#!/usr/bin/env python3
"""Validate the Core Loop V2 demo design contract."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
CONTRACT_PATH = ROOT / "content" / "meta" / "demo_core_loop_v2.json"
REGISTRY_PATH = ROOT / "autoloads" / "DataRegistry.gd"

EXPECTED_TABS = ["messages", "calendar", "people", "record"]
EXPECTED_STAGES = [
    "unmet",
    "met",
    "opening",
    "player_reached_out",
    "shared_commitment",
    "friction",
    "repair_or_distance",
    "reciprocal",
    "romantic_intent",
    "committed",
    "closed",
]
POST_MEET_STAGES = set(EXPECTED_STAGES[2:])
PLAYER_PREREQUISITE_STAGES = set(EXPECTED_STAGES[3:])
ROMANCE_BUNDLES = {
    "daeun_player_return",
    "jiyeon_player_message",
    "daeun_shared_dream",
    "jiyeon_debt_coffee",
}
GENERIC_FOREGROUND_IDS = {
    "routine_apply",
    "routine_side_shift",
    "routine_study",
    "routine_recovery",
}
PLAYER_COPY_FIELDS = (
    "offer_ko",
    "offer_en",
    "detail_ko",
    "detail_en",
    "deadline_ko",
    "deadline_en",
    "decline_ko",
    "decline_en",
)
ALLOWED_ACTION_IDS = {"apply", "side_shift", "resume", "interview", "study", "rest"}
EXPECTED_ROUTINE_EFFECTS = {
    "livelihood": {
        "unemployed": {"money": 70_000, "health": -1, "mental": -1},
        "employed": {"work_performance": 1, "mental": -1},
    },
    "growth": {"intelligence": 1, "mental": -1},
    "recovery": {"health": 1, "mental": 3},
}


def fail(message: str, errors: list[str]) -> None:
    errors.append(message)


def load_registered_events(errors: list[str]) -> dict[str, dict[str, Any]]:
    source = REGISTRY_PATH.read_text(encoding="utf-8")
    try:
        block = source.split("const EVENT_PATHS = [", 1)[1].split("]", 1)[0]
    except IndexError:
        fail("DataRegistry EVENT_PATHS could not be parsed", errors)
        return {}
    paths = re.findall(r'"res://([^\"]+\.json)"', block)
    events: dict[str, dict[str, Any]] = {}
    for relative in paths:
        path = ROOT / relative
        try:
            rows = json.loads(path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError) as exc:
            fail(f"cannot load registered event file {relative}: {exc}", errors)
            continue
        if not isinstance(rows, list):
            fail(f"registered event file is not an array: {relative}", errors)
            continue
        for row in rows:
            if isinstance(row, dict) and str(row.get("id", "")):
                events[str(row["id"])] = row
    return events


def require_dict(value: Any, label: str, errors: list[str]) -> dict[str, Any]:
    if not isinstance(value, dict):
        fail(f"{label} must be an object", errors)
        return {}
    return value


def require_list(value: Any, label: str, errors: list[str]) -> list[Any]:
    if not isinstance(value, list):
        fail(f"{label} must be an array", errors)
        return []
    return value


def main() -> int:
    errors: list[str] = []
    try:
        contract = json.loads(CONTRACT_PATH.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        print(f"ERROR core loop v2: cannot load contract: {exc}")
        return 1

    scope = require_dict(contract.get("scope"), "scope", errors)
    surface = require_dict(contract.get("surface"), "surface", errors)
    routine = require_dict(contract.get("routine"), "routine", errors)
    relationship = require_dict(contract.get("relationship"), "relationship", errors)
    bundles = require_dict(contract.get("scene_bundles"), "scene_bundles", errors)
    months = require_list(contract.get("months"), "months", errors)
    groups = require_dict(contract.get("exclusive_groups"), "exclusive_groups", errors)

    if int(contract.get("schema_version", 0)) != 2:
        fail("schema_version must be 2 for the A1 executable loop contract", errors)
    if bool(contract.get("runtime_default", True)):
        fail("runtime_default must stay false before the 8-week human GO", errors)
    if str(contract.get("fallback", "")) != "event_director_v1":
        fail("existing event director must remain the development fallback", errors)

    expected_scope = {
        "min_week": 1,
        "max_week": 24,
        "months": 6,
        "weeks_per_month": 4,
        "prototype_weeks": [1, 8],
    }
    for key, expected in expected_scope.items():
        if scope.get(key) != expected:
            fail(f"scope.{key} expected {expected!r}, got {scope.get(key)!r}", errors)
    play_minutes = require_list(scope.get("target_play_minutes"), "target_play_minutes", errors)
    if play_minutes != [75, 120]:
        fail("target_play_minutes must remain [75, 120]", errors)

    if surface.get("tabs") != EXPECTED_TABS:
        fail(f"phone tabs must be {EXPECTED_TABS}", errors)
    if int(surface.get("foreground_slots_per_month", 0)) != 4:
        fail("foreground_slots_per_month must be 4", errors)
    if int(surface.get("maximum_locked_slots_per_month", 99)) != 1:
        fail("maximum_locked_slots_per_month must be 1", errors)
    for hidden_key in ("visible_ap", "visible_affinity_numbers", "visible_moral_values"):
        if bool(surface.get(hidden_key, True)):
            fail(f"surface.{hidden_key} must be false", errors)

    if int(routine.get("background_ap_per_week", 0)) != 2:
        fail("background AP must preserve the existing two-unit economy", errors)
    if bool(routine.get("direct_weekly_ap_menu", True)):
        fail("direct weekly AP menu must be hidden in V2", errors)
    if not bool(routine.get("applications_required_before_interview", False)):
        fail("applications must be required before interview contact", errors)
    routine_options = require_dict(routine.get("options"), "routine.options", errors)
    expected_routine_options = {"livelihood", "growth", "recovery"}
    if set(routine_options) != expected_routine_options:
        fail(
            "routine.options must contain exactly livelihood, growth, and recovery",
            errors,
        )
    if set(str(value) for value in routine.get("primary_tracks", [])) \
            != expected_routine_options:
        fail("routine.primary_tracks must match the three executable options", errors)
    for option_id in sorted(expected_routine_options):
        option = require_dict(
            routine_options.get(option_id), f"routine.options.{option_id}", errors
        )
        effects = require_dict(
            option.get("weekly_effects"),
            f"routine.options.{option_id}.weekly_effects",
            errors,
        )
        if not effects:
            fail(f"routine option {option_id} has no weekly effects", errors)
        effect_profiles: dict[str, dict[str, Any]]
        if option_id == "livelihood":
            if set(effects) != {"unemployed", "employed"}:
                fail(
                    "livelihood weekly effects must distinguish unemployed "
                    "and employed execution",
                    errors,
                )
            effect_profiles = {
                profile: require_dict(
                    effects.get(profile),
                    f"routine.options.livelihood.weekly_effects.{profile}",
                    errors,
                )
                for profile in ("unemployed", "employed")
            }
        else:
            effect_profiles = {"default": effects}
        for profile, profile_effects in effect_profiles.items():
            for stat, value in profile_effects.items():
                if stat not in {
                    "money",
                    "health",
                    "mental",
                    "intelligence",
                    "work_performance",
                }:
                    fail(
                        f"routine option {option_id}.{profile} writes unsupported "
                        f"stat {stat}",
                        errors,
                    )
                if not isinstance(value, (int, float)) or isinstance(value, bool):
                    fail(
                        f"routine option {option_id}.{profile}.{stat} must be numeric",
                        errors,
                    )
            if not any(
                isinstance(value, (int, float))
                and not isinstance(value, bool)
                and float(value) != 0.0
                for value in profile_effects.values()
            ):
                fail(
                    f"routine option {option_id}.{profile} has only zero effects",
                    errors,
                )
        expected_effects = EXPECTED_ROUTINE_EFFECTS[option_id]
        if effects != expected_effects:
            fail(
                f"routine option {option_id} effects drifted: "
                f"expected {expected_effects}, got {effects}",
                errors,
            )
    livelihood_effects = require_dict(
        require_dict(
            routine_options.get("livelihood"),
            "routine.options.livelihood",
            errors,
        ).get("weekly_effects"),
        "routine.options.livelihood.weekly_effects",
        errors,
    )
    livelihood_unemployed = require_dict(
        livelihood_effects.get("unemployed"),
        "routine.options.livelihood.weekly_effects.unemployed",
        errors,
    )
    if int(livelihood_unemployed.get("money", 0)) != 70_000:
        fail("livelihood weekly routine must preserve the KRW 70,000 legal floor", errors)

    if relationship.get("stages") != EXPECTED_STAGES:
        fail("relationship stage order drifted", errors)
    if int(relationship.get("maximum_active_named_threads", 99)) > 4:
        fail("maximum_active_named_threads cannot exceed 4", errors)
    if int(relationship.get("maximum_primary_threads", 99)) > 2:
        fail("maximum_primary_threads cannot exceed 2", errors)
    if bool(relationship.get("generic_contact_rewards", True)):
        fail("generic contact rewards must stay disabled", errors)
    if not bool(relationship.get("romance_requires_player_initiation", False)):
        fail("romance must require player initiation", errors)
    if bool(relationship.get("future_route_preview", True)):
        fail("future route preview must stay hidden", errors)

    registered_events = load_registered_events(errors)
    registered = set(registered_events)
    for bundle_id, raw in bundles.items():
        bundle = require_dict(raw, f"bundle {bundle_id}", errors)
        roots = require_list(bundle.get("existing_roots", []), f"{bundle_id}.existing_roots", errors)
        if not roots and not str(bundle.get("planned_scene_id", "")) and not str(bundle.get("action_id", "")):
            fail(f"{bundle_id} has no existing root, planned scene, or action", errors)
        for event_id in roots:
            if str(event_id) not in registered:
                fail(f"{bundle_id} references missing event {event_id}", errors)
        if bool(bundle.get("consumes_slot", False)) and not str(bundle.get("decline_consequence", "")):
            fail(f"{bundle_id} consumes a slot but has no decline consequence", errors)
        stage = str(bundle.get("relationship_stage", ""))
        if stage and stage not in EXPECTED_STAGES:
            fail(f"{bundle_id} has unknown relationship stage {stage}", errors)
        if stage in POST_MEET_STAGES:
            initiated_by = str(bundle.get("initiated_by", ""))
            if initiated_by not in {"player", "reciprocal"}:
                fail(f"{bundle_id} advances beyond meeting without player/reciprocal initiative", errors)
        if stage in PLAYER_PREREQUISITE_STAGES:
            if not bool(bundle.get("requires_player_initiated", False)):
                fail(f"{bundle_id} advances beyond opening without a player-initiation prerequisite", errors)

    for bundle_id in ROMANCE_BUNDLES:
        bundle = require_dict(bundles.get(bundle_id), f"romance bundle {bundle_id}", errors)
        if str(bundle.get("initiated_by", "")) not in {"player", "reciprocal"}:
            fail(f"{bundle_id} does not preserve relationship agency", errors)
        if not bool(bundle.get("requires_player_initiated", False)):
            fail(f"{bundle_id} can advance romance without player initiative", errors)

    expected_groups = {
        "romance_entry": {"daeun_world_meet", "jiyeon_world_meet"},
        "money_mentor_entry": {"sangchul_world_meet", "jaehyuk_world_meet"},
    }
    for group_id, expected_members in expected_groups.items():
        group = require_dict(groups.get(group_id), f"group {group_id}", errors)
        members = set(str(value) for value in require_list(group.get("members"), f"{group_id}.members", errors))
        if members != expected_members:
            fail(f"{group_id} members expected {sorted(expected_members)}, got {sorted(members)}", errors)
        if int(group.get("maximum_selected", 0)) != 1:
            fail(f"{group_id} must allow at most one selection per month", errors)
        for member in members:
            if member not in bundles:
                fail(f"{group_id} references missing bundle {member}", errors)

    if len(months) != 6:
        fail(f"expected 6 months, got {len(months)}", errors)
    expected_start = 1
    total_minutes = 0
    all_month_offer_ids: set[str] = set()
    action_offer_months: dict[str, list[int]] = {}
    prototype_offer_ids: set[str] = set()
    prototype_selectable_ids: set[str] = set()
    prototype_month_by_bundle: dict[str, int] = {}
    for expected_month, raw in enumerate(months, start=1):
        month = require_dict(raw, f"month {expected_month}", errors)
        if int(month.get("month", 0)) != expected_month:
            fail(f"month index expected {expected_month}, got {month.get('month')}", errors)
        weeks = require_list(month.get("weeks"), f"month {expected_month}.weeks", errors)
        expected_weeks = [expected_start, expected_start + 3]
        if weeks != expected_weeks:
            fail(f"month {expected_month} weeks expected {expected_weeks}, got {weeks}", errors)
        expected_start += 4
        offers = [str(value) for value in require_list(month.get("offers"), f"month {expected_month}.offers", errors)]
        minimum = int(surface.get("minimum_offers_per_month", 5))
        maximum = int(surface.get("maximum_offers_per_month", 7))
        if not minimum <= len(offers) <= maximum:
            fail(f"month {expected_month} must expose {minimum}..{maximum} offers, got {len(offers)}", errors)
        if len(set(offers)) != len(offers):
            fail(f"month {expected_month} has duplicate offers", errors)
        for bundle_id in offers:
            all_month_offer_ids.add(bundle_id)
            if bundle_id not in bundles:
                fail(f"month {expected_month} references missing offer {bundle_id}", errors)
                continue
            bundle = require_dict(bundles[bundle_id], f"bundle {bundle_id}", errors)
            if bundle_id in GENERIC_FOREGROUND_IDS or str(bundle.get("kind", "")) == "routine":
                fail(f"month {expected_month} exposes generic AP action {bundle_id}", errors)
            action_id = str(bundle.get("action_id", ""))
            if action_id:
                action_offer_months.setdefault(bundle_id, []).append(expected_month)
                if action_id not in ALLOWED_ACTION_IDS:
                    fail(f"{bundle_id} has unsupported action_id {action_id}", errors)
                if not bundle_id.startswith(f"m{expected_month}_"):
                    fail(f"{bundle_id} must be a month-specific foreground commitment", errors)
            if expected_month <= 2:
                prototype_offer_ids.add(bundle_id)
                prototype_selectable_ids.add(bundle_id)
                prototype_month_by_bundle[bundle_id] = expected_month
        locked = require_list(month.get("locked"), f"month {expected_month}.locked", errors)
        if len(locked) > int(surface.get("maximum_locked_slots_per_month", 1)):
            fail(f"month {expected_month} locks too many foreground slots", errors)
        for row in locked:
            lock = require_dict(row, f"month {expected_month} lock", errors)
            bundle_id = str(lock.get("bundle", ""))
            if bundle_id not in bundles:
                fail(f"month {expected_month} lock references missing bundle {bundle_id}", errors)
            elif expected_month <= 2:
                prototype_offer_ids.add(bundle_id)
                prototype_month_by_bundle[bundle_id] = expected_month
            week = int(lock.get("week", 0))
            if week < weeks[0] or week > weeks[1]:
                fail(f"month {expected_month} lock week {week} lies outside {weeks}", errors)
        named_cap = int(month.get("active_named_characters_max", 99))
        if named_cap > int(relationship.get("maximum_active_named_threads", 4)):
            fail(f"month {expected_month} exceeds named-character cap", errors)
        total_minutes += int(month.get("target_minutes", 0))

    for bundle_id, owner_months in action_offer_months.items():
        if len(owner_months) != 1:
            fail(f"{bundle_id} is reused across months {owner_months}; foreground actions must be concrete", errors)

    for bundle_id in sorted(prototype_offer_ids):
        bundle = require_dict(bundles.get(bundle_id), f"prototype bundle {bundle_id}", errors)
        for field in PLAYER_COPY_FIELDS:
            if not str(bundle.get(field, "")).strip():
                fail(f"{bundle_id} is missing bilingual player copy field {field}", errors)
        allowed_weeks = require_list(
            bundle.get("allowed_weeks"),
            f"{bundle_id}.allowed_weeks",
            errors,
        )
        if not allowed_weeks:
            fail(f"{bundle_id} has no executable allowed_weeks deadline", errors)
            continue
        normalized_weeks: list[int] = []
        for raw_week in allowed_weeks:
            if not isinstance(raw_week, int) or isinstance(raw_week, bool):
                fail(f"{bundle_id}.allowed_weeks contains a non-integer", errors)
                continue
            normalized_weeks.append(raw_week)
        if len(set(normalized_weeks)) != len(normalized_weeks):
            fail(f"{bundle_id}.allowed_weeks contains duplicates", errors)
        owner_month = prototype_month_by_bundle.get(bundle_id, 0)
        month_start = (owner_month - 1) * 4 + 1
        legal_month_weeks = set(range(month_start, month_start + 4))
        if not set(normalized_weeks).issubset(legal_month_weeks):
            fail(
                f"{bundle_id}.allowed_weeks escapes month {owner_month}: "
                f"{normalized_weeks}",
                errors,
            )
        locked_week = int(bundle.get("locked_week", 0))
        if locked_week and normalized_weeks != [locked_week]:
            fail(
                f"{bundle_id} locked week {locked_week} must be its sole allowed week",
                errors,
            )

    if len(prototype_selectable_ids) != 13:
        fail(
            "the 1-8 week prototype must have exactly 13 selectable decline producers, "
            f"got {len(prototype_selectable_ids)}",
            errors,
        )
    decline_outcomes = require_dict(
        contract.get("decline_outcomes"), "decline_outcomes", errors
    )
    selectable_decline_ids: dict[str, str] = {}
    for bundle_id in sorted(prototype_selectable_ids):
        bundle = require_dict(bundles.get(bundle_id), f"bundle {bundle_id}", errors)
        consequence_id = str(bundle.get("decline_consequence", "")).strip()
        if not consequence_id:
            fail(f"{bundle_id} has no decline consequence producer", errors)
            continue
        if consequence_id in selectable_decline_ids:
            fail(
                f"decline consequence {consequence_id} is shared by "
                f"{selectable_decline_ids[consequence_id]} and {bundle_id}",
                errors,
            )
        selectable_decline_ids[consequence_id] = bundle_id
        outcome = require_dict(
            decline_outcomes.get(consequence_id),
            f"decline_outcomes.{consequence_id}",
            errors,
        )
        if str(outcome.get("producer_bundle", "")) != bundle_id:
            fail(
                f"decline outcome {consequence_id} does not point back to "
                f"producer {bundle_id}",
                errors,
            )
        if str(outcome.get("consumer_kind", "")) not in {
            "next_month_message",
            "terminal_recap",
            "in_scene_choice",
        }:
            fail(f"decline outcome {consequence_id} has no executable consumer", errors)
        if int(outcome.get("visible_month", 0)) not in {2, 3}:
            fail(
                f"decline outcome {consequence_id} must surface in month 2 "
                "or the post-month-2 terminal recap",
                errors,
            )
        for language_key in ("message_ko", "message_en"):
            if not str(outcome.get(language_key, "")).strip():
                fail(
                    f"decline outcome {consequence_id} is missing {language_key}",
                    errors,
                )
    consumer_producers: dict[str, list[str]] = {}
    for consequence_id, raw_outcome in decline_outcomes.items():
        outcome = require_dict(
            raw_outcome, f"decline_outcomes.{consequence_id}", errors
        )
        producer = str(outcome.get("producer_bundle", "")).strip()
        if producer:
            consumer_producers.setdefault(producer, []).append(str(consequence_id))
    for bundle_id in sorted(prototype_selectable_ids):
        expected_consequence = str(
            require_dict(bundles.get(bundle_id), f"bundle {bundle_id}", errors).get(
                "decline_consequence", ""
            )
        )
        if consumer_producers.get(bundle_id, []) != [expected_consequence]:
            fail(
                f"{bundle_id} must have exactly one matching decline consumer; "
                f"got {consumer_producers.get(bundle_id, [])}",
                errors,
            )

    prototype_relationship_ids = {
        bundle_id
        for bundle_id in prototype_offer_ids
        if str(
            require_dict(bundles.get(bundle_id), f"bundle {bundle_id}", errors).get(
                "relationship_stage", ""
            )
        )
    }
    for bundle_id in sorted(prototype_relationship_ids):
        bundle = require_dict(bundles.get(bundle_id), f"bundle {bundle_id}", errors)
        roots = [str(value) for value in bundle.get("existing_roots", [])]
        mappings = require_list(
            bundle.get("relationship_outcomes"),
            f"{bundle_id}.relationship_outcomes",
            errors,
        )
        if not mappings:
            fail(f"{bundle_id} has no choice-result relationship mapping", errors)
            continue
        mapped_choices: dict[str, set[int]] = {}
        for index, raw_mapping in enumerate(mappings):
            mapping = require_dict(
                raw_mapping,
                f"{bundle_id}.relationship_outcomes[{index}]",
                errors,
            )
            event_id = str(mapping.get("event_id", "")).strip()
            if event_id not in roots:
                fail(
                    f"{bundle_id} relationship outcome references non-root "
                    f"event {event_id}",
                    errors,
                )
            stage = str(mapping.get("stage", "")).strip()
            if stage not in EXPECTED_STAGES:
                fail(
                    f"{bundle_id} relationship outcome has unknown stage {stage}",
                    errors,
                )
            character = str(mapping.get("character", "")).strip()
            if character and character not in {
                str(value) for value in bundle.get("characters", [])
            }:
                fail(
                    f"{bundle_id} relationship outcome targets unrelated "
                    f"character {character}",
                    errors,
                )
            choices = require_list(
                mapping.get("choices"),
                f"{bundle_id}.relationship_outcomes[{index}].choices",
                errors,
            )
            if not choices:
                fail(f"{bundle_id} relationship outcome has no choices", errors)
            choice_set = mapped_choices.setdefault(event_id, set())
            for raw_choice in choices:
                if not isinstance(raw_choice, int) or isinstance(raw_choice, bool):
                    fail(
                        f"{bundle_id} relationship choice index must be an integer",
                        errors,
                    )
                    continue
                if raw_choice in choice_set:
                    fail(
                        f"{bundle_id} maps {event_id} choice {raw_choice} twice",
                        errors,
                    )
                choice_set.add(raw_choice)
        for event_id in roots:
            event = require_dict(
                registered_events.get(event_id),
                f"registered event {event_id}",
                errors,
            )
            choices = require_list(
                event.get("choices"), f"registered event {event_id}.choices", errors
            )
            expected_choice_indexes = set(range(len(choices)))
            if mapped_choices.get(event_id, set()) != expected_choice_indexes:
                fail(
                    f"{bundle_id} must map every {event_id} choice exactly once: "
                    f"expected {sorted(expected_choice_indexes)}, got "
                    f"{sorted(mapped_choices.get(event_id, set()))}",
                    errors,
                )

    hyunsu_followup = require_dict(
        bundles.get("hyunsu_player_reachout"),
        "bundle hyunsu_player_reachout",
        errors,
    )
    if hyunsu_followup.get("existing_roots") != ["v2_hyunsu_player_reachout"]:
        fail(
            "Hyunsu player reach-out must use the dedicated "
            "v2_hyunsu_player_reachout physical scene",
            errors,
        )

    if not 75 <= total_minutes <= 120:
        fail(f"monthly target minutes total {total_minutes} is outside 75..120", errors)
    if not expected_groups["romance_entry"].issubset(all_month_offer_ids):
        fail("both route-dependent heroine entrances must exist in the monthly plan", errors)
    if not expected_groups["money_mentor_entry"].issubset(all_month_offer_ids):
        fail("both route-dependent money mentor entrances must exist in the monthly plan", errors)

    if errors:
        for message in errors:
            print(f"ERROR core loop v2: {message}")
        return 1

    print(
        "core_loop_v2_ok "
        f"schema={contract['schema_version']} "
        f"months={len(months)} weeks={scope['min_week']}..{scope['max_week']} "
        f"bundles={len(bundles)} target_minutes={total_minutes} "
        f"slots={surface['foreground_slots_per_month']} "
        f"prototype_deadlines={len(prototype_offer_ids)} "
        f"decline_consumers={len(selectable_decline_ids)} "
        f"routines={len(routine_options)} "
        f"relationship_choice_maps={len(prototype_relationship_ids)} "
        f"visible_ap={str(surface['visible_ap']).lower()}"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
