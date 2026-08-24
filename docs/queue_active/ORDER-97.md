# Active Queue Spec: ORDER-97

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-97 [P1·현지화 기반] LOC-0.5 — 값을 끼우기 전에 UI 템플릿을 번역한다

**선행 조건 완료 (2026-08-11):** `ORDER-96`은 한국어 legacy UI 2,730키를
보존하면서 30개 문맥 ID·37개 제품 호출을 구현하고 기술 검증을 닫았다. 일본어
원어민·출시 판정은 사람 게이트로 계속 OPEN이다. 이 오더는 그 문맥 ID를 다시
설계하지 않고, 실제 JA 화면에서 드러난 포맷 순서 결함만 본문 번역 전에 고친다.

현재 `LocaleManager.ui()`·`_tr()` 호출 중 일부는 `"%d주" % week`처럼 값을 먼저
끼운 뒤 완성 문자열을 번역 key로 넘긴다. 사전에는 안정 템플릿만 둘 수 있으므로
JA/ZH가 해당 key를 가질 수 없고 EN fallback이 영구적으로 남는다. 실제 서울
보드는 일본어에서도 `2026.01 · WEEK 1`, `MONTHLY CAPACITY LEFT`,
`498,800 won`을 보였으며, 현재 ScreenshotQA도 같은 miss를 정답으로 승인한다.

## 깊이 3문

1. 지우면 현재 본문 467개와 동적 701키를 전부 번역해도 포맷이 먼저 끝난 UI는 사전
   key와 절대 일치하지 않아 JA/ZH 표면에 영어가 남는다.
2. 플레이 선택·세이브·수치·카피는 바꾸지 않는다. lookup → format 순서만
   고치고 KO/EN 최종 문자열은 byte-for-byte 그대로 보존한다.
3. 준비 언어가 번역 행을 찾았을 때와 EN fallback을 쓸 때 필요한 인자 표면이
   다를 수 있다. 각 호출이 임의 분기를 만들지 않고 한 API가 lookup provenance,
   placeholder, KO/EN 인자 선택과 miss를 소유해야 community pack도 보존된다.

## 고정 전수 원장과 두 배치

착수 실측과 현재 active 후보의 raw registry는 55개를 정확히 다음 네 종류로
분류한다. 한때 별도 호출로 셌던 W1 지원서 완료 표면은 ORDER-119 결과 산문 통합에서
정적 관찰 문장으로 바뀌었으므로 삭제된 `ui_format` 호출을 현재 분모에 남기지 않는다.

- **이동 47호출 / 42템플릿:** lookup 전에 값을 끼우는 player-facing UI.
- **동적 pair reader 4:** 이미 별도 KO/EN 데이터의 완성값을 읽으므로 이동 금지.
- **branch-selected literal 2:** 분기 뒤 정적 문자열을 고르며 preformat 결함이 아님.
- **locale money formatter 2:** `SeoulCycleBoard::_format_money`와
  `CommitmentTask::_format_money`은 47개 template 호출에 섞지 않고, 정확한
  1원 단위·부호·쉼표를 보존하는 LocaleManager 소유 formatter 하나로 합친다.

47호출의 파일별 정확한 수는 `GameState 4 + MainGame 1 +
CommunicationPhone 3 + ArubaGame 1 + StartMenu 16 + StoryMode 7 +
SeoulCycleBoard 2 + CoreLoopPlanner 13 = 47`이다. Batch A의 첫 단위는
manifest에 path·함수·KO/EN 템플릿·placeholder signature·count와 위 55개
전수 disposition을 exact registry로 먼저 기록한다. 그 registry가 완성되기 전에는
제품 호출을 옮기지 않는다. unclassified·duplicate·stale·편의상 추가한 호출은 실패다.

- **배치 A 23단위:** `StartMenu 16 + StoryMode 7`. 시작·기록·설정·장면 표면을
  실제 gallery/story 화면과 함께 닫는다.
- **배치 B 24단위:** 나머지 `4+1+3+1+2+13=24`와 별도 money formatter 두
  owner를 함께 닫는다. 서울 보드의 날짜·남은 여력·정확 원화와 재고조사 수당을
  실제 core-loop 화면에서 확인한다.

42템플릿 중 기존 `슬롯 %d` 한 개를 제외한 41개가 새 legacy key 후보다.
첫 collector 뒤 branch-selected literal의 6개 안정 key, planner의 고정 일정·STEP3
상태 key와 기존 lookup-before-format 경계를 숨기지 않도록 원장을 확장했다. 최종
active 후보 실측은 `total 3,311 = legacy lookup 3,277 + context 34`, 한국어
legacy key 2,816, JA `legacy 2,816/2,816 + context 29/29 = 2,845/2,845`다. raw 후보
55개의 disposition은 그대로이며, 그 밖의 기존 안전 호출을 provenance 때문에
`ui_format`으로 옮긴 2건(Aruba 상태 문장·연도 선택 회상)은 supplemental 원장으로
분리한다. 따라서 런타임 `ui_format`은 49호출이고, KO/EN 인자가 다른 경로 15건도
별도 exact 원장으로 잠근다.

## lookup·format 계약

`LocaleManager.ui_format(ko_template, en_template, ko_args, en_args)` 한 API가
템플릿 조회와 포맷을 순서대로 수행한다.

- KO는 `ko_template % ko_args`, EN은 `en_template % en_args`와 byte 동일하다.
- 준비 언어에서 community/built-in legacy template hit는 번역 template을
  적절한 인자와 포맷하고, 양쪽 miss는 EN template·EN args를 쓴다.
- event·단서·생각처럼 현재 언어에서 먼저 찾은 동적 제목은 EN fallback 인자로
  재사용하지 않는다. `DataRegistry`가 built-in/community/mod 우선순위와 같은
  명시적 English 제목을 별도로 보존하고, target/EN 인자를 각각 공급한다.
- lookup은 **완성 문자열이 아니라 템플릿**을 key로 사용한다. miss dedupe도
  값마다 늘어나는 완성 문자열이 아니라 안정 template 한 건을 기록한다.
- KO와 EN은 각자 자기 template·args를 독립 검증하므로 서로의 placeholder 수가
  달라도 된다. JA/community target은 한국어와 변환 종류·개수·순서, 명시적 `+`
  부호·정밀도, 줄바꿈이 같아야 하며 폭·0 패딩만 달라도 된다. 어긋나면 format
  전에 실패하고 `%` 오류를 빈 문자열이나 원문으로 조용히 삼키지 않는다.
- 두 exact-money owner는 새 template key 수에 포함하지 않는다. LocaleManager의
  한 formatter가 KO/EN 기존 바이트를 보존하면서 JA는 `ウォン`, zh-CN은 `韩元`,
  zh-TW는 `韓元`을 정확 1원 단위로 표시하고, 보드·재고조사 로컬 formatter가
  완성 문자열을 번역 조회에 다시 넣지 못하게 한다.
- `ui_context()` 5단계 우선순위와 ORDER-96 당시 30 ID·37호출의 역사 기준,
  현재 도달 29 ID·34호출, 구 community legacy override, 기본 이름 역조회는
  바꾸지 않는다.

## 정확한 파일 소유권

**제품·데이터 13:** `autoloads/LocaleManager.gd`, `autoloads/GameState.gd`,
`autoloads/DataRegistry.gd`,
`scenes/MainGame.gd`, `scenes/CommunicationPhone.gd`, `scenes/ArubaGame.gd`,
`scenes/StartMenu.gd`, `scenes/StoryMode.gd`, `scenes/SeoulCycleBoard.gd`,
`scenes/CoreLoopPlanner.gd`, `scenes/CommitmentTask.gd`, `locale/ui_ja.json`,
`content/meta/demo_localization_scope.json`.

**감사·QA 7:** `tools/ja_translation_pipeline.py`, `tools/zh_translation_audit.py`,
`tools/I18nInfrastructureCheck.gd`, `tools/ModLayerCheck.gd`,
`tools/ScreenshotQA.gd`, `tools/english_hangul_audit.py`,
`tools/PlaytestFlavorCheck.gd`.
`zh_translation_audit.py`의 skeleton self-test가 legacy 분모 2,730을
하드코딩하므로 새 inventory에서 읽게 바꾼다. `ja_translation_audit.py`와
demo/multilingual 감사기는 새 원장을 소비하므로 실행하되 별도 결함이 없으면
수정하지 않는다.

**지속 정본·사람 게이트 7:** `docs/I18N_INFRASTRUCTURE.md`,
`docs/I18N_GLOSSARY_JA.md`, `docs/I18N_GLOSSARY_ZH.md`, `docs/MODDING.md`,
`docs/QA_CHECKLIST.md`, `docs/DECISIONS.md`, `docs/human_gates.json`.
선언·완료 기록은 `docs/CODEX_QUEUE.md`, 이 사양, `CLAUDE.md`, 완료 뒤
`docs/WORK_LOG.md`, 8월 큐 archive와 생성 `docs/STATUS.md`만 만진다.

### 사용자 발견 P1 범위 추가 — 일본어 혼합 폰트

실제 JA 후보 화면에서 가나와 한자의 굵기가 다른 문제가 발견됐다. 원인은
Pretendard가 가나는 갖지만 일본어 한자를 전부 갖지 않아 가나는 primary
Pretendard, 한자는 fallback Noto Sans JP로 갈린 것과, variable Noto의 기본
`wght=100`을 명시적으로 덮지 않은 것이다. 정상 조판 차이로 보지 않고 이 오더의
출시 차단 P1로 수리한다.

- **폰트 소유 25:** `autoloads/FontKit.gd`, `autoloads/UIStyle.gd`;
  `scenes/BaccaratTable.gd`, `BigWheelGame.gd`, `BlackjackTable.gd`,
  `CommitmentTask.gd`, `CommunicationPhone.gd`, `CoreLoopPlanner.gd`,
  `CoreLoopV2Completion.gd`, `DaiSaiTable.gd`, `HoldemClub.gd`,
  `JeongseonCasino.gd`, `MainGame.gd`, `OpeningCinematic.gd`, `RaceTrack.gd`,
  `RouletteTable.gd`, `ScalpingGame.gd`, `SeoulCycleBoard.gd`,
  `SlotMachineGame.gd`, `SplashScreen.gd`, `StartMenu.gd`, `StoryMode.gd`,
  `TradingFloor.gd`, `TutorialOverlay.gd`, `scenes/ui/GangnamWordmark.gd`.
- **추가 QA·배선 5:** `tools/FontRoutingCheck.gd`, `.gd.uid`, `.tscn`,
  `tools/audit.sh`, `tools/audit_scope.json`. 기존 `ScreenshotQA.gd`는 synthetic
  CJK 문단도 제품의 locale-aware font role을 쓰게 하고 JA·두 ZH 원화 기대를
  같은 formatter 계약으로 검증한다.
- JA는 Noto Sans JP primary `400/600/700` → 동웨이트 Pretendard → emoji,
  KO/EN은 Pretendard primary → 동웨이트 Noto Sans JP → emoji다. 이미 생성된
  Control도 언어 전환 때 같은 공유 role resource 안에서 바뀌어야 한다.
- `FontRoutingCheck`는 제품 직접 폰트 로드 0, variable axis와 정확 굵기,
  대표 가나·한자·문장부호의 단일 Noto RID, KO/EN 우선순위, emoji-last,
  런타임 전환을 잠근다. 기존 ORDER-97 L3 임의 3표면은 이 폰트 수정 뒤 재생성한
  같은 `demo_rc`를 사용하며, 자동 캡처가 사람 판정을 대신하지 않는다.

### 최종 JA 표면 P1 범위 추가 — 서울 배치 미리보기 겹침

폰트 수정 뒤 생성한 실제 JA 1280×800 표면에서 서울 사이클의 장소·행동 원문이
네 줄로 감기며 다음 `현재의 클록` 행과 겹치는 결함을 확인했다. 960×600에서는
오류 행과 확정 버튼의 고정 사각형도 겹칠 수 있었다. 번역 문구를 줄이거나 본문
글자를 15/17px 아래로 축소하지 않고, 기존 소유 파일 안에서 출시 차단 P1로
수리한다.

- **제품·QA 소유 추가 없음:** 기존 `scenes/SeoulCycleBoard.gd`와
  `tools/ScreenshotQA.gd` 두 파일 안에서만 고친다.
- 미리보기의 제목→장소·행동→진전→효과→기한→오류→확정 순서는 유지하되,
  `Label`의 실제 줄바꿈 최소 높이로 행을 순차 배치한다. 전체 원문·숫자·효과·
  상태·포커스·저장 계약은 바꾸지 않는다.
- 회귀는 1~6월의 실제 24개 장소·행동 조합과 실제 자동저장 실패 문장을
  960×600/1280×800에서 검증한다. visible line 수, 각 글자 bounds, 행 간
  비중첩, 패널 경계, compact/wide 15/17px 글자 하한을 모두 잠근다.
- 기존 ‘포맷과 무관한 UI 리팩터링 비범위’에는 이 확인된 단일 P1 수리만
  예외이며, 카드 재설계·맵 폭 변경·스크롤 추가·다른 연출 변경으로 넓히지 않는다.

## 2026-08-18 당시 소스 정합 (역사 snapshot)

- lookup→format 구현과 L1/L2는 완료됐다. 당시 원장은
  `56=48+4+2+2`, 43템플릿, 런타임 `ui_format` 50호출,
  `3,323=3,286+37`, legacy 2,792키로 다시 수집돼 self-test를 통과했다.
- M01~M06 원고 수정 뒤 낡았던 데모 원문 계약은 당시 이미 `72사건·467본문·
  701동적·4자산`으로 갱신됐다. 이 숫자는 번역 완료가 아니라 번역할 범위였다.
- 그 시점의 active `demo_rc`는 후속 소스보다 오래됐으므로 현재 소스 후보 재발급과
  Batch A 23표면·Batch B 25표면의 사용자 임의 3개 판정을 기다렸다.

## 2026-08-24 active demo_rc 정합

- lookup→format 구현과 L1/L2는 완료됐다. 현재 원장은
  `55=47+4+2+2`, 42템플릿, 런타임 `ui_format` 49호출,
  `3,311=3,277+34`, legacy 2,816키·context 29 ID로 다시 수집돼 self-test를 통과한다.
- M01~M06 원고 수정 뒤 낡았던 데모 원문 계약을 현재 `72사건·467본문·701동적·
  4자산`으로 갱신했다. 이 숫자는 번역 완료가 아니라 번역할 정본의 현재 범위다.
- BUILD `2026.08.22.1`의 exact commit에서도 위 collector 실측이 동일하게
  재현된다. 이번 정합은 후보 발급 당시 낡았던 설명 숫자를 고친 것이며 제품
  바이트를 새 후보로 가장하지 않는다. ORDER-97을 닫으려면 같은 후보의 Batch A
  23표면과 Batch B 24표면에서 사용자가
  각각 임의 3개를 판정해야 한다. 자동 검사는 이 두 L3를 대신하지 않는다.
- 사건·엔딩·중국어 본문 번역은 여전히 이 오더의 비범위다. 빈 중국어 UI와
  JA/ZH 엔딩 overlay는 누락 산출물이 아니라 별도 번역 승인을 기다리는 skeleton이다.

## 비범위

- JA·zh-CN·zh-TW 사건 본문·동적 UI·엔딩·catalog 번역과 `--allow-body` 해제
- 중국어 사전 행·폰트·locale 노출·Steam 언어 표기
- 한국어·영어 카피, 플레이 효과·수치·플래그·세이브·게임플레이 ID
- 역사 30·현재 도달 29 context ID 재설계, 새 context ID, community pack 포맷 강제 마이그레이션
- 포맷과 무관한 UI 리팩터링, 카드/레이아웃/연출 변경

## 검증·완료 조건

- 전수 원장 `55 = migrate 47 + dynamic reader 4 + branch literal 2 + money
  formatter 2`, 잔여 preformat lookup 0, 47 owner count exact를 증명한다. 두
  money formatter는 locale owner 하나를 공유하고 KO/EN byte exact와
  JA/zh-CN/zh-TW unit·부호·쉼표를 표적 검사한다.
- supplemental lookup-before-format 2건, 전체 runtime `ui_format` 49건,
  target/English argument provenance 15건을 exact registry와 self-test로 잠근다.
- collector의 실제 total/legacy/context/key/hash와 JA/ZH 분모를 manifest·정본에
  승격한다. 예상값을 맞추려고 호출이나 template을 임의로 합치지 않는다.
- API는 KO/EN byte 동일, built-in/community hit, legacy fallback, miss→EN,
  template miss dedupe·refresh, placeholder mismatch fail-closed를 증명한다.
- JA inventory/self-test/UI audit, ZH skeleton/self-test, I18n/ModLayer,
  demo `467/701/4/0`·body hold·shipping KO/EN, 전체 audit·EN coverage·diff를 통과한다.
- 실제 JA `core-loop-v2`, `gallery`, `story-en`, `i18n-layout`을 1280×800에서
  확인하고 서울 보드의 `WEEK`, `MONTHLY CAPACITY LEFT`, `won` 잔류를 0으로
  만든다. KO/EN 두 해상도 surface도 같은 리비전에서 다시 돈다.
- `FontRoutingCheck`를 전체 감사와 변경 파일 selector에 등록하고 JA
  `i18n-layout`과 실제 core-loop/gallery/story 표면에서 가나·한자 굵기 혼합,
  잘림, 줄바꿈 회귀가 없음을 같은 최종 리비전으로 다시 확인한다.
- L2는 42개 JA template을 한국어 문맥·placeholder와 전수 대조한다. L3는
  23단위 Batch A와 24단위 Batch B에서 각각 사용자가 임의 3개 실제 표면을 보고
  하나라도 틀리면 해당
  배치 전량을 반려한다. 자동 초록은 원어민·4개국어 shipping GO가 아니다.
- 지속 lookup/format 규칙을 정본에 승격하고, 두 배치의 호출 목록·실행 로그는
  일회성으로 판정한 뒤 archive한다.
