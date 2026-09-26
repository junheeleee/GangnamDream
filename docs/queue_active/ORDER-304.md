# Active Queue Spec: ORDER-304

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-304 [표적 QA] 재혁 EN3leaf 수정과 과거 기준선을 구분한다

**2026-09-27 Codex 선언.** ORDER-302 A의 실제3문장 수리 `3fb9890`에서
year5 역사 검사3오류와 volume source hash1오류를 재현했다. 기존 승인·밀도
부채를 없애지 않고 새 문장과 과거 기준선을 정확히 구분하는 일회성 호환 수리다.

## 깊이 3문과 범위

1. 제거 손실: 승인된 영어 오역 수정이 과거 Ch5 객체 변경으로 오인되어 표적 검사가 실패한다.
2. 장기 상태: 원고·플래그·경제·입력·저장·과거 manifest/registry/GO는 그대로다.
3. 경쟁: QA의 historical inverse만 추가하며 현재 원문을 읽는 runtime/현재 volume 관측은 숨기지 않는다.

- 저자 `/root/blackjack_accounting_tests`: `tools/year5_reference_route_audit.py`만.
  exact EN 파일/이벤트/수정 전후 객체 SHA 및3leaf inverse를 최신 역사 projection에
  연결한다. bytes/hash도 exact transition만 허용한다. 다른 값·배열 순서·타입·경로·
  ID 변이는 지우지 않는다. 과거 expected hash/registry는 바꾸지 않는다.
  내장 self-test에 정상·변조·idempotence 경계를 추가한다.
- root: `tools/full_game_volume_baseline.json`의 `source_hashes.graph:en_mapped_immediate`
  한 값만 실제 새 관측으로 갱신한다. `current_report()` 비교에서 나머지 section 및
  observations/allowlisted_findings 동일을 확인했다. 자동 전체 baseline 재생성은 하지 않는다.
- root: 이 사양→`docs/queue_archive/ORDER-304.md`, 큐 두 파일 순번, WORK_LOG,
  생성 STATUS, CLAUDE 현재 행, `docs/agent_review_decisions.json` 새304행,
  독립 보고 정확복사 `docs/agent_reviews/ORDER-304.json`, 새 private
  `.git/full-game-localization/order302-demo-*`/`order304-*` 증거·helper.
- 비저자 `/root/blackjack_accounting_review`: 새 private `order304-review*.json` 및
  302-A 보고. 제품·검사기 저작과 분리한다. 다른 언어 독해는 별도 읽기 전용 보조다.

## 증거와 완료

- 실패 원본 `order302-demo-check-year5-before.json`/`volume-before.json` 보존.
- year5/volume 표적 normal+self-test,3leaf inverse-byte/토큰/개행 및
  baseline 한 hash 외 byte 보존, 기존 부채30·outlier12·HOLD 유지.
- EN coverage/Hangul/story-demo는 동일 원고 `3fb9890`의 기존 PASS 재사용.
- context/queue/audit_select/diff/dashboard 확인 및 실제 source 신원에 결속한 비저자 판정.
- 전체 감사·240주·엔진·화면·사람/원어민·물리패드·외부출시 판정은 하지 않는다.
  ORDER-302 전체는 계속 `[~]`,303은 그 뒤 대기다.
- 모든 추가 지시는 일회성이다. WORK_UNIT의 증거/역사 보존 규칙을 바꾸지 않는다.
