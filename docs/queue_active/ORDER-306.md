# Active Queue Spec: ORDER-306

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-306 [QA] 승인된 데모23leaf 후계와 역사 검사 원형의 분리

2026-09-27 착수. 부모305 원고 변경을 과거 공개 승인으로 오인하거나 역사 핀을
덮지 않고 현재 소스 검사가 비교할 수 있게 한다. 검사 실패를 숨기는 예외가 아니다.

## 깊이 3문

- exact 파일핀이 원고의 승인된 작은 수리도 거부한다. 지우면 과거의 더 넓은 변조까지
  통과할 수 있으므로 기존 핀을 보존하고 새23leaf 후계를 유한하게 등록한다.
- 플레이어 선택/경제/상태/경로 차이는0. 원고305 외 변경을 허용하지 않는 검사 소유다.
- 공개/인간 판정 대신 현재 work_unit 호환만 판정하며 본편·새package는 계속 HOLD다.

## 파일 소유와 경계

- `/root/blackjack_accounting_tests`: `tools/year5_reference_route_audit.py`,
  `tools/chapter5_human_reject_audit.py`, `tools/full_body_translation_scope.py`,
  `tools/chapter1_core_loop_v2_causal_ledger_check.py`, `tools/full_game_volume_baseline.json`,
  새 `tools/order305_demo_source_compat.py`, 필요시 그 새 helper의 `tools/audit_scope.json` 등록.
- 새 helper는305 전후 commit/blob와5파일 raw SHA 및 정확23leaf/substring 역투영만
  인정한다. 기존304/165 등 registry·핀·과거 self-case는 보존한다. 임의 no-op/타파일/
  한 글자 변조/추가 gameplay/잘못된 후보는 후계로 인정하지 않는다.
- 기존 bytes/payload/hash/context 보호는 새305 inverse 뒤 기존 역사 chain 순서로 비교한다.
  ORDER155 census는 각 KO/EN exact 경로에만 전체 composed inverse가 과거 blob와 같을 때
  제거한다. 다른 경로나 failed/no-op inverse는 허용하지 않는다.
- volume은 실제 관측으로 바뀐 graph hash/글자수 등만 정직하게 갱신하며 분량 부채를
  완화하거나 역사 보고·baseline pin을 덮어쓰지 않는다. 변하지 않은 값은 그대로다.
- root: 큐 두 파일·이 사양·WORK_LOG·생성 STATUS·CLAUDE 상태행, 새 scoped 판정원장,
  private `order306-*` 증거. 비저자 `/root/blackjack_accounting_review`는 private
  `order306-review*.json` 및 `docs/agent_reviews/ORDER-306.json`만 소유한다.
- 실제5파일 원고는305 저자 소유. 공개manifest/human/기존agent행·release package 변경0.

## 검증

후계helper의 exact positive/negative/selftest, year5 normal/self, chapter5/full_body의
직접 영향 normal/self, volume normal/self와 실제 전후 관측 diff를 표적으로 삼는다.
legacy V2는 새 연결 경계의 단위 검사/정적 비교만 하며24주/240주 실행은 하지 않는다.
새 검사 등록 시 selector verify, context/queue/human-ledger/diff 검증. 원고305 engine와
증거를 공유하되 기계 PASS를 인간·원어민·물리/화면 관찰로 승격하지 않는다.
독립 비저자 전범위 검수 GO 후 작업 한정 종료. 규범은 일회성/기존 정본 적용이다.
