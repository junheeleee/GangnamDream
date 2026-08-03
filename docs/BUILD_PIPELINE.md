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

`build_id`와 `game_version` 차이는 호환 키가 아니라 진단 경고다. 미래
`save_version`, 빈 식별자, 부적합한 flavor/namespace는 `GameState` 적용 전에
거부한다. 데모 저장은 정식판으로 이어갈 수 있지만 정식판 저장은 데모에서 열 수
없고, 데모와 V2 playtest는 24주를 넘은 저장을 거부한다. V2 playtest는
namespace도 양방향 격리한다.

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
```

세 명령은 각각 마지막에 `✅ 감사 통과`, `DEMO_BUILD_CHECK_OK`,
`PLAYTEST_FLAVOR_CHECK_OK`를 출력해야 한다. Godot 공식 문서상 custom feature는
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
2. Godot `--import`로 fresh checkout의 리소스·`class_name` 캐시 생성
3. 소스 재확인 후 기존 데모 flavor, t=1~8 정본 아크, t=24 허용/t=25 차단 계약 검사
4. V2 playtest 진입 1/retail release 진입 0, 전역 표식, 14개 사용자 데이터 경로
   교집합 0, 10개 preset 계약 검사
5. Windows V2 playtest export
6. macOS V2 playtest export
7. Linux/Steam Deck V2 playtest export
8. 소스 재확인 후 `build/playtest/MANIFEST.sha256` 생성

개별 V2 빌드는 `windows-playtest`, `macos-playtest`, `linux-playtest` 타깃을
사용한다. 기존 Demo는 `demo`, `windows-demo`, `macos-demo`, `linux-demo`로
그대로 만들며 정식판은 `windows`, `macos`, `linux`, `all`을 사용한다. 개별
개발 export는 RC가 아니며 clean-tree 게이트를 통과했다고 간주하지 않는다.

배포 전 `MANIFEST.sha256`의 전체 revision/tree 해시, `source_status=clean`, 산출물 해시와 실제 테스트 기록이 같아야 한다. manifest 파일 자체의 SHA-256도 세션 원장에 기록한다. 빌드 뒤 게임 소스가 바뀌면 기존 산출물은 폐기하고 다시 만든다.

```bash
sed -n '1,10p' build/playtest/MANIFEST.sha256
shasum -a 256 build/playtest/MANIFEST.sha256
```

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
6. 전용 진입을 누르고 콘텐츠 경고 뒤 V2 월간 네 약속 화면까지 확인한다.
7. 24주까지 실제 입력으로 완주해 완료 회고·CTA와 t=25 차단을 확인한다.
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
| §5 전체 package smoke | OPEN | 월간 네 약속 화면, 실제 1→24주·CTA·t=25 차단, 연속 A/V·입력은 아직 판정하지 않음 |
| External/human evidence | OPEN | `human_gates.json`의 `demo_rc`는 재빌드 대기이며 외부 표본 0/10. flavor-proof 산출물을 외부 후보로 등록하지 않음 |

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

### 외부 정상 독해 RC 게이트 (2026-07-21)

| 대상 | 결과 | 범위 |
|---|---|---|
| Dirty source rejection | PASS | tracked·untracked 변경이 있는 `playtest` 즉시 중단 |
| Fresh checkout import | PASS | `.godot` 캐시 0에서 `--import` 완료 후 `DEMO_BUILD_CHECK_OK` |
| Provenance manifest | PASS | 전체 commit/tree·`source_status=clean`·Godot 버전·생성 UTC·3종 SHA-256 |
| Session schema v2 | PASS | 중복·혼합 빌드·플랫폼 해시 이탈·필드/점수 오류 및 망설임 bool/장면/원문 계약 거부 |
| Aggregator fixtures | PASS | 10건: 준비/미달/NO-GO/P0/중복/혼합/점수/enum/망설임 저표본·필수 원문 |
| Human evidence | OPEN | 같은 RC 10명, EN 3명, 경험 양 군, 구체 계획 70% 필요 |

**현재 V2 외부 표본 RC는 미발급이다.** Core Loop V2 출시 블로커가 main에
합쳐진 뒤 clean worktree의 `playtest`가 만든 commit/tree/manifest/플랫폼 해시를
`human_gates.json` 후보 레지스트리에 등록하기 전에는 외부 세션을 모집하지 않는다.
같은 해시끼리 모였더라도 현재 후보와 다르면 `playtest_report.py`가 거부해야 한다.

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
| fresh 데이터의 24주 단일 진입 | PASS / FAIL |
| 전용 진입→V2 월간 네 약속 | PASS / FAIL |
| 실제 1→24주→회고·CTA | PASS / FAIL |
| t=25 진입 전 차단 | PASS / FAIL |
| 중단/오류 |  |
| 증적 경로 |  |

무인자 진입 스모크 `PASS`와 24주 완주 `PASS`는 별도 판정이다. §5.1~6을
닫으려면 월간 네 약속 화면까지 실제 입력으로 가야 하고, §5.7은 같은 산출물로
24주 회고·CTA와 t=25 차단까지 정상 속도로 완주해야 한다.
