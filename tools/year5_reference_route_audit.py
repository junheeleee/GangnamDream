#!/usr/bin/env python3
"""Audit the non-live Year-5 career/startup reference-route contract.

The manifest is deliberately stricter than a prose design note.  It freezes two
author-only traces while production routing, durable ledgers, transactions, and
ending deferral are still absent.  A passing audit therefore means
"machine-readable reference", never "playable".
"""

from __future__ import annotations

import argparse
import copy
import functools
import hashlib
import json
import re
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Callable, Iterable, Iterator


ROOT = Path(__file__).resolve().parents[1]
MANIFEST_PATH = ROOT / "content" / "meta" / "year5_reference_routes.json"
EVENT_DIRS = {
    "ko": ROOT / "content" / "events",
    "en": ROOT / "content" / "events_en",
}

EXPECTED_DECLARATION = "2c0ec23122ce7718439ad352c2d0e55915398e9f"
EXPECTED_BASELINE = "e27ff7e69990fee16aef5f11913c0d3db56d58f3"
EXPECTED_MANIFEST_ID = "year5_reference_routes_v1"
EXPECTED_ROUTE_IDS = (
    "career_reference_v1",
    "startup_acquisition_reference_v1",
)

TOP_LEVEL_KEYS = {
    "schema_version",
    "manifest_id",
    "declaration_commit",
    "protected_baseline_commit",
    "choice_index_base",
    "activation",
    "reachability_claim",
    "runtime_owner",
    "scope",
    "receipt_types",
    "actor_registry",
    "routes",
    "planned_runtime",
    "unresolved_blockers",
    "protected_hashes",
}
ROUTE_KEYS = {
    "route_id",
    "economic_path",
    "partner",
    "entry",
    "exclusions",
    "actors",
    "document_lineage",
    "months",
    "roots",
    "planned_transaction",
    "finale_handoff",
    "legacy_exclusions",
}
MONTH_KEYS = {
    "month",
    "incoming_margin",
    "selected_commitments",
    "outgoing_margin",
    "fallback_owner",
    "unresolved",
    "root_order",
}
ROOT_KEYS = {
    "id",
    "ko_file",
    "en_file",
    "month",
    "order",
    "choice_count",
    "requirements",
    "actor_roles",
    "document_reads",
    "common_writes",
    "choice_partitions",
    "choices",
}
PARTITION_KEYS = {"continuation", "terminal", "complete"}
CHOICE_KEYS = {"index", "outcome_id", "flow", "requirements", "writes"}
PROTECTED_HASH_KEYS = {
    "algorithm",
    "canonicalization",
    "files",
    "objects",
    "runtime_consumers",
}
PROTECTED_OBJECT_KEYS = {"locale", "file", "id", "sha256"}
RUNTIME_CONSUMER_KEYS = {"expected_count", "forbidden_root_ids"}
SCOPE_KEYS = {
    "months",
    "route_ids",
    "expected_route_count",
    "expected_root_count_per_route",
    "expected_choice_count_per_route",
    "expected_root_count_total",
    "expected_choice_count_total",
    "excluded_economic_paths",
    "excluded_reference_families",
    "live_split",
}
RECEIPT_TYPE_KEYS = {
    "route_lock",
    "actor_binding",
    "document_version",
    "scene_choice",
    "commitment_completion",
    "margin",
    "transaction",
    "finale_state",
}

STATEFUL_CHOICE_KEYS = {
    "effects",
    "flags",
    "cast_effects",
    "relationship_effects",
    "investment_effects",
    "follow_up_event",
    "deferred_follow_up",
    "deferred_delay",
    "opportunity",
    "give_items",
    "requires_item",
    "grant_job",
    "replace_current_job",
    "route",
    "year_scene",
}
STATEFUL_EVENT_KEYS = STATEFUL_CHOICE_KEYS | {"writer", "follow_up"}

MANDATORY_PROTECTED_FILES = {
    "content/meta/story_map.json",
    "content/meta/story_rules.json",
    "autoloads/EventManager.gd",
    "autoloads/GameState.gd",
    "autoloads/SaveManager.gd",
    "scenes/MainGame.gd",
    "scenes/StoryMode.gd",
    "systems/EndingSystem.gd",
    "systems/StoryMapMonthlyRuntime.gd",
    "content/endings.json",
    "content/endings_en.json",
    "content/endings_ja.json",
    "content/endings_zh-CN.json",
    "content/endings_zh-TW.json",
}
EXPECTED_PROTECTED_FILES = MANDATORY_PROTECTED_FILES | {
    "content/meta/narrative_spine.json",
    "content/events/arc_drama.json",
    "content/events/arc_midgame.json",
    "content/events/arc_new_characters.json",
    "content/events/arc_pre_ending.json",
    "content/events/callback_events_16.json",
    "content/events/callback_events_19.json",
    "content/events/callback_events_2.json",
    "content/events/callback_events_20.json",
    "content/events/drama_events.json",
    "content/events/life_events.json",
    "content/events_en/arc_drama.json",
    "content/events_en/arc_midgame.json",
    "content/events_en/arc_new_characters.json",
    "content/events_en/arc_pre_ending.json",
    "content/events_en/callback_events_16.json",
    "content/events_en/callback_events_19.json",
    "content/events_en/callback_events_2.json",
    "content/events_en/callback_events_20.json",
    "content/events_en/drama_events.json",
    "content/events_en/life_events.json",
}


@dataclass(frozen=True)
class RootSpec:
    event_id: str
    month: int | str
    choice_count: int


CAREER_ROOTS = (
    RootSpec("arc_y5_contract_cover_career", 49, 3),
    RootSpec("arc_y5_contract_reviewer_delivery_minseo_career", 49, 3),
    RootSpec("arc_y5_protection_boundary_hyunsu_career", 50, 3),
    RootSpec("arc_y5_minseo_goal_cost_career", 51, 3),
    RootSpec("arc_y5_after_goal_hyunsu_career", 51, 3),
    RootSpec("arc_y5_final_offer_career_boss", 52, 3),
    RootSpec("arc_y5_career_reviewer_receipt_minseo", 54, 1),
    RootSpec("arc_y5_three_in_room_career", 55, 3),
    RootSpec("arc_y5_three_in_room_decision_career", 55, 3),
    RootSpec("arc_y5_name_on_line_career_self", 57, 4),
    RootSpec("arc_y5_name_copy_delivered_hyunsu_career", 57, 1),
    RootSpec("arc_y5_people_verdict_career_hyunsu", 58, 3),
    RootSpec("arc_y5_contract_execution_career", 59, 3),
    RootSpec("arc_y5_contract_result_delivered_hyunsu_career", 59, 1),
    RootSpec("arc_final_countdown_career_executed", 60, 3),
    RootSpec("arc_y5_final_week_hyunsu_career_outbound", 60, 3),
)
STARTUP_ROOTS = (
    RootSpec("arc_y5_startup_offer_c0", 49, 3),
    RootSpec("arc_y5_startup_c0_reviewer_delivery_minseo", 49, 1),
    RootSpec("arc_y5_startup_boundary_cofounder", 50, 4),
    RootSpec("arc_y5_startup_minseo_goal_cost", 51, 3),
    RootSpec("arc_y5_startup_after_goal_cofounder", 51, 3),
    RootSpec("arc_y5_startup_final_offer_acquirer", 52, 4),
    RootSpec("arc_y5_startup_reviewer_receipt_minseo", 54, 1),
    RootSpec("arc_y5_startup_three_in_room", 55, 3),
    RootSpec("arc_y5_startup_three_in_room_decision", 55, 3),
    RootSpec("arc_y5_startup_c2_sign_self", 57, 4),
    RootSpec("arc_y5_startup_c2_copy_delivered_cofounder", 57, 1),
    RootSpec("arc_y5_startup_people_verdict_cofounder", 58, 3),
    RootSpec("arc_y5_startup_contract_execution_c3", 59, 3),
    RootSpec("arc_y5_startup_c3_copy_delivered_cofounder", 59, 1),
    RootSpec("arc_final_countdown_startup_executed", 60, 3),
    RootSpec("arc_y5_final_week_startup_after_acquisition", 60, 3),
)
ROUTE_ROOTS = {
    "career_reference_v1": CAREER_ROOTS,
    "startup_acquisition_reference_v1": STARTUP_ROOTS,
}
ALL_TARGET_IDS = tuple(spec.event_id for roots in ROUTE_ROOTS.values() for spec in roots)
ALL_TARGET_ID_SET = set(ALL_TARGET_IDS)
LEGACY_PROTECTED_IDS = (
    "startup_opportunity",
    "startup_acquisition_offer",
    "drama_startup_offer",
    "drama_startup_acquisition",
    "startup_team_conflict",
    "callback_startup_grind_result",
    "callback_startup_going_solo_result",
    "callback_startup_partial_exit_echo",
    "callback_startup_going_solo_echo",
    "callback_startup_exit_echo",
    "callback_startup_founded_echo",
)

EXPECTED_ACTORS = {
    "career_reference_v1": {
        "proposer": "boss",
        "counterparty": "boss",
        "reviewer": "minseo",
        "protected": "hyunsu",
        "affected": "hyunsu",
        "primary_witness": "hyunsu",
    },
    "startup_acquisition_reference_v1": {
        "proposer": "acquirer_lead",
        "counterparty": "acquirer_lead",
        "reviewer": "minseo",
        "protected": "startup_cofounder",
        "affected": "startup_cofounder",
        "primary_witness": "startup_cofounder",
    },
}

EXPECTED_ACTOR_SOURCES = {
    "career_reference_v1": {
        "proposer": "compatible_current_job.canonical_boss_role",
        "counterparty": "same_binding_as:proposer",
        "reviewer": "literal_actor:minseo",
        "protected": "future_typed_receipt:m48_tell_surviving_person.actor",
        "affected": "same_binding_as:protected",
        "primary_witness": "same_binding_as:protected",
    },
    "startup_acquisition_reference_v1": {
        "proposer": "route_scene_receipt:arc_y5_startup_offer_c0",
        "counterparty": "same_binding_as:proposer",
        "reviewer": "literal_actor:minseo",
        "protected": "future_typed_receipt:startup_founded.cofounder_actor",
        "affected": "same_binding_as:protected",
        "primary_witness": "same_binding_as:protected",
    },
}

EXPECTED_DISTINCT_ROLE_GROUPS = [
    ["proposer", "counterparty"],
    ["reviewer"],
    ["protected", "affected", "primary_witness"],
]
EXPECTED_INVALIDATIONS = {
    "career_reference_v1": [
        "player quit the bound job",
        "current job is not in compatible_job_ids",
        "M48 remaining-person actor receipt is absent or is not hyunsu",
    ],
    "startup_acquisition_reference_v1": [
        "startup founding receipt or cofounder binding is absent",
        "startup_exit, startup_partial_exit, startup_going_solo or joined_startup is present",
        "legacy acquisition offer has already been consumed or declined",
    ],
}
EXPECTED_ROUTE_EXCLUSIONS = {
    "career_reference_v1": [
        "partner is not none",
        "player quit the bound job",
        "incompatible current job",
        "M48 actor or trust-margin provenance mismatch",
    ],
    "startup_acquisition_reference_v1": [
        "partner is not none",
        "startup_exit",
        "startup_partial_exit",
        "startup_going_solo",
        "joined_startup",
        "legacy startup acquisition offer already consumed or declined",
        "M48 actor or trust-margin provenance mismatch",
    ],
}

EXPECTED_SCOPE = {
    "months": list(range(49, 61)),
    "route_ids": list(EXPECTED_ROUTE_IDS),
    "expected_route_count": 2,
    "expected_root_count_per_route": 16,
    "expected_choice_count_per_route": 43,
    "expected_root_count_total": 32,
    "expected_choice_count_total": 86,
    "excluded_economic_paths": ["investment"],
    "excluded_reference_families": ["property", "ORDER-111 alternate routes"],
    "live_split": {
        "r1": {
            "months": [49, 50, 51, 52, 53, 54, 55],
            "activation_after_completion": False,
            "owns": ["durable ledger", "actor binding", "typed selectors"],
        },
        "r2": {
            "months": [57, 58, 59, 60],
            "activation_after_completion": True,
            "owns": [
                "terminal routing",
                "atomic transactions",
                "finale hold and release",
            ],
        },
    },
}

EXPECTED_PLANNED_RUNTIME = {
    "current_consumer_count": 0,
    "activation_preconditions": [
        "R1 and R2 complete",
        "all unresolved blockers closed",
        "durable typed receipts and route lock exist",
        "terminal routing, atomic transactions and finale handoff pass self-test",
    ],
    "production_dispatcher": None,
    "save_ledger_owner": None,
}

EXPECTED_ROUTE_ENTRIES = {
    "career_reference_v1": {
        "required_economic_path": "career",
        "compatible_job_ids": [
            "job_03",
            "job_04",
            "job_05",
            "job_06",
            "job_07",
            "job_08",
            "job_09",
            "job_10",
            "job_12",
            "job_14",
            "job_15",
        ],
        "required_future_receipts": [
            "m48_tell_surviving_person.actor=hyunsu",
            "m48_tell_surviving_person.margin.axis=trust",
            "m49_route_selected=career_reference_v1",
        ],
        "route_lock": {
            "producer_month": 49,
            "value": "career_reference_v1",
            "silent_priority": False,
        },
    },
    "startup_acquisition_reference_v1": {
        "required_economic_path": "startup",
        "required_origin_receipt": {
            "flag": "startup_founded",
            "initial_cash_delta_krw": -3000000,
            "initial_equity_basis_points": 2000,
            "cofounder_actor_required": True,
        },
        "required_absent_flags": [
            "startup_exit",
            "startup_partial_exit",
            "startup_going_solo",
            "joined_startup",
        ],
        "required_future_receipts": [
            "m48_tell_surviving_person.actor=startup_cofounder",
            "m48_tell_surviving_person.margin.axis=trust",
            "m49_route_selected=startup_acquisition_reference_v1",
        ],
        "route_lock": {
            "producer_month": 49,
            "value": "startup_acquisition_reference_v1",
            "silent_priority": False,
        },
        "legacy_save_policy": "fail_closed_without_durable_mode",
    },
}

EXPECTED_LEGACY_EXCLUSIONS = {
    "career_reference_v1": [],
    "startup_acquisition_reference_v1": [
        {
            "id": "startup_acquisition_offer",
            "reason": "legacy immediate acquisition and finish path; never infer staged state",
        },
        {
            "id": "drama_startup_acquisition",
            "reason": "legacy 80M joined_startup path; never merge with SA-20",
        },
        {"flag": "startup_partial_exit", "reason": "mutually exclusive ownership path"},
        {"flag": "startup_going_solo", "reason": "mutually exclusive ownership path"},
    ],
}

EXPECTED_ACTOR_ROLES = {
    "arc_y5_contract_cover_career": ["proposer", "reviewer", "protected"],
    "arc_y5_contract_reviewer_delivery_minseo_career": ["reviewer"],
    "arc_y5_protection_boundary_hyunsu_career": ["protected", "affected"],
    "arc_y5_minseo_goal_cost_career": ["reviewer"],
    "arc_y5_after_goal_hyunsu_career": ["protected"],
    "arc_y5_final_offer_career_boss": ["proposer", "counterparty"],
    "arc_y5_career_reviewer_receipt_minseo": ["reviewer"],
    "arc_y5_three_in_room_career": ["proposer", "reviewer", "protected"],
    "arc_y5_three_in_room_decision_career": ["proposer", "reviewer", "protected"],
    "arc_y5_name_on_line_career_self": [],
    "arc_y5_name_copy_delivered_hyunsu_career": ["protected"],
    "arc_y5_people_verdict_career_hyunsu": ["primary_witness"],
    "arc_y5_contract_execution_career": ["proposer", "counterparty"],
    "arc_y5_contract_result_delivered_hyunsu_career": ["primary_witness"],
    "arc_final_countdown_career_executed": ["primary_witness"],
    "arc_y5_final_week_hyunsu_career_outbound": ["primary_witness"],
    "arc_y5_startup_offer_c0": ["proposer", "protected"],
    "arc_y5_startup_c0_reviewer_delivery_minseo": ["reviewer"],
    "arc_y5_startup_boundary_cofounder": ["protected", "affected"],
    "arc_y5_startup_minseo_goal_cost": ["reviewer"],
    "arc_y5_startup_after_goal_cofounder": ["protected"],
    "arc_y5_startup_final_offer_acquirer": ["proposer", "counterparty"],
    "arc_y5_startup_reviewer_receipt_minseo": ["reviewer"],
    "arc_y5_startup_three_in_room": ["proposer", "reviewer", "protected"],
    "arc_y5_startup_three_in_room_decision": ["proposer", "reviewer", "protected"],
    "arc_y5_startup_c2_sign_self": ["counterparty"],
    "arc_y5_startup_c2_copy_delivered_cofounder": ["protected"],
    "arc_y5_startup_people_verdict_cofounder": ["primary_witness"],
    "arc_y5_startup_contract_execution_c3": ["proposer", "counterparty"],
    "arc_y5_startup_c3_copy_delivered_cofounder": ["primary_witness"],
    "arc_final_countdown_startup_executed": ["primary_witness"],
    "arc_y5_final_week_startup_after_acquisition": ["primary_witness"],
}

EXPECTED_TERMINAL_STATES = {
    ("arc_y5_three_in_room_decision_career", 1): "terminal_state:appointment_delayed_10_business_days",
    ("arc_y5_three_in_room_decision_career", 2): "terminal_state:tf_budget_minus_20_percent",
    ("arc_y5_name_on_line_career_self", 0): "terminal_state:c2_withdrawn",
    ("arc_y5_name_on_line_career_self", 2): "terminal_state:external_reviewer_pending_verification",
    ("arc_y5_name_on_line_career_self", 3): "terminal_state:c2_unfiled_held",
    ("arc_y5_people_verdict_career_hyunsu", 1): "terminal_state:result_first_conversation_shortened",
    ("arc_y5_people_verdict_career_hyunsu", 2): "terminal_state:player_must_write_boundary",
    ("arc_y5_contract_execution_career", 1): "terminal_state:offer_rejected_unexecuted",
    ("arc_y5_contract_execution_career", 2): "terminal_state:resigned_settled_badge_returned_c2_unexecuted",
    ("arc_y5_startup_boundary_cofounder", 3): "terminal_state:joint_warranty_rejected_no_extension",
    ("arc_y5_startup_final_offer_acquirer", 3): "terminal_state:discussion_ended_no_draft_received",
    ("arc_y5_startup_three_in_room_decision", 1): "terminal_state:product_package_draft_unsigned",
    ("arc_y5_startup_three_in_room_decision", 2): "terminal_state:people_package_draft_unsigned",
    ("arc_y5_startup_c2_sign_self", 1): "terminal_state:date_mismatch_rework",
    ("arc_y5_startup_c2_sign_self", 2): "terminal_state:deferred_48h",
    ("arc_y5_startup_c2_sign_self", 3): "terminal_state:withdrawn_20pct_retained",
    ("arc_y5_startup_people_verdict_cofounder", 1): "terminal_state:notice_assigned_acquirer",
    ("arc_y5_startup_people_verdict_cofounder", 2): "terminal_state:joint_explanation_required",
    ("arc_y5_startup_contract_execution_c3", 1): "terminal_state:closing_stopped_date_mismatch",
    ("arc_y5_startup_contract_execution_c3", 2): "terminal_state:sale_cancelled_20pct_retained",
}

ROOT_SEMANTIC_DIGEST_KEYS = (
    "requirements",
    "actor_roles",
    "document_reads",
    "common_writes",
    "choice_partitions",
    "choices",
)
EXPECTED_ROOT_SEMANTIC_DIGESTS = {
    "arc_y5_contract_cover_career": "216fc337c6a067c9a76ee31f870d411027a995ba8901134cbd47832045359d1a",
    "arc_y5_contract_reviewer_delivery_minseo_career": "c1df4b31e75c25a6640686085b68c0dceecd09afd812ce79812a77824267229b",
    "arc_y5_protection_boundary_hyunsu_career": "233f286f4ff6795899a37706a4a4871bf15026ac16d623ac26cadd1c1efdee31",
    "arc_y5_minseo_goal_cost_career": "24643075b233a318cdc9477d3905201711239c4788f5008e51f8c246610af617",
    "arc_y5_after_goal_hyunsu_career": "ec0198814a1ccd9b6599b9c68729015fb2ccdcc328abdb72849783a45f22c39b",
    "arc_y5_final_offer_career_boss": "26dbcce87dbec51798ed6241a5d7176c4ae5eb8ca37109ab4d992e4c8fc2cae9",
    "arc_y5_career_reviewer_receipt_minseo": "21bb548e277008ca1241ac5fb2a30911a8331d2e4d73f5b8d16ec6be5024cd97",
    "arc_y5_three_in_room_career": "175d9d39ce859e8d842b71e2ccfbbcce6aa87b9f862f9890e6aa4f1f45346109",
    "arc_y5_three_in_room_decision_career": "4d90c9fadc2fc6eddbeb62e93a31fccbad5839a510a5a6c48b9bf03c281e6f51",
    "arc_y5_name_on_line_career_self": "bf1361e04557438e89334c4619613337bad6660a3c0d37cdaaa94d92a50652d3",
    "arc_y5_name_copy_delivered_hyunsu_career": "1366ba281dd461fb23395eed770efc1afd6cab9b36c40779383a2d13808eb561",
    "arc_y5_people_verdict_career_hyunsu": "2b951be1b02b3e178885e55c9f476f02996da4d6752255e8ac1758048f1e7555",
    "arc_y5_contract_execution_career": "41d58ee4f3f9efff30be88a893e4129eea444e817208eb4bae49c2273b3ab834",
    "arc_y5_contract_result_delivered_hyunsu_career": "a7c47b9ba6dc6954b3c8707c12b1f913923f8ff0c7091bf73684871aca7b671a",
    "arc_final_countdown_career_executed": "25fda3757fe86625be02cb3202ddd5b6f1262849b5b1c0f851978a60b8f9cee0",
    "arc_y5_final_week_hyunsu_career_outbound": "e1c164327b1789cb880c82f44593534d6d0db91ce172d28d09d380add1680374",
    "arc_y5_startup_offer_c0": "fc8fc53acafb6135c31ef40ebf93e763b34f9b85fcd5fd9f27b2b92c55ff1dfc",
    "arc_y5_startup_c0_reviewer_delivery_minseo": "0ac58cc0229abb3318d3003c8e8aee32865075f8f761d9f9f133ca8a65047a86",
    "arc_y5_startup_boundary_cofounder": "bce199090f274b61fcba82a710670a5f2f9aa240b7d2e5add5f7f0971663d07b",
    "arc_y5_startup_minseo_goal_cost": "15820342278bbef6e479ff9c72592783d3bcb77f681d058871e46afa8f3495cf",
    "arc_y5_startup_after_goal_cofounder": "572373318ee2ddd76759178458dd57a779391705e26cb6b90e819de170ae6f2c",
    "arc_y5_startup_final_offer_acquirer": "54189b2d7e6c16c3e0479f34b1163d7a3468d4313945dad2944591ebfa957ce2",
    "arc_y5_startup_reviewer_receipt_minseo": "735dc9d2f06a03fb346c0d9b43755a5ae0e210bdb138add44b20a25941cbc3b3",
    "arc_y5_startup_three_in_room": "a4e38a47231199990779a7dad1a13a58582822d2d62dc5a335db8c201913cf66",
    "arc_y5_startup_three_in_room_decision": "193c5075d50d22d57bf9ec3b26484152129fc2fc44c3a13ffd2147d042d04df4",
    "arc_y5_startup_c2_sign_self": "dfaf04b154ad4c0085e315529de2666282c18a8e4c506a7387ca6dfedb045e74",
    "arc_y5_startup_c2_copy_delivered_cofounder": "7f699a68022581cd6c0def0a7b2c4600185dc5bee7be1c33179810f5871b1e2a",
    "arc_y5_startup_people_verdict_cofounder": "197b5c8bf9d1e250638b6c3a8331360e2ad60a3264f3764b3ba02d582cf2be91",
    "arc_y5_startup_contract_execution_c3": "0c16b3da755c614ecf8313ade7a3e9968070ef8c558b236be3ca85c4f9dda071",
    "arc_y5_startup_c3_copy_delivered_cofounder": "57ed0ecbb1f0125ddf2e7e5473a577cdf2f614445701470401f7881e54864831",
    "arc_final_countdown_startup_executed": "b40d07927aa5ee8fe002c90519dafc0173fb81ae61971968ecbb2b69a1878842",
    "arc_y5_final_week_startup_after_acquisition": "ace141415b424bf9f5b24920e72bec9923bb168abcb7b6c210989f42d73c468e",
}

EXPECTED_TERMINAL_WRITES = {
    ("arc_y5_three_in_room_decision_career", 1): [
        "terminal_state:appointment_delayed_10_business_days",
        "route_terminal:career:m55:1",
        "scene_choice:arc_y5_three_in_room_decision_career:1",
    ],
    ("arc_y5_three_in_room_decision_career", 2): [
        "terminal_state:tf_budget_minus_20_percent",
        "route_terminal:career:m55:2",
        "scene_choice:arc_y5_three_in_room_decision_career:2",
    ],
    ("arc_y5_name_on_line_career_self", 0): [
        "terminal_state:c2_withdrawn",
        "route_terminal:career:m57:0",
        "scene_choice:arc_y5_name_on_line_career_self:0",
    ],
    ("arc_y5_name_on_line_career_self", 2): [
        "terminal_state:external_reviewer_pending_verification",
        "route_terminal:career:m57:2",
        "scene_choice:arc_y5_name_on_line_career_self:2",
    ],
    ("arc_y5_name_on_line_career_self", 3): [
        "terminal_state:c2_unfiled_held",
        "route_terminal:career:m57:3",
        "scene_choice:arc_y5_name_on_line_career_self:3",
    ],
    ("arc_y5_people_verdict_career_hyunsu", 1): [
        "terminal_state:result_first_conversation_shortened",
        "route_terminal:career:m58:1",
        "scene_choice:arc_y5_people_verdict_career_hyunsu:1",
    ],
    ("arc_y5_people_verdict_career_hyunsu", 2): [
        "terminal_state:player_must_write_boundary",
        "route_terminal:career:m58:2",
        "scene_choice:arc_y5_people_verdict_career_hyunsu:2",
    ],
    ("arc_y5_contract_execution_career", 1): [
        "terminal_state:offer_rejected_unexecuted",
        "terminal_document:C2:rejected_unexecuted",
        "route_terminal:career:m59:1",
        "scene_choice:arc_y5_contract_execution_career:1",
    ],
    ("arc_y5_contract_execution_career", 2): [
        "terminal_state:resigned_settled_badge_returned_c2_unexecuted",
        "job_transition:quit_bound_current_job",
        "badge:bound_job_badge_returned",
        "cash:settlement_from_runtime_document",
        "terminal_document:C2:unexecuted_due_to_resignation",
        "route_terminal:career:m59:2",
        "scene_choice:arc_y5_contract_execution_career:2",
    ],
    ("arc_y5_startup_boundary_cofounder", 3): [
        "terminal_state:joint_warranty_rejected_no_extension",
        "route_terminal:startup:m50:3",
        "scene_choice:arc_y5_startup_boundary_cofounder:3",
    ],
    ("arc_y5_startup_final_offer_acquirer", 3): [
        "terminal_state:discussion_ended_no_draft_received",
        "route_terminal:startup:m52:3",
        "scene_choice:arc_y5_startup_final_offer_acquirer:3",
    ],
    ("arc_y5_startup_three_in_room_decision", 1): [
        "terminal_state:product_package_draft_unsigned",
        "route_terminal:startup:m55:1",
        "scene_choice:arc_y5_startup_three_in_room_decision:1",
    ],
    ("arc_y5_startup_three_in_room_decision", 2): [
        "terminal_state:people_package_draft_unsigned",
        "route_terminal:startup:m55:2",
        "scene_choice:arc_y5_startup_three_in_room_decision:2",
    ],
    ("arc_y5_startup_c2_sign_self", 1): [
        "terminal_state:date_mismatch_rework",
        "route_terminal:startup:m57:1",
        "scene_choice:arc_y5_startup_c2_sign_self:1",
    ],
    ("arc_y5_startup_c2_sign_self", 2): [
        "terminal_state:deferred_48h",
        "route_terminal:startup:m57:2",
        "scene_choice:arc_y5_startup_c2_sign_self:2",
    ],
    ("arc_y5_startup_c2_sign_self", 3): [
        "terminal_state:withdrawn_20pct_retained",
        "route_terminal:startup:m57:3",
        "scene_choice:arc_y5_startup_c2_sign_self:3",
    ],
    ("arc_y5_startup_people_verdict_cofounder", 1): [
        "terminal_state:notice_assigned_acquirer",
        "route_terminal:startup:m58:1",
        "scene_choice:arc_y5_startup_people_verdict_cofounder:1",
    ],
    ("arc_y5_startup_people_verdict_cofounder", 2): [
        "terminal_state:joint_explanation_required",
        "route_terminal:startup:m58:2",
        "scene_choice:arc_y5_startup_people_verdict_cofounder:2",
    ],
    ("arc_y5_startup_contract_execution_c3", 1): [
        "terminal_state:closing_stopped_date_mismatch",
        "route_terminal:startup:m59:1",
        "scene_choice:arc_y5_startup_contract_execution_c3:1",
    ],
    ("arc_y5_startup_contract_execution_c3", 2): [
        "terminal_state:sale_cancelled_20pct_retained",
        "route_terminal:startup:m59:2",
        "scene_choice:arc_y5_startup_contract_execution_c3:2",
    ],
}

EXPECTED_FINALE_HANDOFFS = {
    "career_reference_v1": {
        "failure_endings": "immediate canonical evaluation",
        "success_endings": "held while finale_state=pending",
        "release": "final-week complete writes finale_state=ready; connected MainGame listener invokes canonical check_game_over once",
    },
    "startup_acquisition_reference_v1": {
        "failure_endings": "immediate canonical evaluation",
        "success_endings": "held while finale_state=pending",
        "release": "final-week complete writes finale_state=ready; connected MainGame listener invokes canonical check_game_over once",
        "legacy_without_ledger": "immediate canonical evaluation",
    },
}

OTHER_CHOICES_EFFECT = (
    "zero effect on this reference transaction only; "
    "terminal choice-specific writes remain authoritative"
)

EXPECTED_CRITICAL_CHOICE_WRITES = {
    "transaction:tx.career_reference_v1.m59.choice_0": {
        ("arc_y5_contract_execution_career", 0)
    },
    "document:C3:executed:TF-C3-EXEC": {
        ("arc_y5_contract_execution_career", 0)
    },
    "transaction:tx.startup_acquisition_reference_v1.m59.choice_0.sa20_5c20": {
        ("arc_y5_startup_contract_execution_c3", 0)
    },
    "document:h3:5C20:executed": {
        ("arc_y5_startup_contract_execution_c3", 0)
    },
    "finale_state:pending": {
        ("arc_y5_contract_execution_career", 0),
        ("arc_y5_startup_contract_execution_c3", 0),
    },
    "finale_state:ready": {
        ("arc_y5_final_week_hyunsu_career_outbound", 0),
        ("arc_y5_final_week_hyunsu_career_outbound", 1),
        ("arc_y5_final_week_hyunsu_career_outbound", 2),
        ("arc_y5_final_week_startup_after_acquisition", 0),
        ("arc_y5_final_week_startup_after_acquisition", 1),
        ("arc_y5_final_week_startup_after_acquisition", 2),
    },
}

EXPECTED_DOCUMENT_LINEAGES = {
    "career_reference_v1": {
        "lineage_id": "career_tf_clawback",
        "versions": [
            {
                "version": "C0",
                "document_id": "TF-12-C0",
                "hash": "8F2C71A0",
                "title_ko": "신규사업 TF 책임자 발령·교육비 환수 부속합의 C0",
                "title_en": "NEW-BUSINESS TF LEAD APPOINTMENT AND TRAINING-COST CLAWBACK ADDENDUM C0",
                "fields": {
                    "term_months": 12,
                    "monthly_allowance_krw": 450000,
                    "early_exit_training_clawback_krw": 6000000,
                    "external_reviewer": None,
                    "approval_business_days_without_external_name": 15,
                    "approval_business_days_with_external_name": 5,
                },
                "producer_root": "arc_y5_contract_cover_career",
            },
            {
                "version": "C1",
                "document_id": None,
                "hash": None,
                "fields": {
                    "appointment_delay_business_days": 10,
                    "monthly_allowance_krw": 300000,
                    "tf_budget_change_percent": -20,
                    "selected": False,
                    "signed": False,
                },
                "producer_root": "arc_y5_final_offer_career_boss",
            },
            {
                "version": "C2",
                "document_id": "TF-C2-SELF",
                "hash": None,
                "fields": {
                    "monthly_allowance_krw": 300000,
                    "clawback_term_months": 12,
                    "clawback_end_date_rule": "execution_effective_at_plus_12_months",
                    "external_reviewer": "NOT USED",
                    "signature_scope": "SELF ONLY",
                    "filed": True,
                },
                "draft_producer": {
                    "root_id": "arc_y5_three_in_room_decision_career",
                    "choice_index": 0,
                },
                "filing_producer": {
                    "root_id": "arc_y5_name_on_line_career_self",
                    "choice_index": 1,
                },
            },
            {
                "version": "C3",
                "document_id": "TF-C3-EXEC",
                "hash": None,
                "fields": {
                    "setup_deposit_krw": 300000,
                    "monthly_allowance_krw": 300000,
                    "execution_effective_at": "transaction_committed_turn",
                    "clawback_term_months": 12,
                    "clawback_end_date_rule": "execution_effective_at_plus_12_months",
                    "external_reviewer": "NOT USED",
                    "signature_scope": "SELF ONLY",
                    "active_badge": "new_tf_badge",
                    "old_badge_return_confirmed": True,
                    "executed": True,
                },
                "producer_root": "arc_y5_contract_execution_career",
                "producer_choice_index": 0,
            },
        ],
    },
    "startup_acquisition_reference_v1": {
        "lineage_id": "SA-20",
        "versions": [
            {
                "version": "h0",
                "document_id": "SA-20",
                "hash": "A6E8",
                "title_ko": "주식 20% 인수 비구속 의향서",
                "title_en": "NON-BINDING LOI FOR ACQUISITION OF 20% EQUITY",
                "issued_at": "Jan 8 09:40",
                "expires_after_days": 7,
                "fields": {
                    "valuation_krw": 16000000000,
                    "equity_basis_points": 2000,
                    "price_krw": 3200000000,
                    "joint_warranty": None,
                    "team_annex_date": None,
                    "service_annex_date": None,
                    "signed": False,
                    "paid": False,
                    "transferred": False,
                },
                "producer_root": "arc_y5_startup_offer_c0",
            },
            {
                "version": "h1",
                "document_id": "SA-20",
                "hash": "91B4",
                "fields": {
                    "price_krw": 3200000000,
                    "packages": {
                        "time": {
                            "player_months": 12,
                            "team_months": 12,
                            "service_months": 12,
                        },
                        "product": {
                            "player_days": 90,
                            "team_months": 12,
                            "service_days": 90,
                        },
                        "people": {
                            "player_days": 90,
                            "team_days": 90,
                            "service_months": 12,
                        },
                    },
                },
                "producer_root": "arc_y5_startup_final_offer_acquirer",
            },
            {
                "version": "h2",
                "document_id": "SA-20",
                "hash": "D772",
                "fields": {
                    "selected_package": "time",
                    "cofounder_warranty": "NOT USED",
                    "signature_pages": "SEPARATE SELLER PAGES",
                    "player_months": 12,
                    "team_months": 12,
                    "service_months": 12,
                },
                "draft_producer": {
                    "root_id": "arc_y5_startup_three_in_room_decision",
                    "choice_index": 0,
                },
                "filing_producer": {
                    "root_id": "arc_y5_startup_c2_sign_self",
                    "choice_index": 0,
                },
                "filed_copy_delivery_producer": {
                    "root_id": "arc_y5_startup_c2_copy_delivered_cofounder",
                    "choice_index": 0,
                },
            },
            {
                "version": "h3",
                "document_id": "SA-20",
                "hash": "5C20",
                "fields": {
                    "price_krw": 3200000000,
                    "equity_basis_points_before": 2000,
                    "equity_basis_points_after": 0,
                    "seal_and_admin_token_transferred": True,
                    "account_shutdown": True,
                    "transition_badge_active": True,
                    "periods_started": True,
                    "executed": True,
                },
                "execution_producer": {
                    "root_id": "arc_y5_startup_contract_execution_c3",
                    "choice_index": 0,
                },
                "result_delivery_producer": {
                    "root_id": "arc_y5_startup_c3_copy_delivered_cofounder",
                    "choice_index": 0,
                },
            },
        ],
    },
}

EXPECTED_PLANNED_TRANSACTIONS = {
    "career_reference_v1": {
        "transaction_id": "tx.career_reference_v1.m59.choice_0",
        "trigger": {
            "root_id": "arc_y5_contract_execution_career",
            "choice_index": 0,
        },
        "idempotency": "apply once; replay and save/load re-entry are successful no-ops",
        "atomic_writes": {
            "cash_delta_krw": 300000,
            "document_version": "C3",
            "execution_effective_at": "committed_turn",
            "job_transition": {
                "kind": "same_employer_role_change",
                "from": "bound_current_job",
                "to": "new_business_tf_lead",
                "to_is_surface_role_not_actor_id": True,
                "preserve_bound_job_id": True,
                "monthly_income_delta_krw": 300000,
                "apply_together": ["current_job", "monthly_income", "flags.has_job"],
                "runtime_owner": None,
            },
            "active_badge": "new_tf_badge",
            "old_badge_return_confirmed": True,
            "finale_state": "pending",
        },
        "other_choices_effect": OTHER_CHOICES_EFFECT,
    },
    "startup_acquisition_reference_v1": {
        "transaction_id": "tx.startup_acquisition_reference_v1.m59.choice_0.sa20_5c20",
        "trigger": {
            "root_id": "arc_y5_startup_contract_execution_c3",
            "choice_index": 0,
        },
        "idempotency": "apply once; replay and save/load re-entry are successful no-ops",
        "atomic_writes": {
            "cash_delta_krw": 3200000000,
            "equity_basis_points_before": 2000,
            "equity_basis_points_after": 0,
            "document_version": "h3",
            "flag": "startup_exit",
            "finale_state": "pending",
        },
        "separate_required_delivery_receipt": "arc_y5_startup_c3_copy_delivered_cofounder:0",
        "other_choices_effect": OTHER_CHOICES_EFFECT,
    },
}

RUNTIME_FORBIDDEN_TOKENS = (
    *ALL_TARGET_IDS,
    MANIFEST_PATH.relative_to(ROOT).as_posix(),
    EXPECTED_MANIFEST_ID,
    *EXPECTED_ROUTE_IDS,
)

# These are causal receipts, not prose summaries.  A downstream root may add
# more local requirements/writes, but it may not abbreviate or omit these exact
# upstream facts.
REQUIRED_ROOT_TOKENS: dict[str, dict[str, list[str]]] = {
    "arc_y5_startup_offer_c0": {
        "common_writes": ["actor_binding:acquirer_lead"],
    },
    "arc_y5_protection_boundary_hyunsu_career": {
        "common_writes": ["receipt:career_name_boundary_drawn"],
    },
    "arc_y5_minseo_goal_cost_career": {
        "requirements": ["document:C0", "receipt:career_name_boundary_drawn"],
        "document_reads": ["C0"],
    },
    "arc_y5_after_goal_hyunsu_career": {
        "requirements": ["document:C0", "receipt:career_name_boundary_drawn"],
        "document_reads": ["C0"],
    },
    "arc_y5_final_offer_career_boss": {
        "requirements": ["document:C0", "receipt:career_name_boundary_drawn"],
        "common_writes": ["document:C1"],
    },
    "arc_y5_name_on_line_career_self": {
        "requirements": ["document:C2:draft:self_only"],
    },
    "arc_y5_name_copy_delivered_hyunsu_career": {
        "requirements": ["document:C2:filed:TF-C2-SELF"],
        "common_writes": ["receipt:C2_copy_delivered_to_hyunsu"],
    },
    "arc_y5_people_verdict_career_hyunsu": {
        "requirements": ["receipt:C2_copy_delivered_to_hyunsu"],
    },
    "arc_y5_contract_execution_career": {
        "requirements": ["receipt:career_primary_witness_heard", "document:C2:filed:TF-C2-SELF"],
    },
    "arc_y5_contract_result_delivered_hyunsu_career": {
        "requirements": ["transaction:tx.career_reference_v1.m59.choice_0", "document:C3"],
        "common_writes": ["receipt:C3_copy_delivered_to_hyunsu"],
    },
    "arc_final_countdown_career_executed": {
        "requirements": ["receipt:C3_copy_delivered_to_hyunsu", "finale_state:pending"],
        "common_writes": ["receipt:arc_final_countdown_career_executed_completed"],
    },
    "arc_y5_final_week_hyunsu_career_outbound": {
        "requirements": [
            "receipt:arc_final_countdown_career_executed_completed",
            "finale_state:pending",
        ],
    },
    "arc_y5_startup_minseo_goal_cost": {
        "requirements": ["document:h0:A6E8", "receipt:startup_boundary_0|1|2"],
        "document_reads": ["h0"],
    },
    "arc_y5_startup_after_goal_cofounder": {
        "requirements": ["document:h0:A6E8", "receipt:startup_boundary_0|1|2"],
        "document_reads": ["h0"],
    },
    "arc_y5_startup_final_offer_acquirer": {
        "requirements": [
            "document:h0:A6E8",
            "receipt:startup_boundary_0|1|2",
            "actor:acquirer_lead",
        ],
        "common_writes": ["document:h1:91B4"],
    },
    "arc_y5_startup_c2_sign_self": {
        "requirements": ["document:h2:D772:draft"],
    },
    "arc_y5_startup_c2_copy_delivered_cofounder": {
        "requirements": ["document:h2:D772:filed"],
        "common_writes": ["receipt:h2_copy_delivered_to_cofounder"],
    },
    "arc_y5_startup_people_verdict_cofounder": {
        "requirements": ["receipt:h2_copy_delivered_to_cofounder"],
    },
    "arc_y5_startup_contract_execution_c3": {
        "requirements": [
            "receipt:startup_primary_witness_heard",
            "document:h2:D772:filed",
            "receipt:cofounder_separate_seller_page_returned",
        ],
    },
    "arc_y5_startup_c3_copy_delivered_cofounder": {
        "requirements": [
            "transaction:tx.startup_acquisition_reference_v1.m59.choice_0.sa20_5c20",
            "document:h3:5C20",
        ],
        "common_writes": ["receipt:h3_copy_delivered_to_cofounder"],
    },
    "arc_final_countdown_startup_executed": {
        "requirements": ["receipt:h3_copy_delivered_to_cofounder", "finale_state:pending"],
        "common_writes": ["receipt:arc_final_countdown_startup_executed_completed"],
    },
    "arc_y5_final_week_startup_after_acquisition": {
        "requirements": [
            "receipt:arc_final_countdown_startup_executed_completed",
            "finale_state:pending",
        ],
    },
}

REQUIRED_CHOICE_WRITES: dict[str, dict[int, list[str]]] = {
    "arc_y5_three_in_room_decision_career": {
        0: ["document:C2:draft:self_only"],
    },
    "arc_y5_name_on_line_career_self": {
        1: ["document:C2:filed:TF-C2-SELF"],
    },
    "arc_y5_people_verdict_career_hyunsu": {
        0: ["receipt:career_primary_witness_heard"],
    },
    "arc_y5_contract_execution_career": {
        0: [
            "transaction:tx.career_reference_v1.m59.choice_0",
            "document:C3:executed:TF-C3-EXEC",
            "finale_state:pending",
        ],
    },
    "arc_y5_startup_three_in_room_decision": {
        0: ["document:h2:D772:draft"],
    },
    "arc_y5_startup_c2_sign_self": {
        0: ["document:h2:D772:filed", "receipt:conditional_seller_filing"],
    },
    "arc_y5_startup_c2_copy_delivered_cofounder": {
        0: ["receipt:cofounder_separate_seller_page_returned"],
    },
    "arc_y5_startup_people_verdict_cofounder": {
        0: ["receipt:startup_primary_witness_heard"],
    },
    "arc_y5_startup_contract_execution_c3": {
        0: [
            "transaction:tx.startup_acquisition_reference_v1.m59.choice_0.sa20_5c20",
            "document:h3:5C20:executed",
            "finale_state:pending",
        ],
    },
}

EXPECTED_VERSION_PRODUCERS = {
    "career_reference_v1": {
        "c0": ["arc_y5_contract_cover_career"],
        "c1": ["arc_y5_final_offer_career_boss"],
        "c2": [
            "arc_y5_three_in_room_decision_career",
            "arc_y5_name_on_line_career_self",
        ],
        "c3": ["arc_y5_contract_execution_career"],
    },
    "startup_acquisition_reference_v1": {
        "h0": ["arc_y5_startup_offer_c0"],
        "h1": ["arc_y5_startup_final_offer_acquirer"],
        "h2": [
            "arc_y5_startup_three_in_room_decision",
            "arc_y5_startup_c2_sign_self",
            "arc_y5_startup_c2_copy_delivered_cofounder",
        ],
        "h3": [
            "arc_y5_startup_contract_execution_c3",
            "arc_y5_startup_c3_copy_delivered_cofounder",
        ],
    },
}

EXPECTED_COMMITMENT_COUNTS = {
    49: 2,
    50: 1,
    51: 2,
    52: 1,
    53: 0,
    54: 1,
    55: 2,
    56: 0,
    57: 2,
    58: 1,
    59: 2,
    60: 1,
}

EXPECTED_COMMITMENTS = {
    49: ["m49_open_path_contract", "m49_choose_reviewer"],
    50: ["m50_draw_name_boundary"],
    51: ["m51_hear_minseo", "m51_ask_after_goal"],
    52: ["m52_hear_live_proposer"],
    53: [],
    54: ["m54_hear_chosen_reviewer"],
    55: ["m55_disclose_all_terms", "m55_let_reviewer_question"],
    56: [],
    57: ["m57_file_name_decision", "m57_deliver_filed_copy"],
    58: ["m58_hear_primary_witness"],
    59: ["m59_execute_contract_result", "m59_deliver_result_to_affected_person"],
    60: ["m60_sign_own_answer"],
}

EXPECTED_MARGINS = {
    49: ({"axis": "trust", "producer": "future:m48_tell_surviving_person"}, None),
    50: (None, {"axis": "trust", "producer": "m50_draw_name_boundary"}),
    51: ({"axis": "trust", "producer": "m50_draw_name_boundary"}, None),
    52: (None, {"axis": "cash", "producer": "m52_hear_live_proposer"}),
    53: ({"axis": "cash", "producer": "m52_hear_live_proposer"}, None),
    54: (None, {"axis": "trust", "producer": "m54_hear_chosen_reviewer"}),
    55: ({"axis": "trust", "producer": "m54_hear_chosen_reviewer"}, None),
    56: (None, None),
    57: ({"axis": "trust", "producer": "unresolved:M56"}, None),
    58: (None, {"axis": "trust", "producer": "m58_hear_primary_witness"}),
    59: ({"axis": "trust", "producer": "m58_hear_primary_witness"}, None),
    60: (None, None),
}

HEX_64 = re.compile(r"^[0-9a-f]{64}$")
MONTH_RE = re.compile(r"^M?(\d+)$", re.IGNORECASE)
TEXT_SUFFIXES = {".gd", ".tscn", ".tres", ".godot", ".cfg", ".json"}
SKIP_SCAN_DIRS = {".git", ".codex", "docs", "tools", "tests", "test", "reports"}


class DuplicateKeyError(ValueError):
    """Raised when strict JSON encounters the same object key twice."""


def reject_duplicate_keys(pairs: list[tuple[str, Any]]) -> dict[str, Any]:
    result: dict[str, Any] = {}
    for key, value in pairs:
        if key in result:
            raise DuplicateKeyError(f"duplicate JSON key {key!r}")
        result[key] = value
    return result


def strict_loads(text: str, owner: str) -> Any:
    try:
        return json.loads(text, object_pairs_hook=reject_duplicate_keys)
    except (json.JSONDecodeError, DuplicateKeyError) as exc:
        raise ValueError(f"{owner}: invalid strict JSON ({exc})") from exc


def load_json(path: Path) -> Any:
    return strict_loads(path.read_text(encoding="utf-8"), str(path.relative_to(ROOT)))


def canonical_json_sha256(value: Any) -> str:
    payload = json.dumps(
        value,
        sort_keys=True,
        separators=(",", ":"),
        ensure_ascii=False,
    ).encode("utf-8")
    return hashlib.sha256(payload).hexdigest()


def byte_sha256(payload: bytes) -> str:
    return hashlib.sha256(payload).hexdigest()


def exact_keys(value: Any, expected: set[str], owner: str, errors: list[str]) -> bool:
    if not isinstance(value, dict):
        errors.append(f"{owner}: must be an object")
        return False
    actual = set(value)
    if actual != expected:
        errors.append(
            f"{owner}: keys mismatch missing={sorted(expected - actual)} "
            f"extra={sorted(actual - expected)}"
        )
        return False
    return True


def scalar_strings(value: Any) -> list[str]:
    result: list[str] = []
    if isinstance(value, dict):
        for key, child in value.items():
            result.append(str(key))
            result.extend(scalar_strings(child))
    elif isinstance(value, list):
        for child in value:
            result.extend(scalar_strings(child))
    elif value is not None:
        result.append(str(value))
    return result


def flattened(value: Any) -> str:
    return " ".join(scalar_strings(value)).lower()


def iter_dicts(value: Any) -> Iterator[dict[str, Any]]:
    if isinstance(value, dict):
        yield value
        for child in value.values():
            yield from iter_dicts(child)
    elif isinstance(value, list):
        for child in value:
            yield from iter_dicts(child)


def normalized_month(value: Any) -> int | str | None:
    if isinstance(value, int) and not isinstance(value, bool):
        return value
    if isinstance(value, str):
        lowered = value.strip().lower().replace("-", "_")
        if lowered in {"final_week", "finalweek", "aftermath"}:
            return "final_week"
        match = MONTH_RE.fullmatch(value.strip())
        if match:
            return int(match.group(1))
    return None


def list_of_ints(value: Any, owner: str, errors: list[str]) -> list[int]:
    if not isinstance(value, list):
        errors.append(f"{owner}: must be an array")
        return []
    if any(not isinstance(item, int) or isinstance(item, bool) for item in value):
        errors.append(f"{owner}: must contain only integer choice indices")
        return []
    return list(value)


def list_length(value: Any) -> int | None:
    return len(value) if isinstance(value, list) else None


@dataclass
class EventRecord:
    path: str
    row: dict[str, Any]


@dataclass
class AuditContext:
    event_indexes: dict[str, dict[str, list[EventRecord]]]
    runtime_sources: list[tuple[str, str]]


def event_rows(payload: Any, owner: str, errors: list[str]) -> list[dict[str, Any]]:
    rows = payload.get("items", []) if isinstance(payload, dict) else payload
    if not isinstance(rows, list):
        errors.append(f"{owner}: event file must be an array or items object")
        return []
    result: list[dict[str, Any]] = []
    for index, row in enumerate(rows):
        if not isinstance(row, dict):
            errors.append(f"{owner}[{index}]: event must be an object")
            continue
        result.append(row)
    return result


def build_event_indexes(errors: list[str]) -> dict[str, dict[str, list[EventRecord]]]:
    result: dict[str, dict[str, list[EventRecord]]] = {"ko": {}, "en": {}}
    for locale, directory in EVENT_DIRS.items():
        for path in sorted(directory.glob("*.json")):
            relative = path.relative_to(ROOT).as_posix()
            try:
                payload = load_json(path)
            except (OSError, ValueError) as exc:
                errors.append(str(exc))
                continue
            for row in event_rows(payload, relative, errors):
                event_id = str(row.get("id", "")).strip()
                if not event_id:
                    continue
                result[locale].setdefault(event_id, []).append(EventRecord(relative, row))
    return result


def production_runtime_sources(errors: list[str]) -> list[tuple[str, str]]:
    sources: list[tuple[str, str]] = []
    for path in sorted(ROOT.rglob("*")):
        if not path.is_file() or path.suffix not in TEXT_SUFFIXES:
            continue
        relative = path.relative_to(ROOT)
        if any(part in SKIP_SCAN_DIRS for part in relative.parts):
            continue
        rel = relative.as_posix()
        if rel == MANIFEST_PATH.relative_to(ROOT).as_posix():
            continue
        if rel.startswith("content/events/") or rel.startswith("content/events_en/"):
            try:
                payload = load_json(path)
            except (OSError, ValueError) as exc:
                errors.append(str(exc))
                continue
            rows = event_rows(payload, rel, errors)
            non_target = [row for row in rows if str(row.get("id", "")) not in ALL_TARGET_ID_SET]
            sources.append((f"{rel}#non_target_objects", json.dumps(non_target, ensure_ascii=False)))
            continue
        try:
            sources.append((rel, path.read_text(encoding="utf-8")))
        except (OSError, UnicodeDecodeError) as exc:
            errors.append(f"{rel}: cannot scan production source ({exc})")
    return sources


def build_context() -> tuple[AuditContext, list[str]]:
    errors: list[str] = []
    indexes = build_event_indexes(errors)
    sources = production_runtime_sources(errors)
    return AuditContext(indexes, sources), errors


def expected_partition(route_id: str, spec: RootSpec) -> dict[str, list[int]]:
    all_indices = list(range(spec.choice_count))
    if spec.event_id.startswith("arc_y5_final_week_"):
        return {"continuation": [], "terminal": [], "complete": all_indices}

    continuation = all_indices
    if route_id == "career_reference_v1":
        special = {
            "arc_y5_three_in_room_decision_career": [0],
            "arc_y5_name_on_line_career_self": [1],
            "arc_y5_people_verdict_career_hyunsu": [0],
            "arc_y5_contract_execution_career": [0],
        }
        continuation = special.get(spec.event_id, all_indices)
    else:
        special = {
            "arc_y5_startup_boundary_cofounder": [0, 1, 2],
            "arc_y5_startup_final_offer_acquirer": [0, 1, 2],
            "arc_y5_startup_three_in_room_decision": [0],
            "arc_y5_startup_c2_sign_self": [0],
            "arc_y5_startup_people_verdict_cofounder": [0],
            "arc_y5_startup_contract_execution_c3": [0],
        }
        continuation = special.get(spec.event_id, all_indices)
    terminal = [index for index in all_indices if index not in continuation]
    return {"continuation": continuation, "terminal": terminal, "complete": []}


def actor_id(value: Any) -> str:
    if isinstance(value, str):
        return value
    if isinstance(value, dict):
        for key in ("actor_id", "id", "value", "binding"):
            candidate = value.get(key)
            if isinstance(candidate, str):
                return candidate
    return ""


def role_actor_map(actors: Any) -> dict[str, str]:
    result: dict[str, str] = {}
    if isinstance(actors, dict):
        for role, binding in actors.items():
            candidate = actor_id(binding)
            if candidate:
                result[str(role)] = candidate
        bindings = actors.get("bindings")
        if isinstance(bindings, list):
            actors = bindings
        else:
            return result
    if isinstance(actors, list):
        for binding in actors:
            if not isinstance(binding, dict):
                continue
            role = str(binding.get("role", binding.get("actor_role", "")))
            candidate = actor_id(binding)
            if role and candidate:
                result[role] = candidate
    return result


def month_row(route: dict[str, Any], month: int) -> dict[str, Any] | None:
    rows = route.get("months", [])
    if not isinstance(rows, list):
        return None
    matches = [row for row in rows if isinstance(row, dict) and normalized_month(row.get("month")) == month]
    return matches[0] if len(matches) == 1 else None


def route_map(manifest: dict[str, Any]) -> dict[str, dict[str, Any]]:
    routes = manifest.get("routes", [])
    if not isinstance(routes, list):
        return {}
    return {
        str(route.get("route_id", "")): route
        for route in routes
        if isinstance(route, dict) and str(route.get("route_id", ""))
    }


def validate_surface(manifest: Any, errors: list[str]) -> dict[str, dict[str, Any]]:
    if not exact_keys(manifest, TOP_LEVEL_KEYS, "manifest", errors):
        return {}
    assert isinstance(manifest, dict)
    if manifest.get("schema_version") != 1:
        errors.append("manifest.schema_version: expected integer 1")
    if manifest.get("manifest_id") != EXPECTED_MANIFEST_ID:
        errors.append(f"manifest.manifest_id: expected {EXPECTED_MANIFEST_ID!r}")
    declaration = str(manifest.get("declaration_commit", ""))
    if declaration != EXPECTED_DECLARATION:
        errors.append(f"manifest.declaration_commit: must identify {EXPECTED_DECLARATION}")
    baseline = str(manifest.get("protected_baseline_commit", ""))
    if baseline != EXPECTED_BASELINE:
        errors.append(f"manifest.protected_baseline_commit: must identify {EXPECTED_BASELINE}")
    if manifest.get("choice_index_base") != 0:
        errors.append("manifest.choice_index_base: must be zero")
    if manifest.get("activation") != "reference_only":
        errors.append("manifest.activation: must remain reference_only (mapped/live is forbidden)")
    if manifest.get("reachability_claim") is not False:
        errors.append("manifest.reachability_claim: must be false")
    if manifest.get("runtime_owner") is not None:
        errors.append("manifest.runtime_owner: must be JSON null")
    scope = manifest.get("scope")
    if exact_keys(scope, SCOPE_KEYS, "manifest.scope", errors):
        assert isinstance(scope, dict)
        expected_scope_values = {
            "months": list(range(49, 61)),
            "route_ids": list(EXPECTED_ROUTE_IDS),
            "expected_route_count": 2,
            "expected_root_count_per_route": 16,
            "expected_choice_count_per_route": 43,
            "expected_root_count_total": 32,
            "expected_choice_count_total": 86,
        }
        for key, expected_value in expected_scope_values.items():
            if scope.get(key) != expected_value:
                errors.append(f"manifest.scope.{key}: expected {expected_value!r}")
        if "property" not in scalar_strings(scope.get("excluded_reference_families")):
            errors.append("manifest.scope: property reference tuple must remain excluded")
        if scope != EXPECTED_SCOPE:
            errors.append("manifest.scope: exact excluded paths/families and R1/R2 live split mismatch")
    receipt_types = manifest.get("receipt_types")
    exact_keys(receipt_types, RECEIPT_TYPE_KEYS, "manifest.receipt_types", errors)
    actor_registry = manifest.get("actor_registry")
    if not isinstance(actor_registry, dict) or list(actor_registry) != list(EXPECTED_ROUTE_IDS):
        errors.append("manifest.actor_registry: expected exact ordered two-route registry")
    if not isinstance(manifest.get("planned_runtime"), dict):
        errors.append("manifest.planned_runtime: must be an object")
    blockers = manifest.get("unresolved_blockers")
    if not isinstance(blockers, (list, dict)) or not blockers:
        errors.append("manifest.unresolved_blockers: must preserve unresolved blockers")

    routes = manifest.get("routes")
    if not isinstance(routes, list):
        errors.append("manifest.routes: must be an array")
        return {}
    ids = [str(route.get("route_id", "")) for route in routes if isinstance(route, dict)]
    if len(routes) != 2 or ids != list(EXPECTED_ROUTE_IDS):
        errors.append(f"manifest.routes: expected exact ordered routes {list(EXPECTED_ROUTE_IDS)}")
    if len(ids) != len(set(ids)):
        errors.append("manifest.routes: duplicate route_id")
    return route_map(manifest)


def validate_route_shape(
    route_id: str,
    route: dict[str, Any],
    errors: list[str],
) -> tuple[list[dict[str, Any]], dict[str, dict[str, Any]]]:
    owner = f"route[{route_id}]"
    exact_keys(route, ROUTE_KEYS, owner, errors)
    expected_path = "career" if route_id == "career_reference_v1" else "startup"
    if route.get("economic_path") != expected_path:
        errors.append(f"{owner}.economic_path: expected {expected_path!r}")
    if route.get("partner") != "none":
        errors.append(f"{owner}.partner: must be 'none'")
    if not isinstance(route.get("entry"), dict):
        errors.append(f"{owner}.entry: must be an object")
    if not isinstance(route.get("exclusions"), list):
        errors.append(f"{owner}.exclusions: must be an array")
    elif route.get("exclusions") != EXPECTED_ROUTE_EXCLUSIONS[route_id]:
        errors.append(f"{owner}.exclusions: exact invalidation/exclusion list mismatch")
    if not isinstance(route.get("document_lineage"), (dict, list)):
        errors.append(f"{owner}.document_lineage: must be an object or array")
    if not isinstance(route.get("planned_transaction"), dict):
        errors.append(f"{owner}.planned_transaction: must be an object")
    if not isinstance(route.get("finale_handoff"), dict):
        errors.append(f"{owner}.finale_handoff: must be an object")
    if not isinstance(route.get("legacy_exclusions"), (list, dict)):
        errors.append(f"{owner}.legacy_exclusions: must be an array or object")
    elif route.get("legacy_exclusions") != EXPECTED_LEGACY_EXCLUSIONS[route_id]:
        errors.append(f"{owner}.legacy_exclusions: exact legacy collision set mismatch")

    entry = route.get("entry", {})
    if isinstance(entry, dict):
        if entry != EXPECTED_ROUTE_ENTRIES[route_id]:
            errors.append(f"{owner}.entry: exact typed entry contract mismatch")
        if route_id == "career_reference_v1":
            exact_keys(
                entry,
                {
                    "required_economic_path",
                    "compatible_job_ids",
                    "required_future_receipts",
                    "route_lock",
                },
                f"{owner}.entry",
                errors,
            )
            expected_receipts = [
                "m48_tell_surviving_person.actor=hyunsu",
                "m48_tell_surviving_person.margin.axis=trust",
                "m49_route_selected=career_reference_v1",
            ]
            if entry.get("required_future_receipts") != expected_receipts:
                errors.append(f"{owner}.entry.required_future_receipts: exact career provenance mismatch")
            jobs = entry.get("compatible_job_ids")
            if not isinstance(jobs, list) or not jobs or len(jobs) != len(set(jobs)):
                errors.append(f"{owner}.entry.compatible_job_ids: unique non-empty canonical jobs required")
        else:
            exact_keys(
                entry,
                {
                    "required_economic_path",
                    "required_origin_receipt",
                    "required_absent_flags",
                    "required_future_receipts",
                    "route_lock",
                    "legacy_save_policy",
                },
                f"{owner}.entry",
                errors,
            )
            if entry.get("required_origin_receipt") != {
                "flag": "startup_founded",
                "initial_cash_delta_krw": -3000000,
                "initial_equity_basis_points": 2000,
                "cofounder_actor_required": True,
            }:
                errors.append(f"{owner}.entry.required_origin_receipt: exact 3M/20% founding receipt required")
            if entry.get("required_absent_flags") != [
                "startup_exit",
                "startup_partial_exit",
                "startup_going_solo",
                "joined_startup",
            ]:
                errors.append(f"{owner}.entry.required_absent_flags: exact mutual exclusions required")
            expected_receipts = [
                "m48_tell_surviving_person.actor=startup_cofounder",
                "m48_tell_surviving_person.margin.axis=trust",
                "m49_route_selected=startup_acquisition_reference_v1",
            ]
            if entry.get("required_future_receipts") != expected_receipts:
                errors.append(f"{owner}.entry.required_future_receipts: exact startup provenance mismatch")
            if entry.get("legacy_save_policy") != "fail_closed_without_durable_mode":
                errors.append(f"{owner}.entry.legacy_save_policy: must fail closed")
        if entry.get("required_economic_path") != expected_path:
            errors.append(f"{owner}.entry.required_economic_path: expected {expected_path!r}")
        route_lock = entry.get("route_lock")
        if route_lock != {
            "producer_month": 49,
            "value": route_id,
            "silent_priority": False,
        }:
            errors.append(f"{owner}.entry.route_lock: exact M49 explicit selection required")

    roots = route.get("roots")
    if not isinstance(roots, list):
        errors.append(f"{owner}.roots: must be an array")
        roots = []
    roots_by_id: dict[str, dict[str, Any]] = {}
    for index, row in enumerate(roots):
        if not isinstance(row, dict):
            errors.append(f"{owner}.roots[{index}]: must be an object")
            continue
        event_id = str(row.get("id", ""))
        if not event_id or event_id in roots_by_id:
            errors.append(f"{owner}.roots[{index}]: missing or duplicate id {event_id!r}")
        else:
            roots_by_id[event_id] = row
    return roots, roots_by_id


def validate_actors(
    manifest: dict[str, Any],
    route_id: str,
    route: dict[str, Any],
    errors: list[str],
) -> None:
    owner = f"route[{route_id}]"
    route_actor_ref = route.get("actors")
    if not exact_keys(
        route_actor_ref,
        {"registry_ref", "required_roles"},
        f"{owner}.actors",
        errors,
    ):
        route_actor_ref = {}
    assert isinstance(route_actor_ref, dict)
    if route_actor_ref.get("registry_ref") != route_id:
        errors.append(f"{owner}.actors.registry_ref: expected {route_id!r}")
    expected_roles = list(EXPECTED_ACTORS[route_id])
    if route_actor_ref.get("required_roles") != expected_roles:
        errors.append(f"{owner}.actors.required_roles: exact role order mismatch")

    actor_registry = manifest.get("actor_registry", {})
    registry_row = (
        actor_registry.get(route_id, {}) if isinstance(actor_registry, dict) else {}
    )
    expected_registry_keys = {
        "bindings",
        "distinct_role_groups",
        "invalidations",
        "surface_aliases_not_actor_ids",
    } if route_id == "career_reference_v1" else {
        "bindings",
        "distinct_role_groups",
        "invalidations",
        "inference_forbidden",
    }
    exact_keys(registry_row, expected_registry_keys, f"manifest.actor_registry[{route_id}]", errors)
    bindings = role_actor_map(
        registry_row.get("bindings") if isinstance(registry_row, dict) else {}
    )
    expected = EXPECTED_ACTORS[route_id]
    for role, expected_id in expected.items():
        actual = bindings.get(role)
        if actual != expected_id:
            errors.append(f"{owner}.actors.{role}: expected actor_id {expected_id!r}, got {actual!r}")
    distinct = {
        bindings.get("proposer", ""),
        bindings.get("reviewer", ""),
        bindings.get("protected", ""),
    }
    if "" in distinct or len(distinct) != 3:
        errors.append(f"{owner}.actors: proposer/reviewer/protected must be three distinct actors")
    actor_values = {value for value in bindings.values() if value}
    if "team_lead" in actor_values:
        errors.append(f"{owner}.actors: team_lead is a surface title, not a canonical actor ID")

    raw_bindings = registry_row.get("bindings", {}) if isinstance(registry_row, dict) else {}
    if not isinstance(raw_bindings, dict) or set(raw_bindings) != set(expected):
        errors.append(f"{owner}.actors.bindings: exact six-role registry required")
    elif isinstance(raw_bindings, dict):
        for role, binding in raw_bindings.items():
            binding_owner = f"{owner}.actors.bindings.{role}"
            if not exact_keys(binding, {"actor_id", "source", "required"}, binding_owner, errors):
                continue
            assert isinstance(binding, dict)
            if binding.get("source") != EXPECTED_ACTOR_SOURCES[route_id][role]:
                errors.append(f"{binding_owner}.source: exact provenance mismatch")
            if binding.get("required") is not True:
                errors.append(f"{binding_owner}.required: must be true")
    if registry_row.get("distinct_role_groups") != EXPECTED_DISTINCT_ROLE_GROUPS:
        errors.append(f"{owner}.actors.distinct_role_groups: exact partition mismatch")
    if registry_row.get("invalidations") != EXPECTED_INVALIDATIONS[route_id]:
        errors.append(f"{owner}.actors.invalidations: exact invalidation list required")
    if route_id == "career_reference_v1":
        if registry_row.get("surface_aliases_not_actor_ids") != ["team_lead"]:
            errors.append(f"{owner}.actors: team_lead must remain a surface alias only")
    elif registry_row.get("inference_forbidden") != [
        "romance enum",
        "display name",
        "legacy save without durable mode",
    ]:
        errors.append(f"{owner}.actors: startup actor inference-forbidden list drifted")

    actor_text = flattened(registry_row)
    entry_text = flattened(route.get("entry"))
    if route_id == "career_reference_v1":
        for token, label in (
            ("canonical", "boss canonical job-role source"),
            ("literal", "Minseo literal source"),
            ("m48", "Hyunsu M48 receipt source"),
            ("hyunsu", "Hyunsu source"),
        ):
            if token not in actor_text:
                errors.append(f"{owner}.actors: missing {label}")
        for token in ("career", "m48", "hyunsu"):
            if token not in entry_text:
                errors.append(f"{owner}.entry: missing {token!r} entry provenance")
    else:
        for token, label in (
            ("literal", "Minseo literal source"),
            ("c0", "acquirer lead C0 source"),
            ("found", "cofounder founding source"),
        ):
            if token not in actor_text:
                errors.append(f"{owner}.actors: missing {label}")
        for token in ("startup_founded", "20", "startup_exit", "startup_partial_exit", "startup_going_solo", "joined_startup"):
            if token not in entry_text:
                errors.append(f"{owner}.entry: missing {token!r} entry gate")


def validate_months(route_id: str, route: dict[str, Any], errors: list[str]) -> None:
    owner = f"route[{route_id}]"
    rows = route.get("months")
    if not isinstance(rows, list):
        errors.append(f"{owner}.months: must be an array")
        return
    observed = [normalized_month(row.get("month")) for row in rows if isinstance(row, dict)]
    if observed != list(range(49, 61)):
        errors.append(f"{owner}.months: expected exact M49..M60 order, got {observed}")
    for index, row in enumerate(rows):
        if not isinstance(row, dict):
            errors.append(f"{owner}.months[{index}]: must be an object")
            continue
        month = normalized_month(row.get("month"))
        label = f"{owner}.months[{row.get('month')}]"
        exact_keys(row, MONTH_KEYS, label, errors)
        if not isinstance(month, int) or month not in EXPECTED_COMMITMENT_COUNTS:
            continue
        commitments = row.get("selected_commitments")
        expected_count = EXPECTED_COMMITMENT_COUNTS[month]
        if not isinstance(commitments, list) or len(commitments) != expected_count:
            errors.append(f"{label}.selected_commitments: expected {expected_count} entries")
        if commitments != EXPECTED_COMMITMENTS[month]:
            errors.append(
                f"{label}.selected_commitments: expected exact canonical IDs "
                f"{EXPECTED_COMMITMENTS[month]}"
            )
        expected_incoming, expected_outgoing = EXPECTED_MARGINS[month]
        if row.get("incoming_margin") != expected_incoming:
            errors.append(
                f"{label}.incoming_margin: expected exact typed margin {expected_incoming}"
            )
        if row.get("outgoing_margin") != expected_outgoing:
            errors.append(
                f"{label}.outgoing_margin: expected exact typed margin {expected_outgoing}"
            )
        if not isinstance(row.get("root_order"), list):
            errors.append(f"{label}.root_order: must be an array")

    m49 = month_row(route, 49)
    if m49 is None or "m48" not in flattened(m49.get("incoming_margin")):
        errors.append(f"{owner}.M49: incoming same-axis margin must come from an actual M48 receipt")
    if m49 is not None:
        incoming = flattened(m49.get("incoming_margin"))
        if "trust" not in incoming:
            errors.append(f"{owner}.M49: incoming M48 margin axis must be trust")

    for month, token in ((50, "trust"), (52, "cash"), (54, "trust")):
        row = month_row(route, month)
        if row is None or token not in flattened(row.get("outgoing_margin")):
            errors.append(f"{owner}.M{month}: outgoing margin must produce {token}")

    for month in (49, 51, 55, 57, 59):
        row = month_row(route, month)
        if row is None or row.get("outgoing_margin") is not None:
            errors.append(
                f"{owner}.M{month}: optional-second month outgoing_margin must be null"
            )
    m60 = month_row(route, 60)
    if m60 is None or m60.get("incoming_margin") is not None:
        errors.append(f"{owner}.M60: incoming_margin must be null")

    m53 = month_row(route, 53)
    if m53 is None:
        errors.append(f"{owner}.M53: missing month row")
    else:
        if m53.get("fallback_owner") != "generic_month_loop":
            errors.append(f"{owner}.M53: fallback_owner must be generic_month_loop")
        if not m53.get("unresolved"):
            errors.append(f"{owner}.M53: margin-expiry owner must remain unresolved")
        if m53.get("root_order") != []:
            errors.append(f"{owner}.M53: route root_order must stay empty")
        if "jaehyuk" in flattened(m53) or "guarantee" in flattened(m53):
            errors.append(f"{owner}.M53: must not invent a Jaehyuk guarantee action")

    m56 = month_row(route, 56)
    if m56 is None:
        errors.append(f"{owner}.M56: missing month row")
    else:
        if not m56.get("unresolved"):
            errors.append(f"{owner}.M56: M57 margin producer must remain unresolved")
        if m56.get("root_order") != []:
            errors.append(f"{owner}.M56: economic route root_order must stay empty")


def validate_roots(
    route_id: str,
    route: dict[str, Any],
    roots: list[dict[str, Any]],
    roots_by_id: dict[str, dict[str, Any]],
    context: AuditContext,
    outcome_ids: set[str],
    errors: list[str],
) -> None:
    owner = f"route[{route_id}]"
    specs = ROUTE_ROOTS[route_id]
    expected_ids = [spec.event_id for spec in specs]
    observed_ids = [str(row.get("id", "")) for row in roots if isinstance(row, dict)]
    if observed_ids != expected_ids:
        errors.append(f"{owner}.roots: exact order mismatch")
    if len(roots) != 16:
        errors.append(f"{owner}.roots: expected 16 roots, got {len(roots)}")

    expected_orders: list[int] = []
    month_counts: dict[int | str, int] = {}
    for spec in specs:
        month_counts[spec.month] = month_counts.get(spec.month, 0) + 1
        expected_orders.append(month_counts[spec.month])
    order_values = [row.get("order") for row in roots if isinstance(row, dict)]
    if order_values != expected_orders:
        errors.append(
            f"{owner}.roots.order: expected exact within-month order {expected_orders}"
        )

    for spec in specs:
        row = roots_by_id.get(spec.event_id)
        if row is None:
            errors.append(f"{owner}: missing root contract {spec.event_id}")
            continue
        label = f"{owner}.root[{spec.event_id}]"
        exact_keys(row, ROOT_KEYS, label, errors)
        if normalized_month(row.get("month")) != spec.month:
            errors.append(f"{label}.month: expected {spec.month!r}")
        if row.get("choice_count") != spec.choice_count:
            errors.append(f"{label}.choice_count: expected {spec.choice_count}")
        for key in ("requirements", "actor_roles", "document_reads", "common_writes"):
            if not isinstance(row.get(key), list):
                errors.append(f"{label}.{key}: must be an array")
        if row.get("actor_roles") != EXPECTED_ACTOR_ROLES[spec.event_id]:
            errors.append(
                f"{label}.actor_roles: expected exact roles "
                f"{EXPECTED_ACTOR_ROLES[spec.event_id]!r}"
            )
        semantic_view = {key: row.get(key) for key in ROOT_SEMANTIC_DIGEST_KEYS}
        semantic_digest = canonical_json_sha256(semantic_view)
        if semantic_digest != EXPECTED_ROOT_SEMANTIC_DIGESTS[spec.event_id]:
            errors.append(
                f"{label}: canonical semantic digest mismatch "
                f"expected={EXPECTED_ROOT_SEMANTIC_DIGESTS[spec.event_id]} "
                f"got={semantic_digest}"
            )
        causal_contract = REQUIRED_ROOT_TOKENS.get(spec.event_id, {})
        for key, required_values in causal_contract.items():
            actual_values = row.get(key, [])
            for required_value in required_values:
                if not isinstance(actual_values, list) or required_value not in actual_values:
                    errors.append(
                        f"{label}.{key}: missing exact causal token {required_value!r}"
                    )

        partitions = row.get("choice_partitions")
        expected = expected_partition(route_id, spec)
        if exact_keys(partitions, PARTITION_KEYS, f"{label}.choice_partitions", errors):
            assert isinstance(partitions, dict)
            actual_parts: dict[str, list[int]] = {}
            for key in ("continuation", "terminal", "complete"):
                actual_parts[key] = list_of_ints(
                    partitions.get(key), f"{label}.choice_partitions.{key}", errors
                )
            flattened_indices = [index for key in PARTITION_KEYS for index in actual_parts[key]]
            if len(flattened_indices) != len(set(flattened_indices)):
                errors.append(f"{label}.choice_partitions: sets must be disjoint")
            if sorted(flattened_indices) != list(range(spec.choice_count)):
                errors.append(f"{label}.choice_partitions: must cover every choice exactly once")
            if actual_parts != expected:
                errors.append(f"{label}.choice_partitions: exact flow mismatch expected={expected}")

        choices = row.get("choices")
        if not isinstance(choices, list) or len(choices) != spec.choice_count:
            errors.append(f"{label}.choices: expected {spec.choice_count} entries")
            choices = []
        for choice_index, choice in enumerate(choices):
            choice_label = f"{label}.choices[{choice_index}]"
            if not exact_keys(choice, CHOICE_KEYS, choice_label, errors):
                continue
            assert isinstance(choice, dict)
            if choice.get("index") != choice_index:
                errors.append(f"{choice_label}.index: must equal zero-based position")
            outcome_id = str(choice.get("outcome_id", ""))
            if not outcome_id:
                errors.append(f"{choice_label}.outcome_id: must be non-empty")
            elif outcome_id in outcome_ids:
                errors.append(f"{choice_label}.outcome_id: duplicate {outcome_id!r}")
            else:
                outcome_ids.add(outcome_id)
            expected_flow = next(key for key, indices in expected.items() if choice_index in indices)
            if choice.get("flow") != expected_flow:
                errors.append(f"{choice_label}.flow: expected {expected_flow!r}")
            if not isinstance(choice.get("requirements"), list):
                errors.append(f"{choice_label}.requirements: must be an array")
            if not isinstance(choice.get("writes"), list) or not choice.get("writes"):
                errors.append(f"{choice_label}.writes: terminal/continuation choices need durable receipts")
            writes = choice.get("writes", []) if isinstance(choice.get("writes"), list) else []
            expected_scene_choice = f"scene_choice:{spec.event_id}:{choice_index}"
            scene_choice_writes = [
                write for write in writes if str(write).startswith("scene_choice:")
            ]
            if scene_choice_writes != [expected_scene_choice]:
                errors.append(
                    f"{choice_label}.writes: expected exactly one {expected_scene_choice!r} receipt"
                )
            for required_write in REQUIRED_CHOICE_WRITES.get(spec.event_id, {}).get(choice_index, []):
                if required_write not in writes:
                    errors.append(
                        f"{choice_label}.writes: missing exact causal write {required_write!r}"
                    )
            if expected_flow == "terminal":
                if len([write for write in writes if str(write).startswith("route_terminal:")]) != 1:
                    errors.append(f"{choice_label}.writes: terminal requires one route_terminal receipt")
                expected_terminal_state = EXPECTED_TERMINAL_STATES.get(
                    (spec.event_id, choice_index)
                )
                terminal_states = [
                    write for write in writes if str(write).startswith("terminal_state:")
                ]
                if terminal_states != [expected_terminal_state]:
                    errors.append(
                        f"{choice_label}.writes: expected exact semantic terminal state "
                        f"{expected_terminal_state!r}"
                    )
                expected_terminal_writes = EXPECTED_TERMINAL_WRITES.get(
                    (spec.event_id, choice_index)
                )
                if writes != expected_terminal_writes:
                    errors.append(
                        f"{choice_label}.writes: exact terminal write array mismatch "
                        f"expected={expected_terminal_writes!r} got={writes!r}"
                    )
                if any(
                    str(write).startswith(("document:", "transaction:", "finale_state:"))
                    for write in writes
                ):
                    errors.append(f"{choice_label}.writes: terminal must not continue document/transaction/finale")
            elif any(str(write).startswith("terminal_state:") for write in writes):
                errors.append(f"{choice_label}.writes: nonterminal choice must not write terminal_state")
            if expected_flow == "complete" and "finale_state:ready" not in writes:
                errors.append(f"{choice_label}.writes: complete choice must write finale_state:ready")

        for locale in ("ko", "en"):
            matches = context.event_indexes[locale].get(spec.event_id, [])
            if len(matches) != 1:
                errors.append(f"{label}: expected one unique {locale.upper()} root, got {len(matches)}")
                continue
            record = matches[0]
            declared_file = str(row.get(f"{locale}_file", ""))
            if declared_file != record.path:
                errors.append(f"{label}.{locale}_file: expected {record.path!r}")
            event = record.row
            event_choices = event.get("choices")
            if not isinstance(event_choices, list) or len(event_choices) != spec.choice_count:
                errors.append(f"{label}: {locale.upper()} choice-count parity failed")
                continue
            if locale == "ko":
                if event.get("weight") != 0 or event.get("hidden") is not True:
                    errors.append(f"{label}: KO root must stay weight=0 and hidden=true")
                conditions = event.get("conditions")
                if not isinstance(conditions, dict) or conditions.get("min_turn") != 9999:
                    errors.append(f"{label}: KO root must stay min_turn=9999")
                tags = event.get("tags")
                if not isinstance(tags, list) or "author_only" not in tags:
                    errors.append(f"{label}: KO root must keep author_only tag")
                if STATEFUL_EVENT_KEYS.intersection(event):
                    errors.append(f"{label}: KO event root contains state mutation fields")
            else:
                if set(event) != {"id", "title", "description", "choices"}:
                    errors.append(f"{label}: EN overlay must remain text-only")
            for actual_index, event_choice in enumerate(event_choices):
                if not isinstance(event_choice, dict):
                    errors.append(f"{label}: {locale.upper()} choice {actual_index} must be an object")
                    continue
                if set(event_choice) != {"text", "result_text"}:
                    errors.append(
                        f"{label}: {locale.upper()} choice {actual_index} must be text-only/state-free"
                    )
                if not str(event_choice.get("text", "")).strip() or not str(event_choice.get("result_text", "")).strip():
                    errors.append(f"{label}: {locale.upper()} choice {actual_index} has empty prose")

    final_id = specs[-1].event_id
    final_roles = roots_by_id.get(final_id, {}).get("actor_roles", [])
    if final_roles != ["primary_witness"]:
        errors.append(
            f"{owner}.root[{final_id}]: final-week must use the bound primary_witness role"
        )

    for month in range(49, 61):
        expected_month_roots = [spec.event_id for spec in specs if spec.month == month]
        month_contract = month_row(route, month)
        if month_contract is not None and month_contract.get("root_order") != expected_month_roots:
            errors.append(f"{owner}.M{month}.root_order: expected {expected_month_roots}")

    expected_commitment_ids = [
        commitment
        for month in range(49, 61)
        for commitment in EXPECTED_COMMITMENTS[month]
    ]
    observed_commitment_ids: list[str] = []
    for root in roots:
        if not isinstance(root, dict):
            continue
        for write in root.get("common_writes", []):
            if isinstance(write, str) and write.startswith("commitment:"):
                observed_commitment_ids.append(write.split(":", 2)[1])
    if observed_commitment_ids != expected_commitment_ids:
        errors.append(
            f"{owner}.roots.common_writes: canonical commitment production mismatch "
            f"expected={expected_commitment_ids} got={observed_commitment_ids}"
        )


def root_ids_from_value(value: Any) -> list[str]:
    return [item for item in scalar_strings(value) if item in ALL_TARGET_ID_SET]


def expanded_requirement_tokens(requirement: str) -> list[str]:
    """Expand the one manifest shorthand used for three alternative receipts."""
    if "|" not in requirement:
        return [requirement]
    first, *suffixes = requirement.split("|")
    if "_" not in first:
        return [requirement]
    stem = first.rsplit("_", 1)[0]
    return [first, *(f"{stem}_{suffix}" for suffix in suffixes)]


def write_matches_requirement(write: str, requirement: str) -> bool:
    if write == requirement:
        return True
    return requirement.startswith("document:") and write.startswith(f"{requirement}:")


def requirement_has_guaranteed_producer(
    requirement: str,
    guaranteed_writes: set[str],
    exhaustive_choice_groups: list[list[set[str]]],
) -> bool:
    alternatives = expanded_requirement_tokens(requirement)
    if any(
        write_matches_requirement(write, alternative)
        for write in guaranteed_writes
        for alternative in alternatives
    ):
        return True
    # An explicit A|B|C requirement may be guaranteed by a prior branch when
    # every continuing choice produces at least one member of that exact OR.
    return any(
        choice_write_sets
        and all(
            any(
                write_matches_requirement(write, alternative)
                for write in choice_writes
                for alternative in alternatives
            )
            for choice_writes in choice_write_sets
        )
        for choice_write_sets in exhaustive_choice_groups
    )


def validate_prior_producers(
    route_id: str,
    roots: list[dict[str, Any]],
    errors: list[str],
) -> None:
    """Require facts on every surviving continuation path, never a dead terminal."""
    owner = f"route[{route_id}]"
    guaranteed_writes: set[str] = set()
    exhaustive_choice_groups: list[list[set[str]]] = []
    causal_prefixes = ("receipt:", "document:", "transaction:", "finale_state:")
    for root in roots:
        if not isinstance(root, dict):
            continue
        root_id = str(root.get("id", ""))
        requirements = root.get("requirements", [])
        if isinstance(requirements, list):
            for requirement in requirements:
                if not isinstance(requirement, str):
                    continue
                if requirement.startswith("scene:"):
                    errors.append(
                        f"{owner}.root[{root_id}].requirements: orphan scene receipt is forbidden"
                    )
                if requirement.startswith(causal_prefixes) and not requirement_has_guaranteed_producer(
                    requirement,
                    guaranteed_writes,
                    exhaustive_choice_groups,
                ):
                    errors.append(
                        f"{owner}.root[{root_id}].requirements: no prior producer on "
                        f"every continuation path for {requirement!r}"
                    )
        common_writes = root.get("common_writes", [])
        writes_before_choices = set(guaranteed_writes)
        if isinstance(common_writes, list):
            writes_before_choices.update(
                write for write in common_writes if isinstance(write, str)
            )
        choices = root.get("choices", [])
        if isinstance(choices, list):
            for choice in choices:
                requirements = choice.get("requirements", []) if isinstance(choice, dict) else []
                if isinstance(requirements, list):
                    for requirement in requirements:
                        if (
                            isinstance(requirement, str)
                            and requirement.startswith(causal_prefixes)
                            and not requirement_has_guaranteed_producer(
                                requirement,
                                writes_before_choices,
                                exhaustive_choice_groups,
                            )
                        ):
                            errors.append(
                                f"{owner}.root[{root_id}].choice.requirements: "
                                f"no prior producer on every continuation path for "
                                f"{requirement!r}"
                            )
        guaranteed_writes.update(writes_before_choices)

        partitions = root.get("choice_partitions", {})
        continuation_indices = (
            partitions.get("continuation", []) if isinstance(partitions, dict) else []
        )
        continuation_write_sets: list[set[str]] = []
        if isinstance(choices, list) and isinstance(continuation_indices, list):
            for choice_index in continuation_indices:
                if not isinstance(choice_index, int) or not 0 <= choice_index < len(choices):
                    continue
                choice = choices[choice_index]
                writes = choice.get("writes", []) if isinstance(choice, dict) else []
                continuation_write_sets.append(
                    {write for write in writes if isinstance(write, str)}
                    if isinstance(writes, list)
                    else set()
                )
        if continuation_write_sets:
            guaranteed_writes.update(set.intersection(*continuation_write_sets))
            if len(continuation_write_sets) > 1:
                exhaustive_choice_groups.append(continuation_write_sets)


def validate_document_lineage(route_id: str, route: dict[str, Any], errors: list[str]) -> None:
    owner = f"route[{route_id}]"
    lineage = route.get("document_lineage")
    if lineage != EXPECTED_DOCUMENT_LINEAGES[route_id]:
        errors.append(f"{owner}.document_lineage: exact typed C0-C3/h0-h3 subtree mismatch")
    text = flattened(lineage)
    if route_id == "career_reference_v1":
        required_groups = (
            ("c0",), ("c1",), ("c2",), ("c3",), ("tf-12-c0",),
            ("8f2c71a0",), ("not used", "not_used"), ("self only", "self_only"),
            ("badge",),
        )
    else:
        required_groups = (
            ("sa-20",), ("a6e8",), ("91b4",), ("d772",), ("5c20",),
            ("16000000000", "160억", "16,000,000,000"),
            ("2000", "20%"), ("3200000000", "32억", "3,200,000,000"),
            ("not used", "not_used"),
        )
    for alternatives in required_groups:
        if not any(token in text for token in alternatives):
            errors.append(f"{owner}.document_lineage: missing exact field/hash group {alternatives}")

    positions = {spec.event_id: index for index, spec in enumerate(ROUTE_ROOTS[route_id])}
    versions = lineage.get("versions", []) if isinstance(lineage, dict) else []
    if not isinstance(versions, list) or len(versions) != 4:
        errors.append(f"{owner}.document_lineage.versions: expected exact four-stage lineage")
        return
    expected_versions = list(EXPECTED_VERSION_PRODUCERS[route_id])
    observed_versions = [
        str(version.get("version", "")).lower()
        for version in versions
        if isinstance(version, dict)
    ]
    if observed_versions != expected_versions:
        errors.append(
            f"{owner}.document_lineage.versions: expected exact order {expected_versions}"
        )
    producer_positions: dict[str, list[int]] = {}
    for version_index, version in enumerate(versions):
        if not isinstance(version, dict):
            errors.append(f"{owner}.document_lineage.versions[{version_index}]: must be an object")
            continue
        version_id = str(version.get("version", "")).strip().lower()
        producer_ids = root_ids_from_value(version)
        if producer_ids != EXPECTED_VERSION_PRODUCERS[route_id].get(version_id, []):
            errors.append(
                f"{owner}.document_lineage.{version_id}: exact producer chain mismatch "
                f"got={producer_ids}"
            )
        producer_order = [positions[event_id] for event_id in producer_ids]
        if not version_id or not producer_order:
            errors.append(
                f"{owner}.document_lineage.versions[{version_index}]: "
                "version and producer root are required"
            )
            continue
        if producer_order != sorted(set(producer_order)):
            errors.append(
                f"{owner}.document_lineage.{version_id}: draft/filing/execution "
                "producers must be unique and ordered"
            )
        producer_positions[version_id] = producer_order

        if route_id == "startup_acquisition_reference_v1":
            expected_hash = {"h0": "A6E8", "h1": "91B4", "h2": "D772", "h3": "5C20"}.get(version_id)
            if version.get("document_id") != "SA-20" or version.get("hash") != expected_hash:
                errors.append(
                    f"{owner}.document_lineage.{version_id}: SA-20 hash lineage mismatch"
                )
        elif version_id == "c0":
            if version.get("document_id") != "TF-12-C0" or version.get("hash") != "8F2C71A0":
                errors.append(f"{owner}.document_lineage.c0: TF-12-C0/hash mismatch")

    read_count = 0
    for reader_position, root in enumerate(route.get("roots", [])):
        if not isinstance(root, dict):
            continue
        reader_id = str(root.get("id", ""))
        reads = root.get("document_reads", [])
        if not isinstance(reads, list):
            continue
        for raw_read in reads:
            read_count += 1
            read_label = str(raw_read).strip().lower()
            version_id = re.split(r"[:.]", read_label, maxsplit=1)[0]
            writers = producer_positions.get(version_id, [])
            if not writers:
                errors.append(
                    f"{owner}.root[{reader_id}].document_reads: unknown/unwritten version "
                    f"{raw_read!r}"
                )
                continue
            prior_writers = [position for position in writers if position < reader_position]
            if not prior_writers:
                errors.append(
                    f"{owner}.root[{reader_id}].document_reads: {raw_read!r} is read "
                    "before its exact writer/filer"
                )
    if read_count == 0:
        errors.append(f"{owner}.document_lineage: route declares no document readers")


def transaction_id(transaction: Any) -> str:
    if not isinstance(transaction, dict):
        return ""
    for key in ("transaction_id", "id", "planned_transaction_id"):
        value = transaction.get(key)
        if isinstance(value, str):
            return value
    return ""


def validate_transactions_and_finale(
    manifest: dict[str, Any],
    routes: dict[str, dict[str, Any]],
    errors: list[str],
) -> None:
    transaction_ids: list[str] = []
    for route_id, route in routes.items():
        owner = f"route[{route_id}]"
        transaction = route.get("planned_transaction")
        if transaction != EXPECTED_PLANNED_TRANSACTIONS[route_id]:
            errors.append(f"{owner}.planned_transaction: exact typed transaction subtree mismatch")
        tx_id = transaction_id(transaction)
        if not tx_id:
            errors.append(f"{owner}.planned_transaction: missing stable transaction_id")
        else:
            transaction_ids.append(tx_id)
        text = flattened(transaction)
        if not any(token in text for token in ("once", "idempot", "dedup", "no_op", "no-op")):
            errors.append(f"{owner}.planned_transaction: must declare exactly-once replay behavior")
        if route_id == "career_reference_v1":
            if exact_keys(
                transaction,
                {"transaction_id", "trigger", "idempotency", "atomic_writes", "other_choices_effect"},
                f"{owner}.planned_transaction",
                errors,
            ):
                assert isinstance(transaction, dict)
                if transaction.get("transaction_id") != "tx.career_reference_v1.m59.choice_0":
                    errors.append(f"{owner}.planned_transaction.transaction_id: exact ID mismatch")
                if transaction.get("trigger") != {
                    "root_id": "arc_y5_contract_execution_career",
                    "choice_index": 0,
                }:
                    errors.append(f"{owner}.planned_transaction.trigger: exact M59 C1 trigger required")
                atomic = transaction.get("atomic_writes")
                expected_atomic_keys = {
                    "cash_delta_krw",
                    "document_version",
                    "execution_effective_at",
                    "job_transition",
                    "active_badge",
                    "old_badge_return_confirmed",
                    "finale_state",
                }
                if exact_keys(atomic, expected_atomic_keys, f"{owner}.planned_transaction.atomic_writes", errors):
                    assert isinstance(atomic, dict)
                    if atomic.get("cash_delta_krw") != 300000:
                        errors.append(f"{owner}.planned_transaction: career cash delta must be +300000 once")
                    if atomic.get("document_version") != "C3":
                        errors.append(f"{owner}.planned_transaction: career document version must be C3")
                    if atomic.get("execution_effective_at") != "committed_turn":
                        errors.append(
                            f"{owner}.planned_transaction: execution effective time must come from committed_turn"
                        )
                    if atomic.get("active_badge") != "new_tf_badge" or atomic.get("old_badge_return_confirmed") is not True:
                        errors.append(f"{owner}.planned_transaction: badge/return receipt mismatch")
                    if atomic.get("finale_state") != "pending":
                        errors.append(f"{owner}.planned_transaction: finale state must become pending")
                    job = atomic.get("job_transition")
                    if job != {
                        "kind": "same_employer_role_change",
                        "from": "bound_current_job",
                        "to": "new_business_tf_lead",
                        "to_is_surface_role_not_actor_id": True,
                        "preserve_bound_job_id": True,
                        "monthly_income_delta_krw": 300000,
                        "apply_together": ["current_job", "monthly_income", "flags.has_job"],
                        "runtime_owner": None,
                    }:
                        errors.append(f"{owner}.planned_transaction: exact future job transition contract missing")
                if transaction.get("other_choices_effect") != OTHER_CHOICES_EFFECT:
                    errors.append(
                        f"{owner}.planned_transaction: other choices must be zero only for the reference transaction"
                    )
            for alternatives in (
                ("300000", "300,000", "30만원"),
                ("arc_y5_contract_execution_career",),
                ("job",),
                ("badge",),
                ("return",),
            ):
                if not any(token in text for token in alternatives):
                    errors.append(f"{owner}.planned_transaction: missing career atomic effect {alternatives}")
        else:
            if exact_keys(
                transaction,
                {
                    "transaction_id",
                    "trigger",
                    "idempotency",
                    "atomic_writes",
                    "separate_required_delivery_receipt",
                    "other_choices_effect",
                },
                f"{owner}.planned_transaction",
                errors,
            ):
                assert isinstance(transaction, dict)
                if transaction.get("transaction_id") != "tx.startup_acquisition_reference_v1.m59.choice_0.sa20_5c20":
                    errors.append(f"{owner}.planned_transaction.transaction_id: exact ID mismatch")
                if transaction.get("trigger") != {
                    "root_id": "arc_y5_startup_contract_execution_c3",
                    "choice_index": 0,
                }:
                    errors.append(f"{owner}.planned_transaction.trigger: exact M59 C1 trigger required")
                expected_atomic = {
                    "cash_delta_krw": 3200000000,
                    "equity_basis_points_before": 2000,
                    "equity_basis_points_after": 0,
                    "document_version": "h3",
                    "flag": "startup_exit",
                    "finale_state": "pending",
                }
                if transaction.get("atomic_writes") != expected_atomic:
                    errors.append(
                        f"{owner}.planned_transaction.atomic_writes: exact one-time "
                        "3.2B/20%/h3/startup_exit/pending transaction required"
                    )
                if transaction.get("separate_required_delivery_receipt") != "arc_y5_startup_c3_copy_delivered_cofounder:0":
                    errors.append(f"{owner}.planned_transaction: exact affected-person delivery receipt required")
                if transaction.get("other_choices_effect") != OTHER_CHOICES_EFFECT:
                    errors.append(
                        f"{owner}.planned_transaction: other choices must be zero only for the reference transaction"
                    )
            for alternatives in (
                ("3200000000", "3,200,000,000", "32억"),
                ("2000", "20%"),
                ("5c20",),
                ("startup_exit",),
                ("finale_pending", "finale_state pending"),
                ("arc_y5_startup_contract_execution_c3",),
            ):
                if not any(token in text for token in alternatives):
                    errors.append(f"{owner}.planned_transaction: missing startup atomic effect {alternatives}")

        if route.get("finale_handoff") != EXPECTED_FINALE_HANDOFFS[route_id]:
            errors.append(f"{owner}.finale_handoff: exact failure/hold/release contract mismatch")
        finale_text = flattened(route.get("finale_handoff"))
        expected_final = ROUTE_ROOTS[route_id][-1].event_id
        for alternatives in (
            (expected_final, "final-week", "final_week"),
            ("finale_ready", "finale_state ready", "finale_state=ready"),
            ("maingame",),
            ("check_game_over",), ("failure", "fatal"),
        ):
            if not any(token in finale_text for token in alternatives):
                errors.append(f"{owner}.finale_handoff: missing handoff contract {alternatives}")

    observed_critical: dict[str, list[tuple[str, int]]] = {
        write: [] for write in EXPECTED_CRITICAL_CHOICE_WRITES
    }
    for route in routes.values():
        for root in route.get("roots", []):
            if not isinstance(root, dict):
                continue
            root_id = str(root.get("id", ""))
            for write in root.get("common_writes", []):
                if isinstance(write, str) and (
                    write.startswith("transaction:")
                    or (write.startswith("document:") and ":executed" in write)
                    or write.startswith("finale_state:")
                ):
                    errors.append(
                        f"root[{root_id}].common_writes: critical write must belong to its exact choice, got {write!r}"
                    )
            for choice in root.get("choices", []):
                if not isinstance(choice, dict) or not isinstance(choice.get("index"), int):
                    continue
                position = (root_id, choice["index"])
                writes = choice.get("writes", [])
                if not isinstance(writes, list):
                    continue
                for write in writes:
                    if not isinstance(write, str):
                        continue
                    if write in observed_critical:
                        observed_critical[write].append(position)
                    elif (
                        write.startswith("transaction:")
                        or (write.startswith("document:") and ":executed" in write)
                        or write.startswith("finale_state:")
                    ):
                        errors.append(
                            f"choice[{root_id}:{choice['index']}]: unexpected critical write {write!r}"
                        )
    for write, expected_positions in EXPECTED_CRITICAL_CHOICE_WRITES.items():
        actual_positions = observed_critical[write]
        if sorted(actual_positions) != sorted(expected_positions):
            errors.append(
                f"critical write {write!r}: exact occurrence mismatch "
                f"expected={sorted(expected_positions)} got={sorted(actual_positions)}"
            )

    if len(transaction_ids) != 2 or len(set(transaction_ids)) != 2:
        errors.append("planned_transaction: the two routes require distinct transaction IDs")

    startup = routes.get("startup_acquisition_reference_v1", {})
    legacy_text = flattened(startup.get("legacy_exclusions"))
    for token in ("startup_acquisition_offer", "startup_partial_exit", "startup_going_solo", "joined_startup"):
        if token not in legacy_text:
            errors.append(f"startup legacy_exclusions: missing {token!r} collision guard")
    if "legacy" not in legacy_text or not any(
        token in flattened(startup.get("entry")) for token in ("durable", "fail_closed", "fail-closed")
    ):
        errors.append("startup legacy contract: old saves without durable mode must fail closed")
    planned_runtime = manifest.get("planned_runtime")
    if not exact_keys(
        planned_runtime,
        {
            "current_consumer_count",
            "activation_preconditions",
            "production_dispatcher",
            "save_ledger_owner",
        },
        "manifest.planned_runtime",
        errors,
    ):
        planned_runtime = {}
    assert isinstance(planned_runtime, dict)
    if planned_runtime != EXPECTED_PLANNED_RUNTIME:
        errors.append("manifest.planned_runtime: exact activation preconditions mismatch")
    if planned_runtime.get("current_consumer_count") != 0:
        errors.append("manifest.planned_runtime.current_consumer_count: must be 0")
    if planned_runtime.get("production_dispatcher") is not None:
        errors.append("manifest.planned_runtime.production_dispatcher: must be null")
    if planned_runtime.get("save_ledger_owner") is not None:
        errors.append("manifest.planned_runtime.save_ledger_owner: must be null")
    planned_text = flattened(planned_runtime)
    for token in ("r1", "r2"):
        if token not in planned_text:
            errors.append(f"manifest.planned_runtime: missing future-only contract {token!r}")


@functools.lru_cache(maxsize=None)
def git_blob(commit: str, relative: str) -> bytes:
    process = subprocess.run(
        ["git", "show", f"{commit}:{relative}"],
        cwd=ROOT,
        check=False,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    if process.returncode != 0:
        detail = process.stderr.decode("utf-8", errors="replace").strip()
        raise ValueError(f"git cannot read {commit}:{relative} ({detail})")
    return process.stdout


def object_from_payload(payload: Any, event_id: str) -> list[dict[str, Any]]:
    rows = payload.get("items", []) if isinstance(payload, dict) else payload
    if not isinstance(rows, list):
        return []
    return [row for row in rows if isinstance(row, dict) and str(row.get("id", "")) == event_id]


def safe_relative_path(raw: Any, owner: str, errors: list[str]) -> Path | None:
    if not isinstance(raw, str) or not raw or Path(raw).is_absolute():
        errors.append(f"{owner}: must be a non-empty repository-relative path")
        return None
    path = (ROOT / raw).resolve()
    try:
        path.relative_to(ROOT.resolve())
    except ValueError:
        errors.append(f"{owner}: path escapes repository")
        return None
    return path


def scan_runtime_consumers(
    context: AuditContext,
    extra_sources: Iterable[tuple[str, str]] = (),
) -> list[tuple[str, str]]:
    consumers: list[tuple[str, str]] = []
    for owner, text in [*context.runtime_sources, *extra_sources]:
        for forbidden_token in RUNTIME_FORBIDDEN_TOKENS:
            if forbidden_token in text:
                consumers.append((owner, forbidden_token))
    return consumers


def validate_protected_hashes(
    manifest: dict[str, Any],
    context: AuditContext,
    errors: list[str],
    extra_runtime_sources: Iterable[tuple[str, str]] = (),
) -> None:
    protected = manifest.get("protected_hashes")
    if not exact_keys(protected, PROTECTED_HASH_KEYS, "manifest.protected_hashes", errors):
        return
    assert isinstance(protected, dict)
    if protected.get("algorithm") != "sha256":
        errors.append("manifest.protected_hashes.algorithm: expected sha256")
    canonicalization = flattened(protected.get("canonicalization"))
    for token in ("sort_keys", "separators", "ensure_ascii"):
        if token not in canonicalization:
            errors.append(f"manifest.protected_hashes.canonicalization: missing {token}")
    if "false" not in canonicalization:
        errors.append("manifest.protected_hashes.canonicalization: ensure_ascii must be false")

    files = protected.get("files")
    if not isinstance(files, dict):
        errors.append("manifest.protected_hashes.files: must be a path->sha256 object")
        files = {}
    missing_mandatory = sorted(MANDATORY_PROTECTED_FILES - set(files))
    if missing_mandatory:
        errors.append(f"manifest.protected_hashes.files: missing protected runtime/map/ending paths {missing_mandatory}")
    missing_files = sorted(EXPECTED_PROTECTED_FILES - set(files))
    extra_files = sorted(set(files) - EXPECTED_PROTECTED_FILES)
    if missing_files or extra_files:
        errors.append(
            "manifest.protected_hashes.files: exact 35-file baseline set mismatch "
            f"missing={missing_files} extra={extra_files}"
        )
    for relative, expected_hash in files.items():
        owner = f"manifest.protected_hashes.files[{relative!r}]"
        path = safe_relative_path(relative, owner, errors)
        if path is None:
            continue
        if not isinstance(expected_hash, str) or not HEX_64.fullmatch(expected_hash):
            errors.append(f"{owner}: invalid sha256")
            continue
        if not path.is_file():
            errors.append(f"{owner}: protected file is missing")
            continue
        actual_hash = byte_sha256(path.read_bytes())
        if actual_hash != expected_hash:
            errors.append(f"{owner}: working-tree byte hash drifted")
        try:
            baseline_hash = byte_sha256(git_blob(EXPECTED_BASELINE, relative))
        except ValueError as exc:
            errors.append(f"{owner}: {exc}")
        else:
            if baseline_hash != expected_hash:
                errors.append(f"{owner}: manifest hash does not match baseline {EXPECTED_BASELINE}")

    objects = protected.get("objects")
    if not isinstance(objects, list) or not objects:
        errors.append("manifest.protected_hashes.objects: must be a non-empty array")
        objects = []
    object_keys: set[tuple[str, str, str]] = set()
    for index, row in enumerate(objects):
        owner = f"manifest.protected_hashes.objects[{index}]"
        if not exact_keys(row, PROTECTED_OBJECT_KEYS, owner, errors):
            continue
        assert isinstance(row, dict)
        locale = str(row.get("locale", ""))
        relative = str(row.get("file", ""))
        event_id = str(row.get("id", ""))
        expected_hash = str(row.get("sha256", ""))
        key = (locale, relative, event_id)
        if key in object_keys:
            errors.append(f"{owner}: duplicate protected object {key}")
        object_keys.add(key)
        if locale not in {"ko", "en"}:
            errors.append(f"{owner}.locale: expected ko or en")
        if not HEX_64.fullmatch(expected_hash):
            errors.append(f"{owner}.sha256: invalid sha256")
            continue
        path = safe_relative_path(relative, f"{owner}.file", errors)
        if path is None or not path.is_file():
            errors.append(f"{owner}: protected object file is missing")
            continue
        try:
            current_payload = load_json(path)
            baseline_payload = strict_loads(
                git_blob(EXPECTED_BASELINE, relative).decode("utf-8"),
                f"{EXPECTED_BASELINE}:{relative}",
            )
        except (OSError, UnicodeDecodeError, ValueError) as exc:
            errors.append(f"{owner}: cannot load protected object ({exc})")
            continue
        current_rows = object_from_payload(current_payload, event_id)
        baseline_rows = object_from_payload(baseline_payload, event_id)
        if len(current_rows) != 1 or len(baseline_rows) != 1:
            errors.append(f"{owner}: expected one current and one baseline object")
            continue
        if canonical_json_sha256(current_rows[0]) != expected_hash:
            errors.append(f"{owner}: working-tree canonical object hash drifted")
        if canonical_json_sha256(baseline_rows[0]) != expected_hash:
            errors.append(f"{owner}: manifest object hash does not match baseline")

    required_target_objects: set[tuple[str, str, str]] = set()
    for locale in ("ko", "en"):
        for event_id in ALL_TARGET_IDS:
            matches = context.event_indexes[locale].get(event_id, [])
            if len(matches) == 1:
                required_target_objects.add((locale, matches[0].path, event_id))
    required_legacy_objects: set[tuple[str, str, str]] = set()
    for locale in ("ko", "en"):
        for event_id in LEGACY_PROTECTED_IDS:
            matches = context.event_indexes[locale].get(event_id, [])
            if len(matches) != 1:
                errors.append(
                    f"manifest.protected_hashes.objects: legacy {locale}:{event_id} "
                    f"must resolve uniquely, got {len(matches)}"
                )
            else:
                required_legacy_objects.add((locale, matches[0].path, event_id))
    required_objects = required_target_objects | required_legacy_objects
    missing_target_objects = sorted(required_objects - object_keys)
    extra_objects = sorted(object_keys - required_objects)
    if missing_target_objects:
        errors.append(
            "manifest.protected_hashes.objects: missing target/legacy KO/EN canonical hashes "
            f"{missing_target_objects[:8]} (missing={len(missing_target_objects)})"
        )
    if extra_objects:
        errors.append(
            "manifest.protected_hashes.objects: exact protected set is 64 target + "
            f"22 legacy objects; extras={extra_objects[:8]} (extra={len(extra_objects)})"
        )
    if len(object_keys) != 86:
        errors.append(
            f"manifest.protected_hashes.objects: expected exact 86 objects, got {len(object_keys)}"
        )

    runtime = protected.get("runtime_consumers")
    if not exact_keys(runtime, RUNTIME_CONSUMER_KEYS, "manifest.protected_hashes.runtime_consumers", errors):
        return
    assert isinstance(runtime, dict)
    if runtime.get("expected_count") != 0:
        errors.append("manifest.protected_hashes.runtime_consumers.expected_count: must be 0")
    forbidden = runtime.get("forbidden_root_ids")
    if forbidden != list(ALL_TARGET_IDS):
        errors.append("manifest.protected_hashes.runtime_consumers.forbidden_root_ids: exact 32-root order mismatch")
    consumers = scan_runtime_consumers(context, extra_runtime_sources)
    if consumers:
        sample = ", ".join(f"{owner}:{event_id}" for owner, event_id in consumers[:8])
        errors.append(f"production runtime consumer count must be 0; found {len(consumers)} ({sample})")


def validate_manifest(
    manifest: Any,
    context: AuditContext,
    *,
    extra_runtime_sources: Iterable[tuple[str, str]] = (),
) -> tuple[list[str], dict[str, int]]:
    errors: list[str] = []
    routes = validate_surface(manifest, errors)
    if not isinstance(manifest, dict):
        return errors, {"routes": 0, "roots": 0, "choices": 0, "consumers": 0}

    outcome_ids: set[str] = set()
    root_total = 0
    choice_total = 0
    for route_id in EXPECTED_ROUTE_IDS:
        route = routes.get(route_id)
        if route is None:
            errors.append(f"manifest.routes: missing {route_id}")
            continue
        roots, roots_by_id = validate_route_shape(route_id, route, errors)
        root_total += len(roots)
        choice_total += sum(
            int(row.get("choice_count", 0))
            for row in roots
            if isinstance(row, dict) and isinstance(row.get("choice_count"), int)
        )
        validate_actors(manifest, route_id, route, errors)
        validate_months(route_id, route, errors)
        validate_roots(route_id, route, roots, roots_by_id, context, outcome_ids, errors)
        validate_prior_producers(route_id, roots, errors)
        validate_document_lineage(route_id, route, errors)

    if root_total != 32:
        errors.append(f"manifest: expected exactly 32 roots, got {root_total}")
    if choice_total != 86:
        errors.append(f"manifest: expected exactly 86 choices, got {choice_total}")
    if len(outcome_ids) != 86:
        errors.append(f"manifest: expected 86 unique outcome IDs, got {len(outcome_ids)}")
    if set(routes) != set(EXPECTED_ROUTE_IDS):
        errors.append("manifest: route scope must contain career/startup only")

    validate_transactions_and_finale(manifest, routes, errors)
    blocker_text = flattened(manifest.get("unresolved_blockers"))
    for token in ("m48", "m53", "m56", "margin"):
        if token not in blocker_text:
            errors.append(f"manifest.unresolved_blockers: missing unresolved {token!r} blocker")
    if "live_infrastructure" not in blocker_text and "production dispatcher" not in blocker_text:
        errors.append("manifest.unresolved_blockers: missing unresolved live runtime blocker")
    if "startup_cofounder_actor_producer" not in blocker_text or "startup_founded" not in blocker_text:
        errors.append(
            "manifest.unresolved_blockers: startup cofounder actor must remain a future typed producer blocker"
        )
    validate_protected_hashes(manifest, context, errors, extra_runtime_sources)
    consumers = scan_runtime_consumers(context, extra_runtime_sources)
    return errors, {
        "routes": len(routes),
        "roots": root_total,
        "choices": choice_total,
        "consumers": len(consumers),
    }


def expect_failure(
    label: str,
    manifest: dict[str, Any],
    context: AuditContext,
    mutate: Callable[[dict[str, Any]], None],
    expected_fragment: str,
    failures: list[str],
) -> None:
    candidate = copy.deepcopy(manifest)
    mutate(candidate)
    errors, _ = validate_manifest(candidate, context)
    if not any(expected_fragment in error for error in errors):
        failures.append(f"{label}: mutation was not rejected by {expected_fragment!r}; errors={errors[:4]}")


def actor_binding_container(route: dict[str, Any], role: str) -> tuple[Any, Any] | None:
    actors = route.get("bindings", route.get("actors"))
    if isinstance(actors, dict) and role in actors:
        return actors, role
    rows = actors.get("bindings") if isinstance(actors, dict) else actors
    if isinstance(rows, list):
        for index, row in enumerate(rows):
            if isinstance(row, dict) and str(row.get("role", row.get("actor_role", ""))) == role:
                return rows, index
    return None


def replace_actor_binding(route: dict[str, Any], role: str, new_actor: str) -> None:
    location = actor_binding_container(route, role)
    if location is None:
        return
    parent, key = location
    value = parent[key]
    if isinstance(value, str):
        parent[key] = new_actor
    elif isinstance(value, dict):
        for actor_key in ("actor_id", "id", "value", "binding"):
            if actor_key in value:
                value[actor_key] = new_actor
                return


def remove_actor_binding(route: dict[str, Any], role: str) -> None:
    location = actor_binding_container(route, role)
    if location is None:
        return
    parent, key = location
    if isinstance(parent, dict):
        del parent[key]
    else:
        parent.pop(int(key))


def first_terminal_root(route: dict[str, Any]) -> dict[str, Any]:
    for root in route.get("roots", []):
        if isinstance(root, dict) and root.get("choice_partitions", {}).get("terminal"):
            return root
    raise ValueError("no terminal root")


def run_self_test(manifest: dict[str, Any], context: AuditContext) -> tuple[list[str], int]:
    failures: list[str] = []
    case_count = 0
    base_errors, _ = validate_manifest(manifest, context)
    if base_errors:
        return [f"baseline manifest is not valid: {base_errors[:8]}"], 0

    cases: list[tuple[str, Callable[[dict[str, Any]], None], str]] = []
    cases.append(("reachability_true", lambda data: data.__setitem__("reachability_claim", True), "reachability_claim"))
    cases.append(("lifecycle_mapped", lambda data: data.__setitem__("activation", "mapped"), "reference_only"))
    cases.append(("lifecycle_live", lambda data: data.__setitem__("activation", "live"), "reference_only"))

    def actor_duplicate(data: dict[str, Any]) -> None:
        registry = data["actor_registry"]["career_reference_v1"]
        replace_actor_binding(registry, "reviewer", "boss")

    def actor_missing(data: dict[str, Any]) -> None:
        registry = data["actor_registry"]["startup_acquisition_reference_v1"]
        remove_actor_binding(registry, "protected")

    cases.append(("actor_duplicate", actor_duplicate, "actors.reviewer"))
    cases.append(("actor_missing", actor_missing, "actors.protected"))

    def wrong_partition(data: dict[str, Any]) -> None:
        root = first_terminal_root(route_map(data)["career_reference_v1"])
        terminal = root["choice_partitions"]["terminal"]
        root["choice_partitions"]["continuation"].append(terminal.pop())

    def terminal_continuation(data: dict[str, Any]) -> None:
        root = first_terminal_root(route_map(data)["startup_acquisition_reference_v1"])
        index = root["choice_partitions"]["terminal"][0]
        root["choices"][index]["flow"] = "continuation"

    cases.append(("wrong_choice_partition", wrong_partition, "exact flow mismatch"))
    cases.append(("terminal_continuation", terminal_continuation, ".flow: expected 'terminal'"))

    def missing_m48(data: dict[str, Any]) -> None:
        month_row(route_map(data)["career_reference_v1"], 49)["incoming_margin"] = []  # type: ignore[index]

    def resolve_m53(data: dict[str, Any]) -> None:
        month_row(route_map(data)["career_reference_v1"], 53)["unresolved"] = False  # type: ignore[index]

    def resolve_m56(data: dict[str, Any]) -> None:
        month_row(route_map(data)["startup_acquisition_reference_v1"], 56)["unresolved"] = False  # type: ignore[index]

    cases.append(("m48_margin_missing", missing_m48, "actual M48 receipt"))
    cases.append(("m53_falsely_resolved", resolve_m53, "M53: margin-expiry owner must remain unresolved"))
    cases.append(("m56_falsely_resolved", resolve_m56, "M56: M57 margin producer must remain unresolved"))

    def property_tuple(data: dict[str, Any]) -> None:
        route_map(data)["career_reference_v1"]["economic_path"] = "property"

    def legacy_collision(data: dict[str, Any]) -> None:
        route_map(data)["startup_acquisition_reference_v1"]["legacy_exclusions"] = []

    def duplicate_transaction(data: dict[str, Any]) -> None:
        routes = route_map(data)
        startup_tx = routes["startup_acquisition_reference_v1"]["planned_transaction"]
        career_id = transaction_id(routes["career_reference_v1"]["planned_transaction"])
        for key in ("transaction_id", "id", "planned_transaction_id"):
            if key in startup_tx:
                startup_tx[key] = career_id
                return

    cases.append(("property_tuple", property_tuple, "economic_path"))
    cases.append(("legacy_collision", legacy_collision, "legacy_exclusions"))
    cases.append(("duplicate_transaction", duplicate_transaction, "distinct transaction IDs"))

    def wrong_final_actor(data: dict[str, Any]) -> None:
        final_root = route_map(data)["career_reference_v1"]["roots"][-1]
        final_root["actor_roles"] = ["reviewer"]

    def missing_m59_receipt(data: dict[str, Any]) -> None:
        route = route_map(data)["startup_acquisition_reference_v1"]
        execution = next(root for root in route["roots"] if root["id"] == "arc_y5_startup_contract_execution_c3")
        execution["choices"][0]["writes"] = []

    cases.append(("wrong_final_actor", wrong_final_actor, "final-week must use"))
    cases.append(("m59_receipt_missing", missing_m59_receipt, "durable receipts"))

    def change_m48_axis(data: dict[str, Any]) -> None:
        row = month_row(route_map(data)["startup_acquisition_reference_v1"], 49)
        assert row is not None
        row["incoming_margin"]["axis"] = "cash"

    def invent_m53_action(data: dict[str, Any]) -> None:
        row = month_row(route_map(data)["career_reference_v1"], 53)
        assert row is not None
        row["selected_commitments"] = ["m53_fake_protected_action"]
        row["root_order"] = ["arc_y5_people_verdict_career_hyunsu"]

    def invent_m56_producer(data: dict[str, Any]) -> None:
        row = month_row(route_map(data)["startup_acquisition_reference_v1"], 56)
        assert row is not None
        row["outgoing_margin"] = {"axis": "trust", "producer": "m56_false_producer"}

    cases.extend(
        [
            ("m48_axis_mismatch", change_m48_axis, "exact typed margin"),
            ("m53_protected_action_invented", invent_m53_action, "exact canonical IDs"),
            ("m56_false_producer", invent_m56_producer, "exact typed margin"),
        ]
    )

    def actor_source_changed(data: dict[str, Any]) -> None:
        data["actor_registry"]["career_reference_v1"]["bindings"]["protected"]["source"] = "literal_actor:hyunsu"

    def actor_invalidation_removed(data: dict[str, Any]) -> None:
        data["actor_registry"]["startup_acquisition_reference_v1"]["invalidations"] = []

    def startup_actor_source_falsely_current(data: dict[str, Any]) -> None:
        data["actor_registry"]["startup_acquisition_reference_v1"]["bindings"]["protected"]["source"] = "startup_founded.founding_receipt.cofounder_actor"

    def final_actor_binding_mismatch(data: dict[str, Any]) -> None:
        data["actor_registry"]["startup_acquisition_reference_v1"]["bindings"]["primary_witness"]["actor_id"] = "minseo"

    cases.extend(
        [
            ("actor_source_changed", actor_source_changed, "exact provenance mismatch"),
            ("actor_invalidation_removed", actor_invalidation_removed, "exact invalidation list"),
            ("startup_actor_source_falsely_current", startup_actor_source_falsely_current, "exact provenance mismatch"),
            ("final_actor_binding_mismatch", final_actor_binding_mismatch, "actors.primary_witness"),
        ]
    )

    def promote_terminal_choice(
        data: dict[str, Any], route_id: str, event_id: str, choice_index: int
    ) -> None:
        route = route_map(data)[route_id]
        root = next(row for row in route["roots"] if row["id"] == event_id)
        root["choice_partitions"]["terminal"].remove(choice_index)
        root["choice_partitions"]["continuation"].append(choice_index)
        root["choice_partitions"]["continuation"].sort()
        root["choices"][choice_index]["flow"] = "continuation"

    terminal_cases = (
        ("startup_m50_c4_continues", "startup_acquisition_reference_v1", "arc_y5_startup_boundary_cofounder", 3),
        ("startup_m52_c4_continues", "startup_acquisition_reference_v1", "arc_y5_startup_final_offer_acquirer", 3),
        ("career_m55_nonreference_continues", "career_reference_v1", "arc_y5_three_in_room_decision_career", 1),
        ("career_m57_nonreference_continues", "career_reference_v1", "arc_y5_name_on_line_career_self", 0),
        ("career_m58_nonreference_continues", "career_reference_v1", "arc_y5_people_verdict_career_hyunsu", 1),
        ("career_m59_nonreference_continues", "career_reference_v1", "arc_y5_contract_execution_career", 1),
        ("startup_m55_nonreference_continues", "startup_acquisition_reference_v1", "arc_y5_startup_three_in_room_decision", 1),
        ("startup_m57_nonreference_continues", "startup_acquisition_reference_v1", "arc_y5_startup_c2_sign_self", 1),
        ("startup_m58_nonreference_continues", "startup_acquisition_reference_v1", "arc_y5_startup_people_verdict_cofounder", 1),
        ("startup_m59_nonreference_continues", "startup_acquisition_reference_v1", "arc_y5_startup_contract_execution_c3", 1),
    )
    for label, route_id, event_id, choice_index in terminal_cases:
        cases.append(
            (
                label,
                lambda data, route_id=route_id, event_id=event_id, choice_index=choice_index: promote_terminal_choice(
                    data, route_id, event_id, choice_index
                ),
                "exact flow mismatch",
            )
        )

    def startup_cash_duplicated(data: dict[str, Any]) -> None:
        tx = route_map(data)["startup_acquisition_reference_v1"]["planned_transaction"]
        tx["atomic_writes"]["cash_delta_krw"] = [3200000000, 3200000000]

    def startup_equity_changed(data: dict[str, Any]) -> None:
        tx = route_map(data)["startup_acquisition_reference_v1"]["planned_transaction"]
        tx["atomic_writes"]["equity_basis_points_before"] = 1900

    def startup_exit_removed(data: dict[str, Any]) -> None:
        tx = route_map(data)["startup_acquisition_reference_v1"]["planned_transaction"]
        tx["atomic_writes"]["flag"] = "startup_sale_planned"

    def career_cash_changed(data: dict[str, Any]) -> None:
        tx = route_map(data)["career_reference_v1"]["planned_transaction"]
        tx["atomic_writes"]["cash_delta_krw"] = 600000

    def career_job_removed(data: dict[str, Any]) -> None:
        tx = route_map(data)["career_reference_v1"]["planned_transaction"]
        del tx["atomic_writes"]["job_transition"]

    def career_job_bundle_changed(data: dict[str, Any]) -> None:
        tx = route_map(data)["career_reference_v1"]["planned_transaction"]
        tx["atomic_writes"]["job_transition"]["apply_together"] = ["current_job"]

    cases.extend(
        [
            ("startup_32b_duplicate", startup_cash_duplicated, "exact one-time 3.2B"),
            ("startup_20pct_changed", startup_equity_changed, "exact one-time 3.2B"),
            ("startup_exit_removed", startup_exit_removed, "exact one-time 3.2B"),
            ("career_cash_changed", career_cash_changed, "cash delta must be +300000 once"),
            ("career_job_removed", career_job_removed, "keys mismatch"),
            ("career_job_bundle_changed", career_job_bundle_changed, "exact future job transition"),
        ]
    )

    def protected_file_hash_changed(data: dict[str, Any]) -> None:
        data["protected_hashes"]["files"]["content/meta/story_map.json"] = "0" * 64

    def protected_object_hash_changed(data: dict[str, Any]) -> None:
        data["protected_hashes"]["objects"][0]["sha256"] = "0" * 64

    cases.extend(
        [
            ("protected_file_hash_changed", protected_file_hash_changed, "working-tree byte hash drifted"),
            ("protected_object_hash_changed", protected_object_hash_changed, "working-tree canonical object hash drifted"),
        ]
    )

    def seller_page_return_producer_removed(data: dict[str, Any]) -> None:
        route = route_map(data)["startup_acquisition_reference_v1"]
        root = next(row for row in route["roots"] if row["id"] == "arc_y5_startup_c2_copy_delivered_cofounder")
        root["choices"][0]["writes"].remove("receipt:cofounder_separate_seller_page_returned")

    def seller_page_return_reader_removed(data: dict[str, Any]) -> None:
        route = route_map(data)["startup_acquisition_reference_v1"]
        root = next(row for row in route["roots"] if row["id"] == "arc_y5_startup_contract_execution_c3")
        root["requirements"].remove("receipt:cofounder_separate_seller_page_returned")

    cases.extend(
        [
            ("seller_page_return_producer_removed", seller_page_return_producer_removed, "missing exact causal write"),
            ("seller_page_return_reader_removed", seller_page_return_reader_removed, "missing exact causal token"),
        ]
    )

    def scene_choice_removed(data: dict[str, Any]) -> None:
        root = route_map(data)["career_reference_v1"]["roots"][0]
        root["choices"][0]["writes"].remove(
            "scene_choice:arc_y5_contract_cover_career:0"
        )

    def scene_choice_wrong_index(data: dict[str, Any]) -> None:
        root = route_map(data)["career_reference_v1"]["roots"][0]
        root["choices"][1]["writes"] = [
            "scene_choice:arc_y5_contract_cover_career:0"
        ]

    cases.extend(
        [
            ("scene_choice_removed", scene_choice_removed, "expected exactly one 'scene_choice"),
            ("scene_choice_wrong_index", scene_choice_wrong_index, "expected exactly one 'scene_choice"),
        ]
    )

    def acquirer_binding_producer_removed(data: dict[str, Any]) -> None:
        route = route_map(data)["startup_acquisition_reference_v1"]
        root = next(row for row in route["roots"] if row["id"] == "arc_y5_startup_offer_c0")
        root["common_writes"].remove("actor_binding:acquirer_lead")

    def acquirer_binding_reader_removed(data: dict[str, Any]) -> None:
        route = route_map(data)["startup_acquisition_reference_v1"]
        root = next(row for row in route["roots"] if row["id"] == "arc_y5_startup_final_offer_acquirer")
        root["requirements"].remove("actor:acquirer_lead")

    cases.extend(
        [
            ("acquirer_binding_producer_removed", acquirer_binding_producer_removed, "missing exact causal token"),
            ("acquirer_binding_reader_removed", acquirer_binding_reader_removed, "missing exact causal token"),
        ]
    )

    def actor_roles_emptied(data: dict[str, Any]) -> None:
        route = route_map(data)["startup_acquisition_reference_v1"]
        route["roots"][0]["actor_roles"] = []

    def orphan_receipt_added(data: dict[str, Any]) -> None:
        route = route_map(data)["career_reference_v1"]
        route["roots"][-1]["requirements"].append("receipt:orphan_never_produced")

    def orphan_choice_receipt_added(data: dict[str, Any]) -> None:
        route = route_map(data)["startup_acquisition_reference_v1"]
        route["roots"][1]["choices"][0]["requirements"].append(
            "receipt:orphan_choice_never_produced"
        )

    def career_c0_term_changed(data: dict[str, Any]) -> None:
        lineage = route_map(data)["career_reference_v1"]["document_lineage"]
        lineage["versions"][0]["fields"]["term_months"] = 11

    def career_c0_clawback_changed(data: dict[str, Any]) -> None:
        lineage = route_map(data)["career_reference_v1"]["document_lineage"]
        lineage["versions"][0]["fields"]["early_exit_training_clawback_krw"] = 0

    def startup_h2_package_changed(data: dict[str, Any]) -> None:
        lineage = route_map(data)["startup_acquisition_reference_v1"]["document_lineage"]
        lineage["versions"][2]["fields"]["selected_package"] = "product"

    def compatible_job_changed(data: dict[str, Any]) -> None:
        entry = route_map(data)["career_reference_v1"]["entry"]
        entry["compatible_job_ids"][0] = "job_01"

    def excluded_path_removed(data: dict[str, Any]) -> None:
        data["scope"]["excluded_economic_paths"] = []

    def excluded_family_removed(data: dict[str, Any]) -> None:
        data["scope"]["excluded_reference_families"] = ["property"]

    def r1_activation_reversed(data: dict[str, Any]) -> None:
        data["scope"]["live_split"]["r1"]["activation_after_completion"] = True

    def terminal_state_changed(data: dict[str, Any]) -> None:
        route = route_map(data)["startup_acquisition_reference_v1"]
        root = next(
            row for row in route["roots"]
            if row["id"] == "arc_y5_startup_contract_execution_c3"
        )
        root["choices"][1]["writes"][0] = "terminal_state:closing_succeeded_by_mistake"

    def protected_file_deleted(data: dict[str, Any]) -> None:
        del data["protected_hashes"]["files"]["systems/StoryMapMonthlyRuntime.gd"]

    def duplicate_critical_write(data: dict[str, Any]) -> None:
        route = route_map(data)["career_reference_v1"]
        route["roots"][0]["choices"][0]["writes"].append(
            "transaction:tx.career_reference_v1.m59.choice_0"
        )

    def common_critical_write_added(data: dict[str, Any]) -> None:
        route = route_map(data)["startup_acquisition_reference_v1"]
        route["roots"][0]["common_writes"].append("finale_state:pending")

    def finale_handoff_reversed(data: dict[str, Any]) -> None:
        handoff = route_map(data)["career_reference_v1"]["finale_handoff"]
        handoff["failure_endings"], handoff["success_endings"] = (
            handoff["success_endings"], handoff["failure_endings"]
        )

    def transaction_zero_scope_broadened(data: dict[str, Any]) -> None:
        route_map(data)["startup_acquisition_reference_v1"]["planned_transaction"][
            "other_choices_effect"
        ] = "zero"

    def execution_date_source_changed(data: dict[str, Any]) -> None:
        transaction = route_map(data)["career_reference_v1"]["planned_transaction"]
        transaction["atomic_writes"]["execution_effective_at"] = "draft_date"

    def root_with_id(data: dict[str, Any], route_id: str, root_id: str) -> dict[str, Any]:
        return next(
            root for root in route_map(data)[route_id]["roots"]
            if root["id"] == root_id
        )

    def terminal_route_id_changed(data: dict[str, Any]) -> None:
        root = root_with_id(
            data,
            "career_reference_v1",
            "arc_y5_three_in_room_decision_career",
        )
        root["choices"][1]["writes"][1] = "route_terminal:startup:m55:1"

    def terminal_month_changed(data: dict[str, Any]) -> None:
        root = root_with_id(
            data,
            "startup_acquisition_reference_v1",
            "arc_y5_startup_boundary_cofounder",
        )
        root["choices"][3]["writes"][1] = "route_terminal:startup:m57:3"

    def terminal_index_changed(data: dict[str, Any]) -> None:
        root = root_with_id(
            data,
            "career_reference_v1",
            "arc_y5_name_on_line_career_self",
        )
        root["choices"][2]["writes"][1] = "route_terminal:career:m57:3"

    def career_m59_idx1_concrete_write_removed(data: dict[str, Any]) -> None:
        root = root_with_id(
            data,
            "career_reference_v1",
            "arc_y5_contract_execution_career",
        )
        root["choices"][1]["writes"].remove("terminal_document:C2:rejected_unexecuted")

    def career_m59_idx2_concrete_write_removed(data: dict[str, Any]) -> None:
        root = root_with_id(
            data,
            "career_reference_v1",
            "arc_y5_contract_execution_career",
        )
        root["choices"][2]["writes"].remove("job_transition:quit_bound_current_job")

    def dead_terminal_receipt_used_downstream(data: dict[str, Any]) -> None:
        terminal_root = root_with_id(
            data,
            "career_reference_v1",
            "arc_y5_three_in_room_decision_career",
        )
        terminal_root["choices"][1]["writes"].append("receipt:dead_branch_only")
        downstream = root_with_id(
            data,
            "career_reference_v1",
            "arc_y5_name_on_line_career_self",
        )
        downstream["requirements"].append("receipt:dead_branch_only")

    def m49_requirement_removed(data: dict[str, Any]) -> None:
        root = root_with_id(data, "career_reference_v1", "arc_y5_contract_cover_career")
        root["requirements"].remove("future M48 actor+trust-margin receipt")

    def m51_margin_requirement_removed(data: dict[str, Any]) -> None:
        root = root_with_id(
            data,
            "startup_acquisition_reference_v1",
            "arc_y5_startup_minseo_goal_cost",
        )
        root["requirements"].remove("margin:m50_draw_name_boundary:trust")

    def m51_commitment_requirement_removed(data: dict[str, Any]) -> None:
        root = root_with_id(
            data,
            "startup_acquisition_reference_v1",
            "arc_y5_startup_after_goal_cofounder",
        )
        root["requirements"].remove("commitment:m51_hear_minseo:trust")

    def m57_unresolved_margin_removed(data: dict[str, Any]) -> None:
        root = root_with_id(
            data,
            "career_reference_v1",
            "arc_y5_name_on_line_career_self",
        )
        root["requirements"].remove("future margin:M56")

    def m57_cofounder_requirement_removed(data: dict[str, Any]) -> None:
        root = root_with_id(
            data,
            "startup_acquisition_reference_v1",
            "arc_y5_startup_c2_copy_delivered_cofounder",
        )
        root["requirements"].remove("actor:startup_cofounder")

    def m49_early_h2_added(data: dict[str, Any]) -> None:
        root = root_with_id(data, "startup_acquisition_reference_v1", "arc_y5_startup_offer_c0")
        root["common_writes"].append("document:h2:D772:filed")

    def m49_early_actor_binding_added(data: dict[str, Any]) -> None:
        root = root_with_id(data, "startup_acquisition_reference_v1", "arc_y5_startup_offer_c0")
        root["common_writes"].append("actor_binding:startup_cofounder")

    def m49_early_startup_exit_added(data: dict[str, Any]) -> None:
        root = root_with_id(data, "startup_acquisition_reference_v1", "arc_y5_startup_offer_c0")
        root["common_writes"].append("flag:startup_exit")

    def m49_early_cash_added(data: dict[str, Any]) -> None:
        root = root_with_id(data, "startup_acquisition_reference_v1", "arc_y5_startup_offer_c0")
        root["common_writes"].append("cash_delta_krw:3200000000")

    cases.extend(
        [
            ("actor_roles_empty", actor_roles_emptied, "expected exact roles"),
            ("orphan_receipt", orphan_receipt_added, "no prior producer"),
            ("orphan_choice_receipt", orphan_choice_receipt_added, "no prior producer"),
            ("career_c0_term_changed", career_c0_term_changed, "exact typed C0-C3/h0-h3 subtree"),
            ("career_c0_clawback_changed", career_c0_clawback_changed, "exact typed C0-C3/h0-h3 subtree"),
            ("startup_h2_package_changed", startup_h2_package_changed, "exact typed C0-C3/h0-h3 subtree"),
            ("compatible_job_changed", compatible_job_changed, "exact typed entry contract"),
            ("excluded_path_removed", excluded_path_removed, "exact excluded paths/families"),
            ("excluded_family_removed", excluded_family_removed, "exact excluded paths/families"),
            ("r1_activation_reversed", r1_activation_reversed, "exact excluded paths/families"),
            ("terminal_state_changed", terminal_state_changed, "exact semantic terminal state"),
            ("protected_file_deleted", protected_file_deleted, "exact 35-file baseline set mismatch"),
            ("duplicate_critical_write", duplicate_critical_write, "exact occurrence mismatch"),
            ("common_critical_write", common_critical_write_added, "critical write must belong to its exact choice"),
            ("finale_handoff_reversed", finale_handoff_reversed, "exact failure/hold/release"),
            ("transaction_zero_scope_broadened", transaction_zero_scope_broadened, "zero only for the reference transaction"),
            ("execution_date_source_changed", execution_date_source_changed, "execution effective time must come from committed_turn"),
            ("terminal_route_id_changed", terminal_route_id_changed, "exact terminal write array mismatch"),
            ("terminal_month_changed", terminal_month_changed, "exact terminal write array mismatch"),
            ("terminal_index_changed", terminal_index_changed, "exact terminal write array mismatch"),
            ("career_m59_idx1_concrete_write_removed", career_m59_idx1_concrete_write_removed, "exact terminal write array mismatch"),
            ("career_m59_idx2_concrete_write_removed", career_m59_idx2_concrete_write_removed, "exact terminal write array mismatch"),
            ("dead_terminal_receipt_used_downstream", dead_terminal_receipt_used_downstream, "no prior producer on every continuation path"),
            ("m49_requirement_removed", m49_requirement_removed, "canonical semantic digest mismatch"),
            ("m51_margin_requirement_removed", m51_margin_requirement_removed, "canonical semantic digest mismatch"),
            ("m51_commitment_requirement_removed", m51_commitment_requirement_removed, "canonical semantic digest mismatch"),
            ("m57_unresolved_margin_removed", m57_unresolved_margin_removed, "canonical semantic digest mismatch"),
            ("m57_cofounder_requirement_removed", m57_cofounder_requirement_removed, "canonical semantic digest mismatch"),
            ("m49_early_h2_added", m49_early_h2_added, "canonical semantic digest mismatch"),
            ("m49_early_actor_binding_added", m49_early_actor_binding_added, "canonical semantic digest mismatch"),
            ("m49_early_startup_exit_added", m49_early_startup_exit_added, "canonical semantic digest mismatch"),
            ("m49_early_cash_added", m49_early_cash_added, "canonical semantic digest mismatch"),
        ]
    )

    for label, mutate, fragment in cases:
        case_count += 1
        expect_failure(label, manifest, context, mutate, fragment, failures)

    case_count += 1
    try:
        strict_loads('{"schema_version":1,"schema_version":2}', "self-test duplicate key")
    except ValueError as exc:
        if "duplicate JSON key" not in str(exc):
            failures.append(f"duplicate_json_key: wrong rejection {exc}")
    else:
        failures.append("duplicate_json_key: strict loader accepted a duplicate key")

    case_count += 1
    with tempfile.TemporaryDirectory(prefix="year5-route-audit-") as temporary:
        probe = Path(temporary) / "RuntimeConsumer.gd"
        probe_text = f'const ILLEGAL_ROOT = "{ALL_TARGET_IDS[0]}"\n'
        # The temp copy proves the scanner rejects production consumption without
        # writing a fixture into the repository.
        probe.write_text(probe_text, encoding="utf-8")
        errors, _ = validate_manifest(
            copy.deepcopy(manifest),
            context,
            extra_runtime_sources=[(str(probe), probe.read_text(encoding="utf-8"))],
        )
        if not any("production runtime consumer count must be 0" in error for error in errors):
            failures.append("runtime_consumer: temporary runtime consumer was accepted")

    case_count += 1
    loader_probe = 'var reference_routes = load("res://content/meta/year5_reference_routes.json")\n'
    errors, _ = validate_manifest(
        copy.deepcopy(manifest),
        context,
        extra_runtime_sources=[("RuntimeManifestLoader.gd", loader_probe)],
    )
    if not any("production runtime consumer count must be 0" in error for error in errors):
        failures.append("runtime_manifest_loader: generic manifest loader was accepted")

    for label, forbidden_token in (
        ("runtime_manifest_id", EXPECTED_MANIFEST_ID),
        ("runtime_career_route_id", EXPECTED_ROUTE_IDS[0]),
        ("runtime_startup_route_id", EXPECTED_ROUTE_IDS[1]),
    ):
        case_count += 1
        errors, _ = validate_manifest(
            copy.deepcopy(manifest),
            context,
            extra_runtime_sources=[
                (f"{label}.gd", f'const ILLEGAL_REFERENCE = "{forbidden_token}"\n')
            ],
        )
        if not any("production runtime consumer count must be 0" in error for error in errors):
            failures.append(f"{label}: production reference token was accepted")

    return failures, case_count


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()

    try:
        manifest = load_json(MANIFEST_PATH)
    except (OSError, ValueError) as exc:
        print(f"YEAR5_REFERENCE_ROUTE_FAIL load_error={exc}")
        return 1

    context, context_errors = build_context()
    errors, stats = validate_manifest(manifest, context)
    errors = [*context_errors, *errors]
    if errors:
        for error in errors:
            print(f"YEAR5_REFERENCE_ROUTE_ERROR {error}")
        print(f"YEAR5_REFERENCE_ROUTE_FAIL errors={len(errors)}")
        return 1

    if args.self_test:
        failures, cases = run_self_test(manifest, context)
        if failures:
            for failure in failures:
                print(f"YEAR5_REFERENCE_ROUTE_SELF_TEST_ERROR {failure}")
            print(f"YEAR5_REFERENCE_ROUTE_SELF_TEST_FAIL errors={len(failures)} cases={cases}")
            return 1
        print(
            "YEAR5_REFERENCE_ROUTE_SELF_TEST_OK "
            f"cases={cases} routes={stats['routes']} roots={stats['roots']} "
            f"choices={stats['choices']} runtime_consumers={stats['consumers']}"
        )
        return 0

    print(
        "YEAR5_REFERENCE_ROUTE_OK "
        f"routes={stats['routes']} roots={stats['roots']} choices={stats['choices']} "
        f"runtime_consumers={stats['consumers']} activation=reference_only"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
