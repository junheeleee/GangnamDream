#!/usr/bin/env python3
"""Audit the product-owned M56-M60 Chapter 5 finale route (ORDER-134).

This is deliberately a static, deterministic contract check.  The executable
Godot check owns reducer behaviour; this file catches content/ledger/runtime
drift before Godot is started.  Missing integration files are reported as
ordinary, actionable errors so the checker is also useful while the batch is
being assembled.
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
LEDGER = ROOT / "content" / "meta" / "chapter5_finale_ledger.json"
LIFECYCLE = ROOT / "content" / "meta" / "event_lifecycle.json"
SYSTEM = ROOT / "systems" / "Chapter5FinaleRoute.gd"
GAME_STATE = ROOT / "autoloads" / "GameState.gd"
MAIN_GAME = ROOT / "scenes" / "MainGame.gd"
STORY_MODE = ROOT / "scenes" / "StoryMode.gd"

LEDGER_ID = "chapter5_m56_m60_safe_finale_v1"
ROUTE_ID = "chapter5_safe_finale"
PROFILE_ID = "investment_safe_no_execution"
SOURCE_ROUTE_ID = "investment_property"
EXPECTED_INSTANT_LEGEND_SHA256 = (
    "70b9a867122a27f80830cf43a2e4626032ee76bf10cd16a828d4de18aa41ebc6"
)

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
KNOWN_ACTORS = {
    "player", "father", "sangchul", "daeun", "minseo", "jaehyuk",
}
PLACEHOLDER_RE = re.compile(r"\{[A-Za-z_][A-Za-z0-9_]*\}")


@dataclass(frozen=True)
class RootSpec:
    stage: int
    month: int
    turn: int
    root_id: str
    choices: int
    variant: str = ""


ROOTS = (
    RootSpec(1, 56, 221, "arc_y5_father_trace_alive_exact", 3, "alive"),
    RootSpec(1, 56, 221, "arc_y5_father_trace_passed_exact", 3, "passed"),
    RootSpec(2, 56, 224, "arc_y5_father_trace_custody", 2),
    RootSpec(3, 57, 227, "arc_y5_name_on_line_daeun_routed", 4),
    RootSpec(4, 58, 230, "arc_y5_people_verdict_daeun_exact", 3),
    RootSpec(5, 59, 235, "arc_y5_property_not_executed_notice", 1),
    RootSpec(6, 60, 238, "arc_y5_remaining_jaehyuk_or_self", 2),
    RootSpec(7, 60, 239, "arc_y5_final_father_answer_alive", 3, "alive"),
    RootSpec(7, 60, 239, "arc_y5_final_father_answer_passed", 3, "passed"),
    RootSpec(8, 60, 240, "arc_final_countdown_property_not_executed", 3),
    RootSpec(9, 60, 240, "arc_y5_final_week_daeun_outbound", 3),
)
ROOT_IDS = tuple(spec.root_id for spec in ROOTS)
SPEC_BY_ID = {spec.root_id: spec for spec in ROOTS}
STAGE_ROOT_IDS = {
    stage: tuple(spec.root_id for spec in ROOTS if spec.stage == stage)
    for stage in range(1, 10)
}
EXPECTED_STAGE_TURNS = (221, 224, 227, 230, 235, 238, 239, 240, 240)
EXPECTED_STAGE_CHOICES = (3, 2, 4, 3, 1, 2, 3, 3, 3)
EXPECTED_STAGE_NAMES = (
    "father_trace", "custody", "filing", "verdict", "nontransaction",
    "guarantee_return", "father_answer", "signature", "outbound",
)
STAGE_NUMBER_BY_NAME = {
    stage_name: index for index, stage_name in enumerate(EXPECTED_STAGE_NAMES, 1)
}
EXPECTED_TIERS = {
    1: "T1", 2: "T2", 3: "T1", 4: "T1", 5: "T2",
    6: "T2", 7: "T1", 8: "T1", 9: "T1",
}
EXPECTED_ECONOMIC_ZERO = {
    "kind": "none",
    "reason": "no_executable_contract",
    "cash_delta_krw": 0,
    "asset_delta_krw": 0,
    "debt_delta_krw": 0,
}
EXPECTED_SIGNATURE_OUTCOMES = (
    {
        "effects": {},
        "flags": ["arc_final_countdown_seen", "final_signature_owned"],
    },
    {
        "effects": {},
        "flags": ["arc_final_countdown_seen", "final_signature_collateral"],
    },
    {
        "effects": {},
        "flags": ["arc_final_countdown_seen", "final_signature_people"],
    },
)
EXPECTED_OUTBOUND_OUTCOMES = (
    {
        "effects": {},
        "flags": ["arc_final_week_seen"],
    },
    {
        "effects": {},
        "flags": ["arc_final_week_seen"],
    },
    {
        "effects": {},
        "flags": ["arc_final_week_seen"],
    },
)


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
    if not isinstance(raw, list):
        return []
    return [row for row in raw if isinstance(row, dict)]


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


def _source_key(source: Any) -> tuple[Any, ...]:
    if not isinstance(source, dict):
        return ("invalid",)
    kind = str(source.get("kind", ""))
    if kind in {"causal_event", "finale_stage"}:
        return (kind, str(source.get("id", "")))
    if kind == "entry_value":
        raw_values = source.get("values", [])
        values = tuple(raw_values) if isinstance(raw_values, list) else ()
        return (kind, str(source.get("path", "")), values)
    return (kind,)


def validate_inventory(errors: list[str]) -> None:
    if len(ROOTS) != 11 or len(set(ROOT_IDS)) != 11:
        errors.append("finale authored inventory must be exactly 11 unique roots")
    if sum(spec.choices for spec in ROOTS) != 30:
        errors.append("finale authored inventory must be exactly 30 choices")
    if tuple(STAGE_ROOT_IDS) != tuple(range(1, 10)):
        errors.append("finale inventory must contain stages 1 through 9")
    if tuple(min(SPEC_BY_ID[root].turn for root in STAGE_ROOT_IDS[stage])
             for stage in range(1, 10)) != EXPECTED_STAGE_TURNS:
        errors.append("finale stage turn order drifted")
    active_choices = sum(EXPECTED_STAGE_CHOICES)
    if active_choices != 24:
        errors.append(f"finale active run must contain 24 choices, got {active_choices}")
    if STAGE_ROOT_IDS[1] != ROOT_IDS[0:2] \
            or STAGE_ROOT_IDS[7] != ROOT_IDS[7:9]:
        errors.append("alive/passed variant roots moved from stages 1 or 7")
    if any(len(STAGE_ROOT_IDS[stage]) != 1
           for stage in (2, 3, 4, 5, 6, 8, 9)):
        errors.append("nonvariant finale stage gained an authored root")


def _validate_source(
    source: Any,
    target_id: str,
    source_index: int,
    errors: list[str],
) -> bool:
    label = f"{target_id}.chapter5_finale_reads.sources[{source_index}]"
    if not isinstance(source, dict):
        errors.append(f"{label}: source must be an object")
        return False
    kind = source.get("kind")
    if kind in {"causal_event", "finale_stage"}:
        if set(source) != {"kind", "id"} \
                or not isinstance(source.get("id"), str) \
                or not source["id"]:
            errors.append(f"{label}: {kind} source schema drifted")
            return False
        if kind == "finale_stage" and source["id"] not in STAGE_NUMBER_BY_NAME:
            errors.append(f"{label}: unknown finale stage {source['id']}")
            return False
        if kind == "finale_stage" \
                and STAGE_NUMBER_BY_NAME[source["id"]] >= SPEC_BY_ID[target_id].stage:
            errors.append(f"{label}: finale read points to same/future stage")
            return False
        return True
    if kind == "entry_value":
        values = source.get("values")
        if set(source) != {"kind", "path", "values"} \
                or not isinstance(source.get("path"), str) \
                or not source["path"] \
                or not isinstance(values, list) or not values \
                or any(not isinstance(value, (str, int)) for value in values) \
                or len({str(value) for value in values}) != len(values):
            errors.append(f"{label}: entry_value source schema drifted")
            return False
        return True
    errors.append(f"{label}: unknown source kind {kind!r}")
    return False


def _source_choice_count(
    source: dict[str, Any], ko: dict[str, dict[str, Any]],
) -> int:
    kind = source.get("kind")
    if kind == "entry_value":
        values = source.get("values", [])
        return len(values) if isinstance(values, list) else -1
    source_id = str(source.get("id", ""))
    if source_id in STAGE_NUMBER_BY_NAME:
        return EXPECTED_STAGE_CHOICES[STAGE_NUMBER_BY_NAME[source_id] - 1]
    source_event = ko.get(source_id)
    return len(_choice_rows(source_event)) if isinstance(source_event, dict) else -1


def _validate_read_rows(
    rows: Any,
    sources: list[dict[str, Any]],
    ko: dict[str, dict[str, Any]],
    label: str,
    errors: list[str],
) -> bool:
    if not isinstance(rows, list) or len(rows) != len(sources):
        errors.append(f"{label}: prose row/source count drifted")
        return False
    valid = True
    for row_index, (row, source) in enumerate(zip(rows, sources)):
        expected = _source_choice_count(source, ko)
        if expected < 1:
            errors.append(
                f"{label}.texts[{row_index}]: source choice domain is unavailable")
            valid = False
            continue
        if not isinstance(row, list) or len(row) != expected \
                or any(not isinstance(text, str) or not text.strip() for text in row) \
                or len(set(row)) != expected:
            errors.append(
                f"{label}.texts[{row_index}]: expected {expected} distinct "
                "nonempty choice prefixes")
            valid = False
    return valid


def validate_finale_reads(
    ko: dict[str, dict[str, Any]],
    en: dict[str, dict[str, Any]],
    expected_sources: dict[str, list[dict[str, Any]]],
    errors: list[str],
) -> None:
    for root_id in ROOT_IDS:
        ko_event = ko.get(root_id)
        en_event = en.get(root_id)
        if not isinstance(ko_event, dict) or not isinstance(en_event, dict):
            continue
        ko_reads = ko_event.get("chapter5_finale_reads")
        en_reads = en_event.get("chapter5_finale_reads")
        if not isinstance(ko_reads, dict) or set(ko_reads) != {
            "sources", "texts", "mode",
        }:
            errors.append(
                f"{root_id}: KO finale reads must own sources+texts+mode only")
            continue
        raw_sources = ko_reads.get("sources")
        if not isinstance(raw_sources, list) or not raw_sources:
            errors.append(f"{root_id}: KO finale read sources must be nonempty")
            continue
        sources = [source for source in raw_sources if isinstance(source, dict)]
        if len(sources) != len(raw_sources):
            errors.append(f"{root_id}: KO finale read source is not an object")
            continue
        for source_index, source in enumerate(sources):
            _validate_source(source, root_id, source_index, errors)
        if ko_reads.get("mode") != "prepend":
            errors.append(f"{root_id}: KO finale read mode must be prepend")
        declared = expected_sources.get(root_id)
        if declared is None:
            errors.append(f"{root_id}: ledger has no exact read-source contract")
        elif [_source_key(row) for row in sources] != [
                _source_key(row) for row in declared]:
            errors.append(f"{root_id}: finale read source order drifted from ledger")
        ko_ok = _validate_read_rows(
            ko_reads.get("texts"), sources, ko, f"{root_id}.KO", errors)
        if not isinstance(en_reads, dict) or set(en_reads) != {"texts"}:
            errors.append(f"{root_id}: EN finale overlay must own texts only")
            continue
        en_ok = _validate_read_rows(
            en_reads.get("texts"), sources, ko, f"{root_id}.EN", errors)
        if ko_ok and en_ok:
            ko_rows = ko_reads["texts"]
            en_rows = en_reads["texts"]
            for row_index, (ko_row, en_row) in enumerate(zip(ko_rows, en_rows)):
                if any(left == right for left, right in zip(ko_row, en_row)):
                    errors.append(
                        f"{root_id}.texts[{row_index}]: EN prefix did not localize")


def validate_events(
    ko: dict[str, dict[str, Any]],
    en: dict[str, dict[str, Any]],
    expected_sources: dict[str, list[dict[str, Any]]],
    errors: list[str],
) -> None:
    authored_choices = 0
    for spec in ROOTS:
        ko_event = ko.get(spec.root_id)
        en_event = en.get(spec.root_id)
        if ko_event is None or en_event is None:
            missing = []
            if ko_event is None:
                missing.append("KO")
            if en_event is None:
                missing.append("EN")
            errors.append(f"{spec.root_id}: missing {'/'.join(missing)} event")
            continue
        ko_choices = _choice_rows(ko_event)
        en_choices = _choice_rows(en_event)
        authored_choices += len(ko_choices)
        if len(ko_choices) != spec.choices:
            errors.append(
                f"{spec.root_id}: expected {spec.choices} KO choices, "
                f"got {len(ko_choices)}")
        if len(en_choices) != len(ko_choices):
            errors.append(f"{spec.root_id}: KO/EN choice-count drift")
        if placeholders(ko_event) != placeholders(en_event):
            errors.append(f"{spec.root_id}: KO/EN placeholder drift")
        if ko_event.get("weight") != 0 or ko_event.get("hidden") is not True \
                or ko_event.get("conditions") != {"min_turn": 9999}:
            errors.append(
                f"{spec.root_id}: direct ingress requires weight=0 hidden=true "
                "exact min_turn=9999")
        tags = ko_event.get("tags", [])
        if not isinstance(tags, list) or "chapter5" not in tags:
            errors.append(f"{spec.root_id}: chapter5 tag missing")
        if isinstance(tags, list) and "author_only" in tags:
            errors.append(f"{spec.root_id}: author_only tag remains")
        if "scene_tier" in ko_event or "scene_tier" in en_event:
            errors.append(f"{spec.root_id}: event invented a scene_tier field")
        root_leaks = EN_GAMEPLAY_FIELDS & set(en_event)
        if root_leaks:
            errors.append(
                f"{spec.root_id}: EN overlay owns gameplay fields "
                f"{sorted(root_leaks)}")
        for choice_index, choice in enumerate(en_choices):
            leaked = EN_GAMEPLAY_FIELDS & set(choice)
            if leaked:
                errors.append(
                    f"{spec.root_id}.choices[{choice_index}]: EN overlay owns "
                    f"gameplay fields {sorted(leaked)}")
        for choice_index, choice in enumerate(ko_choices):
            effects = choice.get("effects", {})
            if effects is not None and not isinstance(effects, dict):
                errors.append(
                    f"{spec.root_id}.choices[{choice_index}]: effects is not an object")
            elif isinstance(effects, dict):
                economic = ECONOMIC_EFFECT_KEYS & set(effects)
                if economic:
                    errors.append(
                        f"{spec.root_id}.choices[{choice_index}]: finale choice "
                        f"mutates economic/AP fields {sorted(economic)}")
        if spec.stage == 9:
            for choice_index, choice in enumerate(ko_choices):
                flags = choice.get("flags", [])
                if not isinstance(flags, list) \
                        or "arc_final_week_seen" not in flags:
                    errors.append(
                        f"{spec.root_id}.choices[{choice_index}]: final outbound "
                        "must preserve arc_final_week_seen")
                legacy_meaning_flags = {
                    "final_week_self_approval", "final_week_gratitude",
                }
                if isinstance(flags, list) and legacy_meaning_flags & set(flags):
                    errors.append(
                        f"{spec.root_id}.choices[{choice_index}]: final outbound "
                        "borrowed a legacy self-evaluation flag")
                if choice.get("follow_up_event") or choice.get("deferred_follow_up"):
                    errors.append(
                        f"{spec.root_id}.choices[{choice_index}]: final outbound "
                        "invented a post-finale authored follow-up")
        if spec.stage in {8, 9}:
            expected_outcomes = (
                EXPECTED_SIGNATURE_OUTCOMES
                if spec.stage == 8 else EXPECTED_OUTBOUND_OUTCOMES)
            if len(ko_choices) == len(expected_outcomes):
                for choice_index, (choice, expected) in enumerate(
                        zip(ko_choices, expected_outcomes)):
                    if choice.get("effects", {}) != expected["effects"] \
                            or choice.get("flags", []) != expected["flags"]:
                        errors.append(
                            f"{spec.root_id}.choices[{choice_index}]: canonical "
                            "final flags/effects semantics drifted")
                    if choice.get("follow_up_event") \
                            or choice.get("deferred_follow_up"):
                        errors.append(
                            f"{spec.root_id}.choices[{choice_index}]: canonical "
                            "final choice invented an authored follow-up")
    if authored_choices != 30:
        errors.append(
            f"shipping finale authored choice total is {authored_choices}, expected 30")
    validate_finale_reads(ko, en, expected_sources, errors)


def _stage_rows_valid(stages: Any, errors: list[str]) -> None:
    if stages != list(EXPECTED_STAGE_NAMES):
        errors.append(
            "finale ledger stage names/order drifted: "
            f"expected={list(EXPECTED_STAGE_NAMES)} got={stages}")


def _active_when_matches(spec: RootSpec, active_when: Any) -> bool:
    if not spec.variant:
        return active_when is None
    if not isinstance(active_when, dict):
        return False
    flattened = json.dumps(active_when, ensure_ascii=False, sort_keys=True)
    return "father" in flattened and spec.variant in flattened


def _validate_economic_outcome(
    outcome: Any, label: str, required: bool, errors: list[str],
) -> None:
    if outcome in (None, {}):
        if required:
            errors.append(f"{label}: exact no_executable_contract outcome missing")
        return
    if outcome != EXPECTED_ECONOMIC_ZERO:
        errors.append(f"{label}: economic outcome is not exact zero/nontransaction")


def validate_ledger(
    ledger: Any, errors: list[str],
) -> dict[str, list[dict[str, Any]]]:
    expected_sources: dict[str, list[dict[str, Any]]] = {}
    if not isinstance(ledger, dict):
        errors.append("Chapter 5 finale ledger root must be an object")
        return expected_sources
    expected_top = {
        "schema_version", "ledger_id", "choice_index_base",
        "expected_root_count", "expected_active_root_count",
        "expected_choice_count", "expected_active_choice_count",
        "entry_contract", "stages", "roots",
    }
    if set(ledger) != expected_top:
        errors.append(
            "Chapter 5 finale ledger top-level schema drifted: "
            f"expected={sorted(expected_top)} got={sorted(ledger)}")
    if ledger.get("schema_version") != 1 \
            or ledger.get("ledger_id") != LEDGER_ID \
            or ledger.get("choice_index_base") != 0 \
            or ledger.get("expected_root_count") != 11 \
            or ledger.get("expected_active_root_count") != 9 \
            or ledger.get("expected_choice_count") != 30 \
            or ledger.get("expected_active_choice_count") != 24:
        errors.append("Chapter 5 finale ledger id/count declaration drifted")
    entry = ledger.get("entry_contract")
    if not isinstance(entry, dict):
        errors.append("Chapter 5 finale entry_contract must be an object")
    else:
        exact_entry_keys = {
            "route_id", "turn", "profile_id", "source_route_id",
            "source_choice_keys", "father", "actor_bindings",
        }
        if set(entry) != exact_entry_keys:
            errors.append("Chapter 5 finale entry_contract schema drifted")
        required_entry = {
            "route_id": ROUTE_ID,
            "turn": 221,
            "profile_id": PROFILE_ID,
            "source_route_id": SOURCE_ROUTE_ID,
        }
        for key, expected in required_entry.items():
            if entry.get(key) != expected:
                errors.append(
                    f"Chapter 5 finale entry_contract {key} drifted: "
                    f"{entry.get(key)!r}")
        if entry.get("source_choice_keys") != {
            "m55_decision": [0, 1, 2],
            "w212_guarantee": [0, 1, 2],
            "w215_final_door": [0, 1, 2],
        }:
            errors.append("Chapter 5 finale source-choice entry domains drifted")
        if entry.get("father") != {
            "life": ["alive", "passed"],
            "contact_mode": ["present", "called", "missed", "records_only"],
        }:
            errors.append("Chapter 5 finale father entry domains drifted")
        actors = entry.get("actor_bindings")
        if not isinstance(actors, dict) or actors.get("chooser") != "player" \
                or set(actors.values()) != KNOWN_ACTORS:
            errors.append("Chapter 5 finale entry actors drifted or were invented")
    _stage_rows_valid(ledger.get("stages"), errors)
    rows = ledger.get("roots")
    if not isinstance(rows, list) or not all(isinstance(row, dict) for row in rows):
        errors.append("Chapter 5 finale ledger roots must be an object array")
        return expected_sources
    if len(rows) != 11:
        errors.append(f"Chapter 5 finale ledger must contain 11 roots, got {len(rows)}")
    actual_ids = [str(row.get("event_id", "")) for row in rows]
    if actual_ids != list(ROOT_IDS):
        errors.append(f"Chapter 5 finale ledger root order drifted: {actual_ids}")
    receipt_ids: set[str] = set()
    authored_choices = 0
    exact_root_keys = {
        "stage_sequence", "variant_sequence", "month", "turn", "week",
        "event_id", "root_id", "choice_count", "tier", "stage", "active_when",
        "actors", "read_sources", "read_mode", "choices",
    }
    for index, row in enumerate(rows):
        if index >= len(ROOTS):
            break
        spec = ROOTS[index]
        if set(row) != exact_root_keys:
            errors.append(f"{spec.root_id}: finale ledger root schema drifted")
        if row.get("stage_sequence") != spec.stage \
                or row.get("month") != spec.month \
                or row.get("turn") != spec.turn \
                or row.get("week") != spec.turn \
                or row.get("event_id") != spec.root_id \
                or row.get("root_id") != spec.root_id \
                or row.get("choice_count") != spec.choices \
                or row.get("tier") != EXPECTED_TIERS[spec.stage] \
                or row.get("stage") != EXPECTED_STAGE_NAMES[spec.stage - 1]:
            errors.append(
                f"{spec.root_id}: exact stage/month/turn/id/count/tier drifted")
        expected_variant_sequence = (
            STAGE_ROOT_IDS[spec.stage].index(spec.root_id) + 1)
        if row.get("variant_sequence") != expected_variant_sequence:
            errors.append(f"{spec.root_id}: variant sequence drifted")
        if not _active_when_matches(spec, row.get("active_when")):
            errors.append(f"{spec.root_id}: active_when variant contract drifted")
        actors = row.get("actors")
        if not isinstance(actors, dict) or actors.get("chooser") != "player" \
                or any(not isinstance(key, str) or not key
                       or value not in KNOWN_ACTORS for key, value in actors.items()):
            errors.append(f"{spec.root_id}: actor bindings are malformed or invented")
        raw_sources = row.get("read_sources")
        if not isinstance(raw_sources, list) or not raw_sources:
            errors.append(f"{spec.root_id}: ledger read_sources must be nonempty")
            raw_sources = []
        sources: list[dict[str, Any]] = []
        for source_index, source in enumerate(raw_sources):
            if _validate_source(source, spec.root_id, source_index, errors):
                sources.append(copy.deepcopy(source))
        if len(sources) == len(raw_sources):
            expected_sources[spec.root_id] = sources
        if row.get("read_mode") != "prepend":
            errors.append(f"{spec.root_id}: ledger read_mode must be prepend")
        choices = row.get("choices")
        if not isinstance(choices, list) or len(choices) != spec.choices:
            errors.append(f"{spec.root_id}: ledger choice population drifted")
            choices = []
        authored_choices += len(choices)
        for choice_index, choice in enumerate(choices):
            label = f"{spec.root_id}.choices[{choice_index}]"
            if not isinstance(choice, dict) or set(choice) != {
                "index", "receipt_ids", "document_ids", "economic_outcome",
            }:
                errors.append(f"{label}: ledger choice schema drifted")
                continue
            if choice.get("index") != choice_index:
                errors.append(f"{label}: zero-based choice index drifted")
            raw_receipts = choice.get("receipt_ids")
            if not isinstance(raw_receipts, list) or not raw_receipts \
                    or any(not isinstance(value, str) or not value
                           for value in raw_receipts):
                errors.append(f"{label}: receipt_ids must be nonempty strings")
            else:
                for receipt_id in raw_receipts:
                    if receipt_id in receipt_ids:
                        errors.append(f"duplicate finale receipt id: {receipt_id}")
                    receipt_ids.add(receipt_id)
            documents = choice.get("document_ids")
            if not isinstance(documents, list) \
                    or any(not isinstance(value, str) or not value
                           for value in documents):
                errors.append(f"{label}: document_ids must be a string array")
            _validate_economic_outcome(
                choice.get("economic_outcome"), label, spec.stage == 5, errors)
    if authored_choices != 30:
        errors.append(
            f"Chapter 5 finale ledger choice total is {authored_choices}, expected 30")
    if len(receipt_ids) < 30:
        errors.append(
            f"Chapter 5 finale ledger needs at least one unique receipt per choice; "
            f"got {len(receipt_ids)}")
    return expected_sources


def validate_lifecycle(
    lifecycle: Any, ko: dict[str, dict[str, Any]], errors: list[str],
) -> None:
    if not isinstance(lifecycle, dict):
        errors.append("event lifecycle root must be an object")
        return
    raw = lifecycle.get("author_only_event_ids")
    if not isinstance(raw, list):
        errors.append("event lifecycle author_only_event_ids must be an array")
        return
    # During concurrent assembly, roots not yet present are already reported by
    # validate_events.  Do not manufacture a second lifecycle failure for them.
    present = set(ROOT_IDS) & set(ko)
    leaked = sorted(present & {str(value) for value in raw})
    if leaked:
        errors.append(f"promoted finale roots remain author_only: {leaked}")


def validate_source_contracts(
    system_source: str,
    game_state_source: str,
    main_source: str,
    story_source: str,
    errors: list[str],
) -> None:
    if not system_source:
        errors.append("systems/Chapter5FinaleRoute.gd is missing")
        return
    required_system_api = (
        "class_name Chapter5FinaleRoute",
        "static func default_state()",
        "static func state_from_save(",
        "static func lock_entry(",
        "static func entry_locked(",
        "static func entry_snapshot(",
        "static func is_owned_event(",
        "static func expected_read_contract(",
        "static func next_event_for_turn(",
        "static func ingress_available(",
        "static func choice_commit_available(",
        "static func commit_choice(",
        "static func receipt_snapshot_by_event(",
        "static func receipt_snapshot_by_stage(",
        "static func selected_choice_by_event(",
        "static func choice_count_for_event(",
        "static func event_stage(",
        "static func week_completed(",
        "static func holds_ending(",
        "static func ending_ready(",
        "static func consume_ending_check(",
        "static func close_route(",
    )
    for marker in required_system_api:
        if marker not in system_source:
            errors.append(f"Chapter5FinaleRoute public API missing: {marker}")
    for marker in (
        f'const ROUTE_ID := "{ROUTE_ID}"',
        f'const PROFILE_ID := "{PROFILE_ID}"',
        f'const SOURCE_ROUTE_ID := "{SOURCE_ROUTE_ID}"',
        'const CLOSE_REASON_READ_SURFACE_INVALID := "read_surface_invalid"',
        "const EXPECTED_ROOT_COUNT := 11",
        "const EXPECTED_ACTIVE_ROOT_COUNT := 9",
        "const EXPECTED_CHOICE_COUNT := 30",
        "const EXPECTED_ACTIVE_CHOICE_COUNT := 24",
    ):
        if marker not in system_source:
            errors.append(f"Chapter5FinaleRoute constant missing: {marker}")
    for root_id in ROOT_IDS:
        if root_id not in system_source:
            errors.append(f"Chapter5FinaleRoute lacks owned root literal: {root_id}")
    read_contract_block = _function_block(system_source, "expected_read_contract")
    for token in ('"sources"', '"mode"'):
        if token not in read_contract_block:
            errors.append(
                f"Chapter5FinaleRoute read-contract result missing: {token}")
    forbidden_patterns = {
        "money mutation": r"\b(?:add|set)_money\s*\(",
        "AP ownership": r"\baction_points\b|\bspend_ap\s*\(",
        "transaction execution": r"\bexecute_transaction\s*\(",
        "ending execution": r"\bfinish_run\s*\(|\bcheck_game_over\s*\(",
        "asset mutation": r"\b(?:cash|money|debt|assets?)\s*[+\-*/]?=",
    }
    for label, pattern in forbidden_patterns.items():
        if re.search(pattern, system_source):
            errors.append(f"Chapter5FinaleRoute owns forbidden {label}")
    commit_block = _function_block(system_source, "commit_choice")
    for token in ("ending_check", '"ready"'):
        if token not in commit_block:
            errors.append(f"final outbound ready transition missing token: {token}")
    consume_block = _function_block(system_source, "consume_ending_check")
    for token in ("ending_check", '"ready"', '"consumed"'):
        if token not in consume_block:
            errors.append(f"finale consume transition missing token: {token}")
    holds_block = _function_block(system_source, "holds_ending")
    for token in ('"pending"', '"ready"'):
        if token not in holds_block:
            errors.append(f"finale ending hold lost state: {token}")

    required_game_state = (
        'preload("res://systems/Chapter5FinaleRoute.gd")',
        "var chapter5_finale_state:",
        '"chapter5_finale_state": chapter5_finale_state',
        "CHAPTER5_FINALE_ROUTE.state_from_save(",
        "func prepare_chapter5_finale_route_entry(",
        "func chapter5_finale_next_event_for_turn(",
        "func chapter5_finale_ingress_available(",
        "func chapter5_finale_choice_available(",
        "func record_chapter5_finale_choice(",
        "func chapter5_finale_week_completed(",
        "func chapter5_finale_holds_ending(",
        "func chapter5_finale_ending_ready(",
        "func consume_chapter5_finale_ending_check(",
    )
    for marker in required_game_state:
        if marker not in game_state_source:
            errors.append(f"GameState finale binding missing: {marker}")
    record_block = _function_block(game_state_source, "record_chapter5_finale_choice")
    for token in (
        "chapter5_finale_state.duplicate(true)",
        "CHAPTER5_FINALE_ROUTE.commit_choice(",
    ):
        if token not in record_block:
            errors.append(f"GameState finale atomic receipt wrapper missing: {token}")
    for forbidden in ("add_money(", "action_points", "finish_run("):
        if forbidden in record_block:
            errors.append(
                f"GameState finale receipt wrapper owns forbidden effect: {forbidden}")

    required_main = (
        "Chapter5FinaleRoute",
        "func _route_chapter5_finale_week(",
        "func _complete_chapter5_finale_week_after_story(",
        "chapter5_finale_next_event_for_turn",
        "chapter5_finale_week_completed",
        "chapter5_finale_ending_ready",
        "consume_chapter5_finale_ending_check",
        "_check_game_over_with_monotonic_story_state()",
    )
    for marker in required_main:
        if marker not in main_source:
            errors.append(f"MainGame direct finale ownership missing: {marker}")
    main_consume = _function_block(main_source, "_complete_chapter5_finale_week_after_story")
    consume_index = main_consume.find("consume_chapter5_finale_ending_check")
    check_marker = "_check_game_over_with_monotonic_story_state()"
    check_index = main_consume.find(check_marker)
    if consume_index < 0 or check_index < 0 or consume_index > check_index \
            or main_consume.count(check_marker) != 1:
        errors.append("MainGame must consume finale before canonical check_game_over")
    canonical_wrapper = _function_block(
        main_source, "_check_game_over_with_monotonic_story_state")
    if canonical_wrapper.count("GameState.check_game_over()") != 1:
        errors.append(
            "MainGame canonical ending wrapper must call GameState.check_game_over once")

    required_story = (
        "Chapter5FinaleRoute",
        "func _chapter5_finale_event_with_reads(",
        "func _chapter5_finale_live_ingress_allowed(",
        "func _queue_chapter5_finale_same_turn_ingress(",
        "chapter5_finale_choice_available(",
        "record_chapter5_finale_choice(",
        "chapter5_finale_choice_snapshot",
        "GameState.serialize().duplicate(true)",
        '"_restore_serialized_snapshot_exact"',
    )
    for marker in required_story:
        if marker not in story_source:
            errors.append(f"StoryMode finale transaction missing: {marker}")
    story_read_block = _function_block(
        story_source, "_chapter5_finale_event_with_reads")
    for field in ("sources", "mode"):
        if f'expected["{field}"]' not in story_read_block \
                and f'expected.get("{field}"' not in story_read_block:
            errors.append(
                f"StoryMode finale read contract does not consume expected.{field}")
    if "is_same(sources" in story_read_block:
        errors.append(
            "StoryMode compares finale read sources by identity instead of value")

    instant = _instant_legend_block(game_state_source)
    digest = hashlib.sha256(instant.encode("utf-8")).hexdigest()
    if not instant or digest != EXPECTED_INSTANT_LEGEND_SHA256:
        errors.append(
            "GameState instant_legend branch changed: "
            f"expected {EXPECTED_INSTANT_LEGEND_SHA256}, got {digest}")
    check_game_over = _function_block(game_state_source, "check_game_over")
    instant_index = check_game_over.find('finish_run("instant_legend")')
    general_index = check_game_over.find("# ── 일반 30억")
    failure_positions = [
        check_game_over.find(f'finish_run("{ending}")')
        for ending in (
            "burnout", "mental_break", "debt_spiral", "bankruptcy",
            "crypto_ghost",
        )
    ]
    if instant_index < 0 or general_index < 0 or instant_index > general_index:
        errors.append("instant_legend is not ordered before the general 30b branch")
    if any(position < 0 or position > instant_index for position in failure_positions):
        errors.append("an immediate failure ending no longer precedes instant_legend")


def validate_model(
    ko: dict[str, dict[str, Any]],
    en: dict[str, dict[str, Any]],
    ledger: Any,
    lifecycle: Any,
    system_source: str,
    game_state_source: str,
    main_source: str,
    story_source: str,
) -> list[str]:
    errors: list[str] = []
    validate_inventory(errors)
    expected_sources = validate_ledger(ledger, errors)
    validate_events(ko, en, expected_sources, errors)
    validate_lifecycle(lifecycle, ko, errors)
    validate_source_contracts(
        system_source, game_state_source, main_source, story_source, errors)
    return errors


def _fixture_sources(spec: RootSpec) -> list[dict[str, Any]]:
    if spec.stage == 1:
        return [{"kind": "causal_event", "id": "arc_y5_three_in_room_decision"}]
    sources: list[dict[str, Any]] = [
        {"kind": "finale_stage", "id": EXPECTED_STAGE_NAMES[spec.stage - 2]},
    ]
    if spec.stage == 6:
        sources.append({
            "kind": "entry_value",
            "path": "source_choices.w212_guarantee",
            "values": [0, 1, 2],
        })
    return sources


def _fixture_ledger() -> dict[str, Any]:
    roots: list[dict[str, Any]] = []
    for spec in ROOTS:
        economic = EXPECTED_ECONOMIC_ZERO if spec.stage == 5 else {}
        roots.append({
            "stage_sequence": spec.stage,
            "variant_sequence": STAGE_ROOT_IDS[spec.stage].index(spec.root_id) + 1,
            "month": spec.month,
            "turn": spec.turn,
            "week": spec.turn,
            "event_id": spec.root_id,
            "root_id": spec.root_id,
            "choice_count": spec.choices,
            "tier": EXPECTED_TIERS[spec.stage],
            "stage": EXPECTED_STAGE_NAMES[spec.stage - 1],
            "active_when": (
                {"path": "father.life", "equals": spec.variant}
                if spec.variant else None),
            "actors": {"chooser": "player"},
            "read_sources": _fixture_sources(spec),
            "read_mode": "prepend",
            "choices": [
                {
                    "index": index,
                    "receipt_ids": [f"{spec.root_id}_{index}"],
                    "document_ids": [],
                    "economic_outcome": copy.deepcopy(economic),
                }
                for index in range(spec.choices)
            ],
        })
    return {
        "schema_version": 1,
        "ledger_id": LEDGER_ID,
        "choice_index_base": 0,
        "expected_root_count": 11,
        "expected_active_root_count": 9,
        "expected_choice_count": 30,
        "expected_active_choice_count": 24,
        "entry_contract": {
            "route_id": ROUTE_ID,
            "turn": 221,
            "profile_id": PROFILE_ID,
            "source_route_id": SOURCE_ROUTE_ID,
            "source_choice_keys": {
                "m55_decision": [0, 1, 2],
                "w212_guarantee": [0, 1, 2],
                "w215_final_door": [0, 1, 2],
            },
            "father": {
                "life": ["alive", "passed"],
                "contact_mode": [
                    "present", "called", "missed", "records_only",
                ],
            },
            "actor_bindings": {
                "chooser": "player",
                "father": "father",
                "protected_person": "daeun",
                "guarantee_party": "jaehyuk",
                "reviewer": "sangchul",
                "proposer": "sangchul",
                "cost_witness": "minseo",
            },
        },
        "stages": list(EXPECTED_STAGE_NAMES),
        "roots": roots,
    }


def _fixture_events(
    ledger: dict[str, Any], author_only: bool = False,
) -> tuple[dict[str, dict[str, Any]], dict[str, dict[str, Any]]]:
    ko: dict[str, dict[str, Any]] = {
        "arc_y5_three_in_room_decision": {
            "id": "arc_y5_three_in_room_decision",
            "choices": [{"text": "a"}, {"text": "b"}, {"text": "c"}],
        },
    }
    en: dict[str, dict[str, Any]] = {}
    rows_by_id = {row["event_id"]: row for row in ledger["roots"]}
    for spec in ROOTS:
        tags = ["story", "arc", "chapter5"]
        if author_only:
            tags.append("author_only")
        sources = rows_by_id[spec.root_id]["read_sources"]
        texts: list[list[str]] = []
        en_texts: list[list[str]] = []
        for source_index, source in enumerate(sources):
            count = _source_choice_count(source, ko)
            texts.append([
                f"{spec.root_id} 근거 {source_index}-{index}"
                for index in range(count)
            ])
            en_texts.append([
                f"{spec.root_id} source {source_index}-{index}"
                for index in range(count)
            ])
        ko_choices: list[dict[str, Any]] = []
        for index in range(spec.choices):
            choice: dict[str, Any] = {
                "text": f"선택 {index}", "result_text": f"결과 {index}",
            }
            if spec.stage == 8:
                choice.update(copy.deepcopy(EXPECTED_SIGNATURE_OUTCOMES[index]))
            elif spec.stage == 9:
                choice.update(copy.deepcopy(EXPECTED_OUTBOUND_OUTCOMES[index]))
            ko_choices.append(choice)
        ko[spec.root_id] = {
            "id": spec.root_id,
            "title": "장면",
            "description": "{name}의 문서",
            "weight": 0,
            "hidden": True,
            "conditions": {"min_turn": 9999},
            "tags": tags,
            "choices": ko_choices,
            "chapter5_finale_reads": {
                "sources": copy.deepcopy(sources),
                "texts": texts,
                "mode": "prepend",
            },
        }
        en[spec.root_id] = {
            "id": spec.root_id,
            "title": "Scene",
            "description": "{name}'s document",
            "choices": [
                {"text": f"Choice {index}", "result_text": f"Result {index}"}
                for index in range(spec.choices)
            ],
            "chapter5_finale_reads": {"texts": en_texts},
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
    validate_inventory(errors)
    check(not errors, errors[0] if errors else "valid inventory rejected")

    ledger = _fixture_ledger()
    errors = []
    sources = validate_ledger(ledger, errors)
    check(not errors, errors[0] if errors else "valid ledger fixture rejected")

    ko, en = _fixture_events(ledger)
    errors = []
    validate_events(ko, en, sources, errors)
    check(not errors, errors[0] if errors else "valid event fixture rejected")

    choice_mutation = copy.deepcopy(ko)
    choice_mutation[ROOT_IDS[2]]["choices"].pop()
    errors = []
    validate_events(choice_mutation, en, sources, errors)
    check(any("expected 2 KO choices" in error for error in errors),
          "choice-count mutation was accepted")

    source_order = copy.deepcopy(ko)
    two_source_root = "arc_y5_remaining_jaehyuk_or_self"
    source_order[two_source_root]["chapter5_finale_reads"]["sources"].reverse()
    errors = []
    validate_events(source_order, en, sources, errors)
    check(any("source order drifted" in error for error in errors),
          "read-source order mutation was accepted")

    prose_row_order = copy.deepcopy(ko)
    prose_row_order[two_source_root]["chapter5_finale_reads"]["texts"].reverse()
    errors = []
    validate_events(prose_row_order, en, sources, errors)
    check(any("expected 1 distinct" in error or "expected 3 distinct" in error
              for error in errors), "prose read-row order mutation was accepted")

    duplicate_prose = copy.deepcopy(ko)
    duplicate_prose[ROOT_IDS[0]]["chapter5_finale_reads"]["texts"][0][1] = \
        duplicate_prose[ROOT_IDS[0]]["chapter5_finale_reads"]["texts"][0][0]
    errors = []
    validate_events(duplicate_prose, en, sources, errors)
    check(any("distinct nonempty" in error for error in errors),
          "duplicate prose-read mutation was accepted")

    overlay_gameplay = copy.deepcopy(en)
    overlay_gameplay[ROOT_IDS[0]]["chapter5_finale_reads"]["mode"] = "prepend"
    errors = []
    validate_events(ko, overlay_gameplay, sources, errors)
    check(any("EN finale overlay must own texts only" in error for error in errors),
          "EN read-source gameplay mutation was accepted")

    tagged_ko, _ = _fixture_events(ledger, author_only=True)
    errors = []
    validate_events(tagged_ko, en, sources, errors)
    check(any("author_only tag remains" in error for error in errors),
          "author_only mutation was accepted")

    economic_mutation = copy.deepcopy(ledger)
    economic_mutation["roots"][5]["choices"][0]["economic_outcome"][
        "cash_delta_krw"] = 1
    errors = []
    validate_ledger(economic_mutation, errors)
    check(any("not exact zero/nontransaction" in error for error in errors),
          "nonzero economic mutation was accepted")

    instant_fixture = (
        "func check_game_over():\n"
        "\t# ── 첫해 30억 = 즉시 비밀 엔딩 ──────────────────────\n"
        "\t# 현재 자산으로 첫해 안에 30억을 만든 순간만 신화로 즉시 닫는다.\n"
        "\t# 과거 peak만으로 나중에 이 비밀 엔딩이 발동해서는 안 된다.\n"
        "\tif total_now >= 3_000_000_000:\n"
        "\t\t# ★ 히든 이스터에그 — 첫 해(33세=챕터1)에 30억은 거의 불가능한 초고속 달성.\n"
        "\t\t#   변칙 플레이(경마/투자 대박)에 대한 보상 엔딩. 인물 아크는 챕터2+라\n"
        "\t\t#   아직 아무도 못 만난 상태 → 빈 집 대신 '신화' 엔딩으로 인정해준다.\n"
        "\t\tif age <= 33:\n"
        "\t\t\tfinish_run(\"instant_legend\"); return\n"
        "\n\t# ── 일반 30억 = M60 마지막 서명 뒤 성공 엔딩")
    check(
        hashlib.sha256(_instant_legend_block(instant_fixture).encode()).hexdigest()
        == EXPECTED_INSTANT_LEGEND_SHA256,
        "valid instant_legend block rejected",
    )
    changed = instant_fixture.replace("age <= 33", "age <= 34")
    check(
        hashlib.sha256(_instant_legend_block(changed).encode()).hexdigest()
        != EXPECTED_INSTANT_LEGEND_SHA256,
        "instant_legend mutation was accepted",
    )
    return cases


def _optional_json(path: Path, errors: list[str], label: str) -> Any:
    try:
        return load_json(path)
    except FileNotFoundError:
        errors.append(f"{label} is missing: {path.relative_to(ROOT)}")
    except (OSError, json.JSONDecodeError) as exc:
        errors.append(f"{label} could not be loaded: {exc}")
    return None


def _optional_text(path: Path, errors: list[str], label: str) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except OSError as exc:
        errors.append(f"{label} could not be loaded: {exc}")
        return ""


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    if args.self_test:
        try:
            cases = run_self_test()
        except AssertionError as exc:
            print(f"CHAPTER5_FINALE_ROUTE_SELF_TEST_FAIL {exc}", file=sys.stderr)
            return 1
        print(f"CHAPTER5_FINALE_ROUTE_SELF_TEST_OK cases={cases}")
        return 0

    load_errors: list[str] = []
    try:
        ko = load_events(KO_DIR)
        en = load_events(EN_DIR)
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        print(f"CHAPTER5_FINALE_ROUTE_AUDIT_FAIL {exc}", file=sys.stderr)
        return 1
    ledger = _optional_json(LEDGER, load_errors, "finale ledger")
    lifecycle = _optional_json(LIFECYCLE, load_errors, "event lifecycle")
    system_source = _optional_text(SYSTEM, load_errors, "finale reducer")
    game_state_source = _optional_text(GAME_STATE, load_errors, "GameState")
    main_source = _optional_text(MAIN_GAME, load_errors, "MainGame")
    story_source = _optional_text(STORY_MODE, load_errors, "StoryMode")
    errors = load_errors + validate_model(
        ko, en, ledger, lifecycle, system_source, game_state_source,
        main_source, story_source,
    )
    if errors:
        print(f"CHAPTER5_FINALE_ROUTE_AUDIT_FAIL errors={len(errors)}")
        for error in errors:
            print(f"  ERROR {error}")
        return 1
    print(
        "CHAPTER5_FINALE_ROUTE_AUDIT_OK "
        "stages=9 active_roots=9 active_choices=24 "
        "authored_roots=11 authored_choices=30 variants=father2x2 "
        "reads=typed-ko/en-text-only economy=no_executable_contract/zero "
        "ending=pending-ready-consumed instant_legend=preserved"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
