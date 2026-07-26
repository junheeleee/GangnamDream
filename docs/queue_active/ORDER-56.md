# Active Queue Spec: ORDER-56

> Canonical status is indexed in `docs/CODEX_QUEUE.md`.

#### [~] 착수 — 만지는 파일

- `docs/CODEX_QUEUE.md`
- `docs/queue_active/ORDER-56.md`
- `CLAUDE.md`
- `docs/WORK_LOG.md`
- `docs/STORY_CONSISTENCY_SYSTEM.md`
- `content/meta/exposed_event_state_contracts.json`
- `content/meta/story_rules.json`
- `content/events/*.json` (감사에서 발견된 사건만)
- `content/events_en/*.json` (대응 영어 사건만)
- `assets/event_visual_contracts.json` (장소 수리 시)
- `assets/scene_audio_manifest.json` (장소 수리 시)
- `assets/scene_direction_manifest.json` (전환 수리 시)
- `scenes/MainGame.gd` (중복 상태 비트의 스케줄러 차단 시)
- `tools/exposed_state_consistency_audit.py`
- `tools/event_director_audit.py`
- `tools/background_semantic_audit.py`
- `tools/story_consistency_audit.py`
- `tools/audit.sh`
- `tools/DemoBuildCheck.gd`
- `tools/ScreenshotQA.gd` (표적 장면이 필요할 때)

ORDER-56 [P0·정합 QA] 도달 가능한 442사건의 상태 가정을 전수 계약한다

## 근거

`ORDER-55`는 발견된 동적 주거·선택 직업 오류를 수리했지만 상세 정합
원장은 135/1,565사건이다. 실제 게임에서 현재 노출되는 집합은 편성기
전경·다리 82건, 아크 스케줄러 226건을 진입점으로 삼아 명시·지연 후속을
닫은 442건이다. 등록된 계약 안의 오류 0건은 게임 전체 무결점을 뜻하지
않으므로, 노출 집합 전체에 미검토 사건이 남지 않는 별도 래칫이 필요하다.

## 구현 계약

### A. 도달 집합 정본화

- 런타임과 같은 등록 사건, 전경·다리 허용목록, `_next_arc_id()` 반환,
  직접·지연 후속을 따라 노출 집합을 계산한다.
- 현재 기준 `roots=306`, `exposed=442`를 고정하되 숫자만 맞춘 다른
  집합으로 바뀌면 실패하도록 사건 ID 집합도 검증한다.
- 새 사건이 노출되면 상태 계약 또는 검토된 중립 분류 없이는 감사가
  실패한다. 휴면 1,123사건은 이번 오더에서 억지로 안전 판정하지 않는다.

### B. 상태 가정 전수 분류

- 442사건 각각을 `state_sensitive` 또는 `reviewed_neutral` 중 정확히
  하나로 분류한다.
- 상태 민감 계약은 `employment`, `housing`, `relationship`,
  `father_life`, `location` 중 필요한 축만 소유한다.
- 회사·출근·팀장·급여, 고시원·현재 집, 연애·결혼·이별, 입원·사망 같은
  한영 산문과 배경·초상이 계약보다 강한 가정을 만들면 실패한다.
- 계약의 요구 상태는 실제 `conditions`, `story_rules` 선행조건,
  생산자·후속 진입 경로 중 적어도 하나로 실행 가능하게 보호돼야 한다.

### C. 실제 오류 수리

- 고신뢰 모순은 조건을 추가하거나, 선택 경로 전반에서 성립하는 산문·
  장소로 바꾼다. 단순히 감사를 통과시키기 위한 예외 등록은 금지한다.
- 한영 산문과 시각·오디오·전환 계약을 같은 사건 ID 단위로 함께 고친다.
- 직업·주거·관계·아버지 상태 대표 조합을 Godot 회귀로 고정한다.

## 비범위

- 휴면 사건 1,123건의 부활·전면 교정
- 사람 눈으로만 판정 가능한 얼굴·손·시선·공간 미학의 완전 보증
- 장르·엔딩·밸런스 밴드 변경
- 사용자 소유 `project.godot`

## 완료 게이트

- 노출 집합 `442/442` 분류, 중복·미분류 `0`
- 상태 민감 사건의 실행 보호 누락 `0`
- 고신뢰 한영 산문·배경 모순 `0`
- `python3 tools/exposed_state_consistency_audit.py`
- `python3 tools/story_consistency_audit.py`
- `python3 tools/event_director_audit.py`
- `GODOT="$HOME/Downloads/Godot.app/Contents/MacOS/Godot" ./tools/audit.sh`
- `python3 tools/en_coverage_check.py`
- `python3 tools/english_hangul_audit.py`
- `git diff --check`
