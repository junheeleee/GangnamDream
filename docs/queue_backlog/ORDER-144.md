# Active Queue Spec: ORDER-144

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-144 [P0·runtime evidence] 새 게임 W1→W240 사건 occurrence를 실제 제품 흐름에서 기록한다

**[~] 2026-08-31 Codex 착수 · 기준선 `06277c30e61ed54c99069e16fd591ec0ef26c388`:**
ORDER-142의 135 shipping-eligible refs는 작성·생명주기 정적 표면이지 한 플레이의
실제 노출 증거가 아니다. 신규 tools-only trace가 실제 title/new game/opening/
MainGame/StoryMode/ending 흐름을 진행한다. 첫 구현은 제품 파일을 바꾸지 않는다.

## 깊이 3문

1. **기존 자동 완주를 재사용할 수 있는가?** 입력·전환 helper만 참고한다. 기존
   `full-gamepad`는 event ID를 set으로 중복 제거하고 legacy cadence를 검증하므로
   occurrence 분량과 현재 경로 증거로 사용하지 않는다.
2. **한 사건 ID가 다시 나오면 중복인가?** 아니다. occurrence ID와 StoryMode
   instance/event serial을 따로 기록한다. 같은 ID 재등장은 결함일 수도 합법 recovery일
   수도 있으므로 순서·부모·도착 source와 함께 판정한다.
3. **W240 도달이면 게임이 완성인가?** 아니다. headless trace는 실제 selector,
   선택 표면, 상태 receipt, 주차·엔딩 도달만 증명한다. 화면·속도·소리·재미·밀도는
   같은 exact candidate의 사람 플레이가 판정한다.

## 22단위 구현

1. tools-only 소유권과 비목표를 선언한다.
2. 세 profile JSON schema를 만든다.
3. occurrence JSONL v1 schema를 만든다.
4. contract audit를 만든다.
5. malformed/duplicate/missing-edge self-test를 만든다.
6. HOME/XDG를 격리하는 runner를 만든다.
7. clean commit/tree와 profile SHA를 봉인한다.
8. 실제 StartMenu를 생성한다.
9. 최초 콘텐츠 안내를 실제 입력으로 통과한다.
10. New Story와 `run_started`를 확인한다.
11. OpeningCinematic을 통과한다.
12. W1 MainGame/StoryMode 진입을 확인한다.
13. scene watcher를 구현한다.
14. instance+serial 기반 story occurrence를 기록한다.
15. main ingress/queued/follow-up/same-turn provenance를 기록한다.
16. 원문 문단·runtime page·문자·hash와 narrative/control class를 기록한다.
17. choice offer, authored/display index, direct/timed selection을 기록한다.
18. flags, event log, deferred, commitment, Chapter 5 reducer 전후 delta를 기록한다.
19. MainGame 행동·결과·week open/close를 기록하되 AP/control을 서사 분량에서 뺀다.
20. W240 ending open·6 page·run end를 검증한다.
21. safe people, property+daeun, general near-goal father-passed 세 profile을 실제
    선택만으로 실행한다. 주차·돈·상태 주입은 실패다.
22. 단일 경로와 matrix 실행 증거를 발급하되 `product_go=HOLD`,
    `human_density_gate=OPEN`을 고정한다.

## profile과 실패 의미

- `baseline_safe_people`: clean/가족·사람/저위험 선택으로 W240까지 간다.
- `investment_property_daeun`: 실제 선택과 경제 결과로 20억+, 다은/상철/민서·재혁
  선행, property safe-no-execution, W240 property signature/outbound를 요구한다.
- `general_near_goal_father_passed`: 실제 선택으로 아버지 별세, 25억 이상 30억 미만,
  M51→W211→W220→W224→W240 general chain을 요구한다.

후자의 두 경로가 상태 주입 없이 조건에 못 미치면 도구가 억지로 맞추지 않고
profile FAIL을 남긴다. 그것이 실제 제품 도달 구멍의 증거다. instant legend는
진단 profile 밖 이스터에그로 보존한다.

## JSONL 필수 record

`run_start`, `week_open`, `story_enter`, `choice_offer`, `story_choice`,
`story_result`, `main_action_offer`, `main_action_commit`, `week_close`,
`ending_open`, `ending_page`, `run_end`, `trace_error`를 append-only로 남긴다.
모든 줄은 candidate commit/tree/dirty, profile/hash/seed/locale, week/month/chapter,
scene path, occurrence identity를 가진다. 저장소에는 실행 JSONL을 baseline으로
커밋하지 않는다.

## 정확한 파일 소유권

신규 `tools/FullGameRuntimeTrace.gd`, `.gd.uid`, `.tscn`,
`tools/full_game_runtime_trace_profiles.json`,
`tools/full_game_runtime_trace_audit.py`,
`tools/run_full_game_runtime_trace.sh`; 수정 `tools/audit.sh`,
`tools/audit_scope.json`과 선언·마감 문서만 소유한다.

`project.godot`, `MainGame.gd`, `StoryMode.gd`, autoload, 사건 원고, 저장 schema는
첫 구현에서 읽기만 한다. `--demo-build`, `--core-loop-v2`,
`--core-loop-v2-playtest-build`는 W24/다른 저장 flavor를 만들 수 있어 금지한다.

## L1 / L2 / L3

- **L1:** JSON/profile/runner contract와 mutation self-test가 잘못된 후보·주입·event
  dedup·누락 occurrence·W240/ending 누락을 거부한다.
- **L2:** Godot이 있는 clean 환경에서 세 profile을 실행해 JSONL과 exact candidate
  identity를 감사한다. 이 환경에 Godot이 없으면 `PENDING`이지 GREEN이 아니다.
- **L3:** trace와 같은 후보의 정상 속도 M01~M60 플레이가 화면·페이스·사람선·후반
  상승을 판정한다. 그때 사용자에게 플레이 차례를 알린다.
