# Gangnam Dream Release Notes

## Unreleased

### Added (2026-05-27) — 타이틀 스플래시 화면

#### 스플래시 씬 (`SplashScreen.tscn`)
- 게임 최초 실행 시 타이틀 스플래시 → StartMenu 흐름으로 변경
- 키아트 배경 + 로고 + 타이틀 + 태그라인 순차 페이드인 (~4.5초)
- "아무 키나 눌러 계속" 힌트 표시 + 깜빡임 효과
- 키보드·마우스 클릭으로 즉시 스킵 가능

### Added (2026-05-27) — UI 대시보드 개선

#### 탑바 바이탈 HUD
- 탑바 상시 표시: `❤ 건강` / `🧠 정신력` / `😤 스트레스` 수치 + 6칸 블록 진행 바
- 임계값 색상 코딩: 위험(빨강) / 경고(노랑) / 정상(초록·파랑·민트)
- 정보 패널 열지 않아도 핵심 바이탈 항상 확인 가능

#### 스탯 패널 진행 바
- 정보 패널 내 건강/정신/스트레스: 숫자 옆에 10칸 블록 바 표시 (예: `63  ██████░░░░`)

### Added (2026-05-27) — 투자 차트 + 한국어 톤 패스

#### 투자 차트 히스토리 시각화
- 투자 모달 상단: 포트폴리오 전체 수익률 요약 (원금→현재가치, 수익률%)
- 자산별 스파크라인 + 1개월/3개월/12개월 변동률 표시
- 시황 티커: 6개월 미니 스파크라인 추가

#### 한국어 톤 패스
- `life_events.json` 플레이스홀더 설명 35개 전부 제거 → 개별 장면 묘사로 교체
  (family, social, politics, gambling, military, health, disasters, comedy, finance, romance 전 카테고리)
- 톤: 2030 서울 청년의 자조적·담백한 일상 감각

### Added (2026-05-27) — Polish Beta

#### 관계 패널 능동 상호작용
- `🤝 인맥관리` AP 행동이 모달로 전환 — 관계 목록 + 유형별 전용 선택지 표시
  - 친구: ☕ 커피 한 잔 (친밀도 +12, 정신 +3, 스트레스 -5)
  - 연인: 💑 데이트 / 📞 연락 (친밀도 60+ 기준 분기, 정신 +5, 스트레스 -8)
  - 멘토: 🧠 조언 / 📩 근황보고 (신뢰 50+ 기준 분기, 지력·투자감각 성장)
  - 비즈니스: 🤝 파트너 미팅 (신뢰 +8, 평판 +2)
  - 가족: 📞 통화 (친밀도 +10, 정신 +5, 스트레스 -4)
  - 🌐 새 인연 만들기: 사회성 +3, 50% 확률로 이름 풀에서 인연 생성

#### 직업별 이벤트 조건 강화
- `EventManager.gd`: `min_job_tier`, `max_job_tier`, `job_category` 이벤트 조건 신규 지원
- 직업 없이 뜨던 이벤트 5종 수정: `has_job: true` 추가 (첫 회식, 업무 카톡, 연차, 피드백, 험담)
- 이직/퇴사 이벤트 3종: `has_job: true` 추가 + 플레이스홀더 설명 교체
- 야근·성과 이벤트 3종: `min_job_tier: 2` 추가 (T2+ 직장에서만 발생)

#### 엔딩 화면 메타 진행도 표시
- 엔딩 화면에 `🔓 이번 런 해금` 섹션 추가 — 신규 트레이트·업적 실시간 표시
- `MetaProgression.get_new_unlocks()` API 추가

### Fixed (2026-05-27) — 밸런스 패스
- **고시원 월세 800,000 → 650,000원**: 설계 기준 불일치 수정. 신규 플레이어 Turn 2 즉시 현금위기 방지.
- **무직 스트레스 이중계산 제거**: `JobSystem.process_monthly_job()` 무직 +2 스트레스 제거. 총 무직 스트레스 +8 → +6/월로 정상화.
- **T3 직업 스트레스 곡선**: 공공기관 계약직(stress +2→+3), 부동산 중개보조(stress +3→+4). T1 동급 스트레스로 T3 직업이 우열 없이 선택되던 문제 수정.

### Added (2026-05-27)
- 초반 이벤트 3종: `first_job_rejection` (구직 후 첫 탈락), `convenience_midnight_snack` (자정 편의점 딜레마), `small_unexpected_win` (작은 행운).
- Turn 2 라이벌 첫 소개 메시지 자동 표시 (`RivalSystem`).
- Turn 1 액션 단계 "서울 첫 달" 가이드 힌트.
- 첫 취업 시 특별 토스트 피드백 (🎉 초록색, housing_up SFX).

### Fixed (2026-05-27)
- **[Critical]** `story_arrival_elite`·`story_arrival_rich` → `follow_up_event: "story_pressure"` 누락. 명문대/금수저 배경에서 구직 영구 잠금 현상.
- **[Critical]** `story_first_workday`·`story_first_paycheck_feel`·`story_first_savings_milestone`·`story_six_months`·`story_one_year` → `seen` 플래그 누락으로 매 턴 무한 트리거.
- story 이벤트가 random pool에 등장하던 문제 (`conditions.min_turn: 9999`로 차단).

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

