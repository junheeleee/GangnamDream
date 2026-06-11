# Gangnam Dream Balance

Track economy, stress, relationship, event, and progression tuning here.

## 2026-06-11 — 난이도 모드 3종 도입

본편 밸런스(현실)는 불변. 모드는 시작값·월간 압박 계수·베팅 성공률 보정만 다르다.

| 모드 | 시작 자금 | 시작 스트레스 | 월간 건강/정신/스트레스 | 베팅 성공률 |
|---|---|---|---|---|
| 🎬 드라마 | 200만 | 30 | -1 / -2 / +2 | +4%p |
| 🌆 현실 (기본) | 50만 | 35 | -2 / -3 / +3 | ±0 |
| 🔥 지옥고 | 30만 | 45 | -3 / -4 / +5 | -4%p |

- 시뮬 (③ 가끔 베팅 정책, 3,000런): 30억 도달 **드라마 27.0% / 현실 15.3% / 지옥고 7.6%**
  — 모드 간 약 2배 간격. 성실 직장 정책은 세 모드 모두 생존 가능 (지옥고도 취업하면 산다).
- 시뮬 봇 수정: 취업을 휴식보다 우선하도록 변경 (기존 봇은 지옥고 시작 스트레스 45에서
  영원히 취업 못 하는 인공 데드락 — 실제 플레이어 행동과 불일치했음).

## 2026-06-11 — 파산 임계값 정렬 + 대출 시스템 도입

### 파산 임계값 (코드 → 설계값 정렬)
- bankruptcy: 현금 -3천만 → **순자산 -1억** / debt_spiral: -1억 → **순자산 -2억**
- 엔딩 텍스트·튜토리얼·UI 경고·endings.json condition은 전부 이미 -1억/-2억 기준이었음.
  check_game_over의 코드 상수만 어긋나 있던 것 → 정렬.
- 판정 기준을 현금 → **순자산(현금+포트폴리오-대출원금)** 으로 변경.
- 현금 위기 분기 순서 수정: money<0 우선 검사 (기존엔 도달 불가 코드였음).
- 시뮬 검증: 무직 방치 런이 파산(-1억 도달 전) 대신 **mental_break**로 종료 —
  빚 스트레스(+12/월)가 먼저 사람을 무너뜨림. 서사 의도와 일치.

### 대출 시스템 — 신용등급 기반 (신규)
**신용점수(1~100)**: 기저 30 + 고용 15 + 근속(최대 12) + 소득(최대 14) + 순자산(1천만당 1, 최대 20)
+ 평판(최대 5) − 부채비율(최대 25) − 잔고 바닥 이력(8). **등급 1~10** = (점수-5)/10 역산.

| 상품 | 월 이자 (등급별) | 한도 (등급별) | 조건 |
|---|---|---|---|
| 1금융 신용대출 | 0.4%(1등급)~0.88%(7등급) | 월소득×(20-2×등급): 18배~6배 | 직장 + 7등급 이내 |
| 제2금융 대출 | 1.28%(1등급)~2.0%(10등급) | 1,000만+등급당 400만: 4,600만~1,000만 | 없음 |

- **변동금리**: 이자는 매달 현재 등급으로 계산 — 실직·자산 손실·과다 부채로
  등급이 떨어지면 이미 보유한 빚의 이자도 같이 오른다 (빚의 악순환 메커니즘).
- 대표 곡선: 백수 8등급(1금융 거절, 2금융 1,800만/1.84%) → 신입 6등급(1,792만/0.80%)
  → 대기업+1억 3등급(6,370만/0.56%) → 외국계+3억 2등급(1.25억/0.48%)
  → 실직+빚 10등급(1금융 거절, 2금융 1,000만/2.0%)
- 이자 납부 시 스트레스 +2. 상환은 수시(현금 한도 내).
- 순자산이 빚을 차감하므로 대출로 마일스톤·승리 조건을 부풀릴 수 없음.
- 시뮬: 신용 기반 풀레버리지 30억 도달 +4.0pp(신중)~+7.3pp(공격), 실패엔딩 증가 없음.
  저연봉 한도는 전액 날려도 파산선(-1억) 위, 고연봉·고신용 한도(1.2억+)는 파산 가능
  — 판이 클수록 추락도 깊다.

## 2026-06-11 — QA 밸런스 감사 (tools/balance_sim.py, 정책별 3,000런)

Godot 없이 돌릴 수 있는 경제 척추 Python 포트(`tools/balance_sim.py`)로 측정.
SimRun.gd와 동일 한계: 이벤트 노이즈·시장 가격 미모델, 베팅 기회를 매턴 가정(상대 비교용).

### 시뮬 결과 (30억 도달률 / 실패엔딩률)
| 정책 | 자산 중앙값 | 30억 도달 | 실패엔딩 |
|---|---|---|---|
| ①무직 방치 | -3,045만 | 0% | 100% (파산, ~47턴) |
| ②성실 직장 무베팅 | 9,615만 | 0% | 0% |
| ③직장+가끔 베팅(25%) | 2.6억 | 15.3% | 0% |
| ④직장+공격 베팅(60%) | 35.0억 | 59.6% | 0% |
| ③'+인연 패시브 풀가동 | 3.4억 | 19.6% (+4.3pp) | 0% |
| ④'+인연 패시브 풀가동 | 39.9억 | 67.8% (+8.2pp) | 0% |
| ④''+상철 팁 추가 | 40.1억 | 71.0% (+3.2pp) | 0% |

- "정석만으론 강남 불가" 테마 수치로 확인 (무베팅 60턴 = 9,600만).
- 인연 패시브는 "회복 세금 절감"으로 작동: 월간 압박 상쇄에 ~1.5AP/월 필요한 것이
  풀가동 시 ~1AP로 — 남는 AP가 베팅/성장으로 환류. 공격 플레이일수록 이득 큼(복리).

### 발견된 문제
1. **[버그] 현금 위기 분기 도달 불가** — `apply_monthly_pressure()`의
   `if money < 300_000 → elif money < 0` 순서상 마이너스 잔고 패널티(스트레스+12/정신-5)가
   영원히 실행 안 됨 (money<0이면 항상 첫 분기에 걸림). 순서 교체 필요.
2. **[홀:높음] 아이템 무제한 사용** — 구매·사용에 AP/월제한/쿨다운 전무.
   심리상담 3회권 18만원 = 정신+10/스트레스-12 → 월 36만원이면 월간 자연 압박 전부 상쇄,
   스트레스 시스템(게임 핵심 텐션)이 돈으로 무력화됨. 사용 시 AP 1 소모 권장.
3. **[문서 불일치]** CLAUDE.md 파산 기준 "현금 -1억(나락 -2억)" vs 코드 bankruptcy -3천만 / debt_spiral -1억.

### opportunity EV 위계 (운 45 보정, stake당 기대수익)
- inv_redev_zone_tip +2.90 (1회 한정, 28턴+/1억+ — 의도된 클라이맥스 메가베팅)
- arc_opp_jiyeon_bunyang +1.38 / inv_ipo_hot_tip +1.15 (cd18) / arc_opp_sangchul +1.08
- **sangchul_tip_redev +1.08, 승률 69%** (신규, cd12) — 기존 팁과 같은 급, 분산은 더 낮음.
  신뢰 보상으로 적정. 더 보수적으로 가려면 cd 15.
- EV 음수 베팅 없음 — "베팅은 천장, 정석은 바닥" 구조 일관.

### 지배 선택지 148쌍 (한 선택지가 전 스탯 우월)
대부분 의도된 서사 함정(스캠·물타기·친구 대출 — result_text가 대가를 서술)이라 정상.
함정 의도가 아닌데 지배되는 사례만 조정 후보: drama_eviction_notice(법적 대항이 손해),
drama_mentor_encounter(신중한 관망이 전면 열위).

### 회복 경제 실측
- 휴식 1AP 평균: 정신 +5.2 / 스트레스 -4.3 / 건강 +1.0 (REST_VIGNETTES 10종 평균)
- 월간 압박 (직장인·고시원·스트레스 40~60대): 정신 -5~-6 / 스트레스 +5 / 건강 -2
- → 유지비 ≈ 1.5AP/월. 3AP 중 절반이 생존세 = 의도된 텐션. 단 2번 홀이 이를 우회함.

## Core Variables To Track
- Starting money.
- Monthly income.
- Fixed expense.
- Health decay and recovery.
- Mental decay and recovery.
- Stress gain and relief.
- Investment volatility by asset class.
- Crash probability.
- Bubble duration.
- Relationship decay.
- Event rarity weights.
- Job income and performance requirements.
- Item prices and effects.
- Ending thresholds.

## Current Balance Goals
- The player should feel financial pressure early.
- Risky choices should be tempting but not always correct.
- Luck should matter, but strategy should matter more over many runs.
- Relationships should create both support and complications.
- Multiple viable paths should exist: career, investment, business, relationships, rare events.

## Change Log Template

```text
Date:
Commit:
Changed:
Reason:
Observed Result:
Next Adjustment:
```

---

## Change Log

### 2026-06-10 — 5차 난이도 조정 (목표 달성률 1~3% → 5~8%)

```text
Date: 2026-06-10
Changed:
  1. InvestmentSystem drift  0.35%/월 → 0.60%/월 (연 7.2% 기대수익)
  2. 크래시 피해 축소: range -0.18~-0.45 → -0.12~-0.38, 배수 1.2→1.0
  3. crash_risk 상한 clamp 0.98 추가 (과거: 사실상 무제한)
  4. arc_opp_sangchul_realty 기회 이벤트:
       올인 선택: success_rate 0.32→0.42, win_multiplier 1.6→2.8
       보수적 선택: success_rate 0.32→0.44, win_multiplier 1.6→2.0
  5. arc_opp_jiyeon_bunyang 기회 이벤트:
       올인 선택: success_rate 0.28→0.38, win_multiplier 2.4→4.0, loss_ratio 0.80→0.75
  6. 신규 투자 이벤트 2종 추가:
       inv_ipo_hot_tip (공모주, 12턴+, uncommon): 올인 sr 0.36/wm 3.5, 보수 sr 0.40/wm 2.5
       inv_redev_zone_tip (재개발, 28턴+, rare, 1회성): 대박 sr 0.40/wm 7.0, 보수 sr 0.46/wm 5.0
  7. SimRun OPP 재설정: 음수 EV OPP 2개 제거, 실제 이벤트 파라미터로 교체
       OPP[1] (구 sr 0.35/wm 1.8, EV -9.1%) → sr 0.44/wm 2.0
       OPP[3] (구 sr 0.35/wm 2.0, EV -7.0%) → sr 0.36/wm 3.5
Reason: SimRun 60턴 12,000런 결과 정책별 달성률 1.3~3.6%. 목표(5~8%) 미달.
         drift 부족, 크래시 과도, arc OPP 음수 EV, SimRun OPP 파라미터 불일치가 복합 원인.
Observed Result: 시뮬 재실행 결과 정책별 1.3~3.6% → 추정 5~8% (실제값은 로컬 Godot 재실행 필요)
Next Adjustment: 정식 play-test 후 파산율·달성률 교차 확인. 재개발 이벤트(7× 배수) 실 플레이 체감 필요.
Files: systems/InvestmentSystem.gd, content/events/arc_events.json,
       content/events/investment_events.json, tools/SimRun.gd
```

### 2026-06-06 — Opportunity EV 밸런스 패치

```text
Date: 2026-06-06
Changed: 모든 opportunity 이벤트 success_rate 하향 + loss_ratio 상향
Before: 평균 EV +63%/회 (arc_opp_jiyeon_bunyang +130%가 최고)
After:  -6% ~ +10% 범위, 평균 ~0%
Reason: "공격 올인" 시뮬 결과 30억 도달 57% — 수학적 지배 전략이 되어 선택의 의미 소멸.
         BALANCE.md 원칙 "Risky choices should be tempting but not always correct" 위반.
Files:  tools/SimRun.gd (OPPS), arc_events.json, amb_scenarios2.json, scenario_cafe_callback.json
Observed Result: 시뮬 재실행 필요 (공격 올인 목표: 강남 20~30%, 파산 20~30%)
Next Adjustment: 시뮬 재확인 후 공격 경로 파산율이 낮으면 loss_ratio 추가 상향 고려.
```

### 2026-05-28 — RPG/Roguelike Pass

```text
Date: 2026-05-28
Changed: 크래시 확률
Before: crash_risk * volatility * 0.5 (기본 crash_risk 0.02-0.03)
After:  crash_risk * volatility * 1.2 (기본 crash_risk 0.02-0.05)
Reason: 테스터 피드백 "너무 무난함". 시장 긴장감 강화.
Next Adjustment: 플레이 테스트 후 지나치게 빠른 파산 유발 시 0.8로 하향.
```

```text
Date: 2026-05-28
Changed: 월별 크라이시스 시스템 (신규)
Bonus rate: 6% (AP+1, 추가수입 20만-60만, 강세장 전환)
Crisis rate: 18% (긴급지출 15만-70만, AP-1, 시장충격, 건강위기 -5)
Total event rate: 24% per month (3턴 이후)
Reason: 확정 이벤트만으로는 월별 루프가 예측 가능. 랜덤 변수 도입.
Next Adjustment: 크라이시스 강도가 너무 강하면 긴급지출 상한 50만으로 조정.
```

```text
Date: 2026-05-28
Changed: 레버리지 투자 (신규)
Leverage: 2× (동일 금액으로 2배 수량 매수)
Fee: 1.5% (일반 0.3%보다 5배)
Margin call: 포지션 가치 < 원금노출 × 35% → 강제청산 85%
Margin call penalty: 스트레스+20, 정신력-10
Reason: 고위험 고수익 전략 추가로 플레이 스타일 다양화.
Next Adjustment: 마진콜 기준 25%로 낮추면 더 위험, 45%로 높이면 더 안전.
```

```text
Date: 2026-05-28
Changed: 스탯 임계값 RPG 보상 (신규)
Thresholds: 30 / 50 / 70 (투자스킬, 지력, 사회성)
Unlocks at 30: 심화 독서(지력), 레버리지 투자(투자스킬)
Unlocks at 50: 시장 분석 무료(지력), VIP 인맥(사회성)
Reason: 스탯이 단순 숫자가 아닌 행동 선택지를 여는 RPG 성장감 부여.
Next Adjustment: 70 임계값 보상 추가 필요 (현재 해금 없음).
```

```text
Date: 2026-05-28
Changed: 이벤트 최근 기억 창
Before: 14개
After: 25개
Reason: 14개로는 이벤트 pool 대비 반복이 빠름. 체감 다양성 개선.
```

### 2026-05-16 — Prototype Improvement Pass

```text
Date: 2026-05-16
Commit: prototype-improvement-pass
Changed: 엔딩 분기 로직
Reason: 65세 도달 시 자산 규모를 무시하고 단일 엔딩("ordinary_retirement")만 트리거되는 문제.
Observed Result: 자산 5억 이상/미만에 따라 B/C 등급 엔딩 분기 없음.
Next Adjustment: 자산 구간을 더 세분화할 수 있음 (예: 1억 이상 C+, 3억 이상 B- 등).
```

```text
Date: 2026-05-16
Commit: prototype-improvement-pass
Changed: 스탯 색상 경고 임계값 — 건강/정신력
Reason: 코드 버그로 인해 health/mental이 50 이하가 되면 즉시 빨간색이 되어 정보값이 없었음.
Observed Result: 50↓ 노란색(주의), 30↓ 빨간색(위험)으로 정상화.
Next Adjustment: 게임 오버 직전(10 이하) 별도 깜빡임 효과 고려.
```

```text
Date: 2026-05-16
Commit: prototype-improvement-pass
Changed: 투자 매수 금액 고정 10만원 → 3단계 선택
Reason: 단일 금액 매수는 포트폴리오 구성 전략성이 낮고 사용성 불편.
Observed Result: 10만/50만/100만원 선택 가능. 잔액 부족 시 버튼 비활성화.
Next Adjustment: 직접 입력 금액 옵션 고려 (Alpha 단계).
```

```text
Date: 2026-05-16
Commit: prototype-improvement-pass
Changed: 매도 전량 고정 → 분할 매도(25%/50%/전량)
Reason: 전량 매도만 가능하면 리스크 관리 전략이 사실상 불가능.
Observed Result: 분할 매도 가능, 보유 평가액·평단·수익률 표시.
Next Adjustment: 지정가/시장가 개념 추가 고려 (Content Alpha 단계).
```

### 2026-05-27 — Balance Pass (초반 생존성 개선)

```text
Date: 2026-05-27
Commit: balance-pass
Changed: 고시원 월 생활비 800,000원 → 650,000원
Reason: 시작 자금 1,000,000원 기준, 무직 1개월 후 잔액이 200,000원만 남아
         Turn 2에 즉시 현금위기(-30만)가 발생. CLAUDE.md 설계 기준(650K)과의 불일치 수정.
Observed Result: 1개월 버퍼 확보. 신규 플레이어가 직업 탐색에 여유 1턴 추가.
Next Adjustment: 원룸 이사 요건(req_cash 7M) 유지 — 고시원 절약 효과로 더 빠른 상위 주거 진입 가능해짐.
```

```text
Date: 2026-05-27
Commit: balance-pass
Changed: JobSystem.process_monthly_job() 무직 스트레스 +2 제거
Reason: apply_monthly_pressure()에서 이미 무직 패널티 +6/월(기본+3, 무직+3)을 적용하는데,
         process_monthly_job()에서 추가로 +2를 더해 총 +8이 되는 이중계산 구조.
         T1 콜센터(직업 보유, +8)와 무직(+8)이 스트레스 동일한 이상한 결과 발생.
Observed Result: 무직 스트레스 +6/월로 정상화. T1 편의점(+5) < 무직(+6) < T1 배달(+6) < 중소기업(+7)
Next Adjustment: 배달 라이더 = 무직 스트레스 동일 문제 남아있음 — 수입 차이가 유일한 인센티브로 설계상 허용.
```

```text
Date: 2026-05-27
Commit: balance-pass
Changed: T3 직업 스트레스 곡선 조정
  - 공공기관 계약직: stress_per_month 2 → 3
  - 부동산 중개보조:  stress_per_month 3 → 4
Reason: T3(공공기관 +2, 부동산 +3)이 T1(편의점 +2, 배달 +3)과 동일한 스트레스를 가지면서
         월급은 3~4백만원 더 높아 명백히 우월 선택이 됨.
         T3 곡선을 3/4/5/6으로 조정해 스트레스 ≥ T2(6/7/8/9) 미만 유지하면서 T1과 구분.
Observed Result: T1~T4 스트레스 곡선: 2/3/4/5 → 6/7/8/9 → 3/4/5/6 → 7/8/10 (T3 이상)
Next Adjustment: T4 외국계 세일즈(+10/월) — T4 최고 직업 치고 극단적 수치. 관찰 후 조정 여부 결정.
```

