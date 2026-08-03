# Archived Queue Spec: ORDER-75

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [x] ORDER-75 [P0·정점] 24주 첫 청구서를 데모 전용 T1으로 완성한다

**사용자 승인 (2026-08-03):** `PROPOSALS.md` P-3의 데모 T1 등록과 기존
8방향 선택·효과·영수증 보존 범위는 승인됐다. P-3의 고정 비트 수는 이후
사용자 지시가 폐기했으며, 숫자 할당량 없는 한 편의 깊은 연속 장면으로 진행한다.

> 착수 — 새 진입 루트와 필요한 내부 링크만 추가한다. 기존
> `v2_demo_first_bill`은 8방향 결정과 27·28·48주 영수증을 계속 소유한다.
> 구현 링크에는 같은 제목·로그·음악을 유지하고, 선택한 행동의 실제 이동에는
> 경로에 맞는 배경·앰비언스를 쓴 뒤 장부 책상으로 돌아오며
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
> `scenes/StoryMode.gd`, `scenes/StartMenu.gd`, `tools/audit.py`,
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
> 실제 회상 카탈로그가 고정 목록을 쓰므로 `StartMenu.gd`도 진입 루트 한 건의
> 등록에 한해 포함한다. 회상은 스냅숏에 남은 후행 루트만 복원하고 현재 런 HUD를
> 섞지 않으며, 읽기 전용 대체 선택의 장부·치명 결과도 로컬에서 재현한다.

> 범위 정산 (2026-08-04) — 한빛 채용 선택의 25주 이후 요약도 17주 수락
> 영수증과 현재 `job_03`을 함께 읽어야 피날레·장부·48주 인계가 같은 사실을
> 말한다. 그래서 `scenes/MainGame.gd`의 해당 요약 판정만 보강했다. 새 밸런스나
> 진행 경로는 추가하지 않았다. 같은 계약을 직접 검사하는
> `tools/CoreLoopV2DCheck.gd`, `tools/GameAudioContractCheck.gd`,
> `tools/event_director_audit.py`와 장기 규칙의 소유자인 `docs/DECISIONS.md`,
> 데모 전용 T1 지위를 보존하는 `docs/SCENE_TIER.md`도 종료 범위에 포함했다.
> 이 범위 보강 밖의 MainGame 이사나 엔딩 라우팅은 없다.

## 완료 결과 (2026-08-04)

- 플레이어에게 보이는 진입은 `첫 청구서 / The First Bill` 한 건이다. 금요일
  17:52 책상에서 시작해 선택한 행동의 실제 장소와 시간으로 이동한 뒤 같은
  수첩 장부로 돌아온다. 내부 opening→decision→ledger는 제목·대화 기록·BGM을
  새 장면처럼 재시작하지 않고, 경로별 배경·앰비언스는 실제 행동을 따른다.
  갤러리와 올해의 장면에는 opening 하나만 남는다.
- opening에서 고르는, 상태를 바꾸지 않는 표현 선택지 세 가지는 각각 고유한 민준의 행동·생각 뒤 공통
  척추로 합류한다. 직렬화 상태, 주간 약속, V2 영수증의 전후 차이는 모두 0이다.
- 기존 여덟 결정 인덱스·효과·의무 영수증은 그대로다. 실제 경로에서는 현재
  자격에 맞는 2~4개 후보만 비교하고, 선택한 일·미룬 약속·18:00에 마감된 일을
  다른 사실로 장부화한다. 체력 0 경로만 장부와 토요일 여운을 건너뛴다.
- 경로별 노출 표면은 후보 구성에 따라 13~14개였다. 원문 길이 기반 정독 추정값은
  취업+다은 경로 KO 5.24~5.34분 / EN 3.83~3.90분, 무직+재혁 경로
  KO 4.52~4.61분 / EN 3.42~3.49분, 상철 경로 KO 4.17~4.27분 /
  EN 3.22~3.29분이다. 이는 분량 할당량이나 재미 합격값이 아니다.
- 새 책상 클로즈업과 결정 연기 초상, 종이·펜 폴리를 장면의 실제 동작에
  연결했다. KO 960×600과 EN 1280×800에서 결정·완료 장부·유예 장부를
  렌더해 잘림과 한글 누출이 없음을 확인했다.
- 완료 시점의 후보·금액·몸·관계·미선택 의무를 32KiB 제한의 JSON-safe
  스냅숏으로 동결한다. 회상은 현재 런을 바꾸지 않으며 다른 선택과 치명 경로도
  로컬에서 재현한다. 옛 24주 중간 저장은 opening→decision→ledger로 원자적
  보정하고, 복원 불가능한 옛 완료 저장에는 거짓 스냅숏을 합성하지 않는다.
- `CoreLoopV2ECheck`, `CoreLoopV2DCheck`, `CoreLoopV2HandoffCheck`,
  `ManualSaveCheck`, `BGMContinuityCheck`, `GameAudioContractCheck`,
  `ModLayerCheck`, 사건·장면·오디오·출시 인벤토리 감사와 전체 프로젝트 감사를
  통과했다. 자동 PASS는 정상 속도 몰입·재미·연속 청취 사람 판정을 대신하지 않는다.

## 규범 판정

- **승격:** `docs/CORE_LOOP_V2.md`의 6개월 정점·현재 구현·E/F 절은 단일 진입,
  후보 근거, 장부·치명 경로·회상·실입력 게이트를 소유한다.
- **승격:** `docs/SCENE_TIER.md`의 정점 소유 표는 첫 청구서를 48주 1장 보스와
  구분되는 24주 데모 전용 T1으로 소유한다.
- **승격:** `docs/CHOICE_CONSEQUENCE_SYSTEM.md`의 장면 안 선택 배분 절은
  표현 선택과 첫 청구서의 결정 영수증 분리를 소유한다.
- **승격:** `docs/DECISIONS.md`는 정점 제목의 상징성 예외와 유저 표면에서
  관찰 가능한 몸·행동을 직접 쓰는 산문 규칙을 소유한다.
- **승격:** `assets/FIRST_BILL_VISUAL_BIBLE.md`는 전용 책상·초상과 크롭·연속성
  계약을 소유한다.
- **일회성:** 세 내부 조각 이름, 여덟 기존 인덱스, 위 관측 링크·독해 시간,
  정확한 테스트 fixture와 파일 배치는 이 구현을 닫기 위한 증거이지 다른
  장면의 공통 할당량이 아니다.

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
