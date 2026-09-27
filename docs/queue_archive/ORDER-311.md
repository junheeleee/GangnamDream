# Archived Queue Spec: ORDER-311

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [x] ORDER-311 [QA] 310의 정확 영어 후계와 역사 핀을 분리한다

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

## 2026-09-27 완료 증거

- source `a0d4446f1290c22d6ef53b23e94e340439a5bf52`, tree `a4be8663f369da0048bc3031cab8070bcfdb1c86`; [독립 보고](../agent_reviews/ORDER-311.json) 작업 한정 판정.
- 생산자↔독자: `order310_demo_source_compat.py:109/120/187` exact3파일21leaf ↔ 다섯 역사 reader. 현재7파일 raw admission 후310→305 역투영, predecessor를 현재로 허용0. immutable305 helper 무수정.
- 도달 경로: helper106·역사132, year5 정상 선행/self720(702+18), graph 정상 선행/self97(66+31), body 정상/self53, volume 정상/self14, legacy 경계6, 등록156 PASS. 전체 legacy/240주 엔진은 실행0.
- volume EN graphhash1필드만 `f3d1d9e981f7f03a23a75c064f0b5567db35989f5ea701b3e4c4d7716c66f59b`로 동기화. 다른 관측/부채30/outlier12/runtimePENDING/humanOPEN 불변.
- chapter5 최초 normal은 기존308후계 누락1FAIL, self127은PASS였다. 실패를 덮지 않고 별도312에서 수리하여 최종normal/self146 PASS. 이 오더의 허용목록을 넓혀 숨긴 것이 아니다.
- `order310-check-312-bridge-first.json` SHA `addc10ddd1ee6894be520c3f54f6e775a127627e58223a862e121092ee23562f`: 이전18캡처(17PASS/1FAIL) 중16성공 재사용, chapter5 두 결과는 원형 보존/최종 대체. 원격 문서7개 병합의 제품/검사 변경0.
- 바꾸는 상태: 검사 관측만. 게임/저장/선택/장기 결과0. 포기비용·서사 위치·장면 계층 해당 없음. 닫는 것: exact 영어 후계 호환만. 전체 제품/공개/인간/원어민/물리 GO0.
- 규범 승격: 없음(일회성 exact 전이). 자동 게이트는 도달성·계약 증거이지 재미·깊이·문체의 증거가 아니다.
