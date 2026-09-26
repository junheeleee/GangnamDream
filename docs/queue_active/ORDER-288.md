# Active Queue Spec: ORDER-288

#### [~] ORDER-288 [P0·정산] 블랙잭 분할 더블의 추가 원금 보존

[~] 착수 — 2026-09-26. 사용자의 출시 준비 후속 실행 지시와 WORK_UNIT의
개발·품질 위임으로 확인된 정산 결함을 우선한다. 기준 HEAD 7211c8f.

## 문제·판정 가능한 범위

`BlackjackTable._double_down`은 분할 패의 추가 베팅을 현금에서 차감하지만
`_split_stake = _stake`로 이미 낸 원금을 덮어 추가 차감을 누락한다.
그 결과 해당 패의 승리·무승부 반환액과 세션 순손익이 실제 베팅과 다르다.
`_split_active`는 `_split` 배열(분할 후 먼저 플레이하는 패)을 가리킨다.

기존 배율·규칙·선택을 바꾸지 않고 패별 실제 원금을 누적해 반환과 순손익에
같은 원금을 쓰도록 고친다. 중도 이탈 없이 정산 완료한 회차의 계약은
`세션 net = 최종 현금 - 시작 현금`이며
기존 일반승은 원금 2배 회수, 무승부는 원금 반환, 패배는 회수 0이다.

깊이3문: 없으면 추가 베팅이 정산에서 사라진다. 이후 현금·세션 보고에 실제
차이가 남는다. 더블은 같은 현금으로 할 수 있는 다음 베팅과 경쟁한다.

## 파일 소유권

- ROOT: `scenes/BlackjackTable.gd`의 추가 원금·정산식만,
  `tools/run_blackjack_accounting_check.py`, `tools/audit_scope.json`의 해당 등록.
- 테스트 작성 에이전트: 새 `tools/BlackjackAccountingCheck.gd`, `.gd.uid`, `.tscn`.
- ROOT 기록: CLAUDE 현재 상태 한 줄, CODEX_QUEUE, WORK_LOG, STATUS,
  이 active/archive288, `docs/agent_review_decisions.json`의 새 판정 한 건.
- 비저자 검수: `docs/agent_reviews/ORDER-288.json`와 git-private order288 증거.

공개 고정 데모·project.godot·원본 사용자 저장·인간 원장·번역 사전·portable·
게임 배율·AP·이벤트·엔딩은 비소유. AA 추가 카드, split natural 판정, 혼합
결과 설명, dealer peek, 재진입 방어, 바카라는 이 단위에서 고치거나 인증하지 않는다.

## 실행·검증

1. 이 선언 commit/push 뒤 실제 Table의 deal/split/double/stand 경로를 고정
   카드로 실행하는 작은 회귀 검사를 만든다. 수정 전 실패를 원형 보존한다.
2. 일반 패·분할 패의 double 없음/분할만/본패만/양쪽과 승·패·무승부를
   독립 기대값으로 확인한다. 현금, `_net`, history net, session summary,
   각 행동 뒤 차감, 다음 핸드 reset을 본다. KO/EN 같은 산식이다.
3. 기존 pre-autoload bootstrap으로 새 저장 공간에서만 Godot를 실행한다.
   stdout/stderr/Godot log·exit·정확 marker·입력 해시와 실제 사용자 파일
   전후를 보존한다. 실행 재현은 자동 component 검증이며 물리 조작이 아니다.
4. 같은 사례를 수리 후 재실행하고 비저자가 코드·기대값·실패/성공 증거를
   직접 검수한다. 검사 수를 실제 결과로 기록한다.
5. audit_select로 영향 범위를 확인하고 새 정산 검사·영문 표면·오디오/입력
   정적 계약·queue/context·diff를 표적 검증한다. 무관한 240주 전체 감사,
   과거 중국어 화면 검수, 원어민·물리 패드 재인증은 하지 않는다.

새 규범 승격 없음: 실제 낸 원금과 현금 보존을 기존 배율에 맞추는 버그 수리.
자동 검사는 재미·원어민·인간 관찰이 아니다. 본편 HOLD·공개 GO를 유지한다.
