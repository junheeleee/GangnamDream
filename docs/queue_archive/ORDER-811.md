# ORDER-811 — 다은 결혼 견적 원문 정합

#### [x] ORDER-811 · 다은 결혼 견적 원문 정합

부모157/C5. `content/events_{ja,zh-CN,zh-TW}/arc_daeun_married.json`의
`arc_daeun_wedding_prep.description` 견적 및 종잣돈 구간,
`content/meta/full_game_localization.json` 결속만 소유.
예단·예물을 기념품/별도 축의금으로 읽지 않고, 견적 합계가 전세 보증금
규모이며 그 비용이 강남 종잣돈에서 빠진다는 뜻을 유지한다.
숫자·원화/모임5회·선택효과 -800만/-3,100만·두 결과·토큰·나머지/저장·데모 불변.
기존3 정정·신규0. 공식 source/이전target 결속·사전/원장 역복원·독립전독.
실화면/원어민/사람/출시 별도. 일회성.

## 2026-11-07 결과

제품 `6f2ffc14cf307eca29cedb9d09844afc42440343`, tree
`12e1f44c483ddbdf1b06fc62075bb6a8333f0e4c` 정상 push.
[독립 전수 GO](../agent_reviews/order811-cjk-daeun-wedding-estimate.md).
예단·예물 합계 및 종잣돈/전세 보증금 비교 기존3 정합. 견적과
두 실제 차감액을 구분했으며 결과/효과/저장/데모 불변.
공식 export/check/import 1×3 exit0·stderr0, 3JSON/원장 byte 역복원,
원400배치·원수용3·원판정369·raw33·비소유14. 데모5언어/EN/i18n
통과, lane11 선택뿐. 실화면/원어민/사람/출시 별도.
