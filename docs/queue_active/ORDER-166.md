# Active Queue Spec: ORDER-166

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-166 [P0·전체 현지화] 마지막 해의 사람·계약·가족 판정을 세 언어로 옮긴다

**[~] 2026-09-07 Codex 착수 — 아래 정확40 ID의 JA·zh-CN·zh-TW text-only
overlay, 원문 결속 검사·수용 기록·증거 문서만 소유한다.**
사용자 전체 게임 번역 지시를 구현 `ef931a5`에서 이어간다.
기존6,792 수용·비표시 메타9와 별도 선언한 공개CN 한 문장 수리를 보존한다.

## 깊이 3문

1. **없으면 무엇이 깨지는가?** 4년차 비용을 겪은 뒤 마지막 해 계약·민서·아버지·
   관계 판정이 다시 영어로 돌아간다. 부동산/일반, 생존/별세, 도착/미도착을
   함께 번역해 사람이 없거나 동의하지 않았는데 결과가 먼저 성립하지 않게 한다.
2. **선택을 바꾸는가?** 효과·일정·채널·참가자·생사·주거·서명·소유 변경0이다.
   기존 사람 피드백으로 수리된 무응답/미계약과 M55 의상/초상 계약은 비소유다.
   조건별 reader78문구와 inline slot 순서를 보존해 읽는 이력을 바꾸지 않는다.
3. **무엇과 경쟁하는가?** 종막15종과 남은 일반 사건·UI 번역이다. M49~M60
   shipping seed51→정적 closure61/601에서 기작성6/46을 빼면55/555다.
   이 중40/358만 두 배치로 하고 종막15/197은 후속으로 분리한다.
   정적 번역 closure이지 정상 속도 실플레이 전량 번역 주장이 아니다.

## 두 배치 — 정확한 원문 단위

A20사건/180 leaf/23,013 KO자. 계약 입구·민서·재혁·상철·일반 경로의 경계.
- `arc_y5_contract_cover_investment`
- `arc_y5_contract_reviewer_delivery_sangchul`
- `arc_y5_protection_boundary_daeun`
- `arc_y5_final_push_deadline_investment`
- `arc_minseo_03_arrival`
- `arc_minseo_03b_not_arrived`
- `arc_y5_after_goal_daeun`
- `arc_y5_burnout_check_reference`
- `arc_y5_minseo_goal_cost_reference`
- `arc_y5_final_offer`
- `arc_y5_final_offer_reference_delivery`
- `arc_y5_general_name_boundary_exact`
- `arc_y5_guarantee_protected_show_daeun`
- `arc_y5_jaehyuk_father_document_reference`
- `arc_y5_jaehyuk_guarantee_decision_reference`
- `arc_y5_jaehyuk_guarantee_request_reference`
- `arc_y5_jaehyuk_return_call_reference`
- `arc_sangchul_final_door`
- `arc_y5_sangchul_review_receipt`
- `arc_y5_general_debt_memory_reconnect`

B20사건/178 leaf/18,236 KO자. 가족의 기록·네 사람의 방·다은/지연 관계 판정.
- `arc_daeun_final_choice`
- `arc_daeun_final_choice_decision`
- `arc_daeun_final_choice_kitchen`
- `arc_daeun_final_choice_name`
- `arc_father_legacy`
- `arc_jiyeon_verdict`
- `arc_jiyeon_verdict_decision`
- `arc_jiyeon_verdict_fear`
- `arc_jiyeon_verdict_voice`
- `arc_pre_ending_father_call`
- `arc_y5_father_trace_alive_exact`
- `arc_y5_father_trace_custody`
- `arc_y5_father_trace_passed_exact`
- `arc_y5_general_father_legacy_cafe_exact`
- `arc_y5_general_father_legacy_voice_exact`
- `arc_y5_name_on_line_daeun_routed`
- `arc_y5_people_verdict_daeun_exact`
- `arc_y5_room_consent_receipt`
- `arc_y5_three_in_room`
- `arc_y5_three_in_room_decision`

전체41,249 KO자(개행/공백 포함), 표준본문280+reader78이다.
A는 known4+memory4, causal reader36; B는 known4+memory2,
causal reader10+finale reader32다. 조건본문14/7roots와 reader78/23roots를
분리 계측한다. reader도 모든 문자열을 직접 읽으며 true/false/default와
`[[c5read:n]]` 위치·순서·개수 및 조건 키를 바꾸지 않는다.
독립 두 collector의 owner별 source 문자열 목록이 동치이고 전부 shipping,
protected=false이며 기수용138종·author-only/planned/public 겹침0이다.

## 정확한 소유권

각 `content/events_<ja|zh-CN|zh-TW>/` 아래7파일에서 위40 ID만 쓴다.

- `arc_daeun_married.json`, `arc_jiyeon_married.json`
- `arc_new_characters.json`, `arc_midgame.json`, `arc_drama.json`
- `arc_year3_drama.json`, `arc_pre_ending.json`

언어별 작성자는 한 명이고 교차 검토자는 읽기 전용이다. 기존행/파일 prefix와
게임플레이 필드를 그대로 둔다. ROOT는 `tools/full_game_localization.py`,
`tools/full_game_localization_self_test.py`, `tools/zh_translation_audit.py`,
`tools/audit_scope.json`, `content/meta/full_game_localization.json`,
이 사양·CODEX_QUEUE·CLAUDE·WORK_LOG·생성STATUS·전체 현지화 backlog를 소유한다.
기존행 덮어쓰기 재발 방지 한 줄은 `docs/I18N_INFRASTRUCTURE.md`에만 둔다.
부팅 예산 때문에 완료절을 옮길 때만 기존
`docs/history/WORK_LOG_2026-09-07_localization.md`에 원문 바이트 그대로 보존한다.

KO/EN·runtime·저장·라우팅·관계·catalog/endings·폰트·공개 overlay·배포 파일·
언어 출시·human_gates는 비소유다. 원문 결함은 번역으로 몰래 고치지 않는다.
새 수량/이름 오탐은 실제 원문과 정상/변조 fixture로 수리하고 독립 검토한다.

## 검증과 보존

- source manifest `edf845a7164b8fedc9ec027be7a7edc381a3dcdf67ff58c2858d44a3237b64b8`.
  최초 export6개(180/178)를 limit256으로 보존하고 최종 source/response/receipt를
  별도로 발급한다. 소스·토큰·개행·배열·조건 키·초기 hash를 전수 대조한다.
- 세 언어는 KO 직접 독립 저작이다. 다른 작성자가1,074개 전체·reader78/언어와
  모든 선택/조건·금액·인물·주거·연락/동석·생사·일정·동의 경계를 대조한다.
- 이전6,792 수용/메타9·공개 working baseline을 유지하고 새 수용만 합친다.
  draft 미수용 scope 실패는 정상 경계이며 baseline 완화로 통과시키지 않는다.
- L1 `full-game-localization-overlays` 표적 차선·EN·diff·source/target receipt.
  독립 L2와 자동 검사는 L3·원어민·실제 화면을 대신하지 않는다.
  전체 INCOMPLETE·full/main/product HOLD·배경 제품53493fe·배포 데모 사용자 GO와
  새 언어 원어민 OPEN을 유지한다. 종막과 모든 남은 사건/UI를 계속 분리 관리한다.

분할·파일·증거는 일회성이다. 지속 현지화 규칙은 기존 I18N_INFRASTRUCTURE와
세 용어집이 소유하며 새 서사·상품·출시 규칙을 만들지 않는다.

## 2026-09-07 구현·원문 대조 결과

- 세 언어40종/358문구씩1,074개를 KO에서 직접 저작하고 다른 작성자가 전수
  대조했다. reader78·조건14/언어와 선택/조건 대안을 빠짐없이 읽었다.
  JA 자정7곳, CN 의자·행위 주체2곳, TW 복사기 걸림·세 화면·이름 표기4곳을
  정밀화하고 재대조했다. 인명 한자 발명·새 응답/동의/소유 추가0이다.
- 초기 export6개는 source ID/path/hash/text가 current KO358과 일치한다.
  최종 `order166-final-{A,B}.source.jsonl`/response6쌍은 check/import PASS,
  changed_files0이며 git-private locale/prompt 디렉터리에 보존했다.
  최종 source+target aggregate:
  JA `dc7c174a00ecf5718c3ac821cf4e2be3607f7f82810990344fc8506fa1f228b4`,
  CN `2d2316f8f7ac3efa63cc34e1579d5ade4709e7e31d9cdc554a31e6db992421ae`,
  TW `348a59c5998c73c5356d0db3d2ff6054c2329eaab85fd0893f105e81cf9354ea`.
- 이전6,792/비표시 메타9를 보존해 portable7,866=언어별2,622로 합쳤다.
  accepted checksum `a66d6d1d0c3585d74c7c798341ad41bb100f8c795394023f2950bb26cea69ba1`.
  source manifest 불변, 기존64행/언어의 값·순서·raw prefix도 정확히 보존했다.
  KO/EN·runtime·공개 working baseline·폰트·출시·human_gates 변경0이다.
- 실제 원문의 혼합 원화·영수증 식별자·수량/단위·부정문·호칭·이름 인용 오탐을
  정상/변조 fixture로 구분했다. 독립 검토가 찾은 금액 귀속 순서 교환, 수량 뒤
  사람/기간 단위 끼워 넣기, 종이/MB 음수, 일요일 수 누락을 수리했다.
  self115·ZH935 통과; 독립211건은 정상38/38·변이162/173 거부,
  실제 CN177변이는174 거부다. 남은11/3은 baseline에도 있던 분류기 한계이며
  새 회귀나 실제 저작 오류로 오인하지 않는다. L2와 별도 보존하고 전체 QA로 확대하지 않는다.
- 계약 월요일/수요일의 '전날', 민서 회수 발화 출처, 다은 메모3글자, 아버지
  속말/입밖 경계는 원문 확인점으로 backlog에 남겼다. 번역으로 몰래 수정하지 않았다.
  완료163절은 history에 원문1938bytes 그대로 이동했다.
- L3·원어민·실제 화면은 OPEN이므로 오더는 `[~]`, 전체 INCOMPLETE와
  full/main/product HOLD·배포 M01~M06 사용자 GO를 유지한다.
  종막15종197문구/언어와 나머지 사건·UI·표시 소비자를 이어간다.
- 최종12개 표적 차선·EN·diff PASS, 실제7,866문구 전수 검사 오류0이다.
  실제 stdout은 git-private `full-game-localization/order166-final-checks.log`에
  보존했다. Godot 실행·전체 감사·새 실플레이 증거는 아니다.
