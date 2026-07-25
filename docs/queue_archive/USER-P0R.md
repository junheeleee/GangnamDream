# Active Queue Spec: USER-P0R

> Canonical status is indexed in `docs/CODEX_QUEUE.md`.

#### [x] USER-P0R [P0·장소 정합] 고시원 공용 주방 전용 배경

> **2026-07-25 착수 — 만지는 파일**
>
> - 신규 배경: `assets/backgrounds/goshiwon_shared_kitchen.png`와 Godot import
> - 사건·런타임: `content/events/arc_hyunsu.json`,
>   `autoloads/ImageRegistry.gd`
> - 자산 계약: `assets/event_visual_contracts.json`,
>   `assets/mod_asset_manifest.json`, `docs/MODDING.md`,
>   `tools/art_resolution_baseline.json`
> - 자동 회귀: `tools/background_semantic_audit.py`
> - 정본·기록: `assets/GOSHIWON_VISUAL_BIBLE.md`, `assets/IMAGE_PROMPTS.md`,
>   `docs/ART_AI_AUDIT.md`, `CLAUDE.md`, `docs/WORK_LOG.md`,
>   `docs/DEMO_FIXLOG.md`, 이 활성 사양과 큐 인덱스
>
> 진행 중인 `ORDER-48` 파일과 사용자 소유 변경 `project.godot`은 건드리지 않는다.

## 재현·원인

- `hyunsu_study_together`는 "새벽 두 시, 고시원 공용 주방"을 명시하지만
  `background`가 `goshiwon_room`으로 고정돼 침대와 개인 책상이 보인다.
- 현재 자산에는 개인실과 복도만 있고 공용 주방이 없어, 과거에는 일부
  문장을 복도로 후퇴시켰으나 이 장면의 라면 조리·대화 동사는 주방을
  필요로 한다.

## 구현 계약

1. 같은 신촌 고시원의 벽·노후도·형광등·한밤 색온도를 잇는 인물 없는
   좁은 공용 주방 배경을 추가한다.
2. 싱크대·조리대·1~2구 조리기·공용 냉장고·기본 조리도구가 물리적으로
   연결돼야 하며 침대·개인 책상·대형 창·고급 주방은 금지한다.
3. 화면 오른쪽 현수 초상과 하단 대화창을 가려도 장소 동사와 원근이
   읽혀야 한다. 이름·상표·판독 문자는 넣지 않는다.
4. `hyunsu_study_together`의 한영 산문·선택·효과는 바꾸지 않고 배경만
   정합화한다. 기존 고시원 복도 룸톤과 주전자·컵 문단 폴리는 유지한다.
5. 공용 주방을 명시하는 이 사건이 다시 `goshiwon_room`으로 회귀하면
   자동 감사에서 실패한다.

## 검증

- 신규 PNG 원본 해상도·RGB·무문자·인물 없음 육안 확인
- 실제 StoryMode 합성에서 현수 초상·대화창·공용 주방 가독성 확인
- `python3 tools/background_semantic_audit.py`
- 자산·시각 계약, 한영 표면, 전체 컴파일, `git diff --check`

## 완료 결과

- 내장 ImageGen으로 같은 고시원 개인실·복도 재질을 잇는
  `1280×800` RGB 전용 공용 주방을 제작했다.
- `hyunsu_study_together`와 이미지 레지스트리·사건 시각 계약을
  `goshiwon_shared_kitchen`으로 고정했다.
- 한국어 StoryMode 실제 합성
  `/tmp/gangnamdream_qa/hyunsu_study_together_kitchen.png`에서 현수
  초상·하단 대화창과 함께 싱크대·냄비·공용 냉장고가 읽히고 침대가
  사라진 것을 확인했다.
- 모드 매니페스트·해상도·시각 계약·장면 오디오·한영 표면·전체 감사를
  통과했다.
