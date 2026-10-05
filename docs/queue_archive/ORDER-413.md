# ORDER-413 — 선물 진열대·전달 전 준비 안내 중국어 소비자 마감

#### [x] ORDER-413 [P1·현지화] 선물 진열대·전달 전 준비 안내 중국어 소비자 마감

## 완료 — 2026-10-04

- source483b1887c455301619f320685d9c44e181241ab3/treecdcd11e74e98a7418a9ab6554d6cd4ea8b29f83e.
- 비저자30값 KO직접 전수대조·원래14PNG 직접열람·46binding/10typed복원/6자연소멸 PASS.
- runtime32.320초·normal11+목록조회1 670.350초 PASS; 기존raw/플레이어/공개demo/인간원장 보존.
- 독립 [보고](../agent_reviews/ORDER-413.json), private SHA0ebaa9e8fdbba2262ca613b357e27ccbd460e5d17e4044f3c8b2112d2eb89d52.
- 증거 SHA·12명령 원본·모집단·미관측 한계는 보고에 결속. 자동PASS는 계약증거이지 재미·문체·출시GO가 아니다.
- 승격: 없음(일회성 번역·검수). JA2의미수리는414별도. 본편/새packageHOLD·원어민/인간/물리미관측 유지.

## 아래는 착수 선언 원문

**[~] 착수 — 2026-10-04.** 사용자 계속 개발·검수·main 커밋/푸시 위임.
기존 상품명/카탈로그 번역과 별개인 짧은 UI 설명·전달 준비 안내만
KO에서 CN/TW 각각 직접 번역한다. 구매·전달·관계 보상은 실행하거나 바꾸지 않는다.

## 판정 단위·깊이3문

- 생략하면 이미 번역된 상품명 아래 별도 UI설명8개와 준비/차단 안내가 영어로 남는다.
- 24주 뒤 상태·경쟁은 N/A: 기존 표시만 번역하며 가격·수량·관계·AP·시간 불변.
- 기존15 source를15단위, CN/TW 각15값으로 한 배치 판정한다.
  locale당1공식교환·30값/2batch, 비저자30값 KO원문 전수대조.

## 정확한 모집단

진열대 각주2와 _gift_display_desc8:
1. `— 선물 —`
2. `사람 메뉴에서 인연에게 전달할 수 있다. 마음은 가격표에 없다.`
3. `밤을 견디는 사람에게 어울리는, 값싸고 다정한 것`
4. `실용적이라 오히려 마음이 보이는 선물`
5. `밑줄 그을 자리가 많은 책`
6. `좋아한 전시를 기억해야만 고를 수 있는 것`
7. `추운 데서 오래 서 있는 사람을 떠올리게 하는 것`
8. `값이 먼저 보이는 선물`
9. `누구에게나 좋지만 누구에게도 특별하지 않을 수 있는 것`
10. `가장 비싼 답. 정답이 아닐 때 가장 크게 어긋난다`

_open_gift_picker 준비·차단5:
11. `행동력이 없습니다 — 다음 달에`
12. `아직 이르다 — %d주 뒤에`
13. `전달할 선물이 없다. 생활 메뉴에서 산다.`
14. `선물하기 · %s`
15. `무엇을 건넬까. 값이 아니라, 이 사람의 이야기를 떠올린다.`

모두 기존legacy UI leaf. %d1·%s1/주·월/대상 이름을 보존한다.
상품명8과item catalog16leaf/언어는 이미수용되어 재저작0.
숨은 선물 hit/delta·미래관계조건을 설명에 추가하지 않는다.
두지역 문자변환0·JA15기존값·기존사전/receipt/header 보존.
구매 결과·로그·실제전달 반응/반복대사 및 이문구를 공유하는 다른화면은 별도범위.

## 파일 소유

- Root: CNdraft·locale/ui_zh-CN.json 및 locale/ui_zh-TW.json 신규값 merge,
  content/meta/full_game_localization.json 공식30receipt/2batch,
  private order413-exchange*·order413-static*·공식교환원본.
- /root/receipt_bridge392: private order413-zh-TW-draft.json KO직접저작만.
- /root/receipt_tests392: 새 private order413-run.py·check.gd·check.tscn만,
  기존격리/서체/typed복원helper 불변재사용. 엔진은root사전검토후실행.
- /root/independent392: 비저자30값·공식수용·실제화면·검수원본,
  private order413-independent-review.json만. 최종보고SHA공지 후재작성0.
- Root기록: 이사양·CODEX_QUEUE·CLAUDE·WORK_LOG·STATUS·완료archive,
  docs/agent_reviews/ORDER-413.json·docs/agent_review_decisions.json.
- MainGame/GameState/InventorySystem·조건/가격/확률/저장/스케줄/엔딩·KO/EN/JA·
  project.godot·공개demo·인간원장·sourceinventory·tools변경0.

## 표적 검수

- 공식export/check/import locale당1batch; source/selection/leaf/targethash와
  receipt/header연결, append inverse로 이전raw전량보존.
- 실제1280×800 CN/TW 각5준비상태:
  A 생활진열대: 현금500000·8종각2개보유,7상품가능/목걸이1잠금.
  B 전달선택창: 실제 다은 met=true·affinity8·daeun_divorced=false·turn145,
    AP1·cooldown0(last gift=-999)·8종각2개, 실제 eligibility/reachable 확인.
  C 같은자격인물·AP0 toast.
  D AP1·last gift=current turn으로 cooldown4주 toast.
  E AP1·cooldown0·선물없음 toast(준비직접호출이지자연진입아님).
- A/B는 실제scroll을 움직여8상품 각각을 최소1회 온전히관측한다.
  14PNG: A/B 각상하2컷+C/D/E 각1컷을 두언어에서 관측한다.
  이미전량보이는화면을 중복촬영하지 않는다.
  신규15키union·30lookup와8설명×2소비자 연결, 가격8·수량2·대상명삽입을 대조한다.
- 진열대62px/선택60px 카드의14px 설명 한줄ellipsis를 면제하지 않는다.
  제목+수량/가격badge/아이콘 포함·겹침·전체fit/실제SC·TC서체를 검수한다.
  picker는people/AP1 기본badge이며 가격폭수리 조건을 억지로 요구하지 않는다.
  C/D/E 실제NotificationToast는중복없이각1생성·자연소멸/모달비활성을 확인한다.
  모든대상PNG root·독립직접열람. 실제fit결함은새수리범위선언후에만수정.
- pre-autoload격리·typed전체복원·registry/player/source/helperhash불변,
  dictionary/font/theme/cache주입0. 구매/전달/confirm/시간진행0,
  준비fixture이지자연진입/Back/물리관측이아니다.
- normal receipt/fullbody/storygraph/Chapter5/Year5/Chapter1/ZH/EN/context/queue/diff,
  audit_select목록조회만최종후보1회최대3병렬; Chapter1timeout1200.
  이전focused/JA전용/완료화면/역사suite/전체감사/240주반복0.
  실패원본보존후영향만새시도. helper AST검토후 실행하며최종동결뒤변경0.

## 경계

일회성사양·상시규범추가0. 자동PASS는계약증거이지재미·깊이·문체·출시GO가아니다.
공개GO1·인간OPEN45·본편/새packageHOLD·원어민/인간/물리미관측보존.
Claude B3/B4·그밖UI영어폴백·전체번역은별도후속.
412에서 확인한 기존JA 에세이집(이미과잉밑줄)·향수(가격→가치) 의미2곳은
이15키중국어추가 뒤 별도existing-target correction으로 다루며 이번JA변경0. 외부출시·스토어·지출·법률0.
