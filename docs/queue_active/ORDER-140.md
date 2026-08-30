# Active Queue Spec: ORDER-140

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-140 [P0·스토리 데모] M2 위험의 6월 청구와 M3~M6 exact 선택을 실제 장면에서 회수한다

**착수 선언 (2026-08-31, Codex):** ORDER-139가 active `story_demo_rc`를
제품 변경 없이 전수 실측해 11 runtime variant·24 선택·1,080 합법 서명을
고정했다. 이 오더는 그 중 M2 환수 callback 미소비, 심화 경로의 후속 무반응,
M3~M5 exact 선택 미회수, M6 다섯 선택의 후속 이야기 미도달, selector
17/24만을 표적 수리한다. 월간 행동판·신규 시스템·신규 밸런스는 범위 밖이다.

## 깊이 3문

1. 이 수리를 빼면 M2의 돈·몸·마음 차이는 숫자로만 남고, M3~M6의 선택은
   다음 장면이 읽지 않는 일회성 버튼이 된다.
2. 기존 `callback_escaped_dirty_trace`를 그대로 재생하면 6월 시간선에 한 달 뒤
   판정 장면이 끼어들고 중복 수치 피해까지 생긴다. 기존 W24가 소유한 6월 24일
   초기 전화·재유혹 문자만 재생하고 선택 효과는 각각 한 번만 적용한다.
3. 한국어를 고친 뒤 예전 JA·zh 패키지를 그대로 두면 사람 판정 대상이 언어별로
   달라진다. 새 6월 장면·동적 회수 문장을 세 언어에 같이 반영한 exact RC로만
   다음 사람 게이트를 연다.

## 배치 A — 위험 경로·exact 선택 회수 20단위

1. source `16675f6` / tree `aed6904f` / BUILD `2026.08.25.1`의 24 선택 기준선을 고정한다.
2. M6 진입의 clean·restitution·escalation 세 경로를 exact flag/deferred로 구분한다.
3. restitution은 `claim_deferred_event("callback_escaped_dirty_trace", 21)`만 사용한다.
4. claim과 controller session 저장을 하나의 transaction으로 묶고 실패 시 둘 다 롤백한다.
5. schema 1을 유지하며 optional `m6_route_context`를 exact shape로 검증한다.
6. restitution은 `v2_dirty_trace_initial_call`, escalation은 `v2_dirty_recruiter_week24`를 먼저 보인다.
7. clean은 추가 위험 root 없이 바로 M6으로 간다.
8. 새 경로 root의 두 선택에 기존 효과와 exact runtime receipt를 각 1회 적용한다.
9. root→M6은 6월 24일→26일 `time_cut` 정본 contract을 runtime에 복제한다.
10. M6→ledger는 기존 `v2_demo_first_bill->v2_demo_first_bill_ledger` 전환을 복제한다.
11. M6 도입이 M3 다은, 지연, M4 root·answer, M5 재혁의 exact 선택 문장을 읽는다.
12. M3 다은 1번 영수증이면 두 사람 모두 서로의 이름을 모른다.
13. 그 경로의 M6 다은 선택·결과는 `야간 직원`만 쓰고 다은·민준의 이름 호칭을 만들지 않는다.
14. 다른 M3 다은 경로의 기존 이름·대화는 그대로 보존한다.
15. M6 다섯 선택은 정본 효과·장소·결과 산문을 보존하고 ledger follow-up을 각각 가진다.
16. ledger 도입이 고른 한 줄과 놓친 네 줄을 localized M6 choice text로 동적 표시한다.
17. ledger의 단일 `expression` 선택은 수치·flag·controller receipt를 생성하지 않는다.
18. 새 흐름은 clean 9, restitution 10, escalation 10개 durable controller receipt를 남긴다.
19. 기존 BUILD의 M6 `story`로 이미 들어간 저장에 새 root를 역삽입하지 않는다.
20. 기존 M6 전환 저장은 시작 전에만 새 경로로 안전하게 승격한다.

## 배치 B — 5언어·저장·패키지 재발급 20단위

1. JA·zh-CN·zh-TW에 초기 전화·재유혹 문자·ledger 3사건을 추가한다.
2. 세 언어 event scope를 11→14사건, 82→100 leaf로 exact 고정한다.
3. `description_memory_if_known`의 dictionary 값 2개도 localized leaf로 세고 key parity를 검사한다.
4. 동적 M6 도입·ledger·미지 다은 선택·결과를 세 UI 사전에 번역한다.
5. 대체된 예전 M6 도입 key는 삭제해 unknown extra key를 남기지 않는다.
6. controller UI 38, StoryMode UI 82, merged 120, 기본 이름 포함 target 121을 고정한다.
7. zh native number 검사에 `석 달`→`三个月/三個月` 정확 대응과 2·4 오류 반례를 추가한다.
8. zh-TW 자연스러운 `一則訊息`을 허용하되 수량 오류는 닫는다.
9. 29 visible option 중 28 receipt-bearing 선택을 합법 fresh prefix에서 전수 실행한다.
10. ledger expression은 별도로 serialize 전후 zero-state를 증명한다.
11. clean·restitution·escalation과 M4 두 branch를 5 locale 실제 StoryMode로 커버한다.
    escalation의 M2는 원고 1번 선택을 0번에 복제하는 QA overlay 없이 실제 index 1을 누른다.
12. restitution due callback이 큐에 남지 않고 정확한 6월 24일 root로 보였음을 증명한다.
13. escalation의 W24 문자가 실제 장면 독자이고 다음 M6와 연결됨을 증명한다.
14. cold resume를 dirty root, M6 도입·결과, ledger 도입·결과, controller 복귀에서 검사한다.
15. 손상된 route context·허위 완료·중복 deferred는 fail-closed 또는 롤백한다.
16. 30일 월요일·6월 29일 일정, 답장·이체·소유·허위 동석을 새로 만들지 않는다.
17. `project.godot`·`export_presets.cfg`·GameState·StoryMode·기존 사건 소스는 byte-exact로 보존한다.
18. 별도 패키지 보호 자식이 닫힌 뒤 선언된 범위 확장으로 source
    commit/tree/BUILD와 macOS app·PCK·launcher·ZIP·manifest hash를 고정한다.
19. 예전 `771d0e7`·`16675f6`을 새 사람 판정 후보로 재사용하지 않는다.
20. 자동 검사는 회귀 증거로만 기록하고 M01~M06 세 경로 정상 속도 사람 게이트를 OPEN으로 남긴다.

## 정확한 파일 소유권

**선언·마감:** `docs/CODEX_QUEUE.md`, 이 사양, `CLAUDE.md`,
`docs/WORK_LOG.md`, `docs/BUILD_PIPELINE.md`, `docs/DEMO_FIXLOG.md`,
`docs/queue_active/ORDER-124.md`, `docs/human_gates.json`,
`docs/queue_archive/CODEX_QUEUE_2026-08.md`, 생성본 `docs/STATUS.md`.

**controller:** `playtests/order124/StoryChoiceM1M6Playtest.gd`.

**실제 StoryMode QA selector·데모 controller 저장 복구 (2026-08-31 범위 확장):**
`scenes/StoryMode.gd`의 `_story_demo_real_flow_choice_index()`에 M2 fallout의 actual
route index를 전달하는 최소 변경과 `_story_demo_controller_session_snapshot()`이
각 primary/tmp/bak 후보를 semantic reconcile까지 통과시킨 뒤 선택하는 변경만
소유한다. 정적 검토가 controller의 test-only index-0 원고 치환이 실제 authored
index-1 플레이를 대체하고, shape-valid·semantic-invalid primary가 valid `.bak`를
가리는 저장 경계를 각각 확인했으므로 제품 변경 전에 이 범위를 확장한다. 제품
StoryMode의 일반 입력·연출과 위 두 함수 밖 저장 동작은 바꾸지 않는다.

**대상 번역:** `content/events_ja/story_demo_events.json`,
`content/events_zh-CN/story_demo_events.json`, `content/events_zh-TW/story_demo_events.json`,
`locale/ui_ja.json`, `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json`.

**표적·번역·패키지 검사:** `tools/StoryChoiceM1M6Check.gd`,
`tools/StoryDemoFourLanguageCheck.gd`, `tools/story_demo_localization_audit.py`,
`tools/story_demo_density_audit.py`, `tools/fixtures/story_demo_density_contract.json`,
`tools/zh_translation_audit.py`, `tools/audit.sh`, `tools/audit_scope.json`.

**패키지 발급 (2026-08-31 범위 확장):** `tools/build_story_demo_macos.sh`,
`tools/story_demo_package_audit.py`. 닫힌 ORDER-141 보호를 보존하며 아래 이중
신원과 세 경로 발급만 소유한다.

위에 없는 사건 정본·런타임·표면·저장·엔딩·자산 파일은 수정하지 않는다.
특히 `project.godot`, `export_presets.cfg`, `autoloads/GameState.gd`,
`systems/DemoCoreLoopV2.gd`, KO/EN event JSON은 읽기 전용이다. `scenes/StoryMode.gd`는
위 실제 QA selector 한 분기와 controller session 후보 선택 외에는 읽기 전용이다.

## 착수 중 확인된 실제 선택 우회와 범위 확장

- 최초 구현은 `--story-demo-real-flow-smoke`의 escalation M2에서만 원고 choice 1을
  choice 0 자리에 복제하고 receipt를 1번처럼 쓰는 controller overlay를 사용했다.
- 이 방식은 화면 문장은 맞아도 실제 두 번째 버튼을 누르지 않으므로 `actual StoryMode`
  증거가 아니다. 이 상태의 3경로 PASS는 승격 증거로 폐기한다.
- overlay를 삭제하고 StoryMode의 전용 real-flow selector가
  `arc_temptation_fallout`에서 route choice를 그대로 반환하게 한다. 그 뒤 clean,
  restitution, escalation을 새 격리 저장에서 다시 완주해 actual index·receipt·재시작을
  함께 검증한다.

## 착수 중 확인된 M6 저장 순서·backup 복구 범위 확장

- M6 restitution context에서 root receipt·record·completed만 지우고 공통 M6
  receipt를 남긴 shape-valid 저장이 기존 validator를 통과했다. Continue하면 이미
  끝난 M6 뒤에 경찰 전화 root가 재생되는 역순 복구가 된다.
- persisted `completed_event_ids`와 current-month choice record가 scheduled route의
  같은 prefix인지 검증하고, live receipt reconcile도 기존 prefix가 먼저 유효한
  경우에만 뒤의 정상 live prefix를 덧붙인 뒤 strong validator를 다시 통과시킨다.
- StoryMode는 primary의 얕은 shape가 맞으면 즉시 후보 탐색을 멈췄다. primary가 위
  의미 손상이고 `.bak`가 정상이면 수동 저장이 비활성화되므로, 각 후보를 semantic
  reconcile까지 통과시킨 뒤 선택한다. exact M6-before-root 변조 거부와 실제
  primary/.bak 복구를 회귀 검사로 고정한다.

## 착수 중 확인된 별도 패키지 선행 결함

- 현 builder는 반려된 BUILD `2026.08.24.2` 아카이브 3파일이 실제로
  존재해야만 시작하는데 현재 저장소와 연결 디스크에는 빈 디렉터리만 남았다.
- 세션 증거에서 `MANIFEST.json` 9,238 bytes / `87f3491f...`와 checksum
  파일은 exact 복구했지만, 389,505,944 bytes / `626196d6...` ZIP 원문은 없다.
- exact source `e9aff5f` / tree `ad4d88a` / Godot 4.6.2의 clean one-shot
  재빌드도 ZIP `e05fabe4...`, app tree `ad3ed20f...`, launcher `4c0aa3aa...`,
  PCK `5e66c194...`로 역사 hash와 불일치했다. 타임스탬프만 맞춰서는 복원할 수 없다.
- ZIP 자체나 전체 아카이브를 복구했다고 위조하지 않는다. 실종 상태와
  역사 expected hash를 같이 고정하고, 없는 아카이브를 등록된 손상 증거로
  보호하는 최소 자식 오더를 패키지 배치 전에 별도로 연다.

## ORDER-141 완료 뒤 패키지 범위 확장

1. 제품 신원은 `4e80a63e89821094b8bab21b8d5c73ecfc9b6278` / tree
   `0fdddf11e2ef030cd172d23e691e3d7da4ea29ff` / BUILD `2026.08.31.1`이다.
2. package source는 ORDER-141·density·builder QA를 포함한 새 clean commit이며,
   제품 commit이 그 조상이어야 한다.
3. `project.godot`, `export_presets.cfg`, icon 6파일/경로와 `assets`, `autoloads`,
   `content`, `locale`, `playtests`, `scenes`, `steam_input`, `systems`,
   `ui_components`의 product→package source diff는 0이어야 한다.
4. manifest는 package `source.revision/tree`와 별도 product 신원·scope·diff·
   ancestor 판정을 기록한다.
5. audit는 그 불리언을 믿지 않고 Git에서 tree·ancestor·diff를 다시 계산한다.
6. FourLanguage marker는 `locales=5 routes=5 months=30 weeks=120 settlements=30
   ap_surface=0 save=5 story=10 build=2026.08.31.1`로 고정한다.
7. native real roundtrip은 clean/ko/9, restitution/en/10,
   escalation/zh-CN/10 세 행을 이 순서로 실행한다.
8. builder·manifest는 route arg만 쓰고 legacy choice arg를 금지한다.
9. marker·manifest는 `route/m02/receipts`를 exact로 구분하고 `choice`를 금지한다.
10. 세 경로는 별도 RuntimeQA namespace를 쓰고 모든 종료 경로에서 제거한다.
11. `validation.real_story_roundtrips`는 세 행과 exact key/args/marker만 허용한다.
12. density audit·fixture·`docs/human_gates.json`을 package source contract에
    넣고 self-test 29·actual 14/29/28·1,800 서명을 같은 source에서 실행한다.
13. staged audit는 원 저장소 Git object DB를 명시적으로 읽고 working-tree
    fallback이나 fixture-only retarget을 허용하지 않는다.
14. source contract 각 행의 path/hash/size와 순서·중복을 실제 Git blob으로
    재검증한다.
15. ORDER-141의 evidence 세 파일과 `archive_restored=false`,
    `candidate_eligible=false`, `missing_with_loss_receipt` 보호를 byte-exact로 유지한다.
16. self-test는 runtime 한 바이트 drift, non-ancestor/wrong tree, 세 경로 누락·중복·
    순서, locale/m02/receipt/namespace/args, legacy choice, density marker, loss 행
    변조를 각각 거부한다.
17. package source commit/tree로 앱·ZIP·manifest/checksum을 만든 뒤 package audit를
    같은 commit에서 다시 실행한다.
18. `human_gates.json`의 최종 `commit/tree`는 제품 commit이 아니라 실제 package
    source commit/tree를 기록하고, note에 제품 `4e80a63/0fdddf1`과 별도 review
    wrapper HEAD를 명시한다.
19. 세 경로 정상 속도와 JA·zh-CN·zh-TW 원어민 판정은 OPEN이다.
20. 자동 marker는 사람 GO가 아니며 main·본편 이관은 HOLD다.

## 완료 증거

```bash
python3 tools/story_demo_localization_audit.py --self-test
python3 tools/story_demo_localization_audit.py
python3 tools/story_demo_density_audit.py --self-test
python3 tools/story_demo_density_audit.py
python3 tools/zh_translation_audit.py --self-test
GODOT=/Users/junheelee/Downloads/Godot.app/Contents/MacOS/Godot \
  /Users/junheelee/Downloads/Godot.app/Contents/MacOS/Godot --headless \
  --quit-after 3600 res://tools/StoryChoiceM1M6Check.tscn
GODOT=/Users/junheelee/Downloads/Godot.app/Contents/MacOS/Godot \
  /Users/junheelee/Downloads/Godot.app/Contents/MacOS/Godot --headless \
  --quit-after 3600 res://tools/StoryDemoFourLanguageCheck.tscn
python3 tools/audit.py
GODOT=/Users/junheelee/Downloads/Godot.app/Contents/MacOS/Godot ./tools/audit.sh
git diff --check
```

- exact 출력은 14 event variant, 29 visible option, 28 receipt-bearing selector,
  clean/restitution/escalation 서명·영수증·생존 범위를 함께 인쇄한다.
- 5 locale에서 24주·6정산·AP 표면 0·exact StoryMode 완주·저장 재시작을 인쇄한다.
- 패키지는 clean/restitution/escalation 실제 전환과 최소 한 대상 언어 cold resume를
  native OS process에서 확인한다.
- 사람 밀도·재미·일·중·원어민 문체는 자동 GO로 닫지 않는다.

## 사람 판정

기존 `story_demo_rc` BUILD `2026.08.25.1`은 이 수리의 평가 대상이 아니다. 새 exact
source·tree·BUILD를 발급한 뒤 clean, restitution, escalation을 M01~M06 정상
속도로 각각 완주해 `선택이 나중 장면에서 내 행동으로 돌아오는가`, `심화
경로의 돈이 뒤 장면에서 청구되는가`, `M6의 한 가지 실행과 네 가지 포기가 자연스러운가`를
판정한다. 그전에는 `story_demo_rc`·main·본편 이관을 GO로 기록하지 않는다.

## 규범 판정

M2 위험의 6월 청구·M3~M6 exact 선택 회수·이름 경계는 기존
`docs/CHOICE_CONSEQUENCE_SYSTEM.md`와 사건 원고가 소유한다. 이 사양의 BUILD,
route context shape, 검사 숫자, 패키지 명령은 일회성 판정 지시이며 새 정본
승격 대상이 아니다.
