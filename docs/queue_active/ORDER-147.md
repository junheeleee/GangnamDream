# Active Queue Spec: ORDER-147

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-147 [P0·runtime proof integrity] 입력 신원 경합과 화면 타이머 수명을 봉인한다

**[~] 2026-08-31 Codex 착수 · 문서 기준선
`6f346d60994f17c243ee8252f27539becc188411` · 검사 제품
`6ae555f905c95f36424475b0c6da82e100cc97a1`:** 세 profile W1→W240 exact
matrix에서 제품 밸런스와 무관한 입력 초점 경합, 합법 선택을 고르지 못한 일반
profile, MainGame 장면 교체 뒤 남는 두 SceneTreeTimer를 각각 재현했다. 이 사양과
큐 인덱스만 선언 커밋으로 먼저 고정하고, 제품·검사 변경은 별도 커밋으로 검증한다.

공개 출시 데모는 사용자가 GO한 exact `story_demo_rc` M01~M06이며 이 작업으로
범위를 넓히거나 내용을 바꾸지 않는다. 본편·Chapter 5 사람 게이트는 HOLD/open이다.

## 깊이 3문

1. **투자 경로가 5,769만원이면 경제 수치를 먼저 올릴 것인가?** 아니다. 추적기가
   화면의 `study`를 기록했지만 MainGame의 deferred focus가 Enter 직전 첫 카드
   `resume`으로 초점을 되가져갔다. 선택 신원을 봉인한 clean 재실행 전의 자산값은
   밸런스 증거가 아니다.
2. **W13에서 선택 0이 숨겨졌으면 사건을 열어 줄 것인가?** 아니다. 현금이 음수일
   때 지분 비용 선택을 숨기는 제품 규칙은 맞고, 같은 장면의 작성된 무비용 선택 1을
   profile이 직접 골라야 한다. 자동 첫-visible 폴백은 만들지 않는다.
3. **종료 전에 2초 더 기다리면 누수가 닫히는가?** 아니다. MainGame을 떠난 뒤
   suspended coroutine이 SceneTreeTimer 참조를 붙든다. 화면 소유 child Timer와
   동기 상태 기계로 바꾸고 장면 해제 시 transient 상태까지 정리해야 한다.

## 18단위 구현·검증

1. MainGame의 milestone·critical 지연을 소유 child one-shot Timer로 바꾼다.
2. milestone은 오름차순 첫 미도달 하나만 표시하고 timeout 뒤 다음 것을 이어 간다.
3. active 중 반복 refresh는 같은 milestone 로그·소리·상태를 중복 생성하지 않는다.
4. 반복 critical은 같은 Timer를 재시작해 마지막 발생 뒤 1.2초를 보장한다.
5. MainGame 해제 시 두 Timer와 transient portrait flags를 정리한다.
6. milestone 함수의 자유 SceneTreeTimer·await 재도입을 정적 검사로 막는다.
7. trace 버튼 입력은 deferred focus가 끝난 뒤 목표 버튼의 초점을 안정화한다.
8. 실제 `InputEventKey` Enter를 유지하고 signal 직접 발행이나 제품 함수 호출은 금지한다.
9. 목표 초점을 제한 횟수 안에 유지하지 못하면 즉시 실패한다.
10. 화면 선택 action, pending action, finalized commitment choice가 다르면 즉시 실패한다.
11. JSONL의 모든 main action은 visible/action/commitment 세 신원이 exact로 같다.
12. selected/finalized mismatch 변조 fixture가 감사를 실패시킨다.
13. 투자 초기 신원 검사는 화면의 세 investment evidence와 첫 매수를 실제 영수증으로 읽는다.
14. 투자 실현 전 다른 경로가 없고 실현 뒤 invest-only가 보존됨을 검사한다.
15. 일반 profile W13은 `cafe_cb_honest_in`의 작성된 choice 1을 exact override한다.
16. general profile override가 빠지거나 바뀌는 인접 변조를 감사가 거부한다.
17. runner의 ObjectDB/resource leak fail-closed는 그대로 두고 우회 대기를 제거한다.
18. clean exact candidate에서 세 profile을 모두 W240까지 다시 실행·감사한다.

## 반드시 보존할 경계

- exact `story_demo_rc` M01~M06 사용자 GO와 공개 데모 제품 바이트를 바꾸지 않는다.
- first-year 30억 `instant_legend` 이스터에그를 유지한다.
- 월간 AP/행동판을 새로 만들지 않는다.
- 실제 선택 전 주차·현금·경로·사건·플래그를 trace가 주입하지 않는다.
- 제품의 save/study 경제 효과와 route 문턱을 검사 오염 근거로 조정하지 않는다.
- runner의 엔진 오류·ObjectDB/resource leak 차단을 완화하거나 whitelist하지 않는다.
- `project.godot`은 변경하지 않는다.
- 자동·정적 GREEN은 사람 GO가 아니다. `product_go=HOLD`, Chapter 5 두 사람
  게이트 `open`을 유지한다.

## 정확한 파일 소유권

`scenes/MainGame.gd`,
`tools/{FullGameRuntimeTrace,ImmersionLoopCheck}.gd`, `tools/audit.sh`,
`tools/full_game_runtime_trace_profiles.json`,
`tools/full_game_runtime_trace_audit.py`와 이 사양·큐 인덱스만 소유한다.

`tools/run_full_game_runtime_trace.sh`는 read-only이며 기존 leak fail-closed를
그대로 쓴다. 사건 원고·story map·GameState·StoryMode·밸런스·저장 schema·
`project.godot`은 읽기만 한다. `tools/project_dashboard.py`의 ORDER-146 변경은
별도 미완료 작업으로 보존하고 이 제품 커밋에 섞지 않는다.

### 2026-08-31 전체 감사 보충 소유권

최초 선언 뒤 exact `6ae555f`와 현재 작업 트리에서 전체 감사를 실행해, 이번
MainGame 바이트 전이를 아직 모르는 보호 검사 둘과 직전 제품부터 남아 있던 생성
목록·검사 기준선 세 건을 재현했다. JSON 정본 원장을 덮어쓰거나 기존 승인 전이를
바꾸지 않고, 다음 파일만 가산 전이·현재 inventory·생성 결과에 맞춘다.

- `tools/year5_reference_route_audit.py`: `6ae555f`의 MainGame blob에서 이번
  MainGame blob으로 이어지는 exact 가산 전이를 추가한다.
- `tools/chapter1_core_loop_v2_causal_ledger_check.py`: 의미 원장은 그대로 두고
  감사 대상 MainGame source snapshot만 현재 exact hash로 갱신한다.
- `tools/ja_translation_pipeline.py`, `docs/{I18N_INFRASTRUCTURE,I18N_GLOSSARY_JA}.md`:
  이미 사전에 존재하는 합법 `_tr` 여섯 호출을 반영한 3,326/3,292 호출·2,822
  legacy key 기준선으로 맞춘다. 번역 본문이나 출시 언어 범위는 바꾸지 않는다.
- `assets/scene_direction_manifest.json`: 이미 제품에 존재하는 3년차 아버지 장면
  `arc_y3_father_avoidance_document`, `arc_y3_father_deferred_call` 두 건만 생성
  목록에 편입한다.
- `tools/YearIdentityCheck.gd`, `docs/BALANCE.md`: 의도적으로 W49~72로 좁힌 IPO
  입구와 W73~96 상철 후속 구간을 하나의 W49~96 사건으로 오판한 구 검사·설명을
  실제 property ladder의 두 구간 계약에 맞춘다. 경제 수치와 사건 데이터는 바꾸지
  않는다.

`content/meta/{year5_reference_routes,chapter1_core_loop_v2_causal_ledger}.json`은
기존 의미 정본이므로 계속 read-only다. 위 보충은 공개 M01~M06 데모의 내용·범위,
Chapter 5 HOLD, 사람 실플레이 요구를 바꾸지 않는다. `tools/project_dashboard.py`와
`docs/STATUS.md`는 clean 세-profile matrix가 끝난 뒤 exact wrapper에서만 정리한다.

### 2026-08-31 첫 exact 실행 반려 · `0924d279`

`0924d279edf6f95cb85ea79bc584e21f90f4c570`은 W1 TutorialOverlay가 매 frame
초점을 회수해 뒤 카드 입력이 fail-closed했으므로 전부 반려했다. 실제 overlay 버튼을
raw Enter로 먼저 끝낸 뒤 동일한 visible action Button의 초점을 확인하도록 수리했다.
signal 직접 발행·제품 함수 호출·첫-visible 폴백·action id 재탐색은 계속 금지한다.

### 2026-09-01 두 번째 exact 행렬 반려 · `e5c2ae0b`

baseline은 clean 완주했지만 property는 W82 잘못된 기본 선택으로 문턱을 잃었고,
general은 W112 실패 뒤 W188 `mental_break`로 끝났다. 작성돼 있던 경로 일관 선택만
exact override하고 실제 W160→W189 순서와 W132 상철 수용을 profile에 고정했다.
경제·확률·seed·상태·자산 상하한은 바꾸지 않았으며 모든 `e5c2ae0b` trace는 반려다.

### 2026-09-01 세 번째 exact property 실행 반려 · `0babcbb4`

28.21억원·property 전 연쇄는 완주했지만 감사가 화면에 없던 W24 이전 투자 매수를
요구해 반려했다. M06 세 투자 공부와 invest-only 잠금은 유지하고, Chapter 1에서
투자 카드가 처음 보인 W35 즉시 매수를 exact 영수증으로 요구하도록 계약만 바로잡았다.

### 2026-09-01 일반 경로 exact 복구 · `d8037afe`

옛 focus 검사의 seed 값은 폐기했다. exact 신원 계약에서 seed `2026083102`와 작성된
거절·피해자 합류 선택, 목표 자산대 Rest→Save 안전 순서만 고정해 W1→W240·29.388억원·
`investment_master`·`father_passed=true`·clean teardown을 재현했다. 제품 수치·확률·
사건은 바꾸지 않았고 profile 변조는 self-test가 거부한다.

### 2026-09-01 exact property 종료 경합 재현 · `9cb7ab78`

fresh-title 3-profile 행렬에서 baseline과 general은 clean 종료했지만
property는 W1→W240·1,678 record·268 story occurrence·`with_daeun`·
28.21억원의 동일한 합법 trace를 완주하고도 종료 직후 ObjectDB/resource
leak를 남겼다. 이 trace는 계약대로 즉시 반려하고 matrix를 PENDING으로
유지한다.

`--verbose` exact 재실행은 남은 자원 5개를 `sfx_click.wav`,
`sfx_open_modal.wav`, `sfx_ending_stinger_good.wav`, `bgm_reckoning.ogg`,
`bgm_victory.ogg`의 재생 객체로 특정했다. 장면·텍스처·SceneTreeTimer
누수가 아니다. Godot 4.6은 `AudioStreamPlayer.stop()`에서 재생 객체를
즉시 해제하지 않고 다음 AudioServer mix에서 제거하므로, 두 process frame이
실제 mix보다 먼저 끝나면 clean과 leak가 같은 trace에서 경합한다.

runner의 leak fail-closed나 오류 탐지를 완화하지 않는다. 대신 모든 player를
정지·detach한 뒤 `get_time_since_last_mix()`를 먼저, `get_time_to_next_mix()`를
나중에 읽어 현재 phase와 한 mix 주기를 계산한다. 두 호출 사이에 경계가 와도
대기 시간이 축소되지 않는 보수적 순서다. 새 playback의 stop 반영과 제거가
서로 다른 경계에서 일어나는 Dummy probe를 따라, trace node가 소유한
one-shot child Timer로 **두 mix 경계**를 넘는다. 자유
SceneTreeTimer·2초 대기·경고 whitelist는 계속 금지하며, exact 계측·Timer
소유·수치·데이터 흐름·실제 `start(drain_seconds)` 계산 블록 전체의 변조를
self-test가 거부한다. ImmersionLoop는 실제 누수에 남았던 WAV 3개와 OGG 2개를
각각 새 playback으로 재현하고, 독립 프로세스 12회 모두에서 strict ObjectDB
종료 감지를 통과해야 한다. 수리한 새 exact
candidate에서 세 profile W1→W240을 모두 처음부터 다시 실행한다.

## L1 / L2 / L3

- **L1:** trace/profile contract와 mutation self-test가 초점 신원 오염, W13 선택
  drift, 자유 milestone timer 재도입을 거부한다.
- **L2:** Timer 수명 fixture와 clean 세-profile W1→W240 exact matrix가 실제 입력,
  invest-only 경로, ending, teardown leak 0을 증명한다.
- **L3:** 새 exact candidate의 property와
  `general_near_goal_father_passed` M49~M60 정상 속도 사람 실플레이가 판정한다.
  그전까지 본편은 HOLD다.

## 2026-09-01 exact 검증 결과

- 검사 제품은 `83d3f350de0900ce050277d6da1331940d1872a3`, tree
  `97f81c70c11452ef851b4cb0646c5e557544fd93`다. 공개 M01~M06
  `story_demo_rc` 제품 바이트는 바뀌지 않았다.
- baseline/property/general 세 fresh-title profile이 실제 화면 입력과 exact
  action/commitment 신원으로 W1→W240을 끝까지 완주했다. accepted matrix root의
  aggregate marker는 `FULL_GAME_RUNTIME_TRACE_MATRIX_OK profiles=3
  product_go=HOLD human_density_gate=OPEN`이다.
- 오디오 3 WAV+2 OGG teardown stress는 독립 프로세스 12/12 strict 종료를
  통과했다. import 후 전체 감사 로그 SHA-256은
  `6b30e4b7ccbb294f41b3caf51b960b5380967a80b9abd3853430d25f74cb70fb`이고
  최종 표시는 `✅ 감사 통과`다.
- 과거 검사기의 기본 종료 모드에서 남는 네 legacy teardown 경고는 strict 12회
  lane이 소유하지 않으며 숨기거나 사람 판정으로 올리지 않는다. 자동·정적 GREEN은
  재미나 본편 GO가 아니다. 현재 matrix는 GREEN, Chapter 5 L3 두 경로는 OPEN,
  full·main·product는 HOLD다.
