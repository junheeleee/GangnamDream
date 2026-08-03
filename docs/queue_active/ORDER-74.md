# Active Queue Spec: ORDER-74

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-74 [P0·정합 기반] 신규 데모 장면이 아는 것과 말하는 사람을 증명한다

> 착수 — 24주 V2 사건 32건 가운데 실제 대화·메시지가 있는 27건에만
> 화자별 사실 참조와 말투 근거를 선언한다. 현재 전체 사건 1,597건을 강제
> 백필하지 않고, 신규 데모 집합의 누락·무생산 사실·도달 불가 요구만 래칫한다.
> 동시에 플레이에서 확인된 현수 시험 시점, 다은의 화요일 약속 선행지식,
> 상철의 4월 표기와 영어 `-ssi` 번역투를 같은 계약 아래 수리한다.
>
> 구현 파일: `content/events/core_loop_v2_events.json`,
> `content/events_en/core_loop_v2_events.json`,
> `content/meta/demo_core_loop_v2.json`, `content/meta/story_rules.json`,
> `tools/story_consistency_audit.py`, `tools/demo_core_loop_v2_audit.py`,
> `tools/audit_scope.json`, `docs/STORY_CONSISTENCY_SYSTEM.md`,
> `docs/QA_CHECKLIST.md`.
>
> 종료 파일: `CLAUDE.md`, `docs/CODEX_QUEUE.md`, `docs/STATUS.md`,
> `docs/WORK_LOG.md`, `docs/queue_archive/ORDER-74.md`. 게임플레이 수치,
> 선택 순서·효과·영수증, 저장 schema와 `project.godot`은 건드리지 않는다.
>
> 사용자 실플레이 긴급 범위 확장 (2026-08-03) — 추가 파일:
> `scenes/StoryMode.gd`, `tools/StoryDialogueHistoryCheck.gd`. 기록창 배경의
> “아무 마우스 버튼이면 닫기” 처리에 휠 버튼까지 포함되어 실제 스크롤이
> 닫기로 번지는 결함을 먼저 차단한다. 기록 내용·대사 진행·타이머 계약은
> 바꾸지 않고, 휠 스크롤 유지와 바깥쪽 좌클릭 닫기를 회귀로 고정한다.

## 깊이 3문

1. 지우면 `logic.requires`와 `logic.choice_produces`는 있어도 어느 화자가 어떤
   사실을 아는지 검사할 수 없어, 새 대사가 전지적 정보로 새기 쉽다.
2. 선택이 생산한 사실에 따라 후속 장면의 허용 대사와 도달 경로가 달라진다.
3. 침묵/모름/알고 말함이 같은 대화 자리를 경쟁한다.

## 배치 A — 최소 표현

- 기존 `logic.requires`·`logic.choice_produces`를 보존하고, 신규 데모 장면에만
  화자별 사실 참조와 말투 근거를 표현하는 최소 스키마를 둔다.
- 인물별 관계/말투 정본을 일반 높임말 표로 덮지 않는다.

## 배치 B — 신규분 래칫

- 이벤트 디렉터/감사가 생산자 없는 사실, 화자-사실 매핑 누락, 도달 불가능한
  요구를 거부하게 한다. 기존 1,597건 전면 백필은 데모 뒤 별도 작업이다.

## 완료 증거

- 신규 데모 사실의 생산자 없는 참조: `0`
- 화자 불명 공통 references: `0`
- 기존 이벤트 강제 백필: `0`
