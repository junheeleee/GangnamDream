# Gangnam Dream Work Log

## 2026-05-27 (UI 대시보드 개선 — 바이탈 HUD + 진행 바)

### 탑바 바이탈 HUD 추가 (Football Manager 스타일)
- `_build_top_bar()`: AP 레이블 우측에 `vitals_row` HBoxContainer 삽입
  - `vital_health` (❤ + 숫자 + 6칸 블록바), `vital_mental` (🧠), `vital_stress` (😤)
  - 세퍼레이터 `│` 로 AP / 바이탈 / 머니 시각적 구분
  - 건강/정신: 30↓ 빨강, 50↓ 노랑, 정상 초록/파랑
  - 스트레스: 80↑ 빨강, 60↑ 노랑, 정상 민트
- `_refresh_vitals()` 신규 메서드: `_refresh_all()` 호출 시 바이탈 갱신
- `_bar_str(value, max_val, bars)` 신규 헬퍼: `"█".repeat(filled) + "░".repeat(empty)` 블록 진행 바 생성

### 스탯 패널 진행 바 표시
- `_set_stat_value()`: 건강/정신/스트레스 항목에 10칸 블록 진행 바 추가 (`63  ██████░░░░`)
- 기타 스탯(지력, 사회성 등)은 기존 숫자 표시 유지

## 2026-05-27 (Polish Beta — 투자 차트 히스토리 + 한국어 톤 패스)

### 투자 차트 히스토리 시각화
- `MainGame._open_investments()`:
  - 포트폴리오 보유 시 전체 수익률 요약 헤더 추가 (원금 → 현재가치, 수익률 %)
  - 자산별 2줄 표시: ①자산명·리스크·현재가 ②스파크라인 + 1개월/3개월/12개월 변동률
- `MainGame._render_sidebars()` 시황 티커: 6개월 미니 스파크라인 추가

### 한국어 톤 패스
- `life_events.json` 플레이스홀더 설명 35개 → **전부 제거** (0개 남음)
  - 교체 대상: family, social_life, politics, gambling, military, health, disasters, comedy, finance, romance 카테고리 전반
  - 톤: 2030 서울 청년의 자조적·관찰적 시선. 과장 없이 담백한 일상 문장

## 2026-05-27 (Polish Beta — 관계/직업/엔딩 3종 개선)

### 관계 패널 능동 상호작용
- `MainGame.gd`: `_ap_network()` → `_ap_socialize()` + `_open_relationship_manager()` 모달로 교체
  - 관계 유형별 전용 행동: 친구=커피, 연인=데이트(친밀도 60+ 기준), 멘토=조언/근황보고(신뢰 50+ 기준), 비즈니스=파트너 미팅, 가족=통화
  - "새 인연 만들기" 선택지: 사회성 +3, 50% 확률 인연 생성 (이름 풀 16개)
  - 각 행동 후 turn_action_log, add_log, toast 피드백 연동

### 직업별 이벤트 조건 강화
- `EventManager.gd`: `min_job_tier`, `max_job_tier`, `job_category` 조건 추가
- `life_events.json`: 12개 이벤트 조건 패치
  - 직업 없이 뜨던 이벤트 5개에 `has_job: true` 추가 (첫 회식, 업무 카톡, 연차, 피드백, 험담)
  - 이직/퇴사 이벤트 3개: `has_job: true` + 설명 교체 (플레이스홀더 제거)
  - 야근/성과/프로젝트 이벤트 3개: `min_job_tier: 2` 추가 (T2+ 직장에서만)

### 엔딩 화면 메타 진행도 표시
- `MetaProgression.gd`: `_new_this_run` 딕셔너리 추가, `record_run()` 시작 시 초기화
  `unlock_trait()` / `unlock_achievement()` 호출 시 신규 해금이면 목록에 추가
  `get_new_unlocks()` 메서드 추가
- `MainGame.gd `_show_ending()`: 새 해금 트레이트/업적 표시 (🔓 섹션, 업적 ID→한글명 매핑)

## 2026-05-27 (밸런스 패스 — 초반 생존성 개선)

### 수치 조정
- **고시원 월세**: 800,000원 → **650,000원** — 설계 기준(CLAUDE.md) 불일치 수정. 신규 플레이어가 Turn 2에 현금위기(-30만)로 즉시 패닉하던 문제 해소. 1개월 여유 버퍼 확보.
- **무직 스트레스 이중계산 제거**: `JobSystem.process_monthly_job()` 무직 시 +2 스트레스 제거. `apply_monthly_pressure()`에서 이미 +6/월 처리 중. 총 무직 스트레스 +8 → **+6/월**으로 정상화.
- **T3 직업 스트레스 곡선**: 공공기관 계약직(+2→+3), 부동산 중개보조(+3→+4). T3 직업이 T1 직업과 동일한 스트레스를 가지면서 월급은 훨씬 높던 우열 구도 해소.

### 분석 내용
- 15개 직업 전체 스트레스·급여 커브 검토
- `InvestmentSystem.gd` 수익 구조 분석: drift +0.3%/월, 크래시 확률 및 위험도 밸런스 적절 — 조정 불필요
- `assets.json` 18개 자산 변동성·최소 투자금 검토 — 현행 유지

## 2026-05-27 (이벤트 확충 — Content Alpha 달성)

### 콘텐츠 추가
- 투자 이벤트 14 → **30개** (+16): 리밸런싱, 단톡방 주식 정보, 시장 폭락 경보, 배당금 입금, 손절 결정, 공모주 청약, ETF 공부, 부동산 버블 공포, 경기침체 우려, 투자 서적, 선배 내부 정보, 금융소득 과세, 적립식 투자, 코인 광풍, 해외 주식, 1년 수익률 점검
- 관계 이벤트 15 → **30개** (+15): 멘토 커피, 동료 갈등, 소개팅, 친구 이별 위로, 부모님 상경, 전 연인 연락, 사무실 뒷담화, 썸 진전, 사업 파트너 제안, SNS 비교, 멘토 쓴소리, 가족 대출 부탁, 팀 회식, 네트워킹 세미나, 새벽 통화

### 품질 개선
- 기존 투자 14개 + 관계 15개 설명 전면 개선: 동일한 플레이스홀더 텍스트를 이벤트별 개별 장면 묘사로 교체

### Content Alpha 달성 현황
| 콘텐츠 | 목표 | 현재 | 상태 |
|--------|------|------|------|
| 일반 생활 이벤트 | 100개+ | 106개 | ✅ |
| 투자 이벤트 | 30개 | 30개 | ✅ |
| 관계 이벤트 | 30개 | 30개 | ✅ |
| 히든 이벤트 | 20개 | 20개 | ✅ |
| 직업 | 15개 | 15개 | ✅ |
| 아이템 | 30개 | 30개 | ✅ |
| 엔딩 | 10개 | 14개 | ✅ |

## 2026-05-27 (첫 30분 몰입도 개선)

### 버그 수정 (Critical)
- `story_arrival_elite`, `story_arrival_rich` → `follow_up_event: "story_pressure"` 누락 수정.
  명문대/금수저 배경에서 구직 해금(`story_job_unlocked`)이 永久 잠겼던 문제.
- `story_first_workday`, `story_first_paycheck_feel`, `story_first_savings_milestone`, `story_six_months`, `story_one_year` → `seen` 플래그 누락 수정.
  매 턴 무한 반복 트리거 방지 (`flags: ["...seen"]` 형식으로 통일).
- story 이벤트가 random pool에 노출되지 않도록 `conditions: {min_turn: 9999}` 추가.

### 신규 콘텐츠
- `first_job_rejection` (life_events.json): 구직 해금 후 무직 상태 단발 이벤트. 첫 취업 전 긴장감 서사 추가.
- `convenience_midnight_snack` (life_events.json): 자정 편의점 도시락 딜레마. 초반 6개월 이내 한정.
- `small_unexpected_win` (life_events.json): 5만원 발견 행운 이벤트. luck≥40, 초반 한정.

### 튜토리얼/UX 개선
- `MainGame.gd`: `tutorial_step >= 3` 조건 추가 — Turn 1 액션 단계에서 "서울 첫 달!" 힌트 표시.
- `MainGame.gd`: 첫 취업 시 🎉 특별 토스트 피드백 (housing_up SFX + 초록 강조색). 이직 시 기존 노란 토스트 유지.

### 라이벌 시스템
- `RivalSystem.gd`: Turn 2에 라이벌 첫 소개 메시지 자동 표시. 이름·나이·출발선 공개, 경쟁 의식 조기 형성.

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

