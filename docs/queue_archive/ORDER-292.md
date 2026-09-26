# ORDER-292 — 바카라·룰렛 중국어 베팅 전 화면·입력 검수

[x] 2026-09-27. 비저자 작업 한정 GO, 필수 결함0. 전체판 출시는 HOLD다.

- source `f2882004463f33779a260dbbf6b7e8420ab3678d`, tree `ea55442b56d550613489b1a90a25655349f1eb1d`. [독립 보고](../agent_reviews/ORDER-292.json) SHA `ae85709a3d53b217ae9dd7d5c0d12e498a43173a0f053908f1634eb36f688025`. 실제 후속 엔진 source는 `af24a3829b6d409a5c0f9dd281aedb465349a105`; 이후 제품 차이는 CLAUDE 현재 상태 한 줄뿐이며 런타임 identity는 일치한다.
- ORDER-291의 기존22 KO키/CN·TW44값을 재수용하지 않고 실제 준비 상태에서 읽었다. 바카라 P/B/T/PP/BP 합계166만원, 룰렛 모드·숫자0/36·색/범위·dozen·clear·전제조건 안내를 고정 oracle과 대조했다.
- 초기 준비 뒤 raw 키/버튼 press-release와 trigger .56/.90/.40/.34/.56/.34를 실제 입력 경로로 보냈다. 좌우0↔36, 단일 trigger edge/재해제, 베팅 교체, clear→exit를 확인했다. 직접 semantic handler/포커스 강제 변경은 없다. .55/.35 정확한 경계 동등성은 미검사다.
- canvas 선택명은 실제 SC/TC regular font28, 자연 shape width/vertical/glyph, 218px draw폭 및 ancestor clip을 별도로 확인했다. 명시 음수 숫자 fixture는 정상 경로 도달 증거가 아니다.
- 첫 source9c3c01d CN/TW 각15화면 중14PASS/1FAIL: 정착 Xbox 숫자36의 기존 잔액 하단 잘림 하나를 두 지역에서 확인했다. 첫3로그·JSON·30PNG를 보존했다. ORDER-293 수리 뒤 동일15×2=30화면·94×2=188raw 입력 PASS/exit0/오류0, root와 비저자가 후속 원본30PNG 전부를 직접 관찰했다. 서로 다른 두 오더의 새60개 성공 사례로 중복 계산하지 않는다.
- 준비 현금1000만원과 모든 raw/capture에서 cash·AP·serialize·meta/settings·로컬 round/net/commission/RNG/history 보호가 유지됐다. 실제 사용자43파일은 전4실행 전체에서 byte동일. 매 실행 새 pre-autoload namespace,3raw로그·완료/부팅 marker·teardown을 확인했다.
- 도달 경로: 준비 Baccarat/Roulette 컴포넌트의 실제 raw 입력과 GUI 렌더. 생산자↔독자: 기존 locale44값→Table label/RichText/custom canvas. 상태: 준비→선택/금액→clear→exit, 정산0. 제거 손실: 중국어 안내의 의미/입력 결속 및 잔액 가독성. 계층/서사: 기존 카지노 표면, 신규 장면·240주 경제 변경0.
- 공식40177/b132/meta9·보류72·두 사전각1004값·JA/KO/EN·수용 영수증·project·공개·인간 원형 불변. 자동 게이트는 계약 증거이지 재미·깊이·문체 또는 인간 판단의 대체가 아니다.
- 검사 선택기를 `--list` 없이 잘못 호출해 정적6종 완료 뒤 자체검사 도중 중단했다(exit130). 선택26종 전체 PASS나 추가 엔진 검증은 아니다. private `order293-closure-selection-first/dispatch-note.json`에 경위를 남기고 이후 목록 선택은 `--list`만 사용한다.
- 이 한정 GO는 카지노 진입/open/tutorial, DEAL/SPIN/배당·정산, history가 쌓인 화면, 다른 해상도/언어, 원어민/인간/물리 패드 감촉/청취/패키지를 관측했다고 하지 않는다. 직접영어·금융/결과 부모가 남아 전체판 번역 INCOMPLETE, 공개GO1·인간OPEN45·본편HOLD 유지.
- 다음은 별도 선언할 카지노 금액·수령·미납 수수료·손익 부모18키/CN·TW36값 후보다. 공유 잔액 소비자 JeongseonCasino를 포함하며 raw player/banker/tie 로그·Odd/Even 공유 부모·직접영어는 제외한다. 읽기전용 후보이며 아직 번역·수용하지 않았다.
- 규범 판정: 이번 모집단/도구/소유는 일회성. UI_ART_DIRECTION·CONTROLLER_UX_STRATEGY·WORK_UNIT 기존 정본 적용이며 새 지속 규범 승격 없음.

## 착수 및 첫 발견 원문

#### [~] ORDER-292 — 바카라·룰렛 중국어 베팅 전 화면과 실제 입력 검수

- 착수: 2026-09-27, 부모 ORDER-157. 사용자 ‘순서대로 진행해’와 WORK_UNIT 위임에 따른 내부 QA 단위다.
- 기준: clean `c0e084be95f870b83b5aa40cdfcb8034dee2b0f3`; ORDER-291의 22 KO key×2지역=44 수용값, 누적 40177/132, held72 불변. 사전 계획 `.git/full-game-localization/order291-next-render-scope.json` SHA256 `64f2c3096d9bc28558d1bdbbf02546d70920f854b12fd3dffd18061ab692264c`를 source 재결속한다.
- 깊이: 실제로 번역된 베팅 안내가 보이는가, 키보드·합성 raw pad 입력이 그 안내와 같은 대상만 움직이는가, 취소가 현금·라운드·저장·기록을 보존하는가를 판정한다. 한 해/다섯 해의 경제·서사 규칙은 바꾸지 않는다.

**착수 — 만지는 파일 및 소유**

- root: 이 사양 및 완료 시 `docs/queue_archive/ORDER-292.md`, `docs/CODEX_QUEUE.md`, `docs/CODEX_QUEUE_L3_PENDING.md`, `CLAUDE.md` 현재 상태 한 줄, `docs/WORK_LOG.md`, 생성 전용 `docs/STATUS.md`, `docs/agent_review_decisions.json`, `docs/agent_reviews/ORDER-292.json`.
- root private: `.git/full-game-localization/order292-render.py`, `order292-oracle.json`, `order292-close.py`, `order292-render-<지역>-<고유시도>/**`, `order292-closure-<고유시도>/**`. 재시도는 첫 증거를 덮어쓰지 않는다.
- 관찰기 저자: `.git/full-game-localization/order292-prebet-observer.gd`, `order292-prebet-observer.tscn`만. 게임 실행은 root가 직렬 소유한다.
- 비저자 검수: `.git/full-game-localization/order292-independent-review-first.json`, 필요 시 별도 suffix 후속 보고서. 보조 읽기 전용 검수자는 `order292-preflight-review-first.json`만 쓴다.
- 제품 코드·KO/EN/JA·locale/수용 영수증·공개 M01–M06·project.godot·기존 사람 판정·font/art/audio는 변경하지 않는다. 실제 제품 결함은 별도 오더로 선언 후 수정한다.

**한정 실행·증거**

- zh-CN/TW 각 1280×800 실제 graphical Godot 실행 1회씩, locale별 새 pre-autoload 격리 namespace. 원래 사용자 파일 43개의 전후 hash와 전체 관련 제품·oracle·관찰기 pin을 대조한다. DummyAudio; title/casino ingress 및 물리 패드는 이번 증거가 아니다.
- 각 15캡처: baccarat_mixed_pending, baccarat_cleared; roulette_initial, roulette_missing_type, roulette_number_zero, roulette_number_36_xbox, roulette_red, roulette_black, roulette_low, roulette_high, roulette_dozen3, roulette_dozen2, roulette_dozen1, roulette_cleared, roulette_missing_number_defensive. 마지막 하나는 정상 도달이 아닌 명시적 방어 상태 준비다.
- raw key/button/motion press/release를 Input.parse_input_event로 전달한다. 직접 semantic handler·pressed.emit·포커스 강제 변경은 금지. 각 입력의 실제 focus owner와 typed before/after, trigger .55/.35 단일 edge, 0↔36 cursor, 베팅 교체와 clear→exit를 검증한다. DEAL/SPIN·정산은 실행하지 않는다.
- 독립 고정 oracle로 정확한 가시 문자열, P/B/T/PP/BP 합계166만원, 단위·range·keycap을 대조한다. RichText 실제 content/ancestor bounds와 canvas 숫자/외부 선택의 font28·218px shape/vertical/glyph/bounds를 측정한다. root와 비저자가 30개 원본 PNG 전부를 직접 본다.
- 준비 현금1000만원은 fixture이며 매 raw 입력/캡처에서 현금·AP·serialize·meta/settings·격리 저장과 로컬 round/net/commission/RNG/history 불변을 검사한다. 입력 허용 변경은 pending bet/stake/cursor/mode/feedback/visibility뿐이다.
- stdout/stderr/Godot log 3종, 정확한 완료·pre/post bootstrap marker, 정상 종료·teardown·원본 저장 무변경을 함께 요구한다. 오류가 있는데 늦은 OK/exit0인 경우 FAIL이다.
- 표적 context/queue/queue-self/agent·human ledger/dashboard, audit_select, diff-check만 실행한다. 291의 named12·전체 감사·240주·이미 완료한 블랙잭 검사를 반복하지 않는다.

**완료 판정**

- 비저자가 exact clean source/tree와 helper/oracle/output hash에 결속한 내부 GO 또는 재현 가능한 결함을 남긴다. 중간 실패는 보존한다. 이 단위에서 44개의 번역을 재수용하거나 수용 개수를 늘리지 않는다.
- 전수 30프레임이 성공해도 다른 영문 UI, 전체판 현지화 INCOMPLETE, 원어민·물리 패드·정상 속도 이야기 관찰 OPEN, 본편/외부 출시 HOLD를 유지한다.
- 위 실행·소유 규범은 이 단위의 일회성이다. 지속 규칙은 WORK_UNIT·UI_ART_DIRECTION·CONTROLLER_UX_STRATEGY·INPUT_MATRIX·QA_CHECKLIST에 이미 있다.

**첫 실행 발견 — 2026-09-27**

- clean `9c3c01d`에서 CN/TW 첫 각15화면·94 raw를 실행했다. 두 지역 모두 정착 Xbox 숫자36 화면의 기존 잔액 라벨 하단8px 잘림으로 FAIL, 나머지14상태는 통과. 원본3로그·JSON·PNG와 사용자43파일 무변경 증거를 보존한다. 화면 GO로 승격하지 않는다.
- 비저자 두 명이 원본 PNG/코드로 실제 가독성 결함을 확인했다. 번역·회계 결함이 아니며 상단 현금·핵심 조작은 가시다. 별도 ORDER-293 한 줄 간격 수리를 먼저 수행하고 새 source에서 동일 엄격 모집단으로 292를 재판정한다. 원래292 관찰기·oracle·driver는 동결하고 새 실행 driver는293이 소유한다.
