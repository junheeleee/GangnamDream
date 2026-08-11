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

1. 지우면 본문 471개와 동적 657키를 전부 번역해도 포맷이 먼저 끝난 UI는 사전
   key와 절대 일치하지 않아 JA/ZH 표면에 영어가 남는다.
2. 플레이 선택·세이브·수치·카피는 바꾸지 않는다. lookup → format 순서만
   고치고 KO/EN 최종 문자열은 byte-for-byte 그대로 보존한다.
3. 준비 언어가 번역 행을 찾았을 때와 EN fallback을 쓸 때 필요한 인자 표면이
   다를 수 있다. 각 호출이 임의 분기를 만들지 않고 한 API가 lookup provenance,
   placeholder, KO/EN 인자 선택과 miss를 소유해야 community pack도 보존된다.

## 고정 전수 원장과 두 배치

착수 실측의 raw 후보 54개를 정확히 다음 네 종류로 분류한다.

- **이동 46호출 / 41템플릿:** lookup 전에 값을 끼우는 player-facing UI.
- **동적 pair reader 4:** 이미 별도 KO/EN 데이터의 완성값을 읽으므로 이동 금지.
- **branch-selected literal 2:** 분기 뒤 정적 문자열을 고르며 preformat 결함이 아님.
- **locale money formatter 2:** `SeoulCycleBoard::_format_money`와
  `CommitmentTask::_format_money`은 46개 template 호출에 섞지 않고, 정확한
  1원 단위·부호·쉼표를 보존하는 LocaleManager 소유 formatter 하나로 합친다.

46호출의 파일별 정확한 수는 `GameState 4 + MainGame 1 +
CommunicationPhone 3 + ArubaGame 1 + StartMenu 16 + StoryMode 7 +
SeoulCycleBoard 2 + CoreLoopPlanner 12 = 46`이다. manifest는 path·함수·KO/EN
템플릿·placeholder signature·count와 위 54개 전수 disposition을 먼저 잠근다.
unclassified·duplicate·stale·편의상 추가한 호출은 실패다.

- **배치 A 23단위:** `StartMenu 16 + StoryMode 7`. 시작·기록·설정·장면 표면을
  실제 gallery/story 화면과 함께 닫는다.
- **배치 B 23단위:** 나머지 `4+1+3+1+2+12=23`과 별도 money formatter 두
  owner를 함께 닫는다. 서울 보드의 날짜·남은 여력·정확 원화와 재고조사 수당을
  실제 core-loop 화면에서 확인한다.

41템플릿 중 기존 `슬롯 %d` 한 개를 제외한 40개가 새 legacy key 후보다.
첫 manifest 실행에서 확정할 예상 원장은 `legacy lookup 3,263 + context 37 =
total 3,300`, 한국어 legacy key 2,770, JA `legacy 2,770/2,770 + context
30/30`이다. 이 수치는 **[첫 실행 재조정]**이며 첫 collector 결과가 다르면
호출을 빼거나 더하지 말고 54개 disposition·중복 template부터 다시 대조한다.

## lookup·format 계약

`LocaleManager.ui_format(ko_template, en_template, ko_args, en_args)` 한 API가
템플릿 조회와 포맷을 순서대로 수행한다.

- KO는 `ko_template % ko_args`, EN은 `en_template % en_args`와 byte 동일하다.
- 준비 언어에서 community/built-in legacy template hit는 번역 template을
  적절한 인자와 포맷하고, 양쪽 miss는 EN template·EN args를 쓴다.
- lookup은 **완성 문자열이 아니라 템플릿**을 key로 사용한다. miss dedupe도
  값마다 늘어나는 완성 문자열이 아니라 안정 template 한 건을 기록한다.
- placeholder 수·종류·순서와 줄바꿈이 KO/EN/JA/community 행에서 맞지 않으면
  format 전에 실패한다. `%` 오류를 빈 문자열이나 원문으로 조용히 삼키지 않는다.
- 두 exact-money owner는 새 template key 수에 포함하지 않는다. LocaleManager의
  한 formatter가 KO/EN 기존 바이트를 보존하면서 JA는 `ウォン`, zh-CN은 `韩元`,
  zh-TW는 `韓元`을 정확 1원 단위로 표시하고, 보드·재고조사 로컬 formatter가
  완성 문자열을 번역 조회에 다시 넣지 못하게 한다.
- `ui_context()` 5단계 우선순위와 기존 30 ID·37호출, 구 community legacy
  override, 기본 이름 역조회는 바꾸지 않는다.

## 정확한 파일 소유권

**제품·데이터 12:** `autoloads/LocaleManager.gd`, `autoloads/GameState.gd`,
`scenes/MainGame.gd`, `scenes/CommunicationPhone.gd`, `scenes/ArubaGame.gd`,
`scenes/StartMenu.gd`, `scenes/StoryMode.gd`, `scenes/SeoulCycleBoard.gd`,
`scenes/CoreLoopPlanner.gd`, `scenes/CommitmentTask.gd`, `locale/ui_ja.json`,
`content/meta/demo_localization_scope.json`.

**감사·QA 6:** `tools/ja_translation_pipeline.py`, `tools/zh_translation_audit.py`,
`tools/I18nInfrastructureCheck.gd`, `tools/ModLayerCheck.gd`,
`tools/ScreenshotQA.gd`, `tools/english_hangul_audit.py`.
`zh_translation_audit.py`의 skeleton self-test가 legacy 분모 2,730을
하드코딩하므로 새 inventory에서 읽게 바꾼다. `ja_translation_audit.py`와
demo/multilingual 감사기는 새 원장을 소비하므로 실행하되 별도 결함이 없으면
수정하지 않는다.

**지속 정본·사람 게이트 7:** `docs/I18N_INFRASTRUCTURE.md`,
`docs/I18N_GLOSSARY_JA.md`, `docs/I18N_GLOSSARY_ZH.md`, `docs/MODDING.md`,
`docs/QA_CHECKLIST.md`, `docs/DECISIONS.md`, `docs/human_gates.json`.
선언·완료 기록은 `docs/CODEX_QUEUE.md`, 이 사양, `CLAUDE.md`, 완료 뒤
`docs/WORK_LOG.md`, 8월 큐 archive와 생성 `docs/STATUS.md`만 만진다.

## 비범위

- JA·zh-CN·zh-TW 사건 본문·동적 UI·엔딩·catalog 번역과 `--allow-body` 해제
- 중국어 사전 행·폰트·locale 노출·Steam 언어 표기
- 한국어·영어 카피, 플레이 효과·수치·플래그·세이브·게임플레이 ID
- 30 context ID 재설계, 새 context ID, community pack 포맷 강제 마이그레이션
- 포맷과 무관한 UI 리팩터링, 카드/레이아웃/연출 변경

## 검증·완료 조건

- 전수 원장 `54 = migrate 46 + dynamic reader 4 + branch literal 2 + money
  formatter 2`, 잔여 preformat lookup 0, 46 owner count exact를 증명한다. 두
  money formatter는 locale owner 하나를 공유하고 KO/EN byte exact와
  JA/zh-CN/zh-TW unit·부호·쉼표를 표적 검사한다.
- collector의 실제 total/legacy/context/key/hash와 JA/ZH 분모를 manifest·정본에
  승격한다. 예상값을 맞추려고 호출이나 template을 임의로 합치지 않는다.
- API는 KO/EN byte 동일, built-in/community hit, legacy fallback, miss→EN,
  template miss dedupe·refresh, placeholder mismatch fail-closed를 증명한다.
- JA inventory/self-test/UI audit, ZH skeleton/self-test, I18n/ModLayer,
  demo `471/657/4/0`·body hold·shipping KO/EN, 전체 audit·EN coverage·diff를 통과한다.
- 실제 JA `core-loop-v2`, `gallery`, `story-en`, `i18n-layout`을 1280×800에서
  확인하고 서울 보드의 `WEEK`, `MONTHLY CAPACITY LEFT`, `won` 잔류를 0으로
  만든다. KO/EN 두 해상도 surface도 같은 리비전에서 다시 돈다.
- L2는 41개 JA template을 한국어 문맥·placeholder와 전수 대조한다. L3는
  각 23단위 배치에서 사용자가 임의 3개 실제 표면을 보고 하나라도 틀리면 해당
  배치 전량을 반려한다. 자동 초록은 원어민·4개국어 shipping GO가 아니다.
- 지속 lookup/format 규칙을 정본에 승격하고, 두 배치의 호출 목록·실행 로그는
  일회성으로 판정한 뒤 archive한다.
