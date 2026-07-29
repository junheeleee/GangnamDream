#!/usr/bin/env python3
"""Deterministic eight-week economy check for the Core Loop V2 A1 gate.

This is deliberately a small, auditable ledger rather than a probability
forecast. It proves that both legal routine pairs can pay the two prototype
months' fixed costs, and that the dirty-money branch is faster only because it
carries explicit authored costs.
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
PROTOTYPE_WEEKS = 8


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
    name: str, routine_pair: tuple[str, str], options: dict[str, Any]
) -> Ledger:
    ledger = Ledger(name=name)
    for _week in range(1, PROTOTYPE_WEEKS + 1):
        for routine_id in routine_pair:
            ledger.apply_effects(weekly_effects(options, routine_id))
            ledger.routine_units += 1
        if _week in {4, 8}:
            ledger.cash -= MONTHLY_FIXED_COST
    return ledger


def dirty_choice() -> dict[str, Any]:
    events = load_json(ARC_EVENTS_PATH)
    temptation = next(
        (
            row
            for row in events
            if isinstance(row, dict) and row.get("id") == "arc_temptation_01"
        ),
        {},
    )
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

    clean_livelihood = simulate_legal(
        "clean_livelihood", ("livelihood", "recovery"), options
    )
    clean_growth = simulate_legal(
        "clean_growth", ("growth", "livelihood"), options
    )
    legal_ledgers = (clean_livelihood, clean_growth)
    for ledger in legal_ledgers:
        if ledger.routine_units != PROTOTYPE_WEEKS * 2:
            fail(
                f"{ledger.name} executed {ledger.routine_units} routine units, "
                "expected 16",
                errors,
            )
        if ledger.cash < 0:
            fail(
                f"{ledger.name} ended below zero cash: {ledger.cash:,}",
                errors,
            )
    if clean_livelihood.mental <= clean_growth.mental:
        fail(
            "recovery support no longer leaves more mental capacity than growth",
            errors,
        )
    if clean_growth.intelligence <= clean_livelihood.intelligence:
        fail(
            "growth support no longer produces a distinct skill advantage",
            errors,
        )

    authored_dirty_choice = dirty_choice()
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

    dirty = simulate_legal("dirty_fast_cash", ("growth", "livelihood"), options)
    dirty.apply_effects(dirty_effects)
    dirty.flags.update(str(flag) for flag in dirty_flags)
    if dirty.cash <= max(ledger.cash for ledger in legal_ledgers):
        fail(
            "dirty branch is not faster than the strongest legal prototype path",
            errors,
        )

    if errors:
        for message in errors:
            print(f"ERROR core loop v2 balance: {message}")
        return 1

    print(
        "core_loop_v2_balance_ok "
        f"clean_livelihood_cash={clean_livelihood.cash} "
        f"clean_growth_cash={clean_growth.cash} "
        f"dirty_cash={dirty.cash} dirty_costs={explicit_costs} "
        f"routine_units={clean_growth.routine_units}"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
