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
EXPECTED_CATALOG_RANDOM = 1176
EXPECTED_DIRECTED_RANDOM = 1032
EXPECTED_FOREGROUND_RANDOM = 61
EXPECTED_BRIDGE_RANDOM = 18
EXPECTED_IMPLICIT_BRIDGE_ROOTS = {
    "amb_idea_stolen_00",
    "anxiety_child_cost_calc",
    "anxiety_pension_crisis",
    "butterfly_mystery_info_result_scam",
    "butterfly_resume_lie_caught",
    "callback_jaehyuk_reported_witness",
    "callback_lied_interview_surfaces",
}
EXPECTED_CONTENT_DIET = {
    "foreground_min_description_chars": 160,
    "foreground_min_result_chars": 80,
    "material_money_abs": 50000,
    "material_tint_abs": 4,
    "material_stat_abs": 7,
    "material_stats": [
        "mental",
        "health",
        "reputation",
        "social_skill",
        "intelligence",
        "investment_skill",
        "luck",
        "appearance",
    ],
    "excluded_categories": ["comedy"],
    "excluded_id_prefixes": ["korea_"],
    "bridge_min_turn": 25,
    "bridge_single_choice_only": True,
    "bridge_requires_stateful_condition": True,
    "foreground_include_bridge_producers": True,
    "implicit_bridge_root_excluded_tags": ["korea"],
    "foreground_requires_causal_context": True,
}
EXPECTED_REPEATABLE = {
    "convenience_store_meal",
    "delivery_app_temptation",
    "health_insomnia",
}
EXPECTED_DEMO_DECISIONS = [1, 4, 8, 10, 13, 16, 20, 23, 24]
EXPECTED_DEMO_BOSSES = [4, 24]
EXPECTED_DEMO_ECHOES = [6, 9, 17, 21]
EXPECTED_DEMO_SUMMARIES = [4, 12, 24]
EXPECTED_FULL_DECISIONS = [
    29, 35, 37, 45,
    49, 53, 57, 61, 67, 85, 92, 94, 96,
    97, 99, 107, 111, 114, 123, 131, 135, 139, 140,
    145, 149, 153, 157, 161, 169, 176, 181, 185, 188,
    193, 197, 201, 205, 209, 213, 217, 225, 229, 237,
]
EXPECTED_FULL_BOSSES = [45, 92, 140, 176, 237]
EXPECTED_FULL_ECHOES = [
    33, 51, 63, 75, 86, 98, 109, 121, 136,
    151, 159, 171, 184, 199, 207, 219, 231,
]
EXPECTED_FULL_SUMMARIES = [
    36, 48, 60, 72, 84, 96, 108, 120, 132,
    144, 156, 168, 180, 192, 204, 216, 228, 240,
]


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


def event_has_follow_up(event: dict[str, Any]) -> bool:
    if str(event.get("follow_up_event", "")):
        return True
    return any(
        str(choice.get("follow_up_event", ""))
        or str(choice.get("deferred_follow_up", ""))
        for choice in event.get("choices", [])
        if isinstance(choice, dict)
    )


def event_has_stateful_condition(event: dict[str, Any]) -> bool:
    conditions = event.get("conditions", {})
    return isinstance(conditions, dict) and any(
        str(key) not in {"min_turn", "max_turn"} for key in conditions
    )


def event_produced_flags(event: dict[str, Any]) -> set[str]:
    return {
        str(flag)
        for choice in event.get("choices", [])
        if isinstance(choice, dict)
        for flag in choice.get("flags", [])
        if str(flag)
    }


def bridge_condition_flags(event: dict[str, Any]) -> set[str]:
    conditions = event.get("conditions", {})
    if not isinstance(conditions, dict):
        return set()
    result: set[str] = set()
    if str(conditions.get("flag", "")):
        result.add(str(conditions["flag"]))
    for key in ("flags_all", "flags_any"):
        result.update(str(flag) for flag in conditions.get(key, []) if str(flag))
    return result


def choice_material_signature(choice: dict[str, Any]) -> str:
    payload = {
        "effects": choice.get("effects", {}),
        "flags": choice.get("flags", []),
        "follow_up_event": choice.get("follow_up_event", ""),
        "deferred_follow_up": choice.get("deferred_follow_up", ""),
        "route": choice.get("route", ""),
        "tendency": choice.get("tendency", {}),
        "give_items": choice.get("give_items", []),
        "clues": choice.get("clues", []),
        "relationship_effects": choice.get("relationship_effects", []),
        "investment_effects": choice.get("investment_effects", []),
    }
    return json.dumps(payload, ensure_ascii=False, sort_keys=True)


def choice_has_material_stake(
    choice: dict[str, Any], rules: dict[str, Any]
) -> bool:
    effects = choice.get("effects", {})
    if not isinstance(effects, dict):
        effects = {}
    if abs(float(effects.get("money", 0.0))) >= float(rules["material_money_abs"]):
        return True
    if abs(float(effects.get("tint", 0.0))) >= float(rules["material_tint_abs"]):
        return True
    threshold = float(rules["material_stat_abs"])
    if any(
        abs(float(effects.get(str(stat), 0.0))) >= threshold
        for stat in rules["material_stats"]
    ):
        return True
    for key in (
        "flags",
        "route",
        "tendency",
        "give_items",
        "clues",
        "relationship_effects",
        "investment_effects",
    ):
        if choice.get(key):
            return True
    return False


def event_has_material_choice_contrast(
    event: dict[str, Any], rules: dict[str, Any]
) -> bool:
    choices = [choice for choice in event.get("choices", []) if isinstance(choice, dict)]
    if len(choices) < 2 or len(choices) != len(event.get("choices", [])):
        return False
    signatures = {choice_material_signature(choice) for choice in choices}
    return len(signatures) >= 2 and any(
        choice_has_material_stake(choice, rules) for choice in choices
    )


def event_passes_content_exclusions(
    event: dict[str, Any], rules: dict[str, Any]
) -> bool:
    if str(event.get("category", "")) in rules["excluded_categories"]:
        return False
    event_id = str(event.get("id", ""))
    return not any(
        event_id.startswith(str(prefix)) for prefix in rules["excluded_id_prefixes"]
    )


def meets_foreground_source_contract(
    event: dict[str, Any], manifest: dict[str, Any], direct_targets: set[str],
    bridge_trigger_flags: set[str],
) -> bool:
    if not is_directed_random(event, manifest, direct_targets):
        return False
    rules = manifest.get("content_diet", {})
    if not isinstance(rules, dict) or not event_passes_content_exclusions(event, rules):
        return False
    if event_has_follow_up(event):
        return True
    if bool(rules.get("foreground_include_bridge_producers", True)):
        excluded_tags = {
            str(tag) for tag in rules.get("implicit_bridge_root_excluded_tags", [])
        }
        event_tags = {str(tag) for tag in event.get("tags", [])}
        if not (event_tags & excluded_tags) \
                and event_produced_flags(event) & bridge_trigger_flags \
                and event_has_material_choice_contrast(event, rules):
            return True
    choices = event.get("choices", [])
    if not isinstance(choices, list) or len(choices) < 2:
        return False
    if len(str(event.get("description", ""))) < int(
        rules["foreground_min_description_chars"]
    ):
        return False
    if any(
        not isinstance(choice, dict)
        or len(str(choice.get("result_text", "")))
        < int(rules["foreground_min_result_chars"])
        for choice in choices
    ):
        return False
    return event_has_material_choice_contrast(event, rules)


def meets_bridge_source_contract(
    event: dict[str, Any], manifest: dict[str, Any], direct_targets: set[str]
) -> bool:
    if not is_directed_random(event, manifest, direct_targets):
        return False
    rules = manifest.get("content_diet", {})
    if not isinstance(rules, dict) or not event_passes_content_exclusions(event, rules):
        return False
    choices = event.get("choices", [])
    if not isinstance(choices, list) or len(choices) != 1:
        return False
    if event_has_follow_up(event) or not event_has_stateful_condition(event):
        return False
    choice = choices[0]
    return isinstance(choice, dict) and bool(str(choice.get("result_text", "")))


def is_foreground_random(
    event: dict[str, Any], manifest: dict[str, Any], direct_targets: set[str]
) -> bool:
    if not is_directed_random(event, manifest, direct_targets):
        return False
    rules = manifest.get("content_diet", {})
    return isinstance(rules, dict) and str(event.get("id", "")) in rules.get(
        "foreground_event_ids", []
    )


def is_bridge_random(
    event: dict[str, Any], manifest: dict[str, Any], direct_targets: set[str]
) -> bool:
    if not is_directed_random(event, manifest, direct_targets):
        return False
    rules = manifest.get("content_diet", {})
    return isinstance(rules, dict) and str(event.get("id", "")) in rules.get(
        "bridge_event_ids", []
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

    content_diet = manifest.get("content_diet", {})
    if not isinstance(content_diet, dict):
        errors.append("content_diet must be an object")
    else:
        for key, expected in EXPECTED_CONTENT_DIET.items():
            if content_diet.get(key) != expected:
                errors.append(f"content_diet.{key} drifted")
        expected_bridge_ids = sorted(
            str(event["id"])
            for event in events
            if meets_bridge_source_contract(event, manifest, direct_targets)
        )
        bridge_trigger_flags = {
            flag
            for event_id in expected_bridge_ids
            for flag in bridge_condition_flags(by_id[event_id])
        }
        expected_foreground_ids = sorted(
            str(event["id"])
            for event in events
            if meets_foreground_source_contract(
                event, manifest, direct_targets, bridge_trigger_flags
            )
        )
        implicit_bridge_roots = {
            str(event["id"])
            for event in events
            if str(event["id"]) in expected_foreground_ids
            and event_produced_flags(event) & bridge_trigger_flags
            and not event_has_follow_up(event)
        }
        if implicit_bridge_roots != EXPECTED_IMPLICIT_BRIDGE_ROOTS:
            errors.append(
                "implicit bridge roots drifted: "
                f"expected {sorted(EXPECTED_IMPLICIT_BRIDGE_ROOTS)}, "
                f"got {sorted(implicit_bridge_roots)}"
            )
        actual_foreground_ids = content_diet.get("foreground_event_ids", [])
        actual_bridge_ids = content_diet.get("bridge_event_ids", [])
        if actual_foreground_ids != expected_foreground_ids:
            errors.append("foreground_event_ids no longer match the KO source quality audit")
        if actual_bridge_ids != expected_bridge_ids:
            errors.append("bridge_event_ids no longer match the safe one-choice audit")

    pacing = manifest.get("demo_pacing", {})
    if not isinstance(pacing, dict):
        errors.append("demo_pacing must be an object")
    else:
        if int(pacing.get("min_turn", 0)) != 1 or int(pacing.get("max_turn", 0)) != 24:
            errors.append("demo_pacing must cover turns 1..24 exactly")
        expected_lists = {
            "decision_weeks": EXPECTED_DEMO_DECISIONS,
            "boss_weeks": EXPECTED_DEMO_BOSSES,
            "echo_weeks": EXPECTED_DEMO_ECHOES,
            "full_summary_weeks": EXPECTED_DEMO_SUMMARIES,
        }
        for key, expected in expected_lists.items():
            actual = pacing.get(key, [])
            if actual != expected:
                errors.append(f"demo_pacing.{key} drifted: expected {expected}, got {actual}")
            if not isinstance(actual, list) or any(
                not isinstance(turn, int) or turn < 1 or turn > 24 for turn in actual
            ):
                errors.append(f"demo_pacing.{key} must contain only turns 1..24")
        decisions = set(pacing.get("decision_weeks", []))
        bosses = set(pacing.get("boss_weeks", []))
        echoes = set(pacing.get("echo_weeks", []))
        if not 8 <= len(decisions) <= 10:
            errors.append("demo pacing must expose 8..10 direct decision weeks")
        if len(bosses) != 2 or not bosses.issubset(decisions):
            errors.append("demo pacing must expose two bosses inside decision weeks")
        if not 3 <= len(echoes) <= 5 or decisions & echoes:
            errors.append("demo pacing must expose 3..5 echoes outside decision weeks")
        if any(turn % 4 != 0 for turn in pacing.get("full_summary_weeks", [])):
            errors.append("full demo summaries must land on month-end turns")

    full_pacing = manifest.get("full_run_pacing", {})
    if not isinstance(full_pacing, dict):
        errors.append("full_run_pacing must be an object")
    else:
        if int(full_pacing.get("min_turn", 0)) != 25 \
                or int(full_pacing.get("max_turn", 0)) != 240:
            errors.append("full_run_pacing must cover turns 25..240 exactly")
        expected_full_lists = {
            "decision_weeks": EXPECTED_FULL_DECISIONS,
            "boss_weeks": EXPECTED_FULL_BOSSES,
            "echo_weeks": EXPECTED_FULL_ECHOES,
            "full_summary_weeks": EXPECTED_FULL_SUMMARIES,
        }
        for key, expected in expected_full_lists.items():
            actual = full_pacing.get(key, [])
            if actual != expected:
                errors.append(f"full_run_pacing.{key} drifted: expected {expected}, got {actual}")
            if not isinstance(actual, list) or any(
                not isinstance(turn, int) or turn < 25 or turn > 240 for turn in actual
            ):
                errors.append(f"full_run_pacing.{key} must contain only turns 25..240")
        full_decisions = set(full_pacing.get("decision_weeks", []))
        full_bosses = set(full_pacing.get("boss_weeks", []))
        full_echoes = set(full_pacing.get("echo_weeks", []))
        if not full_bosses.issubset(full_decisions):
            errors.append("full-run bosses must be direct decision weeks")
        if full_decisions & full_echoes:
            errors.append("full-run echo weeks must not overlap direct decisions")
        if any(turn % 4 != 0 for turn in full_pacing.get("full_summary_weeks", [])):
            errors.append("full-run summaries must land on month-end turns")
        all_decisions = set(EXPECTED_DEMO_DECISIONS) | full_decisions
        chapter_counts = [
            sum((chapter - 1) * 48 < turn <= chapter * 48 for turn in all_decisions)
            for chapter in range(1, 6)
        ]
        if chapter_counts != [13, 9, 10, 10, 10]:
            errors.append(f"chapter direct-decision counts drifted: {chapter_counts}")
        if not 40 <= len(all_decisions) <= 60:
            errors.append(f"full run must expose 40..60 direct weeks, got {len(all_decisions)}")

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
    foreground_random = [
        event for event in events if is_foreground_random(event, manifest, direct_targets)
    ]
    bridge_random = [
        event for event in events if is_bridge_random(event, manifest, direct_targets)
    ]
    if len(events) != 1565:
        errors.append(f"registered event count drifted: expected 1565, got {len(events)}")
    if len(catalog_random) != EXPECTED_CATALOG_RANDOM:
        errors.append(
            f"catalog random count drifted: expected {EXPECTED_CATALOG_RANDOM}, got {len(catalog_random)}"
        )
    if len(directed_random) != EXPECTED_DIRECTED_RANDOM:
        errors.append(
            f"runtime directed count drifted: expected {EXPECTED_DIRECTED_RANDOM}, got {len(directed_random)}"
        )
    if len(foreground_random) != EXPECTED_FOREGROUND_RANDOM:
        errors.append(
            "foreground random count drifted: "
            f"expected {EXPECTED_FOREGROUND_RANDOM}, got {len(foreground_random)}"
        )
    if len(bridge_random) != EXPECTED_BRIDGE_RANDOM:
        errors.append(
            f"bridge random count drifted: expected {EXPECTED_BRIDGE_RANDOM}, got {len(bridge_random)}"
        )
    overlap = {
        str(event["id"]) for event in foreground_random
    } & {str(event["id"]) for event in bridge_random}
    if overlap:
        errors.append(f"foreground and bridge pools overlap: {sorted(overlap)}")

    if errors:
        for message in errors:
            fail(message)
        return 1
    print(
        "EVENT_DIRECTOR_AUDIT_OK "
        f"events={len(events)} catalog_random={len(catalog_random)} "
        f"directed_random={len(directed_random)} once={len(directed_random) - len(EXPECTED_REPEATABLE)} "
        f"foreground={len(foreground_random)} bridge={len(bridge_random)} "
        f"bridge_roots={len(EXPECTED_IMPLICIT_BRIDGE_ROOTS)} "
        f"repeatable={len(EXPECTED_REPEATABLE)} chapters=5 asset_bands=5"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
