# Active Queue Spec: ORDER-106

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-106 [P0·서사 원고] M13~M24의 압축 연쇄와 빈 경로 24개를 실제 원고로 푼다

**사용자 지시 (2026-08-18):** 사용자가 밖에 있는 동안 시스템·UI·저장·밸런스가
아니라 처음부터 완결까지의 스토리·지문·선택지에 시간을 쓴다. M02~M12 L1/L2
완료 뒤 두 번째 해를 월 순서로 잇고, 형식적인 선택이 아니라 지금 잃을 것을 두고
플레이어가 고민하는 장면을 쓴다.

## 깊이 3문

1. 현재 런타임은 `year_one_mark → money_attracts → sangchul_network`,
   `daeun_fork → father_medication → jiyeon_offer`, `doors_open → parents_visit →
   father_hospital`을 같은 시기에 연속 재생한다. 이 원고를 단순히 다음 달 문장으로
   바꾸면 이미 끝낸 장면을 반복하므로, 활성 연결은 모든 경로에서 참인 안전본으로
   남기고 월별 장면은 author-only로 분리한다.
2. M20의 상철·지연·카지노·아무 문도 못 연 결과와 M22의 다은·지연·무연애 결과는
   서로 다른 사람·장소·손실을 갖는다. 인물 이름만 바꾼 공용문이나 한 문단의
   조건 나열로 덮지 않는다.
3. 이번 배치는 원고만 판정한다. selected commitment·receipt를 실제로 dispatch하는
   라우팅, `story_rules`, 저장·UI·밸런스는 별도 이관 오더가 소유한다. 단, 장면보다
   먼저 약속이 잡혔다고 스포일러하던 M13 commitment의 플레이어 노출 label 한 줄은
   실제 행동 순서에 맞게 함께 고친다.

## 배치 — 정확히 24개 판정 단위

1. M13 `arc_year_one_mark` — 첫해 장부에서 혼자 만든 것과 사람이 열어 준 것을
   구분한다. 두 줄 기록 / 빈칸 표시 / 새해 한 약속만 달력에 옮기기.
2. M14 `arc_y2_money_structure` — 이미 고른 열린 빚 상환 현장에서 내역 확인 후
   이체 / 기한 우선 / 설명 없는 처리비 이의 중 하나로 첫 금액을 실제 처리한다.
3. M14 `arc_y2_bank_limit_review` — 이미 고른 은행 상담에서 파산 조건 확인 / 자기
   소득 한도 / 신청 없이 한도서만 받기를 나눈다.
4. M14 `arc_y2_sangchul_source_review` — 이미 고른 상철 소개 자리에서 자금 출처 /
   소개비·후속 비용 / 서면 없는 다음 만남 거절을 나눈다.
5. M15 `arc_father_medication` — 약 이름 없는 어머니 문자 뒤 아버지에게 전화 /
   어머니에게만 회신 / 주말 방문 약속을 현재 행동으로 나눈다.
6. M16 `arc_34_routine_trap` — 반복표가 몸과 사람 시간을 먼저 쓰는 장면. 보호할
   시간 한 칸을 만들거나 반복 블록 하나를 실제로 지운다.
7. M17 `arc_sangchul_human` — 상철의 비어 있는 십몇 년과 같은 시각의 유급 저녁을
   함께 놓고, 공감 / 공백 질문 / 다시 집값·투자 이야기로 피하기를 구분한다.
8. M18 `arc_year_one_half` — 서울이 방보다 몸에 먼저 밴 것을 인정하고 현재 속도
   유지 / 기본값 하나 변경 / 오늘 하루 쉬기 중 한 가지를 실행한다.
9. M19 `hyunsu_reunion_later` — 취업 명함보다 실패 뒤의 현수를 먼저 볼 것인지,
   축하보다 얼굴 / 그날 문 앞의 첫 문장을 고른다.
10. M20 `arc_34_doors_open` — 특정 문을 골랐다고 단정하지 않는 활성 안전본.
   사람을 더 만나기 / 경계를 긋고 만나기 / 혼자 쌓기를 현재 태도로만 남긴다.
11. M20 `arc_y2_sangchul_chosen_door` — 지정 현장에서 소개인·수수료 확인 / 한 만남만
   수락 / 서면 조건이 없으면 퇴장. 상철 완료 receipt만 연다.
12. M20 `arc_y2_jiyeon_chosen_door` — 지연이 연 자리에 자기 이름으로 소개 / 집안이
    바라는 대가 질문 / 접근권은 거절하고 대화만 지키기. 지연 완료 receipt만 연다.
13. M20 `arc_y2_casino_chosen_door` — 정선 입구에서 동석자 확인 / 현금 봉투 한도 뒤
    입장 / 문 앞에서 귀가. 실제 카지노 초대 완료 receipt만 연다.
14. M20 `arc_y2_chosen_door_none` — 세 문을 놓친 뒤 남은 주소와 지난 시각에서 늦은
    사과 / 놓친 창 기록 / 모두 닫고 현재 일 마감을 고른다.
15. M20 활성 꼬리 `arc_34_parents_visit` — 상철 명함을 전제하지 않고 부모의 서울
    방문과 실제 저녁 일정만 충돌시킨다. 역에서 헤어지거나 방을 보여 준다.
16. M21 `arc_y2_open_door_cost` — 이미 고른 현장 정산 납부에서 항목 확인 / 기한
    우선 전액 / 설명 없는 관리비 이의를 나눈다.
17. M21 `arc_y2_open_door_cost_explanation` — 이미 고른 대면에서 상철 이름까지 공개 /
    자기 선택만 책임 / 새 날짜를 요구하지 않는 사과를 나눈다.
18. M21 `arc_y2_open_door_cost_cancel_repeat` — 이미 고른 반복 초대 취소에서 이번
    좌석만 / 명단 전체 / 서면 조건 전까지를 구분해 어디까지 닫을지 정한다.
    지연·카지노·none의 M21 비용은 별도 planned fallback이다.
19. M22 `arc_y2_daeun_relationship_fork` — 다은의 고향 가능성과 서울 비용 앞에서
    서울 부담 공유 / 고향 먼저 동행 / 기다려 달라 하지 않고 놓기를 나눈다.
20. M22 `arc_y2_jiyeon_relationship_fork` — 사랑과 접근권 앞에서 소개 거절·관계 유지 /
    조건을 묻고 한 번 수락 / 분리할 수 없어 거리 두기를 나눈다.
21. M22 `arc_y2_relationship_fork_unattached` — 이어진 연인이 없는 경로에서 이미
    고른 주거 갱신을 일 년 / 짧은 계약·더 큰 보증금 / 퇴실로 나눈다.
22. M23 `arc_y2_hospital_door` — 다른 월간 약속을 다시 고르지 않고 아버지 병실의
    장기 결정을 토요일 도착 / 월요일로 미룸 / 비용만 보내고 이번 입원 불참으로 나눈다.
23. M24 `arc_year2_close` — t96이면 항상 참인 물건만 쓰는 활성 안전본. 지킬 일정
    하나 / 돈과 사람 비용을 같은 장 / 목표 숫자만 남기기를 나눈다.
24. M24 `arc_y2_year_boss_receipts` — 실제 M20 문·M23 병실 문·M24 약속을 한 책상에
    놓고 청구 / 문 주인 / 지킬 사람 / 모두에게 기한 연장 중 하나를 명시한다.

신규 15개는 300~800자 핵심 교환과 2~4개의 서로 다른 선택을 갖는다. 기존 9개는
선택 수·순서·효과·flag·follow-up을 그대로 둔 채 title·description·choice text·
result만 고친다. 선택 전에는 다음 달 보상·관계 단계·엔딩을 설명하지 않고, 현재
도착한 사람·문서·마감만 보여 준다. 선택 뒤에는 확보한 것과 바로 잃은 것 중 적어도
하나를 행동·대사·물건으로 회수한다.

## 시간·경로 불변

- `arc_year_one_mark → arc_34_money_attracts_money → arc_sangchul_03_network`,
  `arc_daeun_03_fork → arc_father_medication → arc_jiyeon_03_offer`,
  `arc_34_doors_open → arc_34_parents_visit → arc_father_03_hospital`의 현재 즉시
  연결을 월별 receipt 증거로 사용하지 않는다.
- `arc_year_one_mark`는 월초 bridge다. C3은 실제 actor 한 명·지킬 시각·보낼 문장
  초안까지만 준비하고 전송하지 않는다. 이후 `m13_return_to_person`을 선택한 경우에만
  실제 연락·시각 제안과 completion receipt가 생기며, bridge가 같은 행동을 선취하지 않는다.
- `arc_34_money_attracts_money`, `arc_sangchul_03_network`, `arc_daeun_03_fork`,
  `arc_jiyeon_03_offer`, `arc_father_03_hospital`, `arc_34_two_years_in`은 이번 배치에서
  동결한다. 월별 사실을 덧씌우지 않는다.
- M20 네 경로는 각각 정확한 완료·미완료 receipt와 배우를 요구한다. 상철·지연·
  카지노 초대의 물건과 목소리를 서로 바꿔 쓰지 않는다.
- `arc_y2_chosen_door_none` 기준 원고는 세 문 완료가 0이면서
  `m20_keep_paid_shift=completed`인 경로만 읽는다. 유급 근무까지 놓친 경로에는
  종료 시각·확인 번호를 발명하지 않고 별도 planned fallback을 쓴다.
- M14 세 원고는 각각 같은 이름의 selected commitment 하나만 현장으로 옮긴다.
  둘째까지 고른 달에는 두 원고가 각자 due week에 도착하며 어느 원고도 다른 두
  commitment를 만료시키거나 다시 고르게 하지 않는다.
- M21 세 원고도 각각 `m21_pay_open_door_cost`, `m21_tell_the_cost`,
  `m21_cancel_repeat_invitation` selected commitment만 읽는다. 납부 원고는 M20에서
  실제 한 구역에 들어간 선택, 대면 원고는 현장 담당자와 후속 약속이 남은 선택만
  읽고, 그 밖의 결과는 별도 planned fallback으로 둔다.
- `arc_sangchul_human`은 `m17_join_sangchul_dinner=completed`이면서
  `m17_keep_paid_evening_shift=expired`인 기준 원고다. 유급 교대를 지켰거나 두
  약속을 모두 완료한 경로에 같은 오후 여덟 시 만료 결과를 재사용하지 않는다.
- M22 다은·지연·무연애는 세 실제 root다. 다은·지연 원고의 접근권·고향·말투를
  서로 교체하지 않는다.
- 무연애 root는 `m22_answer_lease_renewal=selected`인 주거 현장만 소유한다.
  `m22_close_honestly`의 실제 상대가 있는 경우에는 다은·지연의 해당 관계 원고나
  별도 actor-bound fallback을 쓰며, 무명 대화창을 만들어 갱신과 다시 고르게 하지 않는다.
- M23 병실 장면은 실제 입원 사실과 M23 선택을 함께 요구한다. M20 부모 방문이나
  옛 즉시 병원 follow-up만으로 월말 수입·KTX·원격 비용을 발명하지 않는다.
- 병실 장면은 `story.father_hospital_door`의 visited/deferred/avoided를 쓰는 plot
  stop이다. 월말 수입·상철 약속의 완료·만료를 대신 결정하거나 두 약속을 자동으로
  취소하지 않으며, selected commitment는 해당 병실 선택의 가용성만 연다.
- M24 활성 결산은 명함·병원 스티커·기차 영수증을 항상 단정하지 않는다. 그 세부는
  실제 M20/M23/M24 receipt를 읽는 author-only 보스 원고만 소유한다.
- `arc_y2_year_boss_receipts`는 1단에서 실제 비어 있지 않은 receipt만 목록화하고,
  2단 선택지는 그 실물에 exact availability를 건다. C1은 금액·기한·현재 납부 상태가 있는 청구,
  C2는 이름·주소·출처가 남은 문, C3은 실제 actor가 남은 약속이 있을 때만 보인다.
  C4는 아직 열린 대화 상대가 한 명 이상일 때만 보이며, 빈칸·만료 줄에서 사람이나
  대화창을 발명하지 않는다. 해당 실물이 없으면 그 선택은 숨긴다.

## 정확한 파일 소유권

**선언·마감:** `CLAUDE.md`, `docs/CODEX_QUEUE.md`, 이 사양,
`docs/WORK_LOG.md`, 생성 문서 `docs/STATUS.md`.

**플레이어 노출 문구:** `content/meta/story_map.json`의
`m13_return_to_person.label` 한 줄만. ID·source·axis·due·miss·after와 다른 월은
동결한다.

**KO 원고:** `content/events/arc_midgame.json`,
`content/events/arc_chapter_themes.json`, `content/events/arc_hyunsu.json`,
`content/events/arc_daeun.json`, `content/events/arc_events.json`,
`content/events/arc_year_close.json`.

**EN 원고:** 위와 같은 이름의 `content/events_en/` 6파일.

위 한 줄 외 `story_map`, `story_rules`, DataRegistry, 런타임·UI·저장·밸런스·자산과
검사는 수정하지 않는다. 신규 root는 `weight:0`, `hidden:true`, `min_turn:9999`, 신규 영구
flag/effect/follow-up 0이다. 최종 분류는 기존 텍스트 확장 9개와 신규 author-only
15개다.

## 완료 증거

- [x] 정확히 24개 root와 70개 choices/locale가 KO/EN에 존재하고 placeholder 의미가
  대응한다.
- [x] 기존 9개 root의 텍스트 외 게임 구조가 선언 commit `3c5d911`과
  byte-equivalent다.
- [x] 신규 15개 root는 300~800자, `weight:0`, `hidden:true`, `min_turn:9999`이며
  신규 writer/effect/flag/follow-up은 0이다.
- [x] strict duplicate-key JSON, 한영 coverage, story consistency, speech register,
  exact-scope contract, `audit_select --list`, `git diff --check`가 통과했다.
- [x] 두 번의 독립 최신 바이트 낭독에서 P0/P1 0, L2 GO를 받았다.
- [ ] L3는 사용자가 돌아온 뒤 무작위 3개를 읽어 판정한다.
- 전체 감사·240주 시뮬레이션·Godot 장시간 검사는 실행하지 않았다.

## 사람 판정

L1 정합과 L2 낭독까지 진행한다. 사용자가 돌아오면 24개 중 무작위 3개를 읽고,
하나라도 인물 목소리·현재의 손실·다음 장면을 기다리게 하는 여운이 약하면 배치를
전량 반려한다.
