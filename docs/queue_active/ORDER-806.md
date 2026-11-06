# ORDER-806 — 지연의 문 앞 CJK 시선 정합

#### [~] ORDER-806 · 지연의 문 앞 CJK 시선 정합

부모157/C5. 착수 — `content/events_{ja,zh-CN,zh-TW}/arc_romance_specials.json`의
`arc_jiyeon_narrow_room_1` 기본 설명·`description_if_known.arc_y3_jiyeon_departure_seen`
각 마지막 문장 및 `content/meta/full_game_localization.json`의 해당 결속만.
문 앞에서 처음 낮아진 태도를 자세를 낮추는 동작과 분리하고, 부산/막차는
기존 variant에만 둔다. 4년차 좁은 방 진입·도감·실제 known 선택을 확인한다.
KR2×3 기존6 정정, 신규0. 앞 문장·토큰·제목·선택·효과·다른 서사/저장/데모 불변.
공식 source/이전target 결속·JSON/원장 역복원·데모/EN·독립6전독.
실화면/사람/출시 별도. 일회성.
