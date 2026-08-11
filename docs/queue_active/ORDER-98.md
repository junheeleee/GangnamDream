# Active Queue Spec: ORDER-98

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-98 [P1·패드 UX] PAD-1 — 포커스 레일을 의미 버튼으로 줄인다

**사용자 지시 (2026-08-11):** 패드 조작을 포커스 이동만으로 해결하지 않는다.
D-pad, ABXY의 네 물리 위치, L1/R1, L2/R2를 화면의 의미에 맞게 분담한다.
모든 버튼을 억지로 채우는 것이 아니라, 반복 행동과 탭·페이지·큰 단위 조작을
긴 포커스 레일에서 꺼내 직접 입력으로 만든다.

현재 정본은 이미 `Focus routing is a fallback safety net. It is not the design.`을
요구하지만 실제 공용 입력에는 L2/R2가 없다. L1/R1은 플래너·연락폰·아카이브의
탭을 바꾸는 동시에 일부 카지노 준비 단계에서는 베팅액까지 바꾼다. 자동화는
도달성과 여러 직접 게임을 증명하지만, 이 의미 충돌과 trigger 입력의 edge·글리프·
물리 감각은 증명하지 않는다.

## 깊이 3문

1. 지우면 마우스 버튼을 D-pad로 하나씩 훑는 UI를 계속 `Full Controller` 후보로
   오인하고, 플레이어는 선택보다 조작 위치를 기억하는 데 주의를 쓴다.
2. 게임 결과·확률·수치·세이브·선택지는 바꾸지 않는다. 같은 화면 행동을 더 짧고
   일관된 의미 입력으로 부르며, 기존 South/East 안전 경계는 그대로 둔다.
3. L1/R1과 L2/R2를 단순 별칭으로 중복하지 않는다. sibling group/tab과
   page/coarse adjustment를 분리하고, trigger 한 번은 release 뒤 정확 한 번만
   반응하며 확정·구매·삭제·종료를 직접 실행하지 못하게 한다.

## 전역 의미 계약

| 물리 입력 | 기본 의미 |
|---|---|
| D-pad / Left stick | 현재 그룹 안의 세부 선택 이동 |
| South | 강조된 선택 확인·실행 |
| East | 취소·뒤로·미확정 상태 해제 |
| West | 제거·변경·clear/repeat 같은 문맥 보조 행동 |
| North | 상세·규칙·명시된 화면 도구 |
| L1/R1 | 같은 계층의 이전/다음 탭·그룹·행동군 |
| L2/R2 | 이전/다음 페이지 또는 큰 단위 값 감소/증가 |
| Menu | 시스템 설정 |

- 이 표는 모든 화면이 모든 키를 써야 한다는 뜻이 아니다. 페이지나 큰 값이 없는
  서울 배치 보드처럼 South/East와 지역 D-pad만으로 충분한 화면에는 가짜 기능을
  만들지 않는다.
- L2/R2는 페이지 이동 또는 베팅액·바이인 같은 reversible coarse adjustment만
  소유한다. 확정, 저장, 불러오기, 구매, 배치 commit, 주·달 진행, 종료는 금지한다.
- Story의 North=AUTO처럼 전역 기본과 다른 기존 도구는 화면에 항상 현재 글리프와
  동사를 보이고, 선택·상세와 충돌하지 않는지 별도 표본으로 판정한다.
- 표시 글리프는 Xbox/Steam Deck `LT/RT`, PlayStation `L2/R2`, Nintendo
  `ZL/ZR`를 `ControllerHints`가 소유한다. 키보드 대응은 PageUp/PageDown이다.
- analog trigger는 threshold와 release gate를 가진다. 한 번 누른 상태의 흔들림이나
  Steam Input 재보고가 페이지·금액을 여러 번 바꾸면 실패다.

## 연출·진동 참조 경계

컨트롤러 진동은 입력 성공을 매번 확인하는 클릭음의 복제물이 아니라, 화면·소리와
함께 한 사건의 무게를 닫는 연출 층이다. 공식 개발자 설명에서 다음 구조만 빌린다.

- **[Hades](https://blog.playstation.com/?p=350240):** 케르베로스를 쓰다듬는 관계 행동과 동료 도움 도착처럼 드문 문맥마다
  다른 촉각을 둔다. 강남드림은 사람의 전화 도착, 되돌릴 수 없는 선택 확정,
  도움·위기 도착처럼 이름 있는 순간만 pulse owner로 삼는다.
- **[Astro's Playroom](https://blog.playstation.com/?p=343436) /
  [Astro Bot](https://blog.playstation.com/2024/07/29/first-look-astro-bot-limited-edition-dualsense-wireless-controller/):**
  표면·능력마다 일관된 촉각 서명을 둔다.
  강남드림은 돈 손실·성공·위험·관계 commit의 profile을 장면마다 임의 숫자로
  다시 만들지 않는다. 상시 지면 질감과 모든 UI 이동의 진동량은 가져오지 않는다.
- **[The Last of Us Part II](https://store.playstation.com/en-us/concept/230079/):**
  진동 단서를 시각·오디오와 함께 제공하고 완전히 끌 수
  있게 한다. 진동만으로 결과·위험·방향을 전달하지 않으며 off/0%에서도 같은
  선택과 정보를 얻는다.

현재 `AudioManager.play_ui_click()`은 일반 이동에서도 작은 pulse를 호출한다.
포커스·hover·탭·페이지·일반 대사 진행·값 미리보기는 무진동으로 고치고, 실제
성공한 의미 commit 뒤에만 중앙 profile owner가 한 번 울리게 한다. 실패·disabled
입력, trigger로 값만 둘러보기, 자동 진행에는 pulse가 없어야 한다.

## 두 배치

### 배치 A — 페이지·그룹·화면 도구 15단위

1. 공용 `previous/next major` action과 세 브랜드 trigger 글리프
2. title load 슬롯 1–5 / 6–10 페이지
3. archive의 L1/R1 탭과 L2/R2 페이지 분리
4. Story 저장·불러오기 슬롯 페이지
5. 24주 완료의 여섯 달+미해결 페이지
6. MainGame 수동 저장·불러오기 슬롯 페이지
7. MainGame 엔딩의 순차 페이지
8. MainGame 정보·사람·직업·투자 탭의 기존 L1/R1 의미 고정
9. legacy planner의 L1/R1 workflow와 West 제거
10. 연락폰의 North 열기·L1/R1 탭·East 한 단계 뒤로
11. 서울 배치 보드의 지역 D-pad·South 선택/확정·East 취소와 trigger 무행동
12. Story의 West 기록·North AUTO·Menu 설정 충돌 방지와 장면 설정의 진동
    on/off·강도 즉시 적용
13. trigger 한 번당 한 변화·release 전 재입력 0
14. 모달 뒤 입력 누수·숨은 commit·focus theft 0
15. Xbox/PlayStation/Nintendo·키보드 힌트와 실제 action 일치

### 배치 B — 직접 게임·큰 단위 조절·촉각 연출 15단위

1–8. Blackjack, Baccarat, Slots, Roulette, Big Wheel, Dai Sai, Holdem,
RaceTrack의 L2/R2 베팅액 또는 바이인 감소/증가
9. L1/R1은 각 게임의 bet type/mode/action group이 있을 때만 그 그룹을 이동
10. West의 기존 문맥 보조 행동과 trigger의 양방향 값 조절을 구분
11. North 규칙, South 실행, East pending clear→exit 안전 순서
12. 처리 불가 phase에서 trigger는 상태·돈·라운드·focus를 바꾸지 않음
13. 포커스·탭·페이지·일반 대사·값 변경은 무진동, 성공한 의미 commit만 1 pulse
14. title/MainGame/Story 설정의 vibration off/0%·강도 배율·즉시 stop,
    시각/오디오 중복과 실제 화면 힌트
15. 정상 속도 물리 패드 표본에서 오입력·버튼 탐색·긴 포커스 왕복·진동 피로 기록

## 정확한 파일 소유권

**제품·입력·촉각·후보 식별 18:** `project.godot`,
`steam_input/game_actions_gangnam_dream.vdf`, `autoloads/ControllerHints.gd`,
`autoloads/AudioManager.gd`,
`systems/BuildInfo.gd`,
`scenes/StartMenu.gd`, `scenes/StoryMode.gd`, `scenes/MainGame.gd`,
`scenes/CoreLoopV2Completion.gd`, `scenes/TutorialOverlay.gd`,
`scenes/BlackjackTable.gd`,
`scenes/BaccaratTable.gd`, `scenes/SlotMachineGame.gd`,
`scenes/RouletteTable.gd`, `scenes/BigWheelGame.gd`, `scenes/DaiSaiTable.gd`,
`scenes/HoldemClub.gd`, `scenes/RaceTrack.gd`.

**감사·QA 8:** `tools/InputMatrixCheck.gd`, `tools/GameAudioContractCheck.gd`,
`tools/ScreenshotQA.gd`,
신규 `tools/ControllerSemanticCheck.gd`, `.gd.uid`, `.tscn`,
`tools/audit.sh`, `tools/audit_scope.json`.

**지속 정본·사람 게이트 6:** `docs/CONTROLLER_UX_STRATEGY.md`,
`docs/INPUT_MATRIX.md`, `docs/AUDIO_QA.md`, `docs/SCENE_DIRECTION.md`,
`docs/QA_CHECKLIST.md`, `docs/human_gates.json`.
선언·완료 기록은 `docs/CODEX_QUEUE.md`, 이 사양, `CLAUDE.md`, 완료 뒤
`docs/WORK_LOG.md`, 8월 큐 archive와 생성 `docs/STATUS.md`만 만진다.
체크포인트 기록으로 `WORK_LOG.md`가 40KB 부팅 예산을 넘으면 가장 오래된
2026-08-03 원문만 `docs/history/WORK_LOG_2026-08-03.md`로 보관한다.

**감사에서 추가된 정적 UI 현지화 7:**
`content/meta/demo_localization_scope.json`, `locale/ui_ja.json`,
`tools/ja_translation_pipeline.py`, `docs/I18N_INFRASTRUCTURE.md`,
`docs/I18N_GLOSSARY_JA.md`, `docs/I18N_GLOSSARY_ZH.md`, `docs/MODDING.md`.
L2/R2의 실제 감소·증가 동사, 페이지, 진동 설정 설명이 새 사용자 표시 문자열을
만들었으므로 일본어 정적 UI 행과 현재 원장만 함께 이동한다. ORDER-96/97 당시의
역사적 3,254/3,217/2,730 및 3,310/3,273/2,780 기록은 덮어쓰지 않고, 현재
ORDER-98 관측값을 별도 snapshot으로 보존한다. 중국어 본문·정적 번역과
`--allow-body`, 준비언어 shipping 상태는 계속 비범위다.

`CoreLoopPlanner`, `CommunicationPhone`, `SeoulCycleBoard`, `CommitmentTask`,
`JeongseonCasino`는 현재 의미 분배를 읽기·실행 회귀 대상으로 삼되, 감사에서 실제
결함이 나오지 않으면 제품 파일을 편의상 수정하지 않는다. 소유권 추가가 필요하면
구체 결함과 파일을 이 사양에 먼저 적고 선언 delta를 분리한다.

구현 교차감사에서 신규 major previous/next가 Godot InputMap에는 있으나 Steam Input
action manifest에는 없어 사용자 remap 표면에서 두 의미 행동이 사라지는 결함을
확인했다. 위 manifest를 제품 소유권에 추가하고 Menu/Story/Life/Minigame 네 action
set 모두에 같은 두 행동을 선언한다.

최종 독립 검토에서는 직접 게임의 첫 진입·규칙 `TutorialOverlay`가 L1/R1만
소비하고 신규 trigger press/release를 뒤의 게임 `_unhandled_input`으로 흘려
베팅액·바이인을 바꾸는 모달 누수를 확인했다. 위 오버레이를 제품 소유권에
추가하고, 공용 trigger latch는 계속 갱신하되 8게임 모두 모달이 열린 동안 값·돈·
라운드·focus 변화 0을 raw 입력으로 증명한다.

전체 감사에서는 위 신규 힌트·설정 copy 때문에 source UI가
`3,313 = legacy 3,276 + context 37`, legacy key 2,782로 이동했지만 JA 사전과
manifest가 ORDER-97의 3,310/3,273/2,780에 머문 것을 확인했다. 위 7파일을
추가 소유권으로 먼저 선언한 뒤, 낡은 패드 힌트 8행을 현재 힌트로 교체하고
새 정적 UI 3행을 더해 JA `2,782/2,782 + context 30/30`을 복구한다.

오늘 집 테스트에 넘길 clean 후보가 직전 `2026.08.11.1` 패키지와 같은 화면·
저장 메타 식별자를 재사용하지 않도록 `BuildInfo.BUILD_ID`를
`2026.08.11.2`로 발급한다. 이 변경은 게임 규칙이나 저장 호환 키가 아니라
패키지 provenance이며, 최종 입력·표면 매트릭스와 빌드 매니페스트는 이 식별자를
포함한 같은 clean revision에 묶는다.

## 비범위

- 게임 효과·확률·베팅 옵션·수치·저장 schema·스토리·카피 변경
- adaptive-trigger 장력, controller speaker, 특정 제조사 전용 필수 정보
- 한 버튼 chord, 길게 누르기 필수, analog 압력으로 값 자체를 결정하는 입력
- focus 표시·전체 UI 재배치·카드 디자인·BODY/MIND 게이지
- 마우스·키보드 기능 제거, Steam Input 사용자 remap 차단
- 물리 Deck/DualSense/Switch Pro 사람 판정을 자동 PASS로 대체

## 검증·완료 조건

- InputMap은 기존 10 semantic action과 신규 major previous/next를 exact하게
  보유하며 세 브랜드 trigger 글리프와 PageUp/PageDown 대응을 증명한다.
- 배치 A 15단위와 배치 B 15단위를 raw key/button/axis press→release로 실행한다.
  직접 메서드 호출, `pressed.emit()`, semantic event만 주입한 검사는 대체 증거가
  아니다.
- trigger held/jitter/release, disabled phase, modal capture, destructive-action 0,
  focus restoration, 현재 device 힌트를 표적 검사한다.
- vibration callsite를 `navigation/focus`, `semantic commit`, `danger`, `result`,
  `physical beat`로 전수 분류한다. navigation/focus pulse 0, 임의 raw 숫자 profile 0,
  disabled/failed action pulse 0, off/0% 실제 출력 0을 강제한다.
- 기존 KO/EN 24주 keyboard/gamepad full-matrix와 surface-matrix, 9 direct scenes,
  18 secondary routes, 960×600/1280×800를 같은 최종 revision에서 재실행한다.
- L2/R2 추가 뒤에도 South/East/West/North와 L1/R1의 기존 안전 의미, 돈·라운드·
  선택 결과, mouse/keyboard 패리티가 유지된다.
- L2는 값을 감소·이전, R2는 증가·다음으로 읽혀야 하며 반대로 느껴지는 한 화면도
  있으면 해당 배치를 전량 반려한다.
- L3는 clean active `demo_rc`에서 배치 A 임의 3표면과 배치 B 임의 3게임을 실제
  패드로 정상 속도 수행한다. 버튼 안내를 읽고도 첫 시도에 찾지 못한 행동,
  12회 초과 focus 왕복, 오입력, 잘못된 trigger 방향이 하나라도 있으면 해당 배치
  전량을 다시 연다. 같은 30분 구간에서 일상 진동이 거슬리거나 의미 pulse를 서로
  구별하지 못하거나 off 상태에서 한 번이라도 울리면 촉각 배치도 전량 다시 연다.

## 2026-08-11 구현 체크포인트 — L1/L2 완료, L3 OPEN

- 공용 trigger action·세 브랜드 글리프·press/release/reconnect gate와 title,
  Story, MainGame, 완료 화면의 페이지·설정·포커스 복귀를 구현했다. 8개 직접
  게임은 L2 감소/R2 증가를 경계에서 멈추며, 비활성 phase와 모달 뒤 상태 변화는
  0이다.
- 일반 UI 탐색 진동을 제거하고, scene raw pulse 0·사용 중인 중앙 profile 12개·
  동시 stack 중복 0·OFF/0% 즉시 정지를 잠갔다. 현재 UI 원장은
  `3,313 = legacy 3,276 + context 37`, legacy 2,782키이며 JA는
  `2,782/2,782 + context 30/30`이다.
- L1/L2 증거: `CONTROLLER_SEMANTIC_CHECK_OK ... reconnect_gate=2 ...`,
  `INPUT_MATRIX_CHECK_OK ... major_routes=8 modal_routes=8 boundary_routes=16
  invalid_routes=8 ...`, `GAME_AUDIO_RUNTIME_OK ... haptics=12
  unused_profiles=0 direct_scene_raw=0 vibration_roundtrip=1 boundary_clamp=8
  same_stack=3`, 전체 `audit.sh`, KO/EN×keyboard/gamepad 24주 4경로와
  KO/EN×1280×800/960×600 4표면을 빌드 식별자를 포함한 같은 최종 revision에서
  다시 봉인했다.
- **L3 OPEN:** clean `demo_rc`는 commit `5736061916626a193dab4fd044ef44813938c4f7`,
  tree `c996b98369fe9df6eeb2a76b04a306b69d218e04`, manifest SHA-256
  `9cecaede2e51fd4401d336c0567dc86e96c862767cf134e0cb82c2174380fb56`로
  발급했다. macOS 패키지는 타이틀·24주 시작·설정 진입까지 실제 실행했고,
  Windows와 Linux/Steam Deck는 산출물 생성만 확인했다. 사용자가 집에서 서울
  보드를 처음 정상 속도로 플레이하고 Batch A 임의 3표면과 Batch B 임의 3게임의
  물리 패드 방향·도달성·진동 피로를 판정하기 전에는 이 오더를 `[x]`로 닫거나
  자동 증거를 재미 GO로 부르지 않는다.
- **승격:** `docs/CONTROLLER_UX_STRATEGY.md`, `docs/INPUT_MATRIX.md`,
  `docs/AUDIO_QA.md`, `docs/SCENE_DIRECTION.md`, `docs/QA_CHECKLIST.md`,
  `docs/human_gates.json`, 현지화 정본 4문서와 manifest/JA 사전.
- **일회성:** 정확 파일 소유권, 두 15단위 배치 목록, 변경 revision의 수치 원장,
  검사 명령·로그·패키지 식별자 발급 절차.
