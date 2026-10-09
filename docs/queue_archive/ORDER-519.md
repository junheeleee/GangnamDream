# ORDER-519 — successor 장면의 데모 신원 연결 수리

#### [x] ORDER-519 [P0·저장 재개] StoryMode와 controller의 exact namespace 일치

**착수 — 2026-10-10.** 516 retry1 실제 UI에서 저장한 결과 대신 첫 본문으로
돌아가는 결함만 수리한다. 제품이 이미 제공하는 데모 수동 저장/이어하기의 연결
복구이며 새 저장 시스템·스키마·임의 namespace 허용이 아니다.

## 구현·표적 결과 — source 한정 GO

**완료 — 2026-10-10.** 비저자 `phone_independent_review`가 clean 최종 제품
`cffd9d0e86e7d861be68a4f0962ce58f3e4aa38c`/tree
`8fb35c04292395bbaeb8226ced125567088411da`의 endpoint와 원증거를 직접 대조했다.
StoryMode blob22652a72…·fixture blobf3f53de1…는 검수했던 바이트와 exact다.
보호24곳 fresh 동일·이름표 실제 긴 marker/원로그 일치도 확인했다. 결함/retouch0,
source만 GO다. 새 package·실제 cold resume는 [516](../queue_active/ORDER-516.md)의
후속 [520](../queue_active/ORDER-520.md) 발급 뒤 검수하며 현재 HOLD다.

- 제품 변경은 exact 비교1줄뿐이다. 이미 preload한 controller의 상수를 소비하며
  기존 source의 v1·승인 QA 조건은 그대로다. fixture +35줄은 동적 exact/유사/비활성
  세 표본을 off-tree에서 대조하고 원 설정을 복원한다.
- private `.git/order519-identity-20261010/` clean eebf3cd archive를 기존 builder
  변환4개로 staged successor identity-contract에 맞췄다. 수정 전 exit1/8.047973초는
  exact namespace mismatch1건이다. 수정 후 같은 stage의 제품1줄만 바꿔 exit0/
  8.551746초·stdout/Godot4793B/SHA571db561…·stderr/오류/경고/누수0·정확 marker1이다.
  기존 locales5/routes5/months30/weeks120/save5/story10도 유지한다. 실제 앱 관측은 아니다.
- 기존 Compile68/Font PASS·I18n exit0/정확 marker1/오류0/의도 거절 warning19다.
  이름표24case 실제 engine/runner는 exit0/59.249979초·정확 원 marker1/오류0이다.
  root wrapper가 잘못 적은 이름표 marker의 ValueError는 보존하고 원로그 직접대조
  영수증으로 구분했다. 재실행0이다. EN coverage/Hangul/demo 현지화 normal PASS.
- 영향 선택기는 등록 검사16개 중 Python 검사와 원장/context/queue를 통과했으나
  중간 STATUS stale이 남았고 Godot 없는 PATH의 engine skip은 통과로 세지 않는다.
  위 별도 격리 engine으로 필요한 runtime을 확인했고 마감 때 STATUS를 재생성한다.
- 수정 전 전체 보존 SHA8b6ba9f7…654255B, 수정 후/마지막 전체 보존
  SHAfda30fc4…654301B 동일: tracked3255/helper5/seed2/W238/player33·보호24곳.
  비저자는 stage 전량 baseline/허용 변환·동일 수리1줄/원로그/보존을 직접 대조해
  수리 한정 GO했다. 위 clean 최종 제품 commit 대조로 이 단위만 닫는다.

## 한 단위·깊이 3문

1. 없으면 저장 토스트 뒤 재시작해도 그 선택/문단이 이어하기에 반영되지 않는다.
2. 선택/24주 수치를 바꾸지 않고 이미 선택한 상태와 문단을 동일하게 복원한다.
3. 넓은 namespace 접두사 허용·빌더 추가 변환과 경쟁한다. 이미 preload한 controller의
   exact PUBLIC_CUSTOM_USER_DIR 상수를 소비해 생산자와 판정의 분기를 없앤다.

## 파일·소유

- root 제품: `scenes/StoryMode.gd`의 `_is_public_story_demo()` exact 이름1곳.
- root 기존 fixture: `tools/StoryDemoFourLanguageCheck.gd`의 exact controller namespace,
  유사 이름 거부·custom-dir 비활성 거부 표본. 기존 QA 허용/5언어·저장 검사는 유지한다.
- root 운영: 이 사양·516 실패·302 잔여·CODEX_QUEUE/L3 순번·CLAUDE 현재행·WORK_LOG·
  생성 STATUS·위임판정원장. private `.git/order519-*` 원로그/보존만 생성한다.
- 비저자 `phone_independent_review`: 원코드·반례/결과·보존·최종 commit 읽기 전용 검수.
- 원문/번역·수치/flags·저장 구조·project/export 설정·builder/auditor·공개/third/timer-fix
  앱/ZIP/manifest·모든 기존 저장/raw/helper·과거 인간 판정은 불변이다.

## 실행·검증

1. public 고정 문자열 대신 기존 STORY_DEMO_CONTROLLER.PUBLIC_CUSTOM_USER_DIR를
   비교한다. public/QA 판정의 다른 조건은 그대로다. 전역 접두사 허용은 하지 않는다.
2. 기존 fixture에서 이름을 시험하는 동안 user data 경로는 pre-autoload 격리 공간에
   고정하며 파일 쓰기 없이 ProjectSettings를 복원한다. controller와 StoryMode의
   exact/유사/비활성 판정을 대조한다. 수정 전 실패와 수정 후 성공을 모두 보존한다.
3. 기존 격리 builder/run_command로 fixture·compile·관련 영향 검사를 수행하고 정확
   marker와 stdout/stderr/Godot 오류를 직접 읽는다. 새 checker/runner/보고0·전체 audit0.
4. source 한정 독립 판정만 닫는다. 기존 timer-fix 실패는 보존하며 새 package 발급과
   실제 무인자 저장/cold resume는 별도 후속으로 선언한다. 현 앱을 고치거나 덮지 않는다.

제품 신원 소비 계약 복구·일회성 작업이며 새 정본 규칙 승격0이다.
자동 PASS는 실제 화면/인간/원어민/패드·전체제품/출시 GO가 아니다.
