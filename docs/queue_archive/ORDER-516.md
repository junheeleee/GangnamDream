# ORDER-516 — 수정된 데모 앱의 실제 저장과 재시작

#### [x] ORDER-516 [P0·패키지 QA] successor 실제 무인자 부팅 → 새 저장 → cold resume

**완료 — 2026-10-10. 실제 부팅·새 UI 저장·동일 문단/선택/수치의 cold resume만 GO.**
결과 화면 이름표 차이는 REWORK로 [521](../queue_active/ORDER-521.md)에 분리한다.
전체 화면 동등성·나머지 runtime·출시 GO가 아니며 아래 모든 옛 실패를 보존한다.

## resume-fix 실제 관측 결과와 독립 판정

- exact520 source de90d896/treeec363696·원manifest b81931ac… 앱의 무인자
  own15353은 KO gate/home→M01 자동 전환→본문→차단0→완문 result0/정신64/
  건강70/230만원을 관측했다. 본문0은 타이핑 중 부분관찰, 1~4는 완문관찰이다.
  AUTO/일괄 입력/상태 주입0이며 설정→빈slot1 UI Save의 성공 토스트/메타데이터와
  닫기 뒤 같은 result0을 확인했다. CmdQ exit0/247.791371초다.
- 첫 PID/parent 부재 뒤 명시적 새 own15631 무인자→KOhome Continue는 같은 완문
  result0·선택0·정신64/건강70/230만원을 복원했다. 이후 게임 진행 입력0,
  CmdQ exit0/33.34691초다. 두 실행 stdout/Godot 각474B/SHA dafec273…,
  정확 native entry각1·stderr/engine 오류/경고/누수0이다.
- slot1 qa_fixture=false·19429B/SHA076ea46342e1ef5fa7637a06de501ed6e7c86e066861dd95715521d11c677701은
  두 실행 뒤 byte-exact다. story/result/arc_temptation_01/choice0/paragraph0/KO·
  완문·dialogue7·controller_session·story_resume_slot1과 상태가 일치한다.
  슬롯 신원은 기존 SaveManager full/2026.08.24.5/legacy이며 앱 신원이 아니다.
  controller8094→8126B는 숫자16곳 n→n.0 직렬화뿐으로 JSON값 전체 동일이다.
  byte-equal을 요구한 root 중간 assertion 실패는 엔진 실패와 구분한다.
- private `.git/order516-live-20261010-resume-fix/`: before666348B/de5cee1f…→
  between667564B/87b9e5ba…→after667776B/4c7bfff3…,
  observation2274B/SHA7cc41ab8bd4dd2f717bdf9cb2eaacc954464916545980dd41961818ed7983d07,
  각 command/원로그/slot/controller bytecopy를 보존한다. 원manifest NOT_RUN은 불변이다.
- root/비저자 각 fresh 전체 대조: source cf662ff5/tree18d09c·tracked3257/helper5/
  seed2/W238/player33 exact, 보호30 중 새namespace만 파일0→7이다. 다른29곳의
  public9/옛 실패raw/앱7/ZIP/manifest/520raw는 모두 불변이다. own4PID부재·
  사용자 editor61385생존 직접 확인 뒤 동결을 해제했다.
- 비저자 `/root/phone_independent_review`는 코드/원명령/로그/저장/보존을 직접 읽고
  위 세 관찰 항목만 GO했다. 실제 pixels는 root 관찰이고 인간 관찰로 세지 않는다.
  저장 전 있던 김민준 이름표가 재개 후 없는 차이를 두 화면에서 확인했다.
  새노드 기본 choice-dock cache=false가 현재 표시 상태를 덮는 소스 경로와 일치하며
  결과 화면 동등성은 REWORK다. 521에서 별도 source 수리, 새앱 실제 확인은 후속이다.
  5언어/옛 공개저장 복사 호환/복귀 입력/전체24주·본편/출시는 계속 HOLD다.

규범 판정: 실행·보존·증거 결속은 일회성, 새 정본 승격0이다. 기계 PASS는
재미·깊이·문체나 인간/원어민/물리패드/연속청취의 증거가 아니다.

## 2026-10-10 resume-fix 실제 검수 준비

[519](../queue_archive/ORDER-519.md)의 exact 신원 연결 수리와
[520](../queue_archive/ORDER-520.md)의 새 export는 각각 source/export만 GO다.
기존 user project manager CUA에서 Mac locked를 확인했으므로 이번 새 앱 실행0/
게임입력0/저장0이다. timer-fix의 실제 REWORK를 성공으로 바꾸지 않는다.

- source `de90d8960857931a2416b51d374317898604aafc`/tree
  `ec36369672f65ff6dde281664ed7ae44ca29c085`, BUILD2026.10.10.1/attempt resume-fix.
  원manifest171630B/SHA`b81931ac036f712277a278936326687a87ca1f0f05a93a458e6d0f01d914bbba`.
- 앱은 Application Support/GangnamDream_LocalCandidates/2026.10.10.1/resume-fix/
  GangnamDream-StoryDemo-Successor-2026.10.10.1-resume-fix.app이며 bundle
  `dev.junheelee.gangnamdream.storydemo.successor.resume-fix`다. 새 저장 공간
  `GangnamDream_StoryDemo_Successor_2026_10_10_1_resume-fix` 파일0을 확인했다.
- 해제 확인 뒤 private `.git/order516-live-20261010-resume-fix/`에 fresh 입구를
  봉인한다. 520의 보호25곳+새app/ZIP/manifest/namespace/520raw를 모두 보호한다.
  실제 실행~마지막 fresh 대조 동안 source/docs/helper를 동결한다.
- 정확 executable 무인자→KO 첫 본문/선택/결과 독해→UI 수동 slot1 저장→정상 Quit→
  프로세스 부재→별도 실행 Continue→동일 result 문단/상태 복원을 관측한다.
  Quit 뒤 bound AX를 조회하지 않는다. 실제 UI 관찰만으로 판정하고 fixture/자동저장/
  package GO를 대체 증거로 세지 않는다. 그 외 runtime/출시 HOLD다.

**첫 시도 HOLD — 2026-10-10 실제 첫 실행 SIGSEGV.** PID64603·35.95785초·exit−11.
언어 gate→KO home→처음부터→M01 안내를 실제 개별 클릭2회로 관측한 뒤
자동 전환에서 종료됐다. 첫 StoryMode 본문/선택·수동 저장·정상 Quit·cold resume는0이다.
원로그는 발행 중 Object 해제를 기록하며 controller의 동기 timeout 콜백2412가
자기 Timer를 즉시 free한다. [517](../queue_archive/ORDER-517.md)에서 수명만 별도 수리했다.
새 후보는 [518](../queue_archive/ORDER-518.md)에서 발급했으며 기존 third를 덮거나 재판정하지 않는다.

## 2026-10-10 새 timer-fix 후보 실제 검수 선선언

### 해제 뒤 retry1 착수

**retry1 결과 — 2026-10-10.** 같은 timer-fix 무인자 PID94266은 KO gate/home→
M01 자동 전환→본문5문단→차단 선택0→결과0/정신64→UI slot1 저장을 관측했다.
저장 성공 토스트·쉬운 돈 메타데이터와 실제 qa_fixture=false 슬롯11502B/SHA88364ae5…가
일치한다. CmdQ 정상 exit0/139.213959초·stdout/Godot472B·stderr0·entry marker1이다.
종료 직후 bound AX 조회가 PID94487/PPID1로 앱을 암묵 재실행했다. 게임 입력0으로
다시 CmdQ 종료·프로세스 부재를 확인했으며 controlled cold resume 증거로 세지 않는다.

별도 명시 실행 PID94573의 실제 이어하기는 저장한 result0/정신64가 아니라 M01
첫 prose/정신72로 돌아갔다. CmdQ exit0/44.018858초·각472B·stderr0·marker1이며
엔진 오류/경고/누수0이다. slot1은 끝까지 원바이트 그대로다. slot 신원은 기존
SaveManager의 full/2026.08.24.5/legacy이며 timer-fix package 신원이라고 쓰지 않는다.
StoryMode의 고정 public namespace 판정이 successor를 거부해 controller session과
story_resume_slot이 빠진 원인과 일치한다. [519](../queue_archive/ORDER-519.md)의
연결부 source 수리는 GO이며 [520](../queue_archive/ORDER-520.md)의 새 앱을 발급했다.

private retry1 before648687B/SHA7c5bdd75…→between650044B/043e4668…→
after650244B/019e6e71…·observation2661B/b12af6ed…·두 command/원로그/저장 bytecopy를
보존한다. root/비저자 fresh 전체 대조로 source e293263/tree8eafced·tracked3254/
helper5/seed2/W238/player33·보호19곳·app7/ZIP/manifest exact, 후보 공간9파일만
변경이다. 세 후보 PID부재/editor61385생존 확인 후 동결을 해제했다. 실제 화면은 root
관찰이며 비저자는 원로그/저장/코드/보존을 직접 대조했다. cold resume/출시 GO는 없다.

기존 실행 중 Godot project manager의 정확 경로에서 CUA AX 화면 접근이 다시
정상 반환됐다. 같은 b705bcf8/BUILD2026.10.10.1/timer-fix 앱·저장 공간에서
새 `.git/order516-live-20261010-timer-fix-retry1/` 로그로 첫3항목만 잇는다.
잠금 시도의 빈 Godot로그는 원raw 폴더의 `first.godot.log`로 byte-copy한 뒤
전체 원raw를 입구에 보호한다. 현재 후보 공간의 빈 로그1파일은 삭제/복구하지 않는다.
기존 앱은 실행 중이 아니며 새 실물/전후 보존선 확인 뒤 root만 무인자로 시작한다.
같은 QA 단위의 이어보기이며 새 게임/도구/검사·공개본 교체0이다.

**실제 시도 HOLD.** 무인자 ownPID86257/parent86256 실행 뒤 첫 CUA가 Mac locked/
automatic unlock failed를 반환했다. 화면/게임 입력/새 설정/저장/cold resume0,
native entry marker도0이므로 실제 부팅 GO가 아니다. 정확 executable을 ps로
확인한 뒤 ownPID에만 SIGTERM을 보내 exit−15/23.945928초로 종료했다. 정상 Quit도
Timer 수리 재실패도 아니다. 재시도는 잠금 해제 확인 뒤 새 로그 경로에서 수행한다.

- private 원증거 before646952B/SHA777b4644…→after647135B/SHA35525135…,
  first-command1349B/SHAd3b8bd43…·observation427B/SHAb6706ac1…를 보존한다.
  stdout/stderr/Godot 전부0B다. wrapper의 nonzero exit ValueError는 PASS로 숨기지 않는다.
- root와 비저자 fresh 전수대조로 source af2d1b3/tree9a4d1f·tracked3254/helper5/
  seed2/W238/player33·보호18·새app7/ZIP/원manifest exact다. namespace만 새 빈
  logs/godot.log1파일이며 저장/설정0. oldthird/원516실패raw/518export raw도 불변이다.
  own두PID 부재·사용자editor61385 생존을 직접 확인했다. 동결은 이 대조 후 해제했다.

518의 export 한정 GO 뒤 아래 새 후보에서 같은 첫3항목만 다시 관측한다.
기존 third 실패/namespace/로그를 그대로 보호하고, 아래 입구~최종 fresh 대조 동안
source/문서/helper는 다시 동결한다. 기존 실제 third 실행을 성공으로 바꾸지 않는다.

- 새 source `b705bcf8cad30f7fb39f590beb8670f77043c401`/tree
  `18542e4c54f6137beaa091c616c629fd7f021324`, BUILD2026.10.10.1/attempt timer-fix.
  518 manifest171548B/SHA`892c0be35aaf6fa33b10114a0973473f5dcdcbeb6cdabba1d86d527bab1596a0`.
- 실제 앱은 Application Support/GangnamDream_LocalCandidates/2026.10.10.1/timer-fix/
  GangnamDream-StoryDemo-Successor-2026.10.10.1-timer-fix.app의 executable 무인자 실행이다.
  bundle `dev.junheelee.gangnamdream.storydemo.successor.timer-fix`.
- 새 namespace `GangnamDream_StoryDemo_Successor_2026_10_10_1_timer-fix`는
  empty objectdb_snapshots 폴더만 있고 파일0이다. 저장/설정은 실제 UI에서만 생성한다.
  원관찰/보존/명령은 기존 형식 `.git/order516-live-20261010-timer-fix/`에 보존한다.
- 실제 KO 첫 본문·선택/결과를 독해한 뒤 UI 수동 slot 저장→정상 Quit→별도 프로세스
  이어하기→같은 결과/본문 위치·선택·slot 복원을 대조한다. 자동 월 저장만으로는
  exact cold resume GO가 아니다. 원manifest NOT_RUN는 수정하지 않는다.

- 원증거 `.git/order516-live-20261010/`: first-command.json1263B/SHA7fa0cd72…,
  stderr319B/SHAf972eeb3…, Godot783B/SHA2003713a…. 실제 namespace 자동 저장은
  6478B/SHA4143e6f7…/phase=story/month1/weeks0/choices[]이고 수동 resume slot은 없다.
- OS crash report는 정확 bundle/build/PID의 EXC_BAD_ACCESS/SIGSEGV,
  mainthread Object::_notification_forward→SceneTree::_process_group이다. Mac 잠금이 아니다.
- before638315B/SHA330cda14…와 fresh after-corrected639073B/SHA4edc60cf…:
  전체tracked3251/helper5/seed2/checkpoint/player33·보호6곳·앱7파일/ZIP/manifest 동일.
  after.json의 앱 상위폴더 오지정 산출도 보존하며 판정은 정확 앱 경로의 corrected만 쓴다.
- 후보 namespace만 새 설정/로그/자동 저장/backup4파일을 남겼다. 삭제·복구·재실행0.
  third 실패는 보존하고 새 후보 export 전 기존 실제 재생6항목/출시 HOLD를 유지한다.
  비저자 fresh 전수대조도 동일이며 own64602/64603 부재·사용자editor61385 생존이다.

**착수 — 2026-10-10.** 302의 수리7항목 source GO와 462의 export GO 뒤에 남은 실제
runtime6 가운데 첫 세 항목을 한 저장/재시작 흐름으로 검수한다. 제품 수정과 재export는 없다.

## 한 단위·깊이 3문

1. 없으면 수정된 대본의 앱이 실제 시작하고 진행을 보존하는지 알 수 없다.
2. 선택·24주 상태를 바꾸는 오더가 아니다. 같은 실제 선택/본문 위치가 새 프로세스에서도
   유지되는지 검수하며, 저장을 직접 만들거나 상태/주차/언어를 주입하지 않는다.
3. 전체 5언어/옛 공개 저장 복사 호환과 경쟁한다. 이번에는 KO 한 경로의 신규 저장과
   cold resume만 먼저 닫고 나머지를 실행했다고 세지 않는다.

## 첫 시도 exact 대상과 공통 소유

- 대상: source05747c92de6b590c5f0456376f2210a4e422b182/treea867b41a90f59f5dcedafe9bb171e39b82aa2100,
  BUILD2026.10.05.1/third. 462 manifest SHA02f2a3973b496df52bd71e8d1b0abe81e75fbe768221671ca9bff68016f16d49.
- 실제 배달 앱: Application Support/GangnamDream_LocalCandidates/2026.10.05.1/third의
  GangnamDream-StoryDemo-Successor-2026.10.05.1-third.app. executable 무인자 실행만 사용한다.
- 후보 전용 저장: GangnamDream_StoryDemo_Successor_2026_10_05_1_third. 입구는
  objectdb_snapshots 빈 폴더 외 파일0이며 사용자 기존 저장이 없다. 이번 앱이 만든
  저장·설정·로그는 삭제/복구하지 않고 보존한다.
- root: 이 사양·CODEX_QUEUE/L3 순번·302 runtime 문단·CLAUDE 현재행·WORK_LOG·생성STATUS·
  위임판정원장, private `.git/order516-live-*`의 생성된 보존 snapshot/로그/원관찰만.
- 비저자 phone_independent_review: 위 파일/앱 신원/원로그/저장을 읽기만 하고 한정 판정한다.
  새 오더별 보고0·검사/runner0. root만 엔진/CUA를 실행한다.
- 공개 앱/manifest/핀·옛462 실패/완료 기록·human·project·모든 원고/번역·사용자저장·
  checkpoint/seed/기존 helper는 불변이다.

## 실행·검증

1. 기존 successor builder의 identity/file_record/snapshot/protected/write_json/clean_environment/
   run_command와 기존457 snapshot을 그대로 호출한다. 새 검사 코드/실행기는 만들지 않는다.
   현재 앱·ZIP/PCK/manifest와 공개/사용자·전체tracked·seed/checkpoint 입구를 기록한다.
2. root가 실제 앱의 첫 언어/시작 안내를 읽고 KO를 실제 UI로 선택한다. 앱 실행 인자는0,
   QA smoke/자동선택/상태주입0. M01 실제 대본과 선택 결과를 정상 독해한다.
3. 앱 UI에서 저장 가능한 안전 위치를 만든 뒤 실제 저장 사실/내용을 읽고 정상 종료한다.
   두 번째 별도 프로세스를 같은 무인자로 시작하고 실제 이어보기로 저장 위치/선택을 확인한다.
   원래 저장을 손으로 고치거나 원namespace를 바꾸지 않는다. 마지막에도 정상 종료한다.
4. 정확 native entry profile/build/custom-dir marker, stdout/stderr와 후보 Godot log의
   script/parse/engine 오류, exit/프로세스, 새 저장 identity/본문 위치를 대조한다.
   실행 준비부터 마지막 종료fresh snapshot까지 docs/제품/helper 쓰기를 동결한다.
5. root와 비저자 모두 새 전후 전체 snapshot을 대조한다. 이후 기존 영향검사/context/queue/
   원장·STATUS/git diff로 문서 마감한다. 대형 audit·self-test 전량·240주·재export0.

## 완료와 한계

실제 부팅/새 저장/cold resume가 관측되고 오류·새 회귀0/원본보존이면 이 한 단위만 GO다.
실패는 원시 로그/저장과 함께 HOLD/REWORK로 남기며 원인을 분리해 후속 수리를 선언한다.
StoryMode 복귀 입력은 실제 관측한 만큼만 적고 runtime4 전체를 대신하지 않는다.
5언어 화면·옛 공개저장 복사 호환·전체 24주·본편·인간/원어민/물리패드/연속청취·외부출시
GO는 발급하지 않는다. 자동 PASS는 재미·깊이·문체의 증거가 아니다.
일회성 실행 범위이며 새 지속 규칙/정본 승격0이다.
