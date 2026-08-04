# Active Queue Spec: ORDER-84

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-84 [P0·수치 정합] 모든 현금을 1원 단위로 정산하고 0원 기회를 막는다

**재착수 (2026-08-04 Codex):** `P-9 → P-10` 완료와 원격 CI 통과를 확인했다.
아래 선언 범위를 바꾸지 않고 현금 변이·19개 기회 선택·구 저장부터 전수한다.

**착수 선언 (2026-08-04 Codex) — 만지는 파일:**
`autoloads/GameState.gd`, `autoloads/EventManager.gd`, `autoloads/DataRegistry.gd`,
`systems/InvestmentSystem.gd`, `scenes/MainGame.gd`, `scenes/StoryMode.gd`,
`content/events/amb_scenarios2.json`, `content/events/arc_events.json`,
`content/events/callback_events_3.json`, `content/events/callback_events_4.json`,
`content/events/callback_events_5.json`, `content/events/investment_events.json`,
`content/events/scenario_cafe_callback.json`과 대응하는 `content/events_en/` 오버레이,
`tools/SimRun.gd`, `tools/balance_sim.py`, `tools/convergence_sim.py`,
`tools/CoreLoopV2HandoffCheck.gd`, `tools/ScreenshotQA.gd`, `tools/audit.py`,
`tools/audit.sh`, `tools/audit_scope.json`, `tools/mod_pack_validator.py`,
신규 `tools/MoneyIntegrityCheck.gd/.tscn`, 신규 기회 현금 감사,
`docs/BALANCE.md`, `docs/QA_CHECKLIST.md`, `docs/CORE_LOOP_V2.md`,
`docs/CONVERGENCE_REPORT.md`, `docs/MODDING.md`, `docs/WORK_LOG.md`,
`docs/STATUS.md`, `docs/RELEASE_NOTES.md`, `docs/DEMO_FIXLOG.md`, `CLAUDE.md`,
`docs/CODEX_QUEUE.md`, 이 사양의 활성·아카이브 경로, 그리고 감사가 요구하는
`content/meta/release_content_inventory.json`, `docs/CONTENT_RATING_INVENTORY.md`.
현금 외 수량·수익률·확률과 엔딩·출시 진입은 소유하지 않는다.

**사용자 승인 (2026-08-04):** `docs/DECISIONS.md`의 P-6을 권고대로 실행한다.
현금의 정본 단위는 1원이며, 비율 거래를 포함한 한 거래가 끝날 때 한 번만
명시적으로 정수 원으로 정산한다. 가진 돈이 없어 실질 베팅금이 0원인 선택은
투자·성공/실패·결과 플래그·투자감각을 만들 수 없다.

**발견 근거:** 현재 `cafe_cb_honest_00 → cafe_cb_honest_in` 실패 정산은
`2,496,537.5원`, `3,170,787.5원`을 저장하고 48주에는 `12,006,537.5원`,
`5,840,787.5원`으로 이어진다. 반대로 음수 잔액에서 `stake_ratio` 선택을 고르면
실질 0원인데도 성공/실패와 플래그가 생긴다. 화면의 정수 원과 저장 원장이 서로
다른 문제와 공짜 결과를 같은 화폐 불변식으로 닫는다.

## 깊이 3문

1. 지우면 비율 거래를 반복할수록 화면에는 없는 반 원이 저장과 후속 수치에
   누적되고, 돈이 없어도 위험 경로의 결과·기술·플래그를 얻을 수 있다.
2. 특정 카페 한 건을 잘라 숨기지 않고 현금 유입·유출 경계와 19개 기회 선택,
   구 저장을 함께 다뤄야 24주·1년·5년 원장이 같은 단위를 말한다.
3. 수익률·확률·보유 수량은 소수 계산을 유지하되 현금으로 체결되는 거래만 끝에서
   한 번 정산하면 경제 확률이나 원래 선택 비용을 임의로 다시 설계하지 않는다.

## 배치 A — 원 단위 정책·런타임·구 저장

- `autoloads/GameState.gd`에 현금 정산의 단일 경계를 두고, `add_money`, 월급·고정비·
  대출 이자·주거·투자·기회 정산 및 직접 현금 변이를 전수해 중간 단계가 아니라
  거래 완료 시 한 번만 같은 반올림 규칙을 적용한다. 반올림은 최근접 1원이며
  정확히 `.5원`은 0에서 먼 쪽으로 보낸다. 저장 형식은 호환성을 위해 유지하되
  소수 현금 구 저장은 리퍼폰 환불을 포함한 모든 이관이 끝난 뒤 같은 함수로 한 번
  정규화한다. 스키마 번호는 올리지 않고 재로드 결과는 멱등이어야 한다.
- `systems/InvestmentSystem.gd`와 현금 체결 호출자는 수익률·자산 수량 계산을
  섣불리 정수화하지 않고 최종 현금 유입/유출만 공통 경계를 통과한다.
- `GameState._resolve_opportunity()`는 `round(cash * stake_ratio)`가 1원 이상일 때만
  유효하다. 성공은 `+round(stake * multiplier)`, 실패는
  `-round(stake * loss_ratio)`를 한 번만 반영한다. 1원 미만이면 RNG, 현금,
  정신력, 투자감각, `_last_opportunity_result`, win/lose 플래그를 전혀 바꾸지 않는다.
- 공용 `choice_available` 판정을 `EventManager`, `MainGame`, `StoryMode`의 노출 경계와
  `GameState.apply_choice()` 직전에 함께 사용한다. 무효 선택은 top-level effects와
  flags를 쓰기 전 거부해 돈·스탯·`events_seen`·로그·쿨다운·후속 사건·투자 플래그가
  모두 불변이어야 한다. UI만 숨기거나 결과 계산에서만 늦게 막아서는 안 된다.
- 19개 기회 선택을 소유한 다음 일곱 파일을 전수한다:
  `content/events/amb_scenarios2.json`, `content/events/arc_events.json`,
  `content/events/callback_events_3.json`, `content/events/callback_events_4.json`,
  `content/events/callback_events_5.json`, `content/events/investment_events.json`,
  `content/events/scenario_cafe_callback.json`.
- 15개 사건 중 13개는 기존 비투자 대안을 사용한다. 기회 선택 하나뿐인
  `cafe_cb_stole_allin`, `cafe_cb_stole_smart`에는 현금 부족 전용 무상태 대체 선택을
  `opportunity_unavailable_fallback` 키로 KO/EN에 추가해 구 중간 저장도 막히지 않게
  한다. 이 전용 조건 키는 `autoloads/DataRegistry.gd`,
  `tools/mod_pack_validator.py`, 감사의 `CHOICE_KEYS`에 명시적으로 등록한다.

## 배치 B — 240주 원장·저장·선택 회귀와 정본

- 새 `tools/MoneyIntegrityCheck.gd/.tscn`은 양수/0/음수 현금, 양·음 `.5원`, 고정비/
  비율 거래, win/lose, 리퍼폰 환불을 포함한 구 저장, save/load 반복, rollback,
  19개 선택·15개 사건·두 현금 부족 대체 선택을 통과하며 모든 직렬화 시점의 현금이
  정수 원임을 잠근다.
- `tools/SimRun.gd`, `tools/balance_sim.py`, `tools/convergence_sim.py`,
  `tools/CoreLoopV2HandoffCheck.gd`와 관련 수치 기준선을 production과 같은 정산으로
  맞춰 24·48·240주 결과를 다시 계산한다. 변화한 밴드는 숨기지 않고 실제 값으로
  검토하되 기존 허용 범위 밖이면 자동으로 넓히지 않는다.
  `docs/CONVERGENCE_REPORT.md`도 같은 계산으로 다시 생성한다.
- `tools/audit.py` 또는 전용 `tools/opportunity_money_audit.py`는 기회 선택 19개,
  사건 15개, 양수 최소 베팅과 합법 대체 선택, 현금 정수 직렬화를 검사한다.
  `docs/BALANCE.md`, `docs/QA_CHECKLIST.md`, `docs/MODDING.md`와 현금 단위 정본은
  정확한 정책·조건 키·구 저장 처리·실측값을 소유한다.

## 착수 소유권

- 런타임: `autoloads/GameState.gd`, `autoloads/EventManager.gd`,
  `autoloads/DataRegistry.gd`, `systems/InvestmentSystem.gd`, `scenes/MainGame.gd`,
  `scenes/StoryMode.gd`.
- 콘텐츠: 위 일곱 `content/events/*.json`와 두 대체 선택의 EN overlay.
- 회귀: `tools/SimRun.gd`, `tools/balance_sim.py`, `tools/convergence_sim.py`,
  `tools/CoreLoopV2HandoffCheck.gd`, `tools/audit.py`, `tools/mod_pack_validator.py`,
  신규 `tools/MoneyIntegrityCheck.gd/.tscn`, 선택 기회 전용 감사,
  `tools/ScreenshotQA.gd`, `tools/audit.sh`, `tools/audit_scope.json`.
- 정본·완료: `docs/BALANCE.md`, `docs/QA_CHECKLIST.md`, `docs/CORE_LOOP_V2.md`,
  `docs/CONVERGENCE_REPORT.md`, `docs/MODDING.md`, `CLAUDE.md`,
  `docs/CODEX_QUEUE.md`, `docs/WORK_LOG.md`, `docs/STATUS.md`,
  `docs/RELEASE_NOTES.md`, `docs/DEMO_FIXLOG.md`,
  `content/meta/release_content_inventory.json`, `docs/CONTENT_RATING_INVENTORY.md`,
  `docs/queue_active/ORDER-84.md`, `docs/queue_archive/ORDER-84.md`.

## 비범위

- 현금 외 투자 수량·확률·수익률을 정수화하지 않는다. 급여·대출·주거·투자 수치를
  재밸런싱하거나 새 기회 사건을 만들지 않는다. UI 전체에 미래 결과를 해설하지
  않고, W8 Pareto 우세와 치명 비용 표시는 후속 결합 오더가 소유한다.
- 저장 스키마 번호, `finish_run`, 엔딩 우선순위, 데모 retail 기본 진입과 준비 언어
  노출은 바꾸지 않는다.

## 검증과 사람 판정

- L1: 기회 19개/사건 15개 전수·두 단일 선택 사건의 현금 부족 대체 경로·정수 현금
  직렬화·구 저장 정규화·0원 무효·양수 win/lose·24→48주·240주 밸런스·한영 선택
  가능성·전체 감사·CI를 통과한다.
- L2: 같은 거래를 두 번 반올림하지 않는지, 음수/0/1원 경계, 대출·급여·투자·
  환불의 합이 보존되는지, 바뀐 기준값이 실제 production 계산인지 교차 검토한다.
- L3: 이번 불변식 자체에는 취향 판정이 없다. 선택 비활성 설명이 플레이를 막거나
  결과를 미리 해설하는지는 기존 정상 속도 데모 사람 게이트에서 함께 본다.

## 완료 조건

- 모든 새 게임과 로드 저장의 현금은 1원 단위이고, 거래마다 정산은 한 번이다.
- 베팅금 0원은 어떤 결과·플래그·기술·RNG 소비도 만들지 않으며 합법 대체 선택이 있다.
- 기존 소수 저장은 결정론적으로 한 번 정규화되고 반복 로드해도 달라지지 않는다.
- 실제 24·48·240주 기준선과 KO/EN 입력, 전체 감사, 원격 CI를 통과하고 규범을
  정본에 승격한 뒤 아카이브한다.
