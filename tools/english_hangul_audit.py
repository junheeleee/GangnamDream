#!/usr/bin/env python3
"""Find Korean text that can leak during English play.

This is intentionally stricter than the normal content audit:
- English event/ending JSON must contain zero Hangul characters.
- High-risk runtime UI files are scanned for Hangul string literals that are
  not obviously wrapped in the localizer.

The runtime section is a candidate list, not a full proof. It exists to keep
the English zero-Hangul cleanup reproducible while the game still has many
hand-built UI surfaces.
"""

from __future__ import annotations

import argparse
import bisect
import json
import re
import sys
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HANGUL_RE = re.compile(r"[\u1100-\u11FF\u3130-\u318F\uAC00-\uD7A3]")
STRING_RE = re.compile(r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'')
UI_FORMAT_CALL_RE = re.compile(r"LocaleManager\.ui_format\s*\(")
GD_FUNCTION_RE = re.compile(
    r"(?m)^\s*(?:static\s+)?func\s+([A-Za-z0-9_]+)\s*\("
)
GD_LITERAL_RE = re.compile(r'^"(?:\\.|[^"\\])*"$', re.DOTALL)
UI_FORMAT_SOURCE_DIRS = ("autoloads", "scenes", "systems", "ui_components")
UI_FORMAT_MANIFEST = ROOT / "content" / "meta" / "demo_localization_scope.json"

CONTENT_TARGETS = [ROOT / "content" / "endings_en.json"]
CONTENT_TARGETS += sorted((ROOT / "content" / "events_en").glob("*.json"))

RUNTIME_TARGETS = [
    "autoloads/DataRegistry.gd",
    "autoloads/GameState.gd",
    "autoloads/NewsManager.gd",
    "scenes/StartMenu.gd",
    "scenes/MainGame.gd",
    "scenes/StoryMode.gd",
    "scenes/TutorialOverlay.gd",
    "scenes/JeongseonCasino.gd",
    "scenes/BaccaratTable.gd",
    "scenes/BlackjackTable.gd",
    "scenes/SlotMachineGame.gd",
    "scenes/RouletteTable.gd",
    "scenes/BigWheelGame.gd",
    "scenes/DaiSaiTable.gd",
    "scenes/HoldemClub.gd",
    "scenes/RaceTrack.gd",
    "scenes/TradingFloor.gd",
    "scenes/ScalpingGame.gd",
    "scenes/JobHuntMiniGame.gd",
    "scenes/ArubaGame.gd",
    "systems/InvestmentSystem.gd",
    "systems/JobSystem.gd",
    "systems/InventorySystem.gd",
    "systems/RelationshipSystem.gd",
    "systems/TexasHoldem.gd",
    "systems/DaiSai.gd",
    "systems/HorseWorld.gd",
    "systems/HorseRace.gd",
    "systems/EndingSystem.gd",
    "autoloads/MetaProgression.gd",
]

LOCALIZED_CALLS = (
    "_tr(",
    "LocaleManager.ui(",
    "LocaleManager.ui_context(",
    "_localized_slide(",
)

LOCALIZED_INLINE_MARKERS = (
    " if LocaleManager.is_english() else ",
)

PAIRED_DATA_KEYS = (
    "cat",
    "desc",
    "hint",
    "info",
    "name",
    "q",
    "rare",
    "scene",
    "term",
    "text",
    "tip",
)

PAIRED_DATA_ALIASES = {
    "t": "et",
}

LOCALIZED_INTERNAL_BLOCKS = {
    "scenes/MainGame.gd": (
        ("const _STAT_KR = {", "}"),
    ),
    "autoloads/MetaProgression.gd": (
        ("const ALL_TITLES := [", "]"),
        ("const PERK_RULES := {", "}"),
    ),
    "autoloads/GameState.gd": (
        ("const HOUSING_DATA = {", "}"),
        ("const DIFFICULTY_DATA := {", "}"),
        ("const TENDENCY_DESC := {", "}"),
    ),
    "autoloads/DataRegistry.gd": (
        ("const JOB_TEXT_EN := {", "}"),
        ("const ASSET_TEXT_EN := {", "}"),
        ("const ITEM_TEXT_EN := {", "}"),
        ("const ACHIEVEMENT_TEXT_EN := {", "}"),
        ("const CLUE_TEXT_EN := {", "}"),
        ("const THOUGHT_TEXT_EN := {", "}"),
    ),
    "scenes/StartMenu.gd": (
        ("const RUN_THEMES = [", "]"),
        ("const RUN_THEME_TEXT_EN := {", "}"),
        ("const DIFFICULTY_TEXT_EN := {", "}"),
    ),
}


def rel(path: Path) -> str:
    return str(path.relative_to(ROOT))


def strip_comment(line: str) -> str:
    quote = ""
    escaped = False
    out = []
    for ch in line:
        if escaped:
            out.append(ch)
            escaped = False
            continue
        if ch == "\\" and quote:
            out.append(ch)
            escaped = True
            continue
        if ch in ("'", '"'):
            if not quote:
                quote = ch
            elif quote == ch:
                quote = ""
            out.append(ch)
            continue
        if ch == "#" and not quote:
            break
        out.append(ch)
    return "".join(out)


def paren_delta(line: str) -> int:
    quote = ""
    escaped = False
    delta = 0
    for ch in line:
        if escaped:
            escaped = False
            continue
        if ch == "\\" and quote:
            escaped = True
            continue
        if ch in ("'", '"'):
            if not quote:
                quote = ch
            elif quote == ch:
                quote = ""
            continue
        if quote:
            continue
        if ch == "(":
            delta += 1
        elif ch == ")":
            delta -= 1
    return delta


def balanced_call_span(source: str, start: int) -> tuple[str, int]:
    """Return one GDScript call body and the byte after its closing paren."""
    opening = source.find("(", start)
    if opening < 0:
        raise ValueError("call has no opening parenthesis")
    depth = 0
    in_string = False
    escaped = False
    in_comment = False
    for index in range(opening, len(source)):
        character = source[index]
        if in_comment:
            if character == "\n":
                in_comment = False
            continue
        if in_string:
            if escaped:
                escaped = False
            elif character == "\\":
                escaped = True
            elif character == '"':
                in_string = False
            continue
        if character == "#":
            in_comment = True
        elif character == '"':
            in_string = True
        elif character == "(":
            depth += 1
        elif character == ")":
            depth -= 1
            if depth == 0:
                return source[opening + 1:index], index + 1
    raise ValueError("unterminated GDScript call")


def split_gd_arguments(body: str) -> list[str]:
    arguments: list[str] = []
    start = 0
    depths = {"(": 0, "[": 0, "{": 0}
    closers = {")": "(", "]": "[", "}": "{"}
    in_string = False
    escaped = False
    in_comment = False
    for index, character in enumerate(body):
        if in_comment:
            if character == "\n":
                in_comment = False
            continue
        if in_string:
            if escaped:
                escaped = False
            elif character == "\\":
                escaped = True
            elif character == '"':
                in_string = False
            continue
        if character == "#":
            in_comment = True
        elif character == '"':
            in_string = True
        elif character in depths:
            depths[character] += 1
        elif character in closers:
            depths[closers[character]] -= 1
        elif character == "," and not any(depths.values()):
            arguments.append(body[start:index].strip())
            start = index + 1
    arguments.append(body[start:].strip())
    return arguments


def function_owner(
    functions: list[tuple[int, str]], offset: int
) -> str:
    positions = [position for position, _name in functions]
    index = bisect.bisect_right(positions, offset) - 1
    return functions[index][1] if index >= 0 else "<module>"


def analyze_ui_format_source(
    target: str, source: str
) -> tuple[list[tuple[int, int]], Counter[tuple[str, str, str, str]], list[str]]:
    """Validate literal ui_format templates and return spans safe to suppress.

    A span is safe only when the call has exactly four arguments, both template
    arguments are standalone string literals, and neither the English template
    nor the English argument expression contains Hangul. Dynamic or malformed
    calls remain visible to the runtime scanner.
    """
    functions = [
        (match.start(), match.group(1))
        for match in GD_FUNCTION_RE.finditer(source)
    ]
    spans: list[tuple[int, int]] = []
    observed: Counter[tuple[str, str, str, str]] = Counter()
    issues: list[str] = []
    for match in UI_FORMAT_CALL_RE.finditer(source):
        line = source.count("\n", 0, match.start()) + 1
        try:
            body, end = balanced_call_span(source, match.start())
        except ValueError as exc:
            issues.append(f"{target}:{line}: malformed ui_format call ({exc})")
            continue
        arguments = split_gd_arguments(body)
        if len(arguments) != 4:
            issues.append(
                f"{target}:{line}: ui_format requires exactly four arguments"
            )
            continue
        if not GD_LITERAL_RE.fullmatch(arguments[0]) \
                or not GD_LITERAL_RE.fullmatch(arguments[1]):
            issues.append(
                f"{target}:{line}: ui_format requires literal Korean/English templates"
            )
            continue
        try:
            korean = json.loads(arguments[0])
            english = json.loads(arguments[1])
        except (TypeError, json.JSONDecodeError) as exc:
            issues.append(f"{target}:{line}: invalid ui_format template ({exc})")
            continue
        if HANGUL_RE.search(english):
            issues.append(
                f"{target}:{line}: ui_format English template contains Hangul: {english!r}"
            )
            continue
        if HANGUL_RE.search(arguments[3]):
            issues.append(
                f"{target}:{line}: ui_format English args contain Hangul: "
                f"{arguments[3]!r}"
            )
            continue
        owner = function_owner(functions, match.start())
        observed[(target, owner, korean, english)] += 1
        spans.append((match.start(), end))
    return spans, observed, issues


def suppress_spans(source: str, spans: list[tuple[int, int]]) -> str:
    """Blank validated calls without changing line numbers or adjacent text."""
    if not spans:
        return source
    characters = list(source)
    for start, end in spans:
        for index in range(start, end):
            if characters[index] not in ("\n", "\r"):
                characters[index] = " "
    return "".join(characters)


def ui_format_contract() -> tuple[dict[str, list[tuple[int, int]]], list[str], int]:
    safe_spans: dict[str, list[tuple[int, int]]] = {}
    observed: Counter[tuple[str, str, str, str]] = Counter()
    issues: list[str] = []
    for directory in UI_FORMAT_SOURCE_DIRS:
        for path in sorted((ROOT / directory).rglob("*.gd")):
            target = rel(path)
            source = path.read_text(encoding="utf-8", errors="ignore")
            spans, rows, source_issues = analyze_ui_format_source(target, source)
            if spans:
                safe_spans[target] = spans
            observed.update(rows)
            issues.extend(source_issues)

    try:
        manifest = json.loads(UI_FORMAT_MANIFEST.read_text(encoding="utf-8"))
        plan = manifest["ui_parameterized_template_plan"]
        registry = plan["candidate_registry"]
        supplemental = plan["existing_lookup_before_format_provenance"]
        supplemental_calls = int(plan["existing_lookup_before_format_calls"])
    except (OSError, KeyError, TypeError, json.JSONDecodeError) as exc:
        issues.append(f"manifest: cannot read ui_format registry ({exc})")
        return safe_spans, issues, sum(observed.values())

    expected: Counter[tuple[str, str, str, str]] = Counter()
    for row in registry:
        if not isinstance(row, dict) or row.get("disposition") != "migrate":
            continue
        key = (
            str(row.get("path", "")),
            str(row.get("function", "")),
            str(row.get("ko", "")),
            str(row.get("en", "")),
        )
        expected[key] += int(row.get("count", 0))
    supplemental_observed = 0
    for row in supplemental:
        if not isinstance(row, dict):
            issues.append("manifest: invalid existing lookup-before-format row")
            continue
        count = int(row.get("count", 0))
        key = (
            str(row.get("path", "")),
            str(row.get("function", "")),
            str(row.get("ko", "")),
            str(row.get("en", "")),
        )
        expected[key] += count
        supplemental_observed += count
    if supplemental_observed != supplemental_calls:
        issues.append(
            "manifest: existing lookup-before-format count mismatch "
            f"declared={supplemental_calls} rows={supplemental_observed}"
        )
    if observed != expected:
        for key, count in sorted((expected - observed).items()):
            issues.append(
                "ui_format registry missing source call "
                f"{key[0]}::{key[1]} x{count} KO={key[2]!r} EN={key[3]!r}"
            )
        for key, count in sorted((observed - expected).items()):
            issues.append(
                "ui_format source call is absent from registry "
                f"{key[0]}::{key[1]} x{count} KO={key[2]!r} EN={key[3]!r}"
            )
    return safe_spans, issues, sum(observed.values())


def is_paired_localized_data_line(lines: list[str], index: int) -> bool:
    line = strip_comment(lines[index])
    if not HANGUL_RE.search(line):
        return False
    explicit_pair = re.search(
        r'["\'](?P<key>[A-Za-z0-9_]+)_ko["\']\s*:', line
    )
    if explicit_pair is not None:
        start = max(0, index - 1)
        end = min(len(lines), index + 4)
        window = "\n".join(strip_comment(item) for item in lines[start:end])
        if re.search(
            rf'["\']{re.escape(explicit_pair.group("key"))}_en["\']\s*:',
            window,
        ):
            return True
    for key in PAIRED_DATA_KEYS:
        if not re.search(rf'["\']{re.escape(key)}["\']\s*:', line):
            continue
        start = max(0, index - 1)
        end = min(len(lines), index + 4)
        window = "\n".join(strip_comment(item) for item in lines[start:end])
        if re.search(rf'["\']{re.escape(key)}_en["\']\s*:', window):
            return True
    for key, en_key in PAIRED_DATA_ALIASES.items():
        if not re.search(rf'["\']{re.escape(key)}["\']\s*:', line):
            continue
        start = max(0, index - 1)
        end = min(len(lines), index + 4)
        window = "\n".join(strip_comment(item) for item in lines[start:end])
        if re.search(rf'["\']{re.escape(en_key)}["\']\s*:', window):
            return True
    return False


def internal_only_runtime_line(target: str, line: str) -> bool:
    if target == "scenes/MainGame.gd":
        return (
            "lower_body.find(" in line
            or "lower_title.find(" in line
            or 'for cat in ["주거"' in line
        )
    if target == "autoloads/GameState.gd":
        return (
            'player_name = "김민준"' in line
            or 'player_background = "지방_상경"' in line
            or 'player_route = "직장형"' in line
            or 'var difficulty: String = "현실"' in line
            or 'var run_theme: String = "자유런"' in line
            or '"드라마": {' in line
            or '"현실": {' in line
            or '"지옥고": {' in line
            or 'DIFFICULTY_DATA["현실"]' in line
            or "func start_new_game(" in line
            or 'chosen_name == "김민준"' in line
            or 'DIFFICULTY_DATA.has(chosen_difficulty) else "현실"' in line
            or 'run_theme = "자유런"' in line
            or 'difficulty = "현실"' in line
            or 'return "%d년 %d월 %d주차"' in line
            or 'return "%s%.1f억원"' in line
            or 'return "%s%.0f만원"' in line
            or 'return "%s%.0f원"' in line
            or 'if run_theme == "자유런"' in line
            or 'run_theme = "투자런"' in line
            or 'run_theme = "인맥런"' in line
            or 'run_theme = "성실런"' in line
            or 'TENDENCY_NAMES :=' in line
            or '"investment_skill": "투자감각"' in line
            or '"luck": "운"' in line
            or '"investment": "투자"' in line
            or '"health": "건강"' in line
            or 'player_route = "투자형"' in line
            or 'player_route = "창업형"' in line
            or '"직장형":' in line
            or '"투자형":' in line
            or '"창업형":' in line
            or '"백수":' in line
            or '"알바":' in line
            or '"직장인":' in line
            or '"유튜버":' in line
            or '"코인폐인":' in line
            or '"자유런":' in line
            or '"투자런":' in line
            or '"인맥런":' in line
            or '"청렴런":' in line
        )
    if target == "scenes/StartMenu.gd":
        return (
            'var _selected_theme: String = "자유런"' in line
            or 'var _selected_diff: String = "현실"' in line
            or '"자유런":' in line
            or '"투자런":' in line
            or '"인맥런":' in line
            or '"청렴런":' in line
            or '"드라마":' in line
            or '"현실":' in line
            or '"지옥고":' in line
            or 'GameState.start_new_game(' in line
        )
    if target != "autoloads/MetaProgression.gd":
        return False
    return (
        'run.get("run_theme"' in line
        or 'summary.get("run_theme"' in line
        or '"코인폐인"' in line
    )


def scan_content() -> list[str]:
    issues: list[str] = []
    for path in CONTENT_TARGETS:
        if not path.exists():
            continue
        for lineno, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
            if HANGUL_RE.search(line):
                issues.append(f"{rel(path)}:{lineno}: {line.strip()[:180]}")
    return issues


def scan_runtime(
    ui_format_spans: dict[str, list[tuple[int, int]]] | None = None,
) -> dict[str, list[str]]:
    grouped: dict[str, list[str]] = {}
    ui_format_spans = ui_format_spans or {}
    for target in RUNTIME_TARGETS:
        path = ROOT / target
        if not path.exists():
            continue
        localized_depth = 0
        internal_block_end = ""
        source = path.read_text(encoding="utf-8", errors="ignore")
        source = suppress_spans(source, ui_format_spans.get(target, []))
        lines = source.splitlines()
        for index, raw_line in enumerate(lines):
            lineno = index + 1
            line = strip_comment(raw_line)
            if internal_block_end:
                if line.strip() == internal_block_end:
                    internal_block_end = ""
                continue
            for marker, end_marker in LOCALIZED_INTERNAL_BLOCKS.get(target, ()):
                if marker in line:
                    internal_block_end = end_marker
                    break
            if internal_block_end:
                continue
            if localized_depth > 0:
                localized_depth = max(0, localized_depth + paren_delta(line))
                continue
            if any(call in line for call in LOCALIZED_CALLS):
                localized_depth = max(0, paren_delta(line))
                continue
            if not HANGUL_RE.search(line):
                continue
            if any(marker in line for marker in LOCALIZED_INLINE_MARKERS):
                continue
            if internal_only_runtime_line(target, line):
                continue
            if is_paired_localized_data_line(lines, index):
                continue
            literals = [s for s in STRING_RE.findall(line) if HANGUL_RE.search(s)]
            if not literals:
                continue
            grouped.setdefault(target, []).append(f"{lineno}: {raw_line.strip()[:180]}")
    return grouped


def run_self_test() -> int:
    valid_source = '''
func valid() -> String:
    var value := LocaleManager.ui_format(
        "주차 %d개 남음", "%d WEEKS LEFT", 3, 3)
    var leaked := "실제 누출"
    return value + leaked
'''
    spans, observed, issues = analyze_ui_format_source(
        "scenes/SelfTest.gd", valid_source
    )
    sanitized = suppress_spans(valid_source, spans)
    failures: list[str] = []
    if issues or len(spans) != 1 or sum(observed.values()) != 1:
        failures.append("valid literal ui_format was not accepted")
    if "주차 %d개 남음" in sanitized or "실제 누출" not in sanitized:
        failures.append("validated span suppression hid adjacent runtime Hangul")

    invalid_sources = {
        "dynamic": '''func bad():\n    return LocaleManager.ui_format(KO, "EN %d", 1, 1)\n''',
        "hangul_en": '''func bad():\n    return LocaleManager.ui_format("주차 %d", "영문 %d", 1, 1)\n''',
        "hangul_en_args": '''func bad():\n    return LocaleManager.ui_format("값 %s", "VALUE %s", "안전한 한국어", "영어 화면 누출")\n''',
        "arity": '''func bad():\n    return LocaleManager.ui_format("주차 %d", "WEEK %d", 1)\n''',
        "unterminated": '''func bad():\n    return LocaleManager.ui_format("주차 %d", "WEEK %d", 1, 1\n''',
    }
    for label, source in invalid_sources.items():
        bad_spans, _bad_observed, bad_issues = analyze_ui_format_source(
            f"scenes/SelfTest_{label}.gd", source
        )
        if bad_spans or not bad_issues:
            failures.append(f"{label} ui_format was incorrectly accepted")
    if failures:
        print("ENGLISH_HANGUL_SELF_TEST_FAILED")
        for failure in failures:
            print(f"  {failure}")
        return 1
    print("ENGLISH_HANGUL_SELF_TEST_OK cases=6")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--content-only", action="store_true", help="only fail on English JSON content")
    parser.add_argument("--max-lines", type=int, default=12, help="sample lines per runtime file")
    parser.add_argument("--self-test", action="store_true", help="exercise ui_format parser fail-closed cases")
    args = parser.parse_args()

    if args.self_test:
        return run_self_test()

    content_issues = scan_content()
    ui_format_spans: dict[str, list[tuple[int, int]]] = {}
    ui_format_issues: list[str] = []
    ui_format_calls = 0
    if not args.content_only:
        ui_format_spans, ui_format_issues, ui_format_calls = ui_format_contract()
    runtime_issues = {} if args.content_only else scan_runtime(ui_format_spans)

    print("English zero-Hangul audit")
    print(f"content_issues={len(content_issues)}")
    if content_issues:
        for item in content_issues[:40]:
            print(f"  {item}")
        if len(content_issues) > 40:
            print(f"  ... {len(content_issues) - 40} more")

    if not args.content_only:
        print(f"ui_format_registry_calls={ui_format_calls}")
        print(f"ui_format_contract_issues={len(ui_format_issues)}")
        for item in ui_format_issues[:40]:
            print(f"  {item}")
        if len(ui_format_issues) > 40:
            print(f"  ... {len(ui_format_issues) - 40} more")
        total_runtime = sum(len(v) for v in runtime_issues.values())
        print(f"runtime_candidate_files={len(runtime_issues)}")
        print(f"runtime_candidate_lines={total_runtime}")
        for path, lines in sorted(runtime_issues.items(), key=lambda kv: (-len(kv[1]), kv[0])):
            print(f"\n{path}: {len(lines)}")
            for line in lines[: args.max_lines]:
                print(f"  {line}")
            if len(lines) > args.max_lines:
                print(f"  ... {len(lines) - args.max_lines} more")

    return 1 if content_issues or ui_format_issues or runtime_issues else 0


if __name__ == "__main__":
    sys.exit(main())
