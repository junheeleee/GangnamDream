#!/usr/bin/env python3
"""Measure Tier-1 peak scenes by their actual StoryMode interaction paths."""

from __future__ import annotations

import argparse
import copy
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
GAME_STATE = os.path.join(ROOT, "autoloads", "GameState.gd")
ENDINGS_KO = os.path.join(ROOT, "content", "endings.json")
ENDINGS_EN = os.path.join(ROOT, "content", "endings_en.json")

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
    ("The Last Signature", "arc_final_countdown"),
    ("Three Claims in One Week", "arc_daeun_03_fork"),
    ("The Mirror and the Hospital Door", "arc_sangchul_mirror"),
)

MIN_LINKS = 2
MAX_LINKS = 4
MIN_DECISIONS = 2
MAX_DECISIONS = 3
MIN_DIALOGUE_TURNS = 2
# Ratchet updated only after a peak is expanded and its rendered QA passes.
BASELINE_DEBT = 0
REQUIRED_PASS = {
    "arc_daeun_first_night",
    "arc_daeun_wedding_night",
    "arc_jiyeon_wedding_night",
    "arc_daeun_first_kiss",
    "arc_jiyeon_first_kiss",
    "arc_daeun_hometown_2",
    "arc_jiyeon_narrow_room_2",
    "arc_date_namsan_daeun",
    "arc_date_namsan_jiyeon",
    "arc_daeun_proposal",
    "arc_daeun_wedding_day",
    "arc_jiyeon_wedding_gap",
    "arc_jiyeon_verdict",
    "arc_daeun_final_choice",
    "arc_sangchul_01_meet",
    "arc_sangchul_deduction",
    "arc_sangchul_confrontation",
    "arc_sangchul_casino_invite",
    "father_hospital_wait",
    "arc_father_passing",
    "arc_father_call_on_ktx",
    "hyunsu_reunion_later",
    "arc_jaehyuk_04a_ghost",
    "arc_jaehyuk_mirror",
    "arc_final_countdown",
    "arc_daeun_03_fork",
    "arc_sangchul_mirror",
    "arc_season_sea_daeun",
    "arc_season_sea_jiyeon",
    "arc_season_fireworks_daeun",
    "arc_season_fireworks_jiyeon",
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


def validate_distributed_relationship_bill(
    ko_events: dict[str, dict[str, Any]],
    en_events: dict[str, dict[str, Any]],
) -> dict[str, int]:
    """Keep the protected W157 consequence without faking one immediate chain.

    `arc_36_trust_crack` used to pass the immediate-peak metric only because it
    jumped straight into M40. M40 is now a separate protected week whose target
    depends on M39 receipts, so it belongs to the causal-spine audit rather than
    `walk_paths()`. This contract prevents that honest separation from becoming
    an excuse to lose the consequence or locale parity.
    """
    trust = ko_events.get("arc_36_trust_crack", {})
    trust_choices = trust.get("choices", [])
    if len(trust_choices) != 3:
        raise ValueError("distributed relationship bill lost its trust decision")
    immediate_bypass = sum(
        1
        for choice in trust_choices
        if str(choice.get("follow_up_event", "")).strip()
    )
    if immediate_bypass:
        raise ValueError("distributed relationship bill bypasses protected W157")
    route_contracts = (
        (
            "missed_father and missed_person",
            "arc_36_unexpected_hand",
        ),
        (
            "missed_father and missed_deal",
            "arc_36_unexpected_hand_father_deal",
        ),
        (
            "missed_person and missed_deal",
            "arc_36_unexpected_hand_person_deal",
        ),
    )
    m40_ids = tuple(event_id for _, event_id in route_contracts)
    locale_variants = 0
    for event_id in ("arc_36_trust_crack", *m40_ids):
        ko_event = ko_events.get(event_id, {})
        en_event = en_events.get(event_id, {})
        if (
            not ko_event
            or not en_event
            or len(ko_event.get("choices", []))
            != len(en_event.get("choices", []))
        ):
            raise ValueError(
                f"distributed relationship bill locale drift: {event_id}"
            )
        if event_id in m40_ids:
            locale_variants += 1

    with open(MAIN_GAME, encoding="utf-8") as handle:
        source = handle.read()

    def gdscript_function(name: str) -> str:
        start_match = re.search(rf"(?m)^func {re.escape(name)}\(", source)
        if start_match is None:
            raise ValueError(f"distributed relationship bill lost {name}()")
        end_match = re.search(r"(?m)^func ", source[start_match.end():])
        end = len(source) if end_match is None else start_match.end() + end_match.start()
        return source[start_match.start():end]

    causal_router = gdscript_function("_chapter_four_causal_arc_id")
    full_router = gdscript_function("_next_arc_id")
    w157_start = causal_router.find("\tif t == 157")
    w157_end = causal_router.find("\n\tif t == 161", w157_start)
    if w157_start < 0 or w157_end < 0:
        raise ValueError("distributed relationship bill lost its exact W157 block")
    w157_block = causal_router[w157_start:w157_end]

    week_match = re.search(r"\bif t == (\d+) and f\.get\(\n?\s*"
                           r'"arc_y4_three_promises_seen"', w157_block)
    if week_match is None:
        raise ValueError("distributed relationship bill is not gated by the M39 receipt")
    consequence_week = int(week_match.group(1))
    for token in (
        'not f.get("arc_36_unexpected_hand_seen", false)',
        'f.get("arc_y4_three_promises_missed_father", false)',
        'f.get("arc_y4_three_promises_missed_person", false)',
        'f.get("arc_y4_three_promises_missed_deal", false)',
        "int(missed_father) + int(missed_person) + int(missed_deal) != 2",
        "if father_is_passed and missed_father:",
    ):
        if token not in w157_block:
            raise ValueError(f"distributed W157 receipt contract missing: {token}")
    if len(re.findall(r'(?m)^\s*return ""$', w157_block)) < 2:
        raise ValueError("distributed W157 damaged/deceased receipts do not fail closed")

    routed_pairs = 0
    for condition, event_id in route_contracts:
        if event_id == "arc_36_unexpected_hand":
            # The father/person pair is the only remaining exact pair after the
            # two named pair branches. Its base return must stay inside W157.
            branch_pattern = rf'(?m)^\s*return "{re.escape(event_id)}"$'
        else:
            branch_pattern = (
                rf"if {re.escape(condition)}:\s*\n\s*"
                rf'return "{re.escape(event_id)}"'
            )
        if re.search(branch_pattern, w157_block) is None:
            raise ValueError(
                f"distributed W157 pair lost {condition} -> {event_id}"
            )
        routed_pairs += 1

    causal_call = full_router.find("_chapter_four_causal_arc_id(")
    if causal_call < 0:
        raise ValueError("distributed W157 router is not called by the full router")
    if 'return "arc_36_unexpected_hand"' in full_router:
        raise ValueError(
            "receiptless save can invent the father/person M40 base variant"
        )

    father_active_guards = 0
    for week, next_week in ((153, 157), (167, 169), (181, 185)):
        start = causal_router.find(f"\tif t == {week}")
        end = causal_router.find(f"\n\tif t == {next_week}", start)
        if start < 0 or end < 0 or "not father_is_passed" not in causal_router[start:end]:
            raise ValueError(f"terminal Father evidence can reopen W{week}")
        father_active_guards += 1

    return {
        "consequence_week": consequence_week,
        "variants": locale_variants,
        "target_pairs": routed_pairs,
        "immediate_bypass": immediate_bypass,
        "legacy_fallback": 0,
        "father_active_guards": father_active_guards,
    }


def validate_season_peak_contracts(events: dict[str, dict[str, Any]]) -> None:
    """Keep travel/firework preludes state-free and preserve each terminal choice."""
    contracts = (
        {
            "label": "Daeun sea",
            "root": "arc_season_sea_daeun",
            "branches": ("arc_season_sea_daeun_years", "arc_season_sea_daeun_horizon"),
            "final": "arc_season_sea_daeun_decision",
            "background": "ktx_window",
            "portrait": "daeun_sea",
            "cg": "cg_romance_sea_daeun",
            "actor": "daeun",
            "texts": ('"내년엔 1박으로 와요."', "말없이 손을 끌고 파도 앞까지 같이 뛴다."),
            "effects": (
                {"money": -45_000, "mental": 8, "tint": 2},
                {"money": -45_000, "mental": 10, "tint": 1},
            ),
            "affinity": (8, 5),
            "flags": (["daeun_sea_5years"], ["daeun_sea_5years"]),
            "effect": None,
        },
        {
            "label": "Jiyeon sea",
            "root": "arc_season_sea_jiyeon",
            "branches": ("arc_season_sea_jiyeon_voice", "arc_season_sea_jiyeon_route"),
            "final": "arc_season_sea_jiyeon_decision",
            "background": "ktx_window",
            "portrait": "jiyeon_sea",
            "cg": "cg_romance_sea_jiyeon",
            "actor": "jiyeon",
            "texts": ("웃는다 — 참으려다 실패한다.", '"그럼 내가 잡고 있을게요. 무릎까지만."'),
            "effects": (
                {"money": -60_000, "mental": 6, "tint": 1},
                {"money": -60_000, "mental": 8, "tint": 2},
            ),
            "affinity": (4, 8),
            "flags": (["jiyeon_cant_swim"], ["jiyeon_cant_swim"]),
            "effect": None,
        },
        {
            "label": "Daeun fireworks",
            "root": "arc_season_fireworks_daeun",
            "branches": (
                "arc_season_fireworks_daeun_dress",
                "arc_season_fireworks_daeun_river",
            ),
            "final": "arc_season_fireworks_daeun_decision",
            "background": "hangang_riverside",
            "portrait": "daeun_fireworks",
            "cg": "cg_romance_fireworks_daeun",
            "actor": "daeun",
            "texts": (
                '"예뻐요." — 3초를 넘기기 전에.',
                "불꽃이 터지는 순간, 하늘 대신 옆얼굴을 본다.",
                "인파에 밀리기 전에 손을 잡는다.",
            ),
            "effects": (
                {"mental": 6, "tint": 2},
                {"mental": 8, "tint": 2},
                {"mental": 5, "tint": 1},
            ),
            "affinity": (8, 6, 5),
            "flags": (None, None, None),
            "effect": "fireworks",
        },
        {
            "label": "Jiyeon fireworks",
            "root": "arc_season_fireworks_jiyeon",
            "branches": (
                "arc_season_fireworks_jiyeon_schedule",
                "arc_season_fireworks_jiyeon_pace",
            ),
            "final": "arc_season_fireworks_jiyeon_decision",
            "background": "hangang_riverside",
            "portrait": "jiyeon_fireworks",
            "cg": "cg_romance_fireworks_jiyeon",
            "actor": "jiyeon",
            "texts": (
                "잡힌 손을 깍지로 고쳐 잡는다.",
                '"이쪽 모습이 더 좋은데요."',
                "불꽃이 터지는 순간, 하늘 대신 옆얼굴을 본다.",
            ),
            "effects": (
                {"mental": 6, "tint": 2},
                {"mental": 5, "tint": 1},
                {"mental": 8, "tint": 2},
            ),
            "affinity": (8, 6, 6),
            "flags": (None, None, None),
            "effect": "fireworks",
        },
    )

    for contract in contracts:
        root_id = str(contract["root"])
        branches = tuple(str(value) for value in contract["branches"])
        final_id = str(contract["final"])
        expected_paths = {(root_id, branch_id, final_id) for branch_id in branches}
        actual_paths = {path.event_ids for path in walk_paths(events, root_id)}
        if actual_paths != expected_paths:
            raise ValueError(
                f"{contract['label']} paths changed: "
                f"actual={sorted(actual_paths)!r} expected={sorted(expected_paths)!r}"
            )

        for event_id in (root_id, *branches):
            event = events[event_id]
            if event.get("background") != contract["background"] \
                    or event.get("portrait") != contract["portrait"] \
                    or event.get("cg"):
                raise ValueError(f"{contract['label']} buildup visual changed at {event_id}")
            if contract["effect"] == "fireworks" \
                    and (event.get("living_scene") or {}).get("effect") != "none":
                raise ValueError(f"{contract['label']} ignites fireworks before the final link")
            for choice_index, choice in enumerate(event.get("choices") or []):
                for forbidden in (
                    "effects", "flags", "cast_effects", "result_cg", "result_background"
                ):
                    if choice.get(forbidden):
                        raise ValueError(
                            f"{contract['label']} buildup {event_id}[{choice_index}] "
                            f"commits {forbidden} before the terminal scene"
                        )

        final = events[final_id]
        if final.get("background") != contract["background"] \
                or final.get("portrait") != contract["portrait"] \
                or final.get("cg") != contract["cg"]:
            raise ValueError(f"{contract['label']} final visual changed")
        if contract["effect"] == "fireworks":
            if (final.get("living_scene") or {}).get("effect") != "fireworks" \
                    or final.get("cg_reveal_paragraph") != 2:
                raise ValueError(f"{contract['label']} final firework timing changed")

        choices = final.get("choices") or []
        if len(choices) != len(contract["texts"]):
            raise ValueError(f"{contract['label']} terminal choice count changed")
        for index, choice in enumerate(choices):
            expected_cast = {str(contract["actor"]): {"affinity": contract["affinity"][index]}}
            if choice.get("text") != contract["texts"][index] \
                    or choice.get("effects") != contract["effects"][index] \
                    or choice.get("cast_effects") != expected_cast \
                    or choice.get("flags") != contract["flags"][index]:
                raise ValueError(f"{contract['label']} final choice {index} changed")


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


def validate_jaehyuk_contracts(events: dict[str, dict[str, Any]]) -> None:
    """Keep Jaehyuk's fraud and guarantee mirrors staged without moving their costs."""
    ghost_root = "arc_jaehyuk_04a_ghost"
    ghost_branches = ("arc_jaehyuk_ghost_read", "arc_jaehyuk_ghost_message")
    ghost_final = "arc_jaehyuk_ghost_decision"
    ghost_photo = "arc_jaehyuk_photo_in_dark"
    expected_ghost_paths = {
        (ghost_root, branch, ghost_final)
        for branch in ghost_branches
    } | {
        (ghost_root, branch, ghost_final, ghost_photo)
        for branch in ghost_branches
    }
    actual_ghost_paths = {path.event_ids for path in walk_paths(events, ghost_root)}
    if actual_ghost_paths != expected_ghost_paths:
        raise ValueError(
            "Jaehyuk ghost paths changed: "
            f"actual={sorted(actual_ghost_paths)!r} expected={sorted(expected_ghost_paths)!r}"
        )

    pitch = events["arc_jaehyuk_03_pitch"]
    if pitch.get("cg") != "cg_jaehyuk_reveal":
        raise ValueError("Jaehyuk table CG must belong to the hotel-lounge pitch")
    pitch_all_in = (pitch.get("choices") or [])[0]
    pitch_copy = f"{pitch_all_in.get('text', '')}\n{pitch_all_in.get('result_text', '')}"
    if "거의 전부" in pitch_copy or pitch_all_in.get("effects", {}).get("money") != -3_000_000:
        raise ValueError("Jaehyuk pitch must state the fixed KRW 3M stake without an all-assets claim")
    if events[ghost_root].get("cg"):
        raise ValueError("Jaehyuk ghost must not show an in-person table CG")

    for event_id in (ghost_root, *ghost_branches):
        event = events[event_id]
        if event.get("background") != "current_housing" \
                or event.get("portrait") != "player_shocked" \
                or event.get("cg"):
            raise ValueError(f"Jaehyuk ghost buildup visual changed at {event_id}")
        for choice_index, choice in enumerate(event.get("choices") or []):
            for forbidden in ("effects", "flags", "cast_effects", "requires_item"):
                if choice.get(forbidden):
                    raise ValueError(
                        f"Jaehyuk ghost buildup {event_id}[{choice_index}] "
                        f"commits {forbidden} before the terminal scene"
                    )

    ghost_event = events[ghost_final]
    if ghost_event.get("background") != "current_housing" \
            or ghost_event.get("portrait") != "player_shocked" \
            or ghost_event.get("cg"):
        raise ValueError("Jaehyuk ghost final visual changed")
    ghost_choices = ghost_event.get("choices") or []
    expected_ghost_choices = (
        {
            "text": "며칠을 방에 누워만 있었다",
            "effects": {"mental": -35, "health": -8},
            "cast_effects": {"jaehyuk": {"affinity": -100, "stage": "betrayed"}},
            "flags": ["arc_jaehyuk_ghost_seen", "jaehyuk_scammed", "hit_rock_bottom"],
        },
        {
            "text": "카페에 가입하고 글을 남겼다. '저도 당했습니다.'",
            "effects": {"mental": -20, "intelligence": 4, "tint": 5},
            "cast_effects": {"jaehyuk": {"affinity": -100, "stage": "betrayed"}},
            "flags": ["arc_jaehyuk_ghost_seen", "jaehyuk_scammed", "joined_victims"],
        },
        {
            "text": "(주머니 속… 그날의 사진이 생각났다)",
            "requires_item": "artifact_jaehyuk_photo",
            "effects": {"mental": -18, "tint": 3},
            "cast_effects": {"jaehyuk": {"affinity": -100, "stage": "betrayed"}},
            "flags": [
                "arc_jaehyuk_ghost_seen",
                "jaehyuk_scammed",
                "presented_artifact_correct",
            ],
            "follow_up_event": ghost_photo,
        },
    )
    if len(ghost_choices) != len(expected_ghost_choices):
        raise ValueError("Jaehyuk ghost final must retain three choices")
    for choice_index, contract in enumerate(expected_ghost_choices):
        choice = ghost_choices[choice_index]
        for key, value in contract.items():
            if choice.get(key) != value:
                raise ValueError(
                    f"Jaehyuk ghost final choice {choice_index} changed {key}: "
                    f"{choice.get(key)!r}!={value!r}"
                )

    for event_id in (ghost_photo, "arc_jaehyuk_aftermath"):
        if events[event_id].get("background") != "current_housing":
            raise ValueError(f"Jaehyuk aftermath returned to a fixed goshiwon: {event_id}")

    mirror_root = "arc_jaehyuk_mirror"
    mirror_branches = ("arc_jaehyuk_mirror_reply", "arc_jaehyuk_mirror_father")
    mirror_final = "arc_jaehyuk_mirror_decision"
    expected_mirror_paths = {
        (mirror_root, branch, mirror_final) for branch in mirror_branches
    }
    actual_mirror_paths = {path.event_ids for path in walk_paths(events, mirror_root)}
    if actual_mirror_paths != expected_mirror_paths:
        raise ValueError(
            "Jaehyuk mirror paths changed: "
            f"actual={sorted(actual_mirror_paths)!r} expected={sorted(expected_mirror_paths)!r}"
        )
    for event_id in (mirror_root, *mirror_branches):
        event = events[event_id]
        if event.get("background") != "current_housing" \
                or event.get("portrait") != "player_normal" \
                or event.get("cg"):
            raise ValueError(f"Jaehyuk mirror buildup visual changed at {event_id}")
        if event.get("timed") or event.get("timer_seconds"):
            raise ValueError(f"Jaehyuk mirror timer started before the final decision at {event_id}")
        for choice_index, choice in enumerate(event.get("choices") or []):
            for forbidden in ("effects", "flags", "cast_effects"):
                if choice.get(forbidden):
                    raise ValueError(
                        f"Jaehyuk mirror buildup {event_id}[{choice_index}] "
                        f"commits {forbidden} before the terminal scene"
                    )

    mirror_event = events[mirror_final]
    if mirror_event.get("background") != "current_housing" \
            or mirror_event.get("portrait") != "player_normal" \
            or mirror_event.get("cg") \
            or mirror_event.get("timed") is not True \
            or mirror_event.get("timer_seconds") != 10:
        raise ValueError("Jaehyuk mirror final visual or ten-second timer changed")
    mirror_choices = mirror_event.get("choices") or []
    expected_mirror_choices = (
        {
            "text": '"못 해." (단호하게 거절했다)',
            "effects": {"mental": -8, "tint": 7},
            "flags": ["arc_jaehyuk_mirror_seen", "refused_jaehyuk_guarantee"],
        },
        {
            "text": '"얼마짜리야?" (들어보기로 했다)',
            "effects": {"mental": -15, "tint": -6},
            "flags": [
                "arc_jaehyuk_mirror_seen",
                "vouched_jaehyuk_guarantee",
                "jaehyuk_exploited",
                "crossed_line",
            ],
            "foreshadow": "그의 방식이 틀리지 않을 수도 있었다. 강남에는 이런 사람들이 필요하다고, 스스로를 설득했다.",
        },
        {
            "text": "(읽지 않은 척 메시지를 닫았다)",
            "effects": {"mental": -5, "tint": -2},
            "flags": ["arc_jaehyuk_mirror_seen", "blocked_jaehyuk_guarantee"],
        },
    )
    if len(mirror_choices) != len(expected_mirror_choices):
        raise ValueError("Jaehyuk mirror final must retain three choices")
    for choice_index, contract in enumerate(expected_mirror_choices):
        choice = mirror_choices[choice_index]
        for key, value in contract.items():
            if choice.get(key) != value:
                raise ValueError(
                    f"Jaehyuk mirror final choice {choice_index} changed {key}: "
                    f"{choice.get(key)!r}!={value!r}"
                )


def validate_first_kiss_contracts(events: dict[str, dict[str, Any]]) -> None:
    """Keep buildup expressive while the canonical kiss choice owns every effect."""
    contracts = (
        {
            "label": "Daeun",
            "root": "arc_daeun_first_kiss",
            "branches": ("arc_daeun_first_kiss_wait", "arc_daeun_first_kiss_ask"),
            "final": "arc_daeun_first_kiss_choice",
            "background": "convenience_night",
            "portrait": "daeun_smile",
            "cg": "cg_romance_first_kiss_daeun",
            "flag": "arc_daeun_first_kiss_seen",
            "actor": "daeun",
            "texts": (
                "그 정적 속에서, 먼저 다가간다.",
                "캔커피를 쥐여주고, 오늘은 여기까지.",
            ),
        },
        {
            "label": "Jiyeon",
            "root": "arc_jiyeon_first_kiss",
            "branches": ("arc_jiyeon_first_kiss_silence", "arc_jiyeon_first_kiss_speak"),
            "final": "arc_jiyeon_first_kiss_choice",
            "background": "jiyeon_sedan_night",
            "portrait": "jiyeon_warm",
            "cg": "cg_romance_first_kiss_jiyeon",
            "flag": "arc_jiyeon_first_kiss_seen",
            "actor": "jiyeon",
            "texts": (
                "그 0.5초에, 다가간다.",
                "웃고 만다 — \"아무것도.\"",
            ),
        },
    )
    expected_effects = (
        {"mental": 10, "tint": 2},
        {"mental": 4, "tint": 1},
    )
    expected_affinity = (12, 4)

    for contract in contracts:
        root_id = str(contract["root"])
        branches = tuple(str(event_id) for event_id in contract["branches"])
        final_id = str(contract["final"])
        paths = walk_paths(events, root_id)
        expected_paths = {(root_id, branch_id, final_id) for branch_id in branches}
        actual_paths = {path.event_ids for path in paths}
        if actual_paths != expected_paths:
            rendered = ", ".join(" -> ".join(path) for path in sorted(actual_paths))
            raise ValueError(f"{contract['label']} first-kiss paths changed: {rendered}")

        for event_id in (root_id, *branches):
            event = events[event_id]
            if event.get("background") != contract["background"] \
                    or event.get("portrait") != contract["portrait"]:
                raise ValueError(f"{contract['label']} first-kiss buildup visual changed at {event_id}")
            if event.get("cg"):
                raise ValueError(f"{contract['label']} first-kiss CG revealed before the decision")
            for choice in event.get("choices") or []:
                for forbidden in ("effects", "flags", "cast_effects", "result_cg", "result_background"):
                    if choice.get(forbidden):
                        raise ValueError(
                            f"{contract['label']} first-kiss buildup applies {forbidden} at {event_id}"
                        )

        final_event = events[final_id]
        if final_event.get("background") != contract["background"] \
                or final_event.get("portrait") != contract["portrait"] \
                or final_event.get("cg") != contract["cg"]:
            raise ValueError(f"{contract['label']} first-kiss decision visual changed")
        final_choices = final_event.get("choices") or []
        if len(final_choices) != 2:
            raise ValueError(f"{contract['label']} first-kiss decision must retain two choices")
        for index, choice in enumerate(final_choices):
            expected_cast = {str(contract["actor"]): {"affinity": expected_affinity[index]}}
            expected_flag = [str(contract["flag"])]
            if choice.get("text") != contract["texts"][index] \
                    or choice.get("effects") != expected_effects[index] \
                    or choice.get("flags") != expected_flag \
                    or choice.get("cast_effects") != expected_cast:
                raise ValueError(f"{contract['label']} first-kiss final choice {index} changed")

    jiyeon_result = str(events["arc_jiyeon_first_kiss_choice"]["choices"][0].get("result_text", ""))
    if "{name}이 시동" in jiyeon_result or "운전이나 해" in jiyeon_result:
        raise ValueError("Jiyeon first-kiss result put the passenger in the driver role")


def validate_daeun_first_night_contract(events: dict[str, dict[str, Any]]) -> None:
    """Keep the lived housing and outfit stable until the canonical final choice."""
    root_id = "arc_daeun_first_night"
    branches = (
        "arc_daeun_first_night_silence",
        "arc_daeun_first_night_truth",
    )
    final_id = "arc_daeun_first_night_decision"
    expected_paths = {(root_id, branch_id, final_id) for branch_id in branches}
    actual_paths = {path.event_ids for path in walk_paths(events, root_id)}
    if actual_paths != expected_paths:
        rendered = ", ".join(" -> ".join(path) for path in sorted(actual_paths))
        raise ValueError(f"Daeun first-night paths changed: {rendered}")

    expected_portraits = {
        root_id: "daeun_normal",
        branches[0]: "daeun_normal",
        branches[1]: "daeun_sad",
    }
    for event_id, portrait_id in expected_portraits.items():
        event = events[event_id]
        if event.get("background") != "current_housing" \
                or event.get("portrait") != portrait_id \
                or event.get("cg"):
            raise ValueError(f"Daeun first-night buildup visual changed at {event_id}")
        if (event.get("living_scene") or {}).get("effect") != "city_light":
            raise ValueError(f"Daeun first-night indoor light profile changed at {event_id}")
        for choice in event.get("choices") or []:
            for forbidden in (
                    "effects", "flags", "cast_effects", "result_cg", "result_background"):
                if choice.get(forbidden):
                    raise ValueError(
                        f"Daeun first-night buildup applies {forbidden} at {event_id}"
                    )

    final_event = events[final_id]
    if final_event.get("background") != "current_housing" \
            or final_event.get("portrait") != "daeun_smile" \
            or final_event.get("cg") \
            or (final_event.get("living_scene") or {}).get("effect") != "city_light":
        raise ValueError("Daeun first-night decision visual changed")
    expected_choices = (
        {
            "text": "떨리는 그 손을 마주 잡는다.",
            "effects": {"mental": 14, "tint": 3},
            "flags": ["arc_daeun_first_night_seen", "daeun_first_night"],
            "cast_effects": {"daeun": {"affinity": 18, "stage": "lover"}},
        },
        {
            "text": '"...오늘은 그냥 옆에 있어요." (다은을 안고 잠든다)',
            "effects": {"mental": 10, "tint": 5},
            "flags": ["arc_daeun_first_night_seen"],
            "cast_effects": {"daeun": {"affinity": 14}},
        },
    )
    final_choices = final_event.get("choices") or []
    if len(final_choices) != len(expected_choices):
        raise ValueError("Daeun first-night decision must retain two choices")
    for choice_index, contract in enumerate(expected_choices):
        choice = final_choices[choice_index]
        for key, value in contract.items():
            if choice.get(key) != value:
                raise ValueError(
                    f"Daeun first-night final choice {choice_index} changed {key}"
                )
        result = str(choice.get("result_text", ""))
        if "좁은 침대" in result or "가진 게 이 방 하나뿐" in result:
            raise ValueError("Daeun first-night result assumes the player still lives in a goshiwon")


def validate_wedding_night_contracts(events: dict[str, dict[str, Any]]) -> None:
    """Keep every buildup state-free and reveal the morning only after the fade."""
    contracts = (
        {
            "label": "Daeun",
            "root": "arc_daeun_wedding_night",
            "branches": (
                "arc_daeun_wedding_night_tea",
                "arc_daeun_wedding_night_honest",
            ),
            "final": "arc_daeun_wedding_night_choice",
            "background": "daeun_newlywed_home",
            "portrait": "daeun_wedding_night",
            "cg": "cg_romance_wedding_morning_daeun",
            "flag": "arc_daeun_wedding_night_seen",
            "actor": "daeun",
            "texts": (
                '그 손을 잡고, "천천히 해도 돼요. 저도… 떨려요."',
                '긴장한 그녀를 웃게 한다. "그럼 나도 처음인 걸로 할게요."',
            ),
        },
        {
            "label": "Jiyeon",
            "root": "arc_jiyeon_wedding_night",
            "branches": (
                "arc_jiyeon_wedding_night_window",
                "arc_jiyeon_wedding_night_glass",
            ),
            "final": "arc_jiyeon_wedding_night_choice",
            "background": "jiyeon_newlywed_home",
            "portrait": "jiyeon_wedding_night",
            "cg": "cg_romance_wedding_morning_jiyeon",
            "flag": "arc_jiyeon_wedding_night_seen",
            "actor": "jiyeon",
            "texts": (
                "그 침묵을 존중하고, 먼저 손을 내민다.",
                '긴장을 들킨 그녀를 살짝 놀린다. "천하의 한지연이 말이 없네요."',
            ),
        },
    )
    expected_effects = (
        {"mental": 8, "tint": 4},
        {"mental": 6, "tint": 3},
    )
    expected_affinity = (8, 6)

    for contract in contracts:
        root_id = str(contract["root"])
        branches = tuple(str(event_id) for event_id in contract["branches"])
        final_id = str(contract["final"])
        expected_paths = {(root_id, branch_id, final_id) for branch_id in branches}
        actual_paths = {path.event_ids for path in walk_paths(events, root_id)}
        if actual_paths != expected_paths:
            rendered = ", ".join(" -> ".join(path) for path in sorted(actual_paths))
            raise ValueError(f"{contract['label']} wedding-night paths changed: {rendered}")

        for event_id in (root_id, *branches):
            event = events[event_id]
            if event.get("background") != contract["background"] \
                    or event.get("portrait") != contract["portrait"]:
                raise ValueError(f"{contract['label']} wedding-night visual changed at {event_id}")
            if event.get("cg") or event.get("result_cg"):
                raise ValueError(f"{contract['label']} wedding morning revealed before the final choice")
            for choice in event.get("choices") or []:
                for forbidden in (
                    "effects", "flags", "cast_effects", "result_cg", "result_background"
                ):
                    if choice.get(forbidden):
                        raise ValueError(
                            f"{contract['label']} wedding-night buildup applies "
                            f"{forbidden} at {event_id}"
                        )

        final_event = events[final_id]
        if final_event.get("background") != contract["background"] \
                or final_event.get("portrait") != contract["portrait"] \
                or final_event.get("result_cg") != contract["cg"] \
                or final_event.get("result_cg_reveal_paragraph") != 1:
            raise ValueError(f"{contract['label']} wedding-night final visual changed")
        final_choices = final_event.get("choices") or []
        if len(final_choices) != 2:
            raise ValueError(f"{contract['label']} wedding-night final must retain two choices")
        for index, choice in enumerate(final_choices):
            expected_cast = {str(contract["actor"]): {"affinity": expected_affinity[index]}}
            if choice.get("text") != contract["texts"][index] \
                    or choice.get("effects") != expected_effects[index] \
                    or choice.get("flags") != [str(contract["flag"])] \
                    or choice.get("cast_effects") != expected_cast:
                raise ValueError(
                    f"{contract['label']} wedding-night final choice {index} changed"
                )
            result_text = str(choice.get("result_text", ""))
            if paragraph_count(result_text) != 3 or "다음 날 아침" not in result_text:
                raise ValueError(
                    f"{contract['label']} wedding-night choice {index} lost the night/morning split"
                )


def validate_home_peak_contracts(events: dict[str, dict[str, Any]]) -> None:
    """Keep the two home peaks state-free until their original terminal choices."""
    contracts = (
        {
            "label": "Daeun hometown table",
            "root": "arc_daeun_hometown_2",
            "branches": (
                "arc_daeun_hometown_table_hands",
                "arc_daeun_hometown_table_daughter",
            ),
            "final": "arc_daeun_hometown_table_decision",
            "background": "daeun_mother_home_dining",
            "portrait": "daeun_hometown_warm",
            "cg": "cg_romance_hometown_night_bus_daeun",
            "cg_mode": "result",
            "actor": "daeun",
            "texts": (
                '"잘 먹겠습니다, 어머니." 밥그릇을 정성껏 비운다.',
                '"…다은씨가 해주던 계란말이가, 어머니 거였네요."',
            ),
            "effects": (
                {"mental": 10, "tint": 4},
                {"mental": 8, "tint": 5},
            ),
            "affinity": (8, 10),
            "flags": ["arc_daeun_hometown_2_seen", "daeun_hometown_visited"],
        },
        {
            "label": "Jiyeon narrow room",
            "root": "arc_jiyeon_narrow_room_2",
            "branches": (
                "arc_jiyeon_narrow_room_silence",
                "arc_jiyeon_narrow_room_truth",
            ),
            "final": "arc_jiyeon_narrow_room_decision",
            "background": "goshiwon_room",
            "portrait": "jiyeon_narrow_room",
            "cg": "cg_romance_narrow_room_jiyeon",
            "cg_mode": "continuous",
            "actor": "jiyeon",
            "texts": (
                "말없이, 그녀를 안아준다.",
                "말없이, 라면을 마저 끓여 앞에 놓는다.",
            ),
            "effects": (
                {"mental": 8, "tint": 4},
                {"mental": 6, "tint": 3},
            ),
            "affinity": (10, 8),
            "flags": ["arc_jiyeon_narrow_room_2_seen", "jiyeon_narrow_room"],
        },
    )

    for contract in contracts:
        root_id = str(contract["root"])
        branches = tuple(str(event_id) for event_id in contract["branches"])
        final_id = str(contract["final"])
        expected_paths = {(root_id, branch_id, final_id) for branch_id in branches}
        actual_paths = {path.event_ids for path in walk_paths(events, root_id)}
        if actual_paths != expected_paths:
            rendered = ", ".join(" -> ".join(path) for path in sorted(actual_paths))
            raise ValueError(f"{contract['label']} paths changed: {rendered}")

        for event_id in (root_id, *branches):
            event = events[event_id]
            if event.get("background") != contract["background"] \
                    or event.get("portrait") != contract["portrait"]:
                raise ValueError(f"{contract['label']} visual changed at {event_id}")
            if contract["cg_mode"] == "result" and (event.get("cg") or event.get("result_cg")):
                raise ValueError(f"{contract['label']} return-bus CG appeared before the final result")
            if contract["cg_mode"] == "continuous" and event.get("cg") != contract["cg"]:
                raise ValueError(f"{contract['label']} lost CG continuity at {event_id}")
            for choice in event.get("choices") or []:
                for forbidden in (
                    "effects", "flags", "cast_effects", "result_cg", "result_background"
                ):
                    if choice.get(forbidden):
                        raise ValueError(
                            f"{contract['label']} buildup applies {forbidden} at {event_id}"
                        )

        final_event = events[final_id]
        if final_event.get("background") != contract["background"] \
                or final_event.get("portrait") != contract["portrait"]:
            raise ValueError(f"{contract['label']} final visual changed")
        if contract["cg_mode"] == "result":
            if final_event.get("result_cg") != contract["cg"] \
                    or final_event.get("result_cg_reveal_paragraph") != 1 \
                    or final_event.get("cg"):
                raise ValueError(f"{contract['label']} final result CG timing changed")
        elif final_event.get("cg") != contract["cg"] or final_event.get("result_cg"):
            raise ValueError(f"{contract['label']} final continuous CG changed")

        final_choices = final_event.get("choices") or []
        if len(final_choices) != 2:
            raise ValueError(f"{contract['label']} final must retain two choices")
        for index, choice in enumerate(final_choices):
            expected_cast = {
                str(contract["actor"]): {"affinity": contract["affinity"][index]}
            }
            if choice.get("text") != contract["texts"][index] \
                    or choice.get("effects") != contract["effects"][index] \
                    or choice.get("flags") != contract["flags"] \
                    or choice.get("cast_effects") != expected_cast:
                raise ValueError(f"{contract['label']} final choice {index} changed")


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
        "hyunsu_reconnected": "cg_romance_wedding_daeun_father_reaction_hyunsu",
    }
    if groom_side.get("cg") != "cg_romance_wedding_daeun_father_reaction":
        raise ValueError("Daeun wedding groom-side reaction CG changed")
    if list((groom_side.get("cg_if_known") or {}).items()) != list(
            groom_side_cg_if_known.items()):
        raise ValueError("Daeun wedding groom-side state map or precedence changed")
    passed_groom_side = events.get(
        "arc_daeun_wedding_groom_side_father_passed", {})
    passed_cg_if_known = {
        "hyunsu_reconnected":
            "cg_romance_wedding_daeun_father_reaction_passed_hyunsu",
    }
    if passed_groom_side.get("cg") \
            != "cg_romance_wedding_daeun_father_reaction_passed":
        raise ValueError("Daeun wedding passed groom-side reaction CG changed")
    if list((passed_groom_side.get("cg_if_known") or {}).items()) != list(
            passed_cg_if_known.items()):
        raise ValueError(
            "Daeun wedding passed groom-side state map or precedence changed")
    if passed_groom_side.get("choices") != groom_side.get("choices"):
        raise ValueError(
            "Daeun wedding passed groom-side changed choice mechanics or aisle edge")

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


def validate_sangchul_first_meeting_contract(events: dict[str, dict[str, Any]]) -> None:
    """Preserve the original three answers after a state-free first encounter."""
    root_id = "arc_sangchul_01_meet"
    measure_id = "arc_sangchul_01_measure"
    coffee_id = "arc_sangchul_01_coffee"
    final_id = "arc_sangchul_01_answer"
    expected_paths = {
        (root_id, measure_id, final_id),
        (root_id, coffee_id, final_id),
    }
    actual_paths = {path.event_ids for path in walk_paths(events, root_id)}
    if actual_paths != expected_paths:
        rendered = ", ".join(" -> ".join(path) for path in sorted(actual_paths))
        raise ValueError(f"Sangchul first-meeting paths changed: {rendered}")

    visual_contract = {
        root_id: ("realestate_office", "sangchul_normal"),
        measure_id: ("realestate_office", "sangchul_serious"),
        coffee_id: ("realestate_office", "sangchul_normal"),
        final_id: ("realestate_office", "sangchul_serious"),
    }
    for event_id, (background, portrait) in visual_contract.items():
        event = events[event_id]
        if event.get("background") != background or event.get("portrait") != portrait:
            raise ValueError(
                f"Sangchul first-meeting visual continuity changed at {event_id}"
            )

    root_choices = events[root_id].get("choices") or []
    if len(root_choices) != 2:
        raise ValueError("Sangchul first meeting must offer exactly two opening attitudes")
    expected_followups = [measure_id, coffee_id]
    buildup_choices = list(root_choices)
    for index, choice in enumerate(root_choices):
        if choice.get("follow_up_event") != expected_followups[index]:
            raise ValueError(f"Sangchul first-meeting opening choice {index} changed branch")
    for branch_id in (measure_id, coffee_id):
        choices = events[branch_id].get("choices") or []
        if len(choices) != 1 or choices[0].get("follow_up_event") != final_id:
            raise ValueError(f"{branch_id} must rejoin the final why question")
        buildup_choices.extend(choices)
    for index, choice in enumerate(buildup_choices):
        for forbidden in (
            "effects", "cast_effects", "flags", "give_items", "opportunity",
            "tendency", "route",
        ):
            if choice.get(forbidden):
                raise ValueError(
                    f"Sangchul first-meeting buildup choice {index} commits {forbidden} early"
                )

    final_choices = events[final_id].get("choices") or []
    expected_final = (
        {
            "text": '"아버지한테... 한 번은 보여드리고 싶어서요."',
            "effects": {"mental": 6, "intelligence": 3, "tint": 5},
            "cast_effects": {
                "sangchul": {
                    "met": True,
                    "affinity": 15,
                    "stage": "interested",
                    "flags": ["knows_dad_reason"],
                }
            },
            "flags": ["arc_sangchul_met_seen", "sangchul_met"],
            "give_items": ["artifact_sangchul_card"],
        },
        {
            "text": '"돈 있으면 다 강남 가고 싶지 않나요?"',
            "effects": {"intelligence": 4, "mental": -2},
            "cast_effects": {
                "sangchul": {"met": True, "affinity": 6, "stage": "watching"}
            },
            "flags": ["arc_sangchul_met_seen", "sangchul_met"],
            "give_items": ["artifact_sangchul_card"],
        },
        {
            "text": '"지는 게 싫어서요. 이 도시한테." (솔직하게 꺼냈다)',
            "effects": {"mental": 7, "intelligence": 2, "tint": 3},
            "cast_effects": {
                "sangchul": {"met": True, "affinity": 12, "stage": "interested"}
            },
            "flags": ["arc_sangchul_met_seen", "sangchul_met", "pride_motive"],
            "give_items": ["artifact_sangchul_card"],
        },
    )
    if len(final_choices) != len(expected_final):
        raise ValueError("Sangchul final why question must retain exactly three answers")
    for index, contract in enumerate(expected_final):
        choice = final_choices[index]
        if choice.get("follow_up_event"):
            raise ValueError(f"Sangchul final answer {index} must terminate the chain")
        for key, value in contract.items():
            if choice.get(key) != value:
                raise ValueError(
                    f"Sangchul final answer {index} changed {key}: "
                    f"{choice.get(key)!r}!={value!r}"
                )
    father_result = str(final_choices[0].get("result_text", ""))
    if "창원요." not in father_result or "반 박자 멈췄다" not in father_result:
        raise ValueError("Sangchul first meeting lost the Changwon recognition seed")


def validate_sangchul_deduction_contract(events: dict[str, dict[str, Any]]) -> None:
    """Make two evidence routes converge before the canonical timed judgment."""
    root_id = "arc_sangchul_deduction"
    case_id = "arc_sangchul_deduction_case"
    career_id = "arc_sangchul_deduction_career"
    final_id = "arc_sangchul_deduction_decision"
    expected_paths = {
        (root_id, case_id, final_id),
        (root_id, career_id, final_id),
    }
    actual_paths = {path.event_ids for path in walk_paths(events, root_id)}
    if actual_paths != expected_paths:
        raise ValueError(
            "Sangchul deduction paths changed: "
            f"actual={sorted(actual_paths)!r} expected={sorted(expected_paths)!r}"
        )

    expected_portraits = {
        root_id: "player_tired",
        case_id: "player_tired",
        career_id: "player_tired",
        final_id: "player_shocked",
    }
    for event_id, portrait in expected_portraits.items():
        event = events[event_id]
        if event.get("background") != "current_housing" \
                or event.get("portrait") != portrait or event.get("cg"):
            raise ValueError(f"Sangchul deduction visual continuity changed at {event_id}")

    root_choices = events[root_id].get("choices") or []
    if len(root_choices) != 2 or [choice.get("follow_up_event") for choice in root_choices] != [
        case_id,
        career_id,
    ]:
        raise ValueError("Sangchul deduction must open into the case and career evidence routes")
    buildup_choices = list(root_choices)
    for branch_id in (case_id, career_id):
        choices = events[branch_id].get("choices") or []
        if len(choices) != 1 or choices[0].get("follow_up_event") != final_id:
            raise ValueError(f"{branch_id} must rejoin the final deduction decision")
        buildup_choices.extend(choices)
    for index, choice in enumerate(buildup_choices):
        for forbidden in (
            "effects", "cast_effects", "flags", "clues", "give_items", "opportunity",
            "tendency", "route",
        ):
            if choice.get(forbidden):
                raise ValueError(
                    f"Sangchul deduction buildup choice {index} commits {forbidden} early"
                )

    final = events[final_id]
    if final.get("timed") is not True or final.get("timer_seconds") != 15:
        raise ValueError("Sangchul deduction judgment must retain its 15-second timer")
    expected_final = (
        {
            "text": "새벽 내내 뒤졌다. 등기, 옛 기사, 법인 이력",
            "effects": {
                "mental": -12,
                "intelligence": 2,
                "investment_skill": 1,
                "tint": 3,
            },
            "flags": [
                "arc_sangchul_deduction_seen",
                "sangchul_truth_known",
                "deduced_sangchul_truth",
            ],
            "clues": ["clue_father_broker"],
        },
        {
            "text": "노트북을 닫았다. 기사 하나로 사람을 단정할 순 없다",
            "effects": {"mental": -4, "tint": 2},
            "flags": ["arc_sangchul_deduction_seen", "sangchul_clue_noted"],
            "clues": ["clue_father_broker"],
        },
    )
    final_choices = final.get("choices") or []
    if len(final_choices) != len(expected_final):
        raise ValueError("Sangchul deduction final must retain exactly two judgments")
    for index, contract in enumerate(expected_final):
        choice = final_choices[index]
        if choice.get("follow_up_event"):
            raise ValueError(f"Sangchul deduction final choice {index} must terminate the chain")
        for key, value in contract.items():
            if choice.get(key) != value:
                raise ValueError(
                    f"Sangchul deduction final choice {index} changed {key}: "
                    f"{choice.get(key)!r}!={value!r}"
                )

    hidden = events["hidden_whole_picture"]
    if hidden.get("background") != "current_housing" \
            or hidden.get("portrait") != "player_normal":
        raise ValueError("Sangchul whole-picture epilogue returned to a fixed goshiwon")


def validate_sangchul_casino_contract(events: dict[str, dict[str, Any]]) -> None:
    """Keep the invitation remote, state-free until the reply, and physically earned."""
    root_id = "arc_sangchul_casino_invite"
    people_id = "arc_sangchul_casino_people"
    cost_id = "arc_sangchul_casino_cost"
    final_id = "arc_sangchul_casino_decision"
    arrival_id = "arc_sangchul_casino_arrival"
    expected_paths = {
        (root_id, people_id, final_id, arrival_id),
        (root_id, people_id, final_id),
        (root_id, cost_id, final_id, arrival_id),
        (root_id, cost_id, final_id),
    }
    actual_paths = {path.event_ids for path in walk_paths(events, root_id)}
    if actual_paths != expected_paths:
        raise ValueError(
            "Sangchul casino invitation paths changed: "
            f"actual={sorted(actual_paths)!r} expected={sorted(expected_paths)!r}"
        )

    visual_contract = {
        root_id: ("current_housing", "sangchul_serious"),
        people_id: ("current_housing", "sangchul_serious"),
        cost_id: ("current_housing", "player_tired"),
        final_id: ("current_housing", "player_tired"),
        arrival_id: ("jeongseon_casino_exterior", "sangchul_normal"),
    }
    for event_id, (background, portrait) in visual_contract.items():
        event = events[event_id]
        if event.get("background") != background or event.get("portrait") != portrait \
                or event.get("cg"):
            raise ValueError(f"Sangchul casino visual continuity changed at {event_id}")

    root_choices = events[root_id].get("choices") or []
    if len(root_choices) != 2 or [choice.get("follow_up_event") for choice in root_choices] != [
        people_id,
        cost_id,
    ]:
        raise ValueError("Sangchul casino invitation must open into people and cost routes")
    buildup_choices = list(root_choices)
    for branch_id in (people_id, cost_id):
        choices = events[branch_id].get("choices") or []
        if len(choices) != 1 or choices[0].get("follow_up_event") != final_id:
            raise ValueError(f"{branch_id} must rejoin the final casino reply")
        buildup_choices.extend(choices)
    arrival_choices = events[arrival_id].get("choices") or []
    if len(arrival_choices) != 1 or arrival_choices[0].get("follow_up_event"):
        raise ValueError("Sangchul casino arrival must close after one state-free threshold beat")
    buildup_choices.extend(arrival_choices)
    for index, choice in enumerate(buildup_choices):
        for forbidden in (
            "effects", "cast_effects", "flags", "clues", "give_items", "opportunity",
            "tendency", "route",
        ):
            if choice.get(forbidden):
                raise ValueError(
                    f"Sangchul casino buildup choice {index} commits {forbidden} early"
                )

    expected_final = (
        {
            "text": '"같이 가겠습니다." (따라가기로 했다)',
            "effects": {"social_skill": 1, "mental": -2},
            "cast_effects": {"sangchul": {"affinity": 8}},
            "flags": ["arc_sangchul_casino_seen", "casino_club_introduced"],
            "follow_up_event": arrival_id,
            "result_text": (
                "답장을 보내자 1분도 지나지 않아 승차권 QR과 좌석 번호가 도착했다.\n\n"
                '"내일 오전 6시 40분. 늦지 마요."\n\n'
                "방 안은 그대로였지만, 내일 아침의 방향만 정선 쪽으로 바뀌었다."
            ),
        },
        {
            "text": '"지금은 아닌 것 같아요." (정중히 사양했다)',
            "effects": {"mental": 1},
            "flags": ["arc_sangchul_casino_seen"],
            "follow_up_event": "",
            "result_text": (
                '상철 씨가 "언제든 준비되면"이라고 했다.\n'
                "제안은 열려있다는 말처럼 들렸다."
            ),
        },
    )
    final_choices = events[final_id].get("choices") or []
    if len(final_choices) != len(expected_final):
        raise ValueError("Sangchul casino reply must retain exactly two terminal decisions")
    for index, contract in enumerate(expected_final):
        choice = final_choices[index]
        for key, value in contract.items():
            if choice.get(key, "" if key == "follow_up_event" else None) != value:
                raise ValueError(
                    f"Sangchul casino final choice {index} changed {key}: "
                    f"{choice.get(key)!r}!={value!r}"
                )

    arrival_description = str(events[arrival_id].get("description", ""))
    if not arrival_description.startswith("정선행 버스가 산길 끝 정류장에 멈췄다."):
        raise ValueError("Sangchul casino arrival lost its explicit bus-arrival cue")
    if '"이기는 게 목표가 아니야. 얼마나 잃지 않느냐가 전략이에요."' \
            not in arrival_description:
        raise ValueError("Sangchul casino arrival lost the canonical baccarat warning")


def validate_hyunsu_reunion_contract(events: dict[str, dict[str, Any]]) -> None:
    """Keep the old choice callback true and hand over the card only in person."""
    root_id = "hyunsu_reunion_later"
    photo_id = "hyunsu_reunion_photo"
    memory_id = "hyunsu_reunion_memory"
    meet_id = "hyunsu_reunion_meet"
    expected_paths = {
        (root_id, photo_id, meet_id),
        (root_id, memory_id, meet_id),
    }
    actual_paths = {path.event_ids for path in walk_paths(events, root_id)}
    if actual_paths != expected_paths:
        raise ValueError(
            "Hyunsu reunion paths changed: "
            f"actual={sorted(actual_paths)!r} expected={sorted(expected_paths)!r}"
        )

    visual_contract = {
        root_id: ("current_housing", "hyunsu_accounting"),
        photo_id: ("current_housing", "hyunsu_accounting"),
        memory_id: ("current_housing", "hyunsu_accounting"),
        meet_id: ("gukbap_restaurant_night", "hyunsu_accounting"),
    }
    for event_id, (background, portrait) in visual_contract.items():
        event = events[event_id]
        if event.get("background") != background or event.get("portrait") != portrait \
                or event.get("cg"):
            raise ValueError(f"Hyunsu reunion visual continuity changed at {event_id}")

    root_choices = events[root_id].get("choices") or []
    if len(root_choices) != 2 or [choice.get("follow_up_event") for choice in root_choices] != [
        photo_id,
        memory_id,
    ]:
        raise ValueError("Hyunsu reunion must open into photo and remembered-door routes")
    buildup_choices = list(root_choices)
    for branch_id in (photo_id, memory_id):
        choices = events[branch_id].get("choices") or []
        if len(choices) != 1 or choices[0].get("follow_up_event") != meet_id:
            raise ValueError(f"{branch_id} must move to the in-person reunion")
        buildup_choices.extend(choices)
    for index, choice in enumerate(buildup_choices):
        for forbidden in (
            "effects", "cast_effects", "flags", "clues", "give_items", "opportunity",
            "tendency", "route",
        ):
            if choice.get(forbidden):
                raise ValueError(f"Hyunsu reunion buildup choice {index} commits {forbidden} early")

    memory = events[memory_id]
    comforted_copy = str((memory.get("description_if_known") or {}).get("hyunsu_comforted", ""))
    if "문 두드렸던 거 기억나?" not in comforted_copy or "캔 따는 소리까지요." not in comforted_copy:
        raise ValueError("Hyunsu reunion lost the comforted door-knock callback")
    default_memory = str(memory.get("description", ""))
    if "아무 말도 못 해서 미안했다" not in default_memory \
            or "안 두드린 것도요" not in default_memory \
            or "그때는 그게 고마웠어요" not in default_memory:
        raise ValueError("Hyunsu reunion invented a door knock on the non-comforted route")

    meet = events[meet_id]
    if not str(meet.get("description", "")).startswith(
        "토요일 저녁, 예전 고시원 골목의 국밥집에서 현수가 먼저 와 있었다."
    ):
        raise ValueError("Hyunsu reunion lost its explicit in-person arrival cue")
    expected_final = (
        {
            "text": "그동안 버틴 걸 제대로 축하한다",
            "effects": {"mental": 4, "social_skill": 1, "tint": 3},
            "flags": ["hyunsu_reconnected"],
            "give_items": ["artifact_hyunsu_card"],
        },
        {
            "text": '"이제 힘들 때는 서로 먼저 연락하자"고 한다',
            "effects": {"mental": 3, "social_skill": 2, "tint": 4},
            "flags": ["hyunsu_reconnected"],
            "give_items": ["artifact_hyunsu_card"],
        },
    )
    final_choices = meet.get("choices") or []
    if len(final_choices) != len(expected_final):
        raise ValueError("Hyunsu reunion must retain two in-person responses")
    for index, contract in enumerate(expected_final):
        choice = final_choices[index]
        if choice.get("follow_up_event"):
            raise ValueError(f"Hyunsu reunion final choice {index} must terminate the chain")
        for key, value in contract.items():
            if choice.get(key) != value:
                raise ValueError(
                    f"Hyunsu reunion final choice {index} changed {key}: "
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


def validate_breakup_peak_contracts(events: dict[str, dict[str, Any]]) -> None:
    """Lock state-free preludes, terminal costs, CG timing, and causal gates."""
    contracts = (
        {
            "label": "Daeun final choice",
            "root": "arc_daeun_final_choice",
            "branches": (
                "arc_daeun_final_choice_kitchen",
                "arc_daeun_final_choice_name",
            ),
            "final": "arc_daeun_final_choice_decision",
            "background": "daeun_newlywed_home",
            "portrait": None,
            "actor": "daeun",
            "texts": (
                '펜을 내려놓는다. "다은씨, 우리 그냥... 좀 늦게 가요."',
                "서명한다. 이번에도 숫자를 믿는다.",
                "(펜을 든 채 — 서랍 속 그 포스트잇이 생각났다)",
            ),
            "effects": (
                {"mental": 20, "tint": 10},
                {"mental": -15, "tint": -12},
                {"mental": 20, "tint": 10},
            ),
            "flags": (
                ["arc_daeun_final_choice_seen"],
                ["arc_daeun_final_choice_seen", "daeun_divorced", "crossed_line"],
                ["arc_daeun_final_choice_seen", "presented_artifact_correct"],
            ),
            "affinity": (20, -40, 22),
            "stages": (None, "distant", None),
            "items": (None, None, "artifact_daeun_note"),
            "cg": "cg_romance_breakup_daeun",
            "reveal": 3,
        },
        {
            "label": "Jiyeon verdict",
            "root": "arc_jiyeon_verdict",
            "branches": (
                "arc_jiyeon_verdict_voice",
                "arc_jiyeon_verdict_fear",
            ),
            "final": "arc_jiyeon_verdict_decision",
            "background": "jiyeon_newlywed_home",
            "portrait": "jiyeon_cold",
            "actor": "jiyeon",
            "texts": (
                '"바뀔게요. 당신 세계에 맞출게요. 뭐든 할게요." (그녀를 붙잡는다)',
                '"이게 나예요. 못 바꿔요. ...미안해요." (그녀를 보낸다)',
                "(폰을 꺼낸다 — 그녀의 첫 문자를, 아직 지우지 않았다)",
            ),
            "effects": (
                {"mental": -12, "tint": -8},
                {"mental": 10, "tint": 8},
                {"mental": 6, "tint": 5},
            ),
            "flags": (
                ["arc_jiyeon_verdict_seen", "jiyeon_kept_by_diminishing", "crossed_line"],
                ["arc_jiyeon_verdict_seen", "jiyeon_left"],
                ["arc_jiyeon_verdict_seen", "jiyeon_stayed_as_selves", "presented_artifact_correct"],
            ),
            "affinity": (10, -30, 8),
            "stages": (None, "distant", None),
            "items": (None, None, "artifact_jiyeon_text"),
            "cg": "cg_romance_breakup_jiyeon",
            "reveal": 2,
        },
    )

    for contract in contracts:
        root_id = str(contract["root"])
        branches = tuple(str(event_id) for event_id in contract["branches"])
        final_id = str(contract["final"])
        expected_paths = {(root_id, branch_id, final_id) for branch_id in branches}
        actual_paths = {path.event_ids for path in walk_paths(events, root_id)}
        if actual_paths != expected_paths:
            rendered = ", ".join(" -> ".join(path) for path in sorted(actual_paths))
            raise ValueError(f"{contract['label']} paths changed: {rendered}")

        for event_id in (root_id, *branches):
            event = events[event_id]
            if event.get("background") != contract["background"] \
                    or event.get("portrait") != contract["portrait"]:
                raise ValueError(f"{contract['label']} buildup visual changed at {event_id}")
            if event.get("cg") or event.get("result_cg"):
                raise ValueError(f"{contract['label']} breakup CG appeared before commitment")
            for choice in event.get("choices") or []:
                for forbidden in (
                    "effects", "flags", "cast_effects", "requires_item",
                    "result_cg", "result_background",
                ):
                    if choice.get(forbidden):
                        raise ValueError(
                            f"{contract['label']} buildup applies {forbidden} at {event_id}"
                        )

        final_event = events[final_id]
        if final_event.get("background") != contract["background"] \
                or final_event.get("portrait") != contract["portrait"]:
            raise ValueError(f"{contract['label']} final visual changed")
        final_choices = final_event.get("choices") or []
        if len(final_choices) != 3:
            raise ValueError(f"{contract['label']} final must retain three authored choices")
        for index, choice in enumerate(final_choices):
            cast_payload: dict[str, Any] = {"affinity": contract["affinity"][index]}
            stage = contract["stages"][index]
            if stage is not None:
                cast_payload["stage"] = stage
            expected_cast = {str(contract["actor"]): cast_payload}
            expected_cg = contract["cg"] if index == 1 else None
            expected_reveal = contract["reveal"] if index == 1 else None
            if choice.get("text") != contract["texts"][index] \
                    or choice.get("effects") != contract["effects"][index] \
                    or choice.get("flags") != contract["flags"][index] \
                    or choice.get("cast_effects") != expected_cast \
                    or choice.get("requires_item") != contract["items"][index] \
                    or choice.get("result_cg") != expected_cg \
                    or choice.get("result_cg_reveal_paragraph") != expected_reveal:
                raise ValueError(f"{contract['label']} final choice {index} changed")

    daeun_chain = {
        event_id
        for event_id in (
            "arc_daeun_final_choice",
            "arc_daeun_final_choice_kitchen",
            "arc_daeun_final_choice_name",
            "arc_daeun_final_choice_decision",
        )
    }
    daeun_copy = "\n".join(
        str(events[event_id].get("description", ""))
        + "\n"
        + "\n".join(str(choice.get("result_text", "")) for choice in events[event_id].get("choices", []))
        for event_id in daeun_chain
    )
    for stale_claim in ("청첩장", "강남 등기가 손에 들어왔다"):
        if stale_claim in daeun_copy:
            raise ValueError(f"Daeun final chain retained the false claim: {stale_claim}")

    with open(MAIN_GAME, encoding="utf-8") as handle:
        source = handle.read()
    return_at = source.find('return "arc_daeun_final_choice"')
    block_at = source.rfind("\n\tif ", 0, return_at)
    if return_at < 0 or block_at < 0:
        raise ValueError("missing Daeun final-choice routing block")
    daeun_gate = source[block_at:return_at + len('return "arc_daeun_final_choice"')]
    for token in (
        "t >= 228",
        "GameState.get_total_asset_value() >= GameState.GANGNAM_TARGET",
        'f.get("daeun_married", false)',
        'f.get("arc_daeun_wedding_day_seen", false)',
        'f.get("used_daeun_as_means", false)',
        'not f.get("daeun_divorced", false)',
        'not f.get("arc_daeun_final_choice_seen", false)',
    ):
        if token not in daeun_gate:
            raise ValueError(f"Daeun final-choice causal gate missing: {token}")
    for stale_gate in ("1_800_000_000.0", "< 3_000_000_000.0"):
        if stale_gate in daeun_gate:
            raise ValueError(f"Daeun final-choice retained the old asset corridor: {stale_gate}")

    apart_at = source.find('return "arc_daeun_year3_apart"')
    apart_start = source.rfind("\n\tvar daeun_apart_path", 0, apart_at)
    apart_block = source[apart_start:apart_at + len('return "arc_daeun_year3_apart"')]
    for token in ("daeun_let_drift", "daeun_breakup_begged"):
        if token not in apart_block:
            raise ValueError(f"Daeun year-three apart route lost breakup variant: {token}")

    father_at = source.find('return "arc_father_06_confession"')
    father_start = source.rfind("\n\tif ", 0, father_at)
    father_block = source[father_start:father_at + len('return "arc_father_06_confession"')]
    if "t >= 102" not in father_block or "t >= 112" in father_block:
        raise ValueError("Father's broker confession must precede the t104 deduction window")

    with open(GAME_STATE, encoding="utf-8") as handle:
        game_state_source = handle.read()
    for token in (
        "daeun_reckoning_pending",
        'flags.get("used_daeun_as_means", false)',
        'not flags.get("arc_daeun_final_choice_seen", false)',
        "var gangnam_goal_reached: bool = peak_asset >= GANGNAM_TARGET",
        "gangnam_goal_reached and daeun_reckoning_pending",
    ):
        if token not in game_state_source:
            raise ValueError(f"Daeun ending cascade can bypass her reckoning: {token}")

    with open(ENDINGS_KO, encoding="utf-8") as handle:
        endings_ko = {item["id"]: item for item in json.load(handle)}
    with open(ENDINGS_EN, encoding="utf-8") as handle:
        endings_en = {item["id"]: item for item in json.load(handle)}
    for locale, ending in (("ko", endings_ko["jaehyuk_way"]), ("en", endings_en["jaehyuk_way"])):
        known = ending.get("description_if_known") or {}
        if "vouched_jaehyuk_guarantee" not in known:
            raise ValueError(f"Jaehyuk guarantee has no ending memory in {locale}")


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


def validate_review_appendix_contracts(
        ko_events: dict[str, dict[str, Any]],
        en_events: dict[str, dict[str, Any]]) -> None:
    """Lock the ORDER-50 motive, late-game, and pre-romance repairs."""
    with open(MAIN_GAME, encoding="utf-8") as handle:
        source = handle.read()

    def if_block_before(return_line: str) -> str:
        return_at = source.find(return_line)
        if return_at < 0:
            raise ValueError(f"missing review-appendix route: {return_line}")
        block_at = source.rfind("\n\tif ", 0, return_at)
        if block_at < 0:
            raise ValueError(f"missing route condition before: {return_line}")
        return source[block_at:return_at + len(return_line)]

    late_push = if_block_before('return "arc_late_game_push"')
    for token in (
        "t >= 205",
        "t <= 215",
        'f.get("arc_37_reckoning_seen", false)',
        'f.get("arc_final_year_start_seen", false)',
        "GameState.get_total_asset_value() < 2_800_000_000.0",
    ):
        if token not in late_push:
            raise ValueError(f"late-game push window lost contract: {token}")

    daeun_echo = if_block_before('return "arc_daeun_later_echo"')
    for token in (
        "t >= 193",
        'f.get("arc_final_stretch_seen", false)',
        'not f.get("arc_daeun_later_echo_seen", false)',
    ):
        if token not in daeun_echo:
            raise ValueError(f"Daeun final-stretch echo lost gate: {token}")

    daeun_year5 = if_block_before('return "arc_daeun_year5_ending"')
    for token in (
        "t >= 193",
        "GameState.get_total_asset_value() >= 2_900_000_000.0",
        'not f.get("arc_daeun_year5_seen", false)',
    ):
        if token not in daeun_year5:
            raise ValueError(f"Daeun near-goal dinner lost gate: {token}")

    for language, events in (("ko", ko_events), ("en", en_events)):
        for event_id in ("arc_chapter1_close", "arc_year1_close"):
            event = events[event_id]
            surfaces = [str(event.get("description", ""))]
            surfaces.extend(str(value) for value in (
                event.get("description_if_known") or {}
            ).values())
            for surface in surfaces:
                if "{notebook_motive}" not in surface:
                    raise ValueError(
                        f"{event_id} lost notebook motive token in {language}"
                    )

        jiyeon_truth = json.dumps(
            events["arc_jiyeon_truth_warned"], ensure_ascii=False
        ).lower()
        forbidden_address = "오빠" if language == "ko" else "oppa"
        if forbidden_address in jiyeon_truth:
            raise ValueError(
                f"Jiyeon pre-romance truth retained {forbidden_address} in {language}"
            )

    routine_ko = json.dumps(
        ko_events["arc_34_routine_trap"], ensure_ascii=False
    )
    routine_en = json.dumps(
        en_events["arc_34_routine_trap"], ensure_ascii=False
    )
    for stale in ("루틴은 도구다", "편안함은 성장의 반대말", "루틴을 깨면 원래 안 보이던"):
        if stale in routine_ko:
            raise ValueError(f"routine scene retained abstract maxim: {stale}")
    for stale in ("Discipline means", "Sometimes a small disruption"):
        if stale in routine_en:
            raise ValueError(f"English routine scene retained abstract maxim: {stale}")


FINALE_IDS = (
    "arc_pre_ending_summit",
    "arc_final_countdown",
    "arc_final_week",
)
FINALE_SIGNATURES = (
    "final_signature_owned",
    "final_signature_collateral",
    "final_signature_people",
)


def _prose(value: Any, label: str) -> str:
    if not isinstance(value, str) or not value.strip():
        raise ValueError(f"{label} must be a non-empty prose string")
    return value.strip()


def _paragraphs(value: Any) -> list[str]:
    return [block.strip() for block in str(value or "").split("\n\n") if block.strip()]


def _reject_duplicate_prose_panels(value: Any, label: str) -> None:
    """Reject literal padding without treating a panel count as a quality target."""
    normalized = [re.sub(r"\s+", " ", block).strip().lower() for block in _paragraphs(value)]
    if len(normalized) != len(set(normalized)):
        raise ValueError(f"{label} repeats an identical prose panel (filler)")


def _require_meanings(
        locale: str,
        surface: str,
        text: str,
        requirements: dict[str, tuple[tuple[str, ...], ...]]) -> None:
    """Require each dramatic function, independent of paragraph position or count."""
    for meaning, groups in requirements.items():
        for alternatives in groups:
            if not any(re.search(pattern, text, re.IGNORECASE | re.DOTALL)
                       for pattern in alternatives):
                raise ValueError(f"{locale}:{surface} lost meaning {meaning}")


def _placeholder_sequence(value: Any) -> list[str]:
    # EN may replace repeated KO names with pronouns; preserve the placeholder
    # vocabulary without requiring occurrence-for-occurrence literal symmetry.
    return sorted(set(re.findall(
        r"\{[A-Za-z_][A-Za-z0-9_]*\}", str(value or ""))))


def _variant_map(
        event: dict[str, Any], field: str, label: str,
        exact_keys: set[str] | None = None,
        required_keys: set[str] | None = None) -> dict[str, str]:
    value = event.get(field)
    if not isinstance(value, dict):
        raise ValueError(f"{label}.{field} must be a prose map")
    keys = set(value)
    if exact_keys is not None and keys != exact_keys:
        raise ValueError(f"{label}.{field} keys changed: {sorted(keys)!r}")
    if required_keys is not None and not required_keys.issubset(keys):
        missing = sorted(required_keys - keys)
        raise ValueError(f"{label}.{field} lost variants: {missing!r}")
    result: dict[str, str] = {}
    for key, prose in value.items():
        result[str(key)] = _prose(prose, f"{label}.{field}.{key}")
        _reject_duplicate_prose_panels(prose, f"{label}.{field}.{key}")
    return result


def _all_finale_prose(event: dict[str, Any]) -> list[tuple[str, str]]:
    surfaces: list[tuple[str, str]] = []
    for field in (
        "description", "description_orthodox", "description_unorthodox",
    ):
        if field in event:
            surfaces.append((field, _prose(event[field], f"{event.get('id')}.{field}")))
    for field in (
        "description_if_moral", "description_if_known", "description_memory_if_known",
    ):
        value = event.get(field)
        if value is None:
            continue
        if not isinstance(value, dict):
            raise ValueError(f"{event.get('id')}.{field} must be a prose map")
        for key, prose in value.items():
            surfaces.append((f"{field}.{key}", _prose(
                prose, f"{event.get('id')}.{field}.{key}")))
    choices = event.get("choices")
    if not isinstance(choices, list):
        raise ValueError(f"{event.get('id')}.choices must be an array")
    for index, choice in enumerate(choices):
        if not isinstance(choice, dict):
            raise ValueError(f"{event.get('id')}.choices[{index}] must be an object")
        for field in ("text", "result_text"):
            surfaces.append((f"choices[{index}].{field}", _prose(
                choice.get(field), f"{event.get('id')}.choices[{index}].{field}")))
        if "text_if_moral" in choice:
            moral = choice["text_if_moral"]
            if not isinstance(moral, dict):
                raise ValueError(
                    f"{event.get('id')}.choices[{index}].text_if_moral must be a prose map")
            for key, prose in moral.items():
                surfaces.append((f"choices[{index}].text_if_moral.{key}", _prose(
                    prose, f"{event.get('id')}.choices[{index}].text_if_moral.{key}")))
    return surfaces


def _validate_finale_shape_and_parity(
        ko_events: dict[str, dict[str, Any]],
        en_events: dict[str, dict[str, Any]]) -> None:
    summit_fields = ("description", "description_orthodox", "description_unorthodox")
    for event_id in FINALE_IDS:
        if event_id not in ko_events or event_id not in en_events:
            raise ValueError(f"finale event missing from KO/EN: {event_id}")
        for locale, event in (("ko", ko_events[event_id]), ("en", en_events[event_id])):
            for surface, prose in _all_finale_prose(event):
                _reject_duplicate_prose_panels(prose, f"{locale}:{event_id}.{surface}")
        ko_choices = ko_events[event_id].get("choices") or []
        en_choices = en_events[event_id].get("choices") or []
        if len(ko_choices) != len(en_choices):
            raise ValueError(f"finale KO/EN choice count drifted: {event_id}")

    for locale, events in (("ko", ko_events), ("en", en_events)):
        summit = events["arc_pre_ending_summit"]
        for field in summit_fields:
            _prose(summit.get(field), f"{locale}:arc_pre_ending_summit.{field}")

        countdown = events["arc_final_countdown"]
        _variant_map(
            countdown, "description_if_moral", f"{locale}:arc_final_countdown",
            exact_keys={"black", "white"})
        _variant_map(
            countdown, "description_memory_if_known", f"{locale}:arc_final_countdown",
            exact_keys={"m3_ledger_reasons_named", "m3_ledger_totals_only"})
        for index, choice in enumerate(countdown.get("choices") or []):
            moral = choice.get("text_if_moral")
            if not isinstance(moral, dict) or set(moral) != {"black", "white"}:
                raise ValueError(
                    f"{locale}:arc_final_countdown.choices[{index}].text_if_moral keys changed")
            for moral_id, prose in moral.items():
                _prose(prose, (
                    f"{locale}:arc_final_countdown.choices[{index}]."
                    f"text_if_moral.{moral_id}"))

        final_week = events["arc_final_week"]
        _variant_map(
            final_week, "description_if_known", f"{locale}:arc_final_week",
            required_keys=set(FINALE_SIGNATURES))
        _variant_map(
            final_week, "description_memory_if_known", f"{locale}:arc_final_week",
            exact_keys={
                "m4_housing_priority_runway",
                "m4_housing_priority_privacy",
                "m4_housing_priority_time",
            })

    # Variant/memory topology and placeholder vocabulary stay isomorphic.
    paired_maps = {
        "arc_final_countdown": (
            "description_if_moral", "description_memory_if_known",
        ),
        "arc_final_week": (
            "description_if_known", "description_memory_if_known",
        ),
    }
    for event_id, fields in paired_maps.items():
        for field in fields:
            ko_map = ko_events[event_id].get(field) or {}
            en_map = en_events[event_id].get(field) or {}
            if set(ko_map) != set(en_map):
                raise ValueError(f"finale KO/EN variant keys drifted: {event_id}.{field}")
            for key in ko_map:
                if _placeholder_sequence(ko_map[key]) != _placeholder_sequence(en_map[key]):
                    raise ValueError(
                        f"finale placeholder parity drifted: {event_id}.{field}.{key}")

    for event_id in FINALE_IDS:
        ko_event = ko_events[event_id]
        en_event = en_events[event_id]
        fields = summit_fields if event_id == "arc_pre_ending_summit" else ("description",)
        for field in fields:
            if _placeholder_sequence(ko_event.get(field)) \
                    != _placeholder_sequence(en_event.get(field)):
                raise ValueError(f"finale placeholder parity drifted: {event_id}.{field}")
        for index, (ko_choice, en_choice) in enumerate(zip(
                ko_event.get("choices") or [], en_event.get("choices") or [])):
            for field in ("text", "result_text"):
                if _placeholder_sequence(ko_choice.get(field)) \
                        != _placeholder_sequence(en_choice.get(field)):
                    raise ValueError(
                        f"finale placeholder parity drifted: "
                        f"{event_id}.choices[{index}].{field}")
            ko_moral = ko_choice.get("text_if_moral") or {}
            en_moral = en_choice.get("text_if_moral") or {}
            if set(ko_moral) != set(en_moral):
                raise ValueError(
                    f"finale KO/EN choice variant keys drifted: {event_id}[{index}]")
            for moral_id in ko_moral:
                if _placeholder_sequence(ko_moral[moral_id]) \
                        != _placeholder_sequence(en_moral[moral_id]):
                    raise ValueError(
                        f"finale placeholder parity drifted: "
                        f"{event_id}.choices[{index}].text_if_moral.{moral_id}")


def _validate_finale_meanings(
        ko_events: dict[str, dict[str, Any]],
        en_events: dict[str, dict[str, Any]]) -> None:
    summit_fields = ("description", "description_orthodox", "description_unorthodox")
    summit_common = {
        "ko": {
            "summit.location": ((r"부동산 사무실",), (r"책상", r"매물표")),
            "summit.asset_and_goal": ((r"25\s*억원",), (r"30\s*억원",), (r"목표",)),
            "summit.inclusive_threshold": ((r"25\s*억원에 닿", r"25\s*억원 이상"),),
            "summit.goal_relation_neutral": ((r"아래인지",), (r"닿았는지",), (r"넘어섰는지",)),
            "summit.not_owned": ((r"아직[^.]{0,50}(?:아니|없)", r"소유권[^.]{0,30}(?:아니|없)"),),
            "summit.carrying_cost": ((r"취득세",), (r"중개보수",), (r"남겨 둘 현금", r"버틸 값")),
            "summit.pre_contract_threshold": (
                (r"서명한[^.]{0,30}계약서[^.]{0,100}없", r"계약서[^.]{0,20}아니"),
                (r"등기[^.]{0,80}없", r"등기[^.]{0,20}아니"),
                (r"열쇠[^.]{0,40}없", r"열쇠[^.]{0,20}아니"),
            ),
            "summit.present_action": ((r"아버지[^.]{0,30}연락처",), (r"강남대로",), (r"행동",)),
        },
        "en": {
            "summit.location": ((r"real estate office",), (r"desk", r"listing")),
            "summit.asset_and_goal": ((r"2\.5[- ]billion[- ]won",), (r"3[- ]billion",), (r"goal",)),
            "summit.inclusive_threshold": ((r"(?:had )?reached[^.]{0,30}2\.5[- ]billion[- ]won[^.]{0,20}threshold", r"at least 2\.5[- ]billion[- ]won"),),
            "summit.goal_relation_neutral": ((r"below",), (r"\bat\b",), (r"beyond",)),
            "summit.not_owned": ((r"none of the homes[^.]{0,40}(?:his|owned)", r"ownership[^.]{0,30}(?:not|no)"),),
            "summit.carrying_cost": ((r"acquisition tax",), (r"brokerage fee",), (r"cash to keep", r"survive after paying")),
            "summit.pre_contract_threshold": (
                (r"no signed purchase agreement", r"not a contract"),
                (r"no[^.]{0,80}registration receipt", r"not[^.]{0,20}registration"),
                (r"no[^.]{0,100}(?:handed-over )?key", r"not[^.]{0,20}key"),
            ),
            "summit.present_action": ((r"father[^.]{0,30}contacts",), (r"gangnam-daero",), (r"action",)),
        },
    }
    summit_route = {
        "ko": {
            "description": {
                "summit.general_route_cost": ((r"들어온 돈",), (r"나간 돈",), (r"자산[^.]{0,20}선택",), (r"지나간 시간",)),
            },
            "description_orthodox": {
                "summit.orthodox_cost": ((r"정석",), (r"선택 기록",), (r"더 많은 무게",), (r"고르지 않은 가능성",)),
            },
            "description_unorthodox": {
                "summit.unorthodox_cost": ((r"비정석",), (r"선택 기록",), (r"더 많은 무게",), (r"고르지 않은 가능성",)),
            },
        },
        "en": {
            "description": {
                "summit.general_route_cost": ((r"money in",), (r"money[^.]{0,12}out",), (r"choices[^.]{0,25}moved[^.]{0,15}assets",), (r"time[^.]{0,15}passed",)),
            },
            "description_orthodox": {
                "summit.orthodox_cost": ((r"conventional",), (r"record of his choices",), (r"carried more weight",), (r"possibilities[^.]{0,25}not chosen",)),
            },
            "description_unorthodox": {
                "summit.unorthodox_cost": ((r"unorthodox",), (r"record of his choices",), (r"carried more weight",), (r"possibilities[^.]{0,25}not chosen",)),
            },
        },
    }
    for locale, events in (("ko", ko_events), ("en", en_events)):
        summit = events["arc_pre_ending_summit"]
        surfaces: list[str] = []
        for field in summit_fields:
            text = _prose(summit[field], f"{locale}:arc_pre_ending_summit.{field}")
            surfaces.append(text)
            _require_meanings(
                locale, f"arc_pre_ending_summit.{field}", text,
                summit_common[locale])
            _require_meanings(
                locale, f"arc_pre_ending_summit.{field}", text,
                summit_route[locale][field])
        if len(set(surfaces)) != len(surfaces):
            raise ValueError(f"{locale}:summit route variants lost distinct meaning")

    summit_results = {
        "ko": (
            {
                "summit.father_contact": ((r"아버지",), (r"연락처",)),
                "summit.no_call_made": ((r"누르지 않았다|누르지는 않았다",),),
                "summit.no_reply_created": ((r"발신 시각",), (r"신호음",), (r"답도 생기지 않았다",)),
                "summit.truth_before_goal": ((r"집[^.]{0,20}(?:사지 않았|산 것은 아니)",), (r"25\s*억원[^.]{0,15}(?:문턱[^.]{0,10})?에 닿", r"25\s*억원 이상"), (r"30\s*억원",)),
                "summit.current_comparison": ((r"지금 숫자",), (r"나란히",)),
            },
            {
                "summit.walks_now": ((r"강남대로",), (r"한 블록",)),
                "summit.listing_not_contract": ((r"계약서가 아니라",), (r"매물표",)),
                "summit.body_cost": ((r"허리",), (r"종아리",), (r"걸음을 줄",)),
                "summit.no_ownership": ((r"소유권[^.]{0,25}(?:주지는 않았다|없)",),),
                "summit.refuses_false_arrival": ((r"도착했다[^.]{0,15}(?:삼키|말하지|아니)", r"도착했다[^.]{0,15}말[^.]{0,15}삼키"),),
            },
        ),
        "en": (
            {
                "summit.father_contact": ((r"father",), (r"contact",)),
                "summit.no_call_made": ((r"did not press",),),
                "summit.no_reply_created": ((r"outgoing time",), (r"ring",), (r"no[^.]{0,40}answer",)),
                "summit.truth_before_goal": ((r"had not bought a home",), (r"(?:had )?reached[^.]{0,30}2\.5[- ]billion[- ]won[^.]{0,20}threshold", r"at least 2\.5[- ]billion[- ]won"), (r"3[- ]billion[- ]won",)),
                "summit.current_comparison": ((r"current figure",), (r"compar",)),
            },
            {
                "summit.walks_now": ((r"gangnam-daero",), (r"one block",)),
                "summit.listing_not_contract": ((r"no contract",), (r"listing",)),
                "summit.body_cost": ((r"lower back",), (r"calves",), (r"slowed",)),
                "summit.no_ownership": ((r"neither gave him ownership", r"gave him no ownership"),),
                "summit.refuses_false_arrival": ((r"swallowed[^.]{0,40}arrived",),),
            },
        ),
    }
    for locale, events in (("ko", ko_events), ("en", en_events)):
        for index, requirements in enumerate(summit_results[locale]):
            result = _prose(
                events["arc_pre_ending_summit"]["choices"][index]["result_text"],
                f"{locale}:arc_pre_ending_summit.choices[{index}].result_text")
            _require_meanings(
                locale, f"arc_pre_ending_summit.choices[{index}].result_text",
                result, requirements)

    countdown_common = {
        "ko": {
            "countdown.independent_opening": ((r"다섯 해의 마지막 달",), (r"수첩을 편 책상",)),
            "countdown.start_and_goal": ((r"50\s*만원",), (r"30\s*억원",), (r"목표",)),
            "countdown.current_result": ((r"자산 화면",), (r"목표[^.]{0,30}(?:위|아래|넘|닿|못 닿)",)),
            "countdown.actual_record": ((r"실제로",), (r"금액",), (r"날짜",), (r"이름",), (r"만남",), (r"답",), (r"빈칸",)),
            "countdown.money_people_ledger": ((r"돈",), (r"사람[^.]{0,25}시간",), (r"장부",)),
            "countdown.not_a_contract": ((r"빈 줄",), (r"수첩",), (r"계약서[^.]{0,15}아니",), (r"접수본[^.]{0,15}아니",)),
            "countdown.three_signature_meanings": ((r"책임|결과는 내 것",), (r"이름[^.]{0,20}(?:계산|값|가치)",), (r"사람부터",)),
            "countdown.mutual_exclusion": ((r"하나",), (r"다른 (?:둘|두)",), (r"모두|셋",)),
            "countdown.no_proxy_signer": ((r"대신 서명",), (r"펜[^.]{0,25}(?:함께|같이)",)),
            "countdown.cost_after_choice": ((r"대가",), (r"한 줄",)),
        },
        "en": {
            "countdown.independent_opening": ((r"final month of the five years",), (r"notebook open",)),
            "countdown.start_and_goal": ((r"500,000 won",), (r"3[- ]billion(?:-won)?",), (r"goal",)),
            "countdown.current_result": ((r"assets screen",), (r"(?:above|past)[^.]{0,20}(?:below|goal)|(?:reaching|arrival)[^.]{0,20}(?:missing|failure)",)),
            "countdown.actual_record": ((r"actually",), (r"amount",), (r"date",), (r"name",), (r"meeting",), (r"answer",), (r"blank",)),
            "countdown.money_people_ledger": ((r"money",), (r"time borrowed from people",), (r"ledger",)),
            "countdown.not_a_contract": ((r"blank line",), (r"notebook",), (r"no contract|not a contract",), (r"no filed copy|not a filed copy|no contract or filed copy",)),
            "countdown.three_signature_meanings": ((r"responsibility|outcome is mine",), (r"price the names|names[^.]{0,35}(?:value|cost)",), (r"people first",)),
            "countdown.mutual_exclusion": ((r"one meaning|one of|writing one",), (r"other two",), (r"all three",)),
            "countdown.no_proxy_signer": ((r"sign for him|sign in his place",), (r"hold the pen with him",)),
            "countdown.cost_after_choice": ((r"cost",), (r"one line|the line",)),
        },
    }
    countdown_route = {
        "ko": {
            "description": {
                "countdown.base_signature": ((r"내가 책임",), (r"이름[^.]{0,15}계산",), (r"사람부터",)),
            },
            "black": {
                "countdown.black_signature": ((r"결과는 내 것",), (r"이름[^.]{0,15}(?:값|가치)",), (r"목소리[^.]{0,20}비용",)),
            },
            "white": {
                "countdown.white_signature": ((r"도움[^.]{0,25}지우지", r"도움받은[^.]{0,25}지우지"), (r"책임|자기 몫",), (r"순서|같은 문장|달랐",)),
            },
        },
        "en": {
            "description": {
                "countdown.base_signature": ((r"take responsibility",), (r"price the names",), (r"people first",)),
            },
            "black": {
                "countdown.black_signature": ((r"outcome is mine",), (r"names[^.]{0,35}cost",), (r"voices?[^.]{0,35}cost",)),
            },
            "white": {
                "countdown.white_signature": ((r"without erasing help|not erasing help|help[^.]{0,25}remained visible",), (r"responsibility|his share",), (r"same sentence|order|different",)),
            },
        },
    }
    for locale, events in (("ko", ko_events), ("en", en_events)):
        countdown = events["arc_final_countdown"]
        surfaces = {
            "description": _prose(countdown["description"], f"{locale}:countdown.description"),
            **_variant_map(
                countdown, "description_if_moral", f"{locale}:arc_final_countdown",
                exact_keys={"black", "white"}),
        }
        for route_id, text in surfaces.items():
            _require_meanings(
                locale, f"arc_final_countdown.{route_id}", text,
                countdown_common[locale])
            _require_meanings(
                locale, f"arc_final_countdown.{route_id}", text,
                countdown_route[locale][route_id])
        if len(set(surfaces.values())) != len(surfaces):
            raise ValueError(f"{locale}:countdown moral variants lost distinct meaning")

    countdown_results = {
        "ko": (
            {
                "countdown.owned_result": ((r"자기 이름",), (r"계약서가 아닌|계약[^.]{0,15}아니",), (r"도움[^.]{0,25}(?:지우지|없던 일)",), (r"책임",), (r"관계[^.]{0,30}(?:돌아오|회복|움직)[^.]{0,15}(?:않|아니)",)),
            },
            {
                "countdown.collateral_result": ((r"실제로[^.]{0,25}이름",), (r"수익|얻은 것",), (r"비용|잃은 것",), (r"30\s*억원",), (r"사람[^.]{0,20}자원|목소리[^.]{0,25}작아",), (r"계약[^.]{0,25}(?:실행하지|실행되지|아니|뒤따르지)",), (r"이체[^.]{0,25}(?:실행하지|실행되지|아니|뒤따르지)",)),
            },
            {
                "countdown.people_result": ((r"실제로[^.]{0,35}이름",), (r"곁에[^.]{0,20}(?:아니|뜻도|있거나)",), (r"관계[^.]{0,20}(?:증명하지|아니)|떠난 사람[^.]{0,25}돌아온",), (r"자기 이름[^.]{0,15}(?:마지막|맨 마지막)",), (r"답장",), (r"만남",), (r"화해",)),
            },
        ),
        "en": (
            {
                "countdown.owned_result": ((r"his name",), (r"not a contract",), (r"did not erase[^.]{0,30}(?:help|dates and names)",), (r"responsibility",), (r"did not[^.]{0,30}restore[^.]{0,20}relationship|restored no[^.]{0,20}relationship|neither[^.]{0,45}relationships? moved|no distant relationship returned",)),
            },
            {
                "countdown.collateral_result": ((r"names actually written",), (r"return",), (r"cost",), (r"3-billion-won",), (r"people as resources|voices?[^.]{0,25}shrank",), (r"no(?: new)? contract",), (r"no[^.]{0,25}transfer|transfer[^.]{0,20}did not follow",)),
            },
            {
                "countdown.people_result": ((r"names that (?:already appeared|remained)",), (r"still beside him|had returned",), (r"could not prove[^.]{0,25}relationship|someone who had left had returned",), (r"his own name last",), (r"reply",), (r"meeting",), (r"reconciliation",)),
            },
        ),
    }
    for locale, events in (("ko", ko_events), ("en", en_events)):
        for index, requirements in enumerate(countdown_results[locale]):
            result = _prose(
                events["arc_final_countdown"]["choices"][index]["result_text"],
                f"{locale}:arc_final_countdown.choices[{index}].result_text")
            _require_meanings(
                locale, f"arc_final_countdown.choices[{index}].result_text",
                result, requirements)

    final_week_common = {
        "ko": {
            "final_week.same_scene": ((r"몇 분",), (r"같은 밤",), (r"같은 방",), (r"같은 책상|책상",)),
            "final_week.previous_signature": ((r"서명",), (r"수첩",)),
            "final_week.actual_conversation": ((r"실제로[^.]{0,25}(?:주고받|대화)",), (r"전송 시각",), (r"대화방|대화[^.]{0,20}방",), (r"증명[^.]{0,20}(?:아니|못)",)),
            "final_week.unsettled_state": ((r"답장",), (r"만남",), (r"화해",), (r"확정[^.]{0,15}(?:아니|않)",)),
            "final_week.outbound_actions": ((r"밥",), (r"사과",), (r"거리",), (r"연락[^.]{0,15}시각",)),
            "final_week.other_person_choice": ((r"강제로[^.]{0,20}(?:만들|할 수 없)",), (r"상대[^.]{0,25}선택|화면 반대편 사람[^.]{0,25}선택",)),
            "final_week.present_objects": ((r"휴대폰",), (r"커서",), (r"충전선|배터리",)),
            "final_week.minjun_goes_first": ((r"먼저 보낼 행동", r"자기 쪽에서 먼저"),),
        },
        "en": {
            "final_week.same_scene": ((r"few minutes",), (r"same night",), (r"same room",), (r"same desk|desk",)),
            "final_week.previous_signature": ((r"signature",), (r"notebook",)),
            "final_week.actual_conversation": ((r"actually exchanged|real words",), (r"sent times?",), (r"conversation",), (r"did not prove",)),
            "final_week.unsettled_state": ((r"reply",), (r"meeting",), (r"reconciliation",), (r"not been settled|no[^.]{0,80}settled",)),
            "final_week.outbound_actions": ((r"meal",), (r"apology",), (r"distance",), (r"contact[^.]{0,25}(?:time|tomorrow)",)),
            "final_week.other_person_choice": ((r"could not force|no sentence could force",), (r"choices? for the person|other person[^.]{0,20}choice",)),
            "final_week.present_objects": ((r"phone",), (r"cursor",), (r"charging cable|battery",)),
            "final_week.minjun_goes_first": ((r"action he would send first|his side[^.]{0,20}first",),),
        },
    }
    final_week_route = {
        "ko": {
            "final_signature_owned": {
                "final_week.owned_signature": ((r"이름",), (r"책임",), (r"빚[^.]{0,20}(?:갚|아니)",), (r"관계[^.]{0,20}(?:돌아오|되돌리|회복)[^.]{0,18}(?:않|아니)",)),
            },
            "final_signature_collateral": {
                "final_week.collateral_signature": ((r"이름",), (r"수익|얻은 것",), (r"비용|잃은 것",), (r"목소리",), (r"관계[^.]{0,25}(?:돌아오|되돌리|회복)[^.]{0,18}(?:않|아니)",)),
            },
            "final_signature_people": {
                "final_week.people_signature": ((r"실제로[^.]{0,30}이름",), (r"순서",), (r"떠난 사람[^.]{0,30}돌아오",), (r"관계[^.]{0,20}(?:회복|돌아오|되돌리)[^.]{0,18}(?:않|아니)",)),
            },
        },
        "en": {
            "final_signature_owned": {
                "final_week.owned_signature": ((r"his name",), (r"responsibility",), (r"repaid no debt",), (r"restored no relationship",)),
            },
            "final_signature_collateral": {
                "final_week.collateral_signature": ((r"names",), (r"return",), (r"cost",), (r"voices",), (r"did not restore[^.]{0,80}relationships?",)),
            },
            "final_signature_people": {
                "final_week.people_signature": ((r"names actually written",), (r"order",), (r"did not bring anyone back",), (r"restore a relationship",)),
            },
        },
    }
    for locale, events in (("ko", ko_events), ("en", en_events)):
        final_week = events["arc_final_week"]
        known = final_week.get("description_if_known") or {}
        surfaces = {"description": _prose(
            final_week["description"], f"{locale}:arc_final_week.description")}
        surfaces.update({signature_id: _prose(
            known.get(signature_id),
            f"{locale}:arc_final_week.description_if_known.{signature_id}")
            for signature_id in FINALE_SIGNATURES})
        for route_id, text in surfaces.items():
            _require_meanings(
                locale, f"arc_final_week.{route_id}", text,
                final_week_common[locale])
            if route_id != "description":
                _require_meanings(
                    locale, f"arc_final_week.{route_id}", text,
                    final_week_route[locale][route_id])
        if len(set(surfaces.values())) != len(surfaces):
            raise ValueError(f"{locale}:final week signature variants lost distinct meaning")

    final_week_results = {
        "ko": (
            {
                "final_week.meal_result": ((r"다섯 해 전",), (r"잘했다",), (r"버틴 시간",), (r"밥",), (r"제안",), (r"날짜",), (r"장소",), (r"동의",), (r"전송|보낸 시각",), (r"침묵|거절",)),
            },
            {
                "final_week.apology_result": ((r"미뤄 둔 사과",), (r"잘못",), (r"해명[^.]{0,50}(?:않|없|붙이지)",), (r"용서[^.]{0,20}(?:요구하지|바라지 않)",), (r"읽음|답장",), (r"화해[^.]{0,12}(?:아니|않)",)),
            },
            {
                "final_week.distance_result": ((r"포기하지",), (r"다행",), (r"고마",), (r"혼자|거리",), (r"내일|다시 연락",), (r"8시|여덟 시",), (r"자기 쪽|이쪽",), (r"충전선|충전",), (r"답[^.]{0,15}(?:오지|없)",)),
            },
        ),
        "en": (
            {
                "final_week.meal_result": ((r"five years ago",), (r"you did well",), (r"endured|held on",), (r"meal",), (r"proposal",), (r"date",), (r"place",), (r"consent",), (r"sent time",), (r"silence|refusal",)),
            },
            {
                "final_week.apology_result": ((r"delayed apology",), (r"done wrong|fault",), (r"no explanation",), (r"neither[^.]{0,20}forgiveness|did not demand[^.]{0,20}forgiveness",), (r"read mark|reply",), (r"reconciliation[^.]{0,15}(?:not|were not)|no[^.]{0,60}reconciliation appeared",)),
            },
            {
                "final_week.distance_result": ((r"didn't give up|did not give up",), (r"glad",), (r"gratitude",), (r"alone tonight|distance",), (r"contact[^.]{0,25}tomorrow",), (r"eight",), (r"his side|this side",), (r"charging cable|plugged",), (r"no new answer",)),
            },
        ),
    }
    for locale, events in (("ko", ko_events), ("en", en_events)):
        for index, requirements in enumerate(final_week_results[locale]):
            result = _prose(
                events["arc_final_week"]["choices"][index]["result_text"],
                f"{locale}:arc_final_week.choices[{index}].result_text")
            _require_meanings(
                locale, f"arc_final_week.choices[{index}].result_text",
                result, requirements)


def _validate_finale_false_facts(
        ko_events: dict[str, dict[str, Any]],
        en_events: dict[str, dict[str, Any]]) -> None:
    false_facts = {
        "ko": {
            "invented 3-billion achievement": (
                r"30\s*억원(?:을|에)?\s*(?:넘겼|넘었|달성했|도달했|찍었)",
                r"목표(?:를|에)\s*(?:달성|도달)(?:했|했다)",
            ),
            "invented purchase/ownership": (
                r"(?:집|주택|매물)(?:을|를)\s*(?:샀다|매입했다)",
                r"매매계약(?:서)?(?:에|을)\s*(?:서명했다|체결했다)",
                r"계약을\s*(?:체결했다|마쳤다)",
                r"등기(?:를)?\s*(?:마쳤다|했다|접수했다)",
                r"열쇠(?:를)?\s*(?:받았다|건네받았다)",
            ),
            "invented transfer": (r"이체 확인서", r"이체 완료"),
            "invented reply/recovery": (
                r"답장(?:이|은)\s*(?:왔다|도착했다)",
                r"만나기로\s*(?:했다|확정했다)",
                r"용서받았다", r"화해했다(?:\.|$)", r"관계가 회복됐다",
                r"상대가\s*(?:동의했다|받아들였다)",
            ),
        },
        "en": {
            "invented 3-billion achievement": (
                r"(?:reached|exceeded|hit|achieved) the 3[- ]billion(?:-won)? goal",
                r"3[- ]billion(?:-won)? goal (?:was|had been) (?:reached|achieved)",
            ),
            "invented purchase/ownership": (
                r"(?<!not )bought (?:the|a) home",
                r"signed (?:the|a) purchase (?:agreement|contract)",
                r"completed (?:the )?registration",
                r"(?:received|was handed) the key",
            ),
            "invented transfer": (r"transfer confirmation", r"transfer completed"),
            "invented reply/recovery": (
                r"a reply came", r"agreed to meet", r"was forgiven",
                r"reconciled with", r"the relationship was restored",
                r"the other person (?:agreed|accepted)",
            ),
        },
    }
    for locale, events in (("ko", ko_events), ("en", en_events)):
        for event_id in FINALE_IDS:
            for surface, prose in _all_finale_prose(events[event_id]):
                for label, patterns in false_facts[locale].items():
                    for pattern in patterns:
                        if re.search(pattern, prose, re.IGNORECASE | re.DOTALL):
                            raise ValueError(
                                f"{locale}:{event_id}.{surface} {label}: {pattern!r}")

    # Countdown cannot universalize one route's record or unbound cast.
    for locale, event, forbidden in (
        ("ko", ko_events["arc_final_countdown"],
         ("227", "상철", "현수", "민서")),
        ("en", en_events["arc_final_countdown"],
         ("227", "Sangchul", "Hyunsu", "Minseo")),
    ):
        descriptions = [str(event.get("description", ""))]
        descriptions.extend(str(value) for value in (
            event.get("description_if_moral") or {}).values())
        description_copy = "\n".join(descriptions).lower()
        for token in forbidden:
            if token.lower() in description_copy:
                raise ValueError(
                    f"{locale}:countdown invented a universal record/person: {token!r}")


def _validate_finale_choice_and_chain_contract(
        ko_events: dict[str, dict[str, Any]],
        en_events: dict[str, dict[str, Any]]) -> None:
    expected_ko = {
        "arc_pre_ending_summit": (
            ("연락처에서 아버지의 이름을 연다", {"mental": 5, "tint": 6},
             ["arc_pre_ending_summit_seen"], ""),
            ("혼자 강남대로를 천천히 걷는다", {"mental": 3, "health": -1, "tint": 2},
             ["arc_pre_ending_summit_seen"], ""),
        ),
        "arc_final_countdown": (
            ("마지막 줄에 내 이름만 쓴다. 선택의 책임까지.",
             {"mental": 4, "intelligence": 2, "tint": 1},
             ["arc_final_countdown_seen", "final_signature_owned"], "arc_final_week"),
            ("빌려온 이름까지 계산한다. 목표를 위해 한 번 더.",
             {"investment_skill": 2, "mental": -4, "tint": -2},
             ["arc_final_countdown_seen", "final_signature_collateral"], "arc_final_week"),
            ("나를 불러 준 이름들을 적는다. 사람부터.",
             {"mental": 6, "tint": 3},
             ["arc_final_countdown_seen", "final_signature_people"], "arc_final_week"),
        ),
        "arc_final_week": (
            ("다섯 해 전의 내가 지금의 나에게 ‘잘했다’고 말하는 장면을 떠올리고, 그 사람에게 다음 주 밥을 제안한다",
             {"mental": 15, "health": 5, "tint": 5},
             ["arc_final_week_seen", "final_week_self_approval"], ""),
            ("다음 주를 부탁하기 전에, 미뤄 둔 사과를 먼저 보낸다",
             {"intelligence": 3, "tint": -1}, ["arc_final_week_seen"], ""),
            ("포기하지 않은 것이 다행이라고 스스로 답하고, 오늘 필요한 거리와 다음 연락 시각을 보낸다",
             {"mental": 10, "health": 3, "tint": 4},
             ["arc_final_week_seen", "final_week_gratitude"], ""),
        ),
    }
    expected_en = {
        "arc_pre_ending_summit": (
            "Open Father's name in his contacts",
            "Walk Gangnam-daero alone, slowly",
        ),
        "arc_final_countdown": (
            "Sign only his own name, including responsibility for every choice.",
            "Price even the names he borrowed. Push once more for the goal.",
            "Write the names of the people who called him back to himself.",
        ),
        "arc_final_week": (
            "Imagine his five-years-ago self telling him, ‘You did well,’ then suggest a meal next week",
            "Send the delayed apology before asking for next week",
            "Tell himself he is glad he did not give up, then send the distance he needs and the next contact time",
        ),
    }
    for event_id, contracts in expected_ko.items():
        choices = ko_events[event_id].get("choices") or []
        if len(choices) != len(contracts):
            raise ValueError(f"{event_id}: finale choice count changed")
        for index, (text, effects, flags, follow_up) in enumerate(contracts):
            choice = choices[index]
            if choice.get("text") != text \
                    or choice.get("effects") != effects \
                    or choice.get("flags") != flags \
                    or str(choice.get("follow_up_event", "")) != follow_up:
                raise ValueError(
                    f"{event_id}[{index}]: choice text/effects/flags/follow-up changed")
    for event_id, texts in expected_en.items():
        actual = tuple(str(choice.get("text", "")) for choice in (
            en_events[event_id].get("choices") or []))
        if actual != texts:
            raise ValueError(f"{event_id}: English finale choice order changed")

    paths = walk_paths(ko_events, "arc_final_countdown")
    expected_path = ("arc_final_countdown", "arc_final_week")
    if len(paths) != 9 or {path.event_ids for path in paths} != {expected_path}:
        raise ValueError(
            "finale chain paths changed: arc_final_countdown must flow through "
            "arc_final_week for all 3x3 choices")


def validate_finale_function_contracts(
        ko_events: dict[str, dict[str, Any]],
        en_events: dict[str, dict[str, Any]]) -> None:
    """Validate finale functions without treating paragraph counts as dramatic beats."""
    _validate_finale_shape_and_parity(ko_events, en_events)
    _validate_finale_choice_and_chain_contract(ko_events, en_events)
    _validate_finale_meanings(ko_events, en_events)
    _validate_finale_false_facts(ko_events, en_events)


def run_finale_mutation_self_test(
        ko_events: dict[str, dict[str, Any]],
        en_events: dict[str, dict[str, Any]]) -> int:
    """Prove semantic, shape, parity, chain, and false-fact mutations fail closed."""
    validate_finale_function_contracts(ko_events, en_events)
    mutations: list[tuple[str, str, Any]] = []

    def add(label: str, expected: str, mutate: Any) -> None:
        mutations.append((label, expected, mutate))

    add(
        "broken countdown follow-up", "choice text/effects/flags/follow-up changed",
        lambda ko, _en: ko["arc_final_countdown"]["choices"][0].pop(
            "follow_up_event", None))
    add(
        "non-prose summit description", "must be a non-empty prose string",
        lambda ko, _en: ko["arc_pre_ending_summit"].__setitem__(
            "description", ["not", "prose"]))
    add(
        "summit carrying cost erased", "summit.carrying_cost",
        lambda ko, _en: ko["arc_pre_ending_summit"].__setitem__(
            "description", str(ko["arc_pre_ending_summit"]["description"])
            .replace("취득세", "세금")))
    add(
        "summit inclusive threshold overstated", "summit.inclusive_threshold",
        lambda ko, _en: ko["arc_pre_ending_summit"].__setitem__(
            "description", str(ko["arc_pre_ending_summit"]["description"])
            .replace("25억원에 닿", "25억원을 넘")))
    add(
        "summit above-goal route erased", "summit.goal_relation_neutral",
        lambda ko, _en: ko["arc_pre_ending_summit"].__setitem__(
            "description", str(ko["arc_pre_ending_summit"]["description"])
            .replace("넘어섰는지", "가까운지")))
    add(
        "countdown starting stake erased", "countdown.start_and_goal",
        lambda ko, _en: ko["arc_final_countdown"].__setitem__(
            "description", str(ko["arc_final_countdown"]["description"])
            .replace("50만원", "시작 금액")))
    add(
        "countdown invented prior scene", "countdown.independent_opening",
        lambda ko, _en: ko["arc_final_countdown"].__setitem__(
            "description", str(ko["arc_final_countdown"]["description"])
            .replace("다섯 해의 마지막 달.", "같은 밤, 같은 방.")))
    add(
        "black route collapsed to base", "countdown.black_signature",
        lambda ko, _en: ko["arc_final_countdown"]["description_if_moral"].__setitem__(
            "black", ko["arc_final_countdown"]["description"]))
    add(
        "owned signature collapsed to base", "final_week.owned_signature",
        lambda ko, _en: ko["arc_final_week"]["description_if_known"].__setitem__(
            "final_signature_owned", ko["arc_final_week"]["description"]))
    add(
        "invented 3-billion achievement", "invented 3-billion achievement",
        lambda ko, _en: ko["arc_pre_ending_summit"]["choices"][1].__setitem__(
            "result_text", str(ko["arc_pre_ending_summit"]["choices"][1]["result_text"])
            + "\n\n{name}은 30억원 목표를 달성했다."))
    add(
        "invented reply", "invented reply/recovery",
        lambda _ko, en: en["arc_final_week"]["choices"][0].__setitem__(
            "result_text", str(en["arc_final_week"]["choices"][0]["result_text"])
            + "\n\nA reply came."))
    add(
        "English placeholder drift", "placeholder parity drifted",
        lambda _ko, en: en["arc_final_week"].__setitem__(
            "description", str(en["arc_final_week"]["description"])
            .replace("{name}", "Minjun")))
    add(
        "English choice order drift", "English finale choice order changed",
        lambda _ko, en: en["arc_final_week"]["choices"].__setitem__(
            slice(0, 2), list(reversed(en["arc_final_week"]["choices"][:2]))))

    def duplicate_countdown_panel(ko: dict[str, dict[str, Any]], _en: Any) -> None:
        event = ko["arc_final_countdown"]
        first = _paragraphs(event["description"])[0]
        event["description"] = str(event["description"]) + "\n\n" + first

    add("duplicate prose filler", "repeats an identical prose panel", duplicate_countdown_panel)
    add(
        "apology result replaced with meal result", "final_week.apology_result",
        lambda ko, _en: ko["arc_final_week"]["choices"][1].__setitem__(
            "result_text", ko["arc_final_week"]["choices"][0]["result_text"]))
    add(
        "self-approval receipt erased", "final_week.meal_result",
        lambda ko, _en: ko["arc_final_week"]["choices"][0].__setitem__(
            "result_text", str(ko["arc_final_week"]["choices"][0]["result_text"])
            .replace("잘했다", "여기까지 왔다")))
    add(
        "gratitude receipt erased", "final_week.distance_result",
        lambda ko, _en: ko["arc_final_week"]["choices"][2].__setitem__(
            "result_text", str(ko["arc_final_week"]["choices"][2]["result_text"])
            .replace("포기하지", "멈추지")))
    add(
        "moral variant key removed", "description_if_moral keys changed",
        lambda ko, _en: ko["arc_final_countdown"]["description_if_moral"].pop(
            "white", None))

    failures: list[str] = []
    for label, expected, mutate in mutations:
        changed_ko = copy.deepcopy(ko_events)
        changed_en = copy.deepcopy(en_events)
        mutate(changed_ko, changed_en)
        try:
            validate_finale_function_contracts(changed_ko, changed_en)
        except ValueError as exc:
            if expected not in str(exc):
                failures.append(
                    f"{label}: rejected for {exc!s}, expected marker {expected!r}")
        else:
            failures.append(f"{label}: mutation was not rejected")
    if failures:
        raise ValueError("finale mutation self-test failed:\n- " + "\n- ".join(failures))
    return len(mutations)


def print_finale_observations(events: dict[str, dict[str, Any]], locale: str) -> None:
    """Report layout measurements; none of these values determine acceptance."""
    for event_id in FINALE_IDS:
        event = events[event_id]
        descriptions: list[tuple[str, int]] = [
            ("description", paragraph_count(event.get("description"))),
        ]
        for field in ("description_orthodox", "description_unorthodox"):
            if field in event:
                descriptions.append((field, paragraph_count(event[field])))
        for field in ("description_if_moral", "description_if_known"):
            for key, prose in (event.get(field) or {}).items():
                if field == "description_if_known" and key not in FINALE_SIGNATURES:
                    continue
                descriptions.append((f"{field}.{key}", paragraph_count(prose)))
        choices = event.get("choices") or []
        result_panels = [paragraph_count(choice.get("result_text")) for choice in choices]
        memory_count = len(event.get("description_memory_if_known") or {})
        rendered_descriptions = ",".join(
            f"{field}:{count}" for field, count in descriptions)
        rendered_results = ",".join(str(count) for count in result_panels) or "0"
        print(
            "FINALE_SCENE_OBSERVATION "
            f"locale={locale} event={event_id} descriptions={rendered_descriptions} "
            f"choices={len(choices)} result_panels={rendered_results} "
            f"memory_inserts={memory_count} acceptance=semantic_only"
        )
    paths = walk_paths(events, "arc_final_countdown")
    panel_counts = [path.panels for path in paths]
    terminals = ",".join(sorted({path.event_ids[-1] for path in paths}))
    print(
        "FINALE_CHAIN_OBSERVATION "
        f"locale={locale} root=arc_final_countdown terminals={terminals} "
        f"paths={len(paths)} links={span(min(len(path.event_ids) for path in paths), max(len(path.event_ids) for path in paths))} "
        f"panels={span(min(panel_counts), max(panel_counts))} acceptance=semantic_only"
    )


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
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()

    ko_events = load_events(EVENTS_KO)
    en_events = load_events(EVENTS_EN)
    if args.self_test:
        mutation_count = run_finale_mutation_self_test(ko_events, en_events)
        print(f"FINALE_FUNCTION_SELF_TEST_OK mutations={mutation_count}")
        return 0
    validate_season_peak_contracts(ko_events)
    validate_daeun_first_night_contract(ko_events)
    validate_wedding_night_contracts(ko_events)
    validate_first_kiss_contracts(ko_events)
    validate_home_peak_contracts(ko_events)
    validate_jaehyuk_contracts(ko_events)
    validate_daeun_proposal_contract(ko_events)
    validate_daeun_wedding_contract(ko_events)
    validate_jiyeon_wedding_gap_contract(ko_events)
    validate_sangchul_first_meeting_contract(ko_events)
    validate_sangchul_deduction_contract(ko_events)
    validate_sangchul_casino_contract(ko_events)
    validate_hyunsu_reunion_contract(ko_events)
    validate_sangchul_confrontation_contract(ko_events)
    validate_father_hospital_contract(ko_events)
    validate_father_passing_contract(ko_events)
    validate_breakup_peak_contracts(ko_events)
    validate_jiyeon_marriage_routing_contract()
    validate_review_appendix_contracts(ko_events, en_events)
    validate_finale_function_contracts(ko_events, en_events)
    distributed_metrics = validate_distributed_relationship_bill(
        ko_events, en_events
    )
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
        print_finale_observations(ko_events, "ko")
        print_finale_observations(en_events, "en")
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
    print(
        "DISTRIBUTED_PEAK_AUDIT root=arc_36_trust_crack "
        f"consequence_week={distributed_metrics['consequence_week']} "
        f"variants={distributed_metrics['variants']} "
        f"target_pairs={distributed_metrics['target_pairs']} "
        f"immediate_bypass={distributed_metrics['immediate_bypass']} "
        f"legacy_fallback={distributed_metrics['legacy_fallback']} "
        f"father_active_guards={distributed_metrics['father_active_guards']}"
    )

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
