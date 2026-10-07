# ORDER-477 — 기다리기 선택의 회복을 확정하지 않는다

#### [~] ORDER-477 [위임 수리] 첫 손실 기다리기 결과5잎의 사실 정합 — 2026-10-07

착수 — 선언 커밋·push 뒤 아래 소유만 구현한다. 476의 보유 손실 전제를
반복하지 않고 그 완료사양에 남긴 choice1의 사흘·절반 회복 단정만 수리한다.
STORY_CONSISTENCY_SYSTEM의 실행 사실 정합과 I18N_INFRASTRUCTURE의 기존
수용 교정 절차를 적용한다. 새 거래나 반쪽 매매의 완성/제거가 아니다.

## 한 판정 단위 / 깊이3문

- 지우면: 선택1은 skill+3/mental−3/seen·held_through_loss만 생산하는데,
  결과가 사흘 경과·가격 회복·그 회복의 안도감을 보장한다. 실제 결과와 다르다.
- 뒤의 독자: StoryMode 결과와 같은 선택의 기록은 정확한 현재 원문을 읽는다.
  W36+ held 기억 회수는 가격이 절반 회복됐음을 요구하지 않는다. 기존 flag를 보존한다.
- 경쟁: 팔지 않기로 한 기억·앱 닫기·불안·판단 유보는 남기되 수익·기간·다른
  선택의 도덕적 우열을 새로 발명하지 않는다. 선택0/2의 실제 거래 불일치는 별도다.

대상은 arc_invest_first_loss /choices/1/result_text × ko/en/ja/zh-CN/zh-TW,
정확5잎이다. 세 문단·{name}·비소유 raw·게임플레이·조건·순서·라우팅은 보존한다.
기다림의 불편함을 지우거나 새 가격/수익/경과시간으로 교체하지 않는다.

## 정확 파일 소유 / 분리 전이

- root 제품: content/events/arc_midgame.json 및 content/events_en/arc_midgame.json,
  지정1잎씩만. Main/StoryMode/GameState/InvestmentSystem/콜백 변경0.
- order469_review 저작: content/events_ja/arc_midgame.json,
  content/events_zh-CN/arc_midgame.json, content/events_zh-TW/arc_midgame.json의
  지정1잎씩. 모두 KO 직접 저작이며 CN↔TW 자동변환/EN 중역0.
  tools/night_routine_time_audit.py, tools/investment_loss_gate_audit.py/
  investment_loss_gate_self_test.py는 새5잎의 정확 역사 비교 역상만 연결한다.
- order469_history 지원: tools/order470_source_compat.py/_self_test.py,
  tools/order469_source_compat.py/_self_test.py, tools/pr31_intake_history.py/
  _self_test.py. source5/공식receipt1/필요metadata2의 실제 typed Git 단계와
  현재 디스크/census를 먼저 증명한다. 새KO만 정확 역상한 뒤 기존476 Main 역상을
  적용하며 옛90d88 고정점·476핀·14/13·470~475 끝점/봉인은 덮지 않는다.
  actual runtime/collector payload에는 역사 문장을 반환하지 않는다.
- root 공식 수용: content/meta/full_game_localization.json. export 전 원본·이전
  대상 지문을 보존하고, 변경KO/현재target에 새 export/check/import --accept와
  --replace-existing을 적용한다. 기대 기존3교정/최초0, 270배치 prefix·41848키
  보존. private source/response/receipt와 portable batch를 함께 결속한다.
- root QA: tools/InvestmentLossHoldResultCheck.gd/.tscn,
  tools/investment_loss_hold_result_audit.py, tools/audit_scope.json의 전용 차선.
  기존 pre-autoload bootstrap/ProseRecallCheck를 재사용한다. predicate stub·실제
  사용자 저장/가격/시간 조작0. source5만 먼저 커밋하고 ledger1을 별도 커밋한다.
- root 조건부 지문: content/meta/release_content_inventory.json 및 생성
  docs/CONTENT_RATING_INVENTORY.md의 owner가 확인한 fear 본문지문만.
  후보/ID/강도/분류/공개 분모 불변, source/receipt와 metadata 전이 분리.
- 비저자 order469_main: docs/agent_reviews/ORDER-477.json만 최종후보·실제 증거
  전수검수 뒤 작성. 저작/프로젝트QA/엔진/공식 import/커밋0.
- root 운영: CLAUDE.md 현재, docs/CODEX_QUEUE.md,
  docs/CODEX_QUEUE_L3_PENDING.md 순번, 이 사양/queue_archive/ORDER-477.md,
  docs/WORK_LOG.md, 생성 docs/STATUS.md, docs/agent_review_decisions.json.

project.godot·사용자 저장/seed·공개manifest·과거 human/agent 판정 변경0.
JA pipeline/Main locale history/arc_flow/ScreenshotQA/기존476 fixture는 변경0.
다른 필요 범위가 발견되면 구현 전에 별도 선언하며 이미 완료한 검사를 반복하지 않는다.

## 표적 검증 / 마감

1. source5 전체 직접 독해·정확 literal 역상·비소유 raw/gameplay/토큰/문단 보존.
   기존3교정과 이전 수용/원장 prefix·새 typed 단계·현재 census 및 주변 변조 반례.
2. fresh UUID pre-autoload에서5언어 DataRegistry 로딩·실제 결과 formatter·선택
   적용/기록 소비를 작은 고정 모집단으로 검사한다. 실제 효과/flag와 보유·가격·시간
   불변, 복원·보호source/외부engine SHA·로그/exit/marker를 결속한다.
   기존 held callback 조건은 flag/min_turn 계약만 표적 확인한다. 실제 입력·자연
   발화·render·native/human/pad 증거로 바꾸지 않는다.
3. 한 실제 collect와 동일 호출의 검증된 입력 재사용으로 공식3교정을 수용한다.
   필요한 full-body 현재 수용·EN/한글/서사/오디오/말투·inventory/공개demo·큐/정본
   계약을 표적으로 고른다. 영향 없는476의430·240주·대형UI/옛전체selftest는 반복0.
   바뀐 지원 모듈의 실제 원본 진입·현재 수용은 생략하지 않으며 새 미해결 실패0.
4. L2 경로/생산자↔독자/상태/포기비용/위치/계층/닫힘 전 칸과 비저자 한정 판정
   뒤 main 마감. 전체 투자 장면·149/457/302 실제 관찰·원어민·패드·출시 HOLD 보존.

규범 승격: 새규범0. 기존 사실·공식교정·증거분리 정본 적용, exact5잎/역상/검수
모집단·입력 재사용은 이번 오더 일회성이다. 자동 통과는 재미·깊이·문체 판정이 아니다.
