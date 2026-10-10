# ORDER-526 — 중국어 줄바꿈 데이터의 successor 패키징 수리

#### [x] ORDER-526 [P1·가독성] 빠진 ICU 데이터를 새 로컬 앱에 포함한다

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

**실제 화면·보존 완료 — 2026-10-10.** 기존 Godot의 stale 창 screenshot은
cgWindowNotFound였다. 살아 있는 사용자 project manager를 새로 bind해 실제
screenshot 접근을 확인했다. 이전 Mac locked 실패와 혼동하거나 소급 통과시키지 않는다.
위 exact ICU 앱을 무인자 단일 OS process로 fresh 시작했다. KO M01 본문5문단/
차단0/결과3문단을 자연 완료 뒤 개별 Return으로 읽어 정산1→자동M02에 도착했다.
M02 첫 authored 문단을 완독하고 Settings에서 CN→TW→EN→JA→KO를 각각 닫아
같은 문단에 복귀했다. M02 다음입력/선택·AUTO·skip·수동save·저장복사/주입0이다.

- root 실제1280×864 창/default 크기·Normal 속도에서 KO3/CN3/TW2/EN4/JA3줄.
  CN 첫줄은 은행앱까지, TW는 行動까지 이어지고 Kim Minjun이 같은 줄에 있다.
  525의 Kim/Minjun 분리·큰 첫줄 여백은 재현되지 않았다. CN 마지막줄 `机。`의
  짧은 꼬리는 남으며 전 장면의 줄갈이 완벽을 주장하지 않는다. 완문·무잘림/
  tofu·의도하지 않은 한글 누출 관측0, 이름표/HUD/설정/문단 복귀 정상이다.
  독립 검수자는 두 PCK의 font22경로와 JSON675의 raw 크기/SHA 전체 동일을 확인했다.
  개선은 관측이나 ICU runtime 분기 자체는 계측하지 않았다. 실제pixels는 root이며
  PNG 영속0·독립pixels0·원어민/인간/물리 관찰0이다.
- 정상CmdQ exit0/365.801256초. stdout=Godot790B /
  `7dcba27f53c94cd784627c30ca73fe8d288d67a3a9902c0730481cdc8aeca55f`,
  stderr/오류/경고/누수0. entry en→ko2개는 controller 정상재진입이며 앱2실행이 아니다.
  own26180/parent26176부재·사용자editor61385생존이다. 종료한 앱의AX를 다시 조회하지 않았다.
- private `.git/order526-live-20261010/` raw7개: before714719B /
  `214f0afa5c4ceb6d71d75306bf57f86b5963034d63a1853db3fb2c1fb883666f`,
  after714736B / `d6e344e7205498c2c6f5ee5734175eea659c4788baae7b52c5162a2efe1ced7a`,
  observation5203B / `e017eba416842cc9ee94203d4cb33acddf6e28555cc39af38a30811d22341e92`.
  root/비저자 phone_independent_review는 clean6dea70ab/treea3f43c13의 tracked3265/
  helper5/seed2/W238/player33·immutable53곳을 before=after=fresh 전량 대조했다.
  새namespace 정상UI5파일만 생성됐다. root입구파일0은 기존 빈 objectdb 디렉터리와
  구별했으며 비저자는 launch 뒤3파일을 확인했으므로 독립입구0 관측으로 세지 않는다.
- 실제 controller save8421B/e78edb8b…는 month2/elapsed4/closed[1]/선택0한건/
  settlements1/pressure1/turn5/money2970000/health70/mental62다. settings는 KO다.
  첫 root의 ns부재 assertion과 `cash` 키 오지정은 쓰기 전 중단·수정한 진단이며
  앱오류로 합산하지 않는다. raw와 이전 실패·원manifest NOT_RUN은 그대로 보존한다.
- 비저자는 직접 source/PCK/원로그·저장·53곳 fresh 출구를 읽고 패키징 수리와
  root 지정5언어 첫문단 관찰만 GO했다. 독립 엔진/GUI/쓰기0이며 최종 출구 뒤 동결해제.
  이 작업은 일회성/정본승격0이다. 자동 계약은 재미·전체 품질 판정이 아니다.
  exact새앱 coldresume/남은문단·선택·다른크기·옛공개저장 복사호환·연속청취/
  인간·원어민·물리·본편/출시는 HOLD다. 다음은 별도527의 실제 재개·M02 선택이다.

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
