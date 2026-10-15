# ORDER-696 — 사용자 본편 테스트 환경 인계

#### [x] ORDER-696 [C4 직접 플레이 준비] 환경 인계 완료 — 2026-10-16

## 인계 결과

바탕화면 `강남드림 본편 테스트 2026.10.16.2.app` 바로가기 →
`/Users/junheelee/Applications/GangnamDream-HumanTest-20261016.2/GangnamDream.app`.
`강남드림 테스트 안내.md`2089B/SHA30dd48d26a1730e7b4446100450f486d0a26b07f7d0f94deb865ee65970037cf.
실제 앱1회 정상 무인자 부팅→첫언어KO→인트로제목→한국어메뉴/새이야기포커스,
계속하기 비활성·root 새이야기 입력0·4원JPEG직접관측·PID47625 실행 중 그대로 양보했다.
인계 뒤 사용자 화면/저장 조작0. 전용 저장은 임시 폴더가 아니며 초기화하지 않는다.
제목 시점 settings43B(languageko)·0B로그뿐/진행save0이며 이후 파일은 사용자 소유로 가변이다.
0B boot log는 종료 미관측 상태라 엔진 오류0 인증으로 세지 않는다.

basead230fd→private build-only cf5851d51fc4fe58881209962b69534cc5044cbf /
tree9f6c215a04f205254367de24290ce1c1f023cdde·정확2파일/clean·날짜/ICU0.
성공import1(24.556937초)/export1(45.494258초)·기존macOSmanifest/서명/universal0.
ZIP440949776B/SHA483fbedb4131c8a945b95221e5dcd0178c5b1e3f011d263986abc44f525e66a7,
manifest464B/SHA44e3d8d5b7e962944bbe72847f8ef22f75424bb65bdf89cff4e260cbc9186af0.
app7exact/PCK1893·전payloadMD5/675contentJSON exact·ICU4797072B/40256630…665d.
root도 KOEN254파일/PCKcustomdir를 직접 확인했다. 보호10그룹118파일·원Godot설정97파일exact,
mainproject/BuildInfo/원문/대표694W126/public/Human/제품검사/OS설정/HOME불변이다.
bare-engineSIGKILL/빈엔진dir 예상가드/초기iCloud사본서명실패를 원본 보존했다.
후자는 Applications 새경로에 원ZIP을 noextattr/norsrc로 풀어 바로잡았으며,
quarantine 등 보안 속성 제거·보호 약화0다. 실패본을 PASS로 바꾸지 않았다.

독립 GO_HUMAN_TEST_ENVIRONMENT_HANDOFF_ONLY:
.git/order696-user-test-20261016/independent-handoff.{md,json}
MD5831B/SHA26c4274d2647411ea888df3ae102d99023eeb03751b98f3e68a4d998372dbc10,
JSON8964B/SHA3f2ec365c044c2b8a0ac3413d29e00320eb3a49156610cf2186dd2cc01dae79c.
실행원문5054B/SHAe12103cf40449abe65c35c6d7b8d9d444089a0ac2a72b9b47e58a6cfabfba4f8,
handoff2393B/SHAcb97df3206bc214d0b1ab50dd7ed0e2abbe8b40e068f855337638bfd9383bdb6.
root 보고전문·실제 불변핀/앱7/신원 확인. 표적문서5/마감context·queue·diff actual0,
현황판 stale 참고만/새checker·새런처·전체audit·240주0. main CI 전체 녹색은 미확정이다.
개발스킬의 저장보호/독립/표적/실제입구 확인을 적용했다. 규범승격0/일회성.
사람2~3시간 판단·새게임/저장왕복·5언어·C1완주·fullRC·출시·외부실행 GO는 아니다.

아래는 실행 선언과 실제 교정 원문이다.

사용자 요청: 지금 본인이 테스트할 수 있는 환경을 마련한다.
처음부터 자유롭게 시작하는 본편 macOS 앱을 바탕화면에 준비한다.
진행 중 main CI는 출시 GO로 세지 않고, 이 요청은 새 월 검수나 C1 재플레이가 아니다.
기존 대표 경로694 W126은 복사/편집하지 않는다. 사람의 실제 시간·평가도 선발급하지 않는다.

## exact 범위

root: 이 사양/archive, CODEX_QUEUE·L3 순번, WORK_LOG·CLAUDE 현재 상태;
.git/order696-user-test-20261016의 새 build-only clone/로그/보고;
바탕화면의 새 `강남드림 본편 테스트 2026.10.16.2.app`과 `강남드림 테스트 안내.md`.
바탕화면이 파일 제공자 영역이라 복사한 app에 FinderInfo가 붙어 strict 서명이 실패했다.
실제 앱은 새 `/Users/junheelee/Applications/GangnamDream-HumanTest-20261016.2/GangnamDream.app`에
두고 바탕화면에는 그 앱의 바로가기만 둔다. 실패한 자체 복사본은 private 경로에 이동 보존한다.
보안/격리 속성을 제거하지 않으며 비클라우드 실제 앱의 원서명과 바이트를 다시 확인한다.
전용 사용자 데이터는
`/Users/junheelee/Library/Application Support/GangnamDream_HumanTest_20261016_2`만 사용한다.
동일 경로가 이미 있으면 덮거나 비우지 않고 중지한다. 인계 뒤 이 저장은 사용자 소유다.

base ad230fd839e9e1ed7214830e3b9822cd145882c8 /
tree c6fa52583c4032934ef25c53f4a3097e9ae06046의 별도 clean clone에서
project.godot의 custom user dir/ICU 설정과 BuildInfo BUILD_ID16.2 두파일만 바꿔
build-only commit을 만든다. 메인 project/BuildInfo·원문·조건·효과·저장 구조는 불변이다.
기존 fresh import/macOS export·서명·manifest 도구를 재사용한다. full RC/3플랫폼을 발급했다고 쓰지 않는다.
HOME/XDG/OS 잠금·절전 설정·앱 권한을 바꾸지 않으며 새 검사/런처 도구도 만들지 않는다.
빌드 에디터 설정도 보호하기 위해 기존 Godot 실행 파일의 byte 복사와 공식
self-contained `_sc_` 표식을 `.git/order696-user-test-20261016/engine`에 둔다.
전용 editor_data에서 기존 설치 템플릿을 읽기 전용 링크로 참조하며,
기존 Godot 설정 디렉터리를 별도 전후 대조한다. 원 설치·전역 설정은 바꾸지 않는다.
근거: https://docs.godotengine.org/en/4.4/classes/class_editorpaths.html
첫 bare binary 복사는 macOS가 실행 즉시SIGKILL(-9)해 import 이전에 중지됐다.
stdout/stderr0·원Godot설정과 보호10그룹exact·stage캐시없음을 확인하고 원결과를 보존한다.
서명된 원Godot.app 전체 byte 복사본과 그 옆 `_sc_` 표식으로 바로잡아 재시도하며,
서명/실행/설정 격리 실패 시 사용자 OS 보안 설정을 바꾸거나 우회하지 않는다.
signed 복사본의 fresh import는 exit0/24.556937초·self-contained 설정 생성·원설정exact였다.
엔진이 전용userdir 안에 빈 objectdb_snapshots 디렉터리를 미리 만들어 root의
`native 전 디렉터리 부재` 예상에서 중지됐다. 파일0/저장·설정0·stageclean·보호exact이며
폴더를 지워 숨기거나 import를 반복하지 않는다. 빈 엔진 디렉터리만 허용하고
native 전 저장/설정/메타 파일0을 확인한 뒤 export1회만 이어간다.

## 준비·검수·인계

깊이3문: 이 환경이 없으면 사용자 C4 테스트를 시작할 수 없다.
플레이 선택·장기 상태는 구현으로 바꾸지 않고 사용자 본인이 만든다.
개발 검수 자동화와 사용자의 화면/저장을 경쟁시키지 않는다.

선언 커밋 뒤 private stage 두파일 exact diff·clean·날짜/ICU·기존 데이터 baseline을 확인한다.
독립 검수자는 경로 격리와 package/manifest/서명을 직접 읽는다.
fresh import1/macOS export1 후 실제 앱의 첫 언어/한국어 제목까지 정상 입력으로 확인한다.
새 게임을 대신 시작하거나 선택을 대신 고르지 않고, 사용자가 바로 시작할 제목 화면에서 인계한다.
실제 로그 오류·새 데이터 경로·기존 저장/설정 보존을 확인한다.
한 페이지 안내에는 실행/이어하기/저장/문제 제보 방법과 개발 중인 후보라는 한계를 적는다.

인계된 앱이 실행 중이면 이후 개발 에이전트는 UI를 재선택하거나 입력하지 않고,
사용자 테스트 디렉터리도 덮지 않는다. CI 확인·화면 없는 수리만 가능하며 종료/완료를 추정하지 않는다.
사용자 실제 2~3시간 확인과 출시 판단은 별도 미완료다. 외부업로드/상점/지출/등급인증0.
위 경로·검수 절차는 일회성, 기존 사용자 자료 보호 규범 외 승격0이다.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.
