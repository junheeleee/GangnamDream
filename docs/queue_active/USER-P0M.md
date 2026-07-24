# Active Queue Spec: USER-P0M

> Canonical status is indexed in `docs/CODEX_QUEUE.md`. This file preserves the
> full active specification so sessions only load the order they are executing.

#### [~] USER-P0M [P0·아트] 엔딩 35종 전용 16:10 아트 전수 교체

**[~] 착수 (2026-07-24 Codex) — 만지는 파일:** `docs/CODEX_QUEUE.md`,
`docs/queue_active/USER-P0M.md`, `CLAUDE.md`, `docs/ENDING_ART.md`,
`docs/ENDING_AUDIT.md`, 신규 엔딩 전수 비주얼 바이블, `content/endings.json`,
`content/endings_en.json`,
`autoloads/ImageRegistry.gd`, `scenes/MainGame.gd`, `assets/cg/ending_*.png`,
`assets/cg_acting_manifest.json`, `docs/ART_AI_AUDIT.md`,
`docs/ART_RESOLUTION_READINESS.md`, `tools/art_resolution_baseline.json`,
`assets/mod_asset_manifest.json`, `docs/MODDING.md`,
`tools/ending_distinctness_audit.py`,
`tools/CGRuntimeCheck.gd`, `tools/ScreenshotQA.gd`, `docs/WORK_LOG.md`.
기존 사용자 변경 `project.godot`은 건드리지 않는다.

## 사용자 판정

엔딩 화면에 남아 있는 도형, 공용 무드 카드, 사건과 맞지 않는 기존 배경 크롭을
출시 자산으로 인정하지 않는다. 35개 엔딩은 텍스트를 읽기 전에도 서로 다른 마지막
삶으로 보이는 전용 아트를 소유해야 한다.

## 불변 계약

- 모든 엔딩은 `cg` 키와 독립된 `1280x800` 이상 16:10 전용 CG를 가진다.
- 기존 배경의 단순 크롭, 코드 도형, 심벌 카드, 다른 사건 CG의 재사용으로 통과하지
  않는다.
- 결산 시점은 특별한 조기 엔딩을 제외하면 2031년의 37-38세 민준이다. 얼굴,
  헤어라인, 체형은 같은 사람이어야 하며 연령 차이는 5년 안에서 절제한다.
- 직업·자산·연애·아버지 생사·주거·계절·MORAL_TINT를 이미지가 임의로 발명하지
  않는다. 여러 상태가 공유하는 엔딩은 모든 유효 변주와 모순되지 않는 최종 물리를
  선택한다.
- 인물이 있는 CG는 카메라 역할, 시선 출발점과 목표, 손의 행동, 의상 근거를
  `assets/cg_acting_manifest.json`에 기록한다. 설명되지 않는 렌즈 응시는 실패다.
- `Gangnam Ink`의 한국 성인 사회극과 비주얼노벨 가독성을 유지한다. 포토리얼
  스톡사진, 광택 모바일 일러스트, 무관한 일본 교복풍, 읽히는 로고·문자는 금지한다.
- 실제 엔딩 UI의 하단 대화 영역을 가린 상태에서도 얼굴·행동·핵심 소품이 읽혀야
  한다. 1280x800 KO/EN과 Steam Deck 크롭을 함께 판정한다.

## 실행 순서

1. 35개 엔딩의 현재 CG·배경·심벌·파일 비율·레지스트리·런타임 크롭을 전수표로
   고정한다.
2. 기존 전용 CG 21종을 얼굴, 연령, 의상, 공간, 손, 시선, 반사, 엔딩 의미로
   재감사해 유지·보정·전면 교체를 판정한다.
3. 비전용 14종을 우선 신규 제작하고, 불합격 기존 CG를 같은 기준으로 교체한다.
4. 모든 엔딩을 전용 `cg`로 배선한 뒤 코드 도형과 엔딩 전용 심벌 폴백 의존을
   제거한다.
5. 매니페스트·해상도·AI 감사·모드 교체 계약을 갱신하고 엔딩 전용 KO/EN
   ScreenshotQA와 전체 감사를 통과한다.

## 완료 게이트

- `content/endings.json` 35종 모두 고유한 `cg` 보유
- 35개 CG 경로 존재, 16:10, 최소 1280x800, 중복 SHA-256 0
- 런타임 엔딩 표면에서 코드 도형·공용 배경 카드 사용 0
- `python3 tools/ending_distinctness_audit.py` 통과
- `GODOT=<실제 경로> ./tools/audit.sh` 통과
- KO/EN 엔딩 전수 캡처에서 텍스트·인물·핵심 소품 잘림 0
- `project.godot` 미포함 확인 후 완료 커밋을 `main`에 푸시
