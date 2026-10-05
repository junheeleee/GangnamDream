# ORDER-456 — 생활 장면 선택의 실제 키보드 전달 경로를 확인한다

#### [x] ORDER-456 [P1·입력 QA] 준비된 집밥·공원 휴식 4경로

**[~] 착수 — 2026-10-05.** 기존156의 결과 배경 검사는 실제 버튼의
`pressed.emit()`을 사용한다. 방향키/Enter가 GUI를 거쳐 그 버튼을 한 번만
실행하는지는 그 증거에 없다. 302의7개 source 수리는 완료되어 반복하지 않고,
156의 입력 잔여 중 이 공백만 새 검수 도구로 닫는다.

## 범위·소유

- root: CLAUDE·큐/L3·이 사양/보관·WORK_LOG·생성STATUS·판정, 후보 고정과 실제 실행.
- receipt_tests392: 새 `tools/RoutineBackgroundInputCheck.gd`와 `.tscn`만 저작한다.
  필요 시 새 스크립트의 `.gd.uid`도 이 범위다. 기존156 helper는 수정하지 않는다.
- claude_handoff_review: 새 `tools/run_routine_background_input_check.py`와
  `tools/audit_scope.json`의 해당 검사/명시차선만 저작한다. 기존 안전 실행기 유틸을
  재사용할 수 있지만 과거 검사 main/케이스는 실행하지 않는다.
- independent392: 원문·새 helper·입력 관찰·원본4PNG·검증 결과를 읽고
  마지막 `docs/agent_reviews/ORDER-456.json`만 작성한다.
- 프로젝트 import·collector·검사·엔진은 root만 실행한다. 작성자는 AST/JSON 읽기만 한다.

## 판정 가능한 한 단위

- SAVE[0]/W230와 REST[5]/W216 × KO/EN = 준비 진입4경로다. 기존156의
  seed/본문·일정/장소를 참조하며 새 생활보드나 공개 데모 진입은 만들지 않는다.
- 실제 제품이 정한 첫 포커스0에서 Right→Right→Enter를 누른다. 건당3tap/6raw edge,
  합12tap/24edge가 예상 모집단이다. 포커스를 주입하거나 `pressed.emit`·직접
  선택 callback·입력 소비자 직접 호출로 성공을 만들지 않는다. 실제 포커스/카드
  메타가 기대와 다르면 실패 증거를 남기고 원인을 판단한다.
- 각 실제 `pressed`1회와 해당 action id, weekly receipt1개, AP1→0, turn/date
  불변을 확인한다. SAVE의 실제 난수 절약금액·mental−2와 REST[5] mental+9,
  두 경로의 atomic money signal1회를 다른 상태/로그/성향/기록 변화와 구분한다.
  입력 전 준비/초기화 효과와 입력 뒤 효과를 섞지 않으며 예상하지 못한 변화는 숨기지 않는다.
- 결과 타이핑·유한 fade의 자연 종료 뒤 원본4PNG를 기록한다. SAVE는 실제 공동주방과
  `goshiwon_hallway`, REST는 실제 공원벤치와 `street`; KO/EN 본문·receipt 양언어
  원문·texture path/ID·ambience가 일치해야 한다. 반복 배경 motion 종료나 tween
  `custom_step`은 사용하지 않는다. 결과 확인/다음 주 입력은0이다.
- 새 pre-autoload `StoryNameplateBootstrap` namespace만 사용하고 실제 player34의
  경로·존재·bytes/SHA를 전후 보존한다. 실제 슬롯 load/save/삭제0이다.
  RNG seed와 GameState는 준비값이며 프로세스 격리 종료를 원래 플레이 복원으로 부르지 않는다.

## 검증·보존

새 실행기는 exact marker·exit·stdout/engine log 오류·timeout·격리·실패 아티팩트
보존을 확인한다. 작은 실행기 self-test와 실제4경로, context/queue/diff/등록·차선조회만
실행한다. 새 실패는 지우지 않고 원인 수리 뒤 새 label에서 필요한 경로만 다시 검사한다.
기존32 callback/echo/resolver·302·365·JA/ZH 전체감사·whole audit·240주·새package는
NOT_RUN이다. 제품/원고/번역/원장/입력 매핑/기존 QA/사용자 project.godot 변경0이다.
확인된 제품 결함이 새 파일 수리를 요구하면 별도 선언 뒤 진행한다.

저자/비저자의 원문·입력/4PNG 검토와 같은 clean 후보의 표적 결과가 완료 조건이다.
216판정194보고·인간OPEN45/DONE1·공개GO1·본편/새package HOLD를 보존한다.
이 검수는 prepared legacy/internal 경로의 합성 키보드 전달 관찰이며 자연 플레이·
물리패드·156 전체·5장/작품성·출시 GO를 대신하지 않는다.

## 깊이·규범 소유권

지우면 callback 회귀가 못 보는 GUI 입력 누락/중복을 놓친다. 새 선택이나24주 효과는
만들지 않고 기존 선택의 실제 전달을 검사한다. 이미 확인한 배경 회귀를 반복하는 대신
입력 공백4건에 검수 시간을 쓴다. 위 파일·모집단·절차는 이 작업의 **일회성**이다.

## 완료 — 2026-10-05

- 후보 `5d67f66c76c5f4ca1deef1a0515a9d81e1f4bb2c`, tree `b8bee44b684b691d85816d01cd723d59538bb7eb`의 첫 실제4경로가 통과했다. KO19.312초/EN21.777초, 24raw/12tap/4pressed/4receipt/4PNG, 경계 버튼0이다.
- SAVE 실제50188원·mental−2/career+4와 REST mental+9/free_time_count+1, AP1→0·달력 불변을 확인했다. 준비/초기화와 입력 후 효과를 분리했으며 원본4PNG를 저자와 비저자가 직접 읽었다.
- 같은 후보의 합성17·context/queue/diff/등록193·차선조회 PASS. 잘못 지정한 lane+files 조회의 CLI 오류는 증거에 보존하고 lane-only로 정정했다. 런타임 실패·기존 검사 재실행은 아니다.
- 결과 `.git/full-game-localization/order456-first/result.json` SHA `17badc640d4315af9f7c0e0dc907ac9e5da1f6e01dc1c99e41ff7052aaa7072c`; 정적 증거 `static-checks.json` SHA `c2a21fac75994d285dff739236ebb0639a2473d1a0a45a3de7e3c8b5fbf2e9d6`.
- [독립 한정GO](../agent_reviews/ORDER-456.json), 보고 SHA `4620f2eb58fa6aaecece28414bf228563ecce85d040c4dfe1ee2017eb6606c7c`. 입력22·실제player34·기존216판정194보고와 인간 이력을 보존하고217판정195보고로 마감한다.
- 규범은 위 일회성 지시뿐이며 새 정본 규칙0이다. 자동 PASS는 계약 증거이지 자연 플레이·물리패드·인간/원어민·156전체·5장/출시 GO가 아니다. 본편/새package HOLD를 유지한다.
