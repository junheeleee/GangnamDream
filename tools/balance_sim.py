#!/usr/bin/env python3
"""밸런스 QA — GameState 경제 척추의 Python 포트 시뮬레이터.

SimRun.gd(헤드리스 60턴 시뮬)와 동일한 정책 봇 구조를 따르되,
2026-06-11 추가된 인연 월간 패시브·상철 정보 이벤트의 영향을
켜고/끄고 비교 측정한다. Godot 없이 돌릴 수 있는 게 목적.

미모델(SimRun과 동일한 한계): 랜덤 이벤트 스탯 노이즈, 정밀 AP,
포트폴리오 시장 가격 변동. 급여 고정, 휴식은 대표값.
"""
import random
from collections import Counter

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


class Run:
    def __init__(self):
        self.money = 500_000.0
        self.loans = {"bank": 0.0, "second": 0.0}
        self.tenure = 0
        self.income = 0.0
        self.health = 65
        self.mental = 60
        self.stress = 35
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
        rate = opp["success_rate"] + self.luck * LUCK_FACTOR
        rate = max(0.02, min(0.98, rate))
        self.money -= stake
        if random.random() < rate:
            self.money += stake + stake * opp["win_multiplier"]
            self.stress -= 3
        else:
            self.money += stake * (1.0 - opp["loss_ratio"])
            self.stress += 12
            self.mental -= 6
        self.clamp()

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
        self.health -= 2
        self.mental -= 3
        self.stress += 3
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


def run_policy(name, mode, runs=3000, cast_passives=False, sangchul_tips=False, use_loans=False):
    endings = Counter()
    assets = []
    reached30 = 0
    for r in range(runs):
        random.seed(r * 7919 + mode * 131 + (1000 if cast_passives else 0))
        s = Run()
        employed = False
        tip_cd = 0
        while not s.over and s.turn <= 64:
            t = s.turn
            if tip_cd > 0:
                tip_cd -= 1
            # 생존 유지: 위험하면 휴식 (SimRun 대표값)
            if s.mental <= 30 or s.stress >= 58:
                s.mental += 10
                s.health += 5
                s.stress -= 20
                s.clamp()
            else:
                if mode >= 1 and not employed and t >= 2:
                    s.income = SALARY
                    employed = True
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


def won(v):
    if abs(v) >= 100_000_000:
        return f"{v/100_000_000:.1f}억"
    if abs(v) >= 10_000:
        return f"{v/10_000:.0f}만"
    return f"{v:.0f}"


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
run_policy("④ᴸ 공격 베팅 + 대출 풀레버리지", 3, use_loans=True)
