# ORDER-479 — 시장 번역 역사 검증의 반복 계산 비용

#### [~] ORDER-479 [위임 QA 수리] 원장 의미 검증의 중복 계산만 줄인다 — 2026-10-07

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
