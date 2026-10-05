# ORDER-462 — 수정된 체험판의 별도 로컬 macOS 후보를 만든다

#### [~] ORDER-462 [P0·출시 준비] 공개본을 보존하는 successor export

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
