# Active Queue Spec: ORDER-352

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [ ] ORDER-352 [P1·본편·HOLD 뒤] 5장 M49~M60 대본의 이름·시간·회수·영어 정합을 고친다

**2026-09-27 Claude 발행.** 본편 대본 정합 검토 계획
([FULL_GAME_SCRIPT_REVIEW](../queue_backlog/FULL_GAME_SCRIPT_REVIEW.md))의 배치
R5a·R5b다. story_map M49~M60 root 42장면(투자 기준 경로·일반 경로·안전 미실행 결말,
재혁 보증 거울, 상철 마지막 문, 네 사람의 방, 아버지 흔적, 이름의 선, 사람들의
판정, 마지막 서명, 다은에게 먼저 보낸 말)을 KO/EN으로 읽었다. 경로 조건은
`MainGame.gd` 스케줄과 선택 플래그로, 인물 사실은 `STORY_BIBLE.md`로 확인했다.

## 착수 조건

**5장 HOLD 수리(ORDER-137·138·148·150·151·156)가 닫힌 뒤 착수한다.** 같은
`arc_pre_ending.json`·`arc_drama.json`·`arc_year3_drama.json`을 만지는 수리가 진행
중이다. 착수 전에 아래 위치가 그 수리로 이미 바뀌었는지 먼저 확인하고, 바뀐 항목은
새 원문 기준으로 다시 판정한다. `FULL_GAME_SCRIPT_REVIEW.md` 순서 조건과 같다.

## 깊이 3문

1. **왜 지금 발행하는가?** 판독은 끝났다. 결함을 기록해 두어야 HOLD 수리가 같은
   문장을 다시 쓸 때 함께 닫을 수 있다.
2. **무엇을 바꾸지 않는가?** gameplay key, 선택 수, 효과, 이벤트 ID, 스케줄 조건,
   Chapter5 인과 원장·receipt, 경제 수치는 바꾸지 않는다. 5번만 기존
   `description_variants` 구조를 쓴다.
3. **GO는 어떻게 되는가?** 본편 HOLD와 사람 게이트 OPEN은 그대로다.

## 수리 목록

| # | 위치 | 결함 | 수리 방향 |
|---:|---|---|---|
| 1 | `content/events/arc_pre_ending.json` `arc_y5_name_on_line` 선택 2 결과(“한 다은”), 같은 EN(“HAN DAEUN”) | 다은의 성은 `STORY_BIBLE.md` 정본과 M49·M50 계약서 모두 **김**다은이다. “한”은 한지연의 성이다. | “김다은” / “KIM DAEUN”. |
| 2 | `content/events/arc_year3_drama.json` `arc_father_legacy` 본문 첫 줄, 같은 EN | “아버지가 떠난 지 마흔여덟 주”. 현재 별세 판정은 W188(`_chapter_four_father_outcome_id`) 한 창구이고 이 장면은 t≥224에 열려 실제로는 36주 이상이다. 스케줄 주석(“별세 정점으로부터 48주 뒤”)도 옛 설계다. | “아버지가 떠난 지 여덟 달이 넘었다” / “More than eight months had passed since Father died.” (t224~240 모두 참). `MainGame.gd` 주석도 현재 창구로 고친다. |
| 3 | `content/events/arc_year3_drama.json` `arc_y5_final_father_answer_alive` 본문, 같은 EN | “다섯 해 전 보증인 칸”. 아버지 보증은 민준이 27세에 갚기 시작하기 전 일로, 38세 직전인 지금은 십 년이 넘었다(M32 “십 년 가까이 전”, M36 “십 년 가까운 시간”). | “십 년이 넘은 보증인 칸” / “the guarantor field from more than ten years ago”. |
| 4 | `arc_pre_ending.json` 437·482·495행, `arc_year3_drama.json` 146·147행의 “1장의 마지막 상환확인서/상환확인일”, EN 4곳 “from Year One” | 작가용 장 번호(“1장”)가 산문에 새어 나왔다. 상환은 게임 시작 전(27~32세)에 끝났으므로 EN “Year One”은 사실로도 틀리다. | “1장의”와 “from Year One”을 지운다(“마지막 상환확인서 사본” / “the final repayment confirmation”). |
| 5 | `content/events/arc_new_characters.json` `arc_minseo_03_arrival`·`arc_minseo_03b_not_arrived`, 같은 EN | (a) 두 장면 모두 민서가 “그때 제가 했던 말 … 목표가 사라질 때를 준비하라”를 회수한다. 그 말은 M40 선택 2(`minseo_real_talk`)에서만 나오고, 선택 1 경로의 민서는 “맞아요. 이루긴 했죠.”만 했다. (b) 민서가 먼저 메시지를 보내는데, M37 선택 2(명함 안 받음, `got_minseo_card` 없음)와 M40에는 연락처를 주고받는 장면이 없다. 두 장면의 스케줄은 `arc_minseo_02_seen`만 본다. | (a) 기존 `description_variants`로 `minseo_real_talk`이 없는 경로의 회수 문장을 “이루긴 했죠, 라고 웃던 그 카페”처럼 실제로 본 장면으로 바꾼다. (b) `got_minseo_card`가 없는 경로에는 연락 경로 한 구절(예: “세미나 참가자 명단으로 연락드려요”)을 더한다. 플래그는 추가하지 않는다. |
| 6 | `content/events_en/arc_drama.json` `arc_y5_guarantee_protected_show_daeun` 본문 | 다은이 “Mr. Minjun”이라고 부른다. 다른 모든 EN 장면은 “Minjun”이다. | “Minjun,”. |
| 7 | EN 대사 인용부호: `arc_y5_general_name_boundary_exact`(중개사 통화 대사), `arc_y5_room_consent_receipt`(다은 대사) | 소리 내어 한 말이 작은따옴표로 되어 있다. 같은 장의 다른 장면은 말은 큰따옴표, 문자·메모는 작은따옴표다. | 말은 큰따옴표로 바꾼다. 문자·메모의 작은따옴표는 유지한다. |

## 판단만 남기는 항목 (이 오더에서 고치지 않는다)

- **부정 나열 결말 습관**(“읽음도 답장도 … 생기지 않았다”, “계약서·등기 접수증·열쇠는
  없었다”)이 5장 거의 모든 결과문에 있다. `ORDER-148`(5장 종막의 부정 종결 습관)이
  소유하므로 여기서 중복 수리하지 않는다.
- **M58 `arc_y5_people_verdict`에서 현수와 민서가 같은 테이블에 앉는다.** 두 사람이
  서로 아는 사이가 되는 장면을 찾지 못했다. 민준이 둘을 부른 것인지 한 구절이
  필요한지 5장 HOLD 수리 쪽에서 판정한다.
- **M56 `arc_father_legacy` 선택 결과의 짧은 교훈형·주어 없는 EN 단편**(“Father isn't
  here. Did it anyway.”)은 초기 원고 문체다. EXPAND·ORDER-148 쪽에서 다시 쓴다.

## 결함 아님으로 확인한 것

- “38세 생일까지 7일”(결말 여러 곳): 3장 설날 수정(ORDER-350 2번)과 함께 연말 생일로
  일관된다.
- 상철의 “자네”, 다은의 “민준씨”, 민준의 “다은씨”: 각각 `STORY_BIBLE` 말투 정본과
  `ROMANCE_SYSTEM` 호칭 표에 맞다.
- 투자 기준 경로 계약 숫자(25억 8천만원·계약금·손실 상한·R3 추가 조달 7천만원·
  조달 상한 11억 8천→7억 6천만원): 장면 사이에서 서로 맞는다.

## 완료 조건

- 착수 조건 확인 기록을 먼저 남긴다.
- 1~7번이 KO/EN(해당 시 JA/zh-CN/zh-TW 오버레이 포함)에 반영된다. 5번은 KO/EN 두
  경로(`minseo_real_talk`·`got_minseo_card` 유무)로 실제 StoryMode 표시를 확인한다.
- `python3 tools/en_coverage_check.py`와 `python3 tools/audit_select.py -- <변경 파일>`
  PASS. 해시 고정 검사가 걸리면 기존 소유 오더의 갱신 규칙을 따른다.
- `WORK_LOG`와 이 사양 머리말·큐 행 상태를 함께 갱신한다.
- 원어민·외부 플레이테스트 게이트는 OPEN으로 남는다.
