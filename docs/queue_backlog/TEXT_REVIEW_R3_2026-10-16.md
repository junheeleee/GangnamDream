# 텍스트 검토 R3 — 마지막 해 민서 경로·4년 차 연말·36세 장면 (2026-10-16, Claude)

> R1 규칙 그대로: **규칙은 무엇을 쓰지 않을지를 정한다. 규칙을 문장으로 쓰지 않는다.**
> 범위: KO 산문·결과 문구 + EN 오버레이 대응 텍스트. flags·effects·conditions·ids 무변. JA/zh 보류.
> 형제 변형 전수 확인: 아래 11개 출시 사건 전부. `arc_y4_year_close_jiyeon`은 author_only라 제외.
> `arc_36_unexpected_hand*` 3개의 경로 배정(`_chapter_four_causal_arc_id`, 다은/그 외)과 `description_if_known` 키 순서가 일치함을 코드로 확인했다(버그 없음).

## 0. 원인 한 줄

STORY_BIBLE의 금지 조항("민서의 읽음·답장·약속, 아버지의 응답, 매매·등기·열쇠·이체를 만들지 않는다")이
산문에서 **"읽음도 답장도 생기지 않았다", "돈이나 자산도 움직이지 않았다", "계약서나 등기 서류가 아니었다"**로 옮겨졌다.
금지는 쓰지 않으면 지켜진다. 아래 교체는 그 문장들을 걷어내고 그 자리를 그 순간의 감각 하나로 닫는다.

---

## 1. `arc_y5_final_week_general_people_outbound` (arc_drama.json) — 일반 경로 마지막 주

**본문** KO:

```
지운 시각 아래 자기 이름을 쓴 뒤 몇 분이 지났다. 방에는 {name} 혼자였다. 휴대폰에는 민서와 주고받던 대화창이, 책상 위에는 아버지 기록 봉투가 놓여 있었다.

민서에게 무언가를 보낼 수도, 봉투에 한 줄을 남길 수도 있었다. 오늘 밤에는 그중 하나만 할 수 있을 것 같았다.

{name}은 빈 입력 칸과 봉투의 빈 줄 사이에서 손을 멈췄다.
```

EN:

```
A few minutes had passed since he wrote his name beneath the erased time. {name} was alone in the room. On the phone was the conversation with Minseo; on the desk, his father's envelope of records.

He could send Minseo something, or leave a line on the envelope. Tonight, it seemed, he could do only one.

{name}'s hand stopped between the empty text box and the blank line on the envelope.
```

**결과**

(0) KO:

```
{name}은 민서와의 대화창에 적었다.

‘그때 제가 했던 대답을 아직 기억해요. 집을 얻어야만 다음 질문에 답할 수 있다는 말로 더 미루지는 않을게요.’

전송을 누르자 말풍선 옆에 작은 시각이 찍혔다. {name}은 화면이 꺼질 때까지 그 시각을 보고 있었다.
```

EN:

```
{name} wrote in the conversation with Minseo.

"I still remember the answer I gave you then. I won't keep putting off your next question by saying I have to get a home first."

He pressed send, and a small timestamp appeared beside the bubble. {name} watched it until the screen went dark.
```

(1) KO:

```
{name}은 빈 의자 앞에서 했던 일을 아버지 봉투 겉면에 한 번 더 썼다. 그 아래에 오늘 지운 것의 이름을 적었다.

‘집이 생겼다고 쓰지 않겠습니다. 지운 것은 다시 붙들지 않고, 남겨 둔 것은 이미 이룬 것처럼 부르지 않겠습니다.’

오늘 날짜를 적고 봉투를 뒤집어 놓았다. 뒷면으로 볼펜 자국이 도드라져 손끝에 걸렸다.
```

EN:

```
On the outside of his father's envelope, {name} wrote once more what he had done in front of the empty chair. Beneath it, he wrote the name of what he had erased today.

"I won't write that I have a home. I won't grab back what I erased, and I won't call what I kept something I've already achieved."

He wrote today's date and turned the envelope over. The pen marks stood out through the back and caught on his fingertips.
```

(삭제: "남겨 둔 것 옆에는 ‘소유도 도착도 아님’이라고 썼다", "방에는 답이 생기지 않았다. 민서에게는 새 문장을 보내지 않았고, 만날 날짜도 제안하지 않았다.")

(2) KO:

```
{name}은 민서와의 대화창을 열고 적었다.

‘다음 주 화요일 저녁 일곱 시 반, 그 카페에서 삼십 분만 이야기할 수 있을까요? 도착 뒤 질문에 제가 고른 답을 가져갈게요.’

전송을 누른 뒤 {name}은 휴대폰을 봉투 옆에 내려놓았다. 화면은 한동안 밝았다가 꺼졌다.
```

EN:

```
{name} opened the conversation with Minseo and wrote.

"Next Tuesday at seven-thirty in the evening, could we talk for just thirty minutes at that café? I'll bring the answer I chose to your question about what comes after arriving."

After sending it, {name} set the phone down beside the envelope. The screen stayed lit for a while, then went dark.
```

---

## 2. `arc_y5_general_debt_memory_reconnect` (arc_pre_ending.json)

| 위치 | 현재 | 교체 KO | 교체 EN |
|---|---|---|---|
| 본문 2단락 | 상환이 끝났다는 날짜와 민서에게 실제로 보낸 대답 사이에는 아직 아무 선도 없었다. 민서가 하지 않은 대답도, 아버지가 할 수 없는 대답도, 아직 얻지 않은 집도 보태지 않기로 했다. | 상환이 끝난 날짜와 민서에게 보냈던 대답. {name}은 두 날짜 사이에 아직 선을 긋지 못했다. | The date the debt was paid off, and the answer he had sent Minseo. {name} still hadn't drawn a line between the two dates. |
| 기억 `name_boundary_0` 2단락 | 오늘은 그 기준을 누구에게 보내지 않을 자기 기록으로 잇는 날이었다. 휴대폰의 녹음 버튼과 접어 둔 사본 중 무엇을 쓸지, {name}은 자기 쪽 매체 하나를 골라야 했다. | 휴대폰의 녹음 버튼과 접어 둔 사본이 책상 위에 나란히 있었다. | The phone's record button and the folded copy lay side by side on the desk. |
| 기억 `name_boundary_1` 2단락 | (위와 같은 문장) | (위와 같음) | (same as above) |
| (0) 결과 1단락 | 민서의 메시지에 자기가 실제로 보낸 대답만 말했다. | 민서의 메시지에 자기가 보냈던 대답만 말했다. | he spoke only the answer he had sent to Minseo's message. |
| (0) 결과 2단락 | 메모는 자기 휴대폰에만 남았다. 민서에게 보내지 않았고 읽음도 답장도 생기지 않았다. 저장한 세 주소도 비교 정보인 채 그대로였다. | {name}은 그 메모를 누구에게도 보내지 않았다. 녹음 목록 맨 위에 00:31이 떠 있었다. | {name} sent the memo to no one. At the top of the recordings list sat 00:31. |
| (1) 결과 1단락 | 민서의 메시지에 자기가 실제로 보낸 대답만 적었다. | 민서의 메시지에 자기가 보냈던 대답만 적었다. | he wrote down only the answer he had sent to Minseo's message. |
| (1) 결과 2단락 | 커피가 식을 때까지 맞은편은 비어 있었다. 민서는 오지 않았고 새 메시지도 생기지 않았다. 메모는 상환확인서의 원문을 고치지 않은 채 사본 사이에 따로 남았다. | 커피가 식을 때까지 맞은편은 비어 있었다. {name}은 두 종이를 다시 접어 사본 사이에 끼웠다. | The seat across from him stayed empty until the coffee went cold. {name} folded the two sheets again and tucked the note back into the copy. |

## 3. `arc_y5_general_debt_memory_voice_exact` (arc_pre_ending.json)

| 위치 | 현재 | 교체 KO | 교체 EN |
|---|---|---|---|
| 본문 1단락 | 민서에게 실제로 했던 대답 | 민서에게 했던 대답 | the answer he had given Minseo |
| 본문 3단락 | 이 원본을 남겨 두어도 민서에게 전달되는 것은 아니고, 지워도 이미 있었던 대화가 바뀌는 것은 아니었다. 달라지는 것은 마지막 문턱까지 가져갈 자기 쪽 흔적의 상태뿐이었다. | (삭제) | (delete) |
| (0) 결과 1단락 끝 | 원본은 자기 휴대폰에 그대로 남았고, 마지막 문턱에서도 그 상태를 직접 확인할 수 있게 됐다. | 원본은 자기 휴대폰에 그대로 남았다. | The original stayed on his phone, untouched. |
| (0) 결과 2단락 | 공유 버튼은 누르지 않았다. 민서에게 간 파일도, 읽음도, 답장도, 만나기로 한 시각도 생기지 않았다. 저장한 세 주소는 여전히 비교 정보일 뿐 계약이나 소유가 아니었다. | 공유 버튼은 누르지 않았다. 화면을 끈 뒤에도 서른한 초짜리 목소리가 귀에 남았다. | He didn't press share. Even after the screen went off, thirty-one seconds of his own voice stayed in his ear. |
| (1) 결과 2단락 | 파일을 보내거나 대화를 지운 것은 아니었다. 민서의 읽음도 답장도 새 만남도 생기지 않았고, 아버지에게서 올 수 없는 답을 보태지도 않았다. 돈이나 자산도 움직이지 않았다. | (삭제 — 1단락 "마지막 문턱에 가져갈 수 있는 것은 소리가 아니라 그 시각이었다."로 닫는다) | (delete — end on the first paragraph) |

## 4. `arc_y5_general_debt_memory_cafe_exact` (arc_pre_ending.json)

| 위치 | 현재 | 교체 KO | 교체 EN |
|---|---|---|---|
| 본문 1단락 | 민서에게 실제로 했던 대답 | 민서에게 했던 대답 | the answer he had given Minseo |
| 본문 3단락 | 사본과 메모를 가방에 넣어도 계약서가 되지는 않고, 방에 두어도 민서나 아버지의 답이 생기지는 않는다. 달라지는 것은 마지막 문턱을 넘을 때 이 두 흔적이 {name} 쪽에 함께 놓이는지뿐이었다. | (삭제) | (delete) |
| (0) 결과 2단락 | 민서를 부르거나 메시지를 보내지 않았다. 아버지 기록 봉투에는 새 말을 쓰지 않았다. 사본과 메모는 매매계약서나 등기 서류가 아니었고, 돈이나 소유도 움직이지 않았다. | 가방 지퍼를 닫자 투명칸 안에서 종이가 바스락거렸다. | When he zipped the bag shut, the paper rustled inside the clear pocket. |
| (1) 결과 2단락 | 봉투와 두 종이는 자기 방에 남았다. 아버지가 돌아오거나 민서가 메모를 읽는 일은 생기지 않았다. 어느 종이도 소유권이 아니었고, 돈이나 자산도 움직이지 않았다. | 봉투와 두 종이는 방에 남았다. 문을 닫기 전, {name}은 책상 쪽을 한 번 돌아봤다. | The envelope and the two sheets stayed in the room. Before closing the door, {name} looked back at the desk once. |

---

## 5. `arc_y4_year_close_daeun` / `arc_y4_year_close_unattached` (arc_year_close.json)

**기억 문장 3키 (두 사건 공통)**

| 키 | 현재 (요지) | 교체 KO | 교체 EN |
|---|---|---|---|
| `father_crisis_contact_present` | 방문은 생사를 결정한 공로가 아니라, 그 위기에서 실제로 움직인 관계 영수증이었다. | 그 밤의 창원행 열차표가 아직 수첩 사이에 끼어 있었다. | The train ticket to Changwon from that night was still tucked in the notebook. |
| `father_crisis_contact_called` | 통화는 생사를 결정하지 않았지만 그 위기에서 어떤 행동을 했는지는 바꿨다. | 병동과 연결됐던 그 밤의 통화가 아직 목록 위쪽에 있었다. | The call that had connected to the ward that night was still near the top of the log. |
| `father_crisis_contact_missed` | 확인되지 않은 경과를 발명하지 않아도, 미룬 행동의 시간은 지워지지 않았다. | ‘오늘은 어렵다’고 보냈던 문자가 아직 병동 대화창 맨 아래에 있었다. | The text he'd sent — "I can't today" — was still at the bottom of the ward's thread. |

> R1 적용본의 `crisis_contact` (2) 문자는 "오늘은 창원에 가거나 통화할 수 없습니다"다. 인용을 정확히 맞추려면 위 KO를 `‘오늘은 창원에 가거나 통화할 수 없습니다’라고 보냈던 문자가…`로 쓴다(EN: `The text he'd sent — "I can't come to Changwon or call today" — …`). **이 정확 인용판을 채택한다.**

**본문·결과**

| 사건·위치 | 현재 | 교체 KO | 교체 EN |
|---|---|---|---|
| daeun 본문 1단락 2문장 | 테이블에는 올해 실제로 끝낸 일의 시각과 놓친 일의 빈칸, 몸 후속 안내, 가족 쪽 남은 청구가 나란히 놓였다. | 테이블에는 올해 끝낸 일과 놓친 일을 적은 수첩, 병원의 후속 진료 안내문, 가족 쪽에서 온 청구서가 나란히 놓여 있었다. | On the table lay the notebook of what he had finished and missed this year, the hospital's follow-up notice, and the bill from his family's side. |
| daeun (2) 결과 2단락 | 다은은 도착 시각과 답한 시각을 나란히 봤다. "이제 돈 냈다는 말 하나로 끝내지는 못하겠네요." | 다은은 그가 적은 한도를 잠깐 들여다봤다. "이제 돈 냈다는 말 하나로 끝내지는 못하겠네요." | Daeun glanced at the limit he had written. "So you can't just say 'I paid' and be done with it now." |
| unattached 본문 2문장 | 실제로 끝낸 일과 놓친 일, 몸 후속 안내, 가족 쪽 남은 청구가 서로 다른 시각으로 찍혀 있었다. | 끝낸 일과 놓친 일을 적은 수첩, 후속 진료 안내문, 가족 쪽에서 온 청구서가 펼쳐져 있었다. | The notebook of what he had finished and missed, the follow-up notice, and the bill from his family's side lay open. |
| unattached (2) 결과 | …원문·금액·기한을 다시 확인했다. 전부 대신 갚겠다는 말도, 다른 사람 이름으로 막겠다는 말도 하지 않고 지금 감당할 한도를 회신했다.\n\n통화를 끊자 답한 시각과 답하지 못한 범위가 함께 남았다. | …원문·금액·기한을 다시 확인했다. 확인한 원문 아래에 지금 감당할 수 있는 한도를 적어 회신했다.\n\n통화를 끊고 나서야 {name}은 청구서를 쥔 손에 땀이 배어 있다는 걸 알았다. | …confirmed the wording, amount, and due date again. Beneath the confirmed text, he wrote the limit he could carry now and sent it back.\n\nOnly after hanging up did {name} notice his palm was damp where he held the bill. |

---

## 6. `arc_36_unexpected_hand` / `_father_deal` / `_person_deal` (arc_chapter_themes.json)

| 사건·위치 | 현재 | 교체 KO | 교체 EN |
|---|---|---|---|
| hand 본문(base·known 공통) 1단락 2문장 | 병원 일정 변경 수수료와 다시 움직일 교통비가 장부에 따로 찍혔고, 두 연락창에는 답하지 못한 시각만 남았다. | 병원 일정 변경 수수료와 다시 움직일 교통비가 카드 내역에 따로 찍혔다. 두 대화창에는 아직 답하지 못한 메시지가 있었다. | The hospital's rescheduling fee and the fare for going back showed up as separate lines on his card statement. Both conversations still held messages he hadn't answered. |
| hand 본문 2단락 | …이번 주 달력에서 실제로 비울 수 있는 칸은 많지 않았다. | …이번 주 달력에서 비울 수 있는 칸은 많지 않았다. | …There weren't many slots he could clear on this week's calendar. |
| hand (1) 결과 | …이번 주에 실제로 비울 수 있는 두 시각… / 새 시각이 지난 기다림을 지우지는 않았다. 그래도 다음에 찾아갈 시각만큼은 분명해졌다. | …이번 주에 비울 수 있는 두 시각… / 달력의 그 한 칸이 이번 주에서 가장 진한 색이었다. | …two times he could clear this week… / That one slot was the darkest square on this week's calendar. |
| father_deal 본문 2단락 | 이번 주에 실제로 수습할 수 있는 창구는 하나뿐이었다. | 이번 주에 다시 잡을 수 있는 건 하나뿐이었다. | Only one of them could be rebooked this week. |

---

## 7. `arc_36_night_doubt` / `_father_passed` (arc_midgame.json)

장면 자체는 이 게임에서 좋은 편이다(새벽 3시, 계산기 불빛, "강남에 꼭 가야 하나"). 문제는 결과 문구 끝마다 붙은 해설이다.

| 위치 (두 사건 공통) | 현재 | 교체 KO | 교체 EN |
|---|---|---|---|
| 기억 `arc_y4_midpoint_receipt_seen` | (2단락, "자기가 잠근 장부를 끝까지 읽은 뒤에도 남은 질문이었다"로 끝남) | 계산기 옆에는 열한 주 전 수첩 첫 장에 끼워 둔 긴 종이가 펼쳐져 있었다. 계산기는 얼마나 더 가야 하는지 말했고, 종이는 무엇을 두고 왔는지 말했다. | Beside the calculator lay the long sheet he had tucked into the front of the notebook eleven weeks ago. The calculator said how far he still had to go; the paper said what he had left behind. |
| (0) 3단락 | 목표를 원래 자리에 돌려놓는다고 지난 비용이 사라지지는 않았다. {name}은 30억 밑에… | {name}은 30억 밑에… (첫 문장만 삭제) | (delete the first sentence only) |
| (1) 1단락 끝 | 모른다는 말을 결론처럼 꾸미지 않기 위해서였다. | (삭제) | (delete) |
| (1) 2단락 끝 | 어느 쪽인지 새벽의 자신이 대신 정하지 않기로 했다. | (삭제) | (delete) |
| (1) 4단락 | 답을 미룬 사실까지 종이 위에 남아 있었다. {name}은 그것을 해결이라고 부르지 않고 잠들었다. | 수첩은 계산기 옆에 펼쳐진 채였다. {name}은 그대로 잠들었다. | The notebook lay open beside the calculator. {name} fell asleep like that. |
| (2) 2단락 | 그 생각은 예상만큼 무섭지 않았다. 목표 금액을 지우거나 강남을 포기한 것도 아니었다. 다만 숫자가 모든 선택을 자동으로 정답으로 만들 수 있다는 권한을 거둔 것이었다. | 그 생각은 예상만큼 무섭지 않았다. | The thought was less frightening than he had expected. |
| (2) 4단락 | 창밖이 밝아지기 전 계산기를 닫았다. 통장의 숫자와 삶의 값이 같지 않을 수 있다는 문이 처음 열렸고, 닫지 않은 채 두기로 했다. | 창밖이 밝아지기 전 계산기를 닫았다. 수첩은 펼친 채로 두었다. | He closed the calculator before the sky outside grew light. He left the notebook open. |

**연속성 메모 (문안 작업 없음):** `arc_36_night_doubt_father_passed`의 `description_if_known.daytime_conviction`은 생존판과 같은 본문이라,
아버지를 잃은 런에서 이 키가 맞으면 약봉지·사진·빈 의자가 사라진다. 고칠지 여부는 출시 후 메모로 넘긴다(사실 모순은 아님).

---

## 적용 메모 (Codex)

- 1~7절 KO/EN 교체. 3·4절 "(삭제)"는 해당 단락 전체 삭제다.
- 검증: `python3 tools/en_coverage_check.py`, `python3 tools/audit_select.py -- <변경 파일>`,
  11개 사건에서 `실제로|읽음도 답장도|자산도 움직이지|소유권이 아니|계약서가 되지|생사를 결정|영수증이었다` 0건.
- 번역 원장 `accepted_sha256`은 기존 도구로 재계산한다.

## 다음 회차 (R4 예정)

일반 경로 M56~M60 나머지(`arc_y5_general_*`·`arc_y5_name_on_line_*`·`arc_y5_people_verdict_*`)와 투자 경로 `investment_safe_no_execution` 묶음.
같은 금지 조항이 산문으로 번역된 패턴이 가장 짙은 구간이다. 형제 변형 전수 나열부터 한다.
