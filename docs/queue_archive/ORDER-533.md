# ORDER-533 — 현황판 신선도만 CI 비차단으로 바꾼다

#### [x] ORDER-533 [P1·검사 오탐 수리] STATUS_DOC 참고 경고화

**착수 — 2026-10-10 / 선언commit·push 뒤 구현.** 최신 사용자 직접지시를 근거로
현황판만의 추종commit을 없앤다. 생성기 자체의 실패와 제품검사는 차단을 유지한다.

## 깊이3문 / 1단위

1. 없애면 무엇이 깨지는가: 생성기 실패 검출은 남긴다. 낡은 표시는 제품 고장이 아니다.
2. 24주 상태: 게임상태 변경0. 선택/저장/번역/판정을 바꾸지 않는다.
3. 경쟁: 수동STATUS전용commit을 요구하는 strict기본을 CI참고경고로 바꾼다.

## 범위·소유

- root: `tools/project_dashboard.py`, `tools/audit.sh`, `tools/audit_scope.json`,
  `.codex/skills/gangnamdream-dev/SKILL.md`、本仕様/queue/CLAUDE/WORK_LOG/
  agent판정원장/독립보고만. 필요하면 생성STATUS는 함께 갱신하되 전용commit은 불필요하다.
- 저작분리: `/root/phone_cn_author`는 기존
  `tools/agent_review_decisions_self_test.py`의 생성STATUS fixtures만 소유한다.
  비저자 `/root/phone_independent_review`는 실제차이와 검사결과를 직접 전수검수한다.
- `.github/workflows/ci.yml`, 게임원문/번역/저장/엔진/`project.godot`,
  `human_gates`/과거판정/기존source identity규칙·KNOWN_FAILURES는 변경0.
  새검사기/runner/검증비용계측/경로별면제를 만들지 않는다.

## 구현·판정 가능한 기대값

- `--md PATH --check --advisory`만 신선도 불일치(누락 포함)를 명시경고/exit0으로 한다.
  일반생성은 그대로, strict `--check`는 불일치exit1로 보존한다.
  `--advisory` 필요인자 부족은exit2. 생성/읽기/계약 예외를 성공으로 바꾸지 않는다.
- audit.sh의 STATUS명령과 audit_scope의4참조를 맞추고 STATUS_DOC_EXIT집계를 남긴다.
  이외 검사명령/집계는 동일. skill의 매commit재생성 의무를 소유절에서 고친다.
- 기존fixture로 fresh0/strict stale1/advisory stale0/누락·무쓰기/오용2/
  생성예외실패를 확인한다. identity/human fixture를 약화하지 않고 기존전량검사를 쓴다.
- `audit_select --verify`, shell문법, 등록4곳 동일명령/제품차이0,
  context/queue/인간원장/diff를 검사한다. 공통게임schema·scheduler·ending·RC를
  바꾸지 않으므로 불변 전체게임감사/240주/engine은 반복하지 않는다.
- clean구현commit에서 독립source판정→원장결속/완료기록→main push.
  STATUS를 재생성하지 않고 advisory통과하는 것도 확인한다.
  CI결과는 실측상태만 보고하고 미완료를green으로 부르지 않는다.

지속규칙 승격은 개발skill의 Verify절. 나머지는 이 단위의 일회성지시다.
자동통과는 재미/깊이/문체 증명이 아니며 제품/출시GO가 아니다.

## 2026-10-10 후속 직접지시 반영

사용자가 현황판 비차단을 재확인하고 종료누수의 비차단 등록/추적중단·M07부터 본편
월별 실제 앱 검수·한 달 한 커밋을 지시했다. 이번 마감에 `docs/KNOWN_FAILURES.md`의
실제 앱 문제 기록과 CODEX_QUEUE의 월별커밋 예외를 함께 넣는다. CI 예외표/게임/과거
판정 수정은 없으며 본편 실행범위는 후속 월별 사양으로 나눈다. 이 선언/작업은 새 지시
이전에 착수한 검사 수리이며 월별 실제 앱 검수 커밋을 분할하는 선례가 아니다.

## 완료 증거 — 2026-10-10

- 구현source21a0167f36c7601613b8d986b86813351ab69ff6/tree
  37778b85633ffef96185d9be76a214d4a9a7a857, 변경8파일 전수 독립검수 GO.
  [비저자 보고](ORDER-533_L1_L2_RESULTS.md) SHA
  9f7dbe23b4abf20279fdb91b61101132a3ccb99f4ff17316eca99c509efa850d.
- 기존 self-test 전량 root실행 exit0/290건(기존222+새68), product_verdict=HOLD/
  human_evidence_unchanged=true. 비저자 직접 메모리12경계와 root전량 실행은 별개다.
  strict stale/missing1·advisory0·fresh0·오용2·생성/읽기 예외실패·검사쓰기0을 확인했다.
- audit shell문법/등록179/queue_index25·fence4/context30400·642문서·197링크 PASS.
  STATUS두줄 역복원 전체audit 동일/scope4명령+why1 이외 동일, 제품검사 집계 유지.
  기존 KNOWN gate AST의 EN_HANGUL_EXIT/STATUS_DOC_EXIT 실패는 모두 차단, CI예외0.
- 게임원문/번역/저장/엔진/project/사람원장·기존271판정 불변. ObjectDB는 실제앱
  비차단 문제로만 기록해 추적중단하며 원인해결/모든경로무영향을 주장하지 않는다.
- 승격: 개발skill Verify절(신선도참고경고·STATUS전용commit불필요), CODEX_QUEUE
  운영프로토콜의 월별실제검수 한달한commit 예외. 나머지 실행지시는 일회성이다.
  본편M07 실제플레이/전체품질·인간/원어민/물리·외부출시 GO는 아니다.
- 마감 뒤 root 실제CLI는 STATUS를 재생성하지 않고 DASHBOARD_STALE 참고경고/
  exit0을 냈다(session6398). 생성STATUS는 구현 전3e75859의 바이트 그대로 보존했다.
  새보고는 기존archive분류에 원문/SHA동일 이동했고 문서예산은 올리지 않았다.
