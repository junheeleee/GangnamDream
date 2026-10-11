# ORDER-558 — 수리를 포함한 full 검수 후보 발급

#### [x] ORDER-558 내부 발급 한정 GO — 2026-10-11

사용자의 전체 출시 검수 지시를 따른다. 이전 a0bc 앱은 이름·통화 종료·시간·
투자체험·NG+ 수리 이후의 소스가 아니므로 새 후보를 먼저 만든다. 외부 출시가
아닌 내부 검수용 full 후보 발급이다. 이 선언을 main에 push한 뒤 구현한다.

## 깊이 3문

1. 새 앱 없이는 소스 수리와 실제 관측의 후보가 달라진다. 이전 앱의 GO를
   새 소스에 가져오지 않고 clean revision/tree와 산출물 지문을 결속한다.
2. gameplay·원문·번역·저장 schema 변화0. BUILD_ID만 새 발급 날짜/순번으로
   바꾸며 BuildInfo의 기존 비호환키 아님 규칙과 저장 읽기 정책은 유지한다.
3. 과거 앱 재사용 대신 fresh full-rc Win/macOS/Linux 발급을 택한다. 빌드 성공을
   native 플레이·Steam Deck/Windows 실기기·원어민·출시 GO로 확대하지 않는다.

## 파일 소유와 실행

- root: `systems/BuildInfo.gd`의 BUILD_ID 한 값, 이 사양·큐2·마감
  `CLAUDE.md` 현재행·`docs/WORK_LOG.md`. 제품/프로젝트/원고/번역의 다른 편집0.
- phone_cn_author: `.git/order558-build-20261011/` private 공간에서 기존547 발급
  절차와 build helper만 재사용한다. 새 detached clone·fresh HOME/XDG·기존 설치
  templates의 읽기 전용 symlink→`tools/build.sh full-rc`→macOS 앱 압축 해제.
  새 영구 runner/체커·등록·이력/검증최적화0. helper는 root가 읽기 전에 실행하지 않는다.
- phone_independent_review: helper/후보 신원/산출 manifest/PCK·실제 원로그·보존을
  읽기 전용 독립 검수한다. formal 오더보고/판정원장행 추가0.
- cjk_wrap_diagnosis: 큐2의 순번·범위만 소유하고, 이후 metadata 읽기 전용 검수.

## 검증·보존·완료 경계

- `2026.10.11.1`을 BuildInfo에 발급하고 clean 커밋의 날짜/first-parent 규칙을
  기존 build_identity_audit로 확인한다. fresh clone에는 시작 전 .godot가 없어야
  하며 full-rc가 import/Win/macOS/Linux/통합 manifest를 소유한다.
- 실제 exit·원 stdout/stderr/Godot 오류를 확인한다. macOS deep/strict 서명과
  universal arm64/x86_64, PCK payload digest·필수 notices·타깃 이미지 import,
  source revision/tree/ZIP·앱·PCK 지문을 기존 함수로 검증한다.
- 원 project/presets·공개 데모 package/userdata·player·Human/판정원장·원556 W62와
  관측 원자료를 전후 보존한다. 원 사용자 app/editor/설정·저장을 사용하지 않는다.
  root·private checkout 소스가 바뀌면 발급을 중단하고 실패 자료를 보존한다.
- Win/Linux는 발급/정적 신원만이며 native 실행을 주장하지 않는다. 이 오더에서
  앱 플레이는 하지 않는다. 다음 월별 오더가 원W62 한 파일을 새 HOME/XDG에
  복사해 정상 Continue로 M16을 잇고, 선언/관측/마감을 한 커밋에 묶는다.
- 제품동작 검사 삭제/완화·ObjectDB 추적·479/481·STATUS 단독커밋0. 자동 계약은
  재미·깊이·문체/인간품질 증거가 아니다. 옛 strict FAIL/HOLD·공개 GO와 Human은
  보존하며 새 후보의 전체 제품/출시는 HOLD다. 새 규범0, 실행 지시 일회성이다.

## 완료 증거

- clean source `52369e6600f138cdc7fdda5175112056e2535763` /
  tree `071ad8fc258e5506922e1f8047fc88d1fcab0fde`, BUILD `2026.10.11.1`.
  BuildInfo 한 값만 변경, 기존 build_identity 날짜/first-parent PASS다.
- private `.git/order558-build-20261011/`의 frozen helper로 정확1회 발급했다.
  fresh clone `/private/tmp/gd-order558-build-u_wr0qm1/checkout/GangnamDream`,
  시작 전 .godot 부재·fresh HOME/XDG·원본 source 변환0이다.
  clone/checkout/full-rc/unpack/deepstrict/lipo actual exit 모두0, full-rc84.402741s.
- Windows504507160B/SHA33568e280f2a93e4da8db3f76cffd131e2bda49db742435b068f718403991bf6,
  macZIP438031194B/SHAab0c9838fb78a9e47f3a3ac6a4db37f6668aa5214fa4209885b9a8c704ea2aca,
  Linux470925608B/SHAf0d64e3e5b2f7908770ab071fd4e3a5e5d0168fc9c6f147b769d2059f7b42d39.
  통합 manifest669B/SHA4e15843081121d6d21813f43b65af1aa179ea6534e28ed63df9161eb21d75dab.
- 새 앱 `/private/tmp/gd-order558-build-u_wr0qm1/app/GangnamDream.app`7파일,
  arm64+x86_64·deep/strict 서명 PASS. PCK399853832B/
  SHA3be1b3220d8d284ff88b6f07fdc3875e2070d0b8ea9c967d30efa82bc873738b의
  1892 member MD5·필수고지12 exact·arc_daeun bytes·이미지6 import 연결 PASS다.
- package12505B/SHA857ce67a45d45727c8e3c627c7fab127300b5d6bf873b7080ff9fa68c1dbca66,
  result38611B/SHA7399316314bf8c17d3ceb9cf0219c10545cf2ed148f0874df2f24e4900b693c6.
  원12 stdout/stderr 보존. outer 오류0·nested project 무시 WARNING3·서명 교체
  stderr129B를 구분한다. 성공 import 내부 출력은 build.sh가 숨기므로 warning0 주장0.
- phone_independent_review가 actual raw·산출3/manifest4/app7/PCK·현재 보호를
  직접 재대조해 발급만 GO로 판정했다. 보호10·templates35·engine/source/helper/
  roster exact=true. 원556 W62/raw·557raw·player33/public userdata9·Human/원장 불변;
  build/story_demo는 입구부터 부재이며 새로 삭제하거나 생성하지 않았다.
- ICU member=false를 실제 확인했다. CJK 줄바꿈 지원 데이터 포함 보증은 없으며
  다국어 package 수리는 별도 범위다. 이 발급 GO를 새 native/W62 cold·5언어 화면·
  Win/Linux 실기기·전체 CI·제품/출시 GO로 확대하지 않는다. 앱 실행0이다.
  자동 계약은 재미·깊이·문체/인간품질 증거가 아니다. 옛 strict FAIL/HOLD·공개 GO와
  Human 불변, 본편/출시 HOLD. gangnamdream-dev의 격리/표적 검증을 따랐다.
  새규범0/일회성·formal오더보고/원장행0·STATUS단독커밋0·종료누수 탐침0이다.
