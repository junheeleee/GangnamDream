# ORDER-557 — 기본 이야기 이름의 읽기 표기 수리

#### [~] 착수 — 2026-10-11

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

도달 경로·생산자/독자·5언어 기본/공식/custom·UI·저장/동결 replay 표적 결과와
비저자 판정을 마감 때 채운다. 새 규범0, 실행 범위·검증 지시는 일회성이다.
