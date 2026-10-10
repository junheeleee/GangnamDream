# ORDER-526 — 중국어 줄바꿈 데이터의 successor 패키징 수리

#### [~] ORDER-526 [P1·가독성] 빠진 ICU 데이터를 새 로컬 앱에 포함한다

**착수 — 2026-10-10.** [525](../queue_archive/ORDER-525.md)의 실제 CN/TW 화면에서
첫 줄이Kim/다음 줄이Minjun으로 갈리고 여백이 컸다. 완문·무잘림은 통과했으나
줄갈이의 실행 중 fallback 진입은 아직 추론이다. 읽기 전용 진단은 exact522 PCK
1877항목에 `icudt_godot.dat`가 없음을 확인했다. Godot4.6.2 공식 exporter는
include 설정/등록 Translation locale로 ICU 포함 여부를 정하므로 JSON 현지화가
자동 감지되지 않는다. 공식 TextServer의 ICU iterator 실패 시 공백 분리 fallback은
관측과 맞는다. 원문/본문 consumer 추측수리 대신 이 확인된 패키징 공백을 고친다.

**구현 — 2026-10-10 / 발급·실제 화면은 미완료.** builder는 기존 application
변환 뒤 stage에만 정확한 internationalization 절/ICU true를 더한다. auditor는
설치된4.6.2 template의 고정 크기/SHA를 검사하고 PCK 단일 정규 멤버의 실제 bytes와
대조한다. 기존 synthetic self-test의 설치경계만 tiny 데이터로 mock하며 missing/
empty/valid-digest-corruption·stage설정 누락/변조 반례를 더한다. 생산 우회 옵션0이다.
원root project/preset·StoryMode/원고/번역 diff0이며 옛manifest는 그대로 보존한다.

**소스 검수 — 2026-10-10.** 기존 self-test65/actual_exports0·audit.py ERROR0/
WARNING0·큐/현황/인간원장 계약 PASS다. 부팅 문서18011B 예산 초과는 상태 한 줄을
줄여 수리한다. 비저자 phone_independent_review는 두 파일·호출 경로를 직접 읽어
stage한정/고정template·PCKbytes/기존보호 유지/생산mock우회0의 소스 한정GO다.
실제 발급·실행·줄바꿈 개선 GO는 아직 발급하지 않는다.

**발급·보존 검수 — 2026-10-10 / 실제 화면 HOLD.** clean source
`25fc879d39a6593e244b3905d7782f22560676c2` / tree
`de0898823de1cbb26ea9cfe7c5a7ccd0233b5e6a`의 새 `icu-break`를 발급했다.
원 [manifest 사본](../agent_reviews/ORDER-526-manifest.json)은 byteexact171865B /
`7a435023dbb662de53f02012242ffa04b106f0b56f86ab5ca6c5eab7bdf50072`다.
앱7파일/tree71507b66…·ZIP430908019B/462fc6da…·PCK394657360B/cc6611a4… /
1878항목·currentJSON675 exact다. ICU 단일 멤버4797072B/SHA40256630…와 설치
template의 실제 bytes가 같다. 16명령 exit0·필수마커·서명/별도final package감사
PASS·fatal/leak0이다. nested경고는 import/export각1, I18n19는 의도 반례이며
Godot 거울 로그를 별도 실패로 합산하지 않는다. ad-hoc이며 공개출시 인증이 아니다.

- private `.git/order526-export-20261010/` before=after 각699872B /
  `d66a5d82e9f225a08181938ba24973b8b25d564efd09cfbd0eaebfc39e1e8268`.
  root/비저자 phone_independent_review가 fresh tracked3264/helper5/seed2/W238/
  player33·기존보호45곳을 직접 전량 대조했다. source/docs/helper 동결은 독립
  최종 출구 뒤 해제했다. 옛앱·namespace·manifest·원저장·실패raw diff0이다.
- 비저자는 실제 stage의Git원형/소유4변환·UID, ZIP↔앱7, PCK1878digest/JSON675/
  ICU exact, manifest/result/16명령의 argv·namespace·원로그SHA/마커·보존을 읽어
  발급·보존만 GO다. 엔진·GUI 재실행/독립pixels0이며 전체 작업 GO가 아니다.
- 발급 전 기존 사용자 Godot 창의 native screenshot preflight가 Mac locked를
  반환했다. receipt601B/SHA95273d33…는 그 실패를 기록하며 새앱launch/input/
  savecopy/보안우회0이다. 새namespace 파일0, runtime NOT_RUN/user GO NOT_INHERITED.
  실제 CN/TW/KO 줄바꿈·이후장면/다른크기·원어민/인간/물리·출시 HOLD다.
- 소스 영향6검사는 context 예산18011B를 상태 한 줄 축약으로 고친 뒤 모두 PASS.
  main CI는 마지막 조회에서 진행 중이며 초록/전체 감사 통과를 주장하지 않는다.
- 발급 결과의 문서 영향5검사는 부모302 상태요약16067B 예산 초과를15922B로 줄인
  뒤 context30066/docs634/links193·큐78/76·현황95071B·인간원장 계약·큐index25/4
  PASS다. 원이력/제품/검사를 지우거나 예산을 넓히지 않았다.

**남은 같은 범위:** Mac을 수동 해제한 뒤 위 exact 새앱의 fresh KO 시작→첫선택→M02,
CN/TW/KO 첫 문단·설정닫기·정상종료를 정상UI로 확인한다. 옛slot 복사/주입이나
이전522 실제5언어 GO의 상속으로 대체하지 않는다. 이 오더는 `[~]`/미완료다.

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
