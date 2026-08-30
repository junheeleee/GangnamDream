# Active Queue Spec: ORDER-140

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [ ] ORDER-140 [P0·거절 불가 비트의 치명성] 아버지 별세가 런을 끝내지 않게 하고, 선택지 없는 비트가 죽이지 못하게 막는다

**[ ] 미착수 · 입력은 1~5장 전 구간 재생 뒤 표적 프로브(2026-08-29):**
W188 아버지 별세의 마지막 비트는 선택지가 하나뿐인데 `mental -40`을 적용한다.
mental 40 이하로 그 주에 도달한 플레이어는 **거절할 수 없는 예정 장면 때문에**
`mental_break`으로 런이 끝난다. 이 오더는 그 한 가지 버그 클래스만 소유하며
아버지 별세의 서사·사실·감정 비용은 줄이지 않는다.

## 판정 증거

실제 4장 세이브(slot 9, W145)를 불러 W188로 세우고 `arc_father_passing` →
`arc_father_passing_platform` → `arc_father_passing_hospital_room` 체인을
실제 `GameState.apply_choice`로 실행했다.

| 시작 mental | 마지막 비트 뒤 | 결과 |
|---:|---:|---|
| 95 | 55 | 생존 |
| 72 | 32 | 생존 |
| 45 | 5 | 생존 |
| **40** | **0** | **GAME OVER** |
| 35 | 0 | GAME OVER |
| 25 | 0 | GAME OVER |

- 죽이는 비트 `arc_father_passing_hospital_room`의 선택지는 `빈 침대 옆에
  앉는다.` **하나뿐이다.** 플레이어에게 대안이 없다.
- `mental`은 `clampi(…, 0, 100)`이므로 -40은 40 이하에서 정확히 0을 만든다.
- 실제 흐름에서도 종료된다. `StoryMode._story_has_pending_fatal_state()`가
  `mental <= 0`을 확인해 **남은 authored follow-up을 끊고** `_finish_all()`로
  넘기며, `MainGame`이 `GameState.check_game_over()`를 호출해
  `finish_run("mental_break")`이 실행된다.
- 발생 시점은 W188이다. 마지막 해가 시작되기 4주 전이고, 회복 구간이 없다.
- 참고로 레퍼런스 런의 mental은 W145에서 72, W193에서 95다. 즉 순탄한 런은
  걸리지 않는다. 걸리는 것은 이미 힘든 런이며, 그 런이 받는 판정은 "번아웃"이다.

**같은 버그 클래스 전수 조사 결과는 11건이고, 치명 사거리(≥25)는 2건이다.**

| 이벤트 | 효과 | 생존 최소치 | 파일 |
|---|---:|---:|---|
| `arc_father_passing_hospital_room` | `mental -40` | 41 | `arc_drama.json` |
| `arc_father_passing_deal_morning` | `mental -25` | 26 | `arc_drama.json` |

나머지 9건은 -18 이하이며 별도 조치 대상이 아니다. 다만 신규 검사가 이 9건도
같은 규칙으로 계속 감시한다.

## 깊이 3문

1. **이걸 지우면 무엇이 깨지는가?** 아무것도 깨지지 않는다. 오히려 지금은
   게임의 가장 중요한 장면이 그 장면을 가장 무겁게 받을 플레이어에게서
   먼저 끊긴다. 슬픔의 대가가 서사가 아니라 실패 판정이 된다.
2. **고른 플레이어와 안 고른 플레이어가 뒤에 다른가?** 이 비트에는 고름이
   없다. 그래서 문제다. 대가는 남기되 그 대가가 런을 끝내는 판정으로
   바뀌지 않아야 하며, 끝낼 것이라면 플레이어가 그 위험을 미리 볼 수 있어야 한다.
3. **같은 자리에서 무엇과 경쟁하는가?** `check_game_over()`의 즉시 실패 5종과
   경쟁한다. 그 순서와 임계값은 이 오더가 바꾸지 않는다. 바꾸는 것은 거절할 수
   없는 비트가 그 임계를 **혼자서** 넘기게 두지 않는다는 계약뿐이다.

## 배치 A — 제품

1. 선택지가 하나뿐인 authored 비트는 그 비트 단독으로 `mental`·`health`를
   치명 임계 아래로 내리지 못한다. 계약을 런타임 한 곳이 소유하게 하고
   개별 이벤트 JSON에 흩지 않는다.
2. 아버지 별세의 `mental -40`은 **줄이지 않는다.** 대가는 그대로 두고,
   거절 불가 비트가 마지막 1점을 가져가지 못하게 하는 방식으로 해결한다.
   바닥 처리·분할 적용·후속 회복 비트 중 어느 것을 쓸지는 구현이 정하되
   선택한 방식을 사양에 근거와 함께 남긴다.
3. 이 보호가 플레이어가 **직접 고른** 치명적 선택에는 적용되지 않는다.
   `drama_crypto_result_big`처럼 스스로 고른 파멸은 지금처럼 끝낼 수 있어야 한다.
4. `arc_father_passing_deal_morning`도 같은 규칙으로 정렬한다.
5. 아버지 별세 체인의 원고·플래그·`father_passed` 단조성·follow-up 순서는
   바꾸지 않는다. `tried_to_go_to_father`와 `arc_father_passing_seen`을 보존한다.
6. KO/EN을 같은 커밋에서 맞춘다.

## 배치 B — 증거

1. slot 9 기반 W188 체인을 시작 mental 25·35·40·45·55·72·95에서 실행해
   **모든 값에서 런이 계속됨**을 증명한다. 25에서도 종료되지 않아야 한다.
2. 같은 실행에서 `father_passed`·`arc_father_passing_seen`·
   `tried_to_go_to_father`가 모두 기록되고 follow-up 체인이 끊기지 않음을
   확인한다. 현재는 `_story_has_pending_fatal_state()`가 체인을 끊는다.
3. 플레이어가 직접 고른 치명 선택(`drama_crypto_result_big[1]`, health/mental
   즉시 실패 5종)이 여전히 런을 끝냄을 회귀로 증명한다.
4. **신규 정적 검사:** 선택지가 하나뿐인 authored 이벤트의 `mental`·`health`
   음수 효과가 치명 임계를 단독으로 넘기지 못함을 전수 확인한다. 현재 위반
   2건이며 수리 뒤 0이어야 한다. `tools/audit.py`에 넣어 회귀를 막는다.
5. `GameState.check_game_over()`의 즉시 실패 5종 순서와 임계값이 byte-exact로
   보존됨을 증명한다.
6. 전체 `tools/audit.sh`와 `python3 tools/en_coverage_check.py`가 GREEN이다.

## 정확한 파일 소유권

**런타임:** `autoloads/GameState.gd`(효과 적용 경로),
`scenes/StoryMode.gd`(`_story_has_pending_fatal_state` 인접부는 계약이
증명될 때만 최소 수정).

**KO/EN 사건:** `content/events{,_en}/arc_drama.json`.

**검사:** `tools/audit.py`, `tools/audit.sh`.

**선언·마감:** `docs/CODEX_QUEUE.md`, 이 사양, `CLAUDE.md`,
`docs/DEMO_FIXLOG.md`, `docs/WORK_LOG.md`, 생성본 `docs/STATUS.md`.

`project.godot`, 밸런스 밴드, `check_game_over()`의 임계값과 즉시 실패 순서,
`instant_legend` 라우팅, 아버지 별세 원고는 수정하지 않는다.

## 완료 판정

- **L1 기계:** 신규 정적 검사 위반 0, W188 체인 7개 mental 값 전부 생존,
  자발적 치명 선택 회귀 0, 즉시 실패 순서 보존.
- **L2 자자:** 시작 mental별 결과 표와 체인 완주 로그를 남긴다.
- **L3 사람:** mental이 낮은 상태로 W188에 도달한 런에서 아버지 별세 장면을
  정상 속도로 끝까지 보고, 그 장면이 실패 판정이 아니라 장면으로 읽히는지
  판정한다.

## 정본 승격 예정

- 계속 유효한 규칙: "거절할 수 없는 authored 비트는 단독으로 런을 끝내지
  않는다. 런을 끝내는 것은 플레이어가 고른 선택이거나 누적된 상태다"를
  `docs/BALANCE.md`와 `docs/CHOICE_CONSEQUENCE_SYSTEM.md`에 승격 판정한다.
- 일회성: 현재 위반 2건의 ID와 수치, slot 9 기반 프로브 절차.
