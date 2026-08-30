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

**마감:** 이 사양, `CLAUDE.md`, `docs/WORK_LOG.md`, 생성본 `docs/STATUS.md`.

사건 원고·story map·rules·spine·런타임·저장은 배치 A에서 읽기만 한다. 실측이
잡은 결함 수리는 다음 15~25단위 자식 배치가 exact root 소유권을 선언한 뒤 한다.

## L1 / L2 / L3

- **L1:** 60개월·5장·모든 mapped root를 누락 없이 집계하고 self-test 반례가
  missing root, zero-terminal, write-only decision, 잘못된 chapter 상승을 각각
  거부한다.
- **L2:** raw JSON 표본과 도구 결과를 독립 재계산해 월·root·choice·reader·공백
  수치가 일치하고, 이미 닫힌 M01~M06 데모 신원을 바꾸지 않았음을 확인한다.
- **L3:** 각 다음 수리 배치의 무작위 3장면과 정상 속도 전체 경로가 밀도·애착·
  상승을 판정한다. 배치 A 숫자만으로 원고나 장을 GO 처리하지 않는다.
