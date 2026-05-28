# Gangnam Dream Work Log

## 2026-05-28 (콘텐츠 패스 2 — 25-35세 구간 이벤트 14개 추가)

### 신규 이벤트 (life_events.json, 234→238개)
- `salary_negotiation_moment` (t12+, 취업 필요): 연봉 협상
- `work_life_balance_moment` (t12+, 스트레스 45+): 퇴근 후의 시간
- `health_checkup_results` (t24+, 스트레스 55+): 건강검진
- `mental_health_realization` (t12+, 스트레스 60+): 정신건강 자각
- `first_hundred_million` (1억 이상, no_flag): 처음으로 1억을 봤다
- `mt_company_trip` (t3+, 취업 필요): 회사 MT
- `workplace_gossip` (t8+, 취업 필요): 사무실 소문
- `age_28_career_ceiling` (t72+, min_job_tenure 12): 승진 라인의 벽
- `first_proper_apartment` (t60+, 1500만 이상): 드디어 내 방
- `marriage_pressure_28` (t84+, no_flag): 결혼 얘기가 나오기 시작했다
- `burnout_age_29` (t72+, 스트레스 65+): 번아웃

### 신규 이벤트 (investment_events.json, 32→35개)
- `invest_big_win_first` (t48+, 투자감각 20+, 포트폴리오 보유): 3배 수익이 났다
- `invest_daytrade_catastrophe` (t24+, 투자감각 10+, 포트폴리오 보유): 단타의 대가
- `orthodox_passive_income_milestone` (t96+, 정석 루트 10+): 월세보다 많은 배당금

### 버그 수정
- `drama_crypto_result_big`, `drama_crypto_result_small`: hidden=true 설정. 크립토 미투자자에게 크립토 손실 이벤트 발화 방지.

### QA 검증
- 전체 381개 이벤트 ID 고유성 확인 완료
- follow_up_event 참조 16개 전부 유효
- result_text 빈 값 없음

## 2026-05-28 (게임 재미 심화 — 스토리 마일스톤 + 라이벌 + 콘텐츠 확장)

### 버그 수정
- **직장 이벤트 조건 오류**: `jobs_003`(이직 공고), `jobs_014`(팀장님 한마디), `jobs_036`(야근 메신저) 3개 이벤트에 `has_job: true` 조건 추가. 무직자에게 직장 이벤트가 발생하는 현상 수정.

### 스토리 마일스톤 시스템 개선 (핵심 개선)
- **마일스톤 이벤트 발화 확률 문제 발견 및 수정**: `age_25_crisis`, `five_year_seoul`, `midlife_30s_reflection` 등이 1% 확률로만 발화하던 문제. 랜덤 풀 가중치(0.16%/턴 × 6턴 창구 = 1%) 한계로 인해 플레이어가 거의 못 보던 이벤트들.
- **해결**: `_check_story_triggers()`에 t48/60/120/180/240/300 마일스톤 직접 연결. 이제 100% 발화 보장.
- **신규 스토리 이벤트 2개 추가**:
  - `story_four_year` (턴 48, 4년): "스물넷. 청춘의 딱 중간이다."
  - `story_five_year` (턴 60, 5년): 5년차 서울 생활 회고. `five_year_reflected` 플래그도 설정하여 기존 `five_year_seoul` 이벤트와 충돌 방지.

### 라이벌 서사 강화
- `RivalSystem._check_rival_narrative()` 메서드 신규 추가
- 1년차: 라이벌 첫 월급 치킨 소문
- 2년차: 라이벌 이직/현재 상황 메시지
- 3년차: 라이벌 투자 소문 (자산 기반 분기)
- 5년차: 라이벌 5년 달성 상황 (1억/아파트/고군분투 분기)
- 10년차: 라이벌 30대 진입 메시지

### 캐릭터 아크 이벤트 가중치 상향
- 수민 아크: `romance_sumin_meet` 0.9 → 2.5, 연결 이벤트들 1.0 → 2.0
- 박 과장 아크: `mentor_park_meets_you` 1.0 → 2.5, 연결 이벤트들 0.7-0.9 → 1.8
- 개선 전 encounter rate 약 20% (100턴 기준) → 개선 후 약 70%

### 중반 생활 이벤트 5개 추가 (Turn 36-60)
- `peer_comparison_anxiety` (t36+): SNS 동기 비교 불안
- `marriage_pressure_parent` (t36+): 명절 친척 결혼 압박
- `career_plateau_feeling` (t48+, has_job): 커리어 성장 정체감
- `late_20s_money_anxiety` (t60+): 또래 자산 비교
- `old_friend_diverging` (t48+): 오랜 친구와 방향 달라짐

### 월 등급 메시지 다양화
- 모든 등급(대박/잘함/평범/힘든/위기)에 3종 메시지 풀 추가 (턴 기반 rotate)
- "버티는 달" 등급 초반 전용 메시지 추가 (자산 < 500만)

### 검증
- 전체 367개 이벤트 JSON 유효성 확인
- 이벤트 조건에서 참조하는 플래그 5개 모두 GameState 코드에서 설정 확인

---

## 2026-05-28 (Phase 3-C 밸런스 & 폴리시)

### 버그 수정
- **AP 스터디 모달 타이밍 버그**: `_ap_study()`에서 모달 열기 전에 AP 소비 → 선택 취소해도 AP 날아가던 문제. `_on_study_chosen()` 시점에 AP 소비하도록 이동.

### UI/UX 개선
- **주거 마일스톤 힌트 수정**: 기존 30M/350M 잘못된 값 → 실제 이사 가능 기준(8M/35M/120M)으로 교체. 이제 해당 자산 구간 도달 시 이사 가이드 포함한 힌트 표시.
- **월간 조언 개선**: 고시원 거주자가 원룸 이사 조건을 갖추면 "이사할 자금이 생겼습니다" 조언 자동 표시.

### 문서 업데이트
- **CLAUDE.md 밸런스 수정**: 고정 지출 650K→800K(고시원 기준), 전체 주거 등급별 지출 표 추가, 월별 압박 수치 추가.
- **ROADMAP.md**: Phase 3-C 완료 처리 (2026-05-28).

### 검증 내역
- 전체 수치 밸런스 시뮬레이션: 편의점→중소→대기업→AI컨설턴트 루트로 age 47에 20억 달성 가능 확인.
- 이벤트 360개 follow_up 참조 유효성, 모든 flag 조건 set/check 쌍 확인.
- 정석 38개 / 비정석 61개 이벤트 분포 확인.
- 한국어 문체 통일 패스: 전반적 양호.

---

## 2026-05-28 (스타트업·크리에이터 루트 강화 + 한국 일상 유머 이벤트)

### 스타트업 루트 중간 이벤트 추가
- `startup_first_user_traction` — 첫 유저 피드백으로 팀 동력 회복 (startup_launched 후, growing 이전)
- `startup_team_conflict` — 공동창업자와 B2B vs B2C 방향 충돌 (startup_team 보유 시)

### 크리에이터 루트 중간 이벤트 추가
- `creator_algorithm_penalty` — 알고리즘 페널티 대응 (started 이후 viral 이전)
- `creator_hater_crisis` — 악플 폭격 위기 관리 (viral 이후)
- `creator_collab_offer` — 100만 유튜버 콜라보 제안 (monetized 이후)

### creator_success 엔딩 버그 수정
- 기존: age 65 블록 내부에서만 체크 → 다른 엔딩 조건에 가려 사실상 불가
- 수정: 총자산 3억+ 달성 시 startup_exit처럼 즉시 발동
- age 65 블록의 중복 check 제거

### 한국 일상 유머 이벤트 6개 추가 (Phase 2-D)
- `kakao_group_chat_war` — 카카오 단체방 연봉 자랑 폭발
- `chimaek_friday` — 금요일 한강 치맥 유혹
- `subway_line_2_sleeping` — 2호선에서 통잠 후 종착역
- `convenience_store_1plus1` — 편의점 1+1의 철학적 고민
- `norebang_midnight` — 새벽 노래방의 유혹
- `jjimjilbang_recovery` — 스트레스 50+ 일 때 찜질방 피신

### 시스템 검증
- 360개 이벤트 모두 follow_up 참조 유효, result_text 비어있지 않음 확인
- 모든 required flag 어딘가에서 set됨 확인 (dead-end 없음)
- 정석 루트 이벤트 38개, 비정석 루트 61개 (각 30개+ 목표 달성)

---

## 2026-05-28 (뉴스 템플릿 전면 재작성 + 이벤트 품질 패스 계속)

### 뉴스 템플릿 전면 재작성 (`content/news_templates.json`)
- 기존 79개 템플릿이 단 5개의 동일한 헤드라인 패턴을 재사용하던 문제 수정
  - 이전: "2030 사이에서 {topic} 인증 열풍..." 등 5개 패턴이 모든 카테고리에 반복
  - 이전: 모든 항목의 topics 배열이 동일한 7개 일반 단어 (AI, 코인, 강남 부동산...)
- 수정 후: 79개 헤드라인 모두 고유, 카테고리별 맞춤 헤드라인 및 topics 배열
  - korean_stocks: 실적 쇼크, 외국인 순매수, 공매도 타깃, 회계감리, 목표주가 상향 등
  - us_stocks: AI 수혜주, 연준 발언, 실적 서프라이즈, CEO 사임, 달러 강세 등
  - real_estate: 아파트 급등, 재건축 완화, 전세 매물 실종, 청약 경쟁률, GTX 개통 등
  - politics: 규제 강화, 세제 혜택 통과, 포퓰리즘 공약, 검찰 수사, 한미 협력 등
  - social_trends: 투자 인증 열풍, 영끌 이자 폭탄, 파이어족 논쟁, 앱테크 열풍 등
  - ai_boom: AI 모델 공개, 전력 수요, HBM 공급 계약, 규제, 나스닥 상장 등
  - startup_culture: 시리즈C 유치, 폐업 선언, IPO 흥행, 감원 쇼크, M&A EXIT 등
  - employment_crisis: 취업 경쟁률, 구조조정, 청년 실업, 공무원 회귀, AI 대체 직군 등
  - cryptocurrency: 폭등/해킹, 규제, ETF 기대, 반감기, 김치프리미엄 등

---

## 2026-05-28 (Phase 2-A 취준생 페이즈 + 스토리 마일스톤 + 버그 수정)

### 스토리 마일스톤 이벤트 추가 (크리티컬)
- `_check_story_triggers()`에서 참조하지만 존재하지 않던 3개 이벤트 추가
  - `story_one_half_year` (턴 18, 1년 반): 3가지 선택, `story_one_half_year_seen` 플래그
  - `story_two_year` (턴 24, 2년): 3가지 선택, `story_two_year_seen` 플래그
  - `story_three_year` (턴 36, 3년): 3가지 선택, `story_three_year_seen` 플래그

### Phase 2-A: 취준생 페이즈 구현
- **취업 준비 피드백 개선**: 구직활동 모달에 "준비도 패널" 추가 (이력서 완성 ✓/✗, 면접 연습 ✓/✗, 취업 후 업무능력 보너스 미리 표시)
- **취업 준비 보너스 적용**: `JobSystem.apply_for_job()` — 이력서 완성 시 업무능력 +10, 면접 연습 시 +7 (플래그 소모)
- **취업 성공 토스트 개선**: 준비 보너스가 있을 때 "취업! X직업 (준비 보너스 +17 업무능력)" 표시

### 버그 수정
- **`job_rejection_blues` 조건 수정**: `no_flag: story_first_workday_seen` 제거 → 재취업 준비 중인 플레이어도 이벤트 볼 수 있게
- **`career_crossroads` 반복 방지**: 선택지에 `career_crossroads_seen` 플래그 추가
- **`drama_startup_offer`**: 스타트업 합류 선택지에 `startup_launched` 플래그 추가 누락 → 사이드 창업 섹션 정상 활성화
- **`drama_viral_moment`**: 채널 키우기 선택지에 `creator_started` 플래그 추가 → 크리에이터 루트 정상 진입

### 콘텐츠 확장 (이벤트 +5개)
- `age_25_crisis`: 25살 위기감 (턴 60-66, 1회성)
- `gosiwon_escape_day`: 고시원 탈출 기념 (oneroom 첫 이사 후 1회성)
- `investment_first_profit`: 첫 투자 수익 (1회성 마일스톤)
- `five_year_seoul`: 서울 5년 (턴 60-65)
- `career_pivot_temptation`: 커리어 전환 고민 (턴 24+, 직장인)

### 기타
- `midlife_30s_reflection` 타이밍 수정: min_turn 36 → min_turn 120 (실제 30세와 일치)
- 중복 ID 3개 제거: story_one_half_year/two_year/three_year가 life_events.json에도 존재 → 제거
- 전체 이벤트: 320 → 325개

---

## 2026-05-28 (콘텐츠 대폭 확장 + 크리티컬 버그 수정)

### 크리티컬 버그 수정
- **스토리 이벤트 무한 반복 버그 수정**: `story_events.json`에서 `_seen` 플래그 누락으로 `trigger_event_by_id()`가 매 턴 같은 스토리를 반복 재생하던 문제 수정
  - 수정 대상: story_first_workday, story_first_paycheck_feel, story_first_savings_milestone, story_six_months, story_one_year, story_gosiwon_neighbor
- **배경별 취업 잠금 해제 버그**: story_arrival_elite/rich 이벤트가 `story_job_unlocked` 플래그를 설정하지 않아 명문대/금수저 배경 플레이어가 영원히 취업 불가하던 문제 수정
- **이벤트 중복 ID 9개 제거**: story_events.json과 life_events.json에 동일 ID 이벤트가 중복 존재 → life_events.json의 중복 버전 삭제

### 콘텐츠 확장
- **life_events.json**: 183 → 197개 (+14개 중복 제거 반영 후 순수 추가 이벤트 포함)
- **새 이벤트 카테고리**: 직장 중기(연차 평가, 헤드헌터, 동료 퇴사, 회식, 번아웃, 사내 암투), 한국 부동산(전세 충격, 청약 탈락), 투자 중기(배당 시즌, 폭락장, 강세장 유혹, 코인 FOMO), 사회 비교(친구 집 구매, 30대 회고), 재무(대출 투자 유혹, 가족 금전 부탁, 종합소득세, 자산 점검)
- **이벤트 분포 개선**: 중기(min_turn 7-24) 이벤트 9 → 35개 (3.9배 증가)
- **전체 이벤트 수**: 286 → 320개

### 다음 작업
Phase 2 진입 검토: 취준생 페이즈, 엔딩 강화, 이벤트 품질 패스

---

## 2026-05-28 (칭호 시스템 + 장기 프로젝트 구조 정비)

### 칭호(Title) 시스템 완성
- `MetaProgression.ALL_TITLES` 29개 정의 (주거/직업/투자/성향/관계/생활/자산/메타)
- `check_and_unlock_titles()` / `_check_title_condition()` — 매달 결산 후 자동 체크
- `GameState.get_current_title()` — 실시간 동적 칭호 계산 (16가지 분기)
- 초상화 패널 하단 `「현재 칭호」` 표시 (`title_label`)
- `_check_title_unlocks()` — 새 칭호 해금 시 희귀도 색상 토스트
- 🏆 도감 버튼 (하단 바) + `_open_title_collection()` 모달
- `_ap_free_time()` → `free_time_count` 증가 (자유 영혼 칭호 조건)

### 루트 시스템 연동
- 행동 버튼 람다 래퍼로 `add_route_point()` 자동 적립
- `month_focus` — 이번 달 첫 행동 기록, 이벤트 조건으로 활용
- `housing_months` — 거주지별 체류 기간 추적 (칭호 조건)

### 프로젝트 문서 구조 정비 (장기 개발 대비)
- `CLAUDE.md` 재작성: 최상단에 🔴 현재 상태 블록 추가 (매 세션 종료 시 업데이트)
- `docs/GAME_DESIGN.md` 신규 생성: 게임 정체성, 코어 루프, 시스템 존재 이유,
  기능 추가 기준, 절대 안 하는 것 등 설계 바이블
- `docs/ROADMAP.md` 재작성: 실제 완료 상태 반영, Phase 1-3 체계화, 구현된 시스템 표

### 다음 세션 작업
1-B 미완료: 루트별 이벤트 가중치 차등화 → Phase 1 전체 완료 → 테스터 재검토

---

## 2026-05-28 (Phase 1 콘텐츠 완성 — 1-C/1-D/1-E)

### 시스템 확장
- EventManager._check_conditions(): `housing`, `min_housing_months`, `max_turn` 조건 추가

### 1-C: 거주지별 전용 이벤트 9개
- 고시원(3): gosiwon_wall_noise, gosiwon_bathroom_morning, gosiwon_long_stay_blues
- 원룸(2): oneroom_first_night, oneroom_empty_fridge
- 아파트(2): apartment_floor_noise, apartment_guard_greeting
- 강남(2): gangnam_consumption_trap, gangnam_class_pressure

### 1-D: 선택의 연결 이벤트 10개 (5 flag chain 세트)
- 야근 알바 → 편의점 단골: late_night_job_ran_into → convenience_regular_bond
- 투자 자랑 → 동료 조언 요청: bragged_about_gains → colleague_wants_investment_tips
- 직장 하소연 → 선배 인생 이야기: vented_to_senior → senior_life_wisdom
- 건강 무시 → 쓰러짐: ignored_body_warning → body_forced_rest

### 1-E: 핵심 캐릭터 이벤트 12개
- 연인 후보 이수민(6): meet / number / first_date / crisis / confession
- 멘토/압박 박 과장(6): meets_you / spec_lecture / weekend_request / burnout_mirror / promotion_offer

### 현황
- life_events.json: 113 → 140개 (+27개)
- Phase 1 잔여: 1-B 루트 가중치 차등화만 남음

---

## 2026-05-28 (Tester Feedback + RPG/Roguelike Pass)

### 버그 수정
- **행동력 소비 버그**: `_ap_invest()`에서 모달 오픈 전에 `spend_ap()`를 호출하던 문제 수정. 매수·매도 실행 시(`_on_buy_asset`, `_on_sell_asset`)만 AP를 소비하도록 이동. 조회/분석은 무료.
- **중복 이벤트 ID**: `relationship_events.json`의 `jobs_003`, `investment_events.json`의 `finance_011` 중복 ID를 각각 `rel_jobs_003`, `invest_finance_011`로 고유화.
- **이벤트 설명 보일러플레이트**: `life_events.json` 37개, `relationship_events.json` 12개, `investment_events.json` 14개 — 동일한 플레이스홀더 설명("서울의 속도는 멈추지 않고…")을 고유한 한국어 텍스트로 교체.

### 기능 구현 — 로그라이크 요소
- **월별 크라이시스 시스템** (`MainGame.gd`): 매달 6% 보너스(AP+1, 추가수입, 강세장) / 18% 크라이시스(긴급지출, AP패널티, 시장충격, 건강위기) 랜덤 발동. 3턴 이후부터 활성화.
- **레버리지 투자** (`InvestmentSystem.gd`): `buy_asset_leveraged()` — 동일 금액으로 2배 포지션. 수수료 1.5%.
- **마진콜** (`InvestmentSystem.gd`): `_check_margin_calls()` — 포지션 가치가 원금의 35% 이하 시 85% 청산, 스트레스+20, 정신력-10.
- **시장 충격** (`InvestmentSystem.gd`): `apply_market_shock()` — 크래시 위험 2.5배, 공포지수 -25, 약세장 전환.
- **크래시 확률 상향**: 기존 `crash_risk * volatility * 0.5` → `* 1.2`, 기본 크래시 위험 0.03 → 0.05.

### 기능 구현 — RPG 성장 요소
- **스탯 임계값 시스템** (`GameState.gd`): `STAT_THRESHOLDS = [30, 50, 70]`, `modify_stat()`이 임계값 돌파를 감지하고 `stat_threshold_crossed` 시그널 발생.
- **임계값 해금 알림** (`MainGame.gd`): `_on_stat_threshold_crossed()` — 토스트로 해금 메시지 표시, 게임 로그 기록.
- **조건부 행동 버튼** (`MainGame.gd`): 스탯 수준에 따라 새 행동 버튼 표시:
  - 지력 30+ → 📖 심화 독서 (지력+8)
  - 지력 50+ (취업 중) → 🔭 시장 분석 [무료] (AP 소비 없음)
  - 투자스킬 30+ (취업 중) → ⚡ 레버리지 투자 (2배 포지션)
  - 사회성 50+ → 👔 VIP 인맥 (사회성+3, 관계 대폭 강화)
- **무료 행동 지원**: 행동 버튼에 `free: true` 속성 추가. AP=0이어도 무료 행동은 활성화 유지.
- **시장 예보** (`InvestmentSystem.gd`): `get_market_forecast()` — 크래시 위험/싸이클/공포지수 기반 문자열 반환.

### UI 개선
- **투자 모달 X 버튼**: `_build_info_panel()`을 VBoxContainer + 헤더 행(제목+✕) 구조로 개편.
- **AP 힌트**: 투자 모달 상단에 "⚡ 행동력 N/M — 매수·매도 실행 시 1 소비 (조회는 무료)" 표시.

### 배경음악
- **무한 루프 보장** (`BGMPlayer.gd`): `finished` 시그널 연결 추가. WAV LOOP_FORWARD가 실패해도 `_on_bgm_ended()`에서 재생 재시작.

## 2026-05-16 (Meta-Progression First Pass)

### 기능 구현
- `content/meta/traits.json` 신규 생성 — 5종 트레이트 정의 (id, unlock 조건, description, bonus).
- `DataRegistry.gd` — `TRAITS_PATH` 상수, `traits` 배열 및 `traits_by_id` 딕셔너리 추가. `reload()`에 로드 로직 포함.
- `MetaProgression.gd`:
  - `get_trait_bonus()` — `data["trait_bonuses"]` 딕셔너리 하드코딩 방식 → `DataRegistry.traits` 룩업으로 교체.
  - `_check_progression_unlocks()` — 엔딩 기반 언락 추가: `stable_success`/`ordinary_life` → 안정 지향형, `gangnam_dream` → 강남드림 계승자.
- `StartMenu.gd` — `trait_desc_label` 추가. 트레이트 선택 시 `_on_trait_selected()` 콜백으로 설명 + 보너스 요약 실시간 표시.

## 2026-05-16 (Init)
- Standardized project management around an independent GitHub Desktop repository.
- Published the Godot project to GitHub.
- Added documentation structure for future requirements, roadmap, decisions, and release notes.

## 2026-05-16 (Prototype Improvement Pass)

### 버그 수정
- `GameState.check_game_over()` 엔딩 ID 불일치 수정 (`health_collapse` 등 → `burnout` 등).
- 65세 도달 시 자산 기준으로 `stable_success` / `ordinary_life` 분기 추가.
- `_set_stat_value()` warn/danger 파라미터 순서 역전 버그 수정 (건강/정신력 색상 기준 정상화).

### UI 개선 (MainGame.gd)
- 모달 `ScrollContainer` 추가.
- 모달 타이틀 + X 닫기 버튼 구조로 개편.
- 메인메뉴 복귀 버튼 추가 (자동저장 후 이동).
- 인벤토리 "사용" 버튼 추가 → `InventorySystem.use_item()` 연결.
- 투자 모달: 매수 금액 선택(10만/50만/100만), 분할 매도(25%/50%/전량), 수익률 표시.
- 시장 티커: 전달 대비 등락률(%) + 리스크 점 표시.
- 로그 BBCode 활성화, 타입별 색상 구분.
- 스탯 패널 색상 경고 (건강/정신력/스트레스).
- 이벤트 선택 후 `result_text` 결과 화면 추가.
- 엔딩 화면: 등급 색상, 새 런 / 메뉴 버튼 추가.
- 뉴스 루머 표시 (`[루머]` 접두사).
- 관계 패널 한국어 유형 표기, 친밀도 레이블.

### 콘텐츠 교체
- `items.json` 30개 플레이스홀더 → 실제 한국 생활 아이템.
- `jobs.json` 15개 설명 교체, 카테고리 정정.
- `endings.json` 10개 설명 전면 교체.
- 이벤트 `result_text` 584개 전체 생성.

### 문서화
- `CLAUDE.md` 생성 (Codex 세션 컨텍스트).
- `docs/` 전체 오늘 세션 반영.

## 2026-05-16 (QA & Toast Integration)

### 버그 수정
- `EndingSystem.evaluate_current_ending()` 엔딩 ID 불일치 수정 — `health_collapse` → `burnout`, `mental_burnout` → `mental_break`, `debt_spiral` → `bankruptcy`, `ordinary_retirement` → `ordinary_life`, `upper_middle` → `stable_success`. (`GameState.check_game_over()`는 이전 패스에서 수정됐으나 이 함수는 누락됐었음.)

### UI 개선
- `NotificationToast` 연결 완료 — `MainGame.gd`에 `_toast_container` 및 `_show_toast()` 추가.
- 저장, 직업 변경, 매수, 매도, 아이템 구매/사용 시 토스트 피드백 표시.

## 2026-05-16 (Appearance Stat Implementation)

### 기능 구현
- `appearance` 스탯 효과 전면 구현.
  - **UI**: 스탯 패널에 `외모` 항목 추가 (기존에 저장만 되고 미표시였음).
  - **직업 요건**: `유튜브 크리에이터`(min 55), `보험 영업직`(min 48), `외국계 세일즈`(min 52)에 `min_appearance` 요건 추가.
  - **JobSystem**: `_check_requirements()`에 `min_appearance` 케이스 추가.
  - **RelationshipSystem**: 외모 60 이상일 때 연애 관계(`romantic`) 호감도 월간 감소 차단.

## 2026-05-16 (Save/Load Validation)

### 버그 수정
- `GameState.load_from_dict()` — JSON 역직렬화 시 int 필드가 float으로 복원되는 버그 수정. `age`, `health`, `mental` 등 14개 필드에 명시적 `int()` 변환 추가. (미수정 시 UI에 `"50.0"` 등으로 표시됨)
- `SaveManager.load_game()` — 저장 파일 버전 불일치 시 경고 없이 로드하던 문제 수정. `push_warning()` 추가 및 미래 마이그레이션 훅 위치 확보.
- `SaveManager.save_game()` — `action_log`/`news_log`/`event_log` 무한 증가 방지. 각각 최근 100/60/100개로 캡 적용.

