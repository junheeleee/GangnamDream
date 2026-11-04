# ORDER-789 — 일본어 경마 승식 이름 정정

#### [x] ORDER-789 · 일본어 경마 승식 이름 정정

부모157/C5. 착수 — `locale/ui_ja.json` 연승·복승·삼쌍승 기존 3값과 증분 원장만.
5~7마리 출주·한 마리 2착까지·두 마리 순서 무관·세 마리 순서 일치 규칙에 맞는 명칭.
단승·설명·선택 수·배당·정산·저장·KO/EN/CN/TW·공개 데모는 비소유. 신규 키0.

제품 `c43ef61227c305e7870c24bf68cfd6d1bbdbe5b4`. 연승→複勝, 복승→馬連, 삼쌍승→三連単.
실제 선택·정산과 [일본중앙경마회 용어](https://www.jra.go.jp/kouza/beginner/baken/) 대조.
공식 JA3 check/import·이전값과 원장 바이트 역복원·JA UI·데모·EN 통과.
실화면·Godot 로컬 미실행. [독립 검수](../agent_reviews/order789-ja-race-bets.md).
