#!/usr/bin/env python3
"""Validate the hidden random-event director against the live event catalog."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
REGISTRY = ROOT / "autoloads" / "DataRegistry.gd"
MANIFEST = ROOT / "content" / "meta" / "event_director.json"
EXPECTED_CATALOG_RANDOM = 1177
EXPECTED_DIRECTED_RANDOM = 1032
EXPECTED_REPEATABLE = {
    "convenience_store_meal",
    "delivery_app_temptation",
    "health_insomnia",
}


def fail(message: str) -> None:
    print(f"ERROR event director: {message}")


def load_registered_events() -> list[dict[str, Any]]:
    source = REGISTRY.read_text(encoding="utf-8")
    try:
        block = source.split("const EVENT_PATHS = [", 1)[1].split("]", 1)[0]
    except IndexError as exc:
        raise RuntimeError("DataRegistry EVENT_PATHS could not be parsed") from exc
    paths = re.findall(r'"res://([^\"]+\.json)"', block)
    events: list[dict[str, Any]] = []
    for relative in paths:
        raw = json.loads((ROOT / relative).read_text(encoding="utf-8"))
        if not isinstance(raw, list):
            raise RuntimeError(f"registered event file is not an array: {relative}")
        for event in raw:
            if not isinstance(event, dict) or not str(event.get("id", "")):
                raise RuntimeError(f"invalid event row in {relative}")
            events.append(event)
    return events


def is_catalog_random(event: dict[str, Any]) -> bool:
    conditions = event.get("conditions", {})
    min_turn = int(conditions.get("min_turn", 1)) if isinstance(conditions, dict) else 1
    return not (
        float(event.get("weight", 1.0)) <= 0.0
        or min_turn >= 9999
        or str(event.get("rarity", "")) == "story"
    )


def follow_up_targets(events: list[dict[str, Any]]) -> set[str]:
    targets: set[str] = set()
    for event in events:
        direct = str(event.get("follow_up_event", ""))
        if direct:
            targets.add(direct)
        for choice in event.get("choices", []):
            if not isinstance(choice, dict):
                continue
            for key in ("follow_up_event", "deferred_follow_up"):
                target = str(choice.get(key, ""))
                if target:
                    targets.add(target)
    return targets


def is_directed_random(
    event: dict[str, Any], manifest: dict[str, Any], direct_targets: set[str]
) -> bool:
    event_id = str(event.get("id", ""))
    scope = manifest.get("scope", {})
    prefixes = tuple(str(value) for value in scope.get("excluded_id_prefixes", []))
    return (
        str(event.get("category", "")) != "story"
        and str(event.get("rarity", "")) != "story"
        and float(event.get("weight", 1.0)) > 0.0
        and not event_id.startswith(prefixes)
        and not (scope.get("exclude_follow_up_targets", True) and event_id in direct_targets)
    )


def validate_multiplier_map(value: Any, owner: str, errors: list[str]) -> None:
    if not isinstance(value, dict):
        errors.append(f"{owner} category_multipliers must be an object")
        return
    for category, multiplier in value.items():
        if not isinstance(category, str) or not category:
            errors.append(f"{owner} has an empty category key")
        if not isinstance(multiplier, (int, float)) or not 0.25 <= float(multiplier) <= 2.0:
            errors.append(f"{owner}.{category} multiplier outside 0.25..2.0")


def validate_manifest(manifest: dict[str, Any], events: list[dict[str, Any]]) -> list[str]:
    errors: list[str] = []
    by_id = {str(event["id"]): event for event in events}
    direct_targets = follow_up_targets(events)

    if manifest.get("schema") != 1:
        errors.append("schema must be 1")
    default = manifest.get("default_policy", {})
    if not isinstance(default, dict) or default.get("once_per_run") is not True:
        errors.append("default policy must be once_per_run=true")
    if int(default.get("max_per_run", 0)) != 1:
        errors.append("default max_per_run must be 1")
    if int(default.get("cooldown", 0)) < 3:
        errors.append("default cooldown must be at least 3")
    if float(default.get("repeat_decay", 0.0)) != 1.0:
        errors.append("default repeat decay must be 1.0")

    recent = manifest.get("recent_action", {})
    if not isinstance(recent, dict):
        errors.append("recent_action must be an object")
    else:
        if abs(float(recent.get("max_multiplier", 0.0)) - 2.6) > 0.0001:
            errors.append("latest action echo must remain 2.6x")
        if abs(float(recent.get("prior_week_strength", 0.0)) - 0.55) > 0.0001:
            errors.append("prior-week action strength must remain 0.55")
        if abs(float(recent.get("prior_week_multiplier", 0.0)) - 1.88) > 0.0001:
            errors.append("prior-week action echo must remain 1.88x")

    scope = manifest.get("scope", {})
    if scope.get("excluded_id_prefixes") != ["arc_"]:
        errors.append("scope must exclude scheduled arc_ ids")
    if scope.get("exclude_follow_up_targets") is not True:
        errors.append("scope must exclude direct follow-up and deferred targets")

    chapters = manifest.get("chapter_windows", [])
    if not isinstance(chapters, list) or len(chapters) != 5:
        errors.append("chapter_windows must contain five rows")
    else:
        expected_start = 1
        for index, row in enumerate(chapters):
            if not isinstance(row, dict):
                errors.append(f"chapter row {index} is not an object")
                continue
            start = int(row.get("min_turn", -1))
            end = int(row.get("max_turn", -1))
            if start != expected_start or end < start:
                errors.append(f"chapter {row.get('id', index)} is not contiguous at turn {expected_start}")
            expected_start = end + 1
            validate_multiplier_map(row.get("category_multipliers"), f"chapter.{row.get('id', index)}", errors)
        if expected_start != 241:
            errors.append("chapter windows must cover turns 1..240 exactly")

    bands = manifest.get("asset_bands", [])
    if not isinstance(bands, list) or len(bands) != 5:
        errors.append("asset_bands must contain five rows")
    else:
        previous_max: float | None = None
        for index, row in enumerate(bands):
            if not isinstance(row, dict):
                errors.append(f"asset band {index} is not an object")
                continue
            minimum = float(row["min_assets"]) if "min_assets" in row else None
            maximum = float(row["max_assets"]) if "max_assets" in row else None
            if index == 0 and minimum is not None:
                errors.append("first asset band must be open below")
            if index > 0 and minimum != previous_max:
                errors.append(f"asset band {row.get('id', index)} does not meet previous ceiling")
            if maximum is not None and minimum is not None and maximum <= minimum:
                errors.append(f"asset band {row.get('id', index)} has an invalid range")
            if index < len(bands) - 1 and maximum is None:
                errors.append(f"asset band {row.get('id', index)} needs a ceiling")
            if index == len(bands) - 1 and maximum is not None:
                errors.append("last asset band must be open above")
            previous_max = maximum
            validate_multiplier_map(row.get("category_multipliers"), f"assets.{row.get('id', index)}", errors)

    employment = manifest.get("employment", {})
    if not isinstance(employment, dict):
        errors.append("employment must be an object")
    else:
        for state in ("unemployed", "employed"):
            row = employment.get(state, {})
            if not isinstance(row, dict):
                errors.append(f"employment.{state} must be an object")
            else:
                validate_multiplier_map(row.get("category_multipliers"), f"employment.{state}", errors)
        for key in ("requires_job_tags", "requires_no_job_tags"):
            if not isinstance(employment.get(key), list):
                errors.append(f"employment.{key} must be an array")

    relationships = manifest.get("relationships", {})
    if not isinstance(relationships, dict):
        errors.append("relationships must be an object")
    else:
        named = relationships.get("named_cast_tags", [])
        if not isinstance(named, list) or not named:
            errors.append("named_cast_tags must be a non-empty array")
        introductions = relationships.get("introduction_events", {})
        if not isinstance(introductions, dict):
            errors.append("introduction_events must be an object")
        else:
            for person_id, event_ids in introductions.items():
                if person_id not in named:
                    errors.append(f"introduction owner {person_id} is not a named cast tag")
                for event_id in event_ids:
                    if event_id not in by_id or not is_directed_random(by_id[event_id], manifest, direct_targets):
                        errors.append(f"cast introduction is not in the directed pool: {event_id}")
                    elif person_id not in by_id[event_id].get("tags", []):
                        errors.append(f"cast introduction {event_id} lacks tag {person_id}")

    repeatable = manifest.get("repeatable_events", {})
    if not isinstance(repeatable, dict) or set(repeatable) != EXPECTED_REPEATABLE:
        errors.append("repeatable_events must contain only the three approved everyday events")
    else:
        for event_id, policy in repeatable.items():
            if event_id not in by_id or not is_directed_random(by_id[event_id], manifest, direct_targets):
                errors.append(f"repeatable event is not in the directed pool: {event_id}")
                continue
            if int(policy.get("max_per_run", 0)) != 2:
                errors.append(f"{event_id} max_per_run must be 2")
            if int(policy.get("cooldown", 0)) < 24:
                errors.append(f"{event_id} cooldown must be at least 24 weeks")
            if abs(float(policy.get("repeat_decay", 0.0)) - 0.35) > 0.0001:
                errors.append(f"{event_id} repeat_decay must be 0.35")
    context = manifest.get("context_requirements", {})
    expected_context = {
        "delivery_app_temptation": {"has_job": True},
        "romance_034": {"has_job": True},
        "romance_045": {"active_romance": True},
        "health_back_pain": {"housing_in": ["gosiwon"]},
        "rare_goshiwon_neighbor_success": {"housing_in": ["gosiwon"]},
    }
    if context != expected_context:
        errors.append("explicit job, romance, and goshiwon contradiction gates drifted")
    return errors


def main() -> int:
    try:
        manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
        events = load_registered_events()
    except (OSError, ValueError, RuntimeError) as exc:
        fail(str(exc))
        return 1
    if not isinstance(manifest, dict):
        fail("manifest root must be an object")
        return 1

    errors = validate_manifest(manifest, events)
    catalog_random = [event for event in events if is_catalog_random(event)]
    direct_targets = follow_up_targets(events)
    directed_random = [
        event for event in events if is_directed_random(event, manifest, direct_targets)
    ]
    if len(events) != 1519:
        errors.append(f"registered event count drifted: expected 1519, got {len(events)}")
    if len(catalog_random) != EXPECTED_CATALOG_RANDOM:
        errors.append(
            f"catalog random count drifted: expected {EXPECTED_CATALOG_RANDOM}, got {len(catalog_random)}"
        )
    if len(directed_random) != EXPECTED_DIRECTED_RANDOM:
        errors.append(
            f"runtime directed count drifted: expected {EXPECTED_DIRECTED_RANDOM}, got {len(directed_random)}"
        )

    if errors:
        for message in errors:
            fail(message)
        return 1
    print(
        "EVENT_DIRECTOR_AUDIT_OK "
        f"events={len(events)} catalog_random={len(catalog_random)} "
        f"directed_random={len(directed_random)} once={len(directed_random) - len(EXPECTED_REPEATABLE)} "
        f"repeatable={len(EXPECTED_REPEATABLE)} chapters=5 asset_bands=5"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
