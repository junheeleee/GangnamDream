# ORDER-433 — 수용 이력 검증에서 버리는 JSON 위치 분석을 없앤다

#### [~] ORDER-433 [P2·검수 효율] 값 파싱 2곳의 불필요한 span 생성 제거

**[~] 착수 — 2026-10-04.** 사용자의 효율적 검수·속도 향상 위임.
실측 432 normal이 소유하는 현재 소스 검증 결과와 별도로, 반복되는 JSON 분석의
구조적 중복만 줄인다. 시간 개선은 전후 측정 전에는 수치로 약속하지 않는다.

## 범위와 소유

- root: `tools/ui_translation_append.py`의 validate_append에서 old/new 값만 읽는
  두 `_Document(raw).value` 호출을 동일 strict `_loads(raw)`로 교체.
  raw inverse의 _Document/전체바이트 역상·Git/HEAD·collector·source/receipt 검증은 유지.
- receipt_tests392: 새 `tools/ui_append_value_parse_check.py`만 저작. 원도구 수정·검사 실행0.
- claude_handoff_review: 새 private433 normal runner와 `tools/audit_scope.json`의
  `ui-append-value-parse` 명시 차선만. 엔진/검사 실행은 root만 한다.
- independent392: 비저자 경계·전후 동일 결과·실제 normal 최종 검수.
- 원래 도구 본문에서 위 두 식 이외 변경0. 원문·번역·UI·ledger·helper·역사판정 변경0.
- 기록은 CLAUDE, 큐/L3, active/archive433, WORK_LOG, 생성STATUS, agent 보고/판정.
- 이 중복을 없애도 플레이 결과는 동일하다. 삭제하면 비용만 되돌아오며 새 선택/24주
  상태·경쟁 없음. 읽기만 하는 검증의 같은 JSON 파싱과 exact 역상을 유지하는 성능 수리다.

## 검수

- 같은 strict parser가 쓰이는지 함수 identity와 malformed JSON 거부를 확인한다.
- 유효/잘못된 append fixture에서 원함수와 새함수의 반환/예외 의미 비교.
  UI/receipt/header 순서·값·원문 공백·고아/중복 및 추가범위 훼손을 계속 거부해야 한다.
- spy로 값 파싱 단계 span 생성0, 실제 역상 단계는 원래대로 호출되는지 확인한다.
  정상4파일 비교의 전체 _Document 생성16→8, 실제 역상용8→8은 구조적 수치이며
  실행시간50% 주장이 아니다.
- 각 정상검증의 실제 source/HEAD/current reads와 기존 역사 결과는 그대로.
  432 normal 원본 row01을 변경 전 A로 재사용하고,433 normal의 동일CLI 행1회를
  변경 후 B로 관측한다. stdout exact동일·exit0/stderr0를 요구하며 source후보차이는
  그대로 명시한다. 원문/번역/원장 불변과 도구 exact2식 역상을 별도로 확인한다.
  같은3workers라도 OS캐시·순서·경쟁작업/외부부하가 다르므로 시간은 단1쌍 관측치이고
  파서 변경만의 인과나 속도보장으로 쓰지 않는다. A/세번째 receipt 재실행0.
- 새focused·공통normal13검증+명시조회1 각1회. 과거focused432의 본문/pin은
  보존하며 새두식수리 후보에서 역사prefix 검사를 무관하게 재실행하지 않는다.
  새 집중검사와 영향 normal은 audit_select에 등록한 표적 경로로만 실행한다.
- 순수fixture의 반환/예외를 대조하되, 복합 오류·극단 깊이에서 최초 진단의 순서/시점까지
  모든 입력에 동일하다는 주장은 하지 않는다. 성공 admission에는 원래 raw span 검사가 남는다.
- 게임 코드/런타임 불변이므로 이미 통과한8PNG/입력 및 전체감사/240주 반복0.
  기존431 FAIL/432 성공과 인간/원어민/물리 관측 경계를 보존한다.

일회성 검수 효율 수리. 실제 검증 비용을 줄일 뿐 통과 기준을 낮추지 않는다.
