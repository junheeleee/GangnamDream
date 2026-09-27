# Active Queue Spec: ORDER-358

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [ ] ORDER-358 [P1·검증] 3장 원고 수리의 현재 소스와 역사 비교를 연결한다

2026-09-27 Codex 발행. 350 원고를 고친 뒤 기존 313 exact raw guard가
EN `arc_events`·`arc_midgame`을 실제로 거절했다. 번역 수용 전 실패 원문은
`.git/full-game-localization/order350-static-sourceguard.log`에 보존한다.
수용 뒤 잔여 실패를 별도로 기록하며 최초 실패를 새 통과로 덮지 않는다.

수용 뒤 실제 잔여는3개다(위 EN2 + `content/meta/full_game_localization.json`).
`order350-post-summary.json`의6명령은5 PASS/1 FAIL, receipt 오류0이며 SHA는
`9edf3db751997c6e9be52c47d7f89b40e4e72066cba55c0a4408ef4470aef48b`다.
350 제품 전용 커밋은 `ef896982207de456042e4288cba651553feb38b1`, 직접 부모는
`d8fbf31cf3171bef1824bec87bdb88d026d77abc`다. 21JSON/86leaf + ledger만이며
358 착수 때 이 경계를 다시 Git에서 검증한다. 359는 아직 미실행이다.

## 깊이 3문

1. 왜 필요한가: 수리한 원문을 검증에서 읽을 수 있어야 회귀를 막는다.
2. 무엇을 보존하는가: 현재 원문·번역 수용, 원형 305/310/316/309/313 모듈과
   과거 성공·실패·독립 판정·인간/공개 데모 이력 전체.
3. 무엇과 경쟁하는가: 359의 이미 확인된 4장 결산 회수를 먼저 수리해 같은
   후속 원문 경계를 한 번 검증한다. 351의 새 집필과 출시 판정은 이 범위 밖이다.

## 착수 전 확정할 입력

- 350의 선언 기준 `d8fbf31`과 실제 제품 전용 커밋, 이어질 359 제품 전용 커밋의
  부모·전체 파일집합·exact leaf·원시 SHA·수용 ledger 차이를 Git에서 직접 관측한다.
- 350 예상 모집단은 KO/EN9파일41leaf(기존39/새조건2), JA/CN/TW12파일45leaf
  (기존42/새조건3), ledger 기존42갱신/새3, b139→140다. 실행 전에 실제값을 대조한다.
- 359는 별도 사양의 두 root·조건4 × 5언어 기존20leaf다. 각 작업의 증거와 판정을
  합치지 않는다. 해당 작업이 아직 검증되지 않았으면 후속 guard 구현을 시작하지 않는다.

## 선언 후 소유 가능한 파일

- 새 `tools/order350_source_compat.py`: 현재 admission·Git proof·raw/payload 결속,
  명시 leaf 역변환, 새 ghost 키의 역사 view에서만 제거, ledger 범위 및 음성 회귀.
- 기존 소비자5: `tools/full_body_translation_scope.py`,
  `tools/story_graph_contract_audit.py`, `tools/chapter5_human_reject_audit.py`,
  `tools/year5_reference_route_audit.py`, `tools/chapter1_core_loop_v2_causal_ledger_check.py`.
- `tools/audit_scope.json`·`tools/audit.sh`: 새 명시 전용 표적 차선. 이전 차선·검사를
  면제하거나 의미를 넓히지 않는다. 이전 원형 모듈5개는 수정 금지다.
- 마감: 이 사양/350·359 후속 증거, 두 큐(순번 포함), WORK_LOG, 생성 STATUS,
  CLAUDE 현재 행, 새 판정과 `docs/agent_reviews/ORDER-358.json`, 350·359 후속 보고.
- 실제 착수 시 저자·비저자 파일 소유를 나누고 선언 커밋을 먼저 만든다.
  제품 원고·번역·게임·인간/공개 원장은 이 검증 오더의 비소유다.

## 완료 조건

- current 전체 합집합 admission 뒤에만 정확한 KO/EN 역사 view를 구성한다.
  현재 inventory/보고/receipt를 옛 텍스트로 바꾸지 않는다. rollback·혼합·이웃 문구·
  원시 형식·추가/삭제 키·수용 hash·Git proof 변조는 모두 거부한다.
- 기존 corpus는 원형 유지한다. 옛 CLI의 current gate를 통과한 것으로 가장하지 않고,
  필요한 역사 fixture는 immutable Git 원형과 실제 import/ROOT 신원을 확인한다.
- 필요한 normal/self-test와 새 표적 차선을 실제 실행한다. 긴 검사도 시작 후 표적
  결과를 끝까지 확보하되, 이유 없는 전체 78검사·240주 재실행은 하지 않는다.
- clean source와 실제 실행/화면 증거를 결속한 독립 작업 판정 뒤에만 350·359를 닫는다.
  전체 본편/package HOLD와 원어민·인간·물리 관찰 OPEN은 유지한다.
- 일회성 작업 지시이며 상시 규칙은 기존 WORK_UNIT·I18N 정본을 적용한다.
