# ORDER-564 — 프롤로그 통화 종료 표시 수리

#### [x] ORDER-564 source·표적 headless 수리 완료 — 2026-10-12

만지는 파일: `scenes/StoryMode.gd`, `tools/ManualSaveCheck.gd`,
`docs/CODEX_QUEUE.md`, `docs/CODEX_QUEUE_L3_PENDING.md`, 이 사양,
`docs/WORK_LOG.md`, `CLAUDE.md`. 완료 시 사양을 queue_archive로 이동한다.

## 실물·깊이 3문

- actual534 fresh의 KO 선택0 결과 source2에서 통화가 끝났는데 badge/inset/nameplate가
  남았다. `.git/order534-rework-fresh-20261011/observations.json`2859B/
  SHAed89b1a98a35051ad9aefb9be9d8c5f22c8bbcb2299c47c2bf5673ed94aefb7e.
  현 소비자는 `arc_hyunsu_new_path`만 보정하므로 프롤로그에는 적용되지 않는다.
- 이 수리가 없으면 끝난 통화를 현재 대화로 오인한다. 결과 source 문단 경계를
  화면 페이지/언어 문자열과 분리한다. 선택0은 source2, 선택1은 source1부터 끝난다.
- 24주 뒤 상태를 새로 만드는 선택 작업이 아니다. 기존 효과·father affinity·
  follow_up·choice/read receipt와 한번 적용 계약을 그대로 두는 표시 버그 수리다.
- 통화 중 표시와 종료 서술의 배타성이 대상이다. 새 연출/대사/장면/시스템은0이다.
  근거: STORY_CONSISTENCY_SYSTEM의 Runtime Visual Grammar와 기존 source 결과문.

## 소유·구현

- root: StoryMode의 기존 paragraph presentation consumer와 기록만.
- manual_save_ci: 기존 ManualSaveCheck의 프롤로그 두 선택·5언어·cold result·
  언어 갱신·다음 phone event reset·효과/receipt once 표적 fixture만.
- mod_layer_ci: 읽기전용 source/fixture/실행 원자료 독립 검수만.
- 신규 영구도구/checker/등록/범용 연출 플랫폼·전체 audit/240주·검증 비용 작업0.
  기존 W40 회귀는 유지한다. registry·원고·번역·release inventory는 바꾸지 않는다.

## 표적 검증·완료 경계

- 기존 pre-autoload bootstrap·fresh HOME/3XDG의 headless 검사만 실행한다.
  scoped prologue와 W40 fixture, CompileCheck, StoryPresenceCheck 및 관련 정적
  영어한글·다국어·서사 연속성·데모 계약을 검증한다. actual exit와 marker 및
  stdout/stderr/Godot log 오류를 함께 읽고 사용자/공개/원raw/seed 보존을 대조한다.
- audit_select --list로 영향 목록만 확인한다. 전체 목록의 월/240주 회귀 실행0.
  제품 검사를 삭제하거나 KNOWN_FAILURES를 넓혀 통과시키지 않는다.
- OS 잠금 중 native 앱/UI 입력0. headless source 회귀 한정 완료와 실제 수정화면
  미관측 HOLD를 구분한다. 본편 M17은562 하나만 열려 있고 새 월 플레이0이다.
- project.godot·실제 사용자 저장·공개 demo artifact·인간 OPEN45·옛 판정 불변.
  원어민/인간/물리패드/청취·전체 본편/출시 GO가 아니다. 새규범0·일회성이다.

## 결과

- 선언4ceac5a6/tree8aa6aca3 뒤 기존 소비자만 고쳤다. 선택0 결과 source2,
  선택1 source1부터 narration/초상·명패 숨김이며 기존 Hyunsu 경계는 불변이다.
  원고·번역·registry·효과·save schema·루트/후속 장면 변경0이다.
- scoped prologue fresh retry actual0/10.96642s·literal marker1,
  live30/disk-new-Story20/같은 source 언어20/prepared phone reset10/read-close once10.
  두 선택×5언어의 연결/종료 경계와 mental/tint/father/choice/history/registry once를
  대조했다. KO/EN 실제 언어 소비자와 준비 CJK를 구분한다. 같은 OS process의
  real v4 저장 재개이며 새 OS process/정상 프롤로그 플레이·실제 pixels 증거가 아니다.
- 기존 Hyunsu actual0/9.255693s·live40/disk10/언어10/reset5, final compile69
  actual0/4.729011s·각 marker1·3stream 오류/경고0. 초기 compile도 PASS다.
  초기 prologue actual1/선택화면 nameplate 오탐10은 원raw 그대로 보존했다.
  기존 choice dock의 이름표 숨김에 맞춰 fixture의 choices 단계만 교정했으며,
  result 종료 표시·효과·영수증 assertions는 완화하지 않았다.
- StoryPresence actual0/marker1이나 resource4 ERROR/ObjectDB WARNING이 있어
  private strict 판정은 FAIL로 보존한다. 기존 녹색9c27151 CI에도 같은 resource4가
  있다. 변경 없는 등록 audit guard의 actual raw 재판독은 default0/strict1/
  teardown_strict1이다. clean PASS·원인 해결 주장이 아니며 추가 누수 탐침0이다.
- 등록 정적 표적13종 PASS: EN coverage/Hangul, 서사 연속성·말투·정합,
  장면음악·다국어·JA UI·ZH skeleton·demo scope 기본모드·story demo locale·
  출시 inventory·플레이어 언어다. 별도 optional demo --strict는 기존 JA21/701,
  SC/TC150/701 미완료로 actual1/errors3을 보존한다. 제품 검사/KNOWN 확대0이다.
- 비저자 mod_layer_ci의 source/fixture/원3stream 독립 검수 blocking0·한정GO,
  report9026B/SHA6d4675b85b55830eb14b349bf6d8afe9253b01d244878a15dc304e5f95f06d96.
  rework_batch_plan final13347B/
  SHA941458ffbacdb14368e681e56cf0a1b2de460f0ac8b8ff1cd0672c1c0f30f9f9:
  fresh13/13·nonowned3347·보호42그룹625항목·초기raw exact다.
  모든 원자료는 `.git/order564-qa-20261012/`에 보존했다.
- StoryMode304464B/SHA4415fcce68ec003c1f4a3d3d79ffb7ce81a5115a24893a40f903e275da32758d,
  ManualSave408058B/SHA949918ca43aa5211c726348c91dcbdd771a0036aec2bd272e00cdc25508b8f69.
  source/headless 수리만 마감한다. OS잠금 중 native/UI0·수정 실제화면 HOLD,
  M17/562 retry2 native0·admission0·새 월0이며 과거 인간/공개/REWORK 불변이다.
  기존 BUILD2026.10.11.3 앱에는 이 수리가 없다. 차후 앱 검수에서 확인해야 한다.
- 선언4ceac5a6의 CI38153926498/jobs114512869799·114512869870 전steps success를
  확인했다. 이 결과는 수정 구현 commit의 CI 통과가 아니다. 그 CI는 push 뒤 확인한다.
  원어민/인간/패드/청취·번역 전체/본편/출시 GO가 아니다. 새규범0·모두 일회성.
