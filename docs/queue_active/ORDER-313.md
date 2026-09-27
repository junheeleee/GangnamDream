# Active Queue Spec: ORDER-313

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-313 [P1·본편] 2장 M13~M24 대본의 시간·영어 정합을 고친다

## 2026-09-27 착수 — 파일 소유와 증거 경계

- 기준 clean main `035cc1f`. 원래 수리1~8의 **7 JSON/15 text leaf**만 변경한다.
  `header_layout`은 `content/events{,_en,_ja,_zh-CN,_zh-TW}/arc_events.json`의
  network/visit 기본 description 10개와 EN 선택1 text 두 개를 소유한다.
  root는 EN `arc_midgame.json` medication description/선택1 result_text와
  EN `arc_daeun.json` fork 선택2 result_text, portable ledger의 해당 receipt6을 소유한다.
- 발견된 visit `description_if_known.arc_sangchul_03_seen` 5문구는 별도
  [356](ORDER-356.md)이다. 여기의15문구에 몰래 더하지 않는다.
- root 문서는 이 사양/큐/WORK_LOG/생성 STATUS/CLAUDE 현재 한 행, 새 agent판정·
  `docs/agent_reviews/ORDER-313*.json`이다. `.git/full-game-localization/order313-*`
  export/응답/표적 검사/자가 증거만 만들며 `screen_independent_review`는 읽기 전용
  전수 검수와 private 보고를 맡는다. `screen_path_probe`는 읽기 전용 영향 분석이다.
- 선언 커밋 뒤 원문 export를 보존하고 구현한다. 수리 뒤 fresh export→check/import와
  기존 accepted6만 재검증하며 다른 accepted행/기존 batches/공개 보호행을 보존한다.
  EN coverage·구조·한글누출·story consistency·수용 회귀와 선택기 영향 목록을 확인한다.
  원래 whole-file 핀은 갱신하지 않는다. 새 원고를 거절하는 경계는 별도 후속으로 선언한다.
- 조건/효과/ID/선택 순서/스케줄/맵/엔진/인간 원장/project/공개manifest 변경0.
  실제 화면·입력·원어민·인간·물리·새package 관측을 주장하지 않는다.
  이 소유와 검증 지시는 일회성이며 기존 I18N·P-9·WORK_UNIT을 적용한다.

**2026-09-27 Claude 발행.** 본편 대본 정합 검토 계획
([FULL_GAME_SCRIPT_REVIEW](../queue_backlog/FULL_GAME_SCRIPT_REVIEW.md))의 배치
R2다. story_map M13~M24 root 15장면(첫해 장부, 상철 인맥, 아버지 약, 루틴의 덫,
상철의 공백, 1년 반, 현수 취직, 설명회, 두 번째 해, 다은 갈림길, 부모님 서울
방문, 거울, 월급의 한계, 창원 병실, 34세 결산)을 KO/EN으로 읽고 `STORY_BIBLE`
인물 정본, `DECISIONS` 2026-08-04 문체 규칙과 대조했다. 산문을 새로 쓰는 작업이
아니라 사실·영어 정합 수리다.

## 깊이 3문

1. **왜 지금인가?** 2장 사실(아버지 병세, 상철 인맥, 다은 갈림길)이 3장 판독의
   기준이 된다.
2. **무엇을 바꾸지 않는가?** gameplay key, 선택 수, 효과, 이벤트 ID, 장면 순서,
   스케줄 조건, 경제 수치는 바꾸지 않는다.
3. **순서는?** 체험판(ORDER-302·303)과 1장(ORDER-309) 뒤다. 본편은 HOLD이므로
   공개 GO나 사람 게이트를 바꾸지 않는다.

## 수리 목록

| # | 위치 | 결함 | 수리 방향 |
|---:|---|---|---|
| 1 | `content/events_en/arc_midgame.json` `arc_father_medication` | 본문은 과거형인데 세 선택 결과만 현재형이다. 한 장면 안에서 시제가 바뀐다. | `DECISIONS` 2026-08-04 P-9 4번(영어 서술 기본 현재형)에 따라 본문을 현재형으로 맞춘다. |
| 2 | 같은 장면 선택 1 결과 | KO “그걸 알면 되나.”(안다고 뭐가 달라지나)가 EN “Is that what you need?”로 뜻이 뒤집혔다. | 예: “What good will knowing do?” |
| 3 | `content/events/arc_events.json` `arc_sangchul_03_network` 본문 첫 문장, 같은 EN | “1년 장부에서 자본의 차이를 본 **다음 날**”인데 첫해 장부(`arc_year_one_mark`)는 M13 새해 첫날 밤, 이 장면은 M14다. 첫해 장부 장면에는 자본 차이를 보는 대목도 없다. | 날짜를 특정하지 않는 연결로 바꾼다(예: “첫해 장부를 덮고 한 달이 지났을 무렵”). KO/EN/JA/zh 동일. |
| 4 | `content/events_en/arc_events.json` `arc_sangchul_03_network` 선택 1 문구 | KO “임상철 옆에 붙어 명함을 하나씩 받았다”가 EN “greet everyone”으로 바뀌었다. 결과문은 명함을 받는 장면이다. | “Stay beside Sangchul and take each card”처럼 원문 행동으로 맞춘다. |
| 5 | `content/events_en/arc_daeun.json` `arc_daeun_03_fork` 선택 2 결과 | KO “고향행 종이”가 EN “the bus sheet”다. 버스는 원문에 없는 발명이다. | “the sheet for home”처럼 원문대로. |
| 6 | `content/events/arc_events.json` `arc_father_04_visit` 본문, 같은 EN | “서울에서 여기까지 두 시간이 걸렸다”. 서울–창원 KTX는 실제로 약 2시간 40분~3시간이다(선택적 가상화 원칙상 서울·지명은 실명). | “세 시간 가까이” / “nearly three hours”. |
| 7 | 같은 장면 EN 선택 1 문구 | KO “오늘 과거를 꺼낸다”가 EN “tonight”이다. 첫 KTX로 온 낮 장면이다. | “today”. |
| 8 | `content/events/arc_events.json` `arc_father_04_visit` 본문 첫 문장, 같은 EN | **2026-09-27 판단 결정으로 추가.** 입원 전화(M23)에서 병실 방문(W96)까지 몇 주가 지나는데, 본문은 “첫 KTX를 탔다”로 곧장 달려온 것처럼 시작한다. | 첫 문장 앞에 지연을 인정하는 한 구절을 넣는다(예: “입원 소식을 들은 지 몇 주가 지나서야,” / “Weeks after the call about the admission,”). 늦게 온 사실이 설명 없이 대가로 읽히게 하며, 이유를 덧붙이지 않는다. |

## 판단만 남기는 항목 (이 오더에서 고치지 않는다)

- ~~아버지 입원과 병실 방문 사이의 시간~~ → **결정(2026-09-27): 수리 8번으로 옮겼다.**
- ~~상철의 말투~~ → **결정(2026-09-27): 고치지 않는다.** 1장 `arc_y1_sangchul_open_door`부터 하게체가 퍼져 있고, 가까워지며 말투가 내려가는 흐름이 자연스럽다. 단계는 `STORY_BIBLE.md` 임상철 절의 “말투 정본”에 적었다.
- **M21 `arc_34_two_years_in`이 M18의 감각을 되풀이한다.** M18 본문의 “빠른
  계단, 비를 피할 처마, 늦게까지 불이 켜진 식당”이 M21 본문과 선택 1 결과에 거의
  그대로 다시 나온다. 선택 2 결과는 두 줄뿐이다. M21 beat는 `work: EXPAND`이고
  의도(“두 해의 상승이 누구의 시간 위에 있었는지”)와 읽을 기억(`m20_door_choice`)을
  아직 반영하지 않으므로, 확장 저작 때 새 감각으로 다시 쓴다.
- **선택지 문구의 형태가 섞인다.** 대부분은 명령·의지형(“~한다”)인데 M14 선택
  1·2, M21 선택 1·2, M24 거울 선택 1, 월급의 한계 선택 1~3은 과거 서술형
  (“잔을 들었다”, “주식 앱 알림을 껐다”)이다. 정본 규칙이 없으므로 규칙을 먼저
  정한 뒤 일괄 정리한다.
- **EN 시제 전역 정리.** `DECISIONS` 2026-08-04가 영어 서술 기본 시제를 현재형으로
  정했지만 2장에서도 M14·M19~M22·M24 네 장면이 과거형이다. 배치마다 고치지 않고
  R 배치가 끝난 뒤 수량을 세어 한 번에 정리한다.

## 결함 아님으로 확인한 것

- 거울 장면의 “민준 씨” 직접 표기: 제품 시작 메뉴가 이름을 `김민준`으로 고정해
  넘기므로(`StartMenu.gd` 2106행) 실제 화면에서 어긋나지 않는다.
- 창원 병실의 “지난 여섯 해”: `STORY_BIBLE`의 27~32세 6년 상환과 맞다.
- “34세의 마지막 밤”: 33세 시작, 새해 첫날 나이가 오르는 흐름과 맞다.

## 완료 조건

- 1~8번이 KO/EN(해당 시 JA/zh-CN/zh-TW 오버레이 포함)에 반영된다.
- `python3 tools/en_coverage_check.py`와 `python3 tools/audit_select.py -- <변경 파일>`
  PASS. 해시 고정 검사가 걸리면 기존 소유 오더의 갱신 규칙을 따른다.
- `WORK_LOG`와 이 사양 머리말·큐 행 상태를 함께 갱신한다.
- 원어민·외부 플레이테스트 게이트는 OPEN으로 남는다.

## 2026-09-27 구현·표적 검증 — 통합 HOLD

- 제품 `ac02dbc6a18126dda25e8fea8562faff18c1a365`에서 정확15문구와 기존receipt6을
  고쳤다. 별도356의5문구/receipt3과 함께 7JSON20leaf 외 raw·구조·효과·순서·토큰·개행
  불변을 확인했다. source export 전후6+6·fresh check/import6쌍·stale batch6 거부,
  기존 accepted40299·137이력 보존, 새 이력2만 추가해b139이며 새번역0이다.
- 저장한 정적9명령 **6 PASS/3 FAIL**. PASS: localization264·audit·story consistency·
  i18n coverage·English Hangul·EN coverage. FAIL: full-body63중6실패, graph4오류,
  309guard286 corpus의 current admission. 실패와 stdout은 private `order313-static-*`에
  보존한다. 선택79개는 목록만 보았고 전량/엔진/240주 실행0이다.
- 문구 전수 독립 검토는 적합이며, 최종 source `496142dc64800593ea0913920c51d5ef8feccbd4`
  /tree `9cdb617871151c40f9159a3575c1de1f0014a42d`에 결속한 작업 판정은
  [HOLD](../agent_reviews/ORDER-313.json)다. 보고 SHA
  `a2e412556b37a31198cc4091dfe1d83b06b630a6bd50d101fd92824861bf4ecf`.
  위 통합 실패는 [357](ORDER-357.md)로 분리했고 기존 핀/실패 기록은 보존한다.
  비저자는 clean metadata wrapper `51953a9`의 전체 차이와 source resolver를 확인했다.
  최초 v1 보고는 보존하고 v2를 정확복사했으며 제품 검사를 반복한 것으로 세지 않는다.
- 증거: `.git/full-game-localization/order313-self-check.json`, `order313-self-review.md`.
  root의 첫 raw 대조가 잡은 EN 들여쓰기2칸 변화는 원형으로 복원한 뒤 같은 검사를 통과했다.
  규범은 일회성/기존 P-9·I18N·WORK_UNIT 적용. 새 화면/인간/원어민/물리/package 관측0.
