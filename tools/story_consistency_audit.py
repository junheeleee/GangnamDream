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
RULES_PATH = ROOT / "content" / "meta" / "story_rules.json"

ALLOWED_CHANNELS = {
    "in_person",
    "phone",
    "video_call",
    "message",
    "memory",
    "narration",
}
REMOTE_CHANNELS = {"phone", "video_call", "message", "memory"}
ALLOWED_PORTRAIT_ROLES = {"present", "remote", "local", "none"}
ALLOWED_STATES = {"", "connected", "incoming", "dialing", "missed", "received"}
LOGIC_KEYS = {"requires", "forbids", "produces", "choice_produces", "legacy"}
LEGACY_KEYS = {"requires_flags", "forbids_flags", "produces_all", "produces_any"}
PRESENTATION_KEYS = {
    "channel",
    "state",
    "scene_location",
    "remote_location",
    "remote_actor",
    "participants",
    "portrait_role",
    "expected_portrait",
}
COMMUNICATION_TITLE = re.compile(r"전화|통화|카톡|문자|연락", re.IGNORECASE)


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


def main() -> int:
    errors: list[str] = []
    events, event_errors = load_events()
    errors.extend(event_errors)
    ledger = load_json(RULES_PATH)
    if not isinstance(ledger, dict):
        print("STORY_CONSISTENCY_AUDIT_FAIL ledger root must be an object")
        return 1
    if int(ledger.get("schema_version", 0)) != 1:
        errors.append("schema_version must be 1")

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
        f"exclusive_groups={len(normalized_groups)} unclassified={len(unclassified_suspects)}"
    )
    if unclassified_suspects:
        print("  UNCLASSIFIED_COMMUNICATION " + ", ".join(unclassified_suspects))
    return 0


if __name__ == "__main__":
    sys.exit(main())
