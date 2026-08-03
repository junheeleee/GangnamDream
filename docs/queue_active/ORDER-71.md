# Active Queue Spec: ORDER-71

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-71 [P0·현지화] 유혹 선택지의 영어 도덕 판정을 제거한다

**착수 파일:** `content/events_en/arc_events.json`,
`tools/demo_core_loop_v2_audit.py`, `docs/QA_CHECKLIST.md`와
큐/완료 증거 문서(`CLAUDE.md`, `docs/CODEX_QUEUE.md`,
`docs/WORK_LOG.md`, `docs/HANDOFF.md`, `docs/STATUS.md`, 이 사양).

**착수 설계 판정:** 영어 선택 0을
`Block the number and put the phone face down`으로 바꾼다. 선택 라벨의
영어 문법은 같은 화면의 선택 1과 맞춘 명령형으로 두되, 한국어와 동일하게
번호 차단과 휴대폰 방향이라는 관찰 가능한 행동만 남긴다. 한국어 원본,
선택 순서, 결과문, gameplay key·효과·플래그·route·Week-8 후속은 불변이다.
데모 감사가 한영 행동 대응과 금지된 도덕 자기선언의 재유입을 막는다.

## 깊이 3문

1. 지우면 영어권 플레이어만 다른 선택을 저급하다고 미리 판정받는다.
2. 차단/수락에 따른 돈·정신·후속 상태는 그대로 갈린다.
3. 두 선택은 같은 유혹 자리에서 당장 필요한 돈과 위험 회피를 경쟁한다.

## 배치 A — 의미 중립

- `arc_temptation_01`의 영어 선택 0을 한국어처럼 관찰 가능한 행동만 말하도록
  고친다. 결과·효과·후속·한국어는 바꾸지 않는다.
- KO/EN 선택의 행동, 시제, 주체를 대조하고 설교 방지 원칙을 회귀 검사한다.

## 완료 증거

- 영어의 상대 선택 비하/도덕 자기선언: `0`
- KO/EN 효과·후속 차이: `0`
- `english_hangul_audit.py`: PASS
