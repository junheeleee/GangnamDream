# 텍스트 검토 R5 — 아버지의 죽음 (2026-10-16, Claude)

> R1 규칙 그대로. 범위: KO 산문·결과 문구 + EN 오버레이 대응 텍스트. flags·effects·conditions·ids 무변. JA/zh 보류.
>
> **형제 변형 전수 확인:** `arc_father_passing` + `_platform` / `_deal_room` / `_hospital_room` / `_deal_morning`, 모두 출시 사건이다.
>
> **R0 패턴 재측정:** Y4·Y5를 뺀 출시 사건 62개에 패턴이 있지만, 사건당 1~3건으로 낮고 일상 용법("실제로")이 섞여 있다.
> 서류체는 **Y4·Y5 정점과 그 앞뒤의 아버지 축에 집중**되어 있다. 그래서 R5는 패턴 순위 대신 이 게임의 가장 큰 감정 정점인 아버지의 죽음을 본다.

## 0. 평가

형제 장면 넷은 좋다. 특히 이 두 문장은 이 게임 최고 수준의 문장이다.
- 승강장: "열차 문과 계단은 서로 반대쪽에 있었다. 어느 쪽도 아직 닫히지 않았다."
- 딜 다음 날 아침: "저 숫자가 앞으로 평생 이 아침과 같은 값으로 매겨질 거라는 걸 — 민준은 그제야 알았다."

본편 `arc_father_passing`도 기본 본문은 좋다("이제 어떤 열차를 타도 사망 시각보다 먼저 도착할 수 없기 때문이었다").
**문제는 기억 변형 7개다.** 아버지와의 지난 순간을 하나 꺼낸 뒤, 매번 그 순간이 "죽음을 바꾸지 않았다", "서로 다른 사실로 남았다"고 해명한다.
플레이어가 가장 크게 느껴야 할 문단의 마지막 줄이 매번 검수 문장이다.

## 1. `arc_father_passing` `description_if_known` 7키 (arc_drama.json + events_en)

원칙은 이렇다. 지난 순간을 꺼낸 문장에서 멈춘다. 해명 문장을 지우고, 필요하면 지금 화면의 이미지 하나로 닫는다.

| 키 | 삭제/교체 대상 | 교체 KO | 교체 EN |
|---|---|---|---|
| `called_father_on_ktx` | 2단락 "그날은 통화가 실제로 연결됐고," / 3단락 전체("오늘 병동이 확인한 것은 그 통화와 다른 시각이었다. 연결됐던 한 번이 치료가 되지는 않았고, 지금의 죽음을 미리 정해 둔 것도 아니었다. 둘 다 지울 수 없는 사실로 남았다.") | 2단락: "창원에서 서울로 올라오던 KTX 안에서 아버지에게 전화를 걸었던 날이 떠올랐다. 그날 아버지는 짧은 숨 사이로 민준의 말을 들었다." / 3단락: "그 통화 기록이 지금 병동 번호 바로 아래에 있었다." | P2: "{name} remembered calling Father on the Seoul-bound KTX out of Changwon. That day, between short breaths, Father had listened." / P3: "That call was still in the log, right below the ward's number." |
| `did_not_call_father_on_ktx` | 3단락 전체("오늘 병동이 확인한 사망 시각은 그 선택을 다른 사건으로 바꾸어 주지 않았다. 두 시각은 따로 남았다.") | (삭제 — "민준이 누르지 않은 버튼 하나만 있었다."로 닫는다) | (delete — end on "There had only been a button he did not press.") |
| `father_heard_gangnam_reason` | 마지막 2문장("그 대화가 이후의 모든 침묵을 대신하지는 않았다. 그래도 지금 사라지지 않는 것은 실제로 주고받은 그 말이었다.") | 잘됐으면 좋겠다던 그 목소리가, 수화기 너머 간호사의 목소리 위로 겹쳐 들렸다. | His father's voice saying he hoped things would work out came back, layered over the nurse's voice on the line. |
| `father_knew_i_came` | 마지막 단락 전체("그 방문은 오늘의 결과를 막지 못했다. … 서로 다른 사실로 남았다.") | (삭제 — "약 때문에 조용히 다녀갔던 걸 아버지는 알고 있었다."로 닫는다) | (delete — end on "Father had known about the quiet visit over his medication.") |
| `father_calls_often` | "오늘 화면에 남은 것은 아버지 목소리가 아니라 병동 번호와 확인 시각이었다. 민준은 둘을 같은 통화인 것처럼 겹쳐 놓지 않았다." | 오늘 화면에 뜬 것은 아버지 이름이 아니라 병동 번호였다. | Today, the screen showed not Father's name but the ward's number. |
| `apologized_for_ignoring` | "사과한 사실도, 그 뒤에 남은 시간도 오늘의 사망 시각을 바꾸지는 못했다. 민준은 어느 한쪽을 없던 일로 만들지 않았다." | (삭제 — "괜찮다, 바쁘잖냐"로 닫는다) | (delete — end on "It's fine. You're busy.") |
| `father_debt_felt` | "숫자가 쌓일 때마다 갚아야 할 것이 있다고 생각했지만, 병동이 읽어 준 시각은 돈으로 앞당기거나 되돌릴 수 있는 항목이 아니었다. 화면에는 사망 시각과 딜 알림이 나란히 남았다." | 숫자가 쌓일 때마다, 언젠가는 갚을 수 있다고 생각했다. 화면에는 병동 번호 위로 딜 알림이 떠 있었다. | Every time the number grew, he had thought that someday he could pay it back. On the screen, a deal alert sat above the ward's number. |

**`description_if_moral.white` 마지막 문장**

- 현재: "그래도 어디로 움직일지는 아직 민준의 현재에 남아 있었다." (EN "…was still left in Minjun's present.")
- 교체 KO: `그래도 어디로 갈지는 아직 민준이 정할 수 있었다.`
- 교체 EN: `But where he went from here was still his to choose.`

`description_if_moral.black`은 유지한다("그 계산이 너무 빨리 끝났다는 사실까지 민준은 지울 수 없었다"는 MORAL_TINT의 세계 인식 변화로 잘 작동한다).

## 2. `arc_father_passing_hospital_room` — 사실 확인 필요 (C2 후보)

결과 마지막 문장: "주머니 속 폰에는, 언젠가의 23초짜리 통화 기록이 아직 남아 있었다."

- 23초 통화는 `arc_father_call_on_ktx`(아이템 `artifact_father_call` 보유 시)에서만 성립하는 사실이다.
- `MainGame`은 아이템이 없으면 `arc_father_call_on_ktx_number`로, 아버지가 그보다 먼저 떠나면 KTX 장면 없이 진행한다.
- `hospital_room`은 조건 없이 이 문장을 쓴다. 따라서 **23초 통화를 본 적 없는 플레이어에게도 그 통화를 단정한다.**

**교체(모든 경로에 참):**
- KO: `주머니 속 폰에는 아직 '아버지'라는 이름이 저장되어 있었다.`
- EN: `In his pocket, the phone still had "Father" saved in its contacts.`

(23초를 살리고 싶다면 `description_if_held`/`if_known`으로 `artifact_father_call` 보유 시에만 원문을 쓰는 방법도 있다. 다만 이는 조건 구조 변경이라 이번 회차에서는 권하지 않는다.)

## 3. 표기 메모 (작업 없음)

`_platform` (0)과 `_deal_room` (1)의 선택지는 괄호 속 과거형("(KTX를 탔다. 늦었다는 걸 알면서도.)")이고, 짝이 되는 선택지는 명령형이다.
한 화면에서 두 형식이 섞인다. 의도된 연출(망설임 없는 쪽 = 이미 일어난 일)로 읽힐 수 있어 유지한다.

---

## 적용 메모 (Codex)

- 1·2절 KO/EN 교체. 3절은 기록만.
- 검증: `python3 tools/en_coverage_check.py`, `python3 tools/audit_select.py -- <변경 파일>`,
  `arc_father_passing`에서 `서로 다른 사실로|바꾸지는 못했|바꾸어 주지|없던 일로 만들지|겹쳐 놓지 않|실제로` 0건.
- **우선순위:** 실제 앱 플레이(C1)가 먼저다. 이 문서는 R4와 함께 한 번에 적용해도 된다.

## 다음 회차 (R6 예정)

R0 패턴은 거의 소진됐다. R6부터는 패턴 대신 **도달 빈도가 높은 일반 장면**(M01~M12 반복 루틴·콜백)을 읽는다.
기준은 반복 피로(같은 문장 골격), 교훈형 마무리, 인물 말투 일관성이다.
