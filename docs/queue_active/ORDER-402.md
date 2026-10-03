# ORDER-402 — 인물 인맥·휴식 카드 이미지 돌출 수리

#### [~] ORDER-402 [P0·UI] 인물 인맥·휴식 카드 이미지 돌출 수리

**[~] 착수 — 2026-10-03.** 사용자 계속 개발·검수 위임.
400/401의 실제 network 화면에서 Atlas 그림이 60px 카드 아래로 돌출한다.
제품의 인물 카드 높이만 내용의 실제 최소 높이를 수용하도록 고친다.

## 판정 단위·깊이3문

- 하나의 확인된 기하 결함 + 다섯 언어 회귀, 한 배치다. 임의의15~25개로 늘리지 않는다.
- 수리가 없으면 인맥·VIP·휴식 그림이 카드 경계를 넘어 아래 카드/여백을 침범한다.
- 돈/AP/시간/관계/가능 행동/클릭 연결/스토리 상태는 바꾸지 않는다.
  선택이나 신규 시스템이 아니므로24주 결과 차이·경쟁 항목은 해당 없음.
- 64px 그림+상하4px의72px는 border 포함 전 계산 하한일 뿐 확정 높이가 아니다.
  before 실제 card/margin/row/icon/texture rect와 combined minimum을 먼저 측정한다.
- portrait 카드와 공통 action builder는 그대로 둔다. 측정에 따라 인물 Atlas 카드의
  local 높이만 실제 MarginContainer 최소높이에 맞춘다. 그림 축소/잘라숨기기로 통과하지 않는다.

## 파일 소유

- Root: scenes/MainGame.gd::_build_people_action_card 국소 높이,
  CLAUDE.md 현재 상태·본 사양·큐2·WORK_LOG·STATUS,
  docs/agent_reviews/ORDER-402.json·docs/agent_review_decisions.json·완료 archive.
- /root/receipt_bridge392: tools/main_game_locale_history.py,
  tools/ui_translation_append.py, tools/ui_translation_append_self_test.py,
  tools/audit_scope.json의 이번 exact successor/표적 차선만.
  private order402-bridge-draft.patch는 이 저자의 단독 소유다.
  source 증거는 Git/raw 역변환으로 기존393을 보존한다. 넓은pin면제 금지.
- /root/receipt_tests392: private order402-check.gd·.tscn·order402-run.py와
  .git/full-game-localization/order402-* 새 계측자료. 과거400/401/393 helper·증거불변.
- /root/independent392: 비저자 code/bridge/helper/원본화면 독립 검수,
  private order402-independent-review.json만. 작성 파일과 겹치지 않는다.
- 사전·accepted receipt·원장·source inventory·번역 원문·FontKit/font/테마·이미지
  파일·게임 조건/행동·project.godot·공개demo·human_gates 변경0.
  401 GO를 이 코드 후보의 판정으로 확대하지 않는다.

## 표적 검증

- clean 선언 후보 before:1280×800 실제MainGame, KO/EN/JA/CN/TW의 network와
  portrait. fresh pre-autoload StoryNameplateBootstrap, 별도 새 namespace.
- 동일 준비 조건의 after: 실제 node rect/minimum, 그림이 icon/card/margin 안에
  들어옴, 인접카드 nonoverlap, 마지막카드/텍스트 모달영역 안에 있음. 초상60px 보존.
  전체화면/모든 해상도 가독성 승인은 아니다. 실제PNG 전후를 독립검수자가 직접 읽는다.
- 페이지·위/아래 순환 커서는 실제 semantic InputEventAction을 기존 people 입력
  handler에 전달해 확인한다. 언어별 cast1→network3→down/up→cast 왕복,
  phase당10PNG. ui_cancel은 미관측, 정리는 _close_modal(false,false)이며 자연Back
  성공을 주장하지 않는다. confirm/pressed/게임행동0. 이것은 물리 패드나
  OS raw 입력 관찰이 아니다. 입력회귀를 실행하면 정확한 action·결과를 기록한다.
- 준비/표시/복원의 protected typed state, 실제 사용자 파일과 source/helper hashes.
  기존 실제 AP getter의 memoization warmup 두 flag만 명시기록, cache/font/theme/사전 주입0.
- changed exact history와 accepted wrapper의 focused 양성/음성 회귀,
  current UI receipt 및 normal 소비자5, ZH/EN·context/queue/diff, 차선선택 조회.
  Chapter1 timeout720초·최대3병렬. 영향 없는 역사 self 전체/400·401 전체 번역화면/
  전체감사/240주를 반복하지 않는다. 실패 시 실패 원본보존 후 해당영향 재검증.
- 사용자34파일·human ledger·기존159판정/137보고·41,069/b169 수용raw 불변.
  기존350/351 오래된pin실패를 통과했다고 바꾸지 않는다.
- 상시규범0. 기존 UI/I18N·WORK_UNIT·gangnamdream-dev 적용, 이번기하·후속bridge는
  일회성 범위다. 원어민/인간/물리패드·자연진입/복귀·11px/포커스·다른화면·B3/B4
  미관측/별도잔여. 공개GO1·인간OPEN45·본편/새package HOLD 보존.
  외부출시/스토어/지출/법률0.

## 2026-10-04 before 실측과 잔여 범위

- 51f913c의 10PNG/20semantic 관측: network15카드60px, 최종margin 최소72px,
  이미지64px. 카드간7px지만 내용간−5px, 이미지가 카드 아래8px 돌출한다.
  portrait5카드60px/그림custom42×42 보존. 이 실측으로 Atlas 국소높이를 수리한다.
- before-final 엔진/GD 관측은 완료했으나 runner가 결함카드15만 예상해 실패했다.
  기존 EN cast 배지까지 세면16이며 EN MONEY2/PEOPLE2의 actual12px 글자44/45px가
  label42px보다2/3px 넓다. 노드·모달 bounds는 정상이고 PNG에서는 단어가 보인다.
  이 실패원본을 수정하거나 PASS로 바꾸지 않는다. before 재부팅 없이 원본hash를
  결속한 별도 분석으로 사용한다. after는 해당4건의 exact text/font/size/width/
  measured/bounds·clip 서명을 대조해 비악화만 검증하고 잔여를 별도기록한다.
  무조건 text_3 면제·전역 text-fit PASS·배지수리 승인은 아니다. 새 text 결함은 실패다.

## 같은 범위의 첫 after 반려·수리

- 44828f3 after-final은 network15카드가64px/최종margin72px로 남아 FAIL이다.
  트리 진입 전 최초 최소값만으로는 최종 여백을 반영하지 못한다. 기존 실패10PNG·
  source/helper·사용자파일 증거는 보존한다. 초기 조회에 더해 실제 margin의
  minimum_size_changed를 국소 연결하여60px 하한과 최종내용 높이를 함께 유지한다.
- focused58 중 prefix marker 자체를 문자열로도 쓰는 검사1건이 FAIL이었다.
  exact marker 행만 세도록 고치며 원본 실패를 보존한다. 정상 소비자검사는 제품
  실패 확인 직후 중단(exit143); 미완료를 통과로 기록하지 않는다.
- 새 clean 후보에서 먼저 같은 runtime 전량과 새 focused만 재검증하고 통과 뒤
  normal 소비자13+선택조회1을 실행한다. 현행 JA UI·차선등록 검사도 포함한다.
  제품 실패를 발견한 채 오래 걸리는 후속 검사를 계속하지 않는다. 일회성.
