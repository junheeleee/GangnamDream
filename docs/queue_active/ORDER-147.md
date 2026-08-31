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

## L1 / L2 / L3

- **L1:** trace/profile contract와 mutation self-test가 초점 신원 오염, W13 선택
  drift, 자유 milestone timer 재도입을 거부한다.
- **L2:** Timer 수명 fixture와 clean 세-profile W1→W240 exact matrix가 실제 입력,
  invest-only 경로, ending, teardown leak 0을 증명한다.
- **L3:** 새 exact candidate의 property와
  `general_near_goal_father_passed` M49~M60 정상 속도 사람 실플레이가 판정한다.
  그전까지 본편은 HOLD다.
