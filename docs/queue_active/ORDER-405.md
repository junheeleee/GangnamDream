# ORDER-405 — 돈·투자 모달 중국어 안내 16종

#### [~] ORDER-405 [P1·현지화] 돈·투자 모달 중국어 안내 16종

**[~] 착수 — 2026-10-04.** 부모157. 사용자 계속 개발·검수·main 동기화 위임.
404의 같은 카테고리 카드 소비자 조사에서 CN/TW 누락16키·JA존재16키를 확인했다.
한국어에서 직접 CN/TW16키씩32값, 언어당 공식1교환 batch로 번역한다.

## 판정 단위·깊이3문

- 제거하면 돈 모달의 잠금 조건·알바/투자/절약/시장분석과 비용·효과 안내가 영어로 남는다.
- 번역만 바꾸며 돈/AP/건강·스트레스/기간·원화값/잠금·실행·예측 조건은 바꾸지 않는다.
  24주 선택 차이·새경쟁 선택은 해당 없음. 확률·수치·게임 재설계가 아니다.
- 한 메뉴 실제소비16키를 묶고 밖의 진입카드 preview2키는 추가하지 않는다.
  공용 제목/미리보기가 다른 화면에도 번역되는 것과 실제관측 범위를 분리한다.

## 정확한 모집단·소비자

MainGame::_open_cat_money(15151) → _cat_modal_button;
_side_shift_title(15130)·_ap_action_preview(13831)의 실제호출분기.

1. 돈 · 투자
2. 월급만으론 30억에 닿을 수 없다. 돈이 돈을 벌게 해야 한다.
3. 투자 집중  —  차트를 들여다본다
4. 시장 분석  —  다음 달 방향을 무료로 예측한다
5. 잠금: 투자는 상철과의 대화 후 가능하다.
6. 잠금: 투자는 첫 월급을 받은 뒤 가능하다.
7. %s  —  %s+ (끝난 뒤 몸이 무거워진다)
8. 저축/절약  —  이번 달 지출을 줄인다
9. 추가 야간 시프트
10. 추가 배달
11. 단기 알바
12. 주말 부업
13. 자산별 위험 1~5 · 거래 확정 AP 1 · 1~3주: 결산 변동
14. 중간 위험 · AP 1 · 현금 %s+ · 건강 기본 -3 · 1~3주: 피로
15. 낮은 위험 · AP 1 · 현금 +3만~10만 · 스트레스 +2 · 1~3주: 월세 여유
16. 이후  이번 주가 지나도 남는다

16번은 시장분석의 icon=market이 실제 읽는 fallback이다. 다른 preview로 대체하지 않는다.
%s 두인수/한인수, 30억원·3만~10만원·기본건강−3·스트레스+2·기간·위험범위를 보존한다.
인명은 승인된 로마자·지명/통화는 중국어 용어집. raw gameplay/source/기존번역 불변.

## 파일 소유

- Root: locale/ui_zh-CN.json·locale/ui_zh-TW.json 새16키씩,
  content/meta/full_game_localization.json 새32receipt/2batch 공식수용만.
  private order405-zh-CN-draft.json·order405-exchange*·order405-static-* 및
  공식교환/receipt/append 검증자료.
- /root/receipt_bridge392: private order405-zh-TW-draft.json만 한국어 직접저작;
  CN 변환/중역·tracked/검사기 수정0.
- /root/receipt_tests392: private order405-check.gd·.tscn·order405-run.py,
  새 oracle/원본로그/PNG·order405-screen-*만. 이전helper/증거불변.
- /root/independent392: 비저자32값 전수 의미·문자·수치·포맷/실제소비/화면검수,
  private order405-independent-review.json만.
- Root 기록: 본 사양·큐2·CLAUDE·WORK_LOG·STATUS,
  docs/history/WORK_LOG_2026-10-04_pre_order405.md(구현 전 WORK_LOG 전체를 byte-exact 이동;
  새역사파일은 metadata wrapper가 아니므로405 새후보 동결 전에 반영),
  docs/agent_reviews/ORDER-405.json·docs/agent_review_decisions.json·완료archive.
- MainGame/FontKit/게임/검사기/project.godot/공개demo/인간원장 변경0.
  새 결함은 별도선언, 과거 work_unit GO 승계0.

## 표적 검증

- 공식 export/check/import와 source/target freshness, 32값 전수 독립검수,
  기존 UI/receipt raw 역삭제·append-only. 과거수용/헤더/메타 재작성0.
- 실제 MainGame1280×800 언어당4fixture, 총8PNG:
  - A current_job={}·paycheck=false·guidance=false·investment_skill0: 단기알바+절약2카드.
  - B 실제job_01 복사·paycheck=true·guidance=false: 야간시프트+절약2카드.
  - C 실제job_02 복사·paycheck=true·guidance=true·skill49: 투자/추가배달/절약3카드.
  - D 실제job_03 복사·paycheck=true·guidance=true·skill50: 투자/무료시장분석/주말부업/절약4카드.
  - jobs를 새로 발명하지 않고 DataRegistry 실물을 복사한다. 지급액과 원화는
    _side_shift_base_pay → ArubaGame.get_base_pay 및 GameState.format_money의 실제값을
    두%s 소비위치에 결속한다. 피로를 즉시 체력상실 확정문으로 바꾸지 않는다.
- union16키/locale의 제목·설명·잠금·split title/subtitle·preview 실제노드와
  lookup·source-bound 함수/인수를 확인한다. 신규번역 text-fit/SC·TC font,
  card82/모달/이웃bounds를 측정한다. 기존ellipsis 면제를 자동승계하지 않는다.
- fresh pre-autoload StoryNameplateBootstrap 격리·새namespace·typed 깊은복원·
  실제 사용자34파일과source/helper hash불변. actual getter warmup만 기록,
  사전/font/theme/cache주입0. 입력/confirm/pressed/알바·거래·예측실행/finalizer0.
  prepared state를 자연취업·스토리진입·Back/물리패드 관측으로 부르지 않는다.
- runtime 먼저, 통과후 current UI receipt+normal 소비자5·ZH/EN·context/queue/diff,
  변경파일 audit_select 조회1. Chapter1 720초/최대3병렬. 소스/JA/검사기 불변으로
  이전focused/화면전체/역사self/전체감사/240주 반복0. 실패는 원본보존 후 해당영향만 재검증.
- 발견한 별도잔여: employed 일메뉴의 승진35%표시(MainGame:15113)는 숨은정확확률
  비노출 규칙(CLAUDE:84)과 충돌한다. 본16키와무관하며 KO/EN·기존JA source/receipt까지
  함께 다뤄야 하므로 이 번역에 섞지 않는다. 별도source수리 사양으로 남긴다.
- 상시규범0/일회성. I18N·WORK_UNIT·gangnamdream-dev 적용.
  공개GO1/인간OPEN45·본편/새packageHOLD 유지. 자동PASS≠재미/문체/출시GO.
  원어민/인간/물리·다른화면/해상도·자연행동/Back 미관측. 외부출시/스토어/지출/법률0.
