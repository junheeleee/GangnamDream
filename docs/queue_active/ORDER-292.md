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
