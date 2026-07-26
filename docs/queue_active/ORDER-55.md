# Active Queue Spec: ORDER-55

> Canonical status is indexed in `docs/CODEX_QUEUE.md`.

#### [~] 착수 — 만지는 파일

- `docs/CODEX_QUEUE.md`
- `docs/queue_active/ORDER-55.md`
- `CLAUDE.md`
- `docs/WORK_LOG.md`
- `docs/STORY_CONSISTENCY_SYSTEM.md`
- `content/meta/story_rules.json`
- `content/events/{arc_events,ng_plus_events,arc_year3_drama,scenario_cafe_callback,callback_events,callback_events_36,arc_hyunsu,arc_midgame,arc_chapter_themes,gambling_narrative}.json`
- `content/events_en/{arc_events,ng_plus_events,arc_year3_drama,scenario_cafe_callback,callback_events,callback_events_36,arc_hyunsu,arc_midgame,arc_chapter_themes,gambling_narrative}.json`
- `scenes/MainGame.gd`
- `assets/event_visual_contracts.json`
- `assets/scene_audio_manifest.json`
- `assets/scene_direction_manifest.json`
- `tools/story_consistency_audit.py`
- `tools/DemoBuildCheck.gd`
- `tools/ScreenshotQA.gd`

ORDER-55 [P0·정합 QA] 실제 노출 사건의 직업·주거·장소 계약을 잠근다

## 발견

전체 1,565사건 중 편성기·전경 풀·후속 사슬에서 실제 도달 가능한 사건은 442건이다.
이 집합을 대상으로 정적 계약을 교차 검사하자 다음 고신뢰 결함이 재현됐다.

1. `story_rules.presentation.scene_location=current_housing`인데 사건·시각 계약은
   `goshiwon_room` 또는 `late_night`로 고정된 사건 11건이 있다. 이사 뒤에도 고시원이나
   엉뚱한 야간 배경이 나타날 수 있다.
2. `arc_father_medication`은 직업 조건 없이 편성되지만 회의실·자리 복귀를 서술하고
   사무실 배경을 사용한다.
3. `arc_34_routine_trap`, `arc_34_two_years_in`, `arc_35_orthodox_weight`는 선택한 삶의
   경로와 무관하게 출근·직장을 기정사실화한다.
4. `holdem_skill_transfers`는 회사 협상 장면인데 `holdem_regular`만 검사한다.
5. 커리어 전문화 결과 두 건은 전문화 선택 뒤 퇴사해도 회사 장면을 강제할 수 있다.

## 구현 계약

### A. 동적 주거

- 장소가 고정되지 않은 전화·문자·영상통화는 사건 배경·시각 계약·오디오를
  `current_housing`으로 통일한다.
- 인트로처럼 본문이 실제 고시원을 명시하는 사건은 반대로 규칙 원장의
  `scene_location`을 `goshiwon_room`으로 바로잡는다.
- 4년차 지연 전화의 고정 고시원 문구는 현재 거주지를 침범하지 않는 문장으로 한영 수리한다.

### B. 선택 직업

- 아버지 약 장면은 무직·알바·정규직 모두 성립하는 대중교통 귀갓길 장면으로 바꾼다.
- 경로 회고는 `직장/출근`을 기정사실화하지 않고 일·수입·일정의 보편 문장으로 바꾼다.
- 회사에서만 성립하는 홀덤 전이 사건은 `has_job`을 요구한다.
- 전문화 결과는 현재도 비생존형 직업을 가진 경우에만 편성한다.

### C. 회귀 방지

- 정합 감사에 `current_housing/current_workplace` 동적 장소와 사건 배경의 일치 규칙을
  추가한다.
- 무직 상태의 회사 사건 차단과 전문화 선택 뒤 퇴사한 상태의 결과 차단을 Godot 회귀로
  고정한다.
- KR·EN 산문, 시각·오디오·전환 계약과 Screenshot QA 기대 장소를 함께 갱신한다.

## 비범위

- 휴면 콜백 564건의 부활 또는 전면 교정
- 장르·엔딩·밸런스 밴드 변경
- 사람 판정이 필요한 기존 `[~]` 오더의 상태 변경
- 사용자 소유 `project.godot`

## 완료 게이트

- 실제 도달 사건의 동적 장소 불일치 `11 → 0`
- 실직 상태에서 회사 전용 사건 편성 `0`
- `python3 tools/story_consistency_audit.py`
- `python3 tools/event_director_audit.py`
- `GODOT="$HOME/Downloads/Godot.app/Contents/MacOS/Godot" ./tools/audit.sh`
- `python3 tools/en_coverage_check.py`
- `python3 tools/english_hangul_audit.py`
- `git diff --check`
