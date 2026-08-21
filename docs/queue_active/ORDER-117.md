# Active Queue Spec: ORDER-117

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-117 [P0·서사] ORDER-107·109의 지목 장면을 고치고 career 15편을 전수 재판정한다

**판정 근거 (2026-08-21):** `판정: Claude(사용자 위임)`. ORDER-107·109는 각
1편 조건부, ORDER-112는 1편 보존·15편 재판정이다. 사용자 최종 GO는 OPEN이다.

**착수 선언 (2026-08-21):** 기준 `8a1436629fa2ca589d76a4cf52d1b465aa81b0b3`.
만지는 파일은 아래 18개뿐이다.

- `content/events/{arc_events,arc_chapter_themes,arc_midgame,arc_new_characters,arc_pre_ending,arc_drama}.json`
- `content/events_en/`의 같은 6파일
- `CLAUDE.md`, `docs/CODEX_QUEUE.md`, `docs/queue_active/ORDER-117.md`,
  `docs/WORK_LOG.md`, `docs/STATUS.md`, `docs/human_gates.json`

`docs/human_gates.json`은 새 후보와 위임 판정을 사용자 최종 GO와 분리해 기록할 때만
수정한다. 위 목록 밖의 사건·story map/rules/spine·reference manifest/audit/kernel·
runtime/save/UI/balance/endings·JA/ZH는 byte-exact다.

## 깊이 3문

1. 기록·전달 형식 자체가 문제가 아니다. 그 장면에서만 가능한 사람의 행동이 없고,
   플레이어가 고르는 것이 대조·색칠·사본 보관 방식으로 끝나는 것이 문제다.
2. `arc_y5_after_goal_hyunsu_career`는 이번 묶음의 정점이므로 KO/EN object를 그대로
   잠근다. 나머지 career 15편은 자동 합격시키지 않고 같은 세 축으로 각각 판정한다.
3. 이 배치는 반려된 R1a 계약을 재기준화하지 않는다. story map·manifest·kernel·
   runtime·save·ending은 ORDER-118의 invalidated 상태와 함께 byte-exact다.

## 배치 — 정확히 18단위

1. `arc_y3_father_after_visit_document` 재작성. 아버지가 실제 통화·음성 등으로 현재
   장면에 있어야 한다. 선택은 대조 방식이 아니라 아버지에게 무엇을 묻거나 밝히고,
   그 때문에 검토 시간·부자 사이 체면·오늘 기한 중 무엇을 잃는지로 갈린다.
2. `arc_y2_money_structure` 재작성. `open_debt`의 실제 counterparty receipt가 있을
   때만 그 사람을 불러오고, 사람 없는 기한·설명·미납 순열을 폐기한다. 실제 상대가
   없는 selector에서는 non-live로 남기며 임의 인물을 만들지 않는다.
3. `arc_y5_after_goal_hyunsu_career` 보존 잠금.
   KO object SHA-256 `67360c31ba51e675682dfbb68613f119998aed4bc5c8a9a3bfbe3ed2c68b33eb`,
   EN object SHA-256 `58b2c860ee783e3562aca4cb1b2fff9a61c42e21da649fb01e8146e7582fd57f`.
4. `arc_y5_contract_cover_career`
5. `arc_y5_contract_reviewer_delivery_minseo_career`
6. `arc_y5_protection_boundary_hyunsu_career`
7. `arc_y5_minseo_goal_cost_career`
8. `arc_y5_final_offer_career_boss`
9. `arc_y5_career_reviewer_receipt_minseo`
10. `arc_y5_three_in_room_career`
11. `arc_y5_three_in_room_decision_career`
12. `arc_y5_name_on_line_career_self`
13. `arc_y5_name_copy_delivered_hyunsu_career` — 필수 재작성
14. `arc_y5_people_verdict_career_hyunsu`
15. `arc_y5_contract_execution_career`
16. `arc_y5_contract_result_delivered_hyunsu_career` — 필수 재작성
17. `arc_final_countdown_career_executed`
18. `arc_y5_final_week_hyunsu_career_outbound`

4~18은 각각 인물 목소리 / 지금 잃는 것 / 다음을 기다리게 하는 여운으로 판정하고,
한 축이라도 약하면 그 단위에서 재작성한다. 두 delivery는 “사본을 가방에 넣고
시각을 저장한다”를 폐기한다. 한 선택 진행 장면이어도 현수만 할 수 있는 거절·거리·
동행·기다림과 민준이 그 자리에서 잃는 시간이나 관계를 가져야 한다.

## 파일 소유권

- `arc_y3_father_after_visit_document`, `arc_y2_money_structure`가 있는 KO/EN event 파일
- `content/events/{arc_midgame,arc_new_characters,arc_pre_ending,arc_drama}.json`
- `content/events_en/`의 같은 4파일
- 이 오더의 큐·상태·작업 기록

대상 object 위치는 선언 때 `rg`로 확정한다. 보호: 보존 root KO/EN, 그 밖의 event
objects, startup 16 roots, story map/rules/spine, manifest/audit/kernel, runtime/save/UI/
balance/endings, ORDER-104~111의 비대상 원고, JA/zh-CN/zh-TW.

## 완료·판정

- L1: strict JSON, KO/EN 구조·placeholder, 대상 object exact diff, 보존 hash,
  한영 coverage·story consistency·speech register·표적 감사·diff.
- L2: 107·109 지목 두 편을 직접 읽고, career 보존 1편 외 15편은 전수 판정한다.
- L3: 107·109의 새 두 편은 반드시 직접 재판정한다. career는 15편 전수 판정을
  무작위 3편으로 대체하지 않는다. 기록은 `Claude(사용자 위임)`이며 사용자 최종
  GO와 구분한다.

## 정본·일회성 판정

- 사람의 행동이 결과를 운반하고 내부 상태를 산문에 노출하지 않는 규칙은 기존
  정본이 소유한다. 새 중복 승격 없음.
- 정확한 18단위·보존 hash·파일·검사는 이 복구 오더의 일회성 지시다.
