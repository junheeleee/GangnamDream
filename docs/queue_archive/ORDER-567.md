# ORDER-567 — 경마 지급의 저장 검사 정산 경계 수리

#### [x] ORDER-567 [P0·CI] 검사 수리·등록 CI 완료 — 2026-10-12

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

## 2026-10-12 표적 결과 — 새 main CI 대기

- 선언831436a9/treea3a08f21 뒤 검사 한 함수만 28+/9− 수정했다. 제품·정산
  함수·확률·원 저장·기존 cold/once/AP 방어는 보존하며 성공 marker 소비자는
  해당 함수 자신뿐인 것을 확인했다. countdown metadata 오용은 기존 bool
  property로 정렬했다. 허용 오차·통과 기준·KNOWN 변경0이다.
- 고정 child RNG는 `_ready` 뒤/cold `open` 전에만 지정한다. 실제 cold
  checkpoint의 horse_world 부재도 assert하며 지우거나 주입하지 않는다.
  말0/1만원 베팅, 실제 `_place_bet→_process`·착순 producer를 쓴다.

| 준비 W29 표본 | RNG seed | raw 배당 | 1원 정산 | 실제 현금 2,904,933원에서 | 완료 |
|---|---:|---:|---:|---:|---:|
| 적중 | 3 | 48368.08881136045 | 48368 | 2943301 | 1 |
| 낙첨 | 1 | 0 | 0 | 2894933 | 1 |

- 기존 raw 현금식은 이 적중에서 실제 현금과 다르다. 기대식 결함은 표적으로
  재현했지만 566 원CI에는 현금/횟수/승패 숫자가 없어 당시 분기 확정은 아니다.
- `.git/order567-qa-20261012/`의 seed/compile/production/whole JSON에 actual
  argv·HOME/3XDG·pre-autoload 실제 namespace·입출구 hash·원3stream을 결속했다.
  각각 actual0, marker1, strict ERROR0, 보호45그룹/723항목·tracked3357 전후 exact다.
  seed16표본1.711199s·compile69 4.615261s·production203.864642s·whole225.870818s.
  production WARNING14는 의도된 저장 실패 주입이다. 원stderr를 보존하며
  경고0이라고 하지 않는다. whole WARNING27은 기존 저장/호환13과 같은 주입14다.
  전체 검사도 기존 오류 guard 그대로 통과했다.
- 정적 원자료 static-initial/rest JSON: EN 한글·5장 route/selftest·일반 종막
  selftest·feature·등록179·context·queue·diff 9종 PASS, 별도 일반 종막 audit1은
  기존 FAIL이다. shipping 상수1708과 현재 정본1702의 차이며 packaged1813은 같다.
  checker/직접입력은 선언HEAD·앞565/566와 byte-identical이다. selector 등록
  extra지만 현재 audit.sh/CI에서 호출하지 않는다. 삭제/면제/원장 변경0이다.
  initial orchestration은 네 번째 실패에서 중단되어 경과시간 미보존인 것을
  static-initial에 명시했고 원stdout/stderr·actual exits는 그대로 보존했다.
- 읽기전용 CI 진단 `ci-diagnostic.json` SHA5890e412bfdc6a7ba431c190d7c3ccf27ede4009e9c06aefaad00b9cf7355e15,
  별도 extra 진단 `general-finale-static-diagnostic.json`
  SHAb7b1432bf769c4d978acc6db2c4c61910ba0d7d2cd056b0aaf35ad7a60244263.
  검사 상수 수리는 별도 후속 범위이며 아직 새 오더를 열지 않았다.
- manual_save_ci의 원3stream/전체 diff 독립 검수는 source/headless 한정 GO,
  blocker0이다. `source-review.md` 107줄/13187B,
  SHAfb72fbeade4508a868ce5d7045c52caca176fe9a5e0aa60c5cfa06ce358ae7ac.
  root가 전문을 직접 읽었다. fresh 보존 마감은 같은 디렉터리의
  `independent-preservation-final.json`에 별도 결속하며 옛 봉인을 덮지 않는다.
  gangnamdream-dev의 원출력/실제관찰 분리와 위임된 독립 검수를 적용했다.
  이 수리와 결과를 함께 main에 올린다.
  새 main CI 녹색 전 [~] 유지, M17 하나/새 월0·native0·OS 해제 재요청0이다.
  headless 준비 표본은 자연 본편/새 OS 재개/실제 화면/출시 GO가 아니다.

## 2026-10-12 최종 CI 결속·마감

- 구현 ab66435c63adeba6a07dfc772c4c0ae1e9e2ed48/tree24f76847e3e8ea4029653663218d42206c251fb4,
  push run38196803190/attempt1은 04:12:49Z completed/success다. jobs
  114641162740·114641162941와 모든 표시 step success를 비저자가 직접 확인했다.
  ManualSave 기존 최종 marker·compile69·등록 감사 known_failures0·KO/EN 입력·
  SimRun·SmokeRace PASS다. 합본 marker2줄은 두 실행이 아니다.
- 새 ci-final.json SHA966c7809723afe9ad3113542ba077ff3df446b89b212f5709c47e194720ac1b0을
  root가 직접 읽었다. source b9d2dc96…587e8c·독립 검수 fb72fbea…58ae7ac·
  보존45e814f3…565e303과 실제 구현 byte를 결속했다. 옛 pending 봉인 수정0이다.
- 등록 CI 녹색이지 전체 raw strict-clean은 아니다. 별도 종료 resource ERROR3줄
  (2/3/1 resources)과 extra 종막 FAIL1을 보존한다. 종료 잔여 재탐색0이며
  extra의 제품 무관 옛 census 제거는 별도568에서 선언 후 처리한다.
- 이 검사 수리 범위만 완료다. 제품/원장/사용자 저장 불변·M17 OS잠금 HOLD,
  native/새 월0·실제 수정화면/CJK/인간/전체 번역/본편/출시 HOLD다.
  자동 통과는 도달성과 계약 증거이지 재미·깊이·문체/인간 품질 증거가 아니다.
  일회성/새 규범0·승격0이다.
