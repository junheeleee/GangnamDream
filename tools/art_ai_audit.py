#!/usr/bin/env python3
"""Inventory and gate the player-facing raster art audit.

The visual verdict itself is human: hands, gaze, identity, architecture, fake
lettering, and grading cannot be certified from dimensions alone. This tool
keeps that review honest by deriving the active ImageRegistry paths, checking
their basic raster contracts, and requiring one completed ledger row per file.

Use the bundled Codex Python only for optional contact sheets because the
release audit deliberately has no Pillow dependency:

  python3 tools/art_ai_audit.py
  <bundled-python> tools/art_ai_audit.py --contact-sheets /tmp/gd_art_audit
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import struct
import sys
from collections import defaultdict
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
REGISTRY = ROOT / "autoloads" / "ImageRegistry.gd"
LEDGER = ROOT / "docs" / "ART_AI_AUDIT.md"
PNG_SIGNATURE = b"\x89PNG\r\n\x1a\n"
BLOCK_RE = r"const\s+{name}\s*=\s*\{{(?P<body>.*?)\n\}}"
ENTRY_RE = re.compile(r'"(?P<id>[^"]+)"\s*:\s*"res://(?P<path>[^"]+)"')
PLAYER_RE = re.compile(
    r'const\s+(?P<id>PLAYER_[A-Z0-9_]+)\s*=\s*"res://(?P<path>assets/characters/[^"]+)"'
)
LEDGER_VERDICTS = {"PASS-A", "PASS-B", "PASS-S", "REPAIRED-A", "REPAIRED-S", "FAIL", "PENDING"}

# These sources are intentionally kept at a wider master ratio. Runtime uses
# aspect-cover, and the audit ledger records the crop review instead of
# resampling already-approved artwork just to satisfy a nominal size.
COVER_SAFE_DIMENSIONS = {(1280, 720), (1672, 941)}


def _registry_group(source: str, name: str, kind: str) -> list[dict]:
    match = re.search(BLOCK_RE.format(name=re.escape(name)), source, re.DOTALL)
    if not match:
        raise RuntimeError("ImageRegistry block missing: %s" % name)
    rows = []
    for entry in ENTRY_RE.finditer(match.group("body")):
        rows.append({"kind": kind, "id": entry.group("id"), "path": entry.group("path")})
    return rows


def active_inventory() -> list[dict]:
    source = REGISTRY.read_text(encoding="utf-8")
    raw = []
    raw.extend(_registry_group(source, "CG", "CG"))
    raw.extend(_registry_group(source, "PORTRAITS", "Portrait"))
    raw.extend(_registry_group(source, "BACKGROUNDS", "Background"))
    for match in PLAYER_RE.finditer(source):
        raw.append({"kind": "Portrait", "id": match.group("id").lower(), "path": match.group("path")})

    grouped: dict[tuple[str, str], list[str]] = defaultdict(list)
    for row in raw:
        grouped[(row["kind"], row["path"])].append(row["id"])
    inventory = []
    order = {"CG": 0, "Portrait": 1, "Background": 2}
    for (kind, path), ids in grouped.items():
        inventory.append({"kind": kind, "path": path, "ids": sorted(set(ids))})
    return sorted(inventory, key=lambda row: (order[row["kind"]], row["path"]))


def _png_info(path: Path) -> tuple[int, int, bool]:
    data = path.read_bytes()
    if not data.startswith(PNG_SIGNATURE) or len(data) < 33 or data[12:16] != b"IHDR":
        raise ValueError("not a readable PNG")
    width, height, _depth, color_type = struct.unpack(">IIBB", data[16:26])
    has_alpha = color_type in (4, 6) or b"tRNS" in data
    return width, height, has_alpha


def _raster_info(path: Path) -> tuple[int, int, bool]:
    if path.suffix.lower() == ".png":
        return _png_info(path)
    raise ValueError("unsupported active raster extension: %s" % path.suffix)


def _ledger_rows() -> tuple[dict[str, dict], list[str], list[str]]:
    if not LEDGER.exists():
        return {}, [], []
    rows: dict[str, dict] = {}
    duplicates: list[str] = []
    malformed: list[str] = []
    for number, line in enumerate(LEDGER.read_text(encoding="utf-8").splitlines(), start=1):
        columns = [column.strip() for column in line.strip().strip("|").split("|")]
        if not columns or columns[0] not in ("CG", "Portrait", "Background"):
            continue
        if len(columns) != 8:
            malformed.append("line %d has %d columns" % (number, len(columns)))
            continue
        asset_match = re.fullmatch(r"`([^`]+)`", columns[1])
        hash_match = re.fullmatch(r"`?([0-9a-f]{12})`?", columns[5])
        verdict = columns[6]
        if not asset_match or not hash_match or verdict not in LEDGER_VERDICTS:
            malformed.append("line %d has invalid asset/hash/verdict" % number)
            continue
        path = asset_match.group(1)
        if path in rows:
            duplicates.append(path)
            continue
        rows[path] = {
            "kind": columns[0],
            "hash": hash_match.group(1),
            "verdict": verdict,
        }
    return rows, duplicates, malformed


def _write_contact_sheets(inventory: list[dict], out_dir: Path) -> None:
    try:
        from PIL import Image, ImageDraw, ImageFont, ImageOps
    except ImportError as exc:
        raise RuntimeError("contact sheets require the bundled Codex Python with Pillow") from exc

    out_dir.mkdir(parents=True, exist_ok=True)
    font = ImageFont.load_default(size=14)
    specs = {
        "CG": (3, 3, 384, 240),
        "Background": (3, 3, 384, 240),
        "Portrait": (4, 2, 240, 340),
    }
    for kind in ("CG", "Portrait", "Background"):
        rows = [row for row in inventory if row["kind"] == kind]
        cols, sheet_rows, tile_w, image_h = specs[kind]
        label_h = 42
        per_sheet = cols * sheet_rows
        for page, start in enumerate(range(0, len(rows), per_sheet), start=1):
            batch = rows[start : start + per_sheet]
            sheet = Image.new("RGB", (cols * tile_w, sheet_rows * (image_h + label_h)), "#15171b")
            draw = ImageDraw.Draw(sheet)
            for index, row in enumerate(batch):
                x = (index % cols) * tile_w
                y = (index // cols) * (image_h + label_h)
                full_path = ROOT / row["path"]
                if not full_path.exists():
                    draw.rectangle((x, y, x + tile_w - 1, y + image_h - 1), fill="#521d26")
                    draw.text((x + 12, y + 12), "MISSING", fill="#ffffff", font=font)
                    source = None
                else:
                    source = Image.open(full_path).convert("RGBA")
                if kind == "Portrait":
                    checker = Image.new("RGB", (tile_w, image_h), "#262a31")
                    cdraw = ImageDraw.Draw(checker)
                    square = 20
                    for cy in range(0, image_h, square):
                        for cx in range(0, tile_w, square):
                            if (cx // square + cy // square) % 2:
                                cdraw.rectangle((cx, cy, cx + square - 1, cy + square - 1), fill="#30353d")
                    if source is not None:
                        fitted = ImageOps.contain(source, (tile_w - 8, image_h - 8))
                        checker.paste(fitted, ((tile_w - fitted.width) // 2, image_h - fitted.height), fitted)
                        tile = checker
                    else:
                        tile = Image.new("RGB", (tile_w, image_h), "#521d26")
                else:
                    tile = (
                        ImageOps.fit(source.convert("RGB"), (tile_w, image_h), method=Image.Resampling.LANCZOS)
                        if source is not None
                        else Image.new("RGB", (tile_w, image_h), "#521d26")
                    )
                sheet.paste(tile, (x, y))
                basename = Path(row["path"]).name
                ids = ", ".join(row["ids"])
                draw.text((x + 6, y + image_h + 4), basename, fill="#f0f2f5", font=font)
                draw.text((x + 6, y + image_h + 22), ids[:52], fill="#a6adb8", font=font)
            output = out_dir / ("%s_%02d.png" % (kind.lower(), page))
            sheet.save(output)
            print("CONTACT_SHEET %s" % output)


def _write_ledger_template(inventory: list[dict], output: Path, verdict: str) -> None:
    counts = defaultdict(int)
    lines = [
        "# ART_AI_AUDIT.md — 활성 이미지 품질 감사",
        "",
        "> `autoloads/ImageRegistry.gd`에서 파생한 출시 활성 에셋만 다룬다. "
        "삭제·미등록 원화는 런타임 품질 판정에 포함하지 않는다.",
        "",
        "## 판정 규칙",
        "",
        "- `PASS-A`: 키 비주얼·CG 기준 통과. 얼굴, 손, 시선, 소품, 크롭을 원본 해상도로 재검수했다.",
        "- `PASS-B`: 게임 화면 기준 통과. 정체성·공간 논리·뭉개진 글자·그레이딩을 확인했다.",
        "- `PASS-S`: 작은 보조 표면 기준 통과.",
        "- `REPAIRED-A/S`: 이번 감사에서 수리 후 재검수했다.",
        "- `FAIL`/`PENDING`: 출시 게이트 미통과. 최종 감사에서는 허용하지 않는다.",
        "",
        "## 전수 판정표",
        "",
        "| Kind | Asset | Registry IDs | Raster | Alpha | Hash | Verdict | Review |",
        "|---|---|---|---:|:---:|:---:|:---:|---|",
    ]
    default_review = {
        "CG": "원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인.",
        "Portrait": "투명 분리·얼굴 정체성·의상 실루엣 확인.",
        "Background": "동선·문/창/가구·간판/인쇄물·게임 크롭 확인.",
    }
    for row in inventory:
        counts[row["kind"]] += 1
        full_path = ROOT / row["path"]
        if full_path.exists():
            width, height, alpha = _raster_info(full_path)
            raster = "%dx%d" % (width, height)
            alpha_text = "yes" if alpha else "no"
            digest = hashlib.sha256(full_path.read_bytes()).hexdigest()[:12]
        else:
            raster = "missing"
            alpha_text = "-"
            digest = "missing"
        ids = ", ".join("`%s`" % value for value in row["ids"])
        row_verdict = "PASS-A" if verdict == "PASS-B" and row["kind"] == "CG" else verdict
        lines.append(
            "| %s | `%s` | %s | %s | %s | `%s` | %s | %s |"
            % (
                row["kind"],
                row["path"],
                ids,
                raster,
                alpha_text,
                digest,
                row_verdict,
                default_review[row["kind"]],
            )
        )
    lines.extend(
        [
            "",
            "Inventory: %d CG / %d portraits / %d backgrounds / %d total."
            % (counts["CG"], counts["Portrait"], counts["Background"], len(inventory)),
            "",
        ]
    )
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text("\n".join(lines), encoding="utf-8")
    print("LEDGER_TEMPLATE %s verdict=%s" % (output, verdict))


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--contact-sheets", type=Path)
    parser.add_argument("--inventory-json", type=Path)
    parser.add_argument("--allow-incomplete-ledger", action="store_true")
    parser.add_argument("--write-ledger-template", type=Path)
    parser.add_argument(
        "--default-verdict",
        choices=("PENDING", "PASS-B"),
        default="PENDING",
        help="Template-only default. PASS-B is for a completed human contact-sheet review.",
    )
    args = parser.parse_args()

    errors: list[str] = []
    warnings: list[str] = []
    inventory = active_inventory()
    if args.write_ledger_template:
        _write_ledger_template(inventory, args.write_ledger_template, args.default_verdict)
    ledger, ledger_duplicates, malformed_ledger_rows = _ledger_rows()
    if ledger_duplicates:
        errors.append("ledger has duplicate paths: %s" % ", ".join(sorted(set(ledger_duplicates))[:8]))
    if malformed_ledger_rows:
        errors.append("ledger has malformed rows: %s" % "; ".join(malformed_ledger_rows[:8]))
    hashes: dict[str, list[str]] = defaultdict(list)
    counts = defaultdict(int)

    for row in inventory:
        counts[row["kind"]] += 1
        full_path = ROOT / row["path"]
        if not full_path.exists():
            errors.append("missing active asset: %s" % row["path"])
            continue
        try:
            width, height, alpha = _raster_info(full_path)
        except ValueError as exc:
            errors.append("%s: %s" % (row["path"], exc))
            continue
        row["width"] = width
        row["height"] = height
        row["alpha"] = alpha
        if (
            row["kind"] in ("CG", "Background")
            and (width, height) != (1280, 800)
            and (width, height) not in COVER_SAFE_DIMENSIONS
        ):
            warnings.append("%s is %dx%d, expected 1280x800" % (row["path"], width, height))
        if row["kind"] == "Portrait" and not alpha:
            errors.append("portrait lacks alpha: %s" % row["path"])
        digest = hashlib.sha256(full_path.read_bytes()).hexdigest()
        row["sha256"] = digest
        hashes[digest].append(row["path"])

    for paths in hashes.values():
        if len(paths) > 1:
            errors.append("byte-identical unique paths: %s" % ", ".join(sorted(paths)))

    expected_paths = {row["path"] for row in inventory}
    documented_paths = set(ledger)
    if expected_paths != documented_paths:
        missing = sorted(expected_paths - documented_paths)
        stale = sorted(documented_paths - expected_paths)
        if missing:
            message = "ledger missing %d active paths: %s" % (len(missing), ", ".join(missing[:8]))
            (warnings if args.allow_incomplete_ledger else errors).append(message)
        if stale:
            message = "ledger has %d stale paths: %s" % (len(stale), ", ".join(stale[:8]))
            (warnings if args.allow_incomplete_ledger else errors).append(message)
    if not args.allow_incomplete_ledger:
        incomplete = sorted(path for path, row in ledger.items() if row["verdict"] in ("FAIL", "PENDING"))
        if incomplete:
            errors.append("ledger has %d incomplete verdicts: %s" % (len(incomplete), ", ".join(incomplete[:8])))
        for row in inventory:
            documented = ledger.get(row["path"])
            if not documented or "sha256" not in row:
                continue
            if documented["kind"] != row["kind"]:
                errors.append(
                    "ledger kind mismatch: %s is %s, expected %s"
                    % (row["path"], documented["kind"], row["kind"])
                )
            if documented["hash"] != row["sha256"][:12]:
                errors.append(
                    "asset changed since human review: %s ledger=%s actual=%s"
                    % (row["path"], documented["hash"], row["sha256"][:12])
                )

    if args.inventory_json:
        args.inventory_json.parent.mkdir(parents=True, exist_ok=True)
        args.inventory_json.write_text(json.dumps(inventory, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    if args.contact_sheets:
        _write_contact_sheets(inventory, args.contact_sheets)

    print(
        "ART_AI_AUDIT inventory=%d cg=%d portraits=%d backgrounds=%d ledger=%d"
        % (len(inventory), counts["CG"], counts["Portrait"], counts["Background"], len(ledger))
    )
    for warning in warnings:
        print("ART_AI_WARNING " + warning)
    for error in errors:
        print("ART_AI_ERROR " + error)
    if errors:
        return 1
    print("ART_AI_AUDIT_OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
