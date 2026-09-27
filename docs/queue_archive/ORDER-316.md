# Archived Queue Spec: ORDER-316

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [x] ORDER-316 상단 수리 exact 소스 후속 호환

2026-09-27 착수. ORDER-315의 두 표시 파일 변경이 기존 live exact 소스
검사에서 거부되는 영향이 확인됐다. 옛 증거나 핀을 고치지 않고 새 후속을 분리한다.

## 깊이 3문과 한 배치

- 없으면: 올바른 새 표시 소스도 과거 바이트와 다르다는 이유만으로 live 검사가 실패한다.
- 상태 차이: 게임 상태·원고·저장·공개 패키지는 불변이다. 새 두 파일만 exact 허용한다.
- 경쟁: 과거 검사의 해시를 갱신하거나 넓게 허용하는 대신 검증된 역투영을 추가한다.
- 기존 ORDER-310/305/156 전이·증거·핀은 무수정. 새 제품 커밋의 두 파일만
  exact byte/hash admission 및 검증된 이전 소스로 역투영하며 다른 경로·이웃 변경·
  rollback·증거 누락을 거부한다. 역사 Git blob 전용 검사는 손대지 않는다.

## 파일 소유와 검증

- `/root/header_layout`: 새 `tools/order316_header_source_compat.py`, live 소비자
  `tools/chapter5_human_reject_audit.py`, `tools/year5_reference_route_audit.py`,
  `tools/chapter1_core_loop_v2_causal_ledger_check.py`의 정확한 소스 admission/투영 경로만.
- root: `tools/audit_scope.json`의 316 전용 등록 항목(315 등록과 분리),
  큐·이 사양·진행 문서·판정 원장. 비저자 `/root/screen_independent_review`는
  `docs/agent_reviews/ORDER-316.json` 및 private 검수 증거를 소유한다.
- 제품 두 파일은 315 소유다. 제품 커밋을 고정한 다음 exact 전이 구현을 시작한다.
- 모듈 표적 자체 검사, live 소스 검사, 변조/잘못된 경로/rollback/증거 누락 음성 검사를
  실행한다. 과거 전이 자체 검사는 재실행 가능하나 전체 240주·720 묶음을 반복하지 않는다.
- 독립 검수 뒤에만 이 호환 범위를 닫는다. 314 REWORK/부모302·본편·새 패키지 HOLD와
  인간 OPEN45·옛 공개 GO1을 유지한다. 인간·원어민·물리 패드 판정이 아니다.

이 사양은 일회성 exact 호환 수리이며 기존 증거 보존 규칙을 재정의하지 않는다.

## 2026-09-27 완료 — 작업 한정 GO

- 새 helper와 live 소비자3개에서 두 파일의 parent/commit·경로 모집단·SHA·함수 경계를
  확인한 뒤에만 옛 소스로 역투영한다. 이전310/305/156 핀·모듈·역사 fixture는 보존했다.
- 모듈/실제 live 경계 표적63검사 PASS, 독립 raw/hash 잘못된 결속2건도 거부했다.
  저자의 chapter5/year5 정적 검사와 역사310 106/305 132/기존경계6도 PASS이며 전체720이나
  24/240주 재실행은 하지 않았다. 미래 바이트나 불완전한 Git 증명을 허용하지 않는다.
- 최종 source `d99f2037ecbcb959004b97d380efb3b33314a512`,
  tree `2373139d718d4a6db54a91cc9ce08d9e08aa1bb9`의 정적 호환 한정 GO.
  [독립 보고](../agent_reviews/ORDER-316.json) SHA
  `7083ae080f942e9cb62b9fa809c5465a68a2a3ba4f2b9beb7e132548fc4191dc`.
- 315 화면 GO와 서로 대신하지 않는다. 314/302·본편·패키지 HOLD 및 실제 인간 증거는
  바꾸지 않았다. 규범은 위에 명시한 일회성 전이 검증이다.
