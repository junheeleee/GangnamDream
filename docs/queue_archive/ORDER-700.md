# Archived Queue Spec: ORDER-700

> **[x] 2026-10-16 완료 — 기존 정점 검사의 승인 문안 정합만.** CI/화면/출시 GO가 아니다.

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

## 완료 증거

- checker 저자 `/root/r1_peak_contract`: 의미 positive 함수와 choice text 기대값 함수만
  변경. 기존 false-fact/shape/parity/chain/effect/flag/mutation·다른44 함수/class는 exact.
  두 함수만 역산하면 원 도구 raw 복원이다. 새 검사·self-test 파일·예외0.
- `peak --strict`31/31/debt0, 기존 self-test21 거부·기대 marker 유지. 비저자
  `/root/m32_path_review`가 같은 기존21 mutant의 실제 변경21/no-op0·기대 거부를 독립 확인했다.
  `GO_EXISTING_PEAK_CHECKER_ALIGNMENT_ONLY`; old 문구 낭독을 제거하되 허위 사실 금지는 보존.
- root가 도구 diff와 보고 전문/5002·0·42·0B raw4개·실행 input11핀을 직접 읽고 대조했다.
  도구157984B/SHA256 `bfdf3f01ed573ddffcb36a6ec4e610cded902df2e51d3651e68ed7acedfaa9e7`.
  private `order699-text-r1-20261016/peak-author/` report3313B/
  `82cc6b1eb16b7da6f2801b3fe5580285584ea10f691710d5fe10ff45d6ba479d`,
  result2668B/`076094735a14d7a97b1ac03cedcf36307c309cce5ebcf3885f0a7d3144dcc921`,
  tested-inputs2853B/`a25b360516de0e0f2af29650f859e77bb88c98b447b0de55824dd74f86b25eb0`.
- 독립 판정/현재 파일핀은 [699 완료 증거](ORDER-699.md#완료-증거--이번-source-범위만)의
  MD/JSON 한 쌍이699·700 scope를 분리해 소유한다. 실행 사양2064B/
  `c3b6efca751a08676b3b959bb273a67f18922c485f6dc80828589d2cf5086958` private 보존.
- 도달 경로: 기존 peak source/self-test. 생산자↔독자: 승인 KO/EN↔의미 assertion.
  바꾸는 상태: 검사 기대 문안2함수/제품0. 포기 비용: 효과·분기·허위 사실 거부 불변.
  서사 위치/계층: M60 기존 정점 계약. 닫는 것: 위 checker 정합 한정.
  새 main 전체 CI·화면/저장·사람/원어민·물리패드·출시 GO가 아니다.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.
