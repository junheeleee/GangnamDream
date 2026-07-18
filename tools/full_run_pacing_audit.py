#!/usr/bin/env python3
"""Audit the 240-week novel cadence after the five-chapter redistribution.

The estimate is a structural comparison model, not a substitute for a human
playtest. It combines authored text, deliberation, direct AP weeks, random-event
opportunities, summaries, and the real auto-beat durations. Keeping the model
constant makes later edits comparable and locates the likely two-hour refund line.
"""

from __future__ import annotations

import json
import statistics
import sys
from pathlib import Path
from typing import Any

from narrative_continuity_audit import is_authored, load_events, run_arc_paths


ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "content" / "meta" / "event_director.json"
CHARS_PER_MINUTE = 420.0
CHOICE_DELIBERATION_SECONDS = 8.0
DIRECT_WEEK_SECONDS = 35.0
SUMMARY_SECONDS = 15.0
QUIET_SECONDS = 0.90
ECHO_SECONDS = 1.35
PROLOGUE_MINUTES = 12.0
MIN_RANDOM_OPPORTUNITIES = 24
MAX_RANDOM_OPPORTUNITIES = 36
MIN_RANDOM_PER_CHAPTER = 1


def lists(manifest: dict[str, Any], key: str) -> set[int]:
    return {
        int(value)
        for section in ("demo_pacing", "full_run_pacing")
        for value in manifest.get(section, {}).get(key, [])
    }


def expected_scene_cost(
    event_id: str,
    events: dict[str, dict[str, Any]],
    memo: dict[str, tuple[float, float]],
    stack: tuple[str, ...] = (),
) -> tuple[float, float]:
    if event_id in memo:
        return memo[event_id]
    if event_id in stack:
        raise ValueError("follow-up loop: " + " -> ".join(stack + (event_id,)))
    event = events[event_id]
    description_chars = float(len(str(event.get("description", ""))))
    choices = [choice for choice in event.get("choices", []) if isinstance(choice, dict)]
    if not choices:
        result = (description_chars, 0.0)
        memo[event_id] = result
        return result

    branch_costs: list[tuple[float, float]] = []
    for choice in choices:
        chars = description_chars
        chars += len(str(choice.get("text", "")))
        chars += len(str(choice.get("result_text", "")))
        decisions = float(len(choices) > 1)
        target = str(choice.get("follow_up_event", ""))
        if target:
            child_chars, child_decisions = expected_scene_cost(
                target, events, memo, stack + (event_id,)
            )
            chars += child_chars
            decisions += child_decisions
        branch_costs.append((chars, decisions))
    result = (
        sum(chars for chars, _ in branch_costs) / len(branch_costs),
        sum(decisions for _, decisions in branch_costs) / len(branch_costs),
    )
    memo[event_id] = result
    return result


def scene_minutes(cost: tuple[float, float]) -> float:
    chars, decisions = cost
    return chars / CHARS_PER_MINUTE + decisions * CHOICE_DELIBERATION_SECONDS / 60.0


def main() -> int:
    try:
        manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
        events = load_events()
        paths = run_arc_paths()
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        print(f"FULL_RUN_PACING_AUDIT_FAIL {exc}", file=sys.stderr)
        return 1

    direct = lists(manifest, "decision_weeks")
    bosses = lists(manifest, "boss_weeks")
    echoes = lists(manifest, "echo_weeks")
    summaries = lists(manifest, "full_summary_weeks")
    chapter_direct = [
        sum((chapter - 1) * 48 < turn <= chapter * 48 for turn in direct)
        for chapter in range(1, 6)
    ]
    errors: list[str] = []
    if chapter_direct != [12, 10, 10, 10, 10]:
        errors.append(f"chapter decision cadence drifted: {chapter_direct}")
    if not 40 <= len(direct) <= 60:
        errors.append(f"direct weeks outside 40..60: {len(direct)}")
    if len(bosses) != 7 or not bosses.issubset(direct):
        errors.append(f"boss contract drifted: {sorted(bosses)}")
    if direct & echoes:
        errors.append("direct and echo weeks overlap")

    memo: dict[str, tuple[float, float]] = {}
    random_events = [event for event in events.values() if not is_authored(event)]
    random_costs = [
        scene_minutes(expected_scene_cost(str(event["id"]), events, memo))
        + CHOICE_DELIBERATION_SECONDS / 60.0
        for event in random_events
    ]
    median_random_minutes = statistics.median(random_costs)
    checkpoints: list[int] = []
    totals: list[float] = []
    random_windows: list[int] = []
    random_chapter_windows: list[list[int]] = []

    for path_name, firelog in paths.items():
        elapsed = PROLOGUE_MINUTES
        refund_week = 0
        opportunities = 0
        opportunities_by_chapter = [0, 0, 0, 0, 0]
        chapter_minutes: list[float] = []
        for turn in range(1, 241):
            if turn in firelog:
                elapsed += scene_minutes(expected_scene_cost(firelog[turn], events, memo))
            elif turn > 24 and turn in direct:
                elapsed += median_random_minutes
                opportunities += 1
                opportunities_by_chapter[min(4, (turn - 1) // 48)] += 1
            elapsed += (DIRECT_WEEK_SECONDS / 60.0) if turn in direct else (
                ECHO_SECONDS / 60.0 if turn in echoes else QUIET_SECONDS / 60.0
            )
            if turn in summaries:
                elapsed += SUMMARY_SECONDS / 60.0
            if refund_week == 0 and elapsed >= 120.0:
                refund_week = turn
            if turn % 48 == 0:
                chapter_minutes.append(elapsed)

        exposure = opportunities / max(1, len(random_events))
        if not MIN_RANDOM_OPPORTUNITIES <= opportunities <= MAX_RANDOM_OPPORTUNITIES:
            errors.append(
                f"{path_name}: random opportunities outside "
                f"{MIN_RANDOM_OPPORTUNITIES}..{MAX_RANDOM_OPPORTUNITIES}: {opportunities}"
            )
        sparse_chapters = [
            chapter + 1
            for chapter, count in enumerate(opportunities_by_chapter)
            if count < MIN_RANDOM_PER_CHAPTER
        ]
        if sparse_chapters:
            errors.append(
                f"{path_name}: chapters without a random foreground window: {sparse_chapters}"
            )
        if not 97 <= refund_week <= 144:
            errors.append(f"{path_name}: estimated two-hour point left Chapter 3: week {refund_week}")
        if not 180.0 <= elapsed <= 300.0:
            errors.append(f"{path_name}: estimated run outside 3..5 hours: {elapsed:.1f}m")
        checkpoints.append(refund_week)
        totals.append(elapsed)
        random_windows.append(opportunities)
        random_chapter_windows.append(opportunities_by_chapter)
        print(
            "FULL_RUN_PATH "
            f"name={path_name.replace(' ', '_')} direct={len(direct)} "
            f"chapters={','.join(str(value) for value in chapter_direct)} "
            f"boss={len(bosses)} echo={len(echoes)} summaries={len(summaries)} "
            f"random_windows={opportunities}/{len(random_events)}({exposure * 100:.2f}%) "
            f"random_by_chapter={','.join(str(value) for value in opportunities_by_chapter)} "
            f"refund_week={refund_week} estimated_minutes={elapsed:.1f} "
            f"chapter_cumulative={','.join(f'{value:.1f}' for value in chapter_minutes)}"
        )

    if errors:
        for error in errors:
            print(f"FULL_RUN_PACING_AUDIT_FAIL {error}", file=sys.stderr)
        return 1
    print(
        "FULL_RUN_PACING_AUDIT_OK "
        f"direct={len(direct)} chapter_decisions={chapter_direct} "
        f"random_windows={min(random_windows)}-{max(random_windows)} "
        f"random_chapter_min={min(min(values) for values in random_chapter_windows)} "
        f"refund_week={min(checkpoints)}-{max(checkpoints)} "
        f"estimated_minutes={min(totals):.1f}-{max(totals):.1f}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
