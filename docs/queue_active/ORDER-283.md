# Active Queue Spec: ORDER-283

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-283 [P0·전체 현지화] 바카라 배분·손패 결과 중국어20값을 채운다

**[~] 2026-09-20 Codex 착수 — 아래12경로만 소유.** 부모 ORDER-157.
기준 `64bd57a763431365a0daae4d03bbc122084fa1bd`. 같은 패널 잔여22키에서 금융/정산12키를 제외한
비재무10키×CN/TW20값만 다룬다. 숫자를 맞추기 위해 대상을 늘리지 않는다.
post282-next-baccarat-status-scope.json(14084B/SHA
8a2e25a9d2d468b58fd15178418ead02307921f5ad7ed97ae7e0c447f7791037)의
원문10·Table10/공유1·source3/UI3/portable1/held2핀을 ROOT가 확인했다.

## 깊이 3문

1. 지우면: 카드 배분·손패 승패·다음 라운드·과거 결과 표시가 영어 폴백한다.
2. 24주 상태: 같은 결과를 번역할 뿐 새 선택이나 상태 변화0; 주차/경제/확률 불변.
3. 같은 자리 경쟁: 기존 lookup만 채우며 신규 행동판·진입·창·언어 노출0.

## 정확한 대상

- "🔀 슈 리셔플" — scenes/BaccaratTable.gd::_deal:356; 공유 scenes/BlackjackTable.gd::_deal:250
- "카드를 배분하는 중..." — scenes/BaccaratTable.gd::_render_dealing:604
- "플레이어 승" — scenes/BaccaratTable.gd::_render_result_screen:617
- "뱅커 승" — scenes/BaccaratTable.gd::_render_result_screen:617
- "타이!" — scenes/BaccaratTable.gd::_render_result_screen:617
- "플레이어 페어!" — scenes/BaccaratTable.gd::_render_result_screen:630
- "뱅커 페어!" — scenes/BaccaratTable.gd::_render_result_screen:631
- "다음 라운드" — scenes/BaccaratTable.gd::_render_result_screen:655
- "[color=#3a4a5a]베팅 없음[/color]" — scenes/BaccaratTable.gd::_bet_status_text:1035
- "로드맵" — scenes/BaccaratTable.gd::_draw_road:1339

Player/Banker 승리는 손패측 결과이지 플레이어의 수익이 아니다. Pair도 실제
카드의 같은 rank 발생이며 베팅 유무와 무관하다. 슈는 카드 묶음이며 셔플 완료,
배분은 진행 중이다. 다음 라운드는 베팅 초기화/같은 게임의 다음 판 준비이지
스토리 주차 진행이나 자동 베팅이 아니다. 로드맵은 과거 결과판이며 예측이 아니다.
두 지역 독립 KO 직접 저작, 문자변환/중역0. 정확BBCode·색상·🔀·문장부호 보존.

## 파일 소유권

- locale/ui_zh-CN.json, locale/ui_zh-TW.json: 위10키 append만.
- content/meta/full_game_localization.json: exact20 수용과1배치 append.
- CLAUDE.md, docs/CODEX_QUEUE.md, docs/CODEX_QUEUE_L3_PENDING.md.
- docs/queue_active/ORDER-283.md, docs/queue_archive/ORDER-283.md.
- docs/WORK_LOG.md, docs/STATUS.md.
- docs/agent_review_decisions.json, docs/agent_reviews/ORDER-283.json.

old40047/b127/meta9·기존69판정·held72를 보존한다.
JA/KO/EN/runtime/checker/collector/project.godot/human/public/manifest 비소유.
뱅커 수수료 이중차감·타이 원금 누락 정적 산식채무2, 금액/정산 부모,
직접EN Natural/승리배너/매트, raw result ID는 제외한다. 산식GO/held증가0.

## 검증과 판정

원문10·대상20 전수 비저자 대조 후 locale 명시 source-bound export/check,
설치 뒤 fresh export/import --accept. old40047 source/target hash·UI/portable
raw inverse·JA 불변 확인. 최초실패보존·같은모집단수리. clean exact 제품에서
기존 news-panel-locale-only 고유12를 한 번 실행하고 종료 metadata6으로 닫는다.
full audit·240주·engine·신규QA/숫자예외 확장0.

conditional Main→Casino→Baccarat와 Blackjack 공유는 static 소비자다.
fresh-story/실제화면·원어민·인간·물리패드 미관찰. 공개GO1·인간OPEN45·본편HOLD 유지.
패널/게임 전체 번역완료가 아니다. 선정/소유/배치/검사는 일회성, 기존 WORK_UNIT·
I18N 적용이며 신규 규범 승격0.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.
