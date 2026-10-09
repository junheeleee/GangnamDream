# ORDER-520 — 저장 재개 수리를 담은 새 로컬 데모 앱

#### [x] ORDER-520 [P0·패키지] 기존 빌더로 fresh resume-fix 후보 발급

**완료 — 2026-10-10 / export 한정 GO.** clean source
`de90d8960857931a2416b51d374317898604aafc`/tree
`ec36369672f65ff6dde281664ed7ae44ca29c085`의 별도 resume-fix 앱이다.
비저자 `phone_independent_review`가 실제 원명령·패키지·fresh 전후 보존을 직접
대조한 뒤 export만 GO했다. 실제 앱/수동 저장/cold resume와 출시 GO는 아니다.

## 실제 산출·독립 검수

- 기존 빌더16명령 전부 exit0/필수 정확 marker1/오류·누수0이다. import/export
  nested-project 무시 경고각1·I18n 의도 거절19는 별도 보존한다. five-locale
  locales5/routes5/months30/weeks120/save5/story10 PASS는 실제 플레이가 아니다.
- BUILD2026.10.10.1/attempt resume-fix, codesign deep/strict PASS/ad-hoc다.
  공증·외부 배포는 하지 않았다. manifest171630B/SHA
  `b81931ac036f712277a278936326687a87ca1f0f05a93a458e6d0f01d914bbba`.
  추적 사본 [ORDER-520-manifest.json](../agent_reviews/ORDER-520-manifest.json)은 byte-exact다.
  ZIP428078088B/SHA`d78d2455f04c5b201e3c7ded30a7eac21f211f1bf30b3171ed6cf0d88323b8ae`,
  PCK389860008B/SHA`594edf4a38e26101bf138fa89e5aeca172abebcc90b401e12032a0a2ede90a7f`.
  app7/PCK1877/JSON675·ZIP↔app·stage/source/허용4변환이 일치한다.
- 원출력 `build/story_demo_successor/2026.10.10.1/resume-fix/` result는
  all_pass=true/preservation_errors[]다. root와 비저자가 별도로 기존 package auditor의
  exact PACKAGE_OK/exit0/runtime NOT_RUN을 확인했다. staged StoryMode의 exact
  controller predicate1·Git bytes 동일이며 retouch0이다.
- `.git/order520-export-20261010/before.json`=after는 전체662703B/
  SHA`5f225727ca0a3090947f8d124ee66da73eacaa4e20454f366029463e4401f240`다.
  root/비저자 fresh 전수대조로 tracked3256/helper5/seed2/W238/player33·보호25곳
  불변이다. oldthird/timer-fix 앱·ZIP·manifest·저장/516원실패/519raw를 보존했다.
- 새 namespace 파일0·empty objectdb_snapshots만 있으며 candidate PID0/editor61385
  생존이다. 기존 user project manager CUA는 Mac locked를 반환했다. 새 앱은 실행0/
  실제 입력0이다. [516](../queue_active/ORDER-516.md)에 새 exact 대상으로 준비를
  선언하되 해제 후 실제 UI 저장·cold resume 전까지 HOLD다. 원manifest의 NOT_RUN와
  user GO NOT_INHERITED를 바꾸지 않는다. 마지막 fresh 대조 후 source 동결을 해제했다.

**착수 — 2026-10-10.** [519](../queue_archive/ORDER-519.md)의 source GO를 실제
앱으로 옮긴다. timer-fix의 실제 cold resume REWORK와 모든 원증거는 보존한다.

**발급 준비:** 두 기존 도구의 unit literal6곳만 정렬했다. 기존 synthetic
self-test52 PASS/actual_exports0이며 BUILD/date/player33/변환/검증 로직 diff0이다.

## 한 단위·깊이 3문

1. 없으면 수리된 실제 앱이 없어 수동 저장/재시작 위치를 재검수할 수 없다.
2. 선택/경제/저장 형식은 그대로며 새 앱·빈 namespace에 동일 source를 담는다.
3. 기존 실패 앱 덮기 대신 fresh identity를 쓴다. 새 검수 도구/비용 계측은 하지 않는다.

## 파일·소유

- root: 기존 `tools/build_story_demo_successor_macos.py`·
  `tools/story_demo_successor_package_audit.py`의 발급 unit literal518→520 여섯 곳만.
  BUILD2026.10.10.1/date/player33/변환/검사 로직은 그대로다.
- root 운영: 이 사양·516/302 후속·큐·CLAUDE/WORK_LOG·생성STATUS·위임원장.
  기존 build/app/ZIP/manifest 및 byte-exact 추적 manifest 증거 형식을 재사용한다.
  private `.git/order520-export-20261010/`에 원명령/전후 보존을 남긴다. 새 보고0.
- 비저자 `phone_independent_review`: literal diff/실물/원명령/보존 읽기 전용 검수.
- 게임 코드/원고/번역·project/preset·저장/human·공개/third/timer-fix 후보·
  모든 옛 manifest/raw/helper/seed/W238/player33은 불변이다.

## 실행·검증

1. 선언 push 뒤 unit literal만 정렬하고 기존 synthetic self-test52를 확인한다.
2. clean source를 커밋/push한 뒤 BUILD2026.10.10.1/attempt `resume-fix`를 발급한다.
   기존 빌더16명령·정확 marker·stdout/stderr/Godot 오류·서명·ZIP/PCK audit를 쓴다.
3. 기존 보호24곳과 519 원증거를 입구/최종 fresh 전수대조한다. 원seed2/W238을
   --protect로 넣으며 source/docs/helper는 실행부터 독립 최종대조까지 동결한다.
4. export 한정 판정은 runtime NOT_RUN/user GO NOT_INHERITED다. 실제 무인자
   부팅/수동 저장/cold resume는 516의 새 exact 대상으로 선선언한 뒤 이어간다.

자동 PASS는 실제 화면·재개/인간/원어민/물리패드/청취·본편/출시 GO가 아니다.
수리 후보 발급은 일회성·정본 승격0이다.
