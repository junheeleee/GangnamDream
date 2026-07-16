#!/usr/bin/env python3
"""Produce a deterministic GDScript technical-debt inventory.

This is a triage aid, not a linter. Candidates require human classification
before code changes; in particular, text-only reachability cannot prove that a
Godot callback or string-dispatched method is dead.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
from collections import Counter, defaultdict
from dataclasses import asdict, dataclass
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SKIP_PARTS = {".git", ".godot", "addons"}
PRODUCTION_ROOTS = {"autoloads", "data", "scenes", "systems", "ui_components"}
FUNCTION_RE = re.compile(r"^(?:static\s+)?func\s+([A-Za-z_]\w*)\s*\(")
CALLBACKS = {
    "_draw",
    "_enter_tree",
    "_exit_tree",
    "_gui_input",
    "_input",
    "_notification",
    "_physics_process",
    "_process",
    "_ready",
    "_shortcut_input",
    "_unhandled_input",
    "_unhandled_key_input",
}
NUMBER_RE = re.compile(r"(?<![\w.])(-?\d[\d_]*(?:\.\d+)?)(?![\w.])")
STRING_DISPATCH_RE = re.compile(
    r"\b(?:call|call_deferred|has_method)\s*\(\s*[\"']([A-Za-z_]\w*)[\"']"
)
HEX_RE = re.compile(r"[\"'](#[0-9a-fA-F]{6,8})[\"']")
RESOURCE_RE = re.compile(r"[\"'](res://[^\"']+)[\"']")
TOP_LEVEL_DATA_RE = re.compile(
    r"^(?:const|var)\s+([A-Za-z_]\w*)(?:\s*:[^=]+)?\s*(?::=|=)\s*([\[{])"
)
MAIN_RESPONSIBILITIES: tuple[tuple[str, tuple[str, ...]], ...] = (
    ("presentation", ("_build", "_render", "_style", "_make", "_label", "_wrap", "_refresh")),
    ("navigation_modal", ("_open", "_close", "_show", "_hide", "_transition", "_return")),
    ("weekly_ap", ("_ap_", "action", "week", "montage", "routine", "pressure")),
    ("story_arc", ("event", "arc", "story", "choice", "follow_up", "chapter")),
    ("economy", ("invest", "asset", "bank", "loan", "job", "career", "housing", "money", "market")),
    ("relationships", ("relation", "romance", "contact", "daeun", "jiyeon", "father", "hyunsu", "sangchul", "jaehyuk")),
    ("ending_meta", ("ending", "achievement", "archive", "title", "record")),
    ("minigame_bridge", ("casino", "roulette", "slot", "blackjack", "baccarat", "holdem", "daisai", "race", "aruba", "delivery")),
)


@dataclass(frozen=True)
class FunctionBlock:
    path: str
    name: str
    start: int
    end: int
    lines: tuple[str, ...]

    @property
    def length(self) -> int:
        return self.end - self.start + 1


def gd_files() -> list[Path]:
    paths = []
    for path in ROOT.rglob("*.gd"):
        if any(part in SKIP_PARTS for part in path.relative_to(ROOT).parts):
            continue
        paths.append(path)
    return sorted(paths)


def rel(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def function_blocks(path: Path, lines: list[str]) -> list[FunctionBlock]:
    starts: list[tuple[int, str]] = []
    for index, line in enumerate(lines):
        match = FUNCTION_RE.match(line)
        if match:
            starts.append((index, match.group(1)))
    blocks = []
    for position, (start, name) in enumerate(starts):
        end = starts[position + 1][0] - 1 if position + 1 < len(starts) else len(lines) - 1
        while end > start and not lines[end].strip():
            end -= 1
        blocks.append(
            FunctionBlock(
                path=rel(path),
                name=name,
                start=start + 1,
                end=end + 1,
                lines=tuple(lines[start : end + 1]),
            )
        )
    return blocks


def normalized_body(block: FunctionBlock) -> str:
    body = []
    for line in block.lines[1:]:
        code = line.split("#", 1)[0].strip()
        if code:
            body.append(re.sub(r"\s+", " ", code))
    return "\n".join(body)


def main_responsibility(name: str) -> str:
    lowered = name.lower()
    for responsibility, tokens in MAIN_RESPONSIBILITIES:
        if any(token in lowered for token in tokens):
            return responsibility
    return "core_other"


def top_level_data_candidates(path: str, lines: list[str]) -> list[dict]:
    """Find large top-level arrays/dictionaries that may deserve data files.

    This deliberately ignores indented locals. Bracket counting is only a
    candidate locator; the report never edits or fails on these rows.
    """
    rows: list[dict] = []
    index = 0
    while index < len(lines):
        line = lines[index]
        if line.startswith((" ", "\t")):
            index += 1
            continue
        match = TOP_LEVEL_DATA_RE.match(line)
        if not match:
            index += 1
            continue
        opener = match.group(2)
        closer = "}" if opener == "{" else "]"
        depth = line.count(opener) - line.count(closer)
        end = index
        while depth > 0 and end + 1 < len(lines):
            end += 1
            code = lines[end].split("#", 1)[0]
            depth += code.count(opener) - code.count(closer)
        length = end - index + 1
        if length >= 12:
            rows.append({
                "path": path,
                "name": match.group(1),
                "line": index + 1,
                "length": length,
                "kind": "dictionary" if opener == "{" else "array",
            })
        index = max(index + 1, end + 1)
    return rows


def scan() -> dict:
    files = gd_files()
    texts: dict[str, str] = {}
    lines_by_file: dict[str, list[str]] = {}
    blocks: list[FunctionBlock] = []
    file_rows = []

    for path in files:
        path_rel = rel(path)
        text = path.read_text(encoding="utf-8")
        lines = text.splitlines()
        file_blocks = function_blocks(path, lines)
        texts[path_rel] = text
        lines_by_file[path_rel] = lines
        blocks.extend(file_blocks)
        file_rows.append(
            {
                "path": path_rel,
                "lines": len(lines),
                "functions": len(file_blocks),
                "production": path_rel.split("/", 1)[0] in PRODUCTION_ROOTS,
            }
        )

    corpus = "\n".join(texts.values())
    identifier_counts = Counter(re.findall(r"\b[A-Za-z_]\w*\b", corpus))
    production = {
        path: text
        for path, text in texts.items()
        if path.split("/", 1)[0] in PRODUCTION_ROOTS
    }

    main_blocks = [block for block in blocks if block.path == "scenes/MainGame.gd"]
    responsibility_counts = Counter(main_responsibility(block.name) for block in main_blocks)
    responsibility_samples: dict[str, list[str]] = defaultdict(list)
    for block in main_blocks:
        label = main_responsibility(block.name)
        if len(responsibility_samples[label]) < 8:
            responsibility_samples[label].append(block.name)

    long_functions = [
        asdict(block) | {"length": block.length}
        for block in blocks
        if block.length >= 120
    ]
    for row in long_functions:
        row.pop("lines", None)
    long_functions.sort(key=lambda row: (-row["length"], row["path"], row["start"]))

    duplicate_bodies: dict[str, list[dict]] = defaultdict(list)
    for block in blocks:
        body = normalized_body(block)
        if block.length < 8 or len(body) < 80:
            continue
        digest = hashlib.sha256(body.encode("utf-8")).hexdigest()[:12]
        duplicate_bodies[digest].append(
            {"path": block.path, "name": block.name, "line": block.start, "length": block.length}
        )
    duplicate_groups = [
        {"hash": digest, "functions": group}
        for digest, group in duplicate_bodies.items()
        if len(group) > 1
    ]
    duplicate_groups.sort(key=lambda row: (-len(row["functions"]), row["hash"]))

    dynamic_calls = []
    markers = []
    repeated_numbers: dict[str, list[dict]] = {}
    repeated_hex: dict[str, list[dict]] = {}
    repeated_resources: dict[str, list[dict]] = {}
    inline_data_candidates: list[dict] = []
    for path, lines in lines_by_file.items():
        if path not in production:
            continue
        inline_data_candidates.extend(top_level_data_candidates(path, lines))
        number_hits: dict[str, list[int]] = defaultdict(list)
        hex_hits: dict[str, list[int]] = defaultdict(list)
        resource_hits: dict[str, list[int]] = defaultdict(list)
        for line_no, line in enumerate(lines, 1):
            stripped = line.strip()
            code = line.split("#", 1)[0]
            for method in STRING_DISPATCH_RE.findall(code):
                dynamic_calls.append({"path": path, "line": line_no, "method": method})
            if re.search(r"\b(?:TODO|FIXME|HACK|XXX)\b", line, re.I):
                markers.append({"path": path, "line": line_no, "kind": "marker", "text": stripped})
            if re.match(r"^\s*pass(?:\s*(?:#.*)?)?$", line):
                markers.append({"path": path, "line": line_no, "kind": "pass", "text": stripped})
            if stripped.startswith(("const ", "enum ", "#")):
                continue
            for value in NUMBER_RE.findall(code):
                normalized = value.replace("_", "")
                try:
                    numeric = float(normalized)
                except ValueError:
                    continue
                if numeric in {-2.0, -1.0, 0.0, 1.0, 2.0}:
                    continue
                number_hits[value].append(line_no)
            for value in HEX_RE.findall(code):
                hex_hits[value.lower()].append(line_no)
            for value in RESOURCE_RE.findall(code):
                resource_hits[value].append(line_no)
        repeated_numbers[path] = [
            {"value": value, "count": len(hit_lines), "lines": hit_lines[:8]}
            for value, hit_lines in number_hits.items()
            if len(hit_lines) >= 4
        ]
        repeated_hex[path] = [
            {"value": value, "count": len(hit_lines), "lines": hit_lines[:8]}
            for value, hit_lines in hex_hits.items()
            if len(hit_lines) >= 3
        ]
        repeated_resources[path] = [
            {"value": value, "count": len(hit_lines), "lines": hit_lines[:8]}
            for value, hit_lines in resource_hits.items()
            if len(hit_lines) >= 2
        ]
        repeated_numbers[path].sort(key=lambda row: (-row["count"], row["value"]))
        repeated_hex[path].sort(key=lambda row: (-row["count"], row["value"]))
        repeated_resources[path].sort(key=lambda row: (-row["count"], row["value"]))

    dead_candidates = []
    for block in blocks:
        if block.path not in production or block.name in CALLBACKS:
            continue
        references = identifier_counts[block.name]
        if references == 1:
            dead_candidates.append(
                {"path": block.path, "name": block.name, "line": block.start, "length": block.length}
            )
    dead_candidates.sort(key=lambda row: (row["path"], row["line"]))

    hotspots = [
        row for row in file_rows if row["production"] and (row["lines"] >= 1000 or row["functions"] >= 35)
    ]
    hotspots.sort(key=lambda row: (-row["lines"], row["path"]))
    file_rows.sort(key=lambda row: (-row["lines"], row["path"]))
    markers.sort(key=lambda row: (row["path"], row["line"]))
    dynamic_calls.sort(key=lambda row: (row["path"], row["line"]))
    inline_data_candidates.sort(key=lambda row: (-row["length"], row["path"], row["line"]))
    dynamic_call_files = Counter(row["path"] for row in dynamic_calls)
    repeated_literal_files = []
    for path in sorted(production):
        number_rows = repeated_numbers.get(path, [])
        hex_rows = repeated_hex.get(path, [])
        resource_rows = repeated_resources.get(path, [])
        score = sum(row["count"] for row in number_rows + hex_rows + resource_rows)
        if score:
            repeated_literal_files.append({
                "path": path,
                "score": score,
                "number_kinds": len(number_rows),
                "color_kinds": len(hex_rows),
                "resource_kinds": len(resource_rows),
            })
    repeated_literal_files.sort(key=lambda row: (-row["score"], row["path"]))

    return {
        "summary": {
            "files": len(files),
            "production_files": len(production),
            "lines": sum(row["lines"] for row in file_rows),
            "functions": len(blocks),
            "hotspots": len(hotspots),
            "long_functions": len(long_functions),
            "duplicate_body_groups": len(duplicate_groups),
            "dynamic_calls": len(dynamic_calls),
            "markers": len(markers),
            "dead_candidates": len(dead_candidates),
            "inline_data_candidates": len(inline_data_candidates),
        },
        "hotspots": hotspots,
        "long_functions": long_functions,
        "duplicate_bodies": duplicate_groups,
        "dynamic_calls": dynamic_calls,
        "markers": markers,
        "dead_candidates": dead_candidates,
        "repeated_numbers": {path: rows for path, rows in repeated_numbers.items() if rows},
        "repeated_hex": {path: rows for path, rows in repeated_hex.items() if rows},
        "repeated_resources": {path: rows for path, rows in repeated_resources.items() if rows},
        "repeated_literal_files": repeated_literal_files,
        "inline_data_candidates": inline_data_candidates,
        "dynamic_call_files": [
            {"path": path, "count": count}
            for path, count in dynamic_call_files.most_common()
        ],
        "main_game_responsibilities": {
            label: {
                "functions": responsibility_counts[label],
                "samples": responsibility_samples[label],
            }
            for label in sorted(responsibility_counts)
        },
        "largest_files": file_rows[:25],
    }


def print_human(report: dict) -> None:
    summary = report["summary"]
    print(
        "TECH_DEBT_INVENTORY "
        + " ".join(f"{key}={value}" for key, value in summary.items())
    )
    print("\nHOTSPOTS")
    for row in report["hotspots"]:
        print(f"  {row['path']} lines={row['lines']} functions={row['functions']}")
    print("\nLONG_FUNCTIONS")
    for row in report["long_functions"][:30]:
        print(f"  {row['path']}:{row['start']} {row['name']} lines={row['length']}")
    print("\nDEAD_CANDIDATES")
    for row in report["dead_candidates"]:
        print(f"  {row['path']}:{row['line']} {row['name']} lines={row['length']}")
    print("\nMARKERS")
    for row in report["markers"]:
        print(f"  {row['path']}:{row['line']} {row['kind']} {row['text']}")
    print("\nMAIN_GAME_RESPONSIBILITIES")
    for label, row in report["main_game_responsibilities"].items():
        print(f"  {label} functions={row['functions']} samples={','.join(row['samples'][:4])}")
    print("\nDUPLICATE_BODY_GROUPS")
    for row in report["duplicate_bodies"][:12]:
        names = ", ".join(
            f"{item['path']}:{item['line']}:{item['name']}" for item in row["functions"]
        )
        print(f"  {row['hash']} {names}")
    print("\nINLINE_DATA_CANDIDATES")
    for row in report["inline_data_candidates"][:20]:
        print(
            f"  {row['path']}:{row['line']} {row['name']} "
            f"kind={row['kind']} lines={row['length']}"
        )
    print("\nREPEATED_LITERAL_FILES")
    for row in report["repeated_literal_files"][:15]:
        print(
            f"  {row['path']} score={row['score']} numbers={row['number_kinds']} "
            f"colors={row['color_kinds']} resources={row['resource_kinds']}"
        )
    print("\nDYNAMIC_CALL_FILES")
    for row in report["dynamic_call_files"][:15]:
        print(f"  {row['path']} calls={row['count']}")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--json", action="store_true", help="Print the complete report as JSON")
    args = parser.parse_args()
    report = scan()
    if args.json:
        print(json.dumps(report, ensure_ascii=False, indent=2, sort_keys=True))
    else:
        print_human(report)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
