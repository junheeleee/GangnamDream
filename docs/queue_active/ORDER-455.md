# ORDER-455 — 홀덤 한국어 승리 문구의 조사를 바로잡는다

#### [~] ORDER-455 [P1·표면 정합] 기존 번역 키를 보존한 한국어 승리 표시

**[~] 착수 — 2026-10-05.** 현재 실제 승리 메시지의 `%s으로 승리! +%s`는
족보9종에 `하이카드으로`·`스트레이트으로`·`트리플으로`를 만든다. 기본 족보는
모두 모음 또는 ㄹ로 끝나므로 `로`가 맞다. 지급/승패가 아닌 표시1곳만 수리한다.

## 범위·소유

- root: `scenes/HoldemClub.gd`1210행의 전용 helper 감싸기와 EOF helper만 변경.
  CLAUDE·큐/L3·이 사양/보관·WORK_LOG·생성STATUS·판정과 private455 normal 실행을 소유한다.
- claude_handoff_review: `tools/holdem_money_history.py`·`tools/ui_translation_append.py`의
  새 exact source 전이1단계와 새 `tools/holdem_victory_particle_receipt_check.py`.
- receipt_tests392: `tools/audit_scope.json`, private `order455-oracle.py`, `order455-run.py`,
  `order455-check.gd`, `order455-check.tscn`만 저작한다. 과거452 helper는 재사용하되 수정0.
- independent392: 원문·표적 결과·2PNG를 비저자로 검토하고 마지막에
  `docs/agent_reviews/ORDER-455.json`만 작성한다. 프로젝트 import/collector/검사/엔진은 root만 실행한다.

## 표시·호환 계약

- 기존 `_tr` 한국어·영어 literal와 위치·71 UiCall을 보존한다. 한국어에서만
  승리 template의 `%s으로`를 `%s로`로 바꾸고 족보명/금액을 기존 순서로 format한다.
  helper는 이 승리 문구에만 쓰며 비한국어는 template을 그대로 반환한다.
- lookup key를 바꾸면 세 언어가 영어로 fallback하고 기존 leaf/수용 이력이 끊긴다.
  이 수리는 명시적인 표시 호환 처리이며 사전·번역 원장·소스 literal을 조용히
  재발급하거나 전역 `_tr`/일반 조사 규칙을 변경하지 않는다.
- Holdem 파일 hash와 source manifest는 실제로 바뀐다. 이전 proof를 풀지 않고
  exact 한 줄/EOF 역상·실제 Git 전이 하나와 manifest tuple 하나로 새 소비자를 결속한다.
  기존12단계·454 고정원장 최적화·이전 focused/profiler·pipeline/언어 audit는 원문 그대로 둔다.
- 승자/카드·지급/hand net·AI 패배 문구·RESULT·input/focus·font/레이아웃·세 다국어 사전과
  수용41755/b228은 변경0이다. 새 번역·coverage 증량으로 세지 않는다.

## 표적 검수·완료

- 새 focused: 정확한 제품 역상·Git/HEAD/path/ancestor 거부·복구·현재 source census,
  manifest 한 전이·71 UiCall·KO9족보/두placeholder 순서·비KO 그대로 반환 분기,
  기존 사전/원장/지급/AI 문구/454 prefix 불변을 검수한다. 합성/소스 계약은 엔진 증거가 아니다.
- 격리된 pre-autoload bootstrap의 KO1 process에서 실제 `rank_name(0..8)`를 format한
  9문구를 검사한다. 준비한 합법 RIVER 두 개(스트레이트·트리플)의 실제 dispatcher→
  SHOWDOWN 승리2회·2PNG를 확인한다. 준비 카드와 자연 플레이를 구분한다.
  각11장+남은41장·중복0·단독 승리·지급/순손익과 도박성향 효과를 독립 계산한다.
  typed 전체 상태/RNG/Meta/semantic focus 복원1·실제 player34 불변을 확인한다.
- 실제 deal/betting/AI/RESULT/Close/raw 입력0이다. 비KO는 번역 template/key와
  helper 반환 계약으로 확인하며 과거 다국어 화면 관찰을 새 관찰로 세지 않는다.
- 같은 clean 후보의 새 focused, 실제365 기본1회, EN/context/queue/diff/등록과
  차선조회만 실행한다. 과거 focused/whole audit/240주/공식교환/새package NOT_RUN.
  새 실패는 첫 증거를 보존하고 원인 수리 뒤 새 label에서 필요한 검사만 재실행한다.
- 저자와 비저자가 새2PNG·원문·검사 결과를 읽은 한정GO가 완료 조건이다.
  기존215판정193보고·인간OPEN45/DONE1·공개GO1·이전 실패/수리·본편/새package HOLD 보존.
  자동 PASS는 계약 증거이며 원어민·인간·물리패드·작품성·출시 GO가 아니다.

## 깊이·판정 경계

승리 피드백의 문법 결함을 제거한다. 새 플레이 동사·서사·수치·장기 선택은 없고,
기존 번역을 끊지 않는 좁은 호환 처리로 판단했다. 위 범위·샘플·실행 예산은
**일회성**이며 일반 조사 엔진이나 새 정본 규칙으로 승격하지 않는다.
