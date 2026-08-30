# Active Queue Spec: ORDER-142

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-142 [P0·전체 볼륨] M01~M60의 장면·선택·회수·상승 밀도를 한 작품으로 관리한다

**사용자 승인 (2026-08-31):** “출시 데모자체는 m6이 맞아 이대로 go하고 이제
게임개발 범위를 m60에 이르기까지 풀범위로 고려하면서 전체 볼륨을 관리해줘.”
따라서 공개 데모는 exact `story_demo_rc` M01~M06으로 닫고, 본편 제작 판단은
M07~M24 같은 임의 중간 범위가 아니라 M01~M60 전체를 동시에 본다.

## 깊이 3문

1. 월마다 장면 수만 맞추면 짧은 카드가 늘고 인과 밀도는 낮아진다. 실제 root의
   문단·선택·결과·후속·기억 독자를 함께 세어 한 장면의 기능을 측정한다.
2. 모든 중요 장면을 10비트로 맞추면 숫자가 원고를 지배한다. 비트 수는 감각,
   갈등 전환, 선택 준비, 행동, 결과, 회수, 닫는 이미지처럼 서로 다른 기능이
   실제로 필요할 때만 늘리고, 1~2비트 장면도 bridge 기능이면 합법으로 둔다.
3. 전체 평균만 보면 후반의 얇음과 중간의 과밀이 숨는다. 5개 장·60개월을 같은
   축으로 재되 장별 시작→중간→정점의 상승, 경로별 최장 공백, 선택 회수 지연을
   별도로 보고 다음 표적 배치를 고른다.

## 배치 A — 60개월 실측 기준선 20단위

1. Chapter 1 M01~M12의 작성 root·terminal·선택·결과·후속 독자를 전수 집계한다.
2. Chapter 2 M13~M24를 같은 방식으로 집계한다.
3. Chapter 3 M25~M36을 같은 방식으로 집계한다.
4. Chapter 4 M37~M48을 같은 방식으로 집계한다.
5. Chapter 5 M49~M60을 같은 방식으로 집계한다.
6. Chapter 1의 표현·기억·결정 선택과 실제 receipt reader를 분리한다.
7. Chapter 2의 같은 선택·reader 토폴로지를 분리한다.
8. Chapter 3의 같은 선택·reader 토폴로지를 분리한다.
9. Chapter 4의 같은 선택·reader 토폴로지를 분리한다.
10. Chapter 5의 같은 선택·reader 토폴로지를 분리한다.
11. Chapter 1의 월별 비트 기능·문단·선택·결과 깊이 분포를 측정한다.
12. Chapter 2의 같은 깊이 분포를 측정한다.
13. Chapter 3의 같은 깊이 분포를 측정한다.
14. Chapter 4의 같은 깊이 분포를 측정한다.
15. Chapter 5의 같은 깊이 분포를 측정한다.
16. story map root의 실제 사건 존재·생명주기·제품 ingress·fallback을 교차한다.
17. 월별·경로별 최장 무작성 공백과 같은 인물·주제선의 끊김을 계산한다.
18. 각 장의 시작 4개월·중간 4개월·마지막 4개월 사이 선택 비용과 회수 깊이가
    상승하는지 비교한다.
19. 얇음·과밀·반복은 전역 고정 할당량이 아니라 같은 역할·같은 장 안의 실제
    분포와 정본 기능을 기준으로 finding을 낸다.
20. finding마다 exact month/root와 다음 최소 수리 소유자를 적고, 사용자 표본을
    받을 3개 장면을 결정론적으로 뽑는다.

## 배치 A 실측 결과 (2026-08-31)

- `story_map`에 편성된 전체 작가용 표면은 176 refs, 현재 생명주기상 제품 연결
  가능 표면은 135 refs다. 후자의 root-ref 합계는 519 terminal path·476 choice·
  한국어 155,961자이고, 같은 immediate closure를 한 번만 세는 전역 합집합은
  411 choice·133,752자다. 이 수치는 실제 한 경로의 플레이 분량이 아니다.
- 파일이 없는 `NEW/planned` root는 16개, 원고는 있으나 제품 ingress가 없는
  `EXPAND/needs_rule` root는 25개다. 이 둘을 제품 분량에 합산하지 않는다.
- 서로 다른 달로 편성된 root를 앞 장면의 즉시 후속이 먼저 소비하는 edge는 8개다.
  강제 4, 시간 역전 1, 조건부 1, 선택 분기 2이며 현재 기준선 판정은 `HOLD`다.
- 경력·창업 Year 5 자료 32 roots·86 choices는 `reference_only`, runtime owner 없음,
  story map overlap 0이다. 본편 분량이나 도달 가능한 경로로 세지 않는다.
- `narrative_spine`의 제품 phase root 가운데 opening/prologue 4개와 chapter card
  4개를 제외해도 21개가 현재 story-map closure 밖에 있다. 이 중 Ch2 보스의
  `상철 거울 → 직업 천장 → 아버지 병실` raw follow-up은 직업·입원·생존 가드를
  우회하므로 단순 분량 공백보다 먼저 typed route로 재배선해야 한다.
- 정적 감사는 길이·문단·선택·표면 비트 수를 관찰할 뿐 재미나 상승을 승인하지
  않는다. 특히 현재 M07~M60 실제 노출은 `MainGame` 주차 라우터가 소유하므로,
  fresh title부터 W240까지의 실제 occurrence trace가 나오기 전에는 “제품 전체
  플레이 볼륨”이라는 표현을 쓰지 않는다.

구현은 `tools/full_game_volume_audit.py`와 exact baseline에 고정했다. baseline은
현재 49개 구조 debt를 이름까지 허용하되, 새 finding뿐 아니라 해결된 finding도
명시적 재발급 없이 통과시키지 않는다. 출력은 항상 `full_game_volume_status=HOLD`,
`runtime_trace=PENDING`, `human_density_gate=OPEN`을 함께 남긴다.

다음 자식 배치는 먼저 8개 cross-month edge의 같은 장면/독립 월/deferred 소유권을
확정하고, 별도 배치가 실제 `MainGame`·`StoryMode` fresh-title 런타임 trace를 만든다.
그 뒤에만 정상 경로의 빈 달과 후반 상승을 exact 원고 root로 보강한다.

### 월경계 소유권 판정

- **같은 장면 chain 5:** M08 `goshiwon_goodbye→housing_new_life`, M13
  `year_one_mark→money_attracts_money`, M33 `sangchul_confrontation`의 두 갈래,
  M49 `37_reckoning→final_year_start`. 앞달/앞 beat가 closure를 소유하고 다음
  월에는 재생이 아닌 실제 후속 beat가 필요하다.
- **독립 월 2:** M20 `doors_open→parents_visit` 즉시 연결과 M22
  `daeun_fork→father_medication` 시간 역전을 제거한다. 부모 방문과 약 장면은
  각자의 정상 주차·상태 guard가 소유한다.
- **조건부 미래 월 1:** M15 `father_medication→jiyeon_offer`는 즉시 후속을
  제거하고, M22에서 다은 경로가 불성립하며 지연 선행 사실이 있을 때만
  스케줄러가 선택한다.

이 8건만 고치면 충분하지 않다. 같은 raw `follow_up_event` 통로가 M14
`money_attracts_money→sangchul_03_network`의 상철 선행·자산 guard와 Ch2 보스
`sangchul_mirror→career_ceiling→father_04_visit`의 직업·입원·생존 guard도
우회한다. 다음 graph-contract 배치는 이 인접 P0를 같은 반례 집합으로 소유한다.
반대로 M23 부모 방문 뒤 나흘째 병원 전화는 한 장면의 authored time-cut이므로
삭제하지 않고 정상 ingress와 one-shot만 잠근다.

## 판정 규칙

- `story_map`에 이름만 있고 사건이 없거나, 제품 장면인데 terminal/선택 결과가
  없거나, 기억·결정을 쓰고 실제 미래 독자가 없으면 P0/P1이다.
- 장면 길이는 단독 합격 조건이 아니다. 짧은 장면은 bridge 기능과 다음 독자가,
  긴 장면은 서로 다른 비트 기능과 선택 압력이 있어야 한다.
- 중요한 장면이 서사상 필요하면 10비트를 넘을 수 있다. `10`은 목표치가 아니라
  기능 중복과 억지 늘리기를 잡기 위한 관찰점이다.
- 후반 장은 앞 장보다 무조건 길어야 하는 것이 아니라, 더 먼 선택을 동시에
  읽고 더 큰 포기·책임을 실제 행동으로 발생시켜야 한다.
- 자동 집계는 재미 GO가 아니다. 다음 표적 수리는 같은 exact 후보의 정상 속도
  사람 판정을 별도로 남긴다.

## 정확한 파일 소유권

**선언·GO 기록:** `docs/CODEX_QUEUE.md`, 이 사양, `CLAUDE.md`,
`docs/DECISIONS.md`, `docs/DEMO_FIXLOG.md`, `docs/human_gates.json`,
`docs/context_manifest.json`, 생성본 `docs/STATUS.md`,
`docs/queue_archive/ORDER-124.md`,
`docs/queue_archive/CODEX_QUEUE_2026-08.md`.

**배치 A 구현:** 신규 `tools/full_game_volume_audit.py`, 신규
`tools/full_game_volume_baseline.json`, `tools/audit_scope.json`.

**발견된 검사 수리:** `tools/chapter1_core_loop_v2_causal_ledger_check.py`의
  `StoryMode.gd` 전체 파일 스냅샷이 이미 적용된 공개 데모 저장 복구 변경보다 한
커밋 뒤처져 있었다. 제품 파일은 바꾸지 않고 현재 exact SHA-256으로 갱신한다.

**마감:** 이 사양, `CLAUDE.md`, `docs/WORK_LOG.md`, 생성본 `docs/STATUS.md`.

사건 원고·story map·rules·spine·런타임·저장은 배치 A에서 읽기만 한다. 실측이
잡은 결함 수리는 다음 15~25단위 자식 배치가 exact root 소유권을 선언한 뒤 한다.

## L1 / L2 / L3

- **L1:** 60개월·5장·모든 mapped root를 누락 없이 집계하고 self-test 14개가
  missing root, cycle/zero-terminal, KO/EN topology, cross-month 강제·시간 역전,
  write-only memory/decision/carryover, 관측 기준선 drift, 잘못된 chapter 상승과
  audit/제품 GO 혼동을 각각 거부한다.
- **L2:** raw JSON 표본과 도구 결과를 독립 재계산해 월·root·choice·reader·공백
  수치가 일치하고, 이미 닫힌 M01~M06 데모 신원을 바꾸지 않았음을 확인한다.
- **L3:** 각 다음 수리 배치의 무작위 3장면과 정상 속도 전체 경로가 밀도·애착·
  상승을 판정한다. 배치 A 숫자만으로 원고나 장을 GO 처리하지 않는다.
