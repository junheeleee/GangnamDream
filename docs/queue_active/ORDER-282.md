# Active Queue Spec: ORDER-282

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-282 [P0·전체 현지화] 바카라 베팅·입력 안내 중국어38값을 채운다

**[~] 2026-09-20 Codex 착수 — 아래12경로만 소유.** 부모 ORDER-157.
기준 `151cb2d1b2bda5d20b8bf41a7490d98892136c35`. KO19키×CN/TW38값의
독립 배치다. post281-next-baccarat-scope.json(15816B/SHA
27d4ecd0577fa6af330ff4882c4a0b63d6b972bccf40d0b78b9f8474ecef7f93)의
원문19·Table23/공유6·source9/사전3/portable1핀을 ROOT가 확인했다.

## 깊이 3문

1. 지우면: 베팅 대상·선택 단위·카드 배분·입력 안내가 중국어에서 영어 폴백한다.
2. 24주 상태: 새 선택이 아니라 기존 베팅/입력의 같은 뜻이다. 돈·확률·AP 변화0.
3. 같은 자리 경쟁: 기존 사전 lookup만 채우며 새 행동판·창·언어 노출0.

## 정확한 대상

- "베팅 단위: %s" — scenes/BaccaratTable.gd::_pad_cycle_stake:289; 공유 scenes/DaiSaiTable.gd::_pad_cycle_stake:290
- "플레이어" — scenes/BaccaratTable.gd::_pad_target_label:305, scenes/BaccaratTable.gd::_render_betting:527
- "뱅커" — scenes/BaccaratTable.gd::_pad_target_label:307, scenes/BaccaratTable.gd::_render_betting:528
- "타이" — scenes/BaccaratTable.gd::_pad_target_label:309
- "플레이어 페어" — scenes/BaccaratTable.gd::_pad_target_label:311
- "뱅커 페어" — scenes/BaccaratTable.gd::_pad_target_label:313
- "딜 시작" — scenes/BaccaratTable.gd::_pad_target_label:315, scenes/BaccaratTable.gd::_render_betting:574
- "현금 부족" — scenes/BaccaratTable.gd::_add_bet:325, scenes/BaccaratTable.gd::_deal:350; 공유 scenes/BlackjackTable.gd::_pad_cycle_stake:182, scenes/BlackjackTable.gd::_deal:246
- "베팅을 먼저 해주세요" — scenes/BaccaratTable.gd::_deal:348
- "바카라" — scenes/BaccaratTable.gd::_render_betting:504; 공유 scenes/JeongseonCasino.gd::_build_ui:329, scenes/MainGame.gd::_weekly_commitment_game_label:11750
- "사이드 베팅 (선택)" — scenes/BaccaratTable.gd::_render_betting:533
- "플레이어 페어  (11배)" — scenes/BaccaratTable.gd::_render_betting:540
- "PP베팅" — scenes/BaccaratTable.gd::_render_betting:540
- "뱅커 페어  (11배)" — scenes/BaccaratTable.gd::_render_betting:541
- "BP베팅" — scenes/BaccaratTable.gd::_render_betting:541
- "베팅 단위 (클릭당)" — scenes/BaccaratTable.gd::_render_betting:547
- "베팅 초기화" — scenes/BaccaratTable.gd::_render_betting:581
- "베팅 없음" — scenes/BaccaratTable.gd::_draw_bet_zone:715; 공유 systems/DaiSai.gd::label_for_bet:107
- "[b]%s[/b]  [%s/%s] 존  [%s] 칩/딜  [%s/%s] 단위 −/+  [%s] 단위 +  [%s] 규칙  [%s] 취소" — scenes/BaccaratTable.gd::_add_pad_hint:1003

두 지역 모두 한국어에서 직접 저작하며 중역·간번 자동변환0.
플레이어/뱅커는 사람/은행직원이 아니라 베팅측, 딜은 카드 배분이다.
페어11배는 순배당이며 원금은 별도 반환한다. 단위는 클릭당 추가액이다.
초기화/취소는 미확정 선택을 비우며 환불을 약속하지 않는다. 힌트9인자·
BBCode·공백·부호·%s·원화를 보존한다. 실제 공유6호출도 같은 의미로 대조한다.

## 파일 소유권

- locale/ui_zh-CN.json, locale/ui_zh-TW.json: 위19키 append만.
- content/meta/full_game_localization.json: exact38 수용과1배치 append.
- CLAUDE.md, docs/CODEX_QUEUE.md, docs/CODEX_QUEUE_L3_PENDING.md.
- docs/queue_active/ORDER-282.md, docs/queue_archive/ORDER-282.md.
- docs/WORK_LOG.md, docs/STATUS.md.
- docs/agent_review_decisions.json, docs/agent_reviews/ORDER-282.json.

old40009/b126/meta9, 기존68판정, held72 원형을 보존한다.
JA/KO/EN/runtime/checker/collector/project.godot/human/public/manifest는 비소유.
정적 코드에서 발견한 뱅커 수수료 이중차감·타이 원금 누락은 별도 원문/계산 수리다.
타이8배·수수료/HUD/규칙 부모·직접EN 매트/배너·동적 결과ID는 이 배치에서 제외한다.
기존 held72를 늘리거나 산식이 맞다고 승인하지 않는다.

## 검증과 판정

원문19·대상38 전수 비저자 대조 뒤 locale 명시 source-bound export/check,
수동 설치 뒤 fresh export/import --accept. old40009 source/target hash와
UI/portable raw inverse를 확인한다. 최초 실패는 보존하고 같은 모집단으로 수리한다.
clean exact 제품에서 기존 news-panel-locale-only 고유12를 한 번 실행한다.
종료 metadata6 외 full audit·240주·engine·신규QA/숫자예외 확장은 없다.

Main→Casino→Baccarat는 conditional legacy/AP 소비자다. 정적 연결은
fresh-story/실제화면 관찰이 아니다. 화면·원어민·인간·물리패드 미관찰,
공개GO1·인간OPEN45·본편HOLD 유지. 패널/게임 전체 번역완료가 아니다.
선정/소유/배치/검사는 일회성. 기존 WORK_UNIT·I18N 적용, 신규 규범 승격0.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.
