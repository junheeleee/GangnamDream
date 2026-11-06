# ORDER-810 — 본편 경마 장내 표지 현지화

#### [~] ORDER-810 · 본편 경마 장내 표지 현지화

부모157/C5. `scenes/RaceTrack.gd` 결승선·실시간 순위·사진 판정
세 draw 표지와 `locale/ui_{ja,zh-CN,zh-TW}.json` 각 3키,
`content/meta/full_game_localization.json` 수용만 소유. 본편 기존 경마
도달 경로에서 영어 고정 문자열을 세 locale에만 연결하고 번들 폰트를 쓴다.
KO/EN·공개 데모/기타 locale의 기존 표지와 폰트, 위치·판정·정산·선택/
저장/언어 선택 불변. 공식 신규9 수용·사전/원장 역복원·독립 검수.
격리 엔진 문자열/폰트/보존 확인; 실제 화면·원어민·사람/출시는 별도. 일회성.
