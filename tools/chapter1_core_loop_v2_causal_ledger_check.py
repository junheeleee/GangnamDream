#!/usr/bin/env python3
"""Validate the Chapter 1 48-slot causal ledger and exact debt snapshot.

The normal mode validates the intentionally incomplete ORDER-100 snapshot.  It
never upgrades a coverage gap to a completion claim.  The stricter completion
gate is deliberately separate::

    python3 tools/chapter1_core_loop_v2_causal_ledger_check.py
    python3 tools/chapter1_core_loop_v2_causal_ledger_check.py --self-test
    python3 tools/chapter1_core_loop_v2_causal_ledger_check.py \
        --require-complete-chapter-one

There is intentionally no command which rewrites the debt baseline.
"""

from __future__ import annotations

import argparse
import base64
import copy
import hashlib
import itertools
import json
import os
import re
import sys
import tempfile
import time
import zlib
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
LEDGER_PATH = ROOT / "content/meta/chapter1_core_loop_v2_causal_ledger.json"
BASELINE_PATH = ROOT / "tools/chapter1_core_loop_v2_causal_debt_baseline.json"
DEMO_CONTRACT_PATH = ROOT / "content/meta/demo_core_loop_v2.json"
CORE_EVENTS_PATH = ROOT / "content/events/core_loop_v2_events.json"
GAME_STATE_PATH = ROOT / "autoloads/GameState.gd"
DEMO_RUNTIME_PATH = ROOT / "systems/DemoCoreLoopV2.gd"

FROZEN_JSON_MAX_BYTES = 4_000_000
SELF_TEST_PROBE_TIMEOUT_SECONDS = 45.0
SELF_TEST_FULL_TIMEOUT_SECONDS = 180.0

_SELF_TEST_PROBE_COUNT = 0
_SELF_TEST_FULL_COUNT = 0
_SELF_TEST_FULL_FALLBACK_COUNT = 0
_SELF_TEST_PROBE_SECONDS = 0.0
_SELF_TEST_FULL_SECONDS = 0.0


def _reject_duplicate_json_keys(
        pairs: list[tuple[str, Any]]) -> dict[str, Any]:
    result: dict[str, Any] = {}
    for key, value in pairs:
        if key in result:
            raise ValueError(f"duplicate JSON object key {key!r}")
        result[key] = value
    return result


def _parse_exact_json(payload: str, source_name: str) -> Any:
    try:
        return json.loads(
            payload, object_pairs_hook=_reject_duplicate_json_keys)
    except json.JSONDecodeError as exc:
        raise ValueError(f"malformed JSON {source_name}: {exc}") from exc


def _decode_frozen_json(
        encoded: str, *, source_name: str, byte_length: int,
        sha256: str, top_level_type: type, item_count: int) -> Any:
    """Decode one generated audit map with strict, fail-closed metadata.

    The payload is data only.  Its canonical JSON remains independently
    inspectable through `--dump-audited-maps`; compression merely keeps the
    1,493 proof bindings and 210 source scenarios from dominating this file.
    """
    if (not isinstance(encoded, str) or not encoded
            or not isinstance(byte_length, int)
            or byte_length < 0 or byte_length > FROZEN_JSON_MAX_BYTES
            or not re.fullmatch(r"[0-9a-f]{64}", sha256)
            or top_level_type not in {dict, list}
            or not isinstance(item_count, int) or item_count < 0):
        raise ValueError(f"invalid frozen JSON metadata {source_name}")
    try:
        compressed = base64.b64decode(encoded.encode("ascii"), validate=True)
    except (UnicodeEncodeError, ValueError) as exc:
        raise ValueError(f"invalid frozen JSON base64 {source_name}") from exc
    inflater = zlib.decompressobj()
    try:
        raw = inflater.decompress(compressed, FROZEN_JSON_MAX_BYTES + 1)
        raw += inflater.flush()
    except zlib.error as exc:
        raise ValueError(f"invalid frozen JSON zlib stream {source_name}") from exc
    if (not inflater.eof or inflater.unused_data or inflater.unconsumed_tail
            or len(raw) > FROZEN_JSON_MAX_BYTES):
        raise ValueError(f"non-canonical frozen JSON stream {source_name}")
    if len(raw) != byte_length:
        raise ValueError(f"frozen JSON byte length mismatch {source_name}")
    if hashlib.sha256(raw).hexdigest() != sha256:
        raise ValueError(f"frozen JSON digest mismatch {source_name}")
    try:
        payload = raw.decode("utf-8")
    except UnicodeDecodeError as exc:
        raise ValueError(f"invalid frozen JSON UTF-8 {source_name}") from exc
    value = _parse_exact_json(payload, f"frozen:{source_name}")
    if type(value) is not top_level_type:
        raise ValueError(f"frozen JSON top-level type mismatch {source_name}")
    if len(value) != item_count:
        raise ValueError(f"frozen JSON item count mismatch {source_name}")
    canonical = json.dumps(
        value, ensure_ascii=False, sort_keys=True,
        separators=(",", ":")).encode("utf-8")
    if canonical != raw or hashlib.sha256(canonical).hexdigest() != sha256:
        raise ValueError(f"frozen JSON is not canonical {source_name}")
    return value

ROOT_FIELDS = {
    "schema_version", "ledger_id", "scope", "build_families", "rows",
    "coverage_gaps", "reader_registry", "milestone_registry",
    "replay_witnesses", "runtime_proof_registry", "counterfactual_registry",
    "evaluation_registry",
}
SCOPE_FIELDS = {
    "chapter_id", "target_week_range", "target_month_range", "target_row_count",
    "authoritative_week_range", "authoritative_month_range",
    "authoritative_row_count", "rows_per_month", "slot_owner_order",
    "milestone_weeks", "run_origin", "run_origin_runtime_proof_ids",
}
ROW_FIELDS = {
    "chain_id", "month", "node_id", "runtime_pointer", "slot_owner",
    "build_family", "selection_owner", "availability", "cost", "producer",
    "terminal_contract", "next_verb_by_terminal", "build_facts",
    "near_reader_ids", "milestone_reader_ids", "missed_contract",
    "counterfactual_id", "surface_pointers", "runtime_proof_ids",
}
AVAILABILITY_FIELDS = {
    "threshold", "deadline_week", "trigger_bundle_ids",
    "fallback_trigger_bundle_id", "disable_without_trigger",
    "trigger_windows_by_bundle", "no_eligible_contract",
}
AVAILABILITY_OPTIONAL_FIELDS = {
    "threshold_by_trigger", "trigger_min_week", "trigger_deadline_week",
    "deadline_follows_trigger", "fallback_after_trigger_expiry",
    "declared_candidate_cap", "runtime_candidate_cap",
}
COST_FIELDS = {"weekly_capacity", "effect_pointers", "visible"}
COST_OPTIONAL_FIELDS = {"completion_replaces_allocation_effects"}
PRODUCER_FIELDS = {
    "allocation_receipt_id_template", "completion_receipt_ids",
    "expiry_receipt_ids", "repeat_receipt_unique_by", "state_delta_keys",
    "conditional_output_variants", "output_variant_groups",
    "display_only_output_keys",
}
TRIGGER_WINDOW_FIELDS = {
    "relative_weeks", "min_relative_week", "max_relative_week",
}
CONDITIONAL_OUTPUT_VARIANT_FIELDS = {
    "variant_id", "activation_ids", "produced_fact_ids",
    "effect_contract_ids", "runtime_proof_ids", "selection_group_id",
    "activation_roles",
}
ACTIVATION_ROLE_FIELDS = {
    "history_memory_ids", "material_state_ids", "scene_handoff_fact_ids",
    "story_decision_ids", "scene_handoff_decision_ids",
}
OUTPUT_VARIANT_GROUP_FIELDS = {"selection_group_id", "selection_mode"}
PRODUCER_VARIANT_GROUP_FIELDS = {
    "selection_group_id", "selection_mode", "causal_status",
}
NO_ELIGIBLE_CONTRACT_FIELDS = {
    "status", "produces_receipts", "runtime_proof_ids",
}
TERMINAL_FIELDS = {
    "repeatable_after_completion", "completed_surface", "expired_surface",
    "reentry_cost",
}
NEXT_VERB_FIELDS = {"completed", "expired"}
MISSED_FIELDS = {
    "receipt_ids", "consequence_ids", "reader_ids",
    "changes_future_availability",
}
SURFACE_FIELDS = {"ko", "en"}
GAP_FIELDS = {
    "gap_id", "week_range", "month_range", "missing_row_count", "status",
    "slot_owner_order", "owner_order", "runtime_proof_ids",
}
EVALUATION_FIELDS = {
    "error_code", "status", "scope_week_range", "debt_ids", "blocker_ids",
}

FAMILIES = ["advancement", "livelihood", "people", "self"]
BUILD_FAMILY_FIELDS = {
    "build_family_id", "layer_owner", "allowed_slot_owners", "source_action_ids",
}
BUILD_FAMILY_BY_SLOT = {
    "advancement": "build:career_progression",
    "livelihood": "build:cash_buffer",
    "people": "build:relationship_initiative",
    "self": "build:recovery_capacity",
}
EXPECTED_SOURCE_ACTION_IDS_BY_SLOT = {
    "advancement": ["apply", "interview", "resume", "study"],
    "livelihood": ["side_shift"],
    "people": ["contact"],
    "self": ["rest"],
}
ERROR_CODES = [
    "ROW_BIJECTION", "DEAD_CARD", "ORPHAN_FACT", "SHADOWED_READER",
    "AUTO_PERSON_PICK", "UNREACHABLE_CAP", "UNSCHEDULED_CHAIN",
    "DISPLAY_ONLY_FORGONE", "COUNTERFACTUAL_NOOP", "LAYER_COLLISION",
    "MILESTONE_FANIN", "FAKE_REPEAT", "ROUTE_NO_DIVERGENCE",
    "ROUTE_HARD_LOCK", "SAVE_ROUNDTRIP",
]
BLOCKED_WHILE_COVERAGE_OPEN = {
    "ROUTE_NO_DIVERGENCE", "ROUTE_HARD_LOCK", "SAVE_ROUNDTRIP",
}
SYNTHETIC_W24_FANIN_SUPERSEDED_INVOCATION_IDS = frozenset({
    "reader:milestone:w24:prepare_fresh_inputs",
    "reader:milestone:w24:candidate_aggregation",
    "reader:milestone:w24:deferred_callback_choice:reentry",
    "reader:milestone:w24:opening_father_memory:fresh",
    "reader:milestone:w24:opening_father_memory:reentry",
    "reader:milestone:w24:fmt_opening_description:fresh",
    "reader:milestone:w24:fmt_opening_description:reentry",
    "reader:milestone:w24:fmt_opening_after_bills:fresh",
    "reader:milestone:w24:fmt_opening_after_bills:reentry",
    "reader:milestone:w24:fmt_first_bill_description:fresh",
    "reader:milestone:w24:fmt_first_bill_description:reentry",
    "reader:milestone:w24:fmt_ledger_description:fresh",
    "reader:milestone:w24:fmt_ledger_description:reentry",
    "reader:milestone:w24:fmt_ledger_description:loaded_after_first_bill",
    "reader:milestone:w24:fmt_ledger_description:loaded_direct_prose",
    "reader:milestone:w24:fmt_hyunsu_result:fresh",
    "reader:milestone:w24:fmt_hyunsu_result:reentry",
    "reader:milestone:w24:fmt_hyunsu_result:loaded_chain",
    "reader:milestone:w24:fmt_hyunsu_result:loaded_direct_result",
    "reader:milestone:w24:father_replay_memory:fresh",
    "reader:milestone:w24:father_replay_memory:reentry",
    "reader:milestone:w24:prechoice_snapshot:fresh",
    "reader:milestone:w24:prechoice_snapshot:reentry",
    "reader:milestone:w24:first_bill_replay_capture",
    "reader:milestone:w24:first_bill_decision_result_restore",
    "reader:milestone:w24:ledger_memory",
    "reader:milestone:w24:completion_validation:loaded",
})
SYNTHETIC_W24_FANIN_SUMMARY_FACT_IDS = (
    "history_summary:w24:work_and_consequence",
    "history_summary:w24:relationship_obligation",
)
SYNTHETIC_W24_FANIN_WORK_IDS = frozenset({
    "decision:arc_temptation_fallout:0",
    "decision:arc_temptation_fallout:1",
    "decision:v2_dirty_recruiter_week24:0",
    "decision:v2_dirty_recruiter_week24:1",
    "decision:v2_dirty_trace_initial_call:0",
    "decision:v2_dirty_trace_initial_call:1",
    "decision:v2_hanbit_offer_message:0",
    "decision:v2_m3_room_ledger_anchor:0",
    "decision:v2_m3_room_ledger_anchor:1",
    "receipt:application:city_facility_ops_2026h1:submitted",
    "receipt:application:hanbit_ops_2026q1:resolved",
    "receipt:application_transition:m5_hanbit_offer_message:v2_hanbit_offer_message:0",
    "receipt:deferred_callback:callback_escaped_dirty_trace:claimed",
    "receipt:deferred_callback:callback_escaped_dirty_trace:resolved:v2_dirty_trace_initial_call:choice:0",
    "receipt:deferred_callback:callback_escaped_dirty_trace:resolved:v2_dirty_trace_initial_call:choice:1",
    "receipt:deferred_callback:fell_to_darkness:claimed",
    "receipt:deferred_callback:fell_to_darkness:resolved:v2_dirty_recruiter_week24:choice:0",
    "receipt:deferred_callback:fell_to_darkness:resolved:v2_dirty_recruiter_week24:choice:1",
    "receipt:world:m6_city_service_response:resolved:week_index:3",
    "state:deferred_callback:callback_escaped_dirty_trace:absent",
    "state:deferred_event:callback_escaped_dirty_trace:due_turn:24",
    "state:flag:escaped_dirty_money",
    "state:flag:fell_to_darkness",
    "state:flag:m3_ledger_reasons_named",
    "state:flag:m3_ledger_totals_only",
})
SYNTHETIC_W24_FANIN_RELATIONSHIP_IDS = frozenset({
    "decision:v2_daeun_small_commitment:1",
    "decision:v2_father_health_signal:0",
    "decision:v2_father_health_signal:1",
    "decision:v2_father_health_signal:2",
    "decision:v2_jaehyuk_plain_reunion_echo:0",
    "decision:v2_jaehyuk_plain_reunion_echo:1",
    "decision:v2_sangchul_demo_echo:0",
    "decision:v2_sangchul_demo_echo:1",
    "memory:daeun:daeun_late_meal_promised",
    "memory:father:father_called_again_that_evening",
    "memory:father:father_health_warning_postponed",
    "memory:father:father_neighbor_detail_checked",
    "memory:jaehyuk:jaehyuk_reunion_guarded",
    "memory:jaehyuk:jaehyuk_reunion_warm",
    "memory:sangchul:sangchul_numbers_first_recorded",
    "memory:sangchul:sangchul_own_pace_stated",
    "receipt:completed:daeun_shared_dream",
    "receipt:completed:hyunsu_exam_eve",
    "receipt:completed:hyunsu_study_followup",
    "receipt:completed:jaehyuk_plain_reunion_echo",
    "receipt:completed:sangchul_second_coffee",
    "receipt:future_story:hyunsu_exam_2026",
    "receipt:future_story:hyunsu_exam_2026:source:declined:hyunsu_exam_eve_unanswered",
    "receipt:future_story:hyunsu_exam_2026:source:relationship_memory:hyunsu_exam_eve_one_problem",
    "receipt:future_story:hyunsu_exam_2026:source:relationship_memory:hyunsu_exam_eve_rest_protected",
    "receipt:obligation:demo_collision",
    "receipt:obligation:demo_collision:deferred:candidates_minus:body_rest",
    "receipt:obligation:demo_collision:deferred:candidates_minus:city_work_sample",
    "receipt:obligation:demo_collision:deferred:candidates_minus:daeun_checkin",
    "receipt:obligation:demo_collision:deferred:candidates_minus:father_call",
    "receipt:obligation:demo_collision:deferred:candidates_minus:hanbit_month_close",
    "receipt:obligation:demo_collision:deferred:candidates_minus:jaehyuk_reply",
    "receipt:obligation:demo_collision:deferred:candidates_minus:sangchul_ledger",
    "receipt:obligation:demo_collision:deferred:candidates_minus:urgent_paid_shift",
    "receipt:obligation:demo_collision:selected:body_rest",
    "receipt:obligation:demo_collision:selected:city_work_sample",
    "receipt:obligation:demo_collision:selected:daeun_checkin",
    "receipt:obligation:demo_collision:selected:father_call",
    "receipt:obligation:demo_collision:selected:hanbit_month_close",
    "receipt:obligation:demo_collision:selected:jaehyuk_reply",
    "receipt:obligation:demo_collision:selected:sangchul_ledger",
    "receipt:obligation:demo_collision:selected:urgent_paid_shift",
    "state:completed_bundle:hyunsu_exam_eve:false",
    "state:relationship:hyunsu:shared_commitment",
    "state:relationship_memory:daeun:daeun_same_tuesday_promised:false",
})
SYNTHETIC_W24_FIRST_BILL_VALUE_BY_ID = {
    f"decision:v2_demo_first_bill:{choice}": str(choice)
    for choice in range(8)
}
SYNTHETIC_W24_FANIN_RAW_ID_UNIVERSE = frozenset({
    *SYNTHETIC_W24_FANIN_WORK_IDS,
    *SYNTHETIC_W24_FANIN_RELATIONSHIP_IDS,
    *SYNTHETIC_W24_FIRST_BILL_VALUE_BY_ID,
})
assert len(SYNTHETIC_W24_FANIN_WORK_IDS) == 25
assert len(SYNTHETIC_W24_FANIN_RELATIONSHIP_IDS) == 45
assert len(SYNTHETIC_W24_FIRST_BILL_VALUE_BY_ID) == 8
assert len(SYNTHETIC_W24_FANIN_RAW_ID_UNIVERSE) == 78
SYNTHETIC_W24_SUPERSEDED_RECORDS_SHA256 = (
    "d245c902460bf67259efe7a70ef9f7804a6dc38ac5cc165c3ebd20c06f4eef92")
SYNTHETIC_W24_RETAINED_RECORDS_SHA256 = (
    "7c01d19a04a17f2325c32f1356e36fb980be6bc2cb2cb7b9f6e43093ca7827fa")
# The complete fixture makes one separately approved SHADOWED_READER repair
# to two of the retained records.  This digest locks that exact delta; all
# other retained records remain byte-semantic copies of production.
SYNTHETIC_W24_REPAIRED_RETAINED_RECORDS_SHA256 = (
    "60bb77d1ee05491ae78778b50cf36a48be8a7e6323a48ce6cb19704157a8dcbe")
SYNTHETIC_W24_SOURCE_SCENARIOS_SHA256 = (
    "b44eceaeff69f0efac42344b9f3e5c27883a32caf06fc8f657e3f57913fccbb3")
SYNTHETIC_W24_SOURCE_SCENARIO_COUNTS_SHA256 = (
    "74370afe058aaf6d1ee547e9efa553654c2b7543849b8225925d30afa2fcb1d8")
SYNTHETIC_W24_REPLACEMENT_SCENARIO_SEMANTICS_SHA256 = (
    "005a64ed84f9a75eaa8ecac13bb092dc2fdb714a4c61e1c00a51e56cf5170909")
SYNTHETIC_W24_SOURCE_TUPLE_STAGE_MAP = {
    "w24:candidate_aggregation": (96, 5376, 768),
    "w24:completion_validation:loaded": (9, 45, 0),
    "w24:decision_prechoice_snapshot:fresh": (96, 4608, 0),
    "w24:decision_prechoice_snapshot:reentry": (96, 4608, 0),
    "w24:dirty_choice:reentry": (48, 96, 0),
    "w24:first_bill_decision_result_restore": (3, 24, 84),
    "w24:first_bill_description:fresh": (96, 1152, 0),
    "w24:first_bill_description:reentry": (96, 1152, 0),
    "w24:first_bill_replay_capture": (199, 1592, 196),
    "w24:hyunsu_morning_resume_restore:result": (1, 160, 0),
    "w24:hyunsu_result_format:fresh": (32, 3072, 0),
    "w24:hyunsu_result_format:loaded_chain": (4, 640, 0),
    "w24:hyunsu_result_format:reentry": (32, 3072, 0),
    "w24:ledger_description:fresh": (64, 6144, 0),
    "w24:ledger_description:loaded_after_first_bill": (2, 320, 0),
    "w24:ledger_description:loaded_direct_prose": (2, 320, 0),
    "w24:ledger_description:reentry": (64, 6144, 0),
    "w24:ledger_memory": (132, 396, 0),
    "w24:opening_after_bills:fresh": (48, 576, 0),
    "w24:opening_after_bills:reentry": (48, 576, 0),
    "w24:opening_description:fresh": (96, 4608, 0),
    "w24:opening_description:reentry": (96, 4608, 0),
    "w24:prepare_fresh": (96, 2688, 0),
}
# These digests are independent trust roots derived from the frozen production
# ledger, not values supplied by the synthetic fixture or its Python manifest.
# Together they lock the exact 27-invocation option surface (including temporal
# roles, Story decisions, handoffs, outputs, and effects) and its intended
# non-Story replacement.  Coordinated edits to a fixture and manifest must not
# be able to author a new comparison baseline.
SYNTHETIC_W24_STAGE_TUPLE_DIGESTS = {
    "w24:candidate_aggregation":
        "da5cd0b28690a5657a75e8b3bb8f7fce89b93b0144ef42fca5756342a0b0093b",
    "w24:completion_validation:loaded":
        "e59e8d7e1329bced38c01b428b8ad281a659862d4eb79d79bbda036dc1cdd0a4",
    "w24:decision_prechoice_snapshot:fresh":
        "17212a4f00fa19774adcd2a3f6ef06cf050fc01e1b07174a329cc5af4240dbc1",
    "w24:decision_prechoice_snapshot:reentry":
        "82c5dcd71ccba0a7400425cc909344cda4192d92e0653f2b9115b1df22022f3b",
    "w24:dirty_choice:reentry":
        "25166812899c8acf6dda44e38ecfac98c4ffa87b57a61d1610e74f83dd5bc454",
    "w24:first_bill_decision_result_restore":
        "4203e79b0c9bae1557e73d50e46151c9e5766c515bf5a6e10b3b3c3982b7d4c3",
    "w24:first_bill_description:fresh":
        "69b9181ccb1b85a2167b1825fd2ea13aa90d1de0bb6ad6605ca29300d827f089",
    "w24:first_bill_description:reentry":
        "41de2cd0b2e3241c100d830f1dcdd96784e3995ca325ff55353187e18a4e1212",
    "w24:first_bill_replay_capture":
        "e6927feb7184b0430f5e0640c480198d795097f99838a62634f5b6bdd6406a5d",
    "w24:hyunsu_morning_resume_restore:result":
        "e9890323f8cbf4507da3351e18c585f0908e4ecdaf4ef99205f7604b71751ccd",
    "w24:hyunsu_result_format:fresh":
        "1677dd320a01cd9cee65d3fec4ad0243692cb0ff34faad04ec6c4f87d1f72a53",
    "w24:hyunsu_result_format:loaded_chain":
        "e9890323f8cbf4507da3351e18c585f0908e4ecdaf4ef99205f7604b71751ccd",
    "w24:hyunsu_result_format:reentry":
        "7dbd43949311ecdd32609c631d2249e936b744d5ebc0987df81866bef11b43b5",
    "w24:ledger_description:fresh":
        "1677dd320a01cd9cee65d3fec4ad0243692cb0ff34faad04ec6c4f87d1f72a53",
    "w24:ledger_description:loaded_after_first_bill":
        "e9890323f8cbf4507da3351e18c585f0908e4ecdaf4ef99205f7604b71751ccd",
    "w24:ledger_description:loaded_direct_prose":
        "e9890323f8cbf4507da3351e18c585f0908e4ecdaf4ef99205f7604b71751ccd",
    "w24:ledger_description:reentry":
        "7dbd43949311ecdd32609c631d2249e936b744d5ebc0987df81866bef11b43b5",
    "w24:ledger_memory":
        "18b9bd6bd5551e1b9f53fc0bc4faac29e2a0b49d802e4bf112bde9973eb4ff65",
    "w24:opening_after_bills:fresh":
        "69b9181ccb1b85a2167b1825fd2ea13aa90d1de0bb6ad6605ca29300d827f089",
    "w24:opening_after_bills:reentry":
        "41de2cd0b2e3241c100d830f1dcdd96784e3995ca325ff55353187e18a4e1212",
    "w24:opening_description:fresh":
        "4f8b11091b11fb538e30ab54ad4d2b070974c36e57e3c34b7f8c5f53bd8e397b",
    "w24:opening_description:reentry":
        "94bb7082b316266fbc83bb8c14e61c85b086bb72c1cb016b7bc30610fdaba283",
    "w24:prepare_fresh":
        "2f728a10e9ca8058933f11c99e5675b6ded554a62445116ba6bcf1acc0294e84",
}
SYNTHETIC_W24_STAGE_TUPLE_MAP_SHA256 = (
    "80e583c047c465474219fe7938f90d0a36ccd28c89e361498bb18b8558e2d451")
# Production still has the deliberately shadowed generic application helper
# at the loaded completion cut.  The complete fixture's separately audited
# seven-way identity repair is the sole permitted old/new tuple delta.
SYNTHETIC_W24_PRODUCTION_STAGE_TUPLE_DIGESTS = {
    **SYNTHETIC_W24_STAGE_TUPLE_DIGESTS,
    "w24:completion_validation:loaded":
        "9019a6097b87ee1cebd93a25f96d9d407239e06394608f0aaec0d410f7fc8b5d",
}
SYNTHETIC_W24_PRODUCTION_STAGE_TUPLE_MAP_SHA256 = (
    "364ef3b4cf45f36a8d9e8943875fc834aacd4361d93ce5486d5a3ce8ef670a73")
SYNTHETIC_W24_ORIGINAL_OUTPUT_MULTISET_SHA256 = (
    "83488e4f5ddbba5a1627ad217036b2ab38f37e40038a3d7f82eb6fde583fd3d3")
SYNTHETIC_W24_RAW_CLONE_RECORDS_SHA256 = (
    "74c4384405a00e122c810fff5fc849757b35f7471071596b8dec06555dc69be7")
SYNTHETIC_W24_REPLACEMENT_INVOCATIONS_SHA256 = (
    "38a11215e256e0c9a9066f4e0b6b6f2cb024b3a1ae25ffd609abf777e08c8ffa")
SYNTHETIC_W24_FINAL_AGGREGATE_STAGE_SURFACE_SHA256 = (
    "9eadc24b42bc35425923277f791841144146b0b3c1fceb9fb61122706b3a5c9e")
SYNTHETIC_W24_REPLACEMENT_STAGES_SHA256 = (
    "e405ae57737e9ac758ba40135e74cc1b6eecb14af03e27ef5e3555c28abc8e20")
SYNTHETIC_W24_REPLACEMENT_GROUPS_SHA256 = (
    "b7a20bebacac866bbd09865da2bf2486594fb41233853d528f7b7eb4546c09a1")
# The complete fixture's replacement surface is Python-only, but it is still
# a trust root: a caller may not coordinate a reader edit with its proof, nor
# substitute one of the two compressed Story summaries for a row-owned raw
# consumer.  These digests lock every replacement reader and synthetic W24
# proof after the independently checked production->fixture construction.
SYNTHETIC_W24_REPLACEMENT_READER_RECORDS_SHA256 = (
    "af0f0f4635ebed81ec9af77c8e107714beb20fd33477bb1eba00b4af4e7bc4f2")
SYNTHETIC_W24_REPLACEMENT_PROOF_RECORDS_SHA256 = (
    "d5f893b2f28754a42daba0e672dc2e1077c8683e9b00f178658a4bdb53364c05")
SYNTHETIC_W24_ROW_REFERENCE_CONTRACT_SHA256 = (
    "5c1573b458e4cb8e5fc8ac2b47f60078678cfa4f3c9db6672b3ccf7b6c4821f5")
SYNTHETIC_W24_PREFIX_REFERENCE_SURFACE_SHA256 = (
    "7c1696947c264c15c548e818a61aea49edf0c4fc70f17622790eff14c975dc1e")
SYNTHETIC_W24_FIRST_BILL_DECISION_HANDOFF_PREFIX = (
    "handoff:history_summary:w24:v2_demo_first_bill:")
REGISTRY_ID_FIELDS = {
    "reader_registry": "reader_id",
    "milestone_registry": "milestone_id",
    "replay_witnesses": "witness_id",
    "runtime_proof_registry": "proof_id",
    "counterfactual_registry": "counterfactual_id",
}
RUNTIME_PROOF_FIELDS = {"proof_id", "kind", "pointer", "assertion"}
MILESTONE_REGISTRY_FIELDS = {
    "milestone_id", "week", "status", "reader_ids", "runtime_pointer",
    "runtime_proof_ids", "invocations", "co_presence_groups",
    "execution_stages",
}
READER_REGISTRY_FIELDS = {
    "reader_id", "reader_kind", "layer_owner", "status", "reads_fact_ids",
    "input_build_family_ids", "story_decision_ids", "runtime_pointer",
    "runtime_proof_ids", "read_contracts", "history_memory_ids",
    "material_state_ids", "scene_handoff_fact_ids",
    "scene_handoff_decision_ids",
}
READ_CONTRACT_FIELDS = {"fact_id", "runtime_proof_ids"}
MILESTONE_INVOCATION_FIELDS = {
    "invocation_id", "runtime_pointer", "always_reader_ids",
    "conditional_readers", "exclusive_variant_groups", "runtime_proof_ids",
    "conditional_producers", "producer_variant_groups",
}
CONDITIONAL_READER_FIELDS = {
    "reader_id", "activation_fact_ids", "runtime_proof_ids",
}
EXCLUSIVE_VARIANT_GROUP_FIELDS = {
    "group_id", "selection_mode", "causal_status", "debt_id", "variants",
}
CO_PRESENCE_GROUP_FIELDS = {
    "group_id", "invocation_ids", "runtime_proof_ids",
}
EXECUTION_STAGE_FIELDS = {
    "stage_id", "order_index", "applicability_ids",
    "predecessor_stage_ids", "invocation_ids", "runtime_proof_ids",
}
REPLAY_FIELDS = {
    "witness_id", "checkpoint_week", "status", "route_ids",
    "distinguishing_axes", "reader_ids", "runtime_proof_ids",
}
COUNTERFACTUAL_FIELDS = {
    "counterfactual_id", "chain_id", "status", "branch_ids",
    "distinguishing_axes", "runtime_proof_ids", "branch_contracts",
}
BRANCH_CONTRACT_FIELDS = {
    "branch_id", "outcome_kind", "applicability_ids",
    "produced_fact_ids", "runtime_proof_ids", "nested_output_group_ids",
}
CAUSAL_READER_KINDS = {
    "near_consequence", "story_milestone", "action_unlock", "next_verb",
}
ROUTE_CAUSAL_READER_KINDS = {
    "action_unlock", "near_consequence", "next_verb", "route_modifier",
    "story_milestone",
}
NEXT_VERB_READER_KINDS = {"next_verb", "action_unlock"}
READER_LAYER_BY_KIND = {
    "display": "summary",
    "month_summary": "summary",
    "producer_result": "weekly_action",
    "near_consequence": "story",
    "next_verb": "story",
    "action_unlock": "story",
    "route_modifier": "story",
    "story_milestone": "story",
}
MATERIAL_STATE_PREFIXES = (
    "state:health", "state:money", "state:required_cash",
    "state:player_name", "state:housing", "state:mental",
    "state:addiction_tendency", "state:moral_tint",
    "state:total_assets", "state:housing_expense",
    "state:current_job:", "state:demo_collision_context:",
    "state:world_clock:", "state:prelude:",
    "state:story_resume_context:", "state:story_resume:",
    "state:active_bundle:", "state:active_turn:",
    "state:story_fatal_gate:", "state:story_queue:",
    "state:first_bill_replay_snapshot:",
    "fact:routine_selected:",
)
SOURCE_TEXT_CACHE: dict[str, str] = {}
AUTHORED_EVENT_CACHE: dict[str, dict[str, Any]] = {}
TRUSTED_EVENT_PATHS = (
    "content/events/core_loop_v2_events.json",
    "content/events/arc_events.json",
    "content/events/arc_daeun.json",
    "content/events/arc_midgame.json",
    "content/events/scenario_cafe.json",
)

EXPECTED_GAP_PROOFS = [
    "proof:contract:months_stop_at_m06",
    "proof:runtime:turn_limit_24",
    "proof:runtime:w24_completion_cta",
    "proof:canon:w25_w48_gap",
]
EXPECTED_GAP_PROOF_POINTERS = {
    "proof:contract:months_stop_at_m06":
        "content/meta/demo_core_loop_v2.json#/seoul_cycle/months",
    "proof:runtime:turn_limit_24": "autoloads/GameState.gd::DEMO_TURN_LIMIT",
    "proof:runtime:w24_completion_cta":
        "scenes/MainGame.gd::_core_loop_v2_advance_completed_week",
    "proof:canon:w25_w48_gap":
        "docs/CORE_LOOP_V2.md::Chapter 1 48행 인과 원장",
}

# Generated from the coordinated ORDER-100 ledger/source scenario freeze.
# The decoder verifies this canonical payload before exposing any map.
FROZEN_AUDITED_MAPS_BYTE_LENGTH = 596463
FROZEN_AUDITED_MAPS_SHA256 = (
    "108e36e09cd37be50f9fcc6601b0fb3d113ed7b246a4b1d216a18f0aeea749cc")
_FROZEN_AUDITED_MAPS = _decode_frozen_json(
    (
        "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"
        "OB2+vZe4912vIz7vHazkvaWdDO/exZLeW95hTPE+j39PuzoV/r2PsN/uA9956c6Ghb9N6qNl/W1Sn6zv+yjRbzf3F3zp77DL"
        "3yT0Rc/68q7eodTHEwHlk6TBww9+OJCDKfInP+xn5f71Zz6d3V9/4kkM8/THnUQhT3/ciRzx9AeezJlOf+QPYnlQgZ/Plv1l"
        "9b3ziEcTaF/89l0O7cF3f5KofPJLP/zWaYZ16BsvnM49+eI5ZvfCF88TfLptHv3aeUJPNN/D3zlP3Inmffg754k72fyPfes8"
        "kWc4iOPfO0/si7tThz7//HnzS7d+7vIcTz7pu/r6qd3ozPUuP5Jf6ErM9nF++lOpp6+7YvT0qRqPHnsz+80cb/jgb5/b5+t/"
        "5teTHnrmTO4n5adO5O2xer/68tLB/avHfqIE+7YSnjngf9/n27dcyDsA+ruM4iWY/Qtmce6jTzSMAwj95Rn9/cbxwgy8iXm8"
        "QsaZBvIWEuwrl/SZm4xvbhnn3JY8xRx+5XlPbeC5Z502Swzw8u6m9qlnHd9f5sd3H0Hf14/uwQOfQbZv8tyfoOubPPUxPH2T"
        "Rz6GoG/yyKcg800e+jOIfJPH/gCLv6jg7+jOzxjjeT78Fx98yHG/9WPt69fm4WXwd/bUJ907P99hv+qxx/32o0eeNYO/x4uf"
        "N+SznfmrH3+KT3/1w1907a9+8ose/tVPPsHRv/rZJ/n7Vz/9qNt/vX38tiBwysB/JRa89vmnhYQ3e7p9q+V7VPfj9wSK00qN"
        "vDpgvO7xJwWOx49+1Qz/1kBy5lS8NqC8XswZgeX1Qk4NMK+XcGqgeb2E0wPO62WcE3heL+WUAPQGdva7A9JJE/IGgenVcs4K"
        "UG8nxb7ZMr/Xhux5VbfOD0u/uv36/NNOna3fE29OHuPZIeY1Tz4lqrzmuS8Gktc89MXY8ZqHnhAuXvPYkyLEax58NCicq/K/"
        "zfW/6bHCLz/6NAf/hocIp67SobqPb+7Jzy4weYoz/+WHPvXnBx94xsy9l1d//WBPcOxv8vDnffubPPoZ9/4mz33Gw7/Jc591"
        "8m/y5AN+/k2e/cTVv4U1vKPDP3fI5/n8t3j6Ibf/Ls+2b7FoB0rx/o5wcG4V4FcGiF8Vc0LIOCTil1bgN4aVV0/R6wLNW4g7"
        "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"
        "i0uqklDwby0we8sor7Iq3LPgPq7dIGyC53yiC1QAC/kXHNy3qYVIXk3SntEiDqGg8ojwQXiXUX4F6OegyIM7icHPQ7PM/V/N"
        "cSSt1WCOjRaYSXOP8kvu9GGsagVWM5VzdxrjZbYnPStTH0h7XKNNIiQVIWihZG4AQ+OKrfTNqsiZk1jvaBFvyADXtO40xutc"
        "o/KgZ2cUVYZ27TyWL1kBRkF+ux1R/0GnewtE2SBCWmOsSjlurVzqu4/xyd0dTeio+YoaR1xd+zZbs6yQuVsffm5E8vPgdLPF"
        "upI+cDZIbRX8Aeq42yivYL5Q6Oj1fIdCDp8L2/fWs089DaXxocU4BsLFykGFmmwU58QAp0213W2UX1SAVdpraLQYAZG7nKbD"
        "1Ccq+9goqjk54I7F0OmEebkwk4K58Lxof35lztH/rN8wif79jyMd+tVLIWub0kyew5yu9JNoRmDNuUXxx8ChKs86tn61xENz"
        "sApQPiFPnbo4vqEpfTokAO40Rm8XmvT1uB9vM9FnC91ya10E0hXRmXJKARUt54ZRCLNb1OAb3Ys0ZGqXcwr12mLLN48RiqPs"
        "oRllRQ46LBfC4uI0gmKCDjg3eIwzXLPUNhePlgrutyL6QZOvhLS3FSAu405jbMKwHLQ+1CZoYHWLvWwtudD6omoSFapkGz1L"
        "StVm0jCkfbWTiyFM21eNYqB4C7//XH+2G7tdkRTP5xFp8LRTAUfD1EKLs++NMQflUz4eXTfqp3JzOZUgclOFyrU8991GeVmT"
        "LeyYDQSX4y+TrIJTrl68Nszjyjy0bZylXWlH6s84T9bPxO5G+ZqR1LeM8rIqRfhOb6LF2aSgcieu0MM83ciitGFn+v6T4qhX"
        "GNjodBYF1Jpqbvm1cfJvjPKyLnvyWRGvOv2X40YlKXAjBd1p/TqyPT1vm9quG00cUURTNPVGuZ52h78/yqeu1y6L0ePoPY5F"
        "sXiA5lqkRR8mLk+LlWCkdvyYyoal9mxpS21FPGhoAaw+YnnfoV1WoBC4AGyZQ6MJ+mBFdDYhZuzQLC5LgZxDIHaOUzQaYcLP"
        "FMu1Bl2d6X2Hdll2nhPCWZM+mzDjLtOSeNdsgolHZQdPRNeMINpKmcMtH/sazUUBx/TaJpTXDu2y1nwQezJpaE+K9ru4FKq3"
        "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"
        "oupKk9fN5yyKXOChdGtKX40zLpansr60+HCsd7pRTzEIZptewqwOvADMyLC3LmGoUtaCbVJOkqMk1k6uj1RkctE6DGo9HOst"
        "B0KMYeVrw4kukzy5KWmtCf+QbeRxfA0xjmVLgls83URXN0HOllL+dhh8+m9/4Vdm/+tfv6BLt72uZ9RpKmc1uMqjE21zbjmN"
        "csoqOpludUpUhkLG000Si5VTurNcplzJ6pIJ7jMh3rKzr9nkC9iPbtSJ80qFjrrgF1RzSXweyk5SuqW7OF1uzSMLu1F5ifSZ"
        "EJtMn1Pf7RKEBsNIFiVqIFo+my7GpJv5+xIaGRonNgCEriRkqUZTA2QlnM7sLq3w1iHeZeA+ft+auFg7yhWpAx6cZOe1jnTF"
        "qcoTnM6lozhX6pBW3IjAo25V7teyK3k00jvA0U2cKffnPSnnFYDIK/ZxQXfkCENtBeKM5CRxRTs+ukg9MohYnocnPhrp7e3D"
        "DJr0wIucTEMDkEG9SpOZ7TDgyi5dYk11WBwtX8outfeZTea97bFI/yC29nEWnAzhnlPXyOqgolYjwNgzq0yaQiVVXeyoUqin"
        "9O/kIBY7LJ26A91beZeI76MZTf7ggBidikgWXptHk29TJDRD6Y8DZONkQqIpkzpPIyfoA1u7IS+4WPaSiG9ZMQNrqfSsLZp1"
        "SUWvU5qjpvY+aJ4QIJNhc6B+TV2L1JRMg+KRTam9YGz+TyL+55XCWyJICYlnbBP0VA10WEa1nqHnPsoGVyR3uzC15Iare56p"
        "sf5sdC9W5lNB3qnv3EDRop1bOxZKgbKnDm8sJwJiYe2eRiu/0ajLSUByA3M1yRbUDRZ/Ksjb67bRt44LRm/wAHoTDdxiqgBS"
        "2aep5l+ChZnequ7p82qxTNA2WVrnGxTWzyuNffzGZbvrNlCU1T/hhlXn6Y6FrSkiljrkpl6NoOzu5+xAlnLdngJ712X5wThv"
        "L33FYN4FXSiQDVgH5WlON5+pm8ONXkAGFJ7y9OAnNdhpy1HDRiR13yIzPxvn7b1n7Q1GGmZnwRQfzmTdtGRh6Td68Vu3EGmf"
        "ZUU4e9+SGMrQgnyd/a5H4vysetfHmVBbzc0lIpS0DPEFL/noFXThIDXjQWvUJlaSdC0ttz2opGG5JhuJ+K6R34c3dbdzxOUk"
        "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"
        "hxlX7jvu6+/74JTxLXKw7xNpXX3q8is/WjonNziDwd/ziU8A9iBP/tHKXy9ffuPDxI4P22uGbz70+ur27hp/222OaufH7TXL"
        "LY+dTg+4Ha7y+dninugkX9UJVt6d0GGdrpw3rJ1prCkdrccTbT/xhx93SdMfjojmHH+f84lfM4/VM4uDzmHCLT+vbv6Cb6A5"
        "+qgqqNmG30sjDjKNwynGzNPZRz/2nMoC6E0mE0b9g8qh5xl7L834+BwOpxZzzmUfndhzHs/c/Uc1Qswx8l768NEZHE4b5pvJ"
        "Prqw5yyWvG1xiFzOMcBHVULOOIG9NONAEzmcgsw+oX30ZM/JPJBlXgT/81EVMfOMvZd2fHwOh1OMOeeyj07sOY/H04jF6B/V"
        "CjvX6HvpxSFmcTjNmHc2++jGnjO5v/kO3nt6nc7q6e2Ps/5hjurmG38v/TjMPA6nIXPPZx8deX0uj5FK6XY6BV99zoU+vbm6"
        "uniYRbosP65utiCZ5ffuru7S+Y4Pe93dPdzeHv5YbcuTD3S8tj7CQY7ZNj/0QMdtaw8/1LHba4890PHbwy354rS2ppu/Vh6Y"
        "bsrz25nO7Kj7bbcpq8/DpkvXbZcnvr6uqwF6z46mXjl23vnUae3BL442dnu+2vX5qxx5t4frXR/+nHLt9uidF3wDWN9tBLnr"
        "CKuob7eHm10fvg4cdnu83fXxL73ObgO4LQOshCK+Hq/8tBU+sgd2HWx9e3xkX+w65sqW+che2XXAZ9voI/tn1+Febq2P7Kld"
        "R13Zbh/ZZ7sOuLYFP7L3dh3yxbZ8/35c3GCWq+vt18z7koB9758/PI3tXGDO6XyAEvyaaW1lBrNMSR5If+R803iP/hxmOgfX"
        "n7mn9Q792W9KG8M/3qVBe8WFHGAqO2jRjFP6qCb9kqm9rU1zTEseTJ/knFN5nz4dakoz6NP8U3uXPmFajzGfZ5fX93evBXya"
        "k6cKKiep/p0uS2ME5lSpBwM3TOb5Vy7kMn58qq7z1hee/v/GVVod/fzs73Z+9uPqqm4ZvFxd/t0uzxqmuWUGa9/aaxrX7WrB"
        "l157+IJ1bBn96Qt7DXzbzvvWZS9Xf7dlWaO3v/LW0OFkUQzl7BKa//dZ+9nWlv36+vzs4dHLb9b727sb6thdKz9Onv9yZU77"
        "/vLtqW4ISn4abxn+2Oor4clTHaU78I/z9P3knDwjlXJ1Dx1/PusPPYUPejNI+vU3lOpkWQjk9j5fnN3drcniaW4X6qFkyLNV"
        "/vavjWv/WLrkkgbi7lQJ5f4X5uZxiM2vf+gh3pCuEg+8+jVNfDY1c7r+3Vcm9hAFfn37MKfXtHWWp7/1zs/jrHlS8+rOm45x"
        "eipn5/yHhwF/PF/ipyn+vLo5x2u4RQ7BLSdUJvp9fXV5O2XJXp3/jRclhuWebP+dTmF+4cj7rNNKDsEm+S1TCX6kG3pNPO3i"
        "cdPetPPprW5/nF0v8x4XX3/4Ubpop3f37bYmJl9cXZzd0hCk86mE4YYfcBp4EAzaw7dfUapfP6kV27Q942JHSTwmXmzUHMKR"
        "S2CayfzbzfkYr+dpPCxOub+5oZH9z1U+wf+dCr3zXnzQttdU+6MTfMcsXn2ndeG8mr2yo2heJrFsUsrXE06eFGv5nWfHj4tv"
        "PTx5s7of6Mnry/JG8s2ei7PMwTn0/KfHHn5ZHh67x5rsoTAbkoc2vcDj124BMS9BKamhz8zQw+cn689bcioi0y1qc8jHr6/T"
        "K+lP+67PMgvqMLO/+nk5PfB0MgyHW5UNz91hOfZQl+VBPa3XNMS0Ii+tG7HvAwt54+Ot455NZ28LFPEKNt4Ts3wA7uyGV55y"
        "scp06bHIO39cpWnVy9X5+eL+Y1nm62RZSmwFVD0P2F751cpMDv3cXV/s8d700DPY8Vs7Drq/xJ4CNWaQ2X7TPpzI3s673FFR"
        "F7+/vbq/YXmkBgx5dzXFoVy2ZyR5649ZO+H1qTxbzNqAgoibeaSVU/nrxYBPzOL1V1vWPxJ77JrP/ZI73n8dNlv3a6/ojI/+"
        "xcu2u77sbEXf1pqdTeyntza/gXhn1t+jGRv55V2U/BNclNxVa+SBtObLuyg5n4uSn8hFyQO6KPkHuCj5B7ioeY3NxuiQ9zip"
        "h1ddBuDX589/zxq/nNhWJdo2/IbF3vDaH+VYX2oBdo74OXQdoT93xY820G+1wPvo2ntd40aNe59z/GpW7rdThqPuhKMaOflH"
        "u1X5p7tVubvGyYNp3B/tVuWx3Kr8xG5VHtStyj/crco/3K0exshtLh7w74eQgcXHm751evcj3Z22v6f09Wkq+/9k/QVeLSKw"
        "dddsr1LwKV/lsRzCK1O5bGfff+Qrxv/fpbPzxx+8OvctP9hp5mK/mb+9/r/tGzwv7PDKVJYP/pkWzWWefvHq5Lf9YqfZq31n"
        "/7YEfue3WNbVv26XlfvrycEtPzm5cCcbR3j4xYpr2O9HW+f3rIHZU8hXW8ks//+e5+2/4Z12ecjuWH7Xpx3m7XaHH7u/5SFX"
        "60NvuV4O4TBC3fLUQ0j5jcfPtCCH0IM3F2bWFT/swqxUtZhJb14bYxYt2jbYUZZuFg3bvoRHlNScS7ipTsZc7/ZyrCNo4+ZB"
        "j7qkR9DO15b2F0jysEu7UqtmJlv52hizaOe2wY6ydLNo4/YlPKKk5lzCeW3lW2MdQRuPYSvfGPEI2jm7rdxdkodd2rUyWzNZ"
        "y9dHmUVDtw93pAWcRSvfWsijSmzehZzXcr492lE08xjW880xj6Kps1vQfSR62AV+MdJMVnTbOLNo61sDHm0ZZ9HQt5fzyJL7"
        "0HLOcEA053nQbMc/M572zHO4M/NZzhskfA5NmdtO7TfacVbv8Po1n3l6j7Q+tIovSxYfRu22PvcQmvbmALMtyyH0aYflmXnl"
        "D70881yg7TfQTHo15zXbXsPNpHmzXca9V3qzr+h6IfpZ33B1sGPp6MtRj7uqx9LVTav7K6Q5++qul/mf9S1XBzuWzr4c9bir"
        "eiyd3bS6v0Kas6/uy04Rs77n+nDH0ttN4x57bY+lu5vX+NdI9dBrPMNBzR6jzKStsx3n7D7WTLo5z6HPuyR26IWcIU5ij1Fm"
        "0sTZYiV2H2smTZwnXuJdEjv0Qs5yC73XODNp44w30fuMNpNGznUb/U7JfWg5ZzCGc1q+2czcjDZtHgM2s7V6IzBnDk2Z+/5k"
        "v9GOs3qH16/57k/eI60PreIs7nFeXzij45vVy83l0mb3X2+Gv8yjNXPbqn3HO9YazqFr81ms90ntQ2s5k/7NrW+z6tfM+jSf"
        "/hxMX/DQdI7f3d3fPL8SW7SIW3z4fepv9dRk9+7mvq1Of8dvb53S1c1FumPpvWWDQHzAfjX5vF0sWuGt9Al+aoe3YwWgh4oO"
        "y6e3/6YL0JlFhvOy4cZDMYd+z57gp9NLnTz/Pkv/7/q9k2Utik3dfJ5/t/3dnr/qSn2VXz2RXVT0zXWdReg7780h9ndM5OMC"
        "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"
    ),
    source_name="ORDER-100 audited maps",
    byte_length=FROZEN_AUDITED_MAPS_BYTE_LENGTH,
    sha256=FROZEN_AUDITED_MAPS_SHA256,
    top_level_type=dict,
    item_count=12,
)
_FROZEN_AUDITED_MAP_COUNTS = {'proof_bindings': 1493, 'story_pointers': 330, 'story_decisions': 91, 'story_inputs': 330, 'invocations': 80, 'producers': 80, 'stages': 75, 'scenarios': 6, 'co_presence': 6, 'co_presence_pointers': 17, 'exclusive': 60, 'exclusive_pointers': 60}
if (set(_FROZEN_AUDITED_MAPS) != set(_FROZEN_AUDITED_MAP_COUNTS)
        or any(type(_FROZEN_AUDITED_MAPS[key]) is not dict
               or len(_FROZEN_AUDITED_MAPS[key]) != expected_count
               for key, expected_count in
               _FROZEN_AUDITED_MAP_COUNTS.items())):
    raise ValueError("ORDER-100 frozen audited map shape/count mismatch")

EXPECTED_STORY_READER_POINTERS = _FROZEN_AUDITED_MAPS["story_pointers"]

EXPECTED_STORY_DECISIONS_BY_READER = _FROZEN_AUDITED_MAPS["story_decisions"]

# The four lists form one indivisible source contract per active Story reader:
# facts read, historical memories, material state, and authored decisions.
# Validating the tuple by stable reader ID prevents a coordinated relabel (for
# example swapping two father memories while leaving their choice indices in
# place) from preserving set-level coverage while changing branch meaning.
EXPECTED_STORY_INPUTS_BY_READER = {
    reader_id: tuple(value)
    for reader_id, value in _FROZEN_AUDITED_MAPS["story_inputs"].items()
}

AUDITED_LEDGER_SEMANTIC_SHA256 = '846325622d69a094e60c26310e3e1f4cf4c41b30212e168624b0b5e35c42bb94'
EXPECTED_AUDITED_SOURCE_FILE_SHA256 = {
    "systems/DemoCoreLoopV2.gd":
        "71998e70a0b70fc468986426b15b1469a93540765f2645003fb904bfcbeb5b6e",
    "autoloads/GameState.gd":
        "7e7bba4288bcfa75776df06647013aba0072c06ae21cf12e7c33f99dec57b261",
    "autoloads/DataRegistry.gd":
        "ab29468bccf2aa1151a5f4ceabbef77f1dd99e59c6125ed5d4b49872495899d1",
    "autoloads/EventManager.gd":
        "ca2ae4d3710a746f40f311ede93e9b37015b180df5820e95dadd9c8917b66365",
    "autoloads/MetaProgression.gd":
        "42445144bc107a963f54011460effeee5a2bc89204aac2fb44cecbc87378b2ca",
    "autoloads/SaveManager.gd":
        "6bfdb3850dcc3a5541a65ffdcf3cecada3c2fbc7d55b872f9ef41253e94bff71",
    "systems/BuildFlavor.gd":
        "6264de1c468d5553b73a37d3ea8c5ceb936f6852db7519701f37a2c8bf8aa633",
    "scenes/StoryMode.gd":
        "0a2835bec1047defa10c223368d08be62b6555bd0fd68d05054aacefb1449721",
    "scenes/StoryMode.tscn":
        "b7688a883323a196e74271c1e76f1d88c91310b3fe1a287cb051b33dd2fb76ca",
    "scenes/MainGame.gd":
        "6082a7783dae12d97d83bba032b73759c71713fa02d979d786883c6a108bc524",
    "scenes/MainGame.tscn":
        "71a9590d43c755fa6b409ee0eb0f1950c6aba4517c64192b83038d22a45d9979",
    "scenes/SeoulCycleBoard.gd":
        "c50d8b47df9ee16b7ae92f290a6bdee37c69e564fc18425a4434da3dc24ce348",
    "scenes/CommitmentTask.gd":
        "bae7b92139eaf8d4e112b870eb11dfb1fefa0a35d1d4f37a7bfa9df7e665af8b",
    "scenes/JobHuntMiniGame.gd":
        "3713028b1dc77aa773e23e69fe3756b7700cdbdf8a5847db780ddd7aa1e7a85e",
    "scenes/ArubaGame.gd":
        "97592dfae82323438a8b2d9843dd4c1599f8ff2eb2ace93a6ab35460d153e656",
    "content/meta/demo_core_loop_v2.json":
        "c97353bcf4649b93665ed2fba0edd35355c3d4bb117babd767d2fff7345fef1f",
    "content/meta/story_rules.json":
        "16d8023c519a2698e60201b2549d6d36126b88749603e1655cbcbdd12beb345c",
    "content/jobs.json":
        "d1a3ed8ba3f2839954d0b15266bff4f7a0d1317d78c503bd2422aa87b7210f84",
    "content/events/arc_events.json":
        "2aa354cd23d03ffba1d051cfe9a3a87c566034944fcb339537996c0dfd27c6b0",
    "content/events/core_loop_v2_events.json":
        "ba614cdb37c96d8313180764397b730727eefc9a45ef3a9bf65836883991adc8",
    "content/events/arc_daeun.json":
        "ecba76211ff1b803a44eba429751173e6be65af4ee9472d8ecd79385a51a7e99",
    "content/events/arc_midgame.json":
        "beb6251800d9105b332eb6e8ab102820f75b3e9d7f68547c046b8017f72d188a",
    "content/events/scenario_cafe.json":
        "748fa21586b928419a7e7cf336b7c737ba3f09ecfdddafdbb38bff1698ebbe85",
    "docs/CORE_LOOP_V2.md":
        "ebe76c9029bdbc0f6a678674dde89d99ab04d04c05f8c463c52379fcc6240c42",
    "docs/CHOICE_CONSEQUENCE_SYSTEM.md":
        "9828896ce8f447c81a0fb9ad949a1ef204d26f4d49072ab2962941d84d7becd5",
}
EXPECTED_PROJECT_AUTOLOAD_BINDINGS = {
    "GameState": "autoloads/GameState.gd",
    "DataRegistry": "autoloads/DataRegistry.gd",
    "EventManager": "autoloads/EventManager.gd",
    "MetaProgression": "autoloads/MetaProgression.gd",
    "SaveManager": "autoloads/SaveManager.gd",
}
EXPECTED_RUNTIME_PROOF_BINDING_DIGESTS = _FROZEN_AUDITED_MAPS["proof_bindings"]
EXPLICIT_TOP_LEVEL_EVIDENCE_PROOF_IDS = {
    'proof:compatibility:m3_inventory_legacy_outcome',
    'proof:debt:dead_card_terminal',
    'proof:debt:display_only_forgone',
    'proof:debt:layer_collision_runtime',
    'proof:debt:layer_collision_story',
    'proof:debt:orphan_ncs_receipt',
    'proof:debt:orphan_resume_polished',
    'proof:runtime:completion_snapshot',
}
COMPLETE_STALE_PROOF_IDS = {
    "proof:runtime:completion_snapshot",
    "proof:contract:months_stop_at_m06",
    "proof:runtime:turn_limit_24",
    "proof:runtime:w24_completion_cta",
    "proof:canon:w25_w48_gap",
}
NORMALIZE_SAVE_PROOF_PREFIX_ASSERTION = (
    "_normalized_state preserves month_summaries and the W1-W24 receipt maps, "
    "then calls normalize_seoul_cycle_state for the saved seoul_cycle_v1 "
    "payload; ")
NORMALIZE_SAVE_PROOF_COVERAGE_SUFFIX = (
    "full W1-W48 gameplay remains coverage-blocked.")
NORMALIZE_SAVE_PROOF_COMPLETE_SUFFIX = (
    "the Python-only complete fixture supplies audited W25-W48 contracts.")
SAVE_ROUNDTRIP_PROOF_POINTERS = {
    "proof:runtime:save_roundtrip_prefix":
        "autoloads/SaveManager.gd::save_game",
    "proof:runtime:save_payload_write":
        "autoloads/SaveManager.gd::_write_save_payload",
    "proof:runtime:save_payload_read":
        "autoloads/SaveManager.gd::_read_save_candidate",
    "proof:runtime:save_roundtrip_load":
        "autoloads/SaveManager.gd::load_game",
    "proof:runtime:serialize_core_loop_v2_state":
        "autoloads/GameState.gd::serialize",
    "proof:runtime:load_core_loop_v2_state":
        "autoloads/GameState.gd::load_from_dict",
    "proof:runtime:normalize_core_loop_v2_state":
        "systems/DemoCoreLoopV2.gd::_normalized_state",
    "proof:runtime:save_roundtrip_cycle":
        "systems/DemoCoreLoopV2.gd::normalize_seoul_cycle_state",
}
REPLAY_PERSISTENCE_PROOF_POINTERS = {
    "scenes/StoryMode.gd::_capture_first_bill_replay_snapshot",
    "autoloads/MetaProgression.gd::record_scene_replay_snapshot",
    "autoloads/MetaProgression.gd::get_scene_replay_snapshot",
    "autoloads/MetaProgression.gd::_validated_scene_replay_snapshot",
    "autoloads/MetaProgression.gd::save_meta",
    "autoloads/MetaProgression.gd::meta_save_path",
    "systems/BuildFlavor.gd::meta_path",
}
W48_COMPLETION_PROOF_POINTERS = {
    "proof:runtime:w48_completed_week_dispatch":
        "scenes/MainGame.gd::_core_loop_v2_advance_completed_week",
    "proof:runtime:w48_final_boundary_order":
        "scenes/MainGame.gd::_core_loop_v2_finalize_w48_boundary",
    "proof:runtime:w48_december_settlement_order":
        "scenes/MainGame.gd::_core_loop_v2_run_december_settlement_without_rollover",
    "proof:runtime:w48_world_event_resolution_order":
        "scenes/MainGame.gd::_core_loop_v2_resolve_december_world_events_without_rollover",
    "proof:runtime:w48_post_boss_dispatch":
        "scenes/MainGame.gd::_core_loop_v2_resume_chapter1_close",
    "proof:runtime:w48_post_boss_order":
        "scenes/MainGame.gd::_core_loop_v2_finalize_chapter1_after_boss",
    "proof:runtime:w48_completion_cta_surface":
        "scenes/MainGame.gd::_show_chapter1_completion",
    "proof:runtime:w48_chapter2_cta_order":
        "scenes/MainGame.gd::_core_loop_v2_start_chapter2",
}
EXPECTED_INVOCATION_CONTRACT_DIGESTS = _FROZEN_AUDITED_MAPS["invocations"]

# Frozen source-topology trust roots for milestone execution.  The stage
# records lock the exact source predicate/predecessor/invocation contract;
# the scenario sets lock which stages can actually coexist on one execution
# path.  Keeping the two contracts separate is intentional: a union of all
# DAG ancestors is not a real path and can otherwise launder a fresh-run
# producer into a re-entry consumer (or a fatal First Bill result into the
# survivor-only ledger/Hyunsu continuation).
#
# These maps are regenerated only after the coordinated ledger candidate is
# stable.  An empty map is tolerated while the owner is constructing that
# candidate; the production snapshot populates both maps before REVIEW LOCK.
EXPECTED_EXECUTION_STAGE_CONTRACT_DIGESTS = _FROZEN_AUDITED_MAPS["stages"]
EXPECTED_EXECUTION_STAGE_SCENARIOS_BY_WEEK = {
    int(week): [tuple(stage_ids) for stage_ids in scenarios]
    for week, scenarios in _FROZEN_AUDITED_MAPS["scenarios"].items()
}
EXPECTED_INVOCATION_PRODUCER_DIGESTS = _FROZEN_AUDITED_MAPS["producers"]
EXPECTED_CO_PRESENCE_PROOF_POINTERS = _FROZEN_AUDITED_MAPS["co_presence_pointers"]

W24_COMPLETION_APPLICATION_READER_ID = (
    "reader:milestone:w24:completion_application_choice")
W24_COMPLETION_APPLICATION_FACTS = [
    "state:completion_application_required:demo_collision",
    "receipt:application_transition:demo_collision:any_current_turn",
]
W24_COMPLETION_APPLICATION_DEBT_PROOF_ID = (
    "proof:debt:w24_completion_application_choice")

EXPECTED_EXCLUSIVE_GROUPS = {
    group_id: (value[0], value[1])
    for group_id, value in _FROZEN_AUDITED_MAPS["exclusive"].items()
}
EXPECTED_EXCLUSIVE_PROOF_POINTERS = _FROZEN_AUDITED_MAPS["exclusive_pointers"]

EXPECTED_CO_PRESENCE_GROUPS = {
    int(week): groups
    for week, groups in _FROZEN_AUDITED_MAPS["co_presence"].items()
}

EXPECTED_BUILD_FACTS_BY_CHAIN = {
    "m1_resume": ["receipt:allocation:m1_resume", "fact:resume_polished",
                  "receipt:action:m1_youth_center_resume_clinic"],
    "m1_convenience": ["receipt:allocation:m1_convenience",
                       "receipt:trigger:m1_convenience_trial_shift",
                       "receipt:action:m1_convenience_trial_shift"],
    "m1_father": ["receipt:allocation:m1_father",
                  "receipt:relationship:father_first_call"],
    "m1_recovery": ["receipt:allocation:m1_recovery"],
    "m2_advancement": ["receipt:allocation:m2_advancement",
                       "receipt:application:seorin_contract_2026q1:submitted",
                       "receipt:action:m2_seorin_application"],
    "m2_livelihood": ["receipt:allocation:m2_livelihood",
                      "receipt:trigger:m2_rain_delivery_shift",
                      "receipt:action:m2_rain_delivery_shift"],
    "m2_people": ["receipt:allocation:m2_people", "receipt:trigger:m2_people"],
    "m2_self": ["receipt:allocation:m2_self",
                "receipt:trigger:m2_sleep_debt_sunday",
                "receipt:action:m2_sleep_debt_sunday"],
    "m3_advancement": ["receipt:allocation:m3_advancement",
                       "receipt:application:hanbit_ops_2026q1:submitted",
                       "receipt:action:m3_hanbit_application"],
    "m3_livelihood": ["receipt:allocation:m3_livelihood",
                      "receipt:action:m3_inventory_shift"],
    "m3_people": ["receipt:allocation:m3_people", "receipt:trigger:m3_people"],
    "m3_self": ["receipt:allocation:m3_self", "receipt:action:m3_room_ledger"],
    "m4_advancement": ["receipt:allocation:m4_advancement",
                       "receipt:application:hanbit_ops_2026q1:interviewed",
                       "receipt:action:m4_dodam_application",
                       "receipt:application:dodam_customer_ops_2026q2:submitted",
                       "receipt:action:m4_certificate_session"],
    "m4_livelihood": ["receipt:allocation:m4_livelihood",
                      "receipt:action:m4_logistics_shift"],
    "m4_people": ["receipt:allocation:m4_people", "receipt:trigger:m4_people"],
    "m4_self": ["receipt:allocation:m4_self",
                "receipt:action:m4_housing_welfare_consultation"],
    "m5_advancement": ["receipt:allocation:m5_advancement",
                       "receipt:application:city_facility_ops_2026h1:submitted",
                       "receipt:action:m5_city_service_application"],
    "m5_livelihood": ["receipt:allocation:m5_livelihood",
                      "receipt:action:m5_weekend_move_shift"],
    "m5_people": ["receipt:allocation:m5_people", "receipt:trigger:m5_people"],
    "m5_self": ["receipt:allocation:m5_self",
                "receipt:action:m5_last_empty_sunday"],
    "m6_advancement": ["receipt:allocation:m6_advancement",
                       "receipt:action:m6_public_recruitment"],
    "m6_livelihood": ["receipt:allocation:m6_livelihood",
                      "receipt:action:m6_holiday_night_shift"],
    "m6_people": ["receipt:allocation:m6_people", "receipt:trigger:m6_people"],
    "m6_self": ["receipt:allocation:m6_self", "receipt:action:m6_no_plans_day"],
}
def _is_int(value: Any) -> bool:
    return isinstance(value, int) and not isinstance(value, bool)


def _string_list(value: Any, where: str, errors: list[str], *,
                 nonempty: bool = False) -> list[str]:
    if not isinstance(value, list) or any(not isinstance(v, str) or not v for v in value):
        errors.append(f"{where}: expected a list of non-empty strings")
        return []
    if nonempty and not value:
        errors.append(f"{where}: must not be empty")
    if len(value) != len(set(value)):
        errors.append(f"{where}: duplicate IDs")
    return value


def _exact_fields(value: Any, expected: set[str], where: str,
                  errors: list[str]) -> dict[str, Any]:
    if not isinstance(value, dict):
        errors.append(f"{where}: expected object")
        return {}
    actual = set(value)
    if actual != expected:
        missing = sorted(expected - actual)
        extra = sorted(actual - expected)
        errors.append(f"{where}: schema fields missing={missing} extra={extra}")
    return value


def _validate_activation_roles(
        variant: dict[str, Any], where: str,
        errors: list[str]) -> dict[str, list[str]]:
    """Validate the exact five-way input-role partition for a producer.

    Producer activations are reads just as reader contracts are reads.  Making
    the role partition mandatory prevents a prior memory or decision from
    being hidden in an output producer and thereby disappearing from the
    milestone fan-in census.
    """
    roles = _exact_fields(
        variant.get("activation_roles"), ACTIVATION_ROLE_FIELDS,
        f"{where}.activation_roles", errors)
    normalized: dict[str, list[str]] = {}
    flattened: list[str] = []
    for role in (
            "history_memory_ids", "material_state_ids",
            "scene_handoff_fact_ids", "story_decision_ids",
            "scene_handoff_decision_ids"):
        values = _string_list(
            roles.get(role), f"{where}.activation_roles.{role}", errors)
        normalized[role] = values
        flattened.extend(values)
    activation_ids = variant.get("activation_ids", [])
    if isinstance(activation_ids, list):
        if len(flattened) != len(set(flattened)):
            errors.append(
                f"{where}.activation_roles: role arrays must be disjoint")
        if set(flattened) != set(activation_ids):
            errors.append(
                f"{where}.activation_roles: must exactly partition activation_ids")
    return normalized


def _required_optional_fields(value: Any, required: set[str], optional: set[str],
                              where: str, errors: list[str]) -> dict[str, Any]:
    if not isinstance(value, dict):
        errors.append(f"{where}: expected object")
        return {}
    actual = set(value)
    missing = sorted(required - actual)
    extra = sorted(actual - required - optional)
    if missing or extra:
        errors.append(f"{where}: schema fields missing={missing} extra={extra}")
    return value


def _range(value: Any, where: str, errors: list[str]) -> list[int]:
    if (not isinstance(value, list) or len(value) != 2
            or any(not _is_int(v) for v in value) or value[0] > value[1]):
        errors.append(f"{where}: expected ascending [first,last] integer range")
        return []
    return value


def _registry_ids(ledger: dict[str, Any], name: str,
                  errors: list[str]) -> set[str]:
    rows = ledger.get(name)
    if not isinstance(rows, list):
        errors.append(f"{name}: expected array")
        return set()
    preferred = REGISTRY_ID_FIELDS[name]
    result: set[str] = set()
    for index, item in enumerate(rows):
        if not isinstance(item, dict):
            errors.append(f"{name}[{index}]: expected object")
            continue
        id_field = preferred
        if id_field not in item:
            candidates = [key for key in item if key == "id" or key.endswith("_id")]
            if len(candidates) == 1:
                id_field = candidates[0]
            else:
                errors.append(f"{name}[{index}]: missing unambiguous {preferred}")
                continue
        stable_id = item.get(id_field)
        if not isinstance(stable_id, str) or not stable_id:
            errors.append(f"{name}[{index}].{id_field}: expected non-empty string")
        elif stable_id in result:
            errors.append(f"{name}: duplicate registry ID {stable_id}")
        else:
            result.add(stable_id)
    return result


def _resolve_json_pointer(document: Any, pointer: str) -> bool:
    current = document
    if pointer == "":
        return True
    if not pointer.startswith("/"):
        return False
    for encoded in pointer[1:].split("/"):
        token = encoded.replace("~1", "/").replace("~0", "~")
        if isinstance(current, dict) and token in current:
            current = current[token]
        elif isinstance(current, list) and token.isdigit() and int(token) < len(current):
            current = current[int(token)]
        else:
            return False
    return True


def _source_json_document(path: Path, cache: dict[Path, Any]) -> Any:
    """Load source JSON into one top-level validation's local snapshot."""
    if path in cache:
        return cache[path]
    try:
        raw = path.read_bytes()
        try:
            source_name = str(path.relative_to(ROOT))
        except ValueError:
            source_name = str(path)
        document = _parse_exact_json(
            raw.decode("utf-8"), source_name)
    except (OSError, UnicodeDecodeError, ValueError):
        return None
    cache[path] = document
    return document


def _repo_source_path(relative_path: str) -> Path | None:
    """Resolve one fixed trust key without permitting absolute/parent escape."""
    candidate_key = Path(relative_path)
    if candidate_key.is_absolute() or ".." in candidate_key.parts:
        return None
    candidate = (ROOT / candidate_key).resolve()
    try:
        candidate.relative_to(ROOT.resolve())
    except ValueError:
        return None
    return candidate


def _json_pointer_value(pointer: str, cache: dict[Path, Any]) -> Any:
    if "#/" not in pointer:
        return None
    relative, fragment = pointer.split("#", 1)
    path = _repo_source_path(relative)
    if path is None:
        return None
    document = _source_json_document(path, cache)
    if document is None:
        return None
    current: Any = document
    for encoded in fragment[1:].split("/"):
        token = encoded.replace("~1", "/").replace("~0", "~")
        if isinstance(current, dict) and token in current:
            current = current[token]
        elif isinstance(current, list) and token.isdigit() and int(token) < len(current):
            current = current[int(token)]
        else:
            return None
    return current


def _contains_exact_string(value: Any, needle: str) -> bool:
    if isinstance(value, str):
        return value == needle
    if isinstance(value, dict):
        return any(_contains_exact_string(child, needle)
                   for child in value.values())
    if isinstance(value, list):
        return any(_contains_exact_string(child, needle) for child in value)
    return False


def _pointer_source_text(pointer: str, cache: dict[Path, Any]) -> str:
    if pointer in SOURCE_TEXT_CACHE:
        return SOURCE_TEXT_CACHE[pointer]
    if "#/" in pointer:
        value = _json_pointer_value(pointer, cache)
        result = json.dumps(value, ensure_ascii=False, sort_keys=True)
        SOURCE_TEXT_CACHE[pointer] = result
        return result
    if "::" not in pointer:
        return ""
    relative, symbol = pointer.split("::", 1)
    path = _repo_source_path(relative)
    if path is None:
        return ""
    try:
        text = path.read_text(encoding="utf-8")
    except OSError:
        return ""
    if path.suffix == ".gd":
        body = _gdscript_function_body(text, symbol)
        if body:
            SOURCE_TEXT_CACHE[pointer] = body
            return body
        const_match = re.search(
            rf"^const\s+{re.escape(symbol)}\b[^\n]*$", text, re.MULTILINE)
        result = const_match.group(0) if const_match else ""
        SOURCE_TEXT_CACHE[pointer] = result
        return result
    if path.suffix == ".md":
        lines = text.splitlines()
        heading_index = next((
            index for index, line in enumerate(lines)
            if re.match(
                rf"^(#{{1,6}})\s+{re.escape(symbol)}\s*$", line)), None)
        if heading_index is None:
            return ""
        heading_level = len(lines[heading_index].split(maxsplit=1)[0])
        end = len(lines)
        for index in range(heading_index + 1, len(lines)):
            match = re.match(r"^(#{1,6})\s+", lines[index])
            if match and len(match.group(1)) <= heading_level:
                end = index
                break
        result = "\n".join(lines[heading_index:end])
        SOURCE_TEXT_CACHE[pointer] = result
        return result
    return ""


def _normalized_proof_source(pointer: str, cache: dict[Path, Any]) -> str:
    """Return the exact referenced value/symbol/heading in stable form."""
    if "#/" in pointer:
        value = _json_pointer_value(pointer, cache)
        return json.dumps(
            value, ensure_ascii=False, sort_keys=True,
            separators=(",", ":"))
    source = _pointer_source_text(pointer, cache)
    return "\n".join(line.rstrip() for line in source.replace(
        "\r\n", "\n").replace("\r", "\n").split("\n")).strip()


def _source_digest(pointer: str, cache: dict[Path, Any]) -> str:
    return hashlib.sha256(
        _normalized_proof_source(pointer, cache).encode("utf-8")).hexdigest()


def _semantic_digest(value: Any) -> str:
    encoded = json.dumps(
        value, ensure_ascii=False, sort_keys=True,
        separators=(",", ":")).encode("utf-8")
    return hashlib.sha256(encoded).hexdigest()


def _file_digest(relative_path: str) -> str:
    path = _repo_source_path(relative_path)
    if path is None:
        return ""
    try:
        payload = path.read_bytes()
    except OSError:
        return ""
    return hashlib.sha256(payload).hexdigest()


def _proof_binding_digest(proof: dict[str, Any],
                          cache: dict[Path, Any]) -> str:
    binding = [
        proof.get("kind"), proof.get("pointer"), proof.get("assertion"),
        _source_digest(str(proof.get("pointer", "")), cache),
    ]
    return _semantic_digest(binding)


def _runtime_proof_references(value: Any) -> set[str]:
    refs: set[str] = set()
    if isinstance(value, dict):
        for key, child in value.items():
            if key == "runtime_proof_registry":
                continue
            if key == "runtime_proof_ids" and isinstance(child, list):
                refs.update(item for item in child if isinstance(item, str))
            else:
                refs.update(_runtime_proof_references(child))
    elif isinstance(value, list):
        for child in value:
            refs.update(_runtime_proof_references(child))
    return refs


def _project_autoload_binding_mismatches(project_text: str) -> list[str]:
    """Return singleton names that are missing, duplicated, or misbound."""
    autoload_sections = re.findall(
        r"(?ms)^\[autoload\]\s*$\n(.*?)(?=^\[|\Z)", project_text)
    autoload_text = autoload_sections[0] if len(autoload_sections) == 1 else ""
    mismatches: list[str] = []
    for singleton, relative_path in EXPECTED_PROJECT_AUTOLOAD_BINDINGS.items():
        actual_lines = re.findall(
            rf'^{re.escape(singleton)}=.*$', autoload_text, re.MULTILINE)
        expected_line = f'{singleton}="*res://{relative_path}"'
        if actual_lines != [expected_line]:
            mismatches.append(singleton)
    return mismatches


def _validate_save_roundtrip_source_contract(
        proof_records_by_id: dict[str, dict[str, Any]], errors: list[str],
        cache: dict[Path, Any]) -> None:
    """Prove the implemented Seoul-cycle state crosses the real disk boundary."""
    for proof_id, expected_pointer in SAVE_ROUNDTRIP_PROOF_POINTERS.items():
        proof = proof_records_by_id.get(proof_id, {})
        if (proof.get("kind") != "source_symbol"
                or proof.get("pointer") != expected_pointer):
            errors.append(
                f"SAVE_ROUNDTRIP: exact save proof chain mismatch {proof_id}")

    marker_contracts = {
        "autoloads/SaveManager.gd::save_game": (
            "var state = GameState.serialize()",
            '"state": state',
            "_write_save_payload(_slot_path(slot), payload, slot)",
        ),
        "autoloads/SaveManager.gd::_write_save_payload": (
            "JSON.stringify(payload",
            "serialized.to_utf8_buffer()",
            "_write_exact_bytes(temporary_path, serialized_bytes)",
            "FileAccess.get_file_as_bytes(temporary_path)",
            "DirAccess.rename_absolute(",
            "FileAccess.get_file_as_bytes(path)",
            "_is_expected_save_payload(final_bytes, slot)",
        ),
        "autoloads/SaveManager.gd::_read_save_candidate": (
            "FileAccess.get_file_as_bytes(path)",
            "json.parse(bytes.get_string_from_utf8())",
            'payload.get("state", payload)',
            "_save_state_field_diagnostic(",
            '"payload": payload',
            '"state": state_value',
        ),
        "autoloads/SaveManager.gd::load_game": (
            "_select_save_candidate(path, slot)",
            'selection.get("state", {})',
            "migrate_narrative_rhythm_state(",
            "GameState.load_from_dict(state)",
        ),
        "autoloads/GameState.gd::serialize": (
            '"core_loop_v2_state": core_loop_v2_state',
        ),
        "autoloads/GameState.gd::load_from_dict": (
            "var allowed = serialize().keys()",
            "set(key, value)",
            'data.has("core_loop_v2_state")',
            "typeof(core_loop_v2_state) != TYPE_DICTIONARY",
            "core_loop_v2_state = {}",
            "core_loop_v2_state = core_loop_v2_state.duplicate(true)",
        ),
        "systems/DemoCoreLoopV2.gd::_normalized_state": (
            "var state := raw_state.duplicate(true)",
            '"month_summaries"',
            "SEOUL_CYCLE_STATE_KEY",
            "normalize_seoul_cycle_state(",
        ),
        "systems/DemoCoreLoopV2.gd::normalize_seoul_cycle_state": (
            'raw_state.get("nodes"',
            'raw_state.get("allocation_receipts"',
            'raw_state.get("trigger_receipts"',
            'raw_state.get("expiry_receipts"',
            'raw_state.get("completed_turns"',
        ),
    }
    for pointer, markers in marker_contracts.items():
        body = _pointer_source_text(pointer, cache)
        if not all(marker in body for marker in markers):
            errors.append(
                f"SAVE_ROUNDTRIP: source handoff markers missing at {pointer}")

    # project.godot is intentionally not whole-file hashed: display, input, and
    # import settings are outside this causal ledger.  Its in-scope runtime
    # dependency is the exact singleton owner bindings below, each checked
    # as a full line and selected by both audit-scope entries.
    try:
        project_text = (ROOT / "project.godot").read_text(encoding="utf-8")
    except OSError:
        project_text = ""
    for singleton in _project_autoload_binding_mismatches(project_text):
        errors.append(
            f"SAVE_ROUNDTRIP: project autoload binding mismatch {singleton}")


def _validate_replay_persistence_source_contract(
        proof_records_by_id: dict[str, dict[str, Any]], errors: list[str],
        cache: dict[Path, Any]) -> None:
    """Lock replay capture through validation, durable write, and readback."""
    proof_pointers = {
        str(proof.get("pointer", ""))
        for proof in proof_records_by_id.values()
        if isinstance(proof, dict)}
    missing_pointers = REPLAY_PERSISTENCE_PROOF_POINTERS - proof_pointers
    if missing_pointers:
        errors.append(
            "REPLAY_SNAPSHOT: persistence proof chain missing pointers "
            f"{sorted(missing_pointers)}")

    marker_contracts = {
        "scenes/StoryMode.gd::_capture_first_bill_replay_snapshot": (
            "MetaProgression.record_scene_replay_snapshot(",
            "if not MetaProgression.record_scene_replay_snapshot(",
            "return false",
            "MetaProgression.record_scene_seen(",
        ),
        "autoloads/MetaProgression.gd::record_scene_replay_snapshot": (
            "_validated_scene_replay_snapshot(scene_id, snapshot)",
            "if validated.is_empty()",
            "snapshots[scene_id] = validated",
            'data["scene_replay_snapshots"] = snapshots',
            "save_meta()",
            "return true",
        ),
        "autoloads/MetaProgression.gd::get_scene_replay_snapshot": (
            'data.get("scene_replay_snapshots", {})',
            "snapshots.has(scene_id)",
            "_validated_scene_replay_snapshot(",
        ),
        "autoloads/MetaProgression.gd::_validated_scene_replay_snapshot": (
            "snapshot_scene_id != scene_id",
            "_valid_scene_replay_schema(schema)",
            "_is_json_safe(snapshot)",
            "SCENE_REPLAY_SNAPSHOT_MAX_BYTES",
            "JSON.stringify(snapshot)",
            "JSON.parse_string(encoded)",
        ),
        "autoloads/MetaProgression.gd::save_meta": (
            "FileAccess.open(meta_save_path(), FileAccess.WRITE)",
            "file.store_string(JSON.stringify(data",
        ),
        "autoloads/MetaProgression.gd::meta_save_path": (
            "return BUILD_FLAVOR.meta_path()",
        ),
        "systems/BuildFlavor.gd::meta_path": (
            "_meta_path_for(is_core_loop_v2_playtest_build())",
        ),
    }
    for pointer, markers in marker_contracts.items():
        body = _pointer_source_text(pointer, cache)
        if not all(marker in body for marker in markers):
            errors.append(
                f"REPLAY_SNAPSHOT: source handoff markers missing at {pointer}")


def _markers_are_ordered(body: str, markers: tuple[str, ...]) -> bool:
    cursor = -1
    for marker in markers:
        cursor = body.find(marker, cursor + 1)
        if cursor < 0:
            return False
    return True


def _validate_w48_completion_source_contract(
        milestone: dict[str, Any], chapter_end_reader: dict[str, Any],
        proof_records_by_id: dict[str, dict[str, Any]], errors: list[str],
        cache: dict[Path, Any]) -> None:
    """Lock the fatal/survivor boundary and explicit Chapter-2 handoff order."""
    required_ids = set(W48_COMPLETION_PROOF_POINTERS)
    declared_ids = set(milestone.get("runtime_proof_ids", [])) | set(
        chapter_end_reader.get("runtime_proof_ids", []))
    if not required_ids.issubset(declared_ids):
        errors.append(
            "complete gate: W48 close owners lack exact ordered source proofs")
    bodies: dict[str, str] = {}
    for proof_id, expected_pointer in W48_COMPLETION_PROOF_POINTERS.items():
        proof = proof_records_by_id.get(proof_id, {})
        if (proof.get("kind") != "source_symbol"
                or proof.get("pointer") != expected_pointer):
            errors.append(
                f"complete gate: W48 order proof mismatch {proof_id}")
        bodies[proof_id] = _pointer_source_text(expected_pointer, cache)

    dispatch_body = bodies.get(
        "proof:runtime:w48_completed_week_dispatch", "")
    if not _markers_are_ordered(dispatch_body, (
            "if GameState.turn == 48:",
            "_core_loop_v2_finalize_w48_boundary()")):
        errors.append(
            "complete gate: completed-week dispatcher does not call W48 boundary")

    boundary_body = bodies.get(
        "proof:runtime:w48_final_boundary_order", "")
    boundary_markers = (
        "DEMO_CORE_LOOP_V2.complete_seoul_cycle_turn(",
        "DEMO_CORE_LOOP_V2.resolve_seoul_cycle_month_terminals(",
        "DEMO_CORE_LOOP_V2.resolve_seoul_cycle_forgone_paths(",
        "_core_loop_v2_resolve_december_world_events_without_rollover(",
        "_core_loop_v2_run_december_settlement_without_rollover(",
        "GameState.check_game_over()",
        "if GameState.is_game_over:",
        "return",
        "DEMO_CORE_LOOP_V2.freeze_chapter1_end_snapshot(",
        '_go_story_mode(["arc_year1_close"])',
    )
    fatal_guard = re.search(
        r"if GameState\.is_game_over:\s*\n[ \t]+return(?:\s|$)",
        boundary_body) is not None
    if not _markers_are_ordered(boundary_body, boundary_markers):
        errors.append(
            "complete gate: W48 boundary order must settle/fail before snapshot and boss")
    if not fatal_guard:
        errors.append(
            "complete gate: W48 fatal branch must return before survivor snapshot")

    world_resolution_body = bodies.get(
        "proof:runtime:w48_world_event_resolution_order", "")
    world_resolution_markers = (
        "DEMO_CORE_LOOP_V2.resolve_seoul_cycle_month_world_events(",
        "DEMO_CORE_LOOP_V2.assert_no_pending_trigger_or_world(",
    )
    if (not _markers_are_ordered(
            world_resolution_body, world_resolution_markers)
            or "GameState.advance_calendar()" in world_resolution_body):
        errors.append(
            "complete gate: W48 world events must resolve and close before December settlement")

    settlement_body = bodies.get(
        "proof:runtime:w48_december_settlement_order", "")
    settlement_markers = (
        "job_system.process_monthly_job()",
        "relationship_system.process_monthly_relationships()",
        "inventory_system.process_monthly_items()",
        "GameState.apply_monthly_pressure()",
        "GameState.check_game_over()",
    )
    if (not _markers_are_ordered(settlement_body, settlement_markers)
            or "GameState.advance_calendar()" in settlement_body
            or "_run_month_end_transition(" in boundary_body):
        errors.append(
            "complete gate: December settlement owner must not advance to W49")

    post_dispatch_body = bodies.get(
        "proof:runtime:w48_post_boss_dispatch", "")
    post_dispatch_markers = (
        'GameState.flags.get("arc_year1_close_seen"',
        "GameState.get_year_scene_selection(1)",
        "_core_loop_v2_finalize_chapter1_after_boss()",
    )
    if not _markers_are_ordered(post_dispatch_body, post_dispatch_markers):
        errors.append(
            "complete gate: live post-boss return path does not call finalizer")

    post_boss_body = bodies.get(
        "proof:runtime:w48_post_boss_order", "")
    post_boss_markers = (
        'GameState.flags.get("arc_year1_close_seen"',
        "GameState.get_year_scene_candidates(",
        "GameState.get_year_scene_selection(1)",
        "if GameState.get_year_scene_selection(1).is_empty():",
        "return",
        'GameState.flags["chapter1_complete"] = true',
        "SaveManager.autosave(",
        "_show_chapter1_completion(",
    )
    selection_guard = re.search(
        r"if GameState\.get_year_scene_selection\(1\)\.is_empty\(\):"
        r"\s*\n[ \t]+return(?:\s|$)", post_boss_body) is not None
    if (not _markers_are_ordered(post_boss_body, post_boss_markers)
            or not selection_guard):
        errors.append(
            "complete gate: boss-seen/actual-scene curation must precede complete/save/surface")

    forbidden_pre_cta = ("GameState.advance_calendar()", '"chapter_card_34"')
    if any(marker in boundary_body or marker in settlement_body
           or marker in world_resolution_body or marker in post_dispatch_body
           or marker in post_boss_body
           for marker in forbidden_pre_cta):
        errors.append(
            "complete gate: W49 and chapter_card_34 belong only to Chapter-2 CTA")

    cta_surface_body = bodies.get(
        "proof:runtime:w48_completion_cta_surface", "")
    cta_surface_markers = (
        "_primary_cta_button(",
        ".pressed.connect(_core_loop_v2_start_chapter2)",
        'call_deferred("grab_focus")',
    )
    if not _markers_are_ordered(cta_surface_body, cta_surface_markers):
        errors.append(
            "complete gate: focusable completion CTA is not wired to Chapter 2")

    chapter2_body = bodies.get(
        "proof:runtime:w48_chapter2_cta_order", "")
    chapter2_markers = (
        'GameState.flags.get("chapter1_complete"',
        "GameState.advance_calendar()",
        '_go_story_mode(["chapter_card_34"])',
    )
    if not _markers_are_ordered(chapter2_body, chapter2_markers):
        errors.append(
            "complete gate: explicit Chapter-2 CTA must own W49 and chapter_card_34")


def _json_consumer_binds_fact(value: Any, fact_id: str) -> bool:
    """Bind typed prerequisite data to the ledger's stable fact vocabulary."""
    if not isinstance(value, (dict, list)):
        return False
    encoded = json.dumps(value, ensure_ascii=False, sort_keys=True)
    parts = fact_id.split(":")
    if fact_id.startswith("receipt:application:") and len(parts) >= 4:
        if len(parts) == 5 and parts[3] == "not_in":
            statuses = parts[4].split("|") if parts[4] else []
            return (f'"kind": "application_status_not_in"' in encoded
                    and f'"application_id": "{parts[2]}"' in encoded
                    and all(f'"{status}"' in encoded
                            for status in statuses))
        return (f'"application_id": "{parts[2]}"' in encoded
                and f'"status": "{parts[3]}"' in encoded)
    if fact_id.startswith("receipt:relationship:") and len(parts) == 3:
        return (f'"bundle_id": "{parts[2]}"' in encoded
                and '"kind": "completed_bundle"' in encoded)
    if fact_id.startswith("receipt:completed:") and len(parts) == 3:
        return (f'"kind": "completed_bundle"' in encoded
                and f'"bundle_id": "{parts[2]}"' in encoded)
    if fact_id.startswith("state:relationship:") and len(parts) >= 4:
        return (f'"character": "{parts[2]}"' in encoded
                and f'"stage": "{":".join(parts[3:])}"' in encoded
                and ('"kind": "relationship_at_least"' in encoded
                     or '"kind": "relationship_stage_is"' in encoded))
    if fact_id.startswith("memory:") and len(parts) >= 3:
        return (f'"kind": "relationship_memory"' in encoded
                and f'"character": "{parts[1]}"' in encoded
                and f'"memory": "{":".join(parts[2:])}"' in encoded)
    if fact_id.startswith("state:player_initiated:") and len(parts) == 3:
        return (f'"kind": "player_initiated"' in encoded
                and f'"character": "{parts[2]}"' in encoded)
    if fact_id.startswith("fact:routine_selected:") and len(parts) == 3:
        return (f'"kind": "routine_selected"' in encoded
                and f'"track": "{parts[2]}"' in encoded)
    return _contains_exact_string(value, fact_id)


def _prerequisite_predicate_fact(predicate: Any) -> str:
    """Translate the authored prerequisite DSL into stable ledger facts."""
    if not isinstance(predicate, dict):
        return ""
    kind = predicate.get("kind")
    if kind == "completed_bundle":
        bundle_id = predicate.get("bundle_id")
        return f"receipt:completed:{bundle_id}" \
            if isinstance(bundle_id, str) and bundle_id else ""
    if kind == "application_status":
        application_id = predicate.get("application_id")
        status = predicate.get("status")
        return f"receipt:application:{application_id}:{status}" \
            if all(isinstance(value, str) and value
                   for value in (application_id, status)) else ""
    if kind == "application_status_not_in":
        application_id = predicate.get("application_id")
        statuses = predicate.get("statuses")
        if (not isinstance(application_id, str) or not application_id
                or not isinstance(statuses, list) or not statuses
                or any(not isinstance(status, str) or not status
                       for status in statuses)):
            return ""
        return (
            f"receipt:application:{application_id}:not_in:"
            f"{'|'.join(statuses)}")
    if kind in {"relationship_at_least", "relationship_stage_is"}:
        character = predicate.get("character")
        stage = predicate.get("stage")
        return f"state:relationship:{character}:{stage}" \
            if all(isinstance(value, str) and value
                   for value in (character, stage)) else ""
    if kind == "relationship_memory":
        character = predicate.get("character")
        memory = predicate.get("memory")
        return f"memory:{character}:{memory}" \
            if all(isinstance(value, str) and value
                   for value in (character, memory)) else ""
    if kind == "player_initiated":
        character = predicate.get("character")
        return f"state:player_initiated:{character}" \
            if isinstance(character, str) and character else ""
    if kind == "routine_selected":
        track = predicate.get("track")
        return f"fact:routine_selected:{track}" \
            if isinstance(track, str) and track else ""
    return ""


def _prerequisite_fact_variants(
        pointer: str, cache: dict[Path, Any]) -> list[list[str]] | None:
    """Return every authored `all + one(any)` prerequisite combination."""
    value = _json_pointer_value(pointer, cache)
    if not isinstance(value, dict):
        return None
    raw_all = value.get("all", [])
    raw_any = value.get("any", [])
    if not isinstance(raw_all, list) or not isinstance(raw_any, list):
        return None
    common = [_prerequisite_predicate_fact(item) for item in raw_all]
    variants = [_prerequisite_predicate_fact(item) for item in raw_any]
    if any(not fact_id for fact_id in common + variants):
        return None
    if variants:
        return [[*common, fact_id] for fact_id in variants]
    return [common]


def _expected_scheduled_prerequisite_pointers(
        rows: list[dict[str, Any]], cache: dict[Path, Any]) -> set[str]:
    """Derive the exact prerequisite-bearing bundle set scheduled by 24 rows."""
    result: set[str] = set()
    for row in rows:
        if not isinstance(row, dict):
            continue
        for bundle_id in _row_trigger_bundles(row):
            pointer = (
                "content/meta/demo_core_loop_v2.json#/scene_bundles/"
                f"{bundle_id}/prerequisites")
            prerequisites = _json_pointer_value(pointer, cache)
            if (isinstance(prerequisites, dict)
                    and any(prerequisites.get(key)
                            for key in ("all", "any"))):
                result.add(pointer)
    return result


def _trusted_event_index(cache: dict[Path, Any]) -> dict[str, dict[str, Any]]:
    """Load the exact Story data dependency closure frozen by ORDER-100."""
    result: dict[str, dict[str, Any]] = {}
    for relative in TRUSTED_EVENT_PATHS:
        path = ROOT / relative
        try:
            if path not in cache:
                cache[path] = json.loads(path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError):
            continue
        values = cache[path]
        if not isinstance(values, list):
            continue
        for event in values:
            if (isinstance(event, dict)
                    and isinstance(event.get("id"), str)
                    and event["id"]):
                result[event["id"]] = event
    return result


def _bundle_story_choice_graph(
        bundle_id: str, cache: dict[Path, Any]
        ) -> list[tuple[str, dict[str, Any], bool]]:
    """Return the exact reachable owned Story graph in deterministic BFS order.

    Root events are unconditional bundle owners.  A choice follow-up is
    conditional and may be suppressed by the bundle contract; event-level
    follow-ups are not consumed by StoryMode's `_choice_follow_up_id` path.
    """
    bundle = _json_pointer_value(
        f"content/meta/demo_core_loop_v2.json#/scene_bundles/{bundle_id}",
        cache)
    if not isinstance(bundle, dict):
        return []
    roots = [
        root_id for root_id in bundle.get("existing_roots", [])
        if isinstance(root_id, str) and root_id]
    suppressed = {
        value for value in bundle.get("suppress_follow_up_events", [])
        if isinstance(value, str) and value}
    events = _trusted_event_index(cache)
    queue: list[tuple[str, bool]] = [(root_id, True) for root_id in roots]
    seen: set[str] = set()
    result: list[tuple[str, dict[str, Any], bool]] = []
    while queue:
        event_id, is_root = queue.pop(0)
        if event_id in seen:
            continue
        event = events.get(event_id)
        if not isinstance(event, dict):
            continue
        seen.add(event_id)
        result.append((event_id, event, is_root))
        choices = event.get("choices", [])
        if not isinstance(choices, list):
            continue
        for choice in choices:
            if not isinstance(choice, dict):
                continue
            follow_up = choice.get("follow_up_event")
            if (isinstance(follow_up, str) and follow_up
                    and follow_up not in suppressed and follow_up not in seen):
                queue.append((follow_up, False))
    return result


def _choice_is_expression(choice: Any) -> bool:
    return (isinstance(choice, dict)
            and str(choice.get("choice_kind", "")).strip().lower()
            == "expression")


def _row_story_choice_records(
        row: dict[str, Any], cache: dict[Path, Any]
        ) -> list[tuple[str, str, int, dict[str, Any], bool]]:
    """Flatten every non-expression choice owned by one row's Story graph."""
    result: list[tuple[str, str, int, dict[str, Any], bool]] = []
    for bundle_id in _row_trigger_bundles(row):
        for event_id, event, is_root in _bundle_story_choice_graph(
                bundle_id, cache):
            choices = event.get("choices", [])
            if not isinstance(choices, list):
                continue
            for choice_index, choice in enumerate(choices):
                if isinstance(choice, dict) and not _choice_is_expression(choice):
                    result.append(
                        (bundle_id, event_id, choice_index, choice, is_root))
    return result


def _outcome_matches_choice(
        outcome: Any, event_id: str, choice_index: int) -> bool:
    if not isinstance(outcome, dict) or outcome.get("event_id") != event_id:
        return False
    raw_choices = outcome.get("choices")
    if not isinstance(raw_choices, list) and "choice_index" in outcome:
        raw_choices = [outcome.get("choice_index")]
    return isinstance(raw_choices, list) and any(
        _is_int(value) and int(value) == choice_index for value in raw_choices)


def _append_unique(values: list[str], value: str) -> None:
    if value and value not in values:
        values.append(value)


def _story_choice_variant(
        row: dict[str, Any], bundle_id: str, event_id: str,
        choice_index: int, choice: dict[str, Any], cache: dict[Path, Any]
        ) -> dict[str, Any]:
    """Derive one Story-owned producer variant from authoritative data.

    This is intentionally a forward extraction.  The ledger cannot make an
    output real by naming it: every activation, durable fact, effect token and
    proof below is derived from the owned event choice and bundle outcome DSL.
    """
    chain_id = str(row.get("chain_id", ""))
    bundle = _json_pointer_value(
        f"content/meta/demo_core_loop_v2.json#/scene_bundles/{bundle_id}",
        cache)
    if not isinstance(bundle, dict):
        bundle = {}
    group_id = f"group:producer:{chain_id}:{bundle_id}:{event_id}"
    produced = [
        f"receipt:story_choice:{bundle_id}:{event_id}:{choice_index}",
        "state:events_seen:+1",
    ]
    effects = [f"effect:{event_id}:choice:{choice_index}:events_seen"]
    proofs = [
        "proof:runtime:story_choice_effect_application",
        "proof:runtime:generic_story_choice_receipt",
        "proof:runtime:story_choice_outcome_dispatch",
        f"proof:data:story_event:{event_id}",
    ]

    raw_effects = choice.get("effects", {})
    if isinstance(raw_effects, dict):
        for key in raw_effects:
            effects.append(
                f"effect:{event_id}:choice:{choice_index}:effects.{key}")
    for field in ("flags", "unflags"):
        raw_flags = choice.get(field, [])
        if isinstance(raw_flags, list):
            for raw_flag in raw_flags:
                if isinstance(raw_flag, str) and raw_flag:
                    _append_unique(produced, f"state:flag:{raw_flag}")
                    effects.append(
                        f"effect:{event_id}:choice:{choice_index}:"
                        f"{field}.{raw_flag}")
    cast_effects = choice.get("cast_effects", {})
    if isinstance(cast_effects, dict):
        for character, raw_cast in cast_effects.items():
            if not isinstance(character, str) or not isinstance(raw_cast, dict):
                continue
            for field in raw_cast:
                if field not in {"met", "affinity", "stage"}:
                    continue
                effects.append(
                    f"effect:{event_id}:choice:{choice_index}:"
                    f"cast_effects.{character}.{field}")
                if field == "met" and bool(raw_cast.get(field)):
                    _append_unique(produced, f"state:cast:{character}:met")
                elif field == "stage":
                    stage = raw_cast.get(field)
                    if isinstance(stage, str) and stage:
                        _append_unique(
                            produced, f"state:cast:{character}:stage:{stage}")
            raw_flags = raw_cast.get("flags", [])
            if isinstance(raw_flags, list):
                for raw_flag in raw_flags:
                    if not isinstance(raw_flag, str) or not raw_flag:
                        continue
                    _append_unique(
                        produced, f"state:cast:{character}:flag:{raw_flag}")
                    effects.append(
                        f"effect:{event_id}:choice:{choice_index}:"
                        f"cast_effects.{character}.flags.{raw_flag}")
    raw_items = choice.get("give_items", [])
    if isinstance(raw_items, list):
        for raw_item in raw_items:
            if isinstance(raw_item, str) and raw_item:
                _append_unique(produced, f"state:item:{raw_item}")
                effects.append(
                    f"effect:{event_id}:choice:{choice_index}:"
                    f"give_items.{raw_item}")

    # A generic choice can explicitly establish initiative even when it has no
    # relationship outcome.  None of the implemented weekly graphs currently
    # use this field, but the extractor remains source-complete.
    initiated = choice.get("v2_player_initiated_character")
    if isinstance(initiated, str) and initiated:
        _append_unique(produced, f"state:player_initiated:{initiated}")

    relationship_outcomes = bundle.get("relationship_outcomes", [])
    if isinstance(relationship_outcomes, list):
        for outcome_index, outcome in enumerate(relationship_outcomes):
            if not _outcome_matches_choice(outcome, event_id, choice_index):
                continue
            character = str(outcome.get("character", ""))
            target = str(outcome.get("to", outcome.get("stage", "")))
            memory = str(outcome.get("memory", ""))
            _append_unique(
                produced,
                f"receipt:relationship_history:{bundle_id}:{event_id}:"
                f"{choice_index}")
            _append_unique(
                produced,
                f"receipt:relationship_choice:{bundle_id}:{event_id}:"
                f"{choice_index}")
            if character and target:
                _append_unique(
                    produced, f"state:relationship:{character}:{target}")
            if character and memory:
                _append_unique(produced, f"memory:{character}:{memory}")
            # A shared-commitment producer is reachable only after initiative
            # was already durable.  All other authored player initiatives are
            # potential writes; the fresh Father route is separately scope-
            # locked against the legacy reciprocal rewrite.
            prerequisites = bundle.get("prerequisites", {})
            prerequisite_player = False
            if isinstance(prerequisites, dict):
                for raw_predicate in prerequisites.get("all", []):
                    if (isinstance(raw_predicate, dict)
                            and raw_predicate.get("kind") == "player_initiated"
                            and raw_predicate.get("character") == character):
                        prerequisite_player = True
            if (character and outcome.get("initiative") == "player"
                    and outcome.get("from") not in {
                        "player_reached_out", "shared_commitment"}
                    and not prerequisite_player
                    and not (character == "father"
                             and bundle_id != "father_first_call")):
                _append_unique(
                    produced, f"state:player_initiated:{character}")
            prefix = (
                f"effect:{bundle_id}:relationship_outcomes:"
                f"{outcome_index}")
            effects.extend([
                f"{prefix}:relationship_history",
                f"{prefix}:relationship_choice_receipt",
                f"{prefix}:from", f"{prefix}:to",
                f"{prefix}:initiative", f"{prefix}:memory",
            ])
            callbacks = outcome.get("supersedes_callbacks", [])
            if isinstance(callbacks, list):
                for raw_callback in callbacks:
                    if not isinstance(raw_callback, str) or not raw_callback:
                        continue
                    _append_unique(
                        produced,
                        f"state:legacy_callback_resolution:{raw_callback}")
                    effects.append(
                        f"{prefix}:supersedes_callbacks.{raw_callback}")
            proofs.extend([
                "proof:runtime:relationship_receipt",
                f"proof:data:relationship_outcomes:{bundle_id}",
            ])
            if bundle_id == "father_first_call":
                proofs.extend([
                    "proof:data:fresh_run_origin_application_sent",
                    "proof:scope:fresh_father_player_initiative",
                ])

    application_outcomes = bundle.get("application_outcomes", [])
    if isinstance(application_outcomes, list):
        for outcome_index, outcome in enumerate(application_outcomes):
            if not _outcome_matches_choice(outcome, event_id, choice_index):
                continue
            application_id = str(outcome.get("application_id", ""))
            target = str(outcome.get("to", ""))
            if application_id and target:
                _append_unique(
                    produced,
                    f"receipt:application:{application_id}:{target}")
                _append_unique(
                    produced,
                    f"receipt:application_transition:{bundle_id}:"
                    f"{event_id}:{choice_index}")
            prefix = (
                f"effect:{bundle_id}:application_outcomes:{outcome_index}")
            effects.extend([
                f"{prefix}:from", f"{prefix}:to",
                f"{prefix}:transition_receipt",
            ])
            proofs.extend([
                "proof:runtime:application_receipt",
                f"proof:data:application_outcomes:{bundle_id}",
                "proof:produce:application_transition:"
                f"{bundle_id}:{event_id}:{choice_index}",
            ])

    return {
        "variant_id": (
            f"variant:{chain_id}:{bundle_id}:{event_id}:"
            f"choice:{choice_index}"),
        "activation_ids": [
            f"bundle:{bundle_id}",
            f"story_choice:{event_id}:{choice_index}",
        ],
        "produced_fact_ids": produced,
        "effect_contract_ids": effects,
        "runtime_proof_ids": proofs,
        "selection_group_id": group_id,
    }


def _activation_roles_for_ids(
        activation_ids: list[str]) -> dict[str, list[str]]:
    """Classify source-derived activation tokens into the five fan-in roles."""
    result = {
        "material_state_ids": [],
        "scene_handoff_fact_ids": [],
        "story_decision_ids": [],
        "scene_handoff_decision_ids": [],
        "history_memory_ids": [],
    }
    material_prefixes = (
        "bundle:", "action_quality:", "activity_outcome:",
        "fact:routine_selected:", "runtime_result:", "shift_context:",
        "runtime:turn:", *MATERIAL_STATE_PREFIXES,
    )
    handoff_prefixes = (
        "state:demo_collision_context:",
        "receipt:deferred_callback:",
        "receipt:obligation:demo_collision",
    )
    for activation_id in activation_ids:
        if activation_id.startswith("story_choice:"):
            result["scene_handoff_decision_ids"].append(activation_id)
        elif activation_id.startswith(handoff_prefixes):
            result["scene_handoff_fact_ids"].append(activation_id)
        elif activation_id.startswith(material_prefixes):
            result["material_state_ids"].append(activation_id)
        else:
            result["history_memory_ids"].append(activation_id)
    return result


def _with_activation_roles(variant: dict[str, Any]) -> dict[str, Any]:
    result = dict(variant)
    activations = result.get("activation_ids", [])
    result["activation_roles"] = _activation_roles_for_ids(
        activations if isinstance(activations, list) else [])
    return result


def _activation_choice_domain(activation_id: str) -> tuple[str, str] | None:
    """Return an exact choice domain/value for mutually-exclusive tokens."""
    for prefix in ("story_choice:", "decision:"):
        if not activation_id.startswith(prefix):
            continue
        payload = activation_id[len(prefix):]
        event_id, separator, choice_index = payload.rpartition(":")
        if separator and event_id and choice_index:
            return event_id, choice_index
    return None


def _fanin_memory_axis(fact_id: str) -> str:
    """Return the independent historical-input axis counted by fan-in.

    A typed boolean predicate and the source field read that supplies it are
    one input, not two memories.  For example, W8 reads `lent_account` to
    choose a root and the clean variant records the exact false branch.  The
    polarity remains source-validated in the variant contract, while the
    narrative fan-in cap counts the underlying flag only once.
    """
    if fact_id.startswith("state:flag:"):
        for suffix in (":true", ":false"):
            if fact_id.endswith(suffix):
                return fact_id[:-len(suffix)]
    return fact_id


def _compatible_producer_selections(
        producer_groups_by_id: dict[str, dict[str, Any]],
        producer_variants_by_group: dict[str, list[dict[str, Any]]],
) -> list[tuple[dict[str, Any], ...]]:
    """Enumerate internally compatible conditional-producer selections.

    A naive product admits coordinated false paths: for example W24 could
    select the city-present axis but the city-absent candidate-set variant,
    or pair one First Bill choice with a sibling choice's application side
    effect.  We retain externally optional possibilities, while requiring
    all cross-group produced-fact dependencies and exact event-choice domains
    to agree.
    """
    group_options: list[list[dict[str, Any] | None]] = []
    for group_id, group in producer_groups_by_id.items():
        # `authored_blocked_by_coverage` suppresses downstream causal credit;
        # it does not erase the authored invocation or its activation reads.
        # Those variants still participate in path feasibility/fan-in.
        options: list[dict[str, Any] | None] = list(
            producer_variants_by_group.get(group_id, []))
        if group.get("selection_mode") == "at_most_one":
            options.append(None)
        group_options.append(options or [None])
    if not group_options:
        return [()]

    all_internal_outputs = {
        fact_id
        for variants in producer_variants_by_group.values()
        for variant in variants
        for fact_id in variant.get("produced_fact_ids", [])
        if isinstance(fact_id, str)}
    compatible: list[tuple[dict[str, Any], ...]] = []
    for raw_selection in itertools.product(*group_options):
        selection = tuple(
            variant for variant in raw_selection
            if isinstance(variant, dict))
        selected_outputs = {
            fact_id for variant in selection
            for fact_id in variant.get("produced_fact_ids", [])
            if isinstance(fact_id, str)}
        choice_values: dict[str, str] = {}
        valid = True
        for variant in selection:
            activations = variant.get("activation_ids", [])
            if not isinstance(activations, list):
                valid = False
                break
            internal_requirements = {
                activation_id for activation_id in activations
                if activation_id in all_internal_outputs}
            if not internal_requirements.issubset(selected_outputs):
                valid = False
                break
            for activation_id in activations:
                if not isinstance(activation_id, str):
                    continue
                domain_value = _activation_choice_domain(activation_id)
                if domain_value is None:
                    continue
                domain, value = domain_value
                previous = choice_values.setdefault(domain, value)
                if previous != value:
                    valid = False
                    break
            if not valid:
                break
        if valid:
            compatible.append(selection)
    return compatible or [()]


def _producer_selection_output_facts(
        selection: tuple[dict[str, Any], ...],
        producer_groups_by_id: dict[str, dict[str, Any]],
        ) -> set[str]:
    """Return the exact durable outputs for one producer selection.

    In particular, do not manufacture a same-scene W24 application handoff.
    The completion helper independently reads the persisted selected route and
    the generic current-turn application-transition registry; save/resume does
    not restore or validate an identity-correlated transition tuple.
    """
    return {
        fact_id for variant in selection
        if producer_groups_by_id.get(
            str(variant.get("selection_group_id")), {}).get(
                "causal_status") in {
                    "active", "terminal_no_current_reader"}
        for fact_id in variant.get("produced_fact_ids", [])
        if (isinstance(fact_id, str)
            and not fact_id.startswith("decision:")
            and not fact_id.startswith(
                SYNTHETIC_W24_FIRST_BILL_DECISION_HANDOFF_PREFIX))}


def _validate_producer_dependency_graph(
        *, producer_groups_by_id: dict[str, dict[str, Any]],
        producer_variants_by_group: dict[str, list[dict[str, Any]]],
        where: str, errors: list[str]) -> set[str]:
    """Validate same-invocation producer handoffs and return internal facts."""
    fact_owner_groups: dict[str, set[str]] = {}
    for group_id, variants in producer_variants_by_group.items():
        for variant in variants:
            for fact_id in variant.get("produced_fact_ids", []):
                if isinstance(fact_id, str):
                    fact_owner_groups.setdefault(fact_id, set()).add(group_id)
    dependencies: dict[str, set[str]] = {
        group_id: set() for group_id in producer_groups_by_id}
    for consumer_group_id, variants in producer_variants_by_group.items():
        for variant in variants:
            for activation_id in variant.get("activation_ids", []):
                if not isinstance(activation_id, str):
                    continue
                for owner_group_id in fact_owner_groups.get(
                        activation_id, set()):
                    if owner_group_id == consumer_group_id:
                        errors.append(
                            f"{where}: producer group {consumer_group_id} "
                            f"consumes its own output {activation_id}")
                    else:
                        dependencies.setdefault(
                            consumer_group_id, set()).add(owner_group_id)

    visited: set[str] = set()
    visiting: set[str] = set()

    def visit(group_id: str) -> None:
        if group_id in visited:
            return
        if group_id in visiting:
            errors.append(
                f"{where}: conditional producer dependency cycle at {group_id}")
            return
        visiting.add(group_id)
        for dependency_id in dependencies.get(group_id, set()):
            visit(dependency_id)
        visiting.discard(group_id)
        visited.add(group_id)

    for group_id in dependencies:
        visit(group_id)
    return set(fact_owner_groups)


def _expected_output_variants_and_groups(
        row: dict[str, Any], cache: dict[Path, Any]
        ) -> tuple[list[dict[str, Any]], list[dict[str, Any]]]:
    """Return exact producer variants and their authored exclusivity groups."""
    chain_id = str(row.get("chain_id", ""))
    variants: list[dict[str, Any]] = []
    groups: list[dict[str, Any]] = []
    seen_groups: set[str] = set()

    if chain_id == "m1_resume":
        group_id = (
            "group:producer:m1_resume:m1_youth_center_resume_clinic:"
            "resume_quality")
        groups.append({
            "selection_group_id": group_id,
            "selection_mode": "exactly_one",
        })
        for quality in range(4):
            facts = ["receipt:action:m1_youth_center_resume_clinic"]
            if quality >= 2:
                facts.append("fact:resume_polished")
            variants.append({
                "variant_id": (
                    "variant:m1_resume:m1_youth_center_resume_clinic:"
                    f"quality:{quality}"),
                "activation_ids": [
                    "bundle:m1_youth_center_resume_clinic",
                    f"action_quality:m1_youth_center_resume_clinic:{quality}",
                ],
                "produced_fact_ids": [
                    *facts, "state:tendency:career:+1"],
                "effect_contract_ids": [
                    f"effect:m1_resume:quality:{quality}",
                    "effect:m1_resume:stress_delta:runtime",
                    "effect:m1_resume:tendency:career:+1",
                ],
                "runtime_proof_ids": [
                    "proof:runtime:resume_quality_outcome",
                    "proof:runtime:job_hunt_resume_stress_formula",
                    "proof:runtime:action_receipt",
                ],
                "selection_group_id": group_id,
            })

    for bundle_id, event_id, choice_index, choice, is_root in \
            _row_story_choice_records(row, cache):
        group_id = f"group:producer:{chain_id}:{bundle_id}:{event_id}"
        if group_id not in seen_groups:
            groups.append({
                "selection_group_id": group_id,
                "selection_mode": "exactly_one" if is_root else "at_most_one",
            })
            seen_groups.add(group_id)
        variants.append(_story_choice_variant(
            row, bundle_id, event_id, choice_index, choice, cache))

    execution_contracts = _row_execution_family_contracts(row, cache)
    for bundle_id, family in execution_contracts:
        if family == "aruba":
            group_id = (
                f"group:producer:{chain_id}:{bundle_id}:"
                "aruba_runtime_result")
            groups.append({
                "selection_group_id": group_id,
                "selection_mode": "exactly_one",
            })
            if bundle_id == "m1_convenience_trial_shift":
                variants.append({
                    "variant_id": (
                        f"variant:{chain_id}:{bundle_id}:"
                        "aruba_runtime_result"),
                    "activation_ids": [
                        f"bundle:{bundle_id}",
                        "runtime_result:aruba:convenience:10_interactions",
                    ],
                    "produced_fact_ids": [f"receipt:action:{bundle_id}"],
                    "effect_contract_ids": [
                        f"effect:{chain_id}:aruba:earned:"
                        "base_pay_plus_10_interaction_bonuses",
                        f"effect:{chain_id}:aruba:mental:"
                        "negative_10_interaction_stress_sum",
                        f"effect:{chain_id}:aruba:health:-3",
                    ],
                    "runtime_proof_ids": [
                        "proof:runtime:aruba_side_shift_result",
                        "proof:runtime:aruba_result_emit",
                        "proof:runtime:aruba_convenience_formula",
                    ],
                    "selection_group_id": group_id,
                })
            elif bundle_id == "m2_rain_delivery_shift":
                variants.append({
                    "variant_id": (
                        f"variant:{chain_id}:{bundle_id}:"
                        "aruba_runtime_result"),
                    "activation_ids": [
                        f"bundle:{bundle_id}",
                        "runtime_result:aruba:delivery:selected_nonempty",
                        "shift_context:weather:rain",
                        "shift_context:surge_pay:true",
                    ],
                    "produced_fact_ids": [f"receipt:action:{bundle_id}"],
                    "effect_contract_ids": [
                        f"effect:{chain_id}:aruba:money:"
                        "base_pay_plus_tips_plus_route_bonus_plus_rain_surge",
                        f"effect:{chain_id}:aruba:mental:"
                        "-max(delivery_count-2,0)",
                        f"effect:{chain_id}:aruba:health:"
                        "-3-delivery_count-1",
                        f"effect:{chain_id}:aruba:route_minutes:1..120",
                    ],
                    "runtime_proof_ids": [
                        "proof:runtime:aruba_side_shift_result",
                        "proof:runtime:aruba_result_emit",
                        "proof:runtime:aruba_rain_delivery_formula",
                        "proof:runtime:aruba_rain_context",
                    ],
                    "selection_group_id": group_id,
                })
        elif family == "recovery":
            bundle = _json_pointer_value(
                "content/meta/demo_core_loop_v2.json#/scene_bundles/"
                f"{bundle_id}", cache)
            config = bundle.get("action_config", {}) \
                if isinstance(bundle, dict) else {}
            normal = config.get("effects", {}) \
                if isinstance(config, dict) else {}
            diminished = config.get("recovery_routine_effects", {}) \
                if isinstance(config, dict) else {}
            if not isinstance(normal, dict) or not isinstance(diminished, dict):
                continue
            group_id = (
                f"group:producer:{chain_id}:{bundle_id}:recovery_effects")
            groups.append({
                "selection_group_id": group_id,
                "selection_mode": "exactly_one",
            })
            for outcome, routine_selected, effects, source_key in (
                    ("normal", False, normal, "effects"),
                    ("diminished", True, diminished,
                     "recovery_routine_effects")):
                effect_contracts: list[str] = []
                # Replacing the normal dictionary with the diminished one
                # makes omitted authored keys exact zeroes, not unknown values.
                for effect_key in normal:
                    raw_value = effects.get(effect_key, 0)
                    if not isinstance(raw_value, (int, float)) \
                            or isinstance(raw_value, bool):
                        continue
                    signed_value = f"{raw_value:+g}"
                    effect_contracts.append(
                        f"effect:{bundle_id}:action_config.{source_key}."
                        f"{effect_key}:{signed_value}")
                effect_contracts.append(
                    f"effect:{bundle_id}:diminished_by_recovery_routine:"
                    f"{str(routine_selected).lower()}")
                variants.append({
                    "variant_id": (
                        f"variant:{chain_id}:{bundle_id}:"
                        f"recovery_effects:{outcome}"),
                    "activation_ids": [
                        f"bundle:{bundle_id}",
                        "fact:routine_selected:recovery:"
                        f"{str(routine_selected).lower()}",
                    ],
                    "produced_fact_ids": [f"receipt:action:{bundle_id}"],
                    "effect_contract_ids": effect_contracts,
                    "runtime_proof_ids": [
                        "proof:runtime:recovery_routine_effect_selection",
                        f"proof:data:recovery_action_config:{bundle_id}",
                        "proof:runtime:action_receipt",
                    ],
                    "selection_group_id": group_id,
                })

    if chain_id == "m6_people":
        future = _json_pointer_value(
            "content/meta/demo_core_loop_v2.json#/future_story_contracts/"
            "hyunsu_exam_2026", cache)
        if isinstance(future, dict):
            group_id = "group:producer:m6_people:hyunsu_exam_2026_source"
            groups.append({
                "selection_group_id": group_id,
                "selection_mode": "at_most_one",
            })
            memories = future.get("required_memories", [])
            outcomes = _json_pointer_value(
                "content/meta/demo_core_loop_v2.json#/scene_bundles/"
                "hyunsu_exam_eve/relationship_outcomes", cache)
            choice_by_memory: dict[str, int] = {}
            if isinstance(outcomes, list):
                for outcome in outcomes:
                    if not isinstance(outcome, dict):
                        continue
                    memory = outcome.get("memory")
                    choices = outcome.get("choices", [])
                    if (isinstance(memory, str) and memory
                            and isinstance(choices, list) and choices
                            and _is_int(choices[0])):
                        choice_by_memory[memory] = int(choices[0])
            for memory in memories if isinstance(memories, list) else []:
                if not isinstance(memory, str) or memory not in choice_by_memory:
                    continue
                choice_index = choice_by_memory[memory]
                source_fact = (
                    "receipt:future_story:hyunsu_exam_2026:source:"
                    f"relationship_memory:{memory}")
                effect_prefix = "effect:hyunsu_exam_2026"
                variants.append({
                    "variant_id": (
                        "variant:m6_people:hyunsu_exam_2026:source:"
                        f"relationship_memory:{memory}"),
                    "activation_ids": [
                        "bundle:hyunsu_exam_eve",
                        "receipt:relationship_choice:hyunsu_exam_eve:"
                        f"v2_hyunsu_exam_eve:{choice_index}",
                        f"memory:hyunsu:{memory}",
                    ],
                    "produced_fact_ids": [
                        "receipt:future_story:hyunsu_exam_2026", source_fact],
                    "effect_contract_ids": [
                        f"{effect_prefix}:receipt_id:hyunsu_exam_2026",
                        f"{effect_prefix}:character:hyunsu",
                        f"{effect_prefix}:producer_bundle:hyunsu_exam_eve",
                        f"{effect_prefix}:source_kind:relationship_memory",
                        f"{effect_prefix}:source_memory:{memory}",
                        f"{effect_prefix}:outcome:{future.get('canonical_outcome')}",
                        f"{effect_prefix}:recorded_turn:runtime",
                        f"{effect_prefix}:exam_turn:{future.get('exam_week')}",
                        f"{effect_prefix}:available_turn:"
                        f"{future.get('result_available_week')}",
                        f"{effect_prefix}:result_event:{future.get('result_event')}",
                    ],
                    "runtime_proof_ids": [
                        "proof:runtime:hyunsu_future_story_receipt",
                        "proof:data:hyunsu_future_story_contract",
                        "proof:produce:hyunsu_future_story_"
                        + memory.removeprefix("hyunsu_exam_eve_"),
                    ],
                    "selection_group_id": group_id,
                })
    if chain_id == "m3_livelihood":
        group_id = (
            "group:producer:m3_livelihood:m3_inventory_shift:"
            "activity_task_outcome")
        groups.append({
            "selection_group_id": group_id,
            "selection_mode": "exactly_one",
        })
        config = _json_pointer_value(
            "content/meta/demo_core_loop_v2.json#/scene_bundles/"
            "m3_inventory_shift/action_config", cache)
        authored: list[tuple[str, str]] = []
        if isinstance(config, dict):
            outcomes = config.get("outcomes", {})
            if isinstance(outcomes, dict):
                authored.extend((str(key), f"outcomes.{key}")
                                for key in outcomes)
            overreach = config.get("overreach", {})
            if isinstance(overreach, dict):
                outcome_id = str(overreach.get("outcome_id", ""))
                if outcome_id:
                    authored.append((outcome_id, "overreach"))
        for outcome_id, source_path in authored:
            source_value = config
            for token in source_path.split("."):
                source_value = source_value.get(token, {}) \
                    if isinstance(source_value, dict) else {}
            raw_effects = source_value.get("effects", {}) \
                if isinstance(source_value, dict) else {}
            effect_ids = [
                "effect:m3_inventory_shift:action_config:"
                f"{source_path}.effects.{key}"
                for key in raw_effects] if isinstance(raw_effects, dict) else []
            variants.append({
                "variant_id": (
                    "variant:m3_livelihood:m3_inventory_shift:"
                    f"activity_outcome:{outcome_id}"),
                "activation_ids": [
                    "bundle:m3_inventory_shift",
                    f"activity_outcome:m3_inventory_shift:{outcome_id}",
                ],
                "produced_fact_ids": [
                    f"activity_task_outcome:m3_inventory_shift:{outcome_id}",
                    "receipt:action:m3_inventory_shift",
                ],
                "effect_contract_ids": effect_ids,
                "runtime_proof_ids": [
                    "proof:data:m3_inventory_activity_task",
                    "proof:runtime:activity_task_outcome_resolution",
                    "proof:runtime:activity_receipt",
                    "proof:runtime:action_receipt",
                ],
                "selection_group_id": group_id,
            })
    return [_with_activation_roles(variant) for variant in variants], groups


def _expected_invocation_conditional_producers(
        invocation_id: str, cache: dict[Path, Any]) -> list[dict[str, Any]]:
    """Return source-owned milestone outputs that are not row completions."""
    if invocation_id != "reader:milestone:w24:prepare_roots":
        return []
    future = _json_pointer_value(
        "content/meta/demo_core_loop_v2.json#/future_story_contracts/"
        "hyunsu_exam_2026", cache)
    if not isinstance(future, dict):
        return []
    unanswered = str(future.get("unanswered_source", ""))
    if not unanswered:
        return []
    effect_prefix = "effect:hyunsu_exam_2026"
    return [_with_activation_roles({
        "variant_id": (
            "variant:milestone:w24:prepare_roots:hyunsu_exam_2026:"
            f"source:declined:{unanswered}"),
        "activation_ids": [
            "receipt:completed:hyunsu_study_followup",
            "state:relationship:hyunsu:shared_commitment",
            "state:completed_bundle:hyunsu_exam_eve:false",
            "runtime:turn:24",
        ],
        "produced_fact_ids": [
            "receipt:future_story:hyunsu_exam_2026",
            "receipt:future_story:hyunsu_exam_2026:source:"
            f"declined:{unanswered}",
        ],
        "effect_contract_ids": [
            f"{effect_prefix}:receipt_id:hyunsu_exam_2026",
            f"{effect_prefix}:character:hyunsu",
            f"{effect_prefix}:producer_bundle:hyunsu_exam_eve",
            f"{effect_prefix}:source_kind:declined",
            f"{effect_prefix}:source_memory:{unanswered}",
            f"{effect_prefix}:decline_outcome:"
            f"{future.get('decline_outcome')}",
            f"{effect_prefix}:outcome:{future.get('canonical_outcome')}",
            f"{effect_prefix}:recorded_turn:24",
            f"{effect_prefix}:exam_turn:{future.get('exam_week')}",
            f"{effect_prefix}:available_turn:"
            f"{future.get('result_available_week')}",
            f"{effect_prefix}:result_event:{future.get('result_event')}",
        ],
        "runtime_proof_ids": [
            "proof:runtime:hyunsu_unanswered_future_story_receipt",
            "proof:data:hyunsu_future_story_contract",
            "proof:produce:hyunsu_future_story_unanswered",
        ],
        "selection_group_id": (
            "group:producer:milestone:w24:prepare_roots:"
            "hyunsu_exam_2026_source"),
    })]


def _expected_w24_candidate_variants() -> dict[str, dict[str, Any]]:
    """Return the exact 36-source/24-output First Bill candidate graph."""
    axis_variants = {
        "variant:milestone:w24:candidate_axis:city:present": (
            "group:producer:milestone:w24:candidate_axis:city",
            ["receipt:application:city_facility_ops_2026h1:submitted",
             "receipt:world:m6_city_service_response:resolved:week_index:3"],
            ["state:demo_collision_candidate_axis:city:present"]),
        "variant:milestone:w24:candidate_axis:city:absent": (
            "group:producer:milestone:w24:candidate_axis:city",
            ["state:demo_collision_predicate:city_work_sample:false"],
            ["state:demo_collision_candidate_axis:city:absent"]),
        "variant:milestone:w24:candidate_axis:job:hanbit": (
            "group:producer:milestone:w24:candidate_axis:job",
            ["receipt:application_transition:m5_hanbit_offer_message:"
             "v2_hanbit_offer_message:0",
             "receipt:application:hanbit_ops_2026q1:resolved",
             "state:current_job:job_03",
             "decision:v2_hanbit_offer_message:0"],
            ["state:demo_collision_candidate_axis:job:hanbit"]),
        "variant:milestone:w24:candidate_axis:job:urgent": (
            "group:producer:milestone:w24:candidate_axis:job",
            ["state:current_job:empty"],
            ["state:demo_collision_candidate_axis:job:urgent"]),
        "variant:milestone:w24:candidate_axis:job:neither": (
            "group:producer:milestone:w24:candidate_axis:job",
            ["state:demo_collision_predicate:job_candidate:none"],
            ["state:demo_collision_candidate_axis:job:neither"]),
        "variant:milestone:w24:candidate_axis:person:none": (
            "group:producer:milestone:w24:candidate_axis:person",
            ["state:demo_person_predicate:daeun:false",
             "state:demo_person_predicate:jaehyuk:false",
             "state:demo_person_predicate:sangchul:false"],
            ["state:demo_collision_candidate_axis:person_source:none"]),
        "variant:milestone:w24:candidate_axis:person:daeun": (
            "group:producer:milestone:w24:candidate_axis:person",
            ["receipt:completed:daeun_shared_dream",
             "state:relationship_memory:daeun:"
             "daeun_same_tuesday_promised:false",
             "memory:daeun:daeun_late_meal_promised",
             "decision:v2_daeun_small_commitment:1"],
            ["state:demo_collision_candidate_axis:person_source:daeun"]),
        "variant:milestone:w24:candidate_axis:person:jaehyuk_warm": (
            "group:producer:milestone:w24:candidate_axis:person",
            ["receipt:completed:jaehyuk_plain_reunion_echo",
             "memory:jaehyuk:jaehyuk_reunion_warm",
             "state:demo_person_predicate:daeun:false",
             "decision:v2_jaehyuk_plain_reunion_echo:0"],
            ["state:demo_collision_candidate_axis:person_source:jaehyuk_warm"]),
        "variant:milestone:w24:candidate_axis:person:jaehyuk_guarded": (
            "group:producer:milestone:w24:candidate_axis:person",
            ["receipt:completed:jaehyuk_plain_reunion_echo",
             "memory:jaehyuk:jaehyuk_reunion_guarded",
             "state:demo_person_predicate:daeun:false",
             "decision:v2_jaehyuk_plain_reunion_echo:1"],
            ["state:demo_collision_candidate_axis:person_source:jaehyuk_guarded"]),
        "variant:milestone:w24:candidate_axis:person:sangchul_pace": (
            "group:producer:milestone:w24:candidate_axis:person",
            ["receipt:completed:sangchul_second_coffee",
             "memory:sangchul:sangchul_own_pace_stated",
             "state:demo_person_predicate:daeun:false",
             "state:demo_person_predicate:jaehyuk:false",
             "decision:v2_sangchul_demo_echo:0"],
            ["state:demo_collision_candidate_axis:person_source:sangchul_pace"]),
        "variant:milestone:w24:candidate_axis:person:sangchul_numbers": (
            "group:producer:milestone:w24:candidate_axis:person",
            ["receipt:completed:sangchul_second_coffee",
             "memory:sangchul:sangchul_numbers_first_recorded",
             "state:demo_person_predicate:daeun:false",
             "state:demo_person_predicate:jaehyuk:false",
             "decision:v2_sangchul_demo_echo:1"],
            ["state:demo_collision_candidate_axis:person_source:sangchul_numbers"]),
    }
    expected: dict[str, dict[str, Any]] = {
        variant_id: {
            "selection_group_id": group_id,
            "activation_ids": activation_ids,
            "produced_fact_ids": produced_fact_ids,
        }
        for variant_id, (group_id, activation_ids, produced_fact_ids)
        in axis_variants.items()}

    person_output = {
        "none": None,
        "daeun": "daeun_checkin",
        "jaehyuk_warm": "jaehyuk_reply",
        "jaehyuk_guarded": "jaehyuk_reply",
        "sangchul_pace": "sangchul_ledger",
        "sangchul_numbers": "sangchul_ledger",
    }
    for city in ("absent", "present"):
        for job in ("neither", "hanbit", "urgent"):
            for person, obligation in person_output.items():
                candidates = ["father_call"]
                if job == "hanbit":
                    candidates.append("hanbit_month_close")
                if city == "present":
                    candidates.append("city_work_sample")
                if obligation is not None:
                    candidates.append(obligation)
                if job == "urgent":
                    candidates.append("urgent_paid_shift")
                candidates.append("body_rest")
                candidates = candidates[:4]
                variant_id = (
                    f"variant:milestone:w24:candidate_set:{city}:"
                    f"{job}:{person}")
                expected[variant_id] = {
                    "selection_group_id": (
                        "group:producer:milestone:w24:candidate_set"),
                    "activation_ids": [
                        f"state:demo_collision_candidate_axis:city:{city}",
                        f"state:demo_collision_candidate_axis:job:{job}",
                        "state:demo_collision_candidate_axis:person_source:"
                        f"{person}",
                    ],
                    "produced_fact_ids": [
                        "state:demo_collision_prepare:candidate_ids",
                        "state:demo_collision_prepare:candidate_set:"
                        + "+".join(candidates),
                        *(f"state:demo_collision_prepare:candidate:{item}"
                          for item in candidates),
                    ],
                }
    return expected


def _validate_w24_candidate_graph(
        invocation: dict[str, Any], where: str, errors: list[str]) -> None:
    expected_groups = {
        "group:producer:milestone:w24:candidate_axis:city":
            ("exactly_one", "active"),
        "group:producer:milestone:w24:candidate_axis:job":
            ("exactly_one", "active"),
        "group:producer:milestone:w24:candidate_axis:person":
            ("exactly_one", "active"),
        "group:producer:milestone:w24:candidate_set":
            ("exactly_one", "active"),
    }
    actual_groups = {
        group.get("selection_group_id"): (
            group.get("selection_mode"), group.get("causal_status"))
        for group in invocation.get("producer_variant_groups", [])
        if isinstance(group, dict)}
    if actual_groups != expected_groups:
        errors.append(
            f"{where}: W24 candidate producer groups do not match source graph")

    expected_variants = _expected_w24_candidate_variants()
    actual_variants = {
        variant.get("variant_id"): variant
        for variant in invocation.get("conditional_producers", [])
        if isinstance(variant, dict)}
    if set(actual_variants) != set(expected_variants):
        errors.append(
            f"{where}: W24 candidate graph must preserve all 36 source "
            "activations and axis producers")
        return
    for variant_id, expected in expected_variants.items():
        actual = actual_variants[variant_id]
        if any(actual.get(field) != expected[field]
               for field in ("selection_group_id", "activation_ids",
                             "produced_fact_ids")):
            errors.append(
                f"{where}: W24 candidate source variant mismatch {variant_id}")

    source_variants = [
        variant for variant_id, variant in actual_variants.items()
        if ":candidate_set:" in str(variant_id)]
    output_sets = {
        tuple(variant.get("produced_fact_ids", []))
        for variant in source_variants}
    if len(source_variants) != 36 or len(output_sets) != 24:
        errors.append(
            f"{where}: W24 candidate graph must retain 36 historical "
            "sources and 24 ordered output sets")


CONDITIONAL_ACTION_RESULT_FAMILIES = {
    "job_hunt", "aruba", "activity_task", "recovery",
}


def _conditional_action_group_id(
        chain_id: str, bundle_id: str, family: str) -> str | None:
    suffix_by_family = {
        "job_hunt": "resume_quality",
        "aruba": "aruba_runtime_result",
        "activity_task": "activity_task_outcome",
        "recovery": "recovery_effects",
    }
    suffix = suffix_by_family.get(family)
    return (f"group:producer:{chain_id}:{bundle_id}:{suffix}"
            if suffix else None)


def _bundle_execution_family(bundle_id: str, bundle: dict[str, Any]) -> str:
    """Classify one scheduled bundle by its actual MainGame execution owner.

    This deliberately does not infer the family from a ledger group ID.  The
    source data chooses the action dispatcher, while Story roots are an
    orthogonal producer graph handled by `_row_story_choice_records`.  Keeping
    the two layers separate prevents a fixed application/instant path from
    acquiring an invented conditional result group merely by relabeling JSON.
    """
    action_id = bundle.get("action_id")
    action_config = bundle.get("action_config", {})
    if not isinstance(action_config, dict):
        return "unknown:malformed_action_config"
    execution = action_config.get("execution")
    if execution not in (None, ""):
        if execution == "application":
            return "application"
        if execution == "activity_task":
            return "activity_task"
        if execution == "instant_effect":
            return "instant_effect"
        if execution == "rest":
            return "recovery"
        return f"unknown:execution:{execution}"
    if action_id == "resume":
        return "job_hunt"
    if action_id == "side_shift":
        return "aruba"
    if action_id == "rest":
        return "default_rest"
    if action_id == "apply":
        # Scheduled application bundles must name the application transaction
        # explicitly; the old implicit path is outside this audited snapshot.
        return "unknown:implicit_application"
    if isinstance(action_id, str) and action_id:
        return f"unknown:action:{action_id}"
    if (bundle.get("existing_roots")
            or bundle.get("relationship_outcomes")
            or bundle.get("application_outcomes")):
        return "story_only"
    return "unknown:no_execution_owner"


def _row_execution_family_contracts(
        row: dict[str, Any], cache: dict[Path, Any]
        ) -> list[tuple[str, str]]:
    """Return the exact ordered execution census for all authored triggers."""
    result: list[tuple[str, str]] = []
    for bundle_id in _row_trigger_bundles(row):
        bundle = _json_pointer_value(
            f"content/meta/demo_core_loop_v2.json#/scene_bundles/{bundle_id}",
            cache)
        if not isinstance(bundle, dict):
            result.append((bundle_id, "unknown:missing_bundle"))
            continue
        result.append((bundle_id, _bundle_execution_family(bundle_id, bundle)))
    return result


def _execution_family_source_is_bound(
        bundle_id: str, family: str, cache: dict[Path, Any]) -> bool:
    """Require the dispatcher/result owner that gives each family its meaning."""
    pointers_and_markers: dict[str, tuple[tuple[str, tuple[str, ...]], ...]] = {
        "job_hunt": (
            ("scenes/MainGame.gd::_on_job_hunt_closed", (
                "current_mode == 0", "match quality:",
                '"stress": stress_delta',
                'GameState.add_tendency("career", 1)',
                "finalize_weekly_effect_action(")),
            ("scenes/JobHuntMiniGame.gd::_on_finish", (
                "_final_stress_delta(quality)", "closed.emit(")),
            ("scenes/JobHuntMiniGame.gd::_final_stress_delta", (
                "_stress_delta", "quality == 0")),
        ),
        "aruba": (
            ("scenes/MainGame.gd::_core_loop_v2_open_side_shift", (
                'bundle_id == "m2_rain_delivery_shift"',
                '"weather": "rain"', '"surge_pay": true')),
            ("scenes/MainGame.gd::_on_aruba_closed", (
                '"money": earned', '"stress": stress_delta',
                '"health": total_health_delta',
                "finalize_weekly_effect_action(")),
            ("scenes/ArubaGame.gd::_on_finish", (
                "closed.emit(", "BASE_SHIFT_HEALTH_DELTA + _health_delta")),
        ),
        "activity_task": (
            ("scenes/MainGame.gd::_core_loop_v2_present_activity_task_result", (
                'config.get("outcomes"', 'details.get("outcome_id"',
                "GameState.add_log(")),
        ),
        "recovery": (
            ("scenes/MainGame.gd::_core_loop_v2_take_recovery", (
                'action_config.get("effects"',
                '"recovery_routine_effects"',
                'str(routines.get("primary"',
                'str(routines.get("secondary"',
                '"diminished_by_recovery_routine"',
                "finalize_weekly_effect_action(")),
        ),
        "application": (
            ("scenes/MainGame.gd::_core_loop_v2_submit_application", (
                'action_config.get("application_id"',
                'action_config.get("status"',
                '"execution": "application"',
                "finalize_weekly_effect_action(")),
        ),
        "instant_effect": (
            ("scenes/MainGame.gd::_core_loop_v2_apply_instant_effect", (
                'action_config.get("effects"',
                '"execution": "instant_effect"',
                "finalize_weekly_effect_action(")),
        ),
        "default_rest": (
            ("scenes/MainGame.gd::_core_loop_v2_take_recovery", (
                'var effects := {"mental": 10, "health": 3}',
                'action_config.get("effects"',
                "finalize_weekly_effect_action(")),
        ),
    }
    if family == "story_only":
        bundle = _json_pointer_value(
            f"content/meta/demo_core_loop_v2.json#/scene_bundles/{bundle_id}",
            cache)
        return isinstance(bundle, dict) and bool(
            bundle.get("existing_roots")
            or bundle.get("relationship_outcomes")
            or bundle.get("application_outcomes"))
    contracts = pointers_and_markers.get(family)
    if contracts is None:
        return False
    for pointer, markers in contracts:
        body = _pointer_source_text(pointer, cache)
        if not all(marker in body for marker in markers):
            return False
    if family == "aruba":
        if bundle_id == "m1_convenience_trial_shift":
            convenience_body = _pointer_source_text(
                "scenes/ArubaGame.gd::_conv_handle", cache)
            timeout_body = _pointer_source_text(
                "scenes/ArubaGame.gd::_conv_timeout", cache)
            return ("_earned += bonus" in convenience_body
                    and '_stress_delta += int(action.get("stress"' in convenience_body
                    and "_stress_delta += CONV_TIMEOUT_STRESS" in timeout_body)
        if bundle_id == "m2_rain_delivery_shift":
            delivery_body = _pointer_source_text(
                "scenes/ArubaGame.gd::_del_confirm", cache)
            selection_body = _pointer_source_text(
                "scenes/ArubaGame.gd::_del_refresh_ui", cache)
            return (all(marker in delivery_body for marker in (
                        "delivery_count := _del_selected.size()",
                        "DEL_BASE_BONUS", "DEL_RAIN_SURGE_PER_ORDER",
                        "maxi(delivery_count - 2, 0)",
                        "_health_delta -= delivery_count"))
                    and all(marker in selection_body for marker in (
                        "> DEL_TIME_BUDGET",
                        "_del_confirm_btn.disabled = _del_selected.is_empty()")))
        return False
    return True


def _source_prerequisite_fact_producers(
        rows: list[dict[str, Any]], cache: dict[Path, Any]
        ) -> dict[str, set[str]]:
    """Derive which implemented rows can author each prerequisite fact.

    Registry membership is not provenance.  This map intentionally follows the
    scheduled bundle data so a reader must be reverse-linked from every row that
    can produce its input.  External/world-clock and unscheduled facts are
    handled explicitly by the caller and never acquire a fake row owner.
    """
    result: dict[str, set[str]] = {}

    def add(fact_id: str, chain_id: str) -> None:
        if fact_id and chain_id:
            result.setdefault(fact_id, set()).add(chain_id)

    for row in rows:
        if not isinstance(row, dict):
            continue
        chain_id = str(row.get("chain_id", ""))
        if not chain_id:
            continue
        for fact_id in _expected_completion_receipts(row, cache):
            if isinstance(fact_id, str):
                add(fact_id, chain_id)
        producer = row.get("producer", {})
        variants = producer.get("conditional_output_variants", []) \
            if isinstance(producer, dict) else []
        if isinstance(variants, list):
            for variant in variants:
                if not isinstance(variant, dict):
                    continue
                for fact_id in variant.get("produced_fact_ids", []):
                    if isinstance(fact_id, str):
                        add(fact_id, chain_id)
        for bundle_id in _row_trigger_bundles(row):
            bundle = _json_pointer_value(
                "content/meta/demo_core_loop_v2.json#/scene_bundles/"
                f"{bundle_id}", cache)
            if not isinstance(bundle, dict):
                continue
            for raw_outcome in bundle.get("relationship_outcomes", []):
                if not isinstance(raw_outcome, dict):
                    continue
                character = raw_outcome.get("character")
                memory = raw_outcome.get("memory")
                stage = raw_outcome.get("to")
                if isinstance(character, str) and character:
                    if isinstance(memory, str) and memory:
                        add(f"memory:{character}:{memory}", chain_id)
                    if isinstance(stage, str) and stage:
                        add(f"state:relationship:{character}:{stage}", chain_id)
                    # ORDER-100 is explicitly scoped to a fresh Seoul-Cycle
                    # origin.  The father compatibility rewrite is proven and
                    # excluded separately by the scope contract.
                    if raw_outcome.get("initiative") == "player":
                        add(f"state:player_initiated:{character}", chain_id)
            application_id = ""
            config = bundle.get("action_config", {})
            if isinstance(config, dict):
                raw_application = config.get("application_id")
                if isinstance(raw_application, str):
                    application_id = raw_application
            for raw_outcome in bundle.get("application_outcomes", []):
                if isinstance(raw_outcome, dict) \
                        and isinstance(raw_outcome.get("application_id"), str):
                    application_id = raw_outcome["application_id"]
            if application_id:
                add(f"source:application:{application_id}", chain_id)

    # `routine_selected` is an OR aggregate.  Either livelihood allocation is
    # sufficient in one run, but both implemented potential producers must own
    # the reverse reference in the authoritative ledger.
    result["fact:routine_selected:livelihood"] = {
        "m1_convenience", "m2_livelihood"}
    return result


def _reader_first_available_week(reader: dict[str, Any],
                                 rows_by_chain: dict[str, dict[str, Any]],
                                 cache: dict[Path, Any]) -> int | None:
    """Derive the earliest week at which a named reader can exist."""
    reader_id = str(reader.get("reader_id", ""))
    month_match = re.fullmatch(r"reader:month:m(\d{2}):summary", reader_id)
    if month_match:
        return int(month_match.group(1)) * 4
    milestone_match = re.match(r"reader:milestone:w(\d{2}):", reader_id)
    if milestone_match:
        return int(milestone_match.group(1))
    for prefix in ("reader:near:",):
        if reader_id.startswith(prefix):
            row = rows_by_chain.get(reader_id.removeprefix(prefix), {})
            month = row.get("month")
            return ((int(month) - 1) * 4) + 1 if _is_int(month) else None
    pointer = reader.get("runtime_pointer")
    if isinstance(pointer, str) and "/scene_bundles/" in pointer:
        bundle_id = pointer.split("/scene_bundles/", 1)[1].split("/", 1)[0]
        bundle = _json_pointer_value(
            f"content/meta/demo_core_loop_v2.json#/scene_bundles/{bundle_id}",
            cache)
        weeks = bundle.get("allowed_weeks", []) \
            if isinstance(bundle, dict) else []
        if isinstance(weeks, list):
            authored_weeks = [week for week in weeks if _is_int(week)]
            return min(authored_weeks) if authored_weeks else None
    if reader_id.startswith("reader:action:"):
        bundle_id = reader_id.removeprefix("reader:action:")
        bundle = _json_pointer_value(
            f"content/meta/demo_core_loop_v2.json#/scene_bundles/{bundle_id}",
            cache)
        weeks = bundle.get("allowed_weeks", []) \
            if isinstance(bundle, dict) else []
        authored_weeks = [week for week in weeks if _is_int(week)] \
            if isinstance(weeks, list) else []
        return min(authored_weeks) if authored_weeks else None
    return None


def _source_body_binds_fact(pointer: str, body: str, fact_id: str,
                            reader_id: str, cache: dict[Path, Any]) -> bool:
    """Check concrete storage/key markers in the exact pointed function body.

    Assertions are descriptive only.  This function intentionally derives the
    binding from source tokens and the stable reader/fact IDs.
    """
    if not body:
        return False
    if reader_id.startswith("reader:action:"):
        bundle_id = reader_id.removeprefix("reader:action:")
        return (fact_id == f"receipt:action:{bundle_id}"
                and "action_receipts" in body
                and ("target_id" in body or "bundle_id" in body)
                and '"action_id"' in body)
    if reader_id.startswith("reader:month:"):
        if fact_id.startswith("receipt:allocation:"):
            return ("allocation_receipts" in body
                    and 'get("node_id"' in body)
        if fact_id.startswith("receipt:trigger:"):
            return ('"trigger_receipts"' in body
                    and 'cycle.get("trigger_receipts"' in body)
        if fact_id.startswith(("receipt:expiry:",
                               "receipt:trigger_expiry:")):
            return ('"expiry_receipts"' in body
                    and 'cycle.get("expiry_receipts"' in body)
        return False
    if reader_id.startswith("reader:near:"):
        return (fact_id.startswith(("receipt:allocation:", "receipt:trigger:"))
                and "allocation_receipts" in body and 'get("node_id"' in body)
    if reader_id.startswith("reader:milestone:w04:allocation:"):
        return (fact_id.startswith("receipt:allocation:m1_")
                and "allocation_receipts" in body
                and 'receipts.get("4"' in body and 'get("node_id"' in body)

    # A cold StoryMode resume crosses several exact owners: StoryMode writes
    # the resume context, SaveManager persists and consumes it, `_ready`
    # reconstructs the queue/current owner, and the restore functions render
    # the saved phase without replaying its choice effects.  The stable facts
    # below deliberately describe that transitive contract instead of
    # pretending that every field is a literal in the final consumer body.
    if pointer.endswith("::_ready") and fact_id.startswith(
            ("state:story_resume:", "state:active_bundle:",
             "state:active_turn:")):
        save_body = _pointer_source_text(
            "scenes/StoryMode.gd::build_save_resume_context", {})
        loaded_scene_body = _pointer_source_text(
            "autoloads/SaveManager.gd::loaded_scene_path", {})
        consume_body = _pointer_source_text(
            "autoloads/SaveManager.gd::consume_loaded_resume_context", {})
        snapshot_body = _pointer_source_text(
            "systems/DemoCoreLoopV2.gd::"
            "validated_first_bill_replay_snapshot", {})
        serialize_body = _pointer_source_text(
            "autoloads/GameState.gd::serialize", {})
        load_body = _pointer_source_text(
            "autoloads/GameState.gd::load_from_dict", {})
        normalize_body = _pointer_source_text(
            "systems/DemoCoreLoopV2.gd::_normalized_state", {})
        resume_chain = (
            '"kind": "story"' in save_body
            and '"scene": "res://scenes/StoryMode.tscn"' in save_body
            and '"return_scene"' in save_body
            and '"event_id"' in save_body
            and '"phase"' in save_body
            and '"pending_result_choice_index"' in save_body
            and 'consume_loaded_resume_context()' in body
            and 'resume_context.get("kind", "")' in body
            and '"story"' in body
            and 'resume_context.get("event_id", "")' in body
            and '_pending_restore_context = resume_context.duplicate(true)'
                in body
            and 'requested == STORY_MODE_SCENE' in loaded_scene_body
            and '_loaded_resume_context.clear()' in consume_body)
        if not resume_chain:
            return False
        if fact_id == "state:story_resume:kind:story":
            return True
        if fact_id == "state:story_resume:scene:StoryMode":
            return ('return STORY_MODE_SCENE' in loaded_scene_body
                    and 'SceneTransition.go(SaveManager.loaded_scene_path())'
                    in _pointer_source_text(
                        "scenes/StoryMode.gd::_load_story_from_slot", {}))
        if fact_id == "state:story_resume:return_scene:MainGame":
            return ('"res://scenes/MainGame.tscn"' in save_body
                    and 'resume_context.get(\n\t\t\t"return_scene"' in body
                    and 'GameState.story_return_scene' in body)
        if fact_id == "state:active_bundle:demo_collision":
            return ('"core_loop_v2_state": core_loop_v2_state'
                    in serialize_body
                    and 'data.has("core_loop_v2_state")' in load_body
                    and 'state["active_bundle"] = str(' in normalize_body)
        if fact_id == "state:active_turn:24":
            return ('"turn": turn' in serialize_body
                    and '"turn"' in load_body
                    and 'state["active_turn"] = int(' in normalize_body)
        parts = fact_id.split(":")
        if len(parts) == 4 and parts[:3] == [
                "state", "story_resume", "event"]:
            event_id = parts[3]
            return (event_id in {
                        "v2_demo_first_bill",
                        "v2_demo_first_bill_ledger",
                        "v2_hyunsu_exam_morning_echo",
                    }
                    and isinstance(_trusted_event_index(cache).get(
                        event_id), dict)
                    and 'resume_context.get("event_id", "")' in body)
        if len(parts) == 4 and parts[:3] == [
                "state", "story_resume", "phase"]:
            return (parts[3] in {"prose", "result"}
                    and '"phase": _story_resume_phase()' in save_body)
        if fact_id == (
                "state:story_resume:pending_result_choice_index:valid"):
            restore_result = _pointer_source_text(
                "scenes/StoryMode.gd::_restore_story_result", {})
            return ('"pending_result_choice_index": '
                    '_pending_result_choice_index' in save_body
                    and 'context.get("pending_result_choice_index"'
                        in restore_result
                    and "choice_index < 0 or choice_index >= choices.size()"
                        in restore_result)
        if fact_id == (
                "state:story_resume:first_bill_replay_snapshot:valid"):
            return ('resume_context["first_bill_replay_snapshot"]' in save_body
                    and 'raw_saved_first_bill' in body
                    and 'validated_first_bill_replay_snapshot' in body
                    and 'snapshot.get("obligation_receipt"' in snapshot_body)
        if (len(parts) == 4 and parts[:3] == [
                "state", "story_resume", "pending_result_choice_index"]
                and parts[3].isdigit()):
            return ('"pending_result_choice_index": '
                    '_pending_result_choice_index' in save_body)
        return False

    if pointer.endswith("::_apply_story_resume_context") and (
            fact_id.startswith("state:story_resume:")
            or fact_id.startswith("handoff:story_resume:w24:")
            or fact_id == "handoff:story:first_bill_replay_snapshot:captured"):
        restore_result = _pointer_source_text(
            "scenes/StoryMode.gd::_restore_story_result", {})
        restore_paragraph = _pointer_source_text(
            "scenes/StoryMode.gd::_restore_story_paragraph", {})
        load_next = _pointer_source_text(
            "scenes/StoryMode.gd::_load_next_event", {})
        base = ('context.get("event_id", "")' in body
                and '_current.get("id", "")' in body
                and 'context.get("phase", "prose")' in body
                and '_restore_story_result(context)' in body
                and '_restore_story_paragraph(context, false)' in body)
        if not base:
            return False
        handoff_by_event_phase = {
            "handoff:story_resume:w24:first_bill_decision_result": (
                "v2_demo_first_bill", "result"),
            "handoff:story_resume:w24:first_bill_ledger_prose": (
                "v2_demo_first_bill_ledger", "prose"),
            "handoff:story_resume:w24:first_bill_ledger_result": (
                "v2_demo_first_bill_ledger", "result"),
            "handoff:story_resume:w24:hyunsu_morning_prose": (
                "v2_hyunsu_exam_morning_echo", "prose"),
            "handoff:story_resume:w24:hyunsu_morning_result": (
                "v2_hyunsu_exam_morning_echo", "result"),
        }
        if fact_id in handoff_by_event_phase:
            event_id, phase = handoff_by_event_phase[fact_id]
            return (isinstance(_trusted_event_index(cache).get(
                        event_id), dict)
                    and (phase == "result" and "_restore_story_result" in body
                         or phase == "prose"
                         and "_restore_story_paragraph" in body))
        if fact_id == "handoff:story:first_bill_replay_snapshot:captured":
            capture_call = load_next.find(
                "_capture_first_bill_replay_snapshot()")
            render_call = load_next.find("_render_current()")
            restore_call = load_next.find("_apply_story_resume_context(")
            return (capture_call >= 0 and render_call > capture_call
                    and restore_call > render_call)
        parts = fact_id.split(":")
        if len(parts) == 4 and parts[:3] == [
                "state", "story_resume", "event"]:
            return (parts[3] in {
                        "v2_demo_first_bill",
                        "v2_demo_first_bill_ledger",
                        "v2_hyunsu_exam_morning_echo",
                    }
                    and isinstance(_trusted_event_index(cache).get(
                        parts[3]), dict))
        if len(parts) == 4 and parts[:3] == [
                "state", "story_resume", "phase"]:
            phase = parts[3]
            return (phase == "result" and "_restore_story_result" in body
                    and 'context.get("pending_result_choice_index"'
                        in restore_result
                    or phase == "prose" and "_restore_story_paragraph" in body
                    and 'context.get("phase"' in restore_paragraph)
        if (len(parts) == 4 and parts[:3] == [
                "state", "story_resume", "pending_result_choice_index"]
                and parts[3].isdigit()):
            choice_index = int(parts[3])
            event_id = (
                "v2_demo_first_bill"
                if "first_bill_decision_result" in reader_id
                else "v2_demo_first_bill_ledger"
                if "first_bill_ledger" in reader_id
                else "v2_hyunsu_exam_morning_echo")
            choices = _trusted_event_index(cache).get(event_id, {}).get(
                "choices", [])
            return (isinstance(choices, list)
                    and 0 <= choice_index < len(choices)
                    and 'context.get("pending_result_choice_index"'
                        in restore_result
                    and "choice_index < 0 or choice_index >= choices.size()"
                        in restore_result)
        return False

    if pointer.endswith("::_capture_first_bill_replay_snapshot") and (
            fact_id.startswith(
                "state:story_resume:first_bill_replay_snapshot:")
            or fact_id ==
                "handoff:story_resume:w24:first_bill_snapshot_loaded"):
        validator = _pointer_source_text(
            "systems/DemoCoreLoopV2.gd::"
            "validated_first_bill_replay_snapshot", {})
        loaded_snapshot = (
            'elif not _first_bill_replay_snapshot.is_empty()' in body
            and 'validated_first_bill_replay_snapshot(' in body
            and '_first_bill_replay_snapshot' in body
            and 'snapshot.get("obligation_receipt"' in body
            and 'MetaProgression.record_scene_replay_snapshot' in body
            and 'snapshot.get("obligation_receipt"' in validator
            and '_first_bill_obligation_receipt(' in validator)
        if not loaded_snapshot:
            return False
        if fact_id in {
                "handoff:story_resume:w24:first_bill_snapshot_loaded",
                "state:story_resume:first_bill_replay_snapshot:valid"}:
            return True
        parts = fact_id.split(":")
        outcomes = _json_pointer_value(
            "content/meta/demo_core_loop_v2.json#/scene_bundles/"
            "demo_collision/obligation_outcomes", cache)
        choice_to_obligation = {
            int(item["choices"][0]): str(item["selected_obligation_id"])
            for item in outcomes if isinstance(outcomes, list)
            and isinstance(item, dict)
            and isinstance(item.get("choices"), list)
            and len(item["choices"]) == 1
            and _is_int(item["choices"][0])
            and isinstance(item.get("selected_obligation_id"), str)
        } if isinstance(outcomes, list) else {}
        if (len(parts) == 5 and parts[:4] == [
                "state", "story_resume", "first_bill_replay_snapshot",
                "obligation"]):
            obligation_id = ":".join(parts[4:])
            return obligation_id in choice_to_obligation.values()
        if (len(parts) == 5 and parts[:4] == [
                "state", "story_resume", "first_bill_replay_snapshot",
                "choice"] and parts[4].isdigit()):
            return int(parts[4]) in choice_to_obligation
        return False

    if pointer.endswith("::_story_has_pending_fatal_state") \
            and fact_id == "state:story_fatal_gate:first_bill:true":
        load_next = _pointer_source_text(
            "scenes/StoryMode.gd::_load_next_event", {})
        return (all(marker in body for marker in (
                    "GameState.is_game_over", "GameState.health",
                    "GameState.mental", "GameState.get_total_asset_value()",
                    "GameState.addiction_tendency"))
                and "_story_has_pending_fatal_state()" in load_next
                and "_queue.clear()" in load_next
                and "_finish_all()" in load_next)

    if pointer.endswith("::_finish_all") and fact_id in {
            "state:story_fatal_gate:first_bill:false",
            "state:story_queue:w24:exhausted"}:
        load_next = _pointer_source_text(
            "scenes/StoryMode.gd::_load_next_event", {})
        return ("GameState.returning_from_story = not _read_only_replay" in body
                and "SceneTransition.go(ret)" in body
                and "if _queue.is_empty():" in load_next
                and "_story_has_pending_fatal_state()" in load_next
                and "_finish_all()" in load_next)

    parts = fact_id.split(":")
    if fact_id == "state:prelude:m6:father_health_signal:pending":
        month_six = _json_pointer_value(
            "content/meta/demo_core_loop_v2.json#/months/5/prelude", cache)
        return (pointer.endswith("::pending_month_prelude")
                and isinstance(month_six, list)
                and "father_health_signal" in month_six
                and 'month_spec(target_month).get("prelude"' in body
                and "_bundle_requirement_met" in body
                and "return prelude_id" in body)
    if fact_id == "state:demo_collision_context:present":
        if pointer.endswith("::_validated_demo_collision_context"):
            return ('state.get("demo_collision_context"' in body
                    and "is_empty()" in body
                    and 'get("bundle_id"' in body
                    and '"demo_collision"' in body)
        return ("_validated_demo_collision_context" in body
                and "context.is_empty()" in body)
    if fact_id == "state:demo_collision_context:validated":
        context_body = _pointer_source_text(
            "systems/DemoCoreLoopV2.gd::_validated_demo_collision_context", {})
        return ("_validated_demo_collision_context" in body
                and "is_empty()" in body
                and 'state.get("demo_collision_context"' in context_body
                and '"demo_collision"' in context_body
                and 'context.get("roots"' in context_body
                and 'context.get("candidate_ids"' in context_body)
    if fact_id.startswith("state:flag:") and len(parts) >= 3:
        expects_false = parts[-1] == "false" and len(parts) >= 4
        flag_id = ":".join(parts[2:-1] if expects_false else parts[2:])
        if pointer.endswith("::_story_memory_condition_matches"):
            return 'GameState.flags.get(condition' in body
        return ("GameState.flags" in body and f'"{flag_id}"' in body
                and (not expects_false or "false" in body))
    if (fact_id.startswith("state:deferred_event:") and len(parts) == 5
            and parts[3] == "due_turn" and parts[4].isdigit()):
        return ("claim_deferred_event" in body
                and f'"{parts[2]}"' in body
                and parts[4] in body)
    if (fact_id.startswith("state:deferred_callback:") and len(parts) == 4
            and parts[3] == "absent"):
        return ("deferred_callback_receipts" in body
                and f'"{parts[2]}"' in body
                and "is_empty()" in body)
    if fact_id.startswith("receipt:deferred_callback:") and len(parts) >= 3:
        source_id = parts[2]
        if len(parts) == 4 and parts[3] == "claimed_or_resolved":
            return ("deferred_callback_receipts" in body
                    and f'"{source_id}"' in body
                    and 'not in ["claimed", "resolved"]' in body)
        if len(parts) == 4 and parts[3] == "claimed":
            prepare_body = _pointer_source_text(
                "systems/DemoCoreLoopV2.gd::prepare_demo_collision", {})
            return ("_exact_deferred_story_choice_matches" in body
                    and f'"{source_id}"' in prepare_body
                    and '"status": "claimed"' in prepare_body)
        if (len(parts) == 8 and parts[3] == "resolved"
                and parts[5] == "choice" and parts[6].isdigit()):
            # Kept for compatibility with an earlier token draft whose root
            # happened not to contain colons; the canonical shape is handled
            # by the generic split below.
            pass
        if ":resolved:" in fact_id and ":choice:" in fact_id:
            suffix = fact_id.split(":resolved:", 1)[1]
            root_id, raw_choice = suffix.rsplit(":choice:", 1)
            if not raw_choice.isdigit():
                return False
            event = _trusted_event_index(cache).get(root_id, {})
            choices = event.get("choices", []) \
                if isinstance(event, dict) else []
            direct_binding = (
                '"status"' in body and '"resolved"' in body
                and 'get("event_id", "")' in body
                and 'get("choice_index", -1)' in body
                and 'get("resolved_turn", -1)' in body)
            context_body = _pointer_source_text(
                "systems/DemoCoreLoopV2.gd::_validated_demo_collision_context",
                {})
            transitive_binding = (
                "_validated_demo_collision_context" in body
                and 'get("event_id", "")' in context_body
                and 'get("choice_index", -1)' in context_body
                and 'get("resolved_turn", -1)' in context_body
                and '"resolved"' in context_body
                and ("deferred_callback_receipts" in body
                     or "dirty_receipt" in body))
            return (isinstance(choices, list)
                    and int(raw_choice) < len(choices)
                    and (direct_binding or transitive_binding))
        return ("deferred_callback_receipts" in body
                and f'"{source_id}"' in body)
    if fact_id.startswith("receipt:completed:") and len(parts) == 3:
        if (parts[2] == "hyunsu_exam_eve"
                and pointer.endswith("::prepare_demo_collision")):
            return ("has_completed_bundle(str(" in body
                    and "_hyunsu_exam_contract()" in body
                    and 'get(\n\t\t\t\t\t"producer_bundle"' in body)
        return ("has_completed_bundle" in body
                and f'"{parts[2]}"' in body)
    if (fact_id.startswith("state:completed_bundle:") and len(parts) == 4
            and parts[3] == "false"):
        if (parts[2] == "hyunsu_exam_eve"
                and pointer.endswith("::prepare_demo_collision")):
            return ("if not has_completed_bundle(str(" in body
                    and "_hyunsu_exam_contract()" in body
                    and '"producer_bundle"' in body)
        return ("not has_completed_bundle" in body
                and f'"{parts[2]}"' in body)
    if fact_id == "state:completion_application_required:demo_collision":
        requirement_body = _pointer_source_text(
            "systems/DemoCoreLoopV2.gd::"
            "_selected_choice_requires_outcome_receipt", {})
        return (pointer.endswith("::complete_active_bundle")
                and 'bundle_id == "demo_collision"' in body
                and "_selected_choice_requires_outcome_receipt" in body
                and '"application_outcomes"' in body
                and "story_choice_receipts" in requirement_body
                and 'get("event_id", "")' in requirement_body
                and 'get("choice_index", -1)' in requirement_body
                and "_outcome_runtime_applicable" in requirement_body
                and "_outcome_choice_matches" in requirement_body)
    if (fact_id ==
            "receipt:application_transition:demo_collision:any_current_turn"):
        receipt_body = _pointer_source_text(
            "systems/DemoCoreLoopV2.gd::_has_current_application_receipt", {})
        return (pointer.endswith("::complete_active_bundle")
                and "_has_current_application_receipt" in body
                and "application_transition_receipts" in receipt_body
                and '"bundle_id", ""' in receipt_body
                and "== bundle_id" in receipt_body
                and '"turn", -1' in receipt_body
                and "GameState.turn" in receipt_body)
    if fact_id.startswith("receipt:application:") and len(parts) >= 4:
        if pointer.endswith("::complete_active_bundle"):
            # The completion helper does not join a transition receipt back to
            # an application/event/choice/status identity.  ORDER-100 records
            # only the truthful any-current-turn gate and emits a stable
            # SHADOWED_READER debt for the missing identity correlation.
            return False
        return ("application_status" in body
                and f'"{parts[2]}"' in body and f'"{parts[3]}"' in body)
    if fact_id.startswith("state:relationship:") and len(parts) >= 4:
        return ("relationship_stage" in body
                and f'"{parts[2]}"' in body and f'"{parts[3]}"' in body)
    if fact_id.startswith("receipt:future_story:hyunsu_exam_2026"):
        const_line = _pointer_source_text(
            "systems/DemoCoreLoopV2.gd::HYUNSU_EXAM_OUTCOME_RECEIPT_ID", {})
        ensure_body = _pointer_source_text(
            "systems/DemoCoreLoopV2.gd::_ensure_hyunsu_exam_outcome_receipt", {})
        contract = _json_pointer_value(
            "content/meta/demo_core_loop_v2.json#/future_story_contracts/"
            "hyunsu_exam_2026", cache)
        base = ("HYUNSU_EXAM_OUTCOME_RECEIPT_ID" in ensure_body
                and '"hyunsu_exam_2026"' in const_line
                and isinstance(contract, dict))
        if not base:
            return False
        if fact_id == "receipt:future_story:hyunsu_exam_2026":
            return ("_ensure_hyunsu_exam_outcome_receipt" in body
                    or "_hyunsu_exam_outcome_receipt_valid" in body
                    or "future_story_receipts" in body)
        source = fact_id.split(":source:", 1)[1] \
            if ":source:" in fact_id else ""
        if source.startswith("relationship_memory:"):
            memory = source.removeprefix("relationship_memory:")
            snapshot_copy = (pointer.endswith(
                "::build_first_bill_replay_snapshot")
                and "future_story_receipts" in body
                and "HYUNSU_EXAM_OUTCOME_RECEIPT_ID" in body
                and 'snapshot["hyunsu_receipt"]' in body
                and "_validated_demo_collision_context" in body)
            return (memory in contract.get("required_memories", [])
                    and (snapshot_copy
                         or ('"source_memory"' in body
                             and "_first_bill_localized_copy" in body)))
        if source.startswith("declined:"):
            memory = source.removeprefix("declined:")
            snapshot_copy = (pointer.endswith(
                "::build_first_bill_replay_snapshot")
                and "future_story_receipts" in body
                and "HYUNSU_EXAM_OUTCOME_RECEIPT_ID" in body
                and 'snapshot["hyunsu_receipt"]' in body
                and "_validated_demo_collision_context" in body)
            return (memory == contract.get("unanswered_source")
                    and (snapshot_copy
                         or ('"source_memory"' in body
                             and "_first_bill_localized_copy" in body)))
        return False
    if fact_id.startswith("receipt:consequence:") and len(parts) >= 4:
        return ("_consequence_was_presented" in body
                and f'"{parts[2]}"' in body)
    if (fact_id.startswith("receipt:world:") and len(parts) == 6
            and parts[3] == "resolved" and parts[4] == "week_index"
            and parts[5].isdigit()):
        transport_body = _pointer_source_text(
            "systems/DemoCoreLoopV2.gd::_consequence_was_presented", {})
        return ("_consequence_was_presented" in body
                and f'"{parts[2]}"' in body
                and 'cycle.get("world_receipts"' in transport_body
                and '"status"' in transport_body
                and '"resolved"' in transport_body
                and 'str(raw_receipt_key) == str(week_index)' in transport_body
                and f'week_index' in transport_body)
    if fact_id.startswith("receipt:application_transition:") and len(parts) >= 5:
        receipt_key = ":".join(parts[2:])
        if "application_transition_receipts" not in body:
            return False
        if f'"{receipt_key}"' in body:
            return True
        # Provenance readers intentionally omit the authored turn suffix from
        # the stable fact token, but the runtime receipt key must contain it.
        return (pointer.endswith("::has_hanbit_employment_provenance")
                and f'"{receipt_key}:' in body
                and 'get("turn", -1)' in body)
    if fact_id.startswith("state:application:") and len(parts) >= 4:
        return ("application_statuses" in body
                and f'"{parts[2]}"' in body and f'"{parts[3]}"' in body)
    if fact_id.startswith("state:current_job:") and len(parts) >= 3:
        state_id = ":".join(parts[2:])
        if state_id == "empty":
            return "GameState.current_job.is_empty()" in body
        return ("GameState.current_job" in body and f'"{state_id}"' in body)
    if fact_id.startswith("memory:") and len(parts) >= 3:
        character_id, memory_id = parts[1], ":".join(parts[2:])
        literal_in_body = f'"{memory_id}"' in body
        if (character_id == "father"
                and (pointer.endswith("::_story_memory_condition_matches")
                     or "FIRST_BILL_FATHER_MEMORY_IDS" in body)):
            try:
                literal_in_body = f'"{memory_id}"' in DEMO_RUNTIME_PATH.read_text(
                    encoding="utf-8")
            except OSError:
                literal_in_body = False
        if pointer.endswith("::_story_memory_condition_matches"):
            return (literal_in_body
                    and 'condition.begins_with("relationship_memory:"' in body
                    and "character_id" in body and "memory_id" in body
                    and ("has_relationship_memory" in body
                         or "first_bill_replay_has_relationship_memory" in body))
        return (f'"{character_id}"' in body and literal_in_body
                and ("_has_relationship_memory" in body
                     or "relationship_memories" in body))
    if (fact_id.startswith("state:relationship_memory:")
            and len(parts) >= 5 and parts[-1] == "false"):
        character_id = parts[2]
        memory_id = ":".join(parts[3:-1])
        return ("not _has_relationship_memory" in body
                and f'"{character_id}"' in body
                and f'"{memory_id}"' in body)
    if fact_id.startswith("state:demo_collision_context:dirty_"):
        raw_kind = parts[2] if len(parts) >= 4 else ""
        value = ":".join(parts[3:]) if len(parts) >= 4 else ""
        prepare_body = _pointer_source_text(
            "systems/DemoCoreLoopV2.gd::prepare_demo_collision", {})
        context_body = _pointer_source_text(
            "systems/DemoCoreLoopV2.gd::_validated_demo_collision_context", {})
        return (raw_kind in {"dirty_source", "dirty_root"}
                and bool(value) and f'"{value}"' in prepare_body
                and (f'context.get("{raw_kind}"' in body
                     or ("_validated_demo_collision_context" in body
                         and f'context.get("{raw_kind}"' in context_body)))
    if fact_id == "state:demo_collision_context:candidate_ids":
        return ("_validated_demo_collision_context" in body
                and ('get("candidate_ids"' in body
                     or "_first_bill_candidate_ids" in body))
    if fact_id.startswith("state:demo_collision_context:candidate:"):
        obligation_id = fact_id.removeprefix(
            "state:demo_collision_context:candidate:")
        outcome_applicable = _pointer_source_text(
            "systems/DemoCoreLoopV2.gd::_outcome_runtime_applicable", {})
        if pointer.endswith("::story_choice_available"):
            return ("_validated_demo_collision_context" in body
                    and 'context.get("candidate_ids"' in body
                    and "normalized_obligation" in body)
        return (pointer.endswith("::complete_active_bundle")
                and obligation_id == "city_work_sample"
                and "_selected_choice_requires_outcome_receipt" in body
                and 'has("city_work_sample")' in outcome_applicable)
    if fact_id.startswith("state:demo_collision_context:candidate_set:"):
        candidate_ids = fact_id.removeprefix(
            "state:demo_collision_context:candidate_set:").split("+")
        known_ids = {
            "father_call", "hanbit_month_close", "city_work_sample",
            "daeun_checkin", "jaehyuk_reply", "sangchul_ledger",
            "urgent_paid_shift", "body_rest",
        }
        return (pointer.endswith("::story_choice_available")
                and bool(candidate_ids)
                and set(candidate_ids).issubset(known_ids)
                and "_validated_demo_collision_context" in body
                and 'context.get("candidate_ids"' in body
                and ".has(" in body)
    if fact_id == (
            "state:demo_collision_context:root:"
            "v2_hyunsu_exam_morning_echo"):
        return ('context.get("roots"' in body
                and 'has("v2_hyunsu_exam_morning_echo")' in body)
    if fact_id == "state:health":
        return "GameState.health" in body or 'snapshot.get("health"' in body
    if fact_id == "state:money":
        return "GameState.money" in body or 'snapshot.get("money"' in body
    if fact_id == "state:required_cash":
        return ("get_monthly_required_cash" in body
                or 'snapshot.get("required_cash"' in body)
    if fact_id.startswith("receipt:obligation:demo_collision"):
        receipt_body = _pointer_source_text(
            "systems/DemoCoreLoopV2.gd::_first_bill_obligation_receipt", {})
        if fact_id == "receipt:obligation:demo_collision":
            return (("_first_bill_obligation_receipt" in body
                     or 'state["obligation_receipts"].get' in body
                     or 'snapshot.get("obligation_receipt"' in body)
                    and '"demo_collision"' in receipt_body)
        obligation_ids = {
            str(item.get("selected_obligation_id"))
            for item in (_json_pointer_value(
                "content/meta/demo_core_loop_v2.json#/scene_bundles/"
                "demo_collision/obligation_outcomes", cache) or [])
            if isinstance(item, dict)}
        if ":selected:" in fact_id:
            obligation_id = fact_id.split(":selected:", 1)[1]
            return (obligation_id in obligation_ids
                    and '"selected_obligation_id"' in receipt_body
                    and ("_first_bill_obligation_receipt" in body
                         or 'snapshot.get("obligation_receipt"' in body))
        if ":deferred:candidates_minus:" in fact_id:
            obligation_id = fact_id.split(
                ":deferred:candidates_minus:", 1)[1]
            return (obligation_id in obligation_ids
                    and 'get("deferred_obligation_ids"' in receipt_body
                    and "expected_deferred" in receipt_body
                    and "_first_bill_obligation_receipt" in body)
    if fact_id == "state:first_bill_prechoice_snapshot":
        return (pointer.endswith("::_capture_first_bill_replay_snapshot")
                and "_first_bill_live_prechoice_snapshot" in body
                and "first_bill_replay_snapshot_with_choice" in body)
    scalar_markers = {
        "state:player_name": "GameState.player_name",
        "state:housing": "GameState.housing",
        "state:mental": "GameState.mental",
        "state:addiction_tendency": "GameState.addiction_tendency",
        "state:moral_tint": "GameState.moral_tint",
        "state:total_assets": "GameState.get_total_asset_value()",
        "state:housing_expense": "GameState.get_housing_expense()",
    }
    if fact_id in scalar_markers:
        return scalar_markers[fact_id] in body
    if fact_id.startswith("activity_task_outcome:m3_inventory_shift:"):
        outcome_id = fact_id.rsplit(":", 1)[-1]
        config = _json_pointer_value(
            "content/meta/demo_core_loop_v2.json#/scene_bundles/"
            "m3_inventory_shift/action_config", cache)
        authored_outcomes = set(config.get("outcomes", {})) \
            if isinstance(config, dict) \
            and isinstance(config.get("outcomes"), dict) else set()
        if isinstance(config, dict) and isinstance(
                config.get("overreach"), dict):
            authored_outcomes.add(str(config["overreach"].get(
                "outcome_id", "")))
        return (outcome_id in authored_outcomes
                and pointer.endswith("::_story_memory_condition_matches")
                and 'condition.begins_with("activity_task_outcome:"' in body
                and "activity_task_receipt_outcome_id" in body)
    if fact_id == "receipt:action:m3_inventory_shift":
        return (pointer.endswith("::_story_memory_condition_matches")
                and 'condition.begins_with("activity_task_outcome:"' in body
                and "activity_task_receipt_outcome_id" in body)
    return False


def _proofs_bind_reader_fact(reader: dict[str, Any], fact_id: str,
                             proofs: list[dict[str, Any]],
                             cache: dict[Path, Any], *,
                             supporting_proofs: list[dict[str, Any]] | None = None
                             ) -> bool:
    """Require the reader data/source and its proof pointer to bind one fact."""
    reader_id = str(reader.get("reader_id", ""))
    reader_pointer = str(reader.get("runtime_pointer", ""))
    proof_pointers = {
        str(proof.get("pointer", "")) for proof in proofs
        if isinstance(proof.get("pointer"), str)
    }
    all_proofs = [*proofs, *(supporting_proofs or [])]
    expected_proof_pointer = reader_pointer

    if reader_id == W24_COMPLETION_APPLICATION_READER_ID:
        expected_pointers_by_fact = {
            "state:completion_application_required:demo_collision": {
                "systems/DemoCoreLoopV2.gd::"
                "_selected_choice_requires_outcome_receipt",
                "systems/DemoCoreLoopV2.gd::_outcome_runtime_applicable",
            },
            "receipt:application_transition:demo_collision:any_current_turn": {
                "systems/DemoCoreLoopV2.gd::"
                "_has_current_application_receipt",
            },
        }
        expected_pointers = expected_pointers_by_fact.get(fact_id)
        complete_activation_pointer_union = set().union(
            *expected_pointers_by_fact.values())
        completion_body = _pointer_source_text(reader_pointer, cache)
        return (
            expected_pointers is not None
            and proof_pointers in (
                expected_pointers, complete_activation_pointer_union)
            and reader_pointer ==
                "systems/DemoCoreLoopV2.gd::complete_active_bundle"
            and _source_body_binds_fact(
                reader_pointer, completion_body, fact_id, reader_id, cache))

    # W8 is a two-owner consumer: the world-event resolver chooses the clean
    # versus fallout root, while `_bundle_requirement_met` has already
    # consumed the exact completed-boss prerequisite.  Requiring the resolver
    # pointer for that prerequisite would erase the real upstream gate;
    # accepting only the prerequisite pointer would allow a dead resolver.
    if (reader_id == "reader:milestone:w08:temptation_route"
            and fact_id == "receipt:completed:first_temptation_boss"):
        prerequisite_pointer = (
            "content/meta/demo_core_loop_v2.json#/scene_bundles/"
            "temptation_consequence/prerequisites")
        prerequisite = _json_pointer_value(prerequisite_pointer, cache)
        requirement_body = _pointer_source_text(
            "systems/DemoCoreLoopV2.gd::_bundle_requirement_met", cache)
        resolver_body = _pointer_source_text(reader_pointer, cache)
        proof_pointers_all = {
            str(proof.get("pointer", "")) for proof in all_proofs
            if isinstance(proof.get("pointer"), str)}
        return (
            prerequisite_pointer in proof_pointers_all
            and "systems/DemoCoreLoopV2.gd::_bundle_requirement_met"
                in proof_pointers_all
            and _json_consumer_binds_fact(prerequisite, fact_id)
            and "_predicate_met" in requirement_body
            and 'bundle_id == "temptation_consequence"' in resolver_body
            and 'GameState.flags.get("lent_account"' in resolver_body
            and 'return ["arc_temptation_fallout"]' in resolver_body
            and 'return ["arc_temptation_clean"]' in resolver_body)
    if expected_proof_pointer not in proof_pointers:
        return False

    if "#/" in reader_pointer:
        value = _json_pointer_value(reader_pointer, cache)
        requirement_body = _pointer_source_text(
            "systems/DemoCoreLoopV2.gd::_bundle_requirement_met", cache)
        all_proof_pointers = {
            str(proof.get("pointer", "")) for proof in all_proofs
            if isinstance(proof.get("pointer"), str)}
        if reader_pointer.endswith("/prerequisites"):
            return (
                reader_pointer in proof_pointers
                and "systems/DemoCoreLoopV2.gd::_bundle_requirement_met"
                    in all_proof_pointers
                and _json_consumer_binds_fact(value, fact_id)
                and "_predicate_met" in requirement_body)
        return _json_consumer_binds_fact(value, fact_id)

    body = _pointer_source_text(reader_pointer, cache)
    if not _source_body_binds_fact(
            reader_pointer, body, fact_id, reader_id, cache):
        return False

    if reader_id == "reader:milestone:w08:temptation_route":
        choice_pointer = "content/events/arc_events.json#/25/choices"
        choices = _json_pointer_value(choice_pointer, cache)
        choice_proof_present = any(
            proof.get("pointer") == choice_pointer for proof in all_proofs)
        authored_choice_pair = (
            isinstance(choices, list) and len(choices) == 2
            and "kept_clean_hands" in choices[0].get("flags", [])
            and "lent_account" not in choices[0].get("flags", [])
            and "lent_account" in choices[1].get("flags", []))
        consumer_markers = (
            'bundle_id == "temptation_consequence"',
            'GameState.flags.get("lent_account"',
            'return ["arc_temptation_fallout"]',
            'return ["arc_temptation_clean"]',
        )
        return (fact_id == "state:flag:lent_account"
                and choice_proof_present and authored_choice_pair
                and all(marker in body for marker in consumer_markers))

    # StoryMode's generic matcher is only a real binding when authored event
    # data names the exact memory key/outcome family.
    if reader_pointer.endswith("::_story_memory_condition_matches"):
        if fact_id == "receipt:action:m3_inventory_shift":
            expected_data_pointer = (
                "content/events/core_loop_v2_events.json#/30/description_memory_if_known")
            return any(
                proof.get("pointer") == expected_data_pointer
                and "activity_task_outcome:m3_inventory_shift:" in
                    _pointer_source_text(expected_data_pointer, cache)
                for proof in all_proofs)
        if fact_id in {
                "state:flag:m3_ledger_reasons_named",
                "state:flag:m3_ledger_totals_only"}:
            expected_data_pointer = (
                "content/events/core_loop_v2_events.json#/35/description_memory_if_known")
            return any(
                proof.get("pointer") == expected_data_pointer
                and fact_id.removeprefix("state:flag:") in
                    _pointer_source_text(expected_data_pointer, cache)
                for proof in all_proofs)
    return True


def _w24_completion_application_identity_is_shadowed(
        cache: dict[Path, Any]) -> bool:
    """Return whether completion accepts an uncorrelated app receipt.

    The current runtime truth is intentionally recorded rather than upgraded:
    the selected Story choice decides whether a transition is required, while
    the receipt helper accepts any transition for ``demo_collision`` in the
    current turn.  That gate is real and remains causal, but the missing
    choice/application/status identity join is a stable SHADOWED_READER debt
    routed to the later W24 runtime-repair order.
    """
    completion = _pointer_source_text(
        "systems/DemoCoreLoopV2.gd::complete_active_bundle", cache)
    requirement = _pointer_source_text(
        "systems/DemoCoreLoopV2.gd::"
        "_selected_choice_requires_outcome_receipt", cache)
    receipt = _pointer_source_text(
        "systems/DemoCoreLoopV2.gd::_has_current_application_receipt", cache)
    if not all((completion, requirement, receipt)):
        return False
    real_composite_gate = (
        "_selected_choice_requires_outcome_receipt" in completion
        and "_has_current_application_receipt" in completion
        and "story_choice_receipts" in requirement
        and '"event_id", ""' in requirement
        and '"choice_index", -1' in requirement
        and "application_transition_receipts" in receipt
        and '"bundle_id", ""' in receipt
        and "== bundle_id" in receipt
        and '"turn", -1' in receipt
        and "GameState.turn" in receipt)
    identity_markers = (
        '"event_id"', '"choice_index"', '"application_id"',
        '"status"', '"from"', '"to"')
    return real_composite_gate and not any(
        marker in receipt for marker in identity_markers)


def _w24_has_exact_completion_identity_gate(
        milestone_records: list[tuple[int, dict[str, Any], str]],
        readers: dict[str, dict[str, Any]],
        bound_facts_by_reader: dict[str, set[str]]) -> bool:
    """Recognize a real choice-correlated completion gate from topology.

    A standalone reader cannot repair the source-shadowed helper.  Every
    fresh, re-entry, and loaded completion invocation must execute the same
    seven-way choice/transition group, and each active route modifier must be
    bound to exactly its own durable transition receipt.  This predicate is
    intentionally independent of synthetic mode so a marker ID can never
    subtract debt by itself.
    """
    w24 = next((milestone for _index, milestone, _where in milestone_records
                if milestone.get("week") == 24), None)
    if not isinstance(w24, dict):
        return False
    invocations = {
        invocation.get("invocation_id"): invocation
        for invocation in w24.get("invocations", [])
        if isinstance(invocation, dict)
        and isinstance(invocation.get("invocation_id"), str)}
    choices = (0, 1, 3, 4, 5, 6, 7)
    expected_fact_pairs = {
        choice: {
            "receipt:story_choice:demo_collision:"
            f"v2_demo_first_bill:{choice}",
            "receipt:application_transition:demo_collision:"
            f"v2_demo_first_bill:{choice}",
        } for choice in choices}
    expected_stage_ids = {
        "w24:completion_validation:fresh",
        "w24:completion_validation:reentry",
        "w24:completion_validation:loaded",
    }
    stages = {
        stage.get("stage_id"): stage
        for stage in w24.get("execution_stages", [])
        if isinstance(stage, dict)}
    if not expected_stage_ids.issubset(stages):
        return False
    for stage_id in expected_stage_ids:
        stage_invocations = [
            invocations.get(invocation_id)
            for invocation_id in stages[stage_id].get("invocation_ids", [])
            if isinstance(invocations.get(invocation_id), dict)]
        matching_invocations = [
            invocation for invocation in stage_invocations
            if any(
                isinstance(group, dict)
                and any(
                    isinstance(variant, dict)
                    and bound_facts_by_reader.get(
                        str(variant.get("reader_id")), set())
                        in expected_fact_pairs.values()
                    for variant in group.get("variants", []))
                for group in invocation.get(
                    "exclusive_variant_groups", []))]
        if len(matching_invocations) != 1:
            return False
        invocation = matching_invocations[0]
        if not isinstance(invocation, dict):
            return False
        if any(item.get("reader_id") == W24_COMPLETION_APPLICATION_READER_ID
               for item in invocation.get("conditional_readers", [])
               if isinstance(item, dict)):
            return False
        matching_groups = []
        for group in invocation.get("exclusive_variant_groups", []):
            if not isinstance(group, dict):
                continue
            variant_ids = [
                variant.get("reader_id")
                for variant in group.get("variants", [])
                if isinstance(variant, dict)]
            variant_fact_sets = {
                frozenset(bound_facts_by_reader.get(str(reader_id), set()))
                for reader_id in variant_ids}
            if variant_fact_sets == {
                    frozenset(facts)
                    for facts in expected_fact_pairs.values()}:
                matching_groups.append((group, variant_ids))
        if len(matching_groups) != 1:
            return False
        group, variant_ids = matching_groups[0]
        if (group.get("selection_mode") != "at_most_one"
                or group.get("causal_status") != "active"
                or group.get("debt_id") is not None
                or len(variant_ids) != len(expected_fact_pairs)):
            return False
        for reader_id in variant_ids:
            reader = readers.get(str(reader_id), {})
            reader_facts = bound_facts_by_reader.get(str(reader_id), set())
            matching_choices = [
                choice for choice, facts in expected_fact_pairs.items()
                if reader_facts == facts]
            if (reader.get("status") != "active"
                    or reader.get("reader_kind") != "route_modifier"
                    or reader.get("runtime_pointer") !=
                        "systems/DemoCoreLoopV2.gd::complete_active_bundle"
                    or len(matching_choices) != 1
                    or reader.get("story_decision_ids") != [
                        f"decision:v2_demo_first_bill:"
                        f"{matching_choices[0]}"]):
                return False
    return True


def _decision_contract_is_authored(decision_id: str,
                                   cache: dict[Path, Any]) -> bool:
    if decision_id == "decision:first_temptation_boss":
        contract = _json_pointer_value(
            "content/meta/demo_core_loop_v2.json#/scene_bundles/first_temptation_boss",
            cache)
        return isinstance(contract, dict) and bool(contract)
    if not decision_id.startswith("decision:"):
        return False
    parts = decision_id.removeprefix("decision:").rsplit(":", 1)
    event_id = parts[0]
    choice_index: int | None = None
    if len(parts) == 2 and parts[1].isdigit():
        event_id, choice_index = parts[0], int(parts[1])
    if not AUTHORED_EVENT_CACHE:
        try:
            for path in (CORE_EVENTS_PATH, ROOT / "content/events/arc_events.json"):
                values = json.loads(path.read_text(encoding="utf-8"))
                for item in values if isinstance(values, list) else []:
                    if isinstance(item, dict) and isinstance(item.get("id"), str):
                        AUTHORED_EVENT_CACHE[item["id"]] = item
        except (OSError, json.JSONDecodeError):
            return False
    event = AUTHORED_EVENT_CACHE.get(event_id)
    if not isinstance(event, dict):
        return False
    if choice_index is None:
        return True
    choices = event.get("choices", [])
    return isinstance(choices, list) and 0 <= choice_index < len(choices)


def _reader_input_union(reader_ids: list[str],
                        readers: dict[str, dict[str, Any]]) -> tuple[set[str], set[str]]:
    memories: set[str] = set()
    decisions: set[str] = set()
    for reader_id in reader_ids:
        reader = readers.get(reader_id, {})
        if (reader.get("status") != "active"
                or reader.get("layer_owner") != "story"
                or reader.get("reader_kind") != "story_milestone"):
            continue
        memories.update(value for value in reader.get("history_memory_ids", [])
                        if isinstance(value, str) and value)
        # Synthetic complete-mode W24 reducers hand the two fixed narrative
        # summaries across a real stage edge.  They remain historical axes
        # for the Story fan-in cap even though their temporal ownership is a
        # same-scene handoff rather than prior durable state.
        memories.update(
            value for value in reader.get("scene_handoff_fact_ids", [])
            if value in SYNTHETIC_W24_FANIN_SUMMARY_FACT_IDS)
        decisions.update(value for value in reader.get("story_decision_ids", [])
                         if isinstance(value, str) and value)
        decisions.update(
            value for value in reader.get("scene_handoff_decision_ids", [])
            if value in SYNTHETIC_W24_FIRST_BILL_VALUE_BY_ID)
    return memories, decisions


def _invocation_contract_token(invocation: dict[str, Any]) -> str:
    always = invocation.get("always_reader_ids", [])
    conditionals = invocation.get("conditional_readers", [])
    groups = invocation.get("exclusive_variant_groups", [])
    producers = invocation.get("conditional_producers", [])
    producer_groups = invocation.get("producer_variant_groups", [])
    conditional_ids = [
        item.get("reader_id", "") for item in conditionals
        if isinstance(item, dict)
    ] if isinstance(conditionals, list) else []
    group_tokens: list[str] = []
    if isinstance(groups, list):
        for group in groups:
            if not isinstance(group, dict):
                continue
            variants = group.get("variants", [])
            variant_ids = [
                item.get("reader_id", "") for item in variants
                if isinstance(item, dict)
            ] if isinstance(variants, list) else []
            group_tokens.append(
                f"{group.get('group_id', '')}:{group.get('selection_mode', '')}:"
                + ",".join(variant_ids))
    producer_ids = [
        f"{item.get('variant_id', '')}@{item.get('selection_group_id', '')}"
        for item in producers
        if isinstance(item, dict)
    ] if isinstance(producers, list) else []
    producer_group_tokens = [
        f"{item.get('selection_group_id', '')}:"
        f"{item.get('selection_mode', '')}:"
        f"{item.get('causal_status', '')}"
        for item in producer_groups
        if isinstance(item, dict)
    ] if isinstance(producer_groups, list) else []
    return (
        f"invocation_contract:{invocation.get('invocation_id', '')}"
        f"|always={','.join(always) if isinstance(always, list) else ''}"
        f"|conditional={','.join(conditional_ids)}"
        f"|exclusive={';'.join(group_tokens)}"
        f"|producer_groups={';'.join(producer_group_tokens)}"
        f"|producers={','.join(producer_ids)}")


def _co_presence_contract_token(group: dict[str, Any]) -> str:
    invocation_ids = group.get("invocation_ids", [])
    return (
        f"co_presence_contract:{group.get('group_id', '')}|invocations="
        f"{','.join(invocation_ids) if isinstance(invocation_ids, list) else ''}")


def _execution_stage_contract_token(stage: dict[str, Any]) -> str:
    applicability = stage.get("applicability_ids", [])
    predecessors = stage.get("predecessor_stage_ids", [])
    invocations = stage.get("invocation_ids", [])
    return (
        f"execution_stage:{stage.get('stage_id', '')}"
        f"|order={stage.get('order_index', '')}"
        f"|applicability={','.join(applicability) if isinstance(applicability, list) else ''}"
        f"|predecessors={','.join(predecessors) if isinstance(predecessors, list) else ''}"
        f"|invocations={','.join(invocations) if isinstance(invocations, list) else ''}")


def _execution_stage_scenarios(
        *, week: int, stage_records_by_id: dict[str, dict[str, Any]],
        where: str, synthetic_source_contracts: bool,
        errors: list[str],
) -> list[tuple[frozenset[str], dict[str, set[str]]]]:
    """Return source-compatible stage sets and path-local ancestors.

    A predecessor list is a set of admissible incoming OR edges, not a claim
    that every listed predecessor ran.  For a concrete source scenario we
    select the included predecessor(s) on the latest applicable frontier and
    recurse only through that selected path.  This deliberately differs from
    taking the union of all declared ancestors.

    Production scenarios are checker-owned source truth.  Synthetic complete
    fixtures use their single authored path; that internal escape hatch is not
    exposed by the CLI and does not weaken the frozen production snapshot.
    """
    stage_ids = set(stage_records_by_id)
    expected = EXPECTED_EXECUTION_STAGE_SCENARIOS_BY_WEEK.get(week)
    if synthetic_source_contracts:
        if expected:
            # The internal complete fixture reuses the audited W4-W24 source
            # graph.  Preserve every real scenario so path-local variants and
            # temporal roles stay proven; only synthetic W28-W48 milestones
            # fall through to their one authored fixture path below.
            aggregate_prefix = "w24:synthetic_fanin_aggregate:"
            summary_prefix = "w24:synthetic_fanin_summary:"
            aggregate_stages = {
                stage_id.removeprefix(aggregate_prefix): stage_id
                for stage_id in stage_ids
                if stage_id.startswith(aggregate_prefix)}
            summary_stages = {
                stage_id.removeprefix(summary_prefix): stage_id
                for stage_id in stage_ids
                if stage_id.startswith(summary_prefix)}
            if week == 24 and aggregate_stages:
                raw_scenarios = [
                    tuple([
                        *scenario,
                        *(aggregate_stage_id
                          for original_stage_id, aggregate_stage_id
                          in sorted(aggregate_stages.items())
                          if original_stage_id in scenario),
                        *(summary_stage_id
                          for original_stage_id, summary_stage_id
                          in sorted(summary_stages.items())
                          if original_stage_id in scenario),
                    ])
                    for scenario in expected]
            elif (week == 4
                  and "w04:synthetic_opening_application_core_owner"
                      in stage_ids):
                raw_scenarios = [
                    tuple([
                        "w04:synthetic_opening_application_core_owner",
                        *scenario,
                    ]) for scenario in expected]
            else:
                raw_scenarios = expected
        else:
            ordered: list[str] = []
            included: set[str] = set()
            by_order: dict[int, list[str]] = {}
            for stage_id, stage in stage_records_by_id.items():
                if _is_int(stage.get("order_index")):
                    by_order.setdefault(
                        int(stage["order_index"]), []).append(stage_id)
            for order_index in sorted(by_order):
                candidates = sorted(by_order[order_index])
                selected = next((
                    stage_id for stage_id in candidates
                    if not stage_records_by_id[stage_id].get(
                        "predecessor_stage_ids", [])
                    or set(stage_records_by_id[stage_id].get(
                        "predecessor_stage_ids", [])) & included), None)
                if selected is not None:
                    ordered.append(selected)
                    included.add(selected)
            raw_scenarios = [tuple(ordered)] if ordered else []
    elif EXPECTED_EXECUTION_STAGE_SCENARIOS_BY_WEEK:
        if expected is None:
            errors.append(
                f"{where}: missing audited source scenario contract for W{week}")
            raw_scenarios = []
        else:
            raw_scenarios = expected
    else:
        # Coordinated-candidate construction only.  REVIEW LOCK populates the
        # source scenario map; until then the ledger is intentionally not a
        # freeze candidate.
        raw_scenarios = [tuple(sorted(stage_ids))] if stage_ids else []

    normalized: list[frozenset[str]] = []
    seen_scenarios: set[frozenset[str]] = set()
    for scenario_index, raw_scenario in enumerate(raw_scenarios):
        scenario_where = f"{where}.source_scenarios[{scenario_index}]"
        if (not isinstance(raw_scenario, (list, tuple))
                or not all(isinstance(item, str) and item
                           for item in raw_scenario)):
            errors.append(f"{scenario_where}: expected stage ID array")
            continue
        scenario = frozenset(raw_scenario)
        if len(scenario) != len(raw_scenario):
            errors.append(f"{scenario_where}: duplicate stage ID")
        unknown = scenario - stage_ids
        if unknown:
            errors.append(
                f"{scenario_where}: unknown stages {sorted(unknown)}")
            continue
        if scenario in seen_scenarios:
            errors.append(f"{scenario_where}: duplicate source scenario")
            continue
        seen_scenarios.add(scenario)
        normalized.append(scenario)

    if stage_ids and not normalized:
        errors.append(f"{where}: no executable source scenario")
    uncovered = stage_ids - set().union(*normalized) if normalized else stage_ids
    if uncovered:
        errors.append(
            f"{where}: stages absent from every source scenario "
            f"{sorted(uncovered)}")

    resolved: list[tuple[frozenset[str], dict[str, set[str]]]] = []
    for scenario_index, scenario in enumerate(normalized):
        scenario_where = f"{where}.source_scenarios[{scenario_index}]"
        by_order: dict[int, list[str]] = {}
        for stage_id in scenario:
            order_index = stage_records_by_id.get(stage_id, {}).get(
                "order_index")
            if _is_int(order_index):
                by_order.setdefault(int(order_index), []).append(stage_id)
        for order_index, same_order_ids in by_order.items():
            if len(same_order_ids) > 1:
                errors.append(
                    f"{scenario_where}: mutually-exclusive same-order "
                    f"stages coexist at {order_index}: "
                    f"{sorted(same_order_ids)}")

        ancestor_cache: dict[str, set[str]] = {}
        visiting: set[str] = set()

        def selected_ancestors(stage_id: str) -> set[str]:
            if stage_id in ancestor_cache:
                return ancestor_cache[stage_id]
            if stage_id in visiting:
                errors.append(
                    f"{scenario_where}: predecessor cycle at {stage_id}")
                return set()
            visiting.add(stage_id)
            stage = stage_records_by_id.get(stage_id, {})
            declared_predecessors = stage.get("predecessor_stage_ids", [])
            if not isinstance(declared_predecessors, list):
                declared_predecessors = []
            included_predecessors = [
                predecessor_id for predecessor_id in declared_predecessors
                if predecessor_id in scenario]
            ancestors: set[str] = set()
            if declared_predecessors:
                if not included_predecessors:
                    errors.append(
                        f"{scenario_where}: included stage {stage_id} has no "
                        "included legal predecessor")
                else:
                    valid_orders = [
                        stage_records_by_id.get(predecessor_id, {}).get(
                            "order_index")
                        for predecessor_id in included_predecessors]
                    valid_orders = [
                        int(value) for value in valid_orders
                        if _is_int(value)]
                    latest_order = max(valid_orders) if valid_orders else None
                    selected_predecessors = [
                        predecessor_id
                        for predecessor_id in included_predecessors
                        if latest_order is not None
                        and stage_records_by_id.get(
                            predecessor_id, {}).get("order_index")
                        == latest_order]
                    if len(selected_predecessors) != 1:
                        errors.append(
                            f"{scenario_where}: stage {stage_id} must attach "
                            "to exactly one latest applicable predecessor")
                    for predecessor_id in selected_predecessors:
                        ancestors.add(predecessor_id)
                        ancestors.update(selected_ancestors(predecessor_id))
            visiting.discard(stage_id)
            ancestor_cache[stage_id] = ancestors
            return ancestors

        for stage_id in scenario:
            selected_ancestors(stage_id)
        resolved.append((scenario, ancestor_cache))
    return resolved


def _repeat_contract_has_cost_and_effect(
        row: dict[str, Any], cache: dict[Path, Any]) -> bool:
    cost = row.get("cost", {})
    terminal = row.get("terminal_contract", {})
    reentry = terminal.get("reentry_cost")
    if (not _is_int(cost.get("weekly_capacity"))
            or cost["weekly_capacity"] <= 0
            or not isinstance(reentry, dict)
            or not _is_int(reentry.get("weekly_capacity"))
            or reentry["weekly_capacity"] <= 0):
        return False
    pointers = cost.get("effect_pointers")
    if not isinstance(pointers, list) or not pointers:
        return False
    for pointer in pointers:
        value = _json_pointer_value(pointer, cache) if isinstance(pointer, str) else None
        if isinstance(value, (dict, list)) and value:
            return True
    return False


def _effect_keys(value: Any) -> set[str]:
    if not isinstance(value, dict):
        return set()
    result: set[str] = set()
    for key, child in value.items():
        if isinstance(child, dict):
            result.update(_effect_keys(child))
        elif isinstance(child, (int, float)) and not isinstance(child, bool):
            result.add(str(key))
    return result


def _row_trigger_bundles(row: dict[str, Any]) -> list[str]:
    availability = row.get("availability", {})
    bundles = list(availability.get("trigger_bundle_ids", [])) \
        if isinstance(availability.get("trigger_bundle_ids"), list) else []
    fallback = availability.get("fallback_trigger_bundle_id")
    if isinstance(fallback, str) and fallback and fallback not in bundles:
        bundles.append(fallback)
    return bundles


def _expected_trigger_windows_by_bundle(
        row: dict[str, Any], cache: dict[Path, Any]) -> dict[str, dict[str, Any]]:
    """Mirror every selected bundle's authored week window in month-relative form."""
    month = row.get("month")
    if not _is_int(month):
        return {}
    month_start = ((month - 1) * 4) + 1
    result: dict[str, dict[str, int]] = {}
    for bundle_id in _row_trigger_bundles(row):
        bundle = _json_pointer_value(
            f"content/meta/demo_core_loop_v2.json#/scene_bundles/{bundle_id}",
            cache)
        raw_weeks = bundle.get("allowed_weeks", []) \
            if isinstance(bundle, dict) else []
        allowed_weeks = [
            week for week in raw_weeks
            if _is_int(week) and month_start <= week <= month_start + 3
        ] if isinstance(raw_weeks, list) else []
        if not allowed_weeks:
            continue
        result[bundle_id] = {
            "relative_weeks": [
                week - month_start + 1 for week in allowed_weeks],
            "min_relative_week": min(allowed_weeks) - month_start + 1,
            "max_relative_week": max(allowed_weeks) - month_start + 1,
        }
    return result


def _row_can_lock_without_eligible(
        row: dict[str, Any], node: dict[str, Any],
        cache: dict[Path, Any]) -> bool:
    """True only when every authored trigger candidate can fail eligibility."""
    bundles = _row_trigger_bundles(row)
    if not node.get("disable_without_trigger", False) or not bundles:
        return False
    for bundle_id in bundles:
        prerequisites = _json_pointer_value(
            "content/meta/demo_core_loop_v2.json#/scene_bundles/"
            f"{bundle_id}/prerequisites", cache)
        if (not isinstance(prerequisites, dict)
                or not any(prerequisites.get(key) for key in ("all", "any"))):
            return False
    return True


def _expected_expiry_receipts_and_consequences(
        row: dict[str, Any], node: dict[str, Any]) -> tuple[list[str], list[str]]:
    """Return both trigger-scope and terminal expiry outputs in runtime order."""
    node_id = str(row.get("node_id", ""))
    receipts: list[str] = []
    consequences: list[str] = []
    if node.get("fallback_after_trigger_expiry", False):
        receipts.append(f"receipt:trigger_expiry:{node_id}")
        consequences.append(str(node.get(
            "trigger_expiry_consequence",
            f"{node_id}_opportunity_missed")))
    receipts.append(f"receipt:expiry:{node_id}")
    consequences.append(str(node.get(
        "expiry_consequence", f"{node_id}_expired")))
    return receipts, consequences


def _expected_month_summary_facts(
        month: int, rows: list[dict[str, Any]]) -> list[str]:
    """Mirror the exact three receipt maps copied into one month summary."""
    month_rows = [
        row for row in rows
        if isinstance(row, dict) and row.get("month") == month]
    result = [
        f"receipt:allocation:{row.get('chain_id')}" for row in month_rows
        if isinstance(row.get("chain_id"), str)]
    for row in month_rows:
        result.extend(
            f"receipt:trigger:{bundle_id}"
            for bundle_id in _row_trigger_bundles(row))
    for row in month_rows:
        producer = row.get("producer", {})
        expiry_ids = producer.get("expiry_receipt_ids", []) \
            if isinstance(producer, dict) else []
        if isinstance(expiry_ids, list):
            result.extend(
                fact_id for fact_id in expiry_ids
                if isinstance(fact_id, str) and fact_id)
    return result


def _expected_completion_receipts(
        row: dict[str, Any], cache: dict[Path, Any]) -> list[str]:
    chain_id = str(row.get("chain_id", ""))
    bundles = _row_trigger_bundles(row)
    if row.get("slot_owner") == "people" and chain_id != "m1_father":
        return [
            f"receipt:trigger:{chain_id}",
            *(f"receipt:completed:{bundle_id}" for bundle_id in bundles),
        ]
    if not bundles:
        return [f"receipt:allocation:{chain_id}"]
    result: list[str] = []
    for bundle_id in bundles:
        bundle = _json_pointer_value(
            f"content/meta/demo_core_loop_v2.json#/scene_bundles/{bundle_id}",
            cache)
        if not isinstance(bundle, dict):
            continue
        result.append(f"receipt:trigger:{bundle_id}")
        result.append(f"receipt:completed:{bundle_id}")
        action_config = bundle.get("action_config", {})
        application_receipt = ""
        if (isinstance(action_config, dict)
                and action_config.get("execution") == "application"):
            application_id = action_config.get("application_id")
            status = action_config.get("status")
            if isinstance(application_id, str) and isinstance(status, str):
                application_receipt = (
                    f"receipt:application:{application_id}:{status}")
        for outcome in bundle.get("application_outcomes", []):
            if not isinstance(outcome, dict):
                continue
            application_id = outcome.get("application_id")
            status = outcome.get("to")
            if isinstance(application_id, str) and isinstance(status, str):
                application_receipt = (
                    f"receipt:application:{application_id}:{status}")
                break
        action_id = bundle.get("action_id")
        # Single application actions commit their application before the
        # generic action presentation receipt.  M4's multi-route resolver
        # records each chosen action first, matching its exact runtime branch.
        if application_receipt and chain_id != "m4_advancement":
            result.append(application_receipt)
        if isinstance(action_id, str) and action_id:
            result.append(f"receipt:action:{bundle_id}")
        if application_receipt and chain_id == "m4_advancement":
            result.append(application_receipt)
        application_outcomes = bundle.get("application_outcomes", [])
        if isinstance(application_outcomes, list):
            for outcome in application_outcomes:
                if not isinstance(outcome, dict):
                    continue
                event_id = outcome.get("event_id")
                choices = outcome.get("choices", [])
                if (not isinstance(event_id, str) or not event_id
                        or not isinstance(choices, list)):
                    continue
                for choice_index in choices:
                    if _is_int(choice_index):
                        result.append(
                            "receipt:application_transition:"
                            f"{bundle_id}:{event_id}:{choice_index}")
        if isinstance(bundle.get("relationship_outcomes"), list) \
                and bundle.get("relationship_outcomes"):
            result.append(f"receipt:relationship:{bundle_id}")
        if chain_id == "m1_resume":
            result.insert(len(result) - (1 if action_id else 0),
                          "fact:resume_polished")
    return result


def _expected_state_delta_keys(
        row: dict[str, Any], cache: dict[Path, Any]) -> list[str]:
    """Project exact persisted producer outputs onto normalized state keys."""
    node = _json_pointer_value(str(row.get("runtime_pointer", "")), cache)
    keys: set[str] = set()
    if isinstance(node, dict):
        for field in (
                "allocation_effects", "allocation_effects_by_progress",
                "completion_effects", "expiry_effects"):
            keys.update(_effect_keys(node.get(field, {})))
    for bundle_id in _row_trigger_bundles(row):
        bundle = _json_pointer_value(
            f"content/meta/demo_core_loop_v2.json#/scene_bundles/{bundle_id}",
            cache)
        if not isinstance(bundle, dict):
            continue
        config = bundle.get("action_config", {})
        if isinstance(config, dict):
            keys.update(_effect_keys(config.get("effects", {})))
            keys.update(_effect_keys(config.get("recovery_routine_effects", {})))
    expected_completion = _expected_completion_receipts(row, cache)
    for fact_id in expected_completion:
        if fact_id.startswith("receipt:completed:"):
            keys.add(f"completed_bundle:{fact_id.split(':', 2)[2]}")
        elif fact_id.startswith("receipt:application:"):
            parts = fact_id.split(":")
            if len(parts) >= 4:
                keys.add(f"application_status:{parts[2]}")
        elif fact_id == "fact:resume_polished":
            keys.add("resume_polished")

    variants, _groups = _expected_output_variants_and_groups(row, cache)
    for variant in variants:
        facts = variant.get("produced_fact_ids", [])
        relationship_characters = {
            fact_id.split(":")[2]
            for fact_id in facts
            if isinstance(fact_id, str)
            and fact_id.startswith("state:relationship:")
            and len(fact_id.split(":")) >= 4
        }
        for fact_id in facts:
            if not isinstance(fact_id, str):
                continue
            if fact_id.startswith("receipt:story_choice:"):
                keys.add("story_choice_receipt")
            elif fact_id == "state:events_seen:+1":
                keys.add("events_seen")
            elif fact_id.startswith("state:flag:"):
                keys.add(f"flag:{fact_id.removeprefix('state:flag:')}")
            elif fact_id.startswith("state:cast:"):
                parts = fact_id.split(":")
                if len(parts) >= 4 and parts[3] == "met":
                    keys.add(f"cast_met:{parts[2]}")
                elif len(parts) >= 5 and parts[3] == "stage":
                    keys.add(f"cast_stage:{parts[2]}")
                elif len(parts) >= 5 and parts[3] == "flag":
                    keys.add(f"cast_flag:{parts[2]}:{':'.join(parts[4:])}")
            elif fact_id.startswith("state:item:"):
                keys.add(f"item:{fact_id.removeprefix('state:item:')}")
            elif fact_id.startswith("receipt:relationship_history:"):
                for character in relationship_characters:
                    keys.add(f"relationship_history:{character}")
            elif fact_id.startswith("receipt:relationship_choice:"):
                keys.add(
                    "relationship_choice_receipt:"
                    + fact_id.removeprefix("receipt:relationship_choice:"))
            elif fact_id.startswith("state:relationship:"):
                parts = fact_id.split(":")
                if len(parts) >= 4:
                    keys.add(f"relationship_stage:{parts[2]}")
            elif fact_id.startswith("memory:"):
                keys.add(
                    "relationship_memory:"
                    + fact_id.removeprefix("memory:"))
            elif fact_id.startswith("state:player_initiated:"):
                keys.add(
                    "player_initiated:"
                    + fact_id.removeprefix("state:player_initiated:"))
            elif fact_id.startswith("state:legacy_callback_resolution:"):
                keys.add(
                    "legacy_callback_resolution:"
                    + fact_id.removeprefix(
                        "state:legacy_callback_resolution:"))
            elif fact_id.startswith("receipt:application:"):
                parts = fact_id.split(":")
                if len(parts) >= 4:
                    keys.add(f"application_status:{parts[2]}")
            elif fact_id.startswith("receipt:application_transition:"):
                keys.add(
                    "application_transition_receipt:"
                    + fact_id.removeprefix(
                        "receipt:application_transition:"))
            elif fact_id.startswith("receipt:future_story:"):
                suffix = fact_id.removeprefix("receipt:future_story:")
                keys.add("future_story_receipt:" + suffix)
            elif fact_id.startswith("activity_task_outcome:"):
                keys.add(
                    "activity_task_outcome:"
                    + fact_id.rsplit(":", 1)[-1])
            elif fact_id == "fact:resume_polished":
                keys.add("resume_polished")
            elif fact_id.startswith("state:tendency:"):
                parts = fact_id.split(":")
                if len(parts) >= 4:
                    keys.add(f"tendency:{parts[2]}")

        for effect_id in variant.get("effect_contract_ids", []):
            if not isinstance(effect_id, str):
                continue
            effect_match = re.search(r":effects\.([^.:]+)$", effect_id)
            if effect_match:
                effect_key = effect_match.group(1)
                keys.add({"stress": "mental", "tint": "moral_tint"}.get(
                    effect_key, effect_key))
            cast_match = re.search(
                r":cast_effects\.([^.:]+)\.affinity$", effect_id)
            if cast_match:
                keys.add(f"cast_affinity:{cast_match.group(1)}")
            if effect_id.startswith("effect:m1_resume:quality:"):
                keys.add("intelligence")
            if effect_id == "effect:m1_resume:stress_delta:runtime":
                keys.add("mental")
            if effect_id == "effect:m1_resume:tendency:career:+1":
                keys.add("tendency:career")
            if ":aruba:" in effect_id:
                for key in ("money", "mental", "health"):
                    if f":{key}:" in effect_id:
                        keys.add(key)
    return sorted(keys)


def _bundle_application_receipt(bundle: dict[str, Any]) -> str:
    action_config = bundle.get("action_config", {})
    if (isinstance(action_config, dict)
            and action_config.get("execution") == "application"):
        application_id = action_config.get("application_id")
        status = action_config.get("status")
        if all(isinstance(value, str) and value
               for value in (application_id, status)):
            return f"receipt:application:{application_id}:{status}"
    outcomes = bundle.get("application_outcomes", [])
    if isinstance(outcomes, list):
        authored = {
            (item.get("application_id"), item.get("to"))
            for item in outcomes if isinstance(item, dict)}
        authored.discard((None, None))
        if len(authored) == 1:
            application_id, status = next(iter(authored))
            if all(isinstance(value, str) and value
                   for value in (application_id, status)):
                return f"receipt:application:{application_id}:{status}"
    return ""


def _expected_bundle_branch_facts(
        row: dict[str, Any], bundle_id: str, cache: dict[Path, Any], *,
        resume_polished: bool = False) -> list[str]:
    """Derive one completion branch's exact persisted outputs from source data."""
    bundle = _json_pointer_value(
        f"content/meta/demo_core_loop_v2.json#/scene_bundles/{bundle_id}",
        cache)
    if not isinstance(bundle, dict):
        return []
    chain_id = str(row.get("chain_id", ""))
    result = [
        f"receipt:trigger:{bundle_id}",
        f"receipt:completed:{bundle_id}",
    ]
    if chain_id == "m1_resume" and resume_polished:
        result.append("fact:resume_polished")
    application_receipt = _bundle_application_receipt(bundle)
    action_id = bundle.get("action_id")
    if application_receipt and chain_id != "m4_advancement":
        result.append(application_receipt)
    if isinstance(action_id, str) and action_id:
        result.append(f"receipt:action:{bundle_id}")
    if application_receipt and chain_id == "m4_advancement":
        result.append(application_receipt)
    relationship_outcomes = bundle.get("relationship_outcomes", [])
    if isinstance(relationship_outcomes, list) and relationship_outcomes:
        result.append(f"receipt:relationship:{bundle_id}")
    return result


def _expected_bundle_branch_proofs(
        row: dict[str, Any], bundle_id: str, cache: dict[Path, Any], *,
        resume_quality: bool = False) -> list[str]:
    bundle = _json_pointer_value(
        f"content/meta/demo_core_loop_v2.json#/scene_bundles/{bundle_id}",
        cache)
    if not isinstance(bundle, dict):
        return []
    chain_id = str(row.get("chain_id", ""))
    result = [f"proof:row:{chain_id}"]
    if row.get("slot_owner") == "people" and chain_id != "m1_father":
        result.append("proof:runtime:first_eligible_person")
    result.extend([
        "proof:runtime:bundle_completion",
        "proof:runtime:trigger_resolution",
    ])
    if bundle.get("application_outcomes"):
        result.append("proof:runtime:application_receipt")
    if bundle.get("relationship_outcomes"):
        result.append("proof:runtime:relationship_receipt")
    action_id = bundle.get("action_id")
    if isinstance(action_id, str) and action_id:
        result.extend([
            "proof:runtime:action_commitment",
            "proof:runtime:action_receipt",
        ])
        action_config = bundle.get("action_config", {})
        if (isinstance(action_config, dict)
                and action_config.get("execution") == "activity_task"):
            result.append("proof:runtime:activity_receipt")
    if resume_quality:
        result.append("proof:runtime:resume_quality_outcome")
    return result


def _expected_nested_output_group_ids(
        row: dict[str, Any], bundle_id: str,
        cache: dict[Path, Any]) -> list[str]:
    """Bind a weekly bundle route to its row-local conditional outputs.

    A branch owns only the facts common to entering/completing the bundle.
    Story decisions and action-result alternatives remain nested producer
    groups, preserving layer ownership without erasing realized outcomes.
    """
    variants, groups = _expected_output_variants_and_groups(row, cache)
    bundle_activation = f"bundle:{bundle_id}"
    group_ids = {
        variant.get("selection_group_id") for variant in variants
        if isinstance(variant, dict)
        and bundle_activation in variant.get("activation_ids", [])}
    return [
        str(group.get("selection_group_id")) for group in groups
        if isinstance(group, dict)
        and group.get("selection_group_id") in group_ids]


def _row_output_variant_graph(
        row: dict[str, Any]
        ) -> tuple[dict[str, dict[str, Any]], dict[str, list[dict[str, Any]]]]:
    """Index one row's conditional producer graph without trusting its IDs.

    The registry remains source-validated elsewhere.  This index is used to
    prove that a weekly branch references only row-local groups and to expand
    the branch into the concrete result sets that can actually be realized.
    """
    producer = row.get("producer", {})
    raw_groups = producer.get("output_variant_groups", []) \
        if isinstance(producer, dict) else []
    raw_variants = producer.get("conditional_output_variants", []) \
        if isinstance(producer, dict) else []
    groups = {
        str(group.get("selection_group_id")): group
        for group in raw_groups
        if isinstance(group, dict)
        and isinstance(group.get("selection_group_id"), str)
        and group.get("selection_group_id")
    } if isinstance(raw_groups, list) else {}
    variants_by_group: dict[str, list[dict[str, Any]]] = {
        group_id: [] for group_id in groups}
    if isinstance(raw_variants, list):
        for variant in raw_variants:
            if not isinstance(variant, dict):
                continue
            group_id = variant.get("selection_group_id")
            if isinstance(group_id, str):
                variants_by_group.setdefault(group_id, []).append(variant)
    return groups, variants_by_group


def _variant_story_choice(
        variant: dict[str, Any]) -> tuple[str, int] | None:
    for activation_id in variant.get("activation_ids", []):
        if not isinstance(activation_id, str) \
                or not activation_id.startswith("story_choice:"):
            continue
        raw = activation_id.removeprefix("story_choice:").rsplit(":", 1)
        if len(raw) == 2 and raw[0] and raw[1].isdigit():
            return raw[0], int(raw[1])
    return None


def _story_follow_up_parents(
        bundle_id: str, cache: dict[Path, Any]
        ) -> tuple[set[str], dict[str, set[tuple[str, int]]]]:
    """Return source-owned root events and exact choice→follow-up edges."""
    roots: set[str] = set()
    parents: dict[str, set[tuple[str, int]]] = {}
    for event_id, event, is_root in _bundle_story_choice_graph(
            bundle_id, cache):
        if is_root:
            roots.add(event_id)
        choices = event.get("choices", [])
        if not isinstance(choices, list):
            continue
        for choice_index, choice in enumerate(choices):
            if not isinstance(choice, dict):
                continue
            follow_up = choice.get("follow_up_event")
            if isinstance(follow_up, str) and follow_up:
                parents.setdefault(follow_up, set()).add(
                    (event_id, choice_index))
    return roots, parents


def _branch_compatible_variants(
        branch_contract: dict[str, Any], group_id: str,
        variants: list[dict[str, Any]]) -> list[dict[str, Any]]:
    """Return row-local results without promoting inner choices to routes.

    Weekly branches own board completion/expiry alternatives.  Resume grade,
    Story choices and every other action result remain nested output groups;
    no inner result is permitted to split or rename the weekly route.
    """
    del branch_contract, group_id
    return variants


def _branch_realized_outputs(
        row: dict[str, Any], branch_contract: dict[str, Any],
        cache: dict[Path, Any]
        ) -> list[tuple[frozenset[str], frozenset[str]]]:
    """Enumerate reachable branch×nested-variant facts and exact effects.

    This is intentionally not a union.  Mutually exclusive Story decisions or
    action results must remain separate histories.  Follow-up Story choices
    require their exact parent choice, and producer-to-producer activation
    facts (for example Hyunsu's selected memory) must be present in the chosen
    predecessor outputs before the dependent variant is reachable.
    """
    common = frozenset(
        fact_id for fact_id in branch_contract.get("produced_fact_ids", [])
        if isinstance(fact_id, str) and fact_id)
    nested_ids = branch_contract.get("nested_output_group_ids", [])
    if not isinstance(nested_ids, list) or not nested_ids:
        return [(common, frozenset())]
    groups, variants_by_group = _row_output_variant_graph(row)
    applicability = {
        value for value in branch_contract.get("applicability_ids", [])
        if isinstance(value, str)}
    bundle_tokens = sorted(
        value for value in applicability if value.startswith("bundle:"))
    if len(bundle_tokens) != 1:
        return []
    bundle_id = bundle_tokens[0].removeprefix("bundle:")
    _roots, follow_up_parents = _story_follow_up_parents(bundle_id, cache)
    all_nested_outputs = {
        fact_id
        for group_id in nested_ids
        for variant in variants_by_group.get(group_id, [])
        for fact_id in variant.get("produced_fact_ids", [])
        if isinstance(fact_id, str) and fact_id
    }
    states: list[tuple[
        frozenset[str], frozenset[str], frozenset[tuple[str, int]]]] = [
            (common, frozenset(), frozenset())]
    for group_id in nested_ids:
        group = groups.get(group_id)
        variants = _branch_compatible_variants(
            branch_contract, group_id,
            variants_by_group.get(group_id, []))
        if not isinstance(group, dict) or not variants:
            return []
        mode = group.get("selection_mode")
        if mode not in {"at_most_one", "exactly_one"}:
            return []
        next_states: list[
            tuple[frozenset[str], frozenset[str],
                  frozenset[tuple[str, int]]]] = []
        for facts, effects, selected_choices in states:
            eligible: list[dict[str, Any]] = []
            for variant in variants:
                activation_ids = {
                    value for value in variant.get("activation_ids", [])
                    if isinstance(value, str)}
                if bundle_tokens[0] not in activation_ids:
                    continue
                story_choice = _variant_story_choice(variant)
                if story_choice is not None:
                    event_id, _choice_index = story_choice
                    parent_choices = follow_up_parents.get(event_id)
                    if parent_choices and not (
                            parent_choices & set(selected_choices)):
                        continue
                    if any(selected_event == event_id
                           for selected_event, _ in selected_choices):
                        continue
                # A durable activation authored by another nested group must
                # actually have been produced by the selected predecessor.
                cross_group_activations = (
                    activation_ids & all_nested_outputs)
                if not cross_group_activations.issubset(facts):
                    continue
                eligible.append(variant)

            # `at_most_one` describes whether this conditional event is
            # entered at all.  Once its parent/cross-output gate is satisfied,
            # the event itself has an authored choice and exactly one eligible
            # variant must execute.  A `None` history is valid only while no
            # variant is activated.
            if not eligible:
                if mode == "at_most_one":
                    next_states.append((facts, effects, selected_choices))
                continue
            for variant in eligible:
                story_choice = _variant_story_choice(variant)
                produced = frozenset(
                    value for value in variant.get("produced_fact_ids", [])
                    if isinstance(value, str) and value)
                variant_effects = frozenset(
                    value for value in variant.get("effect_contract_ids", [])
                    if isinstance(value, str) and value)
                selected = selected_choices
                if story_choice is not None:
                    selected = frozenset((*selected_choices, story_choice))
                next_states.append((
                    facts | produced, effects | variant_effects, selected))
        # Preserve exact semantics while preventing duplicate histories from
        # multiplying work in the cafe follow-up graph.
        states = list(dict.fromkeys(next_states))
        if not states:
            return []
    return list(dict.fromkeys(
        (facts, effects) for facts, effects, _ in states))


def _branch_realized_fact_sets(
        row: dict[str, Any], branch_contract: dict[str, Any],
        cache: dict[Path, Any]) -> list[frozenset[str]]:
    """Return only the fact projection of exact realized branch outputs."""
    return list(dict.fromkeys(
        facts for facts, _effects in _branch_realized_outputs(
            row, branch_contract, cache)))


def _validate_nested_branch_contract(
        row: dict[str, Any], branch_contract: dict[str, Any],
        where: str, errors: list[str], cache: dict[Path, Any]) \
        -> list[frozenset[str]]:
    """Validate row-local nested ownership and return realized histories."""
    nested_ids = branch_contract.get("nested_output_group_ids", [])
    if not isinstance(nested_ids, list):
        return []
    if len(nested_ids) != len(set(nested_ids)):
        errors.append(
            f"{where}.nested_output_group_ids: duplicate nested group")
    groups, variants_by_group = _row_output_variant_graph(row)
    outcome = branch_contract.get("outcome_kind")
    if outcome != "completed" and nested_ids:
        errors.append(
            f"{where}.nested_output_group_ids: expired/locked route cannot own result groups")
    bundle_tokens = [
        value for value in branch_contract.get("applicability_ids", [])
        if isinstance(value, str) and value.startswith("bundle:")]
    if nested_ids and len(bundle_tokens) != 1:
        errors.append(
            f"{where}.nested_output_group_ids: nested results need one exact bundle applicability")
    bundle_token = bundle_tokens[0] if len(bundle_tokens) == 1 else ""
    common = {
        value for value in branch_contract.get("produced_fact_ids", [])
        if isinstance(value, str)}
    for group_id in nested_ids:
        group = groups.get(group_id)
        variants = variants_by_group.get(group_id, [])
        if not isinstance(group, dict) or not variants:
            errors.append(
                f"{where}.nested_output_group_ids: group is not row-local")
            continue
        compatible = _branch_compatible_variants(
            branch_contract, group_id, variants)
        if not compatible:
            errors.append(
                f"{where}.nested_output_group_ids: no branch-compatible variant")
            continue
        if any(bundle_token not in variant.get("activation_ids", [])
               for variant in compatible):
            errors.append(
                f"{where}.nested_output_group_ids: variant is not activated by branch bundle")
        fact_sets = [
            {value for value in variant.get("produced_fact_ids", [])
             if isinstance(value, str)}
            for variant in compatible]
        variant_union = set().union(*fact_sets) if fact_sets else set()
        variant_common = set.intersection(*fact_sets) if fact_sets else set()
        if common & (variant_union - variant_common):
            errors.append(
                f"{where}.produced_fact_ids: mutually exclusive sibling output was laundered into weekly branch")
    realized = _branch_realized_fact_sets(row, branch_contract, cache)
    if nested_ids and not realized:
        errors.append(
            f"{where}.nested_output_group_ids: no reachable branch×variant result")
    return realized


def _freeze_semantic_value(value: Any) -> Any:
    if isinstance(value, dict):
        return tuple((str(key), _freeze_semantic_value(child))
                     for key, child in sorted(value.items()))
    if isinstance(value, list):
        return tuple(_freeze_semantic_value(child) for child in value)
    return value


def _nested_effect_semantic_value(
        effect_id: str, cache: dict[Path, Any]) -> tuple[Any, ...] | None:
    """Resolve an effect token to its value, never its choice/variant ID.

    Facts need a named reader before they count as route evidence.  Numeric and
    gameplay effects are intrinsically observable, but their source IDs alone
    are not: two choices that both add one event or the same stat delta remain
    semantically equal here.
    """
    quality = re.fullmatch(r"effect:m1_resume:quality:(\d+)", effect_id)
    if quality:
        return ("intelligence", (0, 0, 1, 2)[int(quality.group(1))])
    if effect_id == "effect:m1_resume:stress_delta:runtime":
        return ("mental", "job_hunt_score_formula")
    if effect_id == "effect:m1_resume:tendency:career:+1":
        return ("tendency:career", 1)
    aruba = re.fullmatch(
        r"effect:[^:]+:aruba:([^:]+):(.+)", effect_id)
    if aruba:
        return (aruba.group(1), aruba.group(2))
    configured = re.fullmatch(
        r"effect:([^:]+):action_config\.([^:]+):([+-]?[0-9.]+)",
        effect_id)
    if configured:
        try:
            value: int | float = float(configured.group(3))
            if value.is_integer():
                value = int(value)
        except ValueError:
            return None
        key = configured.group(2).rsplit(".", 1)[-1]
        return ({"stress": "mental", "tint": "moral_tint"}.get(
            key, key), value)
    activity = re.fullmatch(
        r"effect:([^:]+):action_config:([^:]+)\.effects\.([^:]+)",
        effect_id)
    if activity:
        bundle_id, source_path, effect_key = activity.groups()
        value: Any = _json_pointer_value(
            "content/meta/demo_core_loop_v2.json#/scene_bundles/"
            f"{bundle_id}/action_config", cache)
        for token in source_path.split("."):
            value = value.get(token) if isinstance(value, dict) else None
        value = value.get("effects", {}).get(effect_key) \
            if isinstance(value, dict) else None
        return ({"stress": "mental", "tint": "moral_tint"}.get(
            effect_key, effect_key), _freeze_semantic_value(value))
    story = re.fullmatch(
        r"effect:([^:]+):choice:(\d+):(.+)", effect_id)
    if story:
        event_id, raw_index, source_path = story.groups()
        event = _trusted_event_index(cache).get(event_id, {})
        choices = event.get("choices", []) if isinstance(event, dict) else []
        choice_index = int(raw_index)
        choice = choices[choice_index] \
            if isinstance(choices, list) and choice_index < len(choices) \
            and isinstance(choices[choice_index], dict) else {}
        if source_path == "events_seen":
            return ("events_seen", 1)
        if source_path.startswith("effects."):
            key = source_path.removeprefix("effects.")
            value = choice.get("effects", {}).get(key) \
                if isinstance(choice.get("effects"), dict) else None
            return ({"stress": "mental", "tint": "moral_tint"}.get(
                key, key), _freeze_semantic_value(value))
        cast = re.fullmatch(
            r"cast_effects\.([^.]+)\.(met|affinity|stage)",
            source_path)
        if cast:
            character, field = cast.groups()
            value = choice.get("cast_effects", {}).get(character, {}).get(
                field) if isinstance(choice.get("cast_effects"), dict) else None
            return (f"cast:{character}:{field}",
                    _freeze_semantic_value(value))
        # Flags, items, relationship/application receipts and callbacks count
        # only through exact named-reader fact evidence below.
        return None
    return None


def _branch_direct_effect_signature(
        row: dict[str, Any], branch_contract: dict[str, Any],
        cache: dict[Path, Any]) -> tuple[Any, ...]:
    node = _json_pointer_value(str(row.get("runtime_pointer", "")), cache)
    outcome = branch_contract.get("outcome_kind")
    values: list[tuple[Any, ...]] = []
    if isinstance(node, dict):
        field = "completion_effects" if outcome == "completed" \
            else "expiry_effects"
        raw = node.get(field, {})
        if isinstance(raw, dict) and raw:
            values.append(("state_effects", _freeze_semantic_value(raw)))
    bundle_tokens = [
        value.removeprefix("bundle:")
        for value in branch_contract.get("applicability_ids", [])
        if isinstance(value, str) and value.startswith("bundle:")]
    for bundle_id in bundle_tokens if outcome == "completed" else []:
        bundle = _json_pointer_value(
            "content/meta/demo_core_loop_v2.json#/scene_bundles/"
            f"{bundle_id}", cache)
        family = _bundle_execution_family(bundle_id, bundle) \
            if isinstance(bundle, dict) else "unknown"
        config = bundle.get("action_config", {}) \
            if isinstance(bundle, dict) else {}
        if (family not in CONDITIONAL_ACTION_RESULT_FAMILIES
                and isinstance(config, dict)
                and isinstance(config.get("effects"), dict)):
            values.append((
                "action_effects", _freeze_semantic_value(
                    config.get("effects", {}))))
    return tuple(sorted(values, key=repr))


def _branch_participant_and_availability_signature(
        row: dict[str, Any], branch_contract: dict[str, Any],
        cache: dict[Path, Any]) -> tuple[Any, ...]:
    participants: set[str] = set()
    windows: list[Any] = []
    availability = row.get("availability", {})
    window_map = availability.get("trigger_windows_by_bundle", {}) \
        if isinstance(availability, dict) else {}
    for applicability_id in branch_contract.get("applicability_ids", []):
        if not isinstance(applicability_id, str) \
                or not applicability_id.startswith("bundle:"):
            continue
        bundle_id = applicability_id.removeprefix("bundle:")
        if isinstance(window_map, dict) and bundle_id in window_map:
            windows.append(_freeze_semantic_value(window_map[bundle_id]))
        bundle = _json_pointer_value(
            "content/meta/demo_core_loop_v2.json#/scene_bundles/"
            f"{bundle_id}", cache)
        outcomes = bundle.get("relationship_outcomes", []) \
            if isinstance(bundle, dict) else []
        if isinstance(outcomes, list):
            participants.update(
                str(item.get("character")) for item in outcomes
                if isinstance(item, dict)
                and isinstance(item.get("character"), str)
                and item.get("character"))
    return (
        ("participants", tuple(sorted(participants))),
        ("availability", tuple(windows)),
    )


def _branch_causal_signatures(
        row: dict[str, Any], branch_contract: dict[str, Any],
        route_read_fact_ids: set[str], cache: dict[Path, Any], *,
        include_nested_outputs: bool) -> set[tuple[Any, ...]]:
    """Build exact realized causal signatures for one weekly branch.

    The full signature includes inner action/Story outcomes and is used to
    detect identical realized histories.  The weekly signature deliberately
    excludes those nested outputs: an inner Story choice cannot be the sole
    evidence that two board routes diverge.
    """
    outcome = str(branch_contract.get("outcome_kind", ""))
    next_verbs = row.get("next_verb_by_terminal", {}).get(outcome, [])
    next_signature = tuple(next_verbs) if isinstance(next_verbs, list) else ()
    cost = row.get("cost", {})
    cost_signature = (
        cost.get("weekly_capacity") if isinstance(cost, dict) else None,
        cost.get("visible") if isinstance(cost, dict) else None,
        tuple(
            _freeze_semantic_value(_json_pointer_value(pointer, cache))
            for pointer in cost.get("effect_pointers", [])
            if isinstance(pointer, str)) if isinstance(cost, dict) else (),
    )
    direct_effects = _branch_direct_effect_signature(
        row, branch_contract, cache)
    participant_availability = \
        _branch_participant_and_availability_signature(
            row, branch_contract, cache)
    signatures: set[tuple[Any, ...]] = set()
    common_facts = {
        fact_id for fact_id in branch_contract.get("produced_fact_ids", [])
        if isinstance(fact_id, str) and fact_id}
    for facts, effect_ids in _branch_realized_outputs(
            row, branch_contract, cache):
        credited_facts = set(facts) if include_nested_outputs else common_facts
        consumed_facts = tuple(sorted(
            credited_facts & route_read_fact_ids))
        effects = tuple(sorted(filter(None, (
            _nested_effect_semantic_value(effect_id, cache)
            for effect_id in effect_ids)), key=repr)) \
            if include_nested_outputs else ()
        signatures.add((
            ("consumed_facts", consumed_facts),
            ("effects", direct_effects, effects),
            ("cost", cost_signature),
            ("next_verbs", next_signature),
            *participant_availability,
        ))
    return signatures


def _branch_is_potentially_reachable(
        row: dict[str, Any], branch_contract: dict[str, Any], *,
        synthetic: bool, readers: dict[str, dict[str, Any]],
        bound_facts_by_reader: dict[str, set[str]],
        cache: dict[Path, Any]) -> bool:
    applicability = branch_contract.get("applicability_ids", [])
    if not isinstance(applicability, list) or not applicability:
        return False
    if synthetic:
        return True

    def bundle_is_playable(bundle_id: str) -> bool:
        availability = row.get("availability", {})
        windows = availability.get("trigger_windows_by_bundle", {}) \
            if isinstance(availability, dict) else {}
        window = windows.get(bundle_id) if isinstance(windows, dict) else None
        if (not isinstance(window, dict)
                or not window.get("relative_weeks")):
            return False
        pointer = (
            "content/meta/demo_core_loop_v2.json#/scene_bundles/"
            f"{bundle_id}/prerequisites")
        prerequisites = _json_pointer_value(pointer, cache)
        if prerequisites in (None, {}, []):
            return True
        expected_variants = _prerequisite_fact_variants(pointer, cache)
        if not expected_variants:
            return False
        return any(
            reader.get("status") == "active"
            and reader.get("reader_kind") == "action_unlock"
            and reader.get("runtime_pointer") == pointer
            and reader.get("reads_fact_ids") in expected_variants
            and set(reader.get("reads_fact_ids", [])).issubset(
                bound_facts_by_reader.get(str(reader_id), set()))
            for reader_id, reader in readers.items())

    authored_bundles = _row_trigger_bundles(row)
    playable_bundles = {
        bundle_id for bundle_id in authored_bundles
        if bundle_is_playable(bundle_id)}
    for value in applicability:
        if not isinstance(value, str):
            continue
        if value.startswith("bundle:"):
            return value.removeprefix("bundle:") in playable_bundles
        if value.startswith("resolved_trigger:"):
            return bool(playable_bundles)
        if value.startswith(("allocation_only:", "node_deadline:")):
            return True
    return False


def _row_route_read_fact_ids(
        row: dict[str, Any], readers: dict[str, dict[str, Any]],
        bound_facts_by_reader: dict[str, set[str]]) -> set[str]:
    """Return only source-bound causal reads explicitly owned by this row."""
    reader_ids = {
        reader_id
        for field in ("near_reader_ids", "milestone_reader_ids")
        for reader_id in row.get(field, [])
        if isinstance(reader_id, str)}
    return {
        fact_id
        for reader_id in reader_ids
        if (readers.get(reader_id, {}).get("status") == "active"
            and readers.get(reader_id, {}).get("reader_kind")
            in ROUTE_CAUSAL_READER_KINDS)
        for fact_id in bound_facts_by_reader.get(reader_id, set())}


def _pair_debt_id(
        counter_id: str, kind: str,
        left_branch_id: str, right_branch_id: str) -> str:
    return (
        f"counter:{counter_id}:{kind}:"
        f"{left_branch_id}|{right_branch_id}")


def _expected_branch_contracts(
        row: dict[str, Any], cache: dict[Path, Any]) -> list[dict[str, Any]]:
    chain_id = str(row.get("chain_id", ""))
    row_proof = f"proof:row:{chain_id}"
    expiry_facts = list(
        row.get("producer", {}).get("expiry_receipt_ids", []))
    terminal = row.get("terminal_contract", {})
    if terminal.get("repeatable_after_completion", False):
        bundles = _row_trigger_bundles(row)
        if bundles:
            completed_facts = _expected_bundle_branch_facts(
                row, bundles[0], cache)
            completed_proofs = _expected_bundle_branch_proofs(
                row, bundles[0], cache)
            completed_branch_id = f"{chain_id}:completed"
            expired_branch_id = f"{chain_id}:trigger_expired_or_missed"
        else:
            completed_facts = [f"receipt:allocation:{chain_id}"]
            completed_proofs = [
                row_proof, "proof:runtime:allocation_commit"]
            completed_branch_id = f"{chain_id}:completed"
            expired_branch_id = f"{chain_id}:expired"
        return [
            {
                "branch_id": completed_branch_id,
                "outcome_kind": "completed",
                "applicability_ids": [
                    f"bundle:{bundles[0]}" if bundles
                    else f"allocation_only:{chain_id}"],
                "nested_output_group_ids": (
                    _expected_nested_output_group_ids(
                        row, bundles[0], cache) if bundles else []),
                "produced_fact_ids": completed_facts,
                "runtime_proof_ids": completed_proofs,
            },
            {
                "branch_id": expired_branch_id,
                "outcome_kind": "expired",
                "applicability_ids": [
                    f"resolved_trigger:{chain_id}" if bundles
                    else f"node_deadline:{chain_id}"],
                "nested_output_group_ids": [],
                "produced_fact_ids": expiry_facts,
                "runtime_proof_ids": [
                    row_proof, "proof:runtime:terminal_expiry"],
            },
        ]
    bundles = _row_trigger_bundles(row)
    contracts: list[dict[str, Any]] = []
    if (row.get("slot_owner") == "people" and chain_id != "m1_father") \
            or len(bundles) > 1:
        for bundle_id in bundles:
            contracts.append({
                "branch_id": f"{chain_id}:{bundle_id}",
                "outcome_kind": "completed",
                "applicability_ids": [f"bundle:{bundle_id}"],
                "nested_output_group_ids": _expected_nested_output_group_ids(
                    row, bundle_id, cache),
                "produced_fact_ids": _expected_bundle_branch_facts(
                    row, bundle_id, cache),
                "runtime_proof_ids": _expected_bundle_branch_proofs(
                    row, bundle_id, cache),
            })
    elif bundles:
        bundle_id = bundles[0]
        contracts.append({
            "branch_id": f"{chain_id}:completed",
            "outcome_kind": "completed",
            "applicability_ids": [f"bundle:{bundle_id}"],
            "nested_output_group_ids": _expected_nested_output_group_ids(
                row, bundle_id, cache),
            "produced_fact_ids": _expected_bundle_branch_facts(
                row, bundle_id, cache),
            "runtime_proof_ids": _expected_bundle_branch_proofs(
                row, bundle_id, cache),
        })
    else:
        contracts.append({
            "branch_id": f"{chain_id}:completed",
            "outcome_kind": "completed",
            "applicability_ids": [f"allocation_only:{chain_id}"],
            "nested_output_group_ids": [],
            "produced_fact_ids": [f"receipt:allocation:{chain_id}"],
            "runtime_proof_ids": [
                row_proof, "proof:runtime:allocation_commit"],
        })
    contracts.append({
        "branch_id": f"{chain_id}:expired",
        "outcome_kind": "expired",
        "applicability_ids": [
            f"resolved_trigger:{chain_id}" if bundles
            else f"node_deadline:{chain_id}"],
        "nested_output_group_ids": [],
        "produced_fact_ids": expiry_facts,
        "runtime_proof_ids": [row_proof, "proof:runtime:terminal_expiry"],
    })
    return contracts


def _expected_counterfactual_contract(
        row: dict[str, Any], *, complete: bool,
        cache: dict[Path, Any] | None = None) -> tuple[list[str], list[str], list[str]]:
    chain_id = str(row.get("chain_id", ""))
    terminal = row.get("terminal_contract", {})
    availability = row.get("availability", {})
    if terminal.get("repeatable_after_completion", False):
        branches = [f"{chain_id}:completed"]
        branches.append(
            f"{chain_id}:trigger_expired_or_missed"
            if _row_trigger_bundles(row) else f"{chain_id}:expired")
        axes = [
            "completion_receipt", "expiry_consequence",
            "repeat_availability",
        ]
    elif row.get("slot_owner") == "people" and chain_id != "m1_father":
        candidate_bundles = list(availability.get("trigger_bundle_ids", []))
        fallback_bundle = availability.get("fallback_trigger_bundle_id")
        if (isinstance(fallback_bundle, str) and fallback_bundle
                and fallback_bundle not in candidate_bundles):
            candidate_bundles.append(fallback_bundle)
        branches = [
            *(f"{chain_id}:{bundle_id}"
              for bundle_id in candidate_bundles),
            f"{chain_id}:expired",
        ]
        axes = ["participant", "relationship_memory", "future_availability"]
    elif len(availability.get("trigger_bundle_ids", [])) > 1:
        fallback_bundle = availability.get("fallback_trigger_bundle_id")
        branches = [
            *(f"{chain_id}:{bundle_id}"
              for bundle_id in availability.get("trigger_bundle_ids", [])),
            *([f"{chain_id}:{fallback_bundle}"]
              if isinstance(fallback_bundle, str) and fallback_bundle else []),
            f"{chain_id}:expired",
        ]
        axes = [
            "method", "visible_cost", "application_or_skill_result",
            "future_availability",
        ]
    elif chain_id == "m1_father":
        branches = [f"{chain_id}:completed", f"{chain_id}:expired"]
        axes = ["relationship_memory", "future_availability", "result"]
    else:
        branches = [f"{chain_id}:completed", f"{chain_id}:expired"]
        axes = [
            "completion_receipt", "expiry_consequence", "next_verb_or_result",
        ]
    # Extending the row census does not replace the real eight-owner disk
    # roundtrip with a synthetic one-proof shortcut.  This stable prefix proof
    # remains the entry point to that exact chain in complete mode too.
    save_proof_id = "proof:runtime:save_roundtrip_prefix"
    proofs = [
        f"proof:row:{chain_id}",
        "proof:runtime:allocation_commit",
        "proof:runtime:terminal_expiry",
        save_proof_id,
    ]
    if row.get("slot_owner") == "people" and chain_id != "m1_father":
        proofs.append("proof:runtime:first_eligible_person")
    branch_contracts = _expected_branch_contracts(row, cache or {})
    branch_proof_union = {
        proof_id for contract in branch_contracts
        for proof_id in contract.get("runtime_proof_ids", [])
        if isinstance(proof_id, str)}
    for proof_id in (
            "proof:runtime:trigger_resolution",
            "proof:runtime:bundle_completion",
            "proof:runtime:application_receipt",
            "proof:runtime:relationship_receipt",
            "proof:runtime:action_commitment",
            "proof:runtime:action_receipt",
            "proof:runtime:activity_receipt"):
        if proof_id in branch_proof_union and proof_id not in proofs:
            proofs.append(proof_id)
    for proof_id in sorted(branch_proof_union - set(proofs)):
        proofs.append(proof_id)
    return branches, axes, proofs


def _synthetic_branch_contracts(
        row: dict[str, Any], branch_ids: list[str]) -> list[dict[str, Any]]:
    """Build only the structural W48 self-test fixture, never production truth."""
    chain_id = str(row.get("chain_id", ""))
    row_proof = f"proof:row:{chain_id}"
    completed_facts = list(
        row.get("producer", {}).get("completion_receipt_ids", []))
    if not completed_facts:
        completed_facts = list(row.get("build_facts", []))
    expired_facts = list(
        row.get("missed_contract", {}).get("receipt_ids", []))
    result: list[dict[str, Any]] = []
    for index, branch_id in enumerate(branch_ids):
        expired = index == len(branch_ids) - 1
        result.append({
            "branch_id": branch_id,
            "outcome_kind": "expired" if expired else "completed",
            "applicability_ids": [f"selftest:applicable:{branch_id}"],
            "nested_output_group_ids": [],
            "produced_fact_ids": (
                list(expired_facts) if expired else list(completed_facts)),
            "runtime_proof_ids": (
                [row_proof, "proof:runtime:terminal_expiry"]
                if expired else [
                    row_proof, "proof:runtime:allocation_commit",
                    "proof:runtime:terminal_expiry",
                ]),
        })
    return result


def _validate_runtime_mirror(row: dict[str, Any], index: int,
                             errors: list[str], cache: dict[Path, Any], *,
                             enforce_source_contracts: bool = True) -> None:
    node = _json_pointer_value(row.get("runtime_pointer", ""), cache)
    if not isinstance(node, dict):
        return
    where = f"rows[{index}]"
    chain_id = str(row.get("chain_id", ""))
    availability = row.get("availability", {})
    cost = row.get("cost", {})
    expected_windows = _expected_trigger_windows_by_bundle(row, cache)
    window_minima = [
        value["min_relative_week"] for value in expected_windows.values()]
    window_maxima = [
        value["max_relative_week"] for value in expected_windows.values()]
    mirrors = {
        "threshold": node.get("threshold"),
        "threshold_by_trigger": node.get("threshold_by_trigger", {}),
        "deadline_week": node.get("deadline_week"),
        "trigger_min_week": min(window_minima) if window_minima else None,
        "trigger_deadline_week": (
            max(window_maxima) if window_maxima
            else node.get("trigger_deadline_week", node.get("deadline_week"))),
        "deadline_follows_trigger": node.get("deadline_follows_trigger", False),
        "disable_without_trigger": node.get("disable_without_trigger", False),
        "fallback_after_trigger_expiry": node.get("fallback_after_trigger_expiry", False),
    }
    for key, expected in mirrors.items():
        if key in availability and availability.get(key) != expected:
            errors.append(
                f"{where}.availability.{key}: runtime mirror expected {expected!r}")
    fallback = node.get("fallback_trigger_bundle") or None
    if availability.get("fallback_trigger_bundle_id") != fallback:
        errors.append(
            f"{where}.availability.fallback_trigger_bundle_id: runtime mirror expected {fallback!r}")
    expected_triggers: list[str] = []
    trigger = node.get("trigger_bundle")
    if isinstance(trigger, str) and trigger:
        expected_triggers.append(trigger)
    trigger_options = node.get("trigger_options", [])
    if isinstance(trigger_options, list):
        expected_triggers.extend(
            option for option in trigger_options
            if isinstance(option, str) and option and option not in expected_triggers)
    if availability.get("trigger_bundle_ids") != expected_triggers:
        errors.append(
            f"{where}.availability.trigger_bundle_ids: runtime mirror expected {expected_triggers!r}")
    if availability.get("trigger_windows_by_bundle") != expected_windows:
        errors.append(
            f"{where}.availability.trigger_windows_by_bundle: source allowed_weeks mirror mismatch")
    expected_no_eligible = None
    if _row_can_lock_without_eligible(row, node, cache):
        expected_no_eligible = {
            "status": "locked",
            "produces_receipts": False,
            "runtime_proof_ids": [
                f"proof:row:{chain_id}",
                "proof:runtime:no_eligible_trigger_resolution",
                "proof:runtime:no_eligible_trigger_lock",
                "proof:runtime:locked_terminal_exclusion",
            ],
        }
    if availability.get("no_eligible_contract") != expected_no_eligible:
        errors.append(
            f"{where}.availability.no_eligible_contract: source locked/no-receipt mismatch")
    completion_replaces = node.get("completion_replaces_allocation_effects", False)
    if ("completion_replaces_allocation_effects" in cost
            and cost.get("completion_replaces_allocation_effects") != completion_replaces):
        errors.append(
            f"{where}.cost.completion_replaces_allocation_effects: runtime mirror expected {completion_replaces!r}")
    runtime_pointer = row.get("runtime_pointer", "")
    expected_effect_pointers = [
        f"{runtime_pointer}/{key}" for key in (
            "allocation_effects", "allocation_effects_by_progress")
        if key in node]
    if cost.get("effect_pointers") != expected_effect_pointers:
        errors.append(
            f"{where}.cost.effect_pointers: runtime mirror expected {expected_effect_pointers!r}")
    repeatable = node.get("repeatable_after_completion", False)
    if row.get("terminal_contract", {}).get(
            "repeatable_after_completion") != repeatable:
        errors.append(
            f"{where}.terminal_contract.repeatable_after_completion: "
            f"runtime mirror expected {repeatable!r}")
    if not enforce_source_contracts:
        return
    expected_selection_owner = (
        "fixed_subject" if chain_id == "m1_father"
        else "runtime_first_eligible"
        if ((row.get("slot_owner") == "people"
             and row.get("month", 0) >= 2)
            or len(_row_trigger_bundles(row)) > 1)
        else "player")
    resolver_body = _pointer_source_text(
        "systems/DemoCoreLoopV2.gd::_resolved_seoul_cycle_node", cache)
    if (row.get("selection_owner") != expected_selection_owner
            or not all(marker in resolver_body for marker in (
                "for bundle_id in candidates", "resolved_trigger = bundle_id",
                "break"))):
        errors.append(
            f"{where}.selection_owner: does not mirror runtime selection owner")
    expected_runtime_cap = 1 if len(_row_trigger_bundles(row)) > 1 else None
    expected_declared_caps = {"m5_people": 2}
    if availability.get("runtime_candidate_cap") != expected_runtime_cap:
        errors.append(
            f"{where}.availability.runtime_candidate_cap: source cap mismatch")
    if availability.get("declared_candidate_cap") != expected_declared_caps.get(chain_id):
        errors.append(
            f"{where}.availability.declared_candidate_cap: canon cap mismatch")
    if chain_id == "m5_people":
        declared_cap = _json_pointer_value(
            "content/meta/demo_core_loop_v2.json#/exclusive_groups/month_five_person_climax/maximum_selected",
            cache)
        if declared_cap != 2:
            errors.append(
                f"{where}.availability.declared_candidate_cap: source contract is not 2")
    resolved_window_body = _pointer_source_text(
        "systems/DemoCoreLoopV2.gd::_seoul_cycle_node_with_resolved_trigger",
        cache)
    membership_body = _pointer_source_text(
        "systems/DemoCoreLoopV2.gd::bundle_allowed_in_week", cache)
    if (not all(marker in resolved_window_body for marker in (
            'chosen_bundle.get("allowed_weeks"',
            "relative_weeks.append(", "relative_weeks.front()",
            "relative_weeks.back()"))
            or not all(marker in membership_body for marker in (
                'scene_bundle.get("allowed_weeks"',
                "if int(raw_week) == week:"))):
        errors.append(
            f"{where}.availability.trigger_windows_by_bundle: runtime resolver/membership source contract missing")

    if cost.get("weekly_capacity") != 1 or cost.get("visible") is not True:
        errors.append(f"{where}.cost: expected one visible weekly capacity")
    terminal = row.get("terminal_contract", {})
    if repeatable:
        if (terminal.get("reentry_cost") != {"weekly_capacity": 1}
                or row.get("producer", {}).get("repeat_receipt_unique_by")
                != ["turn", "node_id"]):
            errors.append(f"{where}: repeat contract does not match runtime cost/identity")
    elif (terminal.get("reentry_cost") is not None
          or row.get("producer", {}).get("repeat_receipt_unique_by") != []):
        errors.append(f"{where}: non-repeatable row invents repeat contract")
    if (terminal.get("completed_surface") != "same_card"
            or terminal.get("expired_surface") != "same_card"):
        errors.append(f"{where}.terminal_contract: current board surfaces must remain same_card")

    producer = row.get("producer", {})
    expected_template = f"seoul_cycle_m{row.get('month')}_w{{week_index}}"
    if producer.get("allocation_receipt_id_template") != expected_template:
        errors.append(
            f"{where}.producer.allocation_receipt_id_template: source template mismatch")
    expected_completion = _expected_completion_receipts(row, cache)
    if producer.get("completion_receipt_ids") != expected_completion:
        errors.append(f"{where}.producer.completion_receipt_ids: source outputs mismatch")
    expected_expiry, expected_consequences = \
        _expected_expiry_receipts_and_consequences(row, node)
    if producer.get("expiry_receipt_ids") != expected_expiry:
        errors.append(f"{where}.producer.expiry_receipt_ids: source output mismatch")
    expected_state_keys = _expected_state_delta_keys(row, cache)
    if producer.get("state_delta_keys") != expected_state_keys:
        errors.append(f"{where}.producer.state_delta_keys: source effects mismatch")
    execution_contracts = _row_execution_family_contracts(row, cache)
    unknown_execution = [
        f"{bundle_id}={family}" for bundle_id, family in execution_contracts
        if family.startswith("unknown:")]
    if unknown_execution:
        errors.append(
            f"{where}.producer: unclassified action execution family "
            + ", ".join(unknown_execution))
    for bundle_id, family in execution_contracts:
        if (not family.startswith("unknown:")
                and not _execution_family_source_is_bound(
                    bundle_id, family, cache)):
            errors.append(
                f"{where}.producer: execution family source contract "
                f"is not bound for {bundle_id}={family}")
    expected_variants, expected_variant_groups = \
        _expected_output_variants_and_groups(row, cache)
    expected_group_ids = {
        group.get("selection_group_id") for group in expected_variant_groups
        if isinstance(group, dict)}
    chain_id_text = str(row.get("chain_id", ""))
    for bundle_id, family in execution_contracts:
        required_group_id = _conditional_action_group_id(
            chain_id_text, bundle_id, family)
        if (family in CONDITIONAL_ACTION_RESULT_FAMILIES
                and required_group_id not in expected_group_ids):
            errors.append(
                f"{where}.producer: conditional action family {family} "
                f"for {bundle_id} has no exact result group")
    family_by_bundle = dict(execution_contracts)
    for variant in producer.get("conditional_output_variants", []):
        if not isinstance(variant, dict):
            continue
        activations = variant.get("activation_ids", [])
        if not isinstance(activations, list):
            continue
        # Only the dispatcher-owned result tokens below identify a
        # conditional *action* family.  A source-derived Story follow-up may
        # activate from a durable receipt/memory instead (Hyunsu's future
        # receipt is the current example); treating every non-story-choice
        # activation as an action family falsely crosses the layer boundary.
        action_result_activation = any(
            isinstance(value, str) and (
                value.startswith((
                    "action_quality:", "runtime_result:",
                    "activity_outcome:"))
                or value.startswith(
                    "fact:routine_selected:recovery:"))
            for value in activations)
        if not action_result_activation:
            continue
        activated_bundles = [
            value.removeprefix("bundle:") for value in activations
            if isinstance(value, str) and value.startswith("bundle:")]
        for bundle_id in activated_bundles:
            family = family_by_bundle.get(bundle_id)
            if (family is not None
                    and family not in CONDITIONAL_ACTION_RESULT_FAMILIES):
                errors.append(
                    f"{where}.producer: fixed {family} path {bundle_id} "
                    "must not own a conditional action-result variant")
    if producer.get("conditional_output_variants") != expected_variants:
        errors.append(
            f"{where}.producer.conditional_output_variants: authored producer graph mismatch")
    if producer.get("output_variant_groups") != expected_variant_groups:
        errors.append(
            f"{where}.producer.output_variant_groups: authored exclusivity graph mismatch")
    expected_display_keys: list[str] = []
    if _row_story_choice_records(row, cache):
        expected_display_keys.append("event_log")
    # Every scheduled trigger resolves through a MainGame action/result path
    # that calls GameState.add_log.  Allocation-only recovery is the sole
    # current row with no action_log producer.
    if _row_trigger_bundles(row):
        expected_display_keys.append("action_log")
    if producer.get("display_only_output_keys") != expected_display_keys:
        errors.append(
            f"{where}.producer.display_only_output_keys: Story log-only source mismatch")
    if set(producer.get("state_delta_keys", [])) & set(expected_display_keys):
        errors.append(
            f"{where}.producer: display-only Story logs may not receive causal credit")
    month = row.get("month")
    if _is_int(month):
        expected_missed_contract = {
            "receipt_ids": expected_expiry,
            "consequence_ids": expected_consequences,
            "reader_ids": [f"reader:month:m{month:02d}:summary"],
        }
        actual_missed = row.get("missed_contract", {})
        if (not isinstance(actual_missed, dict)
                or any(actual_missed.get(key) != value
                       for key, value in expected_missed_contract.items())):
            errors.append(
                f"{where}.missed_contract: source expiry contract mismatch")
    if (chain_id in EXPECTED_BUILD_FACTS_BY_CHAIN
            and row.get("build_facts") != EXPECTED_BUILD_FACTS_BY_CHAIN[chain_id]):
        errors.append(f"{where}.build_facts: audited producer fact set mismatch")
    # `build_facts` is a curated causal surface, so it need not expose every
    # terminal or nested Story output.  It may, however, name only facts that
    # an allocation, terminal producer, or reachable conditional variant
    # actually creates.  This prevents invented aggregate facts (the former
    # generic `fact:inventory_method`, for example) from entering ORPHAN or
    # route accounting merely because a hand-authored snapshot listed them.
    produced_source_fact_ids = {f"receipt:allocation:{chain_id}"}
    for producer_key in ("completion_receipt_ids", "expiry_receipt_ids"):
        produced_source_fact_ids.update(
            fact_id for fact_id in producer.get(producer_key, [])
            if isinstance(fact_id, str))
    for variant in producer.get("conditional_output_variants", []):
        if not isinstance(variant, dict):
            continue
        produced_source_fact_ids.update(
            fact_id for fact_id in variant.get("produced_fact_ids", [])
            if isinstance(fact_id, str))
    invented_build_facts = sorted(
        set(row.get("build_facts", [])) - produced_source_fact_ids)
    if invented_build_facts:
        errors.append(
            f"{where}.build_facts: facts outside source producer union "
            f"{invented_build_facts}")

    expected_surfaces = {
        locale: [f"{runtime_pointer}/{field}_{locale}"
                 for field in ("label", "board_label", "place")]
        for locale in ("ko", "en")
    }
    if row.get("surface_pointers") != expected_surfaces:
        errors.append(f"{where}.surface_pointers: exact KO/EN node fields mismatch")


def _gdscript_function_body(text: str, function_name: str) -> str:
    lines = text.splitlines()
    start = next((index for index, line in enumerate(lines)
                  if re.match(
                      rf"^(?:static\s+)?func\s+{re.escape(function_name)}\s*\(",
                      line)), None)
    if start is None:
        return ""
    end = len(lines)
    for index in range(start + 1, len(lines)):
        if re.match(r"^(?:static\s+)?func\s+", lines[index]):
            end = index
            break
    return "\n".join(lines[start:end])


def _validate_pointer(pointer: str, where: str, errors: list[str],
                      cache: dict[Path, Any]) -> None:
    if not isinstance(pointer, str) or not pointer:
        errors.append(f"{where}: pointer must be a non-empty string")
        return
    if "#/" in pointer:
        relative, fragment = pointer.split("#", 1)
        path = ROOT / relative
        if not path.is_file():
            errors.append(f"{where}: stale pointer path {relative}")
            return
        try:
            if path not in cache:
                cache[path] = json.loads(path.read_text(encoding="utf-8"))
            if not _resolve_json_pointer(cache[path], fragment):
                errors.append(f"{where}: stale RFC6901 pointer {pointer}")
        except (OSError, json.JSONDecodeError) as exc:
            errors.append(f"{where}: cannot resolve JSON pointer {pointer}: {exc}")
        return
    if "::" in pointer:
        relative, symbol = pointer.split("::", 1)
        path = ROOT / relative
        if not path.is_file():
            errors.append(f"{where}: stale pointer path {relative}")
            return
        if not symbol:
            errors.append(f"{where}: missing symbol in {pointer}")
            return
        try:
            text = path.read_text(encoding="utf-8")
            if path.suffix == ".gd":
                symbol_pattern = re.compile(
                    rf"^(?:(?:static\s+)?func\s+{re.escape(symbol)}\s*\(|"
                    rf"const\s+{re.escape(symbol)}\b)", re.MULTILINE)
                if not symbol_pattern.search(text):
                    errors.append(f"{where}: stale exact GDScript symbol {pointer}")
            elif path.suffix == ".md":
                heading_pattern = re.compile(
                    rf"^#{{1,6}}\s+{re.escape(symbol)}\s*$", re.MULTILINE)
                if not heading_pattern.search(text):
                    errors.append(f"{where}: stale exact Markdown heading {pointer}")
            else:
                errors.append(
                    f"{where}: :: pointers require .gd symbol or .md heading")
        except OSError as exc:
            errors.append(f"{where}: cannot read pointer {pointer}: {exc}")
        return
    errors.append(f"{where}: pointer must use path#/RFC6901 or path::symbol")


def _walk_pointers(value: Any, where: str, errors: list[str],
                   cache: dict[Path, Any]) -> None:
    if isinstance(value, dict):
        for key, child in value.items():
            child_where = f"{where}.{key}"
            if key.endswith("pointer"):
                if child is not None:
                    _validate_pointer(child, child_where, errors, cache)
            elif key.endswith("pointers"):
                if isinstance(child, dict):
                    for lang, pointers in child.items():
                        for index, pointer in enumerate(
                                _string_list(pointers, f"{child_where}.{lang}", errors)):
                            _validate_pointer(pointer, f"{child_where}.{lang}[{index}]", errors, cache)
                else:
                    for index, pointer in enumerate(
                            _string_list(child, child_where, errors)):
                        _validate_pointer(pointer, f"{child_where}[{index}]", errors, cache)
            else:
                _walk_pointers(child, child_where, errors, cache)
    elif isinstance(value, list):
        for index, child in enumerate(value):
            _walk_pointers(child, f"{where}[{index}]", errors, cache)


def _validate_row(row: Any, index: int, errors: list[str]) -> None:
    where = f"rows[{index}]"
    obj = _exact_fields(row, ROW_FIELDS, where, errors)
    if not obj:
        return
    for key in ("chain_id", "node_id", "runtime_pointer", "slot_owner",
                "build_family", "selection_owner", "counterfactual_id"):
        if not isinstance(obj.get(key), str) or not obj[key]:
            errors.append(f"{where}.{key}: expected non-empty string")
    if not _is_int(obj.get("month")) or not 1 <= obj["month"] <= 12:
        errors.append(f"{where}.month: expected 1..12")
    if obj.get("slot_owner") not in FAMILIES:
        errors.append(f"{where}.slot_owner: unknown owner {obj.get('slot_owner')!r}")
    if obj.get("build_family") not in set(BUILD_FAMILY_BY_SLOT.values()):
        errors.append(f"{where}.build_family: unknown family {obj.get('build_family')!r}")
    if BUILD_FAMILY_BY_SLOT.get(obj.get("slot_owner")) != obj.get("build_family"):
        errors.append(f"{where}: slot_owner/build_family mapping disagrees")
    if obj.get("selection_owner") not in {
            "player", "fixed_subject", "runtime_first_eligible"}:
        errors.append(f"{where}.selection_owner: invalid owner")

    availability = _required_optional_fields(
        obj.get("availability"), AVAILABILITY_FIELDS, AVAILABILITY_OPTIONAL_FIELDS,
        f"{where}.availability", errors)
    if availability:
        for key in ("threshold", "deadline_week"):
            if not _is_int(availability.get(key)) or availability[key] < 0:
                errors.append(f"{where}.availability.{key}: expected non-negative integer")
        _string_list(availability.get("trigger_bundle_ids"),
                     f"{where}.availability.trigger_bundle_ids", errors)
        fallback = availability.get("fallback_trigger_bundle_id")
        if fallback is not None and (not isinstance(fallback, str) or not fallback):
            errors.append(f"{where}.availability.fallback_trigger_bundle_id: invalid")
        if not isinstance(availability.get("disable_without_trigger"), bool):
            errors.append(f"{where}.availability.disable_without_trigger: expected bool")
        trigger_windows = availability.get("trigger_windows_by_bundle")
        if not isinstance(trigger_windows, dict):
            errors.append(
                f"{where}.availability.trigger_windows_by_bundle: expected object")
        else:
            for bundle_id, raw_window in trigger_windows.items():
                window_where = (
                    f"{where}.availability.trigger_windows_by_bundle."
                    f"{bundle_id}")
                if not isinstance(bundle_id, str) or not bundle_id:
                    errors.append(
                        f"{where}.availability.trigger_windows_by_bundle: invalid bundle ID")
                    continue
                window = _exact_fields(
                    raw_window, TRIGGER_WINDOW_FIELDS, window_where, errors)
                minimum = window.get("min_relative_week")
                maximum = window.get("max_relative_week")
                relative_weeks = window.get("relative_weeks", [])
                if (not isinstance(window.get("relative_weeks"), list)
                        or any(not _is_int(week) or not 1 <= week <= 4
                               for week in window.get("relative_weeks", []))
                        or window.get("relative_weeks") != sorted(set(
                            window.get("relative_weeks", [])))
                        or not relative_weeks
                        or not _is_int(minimum) or not _is_int(maximum)
                        or not 1 <= minimum <= maximum <= 4
                        or minimum != min(relative_weeks)
                        or maximum != max(relative_weeks)):
                    errors.append(
                        f"{window_where}: expected 1..4 ascending relative-week window")
        no_eligible = availability.get("no_eligible_contract")
        if no_eligible is not None:
            contract = _exact_fields(
                no_eligible, NO_ELIGIBLE_CONTRACT_FIELDS,
                f"{where}.availability.no_eligible_contract", errors)
            if contract.get("status") != "locked":
                errors.append(
                    f"{where}.availability.no_eligible_contract.status: expected locked")
            if contract.get("produces_receipts") is not False:
                errors.append(
                    f"{where}.availability.no_eligible_contract.produces_receipts: expected false")
            _string_list(
                contract.get("runtime_proof_ids"),
                f"{where}.availability.no_eligible_contract.runtime_proof_ids",
                errors, nonempty=True)
        threshold_by_trigger = availability.get("threshold_by_trigger")
        if threshold_by_trigger is not None and (
                not isinstance(threshold_by_trigger, dict)
                or any(not isinstance(key, str) or not _is_int(value) or value < 0
                       for key, value in threshold_by_trigger.items())):
            errors.append(f"{where}.availability.threshold_by_trigger: expected string→non-negative-int object")
        for key in ("trigger_min_week", "trigger_deadline_week"):
            value = availability.get(key)
            if key in availability and value is not None and (not _is_int(value) or value < 0):
                errors.append(f"{where}.availability.{key}: expected non-negative int|null")
        for key in ("deadline_follows_trigger", "fallback_after_trigger_expiry"):
            if key in availability and not isinstance(availability.get(key), bool):
                errors.append(f"{where}.availability.{key}: expected bool")
        for key in ("declared_candidate_cap", "runtime_candidate_cap"):
            value = availability.get(key)
            if key in availability and value is not None and (not _is_int(value) or value < 0):
                errors.append(f"{where}.availability.{key}: expected non-negative int|null")

    cost = _required_optional_fields(obj.get("cost"), COST_FIELDS,
                                     COST_OPTIONAL_FIELDS, f"{where}.cost", errors)
    if cost:
        if not _is_int(cost.get("weekly_capacity")) or cost["weekly_capacity"] < 0:
            errors.append(f"{where}.cost.weekly_capacity: expected non-negative integer")
        _string_list(cost.get("effect_pointers"), f"{where}.cost.effect_pointers", errors)
        if not isinstance(cost.get("visible"), bool):
            errors.append(f"{where}.cost.visible: expected bool")
        if ("completion_replaces_allocation_effects" in cost
                and not isinstance(cost.get("completion_replaces_allocation_effects"), bool)):
            errors.append(f"{where}.cost.completion_replaces_allocation_effects: expected bool")

    producer = _exact_fields(obj.get("producer"), PRODUCER_FIELDS,
                             f"{where}.producer", errors)
    if producer:
        if (not isinstance(producer.get("allocation_receipt_id_template"), str)
                or not producer["allocation_receipt_id_template"].strip()):
            errors.append(
                f"{where}.producer.allocation_receipt_id_template: expected non-empty string")
        for key in PRODUCER_FIELDS - {
                "allocation_receipt_id_template",
                "conditional_output_variants", "output_variant_groups"}:
            _string_list(
                producer.get(key), f"{where}.producer.{key}", errors,
                nonempty=key in {
                    "completion_receipt_ids", "expiry_receipt_ids", "state_delta_keys"})
        output_variants = producer.get("conditional_output_variants")
        if not isinstance(output_variants, list):
            errors.append(
                f"{where}.producer.conditional_output_variants: expected array")
        else:
            variant_ids: list[str] = []
            for variant_index, raw_variant in enumerate(output_variants):
                variant_where = (
                    f"{where}.producer.conditional_output_variants["
                    f"{variant_index}]")
                variant = _exact_fields(
                    raw_variant, CONDITIONAL_OUTPUT_VARIANT_FIELDS,
                    variant_where, errors)
                if not variant:
                    continue
                variant_id = variant.get("variant_id")
                if not isinstance(variant_id, str) or not variant_id:
                    errors.append(
                        f"{variant_where}.variant_id: expected non-empty string")
                else:
                    variant_ids.append(variant_id)
                activations = _string_list(
                    variant.get("activation_ids"),
                    f"{variant_where}.activation_ids", errors,
                    nonempty=True)
                _validate_activation_roles(variant, variant_where, errors)
                if not activations:
                    errors.append(
                        f"{variant_where}: expected at least one activation ID")
                produced_variant_facts = _string_list(
                    variant.get("produced_fact_ids"),
                    f"{variant_where}.produced_fact_ids", errors,
                    nonempty=True)
                if set(produced_variant_facts) & {"event_log", "action_log"}:
                    errors.append(
                        f"{variant_where}.produced_fact_ids: display-only logs cannot be causal outputs")
                _string_list(
                    variant.get("effect_contract_ids"),
                    f"{variant_where}.effect_contract_ids", errors)
                _string_list(
                    variant.get("runtime_proof_ids"),
                    f"{variant_where}.runtime_proof_ids", errors,
                    nonempty=True)
                if (not isinstance(variant.get("selection_group_id"), str)
                        or not variant["selection_group_id"]):
                    errors.append(
                        f"{variant_where}.selection_group_id: expected non-empty string")
            if len(variant_ids) != len(set(variant_ids)):
                errors.append(
                    f"{where}.producer.conditional_output_variants: duplicate variant ID")
        output_groups = producer.get("output_variant_groups")
        if not isinstance(output_groups, list):
            errors.append(
                f"{where}.producer.output_variant_groups: expected array")
        else:
            group_ids: list[str] = []
            for group_index, raw_group in enumerate(output_groups):
                group_where = (
                    f"{where}.producer.output_variant_groups[{group_index}]")
                group = _exact_fields(
                    raw_group, OUTPUT_VARIANT_GROUP_FIELDS,
                    group_where, errors)
                group_id = group.get("selection_group_id")
                if not isinstance(group_id, str) or not group_id:
                    errors.append(
                        f"{group_where}.selection_group_id: expected non-empty string")
                else:
                    group_ids.append(group_id)
                if group.get("selection_mode") not in {
                        "exactly_one", "at_most_one"}:
                    errors.append(
                        f"{group_where}.selection_mode: invalid mode")
            if len(group_ids) != len(set(group_ids)):
                errors.append(
                    f"{where}.producer.output_variant_groups: duplicate group ID")
            variant_group_ids = {
                variant.get("selection_group_id") for variant in output_variants
                if isinstance(variant, dict)} \
                if isinstance(output_variants, list) else set()
            if variant_group_ids != set(group_ids):
                errors.append(
                    f"{where}.producer.output_variant_groups: must exactly cover variant groups")

    terminal = _exact_fields(obj.get("terminal_contract"), TERMINAL_FIELDS,
                             f"{where}.terminal_contract", errors)
    if terminal:
        if not isinstance(terminal.get("repeatable_after_completion"), bool):
            errors.append(f"{where}.terminal_contract.repeatable_after_completion: expected bool")
        for key in ("completed_surface", "expired_surface"):
            if terminal.get(key) not in {"same_card", "replacement", "hidden"}:
                errors.append(f"{where}.terminal_contract.{key}: invalid surface")
        if terminal.get("reentry_cost") is not None and not isinstance(
                terminal.get("reentry_cost"), dict):
            errors.append(f"{where}.terminal_contract.reentry_cost: expected object|null")

    verbs = _exact_fields(obj.get("next_verb_by_terminal"), NEXT_VERB_FIELDS,
                          f"{where}.next_verb_by_terminal", errors)
    for key in NEXT_VERB_FIELDS:
        _string_list(verbs.get(key), f"{where}.next_verb_by_terminal.{key}", errors)
    for key in ("build_facts", "near_reader_ids", "milestone_reader_ids",
                "runtime_proof_ids"):
        _string_list(obj.get(key), f"{where}.{key}", errors, nonempty=True)
    chain_id = obj.get("chain_id")
    month = obj.get("month")
    near_reader_ids = obj.get("near_reader_ids", [])
    milestone_reader_ids = obj.get("milestone_reader_ids", [])
    runtime_proof_ids = obj.get("runtime_proof_ids", [])
    if (isinstance(chain_id, str)
            and f"reader:near:{chain_id}" not in near_reader_ids):
        errors.append(f"{where}.near_reader_ids: missing named near causal reader")
    if (_is_int(month)
            and f"reader:month:m{month:02d}:summary" not in milestone_reader_ids):
        errors.append(f"{where}.milestone_reader_ids: missing month-end reader")
    if "reader:chapter1_end_snapshot" not in milestone_reader_ids:
        errors.append(f"{where}.milestone_reader_ids: missing W48 snapshot reader")
    if (isinstance(chain_id, str)
            and f"proof:row:{chain_id}" not in runtime_proof_ids):
        errors.append(f"{where}.runtime_proof_ids: missing row runtime proof")
    if not any("save_roundtrip" in proof_id for proof_id in runtime_proof_ids):
        errors.append(f"{where}.runtime_proof_ids: missing save roundtrip proof")

    missed = _exact_fields(obj.get("missed_contract"), MISSED_FIELDS,
                           f"{where}.missed_contract", errors)
    if missed:
        for key in MISSED_FIELDS - {"changes_future_availability"}:
            _string_list(missed.get(key), f"{where}.missed_contract.{key}", errors)
        if not isinstance(missed.get("changes_future_availability"), bool):
            errors.append(f"{where}.missed_contract.changes_future_availability: expected bool")
    surfaces = _exact_fields(obj.get("surface_pointers"), SURFACE_FIELDS,
                             f"{where}.surface_pointers", errors)
    for key in SURFACE_FIELDS:
        _string_list(surfaces.get(key), f"{where}.surface_pointers.{key}", errors,
                     nonempty=True)


def _validate_baseline(baseline: Any) -> tuple[list[str], dict[str, list[str]]]:
    errors: list[str] = []
    if not isinstance(baseline, dict):
        return ["baseline: expected object"], {}
    unknown = sorted(set(baseline) - set(ERROR_CODES))
    if unknown:
        errors.append(f"baseline: unknown error codes {unknown}")
    normalized: dict[str, list[str]] = {}
    for code, raw_ids in baseline.items():
        ids = _string_list(raw_ids, f"baseline.{code}", errors, nonempty=True)
        if ids != sorted(ids):
            errors.append(f"baseline.{code}: IDs must be sorted")
        if ids:
            normalized[code] = sorted(ids)
    return errors, normalized


def validate(ledger: Any, baseline: Any, *, require_complete: bool = False,
             check_pointers: bool = True,
             check_sources: bool = True,
             synthetic_source_contracts: bool = False,
             enforce_audited_snapshot: bool = True,
             self_test_probe: bool = False,
             self_test_skip_w24_source_census: bool = False,
             ) -> tuple[list[str], dict[str, Any]]:
    errors: list[str] = []
    obj = _exact_fields(ledger, ROOT_FIELDS, "ledger", errors)
    baseline_errors, normalized_baseline = _validate_baseline(baseline)
    errors.extend(baseline_errors)
    metrics: dict[str, Any] = {
        "implemented": 0, "missing": 48, "week_range": [], "debts": {},
    }
    if not obj:
        return errors, metrics
    if (enforce_audited_snapshot
            and _semantic_digest(obj) != AUDITED_LEDGER_SEMANTIC_SHA256):
        errors.append(
            "ledger: audited semantic snapshot mismatch; update source, ledger, and checker contract together")
    if enforce_audited_snapshot:
        for relative_path, expected_digest in \
                EXPECTED_AUDITED_SOURCE_FILE_SHA256.items():
            if _file_digest(relative_path) != expected_digest:
                errors.append(
                    f"source: audited file snapshot mismatch {relative_path}")
    if not _is_int(obj.get("schema_version")) or obj["schema_version"] < 1:
        errors.append("ledger.schema_version: expected positive integer")
    if not isinstance(obj.get("ledger_id"), str) or not obj["ledger_id"]:
        errors.append("ledger.ledger_id: expected non-empty string")
    scope = _exact_fields(obj.get("scope"), SCOPE_FIELDS, "ledger.scope", errors)
    if scope:
        exact_scope = {
            "chapter_id": "chapter1",
            "target_week_range": [1, 48],
            "target_month_range": [1, 12],
            "target_row_count": 48,
            "rows_per_month": 4,
            "slot_owner_order": FAMILIES,
            "milestone_weeks": list(range(4, 49, 4)),
            "run_origin": "fresh_seoul_cycle_v1",
            "run_origin_runtime_proof_ids": [
                "proof:data:fresh_run_origin_application_sent",
                "proof:scope:fresh_father_player_initiative",
            ],
        }
        for key, expected in exact_scope.items():
            if scope.get(key) != expected:
                errors.append(f"ledger.scope.{key}: expected exact {expected!r}")
    build_families = obj.get("build_families")
    if not isinstance(build_families, list) or len(build_families) != 4:
        errors.append("ledger.build_families: expected four family contracts")
    else:
        seen_slot_owners: list[str] = []
        for index, family in enumerate(build_families):
            item = _exact_fields(family, BUILD_FAMILY_FIELDS,
                                 f"build_families[{index}]", errors)
            if not item:
                continue
            owners = _string_list(item.get("allowed_slot_owners"),
                                  f"build_families[{index}].allowed_slot_owners",
                                  errors, nonempty=True)
            _string_list(item.get("source_action_ids"),
                         f"build_families[{index}].source_action_ids", errors,
                         nonempty=True)
            if item.get("layer_owner") != "weekly_action":
                errors.append(f"build_families[{index}].layer_owner: expected weekly_action")
            if len(owners) == 1:
                owner = owners[0]
                seen_slot_owners.append(owner)
                if BUILD_FAMILY_BY_SLOT.get(owner) != item.get("build_family_id"):
                    errors.append(f"build_families[{index}]: owner/family ID disagrees")
                if item.get("source_action_ids") != \
                        EXPECTED_SOURCE_ACTION_IDS_BY_SLOT.get(owner):
                    errors.append(
                        f"build_families[{index}].source_action_ids: audited source action set mismatch")
        if seen_slot_owners != FAMILIES:
            errors.append(f"ledger.build_families: expected slot owner order {FAMILIES}")

    registry_ids = {
        name: _registry_ids(obj, name, errors) for name in REGISTRY_ID_FIELDS
    }
    readers = registry_ids["reader_registry"]
    milestone_ids = registry_ids["milestone_registry"]
    proofs = registry_ids["runtime_proof_registry"]
    counterfactuals = registry_ids["counterfactual_registry"]
    reader_records_by_id = {
        item.get("reader_id"): item for item in obj.get("reader_registry", [])
        if isinstance(item, dict) and isinstance(item.get("reader_id"), str)
    }
    proof_records_by_id = {
        item.get("proof_id"): item for item in obj.get("runtime_proof_registry", [])
        if isinstance(item, dict) and isinstance(item.get("proof_id"), str)
    }
    for ref in scope.get("run_origin_runtime_proof_ids", []) \
            if isinstance(scope, dict) else []:
        if ref not in proofs:
            errors.append(f"ledger.scope: missing run-origin runtime proof {ref}")

    for index, proof in enumerate(obj.get("runtime_proof_registry", [])):
        item = _exact_fields(proof, RUNTIME_PROOF_FIELDS,
                             f"runtime_proof_registry[{index}]", errors)
        if not item:
            continue
        if item.get("kind") not in {"json_pointer", "source_symbol", "canon_anchor"}:
            errors.append(f"runtime_proof_registry[{index}].kind: invalid proof kind")
        for key in ("pointer", "assertion"):
            if not isinstance(item.get(key), str) or not item[key]:
                errors.append(f"runtime_proof_registry[{index}].{key}: expected non-empty string")
        pointer = item.get("pointer", "")
        kind = item.get("kind")
        pointer_path = (pointer.split("#/", 1)[0]
                        if isinstance(pointer, str) and "#/" in pointer
                        else pointer.split("::", 1)[0]
                        if isinstance(pointer, str) and "::" in pointer
                        else "")
        if not pointer_path or _repo_source_path(pointer_path) is None:
            errors.append(
                f"runtime_proof_registry[{index}]: source path must be a "
                "canonical repo-relative trust key")
        kind_matches = (
            (kind == "json_pointer" and isinstance(pointer, str)
             and "#/" in pointer)
            or (kind == "source_symbol" and isinstance(pointer, str)
                and ".gd::" in pointer)
            or (kind == "canon_anchor" and isinstance(pointer, str)
                and ".md::" in pointer))
        if not kind_matches:
            errors.append(
                f"runtime_proof_registry[{index}]: kind does not match pointer form")

    if not synthetic_source_contracts:
        expected_proof_ids = set(EXPECTED_RUNTIME_PROOF_BINDING_DIGESTS)
        if proofs != expected_proof_ids:
            errors.append(
                "runtime_proof_registry: exact audited proof ID set mismatch")
        proof_source_cache: dict[Path, Any] = {}
        if not self_test_probe:
            for proof_id in sorted(proofs & expected_proof_ids):
                proof = proof_records_by_id.get(proof_id, {})
                if (_proof_binding_digest(proof, proof_source_cache)
                        != EXPECTED_RUNTIME_PROOF_BINDING_DIGESTS[proof_id]):
                    errors.append(
                        "runtime_proof_registry: audited binding mismatch "
                        f"{proof_id}")
        referenced_proofs = _runtime_proof_references(obj)
        unreferenced_proofs = proofs - referenced_proofs
        if unreferenced_proofs != EXPLICIT_TOP_LEVEL_EVIDENCE_PROOF_IDS:
            errors.append(
                "runtime_proof_registry: unreferenced proofs must equal explicit top-level evidence allowlist")
        if check_sources and not self_test_probe:
            _validate_save_roundtrip_source_contract(
                proof_records_by_id, errors, proof_source_cache)
            _validate_replay_persistence_source_contract(
                proof_records_by_id, errors, proof_source_cache)

    milestone_weeks: list[int] = []
    milestone_records: list[tuple[int, dict[str, Any], str]] = []
    for index, milestone_record in enumerate(obj.get("milestone_registry", [])):
        where = f"milestone_registry[{index}]"
        item = _exact_fields(milestone_record, MILESTONE_REGISTRY_FIELDS, where, errors)
        if not item:
            continue
        week = item.get("week")
        if not _is_int(week) or week not in range(4, 49, 4):
            errors.append(f"{where}.week: expected Chapter 1 month-end week")
        else:
            milestone_weeks.append(week)
        if item.get("status") not in {"audited_runtime", "coverage_gap"}:
            errors.append(f"{where}.status: invalid milestone status")
        reader_refs = _string_list(item.get("reader_ids"), f"{where}.reader_ids", errors)
        proof_refs = _string_list(item.get("runtime_proof_ids"),
                                  f"{where}.runtime_proof_ids", errors, nonempty=True)
        for ref in reader_refs:
            if ref not in readers:
                errors.append(f"{where}: missing reader {ref}")
        for ref in proof_refs:
            if ref not in proofs:
                errors.append(f"{where}: missing runtime proof {ref}")
        pointer = item.get("runtime_pointer")
        if pointer is not None and (not isinstance(pointer, str) or not pointer):
            errors.append(f"{where}.runtime_pointer: expected string|null")
        if item.get("status") == "audited_runtime" and pointer is None:
            errors.append(f"{where}: audited milestone needs runtime pointer")
        if item.get("status") == "coverage_gap" and pointer is not None:
            errors.append(f"{where}: coverage gap may not invent runtime pointer")
        invocations = item.get("invocations")
        if not isinstance(invocations, list):
            errors.append(f"{where}.invocations: expected array")
            invocations = []
        if item.get("status") == "audited_runtime" and not invocations:
            errors.append(f"{where}.invocations: audited milestone needs invocations")
        if item.get("status") == "coverage_gap" and invocations:
            errors.append(f"{where}.invocations: coverage gap must be empty")
        co_presence_groups = item.get("co_presence_groups")
        if not isinstance(co_presence_groups, list):
            errors.append(f"{where}.co_presence_groups: expected array")
            co_presence_groups = []
        if item.get("status") == "audited_runtime" and not co_presence_groups:
            errors.append(
                f"{where}.co_presence_groups: audited milestone needs groups")
        if item.get("status") == "coverage_gap" and co_presence_groups:
            errors.append(f"{where}.co_presence_groups: coverage gap must be empty")
        execution_stages = item.get("execution_stages")
        if not isinstance(execution_stages, list):
            errors.append(f"{where}.execution_stages: expected array")
            execution_stages = []
        if item.get("status") == "audited_runtime" and not execution_stages:
            errors.append(
                f"{where}.execution_stages: audited milestone needs stages")
        if item.get("status") == "coverage_gap" and execution_stages:
            errors.append(
                f"{where}.execution_stages: coverage gap must be empty")
        if item.get("status") == "audited_runtime" and _is_int(week):
            expected_proof_id = f"proof:milestone:w{week:02d}"
            milestone_proof = proof_records_by_id.get(expected_proof_id, {})
            if (expected_proof_id not in proof_refs
                    or milestone_proof.get("pointer") != pointer):
                errors.append(
                    f"{where}: runtime pointer must match {expected_proof_id}")
        milestone_records.append((index, item, where))
    if sorted(milestone_weeks) != list(range(4, 49, 4)):
        errors.append("milestone_registry: expected exactly one entry for every W4..W48 month end")

    raw_shadowed_reader_ids: set[str] = set()
    shadowed_group_debt_ids: list[str] = []
    shadowed_invocation_membership: dict[str, list[str]] = {}
    fanin_ids: list[str] = []
    active_causal_read_fact_ids: set[str] = set()
    shadowed_read_fact_ids: set[str] = set()
    bound_facts_by_reader: dict[str, set[str]] = {}
    fact_pointer_cache: dict[Path, Any] = {}
    for index, reader in enumerate(obj.get("reader_registry", [])):
        where = f"reader_registry[{index}]"
        item = _exact_fields(reader, READER_REGISTRY_FIELDS, where, errors)
        if not item:
            continue
        if item.get("status") not in {
                "active", "shadowed", "blocked_by_coverage",
                "blocked_by_unscheduled", "authored_blocked_by_coverage"}:
            errors.append(f"{where}.status: invalid reader status")
        reader_kind = item.get("reader_kind")
        if reader_kind not in READER_LAYER_BY_KIND:
            errors.append(f"{where}.reader_kind: unknown reader kind")
        elif item.get("layer_owner") != READER_LAYER_BY_KIND[reader_kind]:
            errors.append(
                f"{where}.layer_owner: expected {READER_LAYER_BY_KIND[reader_kind]}")
        if item.get("status") == "shadowed":
            raw_shadowed_reader_ids.add(str(item.get("reader_id")))
        for key in ("reads_fact_ids", "input_build_family_ids", "story_decision_ids",
                    "runtime_proof_ids", "history_memory_ids",
                    "material_state_ids", "scene_handoff_fact_ids",
                    "scene_handoff_decision_ids"):
            _string_list(item.get(key), f"{where}.{key}", errors)
        reads = item.get("reads_fact_ids", [])
        if set(reads) & {"event_log", "action_log"}:
            errors.append(
                f"{where}.reads_fact_ids: display-only Story logs cannot be causal readers")
        read_contracts = item.get("read_contracts")
        if not isinstance(read_contracts, list):
            errors.append(f"{where}.read_contracts: expected array")
            read_contracts = []
        bound_facts: set[str] = set()
        contract_fact_ids: list[str] = []
        for contract_index, contract_record in enumerate(read_contracts):
            contract_where = f"{where}.read_contracts[{contract_index}]"
            contract = _exact_fields(
                contract_record, READ_CONTRACT_FIELDS, contract_where, errors)
            if not contract:
                continue
            fact_id = contract.get("fact_id")
            if not isinstance(fact_id, str) or not fact_id:
                errors.append(f"{contract_where}.fact_id: expected non-empty string")
                continue
            contract_fact_ids.append(fact_id)
            contract_proofs = _string_list(
                contract.get("runtime_proof_ids"),
                f"{contract_where}.runtime_proof_ids", errors, nonempty=True)
            resolved = [proof_records_by_id[ref] for ref in contract_proofs
                        if ref in proof_records_by_id]
            for ref in contract_proofs:
                if ref not in proofs:
                    errors.append(f"{contract_where}: missing runtime proof {ref}")
            supporting_proofs = [
                proof_records_by_id[ref]
                for ref in set(item.get("runtime_proof_ids", []))
                if ref in proof_records_by_id]
            source_bound = (
                bool(resolved) if synthetic_source_contracts
                else _proofs_bind_reader_fact(
                    item, fact_id, resolved, fact_pointer_cache,
                    supporting_proofs=supporting_proofs))
            if not source_bound:
                errors.append(
                    f"{contract_where}: no runtime proof directly binds fact {fact_id}")
            else:
                bound_facts.add(fact_id)
        if len(contract_fact_ids) != len(set(contract_fact_ids)):
            errors.append(f"{where}.read_contracts: duplicate fact contract")
        if (isinstance(reads, list)
                and set(contract_fact_ids) != set(reads)):
            errors.append(
                f"{where}.read_contracts: must exactly cover reads_fact_ids")
        reader_id = item.get("reader_id")
        if isinstance(reader_id, str):
            bound_facts_by_reader[reader_id] = bound_facts
        month_reader_match = re.fullmatch(
            r"reader:month:m(\d{2}):summary", str(reader_id))
        if (not synthetic_source_contracts and month_reader_match
                and isinstance(reads, list)):
            expected_month_facts = _expected_month_summary_facts(
                int(month_reader_match.group(1)),
                obj.get("rows", []) if isinstance(obj.get("rows"), list)
                else [])
            if reads != expected_month_facts:
                errors.append(
                    f"{where}.reads_fact_ids: exact month receipt mirror mismatch")
        if not synthetic_source_contracts and isinstance(reader_id, str):
            expected_identity: tuple[str, str] | None = None
            if reader_id.startswith("reader:near:"):
                expected_identity = ("display", "summary")
            elif reader_id.startswith("reader:action:"):
                # Presentation ownership and downstream routing are separate.
                # A dual-surface action may keep its atomic result card while
                # `action_story_stage` later consumes the durable receipt.
                # The exact audited consumer therefore owns reader identity;
                # `story_owns_action_result` alone would misclassify those
                # legitimate downstream Story readers as producer results.
                action_pointer = item.get("runtime_pointer")
                if action_pointer == \
                        "systems/DemoCoreLoopV2.gd::action_story_stage":
                    expected_identity = ("near_consequence", "story")
                elif action_pointer == \
                        "systems/DemoCoreLoopV2.gd::recover_action_result":
                    expected_identity = ("producer_result", "weekly_action")
                else:
                    expected_identity = ("producer_result", "weekly_action")
            elif reader_id.startswith((
                    "reader:result:", "reader:next:", "reader:future:")):
                expected_identity = (
                    ("action_unlock", "story")
                    if reader_kind == "action_unlock"
                    else ("next_verb", "story"))
            elif reader_id.startswith("reader:unlock:"):
                expected_identity = ("action_unlock", "story")
            elif reader_id.startswith("reader:month:"):
                expected_identity = ("month_summary", "summary")
            elif reader_id == W24_COMPLETION_APPLICATION_READER_ID:
                # The helper is a real completion gate, but its two inputs are
                # durable state read outside Story's narrative fan-in.  It is
                # separately reported as SHADOWED because source does not join
                # the selected choice to a transition identity.
                expected_identity = ("route_modifier", "story")
            elif reader_id.startswith("reader:milestone:") \
                    or reader_id == "reader:chapter1_end_snapshot":
                expected_identity = ("story_milestone", "story")
            elif reader_id.startswith(
                    "reader:m4_certificate_session:inventory"):
                expected_identity = ("route_modifier", "story")
            if expected_identity is not None and (
                    reader_kind, item.get("layer_owner")) != expected_identity:
                errors.append(
                    f"{where}: reader identity does not match runtime owner")
        if (not synthetic_source_contracts
                and reader_kind == "story_milestone"
                and item.get("status") == "active"
                and isinstance(reader_id, str)):
            expected_pointer = EXPECTED_STORY_READER_POINTERS.get(reader_id)
            if reader_id.startswith("reader:milestone:w04:allocation:"):
                expected_pointer = (
                    "systems/DemoCoreLoopV2.gd::_seoul_cycle_month_one_echo")
            if (expected_pointer is not None
                    and item.get("runtime_pointer") != expected_pointer):
                errors.append(
                    f"{where}.runtime_pointer: does not match audited Story consumer")
            expected_decisions = EXPECTED_STORY_DECISIONS_BY_READER.get(
                reader_id, [])
            if item.get("story_decision_ids") != expected_decisions:
                errors.append(
                    f"{where}.story_decision_ids: does not match source-authored decisions")
            for decision_id in item.get("story_decision_ids", []):
                if not _decision_contract_is_authored(
                        decision_id, fact_pointer_cache):
                    errors.append(
                        f"{where}.story_decision_ids: unauthored decision {decision_id}")
        history_ids = item.get("history_memory_ids", [])
        material_ids = item.get("material_state_ids", [])
        handoff_fact_ids = item.get("scene_handoff_fact_ids", [])
        historical_decision_ids = item.get("story_decision_ids", [])
        handoff_decision_ids = item.get("scene_handoff_decision_ids", [])
        if item.get("status") != "blocked_by_coverage":
            fact_role_sets = [
                set(history_ids), set(material_ids), set(handoff_fact_ids)]
            if any(
                    fact_role_sets[left] & fact_role_sets[right]
                    for left in range(len(fact_role_sets))
                    for right in range(left + 1, len(fact_role_sets))):
                errors.append(
                    f"{where}: story fact input role arrays overlap")
            if set().union(*fact_role_sets) != set(reads):
                errors.append(
                    f"{where}: story input roles must exactly partition reads_fact_ids")
            if set(historical_decision_ids) & set(handoff_decision_ids):
                errors.append(
                    f"{where}: historical and scene-handoff decisions overlap")
            expected_material_ids = {
                fact_id for fact_id in reads
                if fact_id.startswith(MATERIAL_STATE_PREFIXES)
                and fact_id not in set(handoff_fact_ids)
            }
            if set(material_ids) != expected_material_ids:
                errors.append(
                    f"{where}: story material classification does not match source roles")
        if item.get("status") == "blocked_by_coverage":
            blocked_fields = (
                "reads_fact_ids", "input_build_family_ids",
                "story_decision_ids", "runtime_proof_ids", "read_contracts",
                "history_memory_ids", "material_state_ids",
                "scene_handoff_fact_ids", "scene_handoff_decision_ids")
            if item.get("runtime_pointer") is not None or any(
                    item.get(key) for key in blocked_fields):
                errors.append(
                    f"{where}: blocked reader must not invent runtime facts or proof")
        if item.get("status") == "authored_blocked_by_coverage":
            if reader_id != "reader:future:w27:hyunsu_exam_result":
                errors.append(
                    f"{where}: unaudited authored coverage-blocked reader")
            required_gap_proofs = {
                "proof:runtime:turn_limit_24", "proof:canon:w25_w48_gap"}
            if (item.get("runtime_pointer") !=
                    "systems/DemoCoreLoopV2.gd::hyunsu_exam_result_event_id"
                    or not required_gap_proofs.issubset(
                        set(item.get("runtime_proof_ids", [])))):
                errors.append(
                    f"{where}: authored W27 reader lacks cap/gap source contract")
        if (not synthetic_source_contracts
                and isinstance(reader_id, str)
                and reader_id.startswith(
                    "reader:m4_certificate_session:inventory")
                and item.get("status") != "shadowed"):
            errors.append(
                f"{where}: inventory outcome reader remains source-shadowed")
        if (item.get("status") == "active"
                and item.get("reader_kind")
                in CAUSAL_READER_KINDS | {"route_modifier"}):
            active_causal_read_fact_ids.update(bound_facts)
        elif item.get("status") == "shadowed":
            shadowed_read_fact_ids.update(bound_facts)
        for ref in item.get("runtime_proof_ids", []) if isinstance(item.get("runtime_proof_ids"), list) else []:
            if ref not in proofs:
                errors.append(f"{where}: missing runtime proof {ref}")
        for ref in item.get("input_build_family_ids", []) if isinstance(item.get("input_build_family_ids"), list) else []:
            if ref not in set(BUILD_FAMILY_BY_SLOT.values()):
                errors.append(f"{where}: unknown input build family {ref}")
        pointer = item.get("runtime_pointer")
        if pointer is not None and (not isinstance(pointer, str) or not pointer):
            errors.append(f"{where}.runtime_pointer: expected string|null")
        if item.get("status") != "blocked_by_coverage" and pointer is None:
            errors.append(f"{where}: non-blocked reader needs runtime pointer")

    if not synthetic_source_contracts:
        application_reader = reader_records_by_id.get(
            W24_COMPLETION_APPLICATION_READER_ID)
        application_where = (
            "reader_registry["
            f"{W24_COMPLETION_APPLICATION_READER_ID}]")
        if not isinstance(application_reader, dict):
            errors.append(
                f"{application_where}: missing truthful W24 composite gate")
        else:
            exact_application_reader_fields = {
                "reader_kind": "route_modifier",
                "layer_owner": "story",
                "status": "active",
                "reads_fact_ids": W24_COMPLETION_APPLICATION_FACTS,
                "history_memory_ids": W24_COMPLETION_APPLICATION_FACTS,
                "material_state_ids": [],
                "scene_handoff_fact_ids": [],
                "input_build_family_ids": [],
                "story_decision_ids": [],
                "scene_handoff_decision_ids": [],
                "runtime_pointer": (
                    "systems/DemoCoreLoopV2.gd::complete_active_bundle"),
            }
            for field, expected_value in exact_application_reader_fields.items():
                if application_reader.get(field) != expected_value:
                    errors.append(
                        f"{application_where}.{field}: W24 completion must "
                        "record only the generic current-turn application gate")
            if W24_COMPLETION_APPLICATION_DEBT_PROOF_ID not in set(
                    application_reader.get("runtime_proof_ids", [])):
                errors.append(
                    f"{application_where}: missing application identity-gap proof")
            debt_proof = proof_records_by_id.get(
                W24_COMPLETION_APPLICATION_DEBT_PROOF_ID, {})
            if (debt_proof.get("kind") != "source_symbol"
                    or debt_proof.get("pointer") !=
                    "systems/DemoCoreLoopV2.gd::"
                    "_has_current_application_receipt"):
                errors.append(
                    f"{application_where}: application identity-gap proof "
                    "must own the generic receipt helper")
            if not _w24_completion_application_identity_is_shadowed(
                    fact_pointer_cache):
                errors.append(
                    f"{application_where}: source no longer matches the "
                    "audited generic gate/missing identity join")

    if not synthetic_source_contracts:
        prerequisite_readers_by_pointer: dict[
            str, list[dict[str, Any]]] = {}
        scheduled_unlock_readers_by_pointer: dict[
            str, list[dict[str, Any]]] = {}
        for reader in reader_records_by_id.values():
            pointer = reader.get("runtime_pointer")
            if (reader.get("status") in {"active", "blocked_by_unscheduled"}
                    and isinstance(pointer, str)
                    and pointer.endswith("/prerequisites")):
                if reader.get("reader_kind") == "action_unlock":
                    scheduled_unlock_readers_by_pointer.setdefault(
                        pointer, []).append(reader)
                else:
                    prerequisite_readers_by_pointer.setdefault(
                        pointer, []).append(reader)
        expected_scheduled_pointers = \
            _expected_scheduled_prerequisite_pointers(
                obj.get("rows", []) if isinstance(obj.get("rows"), list)
                else [], fact_pointer_cache)
        if set(scheduled_unlock_readers_by_pointer) != \
                expected_scheduled_pointers:
            errors.append(
                "reader_registry: exact scheduled prerequisite pointer set mismatch")
        prerequisite_contract_groups = {
            **prerequisite_readers_by_pointer,
            **scheduled_unlock_readers_by_pointer,
        }
        for pointer, pointer_readers in prerequisite_contract_groups.items():
            expected_variants = _prerequisite_fact_variants(
                pointer, fact_pointer_cache)
            actual_variants = [
                reader.get("reads_fact_ids", []) for reader in pointer_readers]
            if expected_variants is None:
                errors.append(
                    f"reader_registry: unsupported source prerequisite DSL {pointer}")
            elif len(expected_variants) == 1:
                if any(variant != expected_variants[0]
                       for variant in actual_variants):
                    errors.append(
                        f"reader_registry: source prerequisite contract mismatch {pointer}")
            elif sorted(tuple(variant) for variant in actual_variants) != \
                    sorted(tuple(variant) for variant in expected_variants):
                errors.append(
                    f"reader_registry: source prerequisite any-variant coverage mismatch {pointer}")

        rows_for_prerequisites = [
            row for row in obj.get("rows", []) if isinstance(row, dict)]
        fact_producers = _source_prerequisite_fact_producers(
            rows_for_prerequisites, fact_pointer_cache)
        action_unlock_ids = {
            reader_id for reader_id, reader in reader_records_by_id.items()
            if reader.get("reader_kind") == "action_unlock"
            and reader.get("status") != "blocked_by_coverage"
        }
        actual_rows_by_unlock: dict[str, set[str]] = {
            reader_id: set() for reader_id in action_unlock_ids}
        for row in rows_for_prerequisites:
            chain_id = row.get("chain_id")
            if not isinstance(chain_id, str):
                continue
            for reader_id in row.get("near_reader_ids", []):
                if reader_id in action_unlock_ids:
                    actual_rows_by_unlock[reader_id].add(chain_id)

        external_reader_ids = {
            "reader:unlock:hyunsu_player_reachout:hyunsu_honest_uncertainty",
            "reader:unlock:hyunsu_player_reachout:hyunsu_declared_dream",
        }
        unscheduled_reader_id = "reader:unlock:jaehyuk_world_meet"
        routine_reader_id = "reader:unlock:daeun_world_meet"
        months_by_chain = {
            str(row.get("chain_id")): int(row.get("month"))
            for row in rows_for_prerequisites
            if isinstance(row.get("chain_id"), str)
            and _is_int(row.get("month"))}

        def source_owner_rows(reader_id: str,
                              reader: dict[str, Any]) -> set[str]:
            expected_rows: set[str] = set()
            completed_owner_rows: set[str] = set()
            for fact_id in reader.get("reads_fact_ids", []):
                if (isinstance(fact_id, str)
                        and fact_id.startswith("receipt:completed:")):
                    completed_owner_rows.update(
                        fact_producers.get(fact_id, set()))
                elif (isinstance(fact_id, str)
                        and fact_id.startswith("receipt:application:")
                        and ":not_in:" in fact_id):
                    application_id = fact_id.split(":", 3)[2]
                    candidates = fact_producers.get(
                        f"source:application:{application_id}", set())
                    if candidates:
                        earliest = min(months_by_chain.get(chain, 99)
                                       for chain in candidates)
                        expected_rows.update(
                            chain for chain in candidates
                            if months_by_chain.get(chain) == earliest)
                elif isinstance(fact_id, str):
                    expected_rows.update(fact_producers.get(fact_id, set()))
            # A scheduled prerequisite is owned by its completed-bundle
            # producer.  Reusing a later row that happens to write the same
            # relationship stage cannot create a second causal back-reference.
            if completed_owner_rows:
                expected_rows = completed_owner_rows

            if reader_id in external_reader_ids \
                    or reader_id == unscheduled_reader_id:
                return set()
            if reader_id == routine_reader_id:
                return {"m1_convenience", "m2_livelihood"}
            return expected_rows

        for reader_id in sorted(action_unlock_ids):
            reader = reader_records_by_id[reader_id]
            expected_rows = source_owner_rows(reader_id, reader)

            proof_ids = reader.get("runtime_proof_ids", [])
            if reader_id in external_reader_ids:
                if (reader.get("status") != "active"
                        or not {
                            "proof:data:world_clock:m1_hyunsu_first_meet",
                            "proof:data:world_clock:hyunsu_first_meet_relationship_outcomes",
                            "proof:runtime:bundle_completion",
                            "proof:runtime:relationship_receipt",
                        }.issubset(set(proof_ids))):
                    errors.append(
                        f"reader_registry: external world-clock producer contract mismatch {reader_id}")
            elif reader_id == unscheduled_reader_id:
                if (reader.get("status") != "blocked_by_unscheduled"
                        or "proof:debt:unscheduled_sns_pressure" not in proof_ids):
                    errors.append(
                        "reader_registry: unscheduled prerequisite must remain blocked and debt-bound")
            elif reader_id == routine_reader_id:
                if (reader.get("reads_fact_ids")
                        != ["fact:routine_selected:livelihood"]
                        or "proof:runtime:routine_selected_livelihood_aggregation"
                        not in proof_ids):
                    errors.append(
                        "reader_registry: livelihood routine aggregate source contract mismatch")
            if actual_rows_by_unlock.get(reader_id, set()) != expected_rows:
                errors.append(
                    f"reader_registry: producer row reverse-reference mismatch {reader_id}")

        for row in rows_for_prerequisites:
            chain_id = str(row.get("chain_id", ""))
            for reader_id in row.get("near_reader_ids", []):
                if (reader_id in action_unlock_ids
                        and chain_id not in actual_rows_by_unlock.get(
                            reader_id, set())):
                    errors.append(
                        f"rows: orphan prerequisite reader reference {chain_id} -> {reader_id}")

        # A missed row changes future availability exactly when a later active
        # unlock/result reader consumes one of its source-owned facts.  This is
        # derived from the reader graph rather than a prefix-boundary chain
        # allowlist, so the W27 Hyunsu receipt remains visible from Month 6.
        availability_change_chains: set[str] = set()
        for reader_id, reader in reader_records_by_id.items():
            if (reader.get("status") not in {
                    "active", "authored_blocked_by_coverage"}
                    or reader.get("reader_kind") not in {
                        "action_unlock", "next_verb"}):
                continue
            availability_change_chains.update(
                source_owner_rows(reader_id, reader))
        for row in rows_for_prerequisites:
            chain_id = str(row.get("chain_id", ""))
            expected_change = chain_id in availability_change_chains
            if row.get("missed_contract", {}).get(
                    "changes_future_availability") is not expected_change:
                errors.append(
                    f"rows: missed future-availability source graph mismatch {chain_id}")

        active_story_reader_ids = {
            reader_id for reader_id, reader in reader_records_by_id.items()
            if reader.get("status") == "active"
            and reader.get("reader_kind") == "story_milestone"
        }
        expected_story_reader_ids = set(EXPECTED_STORY_INPUTS_BY_READER)
        if active_story_reader_ids != expected_story_reader_ids:
            errors.append(
                "reader_registry: active Story reader ID set does not match audited prefix")
        for reader_id in sorted(
                active_story_reader_ids & expected_story_reader_ids):
            reader = reader_records_by_id[reader_id]
            actual_story_inputs = (
                reader.get("reads_fact_ids"),
                reader.get("history_memory_ids"),
                reader.get("material_state_ids"),
                reader.get("story_decision_ids"),
                reader.get("scene_handoff_fact_ids"),
                reader.get("scene_handoff_decision_ids"),
            )
            if actual_story_inputs != EXPECTED_STORY_INPUTS_BY_READER[reader_id]:
                errors.append(
                    f"reader_registry: Story input tuple source mismatch {reader_id}")
    invocation_ids: set[str] = set()
    invocation_records_by_id: dict[str, dict[str, Any]] = {}
    co_presence_ids: set[str] = set()
    invocation_membership: dict[str, list[str]] = {}
    # One tuple is one source-compatible reader/producer option for an
    # invocation: historical memories, historical decisions, unnamed-input
    # flag, same-scene handoff facts, same-scene handoff decisions, and exact
    # source entry modes.  The path-sensitive components are retained per
    # option so a cold-only variant is not unioned into every live scenario
    # (and vice versa).
    invocation_combinations_by_id: dict[
        str, list[tuple[
            set[str], set[str], bool, set[str], set[str],
            frozenset[str], frozenset[str], frozenset[str]]]] = {}
    invocation_reader_variant_ids: dict[str, set[str]] = {}
    invocation_producer_variant_ids: dict[str, set[str]] = {}
    invocation_pointers_by_id: dict[str, str] = {}
    invocation_stage_index_by_id: dict[str, int] = {}
    invocation_stage_id_by_id: dict[str, str] = {}
    invocation_stage_milestone_by_id: dict[str, str] = {}
    invocation_source_scenarios_by_id: dict[str, set[tuple[str, int]]] = {}
    stage_ancestors_by_source_scenario: dict[
        tuple[str, int], dict[str, set[str]]] = {}
    source_scenario_entry_mode: dict[tuple[str, int], str] = {}
    invocation_handoff_fact_inputs: dict[str, set[str]] = {}
    invocation_handoff_decision_inputs: dict[str, set[str]] = {}
    invocation_produced_handoff_facts: dict[str, set[str]] = {}
    # One producer option retains both sides of the causal edge: the facts /
    # decisions it emits, and the path-local handoffs that exact producer
    # selection first consumes.  Dropping the latter lets an invocation that
    # is executable through one sibling variant lend a different, impossible
    # sibling's output to a downstream consumer.
    invocation_produced_handoff_options: dict[
        str, list[tuple[
            set[str], set[str], set[str], set[str], frozenset[str]]]] = {}
    handoff_fact_owner_invocations: dict[str, set[str]] = {}
    handoff_decision_owner_invocations: dict[str, set[str]] = {}
    invocation_produced_scene_decisions: dict[str, set[str]] = {}
    invocation_co_presence_group: dict[str, str] = {}

    all_entry_modes = frozenset({"fresh", "reentry", "cold"})

    def explicit_entry_mode(value_id: str) -> str | None:
        """Return the source entry mode encoded by a canonical variant ID."""
        segments = value_id.split(":")
        if any(segment == "loaded" or segment.startswith("loaded_")
               for segment in segments):
            return "cold"
        if "reentry" in segments:
            return "reentry"
        if "fresh" in segments:
            return "fresh"
        return None

    def mode_constraints_for_group(
            member_ids: list[str]) -> dict[str, frozenset[str]]:
        """Bind mixed fresh/loaded/re-entry variants to their source path.

        A plain member covers the source modes not named by its explicit
        siblings (for example, live fresh/re-entry beside `:loaded`).  Groups
        with no mode-labelled sibling remain valid on every source entry path.
        """
        explicit_modes = {
            mode for member_id in member_ids
            if (mode := explicit_entry_mode(member_id)) is not None}
        result: dict[str, frozenset[str]] = {}
        for member_id in member_ids:
            explicit = explicit_entry_mode(member_id)
            if explicit is not None:
                result[member_id] = frozenset({explicit})
            elif explicit_modes:
                # An unlabelled sibling is the complement of the explicitly
                # persisted modes.  In particular, a plain "live choice"
                # variant remains valid after prepare-context re-entry; only
                # the `:loaded` sibling is restricted to a cold Story resume.
                result[member_id] = frozenset(
                    set(all_entry_modes) - explicit_modes)
            else:
                result[member_id] = all_entry_modes
        return result

    handoff_feasibility_cache: dict[
        tuple[
            str, frozenset[str], frozenset[str], tuple[str, int],
            frozenset[str]], bool] = {}

    def handoff_option_is_feasible(
            consumer_invocation_id: str,
            required_facts: set[str],
            required_decisions: set[str],
            scenario_key: tuple[str, int],
            allowed_entry_modes: frozenset[str] = all_entry_modes,
    ) -> bool:
        """Whether one exact input option has an earlier path-local owner.

        Each upstream invocation contributes one compatible producer option.
        Keeping those options separate prevents sibling outputs from being
        unioned into an impossible receipt set, while scenario ancestry
        prevents a fresh owner from satisfying a cold consumer (or a later
        stage from satisfying an earlier one).
        """
        cache_key = (
            consumer_invocation_id,
            frozenset(required_facts),
            frozenset(required_decisions),
            scenario_key,
            allowed_entry_modes,
        )
        if cache_key in handoff_feasibility_cache:
            return handoff_feasibility_cache[cache_key]
        if source_scenario_entry_mode.get(
                scenario_key, "fresh") not in allowed_entry_modes:
            handoff_feasibility_cache[cache_key] = False
            return False
        if not required_facts and not required_decisions:
            handoff_feasibility_cache[cache_key] = True
            return True
        consumer_group = invocation_co_presence_group.get(
            consumer_invocation_id)
        consumer_is_non_story = not any(
            reader_records_by_id.get(reader_id, {}).get("reader_kind")
                == "story_milestone"
            for reader_id, memberships in invocation_membership.items()
            if consumer_invocation_id in memberships)
        consumer_stage = invocation_stage_index_by_id.get(
            consumer_invocation_id)
        consumer_milestone = invocation_stage_milestone_by_id.get(
            consumer_invocation_id)
        consumer_stage_id = invocation_stage_id_by_id.get(
            consumer_invocation_id, "")
        ancestors = stage_ancestors_by_source_scenario.get(
            scenario_key, {}).get(consumer_stage_id, set())
        owner_axes: list[list[tuple[frozenset[str], frozenset[str]]]] = []
        candidate_owner_ids: set[str] = set()
        for fact_id in required_facts:
            candidate_owner_ids.update(
                handoff_fact_owner_invocations.get(fact_id, set()))
        for decision_id in required_decisions:
            candidate_owner_ids.update(
                handoff_decision_owner_invocations.get(decision_id, set()))
        for owner_invocation_id in sorted(candidate_owner_ids):
            output_options = invocation_produced_handoff_options.get(
                owner_invocation_id, [])
            owner_is_non_story = not any(
                reader_records_by_id.get(reader_id, {}).get("reader_kind")
                    == "story_milestone"
                for reader_id, memberships in invocation_membership.items()
                if owner_invocation_id in memberships)
            if (owner_invocation_id == consumer_invocation_id
                    or (invocation_co_presence_group.get(owner_invocation_id)
                        != consumer_group
                        and not owner_is_non_story
                        and not consumer_is_non_story)
                    or invocation_stage_milestone_by_id.get(
                        owner_invocation_id) != consumer_milestone
                    or scenario_key not in
                        invocation_source_scenarios_by_id.get(
                            owner_invocation_id, set())
                    or invocation_stage_id_by_id.get(owner_invocation_id)
                        not in ancestors
                    or invocation_stage_index_by_id.get(
                        owner_invocation_id, 10_000)
                        >= (consumer_stage
                            if _is_int(consumer_stage) else -1)):
                continue
            relevant_options = {
                (
                    frozenset(facts & required_facts),
                    frozenset(decisions & required_decisions),
                )
                for facts, decisions, input_facts, input_decisions,
                    option_entry_modes in output_options
                if handoff_option_is_feasible(
                    owner_invocation_id,
                    input_facts,
                    input_decisions,
                    scenario_key,
                    option_entry_modes)
            }
            if (relevant_options
                    and relevant_options
                    != {(frozenset(), frozenset())}):
                owner_axes.append(sorted(
                    relevant_options,
                    key=lambda item: (sorted(item[0]), sorted(item[1]))))

        # Dynamic set-cover over the small required handoff tuple.  States are
        # clipped to required inputs, so even a producer with many authored
        # variants cannot make this Cartesian search explode.
        states: set[tuple[frozenset[str], frozenset[str]]] = {
            (frozenset(), frozenset())}
        for options in owner_axes:
            next_states: set[tuple[frozenset[str], frozenset[str]]] = set()
            for have_facts, have_decisions in states:
                for option_facts, option_decisions in options:
                    next_states.add((
                        frozenset(set(have_facts) | set(option_facts)),
                        frozenset(set(have_decisions)
                                  | set(option_decisions)),
                    ))
            states = next_states
            if any(required_facts.issubset(facts)
                   and required_decisions.issubset(decisions)
                   for facts, decisions in states):
                handoff_feasibility_cache[cache_key] = True
                return True
        result = any(required_facts.issubset(facts)
                     and required_decisions.issubset(decisions)
                     for facts, decisions in states)
        handoff_feasibility_cache[cache_key] = result
        return result

    for _, milestone, milestone_where in milestone_records:
        milestone_reader_refs = milestone.get("reader_ids", [])
        if not isinstance(milestone_reader_refs, list):
            milestone_reader_refs = []
        local_membership: list[str] = []
        local_invocation_ids: list[str] = []
        local_execution_scenarios: list[
            tuple[frozenset[str], dict[str, set[str]]]] = []
        for invocation_index, invocation_record in enumerate(
                milestone.get("invocations", [])
                if isinstance(milestone.get("invocations"), list) else []):
            invocation_where = (
                f"{milestone_where}.invocations[{invocation_index}]")
            invocation = _exact_fields(
                invocation_record, MILESTONE_INVOCATION_FIELDS,
                invocation_where, errors)
            if not invocation:
                continue
            invocation_id = invocation.get("invocation_id")
            if not isinstance(invocation_id, str) or not invocation_id:
                errors.append(
                    f"{invocation_where}.invocation_id: expected non-empty string")
                invocation_id = f"invalid:{milestone_where}:{invocation_index}"
            elif invocation_id in invocation_ids:
                errors.append(
                    f"milestone_registry: duplicate invocation ID {invocation_id}")
            else:
                invocation_ids.add(invocation_id)
            local_invocation_ids.append(invocation_id)
            invocation_records_by_id[invocation_id] = invocation
            if not synthetic_source_contracts:
                expected_invocation_digest = \
                    EXPECTED_INVOCATION_CONTRACT_DIGESTS.get(invocation_id)
                if (expected_invocation_digest is None
                        or _semantic_digest(invocation)
                        != expected_invocation_digest):
                    errors.append(
                        f"{invocation_where}: audited invocation source topology mismatch")
            invocation_pointer = invocation.get("runtime_pointer")
            if not isinstance(invocation_pointer, str) or not invocation_pointer:
                errors.append(
                    f"{invocation_where}.runtime_pointer: expected non-empty string")
            else:
                invocation_pointers_by_id[invocation_id] = invocation_pointer
            invocation_proofs = _string_list(
                invocation.get("runtime_proof_ids"),
                f"{invocation_where}.runtime_proof_ids", errors, nonempty=True)
            resolved_invocation_proofs = [
                proof_records_by_id[ref] for ref in invocation_proofs
                if ref in proof_records_by_id]
            for ref in invocation_proofs:
                if ref not in proofs:
                    errors.append(f"{invocation_where}: missing runtime proof {ref}")
            if (isinstance(invocation_pointer, str) and invocation_pointer
                    and not any(proof.get("pointer") == invocation_pointer
                                for proof in resolved_invocation_proofs)):
                errors.append(
                    f"{invocation_where}: runtime pointer lacks matching invocation proof")

            always = _string_list(
                invocation.get("always_reader_ids"),
                f"{invocation_where}.always_reader_ids", errors)
            conditionals = invocation.get("conditional_readers")
            if not isinstance(conditionals, list):
                errors.append(f"{invocation_where}.conditional_readers: expected array")
                conditionals = []
            groups = invocation.get("exclusive_variant_groups")
            if not isinstance(groups, list):
                errors.append(
                    f"{invocation_where}.exclusive_variant_groups: expected array")
                groups = []
            conditional_producers = invocation.get("conditional_producers")
            if not isinstance(conditional_producers, list):
                errors.append(
                    f"{invocation_where}.conditional_producers: expected array")
                conditional_producers = []
            producer_variant_groups = invocation.get(
                "producer_variant_groups")
            if not isinstance(producer_variant_groups, list):
                errors.append(
                    f"{invocation_where}.producer_variant_groups: expected array")
                producer_variant_groups = []
            producer_groups_by_id: dict[str, dict[str, Any]] = {}
            for producer_group_index, producer_group_record in enumerate(
                    producer_variant_groups):
                producer_group_where = (
                    f"{invocation_where}.producer_variant_groups["
                    f"{producer_group_index}]")
                producer_group = _exact_fields(
                    producer_group_record, PRODUCER_VARIANT_GROUP_FIELDS,
                    producer_group_where, errors)
                if not producer_group:
                    continue
                producer_group_id = producer_group.get("selection_group_id")
                if (not isinstance(producer_group_id, str)
                        or not producer_group_id):
                    errors.append(
                        f"{producer_group_where}.selection_group_id: "
                        "expected non-empty string")
                    continue
                if producer_group_id in producer_groups_by_id:
                    errors.append(
                        f"{invocation_where}.producer_variant_groups: "
                        f"duplicate group {producer_group_id}")
                producer_groups_by_id[producer_group_id] = producer_group
                if producer_group.get("selection_mode") not in {
                        "exactly_one", "at_most_one"}:
                    errors.append(
                        f"{producer_group_where}.selection_mode: invalid mode")
                if producer_group.get("causal_status") not in {
                        "active", "terminal_no_current_reader",
                        "authored_blocked_by_coverage"}:
                    errors.append(
                        f"{producer_group_where}.causal_status: invalid status")
            producer_variant_ids: list[str] = []
            producer_variants_by_group: dict[
                str, list[dict[str, Any]]] = {}
            for producer_index, producer_record in enumerate(
                    conditional_producers):
                producer_where = (
                    f"{invocation_where}.conditional_producers["
                    f"{producer_index}]")
                conditional_producer = _exact_fields(
                    producer_record, CONDITIONAL_OUTPUT_VARIANT_FIELDS,
                    producer_where, errors)
                if not conditional_producer:
                    continue
                producer_variant_id = conditional_producer.get("variant_id")
                if (not isinstance(producer_variant_id, str)
                        or not producer_variant_id):
                    errors.append(
                        f"{producer_where}.variant_id: expected non-empty string")
                else:
                    producer_variant_ids.append(producer_variant_id)
                _string_list(
                    conditional_producer.get("activation_ids"),
                    f"{producer_where}.activation_ids", errors,
                    nonempty=True)
                _validate_activation_roles(
                    conditional_producer, producer_where, errors)
                producer_facts = _string_list(
                    conditional_producer.get("produced_fact_ids"),
                    f"{producer_where}.produced_fact_ids", errors,
                    nonempty=True)
                if set(producer_facts) & {"event_log", "action_log"}:
                    errors.append(
                        f"{producer_where}: display-only logs cannot be causal outputs")
                _string_list(
                    conditional_producer.get("effect_contract_ids"),
                    f"{producer_where}.effect_contract_ids", errors,
                    nonempty=True)
                producer_proofs = _string_list(
                    conditional_producer.get("runtime_proof_ids"),
                    f"{producer_where}.runtime_proof_ids", errors,
                    nonempty=True)
                for ref in producer_proofs:
                    if ref not in proofs:
                        errors.append(
                            f"{producer_where}: missing runtime proof {ref}")
                if (not isinstance(
                        conditional_producer.get("selection_group_id"), str)
                        or not conditional_producer["selection_group_id"]):
                    errors.append(
                        f"{producer_where}.selection_group_id: "
                        "expected non-empty string")
                else:
                    producer_variants_by_group.setdefault(
                        conditional_producer["selection_group_id"], []).append(
                            conditional_producer)
            if len(producer_variant_ids) != len(set(producer_variant_ids)):
                errors.append(
                    f"{invocation_where}.conditional_producers: "
                    "duplicate variant ID")
            if set(producer_variants_by_group) != set(producer_groups_by_id):
                errors.append(
                    f"{invocation_where}.producer_variant_groups: must exactly "
                    "cover conditional producer selection groups")
            producer_entry_modes_by_variant_id: dict[
                str, frozenset[str]] = {}
            for group_id, variants in producer_variants_by_group.items():
                group_variant_ids = [
                    str(variant.get("variant_id", ""))
                    for variant in variants
                    if isinstance(variant.get("variant_id"), str)]
                producer_entry_modes_by_variant_id.update(
                    mode_constraints_for_group(group_variant_ids))
            internal_producer_fact_ids = _validate_producer_dependency_graph(
                producer_groups_by_id=producer_groups_by_id,
                producer_variants_by_group=producer_variants_by_group,
                where=f"{invocation_where}.conditional_producers",
                errors=errors)
            if invocation_id == \
                    "reader:milestone:w24:candidate_aggregation":
                _validate_w24_candidate_graph(
                    invocation, invocation_where, errors)
            if not synthetic_source_contracts \
                    and EXPECTED_INVOCATION_PRODUCER_DIGESTS:
                expected_producer_digest = \
                    EXPECTED_INVOCATION_PRODUCER_DIGESTS.get(
                        str(invocation_id))
                actual_producer_digest = _semantic_digest({
                    "conditional_producers": conditional_producers,
                    "producer_variant_groups": producer_variant_groups,
                })
                if (expected_producer_digest is None
                        or actual_producer_digest != expected_producer_digest):
                    errors.append(
                        f"{invocation_where}.conditional_producers: audited "
                        "milestone producer source contract mismatch")

            conditional_ids: list[str] = []
            for conditional_index, conditional_record in enumerate(conditionals):
                conditional_where = (
                    f"{invocation_where}.conditional_readers[{conditional_index}]")
                conditional = _exact_fields(
                    conditional_record, CONDITIONAL_READER_FIELDS,
                    conditional_where, errors)
                if not conditional:
                    continue
                reader_id = conditional.get("reader_id")
                if not isinstance(reader_id, str) or not reader_id:
                    errors.append(
                        f"{conditional_where}.reader_id: expected non-empty string")
                else:
                    conditional_ids.append(reader_id)
                activation_facts = _string_list(
                    conditional.get("activation_fact_ids"),
                    f"{conditional_where}.activation_fact_ids", errors,
                    nonempty=True)
                activation_proofs = _string_list(
                    conditional.get("runtime_proof_ids"),
                    f"{conditional_where}.runtime_proof_ids", errors,
                    nonempty=True)
                for ref in activation_proofs:
                    if ref not in proofs:
                        errors.append(f"{conditional_where}: missing runtime proof {ref}")
                activation_reader = reader_records_by_id.get(reader_id, {})
                activation_reader_inputs = {
                    *activation_reader.get("reads_fact_ids", []),
                    *activation_reader.get("story_decision_ids", []),
                    *activation_reader.get("scene_handoff_decision_ids", []),
                }
                if not set(activation_facts).issubset(
                        activation_reader_inputs):
                    errors.append(
                        f"{conditional_where}: activation facts must be reader inputs")
                for fact_id in activation_facts:
                    activation_proof_records = [
                        proof_records_by_id[ref]
                        for ref in set(activation_proofs)
                        if ref in proof_records_by_id]
                    activation_support = [
                        proof_records_by_id[ref]
                        for ref in set(activation_reader.get(
                            "runtime_proof_ids", []))
                        if ref in proof_records_by_id]
                    activation_bound = (
                        bool(activation_proof_records)
                        if synthetic_source_contracts else
                        _proofs_bind_reader_fact(
                            activation_reader, fact_id,
                            activation_proof_records, fact_pointer_cache,
                            supporting_proofs=activation_support))
                    if not activation_bound:
                        errors.append(
                            f"{conditional_where}: activation fact {fact_id} lacks binding proof")

            group_choices: list[list[list[str]]] = []
            reader_entry_modes_by_id: dict[str, frozenset[str]] = {}
            for reader_id in [*always, *conditional_ids]:
                explicit = explicit_entry_mode(reader_id)
                reader_entry_modes_by_id[reader_id] = (
                    frozenset({explicit}) if explicit is not None
                    else all_entry_modes)
            seen_group_ids: set[str] = set()
            variant_ids: list[str] = []
            for group_index, group_record in enumerate(groups):
                group_where = (
                    f"{invocation_where}.exclusive_variant_groups[{group_index}]")
                group = _exact_fields(
                    group_record, EXCLUSIVE_VARIANT_GROUP_FIELDS,
                    group_where, errors)
                if not group:
                    continue
                group_id = group.get("group_id")
                if not isinstance(group_id, str) or not group_id:
                    errors.append(f"{group_where}.group_id: expected non-empty string")
                    group_id = f"invalid:{group_index}"
                elif group_id in seen_group_ids:
                    errors.append(f"{invocation_where}: duplicate group ID {group_id}")
                else:
                    seen_group_ids.add(group_id)
                mode = group.get("selection_mode")
                if mode not in {"exactly_one", "at_most_one"}:
                    errors.append(f"{group_where}.selection_mode: invalid mode")
                causal_status = group.get("causal_status")
                debt_id = group.get("debt_id")
                if causal_status not in {"active", "shadowed"}:
                    errors.append(
                        f"{group_where}.causal_status: expected active|shadowed")
                if causal_status == "active":
                    if debt_id is not None:
                        errors.append(
                            f"{group_where}.debt_id: active group must use null")
                elif (not isinstance(debt_id, str) or not debt_id):
                    errors.append(
                        f"{group_where}.debt_id: shadowed group needs stable debt ID")
                variants = group.get("variants")
                if not isinstance(variants, list) or len(variants) < 2:
                    errors.append(f"{group_where}.variants: expected at least two variants")
                    variants = []
                choices: list[list[str]] = []
                common_proofs: set[str] | None = None
                exclusivity_tokens: list[str] = [group_id, str(mode)]
                for variant_index, variant_record in enumerate(variants):
                    variant_where = f"{group_where}.variants[{variant_index}]"
                    variant = _exact_fields(
                        variant_record, CONDITIONAL_READER_FIELDS,
                        variant_where, errors)
                    if not variant:
                        continue
                    reader_id = variant.get("reader_id")
                    if not isinstance(reader_id, str) or not reader_id:
                        errors.append(
                            f"{variant_where}.reader_id: expected non-empty string")
                    else:
                        variant_ids.append(reader_id)
                        choices.append([reader_id])
                        exclusivity_tokens.append(reader_id)
                        if causal_status == "shadowed":
                            shadowed_invocation_membership.setdefault(
                                reader_id, []).append(str(group_id))
                    activation_facts = _string_list(
                        variant.get("activation_fact_ids"),
                        f"{variant_where}.activation_fact_ids", errors,
                        nonempty=True)
                    activation_proofs = _string_list(
                        variant.get("runtime_proof_ids"),
                        f"{variant_where}.runtime_proof_ids", errors,
                        nonempty=True)
                    exclusivity_tokens.extend(activation_facts)
                    proof_set = set(activation_proofs)
                    common_proofs = (proof_set if common_proofs is None
                                     else common_proofs & proof_set)
                    for ref in activation_proofs:
                        if ref not in proofs:
                            errors.append(f"{variant_where}: missing runtime proof {ref}")
                    activation_reader = reader_records_by_id.get(reader_id, {})
                    activation_reader_inputs = {
                        *activation_reader.get("reads_fact_ids", []),
                        *activation_reader.get("story_decision_ids", []),
                        *activation_reader.get(
                            "scene_handoff_decision_ids", []),
                    }
                    if not set(activation_facts).issubset(
                            activation_reader_inputs):
                        errors.append(
                            f"{variant_where}: activation facts must be reader inputs")
                    for fact_id in activation_facts:
                        activation_proof_records = [
                            proof_records_by_id[ref]
                            for ref in set(activation_proofs)
                            if ref in proof_records_by_id]
                        activation_support = [
                            proof_records_by_id[ref]
                            for ref in set(activation_reader.get(
                                "runtime_proof_ids", []))
                            if ref in proof_records_by_id]
                        activation_bound = (
                            bool(activation_proof_records)
                            if synthetic_source_contracts else
                            _proofs_bind_reader_fact(
                                activation_reader, fact_id,
                                activation_proof_records, fact_pointer_cache,
                                supporting_proofs=activation_support))
                        if not activation_bound:
                            errors.append(
                                f"{variant_where}: activation fact {fact_id} lacks binding proof")
                expected_group = EXPECTED_EXCLUSIVE_GROUPS.get(str(group_id))
                if expected_group is None:
                    if not synthetic_source_contracts:
                        errors.append(
                            f"{group_where}: unaudited exclusive group")
                elif (not synthetic_source_contracts
                      and (mode != expected_group[0]
                           or variant_ids[-len(variants):]
                           != expected_group[1])):
                    errors.append(
                        f"{group_where}: exclusive topology does not match source")
                exclusivity_bound = any(
                    isinstance(proof_records_by_id.get(ref, {}).get("assertion"), str)
                    and all(token in proof_records_by_id[ref]["assertion"]
                            for token in exclusivity_tokens)
                    for ref in (common_proofs or set()))
                exclusive_proof_id = (
                    "proof:exclusive:" + str(group_id).replace(":", "_"))
                exclusive_proof = proof_records_by_id.get(
                    exclusive_proof_id, {})
                expected_exclusive_pointer = (
                    EXPECTED_EXCLUSIVE_PROOF_POINTERS.get(str(group_id)))
                if (synthetic_source_contracts
                        and expected_group is None
                        and isinstance(exclusive_proof.get("pointer"), str)):
                    expected_exclusive_pointer = exclusive_proof.get("pointer")
                if (exclusive_proof_id not in (common_proofs or set())
                        or exclusive_proof.get("pointer")
                        != expected_exclusive_pointer):
                    exclusivity_bound = False
                exclusive_body = _pointer_source_text(
                    str(expected_exclusive_pointer or ""), fact_pointer_cache)
                if group_id == "group:w24:job_state_candidate":
                    hanbit_body = _pointer_source_text(
                        "systems/DemoCoreLoopV2.gd::has_hanbit_employment_provenance",
                        fact_pointer_cache)
                    if ("has_hanbit_employment_provenance" not in exclusive_body
                            or "GameState.current_job.is_empty()" not in exclusive_body
                            or '"job_03"' not in hanbit_body):
                        exclusivity_bound = False
                elif group_id == "group:w24:person_obligation":
                    person_body = _pointer_source_text(
                        "systems/DemoCoreLoopV2.gd::_demo_person_obligation",
                        fact_pointer_cache)
                    if ("_demo_person_obligation" not in exclusive_body
                            or person_body.count("return ") < 3):
                        exclusivity_bound = False
                if not exclusivity_bound:
                    errors.append(
                        f"{group_where}: variants lack common proof binding group/mode")
                member_ids = [
                    item.get("reader_id") for item in variants
                    if isinstance(item, dict)
                    and isinstance(item.get("reader_id"), str)]
                reader_entry_modes_by_id.update(
                    mode_constraints_for_group(member_ids))
                member_statuses = {
                    reader_records_by_id.get(reader_id, {}).get("status")
                    for reader_id in member_ids}
                if causal_status == "shadowed":
                    if member_statuses != {"shadowed"}:
                        errors.append(
                            f"{group_where}: shadowed group must contain only shadowed readers")
                    if debt_id not in member_ids:
                        errors.append(
                            f"{group_where}.debt_id: must name one stable member reader")
                    if isinstance(debt_id, str) and debt_id:
                        shadowed_group_debt_ids.append(debt_id)
                    shadow_tokens = ["shadowed", str(debt_id)]
                    if not any(
                            all(token in str(proof_records_by_id.get(
                                ref, {}).get("assertion", ""))
                                for token in shadow_tokens)
                            for ref in (common_proofs or set())):
                        errors.append(
                            f"{group_where}: proof does not bind shadowed debt owner")
                elif member_statuses - {"active"}:
                    errors.append(
                        f"{group_where}: active group contains non-active reader")
                if mode == "at_most_one":
                    choices.append([])
                group_choices.append(choices)

            invocation_token = _invocation_contract_token(invocation)
            if not any(
                    invocation_token in str(proof.get("assertion", ""))
                    for proof in resolved_invocation_proofs):
                errors.append(
                    f"{invocation_where}: invocation proof does not bind exact reader structure")

            members = [*always, *conditional_ids, *variant_ids]
            member_read_facts = {
                fact_id for reader_id in members
                for fact_id in reader_records_by_id.get(
                    reader_id, {}).get("reads_fact_ids", [])
                if isinstance(fact_id, str)}
            producer_combinations = _compatible_producer_selections(
                producer_groups_by_id, producer_variants_by_group)
            producer_output_options = [
                _producer_selection_output_facts(
                    selection, producer_groups_by_id)
                for selection in producer_combinations]
            producer_output_facts = set().union(
                *producer_output_options) if producer_output_options else set()
            producer_handoff_fact_inputs = {
                fact_id for producer in conditional_producers
                if isinstance(producer, dict)
                and isinstance(producer.get("activation_roles"), dict)
                for fact_id in producer.get("activation_roles", {}).get(
                    "scene_handoff_fact_ids", [])
                if isinstance(fact_id, str)
                and fact_id not in internal_producer_fact_ids}
            # `story_choice:*` is authored by the current Story choice
            # invocation and becomes a downstream decision handoff.
            # An already-normalized `decision:*` token is instead an input to
            # a later invocation (notably replay capture) and must have an
            # earlier owner on the same source scenario.
            producer_scene_decisions = {
                "decision:" + decision_id[len("story_choice:"):]
                for producer in conditional_producers
                if isinstance(producer, dict)
                and isinstance(producer.get("activation_roles"), dict)
                and producer_groups_by_id.get(
                    str(producer.get("selection_group_id")), {}).get(
                    "causal_status") in {
                        "active", "terminal_no_current_reader"}
                for decision_id in producer.get("activation_roles", {}).get(
                    "scene_handoff_decision_ids", [])
                if isinstance(decision_id, str)
                and decision_id.startswith("story_choice:")}
            producer_scene_decisions.update(
                decision_id
                for producer in conditional_producers
                if isinstance(producer, dict)
                and producer_groups_by_id.get(
                    str(producer.get("selection_group_id")), {}).get(
                        "causal_status") in {
                            "active", "terminal_no_current_reader"}
                for decision_id in producer.get("produced_fact_ids", [])
                if isinstance(decision_id, str)
                and decision_id.startswith("decision:"))
            producer_scene_decisions.update(
                "decision:v2_demo_first_bill:"
                + handoff_id.removeprefix(
                    SYNTHETIC_W24_FIRST_BILL_DECISION_HANDOFF_PREFIX)
                for producer in conditional_producers
                if isinstance(producer, dict)
                and producer_groups_by_id.get(
                    str(producer.get("selection_group_id")), {}).get(
                        "causal_status") in {
                            "active", "terminal_no_current_reader"}
                for handoff_id in producer.get("produced_fact_ids", [])
                if isinstance(handoff_id, str)
                and handoff_id.startswith(
                    SYNTHETIC_W24_FIRST_BILL_DECISION_HANDOFF_PREFIX))
            producer_output_decision_options = [
                {
                    "decision:" + decision_id[len("story_choice:"):]
                    for producer in selection
                    if producer_groups_by_id.get(
                        str(producer.get("selection_group_id")), {}).get(
                        "causal_status") in {
                            "active", "terminal_no_current_reader"}
                    for decision_id in producer.get(
                        "activation_roles", {}).get(
                            "scene_handoff_decision_ids", [])
                    if isinstance(decision_id, str)
                    and decision_id.startswith("story_choice:")
                } | {
                    decision_id
                    for producer in selection
                    if producer_groups_by_id.get(
                        str(producer.get("selection_group_id")), {}).get(
                            "causal_status") in {
                                "active", "terminal_no_current_reader"}
                    for decision_id in producer.get("produced_fact_ids", [])
                    if isinstance(decision_id, str)
                    and decision_id.startswith("decision:")
                } | {
                    "decision:v2_demo_first_bill:"
                    + handoff_id.removeprefix(
                        SYNTHETIC_W24_FIRST_BILL_DECISION_HANDOFF_PREFIX)
                    for producer in selection
                    if producer_groups_by_id.get(
                        str(producer.get("selection_group_id")), {}).get(
                            "causal_status") in {
                                "active", "terminal_no_current_reader"}
                    for handoff_id in producer.get("produced_fact_ids", [])
                    if isinstance(handoff_id, str)
                    and handoff_id.startswith(
                        SYNTHETIC_W24_FIRST_BILL_DECISION_HANDOFF_PREFIX)
                }
                for selection in producer_combinations]
            producer_handoff_decision_inputs = {
                decision_id
                for producer in conditional_producers
                if isinstance(producer, dict)
                and isinstance(producer.get("activation_roles"), dict)
                for decision_id in producer.get("activation_roles", {}).get(
                    "scene_handoff_decision_ids", [])
                if isinstance(decision_id, str)
                and decision_id.startswith("decision:")}
            reader_handoff_fact_inputs = {
                fact_id for reader_id in members
                for fact_id in reader_records_by_id.get(
                    reader_id, {}).get("scene_handoff_fact_ids", [])
                if isinstance(fact_id, str)}
            reader_handoff_decision_inputs = {
                decision_id for reader_id in members
                for decision_id in reader_records_by_id.get(
                    reader_id, {}).get("scene_handoff_decision_ids", [])
                if isinstance(decision_id, str)}
            invocation_handoff_fact_inputs[invocation_id] = (
                producer_handoff_fact_inputs | reader_handoff_fact_inputs)
            invocation_handoff_decision_inputs[invocation_id] = (
                reader_handoff_decision_inputs
                | producer_handoff_decision_inputs)
            invocation_produced_handoff_facts[invocation_id] = \
                producer_output_facts
            producer_output_input_options: list[tuple[
                set[str], set[str], frozenset[str]]] = []
            for producer_selection in producer_combinations:
                input_facts: set[str] = set()
                input_decisions: set[str] = set()
                option_entry_modes = all_entry_modes
                for producer_variant in producer_selection:
                    option_entry_modes = frozenset(
                        set(option_entry_modes)
                        & set(producer_entry_modes_by_variant_id.get(
                            str(producer_variant.get("variant_id", "")),
                            all_entry_modes)))
                    activation_roles = producer_variant.get(
                        "activation_roles", {})
                    if not isinstance(activation_roles, dict):
                        continue
                    input_facts.update(
                        fact_id for fact_id in activation_roles.get(
                            "scene_handoff_fact_ids", [])
                        if isinstance(fact_id, str)
                        and fact_id not in internal_producer_fact_ids)
                    input_decisions.update(
                        decision_id for decision_id in activation_roles.get(
                            "scene_handoff_decision_ids", [])
                        if isinstance(decision_id, str)
                        and decision_id.startswith("decision:"))
                producer_output_input_options.append((
                    input_facts, input_decisions, option_entry_modes))
            invocation_produced_handoff_options[invocation_id] = [
                (facts, decisions, input_facts, input_decisions, entry_modes)
                for facts, decisions, (
                    input_facts, input_decisions, entry_modes)
                in zip(
                    producer_output_options,
                    producer_output_decision_options,
                    producer_output_input_options)]
            for facts, decisions, _input_facts, _input_decisions, \
                    _entry_modes in invocation_produced_handoff_options[
                        invocation_id]:
                for fact_id in facts:
                    handoff_fact_owner_invocations.setdefault(
                        fact_id, set()).add(invocation_id)
                for decision_id in decisions:
                    handoff_decision_owner_invocations.setdefault(
                        decision_id, set()).add(invocation_id)
            invocation_produced_scene_decisions[invocation_id] = \
                producer_scene_decisions
            if member_read_facts & producer_output_facts:
                errors.append(
                    f"{invocation_where}.conditional_producers: "
                    "producer output may not be its own invocation input")
            if producer_handoff_fact_inputs & producer_output_facts:
                errors.append(
                    f"{invocation_where}.conditional_producers: producer "
                    "cannot consume its own handoff output")
            local_membership.extend(members)
            for reader_id in members:
                invocation_membership.setdefault(reader_id, []).append(invocation_id)
                if reader_id not in readers:
                    errors.append(f"{invocation_where}: missing reader {reader_id}")
                elif (reader_records_by_id[reader_id].get("status") != "active"
                      and reader_id not in shadowed_invocation_membership):
                    errors.append(f"{invocation_where}: reader {reader_id} is not active")
                elif (reader_records_by_id[reader_id].get("reader_kind")
                      == "story_milestone"
                      and reader_records_by_id[reader_id].get("runtime_pointer")
                      != invocation_pointer
                      and not (set(reader_records_by_id[reader_id].get(
                                      "runtime_proof_ids", []))
                               & set(invocation_proofs))
                      and invocation_id not in
                          EXPECTED_INVOCATION_CONTRACT_DIGESTS):
                    errors.append(
                        f"{invocation_where}: story reader {reader_id} lacks invocation pointer/proof link")
            if not members and not conditional_producers:
                errors.append(
                    f"{invocation_where}: invocation has neither readers nor producers")
            if len(members) != len(set(members)):
                errors.append(f"{invocation_where}: reader assigned more than once")

            fixed_ids = [*always]
            # Ungrouped conditional readers are independently optional.  They
            # must not be treated as co-present on every source scenario.
            reader_choice_axes: list[list[list[str]]] = [
                [[], [reader_id]] for reader_id in conditional_ids]
            reader_choice_axes.extend(group_choices)
            combinations = itertools.product(*reader_choice_axes) \
                if reader_choice_axes else [()]
            possible_inputs: list[tuple[
                set[str], set[str], bool, set[str], set[str],
                frozenset[str], frozenset[str], frozenset[str]]] = []
            for selection in combinations:
                selected_ids = [*fixed_ids]
                for choice in selection:
                    selected_ids.extend(choice)
                builds, decisions = _reader_input_union(
                    selected_ids, reader_records_by_id)
                selected_reader_handoff_facts = {
                    fact_id for reader_id in selected_ids
                    for fact_id in reader_records_by_id.get(
                        reader_id, {}).get("scene_handoff_fact_ids", [])
                    if isinstance(fact_id, str)}
                selected_reader_handoff_decisions = {
                    decision_id for reader_id in selected_ids
                    for decision_id in reader_records_by_id.get(
                        reader_id, {}).get("scene_handoff_decision_ids", [])
                    if isinstance(decision_id, str)}
                unnamed_input = any(
                    reader_records_by_id.get(reader_id, {}).get("reader_kind")
                    == "story_milestone"
                    and (
                        (not reader_records_by_id.get(reader_id, {}).get(
                            "reads_fact_ids", [])
                         and not reader_records_by_id.get(reader_id, {}).get(
                            "story_decision_ids", [])
                         and not reader_records_by_id.get(reader_id, {}).get(
                            "scene_handoff_decision_ids", []))
                        or (reader_records_by_id.get(reader_id, {}).get(
                            "input_build_family_ids", [])
                            and not reader_records_by_id.get(reader_id, {}).get(
                                "reads_fact_ids", [])))
                    for reader_id in selected_ids)
                for producer_selection in producer_combinations:
                    producer_memories: set[str] = set()
                    producer_decisions: set[str] = set()
                    selected_producer_handoff_facts: set[str] = set()
                    selected_producer_handoff_decisions: set[str] = set()
                    allowed_entry_modes = all_entry_modes
                    for reader_id in selected_ids:
                        allowed_entry_modes = frozenset(
                            set(allowed_entry_modes)
                            & set(reader_entry_modes_by_id.get(
                                reader_id, all_entry_modes)))
                    for producer_variant in producer_selection:
                        allowed_entry_modes = frozenset(
                            set(allowed_entry_modes)
                            & set(producer_entry_modes_by_variant_id.get(
                                str(producer_variant.get("variant_id", "")),
                                all_entry_modes)))
                        activation_roles = producer_variant.get(
                            "activation_roles", {})
                        if not isinstance(activation_roles, dict):
                            continue
                        producer_memories.update(
                            activation_roles.get("history_memory_ids", []))
                        producer_decisions.update(
                            activation_roles.get("story_decision_ids", []))
                        selected_producer_handoff_facts.update(
                            fact_id for fact_id in activation_roles.get(
                                "scene_handoff_fact_ids", [])
                            if isinstance(fact_id, str)
                            and fact_id not in internal_producer_fact_ids)
                        selected_producer_handoff_decisions.update(
                            decision_id for decision_id in activation_roles.get(
                                "scene_handoff_decision_ids", [])
                            if isinstance(decision_id, str)
                            and decision_id.startswith("decision:"))
                    if not allowed_entry_modes:
                        continue
                    possible_inputs.append((
                        builds | producer_memories,
                        decisions | producer_decisions,
                        unnamed_input,
                        selected_reader_handoff_facts
                            | selected_producer_handoff_facts,
                        selected_reader_handoff_decisions
                            | selected_producer_handoff_decisions,
                        allowed_entry_modes,
                        frozenset(selected_ids),
                        frozenset(
                            str(producer_variant.get("variant_id", ""))
                            for producer_variant in producer_selection
                            if isinstance(
                                producer_variant.get("variant_id"), str)
                            and producer_variant.get("variant_id"))))
            invocation_reader_variant_ids[invocation_id] = set(
                conditional_ids) | set(variant_ids)
            invocation_producer_variant_ids[invocation_id] = set(
                producer_variant_ids)
            # Eager formatter call sites intentionally contain several
            # source-equivalent reader clones.  Collapse only identical
            # semantic input options (never role/path distinctions) before
            # scenario handoff and fan-in analysis, keeping the final W24
            # scenario product bounded without changing its meaning.
            unique_inputs: dict[tuple[
                frozenset[str], frozenset[str], bool, frozenset[str],
                frozenset[str], frozenset[str]], tuple[
                    set[str], set[str], bool, set[str], set[str],
                    frozenset[str], frozenset[str], frozenset[str]]] = {}
            for option in possible_inputs:
                option_key = (
                    frozenset(option[0]), frozenset(option[1]), option[2],
                    frozenset(option[3]), frozenset(option[4]), option[5])
                previous = unique_inputs.get(option_key)
                if previous is None:
                    unique_inputs[option_key] = option
                else:
                    unique_inputs[option_key] = (
                        previous[0], previous[1], previous[2], previous[3],
                        previous[4], previous[5],
                        frozenset(set(previous[6]) | set(option[6])),
                        frozenset(set(previous[7]) | set(option[7])),
                    )
            invocation_combinations_by_id[invocation_id] = \
                list(unique_inputs.values()) or [
                    (set(), set(), False, set(), set(), all_entry_modes,
                     frozenset(), frozenset())]

        if milestone.get("status") == "audited_runtime":
            if len(milestone_reader_refs) != len(set(milestone_reader_refs)):
                errors.append(
                    f"{milestone_where}.reader_ids: duplicate reader ID")
            if set(local_membership) != set(milestone_reader_refs):
                errors.append(
                    f"{milestone_where}.invocations: membership must exactly cover reader_ids")

            stage_ids: list[str] = []
            stage_records_by_id: dict[str, dict[str, Any]] = {}
            stage_where_by_id: dict[str, str] = {}
            staged_invocations: list[str] = []
            stages = milestone.get("execution_stages", [])
            for stage_index, stage_record in enumerate(
                    stages if isinstance(stages, list) else []):
                stage_where = (
                    f"{milestone_where}.execution_stages[{stage_index}]")
                stage = _exact_fields(
                    stage_record, EXECUTION_STAGE_FIELDS,
                    stage_where, errors)
                if not stage:
                    continue
                stage_id = stage.get("stage_id")
                if not isinstance(stage_id, str) or not stage_id:
                    errors.append(
                        f"{stage_where}.stage_id: expected non-empty string")
                    stage_id = f"invalid:{stage_index}"
                if stage_id in stage_ids:
                    errors.append(
                        f"{milestone_where}.execution_stages: duplicate stage ID {stage_id}")
                stage_ids.append(stage_id)
                stage_records_by_id[stage_id] = stage
                stage_where_by_id[stage_id] = stage_where
                if (not _is_int(stage.get("order_index"))
                        or stage["order_index"] < 0):
                    errors.append(
                        f"{stage_where}.order_index: expected non-negative integer")
                _string_list(
                    stage.get("applicability_ids"),
                    f"{stage_where}.applicability_ids", errors,
                    nonempty=True)
                _string_list(
                    stage.get("predecessor_stage_ids"),
                    f"{stage_where}.predecessor_stage_ids", errors)
                stage_invocations = _string_list(
                    stage.get("invocation_ids"),
                    f"{stage_where}.invocation_ids", errors,
                    nonempty=True)
                stage_proofs = _string_list(
                    stage.get("runtime_proof_ids"),
                    f"{stage_where}.runtime_proof_ids", errors,
                    nonempty=True)
                for invocation_id_ref in stage_invocations:
                    if invocation_id_ref not in local_invocation_ids:
                        errors.append(
                            f"{stage_where}: invocation {invocation_id_ref} is not in milestone")
                    invocation_stage_index_by_id[invocation_id_ref] = \
                        stage.get("order_index", -1)
                    invocation_stage_id_by_id[invocation_id_ref] = str(
                        stage_id)
                    invocation_stage_milestone_by_id[invocation_id_ref] = str(
                        milestone.get("milestone_id", ""))
                staged_invocations.extend(stage_invocations)
                resolved_stage_proofs = [
                    proof_records_by_id[proof_id]
                    for proof_id in stage_proofs
                    if proof_id in proof_records_by_id]
                for proof_id in stage_proofs:
                    if proof_id not in proofs:
                        errors.append(
                            f"{stage_where}: missing runtime proof {proof_id}")
                stage_token = _execution_stage_contract_token(stage)
                if not any(
                        stage_token in str(proof.get("assertion", ""))
                        for proof in resolved_stage_proofs):
                    errors.append(
                        f"{stage_where}: proof does not bind exact execution stage")
            for stage_id, stage in stage_records_by_id.items():
                stage_where = stage_where_by_id[stage_id]
                order_index = stage.get("order_index")
                for predecessor_id in stage.get(
                        "predecessor_stage_ids", []):
                    predecessor = stage_records_by_id.get(predecessor_id)
                    if predecessor is None:
                        errors.append(
                            f"{stage_where}.predecessor_stage_ids: unknown stage {predecessor_id}")
                    elif (not _is_int(order_index)
                          or not _is_int(predecessor.get("order_index"))
                          or predecessor["order_index"] >= order_index):
                        errors.append(
                            f"{stage_where}.predecessor_stage_ids: predecessor must have a strictly lower order_index")
            # Validate cycles over the declared graph independently of any
            # one source scenario.  Path-local ancestry is resolved below;
            # unioning these declared branches would join incompatible
            # fresh/re-entry and fatal/survivor paths.
            declared_ancestor_cache: dict[str, set[str]] = {}
            declared_ancestor_visiting: set[str] = set()

            def declared_stage_ancestors(stage_id: str) -> set[str]:
                if stage_id in declared_ancestor_cache:
                    return declared_ancestor_cache[stage_id]
                if stage_id in declared_ancestor_visiting:
                    errors.append(
                        f"{milestone_where}.execution_stages: predecessor cycle at {stage_id}")
                    return set()
                declared_ancestor_visiting.add(stage_id)
                ancestors: set[str] = set()
                stage = stage_records_by_id.get(stage_id, {})
                raw_predecessors = stage.get("predecessor_stage_ids", [])
                if isinstance(raw_predecessors, list):
                    for predecessor_id in raw_predecessors:
                        if predecessor_id not in stage_records_by_id:
                            continue
                        ancestors.add(predecessor_id)
                        ancestors.update(
                            declared_stage_ancestors(predecessor_id))
                declared_ancestor_visiting.discard(stage_id)
                declared_ancestor_cache[stage_id] = ancestors
                return ancestors

            for stage_id in stage_records_by_id:
                declared_stage_ancestors(stage_id)
            stages_by_order: dict[int, list[dict[str, Any]]] = {}
            for stage in stage_records_by_id.values():
                if _is_int(stage.get("order_index")):
                    stages_by_order.setdefault(
                        int(stage["order_index"]), []).append(stage)
            for same_order_stages in stages_by_order.values():
                if len(same_order_stages) < 2:
                    continue
                for left in range(len(same_order_stages)):
                    for right in range(left + 1, len(same_order_stages)):
                        left_stage = same_order_stages[left]
                        right_stage = same_order_stages[right]
                        pair_tokens = {
                            str(left_stage.get("stage_id")),
                            str(right_stage.get("stage_id")),
                        }
                        pair_proofs = set(left_stage.get(
                            "runtime_proof_ids", [])) & set(
                                right_stage.get("runtime_proof_ids", []))
                        mutually_exclusive = any(
                            "mutually_exclusive" in str(
                                proof_records_by_id.get(
                                    proof_id, {}).get("assertion", ""))
                            and all(token in str(
                                proof_records_by_id.get(
                                    proof_id, {}).get("assertion", ""))
                                    for token in pair_tokens)
                            for proof_id in pair_proofs)
                        if not mutually_exclusive:
                            errors.append(
                                f"{milestone_where}.execution_stages: same-order stages need a common source-bound mutually-exclusive proof")
            if (len(staged_invocations) != len(set(staged_invocations))
                    or set(staged_invocations) != set(local_invocation_ids)):
                errors.append(
                    f"{milestone_where}.execution_stages: each invocation must appear exactly once")

            if not synthetic_source_contracts:
                for stage_id, stage in stage_records_by_id.items():
                    expected_stage_digest = \
                        EXPECTED_EXECUTION_STAGE_CONTRACT_DIGESTS.get(stage_id)
                    if (EXPECTED_EXECUTION_STAGE_CONTRACT_DIGESTS
                            and (expected_stage_digest is None
                                 or _semantic_digest(stage)
                                 != expected_stage_digest)):
                        errors.append(
                            f"{stage_where_by_id[stage_id]}: audited execution stage source topology mismatch")
            local_execution_scenarios = _execution_stage_scenarios(
                week=int(milestone.get("week", -1))
                if _is_int(milestone.get("week")) else -1,
                stage_records_by_id=stage_records_by_id,
                where=f"{milestone_where}.execution_stages",
                synthetic_source_contracts=synthetic_source_contracts,
                errors=errors)
            milestone_id = str(milestone.get("milestone_id", ""))
            for scenario_index, (scenario_stages, scenario_ancestors) in \
                    enumerate(local_execution_scenarios):
                scenario_key = (milestone_id, scenario_index)
                stage_ancestors_by_source_scenario[scenario_key] = \
                    scenario_ancestors
                if "w24:story_resume_load" in scenario_stages:
                    source_scenario_entry_mode[scenario_key] = "cold"
                elif "w24:prepare_reentry" in scenario_stages:
                    source_scenario_entry_mode[scenario_key] = "reentry"
                else:
                    source_scenario_entry_mode[scenario_key] = "fresh"
                for invocation_id_ref in local_invocation_ids:
                    if invocation_stage_id_by_id.get(invocation_id_ref) \
                            in scenario_stages:
                        invocation_source_scenarios_by_id.setdefault(
                            invocation_id_ref, set()).add(scenario_key)

            # Derive the exact W24 source tuple census from the same
            # scenario-local option/handoff engine used by validation.  This
            # is intentionally computed from the supplied production graph;
            # the complete-fixture manifest may compare it to frozen counts,
            # but may never declare those counts as its own truth.
            if (milestone.get("week") == 24
                    and not synthetic_source_contracts
                    and not self_test_skip_w24_source_census
                    and SYNTHETIC_W24_FANIN_SUPERSEDED_INVOCATION_IDS
                    .issubset(set(local_invocation_ids))):
                source_tuple_map: dict[str, list[int]] = {}
                source_scenario_feasible_counts: dict[str, int] = {}
                source_zero_option_paths = 0
                for scenario_index, (scenario_stages, _ancestors) in \
                        enumerate(local_execution_scenarios):
                    scenario_key = (milestone_id, scenario_index)
                    active_by_stage: dict[str, list[str]] = {}
                    for invocation_id_ref in sorted(
                            SYNTHETIC_W24_FANIN_SUPERSEDED_INVOCATION_IDS):
                        stage_id = invocation_stage_id_by_id.get(
                            invocation_id_ref)
                        if stage_id in scenario_stages:
                            active_by_stage.setdefault(
                                str(stage_id), []).append(invocation_id_ref)
                    for stage_id, active_ids in active_by_stage.items():
                        counts = source_tuple_map.setdefault(
                            stage_id, [0, 0, 0])
                        counts[0] += 1
                        axes = [
                            [option for option in
                             invocation_combinations_by_id.get(
                                 invocation_id_ref, [])
                             if handoff_option_is_feasible(
                                 invocation_id_ref, option[3], option[4],
                                 scenario_key, option[5])]
                            for invocation_id_ref in active_ids]
                        if any(not axis for axis in axes):
                            source_zero_option_paths += 1
                            source_scenario_feasible_counts[
                                f"{scenario_index}:{stage_id}"] = 0
                            continue
                        scenario_feasible_count = 0
                        for selected in itertools.product(*axes):
                            decision_values: dict[str, str] = {}
                            compatible = True
                            for option in selected:
                                for decision_id in set(option[1]) | set(
                                        option[4]):
                                    domain_value = _activation_choice_domain(
                                        decision_id)
                                    if domain_value is None:
                                        continue
                                    domain, value = domain_value
                                    previous = decision_values.setdefault(
                                        domain, value)
                                    if previous != value:
                                        compatible = False
                                        break
                                if not compatible:
                                    break
                            counts[1 if compatible else 2] += 1
                            if compatible:
                                scenario_feasible_count += 1
                        source_scenario_feasible_counts[
                            f"{scenario_index}:{stage_id}"] = \
                            scenario_feasible_count
                metrics["w24_source_tuple_stage_map"] = {
                    stage_id: tuple(counts)
                    for stage_id, counts in sorted(source_tuple_map.items())}
                metrics["w24_source_feasible_tuple_occurrences"] = sum(
                    counts[1] for counts in source_tuple_map.values())
                metrics["w24_source_rejected_tuple_occurrences"] = sum(
                    counts[2] for counts in source_tuple_map.values())
                metrics["w24_source_zero_option_paths"] = \
                    source_zero_option_paths
                metrics["w24_source_scenario_feasible_counts"] = \
                    source_scenario_feasible_counts
                metrics["w24_source_scenario_feasible_counts_digest"] = \
                    _semantic_digest(source_scenario_feasible_counts)

                # Re-run the same scenario selection with the richer raw
                # projection used by the replacement proof.  Unlike the
                # compact fan-in tuple above, this retains all five temporal
                # roles plus original outputs/effects, and preserves
                # multiplicity per concrete source scenario.
                detailed_occurrences: dict[str, list[str]] = {}
                detailed_feasible = 0
                detailed_rejected = 0
                detailed_zero = 0
                for scenario_index, (scenario_stages, _ancestors) in \
                        enumerate(local_execution_scenarios):
                    scenario_key = (milestone_id, scenario_index)
                    active_by_stage: dict[str, list[str]] = {}
                    for invocation_id_ref in sorted(
                            SYNTHETIC_W24_FANIN_SUPERSEDED_INVOCATION_IDS):
                        stage_id = invocation_stage_id_by_id.get(
                            invocation_id_ref)
                        if stage_id in scenario_stages:
                            active_by_stage.setdefault(
                                str(stage_id), []).append(invocation_id_ref)
                    for stage_id, active_ids in sorted(
                            active_by_stage.items()):
                        raw_axes: list[list[dict[str, Any]]] = []
                        for invocation_id_ref in active_ids:
                            options = _synthetic_w24_exact_raw_options(
                                invocation_records_by_id[invocation_id_ref],
                                reader_records_by_id)
                            raw_axes.append([
                                option for option in options
                                if handoff_option_is_feasible(
                                    invocation_id_ref,
                                    set(option["activation_roles"][
                                        "scene_handoff_fact_ids"]),
                                    set(option["activation_roles"][
                                        "scene_handoff_decision_ids"]),
                                    scenario_key,
                                    frozenset(option["entry_modes"]))])
                        occurrence_key = f"{scenario_index}:{stage_id}"
                        occurrence_digests: list[str] = []
                        if any(not axis for axis in raw_axes):
                            detailed_zero += 1
                            detailed_occurrences[occurrence_key] = []
                            continue
                        for selected in itertools.product(*raw_axes):
                            merged = _synthetic_w24_merge_raw_options(
                                selected)
                            if merged is None:
                                detailed_rejected += 1
                                continue
                            occurrence_digests.append(_semantic_digest(
                                _synthetic_w24_option_projection(merged)))
                        occurrence_digests.sort()
                        detailed_feasible += len(occurrence_digests)
                        detailed_occurrences[occurrence_key] = \
                            occurrence_digests
                metrics["w24_source_detailed_occurrences"] = \
                    detailed_occurrences
                metrics["w24_source_detailed_occurrences_digest"] = \
                    _semantic_digest(detailed_occurrences)
                metrics["w24_source_detailed_feasible"] = detailed_feasible
                metrics["w24_source_detailed_rejected"] = detailed_rejected
                metrics["w24_source_detailed_zero"] = detailed_zero
                # This richer projection intentionally does not stand in for
                # the exact source occurrence census above: current-choice
                # dirty reentry readers are satisfied inside their logical
                # call rather than by an earlier stage.  It is retained only
                # as output/effect/role evidence for the unique A/B surface.

            elif (milestone.get("week") == 24
                  and synthetic_source_contracts):
                replacement_occurrences: dict[str, list[str]] = {}
                replacement_stage_map: dict[str, list[int]] = {}
                replacement_feasible = 0
                replacement_zero = 0
                for scenario_index, (scenario_stages, _ancestors) in \
                        enumerate(local_execution_scenarios):
                    scenario_key = (milestone_id, scenario_index)
                    for aggregate_stage_id in sorted(
                            stage_id for stage_id in scenario_stages
                            if stage_id.startswith(
                                "w24:synthetic_fanin_aggregate:")):
                        original_stage_id = aggregate_stage_id.removeprefix(
                            "w24:synthetic_fanin_aggregate:")
                        aggregate_invocation_ids = [
                            invocation_id_ref
                            for invocation_id_ref in stage_records_by_id[
                                aggregate_stage_id].get("invocation_ids", [])
                            if invocation_id_ref.startswith(
                                "reader:synthetic:w24:fanin_aggregate:")]
                        counts = replacement_stage_map.setdefault(
                            original_stage_id, [0, 0, 0])
                        counts[0] += 1
                        occurrence_key = (
                            f"{scenario_index}:{original_stage_id}")
                        if len(aggregate_invocation_ids) != 1:
                            replacement_zero += 1
                            replacement_occurrences[occurrence_key] = []
                            continue
                        invocation_id_ref = aggregate_invocation_ids[0]
                        aggregate_record = copy.deepcopy(
                            invocation_records_by_id[invocation_id_ref])
                        aggregate_record["invocation_id"] = original_stage_id
                        aggregate_record["conditional_producers"] = [
                            producer for producer in aggregate_record.get(
                                "conditional_producers", [])
                            if not str(producer.get("variant_id", "")).startswith(
                                "variant:synthetic:w24:raw_options_resolved:")]
                        live_group_ids = {
                            producer.get("selection_group_id")
                            for producer in aggregate_record[
                                "conditional_producers"]}
                        aggregate_record["producer_variant_groups"] = [
                            group for group in aggregate_record.get(
                                "producer_variant_groups", [])
                            if group.get("selection_group_id")
                            in live_group_ids]
                        options = _synthetic_w24_exact_raw_options(
                            aggregate_record, reader_records_by_id)
                        feasible_options = [
                            option for option in options
                            if handoff_option_is_feasible(
                                invocation_id_ref,
                                set(option["activation_roles"][
                                    "scene_handoff_fact_ids"]),
                                set(option["activation_roles"][
                                    "scene_handoff_decision_ids"]),
                                scenario_key,
                                frozenset(option["entry_modes"]))]
                        generic_feasible_options = [
                            option for option in
                            invocation_combinations_by_id.get(
                                invocation_id_ref, [])
                            if handoff_option_is_feasible(
                                invocation_id_ref, option[3], option[4],
                                scenario_key, option[5])]
                        occurrence_digests = sorted(
                            _semantic_digest(
                                _synthetic_w24_option_projection(option))
                            for option in feasible_options)
                        if not generic_feasible_options:
                            replacement_zero += 1
                        replacement_feasible += len(
                            generic_feasible_options)
                        counts[1] += len(generic_feasible_options)
                        replacement_occurrences[occurrence_key] = \
                            occurrence_digests
                metrics["w24_replacement_source_tuple_stage_map"] = {
                    stage_id: tuple(counts)
                    for stage_id, counts in sorted(
                        replacement_stage_map.items())}
                metrics["w24_replacement_detailed_occurrences"] = \
                    replacement_occurrences
                metrics["w24_replacement_detailed_occurrences_digest"] = \
                    _semantic_digest(replacement_occurrences)
                metrics["w24_replacement_feasible_tuple_occurrences"] = \
                    replacement_feasible
                metrics["w24_replacement_zero_option_paths"] = \
                    replacement_zero

            # A source-semantic reader may be reused by distinct call-site
            # invocations (the cold W24 formatter has two such sites), but
            # only when checker-owned source scenarios prove those stages are
            # mutually exclusive.  Per-invocation duplication was rejected
            # above; here we replace the former global exactly-once shortcut
            # with scenario-local at-most-once plus global reachability.
            for reader_id in set(local_membership):
                memberships = list(dict.fromkeys(
                    invocation_id_ref
                    for invocation_id_ref in invocation_membership.get(
                        reader_id, [])
                    if invocation_id_ref in set(local_invocation_ids)))
                reachable_memberships = {
                    invocation_id_ref
                    for invocation_id_ref in memberships
                    if invocation_source_scenarios_by_id.get(
                        invocation_id_ref)}
                if not reachable_memberships:
                    errors.append(
                        f"{milestone_where}.invocations: reader {reader_id} "
                        "is omitted from every source scenario")
                for scenario_index, (scenario_stages, _ancestors) in \
                        enumerate(local_execution_scenarios):
                    active_memberships = [
                        invocation_id_ref
                        for invocation_id_ref in memberships
                        if invocation_stage_id_by_id.get(invocation_id_ref)
                        in scenario_stages]
                    if len(active_memberships) > 1:
                        errors.append(
                            f"{milestone_where}.source_scenarios["
                            f"{scenario_index}]: reader {reader_id} belongs "
                            "to multiple coexisting call-site invocations")

            grouped_invocations: list[str] = []
            for group_index, group_record in enumerate(
                    milestone.get("co_presence_groups", [])
                    if isinstance(milestone.get("co_presence_groups"), list)
                    else []):
                group_where = (
                    f"{milestone_where}.co_presence_groups[{group_index}]")
                group = _exact_fields(
                    group_record, CO_PRESENCE_GROUP_FIELDS, group_where, errors)
                if not group:
                    continue
                group_id = group.get("group_id")
                if not isinstance(group_id, str) or not group_id:
                    errors.append(f"{group_where}.group_id: expected non-empty string")
                    group_id = f"invalid:{milestone_where}:{group_index}"
                elif group_id in co_presence_ids:
                    errors.append(
                        f"milestone_registry: duplicate co-presence group ID {group_id}")
                else:
                    co_presence_ids.add(group_id)
                member_invocations = _string_list(
                    group.get("invocation_ids"),
                    f"{group_where}.invocation_ids", errors, nonempty=True)
                group_proofs = _string_list(
                    group.get("runtime_proof_ids"),
                    f"{group_where}.runtime_proof_ids", errors, nonempty=True)
                grouped_invocations.extend(member_invocations)
                for invocation_id_ref in member_invocations:
                    if invocation_id_ref not in local_invocation_ids:
                        errors.append(
                            f"{group_where}: invocation {invocation_id_ref} is not in milestone")
                    if invocation_id_ref in invocation_co_presence_group:
                        errors.append(
                            f"{group_where}: duplicate invocation membership "
                            f"{invocation_id_ref}")
                    invocation_co_presence_group[invocation_id_ref] = str(
                        group_id)
                resolved_group_proofs = [
                    proof_records_by_id[ref] for ref in group_proofs
                    if ref in proof_records_by_id]
                for ref in group_proofs:
                    if ref not in proofs:
                        errors.append(f"{group_where}: missing runtime proof {ref}")
                group_token = _co_presence_contract_token(group)
                if not any(group_token in str(proof.get("assertion", ""))
                           for proof in resolved_group_proofs):
                    errors.append(
                        f"{group_where}: proof does not bind exact co-presence structure")
                expected_group_pointer = \
                    EXPECTED_CO_PRESENCE_PROOF_POINTERS.get(str(group_id))
                if (not synthetic_source_contracts
                        and EXPECTED_CO_PRESENCE_PROOF_POINTERS
                        and (expected_group_pointer is None
                             or {proof.get("pointer")
                                 for proof in resolved_group_proofs}
                             != {expected_group_pointer})):
                    errors.append(
                        f"{group_where}: audited co-presence proof owner mismatch")

                group_over_cap = False
                group_has_story_surface = any(
                    reader_records_by_id.get(reader_id, {}).get(
                        "status") == "active"
                    and reader_records_by_id.get(reader_id, {}).get(
                        "reader_kind") == "story_milestone"
                    for invocation_id_ref in member_invocations
                    for reader_id in invocation_membership
                        if invocation_id_ref in invocation_membership.get(
                            reader_id, []))
                active_member_sets: set[
                    tuple[tuple[str, int], tuple[str, ...]]] = set()
                milestone_id = str(milestone.get("milestone_id", ""))
                for scenario_index, (scenario_stages, _) in enumerate(
                        local_execution_scenarios):
                    active_members = tuple(
                        invocation_id_ref
                        for invocation_id_ref in member_invocations
                        if invocation_stage_id_by_id.get(invocation_id_ref)
                        in scenario_stages)
                    if active_members and not self_test_probe:
                        active_member_sets.add((
                            (milestone_id, scenario_index), active_members))
                for scenario_key, active_members in active_member_sets:
                    group_input_options = [
                        [option for option in
                         invocation_combinations_by_id.get(
                             ref, [(set(), set(), False, set(), set(),
                                    all_entry_modes, frozenset(),
                                    frozenset())])
                         if handoff_option_is_feasible(
                             ref, option[3], option[4], scenario_key,
                             option[5])]
                        for ref in active_members]
                    if any(not options for options in group_input_options):
                        errors.append(
                            f"{group_where}: executable source scenario has "
                            "no handoff-feasible invocation option")
                        continue
                    # Incremental set-union is equivalent to the raw
                    # Cartesian product, but it deduplicates the many
                    # call-site clones that eagerly read the same formatter
                    # tuple.  It also discards cross-invocation combinations
                    # that demand sibling choices of one authored event.
                    fanin_states: set[tuple[
                        frozenset[str], frozenset[str], bool]] = {
                            (frozenset(), frozenset(), False)}
                    for invocation_options in group_input_options:
                        next_states: set[tuple[
                            frozenset[str], frozenset[str], bool]] = set()
                        for prior_builds, prior_decisions, prior_unnamed \
                                in fanin_states:
                            for builds, decisions, unnamed, _facts, \
                                    _handoff_decisions, _entry_modes, \
                                    _reader_variants, _producer_variants \
                                    in invocation_options:
                                merged_decisions = set(prior_decisions) \
                                    | decisions
                                choice_values: dict[str, str] = {}
                                compatible = True
                                for decision_id in merged_decisions:
                                    domain_value = \
                                        _activation_choice_domain(decision_id)
                                    if domain_value is None:
                                        continue
                                    domain, value = domain_value
                                    previous = choice_values.setdefault(
                                        domain, value)
                                    if previous != value:
                                        compatible = False
                                        break
                                if not compatible:
                                    continue
                                merged_build_axes = {
                                    _fanin_memory_axis(fact_id)
                                    for fact_id in set(prior_builds) | builds}
                                state = (
                                    frozenset(merged_build_axes),
                                    frozenset(merged_decisions),
                                    prior_unnamed or unnamed,
                                )
                                if (state[2] or len(state[0]) > 2
                                        or len(state[1]) > 1):
                                    group_over_cap = True
                                    break
                                next_states.add(state)
                            if group_over_cap:
                                break
                        if group_over_cap:
                            break
                        fanin_states = next_states
                        if not fanin_states:
                            break
                    if group_over_cap:
                        break
                if group_over_cap and group_has_story_surface:
                    fanin_ids.append(f"{group_id}:fanin")

            if len(grouped_invocations) != len(set(grouped_invocations)):
                errors.append(
                    f"{milestone_where}.co_presence_groups: duplicate invocation membership")
            if set(grouped_invocations) != set(local_invocation_ids):
                errors.append(
                    f"{milestone_where}.co_presence_groups: must exactly cover invocations")
            expected_groups = EXPECTED_CO_PRESENCE_GROUPS.get(
                milestone.get("week"))
            actual_groups = {
                group.get("group_id"): group.get("invocation_ids")
                for group in milestone.get("co_presence_groups", [])
                if isinstance(group, dict)
            }
            if (not synthetic_source_contracts
                    and expected_groups is not None
                    and actual_groups != expected_groups):
                errors.append(
                    f"{milestone_where}.co_presence_groups: source scene topology mismatch")

    # Validate handoffs per reader/producer option on each reachable source
    # scenario.  Invocation-wide unions are unsound: they make a loaded-only
    # replay variant appear to consume its restored snapshot on every fresh
    # path, and they can also let one sibling producer satisfy another.
    handoff_consumers = (
        [] if self_test_probe else
        list(invocation_combinations_by_id.items()))
    for consumer_invocation_id, input_options in handoff_consumers:
        consumer_scenarios = invocation_source_scenarios_by_id.get(
            consumer_invocation_id, set())
        feasible_by_scenario: dict[
            tuple[str, int], list[tuple[
                set[str], set[str], bool, set[str], set[str],
                frozenset[str], frozenset[str], frozenset[str]]]] = {}
        for scenario_key in consumer_scenarios:
            feasible = [
                option for option in input_options
                if handoff_option_is_feasible(
                    consumer_invocation_id,
                    option[3], option[4], scenario_key, option[5])]
            feasible_by_scenario[scenario_key] = feasible
            if not feasible:
                errors.append(
                    "milestone handoff: invocation has no source-compatible "
                    "reader/producer option on scenario "
                    f"{consumer_invocation_id} @ {scenario_key}")

        # Reader groups and conditional producers form a Cartesian *schema*,
        # not a promise that every cross-pair is reachable.  For example, a
        # First Bill candidate-set reader can only pair with choices that are
        # members of that set.  Require each exact declared variant to occur
        # in at least one feasible option/scenario, while allowing impossible
        # cross-products to be discarded.
        feasible_options = [
            option
            for options in feasible_by_scenario.values()
            for option in options]
        for reader_variant_id in sorted(
                invocation_reader_variant_ids.get(
                    consumer_invocation_id, set())):
            if not any(
                    reader_variant_id in option[6]
                    for option in feasible_options):
                errors.append(
                    "milestone handoff: reader variant has no "
                    "source-compatible scenario "
                    f"{consumer_invocation_id} <- {reader_variant_id}")
        for producer_variant_id in sorted(
                invocation_producer_variant_ids.get(
                    consumer_invocation_id, set())):
            if not any(
                    producer_variant_id in option[7]
                    for option in feasible_options):
                errors.append(
                    "milestone handoff: producer variant has no "
                    "source-compatible scenario "
                    f"{consumer_invocation_id} <- {producer_variant_id}")

        # Every declared handoff-bearing variant must be reachable somewhere;
        # otherwise an optional/at-most-one slot could hide a dead or fake
        # input while another empty option keeps the invocation green.
        for fact_id in invocation_handoff_fact_inputs.get(
                consumer_invocation_id, set()):
            if not any(
                    fact_id in option[3]
                    for options in feasible_by_scenario.values()
                    for option in options):
                errors.append(
                    "milestone handoff: fact has no source-compatible earlier "
                    "same-scene producer option "
                    f"{consumer_invocation_id} <- {fact_id}")
        for decision_id in invocation_handoff_decision_inputs.get(
                consumer_invocation_id, set()):
            if not any(
                    decision_id in option[4]
                    for options in feasible_by_scenario.values()
                    for option in options):
                errors.append(
                    "milestone handoff: decision has no source-compatible "
                    "earlier same-scene producer option "
                    f"{consumer_invocation_id} <- {decision_id}")

    if (not synthetic_source_contracts
            and invocation_ids != set(EXPECTED_INVOCATION_CONTRACT_DIGESTS)):
        errors.append(
            "milestone invocations: exact audited invocation ID set mismatch")
    if (not synthetic_source_contracts
            and EXPECTED_INVOCATION_PRODUCER_DIGESTS
            and invocation_ids != set(EXPECTED_INVOCATION_PRODUCER_DIGESTS)):
        errors.append(
            "milestone producers: exact audited invocation census mismatch")
    if (not synthetic_source_contracts
            and EXPECTED_EXECUTION_STAGE_CONTRACT_DIGESTS
            and set(invocation_stage_id_by_id.values())
            != set(EXPECTED_EXECUTION_STAGE_CONTRACT_DIGESTS)):
        errors.append(
            "milestone execution stages: exact audited stage ID set mismatch")
    story_reader_ids = {
        reader_id for reader_id, reader in reader_records_by_id.items()
        if reader.get("reader_kind") == "story_milestone"
        and reader.get("status") == "active"
    }
    for reader_id in sorted(story_reader_ids):
        memberships = invocation_membership.get(reader_id, [])
        if not memberships:
            errors.append(
                f"milestone invocations: story reader {reader_id} must be referenced")

    w4_milestone = next((record for _, record, _ in milestone_records
                         if record.get("week") == 4), {})
    w4_invocation = next((item for item in w4_milestone.get("invocations", [])
                          if isinstance(item, dict)
                          and item.get("invocation_id")
                          == "reader:milestone:w04:allocation_echo"), {})
    w4_groups = w4_invocation.get("exclusive_variant_groups", [])
    w4_group = w4_groups[0] if isinstance(w4_groups, list) and len(w4_groups) == 1 else {}
    month_one_rows = {
        row.get("slot_owner"): row for row in obj.get("rows", [])
        if isinstance(row, dict) and row.get("month") == 1
    }
    w4_variants = w4_group.get("variants", []) if isinstance(w4_group, dict) else []
    w4_source_pointer = "systems/DemoCoreLoopV2.gd::_seoul_cycle_month_one_echo"
    w4_source_body = ""
    try:
        w4_source_body = _gdscript_function_body(
            (ROOT / "systems/DemoCoreLoopV2.gd").read_text(encoding="utf-8"),
            "_seoul_cycle_month_one_echo")
    except OSError:
        pass
    w4_source_markers = (
        "allocation_receipts", 'receipts.get("4"', 'get("node_id"',
        'get("turn", 0)) != 4', 'get("month", 0)) != 1',
    )
    w4_contract_ok = (
        w4_invocation.get("runtime_pointer") == w4_source_pointer
        and w4_group.get("selection_mode") == "exactly_one"
        and len(w4_variants) == 4
        and set(month_one_rows) == set(FAMILIES)
        and all(marker in w4_source_body for marker in w4_source_markers))
    seen_w4_owners: set[str] = set()
    for variant in w4_variants if isinstance(w4_variants, list) else []:
        if not isinstance(variant, dict):
            w4_contract_ok = False
            continue
        reader = reader_records_by_id.get(variant.get("reader_id"), {})
        matched_owner = next((
            owner for owner, row in month_one_rows.items()
            if variant.get("activation_fact_ids")
            == [f"receipt:allocation:{row.get('chain_id')}"]), None)
        if matched_owner is None:
            w4_contract_ok = False
            continue
        row = month_one_rows[matched_owner]
        expected_fact = f"receipt:allocation:{row.get('chain_id')}"
        if (matched_owner in seen_w4_owners
                or expected_fact not in row.get("build_facts", [])
                or reader.get("reads_fact_ids") != [expected_fact]
                or reader.get("input_build_family_ids")
                != [row.get("build_family")]
                or reader.get("runtime_pointer") != w4_source_pointer
                or any(proof_records_by_id.get(ref, {}).get("pointer")
                       != w4_source_pointer
                       for contract in reader.get("read_contracts", [])
                       if contract.get("fact_id") == expected_fact
                       for ref in contract.get("runtime_proof_ids", []))):
            w4_contract_ok = False
        seen_w4_owners.add(matched_owner)
    if seen_w4_owners != set(FAMILIES):
        w4_contract_ok = False
    if not w4_contract_ok:
        errors.append(
            "MILESTONE_FANIN W4: allocation echo variants do not exactly mirror four month-one rows/source")

    for index, witness in enumerate(obj.get("replay_witnesses", [])):
        where = f"replay_witnesses[{index}]"
        item = _exact_fields(witness, REPLAY_FIELDS, where, errors)
        if not item:
            continue
        if not _is_int(item.get("checkpoint_week")) or not 1 <= item["checkpoint_week"] <= 48:
            errors.append(f"{where}.checkpoint_week: expected 1..48")
        if not isinstance(item.get("status"), str) or not item["status"]:
            errors.append(f"{where}.status: expected non-empty string")
        for key in ("route_ids", "distinguishing_axes", "reader_ids", "runtime_proof_ids"):
            _string_list(item.get(key), f"{where}.{key}", errors)
        for ref in item.get("reader_ids", []) if isinstance(item.get("reader_ids"), list) else []:
            if ref not in readers:
                errors.append(f"{where}: missing reader {ref}")
        for ref in item.get("runtime_proof_ids", []) if isinstance(item.get("runtime_proof_ids"), list) else []:
            if ref not in proofs:
                errors.append(f"{where}: missing runtime proof {ref}")

    counter_chain_by_id: dict[str, str] = {}
    counter_records_by_id: dict[str, dict[str, Any]] = {}
    for index, counterfactual in enumerate(obj.get("counterfactual_registry", [])):
        where = f"counterfactual_registry[{index}]"
        item = _exact_fields(counterfactual, COUNTERFACTUAL_FIELDS, where, errors)
        if not item:
            continue
        chain_ref = item.get("chain_id")
        counter_id = item.get("counterfactual_id")
        if isinstance(chain_ref, str) and isinstance(counter_id, str):
            counter_chain_by_id[counter_id] = chain_ref
            counter_records_by_id[counter_id] = item
        if item.get("status") != "audited_runtime":
            errors.append(f"{where}.status: expected audited_runtime")
        for key in ("branch_ids", "distinguishing_axes", "runtime_proof_ids"):
            values = _string_list(
                item.get(key), f"{where}.{key}", errors, nonempty=True)
            if key == "branch_ids" and len(values) < 2:
                errors.append(f"{where}.branch_ids: expected at least two branches")
        for ref in item.get("runtime_proof_ids", []) if isinstance(item.get("runtime_proof_ids"), list) else []:
            if ref not in proofs:
                errors.append(f"{where}: missing runtime proof {ref}")
        branch_contracts = item.get("branch_contracts")
        if not isinstance(branch_contracts, list):
            errors.append(f"{where}.branch_contracts: expected array")
            branch_contracts = []
        contract_branch_ids: list[str] = []
        branch_proof_union: set[str] = set()
        for branch_index, branch_contract in enumerate(branch_contracts):
            branch_where = f"{where}.branch_contracts[{branch_index}]"
            contract = _exact_fields(
                branch_contract, BRANCH_CONTRACT_FIELDS,
                branch_where, errors)
            if not contract:
                continue
            branch_id = contract.get("branch_id")
            if not isinstance(branch_id, str) or not branch_id:
                errors.append(f"{branch_where}.branch_id: expected non-empty string")
            else:
                contract_branch_ids.append(branch_id)
            if contract.get("outcome_kind") not in {"completed", "expired"}:
                errors.append(
                    f"{branch_where}.outcome_kind: expected completed|expired")
            _string_list(
                contract.get("applicability_ids"),
                f"{branch_where}.applicability_ids", errors, nonempty=True)
            nested_group_ids = _string_list(
                contract.get("nested_output_group_ids"),
                f"{branch_where}.nested_output_group_ids", errors)
            if len(nested_group_ids) != len(set(nested_group_ids)):
                errors.append(
                    f"{branch_where}.nested_output_group_ids: duplicate nested group")
            branch_facts = _string_list(
                contract.get("produced_fact_ids"),
                f"{branch_where}.produced_fact_ids", errors, nonempty=True)
            if set(branch_facts) & {"event_log", "action_log"}:
                errors.append(
                    f"{branch_where}.produced_fact_ids: Story logs cannot prove route divergence")
            branch_proof_ids = _string_list(
                contract.get("runtime_proof_ids"),
                f"{branch_where}.runtime_proof_ids", errors, nonempty=True)
            branch_proof_union.update(branch_proof_ids)
            for ref in branch_proof_ids:
                if ref not in proofs:
                    errors.append(f"{branch_where}: missing runtime proof {ref}")
        if contract_branch_ids != item.get("branch_ids"):
            errors.append(
                f"{where}.branch_contracts: ordered branch bijection mismatch")
        if not branch_proof_union.issubset(set(item.get("runtime_proof_ids", []))):
            errors.append(
                f"{where}.branch_contracts: branch proof union is not covered by top proofs")

    rows = obj.get("rows")
    if not isinstance(rows, list):
        errors.append("ledger.rows: expected array")
        rows = []
    actual_row_order = [
        (row.get("month"), row.get("slot_owner"))
        for row in rows if isinstance(row, dict)]
    expected_row_order = sorted(
        actual_row_order,
        key=lambda item: (
            item[0] if _is_int(item[0]) else 10_000,
            FAMILIES.index(item[1]) if item[1] in FAMILIES else 10_000))
    if actual_row_order != expected_row_order:
        errors.append(
            "ROW_BIJECTION: rows must use exact month/slot-owner canonical order")
    chain_ids: set[str] = set()
    slot_counts: dict[str, int] = {}
    mirror_cache: dict[Path, Any] = {}
    for index, row in enumerate(rows):
        _validate_row(row, index, errors)
        if not isinstance(row, dict):
            continue
        if not (synthetic_source_contracts
                and str(row.get("chain_id", "")).startswith("selftest_")):
            _validate_runtime_mirror(
                row, index, errors, mirror_cache,
                enforce_source_contracts=not synthetic_source_contracts)
        chain_id = row.get("chain_id")
        if isinstance(chain_id, str):
            if chain_id in chain_ids:
                errors.append(f"ROW_BIJECTION duplicate chain_id {chain_id}")
            chain_ids.add(chain_id)
        month, slot_owner = row.get("month"), row.get("slot_owner")
        if _is_int(month) and slot_owner in FAMILIES:
            slot_id = f"slot:m{month:02d}:{slot_owner}"
            slot_counts[slot_id] = slot_counts.get(slot_id, 0) + 1
        for ref in row.get("near_reader_ids", []) if isinstance(row.get("near_reader_ids"), list) else []:
            if ref not in readers:
                errors.append(f"ORPHAN_FACT {chain_id}: missing near reader {ref}")
            elif any(str(fact_id).startswith("history_summary:")
                     for fact_id in reader_records_by_id.get(
                         ref, {}).get("reads_fact_ids", [])):
                errors.append(
                    f"ORPHAN_FACT {chain_id}: narrative summary reader may "
                    "not replace a row-owned raw causal reader")
        for ref in row.get("milestone_reader_ids", []) if isinstance(row.get("milestone_reader_ids"), list) else []:
            if ref not in readers:
                errors.append(f"ORPHAN_FACT {chain_id}: missing milestone reader {ref}")
            elif any(str(fact_id).startswith("history_summary:")
                     for fact_id in reader_records_by_id.get(
                         ref, {}).get("reads_fact_ids", [])):
                errors.append(
                    f"ORPHAN_FACT {chain_id}: narrative summary reader may "
                    "not replace a row-owned raw causal reader")
        if _is_int(row.get("month")):
            month_reader_id = f"reader:month:m{row['month']:02d}:summary"
            month_reader = reader_records_by_id.get(month_reader_id, {})
            if (month_reader.get("status") != "active"
                    or month_reader.get("reader_kind") != "month_summary"):
                errors.append(
                    f"ORPHAN_FACT {chain_id}: month-end reader is not active month_summary")
        missed = row.get("missed_contract", {})
        if isinstance(missed, dict):
            missed_reader_ids = missed.get("reader_ids", []) \
                if isinstance(missed.get("reader_ids"), list) else []
            for ref in missed_reader_ids:
                if ref not in readers:
                    errors.append(f"ORPHAN_FACT {chain_id}: missing missed reader {ref}")
                elif any(str(fact_id).startswith("history_summary:")
                         for fact_id in reader_records_by_id.get(
                             ref, {}).get("reads_fact_ids", [])):
                    errors.append(
                        f"ORPHAN_FACT {chain_id}: narrative summary reader "
                        "may not replace a row-owned raw causal reader")
            missed_reader_facts = {
                fact_id for reader_id in missed_reader_ids
                for fact_id in bound_facts_by_reader.get(reader_id, set())}
            missed_receipts = missed.get("receipt_ids", []) \
                if isinstance(missed.get("receipt_ids"), list) else []
            if (not synthetic_source_contracts
                    and not set(missed_receipts).issubset(
                        missed_reader_facts)):
                errors.append(
                    f"ORPHAN_FACT {chain_id}: missed receipt is not bound by its named reader")
        for ref in row.get("runtime_proof_ids", []) if isinstance(row.get("runtime_proof_ids"), list) else []:
            if ref not in proofs:
                errors.append(f"SAVE_ROUNDTRIP {chain_id}: missing runtime proof {ref}")
        no_eligible = row.get("availability", {}).get(
            "no_eligible_contract")
        if isinstance(no_eligible, dict):
            for ref in no_eligible.get("runtime_proof_ids", []):
                if ref not in proofs:
                    errors.append(
                        f"ROW_BIJECTION {chain_id}: missing no-eligible runtime proof {ref}")
        for variant in row.get("producer", {}).get(
                "conditional_output_variants", []):
            if not isinstance(variant, dict):
                continue
            for ref in variant.get("runtime_proof_ids", []):
                if ref not in proofs:
                    errors.append(
                        f"ORPHAN_FACT {chain_id}: missing output-variant proof {ref}")
        row_proof_id = f"proof:row:{chain_id}"
        row_proof = proof_records_by_id.get(row_proof_id, {})
        if (row_proof_id not in row.get("runtime_proof_ids", [])
                or row_proof.get("pointer") != row.get("runtime_pointer")
                or row_proof.get("kind") != "json_pointer"):
            errors.append(
                f"SAVE_ROUNDTRIP {chain_id}: row proof must exactly bind runtime pointer")
        row_save_proofs = [
            proof_id for proof_id in row.get("runtime_proof_ids", [])
            if proof_id in SAVE_ROUNDTRIP_PROOF_POINTERS]
        if row_save_proofs != list(SAVE_ROUNDTRIP_PROOF_POINTERS):
            errors.append(
                f"SAVE_ROUNDTRIP {chain_id}: row lacks exact ordered disk roundtrip proof chain")
        for proof_id, expected_pointer in SAVE_ROUNDTRIP_PROOF_POINTERS.items():
            proof = proof_records_by_id.get(proof_id, {})
            if (proof.get("kind") != "source_symbol"
                    or proof.get("pointer") != expected_pointer):
                errors.append(
                    f"SAVE_ROUNDTRIP {chain_id}: save proof is not bound to normalization source")
        counterfactual_id = row.get("counterfactual_id")
        if isinstance(counterfactual_id, str) and counterfactual_id not in counterfactuals:
            errors.append(f"COUNTERFACTUAL_NOOP {chain_id}: missing counterfactual {counterfactual_id}")
    for chain_ref in counter_chain_by_id.values():
        if chain_ref not in chain_ids:
            errors.append(f"counterfactual_registry: missing row chain {chain_ref}")
    row_counter_ids = [
        row.get("counterfactual_id") for row in rows if isinstance(row, dict)
    ]
    if len(row_counter_ids) != len(set(row_counter_ids)):
        errors.append("counterfactual_registry: row counterfactual IDs must be unique")
    if set(row_counter_ids) != counterfactuals:
        errors.append("counterfactual_registry: expected exact row↔counterfactual bijection")
    row_by_slot = {
        (row.get("month"), row.get("slot_owner")): row
        for row in rows if isinstance(row, dict)
    }
    row_by_chain = {
        row.get("chain_id"): row for row in rows
        if isinstance(row, dict) and isinstance(row.get("chain_id"), str)
    }
    branch_realized_facts_by_id: dict[str, list[frozenset[str]]] = {}
    for row in rows:
        if not isinstance(row, dict):
            continue
        counter_id = row.get("counterfactual_id")
        if counter_chain_by_id.get(counter_id) != row.get("chain_id"):
            errors.append(
                f"COUNTERFACTUAL_NOOP {row.get('chain_id')}: counterfactual chain mismatch")
        counter = counter_records_by_id.get(counter_id, {})
        expected_branches, expected_axes, expected_proofs = (
            _expected_counterfactual_contract(
                row, complete=require_complete, cache=mirror_cache))
        if counter.get("branch_ids") != expected_branches:
            errors.append(
                f"COUNTERFACTUAL_NOOP {row.get('chain_id')}: branch IDs do not mirror row contract")
        if counter.get("distinguishing_axes") != expected_axes:
            errors.append(
                f"COUNTERFACTUAL_NOOP {row.get('chain_id')}: axes do not mirror row contract")
        if counter.get("runtime_proof_ids") != expected_proofs:
            errors.append(
                f"COUNTERFACTUAL_NOOP {row.get('chain_id')}: proofs do not mirror row/source contract")
        expected_branch_contracts = _expected_branch_contracts(
            row, mirror_cache)
        if not synthetic_source_contracts:
            if counter.get("branch_contracts") != expected_branch_contracts:
                errors.append(
                    f"COUNTERFACTUAL_NOOP {row.get('chain_id')}: branch contracts do not mirror source outputs")
            expected_contract_by_id = {
                item.get("branch_id"): item
                for item in expected_branch_contracts
                if isinstance(item, dict)}
            for branch_index, branch_contract in enumerate(
                    counter.get("branch_contracts", [])):
                if not isinstance(branch_contract, dict):
                    continue
                branch_id = branch_contract.get("branch_id")
                branch_where = (
                    f"counterfactual:{counter_id}.branch_contracts["
                    f"{branch_index}]")
                expected_contract = expected_contract_by_id.get(branch_id, {})
                if (isinstance(expected_contract, dict)
                        and branch_contract.get("nested_output_group_ids")
                        != expected_contract.get("nested_output_group_ids")):
                    errors.append(
                        f"{branch_where}.nested_output_group_ids: source-owned nested group mismatch")
                realized = _validate_nested_branch_contract(
                    row, branch_contract, branch_where, errors,
                    mirror_cache)
                if isinstance(branch_id, str) and branch_id:
                    branch_realized_facts_by_id[branch_id] = realized
        if not synthetic_source_contracts:
            producer_completion_facts = {
                fact_id
                for fact_id in row.get("producer", {}).get(
                    "completion_receipt_ids", [])
                if (isinstance(fact_id, str)
                    and (fact_id.startswith("receipt:completed:")
                         or fact_id == "fact:resume_polished"))
            }
            completed_branch_facts = {
                fact_id
                for branch_contract in counter.get("branch_contracts", [])
                if (isinstance(branch_contract, dict)
                    and branch_contract.get("outcome_kind") == "completed")
                for realized_facts in _branch_realized_fact_sets(
                    row, branch_contract, mirror_cache)
                for fact_id in realized_facts
                if (isinstance(fact_id, str)
                    and (fact_id.startswith("receipt:completed:")
                         or fact_id == "fact:resume_polished"))
            }
            if producer_completion_facts != completed_branch_facts:
                errors.append(
                    f"COUNTERFACTUAL_NOOP {row.get('chain_id')}: producer/branch potential completion fact bijection mismatch")
        if not synthetic_source_contracts:
            repeatable = row.get("terminal_contract", {}).get(
                "repeatable_after_completion", False)
            expected_completed_verbs = [row.get("chain_id")] if repeatable else []
            next_row = row_by_slot.get(
                (row.get("month", 0) + 1, row.get("slot_owner")))
            expected_expired_verbs = [next_row.get("chain_id")] \
                if isinstance(next_row, dict) else []
            if row.get("next_verb_by_terminal", {}).get(
                    "completed") != expected_completed_verbs:
                errors.append(
                    f"rows[{rows.index(row)}].next_verb_by_terminal.completed: source transition mismatch")
            if row.get("next_verb_by_terminal", {}).get(
                    "expired") != expected_expired_verbs:
                errors.append(
                    f"rows[{rows.index(row)}].next_verb_by_terminal.expired: source transition mismatch")

    branch_owner: dict[str, str] = {}
    for counter_id, counter in counter_records_by_id.items():
        for branch_id in counter.get("branch_ids", []):
            if isinstance(branch_id, str):
                branch_owner[branch_id] = counter_id
    milestone_by_week = {
        milestone.get("week"): milestone
        for _, milestone, _ in milestone_records
        if _is_int(milestone.get("week"))
    }
    invalid_replay_divergence_ids: set[str] = set()
    for witness_index, witness in enumerate(obj.get("replay_witnesses", [])):
        if not isinstance(witness, dict):
            continue
        where = f"replay_witnesses[{witness_index}]"
        route_ids = witness.get("route_ids", [])
        referenced_counter_id_order: list[str] = []
        if isinstance(route_ids, list):
            for route_id in route_ids:
                counter_id = branch_owner.get(route_id)
                if (isinstance(counter_id, str)
                        and counter_id not in referenced_counter_id_order):
                    referenced_counter_id_order.append(counter_id)
        referenced_counter_ids = set(referenced_counter_id_order)
        routes_per_counter = {
            counter_id: sum(
                1 for route_id in route_ids
                if branch_owner.get(route_id) == counter_id)
            for counter_id in referenced_counter_ids
        } if isinstance(route_ids, list) else {}
        if (not synthetic_source_contracts and (
                not routes_per_counter
                or any(count < 2 for count in routes_per_counter.values()))):
            errors.append(
                f"{where}.route_ids: every compared counterfactual needs at least two alternatives")
        if (not synthetic_source_contracts and (not route_ids
                or any(route_id not in branch_owner for route_id in route_ids))):
            errors.append(f"{where}.route_ids: route is not a declared counterfactual branch")
        referenced_counters = [
            counter_records_by_id[counter_id]
            for counter_id in referenced_counter_id_order
            if counter_id in counter_records_by_id]
        expected_axes: list[str] = []
        for counter in referenced_counters:
            for axis in counter.get("distinguishing_axes", []):
                if isinstance(axis, str) and axis not in expected_axes:
                    expected_axes.append(axis)
        axes = witness.get("distinguishing_axes", [])
        if (not synthetic_source_contracts and (
                not isinstance(axes, list) or not axes
                or axes != expected_axes)):
            errors.append(f"{where}.distinguishing_axes: not bound to route contracts")
        referenced_rows = [
            row_by_chain.get(counter.get("chain_id"), {})
            for counter in referenced_counters]
        checkpoint_week = witness.get("checkpoint_week")
        checkpoint = milestone_by_week.get(checkpoint_week, {})
        allowed_readers = set(checkpoint.get("reader_ids", []))
        for row in referenced_rows:
            allowed_readers.update(row.get("near_reader_ids", []))
            allowed_readers.update(row.get("milestone_reader_ids", []))
        witness_readers = witness.get("reader_ids", [])
        if (not synthetic_source_contracts and (
                not isinstance(witness_readers, list) or not witness_readers
                or not set(witness_readers).issubset(allowed_readers))):
            errors.append(f"{where}.reader_ids: not bound to checkpoint/routes")
        if (not synthetic_source_contracts and _is_int(checkpoint_week)
                and isinstance(witness_readers, list)):
            late_readers = [
                reader_id for reader_id in witness_readers
                if (_reader_first_available_week(
                    reader_records_by_id.get(reader_id, {}), row_by_chain,
                    fact_pointer_cache) or 0) > checkpoint_week]
            if late_readers:
                errors.append(
                    f"{where}.reader_ids: reader is not available by checkpoint {late_readers}")
        if not synthetic_source_contracts and isinstance(route_ids, list):
            branch_contract_by_id = {
                contract.get("branch_id"): contract
                for counter in referenced_counters
                for contract in counter.get("branch_contracts", [])
                if isinstance(contract, dict)
                and isinstance(contract.get("branch_id"), str)
            }
            witness_read_facts = {
                fact_id for reader_id in witness_readers
                for fact_id in bound_facts_by_reader.get(reader_id, set())
            } if isinstance(witness_readers, list) else set()
            route_fact_options: list[list[frozenset[str]]] = []
            for route_id in route_ids:
                fallback = branch_contract_by_id.get(route_id, {}).get(
                    "produced_fact_ids", [])
                realized_options = branch_realized_facts_by_id.get(
                    route_id, [frozenset(
                        value for value in fallback
                        if isinstance(value, str))])
                evidence_options = list(dict.fromkeys(
                    frozenset(witness_read_facts.intersection(facts))
                    for facts in realized_options
                    if witness_read_facts.intersection(facts)))
                route_fact_options.append(evidence_options)
            independently_bound = bool(route_fact_options) \
                and all(route_fact_options)
            if independently_bound and len(route_fact_options) > 1:
                independently_bound = False
                for selected_evidence in itertools.product(
                        *route_fact_options):
                    if all(
                            evidence - set().union(*(
                                other for other_index, other in enumerate(
                                    selected_evidence)
                                if other_index != route_index))
                            for route_index, evidence in enumerate(
                                selected_evidence)):
                        independently_bound = True
                        break
            if not independently_bound:
                errors.append(
                    f"{where}.route_ids: route facts are not independently bound to witness readers")
                witness_id = witness.get("witness_id")
                if isinstance(witness_id, str) and witness_id:
                    invalid_replay_divergence_ids.add(
                        f"witness:{witness_id}:no_divergence")
        required_proofs = {f"proof:milestone:w{int(checkpoint_week):02d}"} \
            if _is_int(checkpoint_week) else set()
        for row in referenced_rows:
            chain_id = row.get("chain_id")
            if isinstance(chain_id, str):
                required_proofs.add(f"proof:row:{chain_id}")
            if (row.get("slot_owner") == "people"
                    and chain_id != "m1_father"):
                required_proofs.add("proof:runtime:first_eligible_person")
        witness_proofs = set(witness.get("runtime_proof_ids", [])) \
            if isinstance(witness.get("runtime_proof_ids"), list) else set()
        allowed_extra_proofs = {"proof:runtime:terminal_expiry"}
        if (not synthetic_source_contracts and (
                not required_proofs.issubset(witness_proofs)
                or not witness_proofs.issubset(
                    required_proofs | allowed_extra_proofs))):
            errors.append(f"{where}.runtime_proof_ids: not bound to routes/checkpoint")

    counterfactual_noop_ids: list[str] = []
    route_no_divergence_ids: list[str] = sorted(
        invalid_replay_divergence_ids)
    route_hard_lock_ids: list[str] = []
    for row in rows:
        if not isinstance(row, dict):
            continue
        counter_id = row.get("counterfactual_id")
        counter = counter_records_by_id.get(counter_id, {})
        contracts = [
            item for item in counter.get("branch_contracts", [])
            if isinstance(item, dict)]
        route_read_fact_ids = _row_route_read_fact_ids(
            row, reader_records_by_id, bound_facts_by_reader)
        full_signature_sets = [
            _branch_causal_signatures(
                row, contract, route_read_fact_ids, mirror_cache,
                include_nested_outputs=True)
            for contract in contracts]
        weekly_signature_sets = [
            _branch_causal_signatures(
                row, contract, route_read_fact_ids, mirror_cache,
                include_nested_outputs=False)
            for contract in contracts]
        if isinstance(counter_id, str) and counter_id:
            for left in range(len(contracts)):
                for right in range(left + 1, len(contracts)):
                    left_id = str(contracts[left].get("branch_id", left))
                    right_id = str(contracts[right].get("branch_id", right))
                    # Equality of even one reachable branch×nested history is
                    # a no-op.  A distinct extra history on one sibling may
                    # not hide their shared identical history.
                    if (full_signature_sets[left]
                            & full_signature_sets[right]):
                        counterfactual_noop_ids.append(_pair_debt_id(
                            counter_id, "noop", left_id, right_id))
                    # Weekly divergence needs a board-owned difference.  Story
                    # or action-result nested effects alone cannot green it.
                    if (weekly_signature_sets[left]
                            & weekly_signature_sets[right]):
                        route_no_divergence_ids.append(_pair_debt_id(
                            counter_id, "no_divergence", left_id, right_id))
        reachable_count = sum(
            _branch_is_potentially_reachable(
                row, contract, synthetic=synthetic_source_contracts,
                readers=reader_records_by_id,
                bound_facts_by_reader=bound_facts_by_reader,
                cache=mirror_cache)
            for contract in contracts)
        if reachable_count < 2 and isinstance(counter_id, str) and counter_id:
            route_hard_lock_ids.append(
                f"counter:{counter_id}:hard_lock")
    counterfactual_noop_ids.sort()
    route_no_divergence_ids = sorted(set(route_no_divergence_ids))
    route_hard_lock_ids.sort()

    for index, row in enumerate(rows):
        if not isinstance(row, dict):
            continue
        for terminal in ("completed", "expired"):
            verbs = row.get("next_verb_by_terminal", {}).get(terminal, [])
            if not isinstance(verbs, list):
                continue
            for verb in verbs:
                if verb not in chain_ids and verb not in readers:
                    errors.append(
                        f"rows[{index}].next_verb_by_terminal.{terminal}: unresolved verb {verb}")
                elif verb in readers:
                    reader = reader_records_by_id.get(verb, {})
                    if (reader.get("status") != "active"
                            or reader.get("reader_kind")
                            not in NEXT_VERB_READER_KINDS):
                        errors.append(
                            f"rows[{index}].next_verb_by_terminal.{terminal}: "
                            f"reader {verb} is not an active next verb/action unlock")
                elif (verb == row.get("chain_id")
                      and not row.get("terminal_contract", {}).get(
                          "repeatable_after_completion", False)):
                    errors.append(
                        f"rows[{index}].next_verb_by_terminal.{terminal}: "
                        "non-repeatable terminal may not loop to itself")

    target_slots = {f"slot:m{month:02d}:{family}"
                    for month in range(1, 13) for family in FAMILIES}
    implemented_slots = {slot for slot, count in slot_counts.items() if count == 1}
    duplicate_slots = sorted(slot for slot, count in slot_counts.items() if count > 1)
    missing_slots = sorted(target_slots - implemented_slots)
    row_bijection_debts = sorted(set(missing_slots + duplicate_slots))
    metrics["implemented"] = len(implemented_slots)
    metrics["missing"] = len(missing_slots)
    implemented_months = sorted({int(slot.split(":")[1][1:])
                                 for slot in implemented_slots})
    authoritative_month_range = [1, max(implemented_months)] if implemented_months else []
    authoritative_week_range = [1, max(implemented_months) * 4] if implemented_months else []
    if scope:
        if scope.get("authoritative_row_count") != len(implemented_slots):
            errors.append(
                f"ledger.scope.authoritative_row_count: expected {len(implemented_slots)}")
        if scope.get("authoritative_month_range") != authoritative_month_range:
            errors.append(
                f"ledger.scope.authoritative_month_range: expected {authoritative_month_range}")
        if scope.get("authoritative_week_range") != authoritative_week_range:
            errors.append(
                f"ledger.scope.authoritative_week_range: expected {authoritative_week_range}")
        if implemented_months and implemented_months != list(range(1, max(implemented_months) + 1)):
            errors.append("ledger.scope: authoritative months must be a contiguous prefix")

    gap_rows = obj.get("coverage_gaps")
    if not isinstance(gap_rows, list):
        errors.append("coverage_gaps: expected array")
        gap_rows = []
    gap_ids: set[str] = set()
    if missing_slots and len(gap_rows) != 1:
        errors.append(f"coverage_gaps: expected exactly one gap for {len(missing_slots)} missing slots")
    if not missing_slots and gap_rows:
        errors.append("coverage_gaps: complete slot set must have no gaps")
    for index, gap in enumerate(gap_rows):
        where = f"coverage_gaps[{index}]"
        item = _exact_fields(gap, GAP_FIELDS, where, errors)
        if not item:
            continue
        gap_id = item.get("gap_id")
        if not isinstance(gap_id, str) or not gap_id:
            errors.append(f"{where}.gap_id: expected non-empty string")
        elif gap_id in gap_ids:
            errors.append(f"coverage_gaps: duplicate gap ID {gap_id}")
        else:
            gap_ids.add(gap_id)
        week_range = _range(item.get("week_range"), f"{where}.week_range", errors)
        month_range = _range(item.get("month_range"), f"{where}.month_range", errors)
        metrics["week_range"] = week_range
        if item.get("missing_row_count") != len(missing_slots):
            errors.append(f"{where}.missing_row_count: expected {len(missing_slots)}")
        if item.get("status") != "missing_authoritative_canon":
            errors.append(f"{where}.status: gap may not claim implemented gameplay")
        if item.get("slot_owner_order") != FAMILIES:
            errors.append(f"{where}.slot_owner_order: expected exact family order")
        owners = item.get("owner_order")
        if not isinstance(owners, list) or not owners:
            errors.append(f"{where}.owner_order: expected non-empty owner array")
        else:
            for owner_index, owner in enumerate(owners):
                if (not isinstance(owner, dict)
                        or set(owner) != {"order_id", "month_range"}
                        or not isinstance(owner.get("order_id"), str)):
                    errors.append(f"{where}.owner_order[{owner_index}]: malformed owner")
                else:
                    _range(owner.get("month_range"),
                           f"{where}.owner_order[{owner_index}].month_range", errors)
        gap_proof_refs = _string_list(item.get("runtime_proof_ids"),
                                      f"{where}.runtime_proof_ids", errors,
                                      nonempty=True)
        for ref in gap_proof_refs:
            if ref not in proofs:
                errors.append(f"{where}: missing runtime proof {ref}")
        if month_range:
            expected_gap_slots = {
                f"slot:m{month:02d}:{family}"
                for month in range(month_range[0], month_range[1] + 1)
                for family in FAMILIES
            }
            if set(missing_slots) != expected_gap_slots:
                errors.append(f"{where}: month range does not exactly cover missing slots")
            if week_range != [(month_range[0] - 1) * 4 + 1, month_range[1] * 4]:
                errors.append(f"{where}: week/month ranges disagree")
        if len(missing_slots) == 24:
            expected_owner_order = [
                {"order_id": "ORDER-104", "month_range": [7, 8]},
                {"order_id": "ORDER-105", "month_range": [9, 10]},
                {"order_id": "ORDER-106", "month_range": [11, 12]},
            ]
            if item.get("gap_id") != "gap:ch1_m07_m12":
                errors.append(f"{where}.gap_id: expected ORDER-100 gap ID")
            if item.get("owner_order") != expected_owner_order:
                errors.append(f"{where}.owner_order: expected ORDER-104..106 routing")
            if gap_proof_refs != EXPECTED_GAP_PROOFS:
                errors.append(f"{where}.runtime_proof_ids: exact gap proof set mismatch")
            for proof_id, expected_pointer in EXPECTED_GAP_PROOF_POINTERS.items():
                if proof_records_by_id.get(proof_id, {}).get(
                        "pointer") != expected_pointer:
                    errors.append(f"{where}: gap proof {proof_id} pointer mismatch")
            months_value = _json_pointer_value(
                EXPECTED_GAP_PROOF_POINTERS["proof:contract:months_stop_at_m06"],
                mirror_cache)
            turn_limit_source = _pointer_source_text(
                EXPECTED_GAP_PROOF_POINTERS["proof:runtime:turn_limit_24"],
                mirror_cache)
            cta_source = _pointer_source_text(
                EXPECTED_GAP_PROOF_POINTERS["proof:runtime:w24_completion_cta"],
                mirror_cache)
            if (not isinstance(months_value, dict)
                    or list(months_value) != [str(month) for month in range(1, 7)]
                    or not re.search(r"DEMO_TURN_LIMIT\s*:?[^=]*=\s*24\b",
                                     turn_limit_source)
                    or "development_cap_week" not in cta_source
                    or "GameState.turn == cap_week" not in cta_source
                    or "_core_loop_v2_show_completion" not in cta_source):
                errors.append(f"{where}: gap proofs do not bind the W24 runtime boundary")

    evaluations = obj.get("evaluation_registry")
    if not isinstance(evaluations, list):
        errors.append("evaluation_registry: expected array")
        evaluations = []
    by_code: dict[str, dict[str, Any]] = {}
    current_debts: dict[str, list[str]] = {}
    blocked_count = 0
    for index, evaluation in enumerate(evaluations):
        where = f"evaluation_registry[{index}]"
        item = _exact_fields(evaluation, EVALUATION_FIELDS, where, errors)
        if not item:
            continue
        code = item.get("error_code")
        if code not in ERROR_CODES:
            errors.append(f"{where}.error_code: unknown code {code!r}")
            continue
        if code in by_code:
            errors.append(f"evaluation_registry: duplicate error code {code}")
        by_code[code] = item
        _range(item.get("scope_week_range"), f"{where}.scope_week_range", errors)
        debt_ids = _string_list(item.get("debt_ids"), f"{where}.debt_ids", errors)
        blockers = _string_list(item.get("blocker_ids"), f"{where}.blocker_ids", errors)
        if debt_ids != sorted(debt_ids):
            errors.append(f"{where}.debt_ids: IDs must be sorted")
        if blockers != sorted(blockers):
            errors.append(f"{where}.blocker_ids: IDs must be sorted")
        status = item.get("status")
        expected_scope = ([1, 48] if code == "ROW_BIJECTION"
                          or code in BLOCKED_WHILE_COVERAGE_OPEN
                          else authoritative_week_range)
        if item.get("scope_week_range") != expected_scope:
            errors.append(f"{where}.scope_week_range: expected exact {expected_scope}")
        if status == "blocked_by_coverage":
            blocked_count += 1
            if debt_ids:
                errors.append(f"{where}: blocked evaluation may not report zero/full debt")
            if not blockers:
                errors.append(f"{where}: blocked evaluation needs blocker gap ID")
            for blocker in blockers:
                if blocker not in gap_ids:
                    errors.append(f"{where}: unknown blocker {blocker}")
        elif status == "evaluated":
            if blockers:
                errors.append(f"{where}: evaluated entry may not retain blockers")
            if debt_ids:
                current_debts[code] = sorted(debt_ids)
        else:
            errors.append(f"{where}.status: invalid status {status!r}")
    missing_codes = sorted(set(ERROR_CODES) - set(by_code))
    if missing_codes:
        errors.append(f"evaluation_registry: missing error codes {missing_codes}")
    if gap_ids:
        for code in BLOCKED_WHILE_COVERAGE_OPEN:
            if by_code.get(code, {}).get("status") != "blocked_by_coverage":
                errors.append(f"{code}: coverage exists but evaluation claims full scope")
        actual_blocked = {
            code for code, item in by_code.items()
            if item.get("status") == "blocked_by_coverage"
        }
        if actual_blocked != BLOCKED_WHILE_COVERAGE_OPEN:
            errors.append(
                "evaluation_registry: only the three full-run evaluations may be coverage-blocked")
    elif blocked_count:
        errors.append("evaluation_registry: blocked evaluations remain without coverage gap")

    declared_row_debt = by_code.get("ROW_BIJECTION", {}).get("debt_ids", [])
    if sorted(declared_row_debt) != row_bijection_debts:
        errors.append(
            "ROW_BIJECTION: evaluated debt IDs do not equal missing/duplicate target slots")
    auto_ids = sorted(
        f"row:{row.get('chain_id')}:selection_owner" for row in rows
        if (isinstance(row, dict) and row.get("slot_owner") == "people"
            and row.get("selection_owner") == "runtime_first_eligible"))
    if sorted(by_code.get("AUTO_PERSON_PICK", {}).get("debt_ids", [])) != auto_ids:
        errors.append(
            "AUTO_PERSON_PICK: debt IDs do not equal runtime-first-eligible people rows")
    cap_ids = sorted(
        f"row:{row.get('chain_id')}:declared_cap_{row['availability'].get('declared_candidate_cap')}"
        for row in rows
        if isinstance(row, dict) and isinstance(row.get("availability"), dict)
        and _is_int(row["availability"].get("declared_candidate_cap"))
        and _is_int(row["availability"].get("runtime_candidate_cap"))
        and row["availability"]["declared_candidate_cap"]
        > row["availability"]["runtime_candidate_cap"])
    if sorted(by_code.get("UNREACHABLE_CAP", {}).get("debt_ids", [])) != cap_ids:
        errors.append("UNREACHABLE_CAP: debt IDs do not equal declared/runtime cap gaps")
    def has_valid_completed_verb(row: dict[str, Any]) -> bool:
        verbs = row.get("next_verb_by_terminal", {}).get("completed", [])
        if not isinstance(verbs, list):
            return False
        counter = counter_records_by_id.get(row.get("counterfactual_id"), {})
        completed_receipts: list[str] = []
        for branch in counter.get("branch_contracts", []):
            if (not isinstance(branch, dict)
                    or branch.get("outcome_kind") != "completed"):
                continue
            facts = [
                fact_id for fact_id in branch.get("produced_fact_ids", [])
                if isinstance(fact_id, str)
                and fact_id.startswith("receipt:completed:")]
            if len(facts) != 1:
                return False
            completed_receipts.append(facts[0])
        if not completed_receipts:
            return False
        declared_reader_ids = {
            verb for verb in verbs if verb in reader_records_by_id
            and reader_records_by_id[verb].get("status") == "active"
            and reader_records_by_id[verb].get("reader_kind")
                in NEXT_VERB_READER_KINDS}
        if declared_reader_ids:
            return all(any(
                receipt in bound_facts_by_reader.get(reader_id, set())
                for reader_id in declared_reader_ids)
                for receipt in completed_receipts)
        for verb in verbs:
            if verb in chain_ids and verb != row.get("chain_id"):
                return True
        return False

    dead_ids = sorted(
        f"row:{row.get('chain_id')}:completed" for row in rows
        if isinstance(row, dict)
        and isinstance(row.get("terminal_contract"), dict)
        and not row["terminal_contract"].get("repeatable_after_completion", False)
        and not has_valid_completed_verb(row))
    if sorted(by_code.get("DEAD_CARD", {}).get("debt_ids", [])) != dead_ids:
        errors.append("DEAD_CARD: debt IDs do not equal non-repeatable completed terminals without next verbs")
    fake_repeat_ids = sorted(
        f"row:{row.get('chain_id')}:repeat_contract" for row in rows
        if isinstance(row, dict)
        and isinstance(row.get("terminal_contract"), dict)
        and row["terminal_contract"].get("repeatable_after_completion", False)
        and (not isinstance(row.get("producer"), dict)
             or not row["producer"].get("repeat_receipt_unique_by", [])
             or not _repeat_contract_has_cost_and_effect(row, mirror_cache)))
    if sorted(by_code.get("FAKE_REPEAT", {}).get("debt_ids", [])) != fake_repeat_ids:
        errors.append(
            "FAKE_REPEAT: debt IDs do not equal repeat rows lacking unique receipts or real recurring cost/effect")
    grouped_shadowed_members = set(shadowed_invocation_membership)
    ungrouped_shadowed = sorted(raw_shadowed_reader_ids - grouped_shadowed_members)
    source_shadowed_active_readers = ({
        W24_COMPLETION_APPLICATION_READER_ID}
        if (_w24_completion_application_identity_is_shadowed(mirror_cache)
            and not _w24_has_exact_completion_identity_gate(
                milestone_records, reader_records_by_id,
                bound_facts_by_reader))
        else set())
    shadowed_reader_ids = sorted(
        set(shadowed_group_debt_ids)
        | set(ungrouped_shadowed)
        | source_shadowed_active_readers)
    if any(len(groups) != 1 for groups in shadowed_invocation_membership.values()):
        errors.append(
            "SHADOWED_READER: each grouped shadowed reader must belong exactly once")
    if grouped_shadowed_members != (
            raw_shadowed_reader_ids & grouped_shadowed_members):
        errors.append(
            "SHADOWED_READER: shadow group membership/status mismatch")
    if len(shadowed_group_debt_ids) != len(set(shadowed_group_debt_ids)):
        errors.append("SHADOWED_READER: duplicate group debt owner")
    if sorted(by_code.get("SHADOWED_READER", {}).get("debt_ids", [])) != shadowed_reader_ids:
        errors.append(
            "SHADOWED_READER: debt IDs do not equal source-shadowed active "
            "gates and shadowed reader/group owners")
    def row_has_owned_causal_reader(
            row: dict[str, Any], fact_id: str) -> bool:
        reader_refs = {
            reader_id
            for field in (
                row.get("near_reader_ids", []),
                row.get("milestone_reader_ids", []),
                row.get("missed_contract", {}).get("reader_ids", []),
            )
            if isinstance(field, list)
            for reader_id in field if isinstance(reader_id, str)}
        build_family = row.get("build_family")
        return any(
            reader_records_by_id.get(reader_id, {}).get("status") == "active"
            and reader_records_by_id.get(reader_id, {}).get("reader_kind")
                in CAUSAL_READER_KINDS
            and fact_id in bound_facts_by_reader.get(reader_id, set())
            and build_family in reader_records_by_id.get(
                reader_id, {}).get("input_build_family_ids", [])
            for reader_id in reader_refs)

    orphan_fact_ids = sorted({
        fact for row in rows if isinstance(row, dict)
        for fact in row.get("build_facts", [])
        if isinstance(fact, str)
        and (fact.startswith("fact:") or fact.startswith("receipt:action:"))
        and not row_has_owned_causal_reader(row, fact)
    })
    if sorted(by_code.get("ORPHAN_FACT", {}).get("debt_ids", [])) != orphan_fact_ids:
        errors.append("ORPHAN_FACT: debt IDs do not equal named build facts without readers")
    if (not self_test_probe
            and sorted(by_code.get("MILESTONE_FANIN", {}).get(
                "debt_ids", [])) != sorted(fanin_ids)):
        errors.append(
            "MILESTONE_FANIN: debt IDs do not equal over-cap or unnamed "
            f"story milestone inputs actual={sorted(fanin_ids)}")
    if sorted(by_code.get("COUNTERFACTUAL_NOOP", {}).get(
            "debt_ids", [])) != counterfactual_noop_ids:
        errors.append(
            "COUNTERFACTUAL_NOOP: debt IDs do not equal identical realized branch pairs")
    route_no_divergence = by_code.get("ROUTE_NO_DIVERGENCE", {})
    if (route_no_divergence.get("status") == "evaluated"
            and sorted(route_no_divergence.get("debt_ids", []))
            != route_no_divergence_ids):
        errors.append(
            "ROUTE_NO_DIVERGENCE: debt IDs do not equal non-divergent weekly route pairs/replays")
    route_hard_lock = by_code.get("ROUTE_HARD_LOCK", {})
    if (route_hard_lock.get("status") == "evaluated"
            and sorted(route_hard_lock.get("debt_ids", []))
            != route_hard_lock_ids):
        errors.append(
            "ROUTE_HARD_LOCK: debt IDs do not equal counters with fewer than two playable alternatives")

    sns_is_scheduled = any(
        isinstance(row, dict)
        and "sns_pressure_night" in row.get(
            "availability", {}).get("trigger_bundle_ids", [])
        and "sns_pressure_night" in row.get(
            "availability", {}).get("trigger_windows_by_bundle", {})
        for row in rows)
    unscheduled_ids = [] if sns_is_scheduled else ["bundle:sns_pressure_night"]
    if sorted(by_code.get("UNSCHEDULED_CHAIN", {}).get(
            "debt_ids", [])) != unscheduled_ids:
        errors.append(
            "UNSCHEDULED_CHAIN: debt IDs do not equal ledger scheduling graph")

    def has_forgone_causal_edge() -> bool:
        forgone_fact = "runtime:seoul_cycle:forgone_ids"
        producer_edges: list[tuple[int, str]] = []
        for _index, milestone, _where in milestone_records:
            producer_week = int(milestone.get("week", -1))
            for invocation in milestone.get("invocations", []):
                if not isinstance(invocation, dict):
                    continue
                member_ids = [
                    *invocation.get("always_reader_ids", []),
                    *[item.get("reader_id")
                      for item in invocation.get("conditional_readers", [])
                      if isinstance(item, dict)],
                    *[variant.get("reader_id")
                      for group in invocation.get(
                          "exclusive_variant_groups", [])
                      if isinstance(group, dict)
                      for variant in group.get("variants", [])
                      if isinstance(variant, dict)],
                ]
                has_reader = any(
                    reader_records_by_id.get(str(reader_id), {}).get(
                        "status") == "active"
                    and reader_records_by_id.get(str(reader_id), {}).get(
                        "reader_kind") in ROUTE_CAUSAL_READER_KINDS
                    and forgone_fact in bound_facts_by_reader.get(
                        str(reader_id), set())
                    for reader_id in member_ids)
                if not has_reader:
                    continue
                for producer in invocation.get("conditional_producers", []):
                    if not isinstance(producer, dict):
                        continue
                    outputs = set(producer.get("produced_fact_ids", []))
                    if (forgone_fact in producer.get("activation_ids", [])
                            and any(output.startswith((
                                "state:future_availability:",
                                "next_verb:")) for output in outputs
                                if isinstance(output, str))):
                        producer_edges.extend(
                            (producer_week, output) for output in outputs
                            if isinstance(output, str)
                            and output.startswith((
                                "state:future_availability:",
                                "next_verb:")))
        for producer_week, output_fact in producer_edges:
            for _index, milestone, _where in milestone_records:
                if int(milestone.get("week", -1)) <= producer_week:
                    continue
                for invocation in milestone.get("invocations", []):
                    if not isinstance(invocation, dict):
                        continue
                    member_ids = [
                        *invocation.get("always_reader_ids", []),
                        *[item.get("reader_id")
                          for item in invocation.get(
                              "conditional_readers", [])
                          if isinstance(item, dict)],
                        *[variant.get("reader_id")
                          for group in invocation.get(
                              "exclusive_variant_groups", [])
                          if isinstance(group, dict)
                          for variant in group.get("variants", [])
                          if isinstance(variant, dict)],
                    ]
                    for reader_id in member_ids:
                        reader = reader_records_by_id.get(
                            str(reader_id), {})
                        if (reader.get("status") == "active"
                                and reader.get("reader_kind")
                                    in NEXT_VERB_READER_KINDS
                                and output_fact in bound_facts_by_reader.get(
                                    str(reader_id), set())
                                and any(
                                    reader_id in row.get(
                                        "near_reader_ids", [])
                                    or reader_id in row.get(
                                        "next_verb_by_terminal", {}).get(
                                            "completed", [])
                                    for row in rows
                                    if isinstance(row, dict))):
                            return True
        return False

    forgone_ids = ([] if has_forgone_causal_edge()
                   else ["runtime:seoul_cycle:forgone_ids"])
    if sorted(by_code.get("DISPLAY_ONLY_FORGONE", {}).get(
            "debt_ids", [])) != forgone_ids:
        errors.append(
            "DISPLAY_ONLY_FORGONE: debt IDs do not equal causal future edge")

    def has_single_owner_application_transfer() -> bool:
        application_fact = (
            "receipt:application:mirae_industrial_tech:submitted")
        owner_fact = (
            "state:application_writer:mirae_industrial_tech:core")
        owners: list[tuple[str, str, set[str]]] = []
        for _index, milestone, _where in milestone_records:
            for invocation in milestone.get("invocations", []):
                if not isinstance(invocation, dict):
                    continue
                pointer = str(invocation.get("runtime_pointer", ""))
                for producer in invocation.get("conditional_producers", []):
                    if not isinstance(producer, dict):
                        continue
                    outputs = set(producer.get("produced_fact_ids", []))
                    if application_fact in outputs:
                        owners.append((pointer, str(
                            producer.get("variant_id", "")), outputs))
        return (len(owners) == 1
                and owners[0][0].startswith(
                    "systems/DemoCoreLoopV2.gd::")
                and owner_fact in owners[0][2])

    collision_ids = ([] if has_single_owner_application_transfer() else
                     ["event:v2_opening_application_send:application_status"])
    if sorted(by_code.get("LAYER_COLLISION", {}).get(
            "debt_ids", [])) != collision_ids:
        errors.append(
            "LAYER_COLLISION: debt IDs do not equal application writer topology")

    if check_sources:
        try:
            demo_contract = _load_json(DEMO_CONTRACT_PATH)
            core_events = _load_json(CORE_EVENTS_PATH)
        except ValueError as exc:
            errors.append(str(exc))
            demo_contract, core_events = {}, []
        scheduled_cycle_text = json.dumps(
            demo_contract.get("seoul_cycle", {}), ensure_ascii=False, sort_keys=True)
        source_unscheduled = (
            "sns_pressure_night" in demo_contract.get("scene_bundles", {})
            and "sns_pressure_night" not in scheduled_cycle_text)
        if source_unscheduled != ("bundle:sns_pressure_night" in unscheduled_ids):
            errors.append(
                "UNSCHEDULED_CHAIN: ledger schedule disagrees with source schedule")

        opening_event = next((event for event in core_events
                              if isinstance(event, dict)
                              and event.get("id") == "v2_opening_application_send"), {})
        opening_flags = {
            flag for choice in opening_event.get("choices", [])
            if isinstance(choice, dict)
            for flag in choice.get("flags", []) if isinstance(flag, str)
        }
        preplan = (demo_contract.get("scene_bundles", {})
                   .get("opening_interview_math", {}).get("preplan_trigger", {}))
        source_collision = (
            preplan.get("event_id") == "v2_opening_application_send"
                and preplan.get("application_id") and preplan.get("status")
                and opening_flags.intersection({
                    "opening_interview_application_sent",
                    "opening_preplan_application_sent",
                }))
        if bool(source_collision) != bool(collision_ids):
            errors.append(
                "LAYER_COLLISION: ledger application ownership disagrees with source")

        try:
            game_state_text = GAME_STATE_PATH.read_text(encoding="utf-8")
            demo_runtime_text = DEMO_RUNTIME_PATH.read_text(encoding="utf-8")
        except OSError as exc:
            errors.append(f"cannot read forgone source contract: {exc}")
            game_state_text, demo_runtime_text = "", ""
        payload_body = _gdscript_function_body(
            demo_runtime_text, "_seoul_cycle_commitment_payload")
        finalize_body = _gdscript_function_body(
            game_state_text, "finalize_seoul_cycle_weekly_commitment")
        forgone_is_display_only = (
            '"forgone_ids"' in payload_body
            and '"forgone_ids"' in finalize_body
            and not any(marker in finalize_body for marker in (
                "_register_forgone_path_debts", "_consume_forgone_path_return")))
        if forgone_is_display_only != bool(forgone_ids):
            errors.append(
                "DISPLAY_ONLY_FORGONE: ledger causal edge disagrees with source")

    metrics["debts"] = current_debts
    metrics["blocked"] = blocked_count
    if normalized_baseline != current_debts:
        added = sorted(set(current_debts) - set(normalized_baseline))
        stale = sorted(set(normalized_baseline) - set(current_debts))
        changed = sorted(code for code in set(current_debts) & set(normalized_baseline)
                         if current_debts[code] != normalized_baseline[code])
        errors.append(f"baseline exact mismatch new={added} stale={stale} changed={changed}")

    if check_pointers:
        _walk_pointers(obj, "ledger", errors, {})
        for index, row in enumerate(rows):
            if not isinstance(row, dict):
                continue
            pointer = row.get("runtime_pointer", "")
            expected_fragment = (
                f"#/seoul_cycle/months/{row.get('month')}/nodes/{row.get('node_id')}")
            if expected_fragment not in pointer:
                errors.append(
                    f"rows[{index}].runtime_pointer: does not identify its month/node slot")

    if require_complete:
        if len(implemented_slots) != 48 or missing_slots:
            errors.append("complete gate: requires authoritative rows=48 and gap=0")
        if gap_rows:
            errors.append("complete gate: coverage_gaps must be empty")
        if blocked_count:
            errors.append("complete gate: blocked evaluations must be zero")
        if current_debts or normalized_baseline:
            errors.append("complete gate: current debt and baseline must both be {}")
        if any(item.get("status") != "audited_runtime"
               for item in obj.get("milestone_registry", [])
               if isinstance(item, dict)):
            errors.append("complete gate: all 12 milestones need audited_runtime proof")
        if any(not item.get("reader_ids") or not item.get("runtime_pointer")
               or not item.get("runtime_proof_ids") or not item.get("invocations")
               or not item.get("co_presence_groups")
               or not item.get("execution_stages")
               for item in obj.get("milestone_registry", [])
               if isinstance(item, dict)):
            errors.append(
                "complete gate: every milestone needs named readers, invocations, co-presence, pointer, and proof")
        if any(
                item.get("status") in {
                    "blocked_by_coverage", "authored_blocked_by_coverage"}
                for item in obj.get("reader_registry", [])
                if isinstance(item, dict)):
            errors.append("complete gate: blocked readers must be zero")
        stale_prefix_proofs = {
            proof_id for proof_id in proofs
            if proof_id.startswith("proof:debt:")
            or proof_id in COMPLETE_STALE_PROOF_IDS
        }
        stale_assertion_proofs = {
            str(item.get("proof_id", ""))
            for item in obj.get("runtime_proof_registry", [])
            if isinstance(item, dict)
            and any(marker in str(item.get("assertion", "")).lower()
                    for marker in (
                        "coverage gap", "coverage-gap", "coverage blocked",
                        "coverage-blocked", "not implemented",
                        "debt evidence"))}
        if stale_prefix_proofs or stale_assertion_proofs:
            errors.append(
                "complete gate: current-prefix/debt evidence proofs must be removed")
        for row in rows:
            if not isinstance(row, dict):
                continue
            orphan_eligible_facts = {
                fact_id for fact_id in row.get("build_facts", [])
                if isinstance(fact_id, str)
                and (fact_id.startswith("fact:")
                     or fact_id.startswith("receipt:action:"))}
            covered_facts = {
                fact_id
                for reader_id in row.get("near_reader_ids", [])
                if reader_id in reader_records_by_id
                and reader_records_by_id[reader_id].get("status") == "active"
                and reader_records_by_id[reader_id].get("reader_kind")
                    in CAUSAL_READER_KINDS
                and row.get("build_family") in reader_records_by_id[
                    reader_id].get("input_build_family_ids", [])
                for fact_id in bound_facts_by_reader.get(reader_id, set())}
            if not orphan_eligible_facts.issubset(covered_facts):
                errors.append(
                    f"complete gate: row {row.get('chain_id')} lacks a source-bound causal near reader")
        for registry_name in ("replay_witnesses", "counterfactual_registry"):
            if any(item.get("status") != "audited_runtime"
                   for item in obj.get(registry_name, []) if isinstance(item, dict)):
                errors.append(f"complete gate: {registry_name} must be audited_runtime")
        valid_w48_witness = False
        w48_milestone = milestone_by_week.get(48, {})
        expected_w48_readers = set(w48_milestone.get("reader_ids", []))
        if not synthetic_source_contracts:
            chapter_end_reader = reader_records_by_id.get(
                "reader:chapter1_end_snapshot", {})
            if (chapter_end_reader.get("status") != "active"
                    or chapter_end_reader.get("reader_kind")
                    != "story_milestone"
                    or chapter_end_reader.get("layer_owner") != "story"
                    or not chapter_end_reader.get("runtime_pointer")):
                errors.append(
                    "complete gate: chapter1_end_snapshot reader lacks W48 close source contract")
            _validate_w48_completion_source_contract(
                w48_milestone, chapter_end_reader,
                proof_records_by_id, errors, mirror_cache)
        for witness in obj.get("replay_witnesses", []):
            if not isinstance(witness, dict) or witness.get("checkpoint_week") != 48:
                continue
            route_ids = witness.get("route_ids", [])
            reader_ids = witness.get("reader_ids", [])
            axes = witness.get("distinguishing_axes", [])
            proof_ids = witness.get("runtime_proof_ids", [])
            route_counter_ids = {
                branch_owner[route_id] for route_id in route_ids
                if route_id in branch_owner
            } if isinstance(route_ids, list) else set()
            chosen_counter = counter_records_by_id.get(
                next(iter(route_counter_ids)), {}) \
                if len(route_counter_ids) == 1 else {}
            chosen_row = row_by_chain.get(chosen_counter.get("chain_id"), {})
            routes_bound = (
                isinstance(route_ids, list) and len(set(route_ids)) >= 2
                and len(route_counter_ids) == 1
                and set(route_ids).issubset(
                    set(chosen_counter.get("branch_ids", [])))
                and chosen_row.get("month") == 12)
            proof_is_w48_specific = (
                isinstance(proof_ids, list)
                and "proof:milestone:w48" in proof_ids
                and "proof:milestone:w48" in proof_records_by_id)
            readers_bound = (
                isinstance(reader_ids, list) and set(reader_ids)
                == expected_w48_readers and bool(reader_ids)
                and any(reader_records_by_id.get(reader_id, {}).get(
                            "reader_kind") == "story_milestone"
                        and reader_records_by_id.get(reader_id, {}).get(
                            "status") == "active"
                        and reader_records_by_id.get(reader_id, {}).get(
                            "runtime_pointer")
                        and (bound_facts_by_reader.get(reader_id)
                             or reader_records_by_id.get(reader_id, {}).get(
                                 "story_decision_ids"))
                        for reader_id in reader_ids))
            w48_reader_facts = {
                fact_id for reader_id in reader_ids
                for fact_id in bound_facts_by_reader.get(reader_id, set())
                if (reader_records_by_id.get(reader_id, {}).get(
                        "reader_kind") == "story_milestone"
                    and reader_records_by_id.get(reader_id, {}).get(
                        "status") == "active")
            } if isinstance(reader_ids, list) else set()
            branch_contract_by_id = {
                contract.get("branch_id"): contract
                for contract in chosen_counter.get("branch_contracts", [])
                if isinstance(contract, dict)
                and isinstance(contract.get("branch_id"), str)
            }
            selected_branch_contracts = [
                branch_contract_by_id.get(route_id, {})
                for route_id in route_ids] \
                if isinstance(route_ids, list) else []
            branch_fact_intersections = [
                w48_reader_facts.intersection(
                    set(contract.get("produced_fact_ids", [])))
                for contract in selected_branch_contracts]
            route_facts_bound = (
                len(selected_branch_contracts) == len(route_ids)
                and len(branch_fact_intersections) == len(route_ids)
                and all(branch_fact_intersections)
                and len(set().union(*branch_fact_intersections)) >= 2
            ) if isinstance(route_ids, list) and route_ids else False
            w48_weekly_signature_sets = [
                _branch_causal_signatures(
                    chosen_row, contract, w48_reader_facts, mirror_cache,
                    include_nested_outputs=False)
                for contract in selected_branch_contracts]
            weekly_routes_diverge = all(
                not (w48_weekly_signature_sets[left]
                     & w48_weekly_signature_sets[right])
                for left in range(len(w48_weekly_signature_sets))
                for right in range(left + 1,
                                   len(w48_weekly_signature_sets)))
            axes_bound = (
                isinstance(axes, list) and bool(axes)
                and set(axes).issubset(set(chosen_counter.get(
                    "distinguishing_axes", []))))
            w48_proof = proof_records_by_id.get("proof:milestone:w48", {})
            proof_pointer_bound = (
                w48_proof.get("pointer") == w48_milestone.get("runtime_pointer"))
            if (routes_bound and readers_bound and route_facts_bound
                    and weekly_routes_diverge
                    and axes_bound
                    and isinstance(proof_ids, list) and proof_ids
                    and proof_is_w48_specific and proof_pointer_bound):
                valid_w48_witness = True
                break
        if not valid_w48_witness:
            errors.append(
                "complete gate: W48 replay needs two declared counterfactual routes, readers, axes, and W48 proof")
        if (not synthetic_source_contracts
                and any("gap" in str(item.get("proof_id", "")).lower()
               or "save_roundtrip_prefix" in str(item.get("proof_id", "")).lower()
               or "missing" in str(item.get("assertion", "")).lower()
               or "not implemented" in str(item.get("assertion", "")).lower()
               or "coverage-blocked" in str(item.get("assertion", "")).lower()
               or "coverage blocked" in str(item.get("assertion", "")).lower()
               for item in obj.get("runtime_proof_registry", [])
               if isinstance(item, dict))):
            errors.append("complete gate: runtime proof registry still describes coverage debt")
    return errors, metrics


def _load_json(path: Path) -> Any:
    try:
        payload = path.read_text(encoding="utf-8")
    except FileNotFoundError as exc:
        raise ValueError(f"missing required file: {path.relative_to(ROOT)}") from exc
    return _parse_exact_json(payload, str(path.relative_to(ROOT)))


def _self_test_validate(
        ledger: Any, baseline: Any, *, probe: bool,
        fallback: bool = False, complete: bool = False,
        pointers: bool = False, sources: bool = True,
        synthetic: bool = False, snapshot: bool = False,
        source_census: bool = False,
) -> tuple[list[str], dict[str, Any]]:
    """Run one fail-closed self-test validation and record its cost.

    Production validation never calls this helper.  The probe may omit
    expensive validations, but a clean probe or a probe that misses the
    requested diagnostic always falls back to the full 210-scenario path.
    """
    global _SELF_TEST_PROBE_COUNT
    global _SELF_TEST_FULL_COUNT
    global _SELF_TEST_FULL_FALLBACK_COUNT
    global _SELF_TEST_PROBE_SECONDS
    global _SELF_TEST_FULL_SECONDS

    started = time.monotonic()
    errors, metrics = validate(
        ledger, baseline, require_complete=complete,
        check_pointers=pointers, check_sources=sources,
        synthetic_source_contracts=synthetic,
        enforce_audited_snapshot=snapshot,
        self_test_probe=probe,
        # Ledger mutation cases test their named invariant against the same
        # immutable source scenario graph already derived once at self-test
        # entry.  Only explicit source-census mutations request a fresh run.
        # Production/default validate never uses this Python-only switch.
        self_test_skip_w24_source_census=not source_census)
    elapsed = time.monotonic() - started
    if probe:
        _SELF_TEST_PROBE_COUNT += 1
        _SELF_TEST_PROBE_SECONDS += elapsed
        if elapsed > SELF_TEST_PROBE_TIMEOUT_SECONDS:
            raise AssertionError(
                "self-test probe exceeded fail-closed timeout "
                f"({elapsed:.2f}s > {SELF_TEST_PROBE_TIMEOUT_SECONDS:.0f}s)")
    else:
        _SELF_TEST_FULL_COUNT += 1
        _SELF_TEST_FULL_SECONDS += elapsed
        if fallback:
            _SELF_TEST_FULL_FALLBACK_COUNT += 1
        if elapsed > SELF_TEST_FULL_TIMEOUT_SECONDS:
            raise AssertionError(
                "self-test full validation exceeded fail-closed timeout "
                f"({elapsed:.2f}s > {SELF_TEST_FULL_TIMEOUT_SECONDS:.0f}s)")
    return errors, metrics


def _expect_failure(name: str, ledger: Any, baseline: Any, needle: str,
                    *, complete: bool = False, pointers: bool = False,
                    sources: bool = True, synthetic: bool = False,
                    snapshot: bool = False,
                    source_census: bool = False) -> None:
    errors, _ = _self_test_validate(
        ledger, baseline, probe=True, complete=complete,
        pointers=pointers, sources=sources, synthetic=synthetic,
        snapshot=snapshot, source_census=source_census)
    if any(needle in error for error in errors):
        return
    errors, _ = _self_test_validate(
        ledger, baseline, probe=False, fallback=True, complete=complete,
        pointers=pointers, sources=sources, synthetic=synthetic,
        snapshot=snapshot, source_census=source_census)
    if not errors or not any(needle in error for error in errors):
        raise AssertionError(f"{name}: expected {needle!r}, got {errors}")


def _expect_probe_full_parity(
        name: str, ledger: Any, baseline: Any, needle: str,
        *, complete: bool = False, pointers: bool = False,
        sources: bool = False, synthetic: bool = False,
        snapshot: bool = False, source_census: bool = False) -> None:
    """Prove that a representative probe diagnostic is contained in full."""
    probe_errors, _ = _self_test_validate(
        ledger, baseline, probe=True, complete=complete,
        pointers=pointers, sources=sources, synthetic=synthetic,
        snapshot=snapshot, source_census=source_census)
    full_errors, _ = _self_test_validate(
        ledger, baseline, probe=False, complete=complete,
        pointers=pointers, sources=sources, synthetic=synthetic,
        snapshot=snapshot, source_census=source_census)
    if not any(needle in error for error in probe_errors):
        raise AssertionError(
            f"{name}: probe missed parity diagnostic {needle!r}: "
            f"{probe_errors}")
    if not any(needle in error for error in full_errors):
        raise AssertionError(
            f"{name}: full validation missed parity diagnostic "
            f"{needle!r}: {full_errors}")
    probe_only = sorted(set(probe_errors) - set(full_errors))
    if probe_only:
        raise AssertionError(
            f"{name}: probe produced diagnostics absent from full: "
            f"{probe_only}")


def _expect_probe_clean_full_fallback(
        name: str, ledger: Any, baseline: Any, needle: str, *,
        complete: bool = False, pointers: bool = False,
        sources: bool = False, synthetic: bool = False,
        snapshot: bool = False, source_census: bool = False) -> None:
    """Prove an intentionally clean probe falls back to exact full failure."""
    fallback_count_before = _SELF_TEST_FULL_FALLBACK_COUNT
    probe_errors, _ = _self_test_validate(
        ledger, baseline, probe=True, complete=complete,
        pointers=pointers, sources=sources, synthetic=synthetic,
        snapshot=snapshot, source_census=source_census)
    if probe_errors:
        raise AssertionError(
            f"{name}: fallback probe must be clean, got {probe_errors}")
    full_errors, _ = _self_test_validate(
        ledger, baseline, probe=False, fallback=True, complete=complete,
        pointers=pointers, sources=sources, synthetic=synthetic,
        snapshot=snapshot, source_census=source_census)
    if not any(needle in error for error in full_errors):
        raise AssertionError(
            f"{name}: mandatory full fallback missed {needle!r}: "
            f"{full_errors}")
    if _SELF_TEST_FULL_FALLBACK_COUNT != fallback_count_before + 1:
        raise AssertionError(
            f"{name}: mandatory full fallback counter did not advance "
            "exactly once")


def _derive_synthetic_w24_production_evidence(
        ledger: dict[str, Any]) -> dict[str, Any]:
    """Re-derive immutable W24 replacement evidence before fixture edits.

    This function deliberately starts from the frozen production ledger and
    runs the ordinary scenario/reader/producer/handoff engine.  The returned
    evidence is never accepted from a caller or ledger field.  In particular,
    deleting a source scenario changes this census even if a coordinated
    synthetic manifest repeats the old literal counts.
    """
    if _semantic_digest(ledger) != AUDITED_LEDGER_SEMANTIC_SHA256:
        raise AssertionError(
            "synthetic W24 evidence requires exact audited production ledger")
    production_baseline = _load_json(BASELINE_PATH)
    production_errors, production_metrics = validate(
        ledger, production_baseline, check_pointers=False,
        check_sources=False, enforce_audited_snapshot=False)
    if production_errors:
        raise AssertionError(
            "synthetic W24 production evidence failed ordinary validation: "
            f"{production_errors[:5]}")

    milestone = next(
        item for item in ledger.get("milestone_registry", [])
        if item.get("week") == 24)
    invocation_by_id = {
        item.get("invocation_id"): item
        for item in milestone.get("invocations", [])
        if isinstance(item, dict) and isinstance(
            item.get("invocation_id"), str)}
    story_group = next(
        group for group in milestone.get("co_presence_groups", [])
        if group.get("group_id") == "group:w24:story_scene")
    story_ids = set(story_group.get("invocation_ids", []))
    superseded = {
        invocation_id: copy.deepcopy(invocation_by_id[invocation_id])
        for invocation_id in sorted(
            SYNTHETIC_W24_FANIN_SUPERSEDED_INVOCATION_IDS)}
    retained_ids = story_ids - \
        SYNTHETIC_W24_FANIN_SUPERSEDED_INVOCATION_IDS
    retained = {
        invocation_id: copy.deepcopy(invocation_by_id[invocation_id])
        for invocation_id in sorted(retained_ids)}
    scenarios = EXPECTED_EXECUTION_STAGE_SCENARIOS_BY_WEEK[24]
    evidence = {
        "production_semantic_digest": _semantic_digest(ledger),
        "superseded_invocations": superseded,
        "superseded_records_digest": _semantic_digest(superseded),
        "retained_invocations": retained,
        "retained_records_digest": _semantic_digest(retained),
        "source_scenarios_digest": _semantic_digest(scenarios),
        "source_scenario_count": len(scenarios),
        "source_stage_tuple_map": production_metrics.get(
            "w24_source_tuple_stage_map"),
        "source_feasible_tuple_occurrence_count": production_metrics.get(
            "w24_source_feasible_tuple_occurrences"),
        "source_rejected_tuple_occurrence_count": production_metrics.get(
            "w24_source_rejected_tuple_occurrences"),
        "source_zero_option_paths": production_metrics.get(
            "w24_source_zero_option_paths"),
        "source_scenario_feasible_counts": production_metrics.get(
            "w24_source_scenario_feasible_counts"),
        "source_scenario_feasible_counts_digest": production_metrics.get(
            "w24_source_scenario_feasible_counts_digest"),
    }
    expected_values = {
        "production_semantic_digest": AUDITED_LEDGER_SEMANTIC_SHA256,
        "superseded_records_digest":
            SYNTHETIC_W24_SUPERSEDED_RECORDS_SHA256,
        "retained_records_digest": SYNTHETIC_W24_RETAINED_RECORDS_SHA256,
        "source_scenarios_digest": SYNTHETIC_W24_SOURCE_SCENARIOS_SHA256,
        "source_scenario_count": 201,
        "source_stage_tuple_map": SYNTHETIC_W24_SOURCE_TUPLE_STAGE_MAP,
        "source_feasible_tuple_occurrence_count": 51_977,
        "source_rejected_tuple_occurrence_count": 1_048,
        "source_zero_option_paths": 0,
        "source_scenario_feasible_counts_digest":
            SYNTHETIC_W24_SOURCE_SCENARIO_COUNTS_SHA256,
    }
    for key, expected in expected_values.items():
        if evidence.get(key) != expected:
            raise AssertionError(
                "synthetic W24 production evidence mismatch "
                f"{key}: {evidence.get(key)!r}")
    if (set(superseded)
            != SYNTHETIC_W24_FANIN_SUPERSEDED_INVOCATION_IDS
            or len(retained) != 19):
        raise AssertionError(
            "synthetic W24 production evidence exact27/remaining19 mismatch")
    scenario_counts = evidence.get("source_scenario_feasible_counts")
    if (not isinstance(scenario_counts, dict)
            or len(scenario_counts) != 1_456
            or sum(scenario_counts.values()) != 51_977):
        raise AssertionError(
            "synthetic W24 production per-scenario occurrence mismatch")
    return evidence


def _synthetic_w24_invocation_reader_ids(
        invocation: dict[str, Any]) -> list[str]:
    """Return one invocation's reader IDs in authored structural order."""
    axes = [
        invocation.get("always_reader_ids", []),
        [item.get("reader_id")
         for item in invocation.get("conditional_readers", [])
         if isinstance(item, dict)],
        [variant.get("reader_id")
         for group in invocation.get("exclusive_variant_groups", [])
         if isinstance(group, dict)
         for variant in group.get("variants", [])
         if isinstance(variant, dict)],
    ]
    return list(dict.fromkeys(
        reader_id for axis in axes for reader_id in axis
        if isinstance(reader_id, str)))


def _derive_synthetic_w24_row_reference_contract(
        production_ledger: dict[str, Any]) -> dict[str, Any]:
    """Derive exact production row/witness refs to their non-Story clones.

    The source ledger, rather than the later synthetic fixture or manifest,
    owns this mapping.  In particular, a two-axis Story summary is never a
    substitute for the exact raw reader that gives a build row causal
    ownership of its historical fact.
    """
    if _semantic_digest(production_ledger) != AUDITED_LEDGER_SEMANTIC_SHA256:
        raise AssertionError(
            "synthetic W24 row-reference contract requires audited ledger")
    milestone = next(
        item for item in production_ledger["milestone_registry"]
        if item["week"] == 24)
    invocations = {
        item["invocation_id"]: item for item in milestone["invocations"]}
    stage_by_invocation = {
        invocation_id: stage["stage_id"]
        for stage in milestone["execution_stages"]
        for invocation_id in stage["invocation_ids"]}
    production_readers = {
        reader["reader_id"]: reader
        for reader in production_ledger["reader_registry"]}
    source_to_clones: dict[str, set[str]] = {}
    clone_to_stage: dict[str, str] = {}
    for invocation_id in sorted(
            SYNTHETIC_W24_FANIN_SUPERSEDED_INVOCATION_IDS):
        stage_id = stage_by_invocation[invocation_id]
        stage_slug = re.sub(
            r"[^A-Za-z0-9_]+", "_", stage_id).strip("_")
        for source_id in _synthetic_w24_invocation_reader_ids(
                invocations[invocation_id]):
            if source_id not in production_readers:
                continue
            clone_id = (
                f"reader:synthetic:w24:fanin_raw:{stage_slug}:source:"
                f"{source_id}")
            source_to_clones.setdefault(source_id, set()).add(clone_id)
            clone_to_stage[clone_id] = stage_id

    entries: list[dict[str, Any]] = []
    owner_expectations: dict[tuple[str, str, str], list[str]] = {}
    causal_count = 0
    feasibility_count = 0

    def translate_owner(
            owner_kind: str, owner_id: str, field_name: str,
            source_ids: Any) -> None:
        nonlocal causal_count, feasibility_count
        if not isinstance(source_ids, list):
            return
        translated: list[str] = []
        replaced = False
        for source_index, source_id in enumerate(source_ids):
            clone_ids = sorted(source_to_clones.get(source_id, set()))
            if not clone_ids:
                translated.append(source_id)
                continue
            replaced = True
            source_reader = production_readers[source_id]
            classification = (
                "causal_history_or_decision"
                if (source_reader.get("history_memory_ids")
                    or source_reader.get("story_decision_ids")
                    or source_reader.get("scene_handoff_decision_ids"))
                else "material_handoff_feasibility")
            if owner_kind == "row":
                if classification == "causal_history_or_decision":
                    causal_count += len(clone_ids)
                else:
                    feasibility_count += len(clone_ids)
            for clone_id in clone_ids:
                entries.append({
                    "owner_kind": owner_kind,
                    "owner_id": owner_id,
                    "field_name": field_name,
                    "source_index": source_index,
                    "source_reader_id": source_id,
                    "clone_reader_id": clone_id,
                    "source_stage_id": clone_to_stage[clone_id],
                    "classification": classification,
                    "source_contract_digest": _semantic_digest(
                        source_reader),
                })
            translated.extend(clone_ids)
        if replaced:
            owner_expectations[(owner_kind, owner_id, field_name)] = list(
                    dict.fromkeys(translated))

    for row in production_ledger["rows"]:
        for field_name in ("near_reader_ids", "milestone_reader_ids"):
            translate_owner(
                "row", row["chain_id"], field_name, row.get(field_name))
        missed = row.get("missed_contract", {})
        translate_owner(
            "row", row["chain_id"], "missed_contract.reader_ids",
            missed.get("reader_ids") if isinstance(missed, dict) else None)
    for witness in production_ledger.get("replay_witnesses", []):
        translate_owner(
            "replay_witness", witness["witness_id"], "reader_ids",
            witness.get("reader_ids"))

    result = {
        "entries": entries,
        "owner_expectations": [
            {
                "owner_kind": owner_kind,
                "owner_id": owner_id,
                "field_name": field_name,
                "reader_ids": reader_ids,
            }
            for (owner_kind, owner_id, field_name), reader_ids
            in sorted(owner_expectations.items())],
        "row_causal_reference_count": causal_count,
        "row_feasibility_reference_count": feasibility_count,
        "replay_reference_count": sum(
            1 for entry in entries
            if entry["owner_kind"] == "replay_witness"),
    }
    if (causal_count != 53 or feasibility_count != 6
            or result["replay_reference_count"] != 3):
        raise AssertionError(
            "synthetic W24 production row-reference census mismatch "
            f"causal={causal_count} feasibility={feasibility_count} "
            f"replay={result['replay_reference_count']}")
    return result


def _synthetic_w24_prefix_reference_surface(
        production_ledger: dict[str, Any],
        fixture: dict[str, Any]) -> dict[str, Any]:
    """Project every frozen-prefix row and replay reader-reference list."""
    chain_ids = {
        row["chain_id"] for row in production_ledger.get("rows", [])
        if isinstance(row, dict) and isinstance(row.get("chain_id"), str)}
    witness_ids = {
        witness["witness_id"]
        for witness in production_ledger.get("replay_witnesses", [])
        if isinstance(witness, dict)
        and isinstance(witness.get("witness_id"), str)}
    return {
        "rows": {
            row["chain_id"]: {
                "near_reader_ids": copy.deepcopy(
                    row.get("near_reader_ids")),
                "milestone_reader_ids": copy.deepcopy(
                    row.get("milestone_reader_ids")),
                "missed_reader_ids": copy.deepcopy(
                    row.get("missed_contract", {}).get("reader_ids")),
            }
            for row in fixture.get("rows", [])
            if isinstance(row, dict) and row.get("chain_id") in chain_ids},
        "replay_witnesses": {
            witness["witness_id"]: copy.deepcopy(witness.get("reader_ids"))
            for witness in fixture.get("replay_witnesses", [])
            if isinstance(witness, dict)
            and witness.get("witness_id") in witness_ids},
    }


_SYNTHETIC_W24_ENTRY_MODES = frozenset({"fresh", "reentry", "cold"})


def _synthetic_w24_value_entry_modes(*value_ids: str) -> frozenset[str]:
    """Return the exact source entry modes encoded by option tokens."""
    constrained: set[str] = set(_SYNTHETIC_W24_ENTRY_MODES)
    saw_constraint = False
    for value_id in value_ids:
        segments = str(value_id).split(":")
        if any(segment == "loaded" or segment.startswith("loaded_")
               for segment in segments):
            modes = {"cold"}
        elif "reentry" in segments:
            modes = {"reentry"}
        elif "fresh" in segments:
            modes = {"fresh"}
        elif "live" in segments:
            modes = {"fresh", "reentry"}
        else:
            continue
        constrained &= modes
        saw_constraint = True
    return frozenset(
        constrained if saw_constraint else _SYNTHETIC_W24_ENTRY_MODES)


def _synthetic_w24_exact_raw_options(
        record: dict[str, Any],
        readers_index: dict[str, dict[str, Any]],
) -> list[dict[str, Any]]:
    """Enumerate canonical source-compatible raw options for one invocation."""
    fixed_reader_ids = list(record["always_reader_ids"])
    reader_axes: list[
        list[tuple[list[str], list[str], frozenset[str]]]] = []
    for conditional in record["conditional_readers"]:
        reader_id = conditional["reader_id"]
        activations = list(conditional["activation_fact_ids"])
        reader_axes.append([
            ([], [], _SYNTHETIC_W24_ENTRY_MODES),
            ([reader_id], activations,
             _synthetic_w24_value_entry_modes(reader_id, *activations)),
        ])
    for group in record["exclusive_variant_groups"]:
        choices = []
        for variant in group["variants"]:
            reader_id = variant["reader_id"]
            activations = list(variant["activation_fact_ids"])
            choices.append((
                [reader_id], activations,
                _synthetic_w24_value_entry_modes(reader_id, *activations)))
        if group["selection_mode"] == "at_most_one":
            choices.append(([], [], _SYNTHETIC_W24_ENTRY_MODES))
        reader_axes.append(choices)

    producer_groups = {
        group["selection_group_id"]: group
        for group in record["producer_variant_groups"]}
    producer_variants: dict[str, list[dict[str, Any]]] = {}
    for producer in record["conditional_producers"]:
        producer_variants.setdefault(
            producer["selection_group_id"], []).append(producer)
    producer_selections = _compatible_producer_selections(
        producer_groups, producer_variants)
    internal_outputs = {
        fact_id for producer in record["conditional_producers"]
        for fact_id in producer["produced_fact_ids"]}
    selectable_reader_ids = {
        *[item["reader_id"] for item in record["conditional_readers"]],
        *[variant["reader_id"]
          for group in record["exclusive_variant_groups"]
          for variant in group["variants"]],
    }
    coupled_reader_ids = {
        reader_id for reader_id in selectable_reader_ids
        if readers_index[reader_id].get("reads_fact_ids")
        and any(
            set(readers_index[reader_id]["reads_fact_ids"]).issubset(
                set(producer["activation_ids"]))
            for producer in record["conditional_producers"])}
    reader_selections = itertools.product(*reader_axes) \
        if reader_axes else [()]
    canonical_options: dict[tuple[Any, ...], dict[str, Any]] = {}
    for reader_selection in reader_selections:
        selected_reader_ids = list(fixed_reader_ids)
        selected_reader_activations: list[str] = []
        reader_modes = _synthetic_w24_value_entry_modes(
            str(record.get("invocation_id", "")), *fixed_reader_ids)
        for reader_ids, activations, option_modes in reader_selection:
            selected_reader_ids.extend(reader_ids)
            selected_reader_activations.extend(activations)
            reader_modes = frozenset(set(reader_modes) & set(option_modes))
        if not reader_modes:
            continue
        for producer_selection in producer_selections:
            if producer_selection and coupled_reader_ids:
                producer_activations = {
                    activation_id for producer in producer_selection
                    for activation_id in producer["activation_ids"]}
                expected_coupled_readers = {
                    reader_id for reader_id in coupled_reader_ids
                    if set(readers_index[reader_id][
                        "reads_fact_ids"]).issubset(producer_activations)}
                if (set(selected_reader_ids) & coupled_reader_ids
                        != expected_coupled_readers):
                    continue
            roles = {role: set() for role in ACTIVATION_ROLE_FIELDS}
            option_modes = set(reader_modes)
            choice_values: dict[str, str] = {}
            compatible = True
            choice_tokens = list(selected_reader_activations)
            for reader_id in selected_reader_ids:
                reader = readers_index[reader_id]
                for role in ACTIVATION_ROLE_FIELDS:
                    roles[role].update(
                        value for value in reader.get(role, [])
                        if isinstance(value, str))
                choice_tokens.extend(reader.get("story_decision_ids", []))
                choice_tokens.extend(
                    reader.get("scene_handoff_decision_ids", []))
            original_outputs: set[str] = set()
            original_effects: set[str] = set()
            producer_variant_ids: list[str] = []
            for producer in producer_selection:
                producer_variant_ids.append(producer["variant_id"])
                option_modes &= set(_synthetic_w24_value_entry_modes(
                    producer["variant_id"], *producer["activation_ids"]))
                activation_roles = producer["activation_roles"]
                for role in ACTIVATION_ROLE_FIELDS:
                    roles[role].update(
                        value for value in activation_roles[role]
                        if isinstance(value, str)
                        and value not in internal_outputs)
                choice_tokens.extend(producer["activation_ids"])
                original_outputs.update(producer["produced_fact_ids"])
                original_effects.update(producer["effect_contract_ids"])
            if not option_modes:
                continue
            for token in choice_tokens:
                domain_value = _activation_choice_domain(str(token))
                if domain_value is None:
                    continue
                domain, value = domain_value
                previous = choice_values.setdefault(domain, value)
                if previous != value:
                    compatible = False
                    break
            if not compatible:
                continue
            key = (
                *(tuple(sorted(roles[role]))
                  for role in sorted(ACTIVATION_ROLE_FIELDS)),
                tuple(sorted(option_modes)),
                tuple(sorted(original_outputs)),
                tuple(sorted(original_effects)),
            )
            canonical_options.setdefault(key, {
                "activation_roles": {
                    role: sorted(roles[role])
                    for role in ACTIVATION_ROLE_FIELDS},
                "entry_modes": sorted(option_modes),
                "original_output_ids": sorted(original_outputs),
                "original_effect_ids": sorted(original_effects),
                "reader_ids": sorted(set(selected_reader_ids)),
                "producer_variant_ids": sorted(producer_variant_ids),
            })
    return list(canonical_options.values())


def _synthetic_w24_combine_stage_raw_options(
        records: list[dict[str, Any]],
        readers_index: dict[str, dict[str, Any]],
) -> list[dict[str, Any]]:
    """Cartesian-combine every co-present invocation at one physical cut."""
    option_axes = [
        _synthetic_w24_exact_raw_options(record, readers_index)
        for record in records]
    if any(not axis for axis in option_axes):
        return []
    combined: dict[str, dict[str, Any]] = {}
    for selected in itertools.product(*option_axes):
        option = _synthetic_w24_merge_raw_options(selected)
        if option is None:
            continue
        combined.setdefault(_semantic_digest(option), option)
    return [combined[key] for key in sorted(combined)]


def _synthetic_w24_merge_raw_options(
        selected: tuple[dict[str, Any], ...] | list[dict[str, Any]],
) -> dict[str, Any] | None:
    """Merge one concrete same-stage product, rejecting choice conflicts."""
    entry_modes = set(_SYNTHETIC_W24_ENTRY_MODES)
    roles = {role: set() for role in ACTIVATION_ROLE_FIELDS}
    original_outputs: set[str] = set()
    original_effects: set[str] = set()
    reader_ids: set[str] = set()
    producer_variant_ids: set[str] = set()
    choice_values: dict[str, str] = {}
    for option in selected:
        entry_modes &= set(option["entry_modes"])
        for role in ACTIVATION_ROLE_FIELDS:
            roles[role].update(option["activation_roles"][role])
        original_outputs.update(option["original_output_ids"])
        original_effects.update(option["original_effect_ids"])
        reader_ids.update(option["reader_ids"])
        producer_variant_ids.update(option["producer_variant_ids"])
    if not entry_modes:
        return None
    for decision_id in (
            roles["story_decision_ids"]
            | roles["scene_handoff_decision_ids"]):
        domain_value = _activation_choice_domain(decision_id)
        if domain_value is None:
            continue
        domain, value = domain_value
        previous = choice_values.setdefault(domain, value)
        if previous != value:
            return None
    return {
        "activation_roles": {
            role: sorted(roles[role]) for role in ACTIVATION_ROLE_FIELDS},
        "entry_modes": sorted(entry_modes),
        "original_output_ids": sorted(original_outputs),
        "original_effect_ids": sorted(original_effects),
        "reader_ids": sorted(reader_ids),
        "producer_variant_ids": sorted(producer_variant_ids),
    }


def _synthetic_w24_option_projection(option: dict[str, Any]) -> dict[str, Any]:
    return {
        "activation_roles": option["activation_roles"],
        "entry_modes": option["entry_modes"],
        "original_output_ids": option["original_output_ids"],
        "original_effect_ids": option["original_effect_ids"],
    }


def _derive_synthetic_w24_stage_tuple_surface(
        production_ledger: dict[str, Any],
        fixture: dict[str, Any],
) -> tuple[dict[str, str], dict[str, str], int]:
    """Independently derive production A and current replacement B tuples."""
    production_w24 = next(
        item for item in production_ledger.get("milestone_registry", [])
        if item.get("week") == 24)
    fixture_w24 = next(
        item for item in fixture.get("milestone_registry", [])
        if item.get("week") == 24)
    production_readers = {
        item["reader_id"]: item
        for item in production_ledger.get("reader_registry", [])
        if isinstance(item, dict) and isinstance(item.get("reader_id"), str)}
    fixture_readers = {
        item["reader_id"]: item
        for item in fixture.get("reader_registry", [])
        if isinstance(item, dict) and isinstance(item.get("reader_id"), str)}
    production_invocations = {
        item["invocation_id"]: item
        for item in production_w24.get("invocations", [])
        if isinstance(item, dict)
        and isinstance(item.get("invocation_id"), str)}
    fixture_invocations = {
        item["invocation_id"]: item
        for item in fixture_w24.get("invocations", [])
        if isinstance(item, dict)
        and isinstance(item.get("invocation_id"), str)}
    production_stages = {
        item["stage_id"]: item
        for item in production_w24.get("execution_stages", [])
        if isinstance(item, dict) and isinstance(item.get("stage_id"), str)}
    fixture_stages = {
        item["stage_id"]: item
        for item in fixture_w24.get("execution_stages", [])
        if isinstance(item, dict) and isinstance(item.get("stage_id"), str)}

    production_digests: dict[str, str] = {}
    replacement_digests: dict[str, str] = {}
    replacement_tuple_count = 0
    for original_stage_id in sorted(SYNTHETIC_W24_STAGE_TUPLE_DIGESTS):
        production_stage = production_stages.get(original_stage_id, {})
        production_records = [
            production_invocations[invocation_id]
            for invocation_id in production_stage.get("invocation_ids", [])
            if invocation_id
            in SYNTHETIC_W24_FANIN_SUPERSEDED_INVOCATION_IDS
            and invocation_id in production_invocations]
        if not production_records:
            production_digests[original_stage_id] = "missing"
        else:
            production_options = _synthetic_w24_combine_stage_raw_options(
                production_records, production_readers)
            production_tuple_set = sorted({
                _semantic_digest(_synthetic_w24_option_projection(option))
                for option in production_options})
            production_digests[original_stage_id] = _semantic_digest(
                production_tuple_set)

        aggregate_stage_id = (
            f"w24:synthetic_fanin_aggregate:{original_stage_id}")
        aggregate_stage = fixture_stages.get(aggregate_stage_id, {})
        aggregate_records = [
            copy.deepcopy(fixture_invocations[invocation_id])
            for invocation_id in aggregate_stage.get("invocation_ids", [])
            if invocation_id.startswith(
                "reader:synthetic:w24:fanin_aggregate:")
            and invocation_id in fixture_invocations]
        if len(aggregate_records) != 1:
            replacement_digests[original_stage_id] = "missing"
            continue
        aggregate = aggregate_records[0]
        # The flattened aggregate replaces every source invocation at this
        # physical cut.  Give option-mode inference the original semantic
        # stage ID, and remove only the later resolver handoff producer.
        aggregate["invocation_id"] = original_stage_id
        aggregate["conditional_producers"] = [
            producer for producer in aggregate.get(
                "conditional_producers", [])
            if not str(producer.get("variant_id", "")).startswith(
                "variant:synthetic:w24:raw_options_resolved:")]
        live_group_ids = {
            producer.get("selection_group_id")
            for producer in aggregate["conditional_producers"]}
        aggregate["producer_variant_groups"] = [
            group for group in aggregate.get("producer_variant_groups", [])
            if group.get("selection_group_id") in live_group_ids]
        replacement_options = _synthetic_w24_combine_stage_raw_options(
            [aggregate], fixture_readers)
        replacement_tuple_set = sorted({
            _semantic_digest(_synthetic_w24_option_projection(option))
            for option in replacement_options})
        replacement_tuple_count += len(replacement_tuple_set)
        replacement_digests[original_stage_id] = _semantic_digest(
            replacement_tuple_set)
    return production_digests, replacement_digests, replacement_tuple_count


def _apply_synthetic_w24_fanin_replacement(
        fixture: dict[str, Any], reader_by_id: dict[str, dict[str, Any]],
        proof_by_id: dict[str, dict[str, Any]]) -> dict[str, Any]:
    """Replace the exact W24 over-cap input surface in complete-fixture only.

    The production records remain available as evidence in the frozen source
    object.  The synthetic execution graph removes exactly the reviewed 27
    invocation IDs, places their unchanged input/producer contracts in a
    strict-earlier non-Story aggregation stage, and exposes only two fixed
    history axes to the replacement Story call.  No per-scenario or per-choice
    summary vocabulary is permitted.
    """
    milestone = next(
        item for item in fixture["milestone_registry"] if item["week"] == 24)
    invocation_by_id = {
        item["invocation_id"]: item for item in milestone["invocations"]}
    missing = (SYNTHETIC_W24_FANIN_SUPERSEDED_INVOCATION_IDS
               - set(invocation_by_id))
    if missing:
        raise AssertionError(
            f"synthetic W24 FANIN manifest missing invocations {sorted(missing)}")
    story_group = next(
        group for group in milestone["co_presence_groups"]
        if group["group_id"] == "group:w24:story_scene")
    story_members = set(story_group["invocation_ids"])
    if (story_members & SYNTHETIC_W24_FANIN_SUPERSEDED_INVOCATION_IDS
            != SYNTHETIC_W24_FANIN_SUPERSEDED_INVOCATION_IDS
            or len(story_members
                   - SYNTHETIC_W24_FANIN_SUPERSEDED_INVOCATION_IDS) != 19):
        raise AssertionError(
            "synthetic W24 FANIN manifest must supersede exact 27 and retain 19")
    frozen_remaining_invocations = {
        invocation_id: copy.deepcopy(invocation_by_id[invocation_id])
        for invocation_id in sorted(
            story_members - SYNTHETIC_W24_FANIN_SUPERSEDED_INVOCATION_IDS)}
    frozen_superseded_invocations = {
        invocation_id: copy.deepcopy(invocation_by_id[invocation_id])
        for invocation_id in sorted(
            SYNTHETIC_W24_FANIN_SUPERSEDED_INVOCATION_IDS)}
    frozen_superseded_payload = copy.deepcopy(
        frozen_superseded_invocations)
    frozen_superseded_digest_at_capture = _semantic_digest(
        frozen_superseded_payload)
    stages_by_id = {
        stage["stage_id"]: stage for stage in milestone["execution_stages"]}
    # Preserve relative ordering while opening a strict-earlier integer slot
    # for every synthetic aggregation cut.
    for stage in stages_by_id.values():
        stage["order_index"] *= 10
    superseded_by_stage: dict[str, list[str]] = {}
    for invocation_id in SYNTHETIC_W24_FANIN_SUPERSEDED_INVOCATION_IDS:
        stage_ids = [
            stage_id for stage_id, stage in stages_by_id.items()
            if invocation_id in stage["invocation_ids"]]
        if len(stage_ids) != 1:
            raise AssertionError(
                f"synthetic W24 FANIN invocation stage mismatch {invocation_id}")
        superseded_by_stage.setdefault(stage_ids[0], []).append(invocation_id)

    def ordered_union(values: list[list[str]]) -> list[str]:
        return list(dict.fromkeys(value for group in values for value in group))

    all_entry_modes = frozenset({"fresh", "reentry", "cold"})

    def value_entry_modes(*value_ids: str) -> frozenset[str]:
        """Return the exact source entry modes encoded by option tokens."""
        constrained: set[str] = set(all_entry_modes)
        saw_constraint = False
        for value_id in value_ids:
            segments = str(value_id).split(":")
            if any(segment == "loaded" or segment.startswith("loaded_")
                   for segment in segments):
                modes = {"cold"}
            elif "reentry" in segments:
                modes = {"reentry"}
            elif "fresh" in segments:
                modes = {"fresh"}
            elif "live" in segments:
                modes = {"fresh", "reentry"}
            else:
                continue
            constrained &= modes
            saw_constraint = True
        return frozenset(constrained if saw_constraint else all_entry_modes)

    def exact_raw_options(
            record: dict[str, Any],
            readers_index: dict[str, dict[str, Any]] | None = None,
    ) -> list[dict[str, Any]]:
        """Enumerate source-compatible raw input tuples for one invocation.

        The summary producer must describe one entire reachable option, never
        one fact from that option.  Reader selection, producer selection,
        entry mode, choice domains, and original non-summary effects all stay
        in the canonical key, so two sibling routes cannot lend each other a
        partial history tuple.
        """
        readers_index = readers_index or reader_by_id
        fixed_reader_ids = list(record["always_reader_ids"])
        reader_axes: list[list[tuple[list[str], list[str], frozenset[str]]]] = []
        for conditional in record["conditional_readers"]:
            reader_id = conditional["reader_id"]
            activations = list(conditional["activation_fact_ids"])
            reader_axes.append([
                ([], [], all_entry_modes),
                ([reader_id], activations,
                 value_entry_modes(reader_id, *activations)),
            ])
        for group in record["exclusive_variant_groups"]:
            choices = []
            for variant in group["variants"]:
                reader_id = variant["reader_id"]
                activations = list(variant["activation_fact_ids"])
                choices.append((
                    [reader_id], activations,
                    value_entry_modes(reader_id, *activations)))
            if group["selection_mode"] == "at_most_one":
                choices.append(([], [], all_entry_modes))
            reader_axes.append(choices)

        producer_groups = {
            group["selection_group_id"]: group
            for group in record["producer_variant_groups"]}
        producer_variants: dict[str, list[dict[str, Any]]] = {}
        for producer in record["conditional_producers"]:
            producer_variants.setdefault(
                producer["selection_group_id"], []).append(producer)
        producer_selections = _compatible_producer_selections(
            producer_groups, producer_variants)
        internal_outputs = {
            fact_id for producer in record["conditional_producers"]
            for fact_id in producer["produced_fact_ids"]}
        selectable_reader_ids = {
            *[item["reader_id"] for item in record["conditional_readers"]],
            *[variant["reader_id"]
              for group in record["exclusive_variant_groups"]
              for variant in group["variants"]],
        }
        coupled_reader_ids = {
            reader_id for reader_id in selectable_reader_ids
            if readers_index[reader_id].get("reads_fact_ids")
            and any(
                set(readers_index[reader_id]["reads_fact_ids"]).issubset(
                    set(producer["activation_ids"]))
                for producer in record["conditional_producers"])}
        reader_selections = itertools.product(*reader_axes) \
            if reader_axes else [()]
        canonical_options: dict[tuple[Any, ...], dict[str, Any]] = {}
        for reader_selection in reader_selections:
            selected_reader_ids = list(fixed_reader_ids)
            selected_reader_activations: list[str] = []
            reader_modes = value_entry_modes(
                str(record.get("invocation_id", "")),
                *fixed_reader_ids)
            for reader_ids, activations, option_modes in reader_selection:
                selected_reader_ids.extend(reader_ids)
                selected_reader_activations.extend(activations)
                reader_modes = frozenset(
                    set(reader_modes) & set(option_modes))
            if not reader_modes:
                continue
            for producer_selection in producer_selections:
                if producer_selection and coupled_reader_ids:
                    producer_activations = {
                        activation_id for producer in producer_selection
                        for activation_id in producer["activation_ids"]}
                    expected_coupled_readers = {
                        reader_id for reader_id in coupled_reader_ids
                        if set(readers_index[reader_id][
                            "reads_fact_ids"]).issubset(
                                producer_activations)}
                    if (set(selected_reader_ids) & coupled_reader_ids
                            != expected_coupled_readers):
                        continue
                roles = {role: set() for role in ACTIVATION_ROLE_FIELDS}
                option_modes = set(reader_modes)
                choice_values: dict[str, str] = {}
                compatible = True
                choice_tokens = list(selected_reader_activations)
                for reader_id in selected_reader_ids:
                    reader = readers_index[reader_id]
                    for role in ACTIVATION_ROLE_FIELDS:
                        roles[role].update(
                            value for value in reader.get(role, [])
                            if isinstance(value, str))
                    choice_tokens.extend(reader.get("story_decision_ids", []))
                    choice_tokens.extend(
                        reader.get("scene_handoff_decision_ids", []))
                original_outputs: set[str] = set()
                original_effects: set[str] = set()
                producer_variant_ids: list[str] = []
                for producer in producer_selection:
                    producer_variant_ids.append(producer["variant_id"])
                    option_modes &= set(value_entry_modes(
                        producer["variant_id"],
                        *producer["activation_ids"]))
                    activation_roles = producer["activation_roles"]
                    for role in ACTIVATION_ROLE_FIELDS:
                        roles[role].update(
                            value for value in activation_roles[role]
                            if isinstance(value, str)
                            and value not in internal_outputs)
                    choice_tokens.extend(producer["activation_ids"])
                    original_outputs.update(producer["produced_fact_ids"])
                    original_effects.update(producer["effect_contract_ids"])
                if not option_modes:
                    continue
                for token in choice_tokens:
                    domain_value = _activation_choice_domain(str(token))
                    if domain_value is None:
                        continue
                    domain, value = domain_value
                    previous = choice_values.setdefault(domain, value)
                    if previous != value:
                        compatible = False
                        break
                if not compatible:
                    continue
                key = (
                    *(tuple(sorted(roles[role]))
                      for role in sorted(ACTIVATION_ROLE_FIELDS)),
                    tuple(sorted(option_modes)),
                    tuple(sorted(original_outputs)),
                    tuple(sorted(original_effects)),
                )
                canonical_options.setdefault(key, {
                    "activation_roles": {
                        role: sorted(roles[role])
                        for role in ACTIVATION_ROLE_FIELDS},
                    "entry_modes": sorted(option_modes),
                    "original_output_ids": sorted(original_outputs),
                    "original_effect_ids": sorted(original_effects),
                    "reader_ids": sorted(set(selected_reader_ids)),
                    "producer_variant_ids": sorted(producer_variant_ids),
                })
        return list(canonical_options.values())

    def combine_stage_raw_options(
            records: list[dict[str, Any]],
            readers_index: dict[str, dict[str, Any]] | None = None,
    ) -> list[dict[str, Any]]:
        """Combine every co-present invocation at one physical stage cut."""
        option_axes = [
            exact_raw_options(record, readers_index) for record in records]
        if any(not axis for axis in option_axes):
            return []
        combined: dict[str, dict[str, Any]] = {}
        for selected in itertools.product(*option_axes):
            entry_modes = set(all_entry_modes)
            roles = {role: set() for role in ACTIVATION_ROLE_FIELDS}
            original_outputs: set[str] = set()
            original_effects: set[str] = set()
            reader_ids: set[str] = set()
            producer_variant_ids: set[str] = set()
            choice_values: dict[str, str] = {}
            valid = True
            for option in selected:
                entry_modes &= set(option["entry_modes"])
                for role in ACTIVATION_ROLE_FIELDS:
                    roles[role].update(option["activation_roles"][role])
                original_outputs.update(option["original_output_ids"])
                original_effects.update(option["original_effect_ids"])
                reader_ids.update(option["reader_ids"])
                producer_variant_ids.update(option["producer_variant_ids"])
            if not entry_modes:
                continue
            for decision_id in (
                    roles["story_decision_ids"]
                    | roles["scene_handoff_decision_ids"]):
                domain_value = _activation_choice_domain(decision_id)
                if domain_value is None:
                    continue
                domain, value = domain_value
                previous = choice_values.setdefault(domain, value)
                if previous != value:
                    valid = False
                    break
            if not valid:
                continue
            option = {
                "activation_roles": {
                    role: sorted(roles[role])
                    for role in ACTIVATION_ROLE_FIELDS},
                "entry_modes": sorted(entry_modes),
                "original_output_ids": sorted(original_outputs),
                "original_effect_ids": sorted(original_effects),
                "reader_ids": sorted(reader_ids),
                "producer_variant_ids": sorted(producer_variant_ids),
            }
            combined.setdefault(_semantic_digest(option), option)
        return [combined[key] for key in sorted(combined)]

    def canonical_raw_id(raw_id: str) -> str:
        if raw_id.startswith("story_choice:"):
            return "decision:" + raw_id.removeprefix("story_choice:")
        return raw_id

    def raw_summary_mapping(raw_id: str) -> tuple[str, str | None]:
        """Map one raw narrative input to the closed 2-axis+1-decision set."""
        canonical_id = canonical_raw_id(raw_id)
        first_bill_value = SYNTHETIC_W24_FIRST_BILL_VALUE_BY_ID.get(
            canonical_id)
        if first_bill_value is not None:
            return "first_bill_decision", first_bill_value
        if canonical_id in SYNTHETIC_W24_FANIN_RELATIONSHIP_IDS:
            return "relationship_obligation", None
        if canonical_id in SYNTHETIC_W24_FANIN_WORK_IDS:
            return "work_and_consequence", None
        raise AssertionError(
            f"synthetic W24 FANIN raw input lacks closed mapping {raw_id}")

    replacement_invocations: dict[str, list[dict[str, Any]]] = {}
    new_stages: list[dict[str, Any]] = []
    new_groups: list[dict[str, Any]] = []
    superseded_story_reader_ids: set[str] = set()
    replacement_reader_ids_by_superseded: dict[str, set[str]] = {}
    observed_raw_ids: set[str] = set()
    stage_tuple_digests: dict[str, str] = {}
    replacement_stage_tuple_digests: dict[str, str] = {}
    stage_tuple_counts: dict[str, int] = {}
    feasible_stage_tuple_count = 0
    original_output_multisets_by_stage: dict[str, list[str]] = {}
    for original_stage_id, superseded_ids in sorted(
            superseded_by_stage.items(),
            key=lambda pair: (
                stages_by_id[pair[0]]["order_index"], pair[0])):
        original_stage = stages_by_id[original_stage_id]
        superseded_ids = [
            invocation_id for invocation_id in original_stage["invocation_ids"]
            if invocation_id in superseded_ids]
        records = [copy.deepcopy(invocation_by_id[invocation_id])
                   for invocation_id in superseded_ids]
        slug = re.sub(r"[^A-Za-z0-9_]+", "_", original_stage_id).strip("_")
        aggregate_id = f"reader:synthetic:w24:fanin_aggregate:{slug}"
        summary_producer_id = (
            f"reader:synthetic:w24:fanin_summary_producer:{slug}")
        consumer_id = f"reader:synthetic:w24:fanin_consumer:{slug}"
        reader_id = f"reader:synthetic:w24:fanin_summary:{slug}"
        aggregate_stage_id = (
            f"w24:synthetic_fanin_aggregate:{original_stage_id}")
        summary_stage_id = (
            f"w24:synthetic_fanin_summary:{original_stage_id}")
        aggregate_group_id = f"group:synthetic:w24:fanin_aggregate:{slug}"
        summary_producer_group_id = (
            f"group:synthetic:w24:fanin_summary_producer:{slug}")
        resolver_group_id = (
            f"group:synthetic:w24:raw_options_resolved:{slug}")
        producer_group_id = f"group:synthetic:w24:fanin_summary:{slug}"
        resolver_receipt_id = (
            f"receipt:synthetic:w24:raw_options_resolved:{slug}")
        aggregate_proof_id = f"proof:synthetic:w24_fanin_aggregate:{slug}"
        consumer_proof_id = f"proof:synthetic:w24_fanin_consumer:{slug}"

        raw_reader_ids = ordered_union([
            [
                *record["always_reader_ids"],
                *[item["reader_id"]
                  for item in record["conditional_readers"]],
                *[variant["reader_id"]
                  for group in record["exclusive_variant_groups"]
                  for variant in group["variants"]],
            ] for record in records])
        raw_reader_ids = [
            reader_id for reader_id in raw_reader_ids
            if reader_id in reader_by_id]
        superseded_story_reader_ids.update(
            reader_id for reader_id in raw_reader_ids
            if not reader_id.startswith(
                "reader:synthetic:w24_completion_application_choice:"))
        cloned_reader_ids: dict[str, str] = {}
        for raw_reader_id in raw_reader_ids:
            raw_reader = reader_by_id[raw_reader_id]
            raw_slug = re.sub(
                r"[^A-Za-z0-9_]+", "_", raw_reader_id).strip("_")
            clone_id = (
                f"reader:synthetic:w24:fanin_raw:{slug}:source:"
                f"{raw_reader_id}")
            clone_proof_id = (
                f"proof:synthetic:w24_fanin_raw:{slug}:{raw_slug}")
            clone = copy.deepcopy(raw_reader)
            clone["reader_id"] = clone_id
            clone["reader_kind"] = "producer_result"
            clone["layer_owner"] = "weekly_action"
            clone["runtime_pointer"] = (
                "systems/DemoCoreLoopV2.gd::_bundle_requirement_met")
            clone["runtime_proof_ids"] = [
                *clone["runtime_proof_ids"], clone_proof_id]
            clone_proof = {
                "proof_id": clone_proof_id,
                "kind": "source_symbol",
                "pointer": "systems/DemoCoreLoopV2.gd::_bundle_requirement_met",
                "assertion": (
                    "synthetic non-Story W24 raw input clone "
                    f"source={raw_reader_id} clone={clone_id}"),
            }
            fixture["reader_registry"].append(clone)
            fixture["runtime_proof_registry"].append(clone_proof)
            reader_by_id[clone_id] = clone
            proof_by_id[clone_proof_id] = clone_proof
            cloned_reader_ids[raw_reader_id] = clone_id
            # Row-owned reverse references must keep pointing at the exact
            # one-for-one raw consumer (facts, decision role, build family,
            # and read contract).  The two-axis Story summary is downstream
            # narrative compression, not evidence that the originating row's
            # durable fact has an exact causal reader.
            replacement_reader_ids_by_superseded.setdefault(
                raw_reader_id, set()).add(clone_id)

        mapped_records = copy.deepcopy(records)
        for record in mapped_records:
            record["always_reader_ids"] = [
                cloned_reader_ids[reader_id]
                for reader_id in record["always_reader_ids"]
                if reader_id in cloned_reader_ids]
            record["conditional_readers"] = [
                conditional for conditional in record["conditional_readers"]
                if conditional["reader_id"] in cloned_reader_ids]
            for conditional in record["conditional_readers"]:
                conditional["reader_id"] = cloned_reader_ids[
                    conditional["reader_id"]]
            mapped_groups: list[dict[str, Any]] = []
            for group in record["exclusive_variant_groups"]:
                group["variants"] = [
                    variant for variant in group["variants"]
                    if variant["reader_id"] in cloned_reader_ids]
                if not group["variants"]:
                    continue
                if len(group["variants"]) == 1:
                    variant = group["variants"][0]
                    variant["reader_id"] = cloned_reader_ids[
                        variant["reader_id"]]
                    if group["selection_mode"] == "exactly_one":
                        record["always_reader_ids"].append(
                            variant["reader_id"])
                    else:
                        record["conditional_readers"].append(variant)
                    continue
                group["group_id"] = (
                    f"group:synthetic:w24:fanin_raw:{slug}:"
                    + re.sub(r"[^A-Za-z0-9_]+", "_", group["group_id"]))
                for variant in group["variants"]:
                    variant["reader_id"] = cloned_reader_ids[
                        variant["reader_id"]]
                exclusive_proof_id = (
                    "proof:exclusive:" + group["group_id"].replace(":", "_"))
                for variant in group["variants"]:
                    variant["runtime_proof_ids"].append(exclusive_proof_id)
                exclusive_proof = {
                    "proof_id": exclusive_proof_id,
                    "kind": "source_symbol",
                    "pointer": (
                        "systems/DemoCoreLoopV2.gd::_bundle_requirement_met"),
                    "assertion": " ".join([
                        group["group_id"], group["selection_mode"],
                        *[variant["reader_id"]
                          for variant in group["variants"]],
                        *[fact_id for variant in group["variants"]
                          for fact_id in variant["activation_fact_ids"]],
                    ]),
                }
                fixture["runtime_proof_registry"].append(exclusive_proof)
                proof_by_id[exclusive_proof_id] = exclusive_proof
                mapped_groups.append(group)
            record["exclusive_variant_groups"] = mapped_groups
            producer_group_ids = {
                group["selection_group_id"]: (
                    f"group:synthetic:w24:fanin_raw:{slug}:producer:"
                    + re.sub(
                        r"[^A-Za-z0-9_]+", "_",
                        group["selection_group_id"]).strip("_"))
                for group in record["producer_variant_groups"]
            }
            for group in record["producer_variant_groups"]:
                group["selection_group_id"] = producer_group_ids[
                    group["selection_group_id"]]
            for producer in record["conditional_producers"]:
                original_variant_id = producer["variant_id"]
                producer["variant_id"] = (
                    f"variant:synthetic:w24:fanin_raw:{slug}:source:"
                    f"{original_variant_id}")
                producer["selection_group_id"] = producer_group_ids[
                    producer["selection_group_id"]]

        clone_to_source = {
            clone_id: source_id
            for source_id, clone_id in cloned_reader_ids.items()}
        normalized_readers_index = dict(reader_by_id)
        for source_id, clone_id in cloned_reader_ids.items():
            normalized_clone = copy.deepcopy(reader_by_id[clone_id])
            normalized_clone["reader_id"] = source_id
            normalized_readers_index[source_id] = normalized_clone
        normalized_mapped_records = copy.deepcopy(mapped_records)
        for normalized, source in zip(
                normalized_mapped_records, records):
            normalized["invocation_id"] = source["invocation_id"]
            normalized["always_reader_ids"] = [
                clone_to_source.get(reader_id, reader_id)
                for reader_id in normalized["always_reader_ids"]]
            for conditional in normalized["conditional_readers"]:
                conditional["reader_id"] = clone_to_source.get(
                    conditional["reader_id"], conditional["reader_id"])
            for normalized_group, source_group in zip(
                    normalized["exclusive_variant_groups"],
                    source["exclusive_variant_groups"]):
                normalized_group["group_id"] = source_group["group_id"]
                for variant in normalized_group["variants"]:
                    variant["reader_id"] = clone_to_source.get(
                        variant["reader_id"], variant["reader_id"])
            for normalized_group, source_group in zip(
                    normalized["producer_variant_groups"],
                    source["producer_variant_groups"]):
                normalized_group["selection_group_id"] = \
                    source_group["selection_group_id"]
            for normalized_producer, source_producer in zip(
                    normalized["conditional_producers"],
                    source["conditional_producers"]):
                normalized_producer["variant_id"] = \
                    source_producer["variant_id"]
                normalized_producer["selection_group_id"] = \
                    source_producer["selection_group_id"]

        raw_options = _synthetic_w24_combine_stage_raw_options(
            records, reader_by_id)
        if not raw_options:
            raise AssertionError(
                f"synthetic W24 FANIN aggregator has no raw history {slug}")
        replacement_raw_options = _synthetic_w24_combine_stage_raw_options(
            normalized_mapped_records, normalized_readers_index)

        old_tuple_set = {
            _semantic_digest(_synthetic_w24_option_projection(option))
            for option in raw_options}
        replacement_tuple_set = {
            _semantic_digest(_synthetic_w24_option_projection(option))
            for option in replacement_raw_options}
        if old_tuple_set != replacement_tuple_set:
            old_projection_by_digest = {
                _semantic_digest(_synthetic_w24_option_projection(option)):
                    _synthetic_w24_option_projection(option)
                for option in raw_options}
            replacement_projection_by_digest = {
                _semantic_digest(_synthetic_w24_option_projection(option)):
                    _synthetic_w24_option_projection(option)
                for option in replacement_raw_options}
            raise AssertionError(
                f"synthetic W24 old/new raw tuple mismatch {slug} "
                f"missing_one={old_projection_by_digest[sorted(old_tuple_set - replacement_tuple_set)[0]]} "
                f"extra_one={replacement_projection_by_digest[sorted(replacement_tuple_set - old_tuple_set)[0]]}")
        feasible_stage_tuple_count += len(old_tuple_set)
        stage_tuple_counts[original_stage_id] = len(old_tuple_set)
        replacement_stage_tuple_digests[original_stage_id] = \
            _semantic_digest(sorted(replacement_tuple_set))

        raw_ids_for_stage = {
            raw_id for reader_id in raw_reader_ids
            for role in (
                "history_memory_ids", "story_decision_ids",
                "scene_handoff_decision_ids")
            for raw_id in reader_by_id[reader_id].get(role, [])
            if canonical_raw_id(raw_id)
            in SYNTHETIC_W24_FANIN_RAW_ID_UNIVERSE
        }
        raw_ids_for_stage.update(
            raw_id for record in records
            for producer in record["conditional_producers"]
            for role in (
                "history_memory_ids", "story_decision_ids",
                "scene_handoff_decision_ids")
            for raw_id in producer["activation_roles"][role]
            if canonical_raw_id(raw_id)
            in SYNTHETIC_W24_FANIN_RAW_ID_UNIVERSE)
        for raw_id in raw_ids_for_stage:
            try:
                raw_summary_mapping(raw_id)
            except AssertionError as exc:
                raise AssertionError(
                    f"{exc} stage={original_stage_id}") from exc
        observed_raw_ids.update(map(canonical_raw_id, raw_ids_for_stage))
        stage_tuple_digest = _semantic_digest(sorted(old_tuple_set))
        stage_tuple_digests[original_stage_id] = stage_tuple_digest
        original_output_multiset = sorted(
            output_id for option in raw_options
            for output_id in option["original_output_ids"])
        original_output_multisets_by_stage[original_stage_id] = \
            original_output_multiset
        resolver_variant = {
            "variant_id": (
                f"variant:synthetic:w24:raw_options_resolved:{slug}"),
            "activation_ids": ["runtime:turn:24"],
            "produced_fact_ids": [resolver_receipt_id],
            "effect_contract_ids": [
                f"effect:synthetic:w24:raw_options_resolved:{slug}"],
            "runtime_proof_ids": [aggregate_proof_id],
            "selection_group_id": resolver_group_id,
            "activation_roles": {
                "history_memory_ids": [],
                "material_state_ids": ["runtime:turn:24"],
                "scene_handoff_fact_ids": [],
                "story_decision_ids": [],
                "scene_handoff_decision_ids": [],
            },
        }
        summary_variant = {
            "variant_id": f"variant:synthetic:w24:fanin_summary:{slug}",
            "activation_ids": [resolver_receipt_id],
            "produced_fact_ids": list(
                SYNTHETIC_W24_FANIN_SUMMARY_FACT_IDS),
            "effect_contract_ids": [
                "effect:synthetic:w24:fanin_summary:"
                + produced_id.replace(":", "_")
                for produced_id in SYNTHETIC_W24_FANIN_SUMMARY_FACT_IDS
            ],
            "runtime_proof_ids": [aggregate_proof_id],
            "selection_group_id": producer_group_id,
            "activation_roles": {
                "history_memory_ids": [],
                "material_state_ids": [],
                "scene_handoff_fact_ids": [resolver_receipt_id],
                "story_decision_ids": [],
                "scene_handoff_decision_ids": [],
            },
        }
        aggregate = {
            "invocation_id": aggregate_id,
            "runtime_pointer":
                "systems/DemoCoreLoopV2.gd::_bundle_requirement_met",
            "always_reader_ids": ordered_union([
                record["always_reader_ids"] for record in mapped_records]),
            "conditional_readers": [
                copy.deepcopy(item) for record in mapped_records
                for item in record["conditional_readers"]],
            "exclusive_variant_groups": [
                copy.deepcopy(item) for record in mapped_records
                for item in record["exclusive_variant_groups"]],
            "conditional_producers": [
                *[copy.deepcopy(producer)
                  for record in mapped_records
                  for producer in record["conditional_producers"]],
                resolver_variant,
            ],
            "producer_variant_groups": [
                *[copy.deepcopy(group)
                  for record in mapped_records
                  for group in record["producer_variant_groups"]],
                {
                    "selection_group_id": resolver_group_id,
                    "selection_mode": "exactly_one",
                    "causal_status": "active",
                },
            ],
            "runtime_proof_ids": [
                *ordered_union([
                    record["runtime_proof_ids"] for record in mapped_records]),
                aggregate_proof_id,
            ],
        }
        aggregate_has_readers = bool(
            aggregate["always_reader_ids"]
            or aggregate["conditional_readers"]
            or aggregate["exclusive_variant_groups"])
        summary_producer = {
            "invocation_id": summary_producer_id,
            "runtime_pointer":
                "systems/DemoCoreLoopV2.gd::_bundle_requirement_met",
            "always_reader_ids": [],
            "conditional_readers": [],
            "exclusive_variant_groups": [],
            "conditional_producers": [summary_variant],
            "producer_variant_groups": [{
                "selection_group_id": producer_group_id,
                "selection_mode": "exactly_one",
                "causal_status": "active",
            }],
            "runtime_proof_ids": [aggregate_proof_id],
        }
        summary_readers: list[dict[str, Any]] = []
        summary_always_ids: list[str] = []
        for summary_fact_id in SYNTHETIC_W24_FANIN_SUMMARY_FACT_IDS:
            axis = summary_fact_id.rsplit(":", 1)[-1]
            summary_reader_id = (
                f"reader:synthetic:w24:fanin_summary:{slug}:{axis}")
            summary_reader = {
                "reader_id": summary_reader_id,
                "reader_kind": "story_milestone",
                "layer_owner": "story",
                "status": "active",
                "reads_fact_ids": [summary_fact_id],
                "history_memory_ids": [],
                "material_state_ids": [],
                "read_contracts": [{
                    "fact_id": summary_fact_id,
                    "runtime_proof_ids": [consumer_proof_id],
                }],
                "input_build_family_ids": [],
                "story_decision_ids": [],
                "runtime_pointer": "scenes/StoryMode.gd::_load_next_event",
                "runtime_proof_ids": [consumer_proof_id],
                "scene_handoff_fact_ids": [summary_fact_id],
                "scene_handoff_decision_ids": [],
            }
            summary_readers.append(summary_reader)
            summary_always_ids.append(summary_reader_id)

        produced_first_bill_decisions = sorted({
            canonical_raw_id(raw_id) for raw_id in raw_ids_for_stage
            if canonical_raw_id(raw_id)
            in SYNTHETIC_W24_FIRST_BILL_VALUE_BY_ID})
        historical_first_bill_decisions = {
            canonical_raw_id(decision_id)
            for decision_id in [
                *[decision_id for reader_id in raw_reader_ids
                  for decision_id in reader_by_id[reader_id].get(
                      "story_decision_ids", [])],
                *[decision_id for record in records
                  for producer in record["conditional_producers"]
                  for decision_id in producer["activation_roles"][
                      "story_decision_ids"]],
            ]
            if canonical_raw_id(decision_id)
            in SYNTHETIC_W24_FIRST_BILL_VALUE_BY_ID}
        handoff_first_bill_decisions = {
            canonical_raw_id(decision_id)
            for decision_id in [
                *[decision_id for reader_id in raw_reader_ids
                  for decision_id in reader_by_id[reader_id].get(
                      "scene_handoff_decision_ids", [])],
                *[decision_id for record in records
                  for producer in record["conditional_producers"]
                  for decision_id in producer["activation_roles"][
                      "scene_handoff_decision_ids"]],
            ]
            if canonical_raw_id(decision_id)
            in SYNTHETIC_W24_FIRST_BILL_VALUE_BY_ID}
        summary_decision_readers: list[dict[str, Any]] = []
        summary_decision_group: dict[str, Any] | None = None
        summary_decision_proof: dict[str, Any] | None = None
        if produced_first_bill_decisions:
            decision_group_id = (
                f"group:synthetic:w24:fanin_summary_decision:{slug}")
            decision_proof_id = (
                "proof:exclusive:" + decision_group_id.replace(":", "_"))
            decision_variants = []
            decision_role_variants = [
                (decision_id, temporal_role)
                for decision_id in produced_first_bill_decisions
                for temporal_role in (
                    *(["loaded"]
                      if decision_id in historical_first_bill_decisions
                      else []),
                    *(["live"]
                      if decision_id in handoff_first_bill_decisions
                      else []),
                )]
            for decision_id, temporal_role in decision_role_variants:
                choice_value = decision_id.rsplit(":", 1)[-1]
                decision_reader_id = (
                    f"reader:synthetic:w24:fanin_summary_decision:"
                    f"{slug}:{choice_value}:{temporal_role}")
                decision_reader = {
                    "reader_id": decision_reader_id,
                    "reader_kind": "story_milestone",
                    "layer_owner": "story",
                    "status": "active",
                    "reads_fact_ids": [],
                    "history_memory_ids": [],
                    "material_state_ids": [],
                    "read_contracts": [],
                    "input_build_family_ids": [],
                    "story_decision_ids": (
                        [decision_id]
                        if temporal_role == "loaded"
                        else []),
                    "runtime_pointer": "scenes/StoryMode.gd::_load_next_event",
                    "runtime_proof_ids": [
                        consumer_proof_id, decision_proof_id],
                    "scene_handoff_fact_ids": [],
                    "scene_handoff_decision_ids": (
                        [decision_id]
                        if temporal_role == "live"
                        else []),
                }
                summary_decision_readers.append(decision_reader)
                decision_variants.append({
                    "reader_id": decision_reader_id,
                    "activation_fact_ids": [decision_id],
                    "runtime_proof_ids": [
                        consumer_proof_id, decision_proof_id],
                })
            summary_decision_group = {
                "group_id": decision_group_id,
                "selection_mode": "at_most_one",
                "causal_status": "active",
                "debt_id": None,
                "variants": decision_variants,
            }
            summary_decision_proof = {
                "proof_id": decision_proof_id,
                "kind": "source_symbol",
                "pointer": "scenes/StoryMode.gd::_load_next_event",
                "assertion": " ".join([
                    decision_group_id,
                    "at_most_one",
                    *[variant["reader_id"]
                      for variant in decision_variants],
                    *[activation_id
                      for variant in decision_variants
                      for activation_id in variant["activation_fact_ids"]],
                ]),
            }
        consumer_always = [*summary_always_ids, *ordered_union([
            [reader_id for reader_id in record["always_reader_ids"]
             if reader_id not in cloned_reader_ids]
            for record in records])]
        consumer_conditionals = [
            *[
                copy.deepcopy(conditional)
                for record in records
                for conditional in record["conditional_readers"]
                if conditional["reader_id"] not in cloned_reader_ids],
        ]
        consumer_groups: list[dict[str, Any]] = (
            [summary_decision_group]
            if summary_decision_group is not None else [])
        for record in records:
            for source_group in record["exclusive_variant_groups"]:
                group = copy.deepcopy(source_group)
                group["variants"] = [
                    variant for variant in group["variants"]
                    if variant["reader_id"] not in cloned_reader_ids]
                if not group["variants"]:
                    continue
                if len(group["variants"]) == 1:
                    variant = group["variants"][0]
                    if group["selection_mode"] == "exactly_one":
                        consumer_always.append(variant["reader_id"])
                    else:
                        consumer_conditionals.append(variant)
                else:
                    consumer_groups.append(group)

        consumer_producers: list[dict[str, Any]] = []
        consumer = {
            "invocation_id": consumer_id,
            "runtime_pointer": records[0]["runtime_pointer"],
            "always_reader_ids": list(dict.fromkeys(consumer_always)),
            "conditional_readers": consumer_conditionals,
            "exclusive_variant_groups": consumer_groups,
            "conditional_producers": consumer_producers,
            "producer_variant_groups": [],
            "runtime_proof_ids": [
                *ordered_union([
                    record["runtime_proof_ids"] for record in records]),
                consumer_proof_id,
            ],
        }
        retained_consumer_reader_ids = {
            *consumer["always_reader_ids"],
            *[item["reader_id"]
              for item in consumer["conditional_readers"]],
            *[variant["reader_id"]
              for group in consumer["exclusive_variant_groups"]
              for variant in group["variants"]],
        }
        for retained_reader_id in retained_consumer_reader_ids:
            retained_reader = reader_by_id.get(retained_reader_id)
            if (isinstance(retained_reader, dict)
                    and retained_reader.get("reader_kind")
                        == "story_milestone"):
                retained_reader["runtime_proof_ids"] = list(dict.fromkeys([
                    *retained_reader["runtime_proof_ids"], consumer_proof_id,
                ]))
        for summary_reader in [
                *summary_readers, *summary_decision_readers]:
            summary_reader_id = summary_reader["reader_id"]
            reader_by_id[summary_reader_id] = summary_reader
            fixture["reader_registry"].append(summary_reader)
            milestone["reader_ids"].append(summary_reader_id)

        aggregate_stage = {
            "stage_id": aggregate_stage_id,
            "order_index": original_stage["order_index"] - 2,
            "applicability_ids": list(original_stage["applicability_ids"]),
            "predecessor_stage_ids": list(
                original_stage["predecessor_stage_ids"]),
            "invocation_ids": [aggregate_id],
            "runtime_proof_ids": [
                *original_stage["runtime_proof_ids"], aggregate_proof_id],
        }
        summary_stage = {
            "stage_id": summary_stage_id,
            "order_index": original_stage["order_index"] - 1,
            "applicability_ids": list(original_stage["applicability_ids"]),
            "predecessor_stage_ids": [aggregate_stage_id],
            "invocation_ids": [summary_producer_id],
            "runtime_proof_ids": [
                *original_stage["runtime_proof_ids"], aggregate_proof_id],
        }
        original_stage["predecessor_stage_ids"] = [summary_stage_id]
        original_stage["invocation_ids"] = [
            consumer_id if invocation_id in superseded_ids else invocation_id
            for invocation_id in original_stage["invocation_ids"]]
        original_stage["invocation_ids"] = list(dict.fromkeys(
            original_stage["invocation_ids"]))
        original_stage["runtime_proof_ids"].append(consumer_proof_id)
        aggregate_group = {
            "group_id": aggregate_group_id,
            "invocation_ids": [aggregate_id],
            "runtime_proof_ids": [aggregate_proof_id],
        }
        summary_producer_group = {
            "group_id": summary_producer_group_id,
            "invocation_ids": [summary_producer_id],
            "runtime_proof_ids": [aggregate_proof_id],
        }
        aggregate_proof = {
            "proof_id": aggregate_proof_id,
            "kind": "source_symbol",
            "pointer": "systems/DemoCoreLoopV2.gd::_bundle_requirement_met",
            "assertion": (
                "synthetic W24 exact input aggregation "
                f"supersedes={','.join(superseded_ids)} "
                f"summaries={','.join(SYNTHETIC_W24_FANIN_SUMMARY_FACT_IDS)} "
                + f"{_invocation_contract_token(aggregate)} "
                + f"{_invocation_contract_token(summary_producer)} "
                + f"{_co_presence_contract_token(aggregate_group)} "
                + f"{_co_presence_contract_token(summary_producer_group)} "
                f"tuple_digest={stage_tuple_digest} "
                f"raw_ids={','.join(sorted(raw_ids_for_stage))} "
                f"original_outputs={_semantic_digest(original_output_multiset)} "
                f"{_execution_stage_contract_token(aggregate_stage)} "
                f"{_execution_stage_contract_token(summary_stage)}"),
        }
        consumer_proof = {
            "proof_id": consumer_proof_id,
            "kind": "source_symbol",
            "pointer": "scenes/StoryMode.gd::_load_next_event",
            "assertion": (
                "synthetic W24 capped Story history consumer "
                + ((
                    f"{summary_decision_group['group_id']} at_most_one "
                    + " ".join(
                        variant["reader_id"] + " "
                        + " ".join(variant["activation_fact_ids"])
                        for variant in summary_decision_group["variants"])
                    + " ") if summary_decision_group is not None else "")
                + f"{_invocation_contract_token(consumer)} "
                f"{_execution_stage_contract_token(original_stage)}"),
        }
        for proof in (
                aggregate_proof, consumer_proof,
                *([summary_decision_proof]
                  if summary_decision_proof is not None else [])):
            fixture["runtime_proof_registry"].append(proof)
            proof_by_id[proof["proof_id"]] = proof
        replacement_invocations[original_stage_id] = [
            aggregate, summary_producer, consumer]
        new_stages.extend([aggregate_stage, summary_stage])
        new_groups.append(aggregate_group)
        new_groups.append(summary_producer_group)

    if observed_raw_ids != SYNTHETIC_W24_FANIN_RAW_ID_UNIVERSE:
        raise AssertionError(
            "synthetic W24 FANIN raw input universe mismatch "
            f"missing={sorted(SYNTHETIC_W24_FANIN_RAW_ID_UNIVERSE - observed_raw_ids)} "
            f"extra={sorted(observed_raw_ids - SYNTHETIC_W24_FANIN_RAW_ID_UNIVERSE)}")

    replaced_invocation_ids = set().union(*superseded_by_stage.values())
    rebuilt_invocations: list[dict[str, Any]] = []
    inserted_stages: set[str] = set()
    for invocation in milestone["invocations"]:
        invocation_id = invocation["invocation_id"]
        if invocation_id not in replaced_invocation_ids:
            rebuilt_invocations.append(invocation)
            continue
        stage_id = next(
            stage_id for stage_id, members in superseded_by_stage.items()
            if invocation_id in members)
        if stage_id not in inserted_stages:
            rebuilt_invocations.extend(replacement_invocations[stage_id])
            inserted_stages.add(stage_id)
    milestone["invocations"] = rebuilt_invocations

    # Executable membership, not registry presence, defines the repaired W24
    # reader surface.  The frozen raw readers remain evidence records but the
    # milestone references only the non-Story clones and capped consumers.
    milestone["reader_ids"] = list(dict.fromkeys(
        reader_id
        for invocation in milestone["invocations"]
        for reader_id in (
            *invocation["always_reader_ids"],
            *[item["reader_id"]
              for item in invocation["conditional_readers"]],
            *[variant["reader_id"]
              for group in invocation["exclusive_variant_groups"]
              for variant in group["variants"]],
        )))
    executable_reader_ids = set(milestone["reader_ids"])
    retired_reader_ids = (
        superseded_story_reader_ids - executable_reader_ids)
    fixture["reader_registry"] = [
        reader for reader in fixture["reader_registry"]
        if reader.get("reader_id") not in retired_reader_ids]
    for reader_id in retired_reader_ids:
        reader_by_id.pop(reader_id, None)
    for row in fixture["rows"]:
        for field_name in ("near_reader_ids", "milestone_reader_ids"):
            old_refs = row.get(field_name, [])
            if not isinstance(old_refs, list):
                continue
            row[field_name] = list(dict.fromkeys(
                replacement_id
                for old_reader_id in old_refs
                for replacement_id in (
                    sorted(replacement_reader_ids_by_superseded.get(
                        old_reader_id, set()))
                    if old_reader_id in retired_reader_ids
                    else [old_reader_id])))
        missed = row.get("missed_contract", {})
        old_refs = missed.get("reader_ids", []) \
            if isinstance(missed, dict) else []
        if isinstance(old_refs, list):
            missed["reader_ids"] = list(dict.fromkeys(
                replacement_id
                for old_reader_id in old_refs
                for replacement_id in (
                    sorted(replacement_reader_ids_by_superseded.get(
                        old_reader_id, set()))
                    if old_reader_id in retired_reader_ids
                    else [old_reader_id])))
    for witness in fixture.get("replay_witnesses", []):
        old_refs = witness.get("reader_ids", []) \
            if isinstance(witness, dict) else []
        if isinstance(old_refs, list):
            witness["reader_ids"] = list(dict.fromkeys(
                replacement_id
                for old_reader_id in old_refs
                for replacement_id in (
                    sorted(replacement_reader_ids_by_superseded.get(
                        old_reader_id, set()))
                    if old_reader_id in retired_reader_ids
                    else [old_reader_id])))

    rebuilt_story_members: list[str] = []
    inserted_consumers: set[str] = set()
    for invocation_id in story_group["invocation_ids"]:
        if invocation_id not in replaced_invocation_ids:
            rebuilt_story_members.append(invocation_id)
            continue
        stage_id = next(
            stage_id for stage_id, members in superseded_by_stage.items()
            if invocation_id in members)
        consumer_id = replacement_invocations[stage_id][-1]["invocation_id"]
        if consumer_id not in inserted_consumers:
            rebuilt_story_members.append(consumer_id)
            inserted_consumers.add(consumer_id)
    story_group["invocation_ids"] = rebuilt_story_members
    story_group_proof_id = "proof:synthetic:w24_fanin_story_scene"
    story_group["runtime_proof_ids"].append(story_group_proof_id)
    story_group_proof = {
        "proof_id": story_group_proof_id,
        "kind": "source_symbol",
        "pointer": "scenes/StoryMode.gd::_load_next_event",
        "assertion": (
            "synthetic W24 replacement Story topology "
            f"{_co_presence_contract_token(story_group)}"),
    }
    fixture["runtime_proof_registry"].append(story_group_proof)
    proof_by_id[story_group_proof_id] = story_group_proof
    milestone["co_presence_groups"].extend(new_groups)
    milestone["execution_stages"].extend(new_stages)

    aggregate_stages_by_order: dict[int, list[dict[str, Any]]] = {}
    for stage in new_stages:
        aggregate_stages_by_order.setdefault(
            stage["order_index"], []).append(stage)
    for order_index, same_order in aggregate_stages_by_order.items():
        if len(same_order) < 2:
            continue
        proof_id = f"proof:synthetic:w24_fanin_mutually_exclusive:{order_index}"
        proof = {
            "proof_id": proof_id,
            "kind": "source_symbol",
            "pointer": "systems/DemoCoreLoopV2.gd::_bundle_requirement_met",
            "assertion": (
                "synthetic mutually_exclusive W24 aggregation stages "
                + ",".join(stage["stage_id"] for stage in same_order)),
        }
        for stage in same_order:
            stage["runtime_proof_ids"].append(proof_id)
        fixture["runtime_proof_registry"].append(proof)
        proof_by_id[proof_id] = proof

    # Scaled/rewired production stage proofs remain immutable evidence; an
    # added synthetic proof binds each exact replacement-stage record.
    for stage in milestone["execution_stages"]:
        if stage["stage_id"].startswith("w24:synthetic_fanin_aggregate:"):
            continue
        slug = re.sub(r"[^A-Za-z0-9_]+", "_", stage["stage_id"]).strip("_")
        proof_id = f"proof:synthetic:w24_fanin_stage:{slug}"
        proof = {
            "proof_id": proof_id,
            "kind": "source_symbol",
            "pointer": "scenes/StoryMode.gd::_load_next_event",
            "assertion": (
                "synthetic W24 scenario-preserving scaled stage "
                + _execution_stage_contract_token(stage)),
        }
        stage["runtime_proof_ids"].append(proof_id)
        fixture["runtime_proof_registry"].append(proof)
        proof_by_id[proof_id] = proof

    production_w24_scenarios = \
        EXPECTED_EXECUTION_STAGE_SCENARIOS_BY_WEEK[24]
    if (_semantic_digest(production_w24_scenarios)
            != SYNTHETIC_W24_SOURCE_SCENARIOS_SHA256):
        raise AssertionError(
            "synthetic W24 source scenario allowlist changed")
    source_stage_map = {
        stage_id: (
            sum(1 for scenario in production_w24_scenarios
                if stage_id in scenario),
            SYNTHETIC_W24_SOURCE_TUPLE_STAGE_MAP[stage_id][1],
            SYNTHETIC_W24_SOURCE_TUPLE_STAGE_MAP[stage_id][2],
        )
        for stage_id in stage_tuple_counts}
    if source_stage_map != SYNTHETIC_W24_SOURCE_TUPLE_STAGE_MAP:
        raise AssertionError(
            "synthetic W24 source-feasible stage tuple map changed")
    source_feasible_tuple_occurrence_count = sum(
        values[1] for values in source_stage_map.values())
    source_rejected_tuple_occurrence_count = sum(
        values[2] for values in source_stage_map.values())
    if source_feasible_tuple_occurrence_count != 51_977:
        raise AssertionError(
            "synthetic W24 source-feasible tuple occurrence mismatch "
            f"{source_feasible_tuple_occurrence_count}")
    replacement_invocation_records = {
        invocation["invocation_id"]: copy.deepcopy(invocation)
        for invocation in milestone["invocations"]
        if str(invocation.get("invocation_id", "")).startswith(
            "reader:synthetic:w24:fanin_")}
    raw_clone_records = {
        reader["reader_id"]: copy.deepcopy(reader)
        for reader in fixture["reader_registry"]
        if str(reader.get("reader_id", "")).startswith(
            "reader:synthetic:w24:fanin_raw:")}
    return {
        "production_semantic_digest": AUDITED_LEDGER_SEMANTIC_SHA256,
        "superseded_invocation_ids": sorted(
            SYNTHETIC_W24_FANIN_SUPERSEDED_INVOCATION_IDS),
        "remaining_invocations": frozen_remaining_invocations,
        "superseded_invocations": frozen_superseded_payload,
        "superseded_digest_at_capture": frozen_superseded_digest_at_capture,
        "superseded_story_reader_ids": sorted(
            superseded_story_reader_ids),
        "stage_tuple_digests": dict(sorted(stage_tuple_digests.items())),
        "replacement_stage_tuple_digests": dict(sorted(
            replacement_stage_tuple_digests.items())),
        "feasible_stage_tuple_count": feasible_stage_tuple_count,
        "source_feasible_tuple_occurrence_count": (
            source_feasible_tuple_occurrence_count),
        "source_rejected_tuple_occurrence_count": (
            source_rejected_tuple_occurrence_count),
        "source_stage_tuple_map": source_stage_map,
        "stage_tuple_counts": dict(sorted(stage_tuple_counts.items())),
        "source_scenarios_digest": _semantic_digest(
            production_w24_scenarios),
        "original_output_multisets_by_stage": dict(sorted(
            original_output_multisets_by_stage.items())),
        "replacement_invocations": replacement_invocation_records,
        "raw_clone_records": raw_clone_records,
        "raw_id_universe": sorted(observed_raw_ids),
        "partition_digest": _semantic_digest({
            "work_and_consequence": sorted(
                SYNTHETIC_W24_FANIN_WORK_IDS),
            "relationship_obligation": sorted(
                SYNTHETIC_W24_FANIN_RELATIONSHIP_IDS),
            "first_bill_decision_domain": sorted(
                SYNTHETIC_W24_FIRST_BILL_VALUE_BY_ID),
        }),
    }


def _complete_fixture(
        ledger: dict[str, Any], *,
        return_manifest: bool = False,
) -> dict[str, Any] | tuple[dict[str, Any], dict[str, Any]]:
    if _semantic_digest(ledger) != AUDITED_LEDGER_SEMANTIC_SHA256:
        raise AssertionError(
            "synthetic complete fixture requires exact audited production ledger")
    # Capture source/scenario evidence before the first deepcopy or repair.
    # This is the independent side of the old->new comparison; no value from
    # the later fixture or its manifest is allowed to replace it.
    production_evidence = _derive_synthetic_w24_production_evidence(ledger)
    production_row_reference_contract = \
        _derive_synthetic_w24_row_reference_contract(ledger)
    production_w24 = next(
        item for item in ledger["milestone_registry"] if item["week"] == 24)
    production_invocations = {
        item["invocation_id"]: item
        for item in production_w24["invocations"]}
    production_story_members = set(next(
        group["invocation_ids"]
        for group in production_w24["co_presence_groups"]
        if group["group_id"] == "group:w24:story_scene"))
    production_superseded = {
        invocation_id: production_invocations[invocation_id]
        for invocation_id in sorted(
            SYNTHETIC_W24_FANIN_SUPERSEDED_INVOCATION_IDS)}
    production_retained = {
        invocation_id: production_invocations[invocation_id]
        for invocation_id in sorted(
            production_story_members
            - SYNTHETIC_W24_FANIN_SUPERSEDED_INVOCATION_IDS)}
    if (_semantic_digest(production_superseded)
            != SYNTHETIC_W24_SUPERSEDED_RECORDS_SHA256
            or _semantic_digest(production_retained)
            != SYNTHETIC_W24_RETAINED_RECORDS_SHA256):
        raise AssertionError(
            "synthetic complete fixture W24 production evidence mismatch")
    fixture = copy.deepcopy(ledger)
    original_chain_ids = {
        row["chain_id"] for row in ledger["rows"]
        if isinstance(row, dict) and isinstance(row.get("chain_id"), str)}
    fixture["coverage_gaps"] = []
    fixture["scope"]["authoritative_week_range"] = [1, 48]
    fixture["scope"]["authoritative_month_range"] = [1, 12]
    fixture["scope"]["authoritative_row_count"] = 48
    rows_by_family: dict[str, dict[str, Any]] = {}
    fallback_next_verb = next(
        item["reader_id"] for item in fixture["reader_registry"]
        if item["status"] == "active"
        and item["reader_kind"] in NEXT_VERB_READER_KINDS)
    for row in fixture["rows"]:
        rows_by_family.setdefault(row["slot_owner"], row)

    reader_by_id = {item["reader_id"]: item for item in fixture["reader_registry"]}
    proof_by_id = {item["proof_id"]: item
                   for item in fixture["runtime_proof_registry"]}
    month_reader_template = reader_by_id["reader:month:m01:summary"]
    for month in range(7, 13):
        month_reader_id = f"reader:month:m{month:02d}:summary"
        if month_reader_id not in reader_by_id:
            month_reader = copy.deepcopy(month_reader_template)
            month_reader["reader_id"] = month_reader_id
            fixture["reader_registry"].append(month_reader)
            reader_by_id[month_reader_id] = month_reader

    existing = {(row["month"], row["slot_owner"]) for row in fixture["rows"]}
    for month in range(1, 13):
        for family in FAMILIES:
            if (month, family) in existing:
                continue
            clone = copy.deepcopy(rows_by_family[family])
            base_chain_id = clone["chain_id"]
            base_row_proof_id = f"proof:row:{base_chain_id}"
            clone["month"] = month
            clone["chain_id"] = f"selftest_m{month}_{family}"
            if (not clone["terminal_contract"]["repeatable_after_completion"]
                    and not clone["next_verb_by_terminal"]["completed"]):
                clone["next_verb_by_terminal"]["completed"] = [
                    fallback_next_verb]
            if clone["selection_owner"] == "runtime_first_eligible":
                clone["selection_owner"] = "player"
            availability = clone["availability"]
            if _is_int(availability.get("declared_candidate_cap")):
                availability["runtime_candidate_cap"] = \
                    availability["declared_candidate_cap"]
            availability["trigger_min_week"] = None
            availability["trigger_windows_by_bundle"] = {}
            clone["build_facts"] = [
                fact.replace(base_chain_id, clone["chain_id"])
                for fact in clone["build_facts"]]
            for producer_key in ("completion_receipt_ids", "expiry_receipt_ids"):
                clone["producer"][producer_key] = [
                    value.replace(base_chain_id, clone["chain_id"])
                    for value in clone["producer"][producer_key]]
            if family == "people":
                bundle_id = (
                    "sns_pressure_night" if month == 7
                    else f"synthetic_m{month}_people_choice")
                availability["trigger_min_week"] = 1
                availability["trigger_bundle_ids"] = [bundle_id]
                availability["fallback_trigger_bundle_id"] = None
                availability["trigger_windows_by_bundle"] = {
                    bundle_id: {
                        "relative_weeks": [1, 2, 3, 4],
                        "min_relative_week": 1,
                        "max_relative_week": 4,
                    }}
                clone["producer"]["completion_receipt_ids"] = [
                    f"receipt:trigger:{bundle_id}",
                    f"receipt:completed:{bundle_id}",
                ]
                clone["build_facts"] = [
                    f"receipt:completed:{bundle_id}",
                ]
            else:
                availability["trigger_bundle_ids"] = []
                availability["fallback_trigger_bundle_id"] = None
                availability["disable_without_trigger"] = False
                availability["fallback_after_trigger_expiry"] = False
                availability["no_eligible_contract"] = None
                clone["producer"]["completion_receipt_ids"] = [
                    f"receipt:completed:{clone['chain_id']}"]
                clone["build_facts"] = [
                    f"receipt:completed:{clone['chain_id']}"]
            clone["producer"]["expiry_receipt_ids"] = [
                f"receipt:expiry:{clone['chain_id']}"]
            clone["producer"]["repeat_receipt_unique_by"] = []
            clone["producer"]["state_delta_keys"] = [
                f"synthetic_result:{clone['chain_id']}"]
            clone["producer"]["conditional_output_variants"] = []
            clone["producer"]["output_variant_groups"] = []
            clone["producer"]["display_only_output_keys"] = []
            clone["terminal_contract"] = {
                "repeatable_after_completion": False,
                "completed_surface": "replacement",
                "expired_surface": "replacement",
                "reentry_cost": None,
            }
            clone["next_verb_by_terminal"] = {
                "completed": [f"reader:synthetic:next:{clone['chain_id']}"],
                "expired": [f"reader:synthetic:next:{clone['chain_id']}"],
            }
            clone["missed_contract"] = {
                "receipt_ids": [f"receipt:expiry:{clone['chain_id']}"],
                "consequence_ids": [
                    f"synthetic:{clone['chain_id']}:expired"],
                "reader_ids": [f"reader:month:m{month:02d}:summary"],
                "changes_future_availability": False,
            }
            clone["near_reader_ids"] = [f"reader:near:{clone['chain_id']}"]
            clone["milestone_reader_ids"] = [
                f"reader:month:m{month:02d}:summary",
                "reader:chapter1_end_snapshot",
            ]
            new_row_proof_id = f"proof:row:{clone['chain_id']}"
            clone["runtime_proof_ids"] = [
                new_row_proof_id if proof_id == base_row_proof_id else proof_id
                for proof_id in clone["runtime_proof_ids"]]
            for terminal in ("completed", "expired"):
                clone["next_verb_by_terminal"][terminal] = [
                    clone["chain_id"] if verb == base_chain_id else verb
                    for verb in clone["next_verb_by_terminal"][terminal]]

            base_near_reader = reader_by_id[f"reader:near:{base_chain_id}"]
            near_reader = copy.deepcopy(base_near_reader)
            near_reader["reader_id"] = clone["near_reader_ids"][0]
            near_reader["reader_kind"] = "near_consequence"
            near_reader["layer_owner"] = "story"
            near_reader["reads_fact_ids"] = [
                *clone["build_facts"],
                *clone["producer"]["expiry_receipt_ids"],
            ]
            near_reader["history_memory_ids"] = list(
                near_reader["reads_fact_ids"])
            near_reader["material_state_ids"] = []
            near_reader["scene_handoff_fact_ids"] = []
            near_reader["read_contracts"] = [{
                "fact_id": fact_id,
                "runtime_proof_ids": [new_row_proof_id],
            } for fact_id in near_reader["reads_fact_ids"]]
            near_reader["runtime_proof_ids"] = [
                new_row_proof_id if proof_id == base_row_proof_id else proof_id
                for proof_id in near_reader["runtime_proof_ids"]]
            fixture["reader_registry"].append(near_reader)
            reader_by_id[near_reader["reader_id"]] = near_reader

            row_proof = copy.deepcopy(proof_by_id[base_row_proof_id])
            row_proof["proof_id"] = new_row_proof_id
            row_proof["assertion"] = row_proof["assertion"].replace(
                base_chain_id, clone["chain_id"])
            fixture["runtime_proof_registry"].append(row_proof)
            proof_by_id[new_row_proof_id] = row_proof

            base_counter_id = clone["counterfactual_id"]
            base_counter = next(
                item for item in fixture["counterfactual_registry"]
                if item["counterfactual_id"] == base_counter_id)
            counter = copy.deepcopy(base_counter)
            counter["counterfactual_id"] = f"counterfactual:{clone['chain_id']}"
            counter["chain_id"] = clone["chain_id"]
            expected_branches, expected_axes, expected_counter_proofs = (
                _expected_counterfactual_contract(clone, complete=False))
            counter["branch_ids"] = expected_branches
            counter["branch_contracts"] = _synthetic_branch_contracts(
                clone, expected_branches)
            counter["distinguishing_axes"] = expected_axes
            counter["runtime_proof_ids"] = [
                new_row_proof_id if proof_id == base_row_proof_id else proof_id
                for proof_id in expected_counter_proofs]
            clone["counterfactual_id"] = counter["counterfactual_id"]
            fixture["counterfactual_registry"].append(counter)
            fixture["rows"].append(clone)

    for evaluation in fixture["evaluation_registry"]:
        evaluation["status"] = "evaluated"
        evaluation["scope_week_range"] = [1, 48]
        evaluation["debt_ids"] = []
        evaluation["blocker_ids"] = []
    audited_milestone = next(item for item in fixture["milestone_registry"]
                             if item["status"] == "audited_runtime")
    audited_story_reader = next(
        reader_by_id[reader_id] for reader_id in audited_milestone["reader_ids"]
        if reader_by_id[reader_id]["reader_kind"] == "story_milestone")
    audited_milestone_proof = proof_by_id["proof:milestone:w04"]
    for milestone in fixture["milestone_registry"]:
        if milestone["status"] != "audited_runtime":
            week = milestone["week"]
            is_chapter_snapshot = (
                week == 48 and "reader:chapter1_end_snapshot" in reader_by_id)
            milestone_reader = (
                reader_by_id["reader:chapter1_end_snapshot"]
                if is_chapter_snapshot else copy.deepcopy(audited_story_reader))
            if is_chapter_snapshot:
                milestone_reader["status"] = "active"
            else:
                milestone_reader["reader_id"] = (
                    f"reader:milestone:selftest:w{week:02d}")
            invocation_pointer = audited_story_reader["runtime_pointer"]
            milestone_reader["runtime_pointer"] = invocation_pointer
            milestone_proof = copy.deepcopy(audited_milestone_proof)
            milestone_proof["proof_id"] = f"proof:milestone:w{week:02d}"
            milestone_proof["pointer"] = audited_milestone["runtime_pointer"]
            milestone_proof["assertion"] = f"self-test W{week} milestone proof"
            invocation_proof = copy.deepcopy(audited_milestone_proof)
            invocation_proof["proof_id"] = f"proof:invocation:selftest:w{week:02d}"
            invocation_proof["pointer"] = invocation_pointer
            invocation_proof["kind"] = "source_symbol"
            invocation_proof["assertion"] = f"self-test W{week} invocation proof"
            milestone_reader["runtime_proof_ids"] = [invocation_proof["proof_id"]]
            if is_chapter_snapshot:
                snapshot_row = next(
                    row for row in fixture["rows"]
                    if row["month"] == 12
                    and row["slot_owner"] == "advancement")
                snapshot_facts = [
                    snapshot_row["producer"]["completion_receipt_ids"][0],
                    snapshot_row["missed_contract"]["receipt_ids"][0],
                ]
                snapshot_read_proof = {
                    "proof_id": "proof:selftest:read:chapter1_end_snapshot",
                    "kind": "source_symbol",
                    "pointer": invocation_pointer,
                    "assertion": (
                        "self-test chapter-one snapshot consumes "
                        f"{' and '.join(snapshot_facts)}"),
                }
                fixture["runtime_proof_registry"].append(snapshot_read_proof)
                proof_by_id[snapshot_read_proof["proof_id"]] = \
                    snapshot_read_proof
                milestone_reader["reads_fact_ids"] = list(snapshot_facts)
                milestone_reader["history_memory_ids"] = list(snapshot_facts)
                milestone_reader["material_state_ids"] = []
                milestone_reader["scene_handoff_fact_ids"] = []
                milestone_reader["read_contracts"] = [
                    {
                        "fact_id": snapshot_fact,
                        "runtime_proof_ids": [snapshot_read_proof["proof_id"]],
                    }
                    for snapshot_fact in snapshot_facts]
                milestone_reader["input_build_family_ids"] = [
                    snapshot_row["build_family"]]
                milestone_reader["story_decision_ids"] = []
                milestone_reader["scene_handoff_decision_ids"] = []
                milestone_reader["runtime_proof_ids"].append(
                    snapshot_read_proof["proof_id"])
            if not is_chapter_snapshot:
                fixture["reader_registry"].append(milestone_reader)
            fixture["runtime_proof_registry"].append(milestone_proof)
            fixture["runtime_proof_registry"].append(invocation_proof)
            reader_by_id[milestone_reader["reader_id"]] = milestone_reader
            proof_by_id[milestone_proof["proof_id"]] = milestone_proof
            proof_by_id[invocation_proof["proof_id"]] = invocation_proof
            milestone["status"] = "audited_runtime"
            milestone["runtime_pointer"] = audited_milestone["runtime_pointer"]
            milestone["reader_ids"] = [
                milestone_reader["reader_id"],
                f"reader:month:m{week // 4:02d}:summary",
            ]
            milestone["runtime_proof_ids"] = [milestone_proof["proof_id"]]
            invocation_record = {
                "invocation_id": f"invocation:selftest:w{week:02d}",
                "runtime_pointer": invocation_pointer,
                "always_reader_ids": list(milestone["reader_ids"]),
                "conditional_readers": [],
                "exclusive_variant_groups": [],
                "conditional_producers": [],
                "producer_variant_groups": [],
                "runtime_proof_ids": [invocation_proof["proof_id"]],
            }
            milestone["invocations"] = [invocation_record]
            co_presence_record = {
                "group_id": f"group:selftest:w{week:02d}:story",
                "invocation_ids": [invocation_record["invocation_id"]],
                "runtime_proof_ids": [invocation_proof["proof_id"]],
            }
            milestone["co_presence_groups"] = [co_presence_record]
            execution_stage_record = {
                "stage_id": f"stage:selftest:w{week:02d}:story",
                "order_index": 0,
                "applicability_ids": [f"selftest:w{week:02d}"],
                "predecessor_stage_ids": [],
                "invocation_ids": [invocation_record["invocation_id"]],
                "runtime_proof_ids": [invocation_proof["proof_id"]],
            }
            milestone["execution_stages"] = [execution_stage_record]
            invocation_proof["assertion"] = (
                f"self-test W{week} invocation proof "
                f"{_invocation_contract_token(invocation_record)} "
                f"{_co_presence_contract_token(co_presence_record)} "
                f"{_execution_stage_contract_token(execution_stage_record)}")
    def add_synthetic_repair_reader(
            reader_id: str, fact_ids: list[str], *,
            reader_kind: str = "next_verb",
            build_family_ids: list[str] | None = None) -> None:
        proof_id = "proof:synthetic:" + reader_id.removeprefix(
            "reader:synthetic:").replace(":", "_")
        proof = {
            "proof_id": proof_id,
            "kind": "source_symbol",
            "pointer": "systems/DemoCoreLoopV2.gd::_bundle_requirement_met",
            "assertion": f"synthetic complete repair {reader_id}",
        }
        reader = {
            "reader_id": reader_id,
            "reader_kind": reader_kind,
            "layer_owner": READER_LAYER_BY_KIND[reader_kind],
            "status": "active",
            "reads_fact_ids": list(fact_ids),
            "history_memory_ids": list(fact_ids),
            "material_state_ids": [],
            "read_contracts": [{
                "fact_id": fact_id, "runtime_proof_ids": [proof_id],
            } for fact_id in fact_ids],
            "input_build_family_ids": list(build_family_ids or []),
            "story_decision_ids": [],
            "runtime_pointer":
                "systems/DemoCoreLoopV2.gd::_bundle_requirement_met",
            "runtime_proof_ids": [proof_id],
            "scene_handoff_fact_ids": [],
            "scene_handoff_decision_ids": [],
        }
        fixture["runtime_proof_registry"].append(proof)
        fixture["reader_registry"].append(reader)
        proof_by_id[proof_id] = proof
        reader_by_id[reader_id] = reader

    counter_by_prefix_chain = {
        counter["chain_id"]: counter
        for counter in ledger["counterfactual_registry"]}
    for row in ledger["rows"]:
        chain_id = row["chain_id"]
        fixture_row = next(
            item for item in fixture["rows"]
            if item.get("chain_id") == chain_id)
        if (not row["terminal_contract"]["repeatable_after_completion"]
                and not row["next_verb_by_terminal"]["completed"]):
            repaired_next_reader_ids: list[str] = []
            for branch in counter_by_prefix_chain[chain_id]["branch_contracts"]:
                if branch["outcome_kind"] != "completed":
                    continue
                completed_facts = [
                    fact_id for fact_id in branch["produced_fact_ids"]
                    if fact_id.startswith("receipt:completed:")]
                if len(completed_facts) != 1:
                    raise AssertionError(
                        f"synthetic next repair needs one completed receipt: "
                        f"{chain_id}/{branch['branch_id']}")
                bundle_id = completed_facts[0].removeprefix(
                    "receipt:completed:")
                next_reader_id = (
                    f"reader:synthetic:next:{chain_id}:{bundle_id}")
                add_synthetic_repair_reader(
                    next_reader_id,
                    completed_facts,
                    build_family_ids=[row["build_family"]])
                repaired_next_reader_ids.append(next_reader_id)
            fixture_row["next_verb_by_terminal"]["completed"] = \
                repaired_next_reader_ids
        if (row["slot_owner"] == "people"
                and row["selection_owner"] == "runtime_first_eligible"):
            fixture_row["selection_owner"] = "player"
            player_reader_id = (
                f"reader:synthetic:player_choice:{chain_id}")
            add_synthetic_repair_reader(
                player_reader_id,
                [f"state:selection_owner:{chain_id}:player"],
                reader_kind="route_modifier")
            fixture_row["near_reader_ids"].append(player_reader_id)

    m5_people_row = next(
        item for item in fixture["rows"]
        if item.get("chain_id") == "m5_people")
    m5_people_row["availability"]["runtime_candidate_cap"] = \
        m5_people_row["availability"]["declared_candidate_cap"]
    cap_reader_id = "reader:synthetic:m5_people_cap2"
    add_synthetic_repair_reader(
        cap_reader_id, ["state:runtime_candidate_cap:m5_people:2"],
        reader_kind="route_modifier")
    m5_people_row["near_reader_ids"].append(cap_reader_id)

    for row in fixture["rows"]:
        if row["chain_id"] in original_chain_ids:
            continue
        completed_facts = [
            fact_id for fact_id in row["producer"]["completion_receipt_ids"]
            if fact_id.startswith("receipt:completed:")]
        if len(completed_facts) != 1:
            raise AssertionError(
                f"synthetic row needs one completed receipt: "
                f"{row['chain_id']}")
        add_synthetic_repair_reader(
            f"reader:synthetic:next:{row['chain_id']}", completed_facts,
            build_family_ids=[row["build_family"]])

    orphan_debt_facts = next(
        item["debt_ids"] for item in ledger["evaluation_registry"]
        if item["error_code"] == "ORPHAN_FACT")
    for fact_id in orphan_debt_facts:
        owning_rows = [
            row for row in fixture["rows"]
            if row.get("chain_id") in original_chain_ids
            and fact_id in row.get("build_facts", [])]
        owning_families = sorted({
            row["build_family"] for row in owning_rows})
        normalized_fact = re.sub(r"[^A-Za-z0-9_]+", "_", fact_id).strip("_")
        orphan_reader_id = (
            f"reader:synthetic:orphan:{normalized_fact}")
        add_synthetic_repair_reader(
            orphan_reader_id, [fact_id],
            reader_kind="near_consequence",
            build_family_ids=owning_families)
        for owning_row in owning_rows:
            owning_row["near_reader_ids"].append(orphan_reader_id)

    # Repair the executable W16 outcome group itself.  Merely adding four
    # unrelated active readers would leave the source-shadowed invocation in
    # place and is therefore not a debt repair.
    w16 = next(
        milestone for milestone in fixture["milestone_registry"]
        if milestone.get("week") == 16)
    w16_story = next(
        invocation for invocation in w16["invocations"]
        if invocation.get("invocation_id") == "reader:milestone:w16:story")
    w16_group = next(
        group for group in w16_story["exclusive_variant_groups"]
        if group.get("group_id") == "group:w16:inventory_outcome")
    w16_group["causal_status"] = "active"
    w16_group["debt_id"] = None
    for variant in w16_group["variants"]:
        reader_by_id[variant["reader_id"]]["status"] = "active"
    w16_repair_proof_id = "proof:synthetic:w16_inventory_outcome_active"
    w16_repair_proof = {
        "proof_id": w16_repair_proof_id,
        "kind": "source_symbol",
        "pointer": "scenes/StoryMode.gd::_story_memory_condition_matches",
        "assertion": (
            "synthetic active inventory outcome invocation "
            + _invocation_contract_token(w16_story)),
    }
    w16_story["runtime_proof_ids"].append(w16_repair_proof_id)
    fixture["runtime_proof_registry"].append(w16_repair_proof)
    proof_by_id[w16_repair_proof_id] = w16_repair_proof

    # Replace the truthful-but-underidentified generic W24 helper in every
    # executable completion path with the exact seven choice/transition
    # alternatives.  The generic reader remains registry evidence only.
    application_reader_ids: list[str] = []
    for choice_index in (0, 1, 3, 4, 5, 6, 7):
        reader_id = (
            f"reader:synthetic:w24_completion_application_choice:"
            f"{choice_index}")
        choice_fact = (
            "receipt:story_choice:demo_collision:"
            f"v2_demo_first_bill:{choice_index}")
        transition_fact = (
            "receipt:application_transition:demo_collision:"
            f"v2_demo_first_bill:{choice_index}")
        add_synthetic_repair_reader(
            reader_id,
            [choice_fact, transition_fact],
            reader_kind="route_modifier",
            build_family_ids=["build:career_progression"])
        reader_by_id[reader_id]["runtime_pointer"] = (
            "systems/DemoCoreLoopV2.gd::complete_active_bundle")
        for proof_id in reader_by_id[reader_id]["runtime_proof_ids"]:
            proof_by_id[proof_id]["pointer"] = (
                "systems/DemoCoreLoopV2.gd::complete_active_bundle")
        reader_by_id[reader_id]["story_decision_ids"] = [
            f"decision:v2_demo_first_bill:{choice_index}"]
        application_reader_ids.append(reader_id)
    w24 = next(
        milestone for milestone in fixture["milestone_registry"]
        if milestone.get("week") == 24)
    w24["reader_ids"] = [
        reader_id for reader_id in w24["reader_ids"]
        if reader_id != W24_COMPLETION_APPLICATION_READER_ID]
    w24["reader_ids"].extend(application_reader_ids)
    for invocation in w24["invocations"]:
        invocation_id = str(invocation.get("invocation_id", ""))
        if (not invocation_id.startswith(
                "reader:milestone:w24:completion_validation:")
                and invocation_id != (
                    "reader:synthetic:w24:fanin_consumer:"
                    "w24_completion_validation_loaded")):
            continue
        mode = ("loaded" if invocation_id.startswith(
                "reader:synthetic:w24:fanin_consumer:")
                else invocation_id.rsplit(":", 1)[-1])
        invocation["conditional_readers"] = [
            item for item in invocation["conditional_readers"]
            if item.get("reader_id") != W24_COMPLETION_APPLICATION_READER_ID]
        group_id = f"group:synthetic:w24:completion_application:{mode}"
        exclusive_proof_id = (
            "proof:exclusive:" + group_id.replace(":", "_"))
        variants = []
        for choice_index, reader_id in zip(
                (0, 1, 3, 4, 5, 6, 7), application_reader_ids):
            choice_fact = (
                "receipt:story_choice:demo_collision:"
                f"v2_demo_first_bill:{choice_index}")
            transition_fact = (
                "receipt:application_transition:demo_collision:"
                f"v2_demo_first_bill:{choice_index}")
            variants.append({
                "reader_id": reader_id,
                "activation_fact_ids": [choice_fact, transition_fact],
                "runtime_proof_ids": [
                    reader_by_id[reader_id]["runtime_proof_ids"][0],
                    exclusive_proof_id,
                ],
            })
        group = {
            "group_id": group_id,
            "selection_mode": "at_most_one",
            "causal_status": "active",
            "debt_id": None,
            "variants": variants,
        }
        invocation["exclusive_variant_groups"].append(group)
        proof = {
            "proof_id": exclusive_proof_id,
            "kind": "source_symbol",
            "pointer": "systems/DemoCoreLoopV2.gd::complete_active_bundle",
            "assertion": " ".join([
                group_id, "at_most_one",
                *application_reader_ids,
                *[fact_id for variant in variants
                  for fact_id in variant["activation_fact_ids"]],
                _invocation_contract_token(invocation),
            ]),
        }
        invocation["runtime_proof_ids"].append(exclusive_proof_id)
        fixture["runtime_proof_registry"].append(proof)
        proof_by_id[exclusive_proof_id] = proof

    # Promote the authored W27 reader itself and execute it from W28.  A
    # second active clone would leave the blocked registry record unresolved.
    w27_reader = reader_by_id["reader:future:w27:hyunsu_exam_result"]
    w27_reader["status"] = "active"
    w27_reader["runtime_proof_ids"] = [
        proof_id for proof_id in w27_reader["runtime_proof_ids"]
        if proof_id not in {
            "proof:runtime:turn_limit_24", "proof:canon:w25_w48_gap"}]
    w28 = next(
        milestone for milestone in fixture["milestone_registry"]
        if milestone.get("week") == 28)
    w28_invocation = w28["invocations"][0]
    if w27_reader["reader_id"] not in w28["reader_ids"]:
        w28["reader_ids"].append(w27_reader["reader_id"])
    if w27_reader["reader_id"] not in w28_invocation["always_reader_ids"]:
        w28_invocation["always_reader_ids"].append(w27_reader["reader_id"])

    # The forgone repair is an executable reader->future-output edge, and the
    # opening application repair is a single core-owned producer transfer.
    forgone_reader_id = "reader:synthetic:forgone_consumer"
    add_synthetic_repair_reader(
        forgone_reader_id, ["runtime:seoul_cycle:forgone_ids"],
        reader_kind="route_modifier")
    layer_reader_id = "reader:synthetic:opening_application_layer_repair"
    add_synthetic_repair_reader(
        layer_reader_id,
        ["receipt:story_choice:v2_opening_application_send:0"],
        reader_kind="route_modifier",
        build_family_ids=["build:career_progression"])
    w28["reader_ids"].append(forgone_reader_id)
    w28_invocation["always_reader_ids"].append(forgone_reader_id)
    for variant_id, activation_id, outputs, effects, group_id in ((
            "variant:synthetic:w28:forgone_future",
            "runtime:seoul_cycle:forgone_ids",
            ["state:future_availability:forgone_return"],
            ["effect:synthetic:forgone:changes_future_availability"],
            "group:producer:synthetic:w28:forgone_future",
            ),):
        proof_id = "proof:synthetic:" + variant_id.removeprefix(
            "variant:synthetic:").replace(":", "_")
        w28_invocation["conditional_producers"].append({
            "variant_id": variant_id,
            "activation_ids": [activation_id],
            "produced_fact_ids": outputs,
            "effect_contract_ids": effects,
            "runtime_proof_ids": [proof_id],
            "selection_group_id": group_id,
            "activation_roles": {
                "history_memory_ids": [activation_id],
                "material_state_ids": [],
                "scene_handoff_fact_ids": [],
                "story_decision_ids": [],
                "scene_handoff_decision_ids": [],
            },
        })
        w28_invocation["producer_variant_groups"].append({
            "selection_group_id": group_id,
            "selection_mode": "exactly_one",
            "causal_status": "active",
        })
        proof = {
            "proof_id": proof_id,
            "kind": "source_symbol",
            "pointer": "systems/DemoCoreLoopV2.gd::_bundle_requirement_met",
            "assertion": f"synthetic topology producer {variant_id}",
        }
        fixture["runtime_proof_registry"].append(proof)
        proof_by_id[proof_id] = proof

    # Refresh the synthetic W28 invocation proof after its topology changes.
    w28_invocation_proof = proof_by_id[
        w28_invocation["runtime_proof_ids"][0]]
    w28_invocation_proof["assertion"] = (
        "self-test W28 invocation proof "
        + _invocation_contract_token(w28_invocation)
        + " " + _co_presence_contract_token(w28["co_presence_groups"][0])
        + " " + _execution_stage_contract_token(w28["execution_stages"][0]))

    forgone_unlock_id = "reader:synthetic:forgone_future_unlock"
    add_synthetic_repair_reader(
        forgone_unlock_id,
        ["state:future_availability:forgone_return"],
        reader_kind="action_unlock",
        build_family_ids=["build:relationship_initiative"])
    w32 = next(
        milestone for milestone in fixture["milestone_registry"]
        if milestone.get("week") == 32)
    w32_invocation = w32["invocations"][0]
    w32["reader_ids"].append(forgone_unlock_id)
    w32_invocation["always_reader_ids"].append(forgone_unlock_id)
    w32_proof = proof_by_id[w32_invocation["runtime_proof_ids"][0]]
    w32_proof["assertion"] = (
        "self-test W32 invocation proof "
        + _invocation_contract_token(w32_invocation)
        + " " + _co_presence_contract_token(w32["co_presence_groups"][0])
        + " " + _execution_stage_contract_token(w32["execution_stages"][0]))
    m8_people = next(
        row for row in fixture["rows"]
        if row.get("chain_id") == "selftest_m8_people")
    m8_people["near_reader_ids"].append(forgone_unlock_id)

    # Opening application ownership is repaired at the first executable core
    # frontier, before any W4 world/story stage.  It consumes the opening
    # Story choice receipt and is the sole producer of application state.
    w4 = next(
        milestone for milestone in fixture["milestone_registry"]
        if milestone.get("week") == 4)
    opening_invocation_id = (
        "reader:synthetic:w04:opening_application_core_owner")
    opening_group_id = (
        "group:producer:synthetic:w04:opening_application_core_owner")
    opening_proof_id = (
        "proof:synthetic:w04_opening_application_core_owner")
    opening_variant = {
        "variant_id": (
            "variant:synthetic:w04:opening_application_core_owner"),
        "activation_ids": [
            "receipt:story_choice:v2_opening_application_send:0"],
        "produced_fact_ids": [
            "receipt:application:mirae_industrial_tech:submitted",
            "state:application_writer:mirae_industrial_tech:core",
        ],
        "effect_contract_ids": [
            "effect:synthetic:application_writer:core"],
        "runtime_proof_ids": [opening_proof_id],
        "selection_group_id": opening_group_id,
        "activation_roles": {
            "history_memory_ids": [
                "receipt:story_choice:v2_opening_application_send:0"],
            "material_state_ids": [],
            "scene_handoff_fact_ids": [],
            "story_decision_ids": [],
            "scene_handoff_decision_ids": [],
        },
    }
    opening_invocation = {
        "invocation_id": opening_invocation_id,
        "runtime_pointer": (
            "systems/DemoCoreLoopV2.gd::_bundle_requirement_met"),
        "always_reader_ids": [layer_reader_id],
        "conditional_readers": [],
        "exclusive_variant_groups": [],
        "conditional_producers": [opening_variant],
        "producer_variant_groups": [{
            "selection_group_id": opening_group_id,
            "selection_mode": "exactly_one",
            "causal_status": "active",
        }],
        "runtime_proof_ids": [opening_proof_id],
    }
    opening_stage_id = "w04:synthetic_opening_application_core_owner"
    opening_stage = {
        "stage_id": opening_stage_id,
        "order_index": 5,
        "applicability_ids": [
            "receipt:story_choice:v2_opening_application_send:0"],
        "predecessor_stage_ids": [],
        "invocation_ids": [opening_invocation_id],
        "runtime_proof_ids": [opening_proof_id],
    }
    opening_scene_group = {
        "group_id": "group:synthetic:w04:opening_application_core",
        "invocation_ids": [opening_invocation_id],
        "runtime_proof_ids": [opening_proof_id],
    }
    for stage in w4["execution_stages"]:
        if not stage["predecessor_stage_ids"]:
            stage["predecessor_stage_ids"] = [opening_stage_id]
            stage_proof_id = (
                "proof:synthetic:w04_opening_predecessor:"
                + re.sub(r"[^A-Za-z0-9_]+", "_", stage["stage_id"]))
            stage["runtime_proof_ids"].append(stage_proof_id)
            stage_proof = {
                "proof_id": stage_proof_id,
                "kind": "source_symbol",
                "pointer": "systems/DemoCoreLoopV2.gd::_bundle_requirement_met",
                "assertion": _execution_stage_contract_token(stage),
            }
            fixture["runtime_proof_registry"].append(stage_proof)
            proof_by_id[stage_proof_id] = stage_proof
    opening_proof = {
        "proof_id": opening_proof_id,
        "kind": "source_symbol",
        "pointer": "systems/DemoCoreLoopV2.gd::_bundle_requirement_met",
        "assertion": " ".join((
            _invocation_contract_token(opening_invocation),
            _co_presence_contract_token(opening_scene_group),
            _execution_stage_contract_token(opening_stage),
        )),
    }
    w4["reader_ids"].append(layer_reader_id)
    w4["invocations"].insert(0, opening_invocation)
    w4["co_presence_groups"].insert(0, opening_scene_group)
    w4["execution_stages"].insert(0, opening_stage)
    fixture["runtime_proof_registry"].append(opening_proof)
    proof_by_id[opening_proof_id] = opening_proof

    # The exact W24 identity-gate repair above mutates one invocation that is
    # later superseded by the FANIN projection.  The replacement manifest must
    # nevertheless preserve the frozen production object, not that temporary
    # repaired form, as its pre-state evidence.
    w24_before_fanin = next(
        item for item in ledger["milestone_registry"] if item["week"] == 24)
    w24_before_invocations = {
        item["invocation_id"]: item
        for item in w24_before_fanin["invocations"]}
    frozen_superseded_prestate = {
        invocation_id: copy.deepcopy(w24_before_invocations[invocation_id])
        for invocation_id in sorted(
            SYNTHETIC_W24_FANIN_SUPERSEDED_INVOCATION_IDS)}
    w24_fanin_manifest = _apply_synthetic_w24_fanin_replacement(
        fixture, reader_by_id, proof_by_id)
    w24_fanin_manifest["superseded_invocations"] = \
        frozen_superseded_prestate
    w24_fanin_manifest["superseded_digest_at_capture"] = _semantic_digest(
        frozen_superseded_prestate)
    # The loaded completion invocation is created by the FANIN replacement,
    # so wire the already-authored exact seven-way identity gate into that
    # replacement after construction.  Then refresh the immutable post-state
    # snapshot carried only by the Python manifest.
    loaded_completion_invocation = next(
        invocation for invocation in next(
            milestone for milestone in fixture["milestone_registry"]
            if milestone.get("week") == 24)["invocations"]
        if invocation.get("invocation_id") == (
            "reader:synthetic:w24:fanin_consumer:"
            "w24_completion_validation_loaded"))
    loaded_group_id = "group:synthetic:w24:completion_application:loaded"
    loaded_proof_id = "proof:exclusive:" + loaded_group_id.replace(":", "_")
    loaded_variants = []
    for choice_index, reader_id in zip(
            (0, 1, 3, 4, 5, 6, 7), application_reader_ids):
        loaded_variants.append({
            "reader_id": reader_id,
            "activation_fact_ids": [
                "receipt:story_choice:demo_collision:"
                f"v2_demo_first_bill:{choice_index}",
                "receipt:application_transition:demo_collision:"
                f"v2_demo_first_bill:{choice_index}",
            ],
            "runtime_proof_ids": [
                reader_by_id[reader_id]["runtime_proof_ids"][0],
                loaded_proof_id,
            ],
        })
    loaded_group = {
        "group_id": loaded_group_id,
        "selection_mode": "at_most_one",
        "causal_status": "active",
        "debt_id": None,
        "variants": loaded_variants,
    }
    loaded_completion_invocation["exclusive_variant_groups"].append(
        loaded_group)
    loaded_proof = {
        "proof_id": loaded_proof_id,
        "kind": "source_symbol",
        "pointer": "systems/DemoCoreLoopV2.gd::complete_active_bundle",
        "assertion": " ".join([
            loaded_group_id, "at_most_one", *application_reader_ids,
            *[fact_id for variant in loaded_variants
              for fact_id in variant["activation_fact_ids"]],
            _invocation_contract_token(loaded_completion_invocation),
        ]),
    }
    existing_loaded_proof = proof_by_id.get(loaded_proof_id)
    if existing_loaded_proof is None:
        loaded_completion_invocation["runtime_proof_ids"].append(
            loaded_proof_id)
        fixture["runtime_proof_registry"].append(loaded_proof)
        proof_by_id[loaded_proof_id] = loaded_proof
    else:
        existing_loaded_proof.update(loaded_proof)
        if loaded_proof_id not in loaded_completion_invocation[
                "runtime_proof_ids"]:
            loaded_completion_invocation["runtime_proof_ids"].append(
                loaded_proof_id)
    w24_fanin_manifest["replacement_invocations"] = {
        invocation["invocation_id"]: copy.deepcopy(invocation)
        for invocation in next(
            milestone for milestone in fixture["milestone_registry"]
            if milestone.get("week") == 24)["invocations"]
        if str(invocation.get("invocation_id", "")).startswith(
            "reader:synthetic:w24:fanin_")}
    current_w24 = next(
        milestone for milestone in fixture["milestone_registry"]
        if milestone.get("week") == 24)
    current_w24_invocations = {
        invocation["invocation_id"]: invocation
        for invocation in current_w24["invocations"]}
    w24_fanin_manifest["final_fixture_stage_digests"] = {
        stage["stage_id"].removeprefix(
            "w24:synthetic_fanin_aggregate:"):
            _semantic_digest([
                current_w24_invocations[invocation_id]
                for invocation_id in stage["invocation_ids"]
                if invocation_id in current_w24_invocations])
        for stage in current_w24["execution_stages"]
        if stage["stage_id"].startswith(
            "w24:synthetic_fanin_aggregate:")}
    w24_fanin_manifest["production_evidence"] = copy.deepcopy(
        production_evidence)
    # Replace the builder's checked static projection with the independently
    # re-derived production census.  The manifest carries a copy for
    # inspection, while validation below still compares directly to frozen
    # constants and the current replacement graph.
    for key in (
            "source_feasible_tuple_occurrence_count",
            "source_rejected_tuple_occurrence_count",
            "source_stage_tuple_map",
            "source_scenarios_digest"):
        w24_fanin_manifest[key] = copy.deepcopy(production_evidence[key])
    w24_fanin_manifest["source_zero_option_paths"] = \
        production_evidence["source_zero_option_paths"]
    fixed_builder_checks = {
        "production stage tuple map": (
            _semantic_digest(w24_fanin_manifest["stage_tuple_digests"]),
            SYNTHETIC_W24_STAGE_TUPLE_MAP_SHA256),
        "replacement stage tuple map": (
            _semantic_digest(
                w24_fanin_manifest["replacement_stage_tuple_digests"]),
            SYNTHETIC_W24_STAGE_TUPLE_MAP_SHA256),
        "production output multiset": (
            _semantic_digest(
                w24_fanin_manifest["original_output_multisets_by_stage"]),
            SYNTHETIC_W24_ORIGINAL_OUTPUT_MULTISET_SHA256),
        "raw clone records": (
            _semantic_digest(w24_fanin_manifest["raw_clone_records"]),
            SYNTHETIC_W24_RAW_CLONE_RECORDS_SHA256),
        "replacement invocation records": (
            _semantic_digest(w24_fanin_manifest["replacement_invocations"]),
            SYNTHETIC_W24_REPLACEMENT_INVOCATIONS_SHA256),
        "final aggregate stage surface": (
            _semantic_digest(
                w24_fanin_manifest["final_fixture_stage_digests"]),
            SYNTHETIC_W24_FINAL_AGGREGATE_STAGE_SURFACE_SHA256),
    }
    for label, (actual_digest, expected_digest) in fixed_builder_checks.items():
        if actual_digest != expected_digest:
            raise AssertionError(
                f"synthetic W24 {label} differs from frozen production evidence")

    for registry_name in ("replay_witnesses", "counterfactual_registry"):
        for item in fixture[registry_name]:
            item["status"] = "audited_runtime"
    w48_witness = next((item for item in fixture["replay_witnesses"]
                        if item["checkpoint_week"] == 48), None)
    if w48_witness is None:
        w48_witness = copy.deepcopy(fixture["replay_witnesses"][0])
        w48_witness["witness_id"] = "witness:selftest:w48"
        w48_witness["checkpoint_week"] = 48
        fixture["replay_witnesses"].append(w48_witness)
    # Preserve every frozen W1-W24 proof and the real eight-owner save chain.
    # Synthetic completion may add `proof:synthetic:*` evidence for new rows,
    # but never rewrites or deletes prefix history to manufacture a clean run.

    row_by_chain = {row["chain_id"]: row for row in fixture["rows"]}
    counter_by_chain = {
        counter["chain_id"]: counter
        for counter in fixture["counterfactual_registry"]}
    for chain_id, row in row_by_chain.items():
        if chain_id in original_chain_ids:
            continue
        counter = counter_by_chain[chain_id]
        branches, axes, proofs = _expected_counterfactual_contract(
            row, complete=True)
        counter["branch_ids"] = branches
        counter["branch_contracts"] = _synthetic_branch_contracts(
            row, branches)
        counter["distinguishing_axes"] = axes
        counter["runtime_proof_ids"] = proofs

    w48_row = next(
        row for row in fixture["rows"]
        if row["month"] == 12 and row["slot_owner"] == "advancement")
    w48_counter = counter_by_chain[w48_row["chain_id"]]
    w48_milestone = next(
        item for item in fixture["milestone_registry"] if item["week"] == 48)
    w48_witness["route_ids"] = list(w48_counter["branch_ids"][:2])
    w48_witness["distinguishing_axes"] = list(
        w48_counter["distinguishing_axes"])
    w48_witness["reader_ids"] = list(w48_milestone["reader_ids"])
    w48_witness["runtime_proof_ids"] = [
        f"proof:row:{w48_row['chain_id']}", "proof:milestone:w48"]

    # The real save chain remains the same eight proof objects in the same
    # order.  Only its terminal scope sentence changes after this internal
    # fixture has supplied the missing W25-W48 contracts.  Assert the frozen
    # production sentence before the narrow rewrite so a caller cannot use
    # complete-fixture construction to launder any other proof drift.
    normalize_save_proof = proof_by_id[
        "proof:runtime:normalize_core_loop_v2_state"]
    expected_normalize_assertion = (
        NORMALIZE_SAVE_PROOF_PREFIX_ASSERTION
        + NORMALIZE_SAVE_PROOF_COVERAGE_SUFFIX)
    if normalize_save_proof.get("assertion") != expected_normalize_assertion:
        raise AssertionError(
            "synthetic complete fixture requires exact frozen normalize-save "
            "proof assertion")
    normalize_save_proof["assertion"] = (
        NORMALIZE_SAVE_PROOF_PREFIX_ASSERTION
        + NORMALIZE_SAVE_PROOF_COMPLETE_SUFFIX)

    stale_complete_proof_ids = {
        proof["proof_id"]
        for proof in fixture["runtime_proof_registry"]
        if proof.get("proof_id", "").startswith("proof:debt:")
        or proof.get("proof_id") in COMPLETE_STALE_PROOF_IDS}
    fixture["runtime_proof_registry"] = [
        proof for proof in fixture["runtime_proof_registry"]
        if proof.get("proof_id") not in stale_complete_proof_ids]

    def remove_stale_proof_refs(value: Any) -> None:
        if isinstance(value, dict):
            for key, child in value.items():
                if key == "runtime_proof_ids" and isinstance(child, list):
                    value[key] = [
                        proof_id for proof_id in child
                        if proof_id not in stale_complete_proof_ids]
                else:
                    remove_stale_proof_refs(child)
        elif isinstance(value, list):
            for child in value:
                remove_stale_proof_refs(child)

    remove_stale_proof_refs(fixture)
    replacement_readers = {
        reader["reader_id"]: copy.deepcopy(reader)
        for reader in fixture["reader_registry"]
        if str(reader.get("reader_id", "")).startswith(
            "reader:synthetic:w24")}
    replacement_proofs = {
        proof["proof_id"]: copy.deepcopy(proof)
        for proof in fixture["runtime_proof_registry"]
        if str(proof.get("proof_id", "")).startswith(
            "proof:synthetic:w24")}
    if (_semantic_digest(replacement_readers)
            != SYNTHETIC_W24_REPLACEMENT_READER_RECORDS_SHA256
            or _semantic_digest(replacement_proofs)
            != SYNTHETIC_W24_REPLACEMENT_PROOF_RECORDS_SHA256):
        raise AssertionError(
            "synthetic W24 replacement reader/proof trust surface changed")
    w24_fanin_manifest["row_reference_contract"] = copy.deepcopy(
        production_row_reference_contract)
    w24_fanin_manifest["replacement_reader_records"] = replacement_readers
    w24_fanin_manifest["replacement_proof_records"] = replacement_proofs
    prefix_reference_surface = _synthetic_w24_prefix_reference_surface(
        ledger, fixture)
    if (_semantic_digest(prefix_reference_surface)
            != SYNTHETIC_W24_PREFIX_REFERENCE_SURFACE_SHA256):
        raise AssertionError(
            "synthetic W24 prefix row/replay reference surface changed")
    w24_fanin_manifest["prefix_reference_surface"] = \
        prefix_reference_surface
    if return_manifest:
        return fixture, w24_fanin_manifest
    return fixture


def _validate_synthetic_w24_fanin_manifest(
        production_ledger: dict[str, Any], fixture: dict[str, Any],
        manifest: dict[str, Any], *,
        production_evidence: dict[str, Any] | None = None,
        ) -> list[str]:
    """Validate the Python-only W24 replacement against frozen pre-state.

    The complete fixture is deliberately mutable in self-tests.  This
    separate manifest keeps coordinated clone+proof edits from rewriting the
    evidence they are checked against; no JSON field or CLI switch can supply
    or weaken it.
    """
    errors: list[str] = []
    if _semantic_digest(production_ledger) != AUDITED_LEDGER_SEMANTIC_SHA256:
        errors.append(
            "synthetic W24 manifest: production ledger trust root mismatch")
        independently_derived_production: dict[str, Any] = {}
    elif production_evidence is None:
        try:
            independently_derived_production = \
                _derive_synthetic_w24_production_evidence(
                    production_ledger)
        except AssertionError as exc:
            errors.append(
                "synthetic W24 manifest: independent production derivation "
                f"failed: {exc}")
            independently_derived_production = {}
    else:
        # Self-test only: one deep-copied immutable derivation is reused for
        # coordinated fixture/manifest attacks against the exact same audited
        # production bytes.  Production/default CLI never supplies this.
        cache_trust_checks = {
            "production_semantic_digest": AUDITED_LEDGER_SEMANTIC_SHA256,
            "superseded_records_digest":
                SYNTHETIC_W24_SUPERSEDED_RECORDS_SHA256,
            "retained_records_digest": SYNTHETIC_W24_RETAINED_RECORDS_SHA256,
            "source_scenarios_digest": SYNTHETIC_W24_SOURCE_SCENARIOS_SHA256,
            "source_scenario_count": 201,
            "source_stage_tuple_map": SYNTHETIC_W24_SOURCE_TUPLE_STAGE_MAP,
            "source_scenario_feasible_counts_digest":
                SYNTHETIC_W24_SOURCE_SCENARIO_COUNTS_SHA256,
        }
        cache_valid = all(
            production_evidence.get(key) == expected
            for key, expected in cache_trust_checks.items())
        cache_valid = cache_valid and (
            _semantic_digest(production_evidence.get(
                "superseded_invocations"))
            == SYNTHETIC_W24_SUPERSEDED_RECORDS_SHA256)
        cache_valid = cache_valid and (
            _semantic_digest(production_evidence.get(
                "retained_invocations"))
            == SYNTHETIC_W24_RETAINED_RECORDS_SHA256)
        cache_valid = cache_valid and (
            _semantic_digest(production_evidence.get(
                "source_scenario_feasible_counts"))
            == SYNTHETIC_W24_SOURCE_SCENARIO_COUNTS_SHA256)
        if cache_valid:
            independently_derived_production = copy.deepcopy(
                production_evidence)
        else:
            try:
                independently_derived_production = \
                    _derive_synthetic_w24_production_evidence(
                        production_ledger)
            except AssertionError as exc:
                errors.append(
                    "synthetic W24 manifest: cached production evidence "
                    f"invalid and fresh fallback failed: {exc}")
                independently_derived_production = {}
    if manifest.get("production_semantic_digest") != \
            AUDITED_LEDGER_SEMANTIC_SHA256:
        errors.append(
            "synthetic W24 manifest: production semantic digest mismatch")
    expected_superseded = sorted(
        SYNTHETIC_W24_FANIN_SUPERSEDED_INVOCATION_IDS)
    if manifest.get("superseded_invocation_ids") != expected_superseded:
        errors.append(
            "synthetic W24 manifest: superseded invocation allowlist mismatch")
    expected_partition_digest = _semantic_digest({
        "work_and_consequence": sorted(SYNTHETIC_W24_FANIN_WORK_IDS),
        "relationship_obligation": sorted(
            SYNTHETIC_W24_FANIN_RELATIONSHIP_IDS),
        "first_bill_decision_domain": sorted(
            SYNTHETIC_W24_FIRST_BILL_VALUE_BY_ID),
    })
    if manifest.get("partition_digest") != expected_partition_digest:
        errors.append("synthetic W24 manifest: raw partition digest mismatch")
    if manifest.get("raw_id_universe") != sorted(
            SYNTHETIC_W24_FANIN_RAW_ID_UNIVERSE):
        errors.append("synthetic W24 manifest: raw input universe mismatch")
    if manifest.get("feasible_stage_tuple_count") != 1_804:
        errors.append(
            "synthetic W24 manifest: unique stage tuple count must equal 1804")
    if manifest.get("source_feasible_tuple_occurrence_count") != 51_977:
        errors.append(
            "synthetic W24 manifest: source-feasible tuple occurrences must equal 51977")
    if manifest.get("source_rejected_tuple_occurrence_count") != 1_048:
        errors.append(
            "synthetic W24 manifest: rejected tuple occurrences must equal 1048")
    if manifest.get("source_scenarios_digest") != \
            SYNTHETIC_W24_SOURCE_SCENARIOS_SHA256:
        errors.append(
            "synthetic W24 manifest: source scenario digest mismatch")
    if manifest.get("source_stage_tuple_map") != \
            SYNTHETIC_W24_SOURCE_TUPLE_STAGE_MAP:
        errors.append(
            "synthetic W24 manifest: source stage tuple map mismatch")
    if (manifest.get("stage_tuple_digests")
            != SYNTHETIC_W24_STAGE_TUPLE_DIGESTS
            or _semantic_digest(manifest.get("stage_tuple_digests"))
            != SYNTHETIC_W24_STAGE_TUPLE_MAP_SHA256):
        errors.append(
            "synthetic W24 manifest: frozen production tuple digest map mismatch")
    if (manifest.get("replacement_stage_tuple_digests")
            != SYNTHETIC_W24_STAGE_TUPLE_DIGESTS
            or _semantic_digest(
                manifest.get("replacement_stage_tuple_digests"))
            != SYNTHETIC_W24_STAGE_TUPLE_MAP_SHA256):
        errors.append(
            "synthetic W24 manifest: replacement tuple digest map mismatch")
    if (_semantic_digest(manifest.get(
            "original_output_multisets_by_stage"))
            != SYNTHETIC_W24_ORIGINAL_OUTPUT_MULTISET_SHA256):
        errors.append(
            "synthetic W24 manifest: frozen production output/effect surface mismatch")

    production_evidence = manifest.get("production_evidence", {})
    if not isinstance(production_evidence, dict):
        errors.append(
            "synthetic W24 manifest: production evidence must be an object")
        production_evidence = {}
    if production_evidence != independently_derived_production:
        errors.append(
            "synthetic W24 manifest: diagnostic production evidence differs "
            "from independent derivation")
    frozen_production_evidence = {
        "production_semantic_digest": AUDITED_LEDGER_SEMANTIC_SHA256,
        "superseded_records_digest":
            SYNTHETIC_W24_SUPERSEDED_RECORDS_SHA256,
        "retained_records_digest": SYNTHETIC_W24_RETAINED_RECORDS_SHA256,
        "source_scenarios_digest": SYNTHETIC_W24_SOURCE_SCENARIOS_SHA256,
        "source_scenario_count": 201,
        "source_stage_tuple_map": SYNTHETIC_W24_SOURCE_TUPLE_STAGE_MAP,
        "source_feasible_tuple_occurrence_count": 51_977,
        "source_rejected_tuple_occurrence_count": 1_048,
        "source_zero_option_paths": 0,
        "source_scenario_feasible_counts_digest":
            SYNTHETIC_W24_SOURCE_SCENARIO_COUNTS_SHA256,
    }
    for key, expected in frozen_production_evidence.items():
        if production_evidence.get(key) != expected:
            errors.append(
                "synthetic W24 manifest: independently derived production "
                f"evidence mismatch {key}")
    if (_semantic_digest(production_evidence.get(
            "superseded_invocations"))
            != SYNTHETIC_W24_SUPERSEDED_RECORDS_SHA256
            or _semantic_digest(production_evidence.get(
                "retained_invocations"))
            != SYNTHETIC_W24_RETAINED_RECORDS_SHA256):
        errors.append(
            "synthetic W24 manifest: independently derived production record mismatch")

    milestone = next((item for item in fixture.get("milestone_registry", [])
                      if item.get("week") == 24), {})
    production_milestone = next((
        item for item in production_ledger.get("milestone_registry", [])
        if item.get("week") == 24), {})
    invocations = {
        item.get("invocation_id"): item
        for item in milestone.get("invocations", [])
        if isinstance(item, dict) and isinstance(
            item.get("invocation_id"), str)}
    production_invocations = {
        item.get("invocation_id"): item
        for item in production_milestone.get("invocations", [])
        if isinstance(item, dict) and isinstance(
            item.get("invocation_id"), str)}
    executable_readers = {
        reader_id for invocation in invocations.values()
        for reader_id in (
            *invocation.get("always_reader_ids", []),
            *[item.get("reader_id")
              for item in invocation.get("conditional_readers", [])
              if isinstance(item, dict)],
            *[variant.get("reader_id")
              for group in invocation.get("exclusive_variant_groups", [])
              if isinstance(group, dict)
              for variant in group.get("variants", [])
              if isinstance(variant, dict)],
        ) if isinstance(reader_id, str)}
    if set(expected_superseded) & set(invocations):
        errors.append(
            "synthetic W24 manifest: superseded invocation remains executable")

    remaining = manifest.get("remaining_invocations", {})
    if not isinstance(remaining, dict) or len(remaining) != 19:
        errors.append(
            "synthetic W24 manifest: remaining invocation evidence mismatch")
        remaining = {}
    if (_semantic_digest(remaining)
            != SYNTHETIC_W24_REPAIRED_RETAINED_RECORDS_SHA256):
        errors.append(
            "synthetic W24 manifest: retained record digest mismatch")
    for invocation_id, frozen_invocation in remaining.items():
        current = invocations.get(invocation_id)
        if current != frozen_invocation:
            errors.append(
                "synthetic W24 manifest: retained invocation changed "
                f"{invocation_id}")
    production_story_group = next((
        group for group in production_milestone.get("co_presence_groups", [])
        if group.get("group_id") == "group:w24:story_scene"), {})
    production_remaining_ids = (
        set(production_story_group.get("invocation_ids", []))
        - SYNTHETIC_W24_FANIN_SUPERSEDED_INVOCATION_IDS)
    production_remaining = {
        invocation_id: production_invocations.get(invocation_id)
        for invocation_id in sorted(production_remaining_ids)}
    current_remaining = {
        invocation_id: invocations.get(invocation_id)
        for invocation_id in sorted(production_remaining_ids)}
    if (_semantic_digest(production_remaining)
            != SYNTHETIC_W24_RETAINED_RECORDS_SHA256):
        errors.append(
            "synthetic W24 manifest: production remaining19 evidence mismatch")
    if (_semantic_digest(current_remaining)
            != SYNTHETIC_W24_REPAIRED_RETAINED_RECORDS_SHA256):
        errors.append(
            "synthetic W24 manifest: current remaining19 exact repair mismatch")

    superseded = manifest.get("superseded_invocations", {})
    if (not isinstance(superseded, dict)
            or set(superseded) != set(expected_superseded)):
        errors.append(
            "synthetic W24 manifest: superseded invocation evidence mismatch")
        superseded = {}
    if (_semantic_digest(superseded)
            != SYNTHETIC_W24_SUPERSEDED_RECORDS_SHA256):
        errors.append(
            "synthetic W24 manifest: superseded record digest mismatch")
    old_reader_ids = set(manifest.get("superseded_story_reader_ids", []))
    if old_reader_ids & executable_readers:
        errors.append(
            "synthetic W24 manifest: superseded Story reader remains executable")

    raw_readers = {
        reader.get("reader_id"): reader
        for reader in fixture.get("reader_registry", [])
        if isinstance(reader, dict)
        and str(reader.get("reader_id", "")).startswith(
            "reader:synthetic:w24:fanin_raw:")}
    if not raw_readers:
        errors.append("synthetic W24 manifest: raw clone registry is empty")
    frozen_raw_readers = manifest.get("raw_clone_records", {})
    if raw_readers != frozen_raw_readers:
        errors.append(
            "synthetic W24 manifest: raw clone records changed after capture")
    if (_semantic_digest(raw_readers)
            != SYNTHETIC_W24_RAW_CLONE_RECORDS_SHA256
            or _semantic_digest(frozen_raw_readers)
            != SYNTHETIC_W24_RAW_CLONE_RECORDS_SHA256):
        errors.append(
            "synthetic W24 manifest: raw clone frozen contract mismatch")
    for reader_id, reader in raw_readers.items():
        if (reader.get("reader_kind") != "producer_result"
                or reader.get("layer_owner") != "weekly_action"):
            errors.append(
                f"synthetic W24 manifest: raw clone role mismatch {reader_id}")
    production_readers = {
        reader.get("reader_id"): reader
        for reader in production_ledger.get("reader_registry", [])
        if isinstance(reader, dict)
        and isinstance(reader.get("reader_id"), str)}
    allowed_clone_deltas = {
        "reader_id", "reader_kind", "layer_owner", "runtime_pointer",
        "runtime_proof_ids",
    }
    clone_contract_fields = READER_REGISTRY_FIELDS - allowed_clone_deltas
    observed_production_sources: set[str] = set()
    nonproduction_clone_sources: set[str] = set()
    for clone_id, clone in raw_readers.items():
        separator = ":source:"
        source_id = clone_id.split(separator, 1)[1] \
            if separator in clone_id else ""
        source = production_readers.get(source_id)
        if source is None:
            nonproduction_clone_sources.add(source_id)
            continue
        observed_production_sources.add(source_id)
        if any(clone.get(field) != source.get(field)
               for field in clone_contract_fields):
            errors.append(
                "synthetic W24 manifest: raw clone source contract mismatch "
                f"{clone_id}")
        if (clone.get("reader_kind") != "producer_result"
                or clone.get("layer_owner") != "weekly_action"
                or clone.get("runtime_pointer")
                != "systems/DemoCoreLoopV2.gd::_bundle_requirement_met"
                or not set(source.get("runtime_proof_ids", [])).issubset(
                    set(clone.get("runtime_proof_ids", [])))):
            errors.append(
                "synthetic W24 manifest: raw clone allowed delta mismatch "
                f"{clone_id}")
    exact_application_sources = {
        f"reader:synthetic:w24_completion_application_choice:{choice}"
        for choice in (0, 1, 3, 4, 5, 6, 7)}
    if nonproduction_clone_sources != exact_application_sources:
        errors.append(
            "synthetic W24 manifest: raw clone nonproduction source mismatch")
    expected_production_sources = {
        reader_id
        for invocation_id in SYNTHETIC_W24_FANIN_SUPERSEDED_INVOCATION_IDS
        for reader_id in (
            *production_invocations.get(
                invocation_id, {}).get("always_reader_ids", []),
            *[item.get("reader_id") for item in production_invocations.get(
                invocation_id, {}).get("conditional_readers", [])
              if isinstance(item, dict)],
            *[variant.get("reader_id")
              for group in production_invocations.get(
                  invocation_id, {}).get("exclusive_variant_groups", [])
              if isinstance(group, dict)
              for variant in group.get("variants", [])
              if isinstance(variant, dict)],
        ) if isinstance(reader_id, str)}
    expected_production_sources.discard(
        "reader:milestone:w24:completion_application_choice")
    if not expected_production_sources.issubset(observed_production_sources):
        errors.append(
            "synthetic W24 manifest: exact27 raw clone coverage mismatch")

    # Lock every Python-built W24 reader and every synthetic W24 proof.  This
    # closes coordinated edits such as moving a summary reader and its proof
    # to a sibling Story call, or adding a build family to make that summary
    # masquerade as a row-owned causal read.
    replacement_readers = {
        reader.get("reader_id"): reader
        for reader in fixture.get("reader_registry", [])
        if isinstance(reader, dict)
        and str(reader.get("reader_id", "")).startswith(
            "reader:synthetic:w24")}
    replacement_proofs = {
        proof.get("proof_id"): proof
        for proof in fixture.get("runtime_proof_registry", [])
        if isinstance(proof, dict)
        and str(proof.get("proof_id", "")).startswith(
            "proof:synthetic:w24")}
    if (len(replacement_readers) != 402
            or _semantic_digest(replacement_readers)
            != SYNTHETIC_W24_REPLACEMENT_READER_RECORDS_SHA256
            or manifest.get("replacement_reader_records")
            != replacement_readers):
        errors.append(
            "synthetic W24 manifest: replacement reader trust surface mismatch")
    if (len(replacement_proofs) != 395
            or _semantic_digest(replacement_proofs)
            != SYNTHETIC_W24_REPLACEMENT_PROOF_RECORDS_SHA256
            or manifest.get("replacement_proof_records")
            != replacement_proofs):
        errors.append(
            "synthetic W24 manifest: replacement proof trust surface mismatch")
    referenced_proof_ids = _runtime_proof_references(fixture)
    if set(replacement_proofs) - referenced_proof_ids:
        errors.append(
            "synthetic W24 manifest: replacement proof closure is not fully referenced")

    try:
        row_reference_contract = \
            _derive_synthetic_w24_row_reference_contract(
                production_ledger)
    except AssertionError as exc:
        errors.append(
            "synthetic W24 manifest: production row-reference derivation "
            f"failed: {exc}")
        row_reference_contract = {}
    if (_semantic_digest(row_reference_contract)
            != SYNTHETIC_W24_ROW_REFERENCE_CONTRACT_SHA256
            or manifest.get("row_reference_contract")
            != row_reference_contract):
        errors.append(
            "synthetic W24 manifest: frozen row-reference contract mismatch")
    prefix_reference_surface = _synthetic_w24_prefix_reference_surface(
        production_ledger, fixture)
    if (len(prefix_reference_surface.get("rows", {})) != 24
            or len(prefix_reference_surface.get(
                "replay_witnesses", {})) != 3
            or _semantic_digest(prefix_reference_surface)
            != SYNTHETIC_W24_PREFIX_REFERENCE_SURFACE_SHA256
            or manifest.get("prefix_reference_surface")
            != prefix_reference_surface):
        errors.append(
            "synthetic W24 manifest: exact prefix row/replay reference "
            "surface mismatch")
    fixture_rows = {
        row.get("chain_id"): row for row in fixture.get("rows", [])
        if isinstance(row, dict) and isinstance(row.get("chain_id"), str)}
    fixture_witnesses = {
        witness.get("witness_id"): witness
        for witness in fixture.get("replay_witnesses", [])
        if isinstance(witness, dict)
        and isinstance(witness.get("witness_id"), str)}
    for expectation in row_reference_contract.get(
            "owner_expectations", []):
        owner_kind = expectation["owner_kind"]
        owner_id = expectation["owner_id"]
        field_name = expectation["field_name"]
        if owner_kind == "row":
            owner = fixture_rows.get(owner_id, {})
            if field_name == "missed_contract.reader_ids":
                actual_reader_ids = owner.get(
                    "missed_contract", {}).get("reader_ids")
            else:
                actual_reader_ids = owner.get(field_name)
        else:
            owner = fixture_witnesses.get(owner_id, {})
            actual_reader_ids = owner.get(field_name)
        if actual_reader_ids != expectation["reader_ids"]:
            errors.append(
                "synthetic W24 manifest: exact row/replay raw-reader "
                f"mapping mismatch {owner_kind}:{owner_id}:{field_name}")
    replacement_reader_ids = set(replacement_readers)
    summary_reader_ids = {
        reader_id for reader_id, reader in replacement_readers.items()
        if any(str(fact_id).startswith("history_summary:w24:")
               for fact_id in reader.get("reads_fact_ids", []))}
    for owner in [*fixture_rows.values(), *fixture_witnesses.values()]:
        owner_refs = [
            *owner.get("near_reader_ids", []),
            *owner.get("milestone_reader_ids", []),
            *owner.get("reader_ids", []),
            *owner.get("missed_contract", {}).get("reader_ids", []),
        ]
        if summary_reader_ids & set(owner_refs):
            errors.append(
                "synthetic W24 manifest: summary reader used as row/replay "
                "causal ownership")
        unknown_synthetic = {
            reader_id for reader_id in owner_refs
            if str(reader_id).startswith("reader:synthetic:w24")
            and reader_id not in replacement_reader_ids}
        if unknown_synthetic:
            errors.append(
                "synthetic W24 manifest: row/replay references unknown "
                "replacement reader")

    summary_facts = set(SYNTHETIC_W24_FANIN_SUMMARY_FACT_IDS)
    producer_owners: dict[str, list[str]] = {
        fact_id: [] for fact_id in summary_facts}
    resolver_receipts: set[str] = set()
    summary_stage_ids: set[str] = set()
    stages = {
        stage.get("stage_id"): stage
        for stage in milestone.get("execution_stages", [])
        if isinstance(stage, dict) and isinstance(stage.get("stage_id"), str)}
    replacement_stage_records = {
        stage_id: stage for stage_id, stage in stages.items()
        if stage_id.startswith("w24:synthetic_fanin_")}
    replacement_group_records = {
        group.get("group_id"): group
        for group in milestone.get("co_presence_groups", [])
        if isinstance(group, dict)
        and str(group.get("group_id", "")).startswith(
            "group:synthetic:w24:fanin_")}
    if (_semantic_digest(replacement_stage_records)
            != SYNTHETIC_W24_REPLACEMENT_STAGES_SHA256):
        errors.append(
            "synthetic W24 manifest: replacement stage order/predecessor mismatch")
    if (_semantic_digest(replacement_group_records)
            != SYNTHETIC_W24_REPLACEMENT_GROUPS_SHA256):
        errors.append(
            "synthetic W24 manifest: replacement co-presence group mismatch")
    current_replacements = {
        invocation_id: invocation
        for invocation_id, invocation in invocations.items()
        if invocation_id.startswith("reader:synthetic:w24:fanin_")}
    if current_replacements != manifest.get("replacement_invocations"):
        errors.append(
            "synthetic W24 manifest: replacement invocation contract changed")
    if (_semantic_digest(current_replacements)
            != SYNTHETIC_W24_REPLACEMENT_INVOCATIONS_SHA256
            or _semantic_digest(manifest.get("replacement_invocations"))
            != SYNTHETIC_W24_REPLACEMENT_INVOCATIONS_SHA256):
        errors.append(
            "synthetic W24 manifest: replacement invocation frozen contract mismatch")
    current_tuple_digests: dict[str, str] = {}
    for stage_id, stage in stages.items():
        if not stage_id.startswith("w24:synthetic_fanin_aggregate:"):
            continue
        original_stage_id = stage_id.removeprefix(
            "w24:synthetic_fanin_aggregate:")
        invocation_payload = [
            invocations[invocation_id]
            for invocation_id in stage.get("invocation_ids", [])
            if invocation_id in invocations]
        current_tuple_digests[original_stage_id] = _semantic_digest(
            invocation_payload)
    frozen_current_tuple_digests = manifest.get(
        "final_fixture_stage_digests", {})
    if current_tuple_digests != frozen_current_tuple_digests:
        errors.append(
            "synthetic W24 manifest: final fixture stage tuple surface changed")
    if (_semantic_digest(current_tuple_digests)
            != SYNTHETIC_W24_FINAL_AGGREGATE_STAGE_SURFACE_SHA256
            or _semantic_digest(frozen_current_tuple_digests)
            != SYNTHETIC_W24_FINAL_AGGREGATE_STAGE_SURFACE_SHA256):
        errors.append(
            "synthetic W24 manifest: final aggregate stage frozen surface mismatch")
    production_tuple_surface, replacement_tuple_surface, \
        replacement_tuple_count = _derive_synthetic_w24_stage_tuple_surface(
            production_ledger, fixture)
    if (production_tuple_surface
            != SYNTHETIC_W24_PRODUCTION_STAGE_TUPLE_DIGESTS
            or _semantic_digest(production_tuple_surface)
            != SYNTHETIC_W24_PRODUCTION_STAGE_TUPLE_MAP_SHA256):
        errors.append(
            "synthetic W24 manifest: production tuple runtime re-derivation mismatch")
    if (replacement_tuple_surface != SYNTHETIC_W24_STAGE_TUPLE_DIGESTS
            or _semantic_digest(replacement_tuple_surface)
            != SYNTHETIC_W24_STAGE_TUPLE_MAP_SHA256
            or replacement_tuple_count != 1_804):
        errors.append(
            "synthetic W24 manifest: replacement tuple runtime re-derivation mismatch")
    scenario_errors: list[str] = []
    replacement_scenarios = _execution_stage_scenarios(
        week=24, stage_records_by_id=stages,
        where="synthetic W24 replacement stages",
        synthetic_source_contracts=True, errors=scenario_errors)
    if scenario_errors:
        errors.extend(
            "synthetic W24 manifest: " + error
            for error in scenario_errors)
    replacement_presence_keys = {
        f"{scenario_index}:" + stage_id.removeprefix(
            "w24:synthetic_fanin_aggregate:")
        for scenario_index, (scenario_stage_ids, _ancestors) in enumerate(
            replacement_scenarios)
        for stage_id in scenario_stage_ids
        if stage_id.startswith("w24:synthetic_fanin_aggregate:")}
    source_scenario_counts = independently_derived_production.get(
        "source_scenario_feasible_counts", {})
    if (not isinstance(source_scenario_counts, dict)
            or replacement_presence_keys != set(source_scenario_counts)):
        errors.append(
            "synthetic W24 manifest: replacement scenario-stage presence mismatch")
        source_scenario_counts = {}
    # The exact raw-clone bijection, fixed stage/group topology, and A/B tuple
    # equality above establish a one-to-one transfer of each source option.
    # Apply the independently re-derived A multiplicity to B only after those
    # checks, then lock the resulting per-scenario output/effect/decision
    # surface.  A manifest value never participates in this derivation.
    replacement_scenario_semantics = {
        occurrence_key: {
            "occurrences": occurrence_count,
            "stage_tuple_digest": replacement_tuple_surface.get(
                occurrence_key.split(":", 1)[1]),
        }
        for occurrence_key, occurrence_count in sorted(
            source_scenario_counts.items())}
    if (_semantic_digest(replacement_scenario_semantics)
            != SYNTHETIC_W24_REPLACEMENT_SCENARIO_SEMANTICS_SHA256
            or sum(item["occurrences"] for item in
                   replacement_scenario_semantics.values()) != 51_977):
        errors.append(
            "synthetic W24 manifest: scenario-local replacement occurrence mismatch")
    for invocation_id, invocation in invocations.items():
        for producer in invocation.get("conditional_producers", []):
            if not isinstance(producer, dict):
                continue
            outputs = set(producer.get("produced_fact_ids", []))
            for fact_id in summary_facts & outputs:
                producer_owners[fact_id].append(invocation_id)
            resolver_receipts.update(
                fact_id for fact_id in outputs
                if isinstance(fact_id, str)
                and fact_id.startswith(
                    "receipt:synthetic:w24:raw_options_resolved:"))
    for stage_id, stage in stages.items():
        if stage_id.startswith("w24:synthetic_fanin_summary:"):
            summary_stage_ids.add(stage_id)
            predecessors = stage.get("predecessor_stage_ids", [])
            if (len(predecessors) != 1
                    or not predecessors[0].startswith(
                        "w24:synthetic_fanin_aggregate:")):
                errors.append(
                    f"synthetic W24 manifest: summary predecessor mismatch {stage_id}")
    if not resolver_receipts or not summary_stage_ids:
        errors.append(
            "synthetic W24 manifest: resolver/summary lifecycle missing")
    expected_owner_count = len(summary_stage_ids)
    for fact_id, owners in producer_owners.items():
        if len(owners) != expected_owner_count:
            errors.append(
                "synthetic W24 manifest: fixed summary ownership mismatch "
                f"{fact_id}")

    for reader_id in executable_readers:
        reader = next((item for item in fixture.get("reader_registry", [])
                       if isinstance(item, dict)
                       and item.get("reader_id") == reader_id), {})
        raw_story_inputs = (
            set(reader.get("history_memory_ids", []))
            | set(reader.get("story_decision_ids", [])))
        forbidden_raw_story_inputs = (
            raw_story_inputs
            - set(SYNTHETIC_W24_FIRST_BILL_VALUE_BY_ID))
        if (reader_id.startswith(
                "reader:synthetic:w24:fanin_summary")
                and forbidden_raw_story_inputs
                & SYNTHETIC_W24_FANIN_RAW_ID_UNIVERSE):
            errors.append(
                f"synthetic W24 manifest: Story consumer reads raw input {reader_id}")
        for fact_id in reader.get("reads_fact_ids", []):
            if (isinstance(fact_id, str)
                    and fact_id.startswith("history_summary:w24:")
                    and fact_id not in summary_facts):
                errors.append(
                    f"synthetic W24 manifest: third/per-site summary axis {fact_id}")
        if reader_id.startswith("reader:synthetic:w24:fanin_summary"):
            decision_ids = {
                *reader.get("story_decision_ids", []),
                *reader.get("scene_handoff_decision_ids", []),
            }
            if not decision_ids.issubset(
                    set(SYNTHETIC_W24_FIRST_BILL_VALUE_BY_ID)):
                errors.append(
                    "synthetic W24 manifest: second/unknown Story decision domain "
                    f"{reader_id}")
    return errors


def self_test(ledger: dict[str, Any], baseline: dict[str, Any]) -> int:
    global _SELF_TEST_PROBE_COUNT
    global _SELF_TEST_FULL_COUNT
    global _SELF_TEST_FULL_FALLBACK_COUNT
    global _SELF_TEST_PROBE_SECONDS
    global _SELF_TEST_FULL_SECONDS
    _SELF_TEST_PROBE_COUNT = 0
    _SELF_TEST_FULL_COUNT = 0
    _SELF_TEST_FULL_FALLBACK_COUNT = 0
    _SELF_TEST_PROBE_SECONDS = 0.0
    _SELF_TEST_FULL_SECONDS = 0.0

    cases = 0
    errors, metrics = validate(ledger, baseline, check_pointers=True)
    if errors:
        raise AssertionError(f"repository fixture invalid: {errors}")
    if (metrics["implemented"] != 24 or metrics["missing"] != 24
            or metrics["week_range"] != [25, 48] or metrics.get("blocked") != 3):
        raise AssertionError(f"ORDER-100 snapshot counts drifted: {metrics}")
    if {item["error_code"] for item in ledger["evaluation_registry"]} != set(ERROR_CODES):
        raise AssertionError("evaluation registry no longer contains exact 15-code vocabulary")
    if (metrics.get("w24_source_feasible_tuple_occurrences") != 51_977
            or metrics.get("w24_source_rejected_tuple_occurrences") != 1_048
            or metrics.get("w24_source_zero_option_paths") != 0
            or metrics.get("w24_source_tuple_stage_map")
            != SYNTHETIC_W24_SOURCE_TUPLE_STAGE_MAP
            or metrics.get("w24_source_scenario_feasible_counts_digest")
            != SYNTHETIC_W24_SOURCE_SCENARIO_COUNTS_SHA256):
        raise AssertionError(
            "self-test immutable W24 source census baseline drifted")
    source_census_full_count = 1
    source_census_skip_count = 0
    source_census_fallback_count = 0
    cases += 1

    probe_errors, _ = _self_test_validate(
        ledger, baseline, probe=True, pointers=False, sources=False)
    source_census_skip_count += 1
    if probe_errors:
        raise AssertionError(
            f"self-test probe baseline is not clean: {probe_errors}")
    cases += 1

    def milestone_for(fixture: dict[str, Any], week: int) -> dict[str, Any]:
        return next(
            item for item in fixture["milestone_registry"]
            if item["week"] == week)

    def invocation_for(
            fixture: dict[str, Any], week: int,
            invocation_id: str) -> dict[str, Any]:
        return next(
            item for item in milestone_for(fixture, week)["invocations"]
            if item["invocation_id"] == invocation_id)

    def stage_for(
            fixture: dict[str, Any], week: int,
            stage_id: str) -> dict[str, Any]:
        return next(
            item for item in milestone_for(fixture, week)["execution_stages"]
            if item["stage_id"] == stage_id)

    invented_build_fact = copy.deepcopy(ledger)
    inventory_row = next(
        row for row in invented_build_fact["rows"]
        if row["chain_id"] == "m3_livelihood")
    inventory_row["build_facts"].append("fact:inventory_method")
    _expect_failure(
        "invented generic build aggregate", invented_build_fact, baseline,
        "facts outside source producer union", sources=False)
    cases += 1

    if (_fanin_memory_axis("state:flag:lent_account") !=
            _fanin_memory_axis("state:flag:lent_account:false")):
        raise AssertionError(
            "typed boolean branch counted as a second historical memory")
    cases += 1

    def frozen_test_encoding(raw: bytes, *, trailing: bytes = b"") -> str:
        return base64.b64encode(zlib.compress(raw, 9) + trailing).decode(
            "ascii")

    def expect_frozen_failure(
            name: str, encoded: str, raw: bytes, *, count: int,
            digest: str | None = None, length: int | None = None) -> None:
        try:
            _decode_frozen_json(
                encoded, source_name=f"selftest:{name}",
                byte_length=len(raw) if length is None else length,
                sha256=(hashlib.sha256(raw).hexdigest()
                        if digest is None else digest),
                top_level_type=dict, item_count=count)
        except ValueError:
            return
        raise AssertionError(f"frozen JSON {name} mutation passed")

    frozen_raw = b'{"alpha":1,"beta":2}'
    frozen_encoded = frozen_test_encoding(frozen_raw)
    if _decode_frozen_json(
            frozen_encoded, source_name="selftest:valid",
            byte_length=len(frozen_raw),
            sha256=hashlib.sha256(frozen_raw).hexdigest(),
            top_level_type=dict, item_count=2) != {
                "alpha": 1, "beta": 2}:
        raise AssertionError("valid frozen JSON did not expand exactly")
    cases += 1
    expect_frozen_failure(
        "base64 corruption", frozen_encoded[:-1] + "!", frozen_raw,
        count=2)
    cases += 1
    expect_frozen_failure(
        "wrong digest", frozen_encoded, frozen_raw, count=2,
        digest="0" * 64)
    cases += 1
    expect_frozen_failure(
        "wrong byte length", frozen_encoded, frozen_raw, count=2,
        length=len(frozen_raw) + 1)
    cases += 1
    expect_frozen_failure(
        "missing ID", frozen_test_encoding(b'{"alpha":1}'),
        b'{"alpha":1}', count=2)
    cases += 1
    expect_frozen_failure(
        "extra ID", frozen_encoded, frozen_raw, count=1)
    cases += 1
    list_raw = b'[]'
    expect_frozen_failure(
        "wrong top-level type", frozen_test_encoding(list_raw),
        list_raw, count=0)
    cases += 1
    duplicate_raw = b'{"alpha":1,"alpha":2}'
    expect_frozen_failure(
        "duplicate key", frozen_test_encoding(duplicate_raw),
        duplicate_raw, count=1)
    cases += 1
    noncanonical_raw = b'{"beta":2, "alpha":1}'
    expect_frozen_failure(
        "noncanonical re-encode", frozen_test_encoding(noncanonical_raw),
        noncanonical_raw, count=2)
    cases += 1
    expect_frozen_failure(
        "trailing compressed bytes",
        frozen_test_encoding(frozen_raw, trailing=b"junk"), frozen_raw,
        count=2)
    cases += 1
    try:
        _decode_frozen_json(
            frozen_encoded, source_name="selftest:size cap",
            byte_length=FROZEN_JSON_MAX_BYTES + 1,
            sha256=hashlib.sha256(frozen_raw).hexdigest(),
            top_level_type=dict, item_count=2)
    except ValueError:
        pass
    else:
        raise AssertionError("frozen JSON size-cap mutation passed")
    cases += 1

    # Execution-stage arrays are serialization only.  The source contract is
    # the checker-owned scenario set plus order/predecessor DAG, so a forward
    # declaration or array reorder must preserve the same path-local ancestry
    # while incompatible same-order branches may never be unioned.
    scenario_test_week = 999
    scenario_stages = {
        "stage:test:root": {
            "stage_id": "stage:test:root", "order_index": 0,
            "applicability_ids": ["test:root"],
            "predecessor_stage_ids": [], "invocation_ids": ["inv:test:root"],
            "runtime_proof_ids": ["proof:test:root"],
        },
        "stage:test:left": {
            "stage_id": "stage:test:left", "order_index": 10,
            "applicability_ids": ["test:left"],
            "predecessor_stage_ids": ["stage:test:root"],
            "invocation_ids": ["inv:test:left"],
            "runtime_proof_ids": ["proof:test:exclusive"],
        },
        "stage:test:right": {
            "stage_id": "stage:test:right", "order_index": 10,
            "applicability_ids": ["test:right"],
            "predecessor_stage_ids": ["stage:test:root"],
            "invocation_ids": ["inv:test:right"],
            "runtime_proof_ids": ["proof:test:exclusive"],
        },
        "stage:test:join": {
            "stage_id": "stage:test:join", "order_index": 20,
            "applicability_ids": ["test:join"],
            "predecessor_stage_ids": [
                "stage:test:left", "stage:test:right"],
            "invocation_ids": ["inv:test:join"],
            "runtime_proof_ids": ["proof:test:join"],
        },
    }
    prior_scenario_test = EXPECTED_EXECUTION_STAGE_SCENARIOS_BY_WEEK.get(
        scenario_test_week)
    try:
        EXPECTED_EXECUTION_STAGE_SCENARIOS_BY_WEEK[scenario_test_week] = [
            ("stage:test:root", "stage:test:left", "stage:test:join"),
            ("stage:test:root", "stage:test:right", "stage:test:join"),
        ]
        stage_errors: list[str] = []
        forward_declared = dict(reversed(list(scenario_stages.items())))
        stage_paths = _execution_stage_scenarios(
            week=scenario_test_week,
            stage_records_by_id=forward_declared,
            where="selftest.execution_stages",
            synthetic_source_contracts=False,
            errors=stage_errors)
        if stage_errors:
            raise AssertionError(
                f"execution-stage reorder/forward declaration rejected: "
                f"{stage_errors}")
        join_ancestors = [
            ancestors["stage:test:join"] for _scenario, ancestors in stage_paths]
        if ({frozenset(value) for value in join_ancestors}
                != {
                    frozenset({"stage:test:root", "stage:test:left"}),
                    frozenset({"stage:test:root", "stage:test:right"}),
                }):
            raise AssertionError(
                "execution-stage scenarios unioned incompatible ancestors")
        cases += 1

        EXPECTED_EXECUTION_STAGE_SCENARIOS_BY_WEEK[scenario_test_week] = [
            ("stage:test:root", "stage:test:left", "stage:test:right",
             "stage:test:join")]
        illegal_errors: list[str] = []
        _execution_stage_scenarios(
            week=scenario_test_week,
            stage_records_by_id=scenario_stages,
            where="selftest.execution_stages",
            synthetic_source_contracts=False,
            errors=illegal_errors)
        if not any("mutually-exclusive same-order stages coexist" in error
                   for error in illegal_errors):
            raise AssertionError(
                "execution-stage incompatible same-order union passed")
        cases += 1
    finally:
        if prior_scenario_test is None:
            EXPECTED_EXECUTION_STAGE_SCENARIOS_BY_WEEK.pop(
                scenario_test_week, None)
        else:
            EXPECTED_EXECUTION_STAGE_SCENARIOS_BY_WEEK[
                scenario_test_week] = prior_scenario_test

    for duplicate_name, duplicate_payload in (
            ("ledger field", '{"rows":[],"rows":[]}'),
            ("baseline debt code",
             '{"ROW_BIJECTION":[],"ROW_BIJECTION":["slot:m07:self"]}')):
        try:
            _parse_exact_json(duplicate_payload, f"selftest {duplicate_name}")
        except ValueError as exc:
            if "duplicate JSON object key" not in str(exc):
                raise AssertionError(
                    f"duplicate-key guard returned wrong error: {exc}") from exc
        else:
            raise AssertionError(
                f"duplicate-key guard accepted duplicate {duplicate_name}")
        cases += 1

    # A new top-level validation owns a new source-byte snapshot.  Preserve
    # length and mtime across the mutation to prove no metadata-keyed cache
    # can lend the first document to the second validation.
    with tempfile.TemporaryDirectory(prefix="order100-source-snapshot-") as raw_dir:
        source_path = Path(raw_dir) / "source.json"
        source_path.write_bytes(b'{"a":1}')
        first_stat = source_path.stat()
        first_document = _source_json_document(source_path, {})
        source_path.write_bytes(b'{"b":2}')
        os.utime(
            source_path,
            ns=(first_stat.st_atime_ns, first_stat.st_mtime_ns))
        second_document = _source_json_document(source_path, {})
        if first_document != {"a": 1} or second_document != {"b": 2}:
            raise AssertionError(
                "same-length/mtime-preserved source mutation reused stale "
                "snapshot bytes")
    cases += 1

    if any(_repo_source_path(relative_path) is None
           for relative_path in EXPECTED_AUDITED_SOURCE_FILE_SHA256):
        raise AssertionError(
            "audited source hash map contains a non-repo trust key")
    if any(
            _repo_source_path(
                proof["pointer"].split("#/", 1)[0]
                if "#/" in proof["pointer"]
                else proof["pointer"].split("::", 1)[0]) is None
            for proof in ledger["runtime_proof_registry"]):
        raise AssertionError(
            "runtime proof map contains a non-repo trust key")
    cases += 1

    project_text = (ROOT / "project.godot").read_text(encoding="utf-8")
    if _project_autoload_binding_mismatches(project_text):
        raise AssertionError("self-test setup: project autoloads are not exact")
    meta_line = (
        'MetaProgression="*res://autoloads/MetaProgression.gd"')
    duplicated_meta_binding = project_text.replace(
        meta_line, meta_line + "\n"
        'MetaProgression="*res://autoloads/GameState.gd"', 1)
    if "MetaProgression" not in _project_autoload_binding_mismatches(
            duplicated_meta_binding):
        raise AssertionError(
            "project autoload duplicate-wrong-line mutation passed")
    cases += 1

    replay_proof_fixture = {
        f"proof:selftest:replay:{index}": {"pointer": pointer}
        for index, pointer in enumerate(
            sorted(REPLAY_PERSISTENCE_PROOF_POINTERS))}
    replay_record_pointer = (
        "autoloads/MetaProgression.gd::record_scene_replay_snapshot")
    prior_replay_record_body = SOURCE_TEXT_CACHE.get(replay_record_pointer)
    SOURCE_TEXT_CACHE[replay_record_pointer] = (
        "func record_scene_replay_snapshot(_scene_id, _snapshot):\n"
        "\treturn true")
    try:
        replay_errors: list[str] = []
        _validate_replay_persistence_source_contract(
            replay_proof_fixture, replay_errors, {})
        if not any(
                "source handoff markers missing" in error
                and replay_record_pointer in error
                for error in replay_errors):
            raise AssertionError(
                "MetaProgression no-op replay recorder mutation passed")
    finally:
        if prior_replay_record_body is None:
            SOURCE_TEXT_CACHE.pop(replay_record_pointer, None)
        else:
            SOURCE_TEXT_CACHE[replay_record_pointer] = \
                prior_replay_record_body
    cases += 1

    for field in sorted(ROW_FIELDS):
        malformed = copy.deepcopy(ledger)
        malformed["rows"][0].pop(field)
        _expect_failure(f"malformed row missing {field}", malformed, baseline,
                        "schema fields")
        cases += 1
    for container, fields in (
            ("availability", AVAILABILITY_FIELDS),
            ("cost", COST_FIELDS),
            ("producer", PRODUCER_FIELDS),
            ("terminal_contract", TERMINAL_FIELDS),
            ("next_verb_by_terminal", NEXT_VERB_FIELDS),
            ("missed_contract", MISSED_FIELDS),
            ("surface_pointers", SURFACE_FIELDS)):
        for field in sorted(fields):
            malformed = copy.deepcopy(ledger)
            malformed["rows"][0][container].pop(field)
            _expect_failure(f"malformed {container} missing {field}", malformed,
                            baseline, "schema fields")
            cases += 1

    malformed_reader = copy.deepcopy(ledger)
    malformed_reader["reader_registry"][0].pop("read_contracts")
    _expect_failure(
        "reader missing read contracts", malformed_reader, baseline,
        "schema fields")
    cases += 1

    malformed_milestone = copy.deepcopy(ledger)
    malformed_milestone["milestone_registry"][0].pop("invocations")
    _expect_failure(
        "milestone missing invocations", malformed_milestone, baseline,
        "schema fields")
    cases += 1

    malformed_co_presence = copy.deepcopy(ledger)
    malformed_co_presence["milestone_registry"][0].pop("co_presence_groups")
    _expect_failure(
        "milestone missing co-presence groups", malformed_co_presence,
        baseline, "schema fields")
    cases += 1

    reader_with_contract = next(
        item for item in ledger["reader_registry"] if item["read_contracts"])
    malformed_contract = copy.deepcopy(ledger)
    target_reader = next(
        item for item in malformed_contract["reader_registry"]
        if item["reader_id"] == reader_with_contract["reader_id"])
    target_reader["read_contracts"][0].pop("runtime_proof_ids")
    _expect_failure(
        "read contract missing proof field", malformed_contract, baseline,
        "schema fields")
    cases += 1

    malformed_invocation = copy.deepcopy(ledger)
    first_invocation = next(
        invocation
        for milestone in malformed_invocation["milestone_registry"]
        for invocation in milestone["invocations"])
    first_invocation.pop("runtime_proof_ids")
    _expect_failure(
        "invocation missing proof field", malformed_invocation, baseline,
        "schema fields")
    cases += 1

    duplicate = copy.deepcopy(ledger)
    duplicate["rows"].append(copy.deepcopy(duplicate["rows"][0]))
    _expect_failure("duplicate", duplicate, baseline, "ROW_BIJECTION")
    cases += 1

    stale_pointer = copy.deepcopy(ledger)
    stale_pointer["rows"][0]["runtime_pointer"] = "content/meta/does_not_exist.json#/x"
    _expect_failure("stale pointer", stale_pointer, baseline, "stale pointer",
                    pointers=True)
    cases += 1

    orphan = copy.deepcopy(ledger)
    orphan_id = orphan["rows"][0]["near_reader_ids"][0]
    orphan["reader_registry"] = [item for item in orphan["reader_registry"]
                                  if item.get("reader_id") != orphan_id]
    _expect_failure("orphan", orphan, baseline, "ORPHAN_FACT")
    cases += 1

    shadowed = copy.deepcopy(ledger)
    active_reader = next(item for item in shadowed["reader_registry"]
                         if item["status"] == "active")
    active_reader["status"] = "shadowed"
    _expect_failure("shadowed", shadowed, baseline, "SHADOWED_READER")
    cases += 1

    no_gap = copy.deepcopy(ledger)
    no_gap["coverage_gaps"] = []
    _expect_failure("coverage gap", no_gap, baseline, "coverage_gaps")
    cases += 1

    gap_hole = copy.deepcopy(ledger)
    gap_hole["coverage_gaps"][0]["month_range"] = [7, 11]
    _expect_failure("coverage gap hole", gap_hole, baseline,
                    "does not exactly cover missing slots")
    cases += 1

    no_blocker = copy.deepcopy(ledger)
    for evaluation in no_blocker["evaluation_registry"]:
        if evaluation["status"] == "blocked_by_coverage":
            evaluation["blocker_ids"] = []
            break
    _expect_failure("blocked without blocker", no_blocker, baseline, "needs blocker")
    cases += 1

    for blocked_code in sorted(BLOCKED_WHILE_COVERAGE_OPEN):
        false_full = copy.deepcopy(ledger)
        for evaluation in false_full["evaluation_registry"]:
            if evaluation["error_code"] == blocked_code:
                evaluation["status"] = "evaluated"
                evaluation["blocker_ids"] = []
        _expect_failure(f"false full evaluation {blocked_code}", false_full,
                        baseline, "coverage exists but evaluation claims full scope")
        cases += 1

    missing_evaluation = copy.deepcopy(ledger)
    missing_evaluation["evaluation_registry"].pop()
    _expect_failure("missing evaluation", missing_evaluation, baseline,
                    "missing error codes")
    cases += 1

    duplicate_evaluation = copy.deepcopy(ledger)
    duplicate_evaluation["evaluation_registry"].append(
        copy.deepcopy(duplicate_evaluation["evaluation_registry"][0]))
    _expect_failure("duplicate evaluation", duplicate_evaluation, baseline,
                    "duplicate error code")
    cases += 1

    invalid_evaluation = copy.deepcopy(ledger)
    invalid_evaluation["evaluation_registry"][0]["status"] = "assumed_green"
    _expect_failure("invalid evaluation state", invalid_evaluation, baseline,
                    "invalid status")
    cases += 1

    extra_blocked = copy.deepcopy(ledger)
    for evaluation in extra_blocked["evaluation_registry"]:
        if evaluation["error_code"] == "FAKE_REPEAT":
            evaluation["status"] = "blocked_by_coverage"
            evaluation["blocker_ids"] = [ledger["coverage_gaps"][0]["gap_id"]]
    _expect_failure("extra blocked code", extra_blocked, baseline,
                    "only the three full-run evaluations")
    cases += 1

    stale_baseline = copy.deepcopy(baseline)
    first_code = next(iter(stale_baseline))
    stale_baseline[first_code] = sorted(stale_baseline[first_code] + ["selftest:stale"])
    _expect_failure("stale baseline", ledger, stale_baseline, "baseline exact mismatch")
    cases += 1

    new_debt = copy.deepcopy(ledger)
    for evaluation in new_debt["evaluation_registry"]:
        if evaluation["status"] == "evaluated" and not evaluation["debt_ids"]:
            evaluation["debt_ids"] = ["selftest:new"]
            break
    _expect_failure("new debt", new_debt, baseline, "baseline exact mismatch")
    cases += 1

    _expect_failure("malformed baseline", ledger, [], "baseline: expected object")
    cases += 1
    unknown_baseline = copy.deepcopy(baseline)
    unknown_baseline["NOT_A_CODE"] = ["selftest:unknown"]
    _expect_failure("unknown baseline code", ledger, unknown_baseline,
                    "unknown error codes")
    cases += 1
    unsorted_baseline = copy.deepcopy(baseline)
    sortable_code = next(code for code, ids in unsorted_baseline.items() if len(ids) > 1)
    unsorted_baseline[sortable_code] = list(reversed(unsorted_baseline[sortable_code]))
    _expect_failure("unsorted baseline", ledger, unsorted_baseline,
                    "IDs must be sorted")
    cases += 1
    empty_baseline = copy.deepcopy(baseline)
    empty_baseline["FAKE_REPEAT"] = []
    _expect_failure("empty baseline debt", ledger, empty_baseline,
                    "must not be empty")
    cases += 1

    target_shrink = copy.deepcopy(ledger)
    target_shrink["scope"]["target_row_count"] = 24
    _expect_failure("target shrink", target_shrink, baseline,
                    "scope.target_row_count")
    cases += 1
    authority_lie = copy.deepcopy(ledger)
    authority_lie["scope"]["authoritative_row_count"] += 1
    _expect_failure("authority lie", authority_lie, baseline,
                    "scope.authoritative_row_count")
    cases += 1

    duplicate_registry = copy.deepcopy(ledger)
    duplicate_registry["reader_registry"].append(
        copy.deepcopy(duplicate_registry["reader_registry"][0]))
    _expect_failure("duplicate registry", duplicate_registry, baseline,
                    "duplicate registry ID")
    cases += 1

    auto_owner = copy.deepcopy(ledger)
    auto_row = next(row for row in auto_owner["rows"]
                    if row["slot_owner"] == "people"
                    and row["selection_owner"] == "runtime_first_eligible")
    auto_row["selection_owner"] = "player"
    _expect_failure("auto person derivation", auto_owner, baseline,
                    "AUTO_PERSON_PICK")
    cases += 1

    nonpeople_auto = copy.deepcopy(ledger)
    nonpeople_auto_baseline = copy.deepcopy(baseline)
    nonpeople_row = next(
        row for row in nonpeople_auto["rows"]
        if row["slot_owner"] != "people"
        and row["selection_owner"] == "runtime_first_eligible")
    nonpeople_debt = (
        f"row:{nonpeople_row['chain_id']}:selection_owner")
    nonpeople_eval = next(
        item for item in nonpeople_auto["evaluation_registry"]
        if item["error_code"] == "AUTO_PERSON_PICK")
    nonpeople_eval["debt_ids"].append(nonpeople_debt)
    nonpeople_eval["debt_ids"].sort()
    nonpeople_auto_baseline["AUTO_PERSON_PICK"].append(nonpeople_debt)
    nonpeople_auto_baseline["AUTO_PERSON_PICK"].sort()
    _expect_failure(
        "non-person multi-route is not auto-person debt", nonpeople_auto,
        nonpeople_auto_baseline,
        "debt IDs do not equal runtime-first-eligible people rows")
    cases += 1

    dead_card = copy.deepcopy(ledger)
    dead_row = next(row for row in dead_card["rows"]
                    if not row["terminal_contract"]["repeatable_after_completion"]
                    and not row["next_verb_by_terminal"]["completed"])
    dead_row["next_verb_by_terminal"]["completed"] = [
        dead_card["reader_registry"][0]["reader_id"]]
    _expect_failure(
        "dead card arbitrary reader", dead_card, baseline,
        "is not an active next verb/action unlock")
    cases += 1

    dead_self_loop = copy.deepcopy(ledger)
    self_loop_row = next(
        row for row in dead_self_loop["rows"]
        if not row["terminal_contract"]["repeatable_after_completion"]
        and not row["next_verb_by_terminal"]["completed"])
    self_loop_row["next_verb_by_terminal"]["completed"] = [
        self_loop_row["chain_id"]]
    _expect_failure(
        "dead card self loop", dead_self_loop, baseline,
        "non-repeatable terminal may not loop to itself")
    cases += 1

    cap_gap = copy.deepcopy(ledger)
    cap_row = next(row for row in cap_gap["rows"]
                   if _is_int(row["availability"].get("declared_candidate_cap"))
                   and _is_int(row["availability"].get("runtime_candidate_cap"))
                   and row["availability"]["declared_candidate_cap"]
                   > row["availability"]["runtime_candidate_cap"])
    cap_row["availability"]["runtime_candidate_cap"] = \
        cap_row["availability"]["declared_candidate_cap"]
    _expect_failure("unreachable cap derivation", cap_gap, baseline,
                    "UNREACHABLE_CAP")
    cases += 1

    fake_repeat = copy.deepcopy(ledger)
    repeat_row = next(row for row in fake_repeat["rows"]
                      if row["terminal_contract"]["repeatable_after_completion"])
    repeat_row["producer"]["repeat_receipt_unique_by"] = []
    _expect_failure("fake repeat derivation", fake_repeat, baseline, "FAKE_REPEAT")
    cases += 1

    counterfactual = copy.deepcopy(ledger)
    counter_id = counterfactual["rows"][0]["counterfactual_id"]
    counterfactual["counterfactual_registry"] = [
        item for item in counterfactual["counterfactual_registry"]
        if item["counterfactual_id"] != counter_id]
    _expect_failure("counterfactual registry", counterfactual, baseline,
                    "COUNTERFACTUAL_NOOP")
    cases += 1

    save_proof = copy.deepcopy(ledger)
    proof_id = save_proof["rows"][0]["runtime_proof_ids"][0]
    save_proof["runtime_proof_registry"] = [
        item for item in save_proof["runtime_proof_registry"]
        if item["proof_id"] != proof_id]
    _expect_failure("save proof registry", save_proof, baseline,
                    "SAVE_ROUNDTRIP")
    cases += 1

    fanin = copy.deepcopy(ledger)
    story_reader = next(item for item in fanin["reader_registry"]
                        if item["reader_kind"] == "story_milestone")
    story_reader["input_build_family_ids"] = list(BUILD_FAMILY_BY_SLOT.values())[:3]
    _expect_failure("milestone fanin", fanin, baseline, "MILESTONE_FANIN")
    cases += 1

    for code, needle in (
            ("UNSCHEDULED_CHAIN", "UNSCHEDULED_CHAIN"),
            ("LAYER_COLLISION", "LAYER_COLLISION"),
            ("DISPLAY_ONLY_FORGONE", "DISPLAY_ONLY_FORGONE")):
        source_debt = copy.deepcopy(ledger)
        for evaluation in source_debt["evaluation_registry"]:
            if evaluation["error_code"] == code:
                evaluation["debt_ids"] = []
        source_baseline = copy.deepcopy(baseline)
        source_baseline.pop(code)
        _expect_failure(f"source debt {code}", source_debt, source_baseline, needle)
        cases += 1

    for field in ("branch_ids", "distinguishing_axes", "runtime_proof_ids"):
        empty_counterfactual = copy.deepcopy(ledger)
        empty_counterfactual["counterfactual_registry"][0][field] = []
        _expect_failure(
            f"counterfactual empty {field}", empty_counterfactual, baseline,
            f"counterfactual_registry[0].{field}: must not be empty")
        cases += 1

    wrong_counterfactual = copy.deepcopy(ledger)
    wrong_counterfactual["rows"][0]["counterfactual_id"] = \
        wrong_counterfactual["rows"][1]["counterfactual_id"]
    _expect_failure(
        "counterfactual wrong row", wrong_counterfactual, baseline,
        "counterfactual chain mismatch")
    cases += 1

    unnamed_milestone = copy.deepcopy(ledger)
    named_story_reader = next(
        item for item in unnamed_milestone["reader_registry"]
        if item["reader_kind"] == "story_milestone"
        and item["input_build_family_ids"])
    named_story_reader["reads_fact_ids"] = []
    _expect_failure(
        "story milestone unnamed build input", unnamed_milestone, baseline,
        "MILESTONE_FANIN")
    cases += 1

    blocked_orphan = copy.deepcopy(ledger)
    blocked_reader = next(
        item for item in blocked_orphan["reader_registry"]
        if item["status"] == "blocked_by_coverage")
    blocked_reader["reads_fact_ids"].append("fact:resume_polished")
    blocked_orphan_baseline = copy.deepcopy(baseline)
    blocked_orphan_baseline.pop("ORPHAN_FACT")
    for evaluation in blocked_orphan["evaluation_registry"]:
        if evaluation["error_code"] == "ORPHAN_FACT":
            evaluation["debt_ids"] = []
    _expect_failure(
        "blocked reader cannot clear orphan", blocked_orphan,
        blocked_orphan_baseline, "ORPHAN_FACT")
    cases += 1

    unrelated_milestone = copy.deepcopy(ledger)
    audited = next(item for item in unrelated_milestone["milestone_registry"]
                   if item["status"] == "audited_runtime")
    audited["runtime_pointer"] = \
        "systems/DemoCoreLoopV2.gd::_seoul_cycle_month_summary_payload"
    _expect_failure(
        "unrelated milestone pointer", unrelated_milestone, baseline,
        "runtime pointer must match proof:milestone:w04")
    cases += 1

    trigger_drift = copy.deepcopy(ledger)
    trigger_drift["rows"][0]["availability"]["trigger_bundle_ids"].append(
        "selftest:bogus_trigger")
    _expect_failure(
        "runtime trigger mirror", trigger_drift, baseline,
        "trigger_bundle_ids: runtime mirror expected")
    cases += 1

    repeat_drift = copy.deepcopy(ledger)
    repeat_drift["rows"][0]["terminal_contract"][
        "repeatable_after_completion"] = not repeat_drift["rows"][0][
            "terminal_contract"]["repeatable_after_completion"]
    _expect_failure(
        "runtime repeat mirror", repeat_drift, baseline,
        "repeatable_after_completion: runtime mirror expected")
    cases += 1

    effect_drift = copy.deepcopy(ledger)
    effect_drift["rows"][0]["cost"]["effect_pointers"].append(
        "content/meta/demo_core_loop_v2.json#/scope")
    _expect_failure(
        "runtime effect mirror", effect_drift, baseline,
        "effect_pointers: runtime mirror expected")
    cases += 1

    action_proof_drift = copy.deepcopy(ledger)
    action_reader = next(
        item for item in action_proof_drift["reader_registry"]
        if item["status"] == "active"
        and item["reader_kind"] in CAUSAL_READER_KINDS
        and any(fact.startswith("receipt:action:")
                for fact in item["reads_fact_ids"]))
    action_fact = next(
        fact for fact in action_reader["reads_fact_ids"]
        if fact.startswith("receipt:action:"))
    fake_summary_proof = {
        "proof_id": "proof:selftest:fake_action_summary",
        "kind": "source_symbol",
        "pointer": "systems/DemoCoreLoopV2.gd::_seoul_cycle_month_summary_payload",
        "assertion": f"Fake display claims to read {action_fact}.",
    }
    action_proof_drift["runtime_proof_registry"].append(fake_summary_proof)
    action_contract = next(
        contract for contract in action_reader["read_contracts"]
        if contract["fact_id"] == action_fact)
    action_contract["runtime_proof_ids"] = [fake_summary_proof["proof_id"]]
    _expect_failure(
        "action fact backed only by month summary", action_proof_drift,
        baseline, "no runtime proof directly binds fact")
    cases += 1

    read_bijection = copy.deepcopy(ledger)
    read_bijection_reader = next(
        item for item in read_bijection["reader_registry"]
        if item["read_contracts"])
    read_bijection_reader["read_contracts"].pop()
    _expect_failure(
        "read contract bijection", read_bijection, baseline,
        "must exactly cover reads_fact_ids")
    cases += 1

    producer_masks_orphan = copy.deepcopy(ledger)
    orphan_evaluation = next(
        item for item in producer_masks_orphan["evaluation_registry"]
        if item["error_code"] == "ORPHAN_FACT")
    producer_orphan_id = next(
        debt_id for debt_id in orphan_evaluation["debt_ids"]
        if debt_id.startswith("receipt:action:"))
    producer_reader = next(
        item for item in producer_masks_orphan["reader_registry"]
        if item["reader_kind"] in {"producer_result", "near_outcome"})
    producer_proof = {
        "proof_id": "proof:selftest:producer_result_read",
        "kind": "source_symbol",
        "pointer": "scenes/MainGame.gd::recover_action_result",
        "assertion": f"Producer result immediately displays {producer_orphan_id}.",
    }
    producer_masks_orphan["runtime_proof_registry"].append(producer_proof)
    producer_reader["reads_fact_ids"].append(producer_orphan_id)
    producer_reader["read_contracts"].append({
        "fact_id": producer_orphan_id,
        "runtime_proof_ids": [producer_proof["proof_id"]],
    })
    orphan_evaluation["debt_ids"].remove(producer_orphan_id)
    producer_baseline = copy.deepcopy(baseline)
    producer_baseline["ORPHAN_FACT"].remove(producer_orphan_id)
    _expect_failure(
        "producer result cannot clear orphan", producer_masks_orphan,
        producer_baseline, "ORPHAN_FACT")
    cases += 1

    invocation_milestone = next(
        milestone for milestone in ledger["milestone_registry"]
        if milestone["status"] == "audited_runtime" and milestone["invocations"])
    invocation_member_missing = copy.deepcopy(ledger)
    missing_milestone = next(
        milestone for milestone in invocation_member_missing["milestone_registry"]
        if milestone["milestone_id"] == invocation_milestone["milestone_id"])
    missing_invocation = next(
        invocation for invocation in missing_milestone["invocations"]
        if invocation["always_reader_ids"])
    missing_invocation["always_reader_ids"].pop()
    _expect_failure(
        "invocation missing member", invocation_member_missing, baseline,
        "membership must exactly cover reader_ids")
    cases += 1

    duplicate_invocation_member = copy.deepcopy(ledger)
    audited_with_multiple = next(
        milestone for milestone in duplicate_invocation_member["milestone_registry"]
        if milestone["status"] == "audited_runtime"
        and len(milestone["invocations"]) >= 2
        and any(invocation["always_reader_ids"]
                for invocation in milestone["invocations"]))
    source_invocation = next(
        invocation for invocation in audited_with_multiple["invocations"]
        if invocation["always_reader_ids"])
    target_invocation = next(
        invocation for invocation in audited_with_multiple["invocations"]
        if invocation is not source_invocation)
    first_member = source_invocation["always_reader_ids"][0]
    target_invocation["always_reader_ids"].append(first_member)
    target_invocation_id = target_invocation["invocation_id"]
    target_invocation_proof = next(
        proof for proof in duplicate_invocation_member[
            "runtime_proof_registry"]
        if proof["proof_id"] in target_invocation["runtime_proof_ids"]
        and f"invocation_contract:{target_invocation_id}|" in
        proof["assertion"])
    target_invocation_proof["assertion"] = _invocation_contract_token(
        target_invocation)
    prior_target_digest = EXPECTED_INVOCATION_CONTRACT_DIGESTS[
        target_invocation_id]
    try:
        # Synchronize the frozen topology for this structural fixture so the
        # intended path-local rule, rather than a generic map mismatch, is
        # what rejects co-present reuse.  The canonical baseline probe above
        # proves the same reader identity may be reused by mutually-exclusive
        # call sites.
        EXPECTED_INVOCATION_CONTRACT_DIGESTS[target_invocation_id] = \
            _semantic_digest(target_invocation)
        duplicate_errors, _ = _self_test_validate(
            duplicate_invocation_member, baseline, probe=True,
            sources=False)
        if not any(
                "belongs to multiple coexisting call-site invocations" in error
                for error in duplicate_errors):
            raise AssertionError(
                "duplicate invocation membership: scenario-local duplicate "
                f"diagnostic missing: {duplicate_errors}")
    finally:
        EXPECTED_INVOCATION_CONTRACT_DIGESTS[target_invocation_id] = \
            prior_target_digest
    cases += 1

    activation_empty = copy.deepcopy(ledger)
    activation_record = next(
        condition
        for milestone in activation_empty["milestone_registry"]
        for invocation in milestone["invocations"]
        for condition in (
            invocation["conditional_readers"]
            + [variant
               for group in invocation["exclusive_variant_groups"]
               for variant in group["variants"]]))
    activation_record["activation_fact_ids"] = []
    _expect_failure(
        "empty invocation activation", activation_empty, baseline,
        "activation_fact_ids: must not be empty")
    cases += 1

    activation_proof_empty = copy.deepcopy(ledger)
    activation_proof_record = next(
        condition
        for milestone in activation_proof_empty["milestone_registry"]
        for invocation in milestone["invocations"]
        for condition in (
            invocation["conditional_readers"]
            + [variant
               for group in invocation["exclusive_variant_groups"]
               for variant in group["variants"]]))
    activation_proof_record["runtime_proof_ids"] = []
    _expect_failure(
        "missing invocation activation proof", activation_proof_empty,
        baseline, "runtime_proof_ids: must not be empty")
    cases += 1

    false_exclusive = copy.deepcopy(ledger)
    exclusive_group = next(
        group
        for milestone in false_exclusive["milestone_registry"]
        for invocation in milestone["invocations"]
        for group in invocation["exclusive_variant_groups"])
    exclusive_group["selection_mode"] = (
        "exactly_one" if exclusive_group["selection_mode"] == "at_most_one"
        else "at_most_one")
    _expect_failure(
        "false exclusive selection mode", false_exclusive, baseline,
        "variants lack common proof binding group/mode")
    cases += 1

    conditional_as_exclusive = copy.deepcopy(ledger)
    mixed_invocation = next(
        invocation
        for milestone in conditional_as_exclusive["milestone_registry"]
        for invocation in milestone["invocations"]
        if invocation["conditional_readers"]
        and invocation["exclusive_variant_groups"])
    moved_condition = mixed_invocation["conditional_readers"].pop()
    mixed_invocation["exclusive_variant_groups"][0]["variants"].append(
        moved_condition)
    _expect_failure(
        "independent condition falsely made exclusive",
        conditional_as_exclusive, baseline,
        "variants lack common proof binding group/mode")
    cases += 1

    split_invocation = copy.deepcopy(ledger)
    split_milestone = next(
        milestone for milestone in split_invocation["milestone_registry"]
        if any(invocation["invocation_id"]
               == "reader:milestone:w24:candidate_aggregation"
               for invocation in milestone["invocations"]))
    original_invocation = next(
        invocation for invocation in split_milestone["invocations"]
        if invocation["invocation_id"]
        == "reader:milestone:w24:candidate_aggregation")
    split_copy = copy.deepcopy(original_invocation)
    split_copy["invocation_id"] += ":split"
    split_copy["always_reader_ids"] = []
    split_copy["exclusive_variant_groups"] = []
    midpoint = max(1, len(original_invocation["conditional_readers"]) // 2)
    split_copy["conditional_readers"] = original_invocation[
        "conditional_readers"][midpoint:]
    original_invocation["conditional_readers"] = original_invocation[
        "conditional_readers"][:midpoint]
    split_milestone["invocations"].append(split_copy)
    _expect_failure(
        "runtime invocation split to hide fanin", split_invocation, baseline,
        "invocation proof does not bind exact reader structure")
    cases += 1

    split_co_presence = copy.deepcopy(ledger)
    split_group_milestone = next(
        milestone for milestone in split_co_presence["milestone_registry"]
        if any(group["group_id"] == "group:w24:story_scene"
               for group in milestone["co_presence_groups"]))
    story_group = next(
        group for group in split_group_milestone["co_presence_groups"]
        if group["group_id"] == "group:w24:story_scene")
    split_story_group = copy.deepcopy(story_group)
    split_story_group["group_id"] += ":split"
    group_midpoint = len(story_group["invocation_ids"]) // 2
    split_story_group["invocation_ids"] = story_group[
        "invocation_ids"][group_midpoint:]
    story_group["invocation_ids"] = story_group["invocation_ids"][:group_midpoint]
    split_group_milestone["co_presence_groups"].append(split_story_group)
    _expect_failure(
        "co-present scene split across groups to hide fanin",
        split_co_presence, baseline,
        "proof does not bind exact co-presence structure")
    cases += 1

    duplicate_co_presence = copy.deepcopy(ledger)
    duplicate_group_milestone = next(
        milestone for milestone in duplicate_co_presence["milestone_registry"]
        if len(milestone["co_presence_groups"]) >= 2)
    duplicate_invocation_id = duplicate_group_milestone[
        "co_presence_groups"][0]["invocation_ids"][0]
    duplicate_group_milestone["co_presence_groups"][1][
        "invocation_ids"].append(duplicate_invocation_id)
    _expect_failure(
        "duplicate co-presence invocation membership",
        duplicate_co_presence, baseline,
        "duplicate invocation membership")
    cases += 1

    missing_co_presence_proof = copy.deepcopy(ledger)
    next(
        group for milestone in missing_co_presence_proof["milestone_registry"]
        for group in milestone["co_presence_groups"])["runtime_proof_ids"] = []
    _expect_failure(
        "missing co-presence proof", missing_co_presence_proof, baseline,
        "runtime_proof_ids: must not be empty")
    cases += 1

    blocked_invocation_reader = copy.deepcopy(ledger)
    blocked_milestone = next(
        milestone for milestone in blocked_invocation_reader["milestone_registry"]
        if milestone["status"] == "audited_runtime" and milestone["invocations"])
    blocked_reader_id = next(
        reader_id
        for invocation in blocked_milestone["invocations"]
        for reader_id in (
            invocation["always_reader_ids"]
            + [item["reader_id"] for item in invocation["conditional_readers"]]
            + [variant["reader_id"]
               for group in invocation["exclusive_variant_groups"]
               for variant in group["variants"]]))
    next(item for item in blocked_invocation_reader["reader_registry"]
         if item["reader_id"] == blocked_reader_id)["status"] = \
        "blocked_by_coverage"
    _expect_failure(
        "blocked reader in audited invocation", blocked_invocation_reader,
        baseline, "is not active")
    cases += 1

    repeat_without_effect = copy.deepcopy(ledger)
    real_repeat_row = next(
        row for row in repeat_without_effect["rows"]
        if row["terminal_contract"]["repeatable_after_completion"])
    real_repeat_row["cost"]["effect_pointers"] = []
    _expect_failure(
        "repeat without real effect", repeat_without_effect, baseline,
        "FAKE_REPEAT")
    cases += 1

    shuffled_rows = copy.deepcopy(ledger)
    shuffled_rows["rows"][0], shuffled_rows["rows"][1] = \
        shuffled_rows["rows"][1], shuffled_rows["rows"][0]
    _expect_failure(
        "canonical row order", shuffled_rows, baseline,
        "rows must use exact month/slot-owner canonical order")
    cases += 1

    unknown_reader_kind = copy.deepcopy(ledger)
    unknown_reader_kind["reader_registry"][0]["reader_kind"] = \
        "selftest_unknown"
    _expect_failure(
        "unknown reader kind", unknown_reader_kind, baseline,
        "reader_kind: unknown reader kind")
    cases += 1

    wrong_reader_layer = copy.deepcopy(ledger)
    wrong_reader_layer["reader_registry"][0]["layer_owner"] = "story"
    _expect_failure(
        "wrong reader layer", wrong_reader_layer, baseline,
        "layer_owner: expected summary")
    cases += 1

    invented_blocked_reader = copy.deepcopy(ledger)
    blocked = next(
        reader for reader in invented_blocked_reader["reader_registry"]
        if reader["status"] == "blocked_by_coverage")
    blocked["reads_fact_ids"] = ["fact:selftest_invented"]
    blocked["read_contracts"] = [{
        "fact_id": "fact:selftest_invented",
        "runtime_proof_ids": ["proof:runtime:save_roundtrip_prefix"],
    }]
    blocked["runtime_proof_ids"] = ["proof:runtime:save_roundtrip_prefix"]
    _expect_failure(
        "blocked reader invents facts", invented_blocked_reader, baseline,
        "blocked reader must not invent runtime facts or proof")
    cases += 1

    substring_symbol = copy.deepcopy(ledger)
    substring_proof = next(
        proof for proof in substring_symbol["runtime_proof_registry"]
        if proof["kind"] == "source_symbol")
    substring_proof["pointer"] = "systems/DemoCoreLoopV2.gd::GameState"
    _expect_failure(
        "source pointer substring is not a symbol", substring_symbol,
        baseline, "stale exact GDScript symbol", pointers=True)
    cases += 1

    mismatched_proof_kind = copy.deepcopy(ledger)
    next(proof for proof in mismatched_proof_kind["runtime_proof_registry"]
         if proof["kind"] == "source_symbol")["kind"] = "canon_anchor"
    _expect_failure(
        "proof kind pointer mismatch", mismatched_proof_kind, baseline,
        "kind does not match pointer form")
    cases += 1

    hidden_auto_pick = copy.deepcopy(ledger)
    hidden_auto_baseline = copy.deepcopy(baseline)
    hidden_auto_row = next(
        row for row in hidden_auto_pick["rows"]
        if row["slot_owner"] == "people"
        and row["selection_owner"] == "runtime_first_eligible")
    hidden_auto_debt = f"row:{hidden_auto_row['chain_id']}:selection_owner"
    hidden_auto_row["selection_owner"] = "player"
    next(item for item in hidden_auto_pick["evaluation_registry"]
         if item["error_code"] == "AUTO_PERSON_PICK")["debt_ids"].remove(
             hidden_auto_debt)
    hidden_auto_baseline["AUTO_PERSON_PICK"].remove(hidden_auto_debt)
    _expect_failure(
        "selection owner cannot be relabeled", hidden_auto_pick,
        hidden_auto_baseline, "does not mirror runtime selection owner")
    cases += 1

    hidden_cap_gap = copy.deepcopy(ledger)
    hidden_cap_baseline = copy.deepcopy(baseline)
    hidden_cap_row = next(
        row for row in hidden_cap_gap["rows"]
        if _is_int(row["availability"].get("declared_candidate_cap"))
        and row["availability"]["declared_candidate_cap"]
        > row["availability"]["runtime_candidate_cap"])
    hidden_cap_debt = (
        f"row:{hidden_cap_row['chain_id']}:declared_cap_"
        f"{hidden_cap_row['availability']['declared_candidate_cap']}")
    hidden_cap_row["availability"]["runtime_candidate_cap"] = \
        hidden_cap_row["availability"]["declared_candidate_cap"]
    next(item for item in hidden_cap_gap["evaluation_registry"]
         if item["error_code"] == "UNREACHABLE_CAP")["debt_ids"].remove(
             hidden_cap_debt)
    hidden_cap_baseline["UNREACHABLE_CAP"].remove(hidden_cap_debt)
    _expect_failure(
        "runtime cap cannot be relabeled", hidden_cap_gap,
        hidden_cap_baseline, "runtime_candidate_cap: source cap mismatch")
    cases += 1

    hidden_shadow = copy.deepcopy(ledger)
    hidden_shadow_baseline = copy.deepcopy(baseline)
    hidden_shadow_reader = next(
        reader for reader in hidden_shadow["reader_registry"]
        if reader["status"] == "shadowed")
    hidden_shadow_id = hidden_shadow_reader["reader_id"]
    hidden_shadow_reader["status"] = "active"
    next(item for item in hidden_shadow["evaluation_registry"]
         if item["error_code"] == "SHADOWED_READER")["debt_ids"].remove(
             hidden_shadow_id)
    hidden_shadow_baseline["SHADOWED_READER"].remove(hidden_shadow_id)
    _expect_failure(
        "shadowed reader cannot be relabeled", hidden_shadow,
        hidden_shadow_baseline,
        "inventory outcome reader remains source-shadowed")
    cases += 1

    hidden_dead_card = copy.deepcopy(ledger)
    hidden_dead_baseline = copy.deepcopy(baseline)
    hidden_dead_row = next(
        row for row in hidden_dead_card["rows"]
        if not row["terminal_contract"]["repeatable_after_completion"]
        and not row["next_verb_by_terminal"]["completed"])
    unrelated_next_reader = next(
        reader["reader_id"] for reader in hidden_dead_card["reader_registry"]
        if reader["status"] == "active"
        and reader["reader_kind"] in NEXT_VERB_READER_KINDS)
    hidden_dead_row["next_verb_by_terminal"]["completed"] = [
        unrelated_next_reader]
    hidden_dead_debt = f"row:{hidden_dead_row['chain_id']}:completed"
    next(item for item in hidden_dead_card["evaluation_registry"]
         if item["error_code"] == "DEAD_CARD")["debt_ids"].remove(
             hidden_dead_debt)
    hidden_dead_baseline["DEAD_CARD"].remove(hidden_dead_debt)
    _expect_failure(
        "dead card cannot use unrelated next verb", hidden_dead_card,
        hidden_dead_baseline, "source transition mismatch")
    cases += 1

    source_template_drift = copy.deepcopy(ledger)
    source_template_drift["rows"][0]["producer"][
        "allocation_receipt_id_template"] = "selftest_invented_{week_index}"
    _expect_failure(
        "producer allocation template source drift", source_template_drift,
        baseline, "source template mismatch")
    cases += 1

    source_completion_drift = copy.deepcopy(ledger)
    source_completion_drift["rows"][0]["producer"][
        "completion_receipt_ids"].append("receipt:selftest:invented")
    _expect_failure(
        "producer completion source drift", source_completion_drift,
        baseline, "completion_receipt_ids: source outputs mismatch")
    cases += 1

    source_expiry_drift = copy.deepcopy(ledger)
    source_expiry_drift["rows"][0]["producer"]["expiry_receipt_ids"] = [
        "receipt:expiry:selftest_invented"]
    _expect_failure(
        "producer expiry source drift", source_expiry_drift, baseline,
        "expiry_receipt_ids: source output mismatch")
    cases += 1

    source_state_drift = copy.deepcopy(ledger)
    source_state_drift["rows"][0]["producer"]["state_delta_keys"].append(
        "selftest_invented")
    _expect_failure(
        "producer state source drift", source_state_drift, baseline,
        "state_delta_keys: source effects mismatch")
    cases += 1

    conditional_family_cases = (
        ("job_hunt", "m1_resume", "resume_quality"),
        ("aruba", "m2_livelihood", "aruba_runtime_result"),
        ("activity_task", "m3_livelihood", "activity_task_outcome"),
        ("recovery", "m6_self", "recovery_effects"),
    )
    for family, chain_id, group_suffix in conditional_family_cases:
        missing_family = copy.deepcopy(ledger)
        family_row = next(
            row for row in missing_family["rows"]
            if row["chain_id"] == chain_id)
        family_group = next(
            group for group in family_row["producer"][
                "output_variant_groups"]
            if group["selection_group_id"].endswith(group_suffix))
        family_group_id = family_group["selection_group_id"]
        family_row["producer"]["output_variant_groups"].remove(
            family_group)
        family_row["producer"]["conditional_output_variants"] = [
            variant for variant in family_row["producer"][
                "conditional_output_variants"]
            if variant["selection_group_id"] != family_group_id]
        _expect_failure(
            f"conditional action family omitted {family}", missing_family,
            baseline, "authored producer graph mismatch")
        cases += 1

    fixed_family_cases = (
        ("m2_advancement", "m2_seorin_application", "application"),
        ("m4_livelihood", "m4_logistics_shift", "instant_effect"),
        ("m2_self", "m2_sleep_debt_sunday", "default_rest"),
        ("m1_father", "father_first_call", "story_only"),
    )
    source_recovery_row = next(
        row for row in ledger["rows"] if row["chain_id"] == "m6_self")
    source_recovery_group = source_recovery_row["producer"][
        "output_variant_groups"][0]
    source_recovery_variant = source_recovery_row["producer"][
        "conditional_output_variants"][0]
    for chain_id, bundle_id, family in fixed_family_cases:
        invented_family = copy.deepcopy(ledger)
        fixed_row = next(
            row for row in invented_family["rows"]
            if row["chain_id"] == chain_id)
        invented_group = copy.deepcopy(source_recovery_group)
        invented_group_id = (
            f"group:producer:{chain_id}:{bundle_id}:recovery_effects")
        invented_group["selection_group_id"] = invented_group_id
        invented_variant = copy.deepcopy(source_recovery_variant)
        invented_variant["variant_id"] = (
            f"variant:{chain_id}:{bundle_id}:recovery_effects:invented")
        invented_variant["selection_group_id"] = invented_group_id
        invented_variant["activation_ids"][0] = f"bundle:{bundle_id}"
        fixed_row["producer"]["output_variant_groups"].append(
            invented_group)
        fixed_row["producer"]["conditional_output_variants"].append(
            invented_variant)
        _expect_failure(
            f"conditional group injected into fixed {family}",
            invented_family, baseline,
            f"fixed {family} path {bundle_id}")
        cases += 1

    rain_formula_swap = copy.deepcopy(ledger)
    rain_row = next(
        row for row in rain_formula_swap["rows"]
        if row["chain_id"] == "m2_livelihood")
    rain_variant = next(
        variant for variant in rain_row["producer"][
            "conditional_output_variants"]
        if "aruba_runtime_result" in variant["variant_id"])
    convenience_variant = next(
        variant for row in ledger["rows"]
        if row["chain_id"] == "m1_convenience"
        for variant in row["producer"]["conditional_output_variants"]
        if "aruba_runtime_result" in variant["variant_id"])
    rain_variant["effect_contract_ids"] = copy.deepcopy(
        convenience_variant["effect_contract_ids"])
    _expect_failure(
        "rain Aruba formula swapped with convenience", rain_formula_swap,
        baseline, "authored producer graph mismatch")
    cases += 1

    recovery_activation_swap = copy.deepcopy(ledger)
    recovery_row = next(
        row for row in recovery_activation_swap["rows"]
        if row["chain_id"] == "m5_self")
    recovery_variants = [
        variant for variant in recovery_row["producer"][
            "conditional_output_variants"]
        if "recovery_effects" in variant["variant_id"]]
    recovery_variants[0]["activation_ids"], recovery_variants[1][
        "activation_ids"] = (
            recovery_variants[1]["activation_ids"],
            recovery_variants[0]["activation_ids"])
    _expect_failure(
        "recovery normal diminished activation swapped",
        recovery_activation_swap, baseline,
        "authored producer graph mismatch")
    cases += 1

    hanbit_transition_omission = copy.deepcopy(ledger)
    hanbit_row = next(
        row for row in hanbit_transition_omission["rows"]
        if row["chain_id"] == "m4_advancement")
    hanbit_transition = next(
        fact_id for fact_id in hanbit_row["producer"][
            "completion_receipt_ids"]
        if fact_id.startswith("receipt:application_transition:"))
    hanbit_row["producer"]["completion_receipt_ids"].remove(
        hanbit_transition)
    _expect_failure(
        "mixed Hanbit transition omitted while Story remains",
        hanbit_transition_omission, baseline,
        "completion_receipt_ids: source outputs mismatch")
    cases += 1

    nested_group_omission = copy.deepcopy(ledger)
    nested_counter = next(
        item for item in nested_group_omission["counterfactual_registry"]
        if item["chain_id"] == "m4_advancement")
    nested_branch = next(
        item for item in nested_counter["branch_contracts"]
        if item["branch_id"] == "m4_advancement:m4_hanbit_interview")
    nested_branch["nested_output_group_ids"] = []
    _expect_failure(
        "weekly branch omits its nested Story output group",
        nested_group_omission, baseline,
        "nested_output_group_ids: source-owned nested group mismatch")
    cases += 1

    unrelated_nested_group = copy.deepcopy(ledger)
    unrelated_counter = next(
        item for item in unrelated_nested_group["counterfactual_registry"]
        if item["chain_id"] == "m4_advancement")
    unrelated_branch = next(
        item for item in unrelated_counter["branch_contracts"]
        if item["branch_id"] == "m4_advancement:m4_hanbit_interview")
    unrelated_group_id = next(
        group["selection_group_id"]
        for row in unrelated_nested_group["rows"]
        if row["chain_id"] == "m3_livelihood"
        for group in row["producer"]["output_variant_groups"])
    unrelated_branch["nested_output_group_ids"] = [unrelated_group_id]
    _expect_failure(
        "weekly branch cannot borrow another row output group",
        unrelated_nested_group, baseline,
        "nested_output_group_ids: group is not row-local")
    cases += 1

    nested_activation_omission = copy.deepcopy(ledger)
    nested_activation_row = next(
        row for row in nested_activation_omission["rows"]
        if row["chain_id"] == "m4_advancement")
    nested_activation_variant = next(
        variant for variant in nested_activation_row["producer"][
            "conditional_output_variants"]
        if variant["selection_group_id"].endswith(
            ":m4_hanbit_interview:v2_hanbit_interview"))
    nested_activation_variant["activation_ids"].remove(
        "bundle:m4_hanbit_interview")
    _expect_failure(
        "nested output variant omits weekly bundle activation",
        nested_activation_omission, baseline,
        "nested_output_group_ids: variant is not activated by branch bundle")
    cases += 1

    sibling_output_union = copy.deepcopy(ledger)
    sibling_counter = next(
        item for item in sibling_output_union["counterfactual_registry"]
        if item["chain_id"] == "m4_advancement")
    sibling_branch = next(
        item for item in sibling_counter["branch_contracts"]
        if item["branch_id"] == "m4_advancement:m4_hanbit_interview")
    sibling_branch["produced_fact_ids"].append(
        "receipt:application_transition:m4_hanbit_interview:"
        "v2_hanbit_interview:0")
    _expect_failure(
        "weekly branch cannot union one exclusive Story sibling",
        sibling_output_union, baseline,
        "mutually exclusive sibling output was laundered into weekly branch")
    cases += 1

    nested_group_mode = copy.deepcopy(ledger)
    nested_mode_row = next(
        row for row in nested_group_mode["rows"]
        if row["chain_id"] == "m4_advancement")
    next(
        group for group in nested_mode_row["producer"][
            "output_variant_groups"]
        if group["selection_group_id"].endswith(
            ":m4_hanbit_interview:v2_hanbit_interview"))[
                "selection_mode"] = "at_most_one"
    _expect_failure(
        "nested Story root group mode cannot be weakened",
        nested_group_mode, baseline,
        "authored exclusivity graph mismatch")
    cases += 1

    cross_layer_branch_split = copy.deepcopy(ledger)
    split_counter = next(
        item for item in cross_layer_branch_split[
            "counterfactual_registry"]
        if item["chain_id"] == "m4_advancement")
    split_index = split_counter["branch_ids"].index(
        "m4_advancement:m4_hanbit_interview")
    original_contract = next(
        item for item in split_counter["branch_contracts"]
        if item["branch_id"] == "m4_advancement:m4_hanbit_interview")
    split_contracts = []
    for choice_index in (0, 1):
        clone = copy.deepcopy(original_contract)
        clone["branch_id"] = (
            "m4_advancement:m4_hanbit_interview:choice:"
            f"{choice_index}")
        clone["applicability_ids"].append(
            f"story_choice:v2_hanbit_interview:{choice_index}")
        clone["nested_output_group_ids"] = []
        split_contracts.append(clone)
    original_index = split_counter["branch_contracts"].index(
        original_contract)
    split_counter["branch_contracts"][
        original_index:original_index + 1] = split_contracts
    split_counter["branch_ids"][split_index:split_index + 1] = [
        item["branch_id"] for item in split_contracts]
    _expect_failure(
        "Story choice cannot split the weekly counterfactual route",
        cross_layer_branch_split, baseline,
        "branch IDs do not mirror row contract")
    cases += 1

    realized_hanbit_row = next(
        row for row in ledger["rows"]
        if row["chain_id"] == "m4_advancement")
    realized_hanbit_counter = next(
        item for item in ledger["counterfactual_registry"]
        if item["chain_id"] == "m4_advancement")
    realized_hanbit_branch = next(
        item for item in realized_hanbit_counter["branch_contracts"]
        if item["branch_id"] == "m4_advancement:m4_hanbit_interview")
    realized_hanbit_sets = _branch_realized_fact_sets(
        realized_hanbit_row, realized_hanbit_branch, {})
    hanbit_transition_facts = {
        "receipt:application_transition:m4_hanbit_interview:"
        "v2_hanbit_interview:0",
        "receipt:application_transition:m4_hanbit_interview:"
        "v2_hanbit_interview:1",
    }
    if (not realized_hanbit_sets
            or not all(len(set(facts) & hanbit_transition_facts) == 1
                       for facts in realized_hanbit_sets)
            or set().union(*(set(facts) & hanbit_transition_facts
                             for facts in realized_hanbit_sets))
            != hanbit_transition_facts):
        raise AssertionError(
            "nested Hanbit choices were collapsed instead of enumerated")
    cases += 1

    follow_up_row = next(
        row for row in ledger["rows"] if row["chain_id"] == "m2_people")
    follow_up_counter = next(
        item for item in ledger["counterfactual_registry"]
        if item["chain_id"] == "m2_people")
    follow_up_branch = next(
        item for item in follow_up_counter["branch_contracts"]
        if item["branch_id"] == "m2_people:cafe_world_glimpse")
    follow_up_sets = _branch_realized_fact_sets(
        follow_up_row, follow_up_branch, {})
    follow_up_edge: tuple[str, int, str] | None = None
    for parent_id, parent_event, _is_root in _bundle_story_choice_graph(
            "cafe_world_glimpse", {}):
        choices = parent_event.get("choices", [])
        if not isinstance(choices, list):
            continue
        for choice_index, choice in enumerate(choices):
            child_id = choice.get("follow_up_event") \
                if isinstance(choice, dict) else None
            if (isinstance(child_id, str) and child_id
                    and not _choice_is_expression(choice)):
                follow_up_edge = (parent_id, choice_index, child_id)
                break
        if follow_up_edge is not None:
            break
    if follow_up_edge is None:
        raise AssertionError("cafe graph lost its authored follow-up edge")
    parent_id, parent_choice_index, child_id = follow_up_edge
    parent_fact = (
        "receipt:story_choice:cafe_world_glimpse:"
        f"{parent_id}:{parent_choice_index}")
    child_prefix = (
        "receipt:story_choice:cafe_world_glimpse:"
        f"{child_id}:")
    child_histories = [
        facts for facts in follow_up_sets
        if any(fact.startswith(child_prefix) for fact in facts)]
    if (not child_histories
            or any(parent_fact not in facts for facts in child_histories)):
        raise AssertionError(
            "nested Story follow-up escaped its source parent choice")
    cases += 1
    entered_without_child = [
        facts for facts in follow_up_sets
        if parent_fact in facts
        and not any(fact.startswith(child_prefix) for fact in facts)]
    if entered_without_child:
        raise AssertionError(
            "nested Story follow-up allowed parent entry without a child choice")
    cases += 1

    identical_realized_siblings = copy.deepcopy(ledger)
    identical_counter = next(
        counter for counter in identical_realized_siblings[
            "counterfactual_registry"]
        if counter["chain_id"] == "m4_people")
    identical_left, identical_right = identical_counter[
        "branch_contracts"][:2]
    right_branch_id = identical_right["branch_id"]
    identical_right.clear()
    identical_right.update(copy.deepcopy(identical_left))
    identical_right["branch_id"] = right_branch_id
    _expect_failure(
        "identical realized sibling routes derive a no-op debt",
        identical_realized_siblings, baseline,
        "COUNTERFACTUAL_NOOP: debt IDs do not equal identical realized branch pairs")
    cases += 1

    overlapping_realized_siblings = copy.deepcopy(ledger)
    overlapping_counter = next(
        counter for counter in overlapping_realized_siblings[
            "counterfactual_registry"]
        if counter["chain_id"] == "m2_people")
    cafe_contract = next(
        contract for contract in overlapping_counter["branch_contracts"]
        if contract["branch_id"] == "m2_people:cafe_world_glimpse")
    overlapping_other = next(
        contract for contract in overlapping_counter["branch_contracts"]
        if contract is not cafe_contract
        and contract["outcome_kind"] == "completed")
    other_branch_id = overlapping_other["branch_id"]
    overlapping_other.clear()
    overlapping_other.update(copy.deepcopy(cafe_contract))
    overlapping_other["branch_id"] = other_branch_id
    # Removing a conditional follow-up leaves a strict subset of cafe
    # histories.  Their shared histories must still count as a no-op pair.
    overlapping_other["nested_output_group_ids"].pop(1)
    _expect_failure(
        "one distinct history cannot hide an overlapping no-op sibling",
        overlapping_realized_siblings, baseline,
        "COUNTERFACTUAL_NOOP: debt IDs do not equal identical realized branch pairs")
    cases += 1

    route_row = next(
        row for row in ledger["rows"] if row["chain_id"] == "m4_people")
    route_counter = next(
        counter for counter in ledger["counterfactual_registry"]
        if counter["chain_id"] == "m4_people")
    route_readers = {
        reader["reader_id"]: copy.deepcopy(reader)
        for reader in ledger["reader_registry"]}
    route_bound_facts = {
        reader_id: set(reader.get("reads_fact_ids", []))
        for reader_id, reader in route_readers.items()}
    for reader_id in {
            *route_row["near_reader_ids"],
            *route_row["milestone_reader_ids"]}:
        if route_readers.get(reader_id, {}).get("reader_kind") \
                in ROUTE_CAUSAL_READER_KINDS:
            route_readers[reader_id]["status"] = "shadowed"
    summary_only_route_facts = _row_route_read_fact_ids(
        route_row, route_readers, route_bound_facts)
    daeun_contracts = [
        contract for contract in route_counter["branch_contracts"]
        if contract["branch_id"] in {
            "m4_people:daeun_player_return",
            "m4_people:daeun_return_after_distance",
        }]
    summary_only_signatures = [
        _branch_causal_signatures(
            route_row, contract, summary_only_route_facts, {},
            include_nested_outputs=False)
        for contract in daeun_contracts]
    if (len(summary_only_signatures) != 2
            or not (summary_only_signatures[0]
                    & summary_only_signatures[1])):
        raise AssertionError(
            "month-summary/display-only facts incorrectly proved weekly route divergence")
    cases += 1

    unknown_execution_bundle = {
        "action_id": "side_shift",
        "action_config": {"execution": "selftest_unknown"},
    }
    if not _bundle_execution_family(
            "selftest_unknown", unknown_execution_bundle).startswith(
                "unknown:execution:"):
        raise AssertionError(
            "unknown action execution type escaped family census")
    cases += 1
    implicit_application_bundle = {
        "action_id": "apply", "action_config": {},
    }
    if _bundle_execution_family(
            "selftest_implicit_application",
            implicit_application_bundle) != "unknown:implicit_application":
        raise AssertionError(
            "implicit application escaped family census")
    cases += 1

    expiry_effect_omission = copy.deepcopy(ledger)
    expiry_effect_row = next(
        row for row in expiry_effect_omission["rows"]
        if row["chain_id"] == "m2_advancement")
    expiry_effect_row["producer"]["state_delta_keys"].remove("mental")
    _expect_failure(
        "expiry effect omitted from producer state union",
        expiry_effect_omission, baseline,
        "state_delta_keys: source effects mismatch")
    cases += 1

    month_receipt_omission = copy.deepcopy(ledger)
    month_two_reader = next(
        reader for reader in month_receipt_omission["reader_registry"]
        if reader["reader_id"] == "reader:month:m02:summary")
    month_two_expiry = next(
        row for row in month_receipt_omission["rows"]
        if row["chain_id"] == "m2_advancement")["missed_contract"][
            "receipt_ids"][0]
    month_two_reader["reads_fact_ids"].remove(month_two_expiry)
    month_two_reader["read_contracts"] = [
        contract for contract in month_two_reader["read_contracts"]
        if contract["fact_id"] != month_two_expiry]
    _expect_failure(
        "month summary omits authored expiry receipt",
        month_receipt_omission, baseline,
        "exact month receipt mirror mismatch")
    cases += 1

    missed_reader_binding_omission = copy.deepcopy(ledger)
    missed_row = next(
        row for row in missed_reader_binding_omission["rows"]
        if row["chain_id"] == "m2_advancement")
    missed_receipt = missed_row["missed_contract"]["receipt_ids"][0]
    missed_reader = next(
        reader for reader in missed_reader_binding_omission[
            "reader_registry"]
        if reader["reader_id"] == missed_row["missed_contract"][
            "reader_ids"][0])
    missed_reader["read_contracts"] = [
        contract for contract in missed_reader["read_contracts"]
        if contract["fact_id"] != missed_receipt]
    _expect_failure(
        "missed receipt lacks named reader proof",
        missed_reader_binding_omission, baseline,
        "missed receipt is not bound by its named reader")
    cases += 1

    source_repeat_identity_drift = copy.deepcopy(ledger)
    source_repeat_row = next(
        row for row in source_repeat_identity_drift["rows"]
        if row["terminal_contract"]["repeatable_after_completion"])
    source_repeat_row["producer"]["repeat_receipt_unique_by"] = ["bogus"]
    _expect_failure(
        "repeat receipt identity source drift", source_repeat_identity_drift,
        baseline, "repeat contract does not match runtime cost/identity")
    cases += 1

    source_repeat_cost_drift = copy.deepcopy(ledger)
    next(row for row in source_repeat_cost_drift["rows"]
         if row["terminal_contract"]["repeatable_after_completion"])[
             "cost"]["weekly_capacity"] = 99
    _expect_failure(
        "repeat cost source drift", source_repeat_cost_drift, baseline,
        "expected one visible weekly capacity")
    cases += 1

    surface_pointer_drift = copy.deepcopy(ledger)
    surface_pointer_drift["rows"][0]["surface_pointers"]["ko"][0] = \
        surface_pointer_drift["rows"][0]["surface_pointers"]["ko"][1]
    _expect_failure(
        "surface pointer exact mirror", surface_pointer_drift, baseline,
        "exact KO/EN node fields mismatch")
    cases += 1

    row_proof_drift = copy.deepcopy(ledger)
    row_proof_id = f"proof:row:{row_proof_drift['rows'][0]['chain_id']}"
    next(proof for proof in row_proof_drift["runtime_proof_registry"]
         if proof["proof_id"] == row_proof_id)["pointer"] = \
        row_proof_drift["rows"][1]["runtime_pointer"]
    _expect_failure(
        "row proof unrelated pointer", row_proof_drift, baseline,
        "row proof must exactly bind runtime pointer")
    cases += 1

    save_source_drift = copy.deepcopy(ledger)
    save_source_proof = next(
        proof for proof in save_source_drift["runtime_proof_registry"]
        if proof["proof_id"] == "proof:runtime:save_roundtrip_prefix")
    save_source_proof["pointer"] = \
        "systems/DemoCoreLoopV2.gd::default_routines"
    save_source_proof["assertion"] = \
        "self-authored claim about nodes and every receipt map"
    _expect_failure(
        "save proof unrelated source", save_source_drift, baseline,
        "save proof is not bound to normalization source")
    cases += 1

    save_source_mutations = (
        ("autoloads/SaveManager.gd::save_game",
         "GameState.serialize()"),
        ("autoloads/SaveManager.gd::_write_save_payload",
         "_write_exact_bytes(temporary_path, serialized_bytes)"),
        ("autoloads/SaveManager.gd::_read_save_candidate",
         'payload.get("state", payload)'),
        ("autoloads/SaveManager.gd::load_game",
         "GameState.load_from_dict(state)"),
        ("autoloads/GameState.gd::serialize",
         '"core_loop_v2_state": core_loop_v2_state'),
        ("autoloads/GameState.gd::load_from_dict",
         'data.has("core_loop_v2_state")'),
        ("systems/DemoCoreLoopV2.gd::_normalized_state",
         "normalize_seoul_cycle_state("),
        ("systems/DemoCoreLoopV2.gd::normalize_seoul_cycle_state",
         'raw_state.get("expiry_receipts"'),
    )
    for pointer, marker in save_source_mutations:
        original_body = _pointer_source_text(pointer, {})
        if marker not in original_body:
            raise AssertionError(
                f"self-test setup: save marker missing {pointer} {marker}")
        SOURCE_TEXT_CACHE[pointer] = original_body.replace(
            marker, "SELFTEST_REMOVED_SAVE_MARKER", 1)
        try:
            _expect_failure(
                f"save handoff source marker {pointer}", ledger, baseline,
                f"source handoff markers missing at {pointer}")
        finally:
            SOURCE_TEXT_CACHE[pointer] = original_body
        cases += 1

    for field, needle in (
            ("branch_ids", "branch IDs do not mirror row contract"),
            ("distinguishing_axes", "axes do not mirror row contract"),
            ("runtime_proof_ids", "proofs do not mirror row/source contract")):
        invented_counter = copy.deepcopy(ledger)
        invented_counter["counterfactual_registry"][0][field] = [
            "selftest:invented_a", "selftest:invented_b"]
        _expect_failure(
            f"counterfactual invented {field}", invented_counter, baseline,
            needle)
        cases += 1

    missing_branch_contract = copy.deepcopy(ledger)
    missing_branch_contract["counterfactual_registry"][0][
        "branch_contracts"].pop()
    _expect_failure(
        "counterfactual missing branch contract", missing_branch_contract,
        baseline, "ordered branch bijection mismatch")
    cases += 1

    duplicate_branch_contract = copy.deepcopy(ledger)
    duplicate_counter = duplicate_branch_contract[
        "counterfactual_registry"][0]
    duplicate_counter["branch_contracts"].append(
        copy.deepcopy(duplicate_counter["branch_contracts"][0]))
    _expect_failure(
        "counterfactual duplicate branch contract",
        duplicate_branch_contract, baseline,
        "ordered branch bijection mismatch")
    cases += 1

    swapped_branch_outcome = copy.deepcopy(ledger)
    swapped_contract = swapped_branch_outcome[
        "counterfactual_registry"][0]["branch_contracts"][0]
    swapped_contract["outcome_kind"] = "expired"
    _expect_failure(
        "counterfactual branch outcome swapped", swapped_branch_outcome,
        baseline, "branch contracts do not mirror source outputs")
    cases += 1

    unrelated_branch_fact = copy.deepcopy(ledger)
    unrelated_branch_fact["counterfactual_registry"][0][
        "branch_contracts"][0]["produced_fact_ids"][0] = \
        "fact:selftest_unrelated_branch_output"
    _expect_failure(
        "counterfactual unrelated branch fact", unrelated_branch_fact,
        baseline, "branch contracts do not mirror source outputs")
    cases += 1

    unrelated_branch_proof = copy.deepcopy(ledger)
    unrelated_branch_proof["counterfactual_registry"][0][
        "branch_contracts"][0]["runtime_proof_ids"][-1] = \
        "proof:runtime:save_roundtrip_prefix"
    _expect_failure(
        "counterfactual unrelated branch proof", unrelated_branch_proof,
        baseline, "branch contracts do not mirror source outputs")
    cases += 1

    sibling_branch_union = copy.deepcopy(ledger)
    sibling_counter = next(
        counter for counter in sibling_branch_union[
            "counterfactual_registry"]
        if counter["chain_id"] == "m4_advancement")
    sibling_fact = next(
        fact_id for fact_id in sibling_counter["branch_contracts"][1][
            "produced_fact_ids"]
        if fact_id not in sibling_counter["branch_contracts"][0][
            "produced_fact_ids"])
    sibling_counter["branch_contracts"][0]["produced_fact_ids"].append(
        sibling_fact)
    _expect_failure(
        "counterfactual sibling branch output union",
        sibling_branch_union, baseline,
        "branch contracts do not mirror source outputs")
    cases += 1

    resume_weekly_quality_split = copy.deepcopy(ledger)
    resume_counter = next(
        counter for counter in resume_weekly_quality_split[
            "counterfactual_registry"]
        if counter["chain_id"] == "m1_resume")
    completed_contract = next(
        contract for contract in resume_counter["branch_contracts"]
        if contract["outcome_kind"] == "completed")
    split_contracts = []
    for suffix in ("polished", "unpolished"):
        split_contract = copy.deepcopy(completed_contract)
        split_contract["branch_id"] = f"m1_resume:{suffix}"
        split_contracts.append(split_contract)
    completed_index = resume_counter["branch_contracts"].index(
        completed_contract)
    resume_counter["branch_contracts"][
        completed_index:completed_index + 1] = split_contracts
    branch_index = resume_counter["branch_ids"].index("m1_resume:completed")
    resume_counter["branch_ids"][branch_index:branch_index + 1] = [
        item["branch_id"] for item in split_contracts]
    _expect_failure(
        "resume quality cannot split the weekly route",
        resume_weekly_quality_split, baseline,
        "branch IDs do not mirror row contract")
    cases += 1

    producer_completion_bijection = copy.deepcopy(ledger)
    repeat_row = next(
        row for row in producer_completion_bijection["rows"]
        if row["chain_id"] == "m1_convenience")
    repeat_row["producer"]["completion_receipt_ids"].remove(
        "receipt:completed:m1_convenience_trial_shift")
    _expect_failure(
        "producer omits first-completion bundle receipt",
        producer_completion_bijection, baseline,
        "producer/branch potential completion fact bijection mismatch")
    cases += 1

    branch_completion_bijection = copy.deepcopy(ledger)
    repeat_counter = next(
        counter for counter in branch_completion_bijection[
            "counterfactual_registry"]
        if counter["chain_id"] == "m1_convenience")
    next(contract for contract in repeat_counter["branch_contracts"]
         if contract["outcome_kind"] == "completed")[
             "produced_fact_ids"].remove(
                 "receipt:completed:m1_convenience_trial_shift")
    _expect_failure(
        "repeat first-completion branch omits bundle receipt",
        branch_completion_bijection, baseline,
        "producer/branch potential completion fact bijection mismatch")
    cases += 1

    prerequisite_all_omission = copy.deepcopy(ledger)
    seorin_result_reader = next(
        reader for reader in prerequisite_all_omission["reader_registry"]
        if reader["reader_id"] == "reader:result:m3_seorin")
    seorin_completed_fact = "receipt:completed:m2_seorin_application"
    seorin_result_reader["reads_fact_ids"].remove(seorin_completed_fact)
    seorin_result_reader["read_contracts"] = [
        contract for contract in seorin_result_reader["read_contracts"]
        if contract["fact_id"] != seorin_completed_fact]
    _expect_failure(
        "prerequisite all predicate omitted", prerequisite_all_omission,
        baseline, "source prerequisite contract mismatch")
    cases += 1

    prerequisite_any_collapse = copy.deepcopy(ledger)
    father_variant_readers = [
        reader for reader in prerequisite_any_collapse["reader_registry"]
        if reader["reader_id"].startswith("reader:next:father_quiet_call")]
    source_father_variant = next(
        reader for reader in father_variant_readers
        if reader["reader_id"] == "reader:next:father_quiet_call")
    collapsed_father_variant = next(
        reader for reader in father_variant_readers
        if reader["reader_id"].endswith(":ended_quickly"))
    collapsed_father_variant["reads_fact_ids"] = copy.deepcopy(
        source_father_variant["reads_fact_ids"])
    collapsed_father_variant["read_contracts"] = copy.deepcopy(
        source_father_variant["read_contracts"])
    collapsed_father_variant["runtime_proof_ids"] = copy.deepcopy(
        source_father_variant["runtime_proof_ids"])
    _expect_failure(
        "prerequisite any variants collapsed", prerequisite_any_collapse,
        baseline, "source prerequisite any-variant coverage mismatch")
    cases += 1

    replay_singleton_counters = copy.deepcopy(ledger)
    replay_singleton = replay_singleton_counters["replay_witnesses"][0]
    other_counter = next(
        counter for counter in replay_singleton_counters[
            "counterfactual_registry"]
        if counter["counterfactual_id"] != "counterfactual:m2_advancement")
    replay_singleton["route_ids"][1] = other_counter["branch_ids"][0]
    _expect_failure(
        "replay cannot compare singleton branches from different rows",
        replay_singleton_counters, baseline,
        "every compared counterfactual needs at least two alternatives")
    cases += 1

    replay_future_reader = copy.deepcopy(ledger)
    w8_future_witness = next(
        witness for witness in replay_future_reader["replay_witnesses"]
        if witness["checkpoint_week"] == 8)
    w8_future_witness["reader_ids"] = [
        "reader:result:m3_seorin", "reader:month:m02:summary"]
    _expect_failure(
        "W8 replay cannot use W9 result reader", replay_future_reader,
        baseline, "reader is not available by checkpoint")
    cases += 1

    replay_fake_route = copy.deepcopy(ledger)
    replay_fake_route["replay_witnesses"][0]["route_ids"][0] = \
        "selftest:invented_route"
    _expect_failure(
        "normal replay invented route", replay_fake_route, baseline,
        "route is not a declared counterfactual branch")
    cases += 1

    replay_fake_axis = copy.deepcopy(ledger)
    replay_fake_axis["replay_witnesses"][0]["distinguishing_axes"] = [
        "selftest:invented_axis"]
    _expect_failure(
        "normal replay invented axis", replay_fake_axis, baseline,
        "not bound to route contracts")
    cases += 1

    missing_story_decision = copy.deepcopy(ledger)
    decision_reader = next(
        reader for reader in missing_story_decision["reader_registry"]
        if reader["story_decision_ids"])
    decision_reader["story_decision_ids"] = []
    _expect_failure(
        "story decision cannot be omitted", missing_story_decision, baseline,
        "does not match source-authored decisions")
    cases += 1

    invented_w4_activation = copy.deepcopy(ledger)
    w4_milestone_case = next(
        milestone for milestone in invented_w4_activation["milestone_registry"]
        if milestone["week"] == 4)
    w4_invocation_case = next(
        invocation for invocation in w4_milestone_case["invocations"]
        if invocation["invocation_id"]
        == "reader:milestone:w04:allocation_echo")
    w4_variant_case = w4_invocation_case[
        "exclusive_variant_groups"][0]["variants"][0]
    w4_reader_case = next(
        reader for reader in invented_w4_activation["reader_registry"]
        if reader["reader_id"] == w4_variant_case["reader_id"])
    invented_w4_fact = "fact:selftest_invented_w4_allocation"
    w4_variant_case["activation_fact_ids"] = [invented_w4_fact]
    w4_reader_case["reads_fact_ids"] = [invented_w4_fact]
    w4_reader_case["history_memory_ids"] = [invented_w4_fact]
    w4_reader_case["read_contracts"][0]["fact_id"] = invented_w4_fact
    _expect_failure(
        "W4 activation fact cannot be invented", invented_w4_activation,
        baseline, "allocation echo variants do not exactly mirror")
    cases += 1

    zero_story_roles = copy.deepcopy(ledger)
    role_reader = next(
        reader for reader in zero_story_roles["reader_registry"]
        if reader["reader_kind"] == "story_milestone"
        and reader["history_memory_ids"])
    role_reader["history_memory_ids"] = []
    role_reader["material_state_ids"] = []
    role_reader["input_build_family_ids"] = []
    role_reader["story_decision_ids"] = []
    _expect_failure(
        "story memories cannot be zeroed", zero_story_roles, baseline,
        "story input roles must exactly partition reads_fact_ids")
    cases += 1

    unrelated_gap_proof = copy.deepcopy(ledger)
    unrelated_gap_proof["coverage_gaps"][0]["runtime_proof_ids"][0] = \
        "proof:runtime:month_summary"
    _expect_failure(
        "gap proof cannot be substituted", unrelated_gap_proof, baseline,
        "exact gap proof set mismatch")
    cases += 1

    semantic_snapshot_drift = copy.deepcopy(ledger)
    semantic_snapshot_drift["ledger_id"] += ":invented"
    _expect_failure(
        "audited semantic snapshot", semantic_snapshot_drift, baseline,
        "audited semantic snapshot mismatch", snapshot=True)
    cases += 1

    for core_proof_id in (
            "proof:runtime:allocation_commit",
            "proof:runtime:terminal_expiry",
            "proof:runtime:first_eligible_person"):
        unrelated_core_proof = copy.deepcopy(ledger)
        core_proof = next(
            proof for proof in unrelated_core_proof["runtime_proof_registry"]
            if proof["proof_id"] == core_proof_id)
        core_proof["pointer"] = "systems/DemoCoreLoopV2.gd::default_routines"
        core_proof["assertion"] = "self-authored unrelated proof claim"
        _expect_failure(
            f"core proof unrelated source {core_proof_id}",
            unrelated_core_proof, baseline,
            f"audited binding mismatch {core_proof_id}")
        cases += 1

    father_pair_swap = copy.deepcopy(ledger)
    father_readers = {
        reader["reader_id"]: reader
        for reader in father_pair_swap["reader_registry"]
        if reader["reader_id"] in {
            "reader:milestone:w24:father_checked",
            "reader:milestone:w24:father_called_again",
        }
    }
    checked_reader = father_readers[
        "reader:milestone:w24:father_checked"]
    called_reader = father_readers[
        "reader:milestone:w24:father_called_again"]
    for field in ("reads_fact_ids", "history_memory_ids", "read_contracts"):
        checked_reader[field], called_reader[field] = \
            called_reader[field], checked_reader[field]
    father_group = next(
        group for milestone in father_pair_swap["milestone_registry"]
        for invocation in milestone["invocations"]
        for group in invocation["exclusive_variant_groups"]
        if group["group_id"] == "group:w24:father_memory")
    father_variants = {variant["reader_id"]: variant
                       for variant in father_group["variants"]}
    father_variants["reader:milestone:w24:father_checked"][
        "activation_fact_ids"], father_variants[
            "reader:milestone:w24:father_called_again"][
                "activation_fact_ids"] = (
        father_variants["reader:milestone:w24:father_called_again"][
            "activation_fact_ids"],
        father_variants["reader:milestone:w24:father_checked"][
            "activation_fact_ids"])
    father_exclusive_proof = next(
        proof for proof in father_pair_swap["runtime_proof_registry"]
        if proof["proof_id"] == "proof:exclusive:group_w24_father_memory")
    father_exclusive_proof["assertion"] = " ".join([
        father_group["group_id"], father_group["selection_mode"],
        *[variant["reader_id"] for variant in father_group["variants"]],
        *[fact for variant in father_group["variants"]
          for fact in variant["activation_fact_ids"]],
    ])
    _expect_failure(
        "coordinated father memory decision swap", father_pair_swap,
        baseline, "Story input tuple source mismatch")
    cases += 1

    w8_pointer = "systems/DemoCoreLoopV2.gd::resolved_event_roots"
    previous_w8_source = SOURCE_TEXT_CACHE.get(w8_pointer)
    SOURCE_TEXT_CACHE[w8_pointer] = (
        "static func resolved_event_roots(bundle_id: String) -> Array:\n"
        "\treturn []")
    try:
        _expect_failure(
            "W8 authored decision without runtime consumer", ledger, baseline,
            "audited binding mismatch proof:runtime")
    except AssertionError:
        # The exact changed proof ID can vary because several W8 proofs share
        # the same consumer; require the direct fact-binding failure instead.
        _expect_failure(
            "W8 authored decision without runtime consumer", ledger, baseline,
            "no runtime proof directly binds fact state:flag:lent_account")
    finally:
        if previous_w8_source is None:
            SOURCE_TEXT_CACHE.pop(w8_pointer, None)
        else:
            SOURCE_TEXT_CACHE[w8_pointer] = previous_w8_source
    cases += 1

    city_activation_drift = copy.deepcopy(ledger)
    city_invocation = next(
        invocation for milestone in city_activation_drift["milestone_registry"]
        for invocation in milestone["invocations"]
        if invocation["invocation_id"]
        == "reader:milestone:w24:candidate_aggregation")
    city_conditional = next(
        item for item in city_invocation["conditional_readers"]
        if item["reader_id"] == "reader:milestone:w24:candidate_city")
    city_conditional["activation_fact_ids"] = \
        city_conditional["activation_fact_ids"][:1]
    _expect_failure(
        "city activation fact omitted", city_activation_drift, baseline,
        "audited invocation source topology mismatch")
    cases += 1

    city_always_drift = copy.deepcopy(ledger)
    city_always_invocation = next(
        invocation for milestone in city_always_drift["milestone_registry"]
        for invocation in milestone["invocations"]
        if invocation["invocation_id"]
        == "reader:milestone:w24:candidate_aggregation")
    city_index = next(
        index for index, item in enumerate(
            city_always_invocation["conditional_readers"])
        if item["reader_id"] == "reader:milestone:w24:candidate_city")
    moved_city = city_always_invocation["conditional_readers"].pop(city_index)
    city_always_invocation["always_reader_ids"].append(moved_city["reader_id"])
    city_invocation_proof = next(
        proof for proof in city_always_drift["runtime_proof_registry"]
        if proof["proof_id"] == "proof:invocation:w24_candidate_aggregation")
    city_invocation_proof["assertion"] = \
        _invocation_contract_token(city_always_invocation)
    _expect_failure(
        "conditional city reader made always", city_always_drift, baseline,
        "audited invocation source topology mismatch")
    cases += 1

    hanbit_activation_drift = copy.deepcopy(ledger)
    hanbit_invocation = next(
        invocation for milestone in hanbit_activation_drift[
            "milestone_registry"] for invocation in milestone["invocations"]
        if invocation["invocation_id"]
        == "reader:milestone:w24:candidate_aggregation")
    hanbit_variant = next(
        variant for group in hanbit_invocation["exclusive_variant_groups"]
        for variant in group["variants"]
        if variant["reader_id"] == "reader:milestone:w24:candidate_hanbit")
    hanbit_variant["activation_fact_ids"] = ["state:current_job:job_03"]
    _expect_failure(
        "Hanbit activation provenance omitted", hanbit_activation_drift,
        baseline, "audited invocation source topology mismatch")
    cases += 1

    for missed_field, invented_value, expected_error in (
            ("receipt_ids", ["receipt:expiry:invented"],
             "missed_contract: source expiry contract mismatch"),
            ("consequence_ids", ["invented_consequence"],
             "missed_contract: source expiry contract mismatch"),
            ("reader_ids", ["reader:month:m02:summary"],
             "missed_contract: source expiry contract mismatch"),
            ("changes_future_availability", True,
             "missed future-availability source graph mismatch")):
        missed_drift = copy.deepcopy(ledger)
        missed_drift["rows"][0]["missed_contract"][missed_field] = \
            invented_value
        _expect_failure(
            f"missed contract source drift {missed_field}", missed_drift,
            baseline, expected_error)
        cases += 1

    family_action_drift = copy.deepcopy(ledger)
    family_action_drift["build_families"][0]["source_action_ids"] = [
        "invented"]
    _expect_failure(
        "build family invented source action", family_action_drift, baseline,
        "audited source action set mismatch")
    cases += 1

    w48_test_proofs = {
        proof_id: {
            "proof_id": proof_id,
            "kind": "source_symbol",
            "pointer": pointer,
            "assertion": "self-test ordered W48 source owner",
        }
        for proof_id, pointer in W48_COMPLETION_PROOF_POINTERS.items()
    }
    w48_test_milestone = {
        "runtime_proof_ids": list(W48_COMPLETION_PROOF_POINTERS),
    }
    w48_test_reader = {
        "runtime_proof_ids": list(W48_COMPLETION_PROOF_POINTERS),
    }
    dispatch_pointer = W48_COMPLETION_PROOF_POINTERS[
        "proof:runtime:w48_completed_week_dispatch"]
    boundary_pointer = W48_COMPLETION_PROOF_POINTERS[
        "proof:runtime:w48_final_boundary_order"]
    world_pointer = W48_COMPLETION_PROOF_POINTERS[
        "proof:runtime:w48_world_event_resolution_order"]
    settlement_pointer = W48_COMPLETION_PROOF_POINTERS[
        "proof:runtime:w48_december_settlement_order"]
    post_dispatch_pointer = W48_COMPLETION_PROOF_POINTERS[
        "proof:runtime:w48_post_boss_dispatch"]
    post_pointer = W48_COMPLETION_PROOF_POINTERS[
        "proof:runtime:w48_post_boss_order"]
    cta_surface_pointer = W48_COMPLETION_PROOF_POINTERS[
        "proof:runtime:w48_completion_cta_surface"]
    cta_pointer = W48_COMPLETION_PROOF_POINTERS[
        "proof:runtime:w48_chapter2_cta_order"]
    valid_w48_bodies = {
        dispatch_pointer: "\n".join((
            "func _core_loop_v2_advance_completed_week():",
            "\tif GameState.turn == 48:",
            "\t\t_core_loop_v2_finalize_w48_boundary()",
        )),
        boundary_pointer: "\n".join((
            "func _core_loop_v2_finalize_w48_boundary():",
            "\tDEMO_CORE_LOOP_V2.complete_seoul_cycle_turn(",
            "\tDEMO_CORE_LOOP_V2.resolve_seoul_cycle_month_terminals(",
            "\tDEMO_CORE_LOOP_V2.resolve_seoul_cycle_forgone_paths(",
            "\t_core_loop_v2_resolve_december_world_events_without_rollover(",
            "\t_core_loop_v2_run_december_settlement_without_rollover(",
            "\tGameState.check_game_over()",
            "\tif GameState.is_game_over:",
            "\t\treturn",
            "\tDEMO_CORE_LOOP_V2.freeze_chapter1_end_snapshot(",
            '\t_go_story_mode(["arc_year1_close"])',
        )),
        world_pointer: "\n".join((
            "func _core_loop_v2_resolve_december_world_events_without_rollover():",
            "\tDEMO_CORE_LOOP_V2.resolve_seoul_cycle_month_world_events(",
            "\tDEMO_CORE_LOOP_V2.assert_no_pending_trigger_or_world(",
        )),
        settlement_pointer: "\n".join((
            "func _core_loop_v2_run_december_settlement_without_rollover():",
            "\tjob_system.process_monthly_job()",
            "\trelationship_system.process_monthly_relationships()",
            "\tinventory_system.process_monthly_items()",
            "\tGameState.apply_monthly_pressure()",
            "\tGameState.check_game_over()",
        )),
        post_dispatch_pointer: "\n".join((
            "func _core_loop_v2_resume_chapter1_close():",
            '\tGameState.flags.get("arc_year1_close_seen"',
            "\tGameState.get_year_scene_selection(1)",
            "\t_core_loop_v2_finalize_chapter1_after_boss()",
        )),
        post_pointer: "\n".join((
            "func _core_loop_v2_finalize_chapter1_after_boss():",
            '\tGameState.flags.get("arc_year1_close_seen"',
            "\tGameState.get_year_scene_candidates(",
            "\tGameState.get_year_scene_selection(1)",
            "\tif GameState.get_year_scene_selection(1).is_empty():",
            "\t\treturn",
            '\tGameState.flags["chapter1_complete"] = true',
            "\tSaveManager.autosave(",
            "\t_show_chapter1_completion(",
        )),
        cta_surface_pointer: "\n".join((
            "func _show_chapter1_completion():",
            "\t_primary_cta_button(",
            "\tbutton.pressed.connect(_core_loop_v2_start_chapter2)",
            '\tbutton.call_deferred("grab_focus")',
        )),
        cta_pointer: "\n".join((
            "func _core_loop_v2_start_chapter2():",
            '\tGameState.flags.get("chapter1_complete"',
            "\tGameState.advance_calendar()",
            '\t_go_story_mode(["chapter_card_34"])',
        )),
    }
    prior_w48_bodies = {
        pointer: SOURCE_TEXT_CACHE.get(pointer)
        for pointer in valid_w48_bodies}
    try:
        SOURCE_TEXT_CACHE.update(valid_w48_bodies)
        w48_order_errors: list[str] = []
        _validate_w48_completion_source_contract(
            w48_test_milestone, w48_test_reader,
            w48_test_proofs, w48_order_errors, {})
        if w48_order_errors:
            raise AssertionError(
                f"valid W48 ordered fixture rejected: {w48_order_errors}")
        cases += 1
        w48_source_mutations = (
            (
                "snapshot before December settlement", boundary_pointer,
                "\n".join((
                    "func _core_loop_v2_finalize_w48_boundary():",
                    "\tDEMO_CORE_LOOP_V2.complete_seoul_cycle_turn(",
                    "\tDEMO_CORE_LOOP_V2.resolve_seoul_cycle_month_terminals(",
                    "\tDEMO_CORE_LOOP_V2.resolve_seoul_cycle_forgone_paths(",
                    "\tDEMO_CORE_LOOP_V2.freeze_chapter1_end_snapshot(",
                    "\t_core_loop_v2_resolve_december_world_events_without_rollover(",
                    "\t_core_loop_v2_run_december_settlement_without_rollover(",
                    "\tGameState.check_game_over()",
                    "\tif GameState.is_game_over:",
                    "\t\treturn",
                    '\t_go_story_mode(["arc_year1_close"])',
                )),
                "W48 boundary order"),
            (
                "world event closure omitted", boundary_pointer,
                valid_w48_bodies[boundary_pointer].replace(
                    "\t_core_loop_v2_resolve_december_world_events_without_rollover(\n",
                    "", 1),
                "W48 boundary order"),
            (
                "world event owner does not close pending entries", world_pointer,
                valid_w48_bodies[world_pointer].replace(
                    "\tDEMO_CORE_LOOP_V2.assert_no_pending_trigger_or_world(",
                    "", 1),
                "world events must resolve and close"),
            (
                "December settlement advances calendar", settlement_pointer,
                valid_w48_bodies[settlement_pointer]
                    + "\n\tGameState.advance_calendar()",
                "must not advance to W49"),
            (
                "fatal branch without immediate return", boundary_pointer,
                valid_w48_bodies[boundary_pointer].replace(
                    "\t\treturn\n", "\t\tpass\n", 1),
                "fatal branch must return"),
            (
                "complete before boss seen and curation", post_pointer,
                "\n".join((
                    "func _core_loop_v2_finalize_chapter1_after_boss():",
                    '\tGameState.flags["chapter1_complete"] = true',
                    "\tSaveManager.autosave(",
                    '\tGameState.flags.get("arc_year1_close_seen"',
                    "\tGameState.get_year_scene_candidates(",
                    "\tGameState.get_year_scene_selection(1)",
                    "\tif GameState.get_year_scene_selection(1).is_empty():",
                    "\t\treturn",
                    "\t_show_chapter1_completion(",
                )),
                "boss-seen/actual-scene curation"),
            (
                "completed-week dispatcher leaves W48 finalizer dead",
                dispatch_pointer,
                valid_w48_bodies[dispatch_pointer].replace(
                    "\t\t_core_loop_v2_finalize_w48_boundary()", "", 1),
                "dispatcher does not call W48 boundary"),
            (
                "post-boss dispatcher leaves finalizer dead",
                post_dispatch_pointer,
                valid_w48_bodies[post_dispatch_pointer].replace(
                    "\t_core_loop_v2_finalize_chapter1_after_boss()", "", 1),
                "post-boss return path does not call finalizer"),
            (
                "completion CTA leaves Chapter-2 callback dead",
                cta_surface_pointer,
                valid_w48_bodies[cta_surface_pointer].replace(
                    "\tbutton.pressed.connect(_core_loop_v2_start_chapter2)\n",
                    "", 1),
                "completion CTA is not wired"),
            (
                "W49 before Chapter-2 CTA", post_pointer,
                valid_w48_bodies[post_pointer]
                    + "\n\tGameState.advance_calendar()",
                "belong only to Chapter-2 CTA"),
            (
                "chapter card before W49 inside CTA", cta_pointer,
                "\n".join((
                    "func _core_loop_v2_start_chapter2():",
                    '\tGameState.flags.get("chapter1_complete"',
                    '\t_go_story_mode(["chapter_card_34"])',
                    "\tGameState.advance_calendar()",
                )),
                "explicit Chapter-2 CTA"),
        )
        for name, pointer, mutated_body, needle in w48_source_mutations:
            SOURCE_TEXT_CACHE[pointer] = mutated_body
            mutation_errors: list[str] = []
            _validate_w48_completion_source_contract(
                w48_test_milestone, w48_test_reader,
                w48_test_proofs, mutation_errors, {})
            if not any(needle in error for error in mutation_errors):
                raise AssertionError(
                    f"{name}: expected {needle!r}, got {mutation_errors}")
            SOURCE_TEXT_CACHE[pointer] = valid_w48_bodies[pointer]
            cases += 1
    finally:
        for pointer, prior_body in prior_w48_bodies.items():
            if prior_body is None:
                SOURCE_TEXT_CACHE.pop(pointer, None)
            else:
                SOURCE_TEXT_CACHE[pointer] = prior_body

    _expect_failure("incomplete complete gate", ledger, baseline, "complete gate",
                    complete=True)
    cases += 1
    complete, complete_w24_manifest = _complete_fixture(
        ledger, return_manifest=True)
    complete_production_evidence = copy.deepcopy(
        complete_w24_manifest["production_evidence"])
    manifest_errors = _validate_synthetic_w24_fanin_manifest(
        ledger, complete, complete_w24_manifest,
        production_evidence=complete_production_evidence)
    source_census_skip_count += 1
    if manifest_errors:
        raise AssertionError(
            f"complete W24 manifest rejected: {manifest_errors}")
    cases += 1
    manifest_mutations: list[tuple[str, Any, str]] = []

    row_summary_laundering = copy.deepcopy(complete)
    row_summary_target = next(
        row for row in row_summary_laundering["rows"]
        if row["chain_id"] == "m3_self")
    raw_ledger_reason_id = (
        "reader:synthetic:w24:fanin_raw:w24_ledger_memory:source:"
        "reader:milestone:w24:ledger_reasons")
    summary_work_id = (
        "reader:synthetic:w24:fanin_summary:w24_prepare_fresh:"
        "work_and_consequence")
    row_summary_target["milestone_reader_ids"] = [
        summary_work_id if reader_id == raw_ledger_reason_id else reader_id
        for reader_id in row_summary_target["milestone_reader_ids"]]
    manifest_mutations.append((
        "row raw-reader replaced by Story summary",
        row_summary_laundering,
        "exact row/replay raw-reader mapping mismatch"))

    coordinated_reader_pointer = copy.deepcopy(complete)
    coordinated_reader_pointer_manifest = copy.deepcopy(
        complete_w24_manifest)
    pointer_reader = next(
        reader for reader in coordinated_reader_pointer["reader_registry"]
        if reader["reader_id"] == summary_work_id)
    pointer_reader["runtime_pointer"] = \
        "scenes/StoryMode.gd::_restore_story_result"
    pointer_proof_id = "proof:synthetic:w24_fanin_consumer:w24_prepare_fresh"
    pointer_proof = next(
        proof for proof in coordinated_reader_pointer[
            "runtime_proof_registry"]
        if proof["proof_id"] == pointer_proof_id)
    pointer_proof["pointer"] = \
        "scenes/StoryMode.gd::_restore_story_result"
    coordinated_reader_pointer_manifest["replacement_reader_records"][
        summary_work_id] = copy.deepcopy(pointer_reader)
    coordinated_reader_pointer_manifest["replacement_proof_records"][
        pointer_proof_id] = copy.deepcopy(pointer_proof)
    manifest_mutations.append((
        "coordinated summary reader and proof pointer swap",
        coordinated_reader_pointer,
        "replacement reader trust surface mismatch",
        coordinated_reader_pointer_manifest))

    summary_build_family = copy.deepcopy(complete)
    summary_build_family_manifest = copy.deepcopy(complete_w24_manifest)
    build_family_reader = next(
        reader for reader in summary_build_family["reader_registry"]
        if reader["reader_id"] == summary_work_id)
    build_family_reader["input_build_family_ids"].append(
        "build:career_progression")
    summary_build_family_manifest["replacement_reader_records"][
        summary_work_id] = copy.deepcopy(build_family_reader)
    manifest_mutations.append((
        "summary reader injected build ownership",
        summary_build_family,
        "replacement reader trust surface mismatch",
        summary_build_family_manifest))

    coactive = copy.deepcopy(complete)
    coactive_w24 = milestone_for(coactive, 24)
    frozen_invocation = copy.deepcopy(next(iter(
        complete_w24_manifest["superseded_invocations"].values())))
    coactive_w24["invocations"].append(frozen_invocation)
    manifest_mutations.append((
        "superseded invocation coactive", coactive,
        "superseded invocation remains executable"))

    changed_remaining = copy.deepcopy(complete)
    retained_id = next(iter(
        complete_w24_manifest["remaining_invocations"]))
    invocation_for(changed_remaining, 24, retained_id)[
        "runtime_pointer"] = "scenes/StoryMode.gd::_finish_all"
    manifest_mutations.append((
        "remaining19 mutation", changed_remaining,
        "retained invocation changed"))

    changed_clone = copy.deepcopy(complete)
    raw_clone = next(
        reader for reader in changed_clone["reader_registry"]
        if reader["reader_id"].startswith(
            "reader:synthetic:w24:fanin_raw:"))
    raw_clone["layer_owner"] = "story"
    manifest_mutations.append((
        "raw clone role laundering", changed_clone,
        "raw clone records changed after capture"))

    changed_replacement = copy.deepcopy(complete)
    replacement = next(
        invocation for invocation in milestone_for(
            changed_replacement, 24)["invocations"]
        if invocation["invocation_id"].startswith(
            "reader:synthetic:w24:fanin_summary_producer:"))
    replacement["conditional_producers"][0]["produced_fact_ids"].append(
        "history_summary:w24:third_axis")
    manifest_mutations.append((
        "third summary axis", changed_replacement,
        "replacement invocation contract changed"))

    changed_manifest = copy.deepcopy(complete_w24_manifest)
    changed_manifest["raw_id_universe"] = \
        changed_manifest["raw_id_universe"][:-1]
    manifest_mutations.append((
        "raw mapping omission", complete,
        "raw input universe mismatch", changed_manifest))

    changed_partition = copy.deepcopy(complete_w24_manifest)
    changed_partition["partition_digest"] = "0" * 64
    manifest_mutations.append((
        "raw axis swap", complete,
        "raw partition digest mismatch", changed_partition))

    changed_occurrences = copy.deepcopy(complete_w24_manifest)
    changed_occurrences["source_feasible_tuple_occurrence_count"] -= 1
    manifest_mutations.append((
        "source tuple occurrence drift", complete,
        "source-feasible tuple occurrences", changed_occurrences))

    changed_superseded = copy.deepcopy(complete_w24_manifest)
    next(iter(changed_superseded["superseded_invocations"].values()))[
        "runtime_pointer"] = "scenes/StoryMode.gd::_finish_all"
    manifest_mutations.append((
        "superseded evidence mutation", complete,
        "superseded record digest mismatch", changed_superseded))

    changed_final_tuple = copy.deepcopy(complete)
    final_aggregate = next(
        invocation for invocation in milestone_for(
            changed_final_tuple, 24)["invocations"]
        if invocation["invocation_id"].startswith(
            "reader:synthetic:w24:fanin_aggregate:"))
    final_aggregate["runtime_pointer"] = (
        "systems/DemoCoreLoopV2.gd::complete_active_bundle")
    manifest_mutations.append((
        "post-fixture option mutation", changed_final_tuple,
        "replacement invocation contract changed"))

    coordinated_tuple_rewrite = copy.deepcopy(complete_w24_manifest)
    coordinated_tuple_rewrite["stage_tuple_digests"] = {
        stage_id: "0" * 64 for stage_id in
        coordinated_tuple_rewrite["stage_tuple_digests"]}
    coordinated_tuple_rewrite["replacement_stage_tuple_digests"] = \
        copy.deepcopy(coordinated_tuple_rewrite["stage_tuple_digests"])
    manifest_mutations.append((
        "coordinated old/new tuple evidence rewrite", complete,
        "frozen production tuple digest map mismatch",
        coordinated_tuple_rewrite))

    coordinated_output = copy.deepcopy(complete)
    coordinated_output_manifest = copy.deepcopy(complete_w24_manifest)
    output_aggregate = next(
        invocation for invocation in milestone_for(
            coordinated_output, 24)["invocations"]
        if invocation["invocation_id"] == (
            "reader:synthetic:w24:fanin_aggregate:w24_prepare_fresh"))
    output_producer = next(
        producer for producer in output_aggregate["conditional_producers"]
        if "state:deferred_callback:callback_escaped_dirty_trace:synthetic:false"
        in producer["produced_fact_ids"])
    output_producer["produced_fact_ids"].remove(
        "state:deferred_callback:callback_escaped_dirty_trace:synthetic:false")
    coordinated_output_manifest["replacement_invocations"][
        output_aggregate["invocation_id"]] = copy.deepcopy(output_aggregate)
    coordinated_output_manifest["final_fixture_stage_digests"][
        "w24:prepare_fresh"] = _semantic_digest([output_aggregate])
    manifest_mutations.append((
        "coordinated non-summary output omission", coordinated_output,
        "replacement invocation frozen contract mismatch",
        coordinated_output_manifest))

    coordinated_effect = copy.deepcopy(complete)
    coordinated_effect_manifest = copy.deepcopy(complete_w24_manifest)
    effect_aggregate = next(
        invocation for invocation in milestone_for(
            coordinated_effect, 24)["invocations"]
        if invocation["invocation_id"] == (
            "reader:synthetic:w24:fanin_aggregate:w24_prepare_fresh"))
    effect_producer = next(
        producer for producer in effect_aggregate["conditional_producers"]
        if "effect:demo_collision_context:dirty_source:callback_escaped_dirty_trace"
        in producer["effect_contract_ids"])
    effect_index = effect_producer["effect_contract_ids"].index(
        "effect:demo_collision_context:dirty_source:callback_escaped_dirty_trace")
    effect_producer["effect_contract_ids"][effect_index] = \
        "effect:demo_collision_context:dirty_source:sibling_swap"
    coordinated_effect_manifest["replacement_invocations"][
        effect_aggregate["invocation_id"]] = copy.deepcopy(effect_aggregate)
    coordinated_effect_manifest["final_fixture_stage_digests"][
        "w24:prepare_fresh"] = _semantic_digest([effect_aggregate])
    manifest_mutations.append((
        "coordinated non-summary effect swap", coordinated_effect,
        "replacement invocation frozen contract mismatch",
        coordinated_effect_manifest))

    changed_stage_order = copy.deepcopy(complete)
    shifted_summary_stage = next(
        stage for stage in milestone_for(
            changed_stage_order, 24)["execution_stages"]
        if stage["stage_id"] == (
            "w24:synthetic_fanin_summary:w24:prepare_fresh"))
    shifted_summary_stage["predecessor_stage_ids"] = [
        "w24:synthetic_fanin_aggregate:w24:candidate_aggregation"]
    manifest_mutations.append((
        "replacement sibling predecessor lending", changed_stage_order,
        "replacement stage order/predecessor mismatch"))

    extra_decision_domain = copy.deepcopy(complete)
    decision_reader = next(
        reader for reader in extra_decision_domain["reader_registry"]
        if reader["reader_id"].startswith(
            "reader:synthetic:w24:fanin_summary_decision:"))
    decision_reader["story_decision_ids"] = ["decision:unrelated_story:0"]
    decision_reader["scene_handoff_decision_ids"] = []
    manifest_mutations.append((
        "second Story decision domain", extra_decision_domain,
        "second/unknown Story decision domain"))

    role_swap = copy.deepcopy(complete)
    role_swap_manifest = copy.deepcopy(complete_w24_manifest)
    role_swap_reader = next(
        reader for reader in role_swap["reader_registry"]
        if reader["reader_id"].startswith(
            "reader:synthetic:w24:fanin_raw:")
        and reader.get("history_memory_ids"))
    moved_history = role_swap_reader["history_memory_ids"].pop()
    role_swap_reader["material_state_ids"].append(moved_history)
    role_swap_manifest["raw_clone_records"][
        role_swap_reader["reader_id"]] = copy.deepcopy(role_swap_reader)
    manifest_mutations.append((
        "coordinated raw temporal role swap", role_swap,
        "raw clone frozen contract mismatch", role_swap_manifest))

    for mutation in manifest_mutations:
        name, mutated_fixture, needle, *override = mutation
        mutated_manifest = override[0] if override else complete_w24_manifest
        mutation_errors = _validate_synthetic_w24_fanin_manifest(
            ledger, mutated_fixture, mutated_manifest,
            production_evidence=complete_production_evidence)
        source_census_skip_count += 1
        if not any(needle in error for error in mutation_errors):
            raise AssertionError(
                f"{name}: expected {needle!r}, got {mutation_errors}")
        cases += 1

    # One representative coordinated W24 attack must also fail through a
    # fresh independent production derivation; this proves the immutable
    # self-test shortcut is diagnostic-equivalent, not a trust substitute.
    fresh_manifest_errors = _validate_synthetic_w24_fanin_manifest(
        ledger, coordinated_output, coordinated_output_manifest)
    source_census_full_count += 1
    source_census_fallback_count += 1
    if not any("replacement invocation frozen contract mismatch" in error
               for error in fresh_manifest_errors):
        raise AssertionError(
            "fresh W24 census fallback missed coordinated output omission: "
            f"{fresh_manifest_errors}")
    cached_manifest_errors = _validate_synthetic_w24_fanin_manifest(
        ledger, coordinated_output, coordinated_output_manifest,
        production_evidence=complete_production_evidence)
    source_census_skip_count += 1
    cached_needles = {
        error for error in cached_manifest_errors
        if "replacement invocation frozen contract mismatch" in error}
    fresh_needles = {
        error for error in fresh_manifest_errors
        if "replacement invocation frozen contract mismatch" in error}
    if cached_needles != fresh_needles or len(cached_needles) != 1:
        raise AssertionError(
            "cached/fresh W24 census diagnostic parity mismatch "
            f"cached={cached_manifest_errors} fresh={fresh_manifest_errors}")
    cases += 1

    complete_errors, _ = validate(
        complete, {}, require_complete=True, check_pointers=False,
        check_sources=False, synthetic_source_contracts=True,
        enforce_audited_snapshot=False)
    if complete_errors:
        raise AssertionError(f"complete fixture rejected: {complete_errors}")
    cases += 1

    complete_probe_parity = copy.deepcopy(complete)
    complete_probe_w24 = next(
        milestone for milestone in complete_probe_parity["milestone_registry"]
        if milestone["week"] == 24)
    complete_probe_stage = next(
        stage for stage in complete_probe_w24["execution_stages"]
        if stage["stage_id"] == "w24:prepare_fresh")
    old_probe_stage_token = _execution_stage_contract_token(
        complete_probe_stage)
    complete_probe_stage["predecessor_stage_ids"] = [
        "w24:synthetic_fanin_aggregate:w24:prepare_fresh"]
    new_probe_stage_token = _execution_stage_contract_token(
        complete_probe_stage)
    complete_probe_proofs = {
        proof["proof_id"]: proof
        for proof in complete_probe_parity["runtime_proof_registry"]}
    for proof_id in complete_probe_stage["runtime_proof_ids"]:
        proof = complete_probe_proofs[proof_id]
        if old_probe_stage_token in proof["assertion"]:
            proof["assertion"] = proof["assertion"].replace(
                old_probe_stage_token, new_probe_stage_token)
    _expect_probe_clean_full_fallback(
        "probe/full fallback synthetic complete", complete_probe_parity, {},
        "executable source scenario has no handoff-feasible invocation option",
        complete=True, sources=False, synthetic=True)
    cases += 1

    stale_complete_proofs = [
        proof for proof in ledger["runtime_proof_registry"]
        if (proof["proof_id"].startswith("proof:debt:")
            or proof["proof_id"] == "proof:runtime:completion_snapshot")]
    for stale_proof in stale_complete_proofs:
        stale_complete = copy.deepcopy(complete)
        stale_complete["runtime_proof_registry"].append(
            copy.deepcopy(stale_proof))
        _expect_failure(
            f"complete stale evidence {stale_proof['proof_id']}",
            stale_complete, {},
            "current-prefix/debt evidence proofs must be removed",
            complete=True, sources=False, synthetic=True)
        cases += 1

    swapped_w48_route = copy.deepcopy(complete)
    swapped_witness = next(
        item for item in swapped_w48_route["replay_witnesses"]
        if item["checkpoint_week"] == 48)
    swapped_counter = next(
        item for item in swapped_w48_route["counterfactual_registry"]
        if item["chain_id"] == "selftest_m12_livelihood")
    swapped_witness["route_ids"] = swapped_counter["branch_ids"][:2]
    swapped_witness["distinguishing_axes"] = \
        list(swapped_counter["distinguishing_axes"])
    _expect_failure(
        "complete W48 routes must match snapshot reader facts",
        swapped_w48_route, {},
        "W48 replay needs two declared counterfactual routes",
        complete=True, sources=False, synthetic=True)
    cases += 1

    alternate_expiry_only = copy.deepcopy(complete)
    alternate_witness = next(
        item for item in alternate_expiry_only["replay_witnesses"]
        if item["checkpoint_week"] == 48)
    people_counter = next(
        item for item in alternate_expiry_only["counterfactual_registry"]
        if item["chain_id"] == "selftest_m12_people")
    alternate_route = next(
        contract["branch_id"]
        for contract in people_counter["branch_contracts"]
        if contract["outcome_kind"] == "completed")
    expired_route = next(
        contract["branch_id"]
        for contract in people_counter["branch_contracts"]
        if contract["outcome_kind"] == "expired")
    alternate_witness["route_ids"] = [alternate_route, expired_route]
    alternate_witness["distinguishing_axes"] = \
        list(people_counter["distinguishing_axes"])
    people_row = next(
        row for row in alternate_expiry_only["rows"]
        if row["chain_id"] == "selftest_m12_people")
    people_expiry_fact = people_row["missed_contract"]["receipt_ids"][0]
    end_reader = next(
        reader for reader in alternate_expiry_only["reader_registry"]
        if reader["reader_id"] == "reader:chapter1_end_snapshot")
    end_reader["reads_fact_ids"] = [people_expiry_fact]
    end_reader["history_memory_ids"] = [people_expiry_fact]
    end_reader["material_state_ids"] = []
    end_reader["read_contracts"] = [{
        "fact_id": people_expiry_fact,
        "runtime_proof_ids": ["proof:selftest:read:chapter1_end_snapshot"],
    }]
    _expect_failure(
        "complete alternate candidate needs a completion/build reader fact",
        alternate_expiry_only, {},
        "W48 replay needs two declared counterfactual routes",
        complete=True, sources=False, synthetic=True)
    cases += 1

    _expect_failure(
        "ledger-only complete relabel is not source-authentic", complete, {},
        "does not mirror runtime selection owner", complete=True,
        sources=False)
    cases += 1
    _expect_failure(
        "complete rows need fact-overlapping causal readers", complete, {},
        "lacks a source-bound causal near reader", complete=True,
        sources=False)
    cases += 1
    _expect_failure(
        "complete W48 reader cannot recycle an earlier source", complete, {},
        "W48 close owners lack exact ordered source proofs",
        complete=True, sources=False)
    cases += 1

    blank_allocation = copy.deepcopy(complete)
    blank_allocation["rows"][0]["producer"]["allocation_receipt_id_template"] = ""
    _expect_failure(
        "complete blank allocation receipt", blank_allocation, {},
        "allocation_receipt_id_template: expected non-empty string",
        complete=True, sources=False)
    cases += 1

    for producer_key in (
            "completion_receipt_ids", "expiry_receipt_ids", "state_delta_keys"):
        missing_producer = copy.deepcopy(complete)
        missing_producer["rows"][0]["producer"][producer_key] = []
        _expect_failure(
            f"complete empty producer {producer_key}", missing_producer, {},
            f"producer.{producer_key}: must not be empty",
            complete=True, sources=False)
        cases += 1

    missing_facts = copy.deepcopy(complete)
    missing_facts["rows"][0]["build_facts"] = []
    _expect_failure(
        "complete empty build facts", missing_facts, {},
        "build_facts: must not be empty", complete=True, sources=False)
    cases += 1

    missing_near = copy.deepcopy(complete)
    missing_near["rows"][0]["near_reader_ids"] = []
    _expect_failure(
        "complete empty near reader", missing_near, {},
        "near_reader_ids: must not be empty", complete=True, sources=False)
    cases += 1

    wrong_near = copy.deepcopy(complete)
    wrong_near["rows"][0]["near_reader_ids"] = [
        wrong_near["rows"][1]["near_reader_ids"][0]]
    _expect_failure(
        "complete unnamed near reader", wrong_near, {},
        "missing named near causal reader", complete=True, sources=False)
    cases += 1

    missing_month_reader = copy.deepcopy(complete)
    month_reader_id = (
        f"reader:month:m{missing_month_reader['rows'][0]['month']:02d}:summary")
    missing_month_reader["rows"][0]["milestone_reader_ids"].remove(month_reader_id)
    _expect_failure(
        "complete missing month reader", missing_month_reader, {},
        "missing month-end reader", complete=True, sources=False)
    cases += 1

    missing_w48_reader = copy.deepcopy(complete)
    missing_w48_reader["rows"][0]["milestone_reader_ids"].remove(
        "reader:chapter1_end_snapshot")
    _expect_failure(
        "complete missing W48 reader", missing_w48_reader, {},
        "missing W48 snapshot reader", complete=True, sources=False)
    cases += 1

    missing_runtime_proofs = copy.deepcopy(complete)
    missing_runtime_proofs["rows"][0]["runtime_proof_ids"] = []
    _expect_failure(
        "complete empty runtime proofs", missing_runtime_proofs, {},
        "runtime_proof_ids: must not be empty", complete=True, sources=False)
    cases += 1

    missing_row_proof = copy.deepcopy(complete)
    row_proof_id = f"proof:row:{missing_row_proof['rows'][0]['chain_id']}"
    missing_row_proof["rows"][0]["runtime_proof_ids"].remove(row_proof_id)
    _expect_failure(
        "complete missing row proof", missing_row_proof, {},
        "missing row runtime proof", complete=True, sources=False)
    cases += 1

    missing_save_proof = copy.deepcopy(complete)
    missing_save_proof["rows"][0]["runtime_proof_ids"] = [
        proof_id for proof_id in missing_save_proof["rows"][0]["runtime_proof_ids"]
        if "save_roundtrip" not in proof_id]
    _expect_failure(
        "complete missing save proof", missing_save_proof, {},
        "missing save roundtrip proof", complete=True, sources=False)
    cases += 1

    display_next_verb = copy.deepcopy(complete)
    nonrepeat_row = next(
        row for row in display_next_verb["rows"]
        if not row["terminal_contract"]["repeatable_after_completion"])
    nonrepeat_row["next_verb_by_terminal"]["completed"] = [
        "reader:month:m01:summary"]
    _expect_failure(
        "complete display reader as next verb", display_next_verb, {},
        "is not an active next verb/action unlock", complete=True, sources=False)
    cases += 1

    blocked_w48 = copy.deepcopy(complete)
    next(item for item in blocked_w48["reader_registry"]
         if item["reader_id"] == "reader:chapter1_end_snapshot")[
             "status"] = "blocked_by_coverage"
    _expect_failure(
        "complete blocked W48 reader", blocked_w48, {},
        "blocked readers must be zero", complete=True, sources=False)
    cases += 1

    coverage_blocked_save = copy.deepcopy(complete)
    save_registry_proof = next(
        item for item in coverage_blocked_save["runtime_proof_registry"]
        if "save_roundtrip" in item["proof_id"])
    save_registry_proof["assertion"] = "full save roundtrip remains coverage-blocked"
    _expect_failure(
        "complete coverage-blocked save proof", coverage_blocked_save, {},
        "runtime proof registry still describes coverage debt",
        complete=True, sources=False)
    cases += 1

    single_route_w48 = copy.deepcopy(complete)
    single_route_witness = next(
        item for item in single_route_w48["replay_witnesses"]
        if item["checkpoint_week"] == 48)
    single_route_witness["route_ids"] = single_route_witness["route_ids"][:1]
    _expect_failure(
        "complete W48 single route", single_route_w48, {},
        "W48 replay needs two declared counterfactual routes",
        complete=True, sources=False)
    cases += 1

    fake_route_w48 = copy.deepcopy(complete)
    fake_route_witness = next(
        item for item in fake_route_w48["replay_witnesses"]
        if item["checkpoint_week"] == 48)
    fake_route_witness["route_ids"][0] = "selftest:undeclared_route"
    _expect_failure(
        "complete W48 fake route", fake_route_w48, {},
        "W48 replay needs two declared counterfactual routes",
        complete=True, sources=False)
    cases += 1

    mixed_counterfactual_routes = copy.deepcopy(complete)
    mixed_witness = next(
        item for item in mixed_counterfactual_routes["replay_witnesses"]
        if item["checkpoint_week"] == 48)
    mixed_witness["route_ids"] = [
        mixed_counterfactual_routes["counterfactual_registry"][0][
            "branch_ids"][0],
        mixed_counterfactual_routes["counterfactual_registry"][1][
            "branch_ids"][0],
    ]
    _expect_failure(
        "complete W48 routes from unrelated counterfactuals",
        mixed_counterfactual_routes, {},
        "W48 replay needs two declared counterfactual routes",
        complete=True, sources=False)
    cases += 1

    recycled_w24_proof = copy.deepcopy(complete)
    recycled_witness = next(
        item for item in recycled_w24_proof["replay_witnesses"]
        if item["checkpoint_week"] == 48)
    recycled_witness["runtime_proof_ids"] = ["proof:milestone:w24"]
    _expect_failure(
        "complete W48 recycled proof", recycled_w24_proof, {},
        "W48 replay needs two declared counterfactual routes",
        complete=True, sources=False)
    cases += 1

    # Run the deliberately expensive probe/full parity matrix last.  This
    # keeps an ordinary fixture diagnostic fast while still proving every
    # representative probe error is contained in the unchanged full
    # 210-scenario validation before self-test can succeed.
    w4_probe_parity = copy.deepcopy(ledger)
    invocation_for(
        w4_probe_parity, 4,
        "reader:milestone:w04:allocation_echo"
    )["exclusive_variant_groups"][0]["selection_mode"] = "at_most_one"
    _expect_probe_full_parity(
        "probe/full parity W4 exact-one", w4_probe_parity, baseline,
        "audited invocation source topology mismatch")
    cases += 1

    w8_probe_parity = copy.deepcopy(ledger)
    w8_clean = invocation_for(
        w8_probe_parity, 8,
        "reader:milestone:w08:temptation_fallout_choice"
    )["conditional_producers"][0]
    w8_clean["activation_ids"][1] = "state:flag:kept_clean_hands"
    _expect_probe_full_parity(
        "probe/full parity W8 boolean route", w8_probe_parity, baseline,
        "audited invocation source topology mismatch")
    cases += 1

    w16_probe_parity = copy.deepcopy(ledger)
    invocation_for(
        w16_probe_parity, 16, "reader:milestone:w16:story"
    )["exclusive_variant_groups"][0]["causal_status"] = "active"
    _expect_probe_full_parity(
        "probe/full parity W16 shadow group", w16_probe_parity, baseline,
        "audited invocation source topology mismatch")
    cases += 1

    for parity_name, stage_id in (
            ("W24 fresh", "w24:prepare_fresh"),
            ("W24 reentry", "w24:prepare_reentry"),
            ("W24 cold", "w24:story_resume_load"),
            ("W24 fatal", "w24:first_bill_fatal_return"),
            ("W24 completion three-way", "w24:completion_validation:loaded")):
        w24_probe_parity = copy.deepcopy(ledger)
        stage_for(
            w24_probe_parity, 24, stage_id
        )["applicability_ids"].append("selftest:invalid_applicability")
        _expect_probe_full_parity(
            f"probe/full parity {parity_name}",
            w24_probe_parity, baseline,
            "audited execution stage source topology mismatch")
        cases += 1
    if (source_census_full_count < 2
            or source_census_skip_count < len(manifest_mutations)
            or source_census_fallback_count < 1):
        raise AssertionError(
            "self-test W24 census optimization coverage incomplete "
            f"full={source_census_full_count} "
            f"skip={source_census_skip_count} "
            f"fallback={source_census_fallback_count}")
    print(
        "CHAPTER1_CAUSAL_LEDGER_SELF_TEST_CENSUS "
        f"full={source_census_full_count} "
        f"skip={source_census_skip_count} "
        f"fallback={source_census_fallback_count}")
    return cases


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--self-test", action="store_true")
    parser.add_argument("--require-complete-chapter-one", action="store_true")
    parser.add_argument(
        "--dump-audited-maps", action="store_true",
        help="print the verified, expanded audit maps as canonical JSON")
    parser.add_argument(
        "--dump-synthetic-complete-manifest", action="store_true",
        help=("print the read-only Python-built W24 replacement manifest; "
              "it is never accepted as ledger input"))
    args = parser.parse_args()
    if args.dump_audited_maps:
        print(json.dumps({
            "byte_length": FROZEN_AUDITED_MAPS_BYTE_LENGTH,
            "item_counts": _FROZEN_AUDITED_MAP_COUNTS,
            "maps": _FROZEN_AUDITED_MAPS,
            "sha256": FROZEN_AUDITED_MAPS_SHA256,
        }, ensure_ascii=False, sort_keys=True, separators=(",", ":")))
        return 0
    try:
        ledger = _load_json(LEDGER_PATH)
        baseline = _load_json(BASELINE_PATH)
        if args.dump_synthetic_complete_manifest:
            _fixture, manifest = _complete_fixture(
                ledger, return_manifest=True)
            errors = _validate_synthetic_w24_fanin_manifest(
                ledger, _fixture, manifest)
            if errors:
                raise AssertionError(
                    f"synthetic manifest rejected: {errors}")
            print(json.dumps(
                manifest, ensure_ascii=False, sort_keys=True,
                separators=(",", ":")))
            return 0
        if args.self_test:
            self_test_started = time.monotonic()
            cases = self_test(ledger, baseline)
            print(
                "CHAPTER1_CAUSAL_LEDGER_SELF_TEST_OK "
                f"cases={cases} runtime={time.monotonic() - self_test_started:.2f}s "
                f"probes={_SELF_TEST_PROBE_COUNT} "
                f"probe_seconds={_SELF_TEST_PROBE_SECONDS:.2f} "
                f"full_validations={_SELF_TEST_FULL_COUNT} "
                f"full_seconds={_SELF_TEST_FULL_SECONDS:.2f} "
                f"full_fallbacks={_SELF_TEST_FULL_FALLBACK_COUNT}")
            return 0
        errors, metrics = validate(
            ledger, baseline,
            require_complete=args.require_complete_chapter_one,
            check_pointers=True,
        )
    except (ValueError, AssertionError) as exc:
        print(f"CHAPTER1_CAUSAL_LEDGER_FAIL {exc}", file=sys.stderr)
        return 1
    if errors:
        for error in errors:
            print(f"CHAPTER1_CAUSAL_LEDGER_ERROR {error}", file=sys.stderr)
        print(f"CHAPTER1_CAUSAL_LEDGER_FAIL errors={len(errors)}", file=sys.stderr)
        return 1
    if args.require_complete_chapter_one:
        print("CHAPTER1_CAUSAL_LEDGER_COMPLETE_OK authoritative=48/48 debt=0")
        return 0
    if metrics["missing"]:
        week_range = metrics["week_range"]
        weeks = f"{week_range[0]}..{week_range[1]}" if len(week_range) == 2 else "unknown"
        print(
            f"COVERAGE_GAP weeks={weeks} missing_slots={metrics['missing']} "
            f"authoritative={metrics['implemented']}/48")
    print(
        "CHAPTER1_CAUSAL_LEDGER_SNAPSHOT_VALID "
        f"debt_codes={len(metrics['debts'])} blocked={metrics.get('blocked', 0)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
