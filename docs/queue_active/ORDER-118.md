# Active Queue Spec: ORDER-118

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-118 [P0·서사/계약] 반려된 startup 마지막 해를 사람과 시간으로 전면 재설계한다

**착수 (2026-08-21):** 만지는 파일은 KO/EN
`arc_midgame.json`, `arc_new_characters.json`, `arc_pre_ending.json`,
`arc_drama.json`, `content/meta/year5_reference_routes.json`,
`tools/year5_reference_route_audit.py`, `tools/Year5ReferenceRouteR1Check.gd`,
그리고 이 오더의 큐·상태·작업 기록으로 한정한다. R1b·저장·dispatcher·transaction·
ending은 계속 동결한다.

**판정 근거 (2026-08-21):** `판정: Claude(사용자 위임) — ORDER-113 전량 반려`.
사용자 최종 GO는 OPEN이다. 원문 revision은 `803a372d4314d58d9ee03038bca3897bc2e18630`,
표본은 seed 9821 무작위 3편이며 인물 목소리 / 지금 잃는 것 / 다음을 기다리게 하는
여운 세 축을 모두 보았다.

## 깊이 3문

1. 기존 16편은 career와 같은 `표지→검토자→경계→방→접수→사본→실행→사본→서명`
   골격을 밟고, 마지막 선택까지 담당·표·계정 기입으로 끝난다. 창업자의 회사와
   공동창업자·팀·고객이 사건의 원인이 아니라 서류의 대상이 됐다.
2. 새 16편은 M49~M60 월 위치만 참고하고 root 순서·choice 수·continuation을 새로
   설계한다. 각 실제 선택은 누구 곁에 남는지, 어느 시간을 버리는지, 누가 현재
   손실을 떠안는지 중 하나를 바꾼다. 단일 진행 장면은 그 사람과 그 자리에서만
   가능한 행동이어야 한다.
3. R1a pure kernel은 삭제하지 않지만 기존 9+9 주입 계약은 반려 증거다. 새 원고 L3와
   별도 새 계약 전에는 R1b·save·dispatcher·transaction·ending을 연결하지 않는다.

## 배치 — 정확히 21단위

### startup 사건 16단위

아래 ID는 기존 물성을 찾는 locator일 뿐이다. ID를 보존할 수는 있으나 현재의 43
choices, 9칸 순서, 문서 계보와 continuation 배열은 보호 대상이 아니다.

1. `arc_y5_startup_offer_c0`
2. `arc_y5_startup_c0_reviewer_delivery_minseo`
3. `arc_y5_startup_boundary_cofounder`
4. `arc_y5_startup_minseo_goal_cost`
5. `arc_y5_startup_after_goal_cofounder`
6. `arc_y5_startup_final_offer_acquirer`
7. `arc_y5_startup_reviewer_receipt_minseo`
8. `arc_y5_startup_three_in_room`
9. `arc_y5_startup_three_in_room_decision`
10. `arc_y5_startup_c2_sign_self`
11. `arc_y5_startup_c2_copy_delivered_cofounder`
12. `arc_y5_startup_people_verdict_cofounder`
13. `arc_y5_startup_contract_execution_c3`
14. `arc_y5_startup_c3_copy_delivered_cofounder`
15. `arc_final_countdown_startup_executed`
16. `arc_y5_final_week_startup_after_acquisition`

각 단위는 다음을 모두 적는다: 장소, 실제 배우, 사건을 연 사람/물건, 지금 비용을
내는 사람, 닫히는 길, 바로 다음 독자. 공동창업자·기명 팀·실제 고객 중 적어도 한
사람이 사건의 원인이거나 비용을 자기 목소리로 말해야 한다. `담당자`와 `인수
책임자`만으로 장면을 닫지 않는다.

`arc_final_countdown_startup_executed`의 책임표·당직표·계정 인계표 선택은 전부
폐기한다. 33세·50만원에서 출발한 5년의 마지막 선택은 팀의 마지막 독립 저녁,
공동창업자와 첫 고객에게 쓰는 시간, 인수사 첫 공식 자리를 포기하는 일처럼 서로
다른 사람과 시간을 직접 잃게 한다. 먼 성공·용서·잔류는 보장하지 않는다.

### 코드 표면 제거 4단위

17. `arc_midgame.json` KO/EN 대상 원고
18. `arc_new_characters.json` KO/EN 대상 원고
19. `arc_pre_ending.json` KO/EN 대상 원고
20. `arc_drama.json` KO/EN 대상 원고

21. `year5_reference_routes`와 감사기를 새 원고가 아니라 **invalidated old evidence**로
    유지하고, 새 계약이 없다는 상태를 검증한다.

Claude 기록의 표면 기준은 코드형 토큰 178회/26장면이다. 선언 단계에서 정확한
matcher와 803a372 재현 수치를 먼저 고정하고, 차이가 나면 추정으로 숫자를 맞추지
말고 방법을 기록한다. KO/EN의 `NOT USED`, `SELF ONLY`, `TF-C2-SELF`,
`TF-C3-EXEC`, `SA-20`, 문서 버전·해시 끝자리는 플레이어 산문·선택·결과에서 0으로
만든다. 상태값·opaque ID는 데이터에만 두고, 필요한 자연어는 `첫 제안서`, `수정안`,
`조건부 접수본`, `실행 확인서`처럼 쓴다.

## 파일 소유권

- `content/events/{arc_midgame,arc_new_characters,arc_pre_ending,arc_drama}.json`
- `content/events_en/`의 같은 4파일
- `content/meta/year5_reference_routes.json`
- `tools/year5_reference_route_audit.py`, `tools/Year5ReferenceRouteR1Check.gd`
- 이 오더의 큐·상태·작업 기록

보호: story map/rules/spine, GameState·SaveManager·EventManager·MainGame·StoryMode,
EndingSystem·StoryMapMonthlyRuntime, 5개 언어 endings, startup legacy objects,
비대상 event objects, JA/zh-CN/zh-TW 본문, `systems/Year5ReferenceRouteKernel.gd`와 uid.

## 완료·판정

- L1: strict JSON, KO/EN 구조·placeholder, 대상 object exact diff, 코드 토큰 0,
  invalidated/product consumer 0/dispatch 0, 보호 바이트, 표적 감사와 diff.
- L2: 16편을 한 줄로 낭독해 career와 다른 끝맺음인지, 선택이 기록 방식이 아닌지,
  공동창업자·팀·고객의 고유 목소리와 현재 비용이 있는지 판정한다.
- L3: 새 16편에서 seed 9821 무작위 3편. 하나라도 세 축에 미달하면 전량 반려한다.
  기록은 다시 `Claude(사용자 위임)`으로 남기고 사용자 최종 GO와 합치지 않는다.
- 이 오더가 끝나도 R1b는 자동으로 열리지 않는다. 새 career/startup 원고 판정 뒤
  별도 계약 오더가 replacement contract를 만들고 사용자가 범위를 확인해야 한다.

## 정본·일회성 판정

- 플레이어 산문에 내부 상태·route·hash를 노출하지 않는 규칙은 `CLAUDE.md`가 이미
  소유한다. 새 중복 승격 없음.
- 정확한 21단위·파일·locator·검사는 이 복구 오더의 일회성 지시다.
