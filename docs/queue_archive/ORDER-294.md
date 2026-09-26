# ORDER-294 — 카지노 현금·배당·수수료·상태 중국어

[x] 2026-09-27. 비저자 작업 한정 GO, 필수 결함0. 실제 화면/입력은 별도 후속이다.

- source `3b105cbbcb4f39559a8d3ade1df923725c8e12e8`, tree `d5ade43e6be9af48c46a39c4e446622aa8775de7`. [독립 보고](../agent_reviews/ORDER-294.json) SHA `f56161e710b0d8024d29f79378ccff90718abbc1fa0ada71ae44684880805dab`.
- Baccarat6/Roulette12 KO키의 CN/TW36값을 각기 한국어에서 작성했다. 비저자 전수 대조와19 literal reader(JeongseonCasino 잔액 공유 포함) 확인. 숫자·BBCode·placeholder·명시 부호 보존.
- Baccarat HUD의 閒/莊/和는 판 결과 횟수, commission은 미납액, exit로그는 지급액이다. 룰렛 순이익과 원금 포함 총수령을 구분하며 preview금액을 출금으로 설명하지 않는다. 실제 영문 버튼과 맞춘 BET 표기는 보존했다.
- 공식 사전 export/check와 적용후 새 target-hash export/check/import 모두 지역별18 PASS. 기존 named12 표적검사 PASS. 금융 계산 수정이나 정산 실행의 증거가 아니다.
- 공식40213/b133/meta9, 신규36. 기존40177 source/target와 두 사전1004값/지역·portable raw inverse 보존. 사전 각1022키,3028 reference 대비 각2006 부재(전체 live UI 분모 아님). JA·원문·runtime·project·공개·human 원형 불변. 보류72 유지.
- 도달: FULL_LOCALIZATION_BATCH_VALID locale=zh-CN/zh-TW leaves=18. 생산자↔독자: locale/ui_zh-*.json ↔ BaccaratTable.gd:122,499,500,535,603,648 / RouletteTable.gd:465,544,546,980,1009,1216,1218,1363,1370,1372,1373,1382 / JeongseonCasino.gd:187. 상태: 각18키 부재→수용. 제거손실: 해당19호출의 영어 폴백. 서사/계층: 기존 카지노 UI, 신규 장면 없음. 닫음: exact36 번역·source-bound 수용만.
- 실제 엔진/화면/입력/원어민/인간/물리패드/패키지 미관측. 기존292/293의 화면 GO를 이번 새 문자열에 상속하지 않는다. 돈 포매터의 기존 반올림·raw player/banker/tie·Odd/Even 공유 소비자·직접영어·남은 UI는 별도다.
- 최초 baseline diff 검사는 선언 파일의 EOF 빈줄1건으로 exit2였다. 제품 변경 없이 queue-only wrapper `d64e61e`에서 제거했고 diff·context·queue를 표적으로 재확인했다. named12는 원래 제품3b105에서 한 번만 실행했다.
- 다음은 새18키의 실제 표시·금액/상태 조합 검수이며 새 범위를 선언한다. private `order294-next-render-scope.json` SHA `f2a2056187ac269765b32df12d6b9fbe5c0fba5296f5ed13ffe3e8dc109c6d86`의26화면·비화면 지급로그2건은 미실행 계획이다. 공개GO1·인간OPEN45·본편HOLD를 보존한다. 규범 승격 없음: I18N/WORK_UNIT 적용, 이18키와 증거 구성은 일회성이다.
- 자동 게이트는 계약 증거이지 재미·깊이·문체 또는 인간 판단의 대체가 아니다.

## 최초 선언 원문

# Active Queue Spec: ORDER-294

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-294 [P0·현지화] 카지노 현금·배당·수수료·상태 중국어 36값

**[~] 2026-09-27 Codex 착수 — 아래 exact 범위만 소유한다.** 사용자
“순서대로 진행해” 및 ORDER-157의 한국어 직접 번역 위임. 기준선 clean main
`151b2b4c11c62f33724d3062f9eaabef80a09a3f`. 앞선292/293 검사는 반복하지 않는다.

## 깊이 3문·범위

1. 제거 손실: 아래18키·19 literal 호출의 CN/TW 영어 폴백이 남는다.
2. 24주 상태: 번역만 달라지고 현금·배당·정산·저장·시간은 불변이다.
3. 경쟁: 남은 사전2024키/지역 중 이미 reader가 확인된 금융/상태 부모를 우선한다.
   전체 live UI 분모나 전체 카지노 완료로 세지 않는다.

18 KO키 × 독립 CN/TW =36값. Baccarat6·Roulette12이며 잔액은 JeongseonCasino도 읽는다.
정확한 KO목록·호출·인자·기준 SHA는 private `order294-source-scope.json`에 결속한다.

- 바카라 커미션 정산 -%s
- `   커미션 [color=%s]%s[/color]`
- `[b]현금 %s[/b]   |   %d라운드   W%d B%d T%d   손익 [b]%s[/b]   슈 %d%%%s`
- 타이  (8배)
- 플레이어 1:1  ·  뱅커 0.95:1(커미션5%)  ·  타이 8:1  ·  페어 11:1  ·  6덱 슈  ·  내추럴(8·9) 시 추가 드로우 없음
- 누적 커미션: %s (나갈 때 정산)
- 먼저 BET 버튼을 눌러주세요
- 당첨!  +%s
- 꽝  결과: %d
- 숫자 베팅 매트  |  단일 숫자는 바로 선택
- 베팅 유형 선택
- `  [color=#f0b429][b]스핀 중[/b][/color]`
- `[b]유럽식 룰렛[/b]   |   현금 [b]%s[/b]   |   %d라운드   W[color=#3de87a]%d[/color] L[color=#e85d5d]%d[/color]   손익 [b]%s[/b]%s`
- 베팅: %s   |   배당: %.0f:1   |   당첨 시 수령: %s
- →   BET 버튼 클릭
- →   [%s] 칩 놓기
- 배당률: %.0f:1   |   베팅 금액: %s   %s
- 잔액: %s

Baccarat W/B/T는 플레이어 본인 승패가 아니라 闲/庄/和 결과 횟수이며 슈는 잔여율이다.
수수료 HUD/안내는 미납액, exit로그는 지급액, net은 수수료 반영값이다.
Roulette 당첨 +금액은 순이익, 당첨 시 수령은 원금 포함 총액이고 preview stake는
아직 놓지 않은 금액이다. 숫자 직접 선택은 즉시 출금이 아니다.
BET는 실제 영문 버튼과 맞춘다. 공유 Odd/Even·raw player/banker/tie 결과 부모·
직접영어·남은 UI·원문/금융 결함은 비소유이며 발견 시 별도 선언한다.

## 파일 소유권

- root: `locale/ui_zh-TW.json`18키 직접 저작, 검수된 `locale/ui_zh-CN.json`18키 반영,
  `content/meta/full_game_localization.json`36 pin·batch1 append.
- CN저자: private `order294-zh-CN-draft.json`만 한국어에서 독립 작성.
- scope 조사자: private `order294-source-scope.json`만. 저자와 별도의 검수자가 전수 판정.
- 비저자: private `order294-language-review-*.json`·`order294-independent-review-*.json`.
- root기록: CLAUDE 현재상태1행, CODEX_QUEUE·CODEX_QUEUE_L3_PENDING,
  이 active/archive, WORK_LOG, 생성 STATUS, agent_reviews/ORDER-294.json,
  agent_review_decisions.json append1. private `.git/full-game-localization/order294-*`.
- KO/EN·JA·runtime·project·테스트/기준선·공개판·human_gates·기존receipt 비소유.

## 검증·증거·경계

사전 export → 지역별 KO 직접 저작 → 공식check → 비저자36값/19reader 전수
→ append → 새 target-hash export/check/import --accept → portable수용.
기존40177/b132/meta9·사전1004/지역·JA·원문·공개·인간 raw와 기존pin 보존.
신규수용시40213/b133/meta9·각1022 예상, 실제 출력으로만 확정한다.
`news-panel-locale-only` 기존 named12 표적검사 및 exact diff보존 guard,
context/queue/원장/dashboard·diff·clean source identity. 전체 감사/240주는 실행하지 않는다.
도달 증거는 공식 source-bound 검증이며 실제 렌더/입력은 별도 다음 배치로 남긴다.
생산자 locale/UI → 위 세 reader, 신규 장면/선택 없음, 원어민·인간·물리패드 미관측.
공개GO1·인간OPEN45·본편HOLD·보류72 보존. 자동 PASS는 품질/인간 GO가 아니다.

규범 승격 없음: I18N/WORK_UNIT 정본을 적용하며 이18키·소유권·검사 구성은 일회성이다.
