# ORDER-453 — 번역 수용기록 검사의 반복 비용을 실제로 측정한다

#### [~] ORDER-453 [P1·검수 효율] 검사를 줄이지 않고 비용을 분해한다

**[~] 착수 — 2026-10-05.** 452의 실제 화면16.312초·focused10.847초에 비해
정상 수용기록 검사는723.222초였다. 고정 교정 원장의 반복 파싱과 반복 source proof는
코드에서 확인됐지만 실행시간 기여율은 아직 모른다. 최적화 전에 측정1배치를 선언한다.

## 범위·소유

- root: CLAUDE·큐/L3·이 사양/보관·WORK_LOG·생성STATUS·새보고/판정 및 private453
  실행/증거. 실제 프로파일·새검사는 root만 실행한다.
  부팅 크기 제한을 위해 기존WORK_LOG 원문을
  `docs/history/WORK_LOG_2026-10-05_pre_order453.md`에 그대로 보관한다.
- claude_handoff_review: 새 `tools/ui_receipt_cost_profile.py`만 저작한다.
- receipt_tests392: 새 `tools/ui_receipt_cost_profile_check.py`와 `tools/audit_scope.json`.
- independent392: 소스/분류·반환/예외/복구 경계·실측 원문 독립 검수. 파일 소유를 나눈다.
- 기존365/append/history/parser·게임·본문·번역·원장·인간판정·공개package 수정0이다.
  성능 최적화와 캐시 도입은 이 오더에서 하지 않는다.

## 측정 계약

- 별도 CLI에서 실제365 기본 main을 정확1회 실행한다. 임시 argv에는 `--self-test`를
  넣지 않는다. 원래 Git/objects/snapshot/proof/manifest/collector/finalHEAD 경로는 유지한다.
- append의 `_Document` 별칭과 다섯 교정 비교 진입점, 최종 current_proof/validate_history,
  collector의 호출만 임시 delegate로 감싼다. 원 callable을 한 번 호출하고 반환 객체
  identity와 원 예외를 그대로 보존하며 모든 별칭·argv를 finally에서 원복한다.
- `_Document` 생성 직전/직후 시계와 raw 길이만 계수한다. 매 호출 원문SHA·전체
  inspect stack 수집은 하지 않는다. caller 파일/행과 교정별 호출 순번으로 before/
  after/dynamic을 구별한다. 동일raw 여부로 구별하지 않는다. `<genexpr>`의 세 호출도
  보존하며 봉인한 함수/소스와 site가 다르면 분류 오류로 별도 기록한다.
- coffee/350/351/365의 다른 `_Document` 별칭은 계측 밖이다. 분류 밖 append 호출도
  other로 계수한다. 중첩된 포함시간을 서로 합산하지 않는다. RSS는 플랫폼 단위를
  붙인 프로세스 누적 최고값이며 함수별 메모리나 before/after 차분으로 부르지 않는다.
- 원 검사 결과·예외와 계측/기록 실패를 분리한다. 기록 실패가 원 예외를 가리지 않는다.
  새 evidence 디렉터리는 비어 있는 고유 경로로 만들고 과거 실행을 덮어쓰지 않는다.
  후보HEAD/tree·소스/기존데이터 SHA·실제player34·이전452 증거를 전후 대조한다.

## 표적 검수

- 새 합성 focused에서 반환identity·동일exception·정상/예외 복구·argv·중첩 context·
  generator before/after/dynamic 순번·동일raw의 역할 구분·실패계수·합계를 검사한다.
  합성 표본은 실제 저장소 admission 증거가 아니다. 저자/비저자가 계측 코드를 읽는다.
- 같은 clean 후보에서 실제 계측된365 기본검사1회와 새focused/context/queue/diff/등록
  5검증+차선조회1을 실행한다. 계측된365가 통과했더라도 비계측 정상검사와 동일한
  wall time이나 정밀 A/B라고 부르지 않는다. 원452의723.222초는 이전 관측값으로만 쓴다.
- 엔진/화면/자연 입력/과거suite/whole audit/240주/공식 교환/새package는 NOT_RUN이다.
  재측정이 필요하면 원 실패 증거를 보존하고 원인을 특정한 뒤 새label로 실행한다.

## 깊이·완료 경계

- 이 작업은 번역·제품 수리마다 반복되는 검수 대기 시간을 줄일 근거를 확보한다.
  월간 코어·서사·수치·플레이 동사·게임 규칙을 확장하지 않는다.
- 실제 데이터에 근거한 비용 분해와 다음 안전한 개선 범위를 기록하면 완료다.
  속도 개선 자체를 완료 조건으로 삼거나 계측값에 맞춰 검증을 느슨하게 만들지 않는다.
- 기존213판정191보고·인간OPEN45/DONE1·공개GO1·원449 REWORK·본편/새package HOLD를
  보존한다. 자동 PASS는 계약 증거이지 재미·깊이·문체·원어민·인간·물리패드·출시 GO가
  아니다. 지시는 일회성이고 새 정본 규칙0이다.
