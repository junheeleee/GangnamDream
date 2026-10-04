# ORDER-437 — 홀덤 후속 베팅의 선택 기회를 보존한다

#### [~] ORDER-437 [P1·게임 흐름] 라운드별 행동 완료·올인 제외

**[~] 착수 — 2026-10-04.** 435 후속 읽기에서 `_betting_complete()`가 금액 일치만
확인해 0원으로 초기화된 FLOP/TURN/RIVER를 플레이어 선택 없이 연속 통과하는 결함을 확인했다.
사용자 계속 개발·내부 검수·main 커밋/푸시 위임 안의 기존 게임 수리다.

## 범위·소유

- root: `scenes/HoldemClub.gd` 한 게임파일, `tools/ui_translation_append.py` EOF admission,
  새 private437 normal, CLAUDE·큐/L3·사양/보관본·WORK_LOG·생성STATUS·agent 보고/판정.
- claude_handoff_review: `tools/holdem_money_history.py` EOF의 새 전이 증명,
  신규 `tools/holdem_betting_receipt_check.py`. 이전 본문·pin·focused·실패/성공 원본 불변.
- receipt_tests392: `tools/audit_scope.json` 명시 `holdem-betting` 차선,
  새 private `order437-run.py`, `order437-check.gd`, `order437-check.tscn`.
- independent392: 비저자 전수 source·새 검사·실제 화면/입력·증거 최종검수.
  실제 엔진/감사 실행은 root만 한다. 선언 후 제품 단독 commit을 증명의 직접 before/after로 고정한다.
- 카드/AI 전략/블라인드 수치·좌석/사이드팟/승패 산식/경제/AP/저장/원문/번역/폰트/공개 패키지 불변.
  JA pipeline/audit는 변경하지 않고 기존 UiCall 좌표까지 보존한다.

## 구현 계약

- 한 라운드의 미행동 좌석을 일시 상태로 추적한다. 블라인드는 행동 완료가 아니다.
- live·잔액 양수인 각 좌석이 행동하고 필요한 금액을 맞춘 뒤에만 다음 단계로 간다.
  최고 베팅을 올린 행동은 다른 좌석의 응답을 다시 요구한다.
- fold·잔액0 좌석은 행동 차례에서 제외한다. 더 베팅 가능한 좌석이 0~1개이고
  미납 콜이 없으면 자동 runout을 허용하며, 혼자 잔액이 있어도 미납이면 선택을 기다린다.
- 기존 빈 줄의 자연스러운 상태/호출 위치와 EOF helper를 사용하되 억지 padding0;
  기존 `_tr`/context 호출의 전체 UiCall tuple(행 번호 포함)을 독립 대조한다.
- 새 게임 raw는 실제 Git commit/tree/blob 18객체·3전이와 전체 역상으로 증명한다.
  18개 실제 source manifest 조합만 인정하며 새 Holdem×옛 peer 가상 조합을 금지한다.
  기존 원장41656/b209·JA3044/CN/TW1733·이전 proof본문은 byte-exact로 둔다.

## 표적 검수

- proven pre-autoload 격리 KO 1프로세스. 임시 TH/RNG 탐색으로 seed만 준비하고 실제
  Enter 첫패→Call→AI/BB 행동→FLOP 대기→Check→AI 행동→TURN 대기의 연속 흐름을 관측한다.
  입력·보드3/4·덱43/42·pending·베팅·semantic cursor를 결속하고 안정된 대기 PNG2장을 읽는다.
- 별도 prepared 표본은 raise 재응답/fold·stack0 제외/모두 all-in/유일 actionable 좌석의
  owed-call 및 matched runout을 확인한다. 준비 상태 주입과 자연 첫패 흐름을 구분한다.
  실제 함수·입력·부작용을 관측하며 자연 ingress/물리패드 주장을 하지 않는다.
- 비동기 0.3/0.6초 타이머 chain은 player-wait/SHOWDOWN에 안정된 뒤만 복원한다.
  timeout은 process 실패로 남긴다. set_process(false)를 타이머 취소라고 주장하지 않는다.
  Showdown의 성향·승패·stack·history 변화도 기대값으로 검증하며 게임 효과0으로 쓰지 않는다.
  Leave/RESULT는 호출하지 않는다. 새 pending의 타입/순서 포함 typed 전체 상태·실제player34를 보존한다.
- fresh receipt/fullbody/JA UI/ZH/EN/context/queue/diff/등록/신규focused 총10검증+차선조회1.
  runtime 뒤 같은 clean 후보에서 한 번만 수행한다. 기존4서사는434 원본 참조/NOT_RUN,
  과거focused·전체감사·240주·성능A/B 반복0이다.

## 깊이·경계

- 수리를 지우면 공개 카드별 베팅 선택과 BB 선택 기회가 다시 사라진다.
  돈을 걸거나 포기하는 기존 선택을 복구하는 것이며 새 24주 상태·서사·선택층을 만들지 않는다.
  같은 자리의 경쟁은 fold/check/call/raise와 남은 stack이며 관련 비용 산식은 보존한다.
- 규범은 이번 수리·검수의 일회성 지시, 상시 정본 추가0. 자동PASS는 계약 증거다.
  중문 후속 street/정산19키 후보, 직접 영어·카드 저대비·10px·mid-action 퇴장 타이머 문제는
  본 작업으로 닫지 않는다. 공개GO1·인간OPEN45·본편/새package HOLD를 유지한다.
