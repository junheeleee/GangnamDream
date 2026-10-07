# ORDER-475 — 심야 루틴의 상대적 취침 순서

#### [x] ORDER-475 [위임 수리] 새벽1시 이후 결과·생활 다리10잎 — 2026-10-07

착수 — 선언 커밋·push 뒤 아래 정확 소유만 구현한다. 474와 별도 오더다.
FULL_GAME_LOCALIZATION.md:156–159에 기록된 실제1시→12시→자정 전 모순이며
이미 닫은474 비용·거처, 다른 원문의 연차·투자손실 가드는 이번 범위가 아니다.

## 한 판정 단위와 깊이3문

- 지우면: 본문 새벽1시 뒤 결과가12시 취침, 자동 생활 다리가 자정 전 소등으로
  되돌아간다. 직접 결과와 EventManager→Main summary 두 독자 모두 모순이다.
- 24주 뒤: 기존 slept_early·arc_night_routine_seen, mental+6·현수 affinity+1은
  불변이다. W40+ callback_slept_early_echo는 무리하지 않고 일찍 쉰 기억을 읽는다.
  다른 선택처럼 더 공부하지 않고 곧 취침했다는 상대적 조기 취침은 보존한다.
- 경쟁: 새벽2시까지 공부/intelligence+2·investment_skill+1·health−2,
  맥주/mental+8·health−1과 기존 경쟁한다. 이번 수리는 선택·비용·회수를 늘리지 않는다.

한 사실/두 소비 잎×5언어=10잎이다. 첫 실행 추정15~25를 채우려 다른 사실을 넣지 않는다.

## 정확 변경·보존

arc_night_routine/choices[1]의 result_text와 bridge_summary만 바꾼다.
새벽1시 본문·새벽2시 선택0·다른 문장·호칭·문장 순서·토큰·LF/문단은 보존한다.
취침의 절대시각만 없애고 더 공부하지 않고 바로 쉼/상대적으로 공부를 일찍 마침으로
정렬한다. 새 시각·수면시간·다음날 효과·캐릭터 사실을 발명하지 않는다.
Main W12–22/고시원/현수 만남/미독해 dispatch·기존 자동 선택 우선순위,
GameState.apply_choice·EventManager 영수증/summary 및 콜백 조건은 변경0.

STORY_BIBLE.md:263과 narrative_spine.demo.bridge_roots가 생활 다리를 소유한다.
공개 M01~M06 14root/100잎 및 legacy72/467의 소유root에는 없다.
공유파일의 legacy 소유 arc_father_quiet_call raw·공개PCK·고정 pin·분모는 불변이다.
이 작은 사실 수리는 새 장면/계층 승격이 아니며 기존 미선언 T3 채무를 보존한다.

## 정확 파일 소유

- root KO/EN: content/events/arc_midgame.json, content/events_en/arc_midgame.json의
  위2잎씩만. root 표적검사: 새 tools/night_routine_time_audit.py(--self-test),
  tools/NightRoutineTimeCheck.gd, tools/NightRoutineTimeCheck.tscn,
  tools/audit_scope.json의 등록/전용 fast lane.
  기존 tools/first_win_fact_audit.py는 공유파일의 정확475 전이만 역사 비교로
  역투영하는 adapter를 root가 소유한다. 실제 현재raw/typed proof를 먼저 검증하며
  474 비용·거처 검사와 제품payload를 완화/롤백하지 않는다.
- 직접KO 목표어 저자 order469_review: content/events_ja/arc_midgame.json,
  content/events_zh-CN/arc_midgame.json, content/events_zh-TW/arc_midgame.json의
  위2잎씩만. 영어 중역·간체→번체 자동변환0.
- root 공식수용: content/meta/full_game_localization.json의 정확2×3 기존 교정,
  export/check/import --replace-existing/최초0/기존267배치 raw prefix·41848키 불변.
- root inventory: content/meta/release_content_inventory.json,
  docs/CONTENT_RATING_INVENTORY.md는 실제 변한 현재 지문만 owner 생성과 함께.
  먼저 실측하며 변하지 않으면 변경0; 공개 분모·분류·계약은 수정0.
- order469_history: tools/order470_source_compat.py,
  tools/order470_source_compat_self_test.py, tools/pr31_intake_history.py,
  tools/pr31_intake_history_self_test.py의 source5/receipt1/필요할 때만 metadata2
  정확 후속 전이와 표적 반례. 옛470–474 끝점·영수증을 바꾸지 않으며
  현재 runtime payload에 옛 산문을 돌려주지 않는다. root만 프로젝트 QA/엔진/커밋.
- 비저자 order469_main: docs/agent_reviews/ORDER-475.json만 작성한다.
  원문/목표어10잎·실제 로그·전이·L2 전수검수 후 독립 GO/HOLD/REWORK.
- root 운영: CLAUDE.md 현재, docs/CODEX_QUEUE.md,
  docs/CODEX_QUEUE_L3_PENDING.md 순번만, 이 사양/queue_archive/ORDER-475.md,
  docs/WORK_LOG.md, 생성 docs/STATUS.md, docs/agent_review_decisions.json.

arc_events/endings5·project.godot·Main/StoryMode/GameState/EventManager/EndingSystem·
callback 원문·narrative_spine·사용자 저장/seed·과거 human/agent 보고/판정·public manifest 변경0.

## 증거·마감

1. 두잎밖 raw/구조/gameplay·토큰·문단 불변과5언어 직접 대조.
2. 원본 공식6교정/최초0, 실제 export 후보/census/영수증과267 prefix·키를 결속한다.
3. proven fresh UUID pre-autoload 준비 상태에서 DataRegistry 두잎 로딩,
   실제 자동 선택 우선순위·직접 선택1·EventManager.resolve_narrative_bridge/
   consume→Main._narrative_bridge_summary를 관측한다. mental/현수/seen/slept_early·
   choice 영수증·summary와 W40 콜백 조건을 확인한다. 정확 모집단/고유ID,
   singleton 복원·전체source/보호/runner/로그/외부Godot SHA 전후·exit·marker·
   stdout/Godot오류를 기록한다. 실제 렌더·자연 플레이 관찰로 바꾸지 않는다.
4. 소유 잎·소비자·공식수용·전이 반례/en_coverage·english_hangul·continuity·
   scene_audio_contract·speech_register·release_inventory·demo 계약만 표적검사한다.
   UI대형/240주/전체감사/옛 화면 반복0. 검증 입력 재사용은 실제 동일성 경계를 남긴다.
5. 신규 미해결 실패0·L2 전칸·비저자 한정 판정 전에 완료하지 않는다.
   인간/원어민/물리패드/실제 화면·본편 출시 HOLD를 준비/자동 PASS로 대체하지 않는다.

규범 승격: 새 규범0. 기존 WORK_UNIT/I18N/SCENE_TIER를 적용하며 exact잎·
후속전이·표적 모집단 결속은 일회성이다.


## 2026-10-07 마감 — 심야 취침 순서10잎 한정 GO

- candidate `827848b25fc27e4e850e7191e9b9a870a8370447` / tree `3088fbf0e24af9bcb93d9bd2d2d92a30ad463fe5`.
  비저자 전수10잎·실제 증거 [ORDER-475 보고](../agent_reviews/ORDER-475.json),
  SHA `99688ec2ae3283792b509a5a614b85ce1ddf6dad1cbfef5a25ab986903b78d37`. 이 사실 수리만 GO이며 실제 화면·자연 플레이·
  원어민·인간·물리패드·본편 출시 GO가 아니다.
- source5 `abd8eb37ebf1dd8cd7967365780e2cc8a5a0c4fd` / direct parent
  `d58583aaf7bb9dc53c249f7ad28def492e51e6aa`: result_text/bridge_summary 두잎×5언어.
  새벽1시 본문은 보존하고12시/자정 전 절대취침을 더 공부하지 않고 곧 취침·
  상대적으로 공부를 일찍 마침으로 맞췄다. 새 시각·수면시간·효과·경로·사실0.
  두잎 밖 raw·tokens·LF0/문단1·호칭·선택/조건/효과/플래그는 불변이다.
- 실제 원본 export/check/import --replace-existing×3=9 actualexit0/stderr0,
  529.471837초; result SHA `47d94dd5118462a39b76a2e412975ba3f64037322dd1137e92a10de75fb96def`.
  기존6교정/최초0·267배치 rawprefix·41848키 보존/현재270.
  ledger1 `6f80f2d113b2b684909956dd9d701cc9b9832e38` / direct parent
  `2b30fb563a120a1001f8beee8e02f1228b8f4e8f`는 actual export 후보 그대로다.
  실제collector1 뒤 같은 invocation 함수identity·전체tracked·census 가드9만
  재사용했다. 이전 판정·영어중역·자동간번체 변환·현재payload 역사문구0.
- quick1 원본 release_inventory가 현재 개발지문2·생성보고 불일치를 잡았다.
  metadata0 예상은 철회했다. owner validate_corpus/render_report로 실제 생산한
  두 지문과 보고 대응값만 metadata2 `aae4446cca8a48b55571e76ebcdd41fc0056de8b` /
  direct parent `170c5024b3e985980bc56f466537046cd6aa2c3c`로 결속했다. 기존 sexuality는
  '불을 껐', alcohol은 비소유 맥주 선택으로 후보였으며 전체 KO/EN event
  해시가 두 수리잎을 소비했다. 후보/개수/강도/분류/법률판정0변경이다.
  owner 생성 증거 SHA `1047fab6fd30ac4bdf9aa648934670d8ecad5bb581a366590d0c431c7db4317d`;
  quick2의 원본 release_inventory 정상 CLI actual0로 현재지문/생성보고 일치를 확인했다.
  공개14root/100잎·legacy quiet-call·public 분모/계약/축9 불변이다.

### L2 — 한 사실/두 실제 소비 잎 × 5언어, 전 칸

| 단위 | 도달 경로 | 생산자 ↔ 독자 | 바꾸는 상태 | 포기 시 잃는 것 | 서사 위치 | 장면 계층 | 닫는 것 |
|---|---|---|---|---|---|---|---|
| arc_night_routine/choices/1/result_text | NIGHT_ROUTINE_TIME_CHECK_OK120; route35/직접5 prepared | arc_midgame.json:2151↔GameState.apply_choice; StoryMode.gd:6400/6412 | mental50→56; hyunsu affinity0→1; seen/slept_early false→true; receipt1 | callback_slept_early_echo; W40부터 조건적격(실제 발화주 미관찰); choices0/2 경쟁 | 1.living_bridge; W12–22/M03–06 prepared | T3(미선언 기본); SCENE_TIER.md:56; 승격0 | seen=true→기존 재진입차단; 새 경로폐쇄0 |
| arc_night_routine/choices/1/bridge_summary | NIGHT_ROUTINE_TIME_CHECK_OK120; priority50/bridge5 prepared | arc_midgame.json:2152↔EventManager.gd:875/903/908↔MainGame.gd:12073 | 동일choice1 상태; summary enqueue1→consume1→0; cooldown9999/recent1 | 동일callback; W40부터 조건적격; route_invest우선/기본choice2 보존 | 1.living_bridge; W12–22/M03–06 prepared | T3(미선언 기본); SCENE_TIER.md:56; 승격0 | seen 차단; 소비queue 비움; 새 경로폐쇄0 |

### 실제 표적검사와 실패 보존

- runtime1 actualengine/wrapper exit1·route35FAIL/그외85PASS·restoredtrue·보호true;
  result SHA `7f6b2b0184cc91f0518a0879b666a2a2bac850e23a2b0dc0fa8fd09856e88cdb`. W11–23 준비상태가 아직
  오지 않은 연말4 close_seen까지 true로 세웠다. 실제 MainGame.gd:7211–7228→
  :6454–6456의 정상 year_scene_skipped 기록을 purity assertion이 잡았다.
  원실패는 그대로 남기고 준비플래그4만 제외했다. 게임router·120모집단·전체
  상태 동일성 조건을 완화하지 않았다. 이 소스 인과와 실제 로그를 구분한다.
- runtime2 fresh UUID pre-autoload 실제engine/wrapper exit0, exactmarker1,
  loaded5/priority50/route35/direct5/bridge5/callback20=120 고유ID 전수PASS,
  stdout=Godot rows·stderr0/engine오류0·singleton복원true.
  실제choice1 mental50→56/현수0→1/seen·slept_early/receiptindex1,
  bridge resolve→consume→Main.summary 및 W39/40 조건reader 경계를 확인했다.
  direct는 apply_choice+실제_fmt이며 StoryMode 입력/UI 실행이 아니다.
  callback은 조건적격이며 random scheduler 발화·자연도달·실제렌더가 아니다.
  result SHA `728752727a7f25236dd835cf9d20553e7d5ace7a990fefd411e7b4d0d65450f4`;
  외부Godot SHA `e6b5cfdc226ffb7ec4f4950b0b12ddba4f040624724cff1acce9ae1241cf0034` 전후동일,
  전체tracked·보호11그룹·runner·로그불변. 뒤 지원핀/현재문서 변경은
  실제5언어제품·consumer·fixture·bootstrap·외부engine 입력동일성으로만 재사용한다.
  최종 재사용 결속 input-reuse2.json SHA `84830796f7aa33e2f40742f07034bd69fe81df2b7be6cbf1ec59280916c2fef0`;
  runtime2 뒤 CLAUDE/지원4/metadata2의7만 바뀌고
  나머지3203 tracked·event641(638 JSON/3 .gitkeep)는 같다.
- focused1 source/receipt80/44는 clean170c 실제PASS·251.964436초,
  SHA `32cc4f90c04e9e12961fe75bec81d4c6d2a2c2231cd4895bfb725368b7fddfa3`이며 최종후보 재실행으로 바꾸지 않는다.
  final focused2 actual metadata40/6 반례/조건·112.701288초,
  SHA `4f1569a69a7504c5d1e45e41b3c4931b7d3a5a8d48bf310d5a09a7cf69d467dc`로 새 metadata2 전이/역투영·독립
  JSON필드·거짓핀·주변값/레이아웃/캐시·이전source/receipt 끝점을 검증했다.
  current typed proof 검증 뒤 역사비교만 역투영하며 실제제품 payload는 현재다.
- quick1 전체FAIL(첫7 stage actualPASS, release1 후중단)·236.139461초,
  SHA `1b90f64ff4a1ece9dc79d30fcaf4d4054cf28acbe46c1590dfabbc999f2dd433`를 보존한다. 첫7 원본script·소비제품·
  비변경3204 tracked 입력동일성은 최종 reuse2로만 결속한다.
  변한 지원4/metadata2는 새40/6 및 fresh typed proof 정상완료로 검수했다.
  final quick2 남은 원본5 CLI actualexit0/stderr0·113.395722초,
  SHA `86c7fca9b4344810df2e33e285a57c28a4f74232296c84824daf1b9e44797f5f`. 합계12 검사 경계는 7기존단계 제한재사용
  (원본script/소비제품 동일+변경증명부 별도검수)+5새실행이며
  단일 quick12 성공이 아니다. 전체source/runner/로그 보존이다. UI대형·240주·
  전체감사·옛 화면 반복0. 신규 미해결 실패0; runtime1/quick1을 PASS로 재분류하지 않는다.

| 검사 | 실제 exit | stdout SHA256 | stderr SHA256 |
|---|---:|---|---|
| quick1@170c/night_routine_time | 0 | `78089d7602b8a416e81ee3a82c1a412c078a1f952a702552bdd472b38a3b185b` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| quick1@170c/first_win_facts | 0 | `0b87f0f9cb2dc4aee5cdabf9e835997532dfefbfda54d89bccedf5affcbb3145` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| quick1@170c/en_coverage | 0 | `3c8fb0fe51e73967455b28149d28977ee7a44a9ff3891baae9a938f89d81451b` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| quick1@170c/english_hangul | 0 | `15ad7fcf86b374cacd08c98110654b04febf4b65210231e6a7b7fb237abe6c44` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| quick1@170c/narrative_continuity | 0 | `50fb37b91b7b1ad1fb7d25f2c7d2fffe1921a944de98518c20333b01d3949f26` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| quick1@170c/scene_audio_contract | 0 | `b629eaab373ccfbd504686997f7cb04b8ebdc484fe4328ec4a6e67432d6b9132` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| quick1@170c/speech_register | 0 | `43952f3918dd5c4d1a8b1002dcec7dad706502315a57d115d67195724324dc11` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| quick1@170c/release_inventory | 1 | `13dd3d43336069f0e5d1c6641ebbe7154a230646a2caeafd498d4e5f48900801` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| quick2@827848b/release_inventory | 0 | `9bca145d3db7bb10745ec0c7deaa709ced89d47c09dbb8de9021c097de5ac516` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| quick2@827848b/demo_i18n | 0 | `a99e3d2981750a415a713bf9292c56abe2c65a0eab43dbe25b03c119c0c0dce8` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| quick2@827848b/context_manifest | 0 | `64d15675e07616c8691d481e27a564b7be1c00e753222306fb67fea273cdc566` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| quick2@827848b/queue_consistency | 0 | `591b8736de73337ab8bda79d4bb66a995e451ffc6b5eaf1382e5a91625bb9d23` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| quick2@827848b/audit_scope_verify | 0 | `1442a1ca89fa4dde39e6d3b1147deeb786c87fa37c15a4043da722427c9f5810` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |

### 보존·판정 경계

- human_gates SHA `6ab5c927c9f327aa2892c231d49fe144c1c154cb6069fc539f4f3f8e9c30c9f6`;
  공개GO1/인간OPEN45·역사REJECT/HOLD·149 captureFAIL/연속창HOLD·474 한정GO 보존.
  project·Main/StoryMode/GameState/EventManager/EndingSystem·callback/narrative_spine·
  arc_events/endings·public manifest·사용자 저장/seed 변경0.
- gangnamdream-dev의 소유·전이분리·표적검수·pre-autoload·증거분리를 적용했다.
  새규범0/기존 WORK_UNIT/I18N/SCENE_TIER 적용; exact배치 결속은 일회성이다.
  자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.
- 후속 확인 결함은 별도선언하며 Mac잠금 반복확인·사용자 재서명 대기로
  돌리지 않는다. 실제 화면149/457/302·전체판·외부출시는 HOLD다.
