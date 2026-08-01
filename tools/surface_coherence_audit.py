#!/usr/bin/env python3
"""Count the traces a screen leaves when its visual language falls apart.

This does not measure whether the UI looks good — nothing can. It measures the
structural residue that always accompanies a screen language splitting into
many: styles built by hand instead of coming from one owner, font sizes chosen
per call site, and colours picked outside the palette.

Emoji belong to `tools/surface_emoji_audit.py`, which asks the sharper question
of whether they reach the player.

Every metric is a ratchet. Numbers may fall; they may not rise. `ORDER-63`
batch 1 owns this tool and `docs/UI_ART_DIRECTION.md` owns the direction.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from human_gates import print_pending  # noqa: E402
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
BASELINE = Path(__file__).resolve().parent / "surface_coherence_baseline.json"
PALETTE = ROOT / "content" / "themes" / "moral_ui_default.json"

CODE_DIRS = ("autoloads", "scenes", "systems", "tools")
STYLE_OWNER = "autoloads/UIStyle.gd"

# 이모지는 여기서 세지 않는다. `tools/surface_emoji_audit.py`가 "플레이어에게
# 닿는가"라는 더 정확한 질문을 이미 소유하고 통과한다. 저장소 전체를 세면
# 정리 맵·주석·데이터 id가 섞이고, 섞인 숫자에 래칫을 걸면 그 검사는 무시당한다.
STYLEBOX = re.compile(r"StyleBox\w*\.new\(\)")
THEME_OVERRIDE = re.compile(r"add_theme_(?:font_size|color|constant|stylebox)_override\(")
FONT_SIZE = re.compile(r"add_theme_font_size_override\(\s*&?\"[^\"]+\"\s*,\s*(\d+)")
HEX_COLOR = re.compile(r"Color\(\s*\"(#[0-9a-fA-F]{6,8})\"\s*\)")


def code_files() -> list[Path]:
    out: list[Path] = []
    for d in CODE_DIRS:
        base = ROOT / d
        if not base.is_dir():
            continue
        for pattern in ("*.gd", "*.tscn"):
            out.extend(p for p in base.rglob(pattern) if ".godot" not in p.parts)
    return sorted(out)


def palette_colors() -> set[str]:
    """Every colour the theme canon declares, normalised to lowercase #rrggbbaa."""
    if not PALETTE.is_file():
        return set()
    found: set[str] = set()

    def walk(node: Any) -> None:
        if isinstance(node, dict):
            for value in node.values():
                walk(value)
        elif isinstance(node, list):
            for value in node:
                walk(value)
        elif isinstance(node, str) and node.startswith("#"):
            found.add(normalise_color(node))

    walk(json.loads(PALETTE.read_text(encoding="utf-8")))
    return found


def normalise_color(value: str) -> str:
    text = value.strip().lower()
    if len(text) == 7:  # #rrggbb -> assume opaque
        text += "ff"
    return text


def measure() -> tuple[dict[str, int], dict[str, list[str]]]:
    metrics = {
        "stylebox_constructions": 0,
        "theme_overrides_outside_owner": 0,
        "distinct_font_sizes": 0,
        "colors_outside_palette": 0,
        "theme_resources": 0,
    }
    evidence: dict[str, list[str]] = {key: [] for key in metrics}

    palette = palette_colors()
    sizes: set[int] = set()
    off_palette: set[str] = set()

    for path in code_files():
        rel = path.relative_to(ROOT).as_posix()
        try:
            text = path.read_text(encoding="utf-8")
        except (OSError, UnicodeDecodeError):
            continue

        hits = len(STYLEBOX.findall(text))
        if hits:
            metrics["stylebox_constructions"] += hits
            evidence["stylebox_constructions"].append(f"{rel}:{hits}")

        if rel != STYLE_OWNER:
            hits = len(THEME_OVERRIDE.findall(text))
            if hits:
                metrics["theme_overrides_outside_owner"] += hits
                evidence["theme_overrides_outside_owner"].append(f"{rel}:{hits}")

        sizes.update(int(m) for m in FONT_SIZE.findall(text))
        for raw in HEX_COLOR.findall(text):
            colour = normalise_color(raw)
            if palette and colour not in palette:
                off_palette.add(colour)
                evidence["colors_outside_palette"].append(f"{rel}:{colour}")

    metrics["distinct_font_sizes"] = len(sizes)
    evidence["distinct_font_sizes"] = [str(n) for n in sorted(sizes)]
    metrics["colors_outside_palette"] = len(off_palette)

    themes = [
        p for p in ROOT.rglob("*.theme") if ".godot" not in p.parts
    ] + [
        p for p in ROOT.rglob("*.tres")
        if ".godot" not in p.parts and "Theme" in _head(p)
    ]
    metrics["theme_resources"] = len(themes)
    evidence["theme_resources"] = [p.relative_to(ROOT).as_posix() for p in themes]

    for key in evidence:
        evidence[key] = sorted(evidence[key])[:12]
    return metrics, evidence


def _head(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")[:400]
    except (OSError, UnicodeDecodeError):
        return ""


# theme_resources must grow; every other metric must shrink.
GROWS = {"theme_resources"}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--update-baseline",
        action="store_true",
        help="record today's numbers as the new ratchet (intentional changes only)",
    )
    parser.add_argument("--json", action="store_true", help="machine-readable output")
    args = parser.parse_args()

    metrics, evidence = measure()

    if args.update_baseline or not BASELINE.is_file():
        BASELINE.write_text(
            json.dumps({"metrics": metrics}, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )
        print("SURFACE_COHERENCE_BASELINE_WRITTEN " + json.dumps(metrics))
        return 0

    baseline = json.loads(BASELINE.read_text(encoding="utf-8"))["metrics"]

    if args.json:
        print(json.dumps({"metrics": metrics, "baseline": baseline}, ensure_ascii=False))

    failures: list[str] = []
    for key, value in metrics.items():
        before = baseline.get(key)
        if before is None:
            failures.append(f"{key}: 기준선에 없는 지표다. --update-baseline 이 필요하다")
            continue
        if key in GROWS:
            if value < before:
                failures.append(f"{key}: {before} → {value} (줄었다. 늘어야 한다)")
        elif value > before:
            failures.append(f"{key}: {before} → {value} (늘었다)")

    width = max(len(k) for k in metrics)
    for key, value in metrics.items():
        before = baseline.get(key, "-")
        mark = "" if str(before) == str(value) else f"  (기준선 {before})"
        print(f"  {key:<{width}}  {value}{mark}")
        if evidence.get(key) and value:
            print(f"  {'':<{width}}    {', '.join(evidence[key][:6])}")

    if failures:
        print("\nSURFACE_COHERENCE_FAIL — 화면 언어가 더 갈라졌다:")
        for line in failures:
            print(f"  - {line}")
        print(
            "\n  의도한 변경이면 --update-baseline 으로 기준선을 갱신하고 근거를 커밋에 남긴다."
        )
        return 1

    print_pending("surface")
    print("\nSURFACE_COHERENCE_OK " + json.dumps(metrics))
    return 0


if __name__ == "__main__":
    sys.exit(main())
