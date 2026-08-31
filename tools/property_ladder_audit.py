#!/usr/bin/env python3
"""Fail-closed audit for the earned property investment ladder.

The ladder is deliberately routed by MainGame rather than the random-event
director.  This audit keeps its data guards, delayed outcomes, cash arithmetic,
failure closure, and the first-year instant ending aligned without executing
or mutating the game.
"""

from __future__ import annotations

import argparse
import copy
import json
import re
import sys
from dataclasses import dataclass
from decimal import Decimal, ROUND_HALF_UP
from pathlib import Path
from typing import Any, Callable


ROOT = Path(__file__).resolve().parents[1]
EVENTS_ROOT = ROOT / "content" / "events"
DIRECTOR_PATH = ROOT / "content" / "meta" / "event_director.json"
ENDINGS_PATH = ROOT / "content" / "endings.json"
MAIN_GAME_PATH = ROOT / "scenes" / "MainGame.gd"
GAME_STATE_PATH = ROOT / "autoloads" / "GameState.gd"


class AuditLoadError(ValueError):
    """Raised when an audited input cannot be loaded unambiguously."""


def _unique_object(pairs: list[tuple[str, Any]]) -> dict[str, Any]:
    result: dict[str, Any] = {}
    for key, value in pairs:
        if key in result:
            raise AuditLoadError(f"duplicate JSON key: {key}")
        result[key] = value
    return result


def _parse_json_text(text: str, label: str) -> Any:
    try:
        return json.loads(text, object_pairs_hook=_unique_object)
    except (json.JSONDecodeError, AuditLoadError) as exc:
        raise AuditLoadError(f"{label}: {exc}") from exc


def _load_json(path: Path, root_type: type) -> Any:
    try:
        text = path.read_text(encoding="utf-8")
    except OSError as exc:
        raise AuditLoadError(f"{path.relative_to(ROOT)}: {exc}") from exc
    value = _parse_json_text(text, str(path.relative_to(ROOT)))
    if not isinstance(value, root_type):
        raise AuditLoadError(
            f"{path.relative_to(ROOT)}: expected {root_type.__name__} root, "
            f"got {type(value).__name__}"
        )
    return value


def _load_source(path: Path) -> str:
    try:
        source = path.read_text(encoding="utf-8")
    except OSError as exc:
        raise AuditLoadError(f"{path.relative_to(ROOT)}: {exc}") from exc
    if not source.strip():
        raise AuditLoadError(f"{path.relative_to(ROOT)}: empty source")
    return source


@dataclass
class Corpus:
    events: dict[str, dict[str, Any]]
    event_owners: dict[str, str]
    director: dict[str, Any]
    endings: list[dict[str, Any]]
    main_source: str
    game_state_source: str


def load_corpus() -> Corpus:
    events: dict[str, dict[str, Any]] = {}
    event_owners: dict[str, str] = {}
    event_paths = sorted(EVENTS_ROOT.glob("*.json"))
    if not event_paths:
        raise AuditLoadError("content/events: no KO event JSON files")
    for path in event_paths:
        rows = _load_json(path, list)
        owner = str(path.relative_to(ROOT))
        for index, row in enumerate(rows):
            if not isinstance(row, dict):
                raise AuditLoadError(f"{owner}[{index}]: event must be an object")
            event_id = row.get("id")
            if not isinstance(event_id, str) or not event_id.strip():
                raise AuditLoadError(f"{owner}[{index}]: non-empty string id required")
            if event_id in events:
                raise AuditLoadError(
                    f"duplicate KO event id {event_id}: "
                    f"{event_owners[event_id]} and {owner}"
                )
            events[event_id] = row
            event_owners[event_id] = owner

    endings = _load_json(ENDINGS_PATH, list)
    for index, ending in enumerate(endings):
        if not isinstance(ending, dict):
            raise AuditLoadError(f"content/endings.json[{index}]: object required")

    return Corpus(
        events=events,
        event_owners=event_owners,
        director=_load_json(DIRECTOR_PATH, dict),
        endings=endings,
        main_source=_load_source(MAIN_GAME_PATH),
        game_state_source=_load_source(GAME_STATE_PATH),
    )


EVENT_OWNERS = {
    "inv_ipo_hot_tip": "content/events/investment_events.json",
    "callback_inv_ipo_hot_tip_win_listing": "content/events/callback_events_6.json",
    "callback_inv_ipo_hot_tip_lose_listing": "content/events/callback_events_6.json",
    "sangchul_tip_redev": "content/events/investment_events.json",
    "callback_sangchul_tip_win_payoff": "content/events/callback_events_6.json",
    "callback_sangchul_tip_lose_awkward": "content/events/callback_events_6.json",
    "arc_opp_sangchul_realty": "content/events/arc_events.json",
    "arc_opp_sangchul_win": "content/events/arc_events.json",
    "arc_opp_sangchul_lose": "content/events/arc_events.json",
    "callback_declined_sangchul_deal_echo": "content/events/callback_events_5.json",
    "inv_redev_zone_tip": "content/events/investment_events.json",
    "callback_redev_bet_taken_result": "content/events/callback_events_11.json",
    "callback_redev_bet_failed_result": "content/events/callback_events_11.json",
    "inv_redev_completion_sale": "content/events/investment_events.json",
}


EXPECTED_CONDITIONS: dict[str, dict[str, Any]] = {
    "inv_ipo_hot_tip": {
        "min_turn": 49,
        "max_turn": 72,
        "min_money": 10_000_000,
        "has_portfolio": True,
        "route": "투자형",
        "flag": "route_invest",
        "no_flag": "inv_ipo_hot_tip_seen",
    },
    "callback_inv_ipo_hot_tip_win_listing": {
        "flag": "inv_ipo_hot_tip_win",
        "no_flag": "inv_ipo_hot_tip_closed",
    },
    "callback_inv_ipo_hot_tip_lose_listing": {
        "flag": "inv_ipo_hot_tip_lose",
        "no_flag": "inv_ipo_hot_tip_closed",
    },
    "sangchul_tip_redev": {
        "cast_stage": {
            "person": "sangchul",
            "in": ["trusted", "mentoring", "guardian"],
        },
        "min_turn": 73,
        "max_turn": 96,
        "min_money": 10_000_000,
        "route": "투자형",
        "flag": "inv_ipo_hot_tip_closed",
        "no_flag": ["sangchul_tip_seen", "arc_opp_sangchul_seen"],
    },
    "callback_sangchul_tip_win_payoff": {
        "flag": "sangchul_tip_win",
        "min_turn": 8,
        "no_flag": "sangchul_tip_closed",
    },
    "callback_sangchul_tip_lose_awkward": {
        "flag": "sangchul_tip_lose",
        "min_turn": 6,
        "no_flag": "sangchul_tip_closed",
    },
    "arc_opp_sangchul_realty": {
        "min_turn": 82,
        "max_turn": 111,
        "min_money": 50_000_000,
        "route": "투자형",
        "flag": "sangchul_tip_closed",
        "cast_stage": {
            "person": "sangchul",
            "in": ["mentoring", "trusted", "guardian"],
        },
        "no_flag": [
            "arc_opp_sangchul_seen",
            "sangchul_truth_known",
            "sangchul_reported",
            "sangchul_cut_ties",
            "sangchul_quietly_distanced",
        ],
    },
    "arc_opp_sangchul_win": {
        "flag": "sangchul_deal_won",
        "no_flag": "arc_opp_sangchul_result_seen",
    },
    "arc_opp_sangchul_lose": {
        "flag": "sangchul_deal_lost",
        "no_flag": "arc_opp_sangchul_result_seen",
    },
    "callback_declined_sangchul_deal_echo": {
        "flag": "declined_sangchul_deal",
        "min_turn": 10,
    },
    "inv_redev_zone_tip": {
        "min_turn": 112,
        "max_turn": 143,
        "min_money": 80_000_000,
        "route": "투자형",
        "flag": "arc_opp_sangchul_result_seen",
        "no_flag": "redev_zone_tip_seen",
    },
    "callback_redev_bet_taken_result": {
        "flag": "redev_project_approved",
        "min_turn": 24,
        "no_flag": "redev_progress_result_seen",
    },
    "callback_redev_bet_failed_result": {
        "flag": "redev_project_failed",
        "min_turn": 24,
        "no_flag": "redev_progress_result_seen",
    },
    "inv_redev_completion_sale": {
        "flag": "redev_management_seen",
        "min_turn": 160,
        "no_flag": ["redev_ladder_exit", "redev_ladder_held"],
    },
}


EXPECTED_OPPORTUNITIES: dict[tuple[str, int], dict[str, Any]] = {
    ("inv_ipo_hot_tip", 0): {
        "stake_ratio": 0.6,
        "success_rate": 0.36,
        "win_multiplier": 3.5,
        "loss_ratio": 0.6,
        "luck_factor": 0.002,
        "skill_gain": 4,
        "win_flag": "inv_ipo_hot_tip_win",
        "lose_flag": "inv_ipo_hot_tip_lose",
    },
    ("inv_ipo_hot_tip", 1): {
        "stake_ratio": 0.25,
        "success_rate": 0.4,
        "win_multiplier": 2.5,
        "loss_ratio": 0.45,
        "luck_factor": 0.002,
        "skill_gain": 2,
        "win_flag": "inv_ipo_hot_tip_win",
        "lose_flag": "inv_ipo_hot_tip_lose",
    },
    ("sangchul_tip_redev", 0): {
        "stake_ratio": 0.4,
        "success_rate": 0.62,
        "win_multiplier": 1.8,
        "loss_ratio": 0.5,
        "luck_factor": 0.002,
        "skill_gain": 3,
        "win_flag": "sangchul_tip_win",
        "lose_flag": "sangchul_tip_lose",
    },
    ("sangchul_tip_redev", 1): {
        "stake_ratio": 0.12,
        "success_rate": 0.62,
        "win_multiplier": 1.8,
        "loss_ratio": 0.5,
        "luck_factor": 0.002,
        "skill_gain": 2,
        "win_flag": "sangchul_tip_win",
        "lose_flag": "sangchul_tip_lose",
    },
    ("arc_opp_sangchul_realty", 0): {
        "stake_ratio": 0.7,
        "success_rate": 0.42,
        "win_multiplier": 2.8,
        "loss_ratio": 0.55,
        "luck_factor": 0.002,
        "skill_gain": 5,
        "win_flag": "sangchul_deal_won",
        "lose_flag": "sangchul_deal_lost",
    },
    ("arc_opp_sangchul_realty", 1): {
        "stake_ratio": 0.3,
        "success_rate": 0.44,
        "win_multiplier": 2.0,
        "loss_ratio": 0.55,
        "luck_factor": 0.002,
        "skill_gain": 3,
        "win_flag": "sangchul_deal_won",
        "lose_flag": "sangchul_deal_lost",
    },
    ("inv_redev_zone_tip", 0): {
        "stake_ratio": 0.65,
        "success_rate": 0.4,
        "win_multiplier": 7.0,
        "loss_ratio": 0.7,
        "luck_factor": 0.0015,
        "skill_gain": 6,
        "win_flag": "redev_project_approved",
        "lose_flag": "redev_project_failed",
    },
    ("inv_redev_zone_tip", 1): {
        "stake_ratio": 0.3,
        "success_rate": 0.46,
        "win_multiplier": 5.0,
        "loss_ratio": 0.55,
        "luck_factor": 0.0015,
        "skill_gain": 3,
        "win_flag": "redev_project_approved",
        "lose_flag": "redev_project_failed",
    },
}


EXPECTED_DEFERRED: dict[tuple[str, int], list[dict[str, Any]]] = {
    ("inv_ipo_hot_tip", 0): [
        {"id": "callback_inv_ipo_hot_tip_win_listing", "delay": 1},
        {"id": "callback_inv_ipo_hot_tip_lose_listing", "delay": 1},
    ],
    ("inv_ipo_hot_tip", 1): [
        {"id": "callback_inv_ipo_hot_tip_win_listing", "delay": 1},
        {"id": "callback_inv_ipo_hot_tip_lose_listing", "delay": 1},
    ],
    ("sangchul_tip_redev", 0): [
        {"id": "callback_sangchul_tip_win_payoff", "delay": 8},
        {"id": "callback_sangchul_tip_lose_awkward", "delay": 8},
    ],
    ("sangchul_tip_redev", 1): [
        {"id": "callback_sangchul_tip_win_payoff", "delay": 8},
        {"id": "callback_sangchul_tip_lose_awkward", "delay": 8},
    ],
    ("arc_opp_sangchul_realty", 0): [
        {"id": "arc_opp_sangchul_win", "delay": 8},
        {"id": "arc_opp_sangchul_lose", "delay": 8},
    ],
    ("arc_opp_sangchul_realty", 1): [
        {"id": "arc_opp_sangchul_win", "delay": 8},
        {"id": "arc_opp_sangchul_lose", "delay": 8},
    ],
    ("inv_redev_zone_tip", 0): [
        {"id": "callback_redev_bet_taken_result", "delay": 24},
        {"id": "callback_redev_bet_failed_result", "delay": 24},
        {"id": "inv_redev_completion_sale", "delay": 48},
    ],
    ("inv_redev_zone_tip", 1): [
        {"id": "callback_redev_bet_taken_result", "delay": 24},
        {"id": "callback_redev_bet_failed_result", "delay": 24},
        {"id": "inv_redev_completion_sale", "delay": 48},
    ],
}


def _fail(errors: list[str], code: str, detail: str) -> None:
    errors.append(f"{code}: {detail}")


def _event(corpus: Corpus, event_id: str, errors: list[str]) -> dict[str, Any]:
    event = corpus.events.get(event_id)
    if not isinstance(event, dict):
        _fail(errors, "event.missing", event_id)
        return {}
    if event.get("id") != event_id:
        _fail(errors, "event.identity", f"{event_id} object id={event.get('id')!r}")
    return event


def _choices(event: dict[str, Any], event_id: str, errors: list[str]) -> list[dict[str, Any]]:
    raw = event.get("choices")
    if not isinstance(raw, list) or not raw:
        _fail(errors, "choice.shape", f"{event_id} needs non-empty choices")
        return []
    result: list[dict[str, Any]] = []
    for index, choice in enumerate(raw):
        if not isinstance(choice, dict):
            _fail(errors, "choice.shape", f"{event_id}[{index}] must be an object")
            continue
        result.append(choice)
    return result


def _flag_set(choice: dict[str, Any]) -> set[str]:
    raw = choice.get("flags", [])
    if not isinstance(raw, list):
        return set()
    return {str(value) for value in raw}


def _require_choice_flags(
    corpus: Corpus,
    event_id: str,
    choice_indexes: list[int],
    required: set[str],
    errors: list[str],
    *,
    forbidden: set[str] | None = None,
) -> None:
    choices = _choices(_event(corpus, event_id, errors), event_id, errors)
    for index in choice_indexes:
        if index >= len(choices):
            _fail(errors, "closure.choice", f"{event_id}[{index}] missing")
            continue
        flags = _flag_set(choices[index])
        missing = required - flags
        if missing:
            _fail(
                errors,
                "closure.flags",
                f"{event_id}[{index}] missing {sorted(missing)}",
            )
        disallowed = (forbidden or set()) & flags
        if disallowed:
            _fail(
                errors,
                "closure.flags",
                f"{event_id}[{index}] writes forbidden {sorted(disallowed)}",
            )


def _audit_events(corpus: Corpus, errors: list[str]) -> None:
    for event_id, expected_owner in EVENT_OWNERS.items():
        event = _event(corpus, event_id, errors)
        if not event:
            continue
        actual_owner = corpus.event_owners.get(event_id)
        if actual_owner != expected_owner:
            _fail(
                errors,
                "event.owner",
                f"{event_id} expected {expected_owner}, got {actual_owner}",
            )
        actual_conditions = event.get("conditions")
        if actual_conditions != EXPECTED_CONDITIONS[event_id]:
            _fail(
                errors,
                "conditions.exact",
                f"{event_id} expected={EXPECTED_CONDITIONS[event_id]!r} "
                f"actual={actual_conditions!r}",
            )

    for (event_id, choice_index), expected in EXPECTED_OPPORTUNITIES.items():
        choices = _choices(_event(corpus, event_id, errors), event_id, errors)
        if choice_index >= len(choices):
            _fail(errors, "opportunity.choice", f"{event_id}[{choice_index}] missing")
            continue
        actual = choices[choice_index].get("opportunity")
        if actual != expected:
            _fail(
                errors,
                "opportunity.constants",
                f"{event_id}[{choice_index}] expected={expected!r} actual={actual!r}",
            )

    for event_id in [
        "inv_ipo_hot_tip",
        "sangchul_tip_redev",
        "arc_opp_sangchul_realty",
        "inv_redev_zone_tip",
    ]:
        choices = _choices(_event(corpus, event_id, errors), event_id, errors)
        if len(choices) != 3:
            _fail(errors, "choice.count", f"{event_id} expected 3, got {len(choices)}")
        elif "opportunity" in choices[2]:
            _fail(errors, "closure.refuse", f"{event_id}[2] must not resolve an opportunity")

    sale_choices = _choices(
        _event(corpus, "inv_redev_completion_sale", errors),
        "inv_redev_completion_sale",
        errors,
    )
    if len(sale_choices) != 2:
        _fail(
            errors,
            "choice.count",
            f"inv_redev_completion_sale expected 2, got {len(sale_choices)}",
        )
    elif sale_choices[0].get("effects", {}).get("money") != 2_600_000_000:
        _fail(errors, "sale.cash", "sale must add exactly 2,600,000,000 won")


def _audit_deferred(corpus: Corpus, errors: list[str]) -> None:
    for (event_id, choice_index), expected in EXPECTED_DEFERRED.items():
        choices = _choices(_event(corpus, event_id, errors), event_id, errors)
        if choice_index >= len(choices):
            _fail(errors, "deferred.choice", f"{event_id}[{choice_index}] missing")
            continue
        actual = choices[choice_index].get("deferred_follow_up")
        if actual != expected:
            _fail(
                errors,
                "deferred.exact",
                f"{event_id}[{choice_index}] expected={expected!r} actual={actual!r}",
            )
        for row in expected:
            if row["id"] not in corpus.events:
                _fail(
                    errors,
                    "deferred.target",
                    f"{event_id}[{choice_index}] missing target {row['id']}",
                )

    for event_id in [
        "inv_ipo_hot_tip",
        "sangchul_tip_redev",
        "inv_redev_zone_tip",
    ]:
        choices = _choices(_event(corpus, event_id, errors), event_id, errors)
        if len(choices) >= 3 and (
            "deferred_follow_up" in choices[2] or "deferred_delay" in choices[2]
        ):
            _fail(errors, "closure.refuse", f"{event_id}[2] must schedule no ladder result")

    realty_choices = _choices(
        _event(corpus, "arc_opp_sangchul_realty", errors),
        "arc_opp_sangchul_realty",
        errors,
    )
    if len(realty_choices) >= 3:
        refusal = realty_choices[2]
        if refusal.get("deferred_follow_up") != "callback_declined_sangchul_deal_echo" \
                or refusal.get("deferred_delay") != 16:
            _fail(
                errors,
                "closure.refuse",
                "arc_opp_sangchul_realty refusal must defer its exact echo by 16 weeks",
            )

    # The windows leave room for every delayed receipt, including a W143 entry.
    timing = {
        "ipo_to_tip": (72 + 1, 73),
        "tip_early_to_realty": (73 + 8, 82),
        "tip_late_to_realty_close": (96 + 8, 111),
        "realty_late_to_redev_close": (111 + 8, 143),
        "redev_early_to_sale": (112 + 48, 160),
        "redev_late_to_run_end": (143 + 48, 240),
    }
    checks = {
        "ipo_to_tip": timing["ipo_to_tip"][0] == timing["ipo_to_tip"][1],
        "tip_early_to_realty": timing["tip_early_to_realty"][0] < timing["tip_early_to_realty"][1],
        "tip_late_to_realty_close": timing["tip_late_to_realty_close"][0] <= timing["tip_late_to_realty_close"][1],
        "realty_late_to_redev_close": timing["realty_late_to_redev_close"][0] <= timing["realty_late_to_redev_close"][1],
        "redev_early_to_sale": timing["redev_early_to_sale"][0] == timing["redev_early_to_sale"][1],
        "redev_late_to_run_end": timing["redev_late_to_run_end"][0] <= timing["redev_late_to_run_end"][1],
    }
    for label, okay in checks.items():
        if not okay:
            _fail(errors, "deferred.window", label)


def _audit_closure(corpus: Corpus, errors: list[str]) -> None:
    _require_choice_flags(corpus, "inv_ipo_hot_tip", [0, 1, 2], {"inv_ipo_hot_tip_seen"}, errors)
    _require_choice_flags(corpus, "inv_ipo_hot_tip", [2], {"inv_ipo_hot_tip_closed"}, errors)
    for callback_id in [
        "callback_inv_ipo_hot_tip_win_listing",
        "callback_inv_ipo_hot_tip_lose_listing",
    ]:
        _require_choice_flags(
            corpus,
            callback_id,
            [0, 1],
            {"inv_ipo_hot_tip_closed"},
            errors,
        )

    _require_choice_flags(corpus, "sangchul_tip_redev", [0, 1, 2], {"sangchul_tip_seen"}, errors)
    _require_choice_flags(corpus, "sangchul_tip_redev", [2], {"sangchul_tip_closed"}, errors)
    for callback_id in [
        "callback_sangchul_tip_win_payoff",
        "callback_sangchul_tip_lose_awkward",
    ]:
        _require_choice_flags(
            corpus,
            callback_id,
            [0, 1],
            {"sangchul_tip_closed"},
            errors,
        )

    _require_choice_flags(corpus, "arc_opp_sangchul_realty", [0, 1, 2], {"arc_opp_sangchul_seen"}, errors)
    _require_choice_flags(corpus, "arc_opp_sangchul_realty", [2], {"declined_sangchul_deal"}, errors)
    for result_id in ["arc_opp_sangchul_win", "arc_opp_sangchul_lose"]:
        _require_choice_flags(
            corpus,
            result_id,
            [0, 1],
            {"arc_opp_sangchul_result_seen"},
            errors,
        )

    _require_choice_flags(corpus, "inv_redev_zone_tip", [0, 1, 2], {"redev_zone_tip_seen"}, errors)
    _require_choice_flags(
        corpus,
        "callback_redev_bet_taken_result",
        [0, 1],
        {"redev_progress_result_seen", "redev_management_seen"},
        errors,
    )
    _require_choice_flags(
        corpus,
        "callback_redev_bet_failed_result",
        [0, 1],
        {"redev_progress_result_seen"},
        errors,
        forbidden={"redev_management_seen"},
    )
    _require_choice_flags(corpus, "inv_redev_completion_sale", [0], {"redev_ladder_exit"}, errors)
    _require_choice_flags(corpus, "inv_redev_completion_sale", [1], {"redev_ladder_held"}, errors)


def _conditions_met(conditions: dict[str, Any], flags: set[str], turn: int) -> bool:
    if "min_turn" in conditions and turn < int(conditions["min_turn"]):
        return False
    if "max_turn" in conditions and turn > int(conditions["max_turn"]):
        return False
    if "flag" in conditions and str(conditions["flag"]) not in flags:
        return False
    raw_no_flag = conditions.get("no_flag", [])
    no_flags = raw_no_flag if isinstance(raw_no_flag, list) else [raw_no_flag]
    return not any(str(flag) in flags for flag in no_flags if str(flag))


def _audit_failure_barrier(corpus: Corpus, errors: list[str]) -> None:
    redev = _event(corpus, "inv_redev_zone_tip", errors)
    success_callback = _event(corpus, "callback_redev_bet_taken_result", errors)
    failure_callback = _event(corpus, "callback_redev_bet_failed_result", errors)
    sale = _event(corpus, "inv_redev_completion_sale", errors)
    if not all([redev, success_callback, failure_callback, sale]):
        return
    redev_choices = _choices(redev, "inv_redev_zone_tip", errors)
    success_choices = _choices(success_callback, "callback_redev_bet_taken_result", errors)
    failure_choices = _choices(failure_callback, "callback_redev_bet_failed_result", errors)
    if len(redev_choices) < 3 or not success_choices or not failure_choices:
        return

    win_flag = str(redev_choices[1].get("opportunity", {}).get("win_flag", ""))
    lose_flag = str(redev_choices[1].get("opportunity", {}).get("lose_flag", ""))
    success_flags = _flag_set(redev_choices[1]) | {win_flag} | _flag_set(success_choices[0])
    failure_flags = _flag_set(redev_choices[1]) | {lose_flag} | _flag_set(failure_choices[0])
    refusal_flags = _flag_set(redev_choices[2])
    sale_conditions = sale.get("conditions", {})
    if not _conditions_met(sale_conditions, success_flags, 160):
        _fail(errors, "failure.barrier", "successful management receipt cannot reach sale")
    if _conditions_met(sale_conditions, failure_flags, 160):
        _fail(errors, "failure.barrier", "failed redevelopment can reach sale")
    if _conditions_met(sale_conditions, refusal_flags, 160):
        _fail(errors, "failure.barrier", "refused redevelopment can reach sale")

    producers: set[tuple[str, int]] = set()
    for event_id, event in corpus.events.items():
        raw_choices = event.get("choices", [])
        if not isinstance(raw_choices, list):
            continue
        for index, choice in enumerate(raw_choices):
            if isinstance(choice, dict) and "redev_management_seen" in _flag_set(choice):
                producers.add((event_id, index))
    expected_producers = {
        ("callback_redev_bet_taken_result", 0),
        ("callback_redev_bet_taken_result", 1),
    }
    if producers != expected_producers:
        _fail(
            errors,
            "failure.producer",
            f"redev_management_seen producers={sorted(producers)}",
        )


def _audit_random_exclusion(corpus: Corpus, errors: list[str]) -> None:
    scope = corpus.director.get("scope")
    diet = corpus.director.get("content_diet")
    if not isinstance(scope, dict) or not isinstance(diet, dict):
        _fail(errors, "random.schema", "event director scope/content_diet dictionaries required")
        return
    prefixes = scope.get("excluded_id_prefixes")
    if not isinstance(prefixes, list) or "arc_" not in prefixes:
        _fail(errors, "random.scope", "arc_ prefix exclusion missing")
    if scope.get("exclude_follow_up_targets") is not True:
        _fail(errors, "random.scope", "follow-up target exclusion must remain true")
    foreground = diet.get("foreground_event_ids")
    bridges = diet.get("bridge_event_ids")
    if not isinstance(foreground, list) or not isinstance(bridges, list):
        _fail(errors, "random.schema", "foreground/bridge allowlists must be arrays")
        return
    foreground_set = {str(value) for value in foreground}
    bridge_set = {str(value) for value in bridges}
    ladder_ids = set(EVENT_OWNERS)
    leaked = ladder_ids & (foreground_set | bridge_set)
    if leaked:
        _fail(errors, "random.exclusion", f"ladder IDs in random/bridge pool: {sorted(leaked)}")
    if len(foreground_set) != len(foreground):
        _fail(errors, "random.schema", "duplicate foreground event id")
    if len(bridge_set) != len(bridges):
        _fail(errors, "random.schema", "duplicate bridge event id")


def _extract_function(source: str, name: str, errors: list[str], owner: str) -> str:
    pattern = re.compile(rf"(?m)^func\s+{re.escape(name)}\s*\(")
    matches = list(pattern.finditer(source))
    if len(matches) != 1:
        _fail(errors, "source.function", f"{owner}:{name} count={len(matches)}")
        return ""
    start = matches[0].start()
    next_func = re.search(r"(?m)^func\s+[A-Za-z0-9_]+\s*\(", source[matches[0].end():])
    end = len(source) if next_func is None else matches[0].end() + next_func.start()
    return source[start:end]


def _code_text(source: str) -> str:
    source = re.sub(r"\\\r?\n", " ", source)
    source = re.sub(r"(?m)#.*$", " ", source)
    return re.sub(r"\s+", " ", source).strip()


def _require_fragment(
    body: str,
    fragment: str,
    errors: list[str],
    code: str,
) -> None:
    if _code_text(fragment) not in _code_text(body):
        _fail(errors, code, _code_text(fragment))


def _audit_main_source(corpus: Corpus, errors: list[str]) -> None:
    body = _extract_function(
        corpus.main_source,
        "_property_ladder_event_id",
        errors,
        "scenes/MainGame.gd",
    )
    next_arc = _extract_function(
        corpus.main_source,
        "_next_arc_id",
        errors,
        "scenes/MainGame.gd",
    )
    if not body or not next_arc:
        return
    fragments = {
        "main.route": '''
            var is_investor := GameState.has_investor_route_identity()
            if not is_investor:
                return ""
        ''',
        "main.recovery": '''
            and not GameState.has_deferred_event("arc_opp_sangchul_win")
            and not GameState.has_deferred_event("arc_opp_sangchul_lose"):
                return "arc_opp_sangchul_win"
                    if f.get("sangchul_deal_won", false)
                    else "arc_opp_sangchul_lose"
        ''',
        "main.window.ipo": '''
            if t >= 49 and t <= 72
                and GameState.money >= 10_000_000.0
                and not GameState.portfolio.is_empty()
                and not f.get("inv_ipo_hot_tip_seen", false):
                return "inv_ipo_hot_tip"
        ''',
        "main.stage": '''
            var sangchul_stage := GameState.get_cast_stage("sangchul")
        ''',
        "main.window.tip": '''
            if t >= 73 and t <= 96
                and f.get("inv_ipo_hot_tip_closed", false)
                and GameState.money >= 10_000_000.0
                and sangchul_stage in ["mentoring", "trusted", "guardian"]
                and not f.get("sangchul_tip_seen", false)
                and not f.get("arc_opp_sangchul_seen", false):
                return "sangchul_tip_redev"
        ''',
        "main.window.realty": '''
            if t >= 82 and t <= 111
                and f.get("sangchul_tip_closed", false)
                and GameState.money >= 50_000_000.0
                and sangchul_stage in ["mentoring", "trusted", "guardian"]
                and not f.get("arc_opp_sangchul_seen", false)
                and not f.get("sangchul_truth_known", false)
                and not f.get("sangchul_reported", false)
                and not f.get("sangchul_cut_ties", false)
                and not f.get("sangchul_quietly_distanced", false):
                return "arc_opp_sangchul_realty"
        ''',
        "main.window.redev": '''
            if t >= 112 and t <= 143
                and f.get("arc_opp_sangchul_result_seen", false)
                and GameState.money >= 80_000_000.0
                and not f.get("redev_zone_tip_seen", false):
                return "inv_redev_zone_tip"
        ''',
    }
    for code, fragment in fragments.items():
        _require_fragment(body, fragment, errors, code)
    if "get_total_asset_value" in body:
        _fail(errors, "main.cash", "property ladder gates must read liquid cash")
    if "inv_redev_completion_sale" in body:
        _fail(errors, "main.sale", "sale must arrive only from its +48 deferred reservation")
    if 'get_cast_stage("sangchul") == "interested"' in next_arc:
        _fail(errors, "main.legacy", "dead interested-stage property router remains")

    deferred_pos = next_arc.find("_deferred_foreground_event_id(resolve_bridges)")
    ladder_pos = next_arc.find("_property_ladder_event_id(t, f)")
    intro_pos = next_arc.find("1구간")
    if min(deferred_pos, ladder_pos, intro_pos) < 0 \
            or not deferred_pos < ladder_pos < intro_pos:
        _fail(
            errors,
            "main.priority",
            "deferred receipts must precede ladder routing, which must precede generic arcs",
        )
    if next_arc.count("_property_ladder_event_id(t, f)") != 1:
        _fail(errors, "main.priority", "property ladder router must be called exactly once")


def _audit_opportunity_core(corpus: Corpus, errors: list[str]) -> None:
    settle = _extract_function(
        corpus.game_state_source, "settle_cash", errors, "autoloads/GameState.gd"
    )
    stake = _extract_function(
        corpus.game_state_source,
        "opportunity_stake_for_cash",
        errors,
        "autoloads/GameState.gd",
    )
    resolve = _extract_function(
        corpus.game_state_source,
        "_resolve_opportunity",
        errors,
        "autoloads/GameState.gd",
    )
    route_identity = _extract_function(
        corpus.game_state_source,
        "has_investor_route_identity",
        errors,
        "autoloads/GameState.gd",
    )
    checks = [
        (settle, "return floor(value + 0.5) if value >= 0.0 else ceil(value - 0.5)", "core.rounding"),
        (stake, 'raw_stake = available_cash * float(opp.get("stake_ratio", 0.0))', "core.stake"),
        (stake, "var stake := settle_cash(raw_stake)", "core.stake"),
        (resolve, 'var rate: float = float(opp.get("success_rate", 0.5))', "core.rate"),
        (resolve, 'rate += float(luck) * float(opp.get("luck_factor", 0.002))', "core.rate"),
        (resolve, "if sangchul_aff >= 35: rate += 0.15", "core.rate"),
        (resolve, "elif sangchul_aff >= 25: rate += 0.10", "core.rate"),
        (resolve, "elif sangchul_aff >= 15: rate += 0.05", "core.rate"),
        (resolve, "rate = clampf(rate, 0.02, 0.98)", "core.rate"),
        (resolve, 'stake * float(opp.get("win_multiplier", 2.0))', "core.win"),
        (resolve, 'float(opp.get("loss_ratio", 1.0)), 0.0, 1.0', "core.loss"),
        (resolve, "add_settled_cash(win)", "core.win"),
        (resolve, "add_settled_cash(-loss)", "core.loss"),
        (
            route_identity,
            "player_route == CHAPTER5_CAUSAL_ROUTE.ENTRY_PLAYER_ROUTE",
            "core.route",
        ),
        (
            route_identity,
            'bool(flags.get("route_invest", false))',
            "core.route",
        ),
    ]
    for body, fragment, code in checks:
        if body:
            _require_fragment(body, fragment, errors, code)


def _settle_positive(value: Decimal) -> Decimal:
    return value.quantize(Decimal("1"), rounding=ROUND_HALF_UP)


def _won(value: Any) -> Decimal:
    return Decimal(str(value))


def _win_cash(cash: Decimal, opportunity: dict[str, Any]) -> Decimal:
    stake = _settle_positive(cash * _won(opportunity["stake_ratio"]))
    gain = _settle_positive(stake * _won(opportunity["win_multiplier"]))
    return cash + gain


def _audit_reference_math(corpus: Corpus, errors: list[str]) -> None:
    path = [
        ("inv_ipo_hot_tip", 0),
        ("sangchul_tip_redev", 0),
        ("arc_opp_sangchul_realty", 1),
        ("inv_redev_zone_tip", 1),
    ]
    expected = [
        Decimal("10000000"),
        Decimal("31000000"),
        Decimal("53320000"),
        Decimal("85312000"),
        Decimal("213280000"),
        Decimal("2813280000"),
    ]
    actual = [expected[0]]
    cash = expected[0]
    for event_id, choice_index in path:
        event = _event(corpus, event_id, errors)
        choices = _choices(event, event_id, errors)
        if choice_index >= len(choices) or not isinstance(
            choices[choice_index].get("opportunity"), dict
        ):
            return
        cash = _win_cash(cash, choices[choice_index]["opportunity"])
        actual.append(cash)
    sale = _event(corpus, "inv_redev_completion_sale", errors)
    sale_choices = _choices(sale, "inv_redev_completion_sale", errors)
    if not sale_choices:
        return
    cash += _won(sale_choices[0].get("effects", {}).get("money", 0))
    actual.append(cash)
    if actual != expected:
        _fail(
            errors,
            "reference.math",
            f"expected={[int(v) for v in expected]} actual={[int(v) for v in actual]}",
        )


def _audit_instant_legend(corpus: Corpus, errors: list[str]) -> None:
    ending_rows = [row for row in corpus.endings if row.get("id") == "instant_legend"]
    if len(ending_rows) != 1:
        _fail(errors, "ending.identity", f"instant_legend count={len(ending_rows)}")
    body = _extract_function(
        corpus.game_state_source, "check_game_over", errors, "autoloads/GameState.gd"
    )
    if not body:
        return
    _require_fragment(
        body,
        '''
            if total_now >= 3_000_000_000:
                if age <= 33:
                    finish_run("instant_legend"); return
        ''',
        errors,
        "ending.first_year",
    )
    if corpus.game_state_source.count('finish_run("instant_legend")') != 1:
        _fail(errors, "ending.first_year", "instant_legend must have one source trigger")


def audit(corpus: Corpus) -> list[str]:
    errors: list[str] = []
    _audit_events(corpus, errors)
    _audit_deferred(corpus, errors)
    _audit_closure(corpus, errors)
    _audit_failure_barrier(corpus, errors)
    _audit_random_exclusion(corpus, errors)
    _audit_main_source(corpus, errors)
    _audit_opportunity_core(corpus, errors)
    _audit_reference_math(corpus, errors)
    _audit_instant_legend(corpus, errors)
    return errors


Mutation = Callable[[Corpus], None]


def _mutate_event(corpus: Corpus, event_id: str) -> dict[str, Any]:
    return corpus.events[event_id]


def _run_self_test(corpus: Corpus) -> int:
    baseline_errors = audit(corpus)
    if baseline_errors:
        print("PROPERTY_LADDER_SELF_TEST_BASELINE_FAILED", file=sys.stderr)
        for error in baseline_errors:
            print(f"  - {error}", file=sys.stderr)
        return 1

    try:
        _parse_json_text('{"same": 1, "same": 2}', "synthetic-duplicate")
    except AuditLoadError:
        duplicate_guard_ok = True
    else:
        duplicate_guard_ok = False
    if not duplicate_guard_ok:
        print("PROPERTY_LADDER_SELF_TEST_FAILED duplicate_json_key", file=sys.stderr)
        return 1

    def mutate_condition(c: Corpus) -> None:
        _mutate_event(c, "inv_ipo_hot_tip")["conditions"]["max_turn"] = 73

    def mutate_cash(c: Corpus) -> None:
        _mutate_event(c, "arc_opp_sangchul_realty")["conditions"]["min_money"] = 40_000_000

    def mutate_stage(c: Corpus) -> None:
        _mutate_event(c, "sangchul_tip_redev")["conditions"]["cast_stage"]["in"] = ["trusted"]

    def mutate_delay_one(c: Corpus) -> None:
        _mutate_event(c, "inv_ipo_hot_tip")["choices"][0]["deferred_follow_up"][0]["delay"] = 2

    def mutate_delay_eight(c: Corpus) -> None:
        _mutate_event(c, "arc_opp_sangchul_realty")["choices"][0]["deferred_follow_up"][0]["delay"] = 7

    def mutate_delay_twenty_four(c: Corpus) -> None:
        _mutate_event(c, "inv_redev_zone_tip")["choices"][0]["deferred_follow_up"][0]["delay"] = 23

    def mutate_delay_forty_eight(c: Corpus) -> None:
        _mutate_event(c, "inv_redev_zone_tip")["choices"][0]["deferred_follow_up"][2]["delay"] = 47

    def mutate_result_closure(c: Corpus) -> None:
        _mutate_event(c, "callback_inv_ipo_hot_tip_win_listing")["choices"][0]["flags"].remove(
            "inv_ipo_hot_tip_closed"
        )

    def mutate_refusal_closure(c: Corpus) -> None:
        _mutate_event(c, "sangchul_tip_redev")["choices"][2]["flags"].remove(
            "sangchul_tip_closed"
        )

    def mutate_failure_gate(c: Corpus) -> None:
        _mutate_event(c, "callback_redev_bet_failed_result")["choices"][0]["flags"].append(
            "redev_management_seen"
        )

    def mutate_random(c: Corpus) -> None:
        c.director["content_diet"]["foreground_event_ids"].append("inv_redev_zone_tip")

    def mutate_constants(c: Corpus) -> None:
        _mutate_event(c, "sangchul_tip_redev")["choices"][0]["opportunity"]["win_multiplier"] = 1.9

    def mutate_sale(c: Corpus) -> None:
        _mutate_event(c, "inv_redev_completion_sale")["choices"][0]["effects"]["money"] = 2_700_000_000

    def mutate_main_route(c: Corpus) -> None:
        c.main_source = c.main_source.replace(
            "GameState.has_investor_route_identity()",
            "true",
            1,
        )

    def mutate_route_identity(c: Corpus) -> None:
        c.game_state_source = c.game_state_source.replace(
            "func has_investor_route_identity() -> bool:\n"
            "\treturn player_route == CHAPTER5_CAUSAL_ROUTE.ENTRY_PLAYER_ROUTE",
            "func has_investor_route_identity() -> bool:\n"
            '\treturn player_route == "직장형"',
            1,
        )

    def mutate_main_priority(c: Corpus) -> None:
        marker = "\tvar property_ladder_id := _property_ladder_event_id(t, f)"
        c.main_source = c.main_source.replace(marker, "\t# removed property ladder call", 1)

    def mutate_core(c: Corpus) -> None:
        c.game_state_source = c.game_state_source.replace(
            'opp.get("win_multiplier", 2.0)',
            'opp.get("win_multiplier", 3.0)',
            1,
        )

    def mutate_ending(c: Corpus) -> None:
        c.game_state_source = c.game_state_source.replace("if age <= 33:", "if age <= 34:", 1)

    cases: list[tuple[str, Mutation, str]] = [
        ("window", mutate_condition, "conditions.exact"),
        ("cash", mutate_cash, "conditions.exact"),
        ("stage", mutate_stage, "conditions.exact"),
        ("delay_1", mutate_delay_one, "deferred.exact"),
        ("delay_8", mutate_delay_eight, "deferred.exact"),
        ("delay_24", mutate_delay_twenty_four, "deferred.exact"),
        ("delay_48", mutate_delay_forty_eight, "deferred.exact"),
        ("result_closure", mutate_result_closure, "closure.flags"),
        ("refusal_closure", mutate_refusal_closure, "closure.flags"),
        ("failure_gate", mutate_failure_gate, "failure.barrier"),
        ("random_foreground", mutate_random, "random.exclusion"),
        ("opportunity_constants", mutate_constants, "opportunity.constants"),
        ("sale_cash", mutate_sale, "sale.cash"),
        ("main_route", mutate_main_route, "main.route"),
        ("route_identity", mutate_route_identity, "core.route"),
        ("main_priority", mutate_main_priority, "main.priority"),
        ("core_multiplier", mutate_core, "core.win"),
        ("instant_legend_age", mutate_ending, "ending.first_year"),
    ]
    failures: list[str] = []
    for name, mutate, expected_error in cases:
        variant = copy.deepcopy(corpus)
        mutate(variant)
        errors = audit(variant)
        if not any(error.startswith(expected_error + ":") for error in errors):
            failures.append(
                f"{name}: expected {expected_error}, got {errors[:3] if errors else 'PASS'}"
            )
    if failures:
        print("PROPERTY_LADDER_SELF_TEST_FAILED", file=sys.stderr)
        for failure in failures:
            print(f"  - {failure}", file=sys.stderr)
        return 1
    print(
        "PROPERTY_LADDER_SELF_TEST_OK "
        f"mutations={len(cases) + 1} duplicate_json=blocked"
    )
    return 0


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--self-test",
        action="store_true",
        help="run mutation cases proving every contract fails closed",
    )
    args = parser.parse_args(argv)
    try:
        corpus = load_corpus()
    except AuditLoadError as exc:
        print(f"PROPERTY_LADDER_AUDIT_ERROR load: {exc}", file=sys.stderr)
        return 1
    if args.self_test:
        return _run_self_test(corpus)
    errors = audit(corpus)
    if errors:
        print(f"PROPERTY_LADDER_AUDIT_FAILED errors={len(errors)}", file=sys.stderr)
        for error in errors:
            print(f"  - {error}", file=sys.stderr)
        return 1
    print(
        "PROPERTY_LADDER_AUDIT_OK "
        "events=14 windows=49-72/73-96/82-111/112-143 "
        "cash=10m/10m/50m/80m deferred=1/8/24/48 "
        "reference=10m->31m->53.32m->85.312m->213.28m->2.81328b "
        "failure_sale=blocked random_foreground=excluded "
        "instant_legend=first_year_3b"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
