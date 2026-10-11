# ORDER-560 — CJK 지원 데이터 full 후보 수리

#### [x] ORDER-560 [패키지] 완료 — 2026-10-11

547·558 실제 Mac PCK에 ICU member가 없었다. JSON 번역은 Godot Translation
resource가 아니므로 자동 감지가 이 요구를 찾지 못한다. 공개 데모는 바꾸지 않는다.

## 깊이 3문

1. 지원 데이터가 빠지면 실제 일본어·중국어 단어/줄 경계가 깨질 수 있다. 소스
   문장을 억지로 개행하거나 폰트를 바꿔 패키지 누락을 덮지 않는다.
2. 다음 full-rc도 같은 누락을 내지 않도록 기존 발급 입구에서 설정을 거절하고,
   실제 새 PCK 데이터 바이트를 대조한다. 설치 파일 존재만으로 성공하지 않는다.
3. 원 프로젝트·preset 보존과 재현 가능한 clean 후보가 함께 필요하다. 별도
   build-only commit의 실제 SHA/tree를 발급하며 main base라고 허위 표기하지 않는다.

## 파일 소유·범위

- cjk_wrap_diagnosis: `tools/build.sh`, `tools/build_identity_audit.py`만 구현한다.
  기존 full-rc 설정 admission·missing-data 경고 거절·기존 self-test를 확장한다.
  일반 WARNING 전체 거절·root 설정 자동변경·새 checker/등록·영구 stage generator0.
- root: 이 사양·큐2·`docs/BUILD_PIPELINE.md` 정본·CLAUDE 현재행·WORK_LOG·마감,
  private clone의 `project.godot` ICU key와 `systems/BuildInfo.gd` BUILD_ID만
  apply_patch하고 local commit한다. 원본 두 파일은 수정/스테이징0이다.
- phone_cn_author: `.git/order560-build-20261011/`에 기존558 adapter/safety/PCK
  readers를 재사용한다. prepare/build 두 단계만 분리, 새 제품 도구·등록0이다.
  root 전체 helper 읽기와 독립 admission 전 실행0. root native 입력도 이번0이다.
- phone_independent_review: 실제 diff/helper/입구/산출/보호·최종을 읽기 전용 검수.
  formal 오더보고/판정원장행0, 저자 자가 GO로 대신하지 않는다.

## 구현·후보 신원

- full-rc는 import 전에 `[internationalization]`의
  `locale/include_text_server_data=true`를 요구한다. 기존 build_identity의 명시
  옵션으로 검사하며 root 기본 정적검사에 이 설정의 부재를 실패시키지 않는다.
- 공식 exporter missing-data 경고는 exit0/새 artifact가 있어도 거절한다. 기존
  error/stale/date/clean/fresh-import/manifest 검사와 mock self-test를 유지한다.
  경고 번역의 한계는 실제 raw 판독·PCK 바이트 검증과 분리한다.
- 구현을 main에 커밋·푸시한 exact clean source를 fresh detached clone/HOME/XDG에
  준비한다. root만 그 clone ICU key+BUILD `2026.10.11.2`를 고쳐 local commit한다.
  이력 base→stage diff는 정확 두 파일, clean/날짜/first-parent/new ID를 대조한다.
  private base..HEAD bundle을 verify하고 보존, manifest는 실제 stage SHA/tree다.
- 원 root `project.godot`·`export_presets.cfg`·BuildInfo·공개 userdata·player 저장/
  설정·Human/과거판정·원556/559 저장/raw/runtime·557raw·558app/package·templates를
  보호한다. fresh namespace만 생성, 옛 산출물 덮어쓰기/사용자 데이터 이동0이다.
- 같은 private stage에서 기존 full-rc 한 번으로 Win/Mac/Linux를 발급한다.
  engine4.6.2·소스/산출/manifest 해시·Mac universal/deepstrict·전체 PCK MD5/
  고지12·기존6image import binding을 대조한다. ICU member의 실제 바이트를
  기존 설치4.6.2 데이터와 exact 비교한다. 공식 embedded fallback도 합법이므로
  영구 guard는 설치 ICU 파일의 존재를 요구하지 않는다.

## 검증·닫는 범위

- 기존 build_identity `--self-test`(내부 export mock 포함), syntax/context/queue/diff,
  actual fresh full-rc·date/manifest·Mac PCK ICU와 보존만 검증한다. 필요 영향은
  기존 selector로 확인한다. 전체 audit/240주·비용 도구·ObjectDB 탐침0이다.
- 결함/실패 raw를 보존하고 같은 범위에서 수리한다. 입구 승인 뒤 source/spec/helper
  freeze, 별도 private stage patch 경계와 actual stage 승인 뒤 build만 실행한다.
- source 발급보호와 새 package만 GO 가능. native CJK5언어/Win·Linux 실기기/
  인간·원어민·물리패드·청취·게임/출시 GO는 별도다. ICU 포함만으로 줄바꿈 품질을
  관측했다고 하지 않는다. 본편/출시 HOLD·전체번역 INCOMPLETE·옛FAIL/HOLD 유지.
- 지속 규칙은 BUILD_PIPELINE 현행 full-rc 절로만 승격한다. 사양의 실행 지시는
  일회성이다. 뒤에559 소득 약속 문안 수리와 원W68 본편 정상 이어보기를 잇는다.

## 실제 결과

### 발급 보호 구현 — 후보 발급 전

- 기존 build.sh에 명시 설정 입구와 공식 missing-data 경고 거절을 더했다.
  기존 오류/산출/manifest/날짜/clean 검사는 유지한다. template·editor embedded
  데이터 메시지는 허용하며 일반 정적 호출에서 root 설정 부재를 실패시키지 않는다.
- 기존 build_identity self-test의 설정7·export mock6 표본을 포함해 actual0,
  `BUILD_IDENTITY_AUDIT_OK profiles=3 identity_fields=4 manifests=0 self_tests=97`.
  stderr0·0.510405125s, GODOT=/usr/bin/true이며 실제 엔진 실행은0이다.
  첫96 PASS는 보존했고 중복 section 표본 추가 때문에 한 번만 재검증했다.
  bash syntax actual0. 최종 build.sh SHA1c8278ad9034db047f9c2e835fd891ddfbee4c8f925a2ea568d2bf7f7e2f8478,
  auditor SHAb5eeef5995de51d8eb0ed536d9e2056eddfbb4727a61e45cd166f77cf6897892.
- root와 phone_independent_review가 실제 source diff를 읽었고 sourceguard GO다.
  private adapter290줄·18경로 roster는 root 전문 판독 완료, 독립 준비 입구 검수 중이다.
  실제 candidate 발급/ICU/PCK/서명/manifest/보호 검증은 아직0이며 이 오더는 진행 중이다.
- selector의 기존 V2/state/order103 관련 후보는 해당 코드·preset 불변이므로 이번에
  반복 실행하지 않는다. 기존 identity 자체검사·actual full-rc·metadata 표적만 실행한다.

### 실제 발급·독립 최종 검수

- main 구현 e83468123fcc4502da2d167ec0d38dce28f0e900/tree4d6168d1c81aa715eeb2af4c65582168f5958445를
  push한 뒤 prepare1회 actual0/7.820955s·보호6 true. root가 private2파일만 patch하고
  clean child227c5ae58c407508c565b8a6b6be0eb869f52cc2/tree30891a8c35ee57175c6b74560dc314f94dcf4e53,
  BUILD2026.10.11.2로 local commit했다. 원 root 프로젝트/preset/BuildInfo 변경0이다.
- 독립 stage admission 뒤 build1회 actual0/95.893340s, full-rc0/85.771834s.
  7실제단계 exit0·보호9 true. bundle678B/SHA3ec7e63e7bcbc1b0f1534f3d1fd0ae34a972cd433b90bc44dd78a690f2315ba3를
  verify했으며 manifest4는 root base가 아닌 실제 private227c5ae/tree30891a8/clean을 쓴다.
- Windows509304352B/SHA4888218983023153a92c6bf5e482a6845d5f9aef467cc96578b63ce70c2de4ef,
  MacZIP440860442B/SHA2bbb3052ad84cc97e34e9c9ffdaab7bb9312147691d13bbd7619440f745d270a,
  Linux475722800B/SHAf4af859adb0395d994f0f93030fc5f1ecb75cd5d315f039ffb31c53b77b3c822.
  Mac deepstrict0/universal x86_64+arm64·ZIP/app7 exact.
- 실제 Mac PCK404651024B/SHA39abeb3d7dae4f8bf9524670122586e1d0bfb94c60f819084a16ded403b2d0bd,
  1893개 전MD5·고지12·arc_daeun bytes·이미지6 import binding PASS.
  ICU icudt_godot.dat4797072B/SHA4025663065f82dd78e68981ad362cafa993396468b44f14853004ded3b3d665d가
  설치4.6.2 원본과 byte-exact다. 세 exporter의 template-data 사용 메시지도 관측했다.
- private560 build-package.json13554B/SHA656e830400b5011796f1d1c403bf6da0ce16e16015c74fc9fbb316a819fdbd25,
  build-result.json7508B/SHA71582dcd5738c39a215e94d88fd4efec226b69580ac0574c1695f9a34824a7fe.
  앱은 `/private/tmp/gd-order560-build-53iuu5un/app/GangnamDream.app`다.
  raw full-rc stdout681987B/SHAd83e64c99715fe1f9a5c9a9fb2b9a98633407ef278f50cd186ea0d84d604b4cd,
  stderr129B/SHA6cd9c4ae91911af6adea913966dedc07fe34e0b883591c03710e223386b11add.
- phone_independent_review가 14원stream·산출/manifest/bundle/app/PCK와 fresh보호18그룹
  207entries를 직접 대조해 발급보호·패키지 한정 GO다. outer ERROR/parse/script/
  ObjectDB/leak/누락 경고0, 기존 nested-project WARNING3·서명교체129B는 보존했다.
  숨긴 import 내부 warning0·native/CJK5화면/비MacPCK/WinLinux실기기/전체CI/출시 GO는 아니다.
- native0·559 소득 약속 REWORK·전체번역 INCOMPLETE·옛FAIL/HOLD·공개GO·인간OPEN45
  유지, 본편/출시 HOLD. 자동 계약은 재미·깊이·문체/인간 품질 증거가 아니다.
  새 checker/등록/formal보고/판정원장행/STATUS단독커밋/누수탐침/전체audit0.
  다음은 별도 M16·M18 소득 약속 문안 정렬, 뒤에 원559 W68 정상 이어보기다.
- 마감 context/queue/diff PASS. WORK_LOG 상한 첫 실패는 원문40588B를
  history/WORK_LOG_2026-10-11_pre_order561.md에 byteexact 이동 보존해 고쳤다.
