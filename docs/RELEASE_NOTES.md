# Gangnam Dream Release Notes

## Unreleased

### Added (2026-06-19) — Audio P1 ambience and ending stingers

- Added 5 ambience WAV layers for goshiwon room, Seoul rain, Han River, office, and casino floor scenes.
- Added 3 ending stingers for good, bad, and legendary endings, selected by ending grade/id.
- Added a separate low-volume ambience layer in `BGMPlayer` so location audio can change independently from the main BGM.
- Extended `AudioAssetCheck` to validate ambience files. It now passes with `bgm=7 ambience=5 sfx=28`.

### Changed (2026-06-19) — Investment/shop/system modal UI skin pass

- Reworked Investment, Bank, Shop, and System modals with icon-backed section headers and SVG/icon-backed CTA buttons.
- Removed emoji prefixes from major modal titles for a more consistent commercial UI tone.
- Extended `ScreenshotQA` with Bank, Shop, and System modal captures. Current screenshot QA output: 21 PNGs.

### Changed (2026-06-19) — Casino table UI and object-feel pass

- Cleaned MainGame info-panel tabs and action-category modal copy to reduce prototype/emoji UI feel.
- Cleaned Blackjack/Baccarat HUDs and primary action buttons into a more restrained casino-table style.
- Replaced SlotMachine reel emoji glyphs with stable text symbol tiles (`7`, `BAR`, `CHERRY`, `BELL`, `LEMON`) and fixed near-miss detection to use numeric reel ids.
- Added a Canvas-drawn Roulette wheel and ball so the roulette minigame shows a physical object instead of only changing numbers.
- Cleaned RaceTrack HUD/dealer/result copy and fixed its countdown callback path for headless smoke QA.
- Extended `ScreenshotQA` with Baccarat, Blackjack, Slot, and Roulette table captures and now clears stale screenshot PNGs before each run.

### Changed (2026-06-19) — Start menu and tutorial UI skin pass

- Reworked StartMenu difficulty/theme cards to use unified SVG icons instead of platform emoji glyphs.
- Cleaned up StartMenu settings, delete, start, and content-notice button copy.
- Replaced TutorialOverlay's large slide emoji with card/chip/UI-icon textures.
- Extended `ScreenshotQA` with a `00_start_menu.png` capture and suppressed automatic tutorial overlays so minigame body screens are visible in QA.
- Cleaned visible Holdem/RaceTrack rule/header controls to reduce emoji/prototype UI feel.
- Switched StoryMode backgrounds to covered scaling and replaced the top VN HUD emoji string with a text status bar.

### Changed (2026-06-19) — UI skin P1 and casino hub polish

- Reworked the MainGame HUD into icon-backed status chips for date, AP, health, mental, and money.
- Replaced the main direct-action text buttons with action cards containing a unified icon, title, short description, and AP/free badge.
- Rebuilt the first-run tutorial modal as compact rule cards instead of a long document-style instruction panel.
- Updated the Jeongseon Casino hub to use existing card-back and poker-chip UI textures instead of emoji game icons, added open fade-in, and connected casino entry buttons to casino SFX.

### Added (2026-06-19) — Player-facing polish QA and first dynamic pass

- Added `docs/PLAYER_FACING_POLISH_AUDIT.md`, a runtime-based audit of UI/UX, image assets, audio assets, minigame surface quality, and Godot motion priorities.
- Added 8 real casino SFX files for existing runtime keys: card, bet, coin, spin, reel, win, lose, and jackpot. `AudioAssetCheck` now passes with `bgm=7 sfx=25`.
- Added subtle MainGame background drift and switched the event background TextureRect to covered mode to reduce static web-page feel.

### Fixed (2026-06-19) — Red crisis effect and QA correction

- Reduced red crisis vignette intensity and limited it to true danger thresholds: health <= 25 or mental <= 15.
- Main dashboard/action vignette rendering now immediately clears lingering category tint and feedback flash, preventing non-crisis screens from staying red.
- Updated `CGRuntimeCheck` so it verifies ending CG plumbing without incorrectly requiring the removed hospital-father CG on the `gangnam_dream` victory ending.
- Fixed StartMenu legacy tagline from "100만원" to the current canon "50만원".

### Changed (2026-06-19) — Claude cloud branch merge cleanup

- Fast-forwarded local `main` to Claude cloud branch `origin/claude/game-polish-steam-uh6ldg` (24 commits ahead of `origin/main`).
- Reapplied and reconciled the Codex visual asset pass on top of the Claude story/English-translation branch: Jeongseon Casino, gym, Han River, Namsan, card-back, and poker-chip updates.
- Resolved merge conflicts in current-status docs, callback event metadata, release notes, work log, and decisions.
- Re-generated `docs/BACKGROUND_SEMANTIC_AUDIT.md` after the Claude branch merge. Current semantic REVIEW count: 129.
- Verified the merged state with `./tools/audit.sh`: ERROR 0 / WARNING 0, balance bands pass, Godot compile clean.

### Fixed (2026-06-17) — 자율 정적 QA 4차 (후반10)
- `_ap_startup_work` / `_ap_create_content`: "mental" 키를 modify_hidden_stat으로 잘못 라우팅 → STARTUP_VIGNETTES 4개 항목 mental 효과 무시되던 버그 수정
- `_ap_study`: 4개 고정 씬 → 40개 다양한 씬 (STUDY_*_VIGNETTES 4풀 연결)
- `_ap_network`: NETWORK_VIGNETTES 10개 씬 연결 (사교력·평판·정신력 비용 다양화)
- SAVE_VIGNETTES / RESUME_VIGNETTES / INTERVIEW_VIGNETTES 데드 상수 삭제
- 네트워크 버튼 레이블 "사회성 +1" → "사교력+, 평판+ (정신력 소모)" 실제 효과 반영

### Fixed (2026-06-17) — 자율 정적 QA 3차 (후반9)
- 스트레스→정신력 전환 잔존 UI 참조 전수 수정: MetaProgression 주거 보너스, `_show_vignette`/`_show_effects_float` merge 처리, 버튼 라벨·로그·힌트 텍스트, ArubaGame/JobHuntMiniGame 결과 화면, StoryMode 튜토리얼
- 이벤트 선택 시 float 표시 누락: stress 효과가 정신력 float으로 올바르게 표시되도록 merge 처리
- 충격 이벤트(`just_critical_event`) 감지: stress 효과 포함 effective_mental_delta 계산
- `has_job: false` → `no_job: true` 11건 수정 — 해당 이벤트가 절대 발동하지 않던 조건 버그

### Fixed (2026-06-17) — 자율 정적 QA 2차 (후반8)
- 이벤트 `result_text` 빈칸 30건 일괄 수정 (10개 JSON 파일: amb/callback/scenario_cafe)
- `GameState._resolve_opportunity()`: stress→mental 머지 잔류 이중 mental 패널티 정리 (`-3 + -6` → `-9` 단일 호출)
- `jaehyuk_way` 엔딩 배경 오류 수정: `gangnam_apartment` → `gangnam_night` (ENDING_ART.md 명세)
- `MainGame._show_ending()` `ending_bg_map` 중복 항목 3건 제거 (endings.json background 필드로 이미 커버)

### Fixed (2026-06-17) — 엔딩 배경/CG 톤 점검 (스크린샷 QA 전수)
- gangnam_dream 승리 엔딩의 잘못된 아버지 임종 CG 제거 → gangnam_apartment 배경 정상화
- stable_success/orthodox_pinnacle: 본문이 "강남은 아니었다"인데 펜트하우스(강남 럭셔리) 배경이던 모순 제거 → 옥상/회식 식당으로 중립화
- crypto_ghost: 코인 중독 본문에 비 오는 거리 → 트레이딩 화면으로 교체
- `docs/ENDING_ART.md` 신설: 26개 엔딩 전수 점검 + 신규 이미지/오디오 에셋 필요 목록 표시

### Changed (2026-06-17) — 스트레스/정신력 단일 스탯 통합
- 이중 정신 스탯을 `mental` 하나로 통합, `stress` 변수 제거 (적용 계층 리다이렉트로 JSON 미수정)
- 조건 `max_stress`/`min_stress`는 그대로 작성 가능 — 내부에서 mental 임계값으로 자동 변환
- 비네팅·BGM 위기 트리거·투자 판단 페널티·관계 감속 전부 mental 기준으로 통일

### Fixed (2026-06-17) — Godot 컴파일 에러 4종
- `tier` 변수 중복 선언, `phase` 타입 추론 실패, UI 헬퍼 4종 반환 타입 누락 (`:=` 파싱 실패)
- audit.sh의 Godot 컴파일 체크가 로컬 경로 문제로 스킵돼 누적돼 있던 잠재 파싱 에러 일소

### Added (2026-06-17) — 고닷 렌더링 연출 + 레버리지/게이팅
- 타이핑 효과, 비네팅 셰이더, 포트폴리오 라인차트, 화면 흔들기, [wave]/[shake], 골바 트윈, 코인버스트, 앰비언트 틴트
- 레버리지 투자 UI 연결(투자감각 30), 투자/도박 스토리 게이팅, 내러티브 이벤트 3종

### Added (2026-06-16) — 데모 전용 아크 이벤트
- `arc_four_months_in` (t=15): 한강 다리 한밤 씬 — 상철~재혁 구간 빈 자리 채움. 정석/비정석/침묵 3선택지.

### Fixed (2026-06-16) — 도박 이벤트 조기 노출 버그
- `race_first_visit`: `hidden:true` — 멘토 follow_up으로만 발동, 랜덤 풀 제거
- `holdem_first_visit`: `entered_network` 플래그 조건 추가 — 상철 네트워크 전 노출 차단

### Fixed (2026-06-16) — StoryMode 초상화 액자 프레임 제거
- 골드 테두리·어두운 매트·그림자 제거, 배경 위 직접 표시

### Fixed (2026-06-16) — 튜토리얼 캘린더 오류 수정 + UX 개선
- `TutorialOverlay` main_game 슬라이드: "1턴=1달" → "1턴=1주", "38세(60턴)" → "38세(240턴)", "다음 달 ▶" → "다음 주 ▶"
- `TutorialOverlay` 4번째 슬라이드 추가: "선택이 쌓이면 삶이 된다" (정석/비정석 철학)
- `_maybe_show_tutorial()`: TutorialOverlay 표시 후 중복 모달 팝업 방지
- `_show_tutorial_intro()` 죽은 코드 제거 ("AP 3개" 오류 포함)

### Fixed (2026-06-16) — 종합 버그 수정 (후반3)

**CRITICAL:**
- `drama_events.json`: `startup_exit`·`political_winner` 엔딩이 절대 달성 불가한 버그 수정 (플래그가 `effects.flag` 잘못된 키에 있어 무시됨 → `flags[]` 정위치로 이동)

**캘린더:**
- BGMPlayer: `turn >= 36` → `age >= 36` (late_tense BGM 9개월→3년 임박 시점으로 정상화)
- BGMPlayer: hustle 판정 → 경과 개월 기준 전환
- MetaProgression: loner_title 조건 주→월 수정
- MainGame: 카페 콜백 무한루프 방지, arc_after_scam 가드, _next_milestone_id 전환, 개월 표시 수정
- EndingSystem: get_score() 주→월 수정
- JSON 이벤트 55건: `min_turn`/`max_turn` 월→주 변환(×4) — chapter_break·final_stretch·father_arc 등 중후반 타이밍 정상화

**엔딩:**
- BGM: 신규 성공 엔딩 9종 good 목록 추가 (instant_legend 등 잘못된 배경 음악 수정)
- 배경: 16개 신규 엔딩 배경 할당
- 요약·에필로그: 10개 신규 엔딩 전용 텍스트 추가

**시스템:**
- JobSystem: 승진 후 퇴직 시 phantom salary 버그 수정 (`effective_salary` 추적)

### Added (2026-06-16) — 챕터 카드 + Chapter 1 반응형 씬 + 고아 플래그 콜백
- **챕터 타이틀 카드 5종** (chapter_cards.json): 연도별 챕터 경계(34/35/36/37세) 자동 트리거. 제목: 시작/확장/무게/균열/강남 (스포일러 없음)
- **t9 자산 반응형 3분기 씬**: arc_money_check_low/mid/high — 플레이어 순자산에 따라 완전히 다른 서사 흐름
- **`instant_legend` 히든 엔딩**: 33세 내 30억 달성 시 발동하는 이스터에그 엔딩 (grade "?", 보라색)
- **Chapter 1 콜백 이벤트 7종** (callback_events_27.json): t9~t11 선택의 기억이 t14~24 사이에 반응 이벤트로 발화
- **알바/편의점 개연성 수정**: `has_job: false` 조건 버그 전면 수정, 편의점 알바 고정 씬 제거, `job_id: job_01` 조건으로 교체
- **`job_id` 조건 키** (EventManager.gd): 특정 job id를 가진 플레이어에게만 이벤트 발화

### Fixed (2026-06-16)
- `daeun_met` / `daeun_first_kind` 고아 플래그 에러 해소 (arc_daeun_01_meet 패치)
- `has_job: false` 조건이 항상 무시되는 버그 수정 (bool(false)는 if문에서 false)
- 편의점 점원으로 고정된 씬들 플레이어 직업 미설정 시에도 발화하는 문제 수정

### Added (2026-06-16) — 중반 아크 이벤트 대규모 확장 (arc_midgame 29개)
- **19개 신규 arc 이벤트**: arc_midgame.json 10→29개. 턴 12~55 전 구간 감정 밀도 강화
  - 현수 아크 심화: drift(방황) → new_path(떠남) 브리지
  - 다은 아크 심화: money_gap(자산 격차) / trace(보낸 경우 편의점 기억)
  - 임상철 아크 심화: human(한우집, 처음으로 사람으로 보인다)
  - 재혁 사기 후: after_scam(다음 날 멍한 독백) 브리지
  - 자산 이정표: first_real_win(5천만) / money_loneliness(1억) / almost_there(10억) / final_stretch(20억) / gangnam_real_estate(25억)
  - 내적 장면: goal_vertigo(30억이 낯설어지는 순간) / night_routine(심야 루틴) / housing_new_life(새 집 첫날 밤)
  - 직장 장면: first_job_week(취직 첫 주) / quit_job(사표) / career_ceiling(월급 한계) / job_vs_invest(직장+투자 충돌)
  - 인물 없는 내적 독백: social_comparison(동창) / father_medication(아버지 약 문자)
- **JobSystem.gd**: `quit_job(voluntary=true)` → `just_quit_job` 플래그 자동 세트 → 사표 arc 트리거 연동

### Added (2026-06-16) — 그림자 이벤트 시스템 (테마/메카닉 괴리 해소)
- **deferred_events 엔진**: 선택지에 `deferred_follow_up` + `deferred_delay` 키 지정 → N턴 후 자동 발동
- **shadow_events.json**: 6개 그림자 이벤트 — 수금 전화(4턴 후), 소문 출처(5턴 후), 창업 약속(7턴 후)
- **audit.py 강화**: deferred_follow_up 체인 끊김 검사 + CHOICE_KEYS 화이트리스트 업데이트

### Added (2026-06-15) — 코인 단타 미니게임 + 튜토리얼 개선
- **CryptoGame**: 3라운드 코인 롱/숏 예측 미니게임 (캔들 흐름 분석, 12초 타이머, 투자감각 기반 힌트)
- **해금 조건 완화**: 투자감각 10 이상이면 즉시 접근 가능 — 스캘핑보다 일찍 투자 게임플레이 체험
- **튜토리얼 정석/비정석 라벨 제거**: "안정을 쌓으면 / 속도를 쌓으면"으로 성향을 설명하되 경로를 명명하지 않음

### Added (2026-06-15) — 30억 경로 명확화 + 아크 흐름 정비
- **arc_invest_guidance**: 12턴 이후 임상철이 투자 필요성을 플레이어에게 직접 안내하는 이벤트 추가
- **arc_sangchul_03_network 조건 완화**: 진입 자금 조건 500만 → 100만원
- **아크 패널 타이밍 힌트**: 각 캐릭터 진행 단계에 "N개월차 이후" 텍스트 표시
- **골 바 마일스톤**: 현재 자산에 따른 다음 목표 구간 표시 (→ 1억/5억/10억/20억/30억!)

### Added (2026-06-15) — AP 전면 게임화 완료
- **LifeSkillsMiniGame**: 절약·인맥·자기계발 AP 사용처 3종 완전 게임화
  - `Mode.BUDGET` (절약 퍼즐): 6개 지출 항목 토글, 목표 15만원, 항목별 스탯 패널티 트레이드오프
  - `Mode.NETWORK` (인맥 카드): 5인 NPC 풀 랜덤 3인, 10초 타이머, 성격 매칭 채점
  - `Mode.STUDY` (자기계발 퀴즈): 4주제 선택 후 3문 8초 타이머 퀴즈, quality별 스탯 배율 (0.3x~1.5x)
- **AP 전면 게임화 달성**: 알바(ArubaGame) + 구직(JobHuntMiniGame) + 생활기술(LifeSkillsMiniGame) 모든 주요 AP 사용처 인터랙티브화

### Added (2026-06-15) — 구직 미니게임 통합
- **JobHuntMiniGame**: 자소서·면접 AP 사용처 완전 게임화
  - `Mode.RESUME`: 지원동기/강점/단점극복/입사포부 4문항, 3선택지 채점형 (3/1/0점)
  - `Mode.INTERVIEW`: 5문항 압박 타이머 (기본 10s, 깜짝 질문 5s), 타임아웃 시 자동 진행
  - quality 0-3에 따른 스탯 차등 적용 — 우수: 지력/사회성+2, 양호: +1, 실패: 스트레스+1
  - 타이머 바 실시간 색상(녹→황→적), 좋은 답 시 스트레스 -1, 나쁜 답 시 +1

### Added (2026-06-15) — 생존게임 패키지 + 알바 미니게임 v2
- **정착 지원금 1개월 단축**: 2개월차부터 실질 생존 압박 (기존 3개월 → 1개월)
- **arc_job_first_rejection**: 구직 2주차(t>=8) 첫 불합격 메일 확정 이벤트, 이력서 다듬기 시 `resume_polished` 획득
- **생존 이벤트 4종**: 월세 납부일 공포, 삼각김밥 두 개, 채용 공고 밤샘, 취업한 친구 인스타
- **알바 미니게임 v2** — 직종별 전용 게임플레이:
  - job_01 편의점: 바코드 스캔 타이밍 게임 (커스텀 드로우 바늘 + 가속)
  - job_02 배달: 루트 최적화 퍼즐 (6주문 중 120분 내 최적 선택)
  - 그 외: 상황 카드 모드 유지

### Changed (2026-06-15) — 정선 카지노 명칭 확정 + 캐릭터 기반 해금
- 카지노 명칭 **정선 카지노**로 확정 (실제 카지노 브랜드/상표 회피, 실제 위치 기반 서술어)
- 카지노 진입 조건: `casino_club_introduced` 플래그 (상철 arc_03_network → casino_invite 완료 필요)
- JeongseonCasino 허브 UI: 바카라·블랙잭·슬롯·룰렛·빅휠 단일 버튼으로 통합
- 주 단위 투자 AP 힌트: "이번 달" → "이번 주" 텍스트 수정

### Added (2026-06-15) — REVIEW_ANALYSIS A항목 6종 완료
- **A-1 관계 감각**: 인물 연락 후 스토리 영역에 캐릭터 리액션 텍스트 타이핑 표시
- **A-2 AP 패턴**: 월말 결산에 이번 달 행동 패턴 코멘트 (도박집중/자기계발/혼합 등 8분기)
- **A-3 도박 경고**: addiction 50→플래시, 70→강제 경고 팝업, 90→월별 경고 배너
- **A-4 금융 용어**: 은행·투자 패널에 `📖 용어` 버튼, 카지노 허브에 `📖 용어 설명` 버튼 (총 18개 용어)
- **A-5 자산 태그**: 18종 투자 자산 각각에 특성 태그 3개 표시 (`[초저변동] [월배당] [부동산 간접]` 등)
- **A-6 월말 서사**: 결산 화면에 현재 상태 기반 1줄 내레이션 (무직/첫 출근/중독/마일스톤 등)
### Added (2026-06-15) — Seoul landmark backgrounds

- Added `assets/backgrounds/hangang_riverside_walk.png`, a 1280x800 Han River blue-hour promenade background for rest, walking, running, romance, and reflective callback scenes.
- Added `assets/backgrounds/namsan_tower_view.png`, a 1280x800 Namsan Tower night overlook background for future Seoul landmark and aspirational city-view scenes.
- Registered `ImageRegistry.BACKGROUNDS["hangang_riverside"]` and `["namsan_tower"]`.
- Routed Han River / Hangang / riverside wording before social, exercise, and generic city fallbacks so Han River running or reflection scenes do not become gym/cafe images.
- Routed Namsan / N Seoul Tower / Seoul Tower wording to the Namsan background for future event expansion.
- Explicitly assigned `hangang_riverside` to `hangang_chicken`, `jiyeon_confession`, and `callback_final_sprint_reflective_call`.
- MainGame routine vignettes now show the Han River background when the vignette text mentions Han River, even if the action category is rest, exercise, or meditation.

### Added (2026-06-15) — Background additions for casino and gym scenes

- Added `assets/backgrounds/casino_interior.png`, a 1280x800 reusable Jeongseon Casino-inspired public casino-floor background for the hub, blackjack, and baccarat.
- Added `assets/backgrounds/jeongseon_casino_exterior.png`, a 1280x800 Jeongseon Casino-inspired mountain resort exterior from a protagonist eye-level driveway/drop-off view for arrival/departure and post-casino reflection events.
- Added `assets/backgrounds/jeongseon_casino_entrance.png`, a 1280x800 Jeongseon Casino-inspired casino entrance/lobby threshold background for entry, exit, check-in, and relapse-urge moments.
- Registered the new background as `ImageRegistry.BACKGROUNDS["casino"]` so future casino scenes/events can call it without hardcoding paths.
- Registered `ImageRegistry.BACKGROUNDS["jeongseon_casino_exterior"]` and routed Jeongseon Casino wording/tags to the exterior background before generic gambling fallbacks.
- Registered `ImageRegistry.BACKGROUNDS["jeongseon_casino_entrance"]` and routed Jeongseon Casino entrance/lobby/check-in/relapse wording to the entrance background.
- Explicitly assigned `jeongseon_casino_exterior` to the loss-bus event and `jeongseon_casino_entrance` to the win-urge and addiction-notice events.
- The image follows the reusable-background rule and avoids direct news-photo copying: no foreground hands, no readable faces, no logos/text/watermarks, and only distant anonymous silhouettes.
- Adjusted blackjack/baccarat/hub overlays so the brighter real-casino visual language remains visible under UI.
- `JeongseonCasino` hub now uses the new casino background under a dark overlay so the casino entry screen has venue presence before opening individual tables.
- Added `assets/backgrounds/gym_interior.png` and remapped `gym` / `exercise` backgrounds to it, replacing the previous rooftop fallback for fitness scenes.
- `BlackjackTable` and `BaccaratTable` now use the real `card_back.png` texture for hidden cards and render larger premium card faces with corner rank/suit indexes and centered suit symbols.
- Rebuilt `card_back.png` and `poker_chip_icon.png` with coordinate-aligned geometry; the poker chip now uses a real-chip blank center with outer white inserts instead of a center suit mark.

### Added (2026-06-14) — Tutorial system + minigame quality pass 2

- New `TutorialOverlay` (static class, session-based `_seen` dict): single-call `maybe_show()` / `force_show()` API; slides for all 9 mini-games plus a 3-slide main-game onboarding (goal / dashboard / month flow).
- `JeongseonCasino` hub: each game card now has a secondary "❓ 규칙" button for on-demand rules.
- All game scenes (slot, roulette, bigwheel, baccarat, blackjack, holdem, scalping, trading, racetrack) have an in-game ❓ help button in the header/action row.
- Main-game onboarding tutorial fires once after the prologue in `_continue_after_story()`.
- Fixed `AudioManager.play_sfx()` → `play()` bug in `RouletteTable` and `BigWheelGame` (SFX was silently ignored).
- `SlotMachineGame`: 3-phase win presentation (regular / big-win double flash / JACKPOT 3× flash + reel gold border) + near-miss "아깝다!" message for 2-symbol partial matches.
- `RouletteTable`: settle-number scale-pop tween on result.
- `BlackjackTable`: deal scale pop animation (0.94→1.0) + screen flash on deal.
- `RaceTrack`: 3-2-1-출발! countdown overlay before race begins.
- `MainGame`: vital labels pulse (alpha fade) when health ≤ 30, mental ≤ 30, or stress ≥ 80.
- `audit.py` passed ERROR 0 / WARNING 0 for all commits.

### Changed (2026-06-15) — Casino premium presentation pass
- Merged Claude's Jeongseon Casino expansion (`origin/main` 50c9130): hub, slots, roulette, big wheel, and scalping candlestick improvements.
- `BlackjackTable` now has central action/result banners for DEAL, HIT, STAND, DOUBLE DOWN, SPLIT, DEALER, WIN, LOSE, and PUSH, plus screen flashes, win pulse, and loss/double-down shake.
- `BaccaratTable` now has casino-call style banners for bets, NO MORE BETS, PLAYER CARD, BANKER CARD, and round results, plus color flashes and result pulse/shake.
- Fixed a Godot strict type inference issue in the new `BigWheelGame`.
- Added the explicit quality bar that minigames should move beyond flash-game presentation toward a 20,000 KRW commercial game feel.
- `./tools/audit.sh` passed after the pass: ERROR 0 / WARNING 0, Godot compile clean.

### Changed (2026-06-15) — Investment minigame presentation pass
- `ScalpingGame` now draws candle-style bars instead of a simple line-only chart, with current-price labels, BUY/SELL markers, market/action banners, flashes, profit pulses, and loss shake.
- `TradingFloor` now displays holding average-price lines on the chart and adds buy/sell execution feedback: banners, screen flashes, chart pulse/shake, and profit/loss-aware SFX.
- The standalone-quality minigame bar now explicitly includes the full Jeongseon Casino suite: blackjack, baccarat, and future casino games.
- `./tools/audit.sh` passed after the pass: ERROR 0 / WARNING 0, Godot compile clean.

### Fixed (2026-06-15) — Main merge + Blackjack compile stability
- Merged Claude's latest `origin/main` (`ebfa19e`) containing Jeongseon Casino baccarat/blackjack, holdem odds/history upgrades, and event context cleanup.
- Resolved `HoldemClub` conflicts by preserving both the new odds/history UI and the Codex POT/chip-burst/table-banner presentation pass.
- Fixed Godot 4.6 strict type inference failures in `systems/Blackjack.gd` and `scenes/BlackjackTable.gd` by replacing Variant-derived `:=` inference with explicit types.
- `./tools/audit.sh` passed after the merge: ERROR 0 / WARNING 0, Godot compile clean.

### Changed (2026-06-15) — Image routing + game-feel feedback pass
- `ImageRegistry.infer_background_id()` now recognizes concrete place wording for cafe/coffee, convenience store, office/interview, subway, real estate, study/library, holdem, racetrack, and lottery before broad investment/gambling fallbacks.
- Runtime gambling callbacks now route holdem scenes to `holdem_club` and racetrack scenes to `racetrack_betting` / `racetrack_track` instead of generic phone/investment backgrounds.
- `callback_events_21.json` now gives the holdem/racetrack echo events explicit category/tags/background metadata for consistent KO/EN overlay behavior.
- `MainGame` choice resolution now adds result feedback: choice SFX, big gain/loss flashes, background shake on heavy losses, and money/title pulse animations.
- `RaceTrack` now has betting debit SFX, race-start flash/shake, win/loss screen flash, and result label pulse.
- `RaceTrack` now switches from betting hall to track view during the race, draws lane surfaces, speed lines, dust, jockey/saddle overlays on the running horses, and live race-call messages for leader changes / final stretch.
- `HoldemClub` now has card-phase reveal flash, raise/call/showdown feedback, win/loss flash, loss shake, and session result pulse.
- `HoldemClub` now has a central POT display, chip icon, chip-burst particles on bets, bigger card panels, and table banners for NEW HAND/FLOP/TURN/RIVER/SHOWDOWN plus player/AI actions.
- `tools/background_semantic_audit.py` mirrors the updated runtime routing and writes the current review report to `docs/BACKGROUND_SEMANTIC_AUDIT.md`.
- `./tools/audit.sh` passed after the pass: ERROR 0 / WARNING 0, Godot compile clean.

### Changed (2026-06-13) — Runtime background semantic routing
- `ImageRegistry.infer_background_id()` now prioritizes concrete scene meaning before broad categories, preventing `social` events like `집들이` from falling through to cafe backgrounds and `health`/exercise scenes from falling through to hospital backgrounds.
- `friend_housewarming` / `housewarming_alone` and room/housewarming wording now route to the current housing background.
- Gym/exercise wording and tags now route to an exercise-safe background before hospital checks.
- Hospital backgrounds now require explicit hospital tags or medical wording such as hospital, doctor, checkup, ER, clinic, or Korean equivalents.
- MainGame routine vignettes now select their own background instead of inheriting the previous event background.
- MainGame event background routing now uses the same `ImageRegistry` inference as StoryMode.
- `./tools/audit.sh` passed after the fix: ERROR 0 / WARNING 0, Godot compile clean.

### Changed (2026-06-13) — P3 BGM/SFX 품질 교체
- BGM 7종을 deterministic local synthesis 기반 Ogg Vorbis로 재생성: menu, goshiwon, main, apartment, crisis, victory, ending
- 기존 `bgm_gosiwon.ogg`가 Theora video로 인식되던 문제를 Ogg Vorbis audio로 교체해 해결
- SFX 17종을 mono 44100 Hz WAV로 재생성
- 기존 코드에서 호출하지만 매핑이 없어 무음이던 `buy`, `sell`, `tab_open` SFX를 추가 및 연결
- BGM import loop 설정 정리: menu/goshiwon/main/apartment/crisis/ending은 loop ON, victory는 one-shot
- `tools/generate_audio_assets.py`와 `tools/AudioAssetCheck.gd` / `.tscn` 추가
- `docs/AUDIO_QA.md` 추가, `AUDIO_ASSET_CHECK_OK bgm=7 sfx=17` 검증 완료

### Changed (2026-06-13) — P2 CG/키아트 최종 패스
- `gangnam_dream_keyart_rooftop.png`를 1920×1080 textless master key art로 교체
- Steam store material 3종을 새 마스터에서 파생하고 로컬 폰트 타이틀을 합성:
  - `steam_capsule_main.png` 616×353
  - `steam_header.png` 460×215
  - `steam_capsule_small.png` 231×87
- 생성 모델 텍스트 대신 로컬 폰트로 `GANGNAM DREAM` / `강남드림`을 얹어 작은 캡슐에서도 제목 가독성 확보
- `/tmp/gangnamdream_p2_keyart_after.png` QA 시트 생성

### Changed (2026-06-13) — P2 public venue 배경 패스
- `seoul_rainy_street.png`, `hometown_train_station.png`, `library.png`, `restaurant_korean.png`, `pc_bang_interior.png`, `racetrack_betting_hall.png`, `holdem_club_interior.png` 교체
- 공공장소 배경 기준을 정정: 완전 무인이 어색한 장소는 작고 어두운 익명 실루엣/군중 텍스처를 허용하되, 얼굴이 보이는 전경 인물이나 주연처럼 읽히는 인물은 금지
- 홀덤 배경은 전경 손/팔 없이 테이블·카드·칩 중심으로 교체하고, PC방/경마장은 배경 실루엣으로 장소 밀도를 보강
- `/tmp/gangnamdream_p2_review_backgrounds_after.png` QA 시트 생성, 배경 감사 현황을 36 pass / 0 review / 0 fix / 0 quarantined로 갱신

### Added (2026-06-12) — CG 런타임 표시 연결
- StoryMode가 이벤트 `cg` 키를 최우선 전체화면 이미지로 표시하도록 연결
- CG 장면에서는 별도 포트레이트 프레임을 숨기고, 이름표/텍스트만 유지해 CG와 인물 초상화가 중복되지 않게 조정
- MainGame 엔딩 화면이 엔딩 `cg` 키를 배경으로 사용하고, 엔딩 모달 안에 와이드 CG 프리뷰를 추가하도록 연결
- `tools/CGRuntimeCheck.gd` / `tools/CGRuntimeCheck.tscn` 추가: StoryMode CG 연결과 MainGame 엔딩 CG 프리뷰 경로를 헤드리스에서 검증

### Changed (2026-06-12) — 한지연 사고 CG 얼굴 정합성
- `assets/cg/jiyeon_crash.png` 교체: 사고 장면 속 한지연 얼굴/헤어/의상을 투명 포트레이트 정본(`npc_mentor`, `npc_jiyeon_warm`, `npc_jiyeon_cold`)에 맞게 재생성
- 기존 정합성 요소는 유지: 검은 Mercedes-Benz S-Class급 세단, 운전석 앞문 하차, 쓰러진 자전거 두 바퀴, 왼쪽의 김민준, 비 오는 강남 야간 도로
- `/tmp/gangnamdream_jiyeon_crash_identity_qa.png` 얼굴 비교 시트와 `/tmp/gangnamdream_crop_qa/visual_crop_qa_sheet.png` 크롭 QA 재생성

### Added (2026-06-12) — 인게임 크롭 QA 툴
- `tools/VisualCropQA.gd` / `tools/VisualCropQA.tscn` 추가
- Godot headless dummy renderer에서도 동작하도록 SubViewport 스크린샷 대신 CPU 이미지 합성으로 MainGame/StoryMode/CG 크롭을 재현
- `/tmp/gangnamdream_crop_qa/visual_crop_qa_sheet.png` 생성: 15개 조합 검수

### Verified (2026-06-12) — P1 인게임 크롭 QA
- 고시원/late-night 방 구조, 편의점 무인 배경, 강남 day/night/station 배경, 가족집, 핵심 포트레이트 크롭이 첫 QA 통과
- CG fullscreen crop은 `start`, `jiyeon_crash`, `jaehyuk_reveal`, `ending_father` 4종 모두 핵심 정보가 화면 안에 유지됨
- 이벤트/엔딩 `cg` 키의 실제 런타임 표시 연결은 다음 QA/구현 대상으로 분리

### Changed (2026-06-12) — 전체 배경 2차 정합성 감사
- `docs/BACKGROUND_CONTINUITY_AUDIT.md` 추가: production/direct 배경 35장 전수 감사, pass/review/fix/quarantine 판정 기록
- `late_night_room.png`를 고시원 구조 불일치로 runtime에서 격리하고, `late_night` / `BG_NIGHT_ROOM` 매핑을 정본 `goshiwon_room.png`로 변경
- 최종 전 재생성 대상 확정: `convenience_store_night`, `gangnam_day`, `gangnam_night_street`, `gangnam_station_exit`, `penthouse_view`, 선택적 `late_night_room`
- `convenience_store_night.png`를 직원/손님 실루엣 없는 2am 편의점 배경으로 재생성하고 감사 상태를 PASS로 갱신
- `gangnam_day.png`, `gangnam_night_street.png`, `gangnam_station_exit.png`를 전경 주인공형 인물 없는 neutral Gangnam 배경으로 재생성
- `penthouse_view.png`를 사람/실루엣 없는 empty luxury ending background로 재생성
- `late_night_room.png`를 `goshiwon_room.png` 기반 4am 색보정 변형으로 재생성하고 `late_night` / `BG_NIGHT_ROOM` 매핑을 해당 파일로 복구
- 배경 감사 현황을 30 pass / 6 review / 0 fix / 0 quarantined로 갱신

### Changed (2026-06-12) — 반복 보조 NPC 투명 포트레이트
- `npc_goshiwon_owner.png`, `npc_team_lead.png`, `npc_seongjun.png`, `npc_tip_seller.png`를 배경 없는 512×768 투명 포트레이트로 교체
- 이전 4종은 RGBA 파일이지만 실제 알파가 전부 255인 배경 포함 이미지였으므로 반복 합성용 에셋 기준에 맞게 정리
- 박성준 설명을 고교 친구 / 9급 공무원 3년차 정본으로 수정하고, 금융권 연락처처럼 읽히는 구 설명 제거
- `npc_seongjun.png`를 한 번 더 재생성해 팀장과의 유사성을 낮춤: 안경 제거, 공무원 ID/카디건 실루엣 강화
- `/tmp/gangnamdream_minor_npc_transparent_pass.png` QA 시트 생성
- `/tmp/gangnamdream_teamlead_seongjun_readability.png` 팀장/성준/민준/현수 구분성 시트 생성

### Added (2026-06-12) — 김민준 직업별 의상 포트레이트
- `main_character_unemployed.png`, `main_character_part_time.png`, `main_character_office.png`, `main_character_corporate.png` 추가
- `ImageRegistry.get_player_context_portrait()` 추가: 현재 직업 카테고리/티어에 따라 주인공 평상시 포트레이트 의상을 자동 선택
- `MainGame._get_portrait_path()`를 ImageRegistry 기준으로 정렬해 대시보드와 이벤트 포트레이트가 같은 의상 규칙을 사용
- `player_suit`를 배경 박힌 `main_character_30s.png` 대신 새 투명 정장 포트레이트로 연결

### Changed (2026-06-12) — 현수 호감형 재디자인
- `npc_close_friend.png`를 26-27세 통통한 공시생 후배 느낌의 투명 포트레이트로 교체
- 이전 고구분성 버전이 너무 중년/비호감으로 읽히던 문제를 수정하고, 민준과의 구분성은 안경·체형·후드 색으로 유지
- `CANON_MAP.md`, `STORY_BIBLE.md`, `CHARACTER_VISUAL_BIBLE.md`, 에셋 브리프의 현수 나이/역할을 첫 등장 이벤트와 맞게 정렬
- 현수 관련 이벤트 말투를 `형` 기준으로 정리하고, 고등학교 친구 보증 이벤트가 현수 호감도를 건드리던 잘못된 `cast_effects`를 제거
- `/tmp/gangnamdream_minjun_hyunsu_readability.png` 비교 시트 생성

### Verified (2026-06-12) — 한지연 정본 스캔
- 활성 메인 아크의 한지연은 31세 강남 금수저 / 위험한 투자 히로인 / 로맨스 상대역 기준으로 정렬되어 있음을 확인
- 40대 멘토/박지연 버전은 `CANON_MAP.md`의 deprecated 항목과 과거 로그 맥락에만 남기고 production 정본에서 제외

### Added (2026-06-12) — 한지연 투명 포트레이트 + 가족 거실 재생성
- `npc_mentor.png`, `npc_jiyeon_warm.png`, `npc_jiyeon_cold.png`를 한지연 정본에 맞는 배경 없는 투명 포트레이트로 교체
- `family_living_room.png`를 민준 아버지의 창원/지방 노동자 가정 거실로 재생성: 대가족 액자/부유한 서울 집/큰 전망창 신호 제거
- `dad_house` / `BG_FAMILY` 매핑을 새 `family_living_room.png`로 재연결
- `/tmp/gangnamdream_jiyeon_new_portraits.png` 검수 시트 생성

### Added (2026-06-12) — 김민준 핵심 투명 포트레이트
- `main_character_neutral_goshiwon.png`, `main_character_tired.png`, `main_character_determined.png`, `main_character_happy.png`, `main_character_shocked.png`를 배경 없는 투명 포트레이트로 교체
- 폰/손/고시원 배경 소품을 제거해 어떤 배경 위에도 합성 가능하게 정리
- `/tmp/gangnamdream_minjun_new_portraits.png` 검수 시트 생성

### Added (2026-06-12) — 운영용 정본 맵
- `docs/CANON_MAP.md` 추가: 현재 인물 정본, 주요 아크, legacy/폐기 설정, DLC·주기 업데이트 확장 게이트를 한 곳에 정리
- 확장 순서를 canon delta → state/ID 예약 → 에셋 규칙 → JSON/코드 → audit/인게임 QA로 명문화

### Added (2026-06-12) — 에셋 정합성 체크리스트
- `docs/ASSET_CONTINUITY_CHECKLIST.md` 추가: 배경/투명 포트레이트/CG별 canon QA 기준과 quarantine 규칙 문서화
- `IMAGE_PROMPTS.md`, `ASSETS_BRIEF.md`, `VISUAL_AUDIO_UPGRADE_BRIEF.md`의 가족 거실 프롬프트를 민준 가족 정본 기준으로 교정

### Fixed (2026-06-12) — 시작 조건 문서 정합성
- `STORY_BIBLE.md`의 구 시작 자금 300만원 표기를 현재 런타임 정본인 50만원으로 교정
- 고시원 월세 표기를 현재 기본 고정 지출 65만원과 맞춤

### Fixed (2026-06-12) — 가족 배경 정합성
- `family_living_room.png`를 production 가족 기본 배경에서 격리: 대가족 액자/화목한 큰 가정집 분위기가 민준 가족 정본과 충돌
- `dad_house` / `BG_FAMILY` 기본 매핑을 `restaurant_korean.png`로 임시 변경해 잘못된 가족사를 암시하지 않도록 조정
- `CANON_MAP.md`, `ASSET_QA.md`, `ASSET_INDEX.md`, `DECISIONS.md`에 가족/집 배경 재생성 기준 기록
- 이후 새 `family_living_room.png` 재생성 검수 통과로 production 가족 배경에 재연결

### Changed (2026-06-12) — 한지연 캐릭터 정본 확정
- 한지연을 "40대 투자 멘토"가 아니라 31세 강남 금수저 / 위험한 투자 히로인 / 로맨스 상대역으로 고정
- `assets/CHARACTER_VISUAL_BIBLE.md` 추가: 한지연 비주얼 정본, 금지 요소, 차량 정본, 현재 실패 에셋 상태 기록
- `STORY_BIBLE.md`, `VISUAL_AUDIO_UPGRADE_BRIEF.md`, `ASSET_GAP_SPEC.md`, `ASSET_INDEX.md`, `ASSET_QA.md`의 한지연 설명을 새 정본으로 정렬
- 첫 접촉 사고 차량 문구를 흰색 BMW에서 검은 메르세데스 벤츠 S클래스급 세단으로 통일

### Fixed (2026-06-12) — 한지연 첫 만남 중복 차단
- 구 `relationship_events.json`의 `jiyeon_meet` 랜덤 체인이 메인 `arc_jiyeon_01_crash`와 같은 첫 사고를 중복 생성하던 문제를 차단
- 구 `jiyeon_meet` → `jiyeon_confession` 랜덤 체인은 legacy 상태로 비활성화하고, 메인 아크/후반 관계 이벤트만 정본 진행으로 유지
- KO/EN 이벤트 오버레이 모두 동일하게 정렬

### Added (2026-06-12) — P1 비주얼 누락 에셋 생성/연결
- **NPC 파생 초상화 7장 추가**: `npc_daeun_smile.png`, `npc_daeun_sad.png`, `npc_father_weak.png`, `npc_sangchul_serious.png`, `npc_jiyeon_warm.png`, `npc_jiyeon_cold.png`, `npc_jaehyuk_shadow.png`
- **신규 배경 3장 추가**: `restaurant_korean.png`, `library.png`, `street_seoul_day.png`
- **고시원 구조 통일**: `assets/backgrounds/goshiwon_room.png`와 `assets/cg/start.png`를 같은 공간 규칙으로 재생성 (큰 창문 없음, 침대 발치 책상, 작은 환기창)
- **아버지 엔딩 CG 교체**: `assets/cg/ending_father.png`를 병실에서 아버지 손을 잡는 감정 장면으로 교체
- **ImageRegistry.gd**: `daeun_smile/sad`, `father_weak`, `sangchul_serious`, `jiyeon_warm/cold`, `jaehyuk_shadow` alias를 실제 파생 파일로 연결
- P1 신규 에셋 해상도 확인: 초상화 512×768, 배경 1280×800

### Changed (2026-06-12) — 비주얼 정합성 레이어 분리
- 반복 주연/핵심 인물은 투명 포트레이트, 배경은 인물 없는 장소 이미지, CG만 인물+배경 허용으로 에셋 원칙 확정
- 일반 투자/재테크 배경은 `investment_phone.png`로 통일하고, `trading` 레거시 키도 폰/작은 책상 스케일로 폴백
- 멀티모니터 트레이딩룸은 `trading_room` / `scalping_room` 등 전용 장면에서만 사용하도록 분리

### Added (2026-06-12) — 비주얼+오디오 업그레이드 브리프
- **VISUAL_AUDIO_UPGRADE_BRIEF.md** — 전체 이미지/오디오 교체용 에이전트 스펙 문서
  - P1: 주인공 7포즈, NPC 14포즈, 핵심 배경 10장, CG 2장
  - P2: 나머지 배경 20장, CG 2장, 키아트 4장
  - P3: BGM 7트랙, SFX 14종
- **ImageRegistry.gd**: 누락 배경 키 5개 추가 (library, restaurant, street, apartment, convenience_store)

### Added (2026-06-12) — 이벤트 500개 달성 + 콘텐츠 경고
- **이벤트 54개 추가** (KO + EN) — 총 500개 달성
  - `life_events2` (19): 일상 마이크로 모먼트 (SNS 비교, 빈 냉장고, 동창회, 월세 인상, 첫 월급, 건강검진, 새벽 편의점 등)
  - `amb_scenarios7` (10): 야망 딜레마 (진급 누락, 창업 합류, 헤드헌터, 연봉 노출, 사내 파벌, 퇴직 충동 등)
  - `drama_events2` (15): 드라마 일상 (결혼 독촉, 명절 식탁, 소개팅, 전 연인 SNS, 연말정산, 폭염, 한파 등)
  - `relationship_events2` (10): 관계 심화 (다은 먼저 문자, 현수 돈 부탁, 아버지의 침묵, 어머니의 고백, 친구 이별 등)
- **콘텐츠 경고 모달** — 첫 실행 시 표시 (재정 어려움·가족 압박·번아웃·정신건강 경고, KO/EN 지원)

### Fixed (2026-06-12) — 이벤트 조건 정합성
- `rel_daeun_first_text`: 잘못된 stage "friend" → 올바른 ["warm","close","interest"]
- `rel_hyunsu_loan`: 없는 hyunsu stage 조건 제거 → `arc_intro_hyunsu_seen` 플래그 조건 대체
- `first_paycheck_00`: 세팅 없는 `first_job_taken` 조건 제거

### Added (2026-06-11) — 영어 이벤트 번역 전체 완료 (150개)
- arc_events (16): 인트로/상철/지연/재혁 스토리 아크
- arc_daeun (9): 다은 편의점 로맨스 아크
- arc_specialization (9): 전문화 분기 (엘리트/퀀트/창업 등)
- scenario_cafe (10) + scenario_cafe_callback (8): 강남 카페 시나리오 전체
- amb_scenarios 1-6 (23): 도덕적 딜레마 시나리오 전체 (전세 사기, 회식, 코인, 명절, 다단계, 지갑, 이직, 보증, 공 가로채기)
- investment_events (43): 투자 이벤트 전체 라이브러리 (시장 폭락, ETF, IPO, 내부자 정보, 언더그라운드 네트워크 등)
- **EN 오버레이 17개 파일 완성 — 미번역 이벤트 0개**

### Added (2026-06-11) — 영어 이벤트 번역 확대 (30개)
- life (15개): 감성 시그니처 이벤트 전체 번역 (부모님 통장, 대리기사, 마지막 겨울 등)
- drama (5개): 코인 한 방, 스타트업, 재벌 접촉, 청약, 직장 암투
- relationship (4개): 지연·다은 핵심 분기, 아버지 병원·사진
- hidden (3개): 엘리베이터(legendary), 건강검진, 강남 오픈하우스

### Added (2026-06-11) — 영어 로컬라이제이션 인프라
- LocaleManager autoload: ko/en 언어 전환, 자동 DataRegistry.reload() 트리거
- DataRegistry: content/events_en/ ID-overlay 방식 (미번역 이벤트 → 자동 KO 폴백)
- StartMenu 설정 팝업: 언어 토글 (한국어 / EN)
- content/events_en/story_events.json: 오프닝 5개 이벤트 영어 번역

### Fixed (2026-06-11) — 이벤트 카테고리 정규화 (런 테마 보너스 누락 수정)
- job→jobs (18개), social_life→social (18개): 청렴런/인맥런 테마 보너스(×1.35) 누락 수정
- drama/opportunity/life/hidden_rare_events → 표준 카테고리 교체 (9개)
- romance 카테고리: 인맥런(relationship 테마) 보너스 공유

### Added (2026-06-11) — 감사 10번째 검사: 카테고리 화이트리스트
- 비표준 카테고리 사용 시 즉시 WARNING — 새 카테고리 추가 전 화이트리스트에 등록 필요

### Fixed (2026-06-11) — 감사 확장으로 검출된 실버그 9건
- work_performance/addiction 효과가 조용히 무시되던 5건 (엘리트 전문화 보상 복구)
- 시즌 이벤트(연말/봄)가 아무 달에나 뜨던 month 조건 미처리 2건
- jiyeon_man 엔딩 게이트의 도달 불가 stage 비교 ("together" → "honest_together")
- events_seen 저장 누락 (로드 시 이벤트 카운트 리셋)
- stage 이름 분열 통일: daeun acquaintance / sangchul trusted

### Added (2026-06-11) — 감사 체계 확장 (검사 9종 + CI)
- audit 신설 4종: serialize 완전성 / 이벤트 키 화이트리스트 / 인물 stage 상태기계(cast_stages.json 정본) / 밸런스 회귀 밴드
- GitHub Actions CI: 정적 감사 + 밸런스 밴드 + Godot 헤드리스 컴파일 + SimRun/SmokeRace

### Fixed (2026-06-11) — 아이템 사용 행동력 소모
- 아이템 사용이 행동력 1을 소모 (무제한 사용으로 스트레스 시스템을 돈으로 우회하던 홀 차단)
- 사용 버튼에 ⚡1 표기, 행동력 0이면 비활성

### Added (2026-06-11) — 난이도 모드 + 스토어 포지셔닝
- **난이도 3종**: 🎬 드라마(자금 200만·압박 완화·베팅 +4%p) / 🌆 현실(기본) / 🔥 지옥고(자금 30만·압박 강화·베팅 -4%p)
  — 시작 화면 카드 선택, 엔딩·공유 카드에 표기, 세이브 호환
- **STORE_PAGE.md 전면 갱신**: "인생역전 드라마 시뮬레이션" 포지셔닝 (VN 워딩 배제), Steam 태그/스크린샷/트레일러/현지화 우선순위

### Added (2026-06-11) — 대출 시스템 (신용등급 기반)
- **신용등급 1~10**: 직장·근속·소득·순자산·평판이 올리고 부채비율·잔고 바닥 이력이 깎음 — 등급이 대출 한도와 금리를 결정
- **🏦 은행 (투자 화면 내)**: 1금융 신용대출(월 0.4~0.88%, 한도 소득 18~6배, 7등급 이내) + 제2금융(월 1.28~2.0%, 한도 4,600만~1,000만, 무직 가능)
- **변동금리**: 등급이 떨어지면 보유한 빚의 이자도 오름 — 실직하면 이자 부담 증가
- 이자 매달 자동 차감(+스트레스 2), 수시 상환, 행동력 무소비
- 자산·파산·승리 판정이 전부 순자산(대출 차감) 기준 — 빌린 돈으로 마일스톤을 찍을 수 없음

### Fixed (2026-06-11) — 파산 밸런스
- **파산 임계값 정렬**: 코드 -3천만/-1억 → 설계값 **-1억/-2억** (엔딩 텍스트·튜토리얼·UI는 원래부터 -1억 기준이었음)
- **마이너스 잔고 압박 복구**: `money<0` 분기가 도달 불가였던 순서 버그 수정 — 이제 빚 상태는 매달 스트레스+12/정신-5
- "파산 위기자" 칭호 기준을 순자산 -5천만으로 조정

### Added (2026-06-11) — 아크-게임플레이 연결
- **인연 에필로그**: 엔딩 화면에 "그 사람들은" 섹션 — 5인(아버지/지연/다은/상철/재혁)의 최종 관계 단계에 따라 결말 직후 장면이 달라짐. 같은 엔딩이라도 곁에 누가 있었는지가 다르다
- **인연 월간 패시브**: 아버지 화해 → 정신 +1/월, 연인 → 스트레스 -2/월, 상철 신뢰 → 투자감각 +1/4턴 — 관계가 경제 게임을 돕는 환류 구조
- **상철 투자 정보 이벤트 2종**: 신뢰 단계에서만 열리는 급매 베팅(시장보다 유리한 EV) + 과열 경고(보호형)
- **AP 행동 vignette 완성**: 저축/인맥/공부(독서·운동·명상·재테크) 행동이 토스트 대신 내러티브 비네트 — 풀 6종 61개 장면

### Added (2026-06-11) — 아크 텍스트 밀도 강화
- 핵심 아크 이벤트 8종 텍스트 확장 (인트로 4종, 아버지 3종, 유혹 1종) — 구체적 지명·감각 디테일

### Added (2026-06-10) — Steam Deck 컨트롤러 지원
- **StoryMode 컨트롤러 완전 지원**: A버튼으로 텍스트 진행·선택지 확인; 선택지 D패드 탐색; B버튼 실수 방지 흡수
- **선택지 포커스 비주얼**: 컨트롤러 포커스 시 선택지 버튼 시각적 하이라이트(파란 왼쪽 테두리)
- **메인게임 탭 순환**: LB/L1으로 이전 탭, RB/R1으로 다음 탭 (정보 패널)
- **마우스 커서 자동 숨김**: 패드 조작 중 커서 숨김, 마우스 이동 시 복원 (Steam Deck 터치패드 사용 고려)
- **`shoulder_l()` / `r3()` API 추가**: ControllerHints에 LB/L1/L 및 R3 레이블 메서드 추가
- **패드 힌트 수정**: 메인게임 힌트에서 gd_next_month를 R3로 올바르게 표시

### Fixed (2026-06-10) — 전체 게임 분석 후 정리 (QA 전)
- **political_fix 엔딩 발동 연결**: 25개 엔딩 중 유일하게 발동 경로가 없던 엔딩 — `political_winner` 플래그(보좌관 수락 → 출마·당선) 시 즉시 발동하도록 check_game_over에 연결
- **political_fix 엔딩 텍스트 교정**: 옛 "정치 테마주" 설명 → 실제 경로(국회의원 당선)에 맞는 "여의도行" 서사로 재작성
- **옛 설계 잔재 이벤트 2종 삭제**: story_arrival_elite / story_arrival_rich (서른 살 시작·루트 선택 전제 — 어디서도 라우팅 안 됨)
- **CLAUDE.md 아이템 수 표기 교정**: 30개 → 28개 (실제 값)

### Added (2026-06-10) — 아크 패널 완성 + 경고 수용 분기
- **arc_jiyeon_truth_warned 신설**: 임상철 경고를 수용한 플레이어(`warned_about_jiyeon`)는 진실 씬에서 "이미 알고 있었던 진실" 버전의 별도 이벤트를 재생 — 선택의 실질적 파장 구현
- **아버지 아크 패널 추가**: 전화/이상신호/병원/방문/화해 5단계 arc 패널 항목 추가 (이전에 패널 목록에서 누락됨)
- **재혁 아크 패널 추가**: 재회/유대/투자제안/도주-반격/사후처리 5단계 arc 패널 항목 추가
- **임상철 패널 힌트 수정**: "직장 경험 후 만남 가능" → "10개월차 이후 자동 만남" (실제 조건 반영)

### Fixed (2026-06-10) — 플래그 교차 검증 도입 + 잠재 버그 15개 수정
- **audit 4번 검사 신설**: 코드/이벤트가 읽는 플래그를 실제 set 위치와 대조 — 오타·이름 불일치로 조용히 죽는 버그를 커밋 전에 기계적으로 검출
- **엔딩 복구 2종**: `late_call`(아버지 화해) 도달 불가 버그, `empty_house` 도달 불가 → "관계 전무 + 비화해"로 재정의
- **칭호 복구**: "자유로운 영혼"(free_spirit) — 자유시간 카운터가 구현돼 있지 않아 해금 불가였음
- **아크 패널 복구**: 강현수 패널 전체(존재하지 않는 플래그 참조), 다은 패널 완료 표시
- **이벤트 복구 3종**: startup_team_conflict(조건 플래그 미존재로 영영 안 뜸), startup_first_user_traction(1회성 보호 깨짐), story_gosiwon_neighbor(반복 방지 깨짐)
- **죽은 분기 정리**: creator_success_unlocked→creator_viral, political_career_started→political_candidate, 구 캐릭터 수민 분기 제거
- **옛 설계 이벤트 11종 삭제**: 마흔다섯/쉰/예순 마일스톤 7종(20세 시작·65세 은퇴 전제) + 아버지 아크 구버전 4종(신버전과 중복 진행 — 아버지가 두 번 아픈 버그)
- **마일스톤 라우팅 정비**: t48이 옛 은퇴 이벤트를 호출하던 버그 수정 → story_four_year. 고아 이벤트 3종(t6 반년/t18 1년반/t30 서른다섯) 라우팅 연결
- **나이 텍스트 교정**: story_four_year(스물넷→서른일곱), story_six_months(100만원→50만원), age_39_final(서른아홉→서른여덟 직전/마지막 반년)

### Added (2026-06-10) — 아크 깊이 작업 2·3차
- **재혁 아크 강화**: arc_jaehyuk_01b_real_face(취중 고백) · arc_jaehyuk_02b_favor(조건 없는 도움) · arc_jaehyuk_04c_stand_up(재기 선택) 추가; aftermath 피해자 경로 3번째 선택지 추가
- **다은 아크 강화**: arc_daeun_03b_date(첫 외출) · arc_daeun_04b_future(관계 긴장) · arc_daeun_regret_draft(이별 후 여운) 추가
- **한지연 아크 강화**: arc_jiyeon_03b_lunch(투자 파트너 vs 감정) · arc_jiyeon_05_epilogue(관계 결말 3종) 추가
- **arc 패널 버그 3종 수정**: daeun/jiyeon/sangchul 아크 패널 표시 플래그 실제 이벤트 플래그로 교정; 한지연 패널 이름 수정 ("박지연 멘토" → "한지연 투자·로맨스")

### Added (2026-06-10) — 아크 깊이 작업 1차
- **아버지 아크 5단계 신설**: arc_father_01_call ~ arc_father_05_after_visit (t≥11/22/35/43/52)
  — 병환 통보·병원 방문·화해까지 전체 아크 구현
- **다은 아크 플래그 수정**: met_daeun / arc_daeun_01_seen 플래그 누락 수정; 빈 result_text 채움

### Fixed (2026-06-10) — QA 패스
- **세이브 버그**: `run_theme` / `unlocked_stat_thresholds` 직렬화 누락 수정, SaveManager v3
- **미사용 엔딩 9종 활성화**: `lonely_rich`, `creator_success`, `reputation_legend`, `orthodox_pinnacle`, `unorthodox_legend`, `early_retirement`, `investment_master`, `balanced_life`, `orthodox_hollow`
- **아크 베팅 결과 내러티브**: 임상철·한지연 기회 이벤트 win/lose 후속 이벤트 4종 연결

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
