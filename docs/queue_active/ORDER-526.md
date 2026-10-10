# ORDER-526 — 중국어 줄바꿈 데이터의 successor 패키징 수리

#### [~] ORDER-526 [P1·가독성] 빠진 ICU 데이터를 새 로컬 앱에 포함한다

**착수 — 2026-10-10.** [525](../queue_archive/ORDER-525.md)의 실제 CN/TW 화면에서
첫 줄이Kim/다음 줄이Minjun으로 갈리고 여백이 컸다. 완문·무잘림은 통과했으나
줄갈이의 실행 중 fallback 진입은 아직 추론이다. 읽기 전용 진단은 exact522 PCK
1877항목에 `icudt_godot.dat`가 없음을 확인했다. Godot4.6.2 공식 exporter는
include 설정/등록 Translation locale로 ICU 포함 여부를 정하므로 JSON 현지화가
자동 감지되지 않는다. 공식 TextServer의 ICU iterator 실패 시 공백 분리 fallback은
관측과 맞는다. 원문/본문 consumer 추측수리 대신 이 확인된 패키징 공백을 고친다.

## 한 단위·깊이 3문

1. 없으면 중국어 독자가 본문의 긴 줄 앞에서 불필요한 짧은 줄을 계속 읽는다.
2. 원문·번역·이름값·선택/효과/페이지의 authored 문단 경계·저장 계약은 바꾸지 않는다.
3. 임의 줄갈이 대신 실제 PCK의 지원 데이터·같은 문자열/서체의 실제 줄 배치로 판정한다.

## 소유·경계

- root: `tools/build_story_demo_successor_macos.py`의 임시 staging project ICU 포함과
  실행 unit literal, 기존 builder 실행·private 원로그/화면, 이 사양·큐/302/CLAUDE/
  WORK_LOG/STATUS·위임원장·완료 manifest 사본만 소유한다.
- 별도 저자: `tools/story_demo_successor_package_audit.py`의 ICU 멤버/설치된4.6.2
  template 원바이트 검증과 기존 synthetic self-test·unit literal만 소유한다.
- 비저자: source/PCK/원로그/저장·보호 전체 읽기 전용 독립 검수. 실제 픽셀/원어민과 구별한다.
- 새checker/runner/보고·검증비용 계측0. project/preset·원고/번역·원장·공개본/옛앱/
  모든 원저장·seed/W238·과거 실패raw/인간판정은 보존한다. root project.godot는 불변이다.
- 같은BUILD2026.10.10.1의 새 attempt `icu-break`를 fresh local destination/namespace로
  발급하며 옛nameplate-fix 앱·manifest·저장을 덮지 않는다. 공개/외부출시0이다.

## 검증·완료

1. 기존 pure transform/self-test에서 stage만 include 설정·ICU 없음/오염 거부를 검사한다.
   원template4797072B/SHA4025663065f82dd78e68981ad362cafa993396468b44f14853004ded3b3d665d와 대조한다.
2. source commit 뒤 기존 builder의 격리 import/compile/데모 검사·export/서명/PCK 감사를
   그대로 재사용한다. 새PCK의 ICU exact와 원고/번역/currentJSON 불변을 확인한다.
   실행 입구~독립 final fresh까지 source/docs/helper 동결·원저장/실패raw 보존이다.
3. fresh 앱 실제 KO 시작→첫선택→M02까지 정상 읽기 후 CN/TW/KO의 첫 문단·설정
   복귀를 관측한다. 바뀐 줄 배치/잘림/다른언어 회귀와 자체 종료를 확인한다.
   자동입력/상태주입/원저장 복사0이며 새namespace의 정상UI 쓰기만 허용한다.
4. raw오류0·전체보호fresh·독립검수로 패키징/실제표면만 판정한다. 미재현이면 원인
   추론을 확정으로 올리지 않고 남은 가독성 위험을 기록한다. 본편·출시 HOLD다.

지시는 일회성이다. 원인 없는 포괄 폰트 교체·전 장면 줄갈이 재작성은 하지 않는다.
