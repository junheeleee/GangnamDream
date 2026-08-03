# Active Queue Spec: ORDER-69

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-69 [P0·밸런스] 24주 합법 경로가 정점 전에 무너지지 않게 한다

**착수 파일:** `content/meta/demo_core_loop_v2.json`,
`tools/demo_core_loop_v2_audit.py`, `tools/core_loop_v2_balance_sim.py`,
`tools/CoreLoopV2ECheck.gd`, `tools/CoreLoopV2HandoffCheck.gd`,
`scenes/MainGame.gd`, `docs/BALANCE.md`, `docs/CORE_LOOP_V2.md`,
`docs/QA_CHECKLIST.md`와 큐/증거 문서.

**사용자 승인 (2026-08-03):** `PROPOSALS.md` P-1 권고대로 진행한다.

## 깊이 3문

1. 지우면 무직 생계+성장 합법 경로가 필수 clean 사건 포함 12주 말에
   `mental_break`로 종료된다(사건을 뺀 종전 계산은 약 16주).
2. 고른 루틴에 따라 24주 정신력·현금·건강이 다르며 회복의 가치는 남는다.
3. 생계·성장·회복 세 자리가 같은 월간 시간 슬롯을 경쟁한다.

## 배치 A — 원장과 실제 압박 정렬

- V2의 `livelihood.unemployed`, `livelihood.employed`, `growth` 정신 효과만
  `-1 → +1`로 바꾸고 `recovery +3`과 5년 공통 월말 압박은 보존한다.
- 설명·정적 시뮬레이터·런타임이 `50만원/건강65/정신60`, 실제 계획·필수 사건·
  거절 결과·여섯 번의 월말 압박을 같은 순서로 읽게 한다.
- 월말 압박의 game-over 검사 뒤 포기비용이 0 이하로 내려가도 recap이 열리는
  순서 결함을 고쳐, 포기비용 직후 다시 `check_game_over()`하고 종료한다.

## 배치 B — 거짓 안전 제거

- Python은 3루틴 조합 × clean/return/deeper × 보수적/강경 선택의 18 kernel을,
  Godot은 최소 clean 미취업, clean 취업+회복, return+회복, deeper 결과 확인의
  네 경로를 1주부터 실제 실행한다.
- 21주에 90을 대입하거나 receipt/snapshot만 조립하지 않는다. 24주 clean 저점,
  return 저점, 회복 고점 저장을 그대로 25~48주에 이어 Week 48 결산까지 검사하고
  V2 효과가 24주 뒤 추가되지 않음을 잠근다.

## 완료 증거

- 필수 사건·foreground·포기비용까지 포함한 1~24주 full-route 경로별 범위 기록
- 루틴·필수 사건만 따른 clean/취업/회복 개입 return/deeper 경로의 24주 이전
  `mental_break`: `0`; 의도된 위험 사망은 원인 선택 ID가 로그에 남음
- 변경 뒤 branch-only 참고 범위: 생계+성장 clean `정신29~37/건강24~31`,
  return `1~10/20~27`, deeper `23~33/24~31`; 실제 full-route가 이를 대체함
- **[첫 실행 재조정]** 회복을 쓴 return 지원 경로의 임시 24주 하한은 정신 10,
  건강 15다. 첫 실제 네 경로 snapshot으로 방어/수정하고 근거를 남긴다.
- clean 저점·return 저점·회복 고점이 값 재설정 없이 Week 48 결산 도달
- 5년 공통 압박·`finish_run`·회복 수치 변경: `0`
