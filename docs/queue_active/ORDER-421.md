# ORDER-421 — 구직 선택과 대가를 중국어로 읽는다

#### [~] ORDER-421 [P1·현지화] 구직 결정 화면의 제목·선택지·기본 결과 안내

**[~] 착수 — 2026-10-04.** 사용자 계속 개발·효율적 검수·main 커밋/푸시 위임.
실제 같은 화면의 KO38키를 17+21 두 소스 배치로 나눠 CN/TW 각각 직접 저작한다.

현재 sourcebb73a66 공식76값 수용 후 최초runtime24.431초 FAIL·HOLD.
위험도24라벨 폭1px 실제결함은 [423](ORDER-423.md)에서 별도 수리한다.
원본8PNG/32taps/64raw/typed복원은 보존하고, 완료 판정은 수리 후 같은8화면을 따른다.

## 판정 단위·모집단

- A17: MainGame::_demo_employment_pressure의 title/question8,
  _demo_action_spec의 apply/resume/side_shift/save/study title/subtitle8,
  _render_scene_first_decision의 선택 경쟁 footer1.
- B21: 같은 다섯 행동의 _weekly_commitment_base_preview now/cost/later15,
  위험2와 _make_demo_decision_card의 지금/대가/후속/1회4.
  정확 KO키는 새 private421 키 원장에 두 묶음으로 결속한다. 교집합0.
- 현재 CN/TW 각각38미번역·exact UI receipt0. JA38은 기존 값·바이트를 보존한다.
  CN/TW76값/receipt76/공식batch4, accepted41366/b191→41442/b195,
  CN/TW1588→1626·JA3044불변을 목표로 한다.
- 번역을 없애면 실제 구직 판단의 질문과 대가가 영어 폴백으로 남는다.
  번역 자체는 새로운 선택·24주 후 차이를 만들지 않는다. 기존 지원/준비/현금/
  절약/학습의 경쟁과 수치·시간·조건을 그대로 옮긴다.
- 하나·두 길·1회·수입0원·1~3주·3만~10만원·건강-3·정신-2와 %s1을 보존한다.
  채용 여부/미래 자격을 확정 보상으로 바꾸지 않는다.
- forgone_path_debts={}의 기본 preview만 대상이다. 과거 포기 누적의 delayed-cost
  wrapper1+개별4키는 별도 미번역 잔여다. pressure.detail4는 이 화면에서 읽지 않아 제외한다.
  수첩 후보는 현재240주 버튼 진입0으로 제외했다. 이 배치를 화면 전체·모든 저장
  상태·일본어·본편 번역 완료로 부르지 않는다.

## 파일 소유

- Root: private421 exact 키·TW 직접초안·공식 export/check/import helper,
  locale/ui_zh-CN.json, locale/ui_zh-TW.json,
  content/meta/full_game_localization.json 위76값/receipt76/checksum/batch4.
  큐·본사양·CLAUDE·WORK_LOG·생성STATUS·archive·agent report/판정원장.
- /root/receipt_bridge392: private421 CN 직접초안 한 파일(한국어 직접저작·TW 참조/변환0).
- /root/receipt_tests392: 새 private421 실제화면·입력 관측 helper만.
- /root/independent392: KO38/지역76값 전수 의미·수치·다중호출 문맥 검수,
  공식수용/raw역상·실제화면·입력/상태 원본 독립검수·최종private보고1회.
- MainGame/GameState/ControllerHints/BuildFlavor/KO/EN/JA/폰트/조건/가격/
  기존검사·proof·공개demo/인간원장/project.godot/출시manifest 비소유.
  새 결함은 원본 보존 후 별도 선언하며 새 시스템·범용 검사 확대0.

## 표적 검수

- 두 지역 KO직접 독립저작, 전수 의미/사실/수치·공식 두 배치씩 수용/raw역상 보존.
- pre-autoload StoryNameplateBootstrap 격리·1280×800 실제MainGame,
  _demo_director_route_week→_render_ap_actions→SceneFirst→실제pressure 경로.
  준비 turn25/resume=false: employment/apply-resume-side_shift;
  turn26/false: readiness/resume-study-apply; turn26/true: followup/apply-study-side_shift;
  turn27/false: survival/side_shift-save-apply. CN/TW 각각4화면·합8PNG.
- current_event/job={}, income/cash0, health/mental>45, AP>0, pending/weekly/bridge/forgone빈값.
  actual 고정비 양수·crisis→decision과 pressure ID/카드순서를 관측한다.
  mode 강제주입0, prepare를 자연스토리진입으로 주장0. static QA meta의 자동진행
  차단은 명시하며 실제 pressure/decision predicate를 별도 확인한다.
- memo2flag와 최초 absent Hyunsu의 정확 literal lazy생성을 코드에서 독립 기대한다.
  EventManager bridge 실제 consume·빈 큐를 기록한다. 전체 typed 기대/관측/복원,
  current_job/income/health/forgone 및 meta 실제 파일바이트·real player34 불변을 확인한다.
- 76 unique lookup/source binding 및 모든 해당 Label/RichTextLabel 소비 위치를 측정한다.
  actual크기 title36/action18/subtitle14/risk-detail-badge12/footer14.
  질문 raw [b]...[/b]/parsedexact·자연typing·actual bold_font700/19px를 사용하며
  regular11px 또는 normal-only probe로 대신하지 않는다. SC/TC primary/ownedchain/
  전체fit·subtitle max2줄·ellipsis0·viewport/clip조상 경계·3카드 비중첩.
- 소스 deferred 초기 focus0→RIGHT→RIGHT→LEFT→LEFT로 0→1→2→1→0을 관측.
  화면당4 taps/8 down-up key events, 전체32taps/64 raw 합성키보드이벤트.
  focus setter0·confirm/pressed/nextturn/거래/아이템/주간finalize0.
  ControllerHints 입력모드/major-event cache/mouse mode를 별도 저장·복원한다.
  실제 물리패드·화면외 분기·자연 ingress·선택효과 실행은 미관측이다.
- 같은 화면의 두 묶음을 한 번에 검수한다. 현재 ui-translation-append 영향 정상
  소비자는 최대3병렬1회, 최초 실패는 원본 보존 후 실패 영향만 재검수.
  기존420 및 과거 focused/화면·전체감사·240주 재실행0.

일회성 번역·표적사양/상시규범추가0. 자동PASS는 계약증거이지 문체·재미·출시GO가 아니다.
공개GO1·인간OPEN45·본편/새packageHOLD·원어민/인간/물리미관측과 B3/B4를 보존한다.
