#!/usr/bin/env python3
"""Validate the language-independent story rule ledger.

The ledger is intentionally introduced before replacing legacy runtime routing.
It gives prerequisites, mutually exclusive outcomes, locations, and communication
channels one machine-readable owner while the existing save-compatible flags stay
in place.
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
EVENT_DIR = ROOT / "content" / "events"
EVENT_EN_DIR = ROOT / "content" / "events_en"
RULES_PATH = ROOT / "content" / "meta" / "story_rules.json"
CHAPTER5_CAUSAL_LEDGER_PATH = (
    ROOT / "content" / "meta" / "chapter5_causal_ledger.json"
)
CHAPTER5_FINALE_LEDGER_PATH = (
    ROOT / "content" / "meta" / "chapter5_finale_ledger.json"
)
CHAPTER5_GENERAL_FINALE_LEDGER_PATH = (
    ROOT / "content" / "meta" / "chapter5_general_finale_ledger.json"
)
DEMO_CONTRACT_PATH = ROOT / "content" / "meta" / "demo_core_loop_v2.json"
JOBS_PATH = ROOT / "content" / "jobs.json"
VISUAL_CONTRACTS_PATH = ROOT / "assets" / "event_visual_contracts.json"
SCENE_AUDIO_PATH = ROOT / "assets" / "scene_audio_manifest.json"

ALLOWED_CHANNELS = {
    "in_person",
    "internal",
    "phone",
    "video_call",
    "message",
    "memory",
    "narration",
}
REMOTE_CHANNELS = {"phone", "video_call", "message", "memory"}
DYNAMIC_SCENE_LOCATIONS = {"current_housing", "current_workplace"}
ALLOWED_PORTRAIT_ROLES = {"present", "remote", "local", "none"}
ALLOWED_STATES = {"", "connected", "incoming", "dialing", "missed", "received"}
LOGIC_KEYS = {
    "requires",
    "forbids",
    "produces",
    "choice_produces",
    "core_loop_v2",
    "legacy",
    "prerequisites",
}
LEGACY_KEYS = {"requires_flags", "forbids_flags", "produces_all", "produces_any"}
CORE_LOOP_V2_KEYS = {"requires_flags", "forbids_flags", "produces_all", "produces_any"}
PREREQUISITE_GROUP_KEYS = {"all", "any"}
PREREQUISITE_CLAUSE_KEYS = {"path", "op", "value"}
PREREQUISITE_OPERATORS = {
    "eq",
    "neq",
    "in",
    "not_in",
    "gte",
    "lte",
    "truthy",
    "falsy",
}
PREREQUISITE_STATIC_PATHS = {
    "turn",
    "player.job.id",
    "player.investment_skill",
}
PREREQUISITE_DYNAMIC_PREFIXES = ("flags.",)
PRESENTATION_KEYS = {
    "channel",
    "state",
    "scene_location",
    "remote_location",
    "remote_actor",
    "participants",
    "portrait_role",
    "nameplate_role",
    "expected_portrait",
    "participant_roles",
    "expected_background",
    "expected_ambience",
}
COMMUNICATION_TITLE = re.compile(r"전화|통화|카톡|문자|연락", re.IGNORECASE)
ALLOWED_TRANSITION_MODES = {"same_location", "explicit_move", "time_cut", "memory_cut"}
ALLOWED_NAMEPLATE_ROLES = {"auto", "hidden"}
TRANSITION_KEYS = {
    "mode",
    "from_location",
    "to_location",
    "arrival_cue_ko",
    "arrival_cue_en",
    "queue_only",
    "legacy_only",
}
SPEECH_KEYS = {"speakers"}
SPEAKER_KEYS = {"register_basis", "references", "choice_indices"}
SPEECH_REFERENCE_KEYS = {"fact", "source"}
SPEECH_SOURCE_KINDS = {
    "self",
    "public",
    "scene_observation",
    "prior_event",
    "prior_choice",
}
CHAPTER5_W210_QUEUE_EDGE = (
    "arc_y5_jaehyuk_return_call_reference"
    "->arc_y5_jaehyuk_father_document_reference"
)
CHAPTER5_W240_FINALE_EDGE = (
    "arc_final_countdown_property_not_executed"
    "->arc_y5_final_week_daeun_outbound"
)
CHAPTER5_W240_GENERAL_FINALE_EDGE = (
    "arc_final_countdown_general_near_goal_passed"
    "->arc_y5_final_week_general_people_outbound"
)


def load_json(path: Path) -> Any:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise RuntimeError(f"cannot load {path.relative_to(ROOT)}: {exc}") from exc


def chapter5_queue_only_edges() -> set[str]:
    """Return non-demo queue edges proven by the typed Chapter 5 ledgers."""
    ledger = load_json(CHAPTER5_CAUSAL_LEDGER_PATH)
    if not isinstance(ledger, dict) \
            or ledger.get("schema_version") != 1 \
            or ledger.get("ledger_id") != "chapter5_m49_m55_causal_route_v1" \
            or ledger.get("expected_root_count") != 19 \
            or ledger.get("expected_choice_count") != 47:
        return set()
    roots = ledger.get("roots", [])
    if not isinstance(roots, list) or len(roots) != 19 \
            or not all(isinstance(root, dict) for root in roots):
        return set()
    source = roots[10]
    target = roots[11]
    if source.get("sequence") != 11 or target.get("sequence") != 12 \
            or source.get("turn") != 210 or target.get("turn") != 210 \
            or source.get("event_id") \
                != "arc_y5_jaehyuk_return_call_reference" \
            or target.get("event_id") \
                != "arc_y5_jaehyuk_father_document_reference" \
            or source.get("condition") is not None \
            or target.get("condition") is not None:
        return set()

    finale = load_json(CHAPTER5_FINALE_LEDGER_PATH)
    if not isinstance(finale, dict) \
            or finale.get("schema_version") != 1 \
            or finale.get("ledger_id") != "chapter5_m56_m60_safe_finale_v1" \
            or finale.get("expected_root_count") != 11 \
            or finale.get("expected_active_root_count") != 9 \
            or finale.get("expected_choice_count") != 30 \
            or finale.get("expected_active_choice_count") != 24:
        return {CHAPTER5_W210_QUEUE_EDGE}
    finale_roots = finale.get("roots", [])
    if not isinstance(finale_roots, list) or len(finale_roots) != 11 \
            or not all(isinstance(root, dict) for root in finale_roots):
        return {CHAPTER5_W210_QUEUE_EDGE}
    signature = finale_roots[9]
    outbound = finale_roots[10]
    if signature.get("stage_sequence") != 8 \
            or outbound.get("stage_sequence") != 9 \
            or signature.get("stage") != "signature" \
            or outbound.get("stage") != "outbound" \
            or signature.get("turn") != 240 \
            or outbound.get("turn") != 240 \
            or signature.get("event_id") \
                != "arc_final_countdown_property_not_executed" \
            or outbound.get("event_id") \
                != "arc_y5_final_week_daeun_outbound" \
            or signature.get("active_when") is not None \
            or outbound.get("active_when") is not None:
        return {CHAPTER5_W210_QUEUE_EDGE}

    established_edges = {CHAPTER5_W210_QUEUE_EDGE, CHAPTER5_W240_FINALE_EDGE}
    general = load_json(CHAPTER5_GENERAL_FINALE_LEDGER_PATH)
    if not isinstance(general, dict) \
            or general.get("schema_version") != 1 \
            or general.get("ledger_id") \
                != "chapter5_general_near_goal_passed_finale_v2" \
            or general.get("expected_root_count") != 8 \
            or general.get("expected_active_root_count") != 6 \
            or general.get("expected_choice_count") != 17 \
            or general.get("expected_active_choice_count") != 13 \
            or general.get("stages") != [
                "father_legacy", "debt_memory_consequence", "summit",
                "record_disposition", "sacrifice", "outbound",
            ]:
        return established_edges
    entry = general.get("entry_contract", {})
    if not isinstance(entry, dict) or entry.get("turn") != 224 \
            or entry.get("source_choice_keys") != {
                "m51_minseo_arrival": [0, 1],
                "w211_name_boundary": [0, 1],
                "w220_debt_memory_reconnect": [0, 1],
            }:
        return established_edges
    general_roots = general.get("roots", [])
    expected_general_ids = [
        "arc_y5_general_father_legacy_voice_exact",
        "arc_y5_general_father_legacy_cafe_exact",
        "arc_y5_general_debt_memory_voice_exact",
        "arc_y5_general_debt_memory_cafe_exact",
        "arc_y5_general_pre_ending_summit_exact",
        "arc_y5_general_final_record_seal",
        "arc_final_countdown_general_near_goal_passed",
        "arc_y5_final_week_general_people_outbound",
    ]
    if not isinstance(general_roots, list) or len(general_roots) != 8 \
            or not all(isinstance(root, dict) for root in general_roots):
        return established_edges
    if [root.get("event_id") for root in general_roots] != expected_general_ids:
        return established_edges
    general_sacrifice = general_roots[6]
    general_outbound = general_roots[7]
    if general_sacrifice.get("stage_sequence") != 5 \
            or general_outbound.get("stage_sequence") != 6 \
            or general_sacrifice.get("variant_sequence") != 1 \
            or general_outbound.get("variant_sequence") != 1 \
            or general_sacrifice.get("stage") != "sacrifice" \
            or general_outbound.get("stage") != "outbound" \
            or general_sacrifice.get("turn") != 240 \
            or general_outbound.get("turn") != 240 \
            or general_sacrifice.get("event_id") \
                != "arc_final_countdown_general_near_goal_passed" \
            or general_outbound.get("event_id") \
                != "arc_y5_final_week_general_people_outbound" \
            or general_sacrifice.get("active_when") is not None \
            or general_outbound.get("active_when") is not None:
        return established_edges
    return established_edges | {CHAPTER5_W240_GENERAL_FINALE_EDGE}


def load_events() -> tuple[dict[str, dict[str, Any]], list[str]]:
    events: dict[str, dict[str, Any]] = {}
    errors: list[str] = []
    for path in sorted(EVENT_DIR.glob("*.json")):
        data = load_json(path)
        rows = data.get("events", []) if isinstance(data, dict) else data
        if not isinstance(rows, list):
            errors.append(f"{path.name}: root must be an array")
            continue
        for row in rows:
            if not isinstance(row, dict):
                continue
            event_id = str(row.get("id", ""))
            if not event_id:
                continue
            if event_id in events:
                errors.append(f"duplicate event id: {event_id}")
                continue
            events[event_id] = row
    return events, errors


def load_overlay_events(directory: Path) -> dict[str, dict[str, Any]]:
    events: dict[str, dict[str, Any]] = {}
    for path in sorted(directory.glob("*.json")):
        data = load_json(path)
        rows = data.get("events", []) if isinstance(data, dict) else data
        if not isinstance(rows, list):
            continue
        for row in rows:
            if not isinstance(row, dict):
                continue
            event_id = str(row.get("id", ""))
            if event_id:
                events[event_id] = row
    return events


def event_location(
    event_id: str,
    events: dict[str, dict[str, Any]],
    rules: dict[str, Any],
) -> str:
    rule = rules.get(event_id, {})
    if isinstance(rule, dict):
        presentation = rule.get("presentation", {})
        if isinstance(presentation, dict):
            location = str(presentation.get("scene_location", ""))
            if location and location not in {"current_location", "current_housing"}:
                return location
    return str(events.get(event_id, {}).get("background", ""))


def portrait_actor(portrait_id: str) -> str:
    prefixes = (
        "cafe_broker_kim",
        "cafe_investor",
        "goshiwon_owner",
        "player",
        "father",
        "mother",
        "sangchul",
        "hyunsu",
        "jiyeon",
        "daeun",
        "jaehyuk",
        "minseo",
        "seongjun",
        "boss",
    )
    for prefix in prefixes:
        if portrait_id == prefix or portrait_id.startswith(prefix + "_"):
            return prefix
    return ""


def choice_flags(choice: dict[str, Any]) -> set[str]:
    raw = choice.get("flags", [])
    return {str(flag) for flag in raw} if isinstance(raw, list) else set()


def validate_string_list(
    value: Any, owner: str, errors: list[str], *, allow_empty: bool = True
) -> list[str]:
    if not isinstance(value, list) or any(not isinstance(item, str) for item in value):
        errors.append(f"{owner}: expected an array of strings")
        return []
    if not allow_empty and not value:
        errors.append(f"{owner}: must not be empty")
    return [str(item) for item in value]


def validate_fact_clause(
    clause: Any,
    owner: str,
    operation: str,
    fact_values: dict[str, set[str]],
    errors: list[str],
) -> tuple[str, str] | None:
    if not isinstance(clause, dict):
        errors.append(f"{owner}: fact clause must be an object")
        return None
    expected_keys = {"fact", operation}
    if set(clause) != expected_keys:
        errors.append(f"{owner}: expected keys {sorted(expected_keys)}, got {sorted(clause)}")
        return None
    fact_id = str(clause.get("fact", ""))
    value = str(clause.get(operation, ""))
    if fact_id not in fact_values:
        errors.append(f"{owner}: unknown fact {fact_id}")
        return None
    if value not in fact_values[fact_id]:
        errors.append(f"{owner}: invalid {fact_id} value {value}")
        return None
    return fact_id, value


def validate_prerequisite_clause(
    clause: Any,
    owner: str,
    job_ids: set[str],
    errors: list[str],
) -> None:
    if not isinstance(clause, dict):
        errors.append(f"{owner}: prerequisite clause must be an object")
        return
    unknown = set(clause) - PREREQUISITE_CLAUSE_KEYS
    if unknown:
        errors.append(f"{owner}: unknown keys {sorted(unknown)}")
    path = str(clause.get("path", "")).strip()
    operation = str(clause.get("op", "")).strip()
    if not path:
        errors.append(f"{owner}: path is required")
    elif (
        path not in PREREQUISITE_STATIC_PATHS
        and not any(path.startswith(prefix) and len(path) > len(prefix)
                    for prefix in PREREQUISITE_DYNAMIC_PREFIXES)
    ):
        errors.append(f"{owner}: unsupported context path {path!r}")
    if operation not in PREREQUISITE_OPERATORS:
        errors.append(f"{owner}: invalid operator {operation!r}")
        return
    if operation not in {"truthy", "falsy"} and "value" not in clause:
        errors.append(f"{owner}: {operation} requires value")
        return
    value = clause.get("value")
    if operation in {"in", "not_in"}:
        if not isinstance(value, list) or not value:
            errors.append(f"{owner}: {operation} value must be a non-empty array")
            return
    if path == "player.job.id" and operation not in {"truthy", "falsy"}:
        raw_values = value if isinstance(value, list) else [value]
        unknown_jobs = sorted(
            str(job_id)
            for job_id in raw_values
            if str(job_id) and str(job_id) not in job_ids
        )
        if unknown_jobs:
            errors.append(f"{owner}: unknown job ids {unknown_jobs}")


def build_demo_event_weeks(
    events: dict[str, dict[str, Any]], errors: list[str]
) -> dict[str, set[int]]:
    """Map V2 authored events to every demo week that can expose them."""
    try:
        contract = load_json(DEMO_CONTRACT_PATH)
    except RuntimeError as exc:
        errors.append(str(exc))
        return {}
    if not isinstance(contract, dict):
        errors.append("content/meta/demo_core_loop_v2.json: root must be an object")
        return {}
    bundles = contract.get("scene_bundles", {})
    if not isinstance(bundles, dict):
        errors.append("demo_core_loop_v2.scene_bundles must be an object")
        return {}

    event_weeks: dict[str, set[int]] = {}

    def add_chain(root_id: str, weeks: set[int]) -> None:
        pending = [root_id]
        seen: set[str] = set()
        while pending:
            current = pending.pop()
            if not current or current in seen:
                continue
            seen.add(current)
            if weeks:
                event_weeks.setdefault(current, set()).update(weeks)
            event = events.get(current, {})
            choices = event.get("choices", []) if isinstance(event, dict) else []
            if not isinstance(choices, list):
                continue
            for choice in choices:
                if not isinstance(choice, dict):
                    continue
                follow_up = str(choice.get("follow_up_event", "")).strip()
                if follow_up:
                    pending.append(follow_up)

    for raw_bundle in bundles.values():
        if not isinstance(raw_bundle, dict):
            continue
        weeks = {
            int(week)
            for week in raw_bundle.get("allowed_weeks", [])
            if isinstance(week, (int, float)) and not isinstance(week, bool)
        }
        for root_id in raw_bundle.get("existing_roots", []):
            add_chain(str(root_id), weeks)

    for raw_contract in contract.get("future_application_contracts", {}).values():
        if not isinstance(raw_contract, dict):
            continue
        weeks = {
            int(week)
            for week in raw_contract.get("allowed_weeks", [])
            if isinstance(week, (int, float)) and not isinstance(week, bool)
        }
        event_id = str(raw_contract.get("result_event", "")).strip()
        if event_id and weeks:
            event_weeks.setdefault(event_id, set()).update(weeks)
    for raw_contract in contract.get("future_story_contracts", {}).values():
        if not isinstance(raw_contract, dict):
            continue
        trigger = str(raw_contract.get("trigger_event", "")).strip()
        exam_week = raw_contract.get("exam_week")
        if trigger and isinstance(exam_week, (int, float)):
            event_weeks.setdefault(trigger, set()).add(int(exam_week))
        result = str(raw_contract.get("result_event", "")).strip()
        result_week = raw_contract.get("result_available_week")
        if result and isinstance(result_week, (int, float)):
            event_weeks.setdefault(result, set()).add(int(result_week))
    for raw_contract in contract.get("post_demo_application_contracts", {}).values():
        if not isinstance(raw_contract, dict):
            continue
        result = str(raw_contract.get("result_event", "")).strip()
        result_week = raw_contract.get("not_before_week")
        if result and isinstance(result_week, (int, float)):
            event_weeks.setdefault(result, set()).add(int(result_week))
    return event_weeks


def validate_speech_contract(
    event_id: str,
    speech: Any,
    presentation: Any,
    events: dict[str, dict[str, Any]],
    event_weeks: dict[str, set[int]],
    errors: list[str],
) -> tuple[int, int, int, int, int]:
    """Validate speaker-owned knowledge and return reference error counters."""
    owner = f"events.{event_id}.speech"
    common_references = 0
    producerless = 0
    unreachable = 0
    reference_count = 0
    choice_scoped_speakers = 0
    if not isinstance(speech, dict):
        errors.append(f"{owner}: must be an object")
        return (
            reference_count,
            producerless,
            common_references,
            unreachable,
            choice_scoped_speakers,
        )
    if "references" in speech:
        common_references += 1
        errors.append(f"{owner}: common references are forbidden; assign them to a speaker")
    unknown_speech = set(speech) - SPEECH_KEYS
    if unknown_speech:
        errors.append(f"{owner}: unknown keys {sorted(unknown_speech)}")
    speakers = speech.get("speakers")
    if not isinstance(speakers, dict) or not speakers:
        errors.append(f"{owner}.speakers: must be a non-empty object")
        return (
            reference_count,
            producerless,
            common_references,
            unreachable,
            choice_scoped_speakers,
        )

    presentation_dict = presentation if isinstance(presentation, dict) else {}
    participants = presentation_dict.get("participants", [])
    allowed_speakers = {
        str(value) for value in participants
    } if isinstance(participants, list) else set()
    if str(presentation_dict.get("channel", "")) in REMOTE_CHANNELS:
        allowed_speakers.add("player")
        remote_actor = str(presentation_dict.get("remote_actor", "")).strip()
        if remote_actor:
            allowed_speakers.add(remote_actor)
    event_choices = events.get(event_id, {}).get("choices", [])
    if not isinstance(event_choices, list):
        event_choices = []

    for raw_speaker_id, raw_spec in speakers.items():
        speaker_id = str(raw_speaker_id).strip()
        speaker_owner = f"{owner}.speakers.{speaker_id or '<empty>'}"
        if not speaker_id:
            errors.append(f"{speaker_owner}: speaker id is required")
        if not isinstance(raw_spec, dict):
            errors.append(f"{speaker_owner}: must be an object")
            continue
        unknown_spec = set(raw_spec) - SPEAKER_KEYS
        if unknown_spec:
            errors.append(f"{speaker_owner}: unknown keys {sorted(unknown_spec)}")
        if not str(raw_spec.get("register_basis", "")).strip():
            errors.append(f"{speaker_owner}.register_basis: must not be empty")
        raw_choice_indices = raw_spec.get("choice_indices")
        choice_indices: list[int] = []
        if raw_choice_indices is not None:
            if (
                not isinstance(raw_choice_indices, list)
                or not raw_choice_indices
                or any(
                    not isinstance(index, int) or isinstance(index, bool)
                    for index in raw_choice_indices
                )
            ):
                errors.append(
                    f"{speaker_owner}.choice_indices: must be a non-empty integer array"
                )
            else:
                choice_indices = [int(index) for index in raw_choice_indices]
                if len(choice_indices) != len(set(choice_indices)):
                    errors.append(
                        f"{speaker_owner}.choice_indices: duplicate choice indices"
                    )
                invalid_indices = sorted(
                    index
                    for index in choice_indices
                    if index < 0 or index >= len(event_choices)
                )
                if invalid_indices:
                    errors.append(
                        f"{speaker_owner}.choice_indices: invalid indices "
                        f"{invalid_indices} for {event_id}"
                    )
                else:
                    choice_scoped_speakers += 1
        if speaker_id and speaker_id not in allowed_speakers and not choice_indices:
            errors.append(
                f"{speaker_owner}: speaker is not present in the base presentation "
                "and has no choice-result scope; "
                f"allowed={sorted(allowed_speakers)}"
            )
        references = raw_spec.get("references")
        if not isinstance(references, list) or not references:
            errors.append(f"{speaker_owner}.references: must be a non-empty array")
            continue
        seen_facts: set[str] = set()
        for index, raw_reference in enumerate(references):
            ref_owner = f"{speaker_owner}.references[{index}]"
            reference_count += 1
            if not isinstance(raw_reference, dict):
                errors.append(f"{ref_owner}: must be an object")
                continue
            unknown_reference = set(raw_reference) - SPEECH_REFERENCE_KEYS
            if unknown_reference:
                errors.append(f"{ref_owner}: unknown keys {sorted(unknown_reference)}")
            fact = str(raw_reference.get("fact", "")).strip()
            if not fact:
                errors.append(f"{ref_owner}.fact: must not be empty")
            elif fact in seen_facts:
                errors.append(f"{ref_owner}.fact: duplicate speaker fact {fact!r}")
            seen_facts.add(fact)
            source = raw_reference.get("source")
            if not isinstance(source, dict):
                producerless += 1
                errors.append(f"{ref_owner}.source: must be an object")
                continue
            kind = str(source.get("kind", "")).strip()
            if kind not in SPEECH_SOURCE_KINDS:
                producerless += 1
                errors.append(f"{ref_owner}.source: invalid kind {kind!r}")
                continue
            if kind in {"self", "public", "scene_observation"}:
                allowed_keys = {"kind", "detail"}
                if set(source) - allowed_keys:
                    errors.append(
                        f"{ref_owner}.source: unknown keys "
                        f"{sorted(set(source) - allowed_keys)}"
                    )
                if not str(source.get("detail", "")).strip():
                    producerless += 1
                    errors.append(f"{ref_owner}.source.detail: must not be empty")
                continue

            allowed_keys = {"kind", "event_id", "detail"}
            if kind == "prior_choice":
                allowed_keys.add("choice_index")
            unknown_source = set(source) - allowed_keys
            if unknown_source:
                errors.append(f"{ref_owner}.source: unknown keys {sorted(unknown_source)}")
            source_event_id = str(source.get("event_id", "")).strip()
            source_event = events.get(source_event_id)
            if not source_event_id or source_event is None:
                producerless += 1
                errors.append(f"{ref_owner}.source: missing event {source_event_id!r}")
                continue
            if source_event_id == event_id:
                unreachable += 1
                errors.append(f"{ref_owner}.source: prior source cannot be the current event")
            if kind == "prior_choice":
                choice_index = source.get("choice_index")
                choices = source_event.get("choices", [])
                if (
                    not isinstance(choice_index, int)
                    or isinstance(choice_index, bool)
                    or not isinstance(choices, list)
                    or choice_index < 0
                    or choice_index >= len(choices)
                ):
                    producerless += 1
                    errors.append(
                        f"{ref_owner}.source: invalid choice_index {choice_index!r} "
                        f"for {source_event_id}"
                    )
            source_weeks = event_weeks.get(source_event_id, set())
            target_weeks = event_weeks.get(event_id, set())
            if source_weeks and target_weeks and min(source_weeks) > max(target_weeks):
                unreachable += 1
                errors.append(
                    f"{ref_owner}.source: {source_event_id} weeks "
                    f"{sorted(source_weeks)} occur after {event_id} weeks "
                    f"{sorted(target_weeks)}"
                )
    return (
        reference_count,
        producerless,
        common_references,
        unreachable,
        choice_scoped_speakers,
    )


def main() -> int:
    errors: list[str] = []
    events, event_errors = load_events()
    errors.extend(event_errors)
    ledger = load_json(RULES_PATH)
    if not isinstance(ledger, dict):
        print("STORY_CONSISTENCY_AUDIT_FAIL ledger root must be an object")
        return 1
    if int(ledger.get("schema_version", 0)) != 3:
        errors.append("schema_version must be 3")

    fact_types = ledger.get("fact_types", {})
    fact_values: dict[str, set[str]] = {}
    if not isinstance(fact_types, dict):
        errors.append("fact_types must be an object")
        fact_types = {}
    for fact_id, spec in fact_types.items():
        owner = f"fact_types.{fact_id}"
        if not isinstance(spec, dict) or spec.get("type") != "enum":
            errors.append(f"{owner}: only enum facts are supported")
            continue
        values = validate_string_list(spec.get("values"), owner + ".values", errors, allow_empty=False)
        if len(values) != len(set(values)):
            errors.append(f"{owner}: duplicate enum values")
        default = str(spec.get("default", ""))
        if default not in values:
            errors.append(f"{owner}: default {default!r} is not in values")
        fact_values[str(fact_id)] = set(values)

    groups = ledger.get("exclusive_flag_groups", {})
    if not isinstance(groups, dict):
        errors.append("exclusive_flag_groups must be an object")
        groups = {}
    normalized_groups: dict[str, set[str]] = {}
    for group_id, raw_flags in groups.items():
        flags = validate_string_list(
            raw_flags, f"exclusive_flag_groups.{group_id}", errors, allow_empty=False
        )
        if len(flags) < 2:
            errors.append(f"exclusive_flag_groups.{group_id}: needs at least two flags")
        normalized_groups[str(group_id)] = set(flags)

    rules = ledger.get("events", {})
    if not isinstance(rules, dict):
        errors.append("events must be an object")
        rules = {}
    events_en = load_overlay_events(EVENT_EN_DIR)
    raw_jobs = load_json(JOBS_PATH)
    job_ids = {
        str(job.get("id", ""))
        for job in raw_jobs
        if isinstance(raw_jobs, list) and isinstance(job, dict) and job.get("id")
    } if isinstance(raw_jobs, list) else set()
    if not job_ids:
        errors.append("content/jobs.json: no job ids found")

    role_types = set(
        validate_string_list(
            ledger.get("participant_role_types", []),
            "participant_role_types",
            errors,
            allow_empty=False,
        )
    )

    visual_data = load_json(VISUAL_CONTRACTS_PATH)
    visual_rows = visual_data.get("contracts", []) if isinstance(visual_data, dict) else []
    visual_contracts: dict[str, dict[str, Any]] = {}
    if not isinstance(visual_rows, list):
        errors.append("assets/event_visual_contracts.json: contracts must be an array")
        visual_rows = []
    for row in visual_rows:
        if not isinstance(row, dict) or not str(row.get("id", "")):
            continue
        contract_id = str(row["id"])
        if contract_id in visual_contracts:
            errors.append(f"duplicate visual contract id: {contract_id}")
        visual_contracts[contract_id] = row

    audio_data = load_json(SCENE_AUDIO_PATH)
    audio_events = audio_data.get("events", {}) if isinstance(audio_data, dict) else {}
    if not isinstance(audio_events, dict):
        errors.append("assets/scene_audio_manifest.json: events must be an object")
        audio_events = {}

    remote_contracts = 0
    logic_contracts = 0
    dynamic_location_contracts = 0
    speech_contracts = 0
    speaker_references = 0
    speech_producerless = 0
    speech_common_references = 0
    speech_unreachable = 0
    speech_choice_scoped = 0
    demo_event_weeks = build_demo_event_weeks(events, errors)
    for event_id, rule in rules.items():
        owner = f"events.{event_id}"
        event = events.get(str(event_id))
        if event is None:
            errors.append(f"{owner}: references missing event")
            continue
        if not isinstance(rule, dict):
            errors.append(f"{owner}: rule must be an object")
            continue
        unknown_rule_keys = set(rule) - {"logic", "presentation", "speech"}
        if unknown_rule_keys:
            errors.append(f"{owner}: unknown keys {sorted(unknown_rule_keys)}")

        logic = rule.get("logic")
        if logic is not None:
            logic_contracts += 1
            if not isinstance(logic, dict):
                errors.append(f"{owner}.logic: must be an object")
            else:
                unknown_logic = set(logic) - LOGIC_KEYS
                if unknown_logic:
                    errors.append(f"{owner}.logic: unknown keys {sorted(unknown_logic)}")
                required_facts: set[tuple[str, str]] = set()
                forbidden_facts: set[tuple[str, str]] = set()
                for index, clause in enumerate(logic.get("requires", [])):
                    parsed = validate_fact_clause(
                        clause, f"{owner}.logic.requires[{index}]", "is", fact_values, errors
                    )
                    if parsed:
                        required_facts.add(parsed)
                for index, clause in enumerate(logic.get("forbids", [])):
                    parsed = validate_fact_clause(
                        clause, f"{owner}.logic.forbids[{index}]", "is", fact_values, errors
                    )
                    if parsed:
                        forbidden_facts.add(parsed)
                overlap = required_facts & forbidden_facts
                if overlap:
                    errors.append(f"{owner}.logic: required and forbidden facts overlap: {sorted(overlap)}")
                for index, clause in enumerate(logic.get("produces", [])):
                    validate_fact_clause(
                        clause, f"{owner}.logic.produces[{index}]", "set", fact_values, errors
                    )

                prerequisites = logic.get("prerequisites")
                if prerequisites is not None:
                    if not isinstance(prerequisites, dict):
                        errors.append(f"{owner}.logic.prerequisites: must be an object")
                    else:
                        unknown_groups = set(prerequisites) - PREREQUISITE_GROUP_KEYS
                        if unknown_groups:
                            errors.append(
                                f"{owner}.logic.prerequisites: unknown keys "
                                f"{sorted(unknown_groups)}"
                            )
                        clause_count = 0
                        for group_key in PREREQUISITE_GROUP_KEYS:
                            if group_key not in prerequisites:
                                continue
                            clauses = prerequisites[group_key]
                            group_owner = f"{owner}.logic.prerequisites.{group_key}"
                            if not isinstance(clauses, list):
                                errors.append(f"{group_owner}: must be an array")
                                continue
                            if not clauses:
                                errors.append(f"{group_owner}: must not be empty")
                            clause_count += len(clauses)
                            for index, clause in enumerate(clauses):
                                validate_prerequisite_clause(
                                    clause,
                                    f"{group_owner}[{index}]",
                                    job_ids,
                                    errors,
                                )
                        if clause_count == 0:
                            errors.append(
                                f"{owner}.logic.prerequisites: needs at least one clause"
                            )

                choices = event.get("choices", [])
                choices = choices if isinstance(choices, list) else []
                choice_produces = logic.get("choice_produces", {})
                if not isinstance(choice_produces, dict):
                    errors.append(f"{owner}.logic.choice_produces: must be an object")
                else:
                    for raw_index, clauses in choice_produces.items():
                        try:
                            choice_index = int(raw_index)
                        except (TypeError, ValueError):
                            errors.append(f"{owner}.logic.choice_produces: invalid choice index {raw_index}")
                            continue
                        if choice_index < 0 or choice_index >= len(choices):
                            errors.append(f"{owner}.logic.choice_produces: choice {choice_index} does not exist")
                        if not isinstance(clauses, list) or not clauses:
                            errors.append(f"{owner}.logic.choice_produces.{raw_index}: must be a non-empty array")
                            continue
                        for clause_index, clause in enumerate(clauses):
                            validate_fact_clause(
                                clause,
                                f"{owner}.logic.choice_produces.{raw_index}[{clause_index}]",
                                "set",
                                fact_values,
                                errors,
                            )

                legacy = logic.get("legacy", {})
                if not isinstance(legacy, dict):
                    errors.append(f"{owner}.logic.legacy: must be an object")
                else:
                    unknown_legacy = set(legacy) - LEGACY_KEYS
                    if unknown_legacy:
                        errors.append(f"{owner}.logic.legacy: unknown keys {sorted(unknown_legacy)}")
                    legacy_lists: dict[str, list[str]] = {}
                    for key in LEGACY_KEYS:
                        if key in legacy:
                            legacy_lists[key] = validate_string_list(
                                legacy[key], f"{owner}.logic.legacy.{key}", errors, allow_empty=False
                            )
                    required_flags = set(legacy_lists.get("requires_flags", []))
                    forbidden_flags = set(legacy_lists.get("forbids_flags", []))
                    if required_flags & forbidden_flags:
                        errors.append(f"{owner}.logic.legacy: required and forbidden flags overlap")
                    if "produces_all" in legacy_lists:
                        if not choices:
                            errors.append(f"{owner}.logic.legacy.produces_all: event has no choices")
                        for flag in legacy_lists["produces_all"]:
                            missing = [
                                str(index)
                                for index, choice in enumerate(choices)
                                if flag not in choice_flags(choice)
                            ]
                            if missing:
                                errors.append(
                                    f"{owner}: flag {flag} is not produced by choices {', '.join(missing)}"
                                )
                    if "produces_any" in legacy_lists:
                        all_flags = set().union(*(choice_flags(choice) for choice in choices)) if choices else set()
                        for flag in legacy_lists["produces_any"]:
                            if flag not in all_flags:
                                errors.append(f"{owner}: flag {flag} is not produced by any choice")

                core_loop_v2 = logic.get("core_loop_v2")
                if core_loop_v2 is not None:
                    if not isinstance(core_loop_v2, dict):
                        errors.append(f"{owner}.logic.core_loop_v2: must be an object")
                    else:
                        unknown_core_loop_v2 = set(core_loop_v2) - CORE_LOOP_V2_KEYS
                        if unknown_core_loop_v2:
                            errors.append(
                                f"{owner}.logic.core_loop_v2: unknown keys "
                                f"{sorted(unknown_core_loop_v2)}"
                            )
                        core_loop_v2_lists: dict[str, list[str]] = {}
                        for key in CORE_LOOP_V2_KEYS:
                            if key in core_loop_v2:
                                core_loop_v2_lists[key] = validate_string_list(
                                    core_loop_v2[key],
                                    f"{owner}.logic.core_loop_v2.{key}",
                                    errors,
                                    allow_empty=(
                                        key == "produces_all"
                                        and event_id
                                        == "v2_opening_application_send"
                                    ),
                                )
                        required_flags = set(
                            core_loop_v2_lists.get("requires_flags", [])
                        )
                        forbidden_flags = set(
                            core_loop_v2_lists.get("forbids_flags", [])
                        )
                        if required_flags & forbidden_flags:
                            errors.append(
                                f"{owner}.logic.core_loop_v2: required and forbidden "
                                "flags overlap"
                            )
                        if "produces_all" in core_loop_v2_lists:
                            if not choices:
                                errors.append(
                                    f"{owner}.logic.core_loop_v2.produces_all: "
                                    "event has no choices"
                                )
                            for flag in core_loop_v2_lists["produces_all"]:
                                missing = [
                                    str(index)
                                    for index, choice in enumerate(choices)
                                    if flag not in choice_flags(choice)
                                ]
                                if missing:
                                    errors.append(
                                        f"{owner}: flag {flag} is not produced by "
                                        f"choices {', '.join(missing)}"
                                    )
                        if "produces_any" in core_loop_v2_lists:
                            all_flags = set().union(
                                *(choice_flags(choice) for choice in choices)
                            ) if choices else set()
                            for flag in core_loop_v2_lists["produces_any"]:
                                if flag not in all_flags:
                                    errors.append(
                                        f"{owner}: flag {flag} is not produced by any choice"
                                    )

        presentation = rule.get("presentation")
        if presentation is not None:
            if not isinstance(presentation, dict):
                errors.append(f"{owner}.presentation: must be an object")
            else:
                unknown_presentation = set(presentation) - PRESENTATION_KEYS
                if unknown_presentation:
                    errors.append(
                        f"{owner}.presentation: unknown keys {sorted(unknown_presentation)}"
                    )
                channel = str(presentation.get("channel", ""))
                portrait_role = str(presentation.get("portrait_role", ""))
                nameplate_role = str(presentation.get("nameplate_role", "auto"))
                state = str(presentation.get("state", ""))
                expected_portrait = str(presentation.get("expected_portrait", ""))
                expected_background = str(
                    presentation.get("expected_background", "")
                )
                expected_ambience = str(
                    presentation.get("expected_ambience", "")
                )
                scene_location = str(presentation.get("scene_location", ""))
                if channel not in ALLOWED_CHANNELS:
                    errors.append(f"{owner}.presentation: invalid channel {channel!r}")
                if portrait_role not in ALLOWED_PORTRAIT_ROLES:
                    errors.append(f"{owner}.presentation: invalid portrait_role {portrait_role!r}")
                if nameplate_role not in ALLOWED_NAMEPLATE_ROLES:
                    errors.append(
                        f"{owner}.presentation: invalid nameplate_role {nameplate_role!r}"
                    )
                if state not in ALLOWED_STATES:
                    errors.append(f"{owner}.presentation: invalid state {state!r}")
                if expected_portrait and str(event.get("portrait", "")) != expected_portrait:
                    errors.append(
                        f"{owner}.presentation: portrait {event.get('portrait', '')!r} "
                        f"!= expected {expected_portrait!r}"
                    )
                visual_contract = visual_contracts.get(str(event_id))
                if scene_location in DYNAMIC_SCENE_LOCATIONS:
                    dynamic_location_contracts += 1
                    if str(event.get("background", "")) != scene_location:
                        errors.append(
                            f"{owner}.presentation: dynamic scene {scene_location!r} "
                            f"uses fixed event background "
                            f"{event.get('background', '')!r}"
                        )
                    if (
                        visual_contract is not None
                        and str(visual_contract.get("background", "")) != scene_location
                    ):
                        errors.append(
                            f"{owner}.presentation: dynamic scene {scene_location!r} "
                            f"uses fixed visual background "
                            f"{visual_contract.get('background', '')!r}"
                        )
                if expected_background:
                    if str(event.get("background", "")) != expected_background:
                        errors.append(
                            f"{owner}.presentation: background "
                            f"{event.get('background', '')!r} != expected "
                            f"{expected_background!r}"
                        )
                    if visual_contract is None:
                        errors.append(
                            f"{owner}.presentation: expected_background needs a visual contract"
                        )
                    elif str(visual_contract.get("background", "")) != expected_background:
                        errors.append(
                            f"{owner}.presentation: visual contract background "
                            f"{visual_contract.get('background', '')!r} != expected "
                            f"{expected_background!r}"
                        )
                if expected_portrait and visual_contract is not None:
                    if str(visual_contract.get("portrait", "")) != expected_portrait:
                        errors.append(
                            f"{owner}.presentation: visual contract portrait "
                            f"{visual_contract.get('portrait', '')!r} != expected "
                            f"{expected_portrait!r}"
                        )
                if expected_ambience:
                    audio_contract = audio_events.get(str(event_id), {})
                    if not isinstance(audio_contract, dict):
                        audio_contract = {}
                    if str(audio_contract.get("ambience", "")) != expected_ambience:
                        errors.append(
                            f"{owner}.presentation: audio ambience "
                            f"{audio_contract.get('ambience', '')!r} != expected "
                            f"{expected_ambience!r}"
                        )

                participants = presentation.get("participants", [])
                participant_roles = presentation.get("participant_roles")
                if participant_roles is not None:
                    if not isinstance(participant_roles, dict):
                        errors.append(
                            f"{owner}.presentation.participant_roles: must be an object"
                        )
                    else:
                        participant_ids = {
                            str(participant)
                            for participant in participants
                        } if isinstance(participants, list) else set()
                        role_ids = {str(participant) for participant in participant_roles}
                        if role_ids != participant_ids:
                            errors.append(
                                f"{owner}.presentation.participant_roles: keys "
                                f"{sorted(role_ids)} != participants "
                                f"{sorted(participant_ids)}"
                            )
                        for participant, role in participant_roles.items():
                            if str(role) not in role_types:
                                errors.append(
                                    f"{owner}.presentation.participant_roles."
                                    f"{participant}: unknown role {role!r}"
                                )
                if channel in REMOTE_CHANNELS:
                    remote_contracts += 1
                    for key in ("scene_location", "remote_location", "remote_actor"):
                        if not str(presentation.get(key, "")):
                            errors.append(f"{owner}.presentation: remote channel needs {key}")
                    if presentation.get("scene_location") == presentation.get("remote_location"):
                        errors.append(f"{owner}.presentation: local and remote locations are identical")
                    if portrait_role == "remote":
                        actor = portrait_actor(str(event.get("portrait", "")))
                        expected_actor = str(presentation.get("remote_actor", ""))
                        if not actor:
                            errors.append(f"{owner}.presentation: remote portrait has no recognized actor")
                        elif actor != expected_actor:
                            errors.append(
                                f"{owner}.presentation: portrait actor {actor} != remote actor {expected_actor}"
                            )
                elif channel == "in_person":
                    participants = presentation.get("participants", [])
                    if not isinstance(participants, list) or len(participants) < 2:
                        errors.append(f"{owner}.presentation: in_person needs at least two participants")
                    if "remote_actor" in presentation or "remote_location" in presentation:
                        errors.append(f"{owner}.presentation: in_person cannot declare a remote actor")
                elif channel == "internal":
                    participants = presentation.get("participants", [])
                    if not isinstance(participants, list) or len(participants) != 1:
                        errors.append(f"{owner}.presentation: internal needs exactly one participant")
                    if portrait_role != "local":
                        errors.append(f"{owner}.presentation: internal portrait must be local")
                    if "remote_actor" in presentation or "remote_location" in presentation:
                        errors.append(f"{owner}.presentation: internal cannot declare a remote actor")
                elif channel == "narration" and portrait_role != "none":
                    errors.append(f"{owner}.presentation: narration must use portrait_role none")

        speech = rule.get("speech")
        if speech is not None:
            speech_contracts += 1
            (
                reference_count,
                producerless,
                common_references,
                unreachable,
                choice_scoped,
            ) = (
                validate_speech_contract(
                    str(event_id),
                    speech,
                    presentation,
                    events,
                    demo_event_weeks,
                    errors,
                )
            )
            speaker_references += reference_count
            speech_producerless += producerless
            speech_common_references += common_references
            speech_unreachable += unreachable
            speech_choice_scoped += choice_scoped

        choices = event.get("choices", [])
        if isinstance(choices, list):
            for choice_index, choice in enumerate(choices):
                flags = choice_flags(choice)
                for group_id, group_flags in normalized_groups.items():
                    overlap = flags & group_flags
                    if len(overlap) > 1:
                        errors.append(
                            f"{event_id}.choices[{choice_index}] sets mutually exclusive "
                            f"{group_id} flags {sorted(overlap)}"
                        )

    coverage = ledger.get("coverage_targets", {})
    if not isinstance(coverage, dict):
        errors.append("coverage_targets must be an object")
        coverage = {}
    minimum = int(coverage.get("minimum_ledger_events", 0))
    if len(rules) < minimum:
        errors.append(f"ledger event count regressed: {len(rules)} < {minimum}")
    for target_name in ("demo_logic", "communication"):
        target_ids = validate_string_list(
            coverage.get(target_name, []), f"coverage_targets.{target_name}", errors, allow_empty=False
        )
        for event_id in target_ids:
            rule = rules.get(event_id, {})
            if not isinstance(rule, dict):
                errors.append(f"coverage target {target_name}: missing rule for {event_id}")
                continue
            required_key = "logic" if target_name == "demo_logic" else "presentation"
            if required_key not in rule:
                errors.append(f"coverage target {target_name}: {event_id} lacks {required_key}")
            if target_name == "communication":
                channel = str(rule.get("presentation", {}).get("channel", ""))
                if channel not in REMOTE_CHANNELS:
                    errors.append(f"coverage target communication: {event_id} is not remote/media framed")

    transition_contracts = ledger.get("transition_contracts", {})
    if not isinstance(transition_contracts, dict):
        errors.append("transition_contracts must be an object")
        transition_contracts = {}
    demo_transition_edges = validate_string_list(
        coverage.get("demo_transition_edges", []),
        "coverage_targets.demo_transition_edges",
        errors,
        allow_empty=False,
    )
    missing_transition_contracts = [
        edge for edge in demo_transition_edges if edge not in transition_contracts
    ]
    for edge in missing_transition_contracts:
        errors.append(f"demo transition lacks contract: {edge}")
    chapter5_queue_edges = chapter5_queue_only_edges()

    validated_transition_contracts = 0
    for edge, contract in transition_contracts.items():
        owner = f"transition_contracts.{edge}"
        if not isinstance(contract, dict):
            errors.append(f"{owner}: must be an object")
            continue
        unknown = set(contract) - TRANSITION_KEYS
        if unknown:
            errors.append(f"{owner}: unknown keys {sorted(unknown)}")
        parts = str(edge).split("->")
        if len(parts) != 2 or not all(parts):
            errors.append(f"{owner}: edge must use from_event->to_event")
            continue
        from_id, to_id = parts
        if from_id not in events or to_id not in events:
            errors.append(f"{owner}: references a missing event")
            continue
        queue_only = contract.get("queue_only", False)
        if not isinstance(queue_only, bool):
            errors.append(f"{owner}: queue_only must be a boolean")
            queue_only = False
        legacy_only = contract.get("legacy_only", False)
        if not isinstance(legacy_only, bool):
            errors.append(f"{owner}: legacy_only must be a boolean")
            legacy_only = False
        if legacy_only and not queue_only:
            errors.append(f"{owner}: legacy_only transitions must be queue_only")
        if queue_only and edge not in demo_transition_edges \
                and edge not in chapter5_queue_edges:
            errors.append(
                f"{owner}: queue_only edge lacks demo or exact Chapter 5 ledger ownership"
            )

        choices = events[from_id].get("choices", [])
        follows = {
            str(choice.get("follow_up_event", ""))
            for choice in choices
            if isinstance(choice, dict)
        } if isinstance(choices, list) else set()
        if not queue_only and to_id not in follows:
            errors.append(f"{owner}: {from_id} does not follow to {to_id}")
        if queue_only and to_id in follows:
            errors.append(f"{owner}: queue_only target is already an authored follow-up")

        mode = str(contract.get("mode", ""))
        from_location = str(contract.get("from_location", ""))
        to_location = str(contract.get("to_location", ""))
        if mode not in ALLOWED_TRANSITION_MODES:
            errors.append(f"{owner}: invalid mode {mode!r}")
        if not from_location or not to_location:
            errors.append(f"{owner}: from_location and to_location are required")
        actual_from = event_location(from_id, events, rules)
        actual_to = event_location(to_id, events, rules)
        if actual_from != from_location:
            errors.append(f"{owner}: source location {actual_from!r} != {from_location!r}")
        if actual_to != to_location:
            errors.append(f"{owner}: destination location {actual_to!r} != {to_location!r}")
        if mode == "same_location":
            if from_location != to_location:
                errors.append(f"{owner}: same_location endpoints differ")
        else:
            # A time cut may return to the same physical room. The localized
            # arrival cue below is then the machine-readable time-frame change.
            if from_location == to_location and mode != "time_cut":
                errors.append(f"{owner}: {mode} must change location or time frame")
            cue_ko = str(contract.get("arrival_cue_ko", ""))
            cue_en = str(contract.get("arrival_cue_en", ""))
            if not cue_ko or cue_ko not in str(events[to_id].get("description", "")):
                errors.append(f"{owner}: Korean arrival cue is missing from {to_id}")
            if not cue_en or cue_en not in str(events_en.get(to_id, {}).get("description", "")):
                errors.append(f"{owner}: English arrival cue is missing from {to_id}")
        validated_transition_contracts += 1

    unclassified_suspects: list[str] = []
    for event_id, event in events.items():
        portrait = str(event.get("portrait", ""))
        actor = portrait_actor(portrait)
        if actor in {"", "player"} or not COMMUNICATION_TITLE.search(str(event.get("title", ""))):
            continue
        presentation = rules.get(event_id, {}).get("presentation", {})
        if not isinstance(presentation, dict) or not str(presentation.get("channel", "")):
            unclassified_suspects.append(event_id)
    suspect_ceiling = int(coverage.get("max_unclassified_communication_suspects", 999999))
    if len(unclassified_suspects) > suspect_ceiling:
        errors.append(
            "unclassified communication portrait debt grew: "
            f"{len(unclassified_suspects)} > {suspect_ceiling} ({', '.join(unclassified_suspects)})"
        )

    if errors:
        print(f"STORY_CONSISTENCY_AUDIT_FAIL errors={len(errors)}")
        for message in errors:
            print(f"  ERROR {message}")
        return 1

    ledger_percent = (100.0 * len(rules) / len(events)) if events else 0.0
    print(
        "STORY_CONSISTENCY_AUDIT_OK "
        f"events={len(events)} ledger={len(rules)} ({ledger_percent:.1f}%) "
        f"logic={logic_contracts} remote={remote_contracts} "
        f"speech={speech_contracts} speaker_references={speaker_references} "
        f"choice_scoped_speakers={speech_choice_scoped} "
        f"producerless={speech_producerless} "
        f"common_references={speech_common_references} "
        f"unreachable={speech_unreachable} "
        f"dynamic_locations={dynamic_location_contracts} "
        f"transitions={validated_transition_contracts} unauthorized_demo_jumps=0 "
        f"exclusive_groups={len(normalized_groups)} unclassified={len(unclassified_suspects)}"
    )
    if unclassified_suspects:
        print("  UNCLASSIFIED_COMMUNICATION " + ", ".join(unclassified_suspects))
    return 0


if __name__ == "__main__":
    sys.exit(main())
