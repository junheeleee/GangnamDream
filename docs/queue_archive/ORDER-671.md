# ORDER-671 — 대출·주거·물품 UI 중국어 실제 누락 25키

#### [x] ORDER-671 [현지화] CN/TW 신규50잎 — 2026-10-15

기준 main061ca4ff63573a25218745780f642126794f6085. ORDER-157의15~25단위
증분 누락 보충을 잇는다. Mac잠금·같은M18/612/BUILD14.3 HOLD·새월0/
열린실제월1. KOEN확정전JA/zh다듬기금지·기존target교체0·5출시언어유지.

## 깊이·정확 범위·소유

기존대출/상환·주거갱신과이사·물품구매사용25키가CN/TW영어fallback이다.
사전의실제누락만채우며돈/대출/원금/주거/시간/행동력/저장처리를바꾸지않는다.
정확25 ID/source/context는 .git/order671-20261015/population.json에봉인한다.
전부JA존재·CN/TW부재·supported/unprotected를현행collector로실측했다.
GameState:4312/4328의인자는emoji/상품명/실제차입액(또는paid)/잔여원금순서다.
MainGame:17963/17976/17978은실제borrow/repay결과표면, 수익/증여가아니다.
MainGame:18568/18575는shared-home일때내주거계약갱신이며실제이사로바꾸지않는다.
18572/18579의일반이사와갱신을구별한다. GameState:1657 보증금인자는
deposit_diff이며총보증금/집값으로발명하지않고KO표시레이블·인자순서를보존한다.
MainGame:13524 rent_ready는현금+max(0,월수입)>=주거비다. 납부완료/이미현금만
확보라는사실을발명하지않는다. 물품사용은InventorySystem:26/30/32가AP1소비,
MainGame:20384가행동력-1을표시한다. SeoulCycleBoard:680 사용함은spent상태다.
MainGame:13497 이사/선물진열대는시간소모없음이며물품사용AP와혼동하지않는다.
정상FullStoryFlow입구/실제25상태·native·폭·원어민은미관찰이다.

root: locale/ui_zh-CN.json·ui_zh-TW.json 신규25키씩만공식import,
content/meta/full_game_localization.json accepted50/checksum/UIbatch1만.
큐2/사양/archive/CLAUDE현재행/WORK_LOG/새private자료도root소유.
m46_48_fact_read: 새private cn.response.jsonl 저작만·비저자TW25보고.
a1_qa_release_audit: 새private tw.response.jsonl 저작만·비저자CN25/append보존보고.
한국어에서독립작성·상대초안중역/간번변환0·비저자각25전수후수용.
기존CN贷款/行动力/物品·TW貸款/行動力/物品등현행UI용어를확인한다.
KOEN/runtime/JA/기존target/조건/정본/저장/project.godot/publicdemo/human/
retail언어설정/원앱·seed·670원고/receipt는비소유다.

## 순서·검증·완료 경계

선언commit/push → before4/보호핀 → fresh exact25 export×2 → 독립저작/
비저자전수 → official check/import --accept×2 → 원header/receipt digest원장append →
기존validate_append4rawinverse/Git sourceproof → 표적7·독립보존 →
제품commit/tree·마감commit/push·실제SHA CI1회확인. --replace-existing 금지.
old328batch/alloldaccepted/기존2314키각order/value/bytes·JA exact가필수다.
source3339c82ed736e8df7542dd304ef15cf813b6418fa1bdb23f4b1d8e8c5b994405,
기존invalid137/70/72와static밖officialinventory JSON은불변이어야한다.
명시제품3경로선택--list조회·ZH all/JA UI/i18n/demo scope all/storydemo/
officialCN·TW inventory7, context/queue/diff와기존appendproof만실행한다.
612범위밖namedlane/explicit병행거부는669원진단을잇고같은실패재실행0.
새checker/selftest/등록·479/481후속·도구수리·전체audit/engine/자연240/native0.
612dirty4/WORK_LOG3555B suffix SHA
a9da54e58a91283d1732eae4d0581400cf8dc499274eb1b8aa2ec95c3a7c693b
는모든commit제외/보존한다. 전체 INCOMPLETE/native/rendered OPEN·실제M18/
5언어전체/CI전체녹색/출시HOLD를유지하고누락감소25/locale만완료로센다.
개발스킬/I18N직접번역·증분·독립보존적용·일회성배치/새정본승격0.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.

## 마감 — 2026-10-15

선언a71a10aa5dd93137bcb54a3f56b8bc8f068a77dd →
제품0d555ad1c01f88f31504f6a62c10f4729408630c /
treedc0f7b15c31ecf66b5d970361b4ca4572971191a.
CN/TW 신규25각50 directKO 독립저작·상호비저자전수 source품질만수용했다.

| 완료 증거 | 측정값 또는 file:line |
|---|---|
| 도달 경로 | MainGame/GameState/InventorySystem/SeoulCycleBoard의현행call→LocaleManager:212/475; 정상입구/25상태실행은미관찰 |
| 생산자 ↔ 독자 | GameState:1657/4312/4328·MainGame:13497/13524/15308/17963–17978/18568–18582/20384·Inventory:15/17/30/32·Cycle:680 ↔ 신규CN/TW25키 ↔ batch329 |
| 바꾸는 상태 | static2110→2135/2980·missing870→845·current2030→2055각각; accepted14853→14878·JA13173불변 |
| 포기 시 잃는 것 | 차입/상환/주거갱신/실제이사/물품구매사용/월세대비의중국어직접번역25키 |
| 서사 위치 | 기존UI누락·신규장면/분기/조건/경제/시간/저장변경0 |
| 장면 계층 | UI번역·신규T1/T2/T3/자산/연출0 |
| 닫는 것 | check/import2각actual0·nonengine표적7actual0·4rawinverse/Gitproof·독립50source/append보존만; 실제월/native/원어민/5언어전체/출시GO0 |

차입은부채와현금이함께늘어나는것이며소득/증여로번역하지않았다.
상환의paid와잔여원금을서로바꾸지않고상환완료를전액청산으로확장하지않았다.
shared-home 내주거계약갱신과일반실제이사를구분했다. 保證金/押金인자는
deposit_diff이며총보증금/집값으로발명하지않았다. 월세감당은현금+
max(0,월수입)>=주거비의가능상태이지납부완료/현금전액확보가아니다.
물품사용AP-1·진열대무시간·Cycle spent를분리하고printf20/✓2/→3/+%s1/-1을보존했다.
기존CN住房合同/押金/月租, TW居住合約/保證金/月租·양쪽物品/행동력지역형에맞췄다.

TW초기房租의region검사exit1 및전체25REWORK/수용0·부분수용0을보존했다.
원응답7032c53402ddb7e453c6b03fd1f40c49e9ce6e21b4e31281aa0a13a2b6daeb90는
tw.response.initial.jsonl로byteexact보존. row19/20의房租→月租두행만수리,
같은25전수재검수후최종cf48a7dea1c6f80dfaedbf87fda52db29d195148df4a38f3dc41d536e118bab9
를수용했다. CN9c60e17b791ff9df7cbabd83e08ce7372539519dcf81dfc190e4c4be8160284c는
초안부터check0·품질GO이며변경0. 검사약화/초기실패숨김/부분승인0.

CN md7339B/dd0e9aff8da57b78144224127bdf28be76997bed537f15c13757df13fdc9eef9,
json6349B/43553ce6656e6feb9bce02063b4c6152bc64e70aa85f394ce9ca23dac87e6158.
TW final md5280B/8a163e0905c7fa5d60ce1b5e3140c0b59b1b609b263eb6bdc8a9d8e721f87919,
json16364B/0c9f6ea7eef8961070de8b1e935dc8825cb317adadc554c24cdbd1a85e931ee6.
보존md6757B/a2d5320343cbd65045aa065ff8aa87393fd801e3d0b8b536f03bfe19ffba4d9b,
json10460B/43257ea981c58599d64e15579d914ae56f127650458b50116b39f630022b8390.
root최종6보고/초기TW2보고전문·CN10/TW14핀·TW25행결속·보존증거22/
제품3/보호10/Git신원/suffix직접대조PASS. 비저자source50과기계보존을분리했고
TW저자의산문자가승인0·TW품질은m46최종GO의정확cf48응답소유다.

old328batch/alloldaccepted/기존2314UI키각order/value/bytes·JA exact,
신규50accepted/329번째UIbatch1만변경. 기존validate_append4rawinverse와실제Git
first-parent sourceproofPASS·source3339c82ed736e8df7542dd304ef15cf813b6418fa1bdb23f4b1d8e8c5b994405불변.
원official header/semanticreceipt: CN8b30d620802dab7ba24f1c63058d4b7344de88aafbf0c657c2fe2f39fa2dbf6c /
TW9e385b0285a037c3190c8b2aa1d0999757304a620bb3a31d32a571eb19bedf69.
checksum2352ddd70fd6b71e17e080e0afa17cd7282b2104243ffba3915e3818e51be81b.
제품CN206322B/96ef7697d33558e26712ddf4b5f053d0800ea271352c44a4ae8c285f51d91c94,
TW207046B/5c73116ebf7ac5c6a6dcdde0cb5b5ae1b3b12b7e8439dae8b437521d66ef20b5,
원장11837377B/3124ed51b2b62cf7149d98a596afa03ccb3319c75eb4c84c4289d0893fe5a4eb.
officialafter는static밖전체JSONexact·invalidCN70/TW72불변. CJK전체137/70/72·
INCOMPLETE/nativeOPEN·기존target다듬기/수정/수용0. KOEN확정뒤기존stale/invalid
일괄정합과이번신규누락보충을구분한다.

namedlane의612범위밖/explicit병용거부는669원진단을잇고같은실패재실행0.
이번제품3경로explicit선택31은조회만·관련nonengine7만실행, namedlane/전체31/
engine/selftest/새checker·등록/479·481후속/도구수리/전체audit/자연240은0.
자료는 .git/order671-20261015/ 에원export/header/응답/공식receipt/초기반려/
최종보고/actualexitcode/raw/역복원/Gitproof/inventorydelta/root핀으로보존했다.
보호10·KOEN/runtime/조건/저장/project.godot/publicdemo/human/JA 불변.
612dirty4/suffix3555B SHA a9da54e58a91283d1732eae4d0581400cf8dc499274eb1b8aa2ec95c3a7c693b
는모든commit제외/보존. Mac잠금·실제M18/612/BUILD14.3/첫W73 HUD저장HOLD,
새월0/열린실제월1·native/설정0. 실제UI폭·원어민·패드·정상입구·5언어전체/
CI전체녹색/출시HOLD. 개발스킬/I18N직접번역·증분·독립보존적용·일회성/새정본승격0.
