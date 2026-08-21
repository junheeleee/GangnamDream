# Archived Queue Spec: ORDER-110

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [x] ORDER-110 [P0·서사 원고] 마지막 해의 한 기준 경로를 계약 도착부터 다음 주까지 실제 사건으로 완주한다

**사용자 지시 (2026-08-18):** “이제 이어서 작업해.” 이어 전달된 독립 원고 평가는
후반으로 갈수록 장면보다 지도 빈칸을 채우는 글이 됐다고 지적했다. M49~M60은
누락 root 수부터 세지 않고, 한 사람이 마지막 해에 실제로 겪는 사건의 순서부터 쓴다.

## 깊이 3문

1. 현재 M49~M60 표에는 월별 계약이 있지만, M49의 계산기 독백은 실제 최종 서류를
   만들지 않고 M50의 빈 페이지는 보호할 사람이나 검토자를 만나지 않는다. M59는
   계약을 실행하기 전에 이미 강남 매수와 축하를 끝낸다. 이 상태에서 fallback부터
   늘리면 서로 연결되지 않는 완성 원고만 많아진다.
2. 먼저 하나의 기준 경로를 끝까지 완주한다. `investment/property + 상철 제안자·검토자
   + 다은 보호 대상 + 재혁 보증 요청 + 아버지 별세·마지막 통화 + 다은 자필 범위
   + 자기 명의 접수·실행`을 기준으로 한다. 이 경로의 사건이 실제 물건과 대화로
   이어진 뒤에만 career/startup·지연·무연애·아버지 생존·다른 접수 상태를 변주한다.
3. ORDER-104의 강한 정점 문장은 다시 쓰지 않는다. 이번 배치는 그 정점 사이의 실제
   도착·전달·검증·접수·실행 영수증을 쓴다. 새 원고는 author-only reference이며
   StoryLedger·스케줄·엔딩 라우팅 승격은 별도 이관 오더가 소유한다.

## 기준 경로의 실제 사건

`투자계약 원문 도착 → 상철에게 원문 전체 전달 → 기존 수입 마감과 충돌 → 다은 이름
삭제본을 다은에게 공개 → 몸 검사 → 민서의 도착 뒤 질문 → 다은에게 30억 이후 삶을
묻기 → 상철의 일곱 장 제안과 동일본 전달 → 재혁 보증 PDF 도착·귀환 이유 청취·아버지
문서 대조·다은 공개·결정 → 상철의 빨간 원 → 네 사람 회의의 자필 범위 → 아버지의
마지막 통화 기록과 약봉지 → 다은이 실제 동석한 접수 창구 → 다은·현수의 판결 →
부동산 계약의 돈과 서류 실행 → 마지막 서명 → 플레이어가 먼저 여는 다음 주 대화방`

## 배치 — 정확히 20개 root / KO·EN 각 51 choices

### M49~M50 — 계약의 표지와 보호선 (4)

1. `arc_y5_contract_cover_investment` — 선택한 투자/property 경로의 실제 원문을 열고
   금액·손실 상한·이름 칸을 한 화면에 놓는다. 3 choices.
2. `arc_y5_contract_reviewer_delivery_sangchul` — 이미 정한 검토자 상철에게 원문 전체를
   실제로 보내고, 감출 수 없게 된 부족액·책임·기한 중 무엇부터 표시할지 고른다. 3.
3. `arc_y5_final_push_deadline_investment` — 이름 보호와 겹친 기존 수입·거래 마감에 실제로
   답한다. 연장 요청의 약점 공개, 현 조건 유지의 시간 손실, 추가 조건 거절의 금액 손실을
   현재 장면에서 회수한다. 3.
4. `arc_y5_protection_boundary_daeun` — 다은의 이름을 뺀 수정본과 줄어든 조건을 다은 앞에
   함께 놓는다. 보호를 대신 결정했다는 문제와 실제 포기한 숫자를 다은이 직접 말한다. 3.

### M51 — 도착 뒤의 몸과 사람 (3)

5. `arc_y5_minseo_goal_cost_reference` — 민준이 먼저 잡은 약속에서 민서가 도착 뒤의
   가격을 묻는다. 목표 달성 여부를 축하·위로로 선확정하지 않는다. 3.
6. `arc_y5_burnout_check_reference` — 선택한 몸 검사가 실제 진료실·검사표·수면 기록으로
   도착한다. 진단명이나 회복은 보장하지 않고 어떤 정보를 의사에게 넘길지만 고른다. 3.
7. `arc_y5_after_goal_daeun` — 민서 뒤 다은에게 30억 다음에도 함께 지킬 하루가 무엇인지
   실제로 묻고, 다은은 돈이 아니라 자기 시간의 범위를 답한다. 3.

### M52~M55 — 제안, 보증, 검토, 같은 방 (8)

8. `arc_y5_final_offer_reference_delivery` — `arc_y5_final_offer` 뒤 일곱 장 동일본이 다은과
   상철에게 실제로 전달됐음을 한 파일 해시·두 전송 시각으로 남긴다. 새 결정이 아닌
   1개의 진행 동작이다.
9. `arc_y5_jaehyuk_guarantee_request_reference` — 재혁의 보증 요청과 PDF가 실제로 도착한다.
   선택 전에 서명·거절·답장을 하지 않고 파일을 보관함에 옮기는 1개 진행 동작이다.
10. `arc_y5_jaehyuk_return_call_reference` — 재혁이 왜 지금 돌아왔는지를 실제 통화에서
    끝까지 듣고, 채무자·금액·친구 이름 중 어느 질문을 먼저 끝낼지 고른다. 3.
11. `arc_y5_jaehyuk_father_document_reference` — 재혁 PDF와 아버지 보증 문서의 이름 칸·책임
    범위를 한 화면에서 대조한다. 결정을 추가하지 않는 1개 진행 동작이다.
12. `arc_y5_guarantee_protected_show_daeun` — 확인된 보증 범위와 요청 원문을 다은에게 실제로
    보여 주고, 금액·이름·숨긴 시간을 어디까지 공개할지 고른다. 다은의 용서·동의는
    자동으로 쓰지 않는다. 3.
13. `arc_y5_jaehyuk_guarantee_decision_reference` — 거절, 실제 서명, 명시적 차단을 정확한
    행동으로 수행한다. 선택문과 결과가 다르게 움직이지 않고 재혁의 답장을 보장하지 않는다. 3.
14. `arc_y5_sangchul_review_receipt` — `arc_sangchul_final_door`에서 빨간 원으로 묶인 위험
    조항과 현재 촬영 시각을 한 장에 남기는 1개 진행 동작이다. 다른 선택의 ‘40분’을
    합치지 않는다.
15. `arc_y5_room_consent_receipt` — `arc_y5_three_in_room_decision`의 자필 범위·기한·범위 밖
    거절 원본을 별도 클립으로 보존한다. 새 동의를 다시 묻지 않는 1개 진행 동작이다.

### M56~M60 — 흔적, 접수, 판결, 실행, 다음 주 (5)

16. `arc_y5_father_trace_passed_called` — 별세한 아버지의 약봉지와 실제 마지막 통화 기록을
    M55의 이름 사용 방식 옆에 놓는다. 48주를 발명하지 않고 현재 기억에 무엇을 말할지
    고른다. 3.
17. `arc_y5_name_on_line_daeun_routed` — 다은이 실제 창구에 동석한다. 철회, 자필 범위 접수,
    명시적 거절을 무시한 옛 사본 사용, 자기 명의 축소를 각각 물리적 도장·접수본으로
    남긴다. 4.
18. `arc_y5_people_verdict_daeun_routed` — M57의 실제 접수본을 다은과 현수가 같은 자리에서
    서로 다르게 읽는다. 결혼·신혼집·강남 성패를 발명하지 않는다. 3.
19. `arc_y5_contract_execution_property` — 상철이 가져온 property 계약을 체결·취소·엑싯 중
    하나로 실제 움직여 돈·서류·전달본을 남긴다. M60은 이 receipt와 M57 filing만 읽는다. 3.
20. `arc_final_week` — 기존 `final_signature_*` 세 변형은 그대로 보존한다. base와 choices만
    무근거 수신 메시지를 제거하고, M60에서 실제 남은 대화방을 플레이어가 먼저 열어 같은
    상대에게 문장을 보내는 장면으로 정렬한다. 기존 3 choices와 모든 효과·플래그를 보존한다.

## 보호 원고

아래 KO/EN object는 선언 commit과 byte-equivalent로 보존한다.

- `arc_y5_final_offer`
- `arc_sangchul_final_door`
- `arc_y5_three_in_room`
- `arc_y5_three_in_room_decision`
- `arc_y5_name_on_line`
- `arc_y5_people_verdict`
- `arc_final_countdown`
- `arc_final_countdown_not_executed`
- `arc_final_week.description_if_known` 전체
- 사용자 지정 정점 8편: `arc_sangchul_confrontation`, `arc_y4_three_promises`,
  `arc_y4_body_witness`, `arc_y4_family_partner_collision`, `arc_y4_borrowed_name`,
  `arc_y4_bill_night`, `arc_sangchul_human`, `hyunsu_reunion_later`

기존 `arc_37_reckoning→arc_final_year_start`, `arc_minseo_03*`, `arc_jaehyuk_mirror*`,
`arc_father_legacy`, `arc_pre_ending_father_call`, `arc_daeun_final_choice`,
`arc_jiyeon_verdict`, `arc_pre_ending_summit`도 삭제·개작하지 않는다. 약한 legacy를
억지로 현재 beat에 맞추지 않고 새 기준 원고 뒤 routing debt로 남긴다.

## 원고 원칙

- 이 배치의 20개는 빈 root 20개가 아니라 하나의 마지막 해에서 실제로 연속되는
  사건 20개다. 각 원고는 바로 앞 물건이나 대사의 흔적을 최소 하나 가져온다.
- 월 commitment를 선택지에서 다시 고르지 않는다. 선택된 도착 뒤 공개 범위·질문·
  현재 손실·물리 실행만 고른다. 이미 정해진 delivery는 1개의 진행 동작으로 쓴다.
- 선택 전에는 미래 성공·별세 원인·용서·답장·계약 성립·엔딩 효과를 말하지 않는다.
- 마지막 문장은 계약 준수 여부를 보고하지 않고 사물·몸짓·침묵·공간에 남긴다.
- 다은은 `민준씨`와 존댓말, 상철은 짧은 실무어, 재혁은 친구 말투, 현수는 `형`,
  민서는 계산과 삶의 질문을 같은 문장에 놓는다.
- KO가 정본이고 EN은 인과·호칭·물건·손실을 보존한다. 지원 placeholder는 `{name}`만 쓴다.
- 신규 19개 root는 `weight:0`, `hidden:true`, `conditions.min_turn:9999`, 신규
  flags/effects/follow_up/writer 0이다. `arc_final_week`은 텍스트 외 구조를 보존한다.

## 정확한 파일 소유권

**선언·마감:** `CLAUDE.md`, `docs/CODEX_QUEUE.md`, 이 사양,
`docs/WORK_LOG.md`, 재생성 `docs/STATUS.md`.

**KO/EN 원고 10파일:**

- `content/events/arc_midgame.json`, `content/events_en/arc_midgame.json`
- `content/events/arc_new_characters.json`, `content/events_en/arc_new_characters.json`
- `content/events/arc_drama.json`, `content/events_en/arc_drama.json`
- `content/events/arc_year3_drama.json`, `content/events_en/arc_year3_drama.json`
- `content/events/arc_pre_ending.json`, `content/events_en/arc_pre_ending.json`

그 밖의 사건·story_map·story_rules·런타임·UI·밸런스·번역·아트·오디오는 수정하지 않는다.
새 19개는 reference-only author prose이며 후속 이관 오더 전에는 실제 도달을 주장하지 않는다.

## 완료 증거

- exact 20 roots만 변경: 신규 19 + 기존 `arc_final_week` text-only 1.
- 신규 KO description 300~800자, 지정 choice counts 합계 48 + 기존 final_week 3 =
  locale당 51 choices. KO/EN ID·순서·placeholder·사건 인과가 대응한다.
- 보호 원고 17개와 `arc_final_week.description_if_known`, 모든 비대상 object가 선언
  commit과 동일하다.
- strict duplicate-key JSON, EN coverage, i18n EN, story consistency, 말투,
  story-map normal/self-test, context/queue/status freshness, exact structured diff,
  `git diff --check`를 통과한다.
- 전체 감사·240주 시뮬레이션·Godot 장시간 검사는 실행하지 않는다.
- 독립 L2는 20개를 한 줄로 낭독해 인물·문서·장소·시간 점프, 월 행동 재선택,
  선택 지배, 먼 결과 스포일러, 계약 보고체를 P0/P1로 판정한다.
- Claude 위임 L3는 seed 9821 무작위 3편으로 완료했고 합격했다. 사용자 최종 GO는
  별도 사람 게이트에서 OPEN이다.

## 정본·일회성 판정

- `각 달을 빈칸 수가 아니라 실제 사건에서 시작한다`, `선택된 delivery는 다시
  고르지 않는다`, `5장 문서 상태를 배우 상태와 합치지 않는다`는 계속 유효한 규칙이며
  이미 `CLAUDE.md`와 `docs/CHOICE_CONSEQUENCE_SYSTEM.md`가 소유한다. 새 중복 승격 없음.
- 정확한 20 root 목록·파일·검사·기준 출연진은 이 배치에서만 유효한 일회성 지시다.

## 실행 결과 (2026-08-18)

- 신규 author-only 19개와 기존 `arc_final_week` 텍스트만 변경했다. locale당 20 roots·
  51 choices이며, 모든 비대상 object와 보호 원고 16개, `arc_final_week` 조건부 지문·
  효과·플래그·비텍스트 구조는 선언 commit `dcb7c27`과 동일하다.
- 계약 원문 → 상철 전달 → 다은 보호선 → 진료·민서·다은 → 재혁 보증 → 상철 검토 →
  네 사람 자필 범위 → 아버지 흔적 → 자기 명의 227 접수 → 다은·현수 판결 → 실제 이체 →
  마지막 주 선발신을 한 줄로 낭독했다. 독립 L2는 P0/P1 0으로 판정했다.
- 상호배타 선택의 receipt를 합치던 수면·파란 선·통화 질문, 보장되지 않은 다은의 가게
  폐점, 아버지 메타 보고체, `arc_final_week`의 배우별 말끝과 선행 대화방 전제를 모두
  실제 공통 물성 또는 배우 중립 행동으로 낮췄다.
- strict duplicate-key JSON, exact structured diff, EN/i18n 1702/1702, story consistency,
  speech register, story-map normal·76 self-test, context/queue와 `git diff --check`가 통과했다.
  전체 감사·240주·Godot는 사양대로 실행하지 않았다. 신규 19개는 후속 이관 전까지
  실제 도달을 주장하지 않는다.

## 2026-08-21 L3 판정

- 방법: 모집단 20편에서 seed 9821 무작위 3편. 세 판정축은 동일하다.
- **판정: Claude(사용자 위임) — 합격.** 근거는
  `arc_y5_jaehyuk_return_call_reference`의 “친구라는 말은 답이면서 부탁의
  재료이기도 했다”는 양면성이다.
- **사용자 최종 GO: 미서명(OPEN).**
