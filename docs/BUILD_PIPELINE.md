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

`GameState.is_demo_build()`만 flavor를 판정한다. 정식판과 데모판의 게임 코드는 같고, 데모 export preset에만 `gangnam_demo` custom feature가 붙는다. 에디터/CI에서는 `--demo-build` 인자로 같은 경로를 명시적으로 시험한다.

## 2. 준비

1. Godot 4.6.2 stable editor를 설치한다.
2. Godot에서 `Editor > Manage Export Templates`를 열고 **4.6.2.stable** 템플릿을 설치한다.
3. 저장소 루트에서 다음을 확인한다.

```bash
GODOT=/Users/junheelee/Downloads/Godot.app/Contents/MacOS/Godot \
  ./tools/audit.sh

GODOT=/Users/junheelee/Downloads/Godot.app/Contents/MacOS/Godot \
  ./tools/build.sh demo-check
```

두 명령은 각각 마지막에 `✅ 감사 통과`, `DEMO_BUILD_CHECK_OK`를 출력해야 한다. Godot 공식 문서상 custom feature는 에디터 실행에는 적용되지 않고 실제 export에서만 적용되므로, 에디터 게이트의 `--demo-build`는 생략하면 안 된다.

참고: [Godot feature tags](https://docs.godotengine.org/en/stable/tutorials/export/feature_tags.html), [command-line export](https://docs.godotengine.org/en/stable/tutorials/export/exporting_projects.html).

## 3. 플레이테스트 데모 생성

세 플랫폼을 한 번에 만든다. `playtest`는 tracked·untracked 변경이 하나라도 있는 작업트리를 거부하므로, 사용자의 진행 중 변경을 버리지 말고 커밋하거나 별도 clean worktree에서 실행한다.

```bash
GODOT=/Users/junheelee/Downloads/Godot.app/Contents/MacOS/Godot \
  ./tools/build.sh playtest
```

이 명령은 순서대로 다음을 수행한다.

1. tracked·untracked 변경 0인 clean Git 소스 확인
2. Godot `--import`로 fresh checkout의 리소스·`class_name` 캐시 생성
3. 소스 재확인 후 데모 flavor, t=1~8 정본 아크, t=24 허용/t=25 차단 계약 검사
4. Windows 데모 export
5. macOS 데모 export
6. Linux/Steam Deck 데모 export
7. 소스 재확인 후 `build/demo/MANIFEST.sha256` 생성

개별 빌드는 `windows-demo`, `macos-demo`, `linux-demo` 타깃을 사용한다. 정식판은 기존 `windows`, `macos`, `linux`, `all` 타깃을 사용한다. 개별 개발 export는 RC가 아니며 clean-tree 게이트를 통과했다고 간주하지 않는다.

배포 전 `MANIFEST.sha256`의 전체 revision/tree 해시, `source_status=clean`, 산출물 해시와 실제 테스트 기록이 같아야 한다. manifest 파일 자체의 SHA-256도 세션 원장에 기록한다. 빌드 뒤 게임 소스가 바뀌면 기존 산출물은 폐기하고 다시 만든다.

```bash
sed -n '1,8p' build/demo/MANIFEST.sha256
shasum -a 256 build/demo/MANIFEST.sha256
```

## 4. 자동 스모크

### 계약 스모크

`tools/DemoBuildCheck.tscn`은 다음을 실제 코드 경로로 검사한다.

- 부팅 main scene이 `SplashScreen.tscn`인지
- 정식 preset에는 `gangnam_demo`가 없고 데모 preset에만 있는지
- t=1~8이 챕터 카드 → 첫 면접 → 통장 계산 → 쉬운 돈 → SNS → 카페 → 현수 → 1막 종료 순서인지
- 선택 효과와 follow-up을 적용한 뒤 `chapter1_closed`가 생기는지
- 24주차를 끝까지 허용하고 25주차 진입 전에 데모 기록 CTA로 막는지

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

## 5. 실제 패키지 스모크

교차 export 성공은 해당 OS 실행 성공을 뜻하지 않는다. 공개 테스트에 보낼 플랫폼마다 그 플랫폼에서 아래를 한 번 통과해야 한다.

1. 기존 세이브가 없는 테스트 계정 또는 새 저장 슬롯에서 실행한다.
2. 언어 선택이 먼저 뜨고 KO/EN 선택이 즉시 전 표면에 적용되는지 확인한다.
3. JUNPAC 스플래시 → 플래시포워드 콜드오픈 → 시작 메뉴까지 막힘 없이 간다.
4. 새 이야기를 시작하고 콘텐츠 경고를 확인한다.
5. 첫 8주를 입력으로 진행한다. 각 주에 AP를 실제로 소비하고 선택지를 직접 고른다.
6. 8주차에 `서울에서의 첫 두 달 / The First Two Months in Seoul` 장면과 AP 복귀를 확인한다.
7. 크래시, 무한 전환, 입력 포커스 소실, 배경/BGM 재시작, 한글 누출을 기록한다.
8. 테스트 빌드 파일의 SHA-256을 `MANIFEST.sha256`과 대조한다.

Mac에서 만든 Windows/Linux 산출물은 **산출물 생성 검증**까지만 인정한다. Windows와 Steam Deck/Linux 실행 스모크는 각 기기에서 별도 수행해야 공개 배포 가능 상태다.

### 최신 로컬 증적 (2026-07-13)

| 대상 | 결과 | 범위 |
|---|---|---|
| Windows Demo export | PASS | 공식 4.6.2 템플릿으로 PE 패키지 생성·SHA-256 기록 |
| macOS Demo export/run | PASS | 격리 HOME, 영어 최초 실행, 언어 선택→JUNPAC→콜드오픈→W1~W8→AP 복귀 실제 입력 |
| Linux/Steam Deck Demo export | PASS | 공식 4.6.2 템플릿으로 ELF 패키지 생성·실행 권한·SHA-256 기록 |
| KO/EN render regression | PASS | `demo-blackbox` 언어별 17컷, CTA 첫 화면·한글 격리·빈 이미지 없음 |

Windows와 Linux/Deck의 `run` 칸은 아직 미검증이다. macOS 실주행 중 발견한 직종별 첫 출근 장면과 월초 AP 상한 표기 회귀는 빌드 실패가 아니라 콘텐츠/루프 QA 항목으로 `ORDER-10`에 이관했다.

### 외부 정상 독해 RC 게이트 (2026-07-21)

| 대상 | 결과 | 범위 |
|---|---|---|
| Dirty source rejection | PASS | tracked·untracked 변경이 있는 `playtest` 즉시 중단 |
| Fresh checkout import | PASS | `.godot` 캐시 0에서 `--import` 완료 후 `DEMO_BUILD_CHECK_OK` |
| Provenance manifest | PASS | 전체 commit/tree·`source_status=clean`·Godot 버전·생성 UTC·3종 SHA-256 |
| Session schema v2 | PASS | 중복·혼합 빌드·플랫폼 해시 이탈·필드/점수 오류 및 망설임 bool/장면/원문 계약 거부 |
| Aggregator fixtures | PASS | 10건: 준비/미달/NO-GO/P0/중복/혼합/점수/enum/망설임 저표본·필수 원문 |
| Human evidence | OPEN | 같은 RC 10명, EN 3명, 경험 양 군, 구체 계획 70% 필요 |

현재 외부 표본 정본은 ORDER-41 clean RC다. 소스 revision은 `e74c69b617cca9292328e459659a26db2c5645b8`, tree는 `76069f026a4e4ae88275f67253cb4b639ed58ff0`, 매니페스트 파일 SHA-256은 `4850b08987b80b39a9d14a760f188519b3413ac60c17da658f6a812fa64d6062`다. 로컬 산출물과 매니페스트는 `build/demo/`에 있으며 Windows/macOS/Linux·Steam Deck 세 파일 모두 재검산 PASS다. 파일럿 5명과 본표본 10명은 이 매니페스트가 아닌 빌드를 섞지 않는다.

자동 게이트는 표본이 `READY_FOR_HUMAN_VERDICT`인지만 판정하며 재미·출시 GO를 선언하지 않는다. Windows와 Linux/Deck의 물리 기기 실행 스모크도 계속 OPEN이다.

## 6. 스모크 기록

| 항목 | 기록 |
|---|---|
| 날짜/테스터 |  |
| commit/revision |  |
| manifest 파일 SHA-256 |  |
| 플랫폼 산출물 SHA-256 |  |
| OS/기기/해상도 |  |
| 언어/입력 장치 |  |
| 부팅→콜드오픈 | PASS / FAIL |
| t=1→8 | PASS / FAIL |
| 8주차 장면→AP 복귀 | PASS / FAIL |
| 중단/오류 |  |
| 증적 경로 |  |

`PASS`는 단순히 창이 열린 상태가 아니다. 8주차 정본 장면까지 실제 입력으로 진행하고 AP 화면으로 안전하게 돌아와야 한다.
