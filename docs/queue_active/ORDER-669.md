# ORDER-669 — 거래 화면 중국어 실제 누락 19키

#### [~] ORDER-669 [현지화] CN/TW 신규38잎만 — 2026-10-15

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
