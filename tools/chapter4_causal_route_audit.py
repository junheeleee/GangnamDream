#!/usr/bin/env python3
"""Audit the shipping Chapter 4 causal spine introduced by ORDER-131."""

from __future__ import annotations

import argparse
import copy
import json
import re
import sys
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
KO_DIR = ROOT / "content" / "events"
EN_DIR = ROOT / "content" / "events_en"
DIRECTOR = ROOT / "content" / "meta" / "event_director.json"
LIFECYCLE = ROOT / "content" / "meta" / "event_lifecycle.json"
MAIN_GAME = ROOT / "scenes" / "MainGame.gd"

GROUPS = {
    "m39": (
        "arc_y4_three_promises",
        "arc_y4_three_promises_jiyeon_and_deal",
        "arc_y4_three_promises_deal_only",
    ),
    "m41": (
        "arc_y4_body_witness",
        "arc_y4_body_witness_jiyeon",
        "arc_y4_body_witness_hyunsu",
    ),
    "m42": (
        "arc_y4_family_partner_collision",
        "arc_y4_family_partner_collision_jiyeon",
        "arc_y4_family_commitment_none",
        "arc_y4_family_table_missed",
    ),
    "m44": (
        "arc_y4_father_call_answered_on_ktx",
        "arc_y4_father_call_missed_on_ktx",
    ),
    "m45": (
        "arc_y4_borrowed_name",
        "arc_y4_borrowed_name_jiyeon",
        "arc_y4_borrowed_name_self",
        "arc_y4_borrowed_name_document_gap",
    ),
    "m46": (
        "arc_y4_bill_night",
        "arc_y4_bill_night_jiyeon",
        "arc_y4_bill_night_unattached",
    ),
    "m47": (
        "arc_y4_father_final_contact_present",
        "arc_y4_father_final_contact_called",
        "arc_y4_father_final_contact_missed",
    ),
    "m48": (
        "arc_y4_year_close_daeun",
        "arc_y4_year_close_jiyeon",
        "arc_y4_year_close_unattached",
    ),
}
PROMOTED = tuple(event_id for rows in GROUPS.values() for event_id in rows)
NEW_EVENTS = (
    "arc_y4_father_crisis_contact",
    "arc_y4_father_crisis_stabilized",
    "arc_y4_father_outcome_unknown",
)
EXPECTED_DIRECT = [
    145, 149, 153, 157, 161, 164, 167, 169, 174, 177,
    181, 185, 188, 190, 192,
]
EXPECTED_BOSSES = [45, 92, 140, 192, 237]
EXPECTED_OWNER_IDS = {
    153: set(GROUPS["m39"]),
    157: {"arc_36_unexpected_hand"},
    161: {"arc_36_body_signal"},
    164: set(GROUPS["m41"]),
    167: set(GROUPS["m42"]),
    174: {"arc_father_call_on_ktx_number"},
    177: set(GROUPS["m45"]),
    181: set(GROUPS["m46"]),
    185: {"arc_y4_father_crisis_contact"},
    188: {"arc_y4_father_crisis_stabilized", "arc_father_passing"},
    190: set(GROUPS["m48"]),
    192: {"arc_year4_close"},
}
PLACEHOLDER_RE = re.compile(r"\{[A-Za-z_][A-Za-z0-9_]*\}")


def load_events(directory: Path) -> dict[str, dict[str, Any]]:
    result: dict[str, dict[str, Any]] = {}
    for path in sorted(directory.glob("*.json")):
        raw = json.loads(path.read_text(encoding="utf-8"))
        rows = raw.get("events", []) if isinstance(raw, dict) else raw
        if not isinstance(rows, list):
            continue
        for row in rows:
            if isinstance(row, dict) and row.get("id"):
                event_id = str(row["id"])
                if event_id in result:
                    raise ValueError(f"duplicate event id {event_id}")
                result[event_id] = row
    return result


def choice_flags(choice: dict[str, Any]) -> set[str]:
    flags = choice.get("flags", [])
    return {str(flag) for flag in flags} if isinstance(flags, list) else set()


def placeholders(value: Any) -> set[str]:
    return set(PLACEHOLDER_RE.findall(json.dumps(value, ensure_ascii=False)))


def expression(choice: dict[str, Any]) -> bool:
    return str(choice.get("choice_kind", "")).strip() == "expression"


def stateful_keys(choice: dict[str, Any]) -> set[str]:
    keys = {
        "effects", "cast_effects", "flags", "items_add", "items_remove",
        "set_flag", "deferred_follow_up",
    }
    return {key for key in keys if choice.get(key) not in (None, {}, [])}


def assert_exactly_one(
    flags: set[str], allowed: set[str], owner: str, errors: list[str],
) -> None:
    actual = flags & allowed
    if len(actual) != 1:
        errors.append(f"{owner}: expected exactly one of {sorted(allowed)}, got {sorted(actual)}")


def validate_model(
    ko: dict[str, dict[str, Any]],
    en: dict[str, dict[str, Any]],
    director: dict[str, Any],
    lifecycle: dict[str, Any],
    source: str,
) -> list[str]:
    errors: list[str] = []
    if len(PROMOTED) != 25 or len(set(PROMOTED)) != 25:
        errors.append("promoted population must be exactly 25 unique events")

    for event_id in (*PROMOTED, *NEW_EVENTS):
        if event_id not in ko or event_id not in en:
            errors.append(f"missing KO/EN event: {event_id}")
            continue
        ko_event = ko[event_id]
        en_event = en[event_id]
        if len(ko_event.get("choices", [])) != len(en_event.get("choices", [])):
            errors.append(f"{event_id}: KO/EN choice count drift")
        if placeholders(ko_event) != placeholders(en_event):
            errors.append(f"{event_id}: KO/EN placeholder drift")
        for index, (ko_choice, en_choice) in enumerate(
            zip(ko_event.get("choices", []), en_event.get("choices", []))
        ):
            # English event files are text-only overlays. Gameplay state remains
            # authoritative in Korean and must not be duplicated into a locale.
            for field in (
                "flags", "effects", "cast_effects", "follow_up_event",
                "choice_kind", "items_add", "items_remove", "set_flag",
                "deferred_follow_up",
            ):
                if field in en_choice:
                    errors.append(
                        f"{event_id}.choices[{index}]: EN overlay owns gameplay field {field}"
                    )
    for event_id in PROMOTED:
        event = ko.get(event_id, {})
        if "author_only" in event.get("tags", []):
            errors.append(f"{event_id}: author_only tag remains")
        if event.get("weight") != 0 or event.get("hidden") is not True:
            errors.append(f"{event_id}: shipping ingress must preserve weight=0/hidden=true")
        if event.get("conditions", {}).get("min_turn") != 9999:
            errors.append(f"{event_id}: direct-only min_turn contract drift")

    author_only = set(lifecycle.get("author_only_event_ids", []))
    leaked = set(PROMOTED) & author_only
    if leaked:
        errors.append(f"promoted events remain in lifecycle author-only ledger: {sorted(leaked)}")

    full = director.get("full_run_pacing", {})
    chapter4_direct = [
        int(week) for week in full.get("decision_weeks", [])
        if 145 <= int(week) <= 192
    ]
    if chapter4_direct != EXPECTED_DIRECT:
        errors.append(f"Chapter 4 direct weeks drifted: {chapter4_direct}")
    if full.get("boss_weeks") != EXPECTED_BOSSES:
        errors.append(f"full boss weeks drifted: {full.get('boss_weeks')}")
    owners = full.get("commitment_event_owners", {})
    for week, expected_ids in EXPECTED_OWNER_IDS.items():
        actual_ids = {
            str(row.get("id", "")) if isinstance(row, dict) else str(row)
            for row in owners.get(str(week), [])
        }
        if actual_ids != expected_ids:
            errors.append(f"W{week} owner ids drifted: {sorted(actual_ids)}")
        for event_id in actual_ids:
            event = ko.get(event_id, {})
            choices = event.get("choices", [])
            if len(choices) < 2:
                errors.append(f"W{week}/{event_id}: owner needs at least two choices")
            if any(expression(choice) for choice in choices):
                errors.append(f"W{week}/{event_id}: owner choice is expression")
    if owners.get("169"):
        errors.append("M43 consequence owns a duplicate weekly action")

    if "func _chapter_four_causal_arc_id" not in source:
        errors.append("MainGame lacks the Chapter 4 causal router")
    for week in (153, 157, 161, 164, 167, 169, 174, 177, 181, 185, 188, 190):
        if f"t == {week}" not in source:
            errors.append(f"MainGame lacks exact W{week} route")
    if re.search(r"t\s*>=\s*176[^\n]{0,500}arc_father_passing", source):
        errors.append("legacy W176+ father death route remains")

    protected = {
        "arc_y4_three_promises_protected_father",
        "arc_y4_three_promises_protected_person",
        "arc_y4_three_promises_protected_deal",
    }
    missed = {
        "arc_y4_three_promises_missed_father",
        "arc_y4_three_promises_missed_person",
        "arc_y4_three_promises_missed_deal",
    }
    for event_id in GROUPS["m39"]:
        for index, choice in enumerate(ko[event_id]["choices"]):
            flags = choice_flags(choice)
            assert_exactly_one(flags, protected, f"{event_id}[{index}] protected", errors)
            if len(flags & missed) != 2:
                errors.append(f"{event_id}[{index}]: must name both forgone promises")
            if "arc_y4_three_promises_seen" not in flags:
                errors.append(f"{event_id}[{index}]: common receipt missing")

    exclusive_contracts = (
        (GROUPS["m41"], "arc_y4_body_witness_seen", {
            "arc_y4_body_chose_care", "arc_y4_body_chose_deadline", "arc_y4_body_chose_alone",
        }),
        (GROUPS["m42"], "arc_y4_family_table_seen", {
            "arc_y4_family_attended_together", "arc_y4_family_attended_alone",
            "arc_y4_family_missed",
        }),
        (GROUPS["m48"], "arc_y4_year_close_boundary_seen", {
            "arc_y4_year_close_protected_relationship",
            "arc_y4_year_close_protected_body",
            "arc_y4_year_close_protected_family",
        }),
    )
    for event_ids, common, allowed in exclusive_contracts:
        for event_id in event_ids:
            for index, choice in enumerate(ko[event_id]["choices"]):
                flags = choice_flags(choice)
                if common not in flags:
                    errors.append(f"{event_id}[{index}]: common receipt {common} missing")
                assert_exactly_one(flags, allowed, f"{event_id}[{index}]", errors)
                if expression(choice):
                    errors.append(f"{event_id}[{index}]: actual action became expression")

    for event_id in GROUPS["m46"]:
        for index, choice in enumerate(ko[event_id]["choices"]):
            flags = choice_flags(choice)
            if "arc_y4_bill_night_seen" not in flags:
                errors.append(f"{event_id}[{index}]: M46 common receipt missing")
            assert_exactly_one(
                flags, {"father_care_coordinated", "father_care_left_open"},
                f"{event_id}[{index}] care", errors,
            )

    ktx = ko.get("arc_father_call_on_ktx_number", {})
    ktx_choices = ktx.get("choices", [])
    expected_ktx = (
        {"arc_father_call_on_ktx_seen", "called_father_on_ktx"},
        {"arc_father_call_on_ktx_seen", "did_not_call_father_on_ktx"},
    )
    if len(ktx_choices) != 2:
        errors.append("KTX terminal must have two choices")
    else:
        for index, expected in enumerate(expected_ktx):
            if choice_flags(ktx_choices[index]) != expected:
                errors.append(f"KTX terminal choice {index} flag drift")
            if expression(ktx_choices[index]):
                errors.append(f"KTX terminal choice {index} became expression")
    for event_id in (
        "arc_father_call_on_ktx", "arc_father_call_on_ktx_memory",
        *GROUPS["m44"],
    ):
        if any(not expression(choice) for choice in ko.get(event_id, {}).get("choices", [])):
            errors.append(f"{event_id}: staging/result choice must be expression")
    ktx_ko = "\n".join(
        json.dumps(ko.get(event_id, {}), ensure_ascii=False)
        for event_id in ("arc_father_call_on_ktx", "arc_father_call_on_ktx_memory", *GROUPS["m44"])
    )
    if "창원행" in ktx_ko or "서울역을 떠난" in ktx_ko:
        errors.append("KTX prose reintroduced the opposite Seoul-to-Changwon direction")
    if "서울행" not in ktx_ko or "창원" not in ktx_ko:
        errors.append("KTX prose does not establish Changwon-to-Seoul travel")

    contact = ko.get("arc_y4_father_crisis_contact", {})
    contact_flags = {
        "father_crisis_contact_present",
        "father_crisis_contact_called",
        "father_crisis_contact_missed",
    }
    if len(contact.get("choices", [])) != 3:
        errors.append("M47 crisis contact gateway must have three choices")
    for index, choice in enumerate(contact.get("choices", [])):
        flags = choice_flags(choice)
        if "arc_y4_father_crisis_contact_seen" not in flags:
            errors.append(f"M47 gateway choice {index}: common receipt missing")
        assert_exactly_one(flags, contact_flags, f"M47 gateway choice {index}", errors)
        if {"father_passed", "father_crisis_stabilized"} & flags:
            errors.append(f"M47 gateway choice {index}: contact writes life outcome")
    for event_id in GROUPS["m47"]:
        for index, choice in enumerate(ko[event_id]["choices"]):
            if not expression(choice) or stateful_keys(choice):
                errors.append(f"{event_id}[{index}]: expression result mutates state")

    stable = ko.get("arc_y4_father_crisis_stabilized", {})
    for index, choice in enumerate(stable.get("choices", [])):
        flags = choice_flags(choice)
        if not {
            "arc_y4_father_crisis_stabilized_seen", "father_crisis_stabilized",
        }.issubset(flags):
            errors.append(f"stable choice {index}: durable receipts missing")
        if choice.get("cast_effects", {}).get("father", {}).get("stage") != "health_crisis":
            errors.append(f"stable choice {index}: father must remain in health_crisis")
    unknown = ko.get("arc_y4_father_outcome_unknown", {})
    if len(unknown.get("choices", [])) != 1:
        errors.append("damaged-save recovery must be one acknowledgement")
    elif choice_flags(unknown["choices"][0]) != {"arc_y4_father_outcome_unknown_seen"}:
        errors.append("damaged-save recovery invented a life outcome")

    outcome_block = source.split(
        "func _chapter_four_father_outcome_id", 1
    )[1].split("\nfunc ", 1)[0] if "func _chapter_four_father_outcome_id" in source else ""
    for forbidden in contact_flags | {"visited_father", "rushed_to_father", "sent_money_instead"}:
        if f'"{forbidden}"' in outcome_block:
            errors.append(f"medical outcome illegally reads contact/nonmedical flag {forbidden}")
    for required in (
        "called_about_medication", "visited_for_medication",
        "sangchul_helped_with_father", "father_care_coordinated",
        "medical_evidence >= 2",
    ):
        if required not in outcome_block:
            errors.append(f"medical 2-of-3 contract missing {required}")
    if "GameState.get_cast_stage(\"father\") == \"passed\"" not in outcome_block:
        errors.append("damaged saves do not preserve monotonic father death")

    death_writers = {
        event_id
        for event_id, event in ko.items()
        if any("father_passed" in choice_flags(choice) for choice in event.get("choices", []))
    }
    if death_writers != {
        "arc_father_passing_hospital_room", "arc_father_passing_deal_morning",
    }:
        errors.append(f"father death writer set drifted: {sorted(death_writers)}")

    jiyeon_text = json.dumps(
        [ko[event_id] for event_id in (
            "arc_y4_three_promises_jiyeon_and_deal",
            "arc_y4_body_witness_jiyeon",
            "arc_y4_family_partner_collision_jiyeon",
            "arc_y4_bill_night_jiyeon",
            "arc_y4_year_close_jiyeon",
        )], ensure_ascii=False,
    )
    if "부산" not in jiyeon_text:
        errors.append("Jiyeon Chapter 4 route lost its Busan long-distance fact")
    document_gap = json.dumps(ko.get("arc_y4_borrowed_name_document_gap", {}), ensure_ascii=False)
    for term in ("대주", "원금", "만기", "담보"):
        if term not in document_gap:
            errors.append(f"M45 document gap omits {term}")
    en_document_gap = json.dumps(en.get("arc_y4_borrowed_name_document_gap", {}), ensure_ascii=False).lower()
    for term in ("lender", "principal", "maturity", "collateral"):
        if term not in en_document_gap:
            errors.append(f"M45 EN document gap omits {term}")

    forbidden_surface = re.compile(r"\bAP\b|행동력|여력\s*[0-9]|beat\s*(?:count|quota)", re.IGNORECASE)
    for event_id in (*PROMOTED, *NEW_EVENTS):
        if forbidden_surface.search(json.dumps(ko.get(event_id, {}), ensure_ascii=False)):
            errors.append(f"{event_id}: AP/quota language leaked into player prose")
    return errors


def run_self_test() -> None:
    base_event = {
        "choices": [{
            "choice_kind": "expression",
            "result_text": "receipt",
        }]
    }
    if stateful_keys(base_event["choices"][0]):
        raise AssertionError("state-free expression fixture rejected")
    mutated = copy.deepcopy(base_event)
    mutated["choices"][0]["flags"] = ["father_passed"]
    if not stateful_keys(mutated["choices"][0]):
        raise AssertionError("expression mutation was not detected")

    allowed = {"a", "b", "c"}
    errors: list[str] = []
    assert_exactly_one({"a"}, allowed, "positive", errors)
    if errors:
        raise AssertionError(errors[0])
    assert_exactly_one({"a", "b"}, allowed, "negative", errors)
    if not errors:
        raise AssertionError("exclusive receipt mutation was not detected")

    source = """
func _chapter_four_father_outcome_id(f):
    var medication_called = f.get("called_about_medication", false)
    var medication_visited = f.get("visited_for_medication", false)
    var care = f.get("father_care_coordinated", false)
    if f.get("sangchul_helped_with_father", false): pass
    if medical_evidence >= 2: pass
    if GameState.get_cast_stage("father") == "passed": pass
func next(): pass
"""
    block = source.split("func _chapter_four_father_outcome_id", 1)[1].split("\nfunc ", 1)[0]
    if "father_crisis_contact_called" in block:
        raise AssertionError("fixture contact leaked into medical evidence")
    mutated_source = source.replace(
        'var care = f.get("father_care_coordinated", false)',
        'var care = f.get("father_crisis_contact_called", false)',
    )
    mutated_block = mutated_source.split(
        "func _chapter_four_father_outcome_id", 1
    )[1].split("\nfunc ", 1)[0]
    if "father_crisis_contact_called" not in mutated_block:
        raise AssertionError("contact-evidence mutation was not detected")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    if args.self_test:
        try:
            run_self_test()
        except AssertionError as exc:
            print(f"CHAPTER4_CAUSAL_ROUTE_SELF_TEST_FAIL {exc}", file=sys.stderr)
            return 1
        print("CHAPTER4_CAUSAL_ROUTE_SELF_TEST_OK cases=6")
        return 0
    try:
        ko = load_events(KO_DIR)
        en = load_events(EN_DIR)
        director = json.loads(DIRECTOR.read_text(encoding="utf-8"))
        lifecycle = json.loads(LIFECYCLE.read_text(encoding="utf-8"))
        source = MAIN_GAME.read_text(encoding="utf-8")
        errors = validate_model(ko, en, director, lifecycle, source)
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        print(f"CHAPTER4_CAUSAL_ROUTE_AUDIT_FAIL {exc}", file=sys.stderr)
        return 1
    if errors:
        print(f"CHAPTER4_CAUSAL_ROUTE_AUDIT_FAIL errors={len(errors)}")
        for error in errors:
            print(f"  ERROR {error}")
        return 1
    print(
        "CHAPTER4_CAUSAL_ROUTE_AUDIT_OK "
        "promoted_events=25 direct=15 owners=12 "
        "medical=2-of-3 contact_life_writers=0"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
