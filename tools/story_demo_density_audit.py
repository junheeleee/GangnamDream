#!/usr/bin/env python3
"""Measure the exact active M01-M06 story-demo choice topology.

This is a read-only, candidate-pinned audit.  Product sources are read only as
Git blobs from the fixture's exact ``source_ref``.  The working tree is used for
the audit fixture and the active human-gate registry only; there is deliberately
no fallback from a missing Git blob to a working-tree product file.

Automation closes the identity and structural measurement contract.  Findings
about density remain findings, and the human route-density/fun gate stays open.
"""

from __future__ import annotations

import argparse
import ast
import copy
import hashlib
import json
import re
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path, PurePosixPath
from typing import Any, Dict, Iterable, List, Mapping, Optional, Sequence, Set, Tuple


ROOT = Path(__file__).resolve().parents[1]
FIXTURE_PATH = ROOT / "tools" / "fixtures" / "story_demo_density_contract.json"
HUMAN_GATES_PATH = ROOT / "docs" / "human_gates.json"

PROFILE = "story_demo_rc"
EXPECTED_SOURCE_REF = "4e80a63e89821094b8bab21b8d5c73ecfc9b6278"
EXPECTED_SOURCE_TREE = "0fdddf11e2ef030cd172d23e691e3d7da4ea29ff"
EXPECTED_BUILD_ID = "2026.08.31.1"
ENTRY_SCENE = "res://playtests/order124/StoryChoiceM1M6Playtest.tscn"
CUSTOM_USER_DIR = "GangnamDream_StoryDemo_v1"
SAVE_PATH = "user://story_demo_save.json"
CONTROLLER_PATH = "playtests/order124/StoryChoiceM1M6Playtest.gd"
ARC_EVENTS_PATH = "content/events/arc_events.json"
DAEUN_EVENTS_PATH = "content/events/arc_daeun.json"
CORE_EVENTS_PATH = "content/events/core_loop_v2_events.json"
STORY_MODE_PATH = "scenes/StoryMode.gd"
GAME_STATE_PATH = "autoloads/GameState.gd"
STORY_CHOICE_CHECK_PATH = "tools/StoryChoiceM1M6Check.gd"
FOUR_LANGUAGE_CHECK_PATH = "tools/StoryDemoFourLanguageCheck.gd"

REQUIRED_SOURCE_BLOBS = {
    CONTROLLER_PATH,
    ARC_EVENTS_PATH,
    DAEUN_EVENTS_PATH,
    CORE_EVENTS_PATH,
    STORY_MODE_PATH,
    GAME_STATE_PATH,
    STORY_CHOICE_CHECK_PATH,
    FOUR_LANGUAGE_CHECK_PATH,
}

# ORDER-140 is an exact-candidate measurement, not a moving-HEAD audit.  Keep
# the reviewed source identity in executable code as well as the data fixture,
# so editing the fixture cannot silently retarget or rewrite the evidence.
EXPECTED_BLOB_SHA256 = {
    CONTROLLER_PATH:
        "0504304cfb92502894d2daa46d5459ab321ac5dd39f4dbb322dc39d2601080e1",
    ARC_EVENTS_PATH:
        "41febd1d1fd6b68f146171b02bf64a144699b39d1dd03c75444e72a518676d99",
    DAEUN_EVENTS_PATH:
        "29a1f84fa411d03660f6e2283f3302a5f1f7c9b264a923c916b4484e9699748d",
    CORE_EVENTS_PATH:
        "30ce137faf06437e131d297efa7ab3fc82806534e77c53bea33af0b01a750b87",
    STORY_MODE_PATH:
        "7ec09c661c708f6f096502f41161ae9b6373003a7df21a0194e2870c5ce9beee",
    GAME_STATE_PATH:
        "21c7547fe171e742a2fdda851a8b2cfdcf07132f6b5002e1df68ea3a97e22028",
    STORY_CHOICE_CHECK_PATH:
        "d9c8edb1e7317dcc506ef620d6da4f352511c25b8c87412dd6d837a362659471",
    FOUR_LANGUAGE_CHECK_PATH:
        "df12e1dd57eb768c40ac5beec563b845a03bac9639a4b9506050e14278f1d7eb",
}

COMMIT_RE = re.compile(r"^[0-9a-f]{40}$")
SHA256_RE = re.compile(r"^[0-9a-f]{64}$")
BUILD_RE = re.compile(r"\bBUILD\s+(\d{4}\.\d{2}\.\d{2}\.\d+)\b")
CHOICE_KEY_RE = re.compile(r"^(.+)#([0-9]+)$")

AXES = {"people", "livelihood", "body", "money"}
MODES = {"decision", "memory", "expression", "bridge"}
RISK_ROLES = {
    "none", "refusal", "acceptance", "refusal_cost", "restitution",
    "escalation",
}
INGRESS_KINDS = {
    "month_root", "route", "ordered_after", "choice_follow_up",
    "branch_join", "synthetic_month_root", "deferred_claim",
    "route_consequence", "route_join",
}
CONSUMER_KINDS = {
    "runtime_receipt", "recap", "route", "follow_up",
    "deferred_follow_up", "history_reader",
}

EXPECTED_RUNTIME_SOURCES: Dict[str, Tuple[int, str, str, int]] = {
    "arc_temptation_01": (1, ARC_EVENTS_PATH, "arc_temptation_01", 2),
    "arc_temptation_clean": (2, ARC_EVENTS_PATH, "arc_temptation_clean", 1),
    "arc_temptation_fallout": (2, ARC_EVENTS_PATH, "arc_temptation_fallout", 2),
    "arc_daeun_01_meet": (3, DAEUN_EVENTS_PATH, "arc_daeun_01_meet", 2),
    "arc_jiyeon_01_crash": (3, ARC_EVENTS_PATH, "arc_jiyeon_01_crash", 3),
    "arc_sangchul_01_meet": (4, ARC_EVENTS_PATH, "arc_sangchul_01_meet", 2),
    "arc_sangchul_01_measure": (4, ARC_EVENTS_PATH, "arc_sangchul_01_measure", 1),
    "arc_sangchul_01_coffee": (4, ARC_EVENTS_PATH, "arc_sangchul_01_coffee", 1),
    "arc_sangchul_01_answer": (4, ARC_EVENTS_PATH, "arc_sangchul_01_answer", 3),
    "arc_jaehyuk_01_reunion": (5, ARC_EVENTS_PATH, "arc_jaehyuk_01_reunion", 2),
    "v2_dirty_trace_initial_call": (
        6, CORE_EVENTS_PATH, "v2_dirty_trace_initial_call", 2),
    "v2_dirty_recruiter_week24": (
        6, CORE_EVENTS_PATH, "v2_dirty_recruiter_week24", 2),
    "order124_m6_first_bill": (6, CORE_EVENTS_PATH, "v2_demo_first_bill", 5),
    "v2_demo_first_bill_ledger": (
        6, CORE_EVENTS_PATH, "v2_demo_first_bill_ledger", 1),
}

EXPECTED_INGRESS_BY_RUNTIME = {
    "arc_temptation_01": "month_root",
    "arc_temptation_clean": "route",
    "arc_temptation_fallout": "route",
    "arc_daeun_01_meet": "month_root",
    "arc_jiyeon_01_crash": "ordered_after",
    "arc_sangchul_01_meet": "month_root",
    "arc_sangchul_01_measure": "choice_follow_up",
    "arc_sangchul_01_coffee": "choice_follow_up",
    "arc_sangchul_01_answer": "branch_join",
    "arc_jaehyuk_01_reunion": "month_root",
    "v2_dirty_trace_initial_call": "deferred_claim",
    "v2_dirty_recruiter_week24": "route_consequence",
    "order124_m6_first_bill": "route_join",
    "v2_demo_first_bill_ledger": "choice_follow_up",
}

EXPECTED_INGRESS: Dict[str, Dict[str, Any]] = {
    "arc_temptation_01": {"kind": "month_root"},
    "arc_temptation_clean": {
        "kind": "route", "producer_choice": "arc_temptation_01#0",
    },
    "arc_temptation_fallout": {
        "kind": "route", "producer_choice": "arc_temptation_01#1",
    },
    "arc_daeun_01_meet": {"kind": "month_root"},
    "arc_jiyeon_01_crash": {
        "kind": "ordered_after", "predecessor_event_id": "arc_daeun_01_meet",
    },
    "arc_sangchul_01_meet": {"kind": "month_root"},
    "arc_sangchul_01_measure": {
        "kind": "choice_follow_up",
        "producer_choice": "arc_sangchul_01_meet#0",
    },
    "arc_sangchul_01_coffee": {
        "kind": "choice_follow_up",
        "producer_choice": "arc_sangchul_01_meet#1",
    },
    "arc_sangchul_01_answer": {
        "kind": "branch_join",
        "producer_choices": [
            "arc_sangchul_01_measure#0", "arc_sangchul_01_coffee#0",
        ],
    },
    "arc_jaehyuk_01_reunion": {"kind": "month_root"},
    "v2_dirty_trace_initial_call": {
        "kind": "deferred_claim",
        "producer_choice": "arc_temptation_fallout#0",
        "source_event_id": "callback_escaped_dirty_trace",
        "trigger_turn": 21,
    },
    "v2_dirty_recruiter_week24": {
        "kind": "route_consequence",
        "producer_choice": "arc_temptation_fallout#1",
        "source_flag": "fell_to_darkness",
        "trigger_turn": 21,
    },
    "order124_m6_first_bill": {
        "kind": "route_join",
        "predecessor_event_ids": [
            "v2_dirty_trace_initial_call", "v2_dirty_recruiter_week24",
        ],
        "clean_direct": True,
    },
    "v2_demo_first_bill_ledger": {
        "kind": "choice_follow_up",
        "producer_choices": [
            "order124_m6_first_bill#0", "order124_m6_first_bill#1",
            "order124_m6_first_bill#2", "order124_m6_first_bill#3",
            "order124_m6_first_bill#4",
        ],
    },
}

M6_RUNTIME_ID = "order124_m6_first_bill"
M6_SOURCE_ID = "v2_demo_first_bill"
M6_LEDGER_ID = "v2_demo_first_bill_ledger"
M6_RESTITUTION_ROOT_ID = "v2_dirty_trace_initial_call"
M6_ESCALATION_ROOT_ID = "v2_dirty_recruiter_week24"
M6_SOURCE_CHOICES = [3, 4, 5, 6, 7]
M6_STRIP_EXACT = {"follow_up_event", "deferred_follow_up", "deferred_delay"}

EXPECTED_MODE_BY_CHOICE: Dict[str, str] = {
    "arc_temptation_01#0": "decision",
    "arc_temptation_01#1": "decision",
    "arc_temptation_clean#0": "bridge",
    "arc_temptation_fallout#0": "decision",
    "arc_temptation_fallout#1": "decision",
    "arc_daeun_01_meet#0": "memory",
    "arc_daeun_01_meet#1": "memory",
    "arc_jiyeon_01_crash#0": "memory",
    "arc_jiyeon_01_crash#1": "memory",
    "arc_jiyeon_01_crash#2": "memory",
    "arc_sangchul_01_meet#0": "expression",
    "arc_sangchul_01_meet#1": "expression",
    "arc_sangchul_01_measure#0": "bridge",
    "arc_sangchul_01_coffee#0": "bridge",
    "arc_sangchul_01_answer#0": "memory",
    "arc_sangchul_01_answer#1": "expression",
    "arc_sangchul_01_answer#2": "memory",
    "arc_jaehyuk_01_reunion#0": "memory",
    "arc_jaehyuk_01_reunion#1": "memory",
    "v2_dirty_trace_initial_call#0": "decision",
    "v2_dirty_trace_initial_call#1": "decision",
    "v2_dirty_recruiter_week24#0": "decision",
    "v2_dirty_recruiter_week24#1": "decision",
    "order124_m6_first_bill#0": "decision",
    "order124_m6_first_bill#1": "decision",
    "order124_m6_first_bill#2": "decision",
    "order124_m6_first_bill#3": "decision",
    "order124_m6_first_bill#4": "decision",
    "v2_demo_first_bill_ledger#0": "expression",
}

EXPECTED_RISK_BY_CHOICE = {key: "none" for key in EXPECTED_MODE_BY_CHOICE}
EXPECTED_RISK_BY_CHOICE.update({
    "arc_temptation_01#0": "refusal",
    "arc_temptation_01#1": "acceptance",
    "arc_temptation_clean#0": "refusal_cost",
    "arc_temptation_fallout#0": "restitution",
    "arc_temptation_fallout#1": "escalation",
    "v2_dirty_trace_initial_call#0": "restitution",
    "v2_dirty_trace_initial_call#1": "restitution",
    "v2_dirty_recruiter_week24#0": "escalation",
    "v2_dirty_recruiter_week24#1": "escalation",
})

LEDGER_EXPRESSION_CHOICE = "%s#0" % M6_LEDGER_ID
EXPECTED_RECEIPT_CHOICES = set(EXPECTED_MODE_BY_CHOICE) - {
    LEDGER_EXPRESSION_CHOICE,
}

# Human-reviewed semantic classification.  These are deliberately exact
# ordered tuples: a fixture-only edit must not be able to invent a sacrifice
# and make a measured density gap disappear.
EXPECTED_AXES_BY_CHOICE: Dict[str, Tuple[Tuple[str, ...], Tuple[str, ...]]] = {
    "arc_temptation_01#0": (("livelihood",), ("money", "body")),
    "arc_temptation_01#1": (("money",), ("people", "body")),
    "arc_temptation_clean#0": (("livelihood", "money"), ("body",)),
    "arc_temptation_fallout#0": (("people", "money"), ("money", "body")),
    "arc_temptation_fallout#1": (("money",), ("people", "body")),
    "arc_daeun_01_meet#0": (("people",), ()),
    "arc_daeun_01_meet#1": (("people",), ("people",)),
    "arc_jiyeon_01_crash#0": (("people",), ("people", "money", "body")),
    "arc_jiyeon_01_crash#1": (("money",), ("people",)),
    "arc_jiyeon_01_crash#2": (("people", "body"), ("money", "body")),
    "arc_sangchul_01_meet#0": (("people",), ()),
    "arc_sangchul_01_meet#1": (("people",), ()),
    "arc_sangchul_01_measure#0": (("people",), ()),
    "arc_sangchul_01_coffee#0": (("people",), ()),
    "arc_sangchul_01_answer#0": (("people",), ()),
    "arc_sangchul_01_answer#1": (("money",), ("people", "body")),
    "arc_sangchul_01_answer#2": (("livelihood",), ()),
    "arc_jaehyuk_01_reunion#0": (("people",), ()),
    "arc_jaehyuk_01_reunion#1": (("people",), ("people", "body")),
    "v2_dirty_trace_initial_call#0": (("people",), ("body",)),
    "v2_dirty_trace_initial_call#1": (("livelihood",), ("body",)),
    "v2_dirty_recruiter_week24#0": (("people",), ("body",)),
    "v2_dirty_recruiter_week24#1": (("livelihood",), ("body",)),
    "order124_m6_first_bill#0": (
        ("people",), ("people", "livelihood", "body", "money")),
    "order124_m6_first_bill#1": (
        ("people",), ("people", "livelihood", "body", "money")),
    "order124_m6_first_bill#2": (
        ("money",), ("people", "livelihood", "body", "money")),
    "order124_m6_first_bill#3": (
        ("livelihood", "money"), ("people", "body", "money")),
    "order124_m6_first_bill#4": (
        ("body",), ("people", "livelihood", "money")),
    "v2_demo_first_bill_ledger#0": ((), ()),
}

EXPECTED_CONSUMERS: Dict[str, Dict[str, Any]] = {
    "controller_session_receipt": {
        "kind": "runtime_receipt",
        "producers": EXPECTED_RECEIPT_CHOICES,
        "demo_reachable": True,
    },
    "controller_recap_choice": {
        "kind": "recap",
        "producers": EXPECTED_RECEIPT_CHOICES,
        "demo_reachable": True,
    },
    "m02_route_split": {
        "kind": "route",
        "producers": {"arc_temptation_01#0", "arc_temptation_01#1"},
        "demo_reachable": True,
    },
    "m04_measure_follow_up": {
        "kind": "follow_up",
        "producers": {"arc_sangchul_01_meet#0"},
        "demo_reachable": True,
    },
    "m04_coffee_follow_up": {
        "kind": "follow_up",
        "producers": {"arc_sangchul_01_meet#1"},
        "demo_reachable": True,
    },
    "m04_answer_follow_up": {
        "kind": "follow_up",
        "producers": {
            "arc_sangchul_01_measure#0",
            "arc_sangchul_01_coffee#0",
        },
        "demo_reachable": True,
    },
    "m02_restitution_claim": {
        "kind": "deferred_follow_up",
        "producers": {"arc_temptation_fallout#0"},
        "demo_reachable": True,
    },
    "m06_restitution_root": {
        "kind": "route",
        "producers": {"arc_temptation_fallout#0"},
        "demo_reachable": True,
    },
    "m06_escalation_root": {
        "kind": "route",
        "producers": {"arc_temptation_fallout#1"},
        "demo_reachable": True,
    },
    "m03_m05_exact_choice_history": {
        "kind": "history_reader",
        "producers": {
            "arc_daeun_01_meet#0", "arc_daeun_01_meet#1",
            "arc_jiyeon_01_crash#0", "arc_jiyeon_01_crash#1",
            "arc_jiyeon_01_crash#2",
            "arc_sangchul_01_meet#0", "arc_sangchul_01_meet#1",
            "arc_sangchul_01_answer#0", "arc_sangchul_01_answer#1",
            "arc_sangchul_01_answer#2",
            "arc_jaehyuk_01_reunion#0", "arc_jaehyuk_01_reunion#1",
        },
        "demo_reachable": True,
    },
    "m06_choice_ledger": {
        "kind": "follow_up",
        "producers": {
            "order124_m6_first_bill#0", "order124_m6_first_bill#1",
            "order124_m6_first_bill#2", "order124_m6_first_bill#3",
            "order124_m6_first_bill#4",
        },
        "demo_reachable": True,
    },
}

EXPECTED_CONSUMER_READERS: Dict[str, Dict[str, Any]] = {
    "controller_session_receipt": {
        "path": CONTROLLER_PATH,
        "symbol": "_collect_current_month_choices",
        "markers": {
            "_choice_receipt_flag", "GameState.flags.get(receipt, false)",
            "_choice_record", '_session["choices"]',
        },
    },
    "controller_recap_choice": {
        "path": CONTROLLER_PATH,
        "symbol": "_show_recap",
        "markers": {
            '_session.get("choices"', "choice_index", "DataRegistry.find_event",
        },
    },
    "m02_route_split": {
        "path": CONTROLLER_PATH,
        "symbol": "_event_ids_for_month / _m02_route",
        "markers": {"lent_account", "arc_temptation_clean", "arc_temptation_fallout"},
    },
    "m04_measure_follow_up": {
        "path": STORY_MODE_PATH,
        "symbol": "_choice_follow_up_id / _after_result",
        "markers": {"follow_up_event", "_pending_follow_up", "_queue.push_front"},
    },
    "m04_coffee_follow_up": {
        "path": STORY_MODE_PATH,
        "symbol": "_choice_follow_up_id / _after_result",
        "markers": {"follow_up_event", "_pending_follow_up", "_queue.push_front"},
    },
    "m04_answer_follow_up": {
        "path": STORY_MODE_PATH,
        "symbol": "_choice_follow_up_id / _after_result",
        "markers": {"follow_up_event", "_pending_follow_up", "_queue.push_front"},
    },
    "m02_restitution_claim": {
        "path": CONTROLLER_PATH,
        "symbol": "_prepare_m6_route_context_mutation",
        "markers": {
            "GameState.claim_deferred_event", "M6_RESTITUTION_SOURCE_ID",
            "M6_ENTRY_TURN", 'context.get("source"',
        },
    },
    "m06_restitution_root": {
        "path": CONTROLLER_PATH,
        "symbol": "_preview_m6_route_context",
        "markers": {
            "escaped_dirty_money", "M6_RESTITUTION_ROOT_ID",
            "M6_RESTITUTION_SOURCE_ID", "missing_due_callback",
        },
    },
    "m06_escalation_root": {
        "path": CONTROLLER_PATH,
        "symbol": "_preview_m6_route_context",
        "markers": {
            "fell_to_darkness", "M6_ESCALATION_ROOT_ID",
            "M6_ESCALATION_SOURCE_ID",
        },
    },
    "m03_m05_exact_choice_history": {
        "path": CONTROLLER_PATH,
        "symbol": "_selected_history_texts_from_session",
        "markers": {
            "_selected_choice_index_from_session", "arc_daeun_01_meet",
            "arc_jiyeon_01_crash", "M4_ROOT_EVENT_ID",
            "M4_ANSWER_EVENT_ID", "arc_jaehyuk_01_reunion", '"text"',
        },
    },
    "m06_choice_ledger": {
        "path": CONTROLLER_PATH,
        "symbol": "_install_story_demo_ledger_event",
        "markers": {
            "M6_SOURCE_CHOICES", "_runtime_choice_receipt_flag",
            "description_if_known", "selected_choice", "missed",
        },
    },
}

EXPECTED_RUNTIME_COVERED = EXPECTED_RECEIPT_CHOICES
EXPECTED_RUNTIME_MISSING: List[str] = []

EXPECTED_START_CONTRACT = {
    "difficulty": "드라마",
    "profile": "알바",
    "run_theme": "자유런",
    "run_theme_categories": [],
    "health_floor": 70,
    "mental_floor": 72,
    "monthly_recovery_health": 1,
    "monthly_recovery_mental": 2,
    "creates_monthly_action_receipts": False,
}

EXPECTED_COUNTS = {
    "months": 6,
    "weeks": 24,
    "runtime_event_variants": 14,
    "visible_choice_options": 29,
    "receipt_bearing_selectors": 28,
    "receipts_per_run": {"clean": 9, "restitution": 10, "escalation": 10},
    "legal_signatures": {
        "clean": 360, "restitution": 720, "escalation": 720,
        "total": 1800,
    },
    "meaningful_decisions": {
        "clean": 7, "restitution": 9, "escalation": 9,
    },
    "forced_continues": {"clean": 2, "restitution": 1, "escalation": 1},
    "route_survival": {
        "settlements_per_run": 6,
        "surviving_signatures": 1800,
        "min_end_health": 61,
        "min_end_mental": 10,
        "min_end_money": 6320000.0,
    },
}

VISIBLE_NUMERIC_FIELDS = {"money", "health", "mental"}


def _reject_duplicate_keys(pairs: List[Tuple[str, Any]]) -> Dict[str, Any]:
    result: Dict[str, Any] = {}
    for key, value in pairs:
        if key in result:
            raise ValueError("duplicate JSON object key %r" % key)
        result[key] = value
    return result


def parse_json_bytes(payload: bytes, label: str) -> Any:
    try:
        text = payload.decode("utf-8")
    except UnicodeDecodeError as exc:
        raise ValueError("%s is not UTF-8: %s" % (label, exc)) from exc
    try:
        return json.loads(text, object_pairs_hook=_reject_duplicate_keys)
    except (json.JSONDecodeError, ValueError) as exc:
        raise ValueError("%s is invalid JSON: %s" % (label, exc)) from exc


def load_working_json(path: Path, label: str) -> Any:
    try:
        return parse_json_bytes(path.read_bytes(), label)
    except OSError as exc:
        raise ValueError("%s could not be read: %s" % (label, exc)) from exc


def sha256_bytes(payload: bytes) -> str:
    return hashlib.sha256(payload).hexdigest()


def git_output(args: Sequence[str]) -> bytes:
    try:
        return subprocess.check_output(
            ["git", "-C", str(ROOT)] + list(args), stderr=subprocess.STDOUT)
    except (OSError, subprocess.CalledProcessError) as exc:
        detail = ""
        if isinstance(exc, subprocess.CalledProcessError):
            detail = exc.output.decode("utf-8", "replace").strip()
        raise ValueError("git %s failed%s" % (
            " ".join(args), ": " + detail if detail else "")) from exc


def valid_blob_path(path: str) -> bool:
    if not path or path.startswith(("/", "-")) or "\x00" in path or ":" in path:
        return False
    pure = PurePosixPath(path)
    return not pure.is_absolute() and ".." not in pure.parts and str(pure) == path


def git_blob(source_ref: str, path: str) -> bytes:
    if not COMMIT_RE.fullmatch(source_ref):
        raise ValueError("source_ref must be one exact 40-hex commit")
    if not valid_blob_path(path):
        raise ValueError("unsafe source blob path %r" % path)
    # Never replace this with Path.read_bytes(): exact-candidate isolation is the
    # point of this audit.
    return git_output(["show", "%s:%s" % (source_ref, path)])


@dataclass
class SourceBundle:
    source_ref: str
    source_tree: str
    blobs: Dict[str, bytes]
    blob_oids: Dict[str, str]

    def text(self, path: str) -> str:
        payload = self.blobs.get(path)
        if payload is None:
            return ""
        return payload.decode("utf-8", "replace")


def subject_value(subject: Mapping[str, Any], *keys: str) -> str:
    for key in keys:
        value = subject.get(key)
        if isinstance(value, str) and value:
            return value
    return ""


def active_story_demo_gate(human_gates: Any, errors: List[str]) -> Dict[str, Any]:
    if not isinstance(human_gates, dict):
        errors.append("human_gates root must be an object")
        return {}
    candidates = human_gates.get("release_candidates")
    if not isinstance(candidates, dict):
        errors.append("human_gates.release_candidates must be an object")
        return {}
    gate = candidates.get(PROFILE)
    if not isinstance(gate, dict):
        errors.append("human_gates lacks release_candidates.%s" % PROFILE)
        return {}
    if gate.get("status") != "active":
        errors.append("human gate %s is not active" % PROFILE)
    return gate


def active_gate_build_id(gate: Mapping[str, Any], errors: List[str]) -> str:
    build_tokens = BUILD_RE.findall(str(gate.get("note", "")))
    if len(build_tokens) != 1:
        errors.append(
            "active story_demo_rc note must contain exactly one BUILD identity")
        return ""
    return build_tokens[0]


def prepare_sources(
        fixture: Any, human_gates: Any) -> Tuple[Optional[SourceBundle], List[str]]:
    errors: List[str] = []
    if not isinstance(fixture, dict):
        return None, ["fixture root must be an object"]
    subject = fixture.get("subject")
    if not isinstance(subject, dict):
        return None, ["fixture.subject must be an object"]

    source_ref = subject_value(subject, "source_ref", "source_commit", "commit")
    source_tree = subject_value(subject, "source_tree", "tree")
    build_id = subject_value(subject, "build_id", "build")
    if source_ref != EXPECTED_SOURCE_REF:
        errors.append("fixture source_ref drifted from ORDER-140 exact candidate")
    if source_tree != EXPECTED_SOURCE_TREE:
        errors.append("fixture source_tree drifted from ORDER-140 exact candidate")
    if build_id != EXPECTED_BUILD_ID:
        errors.append("fixture build_id drifted from ORDER-140 exact candidate")
    profile = subject_value(subject, "profile", "release_candidate", "candidate")

    if profile != PROFILE:
        errors.append("fixture subject profile %r != %r" % (profile, PROFILE))
    if not COMMIT_RE.fullmatch(source_ref):
        errors.append("fixture subject source_ref must be exact 40-hex")
    if not COMMIT_RE.fullmatch(source_tree):
        errors.append("fixture subject source_tree must be exact 40-hex")
    if not build_id:
        errors.append("fixture subject build_id is missing")
    if subject.get("scope") != "M01-M06":
        errors.append("fixture subject scope must be M01-M06")
    if subject.get("human_route_density") != "not_measured":
        errors.append("fixture must keep human_route_density=not_measured")

    gate = active_story_demo_gate(human_gates, errors)
    if gate:
        gate_commit = str(gate.get("commit", ""))
        gate_tree = str(gate.get("tree", ""))
        gate_build = active_gate_build_id(gate, errors)
        # This audit pins the new product commit before packaging/registration.
        # The still-active prior RC must remain a distinct human-gate record;
        # structural automation must not silently promote this candidate.
        if source_ref == gate_commit and source_tree == gate_tree \
                and gate_build and build_id == gate_build:
            errors.append(
                "ORDER-140 product was prematurely registered as active story_demo_rc")

    if errors:
        return None, errors

    try:
        resolved = git_output(
            ["rev-parse", "%s^{commit}" % source_ref]).decode().strip()
        actual_tree = git_output(
            ["show", "-s", "--format=%T", source_ref]).decode().strip()
    except ValueError as exc:
        return None, [str(exc)]
    if resolved != source_ref:
        errors.append("source_ref did not resolve byte-exact to itself")
    if actual_tree != source_tree:
        errors.append(
            "Git tree %s != fixture source_tree %s" % (actual_tree, source_tree))

    declarations = fixture.get("source_blobs")
    if isinstance(declarations, dict):
        declaration_rows = list(declarations.values())
    elif isinstance(declarations, list):
        declaration_rows = declarations
    else:
        return None, errors + ["fixture.source_blobs must be an object or array"]
    declared: Dict[str, str] = {}
    blobs: Dict[str, bytes] = {}
    blob_oids: Dict[str, str] = {}
    for index, row in enumerate(declaration_rows):
        owner = "source_blobs[%d]" % index
        if not isinstance(row, dict):
            errors.append("%s must be an object" % owner)
            continue
        path = row.get("path")
        digest = row.get("sha256")
        if not isinstance(path, str) or not valid_blob_path(path):
            errors.append("%s.path is invalid" % owner)
            continue
        if path in declared:
            errors.append("duplicate source blob declaration %s" % path)
            continue
        if not isinstance(digest, str) or not SHA256_RE.fullmatch(digest):
            errors.append("%s.sha256 must be 64 lowercase hex" % owner)
            continue
        declared[path] = digest
        declared_oid = row.get("git_blob_oid")
        if not isinstance(declared_oid, str) or not COMMIT_RE.fullmatch(declared_oid):
            errors.append("%s.git_blob_oid must be 40 lowercase hex" % owner)
        try:
            payload = git_blob(source_ref, path)
        except ValueError as exc:
            errors.append("%s: %s" % (path, exc))
            continue
        actual_digest = sha256_bytes(payload)
        if actual_digest != digest:
            errors.append(
                "source blob hash mismatch %s expected=%s actual=%s" % (
                    path, digest, actual_digest))
        try:
            actual_oid = git_output(
                ["rev-parse", "%s:%s" % (source_ref, path)]).decode().strip()
        except ValueError as exc:
            errors.append("%s blob OID could not be resolved: %s" % (path, exc))
        else:
            if declared_oid != actual_oid:
                errors.append(
                    "source blob OID mismatch %s expected=%s actual=%s" % (
                        path, declared_oid, actual_oid))
            blob_oids[path] = actual_oid
        blobs[path] = payload

    missing = sorted(REQUIRED_SOURCE_BLOBS - set(declared))
    if missing:
        errors.append("source_blobs missing required exact-ref paths: %s" % missing)
    if errors:
        return None, errors
    return SourceBundle(source_ref, source_tree, blobs, blob_oids), []


def event_rows(payload: Any, path: str, errors: List[str]) -> List[Dict[str, Any]]:
    if isinstance(payload, list):
        rows = payload
    elif isinstance(payload, dict) and isinstance(payload.get("events"), list):
        rows = payload["events"]
    else:
        errors.append("%s event root must be an array" % path)
        return []
    result: List[Dict[str, Any]] = []
    seen: Set[str] = set()
    for index, row in enumerate(rows):
        if not isinstance(row, dict) or not isinstance(row.get("id"), str):
            errors.append("%s[%d] is not an event object" % (path, index))
            continue
        event_id = row["id"]
        if event_id in seen:
            errors.append("%s has duplicate event id %s" % (path, event_id))
        seen.add(event_id)
        result.append(row)
    return result


def load_source_events(
        sources: SourceBundle, errors: List[str]) -> Dict[Tuple[str, str], Dict[str, Any]]:
    result: Dict[Tuple[str, str], Dict[str, Any]] = {}
    for path in (ARC_EVENTS_PATH, DAEUN_EVENTS_PATH, CORE_EVENTS_PATH):
        payload = sources.blobs.get(path, b"")
        try:
            parsed = parse_json_bytes(payload, "%s:%s" % (sources.source_ref, path))
        except ValueError as exc:
            errors.append(str(exc))
            continue
        for row in event_rows(parsed, path, errors):
            result[(path, str(row["id"]))] = row
    return result


def function_block(source: str, symbol: str) -> str:
    pattern = re.compile(
        r"(?m)^(?:static\s+)?func\s+%s\s*\(" % re.escape(symbol))
    match = pattern.search(source)
    if match is None:
        return ""
    next_match = re.search(r"(?m)^(?:static\s+)?func\s+", source[match.end():])
    end = match.end() + next_match.start() if next_match else len(source)
    return source[match.start():end]


def gdscript_without_comments(source: str) -> str:
    """Remove GDScript comments while preserving strings and indentation."""
    output: List[str] = []
    for raw_line in source.splitlines():
        quote = ""
        escaped = False
        kept: List[str] = []
        for character in raw_line:
            if escaped:
                kept.append(character)
                escaped = False
                continue
            if character == "\\" and quote:
                kept.append(character)
                escaped = True
                continue
            if character in ('"', "'"):
                if not quote:
                    quote = character
                elif quote == character:
                    quote = ""
                kept.append(character)
                continue
            if character == "#" and not quote:
                break
            kept.append(character)
        output.append("".join(kept).rstrip())
    return "\n".join(output)


def has_top_level_return(block: str) -> bool:
    code = gdscript_without_comments(block)
    return re.search(r"(?m)^\treturn(?:\s|$)", code) is not None


def has_top_level_return_before(block: str, marker: str) -> bool:
    code = gdscript_without_comments(block)
    marker_index = code.find(marker)
    if marker_index < 0:
        return True
    return re.search(r"(?m)^\treturn(?:\s|$)", code[:marker_index]) is not None


def validate_controller_receipt_consumer(block: str, errors: List[str]) -> None:
    """Pin the receipt lookup to the true branch that records completion."""
    code = gdscript_without_comments(block)
    executable_pattern = re.compile(
        r"(?m)^\t\tfor choice_index in range\(choices\.size\(\)\):\n"
        r"\t\t\tvar receipt := _choice_receipt_flag\(event_id, choice_index\)\n"
        r"\t\t\tif bool\(GameState\.flags\.get\(receipt, false\)\):\n"
        r"\t\t\t\trecords\.append\(_choice_record\(event, choices\[choice_index\], choice_index\)\)\n"
        r"\t\t\t\tcompleted\.append\(event_id\)\n"
        r"\t\t\t\tbreak$")
    if not executable_pattern.search(code) or has_top_level_return(block):
        errors.append("controller receipt consumer true branch drifted or is unreachable")


def validate_story_follow_up_consumer(block: str, errors: List[str]) -> None:
    """Require the authored follow-up enqueue inside its live true branch."""
    code = gdscript_without_comments(block)
    lines = code.splitlines()
    condition = (
        '\tif _pending_follow_up != "" and not '
        'DataRegistry.find_event(_pending_follow_up).is_empty():')
    try:
        condition_index = lines.index(condition)
    except ValueError:
        errors.append("StoryMode follow-up true branch condition drifted")
        return
    true_block: List[str] = []
    for line in lines[condition_index + 1:]:
        if line and not line.startswith("\t\t"):
            break
        true_block.append(line)
    if "\t\t_queue.push_front(_pending_follow_up)" not in true_block \
            or has_top_level_return("\n".join(lines[:condition_index])):
        errors.append("StoryMode follow-up enqueue is not reachable in the true branch")


def const_string(source: str, name: str) -> str:
    match = re.search(
        r'(?m)^const\s+%s(?:\s*:\s*[^=]+)?\s*:=?\s*"([^"]*)"' %
        re.escape(name), source)
    return match.group(1) if match else ""


def const_int(source: str, name: str) -> Optional[int]:
    match = re.search(
        r"(?m)^const\s+%s(?:\s*:\s*[^=]+)?\s*:=?\s*(-?[0-9]+)" %
        re.escape(name), source)
    return int(match.group(1)) if match else None


def const_int_array(source: str, name: str) -> List[int]:
    match = re.search(
        r"(?s)const\s+%s[^=]*=\s*\[(.*?)\]" % re.escape(name), source)
    if not match:
        return []
    return [int(value) for value in re.findall(r"-?[0-9]+", match.group(1))]


def const_string_array(source: str, name: str) -> List[str]:
    match = re.search(
        r"(?s)const\s+%s[^=]*=\s*\[(.*?)\]" % re.escape(name), source)
    if not match:
        return []
    return re.findall(r'"([^"]+)"', match.group(1))


def controller_receipt_template(
        sources: SourceBundle, errors: List[str]) -> str:
    controller = sources.text(CONTROLLER_PATH)
    templates: Dict[str, str] = {}
    for symbol in ("_runtime_choice_receipt_flag", "_choice_receipt_flag"):
        block = function_block(controller, symbol)
        match = re.search(
            r'(?m)^\treturn\s+"([^"]+)"\s*%\s*'
            r'\[\s*event_id\s*,\s*choice_index\s*\]\s*$',
            block)
        if not match:
            errors.append("controller %s receipt formula could not be parsed" % symbol)
            continue
        return_lines = re.findall(r"(?m)^\t+return\b[^\n]*$", block)
        branch_lines = re.findall(
            r"(?m)^\t+(?:if|elif|else|match|for|while)\b[^\n]*$", block)
        if len(return_lines) != 1 or branch_lines:
            errors.append(
                "controller %s receipt helper is not a single-return formula" % symbol)
            continue
        templates[symbol] = match.group(1)
    expected = "order124_choice__%s__%d"
    if set(templates.values()) != {expected} or len(templates) != 2:
        errors.append("controller choice receipt formula drifted")
    return templates.get("_runtime_choice_receipt_flag", expected)


def validate_controller_contract(
        sources: SourceBundle, expected_build_id: str,
        errors: List[str]) -> str:
    controller = sources.text(CONTROLLER_PATH)
    expected_strings = {
        "PUBLIC_PROFILE": PROFILE,
        "PUBLIC_BUILD_ID": expected_build_id,
        "PUBLIC_SAVE_PATH": SAVE_PATH,
        "PUBLIC_CUSTOM_USER_DIR": CUSTOM_USER_DIR,
        "SELF_SCENE": ENTRY_SCENE,
        "M6_EVENT_ID": M6_RUNTIME_ID,
        "M6_SOURCE_EVENT_ID": M6_SOURCE_ID,
        "M6_LEDGER_EVENT_ID": M6_LEDGER_ID,
        "M6_RESTITUTION_ROOT_ID": M6_RESTITUTION_ROOT_ID,
        "M6_ESCALATION_ROOT_ID": M6_ESCALATION_ROOT_ID,
    }
    for name, expected in expected_strings.items():
        actual = const_string(controller, name)
        if not actual:
            errors.append("controller lacks exact %s constant" % name)
        elif actual != expected:
            errors.append("controller %s drifted" % name)
    if const_int_array(controller, "M6_SOURCE_CHOICES") != M6_SOURCE_CHOICES:
        errors.append("controller M6 source-choice projection drifted")
    if const_int(controller, "START_HEALTH_FLOOR") != 70 \
            or const_int(controller, "START_MENTAL_FLOOR") != 72:
        errors.append("controller start survival floors drifted")
    if const_int(controller, "MONTHLY_RECOVERY_HEALTH") != 1 \
            or const_int(controller, "MONTHLY_RECOVERY_MENTAL") != 2:
        errors.append("controller monthly recovery drifted")

    required_function_markers: Dict[str, Sequence[str]] = {
        "_start_new_run": (
            'GameState.start_new_game(', 'START_PROFILE', 'START_DIFFICULTY',
            'GameState.run_theme = "자유런"', '"choices": []',
        ),
        "_event_ids_for_month": (
            'month == 2', 'arc_temptation_fallout', 'arc_temptation_clean',
        ),
        "_m02_route": ('lent_account', '"fallout"', '"clean"'),
        "_m4_branch_event_id": (
            'M4_ROOT_EVENT_ID, 0', 'M4_ROOT_EVENT_ID, 1',
            'M4_MEASURE_EVENT_ID', 'M4_COFFEE_EVENT_ID',
        ),
        "_remaining_event_ids": (
            'M4_ROOT_EVENT_ID', 'M4_ANSWER_EVENT_ID', 'branch_id',
        ),
        "_install_runtime_choice_receipts": (
            '_runtime_choice_receipt_flag(event_id, choice_index)',
            'choice["flags"] = flags', 'DataRegistry.events_by_id[event_id]',
        ),
        "_install_story_demo_m6_event": (
            'event["id"] = M6_EVENT_ID', 'for source_index in M6_SOURCE_CHOICES',
            'key.begins_with("v2_")', '"follow_up_event"',
            '"deferred_follow_up"', '"deferred_delay"',
            '_runtime_choice_receipt_flag(', 'M6_EVENT_ID, choices.size())',
            "_selected_history_texts_from_session", "history_texts.size() == 5",
            'choice["follow_up_event"] = M6_LEDGER_EVENT_ID',
        ),
        "_install_story_demo_ledger_event": (
            "M6_SOURCE_CHOICES", "description_if_known",
            "_runtime_choice_receipt_flag", "selected_choice", "missed",
            'event.erase("description_memory_if_known")',
        ),
        "_prepare_m6_route_context_mutation": (
            "GameState.claim_deferred_event", "M6_RESTITUTION_SOURCE_ID",
            "M6_ENTRY_TURN", '_session["m6_route_context"]',
        ),
        "_selected_history_texts_from_session": (
            "_selected_choice_index_from_session", "arc_daeun_01_meet",
            "arc_jiyeon_01_crash", "M4_ROOT_EVENT_ID", "M4_ANSWER_EVENT_ID",
            "arc_jaehyuk_01_reunion", '"text"',
        ),
        "_choice_record": ('"event_id"', '"choice_index"', '"month"'),
        "_collect_current_month_choices": (
            '_choice_receipt_flag(event_id, choice_index)',
            'records.append(_choice_record(',
        ),
        "_show_transition": ('cash_after', 'health_after', 'mental_after'),
        "_show_recap": (
            'GameState.money', 'GameState.health', 'GameState.mental',
            '_session.get("choices", [])', 'choice_index',
        ),
        "_close_month": (
            'for _week in range(4)', 'GameState.advance_calendar()',
            'GameState.apply_monthly_pressure()',
        ),
    }
    for symbol, markers in required_function_markers.items():
        block = function_block(controller, symbol)
        if not block:
            errors.append("controller lacks function %s" % symbol)
            continue
        for marker in markers:
            if marker not in block:
                errors.append("controller %s lacks marker %r" % (symbol, marker))
        if symbol == "_collect_current_month_choices":
            validate_controller_receipt_consumer(block, errors)
        elif symbol == "_install_runtime_choice_receipts" \
                and has_top_level_return_before(block, "DataRegistry.find_event(event_id)"):
            errors.append("controller runtime receipt installer exits before its source lookup")
        elif symbol == "_install_story_demo_m6_event" \
                and has_top_level_return_before(block, "DataRegistry.find_event(M6_SOURCE_EVENT_ID)"):
            errors.append("controller synthetic M6 installer exits before its source lookup")

    receipt_match = re.search(
        r"(?s)const\s+RUNTIME_RECEIPT_EVENT_IDS[^=]*=\s*\[(.*?)\]",
        controller)
    receipt_block = receipt_match.group(1) if receipt_match else ""
    receipt_constants = {
        "M4_ROOT_EVENT_ID": "arc_sangchul_01_meet",
        "M4_MEASURE_EVENT_ID": "arc_sangchul_01_measure",
        "M4_COFFEE_EVENT_ID": "arc_sangchul_01_coffee",
        "M4_ANSWER_EVENT_ID": "arc_sangchul_01_answer",
        "M6_RESTITUTION_ROOT_ID": M6_RESTITUTION_ROOT_ID,
        "M6_ESCALATION_ROOT_ID": M6_ESCALATION_ROOT_ID,
    }
    receipt_inventory: List[str] = []
    unresolved_receipt_tokens: List[str] = []
    for quoted, identifier in re.findall(
            r'"([^"]+)"|\b([A-Z][A-Z0-9_]*)\b', receipt_block):
        if quoted:
            receipt_inventory.append(quoted)
        elif identifier in receipt_constants:
            receipt_inventory.append(receipt_constants[identifier])
        else:
            unresolved_receipt_tokens.append(identifier)
    expected_receipt_inventory = [
        "arc_temptation_01", "arc_temptation_clean",
        "arc_temptation_fallout", "arc_daeun_01_meet",
        "arc_jiyeon_01_crash", "arc_sangchul_01_meet",
        "arc_sangchul_01_measure", "arc_sangchul_01_coffee",
        "arc_sangchul_01_answer", "arc_jaehyuk_01_reunion",
        M6_RESTITUTION_ROOT_ID, M6_ESCALATION_ROOT_ID,
    ]
    if not receipt_block or unresolved_receipt_tokens \
            or receipt_inventory != expected_receipt_inventory \
            or M6_LEDGER_ID in receipt_inventory:
        errors.append("controller runtime receipt event inventory drifted")
    schedule_match = re.search(
        r"(?s)const\s+MONTH_EVENTS\s*:=\s*\{(.*?)\n\}", controller)
    schedule_block = schedule_match.group(1) if schedule_match else ""
    schedule_markers = (
        '1: ["arc_temptation_01"]',
        '3: ["arc_daeun_01_meet", "arc_jiyeon_01_crash"]',
        '4: ["arc_sangchul_01_meet"]',
        '5: ["arc_jaehyuk_01_reunion"]',
        '6: [M6_EVENT_ID]',
    )
    if not schedule_block or any(marker not in schedule_block for marker in schedule_markers):
        errors.append("controller fixed month schedule drifted")
    for forbidden_drain in ("pop_ready_deferred_events",):
        if forbidden_drain in controller:
            errors.append(
                "isolated controller unexpectedly drains deferred events via %s" %
                forbidden_drain)

    for surface_symbol in ("_show_transition", "_show_recap"):
        block = function_block(controller, surface_symbol)
        for hidden_field in (
                "GameState.intelligence", "GameState.social_skill",
                "GameState.luck", "GameState.moral_tint", "GameState.cast"):
            if hidden_field in block:
                errors.append(
                    "controller %s unexpectedly exposes %s" % (
                        surface_symbol, hidden_field))
    return controller_receipt_template(sources, errors)


def validate_start_contract(fixture: Mapping[str, Any], errors: List[str]) -> None:
    contract = fixture.get("start_contract")
    if not isinstance(contract, dict):
        errors.append("fixture.start_contract must be an object")
        return
    for key, expected in EXPECTED_START_CONTRACT.items():
        if contract.get(key) != expected:
            errors.append("start_contract.%s drifted" % key)


def validate_nodes(
        fixture: Mapping[str, Any], source_events: Mapping[Tuple[str, str], Dict[str, Any]],
        errors: List[str]) -> Dict[str, Dict[str, Any]]:
    rows = fixture.get("nodes")
    if not isinstance(rows, list):
        errors.append("fixture.nodes must be an array")
        return {}
    nodes: Dict[str, Dict[str, Any]] = {}
    node_ids: Set[str] = set()
    for index, row in enumerate(rows):
        owner = "nodes[%d]" % index
        if not isinstance(row, dict):
            errors.append("%s must be an object" % owner)
            continue
        node_id = row.get("node_id")
        runtime_id = row.get("runtime_event_id")
        month = row.get("month")
        source = row.get("source")
        ingress = row.get("ingress")
        if not isinstance(node_id, str) or not node_id:
            errors.append("%s.node_id must be non-empty" % owner)
        elif node_id in node_ids:
            errors.append("duplicate node_id %s" % node_id)
        else:
            node_ids.add(node_id)
        if not isinstance(runtime_id, str) or not runtime_id:
            errors.append("%s.runtime_event_id must be non-empty" % owner)
            continue
        if runtime_id in nodes:
            errors.append("duplicate runtime event node %s" % runtime_id)
            continue
        if runtime_id not in EXPECTED_RUNTIME_SOURCES:
            errors.append("unexpected runtime event node %s" % runtime_id)
            continue
        expected_month, expected_path, expected_event_id, expected_choices = \
            EXPECTED_RUNTIME_SOURCES[runtime_id]
        if isinstance(month, bool) or month != expected_month:
            errors.append("%s month drifted for %s" % (owner, runtime_id))
        if not isinstance(source, dict):
            errors.append("%s.source must be an object" % owner)
            continue
        if source.get("path") != expected_path \
                or source.get("event_id") != expected_event_id:
            errors.append("%s source binding drifted for %s" % (owner, runtime_id))
        source_event = source_events.get((expected_path, expected_event_id))
        if not isinstance(source_event, dict):
            errors.append("source event missing for runtime %s" % runtime_id)
        else:
            source_choices = source_event.get("choices")
            if not isinstance(source_choices, list):
                errors.append("source event %s choices must be an array" % expected_event_id)
            else:
                actual_count = 5 if runtime_id == M6_RUNTIME_ID else len(source_choices)
                if actual_count != expected_choices:
                    errors.append("runtime %s choice count drifted" % runtime_id)
        if not isinstance(ingress, dict):
            errors.append("%s.ingress must be an object" % owner)
        else:
            kind = ingress.get("kind")
            if kind not in INGRESS_KINDS:
                errors.append("%s ingress kind %r is invalid" % (owner, kind))
            elif kind != EXPECTED_INGRESS_BY_RUNTIME[runtime_id]:
                errors.append("%s ingress kind drifted for %s" % (owner, runtime_id))
            if ingress != EXPECTED_INGRESS[runtime_id]:
                errors.append("%s exact ingress binding drifted for %s" % (
                    owner, runtime_id))
        nodes[runtime_id] = row

    missing = sorted(set(EXPECTED_RUNTIME_SOURCES) - set(nodes))
    if missing:
        errors.append("nodes missing runtime variants: %s" % missing)
    if len(nodes) != 14:
        errors.append("runtime event variant count %d != 14" % len(nodes))
    return nodes


def validate_authored_topology(
        source_events: Mapping[Tuple[str, str], Dict[str, Any]],
        sources: SourceBundle, errors: List[str]) -> None:
    def choice(runtime_id: str, index: int) -> Dict[str, Any]:
        _month, path, source_id, _count = EXPECTED_RUNTIME_SOURCES[runtime_id]
        event = source_events.get((path, source_id), {})
        choices = event.get("choices", []) if isinstance(event, dict) else []
        if not isinstance(choices, list) or index < 0 or index >= len(choices):
            return {}
        value = choices[index]
        return value if isinstance(value, dict) else {}

    if "lent_account" not in choice("arc_temptation_01", 1).get("flags", []):
        errors.append("M01 acceptance no longer produces lent_account")
    if "lent_account" in choice("arc_temptation_01", 0).get("flags", []):
        errors.append("M01 refusal unexpectedly produces lent_account")

    expected_followups = {
        ("arc_sangchul_01_meet", 0): "arc_sangchul_01_measure",
        ("arc_sangchul_01_meet", 1): "arc_sangchul_01_coffee",
        ("arc_sangchul_01_measure", 0): "arc_sangchul_01_answer",
        ("arc_sangchul_01_coffee", 0): "arc_sangchul_01_answer",
    }
    for (event_id, index), expected in expected_followups.items():
        if choice(event_id, index).get("follow_up_event") != expected:
            errors.append("authored follow-up drifted for %s#%d" % (event_id, index))

    restitution = choice("arc_temptation_fallout", 0)
    if restitution.get("deferred_follow_up") != "callback_escaped_dirty_trace" \
            or restitution.get("deferred_delay") != 16:
        errors.append("M02 restitution deferred callback contract drifted")
    for root_id in (M6_RESTITUTION_ROOT_ID, M6_ESCALATION_ROOT_ID):
        for index in range(2):
            if not choice(root_id, index):
                errors.append("M06 dirty consequence root choice missing: %s#%d" % (
                    root_id, index))
    for index in range(5):
        if choice(M6_RUNTIME_ID, M6_SOURCE_CHOICES[index]).get(
                "follow_up_event") != M6_LEDGER_ID:
            errors.append("M06 authored choice lost ledger edge at source index %d" % (
                M6_SOURCE_CHOICES[index]))
    ledger_choice = choice(M6_LEDGER_ID, 0)
    if ledger_choice.get("choice_kind") != "expression" \
            or ledger_choice.get("effects") \
            or ledger_choice.get("flags"):
        errors.append("M06 ledger close is not an exact state-free expression")
    game_state = sources.text(GAME_STATE_PATH)
    drama_match = re.search(
        r'(?s)"드라마"\s*:\s*\{(.*?)\n\s*\},', game_state)
    drama_block = drama_match.group(1) if drama_match else ""
    for marker in (
            '"start_money": 2_000_000.0',
            '"pressure_health": -1, "pressure_mental": -2'):
        if marker not in drama_block:
            errors.append("Drama survival model lacks source marker %r" % marker)
    start_block = function_block(game_state, "start_new_game")
    for marker in (
            'fixed_expense = 650_000.0', 'health = 65', 'mental = 60'):
        if marker not in start_block:
            errors.append("start survival model lacks source marker %r" % marker)
    profile_block = function_block(game_state, "_apply_starting_profile")
    part_time_match = re.search(
        r'(?s)\n\s*"알바":(.*?)(?:\n\s*"직장인":)', profile_block)
    part_time_block = part_time_match.group(1) if part_time_match else ""
    for marker in (
            '_add_money_silent(300_000.0)',
            'monthly_income = float(job.get("base_salary", 1_320_000))'):
        if marker not in part_time_block:
            errors.append("part-time survival model lacks source marker %r" % marker)
    pressure_block = function_block(game_state, "apply_monthly_pressure")
    for marker in (
            'add_money(payable_income - fixed_expense)',
            'modify_stat("health", int(diff_data.get("pressure_health", -2)))',
            'modify_stat("mental", int(diff_data.get("pressure_mental", -3)))'):
        if marker not in pressure_block:
            errors.append("monthly survival model lacks source marker %r" % marker)
    gosiwon_match = re.search(
        r'(?s)\n\s*"gosiwon":(.*?)(?:\n\s*"villa",\s*"apartment":)',
        pressure_block)
    gosiwon_block = gosiwon_match.group(1) if gosiwon_match else ""
    if gosiwon_block.count('modify_stat("mental", -1)') != 2:
        errors.append("goshiwon survival pressure is not exactly -2 mental")
    game_over_block = function_block(game_state, "check_game_over")
    for marker in (
            'if health <= 0:', 'if mental <= 0:',
            'if total_now < -100_000_000:'):
        if marker not in game_over_block:
            errors.append("survival terminal model lacks source marker %r" % marker)
    apply_block = function_block(game_state, "apply_choice")
    add_block = function_block(game_state, "add_deferred_event")
    available_block = function_block(game_state, "choice_available")
    for marker in (
            'authored.get("requires_item", "")', "not has_item(required_item)",
            'authored.has("opportunity_unavailable_fallback")',
            'authored.get("opportunity", {})',
            "_opportunity_choice_available(authored)"):
        if marker not in available_block:
            errors.append("GameState.choice_available lacks marker %r" % marker)
    for marker in (
            "DataRegistry.deferred_follow_ups(choice)", "add_deferred_event("):
        if marker not in apply_block:
            errors.append("GameState.apply_choice lacks deferred marker %r" % marker)
    for marker in ('choice.get("give_items", [])', "add_item(item_id, 1)"):
        if marker not in apply_block:
            errors.append("GameState.apply_choice lacks item-grant marker %r" % marker)
    for marker in ("turn + maxi(delay, 0)", '"trigger_turn"'):
        if marker not in add_block:
            errors.append("GameState.add_deferred_event lacks marker %r" % marker)

    story_mode = sources.text(STORY_MODE_PATH)
    follow_block = function_block(story_mode, "_choice_follow_up_id")
    advance_block = function_block(story_mode, "_after_result")
    if 'choice.get("follow_up_event", "")' not in follow_block:
        errors.append("StoryMode no longer reads authored follow_up_event")
    if "_queue.push_front(_pending_follow_up)" not in advance_block:
        errors.append("StoryMode no longer enqueues authored follow_up_event")
    validate_story_follow_up_consumer(advance_block, errors)


def validate_synthetic_event(
        fixture: Mapping[str, Any], source_events: Mapping[Tuple[str, str], Dict[str, Any]],
        sources: SourceBundle, receipt_template: str,
        errors: List[str]) -> List[Dict[str, Any]]:
    rows = fixture.get("synthetic_events")
    if not isinstance(rows, list) or len(rows) != 1 or not isinstance(rows[0], dict):
        errors.append("fixture.synthetic_events must contain exactly one object")
        row: Dict[str, Any] = {}
    else:
        row = rows[0]
    runtime_id = row.get("runtime_event_id")
    source = row.get("source", {})
    source_id = source.get("event_id") if isinstance(source, dict) \
        else row.get("source_event_id")
    source_path = source.get("path") if isinstance(source, dict) \
        else row.get("source_path", CORE_EVENTS_PATH)
    choice_map = row.get("choice_map")
    source_indices: Any = row.get("source_choice_indices")
    runtime_indices: Any = None
    if isinstance(choice_map, list):
        source_indices = [
            item.get("source_choice_index") if isinstance(item, dict) else None
            for item in choice_map
        ]
        runtime_indices = [
            item.get("runtime_choice_index") if isinstance(item, dict) else None
            for item in choice_map
        ]
    transform = row.get("choice_transform", {})
    if not isinstance(transform, dict):
        transform = {}
    strip_prefixes = transform.get(
        "drop_key_prefixes",
        row.get("strip_choice_key_prefixes", row.get("strip_prefixes", [])))
    strip_keys = transform.get(
        "drop_keys", row.get("strip_choice_keys", row.get("strip_keys", [])))
    if runtime_id != M6_RUNTIME_ID:
        errors.append("synthetic M6 runtime_event_id drifted")
    if source_id != M6_SOURCE_ID or source_path != CORE_EVENTS_PATH:
        errors.append("synthetic M6 source binding drifted")
    if source_indices != M6_SOURCE_CHOICES:
        errors.append("synthetic M6 source choice indices drifted")
    if runtime_indices is not None and runtime_indices != list(range(5)):
        errors.append("synthetic M6 runtime choice indices drifted")
    if strip_prefixes not in (["v2_"], ["v2_*"], "v2_"):
        errors.append("synthetic M6 v2_* strip contract drifted")
    if not isinstance(strip_keys, list) or set(strip_keys) != M6_STRIP_EXACT:
        errors.append("synthetic M6 exact strip keys drifted")
    if transform and transform.get("inject_runtime_receipt") is not True:
        errors.append("synthetic M6 runtime receipt injection drifted")
    overrides = row.get("event_overrides", {})
    if not isinstance(overrides, dict) or overrides.get("weight") != 0 \
            or overrides.get("hidden") is not True \
            or overrides.get("conditions") != {"min_turn": 9999} \
            or overrides.get("localized_description_owner") != "controller":
        errors.append("synthetic M6 event overrides drifted")

    event = source_events.get((CORE_EVENTS_PATH, M6_SOURCE_ID), {})
    source_choices = event.get("choices", []) if isinstance(event, dict) else []
    if not isinstance(source_choices, list) or len(source_choices) != 8:
        errors.append("M6 source event must retain exactly eight choices")
        return []
    projected: List[Dict[str, Any]] = []
    for runtime_index, source_index in enumerate(M6_SOURCE_CHOICES):
        raw = source_choices[source_index]
        if not isinstance(raw, dict):
            errors.append("M6 source choice %d is not an object" % source_index)
            continue
        value = copy.deepcopy(raw)
        removed = sorted(
            key for key in value
            if str(key).startswith("v2_") or key in M6_STRIP_EXACT)
        for key in removed:
            value.pop(key, None)
        # ORDER-140 strips the full-product edge and then reinstalls the same
        # ledger target only for a newly prepared M06 route context.
        value["follow_up_event"] = M6_LEDGER_ID
        receipt = receipt_id(receipt_template, M6_RUNTIME_ID, runtime_index)
        flags = list(value.get("flags", [])) if isinstance(value.get("flags", []), list) else []
        flags.append(receipt)
        value["flags"] = flags
        projected.append({
            "runtime_choice_index": runtime_index,
            "source_choice_index": source_index,
            "removed_keys": removed,
            "choice": value,
        })
    if len(projected) != 5:
        errors.append("synthetic M6 projection did not produce five choices")
    controller = sources.text(CONTROLLER_PATH)
    if const_int_array(controller, "M6_SOURCE_CHOICES") != M6_SOURCE_CHOICES:
        errors.append("synthetic fixture and controller M6 projection disagree")
    return projected


def choice_key(runtime_id: str, index: int) -> str:
    return "%s#%d" % (runtime_id, index)


def receipt_id(template: str, runtime_id: str, index: int) -> str:
    try:
        return template % (runtime_id, index)
    except (TypeError, ValueError):
        return ""


def runtime_choice_catalog(
        source_events: Mapping[Tuple[str, str], Dict[str, Any]],
        m6_projection: Sequence[Dict[str, Any]], receipt_template: str,
        errors: List[str]) -> Dict[str, Dict[str, Any]]:
    result: Dict[str, Dict[str, Any]] = {}
    receipt_seen: Set[str] = set()
    for runtime_id, (_month, path, source_id, expected_count) \
            in EXPECTED_RUNTIME_SOURCES.items():
        if runtime_id == M6_RUNTIME_ID:
            choices = [row.get("choice", {}) for row in m6_projection]
            source_indices = [row.get("source_choice_index") for row in m6_projection]
        else:
            event = source_events.get((path, source_id), {})
            choices = event.get("choices", []) if isinstance(event, dict) else []
            source_indices = list(range(len(choices))) if isinstance(choices, list) else []
        if not isinstance(choices, list) or len(choices) != expected_count:
            errors.append("runtime choice inventory drifted for %s" % runtime_id)
            continue
        for index, raw in enumerate(choices):
            if not isinstance(raw, dict):
                errors.append("runtime choice %s#%d is not an object" % (runtime_id, index))
                continue
            key = choice_key(runtime_id, index)
            receipt_bearing = key != LEDGER_EXPRESSION_CHOICE
            receipt = receipt_id(receipt_template, runtime_id, index) \
                if receipt_bearing else ""
            if receipt_bearing and not receipt:
                errors.append("runtime receipt formula failed for %s" % key)
            if key in result:
                errors.append("duplicate runtime choice key %s" % key)
            if receipt and receipt in receipt_seen:
                errors.append("duplicate runtime receipt %s" % receipt)
            if receipt:
                receipt_seen.add(receipt)
            result[key] = {
                "choice_key": key,
                "runtime_event_id": runtime_id,
                "choice_index": index,
                "source_path": path,
                "source_event_id": source_id,
                "source_choice_index": source_indices[index],
                "receipt_id": receipt,
                "receipt_bearing": receipt_bearing,
                "effects": copy.deepcopy(raw.get("effects", {}))
                    if isinstance(raw.get("effects", {}), dict) else {},
                "choice_kind": str(raw.get("choice_kind", "")),
                "flags": copy.deepcopy(raw.get("flags", []))
                    if isinstance(raw.get("flags", []), list) else [],
                "requires_item": str(raw.get("requires_item", "")),
                "give_items": copy.deepcopy(raw.get("give_items", []))
                    if isinstance(raw.get("give_items", []), list) else [],
                "opportunity": copy.deepcopy(raw.get("opportunity", {}))
                    if isinstance(raw.get("opportunity", {}), dict) else {},
                "opportunity_unavailable_fallback": raw.get(
                    "opportunity_unavailable_fallback", None),
                "follow_up_event": str(raw.get("follow_up_event", "")),
                "deferred_follow_up": str(raw.get("deferred_follow_up", "")),
                "deferred_delay": raw.get("deferred_delay"),
            }
    if len(result) != 29:
        errors.append("visible runtime choice option count %d != 29" % len(result))
    receipt_count = sum(
        bool(row.get("receipt_bearing")) for row in result.values())
    if receipt_count != 28:
        errors.append("receipt-bearing runtime selector count %d != 28" % receipt_count)
    if len(receipt_seen) != 28:
        errors.append("runtime receipt IDs are not unique")
    return result


def validate_annotations(
        fixture: Mapping[str, Any], catalog: Mapping[str, Dict[str, Any]],
        errors: List[str]) -> Dict[str, Dict[str, Any]]:
    raw = fixture.get("reviewed_choice_annotations")
    if not isinstance(raw, dict):
        errors.append("fixture.reviewed_choice_annotations must be an object")
        return {}
    annotations: Dict[str, Dict[str, Any]] = {}
    expected_fields = {
        "mode", "action_axes", "sacrificed_axes", "risk_role",
        "consumer_expectations",
    }
    for key, value in raw.items():
        if not isinstance(key, str) or not CHOICE_KEY_RE.fullmatch(key):
            errors.append("annotation key %r must be runtime_event#choice_index" % key)
            continue
        if not isinstance(value, dict):
            errors.append("annotation %s must be an object" % key)
            continue
        unknown = sorted(set(value) - expected_fields)
        missing = sorted(expected_fields - set(value))
        if unknown:
            errors.append("annotation %s has unknown fields %s" % (key, unknown))
        if missing:
            errors.append("annotation %s lacks fields %s" % (key, missing))
        mode = value.get("mode")
        if mode not in MODES:
            errors.append("annotation %s mode %r is invalid" % (key, mode))
        elif EXPECTED_MODE_BY_CHOICE.get(key) != mode:
            errors.append("annotation %s mode drifted" % key)
        for axis_field in ("action_axes", "sacrificed_axes"):
            axes = value.get(axis_field)
            if not isinstance(axes, list) or any(not isinstance(axis, str) for axis in axes):
                errors.append("annotation %s %s must be a string array" % (key, axis_field))
            elif len(axes) != len(set(axes)) or not set(axes) <= AXES:
                errors.append("annotation %s %s contains duplicate/invalid axes" % (
                    key, axis_field))
            elif axis_field == "action_axes" and not axes \
                    and key != LEDGER_EXPRESSION_CHOICE:
                errors.append("annotation %s action_axes must classify the choice" % key)
            expected_axes = EXPECTED_AXES_BY_CHOICE.get(key)
            expected_index = 0 if axis_field == "action_axes" else 1
            if expected_axes is None or axes != list(expected_axes[expected_index]):
                errors.append("annotation %s %s drifted" % (key, axis_field))
        risk_role = value.get("risk_role")
        if risk_role not in RISK_ROLES:
            errors.append("annotation %s risk_role %r is invalid" % (key, risk_role))
        elif EXPECTED_RISK_BY_CHOICE.get(key) != risk_role:
            errors.append("annotation %s risk role drifted" % key)
        consumers = value.get("consumer_expectations")
        if not isinstance(consumers, list) \
                or any(not isinstance(item, str) or not item for item in consumers):
            errors.append("annotation %s consumer_expectations must be a string array" % key)
        elif len(consumers) != len(set(consumers)):
            errors.append("annotation %s has duplicate consumer expectations" % key)
        annotations[key] = value

    missing_annotations = sorted(set(catalog) - set(annotations))
    extra_annotations = sorted(set(annotations) - set(catalog))
    if missing_annotations:
        errors.append("choice annotations missing: %s" % missing_annotations)
    if extra_annotations:
        errors.append("choice annotations name unknown choices: %s" % extra_annotations)
    mode_counts = {mode: 0 for mode in sorted(MODES)}
    for key in catalog:
        annotation = annotations.get(key, {})
        mode = annotation.get("mode")
        if mode in mode_counts:
            mode_counts[mode] += 1
    expected_mode_counts = {
        "decision": 13, "bridge": 3, "memory": 9, "expression": 4,
    }
    if mode_counts != expected_mode_counts:
        errors.append("choice mode distribution drifted: %s" % mode_counts)
    if set(EXPECTED_AXES_BY_CHOICE) != set(catalog):
        errors.append("internal exact reviewed axis baseline is incomplete")
    return annotations


def source_symbol_block(
        sources: SourceBundle, path: str, symbol: str) -> str:
    text = sources.text(path)
    if path.endswith(".gd"):
        symbols = [part.strip() for part in symbol.split("/") if part.strip()]
        blocks = [function_block(text, part) for part in symbols]
        # Reader contracts may name a short call chain.  Evidence is local to
        # those exact function bodies; a same-spelled token elsewhere in the
        # file must not make a stale reader marker pass.
        if not symbols or any(not block for block in blocks):
            return ""
        return "\n".join(blocks)
    if path.endswith(".json"):
        try:
            parsed = parse_json_bytes(sources.blobs.get(path, b""), path)
        except ValueError:
            return ""
        rows: Iterable[Any]
        if isinstance(parsed, list):
            rows = parsed
        elif isinstance(parsed, dict) and isinstance(parsed.get("events"), list):
            rows = parsed["events"]
        else:
            rows = []
        for row in rows:
            if isinstance(row, dict) and row.get("id") == symbol:
                return json.dumps(row, ensure_ascii=False, sort_keys=True)
        return ""
    return text if symbol in text else ""


def validate_consumers(
        fixture: Mapping[str, Any], annotations: Mapping[str, Dict[str, Any]],
        catalog: Mapping[str, Dict[str, Any]], sources: SourceBundle,
        errors: List[str]) -> Dict[str, Dict[str, Any]]:
    raw = fixture.get("consumer_contracts")
    if not isinstance(raw, list):
        errors.append("fixture.consumer_contracts must be an array")
        return {}
    consumers: Dict[str, Dict[str, Any]] = {}
    declared_paths = set(sources.blobs)
    for index, row in enumerate(raw):
        owner = "consumer_contracts[%d]" % index
        if not isinstance(row, dict):
            errors.append("%s must be an object" % owner)
            continue
        consumer_id = row.get("consumer_id")
        kind = row.get("kind")
        producers = row.get("producer_choices")
        reader = row.get("reader")
        reachable = row.get("demo_reachable")
        if not isinstance(consumer_id, str) or not consumer_id:
            errors.append("%s.consumer_id must be non-empty" % owner)
            continue
        if consumer_id in consumers:
            errors.append("duplicate consumer_id %s" % consumer_id)
            continue
        if consumer_id not in EXPECTED_CONSUMERS:
            errors.append("unexpected consumer_id %s" % consumer_id)
        if kind not in CONSUMER_KINDS:
            errors.append("consumer %s kind %r is invalid" % (consumer_id, kind))
        if not isinstance(producers, list) \
                or any(not isinstance(key, str) for key in producers):
            errors.append("consumer %s producer_choices must be a string array" % consumer_id)
            producer_set: Set[str] = set()
        else:
            producer_set = set(producers)
            if len(producer_set) != len(producers):
                errors.append("consumer %s has duplicate producer choices" % consumer_id)
            unknown = sorted(producer_set - set(catalog))
            if unknown:
                errors.append("consumer %s names unknown producers %s" % (
                    consumer_id, unknown))
        if not isinstance(reachable, bool):
            errors.append("consumer %s demo_reachable must be boolean" % consumer_id)
        if not isinstance(reader, dict):
            errors.append("consumer %s reader must be an object" % consumer_id)
        else:
            path = reader.get("path")
            symbol = reader.get("symbol")
            markers = reader.get("markers")
            if not isinstance(path, str) or path not in declared_paths:
                errors.append("consumer %s reader path is not a declared exact blob" % consumer_id)
            elif not isinstance(symbol, str) or not symbol:
                errors.append("consumer %s reader symbol is missing" % consumer_id)
            elif not isinstance(markers, list) or not markers \
                    or any(not isinstance(marker, str) or not marker for marker in markers):
                errors.append("consumer %s reader markers must be non-empty strings" % consumer_id)
            else:
                block = source_symbol_block(sources, path, symbol)
                if not block:
                    errors.append("consumer %s reader symbol %s not found" % (
                        consumer_id, symbol))
                else:
                    for marker in markers:
                        if marker not in block:
                            errors.append("consumer %s reader marker missing: %r" % (
                                consumer_id, marker))
        consumers[consumer_id] = row

    missing = sorted(set(EXPECTED_CONSUMERS) - set(consumers))
    if missing:
        errors.append("consumer contracts missing: %s" % missing)
    for consumer_id, expected in EXPECTED_CONSUMERS.items():
        row = consumers.get(consumer_id)
        if not isinstance(row, dict):
            continue
        if row.get("kind") != expected["kind"]:
            errors.append("consumer %s kind drifted" % consumer_id)
        if set(row.get("producer_choices", [])) != expected["producers"]:
            errors.append("consumer %s producer choice set drifted" % consumer_id)
        if row.get("demo_reachable") is not expected["demo_reachable"]:
            errors.append("consumer %s reachability drifted" % consumer_id)
        expected_reader = EXPECTED_CONSUMER_READERS[consumer_id]
        reader = row.get("reader", {})
        if not isinstance(reader, dict) \
                or reader.get("path") != expected_reader["path"] \
                or reader.get("symbol") != expected_reader["symbol"] \
                or set(reader.get("markers", [])) != expected_reader["markers"]:
            errors.append("consumer %s exact reader contract drifted" % consumer_id)

    authored_followup_producers = {
        key for key, row in catalog.items() if row.get("follow_up_event")
    }
    contracted_followup_producers: Set[str] = set()
    authored_deferred_producers = {
        key for key, row in catalog.items() if row.get("deferred_follow_up")
    }
    contracted_deferred_producers: Set[str] = set()
    for row in consumers.values():
        producers = row.get("producer_choices", [])
        if row.get("kind") == "follow_up":
            contracted_followup_producers.update(producers)
        elif row.get("kind") == "deferred_follow_up":
            contracted_deferred_producers.update(producers)
    if authored_followup_producers != contracted_followup_producers:
        errors.append(
            "authored follow-up edges and consumer contracts disagree: source=%s contract=%s" % (
                sorted(authored_followup_producers),
                sorted(contracted_followup_producers)))
    if authored_deferred_producers != contracted_deferred_producers:
        errors.append(
            "authored deferred edges and consumer contracts disagree: source=%s contract=%s" % (
                sorted(authored_deferred_producers),
                sorted(contracted_deferred_producers)))

    expected_by_choice: Dict[str, Set[str]] = {key: set() for key in catalog}
    for consumer_id, expected in EXPECTED_CONSUMERS.items():
        for producer in expected["producers"]:
            expected_by_choice.setdefault(producer, set()).add(consumer_id)
    for key in catalog:
        actual = annotations.get(key, {}).get("consumer_expectations", [])
        actual_set = set(actual) if isinstance(actual, list) else set()
        expected_set = expected_by_choice.get(key, set())
        if actual_set != expected_set:
            errors.append("annotation %s consumer expectations drifted" % key)
        for consumer_id in actual_set:
            row = consumers.get(consumer_id, {})
            if key not in row.get("producer_choices", []):
                errors.append("annotation %s has dangling consumer %s" % (
                    key, consumer_id))
    validate_live_consequence_readers(sources, errors)
    return consumers


def validate_live_consequence_readers(
        sources: SourceBundle, errors: List[str]) -> None:
    """Reject marker-only, unreachable, or partial ORDER-140 consumers."""
    controller = sources.text(CONTROLLER_PATH)
    history = function_block(controller, "_selected_history_texts_from_session")
    expected_history_order = [
        "arc_daeun_01_meet", "arc_jiyeon_01_crash",
        "M4_ROOT_EVENT_ID", "M4_ANSWER_EVENT_ID",
        "arc_jaehyuk_01_reunion",
    ]
    history_list = re.search(r"(?s)for event_id in \[(.*?)\]:", history)
    if history_list is None:
        errors.append("M03-M05 exact selected-choice reader has no event loop")
    else:
        actual: List[str] = []
        for quoted, identifier in re.findall(
                r'"([^"]+)"|\b(M4_ROOT_EVENT_ID|M4_ANSWER_EVENT_ID)\b',
                history_list.group(1)):
            actual.append(quoted or identifier)
        if actual != expected_history_order:
            errors.append("M03-M05 exact selected-choice reader inventory drifted")
    if has_top_level_return_before(history, "for event_id in [") \
            or 'texts.append(str(((choices as Array)[choice_index] as Dictionary).get(' \
                not in history:
        errors.append("M03-M05 exact selected-choice reader is unreachable or not text-bound")

    m6 = function_block(controller, "_install_story_demo_m6_event")
    history_call = "_selected_history_texts_from_session(session)"
    if history_call not in m6 \
            or "if history_texts.size() == 5:" not in m6 \
            or 'event["description"] = intro_template % history_texts' not in m6 \
            or has_top_level_return_before(m6, history_call):
        errors.append("M06 does not execute the exact M03-M05 history reader")
    if 'if has_new_context:' not in m6 \
            or 'choice["follow_up_event"] = M6_LEDGER_EVENT_ID' not in m6:
        errors.append("M06 receipt choices do not execute the ledger edge")

    claim = function_block(controller, "_prepare_m6_route_context_mutation")
    claim_call = "GameState.claim_deferred_event("
    claim_lines = gdscript_without_comments(claim).splitlines()
    exact_restitution_condition = (
        '\tif str(context.get("source", "")) == M6_RESTITUTION_SOURCE_ID:')
    try:
        condition_index = claim_lines.index(exact_restitution_condition)
    except ValueError:
        condition_index = -1
    true_branch: List[str] = []
    if condition_index >= 0:
        for line in claim_lines[condition_index + 1:]:
            if line and not line.startswith("\t\t"):
                break
            true_branch.append(line)
    exact_claim_lines = [
        "\t\tvar claimed := GameState.claim_deferred_event(",
        "\t\t\tM6_RESTITUTION_SOURCE_ID, M6_ENTRY_TURN)",
    ]
    claim_owned = all(line in true_branch for line in exact_claim_lines) \
        and claim.count(claim_call) == 1 \
        and controller.count(claim_call) == 1
    if condition_index < 0 or not claim_owned \
            or 'claimed.is_empty()' not in "\n".join(true_branch) \
            or '_session["m6_route_context"] = context' not in claim \
            or has_top_level_return_before(claim, exact_restitution_condition):
        errors.append("M02 restitution callback claim/drain is not live and atomic")
    launch = function_block(controller, "_launch_story")
    if "_prepare_m6_route_context_mutation()" not in launch \
            or has_top_level_return_before(
                launch, "_prepare_m6_route_context_mutation()"):
        errors.append("live M06 launch does not consume the route-context mutation")

    preview = function_block(controller, "_preview_m6_route_context")
    for marker in (
            "escaped_dirty_money", "fell_to_darkness",
            "M6_RESTITUTION_ROOT_ID", "M6_ESCALATION_ROOT_ID"):
        if marker not in preview:
            errors.append("M06 dirty-root router lacks %r" % marker)
    ledger = function_block(controller, "_install_story_demo_ledger_event")
    for marker in (
            "for selected_index in range((choices as Array).size())",
            "for other_index in range((choices as Array).size())",
            "_runtime_choice_receipt_flag(",
            'event["description_if_known"] = ledger_variants'):
        if marker not in ledger:
            errors.append("M06 ledger exact selected/forgone reader lacks %r" % marker)


def _gdscript_const_event_array(
        source: str, name: str, errors: List[str]) -> List[str]:
    match = re.search(
        r"(?s)const\s+%s[^=]*=\s*\[(.*?)\]" % re.escape(name), source)
    if not match:
        errors.append("selector evidence lacks const array %s" % name)
        return []
    values: List[str] = []
    for quoted, identifier in re.findall(
            r'"([^"]+)"|\b([A-Z][A-Z0-9_]*)\b', match.group(1)):
        if quoted:
            values.append(quoted)
        elif identifier == "M6_EVENT_ID":
            values.append(M6_RUNTIME_ID)
        else:
            errors.append(
                "selector evidence %s contains unresolved identifier %s" % (
                    name, identifier))
    return values


def _choice_row(
        catalog: Mapping[str, Dict[str, Any]], runtime_id: str,
        index: int) -> Optional[Dict[str, Any]]:
    row = catalog.get(choice_key(runtime_id, index))
    return row if isinstance(row, dict) else None


def _gdscript_int_map(
        block: str, variable: str, errors: List[str]) -> Dict[str, int]:
    match = re.search(
        r"(?s)var\s+%s\s*:=\s*\{(.*?)\n\t\}" % re.escape(variable), block)
    if not match:
        errors.append("selector evidence lacks map %s" % variable)
        return {}
    result: Dict[str, int] = {}
    for quoted, identifier, raw_index in re.findall(
            r'(?m)^\t\t(?:"([^"]+)"|(M6_EVENT_ID))\s*:\s*(-?[0-9]+)\s*,?\s*$',
            match.group(1)):
        event_id = M6_RUNTIME_ID if identifier else quoted
        if event_id in result:
            errors.append("selector map %s duplicates %s" % (variable, event_id))
        result[event_id] = int(raw_index)
    return result


def _story_choice_selector_coverage(
        source: str, catalog: Mapping[str, Dict[str, Any]],
        errors: List[str]) -> Set[str]:
    run_block = function_block(source, "_run")
    if has_top_level_return(run_block):
        errors.append("StoryChoice actual route caller has a top-level early return")
    if "_check_all_receipt_selectors(controller)" not in run_block \
            or has_top_level_return_before(
                run_block, "_check_all_receipt_selectors(controller)"):
        errors.append("StoryChoice 28-selector sweep is not live from _run")
    block = function_block(source, "_check_all_receipt_selectors")
    if not block or has_top_level_return(block):
        errors.append("StoryChoice 28-selector sweep is missing or exits early")
        return set()
    catalog_match = re.search(
        r"(?s)var\s+catalogs[^=]*=\s*\[(.*?)\n\t\]", block)
    if catalog_match is None:
        errors.append("StoryChoice selector catalog could not be parsed")
        return set()
    constants = {
        "M6_RESTITUTION_EVENT_ID": M6_RESTITUTION_ROOT_ID,
        "M6_ESCALATION_EVENT_ID": M6_ESCALATION_ROOT_ID,
        "M6_EVENT_ID": M6_RUNTIME_ID,
    }
    event_ids: List[str] = []
    for quoted, identifier in re.findall(
            r'\{"event":\s*(?:"([^"]+)"|([A-Z][A-Z0-9_]*))\s*,',
            catalog_match.group(1)):
        event_id = quoted or constants.get(identifier, "")
        if not event_id:
            errors.append("StoryChoice selector catalog has unresolved %s" % identifier)
        else:
            event_ids.append(event_id)
    expected_events = [
        runtime_id for runtime_id in EXPECTED_RUNTIME_SOURCES
        if runtime_id != M6_LEDGER_ID
    ]
    if event_ids != expected_events:
        errors.append("StoryChoice receipt selector event inventory drifted")
    code = gdscript_without_comments(block)
    fresh_prefix_call = "_advance_fresh_prefix_to_event("
    exact_prefix_gate = re.compile(
        r'(?m)^\t\t\tif not _advance_fresh_prefix_to_event\($\n'
        r'^\t\t\t\t\tcontroller, event_id, route\):$\n'
        r'^\t\t\t\tcontinue$')
    exact_loop_nesting = re.compile(
        r'(?m)^\tfor catalog in catalogs:$[\s\S]*?'
        r'^\t\tfor choice_index in range\(choices\.size\(\)\):$[\s\S]*?'
        r'^\t\t\tattempts \+= 1$')
    if code.count(fresh_prefix_call) != 1 \
            or exact_prefix_gate.search(code) is None \
            or exact_loop_nesting.search(code) is None:
        errors.append(
            "StoryChoice fresh-prefix selector loop/gate structure drifted")
    executable_markers = (
        "for catalog in catalogs:",
        "for choice_index in range(choices.size()):",
        fresh_prefix_call,
        'controller.call(\n\t\t\t\t"qa_choose_event", event_id, choice_index)',
        'bool(result.get("accepted", false))',
        'bool(result.get("applied", false))',
        'bool(result_flags.get(expected_receipt, false))',
        "selectors.append(expected_receipt)",
        "attempts == 28", "selectors.size() == 28",
        "unique_selectors.size() == 28",
    )
    for marker in executable_markers:
        if marker not in block:
            errors.append("StoryChoice live selector sweep lacks %r" % marker)
    covered = {
        key for key, row in catalog.items()
        if bool(row.get("receipt_bearing"))
        and row.get("runtime_event_id") in event_ids
    }
    if covered != EXPECTED_RECEIPT_CHOICES:
        errors.append("StoryChoice live selector sweep does not cover exact 28 receipts")
    return covered


def _safe_gd_expression(expression: str, variables: Mapping[str, Any]) -> Any:
    normalized = re.sub(r"\btrue\b", "True", expression.strip())
    normalized = re.sub(r"\bfalse\b", "False", normalized)
    tree = ast.parse(normalized, mode="eval")

    def evaluate(node: ast.AST) -> Any:
        if isinstance(node, ast.Expression):
            return evaluate(node.body)
        if isinstance(node, ast.Constant) and isinstance(node.value, (bool, int)):
            return node.value
        if isinstance(node, ast.Name) and node.id in variables:
            return variables[node.id]
        if isinstance(node, ast.BoolOp) and isinstance(node.op, (ast.And, ast.Or)):
            values = [bool(evaluate(value)) for value in node.values]
            return all(values) if isinstance(node.op, ast.And) else any(values)
        if isinstance(node, ast.UnaryOp) and isinstance(node.op, ast.Not):
            return not bool(evaluate(node.operand))
        if isinstance(node, ast.BinOp) and isinstance(node.op, ast.Mod):
            return int(evaluate(node.left)) % int(evaluate(node.right))
        if isinstance(node, ast.Compare) and len(node.ops) == 1 \
                and len(node.comparators) == 1 \
                and isinstance(node.ops[0], (ast.Eq, ast.NotEq)):
            left = evaluate(node.left)
            right = evaluate(node.comparators[0])
            return left == right if isinstance(node.ops[0], ast.Eq) else left != right
        if isinstance(node, ast.IfExp):
            return evaluate(node.body) if bool(evaluate(node.test)) \
                else evaluate(node.orelse)
        raise ValueError("unsupported selector expression node %s" % type(node).__name__)

    return evaluate(tree)


def _selector_expressions(
        source: str, errors: List[str]) -> Tuple[Dict[str, str], str]:
    block = function_block(source, "_choice_index")
    if not block:
        errors.append("FourLanguage selector function is missing")
        return {}, "0"
    expressions: Dict[str, str] = {}
    current_event = ""
    case_pattern = re.compile(
        r'^\t\t(?:"([^"]+)"|(M6_EVENT_ID)):\s*(?:return\s+(.+))?$')
    return_pattern = re.compile(r"^\t\t\treturn\s+(.+)$")
    for line in block.splitlines():
        case_match = case_pattern.match(line)
        if case_match:
            current_event = M6_RUNTIME_ID if case_match.group(2) \
                else case_match.group(1)
            if case_match.group(3):
                expressions[current_event] = case_match.group(3).strip()
                current_event = ""
            continue
        return_match = return_pattern.match(line)
        if current_event and return_match:
            expressions[current_event] = return_match.group(1).strip()
            current_event = ""
    defaults = re.findall(r"(?m)^\treturn\s+(.+?)\s*$", block)
    if len(defaults) != 1:
        errors.append("FourLanguage selector default outcome is ambiguous")
        return expressions, "0"
    return expressions, defaults[0]


def _four_language_selector_coverage(
        source: str, catalog: Mapping[str, Dict[str, Any]],
        route_mapping: Mapping[bool, str], errors: List[str]) -> Set[str]:
    run_block = function_block(source, "_run")
    if has_top_level_return(run_block):
        errors.append("FourLanguage actual locale caller has a top-level early return")
    if not re.search(
            r"(?m)^\tfor locale_index in range\(PUBLIC_LANGUAGES\.size\(\)\):$",
            run_block):
        errors.append("FourLanguage caller locale loop is not directly reachable")
    assignments: Dict[str, str] = {}
    for name in ("fallout", "coffee"):
        matches = re.findall(
            r"(?m)^\t\tvar\s+%s\s*:=\s*(.+?)\s*$" % name, run_block)
        if len(matches) != 1:
            errors.append("FourLanguage caller %s assignment is ambiguous" % name)
        else:
            assignments[name] = matches[0]
    if not re.search(
            r"(?m)^\t\tif not await _run_locale\(controller, language, fallout, coffee\):$",
            run_block):
        errors.append("FourLanguage caller no longer passes both route selectors")
    languages = const_string_array(source, "PUBLIC_LANGUAGES")
    if len(languages) != 5:
        errors.append("FourLanguage caller locale sweep count drifted")
    expressions, default_expression = _selector_expressions(source, errors)
    locale_block = function_block(source, "_run_locale")
    if "var choice_index := _choice_index(event_id, fallout, coffee)" not in locale_block:
        errors.append("FourLanguage run no longer consumes the parsed selector")

    def selector_index(event_id: str, fallout: bool, coffee: bool) -> int:
        expression = expressions.get(event_id, default_expression)
        try:
            value = _safe_gd_expression(
                expression, {"fallout": fallout, "coffee": coffee})
        except (SyntaxError, ValueError, ZeroDivisionError) as exc:
            errors.append(
                "FourLanguage selector %s could not be evaluated: %s" % (
                    event_id, exc))
            return -1
        if isinstance(value, bool) or not isinstance(value, int):
            errors.append("FourLanguage selector %s is not an integer" % event_id)
            return -1
        return value

    covered: Set[str] = set()
    for locale_index in range(len(languages)):
        selector_values: Dict[str, bool] = {}
        for name in ("fallout", "coffee"):
            try:
                value = _safe_gd_expression(
                    assignments.get(name, "false"),
                    {"locale_index": locale_index})
            except (SyntaxError, ValueError, ZeroDivisionError) as exc:
                errors.append(
                    "FourLanguage caller %s could not be evaluated: %s" % (name, exc))
                value = False
            selector_values[name] = bool(value)
        fallout = selector_values["fallout"]
        coffee = selector_values["coffee"]
        m1_index = selector_index("arc_temptation_01", fallout, coffee)
        covered.add(choice_key("arc_temptation_01", m1_index))
        m1_row = _choice_row(catalog, "arc_temptation_01", m1_index)
        has_lent_account = m1_row is not None \
            and "lent_account" in m1_row.get("flags", [])
        route = route_mapping.get(has_lent_account, "")
        m2_event = "arc_temptation_%s" % route
        event_ids = [
            m2_event, "arc_daeun_01_meet", "arc_jiyeon_01_crash",
        ]
        meet_index = selector_index(
            "arc_sangchul_01_meet", fallout, coffee)
        meet_row = _choice_row(catalog, "arc_sangchul_01_meet", meet_index)
        branch_id = str(meet_row.get("follow_up_event", "")) \
            if meet_row is not None else ""
        event_ids.extend([
            "arc_sangchul_01_meet", branch_id,
            "arc_sangchul_01_answer", "arc_jaehyuk_01_reunion",
            M6_RUNTIME_ID,
        ])
        for event_id in event_ids:
            if event_id:
                covered.add(choice_key(
                    event_id, selector_index(event_id, fallout, coffee)))
    return covered


def validate_runtime_coverage(
        fixture: Mapping[str, Any], sources: SourceBundle,
        catalog: Mapping[str, Dict[str, Any]], errors: List[str]) -> Dict[str, Any]:
    raw = fixture.get("runtime_coverage")
    if not isinstance(raw, dict):
        errors.append("fixture.runtime_coverage must be an object")
        return {}
    paths = raw.get("evidence_paths")
    expected_paths = [STORY_CHOICE_CHECK_PATH, FOUR_LANGUAGE_CHECK_PATH]
    if not isinstance(paths, list) or set(paths) != set(expected_paths) \
            or len(paths) != 2:
        errors.append("runtime coverage evidence_paths drifted")
    for path in expected_paths:
        if path not in sources.blobs:
            errors.append("runtime coverage evidence path is not an exact blob: %s" % path)

    choice_check = sources.text(STORY_CHOICE_CHECK_PATH)
    evidence_markers = {
        STORY_CHOICE_CHECK_PATH: (
            "_check_all_receipt_selectors(controller)",
            "func _check_all_receipt_selectors(",
            "attempts == 28", "unique_selectors.size() == 28",
        ),
        FOUR_LANGUAGE_CHECK_PATH: (
            "LOCALE_ROUTES", '"route": "clean"',
            '"route": "restitution"', '"route": "escalation"',
            "M6_RESTITUTION_EVENT_ID", "M6_ESCALATION_EVENT_ID",
            "_check_m6_ledger_surface",
        ),
    }
    for marker in evidence_markers[STORY_CHOICE_CHECK_PATH]:
        if marker not in choice_check:
            errors.append("StoryChoice selector evidence lacks %r" % marker)
    language_check = sources.text(FOUR_LANGUAGE_CHECK_PATH)
    for marker in evidence_markers[FOUR_LANGUAGE_CHECK_PATH]:
        if marker not in language_check:
            errors.append("FourLanguage selector evidence lacks %r" % marker)

    derived_set = _story_choice_selector_coverage(
        choice_check, catalog, errors)
    unknown_covered = sorted(derived_set - EXPECTED_RECEIPT_CHOICES)
    if unknown_covered:
        errors.append("runtime selector evidence chooses unknown options: %s" % unknown_covered)
    derived_set &= EXPECTED_RECEIPT_CHOICES
    derived_covered = [
        key for key in catalog
        if key in derived_set and bool(catalog[key].get("receipt_bearing"))
    ]
    derived_missing = [
        key for key in catalog
        if bool(catalog[key].get("receipt_bearing")) and key not in derived_set
    ]
    covered = raw.get("covered")
    missing = raw.get("missing")
    if not isinstance(covered, list) or covered != derived_covered:
        errors.append("runtime selector covered-choice inventory drifted")
    if not isinstance(missing, list) or missing != derived_missing:
        errors.append("runtime selector missing-choice inventory drifted")
    if raw.get("total") != len(EXPECTED_RECEIPT_CHOICES):
        errors.append("runtime selector coverage total drifted")
    if raw.get("visible_total") != len(catalog) \
            or raw.get("excluded_state_free") != [LEDGER_EXPRESSION_CHOICE]:
        errors.append("runtime selector state-free exclusion drifted")
    if derived_set != EXPECTED_RUNTIME_COVERED:
        errors.append("runtime selector evidence outcomes drifted")
    if set(derived_missing) != set(EXPECTED_RUNTIME_MISSING):
        errors.append("internal runtime coverage partition is inconsistent")
    return {
        "evidence_paths": expected_paths,
        "covered": derived_covered,
        "covered_count": len(derived_covered),
        "total": len(EXPECTED_RECEIPT_CHOICES),
        "visible_total": len(catalog),
        "excluded_state_free": [LEDGER_EXPRESSION_CHOICE],
        "missing": derived_missing,
    }


def _m02_route_mapping(
        sources: SourceBundle, errors: List[str]) -> Dict[bool, str]:
    block = function_block(sources.text(CONTROLLER_PATH), "_m02_route")
    match = re.search(
        r'return\s+"([^"]+)"\s+if\s+bool\s*\(\s*GameState\.flags\.get\s*'
        r'\(\s*"lent_account"\s*,\s*false\s*\)\s*\)\s+else\s+"([^"]+)"',
        block)
    if not match:
        errors.append("controller M02 route binding could not be parsed")
        return {False: "clean", True: "fallout"}
    mapping = {True: match.group(1), False: match.group(2)}
    if mapping != {False: "clean", True: "fallout"}:
        errors.append("controller M02 route binding drifted")
    return mapping


def _runtime_choices(
        catalog: Mapping[str, Dict[str, Any]], runtime_id: str) \
        -> List[Tuple[str, Dict[str, Any]]]:
    return sorted(
        [
            (key, row) for key, row in catalog.items()
            if row.get("runtime_event_id") == runtime_id
        ],
        key=lambda pair: int(pair[1].get("choice_index", -1)))


def _settled_cash(value: float) -> float:
    # Exact values in this candidate are whole won.  Preserve GameState's
    # half-away-from-zero rule so an introduced opportunity gate cannot be
    # silently enumerated under Python's bankers-rounding behavior.
    if value >= 0.0:
        return float(int(value + 0.5))
    return float(int(value - 0.5))


def _opportunity_available_for_state(
        row: Mapping[str, Any], state: Mapping[str, Any]) -> bool:
    opportunity = row.get("opportunity", {})
    if not isinstance(opportunity, dict) or not opportunity:
        return False
    effects = row.get("effects", {})
    money_delta = float(effects.get("money", 0.0)) \
        if isinstance(effects, dict) else 0.0
    available_cash = max(
        0.0, _settled_cash(float(state.get("money", 0.0)) + money_delta))
    raw_stake = float(opportunity.get("cost", 0.0))
    if "stake_ratio" in opportunity:
        raw_stake = available_cash * float(opportunity.get("stake_ratio", 0.0))
    stake = _settled_cash(raw_stake)
    return 1.0 <= stake <= available_cash


def _choice_available_for_state(
        key: str, row: Mapping[str, Any], state: Mapping[str, Any],
        catalog: Mapping[str, Dict[str, Any]]) -> bool:
    required_item = str(row.get("requires_item", ""))
    inventory = state.get("inventory", set())
    if required_item and required_item not in inventory:
        return False
    fallback = row.get("opportunity_unavailable_fallback", None)
    if fallback is not None:
        if fallback is not True:
            return False
        runtime_id = str(row.get("runtime_event_id", ""))
        opportunity_siblings = [
            sibling for sibling_key, sibling in _runtime_choices(catalog, runtime_id)
            if sibling_key != key and sibling.get("opportunity")
        ]
        if not opportunity_siblings:
            return False
        for sibling in opportunity_siblings:
            sibling_required = str(sibling.get("requires_item", ""))
            if sibling_required and sibling_required not in inventory:
                continue
            if _opportunity_available_for_state(sibling, state):
                return False
        return True
    if row.get("opportunity"):
        return _opportunity_available_for_state(row, state)
    return True


def _apply_choice_to_state(
        row: Mapping[str, Any], state: Mapping[str, Any]) -> Dict[str, Any]:
    next_state = {
        "flags": set(state.get("flags", set())),
        "inventory": set(state.get("inventory", set())),
        "money": float(state.get("money", 0.0)),
        "health": int(state.get("health", 0)),
        "mental": int(state.get("mental", 0)),
    }
    if str(row.get("choice_kind", "")).strip().lower() == "expression":
        return next_state
    next_state["flags"].update(
        str(flag) for flag in row.get("flags", []) if str(flag))
    effects = row.get("effects", {})
    if isinstance(effects, dict):
        next_state["money"] = _settled_cash(
            next_state["money"] + float(effects.get("money", 0.0)))
        next_state["health"] = max(
            0, min(100, next_state["health"] + int(effects.get("health", 0))))
        next_state["mental"] = max(
            0, min(100, next_state["mental"] + int(effects.get("mental", 0))))
        effect_items = effects.get("give_items", [])
        if isinstance(effect_items, list):
            next_state["inventory"].update(
                str(item) for item in effect_items if str(item))
    next_state["inventory"].update(
        str(item) for item in row.get("give_items", []) if str(item))
    return next_state


def _settle_demo_month(state: Mapping[str, Any]) -> Optional[Dict[str, Any]]:
    next_state = {
        "flags": set(state.get("flags", set())),
        "inventory": set(state.get("inventory", set())),
        "money": _settled_cash(float(state.get("money", 0.0)) + 670_000.0),
        "health": int(state.get("health", 0)),
        "mental": int(state.get("mental", 0)),
    }
    # Controller automatic recovery (+1/+2), Drama pressure (-1/-2), then the
    # exact goshiwon passive (-2 mental).  Cash-reserve stress is applied after
    # the part-time salary and KRW 650K rent settle.
    next_state["health"] = max(0, min(100, next_state["health"] + 1))
    next_state["mental"] = max(0, min(100, next_state["mental"] + 2))
    next_state["health"] = max(0, min(100, next_state["health"] - 1))
    next_state["mental"] = max(0, min(100, next_state["mental"] - 2))
    next_state["mental"] = max(0, min(100, next_state["mental"] - 1))
    next_state["mental"] = max(0, min(100, next_state["mental"] - 1))
    if next_state["money"] < 0.0:
        reserve_stress = -4
    elif next_state["money"] < 650_000.0:
        reserve_stress = -2
    elif next_state["money"] < 1_950_000.0:
        reserve_stress = -1
    else:
        reserve_stress = 0
    next_state["mental"] = max(
        0, min(100, next_state["mental"] + reserve_stress))
    if next_state["health"] <= 0 or next_state["mental"] <= 0 \
            or next_state["money"] < -100_000_000.0:
        return None
    return next_state


def _settle_paths(
        paths: Sequence[Tuple[Tuple[str, ...], Dict[str, Any]]]) \
        -> List[Tuple[Tuple[str, ...], Dict[str, Any]]]:
    settled: List[Tuple[Tuple[str, ...], Dict[str, Any]]] = []
    for signature, state in paths:
        next_state = _settle_demo_month(state)
        if next_state is not None:
            settled.append((signature, next_state))
    return settled


def _expand_runtime_event(
        paths: Sequence[Tuple[Tuple[str, ...], Dict[str, Any]]], runtime_id: str,
        catalog: Mapping[str, Dict[str, Any]]) \
        -> List[Tuple[Tuple[str, ...], Dict[str, Any]]]:
    expanded: List[Tuple[Tuple[str, ...], Dict[str, Any]]] = []
    for signature, state in paths:
        for key, row in _runtime_choices(catalog, runtime_id):
            if _choice_available_for_state(key, row, state, catalog):
                expanded.append((
                    signature + (key,), _apply_choice_to_state(row, state)))
    return expanded


def route_signatures(
        catalog: Mapping[str, Dict[str, Any]], sources: SourceBundle,
        errors: List[str]) -> Tuple[
            Dict[str, List[Tuple[str, ...]]], Dict[str, Any]]:
    routes = ("clean", "restitution", "escalation")
    result: Dict[str, List[Tuple[str, ...]]] = {route: [] for route in routes}
    end_states: Dict[str, List[Dict[str, Any]]] = {route: [] for route in routes}
    route_mapping = _m02_route_mapping(sources, errors)
    # Drama starts at KRW 2M and the part-time profile adds KRW 300K.  No item
    # is granted by the exact start contract.
    initial_state: Dict[str, Any] = {
        "flags": set(), "inventory": set(), "money": 2_300_000.0,
        "health": 70, "mental": 72,
    }
    for m1_key, m1_row in _runtime_choices(catalog, "arc_temptation_01"):
        if not _choice_available_for_state(
                m1_key, m1_row, initial_state, catalog):
            continue
        m1_state = _apply_choice_to_state(m1_row, initial_state)
        m02_route = route_mapping.get("lent_account" in m1_state["flags"], "")
        if m02_route not in {"clean", "fallout"}:
            errors.append("controller M02 route resolved unknown label %r" % m02_route)
            continue
        m2_event = "arc_temptation_%s" % m02_route
        paths: List[Tuple[Tuple[str, ...], Dict[str, Any]]] = _settle_paths([
            ((m1_key,), m1_state),
        ])
        paths = _expand_runtime_event(paths, m2_event, catalog)
        routed_paths: Dict[str, List[Tuple[Tuple[str, ...], Dict[str, Any]]]] = {
            route: [] for route in routes
        }
        for signature, state in paths:
            if m02_route == "clean":
                route = "clean"
            else:
                m2_choice = signature[-1] if signature else ""
                route = "restitution" if m2_choice == "arc_temptation_fallout#0" \
                    else "escalation" if m2_choice == "arc_temptation_fallout#1" \
                    else ""
            if route:
                routed_paths[route].append((signature, state))
            else:
                errors.append("M02 fallout choice did not resolve an exact dirty route")
        for route in routes:
            if not routed_paths[route]:
                continue
            paths = routed_paths[route]
            paths = _settle_paths(paths)
            for runtime_id in ("arc_daeun_01_meet", "arc_jiyeon_01_crash"):
                paths = _expand_runtime_event(paths, runtime_id, catalog)
            paths = _settle_paths(paths)

            branched: List[Tuple[Tuple[str, ...], Dict[str, Any]]] = []
            for signature, state in paths:
                for meet_key, meet_row in _runtime_choices(
                        catalog, "arc_sangchul_01_meet"):
                    if not _choice_available_for_state(
                            meet_key, meet_row, state, catalog):
                        continue
                    meet_state = _apply_choice_to_state(meet_row, state)
                    branch_id = str(meet_row.get("follow_up_event", ""))
                    branch_paths = _expand_runtime_event(
                        [(signature + (meet_key,), meet_state)], branch_id, catalog)
                    branched.extend(branch_paths)
            paths = _expand_runtime_event(
                branched, "arc_sangchul_01_answer", catalog)
            paths = _settle_paths(paths)
            paths = _expand_runtime_event(
                paths, "arc_jaehyuk_01_reunion", catalog)
            paths = _settle_paths(paths)
            if route == "restitution":
                paths = _expand_runtime_event(
                    paths, M6_RESTITUTION_ROOT_ID, catalog)
            elif route == "escalation":
                paths = _expand_runtime_event(
                    paths, M6_ESCALATION_ROOT_ID, catalog)
            paths = _expand_runtime_event(paths, M6_RUNTIME_ID, catalog)
            paths = _settle_paths(paths)
            result[route].extend(signature for signature, _state in paths)
            end_states[route].extend(state for _signature, state in paths)
    all_end_states = [state for route in routes for state in end_states[route]]
    survival_summary = {
        "settlements_per_run": 6,
        "surviving_signatures": sum(len(values) for values in result.values()),
        "min_end_health": min(
            (int(state["health"]) for state in all_end_states), default=None),
        "min_end_mental": min(
            (int(state["mental"]) for state in all_end_states), default=None),
        "min_end_money": min(
            (float(state["money"]) for state in all_end_states), default=None),
    }
    return result, survival_summary


def validate_expected_counts(
        fixture: Mapping[str, Any], signatures: Mapping[str, Sequence[Tuple[str, ...]]],
        annotations: Mapping[str, Dict[str, Any]],
        survival_summary: Mapping[str, Any], errors: List[str]) -> Dict[str, Any]:
    raw = fixture.get("expected")
    if not isinstance(raw, dict):
        errors.append("fixture.expected must be an object")
        raw = {}
    for key, expected in EXPECTED_COUNTS.items():
        if raw.get(key) != expected:
            errors.append("expected.%s drifted" % key)

    actual_counts = {
        "clean": len(signatures.get("clean", [])),
        "restitution": len(signatures.get("restitution", [])),
        "escalation": len(signatures.get("escalation", [])),
    }
    if actual_counts != {"clean": 360, "restitution": 720, "escalation": 720}:
        errors.append("legal signature enumeration drifted: %s" % actual_counts)
    route_origins = {
        route: sorted({signature[0] for signature in signatures.get(route, [])})
        for route in ("clean", "restitution", "escalation")
    }
    if route_origins != {
            "clean": ["arc_temptation_01#0"],
            "restitution": ["arc_temptation_01#1"],
            "escalation": ["arc_temptation_01#1"]}:
        errors.append("legal signature route origins drifted: %s" % route_origins)
    all_signatures = [
        signature for route in ("clean", "restitution", "escalation")
        for signature in signatures.get(route, [])
    ]
    if len(set(all_signatures)) != 1800:
        errors.append("legal signatures are not 1800 unique receipt tuples")
    expected_lengths = {"clean": 9, "restitution": 10, "escalation": 10}
    for route, length in expected_lengths.items():
        if any(len(signature) != length for signature in signatures.get(route, [])):
            errors.append("%s legal signature does not contain %d receipts" % (
                route, length))

    per_route_modes: Dict[str, Dict[str, List[int]]] = {}
    for route in ("clean", "restitution", "escalation"):
        meaningful: Set[int] = set()
        forced: Set[int] = set()
        for signature in signatures.get(route, []):
            non_bridge = sum(
                1 for key in signature
                if annotations.get(key, {}).get("mode") != "bridge")
            bridge = len(signature) - non_bridge
            meaningful.add(non_bridge)
            forced.add(bridge)
        per_route_modes[route] = {
            "meaningful_decisions": sorted(meaningful),
            "forced_continues": sorted(forced),
        }
    if per_route_modes != {
        "clean": {"meaningful_decisions": [7], "forced_continues": [2]},
        "restitution": {"meaningful_decisions": [9], "forced_continues": [1]},
        "escalation": {"meaningful_decisions": [9], "forced_continues": [1]},
    }:
        errors.append("per-run meaningful/forced counts drifted: %s" % per_route_modes)
    if dict(survival_summary) != EXPECTED_COUNTS["route_survival"]:
        errors.append("route survival enumeration drifted: %s" % survival_summary)
    return {
        "clean": actual_counts["clean"],
        "restitution": actual_counts["restitution"],
        "escalation": actual_counts["escalation"],
        "total": len(all_signatures),
        "receipts_per_run": expected_lengths,
        "route_origins": route_origins,
        "per_run": {
            route: {
                "meaningful_decisions": values["meaningful_decisions"][0]
                    if len(values["meaningful_decisions"]) == 1
                    else values["meaningful_decisions"],
                "forced_continues": values["forced_continues"][0]
                    if len(values["forced_continues"]) == 1
                    else values["forced_continues"],
            }
            for route, values in per_route_modes.items()
        },
    }


def axis_metrics(
        annotations: Mapping[str, Dict[str, Any]],
        catalog: Mapping[str, Dict[str, Any]]) -> Dict[str, Any]:
    option_action = {axis: 0 for axis in sorted(AXES)}
    option_sacrifice = {axis: 0 for axis in sorted(AXES)}
    node_action_sets: Dict[str, Set[str]] = {}
    node_sacrifice_sets: Dict[str, Set[str]] = {}
    mode_options = {mode: 0 for mode in sorted(MODES)}
    for key, row in annotations.items():
        runtime_id = key.rsplit("#", 1)[0]
        mode = row.get("mode")
        if mode in mode_options:
            mode_options[mode] += 1
        if mode == "bridge":
            continue
        for axis in row.get("action_axes", []):
            if axis in AXES:
                option_action[axis] += 1
                node_action_sets.setdefault(runtime_id, set()).add(axis)
        for axis in row.get("sacrificed_axes", []):
            if axis in AXES:
                option_sacrifice[axis] += 1
                node_sacrifice_sets.setdefault(runtime_id, set()).add(axis)
    node_action = {
        axis: sum(axis in axes for axes in node_action_sets.values())
        for axis in sorted(AXES)
    }
    node_sacrifice = {
        axis: sum(axis in axes for axes in node_sacrifice_sets.values())
        for axis in sorted(AXES)
    }

    visible_effect_choices = 0
    negative_visible_choices = 0
    positive_visible_choices = 0
    immediate_costs: Dict[str, Dict[str, Any]] = {}
    for key, row in catalog.items():
        effects = row.get("effects", {})
        if not isinstance(effects, dict):
            effects = {}
        visible = {
            effect: value for effect, value in effects.items()
            if effect in VISIBLE_NUMERIC_FIELDS and isinstance(value, (int, float))
        }
        costs = {
            effect: value for effect, value in effects.items()
            if isinstance(value, (int, float)) and value < 0
        }
        if visible:
            visible_effect_choices += 1
        if any(value < 0 for value in visible.values()):
            negative_visible_choices += 1
        if any(value > 0 for value in visible.values()):
            positive_visible_choices += 1
        if costs:
            immediate_costs[key] = costs
    return {
        "modes_by_choice_option": mode_options,
        "action_axes_by_choice_option": option_action,
        "action_axes_by_decision_node": node_action,
        "sacrificed_axes_by_choice_option": option_sacrifice,
        "sacrificed_axes_by_decision_node": node_sacrifice,
        "immediate_negative_effects_by_choice": immediate_costs,
        "visible_numeric_effect_choices": visible_effect_choices,
        "negative_visible_effect_choices": negative_visible_choices,
        "positive_visible_effect_choices": positive_visible_choices,
        "visible_numeric_fields": ["money", "health", "mental"],
    }


def consumer_graph_summary(
        consumers: Mapping[str, Dict[str, Any]],
        catalog: Mapping[str, Dict[str, Any]]) -> Dict[str, Any]:
    by_kind: Dict[str, List[str]] = {kind: [] for kind in sorted(CONSUMER_KINDS)}
    demo_reachable: List[str] = []
    outside_demo: List[str] = []
    for consumer_id, row in consumers.items():
        kind = row.get("kind")
        if kind in by_kind:
            by_kind[kind].append(consumer_id)
        if row.get("demo_reachable") is True:
            demo_reachable.append(consumer_id)
        else:
            outside_demo.append(consumer_id)
    downstream_choices: Set[str] = set()
    for consumer_id, row in consumers.items():
        if row.get("kind") in {"route", "follow_up", "history_reader"} \
                and row.get("demo_reachable") is True:
            downstream_choices.update(row.get("producer_choices", []))
    runtime_ids = {
        str(row.get("runtime_event_id", "")) for row in catalog.values()
    }
    all_authored_followup_edges = {
        key: str(row.get("follow_up_event", ""))
        for key, row in catalog.items() if row.get("follow_up_event")
    }
    authored_followup_edges = {
        key: target for key, target in all_authored_followup_edges.items()
        if target in runtime_ids
    }
    unresolved_followup_edges = {
        key: target for key, target in all_authored_followup_edges.items()
        if target not in runtime_ids
    }
    downstream_choices.update(authored_followup_edges)
    no_downstream = sorted(set(catalog) - downstream_choices)
    return {
        "contracts_by_kind": {
            kind: sorted(values) for kind, values in by_kind.items()
        },
        "demo_reachable_contracts": sorted(demo_reachable),
        "outside_demo_contracts": sorted(outside_demo),
        "exact_downstream_story_choice_count": len(downstream_choices),
        "exact_downstream_story_choices": sorted(downstream_choices),
        "authored_followup_edges": authored_followup_edges,
        "unresolved_authored_followup_edges": unresolved_followup_edges,
        "choices_without_exact_downstream_story_reader": no_downstream,
    }


def build_findings(
        catalog: Mapping[str, Dict[str, Any]],
        annotations: Mapping[str, Dict[str, Any]],
        consumer_summary: Mapping[str, Any], coverage: Mapping[str, Any],
        axis_summary: Mapping[str, Any], sources: SourceBundle) -> List[Dict[str, Any]]:
    downstream = set(consumer_summary.get("exact_downstream_story_choices", []))
    history_choices = set(EXPECTED_CONSUMERS[
        "m03_m05_exact_choice_history"]["producers"])
    m6_choices = set(EXPECTED_CONSUMERS["m06_choice_ledger"]["producers"])
    meaningful = {
        key: row for key, row in annotations.items()
        if row.get("mode") != "bridge" and key != LEDGER_EXPRESSION_CHOICE
    }
    no_sacrifice = sorted(
        key for key, row in meaningful.items()
        if not row.get("sacrificed_axes"))
    return [
        {
            "id": "runtime_receipt_selector_coverage",
            "severity": "evidence",
            "blocking": False,
            "covered": coverage.get("covered_count", 0),
            "total": coverage.get("total", 0),
            "visible_total": coverage.get("visible_total", 0),
            "excluded_state_free": coverage.get("excluded_state_free", []),
            "missing": coverage.get("missing", []),
            "summary": (
                "The focused runtime sweep applies all %d receipt-bearing "
                "selectors; the one ledger expression is visible and state-free."
                % int(coverage.get("total", 0))),
        },
        {
            "id": "m03_m05_exact_choice_history_reader",
            "severity": "evidence",
            "blocking": False,
            "producer_choices": sorted(history_choices),
            "unread": sorted(history_choices - downstream),
            "reader": "%s::_selected_history_texts_from_session" % CONTROLLER_PATH,
            "summary": (
                "M06 reads the exact selected text for all 12 M03-M05 "
                "character-choice variants."
            ),
        },
        {
            "id": "m02_restitution_callback_claimed_at_m06",
            "severity": "evidence",
            "blocking": False,
            "producer_choice": "arc_temptation_fallout#0",
            "deferred_event_id": "callback_escaped_dirty_trace",
            "due_turn": 21,
            "consumer_contract": "m02_restitution_claim",
            "root_event_id": M6_RESTITUTION_ROOT_ID,
            "demo_reachable": True,
            "summary": (
                "The due M02 restitution callback is atomically claimed at "
                "M06 entry and becomes the initial-call consequence root."
            ),
        },
        {
            "id": "m06_choice_consequence_ledger_reader",
            "severity": "evidence",
            "blocking": False,
            "producer_choices": sorted(m6_choices),
            "unread": sorted(m6_choices - downstream),
            "ledger_event_id": M6_LEDGER_ID,
            "summary": (
                "Each of the five M06 decisions opens a ledger that names the "
                "selected line and the four forgone lines."
            ),
        },
        {
            "id": "dirty_route_consequence_roots",
            "severity": "evidence",
            "blocking": False,
            "restitution_root": M6_RESTITUTION_ROOT_ID,
            "escalation_root": M6_ESCALATION_ROOT_ID,
            "summary": (
                "Restitution and escalation each reach their own two-choice "
                "M06 consequence root before the common first bill."
            ),
        },
        {
            "id": "meaningful_choices_without_explicit_sacrifice",
            "severity": "finding",
            "blocking": False,
            "choices": no_sacrifice,
            "count": len(no_sacrifice),
            "meaningful_choice_options": len(meaningful),
            "summary": (
                "%d of %d non-bridge, state-bearing choices name no explicit "
                "people, livelihood, body, or money sacrifice."
                % (len(no_sacrifice), len(meaningful))),
        },
        {
            "id": "visible_numeric_vs_exact_story_consumption",
            "severity": "finding",
            "blocking": False,
            "visible_numeric_effect_choices": axis_summary.get(
                "visible_numeric_effect_choices", 0),
            "visible_choice_options": len(catalog),
            "exact_downstream_story_choice_count": consumer_summary.get(
                "exact_downstream_story_choice_count", 0),
            "summary": (
                "%d/%d visible choices alter cash/body/mind; %d choices have "
                "an exact demo-reachable story reader."
                % (int(axis_summary.get("visible_numeric_effect_choices", 0)),
                   len(catalog), int(consumer_summary.get(
                       "exact_downstream_story_choice_count", 0)))),
        },
    ]


def validate_fixture_schema(fixture: Mapping[str, Any], errors: List[str]) -> None:
    required = {
        "schema_version", "subject", "source_blobs",
        "start_contract", "nodes", "synthetic_events",
        "reviewed_choice_annotations", "consumer_contracts",
        "runtime_coverage", "expected",
    }
    missing = sorted(required - set(fixture))
    if missing:
        errors.append("fixture missing top-level fields: %s" % missing)
    if fixture.get("schema_version") != 1:
        errors.append("fixture schema_version must be 1")


def audit_with_sources(
        fixture: Mapping[str, Any], human_gates: Any, sources: SourceBundle,
        initial_errors: Optional[Sequence[str]] = None) -> Dict[str, Any]:
    errors: List[str] = list(initial_errors or [])
    validate_fixture_schema(fixture, errors)

    # Revalidate the identity against cached exact blobs.  This makes in-memory
    # self-test mutations fail without ever resolving a different product tree.
    subject = fixture.get("subject", {})
    if not isinstance(subject, dict):
        subject = {}
    expected_subject_fields = {
        "profile", "scope", "source_commit", "source_tree", "build_id",
        "human_route_density",
    }
    if set(subject) != expected_subject_fields:
        errors.append("fixture subject exact field inventory drifted")
    if subject.get("profile") != PROFILE:
        errors.append("fixture subject profile drifted")
    source_ref = subject_value(subject, "source_ref", "source_commit", "commit")
    source_tree = subject_value(subject, "source_tree", "tree")
    build_id = subject_value(subject, "build_id", "build")
    if source_ref != sources.source_ref:
        errors.append("fixture source_ref does not match loaded exact source")
    if source_tree != sources.source_tree:
        errors.append("fixture source_tree does not match loaded exact source")
    if subject.get("scope") != "M01-M06":
        errors.append("fixture subject scope must be M01-M06")
    if subject.get("human_route_density") != "not_measured":
        errors.append("fixture must keep human_route_density=not_measured")
    gate = active_story_demo_gate(human_gates, errors)
    active_gate_match = False
    if gate:
        gate_build = active_gate_build_id(gate, errors)
        active_gate_match = gate.get("status") == "active" \
            and source_ref == gate.get("commit") \
            and source_tree == gate.get("tree") \
            and bool(gate_build) and build_id == gate_build
        if active_gate_match:
            errors.append(
                "ORDER-140 product was prematurely registered as active story_demo_rc")

    declarations = fixture.get("source_blobs", [])
    if isinstance(declarations, dict):
        declaration_rows = list(declarations.values())
    elif isinstance(declarations, list):
        declaration_rows = declarations
    else:
        declaration_rows = []
    if declaration_rows:
        declared_paths: Set[str] = set()
        for row in declaration_rows:
            if not isinstance(row, dict):
                continue
            path = row.get("path")
            digest = row.get("sha256")
            declared_oid = row.get("git_blob_oid")
            if not isinstance(path, str):
                continue
            if path in declared_paths:
                errors.append("duplicate source blob declaration %s" % path)
            declared_paths.add(path)
            payload = sources.blobs.get(path)
            if payload is None:
                errors.append("loaded exact source lacks declared blob %s" % path)
            elif digest != sha256_bytes(payload):
                errors.append("source blob hash mismatch %s" % path)
            expected_digest = EXPECTED_BLOB_SHA256.get(path)
            if expected_digest is None:
                errors.append("source blob %s is outside ORDER-140 exact baseline" % path)
            elif payload is not None and sha256_bytes(payload) != expected_digest:
                errors.append("ORDER-140 exact source baseline drifted %s" % path)
            if declared_oid != sources.blob_oids.get(path):
                errors.append("source blob OID mismatch %s" % path)
        if declared_paths != set(EXPECTED_BLOB_SHA256):
            errors.append("ORDER-140 exact source path inventory drifted")

    receipt_template = validate_controller_contract(sources, build_id, errors)
    validate_start_contract(fixture, errors)
    source_events = load_source_events(sources, errors)
    nodes = validate_nodes(fixture, source_events, errors)
    validate_authored_topology(source_events, sources, errors)
    m6_projection = validate_synthetic_event(
        fixture, source_events, sources, receipt_template, errors)
    catalog = runtime_choice_catalog(
        source_events, m6_projection, receipt_template, errors)
    annotations = validate_annotations(fixture, catalog, errors)
    consumers = validate_consumers(
        fixture, annotations, catalog, sources, errors)
    coverage = validate_runtime_coverage(fixture, sources, catalog, errors)
    signatures, survival_summary = route_signatures(catalog, sources, errors)
    signature_summary = validate_expected_counts(
        fixture, signatures, annotations, survival_summary, errors)
    axes = axis_metrics(annotations, catalog)
    consumer_summary = consumer_graph_summary(consumers, catalog)
    findings = build_findings(
        catalog, annotations, consumer_summary, coverage, axes, sources)

    report: Dict[str, Any] = {
        "status": "PASS" if not errors else "FAIL",
        "subject": {
            "profile": PROFILE,
            "source_ref": source_ref,
            "source_tree": source_tree,
            "build_id": build_id,
            "entry_scene": ENTRY_SCENE,
            "source_mode": "git_show_exact_ref_only",
            "active_human_gate_match": active_gate_match,
        },
        "source_verification": {
            "declared_blob_count": len(sources.blobs),
            "required_blob_count": len(REQUIRED_SOURCE_BLOBS),
            "working_tree_product_fallback": False,
            "blobs": [
                {
                    "path": row.get("path", ""),
                    "git_blob_oid": sources.blob_oids.get(
                        str(row.get("path", "")), ""),
                    "sha256": sha256_bytes(sources.blobs.get(
                        str(row.get("path", "")), b"")),
                }
                for row in declaration_rows if isinstance(row, dict)
            ],
        },
        "topology": {
            "months": 6,
            "weeks": 24,
            "runtime_event_variants": len(nodes),
            "visible_choice_options": len(catalog),
            "unique_choice_options": len(catalog),
            "receipt_bearing_selectors": sum(
                bool(row.get("receipt_bearing")) for row in catalog.values()),
            "unique_runtime_receipts": len({
                row.get("receipt_id") for row in catalog.values()
                if row.get("receipt_id")
            }),
            "legal_signatures": signature_summary,
            "runtime_events_by_month": {
                str(month): [
                    runtime_id for runtime_id, spec in EXPECTED_RUNTIME_SOURCES.items()
                    if spec[0] == month
                ]
                for month in range(1, 7)
            },
        },
        "synthetic_m6_projection": [{
            "runtime_choice_index": row.get("runtime_choice_index"),
            "source_choice_index": row.get("source_choice_index"),
            "removed_keys": row.get("removed_keys", []),
        } for row in m6_projection],
        "choice_catalog": [
            {
                **catalog[key],
                "mode": annotations.get(key, {}).get("mode"),
                "action_axes": annotations.get(key, {}).get("action_axes", []),
                "sacrificed_axes": annotations.get(key, {}).get("sacrificed_axes", []),
                "risk_role": annotations.get(key, {}).get("risk_role"),
                "consumer_expectations": annotations.get(key, {}).get(
                    "consumer_expectations", []),
            }
            for key in catalog
        ],
        "metrics": {
            "axes_cost_modes": axes,
            "route_survival": survival_summary,
            "risk_reach": {
                "clean": {
                    "initial_temptation": 1, "m2_claim": 0,
                    "m2_retemptation": 0, "escalation_option": 0,
                    "post_escalation_world_reaction": 0,
                },
                "restitution": {
                    "initial_temptation": 1, "m2_claim": 1,
                    "m2_retemptation": 0, "escalation_option": 0,
                    "post_m2_world_reaction": int(
                        "arc_temptation_fallout#0" in
                        consumer_summary.get("exact_downstream_story_choices", [])),
                },
                "escalation": {
                    "initial_temptation": 1, "m2_claim": 1,
                    "m2_retemptation": 1, "escalation_option": 1,
                    "post_m2_world_reaction": int(
                        "arc_temptation_fallout#1" in
                        consumer_summary.get("exact_downstream_story_choices", [])),
                },
            },
            "runtime_coverage": coverage,
        },
        "consumer_graph": consumer_summary,
        "findings": findings,
        "errors": errors,
        "gate_boundary": {
            "machine_structure": "pass" if not errors else "fail",
            "human_route_density": "not_measured",
            "human_fun": "not_measured",
            "human_gate": "OPEN",
            "automation_is_not_go": True,
        },
    }
    return report


def load_and_audit() -> Tuple[Dict[str, Any], Dict[str, Any], Any, Optional[SourceBundle]]:
    try:
        fixture = load_working_json(FIXTURE_PATH, "story demo density fixture")
        human_gates = load_working_json(HUMAN_GATES_PATH, "human gate registry")
    except ValueError as exc:
        report = {
            "status": "FAIL", "errors": [str(exc)], "findings": [],
            "gate_boundary": {
                "machine_structure": "fail",
                "human_route_density": "not_measured",
                "human_fun": "not_measured",
                "human_gate": "OPEN",
                "automation_is_not_go": True,
            },
        }
        return report, {}, {}, None
    sources, source_errors = prepare_sources(fixture, human_gates)
    if sources is None:
        report = {
            "status": "FAIL", "errors": source_errors, "findings": [],
            "gate_boundary": {
                "machine_structure": "fail",
                "human_route_density": "not_measured",
                "human_fun": "not_measured",
                "human_gate": "OPEN",
                "automation_is_not_go": True,
            },
        }
        return report, fixture, human_gates, None
    report = audit_with_sources(fixture, human_gates, sources, source_errors)
    return report, fixture, human_gates, sources


def require_mutation_failure(
        label: str, fixture: Mapping[str, Any], human_gates: Any,
        sources: SourceBundle, mutate: Any, fragment: str) -> None:
    mutated_fixture = copy.deepcopy(fixture)
    mutated_gates = copy.deepcopy(human_gates)
    mutated_sources = copy.deepcopy(sources)
    mutate(mutated_fixture, mutated_gates, mutated_sources)
    report = audit_with_sources(mutated_fixture, mutated_gates, mutated_sources)
    errors = report.get("errors", [])
    if not any(fragment in str(error) for error in errors):
        raise AssertionError(
            "%s mutation was accepted; wanted %r, errors=%s" % (
                label, fragment, errors[:5]))


def run_self_test() -> int:
    report, fixture, human_gates, sources = load_and_audit()
    if report.get("status") != "PASS" or sources is None:
        raise AssertionError("baseline audit failed: %s" % report.get("errors", [])[:5])
    cases = 0

    def case(label: str, mutate: Any, fragment: str) -> None:
        nonlocal cases
        require_mutation_failure(
            label, fixture, human_gates, sources, mutate, fragment)
        cases += 1

    def replace_source(
            bundle: SourceBundle, path: str, old: bytes, new: bytes) -> None:
        if old not in bundle.blobs[path]:
            raise AssertionError("self-test source marker missing: %r" % old)
        bundle.blobs[path] = bundle.blobs[path].replace(old, new, 1)

    def mutate_choice(
            bundle: SourceBundle, path: str, event_id: str, index: int,
            mutate: Any) -> None:
        parsed = parse_json_bytes(bundle.blobs[path], path)
        rows = parsed if isinstance(parsed, list) else parsed.get("events", [])
        event = next(
            (row for row in rows
             if isinstance(row, dict) and row.get("id") == event_id), None)
        if not isinstance(event, dict):
            raise AssertionError("self-test event missing: %s" % event_id)
        choices = event.get("choices", [])
        if not isinstance(choices, list) or index >= len(choices) \
                or not isinstance(choices[index], dict):
            raise AssertionError("self-test choice missing: %s#%d" % (
                event_id, index))
        mutate(choices[index])
        bundle.blobs[path] = json.dumps(
            parsed, ensure_ascii=False, separators=(",", ":")).encode("utf-8")

    case("stale source", lambda f, _g, _s: f["subject"].__setitem__(
        "source_commit", "0" * 40), "source_ref does not match loaded exact source")
    case("stale tree", lambda f, _g, _s: f["subject"].__setitem__(
        "source_tree", "0" * 40), "source_tree does not match loaded exact source")
    case("false human verdict", lambda f, _g, _s: f["subject"].__setitem__(
        "human_route_density", "GO"), "human_route_density=not_measured")
    case("inactive prior human gate", lambda _f, g, _s: g[
        "release_candidates"][PROFILE].__setitem__("status", "historical"),
        "is not active")
    case("premature product registration", lambda _f, g, _s: (
        g["release_candidates"][PROFILE].__setitem__("commit", EXPECTED_SOURCE_REF),
        g["release_candidates"][PROFILE].__setitem__("tree", EXPECTED_SOURCE_TREE),
        g["release_candidates"][PROFILE].__setitem__(
            "note", "BUILD %s" % EXPECTED_BUILD_ID)),
        "prematurely registered")
    case("blob digest", lambda f, _g, _s: next(iter(
        f["source_blobs"].values())).__setitem__("sha256", "0" * 64),
        "source blob hash mismatch")
    case("missing dirty node", lambda f, _g, _s: f["nodes"].__setitem__(
        slice(None), [row for row in f["nodes"] if row.get(
            "runtime_event_id") != M6_RESTITUTION_ROOT_ID]),
        "nodes missing runtime variants")
    case("ledger ingress fraud", lambda f, _g, _s: next(
        row for row in f["nodes"] if row.get("runtime_event_id") == M6_LEDGER_ID
        )["ingress"].__setitem__("producer_choices", []),
        "exact ingress binding drifted")
    case("ledger receipt fraud", lambda f, _g, _s: f[
        "reviewed_choice_annotations"][LEDGER_EXPRESSION_CHOICE][
            "consumer_expectations"].append("controller_session_receipt"),
        "consumer expectations drifted")
    case("history consumer producer", lambda f, _g, _s: next(
        row for row in f["consumer_contracts"] if row.get(
            "consumer_id") == "m03_m05_exact_choice_history"
        )["producer_choices"].pop(), "producer choice set drifted")
    case("selector exclusion fraud", lambda f, _g, _s: f[
        "runtime_coverage"].__setitem__("excluded_state_free", []),
        "state-free exclusion drifted")
    case("signature fraud", lambda f, _g, _s: f["expected"][
        "legal_signatures"].__setitem__("total", 1799),
        "expected.legal_signatures drifted")
    case("invented sacrifice", lambda f, _g, _s: f[
        "reviewed_choice_annotations"]["arc_daeun_01_meet#0"][
            "sacrificed_axes"].append("money"), "sacrificed_axes drifted")

    case("dead focused selector caller", lambda _f, _g, s: replace_source(
        s, STORY_CHOICE_CHECK_PATH,
        b'\t_check_all_receipt_selectors(controller)\n',
        b'\t# disabled selector sweep\n'), "28-selector sweep is not live")
    case("partial focused selector total", lambda _f, _g, s: replace_source(
        s, STORY_CHOICE_CHECK_PATH, b'attempts == 28,', b'attempts == 27,'),
        "live selector sweep lacks")
    case("focused selector skips dirty root", lambda _f, _g, s: replace_source(
        s, STORY_CHOICE_CHECK_PATH,
        b'\t\t{"event": M6_RESTITUTION_EVENT_ID, "route": "restitution"},\n',
        b''), "selector event inventory drifted")
    case("focused selector bypasses fresh prefix", lambda _f, _g, s: replace_source(
        s, STORY_CHOICE_CHECK_PATH,
        b'\t\t\tif not _advance_fresh_prefix_to_event(\n',
        b'\t\t\tif true or not _advance_fresh_prefix_to_event(\n'),
        "fresh-prefix selector loop/gate structure drifted")
    case("history reader detached", lambda _f, _g, s: replace_source(
        s, CONTROLLER_PATH, b'_selected_history_texts_from_session(session)',
        b'_selected_history_texts_from_session({})'),
        "does not execute the exact M03-M05 history reader")
    case("history choice no longer exact", lambda _f, _g, s: replace_source(
        s, CONTROLLER_PATH, b'_selected_choice_index_from_session(\n\t\t\tsession, event_id)',
        b'0'), "reader marker missing")
    case("deferred claim removed", lambda _f, _g, s: replace_source(
        s, CONTROLLER_PATH, b'GameState.claim_deferred_event(',
        b'GameState.peek_deferred_event('),
        "callback claim/drain is not live and atomic")
    case("deferred claim branch disabled", lambda _f, _g, s: replace_source(
        s, CONTROLLER_PATH,
        b'\tif str(context.get("source", "")) == M6_RESTITUTION_SOURCE_ID:\n',
        b'\tif false and str(context.get("source", "")) == M6_RESTITUTION_SOURCE_ID:\n'),
        "callback claim/drain is not live and atomic")
    case("ledger inserted into runtime receipts", lambda _f, _g, s: replace_source(
        s, CONTROLLER_PATH,
        b'\tM6_ESCALATION_ROOT_ID,\n]\nconst ACTION_LEDGER_KEYS',
        b'\tM6_ESCALATION_ROOT_ID,\n\tM6_LEDGER_EVENT_ID,\n]\nconst ACTION_LEDGER_KEYS'),
        "runtime receipt event inventory drifted")
    case("M6 launch skips route preparation", lambda _f, _g, s: replace_source(
        s, CONTROLLER_PATH,
        b'\t\tvar prepared := _prepare_m6_route_context_mutation()\n',
        b'\t\tvar prepared := {"ok": true}\n'),
        "live M06 launch does not consume")
    case("M6 ledger edge removed", lambda _f, _g, s: replace_source(
        s, CONTROLLER_PATH, b'choice["follow_up_event"] = M6_LEDGER_EVENT_ID',
        b'choice.erase("follow_up_event")'),
        "do not execute the ledger edge")
    case("ledger selected reader removed", lambda _f, _g, s: replace_source(
        s, CONTROLLER_PATH,
        b'event["description_if_known"] = ledger_variants',
        b'event.erase("description_if_known")'),
        "ledger exact selected/forgone reader lacks")
    case("dirty router collapsed", lambda _f, _g, s: replace_source(
        s, CONTROLLER_PATH, b'M6_ESCALATION_ROOT_ID, true',
        b'M6_RESTITUTION_ROOT_ID, true'), "dirty-root router lacks")
    case("ledger expression gains effects", lambda _f, _g, s: mutate_choice(
        s, CORE_EVENTS_PATH, M6_LEDGER_ID, 0,
        lambda choice: choice.__setitem__("effects", {"mental": 1})),
        "ledger close is not an exact state-free expression")
    case("root destroys survival", lambda _f, _g, s: mutate_choice(
        s, CORE_EVENTS_PATH, M6_RESTITUTION_ROOT_ID, 0,
        lambda choice: choice.setdefault("effects", {}).__setitem__(
            "mental", -100)), "legal signature enumeration drifted")

    try:
        parse_json_bytes(b'{"duplicate":1,"duplicate":2}', "duplicate probe")
    except ValueError as exc:
        if "duplicate JSON object key" not in str(exc):
            raise AssertionError("duplicate-key probe failed for wrong reason")
        cases += 1
    else:
        raise AssertionError("duplicate JSON keys were accepted")
    return cases


def print_human(report: Mapping[str, Any]) -> None:
    if report.get("status") != "PASS":
        errors = report.get("errors", [])
        print("STORY_DEMO_DENSITY_AUDIT_FAIL errors=%d" % len(errors))
        for error in errors:
            print("  ERROR %s" % error)
        print("  HUMAN_GATE OPEN human_route_density=not_measured human_fun=not_measured")
        return
    subject = report.get("subject", {})
    topology = report.get("topology", {})
    signatures = topology.get("legal_signatures", {})
    coverage = report.get("metrics", {}).get("runtime_coverage", {})
    print(
        "STORY_DEMO_DENSITY_AUDIT_OK "
        "source=%s tree=%s build=%s variants=%s choices=%s receipts_per_run=%s "
        "signatures=%s clean=%s restitution=%s escalation=%s" % (
            subject.get("source_ref", ""), subject.get("source_tree", ""),
            subject.get("build_id", ""), topology.get("runtime_event_variants", 0),
            topology.get("visible_choice_options", 0),
            signatures.get("receipts_per_run", 0), signatures.get("total", 0),
            signatures.get("clean", 0), signatures.get("restitution", 0),
            signatures.get("escalation", 0)))
    print(
        "  ROUTES clean=7-meaningful+2-forced "
        "restitution=9-meaningful+1-forced "
        "escalation=9-meaningful+1-forced months=6 weeks=24")
    print(
        "  RUNTIME_COVERAGE %s/%s missing=%s" % (
            coverage.get("covered_count", 0), coverage.get("total", 0),
            ",".join(coverage.get("missing", []))))
    for finding in report.get("findings", []):
        print("  FINDING %s: %s" % (
            finding.get("id", "unknown"), finding.get("summary", "")))
    print(
        "  HUMAN_GATE OPEN human_route_density=not_measured "
        "human_fun=not_measured automation_is_not_GO")


def main(argv: Optional[Sequence[str]] = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    group = parser.add_mutually_exclusive_group()
    group.add_argument("--json", action="store_true", help="print deterministic JSON")
    group.add_argument("--self-test", action="store_true", help="run mutation tests")
    args = parser.parse_args(list(argv) if argv is not None else None)

    if args.self_test:
        try:
            cases = run_self_test()
        except (AssertionError, ValueError, KeyError, IndexError) as exc:
            print("STORY_DEMO_DENSITY_AUDIT_SELF_TEST_FAIL %s" % exc)
            return 1
        print("STORY_DEMO_DENSITY_AUDIT_SELF_TEST_OK cases=%d" % cases)
        return 0

    report, _fixture, _human_gates, _sources = load_and_audit()
    if args.json:
        print(json.dumps(report, ensure_ascii=False, sort_keys=True, indent=2))
    else:
        print_human(report)
    return 0 if report.get("status") == "PASS" else 1


if __name__ == "__main__":
    raise SystemExit(main())
