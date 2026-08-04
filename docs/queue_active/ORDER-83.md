# Active Queue Spec: ORDER-83

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-83 [P0·서사] 3·4개월차의 얕은 결과를 깊은 생활 장면과 5년 기억으로 바꾼다

**사용자 근거 (2026-08-04):** “한 편의 소설, 영화 수준”은 문장 수나 사건 수를
늘리라는 뜻이 아니라 지금까지의 피드백 전체를 가리킨다. 여러 개의 1비트
결과 카드보다 하나의 사건이 깊어야 하고, 평범한 대답은 장면 안에서만 달라질
수 있지만 기억할 만한 선택은 1년과 5년 뒤에 다시 의미를 가져야 한다.

**정본 근거:** `SCENE_TIER.md` §0·§2의 한 체인=한 장면과 T2 계약,
`CHOICE_CONSEQUENCE_SYSTEM.md`의 표현/기억/결정 분리,
`CORE_LOOP_V2.md`의 월별 생활 질문을 그대로 따른다. 비트·링크·선택 개수의
공통 목표는 만들지 않는다.

> 배치 A — 3개월차 `m3_room_ledger`의 일반 결과 카드를 `방 안의 장부`
> 연속 장면으로 넘긴다. 각 금액 옆에 이유까지 적을지, 합계만 먼저 맞출지 고른
> 기억을 24주·48주·2장·5장이 서로 다른 맥락에서 읽는다.
>
> 배치 B — 4개월차 `m4_housing_welfare_consultation`을 주거복지 상담사와
> 실제로 방의 기준을 정하는 연속 장면으로 넘긴다. 이사 뒤 잔액·닫을 수 있는
> 문·생활 동선 중 무엇을 먼저 지킬지 고른 기억을 첫 이사·1년·마지막 주가
> 읽는다. 새 상담사 초상과 기존 공공기관 앰비언스·종이 폴리를 결합한다.

## 깊이 3문

1. 지우면 3·4개월차의 합법 계획에서 수치 카드만 보고 한 달을 넘기는 경로가
   다시 남고, 사용자가 지적한 조잡한 1비트 배열을 수량으로 가릴 수 있다.
2. 두 장면은 돈을 계산하는 방식과 집을 고르는 기준을 각각 물어 같은 생활
   문제를 반복하지 않으며, 1장 안의 회수와 2·5장의 변주를 함께 만든다.
3. 기존 액션의 효과·AP·저장 영수증은 한 번만 적용하고 장면은 그 결과의
   의미만 소유하므로 밸런스나 저장 스키마를 바꾸지 않고 몰입 결손을 수리한다.

## 구현 계약

- 두 번들만 `action_result_presentation: story_owned`로 opt-in한다. 액션 성공
  직후 일반 결과 제목·본문·로그·비네트를 띄우지 않고 StoryMode로 인계한다.
  오래된 결과 대기 저장도 액션을 재적용하지 않고 장면으로 들어가며, 이미
  완료한 저장에는 장면이나 기억을 소급 발명하지 않는다.
- 장면 선택은 전부 `choice_kind: memory`다. 능력치·현금·관계·도덕색·route
  효과를 넣지 않는다. 기존 번들 효과만 정확히 한 번 적용한다.
- 3개월차는 `m3_ledger_reasons_named` 또는 `m3_ledger_totals_only`, 4개월차는
  `m4_housing_priority_runway`·`m4_housing_priority_privacy`·
  `m4_housing_priority_time` 중 정확히 하나만 남긴다. 별도 `*_seen`은 만들지
  않는다.
- 3개월차 독자는 `v2_demo_first_bill_ledger`, `arc_year1_close`,
  `arc_34_money_attracts_money`, `arc_final_countdown`이다. 4개월차 독자는
  `arc_housing_new_life`, `arc_year_one_mark`, `arc_final_week`이다. 기존 엔딩의
  우선순위 분기를 덮지 않도록 `description_memory_if_known`만 사용한다.
- 한국어를 원문으로 쓰고 영어는 동일 ID·선택 구조의 자연스러운 각색으로
  맞춘다. 일본어·중국어 본문은 생성하지 않고 준비 범위의 수·해시만 현재
  데모와 일치시킨다.
- 두 진입 장면은 T2다. 3개월차는 현재 방 배경·민준 초상, 4개월차는 정본
  주민센터 배경·신규 B급 상담사 초상을 쓴다. 장소 앰비언스와 종이/펜 폴리,
  전환 의도와 큐 시점을 등록한다.

## 착수 소유권

- 런타임·편성: `content/meta/demo_core_loop_v2.json`,
  `systems/DemoCoreLoopV2.gd`, `scenes/MainGame.gd`.
- 원고·장기 독자: `content/events/core_loop_v2_events.json`,
  `content/events/arc_year_close.json`, `content/events/arc_chapter_themes.json`,
  `content/events/arc_pre_ending.json`, `content/events/arc_midgame.json`,
  `content/events/arc_drama.json`과 같은 이름의 `content/events_en/` 여섯 파일.
- 기억·출시 계약: `content/meta/narrative_spine.json`,
  `content/meta/story_rules.json`, `content/meta/exposed_event_state_contracts.json`,
  `content/meta/demo_localization_scope.json`,
  `content/meta/release_content_inventory.json`, `docs/I18N_INFRASTRUCTURE.md`,
  `docs/I18N_GLOSSARY_ZH.md`, `docs/QA_CHECKLIST.md`,
  `docs/human_gates.json`, `docs/AUDIO_QA.md`, `tools/audit_scope.json`,
  `tools/ja_translation_pipeline.py`.
- 자산·연출: `assets/characters/npc_housing_counselor.png`와 생성되는 `.import`,
  `autoloads/ImageRegistry.gd`, `assets/ASSET_INDEX.md`, `assets/IMAGE_PROMPTS.md`,
  `assets/cast_detail_manifest.json`, `content/meta/cast_visual_years.json`,
  `assets/mod_asset_manifest.json`, `assets/event_visual_contracts.json`,
  `assets/scene_audio_manifest.json`, `assets/scene_direction_manifest.json`,
  `tools/art_resolution_baseline.json`, `docs/MODDING.md`,
  `docs/ART_AI_AUDIT.md`.
- 회귀: `tools/demo_core_loop_v2_audit.py`, `tools/CoreLoopV2BCheck.gd`,
  `tools/CoreLoopV2CCheck.gd`, `tools/CoreLoopV2DCheck.gd`,
  `tools/CoreLoopV2ECheck.gd`, `tools/ScreenshotQA.gd`,
  `tools/event_director_audit.py`.
- 정본·완료 증거: `docs/CORE_LOOP_V2.md`, `CLAUDE.md`,
  `docs/CODEX_QUEUE.md`, `docs/DEMO_FIXLOG.md`, `docs/WORK_LOG.md`,
  `docs/history/WORK_LOG_2026-07-30.md`, `docs/STATUS.md`,
  `docs/RELEASE_NOTES.md`, `docs/CONTENT_RATING_INVENTORY.md`,
  `docs/queue_active/ORDER-83.md`,
  `docs/queue_archive/ORDER-83.md`.

## 비범위

- W8 위험 선택의 Pareto 우세 수리, 다른 42개 장기 선택과 아버지 기억,
  30억 조기 엔딩과 공통 에필로그, 다른 월의 얕은 결과, 효과 수치·경제 밴드,
  저장 스키마, finish_run·출시 기본 경로는 건드리지 않는다.
- 장면 개수·비트 개수·독해 시간을 전역 목표로 만들지 않는다. 이번 두 장면의
  실측치는 사람 승인 뒤 해당 장면만의 축약 방지 기준선으로 남긴다.

## 검증과 사람 판정

- L1: JSON·한영 구조·기억 producer/reader·액션 효과 1회·구 저장 복구·24주
  도달·현지화 범위·자산/연출/오디오 계약·전체 감사·CI를 통과한다.
- L2: 한국어 번역투, 화자 지식, 금액·날짜·주거 단계, 장면 내 시간·장소,
  1년/5년 회수의 반복 아닌 재해석을 교차 검토한다.
- L3: 사용자는 ① 3개월차 장부 장면이 수치 카드가 아니라 한 번의 경험으로
  남는지, ② 4개월차 상담과 후대 회상이 같은 선택을 다른 의미로 돌려주는지
  두 표본을 정상 속도로 판정한다. 자동 PASS를 재미 합격으로 부르지 않는다.

## 완료 조건

- 두 번들의 일반 결과 카드는 보이지 않고 액션·AP·효과·번들 완료가 모든 저장
  경계에서 정확히 한 번이다.
- 다섯 기억 플래그는 각 장면에서 상호 배타적으로 생산되고 명시한 1년·5년
  독자가 중립적인 옛 저장 fallback과 함께 읽는다.
- KO/EN 24주 완주와 좁은 화면 표본, 전체 감사와 원격 CI가 초록이다. 자동
  증거와 남은 사람 판정을 분리해 기록하고 사양을 아카이브한다.
