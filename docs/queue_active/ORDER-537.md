# ORDER-537 — 저장에 명시된 시작 방식을 구저장 추론이 덮지 않게 한다

#### [~] ORDER-537 [P0·저장 정합] 자유 선택의 cold 재개 보존

**착수 — 2026-10-10 / 구현 전 선언.** 536의 전체 ManualSave 실행에서
`run_theme="자유런" → "투자런"`만 바뀌어 W4 결과 전체 상태 비교가 실패했다.
구저장 범주 역추론은 명시된 시작 방식이 없는 저장에만 적용한다.
536 제품 변경은 미커밋 그대로 보존하며 이 선행 수리와 소유 파일을 분리한다.

## 깊이 3문·소유 (이번 단위의 일회성 지시)

- 없으면 실제 새 이야기의 시작 방식과 사건 범주가 cold 저장 후 달라진다.
- 선택 경로/인물/능력치/범주를 새로 만들지 않고 저장된 플레이어 시작 조건을 지킨다.
- 구버전 `run_theme` 누락 저장의 기존 추론은 유지하며 명시값 복원과 경쟁시키지 않는다.
- phone_cn_author: autoloads/GameState.gd의 구저장 run_theme 추론 guard만.
- cjk_wrap_diagnosis: tools/ManualSaveCheck.gd에 명시 자유/투자 및 누락 구저장 회귀만.
  536의 같은 fixture 소유자이며 그 변경을 되돌리거나 기대값을 완화하지 않는다.
- root: 큐·이 사양·WORK_LOG·CLAUDE 현재행·독립 보고/판정.
- phone_independent_review: 비저자 diff/raw·보호 파일 검수. 제품 편집/engine0.
- 원문/번역/저장 스키마·파일/사용자·공개 저장/project/인간 판정/수치 변경0.

## 검증·완료

- 명시 자유 선택+역추론 가능한 investment/finance 범주, 명시 투자, 필드 누락
  구저장의 재개를 기존 ManualSave로 확인한다. 실제 정상 선택 수치/로그는 보존한다.
- 기존 격리 bootstrap의 compile/전체 Manual 및 536 W4 cold 결과 재검증,
  선택 영향 정적/EN·한글·context/queue/diff, 독립 source/raw 한정 판정.
- 새 runner/전체 감사/240주/누수·비용 최적화0. 합성 저장 회귀는 실제 M07이나
  인간·원어민·물리 패드 관찰이 아니며 본편/출시·기본 활성화 HOLD를 유지한다.
- 새 정본 규칙0. 구현·표적 검증한 결과만 main에 정리하고 536을 재개한다.

## 구현·표적 결과 — 독립 최종 결속 대기

- 기존 추론에 `not data.has("run_theme")` guard만 추가했다. 명시 자유+투자범주,
  명시 투자+인맥범주, 누락 구저장+투자범주 3경계의 실제 v4 두 번 재개 PASS.
  전체 수치/로그/범주 JSON exact, 새 schema/추론 범주/사용자 저장 변경0이다.
- compile6 69, whole preview3/legacy2 exit0 및 RUN_THEME cases3 marker 확인.
  마지막 내부ID 오탐은 조건 순서만 동치 정렬했고 EN/한글0을 확인했다.
  검사/면제 확대0, 최초 자유→투자 실패 원형은 private raw에 보존한다.
- 새 정본 규칙·승격0/작업 지시는 일회성. 536과 같은 후보의 저장 정합 한정이며
  실제 M07·기본 활성화·전체 CI/본편/출시·인간 관찰 GO가 아니다.
