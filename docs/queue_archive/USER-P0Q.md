# Completed Queue Spec: USER-P0Q

> Canonical status is indexed in `docs/CODEX_QUEUE.md`.

#### [x] USER-P0Q [P0·오디오 정합] 상철 부동산 장면 오발 기침 제거

> **2026-07-25 착수 — 만지는 파일**
>
> - 런타임 장소층: `autoloads/BGMPlayer.gd`
> - 장면 계약: `assets/scene_audio_manifest.json`
> - 자동 회귀: `tools/BGMContinuityCheck.gd`,
>   `tools/scene_audio_contract_check.py`
> - 정본·기록: `docs/AUDIO_QA.md`, `CLAUDE.md`, `docs/WORK_LOG.md`,
>   `docs/DEMO_FIXLOG.md`, 이 완료 사양과 큐 인덱스
>
> 진행 중인 `ORDER-48` 파일과 사용자 소유 변경 `project.godot`은 건드리지 않는다.

## 재현·원인

- `arc_sangchul_01_measure`의 작은 부동산 사무실에서 약 15초 뒤
  `콜록콜록` 기침이 재생된다.
- 장면 계약의 `office` 룸톤이 `HUMAN_AMBIENCE_BY_WORLD`의
  `public_interior` 사람층을 자동 호출한다.
- `amb_human_public_interior.wav`에는 14.7초 지점의 실제 기침 샘플이 있다.
  공공청사·학교 복도에는 가능한 소리지만 상철과 민준만 있는 사설 중개소에는
  화면 밖 제3자를 발명한다.

## 구현 계약

1. `arc_sangchul_01_meet`부터 `arc_sangchul_01_answer`까지 네 장면은 기존
   `amb_office_room.wav`를 끊김 없이 유지한다.
2. 이 체인에서만 자동 `public_interior` 사람층을 억제한다. 다른 사무실·학교·
   공공청사의 사람층은 바꾸지 않는다.
3. 빗길 차량, 종이컵, 종이 취급 문단 큐와 무음악 연출은 유지한다.
4. 새 파형 합성이나 대체 음원을 만들지 않는다.

## 검증

- `python3 tools/scene_audio_contract_check.py`
- `godot --headless res://tools/BGMContinuityCheck.tscn`
- 상철 첫 만남 체인에서 `office` 룸톤 유지, human key 공백, 사람층 정지 확인
- 관련 오디오 감사, 전체 컴파일, `git diff --check`

## 완료 결과

- 상철 첫 만남 4장면에만 `suppress_human_ambience: true`를 선언했다.
- 명시적 억제 시 이미 재생 중인 공용 사람층을 즉시 멈춰 페이드 중 기침이
  새 장면으로 새지 않게 했다.
- `office` 룸톤의 재생 위치 연속, 사람층 key 공백·플레이어 정지,
  기존 문단 폴리와 무음악 계약을 자동 회귀로 잠갔다.
- 장면 계약, BGM 연속성, 오디오 자산·출처 검사와 전체 `audit.sh`가
  `✅ 감사 통과`로 끝났다.
