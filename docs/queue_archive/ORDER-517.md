# ORDER-517 — 첫 장면 자동 전환 Timer의 수명 수리

#### [x] ORDER-517 [P0·실행 종료] timeout 신호 발행 중 자기 해제

**착수 — 2026-10-10.** 516의 실제 successor/third 첫 실행에서 확인한
SIGSEGV와 발행 중 Object 해제만 수리한다. 현 controller는 같은 원문이다.

## 완료·source 한정 판정 — 2026-10-10

비저자 `/root/phone_independent_review`가 clean main/origin source
`9c1b4e4c010184e79f46a50a1900156f588be822`/tree
`f07257bd7b77ea5061b72258935b364d272873d5`의 전체7파일 diff와 검수한 두 제품
blob을 직접 대조해 이 Timer 수리만 GO했다. 나머지5개는 운영문서다.
원문/locale/project/SceneTransition·다른 runtime·human/과거 판정/462manifest/builder
Git 변경0이다. 새 실제 package·첫 장면 도달/수동 저장/cold resume는 미관찰이다.

## 구현·표적 결과

- 제품은 두 Timer의 remove_child/free만 queue_free로 교체했다. timeout 발행자는
  그 프레임까지 유효하고 다음 프레임에 해제된다. serial/screen/auto guard와
  _launch_story 호출·3초 wait/CONNECT_ONE_SHOT은 그대로다.
- 기존 five-language fixture에 실제 expiry/cancel/stale 표본을 넣었다. 실제 장면
  라우팅은 막고 emitter lifetime/replacement만 대조한다. serial guard의 독립적인
  장면 차단이나 실제 앱 완주 증거는 아니다.
- `.git/order517-timer-20261010/` 수정 전 before-command SHAf7308627…:
  exit1/8.42011초, controller2412의 locked/free ERROR+SCRIPT ERROR를 재현했다.
  stale의 previously-freed argument와 leak는 수정 전 fixture 부수 오류이며 원516
  사용자 오류와 합치지 않는다. 현재 fixture는 valid guard/실패 시 orphan 정리를 보강했다.
- 수정 후 fixed-command1610B/SHAc5cff20f…: exit0/8.437666초,
  stdout/Godot각4319B/SHAe188f73b…·stderr0·정확5언어 marker1·오류/경고/누수0.
  기존 locales5/routes5/months30/weeks120/settlements30/save5/story10도 통과했다.
- Compile68/Font routing·고지 normal/self·trace normal/self·이름표24case·demo
  현지화 normal/self·package self·audit registration·EN coverage/Hangul PASS.
  influence-command6441B/SHA636a6d7a…와 engine-command2996B/SHA030ec4e8…를 보존한다.
- I18n은 exit0/정확 원래 긴 marker1/engine error0·의도한 입력 거절 warning19다.
  root가 짧은 marker를 잘못 지정한 wrapper 실패는 원로그에 남기고 재실행하지 않았다.
  원코드의 긴 marker를 직접 대조한 receipt2506B/SHA51fc0baf…와 구분한다.
- 수정 전/후 각 source+protected 전후 equality, 수정 후 final fresh도 SHA57eb2809…/
  636215B 전체 동일: tracked3252/helper5/seed2/checkpoint/player33·보호6곳.
  비저자도 fixed 전후/fresh/원로그를 직접 읽고 코드/QA/보존 한정 GO다.
  제품 commit 전수대조까지 수리 한정 GO이며 원장은 이 완료 사양의 SHA에 결속한다.
  새 package/실제 재생은 HOLD다.

## 한 단위·깊이 3문

1. 없으면 첫 월 안내의 3초 자동 전환 때 앱이 종료돼 첫 선택에 도달할 수 없다.
2. 선택·보상·저장 스키마를 바꾸지 않고 기존 첫 장면 도달을 복구한다.
3. SceneTransition 전역 변경·새 빌더·다른 화면과 경쟁한다. 근거가 직접 가리키는
   Timer 수명만 고치고 패키지 재발급/실제 cold resume는 별도 후속으로 남긴다.

## 만지는 파일·소유

- root: `playtests/order124/StoryChoiceM1M6Playtest.gd`의 자동 전환 Timer 해제2곳,
  `tools/StoryDemoFourLanguageCheck.gd`의 기존 제품 검사 내 timeout/cancel/stale 표본.
- root 운영 문서: 이 사양·516 실패/302 잔여·CODEX_QUEUE/L3 순번·CLAUDE 현재행·
  WORK_LOG·생성STATUS·필요한 위임판정원장. private `.git/order517-*`에는 기존 도구의
  원로그/보존 snapshot만 생성한다. 새 검사/runner/오더별 보고0.
- 비저자 `phone_independent_review`: 코드/표본/로그·보존 읽기 전용 검수.
- `project.godot`·원문/번역·수치/조건/flags·저장 구조·SceneTransition·공개 데모·
  third 산출물/manifest·사용자저장·과거 판정·기존 helper는 불변이다.

## 구현·검증

1. Timer.stop/참조 정리·serial/screen/auto-launch guard는 유지한다. 취소/timeout
   즉시 free 대신 queue_free로 현재 신호/프레임이 끝날 때까지 객체를 살려 둔다.
2. 기존 five-language fixture에서 실제 짧은 Timer timeout을 발생시킨다.
   expiry 때 자기 Timer가 유효/삭제예약이고 다음 프레임에 해제됨, 취소한 Timer가
   재발행하지 않음, stale serial이 새 Timer/장면을 소비하지 않음을 대조한다.
   fixture는 장면 이동 guard를 막고 수명만 검수한다. 실제 장면 도달 증거로 쓰지 않는다.
3. 기존 pre-autoload 격리 bootstrap/run_command를 그대로 재사용해 수정 전 반례와
   수정 후 기존 fixture/compile을 검사한다. 정확 marker·stdout/stderr/Godot log를
   모두 읽는다. 기존 영향 검사·공개/demo 문자열 계약·context/queue/STATUS/diff를
   대조한다. 전체 audit/240주/새 도구/재export0.
4. source 수리 한정 GO만 발급한다. 기존 third 실패를 소급 통과시키지 않는다.
   새 package identity/date/census 정렬·재export·실제 첫 장면/수동 저장/cold resume는
   후속에서 선언한다. 원문/번역/공개GO·인간 관찰을 바꾸지 않는다.

자동 PASS는 재미·깊이·문체의 증거가 아니다. 전체제품/출시 HOLD.
기존 객체 수명 계약 복구이며 새 지속 규범/정본 승격0·일회성 작업이다.
