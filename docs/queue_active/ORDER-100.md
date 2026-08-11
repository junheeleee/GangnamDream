# Active Queue Spec: ORDER-100

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-100 [P0·Chapter 1 정본] CH1-LEDGER-0 — 48주 인과 원장과 현재 부채를 먼저 고정한다

**사용자 지시 (2026-08-11):** 완성 단위를 24주가 아니라 48주로 잡고 Chapter 1을
완성한다. 구현 중 현재 대화만 기억해 날코딩하지 않으며, 새 세션에서도 같은 판단을
이어 갈 수 있도록 문서 정본과 기계 원장을 코드보다 먼저 세운다.

현재 `seoul_cycle_v1` 제품 데이터는 1~6개월, 즉 W1~24만 갖는다. W25~48은
V2 행동 영수증이 없는 기존 AP 폴백이고, 현 W48 연말 장면은 마지막 주 행동과
12월 정산보다 먼저 호출된다. 따라서 24주 자동 완주나 W48 레거시 장면 도달을
Chapter 1 완성으로 세지 않는다.

## 깊이 3문

1. 지우면 각 세션이 눈앞의 카드·장면을 그럴듯하게 추가하면서도, 완료한 행동의
   다음 동사와 후속 독자가 없는 얕은 기능을 다시 쌓는다.
2. 이번 오더는 제품·스토리·수치·세이브를 바꾸지 않는다. 현재 W1~24의 실제
   생산자·독자·결손과 W25~48 공백을 exact snapshot으로 기록하고 검사한다.
3. 48개 조합별 스토리를 쓰지 않는다. 주간 행동은 시간·비용·접근권을, 수행층은
   그 일을 해낸 방법과 품질을, Story 선택은 태도·기억·불가역 결정을 소유한다.
   서로의 사실은 이름 있는 영수증과 독자로만 연결한다.

## 완성 계약

- Chapter 1은 W1~48, 12개월 × `직업·생계·사람·회복` 네 가족의 **48개 인과
  행**을 가진다. 한 행은 고정 주차 선택이 아니라 그 달 보드에 놓이는 행동
  가족 하나다. 실제 플레이는 매주 네 가족 중 하나에 시간을 배치한다.
- 현행 감사 가능한 prefix는 W1~24의 24행이다. `rows`에는 이 authoritative
  implemented 행만 둔다. W25~48은 내용을 발명한 placeholder 행을 만들지 않고,
  top-level `coverage_gaps` 한 건이 M7~M12×네 가족의 missing slot ID 24개를
  기계적으로 계산한다.
- 각 implemented 행은 `available → in_progress → completed|expired →
  reentered|retired`,
  `next_verb`, 완료·만료 producer, 근거리 독자, 월말 독자, W48 독자, 저장왕복
  증거를 갖는다. W48 독자는 직접 장면 분기뿐 아니라 bounded build aggregation일
  수 있지만 소비 규칙과 최종 scene reader가 모두 명명돼야 한다. 이름 있는
  독자가 없는 flag·receipt는 완성으로 세지 않는다.
- `coverage_gaps`는 week/month range, missing row count, status, owner order,
  runtime proof만 갖는다. 아직 없는 producer·terminal·reader·save proof를 계획으로
  채우거나 gap 24개를 gameplay row로 세면 검사 실패다.
- 완료한 비반복 카드는 같은 죽은 카드로 남지 않는다. 후속 동사로 교체되거나
  `retired` 이유와 재진입 가격을 명시한다.
- 사람 후보는 플레이어가 고른다. 런타임의 첫 eligible 자동 선택을 관계 선택으로
  세지 않는다.
- 반복 행동은 매 사용마다 고유 비용·효과·영수증이 있을 때만 repeatable이다.
  진행 `+0`과 같은 이름만 반복하면 `FAKE_REPEAT`다.
- Story 장면의 입력 상한은 `docs/CHOICE_CONSEQUENCE_SYSTEM.md` §4가 소유한다.
  Story는 주간 행동을 대신 고르거나 추가 주간 자원을 소비하지 않는다.
- W48은 `마지막 행동 → M12 완료·만료·세계 사건 → 12월 정산·실패 판정 →
  chapter1_end_snapshot → 연말 보스 → 실제 본 장면 회고 → chapter1_complete 저장
  → 완료 화면` 순서다. 사용자가 2장 시작을 선택한 뒤에만 W49로 간다.

## 배치 A — checker-first W1~24 implemented prefix 25단위

1. Chapter 1 범위·세 층 소유권·W48 종료·원장 schema와 최소 checker/self-test
   harness를 먼저 고정
2–25. M1~M6의 month×family 24행을 각각 독립 판정

각 행은 runtime pointer, availability, 완료·만료 producer, terminal, next verb,
근거리·월말·연말 reader, replay/save proof를 한 단위로 대조한다. 24행을 한 번의
“전수 확인”으로 뭉개지 않는다.

## 배치 B — W25~48 gap·검사·부채 라우팅 25단위

1–24. M7~M12의 month×family 24 missing slot ID를 각각 대조하되 gameplay row를
   만들지 않고 단일 `coverage_gaps` 범위 레코드·후속 owner ORDER-104~106·
   `ROW_BIJECTION` debt로 판정
25. checker·self-test·baseline·audit wiring·새 세션 context routing을 한 묶음으로
   실행하고 current missing/extra/stale를 봉인

## 초기 exact debt

초기 baseline은 아래 결손을 숨기지 않는다. 자세한 ID는 machine baseline이 소유한다.

- `ROW_BIJECTION`: W25~48 month×family slot 24개 미구현
- `DEAD_CARD`: 완료 뒤 대체 동사가 없는 비반복 카드 12개
- `AUTO_PERSON_PICK`: M2~M6 사람 카드 5개
- `ORPHAN_FACT`: M1 자소서 `resume_polished`, M6 NCS action receipt
- `SHADOWED_READER`: M3 재고조사→M4 물류수업 reader 1개
- `UNREACHABLE_CAP`: M5 사람 최대 2 계약 1개
- `UNSCHEDULED_CHAIN`: 현재 W1~24 데이터에 선언됐지만 fresh 서울 사이클 편성이
  없는 `bundle:sns_pressure_night`
- `DISPLAY_ONLY_FORGONE`: 주간 `forgone_ids`가 후속 행동을 바꾸지 않음
- `LAYER_COLLISION`: 프롤로그 Story가 지원 상태를 직접 씀

`ROW_BIJECTION`은 48 target의 missing/duplicate month×family에만 쓴다.
`FAKE_REPEAT`는 W1~24 evaluated scope에서 0건이다.
`ROUTE_NO_DIVERGENCE`, `ROUTE_HARD_LOCK`, `SAVE_ROUNDTRIP`의 48주 전체 판정은
top-level `evaluation_registry`에서 `blocked_by_coverage`와 blocker gap ID를 갖는다.
미구현 후반부를 0건으로 보고해 거짓 초록을 만들지 않으며 ORDER-107에서만 full
scope 0건을 요구한다. blocker 없는 blocked, gap이 있는데 full evaluated 주장,
evaluation 행 삭제는 self-test가 거부한다. 표현 선택의 수치 합류는 합법이므로
`COUNTERFACTUAL_NOOP`으로 세지 않는다. 해당 코드는 행동·기억·결정 선택이 next
verb·비용·가용성·참가자·결과를 전혀 바꾸지 않을 때만 쓴다.

허용 debt code는 `ROW_BIJECTION`, `DEAD_CARD`, `ORPHAN_FACT`,
`SHADOWED_READER`, `AUTO_PERSON_PICK`, `UNREACHABLE_CAP`, `UNSCHEDULED_CHAIN`,
`DISPLAY_ONLY_FORGONE`, `COUNTERFACTUAL_NOOP`, `LAYER_COLLISION`,
`MILESTONE_FANIN`, `FAKE_REPEAT`, `ROUTE_NO_DIVERGENCE`, `ROUTE_HARD_LOCK`,
`SAVE_ROUNDTRIP`의 정확 15개다. `MILESTONE_FANIN`은 `story_milestone` reader가
행동/build 가족 2개+Story 결정 1개를 넘거나 입력이 이름 없이 합쳐질 때만 쓴다.

## 정확한 파일 소유권

**선언·정본 9:** `docs/CODEX_QUEUE.md`, 이 사양, `CLAUDE.md`,
`docs/CORE_LOOP_V2.md`, `docs/CONTEXT_INDEX.md`, `docs/QA_CHECKLIST.md`,
`docs/DECISIONS.md`, `docs/WORK_LOG.md`, 생성 `docs/STATUS.md`. 최신 사용자 지시가
기존 24주→후반부 순차 승인 결정을 48주 Chapter 1 완성 단위로 대체한 이유는
`docs/DECISIONS.md`에 한 번만 기록한다. 부팅 예산 보관 이동은
`docs/history/WORK_LOG_2026-08-03.md`만 추가로 소유한다.

**기계 원장·검사 5:** 신규
`content/meta/chapter1_core_loop_v2_causal_ledger.json`, 신규
`tools/chapter1_core_loop_v2_causal_ledger_check.py`, 신규
`tools/chapter1_core_loop_v2_causal_debt_baseline.json`, `tools/audit.sh`,
`tools/audit_scope.json`.

**컨텍스트 정합 1:** `docs/context_manifest.json`.

제품 런타임, `content/meta/demo_core_loop_v2.json`, 사건 원고, 밸런스 수치,
저장 schema, UI·입력·폰·프롤로그는 이번 오더에서 수정하지 않는다. 원장이 발견한
결손 수리는 ORDER-101 이후 8주 단위 오더가 하나씩 소유한다.

## 완료 증거

- machine ledger가 target `48`, implemented `24`, gap `24`를 정확히 보고한다.
- W1~24 24행의 runtime pointer·가족·producer·terminal·reader가 현 제품과 맞는다.
- current debt가 baseline과 missing/extra/stale 0으로 일치한다.
- malformed·duplicate·stale pointer·orphan·shadowed·coverage-gap mutation self-test가
  모두 실패를 검출한다.
- audit selector는 원장·baseline·checker·제품 source 변경에서 이 검사를 고른다.
- JSON parse, checker self-test/current, audit scope verify, queue/context/dashboard,
  `git diff --check`가 통과한다.
- normal audit은 known gap이 있어도 snapshot을 검증할 수 있지만 반드시
  `COVERAGE_GAP weeks=25..48 missing_slots=24 authoritative=24/48`을 출력하고
  Chapter 1 `OK`라고 부르지 않는다. 별도 `--require-complete-chapter-one`은
  rows 48, gap 0, blocked evaluation 0, current debt `{}`, baseline `{}`일 때만
  통과한다.
- baseline은 metadata나 빈 배열 없이 `{ERROR_CODE:[stable_id,...]}`만 가지며
  current와 exact equality다. 새 debt와 이미 해결된 stale debt가 모두 실패하고,
  명시적 갱신 명령 없이 자동 재작성하지 않는다.

## L1·L2·L3 증거 양식

- L1: checker self-test/current, exact debt equality, audit selector/full audit와 문서·
  JSON 정합.
- L2: 48 target slot 전수표에 month/family, implemented 또는 missing, runtime/current
  gap, producer↔reader, next verb, debt owner를 한 행씩 기록한다. 요약 count만으로
  대체하지 않는다.
- L3: 12개월×네 가족 전수 요약을 사용자에게 보여 정본 범위·공백·수리 순서를
  판정받는다. 자동 checker 통과는 canon GO가 아니며, 사용자 판정 전 ORDER-100을
  `[x]`로 닫지 않는다.

이 오더는 baseline을 `{}`로 만들지 않는다. 최종 Chapter 1 후보에서 모든 행과
milestone이 실체화되고 baseline이 `{}`가 되는 책임은 ORDER-101~107이 나눠 가진다.

## 후속 오더 경계

1. ORDER-101 — W1~8 온보딩·자소서/지원·첫 후속
2. ORDER-102 — W9~16 재고조사·지원·관계 선택의 다음 동사
3. ORDER-103 — W17~24 첫 청구서 전반부 완결
4. ORDER-104 — W25~32 실패 뒤의 실제 행동
5. ORDER-105 — W33~40 주거·관계·직업 빌드
6. ORDER-106 — W41~48 마지막 압박·연말 결산·Chapter 1 완료
7. ORDER-107 — 동일 clean RC의 48주 통합 입력·표면·밸런스 증거와 사람 게이트
   등록·handoff. 실제 사람 GO는 `human_gates.json`에 OPEN으로 남아 사용자가 판정

각 자식은 앞 오더의 실측 원장을 입력으로 삼아 별도 선언 커밋을 만들며, 다음
자식의 제품 파일을 미리 소유하지 않는다.

**규범 판정:** 48행 인과 계약, 세 층 연결, named reader, W48 종료 순서는
`docs/CORE_LOOP_V2.md`로 승격한다. Story 입력 상한은 기존 단일 정본
`docs/CHOICE_CONSEQUENCE_SYSTEM.md` §4를 참조한다. 현재 debt snapshot과 작업
단위·후속 오더 번호는 일회성 실행 기록이다.
