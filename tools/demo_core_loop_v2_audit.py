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
HANGUL_RE = re.compile(r"[가-힣]")

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
EXPECTED_CONTRACT_ROOT_KEYS = {
    "schema_version",
    "status",
    "runtime_default",
    "fallback",
    "scope",
    "long_arc_contract",
    "future_application_contracts",
    "deferred_callback_contracts",
    "surface",
    "routine",
    "relationship",
    "exclusive_groups",
    "decline_outcomes",
    "scene_bundles",
    "months",
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
ALLOWED_PREREQUISITE_GROUPS = {"all", "any"}
ALLOWED_PREREQUISITE_KINDS = {
    "completed_bundle",
    "relationship_at_least",
    "relationship_memory",
    "player_initiated",
    "routine_selected",
    "application_status",
}
LEGACY_REQUIREMENT_KEYS = {
    "eligibility",
    "requires_completed_bundle",
    "requires_player_initiated",
    "requires_prior_choice",
}
RELATIONSHIP_INITIATIVES = {"world", "player", "reciprocal"}
M3_ACTION_IDS = {
    "m3_hanbit_application",
    "m3_inventory_shift",
    "m3_empty_saturday",
    "m3_room_ledger",
    "m3_library_job_board",
}
EXPECTED_M3_ACTION_CORE = {
    "m3_hanbit_application": {
        "execution": "application",
        "application_id": "hanbit_ops_2026q1",
        "job_id": "job_03",
        "status": "submitted",
    },
    "m3_inventory_shift": {
        "execution": "instant_effect",
        "axis": "money",
        "place_id": "work",
        "effects": {"money": 360_000, "health": -4, "mental": -3},
    },
    "m3_empty_saturday": {
        "execution": "rest",
        "effects": {"health": 4, "mental": 6},
        "recovery_routine_effects": {"health": 2, "mental": 3},
    },
    "m3_room_ledger": {
        "execution": "rest",
        "effects": {"health": 1, "mental": 2},
        "recovery_routine_effects": {"mental": 1},
    },
    "m3_library_job_board": {
        "execution": "instant_effect",
        "axis": "human",
        "place_id": "city",
        "effects": {"intelligence": 1},
    },
}
EXPECTED_APPLICATION_OUTCOMES = {
    "opening_interview_math": [
        {
            "event_id": "arc_intro_01_meal",
            "choices": [0, 1],
            "application_id": "mirae_industrial_tech",
            "from": "submitted",
            "to": "interviewed",
        }
    ],
    "m2_mirae_result_message": [
        {
            "event_id": "v2_mirae_result_message",
            "choices": [0],
            "application_id": "mirae_industrial_tech",
            "from": "interviewed",
            "to": "no_offer",
        }
    ],
    "m3_seorin_result_message": [
        {
            "event_id": "v2_seorin_result_message",
            "choices": [0],
            "application_id": "seorin_contract_2026q1",
            "from": "submitted",
            "to": "no_offer",
        }
    ],
}
EXPECTED_FUTURE_APPLICATION_CONTRACTS = {
    "m4_hanbit_interview": {
        "producer_bundle": "m3_hanbit_application",
        "application_id": "hanbit_ops_2026q1",
        "from": "submitted",
        "to": "interviewed",
        "owner_month": 4,
        "allowed_weeks": [13, 14, 15, 16],
        "activation_cap_week": 16,
        "runtime_surface": "deferred",
    }
}
EXPECTED_DEFERRED_CALLBACK_CONTRACTS = {
    "callback_escaped_dirty_trace": {
        "producer_bundle": "temptation_consequence",
        "producer_event": "arc_temptation_fallout",
        "producer_choices": [0],
        "scheduled_week": 8,
        "delay_weeks": 16,
        "due_week": 24,
        "final_owner_bundle": "demo_collision",
        "consume_phase": "before_owner_scene",
        "activation_cap_week": 24,
    }
}
EXPECTED_B_PREREQUISITES = {
    "father_quiet_call": {
        "all": [
            {"kind": "completed_bundle", "bundle_id": "father_first_call"},
            {
                "kind": "relationship_at_least",
                "character": "father",
                "stage": "met",
            },
        ],
        "any": [
            {
                "kind": "relationship_memory",
                "character": "father",
                "memory": "father_wellbeing_returned",
            },
            {
                "kind": "relationship_memory",
                "character": "father",
                "memory": "father_future_reassured",
            },
            {
                "kind": "relationship_memory",
                "character": "father",
                "memory": "father_call_ended_quickly",
            },
        ],
    },
    "hyunsu_study_followup": {
        "all": [
            {"kind": "completed_bundle", "bundle_id": "hyunsu_player_reachout"},
            {
                "kind": "relationship_at_least",
                "character": "hyunsu",
                "stage": "player_reached_out",
            },
            {"kind": "player_initiated", "character": "hyunsu"},
        ],
        "any": [
            {
                "kind": "relationship_memory",
                "character": "hyunsu",
                "memory": "hyunsu_resume_shared",
            },
            {
                "kind": "relationship_memory",
                "character": "hyunsu",
                "memory": "hyunsu_problem_set_shared",
            },
        ],
    },
    "daeun_world_meet": {
        "all": [
            {"kind": "routine_selected", "track": "livelihood"},
        ]
    },
    "jiyeon_world_meet": {
        "all": [
            {
                "kind": "completed_bundle",
                "bundle_id": "m2_rain_delivery_shift",
            }
        ]
    },
    "hyunsu_player_reachout": {
        "all": [
            {"kind": "completed_bundle", "bundle_id": "hyunsu_first_meet"},
            {
                "kind": "relationship_at_least",
                "character": "hyunsu",
                "stage": "opening",
            },
        ],
        "any": [
            {
                "kind": "relationship_memory",
                "character": "hyunsu",
                "memory": "hyunsu_honest_uncertainty",
            },
            {
                "kind": "relationship_memory",
                "character": "hyunsu",
                "memory": "hyunsu_declared_dream",
            },
        ],
    },
}
EXPECTED_M3_DECLINES = {
    "m3_hanbit_application": ("next_month_message", 4),
    "m3_inventory_shift": ("next_month_message", 4),
    "m3_empty_saturday": ("next_matching_bundle", 3),
    "m3_room_ledger": ("next_month_message", 4),
    "m3_library_job_board": ("next_month_message", 4),
    "father_quiet_call": ("next_month_message", 4),
    "hyunsu_study_followup": ("next_month_message", 4),
    "daeun_world_meet": ("next_month_message", 4),
    "jiyeon_world_meet": ("next_month_message", 4),
}
EXPECTED_M3_ALLOWED_WEEKS = {
    "m3_hanbit_application": [9],
    "m3_inventory_shift": [9, 10, 11],
    "m3_empty_saturday": [9, 10, 11],
    "m3_room_ledger": [9, 10, 11, 12],
    "m3_library_job_board": [9, 10, 11, 12],
    "father_quiet_call": [9, 10, 11, 12],
    "hyunsu_study_followup": [9, 10, 11, 12],
    "daeun_world_meet": [10, 11, 12],
    "jiyeon_world_meet": [10, 11, 12],
}
EXPECTED_CHOICE_RECEIPTS = {
    "father_first_call": {
        0: ("unmet", "opening", "reciprocal", "father_wellbeing_returned"),
        1: ("unmet", "opening", "reciprocal", "father_future_reassured"),
        2: ("unmet", "opening", "reciprocal", "father_call_ended_quickly"),
    },
    "hyunsu_first_meet": {
        0: ("unmet", "opening", "world", "hyunsu_honest_uncertainty"),
        1: ("unmet", "opening", "world", "hyunsu_declared_dream"),
    },
    "hyunsu_player_reachout": {
        0: (
            "opening",
            "player_reached_out",
            "player",
            "hyunsu_resume_shared",
        ),
        1: (
            "opening",
            "player_reached_out",
            "player",
            "hyunsu_problem_set_shared",
        ),
    },
    "father_quiet_call": {
        0: (
            "opening",
            "opening",
            "player",
            "father_gangnam_words_held_back",
        ),
        1: (
            "opening",
            "opening",
            "player",
            "father_quiet_call_ended",
        ),
        2: (
            "opening",
            "opening",
            "player",
            "father_asked_more",
        ),
    },
    "hyunsu_study_followup": {
        0: (
            "player_reached_out",
            "shared_commitment",
            "reciprocal",
            "hyunsu_same_hour_confirmed",
        ),
        1: (
            "player_reached_out",
            "shared_commitment",
            "reciprocal",
            "hyunsu_one_problem_each_agreed",
        ),
    },
    "daeun_world_meet": {
        0: ("unmet", "opening", "world", "daeun_name_exchanged"),
        1: ("unmet", "met", "world", "daeun_kept_distance"),
    },
}
EXPECTED_ROUTINE_EFFECTS = {
    "livelihood": {
        "unemployed": {"money": 70_000, "health": -1, "mental": -1},
        "employed": {"work_performance": 1, "mental": -1},
    },
    "growth": {"intelligence": 1, "mental": -1},
    "recovery": {"health": 1, "mental": 3},
}
KO_SURFACE_FILES = (
    ROOT / "scenes" / "CoreLoopPlanner.gd",
    ROOT / "scenes" / "MainGame.gd",
)
BANNED_KO_SURFACE_FRAGMENTS = {
    "닫힌 문": "say which option was not chosen or what actually changed",
    "놓친 문": "say which option was not chosen or what actually changed",
    "배경 루틴": "use the player-facing phrase for an activity repeated each week",
    "전경 약속": "name the activity instead of exposing the design layer",
    "다음 한 단": "name the next asset goal",
    "다음 안부를 열": "describe the actual call",
    "다음 공부 약속을 열": "describe who contacted whom and what day they set",
    "다음 약속을 열": "describe who contacted whom and what they arranged",
    "달력에 넣은 약속과": "list completed and unchosen activities directly",
    "지금 남은 몸과 돈": "name cash, health, and mental state directly",
    "기록 안에서 정리": "state the unresolved choice directly",
    "열린 틈은 식": "state that no one suggested meeting again",
    "먼저 열린 틈은 식": "state that no one suggested meeting again",
    "채용 창구": "use the application deadline",
    "연습 창구": "use the remaining appointment or session",
    "야간 창구": "name the paid shift directly",
    "민준이 먼저 만든 한 시간": "describe the earlier study meeting directly",
    "강남의 숫자": "name property prices or the relevant amount",
    "비교의 압박": "describe the repeated comparison behavior",
    "물을 끓는 동안": "use grammatically correct subject or object marking",
    "밀린 잠을 갚": "say that the player sleeps or rests",
    "이번 달 남은 일요일": "state which usable Sunday remains",
    "경력 공백을 숨기지 않는 문장": "say that the application does not hide the gap",
    "잠이 뒤집혀": "describe the late shift and sleeplessness directly",
    "현수가 먼저 물은 공부 약속": "say that Hyunsu proposed the next study meeting",
    "답은 장면 안에서 정한다": "tell the player that the fixed call cannot be skipped",
    "야간 생계 일정": "name the late shift directly",
    "고르지 않은 뒤 달라진 일": "label the concrete results of unchosen options",
    "민준이 연락하지 않는 동안": "do not hard-code a customizable player name",
    "민준이 다시 아버지에게": "use first person or omit the player-name subject",
    "민준이 먼저 현수에게": "use first person or omit the player-name subject",
    "지난 %d개월 동안 민준이": "use first person or omit the player-name subject",
    "알람도 약속도 끄고": "turn off the alarm and say there was no appointment",
    "사람을 만날 일이 적은 달": "do not invent a quiet month from unrelated state",
    "사람 약속이 적은 달": "do not invent a quiet month from unrelated state",
    "아버지가 별일 없다고": "do not invent dialogue absent from the authored call",
    "월세가 모자란 밤": "do not assume a dynamic balance is short of rent",
    "전화를 받고 답해야": "the temptation arrives by text message, not a call",
    "차단한 번호만 통화 기록": "record the blocked number in the block list",
    "비 예보 금요일 배달": "use the natural modifier 비가 예보된",
    "불 꺼진 방의 피드": "name the concrete action of viewing the SNS feed",
    "이름을 알고 다시 여는 편의점 문": "name the return visit directly",
    "이름을 묻지 못한 편의점으로": "name the return visit with a complete verb",
    "문을 보여 주는 사람": "name the month's work and relationship conflict",
}
ACTIVE_KO_EVENT_IDS = {
    "arc_intro_01_meal",
    "arc_intro_03_sns",
    "arc_jiyeon_01_crash",
    "arc_temptation_01",
    "arc_temptation_clean",
    "arc_temptation_fallout",
    "arc_daeun_01_meet",
    "arc_father_quiet_call",
    "v2_mirae_result_message",
    "v2_seorin_result_message",
    "v2_hyunsu_player_reachout",
    "v2_hyunsu_first_study",
    "v2_hyunsu_study_followup",
    "cafe_00",
    "cafe_listen_01",
    "cafe_peek_01",
    "cafe_caught_honest",
    "cafe_talk_01",
    "cafe_humble",
    "cafe_bluff_01",
    "cafe_bluff_caught",
    "cafe_bluff_recover",
    "cafe_mind_01",
}
BANNED_KO_EVENT_FRAGMENTS = {
    "한심한 자존심": "the narrator must record behavior, not judge the player",
    "깨끗한 손": "the narrator must record behavior, not assign moral purity",
    "떳떳한 길": "the narrator must record behavior, not assign moral purity",
    "첫 공부 약속이 끝난 지 일주일": "the follow-up occurs several weeks later",
    "다음 주에도 같은 시간": "do not create an unowned next-week appointment",
    "다음 주 같은 시간을 달력": "do not create an unowned next-week appointment",
    "통장에 50만원": "the café scene must not hard-code a dynamic cash balance",
    "5만원도 없는 놈": "an NPC cannot infer a dynamic cash balance from clothing",
    "야간 일을 마친 새벽": "livelihood does not guarantee a night shift",
    "작은 이름 두 개가 오갔다": "say directly that the two people exchanged names",
    "다음에 하려고 끊었다": "say which topic was deferred to the next call",
    "강남은 — 허세를 가장 먼저 알아본다": "record who exposed the bluff",
    "허세는 강남에서 가장 빨리 죽는 길": "record the concrete lesson",
    "호의가 익숙하지 않은 사람은": "record the player's action, not a maxim",
    "LTV 70 나오는": "use a complete, solvable investment calculation",
}


def fail(message: str, errors: list[str]) -> None:
    errors.append(message)


def load_contract_without_duplicate_keys() -> dict[str, Any]:
    def reject_duplicate_keys(pairs: list[tuple[str, Any]]) -> dict[str, Any]:
        result: dict[str, Any] = {}
        for key, value in pairs:
            if key in result:
                raise ValueError(f"duplicate JSON key {key!r}")
            result[key] = value
        return result

    raw = CONTRACT_PATH.read_text(encoding="utf-8")
    value = json.loads(raw, object_pairs_hook=reject_duplicate_keys)
    if not isinstance(value, dict):
        raise ValueError("root must be an object")
    return value


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


def validate_korean_player_copy(
    contract: dict[str, Any], errors: list[str]
) -> None:
    def walk(value: Any, owner: str) -> None:
        if isinstance(value, dict):
            for key, child in value.items():
                child_owner = f"{owner}.{key}"
                if key.endswith("_ko") and isinstance(child, str):
                    for fragment, replacement_rule in (
                        BANNED_KO_SURFACE_FRAGMENTS.items()
                    ):
                        if fragment in child:
                            fail(
                                f"{child_owner} exposes translationese "
                                f"{fragment!r}; {replacement_rule}",
                                errors,
                            )
                walk(child, child_owner)
        elif isinstance(value, list):
            for index, child in enumerate(value):
                walk(child, f"{owner}[{index}]")

    walk(contract, "contract")
    string_literal = re.compile(r'"((?:\\.|[^"\\])*)"')
    for path in KO_SURFACE_FILES:
        try:
            source = path.read_text(encoding="utf-8")
        except OSError as exc:
            fail(f"cannot read Korean surface {path.relative_to(ROOT)}: {exc}", errors)
            continue
        for literal in string_literal.findall(source):
            for fragment, replacement_rule in BANNED_KO_SURFACE_FRAGMENTS.items():
                if fragment in literal:
                    fail(
                        f"{path.relative_to(ROOT)} exposes translationese "
                        f"{fragment!r}; {replacement_rule}",
                        errors,
                    )


def validate_korean_active_event_copy(
    registered_events: dict[str, dict[str, Any]], errors: list[str]
) -> None:
    def walk(value: Any, owner: str) -> None:
        if isinstance(value, dict):
            for key, child in value.items():
                walk(child, f"{owner}.{key}")
        elif isinstance(value, list):
            for index, child in enumerate(value):
                walk(child, f"{owner}[{index}]")
        elif isinstance(value, str):
            for fragment, replacement_rule in BANNED_KO_EVENT_FRAGMENTS.items():
                if fragment in value:
                    fail(
                        f"{owner} exposes invalid Korean copy {fragment!r}; "
                        f"{replacement_rule}",
                        errors,
                    )

    for event_id in sorted(ACTIVE_KO_EVENT_IDS):
        event = registered_events.get(event_id)
        if event is None:
            fail(f"active Korean copy audit references missing event {event_id}", errors)
            continue
        walk(event, f"event {event_id}")


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


def validate_prerequisites(
    bundle_id: str,
    raw_prerequisites: Any,
    bundles: dict[str, Any],
    routine_tracks: set[str],
    errors: list[str],
) -> None:
    prerequisites = require_dict(
        raw_prerequisites, f"{bundle_id}.prerequisites", errors
    )
    if not prerequisites:
        fail(f"{bundle_id}.prerequisites must contain at least one group", errors)
        return
    unknown_groups = set(prerequisites) - ALLOWED_PREREQUISITE_GROUPS
    if unknown_groups:
        fail(
            f"{bundle_id}.prerequisites has unknown groups "
            f"{sorted(unknown_groups)}",
            errors,
        )
    clause_count = 0
    for group_name in sorted(ALLOWED_PREREQUISITE_GROUPS):
        if group_name not in prerequisites:
            continue
        clauses = require_list(
            prerequisites.get(group_name),
            f"{bundle_id}.prerequisites.{group_name}",
            errors,
        )
        if not clauses:
            fail(
                f"{bundle_id}.prerequisites.{group_name} cannot be empty",
                errors,
            )
        clause_count += len(clauses)
        for index, raw_clause in enumerate(clauses):
            owner = f"{bundle_id}.prerequisites.{group_name}[{index}]"
            clause = require_dict(raw_clause, owner, errors)
            kind = str(clause.get("kind", "")).strip()
            if kind not in ALLOWED_PREREQUISITE_KINDS:
                fail(f"{owner} has unsupported kind {kind!r}", errors)
                continue
            expected_keys = {"kind"}
            if kind == "completed_bundle":
                expected_keys.add("bundle_id")
                required_bundle = str(clause.get("bundle_id", "")).strip()
                if not required_bundle:
                    fail(f"{owner}.bundle_id cannot be empty", errors)
                elif required_bundle not in bundles:
                    fail(
                        f"{owner} references missing bundle {required_bundle}",
                        errors,
                    )
            elif kind == "relationship_at_least":
                expected_keys.update({"character", "stage"})
                if not str(clause.get("character", "")).strip():
                    fail(f"{owner}.character cannot be empty", errors)
                if str(clause.get("stage", "")) not in EXPECTED_STAGES:
                    fail(f"{owner}.stage is not a relationship stage", errors)
            elif kind == "relationship_memory":
                expected_keys.update({"character", "memory"})
                if not str(clause.get("character", "")).strip():
                    fail(f"{owner}.character cannot be empty", errors)
                if not str(clause.get("memory", "")).strip():
                    fail(f"{owner}.memory cannot be empty", errors)
            elif kind == "player_initiated":
                expected_keys.add("character")
                if not str(clause.get("character", "")).strip():
                    fail(f"{owner}.character cannot be empty", errors)
            elif kind == "routine_selected":
                expected_keys.add("track")
                if str(clause.get("track", "")) not in routine_tracks:
                    fail(f"{owner}.track is not an executable routine", errors)
            elif kind == "application_status":
                expected_keys.update({"application_id", "status"})
                if not str(clause.get("application_id", "")).strip():
                    fail(f"{owner}.application_id cannot be empty", errors)
                if not str(clause.get("status", "")).strip():
                    fail(f"{owner}.status cannot be empty", errors)
            unknown_keys = set(clause) - expected_keys
            missing_keys = expected_keys - set(clause)
            if unknown_keys:
                fail(f"{owner} has unknown keys {sorted(unknown_keys)}", errors)
            if missing_keys:
                fail(f"{owner} is missing keys {sorted(missing_keys)}", errors)
    if clause_count == 0:
        fail(f"{bundle_id}.prerequisites has no clauses", errors)


def validate_application_outcomes(
    bundles: dict[str, Any],
    registered_events: dict[str, dict[str, Any]],
    errors: list[str],
) -> None:
    actual_owners = {
        str(bundle_id)
        for bundle_id, raw_bundle in bundles.items()
        if isinstance(raw_bundle, dict) and "application_outcomes" in raw_bundle
    }
    expected_owners = set(EXPECTED_APPLICATION_OUTCOMES)
    if actual_owners != expected_owners:
        fail(
            "application outcome owners drifted: expected "
            f"{sorted(expected_owners)}, got {sorted(actual_owners)}",
            errors,
        )

    for bundle_id, expected_rows in EXPECTED_APPLICATION_OUTCOMES.items():
        bundle = require_dict(
            bundles.get(bundle_id), f"bundle {bundle_id}", errors
        )
        rows = require_list(
            bundle.get("application_outcomes"),
            f"{bundle_id}.application_outcomes",
            errors,
        )
        if rows != expected_rows:
            fail(
                f"{bundle_id}.application_outcomes drifted: expected "
                f"{expected_rows}, got {rows}",
                errors,
            )
        roots = {
            str(value)
            for value in require_list(
                bundle.get("existing_roots"),
                f"{bundle_id}.existing_roots",
                errors,
            )
        }
        prerequisite_states = {
            (
                str(clause.get("application_id", "")),
                str(clause.get("status", "")),
            )
            for clauses in require_dict(
                bundle.get("prerequisites"),
                f"{bundle_id}.prerequisites",
                errors,
            ).values()
            if isinstance(clauses, list)
            for clause in clauses
            if isinstance(clause, dict)
            and clause.get("kind") == "application_status"
        }
        for index, raw_row in enumerate(rows):
            row = require_dict(
                raw_row, f"{bundle_id}.application_outcomes[{index}]", errors
            )
            event_id = str(row.get("event_id", ""))
            if event_id not in roots:
                fail(
                    f"{bundle_id} application outcome event {event_id} "
                    "is not owned by the bundle",
                    errors,
                )
            event = require_dict(
                registered_events.get(event_id),
                f"registered event {event_id}",
                errors,
            )
            event_choices = require_list(
                event.get("choices"),
                f"registered event {event_id}.choices",
                errors,
            )
            mapped_choices = row.get("choices")
            if mapped_choices != list(range(len(event_choices))):
                fail(
                    f"{bundle_id} must map every {event_id} terminal choice "
                    f"exactly once; got {mapped_choices}",
                    errors,
                )
            required_state = (
                str(row.get("application_id", "")),
                str(row.get("from", "")),
            )
            if required_state not in prerequisite_states:
                fail(
                    f"{bundle_id} does not require its application transition "
                    f"source state {required_state}",
                    errors,
                )

    mirae_submission = EXPECTED_APPLICATION_OUTCOMES[
        "opening_interview_math"
    ][0]
    mirae_result = EXPECTED_APPLICATION_OUTCOMES[
        "m2_mirae_result_message"
    ][0]
    if (
        mirae_submission["application_id"] != mirae_result["application_id"]
        or mirae_submission["to"] != mirae_result["from"]
    ):
        fail(
            "Mirae's submitted-to-interviewed transition no longer feeds "
            "the interviewed-to-no_offer result",
            errors,
        )


def validate_future_application_contracts(
    raw_contracts: Any,
    bundles: dict[str, Any],
    months: list[Any],
    development_cap_week: int,
    errors: list[str],
) -> None:
    contracts = require_dict(
        raw_contracts, "future_application_contracts", errors
    )
    if contracts != EXPECTED_FUTURE_APPLICATION_CONTRACTS:
        fail(
            "future application contracts drifted: expected "
            f"{EXPECTED_FUTURE_APPLICATION_CONTRACTS}, got {contracts}",
            errors,
        )

    for owner_id, expected in EXPECTED_FUTURE_APPLICATION_CONTRACTS.items():
        row = require_dict(
            contracts.get(owner_id),
            f"future_application_contracts.{owner_id}",
            errors,
        )
        producer_id = str(row.get("producer_bundle", ""))
        producer = require_dict(
            bundles.get(producer_id), f"bundle {producer_id}", errors
        )
        action_config = require_dict(
            producer.get("action_config"),
            f"{producer_id}.action_config",
            errors,
        )
        if (
            action_config.get("execution") != "application"
            or action_config.get("application_id") != row.get("application_id")
            or action_config.get("status") != row.get("from")
        ):
            fail(
                f"{owner_id} does not consume the exact application status "
                f"produced by {producer_id}",
                errors,
            )

        owner_month = int(row.get("owner_month", 0))
        allowed_weeks = row.get("allowed_weeks")
        expected_weeks = list(
            range((owner_month - 1) * 4 + 1, owner_month * 4 + 1)
        )
        if allowed_weeks != expected_weeks:
            fail(
                f"{owner_id} future interview window must be {expected_weeks}",
                errors,
            )
        activation_cap_week = int(row.get("activation_cap_week", 0))
        if (
            activation_cap_week != expected_weeks[-1]
            or activation_cap_week <= development_cap_week
            or row.get("runtime_surface") != "deferred"
        ):
            fail(
                f"{owner_id} must remain deferred until the Week "
                f"{expected_weeks[-1]} gate",
                errors,
            )
        if owner_id in bundles:
            fail(
                f"{owner_id} exposes an unfinished runtime bundle before "
                f"the Week {activation_cap_week} gate",
                errors,
            )

        for month_index, raw_month in enumerate(months, start=1):
            month = require_dict(raw_month, f"month {month_index}", errors)
            surface_ids = {
                str(value)
                for collection in (
                    "offers",
                    "fallback_offers",
                    "prelude",
                    "conditional_consequences",
                    "closing",
                )
                for value in month.get(collection, [])
            }
            surface_ids.update(
                str(lock.get("bundle", ""))
                for lock in month.get("locked", [])
                if isinstance(lock, dict)
            )
            if owner_id in surface_ids:
                fail(
                    f"{owner_id} is exposed on the month {month_index} "
                    "runtime surface before implementation",
                    errors,
                )


def validate_deferred_callback_contracts(
    raw_contracts: Any,
    bundles: dict[str, Any],
    months: list[Any],
    registered_events: dict[str, dict[str, Any]],
    development_cap_week: int,
    errors: list[str],
) -> None:
    contracts = require_dict(
        raw_contracts, "deferred_callback_contracts", errors
    )
    if contracts != EXPECTED_DEFERRED_CALLBACK_CONTRACTS:
        fail(
            "deferred callback contracts drifted: expected "
            f"{EXPECTED_DEFERRED_CALLBACK_CONTRACTS}, got {contracts}",
            errors,
        )

    for callback_id, expected in EXPECTED_DEFERRED_CALLBACK_CONTRACTS.items():
        row = require_dict(
            contracts.get(callback_id),
            f"deferred_callback_contracts.{callback_id}",
            errors,
        )
        producer_id = str(row.get("producer_bundle", ""))
        producer_event_id = str(row.get("producer_event", ""))
        producer = require_dict(
            bundles.get(producer_id), f"bundle {producer_id}", errors
        )
        producer_roots = {
            str(value)
            for value in require_list(
                producer.get("existing_roots"),
                f"{producer_id}.existing_roots",
                errors,
            )
        }
        if producer_event_id not in producer_roots:
            fail(
                f"{callback_id} producer event {producer_event_id} is not "
                f"owned by {producer_id}",
                errors,
            )
        producer_event = require_dict(
            registered_events.get(producer_event_id),
            f"registered event {producer_event_id}",
            errors,
        )
        producer_choices = require_list(
            producer_event.get("choices"),
            f"registered event {producer_event_id}.choices",
            errors,
        )
        for raw_choice_index in require_list(
            row.get("producer_choices"),
            f"deferred_callback_contracts.{callback_id}.producer_choices",
            errors,
        ):
            if (
                not isinstance(raw_choice_index, int)
                or isinstance(raw_choice_index, bool)
                or raw_choice_index < 0
                or raw_choice_index >= len(producer_choices)
            ):
                fail(
                    f"{callback_id} has invalid producer choice "
                    f"{raw_choice_index!r}",
                    errors,
                )
                continue
            choice = require_dict(
                producer_choices[raw_choice_index],
                f"registered event {producer_event_id}.choices"
                f"[{raw_choice_index}]",
                errors,
            )
            if (
                choice.get("deferred_follow_up") != callback_id
                or int(choice.get("deferred_delay", 0))
                != int(row.get("delay_weeks", 0))
            ):
                fail(
                    f"{producer_event_id} choice {raw_choice_index} no longer "
                    f"schedules {callback_id} with the contracted delay",
                    errors,
                )

        scheduled_week = int(row.get("scheduled_week", 0))
        delay_weeks = int(row.get("delay_weeks", 0))
        due_week = int(row.get("due_week", 0))
        if (
            scheduled_week not in producer.get("allowed_weeks", [])
            or scheduled_week + delay_weeks != due_week
        ):
            fail(
                f"{callback_id} must preserve the Week {scheduled_week} + "
                f"{delay_weeks} = Week {due_week} schedule",
                errors,
            )
        if int(row.get("activation_cap_week", 0)) != due_week:
            fail(
                f"{callback_id} activation cap must equal its Week "
                f"{due_week} due date",
                errors,
            )

        owner_id = str(row.get("final_owner_bundle", ""))
        owner = require_dict(
            bundles.get(owner_id), f"bundle {owner_id}", errors
        )
        if (
            int(owner.get("locked_week", 0)) != due_week
            or not str(owner.get("planned_scene_id", "")).strip()
            or row.get("consume_phase") != "before_owner_scene"
        ):
            fail(
                f"{callback_id} must be consumed by {owner_id} before its "
                f"Week {due_week} scene",
                errors,
            )
        due_month_index = (due_week - 1) // 4
        due_month = require_dict(
            months[due_month_index] if due_month_index < len(months) else {},
            f"month {due_month_index + 1}",
            errors,
        )
        if {"week": due_week, "bundle": owner_id} not in due_month.get(
            "locked", []
        ):
            fail(
                f"{callback_id} final owner {owner_id} is not locked to "
                f"Week {due_week}",
                errors,
            )
        if development_cap_week >= due_week:
            fail(
                f"{callback_id} remains a deferred contract even though the "
                f"Week {due_week} runtime gate is open",
                errors,
            )

        directly_exposed_bundles = {
            str(bundle_id)
            for bundle_id, raw_bundle in bundles.items()
            if isinstance(raw_bundle, dict)
            and (
                callback_id
                in {
                    str(value)
                    for value in raw_bundle.get("existing_roots", [])
                }
                or str(raw_bundle.get("planned_scene_id", "")) == callback_id
            )
        }
        if directly_exposed_bundles:
            fail(
                f"{callback_id} is exposed as an independent runtime root by "
                f"{sorted(directly_exposed_bundles)} instead of its final owner",
                errors,
            )
        if callback_id not in registered_events:
            fail(f"{callback_id} is missing from the registered event set", errors)


def main() -> int:
    errors: list[str] = []
    try:
        contract = load_contract_without_duplicate_keys()
    except (OSError, json.JSONDecodeError, ValueError) as exc:
        print(f"ERROR core loop v2: cannot load contract: {exc}")
        return 1
    actual_root_keys = set(contract)
    if actual_root_keys != EXPECTED_CONTRACT_ROOT_KEYS:
        fail(
            "contract root keys drifted: expected "
            f"{sorted(EXPECTED_CONTRACT_ROOT_KEYS)}, got "
            f"{sorted(actual_root_keys)}",
            errors,
        )
    validate_korean_player_copy(contract, errors)

    scope = require_dict(contract.get("scope"), "scope", errors)
    long_arc = require_dict(
        contract.get("long_arc_contract"), "long_arc_contract", errors
    )
    surface = require_dict(contract.get("surface"), "surface", errors)
    routine = require_dict(contract.get("routine"), "routine", errors)
    relationship = require_dict(contract.get("relationship"), "relationship", errors)
    bundles = require_dict(contract.get("scene_bundles"), "scene_bundles", errors)
    months = require_list(contract.get("months"), "months", errors)
    groups = require_dict(contract.get("exclusive_groups"), "exclusive_groups", errors)

    if int(contract.get("schema_version", 0)) != 3:
        fail("schema_version must be 3 for the 12-week executable contract", errors)
    if bool(contract.get("runtime_default", True)):
        fail("runtime_default must stay false before the 24-week human GO", errors)
    if str(contract.get("fallback", "")) != "event_director_v1":
        fail("existing event director must remain the development fallback", errors)

    expected_scope = {
        "min_week": 1,
        "max_week": 24,
        "months": 6,
        "weeks_per_month": 4,
        "development_cap_week": 12,
        "prototype_weeks": [1, 12],
    }
    for key, expected in expected_scope.items():
        if scope.get(key) != expected:
            fail(f"scope.{key} expected {expected!r}, got {scope.get(key)!r}", errors)
    play_minutes = require_list(scope.get("target_play_minutes"), "target_play_minutes", errors)
    if play_minutes != [75, 95]:
        fail("target_play_minutes must remain [75, 95]", errors)
    development_cap_week = int(scope.get("development_cap_week", 0))
    weeks_per_month = int(scope.get("weeks_per_month", 0))
    if weeks_per_month <= 0 or development_cap_week % weeks_per_month != 0:
        fail("development_cap_week must end on a month boundary", errors)
        development_month_count = 0
    else:
        development_month_count = development_cap_week // weeks_per_month
    if development_month_count != 3:
        fail(
            "the B gate must expose exactly three completed development months",
            errors,
        )
    if (
        long_arc.get("demo_role") != "chapter_one_first_half"
        or int(long_arc.get("chapter_one_end_week", 0)) != 48
        or int(long_arc.get("full_run_end_week", 0)) != 240
        or int(long_arc.get("year_count", 0)) != 5
        or long_arc.get("chapter_one_boss_window") != [45, 48]
        or not bool(long_arc.get("week_24_is_midyear_boss", False))
    ):
        fail("24-week demo must remain the first half of a 48-week chapter and 240-week run", errors)
    canonical_reentry = require_dict(
        long_arc.get("canonical_reentry"),
        "long_arc_contract.canonical_reentry",
        errors,
    )
    for reentry_id, expected_window in {
        "unselected_romance_entry": [25, 40],
        "unselected_money_mentor_entry": [25, 44],
    }.items():
        row = require_dict(
            canonical_reentry.get(reentry_id),
            f"long_arc_contract.canonical_reentry.{reentry_id}",
            errors,
        )
        actual_window = [
            int(row.get("not_before_week", 0)),
            int(row.get("not_after_week", 0)),
        ]
        if actual_window != expected_window or row.get("policy") != "deferred_not_erased":
            fail(
                f"{reentry_id} must defer rather than erase the canonical thread",
                errors,
            )

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
    validate_korean_active_event_copy(registered_events, errors)
    validate_application_outcomes(bundles, registered_events, errors)
    validate_future_application_contracts(
        contract.get("future_application_contracts"),
        bundles,
        months,
        development_cap_week,
        errors,
    )
    validate_deferred_callback_contracts(
        contract.get("deferred_callback_contracts"),
        bundles,
        months,
        registered_events,
        development_cap_week,
        errors,
    )
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
            elif str(
                require_dict(bundles.get(member), f"bundle {member}", errors).get(
                    "exclusive_group", ""
                )
            ) != group_id:
                fail(
                    f"{member} must point back to exclusive group {group_id}",
                    errors,
                )
    for bundle_id, raw_bundle in bundles.items():
        bundle = require_dict(raw_bundle, f"bundle {bundle_id}", errors)
        group_id = str(bundle.get("exclusive_group", "")).strip()
        if not group_id:
            continue
        if group_id not in groups:
            fail(f"{bundle_id} references missing exclusive group {group_id}", errors)
            continue
        members = require_list(
            require_dict(groups.get(group_id), f"group {group_id}", errors).get(
                "members"
            ),
            f"{group_id}.members",
            errors,
        )
        if bundle_id not in {str(value) for value in members}:
            fail(
                f"{bundle_id} points to {group_id} but is absent from its members",
                errors,
            )

    if len(months) != 6:
        fail(f"expected 6 months, got {len(months)}", errors)
    expected_start = 1
    total_minutes = 0
    all_month_offer_ids: set[str] = set()
    action_offer_months: dict[str, list[int]] = {}
    referenced_bundle_ids: set[str] = set()
    development_surface_ids: set[str] = set()
    development_player_ids: set[str] = set()
    development_selectable_ids: set[str] = set()
    development_month_by_bundle: dict[str, int] = {}
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
        fallback_offers = [
            str(value)
            for value in require_list(
                month.get("fallback_offers", []),
                f"month {expected_month}.fallback_offers",
                errors,
            )
        ]
        minimum = int(surface.get("minimum_offers_per_month", 5))
        maximum = int(surface.get("maximum_offers_per_month", 7))
        if (
            expected_month <= development_month_count
            and not minimum <= len(offers) <= maximum
        ):
            fail(f"month {expected_month} must expose {minimum}..{maximum} offers, got {len(offers)}", errors)
        if len(set(offers)) != len(offers):
            fail(f"month {expected_month} has duplicate offers", errors)
        if len(set(fallback_offers)) != len(fallback_offers):
            fail(f"month {expected_month} has duplicate fallback offers", errors)
        if set(offers).intersection(fallback_offers):
            fail(f"month {expected_month} repeats a normal offer as fallback", errors)
        for bundle_id in offers + fallback_offers:
            referenced_bundle_ids.add(bundle_id)
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
            if expected_month <= development_month_count:
                if (
                    bundle_id in development_month_by_bundle
                    and development_month_by_bundle[bundle_id] != expected_month
                ):
                    fail(
                        f"{bundle_id} is reused across completed months "
                        f"{development_month_by_bundle[bundle_id]} and "
                        f"{expected_month}",
                        errors,
                    )
                development_surface_ids.add(bundle_id)
                development_player_ids.add(bundle_id)
                development_selectable_ids.add(bundle_id)
                development_month_by_bundle[bundle_id] = expected_month
        locked = require_list(month.get("locked"), f"month {expected_month}.locked", errors)
        if len(locked) > int(surface.get("maximum_locked_slots_per_month", 1)):
            fail(f"month {expected_month} locks too many foreground slots", errors)
        for row in locked:
            lock = require_dict(row, f"month {expected_month} lock", errors)
            bundle_id = str(lock.get("bundle", ""))
            referenced_bundle_ids.add(bundle_id)
            if bundle_id not in bundles:
                fail(f"month {expected_month} lock references missing bundle {bundle_id}", errors)
            elif expected_month <= development_month_count:
                development_surface_ids.add(bundle_id)
                development_player_ids.add(bundle_id)
                development_month_by_bundle[bundle_id] = expected_month
            week = int(lock.get("week", 0))
            if week < weeks[0] or week > weeks[1]:
                fail(f"month {expected_month} lock week {week} lies outside {weeks}", errors)
        for collection_key in (
            "prelude",
            "conditional_consequences",
            "closing",
        ):
            surface_ids = [
                str(value)
                for value in require_list(
                    month.get(collection_key, []),
                    f"month {expected_month}.{collection_key}",
                    errors,
                )
            ]
            referenced_bundle_ids.update(surface_ids)
            if (
                expected_month <= development_month_count
                and collection_key in {"prelude", "closing"}
                and surface_ids
            ):
                fail(
                    f"month {expected_month} declares {collection_key} "
                    "bundles that the implemented V2 runtime does not consume; "
                    "use the receipt-backed month summary or add an explicit owner",
                    errors,
                )
            for bundle_id in surface_ids:
                if bundle_id not in bundles:
                    fail(
                        f"month {expected_month} {collection_key} references "
                        f"missing bundle {bundle_id}",
                        errors,
                    )
                elif expected_month <= development_month_count:
                    development_surface_ids.add(bundle_id)
                    development_month_by_bundle.setdefault(
                        bundle_id, expected_month
                    )
        named_cap = int(month.get("active_named_characters_max", 99))
        if named_cap > int(relationship.get("maximum_active_named_threads", 4)):
            fail(f"month {expected_month} exceeds named-character cap", errors)
        if expected_month == 3 and named_cap != 3:
            fail("month 3 must cap simultaneous named leads at three", errors)
        total_minutes += int(month.get("target_minutes", 0))

    orphan_bundles = set(str(value) for value in bundles).difference(
        referenced_bundle_ids
    )
    if orphan_bundles:
        fail(
            "scene bundles have no month surface owner "
            f"{sorted(orphan_bundles)}",
            errors,
        )

    for bundle_id, owner_months in action_offer_months.items():
        if len(owner_months) != 1:
            fail(f"{bundle_id} is reused across months {owner_months}; foreground actions must be concrete", errors)

    routine_tracks = {str(value) for value in routine.get("primary_tracks", [])}
    for bundle_id in sorted(development_surface_ids):
        bundle = require_dict(
            bundles.get(bundle_id), f"development bundle {bundle_id}", errors
        )
        legacy_keys = LEGACY_REQUIREMENT_KEYS.intersection(bundle)
        if legacy_keys:
            fail(
                f"{bundle_id} keeps legacy free-form requirements "
                f"{sorted(legacy_keys)} inside the development cap",
                errors,
            )
        if "prerequisites" in bundle:
            validate_prerequisites(
                bundle_id,
                bundle.get("prerequisites"),
                bundles,
                routine_tracks,
                errors,
            )

    for bundle_id, expected in EXPECTED_B_PREREQUISITES.items():
        bundle = require_dict(bundles.get(bundle_id), f"bundle {bundle_id}", errors)
        if bundle.get("prerequisites") != expected:
            fail(
                f"{bundle_id} typed prerequisites drifted: expected "
                f"{expected}, got {bundle.get('prerequisites')}",
                errors,
            )
    if str(
        require_dict(
            bundles.get("father_quiet_call"), "bundle father_quiet_call", errors
        ).get("initiated_by", "")
    ) != "player":
        fail("father_quiet_call must remain Minjun's outgoing Sunday call", errors)
    if str(
        require_dict(
            bundles.get("hyunsu_study_followup"),
            "bundle hyunsu_study_followup",
            errors,
        ).get("initiated_by", "")
    ) != "reciprocal":
        fail("hyunsu_study_followup must answer the player's earlier reach-out", errors)

    for bundle_id in sorted(development_player_ids):
        bundle = require_dict(
            bundles.get(bundle_id), f"development bundle {bundle_id}", errors
        )
        for field in PLAYER_COPY_FIELDS:
            value = str(bundle.get(field, "")).strip()
            if not value:
                fail(f"{bundle_id} is missing bilingual player copy field {field}", errors)
            elif field.endswith("_en") and HANGUL_RE.search(value):
                fail(f"{bundle_id}.{field} leaks Hangul into English", errors)
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
        owner_month = development_month_by_bundle.get(bundle_id, 0)
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

    for bundle_id, expected_weeks in EXPECTED_M3_ALLOWED_WEEKS.items():
        bundle = require_dict(bundles.get(bundle_id), f"bundle {bundle_id}", errors)
        if bundle.get("allowed_weeks") != expected_weeks:
            fail(
                f"{bundle_id}.allowed_weeks expected {expected_weeks}, "
                f"got {bundle.get('allowed_weeks')}",
                errors,
            )

    month_three = require_dict(
        months[2] if len(months) >= 3 else {},
        "month 3",
        errors,
    )
    month_three_action_ids = {
        bundle_id
        for bundle_id in (
            list(month_three.get("offers", []))
            + list(month_three.get("fallback_offers", []))
        )
        if str(
            require_dict(bundles.get(bundle_id), f"bundle {bundle_id}", errors).get(
                "action_id", ""
            )
        )
    }
    if month_three_action_ids != M3_ACTION_IDS:
        fail(
            f"month 3 action commitments expected {sorted(M3_ACTION_IDS)}, "
            f"got {sorted(month_three_action_ids)}",
            errors,
        )
    result_copy_fields = (
        "result_title_ko",
        "result_title_en",
        "result_body_ko",
        "result_body_en",
    )
    result_copy_values: dict[str, set[str]] = {
        field: set() for field in result_copy_fields
    }
    for bundle_id, expected_core in EXPECTED_M3_ACTION_CORE.items():
        bundle = require_dict(bundles.get(bundle_id), f"bundle {bundle_id}", errors)
        config = require_dict(
            bundle.get("action_config"), f"{bundle_id}.action_config", errors
        )
        for key, expected_value in expected_core.items():
            if config.get(key) != expected_value:
                fail(
                    f"{bundle_id}.action_config.{key} expected "
                    f"{expected_value!r}, got {config.get(key)!r}",
                    errors,
                )
        for field in result_copy_fields:
            value = str(config.get(field, "")).strip()
            if not value:
                fail(f"{bundle_id}.action_config is missing {field}", errors)
            elif field.endswith("_en") and HANGUL_RE.search(value):
                fail(
                    f"{bundle_id}.action_config.{field} leaks Hangul into English",
                    errors,
                )
            elif value in result_copy_values[field]:
                fail(
                    f"month 3 action result field {field} is reused: {value!r}",
                    errors,
                )
            result_copy_values[field].add(value)

    decline_outcomes = require_dict(
        contract.get("decline_outcomes"), "decline_outcomes", errors
    )
    selectable_decline_ids: dict[str, str] = {}
    for bundle_id in sorted(development_selectable_ids):
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
            "next_matching_bundle",
        }:
            fail(f"decline outcome {consequence_id} has no executable consumer", errors)
        visible_month = int(outcome.get("visible_month", 0))
        if not 1 <= visible_month <= development_month_count + 1:
            fail(
                f"decline outcome {consequence_id} escapes the developed "
                f"month 1..{development_month_count + 1} consumer window",
                errors,
            )
        for language_key in ("message_ko", "message_en"):
            value = str(outcome.get(language_key, "")).strip()
            if not value:
                fail(
                    f"decline outcome {consequence_id} is missing {language_key}",
                    errors,
                )
            elif language_key == "message_en" and HANGUL_RE.search(value):
                fail(
                    f"decline outcome {consequence_id} leaks Hangul into English",
                    errors,
                )
        if str(outcome.get("consumer_kind", "")) == "next_matching_bundle":
            if outcome.get("target_kinds") != ["encounter", "pursuit"]:
                fail(
                    f"decline outcome {consequence_id} must target the next "
                    "encounter or pursuit",
                    errors,
                )
            if outcome.get("effects") != {"health": -2, "mental": -2}:
                fail(
                    f"decline outcome {consequence_id} strain effects drifted",
                    errors,
                )
            if outcome.get("fallback") != {
                "consumer_kind": "closing_month",
                "visible_month": 3,
            }:
                fail(
                    f"decline outcome {consequence_id} needs its month-three "
                    "closing fallback",
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
    for bundle_id in sorted(development_selectable_ids):
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

    for bundle_id, (consumer_kind, visible_month) in EXPECTED_M3_DECLINES.items():
        bundle = require_dict(bundles.get(bundle_id), f"bundle {bundle_id}", errors)
        consequence_id = str(bundle.get("decline_consequence", "")).strip()
        outcome = require_dict(
            decline_outcomes.get(consequence_id),
            f"decline_outcomes.{consequence_id}",
            errors,
        )
        if (
            str(outcome.get("consumer_kind", "")) != consumer_kind
            or int(outcome.get("visible_month", 0)) != visible_month
        ):
            fail(
                f"{bundle_id} decline must use {consumer_kind} in month "
                f"{visible_month}",
                errors,
            )

    development_relationship_ids = {
        bundle_id
        for bundle_id in development_player_ids
        if str(
            require_dict(bundles.get(bundle_id), f"bundle {bundle_id}", errors).get(
                "relationship_stage", ""
            )
        )
    }
    for bundle_id in sorted(development_relationship_ids):
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
        mapped_memories: dict[str, set[str]] = {}
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
            required_mapping_keys = {
                "event_id",
                "choices",
                "character",
                "from",
                "to",
                "initiative",
                "memory",
            }
            optional_mapping_keys = {
                "supersedes_callbacks",
                "replacement_bundle",
            }
            if not required_mapping_keys.issubset(mapping) or (
                set(mapping) - required_mapping_keys - optional_mapping_keys
            ):
                fail(
                    f"{bundle_id} relationship outcome keys require "
                    f"{sorted(required_mapping_keys)} and allow "
                    f"{sorted(optional_mapping_keys)}; got {sorted(mapping)}",
                    errors,
                )
            superseded = mapping.get("supersedes_callbacks", [])
            if superseded:
                if not isinstance(superseded, list) or not all(
                    isinstance(value, str) and value.strip()
                    for value in superseded
                ):
                    fail(
                        f"{bundle_id} supersedes_callbacks must contain event IDs",
                        errors,
                    )
                if not str(mapping.get("replacement_bundle", "")).strip():
                    fail(
                        f"{bundle_id} superseded callback has no replacement bundle",
                        errors,
                    )
            from_stage = str(mapping.get("from", "")).strip()
            to_stage = str(mapping.get("to", "")).strip()
            if from_stage not in EXPECTED_STAGES:
                fail(
                    f"{bundle_id} relationship outcome has unknown from "
                    f"stage {from_stage}",
                    errors,
                )
            if to_stage not in EXPECTED_STAGES:
                fail(
                    f"{bundle_id} relationship outcome has unknown to "
                    f"stage {to_stage}",
                    errors,
                )
            if (
                from_stage in EXPECTED_STAGES
                and to_stage in EXPECTED_STAGES
                and EXPECTED_STAGES.index(to_stage)
                < EXPECTED_STAGES.index(from_stage)
            ):
                fail(f"{bundle_id} relationship outcome regresses stage", errors)
            character = str(mapping.get("character", "")).strip()
            if not character or character not in {
                str(value) for value in bundle.get("characters", [])
            }:
                fail(
                    f"{bundle_id} relationship outcome targets unrelated "
                    f"character {character}",
                    errors,
                )
            initiative = str(mapping.get("initiative", "")).strip()
            if initiative not in RELATIONSHIP_INITIATIVES:
                fail(
                    f"{bundle_id} relationship outcome has invalid initiative "
                    f"{initiative}",
                    errors,
                )
            if (
                to_stage in EXPECTED_STAGES[3:]
                and initiative not in {"player", "reciprocal"}
            ):
                fail(
                    f"{bundle_id} advances beyond opening without player or "
                    "reciprocal initiative",
                    errors,
                )
            memory = str(mapping.get("memory", "")).strip()
            if not memory:
                fail(
                    f"{bundle_id} relationship outcome has no memory receipt",
                    errors,
                )
            event_memories = mapped_memories.setdefault(event_id, set())
            if memory and memory in event_memories:
                fail(
                    f"{bundle_id} reuses relationship memory {memory} in "
                    f"{event_id}",
                    errors,
                )
            event_memories.add(memory)
            choices = require_list(
                mapping.get("choices"),
                f"{bundle_id}.relationship_outcomes[{index}].choices",
                errors,
            )
            if not choices:
                fail(f"{bundle_id} relationship outcome has no choices", errors)
            elif len(choices) != 1:
                fail(
                    f"{bundle_id} must record one memory per terminal choice",
                    errors,
                )
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
            is_hyunsu_message_lead_in = (
                bundle_id == "hyunsu_player_reachout"
                and event_id == "v2_hyunsu_player_reachout"
            )
            if (
                not is_hyunsu_message_lead_in
                and mapped_choices.get(event_id, set()) != expected_choice_indexes
            ):
                fail(
                    f"{bundle_id} must map every {event_id} choice exactly once: "
                    f"expected {sorted(expected_choice_indexes)}, got "
                    f"{sorted(mapped_choices.get(event_id, set()))}",
                    errors,
                )

    for bundle_id, expected_receipts in EXPECTED_CHOICE_RECEIPTS.items():
        bundle = require_dict(bundles.get(bundle_id), f"bundle {bundle_id}", errors)
        mappings = require_list(
            bundle.get("relationship_outcomes"),
            f"{bundle_id}.relationship_outcomes",
            errors,
        )
        actual_receipts = {
            int(choice): (
                str(mapping.get("from", "")),
                str(mapping.get("to", "")),
                str(mapping.get("initiative", "")),
                str(mapping.get("memory", "")),
            )
            for mapping in mappings
            if isinstance(mapping, dict)
            for choice in mapping.get("choices", [])
            if isinstance(choice, int) and not isinstance(choice, bool)
        }
        if actual_receipts != expected_receipts:
            fail(
                f"{bundle_id} choice receipts drifted: expected "
                f"{expected_receipts}, got {actual_receipts}",
                errors,
            )

    daeun_outcomes = require_list(
        require_dict(
            bundles.get("daeun_world_meet"), "bundle daeun_world_meet", errors
        ).get("relationship_outcomes"),
        "daeun_world_meet.relationship_outcomes",
        errors,
    )
    daeun_result_by_choice = {
        int(choice): (
            str(outcome.get("from", "")),
            str(outcome.get("to", "")),
            str(outcome.get("initiative", "")),
            str(outcome.get("memory", "")),
        )
        for outcome in daeun_outcomes
        if isinstance(outcome, dict)
        for choice in outcome.get("choices", [])
        if isinstance(choice, int) and not isinstance(choice, bool)
    }
    if daeun_result_by_choice != {
        0: ("unmet", "opening", "world", "daeun_name_exchanged"),
        1: ("unmet", "met", "world", "daeun_kept_distance"),
    }:
        fail("Daeun first-meeting choice causality drifted", errors)

    jiyeon_outcomes = require_list(
        require_dict(
            bundles.get("jiyeon_world_meet"), "bundle jiyeon_world_meet", errors
        ).get("relationship_outcomes"),
        "jiyeon_world_meet.relationship_outcomes",
        errors,
    )
    jiyeon_rows = [
        outcome
        for outcome in jiyeon_outcomes
        if isinstance(outcome, dict)
    ]
    jiyeon_choices = [
        int(choice)
        for outcome in jiyeon_rows
        for choice in outcome.get("choices", [])
        if isinstance(choice, int) and not isinstance(choice, bool)
    ]
    jiyeon_memories = {
        str(outcome.get("memory", "")).strip() for outcome in jiyeon_rows
    }
    if sorted(jiyeon_choices) != [0, 1, 2] or len(jiyeon_memories) != 3:
        fail("Jiyeon first meeting must preserve three unique choice memories", errors)
    for outcome in jiyeon_rows:
        if (
            str(outcome.get("from", "")) != "unmet"
            or str(outcome.get("to", "")) != "met"
            or str(outcome.get("initiative", "")) != "world"
        ):
            fail("Jiyeon first meeting must remain unmet-to-met world contact", errors)

    hyunsu_followup = require_dict(
        bundles.get("hyunsu_player_reachout"),
        "bundle hyunsu_player_reachout",
        errors,
    )
    if hyunsu_followup.get("existing_roots") != [
        "v2_hyunsu_player_reachout",
        "v2_hyunsu_first_study",
    ]:
        fail(
            "Hyunsu player reach-out must separate the message from the "
            "next-day in-person study scene",
            errors,
        )
    hyunsu_reciprocal = require_dict(
        bundles.get("hyunsu_study_followup"),
        "bundle hyunsu_study_followup",
        errors,
    )
    if hyunsu_reciprocal.get("existing_roots") != ["v2_hyunsu_study_followup"]:
        fail(
            "Hyunsu's B follow-up must use the V2 study scene, not the "
            "30-billion-won night talk",
            errors,
        )

    memory_consumers: dict[tuple[str, str], set[str]] = {}
    for consumer_id, raw_bundle in bundles.items():
        consumer = require_dict(raw_bundle, f"bundle {consumer_id}", errors)
        prerequisites = consumer.get("prerequisites", {})
        if not isinstance(prerequisites, dict):
            continue
        for raw_group in prerequisites.values():
            if not isinstance(raw_group, list):
                continue
            for raw_clause in raw_group:
                if (
                    not isinstance(raw_clause, dict)
                    or raw_clause.get("kind") != "relationship_memory"
                ):
                    continue
                key = (
                    str(raw_clause.get("character", "")).strip(),
                    str(raw_clause.get("memory", "")).strip(),
                )
                memory_consumers.setdefault(key, set()).add(str(consumer_id))
    expected_memory_consumers = {
        ("father", "father_wellbeing_returned"): {"father_quiet_call"},
        ("father", "father_future_reassured"): {"father_quiet_call"},
        ("father", "father_call_ended_quickly"): {"father_quiet_call"},
        ("hyunsu", "hyunsu_honest_uncertainty"): {"hyunsu_player_reachout"},
        ("hyunsu", "hyunsu_declared_dream"): {"hyunsu_player_reachout"},
        ("hyunsu", "hyunsu_resume_shared"): {"hyunsu_study_followup"},
        ("hyunsu", "hyunsu_problem_set_shared"): {"hyunsu_study_followup"},
        ("daeun", "daeun_name_exchanged"): {"daeun_player_return"},
        ("daeun", "daeun_kept_distance"): {"daeun_return_after_distance"},
        ("jiyeon", "jiyeon_walked_away"): {"jiyeon_bus_stop_reunion"},
        ("jiyeon", "jiyeon_repair_cost_taken"): {"jiyeon_bus_stop_reunion"},
        ("jiyeon", "jiyeon_driver_confronted"): {"jiyeon_bus_stop_reunion"},
    }
    for memory_key, expected_consumers in expected_memory_consumers.items():
        if memory_consumers.get(memory_key, set()) != expected_consumers:
            fail(
                f"first-meeting memory {memory_key} must change the next-card "
                f"eligibility through {sorted(expected_consumers)}",
                errors,
            )
    for consumer_id in {
        value
        for consumers in expected_memory_consumers.values()
        for value in consumers
    }:
        consumer = require_dict(
            bundles.get(consumer_id), f"bundle {consumer_id}", errors
        )
        validate_prerequisites(
            consumer_id,
            consumer.get("prerequisites"),
            bundles,
            routine_tracks,
            errors,
        )

    if "jiyeon_player_message" in bundles:
        fail("Jiyeon cannot receive a player message before contact information exists", errors)
    jiyeon_reunion = require_dict(
        bundles.get("jiyeon_bus_stop_reunion"),
        "bundle jiyeon_bus_stop_reunion",
        errors,
    )
    if jiyeon_reunion.get("existing_roots") != ["arc_jiyeon_02_store"]:
        fail("Jiyeon's next card must be the canonical accidental bus-stop reunion", errors)

    daeun_entry = require_dict(
        bundles.get("daeun_world_meet"), "bundle daeun_world_meet", errors
    )
    if "다은" in str(daeun_entry.get("offer_ko", "")) + str(
        daeun_entry.get("detail_ko", "")
    ) or "Daeun" in str(daeun_entry.get("offer_en", "")) + str(
        daeun_entry.get("detail_en", "")
    ):
        fail("Daeun's name cannot appear on the planner before the first meeting", errors)

    father_signal = require_dict(
        bundles.get("father_health_signal"), "bundle father_health_signal", errors
    )
    if (
        father_signal.get("allowed_weeks") != [21]
        or bool(father_signal.get("consumes_slot", True))
        or "requires_player_initiated" in father_signal
    ):
        fail("Father's health signal must remain a universal Week 21 world fact", errors)
    demo_collision = require_dict(
        bundles.get("demo_collision"), "bundle demo_collision", errors
    )
    if (
        demo_collision.get("planned_scene_id") != "v2_demo_first_bill"
        or demo_collision.get("existing_roots")
    ):
        fail("Week 24 must own one new First Bill root, not stacked legacy recaps", errors)
    forbidden_demo_roots = {
        "arc_daeun_02_regular",
        "arc_daeun_02b_dream",
        "arc_jiyeon_03_offer",
        "arc_sangchul_02_coffee",
        "arc_jaehyuk_01b_real_face",
        "arc_jaehyuk_02_bond",
        "story_six_months",
        "arc_gangnam_visit_alone",
        "arc_four_months_in",
    }
    exposed_future_roots = {
        str(root)
        for month in months[3:]
        if isinstance(month, dict)
        for collection in ("offers", "prelude", "closing")
        for bundle_id in month.get(collection, [])
        if isinstance(bundles.get(str(bundle_id)), dict)
        for root in bundles[str(bundle_id)].get("existing_roots", [])
    }
    leaked_roots = forbidden_demo_roots.intersection(exposed_future_roots)
    if leaked_roots:
        fail(
            f"24-week skeleton consumes later canonical roots {sorted(leaked_roots)}",
            errors,
        )
    month_six_offers = {
        str(value)
        for value in require_dict(
            months[5] if len(months) >= 6 else {}, "month 6", errors
        ).get("offers", [])
    }
    if {"father_quiet_call", "hyunsu_study_followup"}.intersection(
        month_six_offers
    ):
        fail("Month 6 cannot replay the same Father or Hyunsu B root", errors)

    father_event = require_dict(
        registered_events.get("arc_father_quiet_call"),
        "registered event arc_father_quiet_call",
        errors,
    )
    father_description = str(father_event.get("description", ""))
    if not any(
        proof in father_description
        for proof in ("아버지에게 전화했다", "아버지 번호를 눌렀다")
    ):
        fail("Father's quiet-call scene no longer proves Minjun placed the call", errors)
    try:
        english_midgame_rows = json.loads(
            (ROOT / "content/events_en/arc_midgame.json").read_text(
                encoding="utf-8"
            )
        )
    except (OSError, json.JSONDecodeError) as exc:
        fail(f"cannot load English Father-call companion: {exc}", errors)
        english_midgame_rows = []
    english_midgame_events = {
        str(row.get("id", "")): row
        for row in english_midgame_rows
        if isinstance(row, dict)
    }
    english_father_description = str(
        english_midgame_events.get("arc_father_quiet_call", {}).get(
            "description", ""
        )
    ).lower()
    if not any(
        proof in english_father_description
        for proof in ("called his father", "tapped his father's number")
    ):
        fail(
            "English Father quiet-call scene no longer proves Minjun placed the call",
            errors,
        )
    hyunsu_event = require_dict(
        registered_events.get("v2_hyunsu_study_followup"),
        "registered event v2_hyunsu_study_followup",
        errors,
    )
    if "30억" in str(hyunsu_event.get("description", "")):
        fail("Hyunsu's follow-up cannot know the 3-billion-won goal on every route", errors)
    daeun_event = require_dict(
        registered_events.get("arc_daeun_01_meet"),
        "registered event arc_daeun_01_meet",
        errors,
    )
    daeun_choices = require_list(
        daeun_event.get("choices"), "arc_daeun_01_meet.choices", errors
    )
    daeun_first_meeting_copy = str(daeun_event)
    if (
        "몇 번 들른" in daeun_first_meeting_copy
        or "몇 번 뵌" in daeun_first_meeting_copy
        or "얼굴은 익숙" in daeun_first_meeting_copy
        or "매번 챙겨" in str(daeun_choices[0].get("result_text", ""))
        or "30억" in str(daeun_choices[1].get("result_text", ""))
    ):
        fail("Daeun's first meeting cannot invent prior visits, repeated kindness, or a forced motive", errors)
    jiyeon_event = require_dict(
        registered_events.get("arc_jiyeon_01_crash"),
        "registered event arc_jiyeon_01_crash",
        errors,
    )
    jiyeon_event_choices = require_list(
        jiyeon_event.get("choices"), "arc_jiyeon_01_crash.choices", errors
    )
    repair_choice = require_dict(
        jiyeon_event_choices[1] if len(jiyeon_event_choices) > 1 else {},
        "arc_jiyeon_01_crash repair choice",
        errors,
    )
    if (
        require_dict(
            repair_choice.get("effects"),
            "arc_jiyeon_01_crash repair effects",
            errors,
        ).get("money")
        != 80_000
        or "8만원" not in str(repair_choice.get("result_text", ""))
    ):
        fail("Jiyeon's repair payment prose and effect must both equal KRW 80,000", errors)
    jiyeon_reunion_event = require_dict(
        registered_events.get("arc_jiyeon_02_store"),
        "registered event arc_jiyeon_02_store",
        errors,
    )
    jiyeon_reunion_copy = str(jiyeon_reunion_event)
    if (
        "그때 그냥 가셔서" in jiyeon_reunion_copy
        or "그날 제대로 사과도 못 해서" in jiyeon_reunion_copy
    ):
        fail("Jiyeon's reunion must remain valid for all three accident outcomes", errors)
    temptation_event = require_dict(
        registered_events.get("arc_temptation_01"),
        "registered event arc_temptation_01",
        errors,
    )
    temptation_choices = require_list(
        temptation_event.get("choices"), "arc_temptation_01.choices", errors
    )
    temptation_accept = require_dict(
        temptation_choices[1] if len(temptation_choices) > 1 else {},
        "arc_temptation_01 accept choice",
        errors,
    )
    if (
        "월세만 따지면 석 달" not in str(temptation_event.get("description", ""))
        or require_dict(
            temptation_accept.get("effects"),
            "arc_temptation_01 accept effects",
            errors,
        ).get("money")
        != 2_000_000
    ):
        fail("The KRW 2,000,000 temptation must equal just over three KRW 650,000 rents", errors)
    fallout_event = require_dict(
        registered_events.get("arc_temptation_fallout"),
        "registered event arc_temptation_fallout",
        errors,
    )
    fallout_choices = require_list(
        fallout_event.get("choices"), "arc_temptation_fallout.choices", errors
    )
    fallout_return = require_dict(
        fallout_choices[0] if fallout_choices else {},
        "arc_temptation_fallout return choice",
        errors,
    )
    fallout_copy = str(fallout_return.get("text", "")) + str(
        fallout_return.get("result_text", "")
    )
    if (
        require_dict(
            fallout_return.get("effects"),
            "arc_temptation_fallout return effects",
            errors,
        ).get("money")
        != -1_500_000
        or "150만원" not in fallout_copy
        or "사비" in fallout_copy
    ):
        fail("Temptation fallout must return KRW 1,500,000 without inventing extra cash", errors)
    sns_event = require_dict(
        registered_events.get("arc_intro_03_sns"),
        "registered event arc_intro_03_sns",
        errors,
    )
    sns_copy = (
        str(sns_event.get("description", ""))
        + str(sns_event.get("description_variants", {}))
        + str(sns_event.get("description_if_known", {}))
    )
    if "세 번째 달" in sns_copy or "이 방에서 세 번째" in sns_copy:
        fail("The reusable SNS scene cannot hard-code a third-month room tenure", errors)
    year_close_event = require_dict(
        registered_events.get("arc_year1_close"),
        "registered event arc_year1_close",
        errors,
    )
    year_close_variants = require_dict(
        year_close_event.get("description_if_known"),
        "arc_year1_close.description_if_known",
        errors,
    )
    escaped_year_copy = str(year_close_variants.get("escaped_dirty_money", ""))
    if "150만원" not in escaped_year_copy or "사비" in escaped_year_copy:
        fail("Year-one escaped-dirty-money recap must preserve the KRW 1,500,000 return", errors)
    try:
        english_event_rows = json.loads(
            (ROOT / "content/events_en/arc_events.json").read_text(
                encoding="utf-8"
            )
        )
        english_daeun_rows = json.loads(
            (ROOT / "content/events_en/arc_daeun.json").read_text(
                encoding="utf-8"
            )
        )
        english_year_rows = json.loads(
            (ROOT / "content/events_en/arc_year_close.json").read_text(
                encoding="utf-8"
            )
        )
    except (OSError, json.JSONDecodeError) as exc:
        fail(f"cannot load English numeric-consistency companions: {exc}", errors)
        english_event_rows, english_daeun_rows, english_year_rows = [], [], []
    english_events = {
        str(row.get("id", "")): row
        for row in english_event_rows
        if isinstance(row, dict)
    }
    english_daeun_events = {
        str(row.get("id", "")): row
        for row in english_daeun_rows
        if isinstance(row, dict)
    }
    english_year_events = {
        str(row.get("id", "")): row
        for row in english_year_rows
        if isinstance(row, dict)
    }
    english_jiyeon = require_dict(
        english_events.get("arc_jiyeon_01_crash"),
        "English arc_jiyeon_01_crash",
        errors,
    )
    english_jiyeon_choices = require_list(
        english_jiyeon.get("choices"),
        "English arc_jiyeon_01_crash.choices",
        errors,
    )
    if len(english_jiyeon_choices) < 2 or "80,000" not in str(
        english_jiyeon_choices[1].get("result_text", "")
    ):
        fail("English Jiyeon repair prose must say KRW 80,000", errors)
    english_jiyeon_reunion = require_dict(
        english_events.get("arc_jiyeon_02_store"),
        "English arc_jiyeon_02_store",
        errors,
    )
    if (
        "You just walked away" in str(english_jiyeon_reunion)
        or "never apologized properly" in str(english_jiyeon_reunion)
    ):
        fail("English Jiyeon reunion must fit all three accident outcomes", errors)
    english_temptation = require_dict(
        english_events.get("arc_temptation_01"),
        "English arc_temptation_01",
        errors,
    )
    if "three months of rent" not in str(english_temptation.get("description", "")):
        fail("English temptation copy must use the three-rent calculation", errors)
    english_fallout = require_dict(
        english_events.get("arc_temptation_fallout"),
        "English arc_temptation_fallout",
        errors,
    )
    english_fallout_choices = require_list(
        english_fallout.get("choices"),
        "English arc_temptation_fallout.choices",
        errors,
    )
    english_fallout_copy = (
        str(english_fallout_choices[0])
        if english_fallout_choices
        else ""
    )
    if (
        "1.5 million" not in english_fallout_copy
        or "own savings" in english_fallout_copy
        or "own cash" in english_fallout_copy
    ):
        fail("English fallout copy must preserve the KRW 1,500,000 return", errors)
    english_sns = require_dict(
        english_events.get("arc_intro_03_sns"),
        "English arc_intro_03_sns",
        errors,
    )
    english_sns_copy = (
        str(english_sns.get("description", ""))
        + str(english_sns.get("description_variants", {}))
        + str(english_sns.get("description_if_known", {}))
    )
    if "Third month in this room" in english_sns_copy:
        fail("The reusable English SNS scene cannot claim a third-month tenure", errors)
    english_daeun = require_dict(
        english_daeun_events.get("arc_daeun_01_meet"),
        "English arc_daeun_01_meet",
        errors,
    )
    english_daeun_choices = require_list(
        english_daeun.get("choices"),
        "English arc_daeun_01_meet.choices",
        errors,
    )
    if (
        len(english_daeun_choices) < 2
        or "a few times" in str(english_daeun)
        or "familiar face" in str(english_daeun)
        or "always look out" in str(english_daeun_choices[0])
        or "3 billion" in str(english_daeun_choices[1])
    ):
        fail("English Daeun first meeting must match the corrected causality", errors)
    english_year = require_dict(
        english_year_events.get("arc_year1_close"),
        "English arc_year1_close",
        errors,
    )
    english_year_variants = require_dict(
        english_year.get("description_if_known"),
        "English arc_year1_close.description_if_known",
        errors,
    )
    english_escaped_year = str(
        english_year_variants.get("escaped_dirty_money", "")
    )
    if "1.5 million" not in english_escaped_year or "own money" in english_escaped_year:
        fail("English year-one recap must preserve the KRW 1,500,000 return", errors)
    try:
        main_game_source = (ROOT / "scenes/MainGame.gd").read_text(
            encoding="utf-8"
        )
    except OSError as exc:
        fail(f"cannot load the Core Loop V2 recap source: {exc}", errors)
        main_game_source = ""
    if (
        "받은 돈에 사비를 보태 돌려보내고" in main_game_source
        or "added your own cash to what you had received" in main_game_source
    ):
        fail("The twelve-week recap cannot invent extra cash in the return branch", errors)

    if not 75 <= total_minutes <= 95:
        fail(f"monthly target minutes total {total_minutes} is outside 75..95", errors)
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
        f"development_cap={development_cap_week} "
        f"development_months={development_month_count} "
        f"development_deadlines={len(development_player_ids)} "
        f"decline_consumers={len(selectable_decline_ids)} "
        f"routines={len(routine_options)} "
        f"relationship_choice_maps={len(development_relationship_ids)} "
        f"application_transitions={len(EXPECTED_APPLICATION_OUTCOMES)} "
        f"future_applications={len(EXPECTED_FUTURE_APPLICATION_CONTRACTS)} "
        f"deferred_callbacks={len(EXPECTED_DEFERRED_CALLBACK_CONTRACTS)} "
        f"visible_ap={str(surface['visible_ap']).lower()}"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
