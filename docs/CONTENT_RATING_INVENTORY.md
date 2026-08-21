# 출시 콘텐츠·심의 사실 인벤토리

> 이 문서는 `content/meta/release_content_inventory.json`과 현재 소스에서 자동 생성한다.
> 최종 연령 등급·법률 의견·콘텐츠 삭제 결정이 아니며 수동 편집하지 않는다.

갱신 기준: 2026-08-22

## 가장 중요한 범위 판정

현재 10개 export preset은 모두 `all_resources`다. 따라서 V2의 공식 24주 경로가
열지 않는 5년 사건·카지노·경마·홀덤·단타도 패키지에는 포함되며, 사건 127파일은
DataRegistry가 부팅 때 등록하고 도박·위험거래 노드 10개(직접 미니게임 9개 + 허브 1개)는 MainGame 진입 때 생성한다.
`패키지 포함`, `런타임 로드`, `공식 fresh-start 도달`을 같은 값으로 읽지 않는다.

| 프로필 | feature | 공식 범위 | 콘텐츠 필터 |
|---|---|---:|---|
| `retail_full` | 없음 | 1–240주 | `all_resources` |
| `legacy_demo` | gangnam_demo | 1–24주 | `all_resources` |
| `v2_playtest` | gangnam_demo, core_loop_v2_playtest | 1–24주 | `all_resources` |

## 현재 코퍼스

- KO/EN 사건: 각각 127파일 · 1758건, ID 일치
- 패키지 사건: 1758건 · 현재 shipping 사건: 1603건 · author-only reference 원고: 155건
- KO/EN 엔딩: 각각 35건
- 활성 스토리 이미지: 249장 · source raster: 304장
- 게임 pack 대상 raster: 296장 · ImageRegistry 외부 pack 대상: 47장
- `.gdignore` source-only 상점 스크린샷: 8장 · 출처 원장 오디오: 139개
- 사건 ID SHA-256: `0c934fde26f81511016298e932495eb47cc7f2ebf15de4af722584635e1abdf0`
- KO/EN 엔딩 본문 SHA-256: `32ea94755971c459f74f5a3bae80151a077c9eb781277fee7fda58879b1045f1`

후보 fingerprint는 표현의 최종 등급이 아니라 검토 코퍼스가 조용히 바뀌는 것을
막는 자동검색 래칫이다. fact의 사건 ID는 결정적 증거 앵커이지 후보 전부의 1:1
처분표가 아니다. 후보가 바뀌면 사람이 원문·이미지·음향·플레이를 다시 확인한다.

| 축 | 후보 사건/파일 | ID SHA-256 | KO/EN 본문 SHA-256 | 최고 사실 강도 |
|---|---:|---|---|---|
| 사행성·도박 | 137 / 43 | `e324a22a603bda179d3be12bee23fb8e8af3134e9cab56e953416e42d02bba7b` | `6794322ebffc6ac582ce21a675c19c9b3a4c7388b7350f1dc6e9779967c84f0a` | strong, moderate |
| 선정성·성적 내용 | 121 / 25 | `ba24d3b45e98bc31d2e2aaf9afed41b18c76fc15e38d573d5628a9eb7f45228c` | `bb836a012fc7da231ab208cb6ee98008ba171d95d268285973c67b97e86ade38` | moderate, mild |
| 폭력성 | 18 / 15 | `1d403db1107800e1e7c4a8d9d78c08361a840c6901fd8e93de83e609bf585a70` | `ca092987894afe0f87d3cd9d17234c77a666f56c6d7bdb631f3d6b3ba3bb2be8` | mild |
| 공포 | 143 / 51 | `211c3c760cf2f66d61e9bc540cd11003cc05ad46eb59d4d1d97a348eb135c29f` | `a6c47724480ed1fdf2368624219db6af96e782b6551dbec0c4962d1562433432` | moderate |
| 언어 | 2 / 2 | `09cf036c8dac9dcefd776b9cf27b96efa7ed0ee396e74264bea545b480c8eca1` | `fc1a0465f31a6a2df2deb4559825e67c7f762fa2ebfdbaa45ae63e2fb75131c3` | mild |
| 범죄 | 70 / 40 | `e1bf5d669b6ca98117da9ff22117a0f723263db564eb7d74e2b0cbe55852b5b6` | `562880f77a96ac8a5f84ffcb019319b0bcbff40d6cf9690629032dae54451744` | moderate, strong |
| 음주·흡연·약물 | 76 / 37 | `80c9979ea846e60401fc8c1f996c2dbe1f76518998d68e8c361d8fa823298946` | `01b962138dff14d29506a0c8feed46e7ea9eaed7c502d2c06c14edd85f29ae02` | moderate, mild |
| 생성형 AI | 기술 축 | — | — | disclosure_required, none |
| 온라인 기능 | 기술 축 | — | — | none, external_link_only |

명시 검토한 검색 오탐(후보 해시에는 남겨 검색 규칙 변화도 드러낸다):
- 폭력성: `amb_coin_00`, `arc_35_unorthodox_weight`, `arc_daeun_first_night`, `arc_sangchul_confrontation`, `arc_year3_close`, `cafe_bluff_caught`, `callback_ignored_hyunsu_warning_echo`, `callback_recommitted_to_job_echo`, `inv_portfolio_review`, `job_colleague_conflict`, `kx_coin_noraebang`, `startup_team_conflict`, `story_knee_choice`, `story_knee_witness`

## ImageRegistry 외부 source raster 55장

`all_resources`라 ImageRegistry 외부 구버전·마케팅·UI raster 중
47장도 게임 pack 대상이다. 나머지 8장 상점 스크린샷은 `.gdignore` 아래 source-only라 게임 pack에는 없다.
전체 55장은 원본·접촉표로 에이전트 시각 검토했지만 최종 사람 판정은
여전히 `user_required`다. 실제 pack 검사는 대상 raster의 각 `.import`가 가리키는 `.ctex`까지 확인한다.

- 경로 SHA-256: `07c8cf2168ef7c139a1a283506f8228b414a846230ed74123f999545699c4f43`
- 경로+파일 SHA-256: `e3603753f07d425102aa3fdec0245fffbd1690c8d35521fea5df6f7ef41e4785`
- 실제 pack 대상 외부 raster 경로 SHA-256: `e08977c4cb6a19f4ed801ffb88a74721725bfebdfeea351eed6e1458a7d53d1f`
- 실제 pack 대상 외부 raster 경로+파일 SHA-256: `e62104d47939ffdd34c324ab124a7cd24501a5c4c9f720b035aeec3446cdd9e7`
- `.gdignore` source-only 경로 SHA-256: `f53a4433d398f59a1f71b77af81a840587083f9eca7a7d89ba4d6b1e46dfb2a4`
- `story_and_legacy` 14장 · 게임 pack 포함 — 원본 해상도와 접촉표에서 나체·성행위·가시적 혈흔/고어·자해·흡연·불법 약물 묘사는 확인되지 않았다. 이전 수영복, 경제적 절망/도박 회복, 상처가 보이지 않는 충돌 구도는 축별 사실에 따로 기록했으며 최종 사용자 검토가 남는다.
- `packaged_marketing` 10장 · 게임 pack 포함 — 패키지에 들어가는 키아트·캡슐·로고에는 별도로 누락된 더 강한 시각 표현이 확인되지 않았으며 최종 사용자 검토가 남는다.
- `source_only_store_screenshots` 8장 · source-only / 게임 pack 제외 — Steam 마케팅 스크린샷 8장은 assets/store/screenshots/.gdignore 아래라 게임 pack에는 없다. 이미 기록한 대포통장 선택, Moral dark 분위기, 해변 데이트, 엔딩 요약을 되풀이하며 더 강한 누락 표현은 확인되지 않았다. 상점 사용과 최종 사용자 검토는 별도 게이트다.
- `ui` 14장 · 게임 pack 포함 — UI에는 카드·칩·말 실루엣·시장 캔들·도박 행동 atlas가 있다. 폰 기종 구매는 종료됐고 flagship 셸만 세로 연락폰에 사용하며 starter/refurbished 셸은 all_resources pack의 출처 보존용 미사용 자산이다. 실제 현금 구매/환전이나 성적·약물·폭력 묘사는 확인되지 않았으며 최종 사용자 검토가 남는다.
- `m1m6_promise_cards` 9장 · 게임 pack 포함 — M01~M06 약속 선택판의 9개 장면 카드는 인물·브랜드·읽을 수 있는 문구·선택 결과를 선취하지 않는 무인 물성 장면이다. 생성 원본·해상도·해시는 ART_AI_AUDIT에서 확인했으며 최종 사용자 표면 판정은 별도 게이트다.

## 축별 실제 표현과 세 범위

### 사행성·도박

- **simulated_wagering · strong** — 게임 내 원화로 경마·홀덤과 정선 카지노 6종에 반복 베팅해 승패·손익을 정산한다. 실제 현금 결제·환전·양도는 없다.
  - 소유: `scenes/MainGame.gd`, `scenes/JeongseonCasino.gd`, `scenes/RaceTrack.gd`, `scenes/HoldemClub.gd`, `systems/Baccarat.gd`, `systems/Blackjack.gd`, `systems/SlotMachine.gd`, `systems/Roulette.gd`, `systems/BigWheel.gd`, `systems/DaiSai.gd`, `content/events/racetrack_events.json`
  - 사건: `racetrack_mentor_meet`, `race_first_visit`, `arc_sangchul_casino_invite`
  - `retail_full`: 패키지 포함 / 메인 진입 생성 / fresh-start 정적 가능 — Full scheduler and story flags open the interactive venues.
  - `legacy_demo`: 패키지 포함 / 메인 진입 생성 / fresh-start 정적 가능 — The week-4 money-mule choice can set gambling_tempted and leave at least KRW 1M; MainGame then guarantees racetrack_mentor_meet from week 12, whose authored follow-up can open the betting UI before week 24.
  - `v2_playtest`: 패키지 포함 / 메인 진입 생성 / fresh-start 차단 — No V2 1-24 bundle enters a wagering venue; full resources and nodes still load.
- **lottery_purchase_and_fixed_win · moderate** — 플레이어가 게임 내 원화로 로또 또는 긁는 복권을 직접 살 수 있고, 작성된 후속에서 5천원 또는 5만원 당첨금을 받는다. 실제 현금 결제·환전은 없다.
  - 소유: `content/events/life_events.json`, `content/events/rare_encounter_events.json`, `content/meta/event_director.json`, `autoloads/DataRegistry.gd`
  - 사건: `lottery_last_change`, `lottery_result`, `rare_convenience_lottery`, `rare_lottery_result`
  - `retail_full`: 패키지 포함 / 부팅 등록 / fresh-start 정적 가능 — The foreground-allowlisted rare_convenience_lottery can offer a ticket and rare_lottery_result prize. lottery_last_change and lottery_result are packaged and boot-registered but currently lack a normal foreground route.
  - `legacy_demo`: 패키지 포함 / 부팅 등록 / fresh-start 정적 가능 — rare_convenience_lottery is in the legacy foreground allowlist and can offer its ticket before week 24 when its conditions win the draw. lottery_last_change is packaged and registered but is not a normal legacy foreground route.
  - `v2_playtest`: 패키지 포함 / 부팅 등록 / fresh-start 차단 — The official V2 weeks 1-24 use the contracted authored spine and do not draw these lottery events.
- **addiction_debt_recovery · moderate** — 도박 손실 추격, 중독·금단, 빚과 회복을 반복 사건과 엔딩에서 다룬다.
  - 소유: `content/events/gambling_narrative.json`, `content/events/arc_addiction_recovery.json`, `content/endings.json`
  - 사건: `gambling_rock_bottom`, `recovery_first_week`
  - `retail_full`: 패키지 포함 / 부팅 등록 / fresh-start 정적 가능 — Registered full-game events follow gambling state and recovery flags.
  - `legacy_demo`: 패키지 포함 / 부팅 등록 / fresh-start 정적 가능 — A valid dirty-money/no-job route can open the racetrack at week 13, raise addiction to 80, keep cash below the savings milestone, and leave week 23 for a weighted gambling_rock_bottom draw; choosing help defers recovery_first_week to week 24. Relapse and completion stay beyond the cutoff.
  - `v2_playtest`: 패키지 포함 / 부팅 등록 / fresh-start 차단 — The chain is registered but has no official V2 entry before week 24.
- **simulated_scalping · moderate** — 60초 캔들 차트에서 게임 내 원화 10만·50만·100만·300만원을 걸고 반복 매수·매도해 손익을 정산한다. 주식 단타를 모사하지만 게임 내부에서는 ‘도박장’ 메뉴와 회복 잠금 아래 두고, 수익 시 도박 성향·5회 이상 거래 시 중독 성향을 올린다. 실제 금융거래·현금 결제·환전은 없다.
  - 소유: `scenes/MainGame.gd`, `scenes/ScalpingGame.gd`, `content/events/arc_events.json`
  - 사건: `arc_jiyeon_03b_lunch`
  - `retail_full`: 패키지 포함 / 메인 진입 생성 / fresh-start 정적 가능 — Jiyeon's later lunch route can set scalping_introduced; sufficient investment skill then opens the eagerly created 60-second trading minigame.
  - `legacy_demo`: 패키지 포함 / 메인 진입 생성 / fresh-start 차단 — The node is created on MainGame entry, but a fresh 24-week legacy route cannot reach Jiyeon's later lunch introduction and skill gate.
  - `v2_playtest`: 패키지 포함 / 메인 진입 생성 / fresh-start 차단 — No V2 weeks 1-24 bundle sets scalping_introduced or opens this minigame; the node still loads and all resources remain packaged.

### 선정성·성적 내용

- **implied_consensual_intimacy · moderate** — 본편 연애에서 키스와 상호 동의 분위기의 첫밤·결혼 첫날밤을 암시하지만 해부학적 묘사·나체·명시적 성행위는 없다.
  - 소유: `content/events/arc_daeun_romance.json`, `content/events/arc_date_milestones.json`, `content/events/arc_romance_specials.json`, `assets/cg`
  - 사건: `arc_daeun_first_night_decision`, `arc_daeun_first_kiss_choice`, `arc_jiyeon_first_kiss_choice`, `arc_daeun_wedding_night_choice`, `arc_jiyeon_wedding_night_choice`
  - `retail_full`: 패키지 포함 / 부팅 등록 / fresh-start 정적 가능 — Later relationship routes can enter these registered chains.
  - `legacy_demo`: 패키지 포함 / 부팅 등록 / fresh-start 차단 — The 24-week demo contains introductions, not kissing/intimacy milestones.
  - `v2_playtest`: 패키지 포함 / 부팅 등록 / fresh-start 차단 — V2 weeks 1-24 stop before romantic intimacy; text and CG resources remain packaged.
- **adult_swimwear_beach_dates · mild** — 본편의 성인 연애 해변 장면에서 다은과 지연이 원피스형 수영복과 커버업을 입은 초상·CG가 나온다. 지연 CG는 파라솔 아래 앉은 글래머 촬영 구도지만 나체·성행위·성적 신체 클로즈업은 없다.
  - 소유: `content/events/arc_season_dates.json`, `assets/characters/npc_daeun_sea_v2.png`, `assets/characters/npc_jiyeon_sea_v2.png`, `assets/cg/romance/sea_daeun_v3.png`, `assets/cg/romance/sea_jiyeon_v2.png`, `autoloads/ImageRegistry.gd`, `assets/ASSET_INDEX.md`
  - 사건: `arc_season_sea_daeun_decision`, `arc_season_sea_jiyeon_decision`
  - `retail_full`: 패키지 포함 / 부팅 등록 / fresh-start 정적 가능 — Later Daeun/Jiyeon relationship and seasonal routes can reach the beach decisions and paired art.
  - `legacy_demo`: 패키지 포함 / 부팅 등록 / fresh-start 차단 — The official 24-week legacy route cannot establish the later relationship/season prerequisites.
  - `v2_playtest`: 패키지 포함 / 부팅 등록 / fresh-start 차단 — No V2 1-24 bundle reaches the later relationship beach routes; the art remains packaged.
- **inactive_legacy_swimwear_assets · mild** — 현재 ImageRegistry가 쓰지 않는 이전 해변 초상·CG 4장도 all_resources 패키지에는 남아 있다. 모두 성인 캐릭터의 원피스형 수영복·커버업 장면이며 활성본보다 강한 노출은 없지만, 현재 fresh-start 경로에서는 로드되지 않는다.
  - 소유: `assets/characters/npc_daeun_sea.png`, `assets/characters/npc_jiyeon_sea.png`, `assets/cg/romance/sea_daeun.png`, `assets/cg/romance/sea_jiyeon.png`, `autoloads/ImageRegistry.gd`
  - `retail_full`: 패키지 포함 / 로드 없음 / fresh-start 차단 — all_resources includes the legacy PNGs, but no current runtime source or ImageRegistry mapping references them.
  - `legacy_demo`: 패키지 포함 / 로드 없음 / fresh-start 차단 — The same inactive legacy PNGs are packaged but unreferenced by the current runtime.
  - `v2_playtest`: 패키지 포함 / 로드 없음 / fresh-start 차단 — The same inactive legacy PNGs are packaged but unreferenced by the current runtime.

### 폭력성

- **bicycle_collision_minor_blood · mild** — 24주 선택 장면에서 세단이 자전거 앞바퀴를 쳐 민준이 넘어지고 충돌음이 재생되며 무릎에 피가 조금 난다. CG에는 충돌·혈흔·상처가 보이지 않는다.
  - 소유: `content/events/arc_events.json`, `assets/cg/jiyeon_crash_day_v3.png`, `autoloads/ImageRegistry.gd`, `assets/scene_audio_manifest.json`, `assets/audio/AUDIO_SOURCE_MANIFEST.json`
  - 사건: `arc_jiyeon_01_crash`
  - `retail_full`: 패키지 포함 / 부팅 등록 / fresh-start 정적 가능 — The full story can enter Jiyeon's first-meeting route.
  - `legacy_demo`: 패키지 포함 / 부팅 등록 / fresh-start 정적 가능 — Legacy route data can schedule the scene within its early arc.
  - `v2_playtest`: 패키지 포함 / 부팅 등록 / fresh-start 명시 계약 — The V2 narrative spine explicitly owns arc_jiyeon_01_crash in weeks 9-12.

### 공포

- **financial_health_and_police_distress · moderate** — 사기 피해·경찰 연락, 가족 건강, 경제 불안과 협박을 현실적 비그래픽 문장으로 다루며 공포 연출·괴물·점프스케어는 없다.
  - 소유: `content/events/arc_events.json`, `content/events/core_loop_v2_events.json`, `assets/scene_audio_manifest.json`
  - 사건: `arc_temptation_fallout`, `v2_father_health_signal`
  - `retail_full`: 패키지 포함 / 부팅 등록 / fresh-start 정적 가능 — Full routes include financial, family-health, and intimidation consequences.
  - `legacy_demo`: 패키지 포함 / 부팅 등록 / fresh-start 정적 가능 — Early fraud consequences and pressure events are in the registered corpus.
  - `v2_playtest`: 패키지 포함 / 부팅 등록 / fresh-start 명시 계약 — Weeks 8 and 21 explicitly own fraud/family-health distress roots.
- **parental_illness_death_and_grief · moderate** — 본편 후반에는 아버지의 위독·사망과 빈 병실의 애도를 비그래픽 문장과 절제된 상실 음향으로 다룬다. 플레이어는 병원/KTX로 향하거나 투자 딜을 택할 수 있고, 딜을 택하면 아버지가 사망한 시간에 번 500만원을 확인한다. 시신·상처·자해 묘사는 없다.
  - 소유: `content/events/arc_drama.json`, `content/events_en/arc_drama.json`, `scenes/MainGame.gd`, `assets/scene_audio_manifest.json`
  - 사건: `arc_father_passing`, `arc_father_passing_platform`, `arc_father_passing_deal_room`, `arc_father_passing_hospital_room`, `arc_father_passing_deal_morning`
  - `retail_full`: 패키지 포함 / 부팅 등록 / fresh-start 정적 가능 — The late full-game father-health chain can enter arc_father_passing and either hospital/grief or deal-over-family follow-ups.
  - `legacy_demo`: 패키지 포함 / 부팅 등록 / fresh-start 차단 — The official legacy 24 weeks stop before the late father illness/death chain.
  - `v2_playtest`: 패키지 포함 / 부팅 등록 / fresh-start 차단 — V2 week 21 signals health uncertainty but does not enter the later death/grief events before week 24.

### 언어

- **limited_strong_language · mild** — 한영 사건에 제한적인 욕설 후보가 있으나 지속적·반복적인 강한 욕설 중심 작품은 아니다.
  - 소유: `content/events`, `content/events_en`
  - 사건: `arc_jaehyuk_aftermath`, `cafe_caught_honest`
  - `retail_full`: 패키지 포함 / 부팅 등록 / fresh-start 정적 가능 — Candidate events are in the full registered corpus.
  - `legacy_demo`: 패키지 포함 / 부팅 등록 / fresh-start 정적 가능 — MainGame schedules cafe_00 from week 6; the player's listen, peek, and honest-apology choices can reach cafe_caught_honest.
  - `v2_playtest`: 패키지 포함 / 부팅 등록 / fresh-start 명시 계약 — The V2 cafe_world_glimpse bundle owns cafe_00; its authored follow-up closure includes cafe_caught_honest.

### 범죄

- **family_property_fraud_backstory · moderate** — 필수 프롤로그에서 아버지가 평생 모은 돈으로 사려던 강남 아파트가 사기로 날아갔고, 민준이 5년 안에 다시 집을 마련하겠다는 목표를 적는다. 플레이어는 이 사기의 가해자가 아니라 가족 피해를 출발점으로 삼는다.
  - 소유: `content/events/story_events.json`, `content/meta/narrative_spine.json`, `scenes/MainGame.gd`
  - 사건: `story_prologue_goal`
  - `retail_full`: 패키지 포함 / 부팅 등록 / fresh-start 명시 계약 — A fresh game enters story_flashforward and its authored prologue closure includes story_prologue_goal.
  - `legacy_demo`: 패키지 포함 / 부팅 등록 / fresh-start 명시 계약 — The same mandatory fresh-start prologue precedes the legacy 24-week route.
  - `v2_playtest`: 패키지 포함 / 부팅 등록 / fresh-start 명시 계약 — MainGame's fresh-start branch enters story_flashforward before V2 routing; its closure includes story_prologue_goal.
- **demo_money_mule_choice · strong** — 4주에 플레이어가 대포통장을 거절하거나 통장·카드·비밀번호를 넘겨 200만원을 받는다. 8주에는 모집책 검거 뉴스 또는 피해금 3천만원 반환 요청·경찰 연락 가능성과 추가 가담 선택이 오고, 수락 경로는 24주에 경찰의 초기 확인 전화나 모집책의 재접촉을 받는다. 혐의·처분이 확정됐다고 말하지 않는다.
  - 소유: `content/events/arc_events.json`, `content/events_en/arc_events.json`, `content/events/core_loop_v2_events.json`, `content/meta/narrative_spine.json`
  - 사건: `arc_temptation_01`, `arc_temptation_clean`, `arc_temptation_fallout`, `v2_dirty_trace_initial_call`, `v2_dirty_recruiter_week24`
  - `retail_full`: 패키지 포함 / 부팅 등록 / fresh-start 정적 가능 — The opening full-game arc schedules the same crime fork.
  - `legacy_demo`: 패키지 포함 / 부팅 등록 / fresh-start 정적 가능 — The legacy early arc includes the temptation and consequence chain.
  - `v2_playtest`: 패키지 포함 / 부팅 등록 / fresh-start 명시 계약 — The V2 spine owns the week-4 fork, week-8 clean/fallout roots, and the applicable week-24 initial-call or recruiter-contact root.
- **later_financial_and_property_crime · strong** — 본편에는 폰지·투자 사기, 내부자 거래, 지갑 현금 절취와 주거 사기 선택·결과가 비그래픽 텍스트로 더 등장한다. 재혁의 폰지 증거를 이용해 돈을 갈취하거나 사기를 함께 계속하는 선택도 플레이어가 직접 할 수 있다.
  - 소유: `content/events/arc_events.json`, `content/events/investment_events.json`, `content/events/amb_scenarios4.json`, `content/events/shadow_events.json`
  - 사건: `arc_jaehyuk_04b_counter`, `inv_insider_tip`, `amb_wallet_00`
  - `retail_full`: 패키지 포함 / 부팅 등록 / fresh-start 정적 가능 — The authored Jaehyuk counter route and weighted amb_wallet_00 event can reach extortion/continued-fraud and direct cash-theft choices. inv_insider_tip is packaged and registered but is not a normal foreground route.
  - `legacy_demo`: 패키지 포함 / 부팅 등록 / fresh-start 정적 가능 — amb_wallet_00 is a weighted foreground event with min_turn 3, so its direct cash-theft choice can occur before week 24; the other listed crimes remain later.
  - `v2_playtest`: 패키지 포함 / 부팅 등록 / fresh-start 차단 — No V2 1-24 bundle enters the later crime set.

### 음주·흡연·약물

- **adult_social_drinking · moderate** — 본편에서 소주·맥주·와인과 회식·데이트 음주가 반복되며 강권·숙취 결과도 있다. 음주 미니게임이나 유료 보상은 없다.
  - 소유: `content/events/amb_scenarios.json`, `content/events/arc_daeun.json`, `content/events/arc_daeun_romance.json`, `content/events/arc_romance_specials.json`, `content/events/korea_experience.json`, `autoloads/ImageRegistry.gd`, `assets/backgrounds/company_dinner_restaurant.png`
  - 사건: `amb_hoesik_00`, `amb_hoesik_drink`, `arc_daeun_first_night`, `kx_hangang_chimaek`
  - `retail_full`: 패키지 포함 / 부팅 등록 / fresh-start 정적 가능 — Workplace and romance routes can enter repeated drinking scenes.
  - `legacy_demo`: 패키지 포함 / 부팅 등록 / fresh-start 정적 가능 — amb_hoesik_00 is a foreground-allowlisted min_turn-8 event for employed players; its explicit drinking choice follows into amb_hoesik_drink. kx_hangang_chimaek remains packaged but is not a normal legacy foreground route.
  - `v2_playtest`: 패키지 포함 / 부팅 등록 / fresh-start 차단 — V2 weeks 1-24 contain no explicit alcohol-consumption scene.
- **tobacco_and_medicine_references · mild** — 담배는 경마장 냄새·편의점 진열 같은 배경 언급이며 흡연 행동은 확인되지 않았다. 처방약·복용은 건강 서사로 나오고 불법 약물 플레이는 확인되지 않았다.
  - 소유: `content/events/racetrack_events.json`, `content/events/core_loop_v2_events.json`, `content/events/life_events.json`
  - 사건: `race_first_visit`, `v2_convenience_trial_shift`, `v2_father_health_signal`
  - `retail_full`: 패키지 포함 / 부팅 등록 / fresh-start 정적 가능 — Background tobacco and health-medicine references exist in full routes.
  - `legacy_demo`: 패키지 포함 / 부팅 등록 / fresh-start 정적 가능 — Early health/background references may be scheduled; no smoking action is owned.
  - `v2_playtest`: 패키지 포함 / 부팅 등록 / fresh-start 명시 계약 — Convenience-store tobacco display and the week-21 medicine signal are explicit V2 roots.

### 생성형 AI

- **pre_generated_assistance · disclosure_required** — 일부 2D 아트·서사·영문 현지화·프로그래밍/코드와 오디오 소스 선별·편집·배열·믹싱에 사전 생성 AI 보조를 사용했고 개발자가 선별·수정·검수했다. 오디오 원음은 텍스트-투-오디오나 코드 합성 파형이 아니라 현장·사물 녹음 또는 녹음된 실악기 샘플이다.
  - 소유: `docs/STEAM_PAGE.md`, `docs/ART_AI_AUDIT.md`, `assets/IMAGE_PROMPTS.md`, `assets/audio/AUDIO_SOURCE_MANIFEST.json`, `assets/audio/AUDIO_SOURCE_LEDGER.md`, `tools/build_sample_audio_assets.py`
  - `retail_full`: 패키지 포함 / 로드 없음 / fresh-start 해당 없음 — Production provenance applies to shipped content, not a player route.
  - `legacy_demo`: 패키지 포함 / 로드 없음 / fresh-start 해당 없음 — The same all_resources source provenance applies to the demo package.
  - `v2_playtest`: 패키지 포함 / 로드 없음 / fresh-start 해당 없음 — The same all_resources source provenance applies to the V2 package.
- **no_live_generation · none** — 플레이 중 모델 추론·외부 AI 엔드포인트·실시간 생성은 없다.
  - 소유: `autoloads`, `scenes`, `systems`, `ui_components`, `docs/STEAM_PAGE.md`
  - `retail_full`: 패키지 포함 / 로드 없음 / fresh-start 해당 없음 — Runtime source scan finds no model/client/API path.
  - `legacy_demo`: 패키지 포함 / 로드 없음 / fresh-start 해당 없음 — Runtime source scan finds no model/client/API path.
  - `v2_playtest`: 패키지 포함 / 로드 없음 / fresh-start 해당 없음 — Runtime source scan finds no model/client/API path.

### 온라인 기능

- **offline_single_player · none** — 계정·서버·멀티플레이·채팅·원격 UGC·리더보드·텔레메트리·실결제 없는 오프라인 싱글플레이이며 모드는 로컬 데이터 파일만 읽는다.
  - 소유: `autoloads/ModLoader.gd`, `autoloads`, `scenes`, `systems`, `ui_components`
  - `retail_full`: 패키지 포함 / 로드 없음 / fresh-start 해당 없음 — Forbidden network API scan is zero; ModLoader reads local data.
  - `legacy_demo`: 패키지 포함 / 로드 없음 / fresh-start 해당 없음 — Forbidden network API scan is zero; ModLoader reads local data.
  - `v2_playtest`: 패키지 포함 / 로드 없음 / fresh-start 해당 없음 — Forbidden network API scan is zero; ModLoader reads local data.
- **steam_external_link · external_link_only** — 데모 종료 CTA의 한 동작만 OS 기본 브라우저로 Steam 위시리스트/스토어 URL을 연다.
  - 소유: `scenes/MainGame.gd`
  - `retail_full`: 패키지 포함 / 지연 / fresh-start 정적 가능 — The CTA code is packaged; visibility depends on the completion surface.
  - `legacy_demo`: 패키지 포함 / 지연 / fresh-start 정적 가능 — The demo completion CTA can expose the external link.
  - `v2_playtest`: 패키지 포함 / 지연 / fresh-start 명시 계약 — The V2 completion CTA owns the wishlist action.

## 생성형 AI·온라인 공시 경계

- 사전 생성 보조: 일부 2D 아트, 서사, 영문 현지화, 프로그래밍/코드,
  오디오 소스 선별·편집·배열·믹싱.
- 오디오 원음은 현장·사물 녹음 또는 녹음된 실악기 샘플이며 텍스트-투-오디오·
  코드 합성 파형은 없다. 이 출처 사실이 오디오 제작 과정의 AI 보조 공시를 없애지는 않는다.
- 런타임 생성, 플레이 중 외부 AI 서비스: 없음.
- 오프라인 싱글플레이. 서버·멀티플레이·채팅·원격 UGC·텔레메트리·실결제 없음.
- 예외는 데모 CTA의 `OS.shell_open` Steam 위시리스트/스토어 링크 1곳이며,
  `user://mods/`는 로컬 데이터 모드다.

## 제출 직전 수동 절차

1. 제출 후보의 full/V2 실제 pack ZIP을 아래 명령으로 검사하고 출력 해시를 보관한다.
2. Steam 파트너 설문과 국내 접수 화면을 다시 캡처해 문항·버전·빌드 해시를 묶는다.
3. 최종 등급·삭제·export 필터 변경은 사용자와 심의 주체가 결정한다.
4. 필수 심의 공시는 상점 마케팅에서 숨은 반전·Moral Tint를 공개할 허가가 아니다.

```bash
python3 tools/release_content_inventory.py --self-test
python3 tools/release_content_inventory.py \
  --pack-zip retail_full=build/qa/release_content_inventory/full.zip \
  --pack-zip v2_playtest=build/qa/release_content_inventory/v2.zip
```

## 공식 공개 근거 (확인일 2026-08-03)

- [steam_content_survey](https://partner.steamgames.com/doc/gettingstarted/contentsurvey?l=english) — Public overview only; the live partner form must be captured again for the submitted build.
- [grac_rating_rules](https://www.law.go.kr/LSW/schlPubRulInfoP.do?chrClsCd=&schlPubRulSeq=2200000127949) — Public rule displayed as effective 2024-03-22; re-check the current submission rule.
- [gcrb_submission_guide](https://www.gcrb.or.kr/Images/usingGuide/using_guide_01.html) — Public submission guide; the live intake form and requested evidence remain authoritative.
- [game_industry_promotion_act](https://www.law.go.kr/LSW/lsInfoP.do?lsId=010196) — Statutory reference only; this ledger is not legal advice.

Steam 공개 문서는 설문을 General Content, Mature Content, Generative AI의
세 구획으로 나누며, 업로드된 성인 콘텐츠는 접근 불가여도 공개하라고 안내한다.
공개 페이지에는 파트너 전용 전체 문항이 없고 Steam 답변이 한국 등급분류를
자동 대체하지 않는다. 이 문서는 법률 자문이 아니다.
