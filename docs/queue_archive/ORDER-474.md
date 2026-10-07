# ORDER-474 — 첫5천만원 축하의 지출·거처 사실

#### [x] ORDER-474 [위임 수리] 실제1만5천원 선택과 현재 거처 — 2026-10-07

착수 — 선언 커밋·push 뒤 아래 정확 소유만 구현한다. 기존157 잔여 기록
FULL_GAME_LOCALIZATION.md:156–159와 현재 원문/소비자의 확인 결함이다.
473의 완료 범위를 늘리거나 화면 대기149/457/302·157의 원래 소유에 넣지 않는다.

## 실측 두 독립 단위와 깊이3문

- 지우면: 실제 money−15000 선택을5천원 지출이라고 설명하고, 비고시원 거주자도
  사별판 결과에서 고시원 계단에 앉는다. 결과문과 실제 choice/current_housing이 충돌한다.
- 24주 뒤: mental+12·money−15000·arc_first_real_win_seen 및 선택/후속/소비자는
  그대로다. 새 상태·회수·금액·승리 조건을 만들지 않고 이미 낸 비용의 설명만 맞춘다.
- 경쟁: 혼자 축하/아버지에게 전화(사별판은 연결되지 않는 번호)/다음 목표의
  기존 선택·대가·아버지 생사를 보존한다. 수리를 위해 선택이나 음식을 늘리지 않는다.

모집단은 두 root의 choices[0].result_text만×5언어=10잎이다. 확인된 작은 사실
수리를15개로 부풀리지 않는다(WORK_UNIT의 배치 크기는 첫 실행 추정).

## 정확 변경

1. arc_first_real_win/choices[0].result_text의 기존 아이스크림5천원을 실제
   선택 효과1만5천원에 맞춘다. 다른 문장·효과·금액은 보존한다.
2. arc_first_real_win_father_passed의 같은 금액과 `고시원 계단`을 수리한다.
   이미 생존판이 쓰는 `집으로 돌아와`와 양립하는 결과로만 정렬한다.

토큰·문단·문장 순서·KO/EN 시제·다른 결과/본문/배경·일반/사별 라우팅은 불변이다.
MainGame.gd:7688–7693의 t≥15/순자산≥5천만/미독해·생사 분기는 수정하지 않는다.
공개 M01~M06 14root/100잎에 두 root가 없다(story_demo_localization_audit.py:33–48).
legacy V2의 arc_midgame 소유는 arc_father_quiet_call이며 그 raw도 보존한다.
기존 frozen 공개 PCK·인간 GO 및 M01~M06 원문을 새로 만들거나 갱신하지 않는다.

## 파일 소유

- root KO/EN: content/events/arc_midgame.json,
  content/events_en/arc_midgame.json의 위2잎씩만.
- 직접KO 목표어 저자 order469_review: content/events_ja/arc_midgame.json,
  content/events_zh-CN/arc_midgame.json, content/events_zh-TW/arc_midgame.json의
  위2잎씩만. 영어 중역·간체→번체 자동변환 금지.
- root 공식수용: content/meta/full_game_localization.json. exact2×3의
  export/check/import --replace-existing, 최초수용0/기존 원장 prefix·키 보존.
- root inventory: content/meta/release_content_inventory.json,
  docs/CONTENT_RATING_INVENTORY.md의 실제 변한 현재 지문만 owner 생성과 함께.
  먼저 실측하며 변하지 않은 지문·공개 계약·분모·분류는 변경0.
- order469_history: tools/order470_source_compat.py,
  tools/order470_source_compat_self_test.py, tools/pr31_intake_history.py,
  tools/pr31_intake_history_self_test.py의 실제 source5/receipt1/
  필요할 때만 metadata2를 정확 successor로 추가한다. 옛470–473 끝점은 불변이고
  과거 산문을 실제 runtime payload로 반환하지 않는다. root만 QA/엔진/커밋한다.
- root 표적검사: 새 tools/first_win_fact_audit.py(--self-test),
  tools/FirstWinFactCheck.gd, tools/FirstWinFactCheck.tscn,
  tools/audit_scope.json의 등록·전용 fast lane.
- 비저자 order469_main: docs/agent_reviews/ORDER-474.json만 작성한다.
  원문/목표어10잎·실제로그·전이·L2 전수검수, 독립 GO/HOLD/REWORK.
- root 운영: CLAUDE.md 현재, docs/CODEX_QUEUE.md,
  docs/CODEX_QUEUE_L3_PENDING.md 순번만, 이 사양/queue_archive/ORDER-474.md,
  docs/WORK_LOG.md, 생성 docs/STATUS.md, docs/agent_review_decisions.json.

arc_events5·endings5·project.godot·GameState/Main/EndingSystem·사용자 저장·seed·
과거 human/agent 보고·판정·public manifest는 만지지 않는다.

## 최소 증거와 마감

1. exact10 밖 raw/JSON 구조·효과·플래그·토큰·LF/문단 불변,5언어 전수 의미 대조.
2. 공식6교정/최초0과 실제 source census·이전 원장 prefix·typed Git 전이를 결속한다.
3. 새 fixture는 proven fresh UUID pre-autoload에서 실제 GameState.apply_choice/
   MainGame._next_arc_id를 읽는다. 생사×고시원/비고시원, t/금액 경계, 실제
   money−15000/mental+12/seen 영수증과 재호출 차단을 준비 상태로 확인한다.
   source/runtime/사용자 보호와 외부 Godot 실행파일 SHA 전후·exit·정확marker·
   stdout/Godot오류를 모두 기록한다.
4. 변경된 잎·생산자/독자·공식 수용·이력 반례 및 en_coverage·english_hangul·
   narrative_continuity·scene_audio_contract·speech_register·release_inventory·
   demo 계약에 필요한 표적 검사만 선택한다. JA/zh는 실제 공식 leaf 검증을 한다.
   변경 없는 UI 대형 검사/240주/전체 감사/옛 화면을 이유 없이 반복하지 않는다.
   이전 검사 재사용은 그 검사의 실제 입력 동일성/비적용 경계를 따로 남긴다.
5. 새 실패0·L2 각 칸·비저자 한정 판정 전에 완료하지 않는다. 실제 창·자연 플레이·
   인간·원어민·물리패드·본편 출시 HOLD는 준비/자동 검증으로 대신하지 않는다.

규범 승격: 새 규범0. 기존 WORK_UNIT/I18N/SCENE_TIER 정본을 적용하며 이번
exact두 결과·분리 전이·최소 검사 순서는 일회성이다.


## 2026-10-07 마감 — 첫 수익 결과의 비용·거처 사실 한정 GO

- candidate `e0d53cced72aaa1da30d397caafdf599bf15152a` / tree `6984da0570ed568838daabf188c1a1f4fd8c1faa`.
  비저자 전수10잎·실제 로그·전이 검수 [ORDER-474 보고](../agent_reviews/ORDER-474.json),
  SHA `8093f0da51d37f4dea9d6fe4cbe649e5c303bd944abe633e8ad04640270dc0c0`. 실제 화면·자연 플레이·원어민·인간·물리패드·본편 출시 GO가 아니다.
- source5 `1dbdf12ffa09b7143af43a006828af5d78e52619`→KOrepair1 `efacadafb59bb80c8fce10cb9d5937509ce22b1f`의 선택0 결과만5언어10잎:
  음식값5천원→실제1만5천원, 사별판 고시원 계단→기존 생존판과 같은 귀가.
  다른raw·토큰·LF4/문단3·효과·플래그·배경·선택·라우팅 변경0.
- 공식2×3 교정/최초0, 기존264배치 raw prefix·41848키 불변/현재267.
  receipt1 `bae21b2f297d4eb8f285448a23b5c391370782e4` / direct parent
  `037a858c4e70d7fa37d2950f22296b1669446308`는 실제 공식 export 후보에 결속한다.
  actual main9(export/check/import×3) exit0/stderr0, 459.284228초;
  result SHA `02aa5fa636ac6357e77f5583d51bc98962b385ff79f50ff875d7fa45f05e9bba`.
  실제collect1 뒤 같은 invocation 전체입력·함수 identity·census 가드9회;
  원본 check/import를 대체하거나 이전 invocation 판정을 재사용하지 않았다.
- official1은 실제ja export0/check1, steps2/9·receipt0·보호true의 FAIL이다.
  336.079557917초/result SHA `f0ebd3482a07f1033bc60b37a9d5d6cc39700f1938ee4c91eccd8a73d7e957e5`를 보존한다.
  기존 파서가 `1만5천원짜리`를5천원으로 읽었고 동일KO2잎을 `15,000원짜리`로
  명확히 했다. 원실패/initial source 핀을 보존하며 검사기를 완화하거나 금액을 바꾸지 않았다.
- release_content_inventory 원본 검사 exit0와 생성 보고 동일성으로 지문 변경0을 확인했다.
  metadata2 전이를 만들지 않았고 기존473 ending지문·public 계약·축9·분모를 보존했다.

### L2 — 두 root × 같은5언어, 전 칸

| 단위 | 도달 경로 | 생산자 ↔ 독자 | 바꾸는 상태 | 포기 시 잃는 것 | 서사 위치 | 장면 계층 | 닫는 것 |
|---|---|---|---|---|---|---|---|
| arc_first_real_win/choices/0/result_text | FIRST_WIN_FACT_CHECK_OK 150; route100/choice20/reentry20 prepared | arc_midgame.json:345↔MainGame.gd:7688–7693; GameState.gd:1950/2006 | 준비현금50000000→49985000; mental50→62; seen false→true; housing불변 | 기존choices1/2 경쟁; W15 prepared choice0만 실행; 새 회수0 | 1.milestone; dispatch W≥15/M≥04; 자연 도달시각 미관찰 | T3(미선언 기본); SCENE_TIER.md:56 | seen=true→first-win 양root 재진입0; 새 경로폐쇄0 |
| arc_first_real_win_father_passed/choices/0/result_text | FIRST_WIN_FACT_CHECK_OK 150; route100/choice20/reentry20 prepared | arc_midgame.json:4291↔MainGame.gd:7688–7693; GameState.gd:1950/2006 | 준비현금50000000→49985000; mental50→62; seen false→true; housing불변 | 기존choices1/2 경쟁; W15 prepared choice0만 실행; 새 회수0 | 1.milestone; dispatch W≥15/M≥04; 자연 도달시각 미관찰 | T3(미선언 기본); SCENE_TIER.md:56 | seen=true→first-win 양root 재진입0; 새 경로폐쇄0 |

### 실제 표적 검증과 실패 보존

- runtime1은 actual engine/wrapper exit1, cases150 중 choice20만FAIL/복원true/보호true.
  JSON effect float와 fixture expected int의 타입 오탐이다. result SHA
  `55a0cc851f17a27e5f5914ec2042f7ab0421e23a9ad59cdd555a4f7098b9226c`를 그대로 보존한다.
  fixture expected만12.0/−15000.0으로 고친 `1bf0585`에서 fresh runtime2를 실행했다.
- runtime2는 표기수리 전 actual150 PASS의 역사 증거로 보존한다. KO표기가 바뀐 뒤
  (runtime2 result SHA `5c4c188f4de14cbb8512774879cd121285b99ea9b2c31cf30115b43963dac37b`.)
  fresh runtime3 actual engine/wrapper exit0; pre-autoload 경로 같음/정확marker1,
  loaded10/route100/choice20/reentry20=150 전수PASS, stdout=Godot cases·stderr0/engine오류0/복원true.
  choice20 실제 cash50000000→49985000/mental50→62/receiptindex0;
  reentry는 돈을threshold에 **준비 복원**한 뒤 seen 차단을 확인하며 제품 환급이 아니다.
  result SHA `999dfaaf9406c416d41ebf0bee982ccd7cfe0a8dfc77dd79097a9982c2e32b77`. 엔진 SHA
  `e6b5cfdc226ffb7ec4f4950b0b12ddba4f040624724cff1acce9ae1241cf0034` 전후 동일, 전체tracked 입력·보호11그룹·로그 불변.
  뒤 원장/지원핀/현재문서만 바뀐 입력 동등성은 비저자가 직접 읽었다.
  현재최종후보에서의 추가 엔진 실행·자연경로·혼합자산·모든생사레거시조합·렌더 claim은0이다.
- final focused source/proof `[101, 58]` actual0,
  141.985625초/result SHA `5617ea21c4d16f583077e6d33293ba8c17f6c82c16a80f10730f1cdd29bc66c2`.
  변경raw·source5/receipt1·현 원문과 역사 비교 전용투영·독립재hash 반례를 읽고
  옛470–473끝점과264prefix를 보존했다.
- final quick11 original CLI 실제exit0/stderr0, 131.616046초;
  result SHA `71b098eb2823329ba10c1bdc22b6bac87bacadb3ed5d34867b85df7c90b31bcf`. 한 fresh proof invocation 안에서
  원본 CLI를 각각 실행하고 전후전체입력·runner·로그 동일성을 확인했다.
  변경 없는 UI대형/240주/전체감사/옛 화면 반복0. 최종 미해결 신규 실패0;
  원runtime1 실패는 PASS로 재분류하지 않는다.

| 검사 | 실제 exit | stdout SHA256 | stderr SHA256 |
|---|---:|---|---|
| first_win_facts | 0 | `01b5e1fb51275ef8b733e8f21a5da420fd54765e7418de82fa1f6b091a6fa24b` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| en_coverage | 0 | `3c8fb0fe51e73967455b28149d28977ee7a44a9ff3891baae9a938f89d81451b` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| english_hangul | 0 | `15ad7fcf86b374cacd08c98110654b04febf4b65210231e6a7b7fb237abe6c44` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| narrative_continuity | 0 | `50fb37b91b7b1ad1fb7d25f2c7d2fffe1921a944de98518c20333b01d3949f26` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| scene_audio_contract | 0 | `b629eaab373ccfbd504686997f7cb04b8ebdc484fe4328ec4a6e67432d6b9132` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| speech_register | 0 | `43952f3918dd5c4d1a8b1002dcec7dad706502315a57d115d67195724324dc11` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| release_inventory | 0 | `9bca145d3db7bb10745ec0c7deaa709ced89d47c09dbb8de9021c097de5ac516` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| demo_i18n | 0 | `a99e3d2981750a415a713bf9292c56abe2c65a0eab43dbe25b03c119c0c0dce8` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| context_manifest | 0 | `28811d57a789cfeb19ffad330d2c4f5849a073d57fc315151593454a3680ba3e` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| queue_consistency | 0 | `591b8736de73337ab8bda79d4bb66a995e451ffc6b5eaf1382e5a91625bb9d23` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| audit_scope_verify | 0 | `24e4e09d3a6a55420986928a304b021664f52dc24cec1e614c6bb6dd65a922a9` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |

### 보존·판정 경계

- project·GameState/Main/EndingSystem·arc_events/endings·사용자 저장/seed·공개 데모 변경0;
  human_gates SHA `6ab5c927c9f327aa2892c231d49fe144c1c154cb6069fc539f4f3f8e9c30c9f6`.
  공개GO1·인간OPEN45·역사REJECT/HOLD·149 captureFAIL/연속창HOLD·472/473 한정GO 보존.
- gangnamdream-dev의 exact소유·전이분리·표적검수·pre-autoload·증거분리를 적용했다.
  새규범0, 기존 WORK_UNIT/I18N/SCENE_TIER 정본 적용이며 이 exact배치 결속은 일회성이다.
- 자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.
- 후속 확인 결함은 별도큐 선언 뒤 다룬다. 화면149/457/302와 전체판/출시는 HOLD이며
  잠금 반복확인이나 사용자 재서명을 요구하지 않고 안전한 원문/소비자 수리를 계속한다.
