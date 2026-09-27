# Active Queue Spec: ORDER-314

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-314 수리된 데모 KO/EN 실제 화면·입력 표적 검수

2026-09-27 착수. 사용자 개발·내부 검수 위임과 부모302의 잔여 화면 검수에 따른다.
기준 clean main `149f339747805940868dcbfe758d5a83dfe81a31`.

## 깊이 3문과 범위

- 없으면: 문자열 수리의 실제 표시·선택 결과 소비자가 미관측이다.
- 상태 차이: 새 게임 규칙을 만들지 않는다. 선택 전후 실제 이력·결과를 대조한다.
- 경쟁: 전체 회귀 반복 대신 시작 안내/M04 월세/M06 회상·무명 직원 소비자를 우선한다.
- 한 배치: KO/EN 각 home, M04 월세 본문/선택/결과, M06 회상/선택/결과/recap의
  8표면(총16 목표), 1280×800 실제 렌더와 엔진에 dispatch한 합성 키 press/release.
  필요한 본문 pagination 중간 캡처는 추가 증거이며 별도 완성 단위로 세지 않는다.
  이번은 OS 물리 키보드/패드, 인간 독해, 원어민 판정이 아니다.
- 월 진입은 기존 공개 controller의 QA fixture로 이전 선택·정산을 준비하고,
  관측할 StoryMode 본문·선택·결과 이동은 입력 dispatch로 한다. fixture 도약은
  사용자 처음부터 끝까지 입력 완주로 세지 않는다. M04 coffee 분기는 별도 미관측이다.

## 파일 소유와 검증

- root: 이 사양·큐2개·부모302 진행 꼬리·CLAUDE 현재행·WORK_LOG·생성STATUS;
  `.git/full-game-localization/order314-*` 중 launcher/사용자보존 census/raw 증거.
- `/root/screen_path_probe`: private `order314-screen.gd`, `order314-screen.tscn`,
  `order314-bootstrap.gd`만. 기존 런타임을 instantiate하며 제품 파일 변경 금지.
- 독립 검수자: private review 및 `docs/agent_reviews/ORDER-314.json`만.
  저자와 다른 에이전트가 모든 실제 PNG·입력 로그·source pin·원문을 검토한다.
- 제품 코드/원고/번역/게임효과/공개 package/과거 수용·인간·판정 원장은 무수정.
  결함 발견 시 이번 검수 결과를 보존하고 수리는 새 파일 범위로 별도 선언한다.
- pre-autoload fresh RuntimeQA32hex namespace, HOME 유지, 사용자 저장/설정 전후
  census/hash 동일, source/helper SHA·commit/tree 전후 동일, timeout과 프로세스 정리.
- 각 실행 exit0, exact marker, stdout/stderr/Godot 로그 오류0, 실제 PNG 크기 확인.
  raw 로그와 실패 증거를 지우지 않는다. 기존 5언어 headless/720검사 재실행 없음.
- 완료 시 context/queue/diff/생성STATUS 표적검사. 위임 작업한정 판정만 별도 기록하며
  제품·패키지 GO는 발급하지 않는다. 전체302·본편 HOLD, 인간OPEN45·공개GO1 보존.
- 이 사양은 일회성 검수 지시다. 입력·안전영역 정본은 INPUT_MATRIX와
  CONTROLLER_UX_STRATEGY를 따르며 새 규범을 만들지 않는다.
