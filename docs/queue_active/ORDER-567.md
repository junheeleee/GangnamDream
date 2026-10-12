# ORDER-567 — 경마 지급의 저장 검사 정산 경계 수리

#### [~] ORDER-567 [P0·CI] 착수 — 2026-10-12

main946315c0/tree693db793의 CI38190470970에서 MANUAL_SAVE_EXIT가 실패했다.
이전565 CI38188149161은 같은 경마/검사 코드로 success다. 실패 원로그에는
현금/횟수 숫자가 없어 어느 조건인지 단정하지 않고 실제 표적으로 재현한다.

## 깊이 3문·소유

1. 실제 경마는 GameState.add_money→settle_cash로 1원 정산하지만 기존 검사는
   raw fractional 배당과 exact 비교한다. 적중/낙첨에 따라 CI가 흔들린다.
2. 배당 손실/중복 지급·완료 횟수·cold 저장·같은 주 복귀/시간 once를 계속 지킨다.
   제품 정산 규칙/확률/원 저장은 바꾸지 않으며 검사 삭제/허용 오차 확대0이다.
3. 새 월보다 CI 회복이 먼저다. 열린 M17/562 하나·native0를 유지한다.

- root: `tools/ManualSaveCheck.gd`의 `_check_production_activity`만. 기존 현금
  기대를 정본 최근접 1원 정산에 맞추고 현금/횟수 실패 진단을 분리한다.
  실제 `_place_bet→_process`의 seed 기반 소수 적중/낙첨 두 표본을 확보하며
  실제 countdown property를 쓰는 기존 fixture 준비도 정렬한다.
- root: 큐2/이 활성 사양/마감 WORK_LOG·CLAUDE 현재행만. 원 테스트 성공 marker
  소비자를 확인하고 기존 전체 저장 검사와 production 표적으로 검증한다.
- manual_save_ci: 독립 코드·raw 검수만. 제품/검사 저작은 하지 않는다.
- rework_batch_plan: 새 `.git/order567-qa-20261012/`의 보호 before/final,
  기존564 isolated helper 최소 사본만. 전문 root/비저자 판독 전 실행0이다.
- mod_layer_ci: 같은 새 디렉터리의 실제 CI/계보 읽기전용 진단 기록만.

RaceTrack/HorseWorld/HorseRace/GameState/SaveManager/MainGame·audit/KNOWN/통과
기준·게임 원문/번역/원장·project/presets·공개 데모·사용자 저장/설정·Human·
과거 판정·기존 seed/raw/helper/app은 비소유다. 앞566/565/564 봉인 편집0이다.

## 증거·검증

- `docs/BALANCE.md` 현금1원 정산, GameState.settle_cash/add_money와 실제 경마
  payout producer를 대조한다. 실제 경마 RNG·simulate를 유지하고 착순/배당
  강제 대입0, native 입력/자연 한 판 증거로 확대0이다.
- 선언 commit/push 뒤 fresh 보호·pre-autoload bootstrap·HOME/3XDG/namespace,
  original stdout/stderr/Godot log·actual exit·exact marker·strict 오류 스캔을 쓴다.
  기존 production 표적과 전체 ManualSaveCheck, compile69를 실행한다.
  필요할 때 새 private seed 진단만 허용하고 영구 checker/등록/selftest0이다.
- 기존 영향 목록/등록·EN 한글·context/queue/diff를 표적으로 확인한다.
  전체 audit/240주를 로컬 반복하지 않고 기존 main CI 전체 결과를 직접 확인한다.
- 비저자 source/raw/보존 GO와 새 main CI 녹색 전 미완료다. CI pending은
  pending이며 새 월/앱 실행0, STATUS 단독 후속0이다. 월별 실제 관찰은562에 남는다.

새 규범0·작업 지시는 일회성이다. 자동 계약은 재미·깊이·문체/인간 관찰이
아니며 원어민/패드/청취·전체 번역 INCOMPLETE·본편/출시 HOLD를 보존한다.
