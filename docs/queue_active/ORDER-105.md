# Active Queue Spec: ORDER-105

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-105 [P0·서사 원고] M02~M12의 빈 장면과 중복 장면 20개를 실제 원고로 고친다

**사용자 지시 (2026-08-18):** 사용자가 밖에 있는 동안 시스템·UI·저장·밸런스가
아니라 처음부터 완결까지의 스토리·지문·선택지에 시간을 쓴다. ORDER-104의 5장
기준 앵커 다음에는 월 순서대로 첫해의 빈 구간을 채운다.

## 깊이 3문

1. M03·M04의 첫 만남은 강하지만 M05 두 번째 만남, M06 첫 청구서의 지연·상철
   경로, M09의 지연·현수·무연결, M11의 실제 세 문은 원고가 없거나 다른 첫
   만남을 재사용한다. 이 상태에서는 월간 약속을 골라도 같은 장면을 보게 된다.
2. M07은 방 계약을 먼저 하고 M08은 다시 방을 고르며, M08의 즉시 이사 후속을
   M10이 첫날 밤처럼 반복한다. 원고만으로도 계약→작별·이사→한 달 뒤 공과금의
   실제 시간 순서를 복원해야 한다.
3. 라우팅까지 함께 고치면 원고 판정과 런타임 이관이 섞인다. 이번 배치는 기존
   root의 텍스트와 author-only 신규 root만 소유하고, 실제 selected receipt
   dispatch는 `needs_rule/NEW`로 다음 이관 오더에 남긴다.

## 배치 — 정확히 20개 판정 단위

1. M02 `arc_temptation_clean` — 거절 뒤 은행 앱·차단 목록·남은 야간노동.
2. M02 `arc_temptation_fallout` — 계좌를 빌려준 뒤 실제 반환 요청과 즉시 대응.
3. M05 `arc_y1_daeun_second_crossing` — 민준이 먼저 잡은 다은의 두 번째 약속.
4. M05 `arc_y1_jiyeon_second_crossing` — 보상 연락이 아닌 민준의 두 번째 연락.
5. M06 `v2_demo_first_bill_opening` — M02 결과와 M05 주력 인물이 첫 장에 남는다.
6. M06 `v2_demo_first_bill` — 실제로 끝낸 일과 그 밤 놓친 일을 함께 적는다.
7. M06 `arc_y1_jiyeon_first_bill_date` — 지연과의 첫 데이트 문턱.
8. M07 `arc_y1_hyunsu_result_fail_after_move` — 계약금 알림과 현수의 실패 문자가
   같은 주말에 온다. 기존 `hyunsu_result_fail`은 이사·근무 포기를 보장하지 않아
   원고를 덮지 않고 그대로 보존한다.
9. M08 `arc_goshiwon_goodbye` — 방을 다시 고르지 않고 포장·작별·이사로 간다.
10. M09 `arc_daeun_02_regular` — 다은에게 먼저 연락한 경로만 실제 도착한다.
11. M09 `arc_y1_jiyeon_relationship_reentry` — 지연에게 미뤄 둔 답을 먼저 말한다.
12. M09 `arc_y1_hyunsu_relationship_reentry` — M07 이사 계약과 M09 첫 방값을 실제로
    끝낸 현수 경로. 현수는 메시지 상대이며 동석하지 않는다.
13. M09 `arc_y1_relationship_reentry_none` — 보내지 않은 초안과 빈 주말을 남긴다.
14. M10 `arc_y1_new_room_first_month` — 이사와 첫 공과금 납부를 실제로 끝낸 경로의
    한 달 뒤. 이사 첫날을 다시 재생하지 않는다.
15. M11 `arc_y1_jaehyuk_open_door` — M05 재회를 기억한 채 투자 전의 일터 문을 연다.
16. M11 `arc_y1_sangchul_open_door` — 지정 주소에서 소개인·수수료를 직접 묻는다.
17. M11 `arc_y1_current_route_open_door` — 느린 합법 경로의 연장·승급 면담.
18. M11 `arc_y1_open_door_none` — 세 문을 모두 놓친 실제 빈 주소와 지난 시각.
19. M12 `arc_year1_close` — 모든 런에서 참인 연말 결산을 두고, 실제 M12 receipt는
    조건부 기억에서만 사물로 회수한다.
20. M12 `arc_y1_close_hyunsu_call` — 아버지 대사를 복사하지 않은 현수 연말 통화.

신규 단위는 300~800자 규모의 핵심 교환과 2~4개의 서로 다른 선택을 갖는다.
기존 `v2_demo_first_bill`은 저장·선택 identity 때문에 기존 8개 선택을 그대로
보존하고 각 결과를 한 원고 단위로 함께 판정한다.
선택 전에는 먼 결과를 설명하지 않고 지금 도착한 사람·문서·마감만 보여 준다.
선택된 약속 또는 완료·미룸·만료 receipt는 첫 문장·참석자·부재·선택지 중 하나에
드러나야 한다. 다은·지연, 상철·재혁, 아버지·현수의 원고를 서로 바꿔 쓰지 않는다.

## 시간·경로 불변

- M07은 방 계약, M08은 고시원 작별과 이사다. M08에서 방을 다시 고르지 않는다.
- `arc_goshiwon_goodbye → arc_housing_new_life`는 같은 이사 체인의 즉시 후속으로
  보존한다. M10은 `첫날 밤`이 아니라 `새 방의 첫 공과금`이다.
- M05 재혁 장면은 첫 재회이고 M11은 그 재회를 기억한 두 번째 문이다.
- `arc_y1_hyunsu_result_fail_after_move`는 `m07_sign_move_contract=completed`와
  `m07_take_weekend_shift=expired`를 함께 읽는 경로만 연다. 이사와 주말 근무를
  모두 지킨 경로에 근무 포기 문장을 재사용하지 않는다.
- M09의 다은·지연·현수·아무도 없음은 네 실제 경로이며 이름 언급만 바꾼 공용문이
  아니다. 현수 메시지를 실제 동석처럼 쓰지 않는다.
- 현수 M09 원고는 `m07_sign_move_contract`와 `m09_settle_new_room` 완료를 함께
  요구하고, M10 원고는 첫 공과금 완료 receipt를 요구한다. author-only 원고를
  이관할 때 이 복합 조건 없이 관계 selector 하나로만 열지 않는다.
- M12는 장기 결정 7개를 늘리지 않는다. 구체 receipt는 실제 조건부 기억에서만
  보여 주고, 네 carryover의 정확한 다음 장 결과를 선택 전에 공개하지 않는다.

## 정확한 파일 소유권

**선언·마감:** `CLAUDE.md`, `docs/CODEX_QUEUE.md`, 이 사양,
`docs/WORK_LOG.md`.

**KO 원고:** `content/events/arc_events.json`, `content/events/arc_daeun.json`,
`content/events/core_loop_v2_events.json`, `content/events/arc_hyunsu.json`,
`content/events/arc_midgame.json`, `content/events/arc_year_close.json`.

**EN 원고:** 위와 같은 이름의 `content/events_en/` 6파일.

`story_map`, `story_rules`, DataRegistry, 런타임·UI·저장·밸런스·자산과 검사는
수정하지 않는다. 기존 root는 title/description/choice text/result 같은 텍스트만
바꾸고 ID·조건·선택 수·순서·효과·flag·follow-up을 보존한다. 신규 root는
`weight:0`, `hidden:true`, `min_turn:9999`, 신규 영구 flag/effect/follow-up 0이다.
따라서 최종 분류는 기존 텍스트 확장 7개와 신규 author-only 13개다.

## 완료 증거

- **L1/L2 완료:** 20개 root KO/EN 존재, 선택 수·순서·placeholder 의미 패리티.
- 기존 7개 root의 텍스트 외 게임 구조가 선언 commit과 byte-equivalent다.
- 신규 13개 root의 author-only metadata와 신규 writer flag 0이다.
- strict JSON, 한영 coverage, story consistency, speech register,
  `audit_select --list`, `git diff --check`가 통과했다.
- 독립 최신 바이트 검토는 선택하지 않은 행동·사물·인물 발명, 경로별 공간·시간
  점프, 안전한 지배 선택을 다시 읽고 `P0=0 / P1=0`으로 판정했다.
- 전체 감사·240주 시뮬레이션·Godot 장시간 검사는 실행하지 않는다.

## 사람 판정

L1 정합과 L2 낭독까지 진행한다. 사용자가 돌아오면 20개 중 무작위 3개를 읽고,
하나라도 인물 목소리·현재의 손실·다음 장면을 기다리게 하는 여운이 약하면 배치를
전량 반려한다.
