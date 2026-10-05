# ORDER-447 — 홀덤 행동·단계 배너를 선택 언어로 읽는다

#### [x] ORDER-447 [P1·UI 현지화] 영어 직접 배너와 쇼다운 요약 제목

**완료 — 2026-10-05.** 코드 `8a18431`·지원 `5ac51c9`·번역 `739e64b`·검수 후보
`fc1c1c2`를 main에 커밋·푸시했다. 기존 액션/단계 번역을 재사용하며 새 핸드1키만
3언어로 수용했다. accepted41740/b220·JA3049/CN·TW1772, 실제 UiCall66이다.
실제 JA/CN/TW9PNG·39배너·요약제목3·39준비표시·3그룹 복원 PASS(62.544초),
입력/딜/AI/정산0·실제player34 불변. 저자와 비저자가9원본을 모두 직접 읽었다.
같은 후보의 fresh9검증+조회1 PASS(528.598초), focused67/과거0·등록184다.
[독립 보고](../agent_reviews/ORDER-447.json)가 source/tree·증거·한계를 결속한다.
공식 export 전 literal HEAD 사전조건 실패는 subprocess 실행 전 차단으로 보존했고,
source hash 계측 가정은 엔진 실행 전에 고쳤다. 공식9회와 runtime/normal은 첫 실행 PASS다.
지시는 일회성·새 정본 규칙0. 자동 PASS는 계약 증거이며 원어민·인간·물리패드·
자연 진행·본편/새package GO가 아니다. 아래 착수 이력을 보존한다.

**[~] 착수 — 2026-10-05.** 실제 445·446 화면에서 행동/단계 배너와
쇼다운 요약 제목에 직접 영어가 남았다. 기존 번역을 재사용하고 첫 판에도 맞는
`새 핸드 / New Hand` 한 키만 새로 추가한다.

## 범위·소유

- root: `scenes/HoldemClub.gd`의 아래 표시 인자와 EOF helper,
  `locale/ui_ja.json`·`locale/ui_zh-CN.json`·`locale/ui_zh-TW.json`의 새1키,
  `content/meta/full_game_localization.json`, private447 공식 교환/normal,
  CLAUDE·큐/L3·이 사양/보관·WORK_LOG·생성STATUS·새 보고/판정.
- claude_handoff_review: `tools/holdem_money_history.py`, `tools/ui_translation_append.py`,
  `tools/ja_translation_pipeline.py`의 정확한 새 전이/현재 view EOF 확장,
  새 `tools/holdem_banner_locale_receipt_check.py`.
- receipt_tests392: private447 GD/scene·Python oracle/runtime와
  `tools/audit_scope.json`의 표적 차선.
- independent392: 비저자 3언어·소스/수용·실제 화면·보존 및 최종 검수.
  root만 공식 교환·collector·검사·엔진을 실행하며 파일 소유를 겹치지 않는다.

## 표시 계약

- 플레이어/상대 액션8곳은 기존 `_action_label(...).to_upper()`를 쓴다.
  AI는 원래 이름과 두 공백을 유지한다. EN 대문자를 보존하고 JA/CN/TW를 읽는다.
- EOF `_phase_banner_label(token)`에서 NEW HAND/FLOP/TURN/RIVER/SHOWDOWN
  5개만 명시적 `_tr`로 매핑하고 번역 뒤 대문자화한다. 기존 phase4키를 재사용한다.
  NEW HAND는 `새 핸드 / New Hand`다. `다음 핸드`로 뜻을 바꾸지 않는다.
- 첫 핸드·단계 전환·쇼다운 배너의 표시 인자3곳과 summary kicker1곳만 helper에
  연결한다. 내부 FLOP/TURN/RIVER 토큰·new_cards 조건·정산/돈/AI/AP는 불변이다.
- `_show_table_banner`·`_flash_message`·배너 크기/위치/tween은 그대로다.
  POT/BOARD/STACK 및 다른 UI·별도 오역은 이 범위에 포함하지 않는다.
- 기존61 UiCall의 위치·원문·owner는 보존하고 EOF의5호출을 실제 수집한다.
  current view는66호출·unique KO+1이다. 과거61개로 가장하거나 새 lookup을 숨기지 않는다.
- 새1KO·3값만 공식 export/check/import로 수용한다. 기존 번역/receipt 재발급0,
  목표 accepted41737→41740/b217→220·JA3048→3049/CN·TW1771→1772.
  소스 단독 제품 커밋의 관측 핀에 현재 collector successor를 연결한 뒤 공식3배치를
  수용하고 사전/원장 제품 커밋을 분리한다. 미관측 핀을 미리 발명하지 않는다.
- exact whole-file 역상·새8번째 Holdem descriptor와 실제 manifest tuple1개만
  더한다. 기존 collector/과거 proof 본문·seal·인간/공개 판정은 보존한다.

## 표적 검증·한계

- 신규 focused는 실제 call/leaf/66현재 view·기존61보존·새 전이/manifest·3receipt와
  게임 규칙/외부 바이트 변형 거부를 확인한다. 기존 suite를 다시 실행하지 않는다.
- JA/CN/TW 각각13개 배너 문구와 kicker를 실제 표시·폰트/glyph/fit/bounds로
  측정하고 NEW HAND·가장 긴 실제 AI 조합·SHOWDOWN 대표3PNG, 총9PNG를 본다.
  준비 reader/표시 호출로 한정하며 첫딜/dispatcher/AI/정산/입력/Close0이다.
- 기존 배너 lifecycle·전체 베팅/규칙 설명 회귀는 불변 증거를 참조한다.
  whole typed/RNG/Meta bytes/existence·semantic focus와 실제player34를 보존한다.
- fresh focused·receipt·JA UI·ZH·EN·context·queue·diff·등록9검증+차선조회1.
  fullbody·과거 focused/runtime·서사4종·전체감사/240주/성능 A/B는 NOT_RUN.
- 기존207판정/185보고·인간OPEN45/DONE1·공개GO1·본편/새package HOLD를 보존한다.
  지시는 일회성이고 자동 PASS는 원어민·인간·물리패드·자연 진행·출시 GO가 아니다.
