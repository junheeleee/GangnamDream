# Active Queue Spec: ORDER-700

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

## [~] 2026-10-16 착수 — 승인 R1 문안의 기존 정점 검사 정합

부모 [699](ORDER-699.md)의 사용자 승인 교체 문안은 `peak_scene_chain_audit.py`가
필수로 요구하던 `실제로`, `증명이 아니었다`, `관계가 회복되지 않았다`,
`계약서가 아니다` 등 검수 낭독과 두 선택지 exact 문구를 바꾼다.
기존 positive 문구 조건과 mutation의 교체 출발 문자열만 새 행동·장면 문안으로
정렬한다. C3의 승인된 제품 변경에 따른 검사 정합이며 새 도구가 아니다.

### 깊이 3문

1. 안 하면: 승인 문안이 옛 문구를 쓰지 않는다는 이유로 PEAK CI 실패.
2. 플레이어 상태: 변화0. 효과·flags·조건·순서·chain 계약은 불변.
3. 경쟁: 검수 낭독을 되살리는 대신 실제 행동과 동일한 비실행·미회복 경계를
   검사한다. 단어 삭제를 계약 삭제로 바꾸지 않는다.

### 정확한 파일 소유

- 독립 checker 저자: `tools/peak_scene_chain_audit.py`의 finale positive 의미 조건,
  바뀐 choice text 기대값, 기존 mutation의 현행 출발 문자열만.
- root: 이 사양·`docs/CODEX_QUEUE.md`·순번만 `docs/CODEX_QUEUE_L3_PENDING.md`·
  `docs/WORK_LOG.md`·`CLAUDE.md`. private 근거 `.git/order699-text-r1-20261016/`.

허위 성취/매매/이체/답장/용서/회복 금지, gameplay exact·choice 순서·chain·
variant/토큰/parity·장면 기능·mutant 거부 수는 보존한다. 다른 peak와 임계값은
비소유다. 기존 self-test가 no-op mutation으로 바뀌면 그 출발 문자열을 현행
문안으로 옮겨 실제 나쁜 입력을 계속 거부하게 한다. 새 self-test 파일·전체audit·
엔진·240주·CI 예외0. 기존 peak source/self-test와 KO/EN 비저자 검수만.
기존 제품 검사 통과를 화면/사람/출시 GO로 확대하지 않는다.
규범 승격0·모두 이번 승인 문안 정합용 일회성이다.
