# Active Queue Spec: ORDER-93

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-93 [P0·코어 루프] 첫 달을 월간 약속 선택과 한 달 에피소드로 다시 만든다

**사용자 승인 (2026-08-10):** 카드 문구와 물성만 고쳐 현재 상황을 모면하지
말고, 매주 무엇을 정하며 어디서 재미가 생기는지 24주·48주·240주 관점에서
다시 설계한다. 실측과 대안 비교 뒤 제안한 `월간 약속 선택 → 자동 편성 →
장면 안의 수행·대화 선택 → 고정 위기의 회수` 방향에 사용자가 `그래`로
승인했다.

**착수 — 만지는 파일:** `CLAUDE.md`, `docs/CODEX_QUEUE.md`,
`docs/queue_active/ORDER-93.md`, `docs/queue_archive/ORDER-93.md`,
`docs/queue_archive/ORDER-91.md`, `docs/DECISIONS.md`, `docs/PROPOSALS.md`,
`docs/CORE_LOOP_V2.md`, `docs/UI_ART_DIRECTION.md`,
`docs/CONTROLLER_UX_STRATEGY.md`, `docs/QA_CHECKLIST.md`,
`docs/DEMO_FIXLOG.md`, `docs/RELEASE_NOTES.md`, `docs/WORK_LOG.md`,
`docs/STATUS.md`, `docs/human_gates.json`, `docs/I18N_INFRASTRUCTURE.md`,
`docs/I18N_GLOSSARY_ZH.md`, `content/meta/demo_core_loop_v2.json`,
`content/meta/demo_localization_scope.json`,
`content/events/core_loop_v2_events.json`,
`content/events_en/core_loop_v2_events.json`, `content/events/arc_events.json`,
`content/events_en/arc_events.json`, `locale/ui_ja.json`,
`assets/scene_direction_manifest.json`, `scenes/CoreLoopPlanner.gd`,
`scenes/MainGame.gd`, `scenes/TutorialOverlay.gd`,
`systems/DemoCoreLoopV2.gd`, `tools/CoreLoopV2Check.gd`,
`tools/CoreLoopV2FirstEntryCheck.gd`, `tools/CommunicationPhoneCheck.gd`,
`tools/ScreenshotQA.gd`, `tools/demo_core_loop_v2_audit.py`,
`tools/demo_localization_scope.py`, `tools/scene_direction_catalog.py`.
Godot가 기존 스크립트의 UID·import 메타를 갱신할 때만 그 동반 파일을 같은
범위에 포함한다. `project.godot`과 2~6개월의 선택·효과·산문은 건드리지 않는다.

## 깊이 3문

1. 첫 달의 수동 배치 세 칸은 합법 주차만 검사할 뿐, 같은 선택 묶음의 결과를
   바꾸지 않는다. 이를 보존하면 플레이어는 책임질 일을 고르는 대신 달력
   서식을 완성하며, 240주에는 같은 조작이 약 220회로 늘어난다.
2. 현수 첫 만남은 `initiated_by=world`인데 `consumes_slot=true`라 민준이 알 수
   없는 우연을 미리 일정에 적게 한다. 제목만 행동형으로 고치면 같은 모순이
   다은·지연 첫 만남에서 반복된다. 세계가 일으키는 사건과 플레이어 약속을
   데이터·화면·저장 모두에서 분리해야 한다.
3. 첫 달부터 24주 전체를 한 번에 바꾸면 선택 수와 밸런스, 49개 제안의 산문,
   저장 호환을 동시에 흔들어 무엇이 재미를 개선했는지 판정할 수 없다. 첫 달만
   같은 내부 4주 저장 형식을 유지한 채 새 표면으로 바꾸고, 2개월차부터는 현행을
   비교 기준으로 둔다.

## 배치 A — 플레이어가 아는 약속 두 개만 고른다

- 첫 달 새 계획에서는 `목요일 야간 대타`, `자기소개서 네 문항 수정`,
  `아버지에게 다시 전화`, `휴대폰을 끄는 일요일`만 선택 후보가 된다.
  플레이어는 순서가 있는 두 약속을 고른다. 첫 번째는 이달의 중심, 두 번째는
  곁에 둘 약속이며 네 주 달력에 직접 넣지 않는다.
- 시스템은 중심 약속을 1주차, 보조 약속을 2주차, 현수 첫 만남을 숨은 세계
  사건으로 3주차, 첫 유혹 위기를 숨은 고정 사건으로 4주차에 편성한다. 실제
  기한이 충돌하거나 구 저장 호환 제안이 있을 때만 결정론적으로 가장 이른
  합법 주를 사용한다. 자동 편성 결과는 기존 `schedule` 저장 형식을 유지한다.
- 첫 달 루틴은 기존 기본 `생계+회복`을 그대로 적용하지만 별도 단계로 확인시키지
  않는다. 루틴 변경과 수동 주차는 2~6개월의 비교 표면에만 남는다.
- 화면은 한 번에 보이는 2×2 약속 선택과 포커스 상세, `0/2` 진행, 한 개의
  `이달 시작` 확인만 가진다. 기본 카드에는 행동·짧은 기한만 보이고 출처·종류·
  상태 문장을 겹쳐 쓰지 않는다. 마우스·키보드·패드가 같은 선택 순서와 취소를
  만들며 960×600에서 화면 내부 스크롤이 없어야 한다.
- 읽기 전용 재열기는 중심·보조 약속과 시스템이 편성한 네 주를 사실대로 보여
  주되, 아직 일어나지 않은 현수와 모르는 번호의 정체를 선공개하지 않는다.

## 배치 B — 선택이 4주차 중심 장면으로 돌아온다

- 첫 번째로 고른 약속은 4주차 `arc_temptation_01` 직전의 짧은 전용 브리지로
  돌아온다. 대타 수당, 고쳐 둔 자기소개서, 아버지 통화 뒤의 침묵, 비워 둔
  일요일 중 실제 완료한 한 가지 물리 흔적만 보여 주고 숨은 도덕·확정 미래를
  해설하지 않는다.
- 브리지는 선택 없는 한 호흡이며 기존 유혹 장면·두 선택·효과·금액을 바꾸지
  않는다. 중심 약속이 없거나 구 저장이면 종전 장면으로 안전하게 폴백한다.
- 현수 첫 만남은 선택 카드·미선택 기록·가짜 자기 메모를 만들지 않는다. 만남
  뒤에 열리는 `현수에게 먼저 보내는 메시지`부터 플레이어 약속으로 남는다.
- 첫 계획 튜토리얼은 `두 약속을 고른다 → 세계의 일은 예고 없이 온다 → 장면
  안에서 어떻게 대응할지 고른다`의 세 장만 설명한다. 2~6개월의 현행 조작을
  새 규범으로 거짓 설명하지 않는다.

## 검증과 사람 판정

- L1: 첫 달 후보 4·선택 2·자동 세계 사건 1·고정 위기 1, 주차 수동 입력 0,
  루틴 단계 입력 0, 동일 선택의 결정론적 schedule, 선택/취소 무변이, 저장
  왕복, 구 계획 읽기, KO/EN 실제 입력, 키보드·패드, 960×600·1280×800,
  Reduce Motion, 2~24주 회귀와 전체 감사를 통과한다.
- L2: 현수와 첫 유혹은 계획 전에 제목·보낸 사람·결말이 보이지 않고, 중심
  약속 네 종류가 각각 W4 브리지 하나로 돌아오며, 유혹의 선택·효과·금액과
  2~6개월 결과는 전후와 같다.
- L3: 사용자는 첫 화면을 60초 안에 끝내고 ① 고른 두 약속, ② 미룬 한 가지,
  ③ 현수를 계획한 적 없이 만났다는 점, ④ 4주차 유혹 전에 되돌아온 자기
  행동을 말할 수 있어야 한다. 여전히 `일정 관리`, `카드 네 개 채우기`라고
  부르거나 4주차가 앞선 선택과 무관하다고 느끼면 24주로 확장하지 않는다.

## 완료 조건

- 첫 달이 하나의 선택 화면과 자동 편성으로 완주되고 기존 4주 저장·경제·장면
  원자성이 보존된다.
- 세계 사건·플레이어 약속·지속 루틴·고정 위기의 소유권이 정본과 기계 계약에
  각각 한 번만 정의된다.
- 자동 검증은 구조·입력·정합만 통과했다고 기록하고 재미 GO는 사용자 플레이
  뒤에만 닫는다. 첫 달 사람 판정용 동일 리비전 테스트 빌드를 제공한다.
