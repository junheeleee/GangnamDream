# Active Queue Spec: ORDER-146

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-146 [P0·candidate ledger] exact 제품 후보와 공개 데모 신원을 현황판에 바르게 기록한다

**[~] 2026-08-31 Codex 착수 · 제품 기준선
`6ae555f905c95f36424475b0c6da82e100cc97a1` · tree
`c1ae1fa7146f5c59bd0feceb616f1b399f3e4104`:** ORDER-145 제품 커밋은 사용자가
GO한 exact `story_demo_rc` M01~M06을 바꾸지 않았고, 본편은 아직
`product_go=HOLD`, `human_density_gate=OPEN`이다. 이 오더는 제품 파일을
바꾸지 않고 clean runtime trace 결과와 사람 재플레이 대상만 정본 원장에
기록한다.

## 깊이 3문

1. **W240 자동 도달이 GO인가?** 아니다. 자동 trace는 실제 selector·선택·상태
   receipt·엔딩 도달만 증명한다. 화면·속도·재미·밀도는 같은 exact
   candidate의 정상 속도 사람 플레이가 판정한다.
2. **어떤 데모를 현황판 상단에 두는가?** 사용자가 범위를 확정한 M01~M06
   `story_demo_rc`를 우선한다. 기존 W1~W24 `demo_rc`는 legacy/internal로
   표시하고 공개 출시 데모처럼 드러내지 않는다.
3. **새 후보가 이전 5장 실플레이를 대체하는가?** 아니다. 제품 커밋·tree·
   manifest가 다른 새 exact candidate로 property와
   `general_near_goal_father_passed` M49~M60을 둘 다 다시 실플레이해야 한다.

## 15단위 구현·검증

1. product commit·tree·dirty=false를 clean worktree에서 재확인한다.
2. 세 runtime profile 설정 SHA를 원장에 고정한다.
3. `baseline_safe_people`를 fresh title에서 W240까지 주입 없이 실행한다.
4. `investment_property_daeun`을 같은 방식으로 실행한다.
5. `general_near_goal_father_passed`를 같은 방식으로 실행한다.
6. 각 JSONL의 candidate/profile/week/occurrence/ending 계약을 재감사한다.
7. 실패 profile은 상태를 주입해 성공처럼 만들지 않고 exact 주차·원인을 남긴다.
8. `chapter5_finale_rc`에 새 product commit·tree·manifest를 등록한다.
9. property와 general 사람 게이트를 둘 다 `state=open`으로 유지한다.
10. 이전 `771d0e7…`·`9909437…`·`b375af2…`를 현재 후보로 재사용하지 않는다.
11. dashboard generator가 `story_demo_rc`를 공개 데모로 우선하게 한다.
12. W1~W24 `demo_rc`는 legacy/internal로 구분한다.
13. 생성기로 `docs/STATUS.md`를 재발급하고 손으로 고치지 않는다.
14. exact candidate의 full audit·context·EN·diff를 다시 GREEN한다.
15. 제품 변경 없는 review wrapper commit을 발급하고 두 정상 속도 실플레이를 요청한다.

## 반드시 보존할 판정

- 공개 데모: exact `story_demo_rc` M01~M06 사용자 GO.
- 본편: `product_go=HOLD`, full volume `HOLD`, `human_density_gate=OPEN`.
- Chapter 5: property/general 사람 게이트 둘 다 `open`.
- `AUDIT_OK`, `MATRIX_OK`, `HUMAN_GATES_OK`는 사람 GO가 아니다.
- 제품·원고·밸런스·`project.godot`은 변경하지 않는다.

## 정확한 파일 소유권

`tools/project_dashboard.py`, `docs/human_gates.json`, 생성본 `docs/STATUS.md`,
`docs/context_manifest.json`, `docs/CODEX_QUEUE.md`, `docs/WORK_LOG.md`, `CLAUDE.md`,
이 사양과 필요한 선언·마감 문서만 소유한다. 제품 파일은 읽기만 한다.

## L1 / L2 / L3

- **L1:** dashboard/human gate/context/full audit가 후보 신원·데모 우선순위·HOLD/open을 검증한다.
- **L2:** clean three-profile trace가 실제 W1→W240 발생과 ending을 주입 없이 남긴다.
- **L3:** 새 exact candidate의 M49~M60 두 경로 정상 속도 사람 실플레이가 판정한다.
