# Archived Queue Spec: ORDER-288

#### [x] ORDER-288 [P0·정산] 블랙잭 분할 더블의 추가 원금 보존

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

## 완료 — 2026-09-26

- 최종 source `3f3c50273c19c2668bdc997e0c85b48134fb64f4`,
  tree `3c84ff7a6a3a233071777e24cbeaba6557c8e9d8`.
  [독립 검수](../agent_reviews/ORDER-288.json)의 이 작업 한정 GO.
- 제품 변경: 분할 더블의 `_split_stake` 대입을 누적으로 바꾸고 패별 실제
  원금 식을 단순화했다. 정산·손익·ON TABLE이 같은 원금을 사용한다.
  배율·카드 규칙·공개 고정 데모·저장 형식 변경 0.
- `BlackjackAccountingCheck`는 실제 Table에 고정 카드를 공급하고
  deal/split/double/hit/stand를 호출한다. 24사례 × KO/EN = 48.
  없음/본패/분할패/양쪽 double × 승/무/패/bust 16사례와 일반·natural·혼합
  대조 8사례. 기대값은 독립 상수이며 제품의 payout 함수를 읽어 만들지 않는다.
- 10만원 기본 베팅에서 분할 double 승리의 총 회수는 40만→60만원,
  무승부는 20만→30만원. 분할 double 양패의 손익은 −20만→−30만원.
  연속 세션·최근10회 기록·각 행동 현금 신호·reset·요약·두 언어 패리티를 확인했다.
  ON TABLE은 표시식 입력값 검증이며 새 화면 캡처가 아니다.

### 실제 실행과 실패 보존

아래는 모두 `.git/full-game-localization/` 아래 `result.json`이며 각 파일은
실행 소스·입력 해시·사용자 파일 전후·stdout/stderr/Godot log SHA를 결속한다.

| 실행 | 결과 | result SHA-256 |
|---|---|---|
| `order288-before-fix` | cfc3789, 검사 예약어 parse FAIL·0사례·60초 timeout/exit−9; 정산 재현 아님 | `f1131d708630f59add6a1a19e5bbbcf00b5deb9b116d73c8c93be4b5eeb82592` |
| `order288-before-fix-parser-repair` | d77a7f5, exit1·48사례·296assert 실패·16PASS/32FAIL | `9e301253e2bd0766e1973c8c8b6375b3443b57eba8b32c1a25f627d9c16799e6` |
| `order288-after-fix` | 3f3c502, exit0·48PASS·errors0·정확 성공 marker | `e246b610ce9c7f28cc5d5f9dd20aaf0c810afebc595d534651598d1ca2c4da5b` |
| `order288-targeted-first` | 정적12 중10PASS/2FAIL; 아래 한계 참조 | `9b93f8aaa38199460a1fc421414a241c6df592b35d79ff32e8c8a32865c4396e` |

첫 검사 문법은 GDScript 예약어 `namespace` 대신 `qa_namespace`를 써서
수리하고 오디오 정리 타입을 명시했다. 모집단·기대값을 줄이지 않았다.
실제 before/after는 검사·runner 등 11입력이 같고 Table만 다르다.
실패 32행은 앞선 현금 오차의 누적을 포함하며 32개 독립 제품 결함이 아니다.
후속 실행 3.384초, 입력12·실제 사용자 파일43 전후 동일, 새 pre-autoload
namespace 사용·보존. QA 저장소를 지우거나 원래 사용자 저장을 조작하지 않았다.

표적 정적 PASS: core static, EN 표면/coverage, 오디오·입력 정적 계약,
플레이어 표면, surface coherence, JA UI, ZH, context, 감사 등록154.
feature-liveness는 기존 `.git` 내부 과거 증거 gd33개를 제품으로 세어 FAIL이다.
새 검사 파일은 scene의 참조가 있고 기존 제품 orphan2와 baseline은 변경하지 않았다.
queue FAIL은 새 행 순번0 선언 실수다. 종료 시288행을 제거해 기존1..75로
복원했다. 종료 metadata 결과는 `order288-closure-first/result.json`에 별도 보존한다.
정산48은 문서 마감 때문에 반복하지 않는다.

### L2 결속과 경계

```text
도달 경로      : BLACKJACK_ACCOUNTING_CHECK_OK cases=48 locales=2
생산자 ↔ 독자   : scenes/BlackjackTable.gd:318 ↔ scenes/BlackjackTable.gd:420
바꾸는 상태     : split double 원금 100000 → 200000; 실제 추가 차감과 일치
포기 시 잃는 것 : double 미선택 대조 none/main 사례의 현금·회수값
서사 위치       : 해당 없음 — 카지노 Table component 정산
장면 계층       : 해당 없음 — 새 장면 저작 0
닫는 것         : 분할 double 원금 누락 1건; 전 블랙잭/본편 출시 닫음 아님
```

검사·runner의 엄격48행/정확 marker·격리·오류 검출만 추가했으며 규범 승격은
없다. 위 실행·파일 소유·판정 지시는 **일회성**이다. 자동 게이트는 계약 증거이며
재미·깊이·문체·원어민·인간·물리 패드 관찰을 공급하지 않는다.
실제 화면·패키지·fresh-story 진입·다른 해상도·AA·split natural·혼합net0 설명·
dealer peek·EV·중도 이탈·바카라는 미검증/별도 수리다. 본편 HOLD,
공개GO1·인간OPEN45·공식40129/b130/meta9·보류72를 보존한다.
