# ORDER-441 — 밝은 홀덤 카드의 숫자와 무늬를 읽는다

#### [x] ORDER-441 [P1·화면] 카드 앞면 잉크 대비 수리

**[x] 완료 — 2026-10-05.** 439 실제 화면에서 검은 패의 밝은 글자가 크림색
카드와 거의 구분되지 않는 것을 확인했다. 사용자의 계속 개발·main 커밋/푸시 위임이다.

## 범위·소유

- root: `scenes/HoldemClub.gd` 1468행 색 표현 하나, `tools/ui_translation_append.py`
  EOF source bridge, private441 normal/증거, CLAUDE·큐/L3·이 사양/보관본·WORK_LOG·
  생성STATUS·새 agent 보고/판정.
- claude_handoff_review: `tools/holdem_money_history.py` EOF 좁은 색 전이,
  신규 `tools/holdem_card_color_receipt_check.py`만.
- receipt_tests392: private441 새 격리 Python/GD/scene helper와
  `tools/audit_scope.json` 신규 focused 등록·명시 `holdem-card-contrast` 차선만.
- independent392: 비저자 소스·helper·실제 캡처/노드/보존 증거 검수. 실제 검사와
  engine은 root만 실행한다. 기존 helper·실패/성공 증거·focused·핀 불변.
- TexasHoldem·Main·GameState·Meta·FontKit·LocaleManager·자산·폰트·KO/EN/JA/CN/TW·
  번역 수용41694/b211·승패/덱/돈/AI/타이머/공개조건/AP/저장·인간원장·공개데모 불변.
  기존201판정/179보고를 보존한다.

## 구현·표적 검수

- 현재 `_card_label`의 `Color(TH.card_color(card))` 한 줄만 앞면 전용 검정
  `#141827`/빨강 `#b4232c`로 바꾼다. suit1/2만 빨강, suit0/3은 검정이다.
  같은 위치·44×60·13px bold·강조 ring·card_str·뒷면/placeholder는 유지한다.
- paper3색·fallback2색 및 강조 overlay의 sRGB 대비를 계산한다. 기존 다른 게임의
  red#d73939도 어두운 paper끝에서3.504라 복제하지 않는다. 선택 red는최저4.938,
  black13.354를 기대하되 실제 노드·화면 판독과 분리하며 접근성 인증을 주장하지 않는다.
- 제품 단독 commit 뒤 정확 before/after commit/tree/blob/raw를 결속한다.
  기존 history579행·append1906행을 보존하고 EOF에5전이/30객체·정확 한 줄 역상과
  실제20 manifest만 추가한다. 새로운 Holdem과 과거 다른 파일의 가상 조합은 거부한다.
- 새 focused는 실제 proof/collector 각1회,61 UiCall 전체 tuple·행/owner/문자열·
  Entry 불변, 정확 역상·위조 Git/현재 census·20실제/가상 manifest 반례를 확인한다.
  이전 focused는 비교 자료이며 재실행하지 않는다.
- proven pre-autoload 격리 CN/TW 두 프로세스. 실제 카드 factory의52장×일반/강조
  104노드를 지역별 관측하고, 합법 카드 준비형 일반 테이블/SHOWDOWN 총4PNG를 읽는다.
  네 무늬·10·얼굴카드·플레이어 강조·보드·공개 상대 패·비공개 뒷면/빈 자리 검수.
  실제 source font/color/문자열/크기/glyph/fit·보이는 노드의 소유를 확인한다.
- 준비형 reader이며 입력·첫손·정산·Close0. whole typed/RNG/generation/pending·
  MainUI/의미focus·Meta bytes·논리BGM/Controller 복원, 실제player34 불변.
  node identity/audio playhead/global visual RNG·자연 플레이·물리패드 주장은 하지 않는다.
- 같은 clean 후보에서 fresh 신규focused·receipt·EN·context·queue·diff·등록7검증+
  차선조회1과 새 표적 화면만 실행한다. 원문/수용 불변인 fullbody/JA/ZH·439화면·
  438비동기·과거focused/434서사·전체감사/240주/성능A/B는 참조/NOT_RUN이다.

## 깊이·한계·일회성

- 없으면 현재 패를 읽기 어려워 베팅 판단이 훼손된다. 기존 정보 전달 수리이며
  선택·경쟁·24주 결과·경제 규칙을 추가하지 않는다.
- 이 지시는 **일회성**, 정본 추가0. 기존13px 크기·나머지 영어와 번역·규칙 collector
  잔여는 이번에 고치지 않는다. 자동PASS는 계약 증거이며 실제 품질은 독립 관찰한다.
- 원어민/인간/물리패드 미관측·공개GO1·인간OPEN45·본편/새package HOLD를 유지한다.

## 완료 증거

- 제품 `99aee1b0dc7db01edd2efe33349bc5570847c011`, 최종 source `020b1a212377d1f9ad7e4afc7dbaddc2a9c8c408`, tree `3e04371988401793c01e0e047377426d54a8fd70`를 main에 커밋·푸시했다.
- 실제 CN/TW 208 factory 노드·준비형 table/SHOWDOWN4PNG PASS(21.036초). 실제 입력/첫손/SHOWDOWN dispatcher/정산/Close0, typed2복원·player34 불변이다.
- runtime `.git/full-game-localization/order441-screen-first/result.json` SHA `8a361b112fa7e328f36a2690646894ad958495e6859f7efc9c95a40081d9bac5`.
- fresh7검증+차선조회1 PASS(398.468초), 신규50case/과거0; normal SHA `31ba23619630f7f65f6e456c092803752965fa8ef0c4f730efd9df32469e6786`. 이전 검사는 참조/NOT_RUN이다.
- [독립 보고](../agent_reviews/ORDER-441.json)의 이 범위만 GO. 기존201판정/179보고 보존 후202/180, 지시는 일회성·정본 추가0. 선택 팔레트 대비는 실제 모든 픽셀의 접근성 인증이 아니다. 기존13px/나머지영문/규칙 collector·원어민/인간/물리패드·본편/새package HOLD 유지.
