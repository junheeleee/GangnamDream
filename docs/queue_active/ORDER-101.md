# Active Queue Spec: ORDER-101

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-101 [P0·Chapter 1 W1~8] CH1-A — 온보딩·자기소개서/지원·첫 후속을 한 소유권으로 잇는다

**사용자 지시 (2026-08-12):** Chapter 1의 완성 단위를 W1~48로 두고 끝까지
완성한다. ORDER-100이 봉인한 48행 중 첫 8행을 먼저 실제 제품으로 수리하며,
이 배치의 수치와 표면을 다음 8주 사양의 입력으로 쓴다.

## 현재 실측과 범위

현재 제품은 W1~8의 여덟 행을 갖지만, 행 부채 10개와 온보딩 경계의 전역 부채
2개가 남아 있다. 이 오더는 **20단위 = 여덟 행 전수 8 + exact debt 수리 12**를
한 배치로 소유한다. W9 제품 노드는 만들지 않되 W1~8 producer가 여는 첫 named
consumer의 도달성까지 증명한다.

행 부채 10개:

- `m1_resume`: `DEAD_CARD` 1 + `ORPHAN_FACT` 2
  (`fact:resume_polished`, `receipt:action:m1_youth_center_resume_clinic`)
- `m1_father`: `DEAD_CARD` 1
- `m2_advancement`: `DEAD_CARD` 1 + `ORPHAN_FACT` 1
  (`receipt:action:m2_seorin_application`)
- `m2_livelihood`: `ORPHAN_FACT` 1
  (`receipt:action:m2_rain_delivery_shift`)
- `m2_people`: `DEAD_CARD` 1 + `AUTO_PERSON_PICK` 1
- `m2_self`: `ORPHAN_FACT` 1
  (`receipt:action:m2_sleep_debt_sunday`)

온보딩 경계 부채 2개:

- `LAYER_COLLISION`: `event:v2_opening_application_send:application_status`
- `UNSCHEDULED_CHAIN`: `bundle:sns_pressure_night`

`m1_convenience`, `m1_recovery`는 현재 row debt 0이므로 퇴행시키지 않는다.
W4/W8 milestone의 기존 source scenario, W24의 fan-in/save 계약, W25~48 gap은
이번 오더가 다시 설계하지 않는다.

## 깊이 3문

1. 지우면 자기소개서를 잘 써도 지원 조건이 달라지지 않고, 완료한 카드는
   사라진 뒤 다음에 무엇을 할지 주지 않으며, 사람 행동은 플레이어 대신 첫
   후보를 자동 선택한다.
2. 주간 행동·생활 빌드·Story를 한 버튼의 여러 이름으로 합치지 않는다. W1의
   실제 행동 transaction이 시간·품질·지원 material의 유일 owner이고,
   Story는 그 영수증을 읽어 면접의 표현·기억만 맡는다.
3. 완료/만료, 품질 0~3, 두 사람 동시 후보, fresh/구 저장의 모든 합법 경로가
   다음 동사에 닿아야 한다. 문구·월말 요약·reader ID만 추가해 부채를 지우면
   실패다.

## 20단위 구현 계약

### 여덟 행 전수 8단위

1. `m1_resume`: fresh W1 안내는 stable node ID로 자기소개서 수행층에 들어간다.
   Back/Cancel은 무변이이며 최종 Send 한 번만 주간 commitment 1,
   `m1_youth_center_resume_clinic` action receipt 1, typed quality, Mirae application
   transition 1을 한 transaction으로 쓴다. 플레이어가 고른 실제 unspent
   capacity 1개를 소비하되, fresh turn 1·미완료·무receipt에서만 명시적인
   `onboarding_completion_override`가 자기소개서 노드를 완료한다. 고정 슬롯이나
   이상적인 seed를 가정하지 않으며 구 저장과 이후 진입은 기존 threshold 3·
   progress band를 그대로 쓴다.
2. `m1_convenience`: 기존 반복 행동·다음달 이월·receipt cardinality를 보존하고
   새 안내가 W2~W4 선택권을 가리지 않는지 회귀한다.
3. `m1_father`: 완료 branch receipt를 기존
   `father_quiet_call` 세 variant의 예약된 다음 동사에 연결한다. 만료는
   `m2_people` fail-forward이며 완료와 같은 signature가 아니어야 한다.
4. `m1_recovery`: 현재 반복·이월과 회복 effect를 보존하고 W1 안내 뒤 남은
   합법 seed/order에서 선택 가능해야 한다.
5. `m2_advancement`: W1 typed resume receipt에서 준비 variant를 계산하되 품질이
   낮거나 M1 카드가 만료되어도 합법 지원 경로는 남긴다. 완료 action receipt와
   application identity가 W9 `m3_seorin_result_message`의 exact reader에 닿는다.
6. `m2_livelihood`: 완료 action receipt가 기존 Jiyeon 후속의 실제 availability나
   조건을 바꾸며, producer-result 카드나 월말 문구만 reader로 세지 않는다.
7. `m2_people`: 가능한 Hyunsu/Cafe 후보를 보드에 함께 보이고 플레이어가 하나를
   직접 확정한다. 선택 identity를 allocation과 함께 저장하고 선택한 branch만
   receipt·관계 변화·Hyunsu 2/Sangchul 1 후속 중 맞는 것을 생산한다.
8. `m2_self`: 완료 action receipt를 기존 W9 `m3_self` 경계의 named
   offer/state variant가 읽는다. ORDER-101은 그 exact non-Story reader field와
   edge까지만 소유하고 W9 보드·본문은 만들지 않는다. 기존 수치 밴드를 조용히
   바꾸지 않으며, threshold/effect 변경이 필요하면 먼저 별도 판정을 올린다.

### exact debt 수리 12단위

9. `m1_resume` completed terminal은 실행 가능한 M2 지원 준비 surface를,
   expired terminal은 조건이 다른 fail-forward surface를 연다. 둘 다 닫힌
   M1 카드를 다시 focus/commit할 수 없다.
10. `fact:resume_polished`는 typed action receipt에서만 도출한다. free flag만
    주입하면 효력이 없고, sibling fact swap은 거부한다.
11. `receipt:action:m1_youth_center_resume_clinic`의 품질 0·1·2·3과 expiry
    다섯 경로가 M2 지원의 availability/cost/threshold/result/choice 중 최소 하나를
    source-bound하게 다르게 만든다. 각 상태는 fail-forward이며 정확 수치는
    기존 밴드 안에서 첫 실제 balance run 뒤 재조정한다.
12. `m1_father` completed의 세 branch receipt를 기존 세 후속 reader가 전부
    읽고, 잘못된 sibling memory로 바꿔 끼울 수 없다.
13. `m2_advancement` completed terminal은 W9 result를 예약하고 expired terminal은
    M3 advancement fail-forward를 연다. 둘의 실제 surface/조건이 같으면 실패다.
14. `receipt:action:m2_seorin_application`은 W9 result reader가 completed bundle,
    exact application/turn/status와 함께 읽는다. 상태 직접 주입은 제품 증거가 아니다.
15. `receipt:action:m2_rain_delivery_shift`는 기존 Jiyeon unlock의 현재 run
    provenance를 강화한다. 구 schema 저장은 기존 completed-bundle fallback을
    보존하되 새 run의 receipt를 발명하지 않는다.
16. `m2_people` completed terminal은 선택 branch의 기존 Hyunsu/Sangchul 후속만
    열고, expired terminal은 M3 people fail-forward를 연다.
17. `m2_people.selection_owner`를 `runtime_first_eligible`에서 durable player
    selection으로 바꾼다. 후보 JSON 순서를 뒤집어도 선택 결과가 바뀌지 않는다.
18. `receipt:action:m2_sleep_debt_sunday`는 새 M3 회복 near reader가 실제
    offer/state variant를 바꾸며 display/month-summary reader로 대체할 수 없다.
19. `v2_opening_application_send`의 fresh material writes를 Story에서 제거한다.
    fresh W1 transaction만 application·quality·build를 쓰고 Story choice는
    설명·표현과 result presentation만 소유한다. 구 preplan 저장은 provenance를
    보존하며 새 weekly receipt를 소급 생성하지 않는다.
20. authored `sns_pressure_night`를 Month 2 world clock의 source-derived 위치에
    정확 1회 예약해 `jaehyuk_world_meet`까지 닿게 한다. system consequence는
    주간 slot/capacity/action receipt를 소비하지 않는다.

## 온보딩·후속 소유권

- fresh 경로는 `프롤로그 → W1 guided resume/application commitment → 동일 주
  면접 consequence → 125년 회고 → 남은 M1 보드`다. 안내 중간 버튼은
  상태를 쓰지 않고 최종 Send만 atomic commit한다.
- W1 면접과 W5 `m2_mirae_result_message`는 다른 consequence다. 둘 다 exact Mirae
  application producer 없이는 0회, 있으면 각 1회다. W5 결과는 `interviewed →
  no_offer`만 쓰고 주간 slot·weekly receipt·current job을 만들지 않는다.
- M2 Seorin result는 W9 경계 reader까지만 이번 오더가 강화한다. W9 노드·본문·
  W9~16 보드는 ORDER-102가 소유한다.
- `m2_youth_center_mock_interview`는 authored offer만으로 next verb라 부르지 않는다.
  실제 board terminal transition이 없는 동안 이 오더의 완료 근거에서 제외한다.

## 저장·원자성 계약

- **post-result durable + pre-result restart-on-load**를 선택한다. allocation
  pending 저장은 고른 capacity·node와 owner만 보존한다. draft-pre-Send와
  mid-interview의 입력 답안·점수는 저장하지 않으며 load 시 같은 minigame을
  처음부터 다시 연다. final Send가 quality/application/action receipt를 모두
  성공시킨 뒤 Story로 넘기기 전에 기존 SaveManager entrypoint로 한 번 저장한다.
- resume quality, application write, action receipt, Story handoff의 각 late failure는
  전체 pre-state rollback 또는 같은 durable receipt 재표시만 허용한다. 부분
  polished·부분 submitted·capacity 이중 차감은 금지다.
- checkpoint는 pre-commit / draft-pre-Send(restart) / post-Send-pre-Story / Story choice /
  Story result / post-interview-pre-week-close / week-closed / W5 result presented /
  consumed 아홉 개다. 각 save를 두 번 load해 AP·capacity·effect·quality·
  application·choice·completion cardinality를 검사한다. mid-interview도
  restart-on-load이며 이미 확정된 application·capacity는 다시 쓰지 않는다.
- legacy before-send, submitted/presented, mid-interview, interviewed/math 저장은
  origin/schema를 보존한다. 새 안내가 과거 클릭이나 weekly receipt를 발명하거나
  이미 본 결과를 다시 적용하면 실패다.

## 정확한 파일 소유권

**제품/데이터 10:** `content/meta/demo_core_loop_v2.json`,
`content/meta/story_rules.json`, `content/meta/narrative_spine.json`,
`content/events/core_loop_v2_events.json`,
`content/events_en/core_loop_v2_events.json`, `systems/DemoCoreLoopV2.gd`,
`scenes/MainGame.gd`, `scenes/JobHuntMiniGame.gd`, `scenes/SeoulCycleBoard.gd`,
`scenes/StoryMode.gd`.

**기계/회귀 8:** `content/meta/chapter1_core_loop_v2_causal_ledger.json`,
`tools/chapter1_core_loop_v2_causal_debt_baseline.json`,
`tools/chapter1_core_loop_v2_causal_ledger_check.py`,
`tools/demo_core_loop_v2_audit.py`, `tools/CoreLoopV2CycleCheck.gd`,
`tools/CoreLoopV2FirstEntryCheck.gd`, `tools/CoreLoopV2CycleBalanceCheck.gd`,
`tools/run_core_loop_v2_input_qa.sh`.

**정본/선언/증거 9:** `docs/CORE_LOOP_V2.md`, `docs/BALANCE.md`, 이 사양,
`docs/CODEX_QUEUE.md`, `docs/QA_CHECKLIST.md`, `docs/WORK_LOG.md`, `CLAUDE.md`,
완료 시 생성하는 `docs/STATUS.md`, 사람 L3를 등록할 때만
`docs/human_gates.json`.

**비소유:** `autoloads/{GameState,SaveManager,EventManager,DataRegistry,
MetaProgression}.gd`, `systems/JobSystem.gd`, `project.godot`,
`content/jobs.json`, W9+ 제품 노드/새 Story 본문,
`docs/CHOICE_CONSEQUENCE_SYSTEM.md`, `tools/audit.sh`, `tools/audit_scope.json`.
예외적으로 기존 W9 bundle/node의 exact prerequisite·non-Story modifier reader
field는 W1~8 producer의 첫 named consumer 경계로만 수정할 수 있다. 저장 스키마·
새 인물 장면·밴드 밖 수치가 필요하면 조용히 범위를 넓히지 않고 제안한다.

## L1·L2·L3 증거

### L1 기계

- causal checker self-test/current, baseline exact 48. 예상 breakdown은
  `ROW24 + DEAD8 + ORPHAN7 + AUTO4 + SHADOW2 + CAP1 + DISPLAY1 + FANIN1 = 48`,
  `LAYER0`, `UNSCHEDULED0`, blocked 3 불변이다. 다른 debt ID 삭제/이름 변경으로
  수치를 맞추지 않고 ordinary derivation에서 exact 12개만 사라져야 한다.
- 기존 등록 회귀 안의 `Order101W1To8Check` 절: 실제 MainGame 입력으로
  back/cancel 무변이, Send 단일
  owner, 품질 0~3+expiry causal A/B, 완료/만료 next surface, W1/W5 consequence,
  두 사람 동시 후보와 JSON order reversal, KO/EN·keyboard/pad W1~8.
- 기존 등록 회귀 안의 `Order101PersistenceCheck` 절: 아홉 save phase×
  fresh/legacy, double reload, pre-result restart와 post-result restore의 구분,
  late-failure rollback, post-result durable, selected person identity 보존.
- Story application write, month-summary-only reader, completed/expired identical
  signature, offer-only mock interview, `runtime_first_eligible`, free build flag,
  `consumes_slot=true`, wrong receipt sibling을 각각 mutation negative로 거부한다.
- `demo_core_loop_v2_audit.py`, Cycle/FirstEntry/Balance, input QA, context manifest,
  EN coverage, 전체 audit와 `git diff --check`. `--require-complete-chapter-one`은
  남은 W9~48/gap/debt 때문에 계속 실패해야 하며 Chapter 1 완료를 주장하지 않는다.

### L2 자가 검토

- 여덟 행 before/after와 exact 12 debt 각각을
  `producer → reader → 다음 플레이 동사 → source pointer → save replay`로
  한 행씩 기록한다. 20단위 전수 깊이 3문을 쓰고 무작위 표본으로 줄이지 않는다.
- player-facing 전수는 W1 안내/Send/면접, M1 네 terminal, M2 네 terminal,
  W5 Mirae 결과, two-candidate people chooser, W8 SNS 후속이다. KO/EN과
  키보드/패드의 표시·포커스·취소·확정을 대조한다.

### L3 사람

다음 다섯 표면을 한 사람 판정 모집단으로 준비하고, 사용자가 그중 임의 3개를
골라 GO를 판정한다.

1. 자기소개서 품질/만료가 M2 지원의 실제 조건을 바꾸는 경로
2. 아버지 첫 통화 완료→후속, 만료→다른 fail-forward
3. Hyunsu와 Cafe가 모두 가능한 M2에서 직접 고르고 reload해도 같은 선택
4. W1 지원→면접→W5 결과와 M2 Seorin 지원→W9 예약
5. 배달·회복 action receipt가 바꾸는 다음달 표면과 W8 SNS 후속

자동 초록은 재미·사람 GO가 아니다. 고른 3개 중 하나라도 불합격이면 20단위
배치 전체를 반려한다.

## 다음 오더 경계

ORDER-101 완료 시 W1~8 실측 원장·save matrix·사람 판정을 ORDER-102의 입력으로
넘긴다. W9~16 재고조사·지원·관계 선택, W25~48 신설, W48 종료는 미리 만들지
않는다.
