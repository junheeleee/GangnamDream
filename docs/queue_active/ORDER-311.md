# Active Queue Spec: ORDER-311

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-311 [QA] 310의 정확 영어 후계와 역사 핀을 분리한다

2026-09-27 Codex 선언. 310의 제품21문자열 수리로 변하는 EN arc/core/controller를
현재 raw source로 검사하고, 기존 역사 검사에만 정확 역투영한다. 기존305/304
핀·전이·공개/인간/수용 판정을 재발급하거나 덮지 않는다. 기준 `0f0b5e8`.

## 깊이 3문

- 없으면: 의미가 보존된 현재 영어 파일과 과거 source 핀이 충돌하여 정당한 수리를 거부한다.
- 장기 상태: 검사 관측만 바꾼다. 게임/선택/저장/240주 상태는 불변이다.
- 경쟁: 범용 치환·핀 덮기 대신 exact immutable 전후 파일/객체 대조만 허용한다.

## 소유·한 배치

- `/root/blackjack_accounting_tests`: 새 `tools/order310_demo_source_compat.py`,
  기존 reader `tools/year5_reference_route_audit.py`, `tools/chapter5_human_reject_audit.py`,
  `tools/full_body_translation_scope.py`, `tools/chapter1_core_loop_v2_causal_ledger_check.py`,
  `tools/story_graph_contract_audit.py`의 새 후계 어댑터 경계만. 각 역사핀/기존 음성회귀는 보존.
  기존 `tools/order305_demo_source_compat.py`는 무수정이며 새 단계가 먼저 검증/역투영한다.
- root: `tools/audit_scope.json` 새 helper 등록과 caller 매핑, 실제 EN graph sourcehash만
  `tools/full_game_volume_baseline.json`에 갱신. KO분량/부채/제한/목표/상태 변경0.
  이 사양·큐·WORK_LOG·생성STATUS와 새 private `order311-*` 증거.
- 비저자 `/root/blackjack_accounting_review`: 310에 선언한 별도 보고만 소유.

새 raw는 정확 current3파일을 요구하고 predecessor/변조/중복/누락/순서변경은 거절한다.
역사 투영은 deep copy이며 live 파일을 고치지 않는다. 특히305 current_source_errors는
305 역사 입력에만 쓰고 raw310입력 검사를 생략하는 근거로 삼지 않는다.
각 caller normal/표적 self, 새 helper 전이·변조·불변 검사, graph/volume 정합을 실행한다.
legacy 검사 전체는 금지하고 변경 경계의 별도 회귀만 실행한다. 느린 year5 기존702회귀는
영향 분석 후 한 번만 실행하며 같은 무변경 증거를 복제하지 않는다.
후계 제품commit은310 저작 동결 뒤 결속한다. 정상/실패 raw·검수 source/tree를 보존한다.

표적 검사 GO는 과거GO/전체제품/새패키지 GO가 아니다. 인간OPEN45·공개옛GO1·
전체본편HOLD를 유지한다. 이 오더는 일회성 exact 호환이며 새 규범을 만들지 않는다.
