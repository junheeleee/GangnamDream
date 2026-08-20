# Active Queue Spec: ORDER-115

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-115 [P0·구조] 마지막 해 R1a 비활성 계약 커널을 만든다

**착수 (2026-08-20):** ORDER-114의 career·startup exact reference 계약을 다시 읽은 결과,
live 저장·라우팅보다 먼저 닫아야 할 계약 P1 여섯 건이 확인됐다. 이번 배치는 그 계약을
교정하고 M49~M55만 순수하게 재생하는 비활성 커널을 만든다. `reference_only`,
`reachability_claim:false`, `runtime_owner:null`, production consumer 0은 유지한다.

**사용자 지시 (2026-08-20):** “진행해 먼저 브리핑하고 깃 상태도 체크하고.” 메인
worktree의 기존 staged·unstaged·untracked 변경은 사용자 소유로 보존하고, 깨끗한 전용
worktree에서 선언 커밋 뒤 작업한다.

## 깊이 3문

1. 현재 manifest는 startup M52의 terminal 선택에도 h1을 공통 생산하고, 실재하지 않는
   career boss source와 M53 fallback owner를 적는다. M48 actor/margin, startup cofounder,
   M52→M54 reviewer custody도 아직 제품 producer가 없다.
2. 이 상태에서 GameState·SaveManager·StoryMode에 ledger를 연결하면 거짓 ingress를 오래
   사는 저장 계약으로 굳힌다. 먼저 입력과 선택을 파일·GameState 없이 검증하는 pure
   kernel로 writer-before-reader, actor provenance, margin, terminal을 증명해야 한다.
3. 이번 배치는 제품 노출이 아니다. 커널은 autoload·dispatcher·queue sink가 아니며,
   돈·직업·flags·ending·event effects를 쓰지 않는다. durable save adapter, M48/founding
   producer, M53 실제 소유자, M49 UI/dispatcher는 후속 R1b가 소유한다.

## 판정 가능한 20단위

| # | 단위 | 완료 판정 |
|---:|---|---|
| 1 | 보호 baseline | `b73d374`의 보호 35파일·86 objects, `content/jobs.json`, `project.godot`, product consumer 0을 고정한다. |
| 2 | R1a lifecycle | `dormant_contract_kernel`, activation-after false, reference-only/non-live와 QA injection consumer 1을 기계가 읽는다. |
| 3 | career actor source | 호환 `current_job.id`+`flags.has_job` snapshot 뒤 literal `boss`를 bind하고 bound job 변경 시 무효화한다. |
| 4 | M48 ingress | month/root/choice/actor/trust axis/expiry=M49를 가진 future typed receipt를 요구한다. |
| 5 | startup origin | -300만원·2000bp와 typed cofounder receipt를 분리하고, producer spec은 `implemented_in_product:false`다. |
| 6 | legacy 격리 | durable staged mode가 없는 legacy save·기존 acquisition 소비/거절은 추론하지 않는다. |
| 7 | route lock | typed partner-none ingress와 M49 explicit route lock만 허용하고 dual eligibility silent priority를 거부한다. |
| 8 | 배우 역할 | document role handle과 scene actor를 분리하고 세 역할군의 source·distinctness·invalidation을 검증한다. |
| 9 | 문서 소유 | version/hash와 holder/custody/reader를 분리해 문서 존재를 전달로 합치지 않는다. |
| 10 | M49 여력 | incoming trust와 cash+trust 두 선택, route lock, C0 delivery receipt를 정확히 재생한다. |
| 11 | M50→M51 여력 | M50 trust margin 한 번 생성, M51 두 trust 선택에서 한 번 소비를 검증한다. |
| 12 | M52 문서 | cash margin, actual boss/acquirer actor 확인, C1/h1 생성·custody를 기록하고 startup C4는 no-delivery terminal로 닫는다. |
| 13 | M53 handoff | 실제 owner가 없는 동안 external blocker에서 정지하고 Jaehyuk·PDF·margin expiry를 발명하지 않는다. |
| 14 | M54 custody | reviewer가 C1/h1을 받은 future receipt 없이는 읽지 못하며, trust margin만 생산한다. |
| 15 | M55 선택 | 두 trust 선택, opening→decision, reference continuation과 terminal artifact를 정확히 분리한다. |
| 16 | R1a root 표 | M49~M55 career·startup 18 roots·50 choices의 month/order/partition을 고정한다. |
| 17 | 불변 history | 입력과 history를 immutable하게 복제하고 derived state를 history에서 다시 계산한다. |
| 18 | 원자 선택 | common+choice writes를 한 번에 반영하며 변조·부분쓰기·중복 callback을 거부한다. |
| 19 | 비활성 kernel | generic API에 manifest/route/root/path literal 0, file I/O·GameState·SaveManager·dispatch·state effect 0이다. |
| 20 | 표적 검사 | 두 route segment와 음성 변이, audit lane, 보호 drift, `git diff --check`가 모두 통과한다. |

## exact 계약 교정

- career proposer source는 존재하지 않는 `canonical_boss_role`이 아니다. 호환 직업 ID와
  `flags.has_job`을 확인한 entry snapshot에서 literal actor `boss`를 bind하고
  `bound_job_id`를 저장한다. 직업 ID가 바뀌거나 퇴사하면 route는 invalid다.
- M49 cover root의 proposer/counterparty는 문서 발행 role handle이지 동석 배우 receipt가
  아니다. career boss와 startup acquirer의 실제 actor binding은 M52 live proposer 장면에서
  같은 role handle임을 대조해 확정한다. root의 `required_route_roles`와
  `scene_actor_roles`를 분리한다.
- M48 ingress는 `month=48`, exact producer root/choice, exact actor, `axis=trust`,
  `expires_after_month=49`를 모두 가진 future receipt다. 현재 producer가 없으므로 blocker다.
- startup origin의 `startup_founded`·-3,000,000원은 공동창업자 actor나 2000bp typed receipt를
  대신하지 않는다. producer spec은 exact founding event/choice와
  `implemented_in_product:false`를 기록한다. 새 producer 전에는 entry를 fail-closed하고
  legacy save에서 추정하지 않는다.
- partner none도 cast·flags에서 추정하지 않는다. future typed relationship decision receipt를
  entry requirement와 unresolved blocker로 기록한다.
- document version/hash와 custody를 별도 receipt로 둔다. M52 C1/h1은 counterparty가
  보유한 draft일 수 있지만 Minseo가 받았다는 뜻은 아니다. M54는 exact reviewer handoff가
  없으면 external blocker에서 정지한다.
- custody holder는 route별로 고정한다. career C1은 M52에서 player가 보유한 뒤 future
  handoff로 Minseo에게 가고, startup h1은 M52 choice 0~2에서 acquirer가 보유한 뒤 future
  handoff로 Minseo에게 간다. startup C4는 h1과 custody가 모두 0이다.
- common write와 choice write의 합성 규칙을 manifest가 소유한다. startup M52 h1 write는
  common에서 제거하고 choice 0~2 continuation에만 각각 적용한다. choice 3은
  `discussion_ended_no_draft_received` terminal이며 downstream h1/custody를 생산하지 않는다.
- M53 `generic_month_loop`는 현재 실물 owner가 아니다. fallback을 구조화해 story-map
  reference와 `product_owner:null`을 분리하고, 커널은 external handoff 없이는 M54로
  진행하지 않는다. guarantee outcome이나 cash-margin expiry를 대신 생성하지 않는다.

## kernel 계약

신규 `systems/Year5ReferenceRouteKernel.gd`는 `RefCounted` pure class다. 파일 경로,
GameState, SaveManager, EventManager, MainGame, StoryMode, EndingSystem을 참조하지 않는다.
manifest·route·root literal도 내장하지 않고 caller가 건넨 Dictionary만 다룬다.

최소 API:

- `configure(contract)`
- `initial_state()`
- `begin_route(state, entry_snapshot, m48_receipt, explicit_route_lock)`
- `next_step(state)`
- `commit_choice(state, root_id, choice_index)`
- `normalize_state(raw_history)`
- `snapshot(state)`

모든 결과는 `ok/error_code/error`를 가지며 선택 결과는
`state`, `emitted_receipts`, `next`를 반환한다. `next.kind`는
`root|external_blocker|terminal|awaiting_r2`뿐이고 `dispatch_allowed`는 항상 false다.
같은 exact callback replay는 성공 no-op이고 다른 choice·payload·순서 재적용은 실패한다.
반면 persisted history 안의 중복 row는 normalize에서 손상으로 거부한다.
M53 owner와 M48/founding/reviewer custody가 unresolved인 한 정상 trace는 해당 blocker에서 멈춘다.

## 파일 소유권

**선언·마감**

- `CLAUDE.md`
- `docs/CODEX_QUEUE.md`
- `docs/queue_active/ORDER-115.md`
- `docs/WORK_LOG.md`
- 재생성 `docs/STATUS.md`

**계약·커널·검사**

- `content/meta/year5_reference_routes.json`
- `tools/year5_reference_route_audit.py`
- 신규 `systems/Year5ReferenceRouteKernel.gd`와 `.uid`
- 신규 `tools/Year5ReferenceRouteR1Check.gd`, `.tscn`, `.uid`
- `tools/audit_scope.json`
- `tools/audit.sh`
- `docs/context_manifest.json`
- `docs/CONTEXT_INDEX.md`

그 밖의 GameState·SaveManager·EventManager·MainGame·StoryMode·story map·story rules·events·
endings·번역·UI·밸런스·아트·오디오는 byte-exact다. 다른 파일이 필요해지면 이번 배치에
붙이지 않고 새 오더로 분리한다.

## 검사 계약

- manifest strict duplicate-key JSON, exact schema, R1a lifecycle, actor/document custody,
  M49~M55 18 roots·50 choices, continuation/terminal partition, unresolved blocker를 검사한다.
- audit self-test는 startup M52 C4 h1 누수, 가짜 boss role, M48 incomplete receipt,
  cofounder 추론, reviewer custody 누락, M53 skip/forged guarantee를 각각 거부한다.
- kernel check는 career·startup을 external blocker까지 재생하고 wrong actor/job/expiry,
  duplicate actor, wrong hash/holder, read-before-transfer, margin axis/double-spend,
  terminal→downstream, partial writes, duplicate/tampered history를 거부한다.
- M54~M55 검사는 `synthetic future handoff receipt`라고 명시한 resumed fixture에서만 이어가며,
  이 fixture를 product producer나 reachability로 세지 않는다.
- production source는 manifest path/id, 두 route ID, 대상 root ID의 consumer를 계속 0으로
  유지한다. kernel은 테스트에서만 contract를 주입받고 manifest는 QA injection consumer 1과
  product consumer 0을 구분한다. kernel 파일 자체를 제외한 production source에서 kernel
  path/class reference도 0으로 고정한다.
- 실행: `python3 tools/year5_reference_route_audit.py --self-test`, 전용 headless Godot check,
  context/queue checks, `python3 tools/audit_select.py -- <변경 파일...>`,
  `git diff --check`. full audit·240주·엔딩·RC 검사는 실행하지 않는다.

## 완료·정본 판정

- L1은 manifest/audit와 headless kernel check, L2는 독립 redteam 두 route trace와 음성 변이,
  L3는 후속 live 연결 뒤 실제 선택·저장·복구 체감으로 미룬다.
- 완료 명칭은 오직 **`R1a dormant contract kernel complete`**다. M49~M55 도달·저장·
  플레이 가능, R1 전체 완료, routed/live 승격을 주장하지 않는다.
- 계속 유효한 계약은 manifest와 kernel API가 소유한다. baseline·파일 소유권·20단위·
  검사 명령은 이 오더의 일회성 작업 지시다.
