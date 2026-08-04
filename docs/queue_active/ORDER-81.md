# Active Queue Spec: ORDER-81

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-81 [P1·현지화 준비] 실제 24주 일본어 범위와 영어 우회 경로를 먼저 잠근다

**사용자 근거 (2026-08-04):** “한 편의 소설, 영화 수준”은 분량 지시가 아니라
지금까지의 피드백 전체를 묶는 작품 기준이다. 번역도 키 개수만 채우는 일이
아니라 한국어 정본의 인물 목소리·관계 거리·함축·돈의 체감·선택 인과를 같은
장면 안에서 보존해야 한다. 사용자는 데모 뒤 시간과 토큰이 남으면 일본어와
중국어를 24주 데모까지 준비하라고 했지만, 번역 본문을 출시 승인하지는 않았다.

> 배치 A — 실제 24주 범위·런타임·자동 게이트:
> `content/meta/demo_localization_scope.json`,
> `content/meta/release_content_inventory.json`,
> `content/events_ja/story_events.json`,
> `autoloads/LocaleManager.gd`, `autoloads/GameState.gd`,
> `autoloads/ImageRegistry.gd`,
> `scenes/MainGame.gd`, `scenes/StoryMode.gd`,
> `scenes/CoreLoopPlanner.gd`, `scenes/CommunicationPhone.gd`,
> `scenes/OpeningCinematic.gd`,
> `tools/demo_localization_scope.py`, `tools/release_content_inventory.py`,
> `tools/ja_translation_pipeline.py`, `tools/audit.sh`,
> `tools/audit_scope.json`.
>
> 배치 B — 일본어 준비 정본·사람 판정·완료 기록:
> `docs/I18N_GLOSSARY_JA.md`, `docs/I18N_INFRASTRUCTURE.md`,
> `docs/QA_CHECKLIST.md`, `docs/human_gates.json`,
> `CLAUDE.md`, `docs/CODEX_QUEUE.md`, `docs/DEMO_FIXLOG.md`,
> `docs/WORK_LOG.md`, `docs/RELEASE_NOTES.md`, `docs/STATUS.md`,
> `docs/queue_active/ORDER-81.md`, `docs/queue_archive/ORDER-81.md`.

`locale/ui_ja.json`의 대량 동적 문구와 `content/events_ja/**`의 새 본문은 만들지
않는다. 현재 존재하는 일본어 행의 정본 용어 오류만 정확히 수리할 수 있다.
`SHIPPING_LANGUAGES`, 첫 실행 언어 선택, Steam 메타데이터는 KO/EN 그대로 둔다.

## 깊이 3문

1. 지우면 정적 UI 2,544키 통과를 실제 24주 일본어 완성으로 오인하고 계획판과
   연락폰에 수백 개 영어 문장을 남긴다.
2. 모든 합법 선택의 도달 합집합과 동적 한영 쌍을 먼저 고정하면 한 자동 경로에
   안 나온 장면을 번역에서 누락하지 않고, 본편 25~240주를 잘못 번역하지 않는다.
3. 런타임 우회와 추출 결손을 먼저 고치는 것은 원고·밸런스·선택 효과를 바꾸지
   않으면서 이후 번역과 원어민 검수를 재현 가능하게 만든다.

## 배치 A — 실제 24주 범위와 준비 언어 경로

- 새 게임의 프롤로그 즉시 연결, 필수 Chapter 1 카드, V2 1~24주 모든 bundle,
  narrative-spine 전경 root, 런타임 동적 root, 선택의 즉시 follow-up을 합쳐
  도달 사건을 계산한다. `suppress_follow_up_events`는 그대로 적용한다.
- 실제 범위는 현재 관측값 `프롤로그 12 + Chapter 1 1 + W1~24 57 = 70`이며,
  숫자를 수동 목록으로만 믿지 않고 실행 정본에서 매번 재계산한다. 24주 CTA는
  `finish_run` 엔딩이 아니므로 데모 번역 범위의 ending은 0이다.
- 70사건의 번역 가능한 텍스트 경로와 `demo_core_loop_v2.json`의 모든
  `*_ko/*_en` 쌍, 오프닝 시네마의 6개 쌍을 원본 경로·해시와 함께 잠근다.
  같은 한국어 키의 반복과 영어 불일치는 별도로 검사한다.
- 준비 언어가 `LocaleManager.is_english()`로 곧바로 영어 값을 고르는 데모 경로를
  `LocaleManager.ui(ko, en)` 단일 폴백으로 모은다. 번역 키가 없으면 지금처럼
  영어를 보이되, 키를 채운 뒤에도 영어로 우회하는 구조는 남기지 않는다.
- 번역 파이프라인은 `description_memory_if_known`와 선택 `bridge_summary`를
  포함한 허용 텍스트 필드를 모두 추출한다. 조건·효과·flags·후속 라우팅·수치
  필드는 번역 오버레이에 복사하지 않는다.
- 기본 준비 감사는 구조·source drift·숨김 상태·기존 번역 행의 정합을 실패시키고,
  미번역 수는 명시적으로 보고하되 현재 KO/EN CI를 막지 않는다. 언어별
  `--strict`는 70사건·동적 표면 완전성·영어 우회 0을 요구해 번역 전에는 의도대로
  실패한다. 자체 변이 검사가 누락 사건·동적 쌍·잘못된 선택 구조를 각각 잡는다.

## 배치 B — 작품 번역 게이트

- 정적 UI 실제값과 24주 사건·동적 표면 준비율을 서로 다른 숫자로 기록한다.
  “UI 통과”를 “데모 번역 통과”로 부르지 않는다.
- 일본어는 영어 중역이 아니라 한국어 원문과 직접 대조한다. 다은·지연·현수·
  상철·아버지의 호칭과 말투뿐 아니라 대답 뒤의 거리 변화, 생계 금액, 유혹의
  귀속, 장면 끝 여운을 원어민이 문맥 안에서 판정한다.
- 자동 완전성 뒤에도 실제 24주 정상 속도, 합법 선택의 미통과 장면 replay,
  계획판·세로 연락폰·대화 기록·첫 청구서·CTA 화면 검수가 남는다. 사람 판정은
  `human_gates.json`에 `claim:ja-demo` 범위로 기록해 KO/EN 데모 출시는 막지 않는다.
- 현재 본문 생성 보류와 일본어 비노출 상태를 유지한다. 본문 번역은 사용자의
  명시적 데모 GO 뒤 별도 오더에서만 연다.

## 검증

- `python3 tools/demo_localization_scope.py --self-test`
- `python3 tools/demo_localization_scope.py --lang all`
- `python3 tools/release_content_inventory.py --self-test`
- `python3 tools/ja_translation_audit.py --scope ui`
- `python3 tools/i18n_coverage_check.py --lang ja`
- `python3 tools/context_manifest_check.py`
- `python3 tools/queue_consistency_check.py`
- `GODOT=<경로> ./tools/audit.sh`
- `git diff --check`

## 증거 양식

- `DEMO_I18N_SCOPE events=<n> strings=<n> endings=0 dynamic_pairs=<n> dynamic_keys=<n>`
- `DEMO_I18N_COVERAGE lang=<code> events=<n>/<all> strings=<n>/<all> dynamic=<n>/<all> mode=<skeleton|strict>`
- `DEMO_I18N_ROUTE language=<code> translated_lookup=<n> direct_english_bypass=0 shipping=0`
- L3: 원어민이 한국어 원문과 같은 revision의 일본어 24주 문맥을 대조한 기록.
