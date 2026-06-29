#!/usr/bin/env python3
"""Fail when platform emoji leaks into direct UI text surfaces.

This is intentionally narrow. Raw logs, parser keywords, and cleanup maps may
still contain legacy emoji tokens, but labels, buttons, toasts, and modal text
should not rely on OS emoji rendering.
"""

from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

FILES = [
    "scenes/MainGame.gd",
    "scenes/StoryMode.gd",
    "scenes/StartMenu.gd",
    "scenes/TutorialOverlay.gd",
]

SURFACE_HINTS = (
    "_label(",
    "_wrap_label(",
    "_button(",
    ".text =",
    "lines.append(",
    "_show_toast(",
    "_show_vignette(",
)

EMOJI_RE = re.compile(
    "["
    "\U0001F300-\U0001FAFF"
    "\u2600-\u27BF"
    "]"
)


def allowed(path: str, line: str) -> bool:
    # Familiar close affordance, not a decorative platform emoji.
    return path == "scenes/MainGame.gd" and '_small_button("✕"' in line


def main() -> int:
    findings: list[tuple[str, int, str]] = []
    for rel in FILES:
        p = ROOT / rel
        if not p.exists():
            continue
        for idx, line in enumerate(p.read_text(encoding="utf-8").splitlines(), 1):
            if not any(hint in line for hint in SURFACE_HINTS):
                continue
            if not EMOJI_RE.search(line):
                continue
            if allowed(rel, line):
                continue
            findings.append((rel, idx, line.strip()))

    print("● 직접 UI 이모지 표면 감사")
    if findings:
        print(f"  ✗ surface emoji leaks: {len(findings)}")
        for rel, idx, line in findings[:30]:
            print(f"    {rel}:{idx}: {line}")
        return 1
    print("  ✓ 직접 UI 텍스트 표면 깨끗")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
