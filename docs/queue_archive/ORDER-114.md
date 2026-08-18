# Archived Queue Spec: ORDER-114

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [x] ORDER-114 [P0·구조] 마지막 해 두 reference 세로줄의 exact routing 계약을 기계 판독형으로 고정한다

**완료 (2026-08-18):** career·startup 두 경로의 32 roots·86 choices를
`activation: reference_only`, `reachability_claim: false`, `runtime_owner: null`인
기계 판독 계약으로 고정했다. 배우·문서 계보·월별 선택·20개 terminal 손실·M59
원자 거래·M60/final-week handoff를 기록했고 현재 runtime consumer는 0이다.
보호 35파일과 86 objects, root 32개 의미 digest, 살아남은 continuation 분기만 읽는
producer graph를 감사한다. 직접 감사와 84개 음성 변이, story-map 표적 차선 6개,
독립 재현 18건이 모두 통과해 P0/P1 0이다. runtime·save·story map·rules·events·
endings는 바꾸지 않았으며 live 승격은 후속 R1·R2가 소유한다.

**정본 승격:** 계속 유효한 두 reference 계약은
`content/meta/year5_reference_routes.json`, 그 거부 조건은
`tools/year5_reference_route_audit.py`, 검사 라우팅은 `tools/audit_scope.json`과
`tools/audit.sh`, 문서 분류는 `docs/context_manifest.json`과
`docs/CONTEXT_INDEX.md`가 소유한다. 이 사양의 baseline commit·파일 소유권·20단위·
검사 명령은 일회성 작업 지시다.

**사용자 지시 (2026-08-18):** “이제 이어서 작업해.” career와 startup 원고를 바로
노출하지 않는다. 현재 제품에는 M49~M60 production dispatcher·typed durable ledger·
원자 거래·성공 엔딩 유예가 없으므로, 이번 배치는 후속 live 구현이 따라야 할 두 경로의
배우·문서·선택·월간 여력·영수증을 먼저 기계가 거부 가능한 계약으로 만든다.

## 깊이 3문

1. ORDER-112·113의 32 roots는 모두 `weight:0`, `hidden:true`, `min_turn:9999`,
   `author_only`이고 상태 변경과 follow-up이 없다. 이것은 안전한 reference 원고이지,
   story map이나 현재 런타임이 재생하는 제품 경로가 아니다.
2. M59 startup에서 32억원이나 `startup_exit`를 현재 방식으로 적용하면 기존 성공 엔딩이
   M60·final-week보다 먼저 발화한다. career도 거래·직업·배지 결과를 한 번만 적용할
   receipt가 없다. 따라서 prose를 `mapped`나 live라고 부르기 전에 exact 선택과 future
   transaction/ending handoff를 데이터로 고정해야 한다.
3. 이번에는 runtime·save·story map·rules·events·endings를 바꾸지 않는다. career 한 줄과
   startup 한 줄만 `activation: reference_only`, `reachability_claim: false`,
   `runtime_owner: null`로 선언하고, M53·M56과 live infra를 명시적 blocker로 남긴다.

## 판정 가능한 20단위

| # | 단위 | 완료 판정 |
|---:|---|---|
| 1 | manifest 표면 | schema/version·choice index·reference-only 3필드가 exact다. |
| 2 | 경로 범위 | career·startup 두 route만 있고 property·ORDER-111 alternate는 없다. |
| 3 | career 진입 | 호환 직업·M48 Hyunsu provenance·partner none·M49 route choice를 모두 요구한다. |
| 4 | startup 진입 | founded 20%와 no exit/partial/solo/joined 상태, cofounder provenance를 요구한다. |
| 5 | career 배우 | boss/minseo/hyunsu 역할·source·distinctness·invalidation이 고정된다. |
| 6 | startup 배우 | acquirer_lead/minseo/startup_cofounder 역할·source·distinctness가 고정된다. |
| 7 | career 문서 | C0→C1→C2→C3와 숫자·NOT USED·self-only·badge receipt가 이어진다. |
| 8 | startup 문서 | SA-20 A6E8→91B4→D772→5C20과 160억·20%·32억이 이어진다. |
| 9 | 월간 여력 | M49~M60 incoming/outgoing margin·selected commitments·fallback owner가 적힌다. |
| 10 | career 장면표 | 16 roots·43 choices와 월·순서가 실물과 일치한다. |
| 11 | startup 장면표 | 16 roots·43 choices와 월·순서가 실물과 일치한다. |
| 12 | continuation | 두 경로의 계속/끝점 choice index가 전부 disjoint·complete다. |
| 13 | scene receipts | root별 requirement·writes·actor/document output을 선택별로 합치지 않는다. |
| 14 | career 거래 계획 | +30만원·job/badge 변화를 한 transaction ID로 한 번만 적용할 계획이다. |
| 15 | startup 거래 계획 | 32억원·20%·startup exit를 한 transaction ID로 한 번만 적용할 계획이다. |
| 16 | legacy 상호배제 | 기존 즉시 startup 인수·8천만원 경로·구세이브를 staged와 섞지 않는다. |
| 17 | 엔딩 유예 계획 | 실패 우선, 성공만 final-week 뒤까지 보류하는 future handoff가 명시된다. |
| 18 | blocker | M53 fallback/margin 만료와 M56 실제 margin producer가 unresolved다. |
| 19 | 음성 검사 | actor·choice·margin·transaction·runtime-consumer 변이를 self-test가 거부한다. |
| 20 | 보호 범위 | 기존 events/map/rules/runtime/endings hash와 runtime 소비자 0을 검사한다. |

## lifecycle와 비도달성

- manifest의 유일한 현재 lifecycle은 `reference_only`다. `mapped`, `routed`, `live`,
  `runnable` 또는 동등한 도달성 표시는 금지한다.
- `reachability_claim`은 `false`, `runtime_owner`는 JSON `null`이다. production 코드가
  manifest나 32 root ID를 소비하면 이번 배치 검사가 실패해야 한다.
- 사건 원고는 계속 author-only다. weight·hidden·min_turn·choices·KO/EN·effects·flags·
  follow_up을 바꾸지 않는다.
- story map lifecycle, story rules, MainGame, StoryMode, EventManager, GameState,
  SaveManager, EndingSystem, endings는 이번 배치에서 byte-exact다.
- 후속 live 배치는 최소 두 조각이다. R1은 M49~M55 ledger/actor/selector를 만들되 제품
  활성화를 끄고, R2가 M57~M60 terminal·원자 거래·엔딩 hold까지 닫은 뒤에만 32 roots를
  typed direct router로 노출한다.

## exact 배우와 진입

### career

- route id `career_reference_v1`, 경제 경로 `career`, partner none이다.
- proposer=counterparty=`boss`, reviewer=`minseo`, protected=affected=primary witness=
  `hyunsu`다. 세 역할군은 서로 distinct다. `team_lead`는 표면 호칭일 뿐 actor ID가 아니다.
- boss는 호환 가능한 현재 직업의 canonical role에서, Minseo는 literal actor에서,
  Hyunsu는 M48의 실제 remaining-person receipt에서 온다. 퇴사·비호환 직업·M48 actor 불일치면
  진입을 거부한다.
- career와 startup이 동시에 eligible이면 silent priority를 쓰지 않고 M49에서 실제 선택한
  route value가 lock receipt를 만든다.

### startup

- route id `startup_acquisition_reference_v1`, 경제 경로 `startup`, partner none이다.
- proposer=counterparty=`acquirer_lead`, reviewer=`minseo`, protected=affected=primary witness=
  `startup_cofounder`다. 두 route-scoped actor와 Minseo는 서로 distinct다.
- origin은 `startup_founded`의 300만원·20% receipt이며 `startup_exit`,
  `startup_partial_exit`, `startup_going_solo`, `joined_startup`을 배제한다.
- `acquirer_lead`는 C0 scene receipt, 공동창업자는 founding receipt에 의해 처음 고정된다.
  연애 enum이나 임의 실명으로 추측하지 않는다.
- 기존 `startup_acquisition_offer`를 이미 소비했거나 거절한 legacy save는 staged로 추정
  이관하지 않는다. 새 durable mode가 없는 구세이브는 fail-closed legacy다.

## exact 월간 여력·fallback

- M49는 route cash + reviewer trust의 두 행동이므로 M48의 실제 동일축 margin이 필요하다.
- M50은 boundary trust 하나를 완료해 다음 달 trust margin을 만든다.
- M51은 Minseo와 exact protected actor의 trust 두 행동으로 그 margin을 소비한다.
- M52는 proposer cash 하나를 완료해 cash margin을 만든다.
- M53은 route scene 0, `fallback_owner=generic_month_loop`, route commitment 0이다. Jaehyuk
  guarantee를 refused/blocked로 위조하지 않고 이 달의 margin 만료 소유자는 unresolved다.
- M54는 reviewer trust 하나를 완료해 trust margin을 만든다.
- M55는 disclose + reviewer question trust 두 행동으로 그 margin을 소비한다.
- M56은 가족 경로 pass-through다. 경제 배우·문서를 아버지 장면에 합치지 않으며,
  M57 두 행동을 허용할 실제 same-axis margin producer는 unresolved다.
- M57은 filing + filed-copy delivery, M58은 primary witness 하나, M59는 execute + result
  delivery, M60은 sign-own-answer 하나다. countdown/final-week는 새 월 행동이 아니라
  route aftermath다.
- M53·M56 blocker가 해소되고 durable receipt가 생기기 전 manifest는 runnable이 될 수 없다.

## exact 선택 연쇄

- choice index는 0-base다. root의 모든 choice는 continuation 또는 terminal/complete 중 정확히
  하나에 속한다.
- career: M55 decision C1(index 0) → M57 self-only C2(index 1) → M58 listen C1(index 0)
  → M59 execute C1(index 0)만 다음 단계로 간다. 다른 선택은 route terminal이다.
- startup: M50·M52 C1~C3(index 0~2)는 continue, C4(index 3)는 terminal이다.
  이후 M55 C1(index 0) → M57 C1(index 0) → M58 C1(index 0) → M59 C1(index 0)만
  다음 단계로 간다.
- 두 route의 M60 countdown choices 3개는 모두 exact final-week로 continue하고,
  final-week choices 3개는 모두 route complete다.
- terminal도 그 선택이 만든 현재 손실과 receipt를 저장한다. 다른 선택의 문서·배우·돈을
  붙이거나 일반 ending을 즉시 호출하지 않는다.

## 문서·거래·엔딩 future contract

- career document lineage와 startup SA-20 lineage는 manifest가 field와 hash를 소유한다.
  같은 버전 사본만 same hash이며 root별 writes가 reader보다 앞서야 한다.
- future career M59 transaction은 정확한 event+choice+route transaction ID로 +300,000원,
  직업·배지·옛 배지 반환 receipt를 한 번만 적용한다. 다른 choices는 해당 효과 0이다.
- future startup M59 transaction은 SA-20 h3, 3,200,000,000원 1회, 2,000bp→0bp,
  execution/delivery receipt, `startup_exit`, `finale_pending`을 원자 저장한다. replay와
  save/load 재호출은 성공적 no-op다.
- 실패 ending은 그대로 즉시 판정한다. staged pending은 모든 성공 ending만 유예한다.
  final-week completion이 `finale_ready`를 쓴 뒤 MainGame listener가 연결된 상태에서 canonical
  `check_game_over()`를 한 번 호출한다. 기존 legacy startup exit는 ledger가 없으면 즉시 끝난다.
- 위 문장은 후속 구현 계약이지 현재 동작 주장이나 수치 적용이 아니다.

## manifest·검사 파일 소유권

**선언·마감**

- `CLAUDE.md`
- `docs/CODEX_QUEUE.md`
- `docs/queue_active/ORDER-114.md`
- `docs/WORK_LOG.md`
- 재생성 `docs/STATUS.md`

**machine-readable contract**

- 신규 `content/meta/year5_reference_routes.json`
- 신규 `tools/year5_reference_route_audit.py`
- `tools/audit_scope.json`
- `tools/audit.sh`
- `docs/context_manifest.json`
- `docs/CONTEXT_INDEX.md`

그 밖의 사건·story map·story rules·runtime·save·UI·balance·ending·번역·아트·오디오는
수정하지 않는다. commit/push 없이 공유 바이트를 덮어쓰는 에이전트 작업도 금지한다.

## 검사 계약

- manifest strict duplicate-key JSON, exact schema, root 32/choice 86, KO/EN root·choice parity,
  author-only metadata·state mutation 0을 검사한다.
- route마다 actor source/distinctness, document writer→reader, month order, continuation/terminal
  partition, incoming/outgoing margin, unresolved blocker를 검사한다.
- self-test는 최소 다음 변이를 거부한다: M48 margin 누락/축 불일치, M53 보호 행동 발명,
  M56 producer 허위 완료, terminal 뒤 downstream, actor 누락·중복·invalidation, property tuple,
  legacy startup collision, 32억 transaction 중복, M59 receipt 없는 M60, final-week actor mismatch,
  `reachability_claim:true`, lifecycle mapped/live, runtime consumer 추가.
- baseline `e27ff7e`의 story map·rules·production runtime·legacy startup objects·5 locale endings와
  대상 32 root 이외 기존 objects가 바뀌면 실패한다. 보호 hash는 manifest에 기록한다.
- `python3 tools/year5_reference_route_audit.py --self-test`, context/queue checks,
  `python3 tools/audit_select.py -- <변경 파일...>`, `git diff --check`를 실행한다.
- full audit·240주·Godot는 실행하지 않는다. 이번 배치는 runtime·공통 event schema·ending을
  바꾸지 않는 정적 계약이므로 표적 검사만 사용한다.

## 완료·정본 판정

- L1은 manifest와 self-test, L2는 독립 redteam이 두 exact trace와 음성 변이를 판정한다.
- L3는 원고 품질이 아니라 후속 live 전 제품 선택·저장·엔딩 체감으로 미룬다.
- 계속 유효한 정본은 `content/meta/year5_reference_routes.json`이 소유한다. 이 사양의 파일
  목록·baseline commit·20단위·검사 명령은 일회성 작업 지시다.
- 완료 시 manifest는 여전히 reference-only여야 한다. live 승격은 성공이 아니라 검사 실패다.
