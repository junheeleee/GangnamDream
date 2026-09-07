# Active Queue Spec: ORDER-164

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-164 [P0·전체 현지화] 4년차의 비용과 아버지 경과를 세 언어로 옮긴다

**[~] 2026-09-07 Codex 착수 선언 — 만지는 파일: 아래 정확47 ID의
JA·zh-CN·zh-TW text-only overlay, 원문 결속 검사·수용 원장·증거 문서.**
사용자 전체판 번역 지시를 구현 `7dffdad`에서 이어간다.
기존5,412 수용 문구·비표시 메타9·KO 제품53493fe·공개 데모를 보존한다.

## 깊이 3문

1. **없으면 무엇이 깨지는가?** 3년차 진실을 알아낸 뒤 약속·몸·가족·빌린 이름의
   비용과 아버지 연락/의료 경과가 다시 영어로 돌아간다. 모든 관계 변형과
   안정/미확정 경과까지 같이 옮겨 선택과 생사 결과를 혼동하지 않는다.
2. **선택을 바꾸는가?** 조건·선택·효과·비용·주차·생사·답장·방문·서명·소유는
   변경0이다. 방문을 택했다고 생존을 확정하거나 미응답을 사망으로 채우지 않는다.
3. **무엇과 경쟁하는가?** 마지막 해·무작위 사건·UI 번역 예산이다. M37~M48
   shipping seed36→immediate45→deferred 포함49에서 기수용2종을 제외한
   47종/460문구/54,231 KO자로 제한한다. M49 이후 후속도 포함하므로
   M37~M48 실제 플레이 전량 번역이라는 주장이 아니다.

## 두 배치 — 정확한 원문 단위

A24사건/249 leaf/30,021 KO자. 사람·몸·이름의 비용.
- `arc_minseo_01_meet`
- `arc_minseo_02_real`
- `arc_year_three_crossroads`
- `arc_year_three_half`
- `arc_y4_three_promises`
- `arc_y4_three_promises_jiyeon_and_deal`
- `arc_y4_three_promises_deal_only`
- `arc_36_unexpected_hand`
- `arc_36_unexpected_hand_father_deal`
- `arc_36_unexpected_hand_person_deal`
- `arc_y4_body_witness`
- `arc_y4_body_witness_jiyeon`
- `arc_y4_body_witness_hyunsu`
- `arc_y4_family_partner_collision`
- `arc_y4_family_partner_collision_jiyeon`
- `arc_y4_family_commitment_none`
- `arc_y4_family_table_missed`
- `arc_y4_borrowed_name`
- `arc_y4_borrowed_name_jiyeon`
- `arc_y4_borrowed_name_self`
- `arc_y4_borrowed_name_document_gap`
- `arc_y4_bill_night`
- `arc_y4_bill_night_jiyeon`
- `arc_y4_bill_night_unattached`

B23사건/211 leaf/24,210 KO자. 연락·의료 경과·연말 책임.
- `arc_father_call_on_ktx`
- `arc_father_call_on_ktx_memory`
- `arc_father_call_on_ktx_number`
- `arc_y4_father_call_answered_on_ktx`
- `arc_y4_father_call_missed_on_ktx`
- `arc_y4_father_crisis_contact`
- `arc_y4_father_final_contact_present`
- `arc_y4_father_final_contact_called`
- `arc_y4_father_final_contact_missed`
- `arc_father_passing`
- `arc_father_passing_platform`
- `arc_father_passing_deal_room`
- `arc_father_passing_hospital_room`
- `arc_father_passing_deal_morning`
- `arc_y4_father_crisis_stabilized`
- `arc_y4_father_outcome_unknown`
- `arc_y4_year_close_daeun`
- `arc_y4_year_close_jiyeon`
- `arc_y4_year_close_unattached`
- `arc_year4_close`
- `arc_37_reckoning`
- `arc_final_year_start`
- `callback_chose_money_father_echo`

공백·개행 포함 자수다. 조건128 leaf는 A71(known33+memory38),
B57(known23+memory20+moral2+choice moral12)이다. reader/foreshadow0이다.
`arc_year_three_half`의28개 known(기본1+27조합)과 기억1을 분리 누락하거나
조합을 기계적으로 중복 처리하지 않는다. 각 변형을 대응 KO와 전수 대조한다.
독립 text deliverable은 사건별이며 문장을300~800자로 자르거나 장면 수를 늘리지 않는다.

M49 이후 정적 후속3종도 번역한다: `arc_year4_close`의1주 지연
`arc_37_reckoning`→즉시 `arc_final_year_start`, 그리고
`arc_father_passing_deal_morning`의12주 지연
`callback_chose_money_father_echo`다. 마지막 callback은 일반 풀에도 있어
W200 실제 노출을 보장하지 않는다. author-only/planned/public 중첩0,
기수용 `arc_35_path_cost`와 `arc_35_habit_check`는 변경0이다.

## 정확한 파일 소유권

각 `content/events_<ja|zh-CN|zh-TW>/` 아래6파일에서 위47 ID만 소유한다.

- `arc_new_characters.json`, `arc_midgame.json`, `arc_chapter_themes.json`
- `arc_drama.json`, `arc_year_close.json`, `callback_events_42.json`

언어별 작성자는 한 명이며 교차 검토자는 읽기 전용이다.
root는 `tools/full_game_localization.py`, `tools/full_game_localization_self_test.py`,
`tools/zh_translation_audit.py`, `tools/audit_scope.json`,
`content/meta/full_game_localization.json`, 이 사양·CODEX_QUEUE·CLAUDE·WORK_LOG·
생성 STATUS·전체 현지화 backlog를 소유한다.
부팅 예산이 필요하면 WORK_LOG 앞선 완료절을
`docs/history/WORK_LOG_2026-09-07_localization.md`에 원문 그대로 이동한다.
수량/이름 오탐은 실제 원문 문맥+정상/변조 fixture로만 수리하며 전역 완화하지 않는다.

KO/EN·runtime·저장·라우팅·관계·catalog/endings·폰트·공개 overlay·언어 출시·
human_gates는 비소유다. 원문 결함은 별도 기록하며 번역으로 몰래 수리하지 않는다.

## 검증과 보존

- source manifest `edf845a7164b8fedc9ec027be7a7edc381a3dcdf67ff58c2858d44a3237b64b8`.
  최초 source export6개를 limit256으로249/211씩 발급해 보존한다.
  source ID/hash·선택 배열·조건 키 순서·빈 줄·토큰과 기존5,412 receipt/메타9를 유지한다.
- 세 언어는 KO에서 직접 작성한다. 다른 검토자가1,380개 전체와 조건128개/언어,
  모든 선택 결과·금액·기간·인명·생사·연락/동석·장소를 대조한다.
- L1은 `full-game-localization-overlays` 표적 차선·EN·diff·source/target receipt다.
  새 검사 수리는 독립 정상/변조 검토를 받는다. draft의 미수용 scope 실패는
  정상 경계이며 baseline 완화로 통과시키지 않는다.
- L2 원문 대조와 L3 사용자 무작위 표본·원어민·실제 화면은 다르다. L3 OPEN,
  전체 INCOMPLETE·full/main/product HOLD·배경 제품53493fe를 유지한다.
  공개 M01~M06 사용자 GO를 본편/새 언어 출시 승인으로 확대하지 않는다.

분할·파일·이번 증거는 일회성이다. 지속 규범은 기존 I18N_INFRASTRUCTURE와
세 용어집이 소유하며 새 서사·상품·출시 규칙을 만들지 않는다.
