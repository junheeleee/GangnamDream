# ORDER-807 — 좁은 방 선택 결과 의미 정합

#### [x] ORDER-807 · 좁은 방 선택 결과 의미 정합

부모157/C5. 착수 — `content/events_{ja,zh-CN,zh-TW}/arc_romance_specials.json`
중 `arc_jiyeon_narrow_room_2.choices[1].result_text`의 짧은 멈춤 3언어와
일본어 `arc_jiyeon_narrow_room_decision.choices[0].result_text`의 포옹 표현,
`content/meta/full_game_localization.json` 결속만. 날 선 대답 예상과
입술 자체 변형을 분리하고, 말없이 안는 행동은 성관계로 오해되지 않게 한다.
후속 truth/silence/결정·각 효과·원문/다른 줄·토큰·언어·데모/저장 불변.
기존4정정·신규0. source/이전target 결속·전체 JSON/원장 역복원·데모/EN·독립4전독.
실화면·원어민·사람·출시 별도. 일회성.

## 2026-11-06 결과

제품 `2440b7e7b377080bd6e8c34aab59715be31f7bd5`, tree
`40598b3b2370f504ec37e58c485192fcf208d15a` 정상 push.
[독립4전독 GO](../agent_reviews/order807-cjk-jiyeon-narrow-results.md).
날 선 대답 직전의 멈춤3·말없는 포옹JA1, 나머지 바이트와 분기/효과 보존.
공식 check/import JA2/CN1/TW1 exit0·stderr0, 3JSON/원장 전체 역복원,
396배치·동일source 원수용4·기존365판정·raw34·비소유15. CN 배열 포맷만 원복.
신규0·데모5언어/EN/i18n 통과, lane11 선택뿐. 실화면/사람/출시 별도.
