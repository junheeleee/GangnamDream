# Closed Queue Spec: ORDER-673

> 우선순위·상태 정본: [CODEX_QUEUE](../CODEX_QUEUE.md).

#### [x] ORDER-673 [C4·고지] 상점 초안과 게임 언어 선택에 AI 보조 번역을 밝힌다

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

- root: autoloads/UIStyle.gd의 공통 고지 Label 생산자1개와
  scenes/SplashScreen.gd, scenes/StartMenu.gd, scenes/StoryMode.gd의 해당 소비자 연결 및
  필요한 해당 패널 여백만. 입력 핸들러/언어선택/저장/게임 로직은 비소유.
- root: locale/ui_ja.json, locale/ui_zh-CN.json, locale/ui_zh-TW.json 신규 고지1키씩,
  content/meta/full_game_localization.json의 해당 accepted3·batch1 append만.
  official export/check/import와 ui_translation_append로 source hash/old bytes를 결속한다.
- 번역·상점 저자 m46_48_fact_read: docs/STEAM_PAGE.md의 언어/AI 고지/업로드 문구만,
  .git/order673-ai-notice/translation-response.json 초안. 이 외 제품·큐·Git 쓰기0.
- root: docs/I18N_INFRASTRUCTURE.md 최신 출시 고지/정책 라우팅만,
  docs/queue_active/ORDER-157.md의 현재 C4 gap 한 문장 갱신만, CLAUDE 현재상태,
  큐2·이 사양(마감시 queue_archive/ORDER-673.md)·WORK_LOG 새 앞부분.
- 비저자 a1_qa_release_audit: .git/order673-ai-notice/preflight*, review* 읽기 검수만.
- root: .git/order673-ai-notice/*의 batch/response/receipt/기존검사·격리 런처 증거.
  필요 임시 프로젝트는 /private/tmp/gd-order673-* 아래만. 원 project.godot/저장/설정 불변.

## 검증·판정 경계

구현 방식 정정: 3장면에 literal을 각각 넣은 첫 시도는 실제 inventory에서 공개 데모의
고정 UI source 수(StoryMode82/target121)를 늘려 차단됐다. 그 시도는 수용하지 않는다.
기존 공통 스타일 소유자 UIStyle에 수집 가능한 literal pair1·수동 Label 생산자를 두고
3장면이 소비하게 한다. 이는 동일 고지 객체의 배선 정정이며 새 API·UI 재설계 오더가
아니다. 데모 보호 수치와 스타일 기준선을 바꾸지 않고 실제 inventory로 재확인한다.

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

## 2026-10-15 수용 — 구현·신규번역 한정

source262efe1f54b5781f72cb4bf9ba3a31c4c020d779/tree375fe572cd1835206beb8bfea6cb0fde84d6c778,
targetba8f90b5af5957d2502f347c69b86881c3458f7d에 결속했다. UIStyle 단일 고지1개와
3소비자·상점5언어 초안, 신규JA/CN/TW1각3값/accepted3/batch1만 수용했다.
official export3·import3의 내부check와 기존 current_proof의 실제Git source census,
first-parent transition 및 네 파일 full raw inverse가 통과했다. 새 사전 row만 수용했고
기존 사전/원장·공개demo82/121·콜렉터/스타일기준선은 불변이다.

처음 3scene literal 추가는 demo83/122로 차단되어 소유 선언 뒤 공통UIStyle로 옮겼다.
공식 import의 JA기존5줄 들여쓰기 정규화는 원탭으로 복원했고 repaired inverse PASS다.
해당 실패를 성공으로 덮거나 제품 검사를 완화하지 않았다.

격리 pre-autoload fresh namespace의 CompileCheck69, StoryAudioSettings KO/EN,
I18nInfrastructure3, First30Seconds가 exit0/성공marker·engine/script/parse오류0이었다.
EN한글0·surface coherence·first-start self17도 통과했다. 추가 LocaleSurfaceCheck는
exit0/markerOK지만 ObjectDB/resource1 종료잔여로 strictPASS가 아니다. 사용자지시대로
추적중단·CI예외신설0이며 플레이 영향이나 무영향을 새로 확정하지 않았다.

비저자 source5값·배선검수와 별도 비소유 보존 검토를 수행했다. private 증거:
`.git/order673-ai-notice/history-proof.json`1756B/SHA61dc7fc74d00815bdcc8c2207a6fef705d12078027ed50ae301241eef517c132,
`targeted-evidence.json`4511B/SHA10fda0b7f6572ce56915901d442fc70fad41783e71412624ec9199800b030c92,
`review-source.md`6541B/SHAaf279044a600d1bb549e949e5dfd2314ab358071a2a1e8ee0339726cd45bf55d,
`preservation-review.md`4244B/SHAbe4d2c5eb79c53d91edf4570a77bd48cb246a68ff2702d3bfc3998a8a6588f12.
최종 target/ledger 독립GO는 `review-final.md`7765B/
SHAe1afc8ec44096a587ac4d8592c24aadee6488b87fe69dd409683048b265f281e와
`.json`11841B/SHA2cf7053d4fd0f37857717ea1f21b13916e72f5bd7110d43311b1a3809e0ae341다.
후속 기존 I18N coverage(EN1813/1813·ending35/35)와 multilingual surface도 통과했다.

완료 표시는 구현·신규번역 범위만 뜻하며 화면 관찰이나 출시 판정이 아니다.
실제 렌더3×5·CJK폰트/줄바꿈·native/물리패드·외부Steam반영·사람2~3h·C4전체/
C5/출시GO는 발급하지 않는다. 기존발급앱/공개demo GO를 새source에 상속하지 않는다.
612사양11314B/suffix3555B·project/LocaleManager/인간원장·사용자저장/설정 보존,
새월0·전체audit/240주 재실행0. 남은 C4 실제반영·사람확인은 부모157/큐에 유지한다.
