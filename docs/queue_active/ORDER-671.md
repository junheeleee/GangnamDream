# ORDER-671 — 대출·주거·물품 UI 중국어 실제 누락 25키

#### [~] ORDER-671 [현지화] CN/TW 신규50잎 — 2026-10-15

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
