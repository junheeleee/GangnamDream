# Archived Queue Spec: ORDER-139

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [x] ORDER-139 [P1·판정] 현재 스토리 데모의 선택 밀도와 위험 대가를 실측한다

**착수 선언 (2026-08-31 Codex):** 실행 기준은
`98be0db200f33f993bda1562b78eafa27031febd`다. 측정 대상은 현재 소스 HEAD가
아니라 사용자에게 발급된 active `story_demo_rc` exact
`16675f6ce310adb477da9ab3431c2edfe15ab278` / tree
`aed6904fc95345a867d2762f0bb8a62e65b32ce1`, BUILD `2026.08.25.1`이다.
제품 사건·런타임·번역 파일은 모두 읽기 전용으로 잠근다.

**완료 (2026-08-31 Codex):** active `story_demo_rc` exact source를 한 바이트도
바꾸지 않고 11 runtime variant·24 choice option과 합법 경로를 전수 측정했다.
clean 360 + fallout 720 = 1,080개 고유 signature가 모두 6회 정산을 통과했고,
종료 최저치는 몸 61·마음 15·현금 632만원이다. 각 런은 선택 영수증 9개를 남긴다.

기존 자동 선택기는 24개 중 17개만 실제 선택하며 7개가 비어 있다. M6 고정 산문은
M3~M5의 exact 인물 선택을 읽지 않고, M2 환수 callback은 M6 진입 전에 due가 되지만
데모 끝까지 소비되지 않는다. M6 다섯 선택도 recap 외 후속 이야기 독자가 없다.
clean 경로의 위험 제안은 M1 한 번뿐이고, fallout 심화는 환수보다 현금·몸·마음
수치가 모두 더 유리한데 이후 세계 반응이 없다. 비-bridge 21개 중 6개는 함께 할 수 없는
사람·생계·몸·돈 대안을 명시하지 않으며, 보이는 세 수치를 바꾸는 선택은 18/24인데
exact demo-reachable 이야기 독자를 가진 선택은 6개다.

측정기 구현은 `a4d3271`이다. source commit/tree/BUILD와 8개 Git blob을 코드·fixture·
실제 SHA/OID로 이중 고정하고, 24개 축 분류와 실제 영수증·follow-up true branch,
selector caller reachability, working-tree fallback 거부를 44개 변이 검사로 잠갔다.
독립 반례 검토 결과 P0/P1/P2는 0이다. 이 결과는 구조 결함의 수리 입력이며
`human_route_density`와 `human_fun`은 계속 `not_measured`, 사람 게이트는 OPEN이다.

**사용자 근거:** 사용자는 게임의 가장 중요한 점을 처음부터 끝까지 허술하지
않은 밀도로 정했고, 토큰이 남는 동안 사람 판정과 독립적인 큐 작업을 계속하라고
지시했다. `ORDER-58` 부모의 축·유혹 추정은 폐기된 월간 행동판을 전제로 하므로
그 수치를 그대로 집행하지 않는다. 현재 StoryMode 선택판의 실물을 먼저 잰다.

## 깊이 3문

1. 이 측정을 빼면 M01~M06이 장면 수만 많은지, 실제 행동·포기·후속이 빽빽한지
   구분하지 못한 채 사람 플레이에 모든 진단을 떠넘긴다.
2. 옛 AP·commitment 비율을 다시 쓰면 반려된 시스템을 완성도 증거로 부활시킨다.
   현재 9장면 런의 실제 선택·정확한 영수증·소비자만 입력으로 쓴다.
3. 같은 오더에서 원고까지 고치면 측정 기준과 수리 결과가 섞인다. 이번 자식은
   결함을 exact 사건·달·선택으로 증명하되 제품 수리는 다음 최소 자식으로 분리한다.

## 한 배치 20단위

1. active 후보 commit/tree/BUILD를 검증한다.
2. 대상 JSON과 controller를 `git show <source_ref>:<path>`로 읽는다.
3. M01 root와 두 선택을 고정한다.
4. M02 clean/fallout 분기를 `lent_account` 생산자와 연결한다.
5. M03의 두 연속 장면을 별도 선택 소유자로 센다.
6. M04 meet→measure/coffee→answer 순서를 exact receipt로 잇는다.
7. M05 재혁 장면을 고정한다.
8. M06 runtime clone의 source choice 3..7과 제거 필드를 검증한다.
9. clean/fallout 각 런의 장면 수와 choice option 수를 센다.
10. 합법 완주 signature를 전수 열거한다.
11. 단일 선택 bridge를 의미 결정 수에서 분리한다.
12. 표현·기억·결정·bridge 분류를 모든 root에 붙인다.
13. 사람·생계·몸·돈 행동축을 각 의미 선택에 명시한다.
14. 즉시 비용과 함께 할 수 없는 대안을 별도 필드로 기록한다.
15. 위험 제안·수락·청구·재유혹·심화의 도달 횟수를 경로별로 센다.
16. 선택 receipt 생산자와 demo 안 소비자를 연결한다.
17. demo 밖 deferred consumer는 별도로 표시하고 도달로 오인하지 않는다.
18. 미분류 선택·중복 receipt·끊긴 consumer를 실패시키는 self-test를 만든다.
19. 기계 판독 JSON 요약과 사람이 읽을 결함 목록을 같은 실행에서 출력한다.
20. 표적 검사·전체 감사·diff를 통과시키고 측정값만 기록한다.

## 측정 계약

- 합법 경로는 M01 선택, M02 route/선택, M03 두 선택, M04 root/answer,
  M05 선택, M06 선택의 조합으로 정의한다. 강제 단일 선택은 경로 영수증에는
  남기되 플레이어의 의미 결정으로 세지 않는다.
- `mode`는 `decision`, `memory`, `expression`, `bridge` 네 값이다. 축은
  `people`, `livelihood`, `body`, `money`만 쓰고, 분류 근거가 애매하면 억지로
  축을 붙이지 않고 `unclassified`로 실패시킨다.
- 위험은 태그 개수가 아니라 실제 도달 장면으로 센다. M01 수락의 M02 청구,
  M02의 재유혹, 심화 뒤 M06까지의 추가 세계 반응을 서로 다른 값으로 출력한다.
- 모든 선택은 runtime receipt ID와 controller session/recap 소비 여부를 가진다.
  M4 분기와 M2 deferred callback처럼 이름 있는 추가 독자는 별도 열에 둔다.
- 구조·분류 완전성은 L1 게이트다. 재미·체감·정상 독해 밀도는 숫자로 GO 처리하지
  않고 `human_route_density=not_measured`를 유지한다.

## 정확한 파일 소유권

**선언·마감:** `docs/CODEX_QUEUE.md`, 이 사양, `CLAUDE.md`,
`docs/WORK_LOG.md`, `docs/history/WORK_LOG_2026-08-20.md`,
`docs/queue_archive/CODEX_QUEUE_2026-08.md`, 생성본 `docs/STATUS.md`.

**신규 측정기·계약:** `tools/story_demo_density_audit.py`,
`tools/fixtures/story_demo_density_contract.json`.

**회귀 등록:** `tools/audit.sh`, `tools/audit_scope.json`.

위에 적지 않은 제품·원고·번역·런타임·패키지·사람 게이트 파일은 수정하지 않는다.
특히 `project.godot`, `content/events*`, `playtests/order124/*`, `scenes/*`,
`autoloads/*`, `systems/*`, `docs/human_gates.json`은 읽기 전용이다.

## 완료 증거

```bash
python3 tools/story_demo_density_audit.py --self-test
python3 tools/story_demo_density_audit.py
python3 tools/story_demo_density_audit.py --json
python3 tools/audit.py
GODOT=/Users/junheelee/Downloads/Godot.app/Contents/MacOS/Godot ./tools/audit.sh
git diff --check
```

- 출력은 source commit/tree, root/choice/receipt/route 수, 경로별 결정·bridge 수,
  축·비용·위험·consumer coverage와 exact 결함 ID를 포함한다.
- current HEAD와 active 후보가 다르면 둘을 섞지 않고 drift를 별도 출력한다.
- 결함이 없어도 제품 파일을 편의상 수정하지 않는다. 결함이 있으면 다음 자식의
  최소 수리 입력으로만 넘긴다.
- Godot 4.6.2 전체 감사는 `✅ 감사 통과`로 종료했고 미설정·실패
  플래그는 0이다. `STORY_DEMO_DENSITY_AUDIT_SELF_TEST_OK cases=44`,
  `STORY_DEMO_DENSITY_AUDIT_OK ... signatures=1080 clean=360 fallout=720`,
  `COMPILE_CHECK_OK total=68`을 같은 실행에서 확인했다.

## 규범 판정

이 사양의 source ref, 분류표, 명령, 측정 임계는 모두 일회성 판정 지시다. 새 제품
규칙을 만들지 않으므로 정본 승격 대상이 없다.
