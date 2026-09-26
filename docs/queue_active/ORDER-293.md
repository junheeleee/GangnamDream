#### [~] ORDER-293 — 룰렛 패드 정착 화면의 잔액 하단 잘림 수리

- 착수: 2026-09-27, 부모 ORDER-292/157. 현재 사용자 위임의 확인된 UI 결함 수리이며 새 게임 규칙·외부 출시는 아니다.
- 재현: clean `9c3c01d69e2a549b36b1161494c49a0ec103505d`의 292 첫 CN/TW 실행 모두 15화면 중 `roulette_number_36_xbox`에서 Balance 라벨 y776..798이 scroller y50..790에 8px 잘린다. 원본 `.git/full-game-localization/order292-render-cn-first/`, `order292-render-tw-first/`를 보존한다. 94 raw 입력/지역·현금·저장 보호는 통과했다. 새 번역 회귀·금전 손실로 확대하지 않는다.
- 깊이: 플레이어가 패드 안내가 정착한 뒤에도 잔액을 스크롤 없이 끝까지 읽도록 한다. 기존 글자 크기·버튼·회계·240주 인과는 바꾸지 않는다. 현재 카지노 결정 화면의 compact/no-scroll 정본(CONTROLLER_UX_STRATEGY)을 적용하며 새 규범은 만들지 않는다.

**파일 소유**

- 구현 저자: `scenes/RouletteTable.gd`의 `_content_root` 세로 간격 6→4 한 줄만. 실제 12간격에서 24px 확보를 예상하며 실제 렌더로 확인한다. 다른 runtime·locale·자산·project·공개·인간 자료는 불변이다.
- root: 이 사양/완료 archive293, 292 진행 기록 및 기존 292 문서 소유, 두 큐, CLAUDE 현재 상태 한 줄, WORK_LOG, 생성 STATUS, agent ledger, `docs/agent_reviews/ORDER-293.json`.
- root private: `order293-render.py`, `order293-close.py`, `order293-render-<고유시도>/**`, `order293-closure-<고유시도>/**` (모두 `.git/full-game-localization/` 아래). 기존292 driver/observer/oracle/첫 실패를 덮어쓰지 않는다.
- 비저자: 같은 private 폴더의 `order293-independent-review-first.json` 및 별도 suffix 후속, 292 최종 보고는 기존 소유를 따른다. 구현 저자와 최종 검수자는 분리한다.

**검증과 완료**

- 선언 커밋 뒤 한 줄만 수정한다. 새 driver는 292 driver의 정확한 검사를 재사용하고 runtime drift 예외 대신 원본 Roulette 바이트의 정확한 한 줄 치환 결과와 현재 파일의 일치를 요구한다. frozen oracle·observer는 동일, 변화한 driver/사양도 hash로 묶는다.
- 새 clean source에서 CN/TW 각각 새 namespace·고유 출력 폴더로 기존 15화면/94 raw 전수 재검수. 오류/엄격한 bounds/가시 census 검사를 완화하지 않고 원래 사용자 43파일·현금/AP/serialize/meta/로컬회계·RNG 불변을 유지한다. root와 비저자가 수정 후30 원본 PNG를 직접 본다.
- 초기/메시지/정착 패드 상태를 원본과 대조하고 실제 잔액 하단과 scroller bounds를 기록한다. 기존 판정과 똑같이 DEAL/SPIN/정산·타이/수수료·카지노 진입·물리 패드/원어민/인간 관찰·오디오·패키지는 주장하지 않는다. 결과가 쌓인 history·다른 해상도의 배치는 이번 prebet 모집단 밖이다.
- context/queue/queue-self/human-agent ledger/dashboard·audit_select·diff-check의 표적 게이트. 의미 코드가 변하지 않은 named12/전체 감사를 반복하지 않는다. exact clean source/tree와 변경 전후 증거에 결속한 비저자 GO 후 292/293을 각각 판정·닫는다.
- 공식40177/b132/meta9·held72·공개GO1·인간OPEN45·본편HOLD 불변. 다음은 별도 선언할 카지노 금융/상태 부모18키 CN/TW 번역 후보이며 이번 수리로 확대하지 않는다. 위 작업 지시는 일회성, 기존 정본 적용만 한다.
