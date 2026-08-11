# Gangnam Dream Context Index

Updated: 2026-08-11

이 문서는 “무엇이 정본인가”를 다시 설명하는 바이블이 아니라, 작업에 필요한 정본만 고르는 라우터다. 상세 규칙은 아래 소유 문서 한 곳에만 둔다. 기계 판독 버전은 `docs/context_manifest.json`이다.

## 최소 부팅

항상 읽기:

1. `CLAUDE.md`
2. `docs/CODEX_QUEUE.md`
3. 실제 착수할 `docs/queue_active/<ID>.md` 하나

그다음 아래 작업 프로필 하나를 선택한다. `docs/WORK_LOG.md`는 최근 항목만, `docs/DECISIONS.md`는 주제 검색 결과만 읽는다.

기본 로드 금지:

- `docs/history/`
- `docs/queue_backlog/`
- `docs/queue_archive/`
- `docs/archive/`
- `docs/RELEASE_NOTES.md` 전체
- `docs/STATE_LOG_ARCHIVE.md`
- 선택하지 않은 `docs/queue_active/*.md`

## 정본 소유자

| 영역 | 정본 | 역할 |
|---|---|---|
| 상품 정체성·현재 상태 | `CLAUDE.md` | 현재 목표와 불변 규칙. 실행 우선순위·상태는 `CODEX_QUEUE.md`만 소유 |
| 세계·인물·5장 서사 | `docs/STORY_BIBLE.md`, `docs/CANON_MAP.md` | 의도된 이야기와 세계 사실 |
| 선택·주간 루프 | `docs/CORE_LOOP_V2.md`, `content/meta/demo_core_loop_v2.json`, `docs/AP_REDESIGN.md`, `docs/GAME_RECOMPOSITION_PLAN.md` | 데모의 넓은 월간 약속·별도 세로 연락폰·관계 주도권, 기존 AP·Quiet/Echo 폴백 |
| 참조 시스템 판정 | `docs/REFERENCE_SYSTEM_VERDICTS.md` | 외부 참조 구조의 채택·보류·폐기, 기존 여력·노드·클록·영수증 부착 경계 |
| 선택·5장 결과 | `docs/CHOICE_CONSEQUENCE_SYSTEM.md` | 표현·기억·결정 선택, 영수증·사실·반복 패턴, 챕터 간 스노우볼과 엔딩 입력 |
| 인과·장소·대화 채널 | `content/meta/story_rules.json`, `docs/STORY_CONSISTENCY_SYSTEM.md` | 선행조건, 통화/기억, 장면 전환 |
| 관계·결혼 | `docs/ROMANCE_SYSTEM.md` | 호칭, 상호배타, 결혼·이별 |
| 밸런스 | `docs/BALANCE.md`, `autoloads/GameState.gd` | 의도 밴드와 현재 실행값 |
| MORAL_TINT | `docs/MORAL_TINT.md` | 숨은 변화의 의미와 표현 한계 |
| 영어·다국어 | `docs/I18N_GLOSSARY.md`, `docs/I18N_INFRASTRUCTURE.md` | 용어, 폴백, 출시 언어 |
| 아트 스타일 | `docs/GANGNAM_INK_ART_DIRECTION.md`, `docs/IP_VISUAL_IDENTITY.md` | 게임 고유 비주얼 언어 |
| 인물·공간 연속성 | `assets/CHARACTER_VISUAL_BIBLE.md`, `assets/*VISUAL_BIBLE.md`, `docs/ASSET_CONTINUITY_CHECKLIST.md` | 얼굴, 의상, 구조, 차량, 시선 |
| 사건별 비주얼 | `assets/event_visual_contracts.json`, `assets/cg_acting_manifest.json` | 실제 런타임 계약 |
| 오디오 | `assets/game_audio_manifest.json`, `assets/scene_audio_manifest.json`, `assets/audio/AUDIO_SOURCE_MANIFEST.json`, `docs/AUDIO_QA.md` | 키, 장면 배선, 출처, 청취 |
| UI·입력 | `docs/UI_ART_DIRECTION.md`, `docs/CONTROLLER_UX_STRATEGY.md`, `docs/INPUT_MATRIX.md` | 표면, 포커스, 패드, 해상도 |
| QA·출시 | `docs/MASTER_RELEASE_AUDIT.md`, `docs/QA_CHECKLIST.md`, `docs/BUILD_PIPELINE.md` | 출시 차단 게이트 |
| 심의·콘텐츠 설문 | `content/meta/release_content_inventory.json`, `docs/CONTENT_RATING_INVENTORY.md` | 패키지 포함 범위, 24주/240주 도달성, 내용 축, 생성형 AI·온라인 사실 |
| Steam·마케팅 | `docs/STEAM_PAGE.md`, `docs/STORE_SHOTLIST.md`, `docs/TRAILER_PRODUCTION.md` | 외부 판매 표면 |
| 최신 결정 이유 | `docs/DECISIONS.md` | 날짜순 결정 원장, 필요한 절만 검색 |
| 작업 증거 | `docs/WORK_LOG.md`, `docs/history/` | 최근 결과와 과거 원문 |

런타임 코드와 JSON은 “현재 실제 동작”의 증거다. 정본 문서와 다르면 코드가 무조건 우선하는 것이 아니라 정합 결함으로 취급한다.

## 작업별 로드 프로필

### 서사·이벤트·엔딩

필수:

- `docs/STORY_BIBLE.md`
- `docs/CHOICE_CONSEQUENCE_SYSTEM.md`
- `docs/STORY_CONSISTENCY_SYSTEM.md`
- `content/meta/narrative_spine.json`
- `content/meta/story_rules.json`

조건부:

- 관계 장면: `docs/ROMANCE_SYSTEM.md`
- Chapter 1의 1~48주 편성: `docs/CORE_LOOP_V2.md`, `content/meta/demo_core_loop_v2.json`, 필요한 경우 현재 48행 인과 원장과 활성 Chapter 1 오더. 현재 제품에 구현된 전반부는 1~24주다.
- 본편 폴백 편성: `docs/GAME_RECOMPOSITION_PLAN.md`, 현재 `ORDER-28`
- 엔딩 라우팅: `content/endings.json`, `systems/EndingSystem.gd`, 관련 `DECISIONS` 절

### 게임 루프·밸런스

필수:

- `docs/CORE_LOOP_V2.md`
- `content/meta/demo_core_loop_v2.json`
- `docs/AP_REDESIGN.md`
- `docs/BALANCE.md`
- `autoloads/GameState.gd`
- `scenes/MainGame.gd`의 관련 함수

조건부:

- 사건 편성: `content/meta/event_director.json`
- 장편 구조: `docs/GAME_RECOMPOSITION_PLAN.md`
- 참조작에서 가져올 구조·버릴 외형 판정: `docs/REFERENCE_SYSTEM_VERDICTS.md`
- 수치 변경: 관련 시뮬레이터와 `tools/balance_check.py`

Chapter 1의 완성 단위는 1~48주다. 현재 구현된 1~24주 전반부에서는 Core
Loop V2가 화면·관계 주도권·월간 편성의 우선 정본이고, 25~48주는 48행 인과
원장이 채워질 때까지 기존 폴백의 증거일 뿐 완성 제품으로 세지 않는다. 기존
AP/Decision 문서는 내부 경제와 49~240주 폴백의 증거이며, Chapter 1 사람 GO
전까지 삭제하거나 후속 장에 확산하지 않는다.
`docs/CORE_LOOP_V2_REVIEW.md`는 대안 비용을 비교한 논의 자료이며 정본이나
실행 오더가 아니다. 요청받아 대안을 재검토할 때만 읽는다.

### 캐릭터·CG·배경

필수:

- `docs/GANGNAM_INK_ART_DIRECTION.md`
- `docs/ASSET_CONTINUITY_CHECKLIST.md`
- `assets/CHARACTER_VISUAL_BIBLE.md`
- 대상 장면의 `assets/*VISUAL_BIBLE.md`

조건부:

- 엔딩: `docs/ENDING_ART.md`, `docs/ENDING_AUDIT.md`
- 초상 연차: `assets/CAST_TIME_VISUAL_BIBLE.md`, `content/meta/cast_visual_years.json`
- 실제 배선: `autoloads/ImageRegistry.gd`, `assets/event_visual_contracts.json`, `assets/cg_acting_manifest.json`

`docs/ASSETS_BRIEF.md`는 과거 대량 제작 브리프다. 현재 스타일·정합보다 우선하지 않으며, 신규 작업의 단독 정본으로 사용하지 않는다.

### 오디오

필수:

- `docs/AUDIO_QA.md`
- `assets/game_audio_manifest.json`
- `assets/scene_audio_manifest.json`
- `assets/audio/AUDIO_SOURCE_MANIFEST.json`

조건부:

- 빌드 방식: `docs/PRODUCTION_ASSET_PIPELINE.md`
- 실제 장면: 대상 사건 JSON과 `autoloads/AudioManager.gd`, `autoloads/BGMPlayer.gd`

자동 PASS는 장면 적합성·피로도·믹스를 증명하지 않는다. 최종 승인은 연속 청취다.

### UI·패드·해상도

필수:

- `docs/UI_ART_DIRECTION.md`
- `docs/CONTROLLER_UX_STRATEGY.md`
- `docs/INPUT_MATRIX.md`

조건부:

- 화면 계약: `docs/QA_CHECKLIST.md`
- Moral 표면: `docs/MORAL_TINT.md`
- 실제 의미 입력: `autoloads/ControllerHints.gd`

### 현지화

필수:

- `docs/I18N_GLOSSARY.md`
- `docs/I18N_INFRASTRUCTURE.md`
- KR 원본과 대상 언어 오버레이 한 쌍

조건부:

- 일본어: `docs/I18N_GLOSSARY_JA.md`
- 중국어 간체·번체: `docs/I18N_GLOSSARY_ZH.md`
- UI 런타임: `autoloads/LocaleManager.gd`

번역 작업에서 게임플레이 키나 조건을 오버레이로 옮기지 않는다.

### QA·빌드·출시

필수:

- `docs/MASTER_RELEASE_AUDIT.md`
- `docs/QA_CHECKLIST.md`
- `docs/BUILD_PIPELINE.md`
- `content/meta/release_content_inventory.json`
- `docs/CONTENT_RATING_INVENTORY.md`

조건부:

- Next Fest: `docs/NEXTFEST_CHECKLIST.md`
- 외부 테스트: `docs/PLAYTEST_KIT.md`, `docs/DEMO_FIXLOG.md`
- Steam 표면: `docs/STEAM_PAGE.md`, `docs/STORE_SHOTLIST.md`

심의·설문에서는 `24주 V2 도달 / 240주 본편 도달 / 패키지 포함·현재 비도달`을
합치지 않는다. 보고서는 사실 근거를 라우팅할 뿐 최종 연령 등급·삭제·export
필터를 결정하지 않으며, 제출 시점의 실제 파트너·심의 화면을 다시 확인한다.

## 기록 규칙

- 현재 상태: `CLAUDE.md` 한 곳
- 활성 작업 상태: `docs/CODEX_QUEUE.md` 표 한 곳
- 상세 활성 사양: `docs/queue_active/<ID>.md`
- 구현 결과: `docs/WORK_LOG.md`, 최신순
- 결정 이유: `docs/DECISIONS.md`, 최신순
- 사용자 플레이 노트: `docs/DEMO_FIXLOG.md`
- 과거 원문: `docs/history/`, `docs/queue_archive/`, `docs/archive/`

같은 사실을 여러 바이블에 복사하지 않는다. 한 문서가 소유하고 다른 문서는 링크만 건다.

## 검색 요령

긴 파일은 전체 로드 대신 제목과 키워드부터 찾는다.

```bash
rg -n '^## |<키워드>' docs/DECISIONS.md
rg -n '<event_id>|<flag>|<character>' content docs assets
sed -n '<start>,<end>p' <파일>
```

과거 변경 이유가 필요할 때만:

```bash
rg -n '<키워드>' docs/history docs/queue_archive docs/archive
```

## 유지보수

- `python3 tools/context_manifest_check.py`는 필수 파일, 크기 예산, 분류 누락, 관리 문서의 깨진 링크와 핵심 시간축을 검사한다.
- 새 최상위 문서를 만들면 `docs/context_manifest.json`의 정확한 그룹 또는 glob에 포함한다.
- 부팅 문서가 커지면 상세 설명을 정본 문서로 옮기고 링크만 남긴다.
- 월별 또는 큰 마일스톤 뒤 `WORK_LOG.md`를 손실 없는 보관본으로 롤링한다.
