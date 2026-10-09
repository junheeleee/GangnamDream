# ORDER-507 — 중국어 투자 거래·예측 UI17키

#### [x] ORDER-507 [전체 현지화] CN/TW 기존 UI34값 — 2026-10-09

착수 — 만지는 파일: locale/ui_zh-CN.json·ui_zh-TW.json 신규17키씩,
content/meta/full_game_localization.json 해당34영수증·배치1. 운영 파일은
큐/L3 이어보기·본 사양/완료archive·WORK_LOG·CLAUDE 마지막 갱신·생성STATUS만.
게임원문·조건·효과·경제/저장/runtime·기존 번역·JA·도구는 비소유다.

## 판정 단위 / 깊이3문

- 지우면: 일반/레버리지 거래의 실패 이유·거래 기록과 시장 예측이 영어로 남는다.
- 독자: InvestmentSystem.buy_asset/sell_asset/buy_asset_leveraged 반환 message →
  MainGame._on_buy_asset/_on_sell_asset/_on_leverage_buy 토스트,
  거래 add_log → GameState 기록, get_market_forecast → _ap_market_analysis다.
- 경쟁: 투자 기능이나 예측을 새로 만들지 않는다. 기존 소비자의 중국어 폴백만 채운다.

## 정확 선택 — 공식17 한 배치

기준Git34f645c29003871cef54566f89848809f5c71fdc,
source manifest f971c7193ba3a68299e166f2734f507f577001bc1ecc83cc940551abd038fb85.
현 collector의 systems/InvestmentSystem.gd 정적25키 중 CN/TW 모두 미존재17키만.
모두 JA존재·public-demo protected=false·builtin_overlay_static_only다.
공식 leaf ID17은 export 전 별도 private 선택 파일로 고정하고 source batch에 결속한다.

실패 이유8(존재하지 않는 자산 2형·잔액 2형·가격 2형·미보유·최소투자),
일반 매수완료1·일반 매수/매도 및 레버리지 기록3·시장예측5다.
원화 금액·토큰·순서·불확실성 유지. 레버리지 기록은 투입현금과 두 배 포지션을
구분하며 예측을 보장으로 바꾸지 않는다. source 자체나 공유된 기존8키는 변경하지 않는다.

## 실행 / 검증 / 증거 경계

선언commit/push 후 공식 export/check/import17씩. CN/TW저자는 KO 직접
private response 각1파일만 소유하며 서로 변환하지 않는다. root는 원공식receipt
header/SHA2·source/target34를 기존 원장에 결속한다. 비저자는 KO17/실제소비자/
번역34·원영수증·기존4파일 raw 역상·actual Git source를 전수 검수한다.
기존 ui_translation_append와 EN/Hangul·JA UI·ZH·i18n·multilingual·공개/legacy
demo 영향8검사만. 전체 local audit/240주·새 검사/이력/계측/재사용 도구·형식보고0.

Mac잠금으로 실제폭/입력 미관찰·원어민/물리패드 OPEN·본편출시 HOLD다.
project.godot·사용자 저장·shipping language·공개M01~M06·역사 인간판정 불변.
개발 스킬의 선선언·현지화 프로필·독립 지역 저작/비저자 검수·표적검사를 적용한다.
새규범0·범위/절차는 일회성이다. 자동PASS는 재미·원어민/사람GO가 아니다.

## 수용 결과 — 정적 거래 소비자 번역 한정 GO

선언acb5d4ace8eff6cb2066aa64948882c0c8e84131 →
제품d855006bf81e1d5d47ded2db94ac01f7c36ea4ce main commit/push.
KO17·CN/TW34값 지역별 직접 병렬 저작·비저자 전수검수 GO·retouch0이다.
선정17키는 producer 호출17회다. 실패8/거래로그3/예측5의16키는 실제 reader가 있으며,
매수완료1은 성공반환만 있고 MainGame이 별도toast를 써 packaged 수용만 세었다.
일반 매수액=투입현금, 매도=정산대금/부호손익, 레버리지 투입금과 두 배 포지션,
성장주와 예상/권장/주의의 불확실성·원화·토큰순서를 보존했다.

공식export/check/import17씩·원header/SHA2·current source/target34·기존4파일raw 역상PASS.
원receipt CN6107f76aa718067ce60b07b93c1ea22fbb4b707bce12447d28d9b117f6d5e129,
TW768b66ee4155f8923bae106a3ab438f7d0fea541ddf7dda845990861e82af670.
accepted42411→42445/batches301→302/UI2087→2104씩·JA3055불변,
CN/TW legacy1862→1879/2952/context29/29/dynamic150/701·전체INCOMPLETE다.
역사 header/영수증·기존8키·runtime/경제/저장/공개M01~M06/project 불변이다.

비저자 phone_independent_review actual Git current_proof(base34f645c→d855006)
제품전이1·34receipt·배치1·선언acb5d4a/current source manifest f971c719… 일치GO다.
KO17/실제독자/34번역/공식header·receipt·기존raw 모두 직접 읽었고 blocking0이다.
EN/Hangul·JA UI·ZH·i18n·multilingual·공개storydemo·legacy demo 영향8검사 PASS.
선언의 새사양 끝 빈줄1을 비저자가 baseline diff-check에서 발견했다.
제품diff는PASS였으나 전체PASS로 확대하지 않았고 이 archive 전환에서 빈줄을 제거했다.

개발 스킬의 선선언·독립 지역 저작/비저자 검수·기존 원장·표적검증 적용.
새규범0/일회성·새 검사/이력/계측/재사용 도구·형식보고0이다.
직전25c2cc39 CI37916871377 녹색 확인·최신main CI대기,
실제폭/입력/청취·원어민/물리패드 OPEN·전체번역 INCOMPLETE·출시HOLD다.
