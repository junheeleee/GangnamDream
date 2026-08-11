# Active Queue Spec: ORDER-96

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-96 [P0·현지화 기반] LOC-0 — 다의 한국어 UI 키를 안정 문맥 ID로 분리한다

**선행 조건 완료 (2026-08-11):** `ORDER-88`은 `[x]`로 닫히고
`docs/queue_archive/ORDER-88.md`로 내렸다. 이 `[~]` 전환은 구현과 분리한
착수 선언이며, 아래 정확한 파일 소유권 밖으로 범위를 늘리지 않는다.

`docs/I18N_INFRASTRUCTURE.md`와
`content/meta/demo_localization_scope.json`이 잠근 현재 실측은 UI source pair
3,254회·한국어 소스 키 2,730개다. 같은 한국어 키에 여러 영어 값이 붙은 107키는
formatting-only 34·semantic allowlist 45·문맥 분리 28이며, 마지막 28키는 아래
30개 ID·37호출로만 이동한다. 한국어 소스 키 SHA-256
`b67df90ba814deeac78db1b1bc4836d16596b6b93521e97a34427ae3b2bcb222`를
바꾸지 않는다. 기존 2,730키를 삭제·이름 변경하지 않는다.

## 깊이 3문

1. 지우면 JA·zh-CN·zh-TW가 `기록=Log/Archive/Record`, `생활=Life/Living/
   Lifestyle`처럼 다른 뜻을 한 행으로 강제 공유해 오역을 피할 수 없다.
2. 이 오더는 플레이 선택이나 24주 상태를 바꾸지 않는다. KO/EN은 원래 두 인자를
   그대로 보여야 하며, 달라지는 것은 준비 언어가 정확한 문맥 번역을 고르는가뿐이다.
3. 같은 자리에서 문맥 정확성과 2,730개 legacy 키·기존 community pack 호환이
   경쟁한다. 문맥 ID를 추가하되 legacy fallback을 제거하거나 본문 번역을 열지 않는다.

## 고정 문맥 원장 — 30 ID / 37호출

줄 번호는 이 사양 작성 시점의 증거 앵커다. 줄이 이동해도 `ID + path::function +
KO/EN 인자`가 계약이다. 37곳은 wrapper를 새로 만들지 않고
`LocaleManager.ui_context(id, ko, en)`를 직접 호출한다.

| # | stable context ID | KO / 허용 EN | 소유 callsite (현재 줄) |
|---:|---|---|---|
| 1 | `ui.credit.standard_grade` | `보통` / `Standard` | `autoloads/GameState.gd::get_credit_grade_label` (2969) ×1 |
| 2 | `ui.phone.title` | `연락` / `PHONE` | `scenes/CommunicationPhone.gd::_update_tab_copy_and_style` (348) ×1 |
| 3 | `ui.planner.skill_axis` | `지력` / `Skill` | `scenes/CoreLoopPlanner.gd::_routine_effect_copy` (2915) ×1 |
| 4 | `ui.planner.income_axis` | `생계` / `INCOME` | `scenes/CoreLoopPlanner.gd::_offer_kind_label` (3277) ×1 |
| 5 | `ui.planner.people_axis` | `관계` / `PEOPLE` | 같은 함수 (3285) ×1 |
| 6 | `ui.choice.noun_label` | `선택` / `OPTION`, `Choices`, `Choice` | `CoreLoopPlanner::_offer_kind_label` (3286) ×1; `MainGame::_reveal_choices` (8165, 8193) ×2 |
| 7 | `ui.holdem.setup_action` | `설정` / `Setup` | `scenes/HoldemClub.gd::_render_table` (493) ×1 |
| 8 | `ui.completion.unrecorded_value` | `기록 없음` / `NOT RECORDED` | `scenes/MainGame.gd::_core_loop_v2_completion_view_model` (2714, 2839, 2850, 2861) ×4 |
| 9 | `ui.tutorial.danger` | `위험` / `Danger` | `MainGame::_show_tutorial` (5582) ×1 |
| 10 | `ui.week.spent_status` | `주 종료` / `WEEK SPENT` | `MainGame::_ap_remaining_text` (8296) ×1 |
| 11 | `ui.situation.body_tag` | `건강` / `BODY` | `MainGame::_situation_category_tag` (10616) ×1 |
| 12 | `ui.situation.civic_tag` | `사회` / `CIVIC` | 같은 함수 (10624) ×1 |
| 13 | `ui.situation.event_fallback` | `상황` / `EVENT` | 같은 함수 (10630) ×1 |
| 14 | `ui.job.application_noun` | `지원` / `Application` | `MainGame::_action_echo_label` (10781) ×1 |
| 15 | `ui.action.creating_content` | `콘텐츠 제작` / `Creating content` | 같은 함수 (10804) ×1 |
| 16 | `ui.forgone.relationship_fallback` | `인연` / `the relationship` | `MainGame::_weekly_commitment_return_cost_text` (11682) ×1 |
| 17 | `ui.situation.life_tag` | `생활` / `Life` | `MainGame::_add_ap_section_header` (12076) ×1 |
| 18 | `ui.choice.keep_action` | `기억` / `KEEP` | `MainGame::_item_art_frame` (13814) ×1 |
| 19 | `ui.housing.now_status` | `현재` / `Now` | `MainGame::_open_cat_life` (14508) ×1 |
| 20 | `ui.housing.requirement_state` | `대기` / `Need` | 같은 함수 (14535) ×1 |
| 21 | `ui.gambling.venues_title` | `도박장` / `Gambling Venues` | `MainGame::_open_cat_gambling` (14599) ×1 |
| 22 | `ui.saving.activity_title` | `절약` / `Saving` | `MainGame::_ap_save_money` (14927) ×1 |
| 23 | `ui.result.gain_badge` | `성장` / `GAIN` | `MainGame::_ap_result_tone_label` (16672) ×1; `StoryMode::_story_result_tone_label` (4884) ×1 |
| 24 | `ui.job.entry_tier` | `입문` / `Entry` | `MainGame::_job_tier_label` (17244) ×1 |
| 25 | `ui.investment.warning_badge` | `주의` / `WARN` | `MainGame::_open_first_investment_guide` (18286) ×1 |
| 26 | `ui.meta.career_category` | `직업` / `Career` | `MainGame::_open_title_collection` (22474) ×1 |
| 27 | `ui.meta.lifestyle_category` | `생활` / `Lifestyle` | 같은 함수 (22475) ×1 |
| 28 | `ui.navigation.archive` | `기록` / `Archive`, `ARCHIVE` | `scenes/StartMenu.gd::_build_ui` (579) ×1; `_open_archive_overlay` (932) ×1 |
| 29 | `ui.archive.previous_page` | `이전` / `Previous` | `StartMenu::_open_archive_overlay` (987) ×1 |
| 30 | `ui.archive.record_fallback` | `기록` / `Record` | `StartMenu::_archive_scene_card` (1240) ×1 |

파일별 호출 수는 `GameState 1 + CommunicationPhone 1 + CoreLoopPlanner 4 +
HoldemClub 1 + MainGame 25 + StartMenu 4 + StoryMode 1 = 37`이다. 표에 없는
`기록/Log`, `생활/Living`, `선택/Choose·Select`, `성장/Growth`, `기록 없음/No
record` 등은 legacy 조회에 남긴다. 37곳 밖을 편의상 이동하면 실패다.

## lookup·community pack 호환 계약

`LocaleManager.ui_context(context_id, ko_text, en_text)`를 추가한다.

- `ko`는 `ko_text`, `en`은 `en_text`를 그대로 반환한다. 기존 `ui(ko,en)`의
  동작과 모든 기존 호출은 바꾸지 않는다.
- 준비 언어의 우선순위는 **community context ID → community 한국어 legacy 키 →
  built-in context ID → built-in 한국어 legacy 키 → 영어 인자**다.
- 현재처럼 built-in과 community 표를 먼저 합치면 built-in context가 구형 pack의
  legacy override를 가리므로 두 provenance를 `LocaleManager`가 분리 보관한다.
- context와 legacy가 모두 없을 때만 영어를 반환하고 `context:<id>`로 miss를
  dedupe한다. legacy fallback 성공과 explicit context 미보유는 정적 pack 감사가
  구분한다. community refresh는 새 표와 miss cache를 모두 비운다.
- context ID는 기존 `ui_<code>.json` 안에 둔다. `ModLoader.gd`, pack 경로,
  스키마 버전은 바꾸지 않는다.

## 배치 A — 15단위: 계약·loader·감사 기반

`A01` manifest 원장, `A02` built-in/community 표 분리·refresh, `A03` KO/EN 직접
반환, `A04` 5단계 lookup, `A05` context miss, `A06` 두 API source collector,
`A07` 107키 exact partition, `A08` 30-ID/37-call 감사, `A09` JA 2계층 coverage,
`A10` ZH 2계층 coverage, `A11` JA mutation self-test, `A12` ZH mutation self-test,
`A13` 런타임 locale 검사, `A14` legacy/new community pack 검사, `A15` 지속 정본
문서 승격을 각각 독립 판정한다.

이 배치가 끝나도 호출은 아직 이동하지 않는다. manifest는 formatting-only 34,
semantic allowlist 45, split 28의 exact·서로소·합집합 107과 각 context 행의
ID/KO/허용 EN/path/count를 소유한다. collector는 legacy 2인자와 context 3인자를
함께 읽는다.

## 배치 B — 15단위: 30 ID를 제품 표면에 적용

각 단위는 위 표의 두 연속 ID와 해당 callsite·JA 행만 소유한다:
`B01=1~2`, `B02=3~4`, `B03=5~6`, `B04=7~8`, `B05=9~10`, `B06=11~12`,
`B07=13~14`, `B08=15~16`, `B09=17~18`, `B10=19~20`, `B11=21~22`,
`B12=23~24`, `B13=25~26`, `B14=27~28`, `B15=29~30`.

JA는 기존 한국어 키 2,730개를 그대로 두고 의미에 맞는 비어 있지 않은 context
행 30개를 추가해 총 2,760행으로 만든다. KO/EN 화면 문구는 byte-for-byte
동일해야 한다. zh-CN·zh-TW 사전은 이번 오더에서 빈 skeleton을 유지한다.

## 정확한 파일 소유권

**제품·데이터 10:** `autoloads/LocaleManager.gd`, `autoloads/GameState.gd`,
`scenes/CommunicationPhone.gd`, `scenes/CoreLoopPlanner.gd`,
`scenes/HoldemClub.gd`, `scenes/MainGame.gd`, `scenes/StartMenu.gd`,
`scenes/StoryMode.gd`, `locale/ui_ja.json`,
`content/meta/demo_localization_scope.json`.

**감사·테스트 7:** `tools/ja_translation_pipeline.py`,
`tools/ja_translation_audit.py`, `tools/zh_translation_audit.py`,
`tools/I18nInfrastructureCheck.gd`, `tools/ModLayerCheck.gd`,
`tools/ScreenshotQA.gd`, `tools/english_hangul_audit.py`. 새 문맥 API도 기존
영어 무한글 감사에서 `_tr`/`LocaleManager.ui`와 같은 안전한 KO/EN 쌍으로
인식한다. 일본어 실제 표면을 기존 core-loop scope로 실행할 때
제품의 `선택 중` 번역을 QA가 `선택 중 ·`이라는 다른 lookup key로 비교하던
오탐만 제품과 같은 key로 맞춘다.

**지속 정본·사람 게이트 7:** `docs/I18N_INFRASTRUCTURE.md`, `docs/I18N_GLOSSARY_JA.md`,
`docs/I18N_GLOSSARY_ZH.md`, `docs/MODDING.md`, `docs/QA_CHECKLIST.md`,
`docs/DECISIONS.md`, `docs/human_gates.json`. 문맥 UI 분모를 추가하면서 기존
JA·zh-CN·zh-TW 사람 판정의 strict 선행조건에도 `context 30/30`을 명시한다.
선언·완료 기록은 `docs/CODEX_QUEUE.md`, 이 사양,
`CLAUDE.md`, 완료 뒤 `docs/WORK_LOG.md`와 8월 큐 archive만 만진다.

기존 `audit.sh`와 `audit_scope.json`은 위 검사·경로를 이미 배선하므로 새 전용
도구를 만들지 않는 최소안에서는 수정하지 않는다. `ModLoader.gd`, 중국어 UI
skeleton, `multilingual_surface_audit.py`, `i18n_coverage_check.py`,
`demo_localization_scope.py`, 사건·엔딩·catalog도 수정하지 않는다.

## 비범위

- JA·zh-CN·zh-TW 사건 본문·동적 UI·엔딩·catalog 번역과 `--allow-body` 해제
- 중국어 UI 행 생성, 새 폰트, locale 노출, Steam 언어 표기 변경
- 한국어·영어 카피 수정, 이벤트/선택/수치/플래그/세이브/게임플레이 ID 변경
- community pack 강제 마이그레이션, 기존 2,730키 제거, 새 locale 파일 포맷
- 문맥 표 밖 다의 키 정리, UI 리팩터링, `MainGame.gd` 이사

## 검증·완료 조건

- L1 source 원장은 migration 뒤 `legacy API 3,217 + context API 37 = 3,254`,
  고유 한국어 키 2,730, 다중 EN `34+45+28=107`, context `30/37`, 위 SHA 불변이다.
  overlap·누락·stale allowlist·unknown/duplicate/unreferenced ID는 실패한다.
- JA UI는 `legacy 2,730/2,730 + context 30/30`, unknown 0, 한글·엔/엔화·token·
  newline 오류 0이다. ZH skeleton은 각각 `0/2,730 + 0/30`을 숨김 준비 상태로
  보고하고 strict는 번역 전 계속 실패해야 한다.
- `I18nInfrastructureCheck`가 KO/EN 동일, built-in hit, legacy fallback,
  context miss→EN·reset을 증명한다. `ModLayerCheck`가 구형 legacy pack 우선과
  신형 explicit context 우선을 모두 증명한다.
- `demo_localization_scope.py --self-test/--lang all`의 본문 원장
  `471/657/4/0`, body hold, `SHIPPING_LANGUAGES=KO/EN`은 불변이다.
- 좁은 순서는 JA UI inventory/self-test/audit → ZH skeleton/self-test → 두 Godot
  검사 → demo scope → multilingual audit다. 그 뒤 context manifest, queue
  consistency, 전체 audit, EN coverage, `git diff --check`를 통과한다.
- P1 실제 JA 화면은 기존 `--qa=core-loop-v2`, `--qa=gallery`, `--qa=story-en`을
  1280×800에서 캡처한다. 합성 `i18n-layout`만으로 합격시키지 않는다.
- L2는 30개 JA 행이 표의 실제 명사·동작·badge 문맥을 보존하는지 전수 재독한다.
  L3는 사용자가 임의 3개 실제 표면을 보고 하나라도 문맥이 틀리면 배치 B 전량을
  반려한다. 자동 초록은 원어민 승인이나 shipping GO가 아니다.
- 지속 규칙은 위 여섯 정본에 승격하고, 30행 migration·두 배치 실행 지시는
  일회성으로 판정한 뒤 사양을 archive한다.
