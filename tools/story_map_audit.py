#!/usr/bin/env python3
"""Fast structural audit for the canonical 60-month story map.

The audit checks design contracts, not source-file hashes. It is intentionally
small enough to run while prose, UI, or unrelated runtime code is moving.
"""

from __future__ import annotations

import argparse
import copy
import glob
import json
import os
import re
import sys
from dataclasses import dataclass
from typing import Any, Callable


ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MAP_PATH = os.path.join(ROOT, "content", "meta", "story_map.json")
RULES_PATH = os.path.join(ROOT, "content", "meta", "story_rules.json")
SPINE_PATH = os.path.join(ROOT, "content", "meta", "narrative_spine.json")
EVENTS_KO = os.path.join(ROOT, "content", "events")
EVENTS_EN = os.path.join(ROOT, "content", "events_en")

TOP_KEYS = {
    "schema_version", "scope", "design_targets", "vertical_slices",
    "loop_contract", "commitment_causality", "long_term_decisions",
    "carryover_slots", "chapters",
}
CHAPTER_KEYS = {"chapter", "carryover", "months"}
MONTH_KEYS = {"month", "design_label", "phase", "contract", "commitments", "beats"}
CONTRACT_KEYS = {"pressure", "opportunity", "person_promise", "deadline"}
COMMITMENT_KEYS = {"id", "source", "axis", "label", "due_week", "miss", "after"}
AVAILABILITY_KEYS = {"axis", "values"}
BEAT_KEYS = {
    "id", "kind", "delivery", "work", "root", "rule_status", "intent",
    "scene_id", "channel", "cast", "reads", "writes", "forgone",
}
IO_KEYS = {"memories", "decision", "carryovers"}
COVERAGE_KEYS = {"axis", "base_values", "fallbacks"}
FALLBACK_KEYS = {
    "values", "root", "work", "rule_status", "channel", "cast", "reads", "forgone",
}
FALLBACK_OPTIONAL_KEYS = {
    "role_bindings", "distinct_roles", "coalesce_roles", "actor_outputs", "selector",
}
ROLE_BINDING_KINDS = {"literal", "fact_actor", "receipt_actor", "commitment_actor"}
RECEIPT_SOURCE_TYPES = {"memory", "carryover"}
ACTOR_OUTPUT_POLICIES = {"all_distinct", "coalesced"}
SELECTOR_KEYS = {"selected_all", "selected_none", "availability_values"}
PHASES = {"setup", "escalation", "reversal", "boss"}
KINDS = {"scene", "decision", "consequence", "bridge"}
DELIVERIES = {"stop", "flow"}
WORK_TYPES = {"KEEP", "MOVE", "EXPAND", "NEW"}
RULE_STATUSES = {"mapped", "needs_rule", "planned"}
CHANNELS = {
    "in_person", "internal", "phone", "message", "memory", "mixed",
    "narration", "system",
}
COMMITMENT_SOURCES = {"pressure", "opportunity", "person_promise"}
COMMITMENT_AXES = {"cash", "health", "trust"}
MISSED_RESULTS = {"deferred", "expired"}
RECEIPT_STATES = {"completed", "deferred", "expired"}
EXPECTED_MISS_CONSEQUENCES = {
    "deferred": "returns_once_next_month_as_selectable_debt_then_expires",
    "expired": "specific_path_or_pressure_effect_only_no_global_stack_penalty",
}
CAUSALITY_KEYS = {
    "selection_slots", "selection_record", "receipt_record", "reader_modes",
    "write_order", "generic_reader", "named_readers",
}
GENERIC_READER_KEYS = {
    "source", "states", "completed", "misses", "months", "terminal",
}
TERMINAL_KEYS = {
    "month", "kind", "after_scene", "target", "next_month", "signature_receipt",
}
SIGNATURE_RECEIPT_KEYS = {"commitment_id", "state_to_outcome"}
READER_REF_KEYS = {"kind", "scene_id"}
GATE_READER_KEYS = {"id", "mode", "source", "reader", "effect"}
FOCUS_READER_KEYS = {
    "id", "mode", "sources", "resolve", "fallback_value", "reader", "effect",
}
SELECTED_SOURCE_KEYS = {"kind", "commitment_id", "slot"}
SELECTED_FOCUS_SOURCE_KEYS = SELECTED_SOURCE_KEYS | {"value"}
RECEIPT_SOURCE_KEYS = {"kind", "source_receipt_id", "state"}
RECEIPT_FOCUS_SOURCE_KEYS = RECEIPT_SOURCE_KEYS | {"value"}
EFFECT_KEYS = {
    "delivery": {"kind", "root"},
    "coverage": {"kind", "axis"},
    "outcome": {"kind", "target"},
    "cost": {"kind", "target"},
    "availability": {"kind", "target", "after"},
}
EXPECTED_SELECTION_SLOTS = ["protected", "optional_second"]
EXPECTED_SELECTION_RECORD = {
    "kind": "selected_commitment",
    "commitment_id": "string",
    "slot": ["protected", "optional_second"],
}
EXPECTED_RECEIPT_RECORD = {
    "kind": "commitment_receipt",
    "source_receipt_id": "string",
    "state": ["completed", "deferred", "expired"],
    "resolved_week": "integer",
    "selection_slot": ["protected", "optional_second", None],
    "actors": "object",
}
EXPECTED_READER_MODES = ["gate", "focus"]
EXPECTED_WRITE_ORDER = [
    "selection_saved",
    "selected_readers_dispatched",
    "scene_writes_staged",
    "scene_writes_and_completed_receipts_atomic_commit",
    "resolved_readers_dispatched",
    "month_closed",
]
EXPECTED_VERTICAL_SLICES = {
    "M01": "entry_loop",
    "M35": "cross_chapter_payoff",
    "M55": "ensemble_collision",
}
REQUIRED_COVERAGE_MONTHS = {
    22, 25, 28, 30, 32, 34, 35,
    39, 42, 44, 45, 46, 47,
    51, 52, 54, 55, 56, 57, 58, 59,
}
EXPECTED_RELOCATIONS = {
    "arc_y3_cost_of_knowing": (34, "EXPAND", 35),
    "arc_minjun_first_call": (35, "EXPAND", 33),
    "arc_father_passing": (47, "EXPAND", 44),
    "arc_jaehyuk_mirror": (53, "EXPAND", 15),
}
EXPECTED_CHAPTER5_PRODUCT_MONTHS = {
    "arc_y5_contract_cover_investment": 49,
    "arc_y5_contract_reviewer_delivery_sangchul": 49,
    "arc_y5_final_push_deadline_investment": 50,
    "arc_y5_protection_boundary_daeun": 50,
    "arc_y5_burnout_check_reference": 51,
    "arc_y5_minseo_goal_cost_reference": 51,
    "arc_y5_after_goal_daeun": 51,
    "arc_y5_final_offer": 52,
    "arc_y5_final_offer_reference_delivery": 52,
    "arc_y5_jaehyuk_guarantee_request_reference": 53,
    "arc_y5_jaehyuk_return_call_reference": 53,
    "arc_y5_jaehyuk_father_document_reference": 53,
    "arc_y5_guarantee_protected_show_daeun": 53,
    "arc_y5_jaehyuk_guarantee_decision_reference": 53,
    "arc_sangchul_final_door": 54,
    "arc_y5_sangchul_review_receipt": 54,
    "arc_y5_three_in_room": 55,
    "arc_y5_three_in_room_decision": 55,
    "arc_y5_room_consent_receipt": 55,
    "arc_y5_father_trace_alive_exact": 56,
    "arc_y5_father_trace_passed_exact": 56,
    "arc_y5_father_trace_custody": 56,
    "arc_y5_name_on_line_daeun_routed": 57,
    "arc_y5_people_verdict_daeun_exact": 58,
    "arc_y5_property_not_executed_notice": 59,
    "arc_y5_remaining_jaehyuk_or_self": 60,
    "arc_y5_final_father_answer_alive": 60,
    "arc_y5_final_father_answer_passed": 60,
    "arc_final_countdown_property_not_executed": 60,
    "arc_y5_final_week_daeun_outbound": 60,
}
EXPECTED_DECISIONS = {
    "story.first_illegal_offer",
    "story.father_hospital_door",
    "story.sangchul_truth_resolution",
    "story.jaehyuk_guarantee_resolution",
    "story.partner_commitment",
    "story.partner_name_use",
    "story.father_final_contact",
}
EXPECTED_SLOTS = {
    "boss_choice", "protected_commitment", "expired_obligation", "open_debt",
}
EXPECTED_CARRYOVER_SPEC = {
    "type": "receipt_ref",
    "required": ["kind", "source_receipt_id"],
    "optional": ["actor_id"],
}
EXPECTED_DECISION_SPECS = {
    "story.first_illegal_offer": {
        "type": "enum", "default": "unknown",
        "values": ["unknown", "refused", "escaped", "lent"],
    },
    "story.father_hospital_door": {
        "type": "enum", "default": "unknown",
        "values": ["unknown", "visited", "deferred", "avoided"],
    },
    "story.sangchul_truth_resolution": {
        "type": "enum", "default": "unknown",
        "values": ["unknown", "refused_to_know", "confronted", "used", "cut_ties"],
    },
    "story.jaehyuk_guarantee_resolution": {
        "type": "enum", "default": "unknown",
        "values": ["unknown", "refused", "vouched", "blocked"],
    },
    "story.partner_commitment": {
        "type": "enum", "default": "none", "values": ["none", "daeun", "jiyeon"],
    },
    "story.partner_name_use": {
        "type": "enum", "default": "n_a",
        "values": ["n_a", "asked_refused", "consensual", "secret"],
    },
    "story.father_final_contact": {
        "type": "enum", "default": "unknown",
        "values": ["unknown", "present", "called", "missed"],
    },
}


class DuplicateKeyError(ValueError):
    pass


def _reject_duplicate_keys(pairs: list[tuple[str, Any]]) -> dict[str, Any]:
    result: dict[str, Any] = {}
    for key, value in pairs:
        if key in result:
            raise DuplicateKeyError(f"duplicate key {key!r}")
        result[key] = value
    return result


def load_json(path: str) -> Any:
    with open(path, encoding="utf-8") as handle:
        return json.load(handle, object_pairs_hook=_reject_duplicate_keys)


def load_event_ids(directory: str) -> set[str]:
    result: set[str] = set()
    for path in sorted(glob.glob(os.path.join(directory, "*.json"))):
        data = load_json(path)
        if not isinstance(data, list):
            continue
        for event in data:
            if isinstance(event, dict) and str(event.get("id", "")).strip():
                result.add(str(event["id"]))
    return result


def exact_keys(value: Any, expected: set[str], owner: str, errors: list[str]) -> bool:
    if not isinstance(value, dict):
        errors.append(f"{owner}: must be an object")
        return False
    actual = set(value)
    if actual != expected:
        errors.append(
            f"{owner}: keys mismatch missing={sorted(expected - actual)} "
            f"extra={sorted(actual - expected)}"
        )
        return False
    return True


def string_list(value: Any, owner: str, errors: list[str]) -> list[str]:
    if not isinstance(value, list):
        errors.append(f"{owner}: must be an array")
        return []
    result: list[str] = []
    for index, item in enumerate(value):
        if not isinstance(item, str) or not item.strip():
            errors.append(f"{owner}[{index}]: must be a non-empty string")
            continue
        result.append(item)
    if len(result) != len(set(result)):
        errors.append(f"{owner}: duplicate values")
    return result


def rule_fact_contract(
    rule: Any,
) -> tuple[dict[str, set[str] | None], dict[str, set[str] | None], list[str]]:
    """Return approved enum facts, their exact values, and malformed clauses."""
    if not isinstance(rule, dict):
        return {}, {}, []
    logic = rule.get("logic", {})
    if not isinstance(logic, dict):
        return {}, {}, []

    reads: dict[str, set[str] | None] = {}
    writes: dict[str, set[str] | None] = {}
    malformed: list[str] = []

    def add_rows(rows: Any, target: dict[str, set[str] | None], *, write: bool) -> None:
        if not isinstance(rows, list):
            return
        value_keys = ("set", "value", "is", "in") if write else ("is", "in")
        for row in rows:
            if not isinstance(row, dict):
                continue
            fact = row.get("fact")
            if not isinstance(fact, str) or fact not in EXPECTED_DECISIONS:
                continue
            raw_value: Any = None
            for key in value_keys:
                if key in row:
                    raw_value = row[key]
                    break
            if isinstance(raw_value, str):
                values: set[str] | None = {raw_value}
            elif isinstance(raw_value, list) and all(
                isinstance(value, str) and value for value in raw_value
            ):
                values = set(raw_value)
            else:
                values = None
                malformed.append(f"{fact} has no exact enum value")
            allowed = set(EXPECTED_DECISION_SPECS[fact]["values"])
            if values is not None:
                invalid = values - allowed
                if invalid:
                    malformed.append(f"{fact} has invalid enum values {sorted(invalid)}")
            old = target.get(fact)
            if fact not in target:
                target[fact] = values
            elif old is None or values is None:
                target[fact] = None
            else:
                old.update(values)

    add_rows(logic.get("requires"), reads, write=False)
    add_rows(logic.get("forbids"), reads, write=False)
    add_rows(logic.get("produces"), writes, write=True)
    choices = logic.get("choice_produces", {})
    if isinstance(choices, dict):
        for rows in choices.values():
            add_rows(rows, writes, write=True)
    return reads, writes, malformed


def exact_rule_mapping(
    rule: Any,
    declared_reads: set[str],
    declared_writes: set[str],
    *,
    coverage_axis: str | None = None,
    coverage_values: set[str] | None = None,
) -> tuple[bool, list[str]]:
    """Require exact approved fact sets and exact covered enum values."""
    rule_reads, rule_writes, malformed = rule_fact_contract(rule)
    issues = list(malformed)
    if set(rule_reads) != declared_reads or set(rule_writes) != declared_writes:
        issues.append(
            "approved fact sets do not exactly match declared reads/writes "
            f"reads={sorted(rule_reads)} writes={sorted(rule_writes)}"
        )
    matches = set(rule_reads) == declared_reads and set(rule_writes) == declared_writes
    if any(values is None for values in rule_reads.values()):
        matches = False
    if any(values is None for values in rule_writes.values()):
        matches = False
    if malformed:
        matches = False
    if coverage_axis is not None and coverage_values is not None:
        if rule_reads.get(coverage_axis) != coverage_values:
            issues.append(
                f"{coverage_axis} values must match coverage {sorted(coverage_values)}"
            )
        matches = matches and rule_reads.get(coverage_axis) == coverage_values
    return matches, issues


def scene_execution_paths(
    beats_by_month: dict[int, list[dict[str, Any]]],
) -> dict[str, list[dict[str, Any]]]:
    """Expand mutually exclusive coverage branches without unioning impossible inputs."""
    beats_by_scene: dict[str, list[dict[str, Any]]] = {}
    for month_number in sorted(beats_by_month):
        for beat in beats_by_month[month_number]:
            if not isinstance(beat, dict) or not isinstance(beat.get("scene_id"), str):
                continue
            beats_by_scene.setdefault(beat["scene_id"], []).append(beat)

    result: dict[str, list[dict[str, Any]]] = {}
    for scene_id, beats in beats_by_scene.items():
        paths: list[dict[str, Any]] = [{
            "selectors": {}, "memories": set(), "carryovers": set(), "decisions": set(),
        }]
        for beat in beats:
            coverage = beat.get("coverage")
            alternatives: list[tuple[dict[str, Any], set[str]]] = []
            if isinstance(coverage, dict) and isinstance(coverage.get("axis"), str):
                base_values = coverage.get("base_values")
                alternatives.append((beat, set(base_values) if isinstance(base_values, list) else set()))
                fallbacks = coverage.get("fallbacks")
                if isinstance(fallbacks, list):
                    for fallback in fallbacks:
                        if isinstance(fallback, dict):
                            values = fallback.get("values")
                            alternatives.append((
                                {"reads": fallback.get("reads", {})},
                                set(values) if isinstance(values, list) else set(),
                            ))
            else:
                alternatives.append((beat, set()))

            beat_options: list[dict[str, Any]] = []
            for source, values in alternatives:
                reads = source.get("reads", {}) if isinstance(source, dict) else {}
                memories = reads.get("memories", []) if isinstance(reads, dict) else []
                carryovers = reads.get("carryovers", []) if isinstance(reads, dict) else []
                decision = reads.get("decision") if isinstance(reads, dict) else None
                decisions = {decision} if isinstance(decision, str) else set()
                selectors: dict[str, set[str]] = {}
                if isinstance(coverage, dict) and isinstance(coverage.get("axis"), str):
                    axis = coverage["axis"]
                    selectors[axis] = values or {"<invalid>"}
                    if axis in EXPECTED_DECISIONS:
                        decisions.add(axis)
                beat_options.append({
                    "selectors": selectors,
                    "memories": {value for value in memories if isinstance(value, str)},
                    "carryovers": {value for value in carryovers if isinstance(value, str)},
                    "decisions": decisions,
                })

            combined: list[dict[str, Any]] = []
            for path in paths:
                for option in beat_options:
                    selectors = {
                        axis: set(values) for axis, values in path["selectors"].items()
                    }
                    compatible = True
                    for axis, values in option["selectors"].items():
                        if axis not in selectors:
                            selectors[axis] = set(values)
                            continue
                        left = selectors[axis]
                        if "*" in left or "*" in values:
                            intersection = {"*"} if "*" in left and "*" in values else set()
                        else:
                            intersection = left & values
                        if not intersection:
                            compatible = False
                            break
                        selectors[axis] = intersection
                    if compatible:
                        combined.append({
                            "selectors": selectors,
                            "memories": path["memories"] | option["memories"],
                            "carryovers": path["carryovers"] | option["carryovers"],
                            "decisions": path["decisions"] | option["decisions"],
                        })
            paths = combined
        result[scene_id] = paths
    return result


def validate_actor_contracts(
    months: list[dict[str, Any]],
    rules: Any,
    spine: Any,
    errors: list[str],
) -> dict[str, set[str]]:
    """Validate typed actor provenance on each executable scene branch."""
    canonical_actors = {"player"}
    rule_events = rules.get("events", {}) if isinstance(rules, dict) else {}
    if isinstance(rule_events, dict):
        for event in rule_events.values():
            presentation = event.get("presentation", {}) if isinstance(event, dict) else {}
            if not isinstance(presentation, dict):
                continue
            participants = presentation.get("participants", [])
            if isinstance(participants, list):
                canonical_actors.update(
                    actor for actor in participants
                    if isinstance(actor, str) and actor
                )
            remote_actor = presentation.get("remote_actor")
            if isinstance(remote_actor, str) and remote_actor:
                canonical_actors.add(remote_actor)
    if isinstance(spine, dict):
        for collection_name in ("characters", "supporting_cast"):
            collection = spine.get(collection_name, [])
            if not isinstance(collection, list):
                continue
            canonical_actors.update(
                row["id"] for row in collection
                if isinstance(row, dict)
                and isinstance(row.get("id"), str)
                and row["id"]
            )

    commitment_records: dict[str, tuple[int, dict[str, Any], set[str]]] = {}
    for month in months:
        month_number = month.get("month")
        if not isinstance(month_number, int):
            continue
        for commitment in month.get("commitments", []):
            if not isinstance(commitment, dict) or not isinstance(commitment.get("id"), str):
                continue
            raw_slots = commitment.get("actor_slots", [])
            actor_slots = {
                slot for slot in raw_slots
                if isinstance(slot, str) and slot
            } if isinstance(raw_slots, list) else set()
            commitment_records[commitment["id"]] = (
                month_number, commitment, actor_slots,
            )

    scene_owners: dict[str, dict[str, Any]] = {}
    branches: list[dict[str, Any]] = []
    branches_by_beat: dict[str, list[dict[str, Any]]] = {}

    def reads_of(source: Any) -> dict[str, Any]:
        reads = source.get("reads", {}) if isinstance(source, dict) else {}
        return reads if isinstance(reads, dict) else {}

    def parse_role_policy(source: dict[str, Any], expected: set[str], owner: str) -> bool:
        keys = {key for key in ("distinct_roles", "coalesce_roles") if key in source}
        if len(keys) != 1:
            errors.append(f"{owner}: role bindings need exactly one role collision policy")
            return False
        key = next(iter(keys))
        roles = string_list(source.get(key), f"{owner}.{key}", errors)
        if set(roles) != {f"@{role}" for role in expected}:
            errors.append(f"{owner}.{key}: must cover every bound role")
        return key == "coalesce_roles"

    for month in months:
        month_number = month.get("month")
        if not isinstance(month_number, int):
            continue
        raw_beats = month.get("beats", [])
        if not isinstance(raw_beats, list):
            continue
        for beat_index, beat in enumerate(raw_beats):
            if not isinstance(beat, dict):
                continue
            beat_id = beat.get("id", f"beat_{beat_index}")
            beat_owner = f"M{month_number:02}.{beat_id}"
            scene_id = beat.get("scene_id")
            scene_id = scene_id if isinstance(scene_id, str) else beat_owner
            cast = beat.get("cast", [])
            cast = cast if isinstance(cast, list) else []
            role_names = {
                actor[1:] for actor in cast
                if isinstance(actor, str) and actor.startswith("@") and len(actor) > 1
            }
            bindings = beat.get("role_bindings")
            effective_bindings: dict[str, Any] = {}
            if bindings is not None:
                if not isinstance(bindings, dict):
                    errors.append(f"{beat_owner}.role_bindings: must be an object")
                    bindings = {}
                if not role_names:
                    errors.append(f"{beat_owner}: role metadata requires @roles in cast")
                if set(bindings) != role_names:
                    errors.append(
                        f"{beat_owner}.role_bindings: must bind every cast role exactly"
                    )
                parse_role_policy(beat, role_names, beat_owner)
                if scene_id in scene_owners:
                    errors.append(
                        f"scene {scene_id}: base role_bindings owner must be exactly one beat"
                    )
                else:
                    scene_owners[scene_id] = {
                        "owner": beat_owner,
                        "roles": set(role_names),
                        "bindings": bindings,
                        "variants": [bindings],
                    }
                effective_bindings = bindings
                binding_variants = [bindings]
            elif role_names:
                owner_record = scene_owners.get(scene_id)
                if owner_record is None or not role_names.issubset(owner_record["roles"]):
                    errors.append(f"{beat_owner}.role_bindings: required for @roles")
                    binding_variants = [{}]
                else:
                    effective_bindings = owner_record["bindings"]
                    binding_variants = owner_record["variants"]
                if "distinct_roles" in beat or "coalesce_roles" in beat:
                    errors.append(
                        f"{beat_owner}: reused scene roles must not repeat distinct_roles"
                    )
            elif "distinct_roles" in beat or "coalesce_roles" in beat:
                errors.append(f"{beat_owner}: role metadata requires @roles in cast")
                binding_variants = [{}]
            else:
                binding_variants = [{}]

            coverage = beat.get("coverage")
            axis = coverage.get("axis") if isinstance(coverage, dict) else None
            base_values = coverage.get("base_values") if isinstance(coverage, dict) else None
            branch = {
                "month": month_number,
                "owner": f"{beat_owner}.base",
                "scene_id": scene_id,
                "channel": beat.get("channel"),
                "reads": reads_of(beat),
                "axis": axis,
                "values": base_values if isinstance(base_values, list) else None,
                "role_names": role_names,
                "bindings": effective_bindings,
                "binding_variants": binding_variants,
                "own_bindings": bindings if isinstance(bindings, dict) else None,
                "coalesces": "coalesce_roles" in beat,
                "selector": beat.get("selector"),
                "actor_outputs": beat.get("actor_outputs"),
                "writes": beat.get("writes", {}),
            }
            branches.append(branch)
            branches_by_beat.setdefault(beat_owner, []).append(branch)

            fallbacks = coverage.get("fallbacks", []) if isinstance(coverage, dict) else []
            if not isinstance(fallbacks, list):
                continue
            for fallback_index, fallback in enumerate(fallbacks):
                if not isinstance(fallback, dict):
                    continue
                fallback_owner = f"{beat_owner}.fallback[{fallback_index}]"
                fallback_cast = fallback.get("cast", [])
                fallback_cast = fallback_cast if isinstance(fallback_cast, list) else []
                fallback_roles = {
                    actor[1:] for actor in fallback_cast
                    if isinstance(actor, str) and actor.startswith("@") and len(actor) > 1
                }
                fallback_bindings = fallback.get("role_bindings")
                effective_fallback_bindings: dict[str, Any] = {}
                if fallback_roles:
                    if not isinstance(fallback_bindings, dict):
                        errors.append(
                            f"{fallback_owner}.role_bindings: fallback must bind its own @roles"
                        )
                        fallback_bindings = {}
                    if set(fallback_bindings) != fallback_roles:
                        errors.append(
                            f"{fallback_owner}.role_bindings: must bind every cast role exactly"
                        )
                    parse_role_policy(fallback, fallback_roles, fallback_owner)
                    effective_fallback_bindings = fallback_bindings
                    owner_record = scene_owners.get(scene_id)
                    if (
                        owner_record is not None
                        and owner_record["owner"] == beat_owner
                    ):
                        owner_record["variants"].append(fallback_bindings)
                elif fallback_bindings is not None or any(
                    key in fallback for key in ("distinct_roles", "coalesce_roles")
                ):
                    errors.append(f"{fallback_owner}: role metadata requires @roles in cast")
                fallback_branch = {
                    "month": month_number,
                    "owner": fallback_owner,
                    "scene_id": scene_id,
                    "channel": fallback.get("channel"),
                    "reads": reads_of(fallback),
                    "axis": axis,
                    "values": fallback.get("values") if isinstance(fallback.get("values"), list) else None,
                    "role_names": fallback_roles,
                    "bindings": effective_fallback_bindings,
                    "binding_variants": [effective_fallback_bindings],
                    "own_bindings": fallback_bindings if isinstance(fallback_bindings, dict) else None,
                    "coalesces": "coalesce_roles" in fallback,
                    "selector": fallback.get("selector"),
                    "actor_outputs": fallback.get("actor_outputs"),
                    "writes": beat.get("writes", {}),
                }
                branches.append(fallback_branch)
                branches_by_beat.setdefault(beat_owner, []).append(fallback_branch)

    memory_receipts: list[tuple[int, str, dict[str, Any]]] = []
    actor_history_inputs: dict[str, set[str]] = {}

    def validate_actor_fallback(value: Any, owner: str) -> list[str]:
        if not isinstance(value, dict) or set(value) != {"kind", "actor_ids"}:
            errors.append(f"{owner}: fallback must be an exact first_distinct actor list")
            return []
        actor_ids = string_list(value.get("actor_ids"), f"{owner}.actor_ids", errors)
        if value.get("kind") != "first_distinct" or len(actor_ids) < 2 or any(
            actor not in canonical_actors or actor == "player" for actor in actor_ids):
            errors.append(f"{owner}: fallback actors must be canonical non-player candidates")
        return actor_ids

    def validate_binding(
        binding: Any,
        branch: dict[str, Any],
        binding_owner: str,
        *,
        allow_scene_role: bool,
    ) -> bool:
        if not isinstance(binding, dict):
            errors.append(
                f"{binding_owner}: binding must use a tagged actor source object"
            )
            return False
        kind = binding.get("kind")
        if kind == "scene_role":
            if not allow_scene_role:
                errors.append(f"{binding_owner}: scene_role is only valid in actor_outputs")
                return False
            if set(binding) != {"kind", "role"}:
                errors.append(f"{binding_owner}: scene_role keys must be kind,role")
                return False
            role = binding.get("role")
            if not isinstance(role, str) or role not in branch["bindings"]:
                errors.append(f"{binding_owner}: scene_role must reference a bound scene role")
                return False
            return True
        if kind not in ROLE_BINDING_KINDS:
            errors.append(f"{binding_owner}: invalid actor binding kind {kind!r}")
            return False
        expected_keys = {
            "literal": {"kind", "actor_id"},
            "fact_actor": {"kind", "fact_id", "value_to_actor"},
            "receipt_actor": {"kind", "source_type", "source_id", "actor_role"},
            "commitment_actor": {"kind", "source", "actor_role"},
        }[kind]
        allowed_keys = {frozenset(expected_keys)}
        if kind in {"receipt_actor", "commitment_actor"}:
            allowed_keys.add(frozenset(expected_keys | {"fallback"}))
        if frozenset(binding) not in allowed_keys:
            errors.append(
                f"{binding_owner}: {kind} keys mismatch "
                f"missing={sorted(expected_keys - set(binding))} "
                f"extra={sorted(set(binding) - expected_keys - {'fallback'})}"
            )
            return False
        if kind == "literal":
            actor_id = binding.get("actor_id")
            if not isinstance(actor_id, str) or actor_id not in canonical_actors:
                errors.append(f"{binding_owner}: literal actor_id is not canonical")
                return False
            return True
        if kind == "fact_actor":
            fact_id = binding.get("fact_id")
            reads = branch["reads"]
            decision = reads.get("decision") if isinstance(reads, dict) else None
            if fact_id not in EXPECTED_DECISIONS or fact_id not in {decision, branch["axis"]}:
                errors.append(
                    f"{binding_owner}: fact_actor must use this branch decision or coverage axis"
                )
                return False
            mapping = binding.get("value_to_actor")
            if not isinstance(mapping, dict):
                errors.append(f"{binding_owner}.value_to_actor: must be an object")
                return False
            raw_values = branch["values"]
            if branch["axis"] == fact_id and isinstance(raw_values, list):
                expected_values = {
                    value for value in raw_values
                    if isinstance(value, str) and value != "*"
                }
            else:
                expected_values = (
                    set(EXPECTED_DECISION_SPECS[fact_id]["values"])
                    - {"unknown", "none"}
                )
            if set(mapping) != expected_values:
                errors.append(
                    f"{binding_owner}.value_to_actor: must exactly cover branch enum values "
                    f"missing={sorted(expected_values - set(mapping))} "
                    f"extra={sorted(set(mapping) - expected_values)}"
                )
                return False
            if any(
                not isinstance(actor, str) or actor not in canonical_actors
                for actor in mapping.values()
            ):
                errors.append(f"{binding_owner}.value_to_actor: actor ids must be canonical")
                return False
            return True

        actor_role = binding.get("actor_role")
        if not isinstance(actor_role, str) or re.fullmatch(r"[a-z][a-z0-9_]*", actor_role) is None:
            errors.append(f"{binding_owner}.actor_role: must be a lowercase role identifier")
            return False
        if "fallback" in binding:
            validate_actor_fallback(binding.get("fallback"), f"{binding_owner}.fallback")

        if kind == "commitment_actor":
            source = binding.get("source")
            if not isinstance(source, dict):
                errors.append(f"{binding_owner}.source: must be a tagged commitment source")
                return False
            source_kind = source.get("kind")
            expected_source_keys = {
                "available_commitment": {"kind", "commitment_id"},
                "selected_commitment": SELECTED_SOURCE_KEYS,
                "commitment_receipt": RECEIPT_SOURCE_KEYS,
            }.get(source_kind)
            if expected_source_keys is None:
                errors.append(
                    f"{binding_owner}.source.kind: must be available_commitment, "
                    "selected_commitment, or commitment_receipt"
                )
                return False
            if not exact_keys(source, expected_source_keys, f"{binding_owner}.source", errors):
                return False
            if source_kind == "commitment_receipt":
                source_id = source.get("source_receipt_id")
            else:
                source_id = source.get("commitment_id")
            record = commitment_records.get(source_id) if isinstance(source_id, str) else None
            if record is None:
                errors.append(f"{binding_owner}.source: commitment does not exist")
                return False
            source_month, _, actor_slots = record
            if actor_role not in actor_slots:
                errors.append(
                    f"{binding_owner}: commitment {source_id} does not declare "
                    f"actor_slot {actor_role}"
                )
                return False
            if source_kind in {"available_commitment", "selected_commitment"}:
                if allow_scene_role:
                    errors.append(
                        f"{binding_owner}: {source_kind} is only valid in scene role_bindings"
                    )
                    return False
                if source_month != branch["month"]:
                    errors.append(
                        f"{binding_owner}: {source_kind} actor must come from the same month"
                    )
                    return False
                if branch.get("channel") == "in_person" and source_kind != "selected_commitment":
                    errors.append(
                        f"{binding_owner}: in-person commitment actor needs selected provenance"
                    )
                    return False
                if (
                    source_kind == "selected_commitment"
                    and source.get("slot") != EXPECTED_SELECTION_SLOTS
                ):
                    errors.append(
                        f"{binding_owner}.source.slot: must allow protected and optional_second"
                    )
                    return False
                return True
            if not allow_scene_role:
                errors.append(
                    f"{binding_owner}: completed commitment actor is only valid in actor_outputs"
                )
                return False
            if source.get("state") != ["completed"]:
                errors.append(
                    f"{binding_owner}.source.state: actor identity requires completed provenance"
                )
                return False
            if source_month != branch["month"] - 1:
                errors.append(
                    f"{binding_owner}.source: completed actor receipt must come from the previous month"
                )
                return False
            if "fallback" not in binding:
                errors.append(
                    f"{binding_owner}: completed actor output needs a truthful fallback resolver"
                )
                return False
            actor_history_inputs.setdefault(branch["scene_id"], set()).add(
                f"receipt.{source_id}"
            )
            return True

        source_type = binding.get("source_type")
        source_id = binding.get("source_id")
        if source_type not in RECEIPT_SOURCE_TYPES:
            errors.append(f"{binding_owner}.source_type: must be memory or carryover")
            return False
        reads = branch["reads"]
        if source_type == "memory":
            if not isinstance(source_id, str) or not source_id.startswith("memory."):
                errors.append(f"{binding_owner}.source_id: memory receipt must start memory.")
                return False
            read_memories = reads.get("memories", []) if isinstance(reads, dict) else []
            if source_id not in read_memories:
                errors.append(
                    f"{binding_owner}: memory receipt {source_id} is not read by its owner branch"
                )
                return False
            memory_receipts.append((branch["month"], binding_owner, binding))
            return True
        if source_type == "carryover":
            if source_id not in EXPECTED_SLOTS or actor_role != "actor":
                errors.append(
                    f"{binding_owner}: carryover receipt needs canonical slot and actor role"
                )
                return False
            read_carryovers = reads.get("carryovers", []) if isinstance(reads, dict) else []
            if source_id not in read_carryovers:
                errors.append(
                    f"{binding_owner}: carryover receipt {source_id} is not read by its owner branch"
                )
                return False
            if allow_scene_role and "fallback" not in binding:
                errors.append(
                    f"{binding_owner}: carryover actor output needs a truthful fallback resolver"
                )
                return False
            return True
        return False

    for branch in branches:
        bindings = branch["own_bindings"]
        if isinstance(bindings, dict):
            for role, binding in bindings.items():
                validate_binding(
                    binding, branch, f"{branch['owner']}.role_bindings.{role}",
                    allow_scene_role=False,
                )

    producer_variants: dict[str, list[dict[str, Any]]] = {}
    output_graph: dict[tuple[str, str], set[tuple[str, str]]] = {}
    for beat_owner, beat_branches in branches_by_beat.items():
        actorized_memories = {
            memory_id
            for branch in beat_branches
            if isinstance(branch["actor_outputs"], dict)
            for memory_id in branch["actor_outputs"]
        }
        for branch in beat_branches:
            raw_outputs = branch["actor_outputs"]
            outputs = raw_outputs if isinstance(raw_outputs, dict) else {}
            for memory_id in actorized_memories:
                if memory_id not in outputs:
                    errors.append(
                        f"{branch['owner']}.actor_outputs: missing branch output for {memory_id}"
                    )
            if raw_outputs is not None and not isinstance(raw_outputs, dict):
                errors.append(f"{branch['owner']}.actor_outputs: must be an object")
                continue
            written = branch["writes"].get("memories", []) \
                if isinstance(branch["writes"], dict) else []
            for memory_id, output in outputs.items():
                output_owner = f"{branch['owner']}.actor_outputs.{memory_id}"
                if memory_id not in written:
                    errors.append(f"{output_owner}: actor output memory is not written by this beat")
                policy_keys = set(output) & ACTOR_OUTPUT_POLICIES if isinstance(output, dict) else set()
                if not isinstance(output, dict) or set(output) != {"roles"} | policy_keys or len(policy_keys) != 1:
                    errors.append(f"{output_owner}: keys must be roles plus exactly one actor role policy")
                    continue
                roles = output.get("roles")
                if not isinstance(roles, dict) or not roles:
                    errors.append(f"{output_owner}.roles: must be a non-empty object")
                    roles = roles if isinstance(roles, dict) else {}
                for role, binding in roles.items():
                    if not isinstance(role, str) or re.fullmatch(r"[a-z][a-z0-9_]*", role) is None:
                        errors.append(f"{output_owner}.roles: invalid output role {role!r}")
                        continue
                    validate_binding(
                        binding, branch, f"{output_owner}.roles.{role}",
                        allow_scene_role=True,
                    )
                policy = next(iter(policy_keys))
                groups = output.get(policy)
                if not isinstance(groups, list):
                    errors.append(f"{output_owner}.{policy}: must be an array")
                    groups = []
                for group_index, group in enumerate(groups):
                    group_roles = string_list(
                        group, f"{output_owner}.{policy}[{group_index}]", errors
                    )
                    if len(group_roles) < 2:
                        errors.append(
                            f"{output_owner}.{policy}[{group_index}]: needs at least two roles"
                        )
                    if not set(group_roles).issubset(set(roles)):
                        errors.append(
                            f"{output_owner}.{policy}[{group_index}]: unknown output role"
                        )
                for binding_variant in branch["binding_variants"]:
                    producer_variants.setdefault(memory_id, []).append({
                        "month": branch["month"],
                        "owner": output_owner,
                        "roles": roles,
                        "bindings": binding_variant,
                        "groups": groups,
                        "coalesced": policy == "coalesced",
                    })

    for reader_month, binding_owner, binding in memory_receipts:
        source_id = binding["source_id"]
        actor_role = binding["actor_role"]
        variants = producer_variants.get(source_id, [])
        if not variants:
            errors.append(
                f"{binding_owner}: memory receipt {source_id}.{actor_role} has no actor_outputs producer"
            )
            continue
        for variant in variants:
            if variant["month"] >= reader_month:
                errors.append(f"{binding_owner}: memory actor producer must be earlier")
            if actor_role not in variant["roles"]:
                errors.append(
                    f"{binding_owner}: producer {variant['owner']} has no role {actor_role}"
                )

    def memory_edges(binding: Any, scene_bindings: dict[str, Any]) -> set[tuple[str, str]]:
        if not isinstance(binding, dict):
            return set()
        if binding.get("kind") == "receipt_actor" and binding.get("source_type") == "memory":
            source_id = binding.get("source_id")
            actor_role = binding.get("actor_role")
            if isinstance(source_id, str) and isinstance(actor_role, str):
                return {(source_id, actor_role)}
        if binding.get("kind") == "scene_role":
            role = binding.get("role")
            return memory_edges(scene_bindings.get(role), scene_bindings)
        return set()

    for memory_id, variants in producer_variants.items():
        for variant in variants:
            for role, binding in variant["roles"].items():
                output_graph.setdefault((memory_id, role), set()).update(
                    memory_edges(binding, variant["bindings"])
                )

    visiting: set[tuple[str, str]] = set()
    visited: set[tuple[str, str]] = set()

    def find_cycle(node: tuple[str, str]) -> bool:
        if node in visiting:
            return True
        if node in visited:
            return False
        visiting.add(node)
        if any(find_cycle(target) for target in output_graph.get(node, set())):
            return True
        visiting.remove(node)
        visited.add(node)
        return False

    for node in output_graph:
        if find_cycle(node):
            errors.append(f"actor output cycle at {node[0]}.{node[1]}")
            break

    def resolve_binding(
        binding: Any,
        scene_bindings: dict[str, Any],
        stack: set[tuple[str, str]],
    ) -> set[str]:
        if not isinstance(binding, dict):
            return set()
        kind = binding.get("kind")
        if kind == "literal":
            actor_id = binding.get("actor_id")
            return {actor_id} if isinstance(actor_id, str) else set()
        if kind == "fact_actor":
            mapping = binding.get("value_to_actor")
            return {
                actor for actor in mapping.values() if isinstance(actor, str)
            } if isinstance(mapping, dict) else set()
        if kind == "commitment_actor":
            source = binding.get("source")
            actor_role = binding.get("actor_role")
            values: set[str] = set()
            if isinstance(source, dict):
                source_kind = source.get("kind")
                source_id = (
                    source.get("source_receipt_id")
                    if source_kind == "commitment_receipt"
                    else source.get("commitment_id")
                )
                if isinstance(source_kind, str) and isinstance(source_id, str):
                    values.add(f"commitment:{source_kind}:{source_id}:{actor_role}")
            fallback = binding.get("fallback")
            if isinstance(fallback, dict) and isinstance(fallback.get("actor_ids"), list):
                values.update(actor for actor in fallback["actor_ids"] if isinstance(actor, str))
            return values
        if kind == "receipt_actor":
            source_type = binding.get("source_type")
            source_id = binding.get("source_id")
            actor_role = binding.get("actor_role")
            fallback = binding.get("fallback")
            fallback_values = {
                actor for actor in fallback.get("actor_ids", []) if isinstance(actor, str)
            } if isinstance(fallback, dict) else set()
            if source_type != "memory":
                return {
                    f"receipt:{source_type}:{source_id}:{actor_role}"
                } | fallback_values
            node = (source_id, actor_role)
            if node in stack:
                return fallback_values
            result: set[str] = set(fallback_values)
            for variant in producer_variants.get(source_id, []):
                producer_binding = variant["roles"].get(actor_role)
                result.update(resolve_binding(
                    producer_binding, variant["bindings"], stack | {node}
                ))
            return result
        if kind == "scene_role":
            return resolve_binding(
                scene_bindings.get(binding.get("role")), scene_bindings, stack
            )
        return set()

    def check_distinct(
        named_bindings: dict[str, Any],
        groups: list[list[str]],
        scene_bindings: dict[str, Any],
        owner: str,
    ) -> None:
        def memory_ref(binding: Any) -> tuple[str, str] | None:
            if not isinstance(binding, dict):
                return None
            if binding.get("kind") == "scene_role":
                return memory_ref(scene_bindings.get(binding.get("role")))
            if binding.get("kind") == "receipt_actor" and binding.get("source_type") == "memory":
                return binding.get("source_id"), binding.get("actor_role")
            return None
        for group in groups:
            for left_index, left in enumerate(group):
                left_values = resolve_binding(
                    named_bindings.get(left), scene_bindings, set()
                )
                for right in group[left_index + 1:]:
                    left_ref, right_ref = memory_ref(named_bindings.get(left)), memory_ref(named_bindings.get(right))
                    if left_ref and right_ref and left_ref[0] == right_ref[0] and any(
                        variant["coalesced"] and {left_ref[1], right_ref[1]}.issubset(set(role_group))
                        for variant in producer_variants.get(left_ref[0], [])
                        for role_group in variant["groups"] if isinstance(role_group, list)
                    ):
                        errors.append(f"{owner}: coalesced actor roles require coalesce policy")
                    right_values = resolve_binding(
                        named_bindings.get(right), scene_bindings, set()
                    )
                    overlap = left_values & right_values
                    if overlap:
                        errors.append(
                            f"{owner}: distinct roles resolve to same actor {sorted(overlap)}"
                        )

    for branch in branches:
        if isinstance(branch["own_bindings"], dict) and not branch["coalesces"]:
            roles = sorted(branch["role_names"])
            check_distinct(
                branch["own_bindings"], [roles], branch["bindings"],
                f"{branch['owner']}.distinct_roles",
            )
    for memory_id, variants in producer_variants.items():
        for variant in variants:
            if variant["coalesced"]:
                continue
            valid_groups = [
                group for group in variant["groups"]
                if isinstance(group, list)
            ]
            check_distinct(
                variant["roles"], valid_groups, variant["bindings"],
                f"{variant['owner']}.all_distinct",
            )

    def actor_requirements(branch: dict[str, Any]) -> tuple[set[str], set[str]]:
        selected: set[str] = set()
        available: set[str] = set()
        bindings = branch.get("own_bindings")
        if not isinstance(bindings, dict):
            return selected, available
        for binding in bindings.values():
            if not isinstance(binding, dict) or binding.get("kind") != "commitment_actor":
                continue
            if "fallback" in binding:
                continue
            source = binding.get("source")
            if not isinstance(source, dict):
                continue
            source_kind = source.get("kind")
            commitment_id = source.get("commitment_id")
            if not isinstance(commitment_id, str):
                continue
            if source_kind == "selected_commitment":
                selected.add(commitment_id)
            elif source_kind == "available_commitment":
                available.add(commitment_id)
        return selected, available

    months_by_number = {row["month"]: row for row in months if isinstance(row.get("month"), int)}
    for beat_owner, beat_branches in branches_by_beat.items():
        if not any(branch.get("selector") is not None for branch in beat_branches):
            continue
        month_number = beat_branches[0]["month"]
        month = months_by_number.get(month_number, {})
        rows = [row for row in month.get("commitments", [])
                if isinstance(row, dict) and isinstance(row.get("id"), str)]
        availability = month.get("availability") if isinstance(month, dict) else None
        scenario_values = availability.get("values", []) if isinstance(availability, dict) else [None]
        month_ids = {row["id"] for row in rows}
        valid_selectors: dict[str, tuple[set[str], set[str], set[str]]] = {}
        for branch in beat_branches:
            selector = branch.get("selector")
            owner = f"{branch['owner']}.selector"
            if not exact_keys(selector, SELECTOR_KEYS, owner, errors):
                continue
            selected_all = set(string_list(selector.get("selected_all"), f"{owner}.selected_all", errors))
            selected_none = set(string_list(selector.get("selected_none"), f"{owner}.selected_none", errors))
            available_values = set(string_list(selector.get("availability_values"), f"{owner}.availability_values", errors))
            if (selected_all | selected_none) - month_ids or selected_all & selected_none:
                errors.append(f"{owner}: commitment ids must be same-month and disjoint")
            if not available_values or ("*" in available_values and available_values != {"*"}):
                errors.append(f"{owner}.availability_values: wildcard must stand alone")
            valid_selectors[branch["owner"]] = selected_all, selected_none, available_values
        if len(valid_selectors) != len(beat_branches):
            errors.append(f"{beat_owner}: every coverage branch needs an exact selector")
        for scenario_value in scenario_values:
            visible = [row for row in rows if scenario_value is None
                       or row.get("available_values") == ["*"]
                       or scenario_value in row.get("available_values", [])]
            visible_ids = {row["id"] for row in visible}
            actionable = [row for row in visible if row.get("after") is None]
            legal_selections = [frozenset({row["id"]}) for row in actionable]
            for left_index, left in enumerate(actionable):
                for right in actionable[left_index + 1:]:
                    legal_selections.append(frozenset({left["id"], right["id"]}))
            for successor in visible:
                predecessor = successor.get("after")
                if isinstance(predecessor, str) and predecessor in visible_ids:
                    legal_selections.append(frozenset({predecessor, successor["id"]}))
            for selected_ids in set(legal_selections):
                matching = [branch for branch in beat_branches
                            if (selector := valid_selectors.get(branch["owner"])) is not None
                            and (selector[2] == {"*"} or scenario_value in selector[2])
                            and selector[0].issubset(selected_ids)
                            and selector[1].isdisjoint(selected_ids)]
                scenario_label = "all" if scenario_value is None else str(scenario_value)
                if len(matching) != 1:
                    errors.append(f"{beat_owner}: selector dispatch must resolve exactly one branch for "
                                  f"availability={scenario_label} selected={sorted(selected_ids)}")
                    continue
                required_selected, required_available = actor_requirements(matching[0])
                if not required_selected.issubset(selected_ids) or not required_available.issubset(visible_ids):
                    errors.append(f"{matching[0]['owner']}: selector violates actor provenance")

    m52_branches = [branch for branch in branches if branch["scene_id"] == "m52_final_offer"]
    live_sources = {binding.get("source", {}).get("commitment_id")
                    for branch in m52_branches if branch.get("channel") == "in_person"
                    for binding in (branch.get("own_bindings") or {}).values()
                    if isinstance(binding, dict) and binding.get("kind") == "commitment_actor"
                    and binding.get("source", {}).get("kind") == "selected_commitment"}
    document_sources = [binding.get("source")
                        for branch in m52_branches if branch.get("channel") == "message"
                        for binding in (branch.get("own_bindings") or {}).values()
                        if isinstance(binding, dict) and binding.get("kind") == "commitment_actor"]
    if (
        len(document_sources) != 1
        or document_sources[0].get("kind") != "available_commitment"
        or document_sources[0].get("commitment_id") not in live_sources
    ):
        errors.append("M52 document fallback must use the actual available live proposer")

    return actor_history_inputs


def validate_commitment_quality(
    months: list[dict[str, Any]],
    retired_selectable_ids: set[str],
    errors: list[str],
) -> None:
    """Reject the fixed deadline template, free deferral, and retired fake cards."""
    pressure_total = 0
    pressure_week_one = 0
    person_total = 0
    person_week_four = 0
    chapter_person_total = {chapter: 0 for chapter in range(1, 6)}
    chapter_person_deferred = {chapter: 0 for chapter in range(1, 6)}
    chapter_conflict_months = {chapter: 0 for chapter in range(1, 6)}

    def has_cross_source_same_week(rows: list[dict[str, Any]]) -> bool:
        sources_by_week: dict[int, set[str]] = {}
        for row in rows:
            source = row.get("source")
            due_week = row.get("due_week")
            if (
                source not in COMMITMENT_SOURCES
                or not isinstance(due_week, int)
                or isinstance(due_week, bool)
            ):
                continue
            sources_by_week.setdefault(due_week, set()).add(source)
        return any(len(sources) >= 2 for sources in sources_by_week.values())

    for month in months:
        month_number = month.get("month")
        if not isinstance(month_number, int) or isinstance(month_number, bool):
            continue
        chapter = (month_number - 1) // 12 + 1
        if chapter not in chapter_person_total:
            continue
        raw_commitments = month.get("commitments", [])
        commitments = [
            row for row in raw_commitments if isinstance(row, dict)
        ] if isinstance(raw_commitments, list) else []

        for commitment in commitments:
            commitment_id = commitment.get("id")
            if commitment_id in retired_selectable_ids:
                errors.append(
                    f"M{month_number:02} commitments: retired selectable commitment id "
                    f"{commitment_id} must stay automatic or removed"
                )

            source = commitment.get("source")
            due_week = commitment.get("due_week")
            local_week = (
                (due_week - 1) % 4 + 1
                if isinstance(due_week, int) and not isinstance(due_week, bool)
                else None
            )
            if source == "pressure":
                pressure_total += 1
                if local_week == 1:
                    pressure_week_one += 1
            elif source == "person_promise":
                person_total += 1
                chapter_person_total[chapter] += 1
                if local_week == 4:
                    person_week_four += 1
                if commitment.get("miss") == "deferred":
                    chapter_person_deferred[chapter] += 1

            if month_number == 60 and commitment.get("miss") == "deferred":
                errors.append(
                    f"M60 commitments: deferred miss is forbidden for {commitment_id}"
                )

        availability = month.get("availability")
        if isinstance(availability, dict):
            values = availability.get("values")
            visible_scenarios: list[list[dict[str, Any]]] = []
            if isinstance(values, list) and values:
                for value in values:
                    visible: list[dict[str, Any]] = []
                    for commitment in commitments:
                        available_values = commitment.get("available_values")
                        if available_values == ["*"] or (
                            isinstance(available_values, list)
                            and value in available_values
                        ):
                            visible.append(commitment)
                    visible_scenarios.append(visible)
        else:
            visible_scenarios = [commitments]
        if visible_scenarios and all(
            has_cross_source_same_week(rows) for rows in visible_scenarios
        ):
            chapter_conflict_months[chapter] += 1

    if pressure_total and pressure_week_one * 5 > pressure_total * 4:
        errors.append(
            "deadline pattern: pressure local week 1 maximum is 80% "
            f"({pressure_week_one}/{pressure_total})"
        )
    if person_total and person_week_four * 10 > person_total * 7:
        errors.append(
            "deadline pattern: person_promise local week 4 maximum is 70% "
            f"({person_week_four}/{person_total})"
        )
    for chapter in range(1, 6):
        conflict_months = chapter_conflict_months[chapter]
        if conflict_months < 2:
            errors.append(
                f"chapter {chapter}: cross-source same-week conflict months minimum is 2 "
                f"(got {conflict_months})"
            )
        deferred = chapter_person_deferred[chapter]
        total = chapter_person_total[chapter]
        if total and deferred * 2 > total:
            errors.append(
                f"chapter {chapter}: deferred person_promise maximum is 50% "
                f"({deferred}/{total})"
            )


def validate_commitment_causality(
    story_map: dict[str, Any],
    months: list[dict[str, Any]],
    beats_by_month: dict[int, list[dict[str, Any]]],
    commitment_months: dict[str, int],
    errors: list[str],
) -> tuple[int, int, dict[str, set[str]]]:
    """Validate local selection readers and durable receipt readers as separate stages."""
    owner = "commitment_causality"
    causality = story_map.get("commitment_causality")
    if not exact_keys(causality, CAUSALITY_KEYS, owner, errors):
        return 0, 0, {}

    if causality.get("selection_slots") != EXPECTED_SELECTION_SLOTS:
        errors.append(f"{owner}.selection_slots: must preserve protected then optional_second")
    if causality.get("selection_record") != EXPECTED_SELECTION_RECORD:
        errors.append(
            f"{owner}.selection_record: must declare exact kind/commitment_id/slot runtime shape"
        )
    if causality.get("receipt_record") != EXPECTED_RECEIPT_RECORD:
        errors.append(
            f"{owner}.receipt_record: must declare exact durable receipt runtime shape"
        )
    if causality.get("reader_modes") != EXPECTED_READER_MODES:
        errors.append(f"{owner}.reader_modes: only gate and focus are allowed")
    if causality.get("write_order") != EXPECTED_WRITE_ORDER:
        errors.append(
            f"{owner}.write_order: selection, scene writes, receipt commit, and resolved dispatch order drifted"
        )

    commitment_rows: dict[str, dict[str, Any]] = {}
    availability_axes: dict[int, str] = {}
    for month in months:
        month_number = month.get("month")
        if not isinstance(month_number, int) or isinstance(month_number, bool):
            continue
        availability = month.get("availability")
        if isinstance(availability, dict) and isinstance(availability.get("axis"), str):
            availability_axes[month_number] = availability["axis"]
        rows = month.get("commitments", [])
        if isinstance(rows, list):
            for row in rows:
                if isinstance(row, dict) and isinstance(row.get("id"), str):
                    commitment_rows[row["id"]] = row

    scene_months: dict[str, int] = {}
    scene_roots: dict[str, set[str]] = {}
    scene_coverages: dict[str, list[dict[str, Any]]] = {}
    for month_number, beats in beats_by_month.items():
        for beat in beats:
            if not isinstance(beat, dict) or not isinstance(beat.get("scene_id"), str):
                continue
            scene_id = beat["scene_id"]
            old_month = scene_months.get(scene_id)
            if old_month is not None and old_month != month_number:
                errors.append(f"{owner}: scene {scene_id} cannot span multiple months")
            scene_months[scene_id] = month_number
            roots = scene_roots.setdefault(scene_id, set())
            if isinstance(beat.get("root"), str):
                roots.add(beat["root"])
            coverage = beat.get("coverage")
            if isinstance(coverage, dict):
                scene_coverages.setdefault(scene_id, []).append(coverage)
                fallbacks = coverage.get("fallbacks", [])
                if isinstance(fallbacks, list):
                    for fallback in fallbacks:
                        if isinstance(fallback, dict) and isinstance(fallback.get("root"), str):
                            roots.add(fallback["root"])

    generic = causality.get("generic_reader")
    generic_covered: set[str] = set()
    if exact_keys(generic, GENERIC_READER_KEYS, f"{owner}.generic_reader", errors):
        if generic.get("source") != "all_commitments":
            errors.append(f"{owner}.generic_reader.source: must cover all commitments")
        if generic.get("states") != ["completed", "deferred", "expired"]:
            errors.append(f"{owner}.generic_reader.states: must cover every terminal receipt state")
        if generic.get("completed") != "loop_contract.optional_second.single_protected_completion":
            errors.append(f"{owner}.generic_reader.completed: must use the optional-second margin contract")
        if generic.get("misses") != "loop_contract.miss_consequences":
            errors.append(f"{owner}.generic_reader.misses: must use the loop miss contract")
        generic_months = generic.get("months")
        if generic_months != [1, 59]:
            errors.append(f"{owner}.generic_reader.months: must cover M01..M59")
        terminal = generic.get("terminal")
        if exact_keys(terminal, TERMINAL_KEYS, f"{owner}.generic_reader.terminal", errors):
            if terminal.get("month") != 60:
                errors.append(f"{owner}.generic_reader.terminal.month: must be M60")
            if terminal.get("kind") != "ledger_echo":
                errors.append(f"{owner}.generic_reader.terminal.kind: must be ledger_echo")
            if terminal.get("after_scene") != "m60_final_signature":
                errors.append(
                    f"{owner}.generic_reader.terminal.after_scene: ledger echo must follow the mandatory final scene"
                )
            if terminal.get("target") != "final_month_ledger_echo":
                errors.append(
                    f"{owner}.generic_reader.terminal.target: must consume M60 receipts in final_month_ledger_echo"
                )
            if terminal.get("next_month") is not None:
                errors.append(f"{owner}.generic_reader.terminal: M61 is forbidden")
            signature_receipt = terminal.get("signature_receipt")
            if exact_keys(
                signature_receipt, SIGNATURE_RECEIPT_KEYS,
                f"{owner}.generic_reader.terminal.signature_receipt", errors,
            ) and signature_receipt != {
                "commitment_id": "m60_sign_own_answer",
                "state_to_outcome": {
                    "completed": "signed", "expired": "leave_blank",
                },
            }:
                errors.append(
                    f"{owner}.generic_reader.terminal.signature_receipt: completed signs and expired leaves blank"
                )
        if generic.get("source") == "all_commitments" and generic_months == [1, 59]:
            generic_covered.update(
                commitment_id for commitment_id, month_number in commitment_months.items()
                if 1 <= month_number <= 59
            )
        if (
            isinstance(terminal, dict)
            and terminal.get("month") == 60
            and terminal.get("kind") == "ledger_echo"
            and terminal.get("after_scene") == "m60_final_signature"
            and terminal.get("target") == "final_month_ledger_echo"
            and terminal.get("next_month") is None
        ):
            generic_covered.update(
                commitment_id for commitment_id, month_number in commitment_months.items()
                if month_number == 60
            )
    missing_generic = set(commitment_months) - generic_covered
    if missing_generic:
        errors.append(
            f"{owner}.generic_reader: commitments missing generic consequence "
            f"{sorted(missing_generic)}"
        )
    generic_target = story_map.get("design_targets", {}).get("generic_commitments")
    if (
        not isinstance(generic_target, int)
        or isinstance(generic_target, bool)
        or generic_target != len(commitment_months)
        or len(generic_covered) != generic_target
    ):
        errors.append(
            f"{owner}.generic_reader: coverage must match map-owned generic commitment target"
        )

    readers = causality.get("named_readers")
    if not isinstance(readers, list):
        errors.append(f"{owner}.named_readers: must be an array")
        return len(generic_covered), 0, {}
    named_ids = [
        reader.get("id") for reader in readers
        if isinstance(reader, dict) and isinstance(reader.get("id"), str)
    ]
    if len(named_ids) != len(set(named_ids)):
        errors.append(f"{owner}.named_readers: duplicate reader ids")
    named_target = story_map.get("design_targets", {}).get("named_readers")
    if (
        not isinstance(named_target, int)
        or isinstance(named_target, bool)
        or named_target < 0
        or len(readers) != named_target
        or len(named_ids) != len(readers)
    ):
        errors.append(
            f"{owner}.named_readers: count and unique ids must match design target"
        )

    prior_receipt_inputs: dict[str, set[str]] = {}
    selected_producer_scenes: dict[str, set[str]] = {}
    receipt_usages: list[tuple[str, str, str]] = []
    selected_availability: dict[tuple[str, str], tuple[str, Any]] = {}

    def validate_reader_ref(value: Any, value_owner: str) -> tuple[str | None, int | None]:
        if not exact_keys(value, READER_REF_KEYS, value_owner, errors):
            return None, None
        if value.get("kind") != "scene":
            errors.append(f"{value_owner}.kind: only scene readers are allowed")
        scene_id = value.get("scene_id")
        if not isinstance(scene_id, str) or scene_id not in scene_months:
            errors.append(f"{value_owner}.scene_id: reader scene does not exist")
            return scene_id if isinstance(scene_id, str) else None, None
        return scene_id, scene_months[scene_id]

    def validate_source(
        source: Any,
        source_owner: str,
        reader_month: int | None,
        *,
        focus: bool,
    ) -> tuple[str | None, str | None, str | None]:
        if not isinstance(source, dict):
            errors.append(f"{source_owner}: must be an object")
            return None, None, None
        kind = source.get("kind")
        expected = (
            SELECTED_FOCUS_SOURCE_KEYS if focus else SELECTED_SOURCE_KEYS
        ) if kind == "selected_commitment" else (
            RECEIPT_FOCUS_SOURCE_KEYS if focus else RECEIPT_SOURCE_KEYS
        )
        if kind not in {"selected_commitment", "commitment_receipt"}:
            errors.append(f"{source_owner}.kind: must be selected_commitment or commitment_receipt")
            return None, None, None
        if not exact_keys(source, expected, source_owner, errors):
            return kind, None, None
        value = source.get("value") if focus else None
        if focus and (
            not isinstance(value, str)
            or re.fullmatch(r"[a-z][a-z0-9_]*", value) is None
        ):
            errors.append(f"{source_owner}.value: must be a lowercase focus value")
        if kind == "selected_commitment":
            commitment_id = source.get("commitment_id")
            slots = string_list(source.get("slot"), f"{source_owner}.slot", errors)
            if not slots or any(slot not in EXPECTED_SELECTION_SLOTS for slot in slots):
                errors.append(f"{source_owner}.slot: contains an unknown selection slot")
            source_month = commitment_months.get(commitment_id)
            if source_month is None:
                errors.append(f"{source_owner}.commitment_id: source commitment does not exist")
            elif reader_month is not None and source_month != reader_month:
                errors.append(f"{source_owner}: selected source must share the reader month")
            return kind, commitment_id if isinstance(commitment_id, str) else None, value
        commitment_id = source.get("source_receipt_id")
        states = string_list(source.get("state"), f"{source_owner}.state", errors)
        if states != ["completed"]:
            errors.append(f"{source_owner}.state: named resolved readers require completed")
        source_month = commitment_months.get(commitment_id)
        if source_month is None:
            errors.append(f"{source_owner}.source_receipt_id: source commitment does not exist")
        elif reader_month is not None and not source_month <= reader_month <= source_month + 1:
            errors.append(f"{source_owner}: receipt reader must be same month or the next month")
        return kind, commitment_id if isinstance(commitment_id, str) else None, value

    for index, reader in enumerate(readers):
        reader_owner = f"{owner}.named_readers[{index}]"
        if not isinstance(reader, dict):
            errors.append(f"{reader_owner}: must be an object")
            continue
        mode = reader.get("mode")
        if mode not in {"gate", "focus"}:
            errors.append(f"{reader_owner}.mode: only gate and focus are allowed")
            continue
        if not exact_keys(
            reader, GATE_READER_KEYS if mode == "gate" else FOCUS_READER_KEYS,
            reader_owner, errors,
        ):
            continue
        scene_id, reader_month = validate_reader_ref(
            reader.get("reader"), f"{reader_owner}.reader"
        )
        effect = reader.get("effect")
        effect_kind = effect.get("kind") if isinstance(effect, dict) else None
        effect_keys = EFFECT_KEYS.get(effect_kind)
        if effect_keys is None:
            errors.append(f"{reader_owner}.effect.kind: invalid {effect_kind!r}")
        else:
            exact_keys(effect, effect_keys, f"{reader_owner}.effect", errors)

        if mode == "gate":
            source_kind, commitment_id, _ = validate_source(
                reader.get("source"), f"{reader_owner}.source", reader_month,
                focus=False,
            )
            if source_kind == "selected_commitment" and commitment_id and scene_id:
                selected_producer_scenes.setdefault(commitment_id, set()).add(scene_id)
            if effect_kind == "delivery":
                if source_kind != "selected_commitment":
                    errors.append(f"{reader_owner}.effect: delivery only accepts a selected source")
                root = effect.get("root") if isinstance(effect, dict) else None
                if scene_id is not None and root not in scene_roots.get(scene_id, set()):
                    errors.append(f"{reader_owner}.effect.root: delivery root is not owned by reader scene")
            elif effect_kind == "availability":
                if source_kind != "selected_commitment":
                    errors.append(f"{reader_owner}.effect: availability only accepts a selected source")
                target = effect.get("target") if isinstance(effect, dict) else None
                if not isinstance(target, str) or not target.startswith("choice."):
                    errors.append(f"{reader_owner}.effect.target: availability target must start choice.")
                if commitment_id is not None and scene_id is not None and isinstance(target, str):
                    key = (scene_id, commitment_id)
                    if key in selected_availability:
                        errors.append(f"{reader_owner}: duplicate scene-local commitment option")
                    selected_availability[key] = (target, effect.get("after"))
            elif effect_kind in {"outcome", "cost"}:
                if source_kind != "commitment_receipt":
                    errors.append(f"{reader_owner}.effect: resolved outcome/cost requires a receipt source")
            elif effect_kind == "coverage":
                errors.append(f"{reader_owner}.effect: coverage requires focus mode")
            if source_kind == "commitment_receipt" and commitment_id and scene_id:
                receipt_usages.append((commitment_id, scene_id, reader_owner))
                source_month = commitment_months.get(commitment_id)
                if reader_month is not None and source_month is not None and source_month < reader_month:
                    prior_receipt_inputs.setdefault(scene_id, set()).add(
                        f"receipt.{commitment_id}"
                    )
        else:
            raw_sources = reader.get("sources")
            if not isinstance(raw_sources, list) or not raw_sources:
                errors.append(f"{reader_owner}.sources: must be a non-empty array")
                raw_sources = raw_sources if isinstance(raw_sources, list) else []
            source_values: set[str] = set()
            source_kinds: set[str] = set()
            for source_index, source in enumerate(raw_sources):
                source_kind, commitment_id, value = validate_source(
                    source, f"{reader_owner}.sources[{source_index}]", reader_month,
                    focus=True,
                )
                if source_kind is not None:
                    source_kinds.add(source_kind)
                if source_kind == "selected_commitment" and commitment_id and scene_id:
                    selected_producer_scenes.setdefault(commitment_id, set()).add(scene_id)
                if value is not None:
                    if value in source_values:
                        errors.append(f"{reader_owner}.sources: duplicate focus value {value}")
                    source_values.add(value)
                if source_kind == "commitment_receipt" and commitment_id and scene_id:
                    receipt_usages.append((commitment_id, scene_id, reader_owner))
                    source_month = commitment_months.get(commitment_id)
                    if reader_month is not None and source_month is not None and source_month < reader_month:
                        prior_receipt_inputs.setdefault(scene_id, set()).add(
                            f"receipt.{commitment_id}"
                        )
            if len(source_kinds) > 1:
                errors.append(f"{reader_owner}.sources: focus cannot mix selected and receipt stages")
            if reader.get("resolve") != "selection_slot_then_due_week":
                errors.append(f"{reader_owner}.resolve: must use selection slot then due week")
            fallback_value = reader.get("fallback_value")
            if (
                not isinstance(fallback_value, str)
                or re.fullmatch(r"[a-z][a-z0-9_]*", fallback_value) is None
                or fallback_value in source_values
            ):
                errors.append(f"{reader_owner}.fallback_value: must be one distinct lowercase value")
            if effect_kind != "coverage":
                errors.append(f"{reader_owner}.effect: focus must drive coverage")
            elif scene_id is not None and reader_month is not None:
                axis = effect.get("axis")
                if axis == availability_axes.get(reader_month):
                    errors.append(f"{reader_owner}.effect.axis: focus axis must differ from month availability")
                matching = [
                    coverage for coverage in scene_coverages.get(scene_id, [])
                    if coverage.get("axis") == axis
                ]
                if len(matching) != 1:
                    errors.append(f"{reader_owner}.effect.axis: reader scene needs exactly one matching coverage")
                else:
                    coverage = matching[0]
                    base_values = coverage.get("base_values", [])
                    fallbacks = coverage.get("fallbacks", [])
                    if not isinstance(base_values, list) or len(base_values) != 1:
                        errors.append(f"{reader_owner}.effect.axis: focus base must own exactly one value")
                        base_values = []
                    explicit_values: set[str] = {
                        value for value in base_values if isinstance(value, str)
                    }
                    wildcard_count = 0
                    if not isinstance(fallbacks, list):
                        fallbacks = []
                    for fallback in fallbacks:
                        if not isinstance(fallback, dict):
                            continue
                        values = fallback.get("values")
                        if values == ["*"]:
                            wildcard_count += 1
                        else:
                            if not isinstance(values, list) or len(values) != 1:
                                errors.append(f"{reader_owner}.effect.axis: each focus variant owns one value")
                            else:
                                explicit_values.update(
                                    value for value in values if isinstance(value, str)
                                )
                        # Root lifecycle is checked below against the actual KO/EN and
                        # story-rule inventories. A focus variant starts NEW/planned,
                        # then becomes an existing EXPAND/needs_rule (or mapped) root
                        # as soon as its manuscript and routing are authored.
                    if explicit_values != source_values or wildcard_count != 1:
                        errors.append(
                            f"{reader_owner}.effect.axis: focus coverage must exactly match source values plus one fallback"
                        )

    for commitment_id, scene_id, usage_owner in receipt_usages:
        if scene_id in selected_producer_scenes.get(commitment_id, set()):
            errors.append(
                f"{usage_owner}: completed receipt cannot open its own producer scene"
            )

    for (scene_id, commitment_id), (target, declared_after) in selected_availability.items():
        commitment = commitment_rows.get(commitment_id, {})
        predecessor_id = commitment.get("after")
        expected_after = None
        if isinstance(predecessor_id, str):
            predecessor = selected_availability.get((scene_id, predecessor_id))
            if predecessor is None:
                errors.append(
                    f"{owner}: {commitment_id} requires selected predecessor {predecessor_id} in the same scene"
                )
            else:
                expected_after = predecessor[0]
                predecessor_due = commitment_rows.get(predecessor_id, {}).get("due_week")
                due_week = commitment.get("due_week")
                if not (
                    isinstance(predecessor_due, int)
                    and isinstance(due_week, int)
                    and predecessor_due < due_week
                ):
                    errors.append(f"{owner}: {commitment_id} predecessor must occur earlier")
        if declared_after != expected_after:
            errors.append(
                f"{owner}: {target} after must match its selected scene-local predecessor"
            )

    terminal_scene_id = generic.get("terminal", {}).get("after_scene") \
        if isinstance(generic, dict) else None
    if terminal_scene_id not in scene_months:
        errors.append(f"{owner}.generic_reader.terminal.after_scene: scene does not exist")
    final_beats = [
        beat for beat in beats_by_month.get(60, [])
        if isinstance(beat, dict) and beat.get("scene_id") == "m60_final_signature"
    ]
    if (
        len(final_beats) != 1
        or final_beats[0].get("kind") != "decision"
        or final_beats[0].get("delivery") != "stop"
    ):
        errors.append(
            f"{owner}: m60_final_signature must remain the mandatory W240 decision stop"
        )
    if any(
        isinstance(reader, dict)
        and isinstance(reader.get("reader"), dict)
        and reader["reader"].get("scene_id") == "m60_final_signature"
        and isinstance(reader.get("effect"), dict)
        and reader["effect"].get("kind") == "delivery"
        for reader in readers
    ):
        errors.append(
            f"{owner}: M60 terminal scene cannot be delivered by a commitment receipt or selection"
        )

    def matches(reader: Any, scene: str, mode: str, effect: str) -> bool:
        return (
            isinstance(reader, dict) and reader.get("mode") == mode
            and isinstance(reader.get("reader"), dict)
            and reader["reader"].get("scene_id") == scene
            and isinstance(reader.get("effect"), dict)
            and reader["effect"].get("kind") == effect
        )

    m35_focus = [row for row in readers if matches(row, "m35_choice_heard", "focus", "coverage")]
    m35_sources = m35_focus[0].get("sources") if len(m35_focus) == 1 else None
    if not isinstance(m35_sources, list) or not m35_sources or any(
        not isinstance(source, dict) or source.get("kind") != "selected_commitment"
        for source in m35_sources
    ):
        errors.append(f"{owner}: M35 listener vertical slice needs one selected focus reader")

    m55_commitments = {
        commitment_id for commitment_id, month_number in commitment_months.items()
        if month_number == 55
    }
    m55_option_readers = [row for row in readers
                          if matches(row, "m55_three_in_room", "gate", "availability")
                          and isinstance(row.get("source"), dict)
                          and row["source"].get("kind") == "selected_commitment"]
    m55_source_ids = {
        reader["source"].get("commitment_id") for reader in m55_option_readers
    }
    if len(m55_option_readers) != 4 or m55_source_ids != m55_commitments:
        errors.append(f"{owner}: M55 vertical slice must gate each selected option exactly once")

    terminal = generic.get("terminal", {}) if isinstance(generic, dict) else {}
    signature = terminal.get("signature_receipt", {}) if isinstance(terminal, dict) else {}
    signature_id = signature.get("commitment_id") if isinstance(signature, dict) else None
    m60_sign_readers = [
        row for row in readers
        if matches(row, "m60_final_signature", "gate", "availability")
        and isinstance(row.get("source"), dict)
        and row["source"].get("kind") == "selected_commitment"
        and row["source"].get("commitment_id") == signature_id
        and row["effect"].get("target") == "choice.sign"
    ]
    if len(m60_sign_readers) != 1:
        errors.append(f"{owner}: M60 signature needs one selected gate before terminal echo")
    return len(generic_covered), len(readers), prior_receipt_inputs


@dataclass
class Stats:
    months: int = 0
    commitments: int = 0
    availability_months: int = 0
    availability_scenarios: int = 0
    conditional_commitments: int = 0
    beats: int = 0
    fallbacks: int = 0
    planned_fallbacks: int = 0
    stops: int = 0
    existing: int = 0
    planned: int = 0
    needs_rule: int = 0
    generic_commitments: int = 0
    named_readers: int = 0


def validate_story_map(
    story_map: Any,
    rules: Any,
    spine: Any,
    ko_ids: set[str],
    en_ids: set[str],
) -> tuple[list[str], Stats]:
    errors: list[str] = []
    stats = Stats()
    if not exact_keys(story_map, TOP_KEYS, "story_map", errors):
        if not isinstance(story_map, dict):
            return errors, stats

    if story_map.get("schema_version") != 1:
        errors.append("story_map.schema_version: must be 1")
    scope = story_map.get("scope")
    if exact_keys(scope, {"months", "weeks_per_month", "months_per_chapter"}, "scope", errors):
        if scope != {"months": [1, 60], "weeks_per_month": 4, "months_per_chapter": 12}:
            errors.append("scope: must describe M01..M60 as five 12-month chapters")
    targets = story_map.get("design_targets")
    target_shape = {
        "direct_stops", "history_inputs_per_scene", "decision_inputs_per_scene",
        "named_readers", "generic_commitments",
    }
    if exact_keys(targets, target_shape, "design_targets", errors):
        if (
            targets.get("direct_stops") != [45, 51]
            or targets.get("history_inputs_per_scene") != 2
            or targets.get("decision_inputs_per_scene") != 1
        ):
            errors.append("design_targets: approved targets are stops 45..51, scene history 2, decision 1")
        for count_key in ("named_readers", "generic_commitments"):
            value = targets.get(count_key)
            if not isinstance(value, int) or isinstance(value, bool) or value < 0:
                errors.append(f"design_targets.{count_key}: must be a non-negative integer")
    loop_contract = story_map.get("loop_contract")
    loop_keys = {
        "routine", "candidate_sources", "candidate_count", "protected_commitments",
        "optional_second", "order_prompt", "random_incidents", "retired_selectable_ids",
        "miss_consequences",
    }
    retired_selectable_ids: set[str] = set()
    if exact_keys(loop_contract, loop_keys, "loop_contract", errors):
        expected_loop_core = {
            "routine": "automatic_until_changed",
            "candidate_sources": ["pressure", "opportunity", "person_promise"],
            "candidate_count": [2, 4],
            "protected_commitments": 1,
            "optional_second": {"maximum": 1, "margin_axes": ["cash", "health", "trust"], "margin_capacity": 1,
                "initial_margin": None, "margin_lifetime_months": 1, "requires": "same_axis_margin", "consumes": "on_confirm", "completion_refund": False, "single_protected_completion": "next_month_same_axis_margin_unless_selected_repaid_burden", "double_month_next_margin": None},
            "order_prompt": "dependency_or_deadline_only",
            "random_incidents": "modify_cost_or_conflict_never_close",
            "miss_consequences": EXPECTED_MISS_CONSEQUENCES,
        }
        if any(loop_contract.get(key) != value for key, value in expected_loop_core.items()):
            errors.append("loop_contract: must preserve the approved monthly choice grammar")
        retired_rows = string_list(
            loop_contract.get("retired_selectable_ids"),
            "loop_contract.retired_selectable_ids", errors,
        )
        if not retired_rows:
            errors.append("loop_contract.retired_selectable_ids: tombstones must not be empty")
        if any(re.fullmatch(r"m\d{2}_[a-z0-9_]+", row) is None for row in retired_rows):
            errors.append(
                "loop_contract.retired_selectable_ids: ids must be canonical commitment ids"
            )
        retired_selectable_ids = set(retired_rows)
    if story_map.get("vertical_slices") != EXPECTED_VERTICAL_SLICES:
        errors.append("vertical_slices: must declare exact M01/M35/M55 contracts")

    decisions = string_list(story_map.get("long_term_decisions"), "long_term_decisions", errors)
    if len(decisions) != 7 or set(decisions) != EXPECTED_DECISIONS:
        errors.append("long_term_decisions: must be the exact seven approved facts")
    fact_types = rules.get("fact_types", {}) if isinstance(rules, dict) else {}
    rule_events = rules.get("events", {}) if isinstance(rules, dict) else {}
    if not isinstance(fact_types, dict):
        errors.append("story_rules.fact_types: must be an object")
        fact_types = {}
    if not isinstance(rule_events, dict):
        errors.append("story_rules.events: must be an object")
        rule_events = {}
    for fact_id in decisions:
        if fact_types.get(fact_id) != EXPECTED_DECISION_SPECS[fact_id]:
            errors.append(f"long_term_decisions: story_rules fact {fact_id} has the wrong enum contract")

    slots = story_map.get("carryover_slots")
    if not isinstance(slots, dict):
        errors.append("carryover_slots: must be an object")
        slots = {}
    if set(slots) != EXPECTED_SLOTS:
        errors.append("carryover_slots: must contain the exact four approved slots")
    for slot, spec in slots.items():
        if spec != EXPECTED_CARRYOVER_SPEC:
            errors.append(
                f"carryover_slots.{slot}: must preserve kind/source receipt and optional actor"
            )

    spine_chapters = spine.get("chapters", []) if isinstance(spine, dict) else []
    spine_weeks = {
        row.get("number"): row.get("weeks")
        for row in spine_chapters if isinstance(row, dict)
    }
    chapters = story_map.get("chapters")
    if not isinstance(chapters, list) or len(chapters) != 5:
        errors.append("chapters: must contain exactly five chapters")
        chapters = chapters if isinstance(chapters, list) else []

    months: list[dict[str, Any]] = []
    beats_by_month: dict[int, list[dict[str, Any]]] = {}
    beat_ids: set[str] = set()
    root_owners: dict[str, tuple[int, str]] = {}
    memory_writers: dict[str, tuple[int, str]] = {}
    memory_readers: dict[str, list[tuple[int, str]]] = {}
    decision_writers: dict[str, list[tuple[int, str]]] = {}
    decision_readers: dict[str, list[tuple[int, str]]] = {}
    carry_writers: dict[int, dict[str, list[int]]] = {}
    carry_readers: dict[int, set[str]] = {}
    commitment_ids: set[str] = set()
    commitment_months: dict[str, int] = {}
    availability_receipt_refs: list[tuple[str, str, int]] = []
    scene_inputs: dict[str, dict[str, set[str]]] = {}
    stop_scene_ids: set[str] = set()
    chapter5_product_months: dict[str, list[int]] = {
        root_id: [] for root_id in EXPECTED_CHAPTER5_PRODUCT_MONTHS
    }
    coverage_months: set[int] = set()

    for chapter_index, chapter in enumerate(chapters, start=1):
        owner = f"chapters[{chapter_index - 1}]"
        if not exact_keys(chapter, CHAPTER_KEYS, owner, errors):
            continue
        if chapter.get("chapter") != chapter_index:
            errors.append(f"{owner}.chapter: must be {chapter_index}")
        expected_weeks = [(chapter_index - 1) * 48 + 1, chapter_index * 48]
        if spine_weeks.get(chapter_index) != expected_weeks:
            errors.append(f"narrative_spine chapter {chapter_index}: weeks must be {expected_weeks}")
        if chapter_index < 5:
            chapter_carryover = string_list(
                chapter.get("carryover"), f"{owner}.carryover", errors
            )
            if set(chapter_carryover) != EXPECTED_SLOTS:
                errors.append(f"{owner}.carryover: must list the canonical four slots")
        if chapter_index == 5 and chapter.get("carryover") is not None:
            errors.append(f"{owner}.carryover: chapter 5 must be null")

        chapter_months = chapter.get("months")
        if not isinstance(chapter_months, list) or len(chapter_months) != 12:
            errors.append(f"{owner}.months: must contain exactly 12 months")
            chapter_months = chapter_months if isinstance(chapter_months, list) else []
        for local_index, month in enumerate(chapter_months, start=1):
            month_number = (chapter_index - 1) * 12 + local_index
            month_owner = f"{owner}.months[{local_index - 1}]"
            allowed_month_keys = set(MONTH_KEYS)
            availability_declared = isinstance(month, dict) and "availability" in month
            if availability_declared:
                allowed_month_keys.add("availability")
            if not exact_keys(month, allowed_month_keys, month_owner, errors):
                continue
            if month.get("month") != month_number:
                errors.append(f"{month_owner}.month: must be {month_number}")
            if not isinstance(month.get("design_label"), str) or not month["design_label"].strip():
                errors.append(f"{month_owner}.design_label: must be non-empty")
            if month.get("phase") not in PHASES:
                errors.append(f"{month_owner}.phase: invalid {month.get('phase')!r}")
            if local_index == 12 and month.get("phase") != "boss":
                errors.append(f"{month_owner}.phase: final month must be boss")
            contract = month.get("contract")
            if exact_keys(contract, CONTRACT_KEYS, f"{month_owner}.contract", errors):
                for key in CONTRACT_KEYS:
                    if not isinstance(contract.get(key), str) or not contract[key].strip():
                        errors.append(f"{month_owner}.contract.{key}: must be non-empty")

            availability_values: list[str] = []
            if availability_declared:
                stats.availability_months += 1
                availability = month.get("availability")
                if exact_keys(
                    availability, AVAILABILITY_KEYS,
                    f"{month_owner}.availability", errors,
                ):
                    availability_axis = availability.get("axis")
                    availability_values = string_list(
                        availability.get("values"),
                        f"{month_owner}.availability.values", errors,
                    )
                    if not availability_values:
                        errors.append(
                            f"{month_owner}.availability.values: must be finite and non-empty"
                        )
                    if "*" in availability_values:
                        errors.append(
                            f"{month_owner}.availability.values: wildcard is not a finite route value"
                        )
                    if any(
                        re.fullmatch(r"[a-z][a-z0-9_]*", value) is None
                        for value in availability_values
                    ):
                        errors.append(
                            f"{month_owner}.availability.values: values must be lowercase identifiers"
                        )

                    if isinstance(availability_axis, str) and availability_axis in fact_types:
                        if availability_axis in EXPECTED_DECISIONS:
                            decision_readers.setdefault(availability_axis, []).append(
                                (month_number, f"M{month_number:02}.availability")
                            )
                        fact_spec = fact_types.get(availability_axis)
                        fact_values = fact_spec.get("values") \
                            if isinstance(fact_spec, dict) else None
                        if (
                            not isinstance(fact_spec, dict)
                            or fact_spec.get("type") != "enum"
                            or not isinstance(fact_values, list)
                            or not all(isinstance(value, str) for value in fact_values)
                        ):
                            errors.append(
                                f"{month_owner}.availability.axis: story fact must be a finite enum"
                            )
                        else:
                            invalid_values = set(availability_values) - set(fact_values)
                            if invalid_values:
                                errors.append(
                                    f"{month_owner}.availability.values: outside story fact enum "
                                    f"{sorted(invalid_values)}"
                                )
                    elif isinstance(availability_axis, str) and re.fullmatch(
                        r"receipt\.(m\d{2}_[a-z0-9_]+)\.state", availability_axis,
                    ):
                        match = re.fullmatch(
                            r"receipt\.(m\d{2}_[a-z0-9_]+)\.state", availability_axis,
                        )
                        assert match is not None
                        availability_receipt_refs.append(
                            (f"{month_owner}.availability.axis", match.group(1), month_number)
                        )
                        invalid_values = set(availability_values) - RECEIPT_STATES
                        if invalid_values:
                            errors.append(
                                f"{month_owner}.availability.values: invalid receipt states "
                                f"{sorted(invalid_values)}"
                            )
                    elif not (
                        isinstance(availability_axis, str)
                        and re.fullmatch(
                            rf"route\.m{month_number:02}\.[a-z][a-z0-9_]*",
                            availability_axis,
                        )
                    ):
                        errors.append(
                            f"{month_owner}.availability.axis: must be an approved story fact, "
                            "earlier receipt state, or local route axis"
                        )
                    stats.availability_scenarios += len(availability_values)
            commitments = month.get("commitments")
            if not isinstance(commitments, list) or not 2 <= len(commitments) <= 4:
                errors.append(f"{month_owner}.commitments: must contain 2..4 concrete candidates")
                commitments = commitments if isinstance(commitments, list) else []
            month_sources: set[str] = set()
            month_axes: set[str] = set()
            month_labels: set[str] = set()
            month_commitment_ids: set[str] = set()
            month_dependencies: dict[str, str] = {}
            month_due_weeks: dict[str, int] = {}
            first_week = (month_number - 1) * 4 + 1
            month_week_range = range(first_week, first_week + 4)
            for commitment_index, commitment in enumerate(commitments):
                commitment_owner = f"{month_owner}.commitments[{commitment_index}]"
                allowed_commitment = set(COMMITMENT_KEYS)
                if month_number <= 6 and isinstance(commitment, dict) and "strategy" in commitment: allowed_commitment.add("strategy")
                if isinstance(commitment, dict) and "actor_slots" in commitment:
                    allowed_commitment.add("actor_slots")
                if availability_declared or (
                    isinstance(commitment, dict) and "available_values" in commitment
                ):
                    allowed_commitment.add("available_values")
                if not exact_keys(commitment, allowed_commitment, commitment_owner, errors):
                    continue
                commitment_id = commitment.get("id")
                if not isinstance(commitment_id, str) or not commitment_id.startswith(f"m{month_number:02}_"):
                    errors.append(f"{commitment_owner}.id: must start m{month_number:02}_")
                elif commitment_id in commitment_ids:
                    errors.append(f"{commitment_owner}.id: duplicate {commitment_id}")
                else:
                    commitment_ids.add(commitment_id)
                    month_commitment_ids.add(commitment_id)
                    commitment_months[commitment_id] = month_number
                source = commitment.get("source")
                if source not in COMMITMENT_SOURCES:
                    errors.append(f"{commitment_owner}.source: invalid {source!r}")
                else:
                    month_sources.add(source)
                axis = commitment.get("axis")
                if axis not in COMMITMENT_AXES:
                    errors.append(f"{commitment_owner}.axis: invalid {axis!r}")
                else:
                    month_axes.add(axis)
                label = commitment.get("label")
                if not isinstance(label, str) or len(label.strip()) < 4:
                    errors.append(f"{commitment_owner}.label: must be a concrete player action")
                elif label in month_labels:
                    errors.append(f"{commitment_owner}.label: duplicate monthly action")
                else:
                    month_labels.add(label)
                due_week = commitment.get("due_week")
                if not isinstance(due_week, int) or isinstance(due_week, bool) or due_week not in month_week_range:
                    errors.append(f"{commitment_owner}.due_week: must be inside M{month_number:02}")
                elif isinstance(commitment_id, str):
                    month_due_weeks[commitment_id] = due_week
                if commitment.get("miss") not in MISSED_RESULTS:
                    errors.append(f"{commitment_owner}.miss: must be deferred or expired")
                after = commitment.get("after")
                if after is not None and not isinstance(after, str):
                    errors.append(f"{commitment_owner}.after: must be null or a commitment id")
                elif isinstance(commitment_id, str) and isinstance(after, str):
                    month_dependencies[commitment_id] = after
                if "actor_slots" in commitment:
                    actor_slots = string_list(
                        commitment.get("actor_slots"),
                        f"{commitment_owner}.actor_slots",
                        errors,
                    )
                    if any(
                        re.fullmatch(r"[a-z][a-z0-9_]*", slot) is None
                        for slot in actor_slots
                    ):
                        errors.append(
                            f"{commitment_owner}.actor_slots: roles must be lowercase identifiers"
                        )
                if availability_declared:
                    available_values = string_list(
                        commitment.get("available_values"),
                        f"{commitment_owner}.available_values", errors,
                    )
                    if not available_values:
                        errors.append(
                            f"{commitment_owner}.available_values: must be non-empty"
                        )
                    elif available_values == ["*"]:
                        pass
                    elif "*" in available_values:
                        errors.append(
                            f"{commitment_owner}.available_values: wildcard must stand alone"
                        )
                    else:
                        invalid_values = set(available_values) - set(availability_values)
                        if invalid_values:
                            errors.append(
                                f"{commitment_owner}.available_values: outside availability values "
                                f"{sorted(invalid_values)}"
                            )
                        stats.conditional_commitments += 1
                elif "available_values" in commitment:
                    errors.append(
                        f"{commitment_owner}.available_values: requires month availability"
                    )
                stats.commitments += 1
            if commitments and "pressure" not in month_sources:
                errors.append(f"{month_owner}.commitments: pressure source is required")
            if commitments and not month_sources & {"opportunity", "person_promise"}:
                errors.append(
                    f"{month_owner}.commitments: needs opportunity or person_promise beside pressure"
                )
            if commitments and len(month_axes) < 2:
                errors.append(f"{month_owner}.commitments: must create a conflict across at least two axes")
            if availability_declared and availability_values:
                for scenario_value in availability_values:
                    visible = []
                    for commitment in commitments:
                        if not isinstance(commitment, dict):
                            continue
                        raw_available = commitment.get("available_values")
                        if not isinstance(raw_available, list):
                            continue
                        if raw_available == ["*"] or scenario_value in raw_available:
                            visible.append(commitment)
                    scenario_owner = (
                        f"{month_owner}.availability[{scenario_value}]"
                    )
                    if not 2 <= len(visible) <= 4:
                        errors.append(
                            f"{scenario_owner}: must expose 2..4 visible commitments, "
                            f"got {len(visible)}"
                        )
                    visible_sources = {
                        commitment.get("source") for commitment in visible
                    }
                    if "pressure" not in visible_sources:
                        errors.append(f"{scenario_owner}: visible pressure source is required")
                    if not visible_sources & {"opportunity", "person_promise"}:
                        errors.append(
                            f"{scenario_owner}: visible opportunity or person_promise is required"
                        )
                    visible_axes = {
                        commitment.get("axis") for commitment in visible
                        if commitment.get("axis") in COMMITMENT_AXES
                    }
                    if len(visible_axes) < 2:
                        errors.append(
                            f"{scenario_owner}: visible commitments need at least two axes"
                        )
            capacity_scenarios: list[tuple[str, list[dict[str, Any]]]] = []
            if availability_declared and availability_values:
                for scenario_value in availability_values:
                    visible = [
                        commitment for commitment in commitments
                        if isinstance(commitment, dict)
                        and (
                            commitment.get("available_values") == ["*"]
                            or scenario_value in commitment.get("available_values", [])
                        )
                    ]
                    capacity_scenarios.append((str(scenario_value), visible))
            else:
                capacity_scenarios.append(("all", [
                    commitment for commitment in commitments
                    if isinstance(commitment, dict)
                ]))
            for scenario_value, visible in capacity_scenarios:
                scenario_owner = f"{month_owner}.capacity[{scenario_value}]"
                actionable = [
                    commitment for commitment in visible
                    if commitment.get("after") is None
                ]
                if len(actionable) < 2:
                    errors.append(
                        f"{scenario_owner}: capacity=1 needs at least two actionable commitments; "
                        "after successors remain locked"
                    )
                visible_ids = {
                    commitment.get("id") for commitment in visible
                    if isinstance(commitment.get("id"), str)
                }
                for successor in visible:
                    predecessor = successor.get("after")
                    if isinstance(predecessor, str) and predecessor not in visible_ids:
                        errors.append(
                            f"{scenario_owner}: capacity=2 locked successor "
                            f"{successor.get('id')} has no visible predecessor {predecessor}"
                        )
            for commitment_id, predecessor in month_dependencies.items():
                if predecessor not in month_commitment_ids:
                    errors.append(f"{month_owner}.commitments: {commitment_id} depends outside its month")
                elif month_due_weeks.get(predecessor, 241) >= month_due_weeks.get(commitment_id, 0):
                    errors.append(
                        f"{month_owner}.commitments: {predecessor} must be due before {commitment_id}"
                    )
                seen: set[str] = {commitment_id}
                cursor = predecessor
                depth = 1
                while cursor in month_dependencies:
                    if cursor in seen:
                        errors.append(f"{month_owner}.commitments: dependency cycle at {cursor}")
                        break
                    seen.add(cursor)
                    cursor = month_dependencies[cursor]
                    depth += 1
                if depth > 1:
                    errors.append(
                        f"{month_owner}.commitments: dependency chain exceeds two selectable commitments"
                    )
            raw_beats = month.get("beats")
            if not isinstance(raw_beats, list) or not raw_beats:
                errors.append(f"{month_owner}.beats: every month needs at least one beat")
                raw_beats = raw_beats if isinstance(raw_beats, list) else []
            months.append(month)
            beats_by_month[month_number] = raw_beats

            for beat_index, beat in enumerate(raw_beats):
                beat_owner = f"{month_owner}.beats[{beat_index}]"
                allowed = set(BEAT_KEYS)
                if isinstance(beat, dict) and "source_month" in beat:
                    allowed.add("source_month")
                for optional_key in (
                    "coverage", "role_bindings", "distinct_roles", "coalesce_roles",
                    "actor_outputs", "selector",
                ):
                    if isinstance(beat, dict) and optional_key in beat:
                        allowed.add(optional_key)
                if not exact_keys(beat, allowed, beat_owner, errors):
                    continue
                stats.beats += 1
                beat_id = beat.get("id")
                if not isinstance(beat_id, str) or not beat_id.strip():
                    errors.append(f"{beat_owner}.id: must be non-empty")
                    beat_id = f"<invalid:{month_number}:{beat_index}>"
                elif beat_id in beat_ids:
                    errors.append(f"{beat_owner}.id: duplicate {beat_id}")
                beat_ids.add(beat_id)
                scene_id = beat.get("scene_id")
                if not isinstance(scene_id, str) or not scene_id.startswith(f"m{month_number:02}_"):
                    errors.append(f"{beat_owner}.scene_id: must start m{month_number:02}_")
                    scene_id = f"<invalid-scene:{month_number}:{beat_index}>"
                scene_state = scene_inputs.setdefault(
                    scene_id, {
                        "memories": set(), "carryovers": set(),
                        "decisions": set(), "coverage_axes": set(),
                    }
                )
                for key, allowed_values in (
                    ("kind", KINDS), ("delivery", DELIVERIES), ("work", WORK_TYPES),
                    ("rule_status", RULE_STATUSES), ("channel", CHANNELS),
                ):
                    if not isinstance(beat.get(key), str) or beat.get(key) not in allowed_values:
                        errors.append(f"{beat_owner}.{key}: invalid {beat.get(key)!r}")
                if not isinstance(beat.get("intent"), str) or len(beat["intent"].strip()) < 15:
                    errors.append(f"{beat_owner}.intent: must state a concrete design purpose")
                cast = string_list(beat.get("cast"), f"{beat_owner}.cast", errors)
                if not cast:
                    errors.append(f"{beat_owner}.cast: must not be empty")
                unresolved_cast = {
                    "father_or_hyunsu", "partner", "final_proposer",
                    "chosen_reviewer", "protected_person", "deal_owner",
                }
                if any(actor in unresolved_cast for actor in cast):
                    errors.append(f"{beat_owner}.cast: unresolved role names must use @role bindings")
                role_refs = [actor for actor in cast if actor.startswith("@")]
                if not role_refs and (
                    any(key in beat for key in ("role_bindings", "distinct_roles", "coalesce_roles"))
                ):
                    errors.append(f"{beat_owner}: role metadata requires @roles in cast")
                forgone = string_list(beat.get("forgone"), f"{beat_owner}.forgone", errors)
                if beat.get("delivery") == "stop":
                    stop_scene_ids.add(scene_id)
                    if not forgone:
                        errors.append(f"{beat_owner}.forgone: stop beats need a real forgone path")

                work = beat.get("work")
                if work == "MOVE":
                    source_month = beat.get("source_month")
                    if not isinstance(source_month, int) or isinstance(source_month, bool):
                        errors.append(f"{beat_owner}.source_month: MOVE requires an integer")
                    elif not 1 <= source_month <= 60 or source_month == month_number:
                        errors.append(f"{beat_owner}.source_month: must name a different month in 1..60")
                elif "source_month" in beat:
                    if work != "EXPAND":
                        errors.append(f"{beat_owner}.source_month: only MOVE/EXPAND may declare it")
                    elif not isinstance(beat.get("source_month"), int) or isinstance(beat.get("source_month"), bool):
                        errors.append(f"{beat_owner}.source_month: EXPAND source must be an integer")
                    elif not 1 <= beat["source_month"] <= 60:
                        errors.append(f"{beat_owner}.source_month: must be in 1..60")

                root = beat.get("root")
                if not isinstance(root, str) or not root.strip():
                    errors.append(f"{beat_owner}.root: must be non-empty")
                    root = f"<invalid-root:{month_number}:{beat_index}>"
                if root in chapter5_product_months:
                    chapter5_product_months[root].append(month_number)
                relocation = EXPECTED_RELOCATIONS.get(root)
                if relocation and (month_number, work, beat.get("source_month")) != relocation:
                    errors.append(
                        f"{beat_owner}: {root} relocation must be "
                        f"M{relocation[0]:02} {relocation[1]} from M{relocation[2]:02}"
                    )
                if root in root_owners:
                    old_month, old_beat = root_owners[root]
                    errors.append(f"{beat_owner}.root: {root} already owned by M{old_month:02} {old_beat}")
                else:
                    root_owners[root] = (month_number, beat_id)
                in_ko, in_en, in_rules = root in ko_ids, root in en_ids, root in rule_events
                if work == "NEW":
                    stats.planned += 1
                    if beat.get("rule_status") != "planned":
                        errors.append(f"{beat_owner}: NEW roots must have rule_status planned")
                    if in_ko or in_en or in_rules:
                        errors.append(f"{beat_owner}: NEW root {root} already exists")
                else:
                    stats.existing += 1
                    if not in_ko or not in_en:
                        errors.append(f"{beat_owner}: existing root {root} must exist in KO and EN")
                    coverage_axis = beat.get("coverage", {}).get("axis")
                    declared_reads = {
                        fact for fact in (
                            beat.get("reads", {}).get("decision"),
                            coverage_axis if coverage_axis in EXPECTED_DECISIONS else None,
                        ) if isinstance(fact, str) and fact in EXPECTED_DECISIONS
                    }
                    declared_writes = {
                        fact for fact in (beat.get("writes", {}).get("decision"),)
                        if isinstance(fact, str) and fact in EXPECTED_DECISIONS
                    }
                    coverage_values = None
                    if coverage_axis in EXPECTED_DECISIONS:
                        raw_values = beat.get("coverage", {}).get("base_values")
                        if isinstance(raw_values, list) and all(
                            isinstance(value, str) for value in raw_values
                        ):
                            coverage_values = set(raw_values)
                    mapping_matches, malformed_rule = exact_rule_mapping(
                        rule_events.get(root),
                        declared_reads,
                        declared_writes,
                        coverage_axis=(coverage_axis if coverage_axis in EXPECTED_DECISIONS else None),
                        coverage_values=coverage_values,
                    )
                    exact_rule_link = in_rules and mapping_matches
                    expected_status = "mapped" if exact_rule_link else "needs_rule"
                    if beat.get("rule_status") == "mapped":
                        for issue in malformed_rule:
                            errors.append(f"{beat_owner}: {root} rule enum contract invalid: {issue}")
                    if beat.get("rule_status") != expected_status:
                        errors.append(f"{beat_owner}: {root} rule_status must be {expected_status}")
                    if expected_status == "needs_rule":
                        stats.needs_rule += 1

                for io_name in ("reads", "writes"):
                    io_value = beat.get(io_name)
                    if not exact_keys(io_value, IO_KEYS, f"{beat_owner}.{io_name}", errors):
                        continue
                    memories = string_list(io_value.get("memories"), f"{beat_owner}.{io_name}.memories", errors)
                    carryovers = string_list(io_value.get("carryovers"), f"{beat_owner}.{io_name}.carryovers", errors)
                    decision = io_value.get("decision")
                    if decision is not None and (
                        not isinstance(decision, str) or decision not in EXPECTED_DECISIONS
                    ):
                        errors.append(f"{beat_owner}.{io_name}.decision: must be null or an approved fact")
                    if len(memories) > 2:
                        errors.append(f"{beat_owner}.{io_name}.memories: maximum is 2")
                    if io_name == "reads" and len(memories) + len(carryovers) > 2:
                        errors.append(f"{beat_owner}.reads: history inputs maximum is 2")
                    if any(not memory.startswith("memory.") for memory in memories):
                        errors.append(f"{beat_owner}.{io_name}.memories: ids must start memory.")
                    if any(slot not in EXPECTED_SLOTS for slot in carryovers):
                        errors.append(f"{beat_owner}.{io_name}.carryovers: unknown slot")
                    if io_name == "reads":
                        scene_state["memories"].update(memories)
                        scene_state["carryovers"].update(carryovers)
                        if isinstance(decision, str):
                            scene_state["decisions"].add(decision)
                        for memory in memories:
                            memory_readers.setdefault(memory, []).append((month_number, beat_id))
                        carry_readers.setdefault(chapter_index, set()).update(carryovers)
                        if isinstance(decision, str):
                            decision_readers.setdefault(decision, []).append((month_number, beat_id))
                    else:
                        for memory in memories:
                            if memory in memory_writers:
                                errors.append(f"{beat_owner}: memory {memory} already has a writer")
                            else:
                                memory_writers[memory] = (month_number, beat_id)
                        for slot in carryovers:
                            carry_writers.setdefault(chapter_index, {}).setdefault(slot, []).append(month_number)
                        if isinstance(decision, str):
                            decision_writers.setdefault(decision, []).append((month_number, beat_id))

                coverage = beat.get("coverage")
                if coverage is not None:
                    coverage_months.add(month_number)
                    if not exact_keys(coverage, COVERAGE_KEYS, f"{beat_owner}.coverage", errors):
                        coverage = {}
                    axis = coverage.get("axis")
                    if isinstance(axis, str):
                        scene_state["coverage_axes"].add(axis)
                    is_story_axis = isinstance(axis, str) and axis in EXPECTED_DECISIONS
                    is_route_axis = (
                        isinstance(axis, str)
                        and re.fullmatch(rf"route\.m{month_number:02}\.[a-z0-9_]+", axis) is not None
                    )
                    if is_story_axis:
                        if beat.get("reads", {}).get("decision") != axis:
                            errors.append(
                                f"{beat_owner}.coverage: base reads.decision must equal story axis {axis}"
                            )
                        scene_state["decisions"].add(axis)
                        decision_readers.setdefault(axis, []).append((month_number, beat_id))
                    if not is_story_axis and not is_route_axis:
                        errors.append(f"{beat_owner}.coverage.axis: must be an approved fact or local route axis")
                    base_values = string_list(
                        coverage.get("base_values"), f"{beat_owner}.coverage.base_values", errors
                    )
                    if not base_values:
                        errors.append(f"{beat_owner}.coverage.base_values: must not be empty")
                    seen_values = set(base_values)
                    fallbacks = coverage.get("fallbacks")
                    if not isinstance(fallbacks, list) or not fallbacks:
                        errors.append(f"{beat_owner}.coverage.fallbacks: must not be empty")
                        fallbacks = fallbacks if isinstance(fallbacks, list) else []
                    wildcard_fallbacks = 0
                    for fallback_index, fallback in enumerate(fallbacks):
                        stats.fallbacks += 1
                        fallback_owner = f"{beat_owner}.coverage.fallbacks[{fallback_index}]"
                        allowed_fallback = set(FALLBACK_KEYS)
                        if isinstance(fallback, dict) and "source_month" in fallback:
                            allowed_fallback.add("source_month")
                        for optional_key in FALLBACK_OPTIONAL_KEYS:
                            if isinstance(fallback, dict) and optional_key in fallback:
                                allowed_fallback.add(optional_key)
                        if not exact_keys(fallback, allowed_fallback, fallback_owner, errors):
                            continue
                        values = string_list(fallback.get("values"), f"{fallback_owner}.values", errors)
                        if not values:
                            errors.append(f"{fallback_owner}.values: must not be empty")
                        if values == ["*"]:
                            wildcard_fallbacks += 1
                            if fallback_index != len(fallbacks) - 1:
                                errors.append(f"{fallback_owner}.values: wildcard fallback must be last")
                        elif "*" in values:
                            errors.append(f"{fallback_owner}.values: wildcard must stand alone")
                        overlap = seen_values & set(values)
                        if overlap:
                            errors.append(f"{fallback_owner}.values: duplicate coverage {sorted(overlap)}")
                        seen_values.update(values)

                        fallback_work = fallback.get("work")
                        if fallback_work not in WORK_TYPES:
                            errors.append(f"{fallback_owner}.work: invalid {fallback_work!r}")
                        if fallback_work == "MOVE":
                            source_month = fallback.get("source_month")
                            if not isinstance(source_month, int) or isinstance(source_month, bool):
                                errors.append(f"{fallback_owner}.source_month: MOVE requires an integer")
                            elif not 1 <= source_month <= 60 or source_month == month_number:
                                errors.append(f"{fallback_owner}.source_month: invalid relocation source")
                        elif "source_month" in fallback:
                            if fallback_work != "EXPAND":
                                errors.append(f"{fallback_owner}.source_month: only MOVE/EXPAND may declare it")
                            elif not isinstance(fallback.get("source_month"), int) or isinstance(fallback.get("source_month"), bool):
                                errors.append(f"{fallback_owner}.source_month: EXPAND source must be an integer")

                        fallback_channel = fallback.get("channel")
                        if fallback_channel not in CHANNELS:
                            errors.append(f"{fallback_owner}.channel: invalid {fallback_channel!r}")
                        fallback_cast = string_list(fallback.get("cast"), f"{fallback_owner}.cast", errors)
                        if not fallback_cast:
                            errors.append(f"{fallback_owner}.cast: must not be empty")
                        if any(actor in unresolved_cast for actor in fallback_cast):
                            errors.append(f"{fallback_owner}.cast: unresolved role names must use @role bindings")
                        fallback_forgone = string_list(
                            fallback.get("forgone"), f"{fallback_owner}.forgone", errors
                        )
                        if beat.get("delivery") == "stop" and not fallback_forgone:
                            errors.append(f"{fallback_owner}.forgone: stop fallback needs a real forgone path")

                        fallback_reads = fallback.get("reads")
                        if exact_keys(fallback_reads, IO_KEYS, f"{fallback_owner}.reads", errors):
                            memories = string_list(
                                fallback_reads.get("memories"), f"{fallback_owner}.reads.memories", errors
                            )
                            carryovers = string_list(
                                fallback_reads.get("carryovers"), f"{fallback_owner}.reads.carryovers", errors
                            )
                            decision = fallback_reads.get("decision")
                            if decision is not None and (
                                not isinstance(decision, str) or decision not in EXPECTED_DECISIONS
                            ):
                                errors.append(f"{fallback_owner}.reads.decision: invalid decision")
                            if is_story_axis and decision != axis:
                                errors.append(
                                    f"{fallback_owner}.reads.decision: must equal story axis {axis}"
                                )
                            if any(not memory.startswith("memory.") for memory in memories):
                                errors.append(f"{fallback_owner}.reads.memories: ids must start memory.")
                            if any(slot not in EXPECTED_SLOTS for slot in carryovers):
                                errors.append(f"{fallback_owner}.reads.carryovers: unknown slot")
                            scene_state["memories"].update(memories)
                            scene_state["carryovers"].update(carryovers)
                            if isinstance(decision, str):
                                scene_state["decisions"].add(decision)
                                decision_readers.setdefault(decision, []).append((month_number, beat_id))
                            for memory in memories:
                                memory_readers.setdefault(memory, []).append((month_number, beat_id))
                            carry_readers.setdefault(chapter_index, set()).update(carryovers)

                        fallback_root = fallback.get("root")
                        if not isinstance(fallback_root, str) or not fallback_root.strip():
                            errors.append(f"{fallback_owner}.root: must be non-empty")
                            continue
                        if fallback_root in chapter5_product_months:
                            chapter5_product_months[fallback_root].append(month_number)
                        old_owner = root_owners.get(fallback_root)
                        if old_owner is not None and old_owner != (month_number, beat_id):
                            errors.append(
                                f"{fallback_owner}.root: {fallback_root} already owned by "
                                f"M{old_owner[0]:02} {old_owner[1]}"
                            )
                        else:
                            root_owners[fallback_root] = (month_number, beat_id)
                        in_ko = fallback_root in ko_ids
                        in_en = fallback_root in en_ids
                        in_rules = fallback_root in rule_events
                        fallback_status = fallback.get("rule_status")
                        if fallback_work == "NEW":
                            stats.planned_fallbacks += 1
                            if fallback_status != "planned" or in_ko or in_en or in_rules:
                                errors.append(f"{fallback_owner}: NEW fallback must be absent and planned")
                        else:
                            if not in_ko or not in_en:
                                errors.append(f"{fallback_owner}: existing fallback must exist in KO and EN")
                            declared_reads = {
                                fact for fact in (
                                    fallback.get("reads", {}).get("decision"),
                                    axis if is_story_axis else None,
                                ) if isinstance(fact, str) and fact in EXPECTED_DECISIONS
                            }
                            declared_writes = {
                                fact for fact in (beat.get("writes", {}).get("decision"),)
                                if isinstance(fact, str) and fact in EXPECTED_DECISIONS
                            }
                            mapping_matches, malformed_rule = exact_rule_mapping(
                                rule_events.get(fallback_root),
                                declared_reads,
                                declared_writes,
                                coverage_axis=(axis if is_story_axis else None),
                                coverage_values=(set(values) if is_story_axis else None),
                            )
                            exact_rule_link = in_rules and mapping_matches
                            expected_status = "mapped" if exact_rule_link else "needs_rule"
                            if fallback_status == "mapped":
                                for issue in malformed_rule:
                                    errors.append(
                                        f"{fallback_owner}: {fallback_root} rule enum contract invalid: {issue}"
                                    )
                            if fallback_status != expected_status:
                                errors.append(
                                    f"{fallback_owner}: {fallback_root} rule_status must be {expected_status}"
                                )
                    if is_story_axis:
                        expected_values = set(EXPECTED_DECISION_SPECS[axis]["values"]) - {"unknown"}
                        if seen_values != expected_values:
                            errors.append(
                                f"{beat_owner}.coverage: story values mismatch "
                                f"missing={sorted(expected_values - seen_values)} "
                                f"extra={sorted(seen_values - expected_values)}"
                            )
                    elif is_route_axis:
                        selector_partition = "selector" in beat and all(
                            isinstance(row, dict) and "selector" in row for row in fallbacks
                        )
                        expected_wildcards = 0 if selector_partition else 1
                        if wildcard_fallbacks != expected_wildcards:
                            errors.append(
                                f"{beat_owner}.coverage: route axis selector partition needs explicit values"
                                if selector_partition else
                                f"{beat_owner}.coverage: route axis needs exactly one wildcard fallback"
                            )

    for availability_owner, receipt_id, reader_month in availability_receipt_refs:
        writer_month = commitment_months.get(receipt_id)
        if writer_month is None:
            errors.append(
                f"{availability_owner}: receipt commitment {receipt_id} does not exist"
            )
        elif writer_month >= reader_month:
            errors.append(
                f"{availability_owner}: receipt commitment must come from an earlier month"
            )

    stats.months = len(months)
    stats.stops = len(stop_scene_ids)
    if [month.get("month") for month in months] != list(range(1, 61)):
        errors.append("months: must be the exact continuous sequence M01..M60")
    if not 45 <= stats.stops <= 51:
        errors.append(f"direct stops: {stats.stops} is outside 45..51")
    for root_id, expected_month in EXPECTED_CHAPTER5_PRODUCT_MONTHS.items():
        if chapter5_product_months[root_id] != [expected_month]:
            errors.append(
                f"Chapter 5 product root {root_id}: expected exactly M{expected_month}, "
                f"got {chapter5_product_months[root_id]}"
            )
    if not REQUIRED_COVERAGE_MONTHS.issubset(coverage_months):
        errors.append(
            "coverage: missing required route months "
            f"{sorted(REQUIRED_COVERAGE_MONTHS - coverage_months)}"
        )
    active_retired = commitment_ids & retired_selectable_ids
    if active_retired:
        errors.append(
            f"loop_contract.retired_selectable_ids: active commitments overlap tombstones "
            f"{sorted(active_retired)}"
        )
    validate_commitment_quality(months, retired_selectable_ids, errors)
    (
        stats.generic_commitments,
        stats.named_readers,
        causal_history_inputs,
    ) = validate_commitment_causality(
        story_map, months, beats_by_month, commitment_months, errors
    )
    actor_history_inputs = validate_actor_contracts(months, rules, spine, errors)
    execution_paths = scene_execution_paths(beats_by_month)
    for scene_id, paths in execution_paths.items():
        for path_index, path in enumerate(paths):
            history_inputs = (
                path["memories"]
                | path["carryovers"]
                | causal_history_inputs.get(scene_id, set())
                | actor_history_inputs.get(scene_id, set())
            )
            if len(history_inputs) > 2:
                errors.append(
                    f"scene {scene_id} path {path_index}: history inputs maximum is 2"
                )
            if len(path["decisions"]) > 1:
                errors.append(
                    f"scene {scene_id} path {path_index}: decision inputs maximum is 1"
                )
    for memory, (writer_month, writer_beat) in memory_writers.items():
        readers = memory_readers.get(memory, [])
        if not readers:
            errors.append(f"memory {memory}: writer {writer_beat} has no named reader")
        elif not any(reader_month > writer_month for reader_month, _ in readers):
            errors.append(f"memory {memory}: has no reader after its write month")
    for memory, readers in memory_readers.items():
        writer = memory_writers.get(memory)
        if writer is None:
            errors.append(f"memory {memory}: read without a writer")
            continue
        for reader_month, reader_beat in readers:
            if reader_month <= writer[0]:
                errors.append(f"memory {memory}: {reader_beat} must follow writer M{writer[0]:02}")
    for fact_id in EXPECTED_DECISIONS:
        writers = decision_writers.get(fact_id, [])
        if len(writers) != 1:
            errors.append(f"decision {fact_id}: must have exactly one canonical writer")
        else:
            writer_month = writers[0][0]
            readers = decision_readers.get(fact_id, [])
            if not any(month > writer_month for month, _ in readers):
                errors.append(f"decision {fact_id}: needs a later named reader")
            for reader_month, reader_owner in readers:
                if reader_month <= writer_month:
                    errors.append(
                        f"decision {fact_id}: {reader_owner} must follow canonical writer M{writer_month:02}"
                    )

    if carry_readers.get(1, set()):
        errors.append("chapter 1: must not read prior carryovers")
    if carry_writers.get(5, {}):
        errors.append("chapter 5: must not write carryovers")
    for chapter_number in range(1, 5):
        written = carry_writers.get(chapter_number, {})
        boss_month = chapter_number * 12
        if set(written) != EXPECTED_SLOTS or any(
            months != [boss_month] for months in written.values()
        ):
            errors.append(f"chapter {chapter_number}: boss must write the exact four carryovers")
        boss_writer_beats = [
            beat for beat in beats_by_month.get(boss_month, [])
            if isinstance(beat, dict) and beat.get("writes", {}).get("carryovers")
        ]
        if (
            len(boss_writer_beats) != 1
            or set(boss_writer_beats[0].get("writes", {}).get("carryovers", [])) != EXPECTED_SLOTS
            or boss_writer_beats[0].get("delivery") != "stop"
            or boss_writer_beats[0].get("kind") != "decision"
        ):
            errors.append(
                f"chapter {chapter_number}: one boss decision scene must write all four carryovers"
            )
        if carry_readers.get(chapter_number + 1, set()) != EXPECTED_SLOTS:
            errors.append(f"chapter {chapter_number + 1}: must read every prior carryover slot")
    for chapter_number in range(1, 6):
        boss_month = chapter_number * 12
        chapter_start = boss_month - 11
        boss_inputs = {
            memory
            for beat in beats_by_month.get(boss_month, [])
            for memory in beat.get("reads", {}).get("memories", [])
            if memory in memory_writers and chapter_start <= memory_writers[memory][0] < boss_month
        }
        if len(boss_inputs) < 2:
            errors.append(f"chapter {chapter_number}: boss must read two current-chapter memories")

    m1 = [beat for beat in beats_by_month.get(1, []) if isinstance(beat, dict)]
    if not any(beat.get("delivery") == "stop" and beat.get("writes", {}).get("decision") == "story.first_illegal_offer" for beat in m1):
        errors.append("M01 vertical slice: missing first-illegal-offer stop writer")
    if not any(
        beat.get("reads", {}).get("decision") == "story.first_illegal_offer"
        for month in range(2, 7) for beat in beats_by_month.get(month, []) if isinstance(beat, dict)
    ):
        errors.append("M01 vertical slice: M02..M06 needs a decision reader")
    m35 = [beat for beat in beats_by_month.get(35, []) if isinstance(beat, dict)]
    if not any(
        beat.get("root") == "arc_minjun_first_call"
        and beat.get("delivery") == "stop"
        and beat.get("reads", {}).get("decision") == "story.sangchul_truth_resolution"
        and any(memory_writers.get(memory, (61, ""))[0] <= 24 for memory in beat.get("reads", {}).get("memories", []))
        for beat in m35
    ):
        errors.append("M35 vertical slice: must recover a pre-M25 memory and the truth decision")
    m55 = [beat for beat in beats_by_month.get(55, []) if isinstance(beat, dict)]
    if not any(
        beat.get("delivery") == "stop"
        and beat.get("channel") == "in_person"
        and "player" in beat.get("cast", [])
        and len(beat.get("cast", [])) >= 3
        for beat in m55
    ):
        errors.append("M55 vertical slice: needs a three-person in-person stop")
    m55_scene_beats = [beat for beat in m55 if beat.get("scene_id") == "m55_three_in_room"]
    if len(m55_scene_beats) != 2:
        errors.append("M55 vertical slice: opening and decision must share one scene")
    else:
        if any("player" not in beat.get("cast", []) for beat in m55_scene_beats):
            errors.append("M55 vertical slice: player must attend every three-in-room beat")
        m55_paths = execution_paths.get("m55_three_in_room", [])
        if not m55_paths or any(
            path.get("memories") != {
                "memory.m50_protection_context", "memory.m52_final_offer",
            } or path.get("decisions") != {"story.jaehyuk_guarantee_resolution"}
            for path in m55_paths
        ):
            errors.append("M55 vertical slice: scene must read protected name, final offer, and guarantee")
        expected_roles = {"@final_proposer", "@chosen_reviewer", "@protected_person"}
        if not any(expected_roles.issubset(set(beat.get("cast", []))) for beat in m55_scene_beats):
            errors.append("M55 vertical slice: must bind three distinct attendee roles")
    return errors, stats


def run_self_test(
    base: dict[str, Any], rules: Any, spine: Any, ko_ids: set[str], en_ids: set[str]
) -> tuple[list[str], int]:
    failures: list[str] = []
    case_count = 0

    def month(data: dict[str, Any], number: int) -> dict[str, Any]:
        return next(
            row
            for chapter in data["chapters"]
            for row in chapter["months"]
            if row["month"] == number
        )

    def beat(
        data: dict[str, Any], number: int, beat_id: str
    ) -> dict[str, Any]:
        return next(
            row for row in month(data, number)["beats"]
            if row["id"] == beat_id
        )

    def case(
        name: str,
        mutate: Callable[[dict[str, Any]], None],
        needle: str | tuple[str, ...],
    ) -> None:
        nonlocal case_count
        case_count += 1
        candidate = copy.deepcopy(base)
        mutate(candidate)
        errors, _ = validate_story_map(candidate, rules, spine, ko_ids, en_ids)
        needles = (needle,) if isinstance(needle, str) else needle
        missing = [
            expected for expected in needles
            if not any(expected in error for error in errors)
        ]
        if missing:
            failures.append(f"{name}: expected {missing!r}, got {errors[:8]}")

    def case_rules(name: str, mutate: Callable[[dict[str, Any]], None], needle: str) -> None:
        nonlocal case_count
        case_count += 1
        candidate_rules = copy.deepcopy(rules)
        mutate(candidate_rules)
        errors, _ = validate_story_map(base, candidate_rules, spine, ko_ids, en_ids)
        if not any(needle in error for error in errors):
            failures.append(f"{name}: expected {needle!r}, got {errors[:5]}")

    def case_data_rules(
        name: str,
        mutate_data: Callable[[dict[str, Any]], None],
        mutate_rules: Callable[[dict[str, Any]], None],
        needle: str,
    ) -> None:
        nonlocal case_count
        case_count += 1
        candidate = copy.deepcopy(base)
        candidate_rules = copy.deepcopy(rules)
        mutate_data(candidate)
        mutate_rules(candidate_rules)
        errors, _ = validate_story_map(candidate, candidate_rules, spine, ko_ids, en_ids)
        if not any(needle in error for error in errors):
            failures.append(f"{name}: expected {needle!r}, got {errors[:5]}")

    def pass_case(name: str, mutate: Callable[[dict[str, Any]], None]) -> None:
        nonlocal case_count
        case_count += 1
        candidate = copy.deepcopy(base)
        baseline_errors, _ = validate_story_map(base, rules, spine, ko_ids, en_ids)
        mutate(candidate)
        errors, _ = validate_story_map(candidate, rules, spine, ko_ids, en_ids)
        new_errors = [error for error in errors if error not in baseline_errors]
        if new_errors:
            failures.append(f"{name}: expected pass, got {new_errors[:5]}")

    case("missing_month", lambda x: x["chapters"][0]["months"].pop(), "exactly 12 months")
    case(
        "monthly_candidate_removed",
        lambda x: month(x, 1)["commitments"].clear(),
        "2..4 concrete candidates",
    )

    def keep_valid_two_candidates(data: dict[str, Any]) -> None:
        commitments = month(data, 1)["commitments"]
        del commitments[2:]
        commitments[1]["axis"] = "trust"
        data["design_targets"]["generic_commitments"] = sum(
            len(target_month["commitments"])
            for chapter in data["chapters"]
            for target_month in chapter["months"]
        )

    pass_case("two_candidate_month_allowed", keep_valid_two_candidates)
    case(
        "candidate_pressure_missing",
        lambda x: month(x, 1)["commitments"].pop(0),
        "pressure source is required",
    )

    def keep_pressure_only(data: dict[str, Any]) -> None:
        for commitment in month(data, 1)["commitments"]:
            commitment["source"] = "pressure"

    case(
        "candidate_only_pressure",
        keep_pressure_only,
        "needs opportunity or person_promise beside pressure",
    )
    case(
        "candidate_due_outside_month",
        lambda x: month(x, 1)["commitments"][0].update({"due_week": 5}),
        "must be inside M01",
    )

    def make_dependency_cycle(data: dict[str, Any]) -> None:
        commitments = month(data, 1)["commitments"]
        commitments[0]["after"] = commitments[1]["id"]
        commitments[1]["after"] = commitments[0]["id"]

    case("candidate_dependency_cycle", make_dependency_cycle, "dependency cycle")

    def make_dependency_chain(data: dict[str, Any]) -> None:
        commitments = month(data, 1)["commitments"]
        commitments[1]["after"] = commitments[0]["id"]
        commitments[2]["after"] = commitments[1]["id"]

    case("candidate_dependency_too_deep", make_dependency_chain, "exceeds two selectable commitments")
    case(
        "availability_requires_every_commitment_annotation",
        lambda x: month(x, 15)["commitments"][0].pop("available_values"),
        "available_values",
    )
    case(
        "available_values_forbidden_without_month_axis",
        lambda x: month(x, 1)["commitments"][0].update(
            {"available_values": ["*"]}
        ),
        "requires month availability",
    )
    case(
        "availability_axis_must_be_typed",
        lambda x: month(x, 15)["availability"].update(
            {"axis": "route.m99.relationship_path"}
        ),
        "approved story fact, earlier receipt state, or local route axis",
    )
    case(
        "commitment_availability_value_must_be_declared",
        lambda x: month(x, 15)["commitments"][1].update(
            {"available_values": ["invented_path"]}
        ),
        "outside availability values",
    )

    def hide_all_but_one_candidate(data: dict[str, Any]) -> None:
        commitments = month(data, 15)["commitments"]
        for commitment in commitments:
            commitment["available_values"] = ["daeun"]

    case(
        "availability_scenario_needs_two_candidates",
        hide_all_but_one_candidate,
        "must expose 2..4 visible commitments",
    )
    case(
        "availability_scenario_needs_pressure",
        lambda x: month(x, 17)["commitments"][0].update(
            {"available_values": ["unattached"]}
        ),
        "visible pressure source is required",
    )
    case(
        "availability_scenario_needs_two_axes",
        lambda x: month(x, 15)["commitments"][3].update({"axis": "cash"}),
        "visible commitments need at least two axes",
    )

    def point_availability_at_missing_receipt(data: dict[str, Any]) -> None:
        target = month(data, 15)
        target["availability"] = {
            "axis": "receipt.m14_missing_commitment.state",
            "values": ["completed"],
        }
        for commitment in target["commitments"]:
            commitment["available_values"] = ["*"]

    case(
        "availability_receipt_must_exist",
        point_availability_at_missing_receipt,
        "receipt commitment m14_missing_commitment does not exist",
    )
    case(
        "miss_consequence_contract_drift",
        lambda x: x["loop_contract"]["miss_consequences"].update(
            {"expired": "silent_disappearance"}
        ),
        "approved monthly choice grammar",
    )

    def restore_fixed_deadline_template(data: dict[str, Any]) -> None:
        for chapter in data["chapters"]:
            for target_month in chapter["months"]:
                first_week = (target_month["month"] - 1) * 4 + 1
                for commitment in target_month["commitments"]:
                    if commitment["source"] == "pressure":
                        commitment["due_week"] = first_week
                    elif commitment["source"] == "person_promise":
                        commitment["due_week"] = first_week + 3

    case(
        "fixed_deadline_template_returns",
        restore_fixed_deadline_template,
        (
            "pressure local week 1 maximum is 80%",
            "person_promise local week 4 maximum is 70%",
        ),
    )

    def erase_chapter_two_conflicts(data: dict[str, Any]) -> None:
        chapter = data["chapters"][1]
        local_week_by_source = {
            "pressure": 1, "opportunity": 2, "person_promise": 4,
        }
        for target_month in chapter["months"]:
            first_week = (target_month["month"] - 1) * 4 + 1
            for commitment in target_month["commitments"]:
                commitment["due_week"] = (
                    first_week + local_week_by_source[commitment["source"]] - 1
                )

    case(
        "chapter_needs_real_deadline_conflicts",
        erase_chapter_two_conflicts,
        "chapter 2: cross-source same-week conflict months minimum is 2",
    )

    def make_person_deferral_dominant(data: dict[str, Any]) -> None:
        for target_month in data["chapters"][4]["months"]:
            for commitment in target_month["commitments"]:
                if commitment["source"] == "person_promise":
                    commitment["miss"] = "deferred"

    case(
        "person_deferral_cannot_be_dominant_or_terminal",
        make_person_deferral_dominant,
        (
            "chapter 5: deferred person_promise maximum is 50%",
            "M60 commitments: deferred miss is forbidden",
        ),
    )
    case(
        "retired_fake_card_cannot_return",
        lambda x: month(x, 11)["commitments"][0].update(
            {"id": x["loop_contract"]["retired_selectable_ids"][0]}
        ),
        "retired selectable commitment id",
    )
    case(
        "implemented_root_marked_new",
        lambda x: month(x, 1)["beats"][0].update({"work": "NEW", "rule_status": "planned"}),
        "already exists",
    )
    case(
        "implemented_focus_fallback_marked_new",
        lambda x: month(x, 9)["beats"][0]["coverage"]["fallbacks"][0].update(
            {"work": "NEW", "rule_status": "planned"}
        ),
        "NEW fallback must be absent and planned",
    )
    case_rules(
        "decision_enum_drift",
        lambda x: x["fact_types"]["story.partner_commitment"].update({"values": ["none"]}),
        "wrong enum contract",
    )
    case(
        "carryover_payload_erased",
        lambda x: x["carryover_slots"]["open_debt"].update({"required": ["kind"]}),
        "must preserve kind/source receipt",
    )
    case(
        "chapter_one_reads_carryover",
        lambda x: month(x, 1)["beats"][0]["reads"]["carryovers"].append("open_debt"),
        "chapter 1: must not read prior carryovers",
    )
    case(
        "chapter_five_writes_carryover",
        lambda x: month(x, 60)["beats"][0]["writes"]["carryovers"].append("open_debt"),
        "chapter 5: must not write carryovers",
    )

    def write_carryover_early(data: dict[str, Any]) -> None:
        month(data, 11)["beats"][0]["writes"]["carryovers"].append("boss_choice")

    case("carryover_written_early", write_carryover_early, "boss must write the exact four carryovers")

    def split_boss_carryovers(data: dict[str, Any]) -> None:
        boss = month(data, 12)["beats"][0]
        split = copy.deepcopy(boss)
        moved = boss["writes"]["carryovers"].pop()
        split.update({
            "id": "m12_split_boss_writer",
            "scene_id": "m12_split_boss_writer",
            "root": "arc_self_test_split_boss_writer",
            "work": "NEW",
            "rule_status": "planned",
        })
        split["reads"] = {"memories": [], "decision": None, "carryovers": []}
        split["writes"] = {"memories": [], "decision": None, "carryovers": [moved]}
        month(data, 12)["beats"].append(split)

    case(
        "boss_carryovers_split_across_scenes",
        split_boss_carryovers,
        "one boss decision scene must write all four carryovers",
    )

    case("actor_receipt_counts_in_history", lambda x: beat(
         x, 50, "m50_final_year_start")["reads"]
         ["memories"].append("memory.m47_final_contact"), "history inputs maximum is 2")
    def make_fallback_history_disjoint(data: dict[str, Any]) -> None:
        beat(data, 51, "m51_minseo_arrival")["coverage"]["fallbacks"][0]["reads"]["memories"] = [
            "memory.m47_final_contact", "memory.m50_protection_context",
        ]

    pass_case("mutually_exclusive_history_not_unioned", make_fallback_history_disjoint)

    case("coverage_enum_omission", lambda x: month(x, 25)["beats"][0]["coverage"]
         ["fallbacks"][0]["values"].pop(), "story values mismatch")
    case(
        "story_coverage_base_decision_missing",
        lambda x: month(x, 25)["beats"][0]["reads"].update({"decision": None}),
        "base reads.decision must equal story axis",
    )
    case(
        "story_coverage_fallback_decision_missing",
        lambda x: month(x, 25)["beats"][0]["coverage"]["fallbacks"][0]["reads"].update(
            {"decision": None}
        ),
        "reads.decision: must equal story axis",
    )
    case(
        "m59_execute_selection_gate",
        lambda x: month(x, 59)["beats"][0]["coverage"]["fallbacks"][-1]
        ["selector"].update({"selected_none": []}),
        "selector dispatch must resolve exactly one branch",
    )
    case(
        "m45_partner_needs_both_selections",
        lambda x: month(x, 45)["beats"][0]["selector"]
        .update({"selected_all": ["m45_measure_financing_gap"]}),
        "selector dispatch must resolve exactly one branch",
    )

    def put_wildcard_first(data: dict[str, Any]) -> None:
        fallbacks = month(data, 22)["beats"][0]["coverage"]["fallbacks"]
        fallbacks[0], fallbacks[1] = fallbacks[1], fallbacks[0]

    case("coverage_wildcard_not_last", put_wildcard_first, "wildcard fallback must be last")
    case("availability_fact_use_before_write", lambda x: month(x, 39).update({"availability": {
         "axis": "story.partner_commitment", "values": ["none", "daeun", "jiyeon"]}}),
         "must follow canonical writer M42")
    case(
        "capacity_one_excludes_locked_successors",
        lambda x: next(row for row in month(x, 30)["commitments"] if row["id"] == "m30_leave_final_voice").update({"after": "m30_preserve_evidence"}),
        "capacity=1 needs at least two actionable commitments",
    )
    case(
        "role_binding_owner_read_missing",
        lambda x: month(x, 55)["beats"][0]["role_bindings"].update(
            {"final_proposer": {
                "kind": "receipt_actor", "source_type": "memory",
                "source_id": "memory.m53_guarantee_request", "actor_role": "proposer",
            }}
        ),
        "not read by its owner branch",
    )
    def make_family_actor_available(data: dict[str, Any]) -> None:
        beat = month(data, 42)["beats"][0]
        family_only = next(
            row for row in beat["coverage"]["fallbacks"]
            if row.get("values") == ["family_only"]
        )
        family_only["role_bindings"]["family_member"]["source"] = {
            "kind": "available_commitment",
            "commitment_id": "m42_face_family_member",
        }

    case("in_person_actor_requires_selection", make_family_actor_available,
         "needs selected provenance")
    case(
        "m52_document_uses_available_actor",
        lambda x: month(x, 52)["beats"][0]["coverage"]["fallbacks"][-1]["role_bindings"].update({"final_proposer": {"kind": "literal", "actor_id": "sangchul"}}),
        "actual available live proposer",
    )
    def promote_coalesced_room(data: dict[str, Any]) -> None:
        beat = month(data, 55)["beats"][0]
        beat["distinct_roles"] = beat.pop("coalesce_roles")

    case("coalesced_roles_cannot_be_promoted_distinct", promote_coalesced_room,
         "distinct roles resolve to same actor")
    case("actor_output_policy_xor", lambda x: month(x, 50)["beats"][0]["actor_outputs"]
         ["memory.m50_protection_context"].update({"all_distinct": [["protected_person", "reviewer"]]}),
         "exactly one actor role policy")

    def erase_memory_actor_role(data: dict[str, Any]) -> None:
        del month(data, 39)["beats"][0]["actor_outputs"][
            "memory.m39_three_promises"
        ]["roles"]["surviving_witness"]

    case(
        "memory_actor_role_requires_producer_output",
        erase_memory_actor_role,
        "unknown output role",
    )

    def bind_from_other_scene_beat_read(data: dict[str, Any]) -> None:
        second = month(data, 55)["beats"][1]
        second["role_bindings"] = copy.deepcopy(
            month(data, 55)["beats"][0]["role_bindings"]
        )
        second["distinct_roles"] = [
            "@final_proposer", "@chosen_reviewer", "@protected_person",
        ]

    case(
        "scene_union_read_cannot_supply_binding_owner",
        bind_from_other_scene_beat_read,
        "base role_bindings owner must be exactly one beat",
    )

    def erase_fallback_role_bindings(data: dict[str, Any]) -> None:
        fallback = month(data, 55)["beats"][0]["coverage"]["fallbacks"][0]
        del fallback["role_bindings"]
        del fallback["coalesce_roles"]

    case(
        "fallback_cannot_inherit_base_role_bindings",
        erase_fallback_role_bindings,
        "fallback must bind its own @roles",
    )

    case(
        "m39_selected_set_exact_dispatch",
        lambda x: month(x, 39)["beats"][0]["selector"]["selected_all"]
        .remove("m39_investment_meeting"),
        "selector dispatch must resolve exactly one branch",
    )
    case(
        "actor_fallback_must_be_truthful",
        lambda x: month(x, 50)["beats"][0]["actor_outputs"]["memory.m50_protection_context"]["roles"]["reviewer"]["fallback"].update({"actor_ids": ["player"]}),
        "canonical non-player candidates",
    )

    def erase_commitment_actor_slot(data: dict[str, Any]) -> None:
        target = next(
            commitment for commitment in month(data, 52)["commitments"]
            if commitment["id"] == "m52_hear_live_proposer"
        )
        del target["actor_slots"]

    case(
        "commitment_actor_requires_actor_slot",
        erase_commitment_actor_slot,
        "does not declare actor_slot proposer",
    )

    def use_same_month_completed_actor(data: dict[str, Any]) -> None:
        binding = month(data, 50)["beats"][0]["actor_outputs"][
            "memory.m50_protection_context"
        ]["roles"]["reviewer"]
        binding["source"] = {
            "kind": "commitment_receipt", "source_receipt_id": "m50_tell_protected_person",
            "state": ["completed"],
        }
        binding["actor_role"] = "protected_person"

    case(
        "completed_actor_must_be_previous_month",
        use_same_month_completed_actor,
        "must come from the previous month",
    )

    def create_actor_output_cycle(data: dict[str, Any]) -> None:
        roles = month(data, 52)["beats"][0]["actor_outputs"][
            "memory.m52_final_offer"
        ]["roles"]
        roles["protected_person"] = {
            "kind": "receipt_actor",
            "source_type": "memory",
            "source_id": "memory.m52_final_offer",
            "actor_role": "protected_person",
        }

    case("actor_output_cycle", create_actor_output_cycle, "actor output cycle")

    def move_actor_output_to_unwritten_memory(data: dict[str, Any]) -> None:
        outputs = month(data, 50)["beats"][0]["actor_outputs"]
        outputs["memory.self_test_unwritten"] = outputs.pop("memory.m50_protection_context")

    case(
        "actor_output_must_target_written_memory",
        move_actor_output_to_unwritten_memory,
        "actor output memory is not written",
    )

    case(
        "actor_output_must_be_total_across_fallbacks",
        lambda x: month(x, 52)["beats"][0]["coverage"]["fallbacks"][0]
        .pop("actor_outputs"),
        "missing branch output for memory.m52_final_offer",
    )
    case(
        "mapped_writer_without_fact",
        lambda x: month(x, 23)["beats"][0].update({"rule_status": "mapped"}),
        "rule_status must be needs_rule",
    )

    def add_extra_mapped_fact(candidate_rules: dict[str, Any]) -> None:
        candidate_rules["events"]["arc_daeun_01_meet"]["logic"] = {
            "requires": [{"fact": "story.first_illegal_offer", "is": "refused"}]
        }

    case_rules(
        "mapped_fact_set_must_be_exact",
        add_extra_mapped_fact,
        "rule_status must be needs_rule",
    )

    def mark_m25_mapped(data: dict[str, Any]) -> None:
        month(data, 25)["beats"][0]["rule_status"] = "mapped"

    def set_m25_wrong_axis(candidate_rules: dict[str, Any]) -> None:
        candidate_rules["events"].setdefault("arc_father_05_after_visit", {})["logic"] = {
            "requires": [{"fact": "story.sangchul_truth_resolution", "is": "confronted"}]
        }

    case_data_rules(
        "mapped_coverage_axis_must_match",
        mark_m25_mapped,
        set_m25_wrong_axis,
        "approved fact sets do not exactly match",
    )

    def set_m25_wrong_value(candidate_rules: dict[str, Any]) -> None:
        candidate_rules["events"].setdefault("arc_father_05_after_visit", {})["logic"] = {
            "requires": [{"fact": "story.father_hospital_door", "is": "deferred"}]
        }

    case_data_rules(
        "mapped_coverage_values_must_match",
        mark_m25_mapped,
        set_m25_wrong_value,
        "values must match coverage",
    )

    def set_m25_invalid_enum(candidate_rules: dict[str, Any]) -> None:
        candidate_rules["events"].setdefault("arc_father_05_after_visit", {})["logic"] = {
            "requires": [{"fact": "story.father_hospital_door", "is": "visited_typo"}]
        }

    case_data_rules(
        "mapped_rule_enum_value_invalid",
        mark_m25_mapped,
        set_m25_invalid_enum,
        "invalid enum values",
    )
    case(
        "relocation_source_drift",
        lambda x: month(x, 34)["beats"][0].update({"source_month": 36}),
        "relocation must be M34 EXPAND from M35",
    )
    case(
        "listener_relocation_mode_drift",
        lambda x: month(x, 35)["beats"][0].update({"work": "MOVE"}),
        "relocation must be M35 EXPAND from M33",
    )
    case(
        "father_relocation_mode_drift",
        lambda x: beat(x, 47, "m47_father_medical_outcome").update(
            {"work": "MOVE"}),
        "relocation must be M47 EXPAND from M44",
    )
    case(
        "mirror_relocation_mode_drift",
        lambda x: beat(x, 53, "m53_jaehyuk_guarantee").update({"work": "MOVE"}),
        "relocation must be M53 EXPAND from M15",
    )
    case(
        "m55_cast_erased",
        lambda x: beat(x, 55, "m55_three_in_room_decision").update(
            {"cast": ["player", "@final_proposer"]}),
        "M55 vertical slice",
    )

    def remove_m55_player(data: dict[str, Any]) -> None:
        for beat in month(data, 55)["beats"]:
            beat["cast"].remove("player")

    case("m55_player_erased", remove_m55_player, "player must attend")
    case(
        "monthly_candidate_drift",
        lambda x: x["loop_contract"].update({"candidate_count": [1, 4]}),
        "approved monthly choice grammar",
    )

    def causal_reader(data: dict[str, Any], reader_id: str) -> dict[str, Any]:
        return next(
            reader for reader in data["commitment_causality"]["named_readers"]
            if reader["id"] == reader_id
        )

    def corrupt_runtime_records(data: dict[str, Any]) -> None:
        data["commitment_causality"]["selection_record"].pop("slot")
        data["commitment_causality"]["receipt_record"].pop("actors")

    case(
        "causality_runtime_record_shapes",
        corrupt_runtime_records,
        ("selection_record: must declare exact", "receipt_record: must declare exact"),
    )

    def break_generic_terminal(data: dict[str, Any]) -> None:
        generic = data["commitment_causality"]["generic_reader"]
        generic["months"] = [1, 58]
        generic["terminal"]["next_month"] = 61

    case(
        "generic_coverage_and_no_m61",
        break_generic_terminal,
        ("commitments missing generic consequence", "M61 is forbidden"),
    )

    def make_delivery_read_receipt(data: dict[str, Any]) -> None:
        causal_reader(data, "reader.m03_daeun_delivery")["source"] = {
            "kind": "commitment_receipt",
            "source_receipt_id": "m03_daeun_return",
            "state": ["completed"],
        }

    case(
        "delivery_requires_local_selection",
        make_delivery_read_receipt,
        "delivery only accepts a selected source",
    )

    def remove_scene_and_root(data: dict[str, Any]) -> None:
        causal_reader(data, "reader.m43_lived_promise")["reader"]["scene_id"] = (
            "m43_missing_scene"
        )
        causal_reader(data, "reader.m03_daeun_delivery")["effect"]["root"] = (
            "arc_missing_delivery_root"
        )
        data["commitment_causality"]["named_readers"].remove(
            causal_reader(data, "reader.m46_body_help")
        )

    case(
        "named_reader_scene_and_root_exist",
        remove_scene_and_root,
        ("reader scene does not exist", "delivery root is not owned", "count and unique ids"),
    )
    case(
        "selected_reader_is_same_month",
        lambda x: causal_reader(x, "reader.m03_daeun_delivery")["source"].update(
            {"commitment_id": "m02_hyunsu_first_promise"}
        ),
        "selected source must share the reader month",
    )

    def add_same_scene_receipt_cycle(data: dict[str, Any]) -> None:
        data["commitment_causality"]["named_readers"].append({
            "id": "reader.self_test_m57_cycle",
            "mode": "gate",
            "source": {
                "kind": "commitment_receipt",
                "source_receipt_id": "m57_file_name_decision",
                "state": ["completed"],
            },
            "reader": {"kind": "scene", "scene_id": "m57_name_on_line"},
            "effect": {"kind": "outcome", "target": "echo.self_test_cycle"},
        })

    case(
        "completed_receipt_cannot_open_producer_scene",
        add_same_scene_receipt_cycle,
        "completed receipt cannot open its own producer scene",
    )

    def reuse_m20_availability_axis(data: dict[str, Any]) -> None:
        causal_reader(data, "reader.m20_chosen_door")["effect"]["axis"] = (
            "route.m20.open_door"
        )
        month(data, 20)["beats"][0]["coverage"]["axis"] = "route.m20.open_door"

    case(
        "focus_axis_is_distinct_from_availability",
        reuse_m20_availability_axis,
        "focus axis must differ from month availability",
    )
    case(
        "focus_coverage_is_exact",
        lambda x: causal_reader(x, "reader.m09_relationship_reentry")["sources"].pop(),
        "focus coverage must exactly match source values plus one fallback",
    )
    case(
        "m55_after_requires_selected_predecessor",
        lambda x: causal_reader(
            x, "reader.m55_reviewer_question_option"
        )["effect"].update({"after": None}),
        "after must match its selected scene-local predecessor",
    )
    case(
        "atomic_scene_receipt_commit_order",
        lambda x: x["commitment_causality"]["write_order"].__setitem__(
            3, "completed_receipts_committed"
        ),
        "receipt commit, and resolved dispatch order drifted",
    )
    return failures, case_count


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    try:
        story_map = load_json(MAP_PATH)
        rules = load_json(RULES_PATH)
        spine = load_json(SPINE_PATH)
        ko_ids = load_event_ids(EVENTS_KO)
        en_ids = load_event_ids(EVENTS_EN)
    except (OSError, json.JSONDecodeError, DuplicateKeyError) as exc:
        print(f"STORY_MAP_FAIL load_error={exc}")
        return 1
    errors, stats = validate_story_map(story_map, rules, spine, ko_ids, en_ids)
    if errors:
        for error in errors:
            print(f"STORY_MAP_ERROR {error}")
        print(f"STORY_MAP_FAIL errors={len(errors)}")
        return 1
    if args.self_test:
        failures, case_count = run_self_test(story_map, rules, spine, ko_ids, en_ids)
        if failures:
            for failure in failures:
                print(f"STORY_MAP_SELF_TEST_ERROR {failure}")
            print(f"STORY_MAP_SELF_TEST_FAIL errors={len(failures)}")
            return 1
        print(f"STORY_MAP_SELF_TEST_OK cases={case_count}")
        return 0
    print(
        "STORY_MAP_OK "
        f"months={stats.months} commitments={stats.commitments} "
        f"availability_months={stats.availability_months} "
        f"availability_scenarios={stats.availability_scenarios} "
        f"conditional_commitments={stats.conditional_commitments} "
        f"generic_commitments={stats.generic_commitments}/{stats.commitments} "
        f"named_readers={stats.named_readers} "
        f"beats={stats.beats} stops={stats.stops} "
        f"fallbacks={stats.fallbacks} planned_fallbacks={stats.planned_fallbacks} "
        f"existing={stats.existing} planned={stats.planned} needs_rule={stats.needs_rule}"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
