# ORDER-568 — 일반 종막 검사의 무관한 전체 사건 수 고정 제거

#### [x] ORDER-568 [검사 오탐 정리] source·표적 검사 완료 — 2026-10-12

567 표적 검사에서 확인한 extra FAIL1만 처리한다. main ab66435c의
CI38196803190은 completed/success다. 이 extra 검사는 audit.sh 호출 대상이
아니며 main CI 실패 원인이라고 쓰지 않는다. M17/562 한 월·OS잠금 HOLD는 유지한다.

## 깊이 3문·근거

1. 종막과 무관한 전체 사건 개수를 고정해도 종막 도달·선택·저장 동작은
   보장되지 않는다. 실제 ROOT_IDS 비도달 방어와 영수증·라우팅 검사는 남긴다.
2. 589a0f60의 승인된 4장 비도달6 전환으로 shipping1708→1702가 됐다.
   게임/원장을 되돌리거나 옛 수치에 맞추지 않는다. counts/hash 일치는
   기존 tools/event_lifecycle.py의 현재 코퍼스 대조가 계속 소유한다.
3. 새 검사/비용 도구와 경쟁하지 않는다. DECISIONS 2026-10-08의 제품 동작
   없는 이력 고정 제거에 따라 최소 부분만 지우며 나머지 검사를 확대하지 않는다.

## 삭제 전 표 — 이 표를 먼저 커밋한 뒤 다음 커밋에서 삭제

| 검사명/부분 | 지키는 제품 동작 | 실패 원인 | 처리 |
|---|---|---|---|
| chapter5_general_finale_route_audit의 전챕터 packaged1813/shipping1708 exact pin | 없음. 전체 옛 개수와 같아도 종막은 비도달일 수 있다. 실제 종막 ROOT_IDS의 author_only 방어는 별도이며 보존한다. | 승인된 4장6건 비도달 전환 뒤 정본 shipping1702와 옛 상수1708 불일치 | 두 상수와 validate_lifecycle의 counts exact 비교만 삭제. 현재 코퍼스 counts/hash/schema는 event_lifecycle.py 유지. census 전용 self-test가 있으면 같은 범위에서 제거하며 나머지는 유지. |

## 정확한 소유

- root: tools/chapter5_general_finale_route_audit.py의 EXPECTED_PACKAGED_EVENTS /
  EXPECTED_SHIPPING_EVENTS와 validate_lifecycle의 counts exact 비교만.
  object·author_only 배열·ROOT_IDS 방어, 나머지 실제 종막 검사는 보존한다.
- root: 큐2/이 사양(마감 archive)/WORK_LOG·CLAUDE 현재행만. 선언과 함께
  완료567 사양을 archive로 옮긴다. WORK_LOG 예산 때문에 기존39872B를
  docs/history/WORK_LOG_2026-10-12_pre_order568.md에 byte-exact 이동한다
  (SHA f733be0a4de292acfa40d7717be6180b5d5847dfa37e963628043eae5b8ce652).
- manual_save_ci: 읽기전용 삭제 범위·제품 방어 보존 독립 검수만.
- rework_batch_plan: 새 .git/order568-20261012/ 보존 before/final만.
- mod_layer_ci: 기존567의 새 CI 최종 증거만. 옛 봉인은 수정하지 않는다.

게임 원문·번역·원장·모든 runtime/저장·project/presets·public/Human·원seed/raw/app·
audit.sh/audit_scope/KNOWN_FAILURES와 기존 self-test 기준은 비소유다.
검사 파일 전체 삭제·새 도구/등록/self-test·비용/시간 최적화·엔진/전체audit/240주0이다.

## 검증·마감

- 선언 커밋 뒤 기존 general finale audit와 self-test, event_lifecycle와
  그 self-test, context/queue/diff 및 영향 목록을 표적으로 확인한다.
- 정상 검사 PASS만으로 제품 방어 보존을 추정하지 않는다. 비저자가 실제
  삭제 diff·기존 lifecycle의 counts/hash 검증과 종막 비도달 방어를 직접 대조한다.
- 삭제 목록과 제품 동작이 없던 근거를 WORK_LOG에 남긴다. 제품/원장/기존
  원자료 불변을 확인하고 commit/push한다. 새 CI는 실제 상태 그대로 기록한다.
- 자동 계약은 도달성과 계약 증거이지 재미·깊이·문체/인간 관찰이 아니다.
  실제 앱/CJK/원어민/패드/청취·전체 번역 INCOMPLETE·본편/출시 HOLD를 보존한다.
  월별 검수 마감 커밋0·새 월0·OS해제 재요청0, 모든 지시는 일회성/승격0이다.

## 결과·한정 마감

- 삭제 전 표/선언 de1315230b2514b24b3d5f48ccca1fd52be4c1fb/treec603597cf7a3c2529963042f810ac346bb83a45e를
  먼저 commit/push했다. 그 뒤 검사 한 파일의 두 상수+counts 비교만 0+/10−로
  제거했다. 종막 도달/선택/영수증/라우팅·object/array/ROOT_IDS 방어와 기존
  self-test 전체는 byte-exact다. 제거할 census 전용 self-test는0이었다.
- 삭제 목록은 표의10줄뿐이다. 전챕터 옛 개수의 일치는 종막 제품 동작을
  보장하지 않았다. 현재 코퍼스 counts/hash·실제 shipping 분리의 소유자
  event_lifecycle.py와 audit.sh 등록은 바꾸지 않았다. 새 상수 재고정0이다.
- 실제 기존4검사 모두 exit0/stderr0: general audit·self-test32,
  lifecycle·self-test27. packaged1813/shipping1702·author111·product ingress0이다.
  raw8개680B·static-results.json SHA4be862b58c36b70af59753ac42dbe27478a0efd5e3e1c0145d9c16da7c5a9bed,
  검사 source SHAdfe4f57fa8011403626d27bb869480d526f165f9c25b3fb7e5273698d4061438.
  영향12개는 목록만 조회했다. 제품/엔진 입력 불변이므로 엔진·전체audit/240주0이다.
- 비저자 source-review.md 2824B/SHA5b8193394f1be05625c5e1ffd2ff3bae6985fbb4c9ad35c93d59d6de6876db24를
  root가 전문 판독했다. 실제 diff/남은 bytes/기존4검사 원출력을 직접 읽은
  checker source 한정 GO·blocker0이다. 제품 후보/새 CI GO가 아니다.
- 새 .git/order568-20261012/ 보존 before46그룹/776항목·비소유3353,
  SHA89597b70c7a64bc3efbe697ffd4c8d48ca5c5b842f0cf9346b052905e7adcd18.
  final은 같은 곳 independent-preservation-final.json으로 별도 결속한다.
  옛567 FAIL/pending/CI 종료 ERROR 봉인·39872B WORK_LOG 원문은 보존했다.
- gangnamdream-dev의 제품/이력 핀 분리와 비저자 실제 증거 판독을 적용했다.
  source 수리만 완료하며 실제 main push/새 CI는 뒤의 읽기전용 snapshot에서
  결속한다. M17 OS잠금 HOLD/native0·게임/원장/사용자 저장 불변·인간/원어민/
  패드/청취·전체 번역 INCOMPLETE·본편/출시 HOLD는 유지한다. 일회성/승격0이다.
