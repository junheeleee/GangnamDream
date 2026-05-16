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

