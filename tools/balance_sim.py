#!/usr/bin/env python3
"""밸런스 QA — GameState 경제 척추의 Python 포트 시뮬레이터.

SimRun.gd(헤드리스 60턴 시뮬)와 동일한 정책 봇 구조를 따르되,
2026-06-11 추가된 인연 월간 패시브·상철 정보 이벤트의 영향을
켜고/끄고 비교 측정한다. Godot 없이 돌릴 수 있는 게 목적.

미모델(SimRun과 동일한 한계): 랜덤 이벤트 스탯 노이즈, 정밀 AP,
포트폴리오 시장 가격 변동. 급여 고정, 휴식은 대표값.
"""
import json
import random
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


def _load_route_events():
    wanted = {
        "startup_opportunity",
        "startup_acquisition_offer",
        "sangchul_tip_redev",
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
    def __init__(self, diff="현실"):
        self.diff = DIFFICULTY[diff]
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

    def resolve_opportunity(self, opp):
        stake = max(0.0, self.money) * opp["stake_ratio"]
        rate = opp["success_rate"] + self.luck * LUCK_FACTOR + self.diff["opp"]
        rate = max(0.02, min(0.98, rate))
        self.money -= stake
        if random.random() < rate:
            self.money += stake + stake * opp["win_multiplier"]
            self.stress -= 3
            won = True
        else:
            self.money += stake * (1.0 - opp["loss_ratio"])
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
            return 0.004 + (g - 1) * 0.0008
        return 0.012 + g * 0.0008

    def monthly_pressure(self, cast_passives=False, lover=False, father=False, sangchul=False):
        expense = 650_000.0  # 고시원 고정 (SimRun 동일)
        self.money += self.income - expense
        # 대출 이자 (2026-06-11 신규, 변동금리 — 신용등급 기준)
        interest = sum(self.loans[p] * self.loan_rate(p, self.tenure) for p in self.loans)
        if interest > 0:
            self.money -= interest
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
        # 현금 위기 (2026-06-11 수정: 마이너스 우선 검사)
        if self.money < 0:
            self.stress += 12
            self.mental -= 5
        elif self.money < 300_000:
            self.stress += 8
            self.mental -= 4
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
        if net >= 3_000_000_000:
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
                            amt = limit - s.loans[prod]
                            s.loans[prod] += amt
                            s.money += amt
                    # 자산이 빚의 5배를 넘으면 전액 상환 (이자 절감)
                    if s.loan_total() > 0 and s.money > s.loan_total() * 5:
                        s.money -= s.loan_total()
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
                s.money += 300_000
            s.monthly_pressure(cast_passives=cast_passives, lover=cast_passives,
                               father=cast_passives, sangchul=cast_passives)
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
    state.money += float(choice.get("effects", {}).get("money", 0.0))
    return choice


def run_route_policy(name, route, runs=3000, diff="현실"):
    """Run a route-focused 240-week policy against live event parameters.

    Like the baseline simulator, generic event stat noise and portfolio ticks are
    intentionally omitted. Unlike the old 64-month policy loop, route exposure
    uses the real weekly cadence, one weighted situation draw per week, the live
    rarity/weight values, and monthly salary/rent every four weeks.
    """
    if route not in ("startup", "property"):
        raise ValueError("unknown route: %s" % route)
    endings = Counter()
    assets = []
    reached30 = 0
    route_steps = Counter()

    startup_join = ROUTE_EVENTS["startup_opportunity"]
    startup_exit = ROUTE_EVENTS["startup_acquisition_offer"]
    redev = ROUTE_EVENTS["inv_redev_zone_tip"]
    redev_min = float(redev.get("conditions", {}).get("min_money", 0.0))
    redev_min_week = int(redev.get("conditions", {}).get("min_turn", 0))
    completion_min_week = int(
        ROUTE_EVENTS["inv_redev_completion_sale"].get("conditions", {}).get("min_turn", 0)
    )

    for run_index in range(runs):
        seed_salt = 31 if route == "startup" else 47
        rng = random.Random(run_index * 982_451_653 + seed_salt)
        random.seed(run_index * 982_451_653 + seed_salt)
        state = Run(diff)
        state.income = SALARY
        founded = False
        acquisition_seen = False
        redev_seen = False
        redev_approved = False
        completion_seen = False
        tip_lock_until = 0

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
                eligible = []
                trusted = week >= 40
                if redev_approved and not completion_seen and week >= completion_min_week:
                    eligible.append("inv_redev_completion_sale")
                if not redev_seen and week >= redev_min_week and state.money >= redev_min:
                    eligible.append("inv_redev_zone_tip")
                if trusted and state.money >= 10_000_000.0 and week >= tip_lock_until:
                    eligible.append("sangchul_tip_redev")
                drawn = _draw_route_event(rng, eligible, focused=True, trusted_sangchul=trusted)
                if drawn == "sangchul_tip_redev":
                    opp = dict(_event_choice(drawn)["opportunity"])
                    opp["success_rate"] = float(opp["success_rate"]) + 0.15
                    state.resolve_opportunity(opp)
                    tip_lock_until = week + 25  # recent-event window dominates cooldown 12
                    route_steps["property_tip"] += 1
                elif drawn == "inv_redev_zone_tip":
                    opp = dict(_event_choice(drawn)["opportunity"])
                    opp["success_rate"] = float(opp["success_rate"]) + 0.15
                    redev_approved = state.resolve_opportunity(opp)
                    redev_seen = True
                    route_steps["redev_attempt"] += 1
                    if redev_approved:
                        route_steps["redev_approved"] += 1
                elif drawn == "inv_redev_completion_sale":
                    _apply_fixed_money_choice(state, drawn)
                    completion_seen = True
                    route_steps["redev_exit"] += 1

            if state.net_worth() >= 3_000_000_000.0:
                reached30 += 1
                endings["gangnam_dream(30억)"] += 1
                break

            if week % 4 == 0:
                if state.mental <= 30 or state.stress >= 58:
                    state.mental += 10
                    state.health += 5
                    state.stress -= 20
                    state.clamp()
                state.tenure += 1
                if week == 4:
                    state.money += 300_000.0
                state.monthly_pressure()
                if not state.over:
                    state.advance()
        if state.net_worth() < 3_000_000_000.0:
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
    return {"win_rate": reached30 / runs, "fail_rate": fail / runs, "median": med, "steps": route_steps}


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
    print("\n--- 240주 경로 다양화 (실제 이벤트 가중치, 2026-07-13) ---")
    run_route_policy("⑤ 창업 공동창업→엑싯", "startup")
    run_route_policy("⑥ 임상철 급매→재개발 사다리", "property")
    run_policy("④ᴸ 공격 베팅 + 대출 풀레버리지", 3, use_loans=True)
    print("\n--- 난이도 모드 비교 (2026-06-11 신규) ---")
    for d in ("드라마", "현실", "지옥고"):
        run_policy(f"② 성실 직장 [{d}]", 1, diff=d)
    for d in ("드라마", "현실", "지옥고"):
        run_policy(f"③ 가끔 베팅 [{d}]", 2, diff=d)
