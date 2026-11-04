# ORDER-784 — 엔딩 도감 새 발견 표식

#### [x] ORDER-784 · 엔딩 도감 새 발견 표식

부모157/C5. 착수 — `scenes/MainGame.gd::_ending_playstyle`의 새 발견 표식,
`locale/ui_ja.json`, `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json` 각 신규 1키와
증분 수용 원장만 소유한다. 최초 발견 때만 보이던 영어 NEW를 세 언어로 표시한다.
KO/EN·기타 locale 표식, %d 두 값·간격·강조·발견 조건·진행 저장·공개 데모·언어 선택 비소유.

제품 `6261f6c1e08722e87987cf64283f1ca78fb3ee8c`, 원문 소스 `f7a39cfbddbecc514295bf643c2e0a4a993f3baf`.
공식 JA/CN/TW 1키씩 check/import·실제 Git 원장 역복원·JA UI·공개 데모·EN 통과.
처음 헤더 누락 거절3 및 선언 revision 검사 전용3은 수용과 분리해 보존했다.
실화면·Godot 로컬 미실행. [독립 검수](../agent_reviews/order784-ending-discovery.md).
