# Gangnam Dream Work Log

> 최신 작업만 이 파일에 역순으로 기록한다. 2026-05-16부터 2026-07-24 USER-P0M까지의 원문은
> [`history/WORK_LOG_2026-05-16_to_2026-07-24.md`](history/WORK_LOG_2026-05-16_to_2026-07-24.md)에 손실 없이 보존했다.
> 2026-08-14·2026-08-10·2026-08-05·2026-08-04의 오래된 항목, 2026-08-03·2026-07-31의 오래된 항목,
> 2026-07-30의 오래된 V2 C/D/E 항목,
> 2026-07-29 이전 항목은 날짜별 보관본인
> [`history/WORK_LOG_2026-08-14.md`](history/WORK_LOG_2026-08-14.md),
> [`history/WORK_LOG_2026-08-03.md`](history/WORK_LOG_2026-08-03.md),
> [`history/WORK_LOG_2026-08-04.md`](history/WORK_LOG_2026-08-04.md),
> [`history/WORK_LOG_2026-08-05.md`](history/WORK_LOG_2026-08-05.md),
> [`history/WORK_LOG_2026-08-10.md`](history/WORK_LOG_2026-08-10.md),
> [`history/WORK_LOG_2026-08-11.md`](history/WORK_LOG_2026-08-11.md),
> [`history/WORK_LOG_2026-08-12.md`](history/WORK_LOG_2026-08-12.md),
> [`history/WORK_LOG_2026-07-31.md`](history/WORK_LOG_2026-07-31.md),
> [`history/WORK_LOG_2026-07-30.md`](history/WORK_LOG_2026-07-30.md),
> [`history/WORK_LOG_2026-07-29.md`](history/WORK_LOG_2026-07-29.md),
> [`history/WORK_LOG_2026-07-27.md`](history/WORK_LOG_2026-07-27.md)와
> [`history/WORK_LOG_2026-07-26.md`](history/WORK_LOG_2026-07-26.md),
> [`history/WORK_LOG_2026-07-25.md`](history/WORK_LOG_2026-07-25.md)로
> 차례로 옮긴다.
> 과거 근거는 기본 컨텍스트에 넣지 말고 먼저 `rg -n "<키워드>" docs/history/`로 찾는다.

## 2026-08-24 (Codex — ORDER-124 검은 장면 복귀 수리 BUILD .3)

- 사용자가 BUILD `.2`에서 “중간에 그냥 검은화면뭔데”라고 보고했다. 저장·크래시가
  아니라 `StoryMode`가 `SceneTransition.go(ret)`로 완전 불투명 전환막을 남긴 뒤
  ORDER-124 목적 장면이 `fade_in()`을 호출하지 않은 결함이었다. M01~M05는 다음
  장면이 6초 뒤 우연히 막을 걷었지만 M06 회고는 영구 검정이 될 수 있었다.
- 후보 controller가 StoryMode 복귀 UI를 만든 뒤 전환막과 입력 차단을 반드시
  해제하도록 고쳤다. 정산 실패도 빈 shell에 머물지 않고 남은 장면 전환 또는
  오류 홈을 보인다. 표적 검사는 M01 전환과 M06 회고의 실제 복귀 상태를 각각
  재현해 `returns=2 overlay=1`을 확인한다.
- BUILD `2026.08.24.3` source
  `23f0bd9b7a56a352c9234f95870a98dbf5c728e9` / tree
  `2dcfb0e465f2981b8058ccc03605fa98fca3f746`, manifest
  `721c9021236c158432be0b3ae47ebcd785f4e4f461b4b05d709b0d71384ca148`, ZIP
  `b66d72ce97f1d36e7902ccc79a1062e61e6627aa4aa12cdea5eb84f53c362431`, app tree
  `275f536ad1cf70b138ecda1350ef539fd20de43c904796fe59bada0ff3f194ee`다.
- package self-test `checks=38`, final audit·ad-hoc codesign, KO 1280×800·EN
  960×600 smoke와 캡처가 통과했다. 패키지의 실제 왕복은
  `ORDER124_RETURN_SMOKE_OK ... screen=transition month=2 overlay=clear input=clear`,
  기존 저장 복귀는 `ORDER124_RESUME_SMOKE_OK ... month=3 weeks=8 settlements=2
  choices=2 phase=story screen=transition overlay=clear input=clear`를 남겼다.
- 사용자의 `.2` 저장 SHA-256
  `fe1d0a0011a1a8d447ce7d46494f2454b3b09ee7c8e2f6596d827a6cd8db734b`와 전용
  디렉터리 tree `b54d6515e45742298104cc44774508e8d53701debc3be7b9ed5d84bf72c0b5e8`는
  빌드 전후 byte-exact다. 별도 복구본도
  `GangnamDream_ORDER124_SaveBackups/pre-build-2026.08.24.3`에 보존했다.
  retail meta SHA `fc46cc3a40d7813beffc7ed6db969bd55218ee60de66ba313235a99e2072577d`,
  제품 설정, `demo_rc`, ORDER-103 저장·산출물도 불변이다.
- 결함 있는 `.2` manifest·checksum·ZIP은
  `build/order124/archive/2026.08.24.2`에 보존하고 active 후보에서 내렸다.
  `.3` 기술 후보는 플레이 가능하지만 재미 L3와 본편 이관은 OPEN/HOLD다. AP·시간·
  경제 내부를 지금 삭제한 것이 아니며 플레이어 앞의 별도 월간 행동 선택층만 이
  표본에서 사용하지 않는다. 24주·240주·전체 감사는 실행하거나 인용하지 않았다.

## 2026-08-24 (Codex — 월간 행동 없는 M01~M06 후보)

- 사용자 NO-GO에 따라 `주력/함께/여력`을 없애고 StoryMode 선택 뒤 네 주와
  생활 압박이 자동 정산되는 독립 앱을 만들었다.
- BUILD `2026.08.24.2` source `e9aff5f06c2e3ec3708426156074674a56a4c3f6` /
  tree `ad4d88a6aed68a79074f6f8e3204bf0474f6dbc4`, manifest
  `87f3491f7e526762203a83eb4ed25bbbba79981f7dc3ec812d49cdd955db1194`, ZIP
  `626196d6a74f50373ddc3e6d0cb8b3a502f052d4436f308361d8b82d3ab45a75`다.
- 표적 검사는 6개월·24주·정산 6·commitment 0·두 경로·저장·M06을 통과했고
  package audit, KO/EN smoke·캡처도 green이다. 최종 앱의 KO 960×600·EN
  1280×800 실제 선택을 Enter로 확정했고 KO는 M03·8주·정산 2까지 이어졌다.
- 초기 direct checker가 retail meta를 건드렸으나 백업에서 SHA
  `fc46cc3a40d7813beffc7ed6db969bd55218ee60de66ba313235a99e2072577d`로 복구했다.
  이후 staged-only guard를 강제했고 제품·기존 저장·반려 ORDER-103은 불변이다.
- `order124_rc`는 active, 사용자 L3와 본편 이관은 OPEN이다. 24주·240주·전체
  감사는 이 후보에 실행하거나 인용하지 않았다.

## 2026-08-24 (Codex — ORDER-103 전용 M01~M06 macOS 후보)

- 숫자 여력 네 장의 W1~W24 active `demo_rc`와 장면 카드·`주력/함께` M01~M06
  선택판이 섞여 안내된 원인을 확인했다. 일반 제품 export에는 tools 체험 장면이
  포함되지 않았으므로 ORDER-103만 여는 전용 앱
  `GangnamDream-ORDER103-M01M06-ChoicePlaytest`를 발급했다.
- BUILD `2026.08.24.1`은 exact clean source
  `20ec3fb04f5068846518f28e4123e1fabfa73e34` / tree
  `79cf4bd95899a44fa353bd68212f266a2b4fba09`다. manifest SHA-256은
  `8e22703a2ac9fc1ee92188f3519e82704271a4a4f204556c4b162f271357503d`, ZIP은
  `8e6a7d7930c25ec71f2a6a45ec8ac8ea7f52ae8af9a1b34d17cc63d9310fd930`다.
- 표적 검사, KO 1280×800·EN 960×600 package flow, 첫 확인 역할 포커스·둘째 확인
  배정, 자동 배정/잘림/스크롤 0, M02·회고 저장 재개, Finder 무인자 전용 홈 진입,
  ad-hoc codesign과 manifest/app/ZIP 재검산을 통과했다. 제품 설정 7파일과 기존
  retail/V2 저장 19파일은 후보 생성 전후 byte-exact다. 24주·240주 검사는 이
  후보의 증거로 실행하거나 인용하지 않았다.
- `order103_rc`만 active로 등록했다. 자동 입력은 합성 L2라 물리 패드·재미·최종
  GO를 대신하지 않으므로 ORDER-103은 `[~]`, 사용자 L3는 `OPEN`이다. 기존
  `demo_rc`, 고정 BUILD `.3`, full 후보의 identity와 상태는 바꾸지 않았다.

## 2026-08-22 (Codex — ORDER-119 exact clean 기계·패키지 후보)

- exact clean `ebc58a839d64d8810b9da5548c20e58bc43c9e30` / tree
  `f978a22525b678ef83619dc50094a6dada75f190`에서 full audit failure flag `0`,
  KO gamepad·EN keyboard 각 24주 `CORE_LOOP_V2_INPUT_OK`, KO gamepad 240주
  `FULL_INPUT_RUN_OK weeks=240 events=240 ending=with_daeun`를 확인했다.
- BUILD `2026.08.22.1`의 Windows·macOS·Linux V2 playtest를 발급했고 manifest
  SHA-256은 `8a34920038962a4ba0885ad6189d92dc6d3c3ee2780020f3894938d380613177`다.
  macOS native no-arg smoke도 `PLAYTEST_RELEASE_ENTRY_READY`와 정상 종료 `0`을 확인했다.
  세 artifact SHA와 clean source identity는 manifest가 소유한다.
- 이 후보를 active `demo_rc`로 등록했다. 자동 증거는 사람 판정을 대신하지 않으므로
  ORDER-119는 `[~]`, 사용자 최종 GO는 `OPEN`이다. 고정 BUILD `.3` ORDER-99 저장
  게이트와 별도 ORDER-103 실행 후보·사용자 게이트도 바꾸지 않았다.

## 2026-08-22 (Codex — ORDER-123 원격 24주 입력 시간 예산 복구)

- closure `814f84b647aef8e351b7e5df727fe092309781ea`의 원격 run
  `32537893833`은 정적 job과 전체 `audit.sh`를 통과했다. KO PlayStation도
  Board 행렬, W9 exact terminal tuple, `v2_hyunsu_study_followup`을 통과하고
  W15까지 진행했으나 workflow의 420초 상한에 정확히 닿아 exit `124`로 끝났다.
- 종료 1.66초 전에도 W15 장면을 출력했고 engine/script/QA failure는 `0`이라
  제품 정지가 아니다. scope `65fbcf2` 뒤 구현
  `79f1e0db2878a1c1d8c380a478d2503c545c6af2`(tree
  `dea843ec197a456388d60801166f0baea26e1321`)에서 소유 범위를 20파일로
  늘리고 KO/EN 두 step의 유한 상한만 `420→1200`으로 고정했다.
- 제품·콘텐츠·입력 QA·runner는 `814f84b`와 byte-exact다. 같은 최종 closure
  바이트의 local full audit failure flag `0`을 재확인하며, 새 원격 CI가 KO·EN
  W24, SimRun, SmokeRace까지 green인 경우에만 `[x]`를 채택한다.

## 2026-08-22 (Codex — W9 다중 약속 선택·24주 입력 복구)

- 기준 `680e5f6bdcc9223b45143ca6224f7eb112809c6e`에서 구현
  `4177cd281d7be2c4084a294fd1aa3cbb89b15709`(tree
  `fc836ca142471c6520ba6f489e500ef1fc35d1dc`)으로 W9의 ordinary
  `daeun_world_meet`, Father terminal, Hyunsu terminal 세 후보를 모두
  보존했다. Board 상한은 현재 reachable max 4이며 5+,
  malformed record, 빈/중복 ID, KO/EN 결손, identity cross-wire는
  fail-closed한다.
- terminal candidate ID·authored bundle·route·variant를 분리했고,
  960×600에서 후보만 두 행 scroll로 보이며 설명·진전·deadline·
  Commit은 고정했다. W9의 Hyunsu terminal은 실제
  `hyunsu_study_followup` 번들과 `v2_hyunsu_study_followup` 장면으로
  연결됐다.
- KO/EN × keyboard/gamepad 24주 4개는 각각 24 allocations, W24 frozen
  snapshot, save/load, autosave, title return으로 완주했다. KO/EN ×
  1280×800/960×600 화면 4개, Board 0~4개 입력/해상도 행렬,
  Compile 65, Cycle 24/48/240 horizon, demo ORDER-123 음성 10,
  독립 L2 P0/P1 `0`을 확인했다.
- 첫 전체 감사는 제품·컴파일·밸런스·런타임을 통과하고 Year5 보호 해시
  1개와 Board 안내 lookup `+1`에서 파생된 JA/ZH 원장 4개만 실패했다.
  `284307e`가 범위를 19파일로 확장했고 `49942f7`은 잠금 4파일과
  Chapter source hash만 갱신했다. Year5 direct/self-test/R1 266,
  JA 68, ZH 251, demo localization 16, Chapter direct가 통과했다.
- `DemoCoreLoopV2`, GameState, KO/EN 사건, 실행 meta, 효과, 저장 schema,
  밸런스, Chapter ledger JSON은 기준과 byte-exact다. exact W9 IDs,
  유입 commit 계보, 20단위·19파일·산출물 경로는 일회성 증거이며,
  지속 규칙은 `docs/QA_CHECKLIST.md`의 Weeks 9–12 gate에 승격했다.
  ORDER-119 사용자 최종 GO는 계속 OPEN이다.

## 2026-08-22 (Codex — 전체 감사 잔여 7플래그 exact-scope 복구)

- 기준 `e53689ca58ef3fdc6e6fa9d2c67c7b4ca82975b4`에서 구현
  `5729b14af5f36af15a57cb21b8332e871224061f`(tree
  `4a77c593aa7a51cf4c08fd4a8071c7942365a20f`)로 surface, narrative continuity,
  full-run pacing, demo prose, exposed state, CoreLoop V2, scene-direction runtime의
  일곱 소유자를 수리했다. baseline·debt·project·manifest·gameplay metadata를
  완화하지 않았고 허용한 사건 산문은 exact 네 leaf뿐이다.
- surface는 StyleBox `260` / direct theme override `2112` / private color `681`,
  continuity는 A/B Chapter 2 isolated `0`과 branch `420/421` 경계, fixed-model
  2시간 crossing은 A W97 `modeled_random_foreground` / B W96
  `arc_year2_close`의 exact scene component다. demo prose written clock은 `0`,
  exposed-state는 domain `+2/-6`, CoreLoop V2 음성 검사는 `14`, direction runtime은
  shipping `1603`으로 통과했다.
- release는 packaged `1758` / shipping `1603` / author-only `155`, Chapter 1은
  authoritative `24/48` / debt code `8` / blocked evaluation `3`을 보존했다.
  Godot StoryMap/Direction/Compile이 통과했고 독립 L2 최종 판정은 P0/P1 `0`이다.
  `docs/QA_CHECKLIST.md`에는 branch 420/421, W96 exact-scene crossing, shipping
  direction fail-closed, reachable exact-minute permission을 정본 승격했다.
- 정확한 roots·edges·occurrences·domains·commit/tree·25단위·22파일은 일회성
  증거다. 이 마감 후보는 closure와 STATUS를 포함한 같은 최종 바이트에서 root가
  전체 `tools/audit.sh` failure flag `0`을 확인한 경우에만 완료 정본이며, 실패하면
  ORDER-122를 미완료로 되돌린다. ORDER-119는 그 green 뒤 마감을 재개하고 사용자
  최종 GO는 계속 OPEN이다.

## 2026-08-22 (Codex — author-only 생명주기와 shipping corpus 분리)

- 구현 `f7b9f6e53be1e06201b52360935593d372cb1ebb`(tree
  `3f7687f5acac752ba024d91f2ae9bb4ca68deeee`)에서 packaged 1,758 / shipping
  1,603 / author-only 155를 분리했다. tagged 127과 ledger-only 28의 exact 원장을
  만들고 weight/hidden/min_turn metadata와 제품 ingress 0을 함께 만족한 155편만
  dead/inert 감사에서 제외했다. `debt_baseline`은 올리지 않았고 `audit.py`는
  ERROR 0·inert 0이다.
- event director와 visual/audio/direction catalog는 shipping 1,603을 유지한다.
  release inventory/report는 packaged 1,758을 계속 심의 대상으로 세며, author-only를
  출시 package에서 지우거나 기존 manifest를 1,758로 부풀리지 않았다.
- Year5 kernel Dictionary 3곳, `arc_final_countdown` cue 4→3, Chapter 1 source/proof
  snapshot을 최소수리했다. lifecycle 27변이, release 14변이, year5 35변이·Godot
  266검사, Chapter 1 472변이와
  [정적 CI job](https://github.com/junheeleee/GangnamDream/actions/runs/32499196077)의
  story map·정적 감사·밸런스가 통과했다. 독립 L2 최종 판정은 P0/P1 0이다.
- 같은 구현의 전체 `audit.sh`는 rc 1이다. 확인된 잔여는 narrative continuity,
  full-run pacing, demo prose, exposed state, CoreLoopV2, surface coherence, stale STATUS,
  scene-direction runtime 여덟 플래그다. direction의 미분류 edge는
  `arc_y5_three_in_room→arc_y5_three_in_room_decision`과
  `arc_final_countdown_not_executed→arc_final_week`이다. STATUS는 이 closeout에서
  재생성해 해소했고, 현재 OPEN 7개는 별도 exact-scope 복구와 ORDER-119 마감 전까지
  넘긴다. leverage roundtrip 실패는 이번 전체 감사에서 재현되지 않았다.

## 2026-08-21 (Codex — ORDER-117 국소 수리·career 전수 판정 L1/L2 후보)

- 구현 후보 `e32c69b32acfbf6c5f1ced13cc88bf85ac5df563`(tree
  `a6f0a4050862e717d7eb4b365b557bcc5a409e3f`)에서 107/109 지목 2편과 career
  15편을 세 축으로 전수 판정했다. 지목 2편과 career 14편을 재작성해 KO/EN 각각
  exact changed roots는 16개이며, 비대상 object·metadata·choice count는 기준
  `921edf7e7eb04b5034bb3b788249875630619887`과 exact다.
- `arc_y5_after_goal_hyunsu_career`는 KO
  `0f813ff0292bb46f1e03cac8fbf66e79d807f88d7238a0c671a04782e32bc923`, EN
  `875b9e909f882712bf380b265c593327208599834bf339fc7d3acbe97fed2982`로 보존했고,
  `arc_y5_people_verdict_career_hyunsu`도 baseline exact다. description은 KO
  394~525자·EN 691~799자, 한영 leaf·placeholder parity exact, generalized
  code-token/backtick은 0이다.
- year5 direct/self-test 34, EN coverage, story consistency, speech register,
  random-pool hygiene와 diff 검사가 통과했고 독립 L2 후 최종 P0/P1은 0이다.
  ORDER-117은 `[~]`로 두며 Claude의 지목 2편 직접·career 15편 전수 재판정과
  사용자 최종 GO는 OPEN, R1b는 HOLD다.

## 2026-08-21 (Codex — ORDER-118 startup 마지막 해 재설계 L1/L2 후보)

- 구현 후보 `f425b812d72664c2baeeb746aa6ce0b5f6299c0f`(tree
  `4c0a659e972140660ae6d75968fcffef0c081cee`)에서 startup 16편을 고객 장애부터
  마지막 독립 저녁까지 사람·시간 중심 6결정+10다리로 다시 썼다. KO/EN은 각각
  16 roots·27 choices이며 공동창업자·팀·현재 고객 수진이 비용을 자기 행동으로 낸다.
- 마지막 해 인접 산문의 문서 코드·버전·해시 표기를 자연어로 내려 strict player
  token은 0이다. 한영 구조·placeholder·말투·서사 정합, 34개 음성 감사와 Godot
  historical kernel 266검사가 통과했고 product consumer·dispatch는 0이다.
- 독립 L2는 P0/P1 0이다. ORDER-118은 `[~]`로 두고 seed 9821의 새 16편 중 3편을
  `Claude(사용자 위임)`으로 다시 낭독한 뒤 사용자 최종 GO를 별도로 받는다. 새
  replacement contract가 없으므로 R1b·save·dispatcher·transaction·ending은 HOLD다.

## 2026-08-21 (Codex — ORDER-104~113 Claude 위임 L3 판정 기록)

- 803a372 원문에서 오더별 seed 9821 무작위 3편, 총 30편을 인물 목소리·지금
  잃는 것·다음을 기다리게 하는 여운으로 판정했다. 결과는 104/105/106/108/110/111
  합격, 107/109 조건부, 112 부분 반려, 113 전량 반려다. 기록 권위는
  `Claude(사용자 위임)`이며 사용자 최종 GO 10건은 모두 OPEN으로 남겼다.
- 합격한 6개만 `[x]`로 닫고, 조건부·부분·전량 반려 4개는 `[!]` 실패 이력으로
  보존했다. ORDER-118은 startup 16편·코드형 산문, ORDER-117은 107/109 지목 2편과
  career 15편 복구를 소유한다. 강한 현수 장면은 KO/EN exact 보존한다.
- dormant 9+9 계약은 `invalidated_by_delegated_l3`, `r1b_allowed=false`, replacement
  null로 잠갔다. pure kernel·제품 runtime·save·story map·endings는 건드리지 않았고,
  새 원고 L3와 별도 새 계약 전에는 R1b를 열지 않는다.

## 2026-08-21 (Codex — M01~M06 선택 화면 게임 장면형 재작업)

- 오래된 `BUILD 2026.08.10.1`의 빈 2×2 관리표를 제품 후보로 잘못 띄운 사실을
  확인하고 중단했다. 현행 정본 `StoryMapM1M6Playtest`도 같은 대시보드 문법이어서,
  제품·스토리·저장 경로는 건드리지 않고 선택 화면만 고시원 세계 위 어두운
  `Gangnam Ink` 장면 카드와 명시적 `주력`·`함께` 자리로 다시 만들었다.
- 19개 약속을 결과를 선취하지 않는 9개 신규 무인 이미지와 9개 안전한 기존 장소
  이미지에 연결했다. 마우스 호버와 패드 포커스는 같은 잉크선·2px 이하 들림·
  1.8% 장면 push-in·잉크막 걷힘을 쓰며, 확인은 55ms 동안 내용이 1px 눌린다.
  밝은 포스트잇·카테고리색·호버 효과음/진동은 쓰지 않는다.
- 카드 확인은 역할을 자동 배정하지 않고 해당 자리로 포커스만 옮긴다. 두 번째
  확인이 배치를 확정하고, 선택/취소에는 종이 소리와 쪽지 이동, 월 확정에는 도장
  소리가 한 번만 난다. 영문 960px 재시작 확인 문구는 좁은 버튼이 아니라 하단
  안내줄에 표시한다.
- 사용자 판정 “월 마감 지금 괜찮아”를 따라 결과·회고 레이아웃과 결과 계산은
  보존했다. KO/EN 960×600·1280×800 실렌더, 마우스·키보드/패드 의미 입력,
  여섯 달 전용 저장, 종료 자원 해제, 표적 5검사와 독립 L2는 P0/P1 0이다.
  사용자 L3 재플레이 전까지 ORDER-103은 `[~]`이고 기존 24주 이관은 시작하지 않는다.
  전체 UI 통일은 이 표면 승인 뒤 공용 토큰/장면 컴포넌트부터 단계 이관하며,
  승인된 월 마감·회고·엔딩은 마지막 별도 배치 전까지 동결한다.

## 2026-08-20 (Codex — 마지막 해 R1a 비활성 계약 커널)

- career·startup M49~M55의 18 roots·50 choices를 caller가 주입한 Dictionary만으로
  재생하는 pure `Year5ReferenceRouteKernel`을 만들었다. exact partner/M48/founding/
  route-lock ingress와 경제 경로, document role handle과 실제 scene actor, C0/C1·
  h0/h1 custody, M53 synthetic handoff, 월간 margin, continuation/terminal을 분리했다.
- 선택은 common+choice writes를 원자 적용하고 exact callback만 성공 no-op로 받는다.
  history는 매번 다시 계산하며 extra/missing receipt, 이직·퇴사, 잘못된 M52 actor,
  read-before-transfer, margin double-spend, terminal downstream, bool·float·string integer
  위조, 중복·부분·변조 row를 fail-closed한다. file I/O·autoload·GameState·SaveManager·
  EventManager·MainGame·StoryMode·돈·직업·flag·ending write는 0이다.
- manifest direct 2 routes/32 roots/86 choices와 음성 100건, Godot R1a 18/50·241건,
  story-map 차선 7/7, strict JSON·context·queue·scope·diff, 독립 L2가 모두 통과해
  P0/P1 0이다. 보호 37파일은 byte-exact, lifecycle은 `reference_only`, product consumer·
  dispatch 0, QA consumer 1이다. 메인 worktree의 기존 변경은 건드리지 않았고 전용
  `codex/story-map-240w` worktree에서 작업했다. R1b가 실제 ingress·GameState·save,
  R2가 M57~M60 transaction/finale를 별도 소유한다.

## 2026-08-18 (Codex — 마지막 해 두 reference 경로 exact 계약·감사)

- career·startup 신규 원고 32 roots·86 choices의 exact 배우, 문서 C0→C3·
  h0→h3, 월별 선택·여력, continuation/terminal/complete, future M59 거래와
  M60/final-week handoff를 `content/meta/year5_reference_routes.json`에 고정했다.
- 계약은 `reference_only`, 도달 주장 없음, runtime owner·consumer 0이다. 현재 없는
  M48 typed actor/margin, M53 만료 소유자, M56→M57 여력 생산자와 live ledger·router·
  save·성공 엔딩 유예를 blocker로 남겨 반쪽 구현을 제품 경로로 오인하지 않게 했다.
- 감사기는 보호 35파일·86 objects, 32 root 의미 digest, 20 terminal 전체 write,
  continuation-only producer graph, 직업 11종·배우·문서·원자 거래 위치를 강제한다.
  직접 감사 2/32/86/0, 음성 self-test 84건, story-map 차선 6/6, 독립 재현 18건,
  context·queue·scope·diff가 통과했고 P0/P1 0이다. runtime·save·story map·rules·
  events·endings·기존 원고는 바꾸지 않았으며 full audit·240주·Godot는 생략했다.

## 2026-08-18 (Codex — 창업 20%·32억원 staged 인수 세로줄 16개 L1/L2)

- 300만원 공동창업→지분 20%→기업가치 160억원→32억원 단일 엑싯 정본을 따라,
  비구속 인수의향서부터 공동창업자 이름 경계·민서 검토·네 사람 수정 지시·조건부
  seller 접수·실행·인수 뒤 첫 직무 충돌까지 신규 author-only 16 roots·43
  choices/locale로 완주했다.
- 세 안은 32억원을 고정하고 민준의 전환 12개월, 기존 서비스 12개월, 기명 팀 고용
  12개월 중 손실 주체만 바꾼다. reference는 민준 12개월 전환과 팀·서비스 12개월을
  남기고, 공동창업자는 `NOT USED`와 별도 seller page를 직접 확인·서명해 반송한다.
- M49 초기 7일과 M50 새 7일 수정창, M51 다음 달을 분리했다. M52의 지배 선택을
  전환근무표 질문으로 좁히고, 조건부 접수 h2와 32억원·20%가 한 번 움직이는 h3,
  두 사본 전달과 M60 책임 서명을 서로 다른 사건으로 유지했다.
- 선언 `a212882` 대비 기존 object drift 0, startup legacy·map·rules·runtime·35 endings·
  5 locale endings는 byte-exact다. exact 16/43, strict JSON, EN strict 1758/1758·35/35,
  서사·말투·random pool·story-map 76 self-test·context/queue·diff가 통과했고 독립 두
  낭독은 P0/P1 0 GO다. 전체·240주·Godot는 생략했다. L3는 사용자 무작위 3개이며,
  다음은 author-only 원고를 typed receipt와 exact selector에 이관하는 routing 배치다.

## 2026-08-18 (Codex — 마지막 해 career 실제 세로줄 16개 L1/L2)

- 현 팀장의 `신규사업 TF 책임자 발령·교육비 환수 부속합의 C0`에서 시작해 민서의
  검토, 현수 이름을 외부 수치 검토자 칸에서 제외하는 공개 약속, self-only C2 접수,
  C3 직책 실행, 마지막 책임 서명과 선발신까지 신규 author-only 16 roots·43
  choices/locale로 완주했다.
- C0의 월 책임수당 45만원·교육비 환수 600만원·15→5영업일 이름 대가가 C1의
  발령 지연/수당 30만원/예산 축소로 갈라진다. reference는 수당 30만원 C2만 이어
  `NOT USED`·`SELF ONLY` 접수, TF 준비비 30만원 입금, 새 배지 발급과 옛 배지
  반환 확인표를 C3에 남긴다. 공개 수정 지시와 접수, 실행과 사본 전달을 각각 별도
  장면·시각으로 분리했다.
- 독립 낭독에서 선택별 빈칸 상태 합침, 종이 수량, EN 동적 이름 소유격, C0~C3
  용어 drift, 선택 전 30만원 이동, 생산되지 않은 카페 시각을 찾아 교정했다. 현수는
  보호 보너스가 아니라 회계 직업의 책임을 잃는 당사자, 민서는 숫자·종료일 검토자,
  boss는 승인 기한의 상대라는 목소리를 유지했다.
- 선언 `9734831` 대비 기존 objects changed/removed 0, story map·story rules·35 endings·
  5 locale ending 파일 byte-exact다. exact 16/43, strict JSON, description 300~800,
  EN/i18n 1742/1742·35/35, 서사·말투, story-map normal·76 self-test, structured diff와
  diff-check가 통과했다. 독립 L2 P0/P1 0 GO이며 전체·240주·Godot는 생략했다.
  L3는 사용자 무작위 3개고, 다음은 즉시 32억원 exit 원고를 재사용하지 않는 startup
  실제 세로줄이다.

## 2026-08-18 (Codex — 마지막 해 두 세로줄 L1/L2)

- 지연·아버지 생존·제한 동의 명의·property 실행과 무연애·재혁 차단·다은 거절·
  자기 명의 접수·미실행을 M50부터 마지막 선발신까지 신규 author-only 24 roots·
  58 choices/locale로 이어 썼다. 보호 `arc_y5_people_verdict`까지 두 세로줄은
  25 incidents·61 choices다.
- A는 빈 종이와 회색 세 칸, 책임 상한·끝날짜, 제한 접수본, 실행 확인 원본·사본,
  지연 앞 열쇠와 선발신을 이어받는다. B는 다은 거절 원본, `해당 없음`·`사용하지 않음`,
  아버지 미연결 0초 합성 사진, 접수번호 227, 미실행 통지, 반환 준비 봉투와 현수
  선발신을 이어받는다. 각 downstream은 실제로 맞는 upstream choice 하나만 읽는다.
- 독립 두 낭독에서 미수신 메시지, 원본/사본 회귀, 선택 receipt 합침, 이름
  하드코딩, 민서 성씨, 계약 보고체를 찾아 물성으로 교정했다. 신규 24개 밖의 기존 사건
  294 objects와 35 endings·5 locale ending 파일은 선언 `a0da872`와 동일하다.
- exact 24/58, strict JSON, EN/i18n 1726/1726, 서사·말투, story-map normal·76 self-test,
  context/queue·diff가 통과했고 독립 L2는 P0/P1 0 GO다. 전체·240주·Godot는 생략했다.
  신규 원고는 후속 exact routing 전 reference-only이며 L3는 사용자 무작위 3개다.

## 2026-08-18 (Codex — M49~M60 마지막 해 기준 경로 20사건 L1/L2)

- 투자/property·상철 제안/검토·다은 보호·재혁 보증·아버지 별세/통화·자기 명의
  접수/실행을 한 기준 경로로 고정하고, 계약 원문 도착부터 마지막 주의 선발신까지
  신규 author-only 19 roots와 기존 `arc_final_week` 텍스트로 이어 썼다.
- 원문 전체 전달, 다은 이름 삭제본 공개, 진료실 수면/작업 기록, 재혁 PDF와 아버지
  보증 문서 대조, M55 자필 범위, 창구 227 접수, 실제 이체 확인서를 다음 장면이
  물건으로 이어받는다. `arc_final_week`는 무근거 수신과 배우별 말끝을 없애고 실제
  말을 주고받은 대화방에 플레이어가 먼저 행동을 남긴다.
- 상호배타 선택의 기록을 합치던 통화 질문·수면·파란 선, 보장되지 않은 다은의
  가게 폐점, 아버지 계약 보고체를 독립 낭독에서 찾아 공통 receipt로 낮췄다.
  보호 정점 16개와 조건부 지문·효과·플래그·비텍스트 구조는 불변이다.
- exact 20 roots·51 choices, strict JSON, EN/i18n 1702/1702, 서사·말투,
  story-map normal·76 self-test, context/queue·diff가 통과했다. 독립 L2 P0/P1 0이며
  전체·240주·Godot는 생략했다. 신규 19개는 후속 이관 전 reference-only이고,
  L3는 사용자 무작위 3개다.

## 2026-08-18 (Codex — M34 반복·계약 보고체·시계형 도입 문학 보정)

- M34의 여섯 terminal이 문자·음성·공식 통지의 같은 선택을 반복한다는 사용자 전달
  전수 낭독을 수용했다. 신고는 경찰 참고인 대기, 용서는 식은 커피의 첫 대면,
  이용은 소개자가 찍힌 우대 배지, 변제는 두 거래 날짜, 묻음은 명단 밖 좌석,
  단절은 현재 주소 관리실의 무표기 봉투로 다시 썼다. 각 장면은 새 결정을 묻지 않는
  1개의 진행 동작만 둔다.
- ‘답장을 사실로 만들지 않았다’처럼 작가 계약을 독자에게 보고하던 20문장을
  눌리지 않은 재생 삼각형·엎어진 휴대폰·빈 답장 칸·발신 시각 같은 물성으로 바꿨다.
  최초 19문장 집계 밖에 있던 `답은 보장되지 않았다` 한 줄도 독립 L2에서 찾아 제거했다.
- ORDER-106 신규 원고 중 숫자 시각으로 시작하던 9편은 첫 문장을 사람·냄새·종이·
  화면으로 열고, 비용 증거인 정확한 시각은 두 번째 문장에 모두 보존했다. 선택·결과·
  게임 구조와 M33/M39/M41/M42/M45/M46/M17/M19 정점 원고는 불변이다.
- exact 16 roots·대상 밖 drift 0, M34 6×1 choice, strict JSON, 한영 coverage·서사·
  말투·context/queue·diff가 통과했다. 독립 최신 낭독은 P0/P1 0이며, ORDER-107은
  보정 뒤 20 roots·48 choices/locale다. L3는 사용자 무작위 3개 판정으로 남는다.

## 2026-08-18 (Codex — M39~M48 실제 원고 25개 L1/L2)

- 네 번째 해의 세 약속·몸 목격·가족/연인 식탁·빌린 이름·청구서 밤·아버지
  연락·연말 결산을 기존 text-only 확장 5개와 author-only 신규 20개로 나눠
  KO/EN 25 roots·75 choices/locale로 썼다. 다은·지연·현수의 목소리와 장소를
  이름 치환이 아닌 별도 장면으로 만들었다.
- M39·M41·M42·M45·M46의 문학적 정점 원고는 보존했다. current actor/receipt만으로
  정직하게 결속되는 generic-safe 3개만 map에 남기고, Sangchul actor·M41 witness·
  father decision·M46 selected set 같은 복합 gate가 필요한 원고는 routed
  `NEW/planned` 뒤 reference-only로 격리했다. 원고가 있다는 이유로 도달을 주장하지 않는다.
- strict duplicate-key JSON, exact scope, 25/75 KO/EN, story-map normal·76 self-test,
  EN coverage, story consistency, speech register, queue/context, diff가 통과했다.
  독립 최신 낭독 P0/P1 0이다. `audit.py`의 author-only 미도달과 기존 전역 pacing/
  director baseline은 별도 라우팅 부채로 계속 RED이며 숨기지 않았다. L3는 사용자
  무작위 3개다.
- 후속 전수 낭독은 M34 여섯 terminal 반복, ORDER-107 계약 보고체, ORDER-106
  숫자 시각 도입을 문학 부채로 판정했다. 다음 별도 배치에서 고치며 M33/M39/M41/
  M42/M45/M46/M17/M19 정점 본문은 보존한다.

## 2026-08-18 (Codex — 원고 생명주기·번역 준비 정합 복구)

- M09·M20·M22·M25·M28·M30·M32·M35의 fallback 13개는 KO/EN 원고가
  이미 있는데 `NEW/planned`로 남아 있었다. 전부 `EXPAND/needs_rule`로 바로잡고,
  실제 원고가 생긴 focus fallback도 같은 생명주기 검사를 받도록 낡은 예외를
  제거했다. `story_map_audit` 일반 검사와 76개 변조 self-test가 통과한다.
- 이 검사를 사건 파일 변경 범위, 전체 로컬 감사, CI 조기 self-test에 모두 넣었다.
  사건 원고만 추가해도 60개월 지도의 원고 존재 상태를 검사하며, 검사 시간은
  일반 약 0.12초·self-test 약 0.9초다.
- M01~M06 수정 뒤 낡았던 데모 번역 source contract를 현재
  `72사건·467본문·701동적·4자산`으로 재수집했다. ORDER-107 영어 overlay 세
  root에 잘못 복제된 게임 메타데이터 27개를 제거해 전역 한영 coverage를 복구했다.
- `audit.py`는 라우팅 전 author-only 원고 58개를 실제 미도달 사건으로 계속
  거부한다. 이를 baseline이나 예외로 숨기지 않는다. 따라서 M01~M36은 원고
  L1/L2 후보이지 실행·L3·번역 확정본이 아니며, JA/ZH 본문 번역은 각 원고 배치의
  사용자 L3와 별도 번역 승인을 기다린다.

## 2026-08-18 (Codex — M25~M36 실제 원고 20개 L1/L2)

- 세 번째 해의 아버지 기록·재혁 피치·관계 이탈·상철 진실 후속·진실을 들은
  사람을 author-only 신규 20개·60선택/locale로 썼다. 기존 active 사건은 선언
  commit `28cfaa7`과 전체 object가 같으며, M30~M33의 강한 사기·추적·대면 장면을
  반복하지 않았다.
- 월초 commitment를 장면에서 다시 고르던 초안을 모두 반려했다. M25 문서 대조·
  아버지 연락, M26 생일 통화, M27 피치 질문, M28 세 사람 경로, M29 마지막 질문,
  M30 마지막 답, M32 상철 통보, M34 경계 통보는 세 선택 모두 이미 고른 행동을
  끝낸다. M35는 선택된 청자를 바꾸지 않고 들은 뒤의 말만 가른다.
- 하지 않은 송금·병실 도착·물리 원본·서류 반환·상철 답장을 산문이 대신 만들지
  않게 사본·현재 기록·미확인 반응으로 낮췄다. 다만 후속 전수 낭독에서 M34 여섯
  terminal이 여전히 문자/음성/공식 통지의 같은 뼈대를 반복한다고 판정됐다. 당시의
  ‘채널 버튼 복제가 아니다’라는 완료 보고는 철회하며 별도 재작성 대상으로 남긴다.
- exact 20 roots·60 choices/locale, KO/EN 300~800자, writer 0, strict JSON·한영·
  서사·말투·범위 계약과 diff가 통과했다. 독립 최신 바이트 판정 P0/P1 0이며 L3는
  사용자 무작위 3개다. 라우팅·UI·저장·밸런스·전체·240주·Godot는 생략했다.

## 2026-08-18 (Codex — M13~M24 실제 원고 24개 L1/L2)

- 두 번째 해의 압축 연쇄와 빈 경로를 기존 텍스트 확장 9개·author-only 신규
  15개로 나눠 KO/EN 집필했다. M14와 M21은 월간 행동 3개를 장면에서 다시 고르지
  않도록 선택된 commitment별 현장으로 분리했고, M20 네 문·M22 세 관계·M23 병실
  문·M24 receipt 결산은 실제 남은 사람·주소·시각·문서만 읽는다.
- 확인하면 기한을 놓치고, 기한을 지키면 출처가 비며, 이의를 남기면 일부 미납이
  남는 식으로 선택마다 현재 얻는 것과 즉시 잃는 것을 함께 회수했다. 부모 방문은
  발명한 저녁 약속 대신 9시 10분 귀가표 안에서 긴 저녁과 방 공개를 충돌시켰다.
- exact 24 roots·70 choices/locale, 기존 9개 구조 불변, 신규 15개 writer 0,
  strict JSON·한영·서사·말투·범위 계약과 diff가 통과했다. 독립 최신 바이트 판정은
  P0/P1 0이며 L3는 사용자 무작위 3개다. 전체·240주·Godot는 생략했다. 다음은
  M25~M36 실제 원고 20개다.

## 2026-08-18 (Codex — M02~M12 실제 원고 20개 L1/L2)

- 첫해의 빈 장면과 중복 첫 만남을 기존 텍스트 확장 7개·author-only 신규 13개로
  나눠 KO/EN 집필했다. M05 다은·지연 두 번째 만남, M06 첫 청구서, M08 이사,
  M09 네 관계 경로, M11 현재 일·상철·재혁·아무 문도 못 연 경로, M12 연말을
  서로 다른 실제 장소와 현재 손실로 만들었다.
- 선택하지 않은 근무·주소·영수증·통화·인물을 지문이 이미 일어난 일처럼 쓰지
  않도록 정확한 receipt 조건 또는 경로 중립 문장으로 고쳤다. 선택 전에 먼 보상은
  설명하지 않고, 선택 뒤에는 확보한 일과 잃은 시간처럼 즉시 생긴 한 가지 값을
  물건·행동으로 남겼다. 기존 7개 gameplay 구조와 신규 writer flag는 불변이다.
- 20/20 한영 선택·placeholder, strict JSON, coverage·서사·말투, 변경 범위와
  diff 검사가 통과했고 독립 최신 바이트 판정은 P0/P1 0이다. 전체·240주·Godot는
  생략했다. L3는 사용자 무작위 3개 낭독이며, 다음 집필은 M13~M24다.

## 2026-08-18 (Codex — 처음부터 완결까지 핵심 원고 1차 배치 L1/L2)

- M01 첫 불법 제안부터 M60 마지막 서명·후일담까지 22개 기준 장면과 미접수
  결말 1개를 KO/EN으로 썼다. Ch4는 다은·상철·아버지가 실제 같은 시간에
  충돌하고, Ch5는 상철의 제안·검토 이해충돌, 재혁의 보증, 다은의 이름을 한
  회의실에 모았다. 무연애 M58은 현수·민서의 서로 다른 판정으로 분리했다.
- 접수·미실행·미접수와 다른 배우 조합은 공용 가정문으로 덮지 않고 정확한
  기준 원고 또는 NEW fallback으로 나눴다. 기존 11개 root의 게임 구조와 장기
  결정 7개는 불변이고 신규 영구 flag는 0이다.
- 60개월 지도·자가 75건, narrative spine, 한영·말투·서사 정합, 정점 장면
  32개, strict JSON과 22+1 구조 계약이 통과했다. 전체/240주/Godot는 생략했다.
  L3는 사용자 무작위 3개 판정이며, 다음은 M02~M12 20개 원고다.

## 2026-08-15 (Codex — M01~M06 독립 월간 선택 체험판 L1/L2·스포일러 제거)

- 60개월 정본 중 첫 여섯 달만 읽는 독립 런타임과 화면을 만들었다. 플레이어는
  클릭 순서가 아니라 `주력` 하나와, 전월의 같은 축 여유가 있을 때만 가능한
  `함께` 하나를 명시한다. 미룸은 한 번 돌아온 뒤 만료되고, M03의 주력 인물은
  M05·M06까지 같은 사람으로 이어진다.
- 1차판의 `지키면/놓치면` 정확한 미래 설명은 사용자 판정으로 반려됐다. `.2`는
  선택 전에 행동·축·마감·한 번 미룸/그달 만료만 보여 주고, 이름 있는 사건·관계
  변화는 실제 도착할 때 밝힌다. 월 결과도 이미 일어난 지킴·미룸·만료만 확인한다.
- 전용 Godot 검사는 `STORY_MAP_M1M6_CHECK_OK months=6 margin=4 deferred=2
  actor=2 save=2 ui=1 disclosure=2`로 KO/EN 선택 전 노출도 함께 막는다. KO/EN
  960×600·1280×800 렌더와 M01→M06 완주를 확인했고 24주·240주 감사는 생략했다.
- 스포일러 제거 Apple Silicon 체험본은 28,796,088바이트, SHA-256
  `f324cac9dd7927abc9c7fbb8c07af65b2c5ea2ddb0bf5b9497c70953b4c7e37d`다.
  기계 GREEN은 재미 GO가 아니므로 ORDER-103은 사용자 정상 속도 판정까지 `[~]`다.
