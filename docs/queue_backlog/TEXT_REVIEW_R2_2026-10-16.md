# 텍스트 검토 R2 — 지연판 청구의 밤·4년 차 정리 장면·마지막 주 가려진 변형 (2026-10-16, Claude)

> R1(`TEXT_REVIEW_R1_2026-10-16.md`, 적용 완료 ff903621)과 같은 규칙을 쓴다:
> **규칙은 무엇을 쓰지 않을지를 정한다. 규칙을 문장으로 쓰지 않는다.**
> 범위: KO 산문·선택지·결과 문구와 EN 오버레이 대응 텍스트. flags·effects·conditions·ids 무변. JA/zh 보류.

## 1. `arc_y4_bill_night_jiyeon` (content/events/arc_chapter_themes.json + events_en) — R1 누락분

R1에서 attached/unattached 두 변형만 고치고 지연판을 놓쳤다. 이 판은 상태가 가장 나쁘다.
지연의 대사 자체가 검수 규칙이다: "돈, 민준씨 몸, 아버님 병동을 한 사실로 합치지 마세요."
지문도 마찬가지다: "{name}은 지연의 이동이나 이름을 동의로 만들지 않고…"

**본문** KO:

```
밤 11시 47분. 창원 성심병원 원무과가 보낸 가상계좌의 입금 기한은 오늘 밤 11시 59분이었다. 487,300원. 기한을 넘기면 계좌를 다시 받아야 했다.

{name}의 손끝은 저녁부터 떨리고 있었다. 서울 동부야간진료센터 접수는 자정에 마감이었다. 그리고 아버지 병동의 야간 간호사는 인계 전인 11시 50분에 보호자와 약 목록, 전원 병원, 연락 순서를 맞추자는 문자를 남겨 두었다.

부산의 지연이 영상통화 화면 너머에서 {name}의 얼굴을 보고 있었다. 그녀는 세 시각을 종이에 받아 적었다. "민준씨, 지금 하나만 골라요. 셋 다 하려다 하나도 못 해요."

열두 분. 셋 중 하나만 끝낼 수 있었다.
```

EN:

```
11:47 p.m. The virtual account the billing office at Changwon Sungsim Hospital had sent was due by 11:59 tonight. 487,300 won. Miss it, and he'd have to request a new account.

{name}'s fingertips had been trembling since evening. Seoul East After-Hours Clinic stopped taking patients at midnight. And the night nurse on his father's ward had left a text: at 11:50, before shift change, she wanted to go over the medication list, transfer hospital, and contact order with family.

From Busan, Jiyeon watched his face through the video call. She wrote the three times down on paper. "Minjun, pick one. Try all three and you'll finish none."

Twelve minutes. He could finish only one of the three.
```

**결과**

(0) KO:

```
{name}은 화면을 지연에게 보여 준 채 본인 인증을 마치고 11시 58분에 487,300원을 보냈다. 지연은 영수증 번호를 소리 내어 한 번 읽었다.

그사이 11시 50분 병동 문자에는 답하지 못했고, 야간진료 접수도 지나갔다. 화면 너머에서 지연이 펜을 내려놓았다.
```

EN:

```
With the screen turned toward Jiyeon, {name} finished verifying his identity and sent 487,300 won at 11:58. Jiyeon read the receipt number aloud once.

Meanwhile the 11:50 text from the ward went unanswered, and the night clinic's window passed. On the other side of the screen, Jiyeon set down her pen.
```

(1) KO:

```
{name}은 지연에게 서울 주소와 이동 계획을 보내고 통화를 끊은 뒤 택시에 탔다. 11시 59분, 접수대에서 떨림이 언제 시작됐는지, 언제 앞이 겹쳐 보였는지 직접 말했다.

입금 기한과 병동 문자는 그사이 지나갔다. 진료실 앞 의자에 앉자 지연에게서 '도착했어요?' 한 줄이 와 있었다.
```

EN:

```
{name} sent Jiyeon his Seoul address and his route, ended the call, and got into a taxi. At 11:59, at the front desk, he told them himself when the trembling had started and when his vision had doubled.

The payment deadline and the ward's text passed in the meantime. When he sat down on the bench outside the exam room, a single line from Jiyeon was waiting: "Did you get there?"
```

(2) KO:

```
{name}은 병동에 연결해 약 봉투와 간호 기록을 맞추고, 다음 날 진료 의뢰 번호와 악화 시 전원 병원, 야간 보호자 연락 순서를 확인했다. 영상통화 화면 속 지연도 그 순서를 따라 적었다.

자정이 지나자 입금 기한과 {name}의 야간진료 접수는 닫혔다. 아버지는 낫지 않았다. 다만 오늘 밤 숨이 나빠지면 누가 누구에게 먼저 전화할지는 정해졌다.
```

EN:

```
{name} got through to the ward and matched his father's medicine packets against the nursing record, then confirmed tomorrow's referral number, the transfer hospital if things worsened, and the overnight contact order. In the video call, Jiyeon wrote the same order down after him.

At midnight the payment deadline and his own clinic window closed. His father was not better. But if his breathing worsened tonight, it was settled now who would call whom first.
```

**기억 문장 5키** — R1 §4 표의 attached 문장을 그대로 쓰되, `arc_y4_borrowed_name_partner_review_only`만 아래로:

- KO: `앞서 명의 서류는 검토용 사본만 건넸고, 이름도 서명도 부탁하지 않았다.`
- EN: `Earlier, he had handed over only a review copy of the loan papers, and asked for neither name nor signature.`

(현재 문장 "부산의 지연이 오늘 화면을 본 사실도 결제나 의료 결정의 위임은 아니었다"는 삭제한다.)

---

## 2. `arc_year_three_half` "세 줄의 값" (content/events/arc_midgame.json + events_en)

### 문제

4년 차 중간 결산 카드다. `description_if_known` 28변형이 3축(세 약속 × 몸 × 가족 식탁) 조합으로 되어 있고, 모두 회계 어휘로 쓰였다
("아버지 쪽 창구", "실제 동행자"(9회), "완료 시각", "빈칸", "상계하지 못한다", "같은 성과로 합치지 않았다").
각 변형의 둘째 단락은 결국 같은 말("지킨 것이 놓친 것을 지우지 않는다")을 27가지로 반복하는 교훈이다.

### 사실 확인 (원본 장면에서)

- `protected_person`은 경로에 따라 **다은과의 약속 / 부산 지연과의 약속 / 자기 야간진료 접수**(`arc_y4_three_promises_deal_only`)다.
  그래서 "사람에게 갔다"로 쓰면 deal_only 경로에서 틀린다. 아래 문장은 세 경로 모두에 참이 되도록 중립으로 쓴다.
- `body_chose_care`는 다은에게 팔을 맡김 / 119 연결(지연·현수판) 모두를 포함한다 → "도움을 받았다".
- `family_attended_alone`은 늦은 도착만이 아니다(`commitment_none`에선 유급 현장을 거절하고 간다) → 시점 표현을 넣지 않는다.

### 교체 방식 — 조합 문장 + 한 장면 이미지

27개 조합 변형은 아래 조각을 이어 만든다. 둘째 단락의 교훈 문장은 없애고 가족 축 이미지 한 줄로 닫는다.

**KO 틀:** `일요일 밤, {name}은 이번 계절의 메모를 바닥에 날짜순으로 펼쳤다. [A] [B] [C]\n\n[D]`

**EN 틀:** `On Sunday night, {name} spread this season's notes on the floor in date order. [A] [B] [C]\n\n[D]`

| 축 | 값 | KO | EN |
|---|---|---|---|
| A 세 약속 | `protected_father` | 세 시각이 겹쳤던 토요일에는 네 시 아버지 통화를 지켰다. 다른 두 시각은 그대로 지나갔다. | On the Saturday the three times collided, he kept the four o'clock call with his father. The other two slipped by. |
| | `protected_person` | 세 시각이 겹쳤던 토요일에는 아버지 통화와 거래 검토를 놓치고 남은 한 곳으로 갔다. | On the Saturday the three times collided, he let the call with his father and the contract review go, and went to the one place left. |
| | `protected_deal` | 세 시각이 겹쳤던 토요일에는 검토실에서 거래 원문을 끝까지 읽었다. 아버지 통화와 다른 약속은 그대로 지나갔다. | On the Saturday the three times collided, he read the contract through to the end in the review room. The call with his father and the other appointment slipped by. |
| B 몸 | `body_chose_care` | 손이 떨리던 새벽에는 문을 열고 도움을 받았다. | On the night his hands shook, he opened the door and let someone help. |
| | `body_chose_deadline` | 손이 떨리던 새벽에는 파일 마감부터 보냈다. | On the night his hands shook, he sent the file before the deadline first. |
| | `body_chose_alone` | 손이 떨리던 새벽에는 문을 닫고 혼자 버텼다. | On the night his hands shook, he shut the door and held out alone. |
| C 가족 식탁 | `family_attended_together` | 가족 식탁에는 함께 간 사람과 나란히 앉았다. | At the family table, he sat beside the person who had come with him. |
| | `family_attended_alone` | 가족 식탁에는 혼자 갔다. | He went to the family table alone. |
| | `family_missed` | 가족과 잡은 저녁에는 가지 못했다. | He didn't make it to the dinner with his family. |
| D 이미지 (C에 따름) | `family_attended_together` | 메모 사이에 그날 식당의 물수건 포장지 하나가 끼어 있었다. | Tucked between the notes was a wet-towel wrapper from the restaurant that day. |
| | `family_attended_alone` | 식당까지 혼자 간 날의 교통카드 내역이 메모 맨 아래에 있었다. | At the bottom of the pile was the transit-card record from the day he went to the restaurant alone. |
| | `family_missed` | 가족과 잡았던 토요일 저녁 칸에는 식당 이름만 적혀 있었다. | The Saturday-evening square for the family dinner held only the name of the restaurant. |

**예** (`protected_father & body_chose_care & family_attended_together`):

> 일요일 밤, {name}은 이번 계절의 메모를 바닥에 날짜순으로 펼쳤다. 세 시각이 겹쳤던 토요일에는 네 시 아버지 통화를 지켰다. 다른 두 시각은 그대로 지나갔다. 손이 떨리던 새벽에는 문을 열고 도움을 받았다. 가족 식탁에는 함께 간 사람과 나란히 앉았다.
>
> 메모 사이에 그날 식당의 물수건 포장지 하나가 끼어 있었다.

28번째 변형(`seen&seen&seen`만, 결과 미상 — "메모는 물에 젖어 번져 있었다")은 좋은 장면이라 유지한다.

### 기본 본문 `description` 교체

KO:

```
일요일 밤, {name}은 방의 불을 하나만 남기고 이번 계절의 메모를 바닥에 날짜순으로 펼쳤다. 약속, 몸, 가족. 휴대폰 달력과 결제 내역을 옆에 두고 날짜를 하나씩 맞췄다.

한 날짜를 옮겨 적으려니 종이 끝이 말려 올라왔다. {name}은 팔꿈치로 누르고 마지막 숫자를 마저 썼다. 팔을 떼자 눌린 자리에 옅은 주름이 남았다.

{name}은 자를 대고 세 줄을 그었다. 날짜가 남지 않은 칸에는 빗금만 쳤다.
```

EN:

```
On Sunday night, {name} left a single light on and spread this season's notes on the floor in date order. Promises, body, family. With his phone calendar and payment history beside him, he matched the dates one by one.

As he copied a date, the edge of the paper curled up. {name} held it down with his elbow and finished the last digit. When he lifted his arm, a faint crease remained.

{name} laid a ruler down and drew three lines. Where no date was left, he drew only a slash.
```

### 기억 문장 `arc_y4_three_promises_seen` 교체

모든 결과 변형 뒤에 붙는 문단이라 길이가 바로 체감된다. 3단락을 1단락으로 줄인다.

- KO: `세 장의 메모는 크기가 제각각이었다. {name}은 끝낸 시각에는 짧은 밑줄을, 지나간 시각에는 끝이 막힌 선을 그었다. 그리고 세 장을 겹쳐 길게 접었다. 다음에 펼쳤을 때 어느 칸이 왜 비었는지 바로 보이도록.`
- EN: `The three sheets were different sizes. {name} underlined the times he had kept with a short stroke and closed off the ones that had passed with a capped line. Then he stacked the three and folded them lengthwise, so that next time he opened them he would see at once which square was empty, and why.`

### 선택 결과 (단일 선택) 수정

| 위치 | 현재 | 교체 KO | 교체 EN |
|---|---|---|---|
| 1단락 끝 | 그때마다 확인할 수 없는 문장을 지웠다. | 그때마다 쓰려던 문장을 지웠다. | each time, he crossed out the sentence he had been about to write. |
| 4단락 | 다음 달의 속도는 새 결심에서 시작하지 않는다. 이미 지불한 값을 숨기지 않는 데서 시작한다. | (삭제) | (delete) |

선택지 문구 "완료 시각과 빈칸을 그대로 잠근다"는 → **"메모를 접어 수첩 첫 장에 끼운다"** / EN **"Fold the notes into the front of the notebook"**.

---

## 3. 발견 — `arc_final_week`의 `final_*` 16변형은 화면에 나오지 않는다 (문안 작업 없음)

`arc_final_week`의 `description_if_known`에는 `final_signature_owned/collateral/people` 3개 뒤에
`final_all_in_won` … `reflected_on_state` 16개("38세 생일이 7일 남았다" 계열)가 있다.

- `StoryMode._resolved_story_description`은 dict 순서대로 **처음 맞는 키 하나**만 쓴다.
- `MainGame`(W240)은 항상 `arc_final_countdown` → `arc_final_week` 순으로 연다.
- `arc_final_countdown`의 세 선택은 **모두** `final_signature_*` 중 하나를 세운다.
- 따라서 `final_week` 시점에는 늘 `final_signature_*`가 먼저 맞고, 뒤의 16변형은 도달하지 않는다.

R1 때 Claude가 DECISIONS 2026-10-15 ③으로 넣은 `final_gamble_taken` 문장도 여기 포함되어 화면에 나오지 않는다(Claude 확인 누락).

**권고:** 16변형을 지금 다시 쓰지 않는다(플레이어가 보지 못하는 문장에 시간을 쓰지 않는다). 삭제도 하지 않는다(삭제는 별도 판단 대상).
다만 마지막 반년의 큰 선택(올인·방어·사람 우선 등)은 마지막 주 본문에서 지금 아무 말도 듣지 못한다.
이것을 살릴지(예: `description_memory_if_known`에 한 줄 기억으로 이동)는 출시 후 메모(`POST_LAUNCH_NOTES`)로 넘긴다.
Codex는 이 섹션에서 **코드·데이터를 바꾸지 않는다.**

---

## 적용 메모 (Codex)

- 1·2절만 적용한다. 3절은 기록만 한다.
- 2절의 27변형은 표의 조각을 이어 KO/EN에 같은 키로 넣는다. 조합 생성은 일회성 스크립트로 해도 되지만 스크립트는 커밋하지 않는다.
- 검증: `python3 tools/en_coverage_check.py`, `python3 tools/audit_select.py -- <변경 파일>`,
  grep으로 `실제 동행자|창구|상계|미확인|대신하지|동의로 만들지` 가 두 사건에서 0건.
- 번역 원장 `accepted_sha256`은 기존 도구로 재계산한다.

## 다음 회차 (R3 예정)

R0 패턴표 잔여 사건 중 정점 가까운 순으로: `arc_y5_final_week_general_people_outbound`, `arc_y5_general_debt_memory_*`,
`arc_y4_year_close_daeun/unattached`, `arc_36_unexpected_hand`, `arc_36_night_doubt(_father_passed)`.
각 사건은 **형제 변형(_jiyeon/_unattached/_father_passed 등)을 먼저 전부 나열**한 뒤 문안을 쓴다(R1 누락 재발 방지).
