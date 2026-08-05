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
CORE_V2_EVENTS_PATH = ROOT / "content" / "events" / "core_loop_v2_events.json"
CORE_V2_EVENTS_EN_PATH = (
    ROOT / "content" / "events_en" / "core_loop_v2_events.json"
)
STORY_RULES_PATH = ROOT / "content" / "meta" / "story_rules.json"
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
    "speech_contract",
    "legacy_callback_retirements",
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
PRACTICAL_EXCLUDED_KINDS = {"pursuit", "encounter", "care"}
AXIS_KINDS = {
    "people": {"pursuit", "encounter", "care"},
    "practical": {"livelihood", "growth", "recovery"},
    "career": {"career"},
}
EXPECTED_AXIS_LEGAL_UNION = [80, 72, 268, 364, 532, 105]
ACTION_STORY_ROOTS = {
    "m1_convenience_trial_shift": "v2_convenience_trial_shift",
    "m3_inventory_shift": "v2_inventory_count_nights",
    "m3_room_ledger": "v2_m3_room_ledger_anchor",
    "m4_certificate_session": "v2_logistics_class_session",
    "m4_housing_welfare_consultation": "v2_m4_housing_consultation_anchor",
    "m5_weekend_move_shift": "v2_moving_crew_days",
    "m5_last_empty_sunday": "v2_empty_sunday",
}
STORY_OWNED_ACTION_ROOTS = {
    "m3_room_ledger": "v2_m3_room_ledger_anchor",
    "m4_housing_welfare_consultation": "v2_m4_housing_consultation_anchor",
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
EXPECTED_OPENING_SEND_FLAGS = {
    "story_job_unlocked",
    "opening_interview_application_sent",
    "opening_preplan_application_sent",
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
EXPECTED_LEGACY_CALLBACK_RETIREMENTS = {
    "callback_mindset_saver_echo",
    "callback_mindset_investor_echo",
    "callback_mindset_founder_echo",
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
        0: ("unmet", "opening", "player", "father_wellbeing_returned"),
        1: ("unmet", "opening", "player", "father_future_reassured"),
        2: ("unmet", "opening", "player", "father_call_ended_quickly"),
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


def validate_demo_speech_contract(
    contract: dict[str, Any], errors: list[str]
) -> dict[str, int]:
    """Keep every new V2 event either speech-owned or explicitly exempt."""
    summary = {
        "required": 0,
        "exempt": 0,
        "unclassified": 0,
        "legacy_backfill_required": 0,
    }
    raw_contract = contract.get("speech_contract")
    if not isinstance(raw_contract, dict):
        fail("speech_contract must be an object", errors)
        return summary
    if set(raw_contract) != {"required_events", "exempt_events"}:
        fail(
            "speech_contract must contain only required_events and exempt_events",
            errors,
        )
    required_rows = raw_contract.get("required_events")
    exempt_rows = raw_contract.get("exempt_events")
    if not isinstance(required_rows, list) or any(
        not isinstance(value, str) or not value.strip() for value in required_rows
    ):
        fail("speech_contract.required_events must be non-empty event ids", errors)
        required_rows = []
    if not isinstance(exempt_rows, dict):
        fail("speech_contract.exempt_events must be an object", errors)
        exempt_rows = {}
    required = {str(value) for value in required_rows}
    exempt = {str(value) for value in exempt_rows}
    summary["required"] = len(required)
    summary["exempt"] = len(exempt)
    if len(required_rows) != len(required):
        fail("speech_contract.required_events contains duplicates", errors)
    overlap = required & exempt
    if overlap:
        fail(f"speech contract required/exempt overlap {sorted(overlap)}", errors)
    for event_id, reason in exempt_rows.items():
        if not str(event_id).strip() or not str(reason).strip():
            fail(f"speech exemption {event_id!r} needs a written reason", errors)

    try:
        korean_rows = json.loads(CORE_V2_EVENTS_PATH.read_text(encoding="utf-8"))
        english_rows = json.loads(
            CORE_V2_EVENTS_EN_PATH.read_text(encoding="utf-8")
        )
        story_ledger = json.loads(STORY_RULES_PATH.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        fail(f"cannot load demo speech contract inputs: {exc}", errors)
        return summary
    if not isinstance(korean_rows, list) or not isinstance(english_rows, list):
        fail("Core V2 Korean/English event files must be arrays", errors)
        return summary
    korean_by_id = {
        str(row.get("id", "")): row
        for row in korean_rows
        if isinstance(row, dict) and str(row.get("id", ""))
    }
    english_by_id = {
        str(row.get("id", "")): row
        for row in english_rows
        if isinstance(row, dict) and str(row.get("id", ""))
    }
    if len(korean_by_id) != len(korean_rows):
        fail("Core V2 Korean events contain a missing or duplicate id", errors)
    if len(english_by_id) != len(english_rows):
        fail("Core V2 English events contain a missing or duplicate id", errors)
    if set(korean_by_id) != set(english_by_id):
        fail("Core V2 Korean/English event ids differ", errors)
    core_ids = set(korean_by_id)
    unclassified = core_ids - required - exempt
    summary["unclassified"] = len(unclassified)
    if unclassified:
        fail(f"Core V2 speech events are unclassified {sorted(unclassified)}", errors)
    extra = (required | exempt) - core_ids
    if extra:
        fail(f"speech contract references non-Core-V2 events {sorted(extra)}", errors)
    if len(required) != 29 or len(exempt) != 9 or len(core_ids) != 38:
        fail(
            "Core V2 speech partition must remain 29 required + 9 exempt = 38; "
            f"got {len(required)} + {len(exempt)} = {len(core_ids)}",
            errors,
        )

    ledger_rules = story_ledger.get("events", {}) \
        if isinstance(story_ledger, dict) else {}
    if not isinstance(ledger_rules, dict):
        fail("story_rules.events must be an object", errors)
        ledger_rules = {}
    if int(story_ledger.get("schema_version", 0)) != 3:
        fail("story_rules schema must be 3 for speech ownership", errors)
    missing_speech = sorted(
        event_id
        for event_id in required
        if not isinstance(ledger_rules.get(event_id), dict)
        or not isinstance(ledger_rules[event_id].get("speech"), dict)
    )
    if missing_speech:
        fail(f"required V2 events lack speech contracts {missing_speech}", errors)

    hyunsu_ko = korean_by_id.get("v2_hyunsu_study_followup", {})
    hyunsu_en = english_by_id.get("v2_hyunsu_study_followup", {})
    hyunsu_ko_choices = hyunsu_ko.get("choices", []) \
        if isinstance(hyunsu_ko, dict) else []
    hyunsu_en_choices = hyunsu_en.get("choices", []) \
        if isinstance(hyunsu_en, dict) else []
    if (
        not isinstance(hyunsu_ko_choices, list)
        or len(hyunsu_ko_choices) < 2
        or any(
            "6월 27일 토요일 오전 9시"
            not in str(choice.get("result_text", ""))
            for choice in hyunsu_ko_choices[:2]
            if isinstance(choice, dict)
        )
        or "다음 달 토요일 오전 9시" in json.dumps(hyunsu_ko, ensure_ascii=False)
        or "24주차 토요일 오전 9시" in json.dumps(hyunsu_ko, ensure_ascii=False)
    ):
        fail("Hyunsu study follow-up must name the canonical Week-24 exam", errors)
    if (
        not isinstance(hyunsu_en_choices, list)
        or len(hyunsu_en_choices) < 2
        or any(
            "at 9 a.m. on Saturday, June 27"
            not in str(choice.get("result_text", ""))
            for choice in hyunsu_en_choices[:2]
            if isinstance(choice, dict)
        )
        or "on a Saturday next month" in json.dumps(hyunsu_en)
        or "Saturday of Week 24" in json.dumps(hyunsu_en)
    ):
        fail("English Hyunsu follow-up must name the canonical Week-24 exam", errors)

    city_ko = korean_by_id.get("v2_city_service_work_sample_message", {})
    city_en = english_by_id.get("v2_city_service_work_sample_message", {})
    city_ko_text = json.dumps(city_ko, ensure_ascii=False)
    city_en_text = json.dumps(city_en, ensure_ascii=False)
    if (
        city_ko_text.count("6월 26일 금요일 18:00") != 2
        or "24주차 금요일 오후 6시" in city_ko_text
    ):
        fail("City work-sample copy must expose the June 26 calendar deadline", errors)
    if (
        city_en_text.count("6:00 p.m. on Friday, June 26") != 2
        or "Friday of Week 24" in city_en_text
    ):
        fail("English City work-sample copy must expose the June 26 deadline", errors)
    scene_bundles = contract.get("scene_bundles", {})
    city_bundle = scene_bundles.get("m6_city_service_response", {}) \
        if isinstance(scene_bundles, dict) else {}
    if (
        not isinstance(city_bundle, dict)
        or city_bundle.get("message_body_ko")
        != "지원서 검토를 위해 6월 26일 금요일 오후 6시까지 시설 점검 작업표 견본을 제출해 주세요."
        or city_bundle.get("message_body_en")
        != "For application review, please submit a sample facilities-inspection worksheet by 6:00 p.m. on Friday, June 26."
    ):
        fail("City phone surface must match the authored June 26 deadline", errors)

    sangchul_ko = str(
        korean_by_id.get("v2_sangchul_housing_lead", {}).get("description", "")
    )
    sangchul_en = str(
        english_by_id.get("v2_sangchul_housing_lead", {}).get("description", "")
    )
    if "4월 초" not in sangchul_ko or "4월 첫째 주" in sangchul_ko:
        fail("Sangchul housing lead must use the Week-13/14-safe 'early April'", errors)
    if "Early April" not in sangchul_en or "first week of April" in sangchul_en:
        fail("English Sangchul lead must use 'Early April'", errors)
    if "-ssi" in json.dumps(english_rows, ensure_ascii=False):
        fail("Core V2 English prose must not expose Korean '-ssi' translationese", errors)
    if re.search(r"\d+주차", json.dumps(korean_rows, ensure_ascii=False)):
        fail("Core V2 story prose must use calendar language, not numeric game weeks", errors)
    if re.search(r"\bWeek \d+\b", json.dumps(english_rows, ensure_ascii=False)):
        fail("English Core V2 prose must use calendar language, not game-week labels", errors)
    return summary


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


def validate_opening_motivation_contract(
    contract: dict[str, Any],
    registered_events: dict[str, dict[str, Any]],
    errors: list[str],
) -> None:
    """Lock the pre-plan opening and retire declaration-only V2 identities."""
    retirements = require_dict(
        contract.get("legacy_callback_retirements"),
        "legacy_callback_retirements",
        errors,
    )
    if set(retirements) != EXPECTED_LEGACY_CALLBACK_RETIREMENTS:
        fail(
            "legacy mindset callback retirements must be exactly "
            f"{sorted(EXPECTED_LEGACY_CALLBACK_RETIREMENTS)}",
            errors,
        )
    for callback_id in EXPECTED_LEGACY_CALLBACK_RETIREMENTS:
        row = require_dict(
            retirements.get(callback_id),
            f"legacy_callback_retirements.{callback_id}",
            errors,
        )
        if (
            row.get("policy") != "superseded"
            or row.get("scope") != "core_loop_v2"
            or row.get("preserve_legacy") is not True
            or not str(row.get("reason_ko", "")).strip()
            or not str(row.get("reason_en", "")).strip()
        ):
            fail(
                f"{callback_id} must be a written V2-only retirement that "
                "preserves legacy state",
                errors,
            )

    bundles = require_dict(contract.get("scene_bundles"), "scene_bundles", errors)
    opening = require_dict(
        bundles.get("opening_interview_math"),
        "scene_bundles.opening_interview_math",
        errors,
    )
    expected_trigger = {
        "event_id": "v2_opening_application_send",
        "choices": [0],
        "application_id": "mirae_industrial_tech",
        "status": "submitted",
    }
    expected_prerequisites = {
        "all": [{
            "kind": "application_status",
            "application_id": "mirae_industrial_tech",
            "status": "submitted",
        }]
    }
    if (
        opening.get("allowed_weeks") != [1, 2, 3, 4]
        or opening.get("existing_roots")
        != ["arc_intro_01_meal", "v2_opening_return_math"]
        or opening.get("suppress_follow_up_events")
        != ["arc_intro_02_dad_call"]
        or opening.get("preplan_trigger") != expected_trigger
        or opening.get("prerequisites") != expected_prerequisites
    ):
        fail(
            "opening_interview_math must own interview + 125-year return, "
            "trigger from the sent application, and suppress only the legacy math",
            errors,
        )

    legacy_application = require_dict(
        bundles.get("m1_mirae_application"),
        "scene_bundles.m1_mirae_application",
        errors,
    )
    expected_application_guard = {
        "all": [{
            "kind": "application_status_not_in",
            "application_id": "mirae_industrial_tech",
            "statuses": ["submitted", "interviewed", "no_offer", "resolved"],
        }]
    }
    if legacy_application.get("prerequisites") != expected_application_guard:
        fail("fresh plans must hide the already-sent Mirae application", errors)

    legacy_pressure = require_dict(
        registered_events.get("story_pressure"),
        "registered event story_pressure",
        errors,
    )
    legacy_pressure_choices = require_list(
        legacy_pressure.get("choices"),
        "registered event story_pressure.choices",
        errors,
    )
    legacy_pressure_flags = (
        set(legacy_pressure_choices[0].get("flags", []))
        if len(legacy_pressure_choices) == 1
        and isinstance(legacy_pressure_choices[0], dict)
        and isinstance(legacy_pressure_choices[0].get("flags", []), list)
        else set()
    )
    if (
        len(legacy_pressure_choices) != 1
        or "story_job_unlocked" not in legacy_pressure_flags
        or (EXPECTED_OPENING_SEND_FLAGS - {"story_job_unlocked"}).intersection(
            legacy_pressure_flags
        )
    ):
        fail(
            "legacy story_pressure must only open the job app and must not "
            "fabricate a submitted V2 application",
            errors,
        )

    application_event = require_dict(
        registered_events.get("v2_opening_application_send"),
        "registered event v2_opening_application_send",
        errors,
    )
    application_choices = require_list(
        application_event.get("choices"),
        "registered event v2_opening_application_send.choices",
        errors,
    )
    application_flags = (
        set(application_choices[0].get("flags", []))
        if len(application_choices) == 1
        and isinstance(application_choices[0], dict)
        and isinstance(application_choices[0].get("flags", []), list)
        else set()
    )
    if (
        len(application_choices) != 1
        or not isinstance(application_choices[0], dict)
        or not EXPECTED_OPENING_SEND_FLAGS.issubset(application_flags)
    ):
        fail(
            "v2_opening_application_send must own one actual Send choice and "
            f"produce {sorted(EXPECTED_OPENING_SEND_FLAGS)}",
            errors,
        )

    try:
        english_opening_rows = json.loads(
            CORE_V2_EVENTS_EN_PATH.read_text(encoding="utf-8")
        )
    except (OSError, json.JSONDecodeError) as exc:
        fail(f"cannot load English opening timeline companion: {exc}", errors)
        english_opening_rows = []
    english_opening_events = {
        str(row.get("id", "")): row
        for row in english_opening_rows
        if isinstance(row, dict) and str(row.get("id", ""))
    } if isinstance(english_opening_rows, list) else {}
    english_application = require_dict(
        english_opening_events.get("v2_opening_application_send"),
        "English v2_opening_application_send",
        errors,
    )
    english_application_choices = require_list(
        english_application.get("choices"),
        "English v2_opening_application_send.choices",
        errors,
    )
    application_result = str(application_choices[0].get("result_text", "")) \
        if application_choices and isinstance(application_choices[0], dict) else ""
    english_application_result = str(
        english_application_choices[0].get("result_text", "")
    ) if english_application_choices \
        and isinstance(english_application_choices[0], dict) else ""
    if (
        not str(application_event.get("description", "")).startswith("다음 날 아침")
        or "오전 9:14" not in application_result
        or not str(english_application.get("description", "")).startswith(
            "The next morning"
        )
        or "9:14 a.m." not in english_application_result
    ):
        fail(
            "the fresh application must move from the evening meal to a "
            "next-morning 9:14 Send in both languages",
            errors,
        )

    try:
        story_rules = json.loads(STORY_RULES_PATH.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        fail(f"cannot load opening story-rule contract: {exc}", errors)
        story_rules = {}
    send_rule = require_dict(
        require_dict(story_rules.get("events"), "story_rules.events", errors).get(
            "v2_opening_application_send"
        ),
        "story_rules.events.v2_opening_application_send",
        errors,
    )
    send_logic = require_dict(
        require_dict(send_rule.get("logic"), "opening Send logic", errors).get(
            "core_loop_v2"
        ),
        "opening Send core_loop_v2 logic",
        errors,
    )
    produces_all = send_logic.get("produces_all", [])
    if not isinstance(produces_all, list) \
            or not EXPECTED_OPENING_SEND_FLAGS.issubset(set(produces_all)):
        fail(
            "opening Send story rule must declare every durable application flag",
            errors,
        )
    opening_transition = require_dict(
        require_dict(
            story_rules.get("transition_contracts"),
            "story_rules.transition_contracts",
            errors,
        ).get("story_prologue_meal->v2_opening_application_send"),
        "opening meal-to-Send transition",
        errors,
    )
    if (
        opening_transition.get("mode") != "time_cut"
        or opening_transition.get("arrival_cue_ko") != "다음 날 아침"
        or opening_transition.get("arrival_cue_en") != "The next morning"
    ):
        fail(
            "the evening meal-to-Send transition must own the next-morning cut",
            errors,
        )

    math_event = require_dict(
        registered_events.get("v2_opening_return_math"),
        "registered event v2_opening_return_math",
        errors,
    )
    math_choices = require_list(
        math_event.get("choices"),
        "registered event v2_opening_return_math.choices",
        errors,
    )
    math_text = json.dumps(math_event, ensure_ascii=False)
    if not all(token in math_text for token in ("30억", "200만", "1,500개월", "125년")):
        fail("the opening calculation must show 30억/200만/1,500개월/125년", errors)
    if len(math_choices) != 2:
        fail("the opening calculation must expose exactly two expression choices", errors)
    for index, raw_choice in enumerate(math_choices):
        choice = require_dict(
            raw_choice, f"v2_opening_return_math.choices[{index}]", errors
        )
        if choice.get("choice_kind") != "expression" \
                or STORY_GAMEPLAY_KEYS.intersection(choice):
            fail(
                "v2_opening_return_math choices must be expression-only and state-free",
                errors,
            )


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

    total_authored = sum(authored_vector)
    # These vectors are observations, not authoring quotas. A later pass may
    # merge several foreground roots into one deeper continuous scene without
    # failing merely because a monthly count changed.

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
                if bundle_id in STORY_OWNED_ACTION_ROOTS:
                    # These scenes own a memory choice, not the action's AP,
                    # stats, axis, or relationship outcome. Their exact flags
                    # are producer/reader-audited by the story contracts.
                    duplicated_keys.discard("flags")
                if duplicated_keys:
                    fail(
                        f"{bundle_id} hybrid story {event_id} choice "
                        f"{choice_index} duplicates action gameplay keys "
                        f"{sorted(duplicated_keys)}",
                        errors,
                    )

    story_owned_actions = {
        bundle_id: raw_bundle
        for bundle_id, raw_bundle in bundles.items()
        if isinstance(raw_bundle, dict)
        and str(raw_bundle.get(
            "action_result_presentation", ""
        )).strip() == "story_owned"
    }
    if set(story_owned_actions) != set(STORY_OWNED_ACTION_ROOTS):
        fail(
            "story-owned action-result inventory drifted: "
            f"{sorted(story_owned_actions)}",
            errors,
        )
    for bundle_id, root_id in STORY_OWNED_ACTION_ROOTS.items():
        bundle = story_owned_actions.get(bundle_id, {})
        if (
            not str(bundle.get("action_id", "")).strip()
            or bundle.get("existing_roots") != [root_id]
        ):
            fail(
                f"{bundle_id} story-owned result lost action/root {root_id}",
                errors,
            )
    invalid_result_presentations = {
        bundle_id: str(raw_bundle.get(
            "action_result_presentation", ""
        )).strip()
        for bundle_id, raw_bundle in bundles.items()
        if isinstance(raw_bundle, dict)
        and str(raw_bundle.get(
            "action_result_presentation", ""
        )).strip() not in {"", "story_owned"}
    }
    if invalid_result_presentations:
        fail(
            "unknown action-result presentation values: "
            f"{invalid_result_presentations}",
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


def visible_offer_ids_for_fixture(
    month: dict[str, Any],
    bundles: dict[str, Any],
    fixture: dict[str, Any],
    surface: dict[str, Any],
) -> list[str]:
    """Mirror the runtime's prerequisite filtering and sparse fallback fill."""
    result: list[str] = []
    raw_offers = month.get("offers", [])
    if isinstance(raw_offers, list):
        for raw_bundle_id in raw_offers:
            bundle_id = str(raw_bundle_id).strip()
            bundle = bundles.get(bundle_id)
            if (
                bundle_id
                and isinstance(bundle, dict)
                and bundle_available_in_fixture(bundle, fixture)
            ):
                result.append(bundle_id)

    slot_count = max(1, int(surface.get("foreground_slots_per_month", 4)))
    minimum_offers = max(
        1, int(surface.get("minimum_offers_per_month", slot_count))
    )
    fill_target = max(slot_count, minimum_offers)
    if len(result) < fill_target:
        raw_fallbacks = month.get("fallback_offers", [])
        if isinstance(raw_fallbacks, list):
            for raw_bundle_id in raw_fallbacks:
                bundle_id = str(raw_bundle_id).strip()
                bundle = bundles.get(bundle_id)
                if (
                    not bundle_id
                    or bundle_id in result
                    or not isinstance(bundle, dict)
                    or not bundle_available_in_fixture(bundle, fixture)
                ):
                    continue
                result.append(bundle_id)
                if len(result) >= fill_target:
                    break
    return result


def selection_within_reachable_plan_constraints(
    selected: list[str],
    month: dict[str, Any],
    bundles: dict[str, Any],
    groups: dict[str, Any],
    relationship: dict[str, Any],
    fixture: dict[str, Any],
) -> bool:
    """Mirror plan constraints, including already-active named characters."""
    for raw_group in groups.values():
        if not isinstance(raw_group, dict):
            continue
        members = {str(value) for value in raw_group.get("members", [])}
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
        for character, stage in fixture.get("stages", {}).items()
        if str(character).strip()
        and str(stage).strip() not in {"", "unmet", "closed"}
    }
    named_characters.update(
        str(character).strip()
        for bundle_id in selected
        for character in (
            bundles.get(bundle_id, {}).get("characters", [])
            if isinstance(bundles.get(bundle_id), dict)
            else []
        )
        if str(character).strip()
    )
    return len(named_characters) <= named_cap


def enumerate_reachable_month_schedules(
    month: dict[str, Any],
    visible_offer_ids: list[str],
    bundles: dict[str, Any],
    groups: dict[str, Any],
    relationship: dict[str, Any],
    fixture: dict[str, Any],
) -> list[dict[str, str]]:
    """Exhaustively assign the four weeks for one reachable visible surface."""
    raw_weeks = month.get("weeks", [])
    if (
        not isinstance(raw_weeks, list)
        or len(raw_weeks) != 2
        or any(not isinstance(value, int) for value in raw_weeks)
    ):
        return []
    weeks = list(range(int(raw_weeks[0]), int(raw_weeks[1]) + 1))
    locked_by_week: dict[int, str] = {}
    raw_locks = month.get("locked", [])
    if isinstance(raw_locks, list):
        for raw_lock in raw_locks:
            if isinstance(raw_lock, dict):
                locked_by_week[int(raw_lock.get("week", 0))] = str(
                    raw_lock.get("bundle", "")
                ).strip()

    schedules: list[dict[str, str]] = []

    def assign(
        week_index: int, schedule: dict[str, str], selected: list[str]
    ) -> None:
        if week_index >= len(weeks):
            if selection_within_reachable_plan_constraints(
                selected,
                month,
                bundles,
                groups,
                relationship,
                fixture,
            ):
                schedules.append(dict(schedule))
            return
        week = weeks[week_index]
        candidates = (
            [locked_by_week[week]]
            if week in locked_by_week
            else visible_offer_ids
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
            if selection_within_reachable_plan_constraints(
                selected,
                month,
                bundles,
                groups,
                relationship,
                fixture,
            ):
                assign(week_index + 1, schedule, selected)
            selected.pop()
            schedule.pop(str(week), None)

    assign(0, {}, [])
    return schedules


def axis_schedule_key(schedule: dict[str, str]) -> tuple[tuple[int, str], ...]:
    return tuple(
        sorted((int(week), str(bundle_id)) for week, bundle_id in schedule.items())
    )


def axis_format_schedule(schedule: dict[str, str]) -> str:
    return ";".join(
        f"{week}:{bundle_id}" for week, bundle_id in axis_schedule_key(schedule)
    )


def axis_lower_median(values: list[int]) -> int:
    ordered = sorted(values)
    return ordered[(len(ordered) - 1) // 2]


def axis_range(values: list[int]) -> tuple[int, int, int]:
    return min(values), axis_lower_median(values), max(values)


def axis_format_range(values: list[int]) -> str:
    low, middle, high = axis_range(values)
    return f"{low}/{middle}/{high}"


def axis_future_predicate_atoms(
    months: list[Any], bundles: dict[str, Any]
) -> dict[str, Any]:
    """Return only state atoms that can alter a later selectable offer."""
    selectable_ids = {
        str(bundle_id)
        for raw_month in months
        if isinstance(raw_month, dict)
        for field in ("offers", "fallback_offers")
        for bundle_id in raw_month.get(field, [])
    }
    completed: set[str] = set()
    memory_groups: set[tuple[tuple[str, str], ...]] = set()
    player_initiated: set[str] = set()
    routines: set[str] = set()
    applications: set[str] = set()
    for bundle_id in sorted(selectable_ids):
        raw_bundle = bundles.get(bundle_id)
        if not isinstance(raw_bundle, dict):
            continue
        raw_prerequisites = raw_bundle.get("prerequisites", {})
        if not isinstance(raw_prerequisites, dict):
            continue
        for group in ("all", "any"):
            raw_rows = raw_prerequisites.get(group, [])
            if not isinstance(raw_rows, list):
                continue
            grouped_memories: list[tuple[str, str]] = []
            for raw_row in raw_rows:
                if not isinstance(raw_row, dict):
                    continue
                kind = str(raw_row.get("kind", ""))
                if kind == "completed_bundle":
                    completed.add(str(raw_row.get("bundle_id", "")))
                elif kind == "relationship_memory":
                    memory = (
                        str(raw_row.get("character", "")),
                        str(raw_row.get("memory", "")),
                    )
                    if group == "any":
                        grouped_memories.append(memory)
                    else:
                        memory_groups.add((memory,))
                elif kind == "player_initiated":
                    player_initiated.add(str(raw_row.get("character", "")))
                elif kind == "routine_selected":
                    routines.add(str(raw_row.get("track", "")))
                elif kind in {
                    "application_status",
                    "application_status_not_in",
                }:
                    applications.add(str(raw_row.get("application_id", "")))
            if grouped_memories:
                memory_groups.add(tuple(sorted(grouped_memories)))
    return {
        "completed": completed,
        "memory_groups": tuple(sorted(memory_groups)),
        "player_initiated": player_initiated,
        "routines": routines,
        "applications": applications,
    }


def axis_initial_causal_state() -> dict[str, Any]:
    return {
        "completed": set(),
        "stages": {},
        "memories": set(),
        "player_initiated": set(),
        "routines": set(),
        "applications": {},
    }


def axis_copy_causal_state(state: dict[str, Any]) -> dict[str, Any]:
    return {
        "completed": set(state.get("completed", set())),
        "stages": dict(state.get("stages", {})),
        "memories": set(state.get("memories", set())),
        "player_initiated": set(state.get("player_initiated", set())),
        "routines": set(state.get("routines", set())),
        "applications": dict(state.get("applications", {})),
    }


def axis_causal_state_key(
    state: dict[str, Any], atoms: dict[str, Any]
) -> tuple[Any, ...]:
    """Collapse choice prose only when every later eligibility truth agrees."""
    memories = set(state.get("memories", set()))
    return (
        tuple(
            sorted(
                set(state.get("completed", set())).intersection(
                    atoms["completed"]
                )
            )
        ),
        tuple(
            bool(memories.intersection(memory_group))
            for memory_group in atoms["memory_groups"]
        ),
        tuple(
            sorted(
                (str(character), str(stage))
                for character, stage in state.get("stages", {}).items()
                if str(character) and str(stage) not in {"", "unmet"}
            )
        ),
        tuple(
            sorted(
                set(state.get("player_initiated", set())).intersection(
                    atoms["player_initiated"]
                )
            )
        ),
        tuple(
            sorted(
                set(state.get("routines", set())).intersection(
                    atoms["routines"]
                )
            )
        ),
        tuple(
            sorted(
                (
                    application_id,
                    str(state.get("applications", {}).get(application_id, "")),
                )
                for application_id in atoms["applications"]
            )
        ),
    )


def deduplicate_axis_causal_states(
    states: list[dict[str, Any]], atoms: dict[str, Any]
) -> list[dict[str, Any]]:
    unique: dict[tuple[Any, ...], dict[str, Any]] = {}
    for state in states:
        state_key = axis_causal_state_key(state, atoms)
        if state_key not in unique:
            unique[state_key] = state
    return [unique[state_key] for state_key in sorted(unique)]


def axis_bundle_changes_future_truth(
    bundle_id: str, bundle: dict[str, Any], atoms: dict[str, Any]
) -> bool:
    action_config = bundle.get("action_config", {})
    action_application = (
        str(action_config.get("application_id", "")).strip()
        if isinstance(action_config, dict)
        else ""
    )
    outcome_applications = {
        str(outcome.get("application_id", "")).strip()
        for outcome in bundle.get("application_outcomes", [])
        if isinstance(outcome, dict)
    }
    return bool(
        bundle_id in atoms["completed"]
        or bundle.get("relationship_outcomes", [])
        or action_application in atoms["applications"]
        or outcome_applications.intersection(atoms["applications"])
    )


def expand_axis_bundle_causal_states(
    state: dict[str, Any],
    bundle_id: str,
    bundle: dict[str, Any],
    atoms: dict[str, Any],
    errors: list[str],
    mark_completed: bool = True,
) -> list[dict[str, Any]]:
    """Apply only completion/outcome facts that can alter a later plan."""
    base = axis_copy_causal_state(state)
    if mark_completed and bundle_id in atoms["completed"]:
        base["completed"].add(bundle_id)
    action_config = bundle.get("action_config", {})
    if isinstance(action_config, dict):
        application_id = str(action_config.get("application_id", "")).strip()
        status = str(action_config.get("status", "")).strip()
        if application_id in atoms["applications"] and status:
            base["applications"][application_id] = status

    raw_relationship_outcomes = bundle.get("relationship_outcomes", [])
    relationship_states = [base]
    if isinstance(raw_relationship_outcomes, list) and raw_relationship_outcomes:
        relationship_states = []
        for raw_outcome in raw_relationship_outcomes:
            if not isinstance(raw_outcome, dict):
                continue
            character = str(raw_outcome.get("character", "")).strip()
            from_stage = str(raw_outcome.get("from", "")).strip()
            to_stage = str(raw_outcome.get("to", "")).strip()
            current_stage = str(base["stages"].get(character, "unmet"))
            if current_stage != from_stage and not (
                bool(raw_outcome.get("allow_already_at_target", False))
                and current_stage == to_stage
            ):
                continue
            next_state = axis_copy_causal_state(base)
            memory = str(raw_outcome.get("memory", "")).strip()
            if character and to_stage:
                next_state["stages"][character] = to_stage
            if character and memory:
                next_state["memories"].add((character, memory))
            if character and str(raw_outcome.get("initiative", "")) == "player":
                next_state["player_initiated"].add(character)
            relationship_states.append(next_state)
        if not relationship_states:
            message = (
                f"axis causal transition {bundle_id} has no relationship "
                "outcome for its reachable stage"
            )
            if message not in errors:
                fail(message, errors)
            relationship_states = [base]
        relationship_states = deduplicate_axis_causal_states(
            relationship_states, atoms
        )

    raw_application_outcomes = bundle.get("application_outcomes", [])
    relevant_application_outcomes = [
        outcome
        for outcome in raw_application_outcomes
        if isinstance(outcome, dict)
        and str(outcome.get("application_id", "")) in atoms["applications"]
    ] if isinstance(raw_application_outcomes, list) else []
    if not relevant_application_outcomes:
        return relationship_states

    expanded: list[dict[str, Any]] = []
    for relationship_state in relationship_states:
        transitions: dict[tuple[str, str], dict[str, Any]] = {}
        for outcome in relevant_application_outcomes:
            application_id = str(outcome.get("application_id", "")).strip()
            from_status = str(outcome.get("from", "")).strip()
            to_status = str(outcome.get("to", "")).strip()
            if str(relationship_state["applications"].get(
                application_id, ""
            )) != from_status:
                continue
            next_state = axis_copy_causal_state(relationship_state)
            next_state["applications"][application_id] = to_status
            transitions[(application_id, to_status)] = next_state
        if transitions:
            expanded.extend(transitions[key] for key in sorted(transitions))
        else:
            message = (
                f"axis causal transition {bundle_id} has no application "
                "outcome for its reachable status"
            )
            if message not in errors:
                fail(message, errors)
            expanded.append(relationship_state)
    return deduplicate_axis_causal_states(expanded, atoms)


def apply_axis_causal_sequence(
    state: dict[str, Any],
    bundle_ids: tuple[str, ...],
    bundles: dict[str, Any],
    atoms: dict[str, Any],
    errors: list[str],
) -> list[dict[str, Any]]:
    states = [state]
    for bundle_id in bundle_ids:
        bundle = bundles.get(bundle_id)
        if not isinstance(bundle, dict):
            continue
        expanded: list[dict[str, Any]] = []
        for current_state in states:
            expanded.extend(
                expand_axis_bundle_causal_states(
                    current_state,
                    bundle_id,
                    bundle,
                    atoms,
                    errors,
                )
            )
        states = deduplicate_axis_causal_states(expanded, atoms)
    return states


def extend_axis_routine_histories(
    state: dict[str, Any],
    routine_truths: list[set[str]],
    atoms: dict[str, Any],
) -> list[dict[str, Any]]:
    extended: list[dict[str, Any]] = []
    for routine_truth in routine_truths:
        next_state = axis_copy_causal_state(state)
        next_state["routines"].update(routine_truth)
        extended.append(next_state)
    return deduplicate_axis_causal_states(extended, atoms)


def validate_axis_runtime_prelude_order(errors: list[str]) -> None:
    try:
        source = (ROOT / "scenes" / "MainGame.gd").read_text(encoding="utf-8")
        route_week = source.split(
            "func _core_loop_v2_route_week", 1
        )[1].split("\nfunc ", 1)[0]
    except (OSError, IndexError) as exc:
        fail(f"axis measurement cannot inspect V2 prelude order: {exc}", errors)
        return
    prelude_index = route_week.find("pending_month_prelude")
    plan_index = route_week.find("needs_plan")
    if prelude_index < 0 or plan_index < 0 or prelude_index > plan_index:
        fail(
            "Core Loop V2 must consume the month prelude before opening its plan",
            errors,
        )


def validate_axis_runtime_routine_history(errors: list[str]) -> None:
    try:
        source = (ROOT / "systems" / "DemoCoreLoopV2.gd").read_text(
            encoding="utf-8"
        )
        predicate = source.split(
            "static func _predicate_met", 1
        )[1].split("\nstatic func ", 1)[0]
    except (OSError, IndexError) as exc:
        fail(f"axis measurement cannot inspect routine history: {exc}", errors)
        return
    if (
        '"routine_selected":' not in predicate
        or 'state["plans"].values()' not in predicate
    ):
        fail(
            "routine_selected must read every retained monthly plan, not only "
            "the current month's routine pair",
            errors,
        )


def measure_reachable_axis_surfaces(
    contract: dict[str, Any],
    bundles: dict[str, Any],
    months: list[Any],
    groups: dict[str, Any],
    relationship: dict[str, Any],
    surface: dict[str, Any],
    registered_events: dict[str, dict[str, Any]],
    errors: list[str],
) -> list[str]:
    """Exhaust every plan reachable through future-relevant causal state."""
    causal_states = [axis_initial_causal_state()]
    routine_ids = sorted(
        str(value)
        for value in contract.get("routine", {}).get("options", {})
    )
    if len(routine_ids) < 2:
        fail("axis causal measurement has no legal routine pair", errors)
        return []
    validate_axis_runtime_prelude_order(errors)
    validate_axis_runtime_routine_history(errors)

    raw_primary_ids: list[str] = []
    raw_fallback_ids: list[str] = []
    locked_ids: list[str] = []
    prelude_ids: list[str] = []
    conditional_ids: list[str] = []
    for raw_month in months:
        if not isinstance(raw_month, dict):
            continue
        for field, target in (
            ("offers", raw_primary_ids),
            ("fallback_offers", raw_fallback_ids),
            ("prelude", prelude_ids),
            ("conditional_consequences", conditional_ids),
        ):
            raw_ids = raw_month.get(field, [])
            if isinstance(raw_ids, list):
                target.extend(str(value) for value in raw_ids)
        raw_locks = raw_month.get("locked", [])
        if isinstance(raw_locks, list):
            locked_ids.extend(
                str(raw_lock.get("bundle", ""))
                for raw_lock in raw_locks
                if isinstance(raw_lock, dict)
            )

    def surface_stat(ids: list[str], kinds: set[str] | None = None) -> str:
        selected_ids = [
            bundle_id
            for bundle_id in ids
            if isinstance(bundles.get(bundle_id), dict)
            and (
                kinds is None
                or str(bundles[bundle_id].get("kind", "")) in kinds
            )
        ]
        authored_ids = [
            bundle_id
            for bundle_id in selected_ids
            if bundle_has_registered_authored_surface(
                bundles[bundle_id], registered_events
            )
        ]
        authored_minutes = sum(
            int(bundles[bundle_id].get("estimated_minutes", 0))
            for bundle_id in authored_ids
        )
        total_minutes = sum(
            int(bundles[bundle_id].get("estimated_minutes", 0))
            for bundle_id in selected_ids
        )
        return (
            f"{len(authored_ids)}/{len(selected_ids)}:"
            f"{authored_minutes}/{total_minutes}m"
        )

    lines = [
        "axis_measurement scope=exact_causal_states "
        "plans=exhaustive causal_union=deduplicated_unweighted median=lower "
        "prelude_order=before_plan "
        "surface_tuple=authored/total:authored_minutes/total_minutes "
        "path_tuple=selected_range:authored_range:minute_range",
        "axis_surface "
        + " ".join(
            f"{axis_id}={surface_stat(raw_primary_ids, kinds)}"
            for axis_id, kinds in AXIS_KINDS.items()
        ),
        "axis_context "
        f"fallback={surface_stat(raw_fallback_ids)} "
        f"locked={surface_stat(locked_ids)} "
        f"prelude={surface_stat(prelude_ids)} "
        f"conditional={surface_stat(conditional_ids)}",
    ]

    for month_index, raw_month in enumerate(months, start=1):
        if not isinstance(raw_month, dict):
            fail(f"axis reachability month {month_index} is not an object", errors)
            continue
        current_atoms = axis_future_predicate_atoms(
            months[month_index - 1 :], bundles
        )
        next_atoms = axis_future_predicate_atoms(
            months[month_index:], bundles
        )
        routine_truth_keys = {
            tuple(
                sorted(
                    {routine_ids[left], routine_ids[right]}.intersection(
                        next_atoms["routines"]
                    )
                )
            )
            for left in range(len(routine_ids))
            for right in range(left + 1, len(routine_ids))
        }
        routine_truths = [set(values) for values in sorted(routine_truth_keys)]
        for raw_prelude_id in raw_month.get("prelude", []):
            prelude_id = str(raw_prelude_id).strip()
            prelude = bundles.get(prelude_id)
            if not isinstance(prelude, dict):
                continue
            expanded_preludes: list[dict[str, Any]] = []
            for causal_state in causal_states:
                if bundle_available_in_fixture(prelude, causal_state):
                    expanded_preludes.extend(
                        expand_axis_bundle_causal_states(
                            causal_state,
                            prelude_id,
                            prelude,
                            current_atoms,
                            errors,
                            mark_completed=False,
                        )
                    )
                else:
                    expanded_preludes.append(causal_state)
            causal_states = deduplicate_axis_causal_states(
                expanded_preludes, current_atoms
            )
        opening_causal_state_count = len(causal_states)
        if month_index == 3 and "daeun_world_meet" in raw_month.get(
            "offers", []
        ):
            routine_surfaces: dict[bool, set[bool]] = {
                False: set(),
                True: set(),
            }
            for causal_state in causal_states:
                livelihood_seen = "livelihood" in causal_state.get(
                    "routines", set()
                )
                routine_surfaces[livelihood_seen].add(
                    "daeun_world_meet"
                    in visible_offer_ids_for_fixture(
                        raw_month, bundles, causal_state, surface
                    )
                )
            if routine_surfaces != {False: {False}, True: {True}}:
                fail(
                    "axis causal states must preserve both cumulative "
                    "livelihood histories and expose Daeun only after that "
                    "past routine was selected",
                    errors,
                )
        if "father_health_signal" in raw_month.get("prelude", []) and any(
            str(state.get("stages", {}).get("father", "unmet"))
            in {"", "unmet", "closed"}
            for state in causal_states
        ):
            fail(
                "Father's month-six prelude must activate his thread before "
                "the planner counts named characters",
                errors,
            )

        unique_visible_sets: set[tuple[str, ...]] = set()
        unique_schedules: dict[
            tuple[tuple[int, str], ...], dict[str, str]
        ] = {}
        dead_surfaces: list[
            tuple[tuple[str, ...], tuple[str, ...]]
        ] = []
        schedule_cache: dict[
            tuple[tuple[str, ...], tuple[str, ...]],
            tuple[list[dict[str, str]], list[tuple[str, ...]]],
        ] = {}
        next_states: dict[tuple[Any, ...], dict[str, Any]] = {}
        for causal_state in causal_states:
            visible_ids = visible_offer_ids_for_fixture(
                raw_month, bundles, causal_state, surface
            )
            visible_key = tuple(visible_ids)
            active_named = tuple(
                sorted(
                    str(character)
                    for character, stage in causal_state.get(
                        "stages", {}
                    ).items()
                    if str(stage) not in {"", "unmet", "closed"}
                )
            )
            cache_key = (visible_key, active_named)
            if cache_key not in schedule_cache:
                schedules = enumerate_reachable_month_schedules(
                    raw_month,
                    visible_ids,
                    bundles,
                    groups,
                    relationship,
                    causal_state,
                )
                transition_sequences = sorted(
                    {
                        tuple(
                            bundle_id
                            for _, bundle_id in axis_schedule_key(schedule)
                            if isinstance(bundles.get(bundle_id), dict)
                            and axis_bundle_changes_future_truth(
                                bundle_id, bundles[bundle_id], next_atoms
                            )
                        )
                        for schedule in schedules
                    }
                )
                schedule_cache[cache_key] = (
                    schedules,
                    transition_sequences,
                )
                for schedule in schedules:
                    unique_schedules[axis_schedule_key(schedule)] = schedule
            fixture_schedules, transition_sequences = schedule_cache[cache_key]
            unique_visible_sets.add(visible_key)
            if not fixture_schedules:
                dead_surfaces.append(cache_key)
                continue
            for transition_sequence in transition_sequences:
                transitioned = apply_axis_causal_sequence(
                    causal_state,
                    transition_sequence,
                    bundles,
                    next_atoms,
                    errors,
                )
                for transitioned_state in transitioned:
                    for next_state in extend_axis_routine_histories(
                        transitioned_state, routine_truths, next_atoms
                    ):
                        state_key = axis_causal_state_key(next_state, next_atoms)
                        if state_key not in next_states:
                            next_states[state_key] = next_state

        if dead_surfaces:
            fail(
                f"axis reachability month {month_index} has "
                f"{len(dead_surfaces)} reachable offer surfaces without a "
                f"legal four-week plan; examples={dead_surfaces[:3]}",
                errors,
            )
        causal_states = [
            next_states[state_key] for state_key in sorted(next_states)
        ]
        next_causal_state_count = len(causal_states)
        schedules = [unique_schedules[key] for key in sorted(unique_schedules)]
        if not schedules:
            fail(
                f"axis reachability month {month_index} has no reachable "
                "legal four-week plan",
                errors,
            )
            continue
        expected_legal = EXPECTED_AXIS_LEGAL_UNION[month_index - 1]
        if len(schedules) != expected_legal:
            fail(
                f"axis exact legal union month {month_index} expected "
                f"{expected_legal}, got {len(schedules)}",
                errors,
            )

        locked_declared = [
            str(raw_lock.get("bundle", ""))
            for raw_lock in raw_month.get("locked", [])
            if isinstance(raw_lock, dict)
        ]
        locked = set(locked_declared)
        prelude_declared = [
            str(value) for value in raw_month.get("prelude", [])
        ]
        conditional_declared = [
            str(value)
            for value in raw_month.get("conditional_consequences", [])
        ]

        def authored_context_ids(declared: list[str]) -> list[str]:
            return [
                bundle_id
                for bundle_id in declared
                if isinstance(bundles.get(bundle_id), dict)
                and bundle_has_registered_authored_surface(
                    bundles[bundle_id], registered_events
                )
            ]

        def format_authored_context(declared: list[str]) -> str:
            authored = authored_context_ids(declared)
            return f"{len(authored)}:{','.join(authored) if authored else '-'}"

        def selectable_ids(schedule: dict[str, str]) -> list[str]:
            return [
                bundle_id
                for _, bundle_id in axis_schedule_key(schedule)
                if bundle_id not in locked
            ]

        def authored_count(schedule: dict[str, str]) -> int:
            return sum(
                1
                for bundle_id in selectable_ids(schedule)
                if bundle_has_registered_authored_surface(
                    bundles[bundle_id], registered_events
                )
            )

        ranked = sorted(
            (authored_count(schedule), axis_schedule_key(schedule), schedule)
            for schedule in schedules
        )
        minimum = ranked[0][0]
        maximum = ranked[-1][0]
        median_index = (len(ranked) - 1) // 2
        median = ranked[median_index][0]
        witnesses = {
            "min": next(row[2] for row in ranked if row[0] == minimum),
            "median": ranked[median_index][2],
            "max": next(row[2] for row in ranked if row[0] == maximum),
        }
        for label, expected in (
            ("min", minimum),
            ("median", median),
            ("max", maximum),
        ):
            witness = witnesses[label]
            if (
                axis_schedule_key(witness) not in unique_schedules
                or authored_count(witness) != expected
            ):
                fail(
                    f"axis reachability month {month_index} has an invalid "
                    f"{label} witness {axis_format_schedule(witness)}",
                    errors,
                )

        axis_fields: list[str] = []
        for axis_id, kinds in AXIS_KINDS.items():
            selected_values: list[int] = []
            axis_authored_values: list[int] = []
            minute_values: list[int] = []
            for schedule in schedules:
                ids = [
                    bundle_id
                    for bundle_id in selectable_ids(schedule)
                    if str(bundles[bundle_id].get("kind", "")) in kinds
                ]
                selected_values.append(len(ids))
                axis_authored_values.append(
                    sum(
                        1
                        for bundle_id in ids
                        if bundle_has_registered_authored_surface(
                            bundles[bundle_id], registered_events
                        )
                    )
                )
                minute_values.append(
                    sum(
                        int(bundles[bundle_id].get("estimated_minutes", 0))
                        for bundle_id in ids
                    )
                )
            axis_fields.append(
                f"{axis_id}={axis_format_range(selected_values)}:"
                f"{axis_format_range(axis_authored_values)}:"
                f"{axis_format_range(minute_values)}m"
            )

        lines.append(
            f"axis_path month={month_index} "
            "coverage=exact_causal_states "
            f"causal_states={opening_causal_state_count} "
            f"plan_signatures={len(schedule_cache)} "
            f"next_states={next_causal_state_count} "
            f"visible_sets={len(unique_visible_sets)} "
            f"legal={len(schedules)} "
            f"authored={minimum}/{median}/{maximum} "
            + " ".join(axis_fields)
            + " "
            f"locked_authored={format_authored_context(locked_declared)} "
            f"prelude_authored={format_authored_context(prelude_declared)} "
            "conditional_basis=declared_presence "
            f"conditional_authored={format_authored_context(conditional_declared)} "
            f"witness_min={axis_format_schedule(witnesses['min'])} "
            f"witness_median={axis_format_schedule(witnesses['median'])} "
            f"witness_max={axis_format_schedule(witnesses['max'])}"
        )

    return lines


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
            or accepted.get("replace_current_job") is not True
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
                "job_03 replacement hire with a three-week first paycheck and exact role "
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


def measure_long_tail_readers(
    contract: dict[str, Any],
    registered_events: dict[str, dict[str, Any]],
    demo_core_loop_source: str,
    year_close_variants: dict[str, Any],
    year_close_obligation_readers: dict[str, Any],
    obligation_ids: list[str],
    errors: list[str],
) -> list[str]:
    """Classify V2 receipts by reachable reader, not by registration alone."""

    def compact_ids(values: set[str] | list[str]) -> str:
        ordered = sorted({str(value) for value in values if str(value)})
        return ",".join(ordered) if ordered else "none"

    def relationship_reader_keys(event: dict[str, Any]) -> dict[str, str]:
        raw_variants = event.get("description_memory_if_known", {})
        if not isinstance(raw_variants, dict):
            return {}
        result: dict[str, str] = {}
        for raw_key in raw_variants:
            parts = str(raw_key).split(":", 2)
            if len(parts) == 3 and parts[0] == "relationship_memory":
                result[parts[2]] = parts[1]
        return result

    def payload_has_material_value(value: Any) -> bool:
        if isinstance(value, bool):
            return value
        if isinstance(value, (int, float)):
            return float(value) != 0.0
        if isinstance(value, str):
            return bool(value.strip())
        if isinstance(value, dict):
            return any(payload_has_material_value(item) for item in value.values())
        if isinstance(value, list):
            return any(payload_has_material_value(item) for item in value)
        return False

    def event_has_stateful_outcome(event: dict[str, Any]) -> bool:
        stateful_keys = STORY_GAMEPLAY_KEYS | {
            "cast_effects",
            "clues",
            "deferred_follow_up",
            "follow_up_event",
            "give_items",
            "grant_job",
            "housing_keepsake",
            "opportunity",
            "relationship_outcomes",
            "application_outcomes",
            "tendency",
            "year_scene",
        }
        for key in stateful_keys:
            if key in event and payload_has_material_value(event.get(key)):
                return True
        choices = event.get("choices", [])
        if not isinstance(choices, list):
            return False
        return any(
            isinstance(choice, dict)
            and str(choice.get("choice_kind", "")) != "expression"
            and any(
                key in choice
                and payload_has_material_value(choice.get(key))
                for key in stateful_keys
            )
            for choice in choices
        )

    def payload_exact_causal_memories(
        value: Any, memory_ids: set[str]
    ) -> set[str]:
        prose_keys = {
            "description",
            "description_en",
            "description_memory_if_known",
            "result_text",
            "result_text_en",
            "text",
            "text_en",
            "title",
            "title_en",
        }
        ignored_writer_keys = {
            "application_outcomes",
            "application_transition",
            "cast_effects",
            "effects",
            "flag_updates",
            "flags",
            "future_story_outcome",
            "relationship_change",
            "relationship_changes",
            "relationship_outcomes",
        }

        def typed_tokens(raw_value: Any) -> set[str]:
            if isinstance(raw_value, dict):
                return {
                    memory_id
                    for raw_key, item in raw_value.items()
                    for memory_id in (
                        ({str(item).strip()} & memory_ids)
                        if str(raw_key) in {"memory", "memory_id", "id"}
                        else typed_tokens(item)
                    )
                }
            if isinstance(raw_value, list):
                return {
                    memory_id
                    for item in raw_value
                    for memory_id in typed_tokens(item)
                }
            if isinstance(raw_value, str):
                token = raw_value.strip()
                if token in memory_ids:
                    return {token}
                if token.startswith("relationship_memory:"):
                    memory_id = token.rsplit(":", 1)[-1]
                    return {memory_id} if memory_id in memory_ids else set()
            return set()

        if isinstance(value, dict):
            result: set[str] = set()
            if str(value.get("kind", "")) == "relationship_memory":
                result.update(typed_tokens(value))
            for raw_key, raw_value in value.items():
                key = str(raw_key)
                if key in prose_keys or key in ignored_writer_keys \
                        or key.endswith("_copy"):
                    continue
                if key in {
                    "relationship_memory",
                    "relationship_memories",
                    "required_relationship_memories",
                }:
                    result.update(typed_tokens(raw_value))
                    continue
                if key.startswith("relationship_memory:"):
                    memory_id = key.rsplit(":", 1)[-1]
                    if memory_id in memory_ids:
                        result.add(memory_id)
                result.update(
                    payload_exact_causal_memories(raw_value, memory_ids)
                )
            return result
        if isinstance(value, list):
            return {
                memory_id
                for item in value
                for memory_id in payload_exact_causal_memories(
                    item, memory_ids
                )
            }
        if isinstance(value, str):
            token = value.strip()
            if token.startswith("relationship_memory:"):
                memory_id = token.rsplit(":", 1)[-1]
                return {memory_id} if memory_id in memory_ids else set()
        return set()

    def direct_route_week(event_id: str, source: str) -> int:
        weeks: list[int] = []
        for route in re.finditer(
            rf'return "{re.escape(event_id)}"', source
        ):
            nearby = source[max(0, route.start() - 520):route.start()]
            guards = re.findall(r"if t >= (\d+)\b", nearby)
            if guards:
                weeks.append(int(guards[-1]))
        return min(weeks) if weeks else 0

    def gdscript_function(source: str, function_name: str) -> str:
        match = re.search(
            rf"^(?:static )?func {re.escape(function_name)}\b[\s\S]*?"
            r"(?=^(?:static )?func |\Z)",
            source,
            re.MULTILINE,
        )
        return match.group(0) if match is not None else ""

    def event_routes_to(value: Any, target_id: str) -> bool:
        if isinstance(value, dict):
            for raw_key, raw_value in value.items():
                key = str(raw_key)
                if key in {
                    "deferred_event",
                    "follow_up_event",
                    "next_event",
                    "target_event",
                } and str(raw_value) == target_id:
                    return True
                if isinstance(raw_value, (dict, list)) \
                        and event_routes_to(raw_value, target_id):
                    return True
        elif isinstance(value, list):
            return any(event_routes_to(item, target_id) for item in value)
        return False

    def deferred_follow_up_targets(owner: dict[str, Any]) -> set[str]:
        raw_follow_up = owner.get("deferred_follow_up", "")
        values = raw_follow_up if isinstance(raw_follow_up, list) \
            else [raw_follow_up]
        targets: set[str] = set()
        for value in values:
            if isinstance(value, str) and value.strip():
                targets.add(value.strip())
            elif isinstance(value, dict):
                target_id = str(value.get("id", "")).strip()
                if target_id:
                    targets.add(target_id)
        return targets

    def event_follow_up_targets(event: dict[str, Any]) -> set[str]:
        targets = deferred_follow_up_targets(event)
        event_follow_up = str(event.get("follow_up_event", "")).strip()
        if event_follow_up:
            targets.add(event_follow_up)
        raw_choices = event.get("choices", [])
        if not isinstance(raw_choices, list):
            return targets
        for raw_choice in raw_choices:
            if not isinstance(raw_choice, dict):
                continue
            choice_follow_up = str(
                raw_choice.get("follow_up_event", "")
            ).strip()
            if choice_follow_up:
                targets.add(choice_follow_up)
            targets.update(deferred_follow_up_targets(raw_choice))
        return targets

    try:
        main_game_source = (ROOT / "scenes/MainGame.gd").read_text(
            encoding="utf-8"
        )
        game_state_source = (ROOT / "autoloads/GameState.gd").read_text(
            encoding="utf-8"
        )
        event_director_source = (ROOT / "autoloads/EventManager.gd").read_text(
            encoding="utf-8"
        )
        planner_source = (ROOT / "scenes/CoreLoopPlanner.gd").read_text(
            encoding="utf-8"
        )
        event_director = json.loads(
            (ROOT / "content/meta/event_director.json").read_text(
                encoding="utf-8"
            )
        )
        ending_rows = json.loads(
            (ROOT / "content/endings.json").read_text(encoding="utf-8")
        )
    except (OSError, json.JSONDecodeError) as exc:
        fail(f"cannot load long-tail reader surfaces: {exc}", errors)
        main_game_source = ""
        game_state_source = ""
        event_director_source = ""
        planner_source = ""
        event_director = {}
        ending_rows = []

    bundles = require_dict(contract.get("scene_bundles"), "scene_bundles", errors)
    months = require_list(contract.get("months"), "months", errors)
    scope = require_dict(contract.get("scope"), "scope", errors)
    endings = {
        str(row.get("id", "")): row
        for row in ending_rows
        if isinstance(row, dict) and str(row.get("id", ""))
    }
    content_diet = (
        event_director.get("content_diet", {})
        if isinstance(event_director, dict)
        else {}
    )
    if not isinstance(content_diet, dict):
        content_diet = {}
    foreground_ids = {
        str(value) for value in content_diet.get("foreground_event_ids", [])
    }
    bridge_ids = {
        str(value) for value in content_diet.get("bridge_event_ids", [])
    }
    if (
        'rules.get("foreground_event_ids", [])' not in event_director_source
        or 'rules.get("bridge_event_ids", [])' not in event_director_source
    ):
        fail("EventDirector stopped enforcing its reader allowlists", errors)
    directed_random_function = gdscript_function(
        event_director_source, "is_directed_random_event"
    )
    content_exclusion_function = gdscript_function(
        event_director_source, "_event_passes_content_exclusions"
    )
    bridge_function = gdscript_function(
        event_director_source, "is_narrative_bridge_event"
    )
    follow_up_function = gdscript_function(
        event_director_source, "_event_has_follow_up"
    )
    bridge_runtime_tokens = (
        "if not is_directed_random_event(event)",
        "not _event_passes_content_exclusions(event, rules)",
        'rules.get("bridge_event_ids", [])',
        'rules.get("bridge_single_choice_only", true)',
        "if _event_has_follow_up(event)",
        'rules.get("bridge_requires_stateful_condition", true)',
        'get("result_text", "")',
    )
    if (
        not directed_random_function
        or not content_exclusion_function
        or not follow_up_function
        or any(token not in bridge_function for token in bridge_runtime_tokens)
    ):
        fail(
            "EventDirector bridge eligibility topology changed; "
            "reclassify dormant callbacks",
            errors,
        )

    follow_up_target_ids = {
        target_id
        for event in registered_events.values()
        if isinstance(event, dict)
        for target_id in event_follow_up_targets(event)
    }
    director_scope = (
        event_director.get("scope", {})
        if isinstance(event_director, dict)
        else {}
    )
    if not isinstance(director_scope, dict):
        director_scope = {}

    def is_directed_random(event: dict[str, Any]) -> bool:
        event_id = str(event.get("id", ""))
        if not event_id or event_id not in registered_events:
            return False
        if str(event.get("rarity", "")) == "story" \
                or str(event.get("category", "")) == "story" \
                or float(event.get("weight", 1.0)) <= 0.0:
            return False
        if any(
            event_id.startswith(str(prefix))
            for prefix in director_scope.get("excluded_id_prefixes", [])
        ):
            return False
        return not (
            bool(director_scope.get("exclude_follow_up_targets", True))
            and event_id in follow_up_target_ids
        )

    def passes_content_exclusions(event: dict[str, Any]) -> bool:
        event_id = str(event.get("id", ""))
        return (
            str(event.get("category", ""))
            not in content_diet.get("excluded_categories", [])
            and not any(
                event_id.startswith(str(prefix))
                for prefix in content_diet.get("excluded_id_prefixes", [])
            )
        )

    def is_bridge_event(event: dict[str, Any]) -> bool:
        event_id = str(event.get("id", ""))
        choices = event.get("choices", [])
        conditions = event.get("conditions", {})
        if not is_directed_random(event) or not passes_content_exclusions(event) \
                or event_id not in bridge_ids or not isinstance(choices, list):
            return False
        if bool(content_diet.get("bridge_single_choice_only", True)) \
                and len(choices) != 1:
            return False
        if event_follow_up_targets(event):
            return False
        stateful = isinstance(conditions, dict) and any(
            str(key) not in {"min_turn", "max_turn"} for key in conditions
        )
        if bool(content_diet.get("bridge_requires_stateful_condition", True)) \
                and not stateful:
            return False
        return bool(
            choices
            and isinstance(choices[0], dict)
            and str(choices[0].get("result_text", ""))
        )

    scheduled_bundle_ids: set[str] = set()
    for raw_month in months:
        if not isinstance(raw_month, dict):
            continue
        for field in (
            "prelude",
            "offers",
            "fallback_offers",
            "conditional_consequences",
            "closing",
        ):
            raw_ids = raw_month.get(field, [])
            if isinstance(raw_ids, list):
                scheduled_bundle_ids.update(str(value) for value in raw_ids)
        raw_locks = raw_month.get("locked", [])
        if isinstance(raw_locks, list):
            scheduled_bundle_ids.update(
                str(row.get("bundle", ""))
                for row in raw_locks
                if isinstance(row, dict)
            )
    scheduled_bundle_ids.discard("")

    relationship_producers: dict[str, tuple[str, str]] = {}
    relationship_bundle_ids: set[str] = set()
    for bundle_id, raw_bundle in bundles.items():
        if not isinstance(raw_bundle, dict):
            continue
        raw_outcomes = raw_bundle.get("relationship_outcomes", [])
        if not isinstance(raw_outcomes, list) or not raw_outcomes:
            continue
        relationship_bundle_ids.add(str(bundle_id))
        for raw_outcome in raw_outcomes:
            if not isinstance(raw_outcome, dict):
                fail(f"{bundle_id} has a non-object relationship outcome", errors)
                continue
            memory_id = str(raw_outcome.get("memory", "")).strip()
            character_id = str(raw_outcome.get("character", "")).strip()
            if not memory_id or not character_id:
                fail(f"{bundle_id} has an unnamed relationship memory", errors)
                continue
            if memory_id in relationship_producers:
                fail(
                    f"relationship memory {memory_id} has duplicate producers",
                    errors,
                )
                continue
            relationship_producers[memory_id] = (str(bundle_id), character_id)
    relationship_memory_ids = set(relationship_producers)
    registered_causal_memory_readers = {
        event_id: payload_exact_causal_memories(
            event, relationship_memory_ids
        )
        for event_id, event in registered_events.items()
        if isinstance(event, dict)
    }
    legacy_flag_collision_ids = {
        "daeun_kept_distance",
        "jiyeon_walked_away",
    }
    legacy_flag_collision_events: dict[str, set[str]] = {
        memory_id: set() for memory_id in legacy_flag_collision_ids
    }
    typed_reader_probe_id = sorted(relationship_memory_ids)[0] \
        if relationship_memory_ids else ""
    typed_reader_probe = payload_exact_causal_memories(
        {
            "conditions": {
                "all": [{
                    "kind": "relationship_memory",
                    "memory": typed_reader_probe_id,
                }]
            }
        },
        relationship_memory_ids,
    )
    legacy_flag_probe = payload_exact_causal_memories(
        {"conditions": {"flag": typed_reader_probe_id}},
        relationship_memory_ids,
    )
    for event_id, event in registered_events.items():
        conditions = event.get("conditions", {})
        if not isinstance(conditions, dict):
            continue
        for condition_key in ("flag", "no_flag"):
            raw_value = conditions.get(condition_key, "")
            values = raw_value if isinstance(raw_value, list) else [raw_value]
            for value in values:
                memory_id = str(value).strip()
                if memory_id in legacy_flag_collision_events:
                    legacy_flag_collision_events[memory_id].add(event_id)
    if (
        legacy_flag_collision_ids - relationship_memory_ids
        or typed_reader_probe != {typed_reader_probe_id}
        or bool(legacy_flag_probe)
        or any(
            not event_ids
            or any(
                memory_id
                in registered_causal_memory_readers.get(event_id, set())
                for event_id in event_ids
            )
            for memory_id, event_ids in legacy_flag_collision_events.items()
        )
    ):
        fail(
            "legacy flags collided with typed relationship-memory readers",
            errors,
        )

    demo_event_ids: set[str] = set()
    for bundle_id in scheduled_bundle_ids:
        raw_bundle = bundles.get(bundle_id, {})
        if not isinstance(raw_bundle, dict):
            continue
        roots = {
            str(value)
            for value in raw_bundle.get("existing_roots", [])
            if str(value)
        }
        planned_scene_id = str(raw_bundle.get("planned_scene_id", "")).strip()
        if planned_scene_id:
            roots.add(planned_scene_id)
        demo_event_ids.update(reachable_event_ids(roots, registered_events))

    demo_prerequisite_readers: set[str] = set()
    for bundle_id in scheduled_bundle_ids:
        raw_bundle = bundles.get(bundle_id, {})
        if not isinstance(raw_bundle, dict):
            continue
        raw_prerequisites = raw_bundle.get("prerequisites", {})
        if not isinstance(raw_prerequisites, dict):
            continue
        for group in ("all", "any"):
            raw_rows = raw_prerequisites.get(group, [])
            if not isinstance(raw_rows, list):
                continue
            for raw_row in raw_rows:
                if not isinstance(raw_row, dict) \
                        or raw_row.get("kind") != "relationship_memory":
                    continue
                memory_id = str(raw_row.get("memory", "")).strip()
                character_id = str(raw_row.get("character", "")).strip()
                producer = relationship_producers.get(memory_id)
                if producer is None or producer[1] != character_id:
                    fail(
                        f"{bundle_id} reads unknown relationship memory "
                        f"{character_id}:{memory_id}",
                        errors,
                    )
                    continue
                demo_prerequisite_readers.add(memory_id)

    person_function = re.search(
        r"static func _demo_person_obligation\([^\n]*\)[\s\S]*?"
        r"(?=\nstatic func )",
        demo_core_loop_source,
    )
    demo_person_readers: set[str] = set()
    if person_function is None:
        fail("First Bill person-obligation reader disappeared", errors)
    else:
        for character_id, memory_id in re.findall(
            r'_has_relationship_memory\(\s*state,\s*"([^"]+)",\s*"([^"]+)"\)',
            person_function.group(0),
        ):
            producer = relationship_producers.get(memory_id)
            if producer is None or producer[1] != character_id:
                fail(
                    "First Bill reads unknown relationship memory "
                    f"{character_id}:{memory_id}",
                    errors,
                )
                continue
            demo_person_readers.add(memory_id)

    registered_memory_readers = {
        event_id: relationship_reader_keys(event)
        for event_id, event in registered_events.items()
        if isinstance(event, dict) and relationship_reader_keys(event)
    }
    demo_prose_readers: set[str] = set()
    for event_id in demo_event_ids:
        demo_prose_readers.update(
            set(registered_memory_readers.get(event_id, {}))
            & relationship_memory_ids
        )

    planner_expected_new = {
        "hyunsu": {
            "hyunsu_same_hour_confirmed",
            "hyunsu_one_problem_each_agreed",
        },
        "daeun": {
            "daeun_third_greeting_started",
            "daeun_shift_question_asked",
        },
        "jiyeon": {
            "jiyeon_neighborhood_coffee_accepted",
            "jiyeon_talk_without_debt_requested",
            "jiyeon_coffee_fully_refused",
        },
    }
    planner_rebuild = gdscript_function(
        planner_source, "_rebuild_read_only_surface"
    )
    planner_people = gdscript_function(planner_source, "_build_people_surface")
    planner_memory_helper = gdscript_function(
        planner_source, "_has_relationship_memory"
    )
    planner_relationship_copy = gdscript_function(
        planner_source, "_relationship_copy"
    )
    if not re.search(
        r"match _active_tab:[\s\S]*?\n\t\t2:\s*\n\t\t\t_build_people_surface\(\)",
        planner_rebuild,
    ):
        fail("planner People tab no longer opens its read-only surface", errors)
    if (
        '"지금까지 만난 사람", "PEOPLE MET SO FAR"' not in planner_people
        or "_relationship_copy(character_id)" not in planner_people
        or "_character_name(character_id)" not in planner_people
    ):
        fail("planner People surface lost its visible relationship copy", errors)
    if (
        "CORE_LOOP.has_relationship_memory(character_id, memory_id)"
        not in planner_memory_helper
    ):
        fail("planner relationship copy stopped reading V2 memory state", errors)

    planner_reader_map: dict[str, set[str]] = {}
    for character_id in sorted(
        {character for _, character in relationship_producers.values()}
    ):
        character_block = re.search(
            rf'\n\tif character_id == "{re.escape(character_id)}":'
            r"([\s\S]*?)(?=\n\tif character_id == |\n\tvar stage :=|\Z)",
            planner_relationship_copy,
        )
        if character_block is None:
            continue
        mapped_memories: set[str] = set()
        for raw_list in re.findall(
            r"_has_relationship_memory\(character_id,\s*\[([\s\S]*?)\]\)",
            character_block.group(1),
        ):
            mapped_memories.update(re.findall(r'"([^"]+)"', raw_list))
        for memory_id in mapped_memories & relationship_memory_ids:
            if relationship_producers[memory_id][1] != character_id:
                fail(
                    "planner relationship reader maps "
                    f"{memory_id} to the wrong character {character_id}",
                    errors,
                )
        planner_reader_map[character_id] = mapped_memories
    for character_id, expected_memories in planner_expected_new.items():
        missing = expected_memories - planner_reader_map.get(character_id, set())
        if missing:
            fail(
                "planner People surface lost exact "
                f"{character_id} memory readers {sorted(missing)}",
                errors,
            )
    demo_planner_readers = {
        memory_id
        for character_id, memory_ids in planner_reader_map.items()
        for memory_id in memory_ids
        if memory_id in relationship_memory_ids
        and relationship_producers[memory_id][1] == character_id
    }

    future_story_contracts = contract.get("future_story_contracts", {})
    if not isinstance(future_story_contracts, dict):
        future_story_contracts = {}
    future_demo_readers: set[str] = set()
    y1_readers: set[str] = set()
    y2_y5_readers: set[str] = set()
    y1_registered_reader_events: dict[str, set[str]] = {}
    y2_y5_registered_reader_events: dict[str, set[str]] = {}

    def index_post_demo_reader_events(
        target: dict[str, set[str]],
        event_id: str,
        memory_ids: set[str],
    ) -> None:
        if event_id not in registered_events:
            return
        for memory_id in memory_ids:
            target.setdefault(memory_id, set()).add(event_id)

    for contract_id, raw_contract in future_story_contracts.items():
        if not isinstance(raw_contract, dict):
            continue
        required_memories = {
            str(value) for value in raw_contract.get("required_memories", [])
        } & relationship_memory_ids
        exam_week = int(raw_contract.get("exam_week", 0))
        if exam_week <= int(scope.get("max_week", 24)):
            raw_demo_collision = bundles.get("demo_collision", {})
            raw_finale = (
                raw_demo_collision.get("first_bill_finale", {})
                if isinstance(raw_demo_collision, dict)
                else {}
            )
            raw_memory_copy = (
                raw_finale.get("hyunsu_memory_copy", {})
                if isinstance(raw_finale, dict)
                else {}
            )
            if (
                'for memory_id in spec["required_memories"]'
                not in demo_core_loop_source
                or "_first_bill_hyunsu_memory_copy" not in demo_core_loop_source
                or not isinstance(raw_memory_copy, dict)
                or not required_memories.issubset(set(raw_memory_copy))
            ):
                fail(
                    f"future story {contract_id} lost its exact demo memory reader",
                    errors,
                )
            future_demo_readers.update(required_memories)
        result_week = int(raw_contract.get("result_available_week", 0))
        result_event_id = str(raw_contract.get("result_event", ""))
        result_readers = (
            set(registered_memory_readers.get(result_event_id, {}))
            | registered_causal_memory_readers.get(result_event_id, set())
        ) & relationship_memory_ids
        if 25 <= result_week <= 48:
            y1_readers.update(result_readers)
            index_post_demo_reader_events(
                y1_registered_reader_events,
                result_event_id,
                result_readers,
            )
        elif 49 <= result_week <= 240:
            y2_y5_readers.update(result_readers)
            index_post_demo_reader_events(
                y2_y5_registered_reader_events,
                result_event_id,
                result_readers,
            )

    for event_id in registered_events:
        event_readers = (
            set(registered_memory_readers.get(event_id, {}))
            | registered_causal_memory_readers.get(event_id, set())
        ) & relationship_memory_ids
        if not event_readers or event_id in demo_event_ids:
            continue
        route_week = direct_route_week(event_id, main_game_source)
        if route_week <= 0 and event_id in foreground_ids | bridge_ids:
            raw_conditions = registered_events.get(event_id, {}).get(
                "conditions", {}
            )
            min_turn = (
                int(raw_conditions.get("min_turn", 0))
                if isinstance(raw_conditions, dict)
                else 0
            )
            route_week = max(25, min_turn)
        if 25 <= route_week <= 48:
            y1_readers.update(event_readers)
            index_post_demo_reader_events(
                y1_registered_reader_events, event_id, event_readers
            )
        elif 49 <= route_week <= 240:
            y2_y5_readers.update(event_readers)
            index_post_demo_reader_events(
                y2_y5_registered_reader_events, event_id, event_readers
            )

    ending_prose_readers: set[str] = set()
    ending_prose_reader_payloads: dict[str, set[str]] = {}
    ending_causal_memory_readers: dict[str, set[str]] = {}
    for ending_id, ending in endings.items():
        if isinstance(ending, dict):
            prose_memory_ids = (
                set(relationship_reader_keys(ending))
                & relationship_memory_ids
            )
            ending_prose_readers.update(prose_memory_ids)
            for memory_id in prose_memory_ids:
                ending_prose_reader_payloads.setdefault(memory_id, set()).add(
                    ending_id
                )
            for memory_id in payload_exact_causal_memories(
                ending, relationship_memory_ids
            ):
                ending_causal_memory_readers.setdefault(
                    memory_id, set()
                ).add(ending_id)

    def effectful_exact_memories(
        reader_events: dict[str, set[str]],
    ) -> set[str]:
        return {
            memory_id
            for memory_id, event_ids in reader_events.items()
            if any(
                memory_id
                in registered_causal_memory_readers.get(event_id, set())
                for event_id in event_ids
            )
        }

    y1_effectful_exact = effectful_exact_memories(
        y1_registered_reader_events
    )
    y2_y5_effectful_exact = effectful_exact_memories(
        y2_y5_registered_reader_events
    )
    ending_effectful_exact = set(ending_causal_memory_readers)
    ending_readers = ending_prose_readers | ending_effectful_exact
    y1_prose_only = y1_readers - y1_effectful_exact
    y2_y5_prose_only = y2_y5_readers - y2_y5_effectful_exact
    ending_prose_only = ending_prose_readers - ending_effectful_exact
    y1_host_effectful_event_ids = {
        event_id
        for event_ids in y1_registered_reader_events.values()
        for event_id in event_ids
        if event_has_stateful_outcome(registered_events.get(event_id, {}))
    }
    y1_host_effectful_memories = {
        memory_id
        for memory_id, event_ids in y1_registered_reader_events.items()
        if event_ids & y1_host_effectful_event_ids
    }
    if (
        set(y1_registered_reader_events) != y1_readers
        or set(y2_y5_registered_reader_events) != y2_y5_readers
        or y1_prose_only & y1_effectful_exact
        or y1_prose_only | y1_effectful_exact != y1_readers
        or y2_y5_prose_only & y2_y5_effectful_exact
        or y2_y5_prose_only | y2_y5_effectful_exact != y2_y5_readers
        or set(ending_prose_reader_payloads) != ending_prose_readers
        or ending_prose_only & ending_effectful_exact
        or ending_prose_only | ending_effectful_exact != ending_readers
    ):
        fail("post-demo relationship reader classification is incomplete", errors)

    demo_gate_readers = demo_prerequisite_readers | demo_person_readers
    demo_prose_readers.update(future_demo_readers)
    demo_before_planner = demo_gate_readers | demo_prose_readers
    demo_planner_new_readers = demo_planner_readers - demo_before_planner
    demo_readers = demo_before_planner | demo_planner_readers
    named_relationship_readers = (
        demo_readers | y1_readers | y2_y5_readers | ending_readers
    )
    relationship_readerless = relationship_memory_ids - named_relationship_readers
    relationship_overlap_demo_y1 = demo_readers & y1_readers
    relationship_post_demo_prose = (
        y1_prose_only | y2_y5_prose_only | ending_prose_only
    )
    relationship_post_demo_effectful = (
        y1_effectful_exact | y2_y5_effectful_exact | ending_effectful_exact
    )
    relationship_post_demo_absent = relationship_memory_ids - (
        relationship_post_demo_prose | relationship_post_demo_effectful
    )
    relationship_post_demo_prose_only = (
        relationship_post_demo_prose - relationship_post_demo_effectful
    )
    relationship_demo_only = demo_readers - (
        relationship_post_demo_prose | relationship_post_demo_effectful
    )
    relationship_long_tail_candidates = (
        relationship_post_demo_absent | relationship_post_demo_prose_only
    )
    if (
        relationship_post_demo_absent & relationship_post_demo_prose_only
        or relationship_long_tail_candidates
        != relationship_memory_ids - relationship_post_demo_effectful
        or relationship_readerless - relationship_post_demo_absent
        or relationship_demo_only
        != demo_readers - (
            relationship_post_demo_prose
            | relationship_post_demo_effectful
        )
    ):
        fail(
            "relationship long-tail candidate partition is inconsistent",
            errors,
        )

    action_bundles = {
        str(bundle_id): raw_bundle
        for bundle_id, raw_bundle in bundles.items()
        if isinstance(raw_bundle, dict)
        and str(raw_bundle.get("action_id", "")).strip()
    }
    practical_actions = {
        bundle_id: raw_bundle
        for bundle_id, raw_bundle in action_bundles.items()
        if str(raw_bundle.get("kind", "")) in AXIS_KINDS["practical"]
    }
    career_application_actions = {
        bundle_id: raw_bundle
        for bundle_id, raw_bundle in action_bundles.items()
        if str(raw_bundle.get("kind", "")) == "career"
    }
    static_material_actions: set[str] = set()
    runtime_material_actions: set[str] = set()
    legacy_action_routes = {
        "side_shift": "_core_loop_v2_open_side_shift(bundle_id)",
        "resume": "_ap_write_resume()",
        "interview": "_ap_interview_prep()",
        "rest": "_core_loop_v2_take_recovery(scene_bundle)",
    }
    for bundle_id, raw_bundle in practical_actions.items():
        raw_config = raw_bundle.get("action_config", {})
        config = raw_config if isinstance(raw_config, dict) else {}
        execution = str(config.get("execution", "")).strip()
        raw_effects = config.get("effects", {})
        effects = raw_effects if isinstance(raw_effects, dict) else {}
        has_nonzero_effect = any(
            isinstance(value, (int, float))
            and not isinstance(value, bool)
            and float(value) != 0.0
            for value in effects.values()
        )
        if execution in {"instant_effect", "rest"} and has_nonzero_effect:
            static_material_actions.add(bundle_id)
            continue
        action_id = str(raw_bundle.get("action_id", "")).strip()
        route_token = legacy_action_routes.get(action_id, "")
        if not execution and route_token and route_token in main_game_source:
            runtime_material_actions.add(bundle_id)
            continue
        fail(
            f"practical action receipt {bundle_id} has no material execution route",
            errors,
        )

    practical_story_bundles = {
        bundle_id
        for bundle_id, raw_bundle in practical_actions.items()
        if isinstance(raw_bundle.get("existing_roots"), list)
        and bool(raw_bundle.get("existing_roots"))
    }
    if practical_story_bundles != set(ACTION_STORY_ROOTS):
        fail(
            "practical action-story receipt inventory drifted: "
            f"{sorted(practical_story_bundles)}",
            errors,
        )
    practical_completed_bundle_readers: dict[str, set[str]] = {}
    for target_id in sorted(scheduled_bundle_ids):
        target_bundle = bundles.get(target_id, {})
        if not isinstance(target_bundle, dict) \
                or not bundle_has_registered_authored_surface(
                    target_bundle, registered_events
                ):
            continue
        raw_prerequisites = target_bundle.get("prerequisites", {})
        if not isinstance(raw_prerequisites, dict):
            continue
        for group in ("all", "any"):
            raw_rows = raw_prerequisites.get(group, [])
            if not isinstance(raw_rows, list):
                continue
            for raw_row in raw_rows:
                if not isinstance(raw_row, dict) \
                        or raw_row.get("kind") != "completed_bundle":
                    continue
                producer_id = str(raw_row.get("bundle_id", "")).strip()
                if producer_id in practical_actions:
                    practical_completed_bundle_readers.setdefault(
                        producer_id, set()
                    ).add(target_id)
    expected_practical_completed_readers = {
        "m2_rain_delivery_shift": {"jiyeon_world_meet"},
    }
    if practical_completed_bundle_readers \
            != expected_practical_completed_readers:
        fail(
            "practical completed-bundle story readers drifted: "
            f"{practical_completed_bundle_readers}",
            errors,
        )
    practical_causal_story_bundles = (
        practical_story_bundles | set(practical_completed_bundle_readers)
    )
    authored_story_receipt_ids: set[str] = set()
    for bundle_id in sorted(practical_story_bundles):
        root_id = ACTION_STORY_ROOTS[bundle_id]
        for event_id in reachable_event_ids({root_id}, registered_events):
            choices = registered_events.get(event_id, {}).get("choices", [])
            if not isinstance(choices, list):
                continue
            for choice_index, raw_choice in enumerate(choices):
                if not isinstance(raw_choice, dict):
                    continue
                if str(raw_choice.get("choice_kind", "")) == "expression":
                    fail(
                        f"{bundle_id} action-story completion choice became expression-only",
                        errors,
                    )
                    continue
                authored_story_receipt_ids.add(
                    f"{bundle_id}:{event_id}[{choice_index}]"
                )
    if "_has_current_bundle_story_receipt" not in demo_core_loop_source:
        fail("action-story completion receipt reader disappeared", errors)

    effectless_application_actions: set[str] = set()
    material_career_actions: set[str] = set()
    career_direct_receipt_story: set[str] = set()
    for bundle_id, raw_bundle in career_application_actions.items():
        raw_config = raw_bundle.get("action_config", {})
        config = raw_config if isinstance(raw_config, dict) else {}
        execution = str(config.get("execution", "")).strip()
        action_id = str(raw_bundle.get("action_id", "")).strip()
        raw_effects = config.get("effects", {})
        effects = raw_effects if isinstance(raw_effects, dict) else {}
        if action_id == "apply" and execution in {"", "application"} \
                and not effects:
            effectless_application_actions.add(bundle_id)
        else:
            material_career_actions.add(bundle_id)
        raw_roots = raw_bundle.get("existing_roots", [])
        if isinstance(raw_roots, list) and raw_roots:
            career_direct_receipt_story.add(bundle_id)

    min_week = int(scope.get("min_week", 1))
    max_week = int(scope.get("max_week", 24))
    routine_receipt_count = max(0, max_week - min_week + 1)
    routine = require_dict(contract.get("routine"), "routine", errors)
    routine_units = routine_receipt_count * int(
        routine.get("background_ap_per_week", 0)
    )
    routine_material = (
        "GameState.apply_effects(effects)" in demo_core_loop_source
        and 'state["routine_receipts"][turn_key]' in demo_core_loop_source
    )
    if not routine_material:
        fail("routine receipt lost its immediate material execution", errors)

    first_bill_event = registered_events.get("v2_demo_first_bill", {})
    first_bill_choices = first_bill_event.get("choices", [])
    if not isinstance(first_bill_choices, list):
        first_bill_choices = []
    first_bill_local_material = sum(
        1
        for choice in first_bill_choices
        if isinstance(choice, dict)
        and isinstance(choice.get("effects"), dict)
        and any(
            isinstance(value, (int, float))
            and not isinstance(value, bool)
            and float(value) != 0.0
            for value in choice.get("effects", {}).values()
        )
    )
    first_bill_bundle = bundles.get("demo_collision", {})
    finale = (
        first_bill_bundle.get("first_bill_finale", {})
        if isinstance(first_bill_bundle, dict)
        else {}
    )
    if not isinstance(finale, dict):
        finale = {}
    root_contract = finale.get("root_contract", {})
    ledger_event_id = (
        str(root_contract.get("ledger_event", ""))
        if isinstance(root_contract, dict)
        else ""
    )
    first_bill_demo_readers = set(obligation_ids) if (
        ledger_event_id in registered_events
        and "_first_bill_obligation_receipt" in demo_core_loop_source
    ) else set()
    if len(first_bill_demo_readers) != len(obligation_ids):
        fail("First Bill ledger stopped reading exact obligation receipts", errors)

    recap_ids = {
        obligation_id
        for obligation_id in obligation_ids
        if all(
            str(
                year_close_obligation_readers.get(
                    "obligation_receipt:demo_collision:"
                    f"{disposition}:{obligation_id}",
                    "",
                )
            ).strip()
            for disposition in ("selected", "deferred")
        )
    }
    post_demo_contracts = contract.get("post_demo_application_contracts", {})
    city_contract = (
        post_demo_contracts.get("city_facility_ops_2026h1_result", {})
        if isinstance(post_demo_contracts, dict)
        else {}
    )
    if not isinstance(city_contract, dict):
        city_contract = {}
    city_event = registered_events.get(
        str(city_contract.get("result_event", "")), {}
    )
    city_choices = city_event.get("choices", [])
    city_effectful = (
        city_contract.get("selected_obligation_id") == "city_work_sample"
        and city_contract.get("not_before_week") == 28
        and isinstance(city_choices, list)
        and bool(city_choices)
        and all(
            isinstance(choice, dict)
            and isinstance(choice.get("effects"), dict)
            and bool(choice.get("effects"))
            for choice in city_choices
        )
    )
    if not city_effectful:
        fail(
            "declared Week-28 effectful reader disappeared for city_work_sample",
            errors,
        )
    first_bill_obligation_ids = set(obligation_ids)
    first_bill_effectful_post_demo = (
        {"city_work_sample"} if city_effectful else set()
    )
    first_bill_post_demo_absent = first_bill_obligation_ids - recap_ids
    first_bill_post_demo_recap_only = (
        recap_ids - first_bill_effectful_post_demo
    )
    first_bill_long_tail_candidates = (
        first_bill_post_demo_absent | first_bill_post_demo_recap_only
    )
    if (
        first_bill_effectful_post_demo - first_bill_obligation_ids
        or first_bill_effectful_post_demo - recap_ids
        or first_bill_post_demo_absent & first_bill_post_demo_recap_only
        or first_bill_long_tail_candidates
        != first_bill_obligation_ids - first_bill_effectful_post_demo
    ):
        fail("First Bill long-tail candidate partition is inconsistent", errors)

    career_route_specs = {
        "m1_mirae_application": {
            "application_id": "mirae_industrial_tech",
            "demo": ("opening_interview_math", "m2_mirae_result_message"),
        },
        "m2_seorin_application": {
            "application_id": "seorin_contract_2026q1",
            "demo": ("m3_seorin_result_message",),
        },
        "m3_hanbit_application": {
            "application_id": "hanbit_ops_2026q1",
            "demo": ("m4_hanbit_interview", "m5_hanbit_offer_message"),
        },
        "m4_dodam_application": {
            "application_id": "dodam_customer_ops_2026q2",
            "demo": ("m6_dodam_response",),
        },
        "m5_city_service_application": {
            "application_id": "city_facility_ops_2026h1",
            "demo": ("m6_city_service_response",),
        },
    }
    if set(career_route_specs) != set(career_application_actions):
        fail(
            "career application causal producer inventory drifted: "
            f"{sorted(career_application_actions)}",
            errors,
        )
    opening_application_commit = gdscript_function(
        main_game_source, "_commit_opening_interview_application"
    )
    future_application_contracts = contract.get(
        "future_application_contracts", {}
    )
    if not isinstance(future_application_contracts, dict):
        future_application_contracts = {}
    career_demo_routes: dict[str, tuple[str, ...]] = {}
    career_demo_reader_ids: set[str] = set()
    for producer_id, spec in career_route_specs.items():
        producer_bundle = career_application_actions.get(producer_id, {})
        raw_config = producer_bundle.get("action_config", {})
        config = raw_config if isinstance(raw_config, dict) else {}
        application_id = str(config.get("application_id", "")).strip()
        if producer_id == "m1_mirae_application":
            if '"application_id": "mirae_industrial_tech"' \
                    not in opening_application_commit:
                fail("Mirae application runtime status producer disappeared", errors)
            application_id = "mirae_industrial_tech"
        if application_id != spec["application_id"]:
            fail(
                f"{producer_id} application id drifted to {application_id}",
                errors,
            )
        current_status = str(config.get("status", "submitted"))
        route_ids = tuple(str(value) for value in spec["demo"])
        for route_index, target_id in enumerate(route_ids):
            target_bundle = bundles.get(target_id, {})
            if (
                target_id not in scheduled_bundle_ids
                or not isinstance(target_bundle, dict)
                or not bundle_has_registered_authored_surface(
                    target_bundle, registered_events
                )
            ):
                fail(
                    f"{producer_id} causal story reader {target_id} is not reachable",
                    errors,
                )
                continue
            raw_prerequisites = target_bundle.get("prerequisites", {})
            prerequisite_rows = (
                list(raw_prerequisites.get("all", []))
                + list(raw_prerequisites.get("any", []))
                if isinstance(raw_prerequisites, dict)
                else []
            )
            if not any(
                isinstance(row, dict)
                and row.get("kind") == "application_status"
                and row.get("application_id") == application_id
                and row.get("status") == current_status
                for row in prerequisite_rows
            ):
                fail(
                    f"{target_id} stopped reading {application_id}:{current_status}",
                    errors,
                )
            career_demo_reader_ids.add(target_id)
            transition_rows = target_bundle.get("application_outcomes", [])
            matching_transitions = [
                row
                for row in transition_rows
                if isinstance(row, dict)
                and row.get("application_id") == application_id
                and row.get("from") == current_status
            ] if isinstance(transition_rows, list) else []
            if route_index + 1 < len(route_ids):
                if len(matching_transitions) != 1:
                    fail(
                        f"{target_id} no longer has one causal status transition",
                        errors,
                    )
                else:
                    current_status = str(matching_transitions[0].get("to", ""))
        career_demo_routes[producer_id] = route_ids

    for producer_id, contract_id in {
        "m4_dodam_application": "m6_dodam_response",
        "m5_city_service_application": "m6_city_service_response",
    }.items():
        future_contract = future_application_contracts.get(contract_id, {})
        expected_application_id = career_route_specs[producer_id]["application_id"]
        expected_target = career_demo_routes[producer_id][0]
        target_roots = bundles.get(expected_target, {}).get("existing_roots", [])
        if (
            not isinstance(future_contract, dict)
            or future_contract.get("producer_bundle") != producer_id
            or future_contract.get("application_id") != expected_application_id
            or future_contract.get("result_event") not in target_roots
        ):
            fail(
                f"future application contract {contract_id} lost {producer_id}",
                errors,
            )

    hanbit_competing_bundle = bundles.get("m4_dodam_application", {})
    hanbit_competing_prerequisites = (
        hanbit_competing_bundle.get("prerequisites", {})
        if isinstance(hanbit_competing_bundle, dict)
        else {}
    )
    hanbit_not_in_rows = (
        hanbit_competing_prerequisites.get("all", [])
        if isinstance(hanbit_competing_prerequisites, dict)
        else []
    )
    hanbit_availability_reader = any(
        isinstance(row, dict)
        and row.get("kind") == "application_status_not_in"
        and row.get("application_id") == "hanbit_ops_2026q1"
        and set(str(value) for value in row.get("statuses", []))
        == {"submitted", "interviewed"}
        for row in hanbit_not_in_rows
    )
    if not hanbit_availability_reader:
        fail("Hanbit application lost its competing Dodam availability reader", errors)

    career_y1_routes = {
        "m5_city_service_application": {
            str(city_contract.get("result_event", ""))
        }
    } if city_effectful else {}
    if career_y1_routes != {
        "m5_city_service_application": {"v2_city_service_result_message"}
    }:
        fail("City application lost its conditional Week-28 result reader", errors)

    career_demo_route_labels = {
        f"{producer}>{'>'.join(route)}"
        for producer, route in career_demo_routes.items()
    }

    ending_obligation_readers: set[str] = set()
    for ending in endings.values():
        raw_variants = (
            ending.get("description_memory_if_known", {})
            if isinstance(ending, dict)
            else {}
        )
        if not isinstance(raw_variants, dict):
            continue
        for raw_key in raw_variants:
            parts = str(raw_key).split(":")
            if len(parts) >= 4 and parts[0] == "obligation_receipt" \
                    and parts[1] == "demo_collision":
                obligation_id = parts[3].split("&", 1)[0]
                if obligation_id in obligation_ids:
                    ending_obligation_readers.add(obligation_id)

    trace_copy = finale.get("trace_copy", {})
    if not isinstance(trace_copy, dict):
        trace_copy = {}
    dirty_specs = (
        (
            "escaped_dirty_money",
            "callback_escaped_dirty_trace",
            "v2_dirty_trace_initial_call",
        ),
        (
            "fell_to_darkness",
            "fell_to_darkness",
            "v2_dirty_recruiter_week24",
        ),
    )
    dirty_story_receipt_ids: set[str] = set()
    dirty_deferred_receipt_ids: set[str] = set()
    dirty_local_material = 0
    for flag_id, source_id, root_id in dirty_specs:
        route_pattern = re.compile(
            rf'(?:if|elif) bool\(GameState\.flags\.get\("{flag_id}", false\)\):\s*'
            rf'(?:[\s\S]{{0,220}}?)dirty_source = "{source_id}"\s*'
            rf'dirty_root = "{root_id}"'
        )
        if not route_pattern.search(demo_core_loop_source):
            fail(
                f"Week-24 dirty route {flag_id}->{root_id} disappeared",
                errors,
            )
        dirty_deferred_receipt_ids.add(source_id)
        event = registered_events.get(root_id, {})
        choices = event.get("choices", [])
        if not isinstance(choices, list) or not choices:
            fail(f"Week-24 dirty event {root_id} has no choices", errors)
            continue
        root_copy = trace_copy.get(root_id, {})
        copy_choices = (
            root_copy.get("choices", {})
            if isinstance(root_copy, dict)
            else {}
        )
        if not isinstance(copy_choices, dict) \
                or set(copy_choices) != {str(index) for index in range(len(choices))}:
            fail(f"First Bill trace lost an exact choice reader for {root_id}", errors)
        for choice_index, raw_choice in enumerate(choices):
            if isinstance(raw_choice, dict) \
                    and str(raw_choice.get("choice_kind", "")) == "expression":
                fail(
                    f"Week-24 dirty choice {root_id}[{choice_index}] "
                    "no longer writes a generic story receipt",
                    errors,
                )
                continue
            dirty_story_receipt_ids.add(f"{root_id}[{choice_index}]")
            if isinstance(raw_choice, dict) \
                    and isinstance(raw_choice.get("effects"), dict) \
                    and bool(raw_choice.get("effects")):
                dirty_local_material += 1
    if "_first_bill_trace_copy" not in demo_core_loop_source:
        fail("First Bill exact dirty trace reader disappeared", errors)

    note_story_choice_function = gdscript_function(
        demo_core_loop_source, "note_story_choice"
    )
    generic_story_writer = gdscript_function(
        demo_core_loop_source, "_note_generic_story_choice"
    )
    action_story_stage_function = gdscript_function(
        demo_core_loop_source, "action_story_stage"
    )
    complete_bundle_function = gdscript_function(
        demo_core_loop_source, "complete_active_bundle"
    )
    story_receipt_reader_function = gdscript_function(
        demo_core_loop_source, "_has_current_bundle_story_receipt"
    )
    if (
        "var story_recorded := _note_generic_story_choice("
        not in note_story_choice_function
        or 'state["story_choice_receipts"][receipt_key] = receipt'
        not in generic_story_writer
    ):
        fail("Week-24 dirty choices stopped writing generic story receipts", errors)
    story_receipt_reader_calls = demo_core_loop_source.count(
        "_has_current_bundle_story_receipt("
    )
    action_only_story_readers = (
        story_receipt_reader_calls == 3
        and bool(story_receipt_reader_function)
        and "_is_action_story_bundle(scene_bundle)"
        in action_story_stage_function
        and action_story_stage_function.count(
            "_has_current_bundle_story_receipt(state, target_id)"
        ) == 1
        and "if _is_action_story_bundle(active_spec)" in complete_bundle_function
        and complete_bundle_function.count(
            "_has_current_bundle_story_receipt("
        ) == 1
        and not str(first_bill_bundle.get("action_id", "")).strip()
    )
    if not action_only_story_readers:
        fail(
            "generic story receipt reader topology changed; "
            "reclassify Week-24 dirty receipts",
            errors,
        )
    story_owned_query_function = gdscript_function(
        demo_core_loop_source, "story_owns_action_result"
    )
    story_owned_handoff_function = gdscript_function(
        main_game_source,
        "_core_loop_v2_handoff_story_owned_action_result",
    )
    story_owned_query_is_pure = (
        bool(story_owned_query_function)
        and '"action_result_presentation", ""' in story_owned_query_function
        and '== "story_owned"' in story_owned_query_function
        and 'scene_bundle.get("action_id", "")' in story_owned_query_function
        and 'scene_bundle.get("existing_roots", [])' in story_owned_query_function
        and "GameState.core_loop_v2_state =" not in story_owned_query_function
        and "acknowledge_action_story_result" not in story_owned_query_function
        and "complete_active_bundle" not in story_owned_query_function
    )
    if not story_owned_query_is_pure:
        fail(
            "story-owned result query must remain an action/root-gated "
            "side-effect-free data query",
            errors,
        )
    handoff_ack_index = story_owned_handoff_function.find(
        "acknowledge_action_story_result"
    )
    handoff_story_index = story_owned_handoff_function.find(
        "_core_loop_v2_begin_story_bundle"
    )
    if not (
        "story_owns_action_result" in story_owned_handoff_function
        and "action_result_ready" in story_owned_handoff_function
        and "action_story_stage" in story_owned_handoff_function
        and 0 <= handoff_ack_index < handoff_story_index
        and "complete_active_bundle" not in story_owned_handoff_function
    ):
        fail(
            "story-owned result handoff stopped acknowledging before its "
            "same-owner story without completing the week",
            errors,
        )

    for route_function_name in ("_core_loop_v2_route_week", "_begin_month"):
        route_function = gdscript_function(
            main_game_source, route_function_name
        )
        handoff_index = route_function.find(
            "_core_loop_v2_handoff_story_owned_action_result"
        )
        restore_index = route_function.find(
            "_core_loop_v2_restore_action_result"
        )
        if not (0 <= handoff_index < restore_index):
            fail(
                f"{route_function_name} must hand off story-owned saved "
                "results before rendering a generic result card",
                errors,
            )

    direct_result_functions = {
        "_core_loop_v2_submit_application": "GameState.add_log",
        "_core_loop_v2_apply_instant_effect": "GameState.add_log",
        "_core_loop_v2_take_recovery": "GameState.add_log",
    }
    for function_name, generic_result_token in direct_result_functions.items():
        direct_function = gdscript_function(main_game_source, function_name)
        finalize_index = direct_function.find(
            "GameState.finalize_weekly_effect_action"
        )
        handoff_index = direct_function.find(
            "_core_loop_v2_handoff_story_owned_action_result"
        )
        generic_index = direct_function.find(generic_result_token)
        vignette_index = direct_function.find("_show_vignette")
        if not (
            0 <= finalize_index < handoff_index < generic_index
            and handoff_index < vignette_index
        ):
            fail(
                f"{function_name} must finalize once, hand off its "
                "story-owned result, then retain generic copy as fallback",
                errors,
            )
    demo_collision_completion = re.search(
        r'\n\t\tif bundle_id == "demo_collision":([\s\S]*?)'
        r'(?=\n\t\tif int\(contract\(\)\.get\("schema_version")',
        complete_bundle_function,
    )
    deferred_completion_guard = (
        demo_collision_completion is not None
        and re.search(
            r'state\[\s*"deferred_callback_receipts"\s*\]\.get\('
            r'\s*dirty_source,\s*\{\}\)',
            demo_collision_completion.group(1),
        ) is not None
        and re.search(
            r'get\(\s*"status",\s*""\s*\)\)\s*!=\s*"resolved"',
            demo_collision_completion.group(1),
        ) is not None
    )
    if not deferred_completion_guard:
        fail("Week-24 dirty completion lost its deferred-receipt guard", errors)
    if dirty_local_material != len(dirty_story_receipt_ids):
        fail("Week-24 dirty choices lost their local effects", errors)

    white_ending = endings.get("gangnam_dream_white", {})
    white_variants = (
        white_ending.get("description_if_known", {})
        if isinstance(white_ending, dict)
        else {}
    )
    if not isinstance(white_variants, dict) \
            or not str(white_variants.get("kept_clean_hands", "")).strip():
        fail(
            "declared clean ending recap reader disappeared for kept_clean_hands",
            errors,
        )
    check_game_over_function = gdscript_function(
        game_state_source, "check_game_over"
    )
    dark_priority_tokens = (
        'finish_run("full_circle")',
        'finish_run("second_love")',
        'finish_run("guardian")',
        'if flags.get("startup_exit", false):',
        "if total_now >= 3_000_000_000:",
        "if age <= 33:",
        'if flags.get("father_passed", false):',
        'if flags.get("daeun_divorced", false):',
        'if flags.get("daeun_married", false):',
        'if flags.get("jiyeon_romance_started", false)',
        'if flags.get("fell_to_darkness", false) '
        'or flags.get("crossed_line", false):',
        'finish_run("jaehyuk_way")',
    )
    dark_cursor = -1
    for token in dark_priority_tokens:
        dark_cursor = check_game_over_function.find(token, dark_cursor + 1)
        if dark_cursor < 0:
            break
    if "jaehyuk_way" not in endings or dark_cursor < 0:
        fail(
            "fell_to_darkness lost its conditional post-goal ending priority",
            errors,
        )

    actual_link_source_ids = (
        demo_event_ids
        | foreground_ids
        | bridge_ids
        | {"arc_year1_close"}
        | {
            str(raw_contract.get(field, ""))
            for raw_contract in future_story_contracts.values()
            if isinstance(raw_contract, dict)
            for field in ("trigger_event", "result_event")
        }
        | {
            str(city_contract.get("result_event", "")),
            *(root_id for _, _, root_id in dirty_specs),
        }
    )
    actual_link_source_ids.update(
        event_id
        for event_id in registered_events
        if direct_route_week(event_id, main_game_source) > 0
    )
    actual_link_source_ids.discard("")

    risk_specs = (
        (
            "clean",
            "kept_clean_hands+stayed_clean",
            "W4:arc_temptation_01[0]+W8:arc_temptation_clean",
            "none",
            "kept_clean_hands:recap_only",
            "gangnam_dream_white:recap_only",
            True,
            "recap_only",
            (("callback_stayed_clean_echo", "stayed_clean"),),
        ),
        (
            "escaped",
            "escaped_dirty_money+was_compromised",
            "W8:arc_temptation_fallout[0]",
            "v2_dirty_trace_initial_call:local_effect+exact_trace",
            "escaped_dirty_money:recap_only",
            "none",
            True,
            "recap_only",
            (
                ("callback_escaped_dirty_money_echo", "escaped_dirty_money"),
                ("callback_was_compromised_consequence", "was_compromised"),
            ),
        ),
        (
            "dark",
            "fell_to_darkness",
            "W8:arc_temptation_fallout[1]",
            "v2_dirty_recruiter_week24:local_effect+exact_trace",
            "fell_to_darkness:recap_only",
            "jaehyuk_way:conditional_route_effectful",
            False,
            "conditional_effectful_ending",
            (("callback_fell_to_darkness_echo", "fell_to_darkness"),),
        ),
    )
    dormant_callbacks: set[str] = set()
    bridge_shape_callbacks: set[str] = set()
    callback_copy_anchor_risks: set[str] = set()
    callback_labels: dict[str, list[str]] = {}
    for branch, _, _, _, recap, _, _, _, callbacks in risk_specs:
        recap_flag = recap.split(":", 1)[0]
        if not str(year_close_variants.get(recap_flag, "")).strip():
            fail(
                f"declared Week-48 risk recap reader disappeared for {recap_flag}",
                errors,
            )
        labels: list[str] = []
        for callback_id, condition_flag in callbacks:
            callback = registered_events.get(callback_id, {})
            conditions = callback.get("conditions", {})
            choices = callback.get("choices", [])
            if not isinstance(conditions, dict) \
                    or conditions.get("flag") != condition_flag \
                    or not isinstance(choices, list) \
                    or not choices:
                fail(
                    f"declared callback {callback_id} stopped reading {condition_flag}",
                    errors,
                )
                continue
            if is_bridge_event(callback):
                bridge_shape_callbacks.add(callback_id)
            linked_from_event = any(
                event_routes_to(event, callback_id)
                for event_id, event in registered_events.items()
                if event_id != callback_id
                and event_id in actual_link_source_ids
                and isinstance(event, dict)
            )
            direct_runtime = (
                f'"{callback_id}"' in demo_core_loop_source
                or f'"{callback_id}"' in main_game_source
            )
            reachable_callback = (
                (
                    callback_id in foreground_ids
                    and is_directed_random(callback)
                    and passes_content_exclusions(callback)
                )
                or callback_id in bridge_shape_callbacks
                or linked_from_event
                or direct_runtime
            )
            if not reachable_callback:
                dormant_callbacks.add(callback_id)
                labels.append(f"{callback_id}[{condition_flag}]:dormant")
            else:
                labels.append(f"{callback_id}[{condition_flag}]:reachable")
            description = str(callback.get("description", ""))
            if "두 달" in description or "석 달" in description:
                callback_copy_anchor_risks.add(callback_id)
        callback_labels[branch] = labels

    lines = [
        "long_tail_inventory "
        f"relationship_bundles={len(relationship_bundle_ids)} "
        f"relationship_memories={len(relationship_memory_ids)} "
        f"practical_action_receipts={len(practical_actions)} "
        f"career_application_receipts={len(career_application_actions)} "
        f"authored_action_story_receipts={len(authored_story_receipt_ids)} "
        f"routine_receipts={routine_receipt_count} "
        f"first_bill_decisions={len(obligation_ids)} "
        f"w24_dirty_story_choices={len(dirty_story_receipt_ids)} "
        f"w24_dirty_deferred_receipts={len(dirty_deferred_receipt_ids)}",
        "long_tail_family family=relationship_memory layer=memory "
        f"producers={len(relationship_memory_ids)} "
        f"local_state={len(relationship_memory_ids)} "
        f"demo_exact={len(demo_readers)} "
        f"demo_gate={len(demo_gate_readers)} "
        f"demo_prose={len(demo_prose_readers)} "
        f"demo_planner={len(demo_planner_readers)} "
        f"demo_planner_new={len(demo_planner_new_readers)} "
        f"overlap_gate_prose={len(demo_gate_readers & demo_prose_readers)} "
        f"y1_exact={len(y1_readers)} "
        f"y1_effectful_exact={len(y1_effectful_exact)} "
        f"overlap_demo_y1={len(relationship_overlap_demo_y1)} "
        f"y2_y5_exact={len(y2_y5_readers)} "
        f"y2_y5_effectful_exact={len(y2_y5_effectful_exact)} "
        f"ending_exact={len(ending_readers)} "
        f"ending_effectful_exact={len(ending_effectful_exact)} "
        f"named_reader_union={len(named_relationship_readers)} "
        f"readerless={len(relationship_readerless)}",
        "long_tail_readers family=relationship_memory horizon=y1 "
        f"count={len(y1_readers)} "
        f"prose_only={len(y1_prose_only)} "
        f"effectful_exact={len(y1_effectful_exact)} "
        f"host_effectful_memories={len(y1_host_effectful_memories)} "
        f"host_effectful_events={len(y1_host_effectful_event_ids)} "
        f"ids={compact_ids(y1_readers)} "
        f"effectful_exact_ids={compact_ids(y1_effectful_exact)} "
        f"host_effectful_event_ids="
        f"{compact_ids(y1_host_effectful_event_ids)}",
        "long_tail_readers family=relationship_memory horizon=y2_y5 "
        f"count={len(y2_y5_readers)} "
        f"prose_only={len(y2_y5_prose_only)} "
        f"effectful_exact={len(y2_y5_effectful_exact)} "
        f"ids={compact_ids(y2_y5_readers)} "
        f"effectful_exact_ids={compact_ids(y2_y5_effectful_exact)}",
        "long_tail_readers family=relationship_memory horizon=ending "
        f"count={len(ending_readers)} "
        f"prose_only={len(ending_prose_only)} "
        f"effectful_exact={len(ending_effectful_exact)} "
        f"ids={compact_ids(ending_readers)} "
        f"effectful_exact_ids={compact_ids(ending_effectful_exact)}",
        "long_tail_candidate family=relationship_memory "
        "candidate_disposition=pending_user_classification_not_auto_defect "
        "classification_question=small_completion_or_long_tail_gap "
        f"count={len(relationship_long_tail_candidates)} "
        f"post_demo_absent={len(relationship_post_demo_absent)} "
        f"post_demo_prose_only={len(relationship_post_demo_prose_only)} "
        f"post_demo_effectful_exact="
        f"{len(relationship_post_demo_effectful)} "
        f"readerless_anywhere={len(relationship_readerless)} "
        f"demo_only={len(relationship_demo_only)}",
        "long_tail_candidate_ids family=relationship_memory "
        f"post_demo_absent={compact_ids(relationship_post_demo_absent)} "
        f"post_demo_prose_only="
        f"{compact_ids(relationship_post_demo_prose_only)} "
        f"post_demo_effectful_exact="
        f"{compact_ids(relationship_post_demo_effectful)} "
        f"readerless_anywhere={compact_ids(relationship_readerless)}",
        "long_tail_reader_guard family=relationship_memory "
        "causal_schema=typed_relationship_memory_only "
        f"legacy_flag_collision_excluded={len(legacy_flag_collision_ids)} "
        f"ids={compact_ids(legacy_flag_collision_ids)}",
        "long_tail_family family=practical_action_receipt layer=material "
        f"producers={len(practical_actions)} "
        f"local_material={len(static_material_actions | runtime_material_actions)} "
        f"static_effect={len(static_material_actions)} "
        f"runtime_effect_route={len(runtime_material_actions)} "
        f"direct_receipt_story={len(practical_story_bundles)} "
        f"completed_bundle_causal_story="
        f"{len(practical_completed_bundle_readers)} "
        f"demo_causal_story={len(practical_causal_story_bundles)} "
        f"y1_causal_story=0 y2_y5_causal_story=0 ending_causal_story=0 "
        f"no_named_causal_story="
        f"{len(practical_actions) - len(practical_causal_story_bundles)} "
        f"direct_ids={compact_ids(practical_story_bundles)} "
        f"causal_routes={compact_ids({f'{source}>{target}' for source, targets in practical_completed_bundle_readers.items() for target in targets})}",
        "long_tail_family family=career_application_action_receipt "
        "layer=state_transition "
        f"producers={len(career_application_actions)} "
        f"local_material={len(material_career_actions)} "
        f"local_state_transition={len(effectless_application_actions)} "
        f"direct_receipt_story={len(career_direct_receipt_story)} "
        f"demo_causal_producers={len(career_demo_routes)} "
        f"demo_named_readers={len(career_demo_reader_ids)} "
        f"demo_availability_readers={int(hanbit_availability_reader)} "
        f"y1_causal_producers={len(career_y1_routes)} "
        f"y1_named_readers="
        f"{len({reader for readers in career_y1_routes.values() for reader in readers})} "
        "y2_y5_causal_story=0 ending_causal_story=0 "
        f"named_causal_union="
        f"{len(set(career_demo_routes) | set(career_y1_routes))} "
        f"no_named_causal_story="
        f"{len(career_application_actions) - len(set(career_demo_routes) | set(career_y1_routes))}",
        "long_tail_routes family=career_application_causal_story "
        f"demo={compact_ids(career_demo_route_labels)} "
        f"availability=m3_hanbit_application>m4_dodam_application[status_not_in] "
        f"y1=m5_city_service_application>v2_city_service_result_message"
        "[if_first_bill_city_work_sample]",
        "long_tail_family family=authored_action_story_receipt "
        "layer=mechanical "
        f"producers={len(authored_story_receipt_ids)} local_material=0 "
        f"demo_exact={len(authored_story_receipt_ids)} "
        "reader_mode=completion_guard y1_exact=0 y2_y5_exact=0 "
        "ending_exact=0 readerless=0",
        "long_tail_family family=routine_receipt layer=material "
        f"producers={routine_receipt_count} units={routine_units} "
        f"local_material={routine_receipt_count if routine_material else 0} "
        f"mechanical_idempotency={routine_receipt_count} "
        "demo_narrative_exact=0 y1_exact=0 y2_y5_exact=0 "
        f"ending_exact=0 no_named_story_reader={routine_receipt_count}",
        "long_tail_family family=first_bill_obligation layer=decision "
        f"producers={len(obligation_ids)} "
        f"local_material={first_bill_local_material} "
        f"demo_exact={len(first_bill_demo_readers)} reader_mode=ledger "
        f"y1_recap={len(recap_ids)} "
        f"y1_effectful={int(city_effectful)}:city_work_sample "
        "y2_y5_exact=0 "
        f"ending_exact={len(ending_obligation_readers)} "
        f"named_reader_union={len(first_bill_demo_readers | recap_ids)} "
        f"readerless={len(set(obligation_ids) - first_bill_demo_readers - recap_ids)}",
        "long_tail_candidate family=first_bill_obligation "
        "candidate_disposition=pending_user_classification_not_auto_defect "
        "classification_question=small_completion_or_long_tail_gap "
        f"count={len(first_bill_long_tail_candidates)} "
        f"post_demo_absent={len(first_bill_post_demo_absent)} "
        f"post_demo_recap_only={len(first_bill_post_demo_recap_only)} "
        f"effectful_excluded={len(first_bill_effectful_post_demo)} "
        f"ids={compact_ids(first_bill_long_tail_candidates)}",
        "long_tail_family family=w24_dirty_story_receipt layer=mechanical "
        f"producers={len(dirty_story_receipt_ids)} "
        f"choice_local_material={dirty_local_material} receipt_local_material=0 "
        "demo_exact=0 reader_mode=action_story_only "
        "y1_exact=0 y2_y5_exact=0 ending_exact=0 "
        f"readerless={len(dirty_story_receipt_ids)}",
        "long_tail_candidate family=w24_dirty_story_receipt "
        "candidate_disposition=pending_user_classification_not_auto_defect "
        "classification_question=small_completion_or_long_tail_gap "
        f"count={len(dirty_story_receipt_ids)} basis=write_only "
        f"ids={compact_ids(dirty_story_receipt_ids)}",
        "long_tail_family family=w24_dirty_deferred_receipt layer=decision "
        f"producers={len(dirty_deferred_receipt_ids)} local_material=0 "
        f"demo_exact={len(dirty_deferred_receipt_ids)} "
        "reader_mode=first_bill_exact_trace y1_exact=0 y2_y5_exact=0 "
        f"ending_exact=0 ids={compact_ids(dirty_deferred_receipt_ids)}",
        "long_tail_candidate family=w24_dirty_deferred_receipt "
        "count=0 basis=transport_exact_trace "
        "candidate_disposition=excluded_transport_not_choice "
        f"excluded_producers={len(dirty_deferred_receipt_ids)} "
        f"excluded_ids={compact_ids(dirty_deferred_receipt_ids)}",
    ]
    for (
        branch,
        producers,
        source,
        week24,
        recap,
        ending,
        is_long_tail_candidate,
        candidate_basis,
        _,
    ) in risk_specs:
        lines.append(
            "long_tail_risk "
            f"branch={branch} producers={producers} source={source} "
            f"w24={week24} w48={recap} "
            f"callback={'+'.join(callback_labels.get(branch, []))} "
            f"ending={ending} "
            f"long_tail_candidate={int(is_long_tail_candidate)} "
            f"candidate_basis={candidate_basis} "
            "candidate_disposition="
            + (
                "pending_user_classification_not_auto_defect"
                if is_long_tail_candidate else "has_effectful_tail"
            )
        )
    lines.append(
        "long_tail_dormant family=risk_callback "
        f"count={len(dormant_callbacks)} ids={compact_ids(dormant_callbacks)} "
        f"foreground={len(dormant_callbacks & foreground_ids)} "
        f"bridge={len(dormant_callbacks & bridge_ids)} "
        f"bridge_shape_eligible={len(bridge_shape_callbacks)} "
        f"earliest_if_foreground_added="
        f"{max(max_week + 1, int(content_diet.get('bridge_min_turn', 25)))} "
        f"relative_month_copy_risk={len(callback_copy_anchor_risks)} "
        f"copy_ids={compact_ids(callback_copy_anchor_risks)}"
    )
    return lines


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
    speech_summary = validate_demo_speech_contract(contract, errors)

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
    validate_opening_motivation_contract(contract, registered_events, errors)
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
    axis_measurement_lines = measure_reachable_axis_surfaces(
        contract,
        bundles,
        months,
        groups,
        relationship,
        surface,
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
            "daeun_late_meal_only": {
                "completed": {"daeun_shared_dream"},
                "stages": {"daeun": "shared_commitment"},
                "memories": {
                    ("daeun", "daeun_late_meal_promised"),
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
            "daeun_late_meal_only": expected_base,
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
    opening_id = "v2_demo_first_bill_opening"
    decision_id = "v2_demo_first_bill"
    ledger_id = "v2_demo_first_bill_ledger"
    if (
        demo_collision.get("planned_scene_id") != opening_id
        or demo_collision.get("existing_roots") != [opening_id]
        or demo_collision.get("allowed_weeks") != [24]
        or int(demo_collision.get("locked_week", 0)) != 24
    ):
        fail(
            "The locked June-26 finale must enter through the continuous "
            "First Bill opening root",
            errors,
        )
    expected_dynamic_tokens = [
        "{v2_first_bill_body}",
        "{v2_first_bill_trace}",
        "{v2_first_bill_evidence}",
        "{v2_first_bill_after_bills}",
        "{v2_first_bill_tradeoffs}",
        "{v2_first_bill_return}",
        "{v2_first_bill_done}",
        "{v2_first_bill_not_done}",
        "{v2_first_bill_deadline_missed}",
        "{v2_hyunsu_exam_eve_memory}",
    ]
    first_bill_finale = require_dict(
        demo_collision.get("first_bill_finale"),
        "demo_collision.first_bill_finale",
        errors,
    )
    expected_root_contract = {
        "opening_root": opening_id,
        "decision_event": decision_id,
        "ledger_event": ledger_id,
        "receipt_owner": "demo_collision",
        "continuous_fragment_tag": "continuous_scene_fragment",
    }
    if first_bill_finale.get("root_contract") != expected_root_contract:
        fail(
            "First Bill root/decision/ledger ownership contract drifted",
            errors,
        )
    expected_feature_contract = {
        "pressure_and_evidence": {
            "owner": opening_id,
            "tokens": expected_dynamic_tokens[:4],
        },
        "tradeoff_and_decision": {
            "owner": decision_id,
            "tokens": ["{v2_first_bill_tradeoffs}"],
            "long_term_receipt_owner": decision_id,
        },
        "done_and_deferred_ledger": {
            "owner": ledger_id,
            "tokens": expected_dynamic_tokens[5:9],
        },
        "exam_eve_memory": {
            "owner": "v2_hyunsu_exam_morning_echo",
            "tokens": ["{v2_hyunsu_exam_eve_memory}"],
            "receipt_id": "hyunsu_exam_2026",
        },
    }
    if first_bill_finale.get("feature_contract") != expected_feature_contract:
        fail(
            "First Bill scene functions no longer have one explicit owner each",
            errors,
        )
    if first_bill_finale.get("dynamic_tokens") != expected_dynamic_tokens:
        fail("First Bill dynamic story-token set or order drifted", errors)
    if first_bill_finale.get("deadline_missed_ids") != [
        "city_work_sample",
        "urgent_paid_shift",
    ]:
        fail(
            "Only the city worksheet and same-day paid shift may be recorded "
            "as deadlines missed",
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
    first_bill_opening = require_dict(
        registered_events.get(opening_id),
        f"registered event {opening_id}",
        errors,
    )
    first_bill_event = require_dict(
        registered_events.get(decision_id),
        f"registered event {decision_id}",
        errors,
    )
    first_bill_ledger = require_dict(
        registered_events.get(ledger_id),
        f"registered event {ledger_id}",
        errors,
    )
    first_bill_choices = require_list(
        first_bill_event.get("choices"),
        "registered event v2_demo_first_bill.choices",
        errors,
    )
    first_bill_description = str(first_bill_opening.get("description", ""))
    if (
        "{cash_position}" not in first_bill_description
        or "{expense}" not in first_bill_description
        or "{money}" in first_bill_description
    ):
        fail(
            "First Bill must distinguish available balance from arrears via "
            "{cash_position} and {expense}, never describe raw negative money "
            "as a bank balance",
            errors,
        )
    continuous_tag = "continuous_scene_fragment"
    finale_events = [first_bill_opening, first_bill_event, first_bill_ledger]
    if any(
        event.get("title") != "첫 청구서"
        or event.get("background") != "v2_first_bill_desk_closeup"
        or event.get("portrait") != "player_first_bill_decision"
        for event in finale_events
    ):
        fail(
            "First Bill opening, decision, and ledger must retain one Korean "
            "title, desk close-up, and Minjun performance portrait",
            errors,
        )
    if (
        continuous_tag in first_bill_opening.get("tags", [])
        or continuous_tag not in first_bill_event.get("tags", [])
        or continuous_tag not in first_bill_ledger.get("tags", [])
    ):
        fail(
            "Only the First Bill entry root may count as a standalone scene; "
            "its internal decision and ledger must be continuous fragments",
            errors,
        )

    expression_local_keys = {
        "text",
        "choice_kind",
        "follow_up_event",
        "result_text",
    }
    opening_choices = require_list(
        first_bill_opening.get("choices"),
        f"registered event {opening_id}.choices",
        errors,
    )
    if len(opening_choices) != 3:
        fail("First Bill opening must retain its three authored expression paths", errors)
    for choice_index, raw_choice in enumerate(opening_choices):
        choice = require_dict(
            raw_choice, f"registered event {opening_id}.choices[{choice_index}]", errors
        )
        if (
            choice.get("choice_kind") != "expression"
            or choice.get("follow_up_event") != decision_id
            or set(choice) != expression_local_keys
            or not str(choice.get("result_text", "")).strip()
        ):
            fail(
                f"First Bill opening choice {choice_index} must be a "
                "state-free expression response that rejoins the decision",
                errors,
            )
    if len(opening_choices) > 1 and "{v2_first_bill_after_bills}" not in str(
        require_dict(
            opening_choices[1],
            f"registered event {opening_id}.choices[1]",
            errors,
        ).get("result_text", "")
    ):
        fail(
            "The balance expression path must show the actual post-fixed-cost amount",
            errors,
        )

    ledger_choices = require_list(
        first_bill_ledger.get("choices"),
        f"registered event {ledger_id}.choices",
        errors,
    )
    if len(ledger_choices) != 1:
        fail("First Bill ledger must close through one authored local action", errors)
    else:
        ledger_choice = require_dict(
            ledger_choices[0], f"registered event {ledger_id}.choices[0]", errors
        )
        if (
            ledger_choice.get("choice_kind") != "expression"
            or set(ledger_choice) != {
                "text", "choice_kind", "result_text"
            }
            or not str(ledger_choice.get("result_text", "")).strip()
        ):
            fail(
                "Closing the notebook must remain a terminal state-free "
                "expression action",
                errors,
            )

    try:
        english_core_rows = json.loads(
            CORE_V2_EVENTS_EN_PATH.read_text(encoding="utf-8")
        )
    except (OSError, json.JSONDecodeError) as exc:
        fail(f"cannot load First Bill English overlay: {exc}", errors)
        english_core_rows = []
    english_core = {
        str(row.get("id", "")): row
        for row in english_core_rows
        if isinstance(row, dict) and str(row.get("id", ""))
    } if isinstance(english_core_rows, list) else {}
    if any(
        str(english_core.get(event_id, {}).get("title", ""))
        != "The First Bill"
        for event_id in (opening_id, decision_id, ledger_id)
    ):
        fail("English First Bill fragments must retain one continuous title", errors)
    ko_decision_description = str(first_bill_event.get("description", ""))
    en_decision_description = str(
        english_core.get(decision_id, {}).get("description", "")
    )
    if (
        "마감이 있는 일은 정해진 시각을 넘기는 순간 놓치게 된다."
        not in ko_decision_description
        or any(
            stale in ko_decision_description
            for stale in (
                "오후 6시까지인 두 마감",
                "오늘 다시 고를 수 없었다",
            )
        )
        or "Once a deadline passes, that task can no longer be completed tonight."
        not in en_decision_description
        or any(
            stale in en_decision_description
            for stale in (
                "two six-o'clock deadlines",
                "will be gone once its time passes tonight",
            )
        )
    ):
        fail(
            "First Bill decision must describe deadline pressure without "
            "inventing a fixed number of live deadline candidates",
            errors,
        )
    ko_token_surface = json.dumps(
        finale_events + [
            registered_events.get("v2_hyunsu_exam_morning_echo", {})
        ],
        ensure_ascii=False,
    )
    en_token_surface = json.dumps(
        [
            english_core.get(event_id, {})
            for event_id in (
                opening_id,
                decision_id,
                ledger_id,
                "v2_hyunsu_exam_morning_echo",
            )
        ],
        ensure_ascii=False,
    )
    for token in expected_dynamic_tokens:
        if ko_token_surface.count(token) != 1 or en_token_surface.count(token) != 1:
            fail(
                f"First Bill token {token} must have exactly one Korean and "
                "one English authored surface",
                errors,
            )

    candidate_copy = require_dict(
        first_bill_finale.get("candidate_copy"),
        "demo_collision.first_bill_finale.candidate_copy",
        errors,
    )
    expected_direct_first_bill_copy = {
        ("tradeoff", "body_rest", "en"):
            "shower, drink some water, and rest without doing more work",
        ("done", "daeun_checkin", "ko"): "짧게 안부를 나눴다",
        ("done", "daeun_checkin", "en"):
            "briefly checked in with her",
        ("not_done", "body_rest", "ko"): "알람을 맞추고 누워 쉬지 못했다",
        ("not_done", "body_rest", "en"):
            "did not stop for the night and lie down to rest",
        ("return", "sangchul_ledger", "ko"):
            "수첩을 앞쪽의 결정 페이지로 넘겼다",
        ("return", "sangchul_ledger", "en"):
            "turns from the expense ledger back",
    }
    for (phase, obligation_id, locale), required_copy in (
        expected_direct_first_bill_copy.items()
    ):
        localized = candidate_copy.get(phase, {}).get(obligation_id, {})
        actual_copy = str(localized.get(locale, "")) \
            if isinstance(localized, dict) else ""
        if required_copy not in actual_copy:
            fail(
                f"First Bill {phase}.{obligation_id}.{locale} must retain "
                "observable, direct physical wording",
                errors,
            )
    expected_candidate_sets = {
        "evidence": set(expected_obligation_ids),
        "tradeoff": set(expected_obligation_ids),
        "done": set(expected_obligation_ids),
        "return": set(expected_obligation_ids),
        "not_done": set(expected_obligation_ids)
        - {"city_work_sample", "urgent_paid_shift"},
        "deadline_missed": {"city_work_sample", "urgent_paid_shift"},
    }
    if set(candidate_copy) != set(expected_candidate_sets):
        fail("First Bill candidate copy contains an unknown or missing phase", errors)
    for phase, expected_ids in expected_candidate_sets.items():
        phase_copy = require_dict(
            candidate_copy.get(phase),
            f"demo_collision.first_bill_finale.candidate_copy.{phase}",
            errors,
        )
        if set(phase_copy) != expected_ids:
            fail(
                f"First Bill {phase} copy must cover only its actual candidate IDs",
                errors,
            )
        for obligation_id, raw_copy in phase_copy.items():
            localized = require_dict(
                raw_copy,
                f"demo_collision.first_bill_finale.candidate_copy."
                f"{phase}.{obligation_id}",
                errors,
            )
            if set(localized) != {"ko", "en"} or any(
                not isinstance(localized.get(locale), str)
                or not localized.get(locale, "").strip()
                for locale in ("ko", "en")
            ):
                fail(
                    f"First Bill {phase}.{obligation_id} needs independent "
                    "non-empty Korean and English copy",
                    errors,
                )

    body_checks = require_list(
        first_bill_finale.get("body_check"),
        "demo_collision.first_bill_finale.body_check",
        errors,
    )
    if [row.get("max_health") for row in body_checks if isinstance(row, dict)] \
            != [5, 20, 50, 100]:
        fail("First Bill body copy must cover the four canonical health bands", errors)
    after_bills_copy = require_dict(
        first_bill_finale.get("after_bills_copy"),
        "demo_collision.first_bill_finale.after_bills_copy",
        errors,
    )
    if set(after_bills_copy) != {"covered", "short", "arrears"}:
        fail("First Bill cash copy must distinguish covered, short, and arrears", errors)
    trace_copy = require_dict(
        first_bill_finale.get("trace_copy"),
        "demo_collision.first_bill_finale.trace_copy",
        errors,
    )
    if set(trace_copy) != {
        "v2_dirty_trace_initial_call", "v2_dirty_recruiter_week24"
    }:
        fail("First Bill dirty trace may read only the two durable Week-24 roots", errors)
    hyunsu_memory_copy = require_dict(
        first_bill_finale.get("hyunsu_memory_copy"),
        "demo_collision.first_bill_finale.hyunsu_memory_copy",
        errors,
    )
    if set(hyunsu_memory_copy) != {
        "hyunsu_exam_eve_one_problem",
        "hyunsu_exam_eve_rest_protected",
        "hyunsu_exam_eve_unanswered",
    }:
        fail(
            "Hyunsu's exam morning must distinguish one problem, protected "
            "rest, and no reply",
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
    expected_first_bill_effects = [
        {"mental": -1},
        {"intelligence": 1, "mental": -1},
        {"intelligence": 1, "mental": -2},
        {"social_skill": 1, "mental": 1},
        {"social_skill": 1},
        {"intelligence": 1},
        {"money": 280_000, "health": -5, "mental": -4},
        {"health": 2, "mental": 1},
    ]
    expected_result_backgrounds = {
        3: "convenience_night",
        6: "warehouse_inventory_night",
    }
    expected_result_ambience = {
        3: "convenience",
        6: "public_office",
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
        if (
            choice.get("choice_kind") != "decision"
            or choice.get("follow_up_event") != ledger_id
            or choice.get("effects", {})
            != (
                expected_first_bill_effects[choice_index]
                if choice_index < len(expected_first_bill_effects)
                else None
            )
            or str(choice.get("result_background", ""))
            != expected_result_backgrounds.get(choice_index, "")
            or str(choice.get("result_ambience", ""))
            != expected_result_ambience.get(choice_index, "")
        ):
            fail(
                f"First Bill choice {choice_index} changed its decision kind, "
                "effect receipt, result location, or common ledger return",
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
        for proof in ("called his father", "taps his father's number")
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
            "{name} blocks the number and flips the phone face-down."
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

    long_tail_measurement_lines = measure_long_tail_readers(
        contract,
        registered_events,
        demo_core_loop_source,
        year_close_variants,
        year_close_obligation_readers,
        expected_obligation_ids,
        errors,
    )

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

    for line in axis_measurement_lines:
        print(line)
    for line in long_tail_measurement_lines:
        print(line)
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
        f"speech_required={speech_summary['required']} "
        f"speech_exempt={speech_summary['exempt']} "
        f"speech_unclassified={speech_summary['unclassified']} "
        "legacy_backfill_required=0 "
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
