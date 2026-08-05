#!/usr/bin/env python3
"""Guard the authored prologue against returning to a click-through wall."""

from __future__ import annotations

import json
import sys
from dataclasses import dataclass
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from human_gates import print_pending  # noqa: E402


ROOT = Path(__file__).resolve().parents[1]
START_ID = "story_flashforward"
DEMO_CONTRACT_PATH = ROOT / "content" / "meta" / "demo_core_loop_v2.json"
PREPLAN_BUNDLE_ID = "opening_interview_math"
EXPECTED_OPENING_ROOTS = (
    "arc_intro_01_meal",
    "v2_opening_return_math",
)
EXPECTED_OPENING_TRIGGER = {
    "event_id": "v2_opening_application_send",
    "choices": [0],
    "application_id": "mirae_industrial_tech",
    "status": "submitted",
}
EXPECTED_OPENING_SUPPRESSIONS = {"arc_intro_02_dad_call"}
EXPECTED_FRESH_REPLACEMENT = (
    "story_prologue_meal",
    "story_pressure",
    "v2_opening_application_send",
)
CHAPTER_ROOT = "chapter_card_33"
PLACEHOLDER_CHARS = ".…"
EXPECTED_FRESH_EVENT_SEQUENCE = (
    "story_flashforward",
    "story_arrival",
    "story_knee_door",
    "story_knee_witness",
    "story_knee_choice",
    "story_last_payment_wait",
    "story_last_payment_word",
    "story_last_payment_exit",
    "story_prologue_dad",
    "story_prologue_goal",
    "story_prologue_meal",
    "v2_opening_application_send",
    "arc_intro_01_meal",
    "v2_opening_return_math",
    "chapter_card_33",
)
EXPECTED_FRESH_PATHS = 432
MAX_PARAGRAPHS = 110
MAX_FAST_INPUTS = 220
EXPECTED_DIRECT_CONTINUES = 7
EXPECTED_MANUAL_STORY_STOPS = 8


@dataclass(frozen=True)
class PathMetrics:
    event_ids: tuple[str, ...] = ()
    paragraphs: int = 0
    fast_inputs: int = 0
    manual_story_stops: int = 0
    direct_continues: int = 0
    meaningful_choices: int = 0
    first_meaningful_event: int = 999


def load_events(directory: Path) -> dict[str, dict]:
    events: dict[str, dict] = {}
    for path in sorted(directory.glob("*.json")):
        data = json.loads(path.read_text(encoding="utf-8"))
        if not isinstance(data, list):
            continue
        for event in data:
            if isinstance(event, dict) and event.get("id"):
                events[str(event["id"])] = event
    return events


def paragraph_count(text: str) -> int:
    return sum(1 for part in text.split("\n\n") if part.strip())


def is_placeholder(text: str) -> bool:
    return not text.strip().strip(PLACEHOLDER_CHARS).strip()


def is_direct_continue(event: dict) -> bool:
    choices = event.get("choices") or []
    return (
        len(choices) == 1
        and not event.get("timed", False)
        and not str(event.get("id", "")).startswith("chapter_card_")
        and not choices[0].get("requires_item")
    )


def walk_paths(
    events: dict[str, dict],
    event_id: str,
    metrics: PathMetrics,
    stack: tuple[str, ...] = (),
    suppressed_follow_ups: frozenset[str] = frozenset(),
    follow_up_replacements: dict[tuple[str, str], str] | None = None,
) -> list[PathMetrics]:
    if event_id in stack:
        raise ValueError(f"prologue follow-up loop: {' -> '.join(stack + (event_id,))}")
    event = events.get(event_id)
    if event is None:
        raise ValueError(f"missing prologue follow-up event: {event_id}")

    choices = event.get("choices") or []
    description_paragraphs = paragraph_count(str(event.get("description", "")))
    meaningful = len(choices) > 1
    direct_continue = is_direct_continue(event)
    event_number = len(metrics.event_ids) + 1
    base = PathMetrics(
        event_ids=metrics.event_ids + (event_id,),
        paragraphs=metrics.paragraphs + description_paragraphs,
        fast_inputs=metrics.fast_inputs + description_paragraphs * 2,
        manual_story_stops=metrics.manual_story_stops,
        direct_continues=metrics.direct_continues + int(direct_continue),
        meaningful_choices=metrics.meaningful_choices + int(meaningful),
        first_meaningful_event=(
            min(metrics.first_meaningful_event, event_number)
            if meaningful
            else metrics.first_meaningful_event
        ),
    )
    if not choices:
        return [base]

    paths: list[PathMetrics] = []
    for choice in choices:
        text = str(choice.get("text", ""))
        if is_placeholder(text):
            raise ValueError(f"placeholder choice in first session: {event_id!r} -> {text!r}")
        result_paragraphs = paragraph_count(str(choice.get("result_text", "")))
        selected = PathMetrics(
            event_ids=base.event_ids,
            paragraphs=base.paragraphs + result_paragraphs,
            fast_inputs=base.fast_inputs + result_paragraphs * 2 + int(not direct_continue),
            manual_story_stops=base.manual_story_stops + int(not direct_continue),
            direct_continues=base.direct_continues,
            meaningful_choices=base.meaningful_choices,
            first_meaningful_event=base.first_meaningful_event,
        )
        follow_up = str(choice.get("follow_up_event", ""))
        replacement_key = (event_id, follow_up)
        if follow_up_replacements and replacement_key in follow_up_replacements:
            follow_up = follow_up_replacements[replacement_key]
        if follow_up in suppressed_follow_ups:
            follow_up = ""
        if follow_up:
            paths.extend(walk_paths(
                events,
                follow_up,
                selected,
                stack + (event_id,),
                suppressed_follow_ups,
                follow_up_replacements,
            ))
        else:
            paths.append(selected)
    return paths


def walk_fresh_v2_paths(events: dict[str, dict]) -> list[PathMetrics]:
    """Follow the exact fresh queue through the chapter card before planning.

    StoryMode replaces only the legacy app-open follow-up with the V2 scene
    that actually sends the application. The interview and calculation remain
    reserved queue roots, so they run after that replaced prologue chain.
    """
    contract = json.loads(DEMO_CONTRACT_PATH.read_text(encoding="utf-8"))
    bundle = contract.get("scene_bundles", {}).get(PREPLAN_BUNDLE_ID, {})
    roots = tuple(bundle.get("existing_roots", []))
    suppressions = set(bundle.get("suppress_follow_up_events", []))
    trigger = bundle.get("preplan_trigger", {})
    if roots != EXPECTED_OPENING_ROOTS:
        raise ValueError(
            f"pre-plan opening roots drifted: {roots}!={EXPECTED_OPENING_ROOTS}"
        )
    if suppressions != EXPECTED_OPENING_SUPPRESSIONS:
        raise ValueError(
            "pre-plan opening suppressions drifted: "
            f"{sorted(suppressions)}!={sorted(EXPECTED_OPENING_SUPPRESSIONS)}"
        )
    if trigger != EXPECTED_OPENING_TRIGGER:
        raise ValueError(
            f"pre-plan opening trigger drifted: {trigger}!={EXPECTED_OPENING_TRIGGER}"
        )

    replacement_source, replacement_target, replacement_event = (
        EXPECTED_FRESH_REPLACEMENT
    )
    if replacement_event != str(trigger.get("event_id", "")):
        raise ValueError("fresh prologue replacement no longer matches pre-plan trigger")
    paths = walk_paths(
        events,
        START_ID,
        PathMetrics(),
        follow_up_replacements={
            (replacement_source, replacement_target): replacement_event,
        },
    )
    frozen_suppressions = frozenset(suppressions)
    for root in roots:
        next_paths: list[PathMetrics] = []
        for metrics in paths:
            next_paths.extend(walk_paths(
                events,
                root,
                metrics,
                suppressed_follow_ups=frozen_suppressions,
            ))
        paths = next_paths
    next_paths = []
    for metrics in paths:
        next_paths.extend(walk_paths(events, CHAPTER_ROOT, metrics))
    paths = next_paths
    return paths


def validate_localized_surface(base_events: dict[str, dict], en_events: dict[str, dict], ids: set[str]) -> None:
    for event_id in sorted(ids):
        base = base_events[event_id]
        localized = en_events.get(event_id)
        if localized is None:
            raise ValueError(f"missing English prologue surface: {event_id}")
        base_choices = base.get("choices") or []
        en_choices = localized.get("choices") or []
        if len(base_choices) != len(en_choices):
            raise ValueError(f"choice count mismatch in English prologue: {event_id}")
        for choice in en_choices:
            text = str(choice.get("text", ""))
            if is_placeholder(text):
                raise ValueError(f"placeholder English choice in first session: {event_id!r} -> {text!r}")
        for surface_name, event in (("KO", base), ("EN", localized)):
            chunks = [str(event.get("description", ""))]
            chunks.extend(str(choice.get("result_text", "")) for choice in event.get("choices") or [])
            longest = max(
                (len(part.strip()) for chunk in chunks for part in chunk.split("\n\n") if part.strip()),
                default=0,
            )
            limit = 140 if surface_name == "KO" else 240
            if longest > limit:
                raise ValueError(
                    f"{surface_name} prologue paragraph too dense for the story panel: "
                    f"{event_id} ({longest}>{limit} chars)"
                )


def main() -> int:
    base_events = load_events(ROOT / "content" / "events")
    en_events = load_events(ROOT / "content" / "events_en")
    paths = walk_fresh_v2_paths(base_events)
    visited = {event_id for path in paths for event_id in path.event_ids}
    validate_localized_surface(base_events, en_events, visited)

    min_events = min(len(path.event_ids) for path in paths)
    max_events = max(len(path.event_ids) for path in paths)
    manual_story_stops = {path.manual_story_stops for path in paths}
    direct_continues = {path.direct_continues for path in paths}
    max_fast_inputs = max(path.fast_inputs for path in paths)
    max_paragraphs = max(path.paragraphs for path in paths)
    first_meaningful = min(path.first_meaningful_event for path in paths)
    unexpected_sequences = [
        path.event_ids
        for path in paths
        if path.event_ids != EXPECTED_FRESH_EVENT_SEQUENCE
    ]
    if unexpected_sequences:
        raise ValueError(f"fresh V2 opening sequence drifted: {unexpected_sequences[0]}")
    if len(paths) != EXPECTED_FRESH_PATHS:
        raise ValueError(
            f"fresh V2 opening path count drifted: {len(paths)}!={EXPECTED_FRESH_PATHS}"
        )
    if min_events != len(EXPECTED_FRESH_EVENT_SEQUENCE) \
            or max_events != len(EXPECTED_FRESH_EVENT_SEQUENCE):
        raise ValueError(
            "fresh V2 opening event count drifted: "
            f"{min_events}-{max_events}!={len(EXPECTED_FRESH_EVENT_SEQUENCE)}"
        )
    if max_paragraphs > MAX_PARAGRAPHS:
        raise ValueError(
            "fresh V2 opening prose exceeded its pre-plan budget: "
            f"{max_paragraphs}>{MAX_PARAGRAPHS}"
        )
    if manual_story_stops != {EXPECTED_MANUAL_STORY_STOPS}:
        raise ValueError(
            "fresh V2 opening manual story-stop count drifted: "
            f"{sorted(manual_story_stops)}!={[EXPECTED_MANUAL_STORY_STOPS]}"
        )
    if direct_continues != {EXPECTED_DIRECT_CONTINUES}:
        raise ValueError(
            f"prologue direct-continue count drifted: "
            f"{sorted(direct_continues)}!={[EXPECTED_DIRECT_CONTINUES]}"
        )
    if max_fast_inputs > MAX_FAST_INPUTS:
        raise ValueError(
            "fresh V2 opening fast-forward input budget exceeded: "
            f"{max_fast_inputs}>{MAX_FAST_INPUTS}"
        )
    if first_meaningful > 5:
        raise ValueError(f"first meaningful choice arrives too late: event {first_meaningful}>5")
    if "story_pressure" in visited or "v2_opening_application_send" not in visited:
        raise ValueError(
            "fresh V2 opening must replace story_pressure with the actual Send scene"
        )

    print_pending("pacing")
    print(
        "FIRST_SESSION_PACING_OK "
        f"paths={len(paths)} events={min_events}-{max_events} "
        f"paragraphs<={max_paragraphs} manual_stops={EXPECTED_MANUAL_STORY_STOPS} "
        f"direct={EXPECTED_DIRECT_CONTINUES} fast_inputs<={max_fast_inputs} "
        f"first_meaningful={first_meaningful} replacement=1 chapter=1"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
