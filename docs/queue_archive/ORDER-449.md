# ORDER-449 — 홀덤 테이블의 칩·공개 카드 라벨을 선택 언어로 읽는다

#### [x] ORDER-449 [P1·UI 현지화] POT/BOARD/STACK/BET 표시5곳

**후속 수리로 완료 — 2026-10-05.** 번역제품 `3090b03`의4키12값과 공식수용을 유지한다.
최초 후보 `74aeeb0`은 [독립 REWORK](../agent_reviews/ORDER-449.json)로 보존한다.
[450](ORDER-450.md)의 높이 한 줄 수리 후 새 후보 `7afed5a`에서 같은 번역 전량과
실제 행동UI를3PNG·39표면/복원3(27.829초), fresh9검증+조회1(623.320초)로 재검수했다.
[후속 독립 GO](../agent_reviews/ORDER-450.json)는 수리된 범위만 판정한다. 최초449
FAIL/정상검사NOT_RUN을 PASS로 바꾸지 않는다. accepted41753/b227·사전3053/1776/1776
및 인간/공개 이력·본편/새package HOLD 불변. 지시는 일회성·새 정본 규칙0이다.
자동 PASS는 계약 증거이지 재미·깊이·문체·원어민·인간·물리패드·출시 GO가 아니다.
아래 최초 실행과 착수 이력을 보존한다.

**[~] 배치 수리 대기 — 2026-10-05.** 실제 홀덤 화면의 직접 영어 라벨5곳을 한국어·일본어·
중국어로 읽도록 연결한다. 금액·공백·조건·폰트·배치는 유지한다. 기존 배너·규칙 설명과
다른 잔여 문자열은 이 범위가 아니며 전체 홀덤 현지화 완료로 부르지 않는다.

## 첫 실행 결과·후속 수리

- 코드bf26b99·지원7e84de5·번역3090b03·검수후보74aeeb0을 main에 커밋·푸시했다.
  공식3언어9명령 PASS·12receipt/3batch exact append PASS, accepted41753/b227이다.
- 준비형 실제3PNG 모두 좌석 패널이 테이블 아래6.2px를 넘어서 FAIL(27.771초).
  가로폭·고액 표본은 맞으며 글자 viewport 잘림은 보이지 않았다. 입력0·실제player34 불변.
  `.git/full-game-localization/order449-screen-first/result.json` SHA
  `fce0c2df547c277fe4b1d9f34ca89b7a92931a1909ab22f85ea645e13804de60`를 보존한다.
- 정상9검증은 선행 runtime 실패로 NOT_RUN이다. [450](ORDER-450.md) 높이 수리와
  새 후보 검수 후 함께 닫으며, 이 최초 후보를 PASS/GO로 소급하지 않는다.

## 범위·소유

- root: `scenes/HoldemClub.gd` 표시5줄, `locale/ui_ja.json`·`locale/ui_zh-CN.json`·
  `locale/ui_zh-TW.json`의4키, `content/meta/full_game_localization.json`, private449
  공식 교환/normal, CLAUDE·큐/L3·이 사양/보관·WORK_LOG·생성STATUS·새 보고/판정.
- claude_handoff_review: `tools/holdem_money_history.py`, `tools/ja_translation_pipeline.py`,
  `tools/ui_translation_append.py`의 정확한 EOF 전이/collector/manifest 연결,
  새 `tools/holdem_table_labels_receipt_check.py`.
- receipt_tests392: private449 GD/scene·Python oracle/runtime 및 `tools/audit_scope.json`.
- independent392: 비저자 지역어·소스/수용·실제3PNG·normal 최종 검수.
  root만 공식 교환·collector·검사·엔진을 실행하며 파일 소유를 겹치지 않는다.

## 표시·수용 계약

- `_render_table:548`의 POT+두 공백+금액, `_build_table_surface:611` POT·`:639` BOARD,
  `_build_holdem_seat:783` STACK+한 공백+금액·`:785` 앞 세 공백+BET+한 공백+금액만
  같은 줄의 `_tr`로 연결한다. `bet > 0`·`_fmt`·게임/RNG/입력/정산은 그대로다.
- bare KO/EN은 `팟/POT`, `공개 카드/BOARD`, `보유 칩/STACK`, `베팅/BET`다.
  JA는 `ポット/共通カード/持ちチップ/ベット`, CN은 `底池/公共牌/持有筹码/下注`,
  TW는 `底池/公共牌/持有籌碼/下注`로 한국어와 실제 소비자 의미를 직접 대조했다.
  STACK은 아직 내지 않은 칩, BET는 이번 라운드에 이미 낸 금액이지 추가 콜 금액이 아니다.
- 현재66 UiCall 위치·원문·Entry ID를 보존하고 새5호출/고유4키를 정직하게 수집한다.
  새호출은 EOF가 아니라 기존 함수 중간이므로 정렬된71호출 전체를 비교한다.
- source 단독 커밋의 실제 parent/tree/blob/raw를 관측한 뒤9번째 descriptor에 결속한다.
  기존 proof/collector prefix·seal은 보존하고 현재71/역사66을 구분한다. 미래 핀을 만들지 않는다.
- 새4키×3언어12값을 official export/check/import3배치로 수용한다. 기존 키/receipt 재발급0,
  accepted41741→41753/b224→227·JA3049→3053/CN·TW1772→1776다.
  사전3+원장의 추가분만 역상하면 직전 whole raw와 같아야 한다.

## 표적 검증·한계

- 신규 focused는 실제5줄 역상/9전이/현재71호출·새4Entry/12receipt·실제 manifest 계보와
  외부 코드/금액/조건/old target 변이 거부를 확인한다. 기존 suite를 재실행하지 않는다.
- JA/CN/TW 준비형 PREFLOP 각1PNG=3PNG. pot15000, player95000/bet5000,
  opp0 100000/bet0, opp1 90000/bet10000으로 총300000·hole6/deck46/board0을 준비한다.
  양수 BET2와 zero suffix 부재1, POT2·BOARD1·STACK3의 실제font/폭/경계/겹침을 본다.
- 11px 좌석은 별도로500k/500k·1m/500k·1.49m/10k의 소수 고액 문자열 폭만 측정한다.
  이는 합성 표본이며 전체 최대치·실제 진행 보장이 아니다. 실제 부족하면 기준을 완화하거나
  글자를 몰래 줄이지 않고 별도 배치로 수리한다. whole typed/RNG/Meta bytes/existence·
  semantic focus 복원3·실제player34 보존, 입력/딜/AI/정산/Close0이다.
- fresh focused·receipt normal·JA UI·ZH·EN·context·queue·diff·등록9검증+차선조회1.
  사건 본문/fullbody·과거 focused/runtime·서사4종·whole audit/240주/성능 A/B·새package는
  NOT_RUN이다. 공식 leaf check3회는 별도 증거이며 이전448 결과를 새 실행으로 부르지 않는다.
- 기존209판정187보고·인간OPEN45/DONE1·공개GO1·본편/새package HOLD를 보존한다.
  지시는 일회성이다. 자동 PASS는 계약 증거이며 원어민·인간·물리패드·자연 진행·출시 GO가 아니다.
