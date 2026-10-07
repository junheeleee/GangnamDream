# ORDER-477 — 기다리기 선택의 회복을 확정하지 않는다

#### [x] ORDER-477 [위임 수리] 첫 손실 기다리기 결과5잎의 사실 정합 — 2026-10-07

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


## 2026-10-07 마감 — 기다리기 결과5잎 사실 한정 GO

- 최종 source candidate `0ec43c3efb255f4dd5f127377cf7523898fa913c` / tree `ded9cee5668f86d70d0a8464a86381d4851870ae`.
  비저자 [ORDER-477 전수보고](../agent_reviews/ORDER-477.json) SHA `342900d5c42cb936a284e12ddc791d7fcfcccc2c49d4d03cac7408f7f69ef6d1`.
  기다리기 결과의 사흘·손실 절반 회복·회복 안도감 확정만 제거했다. 앱 닫기·불안·
  판단 유보·팔지 않기로 한 기억과 기존 세 문단/{name}/마지막 문단·비소유 raw·게임플레이는 보존한다.
- source5 `04ed119c6f0e31306ed89d62f2951ef6cc5490e5` / directparent `70ceeebdb67c4e3ab66dc2bd08cb21cf2598a343`,
  support13 `fb9952cd1c5fbd8d128d487d20902ca10429a42d`, 공식 receipt1
  `fb766fd7fc17a574bc00ffcbcd278fb03b797cee`, owner fear metadata2
  `d1ef3d225b2364f90163cb7bb734ea03655ae45c`를 실제 Git 단계로 분리했다.
  이후 지원핀과 CLAUDE 현재행을 결속하며 과거469~476 seal/끝점·Main14/13·90d88을 덮지 않았다.
  실제 payload는 현재 원문이며 역사5잎은 비교에서만 역상한다.
- official accept1: 실제 main9/exit0/stderr0·676.305925초, 원본 collect1
  528.600107초 뒤 같은 호출의 immutable inventory·함수 identity·전체 source/census 가드9.
  기존3교정/최초0, 이전270 raw배치·41848키 보존→273. source census
  `cd3a8af9a4f972f4fea87ea1630b6d31013418d35e0b4b29f01c0a7cc67a314b`. private source/response/receipt는 원보고의 실제 경로·SHA로 결속한다.
  fear는 event145/file51/IDs·분류·강도·공개 분모를 유지하고 본문 지문1과 생성보고 대응값만 owner로 갱신했다.

### L2 — 정확 결과1잎×5, 전 칸

| 단위 | 도달 경로 | 생산자 ↔ 독자 | 바꾸는 상태 | 포기 시 잃는 것 | 서사 위치 | 장면 계층 | 닫는 것 |
|---|---|---|---|---|---|---|---|
| 결과1잎×5언어 | INVESTMENT_LOSS_HOLD_CHECK_OK locales=5 cases=40 loaded=5 formatted=5 producer=5 record=5 callback=20 prepared_component_only=true; W15 결과/기록 소비 준비. 자연 진입·화면·입력 관찰 아님. | content/events/arc_midgame.json:2423,2428,2432 + autoloads/GameState.gd:1981–1982,2006–2009,2088 ↔ scenes/StoryMode.gd:7064(준비 실제 _fmt 호출),6400–6412(일반 결과 소비 코드 독해만) 및 GameState.gd:2093,4066. held_through_loss ↔ content/events/callback_events_45.json:271 + autoloads/EventManager.gd:976. | result1잎×5만 교정. 준비 실제 적용 skill50→53/mental50→47, arc_invest_first_loss_seen·held_through_loss 생산, event_log choice_index1/turn15/result 현재 formatter. cash·portfolio·market_prices·calendar 변경0. | held_through_loss 기억 없음 → callback_held_through_loss_echo 조건 부적격. W35/36×flag제거/유지×5의 실제 조건 검사20: 적격5/거절15. 실제 scheduler 발화 아님. | 1장 Main 직접 아크 W15~18/M04~05; story_map/spine 명시항목 없음. 기존476 진입조건 불변/반복 실행0. | T3(기존 미선언 기본); 결과 사실 교정만, 장면 승격0. 전체 투자 장면의 거래·회수 품질 판정 아님. | 기다림 결과의 사흘 경과·손실 절반 회복·회복 안도감 확정만 제거. 선택/효과/flag/라우팅/콜백 불변. 선택0/2 실제 매매 불일치와 후속 회수 서사 부채는 별도. |

### 실제 검증과 재사용

- runtime1: actual engine/wrapper0·4.407834초·fresh UUID pre-autoload,
  준비40=loaded5/formatted5/producer5/record5/callback20 전수, 복원true.
  실제 DataRegistry/StoryMode formatter/GameState.apply_choice/event_log/EventManager 조건을 읽었고
  skill50→53/mental50→47·seen/held·result 현재 원문, 가격/보유/현금/달력 불변이다.
  stdout=Godot·stderr/엔진/스크립트오류0·외부 engine SHA·전체 tracked/보호11/runner/log 보존.
  소스 반례32는 original CLI 실제 관측이되 지원 저작 중의 component-only 증거로 남긴다.
- checks1: focused `[('ORDER477_LOSS_HOLD', 75), ('ORDER477_LOSS_HOLD_SOURCE', 17), ('PR31_LOSS_HOLD', 25)]`·원본 검증15+차선목록1 실제exit0/stderr0,
  3392.302005초. 한 actual collect와 함수/immutable값/census/전체tracked 재사용 가드를
  각 집중·receipt·CLI 전후/네 fresh proof 최종 경계에서 확인했다. 네 context 정상종료·error=null·source/runner/log 보존.
  full-body 현재 수용·EN/한글/서사/오디오/말투·등급inventory/공개demo·큐/정본/등록을 직접 실행했다.
- 실제 runtime 입력은 fb9952c에 남긴다. 최종후보까지 바뀐 경로 `['CLAUDE.md', 'content/meta/full_game_localization.json', 'content/meta/release_content_inventory.json', 'docs/CONTENT_RATING_INVENTORY.md', 'tools/order470_source_compat.py']`는
  receipt/owner metadata/Python 역사핀/현재 상태뿐이며 나머지3216 tracked와 제품5·실제 소비자·
  fixture/bootstrap/Godot 입력은 동일하다. input-reuse1의 실제 전체 비교와 비저자 독해로만 재사용하며
  최종후보에서40을 재실행했다고 주장하지 않는다. 기존476430·대형UI·옛전체selftest 반복0.
  별도 arc_flow/240주 항목은 없지만 원본 narrative_continuity가 내부 arc_flow A/B1~240주 경로를 실제 실행했다.

| 실제 증거 | SHA256 |
|---|---|
| baseline1/result.json | `a84caaee30e5c57e788f35db279fdfb9297c9f40e0057f80be1a89ad77ec4eff` |
| source5-proof.json | `7987efdcdfb8bec064bb9b12df48bead3fa8a179f31bebbc84db95d5c7455526` |
| runtime1/result.json | `925d83dbb1b00e9a10305bfe1d31401d5ac5ca9b85e78dbcfc874eae7ad3ada7` |
| accept1/result.json | `479a130a653e970143db4a501d8d92edb3d4a63a69b53b8b2c47c8e1a317f0b9` |
| inventory-generation.json | `3b426a72d7c6c303249882f2d1179203164dfbe739f01706a1f8888a40038fd2` |
| checks1/result.json | `25e802282ef2ba021328a7749c04a63d0c74e4e9b5920539f8aecdfa080bcea5` |
| input-reuse1.json | `32a06b705d4bc06fddf689e8e822ca7baeb4c739b26862f489af95c8eb205941` |

위 private 원본은 `.git/order477-20261007.BVytDV/`에 보존한다. 실패 재분류0·새 미해결 실패0.
project/사용자 저장·seed/공개 GO1·인간 OPEN45·옛 human/agent 판정·149 capture FAIL은 보존한다.
준비 조건 검사는 자연 callback 발화·실제 화면/입력·원어민·사람·물리패드·본편 출시 증거가 아니다.
전체 투자 장면, 선택0/2 매매 불일치와 후속 회수 서사, 149/457/302 실제 관찰은 남는다.
gangnamdream-dev의 정확 소유·전이분리·pre-autoload 격리·표적검수·증거분리를 적용했다.
새 규범0, 이번 exact5잎/역상/검수·재사용 결속은 일회성이다.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.
