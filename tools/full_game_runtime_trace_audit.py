#!/usr/bin/env python3
"""Contract gate for fresh-title W1->W240 occurrence traces.

This audit deliberately separates three claims:

* profile/source validation proves the recorder contract is internally coherent;
* a validated JSONL proves one exact candidate/profile reached its declared target;
* neither result is a human density, presentation, pacing, sound, or fun verdict.

Runtime JSONL is evidence output and is never checked into the repository.
"""

from __future__ import annotations

import argparse
import copy
import hashlib
import json
import re
import sys
import tempfile
from collections import Counter
from pathlib import Path
from typing import Any, Iterable


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_PROFILES = ROOT / "tools" / "full_game_runtime_trace_profiles.json"
TRACE_SCRIPT = ROOT / "tools" / "FullGameRuntimeTrace.gd"
TRACE_SCENE = ROOT / "tools" / "FullGameRuntimeTrace.tscn"
TRACE_RUNNER = ROOT / "tools" / "run_full_game_runtime_trace.sh"
AUDIT_RUNNER = ROOT / "tools" / "audit.sh"
IMMERSION_LOOP_SCRIPT = ROOT / "tools" / "ImmersionLoopCheck.gd"
MAIN_GAME_SCRIPT = ROOT / "scenes" / "MainGame.gd"
AUDIO_MANAGER_SCRIPT = ROOT / "autoloads" / "AudioManager.gd"
AUDIT_RUNNER_SHA256 = (
    "61b3e67984e436d2031fdf867a726c630bb5d2c0ac9c4607b616dd1546c5ca96"
)

AUDIO_MIX_DRAIN_CRITICAL_BLOCK = (
    "\tvar time_since_last_mix: float = maxf(\n"
    "\t\t0.0, float(AudioServer.get_time_since_last_mix()))\n"
    "\tvar time_to_next_mix: float = maxf(\n"
    "\t\t0.0, float(AudioServer.get_time_to_next_mix()))\n"
    "\tvar mix_period_seconds := time_since_last_mix + time_to_next_mix\n"
    "\tvar drain_seconds := clampf(\n"
    "\t\ttime_to_next_mix + mix_period_seconds\n"
    "\t\t\t+ AUDIO_MIX_DRAIN_MARGIN_SECONDS,\n"
    "\t\tAUDIO_MIX_DRAIN_MARGIN_SECONDS,\n"
    "\t\tAUDIO_MIX_DRAIN_MAX_SECONDS)\n"
    "\t_audio_mix_drain_timer.start(drain_seconds)\n"
    "\tawait _audio_mix_drain_timer.timeout\n"
)
IMMERSION_SUBPROCESS_CRITICAL_BLOCK = (
    '    IMMERSION_HOME=$(make_isolated_home "gangnam-immersion-loop")\n'
    '    IMMERSION_RAW=$(run_limited env HOME="$IMMERSION_HOME" "$GODOT" '
    '--headless --quit-after 3600 res://tools/ImmersionLoopCheck.tscn 2>&1)\n'
    "    IMMERSION_STATUS=$?\n"
    '    cleanup_isolated_home "$IMMERSION_HOME"\n'
)
IMMERSION_STRESS_SECTION_BODY = (
    "  IMMERSION_EXIT=0\n"
    "  IMMERSION_PASSES=0\n"
    "  IMMERSION_RUN_INDEX=1\n"
    '  while [ "$IMMERSION_RUN_INDEX" -le '
    '"$IMMERSION_AUDIO_TEARDOWN_RUNS" ]; do\n'
    + IMMERSION_SUBPROCESS_CRITICAL_BLOCK
    + '    if godot_check_passed "$IMMERSION_RAW" "$IMMERSION_STATUS" \\\n'
    '        "IMMERSION_LOOP_CHECK_OK" teardown_strict; then\n'
    "      IMMERSION_PASSES=$((IMMERSION_PASSES + 1))\n"
    "    else\n"
    '      echo "$IMMERSION_RAW" | grep -E '
    '"IMMERSION_LOOP_CHECK_(OK|FAIL)|ERROR:|WARNING: ObjectDB|SCRIPT ERROR|Parse Error|Compile Error" '
    "| sed 's/^/  /'\n"
    "      IMMERSION_EXIT=1\n"
    "      break\n"
    "    fi\n"
    "    IMMERSION_RUN_INDEX=$((IMMERSION_RUN_INDEX + 1))\n"
    "  done\n"
    '  if [ "$IMMERSION_PASSES" -ne "$IMMERSION_AUDIO_TEARDOWN_RUNS" ]; then\n'
    "    IMMERSION_EXIT=1\n"
    '  elif [ "$IMMERSION_EXIT" -eq 0 ]; then\n'
    '    echo "  IMMERSION_LOOP_STRESS_OK runs=$IMMERSION_PASSES '
    'audio_teardown=3wav+2ogg"\n'
    "  fi\n"
)
AUDIT_GODOT_ERROR_POLICY_BLOCK = (
    "  local error_lines\n"
    "  local engine_error_pattern='ERROR:|SCRIPT ERROR|Parse Error|Compile Error|Failed to load script'\n"
    '  if [ "$error_mode" = "teardown_strict" ]; then\n'
    '    engine_error_pattern="$engine_error_pattern|WARNING: ObjectDB instances leaked at exit"\n'
    "  fi\n"
    '  error_lines=$(printf \'%s\\n\' "$output" | grep -iE "$engine_error_pattern")\n'
    '  if [ "$error_mode" != "strict" ] && [ "$error_mode" != "teardown_strict" ]; then\n'
    '    error_lines=$(printf \'%s\\n\' "$error_lines" \\\n'
    "      | grep -viE 'ERROR: [0-9]+ resources still in use at exit')\n"
    "  fi\n"
    '  if [ -n "$error_lines" ]; then\n'
    '    echo "  ✗ 성공 마커와 함께 Godot 오류가 출력됨"\n'
    "    return 1\n"
    "  fi\n"
    "  return 0\n"
)
AUDIT_OBJECTDB_SELF_TEST_BLOCK = (
    "if godot_check_passed $'AUDIT_GUARD_OBJECTDB_SELF_TEST_OK\\n"
    "WARNING: ObjectDB instances leaked at exit' \\\n"
    '    0 "AUDIT_GUARD_OBJECTDB_SELF_TEST_OK" teardown_strict >/dev/null; then\n'
    '  echo "❌ 내부 감사 오류 — ObjectDB 종료 누수 감지가 작동하지 않습니다."\n'
    "  exit 1\n"
    "fi\n"
)

SCHEMA_VERSION = 1
TRACE_SCHEMA_VERSION = 1
PROFILE_IDS = (
    "baseline_safe_people",
    "investment_property_daeun",
    "general_near_goal_father_passed",
)
EARLY_INVESTMENT_IDENTITY_PROFILES = {
    "investment_property_daeun",
    "general_near_goal_father_passed",
}
FORBIDDEN_USER_ARGS = (
    "--demo-build",
    "--core-loop-v2",
    "--core-loop-v2-playtest-build",
)
RECORD_TYPES = (
    "run_start",
    "week_open",
    "story_enter",
    "choice_offer",
    "story_choice",
    "story_result",
    "main_action_offer",
    "main_action_commit",
    "week_close",
    "ending_open",
    "ending_page",
    "run_end",
    "trace_error",
)
SUCCESS_REQUIRED_RECORD_TYPES = tuple(
    value for value in RECORD_TYPES if value != "trace_error"
)
COMMON_KEYS = {
    "schema_version",
    "record_type",
    "sequence",
    "candidate_commit",
    "candidate_tree",
    "candidate_dirty",
    "profile_id",
    "profile_hash",
    "seed",
    "locale",
    "week",
    "month",
    "chapter",
    "scene_path",
    "occurrence_id",
    "state_injection",
    "payload",
}
PROFILE_KEYS = {
    "id",
    "description",
    "seed",
    "locale",
    "input_mode",
    "default_choice",
    "modal_policy",
    "choice_overrides",
    "main_action_priority",
    "main_function_priority",
    "survival_policy",
    "asset_band_policy",
    "required_event_sequence",
    "required_edges",
    "required_event_occurrences",
    "target",
}
TARGET_KEYS = {
    "minimum_week",
    "ending_page_count",
    "minimum_total_assets",
    "maximum_total_assets",
    "required_flags_true",
    "required_flags_false",
    "required_ending_ids",
    "forbidden_ending_ids",
}
CHOICE_KEYS = {"index", "selection_mode"}
EDGE_KEYS = {"from", "to", "provenance"}
SURVIVAL_POLICY_KEYS = {
    "enter_health_at_or_below",
    "enter_mental_at_or_below",
    "resume_health_at_or_above",
    "resume_mental_at_or_above",
    "action_priority",
    "function_priority",
}
SURVIVAL_ACTION_PRIORITY = ["rest", "contact"]
SURVIVAL_FUNCTION_PRIORITY = ["_ap_free_time", "_ap_contact_person"]
ASSET_BAND_POLICY_KEYS = {
    "activate_at_total_assets",
    "action_priority",
    "function_priority",
}
ASSET_BAND_PROFILE_ID = "general_near_goal_father_passed"
ASSET_BAND_ACTION_PRIORITY = ["rest", "save"]
ASSET_BAND_FUNCTION_PRIORITY = ["_ap_free_time", "_ap_save_money"]
MODAL_POLICY_KEYS = {"study_type"}
PROFILE_STUDY_TYPES = {
    "baseline_safe_people": 0,
    "investment_property_daeun": 3,
    "general_near_goal_father_passed": 3,
}
GENERAL_PROFILE_ID = "general_near_goal_father_passed"
GENERAL_REQUIRED_CHOICE_OVERRIDE_EVENT = "cafe_cb_honest_in"
GENERAL_REQUIRED_CHOICE_OVERRIDE = {"index": 1, "selection_mode": "direct"}
GENERAL_SURVIVAL_CHOICE_OVERRIDES = {
    "arc_opp_jiyeon_bunyang": {"index": 1, "selection_mode": "direct"},
    "arc_36_night_doubt": {"index": 2, "selection_mode": "direct"},
    "amb_guarantee_00": {"index": 2, "selection_mode": "direct"},
    "arc_36_trust_crack": {"index": 1, "selection_mode": "direct"},
    "arc_35_path_cost": {"index": 1, "selection_mode": "direct"},
    "arc_35_habit_check": {"index": 1, "selection_mode": "direct"},
    "arc_36_reality_check": {"index": 1, "selection_mode": "direct"},
    "arc_year_three_crossroads": {"index": 1, "selection_mode": "direct"},
    "arc_36_body_signal": {"index": 1, "selection_mode": "direct"},
    "arc_jaehyuk_ghost_decision": {"index": 1, "selection_mode": "direct"},
}
PROPERTY_PROFILE_ID = "investment_property_daeun"
PROPERTY_LADDER_PROFILE_IDS = {
    "investment_property_daeun",
    "general_near_goal_father_passed",
}
PROPERTY_REQUIRED_CHOICE_OVERRIDE_EVENT = "arc_opp_sangchul_realty"
PROPERTY_REQUIRED_CHOICE_OVERRIDE = {"index": 1, "selection_mode": "direct"}
PROPERTY_CAST_GUARD_CHOICE_OVERRIDE_EVENT = "arc_sangchul_reckoning"
PROPERTY_CAST_GUARD_CHOICE_OVERRIDE = {"index": 1, "selection_mode": "direct"}
PROPERTY_REQUIRED_SEQUENCE_SLICE = (
    "arc_opp_sangchul_realty",
    "arc_sangchul_reckoning",
    "inv_redev_zone_tip",
    "arc_minseo_02_real",
    "inv_redev_completion_sale",
    "arc_y5_contract_cover_investment",
)
FIRST_INVESTMENT_BUY_DEADLINE_WEEK = 48
INVESTMENT_EVIDENCE = {"kind": "invest", "weight": 4, "version": 2}
INVESTMENT_EVIDENCE_ACTIONS = {
    "study_invest": ("study", "_ap_study"),
    "invest_buy": ("invest", "_ap_invest"),
    "invest_leverage": ("invest", "_ap_invest"),
}
PROVENANCE_VALUES = {"main_ingress", "queued", "follow_up", "same_turn", "deferred"}
HEX40 = re.compile(r"^[0-9a-f]{40}$")
HEX64 = re.compile(r"^[0-9a-f]{64}$")


class ContractError(ValueError):
    pass


def _load_json(path: Path) -> Any:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise ContractError(f"cannot read JSON {path}: {exc}") from exc


def _profile_hash(path: Path, profile_id: str) -> str:
    return hashlib.sha256(path.read_bytes() + b"\0" + profile_id.encode("utf-8")).hexdigest()


def _collect_event_ids() -> set[str]:
    result: set[str] = set()
    for path in sorted((ROOT / "content" / "events").glob("*.json")):
        raw = _load_json(path)
        rows = raw if isinstance(raw, list) else raw.get("events", [])
        if not isinstance(rows, list):
            continue
        for row in rows:
            if isinstance(row, dict) and isinstance(row.get("id"), str):
                result.add(row["id"])
    return result


def _collect_event_choice_counts() -> dict[str, int]:
    result: dict[str, int] = {}
    for path in sorted((ROOT / "content" / "events").glob("*.json")):
        raw = _load_json(path)
        rows = raw if isinstance(raw, list) else raw.get("events", [])
        if not isinstance(rows, list):
            continue
        for row in rows:
            if not isinstance(row, dict) or not isinstance(row.get("id"), str):
                continue
            choices = row.get("choices", [])
            result[row["id"]] = len(choices) if isinstance(choices, list) else 0
    return result


def _collect_main_ap_functions() -> set[str]:
    try:
        source = MAIN_GAME_SCRIPT.read_text(encoding="utf-8")
    except OSError as exc:
        raise ContractError(f"cannot read {MAIN_GAME_SCRIPT}: {exc}") from exc
    return set(re.findall(r"(?m)^func\s+(_ap_[A-Za-z0-9_]+)\s*\(", source))


def _string_list(value: Any, label: str, *, unique: bool = True) -> list[str]:
    if not isinstance(value, list) or any(not isinstance(item, str) or not item for item in value):
        raise ContractError(f"{label} must be a non-empty-string array")
    if unique and len(set(value)) != len(value):
        raise ContractError(f"{label} must not contain duplicates")
    return value


def _validate_choice(value: Any, label: str) -> None:
    if not isinstance(value, dict) or set(value) != CHOICE_KEYS:
        raise ContractError(f"{label} must have exact keys {sorted(CHOICE_KEYS)}")
    if not isinstance(value["index"], int) or value["index"] < 0:
        raise ContractError(f"{label}.index must be a non-negative integer")
    if value["selection_mode"] not in ("direct", "timed"):
        raise ContractError(f"{label}.selection_mode must be direct or timed")


def _gdscript_function_body(source: str, function_name: str) -> str:
    match = re.search(
        rf"(?ms)^func\s+{re.escape(function_name)}\s*\([^\n]*\)"
        rf"(?:\s*->\s*[^:\n]+)?\s*:\s*\n(.*?)(?=^func\s+|\Z)",
        source,
    )
    if match is None:
        raise ContractError(f"missing GDScript function {function_name}")
    return match.group(1)


def _validate_audio_mix_drain_critical_block(body: str, label: str) -> None:
    if body.count(AUDIO_MIX_DRAIN_CRITICAL_BLOCK) != 1:
        raise ContractError(
            f"{label} must keep the exact measured/clamped/direct-start audio "
            "mix drain block"
        )
    for identifier in (
        "time_since_last_mix",
        "time_to_next_mix",
        "mix_period_seconds",
        "drain_seconds",
    ):
        assignments = re.findall(
            rf"(?m)^\t(?:var\s+)?{re.escape(identifier)}"
            rf"(?:\s*:\s*[A-Za-z0-9_.]+)?\s*(?::=|\+=|-=|\*=|/=|=)",
            body,
        )
        if len(assignments) != 1:
            raise ContractError(
                f"{label} must assign {identifier} exactly once inside the "
                "sealed calculation block"
            )
    direct_starts = re.findall(
        r"(?m)^\t_audio_mix_drain_timer\.start\(drain_seconds\)\s*$",
        body,
    )
    if len(direct_starts) != 1:
        raise ContractError(
            f"{label} must start its owned timer exactly once with drain_seconds"
        )


def validate_profiles(path: Path = DEFAULT_PROFILES, *, check_events: bool = True) -> dict[str, dict[str, Any]]:
    raw = _load_json(path)
    if not isinstance(raw, dict) or set(raw) != {
        "schema_version", "trace_schema_version", "scope", "profiles"
    }:
        raise ContractError("profile document top-level schema drifted")
    if raw["schema_version"] != SCHEMA_VERSION or raw["trace_schema_version"] != TRACE_SCHEMA_VERSION:
        raise ContractError("profile/trace schema version drifted")
    scope = raw["scope"]
    if not isinstance(scope, dict):
        raise ContractError("scope must be an object")
    if scope.get("product_go") != "HOLD" or scope.get("human_density_gate") != "OPEN":
        raise ContractError("static/runtime contracts must keep product_go=HOLD and human_density_gate=OPEN")
    if tuple(scope.get("forbidden_user_args", [])) != FORBIDDEN_USER_ARGS:
        raise ContractError("forbidden runtime arguments drifted")
    if tuple(scope.get("required_record_types", [])) != RECORD_TYPES:
        raise ContractError("required JSONL record vocabulary drifted")
    forbidden_sources = _string_list(scope.get("forbidden_state_sources"), "scope.forbidden_state_sources")
    for required in ("save_slot", "fixture", "state_injection", "week_jump", "money_injection", "flag_injection"):
        if required not in forbidden_sources:
            raise ContractError(f"scope no longer forbids {required}")

    rows = raw["profiles"]
    if not isinstance(rows, list) or len(rows) != 3:
        raise ContractError("exactly three fresh-title profiles are required")
    event_ids = _collect_event_ids() if check_events else set()
    event_choice_counts = _collect_event_choice_counts() if check_events else {}
    main_ap_functions = _collect_main_ap_functions()
    profiles: dict[str, dict[str, Any]] = {}
    for index, profile in enumerate(rows):
        label = f"profiles[{index}]"
        if not isinstance(profile, dict) or set(profile) != PROFILE_KEYS:
            extra = sorted(set(profile) - PROFILE_KEYS) if isinstance(profile, dict) else []
            missing = sorted(PROFILE_KEYS - set(profile)) if isinstance(profile, dict) else sorted(PROFILE_KEYS)
            raise ContractError(f"{label} schema drifted; missing={missing} extra={extra}")
        profile_id = profile["id"]
        if not isinstance(profile_id, str) or not profile_id or profile_id in profiles:
            raise ContractError(f"{label}.id must be unique and non-empty")
        if not isinstance(profile["description"], str) or not profile["description"]:
            raise ContractError(f"{label}.description must be non-empty")
        if not isinstance(profile["seed"], int) or profile["seed"] <= 0:
            raise ContractError(f"{label}.seed must be a positive integer")
        if profile["locale"] != "ko" or profile["input_mode"] != "keyboard":
            raise ContractError(f"{label} R1 must use Korean keyboard input")
        _validate_choice(profile["default_choice"], f"{label}.default_choice")
        modal_policy = profile["modal_policy"]
        if not isinstance(modal_policy, dict) or set(modal_policy) != MODAL_POLICY_KEYS:
            raise ContractError(f"{label}.modal_policy schema drifted")
        if modal_policy["study_type"] != PROFILE_STUDY_TYPES.get(profile_id):
            raise ContractError(
                f"{label}.modal_policy.study_type must preserve its route policy"
            )
        overrides = profile["choice_overrides"]
        if not isinstance(overrides, dict):
            raise ContractError(f"{label}.choice_overrides must be an object")
        for event_id, choice in overrides.items():
            if not isinstance(event_id, str) or not event_id:
                raise ContractError(f"{label}.choice_overrides has an invalid event id")
            _validate_choice(choice, f"{label}.choice_overrides.{event_id}")
            if check_events and event_id not in event_ids:
                raise ContractError(f"{label} choice override references unknown event {event_id}")
            if check_events and choice["index"] >= event_choice_counts.get(event_id, 0):
                raise ContractError(
                    f"{label} choice override index {choice['index']} is outside "
                    f"{event_id}'s {event_choice_counts.get(event_id, 0)} authored choices"
                )
        if profile_id == GENERAL_PROFILE_ID and overrides.get(
                GENERAL_REQUIRED_CHOICE_OVERRIDE_EVENT) != GENERAL_REQUIRED_CHOICE_OVERRIDE:
            raise ContractError(
                f"{label} must choose authored choice 1 for "
                f"{GENERAL_REQUIRED_CHOICE_OVERRIDE_EVENT}"
            )
        if profile_id == GENERAL_PROFILE_ID:
            for event_id, required_choice in GENERAL_SURVIVAL_CHOICE_OVERRIDES.items():
                if overrides.get(event_id) != required_choice:
                    raise ContractError(
                        f"{label} must choose the authored survival choice for {event_id}"
                    )
        if profile_id in PROPERTY_LADDER_PROFILE_IDS and overrides.get(
                PROPERTY_REQUIRED_CHOICE_OVERRIDE_EVENT) != PROPERTY_REQUIRED_CHOICE_OVERRIDE:
            raise ContractError(
                f"{label} must choose authored choice 1 for "
                f"{PROPERTY_REQUIRED_CHOICE_OVERRIDE_EVENT}"
            )
        if profile_id == PROPERTY_PROFILE_ID and overrides.get(
                PROPERTY_CAST_GUARD_CHOICE_OVERRIDE_EVENT) != PROPERTY_CAST_GUARD_CHOICE_OVERRIDE:
            raise ContractError(
                f"{label} must preserve the authored Chapter 5 cast through "
                f"{PROPERTY_CAST_GUARD_CHOICE_OVERRIDE_EVENT} choice 1"
            )
        _string_list(profile["main_action_priority"], f"{label}.main_action_priority")
        functions = _string_list(profile["main_function_priority"], f"{label}.main_function_priority")
        if any(not value.startswith("_ap_") for value in functions):
            raise ContractError(f"{label}.main_function_priority contains a non-AP function")
        unknown_functions = sorted(set(functions) - main_ap_functions)
        if unknown_functions:
            raise ContractError(
                f"{label}.main_function_priority references unknown MainGame functions: "
                f"{unknown_functions}"
            )
        survival = profile["survival_policy"]
        if not isinstance(survival, dict) or set(survival) != SURVIVAL_POLICY_KEYS:
            raise ContractError(f"{label}.survival_policy schema drifted")
        for threshold_key in (
            "enter_health_at_or_below", "enter_mental_at_or_below",
            "resume_health_at_or_above", "resume_mental_at_or_above",
        ):
            threshold = survival[threshold_key]
            if not isinstance(threshold, int) or not 1 <= threshold <= 99:
                raise ContractError(
                    f"{label}.survival_policy.{threshold_key} must be an integer in 1..99"
                )
        if survival["enter_health_at_or_below"] >= survival["resume_health_at_or_above"] \
                or survival["enter_mental_at_or_below"] >= survival["resume_mental_at_or_above"]:
            raise ContractError(f"{label}.survival_policy must have a recovery hysteresis gap")
        survival_actions = _string_list(
            survival["action_priority"], f"{label}.survival_policy.action_priority"
        )
        survival_functions = _string_list(
            survival["function_priority"], f"{label}.survival_policy.function_priority"
        )
        if survival_actions != SURVIVAL_ACTION_PRIORITY \
                or survival_functions != SURVIVAL_FUNCTION_PRIORITY:
            raise ContractError(
                f"{label}.survival_policy must prefer visible rest then contact"
            )
        if not set(survival_actions).issubset(profile["main_action_priority"]) \
                or not set(survival_functions).issubset(functions):
            raise ContractError(
                f"{label}.survival_policy must preserve the profile's normal action vocabulary"
            )
        unknown_survival_functions = sorted(set(survival_functions) - main_ap_functions)
        if unknown_survival_functions:
            raise ContractError(
                f"{label}.survival_policy references unknown MainGame functions: "
                f"{unknown_survival_functions}"
            )
        asset_band_policy = profile["asset_band_policy"]
        if profile_id != ASSET_BAND_PROFILE_ID:
            if asset_band_policy is not None:
                raise ContractError(
                    f"{label}.asset_band_policy must stay null outside the general near-goal profile"
                )
        else:
            if not isinstance(asset_band_policy, dict) \
                    or set(asset_band_policy) != ASSET_BAND_POLICY_KEYS:
                raise ContractError(f"{label}.asset_band_policy schema drifted")
            activation_assets = asset_band_policy["activate_at_total_assets"]
            if isinstance(activation_assets, bool) \
                    or not isinstance(activation_assets, (int, float)) \
                    or activation_assets <= 0:
                raise ContractError(
                    f"{label}.asset_band_policy.activate_at_total_assets must be positive"
                )
            band_actions = _string_list(
                asset_band_policy["action_priority"],
                f"{label}.asset_band_policy.action_priority",
            )
            band_functions = _string_list(
                asset_band_policy["function_priority"],
                f"{label}.asset_band_policy.function_priority",
            )
            if band_actions != ASSET_BAND_ACTION_PRIORITY \
                    or band_functions != ASSET_BAND_FUNCTION_PRIORITY:
                raise ContractError(
                    f"{label}.asset_band_policy must use the exact safe visible "
                    "Rest-then-Save fallback"
                )
            if not set(band_actions).issubset(profile["main_action_priority"]) \
                    or not set(band_functions).issubset(functions):
                raise ContractError(
                    f"{label}.asset_band_policy escaped the profile's visible action vocabulary"
                )
            unknown_band_functions = sorted(set(band_functions) - main_ap_functions)
            if unknown_band_functions:
                raise ContractError(
                    f"{label}.asset_band_policy references unknown MainGame functions: "
                    f"{unknown_band_functions}"
                )
        sequence = _string_list(profile["required_event_sequence"], f"{label}.required_event_sequence")
        if check_events:
            unknown = sorted(set(sequence) - event_ids)
            if unknown:
                raise ContractError(f"{label} required sequence has unknown events: {unknown}")
        if profile_id == PROPERTY_PROFILE_ID:
            required_slice_size = len(PROPERTY_REQUIRED_SEQUENCE_SLICE)
            if not any(
                    tuple(sequence[start:start + required_slice_size])
                    == PROPERTY_REQUIRED_SEQUENCE_SLICE
                    for start in range(len(sequence) - required_slice_size + 1)):
                raise ContractError(
                    f"{label} must order the property ladder by actual runtime: "
                    "realty, reckoning, redev, Minseo, sale, then Chapter 5 cover"
                )
        edges = profile["required_edges"]
        if not isinstance(edges, list) or not edges:
            raise ContractError(f"{label}.required_edges must be non-empty")
        seen_edges: set[tuple[str, str, str]] = set()
        for edge_index, edge in enumerate(edges):
            if not isinstance(edge, dict) or set(edge) != EDGE_KEYS:
                raise ContractError(f"{label}.required_edges[{edge_index}] schema drifted")
            key = (edge["from"], edge["to"], edge["provenance"])
            if any(not isinstance(value, str) or not value for value in key):
                raise ContractError(f"{label}.required_edges[{edge_index}] values must be strings")
            if edge["provenance"] not in PROVENANCE_VALUES:
                raise ContractError(f"{label}.required_edges[{edge_index}] has invalid provenance")
            if key in seen_edges:
                raise ContractError(f"{label}.required_edges contains a duplicate")
            seen_edges.add(key)
            if check_events and (edge["from"] not in event_ids or edge["to"] not in event_ids):
                raise ContractError(f"{label}.required_edges[{edge_index}] references an unknown event")
        occurrences = profile["required_event_occurrences"]
        if not isinstance(occurrences, dict):
            raise ContractError(f"{label}.required_event_occurrences must be an object")
        for event_id, count in occurrences.items():
            if not isinstance(event_id, str) or not event_id or not isinstance(count, int) or count < 2:
                raise ContractError(f"{label}.required_event_occurrences must map event ids to integers >=2")
            if check_events and event_id not in event_ids:
                raise ContractError(f"{label}.required_event_occurrences references unknown event {event_id}")
        target = profile["target"]
        if not isinstance(target, dict) or set(target) != TARGET_KEYS:
            raise ContractError(f"{label}.target schema drifted")
        if target["minimum_week"] != 240 or target["ending_page_count"] != 6:
            raise ContractError(f"{label} must target W240 and six ending pages")
        for number_key in ("minimum_total_assets", "maximum_total_assets"):
            if target[number_key] is not None and (
                not isinstance(target[number_key], (int, float)) or target[number_key] < 0
            ):
                raise ContractError(f"{label}.target.{number_key} must be null or non-negative")
        if target["minimum_total_assets"] is not None and target["maximum_total_assets"] is not None \
                and target["minimum_total_assets"] > target["maximum_total_assets"]:
            raise ContractError(f"{label} asset target is inverted")
        if profile_id == ASSET_BAND_PROFILE_ID:
            minimum_assets = target["minimum_total_assets"]
            maximum_assets = target["maximum_total_assets"]
            if minimum_assets is None or maximum_assets is None:
                raise ContractError(
                    f"{label}.asset_band_policy requires a bounded asset target"
                )
            if asset_band_policy["activate_at_total_assets"] != minimum_assets:
                raise ContractError(
                    f"{label}.asset_band_policy must activate at the target floor"
                )
            if asset_band_policy["activate_at_total_assets"] >= maximum_assets:
                raise ContractError(
                    f"{label}.asset_band_policy activation must stay below the target ceiling"
                )
        for list_key in (
            "required_flags_true", "required_flags_false",
            "required_ending_ids", "forbidden_ending_ids",
        ):
            _string_list(target[list_key], f"{label}.target.{list_key}")
        if set(target["required_flags_true"]) & set(target["required_flags_false"]):
            raise ContractError(f"{label} requires a flag both true and false")
        if set(target["required_ending_ids"]) & set(target["forbidden_ending_ids"]):
            raise ContractError(f"{label} requires and forbids the same ending")
        if "instant_legend" not in target["forbidden_ending_ids"]:
            raise ContractError(f"{label} must keep instant_legend outside the W240 profile corpus")
        profiles[profile_id] = profile

    if tuple(profiles) != PROFILE_IDS:
        raise ContractError(f"profile identity/order drifted: {tuple(profiles)}")
    return profiles


def _validate_trace_script_source(source: str) -> None:
    for needle in (
        "extends Node",
        "run_started.connect",
        "weekly_commitment_finalized.connect",
        '"story_enter"',
        '"event_serial"',
        '"scene_instance_id"',
        '"main_ingress"',
        '"follow_up"',
        '"same_turn"',
        '"deferred"',
        '"source_paragraph_count"',
        '"runtime_page_count"',
        '"state_delta"',
        '"product_go": "HOLD"',
        '"human_density_gate": "OPEN"',
        "Input.parse_input_event",
        "func _select_visible_main_action(cards: Array[Button]) -> Button:",
        "var selected := _select_visible_main_action(cards)",
        "func _select_visible_modal_button(root: Node, modal_kind: String) -> Button:",
        "var modal_button := _select_visible_modal_button(",
        'root, "ap_job_id", job_buttons',
        'modal_kind == "jobs"',
        "visible job modal has no enabled keyboard-focusable application",
        'root, "ap_study_type", study_buttons',
        'modal_policy.get("study_type", -1)',
        "profile study_type %d is absent from the visible study modal",
        "func _survival_recovery_required() -> bool:",
        "if _survival_recovery_required():",
        "var recovery_selected := _select_visible_by_priority(",
        "var health := int(GameState.health)",
        "var mental := int(GameState.mental)",
        "func _asset_band_hold_required() -> bool:",
        "if _asset_band_hold_required():",
        'policy.get("activate_at_total_assets", -1.0)',
        "float(GameState.get_total_asset_value()) >= activation_assets",
        '_main_selection_policy = "asset_band_hold"',
        '"asset band policy has no visible safe action"',
        '_pending_main_action["selection_policy"] = _main_selection_policy',
        "const MAX_MAIN_ACTION_FOCUS_ATTEMPTS := 3",
        "await _activate_settled_main_action_button(selected)",
        "func _activate_settled_main_action_button(button_raw: Variant) -> void:",
        "for _attempt in range(MAX_MAIN_ACTION_FOCUS_ATTEMPTS):",
        '"visible MainGame action could not retain exact keyboard focus: "',
        '"visible MainGame action identity drift: "',
        "committed_action_id != expected_action_id",
        "if not GameState.pending_story_queue.is_empty():",
        'const TUTORIAL_OVERLAY_SCRIPT := "res://scenes/TutorialOverlay.gd"',
        "var tutorial_overlay := _active_main_tutorial_overlay(main)",
        "func _active_main_tutorial_overlay(root: Node) -> Control:",
        'call_deferred("_graceful_shutdown", 0)',
        "func _graceful_shutdown(exit_code: int) -> void:",
        "await _release_audio_for_exit()",
        "func _release_audio_for_exit() -> void:",
        "await _release_active_scene_for_exit()",
        "func _release_active_scene_for_exit() -> void:",
        "_detach_audio_streams(get_tree().root)",
        "player.stream = null",
        "(raw_sounds as Dictionary).clear()",
        "await AudioManager.drain_pending_timers_for_exit()",
        "await _drain_audio_server_after_stop()",
        "var _audio_mix_drain_timer: Timer",
        "func _drain_audio_server_after_stop() -> void:",
        "AudioServer.get_time_to_next_mix()",
        "AudioServer.get_time_since_last_mix()",
        "await _audio_mix_drain_timer.timeout",
    ):
        if needle not in source:
            raise ContractError(f"GDScript recorder contract is missing {needle!r}")
    for dedup_pattern in (
        "seen_events",
        "if event_id not in _story",
        "if not _story_event_ids.has(event_id)",
    ):
        if dedup_pattern in source:
            raise ContractError(f"GDScript appears to deduplicate event IDs: {dedup_pattern}")
    if re.search(r"\bcallv\s*\(", source):
        raise ContractError("GDScript recorder must not execute a dynamic callv action")
    if re.search(r"\bpressed\.emit\s*\(", source) \
            or re.search(r"\bemit_signal\s*\(\s*['\"]pressed['\"]", source):
        raise ContractError(
            "GDScript recorder must use real input, not emit Button.pressed"
        )
    if re.search(
        r"\bGameState\.\w+\s*(?:\+=|-=|\*=|/=|(?<![=!<>])=(?!=))",
        source,
    ) or re.search(
        r"\bGameState\.\w+\s*\[[^\]]+\]\s*(?:\+=|-=|\*=|/=|(?<![=!<>])=(?!=))",
        source,
    ) or re.search(
        r"\bGameState\.\w+\.(?:append|append_array|assign|clear|erase|merge|pop_at|pop_back|push_back|remove_at)\s*\(",
        source,
    ):
        raise ContractError("GDScript recorder directly mutates GameState")
    if re.search(r"\bGameState\s*\[[^\]]+\]\s*=", source) \
            or re.search(
                r"\bGameState\.\w+\.\w+\s*(?:\+=|-=|\*=|/=|(?<![=!<>])=(?!=))",
                source,
            ) \
            or re.search(
                r"\b(?:var|const)\s+\w+(?:\s*:[^=\n]+)?\s*(?::=|=)\s*GameState\b(?!\s*\.)",
                source,
            ) \
            or re.search(
                r"\b(?:var|const)\s+\w+(?:\s*:[^=\n]+)?\s*(?::=|=)\s*GameState\.[A-Za-z_]\w*\s*(?:$|[;#])",
                source,
                re.MULTILINE,
            ):
        raise ContractError("GDScript recorder aliases or indexes mutable GameState")
    allowed_state_methods = {
        "chapter5_causal_is_owned_event",
        "chapter5_finale_is_owned_event",
        "format_event_text",
        "get_total_asset_value",
        "is_story_weekly_commitment_record",
    }
    direct_state_methods = set(re.findall(
        r"\bGameState\.([A-Za-z_]\w*)\s*\(", source
    ))
    unexpected_state_methods = sorted(direct_state_methods - allowed_state_methods)
    if unexpected_state_methods:
        raise ContractError(
            "GDScript recorder calls a mutating/unapproved GameState method: "
            + ", ".join(unexpected_state_methods)
        )
    allowed_nested_state_methods = {
        "connect", "disconnect", "duplicate", "get", "is_connected", "is_empty",
    }
    nested_state_methods = set(re.findall(
        r"\bGameState\.[A-Za-z_]\w*\.([A-Za-z_]\w*)\s*\(", source
    ))
    unexpected_nested_methods = sorted(
        nested_state_methods - allowed_nested_state_methods
    )
    if unexpected_nested_methods:
        raise ContractError(
            "GDScript recorder mutates a GameState-owned container/signal: "
            + ", ".join(unexpected_nested_methods)
        )
    # The sole product method call is a read-only surface-state query. All
    # actions must resolve to an actually visible Button and then use input.
    method_calls = re.findall(r"\b[A-Za-z_]\w*\.call\s*\([^\n)]*\)", source)
    allowed_calls = {
        'main.call("_demo_director_requires_player_input")',
        'story.call("_direct_continue_choice_index")',
    }
    unexpected_calls = sorted(set(method_calls) - allowed_calls)
    if unexpected_calls:
        raise ContractError(
            "GDScript recorder directly calls a product method: "
            + ", ".join(unexpected_calls)
        )

    drive_body = _gdscript_function_body(source, "_drive_main")
    tutorial_start = drive_body.find(
        "\tvar tutorial_overlay := _active_main_tutorial_overlay(main)"
    )
    modal_start = drive_body.find('\tvar modal := main.get("modal_layer") as Control')
    cards_start = drive_body.find(
        '\tvar cards_raw: Variant = main.get("_ap_grid_cards")'
    )
    if not 0 <= tutorial_start < modal_start < cards_start:
        raise ContractError(
            "visible TutorialOverlay must be driven before MainGame modal/cards"
        )
    pending_guard = (
        "\tif not GameState.pending_story_queue.is_empty():\n"
        "\t\treturn false\n"
    )
    guard_start = drive_body.find(pending_guard)
    if guard_start < 0 or guard_start >= tutorial_start:
        raise ContractError(
            "queued-story guard must precede the TutorialOverlay input owner"
        )
    pre_tutorial_gap = drive_body[
        guard_start + len(pending_guard):tutorial_start
    ]
    for forbidden_dispatch in (
        "_activate_button(",
        "_activate_settled_main_action_button(",
        "_send_key(",
        "Input.parse_input_event",
    ):
        if forbidden_dispatch in pre_tutorial_gap:
            raise ContractError(
                "input dispatch bypasses the visible TutorialOverlay owner: "
                + forbidden_dispatch
            )
    tutorial_block = drive_body[tutorial_start:modal_start]
    tutorial_pattern = re.compile(
        r"(?m)^\tvar tutorial_overlay := _active_main_tutorial_overlay\(main\)\n"
        r"\tif tutorial_overlay != null:\n"
        r"\t\tvar tutorial_button := _focused_or_first_button\(tutorial_overlay\)\n"
        r"\t\tif tutorial_button != null:\n"
        r"\t\t\tawait _activate_button\(tutorial_button\)\n"
        r"\t\treturn false\n"
    )
    if tutorial_pattern.search(tutorial_block) is None:
        raise ContractError(
            "TutorialOverlay must use its real button and block card fallthrough"
        )
    tutorial_helper_body = _gdscript_function_body(
        source, "_active_main_tutorial_overlay"
    )
    ordered_tutorial_markers = (
        "for child in root.get_children():",
        "if child is Control",
        "not child.is_queued_for_deletion()",
        "(child as Control).is_visible_in_tree()",
        "_scene_script_path(child) == TUTORIAL_OVERLAY_SCRIPT",
        "return child as Control",
        "var nested := _active_main_tutorial_overlay(child)",
        "if nested != null:",
        "return nested",
    )
    previous_marker = -1
    for marker in ordered_tutorial_markers:
        if marker not in tutorial_helper_body:
            raise ContractError(
                f"TutorialOverlay discovery contract is missing {marker!r}"
            )
        marker_index = tutorial_helper_body.index(marker)
        if marker_index <= previous_marker:
            raise ContractError(
                "TutorialOverlay discovery order drifted at " + repr(marker)
            )
        previous_marker = marker_index
    for required_and in (
        "and not child.is_queued_for_deletion()",
        "and (child as Control).is_visible_in_tree()",
        "and _scene_script_path(child) == TUTORIAL_OVERLAY_SCRIPT",
    ):
        if required_and not in tutorial_helper_body:
            raise ContractError(
                f"TutorialOverlay discovery must keep conjunctive guard {required_and!r}"
            )
    if tutorial_helper_body.rfind("return null") <= previous_marker:
        raise ContractError("TutorialOverlay discovery must fail closed after recursion")

    activation_body = _gdscript_function_body(source, "_activate_button")
    for marker in (
        "button.grab_focus()",
        "var focused := get_viewport().gui_get_focus_owner()",
        "if focused != button:",
        "await _send_key(KEY_ENTER)",
    ):
        if marker not in activation_body:
            raise ContractError(
                f"visible button activation focus contract is missing {marker!r}"
            )
    activation_grab = activation_body.index("button.grab_focus()")
    activation_owner = activation_body.index(
        "var focused := get_viewport().gui_get_focus_owner()"
    )
    activation_exact = activation_body.index("if focused != button:")
    activation_enter = activation_body.index("await _send_key(KEY_ENTER)")
    if not activation_grab < activation_owner < activation_exact < activation_enter:
        raise ContractError(
            "visible button activation must grab, verify exact owner, then send Enter"
        )

    focus_body = _gdscript_function_body(
        source, "_activate_settled_main_action_button"
    )
    if focus_body.count("await get_tree().process_frame") < 2:
        raise ContractError(
            "MainGame action focus must settle across product-deferred frames"
        )
    for marker in (
        "button.grab_focus()",
        "focused == button",
        "await _send_key(KEY_ENTER)",
        "_fail(",
    ):
        if marker not in focus_body:
            raise ContractError(
                f"MainGame action focus contract is missing {marker!r}"
            )
    for forbidden in (
        "_activate_button(",
        "_find_first_enabled_button(",
        "_focused_or_first_button(",
        "pressed.emit(",
        'emit_signal("pressed"',
    ):
        if forbidden in focus_body:
            raise ContractError(
                f"MainGame action focus uses a forbidden fallback: {forbidden}"
            )
    first_settle = focus_body.index("await get_tree().process_frame")
    grab_focus = focus_body.index("button.grab_focus()")
    post_grab_settle = focus_body.index(
        "await get_tree().process_frame", grab_focus
    )
    exact_focus = focus_body.index("if focused == button:")
    send_enter = focus_body.index("await _send_key(KEY_ENTER)")
    if not first_settle < grab_focus < post_grab_settle < exact_focus < send_enter:
        raise ContractError(
            "MainGame action focus must settle, grab, verify, then send Enter"
        )
    send_key_body = _gdscript_function_body(source, "_send_key")
    if send_key_body.count("Input.parse_input_event") != 2 \
            or "InputEventKey.new()" not in send_key_body:
        raise ContractError(
            "runtime trace must send exact press/release InputEventKey edges"
        )

    commitment_body = _gdscript_function_body(
        source, "_on_weekly_commitment_finalized"
    )
    identity_guard = (
        "if expected_action_id.is_empty() "
        "or committed_action_id != expected_action_id:"
    )
    for marker in (
        '_pending_main_action.get("action_id", "")',
        'commitment.get("choice_id", "")',
        identity_guard,
        '"action_id": committed_action_id',
    ):
        if marker not in commitment_body:
            raise ContractError(
                f"MainGame action commitment identity seal is missing {marker!r}"
            )
    if commitment_body.index(identity_guard) > commitment_body.index(
            '_record("main_action_commit"'):
        raise ContractError(
            "MainGame action commitment identity must fail before recording"
        )

    release_body = _gdscript_function_body(source, "_release_audio_for_exit")
    if "get_tree().create_timer" in release_body:
        raise ContractError(
            "runtime exit must not wait on an obsolete free SceneTreeTimer"
        )
    if release_body.count("await get_tree().process_frame") < 2:
        raise ContractError("runtime audio teardown must drain two process frames")
    audio_manager_drain = release_body.index(
        "await AudioManager.drain_pending_timers_for_exit()"
    )
    audio_server_drain = release_body.index(
        "await _drain_audio_server_after_stop()"
    )
    first_process_frame = release_body.index("await get_tree().process_frame")
    if not audio_manager_drain < audio_server_drain < first_process_frame:
        raise ContractError(
            "runtime audio teardown must drain tracked cues, then two real mix boundaries"
        )

    mix_drain_body = _gdscript_function_body(
        source, "_drain_audio_server_after_stop"
    )
    ordered_mix_drain_markers = (
        "if not is_instance_valid(_audio_mix_drain_timer):",
        "_audio_mix_drain_timer = Timer.new()",
        "_audio_mix_drain_timer.one_shot = true",
        "_audio_mix_drain_timer.process_mode = Node.PROCESS_MODE_ALWAYS",
        "add_child(_audio_mix_drain_timer)",
        "AudioServer.get_time_since_last_mix()",
        "AudioServer.get_time_to_next_mix()",
        "time_since_last_mix + time_to_next_mix",
        "AUDIO_MIX_DRAIN_MARGIN_SECONDS",
        "AUDIO_MIX_DRAIN_MAX_SECONDS",
        "_audio_mix_drain_timer.start(drain_seconds)",
        "await _audio_mix_drain_timer.timeout",
    )
    previous_marker = -1
    for marker in ordered_mix_drain_markers:
        if marker not in mix_drain_body:
            raise ContractError(
                f"audio mix drain contract is missing {marker!r}"
            )
        marker_index = mix_drain_body.index(marker)
        if marker_index <= previous_marker:
            raise ContractError(
                "audio mix drain ownership/order drifted at " + repr(marker)
            )
        previous_marker = marker_index
    if "get_tree().create_timer" in mix_drain_body:
        raise ContractError(
            "audio mix drain must use its owned child Timer"
        )
    _validate_audio_mix_drain_critical_block(
        mix_drain_body, "runtime trace audio teardown"
    )
    for exact_contract in (
        "const AUDIO_MIX_DRAIN_MARGIN_SECONDS := 0.02",
        "const AUDIO_MIX_DRAIN_MAX_SECONDS := 0.25",
        "time_since_last_mix + time_to_next_mix",
        "time_to_next_mix + mix_period_seconds",
    ):
        if exact_contract not in source:
            raise ContractError(
                f"audio mix drain numeric/data-flow contract is missing {exact_contract!r}"
            )

    shutdown_body = _gdscript_function_body(source, "_graceful_shutdown")
    audio_release = shutdown_body.index("await _release_audio_for_exit()")
    scene_release = shutdown_body.index("await _release_active_scene_for_exit()")
    tree_quit = shutdown_body.index("get_tree().quit(exit_code)")
    if not audio_release < scene_release < tree_quit:
        raise ContractError(
            "runtime teardown must release audio and active scene before quit"
        )
    scene_release_body = _gdscript_function_body(
        source, "_release_active_scene_for_exit"
    )
    for marker in (
        "var active_scene := get_tree().current_scene",
        "active_scene == self",
        "get_tree().current_scene = null",
        "active_scene.queue_free()",
    ):
        if marker not in scene_release_body:
            raise ContractError(
                f"runtime active-scene teardown is missing {marker!r}"
            )
    if scene_release_body.count("await get_tree().process_frame") < 2:
        raise ContractError(
            "runtime active-scene teardown must drain two process frames"
        )


def _validate_main_game_timer_source(source: str) -> None:
    for marker in (
        "var _critical_portrait_timer: Timer",
        "var _milestone_portrait_timer: Timer",
        "var _milestone_portrait_active: bool",
        "func _init_transient_portrait_timers() -> void:",
        "func _arm_critical_portrait_feedback() -> void:",
        "func _on_critical_portrait_timeout() -> void:",
        "func _on_milestone_portrait_timeout() -> void:",
        "func _exit_tree() -> void:",
    ):
        if marker not in source:
            raise ContractError(
                f"MainGame transient portrait timer contract is missing {marker!r}"
            )

    init_body = _gdscript_function_body(
        source, "_init_transient_portrait_timers"
    )
    for marker in (
        "_critical_portrait_timer.one_shot = true",
        "_critical_portrait_timer.wait_time = 1.2",
        "_critical_portrait_timer.process_mode = Node.PROCESS_MODE_ALWAYS",
        "add_child(_critical_portrait_timer)",
        "_critical_portrait_timer.timeout.connect(_on_critical_portrait_timeout)",
        "_milestone_portrait_timer.one_shot = true",
        "_milestone_portrait_timer.wait_time = 2.0",
        "_milestone_portrait_timer.process_mode = Node.PROCESS_MODE_ALWAYS",
        "add_child(_milestone_portrait_timer)",
        "_milestone_portrait_timer.timeout.connect(_on_milestone_portrait_timeout)",
    ):
        if marker not in init_body:
            raise ContractError(
                f"MainGame child Timer initialization is missing {marker!r}"
            )

    critical_body = _gdscript_function_body(
        source, "_arm_critical_portrait_feedback"
    )
    for marker in (
        'GameState.flags["just_critical_event"] = true',
        "_update_portrait()",
        "_critical_portrait_timer.start()",
    ):
        if marker not in critical_body:
            raise ContractError(
                f"MainGame critical timer path is missing {marker!r}"
            )
    choose_body = _gdscript_function_body(source, "_choose")
    if "_arm_critical_portrait_feedback()" not in choose_body:
        raise ContractError("critical event choice no longer arms its owned Timer")

    critical_timeout_body = _gdscript_function_body(
        source, "_on_critical_portrait_timeout"
    )
    for marker in (
        'GameState.flags["just_critical_event"] = false',
        "_update_portrait()",
    ):
        if marker not in critical_timeout_body:
            raise ContractError(
                f"MainGame critical timeout is missing {marker!r}"
            )

    milestone_body = _gdscript_function_body(source, "_check_milestones")
    if "get_tree().create_timer" in milestone_body \
            or re.search(r"(?m)^\s*await\b", milestone_body):
        raise ContractError(
            "_check_milestones must not suspend on a free SceneTreeTimer"
        )
    for marker in (
        "_milestone_portrait_active",
        "_milestone_portrait_active = true",
        "_milestone_portrait_timer.start()",
        "return",
    ):
        if marker not in milestone_body:
            raise ContractError(
                f"_check_milestones state machine is missing {marker!r}"
            )
    if milestone_body.index("_milestone_portrait_active = true") \
            > milestone_body.index("_milestone_portrait_timer.start()"):
        raise ContractError(
            "milestone reentry guard must arm before its Timer starts"
        )

    milestone_timeout_body = _gdscript_function_body(
        source, "_on_milestone_portrait_timeout"
    )
    for marker in (
        'GameState.flags["just_hit_milestone"] = false',
        "_update_portrait()",
        "_milestone_portrait_active = false",
        'call_deferred("_check_milestones")',
    ):
        if marker not in milestone_timeout_body:
            raise ContractError(
                f"milestone timeout continuation is missing {marker!r}"
            )

    exit_body = _gdscript_function_body(source, "_exit_tree")
    for marker in (
        "_critical_portrait_timer.stop()",
        "_milestone_portrait_timer.stop()",
        "_milestone_portrait_active = false",
        'GameState.flags["just_critical_event"] = false',
        'GameState.flags["just_hit_milestone"] = false',
    ):
        if marker not in exit_body:
            raise ContractError(
                f"MainGame exit cleanup is missing {marker!r}"
            )


def _validate_audio_manager_source(source: str) -> None:
    for needle in (
        "var _pending_audio_timers: Dictionary = {}",
        "func _schedule_audio_timer(delay: float, callback: Callable) -> void:",
        "func drain_pending_timers_for_exit() -> void:",
        "_pending_audio_timer_generation += 1",
        "(raw_timer as SceneTreeTimer).time_left = 0.0",
        "assert(_pending_audio_timers.is_empty()",
    ):
        if needle not in source:
            raise ContractError(f"AudioManager timer drain contract is missing {needle!r}")
    if source.count("get_tree().create_timer(") != 1:
        raise ContractError(
            "AudioManager delayed audio must use the single tracked timer scheduler"
        )
    if source.count("_schedule_audio_timer(delay,") != 3:
        raise ContractError("AudioManager delayed cue call sites escaped timer tracking")


def _validate_immersion_audio_teardown_source(source: str) -> None:
    for marker in (
        "const AUDIO_MIX_DRAIN_MARGIN_SECONDS := 0.02",
        "const AUDIO_MIX_DRAIN_MAX_SECONDS := 0.25",
        "var _audio_mix_drain_timer: Timer",
        "const AUDIO_TEARDOWN_PROBE_PATHS: Array[String] = [",
        '"res://assets/audio/sfx_click.wav"',
        '"res://assets/audio/sfx_open_modal.wav"',
        '"res://assets/audio/sfx_ending_stinger_good.wav"',
        '"res://assets/audio/bgm_reckoning.ogg"',
        '"res://assets/audio/bgm_victory.ogg"',
        "await _arm_audio_teardown_probe()",
        "func _arm_audio_teardown_probe() -> void:",
        "for index in range(AUDIO_TEARDOWN_PROBE_PATHS.size()):",
        "load(AUDIO_TEARDOWN_PROBE_PATHS[index]) as AudioStream",
        "player.stream = probe_stream",
        "player.play()",
        "await get_tree().process_frame",
        "await _drain_audio_server_after_stop()",
        "func _drain_audio_server_after_stop() -> void:",
        "_audio_mix_drain_timer.one_shot = true",
        "_audio_mix_drain_timer.process_mode = Node.PROCESS_MODE_ALWAYS",
        "AudioServer.get_time_since_last_mix()",
        "AudioServer.get_time_to_next_mix()",
        "time_since_last_mix + time_to_next_mix",
        "time_to_next_mix + mix_period_seconds",
        "await _audio_mix_drain_timer.timeout",
        "audio_teardown=3wav+2ogg",
    ):
        if marker not in source:
            raise ContractError(
                f"focused audio teardown runtime fixture is missing {marker!r}"
            )
    release_body = _gdscript_function_body(source, "_release_audio_for_exit")
    drain_body = _gdscript_function_body(
        source, "_drain_audio_server_after_stop"
    )
    if "get_tree().create_timer" in release_body + drain_body:
        raise ContractError(
            "focused audio teardown fixture must not use a free SceneTreeTimer"
        )
    if "AudioStreamGenerator.new()" in source:
        raise ContractError(
            "focused audio teardown fixture must use the exact leaked WAV/OGG assets"
        )
    if source.count('"res://assets/audio/') != 5:
        raise ContractError(
            "focused audio teardown fixture must own exactly five leaked asset paths"
        )
    _validate_audio_mix_drain_critical_block(
        drain_body, "focused audio teardown fixture"
    )
    previous_marker = -1
    for marker in (
        "AudioServer.get_time_since_last_mix()",
        "AudioServer.get_time_to_next_mix()",
        "time_since_last_mix + time_to_next_mix",
        "time_to_next_mix + mix_period_seconds",
        "await _audio_mix_drain_timer.timeout",
    ):
        marker_index = drain_body.index(marker)
        if marker_index <= previous_marker:
            raise ContractError(
                "focused audio teardown sample/data-flow order drifted at "
                + repr(marker)
            )
        previous_marker = marker_index


def _validate_audit_runtime_guard(source_input: str | bytes) -> None:
    source_bytes = (
        source_input.encode("utf-8")
        if isinstance(source_input, str)
        else source_input
    )
    try:
        source = source_bytes.decode("utf-8")
    except UnicodeDecodeError as exc:
        raise ContractError("audit runtime runner is not valid UTF-8") from exc
    source_sha256 = hashlib.sha256(source_bytes).hexdigest()
    if source_sha256 != AUDIT_RUNNER_SHA256:
        raise ContractError(
            "audit runtime runner exact-source seal drifted: "
            f"expected {AUDIT_RUNNER_SHA256}, got {source_sha256}"
        )
    for marker in (
        "WARNING: ObjectDB instances leaked at exit",
        "AUDIT_GUARD_OBJECTDB_SELF_TEST_OK",
        "IMMERSION_AUDIO_TEARDOWN_RUNS=12",
        'while [ "$IMMERSION_RUN_INDEX" -le "$IMMERSION_AUDIO_TEARDOWN_RUNS" ]',
        "IMMERSION_PASSES=$((IMMERSION_PASSES + 1))",
        'if [ "$IMMERSION_PASSES" -ne "$IMMERSION_AUDIO_TEARDOWN_RUNS" ]',
        "IMMERSION_LOOP_STRESS_OK runs=$IMMERSION_PASSES audio_teardown=3wav+2ogg",
        '"IMMERSION_LOOP_CHECK_OK" teardown_strict',
    ):
        if marker not in source:
            raise ContractError(
                f"audit runtime teardown guard is missing {marker!r}"
            )
    if source.count(AUDIT_GODOT_ERROR_POLICY_BLOCK) != 1:
        raise ContractError(
            "audit must keep the exact compiler/strict/teardown_strict error policy"
        )
    if source.count(AUDIT_OBJECTDB_SELF_TEST_BLOCK) != 1:
        raise ContractError(
            "audit must execute the exact ObjectDB teardown guard self-test"
        )
    for function_name in (
        "run_limited",
        "cleanup_isolated_home",
        "godot_check_passed",
    ):
        definitions = re.findall(
            rf"(?m)^(?:function\s+)?{re.escape(function_name)}"
            rf"(?:\(\))?\s*\{{$",
            source,
        )
        if len(definitions) != 1:
            raise ContractError(
                f"audit helper {function_name} must have exactly one definition"
            )
        if re.search(
            rf"(?m)^\s*{re.escape(function_name)}=", source
        ):
            raise ContractError(
                f"audit helper {function_name} must not be reassigned"
            )
    expected_state_assignments = {
        "IMMERSION_AUDIO_TEARDOWN_RUNS": 1,
        "IMMERSION_EXIT": 4,
        "IMMERSION_PASSES": 2,
        "IMMERSION_RUN_INDEX": 2,
        "IMMERSION_HOME": 1,
        "IMMERSION_RAW": 1,
        "IMMERSION_STATUS": 1,
    }
    for identifier, expected_count in expected_state_assignments.items():
        assignment_count = len(re.findall(
            rf"(?m)^\s*{re.escape(identifier)}=", source
        ))
        if assignment_count != expected_count:
            raise ContractError(
                f"audit must assign {identifier} exactly {expected_count} times"
            )
    if re.search(
        r"(?m)\b(?:printf\s+-v|unset|export|readonly)\s+IMMERSION_", source
    ):
        raise ContractError(
            "audit must not mutate immersion verdict state through an indirect shell write"
        )
    if "MORAL_AMBIENCE_EXIT IMMERSION_EXIT" not in source:
        raise ContractError(
            "audit must carry IMMERSION_EXIT into the final aggregate gate"
        )
    if len(re.findall(
        r"(?m)^IMMERSION_AUDIO_TEARDOWN_RUNS=12$", source
    )) != 1:
        raise ContractError("audit must require exactly 12 immersion subprocesses")
    immersion_section_match = re.search(
        r'(?ms)^echo "● 주간 행동 에코·인과 프레임·비네트·예감·SFX 믹스 검사"\n'
        r'if \[ -x "\$GODOT" \]; then\n(.*?)^else$',
        source,
    )
    if immersion_section_match is None:
        raise ContractError("audit immersion stress section is missing")
    immersion_section = immersion_section_match.group(1)
    if immersion_section != IMMERSION_STRESS_SECTION_BODY:
        raise ContractError(
            "audit must keep the exact subprocess/output/verdict/count stress section"
        )
    ordered_stress_lines = (
        "  IMMERSION_EXIT=0",
        "  IMMERSION_PASSES=0",
        "  IMMERSION_RUN_INDEX=1",
        '  while [ "$IMMERSION_RUN_INDEX" -le "$IMMERSION_AUDIO_TEARDOWN_RUNS" ]; do',
        "      IMMERSION_PASSES=$((IMMERSION_PASSES + 1))",
        "    IMMERSION_RUN_INDEX=$((IMMERSION_RUN_INDEX + 1))",
        "  done",
        '  if [ "$IMMERSION_PASSES" -ne "$IMMERSION_AUDIO_TEARDOWN_RUNS" ]; then',
    )
    previous_line = -1
    for line in ordered_stress_lines:
        matches = list(re.finditer(
            rf"(?m)^{re.escape(line)}$", immersion_section
        ))
        if len(matches) != 1 or matches[0].start() <= previous_line:
            raise ContractError(
                f"audit must keep one ordered 12-process stress line {line!r}"
            )
        previous_line = matches[0].start()
    if len(re.findall(
        r"(?m)^\s+IMMERSION_RUN_INDEX=", immersion_section
    )) != 2:
        raise ContractError(
            "audit audio stress loop must initialize and increment its run index once"
        )
    if len(re.findall(
        r"(?m)^\s+IMMERSION_PASSES=", immersion_section
    )) != 2:
        raise ContractError(
            "audit audio stress loop must initialize and increment its pass count once"
        )
    if source.count("res://tools/ImmersionLoopCheck.tscn") != 1:
        raise ContractError(
            "audit must invoke the focused immersion fixture once inside its loop body"
        )
    stress_loop = re.search(
        r'(?ms)^  while \[ "\$IMMERSION_RUN_INDEX" -le '
        r'"\$IMMERSION_AUDIO_TEARDOWN_RUNS" \]; do\n(.*?)^  done$',
        immersion_section,
    )
    if stress_loop is None:
        raise ContractError("audit audio teardown stress loop body is not sealed")
    stress_loop_body = stress_loop.group(1)
    if not stress_loop_body.startswith(IMMERSION_SUBPROCESS_CRITICAL_BLOCK):
        raise ContractError(
            "audit audio stress loop must execute the exact Godot subprocess, "
            "capture its immediate status, and clean its isolated home"
        )
    for identifier in ("IMMERSION_HOME", "IMMERSION_RAW", "IMMERSION_STATUS"):
        if len(re.findall(
            rf"(?m)^\s+{identifier}=", stress_loop_body
        )) != 1:
            raise ContractError(
                f"audit audio stress loop must assign {identifier} exactly once"
            )
    for marker in (
        "res://tools/ImmersionLoopCheck.tscn",
        '"IMMERSION_LOOP_CHECK_OK" teardown_strict',
        "cleanup_isolated_home \"$IMMERSION_HOME\"",
        "IMMERSION_PASSES=$((IMMERSION_PASSES + 1))",
        "IMMERSION_RUN_INDEX=$((IMMERSION_RUN_INDEX + 1))",
    ):
        if marker not in stress_loop_body:
            raise ContractError(
                f"audit audio teardown stress loop body is missing {marker!r}"
            )


def _validate_runner_error_policy(runner: str) -> None:
    if "Could not create ObjectDB Snapshots directory" in runner:
        raise ContractError("runner must not whitelist the ObjectDB Profiler engine error")
    if "grep -viE" in runner or "grep -vE" in runner:
        raise ContractError("runner must not filter engine teardown errors")
    if "WARNING: ObjectDB instances leaked at exit" not in runner:
        raise ContractError("runner must fail closed on ObjectDB teardown leaks")


def _validate_runner_isolation_contract(runner: str) -> None:
    for needle in (
        "mktemp -d",
        'trace_base="/private/tmp"',
        'reason=trace_base_unavailable',
        'if ! trace_root="$(mktemp -d "${trace_base}/gangnamdream-full-trace-${profile_id}.XXXXXX")"',
        'reason=trace_root_create_failed',
        'reason=trace_root_outside_trace_base',
        'reason=trace_root_invalid',
        'reason=trace_isolation_dirs_failed',
        'trap cleanup_trace_root RETURN',
        'HOME="${trace_home}"',
        'XDG_DATA_HOME="${trace_root}/xdg-data"',
        'XDG_CONFIG_HOME="${trace_root}/xdg-config"',
        'XDG_CACHE_HOME="${trace_root}/xdg-cache"',
        "git diff --quiet",
        "git ls-files --others --exclude-standard",
        "full_game_runtime_trace_audit.py",
        "FULL_GAME_RUNTIME_TRACE_PENDING",
        'GANGNAM_TRACE_TIMEOUT_SECONDS:-7200',
        "local -a trace_command",
        "local -a import_command",
        "--import",
        "--quit-after 2000",
        "global_script_class_cache.cfg",
        "--audio-driver Dummy",
        "reason=timeout",
        'config/name="강남드림"',
        "Library/Application Support/Godot/app_userdata/강남드림/${project_root#/}",
        "xdg-data/godot/app_userdata/강남드림/${project_root#/}",
        'for objectdb_project_dir in "${objectdb_project_dirs[@]}"',
        'case "${objectdb_project_dir}" in',
        '"${trace_root}"/*)',
        "reason=objectdb_project_dir_outside_trace_root",
        "reason=objectdb_project_dir_precreate_failed",
        "WARNING: ObjectDB instances leaked at exit",
        "reason=candidate_changed_during_import",
        "reason=candidate_changed_during_runtime",
        "reason=trace_contract_rejected",
    ):
        if needle not in runner:
            raise ContractError(
                f"runner isolation/identity contract is missing {needle!r}"
            )
    if "app_userdata/강남드림/objectdb_snapshots" in runner:
        raise ContractError(
            "runner pre-creates a generic ObjectDB directory instead of the exact project path"
        )
    mktemp_guard = runner.index('if ! trace_root="$(mktemp -d ')
    trap_install = runner.index("trap cleanup_trace_root RETURN")
    derived_paths = runner.index('trace_home="${trace_root}/home"')
    if not mktemp_guard < trap_install < derived_paths:
        raise ContractError(
            "runner must validate trace_root and install cleanup before derived paths"
        )
    _validate_runner_error_policy(runner)
    if runner.count('post_commit="$(git rev-parse HEAD)"') < 2 \
            or runner.count('post_tree="$(git rev-parse \'HEAD^{tree}\')"') < 2 \
            or runner.count("git diff --quiet --") < 3 \
            or runner.count("git diff --cached --quiet --") < 3 \
            or runner.count("git ls-files --others --exclude-standard") < 3:
        raise ContractError("runner does not reseal commit/tree/clean state around runtime")
    if 'if ! python3 "${audit_path}"' not in runner:
        raise ContractError("runner does not propagate trace validator failure")
    command_region = runner.split("trace_command=", 1)[-1]
    for forbidden in FORBIDDEN_USER_ARGS:
        if forbidden in command_region:
            raise ContractError(
                f"runner invokes forbidden state flavor argument {forbidden}"
            )


def _validate_identity_trace_source(source: str) -> None:
    for marker in (
        '"player_route": str(GameState.player_route)',
        '"tendency": GameState.tendency.duplicate(true)',
        '"tendency_realized": str(GameState.tendency_realized)',
        '"week_routine": GameState.week_routine.duplicate(true)',
        '"identity_before": _identity_snapshot_from_state(',
        '"identity_after": _identity_snapshot_from_state(after)',
    ):
        if source.count(marker) < 1:
            raise ContractError(
                f"runtime trace does not seal identity marker {marker}"
            )


def validate_tool_sources() -> None:
    required_paths = (
        TRACE_SCRIPT, TRACE_SCENE, TRACE_RUNNER, AUDIT_RUNNER,
        IMMERSION_LOOP_SCRIPT, MAIN_GAME_SCRIPT, AUDIO_MANAGER_SCRIPT,
    )
    for path in required_paths:
        if not path.is_file():
            raise ContractError(f"missing runtime trace tool: {path.relative_to(ROOT)}")
    source = TRACE_SCRIPT.read_text(encoding="utf-8")
    _validate_trace_script_source(source)
    _validate_identity_trace_source(source)
    _validate_main_game_timer_source(
        MAIN_GAME_SCRIPT.read_text(encoding="utf-8")
    )
    _validate_audio_manager_source(AUDIO_MANAGER_SCRIPT.read_text(encoding="utf-8"))
    _validate_immersion_audio_teardown_source(
        IMMERSION_LOOP_SCRIPT.read_text(encoding="utf-8")
    )
    _validate_audit_runtime_guard(AUDIT_RUNNER.read_bytes())
    runner = TRACE_RUNNER.read_text(encoding="utf-8")
    _validate_runner_isolation_contract(runner)
    scene = TRACE_SCENE.read_text(encoding="utf-8")
    if 'path="res://tools/FullGameRuntimeTrace.gd"' not in scene:
        raise ContractError("trace scene does not own FullGameRuntimeTrace.gd")


def _read_jsonl(path: Path) -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    try:
        lines = path.read_text(encoding="utf-8").splitlines()
    except OSError as exc:
        raise ContractError(f"cannot read trace {path}: {exc}") from exc
    if not lines:
        raise ContractError(f"trace is empty: {path}")
    for line_number, line in enumerate(lines, 1):
        if not line.strip():
            raise ContractError(f"trace has a blank line at {line_number}")
        try:
            row = json.loads(line)
        except json.JSONDecodeError as exc:
            raise ContractError(f"trace line {line_number} is malformed JSON: {exc}") from exc
        if not isinstance(row, dict):
            raise ContractError(f"trace line {line_number} is not an object")
        rows.append(row)
    return rows


def _ordered_subsequence(haystack: Iterable[str], needles: list[str]) -> bool:
    iterator = iter(haystack)
    return all(any(value == needle for value in iterator) for needle in needles)


def _payload(row: dict[str, Any], label: str) -> dict[str, Any]:
    value = row.get("payload")
    if not isinstance(value, dict):
        raise ContractError(f"{label}.payload must be an object")
    return value


def _validate_early_investment_identity(
    rows: list[dict[str, Any]], profile_id: str
) -> None:
    """Prove three visible study choices earn and preserve one investor route."""
    if profile_id not in EARLY_INVESTMENT_IDENTITY_PROFILES:
        return
    commits = [row for row in rows if row.get("record_type") == "main_action_commit"]
    studies = [
        row for row in commits
        if _payload(row, "main_action_commit").get("actual_action_id")
        == "study_invest"
    ]
    if len(studies) < 3:
        raise ContractError(
            f"{profile_id} must visibly commit investment study at least three times"
        )
    studies = studies[:3]

    def identity_snapshot(value: Any, label: str) -> dict[str, Any]:
        if not isinstance(value, dict):
            raise ContractError(f"{profile_id} {label} identity snapshot is missing")
        for key in (
            "player_route", "tendency", "tendency_realized",
            "route_flags", "pending_flags",
        ):
            if key not in value:
                raise ContractError(
                    f"{profile_id} {label} identity snapshot lacks {key}"
                )
        if not isinstance(value["tendency"], dict) \
                or not isinstance(value["route_flags"], dict) \
                or not isinstance(value["pending_flags"], dict):
            raise ContractError(
                f"{profile_id} {label} identity containers are malformed"
            )
        return value

    def validate_evidence_commit(
        row: dict[str, Any], label: str, expected_actual: str
    ) -> tuple[dict[str, Any], dict[str, Any], dict[str, Any]]:
        payload = _payload(row, label)
        expected_surface = INVESTMENT_EVIDENCE_ACTIONS.get(expected_actual)
        visible = payload.get("visible_button")
        commitment = payload.get("commitment")
        details = payload.get("details")
        if expected_surface is None \
                or not isinstance(visible, dict) \
                or not isinstance(commitment, dict) \
                or not isinstance(details, dict):
            raise ContractError(f"{profile_id} {label} evidence payload is malformed")
        expected_action, expected_function = expected_surface
        expected_trade = {
            "invest_buy": "buy",
            "invest_leverage": "leverage_buy",
        }.get(expected_actual)
        if payload.get("action_id") != expected_action \
                or payload.get("actual_action_id") != expected_actual \
                or visible.get("action_id") != expected_action \
                or visible.get("function") != expected_function \
                or commitment.get("choice_id") != expected_action \
                or commitment.get("actual_action_id") != expected_actual \
                or commitment.get("details") != details \
                or commitment.get("identity_evidence") != INVESTMENT_EVIDENCE:
            raise ContractError(
                f"{profile_id} {label} does not bind one visible investment receipt"
            )
        if expected_actual == "study_invest" and details.get("study_type") != 3:
            raise ContractError(f"{profile_id} {label} is not investment study")
        if expected_trade is not None and details.get("trade") != expected_trade:
            raise ContractError(f"{profile_id} {label} trade receipt drifted")
        before = identity_snapshot(payload.get("identity_before"), f"{label} before")
        after = identity_snapshot(payload.get("identity_after"), f"{label} after")
        return payload, before, after

    def require_neutral(snapshot: dict[str, Any], label: str) -> None:
        if snapshot.get("player_route") != "none" \
                or snapshot.get("tendency_realized") not in {"", None} \
                or any(snapshot["route_flags"].get(flag) is True for flag in (
                    "route_career", "route_invest", "route_startup",
                )) \
                or any(snapshot["pending_flags"].get(flag) is True for flag in (
                    "pending_spec_career", "pending_spec_invest",
                    "pending_spec_found",
                )):
            raise ContractError(
                f"{profile_id} {label} invented a route before the third study"
            )

    previous_week = 0
    for index, row in enumerate(studies):
        ordinal = index + 1
        week = int(row.get("week", -1))
        if week <= previous_week:
            raise ContractError(
                f"{profile_id} investment studies are not strictly ordered"
            )
        previous_week = week
        _, before, after = validate_evidence_commit(
            row, f"investment study {ordinal}", "study_invest"
        )
        require_neutral(before, f"investment study {ordinal} before")
        before_tendency = before["tendency"]
        after_tendency = after["tendency"]
        if int(before_tendency.get("invest", -1)) != index * 4 \
                or int(after_tendency.get("invest", -1)) != ordinal * 4 \
                or any(
                    int(before_tendency.get(kind, 0))
                    != int(after_tendency.get(kind, 0))
                    for kind in ("career", "found")
                ):
            raise ContractError(
                f"{profile_id} investment study {ordinal} did not add exact evidence"
            )
        if ordinal < 3:
            require_neutral(after, f"investment study {ordinal} after")
        elif after.get("player_route") != "투자형" \
                or after.get("tendency_realized") != "invest" \
                or after["route_flags"].get("route_invest") is not True \
                or after["route_flags"].get("route_career") is True \
                or after["route_flags"].get("route_startup") is True \
                or after["pending_flags"].get("pending_spec_invest") is not True \
                or after["pending_flags"].get("pending_spec_career") is True \
                or after["pending_flags"].get("pending_spec_found") is True:
            raise ContractError(
                f"{profile_id} third investment study did not atomically seal invest-only"
            )

    third_study_week = int(studies[2].get("week", -1))
    if third_study_week > 24:
        raise ContractError(
            f"{profile_id} did not earn investor identity within the M06 boundary"
        )
    first_buy = next((
        row for row in commits
        if _payload(row, "main_action_commit").get("actual_action_id")
        in {"invest_buy", "invest_leverage"}
        and int(row.get("week", -1)) >= third_study_week
    ), None)
    if first_buy is None:
        raise ContractError(f"{profile_id} lacks its first visible investment buy")
    first_buy_week = int(first_buy.get("week", -1))
    if third_study_week >= first_buy_week:
        raise ContractError(
            f"{profile_id} did not study three times before its first investment buy"
        )
    if first_buy_week > FIRST_INVESTMENT_BUY_DEADLINE_WEEK:
        raise ContractError(
            f"{profile_id} first investment buy arrived after Chapter 1"
        )
    for row in rows:
        if row.get("record_type") != "main_action_offer":
            continue
        offer_week = int(row.get("week", -1))
        if offer_week < third_study_week or offer_week >= first_buy_week:
            continue
        actions = _payload(row, "main_action_offer").get("actions")
        if not isinstance(actions, list):
            raise ContractError(
                f"{profile_id} W{offer_week:03d} main action offer is malformed"
            )
        if any(
                isinstance(action, dict) and action.get("action_id") == "invest"
                for action in actions):
            raise ContractError(
                f"{profile_id} skipped a visible investment action at "
                f"W{offer_week:03d} before its first buy"
            )
    buy_payload = _payload(first_buy, "first investment buy")
    _, buy_before, buy_after = validate_evidence_commit(
        first_buy, "first investment buy",
        str(buy_payload.get("actual_action_id", "")),
    )
    for label, snapshot in (("before", buy_before), ("after", buy_after)):
        if snapshot.get("player_route") != "투자형" \
                or snapshot.get("tendency_realized") != "invest" \
                or snapshot["route_flags"].get("route_invest") is not True \
                or snapshot["route_flags"].get("route_career") is True \
                or snapshot["route_flags"].get("route_startup") is True:
            raise ContractError(
                f"{profile_id} first buy {label} lost invest-only identity"
            )
    if int(buy_after["tendency"].get("invest", -1)) \
            != int(buy_before["tendency"].get("invest", -1)) + 4 \
            or any(
                int(buy_before["tendency"].get(kind, 0))
                != int(buy_after["tendency"].get(kind, 0))
                for kind in ("career", "found")
            ):
        raise ContractError(
            f"{profile_id} first buy did not add one investment evidence receipt"
        )

    closes: dict[int, dict[str, Any]] = {}
    for row in rows:
        if row.get("record_type") != "week_close":
            continue
        state = _payload(row, "week_close").get("state_after")
        if isinstance(state, dict):
            closes[int(row.get("week", -1))] = state
    for week in range(third_study_week, first_buy_week + 1):
        state = closes.get(week)
        if not isinstance(state, dict):
            raise ContractError(
                f"{profile_id} W{week:03d} lacks its identity state snapshot"
            )
        flags = state.get("flags")
        if not isinstance(flags, dict) or not isinstance(state.get("tendency"), dict):
            raise ContractError(
                f"{profile_id} W{week:03d} identity snapshot is incomplete"
            )
        if state.get("player_route") != "투자형" \
                or state.get("tendency_realized") != "invest" \
                or flags.get("route_invest") is not True \
                or flags.get("route_career") is True \
                or flags.get("route_startup") is True:
            raise ContractError(
                f"{profile_id} W{week:03d} did not preserve invest-only identity"
            )


def validate_trace_rows(
    rows: list[dict[str, Any]],
    profile: dict[str, Any],
    profile_hash: str,
    *,
    expected_commit: str | None = None,
    expected_tree: str | None = None,
) -> dict[str, Any]:
    if not rows:
        raise ContractError("trace has no rows")
    profile_id = profile["id"]
    first = rows[0]
    commit = expected_commit or first.get("candidate_commit")
    tree = expected_tree or first.get("candidate_tree")
    if not isinstance(commit, str) or not HEX40.fullmatch(commit):
        raise ContractError("candidate commit must be a lowercase 40-hex identity")
    if not isinstance(tree, str) or not HEX40.fullmatch(tree):
        raise ContractError("candidate tree must be a lowercase 40-hex identity")
    if not HEX64.fullmatch(profile_hash):
        raise ContractError("profile hash must be a lowercase 64-hex identity")

    sequences: list[int] = []
    record_types: list[str] = []
    story_enter_rows: list[dict[str, Any]] = []
    story_occurrences: set[str] = set()
    story_serials: set[tuple[int, int]] = set()
    story_event_by_occurrence: dict[str, str] = {}
    story_week_by_occurrence: dict[str, int] = {}
    story_offer_occurrences: set[str] = set()
    story_offer_choices: dict[str, set[tuple[int, int]]] = {}
    story_choice_occurrences: set[str] = set()
    story_choice_indices: dict[str, tuple[int, int]] = {}
    story_result_occurrences: set[str] = set()
    week_opens: list[int] = []
    week_closes: list[int] = []
    week_close_sequences: dict[int, int] = {}
    ending_pages: list[int] = []
    ending_open_count = 0
    ending_open_sequence = -1
    ending_open_id = ""
    run_end_rows: list[dict[str, Any]] = []
    trace_errors: list[dict[str, Any]] = []

    for index, row in enumerate(rows):
        label = f"trace[{index}]"
        if set(row) != COMMON_KEYS:
            raise ContractError(
                f"{label} common schema drifted; missing={sorted(COMMON_KEYS-set(row))} "
                f"extra={sorted(set(row)-COMMON_KEYS)}"
            )
        if row["schema_version"] != TRACE_SCHEMA_VERSION:
            raise ContractError(f"{label} schema version drifted")
        record_type = row["record_type"]
        if record_type not in RECORD_TYPES:
            raise ContractError(f"{label} has unknown record type {record_type!r}")
        record_types.append(record_type)
        if not isinstance(row["sequence"], int) or row["sequence"] <= 0:
            raise ContractError(f"{label}.sequence must be positive")
        sequences.append(row["sequence"])
        if row["candidate_commit"] != commit or row["candidate_tree"] != tree:
            raise ContractError(f"{label} candidate identity changed inside the trace")
        if row["candidate_dirty"] is not False:
            raise ContractError(f"{label} was recorded from a dirty candidate")
        if row["profile_id"] != profile_id or row["profile_hash"] != profile_hash:
            raise ContractError(f"{label} profile identity/hash drifted")
        if row["seed"] != profile["seed"] or row["locale"] != profile["locale"]:
            raise ContractError(f"{label} seed/locale drifted")
        if not isinstance(row["week"], int) or not 1 <= row["week"] <= 240:
            raise ContractError(f"{label}.week must be inside exact W1..W240")
        expected_month = min(60, ((row["week"] - 1) // 4) + 1)
        expected_chapter = min(5, ((row["week"] - 1) // 48) + 1)
        if row["month"] != expected_month or row["chapter"] != expected_chapter:
            raise ContractError(f"{label} calendar does not match its week")
        if not isinstance(row["scene_path"], str) or not row["scene_path"].startswith("res://"):
            raise ContractError(f"{label}.scene_path must be a res:// path")
        if not isinstance(row["occurrence_id"], str) or not row["occurrence_id"]:
            raise ContractError(f"{label}.occurrence_id must be non-empty")
        if row["state_injection"] is not False:
            raise ContractError(f"{label} reports state injection")
        payload = _payload(row, label)

        if record_type == "run_start":
            if index != 0:
                raise ContractError("run_start must be the first JSONL record")
            required_start = {
                "state_source": "fresh_title",
                "fresh_title": True,
                "new_story_selected": True,
                "content_notice_confirmed": True,
                "opening_seen": True,
                "run_started_signal": True,
            }
            for key, expected in required_start.items():
                if payload.get(key) != expected:
                    raise ContractError(f"run_start.{key} must be {expected!r}")
            user_args = payload.get("user_args")
            if not isinstance(user_args, list) or any(arg in FORBIDDEN_USER_ARGS for arg in user_args):
                raise ContractError("run_start includes a forbidden flavor/state argument")
            if payload.get("save_loaded") is not False:
                raise ContractError("run_start must prove no save was loaded")
        elif record_type == "week_open":
            week_opens.append(row["week"])
        elif record_type == "week_close":
            week_closes.append(row["week"])
            week_close_sequences[row["week"]] = row["sequence"]
            if not isinstance(payload.get("state_delta"), dict):
                raise ContractError(f"{label} lacks a state_delta")
        elif record_type == "story_enter":
            event_id = payload.get("event_id")
            serial = payload.get("event_serial")
            instance = payload.get("scene_instance_id")
            if not isinstance(event_id, str) or not event_id:
                raise ContractError(f"{label} lacks an event_id")
            if not isinstance(serial, int) or serial <= 0 or not isinstance(instance, int) or instance <= 0:
                raise ContractError(f"{label} lacks positive StoryMode instance/event serial identity")
            if row["occurrence_id"] in story_occurrences:
                raise ContractError(f"duplicate story occurrence identity {row['occurrence_id']}")
            serial_key = (instance, serial)
            if serial_key in story_serials:
                raise ContractError(f"duplicate StoryMode instance/event serial {serial_key}")
            story_occurrences.add(row["occurrence_id"])
            story_serials.add(serial_key)
            story_event_by_occurrence[row["occurrence_id"]] = event_id
            story_week_by_occurrence[row["occurrence_id"]] = row["week"]
            if payload.get("provenance") not in PROVENANCE_VALUES:
                raise ContractError(f"{label} has invalid provenance")
            for stats_key in ("source_paragraph_count", "source_char_count", "runtime_page_count", "runtime_char_count"):
                if not isinstance(payload.get(stats_key), int) or payload[stats_key] < 0:
                    raise ContractError(f"{label}.{stats_key} must be non-negative")
            for hash_key in ("source_sha256", "runtime_sha256"):
                if not isinstance(payload.get(hash_key), str) or not HEX64.fullmatch(payload[hash_key]):
                    raise ContractError(f"{label}.{hash_key} must be sha256")
            if payload.get("volume_class") not in ("narrative", "control"):
                raise ContractError(f"{label} has invalid volume_class")
            story_enter_rows.append(row)
        elif record_type == "choice_offer":
            if row["occurrence_id"] not in story_occurrences:
                raise ContractError(f"{label} points to an unknown story occurrence")
            if row["occurrence_id"] in story_offer_occurrences:
                raise ContractError(f"{label} duplicates a choice_offer occurrence")
            expected_event_id = story_event_by_occurrence[row["occurrence_id"]]
            if payload.get("event_id") != expected_event_id:
                raise ContractError(
                    f"{label}.event_id does not match its story_enter occurrence"
                )
            if row["week"] != story_week_by_occurrence[row["occurrence_id"]]:
                raise ContractError(f"{label}.week differs from its story_enter occurrence")
            choices = payload.get("choices")
            if not isinstance(choices, list) or not choices:
                raise ContractError(f"{label} must expose at least one visible choice")
            authored = [item.get("authored_index") for item in choices if isinstance(item, dict)]
            displayed = [item.get("display_index") for item in choices if isinstance(item, dict)]
            if len(authored) != len(choices) or len(set(authored)) != len(authored) \
                    or len(displayed) != len(choices) or len(set(displayed)) != len(displayed):
                raise ContractError(f"{label} choice authored/display indices are invalid")
            if any(not isinstance(value, int) or value < 0 for value in authored) \
                    or any(not isinstance(value, int) or value < 1 for value in displayed):
                raise ContractError(f"{label} choice indices must be non-negative/one-based integers")
            story_offer_choices[row["occurrence_id"]] = set(zip(authored, displayed))
            story_offer_occurrences.add(row["occurrence_id"])
        elif record_type == "story_choice":
            if row["occurrence_id"] not in story_offer_occurrences:
                raise ContractError(f"{label} has no preceding choice_offer")
            if row["occurrence_id"] in story_choice_occurrences:
                raise ContractError(f"{label} duplicates a story_choice occurrence")
            if payload.get("selection_mode") not in ("direct", "timed"):
                raise ContractError(f"{label} selection mode is invalid")
            expected_event_id = story_event_by_occurrence[row["occurrence_id"]]
            if payload.get("event_id") != expected_event_id:
                raise ContractError(
                    f"{label}.event_id does not match its story_enter occurrence"
                )
            if row["week"] != story_week_by_occurrence[row["occurrence_id"]]:
                raise ContractError(f"{label}.week differs from its story_enter occurrence")
            if not isinstance(payload.get("authored_index"), int) or not isinstance(payload.get("display_index"), int):
                raise ContractError(f"{label} lacks authored/display choice indices")
            selected_indices = (
                payload["authored_index"], payload["display_index"]
            )
            if selected_indices not in story_offer_choices[row["occurrence_id"]]:
                raise ContractError(
                    f"{label} selected a choice not present in its choice_offer"
                )
            if not isinstance(payload.get("state_delta"), dict):
                raise ContractError(f"{label} lacks state_delta")
            story_choice_indices[row["occurrence_id"]] = selected_indices
            story_choice_occurrences.add(row["occurrence_id"])
        elif record_type == "story_result":
            if row["occurrence_id"] not in story_choice_occurrences:
                raise ContractError(f"{label} has no preceding story_choice")
            if row["occurrence_id"] in story_result_occurrences:
                raise ContractError(f"{label} duplicates a story_result occurrence")
            expected_event_id = story_event_by_occurrence[row["occurrence_id"]]
            if payload.get("event_id") != expected_event_id:
                raise ContractError(
                    f"{label}.event_id does not match its story_enter occurrence"
                )
            if row["week"] != story_week_by_occurrence[row["occurrence_id"]]:
                raise ContractError(f"{label}.week differs from its story_enter occurrence")
            if payload.get("authored_index") != story_choice_indices[
                    row["occurrence_id"]][0]:
                raise ContractError(
                    f"{label}.authored_index does not match its story_choice"
                )
            for stats_key in ("source_paragraph_count", "source_char_count", "runtime_page_count", "runtime_char_count"):
                if not isinstance(payload.get(stats_key), int) or payload[stats_key] < 0:
                    raise ContractError(f"{label}.{stats_key} must be non-negative")
            for hash_key in ("source_sha256", "runtime_sha256"):
                if not isinstance(payload.get(hash_key), str) or not HEX64.fullmatch(payload[hash_key]):
                    raise ContractError(f"{label}.{hash_key} must be sha256")
            story_result_occurrences.add(row["occurrence_id"])
        elif record_type == "main_action_offer":
            if payload.get("volume_class") != "control" or payload.get("narrative_volume_counted") is not False:
                raise ContractError(f"{label} must exclude main/AP offers from narrative volume")
            if not isinstance(payload.get("actions"), list) or not payload["actions"]:
                raise ContractError(f"{label} lacks offered actions")
        elif record_type == "main_action_commit":
            if payload.get("volume_class") != "control" or payload.get("narrative_volume_counted") is not False:
                raise ContractError(f"{label} must exclude main/AP commits from narrative volume")
            if not isinstance(payload.get("state_delta"), dict):
                raise ContractError(f"{label} lacks state_delta")
            actual_action_id = payload.get("actual_action_id")
            details = payload.get("details")
            commitment = payload.get("commitment")
            action_id = payload.get("action_id")
            visible_button = payload.get("visible_button")
            if not isinstance(actual_action_id, str) or not actual_action_id:
                raise ContractError(f"{label} lacks actual_action_id")
            if not isinstance(details, dict) or not isinstance(commitment, dict):
                raise ContractError(f"{label} lacks actual commitment details")
            if not isinstance(action_id, str) or not action_id \
                    or not isinstance(visible_button, dict):
                raise ContractError(
                    f"{label} lacks its exact visible MainGame action identity"
                )
            if commitment.get("choice_id") != action_id \
                    or visible_button.get("action_id") != action_id:
                raise ContractError(
                    f"{label} visible/selected/committed MainGame action identity drifted"
                )
            if commitment.get("actual_action_id") != actual_action_id \
                    or commitment.get("details") != details:
                raise ContractError(f"{label} flattened commitment fields drifted")
            study_types = {"study_read": 0, "study_exercise": 1,
                           "study_meditation": 2, "study_invest": 3}
            if actual_action_id in study_types \
                    and details.get("study_type") != study_types[actual_action_id]:
                raise ContractError(f"{label} study action/details disagree")
            selection_policy = payload.get("selection_policy")
            if selection_policy not in {
                "profile", "survival", "profile_fallback", "asset_band_hold",
            }:
                raise ContractError(f"{label} has an invalid selection_policy")
            if selection_policy == "survival":
                if visible_button.get("action_id") not in profile["survival_policy"]["action_priority"] \
                        and visible_button.get("function") not in profile["survival_policy"]["function_priority"]:
                    raise ContractError(
                        f"{label} survival policy selected a non-recovery visible Button"
                    )
            elif selection_policy == "asset_band_hold":
                asset_band_policy = profile.get("asset_band_policy")
                if not isinstance(asset_band_policy, dict):
                    raise ContractError(
                        f"{label} selected asset_band_hold without a profile policy"
                    )
                if visible_button.get("action_id") not in asset_band_policy["action_priority"] \
                        and visible_button.get("function") not in asset_band_policy["function_priority"]:
                    raise ContractError(
                        f"{label} asset-band policy selected a non-safe visible Button"
                    )
        elif record_type == "ending_open":
            ending_open_count += 1
            if row["week"] != 240:
                raise ContractError(f"{label} must open the ending on exact Week 240")
            if not isinstance(payload.get("ending_id"), str) or not payload["ending_id"]:
                raise ContractError(f"{label} lacks ending_id")
            ending_open_sequence = row["sequence"]
            ending_open_id = payload["ending_id"]
            if payload.get("page_count") != profile["target"]["ending_page_count"]:
                raise ContractError(f"{label} ending page count drifted")
        elif record_type == "ending_page":
            if row["week"] != 240:
                raise ContractError(f"{label} must render on exact Week 240")
            if ending_open_sequence < 0 or row["sequence"] <= ending_open_sequence:
                raise ContractError(f"{label} appears before ending_open")
            if not isinstance(payload.get("page_index"), int):
                raise ContractError(f"{label} lacks page_index")
            ending_pages.append(payload["page_index"])
        elif record_type == "trace_error":
            trace_errors.append(row)
        elif record_type == "run_end":
            if row["week"] != 240:
                raise ContractError(f"{label} must be recorded on exact Week 240")
            run_end_rows.append(row)

    if sequences != list(range(1, len(rows) + 1)):
        raise ContractError("trace sequences are not contiguous append-only 1..N")
    if record_types[0] != "run_start" or record_types[-1] != "run_end":
        raise ContractError("trace must start with run_start and end with run_end")
    if len(run_end_rows) != 1:
        raise ContractError("trace must contain exactly one run_end")
    run_end = _payload(run_end_rows[0], "run_end")
    if run_end.get("status") != "pass":
        raise ContractError(f"runtime profile did not pass: {run_end.get('errors', [])}")
    if trace_errors:
        raise ContractError("a passing trace must not contain trace_error")
    missing_types = sorted(set(SUCCESS_REQUIRED_RECORD_TYPES) - set(record_types))
    if missing_types:
        raise ContractError(f"passing trace lacks required records: {missing_types}")
    if week_opens != list(range(1, 241)):
        raise ContractError("passing trace must open each week exactly once from W1 through W240")
    if week_closes != list(range(1, 241)):
        raise ContractError("passing trace must close each week exactly once from W1 through W240")
    if ending_open_count != 1 or ending_pages != list(range(profile["target"]["ending_page_count"])):
        raise ContractError("passing trace must open one ending and traverse pages 0..5 exactly once")
    if ending_open_sequence <= week_close_sequences.get(240, -1):
        raise ContractError("ending_open must occur after the exact W240 week_close")
    if run_end.get("product_go") != "HOLD" or run_end.get("human_density_gate") != "OPEN":
        raise ContractError("runtime success must not claim product/human GO")
    if run_end.get("state_injection_detected") is not False:
        raise ContractError("run_end reports state injection")
    if not story_offer_occurrences == story_choice_occurrences == story_result_occurrences:
        raise ContractError(
            "choice_offer/story_choice/story_result occurrence sets are not identical"
        )

    _validate_early_investment_identity(rows, profile_id)

    event_sequence = [_payload(row, "story_enter")["event_id"] for row in story_enter_rows]
    if not _ordered_subsequence(event_sequence, profile["required_event_sequence"]):
        raise ContractError("required story event sequence is missing or out of order")
    event_counts = Counter(event_sequence)
    for event_id, count in profile["required_event_occurrences"].items():
        if event_counts[event_id] < count:
            raise ContractError(
                f"event-ID dedup/missing occurrence: {event_id} expected>={count} got={event_counts[event_id]}"
            )
    observed_edges: set[tuple[str, str, str]] = set()
    for left, right in zip(story_enter_rows, story_enter_rows[1:]):
        left_payload = _payload(left, "story_enter")
        right_payload = _payload(right, "story_enter")
        observed_edges.add((left_payload["event_id"], right_payload["event_id"], right_payload["provenance"]))
    for edge in profile["required_edges"]:
        key = (edge["from"], edge["to"], edge["provenance"])
        if key not in observed_edges:
            raise ContractError(f"required runtime edge is missing: {key}")

    final_state = run_end.get("final_state")
    if not isinstance(final_state, dict):
        raise ContractError("run_end lacks final_state")
    if final_state.get("week") not in {240, 241}:
        raise ContractError("run final GameState.turn must be Week 240 or 241")
    assets = final_state.get("total_assets")
    if not isinstance(assets, (int, float)):
        raise ContractError("run_end final_state.total_assets must be numeric")
    minimum = profile["target"]["minimum_total_assets"]
    maximum = profile["target"]["maximum_total_assets"]
    if minimum is not None and assets < minimum:
        raise ContractError(f"profile asset floor missed: {assets} < {minimum}")
    if maximum is not None and assets > maximum:
        raise ContractError(f"profile asset ceiling missed: {assets} > {maximum}")
    flags = final_state.get("flags")
    if not isinstance(flags, dict):
        raise ContractError("run_end final_state.flags must be an object")
    for flag in profile["target"]["required_flags_true"]:
        if flags.get(flag) is not True:
            raise ContractError(f"required final flag is not true: {flag}")
    for flag in profile["target"]["required_flags_false"]:
        if flags.get(flag) is True:
            raise ContractError(f"required final flag is unexpectedly true: {flag}")
    player_route = final_state.get("player_route")
    tendency = final_state.get("tendency")
    tendency_realized = final_state.get("tendency_realized")
    if not isinstance(player_route, str) or not isinstance(tendency, dict) \
            or not isinstance(tendency_realized, str):
        raise ContractError("run_end final_state lacks sealed route identity")
    if "route_invest" in profile["target"]["required_flags_true"] \
            and (player_route != "투자형" or tendency_realized != "invest"):
        raise ContractError(
            "final investor flag disagrees with player_route/tendency identity"
        )
    ending_id = final_state.get("ending_id")
    if not isinstance(ending_id, str) or not ending_id:
        raise ContractError("run_end final_state.ending_id must be non-empty")
    if ending_id != ending_open_id:
        raise ContractError("ending_open and run_end ending identities differ")
    required_endings = profile["target"]["required_ending_ids"]
    if required_endings and ending_id not in required_endings:
        raise ContractError(f"ending {ending_id} is outside the required set")
    if ending_id in profile["target"]["forbidden_ending_ids"]:
        raise ContractError(f"forbidden ending reached: {ending_id}")
    return {
        "profile_id": profile_id,
        "candidate_commit": commit,
        "candidate_tree": tree,
        "records": len(rows),
        "story_occurrences": len(story_enter_rows),
        "ending_id": ending_id,
        "total_assets": assets,
        "product_go": "HOLD",
        "human_density_gate": "OPEN",
    }


def validate_trace_file(
    path: Path,
    profiles_path: Path = DEFAULT_PROFILES,
    *,
    expected_profile: str | None = None,
    expected_commit: str | None = None,
    expected_tree: str | None = None,
) -> dict[str, Any]:
    profiles = validate_profiles(profiles_path)
    rows = _read_jsonl(path)
    profile_id = expected_profile or str(rows[0].get("profile_id", ""))
    if profile_id not in profiles:
        raise ContractError(f"trace references unknown profile {profile_id!r}")
    return validate_trace_rows(
        rows,
        profiles[profile_id],
        _profile_hash(profiles_path, profile_id),
        expected_commit=expected_commit,
        expected_tree=expected_tree,
    )


def _fixture_profile() -> dict[str, Any]:
    return {
        "id": "fixture_repeat",
        "description": "self-test",
        "seed": 7,
        "locale": "ko",
        "input_mode": "keyboard",
        "default_choice": {"index": 0, "selection_mode": "direct"},
        "modal_policy": {"study_type": 0},
        "choice_overrides": {},
        "main_action_priority": ["rest"],
        "main_function_priority": ["_ap_rest"],
        "survival_policy": {
            "enter_health_at_or_below": 40,
            "enter_mental_at_or_below": 40,
            "resume_health_at_or_above": 50,
            "resume_mental_at_or_above": 50,
            "action_priority": ["rest", "contact"],
            "function_priority": ["_ap_free_time", "_ap_contact_person"],
        },
        "asset_band_policy": {
            "activate_at_total_assets": 50,
            "action_priority": ["rest"],
            "function_priority": ["_ap_rest"],
        },
        "required_event_sequence": ["fixture_root", "fixture_repeat", "fixture_end"],
        "required_edges": [
            {"from": "fixture_root", "to": "fixture_repeat", "provenance": "follow_up"}
        ],
        "required_event_occurrences": {"fixture_repeat": 2},
        "target": {
            "minimum_week": 240,
            "ending_page_count": 6,
            "minimum_total_assets": 50,
            "maximum_total_assets": 150,
            "required_flags_true": [],
            "required_flags_false": [],
            "required_ending_ids": [],
            "forbidden_ending_ids": ["instant_legend"],
        },
    }


def _identity_fixture_rows() -> list[dict[str, Any]]:
    def identity(
        career: int, invest: int, found: int, *, realized: bool
    ) -> dict[str, Any]:
        return {
            "player_route": "투자형" if realized else "none",
            "tendency": {"career": career, "invest": invest, "found": found},
            "tendency_realized": "invest" if realized else "",
            "route_flags": {
                "route_career": False,
                "route_invest": realized,
                "route_startup": False,
            },
            "pending_flags": {
                "pending_spec_career": False,
                "pending_spec_invest": realized,
                "pending_spec_found": False,
            },
        }

    def commit(
        week: int, actual_action: str, details: dict[str, Any],
        button_action: str, function: str,
        before: dict[str, Any] | None = None,
        after: dict[str, Any] | None = None,
    ) -> dict[str, Any]:
        commitment = {
            "choice_id": button_action,
            "actual_action_id": actual_action,
            "details": copy.deepcopy(details),
        }
        if actual_action in INVESTMENT_EVIDENCE_ACTIONS:
            commitment["identity_evidence"] = copy.deepcopy(INVESTMENT_EVIDENCE)
        payload: dict[str, Any] = {
            "action_id": button_action,
            "actual_action_id": actual_action,
            "details": copy.deepcopy(details),
            "visible_button": {
                "action_id": button_action,
                "function": function,
            },
            "commitment": commitment,
        }
        if before is not None and after is not None:
            payload["identity_before"] = copy.deepcopy(before)
            payload["identity_after"] = copy.deepcopy(after)
        return {
            "record_type": "main_action_commit",
            "week": week,
            "payload": payload,
        }

    rows = [
        commit(
            1, "study_invest", {"study_type": 3}, "study", "_ap_study",
            identity(0, 0, 0, realized=False),
            identity(0, 4, 0, realized=False),
        ),
        commit(
            2, "study_invest", {"study_type": 3}, "study", "_ap_study",
            identity(0, 4, 0, realized=False),
            identity(0, 8, 0, realized=False),
        ),
        commit(3, "side_shift", {}, "side_shift", "_ap_side_job"),
        commit(
            5, "study_invest", {"study_type": 3}, "study", "_ap_study",
            identity(0, 8, 1, realized=False),
            identity(0, 12, 1, realized=True),
        ),
        commit(6, "save", {}, "save", "_ap_save_money"),
        commit(
            35, "invest_buy", {"trade": "buy"}, "invest", "_ap_invest",
            identity(4, 12, 1, realized=True),
            identity(4, 16, 1, realized=True),
        ),
    ]
    rows.extend([
        {
            "record_type": "main_action_offer",
            "week": 23,
            "payload": {"actions": [
                {"action_id": "rest", "function": "_ap_free_time"},
                {"action_id": "side_shift", "function": "_ap_side_job"},
                {"action_id": "contact", "function": "_ap_contact_person"},
            ]},
        },
        {
            "record_type": "main_action_offer",
            "week": 35,
            "payload": {"actions": [
                {"action_id": "invest", "function": "_ap_invest"},
                {"action_id": "save", "function": "_ap_save_money"},
                {"action_id": "contact", "function": "_ap_contact_person"},
            ]},
        },
    ])
    for week in range(5, 50):
        rows.append({
            "record_type": "week_close",
            "week": week,
            "payload": {"state_after": {
                "player_route": "투자형",
                "tendency": {
                    "career": 4 if week >= 6 else 0,
                    "invest": 16 if week >= 35 else 12,
                    "found": 1,
                },
                "tendency_realized": "invest",
                "flags": {
                    "route_invest": True,
                    "pending_spec_invest": True,
                },
            }},
        })
    return rows


def _fixture_rows(profile: dict[str, Any], profile_hash: str) -> list[dict[str, Any]]:
    commit = "1" * 40
    tree = "2" * 40
    rows: list[dict[str, Any]] = []

    def add(record_type: str, week: int, occurrence_id: str, payload: dict[str, Any], scene: str) -> None:
        rows.append({
            "schema_version": 1,
            "record_type": record_type,
            "sequence": len(rows) + 1,
            "candidate_commit": commit,
            "candidate_tree": tree,
            "candidate_dirty": False,
            "profile_id": profile["id"],
            "profile_hash": profile_hash,
            "seed": profile["seed"],
            "locale": profile["locale"],
            "week": week,
            "month": min(60, ((min(week, 240) - 1) // 4) + 1),
            "chapter": min(5, ((min(week, 240) - 1) // 48) + 1),
            "scene_path": scene,
            "occurrence_id": occurrence_id,
            "state_injection": False,
            "payload": payload,
        })

    add("run_start", 1, "run:fixture", {
        "state_source": "fresh_title",
        "fresh_title": True,
        "new_story_selected": True,
        "content_notice_confirmed": True,
        "opening_seen": True,
        "run_started_signal": True,
        "save_loaded": False,
        "user_args": [],
    }, "res://scenes/StartMenu.gd")
    for week in range(1, 241):
        add("week_open", week, f"week:{week}:open", {}, "res://scenes/MainGame.gd")
        if week == 1:
            story_specs = [
                ("fixture_root", 1, "main_ingress", ""),
                ("fixture_repeat", 2, "follow_up", "story:1"),
                ("fixture_repeat", 3, "queued", "story:2"),
                ("fixture_end", 4, "queued", "story:3"),
            ]
            for event_id, serial, provenance, parent in story_specs:
                occurrence = f"story:{serial}"
                add("story_enter", week, occurrence, {
                    "event_id": event_id,
                    "event_serial": serial,
                    "scene_instance_id": 99,
                    "provenance": provenance,
                    "parent_occurrence_id": parent,
                    "source_paragraph_count": 1,
                    "source_char_count": 1,
                    "source_sha256": hashlib.sha256(event_id.encode()).hexdigest(),
                    "runtime_page_count": 1,
                    "runtime_char_count": 1,
                    "runtime_sha256": hashlib.sha256((event_id + "p").encode()).hexdigest(),
                    "volume_class": "narrative",
                }, "res://scenes/StoryMode.gd")
            add("choice_offer", week, "story:4", {
                "event_id": "fixture_end",
                "choices": [{"authored_index": 0, "display_index": 1, "text": "x"}],
            }, "res://scenes/StoryMode.gd")
            add("story_choice", week, "story:4", {
                "event_id": "fixture_end",
                "authored_index": 0,
                "display_index": 1,
                "selection_mode": "direct",
                "state_delta": {},
            }, "res://scenes/StoryMode.gd")
            add("story_result", week, "story:4", {
                "event_id": "fixture_end",
                "authored_index": 0,
                "source_paragraph_count": 1,
                "source_char_count": 1,
                "source_sha256": hashlib.sha256(b"r").hexdigest(),
                "runtime_page_count": 1,
                "runtime_char_count": 1,
                "runtime_sha256": hashlib.sha256(b"rp").hexdigest(),
            }, "res://scenes/StoryMode.gd")
            add("main_action_offer", week, "main:1:offer", {
                "volume_class": "control",
                "narrative_volume_counted": False,
                "actions": [{"action_id": "rest", "function": "_ap_rest"}],
            }, "res://scenes/MainGame.gd")
            add("main_action_commit", week, "main:1:commit", {
                "volume_class": "control",
                "narrative_volume_counted": False,
                "action_id": "rest",
                "actual_action_id": "rest",
                "details": {},
                "commitment": {
                    "choice_id": "rest",
                    "actual_action_id": "rest",
                    "details": {},
                },
                "selection_policy": "asset_band_hold",
                "visible_button": {
                    "action_id": "rest",
                    "function": "_ap_rest",
                },
                "state_delta": {},
            }, "res://scenes/MainGame.gd")
        add("week_close", week, f"week:{week}:close", {"state_delta": {}}, "res://scenes/MainGame.gd")
    add("ending_open", 240, "ending:open", {"ending_id": "with_daeun", "page_count": 6}, "res://scenes/MainGame.gd")
    for page in range(6):
        add("ending_page", 240, f"ending:page:{page}", {"page_index": page}, "res://scenes/MainGame.gd")
    add("run_end", 240, "run:fixture:end", {
        "status": "pass",
        "errors": [],
        "product_go": "HOLD",
        "human_density_gate": "OPEN",
        "state_injection_detected": False,
        "final_state": {
            "week": 240,
            "total_assets": 100.0,
            "player_route": "none",
            "tendency": {"career": 0, "invest": 0, "found": 0},
            "tendency_realized": "",
            "flags": {},
            "ending_id": "with_daeun",
        },
    }, "res://scenes/MainGame.gd")
    return rows


def _renumber(rows: list[dict[str, Any]]) -> None:
    for index, row in enumerate(rows, 1):
        row["sequence"] = index


def _move_first_ending_page_before_open(rows: list[dict[str, Any]]) -> None:
    page_index = next(
        i for i, row in enumerate(rows) if row["record_type"] == "ending_page"
    )
    open_index = next(
        i for i, row in enumerate(rows) if row["record_type"] == "ending_open"
    )
    page = rows.pop(page_index)
    rows.insert(open_index, page)
    _renumber(rows)


def _move_ending_open_before_week_close(rows: list[dict[str, Any]]) -> None:
    open_index = next(
        i for i, row in enumerate(rows) if row["record_type"] == "ending_open"
    )
    close_index = next(
        i for i, row in enumerate(rows)
        if row["record_type"] == "week_close" and row["week"] == 240
    )
    ending_open = rows.pop(open_index)
    rows.insert(close_index, ending_open)
    _renumber(rows)


def _move_story_triad_to_week_two(rows: list[dict[str, Any]]) -> None:
    for row in rows:
        if row["occurrence_id"] == "story:4" \
                and row["record_type"] in {
                    "choice_offer", "story_choice", "story_result",
                }:
            row["week"] = 2
            row["month"] = 1
            row["chapter"] = 1


def _move_ending_surface_to_week_239(rows: list[dict[str, Any]]) -> None:
    for row in rows:
        if row["record_type"] in {"ending_open", "ending_page"}:
            row["week"] = 239
            row["month"] = 60
            row["chapter"] = 5


def _expect_failure(name: str, callback: Any) -> None:
    try:
        callback()
    except ContractError:
        return
    raise AssertionError(f"self-test mutation unexpectedly passed: {name}")


def self_test() -> None:
    validate_profiles(DEFAULT_PROFILES)
    validate_tool_sources()
    profile = _fixture_profile()
    profile_hash = "3" * 64
    valid = _fixture_rows(profile, profile_hash)
    validate_trace_rows(copy.deepcopy(valid), profile, profile_hash)
    cases = 1

    valid_241 = copy.deepcopy(valid)
    valid_241[-1]["payload"]["final_state"]["week"] = 241
    validate_trace_rows(valid_241, profile, profile_hash)
    cases += 1

    identity_rows = _identity_fixture_rows()
    _validate_early_investment_identity(
        copy.deepcopy(identity_rows), "investment_property_daeun")
    cases += 1

    leverage_identity_rows = copy.deepcopy(identity_rows)
    leverage_buy = next(
        row for row in leverage_identity_rows
        if row.get("record_type") == "main_action_commit"
        and row["payload"].get("actual_action_id") == "invest_buy"
    )
    leverage_buy["payload"]["actual_action_id"] = "invest_leverage"
    leverage_buy["payload"]["details"]["trade"] = "leverage_buy"
    leverage_buy["payload"]["commitment"]["actual_action_id"] = \
        "invest_leverage"
    leverage_buy["payload"]["commitment"]["details"]["trade"] = \
        "leverage_buy"
    _validate_early_investment_identity(
        leverage_identity_rows, "investment_property_daeun")
    cases += 1

    no_pressure_identity_rows = [
        row for row in copy.deepcopy(identity_rows)
        if not (
            row.get("record_type") == "main_action_commit"
            and row["payload"].get("actual_action_id") in {"side_shift", "save"}
        )
    ]
    _validate_early_investment_identity(
        no_pressure_identity_rows, "investment_property_daeun")
    cases += 1

    identity_mutations: list[tuple[str, Any]] = [
        ("identity-missing-third-study", lambda rows: rows[3]["payload"].update(
            {"actual_action_id": "study_read"})),
        ("identity-first-study-wrong-weight", lambda rows: rows[0]["payload"]
            ["commitment"]["identity_evidence"].update({"weight": 1})),
        ("identity-third-study-missing-receipt", lambda rows: rows[3]["payload"]
            ["commitment"].pop("identity_evidence")),
        ("identity-third-study-hidden", lambda rows: rows[3]["payload"]
            ["visible_button"].update({"action_id": "save"})),
        ("identity-third-study-late", lambda rows: rows[3].update({"week": 25})),
        ("identity-third-study-invest-before-drift", lambda rows: rows[3]
            ["payload"]["identity_before"]["tendency"].update({"invest": 4})),
        ("identity-third-study-already-realized", lambda rows: rows[3]
            ["payload"]["identity_before"].update({
                "player_route": "투자형", "tendency_realized": "invest",
            })),
        ("identity-third-study-no-transition", lambda rows: rows[3]["payload"].update({
            "identity_after": copy.deepcopy(
                rows[3]["payload"]["identity_before"]),
        })),
        ("identity-third-study-dual-route", lambda rows: rows[3]["payload"]
            ["identity_after"]["route_flags"].update({"route_career": True})),
        ("identity-late-first-buy", lambda rows: rows[5].update({"week": 49})),
        ("identity-skipped-visible-buy", lambda rows: next(
            row for row in rows
            if row["record_type"] == "main_action_offer" and row["week"] == 23
        )["payload"]["actions"][0].update({
            "action_id": "invest", "function": "_ap_invest",
        })),
        ("identity-hidden-first-buy", lambda rows: rows[5]["payload"]
            ["visible_button"].update({"action_id": "save"})),
        ("identity-missing-buy-receipt", lambda rows: rows[5]["payload"]
            ["commitment"].pop("identity_evidence")),
        ("identity-buy-lost-route", lambda rows: rows[5]["payload"]
            ["identity_before"].update({
                "player_route": "none", "tendency_realized": "",
            })),
        ("identity-buy-wrong-delta", lambda rows: rows[5]["payload"]
            ["identity_after"]["tendency"].update({"invest": 20})),
        ("identity-career-stolen", lambda rows: next(
            row for row in rows
            if row["record_type"] == "week_close" and row["week"] == 19
        )["payload"]["state_after"].update({
                "player_route": "직장형", "tendency_realized": "career",
                "flags": {"route_career": True, "pending_spec_career": True},
            })),
        ("identity-missing-invest-route", lambda rows: next(
            row for row in rows
            if row["record_type"] == "week_close" and row["week"] == 23
        )["payload"]["state_after"].update({"flags": {}})),
        ("identity-wrong-player-route", lambda rows: next(
            row for row in rows
            if row["record_type"] == "week_close" and row["week"] == 23
        )["payload"]["state_after"].update({"player_route": "직장형"})),
        ("identity-dual-route", lambda rows: next(
            row for row in rows
            if row["record_type"] == "week_close" and row["week"] == 23
        )["payload"]["state_after"]["flags"].update({"route_career": True})),
    ]
    for name, mutate in identity_mutations:
        rows = copy.deepcopy(identity_rows)
        mutate(rows)
        _expect_failure(
            name,
            lambda rows=rows: _validate_early_investment_identity(
                rows, "investment_property_daeun"),
        )
        cases += 1

    missing_identity_source = TRACE_SCRIPT.read_text(encoding="utf-8").replace(
        '\t\t"week_routine": GameState.week_routine.duplicate(true),\n',
        "",
        1,
    )
    _expect_failure(
        "trace-source-missing-identity-seal",
        lambda: _validate_identity_trace_source(missing_identity_source),
    )
    cases += 1

    mutations: list[tuple[str, Any]] = []
    mutations.append(("duplicate-sequence", lambda rows: rows.__setitem__(1, {**rows[1], "sequence": 1})))
    mutations.append(("wrong-candidate", lambda rows: rows[5].__setitem__("candidate_commit", "4" * 40)))
    mutations.append(("dirty-candidate", lambda rows: rows[0].__setitem__("candidate_dirty", True)))
    mutations.append(("state-injection", lambda rows: rows[10].__setitem__("state_injection", True)))
    mutations.append(("forbidden-arg", lambda rows: rows[0]["payload"].__setitem__("user_args", ["--demo-build"])))
    mutations.append(("missing-week", lambda rows: rows.pop(next(i for i, row in enumerate(rows) if row["record_type"] == "week_open" and row["week"] == 17))))
    mutations.append(("missing-ending-page", lambda rows: rows.pop(next(i for i, row in enumerate(rows) if row["record_type"] == "ending_page" and row["payload"]["page_index"] == 3))))
    mutations.append(("wrong-gate", lambda rows: rows[-1]["payload"].__setitem__("product_go", "GO")))
    mutations.append(("missing-edge", lambda rows: next(row for row in rows if row["record_type"] == "story_enter" and row["payload"]["event_id"] == "fixture_repeat")["payload"].__setitem__("provenance", "queued")))
    mutations.append(("event-id-dedup", lambda rows: rows.pop(next(i for i, row in enumerate(rows) if row["record_type"] == "story_enter" and row["payload"]["event_id"] == "fixture_repeat" and row["payload"]["event_serial"] == 3))))
    mutations.append(("duplicate-occurrence", lambda rows: [row.__setitem__("occurrence_id", "story:1") for row in rows if row["record_type"] == "story_enter" and row["payload"]["event_serial"] == 2]))
    mutations.append(("run-not-pass", lambda rows: rows[-1]["payload"].__setitem__("status", "fail")))
    mutations.append(("missing-state-delta", lambda rows: next(row for row in rows if row["record_type"] == "main_action_commit")["payload"].pop("state_delta")))
    mutations.append(("missing-actual-action-id", lambda rows: next(row for row in rows if row["record_type"] == "main_action_commit")["payload"].pop("actual_action_id")))
    mutations.append(("main-action-focus-identity-drift", lambda rows: next(row for row in rows if row["record_type"] == "main_action_commit")["payload"]["visible_button"].update({"action_id": "invest"})))
    mutations.append(("main-action-selected-identity-drift", lambda rows: next(row for row in rows if row["record_type"] == "main_action_commit")["payload"].update({"action_id": "invest"})))
    mutations.append(("main-action-commitment-identity-drift", lambda rows: next(row for row in rows if row["record_type"] == "main_action_commit")["payload"]["commitment"].update({"choice_id": "invest"})))
    mutations.append(("commitment-details-drift", lambda rows: next(row for row in rows if row["record_type"] == "main_action_commit")["payload"]["commitment"].__setitem__("details", {"study_type": 3})))
    mutations.append(("asset-band-unsafe-button", lambda rows: next(row for row in rows if row["record_type"] == "main_action_commit")["payload"].update({
        "action_id": "invest",
        "visible_button": {"action_id": "invest", "function": "_ap_invest"},
        "commitment": {"choice_id": "invest", "actual_action_id": "rest", "details": {}},
    })))
    mutations.append(("missing-story-result", lambda rows: rows.pop(next(i for i, row in enumerate(rows) if row["record_type"] == "story_result"))))
    mutations.append(("offer-event-mismatch", lambda rows: next(row for row in rows if row["record_type"] == "choice_offer")["payload"].__setitem__("event_id", "wrong_event")))
    mutations.append(("choice-event-mismatch", lambda rows: next(row for row in rows if row["record_type"] == "story_choice")["payload"].__setitem__("event_id", "wrong_event")))
    mutations.append(("result-event-mismatch", lambda rows: next(row for row in rows if row["record_type"] == "story_result")["payload"].__setitem__("event_id", "wrong_event")))
    mutations.append(("choice-not-offered", lambda rows: next(row for row in rows if row["record_type"] == "story_choice")["payload"].__setitem__("authored_index", 97)))
    mutations.append(("result-index-mismatch", lambda rows: next(row for row in rows if row["record_type"] == "story_result")["payload"].__setitem__("authored_index", 98)))
    mutations.append(("final-week-239", lambda rows: rows[-1]["payload"]["final_state"].__setitem__("week", 239)))
    mutations.append(("final-week-242", lambda rows: rows[-1]["payload"]["final_state"].__setitem__("week", 242)))
    mutations.append(("story-triad-week-mismatch", _move_story_triad_to_week_two))
    mutations.append(("ending-surface-week-239", _move_ending_surface_to_week_239))
    mutations.append(("run-end-row-week-239", lambda rows: rows[-1].update({"week": 239, "month": 60, "chapter": 5})))
    mutations.append(("ending-id-mismatch", lambda rows: next(row for row in rows if row["record_type"] == "ending_open")["payload"].__setitem__("ending_id", "different_ending")))
    mutations.append(("ending-page-before-open", _move_first_ending_page_before_open))
    mutations.append(("ending-open-before-week-close", _move_ending_open_before_week_close))

    for name, mutate in mutations:
        rows = copy.deepcopy(valid)
        mutate(rows)
        if name in {"missing-week", "missing-ending-page", "event-id-dedup", "missing-story-result"}:
            _renumber(rows)
        _expect_failure(name, lambda rows=rows: validate_trace_rows(rows, profile, profile_hash))
        cases += 1

    no_asset_band_profile = copy.deepcopy(profile)
    no_asset_band_profile["asset_band_policy"] = None
    _expect_failure(
        "asset-band-selection-without-profile-policy",
        lambda: validate_trace_rows(
            copy.deepcopy(valid), no_asset_band_profile, profile_hash
        ),
    )
    cases += 1

    direct_call_source = TRACE_SCRIPT.read_text(encoding="utf-8") + \
        '\nmain.call("_ap_side_job")\n'
    _expect_failure(
        "direct-hidden-ap-call",
        lambda: _validate_trace_script_source(direct_call_source),
    )
    cases += 1

    trace_source = TRACE_SCRIPT.read_text(encoding="utf-8")
    tutorial_branch = (
        "\tvar tutorial_overlay := _active_main_tutorial_overlay(main)\n"
        "\tif tutorial_overlay != null:\n"
        "\t\tvar tutorial_button := _focused_or_first_button(tutorial_overlay)\n"
        "\t\tif tutorial_button != null:\n"
        "\t\t\tawait _activate_button(tutorial_button)\n"
        "\t\treturn false\n"
    )
    if tutorial_branch not in trace_source:
        raise AssertionError("self-test fixture lost exact TutorialOverlay branch")

    missing_tutorial_branch = trace_source.replace(tutorial_branch, "", 1)
    _expect_failure(
        "main-action-missing-tutorial-surface",
        lambda: _validate_trace_script_source(missing_tutorial_branch),
    )
    cases += 1

    queued_guard = (
        "\tif not GameState.pending_story_queue.is_empty():\n"
        "\t\treturn false\n"
    )
    pre_tutorial_bypass = trace_source.replace(
        queued_guard,
        queued_guard
        + "\tvar bypass := get_viewport().gui_get_focus_owner() as Button\n"
        + "\tif bypass != null:\n"
        + "\t\tawait _activate_button(bypass)\n",
        1,
    )
    _expect_failure(
        "main-action-pre-tutorial-input-bypass",
        lambda: _validate_trace_script_source(pre_tutorial_bypass),
    )
    cases += 1

    tutorial_helper_body = _gdscript_function_body(
        trace_source, "_active_main_tutorial_overlay"
    )
    disabled_tutorial_recursion = trace_source.replace(
        tutorial_helper_body,
        tutorial_helper_body.replace(
            "for child in root.get_children():", "for child in []:", 1
        ),
        1,
    )
    _expect_failure(
        "main-action-disabled-tutorial-recursion",
        lambda: _validate_trace_script_source(disabled_tutorial_recursion),
    )
    cases += 1

    activation_body = _gdscript_function_body(trace_source, "_activate_button")
    stripped_activation_focus = trace_source.replace(
        activation_body,
        activation_body.replace(
            "\tbutton.grab_focus()\n"
            "\tif not _button_is_usable(button):\n"
            "\t\treturn\n"
            "\tif not button.has_focus():\n"
            "\t\tbutton.grab_focus()\n"
            "\tvar focused := get_viewport().gui_get_focus_owner()\n"
            "\tif focused != button:\n"
            "\t\treturn\n",
            "",
            1,
        ),
        1,
    )
    _expect_failure(
        "visible-button-enter-without-exact-focus",
        lambda: _validate_trace_script_source(stripped_activation_focus),
    )
    cases += 1

    moved_tutorial_branch = trace_source.replace(tutorial_branch, "", 1).replace(
        "\tvar focused := get_viewport().gui_get_focus_owner() as Button\n",
        tutorial_branch
        + "\n\tvar focused := get_viewport().gui_get_focus_owner() as Button\n",
        1,
    )
    _expect_failure(
        "main-action-tutorial-after-cards",
        lambda: _validate_trace_script_source(moved_tutorial_branch),
    )
    cases += 1

    weakened_tutorial_return = trace_source.replace(
        tutorial_branch,
        tutorial_branch.replace("\t\treturn false\n", "\t\t\treturn false\n", 1),
        1,
    )
    _expect_failure(
        "main-action-tutorial-conditional-fallthrough",
        lambda: _validate_trace_script_source(weakened_tutorial_return),
    )
    cases += 1

    missing_initial_focus_settle = trace_source.replace(
        "\tawait get_tree().process_frame\n"
        "\tif not _button_is_usable(button_raw):\n",
        "\tif not _button_is_usable(button_raw):\n",
        1,
    )
    _expect_failure(
        "main-action-missing-initial-focus-settle",
        lambda: _validate_trace_script_source(missing_initial_focus_settle),
    )
    cases += 1

    weakened_exact_focus = trace_source.replace(
        "\t\tif focused == button:\n",
        "\t\tif focused != null:\n",
        1,
    )
    _expect_failure(
        "main-action-weakened-exact-focus",
        lambda: _validate_trace_script_source(weakened_exact_focus),
    )
    cases += 1

    legacy_main_activation = trace_source.replace(
        "await _activate_settled_main_action_button(selected)",
        "await _activate_button(selected)",
        1,
    )
    _expect_failure(
        "main-action-legacy-focus-race",
        lambda: _validate_trace_script_source(legacy_main_activation),
    )
    cases += 1

    disabled_commitment_identity = trace_source.replace(
        "if expected_action_id.is_empty() or committed_action_id != expected_action_id:",
        "if false:",
        1,
    )
    _expect_failure(
        "main-action-disabled-commitment-identity",
        lambda: _validate_trace_script_source(disabled_commitment_identity),
    )
    cases += 1

    direct_pressed_emit = trace_source + "\nbutton.pressed.emit()\n"
    _expect_failure(
        "main-action-direct-pressed-emit",
        lambda: _validate_trace_script_source(direct_pressed_emit),
    )
    cases += 1

    disabled_scene_teardown = trace_source.replace(
        "\tawait _release_active_scene_for_exit()\n", "", 1
    )
    _expect_failure(
        "runtime-disabled-active-scene-teardown",
        lambda: _validate_trace_script_source(disabled_scene_teardown),
    )
    cases += 1

    story_race_source = TRACE_SCRIPT.read_text(encoding="utf-8").replace(
        "if not GameState.pending_story_queue.is_empty():", "if false:", 1
    )
    _expect_failure(
        "queued-story-action-race",
        lambda: _validate_trace_script_source(story_race_source),
    )
    cases += 1

    disabled_survival_source = TRACE_SCRIPT.read_text(encoding="utf-8").replace(
        "if _survival_recovery_required():", "if false:", 1
    )
    _expect_failure(
        "disabled-visible-survival-selection",
        lambda: _validate_trace_script_source(disabled_survival_source),
    )
    cases += 1

    disabled_asset_band_source = TRACE_SCRIPT.read_text(encoding="utf-8").replace(
        "if _asset_band_hold_required():", "if false:", 1
    )
    _expect_failure(
        "disabled-visible-asset-band-selection",
        lambda: _validate_trace_script_source(disabled_asset_band_source),
    )
    cases += 1

    disabled_modal_source = TRACE_SCRIPT.read_text(encoding="utf-8").replace(
        "var modal_button := _select_visible_modal_button(",
        "var modal_button := _focused_or_first_button(modal_surface)", 1
    )
    _expect_failure(
        "disabled-semantic-study-modal-selection",
        lambda: _validate_trace_script_source(disabled_modal_source),
    )
    cases += 1

    with tempfile.TemporaryDirectory() as temp_dir:
        inverted_policy = _load_json(DEFAULT_PROFILES)
        inverted_policy["profiles"][1]["survival_policy"][
            "resume_mental_at_or_above"
        ] = 40
        inverted_path = Path(temp_dir) / "inverted-survival-policy.json"
        inverted_path.write_text(json.dumps(inverted_policy), encoding="utf-8")
        _expect_failure(
            "inverted-survival-policy",
            lambda: validate_profiles(inverted_path, check_events=False),
        )
        cases += 1

    with tempfile.TemporaryDirectory() as temp_dir:
        wrong_study_policy = _load_json(DEFAULT_PROFILES)
        wrong_study_policy["profiles"][1]["modal_policy"]["study_type"] = 0
        wrong_path = Path(temp_dir) / "wrong-study-policy.json"
        wrong_path.write_text(json.dumps(wrong_study_policy), encoding="utf-8")
        _expect_failure(
            "wrong-route-study-modal-policy",
            lambda: validate_profiles(wrong_path, check_events=False),
        )
        cases += 1

    for mutation_name, mutation_value in (
        ("missing", None),
        ("wrong-index", {"index": 0, "selection_mode": "direct"}),
        ("timed", {"index": 1, "selection_mode": "timed"}),
    ):
        with tempfile.TemporaryDirectory() as temp_dir:
            drifted_general = _load_json(DEFAULT_PROFILES)
            general_profile = next(
                profile for profile in drifted_general["profiles"]
                if profile["id"] == GENERAL_PROFILE_ID
            )
            if mutation_value is None:
                general_profile["choice_overrides"].pop(
                    GENERAL_REQUIRED_CHOICE_OVERRIDE_EVENT
                )
            else:
                general_profile["choice_overrides"][
                    GENERAL_REQUIRED_CHOICE_OVERRIDE_EVENT
                ] = mutation_value
            drifted_path = Path(temp_dir) / f"general-{mutation_name}.json"
            drifted_path.write_text(json.dumps(drifted_general), encoding="utf-8")
            _expect_failure(
                f"general-unfunded-cafe-choice-{mutation_name}",
                lambda path=drifted_path: validate_profiles(
                    path, check_events=False
                ),
            )
            cases += 1

    for survival_event, survival_choice in GENERAL_SURVIVAL_CHOICE_OVERRIDES.items():
        for mutation_name, mutation_value in (
            ("missing", None),
            ("wrong-index", {"index": 0, "selection_mode": "direct"}),
            ("timed", {**survival_choice, "selection_mode": "timed"}),
        ):
            with tempfile.TemporaryDirectory() as temp_dir:
                drifted_general = _load_json(DEFAULT_PROFILES)
                general_profile = next(
                    profile for profile in drifted_general["profiles"]
                    if profile["id"] == GENERAL_PROFILE_ID
                )
                if mutation_value is None:
                    general_profile["choice_overrides"].pop(survival_event)
                else:
                    general_profile["choice_overrides"][
                        survival_event
                    ] = mutation_value
                drifted_path = Path(temp_dir) / (
                    f"general-{survival_event}-{mutation_name}.json"
                )
                drifted_path.write_text(
                    json.dumps(drifted_general), encoding="utf-8"
                )
                _expect_failure(
                    f"general-survival-{survival_event}-{mutation_name}",
                    lambda path=drifted_path: validate_profiles(
                        path, check_events=False
                    ),
                )
                cases += 1

    for mutation_name, mutation_value in (
        ("missing", None),
        ("wrong-index", {"index": 0, "selection_mode": "direct"}),
        ("timed", {"index": 1, "selection_mode": "timed"}),
    ):
        with tempfile.TemporaryDirectory() as temp_dir:
            drifted_property = _load_json(DEFAULT_PROFILES)
            property_profile = next(
                profile for profile in drifted_property["profiles"]
                if profile["id"] == PROPERTY_PROFILE_ID
            )
            if mutation_value is None:
                property_profile["choice_overrides"].pop(
                    PROPERTY_REQUIRED_CHOICE_OVERRIDE_EVENT
                )
            else:
                property_profile["choice_overrides"][
                    PROPERTY_REQUIRED_CHOICE_OVERRIDE_EVENT
                ] = mutation_value
            drifted_path = Path(temp_dir) / f"property-{mutation_name}.json"
            drifted_path.write_text(
                json.dumps(drifted_property), encoding="utf-8"
            )
            _expect_failure(
                f"property-ladder-realty-choice-{mutation_name}",
                lambda path=drifted_path: validate_profiles(
                    path, check_events=False
                ),
            )
            cases += 1

    with tempfile.TemporaryDirectory() as temp_dir:
        general_without_property_choice = _load_json(DEFAULT_PROFILES)
        general_profile = next(
            profile for profile in general_without_property_choice["profiles"]
            if profile["id"] == GENERAL_PROFILE_ID
        )
        general_profile["choice_overrides"].pop(
            PROPERTY_REQUIRED_CHOICE_OVERRIDE_EVENT
        )
        missing_path = Path(temp_dir) / "general-missing-property-choice.json"
        missing_path.write_text(
            json.dumps(general_without_property_choice), encoding="utf-8"
        )
        _expect_failure(
            "general-property-ladder-realty-choice-missing",
            lambda: validate_profiles(missing_path, check_events=False),
        )
        cases += 1

    for mutation_name, mutation_value in (
        ("missing", None),
        ("wrong-index", {"index": 0, "selection_mode": "direct"}),
        ("timed", {"index": 1, "selection_mode": "timed"}),
    ):
        with tempfile.TemporaryDirectory() as temp_dir:
            drifted_property = _load_json(DEFAULT_PROFILES)
            property_profile = next(
                profile for profile in drifted_property["profiles"]
                if profile["id"] == PROPERTY_PROFILE_ID
            )
            if mutation_value is None:
                property_profile["choice_overrides"].pop(
                    PROPERTY_CAST_GUARD_CHOICE_OVERRIDE_EVENT
                )
            else:
                property_profile["choice_overrides"][
                    PROPERTY_CAST_GUARD_CHOICE_OVERRIDE_EVENT
                ] = mutation_value
            drifted_path = Path(temp_dir) / f"property-cast-{mutation_name}.json"
            drifted_path.write_text(
                json.dumps(drifted_property), encoding="utf-8"
            )
            _expect_failure(
                f"property-cast-guard-choice-{mutation_name}",
                lambda path=drifted_path: validate_profiles(
                    path, check_events=False
                ),
            )
            cases += 1

    with tempfile.TemporaryDirectory() as temp_dir:
        drifted_property_order = _load_json(DEFAULT_PROFILES)
        property_profile = next(
            profile for profile in drifted_property_order["profiles"]
            if profile["id"] == PROPERTY_PROFILE_ID
        )
        sequence = property_profile["required_event_sequence"]
        minseo_index = sequence.index("arc_minseo_02_real")
        sale_index = sequence.index("inv_redev_completion_sale")
        sequence[minseo_index], sequence[sale_index] = (
            sequence[sale_index], sequence[minseo_index]
        )
        drifted_path = Path(temp_dir) / "property-runtime-sequence-order.json"
        drifted_path.write_text(
            json.dumps(drifted_property_order), encoding="utf-8"
        )
        _expect_failure(
            "property-runtime-sequence-order",
            lambda: validate_profiles(drifted_path, check_events=False),
        )
        cases += 1

    with tempfile.TemporaryDirectory() as temp_dir:
        missing_property_reckoning = _load_json(DEFAULT_PROFILES)
        property_profile = next(
            profile for profile in missing_property_reckoning["profiles"]
            if profile["id"] == PROPERTY_PROFILE_ID
        )
        property_profile["required_event_sequence"].remove(
            PROPERTY_CAST_GUARD_CHOICE_OVERRIDE_EVENT
        )
        drifted_path = Path(temp_dir) / "property-runtime-sequence-missing-reckoning.json"
        drifted_path.write_text(
            json.dumps(missing_property_reckoning), encoding="utf-8"
        )
        _expect_failure(
            "property-runtime-sequence-missing-reckoning",
            lambda: validate_profiles(drifted_path, check_events=False),
        )
        cases += 1

    with tempfile.TemporaryDirectory() as temp_dir:
        missing_asset_band = _load_json(DEFAULT_PROFILES)
        missing_asset_band["profiles"][2].pop("asset_band_policy")
        missing_path = Path(temp_dir) / "missing-asset-band-policy.json"
        missing_path.write_text(json.dumps(missing_asset_band), encoding="utf-8")
        _expect_failure(
            "missing-asset-band-policy",
            lambda: validate_profiles(missing_path, check_events=False),
        )
        cases += 1

        property_asset_band = _load_json(DEFAULT_PROFILES)
        property_asset_band["profiles"][1]["asset_band_policy"] = copy.deepcopy(
            property_asset_band["profiles"][2]["asset_band_policy"]
        )
        property_path = Path(temp_dir) / "property-asset-band-policy.json"
        property_path.write_text(json.dumps(property_asset_band), encoding="utf-8")
        _expect_failure(
            "property-profile-asset-band-policy",
            lambda: validate_profiles(property_path, check_events=False),
        )
        cases += 1

        unsafe_asset_band = _load_json(DEFAULT_PROFILES)
        unsafe_asset_band["profiles"][2]["asset_band_policy"].update({
            "action_priority": ["invest"],
            "function_priority": ["_ap_invest"],
        })
        unsafe_path = Path(temp_dir) / "unsafe-asset-band-policy.json"
        unsafe_path.write_text(json.dumps(unsafe_asset_band), encoding="utf-8")
        _expect_failure(
            "unsafe-asset-band-policy",
            lambda: validate_profiles(unsafe_path, check_events=False),
        )
        cases += 1

        drifted_asset_band = _load_json(DEFAULT_PROFILES)
        drifted_asset_band["profiles"][2]["asset_band_policy"][
            "activate_at_total_assets"
        ] += 1
        drifted_path = Path(temp_dir) / "drifted-asset-band-policy.json"
        drifted_path.write_text(json.dumps(drifted_asset_band), encoding="utf-8")
        _expect_failure(
            "drifted-asset-band-threshold",
            lambda: validate_profiles(drifted_path, check_events=False),
        )
        cases += 1

    missing_audio_drain_source = TRACE_SCRIPT.read_text(encoding="utf-8").replace(
        "await _release_audio_for_exit()", "pass", 1
    )
    _expect_failure(
        "missing-audio-teardown-drain",
        lambda: _validate_trace_script_source(missing_audio_drain_source),
    )
    cases += 1

    obsolete_exit_wait_source = TRACE_SCRIPT.read_text(encoding="utf-8").replace(
        "\tawait AudioManager.drain_pending_timers_for_exit()\n",
        "\tawait AudioManager.drain_pending_timers_for_exit()\n"
        "\tawait get_tree().create_timer(2.05).timeout\n",
        1,
    )
    _expect_failure(
        "obsolete-main-game-timer-expiry-wait",
        lambda: _validate_trace_script_source(obsolete_exit_wait_source),
    )
    cases += 1

    missing_real_mix_drain_source = TRACE_SCRIPT.read_text(encoding="utf-8").replace(
        "\tawait _drain_audio_server_after_stop()\n",
        "\tawait get_tree().process_frame\n",
        1,
    )
    _expect_failure(
        "missing-real-audio-mix-drain",
        lambda: _validate_trace_script_source(missing_real_mix_drain_source),
    )
    cases += 1

    trace_audio_source = TRACE_SCRIPT.read_text(encoding="utf-8")
    immersion_audio_source = IMMERSION_LOOP_SCRIPT.read_text(encoding="utf-8")
    unsafe_unbounded_block = (
        "\tvar drain_seconds := time_to_next_mix + mix_period_seconds\n"
        "\t\t+ AUDIO_MIX_DRAIN_MARGIN_SECONDS\n"
        "\t# clampf marker retained; AUDIO_MIX_DRAIN_MAX_SECONDS retained.\n"
    )
    for fixture_label, fixture_source, fixture_validator in (
        ("trace", trace_audio_source, _validate_trace_script_source),
        (
            "immersion",
            immersion_audio_source,
            _validate_immersion_audio_teardown_source,
        ),
    ):
        bypass_mutations = (
            (
                "period-reassigned-after-measurement",
                fixture_source.replace(
                    "\tvar mix_period_seconds := time_since_last_mix + time_to_next_mix\n",
                    "\tvar mix_period_seconds := time_since_last_mix + time_to_next_mix\n"
                    "\tmix_period_seconds = 0.0\n",
                    1,
                ),
            ),
            (
                "next-time-reassigned-after-measurement",
                fixture_source.replace(
                    "\tvar mix_period_seconds := time_since_last_mix + time_to_next_mix\n",
                    "\ttime_to_next_mix = 0.0\n"
                    "\tvar mix_period_seconds := time_since_last_mix + time_to_next_mix\n",
                    1,
                ),
            ),
            (
                "drain-reassigned-after-clamp",
                fixture_source.replace(
                    "\t_audio_mix_drain_timer.start(drain_seconds)\n",
                    "\tdrain_seconds = AUDIO_MIX_DRAIN_MARGIN_SECONDS\n"
                    "\t_audio_mix_drain_timer.start(drain_seconds)\n",
                    1,
                ),
            ),
            (
                "unbounded-drain-expression",
                fixture_source.replace(
                    "\tvar drain_seconds := clampf(\n"
                    "\t\ttime_to_next_mix + mix_period_seconds\n"
                    "\t\t\t+ AUDIO_MIX_DRAIN_MARGIN_SECONDS,\n"
                    "\t\tAUDIO_MIX_DRAIN_MARGIN_SECONDS,\n"
                    "\t\tAUDIO_MIX_DRAIN_MAX_SECONDS)\n",
                    unsafe_unbounded_block,
                    1,
                ),
            ),
            (
                "commented-direct-start-margin-actual",
                fixture_source.replace(
                    "\t_audio_mix_drain_timer.start(drain_seconds)\n",
                    "\t# _audio_mix_drain_timer.start(drain_seconds)\n"
                    "\t_audio_mix_drain_timer.start("
                    "AUDIO_MIX_DRAIN_MARGIN_SECONDS)\n",
                    1,
                ),
            ),
        )
        for mutation_name, mutated_source in bypass_mutations:
            _expect_failure(
                f"{fixture_label}-{mutation_name}",
                lambda source=mutated_source, validator=fixture_validator: validator(source),
            )
            cases += 1

    duplicate_probe_asset_source = immersion_audio_source.replace(
        '"res://assets/audio/bgm_victory.ogg"',
        '"res://assets/audio/sfx_click.wav"',
        1,
    )
    _expect_failure(
        "immersion-probe-duplicates-wav-instead-of-victory-ogg",
        lambda: _validate_immersion_audio_teardown_source(
            duplicate_probe_asset_source
        ),
    )
    cases += 1

    single_immersion_subprocess_source = AUDIT_RUNNER.read_text(
        encoding="utf-8"
    ).replace("IMMERSION_AUDIO_TEARDOWN_RUNS=12", "IMMERSION_AUDIO_TEARDOWN_RUNS=1", 1)
    _expect_failure(
        "audit-runs-audio-teardown-only-once",
        lambda: _validate_audit_runtime_guard(single_immersion_subprocess_source),
    )
    cases += 1

    skipped_immersion_loop_source = AUDIT_RUNNER.read_text(
        encoding="utf-8"
    ).replace("  IMMERSION_RUN_INDEX=1", "  IMMERSION_RUN_INDEX=13", 1)
    _expect_failure(
        "audit-skips-audio-teardown-stress-loop",
        lambda: _validate_audit_runtime_guard(skipped_immersion_loop_source),
    )
    cases += 1

    stalled_immersion_loop_source = AUDIT_RUNNER.read_text(
        encoding="utf-8"
    ).replace(
        "    IMMERSION_RUN_INDEX=$((IMMERSION_RUN_INDEX + 1))\n",
        "",
        1,
    )
    _expect_failure(
        "audit-audio-teardown-stress-loop-does-not-increment",
        lambda: _validate_audit_runtime_guard(stalled_immersion_loop_source),
    )
    cases += 1

    audit_runtime_source = AUDIT_RUNNER.read_text(encoding="utf-8")
    crlf_audit_runtime_source = audit_runtime_source.replace("\n", "\r\n").encode(
        "utf-8"
    )
    _expect_failure(
        "audit-exact-source-seal-rejects-crlf-byte-drift",
        lambda: _validate_audit_runtime_guard(crlf_audit_runtime_source),
    )
    cases += 1
    exact_immersion_command = (
        '    IMMERSION_RAW=$(run_limited env HOME="$IMMERSION_HOME" "$GODOT" '
        '--headless --quit-after 3600 res://tools/ImmersionLoopCheck.tscn 2>&1)\n'
    )
    synthetic_immersion_success_source = audit_runtime_source.replace(
        exact_immersion_command,
        "    # " + exact_immersion_command.lstrip()
        + '    IMMERSION_RAW="IMMERSION_LOOP_CHECK_OK"\n',
        1,
    )
    _expect_failure(
        "audit-comments-out-immersion-subprocess-and-synthesizes-success",
        lambda: _validate_audit_runtime_guard(synthetic_immersion_success_source),
    )
    cases += 1

    forced_immersion_status_source = audit_runtime_source.replace(
        "    IMMERSION_STATUS=$?\n",
        "    IMMERSION_STATUS=0\n",
        1,
    )
    _expect_failure(
        "audit-forces-immersion-subprocess-status-zero",
        lambda: _validate_audit_runtime_guard(forced_immersion_status_source),
    )
    cases += 1

    printed_scene_marker_source = audit_runtime_source.replace(
        exact_immersion_command,
        "    IMMERSION_RAW=$(printf '%s\\n' "
        "'res://tools/ImmersionLoopCheck.tscn IMMERSION_LOOP_CHECK_OK')\n",
        1,
    )
    _expect_failure(
        "audit-prints-scene-marker-instead-of-running-godot",
        lambda: _validate_audit_runtime_guard(printed_scene_marker_source),
    )
    cases += 1

    forced_true_immersion_verdict_source = audit_runtime_source.replace(
        '        "IMMERSION_LOOP_CHECK_OK" teardown_strict; then\n',
        '        "IMMERSION_LOOP_CHECK_OK" teardown_strict || true; then\n',
        1,
    )
    _expect_failure(
        "audit-forces-immersion-verdict-true",
        lambda: _validate_audit_runtime_guard(
            forced_true_immersion_verdict_source
        ),
    )
    cases += 1

    inverted_immersion_verdict_source = audit_runtime_source.replace(
        '    if godot_check_passed "$IMMERSION_RAW" "$IMMERSION_STATUS" \\\n',
        '    if ! godot_check_passed "$IMMERSION_RAW" "$IMMERSION_STATUS" \\\n',
        1,
    )
    _expect_failure(
        "audit-inverts-immersion-verdict",
        lambda: _validate_audit_runtime_guard(inverted_immersion_verdict_source),
    )
    cases += 1

    commented_teardown_mode_source = audit_runtime_source.replace(
        '        "IMMERSION_LOOP_CHECK_OK" teardown_strict; then\n',
        '        # "IMMERSION_LOOP_CHECK_OK" teardown_strict\n'
        '        "IMMERSION_LOOP_CHECK_OK" strict; then\n',
        1,
    )
    _expect_failure(
        "audit-keeps-teardown-mode-only-in-comment",
        lambda: _validate_audit_runtime_guard(commented_teardown_mode_source),
    )
    cases += 1

    sanitized_immersion_output_source = audit_runtime_source.replace(
        '    cleanup_isolated_home "$IMMERSION_HOME"\n',
        '    cleanup_isolated_home "$IMMERSION_HOME"\n'
        "    printf -v IMMERSION_RAW '%s' \"$(printf '%s\\n' "
        "\"$IMMERSION_RAW\" | grep -v 'WARNING: ObjectDB')\"\n",
        1,
    )
    _expect_failure(
        "audit-sanitizes-immersion-output-after-capture",
        lambda: _validate_audit_runtime_guard(sanitized_immersion_output_source),
    )
    cases += 1

    disabled_teardown_error_mode_source = audit_runtime_source.replace(
        '  if [ "$error_mode" = "teardown_strict" ]; then\n',
        '  if false && [ "$error_mode" = "teardown_strict" ]; then\n',
        1,
    )
    _expect_failure(
        "audit-disables-teardown-strict-error-pattern",
        lambda: _validate_audit_runtime_guard(
            disabled_teardown_error_mode_source
        ),
    )
    cases += 1

    filtered_objectdb_error_lines_source = audit_runtime_source.replace(
        '  error_lines=$(printf \'%s\\n\' "$output" | grep -iE "$engine_error_pattern")\n',
        '  error_lines=$(printf \'%s\\n\' "$output" | grep -iE "$engine_error_pattern" '
        "| grep -v 'ObjectDB')\n",
        1,
    )
    _expect_failure(
        "audit-filters-objectdb-from-error-lines",
        lambda: _validate_audit_runtime_guard(filtered_objectdb_error_lines_source),
    )
    cases += 1

    weakened_objectdb_self_test_source = audit_runtime_source.replace(
        '    0 "AUDIT_GUARD_OBJECTDB_SELF_TEST_OK" teardown_strict >/dev/null; then\n',
        '    0 "AUDIT_GUARD_OBJECTDB_SELF_TEST_OK" strict >/dev/null; then\n',
        1,
    )
    _expect_failure(
        "audit-objectdb-self-test-uses-weaker-mode",
        lambda: _validate_audit_runtime_guard(weakened_objectdb_self_test_source),
    )
    cases += 1

    skipped_objectdb_self_test_source = audit_runtime_source.replace(
        AUDIT_OBJECTDB_SELF_TEST_BLOCK,
        "if false; then\n" + AUDIT_OBJECTDB_SELF_TEST_BLOCK + "fi\n",
        1,
    )
    _expect_failure(
        "audit-wraps-objectdb-self-test-in-false-branch",
        lambda: _validate_audit_runtime_guard(skipped_objectdb_self_test_source),
    )
    cases += 1

    immersion_section_heading = (
        'echo "● 주간 행동 에코·인과 프레임·비네트·예감·SFX 믹스 검사"\n'
    )
    redefined_run_limited_source = audit_runtime_source.replace(
        immersion_section_heading,
        "run_limited() {\n"
        "  printf '%s\\n' 'IMMERSION_LOOP_CHECK_OK'\n"
        "}\n"
        + immersion_section_heading,
        1,
    )
    _expect_failure(
        "audit-redefines-run-limited-before-immersion",
        lambda: _validate_audit_runtime_guard(redefined_run_limited_source),
    )
    cases += 1

    redefined_cleanup_source = audit_runtime_source.replace(
        immersion_section_heading,
        "cleanup_isolated_home() {\n"
        '  IMMERSION_RAW="IMMERSION_LOOP_CHECK_OK"\n'
        "  IMMERSION_STATUS=0\n"
        "}\n"
        + immersion_section_heading,
        1,
    )
    _expect_failure(
        "audit-redefines-cleanup-to-forge-immersion-state",
        lambda: _validate_audit_runtime_guard(redefined_cleanup_source),
    )
    cases += 1

    redefined_godot_check_source = audit_runtime_source.replace(
        immersion_section_heading,
        "godot_check_passed() {\n"
        "  return 0\n"
        "}\n"
        + immersion_section_heading,
        1,
    )
    _expect_failure(
        "audit-redefines-godot-check-after-self-test",
        lambda: _validate_audit_runtime_guard(redefined_godot_check_source),
    )
    cases += 1

    zeroed_immersion_run_count_source = audit_runtime_source.replace(
        immersion_section_heading,
        "IMMERSION_AUDIO_TEARDOWN_RUNS=0\n" + immersion_section_heading,
        1,
    )
    _expect_failure(
        "audit-zeroes-immersion-run-count-before-loop",
        lambda: _validate_audit_runtime_guard(zeroed_immersion_run_count_source),
    )
    cases += 1

    cleared_immersion_exit_source = audit_runtime_source.replace(
        '  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — 몰입 루프 체크 건너뜀."\n'
        "  IMMERSION_EXIT=0\n"
        "fi\n",
        '  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — 몰입 루프 체크 건너뜀."\n'
        "  IMMERSION_EXIT=0\n"
        "fi\n"
        "IMMERSION_EXIT=0\n",
        1,
    )
    _expect_failure(
        "audit-clears-immersion-exit-after-section",
        lambda: _validate_audit_runtime_guard(cleared_immersion_exit_source),
    )
    cases += 1

    safe_mix_sample_block = (
        "\tvar time_since_last_mix: float = maxf(\n"
        "\t\t0.0, float(AudioServer.get_time_since_last_mix()))\n"
        "\tvar time_to_next_mix: float = maxf(\n"
        "\t\t0.0, float(AudioServer.get_time_to_next_mix()))\n"
    )
    unsafe_mix_sample_block = (
        "\tvar time_to_next_mix: float = maxf(\n"
        "\t\t0.0, float(AudioServer.get_time_to_next_mix()))\n"
        "\tvar time_since_last_mix: float = maxf(\n"
        "\t\t0.0, float(AudioServer.get_time_since_last_mix()))\n"
    )
    next_mix_sampled_first_source = TRACE_SCRIPT.read_text(
        encoding="utf-8"
    ).replace(safe_mix_sample_block, unsafe_mix_sample_block, 1)
    _expect_failure(
        "next-mix-sampled-before-elapsed-mix",
        lambda: _validate_trace_script_source(next_mix_sampled_first_source),
    )
    cases += 1

    unmeasured_mix_drain_source = TRACE_SCRIPT.read_text(encoding="utf-8").replace(
        "float(AudioServer.get_time_to_next_mix())",
        "0.0",
        1,
    )
    _expect_failure(
        "unmeasured-audio-mix-drain",
        lambda: _validate_trace_script_source(unmeasured_mix_drain_source),
    )
    cases += 1

    missing_mix_period_source = TRACE_SCRIPT.read_text(encoding="utf-8").replace(
        "time_to_next_mix + mix_period_seconds",
        "time_to_next_mix",
        1,
    )
    _expect_failure(
        "next-boundary-only-audio-drain",
        lambda: _validate_trace_script_source(missing_mix_period_source),
    )
    cases += 1

    zero_mix_margin_source = TRACE_SCRIPT.read_text(encoding="utf-8").replace(
        "const AUDIO_MIX_DRAIN_MARGIN_SECONDS := 0.02",
        "const AUDIO_MIX_DRAIN_MARGIN_SECONDS := 0.0",
        1,
    )
    _expect_failure(
        "zero-audio-mix-drain-margin",
        lambda: _validate_trace_script_source(zero_mix_margin_source),
    )
    cases += 1

    tiny_mix_max_source = TRACE_SCRIPT.read_text(encoding="utf-8").replace(
        "const AUDIO_MIX_DRAIN_MAX_SECONDS := 0.25",
        "const AUDIO_MIX_DRAIN_MAX_SECONDS := 0.001",
        1,
    )
    _expect_failure(
        "truncated-audio-mix-drain-window",
        lambda: _validate_trace_script_source(tiny_mix_max_source),
    )
    cases += 1

    repeating_mix_timer_source = TRACE_SCRIPT.read_text(encoding="utf-8").replace(
        "_audio_mix_drain_timer.one_shot = true",
        "_audio_mix_drain_timer.one_shot = false",
        1,
    )
    _expect_failure(
        "audio-mix-drain-timer-not-one-shot",
        lambda: _validate_trace_script_source(repeating_mix_timer_source),
    )
    cases += 1

    main_game_source = MAIN_GAME_SCRIPT.read_text(encoding="utf-8")
    free_milestone_timer_source = main_game_source.replace(
        "\t\t\t_milestone_portrait_timer.start()\n",
        "\t\t\tawait get_tree().create_timer(2.0).timeout\n",
        1,
    )
    _expect_failure(
        "main-game-free-milestone-timer-regression",
        lambda: _validate_main_game_timer_source(free_milestone_timer_source),
    )
    cases += 1

    non_one_shot_timer_source = main_game_source.replace(
        "_critical_portrait_timer.one_shot = true",
        "_critical_portrait_timer.one_shot = false",
        1,
    )
    _expect_failure(
        "main-game-critical-timer-not-one-shot",
        lambda: _validate_main_game_timer_source(non_one_shot_timer_source),
    )
    cases += 1

    missing_exit_flag_cleanup = main_game_source.replace(
        '\tGameState.flags["just_hit_milestone"] = false\n',
        "",
        1,
    )
    _expect_failure(
        "main-game-missing-exit-transient-cleanup",
        lambda: _validate_main_game_timer_source(missing_exit_flag_cleanup),
    )
    cases += 1


    missing_timer_expiry_source = AUDIO_MANAGER_SCRIPT.read_text(
        encoding="utf-8"
    ).replace("(raw_timer as SceneTreeTimer).time_left = 0.0", "pass", 1)
    _expect_failure(
        "missing-real-audio-timer-expiry",
        lambda: _validate_audio_manager_source(missing_timer_expiry_source),
    )
    cases += 1

    teardown_whitelist_runner = TRACE_RUNNER.read_text(encoding="utf-8") + \
        "\n# grep -viE teardown bypass\n"
    _expect_failure(
        "runner-teardown-error-whitelist",
        lambda: _validate_runner_error_policy(teardown_whitelist_runner),
    )
    cases += 1

    generic_objectdb_runner = TRACE_RUNNER.read_text(encoding="utf-8").replace(
        "Library/Application Support/Godot/app_userdata/강남드림/${project_root#/}",
        "Library/Application Support/Godot/app_userdata/강남드림/objectdb_snapshots",
        1,
    )
    _expect_failure(
        "runner-generic-objectdb-directory",
        lambda: _validate_runner_isolation_contract(generic_objectdb_runner),
    )
    cases += 1

    missing_xdg_objectdb_runner = TRACE_RUNNER.read_text(encoding="utf-8").replace(
        "${trace_root}/xdg-data/godot/app_userdata/강남드림/${project_root#/}",
        "${trace_root}/xdg-data/godot/app_userdata/강남드림/objectdb_snapshots",
        1,
    )
    _expect_failure(
        "runner-missing-exact-xdg-objectdb-directory",
        lambda: _validate_runner_isolation_contract(missing_xdg_objectdb_runner),
    )
    cases += 1

    unsafe_darwin_tmp_runner = TRACE_RUNNER.read_text(encoding="utf-8").replace(
        'trace_base="/private/tmp"',
        'trace_base="${TMPDIR:-/tmp}"',
        1,
    )
    _expect_failure(
        "runner-darwin-long-tmpdir-regression",
        lambda: _validate_runner_isolation_contract(unsafe_darwin_tmp_runner),
    )
    cases += 1

    unguarded_mktemp_runner = TRACE_RUNNER.read_text(encoding="utf-8").replace(
        'if ! trace_root="$(mktemp -d ',
        'trace_root="$(mktemp -d ',
        1,
    )
    _expect_failure(
        "runner-unguarded-mktemp",
        lambda: _validate_runner_isolation_contract(unguarded_mktemp_runner),
    )
    cases += 1

    late_cleanup_runner = TRACE_RUNNER.read_text(encoding="utf-8").replace(
        "trap cleanup_trace_root RETURN\n\n  trace_home=",
        "trace_home=",
        1,
    ).replace(
        '  godot_log="${trace_root}/godot.log"',
        '  trap cleanup_trace_root RETURN\n  godot_log="${trace_root}/godot.log"',
        1,
    )
    _expect_failure(
        "runner-late-cleanup-trap",
        lambda: _validate_runner_isolation_contract(late_cleanup_runner),
    )
    cases += 1

    for name, injected_line in (
        ("direct-turn-injection", "GameState.turn = 240"),
        ("direct-money-injection", "GameState.money += 3000000000"),
        ("direct-flag-injection", 'GameState.flags["route_invest"] = true'),
        ("state-set-injection", 'GameState.set("turn", 240)'),
        ("state-indexed-set-injection", 'GameState.set_indexed("flags.route_invest", true)'),
        ("calendar-advance-injection", "GameState.advance_calendar()"),
        ("state-alias-injection", "var injected_state = GameState\ninjected_state.turn = 240"),
        ("container-alias-injection", 'var injected_flags = GameState.flags\ninjected_flags["route_invest"] = true'),
        ("queue-push-injection", "GameState.pending_story_queue.push_front({})"),
        ("flag-set-injection", 'GameState.flags.set("route_invest", true)'),
        ("state-bracket-injection", 'GameState["turn"] = 240'),
        ("flag-property-injection", "GameState.flags.route_invest = true"),
    ):
        injected_source = TRACE_SCRIPT.read_text(encoding="utf-8") + \
            f"\n{injected_line}\n"
        _expect_failure(
            name,
            lambda source=injected_source: _validate_trace_script_source(source),
        )
        cases += 1

    with tempfile.TemporaryDirectory() as temp_dir:
        malformed = Path(temp_dir) / "malformed.jsonl"
        malformed.write_text("{not json}\n", encoding="utf-8")
        _expect_failure("malformed-jsonl", lambda: _read_jsonl(malformed))
        cases += 1
    print(f"FULL_GAME_RUNTIME_TRACE_SELF_TEST_OK cases={cases}")


def _parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--profiles", type=Path, default=DEFAULT_PROFILES)
    parser.add_argument("--trace", type=Path, action="append", default=[])
    parser.add_argument("--profile")
    parser.add_argument("--candidate-commit")
    parser.add_argument("--candidate-tree")
    parser.add_argument("--print-profile-hash", action="store_true")
    parser.add_argument("--self-test", action="store_true")
    return parser


def main(argv: list[str] | None = None) -> int:
    args = _parser().parse_args(argv)
    try:
        profiles = validate_profiles(args.profiles)
        validate_tool_sources()
        if args.print_profile_hash:
            if not args.profile or args.profile not in profiles:
                raise ContractError("--print-profile-hash requires a known --profile")
            print(_profile_hash(args.profiles, args.profile))
            return 0
        if args.self_test:
            self_test()
            return 0
        if not args.trace:
            print(
                "FULL_GAME_RUNTIME_TRACE_CONTRACT_OK "
                "profiles=3 trace_runtime=PENDING product_go=HOLD human_density_gate=OPEN"
            )
            return 0
        summaries = []
        for trace_path in args.trace:
            summaries.append(validate_trace_file(
                trace_path,
                args.profiles,
                expected_profile=args.profile,
                expected_commit=args.candidate_commit,
                expected_tree=args.candidate_tree,
            ))
        for summary in summaries:
            print(
                "FULL_GAME_RUNTIME_TRACE_VALID "
                f"profile={summary['profile_id']} commit={summary['candidate_commit']} "
                f"tree={summary['candidate_tree']} records={summary['records']} "
                f"story_occurrences={summary['story_occurrences']} ending={summary['ending_id']} "
                f"assets={summary['total_assets']} product_go=HOLD human_density_gate=OPEN"
            )
        return 0
    except (ContractError, OSError) as exc:
        print(f"FULL_GAME_RUNTIME_TRACE_AUDIT_FAIL: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
