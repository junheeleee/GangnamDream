#!/usr/bin/env python3
"""밸런스 QA — GameState 경제 척추의 Python 포트 시뮬레이터.

SimRun.gd(헤드리스 60턴 시뮬)와 동일한 정책 봇 구조를 따르되,
2026-06-11 추가된 인연 월간 패시브·상철 정보 이벤트의 영향을
켜고/끄고 비교 측정한다. Godot 없이 돌릴 수 있는 게 목적.

미모델(SimRun과 동일한 한계): 랜덤 이벤트 스탯 노이즈, 정밀 AP,
포트폴리오 시장 가격 변동. 급여 고정, 휴식은 대표값.
"""
import json
import math
import random
import re
from collections import Counter
from pathlib import Path

# SimRun.gd와 동일한 기회 파라미터
OPPS = [
    {"stake_ratio": 0.30, "success_rate": 0.44, "win_multiplier": 2.0, "loss_ratio": 0.55},
    {"stake_ratio": 0.70, "success_rate": 0.42, "win_multiplier": 2.8, "loss_ratio": 0.55},
    {"stake_ratio": 0.80, "success_rate": 0.38, "win_multiplier": 4.0, "loss_ratio": 0.75},
    {"stake_ratio": 0.60, "success_rate": 0.36, "win_multiplier": 3.5, "loss_ratio": 0.60},
]
OPP_MEGA = {"stake_ratio": 0.65, "success_rate": 0.40, "win_multiplier": 7.0, "loss_ratio": 0.70}
# 신규: sangchul_tip_redev (investment_events.json)
OPP_SANGCHUL = {"stake_ratio": 0.40, "success_rate": 0.62, "win_multiplier": 1.8, "loss_ratio": 0.50}
SALARY = 2_240_000.0
LUCK_FACTOR = 0.0015

ROOT = Path(__file__).resolve().parents[1]
RARITY_WEIGHT = {"common": 1.0, "uncommon": 0.7, "rare": 0.28, "legendary": 0.08}
# Representative eligible-pool weight measured from the live event catalog at
# weeks 40/100/160/200. The snapshots ranged from 327 to 356, so 340 is used
# as a fixed conservative denominator for deterministic route comparisons.
ROUTE_EVENT_POOL_WEIGHT = 340.0
CHAPTER5_CAUSAL_ROUTE = ROOT / "systems" / "Chapter5CausalRoute.gd"
PROPERTY_ENTRY_WEEK = 193
PROPERTY_ENTRY_MIN_ASSETS = 2_000_000_000.0
PROPERTY_LADDER_CHOICES = {
    "inv_ipo_hot_tip": 0,
    "sangchul_tip_redev": 0,
    "arc_opp_sangchul_realty": 1,
    "inv_redev_zone_tip": 1,
    "inv_redev_completion_sale": 0,
}


def settle_cash(value):
    """Match GameState.settle_cash: nearest won, exact .5 away from zero."""
    value = float(value)
    if not math.isfinite(value):
        raise ValueError("cash transaction must be finite")
    if value >= 0.0:
        return float(math.floor(value + 0.5))
    return float(math.ceil(value - 0.5))


def _load_route_events():
    wanted = {
        "startup_opportunity",
        "startup_acquisition_offer",
        "inv_ipo_hot_tip",
        "sangchul_tip_redev",
        "arc_opp_sangchul_realty",
        "inv_redev_zone_tip",
        "inv_redev_completion_sale",
    }
    found = {}
    for path in (ROOT / "content" / "events").glob("*.json"):
        for event in json.loads(path.read_text(encoding="utf-8")):
            event_id = str(event.get("id", ""))
            if event_id in wanted:
                found[event_id] = event
    missing = wanted - set(found)
    if missing:
        raise RuntimeError("route simulation events missing: %s" % sorted(missing))
    return found


ROUTE_EVENTS = _load_route_events()


# 난이도 (GameState.DIFFICULTY_DATA 포트, 2026-06-11)
DIFFICULTY = {
    "드라마": {"start_money": 2_000_000, "start_stress": 30, "ph": -1, "pm": -2, "ps": 2, "opp": 0.04},
    "현실":   {"start_money": 500_000,   "start_stress": 35, "ph": -2, "pm": -3, "ps": 3, "opp": 0.0},
    "지옥고": {"start_money": 300_000,   "start_stress": 45, "ph": -3, "pm": -4, "ps": 5, "opp": -0.04},
}


class Run:
    def __init__(self, diff="현실", defer_late_success=False):
        self.diff = DIFFICULTY[diff]
        # Product success endings wait for the W240 finale after the first year.
        # Legacy 64-turn comparisons keep their historical immediate behavior;
        # the full property route opts into the current product rule explicitly.
        self.defer_late_success = defer_late_success
        self.money = float(self.diff["start_money"])
        self.loans = {"bank": 0.0, "second": 0.0}
        self.tenure = 0
        self.income = 0.0
        self.health = 65
        self.mental = 60
        self.stress = self.diff["start_stress"]
        self.luck = 45
        self.inv_skill = 15
        self.turn = 1
        self.age = 33
        self.month = 1
        self.over = None  # ending id
        self.housing = "gosiwon"

    def clamp(self):
        self.health = max(0, min(100, self.health))
        self.mental = max(0, min(100, self.mental))
        self.stress = max(0, min(100, self.stress))
        self.inv_skill = max(0, min(100, self.inv_skill))

    def assert_whole_cash(self, label):
        if not math.isfinite(self.money) or self.money != math.floor(self.money):
            raise AssertionError("fractional/non-finite cash at %s: %r" % (label, self.money))

    def add_cash(self, raw_delta):
        """Settle one transaction exactly once before touching cash."""
        self.assert_whole_cash("before raw transaction")
        settled = settle_cash(raw_delta)
        self.money += settled
        self.assert_whole_cash("after raw transaction")
        return settled

    def add_settled_cash(self, settled_delta):
        self.assert_whole_cash("before settled transaction")
        settled_delta = float(settled_delta)
        if not math.isfinite(settled_delta) or settled_delta != math.floor(settled_delta):
            raise ValueError("settled cash delta must be a whole won amount")
        self.money += settled_delta
        self.assert_whole_cash("after settled transaction")
        return settled_delta

    def resolve_opportunity(self, opp, rng=None, sangchul_affinity=0):
        available = max(0.0, settle_cash(self.money))
        raw_stake = float(opp.get("cost", 0.0))
        if "stake_ratio" in opp:
            raw_stake = available * float(opp["stake_ratio"])
        stake = settle_cash(raw_stake)
        if stake < 1.0 or stake > available:
            return False
        luck_factor = float(opp.get("luck_factor", LUCK_FACTOR))
        rate = opp["success_rate"] + self.luck * luck_factor + self.diff["opp"]
        if sangchul_affinity >= 35:
            rate += 0.15
        elif sangchul_affinity >= 25:
            rate += 0.10
        elif sangchul_affinity >= 15:
            rate += 0.05
        rate = max(0.02, min(0.98, rate))
        roll = rng.random() if rng is not None else random.random()
        if roll < rate:
            self.add_settled_cash(settle_cash(stake * opp["win_multiplier"]))
            self.stress -= 3
            won = True
        else:
            loss = settle_cash(stake * max(0.0, min(1.0, opp["loss_ratio"])))
            self.add_settled_cash(-loss)
            self.stress += 12
            self.mental -= 6
            won = False
        self.clamp()
        return won

    def loan_total(self):
        return sum(self.loans.values())

    def net_worth(self):
        return self.money - self.loan_total()

    # 신용등급 (GameState.get_credit_score/grade 포트, 2026-06-11)
    def credit_grade(self, tenure=0, was_broke=False):
        s = 30.0
        if self.income > 0:
            s += 15.0 + min(tenure * 0.5, 12.0) + min(self.income / 1_000_000 * 2.0, 14.0)
        s += max(0.0, min(self.net_worth() / 10_000_000, 20.0))
        debt = self.loan_total()
        if debt > 0:
            s -= debt / max(1.0, max(0.0, self.net_worth()) + debt) * 25.0
        if was_broke:
            s -= 8.0
        s = max(1, min(100, int(s)))
        return max(1, min(10, 10 - (s - 5) // 10))

    def loan_limit(self, product, tenure=0):
        g = self.credit_grade(tenure)
        if product == "bank":
            if self.income <= 0 or g >= 8:
                return 0.0
            return self.income * (20 - 2 * g)
        return 10_000_000 + (10 - g) * 4_000_000

    def loan_rate(self, product, tenure=0):
        g = self.credit_grade(tenure)
        if product == "bank":
            return min(0.004 + (g - 1) * 0.0008, 0.0153)
        return min(0.011 + (g - 1) * 0.0005, 0.0153)

    def monthly_pressure(self, cast_passives=False, lover=False, father=False, sangchul=False):
        expense = 650_000.0  # 고시원 고정 (SimRun 동일)
        self.add_cash(self.income - expense)
        # 대출 이자 (2026-06-11 신규, 변동금리 — 신용등급 기준)
        interest = sum(self.loans[p] * self.loan_rate(p, self.tenure) for p in self.loans)
        if interest > 0:
            self.add_settled_cash(-settle_cash(interest))
            self.stress += 2
        self.health += self.diff["ph"]
        self.mental += self.diff["pm"]
        self.stress += self.diff["ps"]
        # 고시원 패시브
        self.stress += 2
        self.mental -= 1
        # 인연 패시브 (2026-06-11 신규)
        if cast_passives:
            if father:
                self.mental += 1
            if lover:
                self.stress -= 2
            if sangchul and self.turn % 4 == 0:
                self.inv_skill += 1
        # 무직 압박
        if self.income == 0:
            self.mental -= 2
            self.stress += 3
        self.clamp()
        # 스트레스 단계 피해
        if self.stress >= 80:
            self.health -= 4
            self.mental -= 4
        elif self.stress >= 60:
            self.health -= 2
            self.mental -= 2
        elif self.stress >= 40:
            self.mental -= 1
        # 현금 위기: 취업 여부가 아니라 실제 고시원 고정비 1/3개월치로 판정.
        if self.money < 0:
            self.stress += 12
            self.mental -= 5
        elif self.money < expense:
            self.stress += 8
            self.mental -= 4
        elif self.money < expense * 3.0:
            self.mental -= 1
        self.clamp()
        self.check_over()

    def check_over(self):
        if self.over:
            return
        if self.health <= 0:
            self.over = "burnout"; return
        if self.mental <= 0:
            self.over = "mental_break"; return
        net = self.net_worth()
        if net < -200_000_000:
            self.over = "debt_spiral"; return
        if net < -100_000_000:
            self.over = "bankruptcy"; return
        if net >= 3_000_000_000 \
                and not (self.defer_late_success and self.age > 33):
            self.over = "gangnam_dream(30억)"; return
        if self.age >= 38:
            if net >= 1_000_000_000:
                self.over = "stable_success(10억+)"
            elif net >= 500_000_000:
                self.over = "mid_success(5억+)"
            elif net >= 100_000_000:
                self.over = "1억+"
            else:
                self.over = "ordinary(1억 미만)"

    def advance(self):
        self.turn += 1
        self.month += 1
        if self.month > 12:
            self.month = 1
            self.age += 1


def run_policy(name, mode, runs=3000, cast_passives=False, sangchul_tips=False, use_loans=False, diff="현실"):
    endings = Counter()
    assets = []
    reached30 = 0
    for r in range(runs):
        random.seed(r * 7919 + mode * 131 + (1000 if cast_passives else 0))
        s = Run(diff)
        employed = False
        tip_cd = 0
        while not s.over and s.turn <= 64:
            t = s.turn
            if tip_cd > 0:
                tip_cd -= 1
            # 취업은 컨디션과 무관하게 최우선 (실제 플레이어 행동)
            if mode >= 1 and not employed and t >= 2:
                s.income = SALARY
                employed = True
            # 생존 유지: 위험하면 휴식 (SimRun 대표값)
            if s.mental <= 30 or s.stress >= 58:
                s.mental += 10
                s.health += 5
                s.stress -= 20
                s.clamp()
            else:
                # 대출 레버리지: 신용등급이 허락하는 한도까지 당겨 종잣돈으로
                if use_loans and employed and t >= 4:
                    for prod in ("bank", "second"):
                        limit = s.loan_limit(prod, s.tenure)
                        if s.loans[prod] < limit and (prod == "bank" or s.money < 20_000_000):
                            amt = settle_cash(limit - s.loans[prod])
                            if amt < 1.0:
                                continue
                            s.loans[prod] += amt
                            s.add_settled_cash(amt)
                    # 자산이 빚의 5배를 넘으면 전액 상환 (이자 절감)
                    if s.loan_total() > 0 and s.money > s.loan_total() * 5:
                        s.add_settled_cash(-settle_cash(s.loan_total()))
                        s.loans = {"bank": 0.0, "second": 0.0}
                # 상철 팁 — 신뢰 단계 + 쿨다운 12 + 자금 1천만 이상
                if sangchul_tips and tip_cd == 0 and t >= 10 and s.money > 10_000_000 and random.random() < 0.5:
                    s.resolve_opportunity(OPP_SANGCHUL)
                    tip_cd = 12
                elif mode == 2 and employed and s.money > 3_000_000 and random.random() < 0.25:
                    s.resolve_opportunity(random.choice(OPPS))
                elif mode == 3 and employed and s.money > 1_000_000 and random.random() < 0.6:
                    if s.money > 200_000_000 and t >= 28 and random.random() < 0.5:
                        s.resolve_opportunity(OPP_MEGA)
                    else:
                        s.resolve_opportunity(random.choice(OPPS))
            if employed:
                s.tenure += 1
            if s.turn <= 3:
                s.add_cash(300_000)
            s.monthly_pressure(cast_passives=cast_passives, lover=cast_passives,
                               father=cast_passives, sangchul=cast_passives)
            if t in (24, 48):
                s.assert_whole_cash("baseline turn %d" % t)
            if s.over:
                break
            s.advance()
        if not s.over:
            s.age = 38
            s.check_over()
        assets.append(s.net_worth())
        if s.net_worth() >= 3_000_000_000:
            reached30 += 1
        endings[s.over or "(미종료)"] += 1
    assets.sort()
    med = assets[runs // 2]
    p90 = assets[int(runs * 0.9)]
    mx = assets[-1]
    fail = sum(v for k, v in endings.items() if k in ("burnout", "mental_break", "bankruptcy", "debt_spiral"))
    print(f"\n[{name}]  {runs}런")
    print(f"  자산 중앙값 {won(med)} | p90 {won(p90)} | 최대 {won(mx)} | 30억 도달 {reached30} ({100*reached30/runs:.1f}%) | 실패엔딩 {100*fail/runs:.1f}%")
    line = "  엔딩: " + "  ".join(f"{k} {v}({100*v/runs:.0f}%)" for k, v in endings.most_common())
    print(line)
    return {"win_rate": reached30 / runs, "fail_rate": fail / runs, "median": med}


def _event_weight(event_id, focused=False, trusted_sangchul=False):
    event = ROUTE_EVENTS[event_id]
    weight = float(event.get("weight", 1.0)) * RARITY_WEIGHT.get(event.get("rarity", "common"), 1.0)
    if focused:
        weight *= 1.25  # EventManager month_focus tag boost
    if trusted_sangchul and (
        event.get("category", "") == "investment" or "investment" in event.get("tags", [])
    ):
        weight *= 1.25  # EventManager max Sangchul-affinity curation boost
    return weight


def _draw_route_event(rng, event_ids, focused=False, trusted_sangchul=False):
    roll = rng.random() * ROUTE_EVENT_POOL_WEIGHT
    cursor = 0.0
    for event_id in event_ids:
        cursor += _event_weight(event_id, focused, trusted_sangchul)
        if roll <= cursor:
            return event_id
    return ""


def _event_choice(event_id, choice_index=0):
    choices = ROUTE_EVENTS[event_id].get("choices", [])
    if choice_index < 0 or choice_index >= len(choices):
        raise RuntimeError("route simulation choice missing: %s[%d]" % (event_id, choice_index))
    return choices[choice_index]


def _apply_fixed_money_choice(state, event_id, choice_index=0):
    choice = _event_choice(event_id, choice_index)
    state.add_cash(float(choice.get("effects", {}).get("money", 0.0)))
    return choice


def _deferred_delay(event_id, choice_index, target_id):
    for follow_up in _event_choice(event_id, choice_index).get(
        "deferred_follow_up", []
    ):
        if isinstance(follow_up, str):
            continue
        event_target = str(follow_up.get("id", follow_up.get("event_id", "")))
        if event_target == target_id:
            return int(follow_up.get("delay", 0))
    raise AssertionError("missing deferred route edge: %s -> %s" % (event_id, target_id))


def _property_ladder_contract():
    expected = {
        "inv_ipo_hot_tip": (49, 72, 10_000_000.0),
        "sangchul_tip_redev": (73, 96, 10_000_000.0),
        "arc_opp_sangchul_realty": (82, 111, 50_000_000.0),
        "inv_redev_zone_tip": (112, 143, 80_000_000.0),
    }
    for event_id, (min_week, max_week, min_money) in expected.items():
        conditions = ROUTE_EVENTS[event_id].get("conditions", {})
        actual = (
            int(conditions.get("min_turn", 0)),
            int(conditions.get("max_turn", 0)),
            float(conditions.get("min_money", 0.0)),
        )
        assert actual == (min_week, max_week, min_money), (
            "property ladder threshold/window drift: %s expected=%r got=%r"
            % (event_id, (min_week, max_week, min_money), actual)
        )

    sale_min_week = int(
        ROUTE_EVENTS["inv_redev_completion_sale"]
        .get("conditions", {})
        .get("min_turn", 0)
    )
    assert sale_min_week == 160, "property sale minimum week was lowered"
    sale_money = float(
        _event_choice("inv_redev_completion_sale", 0)
        .get("effects", {})
        .get("money", 0.0)
    )
    assert sale_money == 2_600_000_000.0, "property sale cash drifted"

    delays = {
        "ipo_close": _deferred_delay(
            "inv_ipo_hot_tip", 0, "callback_inv_ipo_hot_tip_win_listing"
        ),
        "tip_close": _deferred_delay(
            "sangchul_tip_redev", 0, "callback_sangchul_tip_win_payoff"
        ),
        "villa_result": _deferred_delay(
            "arc_opp_sangchul_realty", 1, "arc_opp_sangchul_win"
        ),
        "management": _deferred_delay(
            "inv_redev_zone_tip", 1, "callback_redev_bet_taken_result"
        ),
        "sale": _deferred_delay(
            "inv_redev_zone_tip", 1, "inv_redev_completion_sale"
        ),
    }
    assert delays == {
        "ipo_close": 1,
        "tip_close": 8,
        "villa_result": 8,
        "management": 24,
        "sale": 48,
    }, "property ladder deferred cadence drifted: %r" % delays

    source = CHAPTER5_CAUSAL_ROUTE.read_text(encoding="utf-8")
    match = re.search(
        r"const\s+ENTRY_MIN_TOTAL_ASSETS\s*:=\s*([0-9_]+(?:\.[0-9]+)?)",
        source,
    )
    assert match is not None, "Chapter5 property entry threshold is unreadable"
    live_entry_min = float(match.group(1).replace("_", ""))
    assert live_entry_min == PROPERTY_ENTRY_MIN_ASSETS, (
        "Chapter5 property entry threshold drifted: %r" % live_entry_min
    )
    return {"sale_min_week": sale_min_week, "delays": delays}


def _apply_authored_opportunity_result(state, event_id, choice_index, won):
    choice = _event_choice(event_id, choice_index)
    assert float(choice.get("effects", {}).get("money", 0.0)) == 0.0, (
        "property opportunity acquired an injected fixed-money effect: %s" % event_id
    )
    opportunity = choice.get("opportunity", {})
    assert isinstance(opportunity, dict) and opportunity, (
        "property reference choice has no opportunity: %s" % event_id
    )
    available = max(0.0, settle_cash(state.money))
    stake = settle_cash(
        available * float(opportunity.get("stake_ratio", 0.0))
        if "stake_ratio" in opportunity
        else float(opportunity.get("cost", 0.0))
    )
    assert 1.0 <= stake <= available, "invalid property reference stake: %s" % event_id
    before = state.money
    if won:
        state.add_settled_cash(
            settle_cash(stake * float(opportunity.get("win_multiplier", 2.0)))
        )
    else:
        state.add_settled_cash(
            -settle_cash(stake * float(opportunity.get("loss_ratio", 1.0)))
        )
    return {"week": 0, "before": before, "stake": stake, "after": state.money}


def property_ladder_reference_progression(diff="현실"):
    """Prove one authored success path reaches the locked M49 property route.

    The proof starts at W1 with the live difficulty seed and adds only net
    salary/rent plus authored opportunity profits and the authored final sale.
    It does not lower a door, repeat a tip, or grant bridge cash.
    """
    contract = _property_ladder_contract()
    state = Run(diff, defer_late_success=True)
    state.income = SALARY
    event_weeks = {
        "inv_ipo_hot_tip": 49,
        "sangchul_tip_redev": 73,
        "arc_opp_sangchul_realty": 82,
        "inv_redev_zone_tip": 112,
        "inv_redev_completion_sale": 160,
    }
    receipts = {
        "ipo_close": 50,
        "tip_close": 81,
        "villa_result": 90,
        "management": 136,
        "sale": 160,
    }
    assert receipts["ipo_close"] == event_weeks["inv_ipo_hot_tip"] + contract["delays"]["ipo_close"]
    assert receipts["tip_close"] == event_weeks["sangchul_tip_redev"] + contract["delays"]["tip_close"]
    assert receipts["villa_result"] == event_weeks["arc_opp_sangchul_realty"] + contract["delays"]["villa_result"]
    assert receipts["management"] == event_weeks["inv_redev_zone_tip"] + contract["delays"]["management"]
    assert event_weeks["inv_redev_completion_sale"] == max(
        contract["sale_min_week"],
        event_weeks["inv_redev_zone_tip"] + contract["delays"]["sale"],
    )

    ledger = []
    for week in range(1, PROPERTY_ENTRY_WEEK + 1):
        for event_id, event_week in event_weeks.items():
            if week != event_week:
                continue
            conditions = ROUTE_EVENTS[event_id].get("conditions", {})
            min_money = float(conditions.get("min_money", 0.0))
            assert state.money >= min_money, (
                "reference cash missed live %s door at W%d: %.0f < %.0f"
                % (event_id, week, state.money, min_money)
            )
            if event_id == "inv_redev_completion_sale":
                before = state.money
                _apply_fixed_money_choice(
                    state, event_id, PROPERTY_LADDER_CHOICES[event_id]
                )
                row = {"week": week, "before": before, "stake": 0.0, "after": state.money}
            else:
                row = _apply_authored_opportunity_result(
                    state, event_id, PROPERTY_LADDER_CHOICES[event_id], True
                )
                row["week"] = week
            row["event_id"] = event_id
            ledger.append(row)

        # Cash proof intentionally omits the old simulator's W4 bonus. Only
        # earned salary less the live representative rent grows the seed.
        if week % 4 == 0:
            state.add_cash(state.income - 650_000.0)

    assert [row["event_id"] for row in ledger] == list(event_weeks), (
        "property reference repeated or skipped a ladder root"
    )
    assert state.net_worth() >= PROPERTY_ENTRY_MIN_ASSETS, (
        "reference ladder missed M49 property entry: %.0f < %.0f"
        % (state.net_worth(), PROPERTY_ENTRY_MIN_ASSETS)
    )
    return {
        "entry_week": PROPERTY_ENTRY_WEEK,
        "entry_assets": state.net_worth(),
        "entry_min": PROPERTY_ENTRY_MIN_ASSETS,
        "ledger": ledger,
        "receipts": receipts,
    }


def run_route_policy(name, route, runs=3000, diff="현실"):
    """Run a route-focused 240-week policy against live event parameters.

    Like the baseline simulator, generic event stat noise and portfolio ticks are
    intentionally omitted. The startup comparison retains its weighted weekly
    exposure. The property comparison follows MainGame's ordered one-shot router
    and its deferred receipts instead of pretending the tips are repeatable draws.
    """
    if route not in ("startup", "property"):
        raise ValueError("unknown route: %s" % route)
    endings = Counter()
    assets = []
    reached30 = 0
    route_steps = Counter()
    property_entry_runs = 0
    property_reference = (
        property_ladder_reference_progression(diff) if route == "property" else None
    )

    startup_join = ROUTE_EVENTS["startup_opportunity"]
    startup_exit = ROUTE_EVENTS["startup_acquisition_offer"]

    for run_index in range(runs):
        seed_salt = 31 if route == "startup" else 47
        rng = random.Random(run_index * 982_451_653 + seed_salt)
        random.seed(run_index * 982_451_653 + seed_salt)
        state = Run(diff, defer_late_success=(route == "property"))
        state.income = SALARY
        founded = False
        acquisition_seen = False
        ipo_seen = False
        ipo_closed = False
        ipo_close_due = 0
        tip_seen = False
        tip_closed = False
        tip_close_due = 0
        villa_seen = False
        villa_result_seen = False
        villa_result_due = 0
        redev_seen = False
        redev_approved = False
        management_seen = False
        management_due = 0
        sale_due = 0
        sale_checked = False
        completion_seen = False
        property_goal_seen = False
        run_route_steps = set()

        def mark_route_step(step):
            assert step not in run_route_steps, (
                "property ladder step repeated in one run: %s" % step
            )
            run_route_steps.add(step)
            route_steps[step] += 1

        for week in range(1, 241):
            if state.over:
                break

            if route == "startup":
                eligible = []
                # A focused founder policy reaches the live skill/reputation gates
                # through weekly study/networking by the end of the first quarter.
                if not founded and week >= 36 and state.money >= float(startup_join["conditions"]["min_money"]):
                    eligible.append("startup_opportunity")
                elif founded and not acquisition_seen and week >= int(startup_exit["conditions"]["min_turn"]):
                    eligible.append("startup_acquisition_offer")
                drawn = _draw_route_event(rng, eligible)
                if drawn == "startup_opportunity":
                    choice = _apply_fixed_money_choice(state, drawn)
                    founded = True
                    route_steps["startup_founded"] += 1
                    for flag in choice.get("flags", []):
                        if flag == "startup_founded":
                            founded = True
                elif drawn == "startup_acquisition_offer":
                    _apply_fixed_money_choice(state, drawn)
                    acquisition_seen = True
                    route_steps["startup_exit"] += 1

            else:
                # Deferred receipts own their due week, matching the product's
                # priority above the property router. They close each door once.
                if ipo_close_due == week:
                    ipo_closed = True
                    mark_route_step("ipo_closed")
                elif tip_close_due == week:
                    tip_closed = True
                    mark_route_step("sangchul_tip_closed")
                elif villa_result_due == week:
                    villa_result_seen = True
                    mark_route_step("villa_result")
                elif management_due == week:
                    if redev_approved:
                        management_seen = True
                        mark_route_step("redev_management")
                    else:
                        mark_route_step("redev_failed_result")
                elif sale_due == week:
                    sale_checked = True
                    if management_seen and week >= 160:
                        _apply_fixed_money_choice(
                            state,
                            "inv_redev_completion_sale",
                            PROPERTY_LADDER_CHOICES["inv_redev_completion_sale"],
                        )
                        completion_seen = True
                        mark_route_step("redev_exit")
                else:
                    ipo_conditions = ROUTE_EVENTS["inv_ipo_hot_tip"]["conditions"]
                    tip_conditions = ROUTE_EVENTS["sangchul_tip_redev"]["conditions"]
                    villa_conditions = ROUTE_EVENTS["arc_opp_sangchul_realty"]["conditions"]
                    redev_conditions = ROUTE_EVENTS["inv_redev_zone_tip"]["conditions"]
                    portfolio_ready = week >= 23
                    sangchul_ready = week >= 28

                    if (
                        not ipo_seen
                        and int(ipo_conditions["min_turn"]) <= week <= int(ipo_conditions["max_turn"])
                        and portfolio_ready
                        and state.money >= float(ipo_conditions["min_money"])
                    ):
                        choice_index = PROPERTY_LADDER_CHOICES["inv_ipo_hot_tip"]
                        ipo_won = state.resolve_opportunity(
                            _event_choice("inv_ipo_hot_tip", choice_index)["opportunity"],
                            rng=rng,
                            sangchul_affinity=35,
                        )
                        ipo_seen = True
                        ipo_close_due = week + _deferred_delay(
                            "inv_ipo_hot_tip",
                            choice_index,
                            "callback_inv_ipo_hot_tip_win_listing"
                            if ipo_won else "callback_inv_ipo_hot_tip_lose_listing",
                        )
                        mark_route_step("ipo_attempt")
                        mark_route_step("ipo_won" if ipo_won else "ipo_lost")
                    elif (
                        not tip_seen
                        and ipo_closed
                        and int(tip_conditions["min_turn"]) <= week <= int(tip_conditions["max_turn"])
                        and sangchul_ready
                        and state.money >= float(tip_conditions["min_money"])
                    ):
                        choice_index = PROPERTY_LADDER_CHOICES["sangchul_tip_redev"]
                        tip_won = state.resolve_opportunity(
                            _event_choice("sangchul_tip_redev", choice_index)["opportunity"],
                            rng=rng,
                            sangchul_affinity=35,
                        )
                        tip_seen = True
                        tip_close_due = week + _deferred_delay(
                            "sangchul_tip_redev",
                            choice_index,
                            "callback_sangchul_tip_win_payoff"
                            if tip_won else "callback_sangchul_tip_lose_awkward",
                        )
                        mark_route_step("sangchul_tip_attempt")
                        mark_route_step("sangchul_tip_won" if tip_won else "sangchul_tip_lost")
                    elif (
                        not villa_seen
                        and tip_closed
                        and int(villa_conditions["min_turn"]) <= week <= int(villa_conditions["max_turn"])
                        and sangchul_ready
                        and state.money >= float(villa_conditions["min_money"])
                    ):
                        choice_index = PROPERTY_LADDER_CHOICES["arc_opp_sangchul_realty"]
                        villa_won = state.resolve_opportunity(
                            _event_choice("arc_opp_sangchul_realty", choice_index)["opportunity"],
                            rng=rng,
                            sangchul_affinity=35,
                        )
                        villa_seen = True
                        villa_result_due = week + _deferred_delay(
                            "arc_opp_sangchul_realty",
                            choice_index,
                            "arc_opp_sangchul_win" if villa_won else "arc_opp_sangchul_lose",
                        )
                        mark_route_step("villa_attempt")
                        mark_route_step("villa_won" if villa_won else "villa_lost")
                    elif (
                        not redev_seen
                        and villa_result_seen
                        and int(redev_conditions["min_turn"]) <= week <= int(redev_conditions["max_turn"])
                        and state.money >= float(redev_conditions["min_money"])
                    ):
                        choice_index = PROPERTY_LADDER_CHOICES["inv_redev_zone_tip"]
                        redev_approved = state.resolve_opportunity(
                            _event_choice("inv_redev_zone_tip", choice_index)["opportunity"],
                            rng=rng,
                            sangchul_affinity=35,
                        )
                        redev_seen = True
                        management_due = week + _deferred_delay(
                            "inv_redev_zone_tip",
                            choice_index,
                            "callback_redev_bet_taken_result"
                            if redev_approved else "callback_redev_bet_failed_result",
                        )
                        sale_due = week + _deferred_delay(
                            "inv_redev_zone_tip",
                            choice_index,
                            "inv_redev_completion_sale",
                        )
                        mark_route_step("redev_attempt")
                        mark_route_step("redev_approved" if redev_approved else "redev_failed")

            if route == "startup" and state.net_worth() >= 3_000_000_000.0:
                reached30 += 1
                endings["gangnam_dream(30억)"] += 1
                break
            if route == "property" and state.net_worth() >= 3_000_000_000.0:
                property_goal_seen = True

            if route == "property" and week == PROPERTY_ENTRY_WEEK:
                if state.net_worth() >= PROPERTY_ENTRY_MIN_ASSETS:
                    property_entry_runs += 1
                    mark_route_step("m49_property_entry")

            if week % 4 == 0:
                if state.mental <= 30 or state.stress >= 58:
                    state.mental += 10
                    state.health += 5
                    state.stress -= 20
                    state.clamp()
                state.tenure += 1
                if week == 4:
                    state.add_cash(300_000.0)
                state.monthly_pressure()
                if route == "property" and state.net_worth() >= 3_000_000_000.0:
                    property_goal_seen = True
                if not state.over:
                    state.advance()
            if week in (24, 48, 240):
                state.assert_whole_cash("route week %d" % week)
        if route == "property":
            assert not (completion_seen and not management_seen), (
                "property sale occurred without the +24 management receipt"
            )
            assert not (completion_seen and not sale_checked), (
                "property sale bypassed its +48 deferred due week"
            )
            if property_goal_seen:
                reached30 += 1
                endings["gangnam_dream(30억)"] += 1
            else:
                if not state.over:
                    state.age = 38
                    state.check_over()
                endings[state.over or "(미종료)"] += 1
        elif state.net_worth() < 3_000_000_000.0:
            if not state.over:
                state.age = 38
                state.check_over()
            endings[state.over or "(미종료)"] += 1
        assets.append(state.net_worth())

    assets.sort()
    med = assets[runs // 2]
    fail = sum(v for key, v in endings.items() if key in ("burnout", "mental_break", "bankruptcy", "debt_spiral"))
    print("\n[%s]  %d런 / 240주" % (name, runs))
    print(
        "  자산 중앙값 %s | 30억 도달 %d (%.1f%%) | 실패엔딩 %.1f%%"
        % (won(med), reached30, 100 * reached30 / runs, 100 * fail / runs)
    )
    print("  경로 노출: " + "  ".join("%s %.2f/런" % (k, v / runs) for k, v in route_steps.items()))
    if property_reference is not None:
        reference_rows = property_reference["ledger"]
        print(
            "  기준 사다리: "
            + " → ".join(
                "W%d %s %s" % (row["week"], row["event_id"], won(row["after"]))
                for row in reference_rows
            )
        )
        print(
            "  M49 진입 검증: 기준 W%d %s ≥ 문턱 %s (문턱 하향 0, 비저작 현금 주입 0)"
            % (
                property_reference["entry_week"],
                won(property_reference["entry_assets"]),
                won(property_reference["entry_min"]),
            )
        )
        print(
            "  지연 영수증: IPO W50(+1) · 상철 팁 W81(+8) · 빌라 W90(+8) "
            "· 관리 W136(+24) · 매각 W160(+48, 최소 W160)"
        )
        print(
            "  확률 런 M49 진입: %d/%d (%.1f%%)"
            % (property_entry_runs, runs, 100 * property_entry_runs / runs)
        )
    return {
        "win_rate": reached30 / runs,
        "fail_rate": fail / runs,
        "median": med,
        "steps": route_steps,
        "property_entry_rate": property_entry_runs / runs,
        "property_reference": property_reference,
    }


def won(v):
    if abs(v) >= 100_000_000:
        return f"{v/100_000_000:.1f}억"
    if abs(v) >= 10_000:
        return f"{v/10_000:.0f}만"
    return f"{v:.0f}"


if __name__ == "__main__":
    print("=== 밸런스 QA 시뮬 (GameState 경제 척추 Python 포트, 정책별 3000런) ===")
    run_policy("①무직 방치", 0)
    run_policy("②성실 직장(무베팅)", 1)
    run_policy("③직장+가끔 베팅(25%)", 2)
    run_policy("④직장+공격 베팅(60%+메가)", 3)
    print("\n--- 2026-06-11 신규 요소 영향 측정 ---")
    run_policy("③' 가끔 베팅 + 인연 패시브 풀가동", 2, cast_passives=True)
    run_policy("④' 공격 베팅 + 인연 패시브 풀가동", 3, cast_passives=True)
    run_policy("④'' 공격 베팅 + 패시브 + 상철 팁", 3, cast_passives=True, sangchul_tips=True)
    print("\n--- 대출 레버리지 (2026-06-11 신규 시스템) ---")
    run_policy("③ᴸ 가끔 베팅 + 대출 풀레버리지", 2, use_loans=True)
    print("\n--- 240주 경로 검증 (창업 가중치 · 부동산 결정적 사다리) ---")
    run_route_policy("⑤ 창업 공동창업→엑싯", "startup")
    run_route_policy("⑥ 임상철 급매→재개발 사다리", "property")
    run_policy("④ᴸ 공격 베팅 + 대출 풀레버리지", 3, use_loans=True)
    print("\n--- 난이도 모드 비교 (2026-06-11 신규) ---")
    for d in ("드라마", "현실", "지옥고"):
        run_policy(f"② 성실 직장 [{d}]", 1, diff=d)
    for d in ("드라마", "현실", "지옥고"):
        run_policy(f"③ 가끔 베팅 [{d}]", 2, diff=d)
