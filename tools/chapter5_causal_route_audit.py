#!/usr/bin/env python3
"""Audit the shipping M49-M55 Chapter 5 causal route (ORDER-133).

This check owns structural product evidence only.  It deliberately does not
score prose quality, infer missing receipts from legacy flags, or activate the
dormant career/startup reference reducer.
"""

from __future__ import annotations

import argparse
import copy
import hashlib
import json
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
KO_DIR = ROOT / "content" / "events"
EN_DIR = ROOT / "content" / "events_en"
LEDGER = ROOT / "content" / "meta" / "chapter5_causal_ledger.json"
LIFECYCLE = ROOT / "content" / "meta" / "event_lifecycle.json"
DIRECTOR = ROOT / "content" / "meta" / "event_director.json"
STORY_MAP = ROOT / "content" / "meta" / "story_map.json"
REFERENCE = ROOT / "content" / "meta" / "year5_reference_routes.json"
SYSTEM = ROOT / "systems" / "Chapter5CausalRoute.gd"
REFERENCE_KERNEL = ROOT / "systems" / "Year5ReferenceRouteKernel.gd"
MAIN_GAME = ROOT / "scenes" / "MainGame.gd"
STORY_MODE = ROOT / "scenes" / "StoryMode.gd"
GAME_STATE = ROOT / "autoloads" / "GameState.gd"
SCENE_TIER = ROOT / "docs" / "SCENE_TIER.md"

EXPECTED_INSTANT_LEGEND_SHA256 = (
    "70b9a867122a27f80830cf43a2e4626032ee76bf10cd16a828d4de18aa41ebc6"
)
EXPECTED_REFERENCE_KERNEL_SHA256 = (
    "ed1d386b9fb04014995f2d5f7fa947c52c66f65800f9cd2def8c7539db6f2500"
)
EXPECTED_LEDGER_ROOTS_SHA256 = (
    "6905b77050d62bb2617be710679db82be4d6e58a5b10933a7fa0935a66efef6f"
)
TEXT_FIELDS = {
    "title", "description", "text", "result_text", "speaker", "speaker_name",
}
EN_GAMEPLAY_FIELDS = {
    "effects", "cast_effects", "flags", "items_add", "items_remove",
    "set_flag", "follow_up_event", "deferred_follow_up", "choice_kind",
    "chapter5_receipt", "chapter5_receipts", "conditions", "weight", "hidden",
    "scene_tier", "direction", "background", "portrait", "cg",
}
PLACEHOLDER_RE = re.compile(r"\{[A-Za-z_][A-Za-z0-9_]*\}")


@dataclass(frozen=True)
class RouteSpec:
    month: int
    week: int
    root_id: str
    choices: int
    conditional: tuple[str, int] | None = None


ROUTES = (
    RouteSpec(49, 195, "arc_y5_contract_cover_investment", 3),
    RouteSpec(49, 196, "arc_y5_contract_reviewer_delivery_sangchul", 3),
    RouteSpec(50, 197, "arc_y5_final_push_deadline_investment", 3),
    RouteSpec(50, 200, "arc_y5_protection_boundary_daeun", 3),
    RouteSpec(51, 201, "arc_y5_burnout_check_reference", 3),
    RouteSpec(51, 203, "arc_y5_minseo_goal_cost_reference", 3),
    RouteSpec(51, 204, "arc_y5_after_goal_daeun", 3),
    RouteSpec(52, 207, "arc_y5_final_offer", 3),
    RouteSpec(52, 208, "arc_y5_final_offer_reference_delivery", 1),
    RouteSpec(53, 209, "arc_y5_jaehyuk_guarantee_request_reference", 1),
    RouteSpec(53, 210, "arc_y5_jaehyuk_return_call_reference", 3),
    RouteSpec(53, 210, "arc_y5_jaehyuk_father_document_reference", 1),
    RouteSpec(53, 211, "arc_y5_guarantee_protected_show_daeun", 3),
    RouteSpec(53, 212, "arc_y5_jaehyuk_guarantee_decision_reference", 3),
    RouteSpec(54, 215, "arc_sangchul_final_door", 3),
    RouteSpec(
        54, 216, "arc_y5_sangchul_review_receipt", 1,
        ("arc_sangchul_final_door", 0),
    ),
    RouteSpec(55, 217, "arc_y5_three_in_room", 3),
    RouteSpec(55, 219, "arc_y5_three_in_room_decision", 3),
    RouteSpec(
        55, 220, "arc_y5_room_consent_receipt", 1,
        ("arc_y5_three_in_room_decision", 1),
    ),
)
ROOT_IDS = tuple(spec.root_id for spec in ROUTES)
EXPECTED_WEEKS = tuple(spec.week for spec in ROUTES)
READ_SOURCES: dict[str, tuple[tuple[str, ...], tuple[str, ...]]] = {
    ROUTES[index].root_id: ((ROUTES[index - 1].root_id,), ())
    for index in range(1, 15)
}
READ_SOURCES.update({
    ROUTES[16].root_id: (
        (ROUTES[13].root_id, ROUTES[14].root_id, ROUTES[15].root_id),
        (ROUTES[15].root_id,),
    ),
    ROUTES[17].root_id: ((ROUTES[16].root_id,), ()),
})
CHOICE_COUNTS = {spec.root_id: spec.choices for spec in ROUTES}
W212_OUTCOMES = (
    {
        "effects": {"mental": -8, "tint": 7},
        "flags": ["arc_jaehyuk_mirror_seen", "refused_jaehyuk_guarantee"],
    },
    {
        "effects": {"mental": -15, "tint": -6},
        "flags": [
            "arc_jaehyuk_mirror_seen", "vouched_jaehyuk_guarantee",
            "jaehyuk_exploited", "crossed_line",
        ],
    },
    {
        "effects": {"mental": -5, "tint": -2},
        "flags": ["arc_jaehyuk_mirror_seen", "blocked_jaehyuk_guarantee"],
    },
)
REQUIRED_ENTRY_FLAGS = (
    "arc_sangchul_met_seen", "arc_daeun_met", "arc_minseo_02_seen",
    "arc_jaehyuk_reunion_seen", "arc_jaehyuk_aftermath_seen",
)
EXCLUDED_ENTRY_FLAGS = (
    "sangchul_reported", "sangchul_cut_ties",
    "sangchul_quietly_distanced", "daeun_let_her_go", "daeun_divorced",
    "arc_jaehyuk_mirror_seen", "refused_jaehyuk_guarantee",
    "vouched_jaehyuk_guarantee", "blocked_jaehyuk_guarantee",
    "jaehyuk_final_break",
)
ENTRY_CONTRACT = {
    "route_id": "investment_property",
    "turn": 195,
    "economic_route": "investment",
    "asset_band": "at_least_2b",
    "actor_bindings": {
        "chooser": "player",
        "proposer": "sangchul",
        "reviewer": "sangchul",
        "protected_person": "daeun",
        "guarantee_party": "jaehyuk",
        "cost_witness": "minseo",
    },
}


def load_json(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8"))


def load_events(directory: Path) -> dict[str, dict[str, Any]]:
    result: dict[str, dict[str, Any]] = {}
    for path in sorted(directory.glob("*.json")):
        raw = load_json(path)
        rows = raw.get("events", []) if isinstance(raw, dict) else raw
        if not isinstance(rows, list):
            continue
        for row in rows:
            if not isinstance(row, dict) or not str(row.get("id", "")):
                continue
            event_id = str(row["id"])
            if event_id in result:
                raise ValueError(f"duplicate event id {event_id}")
            result[event_id] = row
    return result


def placeholders(value: Any) -> set[str]:
    return set(PLACEHOLDER_RE.findall(json.dumps(value, ensure_ascii=False)))


def _choice_rows(event: dict[str, Any]) -> list[dict[str, Any]]:
    raw = event.get("choices", [])
    return [choice for choice in raw if isinstance(choice, dict)] \
        if isinstance(raw, list) else []


def validate_route_specs(errors: list[str]) -> None:
    if len(ROUTES) != 19 or len(set(ROOT_IDS)) != 19:
        errors.append("route inventory must be exactly 19 unique roots")
    if sum(spec.choices for spec in ROUTES) != 47:
        errors.append("route inventory must be exactly 47 authored choices")
    if EXPECTED_WEEKS != (
        195, 196, 197, 200, 201, 203, 204, 207, 208,
        209, 210, 210, 211, 212, 215, 216, 217, 219, 220,
    ):
        errors.append(f"route week order drifted: {EXPECTED_WEEKS}")
    conditionals = {
        spec.root_id: spec.conditional
        for spec in ROUTES if spec.conditional is not None
    }
    if conditionals != {
        "arc_y5_sangchul_review_receipt": ("arc_sangchul_final_door", 0),
        "arc_y5_room_consent_receipt": ("arc_y5_three_in_room_decision", 1),
    }:
        errors.append(f"conditional receipt inventory drifted: {conditionals}")


def validate_events(
    ko: dict[str, dict[str, Any]],
    en: dict[str, dict[str, Any]],
    errors: list[str],
) -> None:
    total_choices = 0
    for spec in ROUTES:
        ko_event = ko.get(spec.root_id)
        en_event = en.get(spec.root_id)
        if ko_event is None or en_event is None:
            errors.append(f"{spec.root_id}: missing KO/EN event pair")
            continue
        ko_choices = _choice_rows(ko_event)
        en_choices = _choice_rows(en_event)
        total_choices += len(ko_choices)
        if len(ko_choices) != spec.choices:
            errors.append(
                f"{spec.root_id}: expected {spec.choices} KO choices, "
                f"got {len(ko_choices)}"
            )
        if len(en_choices) != len(ko_choices):
            errors.append(f"{spec.root_id}: KO/EN choice-count drift")
        if placeholders(ko_event) != placeholders(en_event):
            errors.append(f"{spec.root_id}: KO/EN placeholder drift")
        if ko_event.get("weight") != 0 or ko_event.get("hidden") is not True \
                or ko_event.get("conditions") != {"min_turn": 9999}:
            errors.append(
                f"{spec.root_id}: direct ingress must preserve "
                "weight=0 hidden=true exact min_turn=9999"
            )
        if "author_only" in ko_event.get("tags", []):
            errors.append(f"{spec.root_id}: author_only tag remains")
        if "scene_tier" in ko_event or "scene_tier" in en_event:
            errors.append(
                f"{spec.root_id}: event JSON invented a scene_tier field; "
                "the formal T2 registry owns this classification"
            )
        for index, choice in enumerate(en_choices):
            leaked = EN_GAMEPLAY_FIELDS & set(choice)
            if leaked:
                errors.append(
                    f"{spec.root_id}.choices[{index}]: EN overlay owns gameplay "
                    f"fields {sorted(leaked)}"
                )
    validate_causal_reads(ko, en, errors)
    w212_choices = _choice_rows(ko.get(ROUTES[13].root_id, {}))
    if len(w212_choices) == len(W212_OUTCOMES):
        for index, (choice, expected) in enumerate(
                zip(w212_choices, W212_OUTCOMES)):
            if choice.get("effects", {}) != expected["effects"] \
                    or choice.get("flags", []) != expected["flags"]:
                errors.append(
                    f"{ROUTES[13].root_id}.choices[{index}]: singular "
                    "Jaehyuk mirror outcome drifted"
                )
    if total_choices != 47:
        errors.append(f"shipping Chapter 5 choice total is {total_choices}, expected 47")


def _valid_read_text_rows(
    rows: Any, source_ids: tuple[str, ...], label: str, errors: list[str],
) -> bool:
    if not isinstance(rows, list) or len(rows) != len(source_ids):
        errors.append(f"{label}: text row/source count drifted")
        return False
    valid = True
    for row_index, (row, source_id) in enumerate(zip(rows, source_ids)):
        expected_count = CHOICE_COUNTS[source_id]
        if not isinstance(row, list) or len(row) != expected_count \
                or any(not isinstance(text, str) or not text.strip() for text in row) \
                or len(set(row)) != expected_count:
            errors.append(
                f"{label}.texts[{row_index}]: expected {expected_count} "
                "distinct nonempty choice prefixes"
            )
            valid = False
    return valid


def validate_causal_reads(
    ko: dict[str, dict[str, Any]],
    en: dict[str, dict[str, Any]],
    errors: list[str],
) -> None:
    actual_ko = {
        event_id for event_id in ROOT_IDS
        if isinstance(ko.get(event_id), dict)
        and "chapter5_causal_reads" in ko[event_id]
    }
    actual_en = {
        event_id for event_id in ROOT_IDS
        if isinstance(en.get(event_id), dict)
        and "chapter5_causal_reads" in en[event_id]
    }
    expected_targets = set(READ_SOURCES)
    if actual_ko != expected_targets:
        errors.append(
            f"KO causal-read target set drifted: {sorted(actual_ko)}")
    if actual_en != expected_targets:
        errors.append(
            f"EN causal-read target set drifted: {sorted(actual_en)}")
    for target_id, (source_ids, optional_ids) in READ_SOURCES.items():
        ko_reads = ko.get(target_id, {}).get("chapter5_causal_reads")
        en_reads = en.get(target_id, {}).get("chapter5_causal_reads")
        if not isinstance(ko_reads, dict) or set(ko_reads) != {
            "source_event_ids", "optional_source_event_ids", "texts", "mode",
        }:
            errors.append(f"{target_id}: KO causal-read base schema drifted")
            continue
        if ko_reads.get("source_event_ids") != list(source_ids) \
                or ko_reads.get("optional_source_event_ids") != list(optional_ids) \
                or ko_reads.get("mode") != "prepend":
            errors.append(f"{target_id}: KO causal-read mapping/mode drifted")
        ko_rows_ok = _valid_read_text_rows(
            ko_reads.get("texts"), source_ids, f"{target_id}.KO", errors)
        if not isinstance(en_reads, dict) or set(en_reads) != {"texts"}:
            errors.append(
                f"{target_id}: EN overlay must own causal-read texts only")
            continue
        en_rows_ok = _valid_read_text_rows(
            en_reads.get("texts"), source_ids, f"{target_id}.EN", errors)
        if ko_rows_ok and en_rows_ok:
            ko_rows = ko_reads["texts"]
            en_rows = en_reads["texts"]
            for row_index, (ko_row, en_row) in enumerate(zip(ko_rows, en_rows)):
                if any(ko_text == en_text for ko_text, en_text in zip(ko_row, en_row)):
                    errors.append(
                        f"{target_id}.texts[{row_index}]: EN prefix did not localize")
    for event_id in (ROUTES[0].root_id, ROUTES[15].root_id, ROUTES[18].root_id):
        if "chapter5_causal_reads" in ko.get(event_id, {}) \
                or "chapter5_causal_reads" in en.get(event_id, {}):
            errors.append(f"{event_id}: non-reader root invented causal prose")


def validate_m56_payoff_order(
    story_map: Any, ko: dict[str, dict[str, Any]], errors: list[str],
) -> None:
    if not isinstance(story_map, dict):
        errors.append("story_map root must be an object")
        return
    chapter5 = next((row for row in story_map.get("chapters", [])
                     if isinstance(row, dict) and row.get("chapter") == 5), None)
    if not isinstance(chapter5, dict):
        errors.append("story_map Chapter 5 is missing")
        return
    month_rows = [row for row in chapter5.get("months", [])
                  if isinstance(row, dict)]
    month55 = next((row for row in month_rows if row.get("month") == 55), None)
    month56 = next((row for row in month_rows if row.get("month") == 56), None)
    if not isinstance(month55, dict) or not isinstance(month56, dict):
        errors.append("M55/M56 payoff boundary is missing from story_map")
        return
    roots55 = [str(beat.get("root", "")) for beat in month55.get("beats", [])
               if isinstance(beat, dict)]
    roots56 = [str(beat.get("root", "")) for beat in month56.get("beats", [])
               if isinstance(beat, dict)]
    if roots55[-3:] != list(ROOT_IDS[16:19]):
        errors.append(f"M55 causal payoff order drifted: {roots55[-3:]}")
    if not roots56 or roots56[0] != "arc_father_legacy" \
            or "M55" not in str(month56.get("contract", {}).get("pressure", "")):
        errors.append("M56 does not explicitly read the M55 decision next")
    for event_id in ROOT_IDS[17:19]:
        for choice_index, choice in enumerate(_choice_rows(ko.get(event_id, {}))):
            if choice.get("follow_up_event") or choice.get("deferred_follow_up"):
                errors.append(
                    f"{event_id}.choices[{choice_index}]: authored follow-up "
                    "bypasses the next M56 payoff"
                )


def validate_lifecycle(lifecycle: Any, errors: list[str]) -> None:
    if not isinstance(lifecycle, dict):
        errors.append("event lifecycle root must be an object")
        return
    raw = lifecycle.get("author_only_event_ids", [])
    if not isinstance(raw, list):
        errors.append("event lifecycle author_only_event_ids must be an array")
        return
    leaked = sorted(set(ROOT_IDS) & {str(value) for value in raw})
    if leaked:
        errors.append(f"promoted Chapter 5 roots remain author_only: {leaked}")


def validate_scene_tier_registry(source: str, errors: list[str]) -> None:
    heading = "ORDER-133 — M49~M55 제품 T2 레지스트리"
    if heading not in source:
        errors.append("Chapter 5 T2 registry heading is missing from SCENE_TIER")
        return
    section = source.split(heading, 1)[1].split("\n## ", 1)[0]
    declared: dict[str, str] = {}
    for line in section.splitlines():
        root_match = re.search(r"`(?P<root>arc_[^`]+)`", line)
        tier_match = re.search(
            r"\|\s*(?P<tier>조건부 T2 진입|T2 상속 링크|T2 진입)\s*\|", line)
        if root_match and tier_match:
            declared[root_match.group("root")] = tier_match.group("tier")
    expected = {root_id: "T2 진입" for root_id in ROOT_IDS}
    expected["arc_y5_jaehyuk_father_document_reference"] = "T2 상속 링크"
    expected["arc_y5_sangchul_review_receipt"] = "조건부 T2 진입"
    expected["arc_y5_room_consent_receipt"] = "조건부 T2 진입"
    if declared != expected:
        errors.append(
            "Chapter 5 T2 registry drifted: "
            f"expected={expected}, got={declared}"
        )


def _reference_counts(manifest: dict[str, Any]) -> tuple[int, int]:
    roots = 0
    choices = 0
    for route in manifest.get("routes", []):
        if not isinstance(route, dict):
            continue
        for root in route.get("roots", []):
            if not isinstance(root, dict):
                continue
            roots += 1
            raw_choices = root.get("choices", [])
            if isinstance(raw_choices, list):
                choices += len(raw_choices)
    return roots, choices


def validate_reference_manifest(manifest: Any, errors: list[str]) -> None:
    if not isinstance(manifest, dict):
        errors.append("Year 5 reference manifest root must be an object")
        return
    if manifest.get("activation") != "reference_only":
        errors.append("Year 5 reference manifest is no longer reference_only")
    roots, choices = _reference_counts(manifest)
    if (roots, choices) != (32, 86):
        errors.append(
            f"Year 5 reference population drifted: roots={roots} choices={choices}"
        )
    lifecycle = manifest.get("r1a_contract", {}).get("lifecycle", {})
    planned = manifest.get("planned_runtime", {})
    protected = manifest.get("protected_hashes", {}).get("runtime_consumers", {})
    if lifecycle.get("reference_only") is not True \
            or lifecycle.get("reachability_claim") is not False \
            or lifecycle.get("product_consumer_count") != 0:
        errors.append("Year 5 R1A lifecycle lost reference-only/product0 semantics")
    if planned.get("current_product_consumer_count") != 0:
        errors.append("Year 5 planned runtime gained a product consumer")
    if protected.get("expected_count") != 0:
        errors.append("Year 5 protected runtime consumer count is not zero")


def _function_block(source: str, function_name: str) -> str:
    marker = f"func {function_name}"
    if marker not in source:
        return ""
    return source.split(marker, 1)[1].split("\nfunc ", 1)[0]


def _instant_legend_block(source: str) -> str:
    start_marker = "\t# ── 첫해 30억 = 즉시 비밀 엔딩"
    end_marker = "\n\t# ── 일반 30억"
    if start_marker not in source:
        return ""
    start = source.index(start_marker)
    end = source.find(end_marker, start)
    return source[start:end] if end >= 0 else ""


def validate_source_contracts(
    system_source: str,
    main_source: str,
    story_source: str,
    game_state_source: str,
    reference_kernel_source: str,
    errors: list[str],
) -> None:
    instant = _instant_legend_block(game_state_source)
    digest = hashlib.sha256(instant.encode("utf-8")).hexdigest()
    if not instant or digest != EXPECTED_INSTANT_LEGEND_SHA256:
        errors.append(
            "GameState instant_legend branch changed: "
            f"expected {EXPECTED_INSTANT_LEGEND_SHA256}, got {digest}"
        )
    kernel_digest = hashlib.sha256(
        reference_kernel_source.encode("utf-8")).hexdigest()
    if kernel_digest != EXPECTED_REFERENCE_KERNEL_SHA256:
        errors.append(
            "Year5ReferenceRouteKernel changed: "
            f"expected {EXPECTED_REFERENCE_KERNEL_SHA256}, got {kernel_digest}"
        )
    if "year5_reference_routes.json" in system_source:
        errors.append("shipping Chapter 5 router reads the dormant reference manifest")
    forbidden_system_calls = (
        "finish_run(", "add_money(", "execute_transaction(",
        "Year5ReferenceRouteKernel", "year5_reference_routes",
    )
    for token in forbidden_system_calls:
        if token in system_source:
            errors.append(f"shipping Chapter 5 router owns forbidden effect: {token}")

    required_system_api = (
        "class_name Chapter5CausalRoute",
        "static func default_state()",
        "static func product_path_available(",
        "static func lock_entry(",
        "static func entry_locked(",
        "static func entry_snapshot(",
        "static func state_from_save(",
        "static func is_owned_event(",
        "static func next_event_for_turn(",
        "static func ingress_available(",
        "static func choice_commit_available(",
        "static func commit_choice(",
        "static func close_route(",
        "static func receipt_matches(",
        "static func selected_choice(",
        "static func receipt_snapshot(",
        "static func choice_count_for_event(",
        "static func event_sequence(",
        "static func expected_read_contract(",
        "static func week_completed(",
    )
    for marker in required_system_api:
        if marker not in system_source:
            errors.append(f"Chapter5CausalRoute public API missing: {marker}")
    for marker in (
        'const ENTRY_PLAYER_ROUTE := "투자형"',
        "const ENTRY_MIN_TOTAL_ASSETS := 2_000_000_000.0",
        "const ENTRY_TURN := 195",
        'const ENTRY_ROUTE_ID := "investment_property"',
        'const ENTRY_ECONOMIC_ROUTE := "investment"',
        'const ENTRY_ASSET_BAND := "at_least_2b"',
    ):
        if marker not in system_source:
            errors.append(f"Chapter5CausalRoute entry contract missing: {marker}")
    product_path_block = _function_block(system_source, "product_path_available")
    required_product_path_tokens = (
        "state: Dictionary", "player_route: String",
        "investment_identity_ready: bool", "participants_ready: bool",
        "total_assets: float", 'str(current.get("status", "")) != "open"',
        'current.get("entry", {})', "return true",
        "player_route == ENTRY_PLAYER_ROUTE", "investment_identity_ready",
        "participants_ready", "is_finite(total_assets)",
        "total_assets >= ENTRY_MIN_TOTAL_ASSETS",
    )
    for token in required_product_path_tokens:
        if token not in product_path_block:
            errors.append(f"Chapter5CausalRoute eligibility drifted: {token}")
    if product_path_block.find('current.get("entry", {})') > \
            product_path_block.find("player_route == ENTRY_PLAYER_ROUTE"):
        errors.append(
            "Chapter5CausalRoute durable-entry continuation no longer precedes live gates"
        )

    required_game_state_api = (
        'preload("res://systems/Chapter5CausalRoute.gd")',
        "var chapter5_causal_state:",
        "func _chapter5_causal_daeun_path_live()",
        "func chapter5_causal_guarantee_relocation_reserved()",
        "func _chapter5_causal_entry_participants_ready()",
        "func chapter5_causal_product_path_available()",
        "func prepare_chapter5_causal_route_entry()",
        "func chapter5_causal_entry_snapshot()",
        "func chapter5_causal_next_event_for_turn(",
        "func chapter5_causal_ingress_available(",
        "func chapter5_causal_choice_available(",
        "func record_chapter5_causal_choice(",
        "func close_chapter5_causal_route(",
        "func chapter5_causal_receipt_matches(",
        "func chapter5_causal_selected_choice(",
        "func chapter5_causal_receipt_snapshot(",
        "func chapter5_causal_choice_count(",
        "func chapter5_causal_event_sequence(",
        "func chapter5_causal_week_completed(",
        '"chapter5_causal_state": chapter5_causal_state',
        "CHAPTER5_CAUSAL_ROUTE.state_from_save(",
    )
    for marker in required_game_state_api:
        if marker not in game_state_source:
            errors.append(f"GameState Chapter 5 binding missing: {marker}")

    daeun_block = _function_block(
        game_state_source, "_chapter5_causal_daeun_path_live")
    for flag in (
        "daeun_chose_her", "daeun_together_path", "daeun_close_bond",
        "daeun_romance_started", "daeun_married",
        "daeun_final_together",
    ):
        if flag not in daeun_block:
            errors.append(f"GameState active Daeun path lost flag: {flag}")
    for flag in ("daeun_let_her_go", "daeun_divorced"):
        if not re.search(
                rf'not bool\(flags\.get\("{flag}", false\)\)', daeun_block):
            errors.append(f"GameState active Daeun path lost exclusion: {flag}")

    reserve_block = _function_block(
        game_state_source, "chapter5_causal_guarantee_relocation_reserved")
    for token in (
        "player_route == CHAPTER5_CAUSAL_ROUTE.ENTRY_PLAYER_ROUTE",
        'flags.get("route_invest", false)',
        "_chapter5_causal_daeun_path_live()",
        'flags.get("arc_jaehyuk_reunion_seen", false)',
        'flags.get("arc_jaehyuk_aftermath_seen", false)',
    ):
        if token not in reserve_block:
            errors.append(f"GameState guarantee relocation drifted: {token}")
    for flag in (
        "arc_jaehyuk_mirror_seen", "refused_jaehyuk_guarantee",
        "vouched_jaehyuk_guarantee", "blocked_jaehyuk_guarantee",
        "jaehyuk_final_break",
    ):
        if not re.search(
                rf'not bool\(flags\.get\("{flag}", false\)\)', reserve_block):
            errors.append(f"GameState guarantee relocation lost unresolved guard: {flag}")
    for forbidden in (
        "get_total_asset_value", "arc_sangchul_met_seen", "arc_minseo_02_seen",
    ):
        if forbidden in reserve_block:
            errors.append(
                f"GameState W209 fallback reservation gained entry-only gate: {forbidden}"
            )

    participant_block = _function_block(
        game_state_source, "_chapter5_causal_entry_participants_ready")
    for flag in REQUIRED_ENTRY_FLAGS:
        if flag not in participant_block and flag not in reserve_block \
                and flag not in daeun_block:
            errors.append(f"GameState Chapter 5 participant gate lost flag: {flag}")
    for flag in EXCLUDED_ENTRY_FLAGS:
        if flag not in participant_block and flag not in reserve_block \
                and flag not in daeun_block:
            errors.append(f"GameState Chapter 5 participant gate lost exclusion: {flag}")
    if "chapter5_causal_guarantee_relocation_reserved()" not in participant_block:
        errors.append("GameState product ingress does not consume unresolved mirror reserve")

    product_wrapper_block = _function_block(
        game_state_source, "chapter5_causal_product_path_available")
    for token in (
        "CHAPTER5_CAUSAL_ROUTE.product_path_available(", "player_route",
        'flags.get("route_invest", false)',
        "_chapter5_causal_entry_participants_ready()", "get_total_asset_value()",
    ):
        if token not in product_wrapper_block:
            errors.append(f"GameState Chapter 5 product wrapper drifted: {token}")
    prepare_entry_block = _function_block(
        game_state_source, "prepare_chapter5_causal_route_entry")
    for token in (
        "CHAPTER5_CAUSAL_ROUTE.lock_entry(", "int(turn)", "player_route",
        'flags.get("route_invest", false)',
        "_chapter5_causal_entry_participants_ready()", "get_total_asset_value()",
    ):
        if token not in prepare_entry_block:
            errors.append(f"GameState durable entry lock drifted: {token}")
    record_entry_block = _function_block(
        game_state_source, "record_chapter5_causal_choice")
    for token in (
        "var candidate_state := chapter5_causal_state.duplicate(true)",
        "CHAPTER5_CAUSAL_ROUTE.entry_locked(candidate_state)",
        "CHAPTER5_CAUSAL_ROUTE.lock_entry(",
        "CHAPTER5_CAUSAL_ROUTE.commit_choice(",
        "candidate_state, event_id, choice_index, turn",
        'if bool(result.get("ok", false)):',
    ):
        if token not in record_entry_block:
            errors.append(f"GameState atomic entry+receipt callback drifted: {token}")
    for function_name in (
        "chapter5_causal_next_event_for_turn", "chapter5_causal_ingress_available",
        "chapter5_causal_choice_available", "record_chapter5_causal_choice",
        "chapter5_causal_week_completed",
    ):
        if "chapter5_causal_product_path_available()" not in _function_block(
                game_state_source, function_name):
            errors.append(
                f"GameState {function_name} bypasses product eligibility"
            )

    record_block = _function_block(
        game_state_source, "record_chapter5_causal_choice")
    for token in ("money", "action_points", "finish_run", "transaction"):
        if token in record_block:
            errors.append(
                f"GameState Chapter 5 receipt wrapper owns forbidden effect: {token}"
            )
    close_block = _function_block(game_state_source, "close_chapter5_causal_route")
    for token in ("money", "action_points", "finish_run", "transaction"):
        if token in close_block:
            errors.append(
                f"GameState Chapter 5 close wrapper owns forbidden effect: {token}"
            )

    # Source-level bindings are intentionally broad.  The executable Godot
    # check owns exact API and state-shape evidence once the public router is
    # loaded; this layer only blocks an unbound implementation.
    for owner, source in (("MainGame", main_source), ("StoryMode", story_source)):
        if "Chapter5CausalRoute" not in source:
            errors.append(f"{owner} does not bind Chapter5CausalRoute")
    main_markers = (
        "func _route_chapter5_causal_week(",
        "func _complete_chapter5_causal_week_after_story(",
        "GameState.chapter5_causal_next_event_for_turn()",
        "GameState.chapter5_causal_week_completed()",
        "_demo_director_finish_auto_week()",
        "GameState.prepare_chapter5_causal_route_entry()",
    )
    for marker in main_markers:
        if marker not in main_source:
            errors.append(f"MainGame direct-week ownership missing: {marker}")
    begin_block = _function_block(main_source, "_begin_month_story_and_render")
    if not begin_block or begin_block.find("_route_chapter5_causal_week") > \
            begin_block.find("_route_opening_chapter_if_pending"):
        errors.append("MainGame does not give Chapter 5 the foreground week first")
    route_block = _function_block(main_source, "_route_chapter5_causal_week")
    if route_block.find("prepare_chapter5_causal_route_entry()") < 0 \
            or route_block.find("prepare_chapter5_causal_route_entry()") > \
            route_block.find("chapter5_causal_next_event_for_turn()"):
        errors.append("MainGame displays W195 before locking its durable entry context")
    deferred_block = _function_block(
        main_source, "_deferred_foreground_event_id")
    deferred_reservation_pattern = (
        r'if event_id == "arc_jaehyuk_mirror"\s*\\\s*'
        r'and GameState\.chapter5_causal_guarantee_relocation_reserved\(\)\s*\\\s*'
        r'and \(GameState\.turn < 209\s*\\\s*'
        r'or not GameState\.chapter5_causal_entry_snapshot\(\)\.is_empty\(\)\):'
        r'\s+continue'
    )
    if not re.search(deferred_reservation_pattern, deferred_block):
        errors.append(
            "MainGame does not hold the singular deferred Jaehyuk mirror "
            "before W209 or while the relocated product entry owns it"
        )
    next_arc_block = _function_block(main_source, "_next_arc_id")
    for token in (
        "var jaehyuk_mirror_min_turn := 209",
        "GameState.chapter5_causal_guarantee_relocation_reserved()",
        "t >= jaehyuk_mirror_min_turn",
        'return "arc_jaehyuk_mirror"',
    ):
        if token not in next_arc_block:
            errors.append(f"MainGame W209 singular-mirror fallback drifted: {token}")
    for flag in (
        "arc_jaehyuk_aftermath_seen", "arc_jaehyuk_mirror_seen",
        "refused_jaehyuk_guarantee", "vouched_jaehyuk_guarantee",
        "blocked_jaehyuk_guarantee",
    ):
        if flag not in next_arc_block:
            errors.append(f"MainGame old mirror duplicate guard lost flag: {flag}")
    for minseo_event_id in (
        "arc_minseo_03_arrival", "arc_minseo_03b_not_arrived",
    ):
        return_marker = f'return "{minseo_event_id}"'
        return_index = next_arc_block.find(return_marker)
        condition_index = next_arc_block.rfind("\n\tif ", 0, return_index)
        if return_index < 0 or condition_index < 0 \
                or "not GameState.chapter5_causal_product_path_available()" \
                not in next_arc_block[condition_index:return_index]:
            errors.append(
                f"MainGame locked product route can duplicate generic {minseo_event_id}"
            )
    story_markers = (
        "func _chapter5_causal_live_ingress_allowed(",
        "func _queue_chapter5_same_turn_ingress(",
        "GameState.chapter5_causal_choice_available(",
        "GameState.record_chapter5_causal_choice(",
        "GameState.chapter5_causal_receipt_matches(",
        "func _chapter5_causal_event_with_reads(",
        "GameState.chapter5_causal_receipt_snapshot(",
        "GameState.chapter5_causal_selected_choice(",
        "GameState.close_chapter5_causal_route(",
        "CLOSE_REASON_READ_SURFACE_INVALID",
        "if event.is_empty() or _read_only_replay:",
        "chapter5_choice_snapshot",
    )
    for marker in story_markers:
        if marker not in story_source:
            errors.append(f"StoryMode Chapter 5 transaction missing: {marker}")
    variant_close_patterns = (
        r"if _current\.is_empty\(\):\s+"
        r"_close_chapter5_causal_invalid_read_surface\(event_id\)",
        r"if live_event_id\.is_empty\(\):\s+"
        r"_close_chapter5_causal_invalid_read_surface\(event_id\)",
    )
    for pattern in variant_close_patterns:
        if not re.search(pattern, story_source, re.S):
            errors.append(
                "StoryMode owned empty/different live variant lacks canonical close")
    # ORDER-134 shares this fail-closed branch with the finale ledger.  Keep
    # the old causal owner explicit: broadening the guard must never let an
    # M49~M55 source variant bypass its canonical close.
    combined_variant_guard = (
        r"if live_event_id != event_id:.*?"
        r"if CHAPTER5_CAUSAL_ROUTE\.is_owned_event\(event_id\)\s*"
        r"(?:\\\s*or\s+CHAPTER5_FINALE_ROUTE\.is_owned_event\(event_id\))?\s*:"
        r"\s+_close_chapter5_causal_invalid_read_surface\(event_id\)"
    )
    if not re.search(combined_variant_guard, story_source, re.S):
        errors.append(
            "StoryMode owned empty/different live variant lacks canonical close")
    missing_literals = [root_id for root_id in ROOT_IDS if root_id not in (
        system_source + main_source
    )]
    if missing_literals:
        errors.append(f"Chapter 5 direct router lacks roots: {missing_literals}")


def validate_ledger(ledger: Any, errors: list[str]) -> None:
    if not isinstance(ledger, dict):
        errors.append("Chapter 5 causal ledger root must be an object")
        return
    if set(ledger) != {
        "schema_version", "ledger_id", "choice_index_base",
        "expected_root_count", "expected_choice_count", "entry_contract", "roots",
    }:
        errors.append("Chapter 5 causal ledger top-level schema drifted")
    if ledger.get("schema_version") != 1 \
            or ledger.get("ledger_id") != "chapter5_m49_m55_causal_route_v1" \
            or ledger.get("choice_index_base") != 0 \
            or ledger.get("expected_root_count") != 19 \
            or ledger.get("expected_choice_count") != 47:
        errors.append("Chapter 5 causal ledger schema/id/count declaration drifted")
    if ledger.get("entry_contract") != ENTRY_CONTRACT:
        errors.append("Chapter 5 causal ledger durable entry contract drifted")
    rows = ledger.get("roots", [])
    if not isinstance(rows, list) or not all(
            isinstance(row, dict) for row in rows):
        errors.append("Chapter 5 causal ledger roots must be an object array")
        return
    if len(rows) != 19:
        errors.append(f"Chapter 5 causal ledger must contain 19 roots, got {len(rows)}")
        return
    roots_digest = hashlib.sha256(json.dumps(
        rows, ensure_ascii=False, sort_keys=True, separators=(",", ":"),
    ).encode("utf-8")).hexdigest()
    if roots_digest != EXPECTED_LEDGER_ROOTS_SHA256:
        errors.append(
            "Chapter 5 causal ledger actor/document/receipt bytes drifted: "
            f"{roots_digest}"
        )
    actual_ids = [str(row.get("event_id", "")) for row in rows]
    if actual_ids != list(ROOT_IDS):
        errors.append(f"Chapter 5 causal ledger root order drifted: {actual_ids}")
    total_choices = 0
    receipt_ids: set[str] = set()
    for spec, row in zip(ROUTES, rows):
        if set(row) != {
            "sequence", "month", "turn", "week", "event_id", "root_id",
            "choice_count", "tier", "actor_bindings", "condition",
            "requires_choice", "choices",
        }:
            errors.append(f"{spec.root_id}: ledger root schema drifted")
        if int(row.get("month", -1)) != spec.month \
                or int(row.get("turn", -1)) != spec.week \
                or int(row.get("week", -1)) != spec.week \
                or str(row.get("root_id", "")) != spec.root_id \
                or int(row.get("choice_count", -1)) != spec.choices \
                or str(row.get("tier", "")) != "T2":
            errors.append(
                f"{spec.root_id}: ledger exact M/W/id/count/T2 contract drifted"
            )
        actors = row.get("actor_bindings")
        if not isinstance(actors, dict) or actors.get("chooser") != "player" \
                or any(not isinstance(key, str) or not isinstance(value, str)
                       or not key or not value for key, value in actors.items()):
            errors.append(f"{spec.root_id}: actor bindings are malformed")
        raw_choices = row.get("choices")
        if not isinstance(raw_choices, list) or len(raw_choices) != spec.choices:
            errors.append(
                f"{spec.root_id}: ledger expected {spec.choices} choices, "
                f"got {len(raw_choices) if isinstance(raw_choices, list) else 'invalid'}"
            )
            raw_choices = []
        total_choices += len(raw_choices)
        for choice_index, choice in enumerate(raw_choices):
            if not isinstance(choice, dict) \
                    or set(choice) != {"index", "receipts"} \
                    or choice.get("index") != choice_index \
                    or not isinstance(choice.get("receipts"), list) \
                    or not choice["receipts"]:
                errors.append(
                    f"{spec.root_id}.choices[{choice_index}]: schema drifted"
                )
                continue
            for receipt in choice["receipts"]:
                if not isinstance(receipt, dict) or set(receipt) != {
                    "receipt_type", "receipt_id", "document_ids",
                } or not isinstance(receipt.get("receipt_type"), str) \
                        or not receipt.get("receipt_type") \
                        or not isinstance(receipt.get("receipt_id"), str) \
                        or not receipt.get("receipt_id") \
                        or not isinstance(receipt.get("document_ids"), list) \
                        or not receipt.get("document_ids") \
                        or any(not isinstance(document_id, str) or not document_id
                               for document_id in receipt.get("document_ids", [])):
                    errors.append(
                        f"{spec.root_id}.choices[{choice_index}]: malformed "
                        "document/custody receipt"
                    )
                    continue
                receipt_id = str(receipt["receipt_id"])
                if receipt_id in receipt_ids:
                    errors.append(f"duplicate Chapter 5 receipt id: {receipt_id}")
                receipt_ids.add(receipt_id)
        conditional = row.get("condition")
        if row.get("requires_choice") != conditional:
            errors.append(f"{spec.root_id}: requires_choice alias drifted")
        if spec.conditional is None:
            if conditional is not None:
                errors.append(f"{spec.root_id}: invented conditional ingress")
        elif not isinstance(conditional, dict) \
                or set(conditional) != {"event_id", "choice_index"} \
                or str(conditional.get("event_id", "")) != spec.conditional[0] \
                or int(conditional.get("choice_index", -1)) != spec.conditional[1]:
            errors.append(f"{spec.root_id}: conditional choice contract drifted")
    if total_choices != 47 or len(receipt_ids) != 47:
        errors.append(
            f"Chapter 5 causal ledger population drifted: "
            f"choices={total_choices} unique_receipts={len(receipt_ids)}"
        )


def validate_model(
    ko: dict[str, dict[str, Any]],
    en: dict[str, dict[str, Any]],
    ledger: Any,
    lifecycle: Any,
    reference: Any,
    story_map: Any,
    system_source: str,
    main_source: str,
    story_source: str,
    game_state_source: str,
    scene_tier_source: str,
    reference_kernel_source: str,
) -> list[str]:
    errors: list[str] = []
    validate_route_specs(errors)
    validate_events(ko, en, errors)
    validate_ledger(ledger, errors)
    validate_lifecycle(lifecycle, errors)
    validate_scene_tier_registry(scene_tier_source, errors)
    validate_reference_manifest(reference, errors)
    validate_m56_payoff_order(story_map, ko, errors)
    validate_source_contracts(
        system_source, main_source, story_source, game_state_source,
        reference_kernel_source, errors,
    )
    return errors


def _fixture_events(author_only: bool = False) -> tuple[
    dict[str, dict[str, Any]], dict[str, dict[str, Any]]
]:
    ko: dict[str, dict[str, Any]] = {}
    en: dict[str, dict[str, Any]] = {}
    for spec in ROUTES:
        tags = ["story", "arc", "chapter5"]
        if author_only:
            tags.append("author_only")
        ko[spec.root_id] = {
            "id": spec.root_id,
            "title": "장면",
            "description": "{name}의 문서",
            "weight": 0,
            "hidden": True,
            "conditions": {"min_turn": 9999},
            "tags": tags,
            "choices": [
                {"text": f"선택 {index}", "result_text": "결과"}
                for index in range(spec.choices)
            ],
        }
        en[spec.root_id] = {
            "id": spec.root_id,
            "title": "Scene",
            "description": "{name}'s document",
            "choices": [
                {"text": f"Choice {index}", "result_text": "Result"}
                for index in range(spec.choices)
            ],
        }
    for index, expected in enumerate(W212_OUTCOMES):
        ko[ROUTES[13].root_id]["choices"][index].update(copy.deepcopy(expected))
    for target_id, (source_ids, optional_ids) in READ_SOURCES.items():
        ko[target_id]["chapter5_causal_reads"] = {
            "source_event_ids": list(source_ids),
            "optional_source_event_ids": list(optional_ids),
            "texts": [
                [f"{source_id} 선택 {index}" for index in range(CHOICE_COUNTS[source_id])]
                for source_id in source_ids
            ],
            "mode": "prepend",
        }
        en[target_id]["chapter5_causal_reads"] = {
            "texts": [
                [f"{source_id} choice {index}" for index in range(CHOICE_COUNTS[source_id])]
                for source_id in source_ids
            ],
        }
    return ko, en


def run_self_test() -> int:
    cases = 0

    def check(condition: bool, message: str) -> None:
        nonlocal cases
        cases += 1
        if not condition:
            raise AssertionError(message)

    errors: list[str] = []
    validate_route_specs(errors)
    check(not errors, errors[0] if errors else "valid route inventory rejected")

    ko, en = _fixture_events()
    errors = []
    validate_events(ko, en, errors)
    check(not errors, errors[0] if errors else "valid event fixture rejected")

    mutated_ko = copy.deepcopy(ko)
    mutated_ko[ROOT_IDS[0]]["choices"].pop()
    errors = []
    validate_events(mutated_ko, en, errors)
    check(any("expected 3 KO choices" in error for error in errors),
          "choice-count mutation was accepted")

    tagged_ko, _ = _fixture_events(author_only=True)
    errors = []
    validate_events(tagged_ko, en, errors)
    check(any("author_only tag remains" in error for error in errors),
          "author-only mutation was accepted")

    gameplay_en = copy.deepcopy(en)
    gameplay_en[ROOT_IDS[0]]["choices"][0]["flags"] = ["invented"]
    errors = []
    validate_events(ko, gameplay_en, errors)
    check(any("EN overlay owns gameplay" in error for error in errors),
          "EN gameplay mutation was accepted")

    read_order_ko = copy.deepcopy(ko)
    target_id = ROUTES[16].root_id
    read_order_ko[target_id]["chapter5_causal_reads"]["source_event_ids"].reverse()
    errors = []
    validate_events(read_order_ko, en, errors)
    check(any("mapping/mode drifted" in error for error in errors),
          "causal-read source-order mutation was accepted")

    read_overlay_en = copy.deepcopy(en)
    read_overlay_en[ROUTES[1].root_id]["chapter5_causal_reads"]["mode"] = "prepend"
    errors = []
    validate_events(ko, read_overlay_en, errors)
    check(any("texts only" in error for error in errors),
          "EN causal-read gameplay schema mutation was accepted")

    duplicate_text_ko = copy.deepcopy(ko)
    duplicate_text_ko[ROUTES[1].root_id]["chapter5_causal_reads"]["texts"][0][1] = \
        duplicate_text_ko[ROUTES[1].root_id]["chapter5_causal_reads"]["texts"][0][0]
    errors = []
    validate_events(duplicate_text_ko, en, errors)
    check(any("distinct nonempty" in error for error in errors),
          "duplicate causal prefix mutation was accepted")

    w212_mutation = copy.deepcopy(ko)
    w212_mutation[ROUTES[13].root_id]["choices"][1]["effects"]["tint"] = -5
    errors = []
    validate_events(w212_mutation, en, errors)
    check(any("singular Jaehyuk mirror outcome drifted" in error for error in errors),
          "W212 canonical mirror mutation was accepted")

    errors = []
    validate_lifecycle({"author_only_event_ids": [ROOT_IDS[0]]}, errors)
    check(any("remain author_only" in error for error in errors),
          "lifecycle author-only mutation was accepted")

    registry_rows = "\n".join(
        f"| `{root_id}` | M49 | `W195` | "
        f"{('T2 상속 링크' if root_id == 'arc_y5_jaehyuk_father_document_reference' else ('조건부 T2 진입' if root_id in {'arc_y5_sangchul_review_receipt', 'arc_y5_room_consent_receipt'} else 'T2 진입'))} |"
        for root_id in ROOT_IDS
    )
    errors = []
    validate_scene_tier_registry(
        "## ORDER-133 — M49~M55 제품 T2 레지스트리\n" + registry_rows,
        errors,
    )
    check(not errors, errors[0] if errors else "valid T2 registry rejected")

    reference = {
        "activation": "reference_only",
        "routes": [
            {"roots": [
                *({"choices": [{}, {}, {}]} for _ in range(12)),
                *({"choices": [{}, {}]} for _ in range(3)),
                {"choices": [{}]},
            ]},
            {"roots": [
                *({"choices": [{}, {}, {}]} for _ in range(12)),
                *({"choices": [{}, {}]} for _ in range(3)),
                {"choices": [{}]},
            ]},
        ],
        "r1a_contract": {"lifecycle": {
            "reference_only": True,
            "reachability_claim": False,
            "product_consumer_count": 0,
        }},
        "planned_runtime": {"current_product_consumer_count": 0},
        "protected_hashes": {"runtime_consumers": {"expected_count": 0}},
    }
    errors = []
    validate_reference_manifest(reference, errors)
    check(not errors, errors[0] if errors else "valid reference fixture rejected")
    activated = copy.deepcopy(reference)
    activated["activation"] = "mapped"
    errors = []
    validate_reference_manifest(activated, errors)
    check(any("no longer reference_only" in error for error in errors),
          "reference activation mutation was accepted")

    game_state_source = (
        "func check_game_over():\n" +
        "\t# ── 첫해 30억 = 즉시 비밀 엔딩 ──────────────────────\n"
        "\t# 현재 자산으로 첫해 안에 30억을 만든 순간만 신화로 즉시 닫는다.\n"
        "\t# 과거 peak만으로 나중에 이 비밀 엔딩이 발동해서는 안 된다.\n"
        "\tif total_now >= 3_000_000_000:\n"
        "\t\t# ★ 히든 이스터에그 — 첫 해(33세=챕터1)에 30억은 거의 불가능한 초고속 달성.\n"
        "\t\t#   변칙 플레이(경마/투자 대박)에 대한 보상 엔딩. 인물 아크는 챕터2+라\n"
        "\t\t#   아직 아무도 못 만난 상태 → 빈 집 대신 '신화' 엔딩으로 인정해준다.\n"
        "\t\tif age <= 33:\n"
        "\t\t\tfinish_run(\"instant_legend\"); return\n"
        "\n\t# ── 일반 30억 = M60 마지막 서명 뒤 성공 엔딩"
    )
    check(
        hashlib.sha256(_instant_legend_block(game_state_source).encode()).hexdigest()
        == EXPECTED_INSTANT_LEGEND_SHA256,
        "valid instant-legend fixture rejected",
    )
    changed_ending = game_state_source.replace("age <= 33", "age <= 34")
    check(
        hashlib.sha256(_instant_legend_block(changed_ending).encode()).hexdigest()
        != EXPECTED_INSTANT_LEGEND_SHA256,
        "instant-legend mutation was accepted",
    )
    return cases


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    if args.self_test:
        try:
            cases = run_self_test()
        except AssertionError as exc:
            print(f"CHAPTER5_CAUSAL_ROUTE_SELF_TEST_FAIL {exc}", file=sys.stderr)
            return 1
        print(f"CHAPTER5_CAUSAL_ROUTE_SELF_TEST_OK cases={cases}")
        return 0
    try:
        ko = load_events(KO_DIR)
        en = load_events(EN_DIR)
        errors = validate_model(
            ko,
            en,
            load_json(LEDGER),
            load_json(LIFECYCLE),
            load_json(REFERENCE),
            load_json(STORY_MAP),
            SYSTEM.read_text(encoding="utf-8"),
            MAIN_GAME.read_text(encoding="utf-8"),
            STORY_MODE.read_text(encoding="utf-8"),
            GAME_STATE.read_text(encoding="utf-8"),
            SCENE_TIER.read_text(encoding="utf-8"),
            REFERENCE_KERNEL.read_text(encoding="utf-8"),
        )
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        print(f"CHAPTER5_CAUSAL_ROUTE_AUDIT_FAIL {exc}", file=sys.stderr)
        return 1
    if errors:
        print(f"CHAPTER5_CAUSAL_ROUTE_AUDIT_FAIL errors={len(errors)}")
        for error in errors:
            print(f"  ERROR {error}")
        return 1
    print(
        "CHAPTER5_CAUSAL_ROUTE_AUDIT_OK "
        "roots=19 choices=47 weeks=19 conditional=2 author_only_delta=-19 "
        "entry=investment/2b/participants/durable-lock continuation=entry-ratchet "
        "w119=deferred-mirror-held w209=old-mirror-fallback "
        "w202=minseo-generic-duplicate0 w212=singular-outcomes "
        "reference=32/86/product0 instant_legend=preserved"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
