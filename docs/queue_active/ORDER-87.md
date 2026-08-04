# Active Queue Spec: ORDER-87

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-87 [P0·초반 동기] 첫 계획 전에 125년의 벽을 겪고, 행동이 진로를 말하게 한다

**착수 — 만지는 파일:** `CLAUDE.md`, `assets/event_visual_contracts.json`,
`assets/scene_audio_manifest.json`, `assets/scene_direction_manifest.json`,
`autoloads/GameState.gd`, `content/events/story_events.json`,
`content/events_en/story_events.json`, `content/events/arc_events.json`,
`content/events_en/arc_events.json`, `content/events/core_loop_v2_events.json`,
`content/events_en/core_loop_v2_events.json`, `content/events/callback_events_35.json`,
`content/meta/demo_core_loop_v2.json`, `content/meta/narrative_spine.json`,
`content/meta/story_rules.json`, `content/meta/exposed_event_state_contracts.json`,
`content/meta/release_content_inventory.json`, `content/meta/demo_localization_scope.json`,
`docs/STORY_BIBLE.md`, `docs/CORE_LOOP_V2.md`, `docs/BALANCE.md`,
`docs/QA_CHECKLIST.md`, `docs/CONTENT_RATING_INVENTORY.md`, `docs/WORK_LOG.md`,
`docs/STATUS.md`,
`docs/RELEASE_NOTES.md`, `docs/DEMO_FIXLOG.md`, `docs/human_gates.json`,
`docs/CODEX_QUEUE.md`, 이 사양의 활성·아카이브 경로, `scenes/MainGame.gd`,
`systems/DemoCoreLoopV2.gd`, `tools/demo_core_loop_v2_audit.py`,
`tools/CoreLoopV2Check.gd`, `tools/CoreLoopV2BCheck.gd`, `tools/CoreLoopV2ECheck.gd`,
`tools/CoreLoopV2FirstEntryCheck.gd`, `tools/CoreLoopV2HandoffCheck.gd`,
`tools/ScreenshotQA.gd`,
`tools/StoryPlaybackCheck.gd`, `tools/StoryTutorialPlacementCheck.gd`,
`tools/DemoBuildCheck.gd`, `tools/core_loop_v2_balance_sim.py`,
`tools/arc_flow_sim.py`, `tools/exposed_state_consistency_audit.py`,
`tools/scene_audio_contract_check.py`, `tools/event_director_audit.py`,
`tools/first_session_pacing_audit.py`, `tools/release_content_inventory.py`,
`tools/audit_scope.json`.

**사용자 승인 (2026-08-04):** `docs/DECISIONS.md`의 P-7을 권고대로 실행한다.
현재 V2의 `opening_interview_math`는 실제로 첫 면접만 재생하고, 월 200만원으로
30억원까지 1,500개월·125년이라는 계산과 문제의식은 데모에서 빠져 있다. 이를
7개월차의 옛 장면으로 되살리지 않고 첫 달 계획 전의 연속 장면 안에 다시 심는다.

**착수 때 잠글 파일 후보:** `content/meta/demo_core_loop_v2.json`,
`content/events/arc_events.json`, `content/events_en/arc_events.json`, 필요한 경우
새 V2 초반 사건을 담을 `content/events/core_loop_v2_events.json`과 영어 오버레이,
`content/events/callback_events_14.json`, `content/events_en/callback_events_14.json`,
`content/events/callback_events_35.json`, `content/events_en/callback_events_35.json`,
`systems/DemoCoreLoopV2.gd`, `scenes/MainGame.gd`, `scenes/StoryMode.gd`,
`content/meta/story_rules.json`, `content/meta/exposed_event_state_contracts.json`,
`tools/demo_core_loop_v2_audit.py`, `tools/CoreLoopV2Check.gd`,
`tools/CoreLoopV2BCheck.gd`, `tools/CoreLoopV2InputRun.gd`, `tools/ScreenshotQA.gd`,
`docs/CORE_LOOP_V2.md`, `docs/QA_CHECKLIST.md`, `docs/WORK_LOG.md`, `docs/STATUS.md`,
`docs/RELEASE_NOTES.md`, `docs/DEMO_FIXLOG.md`, `CLAUDE.md`, `docs/CODEX_QUEUE.md`와
이 사양의 활성·아카이브 경로. 착수 선언은 실제 읽기·쓰기 소비자를 전수한 뒤
정확한 파일만 남겨 별도 커밋으로 먼저 푸시한다.

## 깊이 3문

1. 이 장면이 없으면 플레이어는 30억원이 왜 평범한 월급 계획으로 닿지 않는지
   몸으로 겪기 전에 월간 계획표부터 받으며, 게임의 욕망과 계획의 이유가 분리된다.
2. 옛 `저축가/투자자/창업가` 3택을 그대로 복원하면 플레이어가 아무 행동도 하기
   전에 정체성을 고르게 되고, 뒤의 실제 계획은 그 선언을 반복하는 장식이 된다.
3. 계산은 목표의 벽만 보여 주고 답은 확정하지 않는다. 이후 월간 약속·루틴·실제
   거래의 영수증이 어떤 길을 택했는지 말하게 해야 24주와 5년의 선택 인과가 같다.

## 배치 A — 첫 5분 연속 장면과 상태 소유권

- 프롤로그 수첩의 동기 선택, 미래산업기술 첫 면접, 고시원으로 돌아온 밤의
  계산, 아버지 연락, 첫 월간 계획이 하나의 인과로 이어지게 한다. `125년`은
  별도 1비트 결과 카드나 튜토리얼 설명문이 아니라 면접에서 본 월급 현실이
  방의 계산기로 돌아오는 장면이어야 한다.
- 계산은 `30억원 ÷ 월 200만원 = 1,500개월 = 125년`이라는 단순 비교다. 세금·
  생활비·투자수익을 정밀 예측한 것처럼 쓰지 않고, 월급만으로 목표를 보장할 수
  없다는 문제의식만 전달한다. 30억원 승리 조건·시작 현금·월급·고정비·수익률·
  파산선은 바꾸지 않는다.
- 계산 뒤 선택이 필요하면 수치·경로·`mindset_*`를 쓰지 않는 표현 선택으로만
  둔다. 진로를 미리 선언하는 옛 세 선택은 V2에서 숨긴 채, 첫 계획판은 지금
  가능한 생계·성장·회복과 실제 사람 약속을 그대로 소유한다.
- 같은 밤을 면접 결과 카드, 계산 카드, 아버지 카드로 세 번 끊지 않는다. 현재
  예약 장면의 한 주 소유권·prelude 영수증·저장/복귀를 보존하고, 빠른 입력도
  선택·계획 앞에서 멈춘다.

## 배치 B — 옛 마인드셋의 실제 행동 매핑 또는 퇴역

- `mindset_saver`, `mindset_investor`, `mindset_founder`의 모든 생산자와 독자,
  16주 이후 callback, 25~240주 브리지·엔딩 독자를 전수한다. 이름만 남은 플래그를
  새 계산 선택으로 다시 만들지 않는다.
- V2 영수증에 거짓 없이 대응하는 행동이 있으면 그 실제 완료·거래를 독자가
  직접 읽도록 옮긴다. 대응 행동이 없거나 한 번의 계획으로 성향을 단정해야 하는
  callback은 V2에서 명시적으로 퇴역시키고 legacy 저장의 기존 플래그는 보존한다.
- 옛 세 callback의 효과나 후속을 다른 행동에 공짜로 붙이지 않는다. 매핑 전후
  24·48·240주 돈·몸·마음·관계·장면 순서를 비교하고, 차이가 생기면 의도한 독자
  교체와 과거 저장 호환 외에는 허용하지 않는다.
- 번들 이름과 화면 설명은 실제 내용을 말하게 한다. `opening_interview_math`라는
  이름을 유지한다면 면접과 계산을 둘 다 소유해야 하며, 계산을 별도 영수증이
  소유하면 기존 이름은 호환 별칭으로만 남긴다.

## 비범위

- 투자·창업·저축의 새 시스템, 새 3택 진로, 경제 난이도나 수익률 재설계,
  25~240주 전체 편성 재작성, 데모 저장 retail 브리지, 치명 비용 UI는 만들지 않는다.
- `125년`을 민준의 미래 수익 예측이나 게임의 정답으로 쓰지 않는다. 큰돈에는
  드물고 위험한 기회가 필요하지만, 성실한 길도 안정·관계·전문성과 의미 있는
  결말을 만든다는 5년 정본을 훼손하지 않는다.

## 검증과 사람 판정

- L1: fresh·중간 저장·옛 V2/legacy 저장에서 프롤로그→면접→계산→아버지 연락→
  첫 계획의 순서·한 주 한 소유권·효과 1회가 같아야 한다. KO/EN 구조·숫자·
  플레이스홀더, 960×600/1280×800, 키보드·패드 24주, 24→48주·240주 원장,
  전체 감사와 CI를 통과한다.
- L2: `mindset_*` 생산자/독자 원장이 빈 이름·거짓 회상·도달 불가 callback 0을
  증명하고, 한국어 번역투·아버지 시간·고시원 공간·첫 계획의 동기와 행동이
  서로 모순되지 않는지 교차 재독한다.
- L3: 사용자는 같은 테스트판의 첫 5분에서 ① 30억원의 벽을 계획 전에 이해했는지,
  ② 게임이 투자나 창업을 정답으로 강요하지 않는지, ③ 면접·계산·아버지 연락이
  여러 카드가 아니라 한 장면처럼 이어지는지 판정한다. 자동 통과를 재미 합격으로
  부르지 않는다.

## 완료 조건

- 첫 계획 전에 125년 계산의 문제의식을 실제 장면으로 겪고, 옛 3택 없이도 왜
  이번 달을 계획하는지 이해된다.
- `mindset_*`의 모든 V2 독자는 실제 행동 영수증을 읽거나 명시적으로 퇴역하며,
  legacy 저장과 5년 정본은 거짓 이력 없이 유지된다.
- 같은 리비전의 KO/EN 24주 실제 입력, 24→48주·240주 원장, 전체 감사와 원격
  CI가 초록이고 규범 승격·일회성 판정을 기록한 뒤 아카이브한다.
