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
HANGUL_RE = re.compile(r"[가-힣]")
STRING_RE = re.compile(r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'')

CONTENT_TARGETS = [ROOT / "content" / "endings_en.json"]
CONTENT_TARGETS += sorted((ROOT / "content" / "events_en").glob("*.json"))

RUNTIME_TARGETS = [
    "scenes/MainGame.gd",
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
        for lineno, raw_line in enumerate(path.read_text(encoding="utf-8", errors="ignore").splitlines(), 1):
            line = strip_comment(raw_line)
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
