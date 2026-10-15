# Active Queue Spec: ORDER-673

> 우선순위·상태 정본: [CODEX_QUEUE](../CODEX_QUEUE.md).

#### [~] ORDER-673 [C4·고지] 상점 초안과 게임 언어 선택에 AI 보조 번역을 밝힌다

## 위임·대상

DECISIONS 2026-10-15의 C4 직접 기여이며 ORDER-157의 좁은 자식이다.
새 고지 한 문장 KO/EN과 JA/zh-CN/zh-TW 신규3값만 작성한다. 기존 번역 다듬기,
retail5언어 활성화(C5), 실제 M18 월 플레이, 외부 상점 변경/업로드/설문은 비소유다.
이미 공개된 M01~M06 exact 앱·사용자 GO를 덮거나 새 후보에 상속하지 않는다.

## 깊이 3문

1. 삭제하면 무엇이 깨지는가? 승인된 일본어/중국어 AI 보조 번역 고지가 사라진다.
2. 게임 상태를 바꾸는가? 아니다. 고지는 읽기만 하는 Label이며 선택·관계·시간·저장·
   language allowlist를 바꾸지 않는다. 본편 24주 뒤 상태와 경쟁하는 새 결정이 아니다.
3. 무엇과 경쟁하는가? 언어 선택의 한정 높이·가독성이다. 새 버튼/포커스/모달 없이
   세 선택 표면에 14px 이상 보조 Label을 넣고 기존 입력과 화면경계를 보존한다.

## 배치 1 — 고지 source·상점 초안

KO/EN 안정 pair1·대상3언어 직접 신규번역, 상점5언어 고지 문안을 대조한다.
상점 언어절/업로드 전 원어민 차단 문구는 최신 DECISIONS로 라우팅하고 역사OPEN은
그대로 보존한다. 공식 Steam 정책/법률 판정을 새로 만들거나 외부 문구를 게시하지 않는다.

## 배치 2 — 소비자·표적 검증

Splash 첫언어gate, StartMenu 설정, StoryMode 장면설정의 3소비자×5언어=15표면을
동일 고지 source로 연결한다. UI1키와 영수증3개만 수용하며 이전 사전/원장 원형을 검증한다.
현존 검사/격리 bootstrap을 재사용한다. 새 검수도구/시간단축 프로젝트는 열지 않는다.
실제 Mac 화면이 불가하면 source/컴파일/자동 layout 증거와 미관찰한 실제 화면을 분리한다.

## 파일 소유권

- root: scenes/SplashScreen.gd, scenes/StartMenu.gd, scenes/StoryMode.gd의 고지 Label과
  필요한 해당 패널 여백만. 입력 핸들러/언어선택/저장/게임 로직은 비소유.
- root: locale/ui_ja.json, locale/ui_zh-CN.json, locale/ui_zh-TW.json 신규 고지1키씩,
  content/meta/full_game_localization.json의 해당 accepted3·batch1 append만.
  official export/check/import와 ui_translation_append로 source hash/old bytes를 결속한다.
- 번역·상점 저자 m46_48_fact_read: docs/STEAM_PAGE.md의 언어/AI 고지/업로드 문구만,
  .git/order673-ai-notice/translation-response.json 초안. 이 외 제품·큐·Git 쓰기0.
- root: docs/I18N_INFRASTRUCTURE.md 최신 출시 고지/정책 라우팅만, CLAUDE 현재상태,
  큐2·이 사양(마감시 queue_archive/ORDER-673.md)·WORK_LOG 새 앞부분.
- 비저자 a1_qa_release_audit: .git/order673-ai-notice/preflight*, review* 읽기 검수만.
- root: .git/order673-ai-notice/*의 batch/response/receipt/기존검사·격리 런처 증거.
  필요 임시 프로젝트는 /private/tmp/gd-order673-* 아래만. 원 project.godot/저장/설정 불변.

## 검증·판정 경계

기존 relevant UI/한영·사전·원장 검사를 선택 목록으로 먼저 확인한다.
콜렉터/기준선/제품 검사를 삭제·완화하거나 미승인 예외를 추가하지 않는다.
source-code 후보를 로컬에 먼저 결속한 뒤 새 UI 영수증을 그 source commit에 묶고,
번역/표적 검증 완료 전 불완전 후보를 원격 main에 올리지 않는다.
신규고지의 독립 전수 검토·old 사전/원장 inverse·비소유diff·context/queue/diff를 확인한다.
C4의 인간2~3시간, 실제상점게시, 실제UI관찰, 전체5언어 출시/C1~C5 완료를 발급하지 않는다.
진행중612사양/큐overlay·WORK_LOG suffix3555B와 사용자 자산/설정을 분리 보존한다.

## 규범

출시5조건의 정본은 기존 DECISIONS다. 고지 문구는 STEAM_PAGE, 현지화 배선은
I18N_INFRASTRUCTURE를 참조한다. exact 파일 소유·15표면·수용·검증은 일회성이다.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.
