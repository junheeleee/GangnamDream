# ORDER-806 — 지연의 문 앞 CJK 시선 정합

#### [x] ORDER-806 · 지연의 문 앞 CJK 시선 정합

부모157/C5. 착수 — `content/events_{ja,zh-CN,zh-TW}/arc_romance_specials.json`의
`arc_jiyeon_narrow_room_1` 기본 설명·`description_if_known.arc_y3_jiyeon_departure_seen`
각 마지막 문장 및 `content/meta/full_game_localization.json`의 해당 결속만.
문 앞에서 처음 낮아진 태도를 자세를 낮추는 동작과 분리하고, 부산/막차는
기존 variant에만 둔다. 4년차 좁은 방 진입·도감·실제 known 선택을 확인한다.
KR2×3 기존6 정정, 신규0. 앞 문장·토큰·제목·선택·효과·다른 서사/저장/데모 불변.
공식 source/이전target 결속·JSON/원장 역복원·데모/EN·독립6전독.
실화면/사람/출시 별도. 일회성.

## 2026-11-06 결과

제품 `e21c460e2422fc391322e8476f0934a0fb678b6b`, tree
`84511a1af0b344516a7a874f500b4e669dc6d1ad` 정상 push.
[독립6전독 GO](../agent_reviews/order806-cjk-jiyeon-threshold.md).
기본/부산 기억 각 3언어 마지막 문장만 태도 변화로 정합. 신규0.
공식 check/import2×3 exit0·stderr0·3JSON/원장 byte 역복원, 원395배치·
동일source 원수용6·기존364판정·raw33·비소유15. CN 배열 포맷만 원복.
실제 live/replay 조건·데모5언어/EN/i18n 통과, lane11 선택뿐.
실화면·원어민·사람·CI 완료·출시와 별개.
