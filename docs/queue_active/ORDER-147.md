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
`tools/{FullGameRuntimeTrace,ImmersionLoopCheck}.gd`,
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

clean detached 후보 `0924d279edf6f95cb85ea79bc584e21f90f4c570`의 첫 profile은
W1에서 `side_shift` 카드가 정확한 키보드 포커스를 유지하지 못해 fail-closed했다.
수치·사건·경로 판정 전 실패이며 이 commit/tree의 trace는 후보 증거로 쓰지 않는다.

후속 W1 진단에서 원인을 더 좁혔다. 첫 주에는 전면 `TutorialOverlay`가 살아 있고
그 `_process()`가 매 frame 실제 다음 버튼으로 초점을 회수한다. 뒤쪽 행동 카드는
`visible_in_tree`여도 플레이어가 누를 수 있는 표면이 아니다. 따라서 기존 소유 파일
`tools/FullGameRuntimeTrace.gd`와 `tools/full_game_runtime_trace_audit.py` 안에서만,
활성 튜토리얼의 실제 enabled 버튼을 카드보다 먼저 raw Enter press/release로
진행하고 오버레이가 존재하는 동안은 버튼의 일시 disabled 여부와 무관하게 카드로
내려가지 않도록 입력 장벽을 수리한다. 오버레이가 끝난 뒤 행동 카드는 기존처럼
deferred 기본 포커스를 비우고 **동일한 실제 Button**에 raw Enter가 도달해야 한다.
`pressed.emit`, 제품 함수 직접 호출, 첫-visible 행동 폴백, action id 재탐색은 계속
금지한다. 분기 삭제·카드 뒤 이동·무조건 반환 약화를 변조 fixture가 거부하고, 실제
W1 프로브 뒤 새 제품 commit/tree에서 세 profile W1→W240을 처음부터 다시 실행한다.

### 2026-09-01 두 번째 exact 행렬 반려 · `e5c2ae0b`

같은 후보의 `baseline_safe_people`은 W1→W240·1,588 record·244 story
occurrence·`with_daeun` ending과 clean teardown을 통과했다. 그러나
`investment_property_daeun`은 W82 `arc_opp_sangchul_realty`에서 설계 기준인
작성 선택 1이 아니라 profile 기본 선택 0을 사용해 손실을 냈다. 그 결과 W112~143의
8천만원 문턱을 열지 못했고, 필수 연쇄 8/22·최종 자산 85,139,391원으로 fail-closed했다.
경제 수치·확률·seed·상태를 바꾸지 않고 property ladder 정본과 같은 작성 선택 1을
exact override로 고정하며, 누락·index 0·timed 변조를 profile audit가 거부한다.

이 실패 뒤 비영 종료에서 ObjectDB 5 resource leak도 재현됐다. 성공 표식으로
덮지 않고 마지막 제품 장면의 audio stream과 active scene을 모두 해제한 뒤 종료해,
실패는 깨끗한 profile 실패로 남긴다. 독립 정적 검토가 찾은 tutorial 전 입력 우회,
재귀 탐색 무력화, exact focus 확인 제거도 모두 새 변조 fixture로 차단한다. 이 후보의
행렬은 증거로 쓰지 않고 새 제품 commit/tree에서 세 profile을 다시 처음부터 실행한다.

같은 행렬의 `general_near_goal_father_passed`는 W112 재개발 실패 뒤 7.49억원에
머물렀고, W188 빈 병실의 정신력 하락으로 `mental_break`가 나서 필수 연쇄 2/10에서
끝났다. 기본 index 0이 고른 3년차 후반의 단절·과로 선택 여섯 건도 이 프로필의
사람/아버지 정체성과 반대로 누적됐다. 수치를 주입하지 않고 이미 작성된 절제·회복
선택만 exact override로 고정하며, 누락·다른 index·timed 변조를 거부한다. 25억
진입은 합법적인 투자 선택과 seed의 실제 결과로만 증명하고 자산 상·하한은 완화하지
않는다.

후속 property 진단은 W82 선택 1로 손실을 작게 제한해 W141 재개발 진입·승인과
W189 26억원 매각까지 실제로 열었지만, 기존 필수 순서가 W160 민서를 W189 매각
뒤에 잘못 적어 성공 런도 10/22에서 멈췄다. 또한 W132 상철 결산의 기본 신고 선택이
M49 네 사람 진입에 필요한 상철 관계를 닫았다. 필수 순서를 실제 주차 순서로 고치고,
작성된 상철 수용 선택 1을 고정한다. 이는 장면·경제·확률 변경이 아니라 화면에 있는
합법 선택을 해당 경로가 일관되게 수행하도록 하는 profile 수리다.

### 2026-09-01 세 번째 exact property 실행 반려 · `0babcbb4`

clean exact 런은 W1→W240·268 story occurrence·`with_daeun` ending과 목표 자산
28.21억원, Chapter 5 property 전 연쇄를 런타임 자체에서 통과했다. 다만 사후
감사가 첫 일반 투자 매수 W35를 M06 뒤라고 거부했다. 같은 trace에서 투자 정체성은
작성된 투자 공부 세 번으로 W8에 이미 invest-only로 잠겼고, W9·W16·W20·W23의
화면에는 투자 카드가 한 번도 없으며 첫 실제 투자 카드가 W35에 나타나자 즉시
매수했다. M01~M06 출시 데모를 바꾸거나 화면에 없는 매수를 만들 수 없으므로 이
실행도 후보 증거로 쓰지 않는다.

정적 계약은 M06 안의 세 투자 공부와 invest-only 잠금을 그대로 요구하되, 첫
일반 매수는 Chapter 1 W48 안에서 실제 투자 카드가 처음 보인 주에 수행하도록
고친다. 세 번째 공부 뒤 매수 전까지 투자 카드가 한 번이라도 보였는데 건너뛴
trace는 실패하고, W49 이후 첫 매수도 실패한다. 이 수리는 제품 편성·경제·사건을
바꾸지 않고 감사가 현재 story-first 화면에서 할 수 없는 행동을 요구하던 모순만
제거한다.

## L1 / L2 / L3

- **L1:** trace/profile contract와 mutation self-test가 초점 신원 오염, W13 선택
  drift, 자유 milestone timer 재도입을 거부한다.
- **L2:** Timer 수명 fixture와 clean 세-profile W1→W240 exact matrix가 실제 입력,
  invest-only 경로, ending, teardown leak 0을 증명한다.
- **L3:** 새 exact candidate의 property와
  `general_near_goal_father_passed` M49~M60 정상 속도 사람 실플레이가 판정한다.
  그전까지 본편은 HOLD다.
