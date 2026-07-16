#!/usr/bin/env python3
"""Whole-game structure audit for the Gangnam Dream recomposition pass.

This is an informational audit, not a release gate. It measures the shape of
the current game so pacing decisions are based on the live catalog and the
representative arc simulator instead of document drift.
"""

from __future__ import annotations

import json
import re
import subprocess
import sys
from collections import Counter, defaultdict
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
EVENT_DIR = ROOT / "content" / "events"
MAIN_GAME = ROOT / "scenes" / "MainGame.gd"
ENDINGS = ROOT / "content" / "endings.json"
TOTAL_WEEKS = 240
WEEKS_PER_YEAR = 48
WEEKS_PER_HALF_YEAR = 24
MONTH_END_WEEKS = set(range(4, TOTAL_WEEKS + 1, 4))


def _load_events() -> list[dict[str, Any]]:
    events: list[dict[str, Any]] = []
    for path in sorted(EVENT_DIR.glob("*.json")):
        raw = json.loads(path.read_text(encoding="utf-8"))
        values = raw if isinstance(raw, list) else list(raw.values())
        for event in values:
            if not isinstance(event, dict) or not event.get("id"):
                continue
            item = dict(event)
            item["_source"] = path.name
            events.append(item)
    return events


def _is_authored(event: dict[str, Any]) -> bool:
    conditions = event.get("conditions", {})
    min_turn = int(conditions.get("min_turn", 1)) if isinstance(conditions, dict) else 1
    return (
        float(event.get("weight", 1.0)) <= 0.0
        or min_turn >= 9999
        or str(event.get("rarity", "")) == "story"
    )


def _nonempty_followups(event: dict[str, Any]) -> list[str]:
    targets: list[str] = []
    for choice in event.get("choices", []):
        if not isinstance(choice, dict):
            continue
        target = str(choice.get("follow_up_event", "")).strip()
        if target:
            targets.append(target)
    return targets


def _longest_chain(events: list[dict[str, Any]]) -> tuple[int, str]:
    graph = {str(event["id"]): _nonempty_followups(event) for event in events}
    targets = {target for values in graph.values() for target in values}
    roots = [event_id for event_id, values in graph.items() if values and event_id not in targets]
    memo: dict[str, int] = {}

    def depth(event_id: str, active: set[str]) -> int:
        if event_id in memo:
            return memo[event_id]
        if event_id in active:
            return 0
        next_active = set(active)
        next_active.add(event_id)
        value = 1 + max((depth(target, next_active) for target in graph.get(event_id, [])), default=0)
        memo[event_id] = value
        return value

    if not roots:
        return 1, "none"
    root = max(roots, key=lambda event_id: depth(event_id, set()))
    return depth(root, set()), root


def _run_arc_flow() -> dict[str, dict[int, str]]:
    proc = subprocess.run(
        [sys.executable, str(ROOT / "tools" / "arc_flow_sim.py"), "--verbose"],
        cwd=ROOT,
        check=True,
        text=True,
        capture_output=True,
    )
    paths: dict[str, dict[int, str]] = {}
    current = ""
    for line in proc.stdout.splitlines():
        match = re.match(r"=== Path (.+) ===", line.strip())
        if match:
            current = match.group(1)
            paths[current] = {}
            continue
        fired = re.match(r"\s*t\s*(\d+)\s+([a-zA-Z0-9_]+)\s*$", line)
        if fired and current:
            paths[current][int(fired.group(1))] = fired.group(2)
    return paths


def _longest_gap(weeks: set[int]) -> tuple[int, int, int]:
    if not weeks:
        return TOTAL_WEEKS, 1, TOTAL_WEEKS
    points = [0, *sorted(weeks), TOTAL_WEEKS + 1]
    best = (0, 0, 0)
    for left, right in zip(points, points[1:]):
        gap = right - left - 1
        if gap > best[0]:
            best = (gap, left + 1, right - 1)
    return best


def _event_window(event: dict[str, Any]) -> tuple[int, int]:
    conditions = event.get("conditions", {})
    if not isinstance(conditions, dict):
        return 1, TOTAL_WEEKS
    start = int(conditions.get("min_turn", 1))
    end = int(conditions.get("max_turn", TOTAL_WEEKS))
    return start, end


def _surface_metrics(source: str) -> dict[str, Any]:
    ap_functions = re.findall(r"^func (_ap_[a-zA-Z0-9_]+)\s*\(", source, re.MULTILINE)
    open_functions = re.findall(r"^func (_open_[a-zA-Z0-9_]+)\s*\(", source, re.MULTILINE)
    page_renderers = re.findall(r"^func (_render_[a-zA-Z0-9_]*page)\s*\(", source, re.MULTILINE)
    routine_match = re.search(r"const _ROUTINE_KINDS := \[([^\]]+)\]", source)
    routine_kinds = re.findall(r'"([a-zA-Z0-9_]+)"', routine_match.group(1)) if routine_match else []
    minigames = [
        path.stem
        for path in sorted((ROOT / "scenes").glob("*.gd"))
        if path.stem in {
            "ArubaGame", "BaccaratTable", "BigWheelGame", "BlackjackTable",
            "DaiSaiTable", "HoldemClub", "JeongseonCasino", "JobHuntMiniGame",
            "RaceTrack", "RouletteTable", "ScalpingGame", "SlotMachineGame",
            "TradingFloor",
        }
    ]
    return {
        "main_lines": len(source.splitlines()),
        "ap_functions": len(set(ap_functions)),
        "open_functions": len(set(open_functions)),
        "page_renderers": len(set(page_renderers)),
        "routine_kinds": routine_kinds,
        "minigames": minigames,
    }


def main() -> int:
    events = _load_events()
    event_ids = {str(event["id"]) for event in events}
    authored = [event for event in events if _is_authored(event)]
    random_pool = [event for event in events if not _is_authored(event)]
    categories = Counter(str(event.get("category", "none")) for event in events)
    rarities = Counter(str(event.get("rarity", "none")) for event in events)
    choices = Counter(len(event.get("choices", [])) for event in events)
    conditionless = sum(1 for event in events if not event.get("conditions"))

    followup_edges = [
        (str(event["id"]), target)
        for event in events
        for target in _nonempty_followups(event)
    ]
    dangling_followups = [(source, target) for source, target in followup_edges if target not in event_ids]
    longest_chain, longest_root = _longest_chain(events)

    arc_paths = _run_arc_flow()
    source = MAIN_GAME.read_text(encoding="utf-8")
    surface = _surface_metrics(source)
    endings = json.loads(ENDINGS.read_text(encoding="utf-8"))
    grades = Counter(str(ending.get("grade", "?")) for ending in endings)
    ending_cg = sum(1 for ending in endings if str(ending.get("cg", "")).strip())

    print("GAME_STRUCTURE_AUDIT")
    print(
        "CATALOG events=%d authored=%d random_pool=%d conditionless=%d followup_edges=%d dangling=%d"
        % (len(events), len(authored), len(random_pool), conditionless, len(followup_edges), len(dangling_followups))
    )
    print("CHOICES " + " ".join("%d=%d" % item for item in sorted(choices.items())))
    print("CATEGORIES " + " ".join("%s=%d" % item for item in categories.most_common()))
    print("RARITIES " + " ".join("%s=%d" % item for item in rarities.most_common()))
    print("CHAINS longest=%d root=%s" % (longest_chain, longest_root))

    for half in range(10):
        start = half * WEEKS_PER_HALF_YEAR + 1
        end = start + WEEKS_PER_HALF_YEAR - 1
        available = sum(
            1
            for event in random_pool
            if _event_window(event)[0] <= end and _event_window(event)[1] >= start
        )
        callbacks = sum(
            1
            for event in random_pool
            if str(event.get("_source", "")).startswith("callback_")
            and _event_window(event)[0] <= end
            and _event_window(event)[1] >= start
        )
        print("POOL H%d weeks=%d-%d eligible=%d callbacks=%d" % (half + 1, start, end, available, callbacks))

    for name, firelog in arc_paths.items():
        fired_weeks = set(firelog)
        month_floor = fired_weeks | MONTH_END_WEEKS
        gap, gap_start, gap_end = _longest_gap(fired_weeks)
        yearly = Counter((week - 1) // WEEKS_PER_YEAR + 1 for week in fired_weeks)
        halves = Counter((week - 1) // WEEKS_PER_HALF_YEAR + 1 for week in fired_weeks)
        print(
            "PATH name=%s authored=%d quiet=%d no_montage_stops=%d no_montage_ap_commits=%d current_montage_floor=%d longest_gap=%d(%d-%d)"
            % (
                name.replace(" ", "_"), len(fired_weeks), TOTAL_WEEKS - len(fired_weeks),
                TOTAL_WEEKS, TOTAL_WEEKS * 2, len(month_floor), gap, gap_start, gap_end,
            )
        )
        print("  YEARS " + " ".join("Y%d=%d" % (year, yearly[year]) for year in range(1, 6)))
        print("  HALVES " + " ".join("H%d=%d" % (half, halves[half]) for half in range(1, 11)))

    print(
        "SURFACES main_lines=%d ap_functions=%d open_functions=%d page_renderers=%d routine_kinds=%d routine_coverage=%.1f%% minigames=%d month_summaries=%d"
        % (
            surface["main_lines"], surface["ap_functions"], surface["open_functions"],
            surface["page_renderers"], len(surface["routine_kinds"]),
            len(surface["routine_kinds"]) / max(1, surface["ap_functions"]) * 100.0,
            len(surface["minigames"]), len(MONTH_END_WEEKS),
        )
    )
    print("ROUTINE " + ",".join(surface["routine_kinds"]))
    print("MINIGAMES " + ",".join(surface["minigames"]))
    print(
        "ENDINGS total=%d cg=%d no_cg=%d grades=%s"
        % (len(endings), ending_cg, len(endings) - ending_cg, ",".join("%s:%d" % item for item in sorted(grades.items())))
    )

    if dangling_followups:
        print("ERROR dangling_followups=" + repr(dangling_followups[:10]))
        return 1
    print("GAME_STRUCTURE_AUDIT_OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
