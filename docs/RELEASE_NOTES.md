# Gangnam Dream Release Notes

## Unreleased

### Balancing (2026-06-10) — 난이도 조정
- **투자 드리프트**: 월 0.35% → 0.6%(연 7.2% 기대수익), 크래시 피해 축소
- **arc 기회 이벤트 버프**: 임상철 부동산(성공률 +10%p, 배수 1.6→2.8), 한지연 분양권(+10%p, 배수 2.4→4.0)
- **신규 투자 이벤트**: `inv_ipo_hot_tip`(공모주, 12턴+), `inv_redev_zone_tip`(재개발, 28턴+, rare)
- 목표 달성률 추정치: 1~3% → 5~8% (플레이어 베팅 전략 따라 상이)

### Added (2026-06-10) — 인게임 폴리시 3종
- **중간 저장/불러오기**: ≡ 시스템 메뉴에 슬롯 1–3 저장·불러오기 패널 추가. 슬롯별 저장 일시, 연도·월·총자산 표시.
- **직업 승진 현황 UI**: 💼 일·커리어 탭에서 근속 ProgressBar, 업무 성과 60+ 게이트, 다음 직급 예시 표시. 최고 직급 달성 시 이직 안내로 대체.
- **목표 달성 속도**: 상황판 마일스톤 힌트 하단에 "현재 수입만으로 N개월 필요" 추가. 잔여 시간과 비교해 투자 필요성 경고.

### Added (2026-06-10) — Steam Deck 대응
- `export_presets.cfg`에 "Linux / Steam Deck" 프리셋 추가 (x86_64, embed_pck 단일 바이너리).
- `tools/build.sh`에 `linux` 타겟 추가 (`./tools/build.sh linux` → `build/linux/GangnamDream.x86_64`, chmod+x 자동 처리).
- 모든 Button 헬퍼(`_button`·`_action_button`·`_small_button`)에 포커스 스타일박스 추가: 포커스 시 금색(#f0b429) 테두리 강조.
- 컨트롤러 포커스 자동 이동: 이벤트 선택지 첫 버튼, 결과 확인 버튼, 모달 첫 버튼, AP 소진 시 다음 달 버튼에 각각 grab_focus.
- StartMenu "새 이야기 시작" 버튼에 초기 포커스, 슬롯 버튼에 금색 포커스 링.
- 뷰포트 1280×800이 Steam Deck 화면과 일치 — 해상도 조정 불필요.
- Linux 빌드 실검증: `GangnamDream.x86_64` 164MB 단일 바이너리 export 성공.

### Added (2026-06-10) — 스팀 출시 준비: 데스크톱 폴리시 + 빌드 파이프라인
- `DisplayManager` autoload 신설: 전체화면 설정 영속화(`user://gangnam_dream_display.json`), F11/Alt+Enter 전역 토글, 창 최소 크기 960×600, 창 X 버튼으로 닫을 때 진행 중 런 자동저장. 웹 빌드에서는 비활성(브라우저 충돌 방지).
- StartMenu ⚙️ 설정과 MainGame ≡ 시스템 메뉴에 🖥️ 전체화면 토글 추가 (단축키 힌트 표시).
- MainGame ESC 키 동선: 평소엔 시스템 메뉴 열기, 시스템 메뉴가 열려 있으면 닫기. 이벤트/결산 모달은 흐름 보호를 위해 ESC 비대상.
- `export_presets.cfg` 저장소에 추가 (Windows x86_64 단일 exe[pck 임베드]/macOS universal/Web). `.gitignore`에서 제외 해제 — 서명 키 등 비밀정보 없음.
- `tools/build.sh`: `GODOT=경로` 환경변수 지원(audit.sh와 동일), Linux 템플릿 경로 지원, windows 사용법 문구 추가.

### Verified (2026-06-10) — 헤드리스 QA (Godot 4.6.2)
- 전체 스크립트 컴파일 체크 38개 깨끗 (DisplayManager 포함).
- SimRun 60턴 경제 시뮬 12,000런: 데드락 0, 크래시 0, 승리(30억) 도달률 정책별 1.3~3.6%.
- SmokeRace 경마 런타임 스모크 전체 통과.
- Windows exe(196MB)·Web 빌드 실제 export 성공 — `./tools/build.sh windows` 엔드투엔드 검증 완료.

### Added (2026-06-09) — 핵심 인물/CG/스플래시 보강
- 주요 조연 독립 포트레이트 6종 추가: `npc_father`, `npc_mother`, `npc_jaehyuk`, `npc_team_lead`, `npc_goshiwon_owner`, `npc_seongjun`.
- 실제 콘텐츠에서 참조하는 스토리 CG 3종 추가: `ending_father`, `jaehyuk_reveal`, `jiyeon_crash`.
- 인게임 스플래시 키아트 `gangnam_dream_keyart_rooftop.png`를 완전 애니/한국 만화풍 rooftop-to-Gangnam 이미지로 교체.
- `ImageRegistry`에서 부모님/재혁/팀장/고시원 원장/성준 alias를 독립 파일로 연결.
- 실제 콘텐츠에서 쓰지 않는 미래용 CG 슬롯 3종(`cg_father_phone`, `cg_crisis`, `cg_gangnam_door`)은 레지스트리에서 제거해 누락 에셋 혼선을 줄임.
- `main_character_happy`와 `jiyeon_crash`의 부자연스러운 구도(폰 방향, 자전거/차문 설정)를 수정한 이미지로 교체.
- 홀덤용 `card_back.png`, `poker_chip_icon.png`를 실제 포커 카드/칩 구조의 UI 에셋으로 교체. 코드 연결은 별도 작업.

### Fixed (2026-06-09) — 주인공 초상화 상태 로직
- 33세 시작이라는 이유만으로 `main_character_30s`가 초반부터 표시되던 조건을 수정.
- `main_character_30s`는 아파트/강남 주거 또는 총자산 1억 이상 같은 중후반 상승 상태에서만 표시.

### Added (2026-06-09) — 에셋 생성 파이프라인
- `tools/generate_assets.py` 추가: 44개 이미지 에셋 생성 프롬프트, `gpt-image-2` 기본 모델, `--model`/`--quality`/`--force`/`--dry-run`/`--limit` 옵션 지원.
- 기존 전체 에셋 편차 분석 후 완전 애니/한국 만화풍 VN 기준 `STYLE_SUMMARY`를 모든 이미지 프롬프트 앞에 자동 접두.
- 기존 파일은 기본 스킵하고, API 실패 시 경고 후 다음 에셋으로 진행하며, 완료 시 `assets/ASSET_INDEX.md`에 generated/skipped/failed 체크리스트를 기록.
- `openai` SDK가 없으면 `requests` 전송으로 자동 fallback.

### Changed (2026-06-09) — 주인공 애니풍 포트레이트
- `main_character_neutral_goshiwon`, `main_character_tired`, `main_character_determined`, `main_character_happy`, `main_character_shocked`, `main_character_30s`, `main_character_50s`를 완전 애니/한국 만화풍 VN 스타일로 교체.

### Changed (2026-06-09) — NPC/신규 배경 애니풍 에셋
- NPC 5종(`npc_romantic_interest`, `npc_boss`, `npc_close_friend`, `npc_mentor`, `npc_tip_seller`)을 완전 애니/한국 만화풍 VN 스타일로 교체/추가.
- 신규 배경 6종(`racetrack_betting_hall`, `racetrack_track_view`, `holdem_club_interior`, `scalping_trading_room`, `aruba_delivery_street`, `gangnam_station_exit`)을 1280×800 애니 배경 미술 스타일로 추가.

### Removed (2026-06-01) — 트레이트(특성) 시스템 완전 제거
- 드라마 피벗으로 StartMenu 트레이트 선택이 사라진 뒤 모든 트레이트 패시브가 죽은 코드였음 → 전면 제거.
- `current_trait` 변수, `_apply_trait_bonus()`, `MetaProgression`의 트레이트 해금/보너스 로직, `content/meta/traits.json` 삭제.
- 투자 수수료/매도 증폭의 트레이트 분기, 스탯 패널·엔딩 화면의 트레이트 표시 제거.
- 캐릭터성은 성향(직장/투자/창업) 자각 시스템(`tendency`)으로 대체.
- 업적·칭호 해금은 그대로 유지(트레이트와 무관한 별도 시스템).

### Added (2026-05-27) — 이미지 에셋 연동

#### 배경 이미지 8종 신규 (Codex 생성)
- `convenience_store_night` / `cafe_seoul` / `investment_phone` / `hospital_corridor`
- `rooftop_daytime` / `gangnam_night_street` / `penthouse_view` / `burnout_hospital_room`

#### 캐릭터 포트레이트 추가
- `main_character_shocked` — 건강·정신 -15이상 or 돈 -100만이상 선택지 후 1.2초 자동 표시

#### 이벤트-배경 자동 매핑
- `_get_bg_for_event()` 태그/카테고리 기반 11케이스 매핑 (기존 3 → 11)

#### 엔딩 화면 배경 전환
- 엔딩 종류에 따라 배경 자동 전환 (13개 엔딩 ID 전부 매핑)
  - S급 성공 (gangnam_dream / stable_success / lonely_rich / investment_master / startup_exit) → 펜트하우스
  - 정치/명성 (political_fix / reputation_legend) → 강남 야경
  - 건강 은퇴 (healthy_retirement) → 서울 옥상
  - 번아웃/정신붕괴 (burnout / mental_break) → 병원 병실
  - 파산/코인망령/평범 → 서울 야경 (기본)

### Added (2026-05-27) — 특수 엔딩 트리거 구현

#### 스타트업 엑싯 경로
- 이벤트 2종: `startup_opportunity` (창업 제안) → `startup_acquisition_offer` (M&A 인수)
- 수락 시 4억 수령 + 즉시 `startup_exit` A등급 엔딩 발동

#### 정치인 경로
- 이벤트 2종: `political_recruitment` (보좌관 제안) → `political_election_victory` (당선)
- 65세 도달 시 자산 1억+ 조건으로 `political_fix` B등급 엔딩 발동

#### 코인 망령 경로 강화
- 도박/코인 이벤트 6개 위험 선택지에 `addiction_tendency` 증가 추가
- 누적 90 도달 시 즉시 `crypto_ghost` F등급 엔딩

### Fixed (2026-05-27) — 엔딩 조건 재정비
- `investment_master` 스킬 조건 85 → 75 (기존 사실상 도달 불가)
- `stable_success` / `lonely_rich` 자산 기준 10억 → 8억
- `healthy_retirement` 최소 자산 5,000만 조건 추가
- `political_fix` 조건 격상 및 체크 순서 최우선으로 이동

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
