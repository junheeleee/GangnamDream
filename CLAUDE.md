# CLAUDE.md — 강남드림 (Gangnam Dream)

> **세션 시작 시 이 파일을 가장 먼저 읽는다. 30초 안에 현재 상태를 파악하고 작업을 시작한다.**

---

## 🔴 현재 상태 (매 세션 종료 시 업데이트)

| 항목 | 내용 |
|---|---|
| **단계** | **Metacritic 90 목표 — 글쓰기 밀도·아크 완성도 강화 진행 중** |
| **최근 완료** | **2026-06-20** — (1) StoryMode 루트 기반 텍스트 변주 시스템: low_mental/long_gosiwon/orthodox/unorthodox 상황별 description_* 변형 표시. (2) 아크 8개 (arc_intro 4종 + sangchul/invest/jiyeon/father) 김민준 목소리 강화 + 대사 변주 추가. (3) audit.py EN/KR 조건 패리티 검사 #8 추가 + 98건 수정. (4) 신규 콘텐츠: 34세 씬 3개(arc_midgame), 건강×10+코미디×10(life_events), 현수 아크 6개(arc_hyunsu.json), 어머니 이벤트 3개(callback_events_28.json) + 전체 EN 번역. (5) GameState.apply_effects에 route_orthodox/route_unorthodox 키 추가. (6) cast_stages.json 현수 단계 확장 (10개). (7) Codex 외형 패스: StoryMode `GameState.get(..., default)` 컴파일 오류 수정, 룰렛/빅휠/블랙잭을 카지노 배경+중앙 테이블/기기 프레임으로 재배치. (8) 정선 카지노 신규 미니게임 다이사이 추가: 순수 룰 모델, 중앙 테이블 UI, 튜토리얼, 메타 칭호, ScreenshotQA 캡처 연동. audit ERROR 0 / WARNING 0. |
| **이전** | **2026-06-20** — Codex 12개 커밋 병합: 미니게임 풀스크린/칩UI/전용엔딩CG/오디오P1/BGM연속성/면접배경/초상화레이아웃 + 영문 번역 100% |
| **다음 작업** | **아크 글쓰기 계속** — arc_jaehyuk 시리즈 / arc_father_02-03 / arc_midgame 35~37세 씬 강화; 엔딩 전 씬(pre-ending) 1~2개; F급 엔딩 번아웃/정신붕괴/파산 차별화 |
| **마지막 업데이트** | 2026-06-20 (`audit.sh` OK, ScreenshotQA 재캡처 OK: 룰렛/빅휠/블랙잭/다이사이 외형 확인) |

**세션 시작 시 위 "다음 작업"부터 시작한다. 유저가 다른 지시를 하면 그쪽 우선.**

---

## ✅ 이번 세션 완료 목록 (2026-06-17, 컨텍스트 압축 대비)

### 후반18 (최신) — Steam 데모 품질 벤치마크 UI 폴리싱 11종

#### Disco Elysium 벤치마크 — 선택지 효과 미리보기
- `_choice_effects_preview()` 신규 함수: effects dict를 stress→mental 변환 후 이모지+부호 형식으로 압축
- `_reveal_choices()`: 버튼+미리보기 레이블을 VBoxContainer(sep=3)로 묶어 시각적 연관 명확화
- StoryMode에도 동일 패턴 추가 (`_choice_effect_preview()` + `_SM_STAT_EMOJI` 상수)

#### Citizen Sleeper 벤치마크 — 한눈에 읽히는 스탯
- `_set_stat_value()` 확장: 스킬류(지력/사회성 등) 5칸 미니바 표시 (max=80 기준)
- `_animate_ap_refill()`: AP 보충 시 0.12초 간격 순차 점등 (주사위 굴림 연상)

#### Balatro 벤치마크 — 배경 분위기 신호
- `_category_tint: ColorRect` 오버레이 추가 (MOUSE_FILTER_IGNORE)
- `_apply_category_tint()`: 이벤트 카테고리별 반투명 컬러 (재앙=빨강, 도박=골드, 투자=녹색 등)
- `_render_event()` 진입·복귀 시 틴트 적용/해제

#### Hades 벤치마크 — 활력 임박 경보
- `_pulse_vital_critical()`: ≤15 더블 플래시 (Hades 체력바 임박 플래시 참고)
- `_pulse_vital_warning()`: ≤30 단일 약한 페이드
- `_goal_time_lbl`: 남은 개월 ≤12=빨강·≤24=노랑·그외=회색

#### 기타 폴리싱
- `_show_vignette()` 스탯 효과: BBCode `[color]` 초록/빨강/금색 표시
- `_unhandled_input()`: `ui_accept`(Space/Enter) → 타이핑 스킵 (VN 표준)

### 후반16 (이전) — ArubaGame/표시 버그 2종 수정

#### ArubaGame health_delta 미전달 버그 (후반15)
- `ArubaGame.closed` signal에 `health_delta: int` 파라미터 누락 → 결과 화면에 건강 변동 표시되지만 실제 GameState에 미적용
- `signal closed(earned, stress_delta, health_delta)` 추가, `_on_aruba_closed` 수신측 업데이트
- DELIVERY 모드 배달 건수·CARDS 모드 선택지 건강 효과 이제 실제 적용됨

#### stress+mental 병합 덮어쓰기 표시 버그 (후반16)
- `_show_effects_float`, `_show_vignette`: effects dict에서 "stress"가 "mental"보다 앞에 오면 stress→mental 변환값이 덮어씌워지던 표시 버그 (858개 이벤트 선택지 영향)
- 두 함수 모두 "mental" 키 처리 시 누산 방식으로 변경 (GameState.apply_effects는 원래 올바름)
- 예: `{"stress":-3,"mental":1}` → 정신 +4 표시 (기존: +1)

### 후반10 (이전) — 데드코드 AP 비네팅 연결 + mental 누락 버그 수정

#### AP 비네팅 배열 연결 및 정리
- `_ap_study`: 4개 고정 씬 → STUDY_READ/EXERCISE/MEDITATE/INVEST_VIGNETTES 40개 씬 (10×4 풀)
- `_ap_network`: 5개 단순 텍스트 씬 → NETWORK_VIGNETTES 10개 (효과 다양화)
- SAVE_VIGNETTES / RESUME_VIGNETTES / INTERVIEW_VIGNETTES 데드 상수 삭제
- 네트워크 버튼 레이블 "사회성 +1" → "사교력+, 평판+ (정신력 소모)"

#### _ap_startup_work / _ap_create_content mental 효과 누락 버그
- "mental"을 modify_hidden_stat으로 잘못 라우팅 → 효과 무시됨
- STARTUP_VIGNETTES 4개 항목의 mental 효과 복원

#### 전수 검증 항목
- 26개 엔딩 ↔ finish_run 호출 100% 매핑 확인
- 3개 deferred_follow_up 유효
- opportunity 블록 구조 정상
- arc_four_months_in 트리거 정상 (t>=15 + flag)

### 후반9 — 스트레스 잔존 UI 전수 수정 + has_job 버그 수정

#### 스트레스→정신력 UI 잔존 참조 일괄 수정
- MetaProgression PERK_RULES "주거" 보너스: `stress/-1/-4` → `mental/+1/+4` (로그 "스트레스 -1" → "정신력 +1")
- `_show_vignette`: eff dict에서 stress → mental 병합(부호 반전) — REST/SELFDEV 비네팅 올바르게 표시
- `_show_effects_float`: 동일 병합 처리 — 이벤트 선택 float도 정신력으로 표시
- 충격 이벤트 감지: stress 효과 포함해 `effective_mental_delta` 계산 (stress:15 이상도 critical 발동)
- MainGame stat_map, `_stat_name`, perk stat_kr에서 "stress" 항목 제거
- 관계 힌트 텍스트 "스트레스 -N" → "정신력 +N", 버튼 라벨/로그/설명문 전수 수정
- ArubaGame/JobHuntMiniGame 결과 화면 "스트레스 %+d" → "정신력 %+d" (부호 반전)
- StoryMode 튜토리얼 팝업 스탯 목록에서 "스트레스" 제거

#### has_job:false → no_job:true 11건 수정
- 조건 `has_job: false`는 `if bool(false)` = 항상 false → 이벤트 절대 미발동 버그
- 수정 대상: amb_mlm_00, survival_rent_due/convenience_meal/job_portal_night/friend_sns, rare_interview_classmate/rejection_then_call/interview_pivot, chain_banchan_son/exec_interview, butterfly_resume_lie

#### 검증
- 942개 이벤트 전수 JSON 파싱 OK
- 108개 arc 이벤트 ID 모두 존재 확인
- cast_stages 선언-사용 교차 검증 통과
- audit.sh ERROR 0 / WARNING 0 / 밸런스 밴드 전부 통과

### 후반8 — 자율 정적 QA 1차

#### 이벤트 result_text 빈칸 30건 수정
- amb_scenarios~6, callback_events_3~5, scenario_cafe, scenario_cafe_callback 파일

#### opportunity 이중 mental 패널티 단순화
- `_resolve_opportunity()` 실패 시 `-3`+`-6` 중복 → `-9` 단일화

#### jaehyuk_way 엔딩 배경 + bg_map 정리
- endings.json jaehyuk_way background: `gangnam_apartment` → `gangnam_night`
- ending_bg_map 사용 안 하는 엔트리 3개 제거 (stable_success, orthodox_pinnacle, crypto_ghost)

#### MetaProgression stress_survivor 칭호 텍스트 갱신
- 이름: "스트레스 끝판왕" → "멘탈 끝판왕", 설명 → "정신력 15 이하"

### 후반7 — 스크린샷 QA 자동화

#### 실제 렌더러 스크린샷 QA 하니스 (`tools/ScreenshotQA.tscn`/`.gd`)
- 헤드리스 더미 렌더러는 빈 텍스처 → **xvfb + x11 + opengl3**로 실제 렌더링 캡처
- 실행: `xvfb-run -a godot --display-driver x11 --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn`
- `.tscn` 부팅(autoload 로드) + `add_child.call_deferred` + 전환 트윈 40프레임 차단(StoryMode 이탈 방지)
- 4종 캡처: 이벤트(포트레이트·타이핑·선택지)/투자모달+라인차트/위기 비네팅/AP 대시보드 → `/tmp/gangnamdream_qa/`

#### QA가 잡은 통합 후속 모순 수정
- 시작 안내·튜토리얼·주거 안내에 남아있던 "스트레스" 별도 기제 문구 3곳 → 정신력 통합 서술로 교체
- `_update_vignette`: stress 제거로 죽었던 빨강 가장자리를 **신체 위기**(건강≤35 또는 정신력≤20)로 재점등. 저정신력=어두운 모서리 / 저건강=빨강

### 후반6 — 스트레스→정신력 통합 + 고닷 활용

#### 스트레스 → 정신력 단일 스탯 통합 (밸런스 결정)
- **결정**: `stress`(높을수록 나쁨) 변수 완전 제거 → `mental`(높을수록 좋음) 단일 축으로 통합
- **구현 방식**: 적용 계층 리다이렉트 (JSON 600여 개 미수정). 데이터는 "stress" 단어 유지하되 모두 mental로 변환
  - `GameState.apply_effects` — `"stress": X` → `modify_stat("mental", -X)` (기존부터 존재)
  - `GameState.modify_hidden_stat("stress", X)` → `modify_stat("mental", -X)` (변경)
  - `EventManager._check_conditions` — `max_stress: N` → `mental < (100-N)`, `min_stress: N` → `mental > (100-N)`
  - `EventManager._effective_weight` — `stress>70` → `mental<30`
  - `BGMPlayer` 위기 트리거 → `mental <= 25`
  - `InvestmentSystem` 판단 페널티 → `(70 - mental) / 250`
  - `RelationshipSystem` 신뢰 가속 감소 → `mental < 25`
  - `MainGame._update_vignette` — `stress_norm` 0.0 고정 (셰이더 불변, mental_norm만 작동)
  - `GameState.gd` — `var stress` 선언·serialize·load_from_dict·DIFFICULTY_DATA(start_stress/pressure_stress) 전부 제거
- **밸런스 영향 (정량)**: stress 양수 622건(+3582)→mental -3582, 음수 594건(-2514)→mental +2514. 순 -1068을 mental 풀에 추가 (기존 mental 순합 +3597 → 통합후 +2529). 휴식 액션 강화·그라인드 액션(이력서/면접/창업) 정신력 직접 소모. **밸런스 밴드 전부 통과** (무직 100%·직장 0%·베팅 30억 14.8%)

#### 고닷 렌더링 기능 적극 활용 (이전 세션 main 커밋 + 컴파일 수정)
- 타이핑 효과(visible_ratio), 비네팅 셰이더, 포트폴리오 라인차트, 화면 흔들기, [wave]/[shake] BBCode, 골바 트윈, 코인버스트, 앰비언트 시간대 틴트
- **컴파일 에러 4종 수정** (Godot 컴파일 체크가 그동안 Mac 경로라 스킵돼 미검출):
  - `tier` 변수 중복 선언 (MainGame 4094/4110)
  - `phase := turn % 4` 타입 추론 실패 → `: int =`
  - `_button`/`_small_button`/`_label`/`_wrap_label` 반환 타입 미선언 → `-> Button`/`-> Label` 추가 (`:=` 호출부 일괄 해소)

#### 레버리지 투자 UI 연결 + 스토리 게이팅
- `_open_investments()` 하단 레버리지 버튼 추가 (투자감각 30 게이트) — 죽은 함수 `_open_leverage_investments` 연결
- 투자 버튼 게이팅: `arc_invest_guidance_seen` 플래그 필요 (상철 대화 후)
- 도박 조기 진입 차단: `gambling_006` 조건에 `arc_sangchul_met_seen` 추가
- 내러티브 이벤트 3종 추가 (holdem 2 + racetrack 1)

---

## ✅ 이전 세션 완료 목록 (2026-06-16)

### 후반5

#### StoryMode 포트레이트 프레임 제거
- `scenes/StoryMode.gd` — 금색 테두리·다크 매트·그림자 완전 제거 → 투명 StyleBoxFlat으로 교체
- `stretch_mode`: `STRETCH_KEEP_ASPECT_COVERED` → `STRETCH_KEEP_ASPECT_CENTERED`

#### 도박 이벤트 게이팅 수정
- `content/events/racetrack_events.json` — `race_first_visit`: `hidden: true` 추가 (랜덤 풀 → follow_up 전용)
- `content/events/holdem_events.json` — `holdem_first_visit`: 조건 `{}` → `{ "flag": "entered_network" }` 추가
- 결과: 카지노/경마/홀덤 모두 상철 네트워크 가입(t=23) 이전에는 접근 불가

#### arc_four_months_in 데모 씬 추가
- `content/events/arc_midgame.json` 끝에 새 이벤트 추가 (t=15 트리거)
- `scenes/MainGame.gd` `_next_arc_id()` — t>=15 블록 추가
- 데모 t=14~19 공백 구간 채움: 한강 다리 정체감 씬, 3가지 선택지(orthodox/unorthodox/침묵)

#### TutorialOverlay 추가 수정 (후반4에서 이어서)
- 더블팝업 방지: `TutorialOverlay._seen["main_game"]` 체크 추가
- "다음 달 ▶" → "다음 주 ▶" 수정
- 철학 슬라이드 4번째 추가 (선택 성향 안내)
- `_show_tutorial_intro()` 죽은코드 제거 ("AP 3개" 오류 포함)

---

### 후반3 추가 버그 수정 (세션 재개 후)

#### 캘린더 혼용 버그 6종 (별도 커밋)
- `BGMPlayer.gd:75` — `turn >= 36` → `age >= 36` (late_tense BGM 9개월→36세)
- `BGMPlayer.gd` hustle 판정 → `me(개월)` 기준으로 전환
- `MetaProgression.gd:232` — loner_title `turn >= 30` → 월기준
- `MainGame.gd:1062` — 카페 콜백 무한루프 방지 폴백 추가
- `MainGame.gd:1360` — `arc_after_scam` `t >= 40` 가드 추가
- `MainGame.gd:1476` — `_next_milestone_id()` 전체 `t → me` 전환 (8개 비교)
- `MainGame.gd:4846` — 런 요약 "개월" 표시 수정
- `EndingSystem.gd:18` — `get_score()` `turn → months_elapsed`

#### 이벤트 min_turn/max_turn 월→주 일괄 변환 (×4, 55건)
- 캘린더 마이그레이션 후 JSON이 여전히 월 단위로 작성된 버그
- life_events 19개: chapter_break(반환점/15개월남음), final_stretch/last_winter, father arc 4종, class_reunion 등
- relationship_events 9개: sangchul/daeun/jiyeon 윈도우
- callback_events*.json 18개: happy/father/daeun/jiyeon/final_sprint
- hidden/investment/amb_scenarios7 나머지 6개
- 핵심 영향: "반환점" 씬 7.5개월→30개월, "마지막 겨울" 14개월→56개월, father arc 적절한 중후반 타이밍으로 정상화

#### 엔딩 시스템 완성도
- `BGMPlayer.on_ending()` good 목록에 신규 엔딩 9종 추가 (instant_legend 등 "ending_bad"로 잘못 재생되던 것 수정)
- `_show_ending()` ending_bg_map: 16개 신규 엔딩 배경 추가
- `_ending_run_summary()`: empty_house/jaehyuk_way/with_daeun/jiyeon_man 등 10종 전용 요약 추가
- `_ending_cast_epilogue()` good 분류: 신규 성공 엔딩 10종 추가

#### drama_events.json 플래그 설정 버그 (CRITICAL)
- `startup_exit`·`political_winner` 엔딩이 절대 달성 불가한 버그 수정
- `effects: { "flag": "startup_exit" }` → `flags: ["startup_exit"]`로 올바른 위치로 이동
- 5개 이벤트 전체 수정 (chaebol_connection, bought_apartment, joined_startup 포함)

#### JobSystem 승진 후 퇴직 phantom salary
- 승진 보너스가 `monthly_income`에 누적된 뒤 `quit_job()`에서 `base_salary`만 차감하던 버그
- `current_job["effective_salary"]` 필드 도입으로 정확히 추적

### 캘린더 시스템
- **turn = 1주(週)**. 1개월 = 4턴. 5년 = 240턴 = 60개월. 종료 조건 = `age >= 38`.
- balance_sim / SimRun / 구 문서는 "turn=월" 모델로 작성돼 있었음 — **이미 인지된 기술 부채**.
- `_month_narration()` 에서 `t`(주 카운터)를 월로 잘못 쓰던 것 → `me = (age-33)*12 + month`(경과 개월)로 전면 교체 완료.
- 마감 힌트 `turns_left`: `60 - turn + 1` → `(38 - age)*12 - month + 1` 수정 완료.

### AP
- `GameState.gd` 선언 기본값 `action_points = 3` → **2**. 실제 `start_new_game()`은 항상 2로 세팅. 선언값만 정리. 게임 동작 무변.

### 챕터 카드 (chapter_cards.json)
- 5종: `chapter_card_33`(시작) / `34`(확장) / `35`(무게) / `36`(균열) / `37`(강남)
- 트리거: `_next_arc_id()` 최상단 — prologue_done → chapter_33_seen → 이후 age별 자동 발동
- 플래그 일치 확인: `chapter_33_seen` ~ `chapter_37_seen` set/read 완벽 매칭 (무한루프 없음)

### t9 반응형 씬 (arc_events.json)
- `arc_money_check_low` / `mid` / `high` — `get_total_asset_value()` 구간별 3가지 다른 씬
- `arc_gosiwon_wall` (t11, gosiwon 거주 중에만)

### 알바/편의점 개연성 수정
- `has_job: false` 조건이 `if bool(false)` → 항상 false인 버그 발견 → **`job_id: "job_01"` 조건으로 전면 교체**
- 편의점 점원 고정 씬(`rare_celeb_convenience` 등 5개) 수정
- `arc_intro_02_dad_call`: "편의점 야간 알바" → "고시원 방 새벽 3시" (무직자에게도 맞는 설정)
- `arc_jiyeon_02_store`: 플레이어=점원 → 플레이어=손님(편의점 나오는 중)
- `relationship_events.json`의 `daeun_meet` 삭제 (플레이어=점원 고정 모순)
- `arc_daeun_01_meet`에 `daeun_met` / `daeun_first_kind` 플래그 추가 (고아 에러 해소)
- `EventManager.gd`: `job_id` 조건 키 신규 추가

### instant_legend 히든 엔딩
- `age <= 33` + 자산 30억 → `finish_run("instant_legend")` 분기 (GameState.gd)
- endings.json: grade `"?"`, title "신화", background "gangnam_apartment"
- MainGame.gd: `"?": "#a855f7"` (보라) / `"?": "👁"` grade 표시 추가

### Chapter 1 고아 플래그 콜백 (callback_events_27.json)
- 7개 이벤트, t13~24 범위 발동:
  - `callback_parttime_survived` ← `considered_parttime`
  - `callback_budget_check_in` ← `budget_planned`
  - `callback_mid_goal_echo` ← `set_monthly_goal`
  - `callback_quiet_money_patience` ← `kept_quiet_money`
  - `callback_early_greed_humbled` ← `early_greed`
  - `callback_gosiwon_wall_echo` ← `knocked_on_wall`
  - `callback_stayed_grounded_echo` ← `stayed_grounded`

### SimRun.gd 루프 상한 수정
- `turn <= 64`(16개월) → `turn <= 244`(전체 5년) — 척추 증명이 실제 풀게임 길이를 커버하도록
- guard 상한 `300` → `260` (244 + 버퍼)

### 챕터1 루트·테마별 반응 이벤트 5종 (arc_events.json)
- `arc_ch1_invest_first_chart` ← `route_invest` 플래그, t>=8: HTS 첫 날
- `arc_ch1_career_first_spec` ← `route_career` 플래그, t>=8: 자소서 첫 줄 (3가지 선택지)
- `arc_ch1_startup_first_idea` ← `route_startup` 플래그, t>=8: 아이디어 노트
- `arc_ch1_theme_network_first` ← `theme_network_run` 플래그, t>=8: 재테크 스터디 첫 모임
- `arc_ch1_theme_invest_deep` ← `theme_invest_run` 플래그, t>=8: 차트 3시간
- `_next_arc_id()` t8 블록 뒤에 5개 트리거 추가 (route/theme → 해당 플레이어에게만 발동)

### 오딧 / 밸런스
- ERROR 0, WARNING 0 유지 중
- 밸런스 밴드: 무직 실패 100%, 직장 실패 0%, 베팅 30억 도달 14.8% — 전부 통과

---

## 세션 프로토콜

### 시작 (3분 이내)
1. 이 파일 (`CLAUDE.md`) — 현재 상태 블록 확인 ✓ (지금 읽는 중)
2. `docs/ROADMAP.md` — 현재 단계 `[ ]` 항목 확인
3. `docs/WORK_LOG.md` 최근 3개 항목 — 지난 세션 마무리 상태 확인
4. **유저 지시가 없으면 "다음 작업"부터 바로 시작**

### 종료 (매 작업 후 필수)
1. `CLAUDE.md` 현재 상태 블록 업데이트 (다음 작업 갱신)
2. `docs/ROADMAP.md` — 완료 항목 `[x]` 처리
3. `docs/WORK_LOG.md` — 날짜 + 작업 내용 추가
4. `docs/RELEASE_NOTES.md` — `## Unreleased`에 변경사항 추가
5. `docs/DECISIONS.md` — 설계 결정이 있으면 날짜 + 근거 기록
6. 수치 조정 시 `docs/BALANCE.md` 업데이트

### ⭐ 커밋 전 정적 감사 (필수)
```bash
./tools/audit.sh
```
플레이 없이 옛/새 시스템 모순을 잡는다:
1. **dangling 동적 호출** — `self.call("_x")`/`Callable(self,"_x")`/헬퍼에 넘긴 함수명이
   실제 정의돼 있는지 (← 문자열 호출이라 Godot 파싱을 통과해버리는 "눌러도 무반응" 버그)
2. **폐기 키워드** — 옛 설계 잔재(시작 나이·옛 마감·은퇴·가짜 랜덤 인물 이름 등) <!-- audit-ignore -->
   (코드 전체 + CLAUDE.md·STORY_BIBLE.md만 검사. 과거 로그 문서는 제외)
3. **이벤트 JSON 무결성** — 파싱/중복 id/없는 follow_up/없는 portrait·background·cg/빈 result_text
4. **플래그 교차 검증** — 코드/이벤트 조건이 읽는 플래그(`f.get`/`flags.get`/`flag`/`no_flag`/
   `cast_has_flag`)를 실제로 누가 set하는지 대조 (← 오타·이름 불일치로 패널/분기/이벤트가
   조용히 죽는 버그. 2026-06-10 도입 시점에 잠재 버그 15개 일괄 검출)
5. **serialize 완전성** — GameState var 선언 vs serialize() 키 대조 (← 저장 누락으로 로드 시
   조용히 리셋. transient 변수는 audit.py SERIALIZE_EXEMPT에 등록)
6. **이벤트 키 화이트리스트** — effects/conditions/opportunity/cast_effects 키를
   apply_effects·_check_conditions가 실제 처리하는 키와 대조 (← 오타 키가 조용히 무시되는
   버그. 2026-06-11 도입 시점에 죽은 효과 5건·죽은 조건 2건 검출)
7. **인물 stage 상태기계** — `content/meta/cast_stages.json`이 정본. 선언 안 된 stage를
   set/read하면 ERROR (← acquaint vs acquaintance 같은 "같은 단계의 두 이름" 서사 모순.
   **새 stage 추가 시 이 파일에 먼저 선언할 것**)
8. **밸런스 회귀 밴드** — balance_check.py가 핵심 정책 시뮬로 30억 도달률·실패율 밴드 검증
   (← 경제 파라미터 변경의 의도치 않은 파급. 의도된 변경이면 BALANCE.md 기록 + 밴드 갱신)
9. **Godot 헤드리스 파싱** (로컬 Godot 필요 — 없으면 CI가 수행)

ERROR 0 이면 통과. **새 함수·이벤트·인물·플래그·stage 추가 후 반드시 돌릴 것.**
푸시하면 GitHub Actions(`.github/workflows/ci.yml`)가 같은 감사 + Godot 컴파일/SimRun을 돌린다.

### JSON 수정 후
```bash
python3 -c "import json; json.load(open('파일.json'))"
```

### 새 이벤트 추가 시 체크
- `id`는 `snake_case`, 전체에서 고유
- `result_text` 반드시 채울 것 (빈 문자열 금지)
- `cooldown` 최소 3 이상 권장
- `conditions`가 없으면 `{}`

---

## 프로젝트 개요

- **한 줄 정의**: 33세 백수 김민준이 통장 50만원으로 시작해 5년(38세) 안에 자산 30억을 모아 강남에 입성하는 한국 사회 리얼리티 인터랙티브 드라마
- **장르**: 인터랙티브 드라마 / 비주얼노벨 (드라마처럼 "보는" 게임)
- **엔진**: Godot 4.6 (GDScript)
- **주요 언어**: 한국어 (UI, 이벤트, 뉴스, 설명)
- **설계 바이블**: `docs/GAME_DESIGN.md` — 반드시 읽고 기능을 추가할 것

---

## 디렉토리 구조

```
GangnamDream/
├── CLAUDE.md                  ← 이 파일 (항상 먼저 읽기)
├── project.godot
├── autoloads/
│   ├── DataRegistry.gd        # JSON 콘텐츠 로더 & 인덱스
│   ├── GameState.gd           # 런 상태, 스탯, 돈, 플래그, 직업, 관계, 포트폴리오
│   │                          # + route_orthodox/unorthodox, month_focus, housing_months
│   ├── EventManager.gd        # 조건/가중치/쿨다운/연쇄 이벤트
│   ├── NewsManager.gd         # 월별 뉴스 생성 & 시장 영향
│   ├── MetaProgression.gd     # 런 히스토리, 업적, 칭호(29개) 해금
│   └── SaveManager.gd         # 자동저장 + 다중 슬롯
├── content/
│   ├── events/
│   │   ├── life_events.json        # ~113개 일반 이벤트
│   │   ├── investment_events.json  # 30개 투자 이벤트
│   │   ├── relationship_events.json # 30개 관계 이벤트
│   │   └── hidden_events.json      # 20개 히든/희귀 이벤트
│   ├── assets.json            # 투자 자산
│   ├── jobs.json              # 직업 15개
│   ├── items.json             # 아이템 28개
│   ├── endings.json           # 엔딩 10개
│   ├── news_templates.json    # 뉴스 템플릿 79개
│   └── meta/default_meta.json # 메타 초기값 (unlocked_titles 포함)
├── systems/
│   ├── InvestmentSystem.gd    # 매수/매도, 레버리지, 마진콜, 배당
│   ├── JobSystem.gd           # 취업/퇴직/승진
│   ├── RelationshipSystem.gd  # 관계 패시브, 소멸
│   ├── InventorySystem.gd     # 아이템 구매/사용
│   └── EndingSystem.gd        # 엔딩 조회 & 점수
├── scenes/
│   ├── StartMenu.tscn / .gd   # 시작 화면, 저장 슬롯 (드라마 모드: 고정 시작)
│   └── MainGame.tscn / .gd    # 메인 대시보드 UI
├── ui_components/
│   ├── StatRow.gd
│   └── NotificationToast.gd
└── docs/
    ├── GAME_DESIGN.md         ← 게임 설계 바이블 (반드시 읽기)
    ├── ROADMAP.md             ← 개발 단계 & 체크박스
    ├── WORK_LOG.md            ← 날짜별 작업 기록
    ├── RELEASE_NOTES.md       ← 버전별 변경사항
    ├── DECISIONS.md           ← 설계 결정 근거
    ├── BALANCE.md             ← 밸런스 조정 이력
    └── BUILD_NOTES.md         ← 빌드/테스트 기록
```

---

## 핵심 설계 규칙 (불변)

### GDScript 아키텍처
- 모든 게임 데이터는 `content/` JSON으로 관리. 스크립트 하드코딩 금지.
- 전역 상태는 `GameState` autoload에만 저장.
- 시스템 스크립트(`systems/`)는 `GameState`를 읽고 쓰되 서로 직접 참조하지 않는다.
- UI는 `MainGame.gd`에서 `_refresh_all()`로 일괄 갱신.
- `stats_changed` 시그널 발생 → `_refresh_all()` 자동 호출.

### JSON 이벤트 형식
```json
{
  "id": "unique_snake_case_id",
  "title": "이벤트 제목",
  "description": "상황 설명 (2-4문장)",
  "category": "finance|family|jobs|social|gambling|health|investment|relationship|disasters|politics|comedy|military",
  "rarity": "common|uncommon|rare|legendary",
  "weight": 1.0,
  "hidden": false,
  "conditions": {
    "min_money": 0, "max_stress": 100, "min_intelligence": 0,
    "has_job": true, "flag": "flag_name",
    "min_route_orthodox": 0, "min_route_unorthodox": 0,
    "month_focus": "투자"
  },
  "tags": ["tag1", "tag2"],
  "cooldown": 6,
  "choices": [
    {
      "text": "선택지 텍스트",
      "effects": {
        "money": 100000, "health": -5, "mental": 3,
        "stress": -2, "intelligence": 1, "social_skill": 0,
        "investment_skill": 2, "luck": 0, "reputation": 1
      },
      "flags": ["flag_to_set"],
      "follow_up_event": "",
      "result_text": "선택 후 결과 텍스트 (1-3문장, 빈 문자열 금지)"
    }
  ]
}
```

### 엔딩 ID 매핑
| `finish_run()` 호출 | endings.json id |
|---|---|
| `finish_run("burnout")` | `burnout` |
| `finish_run("mental_break")` | `mental_break` |
| `finish_run("bankruptcy")` | `bankruptcy` |
| `finish_run("stable_success")` | `stable_success` |
| `finish_run("ordinary_life")` | `ordinary_life` |
| `finish_run("gangnam_dream")` | `gangnam_dream` |

특수 엔딩: `crypto_ghost`, `startup_exit`, `political_fix`, `lonely_rich`

---

## 밸런스 기준값

| 항목 | 값 |
|---|---|
| 시작 자금 | 500,000원 (백수, 통장 50만원) |
| 시작 나이 | **33세** (김민준) |
| 마감 기한 | **38세 = 5년 = 60개월 = 240턴(주)** (`age >= 38` 타임리밋) |
| 기본 고정 지출 | 650,000원/월 (고시원) → 원룸/빌라/아파트 전세 (HOUSING_DATA) |
| 건강 초기값 | 65 / 정신력 60 |
| 스트레스 초기값 | 35 |
| 월별 스트레스 자연 증가 | +3 (무직 시 추가 +3, 총 +6) |
| 월별 건강 자동 감소 | -2 |
| 월별 정신력 자동 감소 | -3 (무직 시 추가 -2, 총 -5) |
| **강남 입성(승리) 조건** | **총자산 30억 이상** → `finish_run("gangnam_dream")` |
| 파산 조건 | 순자산(현금+포트폴리오-대출) -1억 이하 (부채 나락 -2억) |
| 대출 | 신용등급(1~10, 직장·근속·소득·자산·부채로 산정)이 한도·금리 결정. 1금융 월 0.4~0.88%·소득 18~6배·7등급 이내 / 2금융 월 1.28~2.0%·4,600만~1,000만. 변동금리 |

---

## 알려진 미구현 / 다음 작업

현재 코드 레이어는 모두 구현 완료. 아래는 로컬 Godot 필요 항목:

- **QA 플레이스루** — 실제 실행 후 스크립트 에러·UI 레이아웃·클릭 흐름 검증
- **빌드/Export 패키징** — Godot Export Templates 설치 후 Web/PC 빌드
- **스토어 페이지 소재** — 스크린샷, 설명문, 태그 (선택사항)

### 구현 완료 항목 (이전 TODO)
- ✅ `NotificationToast.gd` 연동
- ✅ 엔딩 화면 메타 진행도 업적 해금 표시
- ✅ `appearance` 스탯 효과 (직업 요건 3종 + 연애 호감도 감소 완화)
- ✅ 직업별 이벤트 트리거 조건 (`min_job_tier`, `max_job_tier`, `job_category`)
- ✅ 투자 차트 히스토리 시각화 (스파크라인, 수익률 요약)
- ✅ 관계 패널 능동 상호작용 (유형별 전용 선택지 모달)
- ✅ 특수 엔딩 6종 도달 경로 구현
- ✅ 배경 이미지 19종 이벤트 자동 매핑
- ✅ 엔딩 화면 배경 전환 (penthouse/burnout/gangnam_night/rooftop)
- ✅ FM SFX 14종 + BGM 6트랙 (AudioManager + BGMPlayer)
- ✅ Pretendard 한국어 폰트 적용
- ✅ 런 테마 시스템 (매 런 카테고리 2개 부스트)
- ❎ 트레이트(특성) 시스템 — 드라마 피벗으로 제거. 성향(tendency) 자각 시스템으로 대체.
