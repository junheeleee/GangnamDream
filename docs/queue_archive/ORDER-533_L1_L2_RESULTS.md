# ORDER-533 독립 검수 — 현황판 신선도 참고 경고

- 검수자: `/root/phone_independent_review` (구현·fixture 비저자).
- 판정: **source 작업 단위 GO**. 게임·전체 제품·CI 완료·외부 출시 GO가 아니다.
- 실제 검수 source: `21a0167f36c7601613b8d986b86813351ab69ff6` /
  tree `37778b85633ffef96185d9be76a214d4a9a7a857`.
- 비교 기준: 선언 `3e75859`. 보고서 쓰기 직전 위 HEAD/tree·clean 상태를 직접 확인했다.

## 모집단·직접 읽은 범위

기준→source의 변경 8파일 전수: `tools/project_dashboard.py`, `tools/audit.sh`,
`tools/audit_scope.json`, `tools/agent_review_decisions_self_test.py`,
`.codex/skills/gangnamdream-dev/SKILL.md`, `docs/CODEX_QUEUE.md`,
`docs/KNOWN_FAILURES.md`, `docs/queue_active/ORDER-533.md`.
사양·개발스킬·WORK_UNIT의 권한/증거 분리와 최신 직접지시 반영절을 함께 읽었다.
새 도구·검사 파일·엔진·앱·GUI·게임 저장 조작은 없었다. 본 보고서만 작성한다.

## 코드·실패 경계

- `--md PATH --check --advisory`의 문서 불일치/누락 분기만 경고와 exit0이다.
  strict 불일치/누락은1, fresh는0, advisory 필수인자 누락은 argparse exit2다.
  일반 생성/HTML 경로는 그대로이며 markdown·대상 읽기 예외를 성공으로 삼키는
  새 catch가 없다. 기존 생성기 내부 데이터 폴백은 변경하지 않았다.
- 직접 메모리 표적 12경계: fresh strict/advisory 2건, stale 2건, missing 2건,
  advisory 오용3건, 생성 RuntimeError/읽기 PermissionError/UTF-8 decode 예외3건.
  각각 0/0, 1/0, 1/0, 2/2/2, 예외 그대로 전파를 확인했다.
  write_text/mkdir를 금지 mock으로 묶었고 파일 쓰기 없이 끝났다.
- audit.sh의 STATUS 설명/호출 2줄을 역복원한 전체 bytes가 기준과 같다.
  STATUS_DOC_EXIT 수집·전체 제품검사·실패/미실행 집계·KNOWN gate·최종 exit는
  동일하다. scope JSON 전수차는 advisory 명령4곳과 이유1곳뿐이다.
- 기존 KNOWN gate의 evaluate AST만 메모리에서 재사용했다. 현재 목록은 known0 /
  problems0이다. EN_HANGUL_EXIT, STATUS_DOC_EXIT 및 둘의 실패를 각각 넣으면
  CI 예외 허용 모드에서도 모두 blocked로 남고 미실행도 문제로 남는다.
  ObjectDB의 서술 bullet은 CI 예외표 행이 아니며 검사 면제는0건이다.

## fixture 전후·실행 증거 구분

- 기존 fixture의 helper 변경과 삽입 블록만 역복원하면 기준 파일 전체 bytes와 같다.
  기존 222표본을 제거/약화하지 않고 work_unit/internal_product 두 모드에 각34,
  총68표본을 추가했다. stale/missing의 strict·advisory, marker/무쓰기,
  생성·읽기 예외, 오용/생성 미호출을 확인한다. 실제 Git의 권한·identity·혼합 dirty
  경계, 기존 HUMAN_SHA/PRESERVED_ASTS 계약은 보존했다.
- root가 fixture 고정 후 실행한 기존 전량 검사의 도구 세션27889 결과:
  `python3 tools/agent_review_decisions_self_test.py`, exit0,
  `AGENT_REVIEW_DECISIONS_SELF_TEST_OK cases=290 product_verdict=HOLD human_evidence_unchanged=true`.
  이는 **root 관측 원출력**이며 별도 durable raw 파일은 없다. 독립자가 원로그를
  읽거나 전량을 재실행한 것으로 쓰지 않는다. fixture 실물 SHA는
  `a9b623909b4ca44d83e80e36c16a01f4029c8453fce3f32a21b27c70221906b4`이다.
- root의 기존 표적 결과: queue_index25/fence4, context30400/docs642/links197,
  bash 문법·등록 verify179 PASS 및 실제 advisory fresh0. 이 결과를 독립 실행으로
  올리지 않는다. 마감 후 실제 STATUS stale0 확인은 root의 별도 마감 증거이며
  이 보고 시점에는 아직 미관측이다. 전체 감사/불변 제품검사/240주/엔진은 반복0이다.

## 보존·정본·잔여

- 기존 agent 판정 271개 원장 전체 bytes가 기준과 같다. 인간 원장 SHA
  `6ab5c927c9f327aa2892c231d49fe144c1c154cb6069fc539f4f3f8e9c30c9f6`,
  human_gates.py·CI workflow·project.godot도 기준 bytes와 같다.
  diff 모집단 밖 게임원문/번역/저장·source identity 규칙 변경0이다.
- 개발스킬 Verify절은 STATUS 전용 추종커밋 의무를 없애고 strict 명시 확인과
  생성오류 차단을 유지한다. 큐의 월별 실제 앱 검수 예외는 범위 선기록·한 달 한
  커밋·구현 결함 별도 범위를 명시한다. 후속 M07 실행을 관측/승인한 것은 아니다.
- ObjectDB는 529 정상 종료 뒤 경고1건/객체·원인 미동정이라는 기록 그대로다.
  플레이 영향 미관측은 모든 경로 무영향/수리 완료가 아니다. 최신 지시대로
  비차단 문제 기록·추가 추적 중단/실제 영향 시 재개만 선언하며 과거529 REWORK /
  530 HOLD와 원로그는 바꾸지 않는다. CI whitelist로 확대하지 않았다.
- 자동 계약은 재미·깊이·문체의 증명이 아니다. 실제 원어민·인간 플레이·물리 패드·
  연속 청취·독립 pixels·본편/출시 품질은 미관측/HOLD다. 본 source GO는 현황판
  신선도 경계 수리와 명시된 문서 정렬에만 적용한다.
