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

**재판정 (2026-08-22):** 구현 후보 `f425b812`의 사양 1..16 exact root 순서에
CPython `random.Random(9821).sample(roots, 3)`을 적용한 fresh #11/#2/#3을
Claude(사용자 위임)가 낭독해 3편×3축 모두 GO했다. 이 판정은 역사적 반려를
덮지 않고 사용자 최종 GO도 대신하지 않는다. 상세 이력은
`docs/human_gates.json`이 소유하며 R1b는 계속 HOLD다.

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
공동창업자와 현재 고객에게 쓰는 시간, 인수 뒤 첫 전환 자리를 포기하는 일처럼 서로
다른 사람과 시간을 직접 잃게 한다. 먼 성공·용서·잔류는 보장하지 않는다.

### 재설계 동결 — 여섯 결정과 열 사람 다리

새 세로줄은 `고객 장애→팀에 번진 소문→창업자들의 밤→누가 회사를 대표하는가→
당사자 회의→공동창업자의 자기결정→고객의 판결→실제 매각→마지막 저녁`이다.
기존 16 ID는 위치 표지로만 남기고 실제 결정은 여섯 번, 선택은 17개다. 나머지 열
장면은 UI상 한 번의 계속 동작을 가질 수 있으나 새 선택으로 세지 않는 사람 결과다.
전체 JSON choice 수는 27개다.

현재 고객 연락 인물 `수진`은 M49 수신 화면에서 처음 성립하는 route-scoped
표시 이름이다. 첫 고객·회사·산업·직함은 발명하지 않는다. 팀은 집단으로만 두고
기명 팀원을 새로 만들지 않는다. 공동창업자는 이름·성별·나이·지분·매도인 여부를
정하지 않는다. 수진과 공동창업자는 새 계약의 durable actor 선언이 아니며,
replacement contract가 생기기 전에는 산문 안의 local cast일 뿐이다.

| # | 월·ID | 장소·실제 배우 | 사건 / 지금 비용 / 닫히는 길 / 다음 독자 |
|---:|---|---|---|
| 1 | M49 `arc_y5_startup_offer_c0` | 금요일 저녁 사무실 · 민준, 공동창업자, 팀, 수진(전화) | 수진의 서비스 중단 전화가 울리는 중 160억원·민준 20%·32억원 제안이 도착한다. 수진과 팀이 시간을 내며, 사람 없는 숫자로 읽는 길을 닫고 2가 읽는다. |
| 2 | M49 `arc_y5_startup_c0_reviewer_delivery_minseo` | 마감 직전 카페 · 민준, 민서, 공동창업자(음성) | 수습 때문에 늦은 민준에게 공동창업자는 가격만 보고 오지 말라 하고, 민서는 매각 판정을 거절한 채 민준을 돌려보낸다. 민서의 약속한 저녁을 잃고 3이 읽는다. |
| 3 | M50 `arc_y5_startup_boundary_cofounder` | 늦은 사무실 · 민준, 공동창업자, 팀 | 팀이 인수사 이름을 먼저 들었다. 공동창업자는 보호한 척 세워 두고 공지를 떠넘기지 말라고 한다. 비밀·공동 발언·창업자 선설명 중 하나를 닫고 4가 읽는다. |
| 4 | M51 `arc_y5_startup_minseo_goal_cost` | 점심 카페 · 민준, 민서, 수진(동의한 통화) | 수진은 회사 이름보다 월요일 작동 여부를 묻고, 민서는 32억원은 목표지만 오늘 밤의 비용은 생활이라고 말한다. 민서의 식사 시간을 잃고 5가 읽는다. |
| 5 | M51 `arc_y5_startup_after_goal_cofounder` | 팀 퇴근 뒤 사무실 · 민준, 공동창업자, 팀, 수진(전화) | 공동창업자가 코트를 입는 순간 서비스가 다시 멈춘다. 누가 밤을 내는지 정해 자기 잠·두 창업자의 마지막 사담·고객의 기억 중 하나를 닫고 6이 읽는다. |
| 6 | M52 `arc_y5_startup_final_offer_acquirer` | 인수사 유리 회의실 · 민준, 공동창업자, 인수 책임자, 팀·수진(원격) | 실제 시연을 앞두고 누가 회사를 대표할지 정한다. 공동 저자성·민준의 자기 지분 설명권·팀 곁의 창업자 중 하나를 잃는다. M53 기존 장면 뒤 7이 읽는다. |
| 7 | M54 `arc_y5_startup_reviewer_receipt_minseo` | 카페 안쪽 · 민준, 민서, 공동창업자 | 민서는 승인자가 되지 않고 공동창업자는 자기가 남을 월요일을 직접 말한다. 고객 수습과 인수 준비 한 시간을 잃고 8이 읽는다. |
| 8 | M55 `arc_y5_startup_three_in_room` | 창업 사무실 · 민준, 공동창업자, 팀, 수진, 인수 책임자 | 수진이 아직 열린 운영 화면을 들고 오고 팀이 피치 화면을 끈다. 고객의 이동과 팀 작업 시간을 내며 밀실 협상 길을 닫고 9가 읽는다. |
| 9 | M55 `arc_y5_startup_three_in_room_decision` | 같은 방 · 같은 다섯 배우 | 수진의 다음 전화 질문과 인수사의 재개 요구가 충돌한다. 당일 승인·고객 신뢰·민준의 협상 통제 중 하나를 잃는다. M56 기존 아버지 장면 뒤 10이 읽는다. |
| 10 | M57 `arc_y5_startup_c2_sign_self` | 해 뜨기 전 사무실 · 민준, 공동창업자 | 공동창업자가 열쇠를 놓고 인수 뒤 자기 시간을 어디까지 쓸지 스스로 말한다. 민준이 타인의 이후를 대신 정하는 길을 닫고 11이 읽는다. |
| 11 | M57 `arc_y5_startup_c2_copy_delivered_cofounder` | 같은 날 팀 자리 · 민준, 공동창업자, 팀 | 공동창업자가 자기 결정을 직접 말하고 팀은 왜 늦게 알았는지 묻는다. 팀의 기다린 시간을 청구하며 둘만 합의해 통보하는 길을 닫고 12가 읽는다. |
| 12 | M58 `arc_y5_startup_people_verdict_cofounder` | 수진이 일하는 고객 현장 · 민준, 공동창업자, 팀, 수진 | 수진이 두 창업자를 실제 지원석에 앉힌다. 고객의 업무 한 시간과 팀의 지원 교대를 쓰며 사람의 판결을 공지로 대체하는 길을 닫고 13이 읽는다. |
| 13 | M59 `arc_y5_startup_contract_execution_c3` | 인수사 종결실 · 민준, 공동창업자, 인수 책임자, 수진(긴급 전화) | 32억원 이체 직전 서비스 경보가 울린다. 남으면 20%와 마지막 독립 대응을, 나가면 그날의 32억원 창구를 잃는다. 실행만 14가 읽고 비실행은 실행 전용 M60을 닫는다. |
| 14 | M59 `arc_y5_startup_c3_copy_delivered_cofounder` | 종결실 밖 복도 · 민준, 공동창업자, 수진(전화) | 실행 뒤 공동창업자·팀·수진이 민준 없이 경보를 일단 진정시켰다. 돈으로 되살릴 수 없는 시간을 직접 들으며 15가 읽는다. |
| 15 | M60 `arc_final_countdown_startup_executed` | 옛 사무실 입구와 강남의 밤 · 민준, 공동창업자, 팀, 수진, 인수사 | 서른여덟 생일 일주일 전, 팀의 마지막 독립 저녁·공동창업자와 수진의 현장·인수 뒤 첫 전환 자리가 동시에 닫힌다. 가지 않은 두 자리를 잃고 16이 읽는다. |
| 16 | M60 `arc_y5_final_week_startup_after_acquisition` | 인수 뒤 첫 월요일 같은 사무실 · 민준, 공동창업자, 팀, 수진의 목소리, 인수 책임자 | 옛 간판 나사 자국 아래에서 지난 금요일 고른 한 자리와 비운 두 자리가 branch-neutral한 사람 반응으로 돌아온다. 마지막 결정을 고쳐 쓰는 길을 닫고 엔딩·L3가 읽는다. |

여섯 결정은 다음과 같이 고정한다.

- M50: 팀을 다시 불러 두 창업자가 설명 / 민준은 팀 곁에 남고 공동창업자가 인수사
  통화를 혼자 받음 / 두 창업자가 인수사로 가고 팀은 답 없이 퇴근.
- M51: 민준이 야간 지원을 맡음 / 두 창업자가 수진에게 함께 감 / 민준은 인수 준비로
  떠나고 공동창업자·팀이 밤을 맡음.
- M52: 민준이 혼자 인수사에서 회사를 대표 / 공동창업자가 인수사를 맡고 민준은
  서비스 곁에 남음 / 두 창업자가 인수사에 남아 팀·수진이 시연을 떠맡음.
- M55: 인수 책임자를 한 시간 밖에 세우고 팀·수진을 들음 / 인수사를 남겨 협상을
  계속함 / 민준이 수진과 나가고 공동창업자가 팀·인수사와 남음.
- M59: 남아 20%를 32억원에 한 번 넘김 / 공동창업자와 수진에게 가서 20%를 지키고
  그날의 32억원 창구를 닫음.
- M60: 팀의 마지막 독립 저녁 / 공동창업자와 수진의 야간 현장 / 인수 뒤 첫 전환 자리.

전수 낭독 기준선은 `M50 첫째→M51 첫째→M52 첫째→M55 첫째→M59 첫째→M60
둘째`다. 좋은 선택 누적이 아니라 팀에게 먼저 말하고도 결국 회사를 팔며, 마지막에는
인수사와 팀 양쪽 자리를 모두 잃고 공동창업자와 현재 고객에게 가는 모순을 보존한다.
M53·M56은 기존 별도 장면이며 이 원고가 배우·결과·receipt를 발명하지 않는다.

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

**착수 실측:** player-visible matcher는 네 KO/EN 파일의 각 object에서
`title`, `description`, 모든 `choices[].text`, `choices[].result_text`만 이어 붙인 뒤
`NOT USED|SELF ONLY|TF-C2-SELF|TF-C3-EXEC|SA-20|A6E8|91B4|D772|5C20`의 exact
literal occurrence를 센다. 현재 원문은 KO 89회/25편, EN 108회/29편, 합계
197회다. 178은 KO 89회를 양언어 동일하다고 두 배 한 값으로 재현되며 실제 EN
표면과 다르므로, 완료 기준은 위 matcher의 양언어 합계 0이다.

완료 감사는 알려진 값만 지운 뒤 다른 버전 표기가 남는 우회를 막기 위해 범위를 더
넓힌다. 위 literal에 모든 `TF-*`·`SA-숫자`, 독립된 `C숫자`·`h숫자`, 문자와 숫자가
섞인 4~8자리 대문자 16진 표기, `해시/hash`를 더한 strict matcher의 착수 모수는 KO
196회/35편, EN 210회/39편, 합계 406회/고유 39편이다. 한 구절에서 종류가 다른
위반을 각각 세므로 197과 합산하지 않으며, 두 matcher 모두 완료 시 0이어야 한다.

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

**구현 후보 (2026-08-21):** `f425b812` / tree `4c0a659e`. KO/EN 각 16 roots·
27 choices, strict player token 0, product consumer·dispatch 0이다. 표적 L1과 독립
L2는 P0/P1 0이며, fresh seed 9821 Claude(사용자 위임) 3편은 GO다. 오더는
사용자 최종 GO를 기다리는 `[~]` 상태이며 R1b와 replacement contract는 계속
HOLD다.

## 정본·일회성 판정

- 플레이어 산문에 내부 상태·route·hash를 노출하지 않는 규칙은 `CLAUDE.md`가 이미
  소유한다. 새 중복 승격 없음.
- 정확한 21단위·파일·locator·검사는 이 복구 오더의 일회성 지시다.
