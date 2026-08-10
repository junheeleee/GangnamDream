# Archived Queue Spec: ORDER-88

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [x] ORDER-88 [P0·선택 인과] 독자 없는 아버지 기억과 24주 중복 영수증을 기존 장면 안에서 닫는다

**사용자 승인 (2026-08-04):** `docs/DECISIONS.md`의 판정 ③, “독자 없는 기억을
작은 완결로 닫는다”를 실행한다. 3·4개월차 0장면 경로는 `ORDER-83`이 이미 깊은
생활 장면으로 바꿨으므로 다시 만들지 않는다. 이번 범위는 현재 전수 감사가
`readerless_anywhere`로 증명한 아버지 기억 여섯 개와, Week 24 위험 장면이
남기는 write-only 선택 영수증 네 개뿐이다.

**현재 실측:** 관계 기억 45개 중 39개는 데모 안에 이름 있는 독자가 있고,
`father_asked_more`, `father_called_again_that_evening`,
`father_gangnam_words_held_back`, `father_health_warning_postponed`,
`father_neighbor_detail_checked`, `father_quiet_call_ended` 여섯 개만 전체 범위에서
독자가 없다. `v2_dirty_trace_initial_call[0/1]`과
`v2_dirty_recruiter_week24[0/1]`은 실제 효과와 First Bill의 정확한 추적
영수증이 따로 있는데도 선택 기록 자체는 다시 읽히지 않는다.

**착수 선언 — 만지는 파일:** 생산자·독자와 저장 필드를 전수한 결과, 구현은
`content/events/core_loop_v2_events.json`,
`content/events_en/core_loop_v2_events.json`, `systems/DemoCoreLoopV2.gd`,
`scenes/StoryMode.gd`만 바꾼다. `StoryMode`는 Week 24 효과 적용 전 정확 영수증을
검사하고, First Bill 회상에서 완료 당시 아버지 기억만 읽는 경계에 한정한다.
표적 증거는 `tools/demo_core_loop_v2_audit.py`,
`tools/CoreLoopV2BCheck.gd`, `tools/CoreLoopV2ECheck.gd`,
`tools/CoreLoopV2HandoffCheck.gd`, `tools/ManualSaveCheck.gd`,
`tools/ScreenshotQA.gd`, `tools/run_core_loop_v2_input_qa.sh`가 소유한다.
입력 runner는 CI 무음 옵션을 추가한 뒤 드러난 macOS Bash 3.2의 빈 배열
호환만 수리하고 제품 입력 의미는 바꾸지 않는다. 본문 여섯 개가 늘어나는 파생 범위는
`content/meta/demo_localization_scope.json`, `docs/I18N_INFRASTRUCTURE.md`,
`docs/I18N_GLOSSARY_ZH.md`, `docs/human_gates.json`에 반영한다. 정본·검증·종료는
`docs/CORE_LOOP_V2.md`, `docs/QA_CHECKLIST.md`, `CLAUDE.md`,
`docs/CODEX_QUEUE.md`, 이 활성 사양과 완료 뒤 `docs/queue_archive/ORDER-88.md`,
`docs/queue_archive/CODEX_QUEUE_2026-08.md`, `docs/WORK_LOG.md`, 생성
`docs/STATUS.md`만 만진다. `scenes/MainGame.gd`,
`content/meta/demo_core_loop_v2.json`, `content/meta/narrative_spine.json`,
`content/meta/story_rules.json`, `content/meta/exposed_event_state_contracts.json`,
시각·오디오·연출 원장, `docs/BALANCE.md`, `docs/DECISIONS.md`는 사건·라우팅·
장소·효과·수치가 바뀌지 않으므로 제외한다.

## 깊이 3문

1. 지우면 플레이어가 아버지에게 어떻게 응답했는지 여섯 번 기록하면서 어떤
   장면도 그 차이를 읽지 않고, Week 24에서는 같은 위험 선택을 두 종류의
   영수증으로 중복 보관한다.
2. 여섯 기억마다 새 callback 카드를 붙이면 사용자가 싫어한 얕은 1비트 사건을
   늘린다. 이미 예정된 다음 통화·건강 신호·월말 장부 안에서 짧게 달라져야 한
   장면의 깊이가 늘고 흐름은 늘어나지 않는다.
3. 모든 관계 기억을 5년 결말까지 끌고 가면 작은 표현도 거대한 분기 부채가 된다.
   이번에는 실제로 독자 0인 여섯 개와 의미가 중복된 네 기록만 닫고, 이미 데모
   안에서 닫힌 39개나 장기 결말을 자동 확장하지 않는다.

## 배치 A — 여섯 아버지 기억을 다음 기존 장면이 읽는다

- 새 사건·새 슬롯·새 callback을 만들지 않는다. 1개월 첫 통화와 3개월 조용한
  통화에서 생긴 기억은 그 뒤의 기존 아버지 통화 또는 Week 21 건강 신호가 읽고,
  Week 21에서 생긴 세 기억은 기존 6개월 결산이나 First Bill의 아버지 약속
  장부가 읽는다. 한 경로에서 독자가 실제로 보이지 않으면 그 독자는 무효다.
- 회수는 선택 원문을 되풀이하거나 “좋은 아들/나쁜 아들”로 채점하지 않는다.
  전화가 짧아지는 방식, 다시 묻는 한 문장, 약봉투를 확인하는 거리처럼 이미
  일어난 선택 때문에 같은 장면의 반응만 달라져야 한다. 돈·몸·마음·관계 단계·
  도덕색·route 효과는 0이다.
- fresh의 아버지 부재중 전화 뒤 플레이어 발신, schema-2의 옛 수신 통화,
  연락하지 않은 달, Week 21의 `unmet/opening` 호환을 모두 구분한다. 만나지 않은
  사람의 지식, 아직 오지 않은 약국 봉투, 하지 않은 재통화를 소급 발명하지 않는다.
- 한국어는 번역투 없이 부자 사이의 생략과 거리로 쓰고, 영어는 관계의 직접성·
  머뭇거림을 보존한다. 기존 선택·효과·플래그·날짜·금액·선택 수는 바꾸지 않는다.

## 배치 B — Week 24 중복 기록을 하나의 진실로 줄인다

- 경찰 초기 확인과 모집책 재접촉의 네 선택은 기존 효과를 정확히 한 번 적용하고,
  `deferred_callback_receipts`와 First Bill 장부가 현재처럼 실제 선택을 추적한다.
  같은 사실을 별도 write-only 선택 기록으로 다시 저장하지 않는다.
- 이미 배포된 저장의 네 선택 기록은 삭제·재해석하지 않는다. 새 코드가 읽지 않는
  옛 값은 호환용으로 보존하거나 명시적 퇴역 영수증으로 한 번 정리하되, 경찰
  결론·변호사 선임·무혐의·추가 범죄를 발명하지 않는다.
- `callback_escaped_dirty_trace`와 `fell_to_darkness`의 claimed→resolved 전이,
  First Bill selected/deferred/expired 구획, 24→48주와 조건부 5년 결말은 그대로다.
  위험 선택의 수치 대가는 다음 `②+P-5` 작업이며 여기서 손대지 않는다.
- 전수 감사는 관계 기억 `readerless=0`, W24 선택 기록 `write_only=0`, 기존 정확
  추적 영수증 2개, 신규 사건 0을 별도 수치로 증명해야 한다. 숫자를 맞추려고
  unrelated 독자를 붙이거나 아무 화면에도 안 나오는 가짜 독자를 등록하면 실패다.

## 비범위

- 새 아버지 장면·새 관계 단계·새 호감도, 나머지 39개 관계 기억의 5년 확장,
  W8 심화 밸런스와 치명 비용 표시, 데모 저장 retail 브리지, 일본어·중국어 본문,
  엔딩·`finish_run`·경제 수치를 만들지 않는다.
- 기억마다 영구 분기나 callback을 하나씩 만들지 않는다. 표현 선택이 장면 안에서
  고유 반응 뒤 합류할 수 있다는 정본을 유지한다.

## 검증과 사람 판정

- L1: 생산자→도달 가능한 독자 전수, fresh/old V2/V1 저장, 아버지 발신 주체,
  Week 24 선택·효과·정확 영수증 1회, 24→48→240주, KO/EN 구조·숫자, 실제 입력,
  960×600/1280×800, 전체 감사와 CI를 통과한다.
- L2: 아버지 생사·약국 봉투 시점·고시원/전화 공간·경찰 절차·미해결 상태,
  한국어 생략과 영어 관계 거리를 교차 재독한다. 회수가 선택을 칭찬·비난하거나
  1년/5년의 미래를 미리 설명하면 실패다.
- L3: 사용자는 같은 `demo_rc`에서 아버지와 다르게 말한 두 경로를 읽고 ① 다음
  장면의 차이를 알아챘는지, ② 별도 결과 카드가 늘지 않았는지, ③ 관계가 숨은
  점수처럼 느껴지지 않는지 판정한다. 자동 초록을 감정적 완결의 합격으로 부르지
  않는다.

## 완료 조건

- 여섯 아버지 기억은 각각 한 개 이상의 실제 도달 가능한 기존 장면 독자를 갖고,
  아무 선택에도 수치·관계 단계·route 효과를 새로 붙이지 않는다.
- Week 24의 네 선택은 기존 실제 효과와 두 정확 추적 영수증만 남기며 신규/옛
  저장 모두 중복 적용·재생·소실이 없다.
- 신규 사건·슬롯·callback 0, KO/EN 실제 입력·화면·24/48/240주·전체 감사·CI가
  초록이고 규범 승격·일회성 판정을 기록한 뒤 아카이브한다.

## 완료 기록 (2026-08-11)

- 3개월 조용한 통화의 `father_gangnam_words_held_back`,
  `father_quiet_call_ended`, `father_asked_more`는 새 사건 없이 21주
  아버지 건강 신호의 KO/EN 한 문단을 각각 바꾸도록 연결했다.
  21주의 `father_neighbor_detail_checked`,
  `father_called_again_that_evening`, `father_health_warning_postponed`는
  24주 첫 청구서 도입부에서 각각 한 문단으로 돌아온다. 선택·수치·
  관계 단계·route는 바꾸지 않았다.
- 정확한 typed 기억이 없는 저장, 연락하지 않은 경로, V1·legacy
  플래그만 남은 경로는 통화·약국 봉투·재연락을 소급 추론하지 않고
  기본 산문을 쓴다. First Bill 갤러리는 완료 당시의 21주 기억 하나
  또는 기억 없음을 스냅숏에 고정해 다음 런이 과거 회상을 바꾸지 못한다.
  필드가 없던 schema-1 회상은 현재 관계를 읽지 않고 기본 산문을 쓴다.
- `v2_dirty_trace_initial_call[0/1]`과
  `v2_dirty_recruiter_week24[0/1]`은 선택 전에 `demo_collision`의
  정확한 source key·claimed 영수증을 확인한다. 선택 뒤에도 그 key만
  resolved로 바꾸고 기존 효과는 한 번만 적용한다. 영수증이 없거나
  손상됐거나 같은 root의 다른 key면 효과·결과 화면 전에서 멈춘다.
  새 런은 `story_choice_receipts`에 중복 사본을 쓰지 않으며, 옛 중복 값과
  같은 root의 타 영수증은 삭제·재해석하지 않고 호환 자료로 보존한다.
- 전수 감사는
  `relationship_readerless=0 father_memory_readers=6 existing_reader_events=2 new_events=0`과
  `w24_dirty_choices=4 w24_generic_story_receipts=0 w24_exact_deferred_receipts=2 w24_choice_effects=4`를 남겼다.
  `CoreLoopV2BCheck`, `CoreLoopV2ECheck`, `CoreLoopV2HandoffCheck`,
  `ManualSaveCheck`는 옛/V1/V2 저장, 고정 회상 3종, schema-1 기본 산문,
  정확 source의 한 번 해결과 위조·누락 fail-closed를 통과했다.
- KO/EN × 키보드/가상 패드 네 24주 제품 경로는
  `CORE_LOOP_V2_FULL_MATRIX_OK languages=ko+en devices=keyboard+gamepad weeks=24 cases=4`,
  KO/EN × 1280×800/960×600 네 화면은
  `CORE_LOOP_V2_SURFACE_MATRIX_OK languages=ko+en resolutions=1280x800+960x600 cases=4`로 닫혔다.
  전체 감사와 commit `e4239d3`의
  [GitHub Actions 31441743970](https://github.com/junheeleee/GangnamDream/actions/runs/31441743970)도
  전체 GREEN이다.
- 현지화 원장은 정적 UI 2,730, 73사건·471본문·동적 686회/657고유·
  자산 4, 총 번역 소스 1,132로 다시 잠갔다. JA는
  `1/73·8/471·9/657·0/4`, zh-CN·zh-TW는 전부 0이며, 이를 번역·출시
  완료로 부르지 않는다.
- 아버지 생사·약국 봉투 시점·전화 공간·경찰 미해결 상태와 KO/EN
  관계 거리를 교차 재독해 P0/P1 0을 확인했다. 사용자가 두 경로의 작은
  차이를 자연스럽게 기억하는지는
  `demo_father_memory_small_completion` 사람 게이트로 **OPEN**이다.
- **승격:** 여섯 기억의 기존 장면 회수·기억 없음·갤러리 동결 규칙과
  Week-24 정확 deferred 소유·fail-closed·옛 중복 호환은
  `docs/CORE_LOOP_V2.md` `§13 현재 구현 경계`가 소유한다. 기계 계약은
  `docs/QA_CHECKLIST.md`, 현지화 실측은
  `content/meta/demo_localization_scope.json`·`docs/I18N_INFRASTRUCTURE.md`·
  `docs/I18N_GLOSSARY_ZH.md`, 사람 판정은 `docs/human_gates.json`이 소유한다.
- **일회성:** 착수 파일 목록·제외 목록, 배치 A/B 구현 순서, 현 리비전의
  명령·임시 실행 디렉터리·로그·CI run ID는 이 아카이브에만 남긴다.
  자동 PASS를 아버지 관계의 감정적 완결·재미·출시 GO로 바꾸지 않는다.
