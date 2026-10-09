# ORDER-518 — Timer 수리를 담은 새 로컬 데모 후보 발급

#### [x] ORDER-518 [P0·패키지] 기존 successor 빌더의 현재 신원 갱신과 export

**완료 — 2026-10-10 / export 한정 GO.** clean source
`b705bcf8cad30f7fb39f590beb8670f77043c401`/tree
`18542e4c54f6137beaa091c616c629fd7f021324`의 별도 timer-fix 앱을 발급했다.
원 manifest는 runtime NOT_RUN·user GO NOT_INHERITED로 보존하며 실제 재생은
[516](../queue_active/ORDER-516.md)이 새 exact 대상으로 별도 검수한다.

## 실제 산출·독립 검수 증거

- 기존 빌더16명령 전부 exit0/errors0. localization/third-party/font/I18n/five-locale의
  정확 marker는 각각1회다. import/export의 기존 nested project 무시 경고각1과
  I18n 의도적 잘못된 format 거절 경고19를 엔진 오류0과 구분한다.
  five-locale은 locales5/routes5/months30/weeks120/save5/story10 및 이번 Timer 수명
  표본을 통과했지만 실제 native 장면 진입·수동 저장의 증거는 아니다.
- BUILD2026.10.10.1/attempt timer-fix, ad-hoc codesign deep/strict 두 검증 PASS.
  manifest171548B/SHA`892c0be35aaf6fa33b10114a0973473f5dcdcbeb6cdabba1d86d527bab1596a0`.
  추적 사본 [ORDER-518-manifest.json](../agent_reviews/ORDER-518-manifest.json)은
  원본과 byte-exact다. ZIP428076423B/SHA`e15bc26b4508c0470219fcf14c24d44549bed8fd26ce84c468eb40a05700535c`,
  PCK389860104B/SHA`ad427236eb57c6fa4cb57f195e9d6adf8916f0264565b3375d90fd9f1a216d6e`.
  앱7파일·PCK1877항목/JSON675개가 staged source·final ZIP과 일치한다.
- 원출력 `build/story_demo_successor/2026.10.10.1/timer-fix/`의 result all_pass=true·
  preservation_errors[]이며 독립 기존 package audit도 PASS다.
  `.git/order518-export-20261010/before.json`과 after는 각각643708B/
  SHA`8d46e73e6bb3776745a5fedb3f05bf03dfa62f5b4eec95051e84252e7b030bab`로 byte-exact다.
- root와 비저자 `phone_independent_review`가 각 fresh 전체 snapshot을 직접 대조했다.
  tracked3253/helper5/seed2/W238/player33 및 보호17곳 전부 동일이다. 공개 namespace9파일,
  oldthird 앱7·namespace4/ZIP/원manifest·462추적manifest·516raw6·별도checkpoint5를
  보존했다. 공개 build/story_demo는 기존처럼 absent이며 공개 실물 GO로 바꾸지 않는다.
- 독립 검수는 literal diff·원명령/marker/오류·실물 manifest/ZIP/PCK·서명·보존 모집단을
  직접 읽은 export 한정이다. 신원/변환/byte/경로 결함0·retouch0, 실제 부팅·수동 저장/
  cold resume·복귀입력·5언어 화면·옛공개 저장 복사 호환·연속청취·인간/원어민/물리패드·
  전체제품/출시 GO는 없다. 기존 third의 실제 SIGSEGV는 소급 통과시키지 않는다.

**착수 — 2026-10-10.** 517 source 수리 GO 뒤에도 기존 third 앱은 실패한
옛 바이트다. 이를 덮지 않고 새 clean source와 별도 신원으로 발급한다.

구현은 기존 builder9행/auditor11행/BUILD_PIPELINE 지원ID1행의 literal만
정렬했다. 기존 self-test52 PASS/actual_exports0 뒤 clean source로 실제 발급했다.

## 한 단위·깊이 3문

1. 없으면 수정된 코드의 실행 앱이 없어 실제 부팅·저장·재개를 확인할 수 없다.
2. 선택·경제·저장 형식은 바꾸지 않는다. 현재 source를 독립 앱과 빈 저장 공간에 담는다.
3. 옛 third를 덮는 대신 새 identity를 쓴다. 제품/도구 확장·성능 작업과 경쟁하지 않고
   기존 빌더의 날짜·신원·실제 player33 입구만 갱신한다.

## 소유·범위

- root: `tools/build_story_demo_successor_macos.py`,
  `tools/story_demo_successor_package_audit.py`의 BUILD/date/version/namespace,
  발급 unit/기존 self-test 신원과 현재 player33 census literal만.
  기존 두 seed+이어보기 checkpoint 문구를 현 경로 의미에 맞춘다.
- root 문서: BUILD_PIPELINE의 현재 지원 ID, 이 사양·516/302 후속 포인터·큐/L3·
  CLAUDE/WORK_LOG·생성STATUS·위임원장. 원출력 build/manifest/app/로그와 현재 성공
  manifest의 byte-exact 추적 사본은 기존 증거 형식을 재사용한다. 새 보고0.
- 비저자 `phone_independent_review`: 읽기 전용 변경/실제 manifest·앱/ZIP/PCK·보존 검수.
- 새 도구/검사/runner/성능 개선0. 게임 원고/번역/코드·저장·project/preset·human·
  공개 데모/GO·기존 third/462manifest·helper/seed/checkpoint는 불변이다.

## 실행·검증

- BUILD2026.10.10.1/attempt timer-fix, 별도 GangnamDream_LocalCandidates 폴더와
  GangnamDream_StoryDemo_Successor_2026_10_10_1_timer-fix 저장 공간만 새로 만든다.
  source 날짜는 실제 clean commit 날짜와 맞춘다. 재현 날짜를 조작하지 않는다.
- 현재 retail33을 실제 재해시해 입구/출구 전수 동일을 요구한다. 파일을 추가하거나
  census를 원복하지 않는다. existing-fresh/symlink/filter/변경 범위/marker/오류 거절은 유지한다.
- 기존 package auditor self-test와 영향 검사 뒤 clean source를 커밋/push한다.
  기존 빌더 그대로 actual export/import/5언어 계약/고지/서명/ZIP/PCK 검사를 실행한다.
  두 원seed와 원W238을 정확 --protect로 넣고 추가 checkpoint도 root snapshot으로 보존한다.
- source/문서/helper는 실제 builder 실행~최종fresh 대조 동안 동결한다. 원산출/실패를
  삭제하지 않으며 공개 namespace나 player를 실행 대상에 쓰지 않는다.
- 성공은 EXPORTED_NOT_RUNTIME_VERIFIED/runtime NOT_RUN·user GO NOT_INHERITED다.
  manifest/ZIP/PCK/source/tree를 실제 확인한 뒤에만 516의 새 후보 대상으로 선언한다.
  실제 무인자 부팅/수동 저장/cold resume·복귀입력·5언어 화면·옛 공개 저장 복사본
  호환은 별개이며 package/본편/출시 HOLD를 유지한다.

자동 PASS는 재미·깊이·문체의 증거가 아니다. 이 후보 발급은 일회성·정본 승격0이다.
