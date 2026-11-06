# ORDER-809 — 다은 고향 식탁 중국어 정합

#### [x] ORDER-809 · 다은 고향 식탁 중국어 정합

부모157/C5. `content/events_zh-{CN,TW}/arc_romance_specials.json`의
`arc_daeun_hometown_table_hands.description` 각 1값과 간체
`arc_daeun_hometown_table_decision.description`, `choices[0].text`,
`content/meta/full_game_localization.json` 결속만 소유.
다은의 과거와 체하면 묵어도 된다는 애매한 환대, 빈 그릇을 기다리는
행동과 ‘잘 먹겠습니다’를 한국어에서 각 지역에 정합한다.
이전 진료/생사·초대 확정/숙박 결과 발명0·후속/타언어/효과·저장·공개 데모 불변.
기존4 정정/신규0. 공식 source/이전target 결속·JSON/원장 역복원·데모/EN·독립전독.
실화면/원어민/사람/출시 별도. 일회성.

## 2026-11-06 결과

제품 `d93691d45d00ee9cba0241d33585f7070efca6dc`, tree
`7a3bacd14276e2bb3b905dcf2464b692ab2b6b0e` 정상 push.
[독립 전독 GO](../agent_reviews/order809-zh-daeun-hometown-table.md).
두 중국어에서 다은의 과거·체할 때의 조건부 환대, 간체의 기다림·식사
인사까지 기존4 정정, 신규0. 다른 줄·선택결과·생사·후속/효과 불변.
초기 줄목록 export 거절은 보존하고 같은 ID의 JSON 배열로 최종
export/check/import CN3/TW1 exit0·stderr0. 원398배치·원수용4/JSON2·
원장 byte 역복원, raw30·비소유15·원판정367 보존. 데모5언어/EN/i18n
통과, lane11은 선택뿐. 화면/원어민/사람/출시 별도.
