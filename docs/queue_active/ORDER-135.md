# Active Queue Spec: ORDER-135

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-135 [P0·5장 일반 종막] 25억 문턱·아버지 별세 경로의 앞선 선택을 마지막 기록과 선발신에 잇는다

**[~] 진행 중 — 선언 기준선:**
`bc1006f492c2f9e2457b39ca2787b2cf68274da7` / tree
`5313bbc09666eb6ce573a7b9c1ec9a85bf06a008`.

**사용자 위임·착수 근거 (2026-08-27):** 사용자는 처음부터 끝까지 스토리와
게임성이 빽빽하고, 엔딩으로 갈수록 더 치밀하고 격동적이어야 한다고 했다.
중요 장면은 1~2비트로 끝내지 말되 `10`이라는 숫자에 억지로 맞추지 말라고
확인했고, 게임을 완성할 때까지 자율 진행한 뒤 실제 플레이할 시점과 버전을
알려 달라고 했다. 측정상 일반 5장 경로는 투자 기준 경로보다 직접 정지·선택·
분량·peak가 낮고, M51 민서·M56 아버지·M59 문턱 선택이 generic W237/W240에
정확히 읽히지 않는다. 이 오더는 증거가 완전한 첫 일반 profile만 작은 자식으로
닫는다.

## 이번 자식의 정확한 제품 범위

- profile: `general_near_goal_father_passed`.
- 진입: W237, 투자·부동산 causal/finale entry가 없고, 아버지 별세가 단조
  사실이며, `arc_minseo_03_arrival`, `arc_father_legacy`, 신규 W229,
  `arc_pre_ending_summit`에서 각각 정확히 한 선택 영수증이 있을 때만.
- 현재 자산값을 W237에서 다시 진실처럼 고정하지 않는다. M51 도착 장면과 M59
  25억 문턱 장면을 실제로 본 기록이 near-goal의 과거 증거다.
- 신규 작성은 4 roots·10 choices다. W229 `last_page_instruction` 2선택,
  W237 `record_seal` 2선택, W240 `signature` 3선택, 같은 턴 W240
  `outbound` 3선택이다. 네 root는 instruction→record ownership→interpretation→
  concrete person action의 서로 다른 기능 때문에 존재하며 비트 수 목표가 아니다.
- 아버지 생존, 25억 미만·저자산, source 누락/충돌, career/startup, 투자·부동산
  profile은 이 자식이 사실을 발명하지 않는다. 기존 generic 또는 기존 property
  결말이 그대로 소유한다.

## 깊이 3문

1. **이걸 지우면 무엇이 깨지는가?** 민서의 ‘도착 뒤 질문’, 아버지의 빈 의자,
   25억 문턱에서 연 연락처/걸은 한 블록이 마지막 서명에 도달하지 않고 모두
   같은 generic 산문으로 합쳐진다. W229도 직접 독자 없이 빈 주차로 남는다.
2. **고른 플레이어와 안 고른 플레이어가 24주 뒤 다른가?** 이 구간은 게임의
   마지막 12주 안이므로 W240에서 차이를 증명한다. 네 exact choice index가
   entry·stage receipt·ending coda에 남고, W237 첫 장, W240 서명 문장,
   마지막으로 실제 보낸/남긴 행동이 달라진다. 답장·용서·재회는 만들지 않는다.
3. **같은 자리에서 무엇과 경쟁하는가?** W229의 평온/반복 아크, W237 generic
   `arc_final_countdown`, W240 generic `arc_final_week`, AP 행동판과 경쟁한다.
   대상 profile이 잠긴 뒤에는 원장의 다음 exact root가 그 주 행동을 소유한다.

## 배치 A — 제품 16단위

1. M51 민서 2선택에 locale-neutral exact choice flag를 붙이고 KO/EN parity를
   지킨다.
2. M56 아버지 3선택에 exact choice flag를 붙이고 별세 사실을 바꾸지 않는다.
3. M59 문턱 2선택에 exact choice flag를 붙이고 매수·소유를 만들지 않는다.
4. W229 `arc_y5_general_last_page_instruction` KO/EN 2선택을 쓴다.
5. W229를 exact 주차의 foreground commitment owner로 둬 AP 재질문을 막는다.
6. source flag 그룹마다 bool true 정확히 하나와 event_log 한 건·choice index
   일치를 검사한다.
7. 신규 `chapter5_general_finale_ledger.json`에 3 roots·8 choices를 기록한다.
8. 기존 property 상수·원장·schema 1 save를 보존한 채 reducer에 profile/ledger
   selector를 추가한다.
9. W237 진입은 source/father/property exclusion을 모두 통과할 때만 원장 ID와
   entry를 원자적으로 잠근다.
10. W237 `arc_y5_general_final_record_seal` KO/EN 2선택을 쓴다.
11. W240 `arc_final_countdown_general_near_goal_passed` KO/EN 3선택을 쓴다.
12. 같은 턴 W240 `arc_y5_final_week_general_people_outbound` KO/EN 3선택을 쓴다.
13. 각 finale root는 ledger-exact `chapter5_finale_reads`를 prepend한다.
14. outbound receipt가 `pending→ready`, MainGame 복귀가 `ready→consumed`를
   정확히 한 번 수행한다.
15. EndingSystem은 기존 다은 coda를 그대로 두고 general outbound 3종만
   receipt event ID로 분기한다.
16. lifecycle/director/map/rules/spine/release inventory와 장면·선택 정본을 실제
   제품 모양에 맞춘다.

## 배치 B — 증거 16단위

1. 기존 property Python 감사 11/30·한 런 9/24를 exact 불변으로 재실행한다.
2. 신규 general Python 감사가 4/10 source+finale inventory와 mutation을 맡는다.
3. Godot reducer 검사가 property와 general 두 profile을 모두 replay한다.
4. wrong turn/profile/father alive/source missing·multiple·non-bool을 byte-exact
   거절한다.
5. receipt write-once/idempotent/order/index/ledger-ID tamper를 막는다.
6. ManualSave가 W237 entry·partial·W240 ready/consumed를 disk roundtrip한다.
7. W220 legacy fresh/W221 이후 missing closed 경계를 그대로 지킨다.
8. CoreChoiceSlice가 W229·W237 direct ownership과 W240 same-turn 2 roots를
   실행한다.
9. invalid general source는 hold 없이 generic finale로 fallback함을 실행한다.
10. EndingRouteIdentity가 general coda 3종과 consumed 전 coda 0을 증명한다.
11. 즉시 실패 5종이 finale hold/ready보다 항상 먼저 이김을 증명한다.
12. 33세·1장 30억 `instant_legend` 블록과 결과를 byte-exact로 지킨다.
13. KO/EN parity·i18n·말투·연속성·lifecycle/director/map/spine/pacing을 통과한다.
14. 변경 scope 감사 뒤 shared runtime freeze에서 exact clean 전체 감사를 한 번
   실행한다.
15. KO/EN 실제 W229·W237·W240을 렌더해 검은막·겹침·포커스·same-turn·ending
   handoff를 육안 확인한다.
16. `project.godot` hash와 career/startup reference 32 roots·86 choices, property
   19/47+11/30을 불변 증거로 남긴다.

## 정확한 파일 소유권

**런타임·원장:** `autoloads/GameState.gd`, `scenes/MainGame.gd`,
`systems/Chapter5FinaleRoute.gd`, `systems/EndingSystem.gd`, 신규
`content/meta/chapter5_general_finale_ledger.json`. `scenes/StoryMode.gd`는 기존
transaction/read/same-turn 계약 재사용을 우선하며 결함이 증명될 때만 최소 수정한다.

**사건 KO/EN:** `content/events{,_en}/arc_new_characters.json`,
`content/events{,_en}/arc_year3_drama.json`,
`content/events{,_en}/arc_pre_ending.json`,
`content/events{,_en}/arc_drama.json`.

**연출 원장:** `assets/scene_audio_manifest.json`,
`assets/scene_direction_manifest.json`. 신규 네 장면의 기존 cue·같은 장소 연속성을
등록하는 파일이며 오디오 파일·배경·초상 원화 자체는 바꾸지 않는다.

**제품·서사 계약:** `content/meta/event_lifecycle.json`,
`content/meta/event_director.json`, `content/meta/story_map.json`,
`content/meta/story_rules.json`, `content/meta/narrative_spine.json`,
`content/meta/exposed_event_state_contracts.json`,
`content/meta/release_content_inventory.json`, `docs/STORY_BIBLE.md`,
`docs/CHOICE_CONSEQUENCE_SYSTEM.md`, `docs/SCENE_TIER.md`,
`docs/ENDING_CONTRACT.md`, `docs/QA_CHECKLIST.md`, 생성본
`docs/CONTENT_RATING_INVENTORY.md`.

**검사:** 기존 `tools/chapter5_finale_route_audit.py`, 신규
`tools/chapter5_general_finale_route_audit.py`,
`tools/Chapter5FinaleRouteCheck.gd`, `tools/CoreChoiceSliceCheck.gd`,
`tools/ManualSaveCheck.gd`, `tools/EndingRouteIdentityCheck.gd`,
`tools/ScreenshotQA.gd`,
`tools/event_lifecycle.py`, `tools/event_director_audit.py`,
`tools/story_map_audit.py`, `tools/narrative_spine_audit.py`,
`tools/narrative_continuity_audit.py`, `tools/full_run_pacing_audit.py`,
`tools/story_consistency_audit.py`, `tools/peak_scene_chain_audit.py`,
`tools/exposed_state_consistency_audit.py`,
`tools/arc_flow_sim.py`, `tools/i18n_coverage_check.py`, `tools/audit.py`,
`tools/audit_scope.json`, `tools/audit.sh`,
`tools/year5_reference_route_audit.py`,
`tools/chapter1_core_loop_v2_causal_ledger_check.py`의 exact source snapshot.

**선언·마감:** `docs/CODEX_QUEUE.md`, 이 사양, `CLAUDE.md`,
`docs/WORK_LOG.md`, 생성본 `docs/STATUS.md`; 완료 시 사양·큐 이력 아카이브.

`project.godot`, balance 수치, 기존 endings JSON, career/startup reference roots,
`systems/Year5ReferenceRouteKernel.gd`, 기존 property causal/finale 원장 산문은
수정하지 않는다. `GameState.check_game_over()`는 변경하지 않고 즉시 실패→finale
hold→`instant_legend`→일반 30억 순서를 그대로 보존한다.

## L1/L2 후보 증거 (2026-08-27)

- **L1 GREEN:** source+finale `4 roots / 10 choices`, 별도 finale 원장 `3/8`, 기존
  property `11/30`·한 런 `9/24`, career/startup reference `32/86`, 33세
  `instant_legend`를 보존했다. exact source flag+event log, neutral/investor 경로 tuple,
  father/contact exact bool, entry/receipt write-once, JSON 저장, 손상·legacy fallback,
  same-turn outbound, ending pending→ready→consumed를 Python mutation 24건과 Godot
  reducer·CoreChoice·ManualSave·EndingRouteIdentity로 실행했다.
- **L2 화면 GREEN:** KO/EN × 960×600·1280×800·1920×1080의 W229·W237·W240
  signature·outbound·ending 78/78장을 전수 확인했다. 검은 전환, 잘림·겹침, 초점,
  언어 누출, 민서·아버지의 허위 동석은 0이다. 기존 property KO/EN 1280도 각
  10장을 다시 렌더해 W240 same-turn·ending handoff를 보존했다.
- **보호 바이트:** `project.godot` git hash
  `de7af180446a6976bdbb622d9d814175d0869115`, SHA-256
  `78e98d7bdc1349570df6f2cc7ca6cbb11d4fc5451f5bbfdd338561653c7380c5`.

| 행 | 도달·producer → reader | before → after | 이번에 포기한 것 | 화면에 남은 물성·근거 |
|---:|---|---|---|---|
| 1 | W229 · M51 민서 대답 + M56 빈 의자 행동 → `last_page_instruction` | 마지막 장의 첫 줄 없음 → 둘 중 하나의 exact index·event-log 영수증 | 고르지 않은 문장은 표지가 아니라 첨부 기록으로 밀림 | 수첩 사이의 색인 한 장과 펜 · `content/events/arc_pre_ending.json:414`, `autoloads/GameState.gd:491` |
| 2 | W237 · 네 source + 별세/경로 tuple → `record_seal` | generic W237·hold 없음 → immutable entry와 봉인 receipt, 그 주 직접 소유 | 색인과 빈 매수인 칸 중 고르지 않은 한쪽은 파일 첫 장을 잃음 | 날짜를 쓴 투명 파일·25억원대 매물표 세 장·빈 매수인 이름 · `content/events/arc_pre_ending.json:463`, `content/meta/chapter5_general_finale_ledger.json:42`, `autoloads/GameState.gd:537` |
| 3 | W240 · 봉인 receipt → `signature` | ending pending → 서명 receipt는 남지만 outbound 전까지 계속 pending | 확인 사실/이름과 시간/사람 이름 우선 중 고르지 않은 두 해석 | 수첩 마지막 면의 세 칸과 자기 이름 한 번 · `content/events/arc_pre_ending.json:540`, `content/meta/chapter5_general_finale_ledger.json:97` |
| 4 | 같은 W240 · signature → `outbound` → ending coda | pending → outbound 뒤 ready → MainGame 복귀에서 consumed 1회 | 보내지 않거나 쓰지 않은 다른 두 행동은 그 밤 기록에 남지 않음 | 민서 채널의 자기 쪽 전송 시각 또는 아버지 봉투의 날짜 한 줄 · `content/events/arc_drama.json:1473`, `content/meta/chapter5_general_finale_ledger.json:148`, `autoloads/GameState.gd:601`, `systems/EndingSystem.gd:158` |

## 완료 판정

- **L1 기계:** 신규 4 roots·10 choices, general finale 3/8, exact source→entry→
  receipt→coda, save/load/tamper/legacy/fallback/same-turn/ending exactly-once를
  Python+Godot으로 입증한다. property·career/startup·instant legend 회귀 0.
- **L2 자가:** 4행 전수표에 도달 주차, producer↔reader, before→after, 포기 비용,
  물성, 파일:행을 남긴다. KO/EN 실제 화면과 검은막 0을 확인한다.
- **L3 사람:** 자동 GREEN은 재미 GO가 아니다. 새 후보 빌드에서 사용자가 정상
  속도 M49~M60을 플레이해 앞선 세 선택이 마지막 밤에 되돌아오는지 판정한다.
  이 단계 전에는 완성·main 병합·플레이 준비 완료를 선언하지 않는다.

## 다음 경계

아버지 생존과 3억~25억 중간 자산 일반 런은 별도 작은 자식이다. 이 오더의
측정으로 밀도 결함이 증명되기 전까지 빈 주차를 장식 장면으로 채우지 않는다.
