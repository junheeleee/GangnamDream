# Gangnam Dream Build Pipeline

> 기준 엔진: Godot 4.6.2 stable. 공개 빌드는 `main`의 깨끗한 커밋에서만 만든다.

## 1. 빌드 flavor

| Flavor | Export preset | Feature | 결과 |
|---|---|---|---|
| 정식 Windows | `Windows` | 없음 | `build/windows/GangnamDream.exe` |
| 정식 macOS | `macOS` | 없음 | `build/macos/GangnamDream.zip` |
| 정식 Linux/Deck | `Linux / Steam Deck` | 없음 | `build/linux/GangnamDream.x86_64` |
| 데모 Windows | `Windows Demo` | `gangnam_demo` | `build/demo/windows/GangnamDreamDemo.exe` |
| 데모 macOS | `macOS Demo` | `gangnam_demo` | `build/demo/macos/GangnamDreamDemo.zip` |
| 데모 Linux/Deck | `Linux / Steam Deck Demo` | `gangnam_demo` | `build/demo/linux/GangnamDreamDemo.x86_64` |
| V2 테스트 Windows | `Windows V2 Playtest` | `gangnam_demo,core_loop_v2_playtest` | `build/playtest/windows/GangnamDreamV2Playtest.exe` |
| V2 테스트 macOS | `macOS V2 Playtest` | `gangnam_demo,core_loop_v2_playtest` | `build/playtest/macos/GangnamDreamV2Playtest.zip` |
| V2 테스트 Linux/Deck | `Linux / Steam Deck V2 Playtest` | `gangnam_demo,core_loop_v2_playtest` | `build/playtest/linux/GangnamDreamV2Playtest.x86_64` |

`GameState.is_demo_build()`는 24주 차단만 판정한다. `BuildFlavor`는 별도로
`core_loop_v2_playtest`를 판정해 V2 진입·빌드 표식·사용자 데이터
네임스페이스를 한꺼번에 고른다. 에디터/CI에서는 각각 `--demo-build`와
`--core-loop-v2-playtest-build`로 같은 경로를 명시적으로 시험한다. 콘텐츠
개발 인자 `--core-loop-v2`, debug 여부, 저장 안의 `enabled` 값은 build flavor나
저장 경로를 바꾸지 않는다. 기존 Demo preset에는 playtest feature를 덧붙이지 않는다.

Retail은 기존 `gangnam_dream_{autosave,slot_N,settings,display,meta}.json`을
그대로 쓴다. V2 playtest는
`gangnam_dream_v2_playtest_v1_{autosave,slot_N,settings,display,meta}.json`만
쓴다. 두 집합의 교집합은 0이며 어느 쪽도 다른 flavor 파일을 탐색·복사·이전·
삭제하거나 파일이 없을 때 폴백하지 않는다. `v1`은 저장 schema와 별개인
테스트 네임스페이스 버전이다.

### 산출물 식별과 저장 호환

시작 화면의 기계 판독 메타, 새 세이브 루트, 빌드 매니페스트는
`BuildInfo.artifact_identity()`의 네 필드를 같은 값으로 쓴다. 플레이어가 보는
라벨은 버전·빌드 ID·채널을 표시한다. `game_version`과 `build_id`는 빌드 시점의
`BuildInfo` 상수에서 읽으며, profile별 값은 다음과 같다.

| Profile | `game_version` | `build_id` | `build_flavor` | `save_namespace` |
|---|---|---|---|---|
| full | `BuildInfo.GAME_VERSION` | `BuildInfo.BUILD_ID` | `full` | `legacy` |
| demo | `BuildInfo.GAME_VERSION` | `BuildInfo.BUILD_ID` | `demo` | `legacy` |
| V2 playtest | `BuildInfo.GAME_VERSION` | `BuildInfo.BUILD_ID` | `core_loop_v2_playtest` | `core_loop_v2_playtest_v1` |

정식판의 플랫폼별 매니페스트와 demo/V2의 묶음 `MANIFEST.sha256`은 `profile`,
위 네 필드, `save_version`, `features`, 전체 Git `revision`/`tree`, 소스 상태,
Godot 버전, 생성 시각, 산출물 SHA-256을 기록한다. 생성 직후
`tools/build_identity_audit.py`가 profile과 소스 상수를 대조한다.
묶음 `demo`·`playtest` 패키지는 발급 전 `BUILD_ID`의 `YYYY.MM.DD`가 clean
HEAD 커밋 날짜와 같은지, 첫 부모가 쓴 ID를 그대로 재사용하지 않았는지 함께
검사한다. 날짜가 다르거나 같은 리비전 번호를 물려받았으면 export 전에
중단되므로, 새 테스트 패키지를 발급할 때는 `BUILD_ID`를 `YYYY.MM.DD.N`
형식의 새 값으로 먼저 올린다. 같은 clean HEAD의 재빌드는 그 HEAD가 이미
첫 부모와 다른 ID를 소유하므로 허용된다.

`build_id`와 `game_version` 차이는 호환 키가 아니라 진단 경고다. 미래
`save_version`, 빈 식별자, 부적합한 flavor/namespace는 `GameState` 적용 전에
거부한다. 정식판 저장은 데모에서 열 수 없고, 일반적인 데모·V2 playtest
저장은 24주를 넘으면 거부한다. 단, **소스와 대상이 모두**
`core_loop_v2_playtest/core_loop_v2_playtest_v1`이고 `turn=25`, 완료 주차가
정확히 `1..24`, 완료 플래그·캡·경계 턴이 엄격한 타입과 값으로 일치하는
저장만 V2 playtest에서 다시 열 수 있다. 이는 24주 확정 후 남은 결산·CTA
영수증이지 **25주 플레이 허용이 아니다.** 임의로 조립한 turn 25, turn 26 이상,
주차 누락·중복 저장은 상태를 바꾸기 전에 거부한다. V2 playtest namespace는
이 완료 저장까지 포함해 양방향 격리한다.

저장 교체는 기존 정상 파일을 제자리에서 잘라 쓰지 않는다. 새 payload를
같은 폴더의 임시 파일에 쓴 뒤 바이트·JSON·슬롯·빌드 식별자를 다시 읽어
검증하고, 이전 primary의 바이트가 같은 verified `.bak`을 먼저 준비한 뒤에만
교체한다. 임시 쓰기·백업 준비·primary 교체·최종 검증 중 어느 단계든
실패하면 직전 정상 primary와 마지막 verified backup을 보존하고 실패를 한 번만
알린다. 재시도는 성공 신호를 한 번만 남겨야 하며, primary가 없거나 파싱
불능이면 호환되는 verified backup만 읽어 primary를 같은 바이트로 복구한다.
이 계약은 프로세스 내 교체·복구 증거이며 OS 전원 상실 시나리오까지 승인하지는 않는다.

기존 demo flavor 저장을 full loader가 인식할 수 있다는 호환 방향과 공개 제품
bridge는 다른 판정이다. 현재 BUILD `.3`의 V2 playtest 저장은 정식판과 격리돼
W25 이월 후보가 아니다. 공개 제품 bridge는 clean W1~24 demo_rc의 실제 W24 CTA
저장을 full build가 열고 W25를 정확히 한 번 시작하는 경로다. 이 별도 OPEN
이월·full-release 게이트는 데모 길이나 W1~24 사람 판정을 바꾸지 않는다.

## 2. 준비

1. Godot 4.6.2 stable editor를 설치한다.
2. Godot에서 `Editor > Manage Export Templates`를 열고 **4.6.2.stable** 템플릿을 설치한다.
3. 저장소 루트에서 다음을 확인한다.

```bash
GODOT=/Users/junheelee/Downloads/Godot.app/Contents/MacOS/Godot \
  ./tools/audit.sh

GODOT=/Users/junheelee/Downloads/Godot.app/Contents/MacOS/Godot \
  ./tools/build.sh demo-check

GODOT=/Users/junheelee/Downloads/Godot.app/Contents/MacOS/Godot \
  ./tools/build.sh playtest-check

GODOT=/Users/junheelee/Downloads/Godot.app/Contents/MacOS/Godot \
  ./tools/run_core_loop_v2_input_qa.sh full-matrix

GODOT=/Users/junheelee/Downloads/Godot.app/Contents/MacOS/Godot \
  ./tools/run_core_loop_v2_input_qa.sh surface-matrix
```

다섯 명령은 각각 마지막에 `✅ 감사 통과`, `DEMO_BUILD_CHECK_OK`,
`PLAYTEST_FLAVOR_CHECK_OK`,
`CORE_LOOP_V2_FULL_MATRIX_OK languages=ko+en devices=keyboard+gamepad weeks=24 cases=4`,
`CORE_LOOP_V2_SURFACE_MATRIX_OK languages=ko+en resolutions=1280x800+960x600 cases=4`를
정확히 출력해야 한다. `audit.sh`의 서울 사이클 밸런스 블록은 프로세스
종료 0, `CORE_LOOP_V2_CYCLE_BALANCE_OK` 정확 마커, 엔진·스크립트·파싱 오류 0을
모두 요구하는 strict gate다. 이 세 가지 24주 증거는 **동일한 clean
revision**에서 나와야 하며 하나라도 없으면 출고 후보가 아니다. Godot 공식
문서상 custom feature는
에디터 실행에는 적용되지 않고 실제 export에서만 적용되므로, 에디터 게이트의
두 build 인자는 생략하면 안 된다.

참고: [Godot feature tags](https://docs.godotengine.org/en/stable/tutorials/export/feature_tags.html), [command-line export](https://docs.godotengine.org/en/stable/tutorials/export/exporting_projects.html).

## 3. V2 플레이테스트 생성

세 플랫폼을 한 번에 만든다. `playtest`는 tracked·untracked 변경이 하나라도 있는 작업트리를 거부하므로, 사용자의 진행 중 변경을 버리지 말고 커밋하거나 별도 clean worktree에서 실행한다.

```bash
GODOT=/Users/junheelee/Downloads/Godot.app/Contents/MacOS/Godot \
  ./tools/build.sh playtest
```

이 명령은 순서대로 다음을 수행한다.

1. tracked·untracked 변경 0인 clean Git 소스 확인
2. `BUILD_ID` 날짜와 clean HEAD 커밋 날짜 일치 확인
3. Godot `--import`로 fresh checkout의 리소스·`class_name` 캐시 생성
4. 소스 재확인 후 기존 데모 flavor, t=1~8 정본 아크, t=24 허용/t=25 차단 계약 검사
5. V2 playtest 진입 1/retail release 진입 0, 전역 표식, 14개 사용자 데이터 경로
   교집합 0, 10개 preset 계약 검사
6. Windows V2 playtest export
7. macOS V2 playtest export
8. Linux/Steam Deck V2 playtest export
9. 소스 재확인 후 `build/playtest/MANIFEST.sha256` 생성

`playtest` export 자체가 §2의 full/surface matrix를 대신하지는 않는다. 배포자는
위 세 strict 증거를 같은 clean revision의 세션 원장에 남긴 뒤에만 export
해시를 후보로 등록한다.

개별 V2 빌드는 `windows-playtest`, `macos-playtest`, `linux-playtest` 타깃을
사용한다. 기존 Demo는 `demo`, `windows-demo`, `macos-demo`, `linux-demo`로
그대로 만들며 정식판은 `windows`, `macos`, `linux`, `all`을 사용한다. 개별
개발 export는 RC가 아니며 clean-tree 게이트를 통과했다고 간주하지 않는다.

배포 전 `MANIFEST.sha256`의 전체 revision/tree 해시, `source_status=clean`, 산출물 해시와 실제 테스트 기록이 같아야 한다. manifest 파일 자체의 SHA-256도 세션 원장에 기록한다. 빌드 뒤 게임 소스가 바뀌면 기존 산출물은 폐기하고 다시 만든다.

```bash
sed -n '1,10p' build/playtest/MANIFEST.sha256
shasum -a 256 build/playtest/MANIFEST.sha256
```

## 현재 240주 full_rc BUILD 2026.08.24.5 (2026-08-24, 사람 판정 OPEN)

BUILD `.4`는 clean 세 플랫폼 export 뒤 fresh 전체 감사가 stale causal source
snapshot 3건을 잡아 후보로 등록하지 않았다. 누적 `WORK_LOG.md`를 source trust
key로 쓰지 않고 승인된 두 문서 hash와 causal audit selector를 정렬한 exact clean
revision `6c91e11c128c4535f5c5852845b0e7309947e162`, tree
`da15e65977849ab8bf912f3612fa9fd511eee99d`에서 다음 미사용 ID `.5`를 처음부터
다시 만들었다. gameplay·ledger·AP 저장 호환은 이 수리에서 바뀌지 않았다.

`build/order125/2026.08.24.5`의 aggregate manifest SHA-256은
`1cef15ff75eba4e04b45d6d672ce53c8c9365d3d5a3840c51467c49a75178c8a`다.

| 산출물 | 바이트 | SHA-256 |
|---|---:|---|
| Windows EXE | 443,470,984 | `b8d3f11f2e3655884360c52514030c988f04d425e58e56762180ca39e22bf0d5` |
| macOS ZIP | 390,665,610 | `878fddb3d7fd81e88a812cfd2781c0c265b5e724a54938cad6f1fce10be99800` |
| Linux/Deck | 409,889,432 | `759af7dd214ae2ce9fa5741fa66ba380a535cfde1ec20fd8e1d705c53e506a49` |

fresh `.godot` 없는 detached worktree의 import와 전체 `audit.sh`가 exit 0,
`✅ 감사 통과` 1회, `COMPILE_CHECK_OK total=66`을 남겼다. allowlist가 명시한
종료 자원 noise 5줄 밖 금지 오류는 0이다. KO PlayStation과 EN Xbox 의미 입력은
각각 `FULL_DIRECTION_RUNTIME_OK`·`FULL_INPUT_RUN_OK` 1회, 240주,
`ending=with_daeun`, keyboard/mouse 0으로 끝났고, 별도 KO writer는 chapter
slot 6~10을 생성했다. full/V2 pack은 각 1,462 entries로 unzip·release inventory·
제3자 고지를 통과했다. R1b direct/self/runtime은 `product_consumers=0`,
`historical_invalidated`, `r1b_allowed=false`, `dispatch=0`을 재확인했다.

macOS app은 ad-hoc codesign과 x86_64+arm64 universal bundle 검사를 통과했다.
빈 HOME의 무인자 first-run은 필수 언어 게이트에서 생존했고, 같은 binary/PCK의
preseed 진단 movie probe는 StartMenu와 화면의 BUILD `.5`를 1280×800 PNG로
캡처한 뒤 exit 0이었다. 둘을 하나의 무인자 StartMenu 증거로 부르지 않는다.
실제 retail/V2 33파일의 전후 checksum manifest는 byte-exact다. 자동 증거 root는
`build/qa/order125-full-rc/2026.08.24.5`다. 이 후보를
`full_rc` active로 등록했지만 원고·A/V·실제 물리 패드·원어민·정상 속도·재미와
출시 GO를 자동으로 닫지 않는다. ORDER-124 story-first 후보와 AP 삭제 판정도
별도다.

## ORDER-103 전용 M01–M06 선택판 후보

ORDER-103 사람 판정에는 기존 `demo_rc`를 쓰지 않는다. `demo_rc`는 숫자 여력
네 장을 쓰는 W1–W24 `서울의 네 주` 기준선이며 ORDER-103 장면 카드·`주력/함께`
선택판이 아니다. 전용 후보의 앱·ZIP 이름은
`GangnamDream-ORDER103-M01M06-ChoicePlaytest`로 고정하고, 창 안에도
`ORDER-103 · M01–M06 · BUILD 2026.08.24.1` 표식을 노출한다.

후보는 제품 `project.godot`, 제품 `export_presets.cfg`, 시작 화면, 24주 runtime,
retail/V2 저장을 바꾸지 않는다. 대신 clean source commit을 저장소 밖 임시 staging에
풀고 `tools/order103_export/`의 최소 wrapper와 `resources.txt`에 열거한 M01–M06
payload만 복사해 native macOS 앱을 만든다. Finder에서 인자 없이 열면
`tools/StoryMapM1M6Playtest.tscn`만 즉시 표시한다.

```bash
GODOT=/Users/junheelee/Downloads/Godot.app/Contents/MacOS/Godot \
  ./tools/build_order103_macos.sh \
  --source "$(git rev-parse HEAD)" \
  --build-id 2026.08.24.1
```

생성기는 dirty source를 거부하고 다음 파일을 만든다.

- `build/order103/macos/GangnamDream-ORDER103-M01M06-ChoicePlaytest.zip`
- `build/order103/MANIFEST.json`
- `build/order103/MANIFEST.sha256`

`MANIFEST.json`은 profile `order103_m1m6_playtest`, build ID, flavor
`story_map_m1m6_playtest`, namespace `story_map_m1m6_playtest_v1`, save schema,
source commit/tree/clean 상태, exact Godot 버전, main scene, bundle ID, custom user-data
이름, payload·launcher·app·ZIP SHA-256, 생성 UTC, codesign 결과, 표적 검사와
package smoke marker를 기록한다. `MANIFEST.sha256`은 manifest 자체의 SHA-256이다.

전용 사용자 데이터 이름은 `GangnamDream_ORDER103_M01M06_v1`이며 이 후보는
`story_map_m1m6_playtest_autosave.json`만 직접 쓴다. 제품용 retail/V2 저장 경로를
탐색·복사·이전·삭제하지 않는다. 발급 전후 제품 저장의 바이트가 같고, 전용 경로에
예상하지 않은 save JSON이 없는지 확인한다.

자동 L2는 같은 clean source에서 다음만 검사한다.

1. 현행 `story-map-m1m6-runtime` 표적 검사
2. 1280×800 KO와 960×600 EN packaged flow
3. 첫 확인은 역할 자리로 포커스만 이동하고 두 번째 확인에서만 배정
4. 자동 배정 0, 내부 스크롤 0, 카드·역할 자리·확정 버튼 잘림/겹침 0
5. M01 종료·재실행 뒤 M02 이어하기와 M06 종료·재실행 뒤 회고 이어하기
6. 무인자 native 실행이 Splash/StartMenu/`서울의 네 주`가 아닌 전용 홈으로 진입
7. ad-hoc codesign과 manifest/app/ZIP 해시 재검증

자동 L2는 마우스 hover signal, 실제 Enter key event, D-pad/South/East mapping과
gamepad semantic action을 재생한다. 이는 물리 기기 증거가 아니다. 위 package L2가
green이면 `order103_rc`를 사람 판정용 `active` 후보로 등록하고, 실제 마우스·키보드·
물리 패드 조작감은 사용자의 L3에서 닫는다. 이 후보에 24주·240주 검사를 실행하거나
그 결과를 전용 L2 증거로 재사용하지 않는다.

### 반려된 ORDER-103 보존 후보 (2026-08-24, 사용자 NO-GO)

BUILD `2026.08.24.1`은 exact clean revision
`20ec3fb04f5068846518f28e4123e1fabfa73e34`, tree
`79cf4bd95899a44fa353bd68212f266a2b4fba09`에서 생성했다. 앱·ZIP은
`build/order103/macos/GangnamDream-ORDER103-M01M06-ChoicePlaytest.app`과
`.zip`이며 ZIP SHA-256은
`8e6a7d7930c25ec71f2a6a45ec8ac8ea7f52ae8af9a1b34d17cc63d9310fd930`다.
manifest 파일 SHA-256은
`8e22703a2ac9fc1ee92188f3519e82704271a4a4f204556c4b162f271357503d`, app tree
SHA-256은 `89ba5642040b91cfdebb7277aa761d3daa0618922058d62fc73934bd75cfe560`,
launcher SHA-256은
`b9e049e47f2eaf8d3f39aa0f934b2f8422bdf2803696a07cbe423ba0c1d91530`다.

표적 검사와 package audit, KO 1280×800·EN 960×600 flow, M02·회고 저장 재개,
무인자 전용 홈 진입, ad-hoc codesign, manifest/app/ZIP 재검산, 제품 설정 7파일과
기존 retail/V2 저장 19파일의 격리가 PASS했다. 창 하단 표식은
`ORDER-103 · M01–M06 · BUILD 2026.08.24.1`이다. 사용자가 월간 행동 계층 자체를
NO-GO해 `order103_rc`는 현재 사람 원장에서 내렸다. 앱·ZIP·해시는 반려 비교
증거로만 보존하며 새 플레이나 후속 빌드의 기반으로 사용하지 않는다. 숫자 여력
W1~W24 `demo_rc`도 스토리 선택 전용 판정의 실행 파일이 아니다.

## ORDER-124 전용 M01–M06 스토리 선택 후보

월간 `주력/함께/여력` 행동판을 되살리지 않고 실제 `StoryMode` 선택과 장면 뒤
자동 네 주·생활 정산만 검증한다. clean source를 저장소 밖에 통째로 staging한 뒤
그 복사본의 main scene과 custom user-data 이름만 바꾼다. 제품 `project.godot`,
`export_presets.cfg`, 본편 runtime과 기존 저장은 바꾸지 않는다.

```bash
GODOT=/Users/junheelee/Downloads/Godot.app/Contents/MacOS/Godot \
  ./tools/build_order124_macos.sh \
  --source HEAD \
  --build-id 2026.08.24.3
```

생성기는 dirty source와 Godot `4.6.2.stable.official.71f334935`가 아닌 엔진을
거부하고 다음을 남긴다.

- `build/order124/macos/GangnamDream-ORDER124-M01M06-StoryChoicePlaytest.app`
- `build/order124/macos/GangnamDream-ORDER124-M01M06-StoryChoicePlaytest.zip`
- `build/order124/MANIFEST.json`
- `build/order124/MANIFEST.sha256`

profile은 `order124_m1m6_story_choice`, flavor는
`order124_story_choice_playtest`, 진입은
`res://playtests/order124/StoryChoiceM1M6Playtest.tscn`이다. 전용 사용자 데이터는
`GangnamDream_ORDER124_StoryChoice_v1`, 후보 저장은
`user://story_choice_m1m6_playtest_save.json` 하나다. 빌드는 후보 경로의 기존
상태를 snapshot/복원하고 retail/V2, `demo_rc`, 반려 ORDER-103, 제품 설정,
BUILD `.2` archive와 다른 산출물의 전후 해시를 비교한다. 기존 후보 저장이
있으면 복사본을 최종 앱으로 열어 이어하기 계약을 검증한 뒤 원본 디렉터리를
byte-exact로 복원한다.

자동 L1/L2는 전용 `story-choice-m1m6-runtime` 검사, 무인자 전용 홈 진입,
KO 1280×800·EN 960×600 package smoke, ad-hoc codesign, 앱과 ZIP 내부 app tree,
launcher·PCK·source contract와 manifest를 검증한다. M01 전환과 M06 회고는
실제 StoryMode 복귀 경계에서 cover alpha·입력 차단 해제를 검사하고,
패키지 M01 복귀 smoke는 실제 `SceneTransition.go()` 페이드아웃과 장면
재로드를 거친다. 패키지의 홈·전환·회고는 두 언어·두 목표 크기로
캡처하고, 실제 `StoryMode` 선택은 최종 앱에서 직접 입력으로 확인한다. 이
후보에는 기존 24주·240주·전체 감사를 실행하거나 인용하지 않는다.

### 이전 ORDER-124 BUILD 2026.08.24.2 · 검은 전환막 NO-GO

BUILD `2026.08.24.2`는 exact clean revision
`e9aff5f06c2e3ec3708426156074674a56a4c3f6`, tree
`ad4d88a6aed68a79074f6f8e3204bf0474f6dbc4`에서 생성했다. manifest SHA-256은
`87f3491f7e526762203a83eb4ed25bbbba79981f7dc3ec812d49cdd955db1194`, ZIP은
`626196d6a74f50373ddc3e6d0cb8b3a502f052d4436f308361d8b82d3ab45a75`, app tree는
`c21d5ba71c5516465849cc7596d48ed430a4fc903eeeb7033340d36e5afb6a85`, launcher는
`291d39bfa8f6014b40745012e725eb1a398076d223ea89e1caa2d8804495c7c7`, PCK는
`04e3e67e1591df5984f804f299edcba0c95eb6e8281362d253c134df0d64b7d8`다.

표적 marker는
`STORY_CHOICE_M1M6_CHECK_OK months=6 weeks=24 settlements=6 commitments=0 routes=2 save=1 m6=1`이고
package self-test `checks=26`과 최종 audit가 PASS했다. packaged recap은 M06까지,
KO 960×600·EN 1280×800 실제 StoryMode 키보드 선택은 선택 버튼·결과 적용을
확인했다. KO 실제 경로는 M01 clean과 M02 결과 뒤 M03, 8주·정산 2회·commitment
0 저장까지 도달했다. 그러나 `StoryMode`가 후보 controller로 돌아올 때
opaque `SceneTransition` cover를 걷지 않아 장면 사이가 검게 가려졌고 M06
회고는 영구히 가려질 수 있었다. 이 BUILD는 기술 NO-GO로 superseded했다.
기존 manifest/checksum/ZIP은 `build/order124/archive/2026.08.24.2`에 남겼고,
archive 전체 SHA-256
`84b5f16dac820fd946240bf72519dea155f1ff49e1724a72aed5d35664916d41`를 후속 빌드
전후 동일하게 보존한다.

### 현재 ORDER-124 BUILD 2026.08.24.3 (2026-08-24, 사용자 판정 OPEN)

BUILD `2026.08.24.3`은 exact clean revision
`23f0bd9b7a56a352c9234f95870a98dbf5c728e9`, tree
`2dcfb0e465f2981b8058ccc03605fa98fca3f746`에서 생성했다. manifest SHA-256은
`721c9021236c158432be0b3ae47ebcd785f4e4f461b4b05d709b0d71384ca148`, ZIP은
`b66d72ce97f1d36e7902ccc79a1062e61e6627aa4aa12cdea5eb84f53c362431`, app tree는
`275f536ad1cf70b138ecda1350ef539fd20de43c904796fe59bada0ff3f194ee`, launcher는
`2f3b5301c99c78567123b3cf0575ed49c6d1ffb28c8033e213c5a1fdcf259e9e`, PCK는
`d89a005cd4313aae68140951d1c1067e5c46d0cc28aff2cd6e03871ec10546e0`다.

표적 marker는
`STORY_CHOICE_M1M6_CHECK_OK months=6 weeks=24 settlements=6 commitments=0 routes=2 save=1 m6=1 returns=2 overlay=1`이다. M01 전환과 M06 회고의 실제 복귀 후 cover·입력이 둘 다
해제되며, 패키지 M01 실제 복귀는
`ORDER124_RETURN_SMOKE_OK build=2026.08.24.3 screen=transition month=2 overlay=clear input=clear choices=1 settlements=1`로 확인했다. package self-test `checks=38`과 최종
`ORDER124_PACKAGE_AUDIT_OK`도 PASS했다.

BUILD `.2`의 사용자 저장 SHA-256
`fe1d0a0011a1a8d447ce7d46494f2454b3b09ee7c8e2f6596d827a6cd8db734b`는
`phase=story`, M03, 8주, 정산 2회, 선택 2개 상태다. 최종 `.3` 앱은 복사본을
`ORDER124_RESUME_SMOKE_OK build=2026.08.24.3 month=3 weeks=8 settlements=2 choices=2 phase=story screen=transition overlay=clear input=clear`로 열었고 원본 저장을 변경하지 않았다.

제품 `project.godot`·`export_presets.cfg`, retail/V2, `demo_rc`, 반려
ORDER-103 앱·저장·산출물, BUILD `.2` archive, ORDER-124 사용자 디렉터리는
패키지 검사 전후 byte-exact다. `order124_rc`는 active지만 사용자 L3와 본편
이관은 OPEN/HOLD다. 이 격리 후보에 기존 24주·240주·전체 감사를 실행하거나
인용하지 않았다.

## 4. 자동 스모크

### 계약 스모크

`tools/DemoBuildCheck.tscn`은 다음을 실제 코드 경로로 검사한다.

- 부팅 main scene이 `SplashScreen.tscn`인지
- 정식 preset에는 `gangnam_demo`가 없고 데모 preset에만 있는지
- t=1~8이 챕터 카드 → 첫 면접 → 통장 계산 → 쉬운 돈 → SNS → 카페 → 현수 → 1막 종료 순서인지
- 선택 효과와 follow-up을 적용한 뒤 `chapter1_closed`가 생기는지
- 24주차를 끝까지 허용하고 25주차 진입 전에 데모 기록 CTA로 막는지

`tools/PlaytestFlavorCheck.tscn`은 playtest build 인자를 함께 받은 실제
autoload·StartMenu 코드에서 다음을 검사한다.

- release playtest의 V2 진입은 정확히 1개이고 retail release 정책은 0개인지
- 기존 retail/Demo preset에 playtest feature가 없고 신규 세 preset에 두 feature가 있는지
- retail과 playtest의 설정·화면·메타·자동저장·수동 슬롯 1~10 경로 교집합이 0인지
- 창 제목·시작 화면 build identity·전 장면 corner marker 중 flavor 누락이 없는지
- `runtime_default=false`와 24주 cutoff가 유지되고 feature만으로 런을 몰래 켜지 않는지

### W1~24 audited-prefix 서울 사이클·결산·저장 스모크

- `CoreLoopV2CycleBalanceCheck.tscn`은 fresh 실제 배치로 생계·성장·사람·회복
  24주 경로와 고비용 사망 경로를 돌린다. `audit.sh`는 위의 exact marker·종료
  상태·오류 0을 함께 판정하며, 예전 48 루틴 커널은 이 게이트를 대체하지
  못한다.
- `full-matrix`는 KO/EN×키보드/게임패드 네 경로로 24개 실제 배치와
  완료 CTA까지 도달하고, `surface-matrix`는 KO/EN×1280×800/960×600에서
  보드와 결산을 렌더한다. 하위 케이스의 PASS가 있어도 매트릭스 자체의 exact
  marker가 없으면 실패다.
- 새 24주 경계는 종료 순간의 돈·고정지출·몸·마음·주거·배경·재정 사다리·
  유혹 영수증을 동결한 snapshot을 소유한다. 실행 중 HUD를 바꾸어도 첫 요약,
  1~6개월 상세, 미결 페이지가 경계 값을 그대로 읽어야 한다. 패드로 상세·페이지·
  행을 이동하고 960×600과 1280×800에서 첫 요약과 CTA가 스크롤 없이 보여야 한다.
- 결산 자동저장이 실패하면 South는 제목으로 나가지 않고 같은 결산에서
  재시도한다. 성공 후에만 종료 CTA가 열린다. 사전 snapshot이 없는 지원 대상
  구 완료 저장은 복원할 수 있는 영수증만 보여 주고 나머지를 `기록 없음 /
  NOT RECORDED`으로 남긴다. 현재 HUD로 빈칸을 발명하거나 예전 결산 모달로
  폴백하면 실패다.
- `ManualSaveCheck.tscn`은 임시 파일 재독·verified backup·실패 보존·재시도·
  유효한 backup 복구와 봉인된 V2 turn-25 예외를 실제 슬롯 IO로 검사한다.
  `audit.sh`에서는 `MANUAL_SAVE_CHECK_OK`와 종료 0, 엔진·스크립트·파싱 오류 0을
  모두 요구하는 strict gate다.

### 제3자 고지 스모크

`python3 tools/third_party_notice_audit.py --self-test`는 실제 원장에서 설정의
제3자 고지 데이터를 다시 만들 수 있는지 검사한다. 현재 원장은 Godot Engine
4.6.2 1개, 서체 3패밀리/6파일, 오디오 21원천/139파일이며 제공자·라이선스·출처를
UI 코드에 복사하지 않는다. 필수 저작자 표시는 Salamander Grand Piano 1원천이며,
말발굽 출하 파일은 pack 전체 설명이 아니라 실제 `ground.mp3`의 D4XX·CC0 기록을
쓴다. 10개 export preset은 Godot MIT와 내장 구성요소 `COPYRIGHT.txt`, 세 OFL
1.1 사본, 생성된 오디오 고지·원장과 고지 JSON을 포함해야 한다.

Full과 V2의 실제 export-pack ZIP을 만든 뒤에는 소스 검사와 별도로 필수 10파일의
패키지 바이트를 대조한다.

```bash
python3 tools/third_party_notice_audit.py \
  --pack-zip build/qa/release_content_inventory/full.zip \
  --pack-zip build/qa/release_content_inventory/v2.zip
python3 tools/release_content_inventory.py \
  --pack-zip retail_full=build/qa/release_content_inventory/full.zip \
  --pack-zip v2_playtest=build/qa/release_content_inventory/v2.zip
```

### 시각 스모크

실제 렌더러로 KO/EN을 각각 확인한다.

```bash
GODOT=/Users/junheelee/Downloads/Godot.app/Contents/MacOS/Godot

"$GODOT" --rendering-driver opengl3 --resolution 1280x800 \
  res://tools/ScreenshotQA.tscn -- \
  --qa=demo-blackbox --lang=ko --demo-build

"$GODOT" --rendering-driver opengl3 --resolution 1280x800 \
  res://tools/ScreenshotQA.tscn -- \
  --qa=demo-blackbox --lang=en --demo-build
```

`/tmp/gangnamdream_qa`에서 최소한 언어 선택, JUNPAC 스플래시, 콜드오픈, 시작 메뉴, Y1 카드, t=1~8 장면, AP 루프, 6개월 기록 CTA를 육안 검사한다. 한글 격리, 잘린 CTA, 빈 이미지, 잘못된 초상/배경은 빌드 중단 사유다.

제3자 고지 화면은 KO/EN 각각 960×600과 1280×800에서 별도로 렌더한다.

```bash
for size in 960x600 1280x800; do
  for lang in ko en; do
    "$GODOT" --rendering-driver opengl3 --resolution "$size" \
      res://tools/ScreenshotQA.tscn -- \
      --qa=third-party-notices --lang="$lang"
  done
done
```

엔진/서체/오디오 탭, 긴 MIT·Godot COPYRIGHT·OFL 본문의 스크롤, 2.5% 안전영역, 영문 한글
누출 0, East/Esc 닫기와 설정 버튼 포커스 복귀를 확인한다. 자동 렌더는
가독성과 법무 판단을 대신하지 않는다.

## 5. 실제 패키지 스모크

교차 export 성공은 해당 OS 실행 성공을 뜻하지 않는다. 공개 테스트에 보낼 플랫폼마다 그 플랫폼에서 아래를 한 번 통과해야 한다.

1. 터미널 인자를 붙이지 않고 OS의 일반 실행 방식으로 V2 playtest 산출물을 연다.
2. retail 파일을 지우지 말고, playtest 전용 저장이 없는 테스트 계정에서 시작한다.
3. 모든 장면 우상단에 `V2 TEST BUILD · SEPARATE SAVE` 계열 표식이 있고 창 제목과
   시작 화면 build identity에도 `CORE LOOP V2 · PLAYTEST`가 있는지 확인한다.
4. 언어 선택이 먼저 뜨고 KO/EN 선택이 즉시 전 표면에 적용되는지 확인한다.
5. JUNPAC 스플래시 → 시작 메뉴까지 막힘 없이 가고 기본 포커스가
   `24주 데모 시작 / Start 24-Week Demo`인지 확인한다. legacy 새 이야기는 보이면 안 된다.
6. 전용 진입을 누르고 콘텐츠 경고 뒤 V2 서울 사이클의 네 주간 여력·네 노드
   보드까지 확인한다.
7. 24주까지 실제 입력으로 완주해 동결 결산 요약, 1~6개월 상세와 미결 페이지,
   자동저장 성공 후 CTA, 실제 Week 25 진입 차단을 확인한다. 자동저장 실패
   표본은 같은 화면에서 재시도해 성공 전에 제목으로 나갈 수 없어야 한다.
8. 크래시, 무한 전환, 입력 포커스 소실, 배경/BGM 재시작, 한글 누출을 기록한다.
9. 테스트 빌드 파일의 SHA-256을 `MANIFEST.sha256`과 대조한다.

Mac에서 만든 Windows/Linux 산출물은 **산출물 생성 검증**까지만 인정한다. Windows와 Steam Deck/Linux 실행 스모크는 각 기기에서 별도 수행해야 공개 배포 가능 상태다.

### 기존 Demo 로컬 증적 (2026-07-13)

| 대상 | 결과 | 범위 |
|---|---|---|
| Windows Demo export | PASS | 공식 4.6.2 템플릿으로 PE 패키지 생성·SHA-256 기록 |
| macOS Demo export/run | PASS | 격리 HOME, 영어 최초 실행, 언어 선택→JUNPAC→콜드오픈→W1~W8→AP 복귀 실제 입력 |
| Linux/Steam Deck Demo export | PASS | 공식 4.6.2 템플릿으로 ELF 패키지 생성·실행 권한·SHA-256 기록 |
| KO/EN render regression | PASS | `demo-blackbox` 언어별 17컷, CTA 첫 화면·한글 격리·빈 이미지 없음 |

Windows와 Linux/Deck의 `run` 칸은 아직 미검증이다. macOS 실주행 중 발견한 직종별 첫 출근 장면과 월초 AP 상한 표기 회귀는 빌드 실패가 아니라 콘텐츠/루프 QA 항목으로 `ORDER-10`에 이관했다.

### V2 flavor-proof 로컬 증적 (2026-08-03, 외부 RC 아님)

| 대상 | 결과 | 범위 |
|---|---|---|
| Flavor contract | PASS | release V2 진입 1/retail 0, 정확히 두 custom feature를 가진 신규 preset 3개, 게임 쓰기 경로 14개씩·교집합 0, 전역 표식 1, `runtime_default=0`, cutoff 24 |
| Windows V2 export | PASS · 생성만 | PE32+ x86-64 산출물과 manifest 해시 생성. Windows native run은 OPEN |
| macOS V2 no-argument entry smoke | PASS · 진입까지만 | 일반 앱 실행으로 최초 언어 선택→JUNPAC→KO/EN 시작 메뉴, build identity·전역 표식, fresh playtest 데이터의 24주 단일 기본 진입, 콘텐츠 안내→V2 도입 장면 확인 |
| Linux/Deck V2 export | PASS · 생성만 | ELF64 x86-64 산출물과 manifest 해시 생성. Linux/Deck native run은 OPEN |
| §5 전체 package smoke | OPEN | 서울 사이클 보드, 실제 1→24주·동결 결산·재시도·CTA·실제 Week 25 차단, 연속 A/V·입력은 아직 판정하지 않음 |
| External/human evidence | RETIRED | 당시 `demo_rc`는 재빌드 대기였고 외부 표본 0/10. 이 flavor-proof 산출물은 외부 후보로 등록하지 않음 |

flavor-proof는 `BUILD 2026.08.03.1`, revision
`835452bc01ea97316d9dfafeaa79b8c862cca595`, tree
`d9f97570e92913ec1bb7c21a55ad5e63613b0bba`의 clean source에서 만들었다.
manifest 파일 SHA-256은
`de02b11231a47e40b8b1d768bf36c9979662aab4a410c69728abab46a5f39504`,
Windows/macOS/Linux artifact SHA-256은 각각
`531f7e906bf6f6c2fff6926b58c8262442d53a9244768d13325de5234ee49dfc`,
`9b90ba5d6831c3edabd64c3fec90d8a15c2c3686500b530629f6e8c250988072`,
`8e325325e0b3b1502d3b38ddf3c7931ac48aa092ffce5dc8d6d57589016acee0`다.
이는 exact artifact provenance일 뿐 최종 V2 demo RC나 출시 GO가 아니다.

### 역사 V2 집 플레이 후보 (2026-08-11, superseded)

BUILD `2026.08.11.2`는 clean revision
`5736061916626a193dab4fd044ef44813938c4f7`, tree
`c996b98369fe9df6eeb2a76b04a306b69d218e04`에서 세 플랫폼을 export했다.
manifest 파일 SHA-256은
`9cecaede2e51fd4401d336c0567dc86e96c862767cf134e0cb82c2174380fb56`다.
macOS 패키지는 일반 앱 실행으로 타이틀, `Start 24-Week Demo`, 설정의 진동
ON/OFF·강도까지 실제 확인했다. Windows와 Linux/Steam Deck는 생성·해시만
확인했다. 이 provenance는 당시 후보의 역사 증거로 보존하지만 BUILD
`2026.08.22.1`이 active `demo_rc`를 이어받았으므로 새 표본·현재 PASS·출시 GO에
재사용하지 않는다.

### 현재 내부 V2 demo_rc (2026-08-22, 자동 재검증 PASS·사람 판정 OPEN)

BUILD `2026.08.22.1`은 exact clean revision
`ebc58a839d64d8810b9da5548c20e58bc43c9e30`, tree
`f978a22525b678ef83619dc50094a6dada75f190`의 active 내부 `demo_rc`다. manifest
SHA-256은 `8a34920038962a4ba0885ad6189d92dc6d3c3ee2780020f3894938d380613177`,
artifact SHA-256은 Windows
`515bc3c94a96f3874d681f409bbe0863734f44aced95d2e45b82c77e720d2ad7`, macOS ZIP
`065ab253645f1a3975fefa2de837174e6dbdb5e0d8ad9bfdd5b9836cdd015a75`, Linux
`9ed556ef1b23a575848056a6f68672d1485c24c1fa6097fd049d59f2cbd00f7`다.

2026-08-24 별도 clean detached checkout에서 full-matrix
`CORE_LOOP_V2_FULL_MATRIX_OK ... cases=4`, surface-matrix
`CORE_LOOP_V2_SURFACE_MATRIX_OK ... cases=4`, `INPUT_MATRIX_CHECK_OK`,
`CONTROLLER_SEMANTIC_CHECK_OK`, `GAME_AUDIO_RUNTIME_OK`, `DEMO_BUILD_CHECK_OK`,
`PLAYTEST_FLAVOR_CHECK_OK` exact marker와 종료코드 0을 다시 확인했다. 금지된 엔진·
스크립트·파싱·컴파일·리소스 오류는 0이다. InputMatrix 종료의
`ERROR: 3 resources still in use at exit` 한 줄만 `audit.sh`가 명시적으로 허용하는
teardown noise이며 다른 `ERROR:`의 허용 근거가 아니다.

증거 root는 `build/qa/order98-demo-rc-rebind`이고 durable receipt
`VERIFICATION.md` SHA-256은
`daec538d25952e375d6967d597f64b59c80a0e331eeb05f497acb06141ed5017`다. 로그 SHA-256은 import
`2beaa11e4ec48401b975968dd21799afe20246ebd58fdc78ce13cc4d9d3bc7d5`, InputMatrix
`8025d4164971d9334d51b8c94ea53dba7666ab21e2a720c8c0dedce6dd5fea59`, Controller
`4c6e7f105738eef9b7a196de132ab5e7ede34b873905ba984d541fa602f6820d`, GameAudio
`3163c548e390a2dc7b0f3f4738d939e5b6238e1cb34e3994ab880ba69234eb78`, DemoBuild
`cc1276a2aec0dddadf3804fb824cede92307ce2fc5904419a0392863c53cecb2`, PlaytestFlavor
`983b5b5e611da090891fa963ecf49eb91788a4593eeca55dd9e57b73d0c9256a`다.

이는 자동 L1/L2와 내부 후보 identity만 다시 묶는다. Windows·Linux/Steam Deck
native 실행, 실제 물리 패드 Batch A 3표면·Batch B 3게임, 정상 속도 W1~24,
연속 A/V·외부 독해·원어민·재미 판정은 계속 `OPEN`이며 출시 GO가 아니다.

### 외부 정상 독해 RC 게이트 (2026-07-21)

| 대상 | 결과 | 범위 |
|---|---|---|
| Dirty source rejection | PASS | tracked·untracked 변경이 있는 `playtest` 즉시 중단 |
| Fresh checkout import | PASS | `.godot` 캐시 0에서 `--import` 완료 후 `DEMO_BUILD_CHECK_OK` |
| Provenance manifest | PASS | 전체 commit/tree·`source_status=clean`·Godot 버전·생성 UTC·3종 SHA-256 |
| Session schema v2 | PASS | 중복·혼합 빌드·플랫폼 해시 이탈·필드/점수 오류 및 망설임 bool/장면/원문 계약 거부 |
| Aggregator fixtures | PASS | 10건: 준비/미달/NO-GO/P0/중복/혼합/점수/enum/망설임 저표본·필수 원문 |
| Human evidence | OPEN | 같은 RC 10명, EN 3명, 경험 양 군, 구체 계획 70% 필요 |

**외부 30분 표본 package/session 묶음은 아직 미발급이다.** 위 active 내부
`demo_rc` 등록은 자동 재검증과 집 플레이 기준선을 뜻할 뿐 외부 모집 승인이 아니다.
외부 세션에는 같은 candidate의 package hash와 session schema를 별도로 봉인해야
하며, 다른 후보의 해시는 `playtest_report.py`가 거부해야 한다.

**RETIRED — 역사 증거만 보존, 새 세션·현 출시 판정에 사용 금지.** ORDER-43
본편 오디오 자동 확산 RC의 소스 revision은
`e849a6af2aed4aa1c7fc5a7785f59ac1b7ac952d`, tree는
`95a0674b05987efd62558f7aab09a64df0056042`, 매니페스트 파일 SHA-256은
`26287c8124bb0838dbe2062f5d8072d819b164569162af773c091ad28b644cab`다. 산출물
SHA-256은 Windows `ea0ab3fe50ff2a5038a23c6cd573c94963b0faacfb850e88726ba91c5806111f`,
macOS `4495d2424b13bad545870bacc7a460b2764895c20f7d39dd8331a69676e232cd`,
Linux·Steam Deck `6858217e11fc6820d00f5be4cacb13e16e7f859ad534aefbfa572449bd95a55a`다.
별도 clean worktree의 fresh import와 `DEMO_BUILD_CHECK_OK`, 세 export, 로컬 복사
뒤 재검산, 격리 HOME macOS 부팅을 통과한 당시 빌드지만 V2 이전이며 표본은
`0/10`이다. 이후 게임플레이·콘텐츠가 크게 바뀌었으므로 새 후보를 대신하지 않는다.

자동 게이트는 표본이 `READY_FOR_HUMAN_VERDICT`인지만 판정하며 재미·출시 GO를 선언하지 않는다. Windows와 Linux/Deck의 물리 기기 실행 스모크도 계속 OPEN이다.

이 절의 PASS는 저장 복구 체크포인트와 전반부 회귀만 증명한다. W25~48의 24개
실제 행동 행, W48 정산/생존 분기, Chapter 1 완료를 대신하지 않는다.

### 공개 데모→정식판 Week 25 이월 `[OPEN full-release/continuation 블로커]`

봉인된 V2 playtest turn-25 저장을 다시 열거나 legacy component를 W48까지
돌리는 것은 이월 증거가 아니다. V2가 공개 demo flavor로 승격된 뒤에는 같은
산출물의 실제 프롤로그→W24 행동·6월 정산→First Bill→CTA가 만든 저장을 별도
full-build 프로세스에서 연다. 데모에서는 W25가 절대 시작되지 않아야 하며,
full build에서만 정상 경제·조작을 복구하고 W25를 정확히 한 번 시작해 W28까지
주행한다. 24개 행동 영수증·프롤로그·실제 본 장면 이력이 보존되는지 같은
플랫폼 패키지에서 확인한다. 이 게이트 전에는 공개 데모 저장의 정식판 이어하기를
지원한다고 표시하지 않는다. 데모 자체의 W1~24 출시·사람 GO와는 별도다.

## 6. 스모크 기록

| 항목 | 기록 |
|---|---|
| 날짜/테스터 |  |
| commit/revision · tree |  |
| manifest 파일 SHA-256 |  |
| 플랫폼 산출물 SHA-256 |  |
| OS/기기/해상도 |  |
| 언어/입력 장치 |  |
| 무인자 부팅→언어 선택→시작 메뉴 | PASS / FAIL |
| build identity·전역 표식 | PASS / FAIL |
| fresh 데이터의 W1~24 prefix 진입 | PASS / FAIL |
| CycleBalance strict exact marker·오류 0 | PASS / FAIL |
| full-matrix exact marker | PASS / FAIL |
| surface-matrix exact marker | PASS / FAIL |
| 전용 진입→V2 서울 사이클 보드 | PASS / FAIL |
| 실제 W1→24→동결 요약·6개월·미결→진단 CTA | PASS / FAIL |
| 자동저장 재시도·구저장 unknown 표면 | PASS / FAIL |
| `.3`에서 실제 Week 25 진입 차단 | PASS / FAIL |
| 최종 W1→48 Chapter 1 완료 | OPEN / PASS / FAIL |
| 공개 Chapter 1→full Week 49 이월 | OPEN / PASS / FAIL |
| 중단/오류 |  |
| 증적 경로 |  |

무인자 진입 스모크 `PASS`와 W1~24 prefix 완주 `PASS`는 별도 판정이다. 현재
`.3` 증거를 닫으려면 서울 사이클 보드부터 24주 동결 결산·상세·미결·진단 CTA와
Week 25 차단까지 실제 입력으로 가야 한다. 최종 공개 후보는 그와 별도로 같은
clean W1~48 경로와 위 Week 49 bridge를 통과해야 한다.
