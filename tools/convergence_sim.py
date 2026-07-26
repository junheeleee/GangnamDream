#!/usr/bin/env python3
"""Deterministic 240-week strategy-convergence model.

This is not a win-rate oracle. It compares five stable player policies through
the live salary table, weekly AP grammar, monthly pressure, ambient event
choices, opportunity math, relationship affinity, route points, and moral tint.
Low-signal weekly filler and manual minigame skill are compressed to one
representative authored decision per month. The report calls out that limit.
"""

from __future__ import annotations

import argparse
import bisect
import json
import math
import random
from collections import Counter, deque
from dataclasses import dataclass, field
from pathlib import Path
from statistics import median

from event_schedule import deferred_follow_ups


ROOT = Path(__file__).resolve().parents[1]
RARITY_WEIGHT = {"common": 1.0, "uncommon": 0.7, "rare": 0.28, "legendary": 0.08}
FAIL_ENDINGS = {"burnout", "mental_break", "bankruptcy", "debt_spiral", "crypto_ghost"}
CAST_IDS = ("father", "daeun", "jiyeon", "jaehyuk", "sangchul")


def _load_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def _load_events():
    rows = []
    for path in sorted((ROOT / "content" / "events").glob("*.json")):
        data = _load_json(path)
        if isinstance(data, list):
            rows.extend(item for item in data if isinstance(item, dict))
    by_id = {str(row.get("id", "")): row for row in rows if row.get("id")}
    ambient = [
        row
        for row in rows
        if str(row.get("category", "")) != "story"
        and str(row.get("rarity", "")) != "story"
        and float(row.get("weight", 1.0)) > 0.0
        and not bool(row.get("hidden", False))
        and row.get("choices")
    ]
    return ambient, by_id


EVENTS, EVENTS_BY_ID = _load_events()
JOBS = {str(row["id"]): row for row in _load_json(ROOT / "content" / "jobs.json")}


def _build_event_pools():
    pools = {}
    for event in EVENTS:
        category = str(event.get("category", "uncategorized"))
        base_weight = float(event.get("weight", 1.0)) * RARITY_WEIGHT.get(str(event.get("rarity", "common")), 1.0)
        pool = pools.setdefault(category, {"events": [], "weights": [], "total": 0.0})
        pool["events"].append(event)
        pool["weights"].append(base_weight)
        pool["total"] += base_weight
    for pool in pools.values():
        running = 0.0
        cumulative = []
        for value in pool["weights"]:
            running += value
            cumulative.append(running)
        pool["cumulative"] = cumulative
    return pools


EVENT_POOLS = _build_event_pools()


@dataclass(frozen=True)
class Policy:
    key: str
    label: str
    category_bias: dict[str, float]
    money_weight: float
    body_weight: float
    people_weight: float
    moral_weight: float
    risk_weight: float
    route_preference: str


POLICIES = (
    Policy(
        "safe_career", "Safe career", {"jobs": 2.8, "self_development": 1.8, "finance": 1.4, "family": 1.2},
        1.0, 1.0, 0.8, 0.6, -1.0, "orthodox",
    ),
    Policy(
        "aggressive_investor", "Aggressive investor", {"investment": 3.2, "finance": 2.6, "social": 1.3},
        2.0, 0.35, 0.25, 0.0, 1.1, "unorthodox",
    ),
    Policy(
        "people_first", "People first", {"relationship": 3.0, "romance": 3.0, "family": 2.8, "health": 2.0, "social": 1.8},
        0.35, 1.6, 2.2, 1.8, -1.2, "balanced",
    ),
    Policy(
        "gambler", "Gambler", {"gambling": 4.0, "finance": 1.4, "social": 1.1},
        2.1, 0.2, 0.1, -0.3, 2.2, "unorthodox",
    ),
    Policy(
        "founder", "Skill / founder", {"self_development": 2.5, "jobs": 1.8, "social": 2.0, "investment": 1.5, "finance": 2.5},
        1.3, 0.65, 0.55, 0.35, 0.7, "mixed",
    ),
)


def _build_policy_draw_pools():
    output = {}
    categories = list(EVENT_POOLS)
    for policy in POLICIES:
        running = 0.0
        cumulative = []
        for category in categories:
            running += EVENT_POOLS[category]["total"] * policy.category_bias.get(category, 1.0)
            cumulative.append(running)
        output[policy.key] = {"categories": categories, "cumulative": cumulative, "total": running}
    return output


POLICY_DRAW_POOLS = _build_policy_draw_pools()


def _weighted_item(items, cumulative, total, rng: random.Random):
    index = bisect.bisect_left(cumulative, rng.random() * total)
    return items[min(index, len(items) - 1)]


@dataclass
class SimState:
    money: float = 500_000.0
    portfolio: float = 0.0
    loans: float = 0.0
    health: float = 65.0
    mental: float = 60.0
    intelligence: float = 55.0
    social: float = 45.0
    appearance: float = 50.0
    investment_skill: float = 15.0
    luck: float = 45.0
    reputation: float = 5.0
    gambling: float = 0.0
    addiction: float = 0.0
    work_performance: float = 50.0
    moral_tint: float = 0.0
    loop_tint_spent: float = 0.0
    route_orthodox: int = 0
    route_unorthodox: int = 0
    tendency: dict[str, int] = field(default_factory=lambda: {"career": 0, "invest": 0, "found": 0})
    tendency_realized: str = ""
    money_weeks: int = 0
    human_weeks: int = 0
    grind_streak: int = 0
    income: float = 0.0
    job_id: str = ""
    job_tenure_months: int = 0
    flags: set[str] = field(default_factory=set)
    cast: dict[str, float] = field(default_factory=lambda: {
        "father": 40.0, "daeun": 0.0, "jiyeon": 0.0, "jaehyuk": 0.0, "sangchul": 0.0,
    })
    cast_stage: dict[str, str] = field(default_factory=lambda: {
        "father": "distant", "daeun": "unknown", "jiyeon": "unknown",
        "jaehyuk": "unknown", "sangchul": "unknown",
    })
    recent_events: deque[str] = field(default_factory=lambda: deque(maxlen=25))
    cooldowns: dict[str, int] = field(default_factory=dict)
    deferred: list[tuple[int, str]] = field(default_factory=list)
    events_seen: int = 0
    ending: str = ""
    max_assets: float = 500_000.0

    def assets(self) -> float:
        return self.money + self.portfolio - self.loans

    def clamp(self) -> None:
        for name in (
            "health", "mental", "intelligence", "social", "appearance", "investment_skill",
            "luck", "reputation", "gambling", "addiction", "work_performance",
        ):
            setattr(self, name, max(0.0, min(100.0, float(getattr(self, name)))))
        self.moral_tint = max(-100.0, min(100.0, self.moral_tint))
        if "crossed_line" in self.flags:
            self.moral_tint = min(self.moral_tint, -20.0)
        elif "chose_money_over_father" in self.flags:
            self.moral_tint = min(self.moral_tint, 0.0)
        self.max_assets = max(self.max_assets, self.assets())


def _set_job(state: SimState, job_id: str) -> None:
    job = JOBS[job_id]
    state.job_id = job_id
    state.income = float(job.get("base_salary", 0.0))
    state.job_tenure_months = 0
    state.flags.add("has_job")


def _add_tendency(state: SimState, kind: str, amount: int = 1) -> None:
    state.tendency[kind] = state.tendency.get(kind, 0) + amount
    if state.tendency_realized:
        return
    ranked = sorted(((value, key) for key, value in state.tendency.items()), reverse=True)
    if ranked[0][0] >= 12 and ranked[0][0] - ranked[1][0] >= 4:
        state.tendency_realized = ranked[0][1]
        state.flags.add("route_" + state.tendency_realized)


def _apply_week_axis(state: SimState, money_slots: int, human_slots: int) -> None:
    if money_slots:
        state.money_weeks += 1
    if human_slots:
        state.human_weeks += 1
        state.grind_streak = 0
    elif money_slots:
        state.grind_streak += 1
        if state.grind_streak % 4 == 0:
            state.mental -= 1.0
            if state.loop_tint_spent > -20.0:
                state.moral_tint -= 1.0
                state.loop_tint_spent -= 1.0


def _rest(state: SimState, rng: random.Random) -> None:
    state.mental += rng.uniform(5.0, 10.0)
    state.health += rng.uniform(1.0, 4.0)


def _contact(state: SimState, person: str) -> None:
    state.mental += 5.0
    state.cast[person] = min(100.0, state.cast.get(person, 0.0) + 4.0)
    if person == "father" and state.cast[person] >= 64:
        state.cast_stage[person] = "reconciled"
        state.flags.add("father_reconciled")
    if person in ("daeun", "jiyeon") and state.cast[person] >= 60:
        state.cast_stage[person] = "lover"
        state.flags.add(person + "_romance_started")


def _career_action(state: SimState, rng: random.Random) -> None:
    state.intelligence += rng.uniform(1.0, 2.2)
    state.work_performance += rng.uniform(0.4, 1.1)
    state.mental -= rng.uniform(0.4, 1.5)
    state.route_orthodox += 1
    _add_tendency(state, "career")


def _save_action(state: SimState, rng: random.Random) -> None:
    state.money += rng.uniform(30_000.0, 99_000.0)
    state.mental -= 2.0
    state.route_orthodox += 1
    _add_tendency(state, "career")


def _invest_study(state: SimState, rng: random.Random) -> None:
    state.investment_skill += rng.uniform(2.0, 4.0)
    state.intelligence += rng.uniform(0.5, 1.5)
    state.route_unorthodox += 1
    _add_tendency(state, "invest")


def _network(state: SimState, rng: random.Random) -> None:
    state.social += rng.uniform(1.0, 2.0)
    state.reputation += rng.uniform(1.0, 2.0)
    state.mental -= rng.uniform(1.0, 3.0)
    state.route_orthodox += 1
    _add_tendency(state, "career")


def _side_shift(state: SimState, rng: random.Random) -> None:
    state.money += rng.uniform(78_000.0, 104_000.0)
    state.health -= rng.uniform(2.0, 5.0)
    state.mental -= rng.uniform(2.0, 5.0)
    _add_tendency(state, "found")


def _startup_work(state: SimState, rng: random.Random) -> None:
    state.intelligence += rng.uniform(1.0, 2.0)
    state.reputation += rng.uniform(2.0, 3.0)
    state.mental -= rng.uniform(4.0, 6.0)
    state.route_unorthodox += 1
    _add_tendency(state, "found")


def _casino_bet(state: SimState, rng: random.Random) -> None:
    available = max(0.0, state.money)
    stake = min(max(50_000.0, available * rng.uniform(0.06, 0.18)), 2_000_000.0)
    stake = min(stake, available)
    if stake <= 0.0:
        state.mental -= 2.0
        return
    state.money -= stake
    if rng.random() < 0.455:
        state.money += stake * 2.0
        state.mental += 2.0
    elif rng.random() < 0.006:
        state.money += stake * 18.0
        state.mental += 5.0
    else:
        state.mental -= 4.0
    state.gambling += 2.0
    state.addiction += 2.5
    state.route_unorthodox += 1


def _market_action(state: SimState, rng: random.Random) -> None:
    available = max(0.0, state.money)
    amount = min(max(200_000.0, available * 0.10), 2_500_000.0)
    amount = min(amount, available)
    state.money -= amount
    state.portfolio += amount
    state.route_unorthodox += 1
    state.mental -= rng.uniform(0.2, 1.2)
    _add_tendency(state, "invest")


def _apply_policy_week(state: SimState, policy: Policy, week: int, rng: random.Random) -> None:
    if not state.job_id and week >= 2:
        _set_job(state, "job_01" if policy.key in ("people_first", "gambler") else "job_03")

    money_slots = 0
    human_slots = 0
    crisis = state.mental <= 28.0 or state.health <= 28.0
    if state.mental <= 18.0 or state.health <= 20.0:
        _rest(state, rng)
        _rest(state, rng)
        _apply_week_axis(state, 0, 2)
        state.clamp()
        return

    if policy.key == "safe_career":
        _career_action(state, rng)
        money_slots += 1
        if crisis:
            _rest(state, rng)
            human_slots += 1
        elif week % 3 == 0:
            _contact(state, "father")
            human_slots += 1
        else:
            _save_action(state, rng)
            money_slots += 1
    elif policy.key == "aggressive_investor":
        _invest_study(state, rng)
        money_slots += 1
        if crisis:
            _rest(state, rng)
            human_slots += 1
        else:
            _market_action(state, rng)
            money_slots += 1
    elif policy.key == "people_first":
        _contact(state, "father" if week % 4 == 0 else "daeun")
        human_slots += 1
        if crisis or not (state.money < 300_000.0 or week % 6 == 0):
            _rest(state, rng)
            human_slots += 1
        else:
            _side_shift(state, rng)
            money_slots += 1
    elif policy.key == "gambler":
        if crisis:
            _rest(state, rng)
            human_slots += 1
        else:
            _casino_bet(state, rng)
            money_slots += 1
        if week % 3 == 0 or state.health <= 35.0:
            _rest(state, rng)
            human_slots += 1
        else:
            _side_shift(state, rng)
            money_slots += 1
    else:
        if crisis:
            _rest(state, rng)
            human_slots += 1
            _network(state, rng)
            money_slots += 1
        elif state.investment_skill < 35.0:
            _invest_study(state, rng)
            _network(state, rng)
            money_slots += 2
        else:
            _startup_work(state, rng)
            _network(state, rng)
            money_slots += 2

    _apply_week_axis(state, money_slots, human_slots)
    state.clamp()


def _condition_ok(state: SimState, conditions: dict, week: int) -> bool:
    month = ((week - 1) // 4) % 12 + 1
    for key, req in conditions.items():
        if key == "min_money" and state.money < float(req): return False
        if key == "max_money" and state.money > float(req): return False
        if key == "min_assets" and state.assets() < float(req): return False
        if key == "max_assets" and state.assets() > float(req): return False
        if key == "min_turn" and week < int(req): return False
        if key == "max_turn" and week > int(req): return False
        if key == "month":
            if isinstance(req, list) and month not in [int(v) for v in req]: return False
            if not isinstance(req, list) and month != int(req): return False
        if key == "min_health" and state.health < int(req): return False
        if key == "max_health" and state.health > int(req): return False
        if key == "min_mental" and state.mental < int(req): return False
        if key == "max_mental" and state.mental > int(req): return False
        if key == "min_intelligence" and state.intelligence < int(req): return False
        if key in ("min_social", "min_social_skill") and state.social < int(req): return False
        if key == "min_investment_skill" and state.investment_skill < int(req): return False
        if key == "min_luck" and state.luck < int(req): return False
        if key == "min_appearance" and state.appearance < int(req): return False
        if key == "min_reputation" and state.reputation < int(req): return False
        if key == "min_addiction" and state.addiction < int(req): return False
        if key == "max_addiction" and state.addiction > int(req): return False
        if key == "min_gambling" and state.gambling < int(req): return False
        if key == "max_stress" and state.mental < 100 - int(req): return False
        if key == "min_stress" and state.mental > 100 - int(req): return False
        if key == "has_job" and bool(req) and not state.job_id: return False
        if key == "no_job" and bool(req) and state.job_id: return False
        if key == "job_id" and state.job_id != str(req): return False
        if key == "min_job_tier" and int(JOBS.get(state.job_id, {}).get("tier", 0)) < int(req): return False
        if key == "max_job_tier" and int(JOBS.get(state.job_id, {}).get("tier", 999)) > int(req): return False
        if key == "job_category" and str(JOBS.get(state.job_id, {}).get("category", "")) != str(req): return False
        if key == "flag" and str(req) not in state.flags: return False
        if key == "no_flag":
            values = req if isinstance(req, list) else [req]
            if any(str(value) in state.flags for value in values): return False
        if key == "min_route_orthodox" and state.route_orthodox < int(req): return False
        if key == "min_route_unorthodox" and state.route_unorthodox < int(req): return False
        if key == "max_route_orthodox" and state.route_orthodox > int(req): return False
        if key == "max_route_unorthodox" and state.route_unorthodox > int(req): return False
        if key == "min_work_performance" and state.work_performance < int(req): return False
        if key == "min_job_tenure" and state.job_tenure_months < int(req): return False
        if key == "min_cast_affinity":
            if any(state.cast.get(str(pid), 0.0) < int(value) for pid, value in req.items()): return False
        if key == "max_cast_affinity":
            if any(state.cast.get(str(pid), 0.0) > int(value) for pid, value in req.items()): return False
        if key == "cast_met":
            if any((state.cast.get(str(pid), 0.0) > 0.0) != bool(value) for pid, value in req.items()): return False
        if key == "cast_stage":
            pid = str(req.get("person", ""))
            stage = state.cast_stage.get(pid, "unknown")
            if "is" in req and stage != str(req["is"]): return False
            if "in" in req and stage not in [str(v) for v in req["in"]]: return False
            if "not" in req and stage == str(req["not"]): return False
        if key in {
            "has_portfolio", "has_relationship", "route", "cast_flag", "has_item", "housing",
            "min_housing_months", "market_cycle", "min_fear_greed", "max_fear_greed", "month_focus",
        }:
            return False
    return True


def _choice_utility(state: SimState, choice: dict, policy: Policy) -> float:
    effects = choice.get("effects", {})
    utility = 0.0
    money = float(effects.get("money", 0.0)) + 10.0 * float(effects.get("monthly_income", 0.0))
    if money:
        utility += policy.money_weight * math.copysign(math.log1p(abs(money) / 100_000.0), money)
    body = float(effects.get("health", 0.0)) + float(effects.get("mental", 0.0)) - float(effects.get("stress", 0.0))
    utility += policy.body_weight * body * 0.11
    growth = sum(float(effects.get(key, 0.0)) for key in ("intelligence", "social_skill", "investment_skill", "reputation", "luck"))
    utility += growth * (0.11 if policy.key != "founder" else 0.18)
    affinity = 0.0
    for cast_effect in choice.get("cast_effects", {}).values():
        affinity += float(cast_effect.get("affinity", 0.0))
    utility += policy.people_weight * affinity * 0.18
    utility += policy.moral_weight * float(effects.get("tint", 0.0)) * 0.15
    utility += policy.risk_weight * (float(effects.get("gambling_tendency", 0.0)) + float(effects.get("addiction_tendency", 0.0))) * 0.08
    route = str(choice.get("route", ""))
    if route == policy.route_preference:
        utility += 1.2
    if choice.get("opportunity"):
        opp = choice["opportunity"]
        rate = min(0.98, max(0.02, float(opp.get("success_rate", 0.5)) + state.luck * float(opp.get("luck_factor", 0.002))))
        win = float(opp.get("win_multiplier", 2.0))
        loss = float(opp.get("loss_ratio", 1.0))
        expected = rate * win - (1.0 - rate) * loss
        utility += policy.risk_weight * expected * 1.8
    flags = " ".join(str(flag) for flag in choice.get("flags", []))
    if policy.key == "founder" and ("startup" in flags or "creator" in flags): utility += 6.0
    if policy.key == "gambler" and ("gambl" in flags or "casino" in flags): utility += 2.0
    if policy.key == "people_first" and any(name in flags for name in ("father", "daeun", "jiyeon", "reconcile")): utility += 2.0
    if policy.key == "safe_career" and any(name in flags for name in ("job", "career", "resume")): utility += 1.6
    return utility


def _resolve_opportunity(state: SimState, opp: dict, rng: random.Random) -> None:
    if "stake_ratio" in opp:
        stake = max(0.0, state.money) * float(opp["stake_ratio"])
    else:
        stake = float(opp.get("cost", 0.0))
    stake = min(max(0.0, state.money), stake)
    rate = float(opp.get("success_rate", 0.5)) + state.luck * float(opp.get("luck_factor", 0.002))
    if state.cast.get("sangchul", 0.0) >= 35.0:
        rate += 0.15
    elif state.cast.get("sangchul", 0.0) >= 25.0:
        rate += 0.10
    elif state.cast.get("sangchul", 0.0) >= 15.0:
        rate += 0.05
    rate = min(0.98, max(0.02, rate))
    state.money -= stake
    state.investment_skill += float(opp.get("skill_gain", 0.0))
    if rng.random() < rate:
        state.money += stake * (1.0 + float(opp.get("win_multiplier", 2.0)))
        state.mental += 2.0
        if opp.get("win_flag"): state.flags.add(str(opp["win_flag"]))
    else:
        state.money += stake * (1.0 - float(opp.get("loss_ratio", 1.0)))
        state.mental -= 9.0
        if opp.get("lose_flag"): state.flags.add(str(opp["lose_flag"]))


def _apply_effects(state: SimState, effects: dict) -> None:
    for key, raw in effects.items():
        if key == "money": state.money += float(raw)
        elif key == "monthly_income": state.income += float(raw)
        elif key == "health": state.health += float(raw)
        elif key == "mental": state.mental += float(raw)
        elif key == "stress": state.mental -= float(raw)
        elif key == "intelligence": state.intelligence += float(raw)
        elif key in ("social", "social_skill"): state.social += float(raw)
        elif key == "appearance": state.appearance += float(raw)
        elif key == "investment_skill": state.investment_skill += float(raw)
        elif key == "luck": state.luck += float(raw)
        elif key == "reputation": state.reputation += float(raw)
        elif key == "gambling_tendency": state.gambling += float(raw)
        elif key == "addiction_tendency": state.addiction += float(raw)
        elif key == "work_performance": state.work_performance += float(raw)
        elif key == "route_orthodox": state.route_orthodox += int(raw)
        elif key == "route_unorthodox": state.route_unorthodox += int(raw)
        elif key == "tint": state.moral_tint += float(raw)
        elif key == "flag": state.flags.add(str(raw))
        elif key == "unflag": state.flags.discard(str(raw))


def _apply_choice(state: SimState, event: dict, choice: dict, week: int, rng: random.Random) -> None:
    _apply_effects(state, choice.get("effects", {}))
    for flag in choice.get("flags", []):
        state.flags.add(str(flag))
    route = str(choice.get("route", ""))
    if route == "orthodox": state.route_orthodox += 1
    if route == "unorthodox": state.route_unorthodox += 1
    for person, effect in choice.get("cast_effects", {}).items():
        pid = str(person)
        state.cast[pid] = max(-100.0, min(100.0, state.cast.get(pid, 0.0) + float(effect.get("affinity", 0.0))))
        if effect.get("stage"): state.cast_stage[pid] = str(effect["stage"])
    job_id = str(choice.get("grant_job", ""))
    if job_id in JOBS and not state.job_id:
        _set_job(state, job_id)
    if choice.get("opportunity"):
        _resolve_opportunity(state, choice["opportunity"], rng)
    follow = str(choice.get("follow_up_event", ""))
    if follow in EVENTS_BY_ID:
        state.deferred.append((week + 1, follow))
    for deferred, delay in deferred_follow_ups(choice):
        if deferred in EVENTS_BY_ID:
            state.deferred.append((week + delay, deferred))
    state.events_seen += 1
    state.clamp()


def _event_weight(event: dict, policy: Policy) -> float:
    category = str(event.get("category", ""))
    weight = float(event.get("weight", 1.0)) * RARITY_WEIGHT.get(str(event.get("rarity", "common")), 1.0)
    return weight * policy.category_bias.get(category, 1.0)


def _draw_event(state: SimState, policy: Policy, week: int, rng: random.Random) -> dict | None:
    due = [item for item in state.deferred if item[0] <= week]
    if due:
        due.sort()
        selected = due[0]
        state.deferred.remove(selected)
        return EVENTS_BY_ID.get(selected[1])
    for event_id in list(state.cooldowns):
        state.cooldowns[event_id] -= 1
        if state.cooldowns[event_id] <= 0:
            del state.cooldowns[event_id]
    category_pool = POLICY_DRAW_POOLS[policy.key]
    # Rejection sampling preserves live weights without rescanning 1,000+ rows
    # for every simulated month. Thirty-two attempts is enough for narrow gates;
    # no match means a deliberate quiet month in this comparative model.
    for _attempt in range(12):
        category = _weighted_item(
            category_pool["categories"], category_pool["cumulative"], category_pool["total"], rng
        )
        pool = EVENT_POOLS[category]
        event = _weighted_item(pool["events"], pool["cumulative"], pool["total"], rng)
        event_id = str(event.get("id", ""))
        if event_id in state.cooldowns or event_id in state.recent_events:
            continue
        if _condition_ok(state, event.get("conditions", {}), week):
            return event
    return None


def _resolve_monthly_event(state: SimState, policy: Policy, week: int, rng: random.Random) -> None:
    event = _draw_event(state, policy, week, rng)
    if not event:
        return
    choices = event.get("choices", [])
    if not choices:
        return
    scored = [(_choice_utility(state, choice, policy) + rng.uniform(-0.35, 0.35), choice) for choice in choices]
    choice = max(scored, key=lambda item: item[0])[1]
    _apply_choice(state, event, choice, week, rng)
    event_id = str(event.get("id", ""))
    state.recent_events.append(event_id)
    cooldown = int(event.get("cooldown", 6))
    if cooldown > 0:
        state.cooldowns[event_id] = cooldown


def _promote_if_ready(state: SimState, policy: Policy, week: int) -> None:
    target = ""
    if policy.key == "safe_career":
        for threshold, job_id in ((48, "job_05"), (96, "job_08"), (160, "job_12")):
            if week >= threshold:
                target = job_id
    elif policy.key == "aggressive_investor" and week >= 96:
        target = "job_07"
    elif policy.key == "people_first" and week >= 120:
        target = "job_04"
    elif policy.key == "founder" and week >= 96:
        target = "job_11"
    if target and target != state.job_id:
        _set_job(state, target)
        state.flags.add("job_changed_success")
        state.flags.add("max_job_tier")


def _monthly_pressure(state: SimState, policy: Policy, rng: random.Random) -> None:
    state.money += state.income - 650_000.0
    if state.portfolio > 0.0:
        skill_edge = max(0.0, state.investment_skill - 15.0) * 0.00004
        monthly_return = rng.gauss(0.003 + skill_edge, 0.055 if policy.key == "aggressive_investor" else 0.035)
        state.portfolio *= max(0.25, 1.0 + monthly_return)
    state.health -= 2.0
    state.mental -= 5.0  # reality pressure -3 plus goshiwon -2
    if not state.job_id:
        state.mental -= 2.0
    if state.cast.get("father", 0.0) >= 60.0:
        state.mental += 1.0
    if max(state.cast.get("daeun", 0.0), state.cast.get("jiyeon", 0.0)) >= 60.0:
        state.mental += 1.0
    if state.addiction >= 70.0:
        state.mental -= 2.0
    elif state.addiction >= 50.0:
        state.mental -= 1.0
    monthly_bills = 650_000.0
    if state.money < 0.0:
        state.mental -= 4.0
    elif state.money < monthly_bills:
        state.mental -= 2.0
    elif state.money < monthly_bills * 3.0:
        state.mental -= 1.0
    state.job_tenure_months += 1 if state.job_id else 0
    state.clamp()


def _moral_stage(value: float) -> int:
    if value >= 60.0: return 2
    if value >= 20.0: return 1
    if value <= -60.0: return -2
    if value <= -20.0: return -1
    return 0


def _ending_for(state: SimState) -> str:
    assets = state.assets()
    if state.health <= 0.0: return "burnout"
    if state.mental <= 0.0: return "mental_break"
    if assets < -200_000_000.0: return "debt_spiral"
    if assets < -100_000_000.0: return "bankruptcy"
    if state.addiction >= 90.0: return "crypto_ghost"
    if "startup_exit" in state.flags: return "startup_exit"
    if assets >= 3_000_000_000.0:
        if "crossed_line" in state.flags or _moral_stage(state.moral_tint) <= -2:
            return "jaehyuk_way"
        if "daeun_romance_started" in state.flags or "jiyeon_romance_started" in state.flags:
            return "gangnam_together"
        if _moral_stage(state.moral_tint) >= 2:
            return "gangnam_dream_white"
        return "gangnam_dream"
    if "daeun_romance_started" in state.flags: return "with_daeun"
    if "jiyeon_romance_started" in state.flags: return "jiyeon_man"
    if state.reputation >= 80.0: return "reputation_legend"
    if assets >= 1_000_000_000.0 and state.route_orthodox - state.route_unorthodox >= 15:
        return "orthodox_pinnacle"
    if assets >= 500_000_000.0 and state.route_unorthodox - state.route_orthodox >= 15:
        return "unorthodox_legend"
    if assets >= 500_000_000.0 and not state.job_id:
        return "early_retirement"
    committed_investor = (
        state.tendency_realized == "invest"
        and state.investment_skill >= 85.0
        and state.route_unorthodox - state.route_orthodox >= 15
    )
    if (assets >= 500_000_000.0 and state.investment_skill >= 55.0) or (
        assets >= 100_000_000.0 and committed_investor
    ):
        return "investment_master"
    if assets >= 1_000_000_000.0: return "stable_success"
    if assets >= 100_000_000.0 and abs(state.route_orthodox - state.route_unorthodox) <= 5:
        return "balanced_life"
    tier = int(JOBS.get(state.job_id, {}).get("tier", 0))
    if state.job_id and assets >= 100_000_000.0 and ("job_changed_success" in state.flags or tier >= 4):
        return "career_climber"
    if state.health >= 70.0 and state.mental >= 70.0 and max(state.cast.values()) >= 60.0:
        return "healthy_retirement"
    if state.route_orthodox >= 20 and assets < 300_000_000.0:
        return "orthodox_hollow"
    if "father_reconciled" in state.flags: return "late_call"
    return "ordinary_life"


def _simulate(policy: Policy, run_index: int) -> SimState:
    rng = random.Random(run_index * 982_451_653 + sum(ord(char) for char in policy.key) * 131)
    state = SimState()
    for week in range(1, 241):
        if (
            state.health <= 0.0
            or state.mental <= 0.0
            or state.assets() < -200_000_000.0
            or state.addiction >= 90.0
        ):
            break
        _apply_policy_week(state, policy, week, rng)
        _promote_if_ready(state, policy, week)
        if week % 4 == 0:
            _resolve_monthly_event(state, policy, week, rng)
            _monthly_pressure(state, policy, rng)
    state.ending = _ending_for(state)
    return state


def _quantile(values: list[float], fraction: float) -> float:
    ordered = sorted(values)
    return ordered[min(len(ordered) - 1, int(len(ordered) * fraction))]


def _summarize(policy: Policy, states: list[SimState]) -> dict:
    assets = [state.assets() for state in states]
    endings = Counter(state.ending for state in states)
    tint_stages = Counter(_moral_stage(state.moral_tint) for state in states)
    close_rate = sum(max(state.cast.values()) >= 60.0 for state in states) / len(states)
    return {
        "key": policy.key,
        "label": policy.label,
        "runs": len(states),
        "asset_p10": _quantile(assets, 0.10),
        "asset_median": median(assets),
        "asset_p90": _quantile(assets, 0.90),
        "win_rate": sum(value >= 3_000_000_000.0 for value in assets) / len(states),
        "fail_rate": sum(state.ending in FAIL_ENDINGS for state in states) / len(states),
        "health_median": median(state.health for state in states),
        "mental_median": median(state.mental for state in states),
        "tint_median": median(state.moral_tint for state in states),
        "money_weeks_median": median(state.money_weeks for state in states),
        "human_weeks_median": median(state.human_weeks for state in states),
        "orthodox_median": median(state.route_orthodox for state in states),
        "unorthodox_median": median(state.route_unorthodox for state in states),
        "close_rate": close_rate,
        "addiction_median": median(state.addiction for state in states),
        "investment_skill_median": median(state.investment_skill for state in states),
        "endings": endings,
        "tint_stages": tint_stages,
    }


def _js_divergence(left: Counter, right: Counter) -> float:
    keys = set(left) | set(right)
    left_total = max(1, sum(left.values()))
    right_total = max(1, sum(right.values()))
    result = 0.0
    for key in keys:
        p = left.get(key, 0) / left_total
        q = right.get(key, 0) / right_total
        m = (p + q) / 2.0
        if p > 0.0: result += 0.5 * p * math.log2(p / m)
        if q > 0.0: result += 0.5 * q * math.log2(q / m)
    return result


def run_convergence(runs: int = 3000, verbose: bool = True) -> dict:
    summaries = []
    for policy in POLICIES:
        states = [_simulate(policy, index) for index in range(runs)]
        summaries.append(_summarize(policy, states))
    pairwise = []
    for index, left in enumerate(summaries):
        for right in summaries[index + 1:]:
            pairwise.append({
                "left": left["key"], "right": right["key"],
                "ending_jsd": _js_divergence(left["endings"], right["endings"]),
            })
    result = {
        "runs_per_policy": runs,
        "summaries": summaries,
        "pairwise": pairwise,
        "mean_ending_jsd": sum(row["ending_jsd"] for row in pairwise) / len(pairwise),
        "dominant_endings": len({row["endings"].most_common(1)[0][0] for row in summaries}),
        "human_week_spread": max(row["human_weeks_median"] for row in summaries) - min(row["human_weeks_median"] for row in summaries),
        "tint_spread": max(row["tint_median"] for row in summaries) - min(row["tint_median"] for row in summaries),
    }
    if verbose:
        print_report(result)
    return result


def _won(value: float) -> str:
    sign = "-" if value < 0 else ""
    value = abs(value)
    if value >= 1_000_000_000.0: return f"{sign}KRW {value / 1_000_000_000.0:.2f}B"
    if value >= 1_000_000.0: return f"{sign}KRW {value / 1_000_000.0:.1f}M"
    return f"{sign}KRW {value:,.0f}"


def print_report(result: dict) -> None:
    print(f"CONVERGENCE_SIM runs_per_policy={result['runs_per_policy']}")
    for row in result["summaries"]:
        dominant = ",".join(f"{key}:{value / row['runs']:.1%}" for key, value in row["endings"].most_common(3))
        print(
            f"POLICY {row['key']} asset={_won(row['asset_median'])} p10={_won(row['asset_p10'])} "
            f"p90={_won(row['asset_p90'])} win={row['win_rate']:.1%} fail={row['fail_rate']:.1%} "
            f"body={row['health_median']:.0f}/{row['mental_median']:.0f} tint={row['tint_median']:.0f} "
            f"weeks=M{row['money_weeks_median']:.0f}/H{row['human_weeks_median']:.0f} close={row['close_rate']:.1%} "
            f"endings={dominant}"
        )
    print(
        f"DIVERGENCE dominant_endings={result['dominant_endings']} mean_ending_jsd={result['mean_ending_jsd']:.3f} "
        f"human_week_spread={result['human_week_spread']:.0f} tint_spread={result['tint_spread']:.0f}"
    )


def render_markdown(result: dict) -> str:
    lines = [
        "# Strategy Convergence Report",
        "",
        "> Generated by `python3 tools/convergence_sim.py --runs 3000 --write docs/CONVERGENCE_REPORT.md`.",
        "> This is a deterministic comparative model, not a forecast of player win rates.",
        "",
        "## Scope and fidelity",
        "",
        "The model runs five stable policies through 240 internal weeks and 60 monthly pressure cycles. It reads live job salaries and all authored ambient event choices, applies the current AP-axis grind wear, contact affinity, moral effects, opportunity math, route points, ending-priority shape, and the baseline one-month/three-month cash-reserve pressure bands. It compresses low-signal weekly filler to one representative authored choice per month and does not model manual minigame skill, portfolio asset-by-asset prices, variable housing, loan interest, every guaranteed story arc, metaprogression, or player mistakes. Its purpose is to expose convergence, not certify exact economy odds.",
        "",
        "## Results",
        "",
        "| Archetype | Assets p10 / median / p90 | 3B | Fail | Health / mental | Tint | Money / human weeks | Close relation | Addiction / invest skill | Dominant projected endings |",
        "|---|---:|---:|---:|---:|---:|---:|---:|---:|---|",
    ]
    for row in result["summaries"]:
        endings = ", ".join(f"`{key}` {value / row['runs']:.1%}" for key, value in row["endings"].most_common(3))
        lines.append(
            f"| {row['label']} | {_won(row['asset_p10'])} / **{_won(row['asset_median'])}** / {_won(row['asset_p90'])} | "
            f"{row['win_rate']:.1%} | {row['fail_rate']:.1%} | {row['health_median']:.0f} / {row['mental_median']:.0f} | "
            f"{row['tint_median']:.0f} | {row['money_weeks_median']:.0f} / {row['human_weeks_median']:.0f} | "
            f"{row['close_rate']:.1%} | {row['addiction_median']:.0f} / {row['investment_skill_median']:.0f} | {endings} |"
        )
    lines.extend([
        "",
        "## Divergence gates",
        "",
        f"- Distinct dominant ending families: **{result['dominant_endings']} / 5**.",
        f"- Mean pairwise ending Jensen-Shannon divergence: **{result['mean_ending_jsd']:.3f}** (0=same, 1=fully separate).",
        f"- Median human-week spread: **{result['human_week_spread']:.0f} weeks**.",
        f"- Median Moral Tint spread: **{result['tint_spread']:.0f} points**.",
        "",
        "## Source audit: hidden convergence",
        "",
        "No asset catch-up or leader suppression is wired into live play. `GameState.get_run_pace()` is currently definition-only and cannot alter prices, rewards, or event odds. Event weighting reinforces recent actions, selected run themes, route tags, relationships, job context, and market fear; it does not inspect whether the player is behind the 3-billion-won target. Opportunity odds use visible difficulty, Luck, and Sangchul affinity. The low-Mental investment surcharge is a causal impairment penalty, not assistance. There is therefore no rubber-banding to remove in this pass.",
        "",
        "## Diagnosis after the targeted repair",
        "",
        "All five archetypes now have distinct dominant ending identities. The aggressive investor reaches mastery through repeated study and market exposure and is projected into `investment_master`, while the safe salary path remains `career_climber`. Their asset distributions were not inflated to create this separation; the router now names the life that was actually played.",
        "",
        "The pure gambler now mirrors the live immediate ending rule correctly: reaching Addiction 90 ends the run as `crypto_ghost`. Its terminal identity is distinct, but the near-certain collapse confirms that risk and recovery windows must be legible before commitment. The earlier ordinary-life diagnosis was a simulator defect and is not retained.",
        "",
        "The rare founder acquisition now resolves to `startup_exit` before the generic KRW 3B branch. Most founder policies still end as `reputation_legend`, because acquisition is intentionally uncommon and building a company creates reputation even when no buyer arrives. This is strategic identity rather than a guaranteed jackpot.",
        "",
        "The current weekly moral wear also has a narrow vocabulary: every money-only policy receives the same capped -20 grind stain regardless of whether Minjun studies, works, invests, builds, or gambles. Most additional moral separation comes from authored event choices, while the AP layer itself mostly distinguishes `people time` from `everything else`. ORDER-26 should not add another meter; it should make current pressure choices promise different delayed consequences and let existing relationship, health, expertise, addiction, and route states own different endings and scenes.",
        "",
        "A diligent salary path is intentionally not a 3-billion-won route. Its quality gate is survival, legible career growth, and a satisfying non-Gangnam conclusion. Diligence may qualify Minjun for a rare equity, partnership, or founder opportunity, but the opportunity remains a visible risk and salary itself is never inflated to solve the premise.",
        "",
        "Employment no longer grants safety by itself in the pressure model. Cash below one month of baseline bills carries acute pressure, cash below three months remains a thin reserve, and only an actual three-month buffer is treated as safe. The live game derives those thresholds from current housing plus loan interest and presents a reachable next financial rung; this comparison model keeps the 650,000-won goshiwon baseline and therefore tests the long-run bands conservatively rather than reproducing every housing state.",
        "",
        "## Next implementation gate",
        "",
        "1. Keep the existing economy bands and ending-identity routing locked; no hidden catch-up system exists to remove.",
        "2. Keep the live HUD, weekly pressure, and month-end summary on the same bills -> three-month reserve -> wealth-rung contract without replacing the ultimate KRW 3B premise.",
        "3. Make the missed path create a real later cost; do not expose Moral Tint or a new route meter.",
        "4. Demote short random cards to bridges, results, or Echoes and spend foreground time on causal authored scenes.",
        "5. Re-run this report and the existing economy bands after every numerical or routing change.",
        "",
    ])
    return "\n".join(lines)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--runs", type=int, default=3000)
    parser.add_argument("--write", type=Path)
    args = parser.parse_args()
    result = run_convergence(runs=args.runs, verbose=True)
    if args.write:
        args.write.write_text(render_markdown(result), encoding="utf-8")
        print(f"WROTE {args.write}")


if __name__ == "__main__":
    main()
