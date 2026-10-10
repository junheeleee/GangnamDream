# ORDER-536 — 본편 결과 완독→자동 주·월 진행의 첫 내부 단면

#### [~] ORDER-536 [P0·본편 연결] W1–W8 결과 닫힘·생계·월말·실제 후속 독자를 잇는다

**착수 — 2026-10-10 / 구현 전 선언.** 534의 정상 입구 REWORK를 고치기 위한
첫 내부 개발 단면이다. 2026-08-24 DECISIONS의 StoryMode 행동 소유·자동 생활과
WORK_UNIT의 현재 개발 판단 위임을 따른다. 공개 데모와 retail 기본 시작은 불변이다.

## 깊이 3문

1. 없으면 작성 장면의 결과 뒤 legacy AP를 다시 요구하며 정상 본편 선행이 끊긴다.
2. W4의 실제 거절/계좌 대여가 W8 clean/fallout과 미래 예약을 갈라 놓는다.
   새 선택·과거 선택 복원·무상 취업·월급·XP·가짜 알바 플레이 영수증은 만들지 않는다.
3. 200만원 즉시 현금과 자기 계좌를 지키는 길이 경쟁한다. 자동 생계는 별도 선택판이 아니다.

## 소유

- root: scenes/MainGame.gd, scenes/StoryMode.gd, scenes/StartMenu.gd의 full 내부
  연결과 결과/큐 닫힘 배선, tools/audit_scope.json 기존 검사 등록 정합,
  이 사양·큐/L3 연속번호·WORK_LOG·CLAUDE 현재행·독립 보고/판정 원장.
- phone_cn_author: systems/FullStoryFlow.gd(+uid) 한 파일의 full 내부 상태·완독·
  자동 생계/회복 once producer. flags의 기존 v4 직렬화만 쓰고 GameState 스키마는 불변.
- cjk_wrap_diagnosis: 기존 tools/ManualSaveCheck.gd의 표적 회귀. 새 runner/성능 작업0.
- phone_independent_review: 비저자 소스/실행 증거 전수 검수. 제품 편집0.
- 원문/번역, story_map commitment/carryover, DemoCoreLoopV2/controller, JobSystem,
  project.godot/BuildFlavor/기존 사용자·공개 저장/인간 판정/finish_run은 비소유.

## 내부 후보 경계·계약 (이번 단위의 일회성 지시)

- 새 full 게임에서만 명시적 `--full-story-flow-preview`와 proven pre-autoload
  고유 QA namespace를 함께 확인해 활성화한다. marker 없는 기존 저장·일반 새 이야기·
  demo/V2는 그대로다. 기본 전환은 M01–M06→M07 실제 독자를 닫은 별도 판정 전까지 금지.
- W1 프롤로그/장 카드는 실제로 읽는다. 실제 root·follow-up은 기존 MainGame/StoryMode가
  소유한다. W4 첫 제안, W8 clean/fallout 시간을 유지한다. 첫 결과 닫힘만으로 후속 큐를
  잘라 달력을 옮기지 않는다. 진입 marker를 완독 영수증으로 쓰지 않는다.
- 정확한 turn/event/index의 이미 적용된 선택 결과를 읽은 뒤 닫힘을 기록한다.
  replay·미완 문단·오염/결손 context는 완료 근거가 아니다. 후속 큐 소진을 별도로 확인한다.
- 자동 생계·회복은 기존 승인 밴드(무직 주 +70,000원/H-1/M+1, 취업 업무성과+1/M+1,
  회복 H+1/M+3)의 값만 재사용한다. V2 plan·primary/secondary·실행기는 호출하지 않는다.
  AP/축/직접 행동·XP·가짜 임금/취업 이력은 만들지 않는다. 실제 JobSystem 월 처리는 유지한다.
- 정확한 주를 once 처리하고 기존 월말 producer의 직업/관계/아이템→최초 지원금→
  월압력/지출→달력 순서를 유지한다. 월초는 535의 once owner를 재사용한다.
  저장 실패는 진행을 멈추고 재시도/재개에서 이중 수입·정산이 없게 한다. 실제 사망은 보존한다.
- 내부 단면은 W8 완료 후 W9 경계에서 멈춘다. AP/계획판으로 낙하하거나 demo recap·
  강제 M07로 우회하지 않는다. 이 개발 checkpoint를 정상 제품 완료로 주장하지 않는다.

## 검증·판정

- 기존 ManualSaveCheck에서 정상 시작 상태·프롤로그/장 카드 순서, 결과 전/후/후속 큐,
  W4 두 갈래·W8 clean/반환/더 깊게, 원효과/미래 예약, 주8/월2 once·실제 월말 비용,
  v4 disk/result cold/새 Main/중복 입력·저장 실패, legacy/demo/V2 제외·W9 AP0을 검증한다.
  합성 fixture는 실제 자연 완독/M07 플레이가 아니다.
- compile·선택 영향 검사·EN/한글·저장 호환·diff/context/queue와 독립 source/raw 검수.
  엔진은 기존 pre-autoload bootstrap·fresh HOME/XDG/namespace와 exact marker,
  stdout/stderr/Godot 오류 scan·보호 hash를 요구한다. 전체 감사/240주/누수 추적0.
- 한정 source GO만 가능하다. 정상 full 입구534·M07·전체 본편/출시·원어민/인간/물리
  패드·실제 연속 청취는 HOLD/미관측이다. 자동 통과는 재미·깊이·문체 증거가 아니다.

## 구현·표적 결과 — 독립 최종 결속 대기

- 실제 Main roots/StoryMode 결과·장 카드·후속 큐, W4 두 갈래와 W8 세 결과,
  주8/월2 once·v4 cold/새 Main·동기 중복·저장 실패/쓰기 재시도·RNG·W9 경계 PASS.
  compile6 69/exit0, whole preview3 0/21.97초, whole legacy2 0/13.56초.
  앞 동치 guard 후보의 demo/V2 focused 각0/활성0은 별도 원실행으로 보존한다.
- 원 `.git/order536-qa-20261010`의 최초 parse/fixture/상태/RNG 실패와 최종3stream을
  보존한다. warning15/13은 의도된 저장 실패/복구이며 fatal/누수0이다.
  EN/한글0·arc/등록 PASS, 선택 정적 종합은 causal self-test timeout으로 미관측이다.
  기존 general finale census 실패는 고치거나 완화하지 않았다. 전체 CI GO가 아니다.
- 537의 명시 시작 방식 수리를 함께 검증했다. 원문/번역/데모/project·사용자 저장·
  과거 인간 판정은 불변이다. 합성 첫8주 한정이며 정상 입구/M07/출시 HOLD다.
  규범 처리: 새 설계 정본 규칙0. 목록 조회의 실행 방지는 개발 skill Verify에
  한 줄 승격했고, 이 단위의 범위/구현/검수 지시는 일회성이다.
