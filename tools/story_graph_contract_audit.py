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
        "source_owner": {"month": 8, "weeks": [29, 32]},
        "target_owner": {"month": 8, "weeks": [29, 32]},
        "recovery": "source_seen_target_missing_same_owner_window",
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
        "forbids_flags": ["arc_sangchul_03_seen"],
        "requires": [
            {"path": "player.total_asset_value", "op": "gte", "value": 1000000}
        ],
        "fallback": "arc_y2_bank_limit_review",
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
        "forbids_flags": ["arc_34_parents_visit_seen", "father_passed"],
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
        "later_map_root_forbidden": True,
    },
}
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
        23: {"arc_34_parents_visit", "arc_father_04_visit"},
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
    if m23_beats.get("arc_34_parents_visit", {}).get("cast") != [
        "player", "father", "mother"
    ]:
        errors.append("M23 parents visit omits a present table participant")
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
        "if t >= 94 and t <= 96",
        "if t == 95",
        'f.get("arc_daeun_money_gap_seen", false)',
        "if t == 132",
        "GameState.current_job.is_empty()",
        "not father_is_passed",
    )
    for fragment in required_fragments:
        if fragment not in helper:
            errors.append(f"typed scheduler clause missing: {fragment}")
    if helper.count('f.get("arc_34_parents_visit_seen", false)') != 2:
        errors.append("hospital recovery and M23 chain need two exact parent receipts")
    if source.find("var graph_contract_id := _story_graph_contract_event_id(") < 0:
        errors.append("typed story graph router is not called")
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

    @case("activated_fallback_author_only")
    def _(data: Inputs) -> None:
        data.lifecycle.setdefault("author_only_event_ids", []).append(
            "arc_y2_bank_limit_review"
        )

    @case("edge_registry_drop")
    def _(data: Inputs) -> None:
        data.contract["overlap_edges"].pop()

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
