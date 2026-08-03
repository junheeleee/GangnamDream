#!/usr/bin/env python3
"""Deterministic twenty-four-week economy check for the Core Loop V2 E gate.

This is deliberately an auditable ledger rather than a probability
forecast. It preserves the eight-week A1 result, demonstrates the deliberate
month-three cash pressure and twelve-week B result, proves the two authored
legal shifts can keep a sixteen-week livelihood path solvent, proves the
month-five moving shift still leaves missed work visible, verifies the first
legal job payoff, then closes Month Six with the holiday shift, the Week-24
urgent-work option, one salary, and one fixed-cost charge. It also distinguishes
arrears from global bankruptcy and checks both authored dirty-money exits. The
paired ledger holds the real start, full 24-slot schedule, routines, policy and
final action equal while measuring all three exits at the same month closes.
"""

from __future__ import annotations

import json
import re
import sys
from dataclasses import dataclass, field
from itertools import product
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
CONTRACT_PATH = ROOT / "content" / "meta" / "demo_core_loop_v2.json"
RELEASE_INVENTORY_PATH = (
    ROOT / "content" / "meta" / "release_content_inventory.json"
)
ARC_EVENTS_PATH = ROOT / "content" / "events" / "arc_events.json"
CORE_LOOP_EVENTS_PATH = ROOT / "content" / "events" / "core_loop_v2_events.json"
EVENTS_DIR = ROOT / "content" / "events"
JOBS_PATH = ROOT / "content" / "jobs.json"
GAME_STATE_PATH = ROOT / "autoloads" / "GameState.gd"
DEMO_CORE_LOOP_PATH = ROOT / "systems" / "DemoCoreLoopV2.gd"
MAIN_GAME_PATH = ROOT / "scenes" / "MainGame.gd"
STORY_MODE_PATH = ROOT / "scenes" / "StoryMode.gd"

STARTING_CASH = 500_000
OPENING_SURVIVAL_BUFFER = 300_000
MONTHLY_FIXED_COST = 650_000
A1_WEEKS = 8
B_WEEKS = 12
C_WEEKS = 16
DEVELOPMENT_WEEKS = 20
E_WEEKS = 24

STARTING_HEALTH = 65
STARTING_MENTAL = 60
STARTING_INTELLIGENCE = 55
STARTING_SOCIAL_SKILL = 45
STARTING_LUCK = 45
STARTING_REPUTATION = 5
STARTING_WORK_PERFORMANCE = 50
REALITY_HEALTH_PRESSURE = -2
REALITY_MENTAL_PRESSURE = -3
GOSIWON_MENTAL_PRESSURE = -2
UNEMPLOYED_MENTAL_PRESSURE = -2

KERNEL_ROUTINE_PAIRS = (
    ("livelihood", "growth"),
    ("livelihood", "recovery"),
    ("growth", "recovery"),
)
KERNEL_BRANCHES = ("clean", "dirty_return", "dirty_deeper")
KERNEL_POLICIES = ("cautious", "hard")

# The paired trace executes one complete, deterministic unemployed schedule.
# It keeps every authored decline with numeric effects selected, then follows
# the production E-check's causal Hyunsu/Cafe/Sangchul path and unemployed
# support schedule. The same 22 selected slots and two locked bosses are legal
# for every routine pair and temptation branch.
PAIRED_FULL_SCHEDULE = (
    (1, "father_first_call"),
    (2, "hyunsu_first_meet"),
    (3, "m1_phone_off_sunday"),
    (4, "first_temptation_boss"),
    (5, "hyunsu_player_reachout"),
    (6, "m2_sleep_debt_sunday"),
    (7, "cafe_world_glimpse"),
    (8, "sns_pressure_night"),
    (9, "m3_hanbit_application"),
    (10, "m3_empty_saturday"),
    (11, "hyunsu_study_followup"),
    (12, "father_quiet_call"),
    (13, "m4_certificate_session"),
    (14, "sangchul_world_meet"),
    (15, "m4_logistics_shift"),
    (16, "m4_health_check_day"),
    (17, "m5_city_service_application"),
    (18, "m5_last_empty_sunday"),
    (19, "m5_evening_spreadsheet_class"),
    (20, "m5_employment_contract_clinic"),
    (21, "m6_public_recruitment"),
    (22, "m6_last_study_group"),
    (23, "hyunsu_exam_eve"),
    (24, "demo_collision"),
)
PAIRED_LOCKED_SLOTS = {4: "first_temptation_boss", 24: "demo_collision"}
PAIRED_PLAYER_SELECTED_SLOTS = 22
PAIRED_SNAPSHOT_WEEKS = (4, 8, 12, 16, 20, 24)
OMITTED_PUBLIC_DELTA_STATS = (
    "appearance", "investment_skill", "work_performance",
)
EXPECTED_PAIRED_PARETO_COUNTS = {
    "deeper_return_path": 648,
    "deeper_clean_path": 116,
    "deeper_clean_w24": 582,
    "deeper_clean_w24_nonpareto": 66,
}
EXPECTED_PAIRED_W24_CANDIDATES = (
    "father_call",
    "city_work_sample",
    "urgent_paid_shift",
    "body_rest",
)

PROLOGUE_SEQUENCE = (
    "story_flashforward",
    "story_arrival",
    "story_knee_door",
    "story_knee_witness",
    "story_knee_choice",
    "story_last_payment_wait",
    "story_last_payment_word",
    "story_last_payment_exit",
    "story_prologue_dad",
    "story_prologue_goal",
    "story_prologue_meal",
    "story_pressure",
)
PROLOGUE_POLICY_EVENTS = (
    ("story_knee_choice", 3, "knee"),
    ("story_last_payment_word", 3, "payment"),
    ("story_prologue_dad", 2, "dad"),
    ("story_prologue_goal", 3, "goal"),
    ("story_prologue_meal", 2, "meal"),
)
REPRESENTATIVE_PROLOGUE_POLICY = "knee0-payment0-dad0-goal0-meal0"
EXPECTED_PROLOGUE_EFFECTS = {
    "story_flashforward": ({},),
    "story_arrival": ({},),
    "story_knee_door": ({},),
    "story_knee_witness": ({"mental": -2},),
    "story_knee_choice": (
        {"mental": -2, "tint": 2, "route_orthodox": 1},
        {"mental": -4},
        {"mental": -2, "tint": -2, "route_unorthodox": 1},
    ),
    "story_last_payment_wait": ({},),
    "story_last_payment_word": (
        {"mental": -2},
        {"tint": 2, "route_orthodox": 1},
        {"mental": 1, "tint": -2, "route_unorthodox": 1},
    ),
    "story_last_payment_exit": ({},),
    "story_prologue_dad": (
        {"mental": 5, "tint": 2},
        {"mental": -5, "tint": -2},
    ),
    "story_prologue_goal": (
        {"mental": 5},
        {"mental": 3},
        {"mental": 4},
    ),
    "story_prologue_meal": (
        {"money": -1_200, "health": 3},
        {"health": -5, "mental": -6},
    ),
    "story_pressure": ({"intelligence": 2},),
}

# These are branch-only kernels, not claims about arbitrary full routes. They
# include the two background routines, the authored Week-4/8 temptation branch,
# the universal Week-21 Father signal, the branch-owned Week-24 callback, the
# Week-24 First Bill choice, and all six real monthly-pressure settlements. They
# deliberately exclude selected foreground actions, decline outcomes, loans,
# addiction and relationship passives; those belong to named runtime routes.
EXPECTED_KERNEL_TRAJECTORIES = {
    "livelihood+growth/clean/cautious": {
        "mental": (51, 60, 57, 54, 51, 47),
        "health": (59, 53, 47, 41, 35, 31),
    },
    "livelihood+growth/clean/hard": {
        "mental": (51, 60, 57, 54, 51, 39),
        "health": (59, 53, 47, 41, 35, 24),
    },
    "livelihood+growth/dirty_return/cautious": {
        "mental": (45, 25, 24, 21, 18, 10),
        "health": (59, 49, 43, 37, 31, 27),
    },
    "livelihood+growth/dirty_return/hard": {
        "mental": (45, 25, 24, 21, 18, 1),
        "health": (59, 49, 43, 37, 31, 20),
    },
    "livelihood+growth/dirty_deeper/cautious": {
        "mental": (45, 32, 33, 34, 35, 33),
        "health": (59, 53, 47, 41, 35, 31),
    },
    "livelihood+growth/dirty_deeper/hard": {
        "mental": (45, 32, 33, 34, 35, 23),
        "health": (59, 53, 47, 41, 35, 24),
    },
    "livelihood+recovery/clean/cautious": {
        "mental": (59, 76, 81, 86, 89, 89),
        "health": (63, 61, 59, 57, 55, 55),
    },
    "livelihood+recovery/clean/hard": {
        "mental": (59, 76, 81, 86, 89, 85),
        "health": (63, 61, 59, 57, 55, 48),
    },
    "livelihood+recovery/dirty_return/cautious": {
        "mental": (53, 41, 48, 53, 58, 58),
        "health": (63, 57, 55, 53, 51, 51),
    },
    "livelihood+recovery/dirty_return/hard": {
        "mental": (53, 41, 48, 53, 58, 49),
        "health": (63, 57, 55, 53, 51, 44),
    },
    "livelihood+recovery/dirty_deeper/cautious": {
        "mental": (53, 48, 57, 66, 75, 81),
        "health": (63, 61, 59, 57, 55, 55),
    },
    "livelihood+recovery/dirty_deeper/hard": {
        "mental": (53, 48, 57, 66, 75, 71),
        "health": (63, 61, 59, 57, 55, 48),
    },
    "growth+recovery/clean/cautious": {
        "mental": (59, 74, 79, 84, 89, 89),
        "health": (67, 69, 71, 73, 75, 79),
    },
    "growth+recovery/clean/hard": {
        "mental": (59, 74, 79, 84, 89, 85),
        "health": (67, 69, 71, 73, 75, 72),
    },
    "growth+recovery/dirty_return/cautious": {
        "mental": (53, 41, 46, 51, 56, 56),
        "health": (67, 65, 67, 69, 71, 75),
    },
    "growth+recovery/dirty_return/hard": {
        "mental": (53, 41, 46, 51, 56, 47),
        "health": (67, 65, 67, 69, 71, 68),
    },
    "growth+recovery/dirty_deeper/cautious": {
        "mental": (53, 48, 57, 66, 75, 80),
        "health": (67, 69, 71, 73, 75, 79),
    },
    "growth+recovery/dirty_deeper/hard": {
        "mental": (53, 48, 57, 66, 75, 71),
        "health": (67, 69, 71, 73, 75, 72),
    },
}


@dataclass
class Ledger:
    name: str
    cash: int = STARTING_CASH + OPENING_SURVIVAL_BUFFER
    health: int = 0
    mental: int = 0
    intelligence: int = 0
    work_performance: int = 0
    luck: int = 0
    tint: int = 0
    flags: set[str] = field(default_factory=set)
    routine_units: int = 0

    def apply_effects(self, effects: dict[str, Any]) -> None:
        for stat, raw_value in effects.items():
            value = int(raw_value)
            if stat == "money":
                self.cash += value
            elif hasattr(self, stat):
                setattr(self, stat, int(getattr(self, stat)) + value)


@dataclass
class SurvivalLedger:
    """Deterministic ledger shared by branch-only and selected-route checks."""

    name: str
    cash: int = STARTING_CASH + OPENING_SURVIVAL_BUFFER
    health: int = STARTING_HEALTH
    mental: int = STARTING_MENTAL
    intelligence: int = 0
    social_skill: int = 0
    work_performance: int = 0
    luck: int = 0
    reputation: int = 0
    tint: int = 0
    route_orthodox: int = 0
    route_unorthodox: int = 0
    routine_units: int = 0
    settlement_claims: int = 0
    death_week: int = 0
    monthly_snapshots: list[dict[str, Any]] = field(default_factory=list)

    def apply_effects(self, effects: dict[str, Any]) -> None:
        for stat, raw_value in effects.items():
            value = int(raw_value)
            if stat == "money":
                self.cash += value
            elif hasattr(self, stat):
                setattr(self, stat, int(getattr(self, stat)) + value)
        for stat in (
            "health", "mental", "intelligence", "social_skill",
            "work_performance", "luck",
        ):
            setattr(self, stat, max(0, min(100, int(getattr(self, stat)))))
        self.reputation = max(-100, min(100, self.reputation))
        self.tint = max(-100, min(100, self.tint))
        self.route_orthodox = max(0, self.route_orthodox)
        self.route_unorthodox = max(0, self.route_unorthodox)

    def apply_monthly_pressure(self, week: int) -> None:
        # Mirrors GameState.apply_monthly_pressure for the reality-difficulty,
        # unemployed, gosiwon, no-loan/no-addiction/no-relationship kernel.
        self.cash -= MONTHLY_FIXED_COST
        self.apply_effects({
            "health": REALITY_HEALTH_PRESSURE,
            "mental": REALITY_MENTAL_PRESSURE
            + GOSIWON_MENTAL_PRESSURE
            + UNEMPLOYED_MENTAL_PRESSURE,
        })
        required_cash = MONTHLY_FIXED_COST
        reserve_target = required_cash * 3
        if self.cash < 0:
            reserve_band = "negative"
            reserve_mental = -4
        elif self.cash < required_cash:
            reserve_band = "uncovered"
            reserve_mental = -2
        elif self.cash < reserve_target:
            reserve_band = "thin"
            reserve_mental = -1
        else:
            reserve_band = "safe"
            reserve_mental = 0
        self.apply_effects({"mental": reserve_mental})
        self.monthly_snapshots.append({
            "week": week,
            "cash": self.cash,
            "health": self.health,
            "mental": self.mental,
            "intelligence": self.intelligence,
            "social_skill": self.social_skill,
            "luck": self.luck,
            "reputation": self.reputation,
            "tint": self.tint,
            "route_orthodox": self.route_orthodox,
            "route_unorthodox": self.route_unorthodox,
            "reserve_band": reserve_band,
        })


def fail(message: str, errors: list[str]) -> None:
    errors.append(message)


def load_json(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8"))


def load_event_catalog(errors: list[str]) -> list[Any]:
    """Load the same authored event directory used by DataRegistry."""

    events: list[Any] = []
    seen: set[str] = set()
    for path in sorted(EVENTS_DIR.glob("*.json")):
        payload = load_json(path)
        if not isinstance(payload, list):
            continue
        for raw_event in payload:
            if not isinstance(raw_event, dict):
                continue
            event_id = str(raw_event.get("id", "")).strip()
            if not event_id:
                continue
            if event_id in seen:
                fail(f"duplicate authored event id {event_id}", errors)
                continue
            seen.add(event_id)
            events.append(raw_event)
    return events


def weekly_effects(
    options: dict[str, Any], routine_id: str, employed: bool = False
) -> dict[str, Any]:
    option = options.get(routine_id, {})
    effects = option.get("weekly_effects", {}) if isinstance(option, dict) else {}
    if routine_id == "livelihood" and isinstance(effects, dict):
        profile = "employed" if employed else "unemployed"
        effects = effects.get(profile, {})
    return effects if isinstance(effects, dict) else {}


def simulate_legal(
    name: str,
    routine_pair: tuple[str, str],
    options: dict[str, Any],
    weeks: int = DEVELOPMENT_WEEKS,
) -> Ledger:
    ledger = Ledger(name=name)
    for _week in range(1, weeks + 1):
        for routine_id in routine_pair:
            ledger.apply_effects(weekly_effects(options, routine_id))
            ledger.routine_units += 1
        if _week % 4 == 0:
            ledger.cash -= MONTHLY_FIXED_COST
    return ledger


def simulate_hired_month_five(
    name: str,
    routine_pair: tuple[str, str],
    options: dict[str, Any],
    first_paycheck: int,
) -> Ledger:
    ledger = Ledger(name=name)
    for week in range(1, DEVELOPMENT_WEEKS + 1):
        # MainGame applies the Week-17 background routines before the Hanbit
        # result prelude. The accepted job therefore replaces livelihood from
        # Week 18 onward. The final Month-Five deposit covers only those three
        # worked weeks; the normal monthly salary starts next month.
        employed = week >= 18
        for routine_id in routine_pair:
            ledger.apply_effects(
                weekly_effects(options, routine_id, employed=employed)
            )
            ledger.routine_units += 1
        if week % 4 == 0:
            ledger.cash -= MONTHLY_FIXED_COST
            if employed:
                ledger.cash += first_paycheck
    return ledger


def simulate_hired_month_six_from_close(
    name: str,
    starting_cash: int,
    routine_pair: tuple[str, str],
    options: dict[str, Any],
    monthly_salary: int,
) -> Ledger:
    ledger = Ledger(name=name, cash=starting_cash)
    for _week in range(21, E_WEEKS + 1):
        for routine_id in routine_pair:
            ledger.apply_effects(
                weekly_effects(options, routine_id, employed=True)
            )
            ledger.routine_units += 1
    ledger.cash += monthly_salary
    ledger.cash -= MONTHLY_FIXED_COST
    return ledger


def action_config(contract: dict[str, Any], bundle_id: str) -> dict[str, Any]:
    bundles = contract.get("scene_bundles", {})
    if not isinstance(bundles, dict):
        return {}
    bundle = bundles.get(bundle_id, {})
    if not isinstance(bundle, dict):
        return {}
    config = bundle.get("action_config", {})
    return config if isinstance(config, dict) else {}


def event_by_id(events: list[Any], event_id: str) -> dict[str, Any]:
    return next(
        (
            row
            for row in events
            if isinstance(row, dict) and row.get("id") == event_id
        ),
        {},
    )


def dirty_choice(events: list[Any]) -> dict[str, Any]:
    temptation = event_by_id(events, "arc_temptation_01")
    for raw_choice in temptation.get("choices", []):
        if not isinstance(raw_choice, dict):
            continue
        effects = raw_choice.get("effects", {})
        flags = raw_choice.get("flags", [])
        if (
            isinstance(effects, dict)
            and int(effects.get("money", 0)) > 0
            and isinstance(flags, list)
            and "lent_account" in flags
        ):
            return raw_choice
    return {}


def choice_with_flag(event: dict[str, Any], flag: str) -> dict[str, Any]:
    for raw_choice in event.get("choices", []):
        if not isinstance(raw_choice, dict):
            continue
        flags = raw_choice.get("flags", [])
        if isinstance(flags, list) and flag in flags:
            return raw_choice
    return {}


def choice_with_mental_delta(event: dict[str, Any], delta: int) -> dict[str, Any]:
    for raw_choice in event.get("choices", []):
        if not isinstance(raw_choice, dict):
            continue
        effects = raw_choice.get("effects", {})
        if isinstance(effects, dict) and int(effects.get("mental", 0)) == delta:
            return raw_choice
    return {}


def choice_with_obligation(event: dict[str, Any], obligation_id: str) -> dict[str, Any]:
    for raw_choice in event.get("choices", []):
        if (
            isinstance(raw_choice, dict)
            and raw_choice.get("v2_obligation_id") == obligation_id
        ):
            return raw_choice
    return {}


def choice_effects(choice: dict[str, Any]) -> dict[str, Any]:
    effects = choice.get("effects", {}) if isinstance(choice, dict) else {}
    return effects if isinstance(effects, dict) else {}


def resolve_fresh_prologue_policies(
    events: list[Any], errors: list[str]
) -> list[dict[str, Any]]:
    """Enumerate every legal fresh-start prologue choice policy."""

    release_inventory = load_json(RELEASE_INVENTORY_PATH)
    reachability = release_inventory.get("v2_reachability_contract", {}) \
        if isinstance(release_inventory, dict) else {}
    release_root = str(reachability.get("fresh_start_prologue_root", "")) \
        if isinstance(reachability, dict) else ""
    if release_root != PROLOGUE_SEQUENCE[0]:
        fail(
            f"release ledger prologue root drifted to {release_root or 'missing'}",
            errors,
        )

    main_source = MAIN_GAME_PATH.read_text(encoding="utf-8")
    route_match = re.search(
        r"func _begin_month_story_and_render\(\).*?(?=\nfunc )",
        main_source,
        re.DOTALL,
    )
    route_block = route_match.group(0) if route_match else ""
    if not re.search(
        r'GameState\.turn\s*==\s*1.*?'
        r'not\s+GameState\.flags\.get\("prologue_done",\s*false\).*?'
        r'GameState\.flags\["prologue_done"\]\s*=\s*true.*?'
        r'not\s+GameState\.flags\.get\('
        r'"story_flashforward_seen",\s*false\s*\).*?'
        r'_go_story_mode\(\["story_flashforward"\]\).*?'
        r'_go_story_mode\(\["story_arrival"\]\)',
        route_block,
        re.DOTALL,
    ):
        fail("fresh MainGame route no longer owns flashforward -> arrival", errors)

    variable_counts = {
        event_id: count for event_id, count, _label in PROLOGUE_POLICY_EVENTS
    }
    for index, event_id in enumerate(PROLOGUE_SEQUENCE):
        event = event_by_id(events, event_id)
        raw_choices = event.get("choices", []) if event else []
        expected_effects = EXPECTED_PROLOGUE_EFFECTS.get(event_id, ())
        expected_count = variable_counts.get(event_id, 1)
        if not event or not isinstance(raw_choices, list) \
                or len(raw_choices) != expected_count:
            fail(
                f"fresh prologue {event_id} has {len(raw_choices) if isinstance(raw_choices, list) else 'invalid'} "
                f"choices instead of {expected_count}",
                errors,
            )
            continue
        actual_effects = tuple(
            choice_effects(choice) if isinstance(choice, dict) else {}
            for choice in raw_choices
        )
        if actual_effects != expected_effects:
            fail(
                f"fresh prologue {event_id} effects drifted: {actual_effects}",
                errors,
            )
        expected_followup = (
            PROLOGUE_SEQUENCE[index + 1]
            if index + 1 < len(PROLOGUE_SEQUENCE) else ""
        )
        for choice_index, raw_choice in enumerate(raw_choices):
            if not isinstance(raw_choice, dict):
                continue
            followup = str(raw_choice.get("follow_up_event", ""))
            if followup != expected_followup:
                fail(
                    f"fresh prologue {event_id}/{choice_index} routes to "
                    f"{followup or 'end'} instead of {expected_followup or 'end'}",
                    errors,
                )
            if str(raw_choice.get("choice_kind", "")).lower() == "expression" \
                    or raw_choice.get("requires_item") \
                    or raw_choice.get("requirements"):
                fail(
                    f"fresh prologue {event_id}/{choice_index} is no longer an "
                    "unconditional persistent choice",
                    errors,
                )

    policies: list[dict[str, Any]] = []
    choice_ranges = [range(count) for _event_id, count, _label in (
        PROLOGUE_POLICY_EVENTS
    )]
    for indices in product(*choice_ranges):
        choices = {
            event_id: choice_index
            for (event_id, _count, _label), choice_index in zip(
                PROLOGUE_POLICY_EVENTS, indices
            )
        }
        policy_id = "-".join(
            f"{label}{choice_index}"
            for (_event_id, _count, label), choice_index in zip(
                PROLOGUE_POLICY_EVENTS, indices
            )
        )
        ledger = SurvivalLedger(
            name=f"prologue/{policy_id}",
            cash=STARTING_CASH,
            intelligence=STARTING_INTELLIGENCE,
            social_skill=STARTING_SOCIAL_SKILL,
            work_performance=STARTING_WORK_PERFORMANCE,
            luck=STARTING_LUCK,
            reputation=STARTING_REPUTATION,
        )
        flags: set[str] = set()
        for event_id in PROLOGUE_SEQUENCE:
            event = event_by_id(events, event_id)
            raw_choices = event.get("choices", []) if event else []
            choice_index = int(choices.get(event_id, 0))
            if not isinstance(raw_choices, list) or choice_index >= len(raw_choices) \
                    or not isinstance(raw_choices[choice_index], dict):
                fail(
                    f"fresh prologue policy {policy_id} lost "
                    f"{event_id}/{choice_index}",
                    errors,
                )
                continue
            choice = raw_choices[choice_index]
            ledger.apply_effects(choice_effects(choice))
            raw_flags = choice.get("flags", [])
            if isinstance(raw_flags, list):
                flags.update(str(value) for value in raw_flags)
        policies.append({
            "id": policy_id,
            "choices": choices,
            "cash": ledger.cash,
            "health": ledger.health,
            "mental": ledger.mental,
            "intelligence": ledger.intelligence,
            "social_skill": ledger.social_skill,
            "work_performance": ledger.work_performance,
            "luck": ledger.luck,
            "reputation": ledger.reputation,
            "tint": ledger.tint,
            "route_orthodox": ledger.route_orthodox,
            "route_unorthodox": ledger.route_unorthodox,
            "flags": tuple(sorted(flags)),
        })

    expected_policy_count = 1
    for _event_id, count, _label in PROLOGUE_POLICY_EVENTS:
        expected_policy_count *= count
    if len(policies) != expected_policy_count or len({
        str(policy["id"]) for policy in policies
    }) != expected_policy_count:
        fail(
            f"fresh prologue produced {len(policies)} policies instead of "
            f"{expected_policy_count}",
            errors,
        )
    representative = next(
        (policy for policy in policies
         if policy["id"] == REPRESENTATIVE_PROLOGUE_POLICY),
        {},
    )
    expected_representative = {
        "cash": 498_800,
        "health": 68,
        "mental": 64,
        "intelligence": 57,
        "tint": 4,
        "route_orthodox": 1,
        "route_unorthodox": 0,
    }
    if not representative or any(
        int(representative.get(stat, -999)) != value
        for stat, value in expected_representative.items()
    ):
        fail(
            f"fresh prologue choice-0 baseline drifted: {representative}",
            errors,
        )
    return policies


def validate_runtime_monthly_pressure(errors: list[str]) -> None:
    """Keep the deterministic mirror tied to GameState's live constants."""

    source = GAME_STATE_PATH.read_text(encoding="utf-8")
    start_match = re.search(
        r"func start_new_game\(.*?(?=\nfunc )", source, re.DOTALL
    )
    start_block = start_match.group(0) if start_match else ""
    for stat, expected in (
        ("health", STARTING_HEALTH),
        ("mental", STARTING_MENTAL),
        ("intelligence", STARTING_INTELLIGENCE),
        ("social_skill", STARTING_SOCIAL_SKILL),
        ("luck", STARTING_LUCK),
        ("reputation", STARTING_REPUTATION),
        ("work_performance", STARTING_WORK_PERFORMANCE),
    ):
        if not re.search(rf"\b{stat}\s*=\s*{expected}\b", start_block):
            fail(
                f"new-game {stat} drifted from paired start {expected}",
                errors,
            )
    if not re.search(
        rf"INITIAL_SETTLEMENT_SUBSIDY\s*:=\s*{OPENING_SURVIVAL_BUFFER:_}\.0",
        source,
    ):
        fail("initial settlement subsidy drifted from KRW 300,000", errors)
    reality_pattern = re.compile(
        r'"현실"\s*:\s*\{.*?"start_money"\s*:\s*500_000\.0\s*,.*?'
        r'"pressure_health"\s*:\s*-2\s*,\s*'
        r'"pressure_mental"\s*:\s*-3',
        re.DOTALL,
    )
    if not reality_pattern.search(source):
        fail(
            "reality start/pressure drifted from cash 500,000, health -2, "
            "mental -3",
            errors,
        )
    if not re.search(r"\bmoral_tint\s*=\s*0\.0\b", start_block):
        fail("new-game hidden moral tint drifted from 0", errors)

    housing_match = re.search(
        r'match housing:(.*?)# ── 인연 패시브', source, re.DOTALL
    )
    housing_block = housing_match.group(1) if housing_match else ""
    gosiwon_match = re.search(
        r'"gosiwon":(.*?)(?:"villa", "apartment":)',
        housing_block,
        re.DOTALL,
    )
    gosiwon_block = gosiwon_match.group(1) if gosiwon_match else ""
    if gosiwon_block.count('modify_stat("mental", -1)') != 2:
        fail("gosiwon monthly pressure drifted from mental -2", errors)
    if not re.search(
        r'if monthly_income == 0:\s*modify_stat\("mental", -2\)',
        source,
    ):
        fail("unemployed monthly pressure drifted from mental -2", errors)

    reserve_expectations = (
        ('reserve_band = "negative"', 'modify_stat("mental", -4)'),
        ('reserve_band = "uncovered"', 'modify_stat("mental", -2)'),
        ('reserve_band = "thin"', 'modify_stat("mental", -1)'),
    )
    for band_source, penalty_source in reserve_expectations:
        band_index = source.find(band_source)
        penalty_index = source.find(penalty_source, band_index)
        if band_index < 0 or penalty_index < band_index or penalty_index > band_index + 180:
            fail(
                f"cash-reserve monthly pressure drifted near {band_source}",
                errors,
            )

    main_source = MAIN_GAME_PATH.read_text(encoding="utf-8")
    month_end_match = re.search(
        r"func _run_month_end_transition\(.*?(?=\nfunc )",
        main_source,
        re.DOTALL,
    )
    month_end = month_end_match.group(0) if month_end_match else ""
    passives_at = month_end.find("job_system.process_monthly_job()")
    subsidy_at = month_end.find("GameState.claim_initial_settlement_subsidy()")
    pressure_at = month_end.find("GameState.apply_monthly_pressure()")
    if not 0 <= passives_at < subsidy_at < pressure_at:
        fail(
            "month end no longer applies passives, then the one-time subsidy, "
            "then shared pressure",
            errors,
        )


def validate_runtime_temptation_callbacks(errors: list[str]) -> None:
    """Tie the measured Week-24 roots to the flags used by the live router."""

    source = DEMO_CORE_LOOP_PATH.read_text(encoding="utf-8")
    prepare_match = re.search(
        r"static func prepare_demo_collision\(\).*?"
        r"(?=\nstatic func |\Z)",
        source,
        re.DOTALL,
    )
    prepare_block = prepare_match.group(0) if prepare_match else ""
    if not prepare_block:
        fail("paired trace lost the live demo-collision router", errors)
        return
    mappings = (
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
    for flag, source_id, event_id in mappings:
        pattern = re.compile(
            rf'GameState\.flags\.get\("{re.escape(flag)}", false\)'
            rf'.*?dirty_source\s*=\s*"{re.escape(source_id)}"'
            rf'.*?dirty_root\s*=\s*"{re.escape(event_id)}"',
            re.DOTALL,
        )
        if not pattern.search(prepare_block):
            fail(
                f"live Week-24 routing lost {flag} -> {event_id}",
                errors,
            )
    escaped_at = prepare_block.find(
        'if bool(GameState.flags.get("escaped_dirty_money", false)):'
    )
    darker_at = prepare_block.find(
        'elif bool(GameState.flags.get("fell_to_darkness", false)):',
        escaped_at,
    )
    dirty_append = prepare_block.find("roots.append(dirty_root)", darker_at)
    escaped_receipt_block = prepare_block[escaped_at:darker_at]
    darker_receipt_block = prepare_block[darker_at:dirty_append]
    if (
        escaped_at < 0
        or darker_at < 0
        or dirty_append < 0
        or 'state["deferred_callback_receipts"][dirty_source]' \
            not in escaped_receipt_block
        or '"status": "claimed"' not in escaped_receipt_block
        or '"synthetic": false' not in escaped_receipt_block
        or 'state["deferred_callback_receipts"][dirty_source]' \
            not in darker_receipt_block
        or '"status": "claimed"' not in darker_receipt_block
        or '"synthetic": true' not in darker_receipt_block
    ):
        fail(
            "live Week-24 branch receipts lost the exact return/deeper "
            "synthetic distinction",
            errors,
        )

    resolve_match = re.search(
        r"static func _note_deferred_callback_story_choice\(.*?"
        r"(?=\nstatic func |\Z)",
        source,
        re.DOTALL,
    )
    resolve_block = resolve_match.group(0) if resolve_match else ""
    if not re.search(
        r'receipt\.get\("root", ""\)\) != event_id.*?'
        r'receipt\.get\("status", ""\)\) != "claimed".*?'
        r'receipt\["status"\] = "resolved".*?'
        r'receipt\["event_id"\] = event_id.*?'
        r'receipt\["choice_index"\] = choice_index.*?'
        r'state\["deferred_callback_receipts"\]\[source\] = receipt',
        resolve_block,
        re.DOTALL,
    ):
        fail(
            "live Week-24 branch receipt no longer resolves against the exact "
            "callback event and choice",
            errors,
        )
    opening_append = prepare_block.find("roots.append(opening_root)")
    exam_append = prepare_block.find(
        'roots.append("v2_hyunsu_exam_morning_echo")'
    )
    if not 0 <= dirty_append < opening_append < exam_append:
        fail(
            "live Week-24 roots no longer order dirty callback, First Bill, "
            "then Hyunsu echo",
            errors,
        )

    roots_match = re.search(
        r"static func resolved_event_roots\(bundle_id: String\).*?"
        r"(?=\nstatic func |\Z)",
        source,
        re.DOTALL,
    )
    roots_block = roots_match.group(0) if roots_match else ""
    if not re.search(
        r'if bundle_id == "temptation_consequence":\s*'
        r'if bool\(GameState\.flags\.get\("lent_account", false\)\):\s*'
        r'return \["arc_temptation_fallout"\]\s*'
        r'return \["arc_temptation_clean"\]',
        roots_block,
        re.DOTALL,
    ):
        fail(
            "live temptation roots no longer resolve lent_account to fallout "
            "and every other state to clean",
            errors,
        )

    main_source = MAIN_GAME_PATH.read_text(encoding="utf-8")
    route_match = re.search(
        r"func _core_loop_v2_route_week\(\).*?(?=\nfunc )",
        main_source,
        re.DOTALL,
    )
    route_block = route_match.group(0) if route_match else ""
    routine_at = route_block.find("apply_background_routines_for_turn()")
    prelude_at = route_block.find("claim_scheduled_prelude(bundle_id)")
    action_at = route_block.find("_core_loop_v2_begin_action_bundle")
    story_at = route_block.find("_core_loop_v2_begin_story_bundle(bundle_id")
    if not 0 <= routine_at < prelude_at < action_at \
            or not 0 <= routine_at < prelude_at < story_at:
        fail(
            "live weekly route no longer applies routines, scheduled prelude, "
            "then foreground",
            errors,
        )


def validate_runtime_city_service_prelude(errors: list[str]) -> None:
    """Tie the Week-23 result prelude to the live eligibility and queue order."""

    source = DEMO_CORE_LOOP_PATH.read_text(encoding="utf-8")
    main_source = MAIN_GAME_PATH.read_text(encoding="utf-8")
    submit_match = re.search(
        r"func _core_loop_v2_submit_application\(.*?(?=\nfunc )",
        main_source,
        re.DOTALL,
    )
    submit_block = submit_match.group(0) if submit_match else ""
    if not re.search(
        r'action_config\.get\("application_id", ""\).*?'
        r'action_config\.get\("status", "submitted"\).*?'
        r'"execution": "application".*?'
        r'finalize_weekly_effect_action\(\s*'
        r'"apply", \{\}, "money", "work", "", receipt\)',
        submit_block,
        re.DOTALL,
    ):
        fail(
            "live Week-17 application no longer records its configured id and "
            "status through an effectless application action",
            errors,
        )

    action_match = re.search(
        r"static func note_action_commitment\(.*?(?=\nstatic func |\Z)",
        source,
        re.DOTALL,
    )
    action_block = action_match.group(0) if action_match else ""
    receipt_at = action_block.find("_action_receipt_from_record(")
    application_at = action_block.find(
        'var application_id := str(receipt.get("application_id", ""))',
        receipt_at,
    )
    status_at = action_block.find(
        'var status := str(receipt.get("application_status", ""))',
        application_at,
    )
    receipt_store_at = action_block.find(
        'state["action_receipts"][active_id] = receipt',
        status_at,
    )
    store_at = action_block.find(
        'state["application_statuses"][application_id] = status',
        receipt_store_at,
    )
    state_store_at = action_block.find(
        "GameState.core_loop_v2_state = state", store_at
    )
    if not 0 <= receipt_at < application_at < status_at \
            < receipt_store_at < store_at < state_store_at:
        fail(
            "live action receipt no longer persists the Week-17 application "
            "status used by the city-response prerequisite",
            errors,
        )

    pending_match = re.search(
        r"static func pending_consequence_id\(.*?(?=\nstatic func |\Z)",
        source,
        re.DOTALL,
    )
    pending_block = pending_match.group(0) if pending_match else ""
    allowed_at = pending_block.find(
        "bundle_allowed_in_week(consequence_id, int(GameState.turn))"
    )
    prerequisite_at = pending_block.find(
        "_bundle_requirement_met(consequence, int(GameState.turn))"
    )
    return_at = pending_block.find("return consequence_id", prerequisite_at)
    if not 0 <= allowed_at < prerequisite_at < return_at:
        fail(
            "live consequence router no longer checks week and prerequisites "
            "before selecting the Week-23 city response",
            errors,
        )

    play_match = re.search(
        r"func _core_loop_v2_play_scheduled_prelude\(.*?(?=\nfunc )",
        main_source,
        re.DOTALL,
    )
    play_block = play_match.group(0) if play_match else ""
    roots_at = play_block.find("var roots: Array = (")
    prepare_at = play_block.find(
        "DEMO_CORE_LOOP_V2.prepare_story_bundle(consequence_id)", roots_at
    )
    scheduled_at = play_block.find(
        "DEMO_CORE_LOOP_V2.resolved_event_roots(\n\t\t\tbundle_id)",
        prepare_at,
    )
    append_at = play_block.find("roots.append(str(raw_root))", scheduled_at)
    story_at = play_block.find("_go_story_mode(roots)", append_at)
    if not 0 <= roots_at < prepare_at < scheduled_at < append_at < story_at:
        fail(
            "live scheduled prelude no longer queues consequence roots before "
            "the scheduled Week-23 story",
            errors,
        )

    candidates_match = re.search(
        r"static func _demo_collision_candidate_ids\(state: Dictionary\).*?"
        r"(?=\nstatic func |\Z)",
        source,
        re.DOTALL,
    )
    candidates_block = candidates_match.group(0) if candidates_match else ""
    candidate_guards = (
        r'var priority: Array\[String\] = \["father_call"\]',
        r'application_status\("city_facility_ops_2026h1"\) == "submitted"'
        r'[\s\S]*?_consequence_was_presented\('
        r'\s*state,\s*"m6_city_service_response"\s*\)'
        r'[\s\S]*?priority\.append\("city_work_sample"\)',
        r'if has_hanbit_employment_provenance\(state\):\s*'
        r'priority\.append\("hanbit_month_close"\)',
        r'var person_obligation := _demo_person_obligation\(state\)\s*'
        r'if not person_obligation\.is_empty\(\):\s*'
        r'priority\.append\(person_obligation\)',
        r'if GameState\.current_job\.is_empty\(\):\s*'
        r'priority\.append\("urgent_paid_shift"\)',
        r'priority\.append\("body_rest"\)',
        r'selected\.size\(\) < 4',
    )
    if not candidates_block or any(
        re.search(pattern, candidates_block, re.DOTALL) is None
        for pattern in candidate_guards
    ):
        fail(
            "live Week-24 candidate builder no longer exposes the selected "
            "city sample, unemployed urgent shift, and body-rest controls",
            errors,
        )
    literal_candidates = tuple(re.findall(
        r'priority\.append\("([^"]+)"\)', candidates_block
    ))
    canonical_match = re.search(
        r"var canonical_order := \[(.*?)\]\s*var ordered:",
        candidates_block,
        re.DOTALL,
    )
    canonical_candidates = tuple(re.findall(
        r'"([^"]+)"', canonical_match.group(1) if canonical_match else ""
    ))
    if literal_candidates != (
        "city_work_sample",
        "hanbit_month_close",
        "urgent_paid_shift",
        "body_rest",
    ) or canonical_candidates != (
        "father_call",
        "hanbit_month_close",
        "city_work_sample",
        "daeun_checkin",
        "jaehyuk_reply",
        "sangchul_ledger",
        "urgent_paid_shift",
        "body_rest",
    ):
        fail(
            "live Week-24 candidate builder gained, lost, or reordered a "
            "candidate outside the controlled state mirror",
            errors,
        )

    prepare_match = re.search(
        r"static func prepare_demo_collision\(\).*?(?=\nstatic func |\Z)",
        source,
        re.DOTALL,
    )
    prepare_block = prepare_match.group(0) if prepare_match else ""
    build_at = prepare_block.find(
        "var candidates := _demo_collision_candidate_ids(state)"
    )
    validate_at = prepare_block.find(
        'if candidates.is_empty() or not candidates.has("father_call"):',
        build_at,
    )
    context_at = prepare_block.find("var context := {", validate_at)
    candidate_field_at = prepare_block.find(
        '"candidate_ids": candidates.duplicate(),', context_at
    )
    freeze_at = prepare_block.find(
        'state["demo_collision_context"] = context', candidate_field_at
    )
    state_at = prepare_block.find(
        "GameState.core_loop_v2_state = state", freeze_at
    )
    return_at = prepare_block.find(
        '"context": context.duplicate(true)', state_at
    )
    if not 0 <= build_at < validate_at < context_at < candidate_field_at \
            < freeze_at < state_at < return_at:
        fail(
            "live demo collision no longer builds, validates, and freezes the "
            "candidate ids consumed by First Bill",
            errors,
        )

    begin_match = re.search(
        r"func _core_loop_v2_begin_story_bundle\(.*?(?=\nfunc )",
        main_source,
        re.DOTALL,
    )
    begin_block = begin_match.group(0) if begin_match else ""
    demo_at = begin_block.find('if bundle_id == "demo_collision":')
    prepare_call_at = begin_block.find(
        "DEMO_CORE_LOOP_V2.prepare_demo_collision()", demo_at
    )
    roots_call_at = begin_block.find(
        "DEMO_CORE_LOOP_V2.resolved_event_roots(bundle_id)", prepare_call_at
    )
    story_call_at = begin_block.find("_go_story_mode(roots)", roots_call_at)
    if not 0 <= demo_at < prepare_call_at < roots_call_at < story_call_at:
        fail(
            "MainGame no longer freezes the demo-collision candidates before "
            "opening the Week-24 story roots",
            errors,
        )

    available_match = re.search(
        r"static func story_choice_available\(.*?(?=\nstatic func |\Z)",
        source,
        re.DOTALL,
    )
    available_block = available_match.group(0) if available_match else ""
    if not re.search(
        r'event_id != "v2_demo_first_bill".*?'
        r'_validated_demo_collision_context\(state\).*?'
        r'context\.get\("candidate_ids", \[\]\) is Array.*?'
        r'context\.get\("candidate_ids", \[\]\) as Array\)\.has\(\s*'
        r'normalized_obligation\)',
        available_block,
        re.DOTALL,
    ):
        fail(
            "live First Bill choice gate no longer exposes choices from the "
            "frozen Week-24 candidate ids",
            errors,
        )
    story_source = STORY_MODE_PATH.read_text(encoding="utf-8")
    visible_match = re.search(
        r"func _choice_visible\(ch: Dictionary\).*?(?=\nfunc )",
        story_source,
        re.DOTALL,
    )
    visible_block = visible_match.group(0) if visible_match else ""
    if not re.search(
        r'ch\.get\("v2_obligation_id", ""\).*?'
        r'DEMO_CORE_LOOP_V2\.is_active\(\).*?'
        r'DEMO_CORE_LOOP_V2\.story_choice_available\(.*?'
        r'return false.*?return true',
        visible_block,
        re.DOTALL,
    ):
        fail(
            "StoryMode no longer filters First Bill choices through the live "
            "candidate availability gate",
            errors,
        )


def run_survival_kernels(
    options: dict[str, Any],
    arc_events: list[Any],
    core_events: list[Any],
    errors: list[str],
) -> dict[str, SurvivalLedger]:
    """Execute all 18 branch-only survival kernels from the real starting state."""

    temptation = event_by_id(arc_events, "arc_temptation_01")
    clean_consequence = event_by_id(arc_events, "arc_temptation_clean")
    fallout = event_by_id(arc_events, "arc_temptation_fallout")
    father = event_by_id(core_events, "v2_father_health_signal")
    dirty_trace = event_by_id(core_events, "v2_dirty_trace_initial_call")
    dirty_recruiter = event_by_id(core_events, "v2_dirty_recruiter_week24")
    first_bill = event_by_id(core_events, "v2_demo_first_bill")

    clean_opening = choice_with_flag(temptation, "kept_clean_hands")
    clean_week_8 = choice_with_flag(clean_consequence, "stayed_clean")
    dirty_opening = choice_with_flag(temptation, "lent_account")
    dirty_return = choice_with_flag(fallout, "escaped_dirty_money")
    dirty_deeper = choice_with_flag(fallout, "fell_to_darkness")
    branch_plans = {
        "clean": {
            "week_4": clean_opening,
            "week_8": clean_week_8,
            "week_24_event": {},
        },
        "dirty_return": {
            "week_4": dirty_opening,
            "week_8": dirty_return,
            "week_24_event": dirty_trace,
        },
        "dirty_deeper": {
            "week_4": dirty_opening,
            "week_8": dirty_deeper,
            "week_24_event": dirty_recruiter,
        },
    }
    policy_plans = {
        "cautious": {
            "father_mental": -2,
            "first_bill": "body_rest",
            "callback_mental": {"dirty_return": -4, "dirty_deeper": -2},
        },
        "hard": {
            "father_mental": -5,
            "first_bill": "urgent_paid_shift",
            "callback_mental": {"dirty_return": -5, "dirty_deeper": -4},
        },
    }

    required_inputs = {
        "clean Week-4 choice": clean_opening,
        "clean Week-8 consequence": clean_week_8,
        "dirty Week-4 choice": dirty_opening,
        "dirty-return Week-8 choice": dirty_return,
        "dirty-deeper Week-8 choice": dirty_deeper,
        "Week-21 Father event": father,
        "Week-24 dirty-return callback": dirty_trace,
        "Week-24 dirty-deeper callback": dirty_recruiter,
        "Week-24 First Bill event": first_bill,
    }
    for label, payload in required_inputs.items():
        if not payload:
            fail(f"survival kernel lost {label}", errors)

    ledgers: dict[str, SurvivalLedger] = {}
    for routine_pair in KERNEL_ROUTINE_PAIRS:
        pair_name = "+".join(routine_pair)
        for branch_id in KERNEL_BRANCHES:
            branch_plan = branch_plans[branch_id]
            for policy_id in KERNEL_POLICIES:
                policy = policy_plans[policy_id]
                key = f"{pair_name}/{branch_id}/{policy_id}"
                ledger = SurvivalLedger(name=key)
                father_choice = choice_with_mental_delta(
                    father, int(policy["father_mental"])
                )
                bill_choice = choice_with_obligation(
                    first_bill, str(policy["first_bill"])
                )
                callback_choice: dict[str, Any] = {}
                callback_event = branch_plan["week_24_event"]
                if callback_event:
                    callback_delta = int(policy["callback_mental"][branch_id])
                    callback_choice = choice_with_mental_delta(
                        callback_event, callback_delta
                    )
                if not father_choice or not bill_choice or (
                    callback_event and not callback_choice
                ):
                    fail(f"survival kernel {key} lost a policy-owned choice", errors)

                for week in range(1, E_WEEKS + 1):
                    # The Father signal is a Week-21 pre-planning interruption.
                    if week == 21:
                        ledger.apply_effects(choice_effects(father_choice))
                    for routine_id in routine_pair:
                        ledger.apply_effects(weekly_effects(options, routine_id))
                        ledger.routine_units += 1
                    if week == 4:
                        ledger.apply_effects(
                            choice_effects(branch_plan["week_4"])
                        )
                    elif week == 8 and branch_plan["week_8"]:
                        ledger.apply_effects(
                            choice_effects(branch_plan["week_8"])
                        )
                    if week == 24:
                        if callback_choice:
                            ledger.apply_effects(choice_effects(callback_choice))
                        ledger.apply_effects(choice_effects(bill_choice))
                    if not ledger.death_week and (
                        ledger.health <= 0 or ledger.mental <= 0
                    ):
                        ledger.death_week = week
                    if week % 4 == 0:
                        ledger.apply_monthly_pressure(week)
                        if not ledger.death_week and (
                            ledger.health <= 0 or ledger.mental <= 0
                        ):
                            ledger.death_week = week

                ledgers[key] = ledger
                mental_path = tuple(
                    int(row["mental"]) for row in ledger.monthly_snapshots
                )
                health_path = tuple(
                    int(row["health"]) for row in ledger.monthly_snapshots
                )
                expected = EXPECTED_KERNEL_TRAJECTORIES.get(key, {})
                if mental_path != expected.get("mental"):
                    fail(
                        f"survival kernel {key} mental path drifted: "
                        f"{mental_path}",
                        errors,
                    )
                if health_path != expected.get("health"):
                    fail(
                        f"survival kernel {key} health path drifted: "
                        f"{health_path}",
                        errors,
                    )
                if ledger.routine_units != E_WEEKS * 2:
                    fail(
                        f"survival kernel {key} executed {ledger.routine_units} "
                        "routine units instead of 48",
                        errors,
                    )
                if len(ledger.monthly_snapshots) != 6:
                    fail(f"survival kernel {key} did not settle six months", errors)
                if ledger.death_week:
                    fail(
                        f"branch-only survival kernel {key} died in Week "
                        f"{ledger.death_week}",
                        errors,
                    )

    if set(ledgers) != set(EXPECTED_KERNEL_TRAJECTORIES):
        fail("the survival matrix must contain exactly 18 named kernels", errors)
    return ledgers


def _choice_index(event: dict[str, Any], choice: dict[str, Any]) -> int:
    choices = event.get("choices", []) if isinstance(event, dict) else []
    if not isinstance(choices, list):
        return -1
    return next(
        (
            index
            for index, raw_choice in enumerate(choices)
            if isinstance(raw_choice, dict) and raw_choice == choice
        ),
        -1,
    )


def _validate_visible_choice_surface(
    event_id: str,
    event: dict[str, Any],
    choice: dict[str, Any],
    errors: list[str],
) -> None:
    """Prove that a measured effect belongs to prose the player can reach."""

    if not str(event.get("description", "")).strip():
        fail(f"paired trace event {event_id} lost its visible description", errors)
    if not str(choice.get("text", "")).strip():
        fail(f"paired trace event {event_id} lost a visible choice", errors)
    if not str(choice.get("result_text", "")).strip():
        fail(f"paired trace event {event_id} lost visible result attribution", errors)


def _choice_zero_chain(
    root_id: str,
    events: list[Any],
    suppressed_followups: set[str],
    errors: list[str],
) -> tuple[list[dict[str, Any]], set[tuple[str, int]]]:
    """Resolve the deterministic choice-zero chain used by the E-check."""

    effects: list[dict[str, Any]] = []
    choices_seen: set[tuple[str, int]] = set()
    event_id = root_id
    visited: set[str] = set()
    while event_id:
        if event_id in visited:
            fail(f"paired schedule event chain loops at {event_id}", errors)
            break
        visited.add(event_id)
        event = event_by_id(events, event_id)
        raw_choices = event.get("choices", []) if event else []
        if not event or not isinstance(raw_choices, list) or not raw_choices \
                or not isinstance(raw_choices[0], dict):
            fail(f"paired schedule lost event {event_id} choice 0", errors)
            break
        choice = raw_choices[0]
        choices_seen.add((event_id, 0))
        raw_effects = choice.get("effects", {})
        if isinstance(raw_effects, dict) and raw_effects:
            effects.append(raw_effects.copy())
        followup = str(choice.get("follow_up_event", "")).strip()
        if not followup or followup in suppressed_followups:
            break
        event_id = followup
    return effects, choices_seen


def _prerequisite_met(
    predicate: dict[str, Any],
    state: dict[str, Any],
    routine_pair: tuple[str, str],
    stage_order: list[str],
) -> bool:
    kind = str(predicate.get("kind", "")).strip()
    if kind == "completed_bundle":
        return str(predicate.get("bundle_id", "")) in state["completed"]
    if kind == "routine_selected":
        return str(predicate.get("track", "")) in routine_pair
    if kind == "relationship_memory":
        key = (
            str(predicate.get("character", "")),
            str(predicate.get("memory", "")),
        )
        return key in state["memories"]
    if kind == "player_initiated":
        return str(predicate.get("character", "")) in state["player_initiated"]
    if kind in ("relationship_at_least", "relationship_stage_is"):
        character = str(predicate.get("character", ""))
        required = str(predicate.get("stage", ""))
        current = str(state["stages"].get(character, "unmet"))
        if kind == "relationship_stage_is":
            return required in stage_order and current == required
        if current == "closed" or required not in stage_order \
                or current not in stage_order:
            return False
        return stage_order.index(current) >= stage_order.index(required)
    if kind == "application_status":
        application_id = str(predicate.get("application_id", ""))
        expected = str(predicate.get("status", ""))
        return str(state["applications"].get(application_id, "")) == expected
    if kind == "application_status_not_in":
        application_id = str(predicate.get("application_id", ""))
        statuses = predicate.get("statuses", [])
        return isinstance(statuses, list) and str(
            state["applications"].get(application_id, "")
        ) not in {str(value) for value in statuses}
    if kind == "current_job_id":
        return str(predicate.get("job_id", "")) == str(state.get("job_id", ""))
    return False


def _bundle_prerequisites_met(
    bundle: dict[str, Any],
    state: dict[str, Any],
    routine_pair: tuple[str, str],
    stage_order: list[str],
) -> bool:
    raw = bundle.get("prerequisites")
    if raw is None:
        return True
    if not isinstance(raw, dict) or not ("all" in raw or "any" in raw):
        return False
    required = raw.get("all", [])
    alternatives = raw.get("any", [])
    if not isinstance(required, list) or not all(
        isinstance(item, dict)
        and _prerequisite_met(item, state, routine_pair, stage_order)
        for item in required
    ):
        return False
    if "any" in raw:
        if not isinstance(alternatives, list) or not alternatives:
            return False
        return any(
            isinstance(item, dict)
            and _prerequisite_met(item, state, routine_pair, stage_order)
            for item in alternatives
        )
    return True


def _apply_choice_outcomes(
    bundle: dict[str, Any],
    choices_seen: set[tuple[str, int]],
    state: dict[str, Any],
    errors: list[str],
) -> None:
    raw_outcomes = bundle.get("relationship_outcomes", [])
    if not isinstance(raw_outcomes, list):
        fail("paired schedule found malformed relationship outcomes", errors)
        return
    matched = 0
    for raw_outcome in raw_outcomes:
        if not isinstance(raw_outcome, dict):
            continue
        event_id = str(raw_outcome.get("event_id", ""))
        raw_choices = raw_outcome.get("choices", [])
        choice_ids = (
            {int(value) for value in raw_choices}
            if isinstance(raw_choices, list) else set()
        )
        if not any(
            seen_event == event_id and seen_choice in choice_ids
            for seen_event, seen_choice in choices_seen
        ):
            continue
        matched += 1
        character = str(raw_outcome.get("character", ""))
        expected_from = str(raw_outcome.get("from", "unmet"))
        current = str(state["stages"].get(character, "unmet"))
        if current != expected_from:
            fail(
                f"paired schedule relationship {character} expected "
                f"{expected_from}, found {current}",
                errors,
            )
        destination = str(raw_outcome.get("to", current))
        state["stages"][character] = destination
        memory = str(raw_outcome.get("memory", "")).strip()
        if memory:
            state["memories"].add((character, memory))
        if str(raw_outcome.get("initiative", "")) == "player":
            state["player_initiated"].add(character)
    if raw_outcomes and matched != 1:
        fail(
            f"paired schedule expected one choice-0 relationship outcome, "
            f"matched {matched}",
            errors,
        )


def _resolve_paired_schedule(
    contract: dict[str, Any],
    events: list[Any],
    routine_pair: tuple[str, str],
    errors: list[str],
) -> dict[int, list[dict[str, Any]]]:
    """Validate and resolve all 22 selected slots plus both locked bosses."""

    raw_bundles = contract.get("scene_bundles", {})
    raw_months = contract.get("months", [])
    relationship = contract.get("relationship", {})
    if not isinstance(raw_bundles, dict) or not isinstance(raw_months, list) \
            or not isinstance(relationship, dict):
        fail("paired schedule lost its bundle, month, or relationship catalog", errors)
        return {}
    stage_order = [str(value) for value in relationship.get("stages", [])]
    if not stage_order or stage_order[0] != "unmet":
        fail("paired schedule lost the relationship stage order", errors)
    options = contract.get("routine", {}).get("options", {}) \
        if isinstance(contract.get("routine", {}), dict) else {}
    if len(set(routine_pair)) != 2 or not isinstance(options, dict) \
            or any(routine_id not in options for routine_id in routine_pair):
        fail(f"paired schedule has illegal routines {routine_pair}", errors)

    schedule = dict(PAIRED_FULL_SCHEDULE)
    if len(schedule) != E_WEEKS or tuple(sorted(schedule)) != tuple(
        range(1, E_WEEKS + 1)
    ):
        fail("paired schedule must name exactly Weeks 1-24", errors)
    if len(set(schedule.values())) != E_WEEKS:
        fail("paired schedule must not reuse a bundle across months", errors)
    selected_bundle_ids = set(schedule.values())
    raw_declines = contract.get("decline_outcomes", {})
    effectful_decline_producers: set[str] = set()
    if isinstance(raw_declines, dict):
        for raw_month in raw_months:
            if not isinstance(raw_month, dict):
                continue
            for raw_bundle_id in raw_month.get("offers", []):
                bundle_id = str(raw_bundle_id)
                raw_bundle = raw_bundles.get(bundle_id, {})
                bundle = raw_bundle if isinstance(raw_bundle, dict) else {}
                outcome_id = str(bundle.get("decline_consequence", ""))
                raw_outcome = raw_declines.get(outcome_id, {})
                outcome = raw_outcome if isinstance(raw_outcome, dict) else {}
                effects = outcome.get("effects", {})
                if isinstance(effects, dict) and effects:
                    effectful_decline_producers.add(bundle_id)
    missing_effectful_declines = sorted(
        effectful_decline_producers - selected_bundle_ids
    )
    if missing_effectful_declines:
        fail(
            "paired schedule leaves numeric decline effects pending from "
            + ",".join(missing_effectful_declines),
            errors,
        )
    effects_by_week: dict[int, list[dict[str, Any]]] = {
        week: [] for week in range(1, E_WEEKS + 1)
    }
    state: dict[str, Any] = {
        "completed": set(),
        "stages": {},
        "memories": set(),
        "player_initiated": set(),
        "applications": {},
        "job_id": "",
    }
    locked_slots = 0
    selected_slots = 0
    for month_number in range(1, 7):
        month = next(
            (
                raw_month for raw_month in raw_months
                if isinstance(raw_month, dict)
                and int(raw_month.get("month", 0)) == month_number
            ),
            {},
        )
        week_range = month.get("weeks", []) if isinstance(month, dict) else []
        expected_first = (month_number - 1) * 4 + 1
        expected_last = expected_first + 3
        if week_range != [expected_first, expected_last]:
            fail(f"paired Month {month_number} lost its four-week range", errors)
        offers = month.get("offers", []) if isinstance(month, dict) else []
        raw_locks = month.get("locked", []) if isinstance(month, dict) else []
        if not isinstance(offers, list) or not isinstance(raw_locks, list):
            fail(f"paired Month {month_number} has malformed offers/locks", errors)
            offers, raw_locks = [], []
        contract_locks = {
            int(lock.get("week", 0)): str(lock.get("bundle", ""))
            for lock in raw_locks if isinstance(lock, dict)
        }
        expected_locks = {
            week: bundle_id for week, bundle_id in PAIRED_LOCKED_SLOTS.items()
            if expected_first <= week <= expected_last
        }
        if contract_locks != expected_locks:
            fail(
                f"paired Month {month_number} locked slots drifted: "
                f"{contract_locks}",
                errors,
            )
        month_bundle_ids = [schedule.get(week, "") for week in range(
            expected_first, expected_last + 1
        )]
        if len(set(month_bundle_ids)) != 4 or any(not value for value in month_bundle_ids):
            fail(f"paired Month {month_number} must contain four unique slots", errors)

        # Production availability is evaluated when the month is committed,
        # before any of its four scheduled bundles has completed.
        for week in range(expected_first, expected_last + 1):
            bundle_id = schedule.get(week, "")
            raw_bundle = raw_bundles.get(bundle_id, {})
            bundle = raw_bundle if isinstance(raw_bundle, dict) else {}
            if not bundle:
                fail(f"paired Week {week} lost bundle {bundle_id}", errors)
                continue
            if bundle.get("consumes_slot") is not True:
                fail(f"paired Week {week} bundle {bundle_id} lost slot ownership", errors)
            is_locked = week in contract_locks
            if is_locked:
                locked_slots += 1
                if contract_locks.get(week) != bundle_id:
                    fail(f"paired Week {week} changed its locked bundle", errors)
            else:
                selected_slots += 1
                if bundle_id not in offers:
                    fail(
                        f"paired Week {week} bundle {bundle_id} is not a Month "
                        f"{month_number} offer",
                        errors,
                    )
            allowed_weeks = bundle.get("allowed_weeks", [])
            if not isinstance(allowed_weeks, list) or week not in allowed_weeks:
                fail(f"paired bundle {bundle_id} is illegal in Week {week}", errors)
            if not _bundle_prerequisites_met(
                bundle, state, routine_pair, stage_order
            ):
                fail(
                    f"paired bundle {bundle_id} is unavailable when Month "
                    f"{month_number} is committed",
                    errors,
                )

        raw_groups = contract.get("exclusive_groups", {})
        if isinstance(raw_groups, dict):
            for group_id, raw_group in raw_groups.items():
                if not isinstance(raw_group, dict):
                    continue
                members = {str(value) for value in raw_group.get("members", [])}
                chosen = sum(bundle_id in members for bundle_id in month_bundle_ids)
                if chosen > int(raw_group.get("maximum_selected", 1)):
                    fail(
                        f"paired Month {month_number} exceeds exclusive group "
                        f"{group_id}",
                        errors,
                    )
        active_characters = {
            character for character, stage in state["stages"].items()
            if stage not in ("", "unmet", "closed")
        }
        for bundle_id in month_bundle_ids:
            raw_bundle = raw_bundles.get(bundle_id, {})
            if isinstance(raw_bundle, dict):
                active_characters.update(
                    str(value) for value in raw_bundle.get("characters", [])
                    if str(value).strip()
                )
        global_cap = int(relationship.get("maximum_active_named_threads", 0))
        month_cap = int(month.get("active_named_characters_max", 0))
        caps = [value for value in (global_cap, month_cap) if value > 0]
        active_cap = min(caps) if caps else 0
        if active_cap and len(active_characters) > active_cap:
            fail(
                f"paired Month {month_number} has {len(active_characters)} "
                f"named threads above cap {active_cap}",
                errors,
            )

        for week in range(expected_first, expected_last + 1):
            bundle_id = schedule.get(week, "")
            raw_bundle = raw_bundles.get(bundle_id, {})
            bundle = raw_bundle if isinstance(raw_bundle, dict) else {}
            if not bundle:
                continue
            choices_seen: set[tuple[str, int]] = set()
            if week not in PAIRED_LOCKED_SLOTS:
                config = bundle.get("action_config", {})
                config = config if isinstance(config, dict) else {}
                execution = str(config.get("execution", ""))
                raw_effects = config.get("effects", {})
                action_effects = (
                    raw_effects.copy() if isinstance(raw_effects, dict) else {}
                )
                if not execution and str(bundle.get("action_id", "")) == "rest":
                    # The two early legacy recovery cards use MainGame's
                    # explicit fallback rather than an action_config payload.
                    execution = "rest"
                    action_effects = {"mental": 10, "health": 3}
                if execution == "rest" and "recovery" in routine_pair:
                    diminished = config.get("recovery_routine_effects", {})
                    if isinstance(diminished, dict) and diminished:
                        action_effects = diminished.copy()
                    elif config and action_effects:
                        fail(
                            f"paired rest bundle {bundle_id} lost diminished "
                            "recovery effects",
                            errors,
                        )
                if action_effects:
                    effects_by_week[week].append(action_effects)
                roots = bundle.get("existing_roots", [])
                if roots is not None and not isinstance(roots, list):
                    fail(f"paired bundle {bundle_id} has malformed roots", errors)
                    roots = []
                suppressed = {
                    str(value) for value in bundle.get(
                        "suppress_follow_up_events", []
                    )
                }
                for root_id in roots or []:
                    chain_effects, chain_choices = _choice_zero_chain(
                        str(root_id), events, suppressed, errors
                    )
                    effects_by_week[week].extend(chain_effects)
                    choices_seen.update(chain_choices)
            _apply_choice_outcomes(bundle, choices_seen, state, errors)
            if str(bundle.get("action_id", "")) == "apply":
                config = bundle.get("action_config", {})
                config = config if isinstance(config, dict) else {}
                application_id = str(config.get("application_id", ""))
                if bundle_id == "m1_mirae_application" and not application_id:
                    application_id = "mirae_industrial_tech"
                if not application_id:
                    fail(f"paired application {bundle_id} lost its id", errors)
                else:
                    state["applications"][application_id] = str(
                        config.get("status", "submitted")
                    )
            state["completed"].add(bundle_id)

    # The selected Week-17 application makes the non-slot city response the
    # only eligible application prelude in Week 23. Production applies its
    # choice before the scheduled Hyunsu story, so prepend rather than append
    # the effect to that week's foreground sequence.
    future_contracts = contract.get("future_application_contracts", {})
    future_contracts = (
        future_contracts if isinstance(future_contracts, dict) else {}
    )
    city_contract = future_contracts.get("m6_city_service_response", {})
    expected_city_contract = {
        "producer_bundle": "m5_city_service_application",
        "application_id": "city_facility_ops_2026h1",
        "from": "submitted",
        "owner_month": 6,
        "allowed_weeks": [23],
        "activation_cap_week": 24,
        "runtime_surface": "inbound_message",
        "result_event": "v2_city_service_work_sample_message",
        "to": "submitted",
    }
    if not isinstance(city_contract, dict) or any(
        city_contract.get(field) != value
        for field, value in expected_city_contract.items()
    ):
        fail(
            f"paired Week-23 city application contract drifted: "
            f"{city_contract}",
            errors,
        )
    producer = raw_bundles.get("m5_city_service_application", {})
    producer = producer if isinstance(producer, dict) else {}
    producer_config = producer.get("action_config", {})
    producer_config = (
        producer_config if isinstance(producer_config, dict) else {}
    )
    if schedule.get(17) != "m5_city_service_application" or any((
        producer.get("action_id") != "apply",
        producer_config.get("execution") != "application",
        producer_config.get("application_id")
        != "city_facility_ops_2026h1",
        producer_config.get("status") != "submitted",
        state["applications"].get("city_facility_ops_2026h1")
        != "submitted",
    )):
        fail(
            "paired route no longer submits the city-service application "
            "in Week 17",
            errors,
        )
    city_response = raw_bundles.get("m6_city_service_response", {})
    city_response = city_response if isinstance(city_response, dict) else {}
    expected_city_prerequisites = {
        "all": [{
            "kind": "application_status",
            "application_id": "city_facility_ops_2026h1",
            "status": "submitted",
        }],
    }
    month_six = next(
        (
            raw_month for raw_month in raw_months
            if isinstance(raw_month, dict)
            and int(raw_month.get("month", 0)) == 6
        ),
        {},
    )
    conditional_consequences = month_six.get(
        "conditional_consequences", []
    ) if isinstance(month_six, dict) else []
    if (
        schedule.get(23) != "hyunsu_exam_eve"
        or city_response.get("kind") != "consequence"
        or city_response.get("allowed_weeks") != [23]
        or city_response.get("existing_roots")
        != ["v2_city_service_work_sample_message"]
        or city_response.get("phone_surface") != "inbound_message"
        or city_response.get("prerequisites") != expected_city_prerequisites
        or city_response.get("application_outcomes", []) != []
        or city_response.get("consumes_slot") is not False
        or not isinstance(conditional_consequences, list)
        or "m6_city_service_response" not in conditional_consequences
        or not _bundle_prerequisites_met(
            city_response, state, routine_pair, stage_order
        )
    ):
        fail(
            "paired route lost the eligible Week-23 city-service prelude",
            errors,
        )
    city_effects, city_choices = _choice_zero_chain(
        "v2_city_service_work_sample_message", events, set(), errors
    )
    city_event = event_by_id(events, "v2_city_service_work_sample_message")
    city_event_choices = city_event.get("choices", []) \
        if isinstance(city_event, dict) else []
    city_choice = city_event_choices[0] \
        if isinstance(city_event_choices, list) and city_event_choices \
        and isinstance(city_event_choices[0], dict) else {}
    if (
        city_effects != [{"mental": -1}]
        or city_choices != {("v2_city_service_work_sample_message", 0)}
        or city_choice.get("flags", []) != []
        or str(city_choice.get("follow_up_event", "")).strip()
    ):
        fail(
            "Week-23 city-service prelude choice-0 drifted from mental -1",
            errors,
        )
    else:
        effects_by_week[23] = city_effects + effects_by_week[23]

    # Mirror only the live predicates needed by this controlled schedule. The
    # source guard above fixes the candidate algorithm; these state facts prove
    # the representative route resolves to exactly four visible obligations.
    completed = state["completed"]
    memories = state["memories"]
    hanbit_provenance = (
        state.get("job_id", "") == "job_03"
        and state["applications"].get("hanbit_ops_2026q1") == "resolved"
        and "m5_hanbit_offer_message" in completed
    )
    person_obligation = ""
    if (
        "daeun_shared_dream" in completed
        and ("daeun", "daeun_same_tuesday_promised") not in memories
        and ("daeun", "daeun_late_meal_promised") in memories
    ):
        person_obligation = "daeun_checkin"
    elif (
        "jaehyuk_plain_reunion_echo" in completed
        and (
            ("jaehyuk", "jaehyuk_reunion_warm") in memories
            or ("jaehyuk", "jaehyuk_reunion_guarded") in memories
        )
    ):
        person_obligation = "jaehyuk_reply"
    elif (
        "sangchul_second_coffee" in completed
        and (
            ("sangchul", "sangchul_own_pace_stated") in memories
            or ("sangchul", "sangchul_numbers_first_recorded") in memories
        )
    ):
        person_obligation = "sangchul_ledger"
    candidate_priority = ["father_call"]
    city_prelude_presented = (
        state["applications"].get("city_facility_ops_2026h1") == "submitted"
        and city_effects == [{"mental": -1}]
        and city_choices == {("v2_city_service_work_sample_message", 0)}
    )
    if city_prelude_presented:
        candidate_priority.append("city_work_sample")
    if hanbit_provenance:
        candidate_priority.append("hanbit_month_close")
    if person_obligation:
        candidate_priority.append(person_obligation)
    if not str(state.get("job_id", "")):
        candidate_priority.append("urgent_paid_shift")
    candidate_priority.append("body_rest")
    selected_candidates: list[str] = []
    for candidate_id in candidate_priority:
        if candidate_id not in selected_candidates \
                and len(selected_candidates) < 4:
            selected_candidates.append(candidate_id)
    canonical_candidates = (
        "father_call", "hanbit_month_close", "city_work_sample",
        "daeun_checkin", "jaehyuk_reply", "sangchul_ledger",
        "urgent_paid_shift", "body_rest",
    )
    controlled_candidates = tuple(
        candidate_id for candidate_id in canonical_candidates
        if candidate_id in selected_candidates
    )
    if (
        controlled_candidates != EXPECTED_PAIRED_W24_CANDIDATES
        or hanbit_provenance
        or person_obligation
        or str(state.get("job_id", ""))
    ):
        fail(
            "controlled Week-24 state no longer exposes exactly father, city "
            f"sample, urgent shift, and rest: {controlled_candidates}",
            errors,
        )

    if selected_slots != PAIRED_PLAYER_SELECTED_SLOTS or locked_slots != 2:
        fail(
            f"paired schedule resolved {selected_slots} selected and "
            f"{locked_slots} locked slots instead of 22+2",
            errors,
        )
    if schedule.get(7) != "cafe_world_glimpse" or event_by_id(
        events, "cafe_00"
    ) == {}:
        fail("paired schedule must expose cafe_world_glimpse/cafe_00 in Week 7", errors)
    return effects_by_week


def _temptation_cost_tokens(
    event_id: str, choice: dict[str, Any]
) -> tuple[list[str], list[str]]:
    """Separate player-readable stat costs from the hidden moral tint key."""

    visible: list[str] = []
    hidden: list[str] = []
    effects = choice_effects(choice)
    for stat in sorted(effects):
        value = int(effects.get(stat, 0))
        if stat == "tint" and value != 0:
            hidden.append(f"{event_id}:tint")
        elif value < 0:
            visible.append(f"{event_id}:{stat}")
    return visible, hidden


def _delta_range(rows: list[dict[str, int]], stat: str) -> str:
    values = [int(row[stat]) for row in rows]
    low = min(values)
    high = max(values)
    return str(low) if low == high else f"{low}..{high}"


def run_paired_temptation_traces(
    contract: dict[str, Any],
    options: dict[str, Any],
    arc_events: list[Any],
    core_events: list[Any],
    all_events: list[Any],
    prologue_policies: list[dict[str, Any]],
    errors: list[str],
) -> tuple[list[str], str]:
    """Measure W4→W24 branch deltas while every other choice stays equal.

    This comparison ledger does not compare balances from different weeks or
    mix a hired route with an unemployed one.  Each control
    fixes one actual fresh-prologue policy, the complete 24-slot schedule,
    routine pair, Father policy and First Bill action; only the authored
    temptation branch may differ inside a comparison.
    """

    validate_runtime_temptation_callbacks(errors)
    validate_runtime_city_service_prelude(errors)
    temptation = event_by_id(arc_events, "arc_temptation_01")
    clean_consequence = event_by_id(arc_events, "arc_temptation_clean")
    fallout = event_by_id(arc_events, "arc_temptation_fallout")
    father = event_by_id(core_events, "v2_father_health_signal")
    dirty_trace = event_by_id(core_events, "v2_dirty_trace_initial_call")
    dirty_recruiter = event_by_id(core_events, "v2_dirty_recruiter_week24")
    first_bill = event_by_id(core_events, "v2_demo_first_bill")

    expected_first_bill_controls = {
        "body_rest": {
            "choice_index": 7,
            "effects": {"health": 2, "mental": 1},
        },
        "urgent_paid_shift": {
            "choice_index": 6,
            "effects": {
                "money": 280_000,
                "health": -5,
                "mental": -4,
            },
        },
    }
    first_bill_choices = first_bill.get("choices", []) \
        if isinstance(first_bill, dict) else []
    for obligation_id, expected in expected_first_bill_controls.items():
        matches = [
            choice for choice in first_bill_choices
            if isinstance(choice, dict)
            and choice.get("v2_obligation_id") == obligation_id
        ] if isinstance(first_bill_choices, list) else []
        matched_choice = matches[0] if matches else {}
        if (
            len(matches) != 1
            or choice_effects(matched_choice) != expected["effects"]
            or _choice_index(first_bill, matched_choice)
            != expected["choice_index"]
        ):
            fail(
                f"First Bill {obligation_id} id/effects drifted: {matches}",
                errors,
            )

    clean_opening = choice_with_flag(temptation, "kept_clean_hands")
    dirty_opening = choice_with_flag(temptation, "lent_account")
    clean_week_8 = choice_with_flag(clean_consequence, "stayed_clean")
    dirty_return = choice_with_flag(fallout, "escaped_dirty_money")
    dirty_deeper = choice_with_flag(fallout, "fell_to_darkness")
    branch_plans: dict[str, dict[str, Any]] = {
        "clean": {
            "week_4_event_id": "arc_temptation_01",
            "week_4_event": temptation,
            "week_4_choice": clean_opening,
            "week_8_event_id": "arc_temptation_clean",
            "week_8_event": clean_consequence,
            "week_8_choice": clean_week_8,
            "week_24_event_id": "",
            "week_24_event": {},
        },
        "dirty_return": {
            "week_4_event_id": "arc_temptation_01",
            "week_4_event": temptation,
            "week_4_choice": dirty_opening,
            "week_8_event_id": "arc_temptation_fallout",
            "week_8_event": fallout,
            "week_8_choice": dirty_return,
            "week_24_event_id": "v2_dirty_trace_initial_call",
            "week_24_event": dirty_trace,
        },
        "dirty_deeper": {
            "week_4_event_id": "arc_temptation_01",
            "week_4_event": temptation,
            "week_4_choice": dirty_opening,
            "week_8_event_id": "arc_temptation_fallout",
            "week_8_event": fallout,
            "week_8_choice": dirty_deeper,
            "week_24_event_id": "v2_dirty_recruiter_week24",
            "week_24_event": dirty_recruiter,
        },
    }
    w24_branch_evidence: dict[str, dict[str, Any]] = {
        "clean": {
            "foreground_ids": (),
            "trace_copy_id": "",
            "receipt_id": "",
            "synthetic": "none",
        },
        "dirty_return": {
            "foreground_ids": ("v2_dirty_trace_initial_call",),
            "trace_copy_id": "v2_dirty_trace_initial_call",
            "receipt_id": "callback_escaped_dirty_trace",
            "synthetic": "false",
        },
        "dirty_deeper": {
            "foreground_ids": ("v2_dirty_recruiter_week24",),
            "trace_copy_id": "v2_dirty_recruiter_week24",
            "receipt_id": "fell_to_darkness",
            "synthetic": "true",
        },
    }
    policy_plans = {
        "cautious": {
            "father_mental": -2,
            "first_bill": "body_rest",
            "callback_mental": {"dirty_return": -4, "dirty_deeper": -2},
        },
        "hard": {
            "father_mental": -5,
            "first_bill": "urgent_paid_shift",
            "callback_mental": {"dirty_return": -5, "dirty_deeper": -4},
        },
    }

    # Prove that the three measured weeks are routed by the current contract,
    # not merely present somewhere in the event catalog.
    bundles = contract.get("scene_bundles", {})
    bundles = bundles if isinstance(bundles, dict) else {}
    first_boss = bundles.get("first_temptation_boss", {})
    consequence = bundles.get("temptation_consequence", {})
    collision = bundles.get("demo_collision", {})
    if not isinstance(first_boss, dict) or (
        first_boss.get("existing_roots") != ["arc_temptation_01"]
        or first_boss.get("allowed_weeks") != [4]
        or int(first_boss.get("locked_week", 0)) != 4
    ):
        fail("paired trace lost the fixed Week-4 temptation route", errors)
    if not isinstance(consequence, dict) or (
        consequence.get("existing_roots")
        != ["arc_temptation_clean", "arc_temptation_fallout"]
        or consequence.get("allowed_weeks") != [8]
    ):
        fail("paired trace lost the branch-owned Week-8 consequence", errors)
    if not isinstance(collision, dict) or (
        collision.get("existing_roots") != ["v2_demo_first_bill_opening"]
        or collision.get("allowed_weeks") != [24]
        or int(collision.get("locked_week", 0)) != 24
    ):
        fail("paired trace lost the fixed Week-24 First Bill route", errors)
    deferred = contract.get("deferred_callback_contracts", {})
    deferred = deferred if isinstance(deferred, dict) else {}
    return_callback = deferred.get("callback_escaped_dirty_trace", {})
    if not isinstance(return_callback, dict) or (
        return_callback.get("producer_event") != "arc_temptation_fallout"
        or return_callback.get("producer_choices") != [0]
        or int(return_callback.get("due_week", 0)) != 24
        or return_callback.get("final_owner_bundle") != "demo_collision"
    ):
        fail("paired trace lost the Week-24 dirty-return callback contract", errors)
    if (
        dirty_return.get("deferred_follow_up")
        != "callback_escaped_dirty_trace"
        or int(dirty_return.get("deferred_delay", 0)) != 16
    ):
        fail("dirty-return choice no longer schedules its sixteen-week callback", errors)
    finale = collision.get("first_bill_finale", {}) \
        if isinstance(collision, dict) else {}
    trace_copy = finale.get("trace_copy", {}) \
        if isinstance(finale, dict) else {}
    root_contract = finale.get("root_contract", {}) \
        if isinstance(finale, dict) else {}
    obligation_outcomes = collision.get("obligation_outcomes", []) \
        if isinstance(collision, dict) else []
    if not isinstance(root_contract, dict) \
            or root_contract.get("receipt_owner") != "demo_collision":
        fail("First Bill receipt owner drifted from demo_collision", errors)
    for obligation_id, expected in expected_first_bill_controls.items():
        outcome_matches = [
            outcome for outcome in obligation_outcomes
            if isinstance(outcome, dict)
            and outcome.get("event_id") == "v2_demo_first_bill"
            and outcome.get("choices") == [expected["choice_index"]]
            and outcome.get("selected_obligation_id") == obligation_id
        ] if isinstance(obligation_outcomes, list) else []
        if len(outcome_matches) != 1:
            fail(
                f"First Bill {obligation_id} lost its exact demo_collision "
                "receipt mapping",
                errors,
            )
    expected_trace_ids = {
        "v2_dirty_trace_initial_call",
        "v2_dirty_recruiter_week24",
    }
    if not isinstance(trace_copy, dict) or set(trace_copy) != expected_trace_ids:
        fail(
            f"Week-24 exact-trace ids drifted: "
            f"{sorted(trace_copy) if isinstance(trace_copy, dict) else trace_copy}",
            errors,
        )
    for event_id, event in (
        ("v2_dirty_trace_initial_call", dirty_trace),
        ("v2_dirty_recruiter_week24", dirty_recruiter),
    ):
        copy = trace_copy.get(event_id, {}) \
            if isinstance(trace_copy, dict) else {}
        choice_copy = copy.get("choices", {}) if isinstance(copy, dict) else {}
        claimed_copy = copy.get("claimed", {}) if isinstance(copy, dict) else {}
        event_choices = event.get("choices", []) if isinstance(event, dict) else []
        if (
            not isinstance(copy, dict)
            or not isinstance(claimed_copy, dict)
            or not str(claimed_copy.get("ko", "")).strip()
            or not isinstance(choice_copy, dict)
            or not isinstance(event_choices, list)
            or set(choice_copy) != {
                str(index) for index in range(len(event_choices))
            }
        ):
            fail(
                f"Week-24 event {event_id} lost its First Bill attribution",
                errors,
            )
    for branch_id, evidence in w24_branch_evidence.items():
        foreground_ids = tuple(evidence["foreground_ids"])
        plan_event_id = str(branch_plans[branch_id]["week_24_event_id"])
        if foreground_ids != ((plan_event_id,) if plan_event_id else ()) \
                or str(evidence["trace_copy_id"]) != plan_event_id:
            fail(
                f"Week-24 {branch_id} foreground/trace evidence drifted",
                errors,
            )
    surface = contract.get("surface", {})
    if not isinstance(surface, dict) or surface.get("visible_moral_values") is not False:
        fail("paired trace can no longer classify tint as hidden-only", errors)

    opening = event_by_id(all_events, "v2_demo_first_bill_opening")
    ledger_close = event_by_id(all_events, "v2_demo_first_bill_ledger")
    exam_echo = event_by_id(all_events, "v2_hyunsu_exam_morning_echo")
    opening_choices = opening.get("choices", []) if opening else []
    if not isinstance(opening_choices, list) or not opening_choices \
            or not isinstance(opening_choices[0], dict) \
            or choice_effects(opening_choices[0]) \
            or opening_choices[0].get("follow_up_event") != "v2_demo_first_bill":
        fail("Week-24 First Bill opening is no longer an effectless handoff", errors)
    for event_id, event in (
        ("v2_demo_first_bill_ledger", ledger_close),
        ("v2_hyunsu_exam_morning_echo", exam_echo),
    ):
        choices = event.get("choices", []) if event else []
        if not isinstance(choices, list) or not choices \
                or not isinstance(choices[0], dict) \
                or choice_effects(choices[0]):
            fail(f"Week-24 post-decision event {event_id} gained effects", errors)

    for branch_id, plan in branch_plans.items():
        for week in (4, 8):
            event_id = str(plan[f"week_{week}_event_id"])
            event = plan[f"week_{week}_event"]
            choice = plan[f"week_{week}_choice"]
            if not event or not choice:
                fail(f"paired trace lost {branch_id} Week-{week}", errors)
                continue
            _validate_visible_choice_surface(event_id, event, choice, errors)
        callback_event = plan["week_24_event"]
        if branch_id != "clean" and not callback_event:
            fail(f"paired trace lost {branch_id} Week-24 callback", errors)

    all_ledgers: dict[str, SurvivalLedger] = {}
    callback_choices: dict[str, dict[str, dict[str, Any]]] = {}
    resolved_policies: dict[str, dict[str, Any]] = {}
    for policy_id in KERNEL_POLICIES:
        policy = policy_plans[policy_id]
        father_choice = choice_with_mental_delta(
            father, int(policy["father_mental"])
        )
        bill_choice = choice_with_obligation(
            first_bill, str(policy["first_bill"])
        )
        if not father_choice or not bill_choice:
            fail(
                f"paired trace {policy_id} lost its common policy choice",
                errors,
            )
        callback_choices[policy_id] = {}
        for branch_id, plan in branch_plans.items():
            callback_choice: dict[str, Any] = {}
            callback_event = plan["week_24_event"]
            if callback_event:
                callback_choice = choice_with_mental_delta(
                    callback_event,
                    int(policy["callback_mental"][branch_id]),
                )
                if not callback_choice:
                    fail(
                        f"paired trace {branch_id}/{policy_id} lost its "
                        "Week-24 callback choice",
                        errors,
                    )
                else:
                    _validate_visible_choice_surface(
                        str(plan["week_24_event_id"]),
                        callback_event,
                        callback_choice,
                        errors,
                    )
            callback_choices[policy_id][branch_id] = callback_choice
        resolved_policies[policy_id] = {
            "father": father_choice,
            "first_bill": bill_choice,
            "callbacks": callback_choices[policy_id],
        }
        obligation_id = str(bill_choice.get("v2_obligation_id", "")) \
            if isinstance(bill_choice, dict) else ""
        if obligation_id not in EXPECTED_PAIRED_W24_CANDIDATES:
            fail(
                f"paired First Bill policy {policy_id} selects hidden "
                f"obligation {obligation_id or 'missing'}",
                errors,
            )

    # These public axes are intentionally omitted from the printed branch
    # vectors only while every selected branch-owned choice leaves them at
    # zero. Any authored W4/W8/W24 change must expand the ledger and verdict.
    for branch_id, plan in branch_plans.items():
        branch_choices: list[tuple[int, dict[str, Any]]] = [
            (4, plan["week_4_choice"]),
            (8, plan["week_8_choice"]),
        ]
        for policy_id in KERNEL_POLICIES:
            callback_choice = callback_choices.get(
                policy_id, {}
            ).get(branch_id, {})
            if callback_choice:
                branch_choices.append((24, callback_choice))
        for week, branch_choice in branch_choices:
            effects = choice_effects(branch_choice)
            nonzero_omissions = {
                stat: int(effects.get(stat, 0))
                for stat in OMITTED_PUBLIC_DELTA_STATS
                if int(effects.get(stat, 0)) != 0
            }
            if nonzero_omissions:
                fail(
                    f"paired {branch_id} Week-{week} gained omitted public "
                    f"deltas {nonzero_omissions}",
                    errors,
                )

    def simulate_matrix(matrix_errors: list[str]) -> dict[str, SurvivalLedger]:
        matrix: dict[str, SurvivalLedger] = {}
        for routine_pair in KERNEL_ROUTINE_PAIRS:
            selected_effects = _resolve_paired_schedule(
                contract, all_events, routine_pair, matrix_errors
            )
            pair_name = "+".join(routine_pair)
            for prologue in prologue_policies:
                prologue_id = str(prologue.get("id", ""))
                for policy_id in KERNEL_POLICIES:
                    resolved = resolved_policies.get(policy_id, {})
                    father_choice = resolved.get("father", {})
                    bill_choice = resolved.get("first_bill", {})
                    resolved_callbacks = resolved.get("callbacks", {})
                    for branch_id, plan in branch_plans.items():
                        callback_choice = resolved_callbacks.get(branch_id, {}) \
                            if isinstance(resolved_callbacks, dict) else {}
                        key = (
                            f"{prologue_id}/{pair_name}/{policy_id}/{branch_id}"
                        )
                        ledger = SurvivalLedger(
                            name=key,
                            cash=int(prologue.get("cash", STARTING_CASH)),
                            health=int(prologue.get("health", STARTING_HEALTH)),
                            mental=int(prologue.get("mental", STARTING_MENTAL)),
                            intelligence=int(prologue.get(
                                "intelligence", STARTING_INTELLIGENCE
                            )),
                            social_skill=int(prologue.get(
                                "social_skill", STARTING_SOCIAL_SKILL
                            )),
                            work_performance=int(prologue.get(
                                "work_performance", STARTING_WORK_PERFORMANCE
                            )),
                            luck=int(prologue.get("luck", STARTING_LUCK)),
                            reputation=int(prologue.get(
                                "reputation", STARTING_REPUTATION
                            )),
                            tint=int(prologue.get("tint", 0)),
                            route_orthodox=int(prologue.get(
                                "route_orthodox", 0
                            )),
                            route_unorthodox=int(prologue.get(
                                "route_unorthodox", 0
                            )),
                        )
                        for week in range(1, E_WEEKS + 1):
                            # The Month-Six Father signal precedes planning and
                            # the Week-21 routines in production.
                            if week == 21:
                                ledger.apply_effects(
                                    choice_effects(father_choice)
                                )
                            for routine_id in routine_pair:
                                ledger.apply_effects(
                                    weekly_effects(options, routine_id)
                                )
                                ledger.routine_units += 1
                            if week == 4:
                                ledger.apply_effects(
                                    choice_effects(plan["week_4_choice"])
                                )
                            elif week == 8:
                                # claim_scheduled_prelude() resolves the
                                # consequence before the scheduled SNS story.
                                ledger.apply_effects(
                                    choice_effects(plan["week_8_choice"])
                                )
                            if week not in (4, 24):
                                for effects in selected_effects.get(week, []):
                                    ledger.apply_effects(effects)
                            if week == 24:
                                # prepare_demo_collision() emits the dirty root,
                                # then First Bill and the effectless Hyunsu echo.
                                if callback_choice:
                                    ledger.apply_effects(
                                        choice_effects(callback_choice)
                                    )
                                ledger.apply_effects(choice_effects(bill_choice))
                            if not ledger.death_week and (
                                ledger.health <= 0 or ledger.mental <= 0
                            ):
                                ledger.death_week = week
                            if week % 4 == 0:
                                if week == 4 and ledger.settlement_claims == 0:
                                    ledger.cash += OPENING_SURVIVAL_BUFFER
                                    ledger.settlement_claims += 1
                                ledger.apply_monthly_pressure(week)
                                if not ledger.death_week and (
                                    ledger.health <= 0 or ledger.mental <= 0
                                ):
                                    ledger.death_week = week
                        matrix[key] = ledger
        expected_ledgers = len(prologue_policies) * len(
            KERNEL_ROUTINE_PAIRS
        ) * len(KERNEL_POLICIES) * len(KERNEL_BRANCHES)
        if len(matrix) != expected_ledgers:
            fail(
                f"paired matrix produced {len(matrix)} ledgers instead of "
                f"{expected_ledgers}",
                matrix_errors,
            )
        return matrix

    all_ledgers = simulate_matrix(errors)
    replay_errors: list[str] = []
    replay_ledgers = simulate_matrix(replay_errors)
    for message in replay_errors:
        fail(f"paired deterministic replay: {message}", errors)
    for key, ledger in all_ledgers.items():
        replay = replay_ledgers.get(key)
        if replay is None or ledger.monthly_snapshots != replay.monthly_snapshots:
            fail(f"paired trace is not deterministic for {key}", errors)
        weeks = tuple(int(row["week"]) for row in ledger.monthly_snapshots)
        if weeks != PAIRED_SNAPSHOT_WEEKS:
            fail(f"paired trace {key} lost a monthly snapshot: {weeks}", errors)
        if ledger.routine_units != E_WEEKS * 2:
            fail(f"paired trace {key} did not execute 48 routine units", errors)
        if ledger.settlement_claims != 1:
            fail(f"paired trace {key} did not claim one opening subsidy", errors)
        if ledger.death_week:
            fail(
                f"paired trace's complete selected schedule killed {key} in "
                f"Week {ledger.death_week}",
                errors,
            )

    lines: list[str] = []
    prologue_policy_count = len(prologue_policies)
    lines.append(
        "prologue_controls "
        f"root={PROLOGUE_SEQUENCE[0]} events={len(PROLOGUE_SEQUENCE)} "
        f"policies={prologue_policy_count} "
        "space=knee[0,1,2]*payment[0,1,2]*dad[0,1]*goal[0,1,2]*meal[0,1] "
        f"week1_cash={_delta_range(prologue_policies, 'cash')} "
        f"health={_delta_range(prologue_policies, 'health')} "
        f"mental={_delta_range(prologue_policies, 'mental')} "
        f"intelligence={_delta_range(prologue_policies, 'intelligence')} "
        f"tint={_delta_range(prologue_policies, 'tint')} "
        f"orthodox={_delta_range(prologue_policies, 'route_orthodox')} "
        f"unorthodox={_delta_range(prologue_policies, 'route_unorthodox')}"
    )
    for branch_id in KERNEL_BRANCHES:
        plan = branch_plans[branch_id]
        w4_event = plan["week_4_event"]
        w8_event = plan["week_8_event"]
        w24_event = plan["week_24_event"]
        w24 = (
            f"{plan['week_24_event_id']}/policy_choice->"
            "v2_demo_first_bill_opening->v2_demo_first_bill/policy_choice"
            if w24_event
            else "v2_demo_first_bill_opening->v2_demo_first_bill/policy_choice"
        )
        lines.append(
            "temptation_chain "
            f"branch={branch_id} "
            f"w4={plan['week_4_event_id']}/"
            f"{_choice_index(w4_event, plan['week_4_choice'])} "
            f"w8={plan['week_8_event_id']}/"
            f"{_choice_index(w8_event, plan['week_8_choice'])}->"
            "sns_pressure_night/arc_intro_03_sns/0 "
            f"w24={w24}"
        )
    paired_schedule = dict(PAIRED_FULL_SCHEDULE)
    for month_number in range(1, 7):
        first_week = (month_number - 1) * 4 + 1
        schedule_label = ",".join(
            f"w{week}:{paired_schedule[week]}"
            for week in range(first_week, first_week + 4)
        )
        lines.append(
            f"paired_schedule month={month_number} slots={schedule_label}"
        )
    representative_control = (
        f"{REPRESENTATIVE_PROLOGUE_POLICY}/livelihood+growth/cautious"
    )
    representative_prologue = next(
        (
            policy for policy in prologue_policies
            if policy.get("id") == REPRESENTATIVE_PROLOGUE_POLICY
        ),
        {},
    )
    paired_control_count = prologue_policy_count * len(
        KERNEL_ROUTINE_PAIRS
    ) * len(KERNEL_POLICIES)
    control_specs: list[tuple[str, str]] = [
        (
            policy_id,
            f"{prologue['id']}/{'+'.join(routine_pair)}/{policy_id}",
        )
        for prologue in prologue_policies
        for routine_pair in KERNEL_ROUTINE_PAIRS
        for policy_id in KERNEL_POLICIES
    ]
    if len(control_specs) != paired_control_count:
        fail(
            f"paired control index produced {len(control_specs)} controls "
            f"instead of {paired_control_count}",
            errors,
        )
    lines.append(
        "temptation_controls "
        f"validated={paired_control_count} "
        f"ledgers={paired_control_count * len(KERNEL_BRANCHES)} "
        f"representative={representative_control} "
        f"raw_new_game=cash{STARTING_CASH}:"
        f"health{STARTING_HEALTH}:mental{STARTING_MENTAL}:"
        f"intelligence{STARTING_INTELLIGENCE}:"
        f"social{STARTING_SOCIAL_SKILL}:luck{STARTING_LUCK}:"
        f"reputation{STARTING_REPUTATION}:tint0 "
        f"representative_week1=cash{representative_prologue.get('cash', 'missing')}:"
        f"health{representative_prologue.get('health', 'missing')}:"
        f"mental{representative_prologue.get('mental', 'missing')}:"
        f"intelligence{representative_prologue.get('intelligence', 'missing')}:"
        f"tint{representative_prologue.get('tint', 'missing')} "
        f"selected_slots={PAIRED_PLAYER_SELECTED_SLOTS} locked_slots=2 "
        f"subsidy=w4:+{OPENING_SURVIVAL_BUFFER}:before_monthly_pressure "
        "cafe=w7:cafe_world_glimpse/cafe_00/choice0 "
        "city_prelude=w23:m6_city_service_response/"
        "v2_city_service_work_sample_message/choice0:before_hyunsu_exam_eve "
        f"first_bill=cautious:{policy_plans['cautious']['first_bill']},"
        f"hard:{policy_plans['hard']['first_bill']} "
        "snapshot_phase=controlled_post_monthly_pressure "
        "numeric_scope=controlled_ledger_not_full_runtime_snapshot "
        "included=fresh_prologue_player_effects+"
        "selected_story_action_effects+routines+"
        "mandatory_preludes_including_w23_city_service+"
        "first_bill+monthly_pressure "
        "excluded=prologue_cast_affinity+other_application_result_preludes+"
        "application_status_transitions+"
        "job_relationship_item_monthlies+"
        "nonnumeric_decline_receipts numeric_decline_omissions=0"
    )
    lines.append(
        "w24_live_candidates "
        f"count={len(EXPECTED_PAIRED_W24_CANDIDATES)} "
        f"ids={','.join(EXPECTED_PAIRED_W24_CANDIDATES)} "
        "state=city_application_submitted+city_prelude_presented+"
        "current_job_empty+hanbit_provenance_false+person_obligation_none "
        "exposed_policies=cautious:body_rest(choice7),"
        "hard:urgent_paid_shift(choice6) "
        "visibility_gate=StoryMode._choice_visible->"
        "DemoCoreLoopV2.story_choice_available"
    )
    zero_branch_delta = (
        "money0,health0,mental0,intelligence0,social_skill0,luck0,"
        "reputation0,tint0,appearance0,investment_skill0,work_performance0"
    )
    for policy_id in KERNEL_POLICIES:
        bill_choice = resolved_policies.get(policy_id, {}).get(
            "first_bill", {}
        )
        obligation_id = str(bill_choice.get("v2_obligation_id", "")) \
            if isinstance(bill_choice, dict) else ""
        effects = choice_effects(bill_choice)
        effect_tokens = ",".join(
            f"{stat}{int(value):+d}" for stat, value in sorted(effects.items())
        ) or "none"
        lines.append(
            "first_bill_paired_control "
            f"policy={policy_id} obligation_id={obligation_id} "
            f"choice_index={_choice_index(first_bill, bill_choice)} "
            f"effects={effect_tokens} applied_branches=3 "
            "receipt=obligation_receipts/demo_collision "
            f"paired_branch_delta={zero_branch_delta}"
        )
    for branch_id in KERNEL_BRANCHES:
        evidence = w24_branch_evidence[branch_id]
        foreground_ids = tuple(evidence["foreground_ids"])
        callback_indices = []
        for policy_id in KERNEL_POLICIES:
            callback_choice = callback_choices.get(
                policy_id, {}
            ).get(branch_id, {})
            if callback_choice:
                callback_indices.append(
                    f"{policy_id}:"
                    f"{_choice_index(branch_plans[branch_id]['week_24_event'], callback_choice)}"
                )
        receipt_id = str(evidence["receipt_id"])
        lines.append(
            "w24_branch_surface "
            f"branch={branch_id} "
            f"additional_foreground_count={len(foreground_ids)} "
            f"additional_foreground_ids={','.join(foreground_ids) or 'none'} "
            f"callback_count={len(foreground_ids)} "
            f"callback_choice_indices={','.join(callback_indices) or 'none'} "
            f"exact_trace_copy_id={evidence['trace_copy_id'] or 'none'} "
            "branch_receipt="
            f"{('deferred_callback_receipts/' + receipt_id) if receipt_id else 'none'} "
            f"receipt_synthetic={evidence['synthetic']} "
            f"receipt_lifecycle={'claimed_to_resolved' if receipt_id else 'none'}"
        )

    # Produce exact paired deltas against clean for every controlled routine
    # and policy.  Costs are cumulative authored temptation costs through the
    # checkpoint; shared routines, selected schedule, Father and First Bill choices
    # are intentionally named as controls instead of misattributed to a branch.
    for policy_id, control in control_specs:
            clean = all_ledgers.get(f"{control}/clean")
            if clean is None:
                fail(f"paired trace lost clean baseline {control}", errors)
                continue
            for branch_id in KERNEL_BRANCHES:
                ledger = all_ledgers.get(f"{control}/{branch_id}")
                if ledger is None:
                    fail(f"paired trace lost {control}/{branch_id}", errors)
                    continue
                visible_costs: list[str] = []
                hidden_only: list[str] = []
                plan = branch_plans[branch_id]
                choices_by_week = {
                    4: (
                        str(plan["week_4_event_id"]),
                        plan["week_4_choice"],
                    ),
                    8: (
                        str(plan["week_8_event_id"]),
                        plan["week_8_choice"],
                    ),
                }
                callback_choice = callback_choices.get(
                    policy_id, {}
                ).get(branch_id, {})
                if callback_choice:
                    choices_by_week[24] = (
                        str(plan["week_24_event_id"]),
                        callback_choice,
                    )
                for index, week in enumerate(PAIRED_SNAPSHOT_WEEKS):
                    if week in choices_by_week:
                        event_id, choice = choices_by_week[week]
                        new_visible, new_hidden = _temptation_cost_tokens(
                            event_id, choice
                        )
                        visible_costs.extend(new_visible)
                        hidden_only.extend(new_hidden)
                    row = ledger.monthly_snapshots[index]
                    baseline = clean.monthly_snapshots[index]
                    deltas = {
                        stat: int(row[stat]) - int(baseline[stat])
                        for stat in (
                            "cash", "health", "mental", "intelligence",
                            "social_skill", "luck", "reputation", "tint",
                        )
                    }
                    if branch_id == "clean" and any(deltas.values()):
                        fail(
                            f"paired clean baseline {control} is not zero at "
                            f"Week {week}: {deltas}",
                            errors,
                        )
                    if control == representative_control:
                        lines.append(
                            "temptation_pair "
                            f"week={week} branch={branch_id} "
                            f"control={control} "
                            f"cash={row['cash']} health={row['health']} "
                            f"mental={row['mental']} "
                            f"intelligence={row['intelligence']} "
                            f"social={row['social_skill']} luck={row['luck']} "
                            f"reputation={row['reputation']} tint={row['tint']} "
                            f"cash_delta={deltas['cash']} "
                            f"health_delta={deltas['health']} "
                            f"mental_delta={deltas['mental']} "
                            f"intelligence_delta={deltas['intelligence']} "
                            f"social_delta={deltas['social_skill']} "
                            f"luck_delta={deltas['luck']} "
                            f"reputation_delta={deltas['reputation']} "
                            f"tint_delta={deltas['tint']} "
                            f"visible_costs="
                            f"{','.join(visible_costs) or 'none'} "
                            f"hidden_only={','.join(hidden_only) or 'none'}"
                        )

    # A candidate is reported only from like-for-like Week-8+ snapshots.  The
    # legacy summary and its named cash ledgers remain above as regressions but
    # are not inputs to this verdict.
    pareto_controls: list[str] = []
    clean_pareto_path_controls: list[str] = []
    clean_pareto_w24_controls: list[str] = []
    clean_nonpareto_w24: list[tuple[str, dict[str, int]]] = []
    clean_pareto_by_week: dict[int, list[dict[str, int]]] = {
        week: [] for week in PAIRED_SNAPSHOT_WEEKS
    }
    clean_tradeoff_path_controls: dict[str, list[str]] = {
        "dirty_return": [],
        "dirty_deeper": [],
    }
    clean_tradeoff_w24_controls: dict[str, list[str]] = {
        "dirty_return": [],
        "dirty_deeper": [],
    }
    for _policy_id, control in control_specs:
            returned = all_ledgers.get(f"{control}/dirty_return")
            deeper = all_ledgers.get(f"{control}/dirty_deeper")
            if returned is None or deeper is None:
                continue
            dominates_all = True
            for index, week in enumerate(PAIRED_SNAPSHOT_WEEKS):
                if week < 8:
                    continue
                returned_row = returned.monthly_snapshots[index]
                deeper_row = deeper.monthly_snapshots[index]
                deltas = [
                    int(deeper_row[stat]) - int(returned_row[stat])
                    for stat in (
                        "cash", "health", "mental", "intelligence",
                        "social_skill", "luck", "reputation",
                    )
                ]
                if not all(value >= 0 for value in deltas) \
                        or not any(value > 0 for value in deltas):
                    dominates_all = False
                    break
            if dominates_all:
                pareto_controls.append(control)
            clean = all_ledgers.get(f"{control}/clean")
            if clean is None:
                continue
            clean_path_dominates = True
            for index, week in enumerate(PAIRED_SNAPSHOT_WEEKS):
                deeper_row = deeper.monthly_snapshots[index]
                clean_row = clean.monthly_snapshots[index]
                clean_delta = {
                    stat: int(deeper_row[stat]) - int(clean_row[stat])
                    for stat in (
                        "cash", "health", "mental", "intelligence",
                        "social_skill", "luck", "reputation", "tint",
                    )
                }
                clean_pareto_by_week[week].append(clean_delta)
                visible = [
                    clean_delta[stat] for stat in (
                        "cash", "health", "mental", "intelligence",
                        "social_skill", "luck", "reputation",
                    )
                ]
                checkpoint_dominates = all(value >= 0 for value in visible) \
                    and any(value > 0 for value in visible)
                if week >= 8 and not checkpoint_dominates:
                    clean_path_dominates = False
                if week == 24 and checkpoint_dominates:
                    clean_pareto_w24_controls.append(control)
                elif week == 24:
                    clean_nonpareto_w24.append((control, clean_delta))
            if clean_path_dominates:
                clean_pareto_path_controls.append(control)
            for branch_id in clean_tradeoff_path_controls:
                branch = all_ledgers.get(f"{control}/{branch_id}")
                if branch is None:
                    continue
                mixed_path = False
                for index, week in enumerate(PAIRED_SNAPSHOT_WEEKS):
                    if week < 8:
                        continue
                    branch_row = branch.monthly_snapshots[index]
                    clean_row = clean.monthly_snapshots[index]
                    visible_deltas = [
                        int(branch_row[stat]) - int(clean_row[stat])
                        for stat in (
                            "cash", "health", "mental", "intelligence",
                            "social_skill", "luck", "reputation",
                        )
                    ]
                    if (
                        any(value > 0 for value in visible_deltas)
                        and any(value < 0 for value in visible_deltas)
                    ):
                        mixed_path = True
                if mixed_path:
                    clean_tradeoff_path_controls[branch_id].append(control)
                branch_w24 = branch.monthly_snapshots[-1]
                clean_w24 = clean.monthly_snapshots[-1]
                w24_deltas = [
                    int(branch_w24[stat]) - int(clean_w24[stat])
                    for stat in (
                        "cash", "health", "mental", "intelligence",
                        "social_skill", "luck", "reputation",
                    )
                ]
                if (
                    any(value > 0 for value in w24_deltas)
                    and any(value < 0 for value in w24_deltas)
                ):
                    clean_tradeoff_w24_controls[branch_id].append(control)
    expected_control_count = len(control_specs)
    verdict = (
        "balance_candidate"
        if pareto_controls
        else "human_only"
    )
    for branch_id in ("dirty_return", "dirty_deeper"):
        path_matched = clean_tradeoff_path_controls[branch_id]
        w24_matched = clean_tradeoff_w24_controls[branch_id]
        sample_control = representative_control
        sample_branch = all_ledgers.get(f"{sample_control}/{branch_id}")
        sample_clean = all_ledgers.get(f"{sample_control}/clean")
        sample_delta = {}
        if sample_branch is not None and sample_clean is not None:
            sample_delta = {
                stat: int(sample_branch.monthly_snapshots[-1][stat])
                - int(sample_clean.monthly_snapshots[-1][stat])
                for stat in (
                    "cash", "health", "mental", "intelligence",
                    "social_skill", "luck", "reputation", "tint",
                )
            }
        lines.append(
            "temptation_tradeoff "
            f"branch={branch_id} baseline=clean "
            "weeks=8,12,16,20,24 "
            f"mixed_visible_path_controls={len(path_matched)}/"
            f"{expected_control_count} "
            f"mixed_visible_w24_controls={len(w24_matched)}/"
            f"{expected_control_count} "
            f"sample_w24={sample_control}:"
            f"cash{sample_delta.get('cash', 'missing')}:"
            f"health{sample_delta.get('health', 'missing')}:"
            f"mental{sample_delta.get('mental', 'missing')}:"
            f"intelligence{sample_delta.get('intelligence', 'missing')}:"
            f"social{sample_delta.get('social_skill', 'missing')}:"
            f"luck{sample_delta.get('luck', 'missing')}:"
            f"reputation{sample_delta.get('reputation', 'missing')} "
            f"hidden_tint_delta={sample_delta.get('tint', 'missing')}"
        )
    for index, week in enumerate(PAIRED_SNAPSHOT_WEEKS):
        if week < 8:
            continue
        checkpoint_deltas: list[dict[str, int]] = []
        checkpoint_matches = 0
        for _policy_id, control in control_specs:
                returned = all_ledgers.get(f"{control}/dirty_return")
                deeper = all_ledgers.get(f"{control}/dirty_deeper")
                if returned is None or deeper is None:
                    continue
                delta = {
                    stat: int(deeper.monthly_snapshots[index][stat])
                    - int(returned.monthly_snapshots[index][stat])
                    for stat in (
                        "cash", "health", "mental", "intelligence",
                        "social_skill", "luck", "reputation", "tint",
                    )
                }
                checkpoint_deltas.append(delta)
                visible = [
                    delta[stat]
                    for stat in (
                        "cash", "health", "mental", "intelligence",
                        "social_skill", "luck", "reputation",
                    )
                ]
                if all(value >= 0 for value in visible) \
                        and any(value > 0 for value in visible):
                    checkpoint_matches += 1
        if not checkpoint_deltas:
            continue
        lines.append(
            "temptation_pareto "
            f"week={week} comparison=dirty_deeper-dirty_return "
            f"cash_delta={_delta_range(checkpoint_deltas, 'cash')} "
            f"health_delta={_delta_range(checkpoint_deltas, 'health')} "
            f"mental_delta={_delta_range(checkpoint_deltas, 'mental')} "
            f"intelligence_delta="
            f"{_delta_range(checkpoint_deltas, 'intelligence')} "
            f"social_delta={_delta_range(checkpoint_deltas, 'social_skill')} "
            f"luck_delta={_delta_range(checkpoint_deltas, 'luck')} "
            f"reputation_delta="
            f"{_delta_range(checkpoint_deltas, 'reputation')} "
            f"tint_delta={_delta_range(checkpoint_deltas, 'tint')} "
            f"matched_controls={checkpoint_matches}/{expected_control_count}"
        )
    for week in PAIRED_SNAPSHOT_WEEKS:
        checkpoint_deltas = clean_pareto_by_week.get(week, [])
        if not checkpoint_deltas:
            continue
        checkpoint_matches = sum(
            1 for delta in checkpoint_deltas
            if all(
                delta[stat] >= 0 for stat in (
                    "cash", "health", "mental", "intelligence",
                    "social_skill", "luck", "reputation",
                )
            )
            and any(
                delta[stat] > 0 for stat in (
                    "cash", "health", "mental", "intelligence",
                    "social_skill", "luck", "reputation",
                )
            )
        )
        lines.append(
            "temptation_clean_pareto "
            f"week={week} comparison=dirty_deeper-clean "
            f"cash_delta={_delta_range(checkpoint_deltas, 'cash')} "
            f"health_delta={_delta_range(checkpoint_deltas, 'health')} "
            f"mental_delta={_delta_range(checkpoint_deltas, 'mental')} "
            f"intelligence_delta="
            f"{_delta_range(checkpoint_deltas, 'intelligence')} "
            f"social_delta={_delta_range(checkpoint_deltas, 'social_skill')} "
            f"luck_delta={_delta_range(checkpoint_deltas, 'luck')} "
            f"reputation_delta="
            f"{_delta_range(checkpoint_deltas, 'reputation')} "
            f"hidden_tint_delta={_delta_range(checkpoint_deltas, 'tint')} "
            f"matched_controls={checkpoint_matches}/{expected_control_count}"
        )
    if len(clean_pareto_w24_controls) + len(clean_nonpareto_w24) \
            != expected_control_count:
        fail(
            "Week-24 clean comparison did not classify every paired control",
            errors,
        )
    if clean_nonpareto_w24:
        deficit_stats = [
            stat for stat in (
                "cash", "health", "mental", "intelligence",
                "social_skill", "luck", "reputation",
            )
            if any(delta[stat] < 0 for _control, delta in clean_nonpareto_w24)
        ]
        deficit_tokens = [
            f"{stat}="
            f"{_delta_range([delta for _control, delta in clean_nonpareto_w24 if delta[stat] < 0], stat)}"
            for stat in deficit_stats
        ]
        witness_control, witness_delta = clean_nonpareto_w24[0]
        lines.append(
            "temptation_clean_nonpareto "
            "week=24 comparison=dirty_deeper-clean "
            f"controls={len(clean_nonpareto_w24)}/{expected_control_count} "
            f"deficit_stats={','.join(deficit_stats) or 'none'} "
            f"deficit_ranges={','.join(deficit_tokens) or 'none'} "
            f"witness={witness_control}:"
            f"cash{witness_delta['cash']}:health{witness_delta['health']}:"
            f"mental{witness_delta['mental']}:"
            f"intelligence{witness_delta['intelligence']}:"
            f"social{witness_delta['social_skill']}:luck{witness_delta['luck']}:"
            f"reputation{witness_delta['reputation']} "
            "interpretation="
            f"{len(clean_pareto_w24_controls)}_of_{expected_control_count}_"
            "is_not_full_clean_dominance"
        )
    actual_pareto_counts = {
        "deeper_return_path": len(pareto_controls),
        "deeper_clean_path": len(clean_pareto_path_controls),
        "deeper_clean_w24": len(clean_pareto_w24_controls),
        "deeper_clean_w24_nonpareto": len(clean_nonpareto_w24),
    }
    if expected_control_count != 648 \
            or actual_pareto_counts != EXPECTED_PAIRED_PARETO_COUNTS:
        fail(
            "paired Pareto regression drifted after common Week-23 prelude: "
            f"controls={expected_control_count} counts={actual_pareto_counts}",
            errors,
        )
    evidence = "visible_pareto_dirty_deeper_vs_dirty_return_w8_w24"
    if len(clean_pareto_path_controls) == expected_control_count:
        evidence += "+visible_path_pareto_dirty_deeper_vs_clean_w8_w24"
    if len(clean_pareto_w24_controls) == expected_control_count:
        evidence += "+visible_terminal_pareto_dirty_deeper_vs_clean_w24"
    hidden_clean_values = {
        row["tint"] for row in clean_pareto_by_week.get(24, [])
    }
    hidden_clean_label = (
        str(next(iter(hidden_clean_values)))
        if len(hidden_clean_values) == 1 else "mixed"
    )
    sample_return = all_ledgers.get(f"{representative_control}/dirty_return")
    sample_deeper = all_ledgers.get(f"{representative_control}/dirty_deeper")
    return_hidden_label: int | str = "missing"
    if sample_return is not None and sample_deeper is not None:
        return_hidden_label = int(sample_deeper.monthly_snapshots[-1]["tint"]) \
            - int(sample_return.monthly_snapshots[-1]["tint"])
    lines.append(
        f"verdict={verdict} "
        f"evidence={evidence} "
        "candidate_basis=dirty_deeper_dominates_dirty_return_"
        "at_every_w8_w24_checkpoint_for_all_controls "
        "visible_stats=cash,health,mental,intelligence,social,reputation,luck "
        "omitted_public_deltas="
        "appearance0,investment_skill0,work_performance0 "
        f"return_hidden_tint_delta={return_hidden_label} "
        f"deeper_clean_hidden_tint_delta={hidden_clean_label} "
        "conditional_dark_ending_reader=outside_demo_visible_pareto "
        "deeper_return_path_pareto_controls="
        f"{len(pareto_controls)}/{expected_control_count} "
        "deeper_clean_path_pareto_controls="
        f"{len(clean_pareto_path_controls)}/"
        f"{expected_control_count} "
        "deeper_clean_w24_pareto_controls="
        f"{len(clean_pareto_w24_controls)}/"
        f"{expected_control_count}"
    )
    return lines, verdict


def main() -> int:
    errors: list[str] = []
    validate_runtime_monthly_pressure(errors)
    contract = load_json(CONTRACT_PATH)
    routine = contract.get("routine", {})
    options = routine.get("options", {}) if isinstance(routine, dict) else {}
    if not isinstance(options, dict):
        options = {}

    livelihood = weekly_effects(options, "livelihood")
    if int(livelihood.get("money", 0)) != 70_000:
        fail(
            "unemployed livelihood must yield exactly KRW 70,000 per week",
            errors,
        )

    a1_livelihood = simulate_legal(
        "a1_livelihood", ("livelihood", "recovery"), options, A1_WEEKS
    )
    if a1_livelihood.cash != 60_000:
        fail(
            f"the A1 week-eight legal result drifted from KRW 60,000: "
            f"{a1_livelihood.cash:,}",
            errors,
        )

    b_no_shift_livelihood = simulate_legal(
        "b_no_shift_livelihood",
        ("livelihood", "recovery"),
        options,
        B_WEEKS,
    )
    b_no_shift_growth = simulate_legal(
        "b_no_shift_growth",
        ("growth", "livelihood"),
        options,
        B_WEEKS,
    )
    pressure_ledgers = (b_no_shift_livelihood, b_no_shift_growth)
    for ledger in pressure_ledgers:
        if ledger.routine_units != B_WEEKS * 2:
            fail(
                f"{ledger.name} executed {ledger.routine_units} routine units, "
                "expected 24",
                errors,
            )
        if ledger.cash != -310_000:
            fail(
                f"{ledger.name} must expose the no-shift/no-hire pressure "
                f"of KRW -310,000, got {ledger.cash:,}",
                errors,
            )
    if b_no_shift_livelihood.mental <= b_no_shift_growth.mental:
        fail(
            "recovery support no longer leaves more mental capacity than growth",
            errors,
        )
    if b_no_shift_growth.intelligence <= b_no_shift_livelihood.intelligence:
        fail(
            "growth support no longer produces a distinct skill advantage",
            errors,
        )

    inventory_config = action_config(contract, "m3_inventory_shift")
    if str(inventory_config.get("execution", "")) != "instant_effect":
        fail("month-three inventory work is not an instant authored effect", errors)
    inventory_effects = inventory_config.get("effects", {})
    if not isinstance(inventory_effects, dict):
        inventory_effects = {}
    if inventory_effects != {"money": 360_000, "health": -4, "mental": -3}:
        fail(
            f"inventory shift effects drifted: {inventory_effects}",
            errors,
        )
    legal_inventory = simulate_legal(
        "legal_livelihood_inventory",
        ("livelihood", "recovery"),
        options,
        B_WEEKS,
    )
    legal_inventory.apply_effects(inventory_effects)
    if legal_inventory.cash < 50_000:
        fail(
            f"livelihood plus inventory must end at or above KRW 50,000, "
            f"got {legal_inventory.cash:,}",
            errors,
        )

    c_no_shifts = simulate_legal(
        "c_no_shifts", ("livelihood", "recovery"), options, C_WEEKS
    )
    if c_no_shifts.routine_units != C_WEEKS * 2:
        fail(
            f"the sixteen-week fixture executed {c_no_shifts.routine_units} "
            "routine units, expected 32",
            errors,
        )
    if c_no_shifts.cash != -680_000:
        fail(
            "the sixteen-week no-shift livelihood path must expose KRW 680,000 "
            f"of arrears, got {c_no_shifts.cash:,}",
            errors,
        )

    logistics_config = action_config(contract, "m4_logistics_shift")
    if str(logistics_config.get("execution", "")) != "instant_effect":
        fail("month-four logistics work is not an instant authored effect", errors)
    logistics_effects = logistics_config.get("effects", {})
    if not isinstance(logistics_effects, dict):
        logistics_effects = {}
    if logistics_effects != {"money": 520_000, "health": -7, "mental": -5}:
        fail(
            f"logistics shift effects drifted: {logistics_effects}",
            errors,
        )

    c_late_shift_only = simulate_legal(
        "c_late_shift_only", ("livelihood", "recovery"), options, C_WEEKS
    )
    c_late_shift_only.apply_effects(logistics_effects)
    if c_late_shift_only.cash != -160_000:
        fail(
            "taking only the late logistics shift must not erase the missed "
            f"month-three choice, got {c_late_shift_only.cash:,}",
            errors,
        )

    c_two_shift_legal = simulate_legal(
        "c_two_shift_legal", ("livelihood", "recovery"), options, C_WEEKS
    )
    c_two_shift_legal.apply_effects(inventory_effects)
    c_two_shift_legal.apply_effects(logistics_effects)
    if c_two_shift_legal.cash != 200_000:
        fail(
            "the two-shift legal path must finish week 16 at exactly "
            f"KRW 200,000, got {c_two_shift_legal.cash:,}",
            errors,
        )

    moving_config = action_config(contract, "m5_weekend_move_shift")
    if str(moving_config.get("execution", "")) != "instant_effect":
        fail("month-five moving work is not an instant authored effect", errors)
    moving_effects = moving_config.get("effects", {})
    if not isinstance(moving_effects, dict):
        moving_effects = {}
    if moving_effects != {"money": 560_000, "health": -8, "mental": -5}:
        fail(f"month-five moving shift effects drifted: {moving_effects}", errors)

    d_no_shifts = simulate_legal(
        "d_no_shifts", ("livelihood", "recovery"), options
    )
    if d_no_shifts.routine_units != DEVELOPMENT_WEEKS * 2:
        fail(
            f"the twenty-week fixture executed {d_no_shifts.routine_units} "
            "routine units, expected 40",
            errors,
        )
    if d_no_shifts.cash != -1_050_000:
        fail(
            "the twenty-week no-shift livelihood path must expose "
            f"KRW 1,050,000 of arrears, got {d_no_shifts.cash:,}",
            errors,
        )

    d_late_shift_only = simulate_legal(
        "d_late_shift_only", ("livelihood", "recovery"), options
    )
    d_late_shift_only.apply_effects(logistics_effects)
    d_late_shift_only.apply_effects(moving_effects)
    if d_late_shift_only.cash != 30_000:
        fail(
            "the month-four and month-five shifts must leave exactly "
            f"KRW 30,000 while preserving the missed month-three choice, "
            f"got {d_late_shift_only.cash:,}",
            errors,
        )

    d_three_shift_legal = simulate_legal(
        "d_three_shift_legal", ("livelihood", "recovery"), options
    )
    d_three_shift_legal.apply_effects(inventory_effects)
    d_three_shift_legal.apply_effects(logistics_effects)
    d_three_shift_legal.apply_effects(moving_effects)
    if d_three_shift_legal.cash != 390_000:
        fail(
            "all three authored legal shifts must finish week 20 at exactly "
            f"KRW 390,000, got {d_three_shift_legal.cash:,}",
            errors,
        )

    jobs = load_json(JOBS_PATH)
    if not isinstance(jobs, list):
        fail("job catalog must be a list", errors)
        jobs = []
    hanbit_job = next(
        (
            row
            for row in jobs
            if isinstance(row, dict) and row.get("id") == "job_03"
        ),
        {},
    )
    hanbit_salary = int(hanbit_job.get("base_salary", 0))
    if hanbit_salary != 2_240_000:
        fail(
            f"Hanbit job_03 salary drifted from KRW 2,240,000: "
            f"{hanbit_salary:,}",
            errors,
        )
    core_events = load_json(CORE_LOOP_EVENTS_PATH)
    hanbit_event = next(
        (
            row
            for row in core_events
            if isinstance(row, dict)
            and row.get("id") == "v2_hanbit_offer_message"
        ),
        {},
    )
    hanbit_choices = hanbit_event.get("choices", [])
    hanbit_accept = (
        hanbit_choices[0]
        if isinstance(hanbit_choices, list)
        and hanbit_choices
        and isinstance(hanbit_choices[0], dict)
        else {}
    )
    first_paycheck_ratio = float(hanbit_accept.get("first_paycheck_ratio", 0.0))
    if first_paycheck_ratio != 0.75:
        fail(
            "Hanbit's first paycheck must cover exactly three of four weeks, "
            f"got ratio {first_paycheck_ratio}",
            errors,
        )
    expected_display = {
        "ko": "한빛유통 물류센터 운영지원 계약직",
        "en": "Hanbit Logistics Operations Support (Contract)",
    }
    if hanbit_accept.get("grant_job_display") != expected_display:
        fail(
            "Hanbit's granted job lost its company-specific role name",
            errors,
        )
    hanbit_first_paycheck = int(hanbit_salary * first_paycheck_ratio)
    d_hired_legal = simulate_hired_month_five(
        "d_hired_legal",
        ("livelihood", "recovery"),
        options,
        hanbit_first_paycheck,
    )
    d_hired_legal.apply_effects(inventory_effects)
    d_hired_legal.apply_effects(logistics_effects)
    if d_hired_legal.cash != 1_300_000:
        fail(
            "accepting the earned Hanbit offer after both earlier legal shifts "
            "must finish week 20 at exactly KRW 1,300,000 after the "
            "three-week first paycheck, "
            f"got {d_hired_legal.cash:,}",
            errors,
        )

    e_public_config = action_config(contract, "m6_public_recruitment")
    e_public_effects = e_public_config.get("effects", {})
    if e_public_effects != {"intelligence": 3, "mental": -3}:
        fail(f"month-six NCS practice effects drifted: {e_public_effects}", errors)

    e_holiday_config = action_config(contract, "m6_holiday_night_shift")
    e_holiday_effects = e_holiday_config.get("effects", {})
    if e_holiday_effects != {
        "money": 480_000,
        "health": -6,
        "mental": -5,
    }:
        fail(
            f"month-six holiday shift effects drifted: {e_holiday_effects}",
            errors,
        )

    e_study_config = action_config(contract, "m6_last_study_group")
    e_study_effects = e_study_config.get("effects", {})
    if e_study_effects != {
        "intelligence": 2,
        "social_skill": 1,
        "mental": -2,
    }:
        fail(
            f"month-six final study group effects drifted: {e_study_effects}",
            errors,
        )

    e_recovery_config = action_config(contract, "m6_no_plans_day")
    e_recovery_effects = e_recovery_config.get("effects", {})
    e_recovery_diminished = e_recovery_config.get(
        "recovery_routine_effects", {}
    )
    if e_recovery_effects != {"health": 5, "mental": 7}:
        fail(
            f"month-six full recovery effects drifted: {e_recovery_effects}",
            errors,
        )
    if e_recovery_diminished != {"health": 2, "mental": 3}:
        fail(
            "month-six recovery-routine diminishing return drifted: "
            f"{e_recovery_diminished}",
            errors,
        )

    first_bill = event_by_id(core_events, "v2_demo_first_bill")
    first_bill_choices = first_bill.get("choices", [])
    urgent_paid_choice = next(
        (
            choice
            for choice in first_bill_choices
            if isinstance(choice, dict)
            and choice.get("v2_obligation_id") == "urgent_paid_shift"
        ),
        {},
    )
    urgent_paid_effects = urgent_paid_choice.get("effects", {})
    if urgent_paid_effects != {
        "money": 280_000,
        "health": -5,
        "mental": -4,
    }:
        fail(
            f"Week-24 urgent paid-work effects drifted: {urgent_paid_effects}",
            errors,
        )

    father_signal = event_by_id(core_events, "v2_father_health_signal")
    father_money_effects = [
        int(choice.get("effects", {}).get("money", 0))
        for choice in father_signal.get("choices", [])
        if isinstance(choice, dict)
        and isinstance(choice.get("effects", {}), dict)
    ]
    if father_money_effects != [0, 0, 0]:
        fail(
            "Father's Week-21 signal must not invent a hospital, travel, or "
            f"remittance cost: {father_money_effects}",
            errors,
        )

    e_no_shifts = simulate_legal(
        "e_no_shifts",
        ("livelihood", "recovery"),
        options,
        E_WEEKS,
    )
    if e_no_shifts.routine_units != E_WEEKS * 2:
        fail(
            f"the twenty-four-week fixture executed {e_no_shifts.routine_units} "
            "routine units, expected 48",
            errors,
        )
    if e_no_shifts.cash != -1_420_000:
        fail(
            "the twenty-four-week no-shift livelihood path must expose "
            f"KRW 1,420,000 of arrears, got {e_no_shifts.cash:,}",
            errors,
        )

    e_no_month_three_shift = simulate_legal(
        "e_no_month_three_shift",
        ("livelihood", "recovery"),
        options,
        E_WEEKS,
    )
    e_no_month_three_shift.apply_effects(logistics_effects)
    e_no_month_three_shift.apply_effects(moving_effects)
    e_no_month_three_shift.apply_effects(e_holiday_effects)
    if e_no_month_three_shift.cash != 140_000:
        fail(
            "the Month 4-6 shift path must preserve the missed Month-3 choice "
            f"at exactly KRW 140,000, got {e_no_month_three_shift.cash:,}",
            errors,
        )

    e_three_prior_shifts = simulate_legal(
        "e_three_prior_shifts",
        ("livelihood", "recovery"),
        options,
        E_WEEKS,
    )
    for effects in (inventory_effects, logistics_effects, moving_effects):
        e_three_prior_shifts.apply_effects(effects)
    if e_three_prior_shifts.cash != 20_000:
        fail(
            "taking all three earlier shifts but missing Month Six must close "
            f"at exactly KRW 20,000, got {e_three_prior_shifts.cash:,}",
            errors,
        )

    e_four_shift_legal = simulate_legal(
        "e_four_shift_legal",
        ("livelihood", "recovery"),
        options,
        E_WEEKS,
    )
    for effects in (
        inventory_effects,
        logistics_effects,
        moving_effects,
        e_holiday_effects,
    ):
        e_four_shift_legal.apply_effects(effects)
    if e_four_shift_legal.cash != 500_000:
        fail(
            "all four authored legal shifts must finish Week 24 at exactly "
            f"KRW 500,000, got {e_four_shift_legal.cash:,}",
            errors,
        )

    e_four_shifts_with_urgent = simulate_legal(
        "e_four_shifts_with_urgent",
        ("livelihood", "recovery"),
        options,
        E_WEEKS,
    )
    for effects in (
        inventory_effects,
        logistics_effects,
        moving_effects,
        e_holiday_effects,
        urgent_paid_effects,
    ):
        e_four_shifts_with_urgent.apply_effects(effects)
    if e_four_shifts_with_urgent.cash != 780_000:
        fail(
            "the four legal shifts plus First Bill urgent work must close at "
            f"exactly KRW 780,000, got {e_four_shifts_with_urgent.cash:,}",
            errors,
        )

    e_holiday_and_urgent_only = simulate_legal(
        "e_holiday_and_urgent_only",
        ("livelihood", "recovery"),
        options,
        E_WEEKS,
    )
    e_holiday_and_urgent_only.apply_effects(e_holiday_effects)
    e_holiday_and_urgent_only.apply_effects(urgent_paid_effects)
    if e_holiday_and_urgent_only.cash != -660_000:
        fail(
            "Month Six's holiday and urgent shifts alone must not erase five "
            f"months of missed work: got {e_holiday_and_urgent_only.cash:,}",
            errors,
        )

    e_hired_legal = simulate_hired_month_six_from_close(
        "e_hired_legal",
        d_hired_legal.cash,
        ("livelihood", "recovery"),
        options,
        hanbit_salary,
    )
    if d_hired_legal.routine_units + e_hired_legal.routine_units != E_WEEKS * 2:
        fail(
            "the hired six-month path must execute exactly 48 background "
            "routine units",
            errors,
        )
    if e_hired_legal.cash != 2_890_000:
        fail(
            "the Hanbit Month-Six ledger must be 1,300,000 + 2,240,000 "
            f"- 650,000 = 2,890,000, got {e_hired_legal.cash:,}",
            errors,
        )
    d_growth_config = action_config(contract, "m5_evening_spreadsheet_class")
    d_growth_effects = d_growth_config.get("effects", {})
    if d_growth_effects != {"intelligence": 2, "mental": -2}:
        fail(f"month-five spreadsheet course effects drifted: {d_growth_effects}", errors)
    d_clinic_config = action_config(contract, "m5_employment_contract_clinic")
    d_clinic_effects = d_clinic_config.get("effects", {})
    if d_clinic_effects != {"intelligence": 1, "mental": 1}:
        fail(f"month-five contract clinic effects drifted: {d_clinic_effects}", errors)
    d_recovery_config = action_config(contract, "m5_last_empty_sunday")
    d_recovery_effects = d_recovery_config.get("effects", {})
    d_recovery_diminished = d_recovery_config.get("recovery_routine_effects", {})
    if d_recovery_effects != {"health": 5, "mental": 7}:
        fail(f"month-five full recovery drifted: {d_recovery_effects}", errors)
    if d_recovery_diminished != {"health": 2, "mental": 3}:
        fail(
            f"month-five diminished recovery drifted: {d_recovery_diminished}",
            errors,
        )

    recovery_config = action_config(contract, "m3_empty_saturday")
    if str(recovery_config.get("execution", "")) != "rest":
        fail("month-three empty Saturday is not a rest execution", errors)
    full_recovery = recovery_config.get("effects", {})
    diminished_recovery = recovery_config.get("recovery_routine_effects", {})
    if not isinstance(full_recovery, dict):
        full_recovery = {}
    if not isinstance(diminished_recovery, dict):
        diminished_recovery = {}
    if full_recovery != {"health": 4, "mental": 6}:
        fail(f"full empty-Saturday recovery drifted: {full_recovery}", errors)
    if diminished_recovery != {"health": 2, "mental": 3}:
        fail(
            f"recovery-routine diminishing return drifted: "
            f"{diminished_recovery}",
            errors,
        )
    for stat in ("health", "mental"):
        full_value = int(full_recovery.get(stat, 0))
        diminished_value = int(diminished_recovery.get(stat, 0))
        if not 0 < diminished_value < full_value:
            fail(
                f"empty Saturday must have a positive diminishing {stat} "
                "return when recovery is already selected",
                errors,
            )

    arc_events = load_json(ARC_EVENTS_PATH)
    if not isinstance(arc_events, list):
        fail("arc event catalog must be a list", errors)
        arc_events = []
    all_events = load_event_catalog(errors)
    prologue_policies = resolve_fresh_prologue_policies(all_events, errors)
    authored_dirty_choice = dirty_choice(arc_events)
    if not authored_dirty_choice:
        fail("arc_temptation_01 has no lent_account money choice", errors)
        authored_dirty_choice = {"effects": {}, "flags": []}
    dirty_effects = authored_dirty_choice.get("effects", {})
    dirty_flags = authored_dirty_choice.get("flags", [])
    if not isinstance(dirty_effects, dict):
        dirty_effects = {}
    if not isinstance(dirty_flags, list):
        dirty_flags = []
    dirty_income = int(dirty_effects.get("money", 0))
    if dirty_income != 2_000_000:
        fail(
            f"dirty branch initial income drifted from KRW 2,000,000: "
            f"{dirty_income:,}",
            errors,
        )
    explicit_costs = {
        stat: int(dirty_effects.get(stat, 0))
        for stat in ("mental", "tint")
        if int(dirty_effects.get(stat, 0)) < 0
    }
    if "lent_account" not in dirty_flags:
        fail("dirty branch no longer records the lent_account consequence", errors)
    if not explicit_costs:
        fail("dirty branch has money but no explicit mental or moral cost", errors)

    dirty_before_fallout = simulate_legal(
        "dirty_before_fallout", ("growth", "livelihood"), options, B_WEEKS
    )
    dirty_before_fallout.apply_effects(dirty_effects)
    dirty_before_fallout.flags.update(str(flag) for flag in dirty_flags)
    if dirty_before_fallout.cash != 1_690_000:
        fail(
            "dirty branch must hold KRW 1,690,000 before the authored fallout, "
            f"got {dirty_before_fallout.cash:,}",
            errors,
        )

    fallout = event_by_id(arc_events, "arc_temptation_fallout")
    escaped_choice = choice_with_flag(fallout, "escaped_dirty_money")
    deeper_choice = choice_with_flag(fallout, "fell_to_darkness")
    escaped_effects = escaped_choice.get("effects", {})
    deeper_effects = deeper_choice.get("effects", {})
    if not isinstance(escaped_effects, dict):
        escaped_effects = {}
    if not isinstance(deeper_effects, dict):
        deeper_effects = {}
    if int(escaped_effects.get("money", 0)) != -1_500_000:
        fail("dirty-money exit must return exactly KRW 1,500,000", errors)
    if int(deeper_effects.get("money", 0)) != 3_000_000:
        fail("deeper dirty-money branch must add exactly KRW 3,000,000", errors)

    dirty_escaped = simulate_legal(
        "dirty_escaped", ("growth", "livelihood"), options, B_WEEKS
    )
    dirty_escaped.apply_effects(dirty_effects)
    dirty_escaped.apply_effects(escaped_effects)
    if dirty_escaped.cash != 190_000:
        fail(
            "returning KRW 1,500,000 of the received KRW 2,000,000 must leave "
            f"the twelve-week ledger at KRW 190,000, got {dirty_escaped.cash:,}",
            errors,
        )

    dirty_deeper = simulate_legal(
        "dirty_deeper", ("growth", "livelihood"), options, B_WEEKS
    )
    dirty_deeper.apply_effects(dirty_effects)
    dirty_deeper.apply_effects(deeper_effects)
    if dirty_deeper.cash != 4_690_000:
        fail(
            "the deeper branch must leave the twelve-week ledger at "
            f"KRW 4,690,000, got {dirty_deeper.cash:,}",
            errors,
        )
    if dirty_escaped.cash <= legal_inventory.cash:
        fail(
            "even the returned dirty-money branch must remain temporarily "
            "ahead of the solvent legal inventory path",
            errors,
        )
    if dirty_deeper.cash <= dirty_escaped.cash:
        fail(
            "deeper dirty-money involvement is no longer the fastest branch",
            errors,
        )
    if 2_000_000 // MONTHLY_FIXED_COST != 3:
        fail("KRW 2,000,000 must equal three full KRW 650,000 rent payments", errors)

    survival_kernels = run_survival_kernels(
        options, arc_events, core_events, errors
    )
    paired_trace_lines, paired_verdict = run_paired_temptation_traces(
        contract, options, arc_events, core_events, all_events,
        prologue_policies, errors
    )
    kernel_final_mental = [
        int(ledger.monthly_snapshots[-1]["mental"])
        for ledger in survival_kernels.values()
        if ledger.monthly_snapshots
    ]
    kernel_final_health = [
        int(ledger.monthly_snapshots[-1]["health"])
        for ledger in survival_kernels.values()
        if ledger.monthly_snapshots
    ]
    dirty_return_cautious = survival_kernels.get(
        "livelihood+growth/dirty_return/cautious"
    )
    dirty_return_mental = (
        "/".join(
            str(int(row["mental"]))
            for row in dirty_return_cautious.monthly_snapshots
        )
        if dirty_return_cautious is not None
        else "missing"
    )

    if errors:
        for message in errors:
            print(f"ERROR core loop v2 balance: {message}")
        return 1

    for line in paired_trace_lines:
        print(line)

    print(
        "core_loop_v2_balance_ok "
        f"a1_cash={a1_livelihood.cash} "
        f"b_no_shift_cash={b_no_shift_livelihood.cash} "
        f"b_arrears={max(0, -b_no_shift_livelihood.cash)} "
        f"inventory_cash={legal_inventory.cash} "
        f"c_no_shift_cash={c_no_shifts.cash} "
        f"c_late_shift_cash={c_late_shift_only.cash} "
        f"c_two_shift_cash={c_two_shift_legal.cash} "
        f"d_no_shift_cash={d_no_shifts.cash} "
        f"d_late_shift_cash={d_late_shift_only.cash} "
        f"d_three_shift_cash={d_three_shift_legal.cash} "
        f"d_hired_cash={d_hired_legal.cash} "
        f"e_no_shift_cash={e_no_shifts.cash} "
        f"e_no_m3_shift_cash={e_no_month_three_shift.cash} "
        f"e_three_prior_shift_cash={e_three_prior_shifts.cash} "
        f"e_four_shift_cash={e_four_shift_legal.cash} "
        f"e_four_shift_urgent_cash={e_four_shifts_with_urgent.cash} "
        f"e_hired_cash={e_hired_legal.cash} "
        "retired_phone_purchase_cost=0 "
        f"dirty_before_fallout={dirty_before_fallout.cash} "
        f"dirty_escaped={dirty_escaped.cash} dirty_deeper={dirty_deeper.cash} "
        f"dirty_costs={explicit_costs} "
        f"b_routine_units={b_no_shift_growth.routine_units} "
        f"c_routine_units={c_no_shifts.routine_units} "
        f"d_routine_units={d_no_shifts.routine_units} "
        f"e_routine_units={e_no_shifts.routine_units} "
        f"recovery_diminished={diminished_recovery} "
        f"e_recovery_diminished={e_recovery_diminished} "
        f"survival_kernels={len(survival_kernels)} "
        f"kernel_mental={min(kernel_final_mental)}-{max(kernel_final_mental)} "
        f"kernel_health={min(kernel_final_health)}-{max(kernel_final_health)} "
        f"dirty_return_cautious_mental={dirty_return_mental} "
        f"paired_verdict={paired_verdict}"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
