#!/usr/bin/env python3
"""Enumerate M01..M06 commitments and reject dominant shortcuts."""

from __future__ import annotations

import argparse
import copy
import json
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Mapping, Sequence

ROOT = Path(__file__).resolve().parents[1]
MAP_PATH = ROOT / "content" / "meta" / "story_map.json"
MONTHS = tuple(range(1, 7))
AXES = ("cash", "health", "trust")
SOURCES = ("pressure", "opportunity", "person_promise")

EXPECTED_OPTIONAL_SECOND = {
    "maximum": 1,
    "margin_axes": list(AXES),
    "margin_capacity": 1,
    "initial_margin": None,
    "margin_lifetime_months": 1,
    "requires": "same_axis_margin",
    "consumes": "on_confirm",
    "completion_refund": False,
    "single_protected_completion": "next_month_same_axis_margin_unless_selected_repaid_burden",
    "double_month_next_margin": None,
}

class StrategyError(RuntimeError): pass
def reject(message: str) -> None:
    raise StrategyError(message)


def require(condition: bool, message: str) -> None:
    if not condition: reject(message)
def _pairs_hook(pairs: list[tuple[str, Any]]) -> dict[str, Any]:
    result: dict[str, Any] = {}
    for key, value in pairs:
        if key in result:
            reject(f"duplicate JSON key: {key}")
        result[key] = value
    return result
def load_map(path: Path = MAP_PATH) -> dict[str, Any]:
    try:
        with path.open(encoding="utf-8") as handle:
            value = json.load(handle, object_pairs_hook=_pairs_hook)
    except (OSError, json.JSONDecodeError) as exc:
        reject(f"cannot read story map: {exc}")
    require(isinstance(value, dict), "story map root must be an object")
    return value
def exact_keys(value: Any, keys: set[str], where: str) -> Mapping[str, Any]:
    require(isinstance(value, dict), f"{where} must be an object")
    actual = set(value)
    require(
        actual == keys,
        f"{where} fields must be exactly {sorted(keys)}; got {sorted(actual)}",
    )
    return value


def string(value: Any, where: str) -> str:
    require(isinstance(value, str) and bool(value.strip()), f"{where} must be text")
    return value


def string_list(value: Any, where: str) -> tuple[str, ...]:
    require(isinstance(value, list), f"{where} must be a list")
    result = tuple(string(item, f"{where}[]") for item in value)
    require(len(result) == len(set(result)), f"{where} must not contain duplicates")
    return result


@dataclass(frozen=True)
class Focus:
    kind: str
    actor_slot: str
    sources: tuple[tuple[str, str], ...] = ()
    source_receipt_id: str | None = None


@dataclass(frozen=True)
class Strategy:
    gains: tuple[str, ...]
    costs: tuple[str, ...]
    deferred_to: str | None
    availability: tuple[tuple[str, tuple[str, ...]], ...]
    repays_deferred: tuple[str, ...]
    repays_pressure: tuple[str, ...]
    focus: Focus | None


@dataclass(frozen=True)
class Card:
    id: str
    month: int
    source: str
    axis: str
    miss: str
    available_values: tuple[str, ...] | None
    strategy: Strategy


@dataclass(frozen=True)
class Step:
    month: int
    primary: str
    optional: str | None
    margin_before: str | None
    margin_after: str | None


@dataclass(frozen=True)
class State:
    receipts: tuple[tuple[str, str], ...] = ()
    costs: frozenset[str] = frozenset()
    gains: frozenset[str] = frozenset()
    open_debts: frozenset[str] = frozenset()
    margin: str | None = None
    source_counts: tuple[int, int, int] = (0, 0, 0)
    optional_count: int = 0
    plan: tuple[Step, ...] = ()

def month_map(data: Mapping[str, Any]) -> dict[int, Mapping[str, Any]]:
    chapters = data.get("chapters")
    require(isinstance(chapters, list), "chapters must be a list")
    result: dict[int, Mapping[str, Any]] = {}
    for chapter in chapters:
        require(isinstance(chapter, dict), "chapter must be an object")
        months = chapter.get("months")
        require(isinstance(months, list), "chapter.months must be a list")
        for month in months:
            require(isinstance(month, dict), "month must be an object")
            number = month.get("month")
            require(isinstance(number, int), "month.month must be an integer")
            require(number not in result, f"duplicate M{number:02}")
            result[number] = month
    require(all(number in result for number in MONTHS), "story map must contain M01..M06")
    return result


def parse_strategy(raw: Any, card_id: str) -> Strategy:
    where = f"{card_id}.strategy"
    require(isinstance(raw, dict), f"{where} must be an object")
    allowed = {"completed", "missed", "availability", "repays_deferred", "repays_pressure", "focus"}
    required = {"completed", "missed"}
    require(required <= set(raw) <= allowed, f"{where} has invalid fields")

    completed = exact_keys(raw["completed"], {"preview", "gains"}, f"{where}.completed")
    string(completed["preview"], f"{where}.completed.preview")
    gains = string_list(completed["gains"], f"{where}.completed.gains")
    require(bool(gains), f"{where}.completed.gains must not be empty")
    require(all(item.split(".", 1)[0] in {"security", "connection", "upside"}
                for item in gains), f"{where}.completed.gains has an invalid token")

    missed = exact_keys(
        raw["missed"],
        {"preview", "costs", "deferred_to"},
        f"{where}.missed",
    )
    string(missed["preview"], f"{where}.missed.preview")
    costs = string_list(missed["costs"], f"{where}.missed.costs")
    require(bool(costs), f"{where}.missed.costs must not be empty")
    require(all(item.split(".", 1)[0] in {"pressure", "closed", "debt"}
                for item in costs), f"{where}.missed.costs has an invalid token")
    deferred_to = missed["deferred_to"]
    require(
        deferred_to is None or isinstance(deferred_to, str) and deferred_to,
        f"{where}.missed.deferred_to must be null or an id",
    )

    availability: tuple[tuple[str, tuple[str, ...]], ...] = ()
    if "availability" in raw:
        available = exact_keys(
            raw["availability"], {"receipts_any"}, f"{where}.availability"
        )
        conditions = available["receipts_any"]
        require(
            isinstance(conditions, list) and bool(conditions),
            f"{where}.availability.receipts_any must be a non-empty list",
        )
        parsed: list[tuple[str, tuple[str, ...]]] = []
        for index, condition in enumerate(conditions):
            condition = exact_keys(
                condition,
                {"id", "states"},
                f"{where}.availability.receipts_any[{index}]",
            )
            receipt_id = string(condition["id"], f"{where}.availability receipt id")
            states = string_list(condition["states"], f"{where}.availability states")
            require(bool(states), f"{where}.availability states must not be empty")
            require(
                set(states) <= {"completed", "deferred"},
                f"{where}.availability states may only be completed/deferred",
            )
            parsed.append((receipt_id, states))
        require(
            len({item[0] for item in parsed}) == len(parsed),
            f"{where}.availability repeats a receipt id",
        )
        availability = tuple(parsed)

    repays: tuple[str, ...] = ()
    if "repays_deferred" in raw:
        repays = string_list(raw["repays_deferred"], f"{where}.repays_deferred")
        require(bool(repays), f"{where}.repays_deferred must not be empty")
    repays_pressure: tuple[str, ...] = ()
    if "repays_pressure" in raw:
        repays_pressure = string_list(raw["repays_pressure"], f"{where}.repays_pressure")
        require(bool(repays_pressure) and all(item.startswith("pressure.") for item in repays_pressure), f"{where}.repays_pressure must contain pressure tokens")
    focus: Focus | None = None
    if "focus" in raw:
        focus_raw = raw["focus"]
        require(isinstance(focus_raw, dict), f"{where}.focus must be an object")
        kind = focus_raw.get("kind")
        if kind == "selection_focus":
            focus_raw = exact_keys(focus_raw, {"kind", "actor_slot", "resolve", "sources"}, f"{where}.focus")
            require(focus_raw["resolve"] == "protected_then_optional", f"{where}.focus resolver is invalid")
            source_rows = focus_raw["sources"]
            require(isinstance(source_rows, list) and len(source_rows) == 2, f"{where}.focus needs two sources")
            sources = tuple((string(exact_keys(row, {"commitment_id", "actor_id"}, f"{where}.focus.sources[]")["commitment_id"], f"{where}.focus source"), string(row["actor_id"], f"{where}.focus actor")) for row in source_rows)
            require(len({row[0] for row in sources}) == 2 and len({row[1] for row in sources}) == 2, f"{where}.focus sources and actors must be unique")
            focus = Focus(kind, string(focus_raw["actor_slot"], f"{where}.focus.actor_slot"), sources)
        elif kind == "receipt_actor":
            focus_raw = exact_keys(focus_raw, {"kind", "actor_slot", "source_receipt_id"}, f"{where}.focus")
            focus = Focus(kind, string(focus_raw["actor_slot"], f"{where}.focus.actor_slot"), source_receipt_id=string(focus_raw["source_receipt_id"], f"{where}.focus.source_receipt_id"))
        else:
            reject(f"{where}.focus kind is invalid")
    return Strategy(
        gains=gains,
        costs=costs,
        deferred_to=deferred_to,
        availability=availability,
        repays_deferred=repays,
        repays_pressure=repays_pressure,
        focus=focus,
    )


def parse_cards(data: Mapping[str, Any]) -> tuple[dict[int, tuple[Card, ...]], dict[str, Card]]:
    months = month_map(data)
    by_month: dict[int, tuple[Card, ...]] = {}
    by_id: dict[str, Card] = {}
    for number in MONTHS:
        raw_cards = months[number].get("commitments")
        require(
            isinstance(raw_cards, list) and 2 <= len(raw_cards) <= 4,
            f"M{number:02}.commitments must contain 2..4 cards",
        )
        cards: list[Card] = []
        for raw in raw_cards:
            require(isinstance(raw, dict), f"M{number:02} commitment must be an object")
            card_id = string(raw.get("id"), f"M{number:02} commitment id")
            require(card_id not in by_id, f"duplicate commitment id: {card_id}")
            source = raw.get("source")
            axis = raw.get("axis")
            require(source in SOURCES, f"{card_id}.source is invalid")
            require(axis in AXES, f"{card_id}.axis is invalid")
            miss = raw.get("miss")
            require(miss in {"deferred", "expired"}, f"{card_id}.miss is invalid")
            strategy = parse_strategy(raw.get("strategy"), card_id)
            require((miss == "deferred") == (strategy.deferred_to is not None), f"{card_id}.miss and deferred_to disagree")
            require((raw.get("actor_slots") == [strategy.focus.actor_slot]) if strategy.focus else "actor_slots" not in raw, f"{card_id}.actor_slots must exactly match strategy focus")
            available_values = string_list(raw["available_values"], f"{card_id}.available_values") if "available_values" in raw else None
            card = Card(card_id, number, source, axis, miss, available_values, strategy)
            cards.append(card)
            by_id[card_id] = card
        by_month[number] = tuple(cards)
    return by_month, by_id


def validate_contract(data: Mapping[str, Any]) -> None:
    loop = data.get("loop_contract")
    require(isinstance(loop, dict), "loop_contract must be an object")
    optional = loop.get("optional_second")
    require(isinstance(optional, dict), "loop_contract.optional_second must be an object")
    require(
        set(optional) == set(EXPECTED_OPTIONAL_SECOND),
        "optional_second must have the exact strategy fields",
    )
    for key, expected in EXPECTED_OPTIONAL_SECOND.items():
        require(optional[key] == expected, f"optional_second.{key} must be {expected!r}")


def validate_links(by_month: Mapping[int, Sequence[Card]], by_id: Mapping[str, Card], months: Mapping[int, Mapping[str, Any]]) -> None:
    pressure_sources: dict[str, Card] = {}
    for cards in by_month.values():
        for card in cards:
            for token in card.strategy.costs:
                if not token.startswith("pressure."):
                    continue
                require(token not in pressure_sources, f"pressure {token} has multiple producers")
                pressure_sources[token] = card
    pressure_consumers: dict[str, Card] = {}
    for cards in by_month.values():
        for card in cards:
            strategy = card.strategy
            for receipt_id, _states in strategy.availability:
                require(receipt_id in by_id, f"{card.id} availability references unknown {receipt_id}")
                require(
                    by_id[receipt_id].month < card.month,
                    f"{card.id} availability must read an earlier receipt",
                )
            for source in strategy.repays_deferred:
                require(source in by_id, f"{card.id} repays unknown {source}")
                require(source in {item[0] for item in strategy.availability},
                        f"{card.id} repayment must be gated by its source receipt")
                states = dict(strategy.availability)[source]
                require("deferred" in states,
                        f"{card.id} repayment must allow {source}=deferred")
            for token in strategy.repays_pressure:
                require(token in pressure_sources, f"{card.id} repays unknown pressure {token}")
                require(pressure_sources[token].month + 1 == card.month, f"{card.id} must repay pressure from the previous month")
                require(token not in pressure_consumers, f"pressure {token} has multiple consumers")
                pressure_consumers[token] = card
            if strategy.focus is not None:
                focus = strategy.focus
                source_ids = [row[0] for row in focus.sources] if focus.kind == "selection_focus" else [focus.source_receipt_id]
                for source_id in source_ids:
                    require(source_id in by_id and by_id[source_id].month < card.month, f"{card.id} focus must read an earlier commitment")
                if focus.kind == "receipt_actor":
                    source_focus = by_id[focus.source_receipt_id].strategy.focus
                    require(source_focus is not None and source_focus.actor_slot == focus.actor_slot, f"{card.id} focus source must produce the same actor slot")
                    require(strategy.availability == ((focus.source_receipt_id, ("completed", "deferred")),), f"{card.id} receipt actor availability must exactly match its source")
                else:
                    expected_availability = tuple((source_id, ("completed",)) for source_id, _actor_id in focus.sources)
                    actor_values = tuple(actor_id for _source_id, actor_id in focus.sources)
                    require(strategy.availability == expected_availability, f"{card.id} selection focus availability must exactly match its sources")
                    require(card.available_values == actor_values, f"{card.id} available_values must exactly match its focus actors")
                    month_availability = months[card.month].get("availability")
                    require(isinstance(month_availability, dict) and tuple(month_availability.get("values", ())) == ("none",) + actor_values, f"M{card.month:02} availability must be none plus exact focus actors")

            target_id = strategy.deferred_to
            if target_id is None:
                continue
            require(target_id in by_id, f"{card.id} defers to unknown {target_id}")
            target = by_id[target_id]
            require(
                target.month == card.month + 1,
                f"{card.id} deferred target must be in the next month",
            )
            require(
                card.id in target.strategy.repays_deferred,
                f"{target.id} must repay deferred {card.id}",
            )
            require(
                target.strategy.deferred_to is None,
                f"{target.id} may not defer again (infinite defer)",
            )
    require(set(pressure_sources) == set(pressure_consumers), "every M01..M05 pressure token needs one next-month consumer")


def prepare(data: Mapping[str, Any]) -> tuple[dict[int, tuple[Card, ...]], dict[str, Card]]:
    validate_contract(data)
    by_month, by_id = parse_cards(data)
    validate_links(by_month, by_id, month_map(data))
    return by_month, by_id


def is_available(card: Card, receipts: Mapping[str, str]) -> bool:
    conditions = card.strategy.availability
    if not conditions:
        return True
    return any(receipts.get(receipt_id) in states for receipt_id, states in conditions)


def validate_roles(state: State, primary: Card, optional: Card | None) -> None:
    if optional is None:
        return
    require(optional.id != primary.id, "primary and optional must be different cards")
    require(state.margin is not None, "optional commitment requires current margin")
    require(
        optional.axis == state.margin,
        f"optional axis mismatch: {optional.axis} cannot spend {state.margin} margin",
    )


def _resolve(
    state: State,
    month: int,
    available: Sequence[Card],
    by_id: Mapping[str, Card],
    primary: Card,
    optional: Card | None,
    confirm_order: tuple[str, ...],
    *,
    inject_order_bug: bool = False,
) -> State:
    validate_roles(state, primary, optional)
    expected = {primary.id} | ({optional.id} if optional else set())
    require(set(confirm_order) == expected and len(confirm_order) == len(expected),
            "confirm order must contain each selected role once")

    remaining_margin = state.margin
    for clicked in confirm_order:
        if optional is not None and clicked == optional.id:
            require(remaining_margin == optional.axis,
                    "optional confirmation did not consume same-axis margin")
            remaining_margin = None

    selected = (primary,) if optional is None else (primary, optional)
    selected_ids = {card.id for card in selected}
    receipts = dict(state.receipts)
    costs = set(state.costs)
    gains = set(state.gains)
    debts = set(state.open_debts)
    counts = list(state.source_counts)

    for card in available:
        if card.id in selected_ids:
            receipts[card.id] = "completed"
            gains.update(card.strategy.gains)
            counts[SOURCES.index(card.source)] += 1
            for repaid in card.strategy.repays_deferred:
                if repaid in debts:
                    debts.discard(repaid)
                    costs.difference_update(
                        token for token in by_id[repaid].strategy.costs
                        if token.startswith("debt.")
                    )
            for pressure in card.strategy.repays_pressure:
                costs.discard(pressure)
            continue

        missed = card.strategy
        costs.update(missed.costs)
        if missed.deferred_to is not None:
            receipts[card.id] = "deferred"
            debts.add(card.id)
        else:
            receipts[card.id] = "expired"
            for repaid in missed.repays_deferred:
                if repaid in debts:
                    debts.discard(repaid)
                    costs.difference_update(
                        token for token in by_id[repaid].strategy.costs
                        if token.startswith("debt.")
                    )

    next_margin: str | None = None
    if optional is None:
        repays_burden = bool(set(primary.strategy.repays_deferred) & state.open_debts) or bool(set(primary.strategy.repays_pressure) & state.costs)
        if not repays_burden:
            next_margin = primary.axis

    if inject_order_bug and optional is not None and confirm_order[0] == primary.id:
        costs.add("closed.__injected_click_order_bug__")

    step = Step(month, primary.id, optional.id if optional else None,
                state.margin, next_margin)
    return State(
        receipts=tuple(sorted(receipts.items())),
        costs=frozenset(costs),
        gains=frozenset(gains),
        open_debts=frozenset(debts),
        margin=next_margin,
        source_counts=tuple(counts),
        optional_count=state.optional_count + int(optional is not None),
        plan=state.plan + (step,),
    )


def comparable(state: State) -> tuple[Any, ...]:
    return (
        state.receipts,
        state.costs,
        state.gains,
        state.open_debts,
        state.margin,
        state.source_counts,
        state.optional_count,
    )


def focus_actor(card: Card, state: State, by_id: Mapping[str, Card]) -> str:
    focus = card.strategy.focus
    require(focus is not None, f"{card.id} has no actor focus")
    if focus.kind == "receipt_actor":
        return focus_actor(by_id[focus.source_receipt_id], state, by_id)
    source_map = dict(focus.sources)
    source_months = {by_id[source_id].month for source_id in source_map}
    require(len(source_months) == 1, f"{card.id} focus sources must share one month")
    step = state.plan[next(iter(source_months)) - 1]
    for selected in (step.primary, step.optional):
        if selected in source_map: return source_map[selected]
    reject(f"{card.id} focus has no selected source")


def enumerate_paths(
    by_month: Mapping[int, Sequence[Card]],
    by_id: Mapping[str, Card],
    *,
    inject_order_bug: bool = False,
) -> tuple[list[State], dict[str, int]]:
    states = [State()]
    evidence = {
        "click_order_pairs": 0,
        "axis_mismatch_rejections": 0,
        "health_primary": 0,
        "health_optional": 0,
    }
    for month in MONTHS:
        next_states: list[State] = []
        for state in states:
            receipts = dict(state.receipts)
            available = tuple(card for card in by_month[month] if is_available(card, receipts))
            require(len(available) >= 2, f"M{month:02} path exposes fewer than two cards")

            if state.margin is not None:
                for primary in available:
                    for candidate in available:
                        if candidate.id == primary.id or candidate.axis == state.margin:
                            continue
                        try:
                            validate_roles(state, primary, candidate)
                        except StrategyError as exc:
                            require("axis mismatch" in str(exc),
                                    "axis mismatch was rejected for the wrong reason")
                            evidence["axis_mismatch_rejections"] += 1
                        else:
                            reject("axis mismatch optional commitment was accepted")

            for primary in available:
                optional_cards: tuple[Card | None, ...] = (None,)
                if state.margin is not None:
                    optional_cards += tuple(
                        card for card in available
                        if card.id != primary.id and card.axis == state.margin
                    )
                for optional in optional_cards:
                    order_a = (primary.id,) if optional is None else (primary.id, optional.id)
                    result_a = _resolve(
                        state, month, available, by_id, primary, optional, order_a,
                        inject_order_bug=inject_order_bug,
                    )
                    if optional is not None:
                        order_b = (optional.id, primary.id)
                        result_b = _resolve(
                            state, month, available, by_id, primary, optional, order_b,
                            inject_order_bug=inject_order_bug,
                        )
                        require(
                            comparable(result_a) == comparable(result_b),
                            f"click order changes result in M{month:02}: "
                            f"{primary.id} + {optional.id}",
                        )
                        evidence["click_order_pairs"] += 1
                    if month == 6 and primary.id == "m06_family_signal":
                        evidence["health_primary"] += 1
                    if month == 6 and optional is not None and optional.id == "m06_family_signal":
                        evidence["health_optional"] += 1
                    next_states.append(result_a)
        states = next_states
    return states, evidence


def outcome_signature(state: State) -> tuple[int, ...]:
    gains = tuple(sum(token.startswith(prefix) for token in state.gains)
                  for prefix in ("security.", "connection.", "upside."))
    costs = tuple(-sum(token.startswith(prefix) for token in state.costs)
                  for prefix in ("pressure.", "closed.", "debt."))
    return gains + costs
def pareto_signatures(states: Sequence[State]) -> set[tuple[int, ...]]:
    signatures = {outcome_signature(state) for state in states}
    result: set[tuple[int, ...]] = set()
    for candidate in signatures:
        dominated = any(
            other != candidate
            and all(left >= right for left, right in zip(other, candidate))
            for other in signatures
        )
        if not dominated:
            result.add(candidate)
    return result


def assert_policy_frontiers(states: Sequence[State], by_month: Mapping[int, Sequence[Card]], by_id: Mapping[str, Card], full: set[tuple[int, ...]]) -> None:
    def available(state: State, month: int) -> tuple[Card, ...]:
        receipts = dict(state.receipts)
        return tuple(card for card in by_month[month] if is_available(card, receipts))
    def always_cash(state: State) -> bool:
        return all(not any(card.axis == "cash" for card in available(state, step.month)) or by_id[step.primary].axis == "cash" for step in state.plan)
    def always_optional(state: State) -> bool:
        for step in state.plan:
            legal = step.margin_before is not None and any(card.id != step.primary and card.axis == step.margin_before for card in available(state, step.month))
            if legal != (step.optional is not None): return False
        return True
    def one_axis(state: State, axis: str) -> bool:
        return all(by_id[card_id].axis == axis for step in state.plan for card_id in (step.primary, step.optional) if card_id)
    def expired_first(state: State) -> bool:
        return all(not any(card.miss == "expired" for card in available(state, step.month)) or by_id[step.primary].miss == "expired" for step in state.plan)
    policies = {"always_cash": always_cash, "always_optional": always_optional, "cash_only": lambda state: one_axis(state, "cash"), "trust_only": lambda state: one_axis(state, "trust"), "expired_first": expired_first}
    for name, predicate in policies.items():
        restricted = [state for state in states if predicate(state)]
        require(bool(restricted), f"policy {name} has no legal path")
        frontier = pareto_signatures(restricted)
        require(frontier != full, f"policy {name} reproduces the unrestricted frontier")
        covers_full = all(any(all(left >= right for left, right in zip(candidate, target)) for candidate in frontier) for target in full)
        require(not covers_full, f"policy {name} dominates the unrestricted frontier")


def assert_sample_invariants(
    states: Sequence[State],
    evidence: Mapping[str, int],
    by_month: Mapping[int, Sequence[Card]],
    by_id: Mapping[str, Card],
) -> set[tuple[int, ...]]:
    require(bool(states), "M01..M06 has no legal complete path")
    require(evidence["click_order_pairs"] > 0, "no optional pair tested click order")
    require(evidence["axis_mismatch_rejections"] > 0, "no axis mismatch was rejected")
    require(all(step.optional is None for state in states for step in state.plan[:1]),
            "M01 optional commitment must be impossible")
    require(max(state.optional_count for state in states) <= 3,
            "a six-month path uses more than three optional commitments")
    for state in states:
        used = [step.month for step in state.plan if step.optional is not None]
        require(all(right - left > 1 for left, right in zip(used, used[1:])),
                "optional commitments occur in consecutive months")

    require("m06_family_signal" in by_id, "M06 health card is missing")
    require(by_id["m06_family_signal"].axis == "health", "M06 family signal must be health")
    require(evidence["health_primary"] > 0, "M06 health card is never available as primary")
    require(evidence["health_optional"] == 0, "M06 health card was used as optional")

    father = by_id.get("m01_father_call")
    father_return = by_id.get("m02_return_father_call")
    require(father is not None and father_return is not None, "father defer cards are missing")
    require(father.strategy.deferred_to == father_return.id,
            "father call must return exactly once in M02")
    require(father.id in father_return.strategy.repays_deferred,
            "father return must repay the M01 defer")
    require(father_return.strategy.deferred_to is None,
            "father return must expire on its second miss")
    father_selected = father_deferred = father_returned = father_expired = False
    for state in states:
        receipts = dict(state.receipts)
        father_selected |= receipts.get(father.id) == "completed"
        father_deferred |= receipts.get(father.id) == "deferred"
        father_returned |= receipts.get(father_return.id) == "completed"
        father_expired |= receipts.get(father_return.id) == "expired"
        if receipts.get(father.id) == "completed":
            require(father_return.id not in receipts,
                    "father return appeared without an M01 defer")
    require(all((father_selected, father_deferred, father_returned, father_expired)),
            "father defer/return/expiry branches were not all enumerated")

    duo_seen = False
    duo_actors: set[str] = set()
    m05_focus = by_id.get("m05_second_crossing")
    m06_focus = by_id.get("m06_person_date")
    require(m05_focus is not None and m06_focus is not None, "M05/M06 relationship focus cards are missing")
    for state in states:
        step3 = state.plan[2]
        selected3 = {step3.primary, step3.optional}
        if {"m03_daeun_return", "m03_jiyeon_answer"} <= selected3:
            duo_seen = True
            require(step3.margin_before == "trust",
                    "M03 Daeun+Jiyeon did not spend trust margin")
            require(step3.margin_after is None,
                    "M03 Daeun+Jiyeon incorrectly created M04 margin")
            require(state.plan[3].margin_before is None,
                    "M04 retained margin after M03 Daeun+Jiyeon")
            actor = focus_actor(m05_focus, state, by_id)
            require(actor == focus_actor(m06_focus, state, by_id), "M06 relationship actor changed after M05")
            require(actor == ("daeun" if step3.primary == "m03_daeun_return" else "jiyeon"), "M03 protected role did not choose the M05 actor")
            duo_actors.add(actor)
    require(duo_seen, "M03 Daeun+Jiyeon double plan is unreachable")
    require(duo_actors == {"daeun", "jiyeon"}, "M03 primary-role swap must change the focused actor")

    pareto = pareto_signatures(states)
    require(len(pareto) >= 3,
            f"need at least three Pareto source signatures; got {sorted(pareto)}")
    outcomes = {outcome_signature(state) for state in states}
    maxima = tuple(max(signature[index] for signature in outcomes) for index in range(6))
    require(maxima not in outcomes, f"one outcome maximizes every benefit and cost axis: {maxima}")
    assert_policy_frontiers(states, by_month, by_id, pareto)
    frontier_m01 = {state.plan[0].primary for state in states if outcome_signature(state) in pareto}
    require(frontier_m01 == {card.id for card in by_month[1]}, "every M01 choice needs at least one non-dominated future")
    return pareto


def simulate(
    data: Mapping[str, Any],
    *,
    inject_order_bug: bool = False,
) -> tuple[list[State], set[tuple[int, ...]], dict[str, int]]:
    by_month, by_id = prepare(data)
    states, evidence = enumerate_paths(
        by_month, by_id, inject_order_bug=inject_order_bug
    )
    pareto = assert_sample_invariants(states, evidence, by_month, by_id)
    return states, pareto, evidence


def representative_plans(
    states: Sequence[State], pareto: set[tuple[int, ...]]
) -> list[tuple[str, State]]:
    candidates = [state for state in states if outcome_signature(state) in pareto]
    labels = (("security", 0), ("connection", 1), ("upside", 2))
    chosen: list[tuple[str, State]] = []
    used_plans: set[tuple[Step, ...]] = set()
    for label, focus in labels:
        ranked = sorted(
            candidates,
            key=lambda state: (
                -sum(token.startswith(f"{label}.") for token in state.gains),
                -outcome_signature(state)[focus],
                sum(token.startswith("pressure.") for token in state.costs),
                sum(token.startswith("closed.") for token in state.costs),
                state.optional_count,
                tuple((step.primary, step.optional or "") for step in state.plan),
            ),
        )
        pick = next((state for state in ranked if state.plan not in used_plans), ranked[0])
        used_plans.add(pick.plan)
        chosen.append((label, pick))
    return chosen


def format_plan(label: str, state: State) -> str:
    steps = " ".join(
        f"M{step.month:02}:{step.primary}"
        + (f"+{step.optional}" if step.optional else "")
        for step in state.plan
    )
    p, o, person = state.source_counts
    pressure = sum(token.startswith("pressure.") for token in state.costs)
    closed = sum(token.startswith("closed.") for token in state.costs)
    debt = sum(token.startswith("debt.") for token in state.costs)
    security, connection, upside = outcome_signature(state)[:3]
    return (
        f"PLAN {label} gains=S{security}/C{connection}/U{upside} sources=P{p}/O{o}/R{person} "
        f"costs=pressure:{pressure}/closed:{closed}/debt:{debt} :: {steps}"
    )


def find_card(data: Mapping[str, Any], card_id: str) -> Mapping[str, Any]:
    for month in month_map(data).values():
        for card in month["commitments"]:
            if card.get("id") == card_id:
                return card
    reject(f"self-test cannot find {card_id}")


def expect_failure(label: str, function: Any, needle: str) -> None:
    try:
        function()
    except StrategyError as exc:
        require(needle in str(exc), f"self-test {label} failed for wrong reason: {exc}")
    else:
        reject(f"self-test mutation survived: {label}")


def self_test(data: Mapping[str, Any]) -> int:
    simulate(data)
    cases = 0

    mutated = copy.deepcopy(data)
    mutated["loop_contract"]["optional_second"]["requires"] = "any_axis_margin"
    expect_failure("any-axis", lambda: simulate(mutated), "optional_second.requires")
    cases += 1

    mutated = copy.deepcopy(data)
    mutated["loop_contract"]["optional_second"]["completion_refund"] = True
    expect_failure("completion-refund", lambda: simulate(mutated), "completion_refund")
    cases += 1

    mutated = copy.deepcopy(data)
    mutated["loop_contract"]["optional_second"]["double_month_next_margin"] = "cash"
    expect_failure("double-margin", lambda: simulate(mutated), "double_month_next_margin")
    cases += 1

    mutated = copy.deepcopy(data)
    father_return = find_card(mutated, "m02_return_father_call")
    father_return["strategy"]["missed"]["deferred_to"] = "m03_daeun_return"
    expect_failure("second-defer", lambda: simulate(mutated), "miss and deferred_to disagree")
    cases += 1

    expect_failure(
        "click-order-detector",
        lambda: simulate(data, inject_order_bug=True),
        "click order changes result",
    )
    cases += 1

    mutated = copy.deepcopy(data)
    first = find_card(mutated, "m01_survival_shift")
    first["strategy"]["completed"]["gains"] = {"not": "a list"}
    expect_failure("invalid-schema", lambda: simulate(mutated), "gains must be a list")
    cases += 1

    mutated = copy.deepcopy(data)
    find_card(mutated, "m02_close_account_risk")["strategy"].pop("repays_pressure")
    expect_failure("orphan-pressure", lambda: simulate(mutated), "needs one next-month consumer")
    cases += 1

    mutated = copy.deepcopy(data)
    find_card(mutated, "m01_legal_application")["strategy"]["missed"]["costs"].append("pressure.m02_cash_shortfall")
    expect_failure("duplicate-pressure-producer", lambda: simulate(mutated), "has multiple producers")
    cases += 1

    mutated = copy.deepcopy(data)
    find_card(mutated, "m06_person_date")["strategy"]["focus"]["source_receipt_id"] = "m04_sangchul_office_coffee"
    expect_failure("relationship-actor-chain", lambda: simulate(mutated), "must produce the same actor slot")
    cases += 1

    mutated = copy.deepcopy(data)
    find_card(mutated, "m05_second_crossing")["strategy"].pop("availability")
    expect_failure("focus-availability-missing", lambda: simulate(mutated), "selection focus availability must exactly match")
    cases += 1

    mutated = copy.deepcopy(data)
    find_card(mutated, "m05_second_crossing")["strategy"]["availability"]["receipts_any"].pop()
    expect_failure("focus-source-missing", lambda: simulate(mutated), "selection focus availability must exactly match")
    cases += 1

    mutated = copy.deepcopy(data)
    find_card(mutated, "m05_second_crossing")["available_values"].append("both")
    month_map(mutated)[5]["availability"]["values"].append("both")
    expect_failure("focus-both-reintroduced", lambda: simulate(mutated), "available_values must exactly match")
    cases += 1

    require(pareto_signatures([State(gains=frozenset({"security.a"})), State(gains=frozenset({"security.a", "connection.b"}))]) == {(1, 1, 0, 0, 0, 0)}, "semantic dominance check failed")
    cases += 1

    print(f"STORY_MAP_STRATEGY_SELF_TEST_OK cases={cases}")
    return 0


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args(argv)
    try:
        data = load_map()
        if args.self_test:
            return self_test(data)
        states, pareto, evidence = simulate(data)
        for label, state in representative_plans(states, pareto):
            print(format_plan(label, state))
        print(
            "STORY_MAP_STRATEGY_OK "
            f"paths={len(states)} pareto_outcomes={len(pareto)} "
            f"click_pairs={evidence['click_order_pairs']} "
            f"axis_mismatch_rejections={evidence['axis_mismatch_rejections']} "
            f"max_optional={max(state.optional_count for state in states)} policies=5"
        )
        return 0
    except StrategyError as exc:
        print(f"STORY_MAP_STRATEGY_FAIL {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
