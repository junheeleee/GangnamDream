#!/usr/bin/env python3
"""Deterministic twenty-four-week economy check for the Core Loop V2 E gate.

This is deliberately a small, auditable ledger rather than a probability
forecast. It preserves the eight-week A1 result, demonstrates the deliberate
month-three cash pressure and twelve-week B result, proves the two authored
legal shifts can keep a sixteen-week livelihood path solvent, proves the
month-five moving shift still leaves missed work visible, verifies the first
legal job payoff, then closes Month Six with the holiday shift, the Week-24
urgent-work option, one salary, and one fixed-cost charge. It also distinguishes
arrears from global bankruptcy and checks both authored dirty-money exits.
"""

from __future__ import annotations

import json
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
CONTRACT_PATH = ROOT / "content" / "meta" / "demo_core_loop_v2.json"
ARC_EVENTS_PATH = ROOT / "content" / "events" / "arc_events.json"
CORE_LOOP_EVENTS_PATH = ROOT / "content" / "events" / "core_loop_v2_events.json"
JOBS_PATH = ROOT / "content" / "jobs.json"
GAME_STATE_PATH = ROOT / "autoloads" / "GameState.gd"

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

# These are branch-only kernels, not claims about arbitrary full routes. They
# include the two background routines, the authored Week-4/8 temptation branch,
# the universal Week-21 Father signal, the branch-owned Week-24 callback, the
# Week-24 First Bill choice, and all six real monthly-pressure settlements. They
# deliberately exclude optional foreground actions, decline outcomes, loans,
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
    """Small deterministic mirror for the 24-week branch-only kernel."""

    name: str
    cash: int = STARTING_CASH + OPENING_SURVIVAL_BUFFER
    health: int = STARTING_HEALTH
    mental: int = STARTING_MENTAL
    intelligence: int = 0
    work_performance: int = 0
    routine_units: int = 0
    death_week: int = 0
    monthly_snapshots: list[dict[str, Any]] = field(default_factory=list)

    def apply_effects(self, effects: dict[str, Any]) -> None:
        for stat, raw_value in effects.items():
            value = int(raw_value)
            if stat == "money":
                self.cash += value
            elif hasattr(self, stat):
                setattr(self, stat, int(getattr(self, stat)) + value)
        self.health = max(0, min(100, self.health))
        self.mental = max(0, min(100, self.mental))

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
            "reserve_band": reserve_band,
        })


def fail(message: str, errors: list[str]) -> None:
    errors.append(message)


def load_json(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8"))


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


def validate_runtime_monthly_pressure(errors: list[str]) -> None:
    """Keep the deterministic mirror tied to GameState's live constants."""

    source = GAME_STATE_PATH.read_text(encoding="utf-8")
    reality_pattern = re.compile(
        r'"현실"\s*:\s*\{.*?"pressure_health"\s*:\s*-2\s*,\s*'
        r'"pressure_mental"\s*:\s*-3',
        re.DOTALL,
    )
    if not reality_pattern.search(source):
        fail("reality monthly pressure drifted from health -2 / mental -3", errors)

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
        f"dirty_return_cautious_mental={dirty_return_mental}"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
