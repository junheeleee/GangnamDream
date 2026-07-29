#!/usr/bin/env python3
"""Deterministic twelve-week economy check for the Core Loop V2 B gate.

This is deliberately a small, auditable ledger rather than a probability
forecast. It preserves the eight-week A1 result, demonstrates the deliberate
month-three cash pressure, proves the four-night legal shift can keep a
livelihood path solvent, distinguishes arrears from global bankruptcy, and
checks both authored exits from the dirty-money branch.
"""

from __future__ import annotations

import json
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
CONTRACT_PATH = ROOT / "content" / "meta" / "demo_core_loop_v2.json"
ARC_EVENTS_PATH = ROOT / "content" / "events" / "arc_events.json"

STARTING_CASH = 500_000
OPENING_SURVIVAL_BUFFER = 300_000
MONTHLY_FIXED_COST = 650_000
A1_WEEKS = 8
DEVELOPMENT_WEEKS = 12


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


def main() -> int:
    errors: list[str] = []
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

    no_shift_livelihood = simulate_legal(
        "no_shift_livelihood", ("livelihood", "recovery"), options
    )
    no_shift_growth = simulate_legal(
        "no_shift_growth", ("growth", "livelihood"), options
    )
    pressure_ledgers = (no_shift_livelihood, no_shift_growth)
    for ledger in pressure_ledgers:
        if ledger.routine_units != DEVELOPMENT_WEEKS * 2:
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
    if no_shift_livelihood.mental <= no_shift_growth.mental:
        fail(
            "recovery support no longer leaves more mental capacity than growth",
            errors,
        )
    if no_shift_growth.intelligence <= no_shift_livelihood.intelligence:
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
        "legal_livelihood_inventory", ("livelihood", "recovery"), options
    )
    legal_inventory.apply_effects(inventory_effects)
    if legal_inventory.cash < 50_000:
        fail(
            f"livelihood plus inventory must end at or above KRW 50,000, "
            f"got {legal_inventory.cash:,}",
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
        "dirty_before_fallout", ("growth", "livelihood"), options
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
        "dirty_escaped", ("growth", "livelihood"), options
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
        "dirty_deeper", ("growth", "livelihood"), options
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

    if errors:
        for message in errors:
            print(f"ERROR core loop v2 balance: {message}")
        return 1

    print(
        "core_loop_v2_balance_ok "
        f"a1_cash={a1_livelihood.cash} "
        f"no_shift_cash={no_shift_livelihood.cash} "
        f"arrears={max(0, -no_shift_livelihood.cash)} "
        f"inventory_cash={legal_inventory.cash} "
        f"dirty_before_fallout={dirty_before_fallout.cash} "
        f"dirty_escaped={dirty_escaped.cash} dirty_deeper={dirty_deeper.cash} "
        f"dirty_costs={explicit_costs} "
        f"routine_units={no_shift_growth.routine_units} "
        f"recovery_diminished={diminished_recovery}"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
