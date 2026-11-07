# ORDER-816 — 본편 룰렛 상태 표시 현지화

#### [~] ORDER-816 · 본편 룰렛 상태 표시 현지화

부모157/C5. `scenes/RouletteTable.gd`의 상단 상태 배지 및 오른쪽
결과판(회전·접수 마감·접수 가능·결과·직전 당첨 번호·당첨 번호),
`locale/ui_{ja,zh-CN,zh-TW}.json` 각 6키와
`content/meta/full_game_localization.json` 수용만 소유.
같은 상태가 두 표시에서 한 의미로 읽히며 0번과 결과 없음은 구분한다.
KO/EN·데모·기타 locale·숫자·스핀/정산·기존 왼쪽/딜러 표면·저장 불변.
공식 source/이전target 결속, 사전/원장 역복원, 격리 엔진의 상태/글리프/폭,
독립 전수 검수. 실화면·원어민·사람·출시는 별도. 일회성.
