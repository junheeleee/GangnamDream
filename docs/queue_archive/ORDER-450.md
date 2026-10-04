# ORDER-450 — 홀덤 플레이어 좌석을 테이블 영역 안에 둔다

#### [x] ORDER-450 [P1·UI 배치] 실제 좌석 최소 높이 수리

**완료 — 2026-10-05.** 제품 `138caec`·검수 후보 `7afed5a`를 main에 커밋·푸시했다.
높이360→420 한 줄로 플레이어 좌석 최소107px에109.2px를 할당했고, 실제 하단516.6은
테이블 하단525 안에 든다. 기존449 번역12값·71호출·게임 규칙은 그대로다.
동일 clean 후보의 JA/CN/TW 실제3PNG·39표면·18버튼/15semantic/3메시지·전체
typed/RNG/Meta/semantic focus 복원3 PASS(27.829초), 입력/딜/AI/정산0·player34 불변이다.
저자와 비저자가3원본을 직접 읽었다. fresh9검증+조회1 PASS(623.320초), 새focused42/
과거0·등록187. [독립 보고](../agent_reviews/ORDER-450.json)는 수리 후449 번역과450
좌석/행동UI 표시 범위만 GO로 결속한다. 원449 최초FAIL/REWORK·정상검사NOT_RUN은
그대로 보존하며 소급 GO가 아니다. 기존209판정187보고를 보존하고 두 판정/보고를
추가해211판정189보고다. 인간OPEN45/DONE1·공개GO1·본편/새package HOLD는 불변이다.
자동 PASS는 계약 증거이지 재미·깊이·문체·원어민·인간·물리패드·자연진행·전체 출시
GO가 아니다. 지시는 일회성·새 정본 규칙0이며 아래 착수 이력을 보존한다.

**[~] 착수 — 2026-10-05.** 449 준비형 JA/CN/TW 화면 모두에서 테이블 높이360에
플레이어 좌석 최소높이107이 들어가지 않았다. y364.2+107=471.2가 부모 아래465를
6.2px 넘는다. 글자 자체의 viewport 잘림은 관찰하지 않았다. 폭/폰트/번역은 정상이며
449 첫 실패 원본은 보존하고 정상검사449는 미실행으로 둔다.

## 범위·소유

- root: `scenes/HoldemClub.gd`의 테이블 최소높이 한 줄, private450 normal,
  CLAUDE·큐/L3·449/450 사양/보관·WORK_LOG·생성STATUS·새 독립보고/판정.
- claude_handoff_review: `tools/holdem_money_history.py`, `tools/ui_translation_append.py`의
  정확 전이 연결 및 새 `tools/holdem_seat_height_receipt_check.py`. collector 파일은 불변이다.
- receipt_tests392: private450 GD/scene/oracle/run 및 `tools/audit_scope.json`.
- independent392: 실제 소스·12번역·3PNG·새 정상검사 최종 독립검수.
  root만 검사·collector·엔진을 실행한다. 기존449 helper/실패 증거/검사는 수정하지 않는다.

## 수리 계약

- `_build_table_surface:585`의 `Vector2(0, 360)`을 `Vector2(0, 420)`으로만 바꾼다.
  실제 최소107/(0.98−0.72)=411.54보다 큰420으로 할당109.2를 확보한다.
  앵커·폰트·글자·금액·카드·게임/RNG/입력 규칙·71 UiCall과 기존 Entry ID는 불변이다.
- 실제 선언/제품 commit을 읽은 뒤10번째 source 전이에 결속한다. 정확 한 줄을 역상하면
  449 제품 whole raw다. 기존 support prefix·seal을 보존하고 collector는 현재71호출과
  새 leaf0을 증명한다. source manifest는 실제 새 계보만 추가하고 혼합 계보는 거부한다.
- 번역 사전3/원장/공식449 수용12값은 byte-exact다. 새 export/check/import0,
  accepted41753/b227·JA3053/CN·TW1776 그대로이며 이전 수용을 재발급하지 않는다.

## 표적 검수·완료 경계

- JA/CN/TW 각 준비형 PREFLOP 1PNG, 동일 총300000/카드52 상태와6라벨·4lookup·
  고액3쌍 합성 폭 표본을 읽는다. 좌석3개의 부모 포함·할당 폭/높이·겹침을 강제한다.
  실제 행동 UI를 표시만 하여 아래 메시지/버튼 영역과 좌석의 겹침도 확인한다.
  표시 준비로 바뀐 pad signature/index는 관측하고 입력·베팅·딜·AI·정산·Close는0이다.
- 실제font/glyph/fullfit/nominal 경계를 낮추지 않는다. whole typed/RNG/Meta/focus 복원3,
  실제player34 보존. 449 원본3PNG의 실패를 삭제하거나 새 PASS로 바꾸지 않는다.
- 새 focused·receipt normal·JA UI·ZH·EN·context·queue·diff·등록9검증+차선조회1을
  동일 clean 후보에서 실행한다. 사건 본문/과거 suite/whole audit/240주/성능/새package는
  NOT_RUN이다. 정상검수는449의 실패 이후 수리된450 후보를 검증하며 최초449 GO가 아니다.
- 저자와 비저자가 실제 새3PNG를 읽고449 번역과450 높이 수리를 함께 판정한 뒤 두 범위를
  닫는다. 현재209판정187보고·인간OPEN45/DONE1·공개GO1·본편/새package HOLD 보존.
  지시는 일회성이다. 원어민·인간·물리패드·자연진행·다른 해상도·출시 GO를 주장하지 않는다.
