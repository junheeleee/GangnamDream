# ORDER-432 — 기록창이 지역별 본문 서체를 실제로 사용한다

#### [x] ORDER-432 [P1·UI 수리] Main 기록 normal_font 1줄과 정확한 영수증 successor

**[x] 완료 — 2026-10-04.** (착수·실패 기록은 아래 보존.) 431 첫 실제 CN/TW 승리·손실 검수에서 기록창의
resolved normal이 FontKit이 아닌 Open Sans SemiBold로 확인됐다. ThemeDB fallback만으로
RichTextLabel 기본 theme font를 바꾸지 못한 결함이다. 번역10값·정산4회·상태복원은
별도 증거이며, 글꼴 실패를 통과로 바꾸지 않는다. 본편/새package HOLD.

## 범위와 소유

- root 제품: `scenes/MainGame.gd`의 log_box normal_font를 이미 로드한 `_font_regular`에
  연결하는 1줄만. 크기13·문구·BBCode·정산·입력·게임 수치·save는 변경하지 않는다.
- claude_handoff_review: `tools/main_game_locale_history.py`, `tools/ui_translation_append.py`
  기존 본문/pin 보존 후 새 exact Main 1줄 Git successor·역상·manifest 경계만 append.
  새 `tools/log_body_font_receipt_check.py`와 `tools/audit_scope.json`의 표적 등록.
  원래 Scalp/Main 조합 역사와 현재 실제 census를 구분하고 존재하지 않은 조합은 거부한다.
- receipt_tests392: 새 private432 runtime/normal helper만. 431 first/helper/교환 원본 수정0.
  root만 실제 엔진·표적 검증 실행. independent392는 비저자 source/표적 증거 최종검수.
- 기록: CLAUDE, CODEX_QUEUE/L3, active/archive431/432, WORK_LOG, 생성STATUS,
  agent review 보고/원장. locale3·수용원장·인간원장·공개package 변경0.

## 판정·검증

- 삭제하면 실제 log normal이 기본서체로 되돌아간다. 새 선택·24주 상태·경쟁 없음:
  동일 결과 문장의 지역별 glyph/가독성 수리다. bold는 이 기록에서 사용되지 않아 수정0.
- 제품1파일1줄 commit을 분리하고 exact parent/tree/blob/raw/inverse를 영수증 검증에 결속.
  기존 검사의 판정 완화나 과거 실패/수용기록 재작성 금지. 새focused는 실제 Git 전이와
  입력 경계 반례를 분리하고 source/HEAD 변조·phantom manifest를 거부한다.
- 431 first 원본 FAIL 보존. 새 clean 후보에서 CN/TW 결과·기록8PNG/실제 정산4회/
  안전한 합성입력/typed·Meta·UI 복원을 1회 다시 확인한다. 실제 player34 원본 불변.
  정상 font source/400weight/SC·TC fallback·glyph/13px 소비를 노드에서 확인한다.
- 같은 후보에서 새focused+공통normal1회. 과거focused 전체·429/430화면·전체감사·240주
  반복0. 원어민/인간/물리 패드·자연매매/진입·Holdem 공유 결과 소비자 미관측 유지.

일회성 exact 수리·검수이며 새 상시규범0. 자동PASS는 계약증거이고 품질·출시GO가 아니다.

## 최종 범위한정 판정 — 2026-10-04

- 제품732394c는 Main log normal_font를 _font_regular에 연결한 정확1줄이다.
  parent807fb82·두tree/blob/전체바이트 역상,14단계 실제Git와15개 실제historical 조합을
  새focused118case/1.610초로 확인했다. 가상Main/Scalp 조합과 다음호출 변조는 거부한다.
- 검수후보 source31f6751b2bea7fb0155d24eb953e3200e6f09145 / treef570ca6214c99e1bb29121c0b3a8b6d761530738.
  비저자 원본8PNG와 공통13검증+조회1의 판정/해시는 ../agent_reviews/ORDER-432.json.
- runtime39.533초·8PNG·56raw/28taps·실제정산4회 PASS. 기록4곳의 normal/regular/
  ThemeDB fallback identity일치, SC/TC regular400·13px·123glyph 소유/비0와 전체fit를 확인.
  기존431 observer marker는 그대로 사용하고 outer unit432로 구분했다. helper font주입0.
- 공통normal874.151초 PASS, tracked3035·이전증거2619·현재helper2·runtime135·
  실제player34의 전후맵 불변. 원431첫FAIL·REWORK를 덮지 않았으며 과거focused·
  완료429/430화면·전체감사·240주·A/B 재실행0이다.
- 자연매매/진입·Retry/Leave확정·hover·공유Holdem결과·전체HUD갱신·bold실제소비·
  원어민/인간/물리패드 미관측. 본편/새packageHOLD·공개GO1·인간OPEN45/DONE1 유지.
- 규범 검토: exact 수리·증거 절차는 일회성. 기존 FontKit/UI·WORK_UNIT 규칙을 따르며
  새 상시규범0. 자동PASS는 계약증거이지 재미·문체·출시GO가 아니다.
