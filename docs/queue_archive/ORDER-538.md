# ORDER-538 — 본편 세 번째 달의 격리 연결

#### [x] ORDER-538 [P0·본편 연결] W9–W12 실제 후속·월말·저장 실패 경계

**착수 — 2026-10-10 / 구현 전 선언.** 534 정상 입구 REWORK의 후속이며
536의 첫8주 source GO를 기본 본편이나 M07 GO로 확대하지 않는다.
DECISIONS 2026-08-24의 장면 행동 소유·자동 생활과 WORK_UNIT의 위임을 따른다.

## 깊이 3문

1. 없으면 내부 첫8주 뒤 현수와 실제 후속·세 번째 월말·저장 재시도가 끊긴다.
2. 실제 W4/W8 선택과 W9 현수의 말이 원효과·관계·W24 예약으로 남는다.
   주급·취업·지원 이력·새 영수증을 발명해 다음 달을 통과시키지 않는다.
3. 현수에게 현재를 말하거나 꿈을 말하는 선택, 원래 사건 우선순위가 같은 시간을
   경쟁한다. 고시원·구직·잔액 장면을 모두 한 주에 밀어 넣지 않는다.

## 소유

- root: scenes/MainGame.gd의 profile별 저장 재시도·pending 직접활동 비소모 차단·
  새12주 profile의 demo bridge 제외, tools/audit_scope.json 기존 검사 등록 정합
  (필요할 때만), 이 사양·큐/L3연속번호·WORK_LOG·CLAUDE 현재행·비저자 보고/판정 원장.
- phone_cn_author: systems/FullStoryFlow.gd만. 기존8주 profile 불변·새 명시12주
  profile·정확한 W9 후속 완독·profile별 범위·활동 pending 진행 차단.
- cjk_wrap_diagnosis: tools/ManualSaveCheck.gd만. 기존8주 회귀 보존·새12주 실제 호출,
  W9 cold/월초 once·현수2택·후속 미완 차단·W9/12 쓰기 실패와 W13 경계.
- phone_independent_review: 비저자 source/raw 전수·보호 fresh·한정 최종 판정.
- 원문/번역·GameState/SaveManager·StoryMode/StartMenu·demo/V2·JobSystem·밸런스·
  project.godot·공개/사용자 저장·인간 원장·finish_run은 비소유다.

## 이번 단위 계약 — 일회성

- 기존 `--full-story-flow-preview`와 기존 저장 profile은 W8 완료/W9 경계를 유지한다.
  fresh full+검증된 pre-autoload 격리에서 companion
  `--full-story-flow-third-month-preview`까지 명시했을 때만 새12주 profile을 만든다.
  옛8주 저장의 자동 승격·normal/demo/V2 활성화0, 손상 profile은 fail-closed다.
- 실제 MainGame root와 StoryMode 후속을 그대로 쓴다. W9 현수 두 선택 모두의
  `arc_chapter1_close`를 실제 완독해야 주가 닫힌다. 진입/선택 적용만으로 닫지 않는다.
  새12주 profile에서는 demo narrative bridge가 이 본편 장면을 무언 적용하지 않는다.
- 원래 한 주 한 독립 root·우선순위·조건·선택·효과·예약·주/월 정산 owner를 보존한다.
  기존 승인 자동 생계/회복만 재사용하고 체납·압력·사망을 그대로 둔다.
- pending 경마 직접활동은 계약 미구현 경계다. flag/선택/결과를 지우거나 완료로
  위장하지 않고 continue/새 Main/중복 advance에서 계속 막는다. 활동 연결은 별도다.
- profile별 최종 turn을 저장 실패 재시도 검증도 읽는다. 계산된 상태를 유지한 채
  실패 동안 진행을 막고 쓰기만 재시도한다. 마지막12주 정산 뒤 W13에서 개발 경계로
  멈추며 AP/계획판·demo회고·강제M07로 낙하하지 않는다.
- 구직 불합격의 미생산 지원 이력·구제직 원고의 선행사실은 확인된 별도 원고 결함이다.
  이번 연결 source GO를 그 문장의 사실/작품 품질 GO로 올리지 않는다.

## 검증·판정

- 기존8주 fixture 그대로 + 새12주 fresh actual-call 3경로·W9현수2택/후속·실제 월말3회,
  W9 checkpoint disk cold/월3 once·주9→10/주12→13 실패·disk보존/새Main/RNG/retry,
  W13 cold 경계·구profile 비승격·unknownprofile·pending 활동 비소모 차단.
- 동일 process의 actual v4 cold는 별도 무인자 process 재개나 native 자연완독이 아니다.
  컴파일/표적 저장·영향 정적·EN/한글·arc·context/queue/diff와 비저자 전수검수.
  엔진은 기존 bootstrap/fresh HOME/XDG/namespace·marker·3stream 오류 scan을 쓴다.
- 원 실패 보존, 새 실패0 전 마감0. 전체 감사/240주/누수 추적/비용·성능 도구 작업0.
  원격 전체 CI·기본 full 활성화·534/M07·W13이후·원어민/인간/물리/청취·출시 HOLD다.
  자동 통과는 도달/계약 증거이며 재미·깊이·문체 증거가 아니다. 새 설계 정본 규칙0.

## 구현·표적 결과 — 비저자 최종 대기

- 기존8주 profile/상한/schema1은 보존하고 fresh companion만12주를 선택한다.
  W9 현수 두 선택→장 닫힘 후속을 실제 reader 호출로 읽고 W10 불합격·W11 잔액·
  W12 고시원 원래 우선순위와 세 번째 정산 뒤 W13 경계를 확인했다.
- compile69, focused12주·whole12주·whole8주·companion-only legacy·새 companion의
  demo/V2 제외가 각각 exit0/marker·3stream scan PASS다. whole12주는26.30초,
  whole8주21.55초, legacy13.66초이며 기존10슬롯·시작방식·월초 once marker도 유지한다.
  의도된 저장 실패/복구 WARNING는 focused4·whole12주17·whole8주15·legacy13이다.
  fatal/parse/누수0이며 WARNING를 숨기거나0으로 기록하지 않는다.
- W9/12 쓰기 실패의 이전 disk·계산 메모리·새 Main·RNG·쓰기만 retry,
  실제 W9 v4 cold/월3 once·W13 cold·구8 shape 비승격·unknown profile 거부 PASS다.
  pending 경마는 직접 bool flag를 세운 합성 저장/cold/새 Main2회 표본이다.
  실제 경마 선택·방문이나 별도 무인자 process 재개로 확대하지 않는다.
- 새12주 자신의 W1–W8 receipt prefix가 후속 진행에서 불변임을 검사했다.
  옛8주와 모든 root가 같다는 증거가 아니며 옛 profile은 별도 base-only whole run이 소유한다.
- 원 `.git/order538-qa-20261010`에 argv/env/exit/시간·3stream·source4pin을 보존한다.
  비저자 최종 clean source 결속과 보호 fresh 뒤에만 마감한다. 원고/번역·기본 활성화·
  실제 앱 M07·W13 이후·전체CI·본편출시는 HOLD다. 새 정본 규칙/도구 최적화0이다.
- 영향 정적56개 제품55 PASS/기존 census1 FAIL/새 실패0. census 원문은536과 바이트
  동일하다. 성공한 demo 검사 데이터의 `hyunsu_result_fail`을 실행 보조기 regex가
  오류로 잡은 원 FAIL은 남기고 exit0/실제 success marker를 별도 판독했다.
  제품 검사·예외·도구 변경0, causal self-test timeout 재실행0·전체 CI GO0이다.

## 최종 결속·마감 — 격리 source 한정 GO

- [비저자 보고](../agent_reviews/ORDER-538.json) 10091B,
  SHA256 `adf3f662e7abf324708c9fc1813bf8b9eec4a02cbc9c4eb0d805ef4a2db92c42`.
  clean source `b3d725189a5835a8f6a8c2de93b58193478428dd`, tree
  `46ddd479eae4c9cb8d4d2cca57329a09ff2f7e5b`, manifest=null의 한정 GO다.
- 비저자 fresh 보호23그룹968파일/helper5/seed2/W238/player33·과거276판정·
  실행4제품 pin=현재Git blob exact. 최종7회21stream·정적56회112stream 원SHA 대조,
  사후 receipt59310B/223df900…에 결속했다. 원 실패/오탐·WARNING·미관측은 보존한다.
- 규범 판정: 새 설계 정본 규칙0, 이번 범위·구현·검수 지시는 일회성이다.
  구8주 비승격·원문/번역/기본/demo/V2/project·사용자/공개 저장·인간 판정은 불변이다.
  정상 입구534 REWORK·M07·W13 이후·원고 사실/작품성·실제 경마·인간/원어민/물리·
  연속 청취·전체CI·본편/외부출시는 HOLD다. 한정 GO는 그 권한을 넓히지 않는다.
