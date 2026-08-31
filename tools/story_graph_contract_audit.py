#!/usr/bin/env python3
"""Audit ORDER-143 cross-month story ownership and guarded ingress.

This gate is deliberately structural. It proves that raw follow-ups cannot
bypass the typed scheduler and that protected same-scene closures still exist;
it does not replace a normal-speed Godot playtest.
"""

from __future__ import annotations

import argparse
import copy
import glob
import hashlib
import json
import os
import sys
from dataclasses import dataclass
from typing import Any, Callable


ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CONTRACT_PATH = os.path.join(ROOT, "content", "meta", "story_graph_contract.json")
MAP_PATH = os.path.join(ROOT, "content", "meta", "story_map.json")
RULES_PATH = os.path.join(ROOT, "content", "meta", "story_rules.json")
LIFECYCLE_PATH = os.path.join(ROOT, "content", "meta", "event_lifecycle.json")
MAIN_PATH = os.path.join(ROOT, "scenes", "MainGame.gd")

EXPECTED_OVERLAP_IDS = {
    "m08_goodbye_to_new_life",
    "m13_year_mark_to_money",
    "m13_money_to_m14_network",
    "m20_doors_to_m23_parents",
    "m22_daeun_to_m15_medication",
    "m15_medication_to_m22_jiyeon",
    "m33_truth_table_chain",
    "m49_reckoning_to_final_year",
}
EXPECTED_SCOPE = {
    "month_range": [8, 50],
    "owned_months": [8, 10, 13, 14, 15, 20, 22, 23, 24, 33, 34, 49, 50],
    "public_demo_months": [1, 6],
    "weeks_per_month": 4,
    "scheduler": "scenes/MainGame.gd::_story_graph_contract_event_id",
}
EXPECTED_OVERLAP_ROWS = {
    "m08_goodbye_to_new_life": {
        "id": "m08_goodbye_to_new_life",
        "source": "arc_goshiwon_goodbye",
        "target": "arc_housing_new_life",
        "class": "same_scene_closure",
        "raw_follow_up": "required",
        "source_owner": {
            "mode": "dynamic_housing_transition",
            "requires_housing_not": "goshiwon",
        },
        "target_owner": {"mode": "same_scene_closure"},
        "recovery_window": {
            "weeks": [25, 240],
            "label": "all_valid_post_demo_turns",
        },
        "recovery": "source_seen_target_missing_any_post_demo_turn",
        "later_map_root_forbidden": True,
    },
    "m13_year_mark_to_money": {
        "id": "m13_year_mark_to_money",
        "source": "arc_year_one_mark",
        "target": "arc_34_money_attracts_money",
        "class": "same_scene_closure",
        "raw_follow_up": "required",
        "source_owner": {"month": 13, "weeks": [49, 52]},
        "target_owner": {"month": 13, "weeks": [49, 52]},
        "recovery": "source_seen_target_missing_same_owner_window",
        "later_map_root_forbidden": True,
    },
    "m13_money_to_m14_network": {
        "id": "m13_money_to_m14_network",
        "source": "arc_34_money_attracts_money",
        "target": "arc_sangchul_03_network",
        "class": "scheduled_guarded",
        "raw_follow_up": "forbidden",
        "source_owner": {"month": 13, "weeks": [49, 52]},
        "target_owner": {"month": 14, "weeks": [53, 56]},
        "requires_flags": ["arc_34_money_attracts_seen", "arc_sangchul_02_seen"],
        "forbids_flags": ["arc_sangchul_03_seen", "arc_y2_bank_limit_review_seen"],
        "requires": [
            {"path": "player.total_asset_value", "op": "gte", "value": 1000000}
        ],
        "fallback": "arc_y2_bank_limit_review",
        "fallback_forbids_flags": ["arc_sangchul_03_seen"],
        "recovery": "none_after_target_window",
    },
    "m20_doors_to_m23_parents": {
        "id": "m20_doors_to_m23_parents",
        "source": "arc_34_doors_open",
        "target": "arc_34_parents_visit",
        "class": "separated_months",
        "raw_follow_up": "forbidden",
        "source_owner": {"month": 20, "weeks": [77, 80]},
        "target_owner": {"month": 23, "weeks": [89, 92]},
        "requires_flags": ["arc_father_02_done", "arc_father_medication_seen"],
        "forbids_flags": ["arc_34_parents_visit_seen", "arc_father_03_seen", "father_passed"],
        "recovery": "none_after_target_window",
    },
    "m22_daeun_to_m15_medication": {
        "id": "m22_daeun_to_m15_medication",
        "source": "arc_daeun_03_fork",
        "target": "arc_father_medication",
        "class": "temporal_inversion_removed",
        "raw_follow_up": "forbidden",
        "source_owner": {"month": 22, "weeks": [85, 88]},
        "target_owner": {"month": 15, "weeks": [57, 60]},
        "requires_flags": ["arc_father_02_done"],
        "forbids_flags": ["arc_father_medication_seen", "father_passed"],
        "recovery": "none_after_target_window",
    },
    "m15_medication_to_m22_jiyeon": {
        "id": "m15_medication_to_m22_jiyeon",
        "source": "arc_father_medication",
        "target": "arc_jiyeon_03_offer",
        "class": "separated_months",
        "raw_follow_up": "forbidden",
        "source_owner": {"month": 15, "weeks": [57, 60]},
        "target_owner": {"month": 22, "weeks": [85, 88]},
        "requires_flags": ["arc_jiyeon_store_seen"],
        "forbids_flags": ["arc_jiyeon_offer_seen"],
        "selector_priority": [
            "arc_daeun_03_fork",
            "arc_jiyeon_03_offer",
            "arc_y2_relationship_fork_unattached",
        ],
        "recovery": "none_after_target_window",
    },
    "m33_truth_table_chain": {
        "id": "m33_truth_table_chain",
        "source": "arc_sangchul_confrontation",
        "targets": [
            "arc_sangchul_buried_silence",
            "arc_sangchul_stairwell",
            "arc_sangchul_reckoning",
        ],
        "terminal_target": "arc_sangchul_reckoning",
        "class": "same_location_table_chain",
        "raw_follow_up": "required",
        "source_owner": {"month": 33, "weeks": [129, 132]},
        "target_owner": {"month": 33, "weeks": [129, 132]},
        "scene_location": "cafe",
        "optional_prelude": "arc_sangchul_card_at_confrontation",
        "delayed_aftermath": {
            "month": 34,
            "weeks": [133, 136],
            "root": "arc_y3_cost_of_knowing",
            "requires_any_flags": [
                "arc_sangchul_reckoning_seen",
                "sangchul_truth_buried",
                "sangchul_quietly_distanced",
            ],
        },
        "recovery": "terminal_flags_are_authoritative",
    },
    "m49_reckoning_to_final_year": {
        "id": "m49_reckoning_to_final_year",
        "source": "arc_37_reckoning",
        "target": "arc_final_year_start",
        "class": "same_scene_closure",
        "raw_follow_up": "required",
        "source_owner": {"month": 49, "weeks": [193, 196]},
        "target_owner": {"month": 49, "weeks": [193, 196]},
        "recovery": "source_seen_target_missing_same_owner_window",
        "late_source_recovery": {
            "weeks": [197, 208],
            "requires_absent_flags": [
                "arc_37_reckoning_seen", "arc_final_year_start_seen",
            ],
            "claims_ready_deferred_event": "arc_37_reckoning",
            "fallback_when_deferred_absent": "arc_37_reckoning",
            "same_scene_target": "arc_final_year_start",
            "interrupted_target_recovery": True,
        },
        "later_map_root_forbidden": True,
    },
}
EXPECTED_SAME_SCENE_RECOVERIES = [
    {
        "id": "m22_daeun_fork_receipt",
        "source": "arc_daeun_03_fork",
        "source_owner": {"month": 22, "weeks": [85, 88]},
        "requires_source_flag": "arc_daeun_fork_seen",
        "source_missing_branch_policy": "fail_closed",
        "receipt_flag": "arc_daeun_fork_receipt_seen",
        "branches": [
            {
                "requires_flag": "daeun_chose_her",
                "forbids_flag": "daeun_let_her_go",
                "target": "arc_daeun_03_fork_hold_receipt",
            },
            {
                "requires_flag": "daeun_let_her_go",
                "forbids_flag": "daeun_chose_her",
                "target": "arc_daeun_03_fork_release_receipt",
            },
        ],
        "recovery": "source_branch_target_missing_same_owner_window",
    },
    {
        "id": "m24_sangchul_mirror_receipt",
        "source": "arc_sangchul_mirror",
        "source_owner": {"month": 24, "weeks": [93, 93]},
        "target": "arc_sangchul_mirror_receipt",
        "receipt_flag": "arc_sangchul_mirror_receipt_seen",
        "branch_flags": [
            "sangchul_mirror_hospital_face_up",
            "sangchul_mirror_deal_face_up",
        ],
        "recovery_window": {"weeks": [94, 95]},
        "recovery": "source_seen_receipt_and_branch_missing_recovery_window",
    },
]
EXPECTED_FORBIDDEN_RAW = {
    "arc_34_money_attracts_money->arc_sangchul_03_network",
    "arc_34_doors_open->arc_34_parents_visit",
    "arc_daeun_03_fork->arc_father_medication",
    "arc_father_medication->arc_jiyeon_03_offer",
    "arc_sangchul_mirror->arc_career_ceiling",
    "arc_career_ceiling->arc_father_04_visit",
}
EXPECTED_REQUIRED_RAW = {
    "arc_goshiwon_goodbye->arc_housing_new_life",
    "arc_year_one_mark->arc_34_money_attracts_money",
    "arc_34_parents_visit->arc_father_03_hospital",
    "arc_daeun_03_fork->arc_daeun_03_fork_hold_receipt",
    "arc_daeun_03_fork->arc_daeun_03_fork_release_receipt",
    "arc_sangchul_mirror->arc_sangchul_mirror_receipt",
    "arc_sangchul_card_at_confrontation->arc_sangchul_confrontation",
    "arc_sangchul_confrontation->arc_sangchul_reckoning",
    "arc_sangchul_confrontation->arc_sangchul_buried_silence",
    "arc_sangchul_confrontation->arc_sangchul_stairwell",
    "arc_sangchul_buried_silence->arc_sangchul_reckoning",
    "arc_sangchul_stairwell->arc_sangchul_reckoning",
    "arc_37_reckoning->arc_final_year_start",
}
M33_IDS = (
    "arc_sangchul_confrontation",
    "arc_sangchul_buried_silence",
    "arc_sangchul_stairwell",
    "arc_sangchul_reckoning",
)
CHOICE_TOPOLOGY_KEYS = (
    "effects",
    "cast_effects",
    "flags",
    "follow_up_event",
    "deferred_follow_up",
    "deferred_delay",
)


def load_json(path: str) -> Any:
    with open(path, encoding="utf-8") as handle:
        return json.load(handle)


def canonical_bytes(value: Any) -> bytes:
    return json.dumps(
        value, ensure_ascii=False, sort_keys=True, separators=(",", ":")
    ).encode("utf-8")


def sha256(value: bytes) -> str:
    return hashlib.sha256(value).hexdigest()


def event_index(folder: str) -> dict[str, dict[str, Any]]:
    events: dict[str, dict[str, Any]] = {}
    for path in sorted(glob.glob(os.path.join(ROOT, folder, "*.json"))):
        data = load_json(path)
        if not isinstance(data, list):
            continue
        for event in data:
            if not isinstance(event, dict) or not str(event.get("id", "")):
                continue
            event_id = str(event["id"])
            if event_id in events:
                raise RuntimeError(f"duplicate event id: {event_id}")
            events[event_id] = event
    return events


def raw_edges(events: dict[str, dict[str, Any]]) -> set[str]:
    edges: set[str] = set()
    for event_id, event in events.items():
        choices = event.get("choices", [])
        if not isinstance(choices, list):
            continue
        for choice in choices:
            if not isinstance(choice, dict):
                continue
            target = str(choice.get("follow_up_event", "")).strip()
            if target:
                edges.add(f"{event_id}->{target}")
    return edges


def month(story_map: dict[str, Any], number: int) -> dict[str, Any]:
    for chapter in story_map.get("chapters", []):
        for row in chapter.get("months", []):
            if int(row.get("month", 0)) == number:
                return row
    raise KeyError(f"missing M{number:02}")


def roots_for_month(story_map: dict[str, Any], number: int) -> list[str]:
    roots: list[str] = []
    for beat in month(story_map, number).get("beats", []):
        roots.append(str(beat.get("root", "")))
        coverage = beat.get("coverage", {})
        if isinstance(coverage, dict):
            for fallback in coverage.get("fallbacks", []):
                if isinstance(fallback, dict):
                    roots.append(str(fallback.get("root", "")))
    return roots


def choice_topology(event: dict[str, Any]) -> list[dict[str, Any]]:
    output: list[dict[str, Any]] = []
    for raw_choice in event.get("choices", []):
        choice = raw_choice if isinstance(raw_choice, dict) else {}
        output.append({key: choice[key] for key in CHOICE_TOPOLOGY_KEYS if key in choice})
    return output


@dataclass
class Inputs:
    contract: dict[str, Any]
    story_map: dict[str, Any]
    rules: dict[str, Any]
    lifecycle: dict[str, Any]
    events_ko: dict[str, dict[str, Any]]
    events_en: dict[str, dict[str, Any]]
    fixture: dict[str, Any]
    fixture_bytes: bytes
    main_source: str


def load_inputs() -> Inputs:
    contract = load_json(CONTRACT_PATH)
    fixture_path = os.path.join(ROOT, str(contract["demo_protection"]["fixture"]))
    fixture_bytes = open(fixture_path, "rb").read()
    return Inputs(
        contract=contract,
        story_map=load_json(MAP_PATH),
        rules=load_json(RULES_PATH),
        lifecycle=load_json(LIFECYCLE_PATH),
        events_ko=event_index("content/events"),
        events_en=event_index("content/events_en"),
        fixture=json.loads(fixture_bytes),
        fixture_bytes=fixture_bytes,
        main_source=open(MAIN_PATH, encoding="utf-8").read(),
    )


def validate(data: Inputs) -> list[str]:
    errors: list[str] = []
    contract = data.contract
    if contract.get("schema_version") != 1:
        errors.append("story_graph_contract.schema_version must be 1")
    scope = contract.get("scope", {})
    if scope != EXPECTED_SCOPE:
        errors.append(f"story graph scope drifted: {scope}")

    overlaps = contract.get("overlap_edges", [])
    overlap_ids = {
        str(row.get("id", "")) for row in overlaps if isinstance(row, dict)
    }
    if overlap_ids != EXPECTED_OVERLAP_IDS or len(overlaps) != 8:
        errors.append(f"overlap edge identity drifted: {sorted(overlap_ids)}")
    overlap_rows = {
        str(row.get("id", "")): row for row in overlaps if isinstance(row, dict)
    }
    for overlap_id, expected_row in EXPECTED_OVERLAP_ROWS.items():
        if overlap_rows.get(overlap_id) != expected_row:
            errors.append(f"overlap edge contract drifted: {overlap_id}")
    if contract.get("same_scene_recoveries") != EXPECTED_SAME_SCENE_RECOVERIES:
        errors.append("same-scene receipt recovery contract drifted")
    raw_policy = contract.get("raw_edge_policy", {})
    forbidden = set(raw_policy.get("forbidden", []))
    required = set(raw_policy.get("required", []))
    if forbidden != EXPECTED_FORBIDDEN_RAW:
        errors.append(f"forbidden raw-edge policy drifted: {sorted(forbidden)}")
    if required != EXPECTED_REQUIRED_RAW:
        errors.append(f"required raw-edge policy drifted: {sorted(required)}")

    actual_raw = raw_edges(data.events_ko)
    leaked = forbidden & actual_raw
    missing = required - actual_raw
    if leaked:
        errors.append(f"guard-bypassing raw edges restored: {sorted(leaked)}")
    if missing:
        errors.append(f"authored same-scene closures missing: {sorted(missing)}")

    daeun_receipt_flag = "arc_daeun_fork_receipt_seen"
    daeun_receipt_ids = (
        "arc_daeun_03_fork_hold_receipt",
        "arc_daeun_03_fork_release_receipt",
    )
    for event_id in daeun_receipt_ids:
        event = data.events_ko.get(event_id, {})
        choices = event.get("choices", [])
        if len(choices) != 2 or any(
                daeun_receipt_flag not in choice.get("flags", [])
                for choice in choices if isinstance(choice, dict)):
            errors.append(f"Daeun receipt lacks durable completion flag: {event_id}")
        legacy = data.rules.get("events", {}).get(event_id, {}).get(
            "logic", {}).get("legacy", {})
        expected_branch = "daeun_chose_her" if event_id.endswith(
            "hold_receipt") else "daeun_let_her_go"
        opposite_branch = "daeun_let_her_go" if expected_branch == \
            "daeun_chose_her" else "daeun_chose_her"
        if legacy.get("requires_flags") != [
                "arc_daeun_fork_seen", expected_branch] \
                or set(legacy.get("forbids_flags", [])) != {
                    opposite_branch, daeun_receipt_flag,
                } \
                or legacy.get("produces_all") != [daeun_receipt_flag]:
            errors.append(f"Daeun receipt rule contract drifted: {event_id}")

    mirror_receipt_flag = "arc_sangchul_mirror_receipt_seen"
    mirror_branch_flags = [
        "sangchul_mirror_hospital_face_up",
        "sangchul_mirror_deal_face_up",
    ]
    mirror_receipt = data.events_ko.get("arc_sangchul_mirror_receipt", {})
    mirror_choices = mirror_receipt.get("choices", [])
    if len(mirror_choices) != 2 or any(
            set(choice.get("flags", [])) != {
                mirror_receipt_flag, mirror_branch_flags[index],
            }
            for index, choice in enumerate(mirror_choices)
            if isinstance(choice, dict)):
        errors.append("Sangchul mirror receipt lacks exact durable branch flags")
    mirror_legacy = data.rules.get("events", {}).get(
        "arc_sangchul_mirror_receipt", {}).get(
        "logic", {}).get("legacy", {})
    if mirror_legacy.get("requires_flags") != ["arc_sangchul_mirror_seen"] \
            or set(mirror_legacy.get("forbids_flags", [])) != {
                mirror_receipt_flag, *mirror_branch_flags,
            } \
            or mirror_legacy.get("produces_all") != [mirror_receipt_flag] \
            or mirror_legacy.get("produces_any") != mirror_branch_flags:
        errors.append("Sangchul mirror receipt rule contract drifted")

    # Public M01-M06 protection uses semantic event slices rather than whole
    # source-file hashes, so legitimate M08+ edits in a shared file are allowed.
    demo = contract.get("demo_protection", {})
    if sha256(data.fixture_bytes) != demo.get("fixture_sha256"):
        errors.append("story_demo_rc fixture bytes drifted")
    subject = data.fixture.get("subject", {})
    for key in ("profile", "scope", "source_tree", "build_id"):
        if subject.get(key) != demo.get(key):
            errors.append(f"story_demo_rc subject {key} drifted")
    topology = {
        "start_contract": data.fixture.get("start_contract"),
        "nodes": data.fixture.get("nodes"),
        "synthetic_events": data.fixture.get("synthetic_events"),
    }
    if sha256(canonical_bytes(topology)) != demo.get("topology_sha256"):
        errors.append("story_demo_rc node topology drifted")
    refs: set[tuple[str, str]] = set()
    for row in list(data.fixture.get("nodes", [])) + list(
        data.fixture.get("synthetic_events", [])
    ):
        source = row.get("source", {}) if isinstance(row, dict) else {}
        refs.add((str(source.get("path", "")), str(source.get("event_id", ""))))
    semantic_rows: list[dict[str, Any]] = []
    for path, event_id in sorted(refs):
        event = data.events_ko.get(event_id)
        if event is None:
            errors.append(f"demo source event missing: {path}#{event_id}")
            continue
        semantic_rows.append({"path": path, "event_id": event_id, "event": event})
    if sha256(canonical_bytes(semantic_rows)) != demo.get(
        "source_event_semantics_sha256"
    ):
        errors.append("M01-M06 source event semantics drifted")
    demo_months = [month(data.story_map, number) for number in range(1, 7)]
    if sha256(canonical_bytes(demo_months)) != demo.get("story_map_m01_m06_sha256"):
        errors.append("M01-M06 story-map product graph drifted")

    # Canonical map ownership.
    expected_roots = {
        10: {"arc_y1_new_room_first_month"},
        14: {"arc_sangchul_03_network", "arc_y2_bank_limit_review"},
        20: {"arc_34_doors_open"},
        22: {
            "arc_daeun_03_fork",
            "arc_jiyeon_03_offer",
            "arc_y2_relationship_fork_unattached",
        },
        23: {"arc_34_parents_visit"},
        24: {"arc_sangchul_mirror", "arc_career_ceiling", "arc_father_04_visit", "arc_year2_close"},
        33: {"arc_sangchul_confrontation"},
        34: {"arc_y3_cost_of_knowing"},
    }
    for number, expected in expected_roots.items():
        actual = set(roots_for_month(data.story_map, number))
        if not expected <= actual:
            errors.append(f"M{number:02} owner roots missing: {sorted(expected - actual)}")
    if "arc_housing_new_life" in roots_for_month(data.story_map, 10):
        errors.append("M10 replays the M08 move-night closure")
    if "arc_final_year_start" in roots_for_month(data.story_map, 50):
        errors.append("M50 replays the M49 final-year closure")
    m23_beats = {str(row.get("root", "")): row for row in month(data.story_map, 23)["beats"]}
    m20_beat = month(data.story_map, 20)["beats"][0]
    m20_presentation = data.rules.get("events", {}).get(
        "arc_34_doors_open", {}).get("presentation", {})
    if m20_beat.get("channel") != "internal" \
            or m20_beat.get("cast") != ["player"] \
            or "coverage" in m20_beat \
            or m20_presentation.get("channel") != "internal" \
            or m20_presentation.get("participants") != ["player"]:
        errors.append("M20 public briefing map invents a route actor or channel")
    if m23_beats.get("arc_34_parents_visit", {}).get("cast") != [
        "player", "father", "mother"
    ]:
        errors.append("M23 parents visit omits a present table participant")
    parent_event = data.events_ko.get("arc_34_parents_visit", {})
    parent_presentation = data.rules.get("events", {}).get(
        "arc_34_parents_visit", {}).get(
        "presentation", {})
    if parent_event.get("background") != "restaurant" \
            or parent_presentation.get("scene_location") != "restaurant":
        errors.append("M23 parents visit base surface is not the station restaurant")
    parent_logic = data.rules.get("events", {}).get(
        "arc_34_parents_visit", {}).get("logic", {})
    parent_prereqs = parent_logic.get("prerequisites", {}).get("all", [])
    parent_seen_blocker = {
        "path": "flags.arc_34_parents_visit_seen", "op": "neq", "value": True,
    }
    if parent_seen_blocker not in parent_prereqs \
            or "arc_father_03_seen" not in parent_logic.get(
                "legacy", {}).get("forbids_flags", []):
        errors.append("M23 inverse and seen blockers are not executable")
    m14 = month(data.story_map, 14)
    fallbacks = m14["beats"][0].get("coverage", {}).get("fallbacks", [])
    bank_rows = [row for row in fallbacks if row.get("root") == "arc_y2_bank_limit_review"]
    if len(bank_rows) != 1 or bank_rows[0].get("cast") != ["player", "banker"]:
        errors.append("M14 route-safe bank consultation mapping drifted")
    m34_beat = month(data.story_map, 34)["beats"][0]
    if "source_month" in m34_beat or "coverage" in m34_beat:
        errors.append("M34 still replays or relocates an M33 terminal branch")

    rules = data.rules.get("events", {})
    transitions = data.rules.get("transition_contracts", {})
    parent_cut = transitions.get("arc_34_parents_visit->arc_father_03_hospital", {})
    if parent_cut.get("mode") != "time_cut" \
            or parent_cut.get("from_locations") != ["restaurant", "current_housing"] \
            or parent_cut.get("arrival_cue_ko") != "부모님이 서울에서 내려간 지 나흘째" \
            or parent_cut.get("arrival_cue_en") != "Four days after his parents returned from Seoul":
        errors.append("M23 parents-to-hospital four-day time cut drifted")
    for event_id in M33_IDS:
        event = data.events_ko.get(event_id, {})
        presentation = rules.get(event_id, {}).get("presentation", {})
        if event.get("background") != "cafe" \
                or presentation.get("scene_location") != "cafe" \
                or presentation.get("participants") != ["player", "sangchul"]:
            errors.append(f"M33 table-chain surface drifted: {event_id}")
    expected_hashes = contract.get("preserved_choice_topology_sha256", {})
    for event_id in M33_IDS:
        actual_hash = sha256(canonical_bytes(choice_topology(data.events_ko[event_id])))
        if actual_hash != expected_hashes.get(event_id):
            errors.append(f"M33 effects/flags/follow-up topology drifted: {event_id}")
    expected_coarse_outputs = {
        ("arc_sangchul_buried_silence", "0"): "refused_to_know",
        ("arc_sangchul_stairwell", "0"): "cut_ties",
        ("arc_sangchul_reckoning", "0"): "confronted",
        ("arc_sangchul_reckoning", "1"): "confronted",
        ("arc_sangchul_reckoning", "2"): "used",
        ("arc_sangchul_reckoning", "3"): "confronted",
    }
    for (event_id, choice_index), expected_value in expected_coarse_outputs.items():
        clauses = rules.get(event_id, {}).get("logic", {}).get(
            "choice_produces", {}).get(choice_index, [])
        if {clause.get("set") for clause in clauses
                if clause.get("fact") == "story.sangchul_truth_resolution"} \
                != {expected_value}:
            errors.append(
                f"M33 coarse truth bridge drifted: {event_id}[{choice_index}]"
            )
    cost_logic = rules.get("arc_y3_cost_of_knowing", {}).get("logic", {})
    terminal_flags = {
        "arc_sangchul_reckoning_seen", "sangchul_truth_buried",
        "sangchul_quietly_distanced",
    }
    if set(cost_logic.get("reads_any_flags", [])) != terminal_flags \
            or cost_logic.get("legacy", {}).get("produces_all") != [
                "arc_y3_cost_of_knowing_seen"]:
        errors.append("M34 cost reader/receipt contract drifted")
    for event_id in (
        "arc_y1_new_room_first_month",
        "arc_y2_bank_limit_review",
        "arc_y2_relationship_fork_unattached",
    ):
        if event_id in set(data.lifecycle.get("author_only_event_ids", [])):
            errors.append(f"activated fallback remains author-only: {event_id}")
    father_logic = rules.get("arc_father_04_visit", {}).get("logic", {})
    if {row.get("is") for row in father_logic.get("requires", [])} != {"hospitalized"}:
        errors.append("father_04_visit lacks hospitalized typed ingress")
    father_prereqs = father_logic.get("prerequisites", {}).get("all", [])
    expected_father_prereqs = {
        tuple(sorted(row.items())) for row in (
            {"path": "turn", "op": "eq", "value": 96},
            {"path": "flags.arc_father_03_seen", "op": "eq", "value": True},
            {"path": "flags.father_passed", "op": "neq", "value": True},
            {"path": "flags.visited_father", "op": "neq", "value": True},
            {"path": "flags.father_visit_deferred", "op": "neq", "value": True},
        )
    }
    if {tuple(sorted(row.items())) for row in father_prereqs} != expected_father_prereqs \
            or set(father_logic.get("legacy", {}).get("forbids_flags", [])) != {
                "father_passed", "visited_father", "father_visit_deferred"
            }:
        errors.append("father-door executable prerequisites drifted")
    father_contract = contract.get("chapter2_boss_chain", {}).get("father_decision", {})
    if father_contract.get("owner_month") != 24 \
            or father_contract.get("weeks") != [96, 96] \
            or father_contract.get("optional_context_flag") != "arc_sangchul_03_seen" \
            or father_contract.get("default_surface") != "route_neutral" \
            or father_contract.get("same_week_closure") != "arc_year2_close":
        errors.append("W96 route-safe father-door ownership drifted")
    father_close_queue = data.main_source[data.main_source.find("func _go_story_mode("):data.main_source.find(
        "func ", data.main_source.find("func _go_story_mode(") + 5
    )]
    for fragment in (
        "GameState.turn == 96",
        'first_event_id == "arc_father_04_visit"',
        'not GameState.flags.get("arc_year2_close_seen", false)',
        'story_queue.append("arc_year2_close")',
        "year_index = 2",
    ):
        if fragment not in father_close_queue:
            errors.append(f"W96 father-to-year-close queue closure drifted: {fragment}")
    father_event = data.events_ko.get("arc_father_04_visit", {})
    if "상철" in str(father_event.get("description", "")) \
            or "arc_sangchul_03_seen" not in father_event.get("description_if_known", {}):
        errors.append("father-door default surface fabricates or loses network context")
    unattached = data.events_ko.get("arc_y2_relationship_fork_unattached", {})
    expected_choice_flags = [
        "y2_lease_renewed_one_year",
        "y2_lease_renewed_six_months",
        "y2_lease_move_out_scheduled",
    ]
    choices = unattached.get("choices", [])
    if len(choices) != 3 or any(
            expected_choice_flags[i] not in choices[i].get("flags", [])
            for i in range(min(3, len(choices)))):
        errors.append("unattached lease choices collapsed to identical state")
    lease_flags = set(expected_choice_flags)
    year2_close = data.events_ko.get("arc_year2_close", {})
    if not lease_flags <= set(year2_close.get("description_if_known", {})) \
            or set(rules.get("arc_year2_close", {}).get(
                "logic", {}).get("reads_any_flags", [])) != lease_flags:
        errors.append("unattached lease state has no Year 2 close reader")
    m24_roots = roots_for_month(data.story_map, 24)
    expected_m24_order = [
        "arc_sangchul_mirror", "arc_career_ceiling",
        "arc_father_04_visit", "arc_year2_close",
    ]
    if [root for root in m24_roots if root in expected_m24_order] != expected_m24_order:
        errors.append("M24 canonical mirror-career-door order drifted")
    mirror = contract.get("chapter2_boss_chain", {}).get("mirror", {})
    career = contract.get("chapter2_boss_chain", {}).get("career", {})
    if {tuple(sorted(row.items())) for row in mirror.get("requires", [])} != {
            tuple(sorted({"path": "cast.sangchul.affinity", "op": "gte", "value": 65}.items()))}:
        errors.append("mirror affinity-65 runtime guard drifted")
    if {tuple(sorted(row.items())) for row in career.get("requires", [])} != {
            tuple(sorted({"path": "player.job.id", "op": "truthy"}.items())),
            tuple(sorted({"path": "player.job.tenure", "op": "gte", "value": 6}.items())),
    }:
        errors.append("career employment/tenure runtime guards drifted")
    mirror_prereqs = rules.get("arc_sangchul_mirror", {}).get(
        "logic", {}).get("prerequisites", {}).get("all", [])
    for blocker in ("father_passed", "arc_sangchul_mirror_seen"):
        if {"path": f"flags.{blocker}", "op": "neq", "value": True} \
                not in mirror_prereqs:
            errors.append(f"mirror executable blocker missing: {blocker}")
    career_prereqs = rules.get("arc_career_ceiling", {}).get(
        "logic", {}).get("prerequisites", {}).get("all", [])
    if {"path": "flags.arc_career_ceiling_seen", "op": "neq", "value": True} \
            not in career_prereqs:
        errors.append("career executable seen blocker is missing")
    network_prereqs = rules.get("arc_sangchul_03_network", {}).get(
        "logic", {}
    ).get("prerequisites", {}).get("all", [])
    if {tuple(sorted(row.items())) for row in network_prereqs if isinstance(row, dict)}.isdisjoint({
        tuple(sorted({"path": "player.total_asset_value", "op": "gte", "value": 1000000}.items()))
    }):
        errors.append("network typed asset threshold is missing")

    # Runtime proof. These clauses are intentionally exact so broad legacy
    # selectors cannot coexist below the typed router.
    source = data.main_source
    helper_start = source.find("func _story_graph_contract_event_id(")
    helper_end = source.find("\nfunc ", helper_start + 5)
    helper = source[helper_start:helper_end] if helper_start >= 0 and helper_end > helper_start else ""
    required_fragments = (
        "if t >= 49 and t <= 52:",
        "if t >= 53 and t <= 56",
        "if t >= 57 and t <= 60",
        "if t >= 77 and t <= 80",
        "if t >= 82 and t <= 88",
        'f.get("arc_34_parents_visit_seen", false)',
        "if t >= 85 and t <= 88:",
        "if t >= 89 and t <= 92",
        "if t == 93",
        "if t >= 94 and t <= 95",
        "if t == 96",
        "if t == 95",
        'f.get("arc_daeun_money_gap_seen", false)',
        "if t == 132",
        "GameState.current_job.is_empty()",
        "not father_is_passed",
        'f.get("sangchul_truth_buried", false)',
        'f.get("sangchul_quietly_distanced", false)',
    )
    for fragment in required_fragments:
        if fragment not in helper:
            errors.append(f"typed scheduler clause missing: {fragment}")
    for fragment in (
        "if t >= 25 and t <= 240",
        'f.get("arc_goshiwon_goodbye_seen", false)',
        'return "arc_housing_new_life"',
        "if t >= 193 and t <= 208",
        "if t >= 197 and t <= 208",
        'not GameState.has_deferred_event("arc_37_reckoning")',
        'return "arc_37_reckoning"',
        'return "arc_final_year_start"',
        'and (chose_daeun or released_daeun):',
        'if f.get("arc_daeun_fork_seen", false) \\\n'
        '\t\t\t\tand not f.get("arc_daeun_fork_receipt_seen", false):',
        'return "arc_daeun_03_fork_hold_receipt"',
        'return "arc_daeun_03_fork_release_receipt"',
        'not f.get("arc_sangchul_mirror_receipt_seen", false)',
        'not f.get("sangchul_mirror_hospital_face_up", false)',
        'not f.get("sangchul_mirror_deal_face_up", false)',
        'return "arc_sangchul_mirror_receipt"',
    ):
        if fragment not in helper:
            errors.append(f"typed same-scene recovery missing: {fragment}")
    if helper.count('return "arc_housing_new_life"') != 1 \
            or helper.count('return "arc_final_year_start"') != 1:
        errors.append("same-scene recovery is duplicated inside the typed router")
    causal_start = source.find("func _route_chapter5_causal_week(")
    causal_end = source.find("\nfunc ", causal_start + 5)
    causal_router = source[causal_start:causal_end] \
        if causal_start >= 0 and causal_end > causal_start else ""
    for fragment in (
        "GameState.turn <= 208",
        'GameState.claim_deferred_event(\n\t\t\t\t"arc_37_reckoning")',
        '["arc_37_reckoning", "arc_final_year_start"]',
    ):
        if fragment not in causal_router:
            errors.append(f"M49 recovery loses causal-route priority: {fragment}")
    for fragment in (
        'job_context["tenure"] = GameState.job_tenure',
        '"sangchul": {"affinity": GameState.get_cast_affinity("sangchul")}',
    ):
        if fragment not in source:
            errors.append(f"story-rule runtime context missing: {fragment}")
    if source.count("if t >= 133 and t <= 136") != 1:
        errors.append("M34 typed aftermath selector is duplicated or missing")
    m34_clause = source[source.find("if t >= 133 and t <= 136"):source.find(
        "if t >= 137", source.find("if t >= 133 and t <= 136")
    )]
    for terminal_flag in (
        "arc_sangchul_reckoning_seen",
        "sangchul_truth_buried",
        "sangchul_quietly_distanced",
    ):
        if terminal_flag not in m34_clause:
            errors.append(f"M34 aftermath lost terminal ingress: {terminal_flag}")
    if helper.count('f.get("arc_34_parents_visit_seen", false)') != 3:
        errors.append("hospital recovery and inverse-safe M23 chain need three exact parent checks")
    inverse_guard = 'not f.get("arc_34_parents_visit_seen", false) \\\n\t\t\t\tand not f.get("arc_father_03_seen", false)'
    if inverse_guard not in helper:
        errors.append("M23 inverse hospital receipt does not fail closed")
    if source.find("var graph_contract_id := _story_graph_contract_event_id(") < 0:
        errors.append("typed story graph router is not called")
    if helper.count('not f.get("arc_year2_close_seen", false)') != 1:
        errors.append("W96 typed owner lost or duplicated the Year 2 close")
    forbidden_legacy_fragments = (
        'if t >= 55 and f.get("arc_sangchul_02_seen", false)',
        'if t >= 58 and not father_is_passed',
        'if t >= 82 and not father_is_passed',
        'if t >= 90 and f.get("arc_father_03_seen", false)',
        'not f.get("arc_jiyeon_offer_seen", false) and t >= 58',
        "if t >= 88 and t <= 108 \\",
        "if t >= 137 and t <= 160 \\",
        "if t >= 74 and t <= 94",
        "if t >= 60 and t <= 70",
    )
    for fragment in forbidden_legacy_fragments:
        if fragment in source:
            errors.append(f"broad legacy selector survived: {fragment}")
    return errors


def run_self_test(base: Inputs) -> tuple[list[str], int]:
    failures: list[str] = []
    cases: list[tuple[str, Callable[[Inputs], None]]] = []

    def case(name: str):
        def register(fn: Callable[[Inputs], None]) -> Callable[[Inputs], None]:
            cases.append((name, fn))
            return fn
        return register

    @case("forbidden_raw_edge")
    def _(data: Inputs) -> None:
        data.events_ko["arc_34_money_attracts_money"]["choices"][0][
            "follow_up_event"
        ] = "arc_sangchul_03_network"

    @case("required_closure_removed")
    def _(data: Inputs) -> None:
        for choice in data.events_ko["arc_year_one_mark"]["choices"]:
            choice.pop("follow_up_event", None)

    @case("demo_node_drift")
    def _(data: Inputs) -> None:
        data.fixture["nodes"][0]["month"] = 2

    @case("demo_map_drift")
    def _(data: Inputs) -> None:
        month(data.story_map, 1)["beats"][0]["root"] = "arc_self_test"

    @case("network_w52_prelaunch")
    def _(data: Inputs) -> None:
        data.main_source = data.main_source.replace(
            "if t >= 53 and t <= 56", "if t >= 52 and t <= 56", 1
        )

    @case("hospital_without_parent_receipt")
    def _(data: Inputs) -> None:
        data.main_source = data.main_source.replace(
            'f.get("arc_34_parents_visit_seen", false)',
            'f.get("arc_34_parents_visit_missing", false)',
            1,
        )

    @case("hospital_inverse_replays_parents")
    def _(data: Inputs) -> None:
        guard = (
            'not f.get("arc_34_parents_visit_seen", false) '
            + "\\\n"
            + '\t\t\t\tand not f.get("arc_father_03_seen", false)'
        )
        data.main_source = data.main_source.replace(
            guard,
            'not f.get("arc_34_parents_visit_seen", false)',
            1,
        )

    @case("parent_result_surface_lost")
    def _(data: Inputs) -> None:
        data.rules["transition_contracts"][
            "arc_34_parents_visit->arc_father_03_hospital"
        ]["from_locations"] = ["current_housing", "current_housing"]

    @case("parent_seen_prerequisite_lost")
    def _(data: Inputs) -> None:
        rows = data.rules["events"]["arc_34_parents_visit"]["logic"][
            "prerequisites"]["all"]
        rows[:] = [
            row for row in rows
            if row.get("path") != "flags.arc_34_parents_visit_seen"
        ]

    @case("m50_final_year_replay")
    def _(data: Inputs) -> None:
        month(data.story_map, 50)["beats"][0]["root"] = "arc_final_year_start"

    @case("m23_mother_omitted")
    def _(data: Inputs) -> None:
        month(data.story_map, 23)["beats"][0]["cast"] = ["player", "father"]

    @case("m33_location_drift")
    def _(data: Inputs) -> None:
        data.events_ko["arc_sangchul_stairwell"]["background"] = "stairwell"

    @case("m33_effect_drift")
    def _(data: Inputs) -> None:
        data.events_ko["arc_sangchul_reckoning"]["choices"][0]["effects"][
            "mental"
        ] = 999

    @case("m33_coarse_truth_bridge_lost")
    def _(data: Inputs) -> None:
        data.rules["events"]["arc_sangchul_reckoning"]["logic"][
            "choice_produces"]["2"].pop()

    @case("m34_terminal_reader_lost")
    def _(data: Inputs) -> None:
        data.rules["events"]["arc_y3_cost_of_knowing"]["logic"][
            "reads_any_flags"].pop()

    @case("activated_fallback_author_only")
    def _(data: Inputs) -> None:
        data.lifecycle.setdefault("author_only_event_ids", []).append(
            "arc_y2_bank_limit_review"
        )

    @case("edge_registry_drop")
    def _(data: Inputs) -> None:
        data.contract["overlap_edges"].pop()

    @case("dynamic_housing_recovery_window_drift")
    def _(data: Inputs) -> None:
        data.contract["overlap_edges"][0]["recovery_window"]["weeks"] = [29, 32]

    @case("daeun_receipt_recovery_contract_drift")
    def _(data: Inputs) -> None:
        data.contract["same_scene_recoveries"][0]["receipt_flag"] = \
            "arc_missing_receipt"

    @case("daeun_receipt_source_guard_lost")
    def _(data: Inputs) -> None:
        data.main_source = data.main_source.replace(
            'if f.get("arc_daeun_fork_seen", false) \\\n'
            '\t\t\t\tand not f.get("arc_daeun_fork_receipt_seen", false):',
            'if not f.get("arc_daeun_fork_receipt_seen", false):', 1)

    @case("daeun_receipt_completion_flag_lost")
    def _(data: Inputs) -> None:
        data.events_ko["arc_daeun_03_fork_hold_receipt"]["choices"][0][
            "flags"].clear()

    @case("mirror_receipt_rule_producer_lost")
    def _(data: Inputs) -> None:
        data.rules["events"]["arc_sangchul_mirror_receipt"]["logic"][
            "legacy"]["produces_all"].clear()

    @case("m49_causal_recovery_priority_lost")
    def _(data: Inputs) -> None:
        data.main_source = data.main_source.replace(
            "GameState.turn <= 208", "GameState.turn <= 196", 1
        )

    @case("scope_month_range_drift")
    def _(data: Inputs) -> None:
        data.contract["scope"]["month_range"] = [8, 49]

    @case("overlap_owner_month_drift")
    def _(data: Inputs) -> None:
        data.contract["overlap_edges"][2]["target_owner"]["month"] = 13

    @case("overlap_guard_drift")
    def _(data: Inputs) -> None:
        data.contract["overlap_edges"][3]["requires_flags"] = [
            "arc_father_02_done"
        ]

    @case("overlap_fallback_drift")
    def _(data: Inputs) -> None:
        data.contract["overlap_edges"][2]["fallback"] = "arc_missing_fallback"

    @case("m34_buried_terminal_lost")
    def _(data: Inputs) -> None:
        marker = "if t >= 133 and t <= 136"
        head, tail = data.main_source.split(marker, 1)
        tail = tail.replace('or f.get("sangchul_truth_buried", false)', "or false", 1)
        data.main_source = head + marker + tail

    @case("m34_distanced_terminal_lost")
    def _(data: Inputs) -> None:
        marker = "if t >= 133 and t <= 136"
        head, tail = data.main_source.split(marker, 1)
        tail = tail.replace(
            'or f.get("sangchul_quietly_distanced", false)', "or false", 1
        )
        data.main_source = head + marker + tail

    @case("m34_reckoning_terminal_lost")
    def _(data: Inputs) -> None:
        marker = "if t >= 133 and t <= 136"
        head, tail = data.main_source.split(marker, 1)
        tail = tail.replace(
            'f.get("arc_sangchul_reckoning_seen", false)', "false", 1
        )
        data.main_source = head + marker + tail

    @case("unattached_choices_same_state")
    def _(data: Inputs) -> None:
        event = data.events_ko["arc_y2_relationship_fork_unattached"]
        event["choices"][1]["flags"] = list(event["choices"][0]["flags"])

    @case("unattached_year_close_reader_lost")
    def _(data: Inputs) -> None:
        data.rules["events"]["arc_year2_close"]["logic"]["reads_any_flags"].pop()

    @case("father_door_returns_to_m23")
    def _(data: Inputs) -> None:
        data.contract["chapter2_boss_chain"]["father_decision"]["weeks"] = [89, 92]

    @case("father_year_close_queue_lost")
    def _(data: Inputs) -> None:
        data.main_source = data.main_source.replace(
            'story_queue.append("arc_year2_close")', "pass # removed", 1
        )

    @case("father_visited_guard_lost")
    def _(data: Inputs) -> None:
        rows = data.rules["events"]["arc_father_04_visit"]["logic"][
            "prerequisites"]["all"]
        rows[:] = [row for row in rows if row.get("path") != "flags.visited_father"]

    @case("story_rule_tenure_context_lost")
    def _(data: Inputs) -> None:
        data.main_source = data.main_source.replace(
            'job_context["tenure"] = GameState.job_tenure', "pass # removed", 1
        )

    @case("mirror_affinity_guard_drift")
    def _(data: Inputs) -> None:
        data.contract["chapter2_boss_chain"]["mirror"]["requires"][0]["value"] = 64

    @case("career_tenure_guard_drift")
    def _(data: Inputs) -> None:
        data.contract["chapter2_boss_chain"]["career"]["requires"].pop()

    @case("mirror_seen_blocker_lost")
    def _(data: Inputs) -> None:
        rows = data.rules["events"]["arc_sangchul_mirror"]["logic"][
            "prerequisites"]["all"]
        rows[:] = [
            row for row in rows
            if row.get("path") != "flags.arc_sangchul_mirror_seen"
        ]

    @case("career_seen_blocker_lost")
    def _(data: Inputs) -> None:
        rows = data.rules["events"]["arc_career_ceiling"]["logic"][
            "prerequisites"]["all"]
        rows[:] = [
            row for row in rows
            if row.get("path") != "flags.arc_career_ceiling_seen"
        ]

    @case("m24_canonical_order_drift")
    def _(data: Inputs) -> None:
        beats = month(data.story_map, 24)["beats"]
        beats[0], beats[2] = beats[2], beats[0]

    baseline_errors = validate(base)
    if baseline_errors:
        failures.append(
            "baseline must pass before self-test: " + "; ".join(baseline_errors[:3])
        )
        return failures, len(cases)
    for name, mutate in cases:
        candidate = copy.deepcopy(base)
        mutate(candidate)
        if not validate(candidate):
            failures.append(f"self-test mutation escaped: {name}")
    return failures, len(cases)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    try:
        inputs = load_inputs()
        errors = validate(inputs)
    except (OSError, KeyError, ValueError, json.JSONDecodeError, RuntimeError) as exc:
        print(f"ERROR story graph audit could not load: {exc}")
        return 1
    if errors:
        for error in errors:
            print(f"ERROR {error}")
        print(f"story graph contract audit: FAIL errors={len(errors)}")
        return 1
    self_cases = 0
    if args.self_test:
        failures, self_cases = run_self_test(inputs)
        if failures:
            for failure in failures:
                print(f"ERROR {failure}")
            print(f"story graph contract self-test: FAIL errors={len(failures)}")
            return 1
    print(
        "story graph contract audit: PASS "
        f"overlaps=8 forbidden_raw={len(EXPECTED_FORBIDDEN_RAW)} "
        f"required_closures={len(EXPECTED_REQUIRED_RAW)} self_tests={self_cases}"
    )
    print("NOTE automated evidence does not close the human playtest gate")
    return 0


if __name__ == "__main__":
    sys.exit(main())
