# Active Queue Spec: ORDER-124

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-124 [P0·코어 표본] 월간 행동판 없이 스토리 선택만으로 M01~M06을 잇는다

**사용자 승인 (2026-08-24):** ORDER-103을 직접 플레이한 뒤 “게임스토리상에서
선택지로 충분해보여. 아예 매달 행동을 빼버릴까?”라고 판정했고, 제거 방향을
“응”으로 확정했다. 이는 카드 재배치 요청이 아니라 반복 월간 행동 계층의
제품 방향 NO-GO다.

## 깊이 3문

1. 지우면 플레이어가 매달 `주력/함께`와 여유를 관리하는 보드가 사라진다.
   대신 눈앞의 인물·돈·몸 사이에서 실제 행동을 고르는 StoryMode 장면이 같은
   선택 소유권을 가져야 한다.
2. 시간과 경제까지 지우면 인터랙티브 드라마의 선택이 생활과 분리된다. 네 주와
   월세·수입·몸·마음 압박은 장면이 끝날 때 자동으로 흐르고, 다음 장면이 그
   상태를 읽는다.
3. 제품 기본 진입을 곧바로 갈아엎으면 재미 판정과 이관 결함을 구분할 수 없다.
   첫 여섯 달을 별도 장면·별도 저장·별도 macOS 후보로 만들고 사용자 L3 뒤에만
   본편 진입 이관을 새 오더로 연다.

## 배치 A — 스토리 선택 전용 M01~M06 표본 12단위

1. 시작·이어하기 외 플레이어 입력은 실제 `StoryMode`의 선택과 문장 넘기기만
   허용한다.
2. `주력`, `함께`, `여력`, 행동 카드, 월간 후보 선택, 확인 제출 화면을 만들거나
   이름을 바꿔 되살리지 않는다.
3. M01은 `arc_temptation_01`, M02는 그 선택에 따라
   `arc_temptation_clean` 또는 `arc_temptation_fallout`을 재생한다.
4. M03은 `arc_daeun_01_meet`와 `arc_jiyeon_01_crash`를 같은 달의 두 생활
   장면으로 이어 실제 대화 선택을 적용한다.
5. M04는 `arc_sangchul_01_meet` 뒤 실제 follow-up인
   `arc_sangchul_01_measure` 또는 `arc_sangchul_01_coffee`, 이어
   `arc_sangchul_01_answer`까지 같은 달에 재생하고, M05는
   `arc_jaehyuk_01_reunion`을 재생한다.
6. M06은 기존 첫 청구서의 현재 언어 선택·결과 산문을 재사용하되, 구 월간
   의무 영수증과 동적 후보 계약 없이 지금 만난 사람·일·몸 중 하나를 고르는
   이 후보 전용 사건 사본으로 재생한다.
7. 각 달의 마지막 StoryMode가 끝나면 정확히 네 주를 자동 진행하고 월세·수입·
   대출이자·몸·마음 압박을 `GameState` 정본으로 한 번 정산한다.
8. 달 사이 표면은 지난 정산과 다음 장면 제목을 읽는 전환막일 뿐 선택지나
   최적화 정보가 아니다.
9. 스토리 선택의 기존 효과·플래그·인물 관계·후속 사건은 `GameState.apply_choice`
   경로를 그대로 사용한다.
10. M01 선택이 M02 사건을 바꾸고, M03~M05에서 만난 사람이 M06 선택 후보로
    돌아오는 것을 한 런 안에서 확인한다.
11. 후보 전용 JSON 하나가 장면 사이 진행과 전체 `GameState`를 저장한다. 장면 중
    수동 저장은 같은 전용 사용자 디렉터리의 기존 StoryMode 저장 기능을 쓴다.
12. M06 뒤에는 월간 약속 원장이 아니라 여섯 달 동안 실제로 고른 장면 선택과
    최종 현금·몸·마음을 짧게 보여 준다.

## 배치 B — 격리 macOS 후보와 판정 8단위

1. 앱 이름은 `GangnamDream-ORDER124-M01M06-StoryChoicePlaytest`, BUILD는
   `2026.08.24.3`, 후보 키는 `order124_rc`로 고정한다.
2. Finder 무인자 실행은 Splash·StartMenu·MainGame·ORDER-103 선택판을 거치지
   않고 새 전용 홈으로 직접 들어간다.
3. staging에서만 `run/main_scene`과 custom user-data 이름을 덮고 제품
   `project.godot`·`export_presets.cfg`는 byte-exact로 둔다.
4. clean source commit/tree, Godot 버전, 진입 장면, 앱·launcher·PCK·ZIP 해시와
   생성 시각을 매니페스트에 고정한다.
5. KO/EN, 960×600·1280×800, 마우스·키보드·패드 의미 입력에서 홈·전환막·
   StoryMode 선택·회고의 잘림과 막힘을 확인한다.
6. 새 시작, M02 분기, 장면 사이 자동저장, 앱 재실행 이어하기, M06 완주를
   패키지에서 확인한다.
7. 기존 retail/V2 저장, `demo_rc`, 반려 `order103_rc` 산출물과 제품 설정의
   전후 SHA-256이 같아야 한다.
8. L1/L2가 끝나면 `order124_rc`만 active로 등록하고 사용자 L3를 연다.

## 제품·설계 경계

- `content/meta/story_map.json`의 월간 commitment는 삭제하지 않고 이번 표본에서
  읽지 않는 작가용 역사 입력으로 동결한다. 새 제품 소비자를 추가하지 않는다.
- `systems/StoryMapMonthlyRuntime.gd`, `tools/StoryMapM1M6Playtest*`, ORDER-103
  wrapper와 BUILD `2026.08.24.1`은 반려 증거로 byte-exact 보존한다.
- 제품 `StartMenu`, `MainGame`, `StoryMode`, `GameState`, `SaveManager`,
  `DemoCoreLoopV2`, `project.godot`, `export_presets.cfg`는 수정하지 않는다.
- 본편의 반복 월간·주간 행동 진입을 제거하는 제품 이관은 이 표본의 사용자 GO
  뒤 별도 오더다. 이번 오더는 그 결정을 실제 플레이로 검증한다.
- 기존 `demo_rc`와 retail/V2 저장은 읽거나 덮어쓰지 않는다.

## 정확한 파일 소유권

**선언·마감:** `docs/CODEX_QUEUE.md`, 이 사양,
`docs/queue_archive/ORDER-103.md`, `docs/queue_archive/CODEX_QUEUE_2026-08.md`,
`CLAUDE.md`, `docs/DECISIONS.md`, `docs/CHOICE_CONSEQUENCE_SYSTEM.md`,
`docs/DEMO_FIXLOG.md`, `docs/WORK_LOG.md`, `docs/BUILD_PIPELINE.md`,
`docs/human_gates.json`, 생성본 `docs/STATUS.md`.

**독립 플레이 표면:** `playtests/order124/StoryChoiceM1M6Playtest.gd`와 `.gd.uid`,
`playtests/order124/StoryChoiceM1M6Playtest.tscn`.

**표적 검사·패키지:** `tools/StoryChoiceM1M6Check.gd`와 `.gd.uid`,
`tools/StoryChoiceM1M6Check.tscn`, `tools/build_order124_macos.sh`,
`tools/order124_package_audit.py`, `tools/audit_scope.json`.

위에 적지 않은 제품·사건·저장·빌드 파일은 수정하지 않는다.

## 완료 증거

- M01의 두 선택 각각이 M02 clean/fallout으로 갈리고 효과가 정확히 한 번만
  적용된다.
- 여섯 달의 StoryMode 큐를 완주하면 시간은 24주, 월간 정산은 6회이고 월간
  행동 선택·commitment 영수증은 0이다.
- M03~M05에서 만난 인물과 실제 선택 결과가 M06 후보·회고에 남는다.
- 장면 전후 저장 왕복은 같은 달을 중복 정산하지 않고 기존 저장은 byte-exact다.
- M01 뒤 전환막과 M06 뒤 회고로 복귀할 때 검은 cover와 입력 차단이
  모두 풀리며, 정산 실패는 빈 화면 대신 남은 장면 재개 또는 홈으로 복구한다.
- KO/EN 두 해상도에서 `주력/함께/여력`과 행동판 UI 노출 0, 잘림·겹침 0이다.
- 표적 Godot 검사와 package audit만 실행한다. 기존 24주·240주·전체 감사는 이
  격리 후보의 증거로 실행하거나 인용하지 않는다.

## 사람 판정

기계 GREEN은 재미 GO가 아니다. 사용자가 여섯 달을 정상 속도로 플레이한 뒤
`월간 행동판이 없어도 선택하고 있다는 감각이 있는가`, `장면 사이 시간이 너무
빨리 또는 느리게 흐르는가`, `M01 선택의 M02 대가와 M06의 한 가지 포기가
자연스럽게 읽히는가`, `이 구조로 본편을 바꿔도 되는가`를 판정한다. 그 전에는
제품 기본 진입을 전환하지 않는다.

## 규범 판정

사용자가 승인한 “반복 월간 행동은 제거하고 실제 스토리 선택이 행동을 소유한다”는
제품 방향은 `docs/CHOICE_CONSEQUENCE_SYSTEM.md`에 승격한다. 후보 이름·BUILD·
격리 저장·검사 명령은 이 오더에서만 유효한 일회성 지시다.

## BUILD 2026.08.24.2 · 검은 전환막 NO-GO와 보존

- BUILD `2026.08.24.2`는 exact source
  `e9aff5f06c2e3ec3708426156074674a56a4c3f6`, tree
  `ad4d88a6aed68a79074f6f8e3204bf0474f6dbc4`, manifest
  `87f3491f7e526762203a83eb4ed25bbbba79981f7dc3ec812d49cdd955db1194`, ZIP
  `626196d6a74f50373ddc3e6d0cb8b3a502f052d4436f308361d8b82d3ab45a75`, app tree
  `c21d5ba71c5516465849cc7596d48ed430a4fc903eeeb7033340d36e5afb6a85`다.
- 사용자는 M02 뒤 장면 사이에 검은 화면을 발견했다. `StoryMode`가
  `SceneTransition.go()`로 복귀하며 만든 opaque cover를 후보 controller가
  fade-in하지 않아, 6초 전환 카드가 검정 뒤에 숨고 M06 회고는 영구히
  가려질 수 있었다. 기존 검사는 실제 StoryMode 복귀를 건너뛰 이 결함을
  잡지 못했다.
- 이 BUILD는 기술 NO-GO로 active 후보에서 내렸다. 앱 사본을 새 플레이에
  쓰지 않고, manifest/checksum/ZIP을
  `build/order124/archive/2026.08.24.2`에 비교 근거로 보존한다. 이 판정은
  AP 행동의 복원 GO나 스토리 선택 구조의 재미 GO가 아니다.

## BUILD 2026.08.24.3 · 현재 macOS 후보 · 사용자 판정 OPEN

- active `order124_rc`는
  `GangnamDream-ORDER124-M01M06-StoryChoicePlaytest`, BUILD
  `2026.08.24.3`다. exact source는
  `23f0bd9b7a56a352c9234f95870a98dbf5c728e9`, tree는
  `2dcfb0e465f2981b8058ccc03605fa98fca3f746`다.
- manifest SHA-256은
  `721c9021236c158432be0b3ae47ebcd785f4e4f461b4b05d709b0d71384ca148`, ZIP은
  `b66d72ce97f1d36e7902ccc79a1062e61e6627aa4aa12cdea5eb84f53c362431`, app tree는
  `275f536ad1cf70b138ecda1350ef539fd20de43c904796fe59bada0ff3f194ee`다.
- 표적 marker
  `STORY_CHOICE_M1M6_CHECK_OK months=6 weeks=24 settlements=6 commitments=0 routes=2 save=1 m6=1 returns=2 overlay=1`가 M01 전환과 M06 회고의 실제
  복귀 표면을 둘 다 검사했다. 패키지 M01 복귀는
  `ORDER124_RETURN_SMOKE_OK build=2026.08.24.3 screen=transition month=2 overlay=clear input=clear choices=1 settlements=1`을 남겼다. package self-test
  `checks=38`과 `ORDER124_PACKAGE_AUDIT_OK`도 통과했다.
- BUILD `.2`에서 생긴 사용자 저장 SHA-256
  `fe1d0a0011a1a8d447ce7d46494f2454b3b09ee7c8e2f6596d827a6cd8db734b`는
  `phase=story`, M03, 8주, 정산 2회, 선택 2개다. 최종 패키지가 이 저장을
  변경하지 않고
  `ORDER124_RESUME_SMOKE_OK build=2026.08.24.3 month=3 weeks=8 settlements=2 choices=2 phase=story screen=transition overlay=clear input=clear`로 이어하는 것을 확인했다.
- 제품 `project.godot`·`export_presets.cfg`, retail/V2, `demo_rc`, 반려
  ORDER-103 앱·저장·산출물, BUILD `.2` archive, ORDER-124 사용자
  디렉터리는 패키지 검사 전후 byte-exact다.
- L1/L2는 닫혔지만 재미 판정은 아니다. 사용자 L3와 본편 이관 GO는
  OPEN/HOLD이며 ORDER-124는 `[~]`를 유지한다. 기존 24주·240주·전체 감사는
  이 격리 후보에 실행하거나 인용하지 않았다.
