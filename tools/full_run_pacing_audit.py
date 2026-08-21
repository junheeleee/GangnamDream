#!/usr/bin/env python3
"""Audit the 240-week novel cadence after the five-chapter redistribution.

The estimate is a structural comparison model, not a substitute for a human
playtest. It combines authored text, deliberation, direct AP weeks, random-event
opportunities, summaries, and the real auto-beat durations. Keeping the model
constant makes later edits comparable and locates the likely two-hour refund line.
"""

from __future__ import annotations

import argparse
import json
import statistics
import sys
from pathlib import Path
from typing import Any

from event_director_audit import (
    EXPECTED_FOREGROUND_RANDOM,
    follow_up_targets,
    is_foreground_random,
)
from narrative_continuity_audit import load_events, run_arc_paths


ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "content" / "meta" / "event_director.json"
CHARS_PER_MINUTE = 420.0
CHOICE_DELIBERATION_SECONDS = 8.0
DIRECT_WEEK_SECONDS = 35.0
SUMMARY_SECONDS = 15.0
QUIET_SECONDS = 0.90
ECHO_SECONDS = 1.35
PROLOGUE_MINUTES = 12.0
# ORDER-52 restores authored delayed consequences into direct weeks. Those
# scenes correctly displace a small number of random foreground opportunities.
MIN_RANDOM_OPPORTUNITIES = 22
MAX_RANDOM_OPPORTUNITIES = 36
MIN_RANDOM_PER_CHAPTER = 1
EXPECTED_REFUND_DIRECT = [29, 35, 37, 45]
EXPECTED_REFUND_ECHO = [33]
TWO_HOUR_MIN_WEEK = 97
TWO_HOUR_MAX_WEEK = 144
YEAR_CLOSE_BOUNDARY_WEEK = 96
YEAR_CLOSE_BOUNDARY_ROOT = "arc_year2_close"
MODELED_RANDOM_ROOT = "modeled_random_foreground"
TWO_HOUR_MINUTES = 120.0
TIME_COMPONENT_SOURCES = frozenset({"scene", "cadence", "summary"})


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


def apply_time_components(
    start_minutes: float,
    components: list[tuple[str, str, float]],
) -> tuple[float, tuple[str, str, float, float] | None]:
    """Apply one week's components and retain the first exact threshold crossing."""
    elapsed = start_minutes
    crossing: tuple[str, str, float, float] | None = None
    for source, root, minutes in components:
        if source not in TIME_COMPONENT_SOURCES:
            raise ValueError(f"unknown pacing component source: {source}")
        before = elapsed
        elapsed += minutes
        if crossing is None and before < TWO_HOUR_MINUTES <= elapsed:
            crossing = (source, root, before, elapsed)
    return elapsed, crossing


def two_hour_boundary_allowed(week: int, root: str, source: str) -> bool:
    """Keep Chapter 3 as the default while admitting the exact Year 2 close crossing."""
    return bool(root) and source in TIME_COMPONENT_SOURCES and (
        TWO_HOUR_MIN_WEEK <= week <= TWO_HOUR_MAX_WEEK
        or (
            week == YEAR_CLOSE_BOUNDARY_WEEK
            and root == YEAR_CLOSE_BOUNDARY_ROOT
            and source == "scene"
        )
    )


def two_hour_boundary_kind(week: int, root: str, source: str) -> str:
    if (
        week == YEAR_CLOSE_BOUNDARY_WEEK
        and root == YEAR_CLOSE_BOUNDARY_ROOT
        and source == "scene"
    ):
        return "year_close"
    if two_hour_boundary_allowed(week, root, source):
        return "chapter3"
    return "invalid"


def run_self_test() -> None:
    cases = [
        (95, YEAR_CLOSE_BOUNDARY_ROOT, "scene", False),
        (96, "arc_year2_close_other", "scene", False),
        (96, YEAR_CLOSE_BOUNDARY_ROOT, "scene", True),
        (96, YEAR_CLOSE_BOUNDARY_ROOT, "cadence", False),
        (96, YEAR_CLOSE_BOUNDARY_ROOT, "summary", False),
        (97, "", "scene", False),
        (97, MODELED_RANDOM_ROOT, "scene", True),
        (144, "arc_year3_close", "scene", True),
        (145, "arc_year4_open", "scene", False),
    ]
    for week, root, source, expected in cases:
        actual = two_hour_boundary_allowed(week, root, source)
        if actual != expected:
            raise AssertionError(
                f"week={week} root={root} source={source} "
                f"expected={expected} got={actual}"
            )

    positive_end, positive = apply_time_components(
        119.0,
        [
            ("scene", YEAR_CLOSE_BOUNDARY_ROOT, 1.25),
            ("cadence", "direct_week_cadence", DIRECT_WEEK_SECONDS / 60.0),
        ],
    )
    if positive is None or positive[:2] != ("scene", YEAR_CLOSE_BOUNDARY_ROOT):
        raise AssertionError(f"year-close scene crossing attribution drifted: {positive}")
    if positive_end <= positive[3]:
        raise AssertionError("fixture must continue applying cadence after the first crossing")

    _, cadence_crossing = apply_time_components(
        119.0,
        [
            ("scene", YEAR_CLOSE_BOUNDARY_ROOT, 0.50),
            ("cadence", "direct_week_cadence", DIRECT_WEEK_SECONDS / 60.0),
        ],
    )
    if cadence_crossing is None or cadence_crossing[:2] != (
        "cadence",
        "direct_week_cadence",
    ):
        raise AssertionError(f"cadence crossing attribution drifted: {cadence_crossing}")
    if two_hour_boundary_allowed(96, cadence_crossing[1], cadence_crossing[0]):
        raise AssertionError("W96 cadence crossing must not borrow the year-close exception")

    _, summary_crossing = apply_time_components(
        119.4,
        [
            ("scene", YEAR_CLOSE_BOUNDARY_ROOT, 0.50),
            ("cadence", "quiet_week_cadence", QUIET_SECONDS / 60.0),
            ("summary", "full_summary", SUMMARY_SECONDS / 60.0),
        ],
    )
    if summary_crossing is None or summary_crossing[:2] != (
        "summary",
        "full_summary",
    ):
        raise AssertionError(f"summary crossing attribution drifted: {summary_crossing}")
    if two_hour_boundary_allowed(96, summary_crossing[1], summary_crossing[0]):
        raise AssertionError("W96 summary crossing must not borrow the year-close exception")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--self-test", action="store_true", help="run boundary fixtures")
    args = parser.parse_args()
    if args.self_test:
        try:
            run_self_test()
        except AssertionError as exc:
            print(f"FULL_RUN_PACING_SELF_TEST_FAIL {exc}", file=sys.stderr)
            return 1
        print(
            "FULL_RUN_PACING_SELF_TEST_OK "
            "cases=12 boundary=W96/arc_year2_close/scene+W97..W144 "
            "root=required components=scene/cadence/summary"
        )
        return 0

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
    if chapter_direct != [13, 9, 10, 10, 10]:
        errors.append(f"chapter decision cadence drifted: {chapter_direct}")
    if not 40 <= len(direct) <= 60:
        errors.append(f"direct weeks outside 40..60: {len(direct)}")
    if len(bosses) != 7 or not bosses.issubset(direct):
        errors.append(f"boss contract drifted: {sorted(bosses)}")
    if direct & echoes:
        errors.append("direct and echo weeks overlap")
    refund_direct = sorted(turn for turn in direct if 25 <= turn <= 48)
    refund_echo = sorted(turn for turn in echoes if 25 <= turn <= 48)
    if refund_direct != EXPECTED_REFUND_DIRECT:
        errors.append(f"refund-line direct cadence drifted: {refund_direct}")
    if refund_echo != EXPECTED_REFUND_ECHO:
        errors.append(f"refund-line echo cadence drifted: {refund_echo}")

    memo: dict[str, tuple[float, float]] = {}
    direct_targets = follow_up_targets(list(events.values()))
    random_events = [
        event
        for event in events.values()
        if is_foreground_random(event, manifest, direct_targets)
    ]
    if len(random_events) != EXPECTED_FOREGROUND_RANDOM:
        errors.append(f"curated foreground pool drifted: {len(random_events)}")
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
        refund_root = ""
        refund_source = ""
        refund_before = 0.0
        refund_after = 0.0
        opportunities = 0
        opportunities_by_chapter = [0, 0, 0, 0, 0]
        chapter_minutes: list[float] = []
        for turn in range(1, 241):
            components: list[tuple[str, str, float]] = []
            if turn in firelog:
                root = firelog[turn]
                components.append((
                    "scene",
                    root,
                    scene_minutes(expected_scene_cost(root, events, memo)),
                ))
            elif turn > 24 and turn in direct:
                components.append(("scene", MODELED_RANDOM_ROOT, median_random_minutes))
                opportunities += 1
                opportunities_by_chapter[min(4, (turn - 1) // 48)] += 1
            if turn in direct:
                cadence_root = "direct_week_cadence"
                cadence_minutes = DIRECT_WEEK_SECONDS / 60.0
            elif turn in echoes:
                cadence_root = "echo_week_cadence"
                cadence_minutes = ECHO_SECONDS / 60.0
            else:
                cadence_root = "quiet_week_cadence"
                cadence_minutes = QUIET_SECONDS / 60.0
            components.append(("cadence", cadence_root, cadence_minutes))
            if turn in summaries:
                components.append(("summary", "full_summary", SUMMARY_SECONDS / 60.0))
            elapsed, crossing = apply_time_components(elapsed, components)
            if refund_week == 0 and crossing is not None:
                refund_week = turn
                refund_source, refund_root, refund_before, refund_after = crossing
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
        if not two_hour_boundary_allowed(refund_week, refund_root, refund_source):
            errors.append(
                f"{path_name}: estimated two-hour point outside "
                f"W{TWO_HOUR_MIN_WEEK}..W{TWO_HOUR_MAX_WEEK} and exact "
                f"W{YEAR_CLOSE_BOUNDARY_WEEK}/{YEAR_CLOSE_BOUNDARY_ROOT}/scene boundary: "
                f"week={refund_week} root={refund_root or 'none'} "
                f"source={refund_source or 'none'}"
            )
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
            f"refund_week={refund_week} refund_root={refund_root or 'none'} "
            f"refund_source={refund_source or 'none'} "
            f"refund_boundary={two_hour_boundary_kind(refund_week, refund_root, refund_source)} "
            f"refund_minutes={refund_before:.2f}->{refund_after:.2f} "
            f"estimated_minutes={elapsed:.1f} "
            f"chapter_cumulative={','.join(f'{value:.1f}' for value in chapter_minutes)}"
        )

    if errors:
        for error in errors:
            print(f"FULL_RUN_PACING_AUDIT_FAIL {error}", file=sys.stderr)
        return 1
    print(
        "FULL_RUN_PACING_AUDIT_OK "
        f"direct={len(direct)} chapter_decisions={chapter_direct} "
        f"refund_cadence=direct:{refund_direct}/echo:{refund_echo} "
        f"random_windows={min(random_windows)}-{max(random_windows)} "
        f"random_chapter_min={min(min(values) for values in random_chapter_windows)} "
        f"refund_week={min(checkpoints)}-{max(checkpoints)} "
        f"estimated_minutes={min(totals):.1f}-{max(totals):.1f}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
