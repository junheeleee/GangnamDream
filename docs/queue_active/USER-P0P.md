# Active Queue Spec: USER-P0P

> Canonical status is indexed in `docs/CODEX_QUEUE.md`.

#### [~] USER-P0P [P0·인물 연기] 민준 피로 초상 표정 수리

> **2026-07-25 착수 — 만지는 파일**
>
> - 승인 대상: `assets/characters/main_character_tired.png`
> - 인물 정본: `assets/CHARACTER_VISUAL_BIBLE.md`
> - 연속성 정본: `docs/ASSET_CONTINUITY_CHECKLIST.md`
> - 기록: `CLAUDE.md`, `docs/WORK_LOG.md`, 이 활성 사양과 큐 인덱스
>
> 런타임 ID·이벤트 조건·사용자 소유 변경인 `project.godot`은 건드리지 않는다.

## 진단

- 현재 `main_character_tired.png`는 아래로 향한 시선보다 붉고 무겁게 반쯤 감긴
  눈꺼풀이 먼저 읽혀 피곤함이 아니라 통증·질병·약물 취한 상태처럼 보인다.
- 이 한 장은 `player_tired`, `player_sad`, `player_hollow`가 공유하고 많은 사건에서
  재사용되므로 표정 오류의 파급 범위가 크다.
- 민준의 얼굴·나이·머리·체형·검은 크루넥·투명 초상 구도는 이미 정본이다. 전면
  재캐스팅이나 화려한 미남화가 아니라 눈과 미세 표정만 수리한다.

## 이미지 계약

1. 33세 김민준의 동일한 얼굴 구조, 짧고 흐트러진 검은 머리, 마른 체형, 낡은 검은
   크루넥, 숙인 머리와 상반신 실루엣을 유지한다.
2. 두 눈은 분명히 떠 있고 동공·홍채가 자연스럽게 보이며, 시선은 화면 왼쪽 아래를
   향한다. 좌우 눈의 개방 정도가 병적으로 다르지 않아야 한다.
3. 피로는 약한 눈 밑 그림자, 느슨한 어깨, 절제된 입매로 표현한다. 충혈, 부은 눈꺼풀,
   고통스러운 찡그림, 울기 직전 얼굴, 취한 얼굴은 금지한다.
4. 투명 배경, 512×768 RGBA, 하단까지 이어지는 기존 크롭과 여백을 유지한다.
5. Gangnam Ink의 절제된 한국 성인 비주얼노벨/만화 리얼리즘을 유지하며 포토리얼 사진,
   광택 모바일 일러스트, 배경·소품·텍스트를 추가하지 않는다.

## 검증

- 원본과 교체본을 나란히 비교해 한눈에 같은 민준으로 읽히는지 확인한다.
- 투명 모서리·알파 프린지·512×768 해상도·과도한 불투명 배경이 없는지 검사한다.
- `VisualCropQA`의 `story_02_late_night_minjun_tired`와 1280×800 실제 합성 화면에서
  눈·표정·하단 크롭을 육안 확인한다.
- `python3 tools/context_manifest_check.py`
- `GODOT=/usr/local/bin/godot ./tools/audit.sh`
- `python3 tools/en_coverage_check.py`
- `git diff --check`
