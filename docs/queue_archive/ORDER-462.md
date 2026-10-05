# ORDER-462 — 수정된 체험판의 별도 로컬 macOS 후보를 만든다

#### [x] ORDER-462 [P0·출시 준비] 공개본을 보존하는 successor export

**[~] 착수 — 2026-10-05.** 302의 대본7항목은 source GO이나 옛 공개 빌더는
4e80a63/BUILD2026.08.31.1과 공개 저장·출력 경로에 고정돼 있다. 그 핀을 바꾸거나
공개본을 교체하지 않고, 새 clean source에서 별도 후보를 export한다.

## 깊이 3문·한 단위

1. 제거하면 수리된 대본을 담은 실행 산출물을 검사할 수 없다. 옛 공개본 GO는
   새 대본·현재 제품의 package GO가 아니다.
2. 선택·경제·24주 뒤 상태는 바꾸지 않는다. 새 BUILD 표식과 저장 공간만 staging에서
   분리하며 M01~M06·5언어·story_demo_rc 저장 형식은 유지한다.
3. 현재 Mac 잠금으로457 GUI 이어보기는 막혔다. 기다리는 대신 headless로 가능한
   fresh import/표적 계약/export·서명·ZIP/PCK 무결성을 진행한다.

판정 대상 하나는 **기존 공개본과 저장을 보존한 로컬 export 산출물**이다.
GUI 자연 부팅·신규 저장/별도 프로세스 재개·StoryMode 복귀/입력 해제·지역 화면과
옛 공개 저장 복사본 호환은 이후 실제 후보 검수다. 이 단위는 package 출시 GO를
발급하지 않으며 manifest에 EXPORTED_NOT_RUNTIME_VERIFIED와 잔여 항목을 남긴다.

## 소유·불변

- claude_handoff_review: 새 `tools/build_story_demo_successor_macos.py`만.
- receipt_tests392: 새 `tools/story_demo_successor_package_audit.py`만. 작은
  self-test와 별도 manifest/app/ZIP/PCK verifier를 포함한다.
- root: `tools/audit_scope.json`, 이 사양/큐/L3·302 상태 문단·CLAUDE 현재행·
  BUILD_PIPELINE 절·WORK_LOG·생성STATUS·판정원장, 비추적 실행 증거.
- independent392: 코드/실제 결과 비저자 검수와 마지막
  `docs/agent_reviews/ORDER-462.json`만. 프로젝트 import/검사/엔진은 root만 실행한다.
- root 최종 package 증거 사본: `docs/agent_reviews/ORDER-462-manifest.json`.
  실제 성공 MANIFEST와 byte/SHA가 같은 추적 사본만 생성한다. 별도 검수 보고나
  새 실행이 아니며 ephemeral staging 경로는 역사 증거로 남긴다.
- 제품/원고/번역/receipt/기존 builder·audit·density pins·human·원본 project/preset
  변경0. 기존 공개 package·실제 player34·seed2/W195를 이동·삭제·교체하지 않는다.

## 생성 계약

- CLI는 explicit full source commit을 요구하고 HEAD/tree/전체 clean status를 전후
  확인한다. 제품 source와 실행한 빌더의 identity를 기록한다. 과거302 source와
  현재 전체 제품의 동일성을 가정하거나 과거 GO를 상속하지 않는다.
- 첫 후보 BUILD `2026.10.05.1`; 별도 앱/bundle ID/custom-user-dir과
  `build/story_demo_successor/2026.10.05.1/<attempt>/`. BUILD 날짜는 source commit
  날짜와 맞춘다. 이미 존재하는 출력/namespace와 경로 탈출·symlink는 거부한다.
- 저장소 밖 fresh Git archive를 사용한다. staging에서만 application identity/entry,
  원래 macOS preset의 identity/export path, controller PUBLIC_BUILD_ID와
  PUBLIC_CUSTOM_USER_DIR, 전용 check의 기대 BUILD를 정확 치환한다. 전후 hash와
  허용 key/횟수·그 외 원문 보존을 검사한다. export_filter=all_resources 및 기존
  include/exclude filter·게임플레이·profile/save format은 보존한다.
- 사전 Git census에서 UID가 없는 tracked GD3개를 확인했다. fresh import가 만드는
  `tools/RoutineBackgroundInputCheck.gd.uid`,
  `tools/order103_export/AudioManagerStub.gd.uid`, `tools/order103_export/Entry.gd.uid`만
  staging 생성 sidecar로 허용하고 실제 유무/형식/SHA를 별도 기록한다.
  `.godot` 캐시 외 다른 추가 파일은 거부한다. 원본 저장소에 UID를 추가하지 않는다.
- 첫 엔진 시작 전부터 새 RuntimeQA namespace를 application에 지정한다. 각 검사
  환경/namespace를 명시하고 늦은 Node override에 격리를 의존하지 않는다.
  export 전에 artifact 고유 namespace로 전환하여 검사 저장을 후보의 시작 저장으로
  사용하지 않는다. 실패 staging/log는 남기며 자동 삭제/재시도/원본 복구 작업0이다.
- actual macOS ZIP export, app launcher/PCK/Info.plist identity, ad-hoc codesign 및
  재압축 ZIP↔app byte inventory를 검사한다. PCK 디렉토리/각 payload digest와
  현재 content raw JSON을 대조하며 옛1481entry/309JSON을 새 후보 값으로 복사하지 않는다.
  ad-hoc은 notarization·스토어 제출·법률 인증이 아니다.
- manifest에는 exact source/tree·빌더/입력·허용 staging변경·실제 명령/로그 hash·
  app/ZIP/PCK hash·보호대상 before/after와 미실행 runtime 목록을 결속한다.

## 표적 검증·완료

1. 두 새 코드의 전수 사전읽기와 self-test: identity/type/path/기존출력/심볼릭링크/
   source drift/staging 치환·filter 보존/거짓 성공 로그/manifest tamper/ZIP traversal/
   PCK truncation과 current JSON 불일치 등 작은 합성 반례를 실제 export와 구분한다.
2. 새 차선 self-test·등록/context/queue. clean 구현 commit/push 뒤 actual 생성1회:
   demo localization·third-party notice 기본검사, fresh isolated import,
   FontRouting·I18nInfrastructure·StoryDemoFiveLocale(기존 FourLanguageCheck 파일),
   export/서명/ZIP/PCK verifier. exit0·정확marker·stdout와Godot log engine/script오류0.
   변하지 않은 기존 self-test 전량·full-body·365·240주·old builder 반복0이다.
3. 보호된 source·실제 player/seed·공개 산출물/공개저장 전후 대조. 실패는 원문보존 후
   원인만 수리하고 필요한 게이트만 재실행한다. 과거 성공을 새 실행으로 세지 않는다.
4. 독립 artifact 한정판정·증거/원장·main 커밋/푸시. actual export 전에는 완료로
   닫지 않는다. 이후302 실제 package/457/본편/출시HOLD는 별도로 유지한다.

규범 판정: 후보ID·파일소유·이번 실행계획은 일회성. 지속될 별도 로컬후보 생성/격리/
미검증 표식의 사용법만 BUILD_PIPELINE에 승격한다. 기존 WORK_UNIT 적용,
자동PASS는 재미·인간·원어민·물리패드·출시 GO가 아니다.

## 구현·실행 진입 증거

- builder530행/감사676행 전수 사전읽기·합성42/actual_exports0·명시차선4검사 PASS.
  등록196/context548/queue79·76. 처음 lane+파일목록 CLI exit2는 검사0으로 보존한다.
- 실제 출력/namespace 입구의 pure guard와 반례를 연결했고 preset 기본경로는
  staging 앱이름.zip, 실제 출력은 명시 CLI 경로로 결속한다. Python3.9 지원,
  player34 전량·UID exact3·PCK flags2·최종보호 뒤 manifest 발급을 확인했다.
- 현재 actual export/런타임0이다. 깨끗한 구현 후보를 먼저 main에 커밋/푸시하고
  actual 생성1회를 진행한다. 초기 출력 생성 뒤 entry 기록 전 OS실패는 result가
  없을 수 있으나 그 구간 엔진·공개본 변경0이며 잔여를 삭제하지 않는다.

### 첫 실제 실패와 동일 생성 경로의 제한 수리

- clean a717c442의 first는15명령 중 verify_final만 exit1이다. first/result SHA
  `04562493f15de4f1eee540a09f4a280f5c06b9186953f4ab7ca69731154e908c`,
  source/protected 전후 동일·preservation_errors0·최종manifest0이다.
- 같은 ZIP을 별도 `/private/tmp/gangnamdream-successor-first-verify.SLTTWy`에
  재추출한 서명검사 exit0와 Documents의 앱 루트 FinderInfo 추가를 확인했다.
  ZIP앱루트 metadata0·서명 전 앱은 해당속성0이며 첫 실패물은 변경하지 않는다.
- 같은 두 코드 소유에서 다음 fresh attempt의 **생성한 final_app 루트 하나**만
  `com.apple.FinderInfo` 값 `0000000000000000200000000000000000000000000000000000000000000000`
  관측 시 기록하고 제거할 수 있다. 값이 다르면 실패한다. before/read/remove/after
  명령·로그를 manifest와 독립감사에 결속하고 실제 배달 앱 codesign을 계속 요구한다.
  absent이면 제거0이다. recursiveclear·다른속성·quarantine·first·사용자 파일 변경0.
- 새로운 깨끗한 빌더 신원으로 second를 발급한다. 실패 원인을 고친 새 파이프라인
  검증이며 과거first의 계약PASS는 runtimeGO로 바꾸지 않는다. 새 정본규칙이 아닌
  이 후보의 관측된 패키징 결함 수리다.
- 제한 수리의 builder557행/감사737행 최소diff를 비저자가 전수읽기했다.
  합성58/actual_exports0·등록196/context/queue 명시차선4검사 PASS다.
  제거19명령/속성부재17명령을 exact argv·로그·manifest에 결속한다.
  다른속성은 이름 집합 보존 검사이며 값 전체 재계측을 주장하지 않는다.
  첫 실패물의 별도 읽기진단은 app7/PCK1877/currentJSON675·staging 보존PASS이나
  그 배달 앱의 서명 실패는 그대로다. second 실제검증은 다음 clean commit 후다.

### 두 번째 실패 뒤 실제 배달 위치 수리 — 위 단일속성 제거 시도를 대체

- e5d9b846의 second도 최종서명 exit1이다. result SHA
  `c04fb710e0cc97f1bd7c31df7d5b0cac6dfbc00c56d8b9144dac44af4ee2319c`,
  보호/source 전후동일·최종manifest0이다. 삭제 직후 로그는 FinderInfo 부재이나
  후속 xattr 읽기에는 앱루트에 다시 존재한다. 삭제 반복·동기화/보안 설정 변경0.
- 다음 fresh third부터 **실제로 배달할 앱**의 정본 위치는
  `/Users/junheelee/Library/Application Support/GangnamDream_LocalCandidates/<BUILD>/<attempt>/<app>.app`
  이다. 이 후보 폴더는 현재 부재다. ZIP·entry/result/log·manifest는 기존 repo의
  attempt 경로를 유지한다. 깨끗한 첫 입구에서 두 목적지 모두 fresh/symlink없음을
  확인하고 별도 source archive와 분리한다. 재추출·codesign·byte inventory·manifest
  모두 이 실제 외부 앱을 결속하며 임시 폴더 검증으로 배달 앱을 대체하지 않는다.
- FinderInfo 제거 코드와 해당 제거 self-test는 철회한다(앞 두 실패 이력은 보존).
  새 앱 속성목록은 읽기만 하고 FinderInfo/ResourceFork가 있으면 실패한다. 다른
  속성이나 quarantine 변경0, 새 앱의 서명검사 완화0. 세 번째 repo 안에는 loose
  앱을 만들지 않는다. 이것은 같은 로컬 export의 확인된 목적지 결함 수리이며
  사용자 저장 namespace·공개 앱/ZIP·엔진/제품/외부 배포 범위를 늘리지 않는다.
- 실제 지원경로 사전진단: first ZIP을 fresh
  `/Users/junheelee/Library/Application Support/GangnamDream_SignatureDiagnostic.JAQAlh`에
  풀고 root xattr provenance만·codesign exit0를 확인했다. first/second 변경0,
  아직 third의 실제 검증이나 runtime 증거가 아니다.
- builder545/감사708행의 최소 변경을 비저자 전수읽기했고 새 차선52반례/4검사
  PASS다. 철회한 속성제거16반례를 성공으로 누적하지 않고 새 경로/읽기10개로
  교체했다. 새 clean commit의 고정16명령 actual third가 다음 단계다.

## 실제 산출물 — 2026-10-05

- clean source `05747c92de6b590c5f0456376f2210a4e422b182`, tree
  `a867b41a90f59f5dcedafe9bb171e39b82aa2100`의 third 실제16명령 전부exit0.
  APP7파일/PCK1877entry/current raw JSON675의 동일성을 검사했다.
- ZIP427928192byte SHA
  `22cadef5eb023669e67cdf7a44648ff3e369b744d594172e391a3d88217b58aa`,
  PCK389386440byte SHA
  `cd3b0d1b92a3aa47531c25d1a09e2ca25f6d65eabf8a542cfb7d6ae7b45f7351`.
  실제앱은 Application Support/GangnamDream_LocalCandidates/2026.10.05.1/third,
  ZIP/로그/결과는 build/story_demo_successor/2026.10.05.1/third다.
- result SHA `b338d2669831fbc0958cdc253960987407c509271e3282e56ac5243b6819ae6a`,
  all_pass=true·preservation_errors=[]·sourceclean전후일치·보호대상동일.
  공개 build/story_demo는 missing→missing이며 옛artifact 실물 재검증이 아니다.
  artifact namespace는 빈디렉토리로 존재하며 실행저장파일0이다.
- 최종MANIFEST171751byte SHA
  `02f2a3973b496df52bd71e8d1b0abe81e75fbe768221671ca9bff68016f16d49`와
  [추적 사본](../agent_reviews/ORDER-462-manifest.json)이 byte-exact다.
  status EXPORTED_NOT_RUNTIME_VERIFIED/runtime NOT_RUN/user_go NOT_INHERITED.
- 최종 CLI PASS log SHA
  `b3e72857d7f7184ee9ba1b1c4e03e2c7aa0aa8ad39aa87ac6dbd9f3ab33548d5`.
  clean 구현 후보의52합성/4검사 raw log SHA
  `5badc45b951cedeb2cc6e9257f1251a6cc8390b434d2b39663d4d367a268ba95`.
  기존차선 stdout만 남았으므로 최종원시로그 확보1회이며 실제export/engine 재실행0.
- import/export의 nested103 project ignored 및 의도된 i18n 거부warning만 확인했다.
  engine/script/parse오류0. 새 GUI/입력0, no_argument_boot·new_save·cold_resume·
  story_return_input·five_locale_screens·old_public_save_copy_compatibility는 미실행.
  CUA 현재조회도 Mac locked로 자동해제실패. 사용자 수동해제를 요청했으며 우회0.

## 완료 — 2026-10-05 · export 범위 한정

- [독립 보고](../agent_reviews/ORDER-462.json)는 위 package subject/manifest에
  결속한 work_unit GO다. 보고 SHA
  `1f89b2dfa4ac33eabc092ca7aaa3d76752824cc97c7982ad5c19e6011229b554`.
  비저자99고유파일 재해시와 실제 로그/코드 읽기를
  저작·실행과 구분한다. 기존221판정/199보고를 보존한222판정/200보고이며,
  manifest 사본1개는 보고서 수에 넣지 않는다.
- 규범 승격: `docs/BUILD_PIPELINE.md`의 `로컬 successor 후보 — 공개본 미교체`.
  별도identity/저장격리/실제배달앱 서명/미관측runtime 표식만 지속 규칙이다.
  BUILD/attempt·소유·52반례·두 실패와 배달 위치 수리의 실행 순서는 일회성이다.
- 자동PASS는 계약 증거이지 재미·깊이·문체 승인 아님. 실제runtime6·302·457·
  M60/후일담/Property·본편/출시HOLD, 공개 GO1·인간OPEN45/DONE1은 보존한다.
