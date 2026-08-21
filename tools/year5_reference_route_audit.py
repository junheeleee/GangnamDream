#!/usr/bin/env python3
"""Audit the non-live Year-5 career/startup reference-route evidence.

The delegated L3 verdict invalidated the old 9+9 literary topology.  The
manifest now keeps that topology and its prose hashes only as a rejected
snapshot while continuing to freeze legacy objects, protected runtime bytes,
product-consumer zero, and the caller-injected dormant reducer.  A passing
audit therefore means "invalidated evidence is safely dormant", never
"playable" or "ready for R1b".
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
EVENT_LIFECYCLE_RELATIVE_PATH = "content/meta/event_lifecycle.json"
KERNEL_RELATIVE_PATH = "systems/Year5ReferenceRouteKernel.gd"
KERNEL_CLASS_TOKEN = "Year5ReferenceRouteKernel"
QA_INJECTION_RELATIVE_PATH = "tools/Year5ReferenceRouteR1Check.gd"
EVENT_DIRS = {
    "ko": ROOT / "content" / "events",
    "en": ROOT / "content" / "events_en",
}

EXPECTED_DECLARATION = "89d218233b271e9a60a761d2c0bcce1c235ba703"
EXPECTED_BASELINE = "4177cd281d7be2c4084a294fd1aa3cbb89b15709"
EXPECTED_MANIFEST_ID = "year5_reference_routes_v2"
LEGACY_MANIFEST_IDS = ("year5_reference_routes_v1",)
EXPECTED_ROUTE_IDS = (
    "career_reference_v1",
    "startup_acquisition_reference_v1",
)
INVALIDATED_CONTRACT_STATUS = "invalidated_by_delegated_l3"

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
    "r1a_contract",
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
RUNTIME_CONSUMER_KEYS = {"expected_count", "qa_injection", "forbidden_root_ids"}
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
    "document_custody",
    "entry_ingress",
    "external_handoff",
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
    "content/jobs.json",
    "project.godot",
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
REJECTED_PROSE_FILES = {
    "content/events/arc_drama.json",
    "content/events/arc_midgame.json",
    "content/events/arc_new_characters.json",
    "content/events/arc_pre_ending.json",
    "content/events_en/arc_drama.json",
    "content/events_en/arc_midgame.json",
    "content/events_en/arc_new_characters.json",
    "content/events_en/arc_pre_ending.json",
}

# ORDER-118 replaces the rejected startup prose and removes internal document
# tokens from the adjacent Year-5 prose surface.  This is deliberately a prose
# candidate guard, not a replacement routing contract: R1b remains disabled.
ORDER118_BASELINE = "1f6026302f3f6d3e22d3df75c953efb2029bffe2"
ORDER118_EVENT_FILES = {
    "ko": (
        "content/events/arc_midgame.json",
        "content/events/arc_new_characters.json",
        "content/events/arc_pre_ending.json",
        "content/events/arc_drama.json",
    ),
    "en": (
        "content/events_en/arc_midgame.json",
        "content/events_en/arc_new_characters.json",
        "content/events_en/arc_pre_ending.json",
        "content/events_en/arc_drama.json",
    ),
}
ORDER118_STRICT_TOKEN = re.compile(
    r"(?<![A-Za-z])(?:NOT USED|SELF ONLY)(?![A-Za-z])"
    r"|(?<![A-Za-z0-9-])(?:TF-[A-Z0-9]+(?:-[A-Z0-9]+)*|SA-[0-9]+|(?:C|h)[0-9]+)(?![A-Za-z0-9-])"
    r"|(?<![A-Za-z0-9])(?=[A-F0-9]{4,8}(?![A-Za-z0-9]))(?=[A-F0-9]*[A-F])(?=[A-F0-9]*[0-9])[A-F0-9]{4,8}"
    r"|해시|(?i:hash)"
)
ORDER118_PLACEHOLDER = re.compile(r"\{[A-Za-z_][A-Za-z0-9_]*\}")


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

ORDER118_STARTUP_ROOTS = (
    RootSpec("arc_y5_startup_offer_c0", 49, 1),
    RootSpec("arc_y5_startup_c0_reviewer_delivery_minseo", 49, 1),
    RootSpec("arc_y5_startup_boundary_cofounder", 50, 3),
    RootSpec("arc_y5_startup_minseo_goal_cost", 51, 1),
    RootSpec("arc_y5_startup_after_goal_cofounder", 51, 3),
    RootSpec("arc_y5_startup_final_offer_acquirer", 52, 3),
    RootSpec("arc_y5_startup_reviewer_receipt_minseo", 54, 1),
    RootSpec("arc_y5_startup_three_in_room", 55, 1),
    RootSpec("arc_y5_startup_three_in_room_decision", 55, 3),
    RootSpec("arc_y5_startup_c2_sign_self", 57, 1),
    RootSpec("arc_y5_startup_c2_copy_delivered_cofounder", 57, 1),
    RootSpec("arc_y5_startup_people_verdict_cofounder", 58, 1),
    RootSpec("arc_y5_startup_contract_execution_c3", 59, 2),
    RootSpec("arc_y5_startup_c3_copy_delivered_cofounder", 59, 1),
    RootSpec("arc_final_countdown_startup_executed", 60, 3),
    RootSpec("arc_y5_final_week_startup_after_acquisition", 60, 1),
)
ORDER118_STARTUP_CHOICE_COUNTS = {
    spec.event_id: spec.choice_count for spec in ORDER118_STARTUP_ROOTS
}
ORDER118_STARTUP_IDS = set(ORDER118_STARTUP_CHOICE_COUNTS)

ORDER118_KO_ALLOWED_IDS = {
    "arc_y5_contract_cover_career",
    "arc_y5_contract_reviewer_delivery_minseo_career",
    "arc_y5_protection_boundary_hyunsu_career",
    "arc_y5_minseo_goal_cost_career",
    "arc_y5_after_goal_hyunsu_career",
    "arc_y5_final_offer_reference_delivery",
    "arc_y5_final_offer_jiyeon_reference",
    "arc_y5_three_in_room_decision_other_actor",
    "arc_y5_room_consent_receipt_jiyeon",
    "arc_y5_final_offer_career_boss",
    "arc_y5_career_reviewer_receipt_minseo",
    "arc_y5_three_in_room_career",
    "arc_y5_three_in_room_decision_career",
    "arc_y5_name_on_line_career_self",
    "arc_y5_name_copy_delivered_hyunsu_career",
    "arc_y5_people_verdict_career_hyunsu",
    "arc_y5_contract_execution_career",
    "arc_y5_contract_result_delivered_hyunsu_career",
    "arc_final_countdown_career_executed",
    "arc_y5_final_week_hyunsu_career_outbound",
    *ORDER118_STARTUP_IDS,
}
ORDER118_EN_ALLOWED_IDS = {
    *ORDER118_KO_ALLOWED_IDS,
    "arc_y5_three_in_room_decision_blocked_review",
    "arc_y5_room_consent_receipt_blocked_review",
    "arc_y5_name_on_line_self",
    "arc_y5_name_copy_not_delivered_self",
}
ORDER118_ALLOWED_IDS = {
    "ko": ORDER118_KO_ALLOWED_IDS,
    "en": ORDER118_EN_ALLOWED_IDS,
}
ROUTE_ROOTS = {
    "career_reference_v1": CAREER_ROOTS,
    "startup_acquisition_reference_v1": STARTUP_ROOTS,
}
R1A_ROOTS = {
    route_id: roots[:9]
    for route_id, roots in ROUTE_ROOTS.items()
}
EXPECTED_REJECTED_R1A_CONTRACT_SHA256 = "f4929ad915db417d716f5b62119cf6ab6f32d50026f4a62ed2e80859fb322014"
EXPECTED_REJECTED_ROUTE_MANIFEST_SHA256 = "0eb8bcefa0d167e5be29571260a2849bd389a4b7aaebbf0a55991d979635882f"
EXPECTED_REJECTED_PROSE_FILE_HASHES_SHA256 = "be104f89aed0b6661800df939398c2bb0d26108bd202a5718c417fdbcea282df"
EXPECTED_REJECTED_PROSE_OBJECT_HASHES_SHA256 = "17b6dae7997a75fbcc4fd0f7a71f0602720fa60efa2b612921d090ccb0336e14"
R1A_REJECTED_PAYLOAD_KEYS = (
    "lifecycle",
    "composition",
    "ingress_receipts",
    "external_blockers",
    "routes",
)
EXPECTED_REJECTED_SNAPSHOT = {
    "judged_by": "Claude(사용자 위임)",
    "source_commit": "803a372d4314d58d9ee03038bca3897bc2e18630",
    "source_tree": "f95a8dc44dcd61d8c09eef0d487436833c64d721",
    "reason": "ORDER-112 partial reject and ORDER-113 full reject invalidate the 9+9 literary topology",
    "rejected_contract_sha256": EXPECTED_REJECTED_R1A_CONTRACT_SHA256,
    "rejected_route_manifest_sha256": EXPECTED_REJECTED_ROUTE_MANIFEST_SHA256,
    "contract_route_count": 2,
    "contract_root_count": 18,
    "contract_choice_count": 50,
    "prose_file_count": 8,
    "prose_file_hashes_sha256": EXPECTED_REJECTED_PROSE_FILE_HASHES_SHA256,
    "prose_object_count": 64,
    "prose_object_hashes_sha256": EXPECTED_REJECTED_PROSE_OBJECT_HASHES_SHA256,
    "hash_semantics": "historical rejected evidence only; not current prose guards",
}
EXPECTED_UNRESOLVED_BLOCKERS_SHA256 = "50cb52705867689350a98085417417c619685bf598803d0db22d7d2f2a31798d"
EXPECTED_UNRESOLVED_BLOCKER_IDS = (
    "order112_113_l3_topology_rejected",
    "partner_none_decision_producer",
    "m48_actor_and_margin_producer",
    "startup_cofounder_actor_producer",
    "m49_route_lock_producer",
    "career_m53_external_handoff",
    "startup_m53_external_handoff",
    "career_c1_reviewer_handoff",
    "startup_h1_reviewer_handoff",
    "m56_m57_margin_producer",
    "live_infrastructure",
)
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
        "proposer": {
            "kind": "compatible_current_job_snapshot",
            "job_id_ref": "entry_snapshot.current_job.id",
            "has_job_ref": "entry_snapshot.flags.has_job",
            "required_has_job": True,
            "compatible_job_ids_ref": "route.entry.compatible_job_ids",
            "bound_job_id_field": "bound_job_id",
            "literal_actor_id": "boss",
            "invalidate_if_job_changes": True,
        },
        "counterparty": {"kind": "same_binding_as", "role": "proposer"},
        "reviewer": {"kind": "literal_actor", "actor_id": "minseo"},
        "protected": {
            "kind": "future_typed_receipt",
            "receipt_id": "m48_actor_trust",
            "field": "actor_id",
        },
        "affected": {"kind": "same_binding_as", "role": "protected"},
        "primary_witness": {"kind": "same_binding_as", "role": "protected"},
    },
    "startup_acquisition_reference_v1": {
        "proposer": {
            "kind": "scene_actor_confirmation",
            "producer_root_id": "arc_y5_startup_final_offer_acquirer",
            "producer_month": 52,
            "role_handle": "proposer",
            "literal_actor_id": "acquirer_lead",
        },
        "counterparty": {"kind": "same_binding_as", "role": "proposer"},
        "reviewer": {"kind": "literal_actor", "actor_id": "minseo"},
        "protected": {
            "kind": "future_typed_receipt",
            "receipt_id": "startup_founding",
            "field": "cofounder_actor_id",
        },
        "affected": {"kind": "same_binding_as", "role": "protected"},
        "primary_witness": {"kind": "same_binding_as", "role": "protected"},
    },
}

EXPECTED_DISTINCT_ROLE_GROUPS = [
    ["proposer", "counterparty"],
    ["reviewer"],
    ["protected", "affected", "primary_witness"],
]
EXPECTED_INVALIDATIONS = {
    "career_reference_v1": [
        "flags.has_job is false",
        "current_job.id differs from bound_job_id",
        "current_job.id is not in compatible_job_ids",
        "M48 remaining-person actor receipt is absent or is not hyunsu",
    ],
    "startup_acquisition_reference_v1": [
        "typed startup founding receipt or cofounder binding is absent",
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
        "r1a": {
            "months": [49, 50, 51, 52, 53, 54, 55],
            "activation_after_completion": False,
            "owns": ["contract correction", "dormant pure kernel", "QA injection only"],
        },
        "r1b": {
            "months": [49, 50, 51, 52, 53, 54, 55],
            "activation_after_completion": False,
            "owns": ["durable ledger", "producer hooks", "dispatcher and route-lock UI"],
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
    "current_product_consumer_count": 0,
    "current_qa_injection_consumer_count": 1,
    "dormant_kernel_owner": "systems/Year5ReferenceRouteKernel.gd",
    "literary_topology_status": "invalidated_by_delegated_l3",
    "r1b_allowed": False,
    "replacement_contract": None,
    "activation_preconditions": [
        "ORDER-112 and ORDER-113 replacement prose receives a new delegated L3 review",
        "a separate contract order replaces the rejected 9+9 topology",
        "R1b and R2 complete",
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
        "required_job_snapshot": {
            "flags_has_job": True,
            "bind_literal_actor_id": "boss",
            "persist_bound_job_id": True,
            "invalidate_on_bound_job_change_or_quit": True,
        },
        "required_ingress_receipt_ids": ["partner_none", "m48_actor_trust", "route_lock"],
        "route_lock": {
            "receipt_type": "route_lock",
            "producer_month": 49,
            "value": "career_reference_v1",
            "explicit": True,
            "silent_priority": False,
        },
    },
    "startup_acquisition_reference_v1": {
        "required_economic_path": "startup",
        "required_ingress_receipt_ids": [
            "partner_none", "m48_actor_trust", "startup_founding", "route_lock"
        ],
        "required_absent_flags": [
            "startup_exit",
            "startup_partial_exit",
            "startup_going_solo",
            "joined_startup",
        ],
        "route_lock": {
            "receipt_type": "route_lock",
            "producer_month": 49,
            "value": "startup_acquisition_reference_v1",
            "explicit": True,
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
    "arc_y5_final_offer_career_boss": "265d6e1b2eceac84e2476d316e4e7c894125f1783f999061f56136bf6a681e9e",
    "arc_y5_career_reviewer_receipt_minseo": "3f7bf728edc5fe81e36f168ba11f54d191641acb73985ce83b779a7645f4a7a0",
    "arc_y5_three_in_room_career": "9d6b0efab12d5c91fa18ee08aa7d5bfbd5d0f52d6ee6168942404d597ee85224",
    "arc_y5_three_in_room_decision_career": "4d90c9fadc2fc6eddbeb62e93a31fccbad5839a510a5a6c48b9bf03c281e6f51",
    "arc_y5_name_on_line_career_self": "bf1361e04557438e89334c4619613337bad6660a3c0d37cdaaa94d92a50652d3",
    "arc_y5_name_copy_delivered_hyunsu_career": "1366ba281dd461fb23395eed770efc1afd6cab9b36c40779383a2d13808eb561",
    "arc_y5_people_verdict_career_hyunsu": "2b951be1b02b3e178885e55c9f476f02996da4d6752255e8ac1758048f1e7555",
    "arc_y5_contract_execution_career": "41d58ee4f3f9efff30be88a893e4129eea444e817208eb4bae49c2273b3ab834",
    "arc_y5_contract_result_delivered_hyunsu_career": "a7c47b9ba6dc6954b3c8707c12b1f913923f8ff0c7091bf73684871aca7b671a",
    "arc_final_countdown_career_executed": "25fda3757fe86625be02cb3202ddd5b6f1262849b5b1c0f851978a60b8f9cee0",
    "arc_y5_final_week_hyunsu_career_outbound": "e1c164327b1789cb880c82f44593534d6d0db91ce172d28d09d380add1680374",
    "arc_y5_startup_offer_c0": "0b84256b7832b6c8e24b983f4b64ca7b2da07db26a7003f8d2f25f40351e0796",
    "arc_y5_startup_c0_reviewer_delivery_minseo": "0ac58cc0229abb3318d3003c8e8aee32865075f8f761d9f9f133ca8a65047a86",
    "arc_y5_startup_boundary_cofounder": "bce199090f274b61fcba82a710670a5f2f9aa240b7d2e5add5f7f0971663d07b",
    "arc_y5_startup_minseo_goal_cost": "15820342278bbef6e479ff9c72592783d3bcb77f681d058871e46afa8f3495cf",
    "arc_y5_startup_after_goal_cofounder": "572373318ee2ddd76759178458dd57a779391705e26cb6b90e819de170ae6f2c",
    "arc_y5_startup_final_offer_acquirer": "0dc06f0b947409d3b8c982276adcf38076378751ef66f9c37baf55eb21ca8cd4",
    "arc_y5_startup_reviewer_receipt_minseo": "c8f24c77193c0d5925de3e1ba673572d4332176c9d0263db0aede77c9896af44",
    "arc_y5_startup_three_in_room": "50939df9c6d1d93c77811a047c236da29dde17eff2660f7707a62429d14bc495",
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
    *LEGACY_MANIFEST_IDS,
    *EXPECTED_ROUTE_IDS,
    EVENT_LIFECYCLE_RELATIVE_PATH,
    KERNEL_RELATIVE_PATH,
    KERNEL_CLASS_TOKEN,
)

# These are causal receipts, not prose summaries.  A downstream root may add
# more local requirements/writes, but it may not abbreviate or omit these exact
# upstream facts.
REQUIRED_ROOT_TOKENS: dict[str, dict[str, list[str]]] = {
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
        "common_writes": [
            "actor_confirmation:boss:proposer",
            "document:C1",
            "document_holder:C1:player",
        ],
    },
    "arc_y5_career_reviewer_receipt_minseo": {
        "requirements": ["external_receipt:career_c1_reviewer_handoff"],
        "common_writes": ["document_holder:C1:player"],
    },
    "arc_y5_three_in_room_career": {
        "requirements": ["document_holder:C1:player"],
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
        "common_writes": ["actor_confirmation:acquirer_lead:proposer"],
    },
    "arc_y5_startup_reviewer_receipt_minseo": {
        "requirements": ["external_receipt:startup_h1_reviewer_handoff"],
        "common_writes": ["document_holder:h1:player"],
    },
    "arc_y5_startup_three_in_room": {
        "requirements": ["document_holder:h1:player"],
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
    "arc_y5_startup_final_offer_acquirer": {
        0: ["document:h1:91B4", "document_holder:h1:acquirer_lead"],
        1: ["document:h1:91B4", "document_holder:h1:acquirer_lead"],
        2: ["document:h1:91B4", "document_holder:h1:acquirer_lead"],
    },
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
SKIP_SCAN_DIRS = {".git", ".codex", ".godot", "docs", "tools", "tests", "test", "reports"}


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
        if rel == EVENT_LIFECYCLE_RELATIVE_PATH:
            continue
        if rel == KERNEL_RELATIVE_PATH:
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


def contract_is_invalidated(manifest: dict[str, Any]) -> bool:
    contract = manifest.get("r1a_contract")
    return (
        isinstance(contract, dict)
        and contract.get("contract_status") == INVALIDATED_CONTRACT_STATUS
    )


def validate_invalidated_r1a_contract(
    manifest: dict[str, Any],
    contract: dict[str, Any],
    errors: list[str],
) -> None:
    """Keep rejected evidence immutable without binding it to current prose."""
    if not exact_keys(
        contract,
        {
            "contract_status",
            "usable_for_r1b",
            "replacement_contract",
            "rejected_snapshot",
            *R1A_REJECTED_PAYLOAD_KEYS,
        },
        "manifest.r1a_contract",
        errors,
    ):
        return
    if contract.get("contract_status") != INVALIDATED_CONTRACT_STATUS:
        errors.append("manifest.r1a_contract.contract_status: rejected contract must remain invalidated")
    if contract.get("usable_for_r1b") is not False:
        errors.append("manifest.r1a_contract.usable_for_r1b: rejected contract must remain false")
    if contract.get("replacement_contract") is not None:
        errors.append("manifest.r1a_contract.replacement_contract: must remain null until a separate contract order")

    snapshot = contract.get("rejected_snapshot")
    if snapshot != EXPECTED_REJECTED_SNAPSHOT:
        errors.append("manifest.r1a_contract.rejected_snapshot: exact delegated-L3 rejected snapshot mismatch")

    rejected_payload = {
        key: contract.get(key)
        for key in R1A_REJECTED_PAYLOAD_KEYS
    }
    if canonical_json_sha256(rejected_payload) != EXPECTED_REJECTED_R1A_CONTRACT_SHA256:
        errors.append("manifest.r1a_contract.rejected_snapshot: rejected 9+9 contract digest mismatch")
    if canonical_json_sha256(manifest.get("routes")) != EXPECTED_REJECTED_ROUTE_MANIFEST_SHA256:
        errors.append("manifest.r1a_contract.rejected_snapshot: rejected route-manifest digest mismatch")

    protected = manifest.get("protected_hashes", {})
    protected_files = protected.get("files", {}) if isinstance(protected, dict) else {}
    rejected_file_hashes = {
        path: digest
        for path, digest in protected_files.items()
        if path in REJECTED_PROSE_FILES
    } if isinstance(protected_files, dict) else {}
    if (
        len(rejected_file_hashes) != 8
        or canonical_json_sha256(rejected_file_hashes)
        != EXPECTED_REJECTED_PROSE_FILE_HASHES_SHA256
    ):
        errors.append("manifest.r1a_contract.rejected_snapshot: rejected prose-file hash snapshot mismatch")

    protected_objects = protected.get("objects", []) if isinstance(protected, dict) else []
    rejected_objects = [
        row for row in protected_objects
        if isinstance(row, dict) and row.get("id") in ALL_TARGET_ID_SET
    ] if isinstance(protected_objects, list) else []
    if (
        len(rejected_objects) != 64
        or canonical_json_sha256(rejected_objects)
        != EXPECTED_REJECTED_PROSE_OBJECT_HASHES_SHA256
    ):
        errors.append("manifest.r1a_contract.rejected_snapshot: rejected 64-object prose hash snapshot mismatch")

    lifecycle = contract.get("lifecycle")
    if not isinstance(lifecycle, dict):
        errors.append("manifest.r1a_contract.lifecycle: exact dormant/product0/QA1 lifecycle mismatch")
        return
    if lifecycle.get("activation_after_completion") is not False:
        errors.append("manifest.r1a_contract.lifecycle.activation_after_completion: must remain false")
    if lifecycle.get("reference_only") is not True or lifecycle.get("reachability_claim") is not False:
        errors.append("manifest.r1a_contract.lifecycle: rejected contract must remain reference-only and unreachable")
    if lifecycle.get("dispatch_allowed") is not False:
        errors.append("manifest.r1a_contract.lifecycle.dispatch_allowed: must remain false")
    if lifecycle.get("product_consumer_count") != 0:
        errors.append("manifest.r1a_contract.lifecycle.product_consumer_count: must remain 0")
    if lifecycle.get("runtime_owner") is not None or lifecycle.get("save_adapter") is not None:
        errors.append("manifest.r1a_contract.lifecycle: runtime/save owners must remain null")
    if lifecycle.get("kernel_owner") != KERNEL_RELATIVE_PATH:
        errors.append("manifest.r1a_contract.lifecycle.kernel_owner: dormant kernel owner mismatch")


def validate_r1a_contract(
    manifest: dict[str, Any],
    routes: dict[str, dict[str, Any]],
    errors: list[str],
) -> None:
    """Require the delegated-L3 invalidation declaration on the current manifest."""
    contract = manifest.get("r1a_contract")
    if not isinstance(contract, dict):
        errors.append("manifest.r1a_contract: must be an object")
        return
    if contract.get("contract_status") != INVALIDATED_CONTRACT_STATUS:
        errors.append(
            "manifest.r1a_contract.contract_status: rejected contract must remain "
            f"{INVALIDATED_CONTRACT_STATUS!r}"
        )
        return
    validate_invalidated_r1a_contract(manifest, contract, errors)


def validate_legacy_r1a_contract(
    manifest: dict[str, Any],
    routes: dict[str, dict[str, Any]],
    errors: list[str],
) -> None:
    """Archived validator for the pre-verdict contract; not called in invalidated mode."""
    contract = manifest.get("r1a_contract")
    if not exact_keys(
        contract,
        {"lifecycle", "composition", "ingress_receipts", "external_blockers", "routes"},
        "manifest.r1a_contract",
        errors,
    ):
        return
    assert isinstance(contract, dict)
    if canonical_json_sha256(contract) != EXPECTED_REJECTED_R1A_CONTRACT_SHA256:
        errors.append("manifest.r1a_contract: exact dormant contract digest mismatch")

    lifecycle = contract.get("lifecycle")
    expected_lifecycle = {
        "name": "dormant_contract_kernel",
        "activation_after_completion": False,
        "reference_only": True,
        "reachability_claim": False,
        "dispatch_allowed": False,
        "runtime_owner": None,
        "save_adapter": None,
        "product_consumer_count": 0,
        "qa_injection_consumer_count": 1,
        "qa_injection_owner": "tools/Year5ReferenceRouteR1Check.gd",
        "kernel_owner": "systems/Year5ReferenceRouteKernel.gd",
    }
    if lifecycle != expected_lifecycle:
        errors.append("manifest.r1a_contract.lifecycle: exact dormant/product0/QA1 lifecycle mismatch")

    composition = contract.get("composition")
    expected_composition = {
        "root_source": "routes[*].roots selected by route root_ids",
        "effective_writes_order": ["common_writes", "choice.writes"],
        "atomic": True,
        "partial_writes_allowed": False,
        "exact_callback_replay": "success_noop",
        "different_choice_payload_or_order_replay": "reject",
        "persisted_duplicate_history_row": "reject",
        "derived_state_source": "immutable_history",
        "route_selection_policy": "explicit_lock_required_no_silent_priority",
    }
    if composition != expected_composition:
        errors.append("manifest.r1a_contract.composition: exact common+choice atomic history contract mismatch")

    ingress = contract.get("ingress_receipts")
    if not isinstance(ingress, dict) or list(ingress) != [
        "partner_none", "m48_actor_trust", "startup_founding", "route_lock"
    ]:
        errors.append("manifest.r1a_contract.ingress_receipts: exact ordered four-receipt registry required")
        ingress = {}
    partner = ingress.get("partner_none", {}) if isinstance(ingress, dict) else {}
    if not isinstance(partner, dict) or partner.get("implemented_in_product") is not False:
        errors.append("manifest.r1a_contract.ingress_receipts.partner_none: must remain a future product blocker")
    if isinstance(partner, dict):
        schema = partner.get("receipt_schema", {})
        if schema != {
            "exact_keys": ["receipt_type", "decision_id", "partner"],
            "constants": {
                "receipt_type": "relationship_decision",
                "decision_id": "partner_none",
                "partner": "none",
            },
        }:
            errors.append("manifest.r1a_contract.ingress_receipts.partner_none: exact typed decision schema mismatch")
        forbidden = partner.get("inference_forbidden", [])
        if forbidden != ["cast", "flags", "romance enum", "display name"]:
            errors.append("manifest.r1a_contract.ingress_receipts.partner_none: cast/flags inference must be forbidden")

    m48 = ingress.get("m48_actor_trust", {}) if isinstance(ingress, dict) else {}
    m48_schema = m48.get("receipt_schema", {}) if isinstance(m48, dict) else {}
    m48_constants = m48_schema.get("constants", {}) if isinstance(m48_schema, dict) else {}
    if not isinstance(m48, dict) or m48.get("implemented_in_product") is not False:
        errors.append("manifest.r1a_contract.ingress_receipts.m48_actor_trust: product producer must remain false")
    if m48_constants != {
        "receipt_type": "m48_actor_trust_margin",
        "producer_month": 48,
        "producer_root_id": "arc_year4_close",
        "axis": "trust",
        "expires_after_month": 49,
    }:
        errors.append("manifest.r1a_contract.ingress_receipts.m48_actor_trust: exact month/root/axis/expiry mismatch")
    if isinstance(m48_schema, dict):
        if m48_schema.get("exact_keys") != [
            "receipt_type", "route_id", "producer_month", "producer_root_id",
            "producer_choice_index", "actor_id", "axis", "expires_after_month",
        ]:
            errors.append("manifest.r1a_contract.ingress_receipts.m48_actor_trust: exact receipt keys mismatch")
        if m48_schema.get("allowed_values") != {"producer_choice_index": [0, 1, 2]}:
            errors.append("manifest.r1a_contract.ingress_receipts.m48_actor_trust: exact producer choice domain mismatch")
        if m48_schema.get("route_constants") != {
            "career_reference_v1": {"actor_id": "hyunsu"},
            "startup_acquisition_reference_v1": {"actor_id": "startup_cofounder"},
        }:
            errors.append("manifest.r1a_contract.ingress_receipts.m48_actor_trust: exact route actor mismatch")

    founding = ingress.get("startup_founding", {}) if isinstance(ingress, dict) else {}
    founding_constants = (
        founding.get("receipt_schema", {}).get("constants", {})
        if isinstance(founding, dict) and isinstance(founding.get("receipt_schema"), dict)
        else {}
    )
    if not isinstance(founding, dict) or founding.get("implemented_in_product") is not False:
        errors.append("manifest.r1a_contract.ingress_receipts.startup_founding: product producer must remain false")
    if founding_constants != {
        "receipt_type": "startup_founding",
        "producer_event_id": "startup_opportunity",
        "producer_choice_index": 0,
        "initial_cash_delta_krw": -3000000,
        "initial_equity_basis_points": 2000,
        "cofounder_actor_id": "startup_cofounder",
    }:
        errors.append("manifest.r1a_contract.ingress_receipts.startup_founding: exact event/choice/3M/2000bp/cofounder mismatch")
    if isinstance(founding, dict) and founding.get("inference_forbidden") != [
        "startup_founded flag", "money delta", "legacy save"
    ]:
        errors.append("manifest.r1a_contract.ingress_receipts.startup_founding: legacy flag/money inference must be forbidden")

    route_lock = ingress.get("route_lock", {}) if isinstance(ingress, dict) else {}
    lock_schema = route_lock.get("receipt_schema", {}) if isinstance(route_lock, dict) else {}
    if not isinstance(route_lock, dict) or route_lock.get("implemented_in_product") is not False:
        errors.append("manifest.r1a_contract.ingress_receipts.route_lock: product producer must remain false")
    if not isinstance(lock_schema, dict) or lock_schema.get("constants") != {
        "receipt_type": "route_lock", "producer_month": 49, "explicit": True
    } or lock_schema.get("allowed_values") != {"route_id": list(EXPECTED_ROUTE_IDS)}:
        errors.append("manifest.r1a_contract.ingress_receipts.route_lock: exact explicit M49 lock schema mismatch")

    unresolved_rows = manifest.get("unresolved_blockers", [])
    unresolved_ids = {
        str(row.get("id", ""))
        for row in unresolved_rows
        if isinstance(row, dict)
    } if isinstance(unresolved_rows, list) else set()
    for ingress_id in ("partner_none", "m48_actor_trust", "startup_founding", "route_lock"):
        row = ingress.get(ingress_id, {}) if isinstance(ingress, dict) else {}
        blocker_id = row.get("blocker_id") if isinstance(row, dict) else None
        if not isinstance(blocker_id, str) or blocker_id not in unresolved_ids:
            errors.append(f"manifest.r1a_contract.ingress_receipts.{ingress_id}: blocker_id must resolve to unresolved_blockers")

    blockers = contract.get("external_blockers")
    expected_blocker_ids = [
        "career_m53_external_handoff", "career_c1_reviewer_handoff",
        "startup_m53_external_handoff", "startup_h1_reviewer_handoff",
    ]
    if not isinstance(blockers, dict) or list(blockers) != expected_blocker_ids:
        errors.append("manifest.r1a_contract.external_blockers: exact ordered M53/custody blocker registry required")
        blockers = {}
    for blocker_id in expected_blocker_ids:
        if blocker_id not in unresolved_ids:
            errors.append(f"manifest.r1a_contract.external_blockers.{blocker_id}: must resolve to unresolved_blockers")
        blocker = blockers.get(blocker_id, {}) if isinstance(blockers, dict) else {}
        if not isinstance(blocker, dict):
            errors.append(f"manifest.r1a_contract.external_blockers.{blocker_id}: must be an object")
            continue
        if blocker.get("implemented_in_product") is not False or blocker.get("synthetic_fixture_only") is not True:
            errors.append(f"manifest.r1a_contract.external_blockers.{blocker_id}: must be unresolved and QA-fixture-only")
        schema = blocker.get("receipt_schema")
        if not isinstance(schema, dict) or set(schema) != {"exact_keys", "constants"}:
            errors.append(f"manifest.r1a_contract.external_blockers.{blocker_id}.receipt_schema: exact schema object required")
            continue
        constants = schema.get("constants")
        if not isinstance(constants, dict) or list(constants) != schema.get("exact_keys"):
            errors.append(f"manifest.r1a_contract.external_blockers.{blocker_id}.receipt_schema: exact_keys must match constants in order")
            continue
        if constants.get("blocker_id") != blocker_id or constants.get("source_kind") != "synthetic_future_fixture":
            errors.append(f"manifest.r1a_contract.external_blockers.{blocker_id}: exact blocker/source constants mismatch")
        if blocker_id.endswith("m53_external_handoff"):
            if constants.get("receipt_type") != "external_month_handoff" or constants.get("month") != 53 or constants.get("outcome_writes") != []:
                errors.append(f"manifest.r1a_contract.external_blockers.{blocker_id}: M53 must not forge outcome writes")
        else:
            expected_custody = {
                "career_c1_reviewer_handoff": {
                    "route_id": "career_reference_v1",
                    "document_version": "C1",
                    "document_id": None,
                    "document_hash": None,
                    "from_holder": "player",
                    "to_holder": "minseo",
                },
                "startup_h1_reviewer_handoff": {
                    "route_id": "startup_acquisition_reference_v1",
                    "document_version": "h1",
                    "document_id": "SA-20",
                    "document_hash": "91B4",
                    "from_holder": "acquirer_lead",
                    "to_holder": "minseo",
                },
            }[blocker_id]
            if constants.get("receipt_type") != "document_custody_handoff" or any(
                constants.get(key) != value for key, value in expected_custody.items()
            ):
                errors.append(f"manifest.r1a_contract.external_blockers.{blocker_id}: exact reviewer custody receipt required")

    segment_contracts = contract.get("routes")
    if not isinstance(segment_contracts, dict) or list(segment_contracts) != list(EXPECTED_ROUTE_IDS):
        errors.append("manifest.r1a_contract.routes: exact ordered two-route segment registry required")
        return
    total_roots = 0
    total_choices = 0
    for route_id in EXPECTED_ROUTE_IDS:
        segment = segment_contracts.get(route_id)
        if not exact_keys(
            segment,
            {
                "root_ids", "root_count", "choice_count", "entry_receipt_ids",
                "m53_blocker_id", "m54_blocker_id", "required_route_roles",
                "scene_actor_roles", "document_custody",
            },
            f"manifest.r1a_contract.routes[{route_id}]",
            errors,
        ):
            continue
        assert isinstance(segment, dict)
        specs = R1A_ROOTS[route_id]
        expected_ids = [spec.event_id for spec in specs]
        if segment.get("root_ids") != expected_ids or segment.get("root_count") != 9:
            errors.append(f"manifest.r1a_contract.routes[{route_id}]: exact nine-root M49-M55 order mismatch")
        expected_choice_count = sum(spec.choice_count for spec in specs)
        if segment.get("choice_count") != expected_choice_count or expected_choice_count != 25:
            errors.append(f"manifest.r1a_contract.routes[{route_id}]: exact 25-choice count mismatch")
        total_roots += int(segment.get("root_count", 0)) if isinstance(segment.get("root_count"), int) else 0
        total_choices += int(segment.get("choice_count", 0)) if isinstance(segment.get("choice_count"), int) else 0
        expected_entry_ids = ["partner_none", "m48_actor_trust", "route_lock"]
        if route_id == "startup_acquisition_reference_v1":
            expected_entry_ids.insert(2, "startup_founding")
        if segment.get("entry_receipt_ids") != expected_entry_ids:
            errors.append(f"manifest.r1a_contract.routes[{route_id}].entry_receipt_ids: exact fail-closed ingress mismatch")

        route = routes.get(route_id, {})
        roots_by_id = {
            str(root.get("id", "")): root
            for root in route.get("roots", [])
            if isinstance(root, dict)
        }
        required_roles = segment.get("required_route_roles")
        scene_roles = segment.get("scene_actor_roles")
        expected_required = {root_id: EXPECTED_ACTOR_ROLES[root_id] for root_id in expected_ids}
        expected_scene = copy.deepcopy(expected_required)
        expected_scene[expected_ids[0]] = []
        if required_roles != expected_required:
            errors.append(f"manifest.r1a_contract.routes[{route_id}].required_route_roles: exact role-handle map mismatch")
        if scene_roles != expected_scene:
            errors.append(f"manifest.r1a_contract.routes[{route_id}].scene_actor_roles: exact physical-scene actor map mismatch")
        if isinstance(required_roles, dict) and isinstance(scene_roles, dict):
            if required_roles.get(expected_ids[0]) == scene_roles.get(expected_ids[0]):
                errors.append(f"manifest.r1a_contract.routes[{route_id}]: M49 cover role handles must not imply scene actors")
        for root_id in expected_ids:
            root = roots_by_id.get(root_id, {})
            if root.get("actor_roles") != expected_required[root_id]:
                errors.append(f"manifest.r1a_contract.routes[{route_id}].required_route_roles: raw root role-handle mismatch for {root_id}")

        raw_entry_ids = route.get("entry", {}).get("required_ingress_receipt_ids")
        if raw_entry_ids != expected_entry_ids:
            errors.append(f"manifest.r1a_contract.routes[{route_id}].entry_receipt_ids: raw route entry mismatch")
        m53_id = segment.get("m53_blocker_id")
        m54_id = segment.get("m54_blocker_id")
        if m53_id not in blockers or m54_id not in blockers:
            errors.append(f"manifest.r1a_contract.routes[{route_id}]: blocker reference is missing")
        m53 = month_row(route, 53) or {}
        if not isinstance(m53.get("fallback_owner"), dict) or m53["fallback_owner"].get("blocker_id") != m53_id:
            errors.append(f"manifest.r1a_contract.routes[{route_id}]: M53 fallback/blocker cross-reference mismatch")
        m54_root = roots_by_id.get(expected_ids[6], {})
        if f"external_receipt:{m54_id}" not in m54_root.get("requirements", []):
            errors.append(f"manifest.r1a_contract.routes[{route_id}]: M54 read requires exact reviewer custody receipt")

    if total_roots != 18 or total_choices != 50:
        errors.append(f"manifest.r1a_contract: expected exact 18 roots/50 choices, got {total_roots}/{total_choices}")

    career_roots = {
        root.get("id"): root for root in routes.get("career_reference_v1", {}).get("roots", [])
        if isinstance(root, dict)
    }
    career_m52 = career_roots.get("arc_y5_final_offer_career_boss", {})
    for token in ("actor_confirmation:boss:proposer", "document:C1", "document_holder:C1:player"):
        if token not in career_m52.get("common_writes", []):
            errors.append(f"manifest.r1a_contract: career M52 missing exact actor/document/custody write {token!r}")

    startup_roots = {
        root.get("id"): root for root in routes.get("startup_acquisition_reference_v1", {}).get("roots", [])
        if isinstance(root, dict)
    }
    startup_m49 = startup_roots.get("arc_y5_startup_offer_c0", {})
    if any(str(write).startswith("actor_binding:acquirer_lead") for write in startup_m49.get("common_writes", [])):
        errors.append("manifest.r1a_contract: startup acquirer must not be bound by the M49 document-cover root")
    startup_m52 = startup_roots.get("arc_y5_startup_final_offer_acquirer", {})
    common = startup_m52.get("common_writes", [])
    if "document:h1:91B4" in common or "document_holder:h1:acquirer_lead" in common:
        errors.append("manifest.r1a_contract: startup M52 h1/custody must not leak through common_writes")
    choices = startup_m52.get("choices", [])
    if isinstance(choices, list) and len(choices) == 4:
        for choice_index in (0, 1, 2):
            writes = choices[choice_index].get("writes", {}) if isinstance(choices[choice_index], dict) else {}
            for token in ("document:h1:91B4", "document_holder:h1:acquirer_lead"):
                if token not in writes:
                    errors.append(f"manifest.r1a_contract: startup M52 choice {choice_index} missing {token!r}")
        terminal_effective = [*common, *choices[3].get("writes", [])]
        if any(str(write).startswith(("document:h1", "document_holder:h1")) for write in terminal_effective):
            errors.append("manifest.r1a_contract: startup M52 C4 terminal must produce zero h1/custody")


def validate_surface(manifest: Any, errors: list[str]) -> dict[str, dict[str, Any]]:
    if not exact_keys(manifest, TOP_LEVEL_KEYS, "manifest", errors):
        return {}
    assert isinstance(manifest, dict)
    if manifest.get("schema_version") != 2:
        errors.append("manifest.schema_version: expected integer 2")
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
    elif isinstance(blockers, list):
        blocker_ids = [str(row.get("id", "")) for row in blockers if isinstance(row, dict)]
        if len(blocker_ids) != len(blockers) or any(not blocker_id for blocker_id in blocker_ids):
            errors.append("manifest.unresolved_blockers: every row needs a non-empty id")
        if len(blocker_ids) != len(set(blocker_ids)):
            errors.append("manifest.unresolved_blockers: duplicate blocker id")
        if blocker_ids != list(EXPECTED_UNRESOLVED_BLOCKER_IDS):
            errors.append("manifest.unresolved_blockers: exact ordered blocker registry mismatch")
        if canonical_json_sha256(blockers) != EXPECTED_UNRESOLVED_BLOCKERS_SHA256:
            errors.append("manifest.unresolved_blockers: exact blocker problem/resolution digest mismatch")

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
                    "required_job_snapshot",
                    "required_ingress_receipt_ids",
                    "route_lock",
                },
                f"{owner}.entry",
                errors,
            )
            if entry.get("required_ingress_receipt_ids") != [
                "partner_none", "m48_actor_trust", "route_lock"
            ]:
                errors.append(f"{owner}.entry.required_ingress_receipt_ids: exact career provenance mismatch")
            if entry.get("required_job_snapshot") != {
                "flags_has_job": True,
                "bind_literal_actor_id": "boss",
                "persist_bound_job_id": True,
                "invalidate_on_bound_job_change_or_quit": True,
            }:
                errors.append(f"{owner}.entry.required_job_snapshot: exact has-job/bound-job contract mismatch")
            jobs = entry.get("compatible_job_ids")
            if not isinstance(jobs, list) or not jobs or len(jobs) != len(set(jobs)):
                errors.append(f"{owner}.entry.compatible_job_ids: unique non-empty canonical jobs required")
        else:
            exact_keys(
                entry,
                {
                    "required_economic_path",
                    "required_ingress_receipt_ids",
                    "required_absent_flags",
                    "route_lock",
                    "legacy_save_policy",
                },
                f"{owner}.entry",
                errors,
            )
            if entry.get("required_ingress_receipt_ids") != [
                "partner_none", "m48_actor_trust", "startup_founding", "route_lock"
            ]:
                errors.append(f"{owner}.entry.required_ingress_receipt_ids: exact startup provenance mismatch")
            if entry.get("required_absent_flags") != [
                "startup_exit",
                "startup_partial_exit",
                "startup_going_solo",
                "joined_startup",
            ]:
                errors.append(f"{owner}.entry.required_absent_flags: exact mutual exclusions required")
            if entry.get("legacy_save_policy") != "fail_closed_without_durable_mode":
                errors.append(f"{owner}.entry.legacy_save_policy: must fail closed")
        if entry.get("required_economic_path") != expected_path:
            errors.append(f"{owner}.entry.required_economic_path: expected {expected_path!r}")
        route_lock = entry.get("route_lock")
        if route_lock != {
            "receipt_type": "route_lock",
            "producer_month": 49,
            "value": route_id,
            "explicit": True,
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
            ("compatible_current_job_snapshot", "boss compatible-job snapshot source"),
            ("flags.has_job", "boss has-job source"),
            ("bound_job_id", "bound-job invalidation source"),
            ("literal", "Minseo literal source"),
            ("m48", "Hyunsu M48 receipt source"),
            ("hyunsu", "Hyunsu source"),
        ):
            if token not in actor_text:
                errors.append(f"{owner}.actors: missing {label}")
        for token in ("career", "m48", "partner_none", "has_job"):
            if token not in entry_text:
                errors.append(f"{owner}.entry: missing {token!r} entry provenance")
        try:
            jobs_payload = load_json(ROOT / "content" / "jobs.json")
        except (OSError, ValueError) as exc:
            errors.append(f"{owner}.entry.compatible_job_ids: cannot load canonical jobs ({exc})")
            jobs_payload = []
        canonical_job_ids = {
            str(row.get("id", ""))
            for row in jobs_payload
            if isinstance(jobs_payload, list) and isinstance(row, dict)
        }
        compatible_job_ids = route.get("entry", {}).get("compatible_job_ids", [])
        if not isinstance(compatible_job_ids, list) or any(
            job_id not in canonical_job_ids for job_id in compatible_job_ids
        ):
            errors.append(f"{owner}.entry.compatible_job_ids: every bound job must exist in content/jobs.json")
        try:
            job_system_text = (ROOT / "systems" / "JobSystem.gd").read_text(encoding="utf-8")
        except (OSError, UnicodeDecodeError) as exc:
            errors.append(f"{owner}.actors: cannot inspect flags.has_job lifecycle ({exc})")
        else:
            for producer_token in (
                'GameState.flags["has_job"] = true',
                'GameState.flags.erase("has_job")',
            ):
                if producer_token not in job_system_text:
                    errors.append(f"{owner}.actors: flags.has_job lifecycle producer missing {producer_token!r}")
    else:
        for token, label in (
            ("literal", "Minseo literal source"),
            ("52", "acquirer lead live-scene month"),
            ("final_offer_acquirer", "acquirer lead live-scene root"),
            ("found", "cofounder founding source"),
        ):
            if token not in actor_text:
                errors.append(f"{owner}.actors: missing {label}")
        for token in ("startup_founding", "partner_none", "startup_exit", "startup_partial_exit", "startup_going_solo", "joined_startup"):
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
        expected_m49_unresolved = [
            "partner-none typed decision producer",
            "M48 actor and same-axis margin typed producer",
        ]
        if route_id == "startup_acquisition_reference_v1":
            expected_m49_unresolved.append("startup founding typed cofounder/equity producer")
        expected_m49_unresolved.append("M49 explicit route-lock producer")
        if m49.get("unresolved") != expected_m49_unresolved:
            errors.append(f"{owner}.M49: exact unresolved ingress producer list mismatch")

    for month, token in ((50, "trust"), (52, "cash"), (54, "trust")):
        row = month_row(route, month)
        if row is None or token not in flattened(row.get("outgoing_margin")):
            errors.append(f"{owner}.M{month}: outgoing margin must produce {token}")

    m54 = month_row(route, 54)
    expected_m54_unresolved = [
        "career C1 reviewer custody handoff producer"
        if route_id == "career_reference_v1"
        else "startup h1 reviewer custody handoff producer"
    ]
    if m54 is None or m54.get("unresolved") != expected_m54_unresolved:
        errors.append(f"{owner}.M54: exact unresolved reviewer custody producer must be declared")

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
        blocker_id = (
            "career_m53_external_handoff"
            if route_id == "career_reference_v1"
            else "startup_m53_external_handoff"
        )
        expected_fallback = {
            "kind": "external_blocker",
            "blocker_id": blocker_id,
            "story_map_reference": {
                "month": 53,
                "beat_id": "m53_jaehyuk_guarantee",
                "root_id": "arc_jaehyuk_mirror",
                "rule_status": "needs_rule",
            },
            "product_owner": None,
            "forbidden_inferences": [
                "Jaehyuk guarantee outcome", "PDF result", "cash-margin expiry"
            ],
        }
        if m53.get("fallback_owner") != expected_fallback:
            errors.append(f"{owner}.M53: exact structured external-blocker fallback mismatch")
        if m53.get("unresolved") != [
            "product owner absent; synthetic future fixture is QA-only"
        ]:
            errors.append(f"{owner}.M53: product owner must remain unresolved and QA-only")
        if m53.get("root_order") != []:
            errors.append(f"{owner}.M53: route root_order must stay empty")
        fallback = m53.get("fallback_owner")
        if isinstance(fallback, dict):
            if fallback.get("product_owner") is not None:
                errors.append(f"{owner}.M53: product_owner must remain null")
            if any(key in fallback for key in ("writes", "margin_expiry", "guarantee_outcome")):
                errors.append(f"{owner}.M53: must not invent Jaehyuk/PDF/margin writes")

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
            common_writes = row.get("common_writes", [])
            effective_writes = [
                *(common_writes if isinstance(common_writes, list) else []),
                *writes,
            ]
            if len(effective_writes) != len(set(effective_writes)):
                errors.append(f"{choice_label}.effective_writes: common+choice writes must be unique and atomic")
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
                    str(write).startswith(("document:", "document_holder:", "transaction:", "finale_state:"))
                    for write in effective_writes
                ):
                    errors.append(f"{choice_label}.effective_writes: terminal must not continue document/transaction/finale")
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
            "current_product_consumer_count",
            "current_qa_injection_consumer_count",
            "dormant_kernel_owner",
            "literary_topology_status",
            "r1b_allowed",
            "replacement_contract",
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
    if planned_runtime.get("current_product_consumer_count") != 0:
        errors.append("manifest.planned_runtime.current_product_consumer_count: must be 0")
    if planned_runtime.get("current_qa_injection_consumer_count") != 1:
        errors.append("manifest.planned_runtime.current_qa_injection_consumer_count: must be 1")
    if planned_runtime.get("production_dispatcher") is not None:
        errors.append("manifest.planned_runtime.production_dispatcher: must be null")
    if planned_runtime.get("save_ledger_owner") is not None:
        errors.append("manifest.planned_runtime.save_ledger_owner: must be null")
    planned_text = flattened(planned_runtime)
    for token in ("r1b", "r2"):
        if token not in planned_text:
            errors.append(f"manifest.planned_runtime: missing future-only contract {token!r}")


def validate_invalidated_runtime(manifest: dict[str, Any], errors: list[str]) -> None:
    """Enforce the fail-closed runtime boundary without accepting old topology."""
    planned_runtime = manifest.get("planned_runtime")
    if not exact_keys(
        planned_runtime,
        {
            "current_product_consumer_count",
            "current_qa_injection_consumer_count",
            "dormant_kernel_owner",
            "literary_topology_status",
            "r1b_allowed",
            "replacement_contract",
            "activation_preconditions",
            "production_dispatcher",
            "save_ledger_owner",
        },
        "manifest.planned_runtime",
        errors,
    ):
        return
    assert isinstance(planned_runtime, dict)
    if planned_runtime != EXPECTED_PLANNED_RUNTIME:
        errors.append("manifest.planned_runtime: exact invalidated/R1b-HOLD contract mismatch")
    if planned_runtime.get("literary_topology_status") != INVALIDATED_CONTRACT_STATUS:
        errors.append("manifest.planned_runtime.literary_topology_status: must remain invalidated")
    if planned_runtime.get("r1b_allowed") is not False:
        errors.append("manifest.planned_runtime.r1b_allowed: rejected topology must keep R1b disabled")
    if planned_runtime.get("replacement_contract") is not None:
        errors.append("manifest.planned_runtime.replacement_contract: must remain null")
    if planned_runtime.get("current_product_consumer_count") != 0:
        errors.append("manifest.planned_runtime.current_product_consumer_count: must remain 0")
    if planned_runtime.get("current_qa_injection_consumer_count") != 1:
        errors.append("manifest.planned_runtime.current_qa_injection_consumer_count: must remain 1")
    if planned_runtime.get("production_dispatcher") is not None:
        errors.append("manifest.planned_runtime.production_dispatcher: must remain null")
    if planned_runtime.get("save_ledger_owner") is not None:
        errors.append("manifest.planned_runtime.save_ledger_owner: must remain null")


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


def order118_visible_leaves(event: dict[str, Any]) -> Iterator[tuple[str, Any]]:
    yield "title", event.get("title")
    yield "description", event.get("description")
    choices = event.get("choices")
    if not isinstance(choices, list):
        yield "choices", choices
        return
    for index, choice in enumerate(choices):
        if not isinstance(choice, dict):
            yield f"choices[{index}]", choice
            continue
        yield f"choices[{index}].text", choice.get("text")
        yield f"choices[{index}].result_text", choice.get("result_text")


def order118_nonprose_shape(event: dict[str, Any], *, replace_choices: bool) -> Any:
    candidate = copy.deepcopy(event)
    candidate.pop("title", None)
    candidate.pop("description", None)
    if replace_choices:
        candidate.pop("choices", None)
        return candidate
    choices = candidate.get("choices")
    if isinstance(choices, list):
        for choice in choices:
            if isinstance(choice, dict):
                choice.pop("text", None)
                choice.pop("result_text", None)
    return candidate


def validate_order118_prose_candidate(
    context: AuditContext,
    errors: list[str],
) -> dict[str, int]:
    """Guard the non-live ORDER-118 prose delta without reviving old routes."""
    changed: dict[str, set[str]] = {"ko": set(), "en": set()}
    token_count = 0
    startup_choice_count = 0
    for locale, relative_paths in ORDER118_EVENT_FILES.items():
        allowed = ORDER118_ALLOWED_IDS[locale]
        for relative in relative_paths:
            owner = f"ORDER-118:{locale}:{relative}"
            path = ROOT / relative
            try:
                current_payload = load_json(path)
                baseline_payload = strict_loads(
                    git_blob(ORDER118_BASELINE, relative).decode("utf-8"),
                    f"{ORDER118_BASELINE}:{relative}",
                )
            except (OSError, UnicodeDecodeError, ValueError) as exc:
                errors.append(f"{owner}: cannot load current/baseline prose ({exc})")
                continue
            disk_current_rows = event_rows(current_payload, owner, errors)
            baseline_rows = event_rows(baseline_payload, f"{owner}:baseline", errors)
            current_ids = [str(row.get("id", "")) for row in disk_current_rows]
            baseline_ids = [str(row.get("id", "")) for row in baseline_rows]
            if current_ids != baseline_ids:
                errors.append(f"{owner}: event ID/order drift outside the prose rewrite")
                continue
            if len(current_ids) != len(set(current_ids)):
                errors.append(f"{owner}: duplicate event ID")
                continue

            current_rows: list[dict[str, Any]] = []
            for event_id in baseline_ids:
                matches = [
                    record.row
                    for record in context.event_indexes[locale].get(event_id, [])
                    if record.path == relative
                ]
                if len(matches) != 1:
                    errors.append(
                        f"{owner}:{event_id}: expected one current context object, got {len(matches)}"
                    )
                    current_rows = disk_current_rows
                    break
                current_rows.append(matches[0])

            for current, baseline in zip(current_rows, baseline_rows):
                event_id = str(current.get("id", ""))
                label = f"{owner}:{event_id}"
                is_allowed = event_id in allowed
                is_changed = canonical_json_sha256(current) != canonical_json_sha256(baseline)
                if is_changed:
                    changed[locale].add(event_id)
                if not is_allowed:
                    if is_changed:
                        errors.append(f"{label}: non-target event object changed")
                elif not is_changed:
                    errors.append(f"{label}: declared prose target was not rewritten")

                if is_allowed:
                    startup = event_id in ORDER118_STARTUP_IDS
                    current_shape = order118_nonprose_shape(current, replace_choices=startup)
                    baseline_shape = order118_nonprose_shape(baseline, replace_choices=startup)
                    if current_shape != baseline_shape:
                        errors.append(f"{label}: metadata/non-prose structure drifted")
                    choices = current.get("choices")
                    if not isinstance(choices, list):
                        errors.append(f"{label}: choices must remain an array")
                    elif startup:
                        expected_count = ORDER118_STARTUP_CHOICE_COUNTS[event_id]
                        if len(choices) != expected_count:
                            errors.append(
                                f"{label}: expected ORDER-118 choice count {expected_count}, got {len(choices)}"
                            )
                        startup_choice_count += len(choices)
                        description = current.get("description")
                        if not isinstance(description, str) or not 300 <= len(description) <= 800:
                            errors.append(f"{label}: startup description must be 300-800 characters")
                        for index, choice in enumerate(choices):
                            if not isinstance(choice, dict) or set(choice) != {"text", "result_text"}:
                                errors.append(f"{label}: choice {index} must remain text-only")
                            elif not str(choice.get("text", "")).strip() or not str(choice.get("result_text", "")).strip():
                                errors.append(f"{label}: choice {index} has empty prose")

                for field, value in order118_visible_leaves(current):
                    if not isinstance(value, str):
                        errors.append(f"{label}:{field}: player-visible prose must be a string")
                        continue
                    matches = list(ORDER118_STRICT_TOKEN.finditer(value))
                    token_count += len(matches)
                    for match in matches[:4]:
                        errors.append(
                            f"{label}:{field}: internal document token remains {match.group(0)!r}"
                        )
                    if "`" in value:
                        errors.append(f"{label}:{field}: code-markup backtick remains in player prose")

    for event_id in sorted(ORDER118_EN_ALLOWED_IDS):
        ko_matches = context.event_indexes["ko"].get(event_id, [])
        en_matches = context.event_indexes["en"].get(event_id, [])
        if len(ko_matches) != 1 or len(en_matches) != 1:
            errors.append(
                f"ORDER-118:{event_id}: KO/EN placeholder source must resolve once "
                f"(ko={len(ko_matches)} en={len(en_matches)})"
            )
            continue
        ko_leaves = dict(order118_visible_leaves(ko_matches[0].row))
        en_leaves = dict(order118_visible_leaves(en_matches[0].row))
        if set(ko_leaves) != set(en_leaves):
            errors.append(f"ORDER-118:{event_id}: KO/EN player-field structure mismatch")
            continue
        for field in sorted(ko_leaves):
            ko_value = ko_leaves[field]
            en_value = en_leaves[field]
            if not isinstance(ko_value, str) or not isinstance(en_value, str):
                continue
            ko_placeholders = ORDER118_PLACEHOLDER.findall(ko_value)
            en_placeholders = ORDER118_PLACEHOLDER.findall(en_value)
            if ko_placeholders != en_placeholders:
                errors.append(
                    f"ORDER-118:{event_id}:{field}: KO/EN placeholder parity mismatch "
                    f"ko={ko_placeholders} en={en_placeholders}"
                )

    for locale, allowed in ORDER118_ALLOWED_IDS.items():
        if changed[locale] != allowed:
            missing = sorted(allowed - changed[locale])
            extra = sorted(changed[locale] - allowed)
            errors.append(
                f"ORDER-118:{locale}: exact changed-object set mismatch missing={missing[:8]} extra={extra[:8]}"
            )
    if startup_choice_count != 54:
        errors.append(
            "ORDER-118: expected exact 16 roots/27 choices in each locale "
            f"(54 localized choices), got {startup_choice_count}"
        )
    return {
        "order118_roots": len(ORDER118_STARTUP_ROOTS),
        "order118_choices": startup_choice_count // 2,
        "order118_tokens": token_count,
    }


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


def validate_kernel_boundary(errors: list[str]) -> None:
    path = ROOT / KERNEL_RELATIVE_PATH
    if not path.is_file():
        errors.append(f"{KERNEL_RELATIVE_PATH}: dormant kernel file is missing")
        return
    try:
        text = path.read_text(encoding="utf-8")
    except (OSError, UnicodeDecodeError) as exc:
        errors.append(f"{KERNEL_RELATIVE_PATH}: cannot read dormant kernel ({exc})")
        return
    if not re.search(r"(?m)^extends\s+RefCounted\s*$", text):
        errors.append(f"{KERNEL_RELATIVE_PATH}: kernel must extend RefCounted")
    required_functions = (
        "configure", "initial_state", "begin_route", "next_step", "commit_choice",
        "commit_external_receipt", "normalize_state", "snapshot",
    )
    for function_name in required_functions:
        if not re.search(rf"(?m)^func\s+{re.escape(function_name)}\s*\(", text):
            errors.append(f"{KERNEL_RELATIVE_PATH}: missing required pure API {function_name}()")
    forbidden_literals = (
        MANIFEST_PATH.relative_to(ROOT).as_posix(), EXPECTED_MANIFEST_ID,
        *EXPECTED_ROUTE_IDS, *ALL_TARGET_IDS,
    )
    for token in forbidden_literals:
        if token in text:
            errors.append(f"{KERNEL_RELATIVE_PATH}: injected-only kernel contains forbidden route/root/path literal {token!r}")
    for token in (
        "GameState", "SaveManager", "EventManager", "MainGame", "StoryMode",
        "EndingSystem", "FileAccess", "DirAccess", "ResourceLoader", "res://",
        "load(", "preload(", "queue_event", "trigger_event", "change_scene",
    ):
        if token in text:
            errors.append(f"{KERNEL_RELATIVE_PATH}: dormant kernel contains forbidden product/I-O token {token!r}")
    if '"dispatch_allowed": true' in text or "'dispatch_allowed': true" in text:
        errors.append(f"{KERNEL_RELATIVE_PATH}: dispatch_allowed must never be true")
    if text.count('"dispatch_allowed": false') < 2:
        errors.append(f"{KERNEL_RELATIVE_PATH}: every next kind must expose dispatch_allowed=false")


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
            "manifest.protected_hashes.files: exact 29 current + 8 rejected-snapshot file set mismatch "
            f"missing={missing_files} extra={extra_files}"
        )
    for relative, expected_hash in files.items():
        owner = f"manifest.protected_hashes.files[{relative!r}]"
        if not isinstance(expected_hash, str) or not HEX_64.fullmatch(expected_hash):
            errors.append(f"{owner}: invalid sha256")
            continue
        if relative in REJECTED_PROSE_FILES:
            # These eight hashes describe the rejected 803a372 prose snapshot.
            # They are intentionally not compared with current working-tree
            # prose, which ORDER-117/118 must be able to replace.
            continue
        path = safe_relative_path(relative, owner, errors)
        if path is None:
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
        if event_id in ALL_TARGET_ID_SET:
            # The 64 KO/EN rows are an immutable historical registry, checked
            # by rejected_snapshot digest above, not guards on replacement prose.
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

    rejected_snapshot_objects = {
        (
            str(row.get("locale", "")),
            str(row.get("file", "")),
            str(row.get("id", "")),
        )
        for row in objects
        if isinstance(row, dict) and row.get("id") in ALL_TARGET_ID_SET
    }
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
    required_objects = rejected_snapshot_objects | required_legacy_objects
    missing_target_objects = sorted(required_objects - object_keys)
    extra_objects = sorted(object_keys - required_objects)
    if missing_target_objects:
        errors.append(
            "manifest.protected_hashes.objects: missing rejected-snapshot/legacy KO/EN hashes "
            f"{missing_target_objects[:8]} (missing={len(missing_target_objects)})"
        )
    if extra_objects:
        errors.append(
            "manifest.protected_hashes.objects: exact registry is 64 rejected snapshot + "
            f"22 legacy objects; extras={extra_objects[:8]} (extra={len(extra_objects)})"
        )
    if len(object_keys) != 86:
        errors.append(
            "manifest.protected_hashes.objects: expected exact 64 rejected snapshot + "
            f"22 protected legacy objects, got {len(object_keys)}"
        )

    runtime = protected.get("runtime_consumers")
    if not exact_keys(runtime, RUNTIME_CONSUMER_KEYS, "manifest.protected_hashes.runtime_consumers", errors):
        return
    assert isinstance(runtime, dict)
    if runtime.get("expected_count") != 0:
        errors.append("manifest.protected_hashes.runtime_consumers.expected_count: must be 0")
    if runtime.get("qa_injection") != {
        "expected_count": 1,
        "owner": "tools/Year5ReferenceRouteR1Check.gd",
        "kernel_path": "systems/Year5ReferenceRouteKernel.gd",
        "contract_source": "caller_injected_dictionary",
        "production": False,
    }:
        errors.append("manifest.protected_hashes.runtime_consumers.qa_injection: exact QA-only consumer contract mismatch")
    qa_consumers: list[str] = []
    for qa_path in sorted((ROOT / "tools").rglob("*.gd")):
        try:
            qa_text = qa_path.read_text(encoding="utf-8")
        except (OSError, UnicodeDecodeError) as exc:
            errors.append(f"{qa_path.relative_to(ROOT).as_posix()}: cannot scan QA consumer ({exc})")
            continue
        if KERNEL_RELATIVE_PATH in qa_text or KERNEL_CLASS_TOKEN in qa_text:
            qa_consumers.append(qa_path.relative_to(ROOT).as_posix())
    if qa_consumers != [QA_INJECTION_RELATIVE_PATH]:
        errors.append(
            "QA injection consumer count must be exactly 1 and owned by "
            f"{QA_INJECTION_RELATIVE_PATH}; found {qa_consumers}"
        )
    else:
        qa_text = (ROOT / QA_INJECTION_RELATIVE_PATH).read_text(encoding="utf-8")
        if MANIFEST_PATH.relative_to(ROOT).as_posix() not in qa_text:
            errors.append("QA injection consumer must load the exact year5 reference manifest")
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
    order118_stats = {"order118_roots": 0, "order118_choices": 0, "order118_tokens": 0}
    validate_r1a_contract(manifest, routes, errors)
    invalidated = contract_is_invalidated(manifest)
    if invalidated:
        # Counts below are descriptive rejected-snapshot statistics only.  The
        # old route topology and event prose are deliberately not revalidated
        # as a current contract after delegated L3 rejection.
        for route in routes.values():
            roots = route.get("roots", []) if isinstance(route, dict) else []
            if not isinstance(roots, list):
                continue
            root_total += len(roots)
            choice_total += sum(
                int(row.get("choice_count", 0))
                for row in roots
                if isinstance(row, dict) and isinstance(row.get("choice_count"), int)
            )
        validate_invalidated_runtime(manifest, errors)
        order118_stats = validate_order118_prose_candidate(context, errors)
    else:
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
    if "order112_113_l3_topology_rejected" not in blocker_text:
        errors.append("manifest.unresolved_blockers: rejected literary topology must block R1b")
    for token in ("partner_none", "m48", "m49_route_lock", "m53", "m56", "margin"):
        if token not in blocker_text:
            errors.append(f"manifest.unresolved_blockers: missing unresolved {token!r} blocker")
    if "live_infrastructure" not in blocker_text and "production dispatcher" not in blocker_text:
        errors.append("manifest.unresolved_blockers: missing unresolved live runtime blocker")
    if "startup_cofounder_actor_producer" not in blocker_text or "startup_founded" not in blocker_text:
        errors.append(
            "manifest.unresolved_blockers: startup cofounder actor must remain a future typed producer blocker"
        )
    for blocker_id in ("career_c1_reviewer_handoff", "startup_h1_reviewer_handoff"):
        if blocker_id not in blocker_text:
            errors.append(f"manifest.unresolved_blockers: missing reviewer custody blocker {blocker_id!r}")
    validate_kernel_boundary(errors)
    validate_protected_hashes(manifest, context, errors, extra_runtime_sources)
    consumers = scan_runtime_consumers(context, extra_runtime_sources)
    r1a_routes = manifest.get("r1a_contract", {}).get("routes", {})
    r1a_root_total = sum(
        row.get("root_count", 0)
        for row in r1a_routes.values()
        if isinstance(r1a_routes, dict) and isinstance(row, dict) and isinstance(row.get("root_count"), int)
    ) if isinstance(r1a_routes, dict) else 0
    r1a_choice_total = sum(
        row.get("choice_count", 0)
        for row in r1a_routes.values()
        if isinstance(row, dict) and isinstance(row.get("choice_count"), int)
    ) if isinstance(r1a_routes, dict) else 0
    return errors, {
        "routes": len(routes),
        "roots": root_total,
        "choices": choice_total,
        "consumers": len(consumers),
        "r1a_roots": r1a_root_total,
        "r1a_choices": r1a_choice_total,
        **order118_stats,
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


def expect_context_failure(
    label: str,
    manifest: dict[str, Any],
    context: AuditContext,
    mutate: Callable[[AuditContext], None],
    expected_fragment: str,
    failures: list[str],
) -> None:
    candidate = copy.deepcopy(context)
    mutate(candidate)
    errors, _ = validate_manifest(copy.deepcopy(manifest), candidate)
    if not any(expected_fragment in error for error in errors):
        failures.append(
            f"{label}: context mutation was not rejected by {expected_fragment!r}; "
            f"errors={errors[:4]}"
        )


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


def run_invalidated_self_test(
    manifest: dict[str, Any],
    context: AuditContext,
) -> tuple[list[str], int]:
    """Negative tests for the fail-closed invalidated-contract mode."""
    failures: list[str] = []
    base_errors, _ = validate_manifest(manifest, context)
    if base_errors:
        return [f"baseline manifest is not valid: {base_errors[:8]}"], 0

    cases: list[tuple[str, Callable[[dict[str, Any]], None], str]] = []
    cases.append((
        "reachability_true",
        lambda data: data.__setitem__("reachability_claim", True),
        "reachability_claim",
    ))
    cases.append((
        "activation_mapped",
        lambda data: data.__setitem__("activation", "mapped"),
        "reference_only",
    ))
    cases.append((
        "contract_status_reenabled",
        lambda data: data["r1a_contract"].__setitem__("contract_status", "active"),
        "contract_status",
    ))

    def contract_invalidation_declaration_removed(data: dict[str, Any]) -> None:
        for key in (
            "contract_status",
            "usable_for_r1b",
            "replacement_contract",
            "rejected_snapshot",
        ):
            del data["r1a_contract"][key]

    cases.append((
        "contract_invalidation_declaration_removed",
        contract_invalidation_declaration_removed,
        "contract_status",
    ))
    cases.append((
        "contract_usable_for_r1b",
        lambda data: data["r1a_contract"].__setitem__("usable_for_r1b", True),
        "usable_for_r1b",
    ))
    cases.append((
        "contract_replacement_forged",
        lambda data: data["r1a_contract"].__setitem__("replacement_contract", {}),
        "replacement_contract",
    ))
    cases.append((
        "planned_r1b_enabled",
        lambda data: data["planned_runtime"].__setitem__("r1b_allowed", True),
        "r1b_allowed",
    ))
    cases.append((
        "planned_replacement_forged",
        lambda data: data["planned_runtime"].__setitem__("replacement_contract", {}),
        "replacement_contract",
    ))
    cases.append((
        "lifecycle_product_consumer_added",
        lambda data: data["r1a_contract"]["lifecycle"].__setitem__("product_consumer_count", 1),
        "product_consumer_count",
    ))
    cases.append((
        "lifecycle_dispatch_enabled",
        lambda data: data["r1a_contract"]["lifecycle"].__setitem__("dispatch_allowed", True),
        "dispatch_allowed",
    ))
    cases.append((
        "planned_product_consumer_added",
        lambda data: data["planned_runtime"].__setitem__("current_product_consumer_count", 1),
        "current_product_consumer_count",
    ))
    cases.append((
        "planned_dispatcher_added",
        lambda data: data["planned_runtime"].__setitem__("production_dispatcher", "EventManager"),
        "production_dispatcher",
    ))
    cases.append((
        "runtime_consumer_count_added",
        lambda data: data["protected_hashes"]["runtime_consumers"].__setitem__("expected_count", 1),
        "expected_count",
    ))

    def rejected_contract_route_changed(data: dict[str, Any]) -> None:
        data["r1a_contract"]["routes"]["career_reference_v1"]["root_count"] = 8

    def rejected_route_manifest_changed(data: dict[str, Any]) -> None:
        route_map(data)["startup_acquisition_reference_v1"]["roots"][0]["choice_count"] = 99

    def rejected_prose_file_hash_changed(data: dict[str, Any]) -> None:
        data["protected_hashes"]["files"]["content/events/arc_midgame.json"] = "0" * 64

    def rejected_prose_object_hash_changed(data: dict[str, Any]) -> None:
        row = next(
            row for row in data["protected_hashes"]["objects"]
            if row["id"] in ALL_TARGET_ID_SET
        )
        row["sha256"] = "0" * 64

    def legacy_object_hash_changed(data: dict[str, Any]) -> None:
        row = next(
            row for row in data["protected_hashes"]["objects"]
            if row["id"] in LEGACY_PROTECTED_IDS
        )
        row["sha256"] = "0" * 64

    def protected_runtime_hash_changed(data: dict[str, Any]) -> None:
        data["protected_hashes"]["files"]["systems/StoryMapMonthlyRuntime.gd"] = "0" * 64

    cases.extend(
        [
            ("rejected_contract_route_changed", rejected_contract_route_changed, "rejected 9+9 contract digest"),
            ("rejected_route_manifest_changed", rejected_route_manifest_changed, "rejected route-manifest digest"),
            ("rejected_prose_file_hash_changed", rejected_prose_file_hash_changed, "rejected prose-file hash snapshot"),
            ("rejected_prose_object_hash_changed", rejected_prose_object_hash_changed, "rejected 64-object prose hash snapshot"),
            ("legacy_object_hash_changed", legacy_object_hash_changed, "working-tree canonical object hash drifted"),
            ("protected_runtime_hash_changed", protected_runtime_hash_changed, "working-tree byte hash drifted"),
        ]
    )

    for label, mutate, fragment in cases:
        expect_failure(label, manifest, context, mutate, fragment, failures)
    case_count = len(cases)

    def candidate_record(candidate: AuditContext, locale: str, event_id: str) -> dict[str, Any]:
        return candidate.event_indexes[locale][event_id][0].row

    def order118_token_injected(candidate: AuditContext) -> None:
        candidate_record(candidate, "ko", ORDER118_STARTUP_ROOTS[0].event_id)["title"] += " NOT USED"

    def order118_version_token_injected(candidate: AuditContext) -> None:
        candidate_record(candidate, "ko", ORDER118_STARTUP_ROOTS[0].event_id)["title"] += " C4"

    def order118_deal_token_injected(candidate: AuditContext) -> None:
        candidate_record(candidate, "en", ORDER118_STARTUP_ROOTS[0].event_id)["title"] += " SA-21"

    def order118_document_id_injected(candidate: AuditContext) -> None:
        candidate_record(candidate, "en", ORDER118_STARTUP_ROOTS[0].event_id)["title"] += " TF-C4-SELF"

    def order118_backtick_injected(candidate: AuditContext) -> None:
        candidate_record(candidate, "ko", ORDER118_STARTUP_ROOTS[0].event_id)["title"] += " `제안`"

    def order118_placeholder_removed(candidate: AuditContext) -> None:
        event = candidate_record(candidate, "en", ORDER118_STARTUP_ROOTS[0].event_id)
        event["description"] = str(event["description"]).replace("{name}", "Minjun", 1)

    def order118_choice_added(candidate: AuditContext) -> None:
        event = candidate_record(candidate, "en", ORDER118_STARTUP_ROOTS[0].event_id)
        event["choices"].append({"text": "Wait", "result_text": "Wait."})

    def order118_short_description(candidate: AuditContext) -> None:
        candidate_record(candidate, "ko", ORDER118_STARTUP_ROOTS[1].event_id)["description"] = "짧다."

    def order118_state_write_added(candidate: AuditContext) -> None:
        candidate_record(candidate, "ko", ORDER118_STARTUP_ROOTS[2].event_id)["effects"] = {"money": 1}

    def order118_nonstartup_metadata_changed(candidate: AuditContext) -> None:
        candidate_record(candidate, "ko", "arc_y5_contract_cover_career")["category"] = "story"

    def order118_non_target_changed(candidate: AuditContext) -> None:
        for records in candidate.event_indexes["ko"].values():
            for record in records:
                if (
                    record.path == "content/events/arc_midgame.json"
                    and str(record.row.get("id", "")) not in ORDER118_KO_ALLOWED_IDS
                ):
                    record.row["title"] = str(record.row.get("title", "")) + " 변조"
                    return

    for label, mutate, fragment in (
        ("order118_player_token", order118_token_injected, "internal document token remains"),
        ("order118_version_token", order118_version_token_injected, "internal document token remains"),
        ("order118_deal_token", order118_deal_token_injected, "internal document token remains"),
        ("order118_document_id", order118_document_id_injected, "internal document token remains"),
        ("order118_backtick", order118_backtick_injected, "code-markup backtick remains"),
        ("order118_placeholder", order118_placeholder_removed, "placeholder parity mismatch"),
        ("order118_choice_count", order118_choice_added, "expected ORDER-118 choice count"),
        ("order118_description_length", order118_short_description, "300-800 characters"),
        ("order118_state_write", order118_state_write_added, "metadata/non-prose structure drifted"),
        ("order118_nonstartup_metadata", order118_nonstartup_metadata_changed, "metadata/non-prose structure drifted"),
        ("order118_non_target", order118_non_target_changed, "non-target event object changed"),
    ):
        case_count += 1
        expect_context_failure(label, manifest, context, mutate, fragment, failures)

    case_count += 1
    replacement_context = copy.deepcopy(context)
    replacement_record = replacement_context.event_indexes["ko"][ALL_TARGET_IDS[0]][0]
    replacement_record.row["title"] = "replacement prose intentionally remains unbound"
    replacement_errors, _ = validate_manifest(
        copy.deepcopy(manifest),
        replacement_context,
    )
    if replacement_errors:
        failures.append(
            "replacement_prose: invalidated audit still binds current target prose "
            f"errors={replacement_errors[:4]}"
        )

    case_count += 1
    with tempfile.TemporaryDirectory(prefix="year5-route-invalidated-audit-") as temporary:
        probe = Path(temporary) / "RuntimeConsumer.gd"
        probe_text = f'const ILLEGAL_ROOT = "{ALL_TARGET_IDS[0]}"\n'
        probe.write_text(probe_text, encoding="utf-8")
        errors, _ = validate_manifest(
            copy.deepcopy(manifest),
            context,
            extra_runtime_sources=[(str(probe), probe_text)],
        )
        if not any("production runtime consumer count must be 0" in error for error in errors):
            failures.append("runtime_consumer: temporary product dispatch was accepted")

    case_count += 1
    loader_probe = 'var reference_routes = load("res://content/meta/year5_reference_routes.json")\n'
    errors, _ = validate_manifest(
        copy.deepcopy(manifest),
        context,
        extra_runtime_sources=[("RuntimeManifestLoader.gd", loader_probe)],
    )
    if not any("production runtime consumer count must be 0" in error for error in errors):
        failures.append("runtime_manifest_loader: product manifest dispatch was accepted")

    case_count += 1
    lifecycle_loader_probe = (
        'var lifecycle = load("res://content/meta/event_lifecycle.json")\n'
    )
    errors, _ = validate_manifest(
        copy.deepcopy(manifest),
        context,
        extra_runtime_sources=[("RuntimeLifecycleLoader.gd", lifecycle_loader_probe)],
    )
    if not any("production runtime consumer count must be 0" in error for error in errors):
        failures.append(
            "runtime_lifecycle_loader: product lifecycle dispatch was accepted"
        )

    case_count += 1
    try:
        strict_loads('{"schema_version":1,"schema_version":2}', "self-test duplicate key")
    except ValueError as exc:
        if "duplicate JSON key" not in str(exc):
            failures.append(f"duplicate_json_key: wrong rejection {exc}")
    else:
        failures.append("duplicate_json_key: strict loader accepted a duplicate key")

    return failures, case_count


def run_self_test(manifest: dict[str, Any], context: AuditContext) -> tuple[list[str], int]:
    if contract_is_invalidated(manifest):
        return run_invalidated_self_test(manifest, context)
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
    cases.append(("m53_falsely_resolved", resolve_m53, "M53: product owner must remain unresolved"))
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
        root = next(row for row in route["roots"] if row["id"] == "arc_y5_startup_final_offer_acquirer")
        root["common_writes"].remove("actor_confirmation:acquirer_lead:proposer")

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
        data["scope"]["live_split"]["r1a"]["activation_after_completion"] = True

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

    def rejected_topology_r1b_enabled(data: dict[str, Any]) -> None:
        data["planned_runtime"]["r1b_allowed"] = True

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
            ("protected_file_deleted", protected_file_deleted, "exact 37-file baseline set mismatch"),
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
            ("rejected_topology_r1b_enabled", rejected_topology_r1b_enabled, "exact activation preconditions mismatch"),
        ]
    )

    def r1a_activation_enabled(data: dict[str, Any]) -> None:
        data["r1a_contract"]["lifecycle"]["activation_after_completion"] = True

    def partner_ingress_removed(data: dict[str, Any]) -> None:
        data["r1a_contract"]["routes"]["career_reference_v1"]["entry_receipt_ids"].remove(
            "partner_none"
        )

    def qa_injection_count_zero(data: dict[str, Any]) -> None:
        data["protected_hashes"]["runtime_consumers"]["qa_injection"]["expected_count"] = 0

    def fake_canonical_boss_source(data: dict[str, Any]) -> None:
        data["actor_registry"]["career_reference_v1"]["bindings"]["proposer"][
            "source"
        ] = "compatible_current_job.canonical_boss_role"

    def incomplete_m48_receipt(data: dict[str, Any]) -> None:
        schema = data["r1a_contract"]["ingress_receipts"]["m48_actor_trust"][
            "receipt_schema"
        ]
        schema["exact_keys"].remove("producer_choice_index")

    def cofounder_inferred_from_existing_state(data: dict[str, Any]) -> None:
        data["r1a_contract"]["ingress_receipts"]["startup_founding"][
            "implemented_in_product"
        ] = True

    def cover_role_handle_made_scene_actor(data: dict[str, Any]) -> None:
        route_contract = data["r1a_contract"]["routes"]["startup_acquisition_reference_v1"]
        route_contract["scene_actor_roles"]["arc_y5_startup_offer_c0"] = [
            "proposer", "protected"
        ]

    def startup_c4_common_h1_leak(data: dict[str, Any]) -> None:
        root = root_with_id(
            data, "startup_acquisition_reference_v1", "arc_y5_startup_final_offer_acquirer"
        )
        root["common_writes"].append("document:h1:91B4")

    def startup_c4_choice_h1_leak(data: dict[str, Any]) -> None:
        root = root_with_id(
            data, "startup_acquisition_reference_v1", "arc_y5_startup_final_offer_acquirer"
        )
        root["choices"][3]["writes"].append("document_holder:h1:acquirer_lead")

    def career_reviewer_custody_removed(data: dict[str, Any]) -> None:
        root = root_with_id(
            data, "career_reference_v1", "arc_y5_career_reviewer_receipt_minseo"
        )
        root["requirements"].remove("external_receipt:career_c1_reviewer_handoff")

    def startup_reviewer_custody_wrong_holder(data: dict[str, Any]) -> None:
        constants = data["r1a_contract"]["external_blockers"][
            "startup_h1_reviewer_handoff"
        ]["receipt_schema"]["constants"]
        constants["from_holder"] = "player"

    def m53_product_owner_forged(data: dict[str, Any]) -> None:
        row = month_row(route_map(data)["career_reference_v1"], 53)
        assert row is not None
        row["fallback_owner"]["product_owner"] = "generic_month_loop"

    def m53_guarantee_outcome_forged(data: dict[str, Any]) -> None:
        constants = data["r1a_contract"]["external_blockers"][
            "startup_m53_external_handoff"
        ]["receipt_schema"]["constants"]
        constants["outcome_writes"] = ["story.jaehyuk_guarantee_resolution=vouched"]

    cases.extend(
        [
            ("r1a_activation_enabled", r1a_activation_enabled, "exact dormant/product0/QA1 lifecycle"),
            ("qa_injection_count_zero", qa_injection_count_zero, "exact QA-only consumer contract"),
            ("partner_ingress_removed", partner_ingress_removed, "exact fail-closed ingress"),
            ("fake_canonical_boss_source", fake_canonical_boss_source, "exact provenance mismatch"),
            ("incomplete_m48_receipt", incomplete_m48_receipt, "exact receipt keys mismatch"),
            ("cofounder_inferred_from_existing_state", cofounder_inferred_from_existing_state, "product producer must remain false"),
            ("cover_role_handle_made_scene_actor", cover_role_handle_made_scene_actor, "exact physical-scene actor map"),
            ("startup_c4_common_h1_leak", startup_c4_common_h1_leak, "h1/custody must not leak through common_writes"),
            ("startup_c4_choice_h1_leak", startup_c4_choice_h1_leak, "C4 terminal must produce zero h1/custody"),
            ("career_reviewer_custody_removed", career_reviewer_custody_removed, "M54 read requires exact reviewer custody receipt"),
            ("startup_reviewer_custody_wrong_holder", startup_reviewer_custody_wrong_holder, "exact reviewer custody receipt required"),
            ("m53_product_owner_forged", m53_product_owner_forged, "exact structured external-blocker fallback"),
            ("m53_guarantee_outcome_forged", m53_guarantee_outcome_forged, "M53 must not forge outcome writes"),
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

    case_count += 1
    lifecycle_loader_probe = (
        'var lifecycle = load("res://content/meta/event_lifecycle.json")\n'
    )
    errors, _ = validate_manifest(
        copy.deepcopy(manifest),
        context,
        extra_runtime_sources=[("RuntimeLifecycleLoader.gd", lifecycle_loader_probe)],
    )
    if not any("production runtime consumer count must be 0" in error for error in errors):
        failures.append(
            "runtime_lifecycle_loader: product lifecycle dispatch was accepted"
        )

    for label, forbidden_token in (
        ("runtime_manifest_id", EXPECTED_MANIFEST_ID),
        ("runtime_legacy_manifest_id", LEGACY_MANIFEST_IDS[0]),
        ("runtime_career_route_id", EXPECTED_ROUTE_IDS[0]),
        ("runtime_startup_route_id", EXPECTED_ROUTE_IDS[1]),
        ("runtime_kernel_path", KERNEL_RELATIVE_PATH),
        ("runtime_kernel_class", KERNEL_CLASS_TOKEN),
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
            f"cases={cases} rejected_snapshot_routes={stats['routes']} "
            f"rejected_snapshot_roots={stats['roots']} rejected_snapshot_choices={stats['choices']} "
            f"rejected_r1a_roots={stats['r1a_roots']} rejected_r1a_choices={stats['r1a_choices']} "
            f"order118_roots={stats['order118_roots']} order118_choices={stats['order118_choices']} "
            f"order118_tokens={stats['order118_tokens']} "
            f"product_consumers={stats['consumers']} "
            "qa_consumers=1 topology=invalidated r1b_allowed=false"
        )
        return 0

    print(
        "YEAR5_REFERENCE_ROUTE_OK "
        f"rejected_snapshot_routes={stats['routes']} rejected_snapshot_roots={stats['roots']} "
        f"rejected_snapshot_choices={stats['choices']} rejected_r1a_roots={stats['r1a_roots']} "
        f"rejected_r1a_choices={stats['r1a_choices']} "
        f"order118_roots={stats['order118_roots']} order118_choices={stats['order118_choices']} "
        f"order118_tokens={stats['order118_tokens']} "
        f"product_consumers={stats['consumers']} qa_consumers=1 activation=reference_only "
        "topology=invalidated r1b_allowed=false"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
