# ORDER-838 — 엔딩 도달 지도·분포 시뮬레이션·재플레이 검증

#### [ ] ORDER-838 · C1·C6 · 엔딩 도달·재플레이

2026-11-24 사용자 결정(풀프라이스 짜임새·일정 연기). 기준은 [SYSTEMS_DESIGN §5](../SYSTEMS_DESIGN.md)이 소유한다.
설계: Claude(이 사양). 구현·도구·검증: Codex. 834~837 뒤 착수한다.
측정 도구(D1)는 834 B1과 함께 먼저 만들어 다른 오더의 중간 실측에도 쓴다.

## 실측 — 지금의 엔딩 (main `79d81a3c`)

- 엔딩은 35개다(`content/endings.json`). 대표 런 C1은 `with_daeun`, 29.1은 번아웃 뒤 루틴으로 끝났다.
- 기존 `tools/SimRun.gd`는 옛 경제(기회 확률표·고정 급여)를 정책 봇으로 돌린다.
  새 이야기의 장면·선택을 지나가는 엔딩 분포 측정 도구는 없다.

## 엔딩 분류와 목표 상태

| 군 | 엔딩 | 지금 | 여는 오더 | 목표 |
|---|---|---|---|---|
| 관계·가족·나이 | `with_daeun` `jiyeon_man` `late_call` `ordinary_life` `sangchul_reckoning` `writer` | 도달(경로 일부 미문서) | — | 도달·문서화 |
| 몸과 마음 | `burnout` `mental_break` `healthy_retirement` `career_burnout` | 경고 없는 붕괴·경로 미문서 | 836 | 도달 |
| 빚 | `bankruptcy` `debt_spiral` | 음수 현금이 결과 없음 | 835 | 도달 |
| 직장 자산 | `career_climber`(1억) `orthodox_pinnacle`(2억) `stable_success`(10억) | 월급 직선으로 불가 | 835 | 1억·2억 도달, 10억은 드묾 |
| 투자 | `investment_master` `early_retirement` `reputation_legend` `unorthodox_legend` | 투자 정체성 닫힘 | 834·835 | 도달 |
| 도박 | `gambling_recovery` `crypto_ghost` | 도박 문 막다른 길 | 834 | 도달 |
| 창업 | `startup_exit` | 문 없음 | 835 | 드물게 도달 |
| 강남 입성 | `gangnam_dream` `empty_house` `jaehyuk_way` `lonely_rich` `gangnam_dream_white` | 30억 불가 | 834·835 | 상위 플레이에서 도달 |
| 경로 성향 | `orthodox_hollow` `balanced_life` | 경로 점수 9점뿐(도달 선택) | 834~836 결정에 경로 점수 배분 | 도달 |
| NG+ | `full_circle` `second_love` `guardian` | 새 이야기 저장에서 미확인 | 838 D3 | 도달 |
| **의도적 비도달** | `creator_success`(출시 후로 미룸) `political_fix`(새 이야기에 경로 없음) `instant_legend`(1년 차 30억, 히든) | — | — | 문서에 "새 이야기 비도달"로 명시 |

- 목표: 35개 중 **32개가 도달 가능**하고 각각 문서화된 선택 경로를 가진다(SYSTEMS_DESIGN 기준 28개 이상).
  `instant_legend`는 히든 신화로 남기되, 새 이야기에서 수학적으로 불가능하면 그 사실을 기록한다.
- 엔딩 판정 순서는 [종결 정체성 우선 결정](../DECISIONS.md)을 따른다.
  우선순위 때문에 가려져 사실상 나오지 않는 엔딩이 있으면 D2 분포에서 드러내고, 순서 변경은 사용자에게 올린다(`finish_run` 라우팅은 승인 사항).

## 설계

### D1. 새 이야기 정책 런 도구

- `FullStoryFlow`를 헤드리스로 240주 진행하며 **장면의 실제 선택**을 정책 봇이 고르는 도구를 만든다.
  - 옛 기회 확률표가 아니라 실제 사건 JSON·이야기 지도·834 활동 영수증을 지나간다.
  - 미니게임은 정책별 고정 베팅 규칙으로 대체하고, 결과는 실제 활동 영수증 경로로 기록한다.
- 정책 6종:
  - **성실**: 직장·저축
  - **투자**: 834 A 결정 일관
  - **도박**: 834 B
  - **관계 우선**: 사람 갈래 결정 우선
  - **무리한 상승**: 레버리지·밤샘·대출 수락
  - **회복**: 836 회복 결정 우선
- 각 정책 × 시드 N(기본 50). 출력은 엔딩 분포, M24·M48·M60 순자산, 연속 공백, 결정 없는 달, 수치 독자 도달 수다.
- 이 출력이 SYSTEMS_DESIGN 기준선 표를 다시 쓰는 공식 측정이 된다.

#### D1 첫 실행 — 2026-11-24 (Claude, 브랜치 `claude/game-launch-prep-5l8u32`)

- 도구: `tools/FullStoryPolicyRun.gd`(제품 흐름 드라이버 `FullGameRuntimeTrace.gd`를 수정 없이 상속, 보이는 선택만 정책 점수로 고름, 경마는 키보드)
  · `tools/full_story_policy_run.py profiles|run|summary`. 런마다 HOME 격리, 깨끗한 트리만 실행, 300초 무진척 감시.
- 비용 실측: 240주 1런 40~60분(4코어에서 3병렬). **시드 50은 이 장비로 약 80시간**이다. 기본 N은 `[첫 실행 재조정]`으로 내려
  정책당 3(이번), 큰 장비 야간 10을 권고한다. 정책 가중치도 `[첫 실행 재조정]`이다.
- 6정책 × 3시드 = 18런. 커밋 `6fd77db0`(3런)·`18e26e34`(15런, W240 정지 수리 포함).

| 정책 | 엔딩 | M24 | M48 | M60 | 4주+ 공백/런(최장) | 결정 없는 달 | 체력/정신 최저 | 현금 최저 |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| 성실 | with_daeun 2, healthy_retirement 1 | 2,284만 | 6,706만 | 7,963만 | 7.0(11) | 6.3 | 62/59 | 50만 |
| 투자 | healthy_retirement 3 | 2,147만 | 6,013만 | 7,357만 | 7.3(11) | 6.7 | 62/60 | 50만 |
| 도박 | healthy_retirement 2, writer 1 | 2,227만 | 6,502만 | 7,733만 | 7.0(11) | 7.0 | 54/49 | 50만 |
| 관계 우선 | sangchul_reckoning 2, burnout 1(W91) | 1,796만 | 4,028만 | 5,351만 | 6.3(11) | 5.0 | 62/60 | −32만 |
| 무리한 상승 | healthy_retirement 2, burnout 1(W67) | 2,167만 | 5,863만 | 7,174만 | 6.7(11) | 5.3 | 43/30 | 50만 |
| 회복 | with_daeun 3 | 1,632만 | 4,366만 | 4,846만 | 5.0(11) | 5.0 | 62/60 | −32만 |

중앙값. 번아웃 런은 멈춘 주까지만 센다.

- **분포**: 18런 엔딩 5종(35개 중), 최다 `healthy_retirement` 44% → D2 상한 35% 초과. 정책당 2종 이상은 투자·회복이 미달(1종).
- **전략이 결과를 바꾸지 않는다**: 투자·도박 M60이 성실과 같은 7천만대, `player_route`는 18런 모두 `none`.
  도박 정책도 5년간 실제 베팅은 1회(W15 경마 3판, −3만원), 활동 영수증 있는 런은 18 중 2. 834 갈래 고유 엔딩 15%는 0%.
- **리듬**: 전 정책 4주+ 공백 런당 5~7곳, 최장 11주. 결정 없는 달 런당 5~7. 837 목표(≤3주·0달)와 거리.
- **경고 없는 붕괴**: 번아웃 2런은 체력이 48→1(91주)·52→1(67주)로 꾸준히 내려가는 동안 경고 장면 없이 엔딩. 관계 우선 W91 런은
  W16부터 현금 음수가 76주 이어져 −768만원까지 결과 없음(835·836 목표 위반 실측).
- **도구가 찾은 제품 결함**: W240 카운트다운 결과에서 엔딩에 못 가는 정지(6런 중 3) → `FullStoryFlow` 연차 장면 영수증 수리·회귀 검사.
- 남은 도구 한계: 바탕 드라이버가 W240 이전 엔딩을 오류로 기록한다(엔딩 자체는 요약에 남음). 수치 독자 도달 수는 아직 세지 않는다.

#### 엔딩 도달 지도 — 2026-11-24 (판정 `GameState.check_game_over`, 관측 D1 18런)

"생산자"는 그 엔딩이 읽는 플래그를 켜는 사건이고, 괄호는 D1 18런 중 그 사건을 본 런 수다. 수치는 트레이스에 없어 "미관측"으로 둔다.
판정은 위에서 아래로 첫 일치가 이긴다.

| 순서 | 엔딩 | 판정 조건(요약) | 새 이야기 생산자(D1 본 런) | D1 | 막힌 곳 → 오더 |
|---|---|---|---|---:|---|
| 즉시 | `burnout` `mental_break` | 체력/정신 0 | 루틴·선택 감소 | 2/0 | 경고 장면 없음 → 836 |
| 즉시 | `debt_spiral` `bankruptcy` | 순자산 −2억/−1억 미만 | 빚·대출 없음(최저 −768만) | 0 | 835 |
| 즉시 | `crypto_ghost` | 중독 성향 90+ | 올리는 사건 28개, 본 런 0 | 0 | 834 |
| NG+ | `full_circle` `second_love` `guardian` | 메타 기록 + `ng_*` | `arc_daeun_ng_meet`(0)·`arc_father_ng_call`(0) | 0 | 2회차 측정 필요 → D3 |
| 특수 | `startup_exit` | `startup_exit` | 인수 사건 2개(0) | 0 | 835 |
| 특수 | `instant_legend` | 33세에 순자산 30억 | — | 0 | 의도적 비도달 후보 |
| 30억 | `empty_house` `lonely_rich` `gangnam_dream` `jaehyuk_way` `gangnam_dream_white` | 최고 자산 30억 + 마지막 주 뒤 관계·도덕 분기 | 분기 플래그는 생산됨(`fell_to_darkness` 11, `crossed_line` 11) | 0 | 30억 경로 없음 → 834·835 |
| 특수 | `creator_success` `political_fix` | `creator_viral`+3억 / `political_winner` | 각 1개(0) | 0 | 의도적 비도달 |
| 38세 | `with_daeun` | `daeun_romance_started` | `arc_daeun_04b_future`(11)·`arc_daeun_y5_feelings`(4) | 5 | 도달 |
| 38세 | `ordinary_life`(지연 변주) `jiyeon_man` | `jiyeon_left` / `jiyeon_romance_started` | `arc_jiyeon_verdict_decision`(0)·`arc_jiyeon_year5_return`(2) | 0 | 지연 5년 차 진입 드묾 → 837 |
| 38세 | `gambling_recovery` | `beat_addiction` | `recovery_one_month_clean`(0) | 0 | 834 |
| 38세 | `sangchul_reckoning` | 상철 신고/빚 회수 + 아버지 생존 | `arc_sangchul_reckoning`(8) | 2 | 도달 |
| 38세 | `reputation_legend` | 평판 80+ | 올리는 사건 314개 중 본 것 17(합 +53) | 0 | 미관측 → 836 수치 독자 |
| 38세 | `orthodox_pinnacle` `unorthodox_legend` `early_retirement` `investment_master` `stable_success` | 순자산 5억~10억 + 경로/직업/투자감각 | 자산 최대 8,329만 | 0 | 835 |
| 38세 | `balanced_life` `career_climber` | 1억 + 경로 균형 / 이직·직급 4 | `max_job_tier` 18런 모두 1, 직장 사건 `work_*`·`callback_job_change_outcome`(0) | 0 | 835 |
| 38세 | `healthy_retirement` | 체력·정신 70+ + 가까운 관계 | 루틴이 끝까지 회복시켜 거의 항상 참 | 8 | 과점 → 아래 R1 |
| 38세 | `orthodox_hollow` | 정석 20+ + 3억 미만 | 미관측 | 0 | 경로 점수 9뿐 → 834~836 |
| 38세 | `late_call` | 아버지 화해 + 생존 | `arc_father_05_after_visit`(16) | 0 | `healthy_retirement`에 가려짐 → R1 |
| 38세 | `career_burnout` | 직장 + 번아웃 자각/이직 시도 | `work_burnout_monday`(0)·`work_year_review`(0) | 0 | 835·836 |
| 38세 | `writer` | 사건 90+ + 지능 65+ + 고시원 + 3억 미만 | — | 1 | 도달(우연) |
| 끝 | `ordinary_life` | 나머지 | — | 0 | — |

**판정 순서 때문에 생기는 문제(사용자 승인 사항, `finish_run` 라우팅)**

- **R1 `late_call` 가림**: 아버지 화해가 16/18런에서 켜지는데 `late_call`은 0이다. 바로 위의 `healthy_retirement`가 "체력·정신 70+ + 관계"를
  묻고, 지금 루틴은 마지막 주까지 둘을 거의 100으로 회복시켜 사실상 항상 참이다. 836이 몸·마음에 대가를 붙이면 일부 풀리지만, 화해한 아버지가
  있는 런의 결말이 "건강한 은퇴"로 덮이는 구조는 남는다. **권고:** 836 구현 뒤 D1을 다시 돌려 `healthy_retirement`가 35%를 넘으면
  `late_call`을 `healthy_retirement` 위로 올린다. 안 하면 아버지 서사를 끝까지 지킨 런이 계속 일반 결말로 끝난다.
- **R2 결혼했는데 다은이 없는 결말**: `daeun_married`가 켜졌지만 `daeun_romance_started`가 없는 런 3/18이 `healthy_retirement`·
  `sangchul_reckoning`으로 끝났다. 38세 판정은 연애 시작만 묻고 결혼은 30억 분기만 읽는다. **권고:** 38세 판정의 `with_daeun` 조건에
  `daeun_married`(이혼 아님)를 더한다. `with_daeun` 본문에는 이미 `daeun_married` 변주가 있고 `healthy_retirement`에는 없다. 안 하면 다은과 결혼한 플레이어의 마지막 화면에 배우자가 빠진다.

### D2. 분포 기준 `[첫 실행 재조정]`

- 전 정책 합산에서 **한 엔딩이 35%를 넘지 않는다.**
- 정책마다 서로 다른 엔딩 **2개 이상**이 실제로 나온다.
- 투자·도박 정책에서 갈래 고유 엔딩이 각각 15% 이상 나온다.

### D3. 재플레이

- NG+ 메타 플래그(`MetaProgression`)가 새 이야기 저장의 런 종료에서 누적되고, 2회차 새 이야기에서 NG+ 사건과 엔딩을 연다.
- 업적 15종이 새 이야기에서 실제 해금되는지 확인한다(`ACHIEVEMENT_PATH_CHECK`의 경로 대비).
  도달 불가 업적은 경로를 붙이거나 목록에서 "새 이야기 비도달"로 표시한다.
- 갤러리·엔딩 수집이 새 이야기 엔딩을 기록하는지 확인한다.
- 2회차에 다른 갈래를 고르면 장마다 다른 장면이 1개 이상 나오는지 D1 정책 쌍으로 비교한다.

### D4. 엔딩 문체

엔딩 본문은 플레이어가 마지막으로 읽는 글이다. #43 기준(대시·해설형 마무리 제거)으로 35개를 5언어로 정리한다.
예: `crypto_ghost`의 "한 번은 사고지만 두 번은 패턴이었다 —" 같은 마무리.

## 배치

- **B1** D1 도구(834 B1과 병행해 먼저) + 엔딩 도달 지도 문서화 + 비도달 3종 명시
- **B2** 834~837 완료 뒤 D2 분포 측정·조정 제안 + D3 재플레이 검증 + D4 엔딩 문체

## 검증

- D1 출력 표(정책 6종 × 시드)를 증거로 남긴다.
- 엔딩별 도달 경로 문서와 실제 D1 도달이 일치하는지 확인한다.
- `EndingRouteIdentityCheck`·`ACHIEVEMENT_PATH_CHECK`·`GalleryReplaySnapshotCheck`를 새 이야기 저장 경우로 확장한다.

## 범위 밖

엔딩 신규 추가, `finish_run` 순서 변경(사용자 승인 필요), 옛 SimRun 경제표 갱신, 체험판 M01~M06 바이트, `project.godot`, 외부 업로드.
