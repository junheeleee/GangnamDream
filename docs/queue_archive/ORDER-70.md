# Archived Queue Spec: ORDER-70

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [x] ORDER-70 [P0·빌드] 외부 테스터가 실제 V2 release 빌드를 바로 연다

**착수 파일:** `systems/BuildFlavor.gd`, `systems/BuildInfo.gd`,
`systems/DemoCoreLoopV2.gd`, `autoloads/SaveManager.gd`,
`autoloads/MetaProgression.gd`, `autoloads/DisplayManager.gd`,
`autoloads/ModLoader.gd`, `autoloads/SceneTransition.gd`,
`scenes/StartMenu.gd`, `export_presets.cfg`, `tools/build.sh`,
`tools/PlaytestFlavorCheck.gd`, `tools/PlaytestFlavorCheck.tscn`,
`tools/audit.sh`, `tools/audit_select.py`, `tools/audit_scope.json`, `docs/BUILD_PIPELINE.md`,
`docs/QA_CHECKLIST.md`, `docs/PLAYTEST_KIT.md`, `docs/PROPOSALS.md`와
큐/완료 증거 문서(`CLAUDE.md`, `docs/CODEX_QUEUE.md`, `docs/WORK_LOG.md`,
`docs/HANDOFF.md`, `docs/STATUS.md`, 이 사양).

**착수 설계 판정:** 기존 retail·Demo preset과 파일 경로는 문자 그대로 보존하고
Win/macOS/Linux `V2 Playtest` preset만 추가한다. 새 `BuildFlavor`가 실제
`core_loop_v2_playtest` feature와 CI 전용
`--core-loop-v2-playtest-build`만 판정하며, 콘텐츠 QA 인자·debug·저장 내부
V2 상태는 flavor를 바꾸지 않는다. 플레이테스트는 슬롯·메타·설정·화면 설정을
`gangnam_dream_v2_playtest_v1_*`에만 쓰고 retail 파일을 탐색·이전·삭제하거나
없을 때 폴백하지 않는다. release 플레이테스트 시작 화면의 기본 새 이야기 자리는
전용 24주 진입 하나로 대체하고, debug는 종전처럼 별도 V2 진입을 유지한다.

**실행 중 발견한 정합 확장:** 장면 선택이 `MetaProgression`을 즉시 쓰고 언어·
모드 설정과 화면 모드도 같은 `user://`를 공유하므로 슬롯만 분리하면 retail
오염 0을 보증할 수 없다. 네 저장 소유자를 모두 같은 flavor 계약에 연결한다.
신규 `BuildFlavor.gd`와 `PlaytestFlavorCheck.gd`는 clean import가 만드는 필수
companion `.gd.uid`까지 추적해야 `build.sh playtest`의 untracked 0 조건과
충돌하지 않는다. 기존 QA의 retail 상수는 호환 조회용으로 보존하고 생산 읽기·
쓰기만 동적 경로를 사용한다.

**검토 중 발견한 감사 확장:** 변경 파일 기반 표적 감사가 Godot 장면의 프로젝트
인자를 전달하지 않아 정상인 Demo·playtest flavor 검사를 실패로 보고했다. scene별
`args`를 `audit_scope.json`에 선언하고 `audit_select.py`가 `--` 뒤에 넘겨,
전체 감사와 표적 감사가 같은 flavor 계약을 실행하게 한다.

**사용자 승인 (2026-08-03):** `PROPOSALS.md` P-2 권고대로 진행한다.

## 깊이 3문

1. 지우면 `playtest` release 빌드는 V2 버튼이 없어 기존 5년판을 시험한다.
2. 플레이테스트 빌드의 선택은 별도 세이브에 남고 retail 세이브에는 닿지 않는다.
3. `debug`, `core_loop_v2_playtest`, retail 기본값이 서로 다른 배포 목적을 경쟁한다.

## 배치 A — 전용 flavor

- `core_loop_v2_playtest` feature에서만 V2 진입 버튼과 항상 보이는 테스트 표식을
  연다. retail의 `runtime_default=false`는 유지한다.
- 테스트 세이브를 retail/기존판과 분리하고 창 제목·시작 화면에 flavor를 표시한다.

## 배치 B — 배포 경계 회귀

- export preset·`build.sh playtest`·진입/세이브 회귀를 같은 계약으로 묶는다.
- 터미널 인자 없이 release 산출물을 실행해 V2 24주 진입이 보이는지 확인한다.

## 완료 증거

- release playtest V2 진입: `1`, retail 기본 V2 진입: `0`
- playtest/retail 세이브 경로 충돌: `0`
- 빌드 flavor 미표시 경로: `0`

## 정본 승격 판정

- **승격:** `docs/BUILD_PIPELINE.md` §1·§2·§3·§4·§5가 빌드 feature와
  CI 쌍둥이 인자, 세 플랫폼 preset, 게임 쓰기 데이터 14경로 분리, clean-tree 산출·manifest,
  무인자 패키지 검증을 소유한다.
- **승격:** `docs/QA_CHECKLIST.md`의 `V2 release playtest flavor` 행이
  retail 기본값 0, 전용 진입 1, 전역 표식, 교차 flavor 이전·폴백 0을
  지속 회귀로 소유한다.
- **승격:** `docs/PLAYTEST_KIT.md` §2가 실제 세션의 manifest·산출물
  해시 대조, 전용 사용자 데이터, 표식·24주 기본 진입 확인을 소유한다.
- **일회성:** 착수 파일 목록, companion `.gd.uid`,
  구현 커밋·트리·해시와 로컬 패키지 크기는 이 오더의 구현·진단
  세부다. 제품 출시 GO나 외부 RC 식별자로 승격하지 않는다.

## 완료 보고 (2026-08-03)

- `core_loop_v2_playtest` release flavor와 Windows/macOS/Linux 전용 preset을
  추가했다. 기존 retail·Demo preset, 산출물 경로, `full`/`demo` 표시는
  변경하지 않았고 retail `runtime_default=false`도 유지했다.
- release playtest의 일반 새 이야기 자리는
  `24주 데모 시작 / Start 24-Week Demo` 하나로 대체된다. 전용 저장이 없는
  첫 실행에서는 이 버튼이 기본 포커스를 받는다. 창 제목·시작
  화면·모든 장면의 고정 표식은 flavor와 별도 저장을 계속 밝힌다.
- 설정·화면·메타·자동저장·수동 슬롯 1~10의 retail/playtest
  14경로 교집합은 `0`이다. 생산 읽기·쓰기는 현재 flavor 경로만 쓰며
  다른 flavor를 탐색·이전·삭제·폴백하지 않는다.
- `BUILD 2026.08.03.1`의 clean 구현 커밋
  `835452bc01ea97316d9dfafeaa79b8c862cca595`, 트리
  `d9f97570e92913ec1bb7c21a55ad5e63613b0bba`에서 세 플랫폼 export가
  완료됐다. manifest 파일 SHA-256은
  `de02b11231a47e40b8b1d768bf36c9979662aab4a410c69728abab46a5f39504`,
  Windows/macOS/Linux 산출물은 각각
  `531f7e906bf6f6c2fff6926b58c8262442d53a9244768d13325de5234ee49dfc`,
  `9b90ba5d6831c3edabd64c3fec90d8a15c2c3686500b530629f6e8c250988072`,
  `8e325325e0b3b1502d3b38ddf3c7931ac48aa092ffce5dc8d6d57589016acee0`다.
- macOS 산출물을 터미널 인자 없이 실행했다. 최초 언어 선택,
  JUNPAC, KO·EN 시작 메뉴에서 전역 표식·빌드 정체성·전용 진입을
  실제로 확인했고, 전용 진입은 콘텐츠 안내 뒤 V2 도입 장면까지 열렸다.
- `PLAYTEST_FLAVOR_CHECK_OK feature=core_loop_v2_playtest entry=1 retail_entry=0 paths=14 collisions=0 presets=10 marker=1 runtime_default=0 cutoff=24`,
  `DEMO_BUILD_CHECK_OK`, 59개 GDScript 컴파일, 한영 누출 0,
  정적 감사 오류·경고 0, surface 기준선 무악화와 전체
  `GODOT=… ./tools/audit.sh`를 통과했다.
- 이 증거는 flavor·산출 경계를 닫지만 외부 V2 RC 발급, Windows·
  Linux 실기기 실행, 정상 속도 24주 완주·재미·연속 A/V 사람 GO는
  닫지 않는다.
