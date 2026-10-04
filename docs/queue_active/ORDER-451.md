# ORDER-451 — 폴드 상태와 일본어 정산·판돈 선택을 정확히 읽는다

#### [~] ORDER-451 [P1·UI 현지화] 기존 소비자3곳의 확인 결함

**[~] 착수 — 2026-10-05.** 홀덤 좌석의 직접영어 FOLDED와 JA 정산 POT,
단타 SETUP의 판돈 선택을 팟 오즈로 오독한 기존 번역을 한 묶음으로 수리한다.
450의 좌석/라벨 완료를 반복하지 않고 새 표시와 그 경계만 검수한다.

## 범위·소유

- root: `scenes/HoldemClub.gd`758행 한 줄, `locale/ui_ja.json` 두 값과
  `content/meta/full_game_localization.json`, private451 공식 교환/정상검사,
  CLAUDE·큐/L3·이 사양/보관·WORK_LOG·생성STATUS·새 독립 보고/판정.
- claude_handoff_review: `tools/holdem_money_history.py`·`tools/ui_translation_append.py`의
  정확 source 전이와 JA 두 값 정정/첫receipt 증명, 새 `tools/holdem_residual_locale_check.py`.
- receipt_tests392: private451 GD/scene/oracle/run 및 `tools/audit_scope.json`.
- independent392: 소비자·KO에서 직접 정정한 JA 의미·actual4PNG·정상검사 독립검수.
  root만 공식 교환·collector·검사·엔진을 실행한다. 파일 소유를 겹치지 않는다.

## 제품·수용 계약

- `title_lbl.text`의 folded일 때만 붙는 prefix를 동일 줄에서 바꾼다. 정확
  `ko/ja/zh-CN/zh-TW`에서는 기존 `_action_label("fold")`를 재사용하고 EN/community는
  기존 `FOLDED`를 보존한다. 조건·공백2·title·12px bold·좌석/게임 상태는 불변이다.
  `is_english()`는 non-KO 전체를 뜻하므로 exact EN 판별로 잘못 쓰지 않는다.
- JA `%s · POT %s 정산` 값은 `%s · POT %s 精算`→`%s · ポット %s 精算`,
  `판돈 선택` 값은 `ポットオッズ選択`→`ベット金額を選択`로만 정정한다.
  후자의 실제 소비자는 `ScalpingGame._show_setup:484`이며 제품Scalping 변경0이다.
  KO/EN·CN/TW·두 placeholder·금액/정산/입력 규칙은 보존한다.
- 기존71 UiCall·좌표·Entry ID와 collector는 불변이다. 실제 제품 parent/tree/blob/raw를
  관측한 뒤11번째 동일path 전이와 실제 manifest tuple 하나만 추가한다. 혼합 계보는 거부한다.
- JA 두 기존 값은 아직 accepted가 없어 official export/check/import 한 배치로
  정정2·첫receipt2를 구분한다. 새 키/coverage0, 예상accepted41755/b228이며 실제 수용 후
  확정한다. 사전3개수3053/1776/1776·기존receipt/배치·원어민/표시 원장OPEN은 보존한다.
  제품JA/원장의 정확 두 값/추가분 역상만 허용하고 미래 핀을 발명하지 않는다.
- 수용 후 기록 수리: 중간 `7aa0cd2`의 새receipt 필드에 raw 파일SHA를 넣은 root 오류를
  `2fdf435`에서 canonical unsigned digest로만 전진 수리했다. 두 실제 commit과 parent/tree/
  경로·바이트를 모두 증명하고 중간 후보 단독은 거부한다. 공식 교환·번역 재실행0이다.

## 표적 검수·완료 경계

- JA/CN/TW 준비형 SHOWDOWN3PNG에서 긴 상대 이름의 folded표시·unfolded좌석 및 실제
  summary detail을 함께 읽는다. 실제 `_tr`·`rank_name`·`_fmt`로 준비한 detail을 actual
  Label에 결속하되 `_do_showdown`·RESULT·Close·실제 정산은 호출0이다. summary pulse는
  자연종료 뒤 scale1을 직접 확인하고 font/glyph/폭/부모포함·겹침을 검사한다.
- JA Scalping SETUP1PNG는 기존 `_show_setup()`만 호출하여 실제13px bold heading을 읽는다.
  BGM/tutorial을 만드는 `open()`이나 PLAYING/Close/정산은 호출하지 않는다. 준비 전 overlay
  없음·process=false를 확인하고 Scalping 전체필드/RNG/process·배경버튼focus_mode/이웃과
  실제 semantic focus를 각각 복원한다. 원래 UI를 지우는 무조건 재빌드는 금지한다.
- 기존 격리 pre-autoload를 사용하고 wholetyped/RNG/Meta bytes/existence·semantic focus와
  실제player34를 보존한다. 원본4PNG 저자/비저자 직접 읽기, 실제3지역 folded/unfolded
  reader와 KO/EN/community의 exact조건 소스/순수표본을 구분한다. 미등록community의
  runtime/폰트 주입0이며 기존역사 suite나 이전 액션 입력 재실행0이다.
- 새 focused·receipt normal·JA UI·EN·context·queue·diff·등록8검증+차선조회1을 같은 clean
  후보에서 실행한다. CN/TW 사전 불변은 byte-exact·actual화면으로 확인한다. fullbody·ZH전체·
  과거 suite·whole audit·240주·새package는 NOT_RUN이다. 검사성능 변경은 별도 범위다.
- 기존211판정189보고·원449 REWORK·인간OPEN45/DONE1·공개GO1·본편/새package HOLD 보존.
  지시는 일회성이다. 자동 PASS는 계약 증거이며 원어민·인간·물리패드·자연진행·출시 GO가 아니다.
