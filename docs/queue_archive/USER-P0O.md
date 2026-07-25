# Active Queue Spec: USER-P0O

> Canonical status is indexed in `docs/CODEX_QUEUE.md`.

#### [x] USER-P0O [P0·퍼블리셔 로고] 새 JUNPAC GAMES 로고 정본화

> **2026-07-25 착수 — 만지는 파일**
>
> - 승인 원본: `assets/logos/junpac_games_logo_v2.png`
> - 런타임: `scenes/SplashScreen.gd`
> - 폐기 대상: `scenes/ui/JunpacMark.gd`, `scenes/ui/JunpacMark.gd.uid`,
>   `assets/logos/junpac_games_logo.jpg`, `assets/logos/junpac_games_logo.jpg.import`
> - 회귀 계약: `tools/First30SecondsCheck.gd`, `tools/keyart_asset_check.py`
> - 정본·기록: `docs/QA_CHECKLIST.md`, `assets/ASSET_INDEX.md`, `CLAUDE.md`,
>   `docs/WORK_LOG.md`, 이 활성 사양과 큐 인덱스
>
> 사용자 소유 변경인 `project.godot`은 건드리지 않는다.

## 승인 원본

- 사용자 제공 파일:
  `/Users/junheelee/Downloads/준팍게임즈로고.png`
- 1024×1024 RGBA PNG. 배경은 실제 투명이며, 유효 워드마크는 중앙 가로형이다.
- 별빛 심볼, `JUNPAC`, `GAMES` 글자 형태와 색은 재생성하거나 재해석하지 않는다.
- 투명 여백만 런타임 `AtlasTexture` 영역으로 잘라 Steam Deck·TV·4K에서 같은
  비율로 표시한다.

## 구현 계약

1. 퍼블리셔 프리롤은 새 PNG 한 장만 사용한다.
2. 퍼블리셔 구간은 완전한 흰색 배경이며 투명 로고가 중앙 정렬된다. 로고와 흰 배경이
   함께 사라진 뒤에만 강남드림의 검은 타이틀 필름이 시작되고, 늘어짐·잘못된 크롭은
   없어야 한다.
3. 기존 3.1초 예산, 자동 진행, 건너뛰기, `publisher_sting` 1회 계약은 유지한다.
4. 과거 JPEG와 코드 네이티브 초승달은 런타임·감사에서 제거한다.
5. 1280×800 및 3840×2160 실렌더에서 글자 가장자리와 안전 영역을 육안 확인한다.

## 검증

- `python3 tools/keyart_asset_check.py`
- `godot --headless --path . --editor --quit` 또는 정식 import
- `godot --headless res://tools/First30SecondsCheck.tscn`
- `ScreenshotQA --qa=start-en --lang=ko` 1280×800
- `ScreenshotQA --qa=start-en --lang=en` 3840×2160
- 전체 `tools/audit.sh`, EN coverage, `git diff --check`

## 완료 결과

- 승인 PNG를 순백 전면 프리롤에 중앙 배치하고 로고·배경을 함께 페이드아웃했다.
- 과거 JPEG와 코드 네이티브 마크를 제거하고 자산·첫 30초 회귀 계약을 새 정본으로
  교체했다.
- 1280×800 한국어와 3840×2160 영어 실제 프레임에서 순백 배경, 비율, 안전 영역을
  육안 확인했다.
