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


def fail(message: str, errors: list[str]) -> None:
    errors.append(message)


def load_registered_event_ids(errors: list[str]) -> set[str]:
    source = REGISTRY_PATH.read_text(encoding="utf-8")
    try:
        block = source.split("const EVENT_PATHS = [", 1)[1].split("]", 1)[0]
    except IndexError:
        fail("DataRegistry EVENT_PATHS could not be parsed", errors)
        return set()
    paths = re.findall(r'"res://([^\"]+\.json)"', block)
    ids: set[str] = set()
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
                ids.add(str(row["id"]))
    return ids


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

    if int(contract.get("schema", 0)) != 1:
        fail("schema must be 1", errors)
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

    registered = load_registered_event_ids(errors)
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
        f"months={len(months)} weeks={scope['min_week']}..{scope['max_week']} "
        f"bundles={len(bundles)} target_minutes={total_minutes} "
        f"slots={surface['foreground_slots_per_month']} "
        f"visible_ap={str(surface['visible_ap']).lower()}"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
