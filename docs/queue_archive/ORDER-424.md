# ORDER-424 — 투자·시장 선택과 구직 제목을 중국어로 읽는다

#### [x] ORDER-424 [P1·현지화] 실제 SceneFirst 투자·시장 UI 18키와 구직 제목1

**[~] 착수 — 2026-10-04.** 사용자 계속 개발·효율적 검수·main 커밋/푸시 위임.
실제 소비자 KO19키를 CN/TW에서 각각 한국어로부터 직접 저작한다.

## 판정 단위·모집단

- MainGame::_contextual_week_pressure / _demo_week_pressure의 실제 title/question6,
  _demo_action_spec의 투자·승부 title/subtitle4,
  _weekly_commitment_base_preview의 투자·승부 risk/now/cost/later8,
  _ap_job_hunt_title의 구직활동1. 같은 question의 복수 호출은1키다.
- CN/TW 각19값·38receipt/공식batch2, accepted41442/b195→41480/b197,
  CN/TW1626→1645·JA3044불변. exact 키는 private424 모집단으로 결속한다.
- 번역을 없애면 투자 판단·취소 가능 시점·손실 위험·나중의 결과와 구직 제목이
  영어 폴백으로 남는다. 번역 자체가 새 선택·24주 후 효과를 만들지 않으며,
  실제 원금 손실 가능성·거래/플레이 전 취소·장소/자산/세션 하나의 의미를 유지한다.
- 위험1~5·1~3주·{year}/{month}를 보존하고 수익·채용을 보장하지 않는다.
  source detail2는 SceneFirst가 읽지 않아 제외하고, 결과 미정 unknown fallback,
  delayed-cost wrapper/개별키·HUD 혼합은 별도 잔여다.

## 파일 소유

- Root: private424 키·TW 직접초안·공식 export/check/import 및 정상검수 helper,
  locale/ui_zh-CN.json / locale/ui_zh-TW.json 위38값,
  content/meta/full_game_localization.json 위38receipt/checksum/공식batch2;
  큐·본사양·CLAUDE·WORK_LOG·생성STATUS·archive·agent 보고/판정원장.
- /root/receipt_bridge392: private424 CN 직접초안1파일. TW 결과 참조·문자변환0.
- /root/receipt_tests392: 새 private424 화면·입력 helper만; 기존 helper/실패 수정0.
- /root/independent392: KO19/지역38 전수 의미·수치·복수호출/공식수용·raw역상·
  실제8PNG/입력·상태 원본 독립검수, 동일 최종후보 private보고1회.
- MainGame/GameState/KO/EN/JA/가격/조건/폰트/도구/공개demo/인간원장/
  project.godot/출시manifest 비소유. 실제 결함이면 보존 후 별도 선언한다.

## 표적 검수

- 두 지역 직접 독립저작·전수 의미검수, 공식19행씩 export/check/import와
  사전/원장 raw 역상. 기존41442값·195batch 및 이전 모든 실패/판정은 보존한다.
- proven pre-autoload StoryNameplateBootstrap·1280×800 실제 MainGame의
  _demo_director_route_week→SceneFirst→pressure 실제 경로, 지역당4상태/전체8PNG:
  A turn35/2026-09 W3·투자해금·첫방문전·승부가능 → capital/invest-gamble-save;
  B 같은주·방문후·회복잠금·실제 가장가까운인물 조건 충족 → capital/invest-save-contact;
  C turn49/2027-01 W1·tier2·villa·tenure0·portfolio0·지난달money/human0·회복잠금
    → 실제 family market_position/invest-save-study;
  D 기존421 turn25/income-cash0/job빈값 → employment/apply-resume-side_shift.
  투자 상태는 실제 고정비를 덮는 cash/income, health/mental>55, AP>0,
  event/bridge/pending/weekly/forgone빈값, grind0으로 상위 위기를 피한다.
- actual rent/gambling/contextual-family/pressure predicates와 준비 전체상태를
  관측하고 강제 모드/번역/theme/cache 주입0. 준비 상태는 자연 ingress가 아니다.
- UI getter/route의 memo2flag/lazy person/UI tracking 효과는 source에서 독립 기대,
  full typed before/expected/observed/복원과 isolated meta파일·real player34 불변.
- 38 unique lookup와 실제소비 binding, 날짜 format token, title36/question bold19/
  action18/subtitle14/risk-detail-badge12/footer14, 지역SC/TC primary·ownedchain,
  glyph·fullfit·줄수·clip조상·3카드 비중첩·risk actual 최소폭을 확인한다.
- deferred focus0→RIGHT→RIGHT→LEFT→LEFT, 4taps/화면·전체32taps/64합성raw.
  direct focus setter·confirm/pressed/nextturn/trade/item/finalize0,
  ControllerHints cache/mouse/UI tracking 복원. 미선택 행동 실행효과는 미관측.
- 새38값과 같은consumer를 하나의 검수로 묶는다. ui-translation-append 영향
  정상검증 최대3병렬1회; 변경하지 않은421/422/423 및 과거focused/full/240주0.
  최초 실패를 보존하고 실제 영향만 고친다.

일회성 번역/표적사양·상시규범추가0. 자동PASS는 계약증거이지 문체·재미·출시GO가 아니다.
공개GO1·인간OPEN45·본편/새packageHOLD·원어민/인간/물리미관측 및 B3/B4를 유지한다.

## 완료 — 2026-10-04

- 동일 후보 source70ba2b8/tree2a5dada 독립 범위한정 GO: [봉인 보고](../agent_reviews/ORDER-424.json).
- KO19키·CN/TW38값 정식 수용; ORDER424_R1_UI_OK screens=8 keys=19 locales=2 raw=64 taps=32 actions=0.
- 최초 연락 영어후속 잘림 원본은 보존하고425 번역 수리 후 전8화면24.838초 PASS. 연락 later CN295/TW307px ≤366px, 폰트12px 불변.
- 공통normal13행(검증12+차선조회1) 단1회/993.438초 PASS. 실제20PNG·합성80taps/160raw·typed20복원, 원본실패·과거판정·인간원장 보존.
- 일회성/새 상시규범0. 자동PASS는 계약증거이지 문체·재미·출시GO가 아니다. 본편/새packageHOLD·B3/B4·원어민/인간/물리 미관측 유지.
