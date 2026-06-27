# Player-Facing Polish Audit

Updated: 2026-06-27

## Verdict

`강남드림`은 시스템과 콘텐츠 양은 이미 크지만, 플레이어가 처음 만나는 표면은 아직 상업 게임보다 고기능 프로토타입에 가깝다. 가장 큰 이유는 코드가 부족해서가 아니라 UI, 오디오, 전환, 미니게임 스킨, 피드백 레이어가 각각 따로 만들어진 도구처럼 보이기 때문이다.

목표는 모든 UI를 이미지 파일로 굳히는 것이 아니다. Godot 컨트롤은 유지하되, 반복 표면을 공통 테마와 텍스처 스킨으로 묶고, 실제 게임 물체는 이미지/스프라이트로 교체해야 한다.

## Evidence From Runtime QA

- `tools/ScreenshotQA.tscn` 실제 렌더 캡처를 실행했다. 캡처 위치: `/tmp/gangnamdream_qa/`.
- `tools/VisualCropQA.tscn`은 통과했다. 배경/초상화의 기본 crop 정합성은 첫 QA 기준에서 유지된다.
- `tools/AudioAssetCheck.tscn`은 처음 실패했다. `AudioManager`에는 카지노 전용 SFX 8개가 연결돼 있었지만 실제 wav 파일이 없었다. 이 상태에서는 런타임이 삑 소리 폴백을 사용해 미니게임이 바로 목업처럼 들린다.
- `tools/CGRuntimeCheck.tscn`은 처음 실패했다. 다만 원인은 게임 데이터가 아니라 QA 기대값이 낡은 것이었다. `gangnam_dream` 엔딩에 병실 CG를 다시 붙이면 정합성이 깨지므로 QA를 수정했다.
- 실제 화면에서 빨간 위기/피드백 레이어가 너무 쉽게 남아 “상시 위험 상태”처럼 읽혔다. 위기 빨강은 건강/정신력 붕괴 임박 또는 큰 손실에만 사용해야 한다.
- 메인 행동 화면과 미니게임 허브는 정보 구조가 웹 게시판/관리자 화면처럼 보인다. 원인은 이모지 아이콘, 텍스트형 버튼, 과한 목록 레이아웃, 약한 hover/pressed/입장 연출이다.

## 2026-06-27 Runtime QA Update

Executed after merging Claude's latest game-polish branch into `main`.

Checks run:

- `tools/ScreenshotQA.tscn` full 1280x800 render pass: completed, screenshots in `/tmp/gangnamdream_qa/`.
- `tools/VisualCropQA.tscn`: passed, 18 composition shots in `/tmp/gangnamdream_crop_qa/`.
- `tools/AudioAssetCheck.tscn`: passed, BGM 7 / ambience 5 / SFX 28.
- `tools/BGMContinuityCheck.tscn`: passed; repeated BGM start does not restart playback.
- `tools/LocaleSurfaceCheck.tscn`: initially failed because the QA tool changed `LocaleManager.language` directly instead of the saved setting path. Fixed tool path and re-ran successfully.

Player-facing findings:

- Start menu is now serviceable, but still reads more like a systems launcher than an emotional title screen. The next pass should make the `KRW 500K -> KRW 3B -> 5 years` pressure unavoidable without adding more text.
- English dashboard is readable at 1280x800. The broken-looking `[` + emoji style investment unlock hint was removed and replaced with plain text.
- Main portrait panel was too small for a character-driven game. Increasing the left portrait panel from 196px to 224px and portrait height from 248px to 310px makes Minjun read as the protagonist rather than a sidebar icon.
- Casino minigames are substantially improved versus earlier passes. Baccarat, roulette, blackjack, slot, big wheel, Dai Sai, Hold'em, and racetrack no longer have the most obvious off-center/table-obstruction issues in the QA captures.
- The ending screen was the biggest "AI/web mockup" surface: red close button, small modal, and small CG made endings feel like a settings dialog. The ending modal is now a wider cinematic `Finale` frame with a larger CG and subdued close button.
- Remaining high-impact weakness: minigames still feel like styled UI panels over a casino background, not fully tactile table objects. The next art/UX jump needs felt/table skins, chip travel, card dealing timelines, dealer/result callouts, and stronger localized SFX timing.

## UI/UX Diagnosis

### 1. Main HUD

현재 HUD는 기능은 읽히지만 게임적 감정이 약하다.

- 돈, 목표, AP, 건강, 정신력이 모두 텍스트와 이모지 중심이다.
- 상태 변화가 숫자로는 보이지만 “맞았다/벌었다/위험하다”는 촉각이 약하다.
- 상단 바가 전체적으로 웹앱 헤더처럼 보이며, 화면의 감정과 분리돼 있다.

Recommended direction:

- HUD는 아이콘 SVG/TextureRect + 숫자 + 진행바 조합으로 재구성한다.
- AP는 번개 문자 반복이 아니라 고정 크기 pip/slot UI로 만든다.
- 건강/정신력은 평상시 조용하게, 30 이하 경고, 15 이하 위기 펄스로 단계화한다.
- 30억 목표 바는 화면의 핵심 오브젝트처럼 다뤄야 한다. 작게 숨기지 말고 “이번 런의 압박”을 계속 전달한다.

### 2. Action Buttons

현재 행동 버튼은 텍스트 메뉴에 가깝다.

- `투자 — 매수·매도`, `자기계발 — 공부`, `생활 — 이사·상점` 같은 행이 웹 게시판 링크처럼 읽힌다.
- 버튼 자체의 물성이 약하다. 눌렀을 때 소리/스케일/색/결과가 충분히 남지 않는다.
- 이모지가 버튼 아이콘 역할을 하고 있어 플랫폼별 렌더 차이와 저가 UI 인상을 만든다.

Recommended direction:

- 행동 버튼은 `icon + title + AP badge + short consequence tag` 형태의 고정 카드로 만든다.
- 사용 불가 상태는 회색 처리만 하지 말고 잠금 사유를 버튼 내부에 표시한다.
- 버튼 hover/pressed/focus는 공통 `UIStyle`/Theme로 처리하고, 개별 씬에서 직접 `StyleBoxFlat`을 만들지 않는다.

### 3. VN/Event Layer

현재 VN 레이어는 읽을 수 있지만 장면성이 부족하다.

- 배경 위에 텍스트와 선택지가 얹히는 구조는 맞지만, 선택지가 표면적으로 너무 단순하다.
- 이벤트마다 감정 톤이 달라져도 레이아웃 변화가 거의 없다.
- 빨간/흔들림/플래시의 용도가 명확히 분리돼야 한다.

Recommended direction:

- 일반 이벤트: 낮은 대비, 부드러운 타이핑, 약한 배경 드리프트.
- 중요 선택: 선택지 등장 스태거 + 짧은 저음 SFX + 포커스 링.
- 큰 손실/충격: 화면 흔들림 + 짧은 red flash + 저역 타격음.
- 큰 수익/달성: 금색 flash + coin burst + 짧은 stinger.
- 위기 비네팅은 건강/정신력 임계치 전용으로 유지한다.

### 4. Casino / Gambling Minigames

이 영역은 게임의 대중적 재미를 만들 핵심이다. 현재는 기능은 있으나 “독립 게임으로 팔 수 있는 수준”과는 거리가 있다.

Required asset shift:

- 카드 앞면 52장 또는 코드 렌더링 카드 템플릿.
- 카드 뒷면은 사용 가능하나, 모든 카드가 테이블 위 물체처럼 움직여야 한다.
- 칩은 denomination별 스프라이트가 필요하다. 현재 단일 칩 아이콘만으로는 부족하다.
- 룰렛 휠, 슬롯 심볼, 바카라 로드맵, 블랙잭 테이블 펠트는 각각 전용 스킨이 필요하다.
- 카지노 SFX는 필수다. 카드, 칩, 릴, 스핀, 승리, 패배, 잭팟 소리가 모두 분리돼야 한다.

Recommended Godot features:

- `Tween`/`AnimationPlayer`: 카드 딜, 칩 이동, 결과 배너.
- `GPUParticles2D`: 잭팟/대박 때 금색 파편, 단 과하게 쓰지 않는다.
- `ShaderMaterial`: 카드 hover, 위험 베팅 pulse.
- `AudioStreamPlayer` pool: 연속 칩/카드 소리 겹침.

### 5. Racing Minigame

현재 경마는 시스템은 흥미롭지만 화면은 아직 분석표에 가깝다.

Needed:

- 말/기수 실루엣의 가독성 강화.
- 경주 중계 카메라 느낌: 스타트, 코너, 직선, 결승선.
- 마권 UI: 선택한 말과 배당이 “내가 돈을 걸었다”는 물성을 가져야 한다.
- 결과 발표는 텍스트보다 착순 보드/사진 판독처럼 보여야 한다.

### 6. Start Menu / First Impression

첫 화면은 아직 브랜드는 있으나 게임 명제를 강하게 각인하지 못한다.

Needed:

- “50만원 → 30억 → 5년”을 첫 화면에서 명확히.
- 시작 버튼/저장 슬롯/런 테마가 하나의 게임 UI로 보여야 한다.
- legacy 문구는 즉시 제거한다. 정본 시작 자금은 50만원이다.

## Image Asset Strategy

### Keep As Godot UI

아래는 이미지 한 장으로 굳히지 않는다.

- 버튼 텍스트
- 모달 본문
- 설정/저장 슬롯
- 투자 수치/차트
- 번역 대상 텍스트
- 접근성/패드 포커스가 필요한 컨트롤

이들은 Godot `Control`, `Theme`, `StyleBoxTexture`, SVG 아이콘, `TextureRect` 조합으로 만든다.

### Convert To Image/Texture Assets

아래는 실제 이미지/스프라이트가 필요하다.

- 카드 앞면/뒷면
- 칩 denomination 세트
- 룰렛 휠/볼
- 슬롯 릴 심볼
- 경마 말/기수 스프라이트 또는 실루엣 아틀라스
- AP pip, 위험 배지, 목표 배지
- 미니게임별 테이블/펠트/마권/로드맵 스킨
- 엔딩 전용 CG

### Replace Or Regenerate Candidates

- 카드/칩: 현재 단일 카드백과 단일 칩 아이콘은 1차 임시 수준이다. 실제 게임 물체 세트로 확장 필요.
- 미니게임 HUD: 각 미니게임이 다른 웹툴처럼 보이므로 공통 카지노/도박 UI 스킨 필요.
- 엔딩 CG: `gangnam_dream`, `empty_house`, `with_daeun`, `late_call`, `mental_break/burnout`은 전용 CG가 있으면 결말 임팩트가 크게 오른다.
- Main HUD icons: 이모지 제거. `assets/ui/icons`의 SVG 또는 새 아이콘 세트로 교체.

## Audio Asset Strategy

### Immediate Need

- 카지노 전용 SFX는 필수. 카드/칩/스핀/릴/승패/잭팟이 없으면 미니게임이 바로 저가로 들린다.
- 버튼 클릭 하나로 모든 UI를 처리하면 피드백이 얕다. 선택, 취소, 위험 선택, 큰 보상, 실패, 해금, 월 전환을 분리한다.

### Next Layer

- 장소 ambience: 고시원 형광등, 편의점 냉장고, 지하철, 카지노 플로어, 경마장 함성.
- 엔딩 stinger: 승리/씁쓸함/파멸 3종.
- 미니게임 loop: 카지노 플로어는 본편 BGM과 다른 층위가 필요하다.

## Godot Motion Plan

P0:

- 빨간 위기 비네팅을 임계치 전용으로 제한.
- 이벤트/대시보드 전환 시 틴트/플래시 즉시 해제.
- 배경에 매우 약한 카메라 드리프트 적용.
- 카지노 SFX 실파일 생성 및 QA 통과.

P1:

- Main HUD/행동 버튼 공통 Theme 리팩터.
- 이모지 버튼을 SVG 아이콘 + 텍스트로 교체.
- 미니게임 카드/칩/릴/말 스프라이트 교체.
- 카지노 허브를 “게임 선택 카드”가 아니라 실제 플로어 입장 화면처럼 재구성.

P2:

- 미니게임별 AnimationPlayer 타임라인 정리.
- 엔딩 CG 3~5종 추가.
- 장소 ambience와 엔딩 stinger 추가.
- Steam 스크린샷용 8장 장면을 실제 플레이 화면 기준으로 다시 캡처.

## Current Session Fixes

- Added real casino SFX generation targets for 8 runtime keys.
- Updated CG runtime QA so it no longer expects the removed hospital CG on the `gangnam_dream` ending.
- Reduced red crisis vignette intensity and limited it to true danger thresholds.
- Added immediate tint/flash cleanup when returning to dashboard/action vignettes.
- Changed MainGame background display to covered texture mode and added subtle background drift.
- Fixed StartMenu legacy “100만원” tagline to “50만원”.
- 2026-06-27: Fixed locale QA to use the real saved language path, cleaned English investment unlock hint, enlarged the left portrait panel, and converted the final ending modal into a larger cinematic `Finale` frame.
