#!/usr/bin/env python3
"""Audit ORDER-138's dense product-owned general Chapter 5 finale.

The established investment/property finale remains owned by
``chapter5_finale_route_audit.py``.  This checker deliberately keeps the new
general profile separate: ten authored roots/twenty-one choices in the bilingual
catalog, of which eight roots/seventeen choices belong to the typed finale
ledger and six roots/thirteen choices are active in either W220 branch.  It pins
the three exact pre-lock sources and the W211/W220/W224/W229/W234/W237/W240
authored selector spine; it does not claim to reproduce the full weekly play surface.
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
from typing import Any, Iterable


ROOT = Path(__file__).resolve().parents[1]
KO_DIR = ROOT / "content" / "events"
EN_DIR = ROOT / "content" / "events_en"
LEDGER_PATH = ROOT / "content" / "meta" / "chapter5_general_finale_ledger.json"
LIFECYCLE_PATH = ROOT / "content" / "meta" / "event_lifecycle.json"
DIRECTOR_PATH = ROOT / "content" / "meta" / "event_director.json"
STORY_MAP_PATH = ROOT / "content" / "meta" / "story_map.json"
SYSTEM_PATH = ROOT / "systems" / "Chapter5FinaleRoute.gd"
GAME_STATE_PATH = ROOT / "autoloads" / "GameState.gd"
MAIN_GAME_PATH = ROOT / "scenes" / "MainGame.gd"
STORY_MODE_PATH = ROOT / "scenes" / "StoryMode.gd"
ENDING_SYSTEM_PATH = ROOT / "systems" / "EndingSystem.gd"

LEDGER_ID = "chapter5_general_near_goal_passed_finale_v2"
ROUTE_ID = "chapter5_safe_finale"
PROFILE_ID = "general_near_goal_father_passed"
SOURCE_ROUTE_ID = "general_story"
EXPECTED_INSTANT_LEGEND_SHA256 = (
    "70b9a867122a27f80830cf43a2e4626032ee76bf10cd16a828d4de18aa41ebc6"
)
EXPECTED_PACKAGED_EVENTS = 1806
EXPECTED_SHIPPING_EVENTS = 1696

EN_GAMEPLAY_FIELDS = {
    "effects", "cast_effects", "flags", "items_add", "items_remove",
    "set_flag", "follow_up_event", "deferred_follow_up", "choice_kind",
    "conditions", "weight", "hidden", "cooldown", "tags", "background",
    "portrait", "cg", "direction", "scene_tier", "chapter5_finale_receipt",
}
ECONOMIC_EFFECT_KEYS = {
    "money", "cash", "cash_delta", "cash_delta_krw", "assets",
    "asset_delta", "asset_delta_krw", "debt", "debt_delta",
    "debt_delta_krw", "action_points", "ap", "gangnam_share",
}
PLACEHOLDER_RE = re.compile(r"\{[A-Za-z_][A-Za-z0-9_]*\}")
INLINE_SLOT_RE = re.compile(r"\[\[c5read:(\d+)\]\]")


@dataclass(frozen=True)
class RootSpec:
    event_id: str
    month: int
    turn: int
    choice_count: int
    stage: str = ""
    stage_sequence: int = 0
    variant_sequence: int = 1
    branch_value: int | None = None


@dataclass(frozen=True)
class SourceSpec:
    key: str
    event_id: str
    flag_prefix: str
    choice_count: int
    min_turn: int
    max_turn: int
    relative_path: str


ROOTS = (
    RootSpec("arc_y5_general_name_boundary_exact", 53, 211, 2),
    RootSpec("arc_y5_general_debt_memory_reconnect", 55, 220, 2),
    RootSpec(
        "arc_y5_general_father_legacy_voice_exact", 56, 224, 2,
        "father_legacy", 1, 1, 0,
    ),
    RootSpec(
        "arc_y5_general_father_legacy_cafe_exact", 56, 224, 2,
        "father_legacy", 1, 2, 1,
    ),
    RootSpec(
        "arc_y5_general_debt_memory_voice_exact", 58, 229, 2,
        "debt_memory_consequence", 2, 1, 0,
    ),
    RootSpec(
        "arc_y5_general_debt_memory_cafe_exact", 58, 229, 2,
        "debt_memory_consequence", 2, 2, 1,
    ),
    RootSpec(
        "arc_y5_general_pre_ending_summit_exact", 59, 234, 2,
        "summit", 3,
    ),
    RootSpec(
        "arc_y5_general_final_record_seal", 60, 237, 2,
        "record_disposition", 4,
    ),
    RootSpec(
        "arc_final_countdown_general_near_goal_passed", 60, 240, 2,
        "sacrifice", 5,
    ),
    RootSpec(
        "arc_y5_final_week_general_people_outbound", 60, 240, 3,
        "outbound", 6,
    ),
)
ROOT_IDS = tuple(spec.event_id for spec in ROOTS)
FINALE_ROOTS = ROOTS[2:]
FINALE_ROOT_IDS = tuple(spec.event_id for spec in FINALE_ROOTS)
EXPECTED_TIERS = {
    spec.event_id: (
        "T2" if spec.stage in {
            "father_legacy", "debt_memory_consequence", "summit",
        } else "T1"
    )
    for spec in FINALE_ROOTS
}
SOURCE_SPECS = (
    SourceSpec(
        "m51_minseo_arrival", "arc_minseo_03_arrival",
        "chapter5_general_minseo_arrival_", 2, 200, 219,
        "content/events/arc_new_characters.json",
    ),
    SourceSpec(
        "w211_name_boundary",
        "arc_y5_general_name_boundary_exact",
        "chapter5_general_name_boundary_", 2, 211, 211,
        "content/events/arc_pre_ending.json",
    ),
    SourceSpec(
        "w220_debt_memory_reconnect",
        "arc_y5_general_debt_memory_reconnect",
        "chapter5_general_debt_memory_reconnect_", 2, 220, 220,
        "content/events/arc_pre_ending.json",
    ),
)
SOURCE_BY_KEY = {spec.key: spec for spec in SOURCE_SPECS}
EXPECTED_SOURCE_READ_KEYS = {
    "arc_y5_general_name_boundary_exact": (
        "chapter5_general_minseo_arrival_0",
        "chapter5_general_minseo_arrival_1",
    ),
    "arc_y5_general_debt_memory_reconnect": (
        "chapter5_general_name_boundary_0",
        "chapter5_general_name_boundary_1",
    ),
}
EXPECTED_STAGES = [
    "father_legacy", "debt_memory_consequence", "summit",
    "record_disposition", "sacrifice", "outbound",
]
EXPECTED_ACTORS = {
    "chooser": "player", "father": "father", "cost_witness": "minseo",
}
EXPECTED_ROOT_ACTORS = {
    "arc_y5_general_father_legacy_voice_exact": {
        "chooser": "player", "father": "father",
    },
    "arc_y5_general_father_legacy_cafe_exact": {
        "chooser": "player", "father": "father",
    },
    "arc_y5_general_debt_memory_voice_exact": {"chooser": "player"},
    "arc_y5_general_debt_memory_cafe_exact": {"chooser": "player"},
    "arc_y5_general_pre_ending_summit_exact": {
        "chooser": "player", "father": "father",
    },
    "arc_y5_general_final_record_seal": EXPECTED_ACTORS,
    "arc_final_countdown_general_near_goal_passed": {
        "chooser": "player", "father": "father",
    },
    "arc_y5_final_week_general_people_outbound": EXPECTED_ACTORS,
}
EXPECTED_LEDGER_CHOICE_BINDINGS = {
    "arc_y5_general_father_legacy_voice_exact": (
        ("m56_general_father_legacy_voice_spoken",
         "Y5-GENERAL-FATHER-LEGACY-VOICE-SPOKEN"),
        ("m56_general_father_legacy_voice_silence_beside_chair",
         "Y5-GENERAL-FATHER-LEGACY-VOICE-SILENCE-BESIDE-CHAIR"),
    ),
    "arc_y5_general_father_legacy_cafe_exact": (
        ("m56_general_father_legacy_cafe_copy_read_aloud",
         "Y5-GENERAL-FATHER-LEGACY-CAFE-COPY-READ-ALOUD"),
        ("m56_general_father_legacy_cafe_copy_left_folded_in_silence",
         "Y5-GENERAL-FATHER-LEGACY-CAFE-COPY-LEFT-FOLDED-IN-SILENCE"),
    ),
    "arc_y5_general_debt_memory_voice_exact": (
        ("m58_general_voice_memo_kept_private",
         "Y5-GENERAL-VOICE-MEMO-KEPT-PRIVATE"),
        ("m58_general_voice_memo_deleted_timestamp_kept",
         "Y5-GENERAL-VOICE-MEMO-DELETED-TIMESTAMP-KEPT"),
    ),
    "arc_y5_general_debt_memory_cafe_exact": (
        ("m58_general_cafe_copy_carried_forward",
         "Y5-GENERAL-CAFE-COPY-CARRIED-FORWARD"),
        ("m58_general_cafe_copy_left_with_father_record",
         "Y5-GENERAL-CAFE-COPY-LEFT-WITH-FATHER-RECORD"),
    ),
    "arc_y5_general_pre_ending_summit_exact": (
        ("m59_general_summit_father_contact_opened",
         "Y5-GENERAL-SUMMIT-FATHER-CONTACT"),
        ("m59_general_summit_one_block_walked",
         "Y5-GENERAL-SUMMIT-ONE-BLOCK"),
    ),
    "arc_y5_general_final_record_seal": (
        ("m60_general_record_disposition_people_night",
         "Y5-GENERAL-RECORD-DISPOSITION-PEOPLE-NIGHT"),
        ("m60_general_record_disposition_price_night",
         "Y5-GENERAL-RECORD-DISPOSITION-PRICE-NIGHT"),
    ),
    "arc_final_countdown_general_near_goal_passed": (
        ("m60_general_sacrifice_addresses",
         "Y5-GENERAL-SACRIFICE-ADDRESSES"),
        ("m60_general_sacrifice_target",
         "Y5-GENERAL-SACRIFICE-TARGET"),
    ),
    "arc_y5_final_week_general_people_outbound": (
        ("m60_general_outbound_minseo_answer_sent",
         "Y5-GENERAL-FINAL-OUTBOUND-MINSEO"),
        ("m60_general_outbound_father_record_sentence",
         "Y5-GENERAL-FINAL-OUTBOUND-FATHER-RECORD"),
        ("m60_general_outbound_minseo_next_week_time_sent",
         "Y5-GENERAL-FINAL-OUTBOUND-NEXT-WEEK"),
    ),
}
EXPECTED_READ_SOURCES = {
    "arc_y5_general_father_legacy_voice_exact": [
        {"kind": "entry_value", "path": "source_choices.w220_debt_memory_reconnect", "values": [0, 1]},
    ],
    "arc_y5_general_father_legacy_cafe_exact": [
        {"kind": "entry_value", "path": "source_choices.w220_debt_memory_reconnect", "values": [0, 1]},
    ],
    "arc_y5_general_debt_memory_voice_exact": [
        {"kind": "finale_stage", "id": "father_legacy"},
    ],
    "arc_y5_general_debt_memory_cafe_exact": [
        {"kind": "finale_stage", "id": "father_legacy"},
    ],
    "arc_y5_general_pre_ending_summit_exact": [
        {"kind": "finale_stage", "id": "debt_memory_consequence"},
    ],
    "arc_y5_general_final_record_seal": [
        {"kind": "finale_stage", "id": "father_legacy"},
        {"kind": "finale_stage", "id": "debt_memory_consequence"},
        {"kind": "finale_stage", "id": "summit"},
    ],
    "arc_final_countdown_general_near_goal_passed": [
        {"kind": "finale_stage", "id": "record_disposition"},
    ],
    "arc_y5_final_week_general_people_outbound": [
        {"kind": "finale_stage", "id": "sacrifice"},
        {"kind": "entry_value", "path": "source_choices.m51_minseo_arrival", "values": [0, 1]},
        {"kind": "finale_stage", "id": "father_legacy"},
    ],
}
EXPECTED_READ_MODES = {
    spec.event_id: (
        "inline_slots" if spec.stage_sequence <= 4 else "prepend"
    )
    for spec in FINALE_ROOTS
}
EXPECTED_BRANCH_CONDITION = {
    spec.event_id: (
        {
            "entry_path": "source_choices.w220_debt_memory_reconnect",
            "equals": spec.branch_value,
        }
        if spec.branch_value is not None else None
    )
    for spec in FINALE_ROOTS
}
EXPECTED_EVENT_FLAGS = {
    "arc_y5_general_name_boundary_exact": (
        ["arc_y5_general_name_boundary_exact_seen", "chapter5_general_name_boundary_0"],
        ["arc_y5_general_name_boundary_exact_seen", "chapter5_general_name_boundary_1"],
    ),
    "arc_y5_general_father_legacy_voice_exact": (
        ["arc_y5_general_father_legacy_voice_exact_seen", "arc_father_legacy_seen", "chapter5_general_father_legacy_0"],
        ["arc_y5_general_father_legacy_voice_exact_seen", "arc_father_legacy_seen", "chapter5_general_father_legacy_1"],
    ),
    "arc_y5_general_father_legacy_cafe_exact": (
        ["arc_y5_general_father_legacy_cafe_exact_seen", "arc_father_legacy_seen", "chapter5_general_father_legacy_0"],
        ["arc_y5_general_father_legacy_cafe_exact_seen", "arc_father_legacy_seen", "chapter5_general_father_legacy_1"],
    ),
    "arc_y5_general_debt_memory_voice_exact": (
        ["arc_y5_general_debt_memory_voice_exact_seen", "chapter5_general_debt_memory_voice_0"],
        ["arc_y5_general_debt_memory_voice_exact_seen", "chapter5_general_debt_memory_voice_1"],
    ),
    "arc_y5_general_debt_memory_cafe_exact": (
        ["arc_y5_general_debt_memory_cafe_exact_seen", "chapter5_general_debt_memory_cafe_0"],
        ["arc_y5_general_debt_memory_cafe_exact_seen", "chapter5_general_debt_memory_cafe_1"],
    ),
    "arc_y5_general_pre_ending_summit_exact": (
        ["arc_y5_general_pre_ending_summit_exact_seen", "arc_pre_ending_summit_seen", "chapter5_general_summit_0"],
        ["arc_y5_general_pre_ending_summit_exact_seen", "arc_pre_ending_summit_seen", "chapter5_general_summit_1"],
    ),
}
EXPECTED_SACRIFICE_FLAGS = (
    ["arc_final_countdown_seen"],
    ["arc_final_countdown_seen"],
)
EXPECTED_OUTBOUND_FLAGS = (["arc_final_week_seen"],) * 3


def load_json(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8"))


def load_events(
    directory: Path,
) -> tuple[dict[str, dict[str, Any]], dict[str, str]]:
    events: dict[str, dict[str, Any]] = {}
    paths: dict[str, str] = {}
    for path in sorted(directory.glob("*.json")):
        raw = load_json(path)
        rows = raw.get("events", []) if isinstance(raw, dict) else raw
        if not isinstance(rows, list):
            continue
        for row in rows:
            if not isinstance(row, dict) or not str(row.get("id", "")):
                continue
            event_id = str(row["id"])
            if event_id in events:
                raise ValueError(f"duplicate event id {event_id}")
            events[event_id] = row
            paths[event_id] = path.relative_to(ROOT).as_posix()
    return events, paths


def choices(event: Any) -> list[dict[str, Any]]:
    if not isinstance(event, dict) or not isinstance(event.get("choices"), list):
        return []
    return [choice for choice in event["choices"] if isinstance(choice, dict)]


def placeholders(value: Any) -> set[str]:
    return set(PLACEHOLDER_RE.findall(json.dumps(value, ensure_ascii=False)))


def function_block(source: str, function_name: str) -> str:
    marker = f"func {function_name}"
    if marker not in source:
        return ""
    return source.split(marker, 1)[1].split("\nfunc ", 1)[0]


def const_array(source: str, const_name: str) -> list[str]:
    match = re.search(
        rf"const\s+{re.escape(const_name)}[^=]*=\s*\[(.*?)\n\]",
        source,
        re.S,
    )
    return re.findall(r'"([^"]+)"', match.group(1)) if match else []


def instant_legend_block(source: str) -> str:
    start_marker = "\t# ── 첫해 30억 = 즉시 비밀 엔딩"
    end_marker = "\n\t# ── 일반 30억"
    if start_marker not in source:
        return ""
    start = source.index(start_marker)
    end = source.find(end_marker, start)
    return source[start:end] if end >= 0 else ""


def validate_inventory(errors: list[str]) -> None:
    if len(ROOTS) != 10 or len(set(ROOT_IDS)) != 10:
        errors.append("general authored inventory must be exactly 10 unique roots")
    if sum(spec.choice_count for spec in ROOTS) != 21:
        errors.append("general authored inventory must be exactly 21 choices")
    if len(FINALE_ROOTS) != 8 or sum(
            spec.choice_count for spec in FINALE_ROOTS) != 17:
        errors.append("general finale ledger inventory must be exactly 8 roots/17 choices")
    active = [
        spec for spec in FINALE_ROOTS
        if spec.variant_sequence == 1 or spec.stage_sequence > 2
    ]
    if len(active) != 6 or sum(spec.choice_count for spec in active) != 13:
        errors.append("general finale active inventory must be exactly 6 roots/13 choices")
    active_surface = list(ROOTS[:2]) + active
    if len(active_surface) != 8 or sum(
            spec.choice_count for spec in active_surface) != 17:
        errors.append("general active authored surface must be exactly 8 roots/17 choices")
    if [spec.turn for spec in ROOTS] != [
            211, 220, 224, 224, 229, 229, 234, 237, 240, 240]:
        errors.append("general authored turn order drifted")


def validate_retired_w229_absent(
    events: dict[str, dict[str, Any]],
    locale: str,
    errors: list[str],
) -> None:
    if "arc_y5_general_last_page_instruction" in events:
        errors.append(
            f"removed W229 general source root remains in the {locale} catalog")
    old_prefix = "chapter5_general_last_page_instruction_"
    for event_id, event in events.items():
        for index, choice in enumerate(choices(event)):
            flags = choice.get("flags", [])
            if isinstance(flags, list) and any(
                    isinstance(flag, str) and flag.startswith(old_prefix)
                    for flag in flags):
                errors.append(
                    f"{locale}:{event_id}.choices[{index}]: "
                    "removed W229 source flag remains")


def validate_source_producers(
    ko: dict[str, dict[str, Any]],
    ko_paths: dict[str, str],
    errors: list[str],
) -> None:
    validate_retired_w229_absent(ko, "KO", errors)

    occurrences: dict[str, list[tuple[str, int]]] = {}
    all_prefixes = tuple(spec.flag_prefix for spec in SOURCE_SPECS)
    for event_id, event in ko.items():
        for index, choice in enumerate(choices(event)):
            flags = choice.get("flags", [])
            if not isinstance(flags, list):
                continue
            for flag in flags:
                if isinstance(flag, str) and flag.startswith(all_prefixes):
                    occurrences.setdefault(flag, []).append((event_id, index))

    for spec in SOURCE_SPECS:
        event = ko.get(spec.event_id)
        label = f"source {spec.key}:{spec.event_id}"
        if not isinstance(event, dict):
            errors.append(f"{label}: KO producer is missing")
            continue
        if ko_paths.get(spec.event_id) != spec.relative_path:
            errors.append(
                f"{label}: source file drifted expected={spec.relative_path!r} "
                f"actual={ko_paths.get(spec.event_id)!r}")
        rows = choices(event)
        if len(rows) != spec.choice_count:
            errors.append(
                f"{label}: expected {spec.choice_count} choices, got {len(rows)}")
            continue
        domain_flags = {
            f"{spec.flag_prefix}{index}" for index in range(spec.choice_count)
        }
        for index, choice in enumerate(rows):
            flags = choice.get("flags", [])
            selected = domain_flags & set(flags if isinstance(flags, list) else [])
            expected = {f"{spec.flag_prefix}{index}"}
            if selected != expected:
                errors.append(
                    f"{label}.choices[{index}]: exact source flag mismatch "
                    f"expected={sorted(expected)} got={sorted(selected)}")
            for flag in expected:
                if occurrences.get(flag) != [(spec.event_id, index)]:
                    errors.append(
                        f"{flag}: must have exactly one producer at "
                        f"{spec.event_id}.choices[{index}]")


def validate_source_consumers(
    ko: dict[str, dict[str, Any]],
    en: dict[str, dict[str, Any]],
    errors: list[str],
) -> None:
    """Pin the exact M51 -> W211 -> W220 prose-reader chain."""
    for event_id, expected_key_tuple in EXPECTED_SOURCE_READ_KEYS.items():
        expected_keys = set(expected_key_tuple)
        for locale, catalog in (("KO", ko), ("EN", en)):
            event = catalog.get(event_id, {})
            reads = event.get("description_memory_if_known") \
                if isinstance(event, dict) else None
            if not isinstance(reads, dict) or set(reads) != expected_keys:
                errors.append(
                    f"{event_id}:{locale}: exact source prose-reader keys drifted")
                continue
            values = list(reads.values())
            if any(not isinstance(value, str) or not value.strip()
                   for value in values) or len(set(values)) != 2:
                errors.append(
                    f"{event_id}:{locale}: source prose branches must be "
                    "two distinct nonempty strings")


def validate_preserved_generic_roots(
    ko: dict[str, dict[str, Any]],
    en: dict[str, dict[str, Any]],
    errors: list[str],
) -> None:
    for event_id, count in {
        "arc_father_legacy": 3,
        "arc_pre_ending_summit": 2,
    }.items():
        if len(choices(ko.get(event_id))) != count \
                or len(choices(en.get(event_id))) != count:
            errors.append(
                f"preserved generic root {event_id} must remain bilingual "
                f"with exactly {count} choices")
        if event_id in FINALE_ROOT_IDS:
            errors.append(f"preserved generic root became finale-owned: {event_id}")


def _expected_source_choice_count(source: dict[str, Any]) -> int:
    if source.get("kind") == "entry_value":
        values = source.get("values")
        return len(values) if isinstance(values, list) else -1
    if source.get("kind") == "finale_stage":
        stage = str(source.get("id", ""))
        mapping = {spec.stage: spec.choice_count for spec in FINALE_ROOTS}
        return mapping.get(stage, -1)
    return -1


def validate_finale_reads(
    ko: dict[str, dict[str, Any]],
    en: dict[str, dict[str, Any]],
    errors: list[str],
) -> None:
    for root_id in FINALE_ROOT_IDS:
        ko_event = ko.get(root_id, {})
        en_event = en.get(root_id, {})
        reads = ko_event.get("chapter5_finale_reads") \
            if isinstance(ko_event, dict) else None
        if not isinstance(reads, dict) or set(reads) != {
                "sources", "texts", "mode"}:
            errors.append(f"{root_id}: KO finale reads must own sources+texts+mode")
            continue
        sources = reads.get("sources")
        if sources != EXPECTED_READ_SOURCES[root_id]:
            errors.append(f"{root_id}: exact finale read-source order/domain drifted")
            continue
        expected_mode = EXPECTED_READ_MODES[root_id]
        if reads.get("mode") != expected_mode:
            errors.append(
                f"{root_id}: finale read mode must be {expected_mode}")
        text_rows = reads.get("texts")
        if not isinstance(text_rows, list) or len(text_rows) != len(sources):
            errors.append(f"{root_id}: KO read text/source row count drifted")
            continue
        for index, (source, row) in enumerate(zip(sources, text_rows)):
            count = _expected_source_choice_count(source)
            if not isinstance(row, list) or len(row) != count \
                    or any(not isinstance(text, str) or not text.strip() for text in row) \
                    or len(set(row)) != count:
                errors.append(
                    f"{root_id}.KO.texts[{index}]: expected {count} distinct "
                    "nonempty choice prefixes")
        en_reads = en_event.get("chapter5_finale_reads") \
            if isinstance(en_event, dict) else None
        if not isinstance(en_reads, dict) or set(en_reads) != {"texts"}:
            errors.append(f"{root_id}: EN finale overlay must own texts only")
            continue
        en_rows = en_reads.get("texts")
        if not isinstance(en_rows, list) or len(en_rows) != len(sources):
            errors.append(f"{root_id}: EN read text/source row count drifted")
            continue
        for index, (source, row) in enumerate(zip(sources, en_rows)):
            count = _expected_source_choice_count(source)
            if not isinstance(row, list) or len(row) != count \
                    or any(not isinstance(text, str) or not text.strip() for text in row) \
                    or len(set(row)) != count:
                errors.append(
                    f"{root_id}.EN.texts[{index}]: expected {count} distinct "
                    "nonempty choice prefixes")
        ko_tokens = INLINE_SLOT_RE.findall(str(ko_event.get("description", "")))
        en_tokens = INLINE_SLOT_RE.findall(str(en_event.get("description", "")))
        expected_tokens = [str(index) for index in range(len(sources))] \
            if expected_mode == "inline_slots" else []
        if ko_tokens != expected_tokens:
            errors.append(
                f"{root_id}: KO inline token order/count drifted "
                f"expected={expected_tokens} got={ko_tokens}")
        if en_tokens != expected_tokens:
            errors.append(
                f"{root_id}: EN inline token order/count drifted "
                f"expected={expected_tokens} got={en_tokens}")


def validate_events(
    ko: dict[str, dict[str, Any]],
    en: dict[str, dict[str, Any]],
    errors: list[str],
) -> None:
    total = 0
    for spec in ROOTS:
        ko_event = ko.get(spec.event_id)
        en_event = en.get(spec.event_id)
        if not isinstance(ko_event, dict) or not isinstance(en_event, dict):
            errors.append(f"{spec.event_id}: KO/EN event pair is missing")
            continue
        ko_choices = choices(ko_event)
        en_choices = choices(en_event)
        total += len(ko_choices)
        if len(ko_choices) != spec.choice_count:
            errors.append(
                f"{spec.event_id}: expected {spec.choice_count} KO choices, "
                f"got {len(ko_choices)}")
        if len(en_choices) != len(ko_choices):
            errors.append(f"{spec.event_id}: KO/EN choice-count drift")
        if placeholders(ko_event) != placeholders(en_event):
            errors.append(f"{spec.event_id}: KO/EN placeholder drift")
        if ko_event.get("weight") != 0 or ko_event.get("hidden") is not True \
                or ko_event.get("conditions") != {"min_turn": 9999}:
            errors.append(
                f"{spec.event_id}: direct ingress requires weight=0 hidden=true "
                "exact min_turn=9999")
        tags = ko_event.get("tags", [])
        if not isinstance(tags, list) or not {"year5", "finale"}.issubset(tags):
            errors.append(f"{spec.event_id}: year5/finale tags are required")
        if isinstance(tags, list) and "author_only" in tags:
            errors.append(f"{spec.event_id}: author_only tag remains")
        leaked_root = EN_GAMEPLAY_FIELDS & set(en_event)
        if leaked_root:
            errors.append(
                f"{spec.event_id}: EN overlay owns gameplay fields "
                f"{sorted(leaked_root)}")
        for index, choice in enumerate(en_choices):
            leaked = EN_GAMEPLAY_FIELDS & set(choice)
            if leaked:
                errors.append(
                    f"{spec.event_id}.choices[{index}]: EN overlay owns gameplay "
                    f"fields {sorted(leaked)}")
        for index, choice in enumerate(ko_choices):
            effects = choice.get("effects", {})
            if not isinstance(effects, dict):
                errors.append(f"{spec.event_id}.choices[{index}]: effects is not an object")
            elif ECONOMIC_EFFECT_KEYS & set(effects):
                errors.append(
                    f"{spec.event_id}.choices[{index}]: economic/AP mutation is forbidden")
            if choice.get("follow_up_event") or choice.get("deferred_follow_up"):
                errors.append(
                    f"{spec.event_id}.choices[{index}]: authored follow-up is forbidden")

        expected_flags = EXPECTED_EVENT_FLAGS.get(spec.event_id)
        if expected_flags is not None:
            for index, expected in enumerate(expected_flags):
                if index < len(ko_choices) \
                        and ko_choices[index].get("flags", []) != expected:
                    errors.append(
                        f"{spec.event_id}.choices[{index}]: exact compatibility "
                        "flags drifted")

        if spec.stage == "sacrifice" and len(ko_choices) == 2:
            for index, expected in enumerate(EXPECTED_SACRIFICE_FLAGS):
                if ko_choices[index].get("effects", {}) != {} \
                        or ko_choices[index].get("flags", []) != expected:
                    errors.append(
                        f"{spec.event_id}.choices[{index}]: sacrifice semantics drifted")
        if spec.stage == "outbound" and len(ko_choices) == 3:
            for index, expected in enumerate(EXPECTED_OUTBOUND_FLAGS):
                if ko_choices[index].get("effects", {}) != {} \
                        or ko_choices[index].get("flags", []) != expected:
                    errors.append(
                        f"{spec.event_id}.choices[{index}]: outbound semantics drifted")
    if total != 21:
        errors.append(f"general authored choice total is {total}, expected 21")
    validate_source_consumers(ko, en, errors)
    validate_finale_reads(ko, en, errors)


def validate_ledger(ledger: Any, errors: list[str]) -> None:
    if not isinstance(ledger, dict):
        errors.append("general finale ledger must be an object")
        return
    expected_top = {
        "schema_version", "ledger_id", "choice_index_base",
        "expected_root_count", "expected_active_root_count",
        "expected_choice_count", "expected_active_choice_count",
        "entry_contract", "stages", "roots",
    }
    if set(ledger) != expected_top:
        errors.append("general finale ledger top-level keys drifted")
    expected_scalars = {
        "schema_version": 1,
        "ledger_id": LEDGER_ID,
        "choice_index_base": 0,
        "expected_root_count": 8,
        "expected_active_root_count": 6,
        "expected_choice_count": 17,
        "expected_active_choice_count": 13,
    }
    for key, expected in expected_scalars.items():
        if ledger.get(key) != expected:
            errors.append(f"general finale ledger {key} must be {expected!r}")
    if ledger.get("stages") != EXPECTED_STAGES:
        errors.append("general finale stage order drifted")
    entry = ledger.get("entry_contract")
    expected_entry = {
        "route_id": ROUTE_ID,
        "turn": 224,
        "profile_id": PROFILE_ID,
        "source_route_id": SOURCE_ROUTE_ID,
        "source_choice_keys": {
            spec.key: list(range(spec.choice_count)) for spec in SOURCE_SPECS
        },
        "father": {
            "life": ["passed"],
            "contact_mode": ["present", "called", "missed", "records_only"],
        },
        "actor_bindings": EXPECTED_ACTORS,
    }
    if entry != expected_entry:
        errors.append("general finale entry contract drifted")

    rows = ledger.get("roots")
    if not isinstance(rows, list) or len(rows) != 8:
        errors.append("general finale ledger must contain exactly 8 roots")
        return
    all_receipts: set[str] = set()
    all_documents: set[str] = set()
    for index, (row, spec) in enumerate(zip(rows, FINALE_ROOTS)):
        label = f"general finale ledger roots[{index}]"
        if not isinstance(row, dict):
            errors.append(f"{label}: must be an object")
            continue
        expected_shape = {
            "stage_sequence": spec.stage_sequence,
            "variant_sequence": spec.variant_sequence,
            "month": spec.month,
            "turn": spec.turn,
            "week": spec.turn,
            "event_id": spec.event_id,
            "root_id": spec.event_id,
            "choice_count": spec.choice_count,
            "tier": EXPECTED_TIERS[spec.event_id],
            "stage": spec.stage,
            "active_when": EXPECTED_BRANCH_CONDITION[spec.event_id],
            "actors": EXPECTED_ROOT_ACTORS[spec.event_id],
            "read_sources": EXPECTED_READ_SOURCES[spec.event_id],
            "read_mode": EXPECTED_READ_MODES[spec.event_id],
        }
        for key, expected in expected_shape.items():
            if row.get(key) != expected:
                errors.append(f"{label}.{key}: exact value drifted")
        choice_rows = row.get("choices")
        if not isinstance(choice_rows, list) or len(choice_rows) != spec.choice_count:
            errors.append(f"{label}.choices: exact choice count drifted")
            continue
        for choice_index, choice in enumerate(choice_rows):
            if not isinstance(choice, dict) or set(choice) != {
                    "index", "receipt_ids", "document_ids", "economic_outcome"}:
                errors.append(f"{label}.choices[{choice_index}]: schema drifted")
                continue
            if choice.get("index") != choice_index:
                errors.append(f"{label}.choices[{choice_index}]: index drifted")
            receipt_ids = choice.get("receipt_ids")
            document_ids = choice.get("document_ids")
            expected_receipt, expected_document = \
                EXPECTED_LEDGER_CHOICE_BINDINGS[spec.event_id][choice_index]
            if receipt_ids != [expected_receipt] \
                    or document_ids != [expected_document]:
                errors.append(
                    f"{label}.choices[{choice_index}]: exact "
                    "receipt/document binding drifted")
            if not isinstance(receipt_ids, list) or len(receipt_ids) != 1 \
                    or not all(isinstance(value, str) and value for value in receipt_ids):
                errors.append(f"{label}.choices[{choice_index}]: one receipt is required")
            elif all_receipts & set(receipt_ids):
                errors.append(f"{label}.choices[{choice_index}]: duplicate receipt")
            else:
                all_receipts.update(receipt_ids)
            if not isinstance(document_ids, list) or len(document_ids) != 1 \
                    or not all(isinstance(value, str) and value for value in document_ids):
                errors.append(f"{label}.choices[{choice_index}]: one document is required")
            elif all_documents & set(document_ids):
                errors.append(f"{label}.choices[{choice_index}]: duplicate document")
            else:
                all_documents.update(document_ids)
            if choice.get("economic_outcome") != {}:
                errors.append(
                    f"{label}.choices[{choice_index}]: economic outcome must be empty")
    if len(all_receipts) != 17 or len(all_documents) != 17:
        errors.append("general finale ledger must own 17 unique receipts/documents")


def validate_lifecycle(lifecycle: Any, errors: list[str]) -> None:
    if not isinstance(lifecycle, dict):
        errors.append("event lifecycle must be an object")
        return
    counts = lifecycle.get("counts", {})
    if not isinstance(counts, dict) \
            or counts.get("packaged_events") != EXPECTED_PACKAGED_EVENTS \
            or counts.get("shipping_events") != EXPECTED_SHIPPING_EVENTS:
        errors.append(
            "event lifecycle must register packaged=1806 shipping=1696")
    author_only = lifecycle.get("author_only_event_ids", [])
    if not isinstance(author_only, list):
        errors.append("event lifecycle author_only_event_ids must be an array")
    else:
        leaked = sorted(set(ROOT_IDS) & set(author_only))
        if leaked:
            errors.append(f"general authored roots remain author_only: {leaked}")


def _director_rows(director: Any, turn: int) -> list[dict[str, Any]]:
    if not isinstance(director, dict):
        return []
    pacing = director.get("full_run_pacing", {})
    owners = pacing.get("commitment_event_owners", {}) \
        if isinstance(pacing, dict) else {}
    rows = owners.get(str(turn), []) if isinstance(owners, dict) else []
    return [row for row in rows if isinstance(row, dict)] \
        if isinstance(rows, list) else []


def validate_director(director: Any, errors: list[str]) -> None:
    expected = {
        211: [
            {"id": "arc_y5_general_name_boundary_exact", "axis": "human"},
        ],
        220: [
            {"id": "arc_y5_general_debt_memory_reconnect", "axis": "human", "person_id": "minseo"},
        ],
        224: [
            {"id": "arc_y5_general_father_legacy_voice_exact", "axis": "human", "person_id": "father"},
            {"id": "arc_y5_general_father_legacy_cafe_exact", "axis": "human", "person_id": "father"},
        ],
        229: [
            {"id": "arc_y5_general_debt_memory_voice_exact", "axis": "human", "person_id": "minseo"},
            {"id": "arc_y5_general_debt_memory_cafe_exact", "axis": "human", "person_id": "minseo"},
        ],
        234: [
            {"id": "arc_y5_general_pre_ending_summit_exact", "axis": "money"},
        ],
        237: [
            {"id": "arc_y5_general_final_record_seal", "axis": "money"},
        ],
        240: [
            {"id": "arc_final_countdown_general_near_goal_passed", "axis": "money"},
            {"id": "arc_y5_final_week_general_people_outbound", "axis": "human"},
        ],
    }
    for turn, rows in expected.items():
        observed = _director_rows(director, turn)
        for row in rows:
            matches = [candidate for candidate in observed
                       if candidate.get("id") == row["id"]]
            if matches != [row]:
                errors.append(
                    f"event director W{turn} exact owner missing: {row['id']}")


def _story_map_root_months(story_map: Any) -> dict[str, list[int]]:
    result = {event_id: [] for event_id in ROOT_IDS}
    chapters = story_map.get("chapters", []) if isinstance(story_map, dict) else []
    if not isinstance(chapters, list):
        return result
    for chapter in chapters:
        months = chapter.get("months", []) if isinstance(chapter, dict) else []
        if not isinstance(months, list):
            continue
        for month in months:
            if not isinstance(month, dict):
                continue
            number = int(month.get("month", -1))
            for beat in month.get("beats", []):
                if not isinstance(beat, dict):
                    continue
                root = str(beat.get("root", ""))
                if root in result:
                    result[root].append(number)
                coverage = beat.get("coverage", {})
                fallbacks = coverage.get("fallbacks", []) \
                    if isinstance(coverage, dict) else []
                if isinstance(fallbacks, list):
                    for fallback in fallbacks:
                        if not isinstance(fallback, dict):
                            continue
                        root = str(fallback.get("root", ""))
                        if root in result:
                            result[root].append(number)
    return result


def validate_story_map(story_map: Any, errors: list[str]) -> None:
    observed = _story_map_root_months(story_map)
    for spec in ROOTS:
        if observed[spec.event_id] != [spec.month]:
            errors.append(
                f"story map {spec.event_id}: expected exactly M{spec.month}, "
                f"got {observed[spec.event_id]}")


def validate_general_identity_gates(
    game_state: str,
    errors: list[str],
) -> None:
    """Pin the shared route identity and exact father/contact fail-closed gate."""
    profile_gate = function_block(
        game_state, "_chapter5_general_route_profile_allowed")
    for marker in (
        'for flag_id in ["route_career", "route_invest", "route_startup"]',
        "if not flags.has(flag_id):",
        "if not raw_flag is bool:",
        'if flag_id != "route_invest" and bool(raw_flag):',
        'var invest_route := _chapter5_finale_exact_true_flag("route_invest")',
        'if player_route == "none":',
        "return tendency_realized.is_empty() and not invest_route",
        'if player_route == "투자형":',
        'return tendency_realized in ["", "invest"] and invest_route',
    ):
        if marker not in profile_gate:
            errors.append(
                f"GameState general route identity gate missing: {marker}")
    profile_returns = [
        line.strip() for line in profile_gate.splitlines()
        if line.strip().startswith("return ")
    ]
    if profile_returns != [
        "return false",
        "return false",
        "return tendency_realized.is_empty() and not invest_route",
        'return tendency_realized in ["", "invest"] and invest_route',
        "return false",
    ]:
        errors.append(
            "GameState general route identity return inventory drifted")
    if not profile_gate.rstrip().endswith("return false"):
        errors.append(
            "GameState general route identity gate must reject unknown tuples")

    w211 = function_block(game_state, "chapter5_general_finale_w211_available")
    w220 = function_block(game_state, "chapter5_general_finale_w220_available")
    prepare = function_block(game_state, "prepare_chapter5_finale_route_entry")
    if w211.count("_chapter5_general_route_profile_allowed()") != 1:
        errors.append("GameState W211 must use the shared general route gate")
    if w220.count("_chapter5_general_route_profile_allowed()") != 1:
        errors.append("GameState W220 must use the shared general route gate")
    if prepare.count("_chapter5_general_route_profile_allowed()") != 1:
        errors.append("GameState W224 must use the shared general route gate")
    for marker in (
        "_chapter5_general_source_absent(",
        '"arc_y5_general_last_page_instruction"',
        '"chapter5_general_last_page_instruction_"',
    ):
        if marker not in prepare:
            errors.append(
                f"GameState W224 must reject retired W229 evidence: {marker}")
    existing_lock = (
        "if not chapter5_finale_entry_snapshot().is_empty():\n"
        "\t\treturn true"
    )
    lock_index = prepare.find(existing_lock)
    reevaluation_indexes = [
        prepare.find("var father := _chapter5_finale_father_snapshot()"),
        prepare.find("_chapter5_general_route_profile_allowed()"),
        prepare.find("_chapter5_general_finale_source_choices()"),
    ]
    if lock_index < 0 or any(index < 0 for index in reevaluation_indexes) \
            or not all(lock_index < index for index in reevaluation_indexes):
        errors.append(
            "GameState existing finale lock must return before general "
            "route/father/source reevaluation")

    exact_source = function_block(
        game_state, "_chapter5_general_exact_source_choice")
    if "if not raw_flag is bool:\n\t\t\treturn -1" not in exact_source:
        errors.append(
            "GameState exact source non-bool rejection branch is not live")
    if "if selected_flags.size() != 1:\n\t\treturn -1" not in exact_source:
        errors.append(
            "GameState exact source single-selection branch is not live")
    source_returns = [
        line.strip() for line in exact_source.splitlines()
        if line.strip().startswith("return ")
    ]
    if source_returns != [
        "return -1",
        "return -1",
        "return -1",
        "return -1",
        "return selected_choice if matching_receipts == 1 else -1",
    ]:
        errors.append("GameState exact source return inventory drifted")

    exact_true = function_block(
        game_state, "_chapter5_finale_exact_true_flag")
    for marker in (
        "flags.has(flag_id)",
        "var raw_flag: Variant = flags[flag_id]",
        "return raw_flag is bool and bool(raw_flag)",
    ):
        if marker not in exact_true:
            errors.append(
                f"GameState finale exact-true helper missing: {marker}")
    exact_true_returns = [
        line.strip() for line in exact_true.splitlines()
        if line.strip().startswith("return ")
    ]
    if exact_true_returns != [
        "return false", "return raw_flag is bool and bool(raw_flag)",
    ]:
        errors.append("GameState finale exact-true return inventory drifted")
    father = function_block(game_state, "_chapter5_finale_father_snapshot")
    for flag_id in (
        "father_passed",
        "arc_father_passing_seen",
        "father_crisis_contact_present",
        "father_crisis_contact_called",
        "father_crisis_contact_missed",
    ):
        marker = f'_chapter5_finale_exact_true_flag(\n\t\t\t"{flag_id}")'
        inline_marker = f'_chapter5_finale_exact_true_flag("{flag_id}")'
        if marker not in father and inline_marker not in father:
            errors.append(
                f"GameState father/contact exact-true gate missing: {flag_id}")
    if father.count("_chapter5_finale_exact_true_flag(") != 5:
        errors.append(
            "GameState father/contact must have exactly five exact-true reads")
    if "flags.get(" in father or "bool(flags" in father:
        errors.append("GameState father/contact uses permissive flag truthiness")


def validate_runtime(
    system: str,
    game_state: str,
    main_game: str,
    story_mode: str,
    ending_system: str,
    errors: list[str],
) -> None:
    validate_general_identity_gates(game_state, errors)
    for marker in (
        f'const GENERAL_LEDGER_ID := "{LEDGER_ID}"',
        f'const GENERAL_PROFILE_ID := "{PROFILE_ID}"',
        f'const GENERAL_SOURCE_ROUTE_ID := "{SOURCE_ROUTE_ID}"',
        "const GENERAL_ENTRY_TURN := 224",
        "const GENERAL_EXPECTED_ROOT_COUNT := 8",
        "const GENERAL_EXPECTED_ACTIVE_ROOT_COUNT := 6",
        "const GENERAL_EXPECTED_CHOICE_COUNT := 17",
        "const GENERAL_EXPECTED_ACTIVE_CHOICE_COUNT := 13",
    ):
        if marker not in system:
            errors.append(f"Chapter5FinaleRoute general constant missing: {marker}")
    if const_array(system, "GENERAL_OWNED_EVENT_IDS") != list(FINALE_ROOT_IDS):
        errors.append("Chapter5FinaleRoute GENERAL_OWNED_EVENT_IDS drifted")
    if const_array(system, "GENERAL_STAGES") != EXPECTED_STAGES:
        errors.append("Chapter5FinaleRoute GENERAL_STAGES drifted")
    for marker in (
        "static func ledger_id_for_profile(",
        "static func ledger_path_for_profile(",
        "static func profile_for_ledger_id(",
        "static func profile_for_event(",
        "static func is_entry_turn(",
        "GENERAL_LEDGER_PATH",
        "GENERAL_ROOT_CHOICE_COUNTS",
        "GENERAL_SOURCE_CHOICE_KEYS",
        "GENERAL_READ_SOURCES",
        "GENERAL_BRANCH_VARIANTS",
        "INLINE_SLOT_READ_EVENT_IDS",
    ):
        if marker not in system:
            errors.append(f"Chapter5FinaleRoute general selector missing: {marker}")
    for forbidden, pattern in {
        "money mutation": r"\b(?:add|set)_money\s*\(",
        "AP ownership": r"\baction_points\b|\bspend_ap\s*\(",
        "ending execution": r"\bfinish_run\s*\(|\bcheck_game_over\s*\(",
    }.items():
        if re.search(pattern, system):
            errors.append(f"Chapter5FinaleRoute owns forbidden {forbidden}")

    exact_source = function_block(game_state, "_chapter5_general_exact_source_choice")
    for marker in (
        "event_log", "flags", "raw_flag is bool", "selected_flags.size() != 1",
        "choice_index", "turn", "matching_receipts == 1",
    ):
        if marker not in exact_source:
            errors.append(f"GameState exact general source matcher missing: {marker}")
    source_builder = function_block(
        game_state, "_chapter5_general_finale_source_choices")
    for spec in SOURCE_SPECS:
        for marker in (
            f'"{spec.key}"', f'"{spec.event_id}"', f'"{spec.flag_prefix}"',
        ):
            if marker not in source_builder:
                errors.append(f"GameState source builder missing: {marker}")
    source_absent = function_block(game_state, "_chapter5_general_source_absent")
    for marker in (
        'flags.has("%s_seen" % event_id)', "flags.has(flag_id)", "event_log",
    ):
        if marker not in source_absent:
            errors.append(f"GameState exact source-absence matcher missing: {marker}")
    w211 = function_block(game_state, "chapter5_general_finale_w211_available")
    for marker in (
        "query_turn != 211", "chapter5_causal_entry_snapshot().is_empty()",
        "chapter5_finale_entry_snapshot().is_empty()",
        "CHAPTER5_FINALE_ROUTE.state_from_save(",
        "CHAPTER5_FINALE_ROUTE.default_state()",
        'get("life", "")) != "passed"',
        "var current_assets := float(get_total_asset_value())",
        "not is_finite(current_assets)", "current_assets < 2_500_000_000.0",
        '"arc_minseo_03_arrival"', '"chapter5_general_minseo_arrival_"',
        '"arc_y5_general_name_boundary_exact"',
        '"chapter5_general_name_boundary_"',
        '"arc_y5_general_debt_memory_reconnect"',
        "_chapter5_general_source_absent(",
    ):
        if marker not in w211:
            errors.append(f"GameState W211 gate missing: {marker}")
    w220 = function_block(game_state, "chapter5_general_finale_w220_available")
    for marker in (
        "query_turn != 220", "chapter5_causal_entry_snapshot().is_empty()",
        "chapter5_finale_entry_snapshot().is_empty()",
        "CHAPTER5_FINALE_ROUTE.state_from_save(",
        "CHAPTER5_FINALE_ROUTE.default_state()",
        'get("life", "")) != "passed"',
        '"arc_minseo_03_arrival"', '"arc_y5_general_name_boundary_exact"',
        '"chapter5_general_name_boundary_"',
        '"arc_y5_general_last_page_instruction"',
        '"arc_endgame_sixmonths"',
        '"arc_y5_general_debt_memory_reconnect"',
        "_chapter5_general_source_absent(",
    ):
        if marker not in w220:
            errors.append(f"GameState W220 gate missing: {marker}")
    prepare = function_block(game_state, "prepare_chapter5_finale_route_entry")
    for marker in (
        "GENERAL_ENTRY_TURN", "GENERAL_PROFILE_ID", "GENERAL_ACTORS",
        "_chapter5_general_finale_source_choices()",
        "chapter5_causal_entry_snapshot().is_empty()",
        'get("life", "")) != "passed"',
        "var current_assets := float(get_total_asset_value())",
        "not is_finite(current_assets)",
        "current_assets < 2_500_000_000.0",
        '"arc_father_legacy"',
        '"arc_pre_ending_summit"',
    ):
        if marker not in prepare:
            errors.append(f"GameState W224 entry binding missing: {marker}")
    if prepare.count("get_total_asset_value()") != 1 \
            or prepare.count("2_500_000_000.0") != 1:
        errors.append("GameState W224 must lock the exact 2.5B near-goal threshold once")
    if not re.search(
            r'_chapter5_general_event_absent\(\s*"arc_endgame_sixmonths"\s*\)',
            prepare):
        errors.append("GameState W224 entry admits a prior generic six-month event")

    main_router = function_block(main_game, "_route_chapter5_finale_week")
    if "CHAPTER5_FINALE_ROUTE.is_entry_turn(GameState.turn)" not in main_router:
        errors.append("MainGame finale router does not select both entry turns")
    arc_router = function_block(main_game, "_next_arc_id")
    w211_index = arc_router.find('return "arc_y5_general_name_boundary_exact"')
    w220_index = arc_router.find('return "arc_y5_general_debt_memory_reconnect"')
    peace_index = arc_router.find('return "arc_37_ending_peace"')
    if w211_index < 0 or w220_index < 0 or peace_index < 0 \
            or not w211_index < w220_index < peace_index:
        errors.append(
            "MainGame W211/W220 general sources lost authored priority/order")
    validate_w220_reservation_boundary(main_game, errors)
    if 'return "arc_y5_general_last_page_instruction"' in arc_router:
        errors.append("MainGame still routes the removed W229 general source")
    for marker in (
        "func _chapter5_finale_event_with_reads(",
        "func _chapter5_finale_live_ingress_allowed(",
        "func _queue_chapter5_finale_same_turn_ingress(",
        "GameState.record_chapter5_finale_choice(",
    ):
        if marker not in story_mode:
            errors.append(f"StoryMode finale transaction missing: {marker}")
    read_resolver = function_block(
        story_mode, "_chapter5_finale_event_with_reads")
    for marker in (
        'read_mode not in ["prepend", "inline_slots"]',
        'var slot := "[[c5read:%d]]" % source_index',
        "body.count(slot) != 1",
        "slot_position <= previous_slot_position",
        'if "[[c5read:" in body:',
    ):
        if marker not in read_resolver:
            errors.append(f"StoryMode ordered inline-read contract missing: {marker}")

    if "CHAPTER5_GENERAL_OUTBOUND_CODA_BY_CHOICE" not in ending_system \
            or ending_system.count('"kind": "minseo_') < 2 \
            or '"kind": "father_envelope_action"' not in ending_system:
        errors.append("EndingSystem general outbound coda inventory drifted")
    sacrifice_coda = function_block(
        ending_system, "chapter5_general_sacrifice_coda")
    for marker in (
        "GENERAL_ENTRY_TURN", 'get("ending_check", "")) != "consumed"',
        'receipt_snapshot_for_stage(\n\t\tcanonical, "sacrifice")',
        '"arc_final_countdown_general_near_goal_passed"',
        "CHAPTER5_GENERAL_SACRIFICE_CODA_BY_CHOICE",
    ):
        if marker not in sacrifice_coda:
            errors.append(f"EndingSystem sacrifice coda contract missing: {marker}")
    coda = function_block(ending_system, "chapter5_finale_outbound_coda")
    for marker in (
        'event_id == "arc_y5_final_week_daeun_outbound"',
        'event_id == "arc_y5_final_week_general_people_outbound"',
        "CHAPTER5_FINALE_OUTBOUND_CODA_BY_CHOICE",
        "CHAPTER5_GENERAL_OUTBOUND_CODA_BY_CHOICE",
    ):
        if marker not in coda:
            errors.append(f"EndingSystem receipt-ID coda branch missing: {marker}")

    instant = instant_legend_block(game_state)
    digest = hashlib.sha256(instant.encode("utf-8")).hexdigest()
    if not instant or digest != EXPECTED_INSTANT_LEGEND_SHA256:
        errors.append(
            "GameState instant_legend branch changed: "
            f"expected {EXPECTED_INSTANT_LEGEND_SHA256}, got {digest}")


def validate_model(
    ko: dict[str, dict[str, Any]],
    ko_paths: dict[str, str],
    en: dict[str, dict[str, Any]],
    ledger: Any,
    lifecycle: Any,
    director: Any,
    story_map: Any,
    sources: dict[str, str],
) -> list[str]:
    errors: list[str] = []
    validate_inventory(errors)
    validate_source_producers(ko, ko_paths, errors)
    validate_preserved_generic_roots(ko, en, errors)
    validate_retired_w229_absent(en, "EN", errors)
    validate_events(ko, en, errors)
    validate_ledger(ledger, errors)
    validate_lifecycle(lifecycle, errors)
    validate_director(director, errors)
    validate_story_map(story_map, errors)
    validate_runtime(
        sources["system"], sources["game_state"], sources["main_game"],
        sources["story_mode"], sources["ending_system"], errors,
    )
    return errors


def validate_w220_reservation_boundary(
    main_game: str,
    errors: list[str],
) -> None:
    reservation = function_block(
        main_game, "_chapter5_general_w220_reserves_generic")
    for marker in (
        "at_turn <= 220", "chapter5_general_finale_w220_available(220)",
    ):
        if marker not in reservation:
            errors.append(f"MainGame W220 reservation missing: {marker}")


def _fixture_ledger() -> dict[str, Any]:
    return {
        "schema_version": 1,
        "ledger_id": LEDGER_ID,
        "choice_index_base": 0,
        "expected_root_count": 8,
        "expected_active_root_count": 6,
        "expected_choice_count": 17,
        "expected_active_choice_count": 13,
        "entry_contract": {
            "route_id": ROUTE_ID,
            "turn": 224,
            "profile_id": PROFILE_ID,
            "source_route_id": SOURCE_ROUTE_ID,
            "source_choice_keys": {
                spec.key: list(range(spec.choice_count)) for spec in SOURCE_SPECS
            },
            "father": {
                "life": ["passed"],
                "contact_mode": ["present", "called", "missed", "records_only"],
            },
            "actor_bindings": copy.deepcopy(EXPECTED_ACTORS),
        },
        "stages": list(EXPECTED_STAGES),
        "roots": [
            {
                "stage_sequence": spec.stage_sequence,
                "variant_sequence": spec.variant_sequence,
                "month": spec.month,
                "turn": spec.turn,
                "week": spec.turn,
                "event_id": spec.event_id,
                "root_id": spec.event_id,
                "choice_count": spec.choice_count,
                "tier": EXPECTED_TIERS[spec.event_id],
                "stage": spec.stage,
                "active_when": copy.deepcopy(
                    EXPECTED_BRANCH_CONDITION[spec.event_id]),
                "actors": copy.deepcopy(EXPECTED_ROOT_ACTORS[spec.event_id]),
                "read_sources": copy.deepcopy(EXPECTED_READ_SOURCES[spec.event_id]),
                "read_mode": EXPECTED_READ_MODES[spec.event_id],
                "choices": [
                    {
                        "index": choice_index,
                        "receipt_ids": [
                            EXPECTED_LEDGER_CHOICE_BINDINGS[spec.event_id]
                            [choice_index][0]
                        ],
                        "document_ids": [
                            EXPECTED_LEDGER_CHOICE_BINDINGS[spec.event_id]
                            [choice_index][1]
                        ],
                        "economic_outcome": {},
                    }
                    for choice_index in range(spec.choice_count)
                ],
            }
            for spec in FINALE_ROOTS
        ],
    }


def _fixture_events() -> tuple[
    dict[str, dict[str, Any]], dict[str, str], dict[str, dict[str, Any]]
]:
    ko: dict[str, dict[str, Any]] = {}
    en: dict[str, dict[str, Any]] = {}
    paths: dict[str, str] = {}
    for source in SOURCE_SPECS:
        if source.event_id in ko:
            continue
        ko[source.event_id] = {
            "id": source.event_id,
            "choices": [
                {
                    "text": f"선택 {index}",
                    "flags": [f"{source.flag_prefix}{index}"],
                }
                for index in range(source.choice_count)
            ],
        }
        paths[source.event_id] = source.relative_path
    for event_id, count in {
        "arc_father_legacy": 3,
        "arc_pre_ending_summit": 2,
    }.items():
        ko[event_id] = {
            "id": event_id,
            "choices": [
                {"text": f"일반 선택 {index}", "result_text": "일반 결과"}
                for index in range(count)
            ],
        }
        en[event_id] = {
            "id": event_id,
            "choices": [
                {"text": f"Generic choice {index}", "result_text": "Result"}
                for index in range(count)
            ],
        }
    for spec in ROOTS:
        source = next(
            (row for row in SOURCE_SPECS if row.event_id == spec.event_id), None)
        ko_choices: list[dict[str, Any]] = []
        for index in range(spec.choice_count):
            row: dict[str, Any] = {"text": f"선택 {index}", "result_text": "결과"}
            if spec.event_id in EXPECTED_EVENT_FLAGS:
                row["flags"] = copy.deepcopy(
                    EXPECTED_EVENT_FLAGS[spec.event_id][index])
            elif source is not None:
                row["flags"] = [f"{source.flag_prefix}{index}"]
            elif spec.stage == "sacrifice":
                row["flags"] = copy.deepcopy(EXPECTED_SACRIFICE_FLAGS[index])
            elif spec.stage == "outbound":
                row["flags"] = copy.deepcopy(EXPECTED_OUTBOUND_FLAGS[index])
            ko_choices.append(row)
        ko[spec.event_id] = {
            "id": spec.event_id,
            "title": "장면",
            "description": "{name}의 마지막 장면",
            "weight": 0,
            "hidden": True,
            "conditions": {"min_turn": 9999},
            "tags": ["story", "year5", "finale"],
            "choices": ko_choices,
        }
        en[spec.event_id] = {
            "id": spec.event_id,
            "title": "Scene",
            "description": "{name}'s last scene",
            "choices": [
                {"text": f"Choice {index}", "result_text": "Result"}
                for index in range(spec.choice_count)
            ],
        }
        read_keys = EXPECTED_SOURCE_READ_KEYS.get(spec.event_id)
        if read_keys is not None:
            ko[spec.event_id]["description_memory_if_known"] = {
                key: f"회수 {index}"
                for index, key in enumerate(read_keys)
            }
            en[spec.event_id]["description_memory_if_known"] = {
                key: f"Recall {index}"
                for index, key in enumerate(read_keys)
            }
        if spec.stage:
            source_rows = EXPECTED_READ_SOURCES[spec.event_id]
            ko[spec.event_id]["chapter5_finale_reads"] = {
                "sources": copy.deepcopy(source_rows),
                "texts": [
                    [f"근거 {row_index}-{value}" for value in range(
                        _expected_source_choice_count(row))]
                    for row_index, row in enumerate(source_rows)
                ],
                "mode": EXPECTED_READ_MODES[spec.event_id],
            }
            en[spec.event_id]["chapter5_finale_reads"] = {
                "texts": [
                    [f"Source {row_index}-{value}" for value in range(
                        _expected_source_choice_count(row))]
                    for row_index, row in enumerate(source_rows)
                ],
            }
            if EXPECTED_READ_MODES[spec.event_id] == "inline_slots":
                tokens = " ".join(
                    f"[[c5read:{index}]]"
                    for index in range(len(source_rows)))
                ko[spec.event_id]["description"] += " " + tokens
                en[spec.event_id]["description"] += " " + tokens
    return ko, paths, en


def run_self_test() -> int:
    cases = 0

    def require(condition: bool, message: str) -> None:
        nonlocal cases
        cases += 1
        if not condition:
            raise AssertionError(message)

    inventory_errors: list[str] = []
    validate_inventory(inventory_errors)
    require(not inventory_errors, str(inventory_errors[:1]))

    ledger = _fixture_ledger()
    ledger_errors: list[str] = []
    validate_ledger(ledger, ledger_errors)
    require(not ledger_errors, str(ledger_errors[:1]))

    ko, paths, en = _fixture_events()
    event_errors: list[str] = []
    validate_source_producers(ko, paths, event_errors)
    validate_preserved_generic_roots(ko, en, event_errors)
    validate_events(ko, en, event_errors)
    require(not event_errors, str(event_errors[:1]))

    wrong_flag = copy.deepcopy(ko)
    wrong_flag["arc_minseo_03_arrival"]["choices"][0]["flags"] = [
        "chapter5_general_minseo_arrival_1"]
    errors: list[str] = []
    validate_source_producers(wrong_flag, paths, errors)
    require(any("exact source flag mismatch" in error for error in errors),
            "wrong source flag was accepted")

    duplicate_flag = copy.deepcopy(ko)
    duplicate_flag["arc_y5_general_debt_memory_reconnect"]["choices"][0][
        "flags"].append("chapter5_general_debt_memory_reconnect_1")
    errors = []
    validate_source_producers(duplicate_flag, paths, errors)
    require(any("exact source flag mismatch" in error for error in errors),
            "multiple source flags were accepted")

    wrong_consumer = copy.deepcopy(ko)
    wrong_consumer["arc_y5_general_debt_memory_reconnect"][
        "description_memory_if_known"].pop("chapter5_general_name_boundary_1")
    errors = []
    validate_source_consumers(wrong_consumer, en, errors)
    require(any("source prose-reader keys drifted" in error for error in errors),
            "missing W211 -> W220 source reader was accepted")

    leaked_en = copy.deepcopy(en)
    leaked_en[ROOT_IDS[0]]["choices"][0]["flags"] = ["illegal"]
    errors = []
    validate_events(ko, leaked_en, errors)
    require(any("EN overlay owns gameplay" in error for error in errors),
            "EN gameplay mutation was accepted")

    restored_w229_en = copy.deepcopy(en)
    restored_w229_en["arc_y5_general_last_page_instruction"] = {
        "id": "arc_y5_general_last_page_instruction",
        "choices": [{"text": "Retired source"}],
    }
    errors = []
    validate_retired_w229_absent(restored_w229_en, "EN", errors)
    require(any("root remains in the EN catalog" in error for error in errors),
            "retired EN W229 root was accepted")

    leaked_w229_flag_en = copy.deepcopy(en)
    leaked_w229_flag_en[ROOT_IDS[0]]["choices"][0]["flags"] = [
        "chapter5_general_last_page_instruction_0"]
    errors = []
    validate_retired_w229_absent(leaked_w229_flag_en, "EN", errors)
    require(any("removed W229 source flag remains" in error
                for error in errors),
            "retired EN W229 flag was accepted")

    wrong_reads = copy.deepcopy(ko)
    two_source_root = "arc_y5_general_final_record_seal"
    wrong_reads[two_source_root]["chapter5_finale_reads"]["sources"].reverse()
    errors = []
    validate_events(wrong_reads, en, errors)
    require(any("read-source order" in error for error in errors),
            "read source reorder was accepted")

    wrong_inline = copy.deepcopy(ko)
    wrong_inline[two_source_root]["description"] = \
        wrong_inline[two_source_root]["description"].replace(
            "[[c5read:0]] [[c5read:1]]",
            "[[c5read:1]] [[c5read:0]]", 1)
    errors = []
    validate_events(wrong_inline, en, errors)
    require(any("inline token order/count" in error for error in errors),
            "inline read-slot inversion was accepted")

    economic = copy.deepcopy(ko)
    economic[FINALE_ROOT_IDS[0]]["choices"][0]["effects"] = {"money": 1}
    errors = []
    validate_events(economic, en, errors)
    require(any("economic/AP mutation" in error for error in errors),
            "economic mutation was accepted")

    wrong_ledger = copy.deepcopy(ledger)
    wrong_ledger["expected_choice_count"] = 18
    errors = []
    validate_ledger(wrong_ledger, errors)
    require(any("expected_choice_count" in error for error in errors),
            "ledger count mutation was accepted")

    inverted_branch = copy.deepcopy(ledger)
    inverted_branch["roots"][0]["active_when"]["equals"] = 1
    errors = []
    validate_ledger(inverted_branch, errors)
    require(any("active_when" in error for error in errors),
            "W224 branch inversion was accepted")

    tampered_receipt = copy.deepcopy(ledger)
    tampered_receipt["roots"][1]["choices"][0]["receipt_ids"] = \
        tampered_receipt["roots"][0]["choices"][0]["receipt_ids"]
    errors = []
    validate_ledger(tampered_receipt, errors)
    require(any("duplicate receipt" in error for error in errors),
            "duplicate receipt was accepted")

    inverted_seal = copy.deepcopy(ledger)
    seal_index = next(
        index for index, row in enumerate(inverted_seal["roots"])
        if row["event_id"] == "arc_y5_general_final_record_seal")
    inverted_seal["roots"][seal_index]["choices"][0]["receipt_ids"], \
        inverted_seal["roots"][seal_index]["choices"][1]["receipt_ids"] = (
            inverted_seal["roots"][seal_index]["choices"][1]["receipt_ids"],
            inverted_seal["roots"][seal_index]["choices"][0]["receipt_ids"],
        )
    inverted_seal["roots"][seal_index]["choices"][0]["document_ids"], \
        inverted_seal["roots"][seal_index]["choices"][1]["document_ids"] = (
            inverted_seal["roots"][seal_index]["choices"][1]["document_ids"],
            inverted_seal["roots"][seal_index]["choices"][0]["document_ids"],
        )
    errors = []
    validate_ledger(inverted_seal, errors)
    require(any("exact receipt/document binding drifted" in error
                for error in errors),
            "W237 semantic receipt inversion was accepted")

    game_state = GAME_STATE_PATH.read_text(encoding="utf-8")
    identity_errors: list[str] = []
    validate_general_identity_gates(game_state, identity_errors)
    require(not identity_errors, str(identity_errors[:1]))

    main_game = MAIN_GAME_PATH.read_text(encoding="utf-8")
    reservation_errors: list[str] = []
    validate_w220_reservation_boundary(main_game, reservation_errors)
    require(not reservation_errors, str(reservation_errors[:1]))
    reservation_block = function_block(
        main_game, "_chapter5_general_w220_reserves_generic")
    widened_block = reservation_block.replace(
        "at_turn <= 220", "at_turn <= 237", 1)
    widened_main_game = main_game.replace(
        reservation_block, widened_block, 1)
    widened_errors: list[str] = []
    validate_w220_reservation_boundary(widened_main_game, widened_errors)
    require(reservation_block and widened_block != reservation_block
            and any("at_turn <= 220" in error for error in widened_errors),
            "W220 <=237 reservation widening was accepted")

    def mutate_block(
        source: str,
        function_name: str,
        mutate: Any,
    ) -> str:
        block = function_block(source, function_name)
        changed = mutate(block)
        if not block or changed == block:
            raise AssertionError(
                f"self-test could not mutate {function_name}")
        return source.replace(block, changed, 1)

    def require_identity_rejection(
        label: str,
        candidate: str,
        fragment: str,
    ) -> None:
        candidate_errors: list[str] = []
        validate_general_identity_gates(candidate, candidate_errors)
        require(any(fragment in error for error in candidate_errors),
                f"{label} mutation was accepted: {candidate_errors[:2]}")

    require_identity_rejection(
        "W220 shared gate",
        mutate_block(
            game_state, "chapter5_general_finale_w220_available",
            lambda block: block.replace(
                "or not _chapter5_general_route_profile_allowed():",
                "or false:", 1)),
        "W220 must use the shared general route gate",
    )
    require_identity_rejection(
        "W224 shared gate",
        mutate_block(
            game_state, "prepare_chapter5_finale_route_entry",
            lambda block: block.replace(
                "or not _chapter5_general_route_profile_allowed() \\",
                "or false \\", 1)),
        "W224 must use the shared general route gate",
    )
    require_identity_rejection(
        "W224 retired W229 evidence",
        mutate_block(
            game_state, "prepare_chapter5_finale_route_entry",
            lambda block: block.replace(
                '"arc_y5_general_last_page_instruction"',
                '"arc_y5_general_retired_source"', 1)),
        "W224 must reject retired W229 evidence",
    )
    require_identity_rejection(
        "neutral tuple mismatch",
        mutate_block(
            game_state, "_chapter5_general_route_profile_allowed",
            lambda block: block.replace(
                "return tendency_realized.is_empty() and not invest_route",
                "return true", 1)),
        "general route identity gate missing",
    )
    require_identity_rejection(
        "investor tuple mismatch",
        mutate_block(
            game_state, "_chapter5_general_route_profile_allowed",
            lambda block: block.replace(
                'return tendency_realized in ["", "invest"] and invest_route',
                "return invest_route", 1)),
        "general route identity gate missing",
    )
    require_identity_rejection(
        "career/startup route",
        mutate_block(
            game_state, "_chapter5_general_route_profile_allowed",
            lambda block: block.replace(
                'if flag_id != "route_invest" and bool(raw_flag):',
                "if false:", 1)),
        "general route identity gate missing",
    )
    require_identity_rejection(
        "non-bool route flag",
        mutate_block(
            game_state, "_chapter5_general_route_profile_allowed",
            lambda block: block.replace(
                "if not raw_flag is bool:", "if false:", 1)),
        "general route identity gate missing",
    )
    require_identity_rejection(
        "unknown route tuple",
        mutate_block(
            game_state, "_chapter5_general_route_profile_allowed",
            lambda block: block[:block.rfind("return false")]
            + "return true" + block[block.rfind("return false")
                                    + len("return false"):]),
        "must reject unknown tuples",
    )
    require_identity_rejection(
        "father contact permissive read",
        mutate_block(
            game_state, "_chapter5_finale_father_snapshot",
            lambda block: block.replace(
                '_chapter5_finale_exact_true_flag(\n\t\t\t'
                '"father_crisis_contact_called")',
                'bool(flags.get("father_crisis_contact_called", false))', 1)),
        "father/contact exact-true gate missing",
    )
    require_identity_rejection(
        "exact-true non-bool coercion",
        mutate_block(
            game_state, "_chapter5_finale_exact_true_flag",
            lambda block: block.replace(
                "return raw_flag is bool and bool(raw_flag)",
                "return bool(raw_flag)", 1)),
        "finale exact-true helper missing",
    )

    def move_existing_lock_after_father(block: str) -> str:
        clause = (
            "\tif not chapter5_finale_entry_snapshot().is_empty():\n"
            "\t\treturn true\n"
        )
        anchor = "\tvar father := _chapter5_finale_father_snapshot()\n"
        if clause not in block or anchor not in block:
            return block
        without_lock = block.replace(clause, "", 1)
        return without_lock.replace(anchor, anchor + clause, 1)

    require_identity_rejection(
        "existing lock ordering",
        mutate_block(
            game_state, "prepare_chapter5_finale_route_entry",
            move_existing_lock_after_father),
        "existing finale lock must return before general",
    )
    require_identity_rejection(
        "source non-bool dead condition",
        mutate_block(
            game_state, "_chapter5_general_exact_source_choice",
            lambda block: block.replace(
                "if not raw_flag is bool:",
                "if false and not raw_flag is bool:", 1)),
        "exact source non-bool rejection branch is not live",
    )
    require_identity_rejection(
        "source selection-count bypass",
        mutate_block(
            game_state, "_chapter5_general_exact_source_choice",
            lambda block: block.replace(
                "if selected_flags.size() != 1:",
                "if false and selected_flags.size() != 1:", 1)),
        "exact source single-selection branch is not live",
    )
    return cases


def optional_json(path: Path, errors: list[str], label: str) -> Any:
    try:
        return load_json(path)
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        errors.append(f"{label} could not be loaded: {exc}")
        return None


def optional_text(path: Path, errors: list[str], label: str) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except OSError as exc:
        errors.append(f"{label} could not be loaded: {exc}")
        return ""


def main(argv: Iterable[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args(list(argv) if argv is not None else None)
    if args.self_test:
        try:
            cases = run_self_test()
        except AssertionError as exc:
            print(f"CHAPTER5_GENERAL_FINALE_ROUTE_SELF_TEST_FAIL {exc}")
            return 1
        print(f"CHAPTER5_GENERAL_FINALE_ROUTE_SELF_TEST_OK cases={cases}")
        return 0

    load_errors: list[str] = []
    try:
        ko, ko_paths = load_events(KO_DIR)
        en, _en_paths = load_events(EN_DIR)
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        print(f"CHAPTER5_GENERAL_FINALE_ROUTE_AUDIT_FAIL {exc}")
        return 1
    ledger = optional_json(LEDGER_PATH, load_errors, "general finale ledger")
    lifecycle = optional_json(LIFECYCLE_PATH, load_errors, "event lifecycle")
    director = optional_json(DIRECTOR_PATH, load_errors, "event director")
    story_map = optional_json(STORY_MAP_PATH, load_errors, "story map")
    sources = {
        "system": optional_text(SYSTEM_PATH, load_errors, "finale reducer"),
        "game_state": optional_text(GAME_STATE_PATH, load_errors, "GameState"),
        "main_game": optional_text(MAIN_GAME_PATH, load_errors, "MainGame"),
        "story_mode": optional_text(STORY_MODE_PATH, load_errors, "StoryMode"),
        "ending_system": optional_text(
            ENDING_SYSTEM_PATH, load_errors, "EndingSystem"),
    }
    errors = load_errors + validate_model(
        ko, ko_paths, en, ledger, lifecycle, director, story_map, sources)
    if errors:
        print(f"CHAPTER5_GENERAL_FINALE_ROUTE_AUDIT_FAIL errors={len(errors)}")
        for error in errors:
            print(f"  ERROR {error}")
        return 1
    print(
        "CHAPTER5_GENERAL_FINALE_ROUTE_AUDIT_OK "
        "authored_roots=10 authored_choices=21 ledger_roots=8 "
        "active_roots=6 authored_active_roots=8 ledger_choices=17 "
        "active_choices=13 authored_active_choices=17 sources=3 "
        "exact_receipt=flag+event_log profile=general_near_goal_father_passed "
        "source_chain=M51+W211+W220 entry=W224 branch_roots=W224+W229 summit=W234 "
        "ending=pending-ready-consumed instant_legend=preserved"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
