# ORDER-563 — CI 저장·모드 검사 실행 계약 수리

#### [~] ORDER-563 [P0·CI 회귀] 착수 — 2026-10-11

최신 사용자 지시: MANUAL_SAVE/MOD_LAYER_AUDIT가 녹색이 되기 전 새 월 플레이0.
M07~M10 수정화면은 534 한 묶음으로 모으며 월 작업은 534/562 두 개만 둔다.
기존 544/546/549는 비활성 대기로 이동할 뿐 완료/과거 REWORK 소급 GO가 아니다.

## 깊이 3문

1. 저장/모드 제품 계약의 새 실패가 계속 묻힌다. 실제 CI38119116995
   (main53a33d7, job114409993458)의 두 목록 밖 실패를 먼저 수리한다.
2. runtime 저장·preview fail-closed 보호와 모든 기존 상태/meta/RNG assertions를
   유지한다. 잘못된 검사 환경/예상 부정검사 출력만 바로잡는다.
3. 모드 generator의 실제 ImageRegistry 의존 누락을 기존 영향 목록에 등록한다.
   새 검사/비용 최적화/이력 도구·제품 원문/번역·저장 구조 변경0이다.

## 소유·배치

- manual_save_ci: tools/audit.sh의 ManualSave 실행 블록, tools/ManualSaveCheck.gd의
  의도적 손상 fixture 동기 호출만. 기존 pre-autoload bootstrap/fresh HOME/XDG/
  namespace를 연결하고 오류 출력 복원은 await 이전이다. strict gate는 불변이다.
  156bd9c 원격 후속은 같은 audit.sh의 성공 마커 소비자만 더 수리한다. 큰 원로그에서
  grep 조기종료가 printf SIGPIPE를 만드는 오탐이며 exit/error/strict 기준은 그대로다.
- mod_layer_ci: 기존 generate_mod_manifest.py로 assets/mod_asset_manifest.json와
  docs/MODDING.md 생성 부분만 갱신, tools/audit_scope.json의 mod_layer_audit 실제
  입력/자기 경로만 등록한다. 기존 visual257/audio를 보존하고 누락6만 더한다.
- root: 이 사양·큐2·534의 묶음 범위·562 보류·544/546/549 대기 이동,
  CLAUDE 현재행/WORK_LOG, private 원로그·기존 안전 helper 최소 어댑터와 실행만.
- 저자가 아닌 rework_batch_plan/root가 실제 변경과 raw/보존을 독립 확인한다.
  다른 제품/저장/공개 데모/Human/옛 판정·원자료·project.godot 변경0이다.

## 검증·완료

기존 모드 audit/validator self-test·generator check, 영향 선택 --list/등록 검증,
ManualSave 전체 fixture를 새 격리 입구에서 exact marker/actual0와 stdout·stderr·
Godot log의 예상 밖 오류0으로 확인한다. 선언 전 실패 원자료를 보존한다.
CI에서 실제 main 후보의 두 실패가 사라지고 전체 jobs 녹색인지 직접 확인하기 전
CI 완료/새 월 시작을 주장하지 않는다. pending은 pending으로 보고한다.

실제 앱 M07~M10의 변경 화면 검수는 534가 소유하며 이 검사 PASS가 대신하지 않는다.
ObjectDB 추가 탐침·전체 비용 도구0, 전체 CI는 기존 workflow 그대로이며 KNOWN 목록
확대/제품 검사 삭제0이다. 실행 지시는 일회성, 새 정본 규칙0이다.

## 구현·표적 결과 — 원격 CI 대기

저장 전체 actual0/218.065918s·compile69 actual0·모드 runtime actual0, 각 원 marker1/
3stream 예상 밖 오류0이다. fresh32보호그룹·tracked3353은 각 실행 전후 exact,
의도적 fault/rejection WARNING은 보존했다. private563의 원 helper·admission·3stream·
영수증을 비저자가 직접 읽었다. static 모드/generator263·142/validator/scope도 PASS다.
audit.sh 미등록 별도 general-finale 감사의 shipping1708 고정 vs 현행1702 FAIL1은
HEAD부터 있던 실패로 분리 기록하며 이번 숫자/KNOWN 목록 변경0이다.
제품5파일과 현재행/WORK_LOG를 함께 올린 뒤 실제 main 전체 CI를 확인한다.
pending 중 534 실제화면/562 새 월 실행0, 이 구현·검증 기록은 일회성이다.

## 원격 후속 — 마커 소비자 수리·전체 CI 재확인 대기

156bd9c CI38123501580/job114422927096의 whole 저장 성공 마커2·모드 audit/runtime·
compile69는 실제 출력됐다. 남은 목록 밖 실패1은 audit.sh72의 printf Broken pipe
뒤 MANUAL_SAVE_EXIT다. 원격 원로그를 private563/ci-after-156bd9c.log로 보존한다.
같은 오더에서 마커 입력을 끝까지 소비하도록 고쳤다. 원3stream55,092B의 메모리
2배부터 원소비자141 오탐이 재현됐다. 기존 guard selftest3·저자11case·독립18case와
root 큰 로그 대조 PASS, exit/late ERROR/strict·teardown 판정은 불변이다.
엔진/월 플레이 재실행0,
제품 검사 삭제/KNOWN 추가0이며 새 main 전체 jobs 녹색 전 미완료를 유지한다.
