# ORDER-479 — 시장 번역 역사 검증의 반복 계산 비용

#### [x] ORDER-479 [위임 QA 수리] 원장 의미 검증의 중복 계산만 줄인다 — 2026-10-07

478 한정 GO와 main push `06af8f5` 뒤 착수한다. 사용자 요청한 효율적 검수의
작은 한 단위다. 선언 commit/push 전 제품 편집·프로파일·QA 실행0이다.
별도 20억 돌파 기록의 고정 잔여금 결함은 이 단위에 붙이지 않는다.

## 한 판정 단위 / 깊이3문

- 지우면: 동일 11.3MB 원장 의미와 JSON 위치를 fresh 입장·종료·중첩 소비자에서
  다시 계산한다. 비용은 현재 코드상 후보이며 이 오더의 원본 실측으로 확정한다.
- 뒤의 독자: market_cycle_label_history._read_proof → fresh_validation_proof →
  JA/469/470/PR31 역사 비교 소비자. 플레이어 경제·24주 상태 차이를 만들지 않는 QA
  계산 단위며 게임 선택·새 장면이 아니다.
- 경쟁: current typed Git/raw/disk/HEAD·직접 부모·전역 경로·config·함수·정상/예외
  종료 검사를 줄이는 것은 금지한다. 반복 순수 의미 계산과 기존 안전 경계가 경쟁한다.

## 정확 소유

- order469_history 작성2: `tools/market_cycle_label_history.py`와
  `tools/market_cycle_label_history_self_test.py`. 선언 뒤 root의 원본 baseline 측정,
  병목·안전 설계 확정 메시지를 받은 뒤에만 구현한다.
- root: CLAUDE.md 현재 상태행, private `.git/` 원본 cProfile/표적 실행 wrapper와 원로그·입력 지문·실패 기록,
  큐·L3 순번·이 사양/완료 archive·WORK_LOG·생성 STATUS·agent_review_decisions.
- order469_review: 읽기 전용 설계·변조 경계 검토. 파일 편집/QA/엔진0.
- 비저자 order469_main: 최종 source commit/tree·원문2·원본 before/after 비용·표적
  전수·변조 반례·입력 보존을 직접 읽고 `docs/agent_reviews/ORDER-479.json`만 작성.
  저작/프로젝트 QA/import/engine/commit0. 저자의 자가 GO로 완료하지 않는다.

## baseline 뒤 선택하는 최소 수리

원본 `with fresh_validation_proof(ROOT): pass` 한 실제 정상 호출을 cProfile로 잰다.
_read_proof/_snapshot/_objects/_git/_receipt_semantics/_Document/_loads의 실제 호출수와
원로그·성공/예외·시간·tracked/보호 경계를 봉인한다. 준비 예상 수는 실행 결과가 아니다.

1. 우선 교차 호출 메모 없이 _ledger_inverse에서 만든 원본 _Document2를 같은
   _receipt_semantics 호출에서 schema/batch 검사가 다시 읽는 구조로 순수 중복
   _loads2만 제거하는 안을 비용 비중과 함께 검토한다. public 반환/오류 의미는 유지한다.
2. span 순회가 병목이면 호출내 성공 의미 결과(str)만의 private 재사용을 검토한다.
   resolved root·actual module bytes·설정/함수/JSON/hash/copy 의존 신원·정확 immutable
   PATHS5 원문 tuple을 모두 결속하고 current live 검사는 매번 실행한다. 파싱한 dict/
   proof/실패·예외는 저장하거나 재사용하지 않는다. 성공 결과는 현재 입장/종료 검사가
   모두 끝난 뒤에만 발급한다. 소비자 예외·검증 실패 후에는 그 호출 메모를 폐기하고
   이후 catch-and-continue는 원본 의미 계산으로 검증한다. 호출 간 재사용0.

baseline 뒤 선택·실제 범위는 이 사양에 기록하고 소유2 이외 필요 파일은 별도 선언한다.
2026-10-07 선택: 실제 baseline2는 7.8063655초(cProfile 포함), _read_proof2/
_snapshot14/_objects42/_git74/_receipt_semantics2/_Document8/_loads16이다. _loads
누적0.512894초에 비해 위치 순회4.742309초가 지배하므로 효과를 과장하지 않는다.
교차 호출 메모를 추가하지 않고 같은 receipt 호출의 검증된 Document2만 재사용한다.
각 raw inverse/schema/batch 검증은 그대로이고 _loads16→12 및 실제 ledger 중복파싱4회
제거를 확인한다. 시간은 동일 실행의 실제 값만 보고하며 전체 번역 처리 속도 보장으로 확대하지 않는다.
수치 개선이 없거나 안전 경계를 약화하면 완료 GO하지 않는다. 기존 역사 endpoint·
receipt5 pin·수용273→274·41848→41849·native/render 상태·source census·raw 역상은 불변이다.

## 표적 검증

1. 같은 원본 fresh 정상 호출의 before/after 실제 cProfile. 함수 후킹/mock0·원본
   Git/파일 검증 모두 실행. _read_proof/typed snapshots/objects/Git/current disk/HEAD
   호출수·직접 부모·전역 경로·export snapshot·종료 검사를 유지한다. source2/UI/ledger/
   공개 package·user 저장·seed·Godot와 478 원로그 불변을 전수 대조한다.
2. 기존 market controls77은 모집단을 줄이지 않는다. 원래 public Investment/four-raw
   predecessor·source census213·source/receipt UI 비교의 출력·원입력·alias/endpoints를
   확인한다. 메모를 선택하면 warm Git/HEAD/disk/config/module/function/외부의존·변조
   원장 재해시·foreignroot·forged_ACTIVE·memo 오염·실패후 catch-and-continue·두 별도
   invocation·예외 종료·mutable alias/noerrorcache 반례를 추가하고 실제 결과로 수를 기록한다.
3. 영향 없는 365 대형 UI·JA 전체 UI·공식 import·engine·240주·전체 pipeline 반복0.
   그 결과를 새 실행 또는 게임 품질 GO로 세지 않는다. 필요한 wrapper 소비자 접속은
   함수 원문·변경 입력 집합으로 직접 정하고 실제 실행/재사용을 분리한다.
4. L2 전칸·독립 최종 판정 뒤 메인 마감. 종료 metadata는 원본 queue/context/등록/
   판정 원장 owner 검사. 글로벌 본편 HOLD·공개 GO1·인간 OPEN45·과거 판정 보존.

project.godot·게임 코드/원문/번역·full_game_localization·release inventory·공개 manifest/
PCK·인간 원장·과거 agent 보고·사용자 저장·seed 변경0. Mac 잠금 해제 요청/폴링0.
규범 승격: 새 규범0. 기존 영향 표적 검수·current proof 정본 적용이며 비용/역사 결속은
이번 단위의 일회성이다. 자동 통과는 재미·깊이·문체의 증거가 아니다.


## 2026-10-07 마감 — 동일 receipt 호출의 중복 파싱4회만 제거, 한정 GO

- candidate `18197f4d921f7b83302ab82c69123c9c38b325cf` / tree `c4ff636d68898b476daa76b3204e96adce7cecb3`.
  source2 `c04607aa5e0fe44586c947867493518d4dac98ed` 뒤 현재 상태 갱신2행뿐이다.
  비저자 [전수보고](../agent_reviews/ORDER-479.json) SHA `dee8fda7b92629942c991bddb567181d8145e7619e3d534df97cbb30a7e54116`.
  모듈/호출간 캐시0·새 입력/우회0·원 public bytes identity/receipt str 반환 보존.
- 기존 inverse 검증 본문·receipt의 나머지 schema/batch/header 검사·config·원본77
  반례 구문을 AST 전수대조했다. 같은 호출의 checked Document2 값만 다시 읽는다.
  게임/원문/번역/수용273→274 및41848→41849 역사 핀·공개·사용자 변경0.

### L2 — QA 계산 한 단위, 전 칸

| 단위 | 도달 경로 | 생산자 ↔ 독자 | 바꾸는 상태 | 포기 시 잃는 것 | 서사 위치 | 장면 계층 | 닫는 것 |
|---|---|---|---|---|---|---|---|
| 원장 receipt 파싱 | controls1/stdout.log:1 actual96; standalone1/stdout.log:1 actual90; candidate1/stdout.log:1 | tools/market_cycle_label_history.py:225 ↔ :269 ↔ :332/:369 | _loads16→12; 원본입력/순수출력 동일 | receipt 현재 Git/원장 증명(:269, :369), QA 입출구·게임 주차 해당없음 | QA/current proof(게임서사 추가0) | QA(T1~T3 장면 추가0) | 중복 ledger 파싱4회; 그 외 없음 |

### 실제 증거 / 제한 재사용

원본은 `.git/order479-20261007.iU0dWw/`에 보존한다. 아래 SHA는 각 result 원문이다.

| 실제 실행/결속 | 결과 | SHA-256 |
|---|---|---|
| baseline2 원본 empty fresh+cProfile | PASS7.8063655초; parses16 | cd0adbd315cd15ebb0d1916aaf227b84cc76a1776bf5d18ee2e34c13320b6953 |
| after1 같은 원본+cProfile | PASS7.966649083초; parses12 | cb85298e15f9b4010200074bc70f45a92d839dc1f48a9cb732e7963ce6bb20e5 |
| controls1 current 원본77+pure19/actual213 census 검증 | PASS96/실패0·217.522852083초 | 6737c01442d02ff521b7682a137241432244e9045ee65b266fa76e084e485813 |
| standalone1 등록된 원본 CLI | actualexit0/90·187.416877042초; privateexpected89 wrapperFAIL 유지 | 64c81370fb5b1a0fc784eeae121b1600200884f434936dd5b82bb3a4dfe0d856 |
| standalone-seal1 actual90 로그/원입력 결속 | PASS; 원본QA 재실행0 | 278c6c82ece884135b8f3a7aeaafe2798719bc24bfd85f76bfea6bc1d9fecd95 |
| comparison2 AST/전체3230 tracked/보호/478 원본87 | PASS; 원검사 모두 보존 | 05f6f59ae9642d8374196b59218721858fd4a09b5bc7e944efe33517d4eb8b38 |
| candidate1 문서2행 후 새HEAD 원본 fresh 입출구 | PASS6.051004084초; controls96/90 입력동일 재사용 | 538b61f7ee1fc782beb1b398184c789fc510abc369377d8d20551cba1470155e |

- 실제 _read_proof2/_snapshot14/_objects42/_git74/_receipt2/Document8/
  walk553996/ws2198536/config4/disk14/product_inverse4/transition4는 그대로다.
  _loads16→12와 누적0.512893876→0.287765958만 감소했다. 전체시간은0.160283583초
  늘었고 after는 다른 QA와 겹쳤다. 각1표본이므로 통계적 속도/전체 pipeline 개선 GO가 아니다.
- census는 478의 실제 collect 결과213/SHA877171e48c9d8b595d33144c3cc0c1e79cb4715e81236c1851eb368943d5832d를
  현재 원본 API가 typed Git·raw/disk와 다시 검증한 제한 재사용이다. 새collector0/
  원본engine0/공식import0/대형365·JAUI·240주·전체pipeline 반복0이다.
- 선택기는 accidental default4 실제실행(audit.py/context/queue0, self-test1)을 남겼다.
  root가 실행중 HEAD를 바꾸어 원래 exit guard가 `actual proof changed during use`로
  거부했다. 고정후 original self-test만 actual90으로 재실행했다. 도구가 보인 꼬리만
  보존한 selector-attempt1은 전체 자식 로그가 아니다. unsupported --json 검사0,
  private profile.py의 stdlib shadow 실패 표본0, AST 비교 인덱스 실패도 각각 유지한다.
  comparison1의 미존재 함수명0은 current proof 생략이 아니라 요약 오류이고 실제
  config4/transition4를 담은 comparison2만 권위가 있다. 실패를 성공으로 바꾸지 않는다.
- 자기 개선: audit_select 영향 목록은 반드시 `--list`; 기본은 실행이다. 원본 검사가
  실행중일 때 tracked commit을 바꾸지 않는다. 이미 CODEX_QUEUE 공통검증이 소유한
  규칙을 적용하며 새규범 승격0/이 raw전이 결속은 일회성이다.
- gangnamdream-dev의 소유분리·표적 검수·원로그/위임판정/인간증거 분리를 적용했다.
  자동 게이트는 계약 증거이지 재미·깊이·문체의 증거가 아니다. 본편 HOLD·공개GO1·
  인간OPEN45·과거판정 유지. 실제화면/자연플레이/원어민/인간/물리패드/출시 GO가 아니다.
  다음 별도선언: 실제월말20억 첫돌파 기록의 고정10억 잔여 안내 수리.
