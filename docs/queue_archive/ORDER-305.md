# Archived Queue Spec: ORDER-305

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [x] ORDER-305 [P0·출시 데모] 원룸 월세·선택 이름·거절 결과의 사실 정합

2026-09-27 착수. 기준 clean `f537c1ae44a5cc159a46e1c594f168186fc91670`.
사용자 승인302의 잔여2/6/7을 작은 별도 배치로 분리한다. A/B를 재저작하지 않는다.

## 깊이 3문과 판정 범위

- 원룸 월세55만원은 고시원65만원과 생활 선택의 설명을 어긋나게 한다. 승인된
  원룸 대사70만원으로 맞춘다. 보증금1000만원·관리비·실제 경제 계산은 보존한다.
- 고정 이름은 플레이어가 선택한 이름과 충돌하고 이중부정은 거절의 대가를 흐린다.
  새 선택/상태/보상/플래그는 만들지 않는다. 24주 차이·기회비용은 기존 선택 소유다.
- 이 배치는 사실·토큰·국소 문장 정합만 판정한다. EN 시제/인용 전수(302의5),
  실제 화면/입력·새 package·출시·원어민/인간/물리 관찰은 별도이며 부모302 HOLD다.

## 정확한 파일 소유

- root: `content/events/arc_events.json`의 meet description/orthodox/unorthodox
  `월 오십오`→`월 칠십`3leaf; answer choices[0].result_text의 `김민준`→`{name}`,
  choices[1].result_text의 `웃는다`→`웃었다`; clean.description의
  `받지 않은 200만원은 없었고`→`200만원은 들어오지 않았고`. KO6leaf.
- root: `content/events_en/arc_events.json` meet 동일3leaf의 `550,000`→`700,000`만.
- 지역 저자 `/root/release_status_crosscheck`: `content/events_ja/story_demo_events.json`,
  `content/events_zh-CN/story_demo_events.json`, `content/events_zh-TW/story_demo_events.json`.
  meet3leaf 월세 각55→70만(9), answer 결과0 이름을 `{name}`(3), clean.description
  JA/CN 이중부정을 KO 뜻에 맞춤(2). 지역14leaf, 총23leaf/5파일. EN/TW clean은 읽고 보존.
- root 기록: 큐 두 파일·부모302 연결·이 사양·WORK_LOG·생성 STATUS·CLAUDE 현재행,
  `docs/agent_review_decisions.json`의 새 작업 한정 판정(과거행 보존),
  private `.git/full-game-localization/order305-*` helpers/증거와 기존capture 새305 label.
- 비저자 `/root/blackjack_accounting_review`: private `order305-review*.json`과
  `docs/agent_reviews/ORDER-305.json`만. 제품과 검사기 저작 없이 전23leaf/보존 범위 대조.
- 역사 reader와 수량 관측의 호환은 별도306 소유. 그 밖 원고·gameplay·project.godot·
  공식accepted40299/b136/meta9·보류72·human45OPEN/1DONE·옛공개package는 변경하지 않는다.

## 표적 검증과 종료

정확 leaf/토큰(의도한 이름토큰4 추가)/개행·나머지 byte inverse, 언어coverage/Hangul·
story-demo localization·density 및 accepted핀 현재성, 306의 historical compatibility.
새 clean 후보에서 기존 M01~M06 다국어 전용 엔진1회: pre-autoload fresh32hex user namespace,
사용자43파일 전후 보존, exact marker 및 stdout/stderr/Godot로그 오류0를 요구한다.
전체/240주/legacy 엔진 감사는 실행하지 않는다. 실제 렌더/입력 관측으로 과장하지 않는다.
독립 전수 GO 뒤 이 작은 작업만 닫고302 잔여5/실제화면·새후보를 잇는다.
규범은 기존 WORK_UNIT/현지화 정본 적용 및 일회성이다. 자동 통과는 재미·문체·출시 GO가 아니다.

## 2026-09-27 완료 증거

- source: `59d4f790ecfd84f023c5796039264e4bfe72cdcf` / tree `0d6807438c512e5b3873c0a310d24e211612f0c1`.
- 도달 경로: `STORY_DEMO_FOUR_LANGUAGE_CHECK_OK locales=5 routes=5 months=30 weeks=120 settlements=30 ap_surface=0 save=5 story=10 build=2026.08.31.1`.
- 생산자↔독자: `content/events/arc_events.json`의 meet/answer/clean 및 지역4overlay ↔ `scenes/StoryMode.gd`; 원고23leaf/5파일, 나머지 full-byte inverse 동일.
- 바꾸는 상태: 월세55→70만(15leaf), 이름토큰+4, KO시제1, KO/JA/CN 거절표현3. gameplay/경제·선택/경로 변화0. 포기 시 잃는 것/장면 계층: 해당 없음(기존 M02/M04 사실 수리).
- 언어·보존·accepted40299·density PASS. localization 최초 CN/TW2오탐 FAIL은 그대로 보존하고308 후 정상/55self PASS. 신규 receipt0.
- 실제 엔진은 `354c270`에서1회/8.311초만 실행. exact marker·3로그 오류/누수0·ENTRY12 격리경로 일치·사용자43파일/1220실행핀 전후 불변. 최종 후보와는308 검사기/선언metadata만 다르며 `308-bridge-first`가 연결한다. 화면/입력 관찰0.
- [비저자 보고](../agent_reviews/ORDER-305.json): 전23leaf/보존범위·raw evidence 작업 한정 GO. 과거 공개/인간판정 불변,302전체·본편·새package HOLD.
- 닫는 것: 승인302의2/6/7만. 다음 EN문체5·실제화면·새후보는 부모302. 규범 승격: 없음(일회성/기존 정본 적용).
