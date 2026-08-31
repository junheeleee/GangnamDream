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
MAIN_GAME_SCRIPT = ROOT / "scenes" / "MainGame.gd"

SCHEMA_VERSION = 1
TRACE_SCHEMA_VERSION = 1
PROFILE_IDS = (
    "baseline_safe_people",
    "investment_property_daeun",
    "general_near_goal_father_passed",
)
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
    "choice_overrides",
    "main_action_priority",
    "main_function_priority",
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
        sequence = _string_list(profile["required_event_sequence"], f"{label}.required_event_sequence")
        if check_events:
            unknown = sorted(set(sequence) - event_ids)
            if unknown:
                raise ContractError(f"{label} required sequence has unknown events: {unknown}")
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
        "await _activate_button(selected)",
        "if not GameState.pending_story_queue.is_empty():",
        'call_deferred("_graceful_shutdown", 0)',
        "func _graceful_shutdown(exit_code: int) -> void:",
        "await _release_audio_for_exit()",
        "func _release_audio_for_exit() -> void:",
        "_detach_audio_streams(get_tree().root)",
        "player.stream = null",
        "(raw_sounds as Dictionary).clear()",
        "await get_tree().create_timer(0.25).timeout",
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


def _validate_runner_error_policy(runner: str) -> None:
    if "Could not create ObjectDB Snapshots directory" in runner:
        raise ContractError("runner must not whitelist the ObjectDB Profiler engine error")
    if "grep -viE" in runner or "grep -vE" in runner:
        raise ContractError("runner must not filter engine teardown errors")
    if "WARNING: ObjectDB instances leaked at exit" not in runner:
        raise ContractError("runner must fail closed on ObjectDB teardown leaks")


def validate_tool_sources() -> None:
    required_paths = (TRACE_SCRIPT, TRACE_SCENE, TRACE_RUNNER)
    for path in required_paths:
        if not path.is_file():
            raise ContractError(f"missing runtime trace tool: {path.relative_to(ROOT)}")
    source = TRACE_SCRIPT.read_text(encoding="utf-8")
    _validate_trace_script_source(source)
    runner = TRACE_RUNNER.read_text(encoding="utf-8")
    for needle in (
        "mktemp -d",
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
        "Library/Application Support/Godot/app_userdata/강남드림/objectdb_snapshots",
        'case "${objectdb_snapshot_dir}" in',
        '"${trace_root}"/*)',
        "reason=objectdb_snapshot_dir_outside_trace_root",
        "reason=objectdb_snapshot_dir_precreate_failed",
        "WARNING: ObjectDB instances leaked at exit",
        "reason=candidate_changed_during_import",
        "reason=candidate_changed_during_runtime",
        "reason=trace_contract_rejected",
    ):
        if needle not in runner:
            raise ContractError(f"runner isolation/identity contract is missing {needle!r}")
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
            raise ContractError(f"runner invokes forbidden state flavor argument {forbidden}")
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
    if final_state.get("week") != profile["target"]["minimum_week"]:
        raise ContractError("run must end on exact Week 240")
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
        "choice_overrides": {},
        "main_action_priority": ["rest"],
        "main_function_priority": ["_ap_rest"],
        "required_event_sequence": ["fixture_root", "fixture_repeat", "fixture_end"],
        "required_edges": [
            {"from": "fixture_root", "to": "fixture_repeat", "provenance": "follow_up"}
        ],
        "required_event_occurrences": {"fixture_repeat": 2},
        "target": {
            "minimum_week": 240,
            "ending_page_count": 6,
            "minimum_total_assets": None,
            "maximum_total_assets": None,
            "required_flags_true": [],
            "required_flags_false": [],
            "required_ending_ids": [],
            "forbidden_ending_ids": ["instant_legend"],
        },
    }


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
    mutations.append(("missing-story-result", lambda rows: rows.pop(next(i for i, row in enumerate(rows) if row["record_type"] == "story_result"))))
    mutations.append(("offer-event-mismatch", lambda rows: next(row for row in rows if row["record_type"] == "choice_offer")["payload"].__setitem__("event_id", "wrong_event")))
    mutations.append(("choice-event-mismatch", lambda rows: next(row for row in rows if row["record_type"] == "story_choice")["payload"].__setitem__("event_id", "wrong_event")))
    mutations.append(("result-event-mismatch", lambda rows: next(row for row in rows if row["record_type"] == "story_result")["payload"].__setitem__("event_id", "wrong_event")))
    mutations.append(("choice-not-offered", lambda rows: next(row for row in rows if row["record_type"] == "story_choice")["payload"].__setitem__("authored_index", 97)))
    mutations.append(("result-index-mismatch", lambda rows: next(row for row in rows if row["record_type"] == "story_result")["payload"].__setitem__("authored_index", 98)))
    mutations.append(("final-week-241", lambda rows: rows[-1]["payload"]["final_state"].__setitem__("week", 241)))
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

    direct_call_source = TRACE_SCRIPT.read_text(encoding="utf-8") + \
        '\nmain.call("_ap_side_job")\n'
    _expect_failure(
        "direct-hidden-ap-call",
        lambda: _validate_trace_script_source(direct_call_source),
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

    missing_audio_drain_source = TRACE_SCRIPT.read_text(encoding="utf-8").replace(
        "await _release_audio_for_exit()", "pass", 1
    )
    _expect_failure(
        "missing-audio-teardown-drain",
        lambda: _validate_trace_script_source(missing_audio_drain_source),
    )
    cases += 1

    teardown_whitelist_runner = TRACE_RUNNER.read_text(encoding="utf-8") + \
        "\n# grep -viE teardown bypass\n"
    _expect_failure(
        "runner-teardown-error-whitelist",
        lambda: _validate_runner_error_policy(teardown_whitelist_runner),
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
