# ORDER-412 — 선물 진열대 가격 앞자리 잘림 수리

#### [x] ORDER-412 [P1·UI] 선물 진열대 가격 앞자리 잘림 수리

**[x] 완료 — 2026-10-04.** source916e51b/tree0f772c7 독립GO.
5언어40가격 잘림32→0·전후20PNG, 제목/수량/설명40개 전량fit.
focused137·영향검사/조회15건652.284초PASS. 가격·번역·사전/receipt 불변.
[독립 판정](../agent_reviews/ORDER-412.json). 일회성·상시규범추가0.
자동PASS는 계약증거이지 재미·문체·출시GO가 아니며 본편/새packageHOLD 유지.

**[~] 착수 — 2026-10-04.** 사용자 계속 개발·검수·main 커밋/푸시 위임.
411의 실제 CN/TW 생활화면에서 8000원 가격의 앞자리8이 잘려 보였다.
가격·구매조건은 보존하고 선물 가격 Label의 최소폭 전달만 수리한다.

## 판정 단위·깊이3문

- 생략하면 플레이어가 선물 가격의 숫자/통화를 온전히 읽지 못한다.
- 24주 뒤 상태·경쟁은 N/A: 표시만 고치며 가격·인벤토리·AP·시간·관계 불변.
- 선물 badge의 국소 layout 수리1단위. 새번역/선물효과/다른행동카드 수리를 섞지 않는다.

## 정확한 범위

- _make_essential_action_card에서 icon_id=="shop"이고 forced_badge가 비어 있지 않은
  경우만 badge_lbl.clip_text=false. 현재 이 조합의 caller는 _build_gift_shelf_card 하나다.
  실제 문자열의 최소폭이 Panel/HBox에 전달되게 한다.
- 기존62px 최소폭·좌우8px 여백·실제14px 서체·금액 formatter·가격8개·구매판정 불변.
  공용 _label 기본clip·다른 badge·카드높이·폰트·텍스트/번역은 변경0.
- 먼저 기존 실제생활모달에서 5언어8가격의 Label/Panel/font 폭을 계측해
  before증거를 보존한 뒤 수정한다. 설명 영어폴백/기존ellipsis는 별도 번역범위이며
  가격 수리로 제목/수량/설명이 새로 잘리거나 겹치면 통과시키지 않는다.
- 새 MainGame 변경의 exact byte inverse와 fresh Git/HEAD/ancestor/raw 연결을 추가한다.
  기존10단계·8 predecessor·사전·공식header/receipt를 보존하고 새단계1을 결속한다.
  collector의 현재 좌표와 동일 KO/EN값·key/leaf집합을 검증하며 이전모듈/pin 완화0.
  현재까지 exact10 source manifest와 신규1만 허용한다. 실패402 raw 제외 유지.

## 파일 소유

- Root: scenes/MainGame.gd 선물 badge 국소수리, tools/audit_scope.json 표적차선/검사등록,
  새 private order412-run.py/check.gd/check.tscn·static runner/실행산출물,
  CLAUDE·CODEX_QUEUE·WORK_LOG·STATUS·이사양·완료archive·
  docs/agent_reviews/ORDER-412.json·docs/agent_review_decisions.json.
- /root/receipt_bridge392: tools/main_game_locale_history.py,
  tools/ui_translation_append.py 새 bounded source/manifest 연결만.
- /root/receipt_tests392: tools/ui_translation_append_self_test.py 새focused만.
  Root 사전검토용 private runtime helper 초안은 root가 별도 위임할 때만 새 order412 파일에 작성.
- /root/independent392: 비저자 코드·원본계측/화면·검사원본 검수,
  private order412-independent-review.json만.
- ja_translation_pipeline.py·locale/**·content/**·InventorySystem/GameState·FontKit·
  project.godot·player파일·과거helper/증거·공개demo·인간원장 변경0.

## 표적 검수

- 실제 MainGame::_open_cat_life 1280×800 KO/EN/JA/CN/TW, gosiwon·현금500000·
  선물8종 각2개 준비. 구매가능7/불가1, pad keycap 표시 포함.
  실제 ScrollContainer를 움직여 상·하단에서8가격 전량을 관측한다.
  before와after 각각 같은5언어 fixture; 실제PNG 수는 전량노출에 필요한 수만 쓴다.
- 8가격×5언어 font.get_string_size·Label/Panel rect/minimum-size·margin·
  clip/line/visible-line·카드포함·title/quantity/keycap/arrow 겹침을 기록한다.
  가격/통화 전체fit·제목전체fit·수량/상태불변과 설명이 before보다 나빠지지 않음을 확인한다.
  before의 재현된fail은 원본보존하며 after최종GO와 구분한다.
- pre-autoload격리·typed전체복원·registry/player/source/helperhash불변.
  dictionary/font/theme/cache주입0. 구매/전달/confirm/이사/시간진행0.
  prepared표면이며 자연진입/Back/물리입력으로 부르지 않는다.
- 새focused1회: exact현재/11단계object·ancestor·HEAD·inverse9·collector전체map/좌표,
  unchanged사전/receipt·exact11manifest, icon/forced조건/clip/이웃변이거부.
- final normal receipt·collector/fullbody·storygraph·Chapter5·Year5·Chapter1·JAUI·ZH·EN,
  context/queue/diff 및 audit_select목록조회만, 최대3병렬·Chapter1 timeout1200.
  이전focused/역사suite/전체감사/240주/완료화면 재실행0.
  실패원본을 남긴 뒤 영향있는 해당검사만 새시도한다.

## 경계

일회성 사양·상시규범추가0. 자동PASS는 계약증거이지 재미·깊이·문체·출시GO가 아니다.
공개GO1·인간OPEN45·본편/새packageHOLD·원어민/인간/물리미관측 보존.
선물 안내 CN/TW15키·Claude B3/B4·다른 UI/서사 결함은 후속이며 이번에 섞지 않는다.
외부출시·스토어·지출·법률0.
