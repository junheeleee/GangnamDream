# Active Queue Spec: ORDER-99

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-99 [P0·저장 복구] SAVE-P0 — 첫 달 4주차 진행 불능을 복구한다

**사용자 실물 (2026-08-11):** BUILD `2026.08.11.2`의 정상 첫 플레이에서
1월 4주차 배치를 마치고 도시 시각 4/4, 남은 여력 0/4가 되었지만 서울 보드는
다시 여력을 고르라고 요구했다. 확정 버튼은 비활성이고 정상 입력으로는 월말에
도달할 수 없다. 사용자 autosave에는 W4 배치·수치·세계 사건이 이미 한 번
적용되어 있으므로 새 게임이나 수동 JSON 편집을 요구하지 않고 그대로 복구한다.

## 깊이 3문

1. 지우면 실제 사람이 첫 달을 끝낼 수 없고, 자동 24주 완주가 제품 진행 가능성을
   거짓으로 대표한다.
2. 선택·효과·수치·사건·콘텐츠는 바꾸지 않는다. 이미 적용된 W4 영수증을 다시
   적용하지 않고 완료 상태만 정확히 인식해 월말 정산으로 진행한다.
3. JSON 왕복 뒤 정수 주차 키가 `"4.0"`처럼 남더라도 receipt의 정수 의미를
   단일 형식으로 정규화한다. 손상·충돌 키는 추측해서 합치지 않고 닫힌다.

## 배치 A — 저장 키 정규화·실제 저장 복구 6단위

1. `world_receipts`와 주차/턴 소유 receipt dictionary의 숫자 키를 정수 문자열로
   canonicalize한다.
2. `"4.0"` + `week_index=4.0`인 실제 저장 모양이 `"4"`로 복구되는 회귀.
3. 서로 다른 raw key가 같은 canonical key를 가리키면 normalization 실패.
4. 복구 뒤 W4 `turn_ready=true`, 완료 영수증 exactly once.
5. 월말 정산·2개월차 진입과 저장 재개 exactly once.
6. 사용자 저장 복사본에서 돈·몸·마음·선택 영수증 byte-equivalent 보존.

## 정확한 파일 소유권

**제품·회귀 3:** `systems/DemoCoreLoopV2.gd`,
`tools/CoreLoopV2CycleCheck.gd`, `systems/BuildInfo.gd`.

**선언·증거 7:** `docs/CODEX_QUEUE.md`, 이 사양,
`docs/DEMO_FIXLOG.md`, `docs/QA_CHECKLIST.md`, `CLAUDE.md`,
`docs/WORK_LOG.md`, 컨텍스트 예산 보관본
`docs/history/WORK_LOG_2026-08-03.md`; 생성 문서 `docs/STATUS.md`와 새 후보 등록 시
`docs/human_gates.json`을 마지막에만 갱신한다.

프롤로그 순서, `여력` 용어, 자기소개서 효력, 휴대폰 도달성, 생활 빌드·테크트리는
이번 P0와 섞지 않는다. 사용자의 첫 플레이 원문을 보존하고 P0 후보가 실제 저장을
복구한 뒤 별도 첫 달 개선 사양으로 판정한다.

## 완료 증거

- 사용자 autosave 복사본으로 `1월 4주차 → 월말 수첩 → 2월 1주차` 실제 진입.
- W4 편의점 효과와 세계 사건·선택 영수증 중복 0.
- save/load 전후 돈 675,000원·몸 56·마음 52 및 W1~W4 배치 보존.
- CycleCheck, 실제 입력 표적 경로, compile, diff-check GREEN.
- 수정 후보를 내기 전 사용자의 원본 autosave를 덮어쓰지 않는다.

## 구현 체크포인트 (2026-08-11)

- 원인은 pending 세계 사건을 JSON으로 다시 읽을 때 `week_index=4.0`이 되어
  resolved receipt가 `"4.0"` 키로 저장되지만, 주차 종료는 canonical `"4"`만
  찾던 불일치였다. 저장·효과·선택은 정상이고 라우터만 Week 4를 닫지 못했다.
- write path는 local week 1~4의 정수 문자열만 만들고, load path는 exact
  `"N.0"` alias가 authored month/week/bundle·turn·claimed/resolved full proof를
  모두 만족할 때만 `"N"`으로 옮긴다. raw canonical/alias 충돌은 값 타입과
  무관하게 fail-closed다.
- Month 2+의 절대 turn과 local week가 달라지는 public resolve idempotency도
  함께 고정했다. 이미 resolved인 receipt는 status만 보지 않고 bundle·turn·
  claimed/resolved·node/week identity가 모두 맞아야 인정한다.
- 실제 사용자 primary와 `.bak`을 임시 격리 폴더에 복사한 뒤 playtest
  `SaveManager.load_game(0)`으로 불러왔다. 실제 MainGame 경로에서
  `W4 close → Month 1 notebook → confirm → turn 5 Month 2 board → autosave →
  reload`가 통과했고, 4 allocations·유혹 choice·W4 followup은 각각 한 번만
  남았다. 원본 primary/bak SHA-256과 mtime은 검사 전후 동일하다.
- 자동 L1/L2는 완료 상태다. BUILD `2026.08.11.3` 후보에서 사용자가 같은
  저장으로 Month 2 보드에 도달하는 L3 확인 전까지 이 오더는 `[~]`로 둔다.

**규범 판정:** exact numeric-key migration과 회귀 fixture는 이 save defect의
일회성 수리다. 일반 규범인 `저장 호환 수리는 원본을 수정하지 않고 격리 copy의
실제 SaveManager→UI→재저장 경로로 증명한다`는 `docs/QA_CHECKLIST.md`의 저장
경계 절로 승격한다.
