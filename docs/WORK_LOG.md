# Gangnam Dream Work Log

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

