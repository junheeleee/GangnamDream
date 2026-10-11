# ORDER-557 — 기본 이야기 이름의 읽기 표기 수리

#### [x] ORDER-557 마감 — 2026-10-11 / 소스 한정 GO

근거: DECISIONS 2026-09-30 / backlog ORDER-399. 실제 M15에서 기본 이름이
본문·결과마다 전체 이름으로 출력되는 결함을 확인했다(556). 이 선언을 main에
push한 뒤 구현한다. 전체 출시 검수는 계속하되 이 오더는 이름 소비자만 소유한다.

## 깊이 3문

1. 방치하면 서술·다은/재혁 발화가 승인된 지문·호칭과 달라진다.
2. 선택/24주 상태 변경은 없다. 저장된 이름과 사용자 지정 이름을 유지하며 읽기
   투영만 바꾼다. 기존 UI 전체 이름·공식 자기소개/명의·NPC 이름은 보존한다.
3. 원고를 일괄 치환하거나 사건 전체에 공식 예외를 걸지 않는다. 혼합 결과문의
   보통 서술 두 이름과 공식 발화 한 이름을 구별한다.

## 파일 소유

- root: `autoloads/LocaleManager.gd`, `autoloads/GameState.gd`,
  `tools/InvestmentLossHoldResultCheck.gd`, 이 사양/큐 마감/보관,
  `CLAUDE.md` 현재행, `docs/WORK_LOG.md`.
- cjk_wrap_diagnosis: 선언 때 큐2파일, 이후 `systems/DemoCoreLoopV2.gd`,
  `scenes/StoryMode.gd`, `scenes/CommunicationPhone.gd`, `scenes/MainGame.gd`.
- phone_cn_author: 기존 `tools/CommunicationPhoneCheck.gd`, `tools/ManualSaveCheck.gd`,
  `tools/GalleryReplaySnapshotCheck.gd`의 이름 회귀만 확장한다.
- phone_independent_review: 읽기 전용 비저자 검수. 실행/증거는 `.git/order557-qa-20261011/`
  private 공간이며 새 영구 runner/검사/이력 도구·formal 오더 보고/원장행은 만들지 않는다.

## 구현·검증 경계

- 한 pure 이름 투영: 기본값만 민준/Minjun/ミンジュン/Minjun/Minjun. full UI helper와
  기본값 언어 동기화는 유지한다. custom의 공백·토큰처럼 보이는 문자도 그대로 둔다.
- 사건/선택/결과/대사·live Story·동결 gallery/First Bill·문자·월 내레이션을 연결한다.
  공식4문맥은 현재 원고의 정확한 공식 절에 있는 occurrence만 전체 이름으로 남긴다.
  raw 원고/번역/원장/데모 pin·저장 schema·기록을 바꾸지 않는다.
- 기존 isolated pre-autoload bootstrap으로 compile, 기존 이름/저장/replay 표적 검사를
  실행하고 marker와 stdout/stderr/Godot 오류를 함께 확인한다. 정적 영향 검사를 선택한다.
  전체 감사/240주·종료누수·479/481·새 검증 최적화는 이 수리에 포함하지 않는다.
- 비저자는 산출물과 실제 실행 결과를 직접 읽고 범위를 판정한다. 자동 계약은 재미·
  깊이·문체/인간품질 증거가 아니다. source GO와 새앱/실제 화면 GO를 구분한다.
- `project.godot`, 사용자 저장/설정, 공개 데모/GO, 과거 인간 판정, 556 원 checkpoint/
  raw/runtime와 이전 관측은 비소유·불변이다. 새앱의 서술/다은/재혁 5언어 캡처는
  뒤 후보 검수에서 수행하며, 그 전 ORDER-399 전체 완료나 출시 GO를 주장하지 않는다.

## 완료 증거

- 도달 경로: clean568c20d18c368fc6f0971281640da678d848aa8e /
  tree697574b40dd1856a8ed9981a3986b8408b66dc35의 격리 기존 검사. compile69,
  Phone5언어×default alias3/custom3·공식4문맥, gallery ordinary/FirstBill
  양방향20표본, 투자손실40표본, v4 disk/new Story prose/result20건이다.
- 생산자↔독자: LocaleManager.gd:124/159 pure 투영 ↔ GameState.gd:4094,
  DemoCoreLoopV2.gd:12991/13093, StoryMode.gd:7176, CommunicationPhone.gd:872,
  MainGame.gd:11822. 이름은 원문 토큰을 확장한 뒤 한 번만 넣는다.
- 바꾸는 상태: 기본 본문 전체이름→민준/Minjun/ミンジュン/Minjun/Minjun.
  저장 이름·schema·캐시된 과거 대화·UI 전체이름·custom 공백/토큰은 불변이다.
  기존 FirstBill UI의 custom trim은 변경하지 않았다. 공식19 occurrence만 full이며
  병동 혼합문의 독립 기대 순서는 given/given/full이다.
- 포기 시 잃는 것/24주 상태: 선택·효과·플래그·라우팅·원문·번역 변화0.
  기존 본문의 승인된 호칭 투영만 수리하며 신규 선택/장면/계층0이다.
- 실제 실행: 최초35835 compile/Phone/gallery/investment actual0·marker각1·
  stderr0. 이후568c20d까지 runtime6/세 fixture 바이트는 동일하며 Manual만 고쳤다.
  최종 manual04 actual0/7.176274s·marker1·stdout=Godot472B/
  SHA71066c8109cb7e9f8b95e88dbd309c3109453bff0ca00e35c2bfd67175018c30,
  stderr0·진단/오류/경고0. receipt27199B/
  SHA3de60df4d7c3d61456b8f0950a40d1ed9d6c9b9b4054455632997d5241852690.
- 실패 보존: manual01은 fixture 추론 Parse2/load1로 owned process만 TERM(-15).
  02/03의10FAIL은 저장 전후 int→float3잎뿐이었다. 실제 진단의 나머지7절과
  JSON 표현 equality2는 모두 true다. 기대 로그2만 기존 codec 경계로 맞추고
  실제 상태·저장 codec·검증 절은 바꾸지 않았다. 원 attempt1~3를 보존했다.
- Locale actual0/marker1이나 종료 ObjectDB WARNING+resource1 ERROR로 strict FAIL.
  KNOWN_FAILURES의 기존 비차단 종료 정책에 따라 추가 탐침0이며 원인 해결/CI
  예외 추가/전체CI PASS로 세지 않는다. import의 중첩 project WARNING1도 기록했다.
- 정적 영향: EN coverage/Hangul, demo scope/story localization, JA UI, ZH skeleton,
  multilingual surface PASS. 현지화 전체 INCOMPLETE/기존 부채·원어민 OPEN은 불변이다.
- 보호: 모든 실행 preservation_exact=true, project/presets/Human·공개·player·
  원556 W62/raw 및 원장 보존. 원W62 SHA0c9bd1f177d939ca19d2f614bc6e166660df8f75f005ceaa26cb28edd44e69bd.
- 비저자 phone_independent_review는 실제 diff/원3stream/receipt를 직접 읽고
  source-only GO. 자동 계약은 재미·깊이·문체/인간품질 증거가 아니다. 새앱/native/
  새OS cold·399의3장면×5언어 화면·인간/원어민/물리패드·출시는 미관측/HOLD다.
- 닫는 것: 이름 소비자 runtime6/기대 fixture4만. 새 규범0·실행 지시 일회성,
  새 permanent checker/도구·formal 오더보고/원장행0. 다음은 새 후보 발급 후 원W62 M16.
