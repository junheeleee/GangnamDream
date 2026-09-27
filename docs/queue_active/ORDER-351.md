# Active Queue Spec: ORDER-351

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [ ] ORDER-351 [P1·본편] 4장 M37~M48 대본의 아버지 행방·영어 표기 정합을 고친다

**2026-09-27 Claude 발행.** 본편 대본 정합 검토 계획
([FULL_GAME_SCRIPT_REVIEW](../queue_backlog/FULL_GAME_SCRIPT_REVIEW.md))의 배치
R4다. story_map M37~M48 root 16장면(3년치 영수증, 민서 등장·재회, 36세 갈림길,
세 약속, 놓친 두 자리, 새벽 두 시의 다은, 같은 식탁, 세 줄의 값, KTX 열한 분,
빌린 이름, 청구서 밤, 아버지 위기·별세, 비워 둔 한 칸, 36세 결산)을 KO/EN으로
읽고, 아버지 병세는 `MainGame.gd` 스케줄과 `ROMANCE_SYSTEM.md` 다은 라인(t168
상견례)에 대조했다.

## 깊이 3문

1. **왜 지금인가?** 4장은 아버지 임종으로 가는 장이다. 아버지가 입원 중인지 식당에
   나올 수 있는지가 장면마다 다르면 가장 무거운 장면의 신뢰가 무너진다.
2. **무엇을 바꾸지 않는가?** gameplay key, 선택 수, 효과, 이벤트 ID, 스케줄 조건,
   의료 경과 판정(2-of-3), 경제 수치는 바꾸지 않는다. 문장 구절만 더하거나 바꾼다.
3. **순서는?** 3장 오더(ORDER-350) 뒤. 본편 HOLD와 사람 게이트는 바꾸지 않는다.

## 수리 목록

| # | 위치 | 결함 | 수리 방향 |
|---:|---|---|---|
| 1 | 아버지 행방: `arc_y4_three_promises`(W153) 본문, `arc_y4_family_partner_collision`·`_jiyeon`(W167) 본문, `arc_father_call_on_ktx`·`_number`(W174) 본문. 모두 KO/EN | 마지막 입원 장면은 M24 병실이고 M25에는 아버지가 수요일 낮에 먼저 전화한다(퇴원 뒤). 4장은 설명 없이 W153에 “아버지 병동”, W167에 아버지가 서울 식당을 예약해 다은과 마주 앉고, W174에 다시 “아버지가 있는 병원”이다. 퇴원·재입원이 한 번도 나오지 않는다. | 아버지를 식탁에 두는 연애 정본(t168 상견례)을 유지하고 구절만 더한다. W153 “다시 입원한 아버지의 병동”, W167 “퇴원 뒤 처음 서울에 올라온 아버지”, W174 “다시 병원으로 돌아간 아버지”. 새 장면이나 플래그는 만들지 않는다. |
| 2 | EN 병원 이름: `content/events_en/arc_chapter_themes.json`(5곳) ↔ `content/events_en/arc_events.json`(5곳) | 같은 “창원 성심병원”이 한쪽은 “Changwon Sacred Heart Hospital”, 다른 쪽은 “Changwon Sungsim Hospital”이다. | 고유명사 음역 “Sungsim”으로 통일한다. JA/zh 오버레이도 한 표기로 맞춘다. |
| 3 | `content/events_en/arc_new_characters.json` `arc_minseo_01_meet` 본문 | 대사 속 “[rented deposit-only]”와 별도 문단 “[Jeonse: Korea's unique …]”가 번역자 주석처럼 본문에 그대로 나온다. EN 규칙은 문맥으로 못 푸는 명사만 첫 등장에 짧게 설명한다. | 대괄호 두 곳을 지우고, 이 장면이 EN 첫 등장이면 대사 밖 한 구절로(“on jeonse—a large deposit instead of monthly rent—”) 설명한다. 앞 장면에서 이미 설명됐으면 설명 없이 쓴다. |
| 4 | `content/events/arc_chapter_themes.json` `arc_36_unexpected_hand`·`_person_deal` 본문·선택, 같은 EN | “사람·진료 창구”, “병동이 아닌 사람·진료 창구”, “누구 또는 어느 창구”가 플레이어 화면에 그대로 나온다. 변형 슬롯 이름처럼 읽힌다. | 놓친 사람을 가리키는 자연어로 바꾼다(예: “기다리게 한 사람” / “the person he left waiting”). 다은·지연·무연애 경로 모두에 참인 표현을 쓴다. |
| 5 | `content/events/arc_chapter_themes.json` `arc_35_path_cost` 선택 2 결과, 같은 EN | “미뤘던 전화 한 통을 걸었다. 혹은 검진을 예약했다.” 서술자가 무엇을 했는지 정하지 않는다. | 한 행동으로 확정한다(예: 전화). |
| 6 | `content/events_en/arc_chapter_themes.json` `arc_y4_family_partner_collision` 선택 1 결과 | 다은이 민준의 아버지를 “Father”라고 부른다. KO “아버님”의 직역이라 영어에서는 자기 아버지를 부르는 말로 읽힌다. | “sir”로 바꾼다. 지연 변형에도 같은 호칭이 있으면 함께 맞춘다. |

## 판단만 남기는 항목 (이 오더에서 고치지 않는다)

- **4장 root 대부분이 W 단위 편성 의도(“W153 shipping StoryMode가 …”)를 beat
  intent에 적고 있다.** 산문의 인물 행동은 의도대로지만, 장면 설명문(“누구도 다른
  약속을 대신 취소해 주지 않았다”, “아버지도 다은도 이미 식탁에 앉아 있는 사람처럼
  말하지 않았다”)이 시스템 계약을 산문으로 옮긴 문장으로 읽힌다. EXPAND 저작 때
  감각 장면으로 다시 쓴다.
- **민서가 M37 선택 2(말을 걸지 않음) 경로에서도 M40에 “그날 오셨던 분이죠?”라고
  알아본다.** 청중 한 명을 기억하는 근거가 약하다. 민서 5장 도착 장면과 함께 보기
  위해 R5 뒤로 미룬다.

## 결함 아님으로 확인한 것

- 다은의 “민준씨”(붙여 씀): `ROMANCE_SYSTEM.md` 호칭 표 정본이다.
- M45 “같이 산 시간”: 다은 라인은 프로포즈(t150+) 뒤 “우리 집” 아크가 있다.
- 36세 갈림길의 “마감까지 2년이 채 남지 않았다”, “36세의 마지막 밤”: 나이·기한 계산과 맞다.

## 완료 조건

- 1~6번이 KO/EN(해당 시 JA/zh-CN/zh-TW 오버레이 포함)에 반영된다.
- `python3 tools/en_coverage_check.py`와 `python3 tools/audit_select.py -- <변경 파일>`
  PASS. 해시 고정 검사가 걸리면 기존 소유 오더의 갱신 규칙을 따른다.
- `WORK_LOG`와 이 사양 머리말·큐 행 상태를 함께 갱신한다.
- 원어민·외부 플레이테스트 게이트는 OPEN으로 남는다.
