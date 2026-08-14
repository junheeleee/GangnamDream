# Active Queue Spec: ORDER-102

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-102 [P0·코어 재설계] 60개월 story map과 빠른 영향 검사를 만든다

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
3. 한 장면은 기억 최대 2개와 불가역 결정 1개만 읽고, 챕터 간에는 7개 장기
   결정과 4개 carryover 슬롯만 전달한다. 60개월 모두를 독립 분기나 새 장면으로
   만들지 않는다.

## 배치 A — 단일 월간 정본·빠른 검사 10단위

1. 정확히 M01~M60, 주차 1~240, 장별 12개월을 한 `story_map`에 선언한다.
2. 각 월은 질문·압력·기회·사람 약속·기한·처리(K/M/E/N)를 소유한다.
3. 기존 이벤트와 아직 쓸 장면을 `existing`/`planned`로 구분해 없는 콘텐츠를
   구현 완료처럼 세지 않는다. 기존 장면도 `mapped`/`needs_rule`로 갈라 아직
   `story_rules` 이관이 필요한 장면을 숨기지 않는다.
4. 표현·기억·결정 중 장기 저장할 것만 reads/writes로 선언한다.
5. 장기 결정 enum은 7개로 닫고 다른 장기 flag 발명을 거부한다.
6. 챕터 carryover는 정확히 네 슬롯만 허용한다.
7. 한 장면의 역사 입력은 기억 2개+결정 1개를 넘지 못한다.
8. 실제 동석 충돌은 참가자 3명 이상을 요구하고 이름 언급만으로 세지 않는다.
9. M01·M35·M55를 첫 세로 단면으로 표시하고 생산자/독자/포기한 길을 닫는다.
10. 검사기는 JSON·ID·주차·생산자/독자·carryover만 5~15초 안에 판정한다.

## 배치 B — 다음 오더에 넘길 이관 경계

- M01: 기존 W1~4 영수증과 월말 결산을 공통 원장 adapter로 읽는다.
- M35: `선택을 들은 사람`을 3장 보스 전 실제 관계 증언 장면으로 만든다.
- M55: 제안자·검토자·보호할 사람이 같은 방에서 충돌하는 5장 정점을 만든다.
- runtime·산문·UI 구현은 story map과 세 단면을 사람이 승인한 뒤 별도 작은
  오더로 연다. 이 오더에서 60개월 이벤트를 한꺼번에 작성하지 않는다.

## 정확한 파일 소유권

**선언 3:** `CLAUDE.md`, `docs/CODEX_QUEUE.md`, 이 사양.

**정본·검사 9:** `content/meta/story_map.json`,
`tools/story_map_audit.py`, `content/meta/narrative_spine.json`,
`tools/narrative_spine_audit.py`, `content/meta/story_rules.json`,
`docs/CHOICE_CONSEQUENCE_SYSTEM.md`, `docs/DECISIONS.md`,
`docs/CONTEXT_INDEX.md`, `docs/context_manifest.json`,
`tools/audit_scope.json`, `tools/audit_select.py`(story map 단독 fast lane).

기존 이벤트 JSON·제품 런타임·여력 UI·causal ledger·legacy migration은 이
배치에서 수정하지 않는다. `project.godot`은 사용자 소유이므로 건드리지 않는다.

## 완료 증거

- `story_map` 60/60개월, 1~240주 연속, 장별 12개월.
- M01·M35·M55 세 단면의 reads/writes/forgone 및 참가자 계약 GREEN.
- 장기 결정 7개, carryover 슬롯 4개, 장면 입력 상한 위반 0.
- existing event ID 누락 0, planned ID가 기존 구현처럼 오인되는 경우 0.
- existing beat의 `mapped`/`needs_rule` 분류가 실제 `story_rules` 존재 여부와
  정확히 같고, 장기 결정·carryover fact 11개는 `story_rules.fact_types`가 소유.
- `story_map_audit.py` 정상·독립 negative self-test·JSON duplicate-key·diff-check
  GREEN, 목표 실행시간 15초 이하.
- 240주 전체 Godot 감사와 거대 causal self-test는 실행하지 않는다.

## 규범 판정

계속 유효한 60개월 소유권·기억 상한·챕터 이월 규칙은
`docs/CHOICE_CONSEQUENCE_SYSTEM.md`와 `content/meta/story_map.json`으로
승격한다. 파일 목록·M01/M35/M55 착수 순서·검사 명령은 일회성이다.
