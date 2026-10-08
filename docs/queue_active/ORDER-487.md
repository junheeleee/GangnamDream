# ORDER-487 — 상시 실패와 닫힌 오더의 이력 검사 정리

#### [~] ORDER-487 [검수 절차] 실패 전수표 선커밋 → 이력 전용 검사 삭제 → 녹색 CI — 2026-10-09

## 근거 / 판정 범위

사용자의 PR #32 병합·484 마감 직후 단일 정리 지시와
DECISIONS 2026-10-08을 실행한다. 484 source/UI32는 faa7158에서 마감했으며
표적 검사5 FAIL은 성공으로 바꾸지 않고 이 정리의 실제 입력으로 삼는다.
정리 완료까지 다른 새 오더를 열지 않는다. 479·481 및 계측·재사용·시간단축
후속은 중단한다. 새 검사 도구·새 오더별 이력 연결·비용 계측기를 만들지 않는다.

- 지우면: 정상 UI/원장 append가 닫힌 source pin을 건드렸다는 이유로
  번역·데모 제품 검사까지 실패하는 의존을 제거한다. 제품 검사는 남는다.
- 독자: audit.sh의 종료 집계·audit_scope 등록·GitHub CI가 현재 제품의
  실패와 만료 있는 알려진 실패를 구분한다. 과거 Git/인간 판정은 불변이다.
- 경쟁: 매번 새 오더의 history helper를 덧붙이는 방식은 승인 결정에 반하므로
  하지 않는다. 실패를 숨기는 넓은 예외나 제품 검사의 삭제도 하지 않는다.

## 선언된 파일 소유

root와 아래 분리 저자가 다음 도구·등록·CI와 운영 문서만 소유한다.

- tools/audit.sh, tools/audit_scope.json, .github/workflows/ci.yml.
- tools의 닫힌 오더 전용 *history*.py, order*_source_compat*.py,
  order*_demo_source_compat.py, order316_header_source_compat.py,
  order365_ui_receipt_compat.py 및 해당 전용 self-test/receipt check.
  삭제 대상의 정확 목록·비제품 근거는 아래 표를 먼저 커밋해 확정한다.
- 그 의존을 읽는 기존 제품 검사/수용기: full_game_localization.py,
  ja_translation_pipeline.py, ja_translation_audit.py, zh_translation_audit.py,
  demo_localization_scope.py, ui_translation_append.py,
  full_body_translation_scope.py, chapter1_core_loop_v2_causal_ledger_check.py,
  chapter5_human_reject_audit.py, investment_loss_gate_audit.py,
  investment_loss_hold_result_audit.py, first_win_fact_audit.py,
  ending_money_fact_audit.py, wealth_milestone_log_audit.py,
  night_routine_time_audit.py, year5_reference_route_audit.py,
  story_graph_contract_audit.py, prose_recall_audit.py,
  coffee_encounter_locale_check.py, ui_fixed_ledger_projection_check.py,
  ui_append_value_parse_check.py. 역사 의존만 제거/오류 처리 수리하고 제품 조건은 유지한다.
- 추가 확인된 기존 소유/전용 suite: meta_title_locale_successor_self_test.py,
  ci_localization_reconciliation_self_test.py, pr31_main_proof_scope_check.py,
  holdem_manifest_proof_scope_self_test.py, chapter5_proof_scope_self_test.py,
  ui_comparison_memo_self_test.py. 고정 raw/history·비용 suite만 제거한다.
  ui_translation_append_self_test.py는 generic receipt/parser 제품 반례를 유지하며
  삭제한 history 분기만 분리할 수 있다. full_game_runtime_trace_audit.py·
  full_game_runtime_trace_contract.py·feature_liveness_audit.py·project_dashboard.py는
  확인된 old byte seal/독립 QA 오탐/생성 현황 비교만 수리할 수 있으며 제품 조건은 유지한다.
- docs/queue_backlog/AUDIT_FAILURE_TRIAGE_2026-10-09.md,
  docs/KNOWN_FAILURES.md, docs/context_manifest.json, docs/CODEX_QUEUE.md,
  docs/queue_active/ORDER-487.md·완료 archive, docs/WORK_LOG.md,
  생성 docs/STATUS.md, CLAUDE.md 현재 상태.

표 선커밋 cad6d39 이후 구현 파일 소유를 다음처럼 분리한다. 새 오더가 아니다.

- localization_collector_author: tools/ja_translation_pipeline.py만.
- localization_audits_author: tools/ja_translation_audit.py·zh_translation_audit.py만.
- causality_audits_author: tools/chapter1_core_loop_v2_causal_ledger_check.py·
  story_graph_contract_audit.py·year5_reference_route_audit.py·chapter5_human_reject_audit.py만.
- localization_audits_author의 두 validator 저작 종료 뒤 같은 저자가
  tools/full_body_translation_scope.py만 이어 맡는다. 현재 lifecycle/typed closure·
  target receipt·공개 데모 reuse 제품 조건은 유지하고 source history와 옛 census만 분리한다.
- root: 나머지 선언 파일·등록·삭제·통합 검증·문서·main commit/push.

저자들은 기존 제품 조건을 보존하며 자기 파일의 역사 dependency만 걷어낸다.
root가 strict JSON/span을 기존 ui_translation_append 소유자에 보존한다.
각 저자는 새 tool/report·게임/원장 변경·자체 commit·엔진 실행을 하지 않는다.
비저자는 읽기 검수/메시지만 소유하며 구현 파일의 동시 소유0이다.
목록 밖 실제 의존은 편집 전에 사양에 정확히 선언한다.

## 순서 / 완료 조건

1. 현재 audit.sh의 모든 상시 실패를 기존 실제 실행/CI 증거에서 전수 수집한다.
   검사명 / 지키는 제품 동작 / 실패 원인 / 고침·삭제·KNOWN_FAILURES 표를 만든다.
   실행하지 않은 항목이나 미확인 원인을 성공·상시 실패로 단정하지 않는다.
2. 위 표만 먼저 커밋·push한다. 그 뒤 별도 커밋에서 닫힌 오더 전용 이력
   고정 검사와 전용 self-test를 제거하고 audit.sh/audit_scope 등록을 정리한다.
   WORK_LOG에 삭제한 검사와 제품 동작이 없었던 근거를 남긴다.
3. 남는 실패는 KNOWN_FAILURES에 이유·소유자·만료일(최대30일)과 함께 명시한다.
   CI는 이 정확 목록 밖 실패와 만료된 예외만 빨강으로 처리한다. 전역 skip 금지다.
4. 기존 영향 제품 검사를 통과시키고, 실제 main CI 녹색(정확 KNOWN_FAILURES 제외)을
   확인한 뒤에만 정리 완료로 닫는다. 감사 통과는 전체게임·재미·출고 GO가 아니다.

## 실제 첫 표 (2026-10-09)

[실패표](../queue_backlog/AUDIT_FAILURE_TRIAGE_2026-10-09.md)를 cad6d39에서 단독 선커밋·push했다.
현재 집계163flag·관측 실패 합집합36행이다. 최신 직접 FAIL13/PASS1,
과거 종료 로그만22·나머지127 미완주를 분리했다. 비저자 audit_history_classification의
읽기 검수에서 수량·미실행 판정·삭제 근거의 blocking0을 확인했다. 이 시점 삭제0,
KNOWN_FAILURES 적용0·main 전체 CI 아직 녹색 아님이다.

보존: EN 한글 누출, 번역 원장 정합, 서사 연속성, 장면 음악, 데모 고정,
컴파일, 저장 호환 검사. 게임 원문·번역·저장·project.godot·공개 패키지·
human_gates/과거 판정은 수정0이다. "지난 주말 가지 못한 곳" 기본 변형 수리는
이 정리 뒤 문장 묶음으로 남긴다. 새 규범은 승인 DECISIONS가 소유하며 실행 순서는 일회성이다.
