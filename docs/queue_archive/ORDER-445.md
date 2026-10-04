# ORDER-445 — 홀덤 행동 배너가 팟과 이전 배너를 가리지 않는다

#### [x] ORDER-445 [P1·UI 수리] 중앙 배너/POT 및 연속 배너 겹침

**완료 — 2026-10-05.** 제품 `ddece4c`·검수 후보 `dbc0ede`를 main에 반영했다.
실제 CN/TW4PNG·108표면·준비2그룹 typed/Meta/RNG/focus 복원 PASS(22.017초),
입력/AI/첫딜/정산0·player34 불변이다. fresh7검증+조회1 PASS(462.286초),
focused54/historical0·accepted41736/b216 불변. [독립 보고](../agent_reviews/ORDER-445.json)가
정확한 source/tree·원본·세 실패·미관찰 한계를 결속하며 이 수리만 GO다.
첫 freed 인수/예외 기록, 중복 obstacle, summary pulse local/global 가정의 검수
결함 세 번은 원본 FAIL로 보존하고 helper만 수리했다. 제품 변경 추가0이다.
지시는 일회성·새 정본 규칙0. 자동 PASS는 계약 증거이며 원어민·인간·물리패드·
자연 진행·본편/새package GO가 아니다. 아래 착수 이력을 보존한다.

**[~] 착수 — 2026-10-05.** 442 실제 CN/TW RAISE·SHOWDOWN PNG에서 중앙
배너가 POT과 겹치고 이전 AI 배너도 남는 것을 확인했다. 최신 main 커밋/푸시·
계속 개발 위임에 따라 같은 배너 컴포넌트의 두 겹침만 별도 수리한다.

## 범위·소유

- root: `scenes/HoldemClub.gd::_show_table_banner`만, private445 Python
  oracle/runtime/normal, CLAUDE·큐/L3·이 사양/보관·WORK_LOG·생성STATUS·새 보고/판정.
- claude_handoff_review: `tools/holdem_money_history.py`와
  `tools/ui_translation_append.py` EOF의 정확한 새 Git 전이·manifest 호환,
  새 `tools/holdem_banner_receipt_check.py`. 기존 prefix/검사/증거는 불변이다.
- receipt_tests392: private445 GD/scene 및 `tools/audit_scope.json` 표적 차선만.
- independent392: 비저자 제품/계약/계측 원문·실제 PNG·보존 및 최종 범위 검수.
  root 외 collector·공식 검사·엔진 실행0. 파일 소유는 겹치지 않는다.

## 수리 계약

- 배너를 같은 크기·x중앙 그대로 하단24px 여백에 둔다. `_show_table_banner`의
  빈문자 early return 뒤 같은 Holdem 소유자의 direct Control 자식 중 전용
  `holdem_table_banner` metadata가 정확히 true인 기존 배너만 hide한다.
  새 panel에 같은 tag를 붙인다. 외부/untagged Control은 숨기지 않는다.
- 기존 tween·duration·queue_free 시점은 바꾸지 않는다. old 배너는 화면만
  숨기며 살아있는 tween이 자연 완료하도록 둔다. empty 호출은 기존 배너를 유지한다.
  텍스트·색·폰트·배팅/AI/딜/돈/AP/승패·타이머·다른 강조는 변경0이다.
- 이 함수는 마지막61 UiCall 뒤에 있으므로 기존 call의 literal/줄 좌표는
  유지한다. 함수 전체 정확한 역상으로 나머지 파일 불변을 확인한다.
  기존6전이의 공통 Git reader를 재사용하고 새 전이6요청행(신규 고유OID5개)을
  더한다. 전체7전이는42요청행/36고유OID다.
  과거 proof 본문을 복제하거나 현재 disk/HEAD를 과거로 가장하지 않는다.
  실제 직전 manifest 하나만 수용하고 합성 조합은 늘리지 않는다.

## 표적 검증

- 신규 focused: whole-function 역상·외부변경/타이머/태그/빈문자 반례,
  새 실제 Git 전이/current binding·현재 collector/61 UiCall/원래 수용 계약.
  기존 focused 재실행0이며 새 검사도 등록한다.
- 실제 CN/TW × FLOP RAISE·겹치는 시점의 SHOWDOWN 4PNG. Main 소유 Holdem에
  합법 준비 상태와 실제 요약 패널/버튼을 표시하고 제품 배너 함수를 호출한다.
  게임 dispatcher/AI/입력/첫딜/정산은 실행0이며 자연 진행 증거로 부르지 않는다.
- 실제 배너/pot/board/seat/메시지/버튼 경계·폰트/glyph·가독성, old alive/hidden·
  원래 tween 계속/자연해제, empty/no-tag 무영향을 post-draw로 관측한다.
  배너 자연종료 뒤 whole typed/RNG·Meta 원래bytes·semantic focus·player34를 보존한다.
- fresh focused·receipt·EN·context·queue·diff·등록의7검증+차선조회1.
  번역/본문이 불변이므로 JA/ZH/fullbody·과거 focused/runtime·서사4종·전체감사/
  240주·성능 A/B는 NOT_RUN 참조다. 실패는 원문 보존하고 원인만 수리한다.

## 한계·일회성

- 새 선택/24주 인과가 아니라 읽는 순간 팟과 행동이 덮이는 기존 UI 결함 수리다.
  직접 영어 배너·JA 포카드 오역·다른 해상도/장치·임의 장문은 별도 범위다.
- 번역 accepted41736/b216·JA3048/CN·TW1771, 기존205판정/183보고,
  인간OPEN45/DONE1·공개GO1·본편/새package HOLD와 사용자 변경을 보존한다.
- 지시는 일회성·새 정본 규칙0. 자동 PASS는 계약 증거이며 재미·원어민·인간·
  물리패드·외부 출시 GO가 아니다.
