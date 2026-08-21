# Archived Queue Spec: ORDER-113

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [!] ORDER-113 [전량 반려] startup 16편을 사람·시간 중심으로 다시 설계한다

**사용자 지시 (2026-08-18):** “이제 이어서 작업해.” 빈칸 수가 아니라 실제 사건에서
출발한다. 기존 즉시 `startup_exit`는 보존하고, M49~M60의 검토·경계·조건부 접수·
실행·인수 뒤 첫 주가 차례로 물성을 바꾸는 reference 세로줄을 만든다.

## 깊이 3문

1. 현재 창업 정본은 300만원 공동창업으로 지분 20%를 얻고, 기업가치 160억원에서
   그 20%를 32억원에 파는 단일 엑싯이다. 그러나 기존 `startup_acquisition_offer`는
   한 선택 안에서 서명·입금·`startup_exit`까지 끝내 M60과 마지막 주를 건너뛴다.
2. 이번 경로의 질문은 “32억원을 받을까” 하나가 아니다. 대금 32억원은 세 안 모두
   고정하고, 빠른 종결을 위해 민준의 12개월·기존 서비스의 12개월·기명 팀의
   12개월 중 누구의 시간을 계약에 남길지를 고른다. 공동창업자의 이름은 공동보증에
   쓰지 않고, 각 매도인이 자기 서명면과 자기 책임을 가진다.
3. 신규 16개는 author-only exact reference다. 이번에는 story map·StoryLedger·
   돈·지분·flags·`finish_run`·endings를 바꾸거나 도달 가능하다고 주장하지 않는다.
   한영 원고와 C0→C3 사건을 먼저 끝낸 뒤, legacy 격리·원자적 1회 거래·성공 엔딩
   유예·staged ending은 다음 routing/ending 배치가 소유한다.

## startup 사건 16개

| # | 월 | 신규 root | 선택 | 실제 사건 |
|---:|---:|---|---:|---|
| 1 | 49 | `arc_y5_startup_offer_c0` | 3 | 7일 만료 비구속 C0에서 160억원·20%=32억원·공동보증 빈칸 중 먼저 볼 것을 고른다. |
| 2 | 49 | `arc_y5_startup_c0_reviewer_delivery_minseo` | 1 | 같은 h0 C0 전체를 민서에게 직접 건네고 공개 시각을 남긴다. |
| 3 | 50 | `arc_y5_startup_boundary_cofounder` | 4 | 공동보증 대신 별도 매도인 서명면을 요청해 속도·책임·목소리 손실을 가른다. |
| 4 | 51 | `arc_y5_startup_minseo_goal_cost` | 3 | 민서가 제안 32억원과 이동 0원을 대조하고 전환·팀·서비스 종료일을 읽는다. |
| 5 | 51 | `arc_y5_startup_after_goal_cofounder` | 3 | 이름을 보증에 넣으려 한 사실을 밝히고 32억원 뒤 무엇에 남을지 묻는다. |
| 6 | 52 | `arc_y5_startup_final_offer_acquirer` | 4 | 인수 책임자의 C1 세 안을 고르지 않고 전체·팀·서비스 annex·종료부터 읽는다. |
| 7 | 54 | `arc_y5_startup_reviewer_receipt_minseo` | 1 | 민서가 C1의 예외 문구와 세 package 종료일을 표시해 돌려준다. |
| 8 | 55 | `arc_y5_startup_three_in_room` | 3 | 네 사람이 같은 h1 세 부를 펼치고 첫 증거를 테이블에 놓는다. |
| 9 | 55 | `arc_y5_startup_three_in_room_decision` | 3 | 시간·제품·사람 손실 하나를 h2 공개 수정 지시로 남긴다. 실행은 아직 없다. |
| 10 | 57 | `arc_y5_startup_c2_sign_self` | 4 | 민준 조건부 접수·annex 불일치 보류·48시간 연기·철회를 실제 상태로 가른다. |
| 11 | 57 | `arc_y5_startup_c2_copy_delivered_cofounder` | 1 | h2 접수사본 한 부를 공동창업자에게 별도 시각에 건넨다. |
| 12 | 58 | `arc_y5_startup_people_verdict_cofounder` | 3 | 공동창업자의 판정을 듣고 팀 공지 책임자를 현재 비용으로 가른다. |
| 13 | 59 | `arc_y5_startup_contract_execution_c3` | 3 | 일치 실행·불일치 중지·인수 종료를 갈라 reference에서만 32억원·20%를 한 번 움직인다. |
| 14 | 59 | `arc_y5_startup_c3_copy_delivered_cofounder` | 1 | h3 실행 확인 사본을 공동창업자에게 별도 전달한다. |
| 15 | 60 | `arc_final_countdown_startup_executed` | 3 | 반납 물성·전환 출입증·h3 앞에서 첫 주 책임 하나를 자기 이름으로 서명한다. |
| 16 | 60 | `arc_y5_final_week_startup_after_acquisition` | 3 | 첫 인수인계의 직무 충돌을 수정·이견 기록·결정권 반환으로 실제 처리한다. |

정확히 신규 16 roots·43 choices/locale다. M53의 재혁 보증은 startup에서
`not_applicable`인 0-scene gate다. M56의 가족 사건은 별도 세로줄이며 startup 문서가
대신 완료하지 않는다. M60의 반납 물성과 전환 출입증은 M59 실행 receipt의 자동
결과이지 새 월간 commitment가 아니다.

## 고정 정본·배우·문서 계보

- origin/gate는 `startup_opportunity`의 300만원·20%·`startup_founded`와
  `!startup_exit && !startup_partial_exit && !startup_going_solo`다.
  `joined_startup`·`startup_launched`는 합치지 않는다.
- tuple은 player / `acquirer_lead`(proposer=counterparty) / `minseo`(reviewer) /
  founding receipt의 무명 `startup_cofounder`(protected=affected=primary witness)다.
  배우를 합치거나 공동창업자에게 실명·연애 역할을 발명하지 않는다.
  `story.partner_name_use=n_a`; route-scoped typed actor 등록 전 reference-only다.
- deal ID 하나와 `h0 → h1 → h2 → h3`를 쓴다. 같은 버전 사본만 same hash다.
  내부 코드 대신 문서 제목·버전일·hash 끝자리만 플레이어에게 보인다.

### C0 — M49 비구속 의향서

- 160억원·민준 20%=32억원·7일 만료·공동보증 빈칸·팀/서비스 annex가 있는
  비구속 검토본이다. 서명·입금·이전·`startup_exit`는 0이다.

### C1 — M52 대금은 같고 손실 주체만 다른 세 안

1. **시간/reference:** 민준 전환 12개월, 기명 팀·기존 서비스 각 12개월.
2. **제품:** 민준 90일, 팀 12개월, 서비스 90일.
3. **사람:** 민준 90일, 서비스 12개월, 팀 고용 90일.

세 안 모두 160억원·20%=32억원이다. 계약 기간은 미래 결과가 아니며 M52는 읽을 뿐
고르거나 서명하지 않는다.

### C2 — M55 공개 수정 지시, M57 조건부 seller 접수

- 시간안을 reference로 삼아 `COFOUNDER WARRANTY NOT USED`, 매도인별 서명면,
  민준/팀/서비스 종료일과 20%=32억원을 h2에 둔다. M55는 공개 수정 지시만,
  M57은 민준 seller page 조건부 서명·사전심사 ID/시각/두 사본만 만든다.
  최종확인·closing·입금·이전·exit는 0이며 사본 전달은 별도 root다.

### C3 — M59에서만 한 번 실행

- h2 일치 실행에서만 32억원을 한 번 입금하고 민준 20%·대표 인감·관리권한을
  이전한다. 은행 영수증·주주명부·시각·계정 종료·전환 출입증을 남기며 그때부터
  세 12개월 기간이 시작된다. 실제 잔류·성공·면책은 보장하지 않는다.
- 다른 choices는 불일치 중지(0원/0이전)와 종료(0원/0이전·20% 유지)다. M60은
  C3를 읽어 첫 주 책임표에만 서명하며 거래를 재실행하지 않는다.

## exact 선택·월간 여유 계약

- M49는 `open_path_contract(startup)+choose_reviewer(minseo)`를 완료하고 h0와 전달
  시각을 남긴다.
- M50은 `draw_name_boundary`만 완료한다. 공동창업자 전달·동의를 발명하지 않는다.
- M51은 `hear_minseo→ask_after_goal(startup_cofounder)`를 서로 다른 root로 완료한다.
- M52는 `hear_live_proposer(acquirer_lead)`만, C1 수령은 M54가 소유한다.
- M53 Jaehyuk guarantee는 unavailable이다. refused/blocked/PDF를 합치지 않는다.
- M54는 `hear_chosen_reviewer(minseo)`만. 민서는 법률 판정 대신 문구·숫자·날짜를 표시한다.
- M55는 `disclose_all_terms+let_reviewer_question`을 완료한다. h1 세 부와 h2 수정
  지시만 남기며 서명·접수·돈 이동을 선취하지 않는다.
- M57은 `file_name_decision+deliver_filed_copy(startup_cofounder)`를 서로 다른
  root·timestamp로 완료한다.
  reference outcome은 `self_only_conditional_filed + cofounder_not_used + copy_delivered`다.
- M58은 `hear_primary_witness(startup_cofounder)` 한 사람만 등장한다.
- M59는 `execute_contract_result(startup)+deliver_result(startup_cofounder)`를 각각
  완료한다.
  reference는 `startup_acquisition_executed + 3.2B_once + 20pct_transferred +
  execution_copy_delivered`다.
- M60은 `sign_own_answer`만 완료한다. 반납 물성·전환 출입증은 M59 receipt이며 다른
  M60 commitments를 완료했다고 쓰지 않는다.
- exact downstream은 M55 시간 손실 choice 1, M57 self-only 조건부 접수 choice 1,
  M58 민준이 팀 공지 책임을 지고 공동창업자 말을 끝까지 듣는 reference choice,
  M59 일치 실행 choice 1만 읽는다. 다른 선택은 각자의 author-only endpoint다.
- M50·M52는 각각 choices 1~3만 다음 reference 단계로 가며, 공동보증과 인수 논의를
  닫는 choice 4는 각자의 author-only terminal endpoint다.

## 장면·선택 원칙

- M55는 “팔까”를 다시 묻거나 closing을 끝내지 않는다. 네 사람 앞에서 누구의
  12개월을 계약에 남길지 공개 수정 지시로 좁힌다. M57은 그 지시를 민준 자기
  서명면으로 실제 접수할지 배반할지 실행한다. M59만 거래를 종결한다.
- 민서는 도덕 해설자나 변호사가 아니라 숫자·예외 문구·종료일을 찾는 검토자다.
  인수 책임자는 대금·기한·범위를 책임지는 counterparty다.
  공동창업자는 보상 소품이 아니라 자기 이름·팀·제품의 비용을 말하고 판정하는 사람이다.
- 종이 전달을 반복하지 않는다. M50은 이름 경계, M51은 돈 뒤 삶, M57은 조건부 접수,
  M58은 팀 공지 책임, M60은 첫 직무 충돌을 소유한다.
- final-week는 문자·음성·공문 채널 선택이나 추상 회고가 아니다. 새 로고 아래 실제
  직무 변경표·서비스 인계표의 오류 하나를 놓고 공동창업자의 결정권과 민준의 전환
  의무가 충돌하는 사건이어야 한다.
- 결과는 지금 생긴 원본·사본·도장·계좌 한 줄·접근권·업무시간과 현재 잃은 사람·
  제품·시간만 회수한다. 답장·용서·팀 잔류·서비스 성공·세금 후 30억원·일반 강남
  엔딩을 보장하지 않는다. 계약 준수 여부를 화자가 보고하지 않고 물성으로 보인다.
- KO가 정본이며 EN은 배우·문서 버전·hash 수량·160억원/20%/32억원·시각·손실·
  말투를 보존한다. placeholder는 `{name}`만 사용한다.

## 보호 범위와 다음 routing/ending 배치

- `life_events.json`/EN의 `startup_opportunity`, `startup_acquisition_offer`,
  `drama_events.json`/EN의 `drama_startup_acquisition`, `startup_team_conflict`,
  partial/solo callbacks를 object byte-exact로 보존한다. 기존 즉시 수락은 old-save와
  조기 terminal 경로로 남고 이번 M59에 재사용하지 않는다.
- ORDER-104~112의 기존 사건 object와 조건부 지문, story map, story rules, runtime,
  모든 `arc_final_countdown*`, `arc_final_week*` 원고를 선언 commit과 동일하게 보존한다.
- `content/endings.json`, `content/endings_en.json` 35개와 JA·zh-CN·zh-TW endings
  skeleton을 byte-exact로 보존한다. `finish_run`과 엔딩 우선순위를 바꾸지 않는다.
- 다음 routing/ending 배치는 legacy 즉시 root 억제, idempotent 20%·32억원 1회 처리,
  failure를 제외한 성공 종결의 final-week 뒤 유예, staged-specific `startup_exit`
  지문을 소유한다. 기존 ID·CG·보상은 유지한다.
- 이번 신규 원고는 map lifecycle 표시도 하지 않는 reference-only다. 위 네 항목이
  끝나기 전 도달성·제품 완결·엔딩 GO를 주장하지 않는다.

## 정확한 파일 소유권

**선언·마감:** `CLAUDE.md`, `docs/CODEX_QUEUE.md`, 이 사양,
`docs/WORK_LOG.md`, 재생성 `docs/STATUS.md`.

**Writer A — 초기 5 roots:**

- `content/events/arc_midgame.json`, `content/events_en/arc_midgame.json`
- `content/events/arc_new_characters.json`, `content/events_en/arc_new_characters.json`

**Writer B — 후반 11 roots:**

- `content/events/arc_pre_ending.json`, `content/events_en/arc_pre_ending.json`
- `content/events/arc_drama.json`, `content/events_en/arc_drama.json`

그 밖의 사건·메타·규칙·런타임·UI·밸런스·번역·엔딩·아트·오디오는 수정하지 않는다.

## 완료 증거

- exact 신규 16 roots·43 choices/locale, 선언 commit 대비 기존 object changed/removed 0.
- 신규 KO·EN description 300~800자, KO author-only metadata
  (`weight:0`, `hidden:true`, `conditions.min_turn:9999`), 신규
  flags/effects/follow_up/writer 0. EN은 text-only overlay다.
- strict duplicate-key JSON, duplicate ID 0, KO/EN field별 choice·placeholder parity,
  EN/i18n coverage, story consistency, speech register, context/queue/status freshness,
  exact structured diff, `git diff --check`를 통과한다.
- 기존 ORDER-104~112 사건, startup legacy objects, story map·story rules·runtime,
  35 endings·5 locale ending 파일이 선언 commit과 동일하다. 전체 감사·240주·Godot
  장시간 검사는 실행하지 않는다.
- 독립 L2는 h0→h1→h2→h3 계보, 같은 hash 사본 수, 160억원·20%·32억원 1회,
  acquirer/minseo/cofounder 배우, 월간 여유, C2 접수와 C3 실행 분리, 세 손실의
  비지배성, final-week 실제 사건, 먼 결과·계약 보고체를 처음부터 끝까지 판정한다.
- Claude 위임 L3는 seed 9821 무작위 3편으로 완료했고 전량 반려됐다. 사용자 최종
  GO와 JA·zh-CN·zh-TW 원문 잠금은 새 16편·새 계약 뒤까지 OPEN이다.

## 정본·일회성 판정

- 300만원 공동창업→20%→기업가치 160억원→32억원 단일 엑싯과 startup 전용 ending
  우선순위는 `docs/DECISIONS.md`가 이미 소유한다. 새 중복 승격 없음.
- `한 선택 receipt를 다른 선택에 합치지 않는다`, `배우 tuple을 관계 enum으로
  추측하지 않는다`, `마지막 서명 뒤 ending을 판정한다`는 기존 정본이 이미 소유한다.
- 정확한 16 root ID·문서 버전·세 package 기간·배우 tuple·파일·선택 trace는 이
  배치에만 유효한 일회성 작업 지시다.

## 실행 결과 (2026-08-18)

- KO·EN 신규 16 roots·43 choices를 집필했다. h0 `A6E8`→h1 `91B4`→h2 `D772`→
  h3 `5C20`과 160억원·20%·32억원을 보존하고, M59 reference에서만 돈·지분이 한 번
  움직이는 장면으로 닫았다.
- M50의 새 7일 수정창과 M51 다음 달을 분리하고, M52 지배 선택을 전환근무표 질문으로
  좁혔다. 공동창업자는 h2 별도 seller page에 직접 서명·반송하며, 그 receipt가 도착한
  뒤에만 h3가 실행된다. C2 접수와 C3 실행, 두 사본 전달 시각도 분리했다.
- 선언 `a212882` 대비 지정 8파일 기존 object changed/removed 0이다. startup legacy,
  story map·rules·runtime, 35 endings·5 locale 파일은 byte-exact이며 신규 KO는
  author-only·state mutation 0, EN은 text-only다.
- exact 16/43, strict JSON, description 300~800, choice·placeholder, EN strict
  1758/1758·35/35, 서사·말투·random pool, story-map normal·76 self-test, context·queue·
  diff-check가 통과했다. 독립 두 낭독은 P0/P1 0 GO다. 전체·240주·Godot는 생략했고,
  L3 전 JA·zh-CN·zh-TW 번역과 live reachability를 주장하지 않는다.

## 2026-08-21 L3 판정

- 방법: 모집단 16편에서 seed 9821 무작위 3편. 세 판정축은 동일하다.
- **판정: Claude(사용자 위임) — 전량 반려.** 표본 세 편 모두 목소리·현재
  손실·여운이 미달했다. `arc_final_countdown_startup_executed`가 5년의 마지막을
  팀 설명 날짜·당직표·계정 인계표 기입으로 끝내는 것이 결정적 근거다.
- 16 roots의 9칸 절차 골격과 43 choices는 보호 대상이 아니다. 공동창업자·팀·고객의
  사람과 시간을 중심으로 끝나는 방식을 다시 설계한다. 플레이어 산문의 `NOT USED`,
  `SELF ONLY`, 문서 코드·해시도 상태 데이터로 내린다. 복구는 ORDER-118이 소유한다.
- **사용자 최종 GO: 미서명(OPEN).** R1b는 새 원고와 새 계약 전까지 HOLD다.
