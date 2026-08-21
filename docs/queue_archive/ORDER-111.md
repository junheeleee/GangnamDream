# Archived Queue Spec: ORDER-111

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [x] ORDER-111 [P0·서사 원고] 마지막 해의 지연·생존 경로와 무연애·미실행 경로를 두 편의 실제 삶으로 완주한다

**사용자 지시 (2026-08-18):** “이제 이어서 작업해.” 앞 배치가 상철·다은·재혁·
아버지 별세의 기준 경로를 완주했으므로, 이번 배치는 이름만 바꾼 fallback을 늘리지
않고 그 기준과 실제로 다른 두 삶을 M50부터 마지막 주까지 이어 쓴다.

## 깊이 3문

1. 지연 경로는 현재 M58에서 결혼집·장인·강남 실패를 발명하고, 무연애 경로는
   M55의 보증 당사자 부재와 M59의 미실행을 실제 장면으로 갖지 못한다. M60 서명은
   접수 상태와 실행 상태를 함께 읽어야 하지만 현재 fallback 원고가 없다.
2. 이번에는 `지연 + 아버지 생존 + 제한 동의 명의 + property 실행`과
   `무연애 + 재혁 차단 + 다은 이름 거절 + 자기 명의 접수 + 미실행`을 각각 하나의
   세로줄로 쓴다. 모든 장면은 바로 앞 장면의 종이·통화·도장·사람을 하나 이상 받는다.
3. 엔딩 35개는 이번 배치에서 건드리지 않는다. M58 판결·M59 실행·M60 서명 receipt가
   먼저 완성된 뒤 별도 라우팅 배치에서 `finish_run` 순서와 함께 판정한다. 기존 강한
   ORDER-104·110 원고와 final-week 조건부 지문도 그대로 보존한다.

## 두 실제 경로

### A — 지연·아버지 생존·제한 동의 명의·property 실행 (14)

1. `arc_y5_protection_context_jiyeon_reference` — M50. 지연 이름이 들어갈 수 있는
   초기 공동책임 칸을 실제로 보여 주고, 지연이 독립 검토자로 민서를 지목한다. 이름
   사용·서명은 아직 없다. 3 choices.
2. `arc_y5_final_offer_jiyeon_reference` — M52. 상철 제안자·거래 상대, 민서 검토자,
   지연 보호 대상의 배우 receipt를 일곱 장 동일본과 전송 시각으로 고정한다. 3.
3. `arc_y5_three_in_room_other_actor` — M55 opening. 민준·상철·민서·지연·재혁이
   실제 한 방에 앉는다. 상철은 제안자, 민서는 독립 검토자, 재혁은 보증 당사자다. 3.
4. `arc_y5_three_in_room_decision_other_actor` — M55 decision. 지연은 책임 상한,
   독립 검토 완료, 사본 폐기 범위 중 하나를 자기 말과 글씨로 좁힌다. 세 갈래 모두
   제한 동의의 공통 receipt는 남기되 현재 잃는 금액·시간·백업 문서가 다르다. 3.
5. `arc_y5_room_consent_receipt_jiyeon` — M55. 지연의 제한 동의와 범위 밖 거절,
   민서의 검토 표시를 한 클립에 보존하는 진행 동작. 새 동의를 다시 묻지 않는다. 1.
6. `arc_y5_father_trace_alive_called` — M56. 민준이 살아 있는 아버지에게 먼저 전화해
   지연의 제한 동의와 옛 보증을 대조한다. 화해·건강 회복·다음 통화를 보장하지 않는다. 3.
7. `arc_y5_name_on_line_jiyeon` — M57. 지연이 실제 창구에 동석한다. 철회, 제한 범위
   접수, 범위 밖 사용, 자기 명의 축소가 서로 다른 도장과 접수 상태를 남긴다. 4.
8. `arc_y5_name_copy_delivered_jiyeon` — M57. 제한 범위로 접수한 reference 선택 뒤
   지연에게 실제 접수 사본 한 부를 건네고 시각만 남긴다. 수용·용서 0. 1.
9. `arc_y5_people_verdict_jiyeon_routed` — M58. 지연과 현수가 같은 접수본을 계급의
   접근권과 사람의 이름이라는 서로 다른 관점으로 읽는다. 결혼집·장인·성패 발명 0. 3.
10. `arc_y5_contract_execution_property_jiyeon_filing` — M59. 제한 동의 접수본을 읽고
    property 계약의 체결·취소·양도를 실제 돈·도장·전달본으로 움직인다. 3.
11. `arc_y5_contract_result_delivered_jiyeon` — M59. reference 실행 선택의 원본 한 부를
    지연에게 직접 건네고 수령 시각만 남기는 진행 동작. 1.
12. `arc_y5_key_and_remaining_person_jiyeon` — M60. 열쇠 봉투와 실행본을 지연 앞에
    함께 놓고, 그녀가 남는 대가를 한 문장으로 말하게 한다. 관계 결말은 선확정하지 않는다. 1.
13. `arc_final_countdown_other_filing_executed` — M60. 타인 명의 제한 접수와 실제 실행이
    함께 남은 마지막 서명. 기존 세 의미축(책임 소유/담보화/사람 우선)을 지킨다. 3.
14. `arc_y5_final_week_jiyeon_outbound` — M60 aftermath. 지연과 실제 말을 주고받은
    대화방에 민준이 먼저 식사·사과·거리와 다음 시각 중 하나를 보낸다. 답장 0. 3.

### B — 무연애·재혁 차단·자기 명의 접수·미실행 (11)

15. `arc_y5_three_in_room_blocked_review` — M55 opening. ID의 `blocked`는 검토자 부재가
    아니라 재혁 차단이다. 상철은 제안자이자 검토자, 다은은 보호 대상으로 실제
    동석하고 재혁의 의자만 없다. 3.
16. `arc_y5_three_in_room_decision_blocked_review` — M55 decision. 다은 이름을 빼고
    자기 명의로 좁히는 비용, 상철의 이해충돌, 빈 보증 칸을 한 결정으로 닫는다. 3.
17. `arc_y5_room_consent_receipt_blocked_review` — M55. 다은의 명시적 거절과 이름 삭제,
    상철의 미확인 조항을 세 부 사본에 보존한다. 재혁 PDF를 발명하지 않는다. 1.
18. `arc_y5_father_trace_passed_missed` — M56. 별세한 아버지와 연결되지 못한 마지막
    연락을 날짜·통화 길이·약봉지로만 회수한다. 48주·사망 원인·응답 발명 0. 3.
19. `arc_y5_name_on_line_self` — M57. 민준과 창구 담당자만 실제로 있다. 다은 거절
    원본을 읽고 철회·자기 명의 접수·거절 무시·미접수 보류를 물리 상태로 남긴다. 4.
20. `arc_y5_name_copy_not_delivered_self` — M57. 자기 명의 접수 reference 선택 뒤
    다은에게 갈 사본을 보내지 않고 봉투·미전달 시각을 남긴다. 1.
21. `arc_y5_people_verdict` — M58. 기존 자기 명의·무연애 227번 접수본과 현수·민서
    판결을 byte-exact로 재사용한다. 새 원고가 아니다. 기존 3 choices.
22. `arc_y5_contract_not_executed_notice` — M59. 실행 commitment 미선택 뒤 상철에게
    무이체·미실행을 먼저 통보하고 열린 원본과 발신 시각을 남긴다. 뒤늦은 실행 0. 1.
23. `arc_y5_returned_documents_hyunsu` — M60. 열쇠 대신 접수본·미실행 발신 기록·아직
    돌려줘야 할 원본을 반환 준비 봉투와 함께 현수 앞에 놓고, 현수가 사람을 담보로
    잡지 않은 시간으로 읽는다. 반환 완료나 상대 응답은 발명하지 않는다. 1.
24. `arc_final_countdown_filed_not_executed` — M60. 접수는 했지만 돈과 계약은 움직이지
    않은 상태의 마지막 서명. 실행 성공이나 완전한 무접수를 발명하지 않는다. 3.
25. `arc_y5_final_week_hyunsu_outbound` — M60 aftermath. 현수와 실제 말을 주고받은
    대화방에 민준이 먼저 국밥·늦은 사과·거리와 다음 시각 중 하나를 보낸다. 3.

## exact reference 계약

- A 배우 tuple: `proposer=sangchul`, `counterparty=sangchul`, `reviewer=minseo`,
  `protected_person=jiyeon`, `guarantee_party=jaehyuk`. `partner=jiyeon`,
  `father.life=alive`, M55 opening은 빈 종이와 미확인 세 칸을 함께 남긴 C3,
  decision은 책임 상한과 그 끝나는 날짜를 함께 남긴 C1,
  M57 reference outcome=`consensual_filed`, M58은 실행 창구로 돌아가는 C3,
  M59 reference outcome=`executed + delivered`일 때만 세로줄을 그대로 읽는다. M55 C2는
  독립 검토가 끝나기 전의 조건부 동의이고 C3은 사본 범위만 남기므로 이번 M57로
  내려가지 않으며, 각각 후속 receipt 전까지 author-only 끝점이다.
- B 배우 tuple: `proposer=reviewer=counterparty=sangchul`, `protected_person=daeun`,
  `guarantee=blocked`. `partner=none`, `father.life=passed`, final contact=`missed`,
  M55 opening은 제안·미확인 표시를 두 색으로 남긴 C1, decision은 낮아진 자기 명의
  한도와 보증 칸 `사용하지 않음`을 남긴 C1, M56은 약봉지와 0초를 별도 사진으로
  남긴 C3,
  M57 reference outcome=`self_filed`, M58은 현수·민서의 말을 끝까지 듣는 C1,
  M59 outcome=`not_executed`일 때만 읽는다. M55 C2/C3은 별도 사본 상태를 남기므로 이번
  공통 receipt와 M57로 내려가지 않고, M58 C2/C3도 이번 미실행 downstream으로 내려가지
  않는다. M56 C1은 자기 명의 초안 뒷면에 통화 기록을 쓰므로 공식 접수본으로 내려가지
  않고, C2도 별도 음성 메모 끝점으로 남는다.
- 두 경로의 다른 선택 결과는 이번 downstream 원고가 덮지 않는다. 신규 원고는
  author-only reference이고 StoryLedger·dispatch·finish_run 승격을 주장하지 않는다.

## 보호 원고와 엔딩 보류

- ORDER-110의 20 roots 전부, `arc_y5_three_in_room{,_decision}`,
  `arc_y5_name_on_line`, `arc_y5_people_verdict`, `arc_final_countdown`,
  `arc_final_countdown_not_executed`, `arc_final_week` 전체를 선언 commit과 동일하게
  보존한다.
- 약한 legacy `arc_father_legacy`, `arc_pre_ending_father_call`,
  `arc_daeun_final_choice`, `arc_jiyeon_verdict`, `arc_pre_ending_summit`도 삭제·개작하지
  않고 후속 routing에서만 분리한다.
- `content/endings.json`, `content/endings_en.json`의 35개와 JA·zh-CN·zh-TW endings
  skeleton은 전부 byte-exact다. M57/M59/M60 receipt가 live가 되기 전에는 엔딩 문구나
  `finish_run` 우선순위를 고치지 않는다.

## 원고 원칙

- 한 root는 300~800자 한국어 장면 하나다. 진행 동작 1개짜리 root도 물건·몸짓·
  여운을 갖되 새 결정을 가장하지 않는다.
- 월 commitment를 다시 고르지 않는다. 선택된 도착 뒤 공개 범위·현재 손실·실제
  접수·실행만 고른다.
- 지연은 연애 확정 뒤 `오빠`와 반말, 민준은 존댓말 기조다. 다은은 끝까지
  `민준씨`와 존댓말, 현수는 `형`, 민서는 계산과 삶의 질문을 함께 말한다.
- 선택 전에 답장·화해·용서·계약 성공·아버지 회복/별세 원인·엔딩 성패를 말하지 않는다.
- 계약 준수 여부를 화자가 보고하지 않는다. 답이 없으면 빈 말풍선·발신 시각·
  엎어진 휴대폰처럼 장면 안의 물성으로 쓴다.
- KO가 정본이고 EN은 배우·물건·시각·인과·손실·호칭을 보존한다. placeholder는
  `{name}`만 사용한다.

## lifecycle-only story map 정렬

실제 KO/EN 원고가 생기는 아래 9개 fallback의 `work/rule_status`만
`NEW/planned → EXPAND/needs_rule`로 바꾼다. selector·cast·reads·writes·decision은
이번 배치에서 수정하지 않는다.

- M55: `arc_y5_three_in_room_blocked_review`, `_decision_blocked_review`,
  `arc_y5_three_in_room_other_actor`, `_decision_other_actor`
- M57: `arc_y5_name_on_line_jiyeon`, `arc_y5_name_on_line_self`
- M59: `arc_y5_contract_not_executed_notice`
- M60: `arc_final_countdown_other_filing_executed`,
  `arc_final_countdown_filed_not_executed`

원고가 있다는 이유로 dynamic actor tuple이나 composite receipt가 실행 가능하다고
주장하지 않는다. 후속 routing 오더가 exact selector와
`memory.m57_name_decision × memory.m59_contract_result`를 소유한다.

## 정확한 파일 소유권

**선언·마감:** `CLAUDE.md`, `docs/CODEX_QUEUE.md`, 이 사양,
`docs/WORK_LOG.md`, 재생성 `docs/STATUS.md`.

**원고 KO/EN 8파일:**

- `content/events/arc_midgame.json`, `content/events_en/arc_midgame.json`
- `content/events/arc_year3_drama.json`, `content/events_en/arc_year3_drama.json`
- `content/events/arc_drama.json`, `content/events_en/arc_drama.json`
- `content/events/arc_pre_ending.json`, `content/events_en/arc_pre_ending.json`

**정합 1파일:** `content/meta/story_map.json`의 위 9 lifecycle pair만.

그 밖의 사건·story_rules·런타임·UI·밸런스·번역·엔딩·아트·오디오는 수정하지 않는다.

## 완료 증거

- exact 24 신규 roots·58 신규 choices/locale. 보호 `arc_y5_people_verdict` 3 choices를
  포함한 두 세로줄은 25 incident roots·61 choices다.
- 신규 KO description 300~800자, KO author-only metadata
  (`weight:0`, `hidden:true`, `conditions.min_turn:9999`), 신규
  flags/effects/follow_up/writer 0. EN은 text-only overlay다.
- 선언 commit 대비 모든 비대상 object, 보호 원고, 35 endings가 동일하다.
- story-map diff는 지정 9 fallback의 `work/rule_status` pair만이다.
- strict duplicate-key JSON, EN/i18n coverage, story consistency, speech register,
  story-map normal/self-test, context/queue/status freshness, exact structured diff,
  `git diff --check`를 통과한다.
- 전체 감사·240주·Godot 장시간 검사는 실행하지 않는다.
- 독립 L2는 A와 B를 각각 처음부터 끝까지 읽고 배우·문서·장소·시간 점프, 선택
  receipt 합치기, 월 행동 재선택, 선택 지배, 먼 결과 스포일러, 계약 보고체를 판정한다.
- Claude 위임 L3는 신규 24편 모집단의 seed 9821 무작위 3편으로 완료했고 합격했다.
  사용자 최종 GO는 별도 사람 게이트에서 OPEN이다.

## 정본·일회성 판정

- `한 경로의 선택 receipt를 다른 선택에 합치지 않는다`, `배우 tuple을 이름표로
  추측하지 않는다`, `엔딩은 마지막 서명 receipt 뒤에 판정한다`는 계속 유효하며
  `docs/CHOICE_CONSEQUENCE_SYSTEM.md`와 `docs/STORY_CONSISTENCY_SYSTEM.md`가 이미
  소유한다. 새 중복 승격 없음.
- 정확한 25 incident 목록·파일·배우 tuple·검사는 이 배치에만 유효한 일회성 지시다.

## 실행 결과 (2026-08-18)

- 신규 author-only 24 roots·58 choices/locale를 추가했다. 보호된 기존
  `arc_y5_people_verdict` 3 choices까지 포함하면 두 세로줄은 25 incidents·61 choices다.
  선언 commit `a0da872`의 기존 사건 294 objects와 35 endings·5개 locale ending 파일은
  그대로이며, story map은 지정 9 fallback의 lifecycle 18 leaf만 바뀌었다.
- A는 M55 opening C3→decision C1→M57 제한 접수 C2→M58 실행 창구 C3→M59 실제
  이체 C1·원본 전달→M60 실행 확인 사본·선발신으로, B는 M55 opening C1→decision C1→
  M56 별도 합성 사진 C3→M57 자기 명의 접수 C2→M58 현수·민서 낭독 C1→M59
  미실행 통지→M60 반환 준비·선발신으로 exact하게 읽는다. 다른 선택은 이 downstream에
  합치지 않고 각 author-only 끝점으로 남겼다.
- 독립 두 낭독에서 원본/사본, `NOT USED`, 다은 거절, 미수신 메시지, 민서 성씨,
  동적 플레이어명, 계약 보고체와 한영 의미를 보정한 뒤 P0/P1 0 GO를 받았다.
- strict duplicate-key JSON, exact structured diff, EN/i18n 1726/1726, story consistency,
  speech register, story-map normal·76 self-test, context/queue와 `git diff --check`가
  통과했다. 전체 감사·240주·Godot는 사양대로 실행하지 않았다. 신규 24개와 lifecycle
  표시는 후속 exact routing 전까지 실제 도달을 주장하지 않는다.

## 2026-08-21 L3 판정

- 방법: 이 오더가 새로 쓴 24편 모집단에서 seed 9821 무작위 3편. 보호된 기존
  `arc_y5_people_verdict`는 모집단에 합치지 않았다. 세 판정축은 동일하다.
- **판정: Claude(사용자 위임) — 합격.** Claude 판정 요약은
  `arc_y5_final_week_jiyeon_outbound`가 앞 장면의 지연 요구를 이월해 세 선택이
  각각 다른 것을 포기하게 한다는 점이다.
- **사용자 최종 GO: 미서명(OPEN).**
