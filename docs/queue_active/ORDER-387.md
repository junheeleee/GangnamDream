# Active Queue Spec: ORDER-387

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-387 [P1·검수 효율] Chapter 5 정상 검사 내 현재 소스 증명을 한 번만 연다

**[~] 2026-09-29 Codex 착수 — 아래 파일만 소유한다.** 사용자 검수 효율화 지시와
ORDER-386에서 실제 겪은 정상 검사 300초 timeout·단독 재시도 292.847초가 근거다.
ORDER-157 번역 검수에서 반복하는 같은 검사의 중복 비용만 줄이는 단일 작업이다.

## 깊이 3문

1. 없애면 무엇이 깨지는가: 같은 정상 검사에서 현재 소스·번역 영수증 이력 증명을
   구조상 네 번 열어 번역 배치마다 같은 비용을 지불한다. 검증 항목은 없애지 않는다.
2. 24주 뒤 상태 차이: 게임 선택 작업이 아니다. 런타임·원고·사전·저장·공개 후보
   변화는 0이며 다음 정상 호출은 Git/module 증명을 다시 읽는다.
3. 경쟁: 남은 번역 저작 시간과 경쟁한다. 정상 검사를 한 번 재측정하고 저비용
   focused 회귀만 추가하며 전체 감사·과거 self corpus·엔진 반복으로 확대하지 않는다.

## 정확한 소유

- Root: `tools/chapter5_human_reject_audit.py`에 정상 CLI용 invocation helper와
  호출 한 곳, 필요한 표준 import만 추가. 기존 `validate_model`, 모든 규칙·핀·역사
  self-test 본문은 byte-exact. `tools/audit_scope.json`에 해당 전용 차선·검사 등록.
- 별도 저자: 새 `tools/chapter5_proof_scope_self_test.py`만. 현재 증명은 한 호출에서
  공유, 호출 간 새로 읽기, 개별 raw 거부, 중첩·정상/실패/예외 해제와 CLI를 검사한다.
- Root 기록: 이 사양·`docs/CODEX_QUEUE.md`·`docs/CODEX_QUEUE_L3_PENDING.md`,
  `CLAUDE.md`, `docs/WORK_LOG.md`, 필요 시 기존
  `docs/history/WORK_LOG_2026-09-07_localization.md` 손실 없는 이동,
  `docs/queue_archive/ORDER-387.md`, `docs/agent_reviews/ORDER-387.json`,
  `docs/agent_review_decisions.json`, 생성 `docs/STATUS.md`.
- git-private `.git/full-game-localization/order387-*`: 실행·측정·독립 검수 증거.
  독립 검수자는 소스/시험 저작 없이 산출물·로그 전수 확인 후 최종 판정한다.

## 구현·표적 검증

- 기존 `ui_receipts.fresh_validation_proof()`를 정상 호출에만 사용한다. 전역 PASS
  cache·검증 생략·오류 숨김·비싼 실패 재시도·역사 핀 갱신은 금지한다.
- context 진입 실패만 기존 proof 오류 종류로 fail-closed 오류 목록에 바꾼다.
  본문 프로그래밍 예외를 proof 오류로 삼지 않는다. 정상 stdout/exit는 byte-exact,
  proof 진입 실패는 중복 오류 대신 명시 오류 1개와 기존 FAIL/exit 1 프로토콜이다.
- 새 focused 시험, 실제 정상 CLI 1회(과거 292.847초·stdout/exit 증거와 비교),
  registry/context/queue/diff와 영향 조회. 기존 baseline 정상 실행은 반복하지 않는다.
- 게임 파일 및 기존 증거/사람 원장 byte-exact 확인. 자동 시험은 계약 증거이며
  재미·깊이·문체·인간/원어민/물리 패드 또는 본편·출시 GO가 아니다.
- 선언과 검증 계획은 일회성이다. invocation-local 증명 경계는 구현 docstring과
  focused 회귀에 유지한다. 새 게임 규범은 없다.
