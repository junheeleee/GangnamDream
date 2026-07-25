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
ALLOWED_PORTRAIT_ROLES = {"present", "remote", "local", "none"}
ALLOWED_STATES = {"", "connected", "incoming", "dialing", "missed", "received"}
LOGIC_KEYS = {
    "requires",
    "forbids",
    "produces",
    "choice_produces",
    "legacy",
    "prerequisites",
}
LEGACY_KEYS = {"requires_flags", "forbids_flags", "produces_all", "produces_any"}
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
    "expected_portrait",
    "participant_roles",
    "expected_background",
    "expected_ambience",
}
COMMUNICATION_TITLE = re.compile(r"전화|통화|카톡|문자|연락", re.IGNORECASE)
ALLOWED_TRANSITION_MODES = {"same_location", "explicit_move", "time_cut", "memory_cut"}
TRANSITION_KEYS = {
    "mode",
    "from_location",
    "to_location",
    "arrival_cue_ko",
    "arrival_cue_en",
}


def load_json(path: Path) -> Any:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise RuntimeError(f"cannot load {path.relative_to(ROOT)}: {exc}") from exc


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
    if path == "player.job.id":
        raw_values = value if isinstance(value, list) else [value]
        unknown_jobs = sorted(
            str(job_id)
            for job_id in raw_values
            if str(job_id) and str(job_id) not in job_ids
        )
        if unknown_jobs:
            errors.append(f"{owner}: unknown job ids {unknown_jobs}")


def main() -> int:
    errors: list[str] = []
    events, event_errors = load_events()
    errors.extend(event_errors)
    ledger = load_json(RULES_PATH)
    if not isinstance(ledger, dict):
        print("STORY_CONSISTENCY_AUDIT_FAIL ledger root must be an object")
        return 1
    if int(ledger.get("schema_version", 0)) != 2:
        errors.append("schema_version must be 2")

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
    for event_id, rule in rules.items():
        owner = f"events.{event_id}"
        event = events.get(str(event_id))
        if event is None:
            errors.append(f"{owner}: references missing event")
            continue
        if not isinstance(rule, dict):
            errors.append(f"{owner}: rule must be an object")
            continue
        unknown_rule_keys = set(rule) - {"logic", "presentation"}
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
                state = str(presentation.get("state", ""))
                expected_portrait = str(presentation.get("expected_portrait", ""))
                expected_background = str(
                    presentation.get("expected_background", "")
                )
                expected_ambience = str(
                    presentation.get("expected_ambience", "")
                )
                if channel not in ALLOWED_CHANNELS:
                    errors.append(f"{owner}.presentation: invalid channel {channel!r}")
                if portrait_role not in ALLOWED_PORTRAIT_ROLES:
                    errors.append(f"{owner}.presentation: invalid portrait_role {portrait_role!r}")
                if state not in ALLOWED_STATES:
                    errors.append(f"{owner}.presentation: invalid state {state!r}")
                if expected_portrait and str(event.get("portrait", "")) != expected_portrait:
                    errors.append(
                        f"{owner}.presentation: portrait {event.get('portrait', '')!r} "
                        f"!= expected {expected_portrait!r}"
                    )
                visual_contract = visual_contracts.get(str(event_id))
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
        choices = events[from_id].get("choices", [])
        follows = {
            str(choice.get("follow_up_event", ""))
            for choice in choices
            if isinstance(choice, dict)
        } if isinstance(choices, list) else set()
        if to_id not in follows:
            errors.append(f"{owner}: {from_id} does not follow to {to_id}")

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
        f"transitions={validated_transition_contracts} unauthorized_demo_jumps=0 "
        f"exclusive_groups={len(normalized_groups)} unclassified={len(unclassified_suspects)}"
    )
    if unclassified_suspects:
        print("  UNCLASSIFIED_COMMUNICATION " + ", ".join(unclassified_suspects))
    return 0


if __name__ == "__main__":
    sys.exit(main())
