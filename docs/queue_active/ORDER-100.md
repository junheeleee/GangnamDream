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
- 독자는 사실별 `read_contract`와 그 사실을 실제 소비하는 runtime proof를 가진다.
  결과 팝업·월말 표시·아카이브에 한 번 보였다는 이유만으로 인과 독자나 다음
  동사로 세지 않는다.
- 주간 branch는 보드에서 고른 기회와 공통 완료 사실만 소유한다. 자소서 품질,
  알바 수행 결과, 재고조사 방법, 회복 감소, Story 선택처럼 그 안에서 갈리는
  결과는 source-exact nested output group으로 연결한다. 내부 결과 때문에 주간
  branch 수를 부풀리거나, 다른 행동의 output group을 붙이거나, 상호배타 결과를
  공통 완료 사실로 합치면 검사 실패다.
- 주차 정점도 reader만 기록하지 않는다. W4 단위부터 W48까지 그 장면 안에서
  새 flag·job·deferred receipt·obligation·context root를 만드는 선택이 있으면
  milestone conditional producer와 후속 reader의 exact handoff를 함께 기록한다.
  첫 실행의 due event와 재진입의 claimed/resolved receipt는 서로 바꿔 쓸 수 없다.
- 여러 장면·호출로 이어지는 정점은 `execution_stages`가 source-derived 적용 조건,
  선행 stage, invocation, runtime proof를 명시한다. JSON 배열 위치는 실행 순서의
  증거가 아니며, 같은 순서의 두 stage는 fresh/reentry처럼 실제로 상호배타일 때만
  허용한다. 치명·생존, dirty/clean, 선택적 후속을 한 경로에 모두 함께 있었다고
  합치거나 뒤 stage의 출력을 앞 stage 입력으로 돌리면 검사 실패다.
- 같은 W24 장면이라도 최초 prepare, 이미 준비된 MainGame 재진입, StoryMode 저장
  복귀는 입력 소유권이 다르다. 최초 경로의 현재 장면 handoff를 재진입·복귀의
  material/history 입력으로 재사용하거나 세 경로의 reader 역할을 한 ID에 합치면
  검사 실패다. source에서 서로 배타적인 호출만 같은 reader ID를 다시 쓸 수 있다.
- 첫 청구서 formatter는 special token 하나가 있으면 material·dirty trace·현수·
  obligation replacement를 한 호출에서 모두 계산한다. 따라서 실제 token-bearing
  callsite마다 전체 read set을 기록하고 fact 합집합만 중복 제거한다. token이 없는
  현수 prose 호출에 가짜 reader를 붙이거나 여러 호출을 한 번 읽은 것으로 압축하지
  않는다.
- 저장 증거는 `SaveManager.save_game`의 state payload, UTF-8 byte 쓰기·검증,
  byte 읽기·typed state 복원, `SaveManager.load_game`, `GameState` serialize/load,
  V2 전체 state normalization, Seoul Cycle receipt normalization의 정확한 여덟
  단계를 모두 지난다. 메모리 dictionary 복사나 저장 함수 이름 하나만으로
  SAVE_ROUNDTRIP을 증명하지 않는다.
- 월말 Story reader는 한 실행에서 늘 함께 읽는 입력, 독립적으로 함께 성립할 수
  있는 조건부 입력, 정확히 하나만 성립하는 배타 variant를 invocation 단위로
  구분한다. 입력 상한은 가능한 각 실행 조합의 합집합에 적용하며, 같은 장면을
  여러 reader ID로 쪼개 fan-in을 숨기면 검사 실패다.
- W48은 `마지막 행동 → M12 완료·만료·세계 사건 → 12월 정산·실패 판정` 뒤
  치명적 결과면 그 자리에서 끝난다. 생존한 경로만 `chapter1_end_snapshot →
  연말 보스 → 실제 본 장면 회고 → chapter1_complete 저장 → 완료 화면`으로
  이어지고, 사용자가 2장 시작을 선택한 뒤에만 W49로 간다.

## 기계 상세 보관

완료된 배치·부채 taxonomy·파일 범위·L1 증거는
[보관본](../queue_archive/ORDER-100_L1_L2_2026-08-12.md)이 소유한다. 현재 snapshot은
`target/implemented/gap=48/24/24`, `debt/blocked=60/3`이다. 정확한 ID·pointer·fact·proof는
machine ledger·baseline·checker가 소유하며, 아래 48행은 QA L2·L3 판정 표이지 원장을
대체하지 않는다.

## L1·L2·L3 증거 양식

- L1: checker self-test/current, exact debt equality, audit selector/full audit와 문서·
  JSON 정합.
- L2: 48 target slot 전수표에 month/family, implemented 또는 missing, runtime/current
  gap, producer↔reader, next verb, debt owner를 한 행씩 기록한다. 요약 count만으로
  대체하지 않는다.
- L3: 12개월×네 가족 전수 요약을 사용자에게 보여 정본 범위·공백·수리 순서를
  판정받는다. 자동 checker 통과는 canon GO가 아니며, 사용자 판정 전 ORDER-100을
  `[x]`로 닫지 않는다.

### L2 현재 48-slot 전수표

`P`는 해당 행의 완료·만료 producer ID 수, `R`은 행이 직접 명명한 near+milestone
reader ID의 중복 제거 수다. 정확한 ID·pointer·fact 계약은 같은 `chain_id`의 machine
ledger 행이 소유하며 checker가 source와 대조한다. 표의 `없음`은 빈칸이 아니라 현재
`DEAD_CARD` 또는 후속 구현 경계다. 전역 부채 5개는 표 아래에 따로 적는다.

| 월·가족 | 현재 정본 행 | producer → named reader | 완료 / 만료 뒤 동사 | 현 부채·후속 |
|---|---|---:|---|---|
| M1 직업·앞날 | `m1_resume` · 자기소개서 고쳐 쓰기 | P5 → R5 | 없음 / m2_advancement | DEAD+ORPHAN×2 · ORDER-101 |
| M1 생계 | `m1_convenience` · 이번 주 편의점 시프트 | P5 → R6 | m1_convenience / m2_livelihood | — · ORDER-101 |
| M1 사람 | `m1_father` · 아버지에게 할 말 적기 | P4 → R7 | 없음 / m2_people | DEAD · ORDER-101 |
| M1 회복 | `m1_recovery` · 이번 주 하루 비우기 | P2 → R4 | m1_recovery / m2_self | — · ORDER-101 |
| M2 직업·앞날 | `m2_advancement` · 서린물산 지원서 완성하기 | P5 → R6 | 없음 / m3_advancement | DEAD+ORPHAN · ORDER-101 |
| M2 생계 | `m2_livelihood` · 배달 콜과 비 오는 금요일 | P5 → R6 | m2_livelihood / m3_livelihood | ORPHAN · ORDER-101 |
| M2 사람 | `m2_people` · 연락하고 만날 시간 맞추기 | P4 → R6 | 없음 / m3_people | DEAD+AUTO · ORDER-101 |
| M2 회복 | `m2_self` · 밀린 잠 갚기 | P4 → R4 | m2_self / m3_self | ORPHAN · ORDER-101 |
| M3 직업·앞날 | `m3_advancement` · 한빛유통 지원서 보내기 | P5 → R6 | 없음 / m4_advancement | DEAD+ORPHAN · ORDER-102 |
| M3 생계 | `m3_livelihood` · 야간 재고조사 조에 들어가기 | P5 → R8 | m3_livelihood / m4_livelihood | SHADOW · ORDER-102 |
| M3 사람 | `m3_people` · 다시 만날 사람에게 연락하기 | P6 → R9 | 없음 / m4_people | DEAD+AUTO · ORDER-102 |
| M3 회복 | `m3_self` · 영수증과 빨래 정리하기 | P4 → R6 | m3_self / m4_self | — · ORDER-102 |
| M4 직업·앞날 | `m4_advancement` · 이번 달 면접·지원·수업 | P13 → R9 | 없음 / m5_advancement | DEAD · ORDER-102 |
| M4 생계 | `m4_livelihood` · 엿새 심야 물류조 들어가기 | P5 → R4 | m4_livelihood / m5_livelihood | ORPHAN · ORDER-102 |
| M4 사람 | `m4_people` · 다시 찾아갈 사람과 시간 맞추기 | P7 → R14 | 없음 / m5_people | DEAD+AUTO · ORDER-102 |
| M4 회복 | `m4_self` · 몸과 방값 함께 점검하기 | P4 → R4 | m4_self / m5_self | — · ORDER-102 |
| M5 직업·앞날 | `m5_advancement` · 도시시설운영단 지원서 보내기 | P5 → R6 | 없음 / m6_advancement | DEAD+ORPHAN · ORDER-103 |
| M5 생계 | `m5_livelihood` · 나흘 이삿짐 보조조 들어가기 | P5 → R4 | m5_livelihood / m6_livelihood | — · ORDER-103 |
| M5 사람 | `m5_people` · 기다리게 둔 사람에게 연락하기 | P7 → R9 | 없음 / m6_people | DEAD+AUTO+CAP · ORDER-103 |
| M5 회복 | `m5_self` · 아무 약속 없는 일요일 | P4 → R4 | m5_self / m6_self | — · ORDER-103 |
| M6 직업·앞날 | `m6_advancement` · NCS 실전 문제 시간 안에 풀기 | P4 → R4 | 없음 / 없음 | DEAD+ORPHAN · ORDER-103 |
| M6 생계 | `m6_livelihood` · 사흘 심야 상하차조 잡기 | P5 → R4 | m6_livelihood / 없음 | ORPHAN · ORDER-103 |
| M6 사람 | `m6_people` · 이번 달 지켜야 할 약속에 연락하기 | P4 → R54 | 없음 / 없음 | DEAD+AUTO · ORDER-103 |
| M6 회복 | `m6_self` · 하루를 아무에게도 주지 않기 | P5 → R4 | m6_self / 없음 | ORPHAN · ORDER-103 |
| M7 직업·앞날 | `slot:m07:advancement` · missing | P0 → R0 | 미정 / 미정 | ROW · ORDER-104 |
| M7 생계 | `slot:m07:livelihood` · missing | P0 → R0 | 미정 / 미정 | ROW · ORDER-104 |
| M7 사람 | `slot:m07:people` · missing | P0 → R0 | 미정 / 미정 | ROW · ORDER-104 |
| M7 회복 | `slot:m07:self` · missing | P0 → R0 | 미정 / 미정 | ROW · ORDER-104 |
| M8 직업·앞날 | `slot:m08:advancement` · missing | P0 → R0 | 미정 / 미정 | ROW · ORDER-104 |
| M8 생계 | `slot:m08:livelihood` · missing | P0 → R0 | 미정 / 미정 | ROW · ORDER-104 |
| M8 사람 | `slot:m08:people` · missing | P0 → R0 | 미정 / 미정 | ROW · ORDER-104 |
| M8 회복 | `slot:m08:self` · missing | P0 → R0 | 미정 / 미정 | ROW · ORDER-104 |
| M9 직업·앞날 | `slot:m09:advancement` · missing | P0 → R0 | 미정 / 미정 | ROW · ORDER-105 |
| M9 생계 | `slot:m09:livelihood` · missing | P0 → R0 | 미정 / 미정 | ROW · ORDER-105 |
| M9 사람 | `slot:m09:people` · missing | P0 → R0 | 미정 / 미정 | ROW · ORDER-105 |
| M9 회복 | `slot:m09:self` · missing | P0 → R0 | 미정 / 미정 | ROW · ORDER-105 |
| M10 직업·앞날 | `slot:m10:advancement` · missing | P0 → R0 | 미정 / 미정 | ROW · ORDER-105 |
| M10 생계 | `slot:m10:livelihood` · missing | P0 → R0 | 미정 / 미정 | ROW · ORDER-105 |
| M10 사람 | `slot:m10:people` · missing | P0 → R0 | 미정 / 미정 | ROW · ORDER-105 |
| M10 회복 | `slot:m10:self` · missing | P0 → R0 | 미정 / 미정 | ROW · ORDER-105 |
| M11 직업·앞날 | `slot:m11:advancement` · missing | P0 → R0 | 미정 / 미정 | ROW · ORDER-106 |
| M11 생계 | `slot:m11:livelihood` · missing | P0 → R0 | 미정 / 미정 | ROW · ORDER-106 |
| M11 사람 | `slot:m11:people` · missing | P0 → R0 | 미정 / 미정 | ROW · ORDER-106 |
| M11 회복 | `slot:m11:self` · missing | P0 → R0 | 미정 / 미정 | ROW · ORDER-106 |
| M12 직업·앞날 | `slot:m12:advancement` · missing | P0 → R0 | 미정 / 미정 | ROW · ORDER-106 |
| M12 생계 | `slot:m12:livelihood` · missing | P0 → R0 | 미정 / 미정 | ROW · ORDER-106 |
| M12 사람 | `slot:m12:people` · missing | P0 → R0 | 미정 / 미정 | ROW · ORDER-106 |
| M12 회복 | `slot:m12:self` · missing | P0 → R0 | 미정 / 미정 | ROW · ORDER-106 |

행 밖의 현재 부채는 `DISPLAY_ONLY_FORGONE`, `LAYER_COLLISION`,
`UNSCHEDULED_CHAIN`, W24 `MILESTONE_FANIN`, W24 application identity
`SHADOWED_READER` 각 1개다. 행 부채 31 + missing ROW 24 + 전역 5 = exact 60이다.

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
