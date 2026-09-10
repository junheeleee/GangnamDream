# Active Queue Spec: ORDER-231

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-231 [전체 현지화] 남은 초기 코어22종·140문구/언어

**[~] 2026-09-10 착수 — 아래 파일만 소유한다.** 사용자 전체 번역·개발 위임과
ORDER-157을 따른다. 기준은 clean main `1a9799ed7a0b3166d8ae2b065596509b83cb0d2d`,
tree `30dbc3d009f4736fa67049252b576bf1525f5893`이다.

## 깊이 3문·판정 대상

1. 없으면 무엇이 빠지는가? 세 언어에서 아직 없는 일·관계·주거비22종의 원문140문구다.
2. 미래 상태를 바꾸는가? 선택·기억의 의미만 보존한다. 조건·효과·일정 변화는0이다.
3. 무엇과 경쟁하는가? 원문이 가진 돈·몸·사람에게 쓰는 시간의 선택을 번역하며,
   별도 행동판이나 새 플레이 기능을 더하지 않는다.

한국어 전체22객체는 ROOT가 읽었다. 22title+22description+40choice+40result+
16memory=140, LF215, `{name}`73와 다른 동적 토큰7이다. 원문 파일
`content/events/core_loop_v2_events.json`은82380B,
SHA `30ce137faf06437e131d297efa7ab3fc82806534e77c53bea33af0b01a750b87`이다.
선택 source records SHA는
`b074632322a8fcd23337c59ecb596801c13aa8f7666884d3cdfeabbd25027a0e`다.
모두 shipping 분류지만 weight0/hidden/min_turn9999다. 분류는 현재 도달 증거가 아니다.

## 정확한 선택

```text
v2_hanbit_offer_message
v2_daeun_small_commitment
v2_daeun_third_greeting
v2_jiyeon_second_crossing
v2_sangchul_demo_echo
v2_jaehyuk_plain_reunion_echo
v2_father_health_signal
v2_dodam_result_message
v2_city_service_work_sample_message
v2_city_service_result_message
v2_daeun_tuesday_followthrough
v2_hyunsu_exam_eve
v2_hyunsu_exam_morning_echo
v2_gangnam_receipt_walk
v2_convenience_trial_shift
v2_inventory_count_nights
v2_logistics_class_session
v2_moving_crew_days
v2_empty_sunday
v2_demo_first_bill_opening
v2_m3_room_ledger_anchor
v2_m4_housing_consultation_anchor
```

## 파일 소유권·병렬 분담

- Plato: `content/events_ja/core_loop_v2_events.json` 신규22만 append.
- Rawls: `content/events_zh-CN/core_loop_v2_events.json` 신규22만 append.
- Poincare: `content/events_zh-TW/core_loop_v2_events.json` 신규22만 append.
- 세 저자는 각각 KO에서 직접 작성한다. 영어 중역·지역 간 변환0. 기존12객체/68문구의
  raw prefix·순서·값을 보존하며 신규부분 역제거가 기존 파일 전체와 byte-exact여야 한다.
  비저자 전량 대조: Rawls→JA, Poincare→CN, Plato→TW. ROOT는 통합·증거를 소유한다.
- ROOT: `content/meta/full_game_localization.json`에 검수420와 batch1만 추가.
  기존37522/b90/retained metadata9를 역제거로 보존한다.
- 조건부: `tools/ja_translation_pipeline.py`, `tools/zh_translation_audit.py`,
  `tools/full_game_localization.py`, `tools/full_game_localization_self_test.py`.
  첫140 L1의 실제 정상 오탐이 생겼을 때만 exact source·역할 단위의 수리를 한다.
  코드 전에 actual/다른 정상/유효 변조/source-OFF와 비저자 대조를 봉인하고 같은 입력으로
  재검사한다. 전체 leaf 면제·전역 예외·과거 기대 완화0. 좋은 산문을 검사에 맞추지 않는다.
- 운영: `CLAUDE.md`, `docs/CODEX_QUEUE.md`, `docs/CODEX_QUEUE_L3_PENDING.md`,
  `docs/WORK_LOG.md`, `docs/STATUS.md`, `docs/queue_backlog/FULL_GAME_LOCALIZATION.md`,
  이 사양, `docs/queue_archive/ORDER-231_L1_L2_RESULTS.md`, `tools/audit_scope.json`,
  `docs/agent_review_decisions.json`, `docs/agent_reviews/ORDER-231.json`.
  사적 source/response/receipt/증거/QA helper는 `.git/full-game-localization/order231-*`다.
- **손실 없는 이력 이동:** WORK_LOG의 byte33818~EOF39278(5460B), 시작 제목
  `## 2026-08-31 (Codex — 전체 볼륨 자식 배치 선언)`부터 마지막 완료 절까지를
  과거 완결 이력4절을 그대로 `docs/history/WORK_LOG_2026-09-07_localization.md`의 EOF76217 뒤에 newline1+
  exact block으로 옮긴다. block SHA
  `8f60a3f39bfa1eefe8e689ac8bae305dbdbedf65fd66e0ba4f4a9176b8e1758a`,
  history SHA `9af473ea70cd45b34ec0c01b21906864a8e490b00040067f3d8e0ad9c042e6a1`.
  다른 절 이동·요약·삭제0. 앞쪽 새 완료 기록은 별도 삽입한다.

KO/EN·gameplay·인과 원장·runtime/ingress 조사·활성화·저장·project.godot·공개 데모·
인간 원장·언어 선택기·폰트·UI 사전/동적 producer는 비소유다.

## 사실 경계

- 한빛 c0만 수락/회신. 월요일 출근과3주168만원/온전한 달224만원은 미래 급여다.
- 다은 세 번째 인사와 화요일 약속을 합치지 않는다. 6월2일01시의 어제와 상호 응답은
  유지하되 연애를 앞당기지 않는다. 지연 커피/한 블록 걷기/이탈은 별도다.
- 상철·재혁은 원문에 있는 실제 만남만 유지하고 빠진 일정 조율 대사를 발명하지 않는다.
- 아버지는 생존, 전화 미응답 뒤11분 후 실제 문자. 남성 최씨 이웃, 열흘간 두 목격,
  병원 미확인·세 기억을 유지한다. 플래그 done을 진단/통화/방문 완료로 읽지 않는다.
- 도담/도시시설은 면접 전 불합격. 6월17일 샘플 요청·26일18시 마감과 가상 지하1층/
  비상등2개는 실제 근무가 아니다. 현수6월21일22시→27일09시는6일 간격이며 제목은
  시험 전 마지막 문제다. internal exam_eve를 전날로 오역하지 않는다.
- 커피9000원/10분은 구매 선택만. 하루 대타 실제 수령은 금액을 발명하지 않는다.
  재고4일/36만원,11↔12/반품1/미확인 인계/야근의 기억5, 공식3회·처음2회 오류,
  이사4일·상자6중1+5·동시 들기·몸값, 일요일 미회신/공허함을 각각 보존한다.
- 첫 고지서17:52→선택17:53, 미납 조건부 비용/미수령 급여를 지킨다. 문자 재독은
  전화가 아니고 잔액 계산은 납부가 아니다. 장부/주거 기준 선택은 계약·이사가 아니다.

동적7은 `{v2_hyunsu_exam_eve_memory}`, `{cash_position}`, `{expense}`,
`{v2_first_bill_body}`, `{v2_first_bill_trace}`, `{v2_first_bill_evidence}`,
`{v2_first_bill_after_bills}`다. 토큰은 보존하되 생산 문자열·grant_job_display와
선택 밖 후속 v2_demo_first_bill은 이번140에 포함하지 않는다. 원문 연출 채무는
기존 corrected preflight에 남기며 번역으로 몰래 수리하지 않는다.

## 검증·마감

1. 선언 커밋/동기화 뒤 공식 initial export140×3, previous-null420 및 기존 raw를 봉인한다.
2. 직접 저작·자가 전량 대조, 첫 L1 한 번과 모든 실패 원형 보존, 비저자420 전량 검수.
3. 필요 국소 검사 수리만 고정 대조로 닫고 clean C1의 final export/check/import3쌍을
   current target에 결속해 changed_files0을 확인한다. 기존 수용과 보호 입력 역제거 exact.
4. 전체수용 hash/L1 한 번, 명시 `full-game-localization-overlays`12 한 번을 전후 입력으로
   봉인한다. context/queue/diff 표적 검사, Godot/full/240주 재실행0.
5. source-like 문서까지 exact C2로 묶고 비저자 work_unit231 판정 뒤 metadata wrapper만
   추가한다. STATUS는 clean 원장에서 생성·검사한다. 본편 HOLD·인간 원형을 보존한다.

성공 시에만37942(JA12646/CN·TW12648), b91/meta9, 비보호 shipping 사건 결손0이다.
UI·author_only·보호 원고·현재 노출·native/render는 별도다. 자동 검사는 재미·깊이·
문체 증거가 아니다. 기존 I18N/WORK_UNIT 정본을 따른다. 이 선택·소유·마감은 일회성이다.
