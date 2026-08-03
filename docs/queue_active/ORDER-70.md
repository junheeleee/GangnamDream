# Active Queue Spec: ORDER-70

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [ ] ORDER-70 [P0·빌드] 외부 테스터가 실제 V2 release 빌드를 바로 연다

**사용자 승인 (2026-08-03):** `PROPOSALS.md` P-2 권고대로 진행한다.

## 깊이 3문

1. 지우면 `playtest` release 빌드는 V2 버튼이 없어 기존 5년판을 시험한다.
2. 플레이테스트 빌드의 선택은 별도 세이브에 남고 retail 세이브에는 닿지 않는다.
3. `debug`, `core_loop_v2_playtest`, retail 기본값이 서로 다른 배포 목적을 경쟁한다.

## 배치 A — 전용 flavor

- `core_loop_v2_playtest` feature에서만 V2 진입 버튼과 항상 보이는 테스트 표식을
  연다. retail의 `runtime_default=false`는 유지한다.
- 테스트 세이브를 retail/기존판과 분리하고 창 제목·시작 화면에 flavor를 표시한다.

## 배치 B — 배포 경계 회귀

- export preset·`build.sh playtest`·진입/세이브 회귀를 같은 계약으로 묶는다.
- 터미널 인자 없이 release 산출물을 실행해 V2 24주 진입이 보이는지 확인한다.

## 완료 증거

- release playtest V2 진입: `1`, retail 기본 V2 진입: `0`
- playtest/retail 세이브 경로 충돌: `0`
- 빌드 flavor 미표시 경로: `0`
