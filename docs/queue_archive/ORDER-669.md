# ORDER-669 — 거래 화면 중국어 실제 누락 19키

#### [x] ORDER-669 [현지화] CN/TW 신규38잎만 — 2026-10-15

기준 main0c40b0d662335b58278a7bea76e0f8b1f3cdf26e. ORDER-157의
전체판 누락 보충을 잇는다. KOEN 확정 전 JA/zh 다듬기는 중단한다는 최신
사용자 지시를 적용하며, 기존target이 없는 CN/TW19키씩만 채운다.

## 깊이·분모·소유

1. 누락을 두면 기존 TradingFloor의 거래/차트/HUD가 CN/TW에서 영어fallback이다.
2. TradingFloor._tr:53 → LocaleManager.ui:212/lookup:475 → 기존 UI 사전.
   소비 call sites:125/188/272–299/373–407/490–529/573/698.
   게임의 현재 정상 FullStoryFlow에서 이 화면의 입구·실제19상태 관찰은
   별도이며, 이번 사전 보충을 신규 경로/정상플레이 증거로 만들지 않는다.
3. 선택/24주상태/경제/저장은 불변. 기존 매수·매도 경쟁, AP1/MA5·5개월/
   MA20·20개월, 원화·수익률·BBCode·printf순서를 그대로 직접 번역한다.
   source19·JA기존19·CN/TW없음19·supported/unprotected를 실측했다.

정확19 source/ID/context는 새 .git/order669-20261015/population.json에 봉인한다.
거래 HUD·보유·매수/매도·시장국면·시간부족·가격없음·수량없음·평단·차트안내·
닫기19이며, source의 총자산은 기존 사전 용어 总资产/總資產로 유지한다.

root: locale/ui_zh-CN.json·locale/ui_zh-TW.json에 신규19키씩만 공식 import,
content/meta/full_game_localization.json accepted38/checksum/새 UI batch1만.
root: 큐2/이 사양/archive/CLAUDE현재행/WORK_LOG/새 private 실행자료.
m46_48_fact_read: 새 private cn.response.jsonl만 KO직접저작; 비저자TW19
검수 보고만. a1_qa_release_audit: 새 private tw.response.jsonl만 KO직접저작;
비저자CN19/제품4스냅샷append보존 보고만.
두 저자의 소유 파일을 분리하고 상대언어 초안을 보지 않고 독립 저작한다.
root는38원문/대상 전수 직접검토·증거핀 확인을 한다.

KO/EN/runtime/JA/기존CN·TW키/정본/조건/게임플레이/retail언어설정/저장/
project.godot/공개데모/과거human·raw/앱/seed는 비소유다.
Mac잠금·같은M18/612/BUILD14.3 HOLD·새월0·열린실제월1.

## 순서·검증·완료 경계

선언commit/push → before4 및보호핀 봉인 → exact19 fresh 공식export×2 →
KO직접 CN/TW독립초안 → 비저자각19전수/고유기호·돈·시간·의미검수 →
공식 check/import --accept×2 (--replace-existing 금지) →
원official header/digest를 보존한 원장append → 기존validate_append/history·
표적/비저자보존 → 제품commit/tree·최종핀 → 마감commit/push·CI한번확인.
원326batch/oldaccepted/기존사전keys/order/bytes·JA는 exact이며
추가분을 역으로 제거하면 기준4파일 전체바이트가 복원돼야 한다.

named full-game-localization-overlays 차선을 explicit 소유제품3경로로
--list 후 실행한다. inherited612 범위가 섞여 lane거부면 숨기지 않고 원자료를
보존하며 같은 제품 explicit selection으로 적용한다.
CN/TW 공식 after inventory2·ZH all·JA UI·i18n·demo scope all·story demo,
context/queue/diff와 기존 UI append proof를 쓴다. 변경없는 checker selftest
개별반복0·새checker/등록/479·481후속/engine/전체audit/자연240/실제화면0.
누락감소19/locale만완료로세며 기존invalid137/70/72·기존stale의다듬기/
수용0·전체 INCOMPLETE/native/rendered OPEN을 유지한다.

612dirty4/WORK_LOG3555B suffix
a9da54e58a91283d1732eae4d0581400cf8dc499274eb1b8aa2ec95c3a7c693b는
보존/모든commit제외. 신규UI수용은전부machine/source한정이며실제렌더/
원어민/패드/실제월/5언어전체/출시GO는아니다. 일회성배치/새정본승격0.
gangnamdream-dev/I18N의 직접번역·증분·증거경계를 적용한다.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.

## 마감 — 2026-10-15

선언e4db61770d7cf7d88091120fae52e129da572ac5 →
제품986a36bb6679fead87a1f62609583cb2c85434c2 /
tree527d6d30529a0b3f8f6f9c3d2f9ddf57438751a6.
CN/TW 신규19각각38 directKO 독립저작/상호비저자전수sourceGO만수용했다.

| 완료 증거 | 측정값 또는 file:line |
|---|---|
| 도달 경로 | TradingFloor:53→LocaleManager:212/475 · 정상FullStoryFlow입구/실제19상태관찰0 |
| 생산자 ↔ 독자 | TradingFloor:125/188/272–299/373–407/490–529/573/698 ↔ UI CN/TW새19키 ↔ 원장batch327 |
| 바꾸는 상태 | locale당static2066→2085/2980·missing914→895·current1986→2005; accepted14809→14828·JA13173불변 |
| 포기 시 잃는 것 | 거래HUD/보유시가/매수매도/시장/시간/AP1/MA5·MA20/차트19키의CN/TW직접번역 |
| 서사 위치 | 기존거래UI·후일담/신규장면/선택/경제/주차0 |
| 장면 계층 | 기존UI누락번역·신규T1/T2/T3/자산/연출0 |
| 닫는 것 | 공식check/import2각0·표적7actual0·원장append/Gitproof·독립38source/보존GO; 렌더/native/5언어전체/출시GO0 |

원초안의 K차트 영어토큰이 공식check에서양쪽exit1이었다.
초기CN/TW19전체REWORK/수용0·원응답/초기보고/실패raw보존.
직접중국어candlestick명칭 蜡烛图/蠟燭圖로두차트행을수리해다른차트로바꾸지않았다.
닫기visible=false/closed.emit를자동다음달이동으로읽히지않게두행동으로분리했다.
CN은보유시가/시간1어순/MA5·MA20병렬까지4행, TW3행만수리·원19전체각재검수.
원화금액·매도대금/손익분리·printf/BBCode/MA5=5개월·MA20=20개월·AP1보존.

CN final report md4692B/2b16f97952546b4e7e83c91ac65a41fd91fd4f8b47c5f4061dec122200ff1b95,
json5776B/39ee96c84ff0a5d0633ddc89429ab79e5ae30399da2f3d5b61c891fa91c8b189.
TW final md4393B/d1e3decc43175add107890fdf542c8bf814fdaa521c6c598215648c1eb6c3b0c,
json5056B/f435a9c4d2d7669f3e6361421b7a1f090a98419c66d953785511bdd664705177.
보존 md4903B/82b96462217a76c7769961046fa806727bd186a1dc8b409512c88304a9d210f2,
json9619B/60e2ee9d8cf6e57854642241927ccc448f74476b0dfda89b219292b4d74a9a32.
root최종보고6전문·CN9/TW5/보존35핀직접대조PASS·초기38+최종7수정행읽음.
TW저자의보존판정은기계append/비소유만이며산문자가승인0·TW품질은비저자보고소유.

old326batch/oldaccepted전량/사전기존2270키각각/order/bytes·JA exact,
제품3경로/새38 accepted/327번째batch1만변경. 4파일rawinverse·실제Git일차부모
source_manifest proof PASS·manifest3339c82ed736e8df7542dd304ef15cf813b6418fa1bdb23f4b1d8e8c5b994405불변.
원official header/digest보존: CN13dbab2661432768036211cb0e79b40d39c5df6a2a736b6a9627ce76dbfb7dc9 /
TWc6076dc14c90b8ff39830c5d60e94023bf25a5db1670c8f2e140976eb189a3fe.
checksum691aed7540a05c9879b15f38aac39d86373abe1edca04d86d1ceb034acb9025a.
CN/TW afterinventory는ui_static_context밖전체JSONexact·invalid70/72불변,
전체CJK137/70/72·INCOMPLETE/nativeOPEN·기존target다듬기/수정/수용0.
신규19수용과기존stale/invalid의일괄정합을구분한다.

named lane은612untracked가범위밖이라거부됐고, CLI는lane+explicitfiles병행도거부했다.
원진단보존·612숨김/도구변경0·explicit제품3경로selection31은조회만,
관련nonengine표적7을수동실행했다. namedlane실행/전체31실행으로세지않는다.
root진단의TW보고스키마추정KeyError/오케스트레이션parse실패는쓰기전0으로
교정했다. 새helper/checker/selftest/등록·479/481후속/engine/전체audit/자연240/설정0.

KOEN/runtime/조건/저장/project.godot/publicdemo/human/JA 불변.
612dirty4/suffix3555B SHAexact는모든commit제외·보존. Mac잠금사용자확인·
실제M18/612/BUILD14.3/첫W73 HUD저장 HOLD·새월0/열린실제월1.
실제UI폭/서체/원어민/패드/정상FullStoryFlow입구/5언어전체/CI전체녹색/출시HOLD.
개발스킬/I18N직접번역·증분·보존 적용·일회성배치/새정본승격0.
