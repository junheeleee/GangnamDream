# ORDER-443 — 홀덤 행동 문구가 강조 중에도 잘리지 않는다

#### [~] ORDER-443 [P1·UI 수리] 가로 전체폭 메시지의 확대 잘림

**[~] 착수 — 2026-10-05.** 442 실제 간체/번체 콜 입력에서 확대 중
메시지 사각형이 x<0·폭>1280이 되어 ScrollContainer에 잘렸다. 원문 관측
`order442-screen-first`는 실패로 보존하고 번역 30값의 최종 GO는 보류한다.

제품 후보 `9dc812d`: 두 호출만 치환·61 UiCall/줄 좌표 보존. 새 focused
사전검사57 PASS·비저자 제품/EOF/격리 collector 코드 검토 차단0. 실제 두 지역
묶음16PNG와 정상 차선9검증+조회1 대기이며 품질 GO는 아직 미발급이다.

## 범위·소유

- root: `scenes/HoldemClub.gd`의 콜/쇼다운 `_msg_lbl` 확대 호출 두 줄만 주석화,
  새 `tools/holdem_message_pulse_receipt_check.py`, private442 runner/oracle/normal
  및 private443 기록, CLAUDE·큐·이 사양/보관·WORK_LOG·생성STATUS·새 agent 판정.
- claude_handoff_review: `tools/holdem_money_history.py`·`tools/ui_translation_append.py`
  EOF의 정확한 새 Git 전이/과거 manifest 호환만. 기존 prefix/pin/receipt 불변.
- receipt_tests392: private442 GD/scene의 실패 수리·콜/쇼다운 강조 구간 계측과
  `tools/audit_scope.json` 명시 차선만. root 외 engine/collector/검사 실행0.
- independent392: 비저자 원본 실패·제품/검사 diff·새 실제 화면/입력·보존 근거 검수.
- 사전·accepted41724/b213·KO/EN/JA·패/돈/AP/승패/타이머·다른 노드 강조·
  자산/폰트/인간원장/공개데모 불변. 기존202판정/180보고 보존.

## 수리·검증

- 전체폭 RichTextLabel을 중앙 기준 확대하면 첫 글자가 화면 밖으로 밀린다.
  `_msg_lbl` 두 호출만 같은 한 줄 주석으로 치환하고 기존 배너·칩·카드 강조를 유지한다.
  줄 수와 기존 UiCall 좌표를 유지하며 공통 pulse 함수는 변경하지 않는다.
  상태·선택·경제 변경0. 본문을 잘림 이후 시점으로 옮겨 검사하지 않는다.
- 실제 콜과 쇼다운의 기존 확대 시간창에서 메시지 전체 영역·글자·폰트·clip
  및 PNG를 확인한다. 442의 두 지역 입력·AI·정산·Close·복원 묶음을 함께 검수해
  중복 실행을 줄인다. 자연 딜·원어민·물리패드 관측으로 부르지 않는다.
- 첫 실행에서 private witness의 deck 배열이 실제 pop과 공유된 기록 결함도
  별도로 고친다. 준비 시점 deep copy를 저장하며 기존 실패 JSON은 수정하지 않는다.
- exact product diff 역상과 실제 Git 계보·blob·tree 검증, 원래61 UiCall 보존,
  기존 수용/manifest/header/보고/인간원장·player34 바이트 보존을 확인한다.
- 새 focused 검사1 + 442의8검증+조회1과 새 표적 런타임만 실행한다.
  기존 카드/승패/비동기 focused·전체감사/240주/성능 A/B는 NOT_RUN이다.

## 한계·일회성

- 이 수리는 읽는 순간 글자가 화면 밖으로 나가는 확인된 결함만 닫는다.
  신규 선택/규칙/밸런스/번역을 추가하지 않으며 24주 인과 판단 대상이 아니다.
- 지시는 일회성·새 정본 규칙0. 자동 PASS는 계약 증거이며 최종 품질 GO가 아니다.
  공개GO1·인간OPEN45·원어민/인간/물리패드 미관측·본편/새package HOLD 보존.
