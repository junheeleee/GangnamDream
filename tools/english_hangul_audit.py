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
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HANGUL_RE = re.compile(r"[\u1100-\u11FF\u3130-\u318F\uAC00-\uD7A3]")
STRING_RE = re.compile(r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'')

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


def scan_runtime() -> dict[str, list[str]]:
    grouped: dict[str, list[str]] = {}
    for target in RUNTIME_TARGETS:
        path = ROOT / target
        if not path.exists():
            continue
        localized_depth = 0
        internal_block_end = ""
        lines = path.read_text(encoding="utf-8", errors="ignore").splitlines()
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


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--content-only", action="store_true", help="only fail on English JSON content")
    parser.add_argument("--max-lines", type=int, default=12, help="sample lines per runtime file")
    args = parser.parse_args()

    content_issues = scan_content()
    runtime_issues = {} if args.content_only else scan_runtime()

    print("English zero-Hangul audit")
    print(f"content_issues={len(content_issues)}")
    if content_issues:
        for item in content_issues[:40]:
            print(f"  {item}")
        if len(content_issues) > 40:
            print(f"  ... {len(content_issues) - 40} more")

    if not args.content_only:
        total_runtime = sum(len(v) for v in runtime_issues.values())
        print(f"runtime_candidate_files={len(runtime_issues)}")
        print(f"runtime_candidate_lines={total_runtime}")
        for path, lines in sorted(runtime_issues.items(), key=lambda kv: (-len(kv[1]), kv[0])):
            print(f"\n{path}: {len(lines)}")
            for line in lines[: args.max_lines]:
                print(f"  {line}")
            if len(lines) > args.max_lines:
                print(f"  ... {len(lines) - args.max_lines} more")

    return 1 if content_issues or runtime_issues else 0


if __name__ == "__main__":
    sys.exit(main())
