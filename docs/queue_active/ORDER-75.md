# Active Queue Spec: ORDER-75

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-75 [P0·정점] 24주 첫 청구서를 데모 전용 T1으로 완성한다

**사용자 승인 (2026-08-03):** `PROPOSALS.md` P-3의 데모 T1 등록과 기존
8방향 선택·효과·영수증 보존 범위는 승인됐다. P-3의 고정 비트 수는 이후
사용자 지시가 폐기했으며, 숫자 할당량 없는 한 편의 깊은 연속 장면으로 진행한다.

> 착수 — 새 진입 루트와 필요한 내부 링크만 추가한다. 기존
> `v2_demo_first_bill`은 8방향 결정과 27·28·48주 영수증을 계속 소유한다.
> 구현 링크에는 같은 제목·로그·장소·음악을 유지하고
> `continuous_scene_fragment`를 붙여 갤러리·올해의 장면에는 진입 루트 하나만
> 남긴다. 링크·패널·독해 시간은 목표값이 아니라 완성 뒤 관측값이다.
>
> 배치 A 파일 — 원고·상태·연속성:
> `content/events/core_loop_v2_events.json`,
> `content/events_en/core_loop_v2_events.json`,
> `content/meta/demo_core_loop_v2.json`, `content/meta/narrative_spine.json`,
> `content/meta/story_rules.json`, `systems/DemoCoreLoopV2.gd`,
> `autoloads/GameState.gd`, `autoloads/DataRegistry.gd`,
> `autoloads/MetaProgression.gd`, `content/meta/default_meta.json`,
> `scenes/StoryMode.gd`, `tools/audit.py`,
> `tools/demo_core_loop_v2_audit.py`, `tools/story_consistency_audit.py`,
> `tools/CoreLoopV2ECheck.gd`,
> `tools/CoreLoopV2HandoffCheck.gd`, `tools/ManualSaveCheck.gd`,
> `tools/ModLayerCheck.gd`, `tools/BGMContinuityCheck.gd`,
> `tools/ScreenshotQA.gd`, `tools/audit_scope.json`.
>
> 배치 B 파일 — 전용 연출·출시 원장:
> `assets/backgrounds/v2_first_bill_desk_closeup.png`,
> `assets/backgrounds/v2_first_bill_desk_closeup.png.import`,
> `assets/characters/main_character_first_bill_decision.png`,
> `assets/characters/main_character_first_bill_decision.png.import`,
> `autoloads/ImageRegistry.gd`, `content/meta/cast_visual_years.json`,
> `assets/FIRST_BILL_VISUAL_BIBLE.md`, `assets/GOSHIWON_VISUAL_BIBLE.md`,
> `assets/CHARACTER_VISUAL_BIBLE.md`, `assets/IMAGE_PROMPTS.md`,
> `assets/ASSET_INDEX.md`, `assets/event_visual_contracts.json`,
> `assets/scene_audio_manifest.json`, `assets/game_audio_manifest.json`,
> `assets/scene_direction_manifest.json`, `tools/scene_audio_contract_check.py`,
> `tools/scene_direction_catalog.py`,
> `assets/mod_asset_manifest.json`, `docs/MODDING.md`,
> `docs/ART_AI_AUDIT.md`, `docs/ART_RESOLUTION_READINESS.md`,
> `docs/AUDIO_QA.md`, `tools/art_resolution_baseline.json`,
> `content/meta/release_content_inventory.json`,
> `docs/CONTENT_RATING_INVENTORY.md`.
>
> 종료 파일 — `CLAUDE.md`, `docs/CODEX_QUEUE.md`,
> `docs/CORE_LOOP_V2.md`, `docs/CHOICE_CONSEQUENCE_SYSTEM.md`,
> `docs/PROPOSALS.md`, `docs/QA_CHECKLIST.md`, `docs/DEMO_FIXLOG.md`,
> `docs/WORK_LOG.md`, `docs/RELEASE_NOTES.md`, `docs/STATUS.md`,
> `docs/queue_active/ORDER-75.md`, `docs/queue_archive/ORDER-75.md`.
> `MainGame.gd`, `SaveManager.gd`, `project.godot`, 48주 보스·엔딩·밸런스 수치는
> 이 작업에서 바꾸지 않는다.

> 범위 보강 (2026-08-03) — 진입 루트만 갤러리에 남긴다는 위 계약은 장면 당시
> 24주 후보·금액·선택 영수증도 함께 동결해야 새 게임과 25주 이후에 빈 문장이나
> 8개 전부 노출 없이 재생된다. 그래서 `MetaProgression.gd`와
> `default_meta.json`을 장면별 읽기 전용 재생 스냅숏 저장에 한해 배치 A에
> 추가한다. ORDER-75 이전 Week-24 중간 저장의 옛 결정 루트도 기존
> `DemoCoreLoopV2.gd`·`StoryMode.gd` 안에서 새 opening→decision→ledger 계약으로
> 보정하며, `SaveManager.gd`나 저장 버전·게임 진행 수치는 바꾸지 않는다.

## 깊이 3문

1. 지우면 24주 종료는 1이벤트 카드로 끝나 24주의 선택을 결산하지 못한다.
2. 고른 청구서와 미룬 의무는 27·28·48주에 서로 다른 영수증으로 돌아온다.
3. 아버지·재직/지원·합법 인물 약속·무직 생계·휴식이 금요일 한 자리를 경쟁한다.

## 배치 A — 1년 결말을 침범하지 않는 깊은 연속 피날레

- 기존 8개 선택 인덱스·효과·의무/지원 영수증을 보존한다.
- `압박과 실제 영수증을 펼침 → 하나를 골라 실행하고 미룬 것을 함께 적음 →
  수첩을 덮고 다음 달을 남김`을 **한 번 들어가 끝까지 읽는 한 장면**으로
  만든다. 48주 보스·1년 결말은 대체하지 않는다.
- 비트·링크·패널·표현 선택 수를 먼저 정하지 않는다. 아래 기능이 요약 카드로
  생략되지 않을 때까지 쓴다.
  - 금요일 17시 52분의 몸·책상과 실제 1~24주 영수증
  - 지금 경쟁하는 의무가 도착하고 민준이 현재 상태를 드러내는 상호작용
  - 현금·몸·사람의 실제 비용과 하나를 끝내면 닫히는 길의 비교
  - 기존 8방향 중 하나의 결정과 실제 행동·효과·영수증
  - 끝낸 일과 미룬 일을 같은 수첩에 적는 경로별 반응
  - 수첩을 덮고 토요일 현수 시험과 25주의 질문으로 남기는 여운
- 표현 선택은 자연스러운 질문이 있을 때만 넣고 수치·호감도·Moral Tint·영구
  플래그 없이 고유한 대답·지문 뒤 공통 척추로 합류한다. 실제 연락 자격이 없는
  인물을 발신자로 만들지 않는다. 상태를 바꾸는 선택은 기존 8방향 중 하나의
  결정이 소유한다.
- 구현 노드가 여러 개여도 중간 제목·입장 전환·대화 로그·장소·음악을 불필요하게
  다시 시작하지 않는다. 짧은 독립 카드 여러 장으로 분해하면 실패다.
- 실제 `candidate_ids`만 증거·선택·후일담에 쓴다. 후보가 아닌 사람·서류·약속을
  산문에 발명하지 않고, 도시 작업표와 야간 대타처럼 시간이 지나 사라진 길은
  단순한 `미룸`이 아니라 `마감을 놓친 일`로 구분한다.
- 체력 5에서 `urgent_paid_shift`로 건강 0이 되는 기존 번아웃 경로만 공통
  수첩·토요일·25주 여운에 합류시키지 않는다. 그 밖의 생존 경로는 같은 후일담이
  실제 선택·미선택 영수증을 읽는다.

## 배치 B — 전용 연출 자산과 계약

- 책상 클로즈업과 민준 결정 연기 초상을 제작·등록하고 기존 실녹음
  `paper_handle`·`pen_write`를 정확한 행동 비트에 연결한다.
- `CHOICE_CONSEQUENCE_SYSTEM.md`의 표현·기억·결정 분류를 첫 데모 피날레
  프로필로 검증한다. 표현 선택을 수치로 위장하지 않고, 기존 선택·미선택
  영수증만 장기 인과를 소유한다.

## 완료 증거

- 모든 경로가 위 장면 기능과 한 장면 연속성을 충족하며 독립 1링크 카드 연속 `0`
- 표현 선택을 쓴 경로: 선택별 고유 반응 PASS, 신규 수치/플래그 `0`
- 표현 선택 전후 `GameState.serialize()` diff `0`, V2 영수증·주간 약속 diff `0`
- 기존 8선택 효과/영수증 diff: `0`
- 모든 경로의 공통 후속이 실제 선택·미선택 영수증을 읽음
- 신규 자산 continuity/계약/KO·EN 렌더: PASS
- 링크·패널·정상 독해 시간은 관측값으로 보고하고, 완결감·몰입·재미는 사람
  게이트에서 판정한다. 승인된 관측값만 이후 축약을 막는 장면별 래칫이 된다.
