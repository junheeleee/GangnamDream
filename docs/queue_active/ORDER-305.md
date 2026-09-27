# Active Queue Spec: ORDER-305

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-305 [P0·출시 데모] 원룸 월세·선택 이름·거절 결과의 사실 정합

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
