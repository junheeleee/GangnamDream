# ORDER-429 — 스캘핑 준비·거래 상태를 중국어로 읽는다

#### [x] ORDER-429 [P1·현지화] KO15키의 CN/TW30값과 실제 소비자17자리

**[x] 완료 — 2026-10-04.** (착수 선언·실패 기록은 아래 보존.) 사용자 계속 개발·검수 효율·main 커밋/푸시 위임.
한국어 원문에서 지역별로 직접 저작하고 해당 소비자만 검수한다.

## 소유·범위

- root: locale/ui_zh-TW.json 15키, 최종 양지역/수용원장 append 통합, 기록.
- claude_handoff_review: private429 CN response 초안만; locale/ui_zh-CN.json 수입은 root.
- receipt_tests392: 새 private429 격리 화면/helper·공식 교환·normal runner만.
- independent392: 비저자 전수 의미·실제10PNG/상태/입력·normal 원본 최종검수.
- 추적 제품은 locale/ui_zh-CN.json, locale/ui_zh-TW.json,
  content/meta/full_game_localization.json만. 큐·active/archive429·CLAUDE·WORK_LOG·
  생성STATUS·agent 보고/판정은 기록 범위다. 기존 helper/실패/성공 증거 비소유.
- KO/EN/JA·Scalping/Main/Tutorial/Font/게임 조건·효과·save·인간원장·public demo 변경0.
  RESULT3/정산log2/직접영문 MARKET OPEN·BUY·SELL·P&L은 미완료 범위로 남긴다.

## 증거 설계

- 공식 source-bound export/check/import 지역별15값×2batch. 원래 header/digest 보존.
  raw역상으로 기존4파일 전체를 복원하고 accepted41572/b203→41602/b205,
  CN/TW1691→1706·JA3044불변을 확인한다.
- 1280×800 지역별5상태 총10PNG: A 실제venue 메뉴, B skill15/mastery0 setup,
  C skill100/mastery0 setup, D actual_start+prepared 비보유/상승, E prepared 보유/하락.
  부모/Main의 함수 소비와 자연 story unlock을 구분한다.
- A actual 별도title15px/subtitle12px·경고13px; exact em dash 분리 유지, 부제full-fit.
  제목은 A venue/B setup/D visible header3곳. B/C description12px와 실제340px
  wrap·hint11px·timer16px·price13px·position12px를 실제 node/FontKit에 결속한다.
  E entry10px는 Label 대용 없이 실제 draw/PNG·70px 오른쪽폭·Y범위로 확인한다.
- 게임언어를 먼저 설정한 pre-autoload 격리2프로세스, 실제player34파일 불변.
  Tutorial 첫실제표시→SETUP 정상cancel; seen/포커스/문자열/폰트 결과를 주입하지 않는다.
  _start_game 직후 첫await 전에 set_process(false); 시장/보유/history 준비는 fixture로 표시.
  B/C는 mastery보정 후 skill분기, D/E는 최근최소3개와 ±0.3초과 추세를 확인한다.
- 실제 초기focus와 안전한 방향입력만 관측한다. SETUP은 활성setup 자식만,
  PLAYING은 보이는활성버튼만 허용. 초기focus누락/뒤층누출은 FAIL로 보존하며
  helper grab_focus/neighbors 주입으로 통과시키지 않는다. 합성입력은 물리pad아님.
  입력횟수는 실제 수행량을 기록하고 예정숫자를 채우려고 위험입력을 보내지 않는다.
- 거래확정/매수/매도/다음턴/시간만료0. PLAYING close는 정산이므로 teardown에 쓰지 않는다.
  prepared state와 초기화·BGM/튜토리얼·종료효과를 분리해 typed 비교/복원한다.
  자연unlock·실시간매매·정산·전체미니게임 입력GO는 이 범위 증거가 아니다.
- 공식check+표적화면 후 같은clean후보 공통 normal1회만. 기존 focused/전체/240주0.
  실패는 원본을 보존하고 원인 한정수리한다. 제품입력결함이면 별도 범위를 선언한다.

본편/새packageHOLD·B3/B4·원어민/인간/물리 미관측·공개GO1/인간OPEN45 유지.
일회성 배치 지시이며 새 상시규범0; 자동PASS는 계약증거이지 문체·재미·출시GO가 아니다.

## 원문 모집단

```text
높은 수익, 더 높은 위험. 중독에 주의하라.
  —  60초 실시간 매매
스캘핑 트레이딩
진입 %.2f
%d초
가격  %.2f
포지션: 보유중 (%s)
포지션: 없음
추세 감지: %s
상승
하락
60초 안에 저점 매수 / 고점 매도
투자감각 %d  ( %s )
노이즈 낮음 · 추세 힌트 있음
노이즈 높음
판돈 선택
```

## 구현 후보 — 2026-10-04

- KO 직접 CN15/TW15값을 별도 저작하고 비저자 의미 전수검수 후 공식 export/check/import했다.
  exact 대시·60초·줄바꿈·숫자 포맷을 보존하며 위험/중독·추세·보유 여부를 구분했다.
- accepted41572/b203→41602/b205·CN/TW1691→1706; JA3044 및 기존4파일 역상 보존.
- 다음은 clean 같은후보의 실제17소비자리/10PNG·안전입력과 공통normal이다.
  아직 새화면/입력 GO를 주장하지 않는다. 본편/새packageHOLD·원어민/인간/물리 미관측 유지.

## 실제 관측 — 수리 필요

- first/r1은 helper 이름충돌·타입추론 parse 실패였다. 원본을 보존하고 게임 성공으로
  세지 않는다. r2는 실제 10PNG를 생성했지만 준비 재개방 뒤 창 잔류와 B/C/D/E
  초기 포커스 누락을 확인했다. 집계 성공화면0은 검증실패 결과이며 파일 누락이 아니다.
- 번역30값 의미·공식교환은 통과했으나 전체 화면/입력은 REWORK다. 새430에서 제품을
  수리하고 같은 번역 소비자를 다시 검수한다. 공통 normal은 최종 successor에서1회.
- venue 부제의 요청12px는 Main 읽기 최소크기로 실제14px다. 제품폰트 변경 없이
  실제14px를 검사했다. normal helper 소유는 root로 인계했다.

## 최종 범위한정 판정 — 2026-10-04

- source927d6f52591f656eaf1f55045cc672b45b33658a / tree921356a92df99fb9a5424ad9609b5f3be315617b 독립GO.
- da1a015 실제10PNG·196raw/98taps·32.82초 PASS. 준비 B/C overlay1, 거래 D/E0,
  초기 유효 포커스와 disabled BUY→SELL 실제 이동을 확인했다. typed/player34 보존,
  매수/매도/정산0. 현재30번역값·accepted41602/b205·CN/TW1706·JA3044 불변.
- 최초normal841.526초는 focused 중복항목명 때문에 FAIL이며 원본 유지. 통과12검사+
  조회1은 그대로 보존, test 이름인수1줄만 고친 successor의 새74case/1.051초 PASS.
  제품·bridge·사전·helper·기존증거 exact불변으로 통과행/runtime을 재사용했다.
  원래 후보 실행을 새후보에서 재실행한 것으로 재명명하지 않는다.
- normal 사전 player-map SHA/object 비교실패(검사0)와 수정runner, 429 first/r1/r2 및
  옛 REWORK를 모두 보존한다. 판정·전체증거 hash는 ../agent_reviews/ORDER-429.json.
- RESULT/hover/실시간매매/자연진입·원어민/인간/물리 미관측, 본편/새packageHOLD.
  규범 검토: 이 배치의 실행·검수 절차는 일회성. 기존 WORK_UNIT의 위임/실제관측 분리와
  CONTROLLER_UX_STRATEGY 입력계약을 따르며 새 상시규범0. 자동PASS는 계약증거다.
