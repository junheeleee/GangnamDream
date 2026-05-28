# Gangnam Dream Release Notes

## Unreleased

### Added (2026-05-28 — Phase 2-A 취준생 페이즈 + 스토리 마일스톤)
- **스토리 마일스톤 3개 추가** (기존 코드에서 참조하나 존재하지 않아 무음 실패하던 것 수정):
  - `story_one_half_year` — 1년 반 적응의 시간 (턴 18)
  - `story_two_year` — 2년 차 갈림길 (턴 24)
  - `story_three_year` — 3년 20대의 절반 (턴 36)
- **취업 준비 피드백 시스템**: 구직 모달에 이력서/면접 준비도 표시 + 취업 보너스 사전 안내
- **취업 준비 보너스**: `apply_for_job()` 시 이력서 완성 +10, 면접 연습 +7 업무능력 보너스 (플래그 소모)
- **새 이벤트 5개**: age_25_crisis, gosiwon_escape_day, investment_first_profit, five_year_seoul, career_pivot_temptation

### Fixed (2026-05-28 — Phase 2-A)
- `job_rejection_blues` 조건 수정: 재취업 준비 중인 플레이어에게도 표시
- `career_crossroads` 반복 방지 플래그 추가
- `drama_startup_offer` "합류" 선택지에 `startup_launched` 플래그 누락 수정 → 창업 섹션 정상 표시
- `drama_viral_moment` "채널 키우기" 선택지에 `creator_started` 플래그 누락 수정
- `midlife_30s_reflection` 타이밍 수정: 실제 30세 시점으로 이동 (min_turn 36 → 120)
- 중복 이벤트 ID 3개 제거 (story milestone이 life_events.json에도 잔존)



### Added (2026-05-28 — Content Expansion + Critical Bug Fixes)
- **320 total events** (life: 197, story: 16, drama: 27, investment: 30, relationship: 30, hidden: 20)
  - 20 new mid-game life events (min_turn: 12+): 연차 평가, 헤드헌터 연락, 동료 퇴사, 전세 시장 충격, 회식, 번아웃, 청약 탈락, 친구 집 구매, 대출 투자 유혹, 커리어 한계, 연차 쉬기, 배당 시즌, 새벽 편의점, 코인 급등, 30대 회고, 가족 금전 부탁, 자산 점검, 종합소득세, 강세장 유혹, 폭락장
  - `drama_office_politics` 이벤트 추가 (승진 후 사내 암투)
  - `gosiwon_midnight_fire_drill` — 고시원 새벽 화재 경보
  - `job_interview_wait` — 면접 결과 대기 (적절한 선택지로 재작성)
  - `stock_portfolio_crash` — 폭락장 의사결정 이벤트

### Fixed (2026-05-28 — Critical)
- **스토리 이벤트 무한 반복 버그** — `story_events.json`의 `story_first_workday`, `story_first_paycheck_feel`, `story_first_savings_milestone`, `story_six_months`, `story_one_year`, `story_gosiwon_neighbor` 선택지에 `*_seen` 플래그 누락. `trigger_event_by_id()`는 쿨다운을 우회하므로 플래그 없으면 매 턴 같은 스토리 이벤트가 반복됐음.
- **story_arrival_elite/rich 취업 해금 누락** — 배경이 명문대_중퇴/금수저인 플레이어는 `story_pressure` 체인이 없어 `story_job_unlocked` 플래그가 설정되지 않았음. 이제 도착 이벤트 선택지에서 직접 설정.
- **이벤트 중복 ID 9개 제거** — `story_arrival`, `story_six_months`, `story_one_year`, `story_first_paycheck_feel`, `story_first_workday`, `story_first_savings_milestone`, `story_arrival_elite`, `story_arrival_rich`, `drama_office_politics` 가 `life_events.json`에 중복 존재하던 것 제거 (story_events.json/drama_events.json이 정본).

### Added (2026-05-28 — RPG/Roguelike Pass)
- 월별 크라이시스/보너스 롤: 6% 보너스(AP+1, 추가수입, 강세장) + 18% 크라이시스(긴급지출, AP-1, 시장충격, 건강위기). 3턴 이후 매달 발동.
- 레버리지 투자: 동일 금액으로 2배 포지션, 수수료 1.5%, 마진콜(원금 35% 이하 시 강제청산 85% + 스트레스+20).
- 스탯 임계값 RPG 성장 시스템: 투자스킬/지력/사회성이 30/50/70 돌파 시 토스트 해금 알림 + 로그 기록.
- 조건부 행동 버튼 4종: 심화 독서(지력30+), 시장 분석[무료](지력50+), 레버리지 투자(투자스킬30+), VIP 인맥(사회성50+).
- 무료 행동 지원: AP=0에서도 `free: true` 버튼은 활성화.
- 시장 예보 텍스트: 크래시 위험/싸이클/공포지수 기반 5종 메시지.
- 투자 모달 AP 힌트 레이블.

### Fixed (2026-05-28)
- 투자 모달 오픈 시 행동력 즉시 소비 버그 — 실제 매수·매도 시에만 AP 차감.
- 이벤트 중복 ID: `rel_jobs_003`, `invest_finance_011`으로 고유화.
- 이벤트 설명 보일러플레이트 63개 고유 텍스트로 교체.
- BGM 무한 루프: `finished` 시그널 백업 추가.

### Changed (2026-05-28)
- 크래시 확률 상향: `crash_risk * volatility * 0.5` → `* 1.2`, 기본 위험 0.03 → 0.05.
- 이벤트 최근 기억 창: 14 → 25개로 확장 (반복 억제 강화).
- 정보 패널 구조: 단순 TabContainer → VBoxContainer(헤더+탭) 개편, ✕ 닫기 버튼 추가.

### Added
- 메타 진행 트레이트 시스템 — `traits.json` 5종 정의, 자산/엔딩 기반 언락 조건, 런 시작 시 보너스 적용.
  - 기본: 흙수저 생존본능.
  - 해금: 야근 면역자(5천만↑), 리스크 중독자(2억↑), 안정 지향형(stable_success/ordinary_life 엔딩), 강남드림 계승자(gangnam_dream 엔딩).
- 스타트 메뉴 트레이트 설명 표시 — 선택 시 설명 + 스탯 보너스 요약 실시간 표시.
- Save/Load int 필드 타입 복원 수정 — 로드 후 스탯이 float으로 표시되던 버그 해결.
- Save 로그 크기 캡 적용 — action_log 100개, news_log 60개, event_log 100개.
- `appearance` 스탯 효과 구현 — 스탯 패널 표시, 직업 요건 3종(유튜브 크리에이터/보험 영업/외국계 세일즈), 연애 관계 호감도 감소 완화.
- `NotificationToast` UI 연결 — 저장, 직업 변경, 매수/매도, 아이템 구매/사용 시 화면 우측에 토스트 피드백 표시.
- `CLAUDE.md` — Codex/Claude Code 세션 컨텍스트 파일.
- 투자 모달: 매수 금액 3단계 선택(10만/50만/100만원).
- 투자 모달: 분할 매도(25%/50%/전량) + 보유 수익률 표시.
- 인벤토리 아이템 "사용" 버튼.
- 메인메뉴 복귀 버튼 (자동저장 포함).
- 이벤트 선택 후 `result_text` 결과 화면 (확인 버튼으로 진행).
- 시장 티커 등락률(%) 색상 표시 + 리스크 레벨 점 표시.
- 로그 타입별 색상 구분 (BBCode).
- 스탯 패널 임계값 색상 경고 (건강/정신력/스트레스).
- 엔딩 화면 등급별 색상, 새 런 시작 / 메뉴 버튼.
- 65세 도달 시 자산 기준 `stable_success`(5억+) / `ordinary_life` 분기.
- 뉴스 루머 표시.

### Fixed
- 엔딩 ID 불일치 버그: `health_collapse` → `burnout`, `mental_burnout` → `mental_break`, `debt_spiral` → `bankruptcy`, `ordinary_retirement` → `ordinary_life`.
- `EndingSystem.evaluate_current_ending()` 잔존 구 ID 수정 (이전 패스에서 누락).
- `_set_stat_value()` warn/danger 파라미터 역전 버그 (건강 50↓ 노랑, 30↓ 빨강).
- 모달 오버플로: `ScrollContainer` 추가.

### Changed
- `items.json` 30개: 플레이스홀더 이름/설명/아이콘 → 한국 생활 맥락 아이템.
- `jobs.json` 15개: 설명 전면 교체, 카테고리 정정 (예: `"tech"` → `"survival"`).
- `endings.json` 10개: 설명 전면 교체 (서사/감정 포함).
- 이벤트 `result_text` 584개 전체 생성 (기존 전부 공백).
- 모달 구조 개편: 헤더(타이틀+X) + 스크롤 바디.

### Documentation
- Repository structure standardized for project-specific development.
- `docs/` 문서 구조 추가.

