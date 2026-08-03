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
NARRATIVE_SPINE_PATH = ROOT / "content" / "meta" / "narrative_spine.json"
REGISTRY_PATH = ROOT / "autoloads" / "DataRegistry.gd"
DEMO_CORE_LOOP_PATH = ROOT / "systems" / "DemoCoreLoopV2.gd"
HANGUL_RE = re.compile(r"[가-힣]")

EXPECTED_TABS = ["status", "calendar", "people", "record"]
EXPECTED_PHONE_TABS = ["messages", "contacts"]
EXPECTED_PHONE_MESSAGE_SURFACES = ["inbound_message", "call_log"]
EXPECTED_PHONE_CONTACT_METHODS = ["phone", "kakao", "business_card"]
EXPECTED_PHONE_PERSISTENT_FIELDS = [
    "schema",
    "device_purchase_retired",
    "legacy_refund_applied",
    "legacy_refund_amount",
]
EXPECTED_PHONE_LEGACY_MIGRATION = {
    "source_schema": 2,
    "refundable_device_id": "refurbished",
    "previous_device_id": "starter",
    "price": 180_000,
    "available_from_week": 13,
    "refund_once": True,
}
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
    "future_story_contracts",
    "post_demo_application_contracts",
    "deferred_callback_contracts",
    "surface",
    "phone",
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
EXPECTED_AUTHORED_BY_MONTH = [3, 3, 4, 4, 4, 3]
EXPECTED_PRACTICAL_AUTHORED_BY_MONTH = [1, 2, 1, 2, 2, 1]
PRACTICAL_EXCLUDED_KINDS = {"pursuit", "encounter", "care"}
ACTION_STORY_ROOTS = {
    "m1_convenience_trial_shift": "v2_convenience_trial_shift",
    "m3_inventory_shift": "v2_inventory_count_nights",
    "m4_certificate_session": "v2_logistics_class_session",
    "m5_weekend_move_shift": "v2_moving_crew_days",
    "m5_last_empty_sunday": "v2_empty_sunday",
}
STORY_GAMEPLAY_KEYS = {
    "effects",
    "flags",
    "flag_updates",
    "relationship_change",
    "relationship_changes",
    "application_transition",
    "future_story_outcome",
    "moral_tint",
    "route",
}
ALLOWED_PREREQUISITE_GROUPS = {"all", "any"}
ALLOWED_PREREQUISITE_KINDS = {
    "completed_bundle",
    "relationship_at_least",
    "relationship_stage_is",
    "relationship_memory",
    "player_initiated",
    "routine_selected",
    "application_status",
    "application_status_not_in",
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
    "m4_hanbit_interview": [
        {
            "event_id": "v2_hanbit_interview",
            "choices": [0, 1],
            "application_id": "hanbit_ops_2026q1",
            "from": "submitted",
            "to": "interviewed",
        }
    ],
    "m5_hanbit_offer_message": [
        {
            "event_id": "v2_hanbit_offer_message",
            "choices": [0, 1],
            "application_id": "hanbit_ops_2026q1",
            "from": "interviewed",
            "to": "resolved",
        }
    ],
    "m6_dodam_response": [
        {
            "event_id": "v2_dodam_result_message",
            "choices": [0],
            "application_id": "dodam_customer_ops_2026q2",
            "from": "submitted",
            "to": "no_offer",
        }
    ],
    "demo_collision": [
        {
            "event_id": "v2_demo_first_bill",
            "choices": [0, 1, 3, 4, 5, 6, 7],
            "application_id": "city_facility_ops_2026h1",
            "from": "submitted",
            "to": "no_offer",
        }
    ],
}
EXPECTED_FUTURE_APPLICATION_CONTRACTS: dict[str, dict[str, Any]] = {
    "m6_dodam_response": {
        "producer_bundle": "m4_dodam_application",
        "application_id": "dodam_customer_ops_2026q2",
        "from": "submitted",
        "owner_month": 6,
        "allowed_weeks": [22],
        "activation_cap_week": 24,
        "runtime_surface": "inbound_message",
        "result_event": "v2_dodam_result_message",
        "to": "no_offer",
    },
    "m6_city_service_response": {
        "producer_bundle": "m5_city_service_application",
        "application_id": "city_facility_ops_2026h1",
        "from": "submitted",
        "owner_month": 6,
        "allowed_weeks": [23],
        "activation_cap_week": 24,
        "runtime_surface": "inbound_message",
        "result_event": "v2_city_service_work_sample_message",
        "to": "submitted",
    },
}
EXPECTED_FUTURE_STORY_CONTRACTS: dict[str, dict[str, Any]] = {
    "hyunsu_exam_2026": {
        "producer_bundle": "hyunsu_exam_eve",
        "required_memories": [
            "hyunsu_exam_eve_one_problem",
            "hyunsu_exam_eve_rest_protected",
        ],
        "unanswered_source": "hyunsu_exam_eve_unanswered",
        "decline_outcome":
            "hyunsu_takes_the_exam_without_another_shared_hour",
        "trigger_event": "v2_hyunsu_exam_morning_echo",
        "trigger_flag": "hyunsu_exam_day_seen",
        "exam_week": 24,
        "result_available_week": 27,
        "canonical_outcome": "fail",
        "result_event": "hyunsu_result_fail",
        "narrative_spine": "hyunsu_after_the_exam",
        "legacy_override_flag": "hyunsu_encouraged",
        "legacy_override_event": "hyunsu_result_pass",
        "choice_changes_outcome": False,
        "choice_changes_description": True,
    }
}
EXPECTED_POST_DEMO_APPLICATION_CONTRACTS = {
    "city_facility_ops_2026h1_result": {
        "producer_bundle": "demo_collision",
        "producer_event": "v2_demo_first_bill",
        "producer_choice": 2,
        "selected_obligation_id": "city_work_sample",
        "application_id": "city_facility_ops_2026h1",
        "from": "submitted",
        "to": "no_offer",
        "not_before_week": 28,
        "not_after_week": 32,
        "result_event": "v2_city_service_result_message",
        "result_flag": "v2_city_service_result_seen",
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
EXPECTED_M4_ALLOWED_WEEKS = {
    "m4_hanbit_interview": [14],
    "m4_dodam_application": [13],
    "m4_certificate_session": [13, 14, 15],
    "m4_logistics_shift": [13, 14, 15],
    "m4_health_check_day": [13, 14, 15, 16],
    "m4_housing_welfare_consultation": [13, 14, 15, 16],
    "daeun_player_return": [15, 16],
    "daeun_return_after_distance": [15, 16],
    "jiyeon_bus_stop_reunion": [15, 16],
    "sangchul_world_meet": [13, 14],
    "jaehyuk_world_meet": [13, 14, 15, 16],
}
EXPECTED_M4_ACTION_CORE = {
    "m4_dodam_application": {
        "execution": "application",
        "application_id": "dodam_customer_ops_2026q2",
        "job_id": "job_04",
        "status": "submitted",
    },
    "m4_certificate_session": {
        "execution": "instant_effect",
        "axis": "human",
        "place_id": "city",
        "effects": {"intelligence": 2, "mental": -2},
    },
    "m4_logistics_shift": {
        "execution": "instant_effect",
        "axis": "money",
        "place_id": "work",
        "effects": {"money": 520_000, "health": -7, "mental": -5},
    },
    "m4_health_check_day": {
        "execution": "instant_effect",
        "axis": "human",
        "place_id": "hospital",
        "effects": {"health": 1, "mental": 1},
    },
    "m4_housing_welfare_consultation": {
        "execution": "instant_effect",
        "axis": "human",
        "place_id": "city",
        "effects": {"intelligence": 1, "mental": 1},
    },
}
EXPECTED_M5_ALLOWED_WEEKS = {
    "m5_city_service_application": [17],
    "m5_weekend_move_shift": [17, 18, 19, 20],
    "m5_evening_spreadsheet_class": [17, 18, 19, 20],
    "m5_last_empty_sunday": [17, 18, 19, 20],
    "m5_employment_contract_clinic": [17, 18, 19, 20],
    "daeun_shared_dream": [20],
    "daeun_third_greeting": [19, 20],
    "jiyeon_second_crossing": [19, 20],
    "sangchul_second_coffee": [19, 20],
    "jaehyuk_plain_reunion_echo": [19, 20],
}
EXPECTED_M5_ACTION_CORE = {
    "m5_city_service_application": {
        "execution": "application",
        "application_id": "city_facility_ops_2026h1",
        "job_id": "job_03",
        "status": "submitted",
    },
    "m5_weekend_move_shift": {
        "execution": "instant_effect",
        "axis": "money",
        "place_id": "work",
        "effects": {"money": 560_000, "health": -8, "mental": -5},
    },
    "m5_evening_spreadsheet_class": {
        "execution": "instant_effect",
        "axis": "human",
        "place_id": "city",
        "effects": {"intelligence": 2, "mental": -2},
    },
    "m5_last_empty_sunday": {
        "execution": "rest",
        "effects": {"health": 5, "mental": 7},
        "recovery_routine_effects": {"health": 2, "mental": 3},
    },
    "m5_employment_contract_clinic": {
        "execution": "instant_effect",
        "axis": "human",
        "place_id": "city",
        "effects": {"intelligence": 1, "mental": 1},
    },
}
EXPECTED_M5_DECLINES = {
    "m5_city_service_application": ("next_month_message", 6),
    "m5_weekend_move_shift": ("next_month_message", 6),
    "m5_evening_spreadsheet_class": ("next_month_message", 6),
    "m5_last_empty_sunday": ("next_month_message", 6),
    "m5_employment_contract_clinic": ("next_month_message", 6),
    "daeun_shared_dream": ("next_month_message", 6),
    "daeun_third_greeting": ("next_month_message", 6),
    "jiyeon_second_crossing": ("next_month_message", 6),
    "sangchul_second_coffee": ("next_month_message", 6),
    "jaehyuk_plain_reunion_echo": ("next_month_message", 6),
}
EXPECTED_M6_ALLOWED_WEEKS = {
    "m6_public_recruitment": [21, 22, 23],
    "m6_holiday_night_shift": [21, 22, 23],
    "m6_last_study_group": [21, 22, 23],
    "m6_no_plans_day": [21, 22, 23],
    "m6_gangnam_receipt_walk": [21, 22, 23],
    "hyunsu_exam_eve": [23],
    "m6_daeun_tuesday_followthrough": [21],
    "father_health_signal": [21],
    "m6_dodam_response": [22],
    "m6_city_service_response": [23],
    "demo_collision": [24],
}
EXPECTED_M6_ACTION_CORE = {
    "m6_public_recruitment": {
        "execution": "instant_effect",
        "axis": "human",
        "place_id": "city",
        "effects": {"intelligence": 3, "mental": -3},
    },
    "m6_holiday_night_shift": {
        "execution": "instant_effect",
        "axis": "money",
        "place_id": "work",
        "effects": {"money": 480_000, "health": -6, "mental": -5},
    },
    "m6_last_study_group": {
        "execution": "instant_effect",
        "axis": "human",
        "place_id": "library",
        "effects": {"intelligence": 2, "social_skill": 1, "mental": -2},
    },
    "m6_no_plans_day": {
        "execution": "rest",
        "effects": {"health": 5, "mental": 7},
        "recovery_routine_effects": {"health": 2, "mental": 3},
    },
}
EXPECTED_M6_DECLINES = {
    "m6_public_recruitment": ("terminal_recap", 6),
    "m6_holiday_night_shift": ("terminal_recap", 6),
    "m6_last_study_group": ("terminal_recap", 6),
    "m6_no_plans_day": ("terminal_recap", 6),
    "m6_gangnam_receipt_walk": ("terminal_recap", 6),
    "hyunsu_exam_eve": ("terminal_recap", 6),
    "m6_daeun_tuesday_followthrough": ("terminal_recap", 6),
}
EXPECTED_CHOICE_RECEIPTS = {
    "father_health_signal": {
        0: (
            "unmet",
            "opening",
            "reciprocal",
            "father_neighbor_detail_checked",
        ),
        1: (
            "unmet",
            "opening",
            "reciprocal",
            "father_called_again_that_evening",
        ),
        2: (
            "unmet",
            "opening",
            "reciprocal",
            "father_health_warning_postponed",
        ),
    },
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
    "daeun_player_return": {
        0: (
            "opening",
            "player_reached_out",
            "player",
            "daeun_returned_using_her_name",
        ),
        1: (
            "opening",
            "player_reached_out",
            "player",
            "daeun_returned_to_thank_her",
        ),
    },
    "daeun_return_after_distance": {
        0: (
            "met",
            "opening",
            "player",
            "daeun_names_exchanged_on_return",
        ),
        1: (
            "met",
            "opening",
            "player",
            "daeun_thanks_reopened_conversation",
        ),
    },
    "jiyeon_bus_stop_reunion": {
        0: (
            "met",
            "opening",
            "reciprocal",
            "jiyeon_name_offered_after_silence",
        ),
        1: (
            "met",
            "opening",
            "player",
            "jiyeon_name_exchanged_after_player_spoke",
        ),
    },
    "sangchul_world_meet": {
        0: ("unmet", "met", "world", "sangchul_spoke_of_father"),
        1: ("unmet", "met", "world", "sangchul_kept_goal_plain"),
        2: ("unmet", "met", "world", "sangchul_named_city_pride"),
    },
    "jaehyuk_world_meet": {
        0: ("unmet", "met", "reciprocal", "jaehyuk_message_welcomed"),
        1: ("unmet", "met", "reciprocal", "jaehyuk_message_guarded"),
    },
    "daeun_shared_dream": {
        0: (
            "player_reached_out",
            "shared_commitment",
            "reciprocal",
            "daeun_same_tuesday_promised",
        ),
        1: (
            "player_reached_out",
            "shared_commitment",
            "reciprocal",
            "daeun_late_meal_promised",
        ),
    },
    "daeun_third_greeting": {
        0: (
            "opening",
            "player_reached_out",
            "player",
            "daeun_third_greeting_started",
        ),
        1: (
            "opening",
            "player_reached_out",
            "player",
            "daeun_shift_question_asked",
        ),
    },
    "jiyeon_second_crossing": {
        0: (
            "opening",
            "player_reached_out",
            "reciprocal",
            "jiyeon_neighborhood_coffee_accepted",
        ),
        1: (
            "opening",
            "player_reached_out",
            "player",
            "jiyeon_talk_without_debt_requested",
        ),
        2: (
            "opening",
            "opening",
            "reciprocal",
            "jiyeon_coffee_fully_refused",
        ),
    },
    "sangchul_second_coffee": {
        0: (
            "met",
            "opening",
            "player",
            "sangchul_own_pace_stated",
        ),
        1: (
            "met",
            "opening",
            "player",
            "sangchul_numbers_first_recorded",
        ),
    },
    "jaehyuk_plain_reunion_echo": {
        0: (
            "met",
            "opening",
            "reciprocal",
            "jaehyuk_reunion_warm",
        ),
        1: (
            "met",
            "opening",
            "reciprocal",
            "jaehyuk_reunion_guarded",
        ),
    },
}
EXPECTED_ROUTINE_EFFECTS = {
    "livelihood": {
        "unemployed": {"money": 70_000, "health": -1, "mental": 1},
        "employed": {"work_performance": 1, "mental": 1},
    },
    "growth": {"intelligence": 1, "mental": 1},
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
    "v2_hanbit_interview",
    "v2_daeun_return_named",
    "v2_daeun_return_after_distance",
    "v2_sangchul_housing_lead",
    "v2_jaehyuk_message",
    "v2_hanbit_offer_message",
    "v2_daeun_small_commitment",
    "v2_daeun_third_greeting",
    "v2_jiyeon_second_crossing",
    "v2_sangchul_demo_echo",
    "v2_jaehyuk_plain_reunion_echo",
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


def reachable_event_ids(
    roots: set[str], events: dict[str, dict[str, Any]]
) -> set[str]:
    """Return each root and every authored choice follow-up reachable from it."""
    reachable: set[str] = set()
    pending = list(roots)
    while pending:
        event_id = pending.pop()
        if not event_id or event_id in reachable:
            continue
        reachable.add(event_id)
        event = events.get(event_id, {})
        if not isinstance(event, dict):
            continue
        for raw_choice in event.get("choices", []):
            if not isinstance(raw_choice, dict):
                continue
            follow_up = str(raw_choice.get("follow_up_event", "")).strip()
            if follow_up and follow_up not in reachable:
                pending.append(follow_up)
    return reachable


def fixture_predicate_met(predicate: dict[str, Any], fixture: dict[str, Any]) -> bool:
    kind = str(predicate.get("kind", ""))
    if kind == "completed_bundle":
        return str(predicate.get("bundle_id", "")) in fixture.get("completed", set())
    if kind == "relationship_stage_is":
        return fixture.get("stages", {}).get(
            str(predicate.get("character", "")), "unmet"
        ) == str(predicate.get("stage", ""))
    if kind == "relationship_at_least":
        current = str(
            fixture.get("stages", {}).get(
                str(predicate.get("character", "")), "unmet"
            )
        )
        required = str(predicate.get("stage", ""))
        return (
            current != "closed"
            and current in EXPECTED_STAGES
            and required in EXPECTED_STAGES
            and EXPECTED_STAGES.index(current) >= EXPECTED_STAGES.index(required)
        )
    if kind == "relationship_memory":
        return (
            str(predicate.get("character", "")),
            str(predicate.get("memory", "")),
        ) in fixture.get("memories", set())
    if kind == "player_initiated":
        return str(predicate.get("character", "")) in fixture.get(
            "player_initiated", set()
        )
    if kind == "routine_selected":
        return str(predicate.get("track", "")) in fixture.get("routines", set())
    if kind == "application_status":
        return fixture.get("applications", {}).get(
            str(predicate.get("application_id", "")), ""
        ) == str(predicate.get("status", ""))
    if kind == "application_status_not_in":
        return fixture.get("applications", {}).get(
            str(predicate.get("application_id", "")), ""
        ) not in {str(value) for value in predicate.get("statuses", [])}
    return False


def bundle_available_in_fixture(
    bundle: dict[str, Any], fixture: dict[str, Any]
) -> bool:
    prerequisites = bundle.get("prerequisites")
    if not isinstance(prerequisites, dict):
        return True
    all_rows = prerequisites.get("all")
    if isinstance(all_rows, list) and not all(
        isinstance(row, dict) and fixture_predicate_met(row, fixture)
        for row in all_rows
    ):
        return False
    any_rows = prerequisites.get("any")
    if isinstance(any_rows, list) and not any(
        isinstance(row, dict) and fixture_predicate_met(row, fixture)
        for row in any_rows
    ):
        return False
    return bool(
        (isinstance(all_rows, list) and all_rows)
        or (isinstance(any_rows, list) and any_rows)
    )


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


def reachable_registered_event_ids(
    roots: set[str],
    events: dict[str, dict[str, Any]],
    errors: list[str],
    owner: str,
    suppressed: set[str] | None = None,
    stop_after: set[str] | None = None,
) -> set[str]:
    """Traverse authored choice links while failing closed on registry gaps."""
    excluded = suppressed or set()
    terminal = stop_after or set()
    reachable: set[str] = set()
    pending = list(roots)
    while pending:
        event_id = str(pending.pop()).strip()
        if not event_id or event_id in excluded or event_id in reachable:
            continue
        event = events.get(event_id)
        if not isinstance(event, dict):
            fail(
                f"{owner} references missing registered event {event_id}",
                errors,
            )
            continue
        reachable.add(event_id)
        if event_id in terminal:
            continue
        for raw_choice in event.get("choices", []):
            if not isinstance(raw_choice, dict):
                continue
            follow_up = str(raw_choice.get("follow_up_event", "")).strip()
            if follow_up and follow_up not in excluded:
                pending.append(follow_up)
    return reachable


def validate_demo_direction_coverage(
    contract: dict[str, Any],
    bundles: dict[str, Any],
    registered_events: dict[str, dict[str, Any]],
    errors: list[str],
) -> tuple[int, int]:
    """Require direction on the current V2 surface and complete prologue chain."""
    suppressions_by_root: dict[str, set[str]] = {}
    for raw_bundle in bundles.values():
        if not isinstance(raw_bundle, dict):
            continue
        raw_suppressed = raw_bundle.get("suppress_follow_up_events", [])
        raw_roots = raw_bundle.get("existing_roots", [])
        if isinstance(raw_suppressed, list) and isinstance(raw_roots, list):
            local_suppressed = {
                str(value).strip() for value in raw_suppressed if str(value).strip()
            }
            for raw_root in raw_roots:
                root_id = str(raw_root).strip()
                if root_id:
                    suppressions_by_root.setdefault(root_id, set()).update(
                        local_suppressed
                    )

    v2_events: set[str] = set()
    for bundle_id, raw_bundle in bundles.items():
        if not isinstance(raw_bundle, dict):
            continue
        raw_roots = raw_bundle.get("existing_roots", [])
        roots = (
            {str(value).strip() for value in raw_roots if str(value).strip()}
            if isinstance(raw_roots, list)
            else set()
        )
        raw_suppressed = raw_bundle.get("suppress_follow_up_events", [])
        local_suppressed = (
            {
                str(value).strip()
                for value in raw_suppressed
                if str(value).strip()
            }
            if isinstance(raw_suppressed, list)
            else set()
        )
        v2_events.update(
            reachable_registered_event_ids(
                roots,
                registered_events,
                errors,
                f"direction coverage bundle {bundle_id}",
                local_suppressed,
            )
        )

    try:
        narrative_spine = json.loads(
            NARRATIVE_SPINE_PATH.read_text(encoding="utf-8")
        )
    except (OSError, json.JSONDecodeError) as exc:
        fail(f"cannot load narrative spine for direction coverage: {exc}", errors)
        narrative_spine = {}
    scope = contract.get("scope", {})
    demo_min_week = int(scope.get("min_week", 1)) if isinstance(scope, dict) else 1
    demo_max_week = int(scope.get("max_week", 24)) if isinstance(scope, dict) else 24
    spine_roots: set[str] = set()
    demo = narrative_spine.get("demo") if isinstance(narrative_spine, dict) else None
    if not isinstance(demo, dict):
        fail("narrative_spine.demo must be an object", errors)
        demo = {}
    sequences = demo.get("sequences")
    if not isinstance(sequences, list) or not sequences:
        fail("narrative_spine.demo.sequences must be an array", errors)
        sequences = []
    for index, raw_sequence in enumerate(sequences):
        if not isinstance(raw_sequence, dict):
            fail(f"narrative_spine demo sequence {index} must be an object", errors)
            continue
        weeks = raw_sequence.get("weeks", [])
        if (
            not isinstance(weeks, list)
            or len(weeks) != 2
            or any(not isinstance(value, int) for value in weeks)
        ):
            fail(
                f"narrative_spine demo sequence {index} has invalid weeks",
                errors,
            )
            continue
        if max(weeks[0], demo_min_week) > min(weeks[1], demo_max_week):
            continue
        roots = raw_sequence.get("foreground_roots", [])
        if not isinstance(roots, list):
            fail(
                f"narrative_spine demo sequence {index} foreground_roots "
                "must be an array",
                errors,
            )
            continue
        spine_roots.update(
            str(value).strip() for value in roots if str(value).strip()
        )
    for root_id in sorted(spine_roots):
        v2_events.update(
            reachable_registered_event_ids(
                {root_id},
                registered_events,
                errors,
                "direction coverage narrative spine",
                suppressions_by_root.get(root_id, set()),
            )
        )

    for event_id in sorted(v2_events):
        direction = registered_events[event_id].get("direction")
        if not isinstance(direction, dict) or not direction:
            fail(
                f"V2 reachable event {event_id} needs a non-empty direction object",
                errors,
            )

    prologue_end = "story_prologue_meal"
    prologue_events = reachable_registered_event_ids(
        {"story_flashforward"},
        registered_events,
        errors,
        "direction coverage prologue",
        stop_after={prologue_end},
    )
    if prologue_end not in prologue_events:
        fail(
            "prologue direction closure does not reach story_prologue_meal",
            errors,
        )
    for event_id in sorted(prologue_events):
        direction = registered_events[event_id].get("direction")
        if not isinstance(direction, dict) or not direction:
            fail(
                f"prologue event {event_id} needs a non-empty direction object",
                errors,
            )
    return len(v2_events), len(prologue_events)


def bundle_has_registered_authored_surface(
    bundle: dict[str, Any], registered_events: dict[str, dict[str, Any]]
) -> bool:
    """An authored surface must resolve through the real event registry."""
    raw_roots = bundle.get("existing_roots", [])
    if isinstance(raw_roots, list) and raw_roots:
        roots = [str(value).strip() for value in raw_roots]
        if all(root and root in registered_events for root in roots):
            return True
    planned_scene_id = str(bundle.get("planned_scene_id", "")).strip()
    return bool(planned_scene_id and planned_scene_id in registered_events)


def selection_within_plan_constraints(
    selected: list[str],
    month: dict[str, Any],
    bundles: dict[str, Any],
    groups: dict[str, Any],
    relationship: dict[str, Any],
) -> bool:
    """Mirror the month-scope group and named-character plan constraints."""
    for raw_group in groups.values():
        if not isinstance(raw_group, dict):
            continue
        members = {
            str(value) for value in raw_group.get("members", [])
        }
        if len(members.intersection(selected)) > int(
            raw_group.get("maximum_selected", 1)
        ):
            return False

    named_cap = max(0, int(month.get("active_named_characters_max", 0)))
    global_cap = max(
        0, int(relationship.get("maximum_active_named_threads", 0))
    )
    if named_cap <= 0:
        named_cap = global_cap
    elif global_cap > 0:
        named_cap = min(named_cap, global_cap)
    if named_cap <= 0:
        return True
    named_characters = {
        str(character).strip()
        for bundle_id in selected
        for character in (
            bundles.get(bundle_id, {}).get("characters", [])
            if isinstance(bundles.get(bundle_id), dict)
            else []
        )
        if str(character).strip()
    }
    return len(named_characters) <= named_cap


def enumerate_legal_month_schedules(
    month: dict[str, Any],
    bundles: dict[str, Any],
    groups: dict[str, Any],
    relationship: dict[str, Any],
) -> tuple[list[dict[str, str]], list[str]]:
    """Exhaustively assign the four weeks, including locks and fallbacks."""
    raw_weeks = month.get("weeks", [])
    if (
        not isinstance(raw_weeks, list)
        or len(raw_weeks) != 2
        or any(not isinstance(value, int) for value in raw_weeks)
    ):
        return [], []
    weeks = list(range(int(raw_weeks[0]), int(raw_weeks[1]) + 1))
    offer_ids: list[str] = []
    for field in ("offers", "fallback_offers"):
        raw_ids = month.get(field, [])
        if not isinstance(raw_ids, list):
            continue
        for raw_bundle_id in raw_ids:
            bundle_id = str(raw_bundle_id).strip()
            if bundle_id and bundle_id not in offer_ids:
                offer_ids.append(bundle_id)
    locked_by_week: dict[int, str] = {}
    for raw_lock in month.get("locked", []):
        if isinstance(raw_lock, dict):
            locked_by_week[int(raw_lock.get("week", 0))] = str(
                raw_lock.get("bundle", "")
            ).strip()

    schedules: list[dict[str, str]] = []

    def assign(
        week_index: int, schedule: dict[str, str], selected: list[str]
    ) -> None:
        if week_index >= len(weeks):
            if selection_within_plan_constraints(
                selected, month, bundles, groups, relationship
            ):
                schedules.append(dict(schedule))
            return
        week = weeks[week_index]
        candidates = (
            [locked_by_week[week]]
            if week in locked_by_week
            else offer_ids
        )
        for bundle_id in candidates:
            bundle = bundles.get(bundle_id)
            if not isinstance(bundle, dict) or bundle_id in selected:
                continue
            allowed_weeks = bundle.get("allowed_weeks", [])
            if not isinstance(allowed_weeks, list) or week not in {
                int(value) for value in allowed_weeks
            }:
                continue
            schedule[str(week)] = bundle_id
            selected.append(bundle_id)
            if selection_within_plan_constraints(
                selected, month, bundles, groups, relationship
            ):
                assign(week_index + 1, schedule, selected)
            selected.pop()
            schedule.pop(str(week), None)

    assign(0, {}, [])
    return schedules, offer_ids


def validate_density_time_hybrid_contracts(
    contract: dict[str, Any],
    bundles: dict[str, Any],
    months: list[Any],
    groups: dict[str, Any],
    relationship: dict[str, Any],
    registered_events: dict[str, dict[str, Any]],
    errors: list[str],
) -> dict[str, Any]:
    """Lock authored density and time to actual legal week assignments."""
    if len(bundles) != 60:
        fail(
            f"24-week density gate expects 60 scene bundles, got {len(bundles)}",
            errors,
        )
    for bundle_id, raw_bundle in bundles.items():
        bundle = raw_bundle if isinstance(raw_bundle, dict) else {}
        minutes = bundle.get("estimated_minutes")
        if (
            not isinstance(minutes, int)
            or isinstance(minutes, bool)
            or minutes <= 0
        ):
            fail(
                f"{bundle_id}.estimated_minutes must be a positive integer, "
                f"got {minutes!r}",
                errors,
            )

    authored_vector: list[int] = []
    practical_vector: list[int] = []
    time_ranges: list[tuple[int, int]] = []
    optional_overhead: list[int] = []
    legal_plan_counts: list[int] = []
    for month_index, raw_month in enumerate(months, start=1):
        if not isinstance(raw_month, dict):
            authored_vector.append(0)
            practical_vector.append(0)
            time_ranges.append((0, 0))
            optional_overhead.append(0)
            legal_plan_counts.append(0)
            continue
        schedules, offer_ids = enumerate_legal_month_schedules(
            raw_month, bundles, groups, relationship
        )
        legal_plan_counts.append(len(schedules))
        if not schedules:
            fail(
                f"month {month_index} has no legal four-week assignment; "
                f"offers={offer_ids}, weeks={raw_month.get('weeks', [])}, "
                f"groups={groups}",
                errors,
            )
            authored_vector.append(0)
            practical_vector.append(0)
            time_ranges.append((0, 0))
            optional_overhead.append(0)
            continue

        offer_set = set(offer_ids)

        def authored_ids(schedule: dict[str, str]) -> list[str]:
            return [
                bundle_id
                for bundle_id in schedule.values()
                if bundle_id in offer_set
                and isinstance(bundles.get(bundle_id), dict)
                and bundle_has_registered_authored_surface(
                    bundles[bundle_id], registered_events
                )
            ]

        authored_witness = max(schedules, key=lambda row: len(authored_ids(row)))
        authored_max = len(authored_ids(authored_witness))

        def practical_count(schedule: dict[str, str]) -> int:
            return sum(
                1
                for bundle_id in authored_ids(schedule)
                if str(bundles[bundle_id].get("kind", ""))
                not in PRACTICAL_EXCLUDED_KINDS
            )

        practical_witness = max(schedules, key=practical_count)
        practical_max = practical_count(practical_witness)
        authored_vector.append(authored_max)
        practical_vector.append(practical_max)

        if month_index <= len(EXPECTED_AUTHORED_BY_MONTH):
            expected_authored = EXPECTED_AUTHORED_BY_MONTH[month_index - 1]
            minimum_authored = 3 if month_index >= 5 else 2
            if authored_max != expected_authored or authored_max < minimum_authored:
                fail(
                    f"month {month_index} authored maximum {authored_max}; "
                    f"expected {expected_authored}, minimum {minimum_authored}; "
                    f"best legal assignment={authored_witness}; offers={offer_ids}",
                    errors,
                )
            expected_practical = EXPECTED_PRACTICAL_AUTHORED_BY_MONTH[
                month_index - 1
            ]
            if practical_max != expected_practical or practical_max < 1:
                fail(
                    f"month {month_index} practical/non-person authored "
                    f"maximum {practical_max}; expected {expected_practical}; "
                    f"best legal assignment={practical_witness}",
                    errors,
                )

        prelude_ids = [
            str(value) for value in raw_month.get("prelude", [])
        ]

        def base_minutes(schedule: dict[str, str]) -> int:
            scheduled = sum(
                int(bundles.get(bundle_id, {}).get("estimated_minutes", 0))
                for bundle_id in schedule.values()
                if isinstance(bundles.get(bundle_id), dict)
            )
            prelude = sum(
                int(bundles.get(bundle_id, {}).get("estimated_minutes", 0))
                for bundle_id in prelude_ids
                if isinstance(bundles.get(bundle_id), dict)
            )
            return scheduled + prelude

        plan_minutes = [base_minutes(schedule) for schedule in schedules]
        minute_range = (min(plan_minutes), max(plan_minutes))
        time_ranges.append(minute_range)
        target_minutes = int(raw_month.get("target_minutes", 0))
        invalid_times = [
            (schedule, minutes)
            for schedule, minutes in zip(schedules, plan_minutes)
            if abs(minutes - target_minutes) > 3
        ]
        if target_minutes <= 0 or invalid_times:
            fail(
                f"month {month_index} legal plan time range "
                f"{minute_range[0]}..{minute_range[1]} misses "
                f"target {target_minutes}±3; examples={invalid_times[:3]}; "
                f"prelude={prelude_ids}, locked={raw_month.get('locked', [])}",
                errors,
            )

        consequence_ids = [
            str(value)
            for value in raw_month.get("conditional_consequences", [])
        ]
        optional_overhead.append(
            sum(
                int(bundles.get(bundle_id, {}).get("estimated_minutes", 0))
                for bundle_id in consequence_ids
                if isinstance(bundles.get(bundle_id), dict)
            )
        )

    target_major_scenes = contract.get("scope", {}).get(
        "target_major_scenes", []
    )
    total_authored = sum(authored_vector)
    if authored_vector != EXPECTED_AUTHORED_BY_MONTH:
        fail(
            f"authored density vector expected {EXPECTED_AUTHORED_BY_MONTH}, "
            f"got {authored_vector}",
            errors,
        )
    if practical_vector != EXPECTED_PRACTICAL_AUTHORED_BY_MONTH:
        fail(
            "practical/non-person density vector expected "
            f"{EXPECTED_PRACTICAL_AUTHORED_BY_MONTH}, got {practical_vector}",
            errors,
        )
    if (
        total_authored != 21
        or not isinstance(target_major_scenes, list)
        or len(target_major_scenes) != 2
        or not int(target_major_scenes[0])
        <= total_authored
        <= int(target_major_scenes[1])
    ):
        fail(
            f"authored total must be 21 inside target_major_scenes, got "
            f"{total_authored} vs {target_major_scenes}",
            errors,
        )

    month_five_group = groups.get("month_five_person_climax", {})
    if not isinstance(month_five_group, dict):
        month_five_group = {}
    person_members = {
        str(value) for value in month_five_group.get("members", [])
    }
    if int(month_five_group.get("maximum_selected", 0)) != 2:
        fail("month_five_person_climax.maximum_selected must be 2", errors)
    for bundle_id in sorted(person_members):
        allowed_weeks = bundles.get(bundle_id, {}).get("allowed_weeks", [])
        expected_weeks = (
            [20] if bundle_id == "daeun_shared_dream" else [19, 20]
        )
        if allowed_weeks != expected_weeks:
            fail(
                f"{bundle_id} must use its story-time window "
                f"{expected_weeks}, got {allowed_weeks}",
                errors,
            )
    if len(months) >= 5 and isinstance(months[4], dict):
        month_five_schedules, _ = enumerate_legal_month_schedules(
            months[4], bundles, groups, relationship
        )
        if not any(
            len(person_members.intersection(schedule.values())) == 2
            for schedule in month_five_schedules
        ):
            fail(
                "month 5 cannot assign two person bundles to distinct legal weeks",
                errors,
            )

    for bundle_id, root_id in ACTION_STORY_ROOTS.items():
        bundle = bundles.get(bundle_id)
        if not isinstance(bundle, dict):
            fail(f"missing action-story hybrid bundle {bundle_id}", errors)
            continue
        if (
            not str(bundle.get("action_id", "")).strip()
            or bundle.get("existing_roots") != [root_id]
            or not bundle_has_registered_authored_surface(
                bundle, registered_events
            )
        ):
            fail(
                f"{bundle_id} must be one registered action+story hybrid "
                f"rooted at {root_id}",
                errors,
            )
        for event_id in sorted(
            reachable_event_ids({root_id}, registered_events)
        ):
            event = registered_events.get(event_id)
            if not isinstance(event, dict):
                fail(
                    f"{bundle_id} hybrid story references missing {event_id}",
                    errors,
                )
                continue
            choices = event.get("choices", [])
            if not isinstance(choices, list) or not choices:
                fail(
                    f"{bundle_id} hybrid story {event_id} has no choices",
                    errors,
                )
                continue
            for choice_index, choice in enumerate(choices):
                if not isinstance(choice, dict):
                    fail(
                        f"{bundle_id} hybrid story {event_id} choice "
                        f"{choice_index} is not an object",
                        errors,
                    )
                    continue
                duplicated_keys = STORY_GAMEPLAY_KEYS.intersection(choice)
                if duplicated_keys:
                    fail(
                        f"{bundle_id} hybrid story {event_id} choice "
                        f"{choice_index} duplicates action gameplay keys "
                        f"{sorted(duplicated_keys)}",
                        errors,
                    )

    return {
        "authored_vector": authored_vector,
        "practical_vector": practical_vector,
        "total_authored": total_authored,
        "time_ranges": time_ranges,
        "optional_overhead": optional_overhead,
        "legal_plan_counts": legal_plan_counts,
    }


def validate_phone_contract(
    phone: dict[str, Any], errors: list[str]
) -> None:
    expected_root_keys = {
        "schema_version",
        "persistent_fields",
        "surface",
        "legacy_migration",
    }
    if set(phone) != expected_root_keys:
        fail(
            "phone contract must contain only the fixed contact surface and "
            "legacy migration metadata",
            errors,
        )
    if int(phone.get("schema_version", 0)) != 3:
        fail("phone.schema_version must be 3", errors)
    if phone.get("persistent_fields") != EXPECTED_PHONE_PERSISTENT_FIELDS:
        fail(
            "phone state must persist only retirement and one-time refund "
            "settlement fields",
            errors,
        )

    surface = require_dict(phone.get("surface"), "phone.surface", errors)
    if set(surface) != {
        "orientation", "tabs", "message_surfaces", "contact_methods"
    }:
        fail("phone.surface contains an app-grid or unknown capability", errors)
    if surface.get("orientation") != "portrait":
        fail("phone.surface.orientation must be portrait", errors)
    if surface.get("tabs") != EXPECTED_PHONE_TABS:
        fail(f"phone.surface.tabs must be {EXPECTED_PHONE_TABS}", errors)
    if surface.get("message_surfaces") != EXPECTED_PHONE_MESSAGE_SURFACES:
        fail(
            "phone messages must contain only inbound_message and call_log",
            errors,
        )
    if surface.get("contact_methods") != EXPECTED_PHONE_CONTACT_METHODS:
        fail(
            "phone contacts must use only phone, kakao, and business_card",
            errors,
        )

    migration = require_dict(
        phone.get("legacy_migration"), "phone.legacy_migration", errors
    )
    if migration != EXPECTED_PHONE_LEGACY_MIGRATION:
        fail(
            "phone legacy migration must refund only the actual schema-2 "
            "KRW 180,000 refurbished purchase, once",
            errors,
        )


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
            elif kind in {"relationship_at_least", "relationship_stage_is"}:
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
            elif kind == "application_status_not_in":
                expected_keys.update({"application_id", "statuses"})
                if not str(clause.get("application_id", "")).strip():
                    fail(f"{owner}.application_id cannot be empty", errors)
                statuses = require_list(
                    clause.get("statuses"), f"{owner}.statuses", errors
                )
                if not statuses or any(
                    not isinstance(value, str) or not value.strip()
                    for value in statuses
                ):
                    fail(f"{owner}.statuses must contain status strings", errors)
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
        reachable = reachable_event_ids(roots, registered_events)
        raw_prerequisites: Any = bundle.get("prerequisites", {})
        prerequisites = (
            raw_prerequisites
            if isinstance(raw_prerequisites, dict)
            else require_dict(
                raw_prerequisites,
                f"{bundle_id}.prerequisites",
                errors,
            )
        )
        prerequisite_states = {
            (
                str(clause.get("application_id", "")),
                str(clause.get("status", "")),
            )
            for clauses in prerequisites.values()
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
            if event_id not in reachable:
                fail(
                    f"{bundle_id} application outcome event {event_id} "
                    "is not reachable from the bundle entry roots",
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
            expected_choice_indexes = list(range(len(event_choices)))
            if bundle_id == "demo_collision":
                # Choosing the City work sample keeps the submitted
                # application live; every other First Bill choice closes it.
                expected_choice_indexes = [
                    value for value in expected_choice_indexes if value != 2
                ]
            if mapped_choices != expected_choice_indexes:
                fail(
                    f"{bundle_id} must map its exact {event_id} application "
                    f"choices {expected_choice_indexes}; got {mapped_choices}",
                    errors,
                )
            required_state = (
                str(row.get("application_id", "")),
                str(row.get("from", "")),
            )
            if (
                bundle_id != "demo_collision"
                and required_state not in prerequisite_states
            ):
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

    hanbit_offer = require_dict(
        registered_events.get("v2_hanbit_offer_message"),
        "registered event v2_hanbit_offer_message",
        errors,
    )
    hanbit_choices = require_list(
        hanbit_offer.get("choices"),
        "registered event v2_hanbit_offer_message.choices",
        errors,
    )
    if len(hanbit_choices) == 2:
        accepted = require_dict(
            hanbit_choices[0],
            "registered event v2_hanbit_offer_message.choices[0]",
            errors,
        )
        declined = require_dict(
            hanbit_choices[1],
            "registered event v2_hanbit_offer_message.choices[1]",
            errors,
        )
        if (
            accepted.get("grant_job") != "job_03"
            or accepted.get("first_paycheck_ratio") != 0.75
            or accepted.get("grant_job_display")
            != {
                "ko": "한빛유통 물류센터 운영지원 계약직",
                "en": "Hanbit Logistics Operations Support (Contract)",
            }
            or "flags" in accepted
            or "grant_job" in declined
            or "flags" in declined
        ):
            fail(
                "Hanbit's exact application receipt must distinguish a "
                "job_03 hire with a three-week first paycheck and exact role "
                "name from a no-job decline without write-only flags",
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
        month_weeks = list(
            range((owner_month - 1) * 4 + 1, owner_month * 4 + 1)
        )
        expected_weeks = expected.get("allowed_weeks", [])
        if (
            allowed_weeks != expected_weeks
            or not set(allowed_weeks).issubset(month_weeks)
        ):
            fail(
                f"{owner_id} response window must be {expected_weeks} "
                f"inside {month_weeks}",
                errors,
            )
        activation_cap_week = int(row.get("activation_cap_week", 0))
        if (
            activation_cap_week != month_weeks[-1]
            or activation_cap_week != development_cap_week
            or row.get("runtime_surface") != "inbound_message"
        ):
            fail(
                f"{owner_id} must be an implemented Month-Six inbound message "
                f"under the Week-{development_cap_week} cap",
                errors,
            )
        owner = require_dict(
            bundles.get(owner_id), f"bundle {owner_id}", errors
        )
        result_event = str(row.get("result_event", ""))
        if (
            owner.get("allowed_weeks") != expected_weeks
            or owner.get("existing_roots") != [result_event]
            or owner.get("phone_surface") != "inbound_message"
            or bool(owner.get("consumes_slot", True))
        ):
            fail(
                f"{owner_id} does not own its exact non-slot response surface",
                errors,
            )
        prerequisite_states = {
            (
                str(clause.get("application_id", "")),
                str(clause.get("status", "")),
            )
            for clauses in require_dict(
                owner.get("prerequisites"),
                f"{owner_id}.prerequisites",
                errors,
            ).values()
            if isinstance(clauses, list)
            for clause in clauses
            if isinstance(clause, dict)
            and clause.get("kind") == "application_status"
        }
        if (str(row.get("application_id", "")), str(row.get("from", ""))) \
                not in prerequisite_states:
            fail(
                f"{owner_id} does not require the exact submitted producer "
                "status",
                errors,
            )
        owner_has_transition = bool(owner.get("application_outcomes", []))
        if (row.get("to") != row.get("from")) != owner_has_transition:
            fail(
                f"{owner_id} application-transition ownership contradicts "
                f"{row.get('from')}→{row.get('to')}",
                errors,
            )

        surface_months: list[tuple[int, str]] = []
        for month_index, raw_month in enumerate(months, start=1):
            month = require_dict(raw_month, f"month {month_index}", errors)
            for collection in (
                "offers",
                "fallback_offers",
                "prelude",
                "conditional_consequences",
                "closing",
            ):
                if owner_id in {
                    str(value) for value in month.get(collection, [])
                }:
                    surface_months.append((month_index, collection))
        if surface_months != [(owner_month, "conditional_consequences")]:
            fail(
                f"{owner_id} must appear once as a Month-{owner_month} "
                f"conditional consequence, got {surface_months}",
                errors,
            )


def validate_future_story_contracts(
    raw_contracts: Any,
    bundles: dict[str, Any],
    registered_events: dict[str, dict[str, Any]],
    development_cap_week: int,
    errors: list[str],
) -> None:
    contracts = require_dict(
        raw_contracts, "future_story_contracts", errors
    )
    if contracts != EXPECTED_FUTURE_STORY_CONTRACTS:
        fail(
            "future story contracts drifted: expected "
            f"{EXPECTED_FUTURE_STORY_CONTRACTS}, got {contracts}",
            errors,
        )

    row = require_dict(
        contracts.get("hyunsu_exam_2026"),
        "future_story_contracts.hyunsu_exam_2026",
        errors,
    )
    producer_id = str(row.get("producer_bundle", ""))
    producer = require_dict(
        bundles.get(producer_id), f"bundle {producer_id}", errors
    )
    required_memories = [
        str(value) for value in require_list(
            row.get("required_memories"),
            "hyunsu_exam_2026.required_memories",
            errors,
        )
    ]
    produced_memories = {
        str(mapping.get("memory", ""))
        for mapping in producer.get("relationship_outcomes", [])
        if isinstance(mapping, dict)
    }
    if set(required_memories) != produced_memories:
        fail(
            "Hyunsu's future result contract must read both exact "
            f"exam-eve memories, got {sorted(produced_memories)}",
            errors,
        )

    exam_week = int(row.get("exam_week", 0))
    available_week = int(row.get("result_available_week", 0))
    if exam_week != development_cap_week or available_week != 27:
        fail(
            "Hyunsu's exam must close Week 24 while its canonical result "
            "waits until Week 27",
            errors,
        )
    trigger_event = require_dict(
        registered_events.get(str(row.get("trigger_event", ""))),
        "hyunsu_exam_2026.trigger_event",
        errors,
    )
    trigger_flags = {
        str(flag)
        for choice in trigger_event.get("choices", [])
        if isinstance(choice, dict)
        for flag in choice.get("flags", [])
    }
    if str(row.get("trigger_flag", "")) not in trigger_flags:
        fail(
            "Hyunsu's Week-24 trigger event does not write its exact exam flag",
            errors,
        )

    result_event_id = str(row.get("result_event", ""))
    result_event = require_dict(
        registered_events.get(result_event_id),
        f"registered event {result_event_id}",
        errors,
    )
    memory_copy = require_dict(
        result_event.get("description_memory_if_known"),
        f"{result_event_id}.description_memory_if_known",
        errors,
    )
    expected_memory_keys = {
        f"relationship_memory:hyunsu:{memory}"
        for memory in required_memories
    }
    unanswered_source = str(row.get("unanswered_source", "")).strip()
    decline_outcome = str(row.get("decline_outcome", "")).strip()
    expected_memory_keys.add(
        "future_story_source:hyunsu_exam_2026:"
        f"{unanswered_source}"
    )
    if set(memory_copy) != expected_memory_keys:
        fail(
            "Hyunsu's canonical result scene must visibly read both V2 "
            "exam-eve answers and the unanswered path",
            errors,
        )
    override_event = str(row.get("legacy_override_event", ""))
    if (
        result_event_id != "hyunsu_result_fail"
        or result_event_id not in registered_events
        or override_event != "hyunsu_result_pass"
        or override_event not in registered_events
        or unanswered_source != "hyunsu_exam_eve_unanswered"
        or decline_outcome
            != "hyunsu_takes_the_exam_without_another_shared_hour"
        or bool(row.get("choice_changes_outcome", True))
        or not bool(row.get("choice_changes_description", False))
    ):
        fail(
            "Hyunsu's V2 handoff must preserve the canonical failure arc, "
            "legacy pass override, and memory-only prose variation",
            errors,
        )
    delayed_chain = [
        (
            "hyunsu_result_fail",
            "arc_hyunsu_exam_fail",
            4,
            None,
        ),
        (
            "arc_hyunsu_exam_fail",
            "arc_hyunsu_drift",
            5,
            {
                "flag": "hyunsu_failed",
                "no_flag": "arc_hyunsu_exam_fail_seen",
                "min_turn": 25,
            },
        ),
        (
            "arc_hyunsu_drift",
            "arc_hyunsu_new_path",
            6,
            {
                "flag": "arc_hyunsu_exam_fail_seen",
                "no_flag": "arc_hyunsu_drift_seen",
                "min_turn": 30,
            },
        ),
    ]
    for producer_id, follow_up_id, delay, producer_conditions in delayed_chain:
        producer_event = require_dict(
            registered_events.get(producer_id),
            f"registered event {producer_id}",
            errors,
        )
        producer_choices = require_list(
            producer_event.get("choices"),
            f"{producer_id}.choices",
            errors,
        )
        if not producer_choices or any(
            not isinstance(choice, dict)
            or str(choice.get("deferred_follow_up", "")) != follow_up_id
            or int(choice.get("deferred_delay", 0)) != delay
            for choice in producer_choices
        ):
            fail(
                "Hyunsu's failure handoff must preserve the exact "
                f"{producer_id} → {follow_up_id} +{delay}-week chain",
                errors,
            )
        if producer_conditions is not None and require_dict(
            producer_event.get("conditions"),
            f"{producer_id}.conditions",
            errors,
        ) != producer_conditions:
            fail(
                f"{producer_id} must remain eligible when its delayed "
                "callback becomes due",
                errors,
            )
    new_path_conditions = {
        "flag": "arc_hyunsu_drift_seen",
        "no_flag": "arc_hyunsu_new_path_seen",
        "min_turn": 36,
    }
    if require_dict(
        registered_events.get("arc_hyunsu_new_path", {}).get(
            "conditions"
        ),
        "arc_hyunsu_new_path.conditions",
        errors,
    ) != new_path_conditions:
        fail(
            "arc_hyunsu_new_path must remain eligible for the final "
            "delayed callback",
            errors,
        )


def validate_post_demo_application_contracts(
    raw_contracts: Any,
    bundles: dict[str, Any],
    registered_events: dict[str, dict[str, Any]],
    development_cap_week: int,
    errors: list[str],
) -> None:
    contracts = require_dict(
        raw_contracts, "post_demo_application_contracts", errors
    )
    if contracts != EXPECTED_POST_DEMO_APPLICATION_CONTRACTS:
        fail(
            "post-demo application contracts drifted: expected "
            f"{EXPECTED_POST_DEMO_APPLICATION_CONTRACTS}, got {contracts}",
            errors,
        )
    row = require_dict(
        contracts.get("city_facility_ops_2026h1_result"),
        "post_demo_application_contracts.city_facility_ops_2026h1_result",
        errors,
    )
    producer = require_dict(
        bundles.get(str(row.get("producer_bundle", ""))),
        "City post-demo producer bundle",
        errors,
    )
    obligation_rows = require_list(
        producer.get("obligation_outcomes"),
        "City post-demo producer obligation outcomes",
        errors,
    )
    expected_choice = int(row.get("producer_choice", -1))
    if not any(
        isinstance(outcome, dict)
        and str(outcome.get("event_id", ""))
            == str(row.get("producer_event", ""))
        and expected_choice in outcome.get("choices", [])
        and str(outcome.get("selected_obligation_id", ""))
            == str(row.get("selected_obligation_id", ""))
        for outcome in obligation_rows
    ):
        fail(
            "City post-demo result is not owned by the exact Week-24 choice",
            errors,
        )
    if (
        int(row.get("not_before_week", 0)) != 28
        or int(row.get("not_after_week", 0)) != 32
        or int(row.get("not_before_week", 0)) <= development_cap_week
        or str(row.get("from", "")) != "submitted"
        or str(row.get("to", "")) != "no_offer"
    ):
        fail(
            "City post-demo result must close submitted→no_offer in "
            "Weeks 28–32",
            errors,
        )
    result_event = require_dict(
        registered_events.get(str(row.get("result_event", ""))),
        "City post-demo result event",
        errors,
    )
    result_flag = str(row.get("result_flag", ""))
    choice_flags = {
        str(flag)
        for choice in result_event.get("choices", [])
        if isinstance(choice, dict)
        for flag in choice.get("flags", [])
    }
    if result_flag != "v2_city_service_result_seen" \
            or result_flag not in choice_flags:
        fail(
            "City post-demo result event does not consume its exact flag",
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
        if development_cap_week != due_week:
            fail(
                f"{callback_id} must be consumed exactly when the Week "
                f"{due_week} runtime gate opens",
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
    phone = require_dict(contract.get("phone"), "phone", errors)
    routine = require_dict(contract.get("routine"), "routine", errors)
    relationship = require_dict(contract.get("relationship"), "relationship", errors)
    bundles = require_dict(contract.get("scene_bundles"), "scene_bundles", errors)
    months = require_list(contract.get("months"), "months", errors)
    groups = require_dict(contract.get("exclusive_groups"), "exclusive_groups", errors)

    if int(contract.get("schema_version", 0)) != 3:
        fail("schema_version must be 3 for the 24-week executable contract", errors)
    if bool(contract.get("runtime_default", True)):
        fail("runtime_default must stay false before the 24-week human GO", errors)
    if str(contract.get("fallback", "")) != "event_director_v1":
        fail("existing event director must remain the development fallback", errors)
    validate_phone_contract(phone, errors)

    expected_scope = {
        "min_week": 1,
        "max_week": 24,
        "months": 6,
        "weeks_per_month": 4,
        "development_cap_week": 24,
        "prototype_weeks": [1, 24],
    }
    for key, expected in expected_scope.items():
        if scope.get(key) != expected:
            fail(f"scope.{key} expected {expected!r}, got {scope.get(key)!r}", errors)
    play_minutes = require_list(scope.get("target_play_minutes"), "target_play_minutes", errors)
    if play_minutes != [75, 95]:
        fail("target_play_minutes must remain [75, 95]", errors)
    if scope.get("target_play_minutes_basis") != "pre_playtest_estimate":
        fail(
            "target_play_minutes_basis must remain pre_playtest_estimate "
            "until a normal-speed playtest replaces it with measurements",
            errors,
        )
    development_cap_week = int(scope.get("development_cap_week", 0))
    weeks_per_month = int(scope.get("weeks_per_month", 0))
    if weeks_per_month <= 0 or development_cap_week % weeks_per_month != 0:
        fail("development_cap_week must end on a month boundary", errors)
        development_month_count = 0
    else:
        development_month_count = development_cap_week // weeks_per_month
    if development_month_count != 6:
        fail(
            "the E gate must expose exactly six completed development months",
            errors,
        )
    if (
        long_arc.get("demo_role") != "chapter_one_first_half"
        or int(long_arc.get("chapter_one_end_week", 0)) != 48
        or long_arc.get("chapter_close_weeks") != [48, 96, 144, 192]
        or int(long_arc.get("full_run_end_week", 0)) != 240
        or int(long_arc.get("year_count", 0)) != 5
        or long_arc.get("chapter_one_boss_window") != [45, 48]
        or not bool(long_arc.get("week_24_is_midyear_boss", False))
    ):
        fail(
            "24-week demo must remain the first half of a 48-week chapter; "
            "chapter closes must stay exact at Weeks 48/96/144/192 in the "
            "240-week run",
            errors,
        )
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

    if surface.get("primary") != "monthly_planner":
        fail("surface.primary must be the wide monthly_planner", errors)
    if surface.get("tabs") != EXPECTED_TABS:
        fail(f"monthly planner tabs must be {EXPECTED_TABS}", errors)
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
    temptation_bundle = require_dict(
        bundles.get("temptation_consequence"),
        "scene_bundles.temptation_consequence",
        errors,
    )
    if (
        temptation_bundle.get("allowed_weeks") != [8]
        or temptation_bundle.get("existing_roots")
        != ["arc_temptation_clean", "arc_temptation_fallout"]
    ):
        fail(
            "Week-8 temptation consequence must schedule both clean and dirty roots",
            errors,
        )
    clean_consequence = require_dict(
        registered_events.get("arc_temptation_clean"),
        "registered event arc_temptation_clean",
        errors,
    )
    clean_choices = require_list(
        clean_consequence.get("choices"),
        "arc_temptation_clean.choices",
        errors,
    )
    if (
        len(clean_choices) != 1
        or not isinstance(clean_choices[0], dict)
        or clean_choices[0].get("effects") != {"mental": 10}
        or not {"arc_temptation_clean_seen", "stayed_clean"}.issubset(
            set(clean_choices[0].get("flags", []))
        )
    ):
        fail(
            "arc_temptation_clean must apply the mandatory Week-8 mental +10 receipt",
            errors,
        )
    demo_core_loop_source = DEMO_CORE_LOOP_PATH.read_text(encoding="utf-8")
    clean_branch_pattern = re.compile(
        r'if bundle_id == "temptation_consequence":\s*'
        r'if bool\(GameState\.flags\.get\("lent_account", false\)\):\s*'
        r'return \["arc_temptation_fallout"\]\s*'
        r'return \["arc_temptation_clean"\]'
    )
    if not clean_branch_pattern.search(demo_core_loop_source):
        fail(
            "DemoCoreLoopV2 must route the mandatory Week-8 clean consequence "
            "when lent_account is absent",
            errors,
        )
    cafe_honest_in = require_dict(
        registered_events.get("cafe_cb_honest_in"),
        "registered event cafe_cb_honest_in",
        errors,
    )
    cafe_honest_choices = require_list(
        cafe_honest_in.get("choices"),
        "cafe_cb_honest_in.choices",
        errors,
    )
    cafe_invest_flags = (
        set(cafe_honest_choices[0].get("flags", []))
        if cafe_honest_choices and isinstance(cafe_honest_choices[0], dict)
        else set()
    )
    if "cafe_honest_invested" not in cafe_invest_flags \
            or "kept_clean_hands" in cafe_invest_flags:
        fail(
            "the later honest cafe investment must not forge the Week-4 "
            "bank-account refusal receipt",
            errors,
        )
    clean_hand_producers: list[tuple[str, int]] = []
    for event_id, event in registered_events.items():
        if not isinstance(event, dict):
            continue
        choices = event.get("choices", [])
        if not isinstance(choices, list):
            continue
        for choice_index, choice in enumerate(choices):
            if isinstance(choice, dict) and "kept_clean_hands" in choice.get(
                "flags", []
            ):
                clean_hand_producers.append((event_id, choice_index))
    if clean_hand_producers != [("arc_temptation_01", 0)]:
        fail(
            "kept_clean_hands must be produced only by the exact Week-4 "
            f"bank-account refusal choice: {clean_hand_producers}",
            errors,
        )
    v2_direction_events, prologue_direction_events = (
        validate_demo_direction_coverage(
            contract,
            bundles,
            registered_events,
            errors,
        )
    )
    density_summary = validate_density_time_hybrid_contracts(
        contract,
        bundles,
        months,
        groups,
        relationship,
        registered_events,
        errors,
    )
    validate_korean_active_event_copy(registered_events, errors)
    validate_application_outcomes(bundles, registered_events, errors)
    validate_future_application_contracts(
        contract.get("future_application_contracts"),
        bundles,
        months,
        development_cap_week,
        errors,
    )
    validate_future_story_contracts(
        contract.get("future_story_contracts"),
        bundles,
        registered_events,
        development_cap_week,
        errors,
    )
    validate_post_demo_application_contracts(
        contract.get("post_demo_application_contracts"),
        bundles,
        registered_events,
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
        if (
            bool(bundle.get("consumes_slot", False))
            and str(bundle.get("kind", "")) != "boss"
            and not str(bundle.get("decline_consequence", ""))
        ):
            fail(f"{bundle_id} consumes a slot but has no decline consequence", errors)
        stage = str(bundle.get("relationship_stage", ""))
        if stage and stage not in EXPECTED_STAGES:
            fail(f"{bundle_id} has unknown relationship stage {stage}", errors)

    expected_groups = {
        "romance_entry": {"daeun_world_meet", "jiyeon_world_meet"},
        "money_mentor_entry": {"sangchul_world_meet", "jaehyuk_world_meet"},
        "month_five_person_climax": {
            "daeun_shared_dream",
            "daeun_third_greeting",
            "jiyeon_second_crossing",
            "sangchul_second_coffee",
            "jaehyuk_plain_reunion_echo",
        },
    }
    for group_id, expected_members in expected_groups.items():
        group = require_dict(groups.get(group_id), f"group {group_id}", errors)
        members = set(str(value) for value in require_list(group.get("members"), f"{group_id}.members", errors))
        if members != expected_members:
            fail(f"{group_id} members expected {sorted(expected_members)}, got {sorted(members)}", errors)
        expected_maximum = 2 if group_id == "month_five_person_climax" else 1
        if int(group.get("maximum_selected", 0)) != expected_maximum:
            fail(
                f"{group_id} must allow at most {expected_maximum} "
                "selection(s) per month",
                errors,
            )
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
            and expected_month not in {4, 5}
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
            elif (
                expected_month <= development_month_count
                and str(
                    require_dict(
                        bundles.get(bundle_id), f"bundle {bundle_id}", errors
                    ).get("kind", "")
                )
                != "boss"
            ):
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
            if expected_month <= development_month_count:
                allowed_non_slot = (
                    expected_month == 6
                    and collection_key == "prelude"
                    and surface_ids == ["father_health_signal"]
                )
                if (
                    collection_key in {"prelude", "closing"}
                    and surface_ids
                    and not allowed_non_slot
                ):
                    fail(
                        f"month {expected_month} declares unsupported "
                        f"{collection_key} bundles {surface_ids}",
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

    if development_month_count >= 4 and len(months) >= 4:
        month_four = require_dict(months[3], "month 4", errors)
        month_four_offers = [
            str(value) for value in month_four.get("offers", [])
        ]
        month_four_fallbacks = [
            str(value) for value in month_four.get("fallback_offers", [])
        ]
        month_four_fixtures = {
            "sparse_no_prior_person_or_hanbit": {
                "completed": set(),
                "stages": {},
                "memories": set(),
                "applications": {},
            },
            "hanbit_and_named_daeun": {
                "completed": {"m3_hanbit_application", "daeun_world_meet"},
                "stages": {"daeun": "opening"},
                "memories": {("daeun", "daeun_name_exchanged")},
                "applications": {"hanbit_ops_2026q1": "submitted"},
            },
            "distance_daeun": {
                "completed": {"daeun_world_meet"},
                "stages": {"daeun": "met"},
                "memories": {("daeun", "daeun_kept_distance")},
                "applications": {},
            },
            "jiyeon": {
                "completed": {"jiyeon_world_meet"},
                "stages": {"jiyeon": "met"},
                "memories": {("jiyeon", "jiyeon_walked_away")},
                "applications": {},
            },
            "money_paths_and_named_daeun": {
                "completed": {
                    "cafe_world_glimpse",
                    "sns_pressure_night",
                    "daeun_world_meet",
                },
                "stages": {"daeun": "opening"},
                "memories": {("daeun", "daeun_name_exchanged")},
                "applications": {},
            },
        }
        minimum = int(surface.get("minimum_offers_per_month", 5))
        maximum = int(surface.get("maximum_offers_per_month", 7))
        for fixture_name, fixture in month_four_fixtures.items():
            visible = [
                bundle_id
                for bundle_id in month_four_offers
                if bundle_available_in_fixture(
                    require_dict(
                        bundles.get(bundle_id),
                        f"bundle {bundle_id}",
                        errors,
                    ),
                    fixture,
                )
            ]
            if len(visible) < minimum:
                for bundle_id in month_four_fallbacks:
                    if bundle_available_in_fixture(
                        require_dict(
                            bundles.get(bundle_id),
                            f"bundle {bundle_id}",
                            errors,
                        ),
                        fixture,
                    ):
                        visible.append(bundle_id)
                    if len(visible) >= minimum:
                        break
            if not minimum <= len(visible) <= maximum:
                fail(
                    f"month 4 fixture {fixture_name} must expose "
                    f"{minimum}..{maximum} offers, got {len(visible)}: {visible}",
                    errors,
                )
            if (
                fixture.get("applications", {}).get(
                    "hanbit_ops_2026q1", ""
                )
                == "submitted"
            ):
                if "m4_hanbit_interview" not in visible \
                        or "m4_dodam_application" in visible:
                    fail(
                        "submitted Hanbit status must replace Dodam with the "
                        "authored interview offer",
                        errors,
                    )
            elif "m4_dodam_application" not in visible \
                    or "m4_hanbit_interview" in visible:
                fail(
                    "without a submitted Hanbit application, Dodam must remain "
                    "available and the interview hidden",
                    errors,
                )

    if development_month_count >= 5 and len(months) >= 5:
        month_five = require_dict(months[4], "month 5", errors)
        month_five_offers = [
            str(value) for value in month_five.get("offers", [])
        ]
        month_five_fixtures = {
            "sparse_no_person_path": {
                "completed": set(),
                "stages": {},
                "memories": set(),
                "player_initiated": set(),
                "applications": {},
            },
            "named_daeun_and_sangchul": {
                "completed": {"daeun_player_return", "sangchul_world_meet"},
                "stages": {
                    "daeun": "player_reached_out",
                    "sangchul": "met",
                },
                "memories": {
                    ("daeun", "daeun_returned_using_her_name"),
                    ("sangchul", "sangchul_spoke_of_father"),
                },
                "player_initiated": {"daeun", "sangchul"},
                "applications": {},
            },
            "distance_daeun_and_jaehyuk": {
                "completed": {
                    "daeun_return_after_distance",
                    "jaehyuk_world_meet",
                },
                "stages": {"daeun": "opening", "jaehyuk": "met"},
                "memories": {
                    ("daeun", "daeun_names_exchanged_on_return"),
                    ("jaehyuk", "jaehyuk_message_guarded"),
                },
                "player_initiated": {"daeun"},
                "applications": {},
            },
            "jiyeon_and_sangchul": {
                "completed": {
                    "jiyeon_bus_stop_reunion",
                    "sangchul_world_meet",
                },
                "stages": {"jiyeon": "opening", "sangchul": "met"},
                "memories": {
                    ("jiyeon", "jiyeon_name_offered_after_silence"),
                    ("sangchul", "sangchul_kept_goal_plain"),
                },
                "player_initiated": {"sangchul"},
                "applications": {},
            },
        }
        minimum = int(surface.get("minimum_offers_per_month", 5))
        maximum = int(surface.get("maximum_offers_per_month", 7))
        person_members = expected_groups["month_five_person_climax"]
        for fixture_name, fixture in month_five_fixtures.items():
            visible = [
                bundle_id
                for bundle_id in month_five_offers
                if bundle_available_in_fixture(
                    require_dict(
                        bundles.get(bundle_id),
                        f"bundle {bundle_id}",
                        errors,
                    ),
                    fixture,
                )
            ]
            if not minimum <= len(visible) <= maximum:
                fail(
                    f"month 5 fixture {fixture_name} must expose "
                    f"{minimum}..{maximum} offers, got {len(visible)}: {visible}",
                    errors,
                )
            visible_people = person_members.intersection(visible)
            expected_people = 0 if fixture_name == "sparse_no_person_path" else 2
            if len(visible_people) != expected_people:
                fail(
                    f"month 5 fixture {fixture_name} expected "
                    f"{expected_people} live person offers, got "
                    f"{sorted(visible_people)}",
                    errors,
                )

    if development_month_count >= 6 and len(months) >= 6:
        month_six = require_dict(months[5], "month 6", errors)
        month_six_offers = [
            str(value) for value in month_six.get("offers", [])
        ]
        month_six_fixtures = {
            "base": {
                "completed": set(),
                "stages": {},
                "memories": set(),
                "player_initiated": set(),
                "applications": {},
            },
            "hyunsu_followthrough": {
                "completed": {"hyunsu_study_followup"},
                "stages": {"hyunsu": "shared_commitment"},
                "memories": set(),
                "player_initiated": set(),
                "applications": {},
            },
            "daeun_followthrough": {
                "completed": {"daeun_shared_dream"},
                "stages": {"daeun": "shared_commitment"},
                "memories": {
                    ("daeun", "daeun_same_tuesday_promised"),
                },
                "player_initiated": {"daeun"},
                "applications": {},
            },
            "both_person_paths": {
                "completed": {
                    "hyunsu_study_followup",
                    "daeun_shared_dream",
                },
                "stages": {
                    "hyunsu": "shared_commitment",
                    "daeun": "shared_commitment",
                },
                "memories": {
                    ("daeun", "daeun_same_tuesday_promised"),
                },
                "player_initiated": {"daeun"},
                "applications": {},
            },
        }
        expected_base = {
            "m6_public_recruitment",
            "m6_holiday_night_shift",
            "m6_last_study_group",
            "m6_no_plans_day",
            "m6_gangnam_receipt_walk",
        }
        conditional_ids = {
            "hyunsu_exam_eve",
            "m6_daeun_tuesday_followthrough",
        }
        expected_by_fixture = {
            "base": expected_base,
            "hyunsu_followthrough": expected_base | {"hyunsu_exam_eve"},
            "daeun_followthrough": expected_base
            | {"m6_daeun_tuesday_followthrough"},
            "both_person_paths": expected_base | conditional_ids,
        }
        minimum = int(surface.get("minimum_offers_per_month", 5))
        maximum = int(surface.get("maximum_offers_per_month", 7))
        for fixture_name, fixture in month_six_fixtures.items():
            visible = {
                bundle_id
                for bundle_id in month_six_offers
                if bundle_available_in_fixture(
                    require_dict(
                        bundles.get(bundle_id),
                        f"bundle {bundle_id}",
                        errors,
                    ),
                    fixture,
                )
            }
            if visible != expected_by_fixture[fixture_name]:
                fail(
                    f"month 6 fixture {fixture_name} expected "
                    f"{sorted(expected_by_fixture[fixture_name])}, got "
                    f"{sorted(visible)}",
                    errors,
                )
            if not minimum <= len(visible) <= maximum:
                fail(
                    f"month 6 fixture {fixture_name} must expose "
                    f"{minimum}..{maximum} offers, got {len(visible)}",
                    errors,
                )

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
    for bundle_id, expected_weeks in EXPECTED_M4_ALLOWED_WEEKS.items():
        bundle = require_dict(bundles.get(bundle_id), f"bundle {bundle_id}", errors)
        if bundle.get("allowed_weeks") != expected_weeks:
            fail(
                f"{bundle_id}.allowed_weeks expected {expected_weeks}, "
                f"got {bundle.get('allowed_weeks')}",
                errors,
            )
    for bundle_id, expected_weeks in EXPECTED_M5_ALLOWED_WEEKS.items():
        bundle = require_dict(bundles.get(bundle_id), f"bundle {bundle_id}", errors)
        if bundle.get("allowed_weeks") != expected_weeks:
            fail(
                f"{bundle_id}.allowed_weeks expected {expected_weeks}, "
                f"got {bundle.get('allowed_weeks')}",
                errors,
            )
    for bundle_id, expected_weeks in EXPECTED_M6_ALLOWED_WEEKS.items():
        bundle = require_dict(bundles.get(bundle_id), f"bundle {bundle_id}", errors)
        if bundle.get("allowed_weeks") != expected_weeks:
            fail(
                f"{bundle_id}.allowed_weeks expected {expected_weeks}, "
                f"got {bundle.get('allowed_weeks')}",
                errors,
            )

    expected_m4_phone_surfaces = {
        "m4_hanbit_interview": "inbound_message",
        "m4_dodam_application": "self_note",
        "m4_certificate_session": "self_note",
        "m4_logistics_shift": "self_note",
        "m4_health_check_day": "self_note",
        "m4_housing_welfare_consultation": "self_note",
        "daeun_player_return": "self_note",
        "daeun_return_after_distance": "self_note",
        "jiyeon_bus_stop_reunion": "world_encounter",
        "sangchul_world_meet": "self_note",
        "jaehyuk_world_meet": "inbound_message",
    }
    for bundle_id, expected_surface in expected_m4_phone_surfaces.items():
        bundle = require_dict(bundles.get(bundle_id), f"bundle {bundle_id}", errors)
        if bundle.get("phone_surface") != expected_surface:
            fail(
                f"{bundle_id}.phone_surface expected {expected_surface!r}, "
                f"got {bundle.get('phone_surface')!r}",
                errors,
            )
        if expected_surface == "inbound_message":
            for field in (
                "message_sender_ko",
                "message_sender_en",
                "message_body_ko",
                "message_body_en",
            ):
                value = str(bundle.get(field, "")).strip()
                if not value:
                    fail(f"{bundle_id} inbound message is missing {field}", errors)
                elif field.endswith("_en") and HANGUL_RE.search(value):
                    fail(f"{bundle_id}.{field} leaks Hangul into English", errors)

    expected_m5_phone_surfaces = {
        "m5_city_service_application": "self_note",
        "m5_weekend_move_shift": "self_note",
        "m5_evening_spreadsheet_class": "self_note",
        "m5_last_empty_sunday": "self_note",
        "m5_employment_contract_clinic": "self_note",
        "daeun_shared_dream": "self_note",
        "daeun_third_greeting": "self_note",
        "jiyeon_second_crossing": "self_note",
        "sangchul_second_coffee": "self_note",
        "jaehyuk_plain_reunion_echo": "inbound_message",
        "m5_hanbit_offer_message": "inbound_message",
    }
    for bundle_id, expected_surface in expected_m5_phone_surfaces.items():
        bundle = require_dict(bundles.get(bundle_id), f"bundle {bundle_id}", errors)
        if bundle.get("phone_surface") != expected_surface:
            fail(
                f"{bundle_id}.phone_surface expected {expected_surface!r}, "
                f"got {bundle.get('phone_surface')!r}",
                errors,
            )
        if expected_surface == "inbound_message":
            for field in (
                "message_sender_ko",
                "message_sender_en",
                "message_body_ko",
                "message_body_en",
            ):
                value = str(bundle.get(field, "")).strip()
                if not value:
                    fail(f"{bundle_id} inbound message is missing {field}", errors)
                elif field.endswith("_en") and HANGUL_RE.search(value):
                    fail(f"{bundle_id}.{field} leaks Hangul into English", errors)

    expected_m6_phone_surfaces = {
        "father_health_signal": "inbound_message",
        "m6_public_recruitment": "self_note",
        "m6_holiday_night_shift": "self_note",
        "m6_last_study_group": "self_note",
        "m6_no_plans_day": "self_note",
        "m6_gangnam_receipt_walk": "self_note",
        "hyunsu_exam_eve": "inbound_message",
        "m6_daeun_tuesday_followthrough": "self_note",
        "m6_dodam_response": "inbound_message",
        "m6_city_service_response": "inbound_message",
    }
    for bundle_id, expected_surface in expected_m6_phone_surfaces.items():
        bundle = require_dict(bundles.get(bundle_id), f"bundle {bundle_id}", errors)
        if bundle.get("phone_surface") != expected_surface:
            fail(
                f"{bundle_id}.phone_surface expected {expected_surface!r}, "
                f"got {bundle.get('phone_surface')!r}",
                errors,
            )
        if expected_surface == "inbound_message":
            for field in (
                "message_sender_ko",
                "message_sender_en",
                "message_body_ko",
                "message_body_en",
            ):
                value = str(bundle.get(field, "")).strip()
                if not value:
                    fail(f"{bundle_id} inbound message is missing {field}", errors)
                elif field.endswith("_en") and HANGUL_RE.search(value):
                    fail(f"{bundle_id}.{field} leaks Hangul into English", errors)

    city_application = require_dict(
        bundles.get("m5_city_service_application"),
        "bundle m5_city_service_application",
        errors,
    )
    if (
        city_application.get("deadline_ko") != "17주차 금요일 오후 6시"
        or city_application.get("deadline_en")
        != "Friday at 6:00 p.m. in Week 17"
    ):
        fail(
            "the Week-17 city application must remain open after Hanbit's "
            "Tuesday hiring message",
            errors,
        )
    for intensive_id in (
        "m5_weekend_move_shift",
        "m5_evening_spreadsheet_class",
    ):
        intensive = require_dict(
            bundles.get(intensive_id), f"bundle {intensive_id}", errors
        )
        authored_copy = " ".join(
            str(intensive.get(field, ""))
            for field in (
                "offer_ko",
                "detail_ko",
                "offer_en",
                "detail_en",
            )
        )
        config = require_dict(
            intensive.get("action_config"),
            f"bundle {intensive_id}.action_config",
            errors,
        )
        authored_copy += " " + " ".join(
            str(config.get(field, ""))
            for field in (
                "result_title_ko",
                "result_body_ko",
                "result_title_en",
                "result_body_en",
            )
        )
        if (
            "선택한 주" not in authored_copy
            or any(
                stale in authored_copy
                for stale in ("토요일 네 번", "토요일마다", "Four Saturdays")
            )
        ):
            fail(
                f"{intensive_id} still grants future weeks before they occur",
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

    for bundle_id, expected_core in EXPECTED_M4_ACTION_CORE.items():
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

    for bundle_id, expected_core in EXPECTED_M5_ACTION_CORE.items():
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

    for bundle_id, expected_core in EXPECTED_M6_ACTION_CORE.items():
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
        raw_transition = outcome.get("application_transition")
        if consequence_id == "hanbit_interview_not_attended":
            expected_transition = {
                "application_id": "hanbit_ops_2026q1",
                "from": "submitted",
                "to": "not_attended",
            }
            if raw_transition != expected_transition:
                fail(
                    "declining the Hanbit interview must close submitted as "
                    f"not_attended, got {raw_transition}",
                    errors,
                )
        elif raw_transition is not None:
            fail(
                f"{consequence_id} has an unowned application transition",
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
    for bundle_id, (consumer_kind, visible_month) in EXPECTED_M5_DECLINES.items():
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
    for bundle_id, (consumer_kind, visible_month) in EXPECTED_M6_DECLINES.items():
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
    } | {"father_health_signal"}
    for bundle_id in sorted(development_relationship_ids):
        bundle = require_dict(bundles.get(bundle_id), f"bundle {bundle_id}", errors)
        roots = [str(value) for value in bundle.get("existing_roots", [])]
        reachable = reachable_event_ids(set(roots), registered_events)
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
            if event_id not in reachable:
                fail(
                    f"{bundle_id} relationship outcome references unreachable "
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
                "allow_already_at_target",
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
            allow_already_at_target = mapping.get(
                "allow_already_at_target", False
            )
            if not isinstance(allow_already_at_target, bool):
                fail(
                    f"{bundle_id} allow_already_at_target must be boolean",
                    errors,
                )
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
            if allow_already_at_target and from_stage == to_stage:
                fail(
                    f"{bundle_id} allow_already_at_target requires a real "
                    "from/to transition",
                    errors,
                )
            if (
                from_stage in EXPECTED_STAGES
                and to_stage in EXPECTED_STAGES
                and from_stage != "unmet"
                and EXPECTED_STAGES.index(to_stage)
                > EXPECTED_STAGES.index(from_stage) + 1
            ):
                fail(
                    f"{bundle_id} relationship outcome skips an intermediate "
                    f"stage ({from_stage} -> {to_stage})",
                    errors,
                )
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
            elif len(choices) != 1 and not (
                bundle_id == "m6_daeun_tuesday_followthrough"
                and choices == [0, 1]
                and memory == "daeun_tuesday_checkin_kept"
            ):
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
        for event_id, actual_choice_indexes in mapped_choices.items():
            event = require_dict(
                registered_events.get(event_id),
                f"registered event {event_id}",
                errors,
            )
            choices = require_list(
                event.get("choices"), f"registered event {event_id}.choices", errors
            )
            expected_choice_indexes = set(range(len(choices)))
            if actual_choice_indexes != expected_choice_indexes:
                fail(
                    f"{bundle_id} must map every {event_id} choice exactly once: "
                    f"expected {sorted(expected_choice_indexes)}, got "
                    f"{sorted(actual_choice_indexes)}",
                    errors,
                )
            if event_id not in roots and any(
                isinstance(choice, dict)
                and str(choice.get("follow_up_event", "")).strip()
                for choice in choices
            ):
                fail(
                    f"{bundle_id} relationship outcome event {event_id} is "
                    "not terminal in its authored follow-up graph",
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
    ]:
        fail(
            "Hyunsu player reach-out must queue only the message entry root; "
            "the next-day study scene is reached through its authored follow-up",
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
        ("daeun", "daeun_returned_using_her_name"): {"daeun_shared_dream"},
        ("daeun", "daeun_returned_to_thank_her"): {"daeun_shared_dream"},
        ("daeun", "daeun_names_exchanged_on_return"): {
            "daeun_third_greeting"
        },
        ("daeun", "daeun_thanks_reopened_conversation"): {
            "daeun_third_greeting"
        },
        ("jiyeon", "jiyeon_name_offered_after_silence"): {
            "jiyeon_second_crossing"
        },
        ("jiyeon", "jiyeon_name_exchanged_after_player_spoke"): {
            "jiyeon_second_crossing"
        },
        ("sangchul", "sangchul_spoke_of_father"): {
            "sangchul_second_coffee"
        },
        ("sangchul", "sangchul_kept_goal_plain"): {
            "sangchul_second_coffee"
        },
        ("sangchul", "sangchul_named_city_pride"): {
            "sangchul_second_coffee"
        },
        ("jaehyuk", "jaehyuk_message_welcomed"): {
            "jaehyuk_plain_reunion_echo"
        },
        ("jaehyuk", "jaehyuk_message_guarded"): {
            "jaehyuk_plain_reunion_echo"
        },
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
        or father_signal.get("existing_roots") != ["v2_father_health_signal"]
        or bool(father_signal.get("consumes_slot", True))
        or "requires_player_initiated" in father_signal
    ):
        fail("Father's health signal must remain a universal Week 21 world fact", errors)
    if (
        "약국 봉투" not in str(father_signal.get("message_body_ko", ""))
        or "pharmacy" not in str(father_signal.get("message_body_en", "")).lower()
    ):
        fail(
            "Father's Week-21 phone preview must report the observed pharmacy "
            "bags instead of presenting a hospital visit as known fact",
            errors,
        )
    father_signal_event = require_dict(
        registered_events.get("v2_father_health_signal"),
        "registered event v2_father_health_signal",
        errors,
    )
    father_signal_choices = require_list(
        father_signal_event.get("choices"),
        "registered event v2_father_health_signal.choices",
        errors,
    )
    expected_father_signal_choices = [
        (
            {"mental": -3},
            {"arc_father_01_seen", "arc_father_02_done"},
        ),
        (
            {"mental": -2},
            {"arc_father_01_seen", "arc_father_02_done"},
        ),
        (
            {"mental": -5},
            {"arc_father_01_seen", "arc_father_02_done"},
        ),
    ]
    if len(father_signal_choices) != len(expected_father_signal_choices):
        fail("Father's Week-21 signal must keep exactly three choices", errors)
    else:
        for choice_index, (expected_effects, expected_flags) in enumerate(
            expected_father_signal_choices
        ):
            choice = require_dict(
                father_signal_choices[choice_index],
                f"v2_father_health_signal.choices[{choice_index}]",
                errors,
            )
            if (
                choice.get("effects") != expected_effects
                or {
                    str(value) for value in choice.get("flags", [])
                }
                != expected_flags
            ):
                fail(
                    f"Father's Week-21 choice {choice_index} must preserve "
                    f"its exact mental effect and canonical arc flag",
                    errors,
                )
    serialized_father_signal = json.dumps(
        father_signal_event, ensure_ascii=False
    )
    if any(
        invented in serialized_father_signal
        for invented in ("-50000", "-50,000", "기차표", "승차권", "송금했다")
    ):
        fail(
            "Father's Week-21 signal invents travel, remittance, or KRW 50,000",
            errors,
        )

    demo_collision = require_dict(
        bundles.get("demo_collision"), "bundle demo_collision", errors
    )
    if (
        demo_collision.get("planned_scene_id") != "v2_demo_first_bill"
        or demo_collision.get("existing_roots") != ["v2_demo_first_bill"]
        or demo_collision.get("allowed_weeks") != [24]
        or int(demo_collision.get("locked_week", 0)) != 24
    ):
        fail(
            "Week 24 must own the exact First Bill root at the locked boss slot",
            errors,
        )
    expected_obligation_ids = [
        "father_call",
        "hanbit_month_close",
        "city_work_sample",
        "daeun_checkin",
        "jaehyuk_reply",
        "sangchul_ledger",
        "urgent_paid_shift",
        "body_rest",
    ]
    expected_obligation_outcomes = [
        {
            "event_id": "v2_demo_first_bill",
            "choices": [choice_index],
            "selected_obligation_id": obligation_id,
        }
        for choice_index, obligation_id in enumerate(expected_obligation_ids)
    ]
    if demo_collision.get("obligation_outcomes") != expected_obligation_outcomes:
        fail(
            "Week-24 First Bill obligation mapping must partition all eight "
            "authored choices exactly once",
            errors,
        )
    first_bill_event = require_dict(
        registered_events.get("v2_demo_first_bill"),
        "registered event v2_demo_first_bill",
        errors,
    )
    first_bill_choices = require_list(
        first_bill_event.get("choices"),
        "registered event v2_demo_first_bill.choices",
        errors,
    )
    first_bill_description = str(first_bill_event.get("description", ""))
    if (
        "{cash_position}" not in first_bill_description
        or "{money}" in first_bill_description
    ):
        fail(
            "First Bill must distinguish available balance from arrears via "
            "{cash_position}, never describe raw negative money as a bank "
            "balance",
            errors,
        )
    actual_obligation_ids = [
        str(
            require_dict(
                raw_choice,
                f"registered event v2_demo_first_bill.choices[{choice_index}]",
                errors,
            ).get("v2_obligation_id", "")
        )
        for choice_index, raw_choice in enumerate(first_bill_choices)
    ]
    if actual_obligation_ids != expected_obligation_ids:
        fail(
            "First Bill event choices must expose the same eight obligation "
            f"IDs in order, got {actual_obligation_ids}",
            errors,
        )
    expected_initiators = {
        0: "father",
        3: "daeun",
        4: "jaehyuk",
    }
    for choice_index, raw_choice in enumerate(first_bill_choices):
        choice = require_dict(
            raw_choice,
            f"registered event v2_demo_first_bill.choices[{choice_index}]",
            errors,
        )
        if (
            str(choice.get("v2_player_initiated_character", ""))
            != expected_initiators.get(choice_index, "")
        ):
            fail(
                f"First Bill choice {choice_index} has the wrong durable "
                "player-initiative owner",
                errors,
            )
        if choice.get("flags", []):
            fail(
                f"First Bill choice {choice_index} reintroduced write-only flags",
                errors,
            )
    forbidden_first_bill_copy = (
        "오늘 저녁에 할 수 있는 일은 하나뿐",
        "There is time to do only one thing tonight",
        "오후 6시가 지나기 전 끝낼 수 있는 일은 하나뿐",
        "There is time to finish only one thing before six",
        "재혁의 카카오톡에 오늘 안에 답",
        "Answer Jaehyuk's Kakao message",
    )
    serialized_first_bill = json.dumps(
        first_bill_event, ensure_ascii=False
    )
    if any(
        forbidden in serialized_first_bill
        for forbidden in forbidden_first_bill_copy
    ):
        fail(
            "First Bill copy still claims false physical exclusivity or an "
            "inbound Jaehyuk message",
            errors,
        )
    if len(first_bill_choices) == 8:
        urgent_effects = require_dict(
            first_bill_choices[6],
            "registered event v2_demo_first_bill.choices[6]",
            errors,
        ).get("effects")
        if urgent_effects != {
            "money": 280_000,
            "health": -5,
            "mental": -4,
        }:
            fail(
                "First Bill urgent paid shift must keep its exact KRW 280,000 "
                "health/mental receipt",
                errors,
            )

    dirty_tradeoffs = {
        "v2_dirty_trace_initial_call": [
            {"mental": -4},
            {"intelligence": 1, "mental": -5},
        ],
        "v2_dirty_recruiter_week24": [
            {"mental": -2},
            {"intelligence": 1, "mental": -4},
        ],
    }
    for event_id, expected_effects in dirty_tradeoffs.items():
        dirty_event = require_dict(
            registered_events.get(event_id),
            f"registered event {event_id}",
            errors,
        )
        dirty_choices = require_list(
            dirty_event.get("choices"),
            f"registered event {event_id}.choices",
            errors,
        )
        actual_effects = [
            require_dict(
                choice,
                f"{event_id}.choices[{choice_index}]",
                errors,
            ).get("effects", {})
            for choice_index, choice in enumerate(dirty_choices)
        ]
        if actual_effects != expected_effects or any(
            require_dict(
                choice,
                f"{event_id}.choices[{choice_index}]",
                errors,
            ).get("flags", [])
            for choice_index, choice in enumerate(dirty_choices)
        ):
            fail(
                f"{event_id} must keep its non-dominated stat tradeoff "
                "without write-only flags",
                errors,
            )

    gangnam_event = require_dict(
        registered_events.get("v2_gangnam_receipt_walk"),
        "registered event v2_gangnam_receipt_walk",
        errors,
    )
    gangnam_choices = require_list(
        gangnam_event.get("choices"),
        "registered event v2_gangnam_receipt_walk.choices",
        errors,
    )
    gangnam_effects = [
        require_dict(
            choice,
            f"v2_gangnam_receipt_walk.choices[{choice_index}]",
            errors,
        ).get("effects", {})
        for choice_index, choice in enumerate(gangnam_choices)
    ]
    if gangnam_effects != [
        {"money": -9_000, "mental": 3},
        {},
        {"intelligence": 1, "mental": -1},
    ] or any(
        require_dict(
            choice,
            f"v2_gangnam_receipt_walk.choices[{choice_index}]",
            errors,
        ).get("flags", [])
        for choice_index, choice in enumerate(gangnam_choices)
    ):
        fail(
            "Gangnam's KRW 9,000 choice must trade recovery for cash while "
            "the other choices remain distinct and flag-free",
            errors,
        )

    hyunsu_morning = require_dict(
        registered_events.get("v2_hyunsu_exam_morning_echo"),
        "registered event v2_hyunsu_exam_morning_echo",
        errors,
    )
    hyunsu_morning_choices = require_list(
        hyunsu_morning.get("choices"),
        "registered event v2_hyunsu_exam_morning_echo.choices",
        errors,
    )
    if (
        len(hyunsu_morning_choices) != 1
        or "hyunsu_exam_day_seen"
        not in require_dict(
            hyunsu_morning_choices[0] if hyunsu_morning_choices else {},
            "registered event v2_hyunsu_exam_morning_echo.choices[0]",
            errors,
        ).get("flags", [])
    ):
        fail(
            "Hyunsu's Week-24 Saturday echo must leave exactly one "
            "hyunsu_exam_day_seen receipt",
            errors,
        )
    if any(
        event_id in registered_events
        for event_id in (
            "v2_hyunsu_exam_result",
            "v2_hyunsu_exam_pass",
            "v2_hyunsu_exam_failure",
        )
    ):
        fail("the 24-week demo must not reveal Hyunsu's exam result", errors)
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
    temptation_reject = require_dict(
        temptation_choices[0] if temptation_choices else {},
        "arc_temptation_01 reject choice",
        errors,
    )
    temptation_accept = require_dict(
        temptation_choices[1] if len(temptation_choices) > 1 else {},
        "arc_temptation_01 accept choice",
        errors,
    )
    if "월세만 따지면 석 달" not in str(temptation_event.get("description", "")):
        fail(
            "The KRW 2,000,000 temptation must equal just over three "
            "KRW 650,000 rents",
            errors,
        )
    if (
        len(temptation_choices) != 2
        or temptation_reject.get("text")
        != "번호를 차단하고 휴대폰을 엎어놨다"
        or temptation_reject.get("effects") != {"mental": -8, "tint": 5}
        or set(temptation_reject.get("flags", []))
        != {"arc_temptation_seen", "kept_clean_hands"}
        or temptation_reject.get("route") != "orthodox"
        or not str(temptation_reject.get("result_text", "")).startswith(
            "{name}은 번호를 차단하고 휴대폰을 엎어놨다."
        )
        or temptation_accept.get("text")
        != "통장·체크카드와 비밀번호를 넘기고 현금 200만원을 받는다"
        or temptation_accept.get("effects")
        != {"money": 2_000_000, "mental": -16, "tint": -10}
        or set(temptation_accept.get("flags", []))
        != {
            "arc_temptation_seen",
            "lent_account",
            "crossed_line_early",
            "gambling_tempted",
        }
        or temptation_accept.get("route") != "unorthodox"
    ):
        fail(
            "Week-4 temptation choice order, observable KR actions, effects, "
            "flags, and routes must remain exact",
            errors,
        )
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
    year_close_obligation_readers = require_dict(
        year_close_event.get("description_memory_if_known"),
        "arc_year1_close.description_memory_if_known",
        errors,
    )
    for obligation_id in expected_obligation_ids:
        for disposition in ("selected", "deferred"):
            condition_key = (
                "obligation_receipt:demo_collision:"
                f"{disposition}:{obligation_id}"
            )
            if not str(year_close_obligation_readers.get(condition_key, "")).strip():
                fail(
                    "Year-one close must visibly read Week-24 obligation "
                    f"{obligation_id!r} when {disposition}",
                    errors,
                )
    city_year_result_key = (
        "obligation_receipt:demo_collision:selected:"
        "city_work_sample&v2_city_service_result_seen"
    )
    if not str(
        year_close_obligation_readers.get(city_year_result_key, "")
    ).strip():
        fail(
            "Year-one close must replace the Week-24 City submission "
            "with its actual Week-28 result once that message was read",
            errors,
        )
    try:
        demo_core_source = (
            ROOT / "systems/DemoCoreLoopV2.gd"
        ).read_text(encoding="utf-8")
        story_mode_source = (
            ROOT / "scenes/StoryMode.gd"
        ).read_text(encoding="utf-8")
    except OSError as exc:
        fail(f"cannot load obligation receipt reader sources: {exc}", errors)
        demo_core_source, story_mode_source = "", ""
    if "static func obligation_receipt_matches(" not in demo_core_source:
        fail(
            "DemoCoreLoopV2 must expose a public selected/deferred "
            "obligation receipt lookup",
            errors,
        )
    if (
        'condition.begins_with("obligation_receipt:")'
        not in story_mode_source
        or "_obligation_condition_disposition" not in story_mode_source
    ):
        fail(
            "StoryMode must resolve obligation receipt conditions and render "
            "both the selected and deferred Week-24 memories",
            errors,
        )
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
    english_temptation_choices = require_list(
        english_temptation.get("choices"),
        "English arc_temptation_01.choices",
        errors,
    )
    english_temptation_reject = require_dict(
        english_temptation_choices[0] if english_temptation_choices else {},
        "English arc_temptation_01 reject choice",
        errors,
    )
    if (
        len(english_temptation_choices) != len(temptation_choices)
        or english_temptation_reject.get("text")
        != "Block the number and put the phone face down"
        or not str(english_temptation_reject.get("result_text", "")).startswith(
            "{name} blocked the number and flipped the phone face-down."
        )
    ):
        fail(
            "English Week-4 temptation refusal must match the observable KR "
            "action without judging the other choice",
            errors,
        )
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
    english_year_obligation_readers = require_dict(
        english_year.get("description_memory_if_known"),
        "English arc_year1_close.description_memory_if_known",
        errors,
    )
    if set(english_year_obligation_readers) != set(year_close_obligation_readers):
        fail(
            "English year-one close must mirror every Korean Week-24 "
            "obligation reader condition",
            errors,
        )
    for condition_key in year_close_obligation_readers:
        if not str(
            english_year_obligation_readers.get(condition_key, "")
        ).strip():
            fail(
                f"English year-one close has no prose for {condition_key!r}",
                errors,
            )
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
        f"phone_tabs={len(EXPECTED_PHONE_TABS)} "
        f"phone_message_surfaces={len(EXPECTED_PHONE_MESSAGE_SURFACES)} "
        f"phone_contact_methods={len(EXPECTED_PHONE_CONTACT_METHODS)} "
        "phone_runtime_devices=0 "
        f"development_cap={development_cap_week} "
        f"development_months={development_month_count} "
        f"development_deadlines={len(development_player_ids)} "
        f"decline_consumers={len(selectable_decline_ids)} "
        f"routines={len(routine_options)} "
        f"relationship_choice_maps={len(development_relationship_ids)} "
        f"application_transitions={len(EXPECTED_APPLICATION_OUTCOMES)} "
        f"future_applications={len(EXPECTED_FUTURE_APPLICATION_CONTRACTS)} "
        f"future_stories={len(EXPECTED_FUTURE_STORY_CONTRACTS)} "
        f"post_demo_applications={len(EXPECTED_POST_DEMO_APPLICATION_CONTRACTS)} "
        f"deferred_callbacks={len(EXPECTED_DEFERRED_CALLBACK_CONTRACTS)} "
        f"authored_density={density_summary['authored_vector']} "
        f"practical_density={density_summary['practical_vector']} "
        f"authored_total={density_summary['total_authored']} "
        f"legal_plan_time_ranges={density_summary['time_ranges']} "
        f"optional_overhead={density_summary['optional_overhead']} "
        f"v2_direction_events={v2_direction_events} "
        f"prologue_direction_events={prologue_direction_events} "
        f"visible_ap={str(surface['visible_ap']).lower()}"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
