# 2장 수첩 반복·5장 "5년" 앞당김 — 적용 대기 초안 (2026-10-03 Claude)

> 부모: [PROSE_REVISION_CH2.md](PROSE_REVISION_CH2.md) F8, [PROSE_REVISION_CH5.md](PROSE_REVISION_CH5.md) F8.
> 이 문서는 **콘텐츠 파일을 건드리지 않은 초안**이다. Codex가 PR #31 들이기를 하는 동안 충돌을 피하려고
> 문서로만 남긴다. 적용은 Codex가 들이기를 끝낸 뒤 한 배치로 한다(KO/EN은 아래 문장, JA/zh는
> `full_game_localization.py export → check → import --accept`, 원장 영수증, 등급 목록 지문).
> 플래그·효과·조건·라우팅·배경·초상은 바꾸지 않는다. 문단 수는 변형마다 그대로 둔다(`scene_audio_contract_check`).

## 결론

1. **2장 수첩 반복은 두 장면만 고친다.** "페이지를 칸으로 나눠 제목을 적는" 몸짓은 1장 마감
   (`arc_year1_close`, `arc_y1_close_hyunsu_call`)에만 남긴다. 수첩이라는 사물 자체는 프롤로그부터 이어지는
   모티프라 지우지 않는다. 반복이 문제인 것은 사물이 아니라 같은 몸짓이다.
   - `arc_year_one_mark`(새해, 1장 마감 바로 뒤): 빈 공책의 두 제목 → **통장 거래내역 출력지의 입금 줄 옆에 이름을 적는 일**.
   - `arc_year2_close`(2장 마감): 책상 위 수첩 세 칸 → **귀갓길 골목 가로등 아래, 은행 명세표 뒷면**.
     이 장면의 배경(`year2_winter_street_night` = 눈 내린 주택가 골목, `scene_direction_manifest`도 outdoor·snow)과
     본문("책상 위를 비우고")이 지금 어긋나 있다. 장소를 배경에 맞추는 수리이기도 하다.
2. **3~5년 마감은 고치지 않는다.** `arc_year3_close`는 한강 난간·휴대폰 서류라 겹치지 않는다. `arc_year4_close`는
   수첩을 들고 옥상에 오르지만 칸을 나누지 않는다(회수로 읽힌다). `arc_final_year_start`도 빈 페이지 한 장뿐이다.
   다만 4장 `arc_year_three_half`의 "자를 대고 세 줄을 그었다. 약속, 몸, 가족"은 같은 몸짓이다. 4장 결산 구조를
   그대로 읽게 하는 장치라 이번 초안에서는 두고, 4장 지시서 쪽 판단으로 남긴다.
3. **5장 "5년"은 숫자를 빼고 사물로 바꾼다.** "네 해"로 고치면 t193~240 사이 어느 시점에 뜨느냐에 따라 또
   틀린다. 대신 "고시원 시절", "고시원 주방", "그 편의점 카운터"처럼 플레이어가 실제로 겪은 장면을 가리킨다.
4. **추가로 찾은 사실 결함(같은 배치에서 고친다):** `hyunsu_year5_call` 두 변형의 첫 줄 "막판이었다. 강남까지
   정말 얼마 안 남았다."는 자산 조건 없이(t≥200·`hyunsu_year4_echo_seen`만) 뜬다. 중앙값 런(수천만~1억대)에서
   거짓이다. 선택2 결과의 "곧, 정말 곧이었다."도 같다. 시간 사실("마지막 해")로 바꾼다.

---

## 지시서와의 관계

- CH2 지시서 51행(`year_one_mark` 선택2 끝 R1 삭제)과 104행(`year2_close` 본문 끝 논설 삭제, 변형 끝을 사물 하나로)을
  이 초안이 함께 반영한다. 변형 끝의 "…책임져야 했다", "선을 안다는 것과…", "어느 칸을 먼저 쓰든…" 계열은 모두 지웠다.
- 104행의 "결과 셋은 유지"는 사물이 바뀌므로 그대로 둘 수 없다. 대신 같은 이미지로 옮겼다: 접힌 모서리 → 반으로 접은
  명세표와 배어 나온 볼펜 자국, 검은 유리의 잔상 → 그대로.
- F8 수리 칸의 "`year_one_mark`는 달력의 연락 한 칸만"과 다르게, 선택1을 거래내역 출력지에 이름을 적는 일로 남겼다.
  선택1은 `keeps_records`를 세우고 `callback_keeps_records_echo`("1년치 기록을 정리하며")가 읽는다. 달력 한 칸만 남기면
  이 독자가 받을 장면이 없다. 칸 나누기가 아니라 기존 기록 옆에 이름을 다는 다른 몸짓이라 반복이 되지 않는다.

## A. `arc_year_one_mark` (`content/events/arc_midgame.json`)

제목 "첫해 장부" / "The First-Year Ledger"는 유지한다(장부는 비유로 남는다). 선택3과 모든 flags·effects·
`follow_up_event`는 그대로다. `callback_keeps_records_echo`("1년치 기록을 정리하며")와도 맞는다.

### description (3문단 유지)

KO:
> 새해 첫날 자정이 지난 뒤, {name}은 지금 사는 방의 책상에 첫해 통장 거래내역 출력지와 달력, 대화 목록을 펼쳤다. 합계만 보면 한 줄이었다. 그러나 입금 줄마다 날짜 옆에 새벽과 마감이 있었고, 몇 줄 옆에는 먼저 손을 내민 사람의 얼굴이 떠올랐다. 기다리게 한 사람의 이름은 어느 줄에도 찍혀 있지 않았다.
>
> {name}은 연필 끝으로 출력지의 첫 입금 줄을 짚었다. 아직 어느 줄 옆에도 이름을 적지 않았다. 대화 목록은 마지막으로 연락한 날짜순으로 정렬돼 있었다.
>
> 새해 달력의 첫 주는 아직 비어 있었다. 먼저 연락할 사람 한 명과 연락할 시각 하나를 새로 적을 자리가 남아 있었다.

EN:
> After midnight on New Year's Day, {name} spreads the printed first-year bank statement, the calendar, and his chat list across the desk in his current room. Reduced to a total, the year fits on one line. But beside each deposit are predawn hours and deadlines, and beside a few of them a face comes to mind: someone who reached out first. The names of the people he left waiting appear on no line at all.
>
> {name} rests the tip of a pencil on the first deposit. He has not written a name beside any line yet. The chat list is sorted by the last time he made contact.
>
> The first week of the new calendar is still blank. There is room to write one person he will contact first and one time when he will do it.

### description_memory_if_known

`m4_housing_priority_runway`
- KO: 새해 첫날 자정이 지난 뒤, {name}은 지금 사는 방의 책상에 첫해 거래내역 출력지와 4월의 주거 상담표를 펼쳤다. ‘이사 뒤 쓸 수 있는 현금’에 그어 둔 밑줄이 아직 남아 있었다. 연필 끝으로 입금 줄을 짚어 내려갔지만, 아직 어느 줄 옆에도 이름을 적지 않았다. 방값과 잔액을 같은 화면에 놓자, 새해 첫 주에는 먼저 연락할 사람 한 명과 연락할 시각 하나를 새로 적을 자리만 남아 있었다.
- EN: After midnight on New Year's Day, {name} lays the printed first-year bank statement beside the April housing worksheet. “Cash available after the move” is still underlined. He runs a pencil down the deposits but has not written a name beside any of them yet. With housing costs and the balance on the same screen, the first week of the year has room for one person he will contact first and one time when he will do it.

`m4_housing_priority_privacy`
- KO: 새해 첫날 자정이 지난 뒤, {name}은 첫해 거래내역 출력지 옆에 4월의 주거 상담표를 놓았다. 표에는 ‘소리가 어디서 멈추는가’라는 메모가 남아 있었다. 출력지의 숫자에는 조용한 시간도 사람의 이름도 찍혀 있지 않았다. {name}은 연필을 쥔 채 아직 어느 줄 옆에도 아무것도 적지 않았다. 새해 첫 주 달력에는 먼저 연락할 사람 한 명과 연락할 시각 하나를 새로 적을 자리만 비어 있었다.
- EN: After midnight on New Year's Day, {name} sets the printed first-year bank statement beside the April housing worksheet. The note “Where does the noise stop?” is still there. The statement records neither quiet hours nor anyone's name. Pencil in hand, he has not written anything beside a single line yet. The first week of the year still has room for one person he will contact first and one time when he will do it.

`m4_housing_priority_time`
- KO: 새해 첫날 자정이 지난 뒤, {name}은 첫해 거래내역 출력지와 4월의 주거 상담표를 함께 폈다. ‘왕복 시간’ 칸에 적힌 숫자는 은행 명세에는 없었다. 이동에 쓴 시간과 실제로 떠오르는 이름은 아직 어느 입금 줄 옆에도 옮기지 않은 채, 새해 첫 주에 먼저 연락할 사람과 시각 하나를 적을 자리를 살폈다.
- EN: After midnight on New Year's Day, {name} opens the printed first-year bank statement beside the April housing worksheet. The “Round-trip time” box holds a number absent from every bank record. Without yet copying the travel hours or any name beside a deposit, he looks for room in the first week of the year for one person to contact first and one time to do it.

### choices

선택1 (flags `arc_year_one_mark_seen`, `keeps_records` 유지)
- text KO: 거래내역의 입금 줄마다 그 돈을 열어 준 사람의 이름을 적는다
- text EN: Write beside each deposit the name of whoever opened that door
- result KO: {name}은 첫 입금부터 연필로 짚어 내려갔다. 혼자 납부하고 제출하고 버텨서 받은 돈 옆은 비워 두었다. 누군가 소개하거나 기다려 준 줄 옆에만 실제로 떠오르는 이름을 작게 적었다. 같은 액수라도 이름이 붙은 줄과 붙지 않은 줄은 다르게 읽혔다.\n\n누가 열어 줬는지 확실하지 않은 줄이 몇 개 남았다. 그는 이름을 짐작해 채우지 않고, 그 줄들을 빈 채로 둔 출력지를 접었다.
- result EN: {name} works down from the first deposit with the pencil. Beside the money he earned by paying, filing, and enduring on his own, he leaves the margin empty. Only beside lines where someone introduced him or waited for him does he write, small, a name he can actually place. Equal amounts read differently with a name beside them.\n\nA few lines remain where he cannot be sure who opened the door. He does not fill them with a guess. He folds the statement with those margins still blank.

선택2
- text KO: 숫자 합계만 확정하고, 사람 이름은 출력지 밖에 둔다
- text EN: Settle only the numerical total and leave people's names off the statement
- result KO: {name}은 납부액과 입금액, 남은 잔액만 다시 더해 마지막 장 합계 아래에 자정 시각을 적었다. 사람 이름과 기다린 시간은 계산에서 제외했다. 숫자는 한 번에 맞았다.\n\n그는 대화 목록을 열지 않은 채 출력지를 접어 서랍에 넣었다. 자정 넘은 방에서 서랍 닫히는 소리가 유난히 크게 났다.
- result EN: {name} adds only the payments, deposits, and remaining balance, then records the time after midnight beneath the total on the last page. He excludes people's names and the hours they waited. The figures balance at once.\n\nHe folds the statement into a drawer without opening the chat list. In the room past midnight, the drawer closes louder than it should.

선택3: 변경 없음.

---

## B. `arc_year2_close` (`content/events/arc_year_close.json`)

배경 `year2_winter_street_night`(눈 내린 주택가 골목, 가로등·전봇대)와 초상 `player_cold_snap`에 맞춘다.
제목 "34세의 마지막 밤" 유지. flags(`year2_confident`/`year2_conflicted`)·effects 유지. 3장 `arc_year3_close`의
`year2_confident`·`year2_conflicted` DIK는 수첩을 언급하지 않으므로 그대로 맞는다.

### description (3문단 유지)

KO:
> 두 번째 12월의 마지막 밤, {name}은 귀갓길 골목의 가로등 아래에서 걸음을 멈췄다. 큰길 은행에서 뽑아 온 명세표가 외투 주머니 안에서 구겨져 있었다. 손바닥만 한 종이에는 통장 잔액 한 줄과 날짜, 시각만 찍혀 있었다. 휴대폰에는 올해 총자산 {assets}가 떠 있었고, 달력과 대화창에는 열두 달 동안 실제로 보낸 답장과 잡았다 지운 일정이 날짜순으로 남아 있었다.
>
> 명세표에는 금액만 찍혔다. 누구에게 답했고 누구를 기다리게 했는지는 종이 어디에도 없었다. 뒷면은 비어 있었다. {name}은 안주머니에서 볼펜을 꺼내 종이를 전봇대에 대고 눌렀다. 눈송이 하나가 뒷면에 내려앉아 금방 작은 얼룩이 됐다.
>
> 종이 한 장에 다 적을 수는 없었다. 새해 첫 주 달력에 옮길 일정 하나, 금액 옆에 나란히 둘 이름들, 목표까지 남은 숫자. 볼펜 끝이 명세표 뒷면 위에서 멈춰 있는 사이, 눈이 종이 귀퉁이에 두 송이 더 내려앉았다.

EN:
> On the last night of the second December, {name} stopped under a streetlamp in the alley on his way home. The slip he had printed at the bank on the main road was crumpled in his coat pocket. The palm-sized paper held one line for the account balance, a date, and a time. His phone showed total assets of {assets}, and the calendar and conversations kept twelve months of replies actually sent and appointments made and erased, in date order.
>
> The slip recorded only an amount. Whom he had answered and whom he had kept waiting appeared nowhere on it. The back was blank. {name} took a pen from his inside pocket and pressed the paper against a utility pole. A snowflake landed on the back and quickly became a small stain.
>
> One slip could not hold everything. One appointment to carry into the first week of the new calendar, the names to set beside the amount, the distance left to the target. While the pen tip hovered over the back of the slip, two more snowflakes settled on its corner.

### description_if_known (각 변형 문단 수 유지)

`y2_lease_renewed_one_year` (1문단)
- KO: 두 번째 12월의 마지막 밤, {name}은 귀갓길 골목의 가로등 아래에서 휴대폰에 저장해 둔 일 년 갱신서 사진을 열었다. 오른 월세는 매달 빠져나갔고 주소는 그대로 남았다. 주머니 속 명세표의 잔액 한 줄 뒤에는 한 번의 서명이 열두 달의 비용이 된 기록이 겹쳐 있었다. 화면 위로 눈이 내려앉아 다음 납부일 숫자 위에서 녹았다.
- EN: On the last night of the second December, under a streetlamp in the alley on his way home, {name} opened the photo of the one-year renewal saved on his phone. The higher rent had left every month and the address had remained. Behind the single balance line on the slip in his pocket sat a record of how one signature had become twelve months of cost. Snow landed on the screen and melted over the next payment date.

`y2_lease_renewed_six_months` (1문단)
- KO: 두 번째 12월의 마지막 밤, {name}은 귀갓길 골목의 가로등 아래에서 여섯 달 갱신서 사진을 열었다. 보증금에 더 묶인 100만원과 가까워진 종료일이 같은 화면에 있었다. 주머니 속 명세표의 잔액에는 그 100만원이 빠져 있었다. 접힌 명세표 모서리가 주머니 안에서 손가락 끝에 걸렸다.
- EN: On the last night of the second December, under a streetlamp in the alley on his way home, {name} opened the photo of the six-month renewal. The extra 1,000,000 won locked in the deposit and the nearer end date shared one screen. The balance on the slip in his pocket did not include that million. Inside the pocket, the slip's folded corner caught against his fingertip.

`y2_lease_move_out_scheduled` (1문단)
- KO: 두 번째 12월의 마지막 밤, {name}은 귀갓길 골목의 가로등 아래에서 서명하지 않은 갱신서 사진과 퇴실 점검 날짜가 적힌 달력을 번갈아 열었다. 오른 월세는 피했지만 지금 주소의 끝과 다음 방을 찾을 기한이 남았다. 퇴실 날짜 칸 위에 눈이 한 송이 내려앉았다가 녹았다.
- EN: On the last night of the second December, under a streetlamp in the alley on his way home, {name} switched between the photo of the unsigned renewal and the calendar bearing the move-out inspection. He had avoided the higher rent but fixed the end of this address and a deadline to find the next room. A snowflake settled on the move-out date and melted.

`year1_resolve` (2문단)
- KO: 두 번째 12월의 마지막 밤, {name}은 귀갓길 골목의 가로등 아래에서 명세표를 꺼내 들고, 지난해 수첩 마지막 장에 적었던 문장을 떠올렸다. 얻은 것과 내준 것을 같은 장에 쓰겠다는 규칙이었다. 올해의 달력에는 끝낸 날짜와 미룬 날짜가 함께 남았고, 휴대폰의 총자산 {assets}는 그중 돈으로 바뀐 것만 정확히 셌다.\n\n{name}은 올해를 깨끗하게 정리하지 않았다. 이름으로 시작하는 일을 금액 아래로 밀지도, 빈칸을 다른 성과로 채우지도 않았다. 명세표를 전봇대에 대고 볼펜을 눌렀다. 얇은 종이가 전봇대의 거친 결을 따라 우툴두툴해졌다.
- EN: On the last night of the second December, under a streetlamp in the alley on his way home, {name} took out the bank slip and remembered the sentence on the last page of last year's notebook: keep what was gained and what was surrendered on the same page. This year's calendar held completed dates beside postponed ones. The total assets of {assets} on the phone counted only what had become money.\n\n{name} did not tidy the year up. He did not push things that began with names beneath the figures or fill blank spaces with some other success. He pressed the slip against the utility pole and set the pen to it. The thin paper took on the rough grain of the pole.

`year1_numb` (2문단)
- KO: 두 번째 12월의 마지막 밤, {name}은 귀갓길 골목의 가로등 아래에서 명세표를 한참 들고 서 있었다. 지난해 수첩의 마지막 장은 비워 둔 채였다. 잔액, 휴대폰의 총자산 {assets}, 답장을 보낸 시각, 끝내 지운 일정. 기록은 있었지만 그것들을 한 문장으로 부를 말은 없었다.\n\n휴대폰 알림을 모두 지우면 화면은 깨끗해질 수 있었다. 명세표를 구겨 버리면 빈칸도 보이지 않았다. 그래도 손은 명세표를 구기지 않았다. {name}은 볼펜 뚜껑을 열었다 닫았다. 딸깍 소리가 빈 골목에서 두 번 났다.
- EN: On the last night of the second December, {name} stood under a streetlamp in the alley on his way home, holding the bank slip for a long time. The last page of last year's notebook had been left blank. The balance. Total assets of {assets} on the phone. Times when replies were sent. Appointments eventually erased. There were records, but no sentence that held them together.\n\nDeleting every notification would leave a clean screen. Crumpling the slip would hide every blank. Still, his hand did not crumple the slip. {name} uncapped the pen and capped it again. The click sounded twice in the empty alley.

`jaehyuk_stood_up` (2문단)
- KO: 두 번째 12월의 마지막 밤, {name}은 귀갓길 골목의 가로등 아래에서 휴대폰의 재혁 이름을 지나 올해 총자산 {assets}를 열었다. 다시 일어선 뒤에도 숫자는 이어졌지만, 사람을 믿기 전의 자신으로 돌아가지는 못했다. 그 사실은 주머니 속 명세표 어느 줄에도 찍히지 않았다.\n\n다시 믿을 일, 먼저 갚을 일, 내년에도 지킬 사람. 셋은 명세표 한 장 뒷면에 나란히 들어가지 않았다. {name}은 명세표를 쥔 채 가로등 불빛 속으로 떨어지는 눈을 오래 봤다.
- EN: On the last night of the second December, under a streetlamp in the alley on his way home, {name} passed Jaehyuk's name in the phone and opened the year's total assets of {assets}. The figures had continued after he stood up again. He had not, however, returned to the self who trusted before the fall. No line on the slip in his pocket recorded that.\n\nWhat to trust again. What to repay first. Who to keep next year. The three would not fit side by side on the back of one slip. {name} held it and watched snow fall through the lamplight for a long time.

`chose_money_over_father` (2문단)
- KO: 두 번째 12월의 마지막 밤, {name}은 귀갓길 골목의 가로등 아래에서 올해 돈을 먼저 고른 날의 시각을 휴대폰 기록에서 찾았다. 그 선택으로 지킨 것도 있었고, 같은 시간에 답하지 못한 이름도 있었다. 총자산 {assets}는 앞쪽만 셌다. 주머니 속 명세표도 마찬가지였다.\n\n잘못이었다고 한 줄로 지우면 그날 실제로 지킨 일을 거짓말로 만들어야 했다. 옳았다고 쓰면 답하지 않은 시간을 또 지워야 했다. {name}은 그날의 시각이 뜬 화면을 끄지 않은 채 휴대폰을 주머니에 넣었다. 외투 천 사이로 불빛이 한동안 새어 나왔다.
- EN: On the last night of the second December, under a streetlamp in the alley on his way home, {name} found the time stamp from the day he had chosen money first. Something real had been kept by that choice; at the same hour, a name had gone unanswered. Total assets of {assets} counted only the first. So did the slip in his pocket.\n\nCalling it wrong in one line would turn what he had actually protected into a lie. Calling it right would erase the unanswered time again. {name} put the phone in his pocket without turning off the screen that showed that day's time. For a while its light leaked through the cloth of his coat.

`crossed_line` (2문단)
- KO: 두 번째 12월의 마지막 밤, {name}은 귀갓길 골목의 가로등 아래에서 올해 선을 넘은 날의 금액을 다시 확인했다. 숫자는 정확했고, 선 자체는 어느 화면에도, 주머니 속 명세표에도 표시되지 않았다. 그 뒤에도 수입과 지출, 약속과 취소는 평소처럼 이어졌다. 아무 일도 멈추지 않았다는 사실이 그 선택을 작게 보이게 했다.\n\n총자산 {assets}. {name}은 명세표 뒷면에 ‘다음에는 멈출 시각’이라고 쓰려다 볼펜을 멈췄다. 종이에는 ‘다음에는’ 세 글자만 남았다.
- EN: On the last night of the second December, under a streetlamp in the alley on his way home, {name} checked the amount from the day he crossed a line. The number was exact. The line itself appeared on no screen and not on the slip in his pocket. Income and spending, promises and cancellations had continued as usual afterward. Nothing stopping had made the choice look smaller than it was.\n\nTotal assets: {assets}. {name} started to write "The time I will stop next time" on the back of the slip, then stopped the pen. Only "Next time" remained on the paper.

### choices

선택1 (`year2_confident`)
- text KO: 새해 첫 주 달력에 지킬 일정 하나를 옮긴다
- text EN: Carry one appointment he will keep into the first week of the new calendar
- result KO: {name}은 전봇대에 등을 기대고 대화 목록에서 아직 다시 연락할 수 있는 이름 하나를 골랐다. 새해 첫 주의 빈칸에 날짜와 시각을 넣고, 메모란에 ‘먼저 확인하고 도착한다’라고 썼다.\n\n명세표는 접어 지갑에 넣었다. 잔액은 그대로였지만, 새해 달력의 첫 칸에는 금액 대신 자신이 먼저 지켜야 할 시각이 남았다.
- result EN: {name} leaned against the utility pole and chose, from his conversations, one person he could still contact. He entered a date and time in the first open week, then typed in the note field: Confirm first, then arrive.\n\nHe folded the slip into his wallet. The balance had not moved, but the first space of the new calendar held a time he had to keep before it held an amount.

선택2 (`year2_conflicted`)
- text KO: 명세표 뒷면에 돈과 사람에게 쓴 값을 함께 적는다
- text EN: Write the cost to money and the cost to people on the back of the slip
- result KO: {name}은 명세표를 전봇대에 대고 눌러, 잔액이 찍힌 면의 뒤쪽에 답장·방문·기다림에 쓴 시간을 옮겼다. 달력과 대화창에서 확인할 수 있는 것만 쓰고, 기억나지 않는 것은 가로줄로 남겼다.\n\n앞면의 숫자와 뒷면의 시간은 하나의 합계가 되지 않았다. {name}은 종이를 반으로 접어 안주머니에 넣었다. 볼펜을 세게 누른 자국이 앞면의 잔액 위로 희미하게 배어 나와 있었다.
- result EN: {name} pressed the slip against the utility pole and, on the back of the printed balance, copied the time spent replying, visiting, and waiting. He wrote only what the calendar and conversations could prove and left a short line where he could not remember.\n\nThe amount on the front and the hours on the back did not become one total. {name} folded the paper in half and slid it into his inside pocket. Where he had pressed hard, the pen's marks showed faintly through, over the balance.

선택3 (flags `arc_year2_close_seen`만)
- text KO: 다른 것은 닫고 목표까지 남은 숫자만 본다
- text EN: Close everything else and look only at the distance left to the target
- result KO: {name}은 달력과 대화창을 닫고 휴대폰의 목표 화면만 열었다. 현재 총자산, 남은 금액, 남은 달. 이름을 넣지 않으니 세 줄이면 충분했다.\n\n명세표는 구겨 주머니 깊숙이 넣었다. 화면이 꺼진 뒤에도 마지막 숫자의 잔상이 검은 유리에 남았다. {name}은 휴대폰을 뒤집어 주머니에 넣고 다시 꺼내지 않았다.
- result EN: {name} closed the calendar and the conversations and opened only the target screen: current assets, amount remaining, months left. Without names, three lines were enough.\n\nHe crumpled the slip deep into his pocket. Even after the display went dark, the last figure lingered in the black glass. {name} put the phone away facedown and did not take it out again.

---

## C. 5장 "5년" (CH5 F8)

### `hyunsu_year5_call`, `hyunsu_year5_call_father_passed` (`content/events/arc_hyunsu.json`)

| 위치 | 지금 | KO 초안 | EN 초안 |
|---|---|---|---|
| title (두 이벤트) | 5년의 끝에서 온 전화 / A Call at the End of Five Years | 마지막 해에 온 전화 | A Call in the Final Year |
| 모든 본문·DIK 첫 문단 | 막판이었다. 강남까지 정말 얼마 안 남았다. / The home stretch. Gangnam was genuinely close now. | 마지막 해였다. 휴대폰 목표 화면의 남은 주가 눈에 띄게 줄어 있었다. | The final year. The weeks left on his phone's target screen had visibly dwindled. |
| 본문·`called_hyunsu_first` | 5년이 거기 있었다. / Five years were in it. | 고시원 시절부터의 시간이 거기 있었다. | All the time since the goshiwon was in it. |
| `crossed_line` (두 이벤트) | 5년 전 새벽 주방에서 같이 컵라면 먹던 그 사람이 / The guy he'd shared cup ramyeon with in that dawn kitchen five years ago | 고시원 시절 새벽 주방에서 같이 컵라면 먹던 그 사람이 | The guy he'd shared cup ramyeon with in that dawn goshiwon kitchen |
| 선택2 결과 (두 이벤트) | 곧, 정말 곧이었다. … 5년 전 주방의 그 얼굴 같았다. / Soon. Really, soon. … from that kitchen, five years ago. | 곧이라고 말한 건 자기였다. … 고시원 주방의 그 얼굴 같았다. | He was the one who had said soon. … like the one from that goshiwon kitchen. |

선택2 텍스트 "곧 좋은 소식 있을 거야"는 민준의 말이라 허세일 수 있어 그대로 둔다. 결과문이 그 말을 사실처럼 받지만 않으면 된다.
`hyunsu_year5_call_father_passed` 기본 본문은 첫 문단만 바꾼다.

### `arc_daeun_year5_apart` (`content/events/arc_daeun_extension.json`)

- KO: "5년 전 편의점 카운터 앞에서" → "그 편의점 카운터 앞에서"
- EN: "across a convenience-store counter five years ago" → "across that convenience-store counter, years ago"

### `arc_daeun_year5_ending` (`content/events/arc_daeun_extension.json`, "5년" 줄만)

이 장면 전체 재작성(CH5 배치 1 판정)은 별도다. 이번에는 사실이 틀린 줄만 바꾼다. t≥193·자산 29억 이상이면
언제든 뜨므로 숫자 대신 첫 만남의 장소를 가리킨다.

| 위치 | KO 초안 | EN 초안 |
|---|---|---|
| 기본 "5년을 같은 도시에서 버틴 사람." | 첫해부터 같은 도시에서 버틴 사람. | Someone who'd held on in the same city since that first year. |
| 기본·`daeun_year4_close`·`daeun_romance_started` "5년이 이 저녁에 있었다." | 편의점 카운터에서 시작된 시간이 이 저녁에 있었다. | Everything since that convenience-store counter was in this dinner. |
| `daeun_married` "5년이, 그리고 앞으로의 평생이 — 이 저녁 하나에 다 있었다." | 편의점 카운터에서 시작된 시간과 앞으로의 평생이 — 이 저녁 하나에 다 있었다. | Everything since that convenience-store counter — and every year still to come — all of it in this one dinner. |
| `daeun_married` "작년에 {name}이 끼워준 것." | {name}이 끼워 준 것. | He'd put it there. |

`daeun_married`의 "작년에"는 결혼 시점이 경로마다 달라 확정할 수 없다. `daeun_year4_close`의 "4년 전 그 카페 약속"은
`arc_romance_y5`의 "4년 늦은 대답"과 맞으므로 그대로 둔다.

---

## 적용 체크리스트 (Codex)

1. KO/EN 위 문장 반영. 문단 수를 변형별로 대조한다.
2. JA/zh: 바뀐 잎만 `--leaf-ids`로 export → check → import `--accept`. 원장 `accepted`·`accepted_sha256` 갱신.
3. `release_content_inventory.py`: 해당 corpus·축 지문만 갱신 후 `--write-report`(문장에 "불안"·"빚" 등 축 검색어가 새로 들고 나는지 확인).
4. 검사: `narrative_continuity`(420자 하한), `scene_audio_contract_check`, `speech_register`, `en_coverage_check`,
   `english_hangul`, `context_manifest_check`, `audit_select`.
5. 화면: `arc_year2_close` KO/EN을 `year2_winter_street_night` 배경 위에서 한 번 본다(장소 정합이 이 수리의 목적이다).
