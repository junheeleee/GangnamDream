# ORDER-813 — 상철 정선 초대 중국어 정합

#### [x] ORDER-813 · 상철 정선 초대 중국어 정합

부모157/C5. `content/events_{zh-CN,zh-TW}/arc_events.json`의
`arc_sangchul_casino_people.choices[0].result_text`,
`arc_sangchul_casino_cost.description` 각 1값과
`content/meta/full_game_localization.json` 결속만 소유.
누구의 돈이 위험한지와 월세·생활비·아직 일어나지 않은 일에
남겨둘 돈을 구분한다. 실제 손실/송금/수락 발명0·초대 두 경로와
선택/효과/숫자·토큰·JA/KO/EN·저장/공개 데모 불변.
기존4 정정·신규0. 공식 source/이전target·JSON/원장 역복원·독립전독.
실화면/원어민/사람/출시 별도. 일회성.

## 2026-11-07 결과

제품 `4a19aa625bc533716fc0e0778c655ec39c02c7af`, tree
`b9c137b036e257efc712c6e963c5087e51dd8253` 정상 push.
[독립 전수 GO](../agent_reviews/order813-zh-sangchul-invitation.md).
실제로 잃으면 자기 돈이라는 말과 아직 일어나지 않은 일을 위해
남겨둘 돈을 간체·번체에 복원했다. 지출/손실·초대 수락은 발생하지 않는다.
공식 export/check/import2×2 exit0·stderr0·형식 원복·2JSON/원장 역복원,
원402배치/원수용4·원판정371·raw25 보존. 데모5언어/EN/i18n 통과.
lane11은 선택뿐. 실제 화면·원어민·사람·출시 별도.
