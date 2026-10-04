# ORDER-438 — 홀덤의 행동 중복과 이전 타이머 재진입을 막는다

#### [x] ORDER-438 [P1·입력] 비동기 행동 소유권·종료 무효화

**[x] 완료 — 2026-10-04.** 437 실제 trace에서 마지막 AI가 인덱스를 넘긴 뒤
0.6초 기다리는 동안 waiting=true가 되는 구간을 확인했다. 소스의 두 await는
Leave/RESULT/재진입 뒤에도 무조건 렌더·진행한다. 사용자 계속 개발·main 커밋 위임의 기존 결함 수리다.

## 범위·소유

- root: `scenes/HoldemClub.gd`, `tools/ui_translation_append.py` EOF, 새 private438 normal,
  CLAUDE·큐/L3·사양/보관본·WORK_LOG(원문 history 이동 포함)·생성STATUS·agent 보고/판정.
- claude_handoff_review: `tools/holdem_money_history.py` EOF 전이 증명과
  신규 `tools/holdem_async_receipt_check.py`. 기존 proof·pin·focused·원본 증거는 불변.
- receipt_tests392: `tools/audit_scope.json` 명시 `holdem-async` 차선,
  새 private438 Python/GD/scene 격리 helper만. 독립 입력/복원 기대를 저작한다.
- independent392: 비저자 제품·helper·실제 화면/입력·증거 최종검수. 실행은 root만.
- 기존 금액/블라인드/AI 전략/덱/승패/정산 산식·Main/GameState·AP/저장·번역/폰트/공개데모 불변.
  busy와 세대 번호는 transient 상태이며 세이브 스키마에 넣지 않는다.

## 구현 계약

- 행동 진행 중에는 대기 판정과 플레이어 공통 실행 입구 모두 추가 확정을 거부한다.
  AI도 동일 소유권을 잡고, 단계 dispatcher는 숨김/종료/진행 중 상태를 진행하지 않는다.
- 두 타이머는 시작 세대 번호를 보관한다. 재개 시 같은 세대·visible·베팅 단계일 때만
  자기 busy를 해제하고 기존 렌더/진행을 잇는다. 이전 세대는 새 busy에 손대지 않는다.
- open/새 손/SHOWDOWN/RESULT/close 경계는 세대를 단조 증가시켜 이전 행동을 무효화한다.
  busy 중 Leave는 허용하되 RESULT 중복 정산·종료 뒤 deal·중복 close를 막는다.
- UI 호출이 없는 시작/AI/종료 구현의 같은 줄 rename+EOF guard wrapper를 사용할 수 있다.
  기존61 UiCall 전체 tuple과 행 좌표·금액 소비자는 보존한다. 억지 padding/검사 완화0.
- 새 제품 단독 commit의 직접 before/after를 고정한다. history EOF 내부 반복 helper는
  고정4전이·24객체·각 실제 Git before 전체 역상·중간 raw/ancestry·현재 disk/HEAD를 증명한다.
  실제19 manifest 조합만 인정하고 새 Holdem×옛 peer 가상 조합은 거부한다. 캐시/자동 diff 허용0.

## 표적 검수

- proven pre-autoload KO 격리 1프로세스, 실제 Main-owned overlay/합성 키 입력.
  seed만 준비한 두 독립 표본으로 실제 대기 창의 tick/잔여 시간을 확인한다.
  A: 실제 Call 직후 player0.3초 창에서 fresh Enter 무효→Esc→RESULT가 옛 deadline 뒤에도 유지.
  B: 실제 AI 마지막 행동의0.6초 창에서 fresh Enter 무효→Esc/Close→Main회수→재open/새 첫패,
  이전 deadline 뒤 새 판 보존. 정상 Call→AI→다음 선택도 비교한다.
- 새 busy를 이전 token이 해제하지 못하는 경계는 실제 시간창 또는 명시 prepared 함수 표본으로
  분리한다. 실제 키와 직접 함수 호출/준비 상태를 섞어 자연 플레이로 주장하지 않는다.
- 현금−10k/mental−5/Meta 마스터리 등 RESULT 효과와 Close의 AP−1·행동축/장소/로그·UI metadata를
  실제 함수에서 독립 계산해 비교한다. 정산0으로 숨기지 않는다. Main cold/lazy 부작용은 준비와 분리한다.
- 안정된 RESULT/새 판을 PNG로 읽는다. 진행 중 복원하지 않으며 timer가 모두 끝난 뒤 pending 타입·
  busy/generation·GameState·Meta 파일·Main UI/metadata·논리BGM/Controller를 원복한다. 실제player34 보존.
- 같은 clean 후보에서 fresh receipt/fullbody/JA UI/ZH/EN/context/queue/diff/등록/신규focused
  10검증+차선조회1을 한 번 수행한다. 기존4서사는434참조/NOT_RUN,
  과거focused/완료437runtime/전체감사/240주/성능A/B 재실행0.

## 깊이·한계

- 없애면 한 입력이 끝나기 전 다음 행동과 옛 세션 callback이 새 상태를 바꿀 수 있다.
  기존 fold/check/call/raise의 단일 실행 기회를 지키는 수리이며 새 선택층·24주 결과를 만들지 않는다.
- 규범은 일회성 수리·검수 지시다. 실제 번역 accepted41656/b209·JA3044/CN/TW1733 불변.
  저대비 카드·직접 영어/후속번역·side-pot/승패 산식·원어민/인간/물리패드 및 장기 플레이는 별도다.
  과거198판정/176보고·인간원장·공개GO1 보존, 본편/새package HOLD. 자동PASS는 계약 증거다.

## 완료 증거

- source `3c242a5caa3e037f705b03639470d42a1c213879`, tree `5d3512b6861dc0a0828b982692cafaea080f756d`. 제품 단독 `aa21f0b`와 검사 commit main push 완료.
- KO 실제2PNG·26raw/13tap·첫손3·정산2·Close1·prepared token1 PASS(26.712초). 두 실제 대기 창의 추가 Enter 무효와 RESULT/재진입 뒤 옛 timer 차단, 정상 후속 FLOP 및 typed3복원을 확인했다. 실제 player34 불변.
- 첫 시도는 재생성 Main AP 버튼의 옛 absolute 경로로 focus를 복원하려다 FAIL했다. 첫 FAIL138파일을 보존하고 새438 helper만 의미동일 AP 버튼으로 복원했다. raw path/ID는 별도 보존하며 노드 신원 불변으로 주장하지 않는다.
- fresh10검증+조회1 모두 PASS(389.657초), 신규focused50/과거case0. runtime SHA `457e89d58cd2b5c8ff914fae59a297cde7c0a864e015540451b968f84017812c`, normal SHA `9cdd34c5ab12b25d478bfa2a72104395588ce40225ad003d7ff99949d28237c2`.
- [독립 보고](../agent_reviews/ORDER-438.json) SHA `643658f25ec0811e50f59f7ce45ee18442056dfd6b133f1a25e6058f81c5f7da`로 이 source·작업 범위 GO. 199판정/177보고가 되며 역사·인간 원장과 번역 수는 불변이다.
- 규범 판정: 이 오더의 저작·검수 지시는 **일회성**. 새 상시 규칙0. 자동PASS는 계약 증거이며 작품·출시GO가 아니다. helper 복원 입구가 busy 위반 시 즉시 중단하지 않는 실패경로 보강은 후속 helper에서 분리한다. 이번 실제 위반0이며 범용 실패복원 안전성으로 확대하지 않는다.
