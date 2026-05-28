# Gangnam Dream Release Notes

## Unreleased

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

