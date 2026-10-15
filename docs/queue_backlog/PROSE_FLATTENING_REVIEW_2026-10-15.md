# 사실 수리 뒤 문장 평탄화 검수 (2026-10-15 Claude)

> 범위: 2026-10-12~10-15 main의 본편 사실 수리(content/events·endings KO, 77커밋, 바뀐 KO 잎 260개).
> 게임 파일은 바꾸지 않은 검수 문서다. 적용은 Codex가 한다(KO/EN 뒤 JA/zh는 일괄 정합 원칙대로 나중).

## 결론

1. **사실 수리 자체는 맞다.** 확인한 수정 대부분은 실제로 조건에 없는 사실(동거, 투자 수익, 경과 연수, 하지 않은 통화)을 지운 것이다.
2. **고치는 방식이 문장을 흐리게 만들고 있다.** 지어낸 사실을 **구체적인 다른 사실**로 바꾸지 않고, "떠올렸다 / 다시 펼쳤다 / ~라고 정할 수는 없었다" 같은 **추상 회상 + 부정 헤지**로 바꾼다. 이 게임의 정본(CLAUDE.md "감각 구체·절제된 연기·여운", "짧은 교훈 카드로 대체하지 않는다")과 반대 방향이다.
3. **한 건은 설계 판단이 필요하다.** 마지막 6개월의 "전부 건다" 선택이 실제 주문이 아니라 "계획 저장"이 되었다(아래 E).

## 측정 (수리 전 → 후, 바뀐 260잎 합계)

| 신호 | 전 | 후 |
|---|---:|---:|
| 부정 헤지 어미("~수는 없었다", "~주지는 않았다", "설명할 수", "확인할 수") | 9 | **34** |
| "떠올" | 17 | **43** |
| "기록" | 31 | 46 |
| "그때" | 16 | 25 |
| "계획" | 15 | 25 |
| "다시 펼" / "남은 기록" | 0 | 7 |
| 평균 길이 | 190자 | 189자 |

길이는 그대로인데 구체 사물이 빠지고 회상·헤지가 그 자리를 채웠다. 이 장치가 쌓이면 2~5장이 같은 목소리로 반복된다(2장 "수첩 칸 나누기" 반복을 지운 것과 같은 문제다).

## 대표 사례와 대안 (KO)

원칙: **지어낸 사실을 지우면, 그 자리에는 지금 장면에서 참인 감각 하나를 넣는다.** 조건이 갈리면 `description_if_known` 분기로 구체성을 유지한다. 해설·헤지로 닫지 않는다.

### A. `arc_36_reality_check` 기본 본문 (`b12d6be3`)

- 수리 전: "숫자가 나왔다. … 지금 속도로는 안 된다. 뭔가 달라져야 했다. / 3년 전에도 똑같이 생각했었다는 걸 기억했다." — 진행이 앞선 런에도 "안 된다"고 단정하고 "25개월"이 남은 시간과 어긋났다(사실 결함 맞음).
- 수리 후: "현재 자산과 목표 금액을 다시 비교했다. 남은 시간을 생각하며 계획의 어느 부분부터 다시 볼지 살폈다. … 그 숫자가 앞으로의 결과까지 알려 주지는 않았다. … 한동안 빈 종이만 봤다." — 장면의 긴장이 사라졌다.
- 대안:
  > 3년이 지났다.
  >
  > 계산기를 꺼냈다. 현재 총자산. 목표 금액. 남은 시간.
  >
  > {name}은 세 숫자를 메모지에 옮겨 적고 가운데 줄에 볼펜으로 밑줄을 그었다. 힘이 들어가 종이 끝이 조금 찢어졌다.
  >
  > 화면의 숫자는 그대로였다. {name}은 찢어진 자리를 엄지로 눌러 펴면서 다음 주 달력을 열었다.
- 진행 상황(목표 대비 앞섬/뒤처짐)을 갈라 쓰고 싶으면 기존 자산 비율 조건이 있는지 먼저 확인하고 DIK로 나눈다. 없으면 위 중립 감각본으로 둔다.

### B. `arc_36_body_signal` DIK `maintained_routine` (`09ab1b0d`)

- 수리 전 마지막 문단: "작년에도 루틴을 유지했었다. 그런데도 신호가 온다." (운동을 2년 전에 멈췄다는 공통 문단과 충돌 → 수리 타당)
- 수리 후 마지막 문단: "내일 일정을 다시 짰던 때가 떠올랐다. 그때 쓴 일정이 지금의 숨까지 설명해 주지는 않았다."
- 참고: `maintained_routine`은 `arc_35_habit_check`의 "내일 일정을 다시 짰다"가 만든다. 수리 후 문장은 이 실제 선택을 가리킨 점은 맞지만, 부정 헤지로 닫았다.
- 대안(실제 선택을 그대로 쓰고 감각으로 닫는다):
  > 흔들리지 않으려고 내일 일정을 다시 짰던 날이 있었다. 그날의 다짐과 지금의 젖은 손바닥 사이에서, {name}은 휴대폰 메모를 열어 오늘 날짜와 "두 정거장, 숨"이라고만 적었다.

### C. `arc_year_two_half` 기본 본문 (`034a4fbd`)

- 수리 전: "서울에 온 지 2년 반. … 그 안에는 이름을 지운 연락처와 새로 생긴 비밀번호, 익숙해진 방의 소리가 전부 들어 있었다." — 경과 기간 표기가 문제였지만 사물 목록은 어느 경로에서도 참이고 이 장면의 핵심이었다.
- 수리 후: "목표액만 적혀 있을 때보다 페이지가 무거워 보였다. 숫자 아래 빈 줄을 손끝으로 따라가다가 멈췄다." — 사물이 사라졌다.
- 대안(기간 표기 없이 사물을 되살림):
  > 반환점에서 적었던 숫자를 다시 펼쳐 보았다. 그때의 계산 옆에 오늘의 잔액을 적었다.
  >
  > 숫자 사이에는 적지 않은 것들이 끼어 있었다. 새로 외운 비밀번호 몇 개, 이제는 잠들 때 들리지 않는 방의 소음, 저장만 해 두고 걸지 않은 번호.
  >
  > 처음 서울에 왔을 때의 자신을 떠올렸다. 이 페이지를 봤다면 무슨 말을 했을까. 답을 쓰려던 손목이 뻐근해졌다. 페이지는 아직 넘기지 않았다.

### D. `arc_year3_close` DIK `year2_confident` (`3ee7cb66`)

- 수리 전: "작년 이맘때 궤도에 올랐다고 생각했다 … 믿었던 사람의 말, 멘토가 내민 종이…" — 실제 `year2_confident` 생산 선택은 "새해 첫 주 달력에 지킬 일정 하나를 옮긴다"라서 "궤도" 단정은 지어낸 것이었다(수리 타당).
- 수리 후: "올해 기록을 휴대폰에서 다시 펼쳤다. 계획한 일과 실제로 끝낸 일을 한 줄씩 맞춰 봤다." — 플래그가 가리키는 실제 장면(달력에 옮긴 일정 하나)을 쓰지 않고 일반 "기록 펼치기"로 대체했다.
- 대안(첫 두 문단만 교체, 나머지 유지):
  > 35세의 마지막 밤. 작년 이맘때 {name}은 새해 첫 주 달력에 지킬 일정 하나를 옮겨 적었다. 그 칸을 시작으로 올해 달력에는 지킨 시각과 미룬 시각이 번갈아 쌓였다.
  >
  > 목표까지 남은 숫자는 그 어느 칸도 구분하지 않았다. 도착한 날과 도착하지 못한 날이 같은 화면 아래에 묻혀 있었다.

## 설계 판단이 필요한 1건 (사용자)

### E. `arc_endgame_sixmonths` 선택1 "전부 건다" (`a402e402`)

- 이 선택은 효과가 `luck/mental/tint`와 `final_gamble_taken` 플래그뿐이고 실제 거래가 없다. 예전 문장은 "주문 금액을 끝까지 올렸다 … 체결음"으로 **실행하지 않은 거래를 묘사**했다(사실 결함 맞음). Codex는 문장을 "위험한 계획을 저장한다 / 아직 주문은 내지 않았다"로 바꿨다.
- 결과: 마지막 6개월의 정점 선택이 "계획 저장"이 됐다. `arc_final_week`의 `final_gamble_taken` 회수도 같은 맥락으로 약해진다.
- 선택지:
  - ① 지금처럼 계획 저장으로 둔다(가장 안전, 정점 약화).
  - ② 선택이 실제로 보유 자산을 고위험 자산으로 옮기게 한다(정점 회복, 밸런스·엔딩 분포 변경 → 사용자 승인과 경제 시뮬 필요).
  - ③ 실제 거래 없이도 되돌릴 수 없는 행동으로 바꾼다(예: 다음 달 매매를 미리 예약하고 취소 버튼을 지운다, 증권사 앱 알림을 끈다). 문장과 시스템이 일치하고 밸런스는 그대로.
- **권고: ③.** 밸런스를 건드리지 않으면서 "돌이킬 수 없음"을 회복한다.
- **2026-10-15 사용자 결정: ③** ("너 권고대로 해", DECISIONS 2026-10-15). 효과·플래그(`final_gamble_taken`)·조건은 그대로 두고 문장만 바꾼다.
  실제 거래나 예약 기능은 만들지 않는다. 돌이킬 수 없는 행동은 "멈출 조건 칸을 비운 채 저장한다"이다(시스템이 없어도 참인 행동).

  선택1 text
  - KO: 멈출 조건 칸을 비운 채, 큰 위험을 감수할 계획을 저장한다
  - EN: Leave the stop line blank and save a high-risk plan

  선택1 result_text (3문단 유지)
  - KO:
    > 사용할 돈과 감수할 손실을 빈칸에 적었다. 마지막 줄, '여기서 멈춘다'에 쓸 숫자 앞에서 펜이 오래 멈췄다. {name}은 그 줄을 비워 둔 채 저장 버튼을 눌렀다. 손이 떨렸지만 눌렀다.
    >
    > 저장된 계획을 다시 열자 빈 줄 하나가 화면 아래쪽에 하얗게 남아 있었다. {name}은 그 줄을 건드리지 않고 폰을 엎어 놓았다.
    >
    > 손끝의 떨림은 멈추지 않았다. 엎어 놓은 폰 아래에서, 빈 줄 하나가 남은 반년을 기다리고 있었다.
  - EN:
    > He filled in the money he would use and the loss he would accept. At the last line, "Stop here," the pen hovered for a long time. {name} left it blank and pressed save. His hand shook, but he pressed it.
    >
    > When he reopened the saved plan, the one empty line sat white at the bottom of the screen. {name} turned the phone facedown without touching it.
    >
    > The tremor in his fingertips didn't stop. Under the facedown phone, one blank line waited for the last six months.

  회수 `arc_final_week` DIK `final_gamble_taken`의 해당 줄
  - KO: "마지막 구간 어느 밤, 멈출 조건 칸을 비운 채 위험한 계획을 저장했다."
  - EN: "One night in the final stretch, he left the stop line blank and saved a risky plan."
  - 다음 줄("그 밤도 이 5년의 일부다. 부정하지 않기로 했다.")은 유지한다. JA/zh는 일괄 정합 때 맞춘다.

## Codex 적용 규칙 (다음 사실 수리부터)

1. 지어낸 사실을 지우면 같은 자리에 **현재 장면에서 참인 감각·사물 하나**를 넣는다. "떠올렸다/다시 펼쳤다"로 메우지 않는다.
2. "~라고 정할 수는 없었다", "~까지 설명해 주지는 않았다" 같은 **부정 헤지로 문단을 닫지 않는다.**
3. 플래그 DIK는 그 플래그를 만든 **실제 선택의 장면**을 쓴다(예: `year2_confident` → 달력에 옮긴 일정).
4. 아래 44잎은 헤지·회상 장치가 늘어난 곳이다. 위 A~D 방식으로 다시 본다. 적용은 KO/EN 먼저, JA/zh는 일괄 정합 때.

## 헤지·회상 장치가 늘어난 잎 (44개)

| 파일 | 이벤트 | 잎 | 헤지 +n | 회상 장치 +n |
|---|---|---|---:|---:|
| arc_daeun_extension.json | `arc_daeun_year3_together` | `/description` | 0 | 1 |
| arc_drama.json | `arc_sangchul_deduction` | `/description` | 0 | 1 |
| arc_events.json | `arc_jaehyuk_03_pitch` | `/description_unorthodox` | 0 | 1 |
| arc_events.json | `arc_jaehyuk_04a_ghost` | `/description_if_known/asked_partial_return` | 0 | 1 |
| arc_events.json | `arc_jaehyuk_ghost_decision` | `/choices/0/result_text` | 0 | 1 |
| arc_hyunsu.json | `hyunsu_pass_news` | `/choices/1/result_text` | 0 | 1 |
| arc_midgame.json | `arc_34_two_years_in` | `/description` | 0 | 1 |
| arc_midgame.json | `arc_34_two_years_in` | `/description_orthodox` | 0 | 1 |
| arc_midgame.json | `arc_34_two_years_in` | `/description_unorthodox` | 0 | 1 |
| arc_midgame.json | `arc_35_alone` | `/choices/2/result_text` | 0 | 1 |
| arc_midgame.json | `arc_35_alone` | `/description` | 0 | 1 |
| arc_midgame.json | `arc_36_body_signal` | `/choices/1/result_text` | 1 | 0 |
| arc_midgame.json | `arc_36_body_signal` | `/description` | 0 | 1 |
| arc_midgame.json | `arc_36_body_signal` | `/description_if_known/changed_routine` | 2 | 2 |
| arc_midgame.json | `arc_36_body_signal` | `/description_if_known/maintained_routine` | 2 | 2 |
| arc_midgame.json | `arc_36_body_signal` | `/description_if_known/restarted_exercise` | 2 | 2 |
| arc_midgame.json | `arc_36_reality_check` | `/description` | 1 | 0 |
| arc_midgame.json | `arc_37_reckoning` | `/description` | 1 | 0 |
| arc_midgame.json | `arc_37_reckoning` | `/description_if_known/year3_doubled_down` | 1 | 0 |
| arc_midgame.json | `arc_37_reckoning` | `/description_if_known/year3_steady_path` | 1 | 0 |
| arc_midgame.json | `arc_endgame_sixmonths` | `/choices/2/result_text` | 1 | 0 |
| arc_midgame.json | `arc_endgame_sixmonths` | `/description_if_known/final_year_conservative` | 1 | 0 |
| arc_midgame.json | `arc_endgame_sixmonths` | `/description_if_known/final_year_waiting` | 0 | 1 |
| arc_midgame.json | `arc_midpoint_reckoning` | `/description` | 1 | 0 |
| arc_midgame.json | `arc_year_three_crossroads` | `/choices/2/result_text` | 1 | 0 |
| arc_midgame.json | `arc_year_three_crossroads` | `/description_if_known/envy_released` | 0 | 1 |
| arc_midgame.json | `arc_year_three_crossroads` | `/description_if_known/envy_still_burning` | 1 | 1 |
| arc_midgame.json | `arc_year_three_half` | `/choices/0/result_text` | 0 | 2 |
| arc_midgame.json | `arc_year_three_half` | `/description` | 1 | 1 |
| arc_midgame.json | `arc_year_two_half` | `/description` | 0 | 2 |
| arc_midgame.json | `arc_year_two_half` | `/title` | 0 | 1 |
| arc_year3_drama.json | `arc_jiyeon_year3` | `/description` | 0 | 1 |
| arc_year3_drama.json | `arc_y3_cost_of_knowing` | `/description` | 1 | 0 |
| arc_year3_drama.json | `arc_y3_jiyeon_departure` | `/description` | 0 | 1 |
| arc_year_close.json | `arc_year2_close` | `/description_if_known/y2_lease_renewed_one_year` | 0 | 1 |
| arc_year_close.json | `arc_year3_close` | `/description` | 1 | 0 |
| arc_year_close.json | `arc_year3_close` | `/description_if_known/arc_jaehyuk_ghost_seen` | 1 | 0 |
| arc_year_close.json | `arc_year3_close` | `/description_if_known/father_confession_heard` | 2 | 0 |
| arc_year_close.json | `arc_year3_close` | `/description_if_known/sangchul_truth_known` | 2 | 1 |
| arc_year_close.json | `arc_year3_close` | `/description_if_known/year2_confident` | 1 | 1 |
| arc_year_close.json | `arc_year3_close` | `/description_if_known/year2_conflicted` | 2 | 1 |
| arc_year_close.json | `arc_year4_close` | `/description` | 1 | 0 |
| endings.json | `crypto_ghost` | `/description` | 0 | 1 |
| endings.json | `empty_house` | `/description_if_known/father_passed` | 1 | 0 |
