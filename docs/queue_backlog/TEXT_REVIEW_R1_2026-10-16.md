# 텍스트 검토 R1 — 정점 장면의 "검수 문장" 걷어내기 (2026-10-16, Claude)

> 사용자 지시(2026-10-16): Claude는 문장·문맥·개연성·스토리 품질 등 텍스트만 계속 검토한다.
> 이 문서는 그 1회차 결과다. 적용은 Codex가 하며, **화면이 필요 없는 작업**이므로
> 사용자 테스트 앱 실행 중에도 진행할 수 있다.
> 범위: 산문·선택지 문구·결과 문구만. gameplay key·flags·effects·조건·이벤트 id는 바꾸지 않는다.

## 0. 진단 — 검수 규칙이 문장 안으로 새고 있다

산문이 "없는 사실을 지어내지 마라", "다른 인물이 대신 결정하지 마라", "영수증/정확한 사실을 남겨라" 같은
**검수 규칙을 지키는 수준을 넘어 규칙 자체를 플레이어에게 낭독**하고 있다.

예시 (실제 출시 문장):

- "방을 열 수 있다는 사실은 관계가 이어졌거나 회복됐다는 증명이 아니었다." (`arc_final_week`)
- "마지막 장의 빈 줄은 수첩 종이일 뿐이었다. 계약서도 접수본도 아니었고, 도장이나 접수번호가 생길 자리도 아니었다." (`arc_final_countdown`)
- "생존도 사망도, 이후 경과도 아직 확정되지 않았다." (`arc_y4_father_crisis_contact`)
- "그 기록으로 이 방에 파트너를 새로 만들거나 결정을 위임할 수는 없었다." (`arc_y4_bill_night_unattached`)

측정 (출시 대상 1,702건, author_only 제외):

| 패턴 | 건수 | 사건 수 |
|---|---:|---:|
| `실제로` (메시지·사람·이름 수식) | 82 | 56 |
| `확인되지 않` | 14 | 12 |
| `…만으로 … 않았/없었` | 12 | 8 |
| `자동으로` | 10 | 10 |
| `대신 (결정·처리·정하·누르)` | 8 | 6 |
| `미확인` / `기록이 남` | 5 / 5 | 5 / 5 |
| 하나라도 해당 | — | **81** |

몰린 곳이 문제다. 상위 사건이 `arc_y4_bill_night`(8), `arc_final_week`(6), `arc_year1_close`(5),
`arc_final_countdown`(5), `arc_y4_father_crisis_contact`(5)로, **모두 이 게임에서 감정이 가장 높아야 할 장면**이다.

### 작성 규칙 (SCENE_TIER 공통계약에 한 줄 추가 권고)

> **규칙은 무엇을 쓰지 않을지를 정한다. 규칙을 문장으로 쓰지 않는다.**
> 일어나지 않은 일은 말하지 않고 비워 둔다. "~을 증명하지/결정하지/대신하지 않았다",
> "확정되지 않았다", "~만으로는 ~않았다"로 단락을 닫지 않는다.
> 메시지·사람·대화 앞에 `실제(로)`를 붙이지 않는다. 사람의 순간에 `창구·항목·기록·미확인`을 쓰지 않는다.
> 대신: **일어난 행동 한 줄 + 지금 장면의 감각 하나**로 닫는다. 나머지는 플레이어가 읽는다.

새 검사 도구는 만들지 않는다(DECISIONS 2026-10-08). 위 패턴 표를 수동 grep 체크리스트로만 쓴다.

---

## 1. `arc_final_week` (content/events/arc_drama.json + events_en)

### 1-A. 공통 본문 (base·`final_signature_owned/collateral/people` 네 변형에서 2~6단락이 같다)

**첫 단락 변형별 마지막 문장만 교체**

| 키 | 현재 (삭제) | 교체 KO | 교체 EN |
|---|---|---|---|
| base | (유지) | — | — |
| owned | "책임을 자기 몫으로 둔 줄은 남았지만, 그 서명이 빚을 갚거나 관계를 되돌리지는 않았다." | "표지 너머로 잉크 냄새가 조금 남았다." | "A faint smell of ink stayed on the cover." |
| collateral | "화살표는 정확했지만, 계산이 줄인 목소리나 멀어진 관계를 되돌리지는 않았다." | "화살표들은 모두 한 방향을 가리키고 있었다." | "Every arrow pointed the same way." |
| people | "그 순서는 사람을 지우지 않았지만, 떠난 사람을 돌아오게 하거나 관계를 회복시키지는 않았다." | "맨 아래 줄에 자기 이름이 있었다." | "His own name sat on the bottom line." |

(owned·people 첫 문장의 "자기 이름이 마른 수첩" / "실제로 적혀 있던 이름을 먼저 옮긴 수첩"은 각각 "자기 이름이 마른 수첩" 유지 / "이름들을 먼저 옮겨 적은 수첩"으로.)

**2~6단락 → 아래 3단락으로 교체 (네 변형 공통)**

KO:

```
휴대폰을 켜자 대화 목록이 떴다. {name}은 엄지로 천천히 내리다가 한 사람의 이름에서 멈췄다. 마지막 말풍선은 몇 주 전 것이었고, 그 아래로는 아무것도 오지 않았다.

밥 한 끼를 청할 수도, 미뤄 둔 사과를 먼저 보낼 수도, 오늘은 혼자 있겠다고 말할 수도 있었다. 어느 쪽이든 답은 저쪽에서 올 것이었다. 혹은 오지 않을 것이었다.

빈 입력 칸에서 커서가 깜빡였다. 충전선이 책상 가장자리에 걸려 있었다. {name}은 휴대폰을 두 손으로 감싸 쥐었다.
```

EN:

```
He turned on the phone and the conversation list came up. {name} scrolled slowly with his thumb and stopped at one name. The last bubble was weeks old, and nothing had come after it.

He could ask for a meal, send the apology he had put off, or say he needed to be alone tonight. Whichever he chose, the answer would come from the other side. Or it wouldn't.

The cursor blinked in the empty box. The charging cable hung off the edge of the desk. {name} held the phone in both hands.
```

> "몇 주 전"이 경로상 틀릴 수 있으면(최근까지 대화한 경로) "마지막 말풍선 아래로는 아무것도 오지 않았다."로 줄인다.

### 1-B. 선택지 문구

| # | 현재 | 교체 KO | 교체 EN |
|---|---|---|---|
| 0 | 다섯 해 전의 내가 지금의 나에게 ‘잘했다’고 말하는 장면을 떠올리고, 그 사람에게 다음 주 밥을 제안한다 | ‘잘 버텼다’고 스스로에게 말한 뒤, 다음 주 밥을 먼저 청한다 | Tell yourself "you held on," then ask them to eat together next week |
| 1 | (유지 가능) 다음 주를 부탁하기 전에, 미뤄 둔 사과를 먼저 보낸다 | 유지 | 유지 |
| 2 | 포기하지 않은 것이 다행이라고 스스로 답하고, 오늘 필요한 거리와 다음 연락 시각을 보낸다 | 오늘은 혼자 있겠다고, 내일 여덟 시에 먼저 연락하겠다고 보낸다 | Say you need tonight alone, and that you'll reach out tomorrow at eight |

### 1-C. 결과 문구

**(0)** KO:

```
보내기 전에 {name}은 다섯 해 전의 자신을 떠올렸다. 통장에 50만원이 있던 사람. 그 사람이라면 아마 이렇게 말했을 것이다. "잘했다. 여기까지 버텼네."

{name}은 그 말을 지우지 않았다. 그리고 그 아래에, 다음 주에 밥 한 끼 같이 할 수 있는 날이 있는지 물었다.

전송을 누르자 말풍선 옆에 작은 시각이 찍혔다. 숫자 1은 한참 동안 지워지지 않았다.
```

EN:

```
Before sending, {name} thought of himself five years ago. The man with 500,000 won in the bank. He would probably have said: "Good. You held on this far."

{name} didn't delete that. Below it, he asked whether there was a day next week they could eat together.

He pressed send, and a small timestamp appeared beside the bubble. The unread mark stayed for a long time.
```

**(1)** KO:

```
{name}은 무엇을 잘못했는지부터 한 문장으로 적었다. 늦은 이유는 붙이지 않았다. 지금 무엇을 이뤘는지도 쓰지 않았다. 사과 뒤에 서는 말은 변명이 됐다.

마지막 줄에는 답하지 않아도 괜찮다고 썼다. 그 줄을 두 번 지웠다가 다시 썼다.

전송을 누른 뒤 {name}은 휴대폰을 엎어 두었다. 그 위로 스탠드 불빛이 고였다.
```

EN:

```
{name} began with one sentence about what he had done wrong. He didn't add why he was late. He didn't mention what he had achieved. Anything that came after an apology became an excuse.

On the last line he wrote that they didn't have to answer. He deleted that line twice and wrote it again.

After pressing send, {name} laid the phone face down. Lamplight pooled on its back.
```

**(2)** KO:

```
여기서 포기했으면 어땠을까. {name}은 스스로 묻고 곧바로 답했다. 포기하지 않아서 다행이다.

그리고 그 사람에게 썼다. 그동안 해 준 말들이 고마웠다고. 오늘은 혼자 있고 싶다고. 내일 저녁 여덟 시에 자기가 먼저 연락하겠다고.

{name}은 휴대폰을 충전선에 꽂고 불을 껐다. 어둠 속에서 충전 표시등이 초록색으로 바뀌었다. 내일 여덟 시는 그의 몫이었다.
```

EN:

```
What if he had given up here? {name} asked himself, and answered at once. Good thing I didn't.

Then he wrote to them. That he was grateful for everything they'd said. That he wanted to be alone tonight. That he would reach out first, tomorrow at eight in the evening.

{name} plugged in the phone and turned off the light. In the dark, the charging light turned green. Eight o'clock tomorrow was his to keep.
```

> 플래그·효과·`final_*` 변형(“38세 생일이 7일 남았다” 계열)은 이번 회차에서 손대지 않는다. 그 계열은 R2에서 반복 도입부(6변형 동일 5단락)를 다룬다.

---

## 2. `arc_final_countdown` (content/events/arc_pre_ending.json + events_en)

base·`description_if_moral.black/white` 세 본문이 1~5·7~8단락을 공유한다. 공유 단락을 아래로 교체하고, 6단락(세 뜻)은 변형별 추가 문장을 유지한다.

KO (공유부):

```
다섯 해의 마지막 달. 강남의 불빛이 창밖에 걸려 있었고 {name}은 수첩을 편 책상 앞에 혼자 앉아 있었다.

수첩 첫 장에는 시작할 때의 50만원과 목표 30억원이 나란히 적혀 있었다. 자산 화면은 지금 숫자가 그 위인지 아래인지 이미 보여 주고 있었다. {name}은 화면을 엎어 두고 수첩을 넘겼다.

금액과 날짜 사이사이에 이름이 있었다. 빌린 돈, 갚은 돈, 같이 먹은 밥값. 돈은 한 열에서 더해지고 빠졌지만, 이름 옆의 시간은 어느 열에도 들어가지 않았다.

마지막 장에는 빈 줄이 하나 남아 있었다. {name}은 그 줄을 오래 내려다봤다. 거기 쓸 수 있는 말은 셋 중 하나였다. "내가 책임진다." "이름까지 계산한다." "사람부터 남긴다."  ← (black/white는 기존 세 뜻 문구와 변형 추가 문장 유지)

하나를 쓰면 나머지 둘은 쓸 자리가 없었다. 방에는 {name} 혼자였다.

{name}은 검은 펜 끝을 빈 줄 바로 위에 세웠다. 펜 끝에 잉크가 둥글게 맺혔다.
```

EN (shared):

```
The last month of the fifth year. Gangnam's lights hung outside the window, and {name} sat alone at the desk with the notebook open.

The first page held the 500,000 won he had started with and the 3 billion won goal, side by side. The asset screen already showed whether the current number was above or below it. {name} turned the screen face down and leafed through the notebook.

Between the amounts and dates were names. Money borrowed, money repaid, the bill for a meal shared. Money added and subtracted in a single column, but the time beside each name fit in no column at all.

One blank line was left on the last page. {name} looked down at it for a long time. Only one of three things could go there. "I take responsibility." "I count the names too." "People come first."

Writing one left no room for the other two. {name} was alone in the room.

{name} held the tip of the black pen just above the blank line. A round bead of ink formed at the tip.
```

삭제 대상(교체로 사라짐): "닿음도 못 닿음도 지나온 시간을 설명하지는 못했다", "실제로 남은 금액과 날짜, 이름만", "하지 않았던 만남과 받지 않은 답은 빈칸으로 두었다", "계약서도 접수본도 아니었고…", "셋을 모두 고른 척하면…", "대신 서명해 줄 사람도…".

**결과 (0)** KO:

```
{name}은 수첩의 빈 줄에 자기 이름을 천천히 적었다. 오래된 종이가 잉크를 조금씩 빨아들였다.

앞장의 날짜와 이름은 지우지 않았다. 도와준 사람들은 그 자리에 두고, 그 도움으로 고른 길의 책임만 자기 쪽으로 가져왔다.

{name}은 펜을 내려놓고 잉크가 마를 때까지 기다렸다. 창밖의 불빛 몇 개가 그사이 꺼졌다.
```

EN:

```
{name} slowly wrote his own name on the blank line. The old paper drank the ink a little at a time.

He didn't erase the dates and names on the earlier pages. He left the people who had helped him where they were, and took only the responsibility for the path that help had let him choose.

{name} set down the pen and waited for the ink to dry. A few of the lights outside went out in the meantime.
```

**결과 (1)** KO:

```
{name}은 수첩에 적힌 이름들을 수익과 비용의 열로 옮겼다. 이름 옆에 얻은 것과 잃은 것, 빌려 쓴 시간을 적었다.

각 줄 끝의 화살표를 30억 쪽으로 모았다. 서로 다른 사정들이 같은 단위가 되자, 목소리는 숫자 사이에서 작아졌다.

{name}은 마지막 줄에 자기 이름을 크게 썼다. 수첩을 덮자 표지 위로 화살표 자국이 비쳐 보였다.
```

EN:

```
{name} moved the names in the notebook into columns of gain and cost. Beside each name he wrote what he had gained, what he had lost, and the time he had borrowed.

He drew every arrow at the end of every line toward the 3 billion. Once different circumstances became the same unit, the voices grew small between the numbers.

{name} wrote his own name large on the last line. When he closed the notebook, the arrows showed faintly through the cover.
```

**결과 (2)** KO:

```
{name}은 자산 화면을 끄고, 앞장의 이름들을 하나씩 빈 줄 아래로 옮겨 적었다. 이름 하나를 옮길 때마다 그 사람과 마지막으로 나눈 말이 먼저 떠올랐다.

자기 이름은 맨 마지막에 적었다. 혼자 온 길처럼 꾸미지 않는 순서였다.

{name}은 펜을 놓았다. 조용한 휴대폰 옆에서, 이름들이 적힌 페이지가 스탠드 불빛을 받고 있었다.
```

EN:

```
{name} switched off the asset screen and copied the names from the earlier pages, one by one, beneath the blank line. Each time he copied a name, the last words he had shared with that person came to him first.

He wrote his own name last. It was an order that didn't pretend he had come alone.

{name} put down the pen. Beside the silent phone, the page of names caught the lamplight.
```

---

## 3. `arc_y4_father_crisis_contact` (content/events/arc_drama.json + events_en)

**본문** KO:

```
오후 6시 14분, 창원 병동에서 문자가 왔다. 아버지의 호흡이 갑자기 나빠져 산소를 달고 검사에 들어갔다고 했다. 오늘 밤 보호자에게 어떻게 연락하면 되는지 알려 달라는 말과 병동 번호가 적혀 있었다.

서울에서 가장 빠른 창원행 열차를 타면 밤늦게 병실에 닿을 수 있었다. 지금 병동으로 전화하면 간호사가 아버지 귀에 수화기를 대 줄 수 있다는 줄도 있었다.

열차 앱과 병동 번호가 한 화면에 나란히 떠 있었다. {name}의 엄지가 그 사이에서 멈춰 있었다.
```

EN:

```
At 6:14 p.m., a text came from the ward in Changwon. His father's breathing had suddenly worsened; they had put him on oxygen and started tests. The message asked how the family could be reached tonight, and gave the ward's number.

If he caught the fastest train from Seoul to Changwon, he could reach the hospital room late tonight. Another line said that if he called the ward now, a nurse could hold the receiver to his father's ear.

The train app and the ward number sat side by side on the screen. {name}'s thumb hung between them.
```

**결과 (0)** KO:

```
{name}은 7시 2분 창원행 표를 결제했다. 오늘 맡았던 일의 담당자에게는 못 가게 됐다는 문자만 보냈다. 사정은 길게 붙이지 않았다.

병동에는 열차 번호와 도착 예정 시각을 답했다. 확인했다는 짧은 답이 왔다. 역으로 가는 택시 안에서 {name}은 손잡이를 꽉 쥐고 있었다.
```

EN:

```
{name} paid for the 7:02 train to Changwon. To the person expecting him at work today, he sent only a text saying he couldn't make it. He didn't explain at length.

He replied to the ward with the train number and his expected arrival. A short reply came back: received. In the taxi to the station, {name} held the grab handle tight.
```

**결과 (1)** KO (첫 단락 유지, 둘째 단락 교체):

```
{name}은 문자에 적힌 병동 번호를 눌렀다. 간호사는 환자 이름과 보호자 관계를 확인한 뒤 수화기를 옮기겠다고 했다. 카트 바퀴와 커튼 고리 소리가 지나간 다음, 짧은 숨이 연결됐다.

{name}은 아무 말도 하지 못하고 그 숨소리를 들었다. 수화기 너머에서 산소 기계가 일정한 간격으로 쉭, 소리를 냈다.
```

EN:

```
{name} dialed the ward number from the text. The nurse confirmed the patient's name and his relationship, then said she would carry the receiver over. After the sound of cart wheels and curtain rings, a short breath came on the line.

{name} couldn't say anything. He listened to the breathing. On the other end, the oxygen machine hissed at a steady interval.
```

**결과 (2)** KO:

```
{name}은 ‘오늘은 창원에 가거나 통화할 수 없습니다’라고 보냈다. 내일은 꼭 가겠다는 말은 쓰지 않았다. 지킬 수 있을지 몰랐다.

병동에서 확인했다는 짧은 답이 왔다. {name}은 그 한 줄 아래 자기 문장을 오래 내려다봤다. 화면이 저절로 꺼질 때까지 휴대폰을 내려놓지 않았다.
```

EN:

```
{name} sent: "I can't come to Changwon or call today." He didn't write that he'd surely come tomorrow. He didn't know if he could keep that.

A short reply came from the ward: received. {name} stared for a long time at his own sentence above it. He didn't put the phone down until the screen went dark on its own.
```

**기억 문장 `description_memory_if_known` (11키 전부 교체)** — 원칙: 과거 행동 한 줄 + 지금 화면과의 연결 하나. "정하지 않았다/대신 결정하지 않았다"류 전부 삭제.

| 키 | KO | EN |
|---|---|---|
| `arc_y4_bill_chose_payment&called_father_on_ktx` | 병원비를 자정 직전에 보냈던 밤이 있었다. 그보다 앞서, 서울로 올라가던 열차에서 먼저 아버지에게 전화를 건 것도 {name}이었다. 그 통화 기록이 병동 문자 바로 아래에 있었다. | There had been the night he paid the hospital bill just before midnight. Before that, on the train back to Seoul, it was {name} who had called his father first. That call was still in the log, right below the ward's text. |
| `arc_y4_bill_chose_payment&did_not_call_father_on_ktx` | 병원비를 자정 직전에 보냈던 밤이 있었다. 그보다 앞서, 서울로 올라가던 열차에서는 아버지 번호를 띄워 놓고도 누르지 못했다. 엄지가 그때와 같은 자리에서 멈춰 있었다. | There had been the night he paid the hospital bill just before midnight. Before that, on the train back to Seoul, he had brought up his father's number and not pressed it. His thumb had stopped in the same place it had then. |
| `arc_y4_bill_chose_body_care&called_father_on_ktx` | 손 떨림 때문에 자기 몸부터 야간진료에 맡겼던 밤이 있었다. 그보다 앞서, 서울로 올라가던 열차에서 먼저 아버지에게 전화를 건 것도 {name}이었다. 그 통화 기록이 병동 문자 바로 아래에 있었다. | There had been the night his hands shook and he took himself to the night clinic first. Before that, on the train back to Seoul, it was {name} who had called his father first. That call was still in the log, right below the ward's text. |
| `arc_y4_bill_chose_body_care&did_not_call_father_on_ktx` | 손 떨림 때문에 자기 몸부터 야간진료에 맡겼던 밤이 있었다. 그보다 앞서, 서울로 올라가던 열차에서는 아버지 번호를 띄워 놓고도 누르지 못했다. 엄지가 그때와 같은 자리에서 멈춰 있었다. | There had been the night his hands shook and he took himself to the night clinic first. Before that, on the train back to Seoul, he had brought up his father's number and not pressed it. His thumb had stopped in the same place it had then. |
| `arc_y4_bill_chose_father_care&called_father_on_ktx` | 그 밤 {name}은 아버지 병동과 약 목록, 전원 병원, 보호자 연락 순서를 맞춰 두었다. 오늘 문자를 보낸 번호도 그때 받아 적은 번호였다. 서울로 올라가던 열차에서 먼저 전화를 건 기억도 함께 떠올랐다. | That night, {name} had gone over his father's medication list, transfer hospital, and family contact order with the ward. The number texting him now was the one he had written down then. The memory of calling first, on the train back to Seoul, came with it. |
| `arc_y4_bill_chose_father_care&did_not_call_father_on_ktx` | 그 밤 {name}은 아버지 병동과 약 목록, 전원 병원, 보호자 연락 순서를 맞춰 두었다. 오늘 문자를 보낸 번호도 그때 받아 적은 번호였다. 서울로 올라가던 열차에서 끝내 누르지 못한 번호도 함께 떠올랐다. | That night, {name} had gone over his father's medication list, transfer hospital, and family contact order with the ward. The number texting him now was the one he had written down then. So was the number he never pressed on the train back to Seoul. |
| `arc_y4_bill_chose_payment` | 병원비를 자정 직전에 보냈던 밤의 영수증 문자가 아직 문자함 위쪽에 남아 있었다. | The receipt text from the night he paid the hospital bill just before midnight was still near the top of his inbox. |
| `arc_y4_bill_chose_body_care` | 손 떨림 때문에 자기 몸부터 야간진료에 맡겼던 밤이 떠올랐다. 그때 받은 진료 접수 문자가 병동 문자 바로 위에 있었다. | He remembered the night his hands shook and he took himself to the night clinic first. The clinic's check-in text sat right above the ward's message. |
| `arc_y4_bill_chose_father_care` | 그 밤 맞춰 둔 보호자 연락 순서대로, 병동은 {name}에게 가장 먼저 연락했다. | Just as the contact order he had set that night said, the ward reached {name} first. |
| `called_father_on_ktx` | 서울로 올라가던 열차에서 먼저 아버지에게 전화를 걸었던 날의 통화 기록이 병동 문자 바로 아래에 있었다. | The log of the call he had made first, on the train back to Seoul, was right below the ward's text. |
| `did_not_call_father_on_ktx` | 서울로 올라가던 열차에서 아버지 번호를 띄워 놓고도 누르지 못했던 날이 떠올랐다. 엄지가 그때와 같은 자리에서 멈춰 있었다. | He remembered the day on the train back to Seoul when he brought up his father's number and didn't press it. His thumb had stopped in the same place it had then. |

> 열차 출발지 "창원에서 서울로 올라가던"은 원문 그대로 사실이므로 KO에서 "서울로 올라가던"으로 줄여도 같은 장면을 가리킨다. 다른 사건이 출발지를 명시해야 하면 원문을 유지한다.

---

## 4. `arc_y4_bill_night` / `arc_y4_bill_night_unattached` (content/events/arc_chapter_themes.json + events_en)

### 개연성 문제

현재 본문은 병원 원무과의 "납부 창이 11시 59분에 닫히고", 병동이 "11시 50분 한 번만 통화를 연다"고 설명한다.
현실의 병원은 이렇게 움직이지 않는다. **게임의 세 마감을 세계의 규칙처럼 서술한 것**이다.
같은 긴장을 현실적인 장치로 바꾼다: ① 원무과 가상계좌 입금 기한, ② 야간진료 접수 마감, ③ 야간 간호사의 인계 전 보호자 통화 요청.
세 마감 시각(11:50 / 11:59 / 자정), 금액, 선택 결과 구조는 그대로다.

**본문 (attached)** KO:

```
밤 11시 47분. 창원 성심병원 원무과가 보낸 가상계좌의 입금 기한은 오늘 밤 11시 59분이었다. 487,300원. 기한을 넘기면 계좌를 다시 받아야 했다.

{name}의 손끝은 저녁부터 떨리고 있었다. 서울 동부야간진료센터 접수는 자정에 마감이었다. 그리고 아버지 병동의 야간 간호사는 인계 전인 11시 50분에 보호자와 약 목록, 전원 병원, 연락 순서를 맞추자는 문자를 남겨 두었다.

다은은 {name}의 연락을 받고 현관 안에 와 있었다. 그녀는 {name}의 손을 내려다보며 말했다. "민준씨, 손이 떨려요. 지금 할 수 있는 거 하나만 해요."

열두 분. 셋 중 하나만 끝낼 수 있었다.
```

EN:

```
11:47 p.m. The virtual account the billing office at Changwon Sungsim Hospital had sent was due by 11:59 tonight. 487,300 won. Miss it, and he'd have to request a new account.

{name}'s fingertips had been trembling since evening. Seoul East After-Hours Clinic stopped taking patients at midnight. And the night nurse on his father's ward had left a text: at 11:50, before shift change, she wanted to go over the medication list, transfer hospital, and contact order with family.

Daeun had come when he called and was standing just inside the door. She looked down at his hands. "Minjun, your hands are shaking. Just do one thing you can do right now."

Twelve minutes. He could finish only one of the three.
```

**본문 (unattached)** KO — 1·2단락은 위와 같고(다은 문장 제외), 3단락 교체:

```
방 안에는 {name} 혼자였다. 휴대폰 위쪽에 알림 세 개가 겹쳐 떠 있었다. 떨리는 손등이 책상 위 물컵을 한 번 건드렸다.

열두 분이 남아 있었다.
```

EN:

```
{name} was alone in the room. Three notifications were stacked at the top of his phone. The back of his trembling hand knocked the water glass on the desk once.

Twelve minutes were left.
```

**결과 문구 — 두 변형 공통 수정 지점**

| 선택 | 현재 (삭제) | 교체 KO | 교체 EN |
|---|---|---|---|
| 0 attached 둘째 단락 | "서울 야간진료 접수와 11시 50분 병동 조정 통화는 지나갔다. 돈은 도착했지만 … 확인되지 않았다. 다은은 결제 화면을 말없이 들여다봤다." | 그사이 11시 50분 병동 문자에는 답하지 못했고, 야간진료 접수도 지나갔다. 다은은 결제 화면을 말없이 들여다보다가, 떨리는 {name}의 손 위에 자기 손을 잠깐 얹었다. | Meanwhile the 11:50 text from the ward went unanswered, and the night clinic's window passed. Daeun looked at the payment screen without a word, then rested her hand briefly on his trembling one. |
| 0 unattached 둘째 단락 | "서울 야간진료와 병동 조정 통화는 닫혔다. 돈은 도착했지만 … 연결되지 않았다." | 그사이 11시 50분 병동 문자에는 답하지 못했고, 야간진료 접수도 지나갔다. 영수증 번호 아래로 떨리는 손가락이 화면에 자국을 남겼다. | Meanwhile the 11:50 text from the ward went unanswered, and the night clinic's window passed. Below the receipt number, his trembling finger left smudges on the screen. |
| 1 둘째 단락 (두 변형) | "… 아버지 병동의 약·전원·보호자 연결은 미확인으로 남았다." / "… 세 항목은 미확인으로 남았다." | 입금 기한과 병동 문자는 그사이 지나갔다. 진료실 앞 의자에서 {name}은 휴대폰을 뒤집어 무릎 위에 올려 두었다. | The payment deadline and the ward's text passed in the meantime. On the bench outside the exam room, {name} kept his phone face down on his knee. |
| 1 첫 단락 (두 변형) | "떨림 시작 시각과 겹쳐 보인 순간을 직접 말했다" / "떨림 시작 시각과 시야 증상을 직접 말했다" | 떨림이 언제 시작됐는지, 언제 앞이 겹쳐 보였는지 직접 말했다 | told them himself when the trembling had started and when his vision had doubled |
| 2 둘째 단락 (두 변형) | "아버지가 완치된 것은 아니었다. 급성 악화를 넘길 수 있도록 병동의 사람과 절차가 연결됐을 뿐이었다." / "아버지는 병동에 계속 남았고, 급성 악화를 다룰 의료 절차만 이어졌다." | 자정이 지나자 입금 기한과 {name}의 야간진료 접수는 닫혔다. 아버지는 낫지 않았다. 다만 오늘 밤 숨이 나빠지면 누가 누구에게 먼저 전화할지는 정해졌다. | At midnight the payment deadline and his own clinic window closed. His father was not better. But if his breathing worsened tonight, it was settled now who would call whom first. |

**기억 문장 (5키 × 2변형) 교체**

| 키 | KO | EN |
|---|---|---|
| `arc_y4_borrowed_name_reduced_to_self` | 앞서 {name}은 명의 서류에서 남의 이름을 지우고 자기 이름만 남긴 작은 안을 냈다. 그때 줄여 둔 금액이 오늘 밤 청구서 옆에서 떠올랐다. | Earlier, {name} had struck the other names from the loan papers and submitted a smaller plan in his name alone. The amount he had cut came back to him beside tonight's bill. |
| `arc_y4_borrowed_name_partner_review_only` | (attached) 앞서 명의 서류는 곁의 사람에게 검토용으로만 보여 주었고, 이름도 서명도 부탁하지 않았다. / (unattached) 앞서 명의 서류는 검토용 사본만 건넸고, 이름도 서명도 부탁하지 않았다. | (attached) Earlier, he had shown the loan papers to the person beside him only for review, and asked for neither name nor signature. / (unattached) Earlier, he had handed over only a review copy of the loan papers, and asked for neither name nor signature. |
| `arc_y4_borrowed_name_withdrew_request` | 앞서 {name}은 남의 이름을 빌리자던 요청을 거둬들였다. 그 계약 건은 그날로 닫혔다. | Earlier, {name} had withdrawn the request to borrow someone else's name. That deal closed the same day. |
| `arc_y4_borrowed_name_own_name_counteroffer` | 앞서 자기 이름만 넣은 반대안을 내고 접수번호 하나를 받았다. 승인 문자는 아직 오지 않았다. | Earlier, he had submitted a counteroffer in his own name only and received a reference number. No approval text had come yet. |
| `arc_y4_borrowed_name_requested_complete_terms` | 앞서 {name}은 대주와 원금, 만기, 담보가 적힌 원문부터 보내 달라고 하고 절차를 멈췄다. 원문은 아직 오지 않았다. | Earlier, {name} had paused the process and asked first for the full terms: lender, principal, maturity, collateral. They hadn't arrived yet. |

---

## 5. `arc_year1_close` / `arc_year1_close_father_passed` (content/events/arc_year_close.json + events_en)

### 5-A. 연속성 버그 (우선)

`description_if_known`의 `jaehyuk_scammed` / `entered_network` / `hit_rock_bottom` 세 변형은 수첩 마지막 페이지에
**'지킨 것'·'미룬 것'을 쓰는 장면이 없다.** 그런데 선택지 (2) 결과는 "수첩은 '지킨 것'과 '미룬 것' 두 제목 아래가 모두 빈 채로 덮였다"이다.
이 세 경로의 플레이어는 본 적 없는 제목을 읽는다.

**수정:** 세 변형의 마지막 단락 "지금 사는 방의 천장을 봤다. 불을 끈 뒤에도 윤곽은 그대로 남아 있었다."를 아래로 교체한다. 세 변형이 같은 문장으로 끝나던 반복도 함께 사라진다.

KO: `자정까지 4분. {name}은 수첩 마지막 페이지를 반으로 갈라 '지킨 것'과 '미룬 것'이라고 썼다.`

EN: `Four minutes to midnight. {name} split the last page of the notebook in half and wrote "Kept" and "Postponed."`

또한 선택 (0) 결과는 페이지 제목을 '지킨 것/미룬 것'으로 세운 뒤 '얻은 것/내준 것' 줄을 쓴다. 제목을 맞춘다.

| 위치 | 현재 | 교체 KO | 교체 EN |
|---|---|---|---|
| 선택 (0) 문구 | 수첩을 끝까지 쓴다 — 잠을 미뤄도 얻은 것과 내준 것을 함께 적는다 | 수첩을 끝까지 쓴다 — 잠을 미뤄도 지킨 것과 미룬 것을 함께 적는다 | Finish the notebook — even if it costs sleep, write what you kept and what you put off |
| 선택 (0) 결과 둘째 문장 | 한 줄은 '얻은 것', 다음 줄은 '내준 것'이었다. | 지킨 것 아래 한 줄, 미룬 것 아래 한 줄. | One line under Kept, one line under Postponed. |

### 5-B. 단락 끝 부정형 정리

| 위치 | 현재 (삭제/교체) | 교체 KO | 교체 EN |
|---|---|---|---|
| base 2단락 | "첫해 첫날 적은 목표는 지워지지 않았지만, 그 숫자만으로 올해를 설명할 수는 없었다." | 첫날 적은 목표는 그대로였다. | The goal he had written on the first day was still there. |
| base 3단락 끝 | "어느 쪽부터 채울지 정하면, 다른 한쪽은 오늘 밤 비어 있게 된다." | (삭제) | (delete) |
| `kept_clean_hands` 2단락 | "계좌를 빌려 달라는 번호를 막은 뒤, {name}은 새벽 네 시 이십 분 알람을 맞췄다. 받지 않은 돈은 숫자로 남지 않았고, 그 뒤 시간을 어디에 썼는지는 이 장부만으로 확인되지 않았다." | 계좌를 빌려 달라는 번호를 막은 그날 밤, {name}은 새벽 네 시 이십 분에 알람을 맞췄다. | The night he blocked the number asking to borrow his account, {name} set an alarm for 4:20 a.m. |
| `kept_clean_hands` 끝 | "깨끗하다는 말만으로 어느 칸도 저절로 채워지지 않았다." | 펜을 쥔 손가락에 아직 겨울 냉기가 남아 있었다. | The winter cold still lingered in the fingers holding the pen. |
| `escaped_dirty_money` 2단락 끝 | "무엇이 끝났고 무엇이 남았는지는 한 숫자로 정리되지 않았다." | (삭제) | (delete) |
| `escaped_dirty_money` 끝 | "어느 쪽부터 쓰든, 다른 쪽의 숫자가 사라지지는 않았다." | 150만원이라는 숫자가 두 칸 사이 접힌 선 위에 걸쳐 있었다. | The figure 1.5 million won sat right on the fold between the two halves. |
| `father_passed` 선택 (1) 결과 | "받을 사람이 없다는 사실을 기록 하나로 덮지는 않았다." | 받을 사람이 없는 번호였다. | No one would receive it at that number. |

`arc_year1_close_father_passed`는 base 본문과 `description_if_known` 6변형이 같은 구조이므로 5-A·5-B를 그대로 미러한다.

---

## 적용 메모 (Codex)

- 변경은 KO 본문/결과/선택 문구와 EN 오버레이의 대응 텍스트만이다. flags·effects·conditions·ids는 무변.
- JA/zh는 "KO/EN 확정 후 1회 정합" 정책대로 이번 회차에 갱신하지 않는다. 번역 원장 `accepted_sha256`은 기존 도구로 재계산한다.
- 검증: `python3 tools/en_coverage_check.py`, `python3 tools/audit_select.py -- <변경 파일>`, 위 패턴표 grep 재측정(대상 5사건에서 0건).
- 표현 다듬기가 필요하면 의미(행동·숫자·시각)를 유지하는 범위에서 고쳐도 된다. 다만 "~않았다"로 닫는 단락을 되살리지 않는다.

## 다음 회차 (R2 예정)

1. `arc_final_week`의 `final_*` 6변형: 같은 5단락 도입("38세 생일이 7일 남았다…")이 반복되고, 교훈형 마무리("걸어본 사람만 아는 게 있다")가 남아 있다.
2. `arc_year_three_half` 등 Y4 묶음 정리 장면: "창구·기록·빈칸" 어휘 과밀.
3. 패턴표 잔여 81건 중 정점 아닌 장면은 우선순위를 낮춘다.
