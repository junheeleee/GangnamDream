# Gangnam Dream Balance

Track economy, stress, relationship, event, and progression tuning here.

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

