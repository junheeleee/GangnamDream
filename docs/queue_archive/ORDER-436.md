# ORDER-436 — 홀덤 베팅 칩의 원 단위 금액 잘림 수리

#### [x] ORDER-436 [P1·숫자 가독성] 실제 글자 폭으로 베팅 금액 중앙 정렬

**[~] 착수 — 2026-10-04.** 434의 실제 5언어 첫 패에서 확인한 별도 표시 결함이다.
EN 10,000 won=52px, JA 10,000/5,000ウォン=61/55px, CN/TW 10,000韩元/韓元=51px가
기존 draw 폭48px를 넘는다. 10PNG에서 접미사 잘림5건을 독립 확인해 434는 REWORK다.

선언dc9bc1e 뒤 제품단독bd573a4는 draw2행만 교체했다. 현재 문자열 폭을 실제 font10에서
구해 최소48px를 유지하며 중앙 정렬한다. 새 source admission·화면·normal은 작성 중이며
아직436 PASS/GO는 발급하지 않았다. 434 정적 보충 독립 보고는
`.git/full-game-localization/order434-review/static-l1.json`
SHA2cb813065660187f829925393f2a43ab8b6cb55026422fd1a2248ebbb4d3013c다.

## 범위·소유

- root: `scenes/HoldemClub.gd::_draw_bet_stack`의 마지막 draw2행만 바꾼다.
  같은 font10·색·y24·금액으로 `maxf(48.0, 실제 문자열 폭)`을 구하고 폭의 절반만큼
  왼쪽에서 중앙 정렬한다. 두 행을 두 행으로 교체해 기존 `_tr` 호출 행도 보존한다.
  formatter·게임/칩/덱/AI/베팅/정산/AP·저장은 불변이다.
- claude_handoff_review: `tools/holdem_money_history.py` EOF 새 canvas 전이 증명과
  새 `tools/holdem_canvas_width_check.py`만 소유한다. 기존434 본문·상수·pin 불변.
  두 실제 전이의12객체·직접부모·단독경로·단계 사이 바이트/조상·전체2행 역상과
  현재 raw/HEAD를 확인한다. 새 CANVAS 상수를 쓰며 기존 의미를 재바인딩하지 않는다.
- root: `tools/ui_translation_append.py` EOF matcher만 추가한다. 기존15조합과
  실제434 중간 조합·새436 현재 조합의17개만 허용한다. 새/중간 Holdem과 옛
  Main/Scalp/Aruba의 가상 조합은 거부한다. 기존 current_proof/append 본문 불변.
- receipt_tests392: `tools/audit_scope.json`의 명시 차선과 새 private436 화면 helper.
  root가 private436 normal과 모든 실제 검사를 실행한다. independent392는 비저자
  원문·원본 화면/입력·증명·결과 최종 검수를 맡는다.
- 기록: CLAUDE, 큐/L3, active/archive434·436, WORK_LOG, 생성STATUS, agent 보고/판정.
  pipeline·JA audit·사전·번역 수용원장·과거 증거·공개 데모·인간 원장·player34 불변.

## 검수·재사용 경계

- 434 source28aeb902/tree f0983fa의 runtime first 파싱실패119파일, r1 실제161파일과
  REWORK 판정을 그대로 보존한다. r1의 aggregate screens2는 실제PNG10 중 KO 검증분이다.
  434 static14검증+조회1 PASS/776.762초·focused49는 정적 L1만이며 UI GO가 아니다.
- 새 focused는 두 전이/whole inverse/변이 거부, 실제 collector 호출·Entry ID·retained JA
  불변,17개 실제manifest와 가상 조합 거부를 확인한다. 과거 focused는 다시 실행하지 않는다.
- proven pre-autoload 격리 진입으로 KO/EN/JA/CN/TW SETUP·첫 PREFLOP10PNG,
  실제 첫손5·synthetic130raw/65tap을 다시 관측한다. 준비 seed434/5M/100k·27경계값과
  monetary Label/Button70개·canvas10개·지역 glyph/font/폭/높이/겹침을 검수한다.
  canvas는 실제 draw 발생+소스 결속 font 측정이며 raster 호출 가로채기 주장이 아니다.
  실제 픽셀을 별도로 읽고 접미사 전체가 보이는지 판정한다.
- 상태·입력·PNG·비canvas 조건도 독립 확인한 뒤 최종 strict PASS를 판정한다.
  알려진 잘림을 예외 허용하거나 font축소/금액축약으로 넘기지 않는다. table confirm/
  cancel/Leave·정산/AP소비0, typed GameState/Holdem/flash/Main·Meta·Tutorial·Hints/
  논리BGM 복원과 실제player34 보존. 오디오 playhead·물리패드·자연진입 관측은 아니다.
- 새 clean 후보에서 fresh receipt/fullbody·JA/ZH/EN·새focused·context/queue/diff/등록
  총10검증+명시 차선 조회1을 실행한다. exact draw2행과 검증 지원코드만 달라진 것을
  확인하고434의 storygraph/Chapter1/Chapter5/Year5 원본을 참조한다. 이4개는436에서
  NOT_RUN이며 새 PASS로 부르지 않는다. 전체감사/240주/성능A·B도 실행하지 않는다.
- 런타임과 새 source admission이 통과하고 비저자 판정을 얻은 뒤에만434의 잘림
  REWORK를 새 후보에서 해소한다. 옛434 후보 REWORK는 영구 보존한다.

## 일회성·다음

- 삭제하면 정확한 단위 접미사가 다시 잘린다. 새 선택·경제 수치·시스템은 추가하지 않는다.
  선언과 검사 재사용은 이 수리 한정이며 새 상시 규범0이다.
- 다음435는 기존 계획의 신규22키/중문44값이다. 아직 작성·수용0이며 별도 선언한다.
- 준비 두 화면/금액/1280×800만 관측한다. 모든 거액/후속 street·승패·정산·자연진입,
  native_reader/human_playtest/physical_controller_feel은 미관찰이다. 공개GO1·인간OPEN45,
  본편/새package HOLD·외부 출시 권한 경계를 보존한다.

## 최종 범위한정 판정 — 2026-10-04

- 새 source `538e1318eb9dcf92cc46699a04a26c5375639892`, tree `9fe2a7567b711fa6617890a7d7d84d76b87c8dd5`에서 독립 GO. 옛434 source28aeb902의 REWORK는 그대로다.
- actual 5언어10PNG·130raw/65synthetic taps·첫손5·정산0, 61.175초 PASS. 70개 금액 노드와10개 canvas의 값·서체·폭·중앙 정렬을 확인하고 typed/player34를 보존했다.
- fresh10검증+조회1 PASS/359.373초, focused45case/12.185초. Chapter1/storygraph/Chapter5/Year5는434 원본 재사용이며436에서 NOT_RUN이다.
- runtime SHA `56346938769f81a910584f3abcf92e1155cb9e9661eefa13781d992b310d8bf9`; normal SHA `5116f33788ab482f2e45757266322ef68c0862f4438a3f279fafdb505122dc09`.
- tracked3046/prior3099/current4/runtime164/player34 전후 불변. accepted41612/b207·JA3044/CN/TW1711 및 공개GO1·인간OPEN45 보존.
- [독립 보고](../agent_reviews/ORDER-436.json). 기존434 보고 경로/SHA를 보존하기 위해 후속 보고만 별도 파일로 추가했다.
- 규범 검토: 이 수리·검수 절차는 일회성, 새 상시 규범0. 10px 가독성·비금액 영어 잔여·후속라운드/정산·자연진입/원어민/인간/물리패드 미관측, 본편/새package HOLD.
