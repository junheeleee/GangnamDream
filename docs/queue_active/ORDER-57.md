# Active Queue Spec: ORDER-57

> Canonical status is indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-57 [P0·코어 재구축] Core Loop V2 — 플레이어가 자기 6개월을 설계하는 데모

**사용자 판정 (2026-07-27):** 현재판은 초기보다 좋아졌지만 정상 플레이에서
주요 인물이 연달아 수동적으로 등장하고, 관계·연애는 플레이어가 먼저 다가가거나
노력했다는 감각 없이 급진전한다. 반복 AP는 저정신 시 휴식·아버지 전화 같은
우세 행동으로 수렴하고, 데모는 30분 미만이며 전략·소설 밀도가 모두 부족하다.
사용자는 기존 형식 답습을 중단하고 코어 루프 자체를 다시 설계하도록 승인했다.

**착수 (2026-07-27 Codex) — 설계·데이터 계약에서 만지는 파일:**
`docs/CODEX_QUEUE.md`, `docs/queue_active/ORDER-57.md`,
`docs/CORE_LOOP_V2.md`, `docs/GAME_RECOMPOSITION_PLAN.md`,
`docs/AP_REDESIGN.md`, `docs/ROMANCE_SYSTEM.md`, `docs/DECISIONS.md`,
`docs/DEMO_FIXLOG.md`, `docs/context_manifest.json`,
`content/meta/demo_core_loop_v2.json`, `tools/demo_core_loop_v2_audit.py`,
`tools/audit.sh`, `CLAUDE.md`, `docs/WORK_LOG.md`.
기존 사용자 변경 `project.godot`은 건드리지 않는다. 런타임 구현 파일은 현재
구조를 조사한 뒤 별도 범위 확장 선언 커밋으로 잠근다.

**설계 라우터 범위 확장 (2026-07-27 Codex) — 추가로 만지는 파일:**
`docs/CONTEXT_INDEX.md`. 새 V2 정본을 문서 그룹에만 넣고 부팅 라우터에서
누락하면 다음 세션이 인간 NO-GO를 받은 기존 AP 설계를 다시 우선할 수 있다.
게임 루프 프로필과 정본 소유자에 V2를 가장 앞에 연결한다.

**런타임 수직 단면 범위 확장 (2026-07-27 Codex) — 추가로 만지는 파일:**
`autoloads/DataRegistry.gd`, `autoloads/GameState.gd`,
`systems/DemoCoreLoopV2.gd`, `scenes/CoreLoopPlanner.gd`,
`scenes/MainGame.gd`, `tools/CoreLoopV2Check.gd`,
`tools/CoreLoopV2Check.tscn`, `tools/ScreenshotQA.gd`, `tools/audit.sh`,
`docs/CONTROLLER_UX_STRATEGY.md`, `docs/QA_CHECKLIST.md`.
1~8주만 명시적 개발 플래그와 QA 범위에서 새 휴대폰·달력을 사용하며,
사람 GO 전 `runtime_default=false`, 기존 5년 편성, 엔딩, 사용자 변경
`project.godot`은 유지한다. V2 저장은 새 단일 사전 필드로만 추가하고
기존 저장은 빈 상태로 역호환한다.

**일본어 UI 패리티 범위 확장 (2026-07-27 Codex) — 추가로 만지는 파일:**
`locale/ui_ja.json`. 전체 감사에서 새 휴대폰·달력 표면의 한국어 키 8개가
일본어 사전에 없는 것을 차단했다. 새 시스템을 일본어 완역으로 오인하지
않도록 기존 영문 폴백 정책은 유지하되, 공용 UI 키 집합은 같은 수로 맞춘다.

**사람 GO 테스트 진입 범위 확장 (2026-07-27 Codex) — 추가로 만지는 파일:**
`scenes/StartMenu.gd`, `tools/ScreenshotQA.gd`. 일반 실행이 사람 GO 전
기존판을 유지하는 계약은 바꾸지 않는다. 대신 DEBUG 시작 화면에서만
`Core Loop V2 8주 테스트`를 명시적으로 골라 새 런을 시작할 수 있게 하고,
출시 빌드 비노출·한영·패드 포커스·실제 V2 활성화를 표적 QA로 잠근다.

**빌드 식별 표면 범위 확장 (2026-07-27 Codex) — 추가로 만지는 파일:**
`systems/BuildInfo.gd`, `scenes/SplashScreen.gd`, `scenes/StartMenu.gd`,
`tools/ScreenshotQA.gd`, `tools/First30SecondsCheck.gd`, `CLAUDE.md`,
`docs/WORK_LOG.md`. `project.godot`의 사용자 변경은 건드리지 않는다.
게임 버전과 날짜형 빌드 ID는 한 파일에서만 소유하고, 시작 화면과 실행창
제목에서 항상 식별 가능하게 한다. DEBUG V2 진입은 같은 버전 옆에
`CORE LOOP V2`를 덧붙여 일반 시작·V2 테스트 캡처를 혼동하지 않게 한다.

**24주 실제 데모 개발 승인·P0 수리 착수 (2026-07-29 Codex) — 추가로 만지는
파일:** `docs/CODEX_QUEUE.md`, `docs/queue_active/ORDER-57.md`,
`docs/CORE_LOOP_V2.md`, `docs/DECISIONS.md`, `docs/QA_CHECKLIST.md`,
`docs/WORK_LOG.md`, `CLAUDE.md`, `systems/DemoCoreLoopV2.gd`,
`scenes/CoreLoopPlanner.gd`, `scenes/MainGame.gd`,
`tools/CoreLoopV2Check.gd`, `tools/ScreenshotQA.gd`, `locale/ui_ja.json`.
사용자는 1~8주 심층 진단의 결함을 승인하고 최종 상품 데모를 24주로 완성하는
개발 계획 수립과 개선 착수를 지시했다. 첫 수리 묶음은 8주차가 기존판으로
떨어지지 않는 명시적 종료·회고, 플레이어가 이름으로 읽는 놓친 길, 720p
휴대폰 경계와 실제 패드 과업을 소유한다. 이 착수는 최종 24주 목표를
승인하지만 `runtime_default` 즉시 전환이나 미완성 9~24주 개방을 뜻하지
않는다. 8주 루프 완결 → 12주 첫 만남 인과 → 16주 관계 선제 행동
마이크로 슬라이스 → 20주 포기 회수 → 24주 통합 → 기본 데모 전환의
단계 게이트를 지킨다. 기존 사용자 변경 `project.godot`, 25~240주,
엔딩 캐스케이드와 30억원 전제는 건드리지 않는다.

**작업 로그 예산 보존 범위 확장 (2026-07-29 Codex) — 추가로 만지는 파일:**
`docs/history/WORK_LOG_2026-05-16_to_2026-07-24.md`. 이번 기록을 더하자
`docs/WORK_LOG.md`가 40KB 컨텍스트 예산을 넘었다. 아직 현행 파일 끝에 남아
있던 2026-07-24 각본 리뷰 한 건을 기존 날짜별 보관본으로 무손실 이동하고,
최신 작업만 부팅 문서에 남긴다.

**A1 1~8주 공통 루프 완결 착수 (2026-07-29 Codex) — 추가로 만지는 파일:**
`docs/CODEX_QUEUE.md`, `docs/queue_active/ORDER-57.md`,
`docs/CORE_LOOP_V2.md`, `docs/BALANCE.md`, `docs/QA_CHECKLIST.md`,
`CLAUDE.md`, `docs/WORK_LOG.md`, `content/meta/demo_core_loop_v2.json`,
`content/events/core_loop_v2_events.json`,
`content/events_en/core_loop_v2_events.json`, `content/meta/story_rules.json`,
`autoloads/DataRegistry.gd`, `systems/DemoCoreLoopV2.gd`,
`scenes/CoreLoopPlanner.gd`, `scenes/MainGame.gd`, `scenes/StoryMode.gd`,
`assets/event_visual_contracts.json`, `assets/scene_audio_manifest.json`,
`tools/demo_core_loop_v2_audit.py`, `tools/core_loop_v2_balance_sim.py`,
`tools/CoreLoopV2Check.gd`, `tools/ScreenshotQA.gd`, `tools/audit.sh`,
`locale/ui_ja.json`.
분석에서 배경 AP 16회가 실행되지 않고, `decline_consequence`가 문자열
원장으로 끝나며, 주차 기한과 장면 선택 결과가 상태를 소유하지 않고,
합법 최적 경로도 8주 말 적자라는 결함을 재현했다. A1은 월간 주/보조
루틴을 실제 주간 경제에 적용하고, 모든 1~8주 포기에 한영 소비자와 한 번뿐인
상태 회수를 연결하며, `allowed_weeks`와 결과별 관계 전이를 기계화한다.
현수 선제 연락은 우연한 기존 주방 장면 재사용 대신 V2 전용 대면 장면으로
교체하고, 월말에는 돈·고정비·몸·마음·지킨 약속·놓친 제안·다음 한 단을
저장 가능한 회고로 보여 준다. 전용 결정론 시뮬레이션에서 합법 생계 경로가
두 달 고정비를 감당하고 더러운 돈이 유일한 탈출구가 아님을 잠근다.
`runtime_default=false`, 9주 차단, `finish_run` 비호출, 25~240주 폴백,
사용자 소유 `project.godot`은 유지한다.

**A1 사건 연출 원장 범위 확장 (2026-07-29 Codex) — 추가로 만지는 파일:**
`assets/scene_direction_manifest.json`, `tools/scene_direction_catalog.py`,
`tools/event_director_audit.py`. 현수 선제 연락 전용 사건을 실제 사건
레지스트리에 더하자 장면 이동 의도와 Event Director 등록 기준선도 함께
증가해야 했다. 신규 사건은 `hidden=true`, `weight=0`, `min_turn=9999`로
랜덤 풀에 들어가지 않으며, 오디오·장면 연출 원장을 같은 선언 커밋 뒤
재생성해 정본 수와 런타임 소비자를 일치시킨다.

**A1 문단 배경 게이트 결정론 범위 확장 (2026-07-29 Codex) — 추가로
만지는 파일:** `tools/CGRuntimeCheck.gd`. 전체 감사에서 남산 데이트의
문단 배경 검사가 한 차례만 원문보다 한 칸 늦게 읽혔다. 사건 데이터와
StoryMode는 원문 문단 인덱스를 정본으로 쓰지만 검사는 화면 페이지를
무조건 한 번씩만 넘겨, 텍스트 크기·뷰포트에 따라 한 원문 문단이 둘로
나뉘면 잘못 실패할 수 있다. 원문 인덱스가 목표에 도달할 때까지 안전
상한 안에서 페이지를 진행하도록 검사만 고쳐 전체 감사의 우연 통과를
제거한다.

**B 9~12주 첫 만남·세 번째 달 착수 (2026-07-29 Codex) — 추가로 만지는
파일:** `docs/CODEX_QUEUE.md`, `docs/queue_active/ORDER-57.md`,
`docs/CORE_LOOP_V2.md`, `docs/BALANCE.md`, `docs/QA_CHECKLIST.md`,
`docs/WORK_LOG.md`, `docs/history/WORK_LOG_2026-07-25.md`, `CLAUDE.md`,
`content/meta/demo_core_loop_v2.json`, `systems/DemoCoreLoopV2.gd`,
`scenes/CoreLoopPlanner.gd`, `scenes/MainGame.gd`, `scenes/StartMenu.gd`,
`tools/demo_core_loop_v2_audit.py`, `tools/core_loop_v2_balance_sim.py`,
`tools/event_director_audit.py`,
`tools/CoreLoopV2Check.gd`, `tools/CoreLoopV2BCheck.gd`,
`tools/CoreLoopV2BCheck.tscn`, `tools/ScreenshotQA.gd`, `tools/audit.sh`,
`locale/ui_ja.json`.
세 번째 달의 세 행동 카드에는 고유 한영 카피·기한·실행 설정·한 번뿐인
결과와 포기 소비자를 연결한다. 자유 문자열 `eligibility`는 완료 약속,
월간 루틴, 관계 단계, 플레이어 선제 행동을 읽는 typed prerequisite로
교체하고, 다은/지연의 생활 동선 입구는 둘 다 보일 수 있어도 한 달에 최대
하나만 계획하게 한다. 실제 첫 만남 선택은 결과별 `from→to`, 주도권과
기억 receipt를 소유하며 bundle 완료만으로는 전이하지 않는다. 아버지와
현수 후속도 실제 A1 선택·단계를 만족해야만 보인다.

저장 schema는 기존 8주 boolean 완료를 `completed_through_week=8`로
이관하고 별도 개발 상한 12와 비교한다. 따라서 A1 완료 저장은 9주
플래너로 이어지지만 12주 완료 저장은 13주에서 세 달 회고로 멈추며,
미완성 13주나 기존 디렉터로 떨어지지 않는다. 월 3 최대 밀도, 실제
South/East/LB/RB·방향 입력, 저장 왕복과 24개 배경 루틴 단위를 B 전용
게이트로 잠근다. `runtime_default=false`, `finish_run`, 13~240주,
사용자 소유 `project.godot`은 유지한다.

**B 장기 아크·인과·트랜잭션 NO-GO 재작업 범위 확장
(2026-07-29 Codex) — 추가로 만지는 파일:** `docs/DECISIONS.md`,
`content/events/arc_daeun.json`, `content/events_en/arc_daeun.json`,
`content/events/arc_events.json`, `content/events_en/arc_events.json`,
`content/events/arc_year_close.json`, `content/events_en/arc_year_close.json`,
`content/events/core_loop_v2_events.json`,
`content/events_en/core_loop_v2_events.json`, `content/meta/story_rules.json`,
`autoloads/GameState.gd`, `assets/event_visual_contracts.json`,
`assets/scene_audio_manifest.json`, `assets/scene_direction_manifest.json`,
`tools/scene_direction_catalog.py`, `tools/event_director_audit.py`.
24주는 1장 48주의 전반부이며 5년의 결론이 아니다. 따라서 9~12주는
아버지·현수·다은·지연의 정본 사실과 선택 기억을 훗날 소비할 수 있는
인과만 연다. 첫 만남 이전 이름·연락처·반복 친절을 선취하거나 현수 시험,
아버지의 발신 방향, 지연의 보상 금액을 바꾸어 쓰지 않는다. 닫힌 관계는
`at_least`를 통과하지 않고, 첫 만남 결과는 다음 카드의 조건이나 변형이
실제로 읽는다.

행동 결과는 AP·효과·축 등록·주차 확정을 하나의 원자 트랜잭션으로
처리하며 실패 시 전부 되돌린다. 결과 화면에서 저장한 세이브와 schema 2의
진행 중 행동도 재적용 없이 정확히 한 번 복구한다. 같은 주의 예약 사건과
후속 결과가 두 개의 독립 전경 장면으로 겹치지 않도록 하나의 약속 소유권
아래 묶는다. 이 조건과 1년·5년 장기 편성 감사를 통과하기 전 B는
NO-GO이며, 12주 완료나 기본 전환으로 선언하지 않는다.

**B 시간·첫 소개·회고·장기 콜백 NO-GO 재작업 범위 확장
(2026-07-29 Codex) — 추가로 만지는 파일:**
`content/events/arc_midgame.json`, `content/events_en/arc_midgame.json`,
`content/events/callback_events_5.json`,
`content/events_en/callback_events_5.json`,
`content/events/callback_events_23.json`,
`content/events_en/callback_events_23.json`, `scenes/StoryMode.gd`.
대포통장 결과의 “한 달 뒤”는 8주에만 발화하고 경찰 콜백의 정본 주차를
보존한다. 8주·12주 회고는 실제 선택 영수증만 읽으며, 선택하지 않은
아버지·현수·강남 카페를 겪었다고 발명하지 않는다. 첫 만남은 소개 문단
전까지 인물 이름표를 숨기고 한영의 질문·이름 교환 순서를 맞춘다.
아버지 통화·SNS·생계 동선·지원서 차수·대포통장 장기 콜백도 실제 횟수,
주차, 반환액과 분기에 맞춘다. 지연 재회는 정류장 장소와 실제 행인 역할로
연출 원장을 정렬한다.

**B 원자 플래그 생산자 감사 범위 확장 (2026-07-29 Codex) — 추가로
만지는 파일:** `tools/audit.py`. 전경 행동의 플래그는 원자 트랜잭션에
넘기는 `flag_updates["..."]`에서 생산되므로, 직접
`GameState.flags["..."] = ...` 대입만 찾던 감사가 실제 생산자를 놓쳤다.
가짜 직접 대입을 추가하지 않고 리터럴 원자 업데이트도 생산자로 판독해,
모의면접 결과와 이후 지원 보너스의 정적·런타임 계약을 함께 보존한다.

**B 실제 카페 체인 동적 잔고·한국어 정합 범위 확장
(2026-07-29 Codex) — 추가로 만지는 파일:**
`content/events/scenario_cafe.json`,
`content/events_en/scenario_cafe.json`.
2개월차 강남 카페 약속은 현재 난이도·루틴·일정에 따라 달라지는 현금을
고정 50만원이나 5만원 미만으로 단정하지 않는다. 인물이 화면에서 관찰할 수
있는 옷차림과 플레이어가 실제로 말한 무직 상태만 사용하고, 같은 약속 안의
한영 후속도 문이나 세계 같은 추상 비유 대신 실제로 들은 금액·부동산 용어와
받은 명함 여부를 기록한다.

**B 결과 수치·관계 기억·한국어 최종 표면 범위 확장
(2026-07-29 Codex) — 추가로 만지는 파일:**
`autoloads/EventManager.gd`, `content/meta/exposed_event_state_contracts.json`,
`content/events/callback_events_7.json`,
`content/events_en/callback_events_7.json`,
`content/events/callback_events_10.json`,
`content/events_en/callback_events_10.json`,
`content/events/callback_events_24.json`,
`content/events_en/callback_events_24.json`, `scenes/ArubaGame.gd`,
`scenes/JobHuntMiniGame.gd`, `tools/CGRuntimeCheck.gd`,
`tools/speech_register_audit.py`.
첫 만남 선택 기억이 이후 사건의 실제 문장으로 소비되는지 잠그고, 대체된
짧은 콜백만 억제하되 장기 경찰 추적은 보존한다. 미니게임 결과 화면은
기본 효과를 포함한 실제 돈·몸·마음 변화만 말한다. 1~12주에 재사용되는
본문·결과·회고에서 발신자, 현금 전달 방식, 현재 잔고, 장소와 자연스러운
한국어를 맞추며 새 경제 보상이나 관계 단계는 만들지 않는다.

**휴대폰 허브 정본·첫 구현 착수 (2026-07-29 Codex) — 추가로 만지는
파일:** `docs/CODEX_QUEUE.md`, `docs/queue_active/ORDER-57.md`,
`docs/CORE_LOOP_V2.md`, `docs/DECISIONS.md`, `docs/BALANCE.md`,
`docs/QA_CHECKLIST.md`, `docs/WORK_LOG.md`, `CLAUDE.md`,
`content/meta/demo_core_loop_v2.json`, `content/events/life_events.json`,
`content/events_en/life_events.json`, `autoloads/GameState.gd`,
`autoloads/ControllerHints.gd`, 신규 `systems/PhoneSystem.gd`,
`scenes/CoreLoopPlanner.gd`, `scenes/MainGame.gd`,
`tools/demo_core_loop_v2_audit.py`, `tools/CoreLoopV2Check.gd`,
`tools/ScreenshotQA.gd`, `tools/audit.sh`, `locale/ui_ja.json`.
사용자가 날짜·잔액·투자·도박·인물 전화와 기기 구매를 GTA식 실제 폰
UI의 앱으로 묶고, 장기적으로 기기 등급별 미니게임을 확장하라고 지시했다.
기존 플래너의 공개 API와 네 주 계획 계약은 보존하되, 현재 장소 위에서
세로→가로로 돌아오는 기기별 실물 폰 셸·상태바·4열 홈·앱 스택·채팅
말풍선·하단 제스처 바로 바꾼다.

첫 구현은 시작폰과 13주 이후 리퍼폰, 메시지·일정·연락처·은행·기기 앱,
정확한 날짜, 홈·은행의 실제 잔액, 구매 후 잔액, 저장 이관과 의미 입력을 소유한다. 시작폰도
모든 필수 정보·연락·접근성을 제공한다. 투자와 도박은 각각 실제 금융
온보딩과 장소 발견 뒤에만 나타나며, 기존 AP 연락·투자·도박 함수를 곧바로
재사용하지 않는다. 집중 매매와 도박은 앞으로 명시적 전경 약속 실행기가
소유하고, 기기 등급은 수익률·승률·관계 보상·필수 서사를 바꾸지 않는다.
등급별 게임 앱은 계약만 잠그고 C~F의 핵심 인과보다 앞서 제작하지 않는다.
중급폰·플래그십은 계획 데이터와 독립 외형을 보존하되 약속한 편의 기능이
완성될 때까지 전체판에서도 상점 노출·결제를 막는다.
수리비·새 기기 가격을 말하면서 다른 현금 효과를 적용하던 기존 폰 파손
사건은 같은 기기 수리 선택으로 다시 쓰고 한영 산문과 실제 효과를 맞춘다.
월세 사건은 65만원 월말 정산과 중복 차감하지 않는 알림으로 고친다.
`runtime_default=false`, `finish_run`, 25~240주 편성·엔딩과 사용자 소유
`project.godot`은 유지한다.

**선택지 대화 기록 범위 확장 (2026-07-29 Codex) — 추가로 만지는 파일:**
`scenes/StoryMode.gd`, `tools/StoryDialogueHistoryCheck.gd`,
`tools/StoryDialogueHistoryCheck.tscn`, `tools/ManualSaveCheck.gd`,
`tools/ScreenshotQA.gd`, `tools/audit.sh`, `locale/ui_ja.json`,
`docs/CORE_LOOP_V2.md`, `docs/DECISIONS.md`, `docs/QA_CHECKLIST.md`,
`docs/WORK_LOG.md`, `CLAUDE.md`.
사용자는 선택지를 고르기 전에 같은 대화에서 앞서 주고받은 내용을 다시
볼 수 있는 별도 로그 버튼을 요구했다. 이 기능은 편의가 아니라 정보에
근거한 선택의 공정성 계약으로 본다. 현재 StoryMode 세션에서 실제로 본
본문·내레이션, 확정한 선택, 결과만 기록하고 미선택·잠긴 선택지와 미래
문장·숨은 수치는 제외한다. 타이핑 중에는 보인 부분만 임시 표시하고,
즉시 후속과 같은 큐에서는 유지하되 새 StoryMode 방문에서는 비운다.

기록 모달은 타이핑·AUTO·장면 홀드·선택 타이머를 멈추며 닫을 때 같은
선택지 포커스와 남은 시간을 복원한다. 저장은 전역 상태가 아니라
StoryMode resume의 중첩 schema로 왕복해 48주 1장과 240주 전체판에도
같은 규칙을 적용한다. 한 문단 안에 대사와 서술이 섞인 기존 원고에는
화자를 발명하지 않고 당시 장면 제목·이름표·통신 맥락과 실제 표시 문자열을
`장면 정보`로 보존한다. 실제 대괄호 문구는 허용 BBCode 태그와 구별하며,
저장 위치는 원문 문단 안의 진행률로 복원해 글자 크기·언어·해상도 변화가
미래 문장을 열지 못하게 한다. 언어별 원문 문단 수가 다르면 현재 단계의
첫 원문으로 되감아 미래 문장을 추정하지 않는다. 기능 도입 전 v4 저장에는
이전 기록을 복원할 수 없다는 안내를 남긴다. `project.godot`, 관계·경제
정본과 기본 전환은 바꾸지 않는다.

**C 13~16주 선제 추적·돈 인물 착수 (2026-07-30 Codex) — 추가로 만지는
파일:** `docs/CODEX_QUEUE.md`, `docs/queue_active/ORDER-57.md`,
`docs/CORE_LOOP_V2.md`, `docs/STORY_BIBLE.md`, `docs/DECISIONS.md`,
`docs/BALANCE.md`, `docs/QA_CHECKLIST.md`, `docs/WORK_LOG.md`,
`docs/history/WORK_LOG_2026-07-25.md`, `CLAUDE.md`,
`content/meta/demo_core_loop_v2.json`, `content/meta/narrative_spine.json`,
`content/meta/story_rules.json`, `content/events/core_loop_v2_events.json`,
`content/events_en/core_loop_v2_events.json`,
`assets/event_visual_contracts.json`, `assets/scene_audio_manifest.json`,
`assets/scene_direction_manifest.json`, `assets/ui/phone/README.md`,
`assets/ui/phone/phone_frame_starter.png`, `systems/DemoCoreLoopV2.gd`,
`scenes/CoreLoopPlanner.gd`, `scenes/StartMenu.gd`,
`tools/demo_core_loop_v2_audit.py`, `tools/core_loop_v2_balance_sim.py`,
`tools/CoreLoopV2Check.gd`, `tools/CoreLoopV2BCheck.gd`,
신규 `tools/CoreLoopV2CCheck.gd`,
신규 `tools/CoreLoopV2CCheck.gd.uid`,
신규 `tools/CoreLoopV2CCheck.tscn`, `tools/ScreenshotQA.gd`,
`tools/audit.sh`, `locale/ui_ja.json`.
13~16주는 한빛유통 지원서의 실제 면접, 다은/지연의 선택별 한 단계 관계
전이, 상철의 주거 탐색 입구와 재혁의 10년 만 카카오톡 입구를 연다.
다은·상철·교육·검진처럼 플레이어가 직접 찾아가는 행동은 받은 문자로
위장하지 않고 `내 일정/메모`, 지연의 우연한 재회는 `이동 중 사건`,
한빛·재혁의 실제 수신만 `메시지`로 구분한다. 만난 사람, 이름을 아는 사람,
연락수단 보유자를 분리해 이름과 전화 버튼을 선취하지 않는다.

관계는 한 달에 한 단계만 오르고, C에서는 `romantic_intent/date`, 채용,
투자 권유와 돈 인물의 진실을 열지 않는다. 상철은 4월 전용 V2 입구를,
재혁은 답장까지만 사용해 기존 48주 1장과 240주 후속을 보존한다.
한빛 면접은 `submitted → interviewed`만 수행한다. 합법 생계가 더러운 돈의
유일한 대안이 되지 않도록 13~16주 경제 밴드를 시뮬레이션으로 잠근다.
후속 사건은 진입 root에서 도달 가능한 terminal을 인정해 큐 중복 재생을
차단한다. 내부 개발 상한만 16주로 늘리고 `runtime_default=false`,
`finish_run`, 17~240주, 엔딩과 사용자 소유 `project.godot`은 유지한다.

**D 17~20주 기다림·네 의무 충돌 착수 (2026-07-30 Codex) — 추가로 만지는
파일:** `docs/CODEX_QUEUE.md`, `docs/queue_active/ORDER-57.md`,
`docs/CORE_LOOP_V2.md`, `docs/STORY_BIBLE.md`, `docs/DECISIONS.md`,
`docs/BALANCE.md`, `docs/QA_CHECKLIST.md`, `docs/WORK_LOG.md`, `CLAUDE.md`,
`content/meta/demo_core_loop_v2.json`, `content/meta/narrative_spine.json`,
`content/meta/story_rules.json`, `content/events/core_loop_v2_events.json`,
`content/events_en/core_loop_v2_events.json`, `content/events/arc_events.json`,
`content/events_en/arc_events.json`, `assets/event_visual_contracts.json`,
`assets/scene_audio_manifest.json`, `assets/scene_direction_manifest.json`,
`systems/DemoCoreLoopV2.gd`, `scenes/CoreLoopPlanner.gd`,
`scenes/StartMenu.gd`, `tools/demo_core_loop_v2_audit.py`,
`tools/core_loop_v2_balance_sim.py`, `tools/event_director_audit.py`,
`tools/audit.py`,
`tools/CoreLoopV2Check.gd`, `tools/CoreLoopV2BCheck.gd`,
`tools/CoreLoopV2CCheck.gd`, 신규 `tools/CoreLoopV2DCheck.gd`,
신규 `tools/CoreLoopV2DCheck.gd.uid`, 신규 `tools/CoreLoopV2DCheck.tscn`,
`tools/ScreenshotQA.gd`, `tools/audit.sh`, `locale/ui_ja.json`.
**D 출시 후보 정합성 보강 (2026-07-30 Codex) — 추가 범위:**
`autoloads/GameState.gd`, `autoloads/DataRegistry.gd`, `scenes/MainGame.gd`,
`tools/mod_pack_validator.py`. 17주 채용의 실제 근무 주수만 첫 급여에
반영하고, 한빛유통 직무명이 일반 직업명으로 덮이지 않게 하며, 월말에는
놓친 제안명만 정리하고 구체적인 결과는 다음 달 휴대폰 기록에서 한 번만
보여 준다. 조건부 채용 문자는 달력 제안으로 승격하지 않고 메시지 앱의
수신 기록으로만 합친다.
**D 생성 원장 문서 정합성 보강 (2026-07-30 Codex) — 추가 범위:**
`docs/MASTER_RELEASE_AUDIT.md`, `docs/SCENE_DIRECTION.md`. D 사건 여섯 개가
추가된 뒤 실제 오디오·장면 방향 카탈로그 수와 유효한 검사 명령을 현재
출시 감사 문서에 맞춘다.
다섯 번째 달은 선택한 관계 한 갈래와 상철/재혁 중 실제로 연 돈 갈래만
각각 한 단계 이어 간다. 같은 달에는 도시시설 계약직 지원, 이삿짐 대타,
실무 수업, 회복 또는 상담도 경쟁시켜 사람 장면을 전부 고르면 생계가,
생계만 고르면 기다리게 한 사람이 남도록 한다. 관계 단계는 정확히 한 칸만
전진하며 연애·투자 권유·사기 진실·30억원 동기를 선취하지 않는다.

3~4개월의 미선택 제안은 다음 달 휴대폰 `SYSTEM RECORDS`에서 실제 마감,
비용, 채워진 자리로 한 번 회수한다. 20주차는 실제 선행 영수증이 있는
관계·돈 인물 후속을 같은 배타 자리에서 고르게 하고, 선택한 사람·생계·
성장 결과를 24주 정점 후보까지 보존한다. 기존 장편의 공통 아버지 건강
신호는 앞당기지 않고 21주의 비슬롯 전주곡으로 유지한다. 지원서는 제출
상태와 다음 달 결과 계약을 함께 만들며, 결정론 원장은 1~20주 합법 생존
경로와 대타를 포기한 체납 경로를 모두 보여 준다.
개발 상한만 20주로 늘리고 `runtime_default=false`, `finish_run`,
21~240주, 기존 48주·5년 인과, 엔딩과 사용자 소유 `project.godot`은
유지한다.

## 목적

- 기존 5년·240주 콘텐츠와 저장 정본은 파괴하지 않는다.
- 데모 24주만 먼저 `월초 계획 → 연락·기회 확인 → 4주 약속 배치 →
  선택 장면 플레이 → 놓친 길 회수 → 월말 변화`로 재구성한다.
- 주간 시간은 경제·조건 계산 단위로 유지하되, 플레이어에게 같은 AP 허브를
  24회 반복시키지 않는다.
- 휴대폰은 장식 메뉴가 아니라 플레이어의 의도와 먼저 건 연락을 기록하는
  메시지·일정·인연·기록 표면이 된다.
- 관계는 호감도 임계치만으로 진전하지 않는다. 다시 연락할 이유, 플레이어의
  선제 연락, 공동 약속, 충돌, 회복/회피, 상대의 선제 연락을 단계 계약으로 둔다.
- 도박은 발견 뒤 본편 일정 비용을 내는 별도 여가 진입점으로 분리하되,
  시간 없는 무제한 경제 행동으로 만들지 않는다.

## 단계

1. **규칙서·24주 편성:** 월간 계획, 놓친 길, 관계 주도권과 6개월
   생존→인연→돈의 문→충돌을 정본·기계 데이터로 소유한다. 완료.
2. **8주 구조 프로토타입:** 기존판을 폴백으로 남기고 월간 계획·저장·기본
   인과를 별도 런타임에 연결한다. AUTO PASS, 사람 NO-GO.
3. **A0 8주 세션 수리:** 명시적 종료·회고, 이름 있는 포기 확인,
   720p·실제 패드 과업을 닫는다. AUTO PASS.
4. **A1 8주 루프 완결:** 배경 루틴, 실제 `forgone` 소비자, 월말 회수,
   기한, 선택 결과 기반 관계 단계와 합법 경제 경로를 연결한다. AUTO PASS.
5. **B 9~12주:** 다은/지연 생활 동선 입구를 열되 연애 GO는 판정하지 않는다.
   AUTO PASS.
6. **C 13~16주:** 선택한 인연 추적, 상철/재혁 입구, 직업·성장 행동을 연다.
   휴대폰 허브까지 연결했다. AUTO PASS.
7. **D 17~20주:** 관계·돈·취업·생계의 실제 충돌과 놓친 길 회수를 연다.
   AUTO PASS.
8. **E 21~24주:** 신규 `첫 청구서` 정점과 6개월 회고·데모 CTA를 완성한다.
9. **F 통합:** 정상 독해 75~95분·18~22장면·KO/EN·실제 패드·저장·A/V·사람 GO 뒤
   일반 새 이야기를 V2로 전환한다.
10. **5년 보존:** 데모 통합 GO 전에는 주 25~240과 엔딩을 이식하지 않는다.

## 24주 작업 묶음과 소유권

| 묶음 | 주 소유 파일 | 완료 증거 |
|---|---|---|
| A0 세션 경계 | `DemoCoreLoopV2.gd`, `MainGame.gd`, `CoreLoopPlanner.gd` | 8주 뒤 구편성 진입 0, KO/EN 회고, 720p 실제 경계 |
| A1 상태·경제 | `GameState.gd`, `DemoCoreLoopV2.gd`, `demo_core_loop_v2.json` | 배경 루틴 8주 계산, 포기 생산자/소비자 1:1, 합법 경로 회귀 |
| 데이터 스키마 | `demo_core_loop_v2.json`, `demo_core_loop_v2_audit.py` | 모든 슬롯 카드의 한영 8필드, 허용 주차, typed prerequisite, 실행 표면 |
| B~E 월별 콘텐츠 | 대상 `content/events*`, `story_rules.json`, 시각·오디오 계약 | 해당 4주 경로 행렬·장면 전환·KO/EN·선택 결과 |
| 휴대폰·입력 | `CoreLoopPlanner.gd`, `ScreenshotQA.gd`, 입력 검사 | 실제 South/East/LB/RB 경로, 960×600~1080p 안전영역 |
| 통합·전환 | `StartMenu.gd`, `BuildInfo.gd`, 전체 QA | 24주 블랙박스와 사람 GO 뒤에만 기본 전환 |

한 묶음의 상태 엔진과 UI를 여러 에이전트가 동시에 수정하지 않는다. 월별
콘텐츠도 먼저 기계 계약과 prerequisite를 고정한 뒤 KR 원문→EN 오버레이→
story/visual/audio 계약 순서로 연결한다.

월 3~6의 V2 전용 산문은 기존 240주 사건의 후속과 시간을 훼손하지 않도록
향후 `content/events/core_loop_v2_events.json`과 같은 격리된 KR 원문 및
동명 EN 오버레이에 두는 것을 기본안으로 한다. 실제 파일 추가는 각 월 묶음의
별도 범위 선언에서 확정한다.

### 단계별 통과 기준

| 단계 | 게임 범위 | 자동 증거 | 사람 판정과 중지 조건 |
|---|---:|---|---|
| A0·A1 | 1~8주 | 9주 기존판 낙하 0, 종료 저장 왕복, KO/EN 720p 경계, 실제 South/East 검토, 기한 강제, 포기 생산자·소비자 1:1 | 5명 중 4명 이상이 자기 계획과 포기 하나를 말한다. P0 오류가 있으면 9주 구현을 열지 않는다. |
| B | 9~12주 | 다은/지연 동시 입구 선택 0, 생활 동선 없는 첫 만남 0, 첫 만남 결과별 다음 카드 차이, 월 주연 최대 셋 | 첫 만남까지만 검증한다. 아직 연애 GO를 선언하지 않는다. |
| C | 13~16주 | 선제 행동 없는 후속 0, 닫은 연락 뒤 추적 0, 관계 단계 역행 0, `romantic_intent/date` 자동 진입 0 | 관계 마이크로 슬라이스 5명 중 4명 이상이 “내가 다시 연락했다”고 말하고, 자동 데이트로 읽은 응답이 0이어야 한다. 실패하면 17주를 열지 않는다. |
| D | 17~20주 | 선택하지 않은 인연·돈 인물 재등장 0, 동일 root 중복 0, 월 주연 최대 넷, 20주 실제 선택 영수증 보존, 21주 아버지 신호 조기 실행 0 | 5명 중 4명 이상이 기다리게 한 사람 또는 놓친 기회 하나를 기억한다. 실패하면 피날레를 열지 않는다. |
| E·F | 21~24주 | 대표 네 경로 완주, 주요 장면 18~22개, 월말 6회, 25주 진입 0, 4·8·12·20·23주 저장 왕복, CTA 도달 | 동일 RC 10명에서 구체 계획·포기 기억 7/10 이상, 노출자 중 선제 연락 인지 70% 이상, 다음 달 의향 과반, P0 0. 실패하면 기본 전환 금지다. |

`runtime_default`는 위 전 단계에서 false다. 내부 상한만 검증이 끝날 때마다
`8 → 12 → 16 → 20 → 24`로 늘리고, 마지막 사용자 GO 뒤 일반 새 이야기의
신규 런만 별도 단독 커밋으로 전환한다. 기존 저장 자동 변환과 25~240주 이식은
이번 오더에 포함하지 않는다.

### 9~24주를 열기 전 데이터 차단 조건

- 모든 슬롯 소비 bundle은 `offer/detail/deadline/decline` KO/EN을 가진다.
- 기한은 산문 문자열뿐 아니라 배치 가능한 주차로 검증된다.
- 자유 형식 `eligibility`는 런타임이 읽는 typed prerequisite로 치환한다.
- 관계 전이는 bundle 공통값이 아니라 선택 결과별 전이를 가진다.
- `decline_consequence`마다 실제 소비자 ID와 발화 창이 있다.
- `planned_scene_id`는 실제 사건 또는 전용 실행 표면으로 해석된다.
- `variants`는 현재 상태에서 정확히 한 변형을 고르며 대안 root를 연속 재생하지 않는다.
- 신규 플래그는 생산자와 독자를 같은 묶음에서 추가한다.

### 단계별 중지 기준

- 앞 단계에서 write-only 플래그, 실행 불가 bundle, 잘못된 관계 선행조건,
  화면 밖 CTA, 기존판 낙하 중 하나라도 남으면 다음 4주를 열지 않는다.
- 자동 완주는 도달성 증거다. 정상 속도 사람이 포기·주도권·다음 달 의사를
  기억하지 못하면 카피를 늘리는 대신 해당 월의 선택과 회수 구조를 다시 고친다.
- `runtime_default`는 F 통합 전까지 false다. 개발 플래그에서도 완료된 마지막
  단계에서 명시적 중간 회고로 멈추며 미완성 다음 달을 보여 주지 않는다.

## 불변·금지

- `moral_tint`, 호감도 숫자, 미래 연애 루트, 정답 선택을 플레이어에게
  해설하지 않는다.
- 플레이타임을 클릭·짧은 사건·AP 수로 부풀리지 않는다.
- 휴대폰 안에서 장면을 끝내지 않는다. 약속은 실제 장소·초상·CG·오디오가
  있는 장면으로 전환한다.
- 반복 전화·선물·휴식으로 관계나 생존이 무한 상승하지 않는다.
- 신규 재화·복잡한 앱 묶음·별도 도감은 추가하지 않는다.
- 현재 전체판의 엔딩 ID, 저장 호환, 30억원 전제는 8주 프로토타입에서
  변경하지 않는다.

## 자동 게이트

- 24주 데이터가 정확히 6개월·24주를 소유한다.
- 월마다 선택 가능한 약속 3개 이상, 실제 슬롯 4개, 만료 또는 놓친 길 1개 이상.
- 첫 실행의 동시 활성 주요 인물은 최대 4명.
- 다은·지연 관계 단계는 플레이어 선제 연락 없이 데이트 단계로 진입하지 않는다.
- 사건과 UI의 KO/EN 패리티, 패드 South/East 의미 입력, 저장 직렬화를 보존한다.
- `context_manifest_check`, 전체 audit, EN 커버리지, 한글 누출 0,
  `git diff --check`를 통과한다.

## 사람 게이트

- 10분 뒤 플레이어가 이번 달 자기 계획을 한 문장으로 말할 수 있다.
- 30분 뒤 먼저 연락한 인물과 포기한 기회를 각각 하나 기억한다.
- 관계 진전이 “게임이 자동으로 붙여 줬다”가 아니라 자기 선택으로 느껴진다.
- 반복 휴식·반복 전화가 명백한 우세 전략으로 읽히지 않는다.
- 데모 종료 시 다음 달을 보고 싶다는 의사가 있다.

## 진행 기록

### 2026-07-27 — 1·2단계 설계 계약 PASS

- `CORE_LOOP_V2.md`에 월간 계획, 휴대폰, 놓친 길, 관계 주도권, 몸·마음,
  직업·투자·도박 규칙을 고정했다.
- `demo_core_loop_v2.json`은 1~24주, 6개월, 월 네 슬롯, 월 5~7제안,
  최대 한 잠금, 주요 인물 최대 넷, 목표 95분, 28장면 번들을 소유한다.
- 새 감사는 기존 사건 뿌리 존재, 월 연속성, 관계 선제 행동, 제안별 포기
  결과, 숨은 AP·호감도·도덕 수치 비노출을 검사하며 PASS다.
- 기존 AP·Decision/Echo/Quiet 전체판은 삭제하지 않고 개발 폴백으로
  남겼다. 다음은 별도 범위 선언 뒤 1~8주 수직 단면을 구현한다.

### 2026-07-27 — 3단계 1~8주 런타임 수직 단면 AUTO PASS

- 명시적 `--core-loop-v2` 개발 런에만 휴대폰·월간 달력을 연결했다.
  일반 새 게임은 계속 기존 240주 편성기로 시작하며, 저장에는
  `core_loop_v2_state` 한 필드만 역호환 추가했다.
- 월 5~7개 제안에서 네 주를 배치하고, 4주차 고정 보스, 배치 충돌,
  포기 원장, 월 경계를 넘는 지연 회수와 주당 회수 한 건을 런타임 상태로
  잠갔다. 지원하지 않은 회사의 연락은 오지 않으며 현수는 첫 만남 뒤
  플레이어가 먼저 잡은 약속으로만 다음 장면에 들어간다.
- 지원·이력서·면접·회복·부업은 실제 기존 장면 또는 미니게임으로
  전환한다. V2 결과 화면에는 기존 AP 계산표, `남은 웨이브`,
  호감도·도덕 숫자를 노출하지 않는다.
- KO/EN 1280×720 실제 `MainGame` 렌더에서 메시지·일정·인연·기록,
  네 슬롯, 무스크롤, 키보드·패드 포커스와 첫 지원 장면 진입을 확인했다.
  상태·저장·컴파일 자동 게이트도 PASS다.
- **4단계 사람 GO는 OPEN이다.** 정상 속도 8주 플레이에서 계획 소유감,
  기억되는 포기, 먼저 다가간 인물, 다음 달 의사를 확인하기 전에는
  `runtime_default`를 켜거나 9~24주 런타임으로 확장하지 않는다.

### 2026-07-27 — 사람 테스트 진입·빌드 식별 AUTO PASS

- DEBUG 시작 화면에서만 `Core Loop V2 · 8주 테스트`를 고를 수 있다.
  일반 `새 이야기`는 V2 상태를 켜지 않으며 기존판 기본 계약을 유지한다.
- `BuildInfo.gd` 한 곳이 `v0.1.0-dev / BUILD 2026.07.27.1`을 소유한다.
  시작 화면과 실행창 제목이 이를 표시하고, V2 런은 창 제목에
  `CORE LOOP V2`를 덧붙인다.
- KO/EN 1280×720 실제 렌더, 일본어 UI 키, 시작 30초와 전체 감사를 통과했다.
  **4단계 정상 속도 사람 GO는 계속 OPEN이다.**

### 2026-07-29 — 24주 계획·A0 세션 경계 AUTO PASS

- 실제 데모 범위를 24주로 재확인하고 `8 → 12 → 16 → 20 → 24주`의
  단계별 산출물·자동 증거·사람 중지 조건을 고정했다. 관계 판정은 첫 만남만
  있는 12주가 아니라 플레이어 선제 연락까지 있는 16주에 수행한다.
- 8주차 월말 경제 정산 뒤 저장 가능한 완료 마커를 남긴다. 9주차 기존
  디렉터는 시작하지 않으며, 불러오기 뒤에도 지킨 약속·닫힌 제안·현금·
  몸·마음·선제 연락·대포통장 분기를 읽는 KO/EN 회고로 돌아온다.
- 메시지 6~7개를 1280×720 두 열에 수용하고, 계획 확정 전에 네 주의 실제
  약속명과 미선택 제안명을 다시 확인한다. 첫 South는 검토, East는 일정
  보존 편집 복귀, 두 번째 South만 계획 확정이다.
- `CoreLoopV2Check`, KO/EN `ScreenshotQA --qa=core-loop-v2`,
  컨텍스트·영어 누출·diff 표적 검사와 전체 감사는 PASS다. `finish_run`, 본편 엔딩,
  `runtime_default=false`, 사용자 소유 `project.godot`은 유지했다.
- **A1은 OPEN이다.** 이름을 보여 주는 것만으로 실제 포기 결과를 구현했다고
  판정하지 않는다. 배경 루틴, 포기 생산자/소비자 1:1, 기계 기한, 선택 결과
  기반 관계 단계, 합법 생계·취업과 월말 회수가 닫히기 전 9주를 열지 않는다.

### 2026-07-29 — A1 1~8주 공통 루프 AUTO PASS

- 월마다 서로 다른 주/보조 루틴을 고르고, 이야기·행동·결과 장면과 무관하게
  매주 두 단위, 8주 총 16단위를 정확히 한 번 적용한다. 월중 취업은 런을
  무효화하지 않고 본업과 원래 주 루틴 하나로 즉시 전환한다.
- 1~8주 카드 14종의 기한을 `allowed_weeks`로 기계화했다. 선택 가능한
  미선택 제안의 결과 13종은 다음 달 메시지·상태 효과·최종 회고 소비자를
  가지며, 계획 중복 커밋과 결과 중복 소비를 차단했다.
- 관계는 bundle 완료로 움직이지 않는다. 실제 선택 결과만 11단계 안에서
  단조 전이하고, 현수의 두 번째 만남은 민준이 먼저 카카오톡 메시지를
  보낸 뒤 공용 주방의 실제 약속으로 이어지는 V2 전용 한영 장면이다.
  원격 문단에는 현수 초상을 보이지 않는다.
- 월말 수첩은 현금·고정비·몸·마음·지킨 약속·놓친 제안·루틴·다음 경제
  한 단을 저장하고 확인 전에는 다음 달을 열지 않는다. 합법 회복형과
  성장형의 보수적 8주 원장은 각각 6만원을 남기며, 더러운 돈은 빠르지만
  기존 정신·Moral Tint·후속 비용을 유지한다.
- 정적 스키마, 밸런스 원장, 상태·저장·선택·입력 런타임, KO/EN 720p,
  사건·시각·오디오·장면 연출 원장, 일본어 UI와 전체 감사가 PASS다.
  CG 문단 검사는 화면 페이지가 아니라 원문 문단 인덱스를 따라 결정론적으로
  진행한다. `runtime_default=false`, `finish_run`, 25~240주, 사용자 소유
  `project.godot`은 유지했다.
- **사람 게이트는 OPEN이다.** 정상 속도 기억·재미·물리 패드 판정을
  통과했다고 주장하지 않는다. 사용자의 계속 개발 지시에 따라 다음은
  개발 상한만 12주로 늘리는 B 묶음이며 일반 새 이야기 전환은 계속 금지다.

### 2026-07-29 — B 1~12주 관계 입구·원자 저장 AUTO PASS

- 세 번째 달의 고유 행동, 기계 기한, 실제 포기 소비자와 typed 선행조건을
  연결했다. 생활 동선이 있어야 다은 또는 지연의 첫 만남이 열리고, 둘 다
  자격이 있어도 같은 달에는 최대 하나만 계획한다. 아버지·현수 후속도
  실제 첫 연락, 관계 단계, 선택 기억과 플레이어 주도권을 다시 읽는다.
- 첫 만남 선택은 `from→to`, 주도권, 기억 영수증을 남기며 구버전 저장에도
  같은 결과를 한 번만 복원한다. 관계 기억은 인연 탭의 실제 과거 문장으로
  소비되고, 대체된 짧은 콜백만 억제하되 24주 경찰 추적 같은 장기 결과는
  보존한다.
- 지원서는 미래산업기술 `제출→면접→불합격`, 서린물산
  `제출→불합격`으로 실제 결과 장면과 연결했다. 한빛유통의 `제출`은
  13~16주 면접 계약이 소비하며, 완성 전에는 12주 표면에 결과를 발명하지
  않는다.
- 행동 AP·효과·플래그·지원 상태·축·주차는 한 트랜잭션으로 처리한다.
  결과 화면과 진행 중 미니게임 저장은 재적용 없이 복원하고 실패 시 전부
  되돌린다. 월간 증감은 결산 직전이 아니라 월초 계획 확정 시점부터 계산해
  네 주의 행동·루틴·고정비를 모두 포함한다.
- 8만원 자전거 수리, 현금 200만원·150만원 반환·보관함 현금 300만원,
  체납 31만원·합법 재고조사 뒤 5만원을 장면·회고·시뮬레이터에서 맞췄다.
  `닫힌 문`, `통장을 닫았다`, 고정 잔고, 발신자 혼동 같은 1~12주 표면을
  실제 행동과 금융 용어로 바꿨다.
- 정적 인과·장편 콜백·밸런스, A/B 저장 런타임, 1,570사건 한영 패리티,
  CG·초상·장면·오디오와 240주 장기 회귀를 포함한 전체 감사가 PASS다.
  `runtime_default=false`, `finish_run`, 13~240주와 사용자 소유
  `project.godot`은 유지했다. 정상 속도 첫 만남 기억·재미 사람 게이트와
  물리 패드 판정은 OPEN이다.

### 2026-07-30 — C 1~16주 선제 추적·돈 인물 입구 AUTO PASS

- 한빛유통은 실제 제출 상태에서만 면접이 열리고
  `submitted → interviewed/not_attended`를 한 번 기록한다. 다은은 첫 만남의
  이름 공개·거리 두기 선택에 따라 다른 직접 재방문을 쓴다. 지연은
  연락처 없이 버스정류장에서 우연히 다시 만나며, 지연이 먼저 자전거
  안부와 이름을 건네거나 민준이 먼저 사고 이야기를 꺼낸다. 같은 인물의
  관계 단계는 한 달에 한 번만 오른다.
- 상철은 카페 옆자리에서 들은 재개발 입주권 통화, 재혁은 앞선 SNS
  압박이라는 서로 다른 root에서만 열린다. 방 시세 탐색은 상철의 선행이
  아니라 C의 첫 대면 행동이다. C에서는 첫 대화·카카오톡 답장까지만
  사용하고 투자 권유, 30억원 동기, 기존 48주·240주 진실 장면을
  선취하지 않는다. 두 입구는 같은 실행에서 동시에 전경 주연이 되지 않는다.
- 네 번째 달은 성긴 상태에서 정확히 5개, 선행 선택이 풍부한 상태에서
  7개 제안을 가진다. 자격증 수업·물류 대타·검진·회복·주거복지 상담은
  고유 기한과 원자 실행·저장 영수증을 가진다. 부업 없는 16주 체납
  68만원, 늦은 물류 대타만 고른 체납 16만원, 두 합법 대타 뒤 현금
  20만원과 리퍼폰 구매 뒤 2만원을 결정론 원장으로 잠갔다.
- 실제 수신 메시지와 통화 기록만 사람 연락으로 표시한다. 직접 방문 일정과
  개인 메모, 미선택 결과는 일정·`SYSTEM RECORDS`로 분리했다. 시작폰은
  최신형처럼 보이던 얇은 베젤 대신 2017년형 중고 보급폰의 넓은 플라스틱
  베젤·수화부·작동하는 세 버튼 내비게이션을 사용하고, 리퍼폰·플래그십의
  금속 셸·제스처 바와 구분한다.
- A/B/C 저장 런타임, 1,575사건 한영·서사·장면·시각·오디오 계약,
  240주 대표 오디오 경로, KO/EN 1280×720·960×600 실제 폰 렌더와
  전체 감사가 PASS다. 16주 결산은 저장 뒤 17주 기존 편성기로 떨어지지
  않는다. `runtime_default=false`, `finish_run`, 17~240주, 엔딩과 사용자
  소유 `project.godot`은 유지했다.
- **사람 게이트는 OPEN이다.** 정상 속도 선제 행동 기억·관계 애착·재미와
  물리 패드 판정을 자동 통과로 주장하지 않는다. 다음 개발 상한은 D
  17~20주이며, 놓친 길 회수와 사람·생계 충돌이 완성되기 전 21주를
  열지 않는다. 공통 아버지 건강 신호는 E 소유 21주에 유지한다.

### 2026-07-30 — D 1~20주 기다림·충돌 AUTO PASS

- 다섯 번째 달은 항상 열리는 실용 제안 5개와 실제 선행 영수증이 있는
  관계·돈 인물 후속을 각각 최대 하나 더해 5~7개를 유지한다. 다은·지연·
  상철·재혁 후속은 이전 선택, 연락 수단, 인접 관계 단계만 읽고 모두
  20주 `month_five_person_climax` 한 자리를 경쟁한다. 연애·투자 권유·
  사기 진실·상철 정체와 기존 48주·240주 후속은 열지 않았다.
- 한빛유통은 제출과 면접을 마친 경로에만 17주 화요일 채용 문자를 보낸다.
  수락은 실제 `job_03`을 주되 18~20주 첫 급여는 168만원, 다음 온전한
  달은 224만원이다. 선택 뒤에도 실제 수신 영수증은 메시지함에 남고
  캘린더 약속으로 섞이지 않는다. 같은 주 도시시설 지원은 금요일 오후
  6시까지 열어 순서를 맞췄고 그 결과는 E로 미뤘다.
- 이삿짐은 선택한 주 나흘 연속, 전산반은 선택한 주 월~목 저녁 집중
  일정으로 같은 주 안에서 끝난다. 20주 원장은 무부업 체납 105만원,
  4·5개월 대타 3만원, 세 번 대타 39만원, 앞선 두 대타+한빛 취업
  130만원과 리퍼폰 뒤 112만원을 결정론적으로 잠갔다.
- A/B/C/D 상태·선택·원자 저장, 한영 제안·포기·메시지, 1,581사건의
  서사·시각·오디오·장면 계약, KO 960×600과 EN 1280×720 실제 폰 렌더,
  전체 감사를 통과했다. 20주 결산은 저장 뒤 21주 기존 편성기로
  떨어지지 않으며 `finish_run`을 호출하지 않는다.
- `father_health_signal`은 21주 비슬롯 전주곡으로 보존했다.
  `runtime_default=false`, 21~240주, 엔딩과 사용자 소유 `project.godot`은
  유지한다. 정상 속도 충돌 기억·재미·물리 패드 사람 게이트는 OPEN이고,
  다음 개발 상한은 E 21~24주 첫 청구서·6개월 회고다.
