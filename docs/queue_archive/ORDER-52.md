# Completed Queue Spec: ORDER-52

> Canonical status is indexed in `docs/CODEX_QUEUE.md`. 선행: [`ORDER-51`](../queue_archive/ORDER-51.md) B의
> **유저 결정 = (나) 선별 부활**(2026-07-26). 근거 원장: 각본 리뷰 3차 + 부활 선별 정독.
> **Claude 코드 검증 완료** — 아래 엔진 제약·슬롯 점유는 저장소에서 재현한 사실이다.

#### [x] T1 완료 — T2는 사용자 승인 뒤 [`ORDER-53`](ORDER-53.md)으로 이관

ORDER-52 [P1·지연 회수 부활] 도달 불가 콜백 32건을 예약형으로 되살린다

> 이번 착수는 슬롯이 비어 있는 **T1 34행과 선행 산문 수리만** 소유한다.
> T2 3행과 `GameState.gd` 배열 확장은 승인 전까지 수정하지 않는다.

## 결정과 방식

ORDER-51에서 확인된 사실: 콜백 620건 중 도달 가능 24건(3.9%), chain 0/12, 대체 경로 0건.
유저는 **(나) 선별 부활**을 선택했다 — 허용목록을 확대하지 않고(ORDER-37 콘텐츠 다이어트
정본 보존), 생산자 이벤트의 선택지에 `deferred_follow_up`/`deferred_delay`를 달아 **예약형으로
직접 발화**시킨다.

선별은 도달 불가 596건 중 **작성형 생산자(arc_/story_/cafe_/hyunsu_)를 가진 249건**을 4계열로
정독해 이루어졌다. 선별 기준: ①태도 확인이 아니라 돈·몸·관계·평판의 실제 대가가 돌아올 것
②생산자가 플레이어가 실제로 망설인 무게 있는 선택일 것 ③3행 상투 골격·설교 종결·160자 미달
탈락 ④8~16주 간격이 의미를 만들 것. **최종 32건(37 배선행)** — 전량 부활은 금지했다.

## ⚠ 반드시 먼저 읽을 엔진 제약 (Claude 검증)

1. **choice당 예약은 문자열 하나뿐이다.** `autoloads/GameState.gd:1093`이
   `str(choice.get("deferred_follow_up", ""))`로 단일 값만 읽는다. 이미 예약이 있는 선택지에는
   덧붙일 수 없다 → 아래 **T2 3행이 여기 걸린다.**
2. **예약 발화는 conditions를 재검사하지 않는다.** `EventManager.gd:718 trigger_event_by_id`가
   `DataRegistry.find_event` → `queue_event`로 직행한다. 즉 `min_turn`·`flag`·`no_flag`·`has_job`이
   예약 경로에서 **전부 무효**다. 이 표는 그 사실을 delay 값으로 흡수했으나, **부활 콜백의 산문이
   성립하지 않는 상태(아버지 생존·주거·취업)를 전제하면 즉시 거짓이 된다** → 아래 산문 수리가
   선택이 아니라 **전제조건**인 이유다.
3. **예약은 그 주의 아크를 통째로 가져간다.** `scenes/MainGame.gd:2749~2754`에서 deferred는 아크
   픽커 거의 맨 앞에 있고 발화 시 `return ""`한다. 레포에 이미 81건이 살아 있어 상한 있는 아크가
   밀려 유실될 수 있다 → 검증 항목 참조.

## T1. 즉시 배선 가능 — 34행 (슬롯 비어 있음, Claude 확인)

각 행은 해당 파일의 생산자 이벤트, 그 선택지에
`"deferred_follow_up": "<콜백 id>", "deferred_delay": <주>`를 추가하는 것이다.

| # | 장 | 파일 | 생산자#선택지 | delay | 부활 콜백 |
|--:|:--:|---|---|--:|---|
| 1 | 1 | `amb_scenarios.json` | `amb_hoesik_00`#1 | 12 | `callback_hoesik_left_early_office` |
| 2 | 1 | `amb_scenarios.json` | `amb_hoesik_dodge`#1 | 8 | `callback_hoesik_caved_reputation` |
| 3 | 1 | `arc_daeun.json` | `arc_daeun_02_regular`#0 | 12 | `callback_daeun_supportive_warmth` |
| 4 | 1 | `arc_events.json` | `arc_invest_guidance`#0 | 16 | `callback_investment_lesson_echo` |
| 5 | 1 | `arc_events.json` | `arc_temptation_fallout`#0 | 16 | `callback_escaped_dirty_trace` |
| 6 | 1 | `scenario_cafe_callback.json` | `cafe_cb_stole_allin`#0 | 10 | `callback_cafe_stole_gambled_result` |
| 7 | 2 | `arc_midgame.json` | `arc_daeun_money_gap`#2 | 12 | `callback_told_daeun_everything_echo` |
| 8 | 2 | `arc_midgame.json` | `arc_daeun_money_gap`#1 | 12 | `callback_told_daeun_investing_echo` |
| 9 | 2 | `arc_events.json` | `arc_father_03_hospital`#2 | 10 | `callback_sent_money_instead_echo` |
| 10 | 2 | `arc_events.json` | `arc_father_03_hospital`#0 | 14 | `callback_rushed_to_father_echo` |
| 11 | 2 | `arc_midgame.json` | `arc_father_medication`#2 | 12 | `callback_medication_visited_echo` |
| 12 | 2 | `arc_midgame.json` | `arc_father_medication`#1 | 12 | `callback_medication_ignored_echo` |
| 13 | 2 | `arc_events.json` | `arc_jiyeon_03_offer`#2 | 16 | `callback_jiyeon_honest_referral` |
| 14 | 2 | `arc_events.json` | `arc_jiyeon_truth_moment`#0 | 16 | `callback_jiyeon_together_pressure` |
| 15 | 2 | `arc_events.json` | `arc_jiyeon_truth_warned`#0 | 16 | `callback_jiyeon_together_pressure` |
| 16 | 2 | `arc_events.json` | `arc_opp_jiyeon_bunyang`#0 | 12 | `callback_jiyeon_took_deal_consequence` |
| 17 | 2 | `arc_events.json` | `arc_opp_sangchul_realty`#2 | 16 | `callback_declined_sangchul_deal_echo` |
| 18 | 2 | `arc_events.json` | `arc_sangchul_03_network`#1 | 12 | `callback_shadow_investors_proposal` |
| 19 | 2 | `arc_hyunsu.json` | `hyunsu_pass_news`#0 | 16 | `callback_hyunsu_departure_meal_echo` |
| 20 | 3 | `arc_daeun.json` | `arc_daeun_04b_future`#1 | 12 | `callback_daeun_deferred_silence` |
| 21 | 3 | `arc_daeun.json` | `arc_daeun_05_breaking`#1 | 12 | `callback_daeun_breakup_begged_echo` |
| 22 | 3 | `arc_daeun.json` | `arc_daeun_05_together`#0 | 12 | `callback_daeun_daily_life_echo` |
| 23 | 3 | `arc_daeun_extension.json` | `arc_daeun_year3_apart`#0 | 12 | `callback_daeun_married_echo` |
| 24 | 3 | `arc_daeun_extension.json` | `arc_daeun_year3_apart`#1 | 12 | `callback_daeun_married_echo` |
| 25 | 3 | `arc_drama.json` | `arc_father_06_confession`#0 | 12 | `callback_father_confession_echo` |
| 26 | 3 | `arc_drama.json` | `arc_father_06_confession`#1 | 12 | `callback_father_confession_echo` |
| 27 | 3 | `arc_drama.json` | `arc_father_06_confession`#2 | 12 | `callback_father_confession_echo` |
| 28 | 3 | `arc_drama.json` | `arc_sangchul_buried_silence`#0 | 12 | `callback_sangchul_truth_buried_echo` |
| 29 | 3 | `arc_year3_drama.json` | `arc_y3_jiyeon_departure`#0 | 16 | `callback_jiyeon_busan_postcard` |
| 30 | 3 | `arc_year3_drama.json` | `arc_y3_jiyeon_departure`#1 | 16 | `callback_jiyeon_busan_postcard` |
| 31 | 4 | `arc_daeun_extension.json` | `arc_daeun_year4_together`#0 | 8 | `callback_daeun_gangnam_first_echo` |
| 32 | 4 | `arc_drama.json` | `arc_father_passing_deal_morning`#0 | 12 | `callback_chose_money_father_echo` |
| 33 | 4 | `arc_year3_drama.json` | `arc_y3_cost_of_knowing`#0 | 10 | `callback_used_sangchul_after_echo` |
| 34 | 5 | `arc_romance_y5.json` | `arc_daeun_y5_feelings`#0 | 8 | `callback_daeun_committed_gangnam_eve` |

**같은 콜백이 여러 행인 경우**(`callback_father_confession_echo` 3행, `callback_daeun_married_echo`·
`callback_jiyeon_together_pressure`·`callback_jiyeon_busan_postcard` 각 2행)는 그 플래그를 세우는
선택지가 여럿이라 **모든 분기에 같은 예약을 달아야** 어느 선택으로 가도 회수된다. 중복 발화는
콜백 자체의 `cooldown`/`seen` 플래그로 막는다.

## T1 실행 결과 — 2026-07-26

- 생산자 선택 **34행 → 고유 콜백 29건**을 정확히 배선했다.
  `GameState.apply_choice()` 런타임 검사가 각 예약의 대상 ID와
  `현재 주차 + delay`를 전부 확인한다.
- 필수 산문·조건·효과를 한영으로 정렬했다. 아버지 약 복용 회수는
  현재 주거에서 사진을 보는 기억 장면으로, 경찰·지연 어머니 전화는
  현재 주거의 원격 장면으로, 계약 비용은 투자 서류 표면으로 분류했다.
  쓰이지 않는 신규 플래그는 남기지 않았다.
- 대표 A/B 240주에서 각각 **6건/9건**이 발화했고 중복은 0건이었다.
  상한 있는 아크는 전부 창 안에서 생존했으며 아크 잼은 0이었다.
- 1280×800 한국어·영어에서 대표 11건의 소개/결과를 각각 렌더해
  **44장**을 검사했다. 돈·정신력 효과와 결과 문단 진행도 런타임에서
  함께 확인했다.
- 이벤트 디렉터는 도달 가능한 콜백이 **24 → 53건**, 휴면 콜백이
  **596 → 567건**으로 바뀌었다. 남은 휴면 코퍼스는 이번 선별 범위가
  아니며 자동 허용목록으로 되살리지 않는다.
- T2의 슬롯 점유 3행과 `GameState.gd` 배열 확장은 수정하지 않았다.

## T2. 슬롯 점유 3행 — ORDER-53으로 이관

하필 **값어치 최상위 3건**이 이미 예약된 선택지에 걸린다.

| 장 | 파일 | 생산자#선택지 | 기존 예약 | 추가하려는 콜백 |
|:--:|---|---|---|---|
| 3 | `arc_events.json` | `arc_jaehyuk_04b_counter`#1 | `arc_jaehyuk_aftermath` | `callback_jaehyuk_exploited_retaliate` |
| 3 | `arc_events.json` | `arc_jaehyuk_04b_counter`#2 | `arc_jaehyuk_aftermath` | `callback_jaehyuk_partnered_reckoning` |
| 4 | `arc_drama.json` | `arc_sangchul_reckoning`#2 | `arc_sangchul_year3` | `callback_sangchul_leveraged_cost` |

선택지: **(가)** `deferred_follow_up`을 배열도 받도록 `GameState.gd:1093` 한 곳을 확장한다(기존
문자열 호환 유지). 소규모지만 엔진 스키마 변경이라 승인 대상. **(나)** 기존 예약 대상
(`arc_sangchul_year3`·`arc_jaehyuk_aftermath`) 안에 부활 콜백 내용을 dik 분기로 흡수한다 —
신규 배선 없이 가능하나 별도 장면의 무게는 잃는다. **(다)** 이 3건 포기.
**사용자 결정: (가) 승인.** 구현·배선·검증은 `ORDER-53`이 소유한다.

## 부활 전 필수 산문 수리 — 25건

제약 2 때문에 이건 선택이 아니다. 예약 발화는 조건을 안 보므로, 성립하지 않는 상태를 전제한
문장은 그대로 거짓이 된다(예: 아직 쓰러지지 않은 아버지를 "쓰러진 후"로 부르는 3건).

| 콜백 | 부활 전 필수 수리 |
|---|---|
| `callback_jaehyuk_partnered_reckoning` | 산문과 effects의 액수가 어긋난다. 선택지 0의 result_text는 '원래 비율대로 받았다. 5800만원'인데 effects.money는 15,000,000이고, 선택지 1은 '3200만원을 받았다. 합의한 것보다 2600만원 적었다'인데 effects.money는 8,000,000이다(레포에서 직접 확인). 회수의 무게가 숫자로 증명되어야 하므로 한쪽으로 통일한다 — effects를 산문에 맞춰 58,000,000 / 32,000,000으로 올리면 밸런스 밴드 검토가 필요하고, 산문을 effects에 맞춰 '1500만원 / 800만원, 합의보다 700만원 적게'로 낮추면 3장 자산 규모와 더 맞는다. 후자 권장. |
| `callback_jaehyuk_exploited_retaliate` | 선택지 0의 result_text '일주일 뒤 돈이 들어왔다. 3배는 아니었지만 원금은 됐다'와 effects.money -3,000,000이 정반대로 읽힌다(레포 확인). 갈취로 이미 받은 3배분을 토해내고 원금만 남는 정산이라는 걸 문장이 밝혀야 한다. 예: '일주일 뒤 계좌가 정리됐다. 세 배로 받았던 걸 되돌려주고, 원금만 남았다.' |
| `callback_escaped_dirty_trace` | 설명문의 '대포통장에 손댔다가 빠져나온 지 5개월이 됐다'를 delay 16주에 맞춰 '넉 달이 됐다'로 고친다. 생산자 arc_temptation_fallout은 t>=8에 발화하므로 5개월은 배선과 어긋난 채 남는다. |
| `callback_sent_money_instead_echo` | 세 가지. (1) 설명문 '직접 가는 대신 돈을 보냈던 게 한 달 전이다'를 delay 10주에 맞춰 '두 달 반 전'으로 고친다. (2) 선택지 0의 mental +11은 '곧 직접 갈게요'라는 또 한 번의 미룸에 주는 순보상이라 뒤집어야 한다 — 아버지의 '바쁘면 됐다'가 이미 그 대가이므로 소폭 감소나 0으로 조정한다. (3) 선택지 1의 '하지만 돈이 — 존재를 대신할 수는 없었다'는 서술자 교훈이므로 삭제하고, 문자 화면을 오래 들여다보는 동작으로 대체한다. |
| `callback_medication_visited_echo` | 첫 줄 '아버지가 쓰러진 후 병원에서 첫 진료'가 arc_father_03_hospital(MainGame.gd:3023, t>=82)을 전제하는데 이 배선의 착지는 t≈70으로 아직 쓰러지기 전이다. 정기 진료 재방문 장면으로 고친다. 또 deferred 경로는 conditions를 재검사하지 않아 no_flag: father_passed가 무력화되므로, 문장이 아버지 생존을 단정하지 않게 다듬는다. |
| `callback_medication_ignored_echo` | 첫 줄 '아버지가 쓰러진 후 첫 통화였다'가 같은 이유로 아직 오지 않은 병원 사건을 전제한다. 약을 시작한 뒤의 일상 통화로 고쳐야 t≈70 착지와 맞는다. |
| `callback_daeun_married_echo` | 두 가지. (1) 본문 첫 줄 '며칠이 지났다'가 12주 지연과 어긋나므로 '몇 달이 지났다'로 바꿔야 늦은 회수로 읽힌다. (2) 이 콜백은 arc_daeun_year3_apart 전용 예약으로만 살린다 — daeun_married 플래그를 `arc_daeun_proposal_answer[0]`(민준이 다은과 결혼)도 세우므로 조건 기반 부활은 금지다(레포 확인). |
| `callback_hyunsu_departure_meal_echo` | 첫 줄 '오늘도 고시원이다'가 이미 이사한 플레이어에게는 거짓이 된다. arc_goshiwon_goodbye_seen이면 발화하지 않게 막거나, 이사한 경우의 대체 첫 줄(같은 질문이 새 집에서 떠오르는 형태)을 둔다. |
| `callback_declined_sangchul_deal_echo` | 설명문이 77자로 장면이 얇다. 임상철의 전화를 받는 장소와 시간 한 줄(예: 퇴근길 지하철 환승 통로)을 얹으면 감각 구체 기준을 통과한다. 회수의 값어치('그날 넣었으면 지금쯤 1.8배였다')는 그대로 둔다. |
| `callback_jiyeon_took_deal_consequence` | '오늘 첫 정산이 들어왔다. 예상보다 적었다'가 분양권 도박의 승리 분기에서 모순된다. 정산 부족을 승패와 무관한 항목(중개보수·부대비용·유보 조항)으로 바꿔 어느 결과에서도 성립하게 한다. |
| `callback_jiyeon_honest_referral` | 두 가지. (1) '나중에 계산해보니 세금만 1200만원 아꼈다'는 착지 시점(t≈74)의 자산 규모에 비해 과하다 — 보유 자산 비례 표현이나 더 작은 실수령 숫자로 낮춰 밸런스 밴드 안에 둔다. (2) 그 1200만원이 effects.money 0과도 어긋난다(레포 확인). 산문이 주장하는 절감액을 effects가 전혀 반영하지 않으므로 액수를 낮춘 뒤 investment_skill/intelligence 상승으로 회수를 표현하거나, 소액이라도 money에 반영해 숫자로 증명한다. |
| `callback_told_daeun_everything_echo` | 착지 시점(t≈72~82)은 다은이 아직 '민준씨'로 부르는 단계인데 본문이 반말('네가 다 말해줬을 때', '날 믿어준 거잖아')을 쓴다. docs/ROMANCE_SYSTEM.md 호칭 정본에 맞춰 존댓말로 바꾸거나, 연인 확정 이후로만 예약되게 생산자 선택지를 한정한다. |
| `callback_told_daeun_investing_echo` | 두 가지. (1) 선택지 1의 result_text가 '"네, 천천히 말해도 돼요." / 다은은 재촉하지 않았다.'로 31자에 그치고 대가가 없다 — 천천히 가기로 한 쪽에도 값(다은이 다시는 먼저 묻지 않는다는 식)을 남겨야 놓친 길이 성립한다. (2) 선택지 0의 mental +6은 솔직함에 대한 순보상이라 다은이 알게 된 뒤의 무게를 한 줄 더한다. 이 두 수정이 없으면 이 항목은 표에서 값어치가 가장 낮으므로 배선을 보류하는 편이 낫다. |
| `callback_daeun_supportive_warmth` | 설명문 75자로 기준 미달이나 회수가 Y5 정본 장면 변주(arc_romance_y5.json:24 daeun_date_set)를 여는 유일한 경로라 예외로 유지한다. 다만 선택지 1의 '마음은 있었는데 — 거리를 좁히지는 못했다'는 서술자 해설이므로 감각 한 줄(끊긴 대화창, 답장을 쓰다 지운 흔적)로 바꾼다. |
| `callback_cafe_stole_gambled_result` | 가장 무거운 결함. 과거 베팅의 결과(수익이냐 손실이냐)를 플레이어가 선택지로 고르게 되어 있다 — 회수가 아니라 사후 서술 권한이다. 결과는 산문이 확정하고(투자 판정이나 crossed_line_early 상태로 갈라도 된다) 선택지는 그 결과를 어떻게 감당할지만 묻게 고친다. 설명문 58자도 화면·잔고·전화 중 하나는 감각으로 늘린다. 이 수정 없이 부활시키면 '건 것의 대가'가 아니라 자기 채점이 된다. |
| `callback_daeun_committed_gangnam_eve` | 설명문 64자로 짧지만 회수가 엔딩 직결이라 예외로 유지한다. 다만 자산 게이트가 없어 미달 런에서도 '내일 계약이다. 30억.'을 단정한다 — deferred는 conditions를 재검사하지 않으므로 조건으로는 막을 수 없다. 자산 29억 미만용 변주 문단(도착 못 한 전날 밤)을 description_if_known 계열로 추가해야 한다. |
| `callback_hoesik_left_early_office` | 두 가지. (1) '지난번 회식 때 일찍 가셨던 거'를 12주 간격에 맞춰 '지난 분기 회식'류로 조정한다 — '아직'이 가장 아프게 읽히는 지점이다. (2) conditions.has_job: true가 deferred 경로에서 검사되지 않으므로 12주 사이에 퇴사한 런에서도 발화한다. 첫 줄이 현재 재직을 단정하지 않게 다듬거나, 퇴사 후 전 동료의 연락 형태로도 읽히게 쓴다. |
| `callback_hoesik_caved_reputation` | 설명문 73자로 짧다. 단톡 공지와 후배 메시지만 있고 회식 자리 자체의 감각(다시 채워지는 잔, 2차 노래방)이 없어 '또 간다'의 health -5가 무엇으로 청구되는지 보이지 않는다. 선택지 1의 결과문에 그 밤의 구체를 한 단락 넣는다. has_job 조건 무력화는 위 항목과 동일하게 처리한다. |
| `callback_jiyeon_together_pressure` | conditions.min_turn 184가 예약 착지 시점(t≈72~86)과 100주 가까이 어긋난다. deferred 경로에서는 min_turn이 무시되지만 정본이 두 개의 다른 시점을 가리키는 상태를 남기면 안 되므로, 예약 경로 기준으로 min_turn을 낮춰 일치시킨다. |
| `callback_daeun_deferred_silence` | conditions.min_turn 144가 착지 시점(t≈98)과 어긋난다. 예약 경로 기준으로 낮춰 정본을 일치시킨다. 착지가 arc_daeun_year3_apart(t>=100)보다 앞서는 것은 의도된 순서다. |
| `callback_jiyeon_honest_referral` | conditions.min_turn 120이 착지 시점(t≈74)과 어긋난다. 예약 경로 기준으로 낮춘다. |
| `callback_daeun_gangnam_first_echo` | 산문은 결함 없음. 다만 conditions.min_turn 165가 착지 시점(t≈153)과 어긋나므로 예약 경로 기준으로 낮춘다. |
| `callback_daeun_married_echo` | conditions.min_turn 130이 착지 시점(t≈112)과 어긋난다. 예약 경로 기준으로 낮춘다. |
| `callback_father_confession_echo` | 산문 자체는 결함 없음. 다만 상철 대면(arc_sangchul_confrontation, MainGame.gd:3129, t>=132) 이후에 발화하면 '이걸 안 채로 이 자리에 앉아 있다'가 거짓이 된다. delay 12면 t≈114로 안전하지만 스케줄 변동에 대비해 conditions에 no_flag: sangchul_confronted를 명시해 둔다(deferred 경로에서는 무효지만 랜덤/향후 경로의 정본 기록으로 남는다). |
| `callback_ALL_wired` | 전역 항목 — 부활 대상 32건 전부. (1) EventManager.trigger_event_by_id(EventManager.gd:718)는 conditions를 전혀 재검사하지 않고 queue_event만 호출한다. 따라서 모든 콜백의 min_turn·flag·no_flag·has_job은 예약 경로에서 장식이다. 위에 개별로 적은 min_turn 정렬을 일괄 반영해 '랜덤 경로와 예약 경로가 다른 시점을 가리키는' 상태를 없앤다. (2) 산문을 고친 32건은 content/events_en/의 대응 오버레이도 같은 작업에서 갱신해야 한다 — deferred_follow_up/deferred_delay는 gameplay key이므로 KR에만 두고, 수정된 description/result_text만 EN에 반영한다. python3 tools/en_coverage_check.py로 확인한다. |

## 검증

- `GODOT=<경로> ./tools/audit.sh` → "✅ 감사 통과", `python3 tools/english_hangul_audit.py`
- **`python3 tools/arc_flow_sim.py` 필수** — 예약 37행이 아크 슬롯을 잠식하므로 상한 있는 아크
  8종(`arc_36_body_signal` 163~172, `arc_year_three_half` 168~184, `arc_36_night_doubt` 180~187,
  `arc_36_unexpected_hand` 156~188, `arc_y3_cost_of_knowing` 137~160, `arc_y3_jiyeon_departure`
  110~135, `arc_endgame_sixmonths` 216~237, `arc_daeun_money_gap` 60~70)의 도달률 회귀를 확인한다.
  특히 `callback_chose_money_father_echo`(t≈188)가 `arc_36_night_doubt` 창 꼬리와 겹친다.
- 대표 A/B 경로 실주행으로 부활 32건의 실제 발화 시점·중복 발화 0을 계측하고, 장별 분포
  (현재 설계상 1장 6 / 2장 13 / 3장 13 / 4장 4 / 5장 1)를 기록한다. 4·5장이 얇은 것은 그 구간의
  회수를 이미 `arc_final_week` dik 19변주·엔딩 코다가 수행하기 때문이며, 부족하면 후속에서 보강한다.
- EN 오버레이 동시 수리분 커버리지 확인.

## 합성 판정 원문 (리듬·리스크)

**리듬:** 32건이 맞다. "240주 ÷ 25~40건 = 6~10주에 한 번"이라는 전제는 배선한 콜백이 한 런에서 전부 발화한다고 가정하는데, 실제로는 그렇지 않다. 32건 중 상당수가 같은 생산자의 배타 분기다 — arc_father_medication[1]↔[2], arc_father_03_hospital[0]↔[2], arc_daeun_money_gap[1]↔[2], arc_jaehyuk_04b_counter[1]↔[2], amb_hoesik_00[1]↔dodge[1], 그리고 다은 경로 7건(supportive/deferred/daily_life/breakup_begged/married/gangnam_first/gangnam_eve)은 close_bond·together_path·apart_path 중 하나만 타므로 한 런에 3건 안팎만 성립한다. 한 런의 실제 발화는 14~18건, 즉 13~17주에 한 번이다. 이게 정확히 옳은 밀도다. 이 게임의 회수는 "늦은 청구서"여야 하고 분기당 8~16주를 두라는 기준 자체가 한 런에서 6주 간격을 만들 수 없게 되어 있다. 게다가 이 32건은 기존에 이미 도달 가능한 콜백 24건과 레포에 살아 있는 deferred

**리스크:** 1) 아크 슬롯 잠식이 최대 위험이다. MainGame.gd:2749~2754에서 deferred는 아크 픽커의 거의 맨 앞에 있고, 발화하면 `return ""`로 그 주의 아크를 통째로 가져간다. 레포에 이미 81건의 deferred가 살아 있는데 여기에 37개 배선 행이 얹힌다. 대부분의 아크는 하한(t>=N)만 있어 밀려도 다음 주에 다시 잡히지만, 상한이 있는 아크는 영구 유실될 수 있다 — arc_36_body_signal(163~172), arc_year_three_half(168~184), arc_36_night_doubt(180~187), arc_36_unexpected_hand(156~188), arc_y3_cost_of_knowing(137~160), arc_y3_jiyeon_departure(110~135), arc_endgame_sixmonths(216~237), arc_daeun_money_gap(60~70). 이 중 실제 노출 구간은 callback_chose_money_father_echo(t≈188)가 arc_36_night_doubt 창의 꼬리와 겹치는 지점 하나다. callback_ignored_body_echo를 뺀 이유가 바로 이 구간이다. 병합 전 반드시 `python3 tools/arc_flow_sim.py`로 상한 있는 아크 8종의 도달률 회귀를 확인해야 한다.

2) 조건 재검사 없음. EventManager.trigger_event_by_id(EventManager.gd:718)는 DataRegistry.find_event → queue_event만 하고 conditions를 보지 않는다. 즉 min_turn·flag·no_flag·has_job이 예약 경로에서 전부 무효다. 이 표는 그 사실을 delay 값으로 흡수했다 — 아버지 계열 4건은 father_passed(t>=176) 이전 착지를, 회식 계열 2건은 has_job 무효화를 산문 수정으로 각각 처리했다. 향후 누가 생산자의 스케줄러 게이트를 바꾸면 이 안전 마진이 조용히 깨진다.

3) 교체 배선 3건(arc_sangchul_reckoning[2], arc_jaehyuk_04b_counter[1], arc_jaehyuk_04b_counter[2])은 기존 deferred 값을 삭제한다. 엔진이 GameState.gd:1093에서 단일 String만 읽으므로 한 선택지에 두 예약은 물리적으로 불가능하다(
