# Active Queue Spec: ORDER-241

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-241 [P0·검사] VIP 인사 로그의 중국어 단수 생략 오탐을 수리한다

**[~] 2026-09-12 Codex 착수 — 아래 파일만 소유한다.** 로컬 기준 HEAD
`56348b9df108836a689133b14e4f303f42d1d922`, tree
`88d516dbeb1910092104bf47459fe643b41faef6`. 진행 중240의 테스트2 신규 파일은
Rawls 소유이며 그대로 보존한다. 완료·검증 뒤 main/mirror를 동기화한다.

## 깊이 3문·하나의 판정 단위

1. 그대로 두면: 승인한 중국어 `有个人/有個人`의 생략된 一를 인식하지 못해
   실제 한 사람이 다음 만남을 물었다는 두 번역을 잘못 차단한다.
2. 장기 영향: 검사 전용 수량 정규화이며 실제 산문·상태·약속 성사·저장 변화0이다.
3. 대안: 자연스러운 번역을 검사기에 맞춰 고치거나 전역 수량 검사를 약화하지 않는다.
   정확한 UI 원문·키·중국어 locale에만 좁힌 회귀 수리 하나로 판정한다.

## 소유권과 보존선

- Plato 제품2: `tools/zh_translation_audit.py`,
  `tools/full_game_localization_self_test.py`. 실제 첫 L1의 두 오탐만 대상으로
  원문·정확 UI key·CN/TW에 결속한 helper와 고정 회귀를 추가한다.
- ROOT 운영: `tools/audit_scope.json`, `CLAUDE.md`, `docs/CODEX_QUEUE.md`,
  `docs/CODEX_QUEUE_L3_PENDING.md`, 이 사양·`docs/queue_archive/ORDER-241.md`,
  `docs/WORK_LOG.md`, `docs/history/WORK_LOG_2026-09-07_localization.md`,
  `docs/STATUS.md`, `docs/queue_backlog/FULL_GAME_LOCALIZATION.md`,
  `docs/agent_review_decisions.json`, `docs/agent_reviews/ORDER-241.json`.
- WORK의 완료231/230 두 절만 기존 현지화 이력 앞으로 원문 이동한다. 진행 중
  작업은 이동하지 않으며 나머지 bytes와 EOF를 보존한다.
- 240 source2/UI3/portable/test2는 해당 오더 소유다. 이벤트·게임플레이·돈·관계
  효과·기존 검사 기대·일반 숫자 parser·플레이어 저장·project·인간 원장은 수정0이다.
- `.git/full-game-localization/order241-*`는 독립 사전 controls·저작·회귀 사적 증거다.

## 수리·검증 계약

- 첫240 L1의90개 중2실패 원형과 승인 번역표를 유지한다. 출발할 때 한 사람이
  다음 만남을 물은 정확한 문장 역할 안에서만 `有个人/有個人`을 numeric-only
  `有一个人/有一個人`으로 해석한다. 실제 target은 바꾸지 않는다.
- 기존 script/token/용어/통화/줄바꿈/영어 검사는 원 target을 계속 읽는다.
  모든 entity 수량에 一 생략을 허용하거나 실패를 통째로 면제하지 않는다.
- Poincare가 저작 전 고정 controls를 봉인한다. 실제2와 정상 단수 표기,
  오수량·누락·잘못된 역할·중복·복수·key/source/locale OFF를 포함하며
  기대값은 제품 출력으로 만들지 않는다. Plato는 같은 controls를 회귀에 넣는다.
- 같은90 L1을 수리 뒤 재실행한다. 240과 공유하는 전체수용 L1 및 명시 정적
  검사는 최종 입력에서 한 번 실행하고 양쪽 근거로 연결한다. 신규 고정회귀 외
  기존 검사 원형을 보존한다. 전체감사·240주·실제 플레이 판정으로 확대하지 않는다.
- 비저자가 최종 exact source와 수리·실패 증거를 직접 검토한다. 내부 단위 GO만
  해당하며 공개GO1/인간OPEN45/본편HOLD와 native/render 미관찰은 보존한다.

규범 승격 없음: 기존 I18N·WORK_UNIT 적용. 정확 원문·소유·검수는 일회성이다.
