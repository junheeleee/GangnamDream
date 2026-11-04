# ORDER-783 — 일본어 경마 마장 양호 정정

#### [x] ORDER-783 · 일본어 마장 양호 정정

부모157/C5. `locale/ui_ja.json` 기존 양호 한 키와 같은 수용 원장만.
HorseWorld/HorseRace의 마장 상태·RaceTrack 헤더/선호 조회에 쓰이는
‘양호’를 마구간 의미에서 바로잡는다. 마장 인덱스와 배당/레이스/저장,
건조·다습 및 KO/EN/CN/TW·공개 데모·표시 코드 비소유. 기존값 대체, 신규 커버리지0.

제품 `ba20b052f6b133b2a8efd340777ee5fe636aedc3`. `馬房` → `良好`.
공식 JA check/import, 1값·원장 역복원, JA UI·데모·EN 통과. 기존 JA 값의
첫 원문 결속 수용(신규 키0). 기존 저장 불변, 이후 JA 경주 기록에는 정정 표시가 남을 수 있다.
제품 CI41872553769 진행 중. 실화면·Godot 로컬 미실행.
[독립 검수](../agent_reviews/order783-track-condition-ja.md).
