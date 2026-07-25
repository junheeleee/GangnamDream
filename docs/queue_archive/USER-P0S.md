# USER-P0S — 실플레이 가독성·인과·경마 회귀 수리

상태: `[x] 완료`
착수일: 2026-07-25
완료일: 2026-07-26
근거: 사용자 직접 플레이에서 확인된 출시 차단급 가독성·직업 조건·장소·입력 오류

## 목표

- 긴 대사도 글자 크기와 해상도에 관계없이 잘리지 않고 끝까지 읽힌다.
- 선택 결과에서 정확한 호감도 수치와 미래 메타 해설을 노출하지 않는다.
- 회사 사건은 실제 회사 직업일 때만 나오고, 장면의 장소와 배경이 일치한다.
- 경마 첫 체험 선택은 실제 경마 미니게임으로 이어지며 결과 화면을 키보드·패드로 완주할 수 있다.
- 경마에서 돌아온 주간 결산은 카지노가 아니라 경마장 맥락을 유지한다.
- 한국어 원본과 영어 오버레이가 같은 의미와 조건을 유지한다.

## 만지는 파일

- `scenes/StoryMode.gd`
- `scenes/RaceTrack.gd`
- `scenes/MainGame.gd`
  - 이번 항목은 긴 대사·결과 노출·`arc_job_vs_invest` 게이트·월간 제목·경마 진입/복귀 함수만 소유한다.
  - 이미 존재하는 `ORDER-48` 변경은 수정·스테이징하지 않는다.
- `autoloads/EventManager.gd`
- `autoloads/GameState.gd`
- `autoloads/DataRegistry.gd`
- `content/events/arc_events.json`
- `content/events_en/arc_events.json`
- `content/events/arc_midgame.json`
- `content/events_en/arc_midgame.json`
- `content/events/racetrack_events.json`
- `content/events_en/racetrack_events.json`
- `assets/event_visual_contracts.json`
- `assets/scene_audio_manifest.json`
- `content/meta/story_rules.json`
- `docs/STORY_BIBLE.md`
- `docs/STORY_CONSISTENCY_SYSTEM.md`
- `docs/DEMO_FIXLOG.md`
- `docs/WORK_LOG.md`
- `docs/CODEX_QUEUE.md`
- `CLAUDE.md`
- 이번 결함을 고정하는 기존 또는 신규 표적 감사 파일
- `tools/story_consistency_audit.py`

## 정합 계약 보강

- 사건 ID 하나가 논리 선행조건, 현장 참여자·역할, 장소, 초상, 오디오 계약을
  함께 추적할 수 있게 한다.
- 직업 의존 사건은 `story_rules.json`의 허용 직업군을 런타임도 읽는다.
- 편의점 재회처럼 직업 자유화 뒤 역할이 바뀐 장면은 `participant_roles`로
  민준·다은·지연의 현장 역할을 명시하고 자동 감사한다.

## 보호 범위

- 사용자 소유 `project.godot`은 건드리지 않는다.
- 진행 중인 `MetaProgression`, 엔딩, `arc_daeun*`, 일본어, 자산 요청 문서,
  `ScreenshotQA.gd`, `ending_distinctness_audit.py` 변경은 건드리거나 스테이징하지 않는다.
- 밸런스 밴드·엔딩 라우팅·신규 게임 시스템은 변경하지 않는다.

## 완료 게이트

- 긴 한글/영문 대사 표적 렌더에서 마지막 줄까지 보인다.
- 무직·생존직 대표 상태에서 회사 팀장 사건이 열리지 않는다.
- 지연 재회·한식당·경마 결산의 배경 계약이 산문과 일치한다.
- 경마 결과 화면의 좌우 이동·확인·취소와 실제 첫 경주 진입을 자동/수동으로 검증한다.
- `python3 tools/context_manifest_check.py`
- `GODOT=/usr/local/bin/godot ./tools/audit.sh`
- `python3 tools/en_coverage_check.py`
- `git diff --check`

## 완료 결과

- 실제 폰트와 가용 높이로 한국어·영어 본문/결과를 자동 분할하고 글자
  크기·언어 변경에도 원문 위치를 보존했다. 추가 시각 페이지는 사건의
  배경·초상·CG·오디오 큐를 재실행하지 않는다.
- 선택 결과의 정확한 관계 수치와 등급 해설을 숨겼다.
- `story_rules.json`의 사건 ID를 실행 선행조건, 현장 참여자 역할,
  배경·초상·앰비언스 계약의 결합 키로 확장했다. 회사 팀장 사건은 실제
  사무직만 통과한다.
- 지연의 편의점 재회 잔재를 신촌역 버스정류장으로 옮겼고, 청담 한식당은
  전용 식당 배경을 사용하며 커피 또는 솔직 대화를 이어 간 경로만 열린다.
- 첫 경마표 선택은 고정 손실 대신 실제 경마 미니게임을 열고, 결과 화면은
  좌우/Tab·확인·취소로 다음 경주와 나가기를 고른다. 주간 결산은 경마장
  배경과 행동 원장을 유지한다.
- `StoryPlaybackCheck`, `CoreChoiceSliceCheck`, `InputMatrixCheck`,
  `ImmersionLoopCheck`, 사건 정합·시각·오디오 계약, 두 240주 대표
  경로와 한영 표면을 검증했다. 전체 `audit.sh`는 54개 GDScript 강제
  컴파일을 포함해 `✅ 감사 통과`로 끝났다.
