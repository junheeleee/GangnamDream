# ORDER-487 — 상시 실패와 닫힌 오더의 이력 검사 정리

#### [x] ORDER-487 [검수 절차] 실패 전수표 선커밋 → 이력 전용 검사 삭제 → 녹색 CI — 2026-10-09

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
- docs/CODEX_QUEUE_L3_PENDING.md의 완료 행 제거에 따른 순번만 기계적으로 정렬한다.
  기존 L3 문구·상태·사양·판정은 변경하지 않는다.
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
- localization_collector_author의 collector 저작 종료 뒤 같은 저자가 기존 사실 검사
  tools/first_win_fact_audit.py·ending_money_fact_audit.py·night_routine_time_audit.py·
  investment_loss_gate_audit.py·investment_loss_hold_result_audit.py·
  wealth_milestone_log_audit.py·prose_recall_audit.py·coffee_encounter_locale_check.py를 맡는다.
  실제 비용·임계/순자산·시간/장소/수신·영수증 조건과 표적 변조는 유지하고
  고정 before/after·전체 raw 봉인·전이 전용 self-test만 제거한다.
- root: 나머지 선언 파일·등록·삭제·통합 검증·문서·main commit/push.

추가 의존 실사에서 확인된 파일도 같은 오더에 먼저 선언한다(게임 범위 증가는 없다).
- tools/meta_title_locale_successor.py·holdem_residual_locale_check.py와
  ui_receipt_cost_profile.py·ui_receipt_cost_profile_check.py는 옛 endpoint/비용 전용 삭제 후보다.
- gift_caption_locale_self_test.py·new_run_log_locale_self_test.py·first_start_notice_self_test.py,
  decision_risk_width_self_test.py·reaction_body_font_self_test.py·log_body_font_receipt_check.py,
  scalping_phase_focus_receipt_check.py·investment_ap_copy_self_test.py·
  investment_loss_gate_self_test.py·full_game_localization_self_test.py는 기존 현재 의미/형식/
  레이아웃/공식 receipt 부정 테스트를 유지하고 이력 전용 분기·폐지 파일 참조만 제거한다.
  삭제 후보의 추가 표를 별도로 선커밋한 뒤 삭제한다.
  scalping_phase_focus_receipt_check.py의 전체 내용 실사 결과 실제 focus/input 조건 없이
  closed427의 고정 Git/역상/call count뿐이라 삭제 후보로 표를 갱신한다.
- tools/chapter1_ui_proof_reuse_check.py도 완료408 Git-prefix/호출 수 전용이며
  현재 제품 동작이 없으므로 마지막 추가표 선커밋 뒤 삭제한다. 실제 Chapter1 조건은 보존한다.
- 마지막 일반 이름 실사에서 tools/market_cycle_log_audit.py·asset_one_billion_log_audit.py의
  고정 parent/raw/fixture SHA 전용 성격을 확인했다. 추가표 선커밋 뒤 삭제하고 실제 .gd/.tscn은 보존한다.
  tools/holdem_tutorial_ui_self_test.py는4잎 제품 부정 테스트를 보존하고 DECLARED raw pin만 제거한다.
- 실제 main CI37851130776의 목록 밖 STATUS_DOC_EXIT를 수리하기 위해 기존 QA14개의
  Godot 생성 식별자만 소유한다: tools/{AssetOneBillionLogCheck,ChapterFourRelationshipCheck,
  FirstWinFactCheck,InvestmentAPCopyCheck,InvestmentLossGateCheck,InvestmentLossHoldResultCheck,
  MarketCycleLogCheck,NightRoutineTimeCheck,OpeningRhythmCheck,PR31EndingDescriptionCheck,
  ProseRecallCheck,RoutineBackgroundInputCheck,StoryChoiceFactCheck,WealthMilestoneLogCheck}.gd.uid.
  새 검사/스크립트가 아니라 기존 .gd의 누락 sidecar다. 격리 clone에서 첫 import가14개를
  미추적 파일로 만들어 clean 후보를 오염시킨 사실을 확인했다. 현재 후보 판정·신선도 검사는
  약화/skip하지 않으며 게임 .gd·데모 원본·저장·project.godot는 소유하지 않는다.

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

## 구현·검증 진행 (2026-10-09, main CI 대기)

- cad6d39의 전수표 뒤 추가 의존 표214e9d6/f7cdf69를 먼저 커밋하고,
  닫힌 이력·고정 endpoint·비용 전용56파일과 audit.sh의 이력 flag15개를 제거했다.
  기존 제품 검사는148flag로 계속 실행한다. 삭제 파일/비제품 근거는 WORK_LOG와 전수표가 소유한다.
- 기존 collector·validator·parser에서 이력 dependency만 분리했다. strict JSON/문자좌표/
  원 receipt·데모72/467 및 공개 reuse8·경제/시간/장소·저장/compile 조건을 보존했다.
  UI append109/value168/projection88·full-game265·trace187·demo16+62·JA collector76,
  현재 JA/zh·EN/한글누출·서사 연속성·liveness·context/queue/등록 표적 PASS다.
- 실제 제품 FAIL5는 KNOWN_FAILURES에 Codex 소유/2026-10-16 만료로 기록했다.
  검사 실행·FAIL 로그는 남고 CI의 정확 exit1만 비차단이다. 미등록/만료/비정상 종료는 빨강이다.
  전체 main CI의 실제 새 source 완료를 기다리므로 이 오더는 [~]이며 아직 녹색 판정이 아니다.
- 게임 원문·번역·원장·저장·project.godot·과거 인간 판정 변경0이다.
  검수 자체를 출시/원어민/화면 GO로 확대하지 않으며 다른 새 오더0을 유지한다.
- 실제 main0fb0807/run37851130776은 정적/밸런스 성공, 전체 감사의 컴파일68 성공이며
  정확 known5 외 실패는 STATUS_DOC_EXIT 한 건이다. 이 때문에 입력/240주 후속은 미실행이다.
  fresh clone의 첫 import가 누락 QA UID14를 만들며 후보 신원 reason을 바꾸는 오탐을
  재현했다.6305215에서 소유 선언 뒤 엔진 생성 UID14만 수용하여 검사를 그대로 유지한다.
  실제 main 녹색 재확인 전까지 이 오더는 계속 [~]다.

## 실제 main 녹색 확인·마감 (2026-10-09)

- main00eec859470bf69c86cf989b7bbe587f07e2072c/source0af4ca6987aaec94c34d14cd738c2d443f524342의
  [CI37858051278](https://github.com/junheeleee/GangnamDream/actions/runs/37858051278)는
  2026-10-09T00:38:35Z completed/success다. 정적·밸런스 job113586904516과
  Godot·입력·240주 job113586904198 모두 success이며 skipped 제품 단계0이다.
- 실제 로그: DASHBOARD_FRESH; COMPILE_CHECK_OK total=68;
  감사 통과 known_failures=5 allowed_in_ci=True. 목록 밖 실패0이며 정확5건은
  실패 로그/소유자/2026-10-16 만료를 보존한다. 실패를 제품 GO로 바꾸지 않는다.
- CORE_LOOP_V2_INPUT_OK device=gamepad lang=ko weeks=24 gamepad_events=1640;
  device=keyboard lang=en weeks=24 keyboard_events=1646. 둘 다 semantic_events=0,
  unknown_events=0·autosave=1·title_return=1·first_bill=1/1/1이다.
  SIMRUN_CASH_INTEGRITY_OK checkpoints=24/48/240·SMOKE_ALL_OK도 실제 로그에서 확인했다.
  이는 자동 입력 회귀이며 인간·원어민·물리 패드 감각 관찰이 아니다.
- 입력 로그·화면 artifact11587947306/core-loop-v2-input-1(4,712,075byte),
  digest b5869e6b9b70e2574f7bff41fb9d60a9f000480dd1317d3a25933c3cd58bc665를 CI가 보존했다.
  원문·번역·원장·저장·project.godot·과거 인간 판정 변경0, 공개 데모 GO와 본편 HOLD 유지다.
- 규범 판정: 계속 유효한 검수 원칙은 이미 DECISIONS 2026-10-08이 소유한다.
  이 오더의 파일 소유·표 선커밋·삭제56·CI 마감 순서는 일회성이다.
  신규 규범/비용 도구/후속 계측 오더0. 기본 arc_36_unexpected_hand 문장 수리는
  이 마감 뒤 별도 선언한다. 2장 수첩·5장 기간 수리는 완료472를 재적용하지 않는다.
