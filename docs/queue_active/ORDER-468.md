# ORDER-468 — PR31 문장 수리와 검증 이력 통합

#### [~] ORDER-468 [P1·사용자 지시] Claude의 B3/B4 문장 수리를 main에 들인다

**[~] 착수 — 2026-10-05.** 사용자 지시가 기존 순서보다 우선한다.
정본 작업표는 PR31의 `docs/queue_backlog/PR31_INTAKE_RUNBOOK.md`이며
2026-10-03 갱신부터 확인했다. B1 근거 문서와 함께 현재 main에 들였다.
관측 PR head `b9284e3`는 지시의 `fe2bb4c4`에 심의 목록 gambling/violence 지문
보정 1커밋만 더했다. 새 출시·심의 인증을 뜻하지 않는다.

## 순서와 단위

1. `english_hangul_audit.py`의 Holdem 한국어 전용 조사 교정 오탐을 수리한다.
   실제 영어 누출을 허용하지 않는 양성/음성 검사와 현재 기본 검사를 한다.
2. B3 `b0efea56`과 B4 `3643da2b`~`446eab5d`를 하나의 문장 수리 묶음으로 들인다.
   이미 main에 있는 B2 영수증·패드 폰트는 중복 적용하지 않는다.
3. 같은 범위에서 MainGame exact6줄 승인/호출 좌표, release inventory 실제 전이,
   `arc_father_legacy` description·memory 2개(총3잎)의 JA/CN/TW 영수증을 맞춘다.
4. 작업표 CI 귀속을 현재 후보와 비교한다. 새 실패0을 확인하기 전 완료하지 않는다.

깊이3문: 살아 있는 아버지에게 사망 문장을 보여 주는 사실 오류와 장면을 대신하는
해설을 수리한다. 분기·경제·효과는 추가하지 않는다. 정확한 인물 상태와 장면이
플레이어가 이미 선택한 삶의 결과를 전달해야 한다. 새 장면 집필은 아니다.

## 소유 파일과 보존

- root 통합: `content/events*/` 중 PR B3/B4 변경 파일과 `content/endings*.json`,
  `content/meta/full_game_localization.json`, `content/meta/release_content_inventory.json`,
  `docs/CONTENT_RATING_INVENTORY.md`, `scenes/MainGame.gd`의 `_resolved_ending_description` exact6줄.
- root 지원: `tools/english_hangul_audit.py`, `tools/main_game_locale_history.py`,
  `tools/ja_translation_pipeline.py`, `tools/ja_translation_audit.py`, `tools/ui_translation_append.py`,
  `tools/chapter1_core_loop_v2_causal_ledger_check.py` 및 그 실제 inventory history 소유 도구,
  `tools/audit_scope.json`, 신규 `tools/pr31_intake_check.py`.
  소유 도구의 정확한 추가 경로는 실행 전 이 사양에 좁혀 기록한다.
- root 준비된 엔딩 회귀: 신규 `tools/PR31EndingDescriptionCheck.gd`,
  `tools/PR31EndingDescriptionCheck.tscn`, 생성 `.gd.uid`만 추가한다.
  실제 Main resolver/5언어 DataRegistry를 headless로 읽되 Main을 트리에 넣지 않고,
  pre-autoload 새 저장공간에서 생존/사망 증거3종과 기존 타 엔딩 분기를 검증한다.
  실제 화면·입력·자연 플레이·원어민 판정은 아니다.
- 지원 소유 분리: pr31_main_compat는 Main history/pipeline/JA audit/ui append 4도구만,
  pr31_history_plan은 신규 `tools/pr31_intake_history.py`,
  `tools/pr31_intake_history_self_test.py` 및 기존 `tools/order365_ui_receipt_compat.py`,
  `tools/chapter1_core_loop_v2_causal_ledger_check.py`, `tools/full_body_translation_scope.py`,
  `tools/story_graph_contract_audit.py`, `tools/chapter5_human_reject_audit.py`,
  `tools/year5_reference_route_audit.py`의 current admission 연결만 소유한다.
  과거351/350/313/309 원문·핀은 불변이며 새 실제 제품 역상만 비교용으로 제공한다.
- PR B1 근거 문서: DECISIONS·I18N_GLOSSARY의 PR 변경, PR의 queue_backlog 문서와
  역사 기록. 기존 WORK_LOG는 덮어쓰지 않고 이력 링크/이번 항목만 보탠다.
  `tools/prose_signal_report.py`는 제품 들이기에 필요하지 않으므로 제외한다.
- root 기록: 이 사양/큐(이어보기 `CODEX_QUEUE_L3_PENDING.md`의 순번 포함)/CLAUDE 현재행/WORK_LOG/생성STATUS 및 독립 판정 원장.
  비저자 검수 보고 `docs/agent_reviews/ORDER-468.json`; private 증거 `.git/pr31-intake-*`.
- 이전467 미완료 변경4도구와 InvestmentAPCopyCheck2파일은 지우지 않는다.
  AP3문구 수리와 실제 Git 핀을 보존하고 이번 Main6줄과 연결한다.
  기존467의 미실행 검사를 실행한 것으로 기록하지 않는다.

실제 B3 원장 비교에서 father3 외 minseo_arrival description, name_boundary description,
debt_memory_reconnect description/result0, final_father_answer_alive description 5잎도
source가 낡아짐을 확인했다. 원래 B3 안의 총8잎×3언어24영수증을 fresh 수용한다.
이는 새 사건·번역 확대가 아니며 기존 미수용 name_on_line 결과1은 이번에 추가하지 않는다.

현재 수용 사건 전체의 source를 다시 대조해 PR이 바꾼 조건부 결과 3잎도
낡은 영수증으로 남았음을 확인했다: `arc_minseo_03_arrival`의
`description_if_known/contacted_minseo`, `arc_jiyeon_wedding_gap_father_passed`와
`arc_year4_close_father_passed`의 `choices/1/result_text`.
앞 두 잎은 번역문을 보존하고 영수증만 갱신한다. 마지막 잎은 JA/CN/TW의
낡은 옥상 회색 문장을 현재 KO/EN의 종이 한 장 문장으로만 바로잡는다.
같은 PR 들이기의 잔여 결함이며 총11잎×3언어33영수증이다. 앞선24 수용은
보존하고 추가9를 공식 export/check/import한 별도 실제 Git 전이로 결속한다.
수정 범위는 해당 세 언어 `arc_year_close.json`의 결과문 한 문장씩과 원장,
위 소유 history helper/self-test의 exact 역상뿐이다. 원문 KO/EN은 불변이다.

검증 중 한 consumer 호출 안에서도 Main의 같은96객체 증명을 반복하는 것을
코드로 확인했다. `main_game_locale_history.py`에 호출 범위로만 살아 있는
증명 공유를 추가하고 root가 `order365_ui_receipt_compat.py`의 바깥 문맥에 연결한다.
독립 호출은 새로 검증하며 매 재사용 시 HEAD/tree/blob/실제 Main·모듈 바이트를
확인하고 정상 종료 때 전체96객체 증명을 다시 확인한다. 전역 성공 캐시나
manifest 판정 재사용은 금지한다. pr31_main_compat는 이 도구와 신규
`tools/pr31_main_proof_scope_check.py`만 소유하고 root는 검사 등록/실행을 맡는다.

독립 KO/EN 수정부 검수에서 PR이 만든 기간 불일치2건을 확인했다.
다은 최종선택의 `description`·`description_if_known/namsan_lock_daeun`과
바로 잇는 kitchen의 `description`은 같은 명의 거래를 지난해/몇 년 전으로
다르게 부른다. 실제 입구는 test182주 이후·finale228주 또는30억 달성이므로
고정 연도는 보장되지 않는다. 지연 year5_return `choices/1/result_text`도
부산 출발110~135주→귀환193주 이후라 PR의2년을 보장하지 않는다.
이미 소유한 `arc_daeun_married.json`, `arc_year3_drama.json`의 5언어에서
해당4잎만 기간 단정을 없는 과거 회상으로 정렬한다. 관계·효과·분기·일정과
남산10년 약속은 보존한다.
같은 검수에서 `stable_success` 1잎·`orthodox_pinnacle` 12잎·
`unorthodox_legend` 7잎의 새 금액 표현이 실제 `>=` 엔딩 입구를
`넘었다/over`로 잘못 좁힘을 확인했다. 5언어의 이20잎만 `이상/at least`로
고친다. 금액·조건·게임플레이·다른 문장은 바꾸지 않는다.
합계24원문잎×5언어120문자열의 실제 source-only 전이와 이후
events4/endings20×3언어72영수증·6배치의 ledger-only 전이를 분리한다.
기존33갱신을 보존한 총105갱신이며, 원문 변경에 따른 release inventory의
실제 corpus/axis 지문과 필요시 rating 문서만 같은 source 전이에 정렬한다.
두 실제 Git 전이를 기존 이력 helper/self-test의 exact 역상으로 검증한다.
기존 준비된 엔딩 fixture에 실제 `>=` 경계의 상태·5언어20문장 표적 검증을
추가한다. pr31_main_compat가 `tools/PR31EndingDescriptionCheck.gd`만 소유하고
root가 격리 실행하며 실제 자연 플레이나 렌더 증거로 부르지 않는다.
이는 새 장면이나7k가 아닌 들이기에서 확인한 새 사실 오류 수리다.

같은 엔딩 검수에서 main `e97e2cd`부터 존재한 사실 결함2건은 별도 후속으로
남긴다: stable_success의 고정 `남은20억`은 실제 잔여액과 다를 수 있고,
세 엔딩의 통장/잔고 표현은 실제 현금+보유자산−대출인 순자산 판정과 다르다.
5언어 모두 baseline·PR·수정본을 직접 비교해 기존 결함으로 귀속했다.
이번 기간/포괄경계 수리 GO는 이 두 문제나 엔딩 전체 factual GO가 아니다.

공식 CN check에서 `아버지가 떠난 지 여덟 달이 넘었다`를 일반 월수로 분류해
정확한 `八个多月/八個多月`를 거부하는 오탐을 확인했다. PR 번역을 바꾸지 않고
`tools/zh_translation_audit.py`의 기존 duration_month_over 분류에 이 정확한
선행구만 추가한다. pr31_main_compat가 해당 분기와 신규
`tools/pr31_quantity_check.py` 양성/음성 표적 검사를 소유한다.
값·단위·초과/미만·중복 수량 검사는 보존하며 범용 예외는 추가하지 않는다.
동일24잎 전수 기계검사에서 `십 년이 넘은 보증인 칸`과 `十多年前`도
같은 종류의 초과기간 오탐으로 확인했다. 같은 두 도구에서 보증인 칸의
정확한 한국어 후행구에 한해 초과 연수 분류와 기존 초과기간 부정/단위 방어를
함께 연결한다. 일반 연수 패턴은 넓히지 않으며 원래 번역은 그대로 둔다.

**금지:** 모든 언어의 `arc_events.json`, `project.godot`, 공개 데모/사용자 저장,
과거 인간 판정과 실제 GO를 변경하지 않는다. 7k·수첩/5년 초안은 후속 별도 오더다.
PR 전체 파일을 덮어써 main의 새 번역·AP 수리를 되돌리지 않는다.

## 검증과 완료 경계

- 실제 merge-base/두 부모/제품 경로·전후 원문을 기록한다. 영어 한글 오탐 수리부터
  확인하고, JSON 의미 diff와 main 신규 영수증 보존을 검증한다.
- 기본 JA_UI, JA_DEMO_PIPELINE_SELF_TEST, ZH_DEMO_AUDIT/SELF_TEST,
  CHAPTER1_INVENTORY_HISTORY, full_game_localization inventory와 관련 기존
  source/receipt/서사 검사를 귀속표에 따라 실행한다. 과거 실패를 새 PASS로 바꾸지 않는다.
- 새 exact successor는 부모/객체/전체 역상을 검증하며 범용 예외를 추가하지 않는다.
  아버지 생사·empty_house 분기를 준비된 회귀로 확인한다. 실제 화면·자연 플레이와 구분한다.
- context/queue/생성STATUS/등록/diff를 확인하고 검증된 변경만 main에 푸시한다.
  병합 또는 검사 진행 중에는 완료·출시 GO가 아니다. 원어민/인간 플레이/물리패드
  미관찰은 그대로다. 기존 규범 적용, 이번 통합 지시와 exact 핀은 일회성이다.
