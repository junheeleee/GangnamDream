# ORDER-834 — 정식판 투자·도박 갈래 (C6)

#### [~] ORDER-834 · C6 · 투자·도박 갈래를 정식 새 이야기에 챕터별로 연결

2026-11-24 사용자 승인. 근거: [C6 세 갈래 필수](../DECISIONS.md#2026-11-15-정식판-세-갈래-필수--사용자-결정),
[투자·도박 갈래 설계 결정](../DECISIONS.md#2026-11-24-투자도박-갈래는-기존-장면을-챕터별로-잇는다--사용자-승인).
833 다듬기 뒤 착수한다. 설계·실측: Claude. 구현·산문·번역·검증: Codex.
**[~] 착수 — Claude B1 투자 1~2년 차(사용자 지시 2026-11-26).** 만지는 파일: `systems/InvestBranchBeats.gd`(신규),
`content/meta/invest_branch_ledger.json`(신규), `scenes/MainGame.gd`(빈 주 라우팅 한 곳), 투자 재사용 사건의
조건·`tendency` 효과(KO), `tools/InvestBranchBeatsCheck.*`(신규), `tools/audit_scope.json`, `docs/BALANCE.md`.
`StoryMode.gd`·`arc_drama.json`·`ManualSaveCheck`(Codex W188 범위)는 건드리지 않는다.
**[~] 착수 — Claude B2 도박 1~2년 차(사용자 지시 2026-11-26).** 만지는 파일: `systems/GambleBranchBeats.gd`(신규),
`content/meta/gamble_branch_ledger.json`(신규), `systems/FullStoryFlow.gd`(활동 일반화), `scenes/MainGame.gd`(빈 주·활동 라우팅),
도박 재사용 사건의 조건·효과(KO), `tools/GambleBranchBeatsCheck.*`(신규), `tools/audit_scope.json`, `docs/BALANCE.md`.

**[~] 착수 — Claude B2.5 빈 주 습관 방문(사용자 승인 2026-11-26).** 만지는 파일: `systems/BranchHabit.gd`(신규),
`content/meta/branch_habit_ledger.json`(신규), 습관 사건(신규, KO `content/events/branch_habit_events.json`·EN 오버레이·ja/zh 원장),
`systems/FullStoryFlow.gd`(`ACTIVITY_SOURCES` 출처 추가), `scenes/MainGame.gd`(빈 주 라우팅 한 곳), `tools/BranchHabitCheck.*`(신규),
`tools/audit_scope.json`, 정책 런 도구, 사건 등록 원장들, `docs/BALANCE.md`. Codex W188 범위는 건드리지 않는다.

**[x] 완료 — Claude B2.6 중독 바닥·회복 보장(사용자 승인 2026-11-26, 결과 아래).** 파일: `AddictionArc.gd`(신규)·`GameState`(정식 런 중독 종료 한 곳)·`EventManager`(별세 변형 한 줄)·`arc_addiction_recovery` 5언어·`BranchHabit`·`MainGame` 라우팅 한 곳·`AddictionArcCheck`.

**[x] 완료 — Claude B3 두 갈래 3~4년 차(사용자 지시 2026-11-27, 결과 아래).** 만지는 파일: `systems/BranchBeats.gd`(중독·시장 국면·손익률·상철 단계·성향 조건),
`systems/InvestBranchBeats.gd`·`systems/GambleBranchBeats.gd`(문맥 전달), `content/meta/invest_branch_ledger.json`·`gamble_branch_ledger.json`,
`scenes/MainGame.gd`(문맥 전달 두 곳), 재사용 사건 13개의 매매 키·5언어 문체/정합(`investment_events`·`drama_events`·`racetrack_events`·`holdem_events`·`life_events`),
`tools/InvestBranchBeatsCheck`·`GambleBranchBeatsCheck`, 등록 원장들, `docs/BALANCE.md`. 판돈 상한은 올리지 않는다.

## Claude 결과 (2026-11-26)

- **B1 투자 1~2년 차 — 동작 확인.** 투자 정책 2런(`7a8ac428`): W17 수업 → W32 첫 매수 → W37 공부 → W40 밤 매수 →
  W43 첫 손실 추가 매수(투자자 정체성 실현 W43) → W54 레버리지 → W58 코인, 멈춤 0·240주 완주(`late_call` 2).
  보유 평가 정점 약 235만원(W60), M60 순자산 6,952만/7,026만원으로 다른 정책 대역(4,987만~7,880만원)과 같다.
  큰돈이 걸리는 갈림은 B3 몫이다. 수치 근거는 [BALANCE](../BALANCE.md) 2026-11-26.
- **B2 도박 — 활동 영수증 수리.** 도박 정책 첫 런이 W78 정선 칩 교환 결과에서 멈췄다. W15에 닫힌 경마장 영수증이
  "대기 활동이 없어야 한다" 규칙(경마장 하나뿐이던 시절)에 걸려 새 정선 플래그와 함께 세션 전체를 무효로 만들었다.
  닫힘·취소 영수증은 자기 주에서만 대기 플래그를 금지하도록 `FullStoryFlow._valid_activity_receipts`를 고쳤다
  (지난 주의 대기 플래그는 `complete_turn`이 이미 막는다).
- **B2 재실행(`54cc6816`, 도박 정책 3런) — 정지 0.** s01: W15 경마장 → W32~46 경마 5장면 → W79 정선 칩 교환·시계 없는 방
  (카지노 세션 −2만원) → W84 숙박 제안 → W240 `sangchul_reckoning`. s03: W60·64·71 홀덤 3장면(W71 세션 +2.9만원) → W240
  `late_call`. 세 활동 모두 같은 주에 열고 닫혀 대기 플래그가 남지 않았고, 결과 닫기 거부 로그는 0이다.
  s02는 W14 일자리를 거절한 무직 런으로 W68 번아웃(몸 경고 W7·31·42·51 발화). 도박 갈래가 아니라 836 B2
  "무직 런 건강 소모·회복 결정 장면 부재" 몫이다. M60 순자산 7,070만/7,441만원으로 다른 정책과 같은 대역이다.
  미니게임 판돈(세션당 슬롯 5회·홀덤 3핸드)이 작아 1~2년 차 도박은 돈을 거의 움직이지 않는다. 큰돈·파산은 B3·B4 몫.
- **B2.5 습관 방문 실측(`5ee97fa6`, 도박 2·투자 1):** 도박 s01 W33·37 감·W38 거절·W43·44·47 감·W51 습관 변형, s03 홀덤 4회(W61~67)·정선 5회(W79~98)·W99 습관 변형. 두 도박 런 모두 중독 90 즉시 종료(W51·W108)로 끝나 B2.6을 열었다.
- **B2.6 바닥·회복 실측(`4d23f527`, 도박 3런, 정지 0):** s01 W46 바닥→"한 판만 더"→W54 파멸, s03 W107 바닥→"한 판만 더"→W109 파멸, s02 W44 바닥→도움→W45 회복 첫 주→W51 재발 시험에서 재발→습관 재개(W64 무직 번아웃, 836 B2 몫). 장면 없는 중독 종료 0. 이스터에그 실노출(W54 삼각김밥). 도박 정책은 중독을 선호해 회복 완주 런은 아직 없다(`AddictionArcCheck`가 단계 간격을 덮는다).
- **B3 실측(`9d3d36a6`, 투자 2·도박 1, 정지 0):** 투자 s01 W131 회색지대 → W142 폭락(분할 매수), s02 W99 폭락 → W103 상철 경고 → W109 회색지대. M60 6,249만/5,424만원으로 B1 대역보다 낮고 두 런 모두 4년 차에 보유를 정리한다(갈림 없음, B4·835). 도박 s02는 W60 무직 번아웃(836 B2)이라 3~4년 차 도박은 `GambleBranchBeatsCheck`만 덮는다.
- **습관 연속 상한:** 같은 계좌 습관 문장이 최대 5주 연속(s02 45장면) → 같은 활동 연속 2주 뒤 3주 쉼(`BranchHabit`·원장·검사). 재실행(`6a4b0274`, s02): 습관 45→22장면, 최대 연속 2주, 4주+ 공백 0, 결정 없는 달 0→1, 3~4년 차 투자 3장면 발화, M60 6,453만원. 상태별 문장 변주는 다음 후보.
- **QA(11-27):** 별세 뒤 바닥 장면 멈춤(변형이 생존 필수 태그 복사) 수리·회귀 검사, 정선·상철 배경 수리, 습관 문장 한 런 10~45번 → 활동당 연 6번(승인). **후속:** 습관 문장 상태별 변주.
- **남은 일(Codex):** `ManualSaveCheck`에 홀덤·정선 영수증과 "지난 주 닫힌 경마장 + 이번 주 정선 대기" 경우 추가(W188 범위라
  Claude는 손대지 않음), 활동 진입·복귀 `ScreenshotQA`, B3~B5.

## 실측 — 지금 왜 갈래가 아닌가 (2026-11-24, main `79d81a3c`)

- **실제 런 노출 0.** [C1·29.1 주차 기록](../queue_archive/ORDER-833-foreground-weeks.tsv)의 사건 331개 중
  `gambling` 73·`investment` 85 범주는 0회다. 이 사건들은 옛 랜덤 풀에 있고 새 이야기는 그 풀을 돌리지 않는다.
  돈 관련 노출은 W15/16 `arc_invest_guidance`, W76 `arc_sangchul_casino_*`, 콜백 1개뿐이다.
- **투자 정체성이 열리지 않는다.** 새 이야기는 `player_route="none"`으로 시작하고, 자각 임계는
  `TENDENCY_REALIZE_THRESHOLD=12`·격차4다. 그런데 사건 선택 전체의 투자 성향 점수는 6이고 실제 런 도달은 0이다.
  나머지는 옛 AP 행동 가중치였다. 그래서 `Chapter5CausalRoute`(투자형·W195·20억+, 19 root/47 선택)가 닫혀 있다.
- **도박 문이 막다른 길이다.** W76 "같이 가겠습니다"가 `casino_club_introduced`를 쓰지만, 그 독자는
  랜덤 풀의 `casino_chip_exchange`·`casino_no_clocks`·`casino_comp_offer`와 옛 AP UI뿐이다.
  새 이야기 활동은 `FullStoryFlow.begin_activity`가 `racetrack`만 받고, 그 생산자 `race_first_visit`도 랜덤 풀이다.
- **결과:** C1 M60 순자산이 약 5천만원(월급만)이다. 30억·재테크 달인(5억+)·5년 차 투자 경로(20억+)에 닿지 않는다.

## 설계 원칙

- **재사용 우선.** 아래 기존 사건을 새 이야기에 배치한다. 새 산문은 5년 차 도박 결산과 연결 문장에 한정한다.
- **옛 주간 행동판·월간 약속판·랜덤 풀을 다시 열지 않는다.** 투자 행동은 이야기 선택이 소유한다(매매 화면은 장면이 여는 활동, 839).
  도박은 이야기가 연 미니게임 활동 하나가 소유한다.
- 선택은 표현·기억·결정 세 층을 쓴다. 새 플래그는 생산자와 실제 독자를 함께 둔다(write-only 0).
  route·tint·확률은 노출하지 않는다.
- 갈래에 들어가지 않은 플레이어의 이야기·사람 갈래는 바뀌지 않는다. 결정한 선택에서만 다음 장의 문이 열린다.
- 모든 갈래가 30억을 보장할 필요는 없다. 다만 각 갈래가 **해마다 새 기회·대가·회수**를 가져야 한다.

## 갈래 A — 투자: "정보와 돈 사이의 거리"

| 장 | 전개 | 재사용 사건 | 핵심 결정 · 독자 |
|---|---|---|---|
| 1년 차 입문 | 상철 조언 → 계좌 → 첫 수익/손실 | `arc_invest_guidance` `arc_ch1_invest_first_chart` `invest_first_win`/`invest_first_loss`·`arc_invest_first_loss` `goshiwon_invest_night` `arc_ch1_theme_invest_deep` | 손절/버팀/물타기 → 2년 차 레버리지 장면의 비용·대사 |
| 2년 차 광풍 | 코인·공모주·레버리지 → 연말 '투자형' 자각 | `inv_crypto_mania`(W49–96) `inv_ipo_hot_tip`(W49–72) `leverage_temptation` `drama_crypto_allin`+결과 | 원칙/레버리지 → 3년 차 폭락의 손실 크기 |
| 3년 차 폭락 | 폭락과 정보의 출처 | `market_crash_panic` `sangchul_tip_warning` `unorthodox_gray_zone_tip` / `orthodox_institutional_access` | 회색 정보 사용 여부 → 상철 진실·도덕 축 |
| 4년 차 사다리 | 재개발 정보 → 관리 → 완공 매도 | `inv_redev_zone_tip`(W112–143) `inv_redev_completion_sale`(W160+) `sangchul_tip_redev` | 빠질 시점 → 5년 차 진입 자산 |
| 5년 차 결산 | 부동산 투자 경로(완성) | `Chapter5CausalRoute` 19 root | 엔딩 `investment_master`·`early_retirement`·`gangnam_dream` / `bankruptcy` |

- **투자 정체성(사용자 승인):** 1~2년 차 투자 결정 선택에 `tendency.invest`를 넣는다.
  꾸준히 투자를 고른 플레이어만 2년 차 말까지 12/격차4에 닿게 하고, 그 순간 `투자형`·`route_invest`가 선다.
  저축·거절 갈래는 점수를 쌓지 않는다. 수치는 `BALANCE.md`에 근거와 함께 적는다. `[첫 실행 재조정]`
- 매매 화면은 11-27 결정으로 [839](ORDER-839.md)가 장면이 여는 활동으로 연다. 그 전까지 금액·손익은 선택 결과로 처리한다.

## 갈래 B — 도박: "이길 수 있다는 착각"

| 장 | 전개 | 재사용 사건 · 활동 | 핵심 결정 · 독자 |
|---|---|---|---|
| 1년 차 유혹 | 단톡방 토토 링크 → 과천 첫 방문 | `gambling_007` `gambling_020` `race_first_visit` → **경마 활동** `racetrack_mentor_meet` | 다시 갈지(`racetrack_will_return`) → 2년 차 단골 장면 |
| 2년 차 습관 | 단골·홀덤펍 → W76 정선 초대 | `race_number_three`+결과 `race_last_train_home` `holdem_first_visit` → **홀덤 활동** `arc_sangchul_casino_*` → **정선 카지노 활동**(6종) | 한도 설정/칩 추가(`casino_set_limit`·`casino_chips_loaded`) |
| 3년 차 깊이 | 시계 없는 방·콤프·빚·아버지의 눈치 | `casino_chip_exchange` `casino_no_clocks` `casino_comp_offer` `drama_addiction_mirror` `drama_addiction_debt` `drama_addiction_warning` | 대출로 칩/멈춤 → 4년 차 바닥 진입 |
| 4년 차 바닥 | 바닥 → 회복 또는 지속 | `gambling_rock_bottom` `recovery_first_week` `recovery_relapse_test` `recovery_one_month_clean` · `race_big_win` `holdem_big_pot` | 끊을지/한 번 더 → 5년 차 결산 분기 |
| 5년 차 결산 | **신규 1~2장면** | 신규(5언어) | 엔딩 `gambling_recovery` / `bankruptcy`·`debt_spiral` / 드문 큰돈 → `unorthodox_legend` |

- **실제 미니게임(사용자 승인).** `FullStoryFlow`의 활동을 `racetrack` 전용에서 `racetrack`·`holdem`·`jeongseon_casino`로
  일반화한다. 대상은 `begin_activity`/`close_activity`/`_valid_activity_receipts`와 `MainGame._full_story_route_activity`다.
  이야기 결정이 연 주에만 한 번 열린다. 결과 금액은 활동 영수증과 `addiction_tendency`에 남고, 다음 장면이 그것을 읽는다.
- 옛 저장(활동 영수증이 racetrack만 있는 full run)은 그대로 열려야 한다. 표식 없는 옛 저장은 새 갈래에 편입하지 않는다.

## 연결 장치 요구

1. 갈래 사건은 `story_map.json` 해당 월의 **조건부 beat**로 배치한다. 랜덤 풀 가중치로 부활시키지 않는다.
   각 beat는 진입 조건(갈래 플래그·성향·자산), 1회성, 비용, 다음 동사, 근거리·장기 독자를 선언한다.
2. 이야기·사람 갈래 beat와 같은 주에 겹치면 이야기 beat가 우선한다. 갈래 beat는 다음 빈 주로 미루되 그 해를 넘기지 않는다.
3. 기존 사건의 조건(`has_portfolio`, `min_addiction` 등) 중 새 이야기에서 만족할 수 없는 것은 실제 생산자를 붙이거나
   조건을 갈래 플래그로 바꾼다. 영어 오버레이·CJK는 text-only로 유지한다.
4. 사건 생명주기 원장과 `release_content_inventory` 등급 축(도박·투자)을 같은 커밋에서 갱신한다.
5. **아버지 생사 정합(재사용 풀 점검 2026-11-24 실측).** 선택지 단위 생사 가드는 런타임에 없다
   (`StoryMode._choice_visible`은 아이템·의무만 본다). `gambling_rock_bottom`의 "아버지에게 모든 걸 털어놓는다"는
   `father_passed` 뒤에도 보인다. 배선 시 `FATHER_PASSED_EVENT_VARIANTS` 변형 사건(5언어)을 만들거나 4년 차 바닥 beat 진입을
   생존 구간으로 묶는다. `drama_addiction_warning`은 이미 `requires_living_father` 태그로 막혀 있다.

## 밸런스 실측 (구현 전 1회)

`tools/balance_sim.py` 또는 full-run 시뮬로 갈래별 대표 선택 열에서 M24·M48·M60 순자산을 잰다.
- 투자 갈래가 W195 20억 진입·5억 재테크 달인에 닿는 비율
- 도박 갈래의 파산·회복·큰돈 비율

밴드 밖 수치 변경은 사용자에게 올린다.

## 배치 (각 1~2배치, 선언 커밋 선행)

- **B1** 연결 장치 + 투자 1~2년 차 + 투자 정체성
- **B2** 활동 일반화(홀덤·정선) + 도박 1~2년 차
- **B3** 두 갈래 3~4년 차
- **B4** → [840](ORDER-840.md) G4로 이동(11-27)
- **B5** 갈래별 대표 플레이: 새 이야기 → 진입 → 해마다 결정 1개 이상 → 엔딩 반영. 중간 저장/불러오기 포함

## 검증

- `arc_flow_sim`, `en_coverage_check`, JA/zh 감사, `story_graph_contract`, `release_content_inventory`
- 저장 재개 검사(`ManualSaveCheck`)에 갈래 활동 영수증 경우를 추가
- 화면: 활동 진입·복귀를 KO/EN 목표 해상도 `ScreenshotQA`로 확인
- 대표 플레이 증거는 갈래마다 1런. 사람 플레이·청취는 별도 OPEN

## 범위 밖

- 상시 매매 메뉴(839 밖), 옛 AP 행동판, 범용 연락 메뉴, 갈래별 동일 수익 보장
- 체험판 M01~M06 바이트, `project.godot`, 외부 업로드

## 일정 위험

12월 중순 목표 대비 빠듯하다. 미완이면 갈래를 빼지 않고 일정 판단을 사용자에게 올린다.
