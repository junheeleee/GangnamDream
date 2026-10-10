# ORDER-545 — 무거래 본편에 투자 회상이 열리지 않게 한다

#### [x] ORDER-545 [P1·확인 인과 수리] 실제 매수 사실 생산자·본편 지연 독자 — source 한정 GO

**착수 — 2026-10-11.** 544의 실제 W31 무거래 관측과 WORK_UNIT 위임에 따른
별도 구현이다. 월별 관측 오더와 섞지 않고 선언 커밋 뒤 구현한다.

## 깊이 3문

1. 조언 선택의 예약만으로 실제 투자·손절·추가 매수 회상이 열리는 확인 결함을 막는다.
2. 실제 매수 성공 사실은 전량 매도·로그 절단·저장 왕복 후에도 남고 무거래와 구분된다.
3. 자격 없는 예약은 소비/삭제하지 않는다. 다른 적격 장면 또는 기존 quiet 루틴이
   주차를 소유한다. 새 행동판·대체 카드·본편 투자 실행 기능을 만들지 않는다.

## 범위·소유

- root: systems/InvestmentSystem.gd, scenes/MainGame.gd.
  이 사양/마감 archive, 큐/L3 순번, WORK_LOG, CLAUDE 현재행, agent 원장.
- phone_cn_author: 생산자/독자/기존 정상 full 진입 읽기 검토와
  tools/ManualSaveCheck.gd의 표적 fixture만 작성한다. 엔진 실행0.
- phone_independent_review: 비저자 전수 source·표적 raw·보존 검토와
  docs/agent_reviews/ORDER-545.json 및 private before/final 보호 snapshot만 작성한다.
  저자 코드 수정0.
- content/원문/번역·효과/수치·조건 JSON·project.godot·공개 패키지·사용자 저장·
  인간 원장·이전 보고/raw·영구 검수 도구·audit 등록은 비소유다.

## 수리 계약 — 한정 버그, 새 경제 시스템 아님

- 기존 성공 현물/레버리지 매수에서만, 유효한 PROFILE_FULL 세션에 locale-neutral
  bool `full_story_market_purchase_completed=true`를 기존 flags에 쓴다.
  실패 매수/조회/조언/공부/시작 배경/매도는 생산자가 아니다.
- Main의 deferred reader는 이 callback과 full profile에만 exact bool true를 요구한다.
  사실 없는 예약은 preview/실제 resolve 모두 무변경 보류한다. 다른 예약은 막지 않는다.
- 과거 `had_first_investment`, 보유량, 잘리는 action_log나 번역문에서 역산하지 않는다.
  사실 없는 구저장은 불확실한 회상을 보류하고 원래 저장은 수정하지 않는다.
- public/demo·legacy/V2·8/12 preview의 기존 reader/매수 결과는 유지한다.
  기존 v4 flags 왕복을 쓰며 save schema/버전·SaveManager는 바꾸지 않는다.
- 실제 매수는 회상 속 하락·3일 뒤 본전까지 증명하지 않는다. 그 산문 및 정상 full의
  투자 실행 입구 미완성은 별도 REWORK로 남긴다. 544/M08·게임 전체 GO 아님.

## 표적 검증·완료

- 기존 ManualSaveCheck에 작은 focus 차선만 추가한다. 무거래/옛 배경 flag/손상 타입,
  다른 적격 예약 통과·순서/보류 유지, 성공 현물/레버리지와 실패, 전량매도·로그 절단·
  v4 disk/new-main 왕복, 관찰 무변경·한 번 청구, public/legacy/preview 제외를 확인한다.
- 기존 pre-autoload bootstrap·fresh HOME/XDG/namespace와 build safety runner를
  재사용한다. raw stdout/stderr/Godot·actual exit·정확 marker·오류 스캔을 보존한다.
  대상 compiler·기존 현금 보존 계약/EN 한글·영어coverage·서사·음악·원장·
  큐/context/agent metadata와 diff만 실행한다.
  전체감사·8/12/240주 반복·새 최적화/도구·STATUS-only·ObjectDB 탐침0이다.
- source 후보를 먼저 커밋하고 비저자가 그 exact commit/tree를 읽어 독립 판정한다.
  실제 수정/표적 검증·보존이 통과한 범위만 source GO로 기록한다.
  자동 계약은 재미·깊이·문체·실제 앱 화면·인간/원어민/패드/출시의 증거가 아니다.
- 새 정본 규범0. 이 사양 실행 지시는 일회성이고, 기존 사실 없는 회상 금지 규칙의
  구현이다. 월별 실제 재관측은 후속 월 오더의 한 커밋에서 한다.

## 2026-10-11 결과 — 무거래 ingress 수리만 완료

- 선언055a819 뒤 source08e3ac1e95b3fcb7b2c128d47dc01d93ea5a2382 /
  tree aa621f148ad6d34bdafa0f45dbc35049ba14b3b2를 커밋·표적 검증 후 main에 push했다.
  실제 성공 현물/레버리지 매수만 유효 full fact를 cash observer 전에 쓴다.
  무거래·옛 배경/보유/log·손상 타입은 증거가 아니다. reader는 eligibility/claim 전에
  보류하므로 예약을 삭제하거나 다른 적격 장면을 굶기지 않는다.
- compile69·집중 Manual normal/demo/V2·기존 MoneyIntegrity 5실행은 모두 actual0,
  exact marker1·원 stdout/stderr/Godot 오류/경고/누수0이다. 거래/전량매도/log cap/
  v4 disk·같은 프로세스 새 Main의 사실 보존, 관찰 무변경/RNG·한 번 claim을 확인했다.
  W1 actual fresh owner와 별도 prepared W31/read/routine 표본이다. 자연 M08,
  실제 투자 UI·다른 OS cold·하락/3일 수익 증거로 바꾸지 않는다.
- 정적14 actual0은 두 제품 source의 검사다. Manual 작성 완료 전 실행이므로
  최종 fixture 검증으로 소급하지 않는다. 최종 fixture는 위 실제 focus 실행에 결속한다.
  전체감사/8·12·240주 반복·새 영구 도구/audit 등록·ObjectDB 탐침/STATUS-only0이다.
- 비저자 fresh74그룹/1317파일·비소유 tracked3296, 공개/player33·seed2/W238·
  helper5·옛284판정/Human·544 raw/보고/package/namespace exact다.
  private .git/order545-qa-20261011/에 원15stream·정적28stream과 독립 final46679B/
  SHA0245e94e0c0a8715e5c418327dba41cd95574c1af62fc1d8c5e9e983e2e63087을 보존했다.
- [독립 보고](../agent_reviews/ORDER-545.json)는 위 source만 GO다. 544의 과거
  REWORK/W33 화면 HOLD는 덮지 않는다. 정상 full 투자 실행 입구·산문3일본전,
  변경 후 native 화면·원어민/인간/물리패드·전체 본편/외부 출시는 여전히 HOLD다.
  새 정본 규칙0/실행 지시 일회성. 허용 metadata 마감은 제품 source GO의 확대가 아니다.
