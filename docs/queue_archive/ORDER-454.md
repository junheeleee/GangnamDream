# ORDER-454 — 두 고정 교정 원장의 반복 파싱을 줄인다

#### [x] ORDER-454 [P1·검수 효율] 호출 지역의 불변 원장 토큰 재사용

**[~] 착수 — 2026-10-05.** 453의 실제 main708.010초 중 초기 correction/fee의
고정원장148회가130.446초를 차지했다. UI 고정296회는2.579초뿐이므로 그대로 두고,
검사 의미를 유지하며 고정원장만 재사용하는1배치를 선언한다. 절감 효과는 아직 없다.

## 범위·소유

- claude_handoff_review: `tools/ui_translation_append.py`의 두 초기 비교 함수와
  호출지역 바인딩/투영 helper 및 history 연결만 저작한다.
- receipt_tests392: 새 `tools/ui_fixed_ledger_projection_check.py`, `tools/audit_scope.json`.
- root: CLAUDE·큐/L3·이 사양/보관·WORK_LOG·생성STATUS·새보고/판정·private454
  실행/증거. 프로젝트 import/검사/collector/실제 admission은 root만 실행한다.
- independent392: 소스·동등성·실측·보존을 비저자로 검수한다. 초기 읽기0수정,
  마지막 보고서 `docs/agent_reviews/ORDER-454.json`만 별도 소유한다.
- parser/history/365·453 profiler 핀·게임·본문·사전·번역 원장·인간/공개 자료 변경0.
  UI 파싱·gift/rank/residual/coffee·manifest/Git proof 최적화는 범위 밖이다.

## 구현 계약

- 실제 proof와 계보를 통과한 초기 correction/fee의 정확한 before/after 원장 bytes에서
  필요한 원시 토큰·배치 구분자 포함 절편·ordered receipt/batch만 추출한다.
  투영은 불변이며 종류·경로·정확한 immutable bytes에 결속한다. 전체 Document의
  value/text/spans/keys를 캐시에 보관하지 않고 전역/다음 admission으로 넘기지 않는다.
- 재사용은 단일 validate_history 호출 수명 안으로 한정한다. 기존3인자 비교 API와
  직접 호출 경로는 유지한다. 실패한 결과를 저장하지 않으며 반환 dict는 독립이다.
- dynamic snapshot은 계속 strict Document로 읽는다. 현재 전체 accepted checksum,
  receipt/batch 순서·의미·원문 비교와 해당 snapshot의 span 역상을 유지한다.
  고정 span을 현재 snapshot에 재사용하지 않는다. snapshot==after의 기존 재사용
  분기에서 추가 동적 파싱이 생긴다면 비용/호출 수를 숨기지 않는다.
- correction은 현재 receipt의 target hash만 복원하고 fee는 이전 receipt 전체로
  checksum을 계산하는 차이를 보존한다. 고정 receipt를 가변 객체로 공유하지 않는다.
- 기존 Git/objects/snapshot·교정 proof·각 append·source census/manifest·최종HEAD
  검증과 기존 한칸 결과 memo의 epoch/격리/실패 동작을 보존한다. verdict 캐시0이다.

## 표적 검수

- 새 focused는 봉인한453 이전 함수를 oracle로 삼아 exact-after와 후속 append의
  원문 역상·3/4경로·보호JA·동일값 escape/공백·receipt/batch 순서/누락/수정·checksum
  오류를 비교한다. 두 복원 방식의 차이·종류/path/raw 바인딩·입출력 오염·실패와
  새로운 호출의 fresh proof도 검수한다. 실제 고정 blob 쌍과 합성 결함을 구분한다.
- 반복 fixed ledger Document 생성 수 감소와 남는 projection의 경량 불변성으로
  최적화를 입증한다. 초기 준비 비용·추가 dynamic parse를 포함하며 시간만으로
  성공을 판정하지 않는다. 합성 fixture는 실제 repository admission 증거가 아니다.
- 기존 memo 검사의 파일전체/EOF 봉인은 옛428 시점에 고정돼 현재430~452 추가를
  이미 거부하므로 standalone 전체는 실행하지 않는다. 그 도구의 `synthetic_history`와
  `uncached_factory`를 새 focused에서 호출해 fresh proof/HEAD/trace·epoch 회귀만
  검수한다. 옛 봉인을 완화하거나 과거 전체검사 PASS로 부르지 않는다.
- 같은 clean 후보에서 이 회귀를 포함한 새 focused와 실제365 기본검사1회·
  context/queue/diff/등록·차선조회1을 실행한다. 이전 전체
  receipt를 비교 목적으로 재실행하지 않는다. 단일 실제 wall과453 계측 관측은
  계측/환경 조건이 달라 정밀 A/B나 확정 백분율 향상으로 부르지 않는다.
- 엔진/화면/입력/전체언어/이야기/과거 전체suite/whole audit/240주/공식교환/새package
  NOT_RUN. first 실패를 덮지 않고 원인 수리 뒤 새 label로만 필요한 검사를 재시도한다.

## 깊이·완료 경계

- 반복 검수 대기 비용을 줄여 후속 제품 수리를 빠르게 검증하는 범위이며 플레이
  동사·수치·서사·새 시스템은 확장하지 않는다. 동등성·actual admission·생성 수
  감소와 비저자 한정GO가 완료 조건이다. 측정만으로 마감하지 않는다.
- 기존214판정192보고·인간OPEN45/DONE1·공개GO1·이전 실패/전진수리와 본편/새package
  HOLD를 보존한다. 자동 PASS는 계약 증거이지 재미·문체·원어민·인간·물리패드·출시
  GO가 아니다. 지시는 일회성이며 새 정본 규칙0이다.

## 완료 — 2026-10-05

- 후보 `457c93727eb42a09bb7f480c3410baffe11c9e24`, tree
  `fc184a1feebfeec521c314251465ba81473bd42f`를 main에 커밋·푸시했다.
- 첫 표적검사181건/19.707초·실제365 기본610.898초·context/queue/diff/등록191·조회1
  모두 PASS다. 실제 출력은 기존453과 정확히 같으며 accepted41755/b228/live47,
  historical_cases0이다. 전체631.567초; 실제 원장검사 중복실행0이다.
- 실제 두 고정 blob쌍마다 cold1+warm2의 원장파싱 총5회(고정준비2+동적3)를 확인했다.
  직접 API 한 번의 실측2회로 산술 도출한 기존3회분6과 구분하며, UI12회는 불변이다.
  초기 준비와 exact-after의 추가 동적파싱을 포함한 생성 수 감소다. 이전453의
  계측된709.311초와 이번610.898초는 정밀 A/B나 확정 개선율로 해석하지 않는다.
- `.git/full-game-localization/order454-normal-first/result.json`
  SHA `81072450f46c9caa169a80180171e7e2fce5910733896c1f06d886bb0b502aef`;
  entry SHA `32bccc7dd9582a04a40b6ea2f27e47f72ee523f54128454304fed9f011de21fa`.
  tracked3107/player34/helper1·이전증거216파일 불변, artifact9(결과 포함10파일)이다.
- [비저자 한정GO](../agent_reviews/ORDER-454.json)는 이 동등성·파싱 재사용 작업에만
  적용한다. 기존214판정192보고 뒤215/193이 되며 인간OPEN45/DONE1·공개GO1 및
  본편/새package HOLD는 그대로다. 자동 PASS는 계약 증거이지 작품성·출시 GO가 아니다.
- 정본 승격: 없음. 위 사양·실행 예산·봉인한 비교와 검사 선택은 **일회성**이다.
