# Archived Queue Spec: ORDER-107

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [!] ORDER-107 [조건부 반려] M25~M36 원고 중 지목 1편을 다시 쓴다

**사용자 지시 (2026-08-18):** 사용자가 밖에 있는 동안 시스템·UI·저장·밸런스가
아니라 처음부터 완결까지의 스토리·지문·선택지에 모든 시간을 쓴다. 형식적인 순서
맞추기가 아니라, 지금 손에 든 기록과 눈앞의 사람 사이에서 실제로 하나를 포기하게
하는 장면을 쓴다. 선택 전에는 먼 결과·관계 단계·엔딩을 스포일러하지 않는다.

## 깊이 3문

1. M30~M33의 재혁 사기와 상철 대면은 기존 원고가 강하다. 그 선택 노드를 M34에서
   다시 재생하면 플레이어가 이미 끝낸 결정을 또 고르게 된다. 이번 배치는 폭발 장면을
   고쳐 쓰지 않고, 그 뒤 두 달 동안 남은 비용과 사람의 반응을 새 장면으로 쓴다.
2. 상철 진실의 실제 정본은 `buried / distanced / reported / forgiven / leveraged /
   repaid` 여섯 귀결이다. 넓은 요약 fact로 합쳐 같은 후속문을 붙이지 않고, 각 귀결에서
   현재 남아 있는 문서·돈·연락·침묵을 별도 원고로 회수한다.
3. M35에서 아버지·현수·아무도 없음은 ‘누구에게 말할까’를 다시 고르는 선택지가 아니다.
   이미 선택한 listener receipt가 실제 듣는 사람과 첫 반응을 정하고, 장면 안 선택은
   무엇을 숨기거나 어디까지 책임질지에만 쓴다. 라우팅 구현은 별도 이관 오더가 소유한다.

## 배치 — 정확히 20개 판정 단위

1. M25 `arc_y3_father_after_visit_document` — 선택한 문서 대조 안에서 이름·주소 / 보증·
   손실 조항 / 확인·미확인 표 중 한 방식으로 두 원문을 실제 비교 완료한다.
2. M25 `arc_y3_father_deferred_call` — 문서 대조 뒤 선택한 아버지 통화 안에서 출처를
   직접 묻기 / 병실을 피한 사실 인정 / 다음 답변 시각 고정을 현재 대화로 분리한다.
3. M25 `arc_y3_father_avoidance_document` — 병실을 피한 경로의 선택된 연락 안에서
   음성·첫 장·미개봉 상태 중 하나로 회피를 인정하고 실제 발신 시각을 남긴다.
4. M26 `arc_y3_birthday_father_call` — 선택한 생일 통화 안에서 오늘 목소리 / 상환서
   발급처 한 문장 / 자정까지 통화만 유지하기를 나누며 다른 월 행동을 실행하지 않는다.
5. M27 `arc_y3_jaehyuk_pitch_questions` — 선택한 호텔 피치의 스물세 분 안에서 원문에
   없는 3배 / 수취인과 회사 관계 / 친구 이름이 필요한 이유 중 하나를 끝까지 묻는다.
6. M28 `arc_y3_jiyeon_departure_platform` — 지연의 출발 전 플랫폼에 실제 도착한
   경로. 붙잡는 말 / 조건 없는 배웅 / 답을 미룬 채 열차를 보내는 현재 손실을 쓴다.
7. M28 `arc_y3_daeun_hometown_departure` — 다은의 고향행 버스 앞에서 동행할 범위 /
   서울에 남아 지킬 일 / 다음 약속을 만들지 않는 작별을 다은의 말투로 나눈다.
8. M28 `arc_y3_relationship_departure_unattached` — 이어진 연인이 없고 아버지 전화를
   선택한 경로에서 이름 / 침묵 이유 / 끼어들지 않기를 달리하되 고백을 끝까지 듣는다.
9. M29 `arc_y3_jaehyuk_waiting_screen` — 선택한 마지막 질문으로 설명 의사 / 발행처·
   원본·수취 관계 / 독립 검토 사실 중 하나를 자정 기한과 함께 실제 전송한다.
10. M30 `arc_y3_jaehyuk_no_contact` — 연락두절 경로에서 선택한 마지막 답을 음성사서함 /
    미읽음 대화방 / 회사 주소 등기 중 한 채널로 발신하고 친구 연락을 닫는다.
11. M32 `arc_y3_truth_unproven` — 기록이 모자란 경로에서 선택한 상철 통보를 확인된
    사실과 빈칸 / 가린 사본 / 증거 없는 대면 시각 중 하나로 실제 전송한다.
12. M34 `arc_y3_cost_after_reported` — 신고를 끝낸 뒤 경찰서 참고인 출석 통지가 다시
    시간을 청구한다. 접수번호와 대기번호가 붙은 종이를 들고 조사실 앞에 앉는다.
13. M34 `arc_y3_cost_after_forgiven` — 용서 뒤 상철과 처음 다시 마주 앉아 식은 커피를
    마신다. 사과를 받은 것과 예전 거래 방식으로 돌아가는 것은 다르다.
14. M34 `arc_y3_cost_after_leveraged` — 실제 상담 접수대에서 `소개자: 임상철`이 찍힌
    우대 배지와 일반 수수료표를 함께 받는다. 얻은 이익의 출처가 몸에 달린다.
15. M34 `arc_y3_cost_after_repaid` — 상철의 입금 거래내역과 아버지의 오래된 완납확인서를
    은행 발급기 불빛 아래 겹친다. 맞는 금액과 돌아오지 않는 시간이 갈린다.
16. M34 `arc_y3_cost_after_buried` — 정식 명단에는 없고 `임상철 소개`만 찍힌 좌석표를
    받는다. 묻은 진실이 기록 없는 호의를 허락한 것처럼 쓰인다.
17. M34 `arc_y3_cost_after_distanced` — 현재 주소 관리실에 상철 사무소가 직접 맡긴
    무표기 봉투가 도착한다. 끊은 관계가 매일 드나드는 생활공간까지 들어온다.
18. M35 `arc_y3_truth_heard_by_father` — 아버지가 실제로 들은 경로. 설명 / 변명하지
    않고 책임 인정 / 묻지 못한 보증 한 줄을 되묻기를 아버지의 반응과 함께 쓴다.
19. M35 `arc_y3_truth_heard_by_hyunsu` — 현수가 실제로 들은 경로. 숫자 원문 / 친구로서
    한 말 / 다음 행동의 경계를 현수의 구체적인 첫 반응과 함께 쓴다.
20. M35 `arc_y3_truth_heard_by_none` — 아무에게도 말하지 못한 경로. 월 행동이 끝난 늦은
    밤에 미전송 진술 / 개인 사본 / 다음에 물을 한 문장 중 무엇을 남길지 스스로 정한다.

기존 active root는 텍스트까지 선언 commit과 동일하게 보존한다. 신규 20개는 KO
description 300~800자를 지키며, 14개는 2~4개의 서로 다른 선택을 갖는다. M34 여섯
terminal은 후속 문학 보정에서 새 결정을 묻지 않는 단일 consequence delivery로 바뀌어
각 1개의 진행 동작만 둔다. 모두 `weight:0`, `hidden:true`, `min_turn:9999`, 신규 영구
writer/effect/flag/follow-up 0을 지킨다. 선택 전에는 미래의 득실을 설명하지 않고 현재 도착한 사람·
문서·시각만 보여 준다. 선택 뒤에는 지금 얻은 것과 바로 잃은 것 중 적어도 하나를
대사·행동·물건으로 회수한다.

## 시간·경로 불변

- M30 `arc_jaehyuk_04a_ghost`, M32 `arc_sangchul_deduction`, M33
  `arc_sangchul_confrontation`, M36 `arc_year3_close`의 강한 기존 원고와 구조는 동결한다.
- M33의 `arc_sangchul_buried_silence`, `arc_sangchul_stairwell`,
  `arc_sangchul_reckoning`은 그 자리의 선택·즉시 결과다. M34에서 재사용하지 않는다.
- M34 여섯 root는 `sangchul.truth_resolution`의 실제 terminal 값 하나와 정확히
  대응한다. `story.sangchul_truth_resolution`의 압축 이름만으로 서로 다른 결과를
  합치지 않는다.
- M35 세 root는 selected listener가 각각 father / hyunsu / none인 경로만 읽는다.
  장면에서 listener를 다시 고르지 않고, 존재하지 않는 동석자·과거 대면을 발명하지 않는다.
- 모든 신규 root는 한 개의 selected commitment 또는 그 완료 뒤의 consequence를 정확히
  읽는다. 장면의 2~4개 선택은 그 행동을 모두 완료하거나 완료 뒤의 태도만 가르며, 월초에
  이미 고른 다른 commitment를 다시 고르거나 완료·실패로 덮어쓰지 않는다.
- M34 여섯 root는 모두 `m34_set_sangchul_boundary`를 선택한 경로의 terminal별 consequence
  delivery다. 문자·음성·공식 통지 중 전달 채널을 다시 고르지 않고, 신고 뒤 참고인 출석,
  용서 뒤 첫 대면, 우대 배지, 돌아온 입금, 명단 밖 좌석, 생활공간에 도착한 봉투처럼
  각 terminal에서만 벌어지는 사건 하나를 단일 진행 동작으로 끝까지 통과한다.
- M28 세 사람 갈래는 각각 `m28_reach_jiyeon`, `m28_keep_daeun_family_departure`,
  `m28_answer_father_confession`을 선택한 경로만 읽는다. 미선택 갈래는 별도 planned
  fallback이며 이 원고가 거짓 도착·통화를 만들지 않는다.
- M25는 실제 전화·문서 채널을, M28 지연은 플랫폼/메시지를, 다은은 고향행 버스를,
  M32의 아버지는 대면이 아닌 전화를 쓴다. 기존 map label이 다른 채널을 말해도 원고가
  거짓 도착을 만들지 않으며, 후속 라우팅이 정확한 receipt로 결속한다.
- 재혁 피치의 선택은 먼 수익·파산·배신을 예고하지 않는다. M29도 실제 송금을 보장하지
  않으므로 호텔에서 받은 계좌 사본만 쓰며, 세 갈래 모두 마지막 질문과 기한을 전송한다.
- 지연은 정본상 관계 단계가 명시적으로 말을 놓게 하지 않는 한 민준과 상호 존댓말을 쓴다.

## 파일 소유권

**큐·기록:** `CLAUDE.md`, `docs/CODEX_QUEUE.md`, 이 사양,
`docs/WORK_LOG.md`, 생성 문서 `docs/STATUS.md`.

**KO 원고:** `content/events/arc_events.json`, `content/events/arc_midgame.json`,
`content/events/arc_year3_drama.json`, `content/events/arc_daeun_extension.json`,
`content/events/arc_drama.json`.

**EN 원고:** 위와 같은 이름의 `content/events_en/` 5파일.

`story_map`, `story_rules`, DataRegistry, 런타임·UI·저장·밸런스·자산은 수정하지 않는다.
author-only root의 실제 selected receipt dispatch는 별도 이관 오더가 소유한다.

## 완료 증거

- [x] 정확히 20개 root·48개 choices/locale가 KO/EN에 존재하고 ID·선택 순서·
  placeholder 의미가 대응한다.
- [x] 선언 당시 존재한 active root는 텍스트를 포함한 전체 object가 선언 commit
  `28cfaa7`과 동일하다.
- [x] 신규 20개 root가 KO/EN 300~800자·metadata·writer 0 계약을 지킨다.
- [x] M34 여섯 terminal은 서로 다른 사건·장소·주요 물건을 갖고, M35 세 listener는
  서로 다른 현재 물건·목소리·즉시 손실을 갖는다.
- [x] strict duplicate-key JSON, 한영 coverage, story consistency, speech register,
  exact-scope contract, `audit_select --list`, `git diff --check`를 통과한다.
- [x] 독립 L2 최신 바이트 낭독에서 선택 지배·선취·공간 점프·거짓 배우·미래
  스포일러 P0/P1 0, GO를 받았다.
- [!] Claude 위임 L3에서 1편이 조건부 반려됐다. 사용자 최종 GO는 OPEN이다.
- 전체 감사·240주 시뮬레이션·Godot 장시간 검사는 실행하지 않는다.

## 2026-08-21 L3 판정

- 방법: 모집단 20편에서 seed 9821 무작위 3편. 세 판정축은 동일하다.
- **판정: Claude(사용자 위임) — 조건부.** 다른 두 표본은 통과하고
  `arc_y3_father_after_visit_document`만 재작성한다. 아버지가 장면에 없고 세 선택이
  이름·조항 대조와 색칠이라는 기록 방식에 머문다.
- 원 오더의 집필·검토는 종료하고 국소 복구를 ORDER-117로 이관한다.
- **사용자 최종 GO: 미서명(OPEN).**
