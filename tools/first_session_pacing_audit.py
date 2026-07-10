#!/usr/bin/env python3
"""Guard the authored prologue against returning to a click-through wall."""

from __future__ import annotations

import json
from dataclasses import dataclass
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
START_ID = "story_flashforward"
PLACEHOLDER_CHARS = ".…"


@dataclass(frozen=True)
class PathMetrics:
    event_ids: tuple[str, ...] = ()
    paragraphs: int = 0
    fast_inputs: int = 0
    manual_confirms_with_auto: int = 0
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


def walk_paths(
    events: dict[str, dict],
    event_id: str,
    metrics: PathMetrics,
    stack: tuple[str, ...] = (),
) -> list[PathMetrics]:
    if event_id in stack:
        raise ValueError(f"prologue follow-up loop: {' -> '.join(stack + (event_id,))}")
    event = events.get(event_id)
    if event is None:
        raise ValueError(f"missing prologue follow-up event: {event_id}")

    choices = event.get("choices") or []
    description_paragraphs = paragraph_count(str(event.get("description", "")))
    meaningful = len(choices) > 1
    event_number = len(metrics.event_ids) + 1
    base = PathMetrics(
        event_ids=metrics.event_ids + (event_id,),
        paragraphs=metrics.paragraphs + description_paragraphs,
        fast_inputs=metrics.fast_inputs + description_paragraphs * 2,
        manual_confirms_with_auto=metrics.manual_confirms_with_auto,
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
            fast_inputs=base.fast_inputs + result_paragraphs * 2 + 1,
            manual_confirms_with_auto=base.manual_confirms_with_auto + 1,
            meaningful_choices=base.meaningful_choices,
            first_meaningful_event=base.first_meaningful_event,
        )
        follow_up = str(choice.get("follow_up_event", ""))
        if follow_up:
            paths.extend(walk_paths(events, follow_up, selected, stack + (event_id,)))
        else:
            paths.append(selected)
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
    paths = walk_paths(base_events, START_ID, PathMetrics())
    visited = {event_id for path in paths for event_id in path.event_ids}
    validate_localized_surface(base_events, en_events, visited)

    min_events = min(len(path.event_ids) for path in paths)
    max_events = max(len(path.event_ids) for path in paths)
    max_auto_confirms = max(path.manual_confirms_with_auto for path in paths)
    max_fast_inputs = max(path.fast_inputs for path in paths)
    first_meaningful = min(path.first_meaningful_event for path in paths)
    if max_events > 8:
        raise ValueError(f"prologue chains too many scenes before AP: {max_events}>8")
    if max_auto_confirms > 8:
        raise ValueError(f"prologue needs too many confirms even with auto playback: {max_auto_confirms}>8")
    if first_meaningful > 3:
        raise ValueError(f"first meaningful choice arrives too late: event {first_meaningful}>3")

    print(
        "FIRST_SESSION_PACING_OK "
        f"paths={len(paths)} events={min_events}-{max_events} "
        f"auto_confirms<={max_auto_confirms} fast_inputs<={max_fast_inputs} "
        f"first_meaningful={first_meaningful}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
