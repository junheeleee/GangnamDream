# Active Queue Spec: ORDER-388

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-388 [P1·전체 현지화] 은행·대출 중국어 UI 10키를 지역별 직접 번역한다

**[~] 2026-09-29 Codex 착수 — 아래 파일만 소유한다.** ORDER-157의 사용자
전체판 번역 위임과 검수 효율화 지시를 따른다. 읽기전용 후보
`.git/full-game-localization/order385-next-bank-candidate.json`의 10키×2지역을
현재 원문·공식 collector에서 다시 결속하고 별도 수용한다.

## 깊이 3문

1. 없애면 무엇이 깨지는가: 은행 탭의 AP 무소비·신용·월 이율·대출잔액/한도·
   상환·2배 포지션 안내가 중국어 대신 영어로 남는다. 원금/예금/연 이율로
   오독하지 않게 실제 소비자 의미를 옮긴다.
2. 24주 뒤 상태 차이: 새 선택·경제가 아니라 기존 대출/상환의 표시 번역이다.
   실제 잔액·금리·AP·정산·해금조건은 변경0이며 원화 가치와 숫자를 보존한다.
3. 경쟁: 전체 미완료 UI와 실제 화면 검수 시간이 경쟁한다. 두 지역 20값을
   전수 독립 문장 검수하고 바뀐 소비자만 렌더한다. 불변 역사 self/전체감사/
   240주 반복이나 새 호환 모듈 저작을 하지 않는다.

## 정확한 소유와 모집단

- 제품은 `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json` 신규 각10키와
  `content/meta/full_game_localization.json` 해당 공식 수용/영수증 append만.
- 한국어 키: `은행 / 레버리지`, `대출은 행동력 무소비`,
  `신용 %d등급 (%s) · 점수 %d/100`, `레버리지 투자 — 2배 포지션`,
  `2배 포지션 창구는 아직 주문을 받지 않습니다. 손실 경고와 빠져나올 가격이 먼저 보일 때까지 주문서를 더 읽어 보세요.`,
  `%s · 월 %.2f%%`, `잔액 %s / 한도 %s`, `500만 상환`, `전액`,
  `현재 실행 가능한 대출/상환 버튼이 없습니다.`
- Root: 공식 export/check/import·수용 연결·표적 정적검증·기록.
- 별도 저자 `/root/compat357`: private `order388-zh-CN-draft.json`과
  `order388-zh-TW-draft.json`만 한국어에서 각각 작성. 간번 변환 금지.
- 화면 저자 `/root/screen_path_probe`: private `order388-check.gd`,
  `order388-check.tscn`, `order388-run.py` 및 준비·폭·화면 증거만.
- 비저자 `/root/r3_route_probe`: 번역20값 전수·실제 PNG/기록 직접 검수 후
  exact source의 work_unit GO/HOLD. root와 화면 저자의 자기승인으로 대체하지 않는다.
- 기록: 이 사양·큐2개·CLAUDE·WORK_LOG·필요시 기존
  `docs/history/WORK_LOG_2026-09-07_localization.md`의 손실 없는 이동·STATUS,
  `docs/agent_reviews/ORDER-388.json`·`docs/agent_review_decisions.json`·
  `docs/queue_archive/ORDER-388.md`; git-private `order388-*` 교환/실행/검수 증거.

## 표적 검증과 제외

- 원본 export 보존, 응답 token/숫자/지역문자 검사, 한국어 전수 독립 검수,
  실제 노드 폭 확인 후 공식 수용, 기존 raw 역삭제와 수용/공개문구 불변 확인.
- 현재 UI append guard와 영향 consumer5 정상 검사, 중국어 언어검사,
  context/queue/diff와 기존 overlay 차선 조회만. 검사기 변경0·self 재실행0.
- 실제 MainGame 은행 소비자의 신용·부채/무부채·대출불가·레버리지 잠김/열림을
  최소 준비상태로 관측한다. 1280×800 SC/TC font·glyph·문구·경계·PNG를 결속한다.
  준비 주입은 자연 플레이·원어민·인간·물리·실제 대출거래 증거가 아니다.
- 동적 대출상품명·신용등급 형용사4키·패드 부모 템플릿·시장/레버리지 거래·
  레거시 은행 전체 화면은 제외. `500만 상환`의 공유 호출은 추적하되 전체
  은행 완역으로 부르지 않는다. 새 런타임 결함은 별도 선언한다.
- KO/EN/JA·런타임·경제·저장·project.godot·공개데모·사람원장·출시언어 불변.
  기존151판정/129보고와 실패/GO/OPEN/HOLD를 보존하며 외부 권한을 행사하지 않는다.
- 기존 I18N 정본과 append 절 재사용. 범위·모집단·검증 계획은 일회성이다.
  자동PASS는 계약 증거이며 재미·깊이·문체·출시/사람GO가 아니다.
