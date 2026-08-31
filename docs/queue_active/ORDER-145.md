# Active Queue Spec: ORDER-145

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-145 [P0·candidate integrity] 주간 행동 신원과 M25→M28 사람선을 한 후보에서 봉인한다

**[~] 2026-08-31 Codex 범위 정합 선언 · 기준선
`a57b08c96da3a0fd509a94cf9d70f22f54f05eaa`:** ORDER-142의 M01~M60 전체
볼륨 실측에서 주간 행동 영수증·경로 신원 이관과 M25→M28 아버지
사람선이 같은 exact candidate를 막는 것을 확인했다. 연속 세션 중
이 변경 묶음의 단독 소유 선언이 누락된 것도 같이 확인했다. 이
사양과 큐 인덱스만 선언 커밋으로 먼저 고정하고, 제품 변경은 다음
별도 커밋에서 검증·봉인한다.

공개 출시 데모는 사용자가 GO한 exact `story_demo_rc` M01~M06이다. 이
오더는 데모 범위를 늘리지 않고, 월간 AP/행동판을 되살리지 않으며,
본편과 사람 게이트를 GO로 올리지 않는다.

## 깊이 3문

1. **행동 결과가 보이면 주간 정산도 성공한 것인가?** 아니다. 효과·난수·
   영수증·경로 신호가 하나의 transaction으로 성공하거나 모두 롤백되어야
   저장/불러오기와 재입력이 다른 경로를 만들지 않는다.
2. **레거시 저장의 경로 플래그 하나를 신원으로 승격해도 되는가?** 안 된다.
   exact `player_route`+단일 대응 플래그가 같이 있을 때만 실현 신원을 인정하고,
   모순·기억 소실은 보수적으로 닫는다.
3. **M25 장면 수를 늘리면 아버지 선이 복구되는가?** 아니다. M22에서 미룬
   접촉을 연 exact W100 장면이 세 결정 영수증 중 하나를 쓰고, W112가 그
   영수증을 읽어 실제 접촉 방식을 다르게 회수해야 사람선이다.

## 20단위 구현·검증

1. 새 V2 런은 미확정 `player_route=none`에서 시작한다.
2. 화면에서 선택한 주간 행동의 경향 가중치와 경로 문턱을 exact로 잠그다.
3. 효과형 주간 행동을 preflight→mutation→receipt→publish 순서로 원자화한다.
4. 난수를 쓰는 study/save/rest는 pending 소유자를 먼저 확인한다.
5. stale/mismatched owner는 mutation과 신호 발행 전에 fail closed한다.
6. rollback은 로더의 중간 신호를 노출하지 않고 완전 복원 뒤 최대 1회만 발행한다.
7. 레거시 pending side-shift의 효과와 `found +1`을 하나의 mutation에 넣는다.
8. 레거시 저장은 exact route+flag 쌍만 이관하고 flag-only를 발명하지 않는다.
9. 확정 경로를 `12/0/0`으로 정규화해 연속 V2 load에서도 유지한다.
10. 실제 W1 지원 경로의 stats 신호를 한 번만 관찰한다.
11. 직업·투자·도박·부업·쉬기 경로의 실제 UI 소유자를 회귀 검사한다.
12. Chapter 1/Year 5 해시는 기존 predecessor를 바꾸지 않고 exact successor 전이로 추가한다.
13. W100은 아버지 생존·미방문·M22 deferred일 때만 회피 문서 장면을 연다.
14. W100 세 선택은 공통 receipt와 정확히 하나의 접촉 방식 receipt를 쓴다.
15. W112는 M22 unattached·M25 receipt 1개·아버지 생존·미방문을 모두 읽는다.
16. W112 원고는 M25의 전화·문자·편지를 각각 다른 행동으로 회수한다.
17. M30 no-contact와 M55 복장·Chapter 5 무답장/무이체/미소유 선을 보존한다.
18. 오디오 원장에 실제 shipping root 두 개만 추가되었음을 집합으로 검증한다.
19. 번역 범위는 M01~M06 공개 데모와 본편 source inventory를 혼동하지 않는다.
20. clean product commit에서 ORDER-144 3-profile trace를 실행하되 HOLD/open을 유지한다.

## 반드시 보존할 경계

- exact `story_demo_rc` M01~M06 사용자 GO와 제품 바이트를 바꾸지 않는다.
- first-year 30억 `instant_legend` 이스터에그를 유지한다.
- 월간 AP/행동판을 새로 만들지 않는다.
- M25/M28은 허위 통화·답장·동석을 만들지 않고 플레이어의 앞선 방식만 회수한다.
- `project.godot`은 변경하지 않는다.
- 자동·정적 GREEN은 사람 GO가 아니다. `product_go=HOLD`,
  `human_density_gate=OPEN`, Chapter 5 두 게이트 `open`을 유지한다.

## 정확한 파일 소유권

`assets/scene_audio_manifest.json`, `autoloads/{GameState,SaveManager}.gd`,
`content/meta/{demo_localization_scope,narrative_spine}.json`,
`docs/{BALANCE,DECISIONS}.md`, `systems/DemoCoreLoopV2.gd`,
`tools/{CoreLoopV2BCheck,CoreLoopV2CycleCheck,CoreLoopV2FirstEntryCheck,CoreLoopV2HandoffCheck,EventDirectorCheck,ImmersionLoopCheck,MoneyIntegrityCheck}.gd`,
`tools/{core_loop_v2_balance_sim,full_body_translation_scope,property_ladder_audit,chapter5_general_finale_route_audit}.py`
와 이 사양·큐 인덱스만 소유한다.

`scenes/MainGame.gd`, 사건·story map·rules·lifecycle·release inventory·해시 감사기의
기존 ORDER-143 소유권은 같은 실행자가 보존한다. ORDER-144 trace 도구는
이 오더에서 제품 패스 수단으로 쓰지만 그 파일 소유권을 옮기지 않는다.

## L1 / L2 / L3

- **L1:** transaction·save identity·story graph·lifecycle·audio·translation·해시 normal/self-test가
  exact successor와 인접 변조 실패를 증명한다.
- **L2:** 실제 Godot UI 진입·저장 재로드·W100 세 선택→W112 회수를 재생한다.
- **L3:** clean exact product trace 후 M49~M60 두 경로 정상 속도 사람 실플레이를
  다시 요청한다. 이때까지 본편은 HOLD다.
