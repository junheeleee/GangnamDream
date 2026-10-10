# ORDER-541 — 새 본편의 정상 이야기 흐름 연결

#### [~] ORDER-541 [P0·본편 연결] 정상 새 이야기 → 자동 시간·직접 활동·저장 재개

**착수 — 2026-10-10 / 구현 전 선언.** 부모534의 정상 입구 REWORK를 수리한다.
DECISIONS 2026-08-24·08-31의 실제 장면 행동/자동 생활 및 WORK_UNIT의 위임을
근거로 한다. 개발용 주차를 더 늘리지 않고 새 full의 정상 입구를 연결한다.

## 깊이 3문

1. 없으면 새 본편은 첫 이야기 뒤 반려된 반복 행동판으로 떨어져 M07 자연 검수가 불가능하다.
2. 실제 장면의 선택·후속·직업·관계·월말 효과를 그대로 유지한다. 선택하지 않은
   행동/급여/관계를 진행용으로 만들지 않는다. 기존 저장을 새 흐름으로 추정 승격하지 않는다.
3. 기존 한 주 한 독립 root와 직접 후속이 그 주의 시간을 소유한다. 직접 경마도
   같은 주의 행동이며 AP 카드·생계 선택을 한 번 더 요구하지 않는다.

## 정확한 파일 소유

- root: scenes/StartMenu.gd 정상 fresh 초기화, scenes/MainGame.gd의 full 소유
  handoff/경마 복귀·저장 재시도/기존 Chapter5 완료와의 달력 단일 소유;
  scenes/StoryMode.gd는 실제 동적 선택/같은 주 typed 후속의 기존 helper 전달만;
  tools/arc_flow_sim.py 기존 모델 binding 및 tools/audit_scope.json 기존 등록 정합만.
- phone_cn_author: systems/FullStoryFlow.gd만. 새 정상 full profile·실제 달력·동적
  연말 선택 검증·직접 활동 영수증. 기존8/12주 초기화/격리/저장 비승격은 유지한다.
- cjk_wrap_diagnosis: tools/ManualSaveCheck.gd만. 정상 fresh actual-call·직접 활동·
  저장/cold/실패·달력/기존 종결 경계 표본. 기존 preview8/12 fixture는 보존한다.
- phone_independent_review: source/raw 독립 검수·보호 baseline/fresh·한정 최종 보고.
- root metadata: 이 사양·큐/L3 순번·WORK_LOG·CLAUDE 현재행·독립 보고/판정원장,
  private 원시 검증 기록. 월별 실제 앱 기록은 부모534가 별도 한 commit으로 소유한다.
- GameState/SaveManager/JobSystem/Racetrack 원정산·finish_run/엔딩 선택·원문/번역·
  밸런스·project.godot·공개 데모 pin/저장·사용자 저장·인간 원장은 비소유다.

## 일회성 계약

- 정상 무인자 full 새 이야기의 pristine 초기화에만 정상 profile을 발급한다.
  기존8/12 명시 preview·demo/V2·무표식 구저장·손상 marker의 의미를 보존한다.
  저장 v4/기존 marker key를 유지하고 정상 달력은 GameState의 240주·연도/나이를 읽는다.
- root/결과 마지막 페이지/장 카드/실제 직접 후속이 모두 닫히기 전에는 시간0.
  새 full은 demo narrative bridge로 선택을 무언 적용하지 않는다. 원래 편성·현수
  시험 결과 flag 분기·채용/첫월급·효과·기한은 이번 입구 수리로 다시 쓰지 않는다.
- 직접 경마는 실제 authored 선택이 만든 pending을 내구 저장하고 AP 없이 입장한다.
  한 판 완료 또는 무베팅 닫힘은 원 Racetrack 현금 producer를 그대로 읽어 같은 주로
  복귀한다. net 재지급/AP 재소비0. 중복 closed·cold 재개는 같은 효과를 재실행하지 않는다.
  overlay 중 저장 차단/경주 중간 비복원은 기존대로이며 마지막 성공 checkpoint가 소유한다.
- 자동 생계/회복·기존 월초/월말/급여·달력은 once다. 쓰기 실패의 계산된 live 상태를
  동결하고 재시도는 쓰기만 한다. cold는 마지막 성공 disk를 읽는다.
- 동적 연말 선택은 StoryMode와 같은 기존 후보 consumer로 읽고 index1+ 실제 결과도
  정확히 검증한다. 기존 typed W240은 원래 ending latch/축정산/달력 비진행을 유지하고,
  일반 W240은 원래 월말/나이 rollover를 유지한다. 엔딩 종류·우선순위 변경0.
- 실제 저장의 event_log 최근100개 제한은 유지한다. 현재/열린 결과는 실제 로그를
  요구하고, 잘린 완료 과거 결과만 최소 applied tuple·절대 순번으로 검증한다.
  종결 cold는 실제 game_over가 내보낸 같은 ending ID의 기존 화면만 복원하며
  finish_run/record_run/엔딩 재선택0. 종결 저장 실패도 계산 없이 쓰기만 재시도한다.
  full 종결 화면의 재개·갱신은 자산 milestone producer를 다시 호출하지 않는다.
  살아 있는 full 주차·기존 preview/데모의 milestone 동작은 보존한다.
  기존 helper 소유 marker가 있는 빈 표시 로그도 새 게임으로 추정 초기화하지 않는다.
  손상 marker의 fail-closed 소유를 보존하며 profile을 새로 추정/발급하지 않는다.
  종결 빈 로그 cold 표본을 기존 strict 상태/같은 엔딩/meta 비교에 포함한다.
- 기존 causal W210·typed W240의 원 ledger가 여는 같은 주 후속을 기존 StoryMode
  큐에 넣을 때 full helper에도 exact source/choice/next를 전달한다. 원 선택·효과·
  라우팅·엔딩 latch는 그대로다. 두 실제 reader의 연속 결과를 표적 검증한다.

## 검증·판정

- compile·기존 whole/8/12·demo/V2/구저장 제외·정상 StartMenu actual-call→주간
  reader→M06/M07 경계/저장 cold·W16/540 reader·경마 실제 선택/입장/한 판/무베팅/
  pending cold/완료 cold/중복 close·실패 저장/RNG·W48→49 날짜/동적 선택·W240
  typed/generic 원종결 표본을 기존 격리 bootstrap으로 검증한다. 주차/상태 준비는
  합성 actual-method 계약 증거이며 자연 앱·M07 관찰로 올리지 않는다.
- 공통 시간 handoff 변경의 영향 검사 목록을 읽고 관련 arc/EN/한글/번역원장/서사/
  음악/데모/저장/컴파일·context/queue/diff를 검증한다. 기존 전체 감사의 알려진 실패와
  미실행 검사는 별도 표기하고 전체 CI 녹색으로 바꾸지 않는다. 검사 삭제/면제 확대0.
- 모든 엔진은 fresh HOME/XDG·pre-autoload namespace/exact marker/3stream scan을
  요구한다. 보호 baseline을 실행 전에 봉인한다. 종료 누수 추적·비용/검수 도구 최적화0.
- 새 실패0·비저자 한정 판정 전 완료0. 정상 입구의 실제 재시도는 clean 후보 뒤 부모534로
  옮긴다. 240주 자연완독·M07 실제 월검수·원어민/인간/패드/청취·출시는 계속 HOLD다.
  자동 계약 통과는 재미·깊이·문체 GO가 아니다. 새 설계 정본 규칙0/실행 지시 일회성.

## 2026-10-10 표적 검증 결과 — clean 비저자 결속 전

- production-settled-final actualexit0/195.919956초·전체 marker1회. 의도한 부정
  fixture10 ERROR(활동4/손상 owner2/ending4)만 있으며 broad wrapper FAIL과
  앞선 production5회 실패를 원형 보존한다. assertion/예정 밖 오류/종료 누수0.
- actual StartMenu→Main/Story W1–28 두 회, cold W21/25/29, 원 경마 선택/취소/
  정보료/한 판·저장 실패 쓰기 재시도, 105+1 실제 선택/cap100 두 회·변조 거부,
  동적 연말 index2/W49, 준비 W210 두 실제 root·typed/generic W240/cold/meta PASS.
- compile69·기존8/12 whole·demo/V2/preview 제외·font/i18n 및 최종 arc/서사/EN/
  한글/음악/말투6 PASS. 정적58 actual57성공/기존5장 census1실패, V2 데이터 ID의
  wrapper 오탐1은 분리한다. causal self-test timeout·balance/일부 데모 엔진 미실행을
  완료로 올리지 않는다. 원 검사/필터/면제 변경0, 전체 CI 녹색 주장0.
- 자연 M07/자연240주/원어민/인간/물리패드·본편출시는 HOLD. source 범위의
  clean main/원격·비저자 fresh/보호 원문을 결속한 뒤만 한정 GO로 마감한다.
