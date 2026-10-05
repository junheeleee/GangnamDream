# ORDER-403 — 행동 축 배지 글자폭 수리 내부 검수 완료

**[x] 완료 — 2026-10-04.** 비저자 /root/independent392의 work_unit GO.
source12948992e3cb9331adb96a0b96928c3ee818dddd,
tree5e30d8eea3375fbaabc767e1a7d152678027d4e0.
[독립 보고](../agent_reviews/ORDER-403.json)·agent_review_decisions 소유.

- 공용 action card의 axis Label만 clip_text=false 한 줄 수리.
  EN6의 MONEY44/PEOPLE45 대 label42를 실제글자 최소폭으로 수용한다.
  after label44/45·panel60/61, floor58·font12·여백8+8 유지. 35/35축배지 fit.
- before10PNG18.855초는 측정완료/수리FAIL, after10PNG18.811초는 수리PASS.
  실제people/work10PNG + cast5노드 + mixed5개 별도공유component, 5언어1280×800.
  root·저자·독립검수자 전후20PNG 직접확인. Atlas72/초상60/work82/mixed56 유지.
- 비축180행에서 기존fit→신규nonfit0. 기존resume preview4는 명시ellipsis로 남아
  all_text_fits=false다. 전체UI 완전표시 승인으로 확대하지 않는다.
  typed준비/표시/복원10·AP warmup5(delta0)·사용자34파일·tracked2966불변.
- 새403wrapper 호출내 fresh proof 재사용, 정확8허용조합/원본census/이전body 보존.
  focused107/historical0 PASS45.479초. 동일7manifest비교 실측25회8.516초→
  7회2.446초. 합성3항목manifest 비용이며 전체감사 속도 수치가 아니다.
  실패402 raw·부분역변환·HEAD/Git/census 소실은 허용하지 않는다.
- normal13+영향조회1 PASS561.336초, 영향조회96목록은 실행96건이 아니다.
  Chapter1 debt8/blocked3/gap24·year5 reference_only/invalidated 유지.
  역사self/전체감사/240주 반복0. 기존160판정/138보고·인간원장·수용41,069/b169 보존.
- 자연진입/Back/OS raw/confirm/행동/물리·다른해상도·원어민/인간 미관측.
  CN/TW work 영어잔여는 다음404, 11px/포커스·B3/B4·본편/새packageHOLD 별도.
  공개GO1·인간OPEN45 유지. 자동PASS는 출시GO가 아니다.
- 상시규범0/일회성. 기존UI/I18N·WORK_UNIT·gangnamdream-dev 적용.
  아래 최종 실행사양 원문을 보존한다.

## 착수 사양 원문

# ORDER-403 — 행동 축 배지의 영어 글자 잘림 수리

#### [~] ORDER-403 [P1·UI] 행동 축 배지의 영어 글자 잘림 수리

**[~] 착수 — 2026-10-04.** 사용자 계속 개발·검수 위임.
402 before/after에서 EN MONEY44px·PEOPLE45px가 label42px보다 넓은 잔여4건을
확인했다. 고정 글자 크기를 줄이거나 단어를 바꾸지 않고 실제 글자 최소폭을 배지가 수용한다.

## 판정 단위·깊이3문

- 하나의 확인된 공용 축 배지 기하 결함과 소비자 회귀, 한 배치다.
- 수리가 없으면 돈/사람 행동 분류가 잘린다. 선택·돈/AP/시간·관계/가능 행동은 불변이며
  24주 결과와 경쟁 항목은 해당 없음. 배지58px 하한·12px 실제 글자·좌우8px 여백은 유지한다.
- 원인은 공용 _label의 clip_text=true를 상속해 Label 최소폭이 실제 글자폭을 요구하지
  않는 것이다. _make_essential_action_card의 axis_lbl 한정 clip_text=false로 수리한다.
  공용 _label 전체·다른 title/subtitle/AP/keycap·서체/테마·그림 크기는 수정하지 않는다.

## 정확한 소비자와 파일 소유

- 실제 nonempty axis 소비자는 _build_people_action_card와 _cat_modal_button 두 곳.
  money/human은 실제 인물 화면, money는 무직/social0 일 화면에도 있다.
  mixed 반환 경로는 있으나 현재 _cat_modal_button 호출에 _ap_study가 없고 실제 study4카드는
  axis가 빈 값이다. mixed는 별도 실제 builder component 검사이며 자연 소비로 부르지 않는다.
- Root: scenes/MainGame.gd::_make_essential_action_card의 axis_lbl 한정,
  CLAUDE.md·본 사양·큐2·WORK_LOG·STATUS·docs/agent_reviews/ORDER-403.json·
  docs/agent_review_decisions.json·완료 archive.
- /root/receipt_bridge392: tools/main_game_locale_history.py, tools/ui_translation_append.py,
  tools/ui_translation_append_self_test.py, tools/audit_scope.json의 exact403 successor만.
  이전402/393 및 실패 증거 보존, 넓은 hash면제나 사전/accepted manifest 재작성 금지.
  사용자 검수효율 지시에 따라 NEW403 manifest wrapper의 동일 호출 안에서만 fresh
  proof1회가 반환하는 실제current+6역사raw로 정확8허용조합을 비교한다(pre381×preAruba 비교1별도).
  기존7조합+새pre403만 동등성을 검증하고, 실패402 b8·잘못된preAruba조합·미소유변경은
  거부한다. Aruba는 기존대로 실제raw와 별도fresh역변환 필요. no-source_hashes 합성
  fixture delegate 보존. mutable/global/호출간 캐시0; Git/HEAD/raw 소실은 다음 호출실패.
  정상소비자/원장/이전wrapper-body는 줄이거나 고치지 않는다. 시간 절감률은 실측 전 미정.
- /root/receipt_tests392: private order403-check.gd/.tscn/run.py/static-run.py와 새 증거.
  /root/independent392: 비저자 실제 코드·원본 증거·화면 전수검수와 private403 보고만.
- 사전·수용원장·source inventory·KO/EN/JA/CN/TW 원문·게임조건·수치·라우팅·
  project.godot·공개demo·human_gates·이전 source/helper/evidence 변경0.

## 표적 검증

- 먼저 clean before 관측을 봉인한다. 402 원본은 기존 people 잔여의 비교 증거이지
  새 generic/mixed 관측의 대체가 아니다. 새 after는 동일 준비조건·1280×800·5언어.
- phase마다 people network3 + 실제 _open_cat_work 무직/social0 =10PNG.
  cast1은 별도 실제 node60px 보존 측정. mixed5개는 실제 shared builder로 만든
  component probe이며 모달 자연도달·실제 선택 결과라고 쓰지 않는다.
- 실제 axis label/font/측정width와 panel/style 여백, 전후 clip 최소폭 반영을 확인.
  새 text-fit 결함0, 축 배지 전부 fit. 402의 EN4 면제를 그대로 가져오지 않는다.
  title/subtitle/preview/AP/keycap/arrow·card/margin·이웃·모달/viewport 비침범을 확인한다.
  generic preview는 기존 의도된 ellipsis가 있어 before의 clipping/measurement/bounds를
  남긴다. 기존 ellipsis와 새 배지 결함을 섞어 전체 text-fit PASS로 부르지 않는다.
  baseline에서 fit하던 비대상문자가 새로 잘리는 회귀는 실패다.
  사람 Atlas72/portrait60·일 카드82·thumb/custom/image/font/text identity 보존.
- fresh pre-autoload StoryNameplateBootstrap 및 typed 준비/표시/복원, 실제 사용자34파일,
  source/helper hashes. 업무fixture current_job도 deep-save/restore하고 시작flag 두 개와
  arc_intro_meal_seen을 고정한다. 사전/cache/font/theme 주입0. confirm/pressed/거래/finalizer0.
  자연진입/Back/OS raw/물리 입력·전 해상도·일 메뉴 전체 상태는 미관측이다.
- before 실패 원본은 수정하지 않고 측정완료와 수리PASS를 분리한다.
  runtime+403focused 우선; 실패 후보의 느린 normal 검사는 중단한다.
  통과 후보만 현행 UI receipt/normal 소비자5/JA UI·ZH·EN/context/queue/diff/차선등록·선택조회.
  Chapter1 timeout720초/최대3병렬. 이전 self/전체감사/240주·402전체 재실행0.
- 독립 실제 검수가 끝난 exact source만 이 단위 GO. 이전 인간/공개 판정·원장raw는
  보존한다. 본편/새package·외부 출시GO 아님. 원어민/인간/물리 패드는 미관측으로 남긴다.
- 상시규범0/일회성. 기존 UI/I18N·WORK_UNIT·gangnamdream-dev를 적용한다.
