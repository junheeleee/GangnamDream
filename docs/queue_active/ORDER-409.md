# ORDER-409 — 직장 근속 표시 폭·영어 승진 기준 수리

#### [~] ORDER-409 [P1·UI] 직장 근속 표시 폭·영어 승진 기준 수리

**[~] 착수 — 2026-10-04.** 사용자 계속 개발·검수·main 커밋/푸시 위임.
406/407 실제 화면에서 확인한 EN 근속명 잘림과 inclusive60 오역만 수리한다.
408 검사 수명 수리는 별도 완료 증거를 유지한다.

## 판정 단위·깊이3문

- 생략하면 영어 Tenure가 Tenur로 잘리고, 실제60이상 조건이60초과로 안내된다.
- 24주 뒤 상태·경쟁은 N/A: 표시만 수리하고 승진/직업/행동/시간 계산은 불변이다.
- MainGame 두 국소변경을 한 단위로 보고 새 번역·새기능·전체레이아웃 수리를 섞지 않는다.

## 정확한 범위

- _open_cat_work의 tenure_lbl 36px minimum 뒤 clip_text=false를 한 줄 추가한다.
  기존36px floor·months72px·HBox간격8·진행바EXPAND는 보존하며 이름의 실제최소폭을 받는다.
- 같은 함수의 KO '근속 기간 충족. 업무 성과를 60 이상으로 올리세요.'는 그대로 두고
  EN만 'Tenure met. Raise performance to at least 60.'로 고친다.
  조건 tenure>=threshold/perf>=60·실제확률·job threshold/보수·행동불변.
- 기존KO key/JA/CN/TW값·사전원문·accepted41152/b178·공식header/receipt 전량 불변.
  새번역수용0. UI leaf의 Korean-source identity와 English/context좌표를 구분한다.
- 현재 MainGame2곳만 byte inverse. 기존406 포함10단계 fresh Git/object/HEAD/raw
  검증과8개 predecessor를 유지하고 이전모듈본문/pin을 완화하지 않는다.
  실제collector의 영어값·좌표만 정확히 갱신하고 새고유키/선택집합 변화0을 확인한다.
  기존9 manifest와 이번현재1까지 exact10 허용, 실패402 raw 제외는 유지한다.

## 파일 소유

- Root: scenes/MainGame.gd 두국소변경, tools/audit_scope.json 표적차선/검사등록,
  CLAUDE·CODEX_QUEUE·WORK_LOG·STATUS·이사양·완료archive·
  docs/agent_reviews/ORDER-409.json·docs/agent_review_decisions.json,
  새private order409-run.py/check.gd/check.tscn과실행산출물.
- /root/receipt_bridge392: tools/main_game_locale_history.py,
  tools/ja_translation_pipeline.py, tools/ui_translation_append.py의 새bounded연결만.
- /root/receipt_tests392: tools/ui_translation_append_self_test.py 새focused만.
- /root/independent392: 비저자실제원문/정합/화면/원본검토,
  private order409-independent-review.json만.
- locale/**·content/**·JobSystem·FontKit·공통label/월수라벨·project.godot·
  player파일·이전private helpers/증거·공개demo·인간원장 변경0.

## 표적 검수

- 새focused1회: current raw/HEAD/ancestor/immutable10단계·inverse8·collector영어/좌표·
  sameKO key/leaf identity·exactmanifest10·사전/receipt불변·잘림설정인접변이거부.
  406 이전 focused/역사suite는 재실행하지 않는다.
- 실제 MainGame 일메뉴 1280×800 KO/EN/JA/CN/TW 각1회 총5PNG.
  실제job_03·tenure=threshold12/perf59/promotion_count0/max3·monthly_income2240000,
  startup/creator false 준비. 이 한상태로 근속이름·월수·성과미달 경고를 함께 읽는다.
  실제14px 근속명 전체폭과36px floor, months72px·진행바양수·간격/겹침/포함 측정.
  EN 'at least 60'와 각언어기존KO직접값 소비를 확인한다.
- pre-autoload격리·typed전량복원·원본registry불변·user/source/helperhash불변,
  사전/font/cache주입0. 새actualaction/confirm/promotion/trade/finalizer0.
  helper본문/형타입 사전검토 후 실제실행, PNG5장전수 직접열람/독립검수.
- normal receipt·collector/fullbody·storygraph·Chapter5·Year5·Chapter1·JAUI·ZH·EN
  및context/queue/diff/audit_select목록조회만. 408덕분에 Chapter1한snapshot proof1회.
  최대3병렬, source/helper전후동일. 실패원본보존 후 해당검사만 별도시도.
- 전체감사·240주·완료406/407화면·다른해상도·자연진입/Back·물리검수0.

## 경계

일회성·상시규범추가0. 자동PASS는 계약증거이지 재미·문체·출시GO가 아니다.
공개GO1·인간OPEN45·본편/새packageHOLD·원어민/인간/물리미관측 보존.
Claude B3/B4원고·다른UI영어폴백·전체번역은 별도후속이며 이번에 섞지 않는다.
외부출시·스토어·지출·법률0.
