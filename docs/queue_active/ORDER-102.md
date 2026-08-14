# Active Queue Spec: ORDER-102

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-102 [P0·코어 재설계] 60개월 story map과 빠른 영향 검사를 만든다

**현재 상태 (2026-08-15):** 60개월 설계 후보와 M01·M35·M55 세로 단면,
`story-map` 명시 fast lane까지 완성했다. 사용자 후속 판정에 따라 M01~M06에서
형식적 순서표가 아닌 실제 고민과 지배전략 부재를 먼저 증명한다. 런타임·산문·UI는 그 뒤다.

**사용자 판정 (2026-08-14):** 숫자 여력 `5·3·2·4`를 네 행동에 돌려 쓰는
현재 판은 순서와 배분의 의미가 약하고, 회사 지원·알바처럼 초반에만 성립하는
행동을 5년으로 억지 확장한다. 240주를 고정 행동과 개별 조건 수백 개로 채우지
말고, 먼저 다섯 장 전체의 월별 압력·사람·기한·분기 회수를 한 체계로 고정한다.

## 깊이 3문

1. 지우면 3~5장 빈 월과 관계 수렴 부재가 다시 보이지 않게 되고, 데모 수리만
   반복하다 240주 전체의 재미를 판정하지 못한다.
2. 기존 W1~24의 원자적 선택·typed receipt·완료/미룸/만료·월말 스냅숏·save
   replay는 버리지 않는다. 숫자 여력 UI와 경로별 역사 재구성은 이 기반 위의
   임시 표현으로 분리한다.
3. 한 장면은 기억과 carryover를 합쳐 최대 2개, 불가역 결정 1개만 읽고,
   챕터 간에는 7개 장기 결정과 4개 typed carryover receipt만 전달한다. 60개월 모두를 독립 분기나 새 장면으로
   만들지 않는다.

## 배치 A — 단일 월간 정본·빠른 검사 10단위

1. 정확히 M01~M60, 주차 1~240, 장별 12개월을 한 `story_map`에 선언한다.
2. 각 월은 질문·압력·기회·사람 약속·기한, 실제 후보 2~4개와 마감·미선택 결과·선행관계, 처리(K/M/E/N)를 소유한다.
3. 기존 이벤트와 아직 쓸 장면을 `existing`/`planned`로 구분해 없는 콘텐츠를
   구현 완료처럼 세지 않는다. 기존 장면도 `mapped`/`needs_rule`로 갈라 아직
   `story_rules` 이관이 필요한 장면을 숨기지 않는다.
4. 표현·기억·결정 중 장기 저장할 것만 reads/writes로 선언한다.
5. 장기 결정 enum은 7개로 닫고 다른 장기 flag 발명을 거부한다.
6. 챕터 carryover는 정확히 네 슬롯만 허용하며 kind·source receipt·선택적 actor를 잃지 않는다.
7. 한 장면의 역사 입력은 비트 수와 무관하게 기억+carryover 2개와 결정 1개를 넘지 못한다.
8. 실제 동석 충돌은 참가자 3명 이상을 요구하고 이름 언급만으로 세지 않는다.
9. M01·M35·M55를 첫 세로 단면으로 표시하고 생산자/독자/포기한 길을 닫는다.
10. 검사기는 JSON·ID·주차·생산자/독자·carryover만 5~15초 안에 판정한다.

## 다음 오더에 넘길 이관 경계

- M01: 기존 W1~4 영수증과 월말 결산을 공통 원장 adapter로 읽는다.
- M35: `선택을 들은 사람`을 3장 보스 전 실제 관계 증언 장면으로 만든다.
- M55: 제안자·검토자·보호할 사람이 같은 방에서 충돌하는 5장 정점을 만든다.
- runtime·산문·UI 구현은 story map과 세 단면을 사람이 승인한 뒤 별도 작은
  오더로 연다. 이 오더에서 60개월 이벤트를 한꺼번에 작성하지 않는다.

## 배치 B — M01~M06 전략 표본

1. `[첫 실행 재조정]` 돈·몸·관계는 숫자 AP 대신 `여유 있음/없음`만 쓴다.
2. 주력 약속 완료만 다음 달 같은 축 여유를 만들 수 있다. 둘째 약속은 이미 있던
   같은 축 여유 하나를 소모하고, 그 완료로 소모분을 즉시 되돌려 받지 않는다.
3. `after`나 실제 마감 충돌이 없으면 클릭 순서는 결과를 바꾸지 않는다.
4. 카드에는 축·마감·선행조건·`다음 달 빚/이번에 문 닫힘`·둘째 여유 소모를
   공개하되 구체 산문과 먼 결과는 미리 폭로하지 않는다.
5. M01~M06의 각 약속은 완료·미룸·만료의 구체 payload를 소유한다. 미룸은 한 번만
   다음 달 빚으로 돌아오고, 다시 외면하면 만료된다.
6. 짧은 상태 탐색은 `항상 현금`, `항상 둘째`, `항상 만료 우선`, 클릭 순서,
   축 교환이 지배전략이 되는 경우를 거부한다. 240주·Godot는 실행하지 않는다.

## 정확한 파일 소유권

**선언 3:** `CLAUDE.md`, `docs/CODEX_QUEUE.md`, 이 사양.

**정본·검사 12:** `content/meta/story_map.json`,
`tools/story_map_audit.py`, `content/meta/narrative_spine.json`,
`tools/narrative_spine_audit.py`, `content/meta/story_rules.json`,
`docs/CHOICE_CONSEQUENCE_SYSTEM.md`, `docs/DECISIONS.md`,
`docs/CONTEXT_INDEX.md`, `docs/context_manifest.json`,
`tools/audit_scope.json`, `tools/audit_select.py`(story map 단독 fast lane),
`tools/story_map_strategy_sim.py`(M01~M06 지배전략 탐색).

기존 이벤트 JSON·제품 런타임·여력 UI·causal ledger·legacy migration은 이
배치에서 수정하지 않는다. `project.godot`은 사용자 소유이므로 건드리지 않는다.

## 완료 증거

- `story_map` 60/60개월, 1~240주 연속, 장별 12개월.
- M01·M35·M55 세 단면의 reads/writes/forgone 및 참가자 계약 GREEN.
- 장기 결정 7개, carryover 슬롯 4개, 장면 입력 상한 위반 0.
- existing event ID 누락 0, planned ID가 기존 구현처럼 오인되는 경우 0.
- existing beat의 `mapped`/`needs_rule` 분류가 실제 결정 fact read/write까지
  정확히 같고, 장기 결정 7개는 `story_rules.fact_types`, 네 carryover payload는
  `story_map`의 typed receipt-ref 스키마가 소유.
- `story_map_audit.py` 정상·독립 negative self-test·JSON duplicate-key·diff-check
  GREEN, 목표 실행시간 15초 이하.
- `python3 tools/audit_select.py --lane story-map`은 위 소유 파일 밖 변경을 거부하고
  지도·5장 구조·M01~M06 전략·문서/큐 정합 다섯 검사만 실행한다.
- M01~M06 상태 탐색에서 클릭 순서·항상 현금·항상 둘째·축 교환 지배전략 0,
  서로 다른 손실과 열린 길을 가진 비지배 전략 3개 이상.
- 240주 전체 Godot 감사와 거대 causal self-test는 실행하지 않는다.

## 규범 판정

계속 유효한 60개월 소유권·기억 상한·챕터 이월 규칙은
`docs/CHOICE_CONSEQUENCE_SYSTEM.md`와 `content/meta/story_map.json`으로
승격한다. 파일 목록·M01/M35/M55 착수 순서·검사 명령은 일회성이다.
