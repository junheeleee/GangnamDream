# Active Queue Spec: ORDER-126

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-126 [P0·공개 데모] 스토리 선택형 M01~M06을 일·중 포함 출고 후보로 만든다

**착수 선언 (2026-08-25):** 사용자는 반복 AP/월간 행동판 대신 게임의
성공 가능성을 기준으로 Codex가 제품 방향과 순서를 판단하도록 위임했고,
일본어·중국어 데모를 붙이는 순서를 제안했다. 제품 판정은 **실제
StoryMode 선택이 플레이를 소유하고, 반복 행동판은 새 데모 표면에서
퇴역**시키는 것이다. 저장 호환용 AP 데이터·엔진과 기존 retail/V2
저장은 삭제하지 않는다.

## 깊이 3문

1. 왜 다국어를 옛 AP 데모에 먼저 붙이지 않는가? 출고할 플레이 문법이
   스토리 선택형으로 바뀌었다. 반려된 행동판 문장을 세 언어로 더 번역하면
   비용만 늘고 새 작품의 품질 증거가 되지 않는다.
2. 왜 M01~M06 원문을 고정한 뒤 번역하는가? 번역 뒤 장면·선택·전환
   문장을 다시 바꾸면 네 코드의 의미·줄바꿈·자막 검수를 모두 다시 해야 한다.
   먼저 한·영 스토리 효과와 표면을 잠그고 그 exact source만 직접 번역한다.
3. 왜 AP 코드를 지금 삭제하지 않는가? 플레이어에게 보이지 않는 호환 코드
   삭제는 재미를 늘리지 않으면서 저장·240주 회귀 위험만 만든다. 새 데모는
   AP 입구와 원장을 0으로 두되, 기존 저장은 예전 경로로 계속 읽는다.

## 배치 A — 스토리 데모 출고 표면·서체 16단위

1. BUILD는 `2026.08.25.1`, profile은 `story_demo_rc`, 앱 이름은
   `GangnamDream-StoryDemo`, 전용 user dir은 `GangnamDream_StoryDemo_v1`이다.
2. Finder 무인자 실행은 언어 선택 뒤 M01~M06 스토리 홈으로 들어간다.
3. 플레이 입력은 StoryMode의 문장 넘기기·선택, 시작·이어하기·언어만 소유한다.
4. `주력/함께/여력`, AP, 행동 카드, 주간·월간 계획, 확인 제출은 노출 0이다.
5. 장면 뒤 네 주·수입·월세·이자·몸·마음은 exactly once 자동 정산한다.
6. ORDER-124 M01 → M02 분기, M03~M05 인물, M06 한 가지 포기와 회고를 보존한다.
7. 반려 BUILD `.2`의 검은 cover 결함과 수리된 `.3` overlay/input 계약을 같이 검사한다.
8. 새 전용 저장은 월 단위 autosave·StoryMode 수동 저장·앱 재실행 이어하기를 지원한다.
9. 기존 ORDER-124 전용 저장과 retail/V2 슬롯은 읽거나 덮어쓰지 않는다.
10. 간체·번체 전용 Noto Sans SC/TC 원본과 OFL 1.1 사본·해시·고지를 함께 번들한다.
11. `ja` release surface는 Noto Sans JP, `zh-CN`은 SC, `zh-TW`는 TC가 각각 primary다.
12. KO/EN은 Pretendard, 임의 OS font는 어느 출고 언어의 primary가 아니다.
13. 중국 본토 출시 주장은 하지 않고 언어 지원과 지역 유통을 분리한다.
14. 게임의 도박·빚·정신건강 내용을 지역 때문에 순화하거나 삭제하지 않는다.
15. 스토리 데모 export는 staging에서만 entry, app identity, custom user dir를 바꾸고
    루트 `project.godot`·retail export preset을 byte-exact로 둔다.
16. 출고 후보는 clean commit/tree, Godot 버전, 앱·launcher·PCK·ZIP 해시를 manifest에 잠근다.

## 배치 B — 데모 직접 번역·네 언어 표적 QA 20단위

1. 번역 원문은 현재 M01~M06에 실제 도달하는 11 event ID와 데모 shell/
   StoryMode 도달 UI로 고정한다.
2. 일본어·간체·번체는 한국어에서 각각 직접 번역하고 영어를 중역 원문으로 쓰지 않는다.
3. 간체와 번체는 OpenCC 변환 사본이 아니라 각 지역의 자연스러운 문장으로 따로 작성한다.
4. `{name}`, `{v2_*}`, `%s/%d`, BBCode, 줄바꿈, 선택 인덱스와 gameplay key를 보존한다.
5. 고시원·전세·원화·강남·소주·포장마차 등 한국 맥락을 지역 사회로 치환하지 않는다.
6. 선택지는 미래 결과를 추가로 해설하거나 도덕적 정답을 만들지 않는다.
7. 일본어는 정본 호칭·말투·부끄러움 문법, 원화 표기와 한국 생활 글로스를 지킨다.
8. 중국어는 인물 온도·호칭, 원화 표기, 지역별 문장부호와 어휘 차이를 지킨다.
9. 비한국어 표면의 한글 누출, 비중국어 폰트, 영어 fallback은 실제 도달 범위에서 0이다.
10. 모든 사건의 title/description/choice text/result text 및 필수 변형이 원문과 구조 패리티다.
11. M01 두 선택 모두가 M02 clean/fallout의 올바른 번역 장면으로 간다.
12. M04 두 진입이 measure/coffee 번역 후 answer로 합류한다.
13. M06은 도달할 수 있는 다은·재혁·상철·긴급 일·휴식 다섯 선택만 각 언어에서 보인다.
14. KO/EN/JA/zh-CN/zh-TW의 960×600·1280×800 home/transition/StoryMode/recap을 캡처한다.
15. 마우스·키보드·Xbox/PlayStation 의미 입력으로 언어 선택·장면·회고를 끝낸다.
16. 새 시작, M02 분기, 장면 사이 autosave, 재실행 이어하기, M06 완주를 package에서 확인한다.
17. 번역 단위 하나라도 누락·토큰 드리프트·나랜 자막·잘림이 있으면 해당 언어는 출고 선택에서 차단한다.
18. 기계 L1/L2는 번역의 자연스러움과 인물 말투 GO를 대신하지 않는다.
19. 일본어·간체·번체 원어민 검수는 각각 출고 claim을 막는 사람 게이트로 남긴다.
20. 이 데모 후보를 실제 플레이하는 순간이 본편 240주 story-first 이관의 다음 사람 판정점이다.

## 정확한 파일 소유권

**선언·마감:** `docs/CODEX_QUEUE.md`, 이 사양, `CLAUDE.md`,
`docs/DECISIONS.md`, `docs/I18N_INFRASTRUCTURE.md`, `docs/I18N_GLOSSARY_JA.md`,
`docs/I18N_GLOSSARY_ZH.md`, `docs/BUILD_PIPELINE.md`, `docs/human_gates.json`,
`docs/WORK_LOG.md`, 생성본 `docs/STATUS.md`, `tools/audit_scope.json`.

**스토리 데모 표면:** `playtests/order124/StoryChoiceM1M6Playtest.gd`,
`playtests/order124/StoryChoiceM1M6Playtest.tscn`, `scenes/StoryMode.gd`.

**다국어 런타임·서체:** `autoloads/LocaleManager.gd`, `autoloads/FontKit.gd`,
`assets/fonts/NotoSansSC-Variable.ttf`, `assets/fonts/NotoSansTC-Variable.ttf`, 해당
`.import`, `assets/fonts/OFL-NotoSansSC.txt`, `assets/fonts/OFL-NotoSansTC.txt`,
`assets/fonts/FONT_LICENSE_LEDGER.md`, `content/meta/third_party_notices.json`,
`tools/third_party_notice_audit.py`, `tools/FontRoutingCheck.gd`, `tools/I18nInfrastructureCheck.gd`.

**번역:** `content/events_ja/story_demo_events.json`,
`content/events_zh-CN/story_demo_events.json`, `content/events_zh-TW/story_demo_events.json`,
`locale/ui_ja.json`, `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json`,
`locale/catalog_ja.json`, `locale/catalog_zh-CN.json`, `locale/catalog_zh-TW.json`.

**표적 검사·패키지:** `tools/StoryDemoFourLanguageCheck.gd`와 `.gd.uid`,
`tools/StoryDemoFourLanguageCheck.tscn`, `tools/story_demo_localization_audit.py`,
`tools/build_story_demo_macos.sh`, `tools/story_demo_package_audit.py`.

위에 적지 않은 `project.godot`, `export_presets.cfg`, `StartMenu`, `MainGame`, AP·V2,
저장 슬롯, 이벤트 게임플레이, 밸런스, 엔딩·finish_run은 수정하지 않는다.

## 완료 증거·사람 경계

- clean exact source에서 5 locale 구조 패리티, 한글·영어 fallback 0, 폰트 경로·OFL·고지가 PASS다.
- 두 M01 route·두 M04 route·다섯 M06 선택, 24주·정산 6·월간/AP 원장 0,
  save/resume·overlay/input clear가 다섯 locale에서 PASS다.
- macOS app/ZIP/manifest가 고정 commit/tree와 일치하고 기존 사용자 저장·ORDER-124
  산출물·retail/V2 설정이 byte-exact다.
- 이 L1/L2가 끝난 뒤에만 사용자에게 플레이할 앱을 지목한다. 사용자가 직접
  플레이하기 전에 재미·시간감·선택감각 GO를 쓰지 않는다.
- 일·간체·번체 번역은 Codex 전수 L2 낭독 후에도 각 원어민 출고 GO를 OPEN으로
  남긴다. 이 게이트는 데모 플레이를 막지 않지만 Steam 해당 언어 claim은 막는다.
- 데모 성공 판정 뒤의 본편 이관은 다음 작은 오더가 소유한다. 이 오더를 240주
  최종판 완성으로 오인하지 않는다.

## 규범 판정

스토리 선택 표면·AP 내부 호환 보존은 기존
`docs/CHOICE_CONSEQUENCE_SYSTEM.md`의 적용이다. 데모 네 언어와 중국어 두 지역
직접 번역·전용 서체 규칙은 `docs/I18N_INFRASTRUCTURE.md`에 승격한다. BUILD,
앱 이름, 전용 저장, 산출물 해시와 임시 검사 명령은 일회성이다.
