#!/usr/bin/env python3
"""Measure Tier-1 peak scenes by their actual StoryMode interaction paths."""

from __future__ import annotations

import argparse
import glob
import json
import os
import re
from dataclasses import dataclass
from typing import Any


ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
EVENTS_KO = os.path.join(ROOT, "content", "events")
EVENTS_EN = os.path.join(ROOT, "content", "events_en")

# The names mirror docs/ROMANCE_SYSTEM.md section 8. Each root is the exact
# StoryMode entry point; scheduled scenes weeks later do not count as one chain.
PEAK_ROOTS = (
    ("The Night", "arc_daeun_first_night"),
    ("Daeun Wedding Night", "arc_daeun_wedding_night"),
    ("Jiyeon Wedding Night", "arc_jiyeon_wedding_night"),
    ("Daeun First Kiss", "arc_daeun_first_kiss"),
    ("Jiyeon First Kiss", "arc_jiyeon_first_kiss"),
    ("Mother's Table", "arc_daeun_hometown_2"),
    ("The Narrow Room", "arc_jiyeon_narrow_room_2"),
    ("Namsan with Daeun", "arc_date_namsan_daeun"),
    ("Namsan with Jiyeon", "arc_date_namsan_jiyeon"),
    ("Daeun at the Sea", "arc_season_sea_daeun"),
    ("Jiyeon at the Sea", "arc_season_sea_jiyeon"),
    ("Daeun Fireworks", "arc_season_fireworks_daeun"),
    ("Jiyeon Fireworks", "arc_season_fireworks_jiyeon"),
    ("Daeun Proposal", "arc_daeun_proposal"),
    ("Daeun Wedding", "arc_daeun_wedding_day"),
    ("Jiyeon Wedding Gap", "arc_jiyeon_wedding_gap"),
    ("Jiyeon Verdict", "arc_jiyeon_verdict"),
    ("Daeun Final Choice", "arc_daeun_final_choice"),
    ("Sangchul First Meeting", "arc_sangchul_01_meet"),
    ("Sangchul Deduction", "arc_sangchul_deduction"),
    ("Sangchul Confrontation", "arc_sangchul_confrontation"),
    ("Sangchul Casino Temptation", "arc_sangchul_casino_invite"),
    ("Father's Hospital", "father_hospital_wait"),
    ("Father's Passing", "arc_father_passing"),
    ("The 23-Second KTX Call", "arc_father_call_on_ktx"),
    ("Hyunsu Reunion", "hyunsu_reunion_later"),
    ("Jaehyuk Ghost", "arc_jaehyuk_04a_ghost"),
    ("Jaehyuk's True Face", "arc_jaehyuk_mirror"),
)

MIN_LINKS = 2
MAX_LINKS = 4
MIN_DECISIONS = 2
MAX_DECISIONS = 3
MIN_DIALOGUE_TURNS = 2
MIN_PANELS = 6

# Ratchet updated only after a peak is expanded and its rendered QA passes.
BASELINE_DEBT = 24
REQUIRED_PASS = {
    "arc_date_namsan_daeun",
    "arc_date_namsan_jiyeon",
    "arc_daeun_proposal",
    "arc_daeun_wedding_day",
}


@dataclass(frozen=True)
class PathMetric:
    event_ids: tuple[str, ...]
    decisions: int
    panels: int
    dialogue_turns: int


@dataclass(frozen=True)
class PeakMetric:
    label: str
    root_id: str
    paths: int
    min_links: int
    max_links: int
    min_decisions: int
    max_decisions: int
    min_panels: int
    max_panels: int
    min_dialogue: int
    max_dialogue: int
    passes: bool


def load_events(directory: str) -> dict[str, dict[str, Any]]:
    events: dict[str, dict[str, Any]] = {}
    for path in sorted(glob.glob(os.path.join(directory, "*.json"))):
        with open(path, encoding="utf-8") as handle:
            data = json.load(handle)
        if not isinstance(data, list):
            continue
        for event in data:
            if not isinstance(event, dict) or not event.get("id"):
                continue
            event_id = str(event["id"])
            if event_id in events:
                raise ValueError(f"duplicate event id: {event_id}")
            events[event_id] = event
    return events


def paragraph_count(value: Any) -> int:
    return sum(1 for block in str(value or "").split("\n\n") if block.strip())


def dialogue_count(value: Any) -> int:
    text = str(value or "")
    straight = len(re.findall(r'"[^"\n]+"', text))
    curly = len(re.findall(r"“[^”\n]+”", text))
    corner = len(re.findall(r"「[^」\n]+」", text))
    return straight + curly + corner


def walk_paths(
    events: dict[str, dict[str, Any]],
    event_id: str,
    metric: PathMetric | None = None,
    stack: tuple[str, ...] = (),
) -> list[PathMetric]:
    if event_id in stack:
        raise ValueError(f"peak follow-up loop: {' -> '.join(stack + (event_id,))}")
    if len(stack) >= 12:
        raise ValueError(f"peak chain exceeds safety depth at {event_id}")
    event = events.get(event_id)
    if event is None:
        raise ValueError(f"missing peak event: {event_id}")

    choices = event.get("choices") or []
    if not isinstance(choices, list):
        raise ValueError(f"choices must be an array: {event_id}")
    current = metric or PathMetric((), 0, 0, 0)
    base = PathMetric(
        current.event_ids + (event_id,),
        current.decisions + int(len(choices) > 1),
        current.panels + paragraph_count(event.get("description")),
        current.dialogue_turns + dialogue_count(event.get("description")),
    )
    if not choices:
        return [base]

    paths: list[PathMetric] = []
    for choice in choices:
        if not isinstance(choice, dict):
            raise ValueError(f"choice must be an object: {event_id}")
        selected = PathMetric(
            base.event_ids,
            base.decisions,
            base.panels + 1 + paragraph_count(choice.get("result_text")),
            base.dialogue_turns + dialogue_count(choice.get("result_text")),
        )
        follow_up = str(choice.get("follow_up_event", "")).strip()
        if follow_up:
            paths.extend(walk_paths(events, follow_up, selected, stack + (event_id,)))
        else:
            paths.append(selected)
    return paths


def validate_english_path(
    ko_events: dict[str, dict[str, Any]],
    en_events: dict[str, dict[str, Any]],
    event_ids: set[str],
) -> None:
    for event_id in sorted(event_ids):
        ko = ko_events[event_id]
        en = en_events.get(event_id)
        if en is None:
            raise ValueError(f"missing English peak event: {event_id}")
        ko_choices = ko.get("choices") or []
        en_choices = en.get("choices") or []
        if len(ko_choices) != len(en_choices):
            raise ValueError(
                f"English peak choice mismatch: {event_id} "
                f"{len(en_choices)}!={len(ko_choices)}"
            )


def validate_daeun_proposal_contract(events: dict[str, dict[str, Any]]) -> None:
    """Keep buildup choices from silently changing the canonical marriage route."""
    root_id = "arc_daeun_proposal"
    final_id = "arc_daeun_proposal_answer"
    paths = walk_paths(events, root_id)
    for path in paths:
        if not path.event_ids or path.event_ids[-1] != final_id:
            raise ValueError(
                f"Daeun proposal path must end at {final_id}: "
                f"{' -> '.join(path.event_ids)}"
            )

    protected_flags = {"arc_daeun_proposal_seen", "daeun_married"}
    pre_final_ids = {
        event_id
        for path in paths
        for event_id in path.event_ids
        if event_id != final_id
    }
    for event_id in sorted(pre_final_ids):
        for choice in events[event_id].get("choices") or []:
            leaked = protected_flags.intersection(choice.get("flags") or [])
            if leaked:
                raise ValueError(
                    f"Daeun proposal buildup commits final flags at {event_id}: "
                    f"{', '.join(sorted(leaked))}"
                )

    final_choices = events[final_id].get("choices") or []
    if len(final_choices) != 2:
        raise ValueError("Daeun proposal final decision must retain exactly two choices")
    expected = (
        {
            "effects": {"mental": 25, "tint": 8},
            "flags": ["arc_daeun_proposal_seen", "daeun_married"],
            "cast_effects": {
                "daeun": {"affinity": 30, "stage": "lover"},
            },
            "result_cg": "cg_romance_proposal_daeun",
            "result_cg_reveal_paragraph": 1,
        },
        {
            "effects": {"mental": -6, "tint": -1},
            "flags": ["arc_daeun_proposal_seen"],
            "cast_effects": {"daeun": {"affinity": -4}},
        },
    )
    for index, contract in enumerate(expected):
        choice = final_choices[index]
        for key, value in contract.items():
            if choice.get(key) != value:
                raise ValueError(
                    f"Daeun proposal final choice {index} changed {key}: "
                    f"{choice.get(key)!r}!={value!r}"
                )
    if final_choices[1].get("result_cg"):
        raise ValueError("Daeun proposal defer branch must never reveal a CG")


def validate_daeun_wedding_contract(events: dict[str, dict[str, Any]]) -> None:
    """Preserve the paid ceremony variant and canonical aisle decision."""
    root_id = "arc_daeun_wedding_day"
    final_id = "arc_daeun_wedding_aisle"
    expected_path = (
        "arc_daeun_wedding_day",
        "arc_daeun_wedding_walk",
        "arc_daeun_wedding_aisle",
    )
    paths = walk_paths(events, root_id)
    for path in paths:
        if path.event_ids != expected_path:
            raise ValueError(
                "Daeun wedding path must retain the three-link aisle: "
                f"{' -> '.join(path.event_ids)}"
            )

    protected_flags = {
        "arc_daeun_wedding_day_seen",
        "daeun_wedding_small",
        "daeun_wedding_full",
    }
    for event_id in expected_path[:-1]:
        for choice in events[event_id].get("choices") or []:
            leaked = protected_flags.intersection(choice.get("flags") or [])
            if leaked:
                raise ValueError(
                    f"Daeun wedding buildup changes route flags at {event_id}: "
                    f"{', '.join(sorted(leaked))}"
                )

    expected_cg_if_known = {
        "daeun_wedding_full": "cg_romance_wedding_daeun_full",
        "daeun_wedding_small": "cg_romance_wedding_daeun_small",
    }
    for event_id in expected_path:
        event = events[event_id]
        if event.get("cg") != "cg_romance_wedding_daeun_small":
            raise ValueError(f"Daeun wedding legacy CG changed at {event_id}")
        if event.get("cg_if_known") != expected_cg_if_known:
            raise ValueError(f"Daeun wedding variant map changed at {event_id}")

    final_choices = events[final_id].get("choices") or []
    if len(final_choices) != 2:
        raise ValueError("Daeun wedding final decision must retain exactly two choices")
    expected = (
        {
            "effects": {"mental": 10, "tint": 4},
            "flags": ["arc_daeun_wedding_day_seen"],
            "cast_effects": {"daeun": {"affinity": 8}},
        },
        {
            "effects": {"mental": -6, "tint": 2},
            "flags": ["arc_daeun_wedding_day_seen"],
        },
    )
    for index, contract in enumerate(expected):
        choice = final_choices[index]
        for key, value in contract.items():
            if choice.get(key) != value:
                raise ValueError(
                    f"Daeun wedding final choice {index} changed {key}: "
                    f"{choice.get(key)!r}!={value!r}"
                )
    if final_choices[1].get("cast_effects"):
        raise ValueError("Daeun wedding empty-seat reflection must not gain cast effects")


def measure(label: str, root_id: str, events: dict[str, dict[str, Any]]) -> PeakMetric:
    paths = walk_paths(events, root_id)
    links = [len(path.event_ids) for path in paths]
    decisions = [path.decisions for path in paths]
    panels = [path.panels for path in paths]
    dialogue = [path.dialogue_turns for path in paths]
    passes = (
        min(links) >= MIN_LINKS
        and max(links) <= MAX_LINKS
        and min(decisions) >= MIN_DECISIONS
        and max(decisions) <= MAX_DECISIONS
        and min(panels) >= MIN_PANELS
        and min(dialogue) >= MIN_DIALOGUE_TURNS
    )
    return PeakMetric(
        label,
        root_id,
        len(paths),
        min(links),
        max(links),
        min(decisions),
        max(decisions),
        min(panels),
        max(panels),
        min(dialogue),
        max(dialogue),
        passes,
    )


def span(low: int, high: int) -> str:
    return str(low) if low == high else f"{low}-{high}"


def print_markdown(metrics: list[PeakMetric]) -> None:
    print("| Peak | Root event | Links | Decisions | Panels | Dialogue | Verdict |")
    print("|---|---|---:|---:|---:|---:|---|")
    for metric in metrics:
        print(
            f"| {metric.label} | `{metric.root_id}` | "
            f"{span(metric.min_links, metric.max_links)} | "
            f"{span(metric.min_decisions, metric.max_decisions)} | "
            f"{span(metric.min_panels, metric.max_panels)} | "
            f"{span(metric.min_dialogue, metric.max_dialogue)} | "
            f"{'PASS' if metric.passes else 'EXPAND'} |"
        )


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--markdown", action="store_true")
    parser.add_argument("--strict", action="store_true")
    args = parser.parse_args()

    ko_events = load_events(EVENTS_KO)
    en_events = load_events(EVENTS_EN)
    validate_daeun_proposal_contract(ko_events)
    validate_daeun_wedding_contract(ko_events)
    metrics = [measure(label, root_id, ko_events) for label, root_id in PEAK_ROOTS]
    visited = {
        event_id
        for _, root_id in PEAK_ROOTS
        for path in walk_paths(ko_events, root_id)
        for event_id in path.event_ids
    }
    validate_english_path(ko_events, en_events, visited)

    debt = sum(not metric.passes for metric in metrics)
    passing = {metric.root_id for metric in metrics if metric.passes}
    if args.markdown:
        print_markdown(metrics)
    else:
        for metric in metrics:
            print(
                "PEAK_CHAIN "
                f"root={metric.root_id} links={span(metric.min_links, metric.max_links)} "
                f"decisions={span(metric.min_decisions, metric.max_decisions)} "
                f"panels={span(metric.min_panels, metric.max_panels)} "
                f"dialogue={span(metric.min_dialogue, metric.max_dialogue)} "
                f"verdict={'PASS' if metric.passes else 'EXPAND'}"
            )
    print(f"PEAK_SCENE_CHAIN_AUDIT peaks={len(metrics)} pass={len(metrics) - debt} debt={debt}")

    if args.strict:
        missing_pass = sorted(REQUIRED_PASS - passing)
        if missing_pass:
            raise ValueError(f"gold-standard peak regressed: {', '.join(missing_pass)}")
        if debt > BASELINE_DEBT:
            raise ValueError(f"peak-chain debt regressed: {debt}>{BASELINE_DEBT}")
        print(f"PEAK_SCENE_CHAIN_OK pass={len(metrics) - debt} debt={debt} baseline={BASELINE_DEBT}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
