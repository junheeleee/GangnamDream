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
MAIN_GAME = os.path.join(ROOT, "scenes", "MainGame.gd")

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
BASELINE_DEBT = 19
REQUIRED_PASS = {
    "arc_date_namsan_daeun",
    "arc_date_namsan_jiyeon",
    "arc_daeun_proposal",
    "arc_daeun_wedding_day",
    "arc_jiyeon_wedding_gap",
    "arc_sangchul_confrontation",
    "father_hospital_wait",
    "arc_father_passing",
    "arc_father_call_on_ktx",
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
        "arc_daeun_wedding_groom_side",
        "arc_daeun_wedding_walk",
        "arc_daeun_wedding_aisle",
    )
    paths = walk_paths(events, root_id)
    for path in paths:
        if path.event_ids != expected_path:
            raise ValueError(
                "Daeun wedding path must retain the four-link reaction/aisle chain: "
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

    root = events[root_id]
    if root.get("cg") != "cg_romance_wedding_daeun_mother_reaction":
        raise ValueError("Daeun wedding mother reaction CG changed at entry")
    if root.get("cg_if_known"):
        raise ValueError("Daeun wedding mother reaction must not carry route variants")

    groom_side = events["arc_daeun_wedding_groom_side"]
    groom_side_cg_if_known = {
        "father_passed&hyunsu_reconnected": "cg_romance_wedding_daeun_father_reaction_passed_hyunsu",
        "father_passed": "cg_romance_wedding_daeun_father_reaction_passed",
        "hyunsu_reconnected": "cg_romance_wedding_daeun_father_reaction_hyunsu",
    }
    if groom_side.get("cg") != "cg_romance_wedding_daeun_father_reaction":
        raise ValueError("Daeun wedding groom-side reaction CG changed")
    if list((groom_side.get("cg_if_known") or {}).items()) != list(groom_side_cg_if_known.items()):
        raise ValueError("Daeun wedding groom-side state map or precedence changed")

    wide_cg_if_known = {
        "daeun_wedding_full": "cg_romance_wedding_daeun_full",
        "daeun_wedding_small": "cg_romance_wedding_daeun_small",
    }
    walk = events["arc_daeun_wedding_walk"]
    if walk.get("cg") != "cg_romance_wedding_daeun_small":
        raise ValueError("Daeun wedding couple-wide CG changed at bride entrance")
    if list((walk.get("cg_if_known") or {}).items()) != list(wide_cg_if_known.items()):
        raise ValueError("Daeun wedding couple-wide package map changed")

    close_cg_if_known = {
        "daeun_wedding_full": "cg_romance_wedding_daeun_full_close",
        "daeun_wedding_small": "cg_romance_wedding_daeun_small_close",
    }
    final_event = events[final_id]
    if final_event.get("cg") != "cg_romance_wedding_daeun_small_close":
        raise ValueError("Daeun wedding close CG changed at final aisle link")
    if list((final_event.get("cg_if_known") or {}).items()) != list(close_cg_if_known.items()):
        raise ValueError("Daeun wedding close package map changed at final aisle link")

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


def validate_jiyeon_wedding_gap_contract(events: dict[str, dict[str, Any]]) -> None:
    """Preserve Jiyeon's class-pressure scene as pre-decision negotiation only."""
    root_id = "arc_jiyeon_wedding_gap"
    final_id = "arc_jiyeon_wedding_gap_decision"
    expected_path = (
        "arc_jiyeon_wedding_gap",
        "arc_jiyeon_wedding_guest_list",
        "arc_jiyeon_wedding_gap_decision",
    )
    paths = walk_paths(events, root_id)
    for path in paths:
        if path.event_ids != expected_path:
            raise ValueError(
                "Jiyeon wedding gap must retain the three-link class-pressure chain: "
                f"{' -> '.join(path.event_ids)}"
            )

    protected_flags = {"arc_jiyeon_wedding_gap_seen"}
    for event_id in expected_path[:-1]:
        event = events[event_id]
        if event.get("cg") != "cg_romance_wedding_gap_jiyeon":
            raise ValueError(f"Jiyeon wedding gap buildup CG changed at {event_id}")
        for choice in event.get("choices") or []:
            leaked = protected_flags.intersection(choice.get("flags") or [])
            if leaked:
                raise ValueError(
                    f"Jiyeon wedding gap buildup commits final flags at {event_id}: "
                    f"{', '.join(sorted(leaked))}"
                )
            for forbidden in ("effects", "cast_effects", "result_cg", "result_background"):
                if choice.get(forbidden):
                    raise ValueError(
                        f"Jiyeon wedding gap buildup must not apply {forbidden} at {event_id}"
                    )

    final_event = events[final_id]
    if final_event.get("cg") != "cg_romance_wedding_gap_jiyeon":
        raise ValueError("Jiyeon wedding gap final decision CG changed")
    final_choices = final_event.get("choices") or []
    if len(final_choices) != 2:
        raise ValueError("Jiyeon wedding gap final decision must retain exactly two choices")
    expected = (
        {
            "effects": {"money": -20000000, "mental": -8, "tint": -4},
            "flags": ["arc_jiyeon_wedding_gap_seen"],
            "cast_effects": {"jiyeon": {"affinity": 4}},
        },
        {
            "effects": {"mental": 6, "tint": 5},
            "flags": ["arc_jiyeon_wedding_gap_seen"],
            "cast_effects": {"jiyeon": {"affinity": -6}},
        },
    )
    for index, contract in enumerate(expected):
        choice = final_choices[index]
        for key, value in contract.items():
            if choice.get(key) != value:
                raise ValueError(
                    f"Jiyeon wedding gap final choice {index} changed {key}: "
                    f"{choice.get(key)!r}!={value!r}"
                )


def validate_sangchul_confrontation_contract(events: dict[str, dict[str, Any]]) -> None:
    """Keep every t60 response consequential without changing its total outcome."""
    root_id = "arc_sangchul_confrontation"
    reckoning_id = "arc_sangchul_reckoning"
    buried_id = "arc_sangchul_buried_silence"
    stairwell_id = "arc_sangchul_stairwell"
    paths = walk_paths(events, root_id)
    actual_paths = {path.event_ids for path in paths}
    expected_paths = {
        (root_id, reckoning_id),
        (root_id, buried_id),
        (root_id, buried_id, reckoning_id),
        (root_id, stairwell_id),
        (root_id, stairwell_id, reckoning_id),
    }
    if actual_paths != expected_paths:
        rendered = ", ".join(" -> ".join(path) for path in sorted(actual_paths))
        raise ValueError(f"Sangchul confrontation paths changed: {rendered}")

    root_choices = events[root_id].get("choices") or []
    if len(root_choices) != 3:
        raise ValueError("Sangchul confrontation must retain exactly three opening responses")
    expected_followups = [reckoning_id, buried_id, stairwell_id]
    for index, choice in enumerate(root_choices):
        if choice.get("follow_up_event") != expected_followups[index]:
            raise ValueError(f"Sangchul opening response {index} changed its branch")
        for forbidden in ("effects", "cast_effects", "flags"):
            if choice.get(forbidden):
                raise ValueError(
                    f"Sangchul opening response {index} commits {forbidden} before its final link"
                )

    branch_contracts = {
        buried_id: {
            "effects": {"mental": 5, "tint": -3},
            "cast_effects": {"sangchul": {"stage": "strained"}},
            "flags": ["arc_sangchul_confrontation_seen", "sangchul_truth_buried"],
        },
        stairwell_id: {
            "effects": {"mental": -3, "reputation": -2, "tint": 8},
            "cast_effects": {"sangchul": {"stage": "strained"}},
            "flags": ["arc_sangchul_confrontation_seen", "sangchul_quietly_distanced"],
        },
    }
    for event_id, contract in branch_contracts.items():
        choices = events[event_id].get("choices") or []
        if len(choices) != 2:
            raise ValueError(f"{event_id} must offer confirmation or return to the reckoning")
        for key, value in contract.items():
            if choices[0].get(key) != value:
                raise ValueError(
                    f"{event_id} final confirmation changed {key}: "
                    f"{choices[0].get(key)!r}!={value!r}"
                )
        if choices[0].get("follow_up_event"):
            raise ValueError(f"{event_id} final confirmation must end its branch")
        if choices[1].get("follow_up_event") != reckoning_id:
            raise ValueError(f"{event_id} return choice must rejoin the reckoning")
        for forbidden in ("effects", "cast_effects", "flags"):
            if choices[1].get(forbidden):
                raise ValueError(f"{event_id} return choice commits {forbidden} too early")

    reckoning_choices = events[reckoning_id].get("choices") or []
    expected_reckoning = (
        {
            "effects": {"mental": 10, "reputation": -10, "tint": 9},
            "cast_effects": {"sangchul": {"stage": "cut_off"}},
            "flags": [
                "arc_sangchul_confrontation_seen",
                "sangchul_confronted",
                "arc_sangchul_reckoning_seen",
                "sangchul_reported",
                "sangchul_cut_ties",
            ],
        },
        {
            "effects": {"mental": 3, "tint": 6},
            "cast_effects": {"sangchul": {"stage": "strained", "affinity": -10}},
            "flags": [
                "arc_sangchul_confrontation_seen",
                "sangchul_confronted",
                "arc_sangchul_reckoning_seen",
                "sangchul_forgiven",
            ],
        },
        {
            "effects": {"mental": -15, "investment_skill": 5, "tint": -7},
            "cast_effects": {"sangchul": {"stage": "strained"}},
            "flags": [
                "arc_sangchul_confrontation_seen",
                "sangchul_confronted",
                "arc_sangchul_reckoning_seen",
                "sangchul_leveraged",
                "crossed_line",
            ],
        },
        {
            "effects": {"mental": 7, "reputation": 5, "tint": 7},
            "cast_effects": {"sangchul": {"stage": "strained", "affinity": -5}},
            "flags": [
                "arc_sangchul_confrontation_seen",
                "sangchul_confronted",
                "arc_sangchul_reckoning_seen",
                "cleared_father_debt_from_sangchul",
            ],
        },
    )
    if len(reckoning_choices) != len(expected_reckoning):
        raise ValueError("Sangchul reckoning must retain exactly four final judgments")
    for index, contract in enumerate(expected_reckoning):
        choice = reckoning_choices[index]
        for key, value in contract.items():
            if choice.get(key) != value:
                raise ValueError(
                    f"Sangchul reckoning choice {index} changed total {key}: "
                    f"{choice.get(key)!r}!={value!r}"
                )


def validate_father_hospital_contract(events: dict[str, dict[str, Any]]) -> None:
    """Keep the Changwon visit physical and preserve both canonical outcomes."""
    root_id = "father_hospital_wait"
    final_id = "father_hospital_results"
    expected_path = (root_id, final_id)
    for path in walk_paths(events, root_id):
        if path.event_ids != expected_path:
            raise ValueError(
                "Father hospital must retain the wait-to-results chain: "
                f"{' -> '.join(path.event_ids)}"
            )

    root = events[root_id]
    if root.get("background") != "hospital" or root.get("portrait") != "player_offduty_neutral":
        raise ValueError("Father hospital wait must show local Minjun in the Changwon hospital")
    conditions = root.get("conditions") or {}
    if conditions.get("flag") != "father_visited" or conditions.get("no_flag") != "father_passed":
        raise ValueError("Father hospital wait lost its visited/alive prerequisite")
    root_choices = root.get("choices") or []
    if len(root_choices) != 2:
        raise ValueError("Father hospital wait must retain two waiting responses")
    for index, choice in enumerate(root_choices):
        if choice.get("follow_up_event") != final_id:
            raise ValueError(f"Father hospital waiting response {index} skips the results link")
        for forbidden in ("effects", "cast_effects", "flags"):
            if choice.get(forbidden):
                raise ValueError(
                    f"Father hospital waiting response {index} commits {forbidden} before results"
                )

    final = events[final_id]
    if final.get("background") != "hospital" or final.get("portrait") != "father_hospitalized":
        raise ValueError("Father hospital results must reveal Father in a patient gown")
    final_choices = final.get("choices") or []
    expected = (
        {
            "effects": {"mental": -9},
            "cast_effects": {"father": {"affinity": 3}},
            "flags": [],
        },
        {
            "effects": {"mental": 1, "intelligence": 2},
            "cast_effects": {"father": {"affinity": 6, "stage": "hopeful"}},
            "flags": ["saw_father_medical"],
        },
    )
    if len(final_choices) != len(expected):
        raise ValueError("Father hospital final decision must retain exactly two choices")
    for index, contract in enumerate(expected):
        choice = final_choices[index]
        for key, value in contract.items():
            if choice.get(key) != value:
                raise ValueError(
                    f"Father hospital final choice {index} changed {key}: "
                    f"{choice.get(key)!r}!={value!r}"
                )


def validate_father_passing_contract(events: dict[str, dict[str, Any]]) -> None:
    """Separate every physical location while preserving both canonical losses."""
    root_id = "arc_father_passing"
    platform_id = "arc_father_passing_platform"
    deal_room_id = "arc_father_passing_deal_room"
    hospital_id = "arc_father_passing_hospital_room"
    deal_morning_id = "arc_father_passing_deal_morning"
    expected_paths = {
        (root_id, platform_id, hospital_id),
        (root_id, platform_id, deal_morning_id),
        (root_id, deal_room_id, hospital_id),
        (root_id, deal_room_id, deal_morning_id),
    }
    actual_paths = {path.event_ids for path in walk_paths(events, root_id)}
    if actual_paths != expected_paths:
        raise ValueError(
            "Father passing paths changed: "
            f"actual={sorted(actual_paths)!r} expected={sorted(expected_paths)!r}"
        )

    expected_visuals = {
        root_id: ("current_housing", "player_shocked"),
        platform_id: ("seoul_station_ktx_platform_winter", None),
        deal_room_id: ("meeting", "player_suit"),
        hospital_id: ("changwon_hospital_room_empty", None),
        deal_morning_id: ("meeting", "player_suit"),
    }
    for event_id, (background, portrait) in expected_visuals.items():
        event = events[event_id]
        if event.get("background") != background or event.get("portrait") != portrait:
            raise ValueError(
                f"Father passing {event_id} visual changed: "
                f"{event.get('background')!r}/{event.get('portrait')!r}"
            )

    root_choices = events[root_id].get("choices") or []
    if len(root_choices) != 2 or [choice.get("follow_up_event") for choice in root_choices] != [
        platform_id,
        deal_room_id,
    ]:
        raise ValueError("Father passing root must branch to platform or deal room")

    for event_id in (root_id, platform_id, deal_room_id):
        choices = events[event_id].get("choices") or []
        if len(choices) != 2:
            raise ValueError(f"Father passing buildup must retain two choices: {event_id}")
        for choice_index, choice in enumerate(choices):
            for forbidden in ("effects", "cast_effects", "flags"):
                if choice.get(forbidden):
                    raise ValueError(
                        f"Father passing buildup {event_id}[{choice_index}] "
                        f"commits {forbidden} before the terminal scene"
                    )

    expected_terminal = {
        hospital_id: {
            "effects": {"mental": -40, "tint": 10},
            "cast_effects": {"father": {"stage": "passed"}},
            "flags": [
                "arc_father_passing_seen",
                "father_passed",
                "tried_to_go_to_father",
            ],
        },
        deal_morning_id: {
            "effects": {"mental": -25, "money": 5_000_000, "tint": -8},
            "cast_effects": {"father": {"stage": "passed"}},
            "flags": [
                "arc_father_passing_seen",
                "father_passed",
                "chose_money_over_father",
            ],
        },
    }
    for event_id, contract in expected_terminal.items():
        choices = events[event_id].get("choices") or []
        if len(choices) != 1:
            raise ValueError(f"Father passing terminal must have one acknowledgement: {event_id}")
        for key, value in contract.items():
            if choices[0].get(key) != value:
                raise ValueError(
                    f"Father passing terminal {event_id} changed {key}: "
                    f"{choices[0].get(key)!r}!={value!r}"
                )


def validate_jiyeon_marriage_routing_contract() -> None:
    """Keep Jiyeon's marriage chronology explicit even when Minjun is broke."""
    with open(MAIN_GAME, encoding="utf-8") as handle:
        source = handle.read()

    def if_block_before(return_line: str) -> str:
        return_at = source.find(return_line)
        if return_at < 0:
            raise ValueError(f"missing Jiyeon routing return: {return_line}")
        block_at = source.rfind("\n\tif ", 0, return_at)
        if block_at < 0:
            raise ValueError(f"missing Jiyeon routing condition before: {return_line}")
        return source[block_at:return_at + len(return_line)]

    wedding_block = if_block_before('return "arc_jiyeon_wedding_gap"')
    for token in (
        "t >= 205",
        'f.get("jiyeon_romance_started", false)',
        'f.get("arc_y4_marriage_talk_seen", false)',
        'not f.get("arc_jiyeon_wedding_gap_seen", false)',
    ):
        if token not in wedding_block:
            raise ValueError(f"Jiyeon wedding chronology gate missing: {token}")

    marriage_talk_block = if_block_before('return "arc_y4_marriage_talk"')
    for token in (
        "t >= 193",
        'f.get("jiyeon_romance_started", false)',
        'not f.get("arc_y4_marriage_talk_seen", false)',
    ):
        if token not in marriage_talk_block:
            raise ValueError(f"Jiyeon Y5 marriage-talk catch-up gate missing: {token}")

    verdict_block = if_block_before('return "arc_jiyeon_verdict"')
    for token in (
        "t >= 228",
        'f.get("jiyeon_romance_started", false)',
        'f.get("arc_jiyeon_wedding_night_seen", false)',
        'not f.get("arc_jiyeon_verdict_seen", false)',
        "GameState.get_total_asset_value() < 500_000_000.0",
    ):
        if token not in verdict_block:
            raise ValueError(f"Jiyeon verdict chronology gate missing: {token}")


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
    validate_jiyeon_wedding_gap_contract(ko_events)
    validate_sangchul_confrontation_contract(ko_events)
    validate_father_hospital_contract(ko_events)
    validate_father_passing_contract(ko_events)
    validate_jiyeon_marriage_routing_contract()
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
