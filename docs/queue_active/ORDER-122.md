# Active Queue Spec: ORDER-122

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-122 [P0·CI/회귀] ORDER-119 전체 감사 잔여 7플래그를 의미 축소 없이 닫는다

**착수 선언 (2026-08-22):** 구현 기준은 ORDER-121 closure인
`e53689ca58ef3fdc6e6fa9d2c67c7b4ca82975b4`다. ORDER-119의 제품 수리를 넓히지
않고 서로 독립적인 감사 잔여만 각 소유자에서 고친다. baseline/부채 상향, 검사
축소, W96의 W97 허위 보고, author-only의 shipping 활성화는 금지한다.

## 역사적 8플래그와 현재 OPEN 7플래그

- **역사 측정:** `f7b9f6e53be1e06201b52360935593d372cb1ebb`에서 끝난 전체
  `tools/audit.sh`의 실패 플래그는
  `NARRATIVE_CONTINUITY_EXIT`, `FULL_RUN_PACING_EXIT`,
  `DEMO_PROSE_STYLE_EXIT`, `EXPOSED_STATE_EXIT`, `CORE_LOOP_V2_EXIT`,
  `SURFACE_COHERENCE_EXIT`, `STATUS_DOC_EXIT`,
  `SCENE_DIRECTION_RUNTIME_EXIT`의 정확히 8개였다.
- **현재 시작점:** `e53689c`에서 ORDER-121 closure가 `STATUS_DOC_EXIT`를 이미
  해소했다. 따라서 이 오더가 구현으로 닫을 현재 OPEN 실패는 STATUS를 뺀 정확히
  7개다. leverage roundtrip은 위 전체 감사에서 재현되지 않았으므로 확인된 잔여에
  넣지 않는다.
- **STATUS 재소유 이유:** 이 선언과 이후 구현·queue/archive·WORK_LOG 변경은 생성
  대시보드를 다시 낡게 만든다. `docs/STATUS.md`는 시작 결함이나 여덟 번째 제품
  수리가 아니라, 모든 쓰기가 끝난 뒤 마지막으로 재생성할 closure 파일이다.
  선언 직후 생기는 freshness 실패를 역사적 실패의 재발로 세지 않는다.
- ORDER-119 기준 `1220b294e69a11aa34c680790f02f9ccbec0e8c3`과 대조하면
  아래 7개는 ORDER-119 유발 회귀가 아니다. ORDER-121도 이를 green으로
  주장하지 않았다.

## 깊이 3문

1. 왜 기대값만 바꾸지 않는가? 8플래그는 소유자가 다르므로 관측 사실을 보존하고
   각 소유자만 고친다.
2. 왜 사건을 거의 안 고치는가? 실모순은 시계 세 곳과 임대료 한 곳뿐이다.
   First Bill·W4 거절·두 author-only follow-up은 현재 데이터가 맞다.
3. 어떻게 green 세탁을 막는가? 플래그별 음성 변이와 byte 불변을 증명하고,
   현재 7개와 closure STATUS가 같은 후보에서 0일 때 끝낸 뒤 더 쓰지 않는다.

## 역사 플래그별 정확 수리와 음성 검사

### 1. `SURFACE_COHERENCE_EXIT`

- 현재 실측은 StyleBox constructor `262>260`, direct theme override
  `2202>2116`, private color `711>681`이며 단일 초과 소유자는
  `tools/StoryMapM1M6Playtest.gd`다.
- StyleBox 2곳은 `UIStyle.panel_style/btn_style`로, direct override 86곳은
  `UIStyle.override_*`로, private color 30곳은 기존 공용 token 파생으로 바꾼다.
- `autoloads/UIStyle.gd`나 baseline을 바꾸지 않는다. 최종 수치는 각각
  `260/2116/681` 이하이고 세 래칫을 모두 통과해야 한다.
- 변환한 한 호출을 임시 복원해 override `2117`이면 실패하고, 복원 뒤 통과해야 한다.

### 2. `NARRATIVE_CONTINUITY_EXIT`

- Chapter 2 A/B에서 고립 단편으로 잘못 센 두 root는 W62
  `arc_34_routine_trap`(484~495자)와 W96 `arc_year2_close`(581~606자)다.
  둘 다 6 panel인 실질 장면이며 목표는 A/B Chapter 2 `isolated=0`이다.
- `tools/narrative_continuity_audit.py`가 description, choice text,
  result_text와 자식 산문의 문자 수 min/max를 보고하게 한다. 기존 micro 조건에
  `max_chars <= 420`을 함께 만족할 때만 isolated micro로 센다. 기존 chapter
  ratchet과 사건은 바꾸지 않는다.
- self-test는 420자가 micro, 421자는 아님을 잠그며 실제 짧은 장면은 계속 잡는다.
  421자를 micro로 세는 변이는 실패해야 한다.

### 3. `FULL_RUN_PACING_EXIT`

- A는 두 시간 경계를 W97에 넘고 B는 `arc_year2_close`를 읽는 W96에서
  119.05분→121.43분으로 넘는다. W96을 W97로 보고하지 않는다.
- `tools/full_run_pacing_audit.py`가 경계를 넘긴 root를 함께 기록한다. 기본 허용
  범위는 계속 W97..W144이며, 정확히 `week=96/root=arc_year2_close`인
  year-close boundary만 정직하게 허용하고 출력한다. 전역 하한을 96으로 낮추지 않는다.
- self-test는 W95, W96의 다른 root, W145를 모두 실패시키고 정확한 W96
  `arc_year2_close`만 통과시킨다. 현재 A/B는 각각 W97/W96과 root를 출력해야 한다.

### 4. `DEMO_PROSE_STYLE_EXIT`

- `content/events/arc_events.json`의
  `arc_temptation_01.choices[0].result_text`에서 `네 시 이십 분`을 `4시 20분`으로,
  `arc_temptation_clean.description`에서 `새벽 네 시 이십 분`을
  `새벽 4시 20분`으로 바꾼다. 기존 `04:20` 인용은 보존한다.
- `content/meta/demo_localization_scope.json`의 minute permission에는 이 세
  도달 occurrence만 source/literal/canonical `04:20`, exact count와 사유로
  등록한다. prose의 written clock은 0이어야 한다.
- 기존 self-test가 permission 누락/count/source/stale 변이를 거부하고, 복원 뒤
  current audit가 통과해야 한다.

### 5. `EXPOSED_STATE_EXIT`

- `tools/exposed_state_consistency_audit.py --write-contract`로
  `content/meta/exposed_event_state_contracts.json`을 현재 사건에서 다시 만든다.
  추가는 `arc_jaehyuk_04a_ghost: father_life`와
  `hyunsu_reunion_later: employment`의 정확히 두 domain이다.
- stale 제거는 `arc_34_doors_open`의 employment/relationship,
  `arc_father_04_visit`의 employment, `arc_final_countdown`의 father_life,
  `arc_year1_close`의 employment, `arc_year2_close`의 father_life다.
- 두 번째 생성은 diff 0이어야 한다. stale 복원 또는 새 domain 누락 변이는
  실패하며 사건·story rule·event director는 바꾸지 않는다.

### 6. `CORE_LOOP_V2_EXIT`

- First Bill은 현재 원고가 정본이다. KO
  `각 줄에는 끝내야 할 동작과 그 일을 놓아야 하는 시각이 적혀 있었다.`와 EN
  `Each line names an action he can complete and the time when he must let it go.`를
  `tools/demo_core_loop_v2_audit.py`가 잠그고, 현재 KO/EN
  `content/events/core_loop_v2_events.json`은 byte-exact로 둔다.
- 현재 W4 거절도 정본이다. KO 선택
  `번호를 차단한다 — 월세와 내일의 노동을 감수한다`와 결과 prefix
  `차단 버튼을 누르자 대화창이 사라졌다.`, EN 선택
  `Block the number — accept the rent bill and tomorrow's labor`와 결과 prefix
  `The chat vanished when {name} tapped Block.`를 잠근다.
- 실제 모순 하나만 KO/EN `arc_temptation_01.description`에서 고친다.
  2,000,000원에서 650,000원씩 석 달을 빼면 50,000원이 남고 연체 공과금에는
  모자란다는 같은 계산을 두 언어가 명시한다.
- self-test는 First Bill 옛 문장, W4 옛/완화 문구, 틀린 잔액/충분한 공과금
  변이를 실패시킨다. effects·조건·선택 순서·V2 schedule은 byte-exact다.

### 7. `SCENE_DIRECTION_RUNTIME_EXIT`

- 정적 catalog와 manifest의 shipping 집합은 `events=1603/edges=177`로 맞다.
  런타임 checker가 packaged 1,758편 전부를 순회해 author-only follow-up까지
  shipping edge로 오인한 것이 실패 원인이다.
- 미분류 두 edge는
  `arc_y5_three_in_room→arc_y5_three_in_room_decision`(meeting→meeting)과
  `arc_final_countdown_not_executed→arc_final_week`
  (gangnam_night→same)이며 둘 다 author-only root에서 나온다.
- checker는 manifest `event_intents`의 unique/loaded shipping ID 1,603편과
  그 edge만 검사한다. unknown/mod ID와 shipping 미분류는 fail-closed이며
  lifecycle/catalog/manifest/사건/follow-up은 불변이다.
- 음성 검사는 shipping manifest에 unknown ID를 넣거나 shipping edge 하나의
  분류를 지우면 실패하고, 위 두 author-only edge만 packaged에 존재할 때는
  `SCENE_DIRECTION_CHECK_OK events=1603`으로 통과해야 한다.

### 8. 역사적 `STATUS_DOC_EXIT`

- `e53689c` 시작점에서는 이미 해소되어 현재 7개 OPEN에 포함하지 않는다.
  ORDER-122의 모든 구현과 queue/archive/WORK_LOG/causal ledger가 확정된 뒤
  `docs/STATUS.md`를 정확히 한 번 마지막으로 생성하고 freshness check를 통과한다.
- 생성 뒤 queue marker 변이는 status check가 실패하고, 복원·재생성 뒤 통과해야 한다.

## audit selection 복구

`tools/audit_scope.json`에서 다음 네 누락만 추가한다.

- `tools/StoryMapM1M6Playtest.gd` 변경은 `surface_coherence_audit.py`를 선택한다.
- `tools/narrative_continuity_audit.py` 변경은 자기 direct/self-test를 선택한다.
- `tools/full_run_pacing_audit.py` 변경은 자기 direct/self-test를 선택한다.
- `tools/SceneDirectionCheck.gd`/scene 변경은 `SceneDirectionCheck.tscn`을 선택한다.

각 path의 `audit_select` 결과는 해당 검사를 포함하고 무관 path는 선택하지 않는다.

## 배치 — 정확히 25단위

1. 이 active spec, queue index, `CLAUDE.md`의 다음 작업을 같은 선언으로 고정한다.
2. StoryMap M1M6의 constructor/direct override를 shared helper로 합친다.
3. StoryMap M1M6의 private palette를 기존 공용 token 파생으로 맞추고 시각을 재독한다.
4. continuity에 leaf 문자 min/max와 420자 micro 경계를 추가한다.
5. continuity self-test와 현재 A/B Chapter 2 isolated 0을 각각 판정한다.
6. pacing에 crossing root와 W96 year-close 단일 예외를 추가한다.
7. pacing의 W95/다른 W96/W145 음성 fixture와 현재 A/B를 판정한다.
8. 도달 KO 시계 산문 세 occurrence를 숫자 표기로 고친다.
9. 세 `04:20` minute permission의 exact source/count/stale 거부를 맞춘다.
10. KO/EN 임대료 산문을 2,000,000−650,000×3=50,000으로 맞춘다.
11. CoreLoop V2 checker를 현재 First Bill과 W4 거절 정본에 맞춘다.
12. First Bill/W4/잔액의 독립 음성 변이를 모두 통과시킨다.
13. exposed-state contract의 두 domain 추가와 다섯 root stale 제거를 생성한다.
14. exposed-state 누락/stale 음성과 두 번째 생성 diff 0을 판정한다.
15. direction runtime을 manifest shipping 1,603편 순회로 고친다.
16. direction unknown/shipping-missing 거부와 author-only 두 edge 제외를 판정한다.
17. `audit_scope`의 정확한 네 소유 path 매핑과 음성 선택을 고정한다.
18. 계속 유효한 검사 경계를 `docs/QA_CHECKLIST.md` 한 곳에 승격한다.
19. 사건 byte 변경 뒤 release inventory와 content-rating 보고서를 재생성한다.
20. baseline/debt/project/effects/flags/routes/schedule/balance byte 불변을 독립 증명한다.
21. 후보 결과와 역사 8/current 7 구분을 `docs/WORK_LOG.md`에 기록한다.
22. Chapter 1 causal ledger/checker의 source hash와 semantic digest만 현재 후보에 재고정한다.
23. `CLAUDE.md`와 queue를 ORDER-122 완료/ORDER-119 재개 상태로 맞춘다.
24. active spec을 archive와 2026-08 monthly archive로 옮기고 규범 승격을 판정한다.
25. `docs/STATUS.md`를 마지막 생성한 뒤 전체 감사의 플래그 0을 판정하고 더 쓰지 않는다.

## 파일 소유권 — 정확히 22개

1. `tools/StoryMapM1M6Playtest.gd`
2. `tools/narrative_continuity_audit.py`
3. `tools/full_run_pacing_audit.py`
4. `tools/SceneDirectionCheck.gd`
5. `tools/audit_scope.json`
6. `tools/demo_core_loop_v2_audit.py`
7. `content/events/arc_events.json`
8. `content/events_en/arc_events.json`
9. `content/meta/demo_localization_scope.json`
10. `content/meta/exposed_event_state_contracts.json`
11. `content/meta/release_content_inventory.json`
12. `docs/CONTENT_RATING_INVENTORY.md`
13. `content/meta/chapter1_core_loop_v2_causal_ledger.json`
14. `tools/chapter1_core_loop_v2_causal_ledger_check.py`
15. `docs/QA_CHECKLIST.md`
16. `CLAUDE.md`
17. `docs/CODEX_QUEUE.md`
18. `docs/queue_active/ORDER-122.md`
19. `docs/queue_archive/ORDER-122.md`
20. `docs/queue_archive/CODEX_QUEUE_2026-08.md`
21. `docs/WORK_LOG.md`
22. `docs/STATUS.md`

선언은 `CLAUDE.md`, queue index, active spec 세 파일만 바꾼다. 새 결함은
22개 밖 파일을 열지 않고 별도 오더로 넘긴다.

## exact 불변과 허용 prose leaf

다음은 기준 `e53689c`와 byte-exact다.

- `tools/surface_coherence_baseline.json`, `tools/debt_baseline.json`,
  `tools/chapter1_core_loop_v2_causal_debt_baseline.json`
- `project.godot`, `autoloads/UIStyle.gd`
- `content/meta/event_director.json`, `content/meta/story_rules.json`,
  `content/meta/demo_core_loop_v2.json`, `content/meta/event_lifecycle.json`
- `assets/scene_direction_manifest.json`
- `content/events/core_loop_v2_events.json`,
  `content/events_en/core_loop_v2_events.json`
- `docs/BALANCE.md`
- 모든 effects, cast_effects, flags, routes, followups/deferred_followups,
  choice order, conditions, weight, hidden, timer, event ID, schedule와 balance 값

사건에서 허용한 prose leaf는 정확히 네 개뿐이다.

1. KO `arc_temptation_01.description`
2. KO `arc_temptation_01.choices[0].result_text`
3. KO `arc_temptation_clean.description`
4. EN `arc_temptation_01.description`

release 수량은 `packaged=1758/shipping=1603/author-only=155`를 유지한다.
release inventory와 content-rating 보고서는 source hash만 현재 바이트로 다시
만든다. Chapter 1 causal ledger/checker도 source hash와 semantic digest만
재고정하며 debt·coverage 완료 수치·효과 의미를 바꾸지 않는다.

## 완료·판정

- **L1 direct/self-test:** surface, continuity, pacing, prose, exposed-state
  2회 생성, CoreLoop V2, SceneDirection `1603/177`, release/content-rating,
  causal ledger와 `audit_select --verify`를 모두 통과한다.
- **L1 closure:** strict JSON, context manifest, queue consistency,
  dashboard freshness, `git diff --check`를 통과한다. 전체 `tools/audit.sh`의
  현재 7개와 closure `STATUS_DOC_EXIT`를 포함한 모든 failure flag가 같은 최종
  후보에서 0이어야 한다.
- **L2 불변:** 네 prose leaf와 생성 contract/report/hash 외 gameplay byte와
  exact 불변을 기준 commit과 대조하고 화면 계층·대비·focus/hover를 재독한다.
- **L3:** 이 CI 복구가 사용자 사람 게이트를 대신 닫지 않는다. 새 서사·선택·효과를
  만들지 않으며, 수정된 네 prose leaf는 ORDER-119의 기존 KO/EN 24주·KO 240주
  후보 판정에 포함된다. 사용자 최종 GO는 계속 OPEN이다.

## 정본·일회성 판정

- shipping manifest를 런타임 방향 검사의 모집단으로 쓰고 unknown/shipping
  미분류를 fail-closed로 거부하는 규칙, 420자 micro 경계, W96 year-close의
  정확한 보고, clock permission의 도달 occurrence 계약은 완료 시
  `docs/QA_CHECKLIST.md`의 기존 해당 절에만 승격 후보로 판정한다.
- 정확한 두 continuity root, 두 direction edge, 세 시계 occurrence, 두 exposed
  domain, f7/e536 commit과 수치, 25단위와 22파일은 이 수리의 일회성 증거다.
