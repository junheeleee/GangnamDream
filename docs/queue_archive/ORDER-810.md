# ORDER-810 — 본편 경마 장내 표지 현지화

#### [x] ORDER-810 · 본편 경마 장내 표지 현지화

부모157/C5. `scenes/RaceTrack.gd` 결승선·실시간 순위·사진 판정
세 draw 표지와 `locale/ui_{ja,zh-CN,zh-TW}.json` 각 3키,
`content/meta/full_game_localization.json` 수용만 소유. 본편 기존 경마
도달 경로에서 영어 고정 문자열을 세 locale에만 연결하고 번들 폰트를 쓴다.
KO/EN·공개 데모/기타 locale의 기존 표지와 폰트, 위치·판정·정산·선택/
저장/언어 선택 불변. 공식 신규9 수용·사전/원장 역복원·독립 검수.
격리 엔진 문자열/폰트/보존 확인; 실제 화면·원어민·사람/출시는 별도. 일회성.

## 2026-11-06 결과

제품 `bdfce09e7a077f53d50b1ff4a8a3e2e2a899e9d1`, tree
`074bfcb06660184fc39e3257c67f000681f1afd3`, 한국어 source
`9b570d51d7cd1e3f007858a6d0451d6f9751df6a` 정상 push.
[독립 전수 GO](../agent_reviews/order810-cjk-race-canvas.md).
실제 draw3 신규 UI9, bound export/check/import 3×3 exit0·stderr0,
선언 revision export3은 미수용 보존. 소스/사전3/원장 byte 역복원,
원399배치/368판정·raw49·비소유14 보존. 격리 엔진 본편 표시9·
보존9·글리프37/폭 통과, 데모 플래그 보존18·경제상태 불변.
JA UI/데모5언어/EN/i18n 통과, 제품 CI42230091937 시작.
실화면·공개 데모 패키지 실행·원어민·사람·출시 미관측.
