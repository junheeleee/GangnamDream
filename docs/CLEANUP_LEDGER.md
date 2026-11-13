# 레거시·잔여 코드 정리 원장 — ORDER-827 / 1단계

기준 소스: `cb2d4bcd7314ff967de2ecea9330537966f447cc`. 아래 줄 번호는 이 커밋 기준이며, 현재 화면 실행이나 사용자 저장의 내용 검사가 아니다. C1의 정상 slot1 W192→M60은 콘솔 잠금으로 보류. 1단계는 목록만 작성하며 제품·저장·번역·공개 데모·검사·export를 변경하지 않는다.

**A**: 새 이야기·기존 Load·QA에서 참조가 확인되지 않은, 상태를 쓰지 않는 삭제 후보. **B**: 예전 Load 또는 호환 표면에 연결되어 유지. **B?** 표기는 별도 분류가 아니라 B의 보수적 보류: 개별 옛 저장에서 실존한다고 단정할 수 없거나 공유 경계를 아직 분리하지 못했으므로 A로 올리지 않는다. **C**: 플레이테스트·QA·개발 전용. 제품 export 제외와 CI 제거는 다른 판단이다. **D**: 현재 출시 호출, 공유 컴파일 의존 또는 보호 계약으로 유지. “컴파일 의존”은 모든 분기에서 플레이어가 그 기능을 본다는 뜻이 아니다.

## 실제 진입·복원 추적

| 근거 | 실제 호출·게이트 | 판정 및 위험 |
| --- | --- | --- |
| R1 | `project.godot:19` → `scenes/SplashScreen.gd:7,477` → `scenes/StartMenu.gd:563–604,1978–1990,2104–2126`에서 일반 시작은 `false`; 콘텐츠 경고 확인 뒤 `initialize_fresh_run` → `scenes/OpeningCinematic.gd:8,179–194,311–320` → MainGame. `systems/FullStoryFlow.gd:49–68,71–89,521–541`은 full·V2 미요청만 허용, marker가 손상돼도 legacy로 넘기지 않는다. | D. 출시 새 이야기와 강제 V2 버튼·명시적 QA preview 분리. |
| R2 | `scenes/MainGame.gd:349–355,386–400,528–604,629–690,6772–6902,10796–10826`. 일반 본편은 신선한 marker를 보유하고, 기존 공용 스토리 선별을 통과해도 `_full_story_route_week()`가 AP 렌더 본문보다 먼저 돌아간다. V2 주/플래너는 별도 enabled 게이트. `_refresh_all`은 숨겨진 AP 칩까지 채움(:9803–9836). `_ap_status_text`를 “미표시이므로 dead”로 판단하지 않는다. | D: 소유·게이트 및 공용 갱신. B: 그 뒤 구 AP 행동판/행동·구 V2 UI. 다만 V2 이름이 붙은 조건 검사도 공용 흐름에서 호출된다. |
| R3 | `scenes/StartMenu.gd:2128–2133` → `autoloads/SaveManager.gd:93–134,159–163,290–375,392` → 저장 scene으로 복귀(MainGame/StoryMode). 이름 없는 구 저장의 호환 경고/허용과 **명시 V2 전용 namespace/flavor 거부**는 별개다. `autoloads/GameState.gd:1138,4614–4615,4643,4718,4856–4859` 보존/복원 → `systems/DemoCoreLoopV2.gd:444–463,564–577,20025+`의 기존 enabled·정규화. `MainGame:386–387`은 marker도 action_log도 없는 상태를 초기화하므로 모든 무표시 파일이 AP에 들어간다는 뜻은 아니다. | B. 레거시 AP/V2 경로를 빼면 호환 가능한 저장의 진행·receipt·복원 동작이 달라질 수 있다. 전용 테스트 저장을 retail에서 열 수 있다고 주장하지 않는다. |
| R4 | `scenes/StartMenu.gd:563`은 V2 cap을 일반 메뉴에서도 계산. `autoloads/DataRegistry.gd:162,493` → V2 계약 로드. `scenes/MainGame.gd:704–717` → `systems/FullStoryFlow.gd:440–453,769–795`는 `routine.options.livelihood.weekly_effects`·`recovery.weekly_effects`를 본편 자동 생계·회복에 직접 소비. `scenes/StoryMode.gd:6253,7187–7195`는 구 V2 이름의 공용 텍스트/후속 처리, `autoloads/EventManager.gd:942`는 콜백 정규화 호출. | D. JSON/스크립트 통째 제거 금지. routine 상위 부모 전체를 순수 V2로 집계하지 않는다. |
| R5 | `scenes/MainGame.gd:1485–1507,1618–1729,3764–3812`가 플래너/서울 보드/결과 열기. `:2188–2281,2523–2539,16632–16638,18616–18632`가 Aruba/이력서·면접 열기. `:349–355`에서 둘을 무조건 생성, 각각 `ArubaGame.gd:300–308`, `JobHuntMiniGame.gd:249–256`가 숨겨도 UI를 구성한다. 반례: `systems/FullStoryFlow.gd:107–120` → `MainGame:987–1059,18260–18290` 경마는 본편 직접 활동. | B: V2/AP 전용 열기와 해당 저장 복귀. D: 로드/생성 의존, 실제 경마. C로 표시된 도구를 제외해도 이 제품 파일의 export 제외는 별개이고 현 상태에선 불가. |
| R6 | `MainGame:9597–9634,9645–9735,9313–9329,9349–9375`는 옛 인라인 이벤트 창이 choice `foreshadow`를 읽고 소비하는 별도 경로. `:8950,11313`은 AP 보드의 **계산된** 예고로, 같은 키를 읽지 않는다. `DataRegistry.gd:150,182` 외부 언어 필드와 모드 허용 필드도 다름. `FullStoryFlow.gd:419–435`가 W4에서 같은 사건 루트 `arc_temptation_01`을 요구하지만 StoryMode가 인라인 결과 위젯을 실행하는 것은 아니다. | B: 구 창·계산 예고의 두 경로. D: 사건 루트와 공개 데모 계약. 공개 데모 보호 leaf와 전체 여섯 KO 복선 필드를 혼동 금지. |
| R7 | `tools/event_lifecycle.py:466–698`의 author-only 111건(태그 97·원장만 14)은 통상 진입을 막는 guard. `DataRegistry.gd:431,507`는 패키지/ID 조회 유지. `SaveManager.gd:119–127` → `StoryMode.gd:256–259,4016–4082`는 저장된 큐 ID를 읽되 full marker는 추가 바인딩 검증; `StoryMode:280–346` 갤러리는 별도 허용 목록. `EventManager.gd:855–871`의 일반 deferred는 조건을 재검사한다. | B? 111개의 개별 옛 저장 실존·재생을 관측한 것은 아니다. 통상 진입 없음만으로 ID 호환 무관을 증명할 수 없고 2단계 event ID 변경도 금지이므로 전부 보류. |
| R8 | `tools/full_game_localization.py:759–786`은 V2 스코프 수집 701개에서 이미 수용한 정적 키를 뺀 692개를 `ui_demo_dynamic`으로 분류한다. 이 집합은 export filter가 아니다. `autoloads/LocaleManager.gd:259–268,294–337,522–550`는 KO 문구로 공용 테이블 조회. `OpeningCinematic.gd:191–194,261–264`의 오프닝 6키와 `StoryMode.gd:3318,5412`의 인물 이름 소비는 V2 전용이 아니다. | D: 오프닝 6, 공용 인물 이름 2(실제 scene 소비와 계약 보호). B?: 다른 호출이 같은 KO 키를 소비할 수 있다. 하나의 수집 출처만으로 키를 삭제하지 않는다. ORDER-818 오프닝 보존. |
| R9 | `export_presets.cfg:8–11,54–57,114–117,150–153` 일반 export의 `tools/*,docs/*,build/*` 제외; 격리 V2 custom preset :318–321,364–367. 공개 M01~M06 빌더 `tools/build_story_demo_successor_macos.py:28,107–110,124–135`는 별도 controller 진입/namespace, all_resources. `playtests/order124/StoryChoiceM1M6Playtest.gd:11–16,1047–1059` → StoryMode. `docs/BUILD_PIPELINE.md:514–526`의 공개 `story_demo_rc` 2026.08.31.1 122키는 보호 기준. | C는 일반 export에서 이미 제외된 tools가 대부분이다. 공개 데모 controller는 경로 이름에 playtest가 있어도 D. 24주 V2, stock demo flavor, 공개 story_demo를 혼용 금지. |
| R10 | A helper 이름은 tracked 스크립트·씬·리소스·도구에서 선언(또는 아래 내부 호출)만 관측. `MainGame:14226,15588,16385` 문자열 dispatch는 실제 행동 카드가 전달한 함수명으로 한정. `StartMenu:1578–1636`의 panel→row 외부 연결 없음. | A 후보는 UI 로컬 생성/문자열 반환/딕셔너리 계산/무동작 반환만. 새 씬·저장·데이터 ID·번역 키는 이 후보에 포함하지 않는다. |
| R11 | `content/meta/story_map.json:462–473`은 M06 First Bill의 저작상 의도(`needs_rule`)다. 일반 새 이야기의 해당 root 실제 producer로 세지 않는다. `scenes/StoryMode.gd:2369–2378,3693–3710,6445–6457,7180–7195`는 queue/replay 포맷 소비. 공개 `playtests/order124/StoryChoiceM1M6Playtest.gd:25–29,892,901,1113–1209,2762–2765`는 source·ledger와 위험 후속 두 ID를 실제 소비한다. | D. 현재 보호된 공개 계약과 공유 소비 의존. 일반 본편 fresh ingress와 분리. |
| R12 | `tools/audit.sh:260–279,460–475,546–726,1442–1476,1534–1535`, `.github/workflows/ci.yml:64–90`. 전용 래퍼 `tools/run_core_loop_v2_input_qa.sh:95,161` → 공용 ScreenshotQA의 V2 모드. | C. 일반 export에서 tools는 이미 제외. 등록을 제거하면 해당 증거가 사라진다. 원장 JSON의 all_resources 제외 여부는 이후 별도 검증. |

## 2단계 제안과 3단계 경계

1. 먼저 MainGame 미참조 UI helpers(`_goal_sep`, `_demo_record_separator`, `_hint_box`)만 한 묶음 후보.
2. 별도 묶음으로 AP 미참조 표시/계산(`_ap_act_line`, `_ap_result_display_effects`, `_ap_result_feedback_card`); 의존 helper `_result_effect_is_visible` 및 StoryMode의 별도 결과 함수는 이 묶음 밖이다.
3. 마지막으로 시작 화면의 미참조 `_start_brief_panel` + 내부 전용 `_start_brief_row`만 후보. 소스 문구를 읽는 검사/번역 스냅샷이 따라오는지 먼저 재확인하고, 필요하면 이 묶음을 보류한다. 번역 테이블은 그대로 둔다.

위 목록은 삭제 실행이 아니다. C1 완주 후 묶음마다 한 커밋, 전체 컴파일·audit_select 영향 검사·새 이야기 W1~W8·실제 slot1 정상 Load를 확인하고 하나라도 실패하면 그 묶음만 revert. 현재 감시 대상을 가진 검사는 변경하지 않는다. B는 출시 후 v1.1에서 구 저장→새 구조 변환과 복원 비교를 먼저 마련한 뒤 따로 제거한다.

## 실제 CI 시간과 전후 비교

동일 Godot 잡 한 표본: [main CI 43384402423, Godot 131749381111](https://github.com/junheeleee/GangnamDream/actions/runs/43384402423/job/131749381111), `6f327b4`, 성공. job wall time 07:15:13–08:56:17 UTC = **101분 04초**. CI 정의는 `.github/workflows/ci.yml:64–90`.

| 구간 | 실측 | 해석 |
| --- | ---: | --- |
| 전체 audit 단계 | 63분 59초 | 전체 컴파일·현행·레거시 검사가 함께 들어 있음. |
| audit.sh:546–726 V2 연속 10 블록 | 38분 38.6초 | 각 heading부터 다음 heading까지: 739.3 / 30.3 / 144.4 / 29.4 / 8.5 / 244.6 / 394.2 / 497.1 / 34.4 / 196.4초. 첫 블록은 설계/causal self-test·검사/시뮬 합산. 마지막 경계는 08:02:05 UTC 연락폰 schema 3 검사 시작. |
| 별도 V2 W24 입력 KO/EN + 증거 업로드 | 33분 44초 | KO 1,013초, EN 1,009초, 업로드 2초. 공개 데모 검사가 아님. |
| 합산 관측 상한 | 72분 22.6초 (71.6%) | 혼합 demo flavor 검사와 전용이라고 아직 입증 못한 검사는 합계에서 제외. 보존해야 할 B/D 테스트를 지운다는 뜻이 아니다. |

1단계 전후 제품 줄/파일 Δ0, CI 구성 Δ0, 이 변경에 따른 CI 절감 0. A 상위 3묶음도 전용 검사 제거가 확인되지 않아 예상 절감 **0분**. 나중에 전용 V2 입력 잡을 안전하게 별도 호환 lane으로 분리할 수 있다면 이 표본 기준 기본 잡 **약 34분** 단축 여지가 있으나, 실행 총량 절감은 아니며 이번 승인 범위가 아니다. **약 72분은 측정된 상한이지 목표나 승인 시간이 아니다.** 2·3단계 후에는 변경 경로/코드 줄·파일 수와 같은 CI 잡/조건으로 재측정한다.

## 항목별 목록과 합계

아래의 줄 수는 기준 소스의 물리 줄, 양 끝 포함. 함수 범위는 선언부터 마지막 본문 줄(내부 공백 포함, 다음 함수 주석 제외). 같은 파일의 인접 함수/데이터 범위는 겹치지 않는다. JSON의 UI 표는 존재하는 번역 키 한 줄씩만 센다. 없는 번역을 줄이나 신규 누락으로 세지 않는다. C의 .uid/.tscn도 독립 파일 줄 수에 포함. 수치에는 조사한 파일/범위만 포함하며 전체 저장소 총량은 아니다.

| 분류 | 항목 | 물리 줄 | 관련 파일 |
| --- | ---: | ---: | ---: |
| A | 8 | 103 | 2 |
| B | 1849 | 47,120 | 47 |
| C | 102 | 200,840 | 102 |
| D | 181 | 20,920 | 47 |
| 합계 | 2140 | 268,983 | 178 (중복 제거) |

A 103줄 = MainGame UI 19 + AP 미참조 26 + StartMenu panel/row 58. C 수치는 긴 검사 fixture·원장까지 포함하므로 곧바로 삭제 또는 CI 절감 규모가 아니다.

### MainGame·StartMenu

<details>
<summary>190 항목</summary>

| 분류 | 함수·키 | 파일:줄 | 줄 수 | 근거·등록 |
| --- | --- | --- | ---: | --- |
| D | `DEMO_CORE_LOOP_V2` | `scenes/MainGame.gd:9` | 1 | R2/R4 |
| D | `CORE_LOOP_PLANNER_SCRIPT` | `scenes/MainGame.gd:13` | 1 | R2/R4 |
| D | `SEOUL_CYCLE_BOARD_SCRIPT` | `scenes/MainGame.gd:14` | 1 | R2/R4 |
| D | `CORE_LOOP_V2_COMPLETION_SCRIPT` | `scenes/MainGame.gd:15–16` | 2 | R2/R4 |
| D | `_ap_commit_layer` | `scenes/MainGame.gd:79` | 1 | R2/R4 |
| D | `_ap_commit_tween` | `scenes/MainGame.gd:80` | 1 | R2/R4 |
| B | `_ap_rail_slot_counter` | `scenes/MainGame.gd:82` | 1 | R2/R3/R6 |
| B | `_ap_action_grid` | `scenes/MainGame.gd:83` | 1 | R2/R3/R6 |
| B | `_ap_feature_row` | `scenes/MainGame.gd:84` | 1 | R2/R3/R6 |
| B | `_ap_grid_cards` | `scenes/MainGame.gd:85` | 1 | R2/R3/R6 |
| B | `_ap_grid_columns` | `scenes/MainGame.gd:86` | 1 | R2/R3/R6 |
| B | `_ap_focus_restore_index` | `scenes/MainGame.gd:87` | 1 | R2/R3/R6 |
| B | `_ap_focus_restore_turn` | `scenes/MainGame.gd:88` | 1 | R2/R3/R6 |
| B | `_seoul_cycle_board` | `scenes/MainGame.gd:153` | 1 | R2/R3/R6 |
| B | `_core_loop_v2_completion` | `scenes/MainGame.gd:154` | 1 | R2/R3/R6 |
| B | `_seoul_cycle_focus_restore` | `scenes/MainGame.gd:161` | 1 | R2/R3/R6 |
| B | `_seoul_cycle_allocation_in_flight` | `scenes/MainGame.gd:162` | 1 | R2/R3/R6 |
| B | `_seoul_cycle_save_retry_phase` | `scenes/MainGame.gd:163` | 1 | R2/R3/R6 |
| B | `_seoul_cycle_save_retry_month` | `scenes/MainGame.gd:164` | 1 | R2/R3/R6 |
| B | `_core_loop_v2_side_shift_job_id` | `scenes/MainGame.gd:167` | 1 | R2/R3/R6 |
| B | `_core_loop_v2_completion_autosave_succeeded` | `scenes/MainGame.gd:168` | 1 | R2/R3/R6 |
| B | `_core_loop_v2_completion_model` | `scenes/MainGame.gd:169` | 1 | R2/R3/R6 |
| B | `_last_chosen_foreshadow` | `scenes/MainGame.gd:282` | 1 | R2/R3/R6 |
| B | `_core_loop_v2_continue_after_story` | `scenes/MainGame.gd:1159–1215` | 57 | R2/R3/R5 |
| B | `_core_loop_v2_route_week` | `scenes/MainGame.gd:1217–1362` | 146 | R2/R3/R5 |
| B | `_core_loop_v2_route_seoul_cycle_week` | `scenes/MainGame.gd:1364–1381` | 18 | R2/R3/R5 |
| B | `_core_loop_v2_continue_seoul_cycle_week` | `scenes/MainGame.gd:1383–1433` | 51 | R2/R3/R5 |
| B | `_core_loop_v2_begin_seoul_cycle_owner` | `scenes/MainGame.gd:1435–1472` | 38 | R2/R3/R5 |
| B | `_core_loop_v2_route_preplan_opening_if_pending` | `scenes/MainGame.gd:1474–1483` | 10 | R2/R3/R5 |
| B | `_core_loop_v2_open_planner` | `scenes/MainGame.gd:1485–1506` | 22 | R2/R3/R5 |
| B | `_core_loop_v2_cycle_surface_snapshot` | `scenes/MainGame.gd:1508–1616` | 109 | R2/R3/R5 |
| B | `_core_loop_v2_open_seoul_cycle_board` | `scenes/MainGame.gd:1618–1642` | 25 | R2/R3/R5 |
| B | `_maybe_show_core_loop_v2_tutorial` | `scenes/MainGame.gd:1644–1656` | 13 | R2/R3/R5 |
| B | `_mark_core_loop_v2_tutorial_completed` | `scenes/MainGame.gd:1658–1659` | 2 | R2/R3/R5 |
| B | `_core_loop_v2_ensure_surfaces` | `scenes/MainGame.gd:1685–1722` | 38 | R2/R3/R5 |
| D | `_core_loop_v2_can_open_planner` | `scenes/MainGame.gd:1724–1728` | 5 | R2/R4 |
| B | `_core_loop_v2_open_saved_plan` | `scenes/MainGame.gd:1730–1739` | 10 | R2/R3/R5 |
| B | `_core_loop_v2_seoul_cycle_can_edit_current_week` | `scenes/MainGame.gd:1741–1755` | 15 | R2/R3/R5 |
| B | `_core_loop_v2_seoul_cycle_blocks_manual_advance` | `scenes/MainGame.gd:1757–1765` | 9 | R2/R3/R5 |
| D | `_core_loop_v2_can_open_phone` | `scenes/MainGame.gd:1767–1790` | 24 | R2/R4 |
| B | `_core_loop_v2_open_phone` | `scenes/MainGame.gd:1792–1813` | 22 | R2/R3/R5 |
| B | `_on_core_loop_v2_phone_closed` | `scenes/MainGame.gd:1815–1816` | 2 | R2/R3/R5 |
| B | `_on_core_loop_v2_planner_closed` | `scenes/MainGame.gd:1818–1821` | 4 | R2/R3/R5 |
| B | `_on_seoul_cycle_board_closed` | `scenes/MainGame.gd:1823–1837` | 15 | R2/R3/R5 |
| B | `_on_core_loop_v2_communication_requested` | `scenes/MainGame.gd:1839–1840` | 2 | R2/R3/R5 |
| B | `_on_core_loop_v2_phone_offer_requested` | `scenes/MainGame.gd:1842–1859` | 18 | R2/R3/R5 |
| B | `_core_loop_v2_restore_phone_focus` | `scenes/MainGame.gd:1861–1870` | 10 | R2/R3/R5 |
| B | `_core_loop_v2_restore_planner_focus` | `scenes/MainGame.gd:1872–1881` | 10 | R2/R3/R5 |
| B | `_core_loop_v2_restore_seoul_cycle_focus` | `scenes/MainGame.gd:1883–1892` | 10 | R2/R3/R5 |
| B | `_core_loop_v2_focus_target_available` | `scenes/MainGame.gd:1894–1901` | 8 | R2/R3/R5 |
| B | `_core_loop_v2_phone_shortcut_pressed` | `scenes/MainGame.gd:1903–1912` | 10 | R2/R3/R5 |
| B | `_on_core_loop_v2_plan_committed` | `scenes/MainGame.gd:1914–1921` | 8 | R2/R3/R5 |
| B | `_on_core_loop_v2_episode_committed` | `scenes/MainGame.gd:1923–1934` | 12 | R2/R3/R5 |
| B | `_on_seoul_cycle_allocation_requested` | `scenes/MainGame.gd:1936–1966` | 31 | R2/R3/R5 |
| B | `_core_loop_v2_initialize_seoul_cycle_durably` | `scenes/MainGame.gd:1968–1984` | 17 | R2/R3/R5 |
| B | `_core_loop_v2_commit_seoul_cycle_allocation_durably` | `scenes/MainGame.gd:1986–2007` | 22 | R2/R3/R5 |
| B | `_core_loop_v2_open_seoul_cycle_save_retry_gate` | `scenes/MainGame.gd:2009–2072` | 64 | R2/R3/R5 |
| B | `_core_loop_v2_retry_seoul_cycle_autosave` | `scenes/MainGame.gd:2074–2092` | 19 | R2/R3/R5 |
| B | `_core_loop_v2_resume_after_seoul_cycle_save_retry` | `scenes/MainGame.gd:2094–2112` | 19 | R2/R3/R5 |
| B | `_core_loop_v2_continue_after_durable_allocation` | `scenes/MainGame.gd:2114–2128` | 15 | R2/R3/R5 |
| B | `_core_loop_v2_finish_plan_commit` | `scenes/MainGame.gd:2130–2138` | 9 | R2/R3/R5 |
| B | `_core_loop_v2_begin_story_bundle` | `scenes/MainGame.gd:2140–2158` | 19 | R2/R3/R5 |
| B | `_core_loop_v2_play_scheduled_prelude` | `scenes/MainGame.gd:2160–2186` | 27 | R2/R3/R5 |
| B | `_core_loop_v2_begin_action_bundle` | `scenes/MainGame.gd:2188–2280` | 93 | R2/R3/R5 |
| B | `_core_loop_v2_rollback_action_bundle` | `scenes/MainGame.gd:2282–2284` | 3 | R2/R3/R5 |
| B | `_core_loop_v2_open_activity_task` | `scenes/MainGame.gd:2286–2327` | 42 | R2/R3/R5 |
| B | `_on_core_loop_v2_activity_task_selection_changed` | `scenes/MainGame.gd:2329–2339` | 11 | R2/R3/R5 |
| B | `_on_core_loop_v2_activity_task_resolution_confirmed` | `scenes/MainGame.gd:2341–2359` | 19 | R2/R3/R5 |
| B | `_core_loop_v2_finalize_activity_task_resolution` | `scenes/MainGame.gd:2361–2403` | 43 | R2/R3/R5 |
| B | `_core_loop_v2_present_activity_task_result` | `scenes/MainGame.gd:2405–2432` | 28 | R2/R3/R5 |
| B | `_core_loop_v2_submit_application` | `scenes/MainGame.gd:2434–2473` | 40 | R2/R3/R5 |
| B | `_core_loop_v2_apply_instant_effect` | `scenes/MainGame.gd:2475–2521` | 47 | R2/R3/R5 |
| B | `_core_loop_v2_open_side_shift` | `scenes/MainGame.gd:2523–2539` | 17 | R2/R3/R5 |
| B | `_core_loop_v2_take_recovery` | `scenes/MainGame.gd:2541–2585` | 45 | R2/R3/R5 |
| B | `_core_loop_v2_present_pre_bundle_declines` | `scenes/MainGame.gd:2587–2604` | 18 | R2/R3/R5 |
| B | `_core_loop_v2_log_routine_receipt` | `scenes/MainGame.gd:2606–2617` | 12 | R2/R3/R5 |
| B | `_core_loop_v2_localized` | `scenes/MainGame.gd:2619–2622` | 4 | R2/R3/R5 |
| B | `_core_loop_v2_completion_cycle_allocation_names` | `scenes/MainGame.gd:2624–2657` | 34 | R2/R3/R5 |
| B | `_core_loop_v2_recap_names` | `scenes/MainGame.gd:2659–2678` | 20 | R2/R3/R5 |
| B | `_core_loop_v2_completion_legacy_week_names` | `scenes/MainGame.gd:2680–2716` | 37 | R2/R3/R5 |
| B | `_core_loop_v2_cycle_node_label` | `scenes/MainGame.gd:2718–2737` | 20 | R2/R3/R5 |
| B | `_core_loop_v2_cycle_allocation_names` | `scenes/MainGame.gd:2739–2787` | 49 | R2/R3/R5 |
| B | `_core_loop_v2_cycle_outcome_names` | `scenes/MainGame.gd:2789–2834` | 46 | R2/R3/R5 |
| B | `_core_loop_v2_activity_task_recap` | `scenes/MainGame.gd:2836–2857` | 22 | R2/R3/R5 |
| B | `_core_loop_v2_recap_list_card` | `scenes/MainGame.gd:2859–2873` | 15 | R2/R3/R5 |
| B | `_core_loop_v2_temptation_recap` | `scenes/MainGame.gd:2875–2895` | 21 | R2/R3/R5 |
| B | `_core_loop_v2_initiative_recap` | `scenes/MainGame.gd:2897–2934` | 38 | R2/R3/R5 |
| B | `_core_loop_v2_final_decline_messages` | `scenes/MainGame.gd:2936–2949` | 14 | R2/R3/R5 |
| B | `_core_loop_v2_obligation_label` | `scenes/MainGame.gd:2951–2984` | 34 | R2/R3/R5 |
| B | `_core_loop_v2_unresolved_recap` | `scenes/MainGame.gd:2986–3118` | 133 | R2/R3/R5 |
| B | `_core_loop_v2_city_work_sample_expired` | `scenes/MainGame.gd:3120–3202` | 83 | R2/R3/R5 |
| B | `_core_loop_v2_autosave_completion` | `scenes/MainGame.gd:3204–3205` | 2 | R2/R3/R5 |
| B | `_core_loop_v2_autosave_durable_state` | `scenes/MainGame.gd:3207–3216` | 10 | R2/R3/R5 |
| B | `_core_loop_v2_completion_obligation_rows` | `scenes/MainGame.gd:3218–3259` | 42 | R2/R3/R5 |
| B | `_core_loop_v2_completion_hero_copy` | `scenes/MainGame.gd:3261–3333` | 73 | R2/R3/R5 |
| B | `_core_loop_v2_completion_month_missed` | `scenes/MainGame.gd:3335–3376` | 42 | R2/R3/R5 |
| B | `_core_loop_v2_completion_month_event_names` | `scenes/MainGame.gd:3378–3422` | 45 | R2/R3/R5 |
| B | `_core_loop_v2_completion_financial_rung_label` | `scenes/MainGame.gd:3424–3454` | 31 | R2/R3/R5 |
| B | `_core_loop_v2_condition_metric` | `scenes/MainGame.gd:3456–3493` | 38 | R2/R3/R5 |
| B | `_core_loop_v2_completion_boundary_copy` | `scenes/MainGame.gd:3495–3513` | 19 | R2/R3/R5 |
| B | `_core_loop_v2_completion_view_model` | `scenes/MainGame.gd:3515–3742` | 228 | R2/R3/R5 |
| B | `_core_loop_v2_clear_terminal_visual_layers` | `scenes/MainGame.gd:3744–3762` | 19 | R2/R3/R5 |
| B | `_core_loop_v2_open_completion_surface` | `scenes/MainGame.gd:3764–3811` | 48 | R2/R3/R5 |
| B | `_core_loop_v2_retry_completion_autosave` | `scenes/MainGame.gd:3813–3833` | 21 | R2/R3/R5 |
| B | `_core_loop_v2_show_completion` | `scenes/MainGame.gd:3835–4184` | 350 | R2/R3/R5 |
| B | `_core_loop_v2_return_to_title` | `scenes/MainGame.gd:4186–4200` | 15 | R2/R3/R5 |
| B | `_core_loop_v2_finish_action_week` | `scenes/MainGame.gd:4202–4235` | 34 | R2/R3/R5 |
| B | `_core_loop_v2_handoff_story_owned_action_result` | `scenes/MainGame.gd:4241–4260` | 20 | R2/R3/R5 |
| B | `_core_loop_v2_restore_action_result` | `scenes/MainGame.gd:4262–4302` | 41 | R2/R3/R5 |
| B | `_core_loop_v2_economy_snapshot` | `scenes/MainGame.gd:4304–4338` | 35 | R2/R3/R5 |
| B | `_core_loop_v2_cash_metric` | `scenes/MainGame.gd:4340–4360` | 21 | R2/R3/R5 |
| B | `_core_loop_v2_show_month_summary` | `scenes/MainGame.gd:4362–4529` | 168 | R2/R3/R5 |
| B | `_core_loop_v2_acknowledge_month_summary` | `scenes/MainGame.gd:4531–4539` | 9 | R2/R3/R5 |
| B | `_core_loop_v2_advance_completed_week` | `scenes/MainGame.gd:4541–4643` | 103 | R2/R3/R5 |
| D | `_build_ap_commit_layer` | `scenes/MainGame.gd:5492–5498` | 7 | R2/R4 |
| D | `_hide_ap_action_commit` | `scenes/MainGame.gd:5500–5504` | 5 | R2/R5: 실제 본편 경마 :18351 및 엔딩 :21384 |
| D | `_finish_ap_action_commit` | `scenes/MainGame.gd:5506–5511` | 6 | R2/R5: 공용 hide 호출 :5504 |
| B | `_show_ap_action_commit` | `scenes/MainGame.gd:5513–5658` | 146 | R2/R3/R5 |
| A | `_goal_sep` | `scenes/MainGame.gd:6575–6578` | 4 | R10 |
| D | `_core_loop_v2_hyunsu_result_evidence` | `scenes/MainGame.gd:7177–7225` | 49 | R2/R4 |
| B | `_upcoming_arc_foreshadow_line` | `scenes/MainGame.gd:8950–8985` | 36 | R6 |
| B | `_choose` | `scenes/MainGame.gd:9313–9347` | 35 | R6 |
| B | `_show_result` | `scenes/MainGame.gd:9349–9394` | 46 | R6 |
| B | `_render_event` | `scenes/MainGame.gd:9597–9633` | 37 | R6 |
| B | `_reveal_choices` | `scenes/MainGame.gd:9645–9734` | 90 | R6 |
| D | `_ap_bonus_amount` | `scenes/MainGame.gd:9777–9778` | 2 | R2/R4 |
| D | `_ap_status_text` | `scenes/MainGame.gd:9780–9788` | 9 | R2/R4 |
| B | `_ap_remaining_text` | `scenes/MainGame.gd:9790–9801` | 12 | R2/R3/R5 |
| D | `_refresh_all` | `scenes/MainGame.gd:9803–9867` | 65 | R2/R4 |
| B | `_animate_ap_refill` | `scenes/MainGame.gd:10180–10200` | 21 | R2/R3/R5 |
| D | `_render_ap_actions owner gate` | `scenes/MainGame.gd:10796–10798` | 3 | R2 |
| B | `_render_ap_actions AP body` | `scenes/MainGame.gd:10799–10934` | 136 | R2/R3 |
| B | `_ap_recent_action_line` | `scenes/MainGame.gd:11023–11037` | 15 | R2/R3/R5 |
| B | `_apply_ap_focus_routes` | `scenes/MainGame.gd:11039–11064` | 26 | R2/R3/R5 |
| B | `_ap_focus_restore_button` | `scenes/MainGame.gd:11066–11075` | 10 | R2/R3/R5 |
| B | `_bind_ap_hover_focus` | `scenes/MainGame.gd:11077–11089` | 13 | R2/R3/R5 |
| B | `_ap_grid_focus_neighbor` | `scenes/MainGame.gd:11091–11118` | 28 | R2/R3/R5 |
| B | `_add_ap_controller_hint_strip` | `scenes/MainGame.gd:11120–11166` | 47 | R2/R3/R5 |
| B | `_add_week_ap_slots` | `scenes/MainGame.gd:11708–11742` | 35 | R2/R3/R5 |
| B | `_ap_act_index` | `scenes/MainGame.gd:12135–12145` | 11 | R2/R3/R5 |
| B | `_ap_act_info` | `scenes/MainGame.gd:12147–12183` | 37 | R2/R3/R5 |
| A | `_ap_act_line` | `scenes/MainGame.gd:12185–12191` | 7 | R10 |
| B | `_begin_ap_action_board` | `scenes/MainGame.gd:13600–13611` | 12 | R2/R3/R5 |
| B | `_add_ap_section_header` | `scenes/MainGame.gd:13652–13706` | 55 | R2/R3/R5 |
| B | `_ap_people_pressure_subtitle` | `scenes/MainGame.gd:13886–13904` | 19 | R2/R3/R5 |
| B | `_ap_people_pressure_accent` | `scenes/MainGame.gd:13906–13914` | 9 | R2/R3/R5 |
| B | `_ap_job_hunt_title` | `scenes/MainGame.gd:13946–13949` | 4 | R2/R3/R5 |
| B | `_ap_job_hunt_subtitle` | `scenes/MainGame.gd:13951–13954` | 4 | R2/R3/R5 |
| B | `_is_ap_commit_function` | `scenes/MainGame.gd:14120–14132` | 13 | R2/R3/R5 |
| B | `_pulse_ap_action_card` | `scenes/MainGame.gd:14134–14147` | 14 | R2/R3/R5 |
| B | `_play_ap_commit_feedback` | `scenes/MainGame.gd:14149–14151` | 3 | R2/R3/R5 |
| B | `_run_ap_action_from_button` | `scenes/MainGame.gd:14198–14228` | 31 | R2/R3/R5 |
| B | `_next_ap_rail_label` | `scenes/MainGame.gd:14406–14408` | 3 | R2/R3/R5 |
| B | `_animate_ap_action_card` | `scenes/MainGame.gd:14410–14419` | 10 | R2/R3/R5 |
| B | `_ap_action_preview` | `scenes/MainGame.gd:14421–14472` | 52 | R2/R3/R5 |
| B | `_make_ap_board_card` | `scenes/MainGame.gd:14474–14639` | 166 | R2/R3/R5 |
| B | `_ap_study` | `scenes/MainGame.gd:16391–16422` | 32 | R2/R3/R5 |
| B | `_ap_study_commit` | `scenes/MainGame.gd:16517–16572` | 56 | R2/R3/R5 |
| B | `_ap_invest` | `scenes/MainGame.gd:16574–16578` | 5 | R2/R3/R5 |
| B | `_ap_job_hunt` | `scenes/MainGame.gd:16580–16593` | 14 | R2/R3/R5 |
| B | `_ap_side_job` | `scenes/MainGame.gd:16632–16636` | 5 | R2/R3/R5 |
| B | `_on_aruba_closed` | `scenes/MainGame.gd:16638–16716` | 79 | R2/R3/R5 |
| B | `_ap_save_money` | `scenes/MainGame.gd:16748–16775` | 28 | R2/R3/R5 |
| B | `_ap_network` | `scenes/MainGame.gd:16777–16799` | 23 | R2/R3/R5 |
| B | `_ap_date` | `scenes/MainGame.gd:16802–16876` | 75 | R2/R3/R5 |
| B | `_ap_give_gift` | `scenes/MainGame.gd:17667–17704` | 38 | R2/R3/R5 |
| B | `_ap_contact_person` | `scenes/MainGame.gd:17741–17779` | 39 | R2/R3/R5 |
| D | `_open_racetrack` | `scenes/MainGame.gd:18260–18270` | 11 | R2/R4 |
| D | `_on_racetrack_closed` | `scenes/MainGame.gd:18272–18297` | 26 | R2/R4 |
| B | `_ap_selfdev` | `scenes/MainGame.gd:18403–18404` | 2 | R2/R3/R5 |
| B | `_ap_free_time` | `scenes/MainGame.gd:18406–18413` | 8 | R2/R3/R5 |
| B | `_ap_vignette` | `scenes/MainGame.gd:18416–18443` | 28 | R2/R3/R5 |
| A | `_ap_result_display_effects` | `scenes/MainGame.gd:18503–18518` | 16 | R10 |
| A | `_ap_result_feedback_card` | `scenes/MainGame.gd:18523–18525` | 3 | R10 |
| B | `_ap_startup_work` | `scenes/MainGame.gd:18569–18587` | 19 | R2/R3/R5 |
| B | `_ap_create_content` | `scenes/MainGame.gd:18589–18614` | 26 | R2/R3/R5 |
| B | `_ap_write_resume` | `scenes/MainGame.gd:18616–18625` | 10 | R2/R3/R5 |
| B | `_ap_interview_prep` | `scenes/MainGame.gd:18627–18632` | 6 | R2/R3/R5 |
| B | `_on_job_hunt_closed` | `scenes/MainGame.gd:18634–18715` | 82 | R2/R3/R5 |
| B | `_core_loop_v2_open_fresh_w1_send_confirmation` | `scenes/MainGame.gd:18717–18733` | 17 | R2/R3/R5 |
| B | `_core_loop_v2_send_fresh_w1_application` | `scenes/MainGame.gd:18735–18761` | 27 | R2/R3/R5 |
| B | `_ap_move_housing` | `scenes/MainGame.gd:18763–18791` | 29 | R2/R3/R5 |
| B | `_ap_deep_study` | `scenes/MainGame.gd:18801–18815` | 15 | R2/R3/R5 |
| B | `_ap_market_analysis` | `scenes/MainGame.gd:18817–18841` | 25 | R2/R3/R5 |
| B | `_ap_vip_network` | `scenes/MainGame.gd:18926–18958` | 33 | R2/R3/R5 |
| A | `_demo_record_separator` | `scenes/MainGame.gd:21317–21320` | 4 | R10 |
| B | `_get_ap_pattern_comment` | `scenes/MainGame.gd:23638–23677` | 40 | R2/R3/R5 |
| A | `_hint_box` | `scenes/MainGame.gd:24165–24175` | 11 | R10 |
| A | `_start_brief_panel` | `scenes/StartMenu.gd:1578–1610` | 33 | R10 |
| A | `_start_brief_row` | `scenes/StartMenu.gd:1612–1636` | 25 | R10 |

</details>

### scenes/CoreLoopPlanner.gd

<details>
<summary>132 항목</summary>

| 분류 | 함수·키 | 파일:줄 | 줄 수 | 근거·등록 |
| --- | --- | --- | ---: | --- |
| B? | `_ready` | `scenes/CoreLoopPlanner.gd:102–115` | 14 | R5 |
| B? | `open` | `scenes/CoreLoopPlanner.gd:117–201` | 85 | R5 |
| B? | `close` | `scenes/CoreLoopPlanner.gd:202–216` | 15 | R5 |
| B? | `_process` | `scenes/CoreLoopPlanner.gd:219–228` | 10 | R5 |
| B? | `schedule_snapshot` | `scenes/CoreLoopPlanner.gd:230–231` | 2 | R5 |
| B? | `routine_snapshot` | `scenes/CoreLoopPlanner.gd:233–234` | 2 | R5 |
| B? | `episode_selection_mode` | `scenes/CoreLoopPlanner.gd:236–237` | 2 | R5 |
| B? | `episode_commitment_snapshot` | `scenes/CoreLoopPlanner.gd:239–240` | 2 | R5 |
| B? | `review_pending` | `scenes/CoreLoopPlanner.gd:242–243` | 2 | R5 |
| B? | `read_only_plan` | `scenes/CoreLoopPlanner.gd:245–246` | 2 | R5 |
| B? | `armed_offer_id` | `scenes/CoreLoopPlanner.gd:248–249` | 2 | R5 |
| B? | `placement_error` | `scenes/CoreLoopPlanner.gd:251–252` | 2 | R5 |
| B? | `focus_offer` | `scenes/CoreLoopPlanner.gd:254–269` | 16 | R5 |
| B? | `_dictionary_copy` | `scenes/CoreLoopPlanner.gd:271–272` | 2 | R5 |
| B? | `assign_offer_to_week` | `scenes/CoreLoopPlanner.gd:274–296` | 23 | R5 |
| B? | `select_routine` | `scenes/CoreLoopPlanner.gd:298–320` | 23 | R5 |
| B? | `unassign_week` | `scenes/CoreLoopPlanner.gd:322–335` | 14 | R5 |
| B? | `_build_ui` | `scenes/CoreLoopPlanner.gd:337–631` | 295 | R5 |
| B? | `_apply_responsive_layout` | `scenes/CoreLoopPlanner.gd:634–711` | 78 | R5 |
| B? | `_request_communication` | `scenes/CoreLoopPlanner.gd:714–715` | 2 | R5 |
| B? | `_open_routine_editor` | `scenes/CoreLoopPlanner.gd:718–729` | 12 | R5 |
| B? | `_rebuild` | `scenes/CoreLoopPlanner.gd:732–800` | 69 | R5 |
| B? | `_rebuild_episode_selection_surface` | `scenes/CoreLoopPlanner.gd:803–843` | 41 | R5 |
| B? | `_episode_selection_count` | `scenes/CoreLoopPlanner.gd:846–848` | 3 | R5 |
| B? | `_episode_surface_offer_ids` | `scenes/CoreLoopPlanner.gd:851–860` | 10 | R5 |
| B? | `_episode_decision_text` | `scenes/CoreLoopPlanner.gd:863–865` | 3 | R5 |
| B? | `_rebuild_episode_offer_grid` | `scenes/CoreLoopPlanner.gd:868–891` | 24 | R5 |
| B? | `_refresh_episode_selection_surface` | `scenes/CoreLoopPlanner.gd:894–941` | 48 | R5 |
| B? | `_episode_offer_focused` | `scenes/CoreLoopPlanner.gd:944–949` | 6 | R5 |
| B? | `_toggle_episode_offer` | `scenes/CoreLoopPlanner.gd:952–971` | 20 | R5 |
| B? | `_undo_last_episode_offer` | `scenes/CoreLoopPlanner.gd:974–986` | 13 | R5 |
| B? | `_sync_episode_schedule` | `scenes/CoreLoopPlanner.gd:989–1001` | 13 | R5 |
| B? | `_episode_plan_ready` | `scenes/CoreLoopPlanner.gd:1004–1010` | 7 | R5 |
| B? | `_refresh_episode_detail` | `scenes/CoreLoopPlanner.gd:1013–1027` | 15 | R5 |
| B? | `_rebuild_episode_timeline` | `scenes/CoreLoopPlanner.gd:1030–1062` | 33 | R5 |
| B? | `_connect_episode_focus_neighbors` | `scenes/CoreLoopPlanner.gd:1065–1106` | 42 | R5 |
| B? | `_connect_non_calendar_focus_neighbors` | `scenes/CoreLoopPlanner.gd:1109–1125` | 17 | R5 |
| B? | `_connect_read_only_focus_neighbors` | `scenes/CoreLoopPlanner.gd:1128–1204` | 77 | R5 |
| B? | `_refresh_step_rail` | `scenes/CoreLoopPlanner.gd:1207–1267` | 61 | R5 |
| B? | `_schedule_choices_valid` | `scenes/CoreLoopPlanner.gd:1270–1276` | 7 | R5 |
| B? | `_filled_week_count` | `scenes/CoreLoopPlanner.gd:1279–1285` | 7 | R5 |
| B? | `_routine_choice_count` | `scenes/CoreLoopPlanner.gd:1288–1297` | 10 | R5 |
| B? | `_routine_choices_valid` | `scenes/CoreLoopPlanner.gd:1300–1301` | 2 | R5 |
| B? | `_plan_blocker_short` | `scenes/CoreLoopPlanner.gd:1304–1351` | 48 | R5 |
| B? | `_plan_blocker_short_english` | `scenes/CoreLoopPlanner.gd:1354–1388` | 35 | R5 |
| B? | `_planner_copy` | `scenes/CoreLoopPlanner.gd:1390–1391` | 2 | R5 |
| B? | `_active_navigation_control` | `scenes/CoreLoopPlanner.gd:1394–1401` | 8 | R5 |
| B? | `_connect_header_focus_neighbors` | `scenes/CoreLoopPlanner.gd:1404–1428` | 25 | R5 |
| B? | `_communication_badge_count` | `scenes/CoreLoopPlanner.gd:1431–1440` | 10 | R5 |
| B? | `_rebuild_calendar` | `scenes/CoreLoopPlanner.gd:1443–1487` | 45 | R5 |
| B? | `_refresh_calendar` | `scenes/CoreLoopPlanner.gd:1490–1565` | 76 | R5 |
| B? | `_refresh_calendar_detail` | `scenes/CoreLoopPlanner.gd:1568–1603` | 36 | R5 |
| B? | `_refresh_routine_strip` | `scenes/CoreLoopPlanner.gd:1606–1632` | 27 | R5 |
| B? | `_connect_calendar_focus_neighbors` | `scenes/CoreLoopPlanner.gd:1635–1714` | 80 | R5 |
| B? | `_reset_footer_focus_neighbors` | `scenes/CoreLoopPlanner.gd:1717–1728` | 12 | R5 |
| B? | `_rebuild_read_only_surface` | `scenes/CoreLoopPlanner.gd:1731–1746` | 16 | R5 |
| B? | `_build_status_surface` | `scenes/CoreLoopPlanner.gd:1749–1803` | 55 | R5 |
| B? | `_investment_unlocked` | `scenes/CoreLoopPlanner.gd:1806–1811` | 6 | R5 |
| B? | `_investment_holding_copy` | `scenes/CoreLoopPlanner.gd:1814–1831` | 18 | R5 |
| B? | `_investment_market_copy` | `scenes/CoreLoopPlanner.gd:1834–1848` | 15 | R5 |
| B? | `_discovered_place_names` | `scenes/CoreLoopPlanner.gd:1851–1860` | 10 | R5 |
| B? | `_build_people_surface` | `scenes/CoreLoopPlanner.gd:1863–1885` | 23 | R5 |
| B? | `_build_record_surface` | `scenes/CoreLoopPlanner.gd:1888–1950` | 63 | R5 |
| B? | `_build_routine_surface` | `scenes/CoreLoopPlanner.gd:1953–2045` | 93 | R5 |
| B? | `_read_only_row` | `scenes/CoreLoopPlanner.gd:2048–2070` | 23 | R5 |
| B? | `_register_read_only_focus_control` | `scenes/CoreLoopPlanner.gd:2073–2081` | 9 | R5 |
| B? | `_set_read_only_focus_state` | `scenes/CoreLoopPlanner.gd:2084–2091` | 8 | R5 |
| B? | `_restore_focus_after_rebuild` | `scenes/CoreLoopPlanner.gd:2094–2122` | 29 | R5 |
| B? | `_current_focus_key` | `scenes/CoreLoopPlanner.gd:2125–2151` | 27 | R5 |
| B? | `_restore_focus_key` | `scenes/CoreLoopPlanner.gd:2154–2181` | 28 | R5 |
| B? | `_assign_offer` | `scenes/CoreLoopPlanner.gd:2184–2211` | 28 | R5 |
| B? | `_select_week` | `scenes/CoreLoopPlanner.gd:2213–2261` | 49 | R5 |
| B? | `_offer_focused` | `scenes/CoreLoopPlanner.gd:2263–2277` | 15 | R5 |
| B? | `_week_focused` | `scenes/CoreLoopPlanner.gd:2279–2288` | 10 | R5 |
| B? | `_clear_placement_intent` | `scenes/CoreLoopPlanner.gd:2290–2296` | 7 | R5 |
| B? | `_focus_week_button` | `scenes/CoreLoopPlanner.gd:2299–2304` | 6 | R5 |
| B? | `_focus_next_offer_or_confirm` | `scenes/CoreLoopPlanner.gd:2307–2329` | 23 | R5 |
| B? | `_cancel_placement_and_restore_focus` | `scenes/CoreLoopPlanner.gd:2332–2340` | 9 | R5 |
| B? | `_focused_week` | `scenes/CoreLoopPlanner.gd:2343–2348` | 6 | R5 |
| B? | `_on_confirm_gui_input` | `scenes/CoreLoopPlanner.gd:2351–2366` | 16 | R5 |
| B? | `_commit_plan` | `scenes/CoreLoopPlanner.gd:2369–2401` | 33 | R5 |
| B? | `_commit_episode_selection` | `scenes/CoreLoopPlanner.gd:2404–2429` | 26 | R5 |
| B? | `_switch_tab` | `scenes/CoreLoopPlanner.gd:2431–2445` | 15 | R5 |
| B? | `_open_info_view` | `scenes/CoreLoopPlanner.gd:2448–2459` | 12 | R5 |
| B? | `_switch_workflow_step` | `scenes/CoreLoopPlanner.gd:2462–2474` | 13 | R5 |
| B? | `_cycle_step` | `scenes/CoreLoopPlanner.gd:2477–2481` | 5 | R5 |
| B? | `_communication_shortcut_pressed` | `scenes/CoreLoopPlanner.gd:2483–2492` | 10 | R5 |
| B? | `_handle_episode_input` | `scenes/CoreLoopPlanner.gd:2495–2520` | 26 | R5 |
| B? | `_unhandled_input` | `scenes/CoreLoopPlanner.gd:2522–2582` | 61 | R5 |
| B? | `_refresh_footer` | `scenes/CoreLoopPlanner.gd:2584–2744` | 161 | R5 |
| B? | `_refresh_episode_footer` | `scenes/CoreLoopPlanner.gd:2747–2784` | 38 | R5 |
| B? | `_fit_status_label_height` | `scenes/CoreLoopPlanner.gd:2786–2791` | 6 | R5 |
| B? | `_placement_error_text` | `scenes/CoreLoopPlanner.gd:2793–2819` | 27 | R5 |
| B? | `_plan_error_text` | `scenes/CoreLoopPlanner.gd:2821–2861` | 41 | R5 |
| B? | `_begin_commit_review` | `scenes/CoreLoopPlanner.gd:2863–2876` | 14 | R5 |
| B? | `_cancel_commit_review` | `scenes/CoreLoopPlanner.gd:2878–2886` | 9 | R5 |
| B? | `_scheduled_commitment_lines` | `scenes/CoreLoopPlanner.gd:2888–2907` | 20 | R5 |
| B? | `_unchosen_offer_ids` | `scenes/CoreLoopPlanner.gd:2909–2914` | 6 | R5 |
| B? | `_unchosen_offer_lines` | `scenes/CoreLoopPlanner.gd:2916–2924` | 9 | R5 |
| B? | `_selected_offer_count` | `scenes/CoreLoopPlanner.gd:2926–2931` | 6 | R5 |
| B? | `_first_open_week` | `scenes/CoreLoopPlanner.gd:2933–2938` | 6 | R5 |
| B? | `_scheduled_week_for_bundle` | `scenes/CoreLoopPlanner.gd:2941–2945` | 5 | R5 |
| B? | `_first_open_week_for_bundle` | `scenes/CoreLoopPlanner.gd:2947–2954` | 8 | R5 |
| B? | `_first_replaceable_week_for_bundle` | `scenes/CoreLoopPlanner.gd:2956–2962` | 7 | R5 |
| B? | `_localized` | `scenes/CoreLoopPlanner.gd:2964–2967` | 4 | R5 |
| B? | `_english_copy` | `scenes/CoreLoopPlanner.gd:2969–2971` | 3 | R5 |
| B? | `_routine_effect_copy` | `scenes/CoreLoopPlanner.gd:2973–3004` | 32 | R5 |
| B? | `_contact_method` | `scenes/CoreLoopPlanner.gd:3006–3031` | 26 | R5 |
| B? | `_contact_method_copy` | `scenes/CoreLoopPlanner.gd:3034–3057` | 24 | R5 |
| B? | `_bundle_completed` | `scenes/CoreLoopPlanner.gd:3060–3063` | 4 | R5 |
| B? | `_has_relationship_memory` | `scenes/CoreLoopPlanner.gd:3065–3074` | 10 | R5 |
| B? | `_daeun_name_known` | `scenes/CoreLoopPlanner.gd:3076–3083` | 8 | R5 |
| B? | `_jiyeon_name_known` | `scenes/CoreLoopPlanner.gd:3085–3089` | 5 | R5 |
| B? | `_character_name` | `scenes/CoreLoopPlanner.gd:3091–3111` | 21 | R5 |
| B? | `_relationship_copy` | `scenes/CoreLoopPlanner.gd:3113–3316` | 204 | R5 |
| B? | `_section_title` | `scenes/CoreLoopPlanner.gd:3318–3321` | 4 | R5 |
| B? | `_offer_surface_kind` | `scenes/CoreLoopPlanner.gd:3324–3342` | 19 | R5 |
| B? | `_offer_kind_label` | `scenes/CoreLoopPlanner.gd:3345–3362` | 18 | R5 |
| B? | `_offer_kind_color` | `scenes/CoreLoopPlanner.gd:3365–3377` | 13 | R5 |
| B? | `_offer_kind_icon` | `scenes/CoreLoopPlanner.gd:3380–3393` | 14 | R5 |
| B? | `_apply_offer_style` | `scenes/CoreLoopPlanner.gd:3396–3412` | 17 | R5 |
| B? | `_apply_week_style` | `scenes/CoreLoopPlanner.gd:3415–3434` | 20 | R5 |
| B? | `_label` | `scenes/CoreLoopPlanner.gd:3436–3444` | 9 | R5 |
| B? | `_button` | `scenes/CoreLoopPlanner.gd:3446–3454` | 9 | R5 |
| B? | `_set_button_disabled` | `scenes/CoreLoopPlanner.gd:3457–3459` | 3 | R5 |
| B? | `_focus_on_hover` | `scenes/CoreLoopPlanner.gd:3462–3468` | 7 | R5 |
| B? | `_apply_button_style` | `scenes/CoreLoopPlanner.gd:3470–3487` | 18 | R5 |
| B? | `_panel_style` | `scenes/CoreLoopPlanner.gd:3489–3499` | 11 | R5 |
| B? | `_clear_children` | `scenes/CoreLoopPlanner.gd:3501–3504` | 4 | R5 |
| B? | `_on_language_changed` | `scenes/CoreLoopPlanner.gd:3506–3508` | 3 | R5 |
| D | `preload/선언·주석/공백 등 위 함수 범위의 보집합` | `scenes/CoreLoopPlanner.gd` 위 범위 외 | 305 | R4/R5: 파일 의존성 |
| D | `스크립트 UID` | `scenes/CoreLoopPlanner.gd.uid:1` | 1 | R5: 의존 스크립트 동반 |

</details>

### scenes/SeoulCycleBoard.gd

<details>
<summary>101 항목</summary>

| 분류 | 함수·키 | 파일:줄 | 줄 수 | 근거·등록 |
| --- | --- | --- | ---: | --- |
| B? | `_ready` | `scenes/SeoulCycleBoard.gd:94–112` | 19 | R5 |
| B? | `open` | `scenes/SeoulCycleBoard.gd:115–147` | 33 | R5 |
| B? | `refresh` | `scenes/SeoulCycleBoard.gd:150–186` | 37 | R5 |
| B? | `show_error` | `scenes/SeoulCycleBoard.gd:189–196` | 8 | R5 |
| B? | `close` | `scenes/SeoulCycleBoard.gd:199–215` | 17 | R5 |
| B? | `is_open` | `scenes/SeoulCycleBoard.gd:218–219` | 2 | R5 |
| B? | `_unhandled_input` | `scenes/SeoulCycleBoard.gd:222–239` | 18 | R5 |
| B? | `_build_ui` | `scenes/SeoulCycleBoard.gd:242–422` | 181 | R5 |
| B? | `_rebuild_entities` | `scenes/SeoulCycleBoard.gd:425–456` | 32 | R5 |
| B? | `_create_node_button` | `scenes/SeoulCycleBoard.gd:459–529` | 71 | R5 |
| B? | `_create_effort_button` | `scenes/SeoulCycleBoard.gd:532–577` | 46 | R5 |
| B? | `_refresh_surface` | `scenes/SeoulCycleBoard.gd:580–617` | 38 | R5 |
| B? | `_refresh_node_content` | `scenes/SeoulCycleBoard.gd:620–663` | 44 | R5 |
| B? | `_refresh_die_content` | `scenes/SeoulCycleBoard.gd:666–683` | 18 | R5 |
| B? | `_refresh_trigger_candidate_surface` | `scenes/SeoulCycleBoard.gd:686–727` | 42 | R5 |
| B? | `_create_trigger_candidate_button` | `scenes/SeoulCycleBoard.gd:730–746` | 17 | R5 |
| B? | `_refresh_trigger_candidate_states` | `scenes/SeoulCycleBoard.gd:749–781` | 33 | R5 |
| B? | `_refresh_visual_states` | `scenes/SeoulCycleBoard.gd:784–846` | 63 | R5 |
| B? | `_refresh_preview` | `scenes/SeoulCycleBoard.gd:849–958` | 110 | R5 |
| B? | `_repeat_allocation_progress_line` | `scenes/SeoulCycleBoard.gd:961–965` | 5 | R5 |
| B? | `_refresh_preview_geometry_if_ready` | `scenes/SeoulCycleBoard.gd:968–972` | 5 | R5 |
| B? | `_refresh_commit_state` | `scenes/SeoulCycleBoard.gd:975–1011` | 37 | R5 |
| B? | `_refresh_world_clock` | `scenes/SeoulCycleBoard.gd:1014–1037` | 24 | R5 |
| B? | `_refresh_hint` | `scenes/SeoulCycleBoard.gd:1040–1049` | 10 | R5 |
| B? | `_on_die_pressed` | `scenes/SeoulCycleBoard.gd:1052–1070` | 19 | R5 |
| B? | `_on_node_pressed` | `scenes/SeoulCycleBoard.gd:1073–1102` | 30 | R5 |
| B? | `_on_trigger_candidate_pressed` | `scenes/SeoulCycleBoard.gd:1105–1115` | 11 | R5 |
| B? | `_on_commit_pressed` | `scenes/SeoulCycleBoard.gd:1118–1133` | 16 | R5 |
| B? | `_cancel_or_close` | `scenes/SeoulCycleBoard.gd:1136–1182` | 47 | R5 |
| B? | `_on_focus_entered` | `scenes/SeoulCycleBoard.gd:1185–1198` | 14 | R5 |
| B? | `_on_focus_exited` | `scenes/SeoulCycleBoard.gd:1201–1211` | 11 | R5 |
| B? | `_on_mouse_entered` | `scenes/SeoulCycleBoard.gd:1214–1216` | 3 | R5 |
| B? | `_on_language_changed` | `scenes/SeoulCycleBoard.gd:1219–1222` | 4 | R5 |
| B? | `_on_input_mode_changed` | `scenes/SeoulCycleBoard.gd:1225–1227` | 3 | R5 |
| B? | `_focus_after_open` | `scenes/SeoulCycleBoard.gd:1230–1241` | 12 | R5 |
| B? | `_restore_focus_after_refresh` | `scenes/SeoulCycleBoard.gd:1244–1263` | 20 | R5 |
| B? | `_focus_first_available_die` | `scenes/SeoulCycleBoard.gd:1266–1272` | 7 | R5 |
| B? | `_focus_first_available_node` | `scenes/SeoulCycleBoard.gd:1275–1282` | 8 | R5 |
| B? | `_focus_first_trigger_candidate` | `scenes/SeoulCycleBoard.gd:1285–1290` | 6 | R5 |
| B? | `_ensure_trigger_candidate_visible` | `scenes/SeoulCycleBoard.gd:1293–1302` | 10 | R5 |
| B? | `_connect_focus_neighbors` | `scenes/SeoulCycleBoard.gd:1305–1364` | 60 | R5 |
| B? | `_set_neighbors` | `scenes/SeoulCycleBoard.gd:1367–1378` | 12 | R5 |
| B? | `_apply_geometry` | `scenes/SeoulCycleBoard.gd:1381–1410` | 30 | R5 |
| B? | `_apply_header_geometry` | `scenes/SeoulCycleBoard.gd:1413–1433` | 21 | R5 |
| B? | `_header_height_for_label` | `scenes/SeoulCycleBoard.gd:1436–1437` | 2 | R5 |
| B? | `_apply_map_geometry` | `scenes/SeoulCycleBoard.gd:1440–1496` | 57 | R5 |
| B? | `_apply_preview_geometry` | `scenes/SeoulCycleBoard.gd:1499–1661` | 163 | R5 |
| B? | `_preview_label_required_height` | `scenes/SeoulCycleBoard.gd:1664–1667` | 4 | R5 |
| B? | `_apply_effort_geometry` | `scenes/SeoulCycleBoard.gd:1670–1705` | 36 | R5 |
| B? | `_draw_routes` | `scenes/SeoulCycleBoard.gd:1708–1728` | 21 | R5 |
| B? | `_draw_node_overlay` | `scenes/SeoulCycleBoard.gd:1731–1748` | 18 | R5 |
| B? | `_draw_effort_overlay` | `scenes/SeoulCycleBoard.gd:1751–1770` | 20 | R5 |
| B? | `_restore_snapshot_selection` | `scenes/SeoulCycleBoard.gd:1773–1810` | 38 | R5 |
| B? | `_preview_for` | `scenes/SeoulCycleBoard.gd:1813–1851` | 39 | R5 |
| B? | `_selected_trigger_preview` | `scenes/SeoulCycleBoard.gd:1854–1889` | 36 | R5 |
| B? | `_trigger_preview_selected_candidate_id` | `scenes/SeoulCycleBoard.gd:1892–1897` | 6 | R5 |
| B? | `_trigger_preview_matches_selected_candidate` | `scenes/SeoulCycleBoard.gd:1900–1915` | 16 | R5 |
| B? | `_preview_node_id` | `scenes/SeoulCycleBoard.gd:1918–1925` | 8 | R5 |
| B? | `_effect_line` | `scenes/SeoulCycleBoard.gd:1928–1946` | 19 | R5 |
| B? | `_deadline_line` | `scenes/SeoulCycleBoard.gd:1949–1972` | 24 | R5 |
| B? | `_trigger_selection_required` | `scenes/SeoulCycleBoard.gd:1975–1976` | 2 | R5 |
| B? | `_trigger_candidates` | `scenes/SeoulCycleBoard.gd:1979–1987` | 9 | R5 |
| B? | `_selected_node_requires_trigger_choice` | `scenes/SeoulCycleBoard.gd:1990–1995` | 6 | R5 |
| B? | `_selected_trigger_candidate_is_valid` | `scenes/SeoulCycleBoard.gd:1998–2000` | 3 | R5 |
| B? | `_trigger_candidate_record_for_preview` | `scenes/SeoulCycleBoard.gd:2003–2011` | 9 | R5 |
| B? | `_node_has_empty_required_trigger_candidates` | `scenes/SeoulCycleBoard.gd:2014–2019` | 6 | R5 |
| B? | `_node_unavailable_by_id` | `scenes/SeoulCycleBoard.gd:2022–2029` | 8 | R5 |
| B? | `_node_available_by_id` | `scenes/SeoulCycleBoard.gd:2032–2033` | 2 | R5 |
| B? | `_node_unavailable` | `scenes/SeoulCycleBoard.gd:2036–2041` | 6 | R5 |
| B? | `_die_data` | `scenes/SeoulCycleBoard.gd:2044–2050` | 7 | R5 |
| B? | `_remaining_effort_count` | `scenes/SeoulCycleBoard.gd:2053–2058` | 6 | R5 |
| B? | `_base_progress` | `scenes/SeoulCycleBoard.gd:2061–2066` | 6 | R5 |
| B? | `_update_root_meta` | `scenes/SeoulCycleBoard.gd:2069–2091` | 23 | R5 |
| B? | `_selection_stage` | `scenes/SeoulCycleBoard.gd:2094–2102` | 9 | R5 |
| B? | `_normalized_snapshot` | `scenes/SeoulCycleBoard.gd:2105–2171` | 67 | R5 |
| B? | `_normalized_preview` | `scenes/SeoulCycleBoard.gd:2174–2198` | 25 | R5 |
| B? | `_normalized_trigger_candidates` | `scenes/SeoulCycleBoard.gd:2201–2222` | 22 | R5 |
| B? | `_preview_error_text` | `scenes/SeoulCycleBoard.gd:2225–2241` | 17 | R5 |
| B? | `_raw_trigger_candidate_contract_error` | `scenes/SeoulCycleBoard.gd:2244–2269` | 26 | R5 |
| B? | `_raw_trigger_candidate_list_error` | `scenes/SeoulCycleBoard.gd:2272–2294` | 23 | R5 |
| B? | `_snapshot_validation_error` | `scenes/SeoulCycleBoard.gd:2297–2352` | 56 | R5 |
| B? | `_trigger_candidate_contract_error` | `scenes/SeoulCycleBoard.gd:2355–2375` | 21 | R5 |
| B? | `_localized_contract_pair_is_complete` | `scenes/SeoulCycleBoard.gd:2378–2382` | 5 | R5 |
| B? | `_sort_node_ids` | `scenes/SeoulCycleBoard.gd:2385–2393` | 9 | R5 |
| B? | `_sort_trigger_candidates` | `scenes/SeoulCycleBoard.gd:2396–2397` | 2 | R5 |
| B? | `_localized` | `scenes/SeoulCycleBoard.gd:2400–2409` | 10 | R5 |
| B? | `_localized_board_label` | `scenes/SeoulCycleBoard.gd:2412–2423` | 12 | R5 |
| B? | `_format_money` | `scenes/SeoulCycleBoard.gd:2426–2429` | 4 | R5 |
| B? | `_signed_money` | `scenes/SeoulCycleBoard.gd:2432–2434` | 3 | R5 |
| B? | `_tr` | `scenes/SeoulCycleBoard.gd:2437–2438` | 2 | R5 |
| B? | `_safe_node_name` | `scenes/SeoulCycleBoard.gd:2441–2445` | 5 | R5 |
| B? | `_joy_button_pressed` | `scenes/SeoulCycleBoard.gd:2448–2452` | 5 | R5 |
| B? | `_visual_state` | `scenes/SeoulCycleBoard.gd:2455–2464` | 10 | R5 |
| B? | `_label` | `scenes/SeoulCycleBoard.gd:2467–2473` | 7 | R5 |
| B? | `_stat_label` | `scenes/SeoulCycleBoard.gd:2476–2484` | 9 | R5 |
| B? | `_apply_plain_button_style` | `scenes/SeoulCycleBoard.gd:2487–2496` | 10 | R5 |
| B? | `_apply_commit_style` | `scenes/SeoulCycleBoard.gd:2499–2514` | 16 | R5 |
| B? | `_panel_style` | `scenes/SeoulCycleBoard.gd:2517–2531` | 15 | R5 |
| B? | `_clear_children` | `scenes/SeoulCycleBoard.gd:2534–2536` | 3 | R5 |
| D | `preload/선언·주석/공백 등 위 함수 범위의 보집합` | `scenes/SeoulCycleBoard.gd` 위 범위 외 | 289 | R4/R5: 파일 의존성 |
| D | `스크립트 UID` | `scenes/SeoulCycleBoard.gd.uid:1` | 1 | R5: 의존 스크립트 동반 |

</details>

### scenes/CoreLoopV2Completion.gd

<details>
<summary>57 항목</summary>

| 분류 | 함수·키 | 파일:줄 | 줄 수 | 근거·등록 |
| --- | --- | --- | ---: | --- |
| B? | `_ready` | `scenes/CoreLoopV2Completion.gd:56–64` | 9 | R5 |
| B? | `open` | `scenes/CoreLoopV2Completion.gd:67–88` | 22 | R5 |
| B? | `_stabilize_open_layout` | `scenes/CoreLoopV2Completion.gd:91–100` | 10 | R5 |
| B? | `_apply_full_rect_after_rebuild` | `scenes/CoreLoopV2Completion.gd:103–115` | 13 | R5 |
| B? | `close` | `scenes/CoreLoopV2Completion.gd:118–129` | 12 | R5 |
| B? | `_exit_tree` | `scenes/CoreLoopV2Completion.gd:132–133` | 2 | R5 |
| B? | `_restore_playtest_marker_context` | `scenes/CoreLoopV2Completion.gd:136–144` | 9 | R5 |
| B? | `is_open` | `scenes/CoreLoopV2Completion.gd:147–148` | 2 | R5 |
| B? | `summary_visible` | `scenes/CoreLoopV2Completion.gd:151–152` | 2 | R5 |
| B? | `details_visible` | `scenes/CoreLoopV2Completion.gd:155–156` | 2 | R5 |
| B? | `current_page` | `scenes/CoreLoopV2Completion.gd:159–160` | 2 | R5 |
| B? | `_validate_model` | `scenes/CoreLoopV2Completion.gd:163–239` | 77 | R5 |
| B? | `_is_string_array` | `scenes/CoreLoopV2Completion.gd:242–246` | 5 | R5 |
| B? | `_ensure_built` | `scenes/CoreLoopV2Completion.gd:249–305` | 57 | R5 |
| B? | `_load_fonts` | `scenes/CoreLoopV2Completion.gd:308–320` | 13 | R5 |
| B? | `_render_summary` | `scenes/CoreLoopV2Completion.gd:323–369` | 47 | R5 |
| B? | `_build_hero` | `scenes/CoreLoopV2Completion.gd:372–416` | 45 | R5 |
| B? | `_build_outcome_receipt` | `scenes/CoreLoopV2Completion.gd:419–456` | 38 | R5 |
| B? | `_build_metric_strip` | `scenes/CoreLoopV2Completion.gd:459–489` | 31 | R5 |
| B? | `_build_trace_strip` | `scenes/CoreLoopV2Completion.gd:492–515` | 24 | R5 |
| B? | `_build_summary_footer` | `scenes/CoreLoopV2Completion.gd:518–553` | 36 | R5 |
| B? | `_show_summary` | `scenes/CoreLoopV2Completion.gd:556–565` | 10 | R5 |
| B? | `_show_details` | `scenes/CoreLoopV2Completion.gd:568–577` | 10 | R5 |
| B? | `_render_detail_page` | `scenes/CoreLoopV2Completion.gd:580–649` | 70 | R5 |
| B? | `_build_detail_rail` | `scenes/CoreLoopV2Completion.gd:652–728` | 77 | R5 |
| B? | `_add_detail_entry` | `scenes/CoreLoopV2Completion.gd:731–748` | 18 | R5 |
| B? | `_build_detail_readout` | `scenes/CoreLoopV2Completion.gd:751–763` | 13 | R5 |
| B? | `_render_detail_readout` | `scenes/CoreLoopV2Completion.gd:766–784` | 19 | R5 |
| B? | `_change_detail_page` | `scenes/CoreLoopV2Completion.gd:787–796` | 10 | R5 |
| B? | `_select_detail_row` | `scenes/CoreLoopV2Completion.gd:799–808` | 10 | R5 |
| B? | `_move_detail_row` | `scenes/CoreLoopV2Completion.gd:811–821` | 11 | R5 |
| B? | `_refresh_detail_cursor` | `scenes/CoreLoopV2Completion.gd:824–832` | 9 | R5 |
| B? | `_link_detail_focus_neighbors` | `scenes/CoreLoopV2Completion.gd:835–849` | 15 | R5 |
| B? | `_focus_summary_cta` | `scenes/CoreLoopV2Completion.gd:852–854` | 3 | R5 |
| B? | `_focus_detail_row` | `scenes/CoreLoopV2Completion.gd:857–860` | 4 | R5 |
| B? | `_on_finish_pressed` | `scenes/CoreLoopV2Completion.gd:863–873` | 11 | R5 |
| B? | `_on_input_mode_changed` | `scenes/CoreLoopV2Completion.gd:876–879` | 4 | R5 |
| B? | `_refresh_hints` | `scenes/CoreLoopV2Completion.gd:882–905` | 24 | R5 |
| B? | `_input` | `scenes/CoreLoopV2Completion.gd:908–945` | 38 | R5 |
| B? | `_unhandled_input` | `scenes/CoreLoopV2Completion.gd:948–1000` | 53 | R5 |
| B? | `_joy_button_pressed` | `scenes/CoreLoopV2Completion.gd:1003–1007` | 5 | R5 |
| B? | `_page_title` | `scenes/CoreLoopV2Completion.gd:1010–1017` | 8 | R5 |
| B? | `_month_count` | `scenes/CoreLoopV2Completion.gd:1020–1021` | 2 | R5 |
| B? | `_detail_page_count` | `scenes/CoreLoopV2Completion.gd:1024–1025` | 2 | R5 |
| B? | `_outcome_color` | `scenes/CoreLoopV2Completion.gd:1028–1035` | 8 | R5 |
| B? | `_joined_lines` | `scenes/CoreLoopV2Completion.gd:1038–1044` | 7 | R5 |
| B? | `_tr` | `scenes/CoreLoopV2Completion.gd:1047–1048` | 2 | R5 |
| B? | `_label` | `scenes/CoreLoopV2Completion.gd:1051–1075` | 25 | R5 |
| B? | `_button` | `scenes/CoreLoopV2Completion.gd:1078–1102` | 25 | R5 |
| B? | `_set_self_focus_neighbors` | `scenes/CoreLoopV2Completion.gd:1105–1112` | 8 | R5 |
| B? | `_panel_style` | `scenes/CoreLoopV2Completion.gd:1115–1124` | 10 | R5 |
| B? | `_button_style` | `scenes/CoreLoopV2Completion.gd:1127–1136` | 10 | R5 |
| B? | `_focus_style` | `scenes/CoreLoopV2Completion.gd:1139–1148` | 10 | R5 |
| B? | `_separator` | `scenes/CoreLoopV2Completion.gd:1151–1155` | 5 | R5 |
| B? | `_clear_children` | `scenes/CoreLoopV2Completion.gd:1158–1161` | 4 | R5 |
| D | `preload/선언·주석/공백 등 위 함수 범위의 보집합` | `scenes/CoreLoopV2Completion.gd` 위 범위 외 | 163 | R4/R5: 파일 의존성 |
| D | `스크립트 UID` | `scenes/CoreLoopV2Completion.gd.uid:1` | 1 | R5: 의존 스크립트 동반 |

</details>

### scenes/ArubaGame.gd

<details>
<summary>46 항목</summary>

| 분류 | 함수·키 | 파일:줄 | 줄 수 | 근거·등록 |
| --- | --- | --- | ---: | --- |
| D | `_ready` | `scenes/ArubaGame.gd:300–308` | 9 | R5 |
| B? | `_process` | `scenes/ArubaGame.gd:310–339` | 30 | R5 |
| B? | `_unhandled_input` | `scenes/ArubaGame.gd:341–353` | 13 | R5 |
| B? | `open` | `scenes/ArubaGame.gd:356–399` | 44 | R5 |
| B? | `get_base_pay` | `scenes/ArubaGame.gd:401–402` | 2 | R5 |
| B? | `is_rain_surge_shift` | `scenes/ArubaGame.gd:404–405` | 2 | R5 |
| B? | `get_last_shift_receipt` | `scenes/ArubaGame.gd:407–408` | 2 | R5 |
| B? | `_is_rain_surge_shift` | `scenes/ArubaGame.gd:410–414` | 5 | R5 |
| B? | `_clear_content` | `scenes/ArubaGame.gd:416–428` | 13 | R5 |
| D | `_build_base_ui` | `scenes/ArubaGame.gd:431–495` | 65 | R5 |
| B? | `_set_scene_surface` | `scenes/ArubaGame.gd:497–500` | 4 | R5 |
| B? | `_start_cards` | `scenes/ArubaGame.gd:505–556` | 52 | R5 |
| B? | `_show_scenario` | `scenes/ArubaGame.gd:558–575` | 18 | R5 |
| B? | `_on_cards_choice` | `scenes/ArubaGame.gd:577–588` | 12 | R5 |
| B? | `_start_convenience` | `scenes/ArubaGame.gd:593–678` | 86 | R5 |
| B? | `_conv_spawn_into` | `scenes/ArubaGame.gd:680–686` | 7 | R5 |
| B? | `_conv_build_slot_content` | `scenes/ArubaGame.gd:688–784` | 97 | R5 |
| B? | `_conv_clear_slot_panel` | `scenes/ArubaGame.gd:786–795` | 10 | R5 |
| B? | `_conv_slot_style` | `scenes/ArubaGame.gd:797–804` | 8 | R5 |
| B? | `_conv_apply_slot_style` | `scenes/ArubaGame.gd:806–835` | 30 | R5 |
| B? | `_conv_focus_slot` | `scenes/ArubaGame.gd:837–849` | 13 | R5 |
| B? | `_conv_reset_selection` | `scenes/ArubaGame.gd:851–864` | 14 | R5 |
| B? | `_conv_refresh_bar` | `scenes/ArubaGame.gd:866–879` | 14 | R5 |
| B? | `_conv_click_slot` | `scenes/ArubaGame.gd:881–893` | 13 | R5 |
| B? | `_conv_highlight_selected` | `scenes/ArubaGame.gd:895–897` | 3 | R5 |
| B? | `_conv_show_actions` | `scenes/ArubaGame.gd:899–924` | 26 | R5 |
| B? | `_conv_handle` | `scenes/ArubaGame.gd:926–969` | 44 | R5 |
| B? | `_conv_timeout` | `scenes/ArubaGame.gd:971–993` | 23 | R5 |
| B? | `_conv_free_slot` | `scenes/ArubaGame.gd:995–1016` | 22 | R5 |
| B? | `_conv_update_score_lbl` | `scenes/ArubaGame.gd:1018–1025` | 8 | R5 |
| B? | `_start_delivery` | `scenes/ArubaGame.gd:1030–1079` | 50 | R5 |
| B? | `_del_toggle` | `scenes/ArubaGame.gd:1081–1087` | 7 | R5 |
| B? | `_del_refresh_ui` | `scenes/ArubaGame.gd:1089–1171` | 83 | R5 |
| B? | `_del_confirm` | `scenes/ArubaGame.gd:1173–1203` | 31 | R5 |
| B? | `_show_result` | `scenes/ArubaGame.gd:1208–1269` | 62 | R5 |
| B? | `_on_finish` | `scenes/ArubaGame.gd:1271–1278` | 8 | R5 |
| B? | `_shift_stress_result_prose` | `scenes/ArubaGame.gd:1280–1287` | 8 | R5 |
| B? | `_shift_health_result_prose` | `scenes/ArubaGame.gd:1289–1296` | 8 | R5 |
| B? | `_customer_tag` | `scenes/ArubaGame.gd:1299–1318` | 20 | R5 |
| B? | `_make_btn` | `scenes/ArubaGame.gd:1320–1353` | 34 | R5 |
| B? | `_mini_lbl` | `scenes/ArubaGame.gd:1355–1360` | 6 | R5 |
| B? | `_fmt` | `scenes/ArubaGame.gd:1362–1363` | 2 | R5 |
| B? | `_loc` | `scenes/ArubaGame.gd:1365–1369` | 5 | R5 |
| B? | `_delivery_label` | `scenes/ArubaGame.gd:1371–1376` | 6 | R5 |
| D | `preload/선언·주석/공백 등 위 함수 범위의 보집합` | `scenes/ArubaGame.gd` 위 범위 외 | 357 | R4/R5: 파일 의존성 |
| D | `스크립트 UID` | `scenes/ArubaGame.gd.uid:1` | 1 | R5: 의존 스크립트 동반 |

</details>

### scenes/JobHuntMiniGame.gd

<details>
<summary>24 항목</summary>

| 분류 | 함수·키 | 파일:줄 | 줄 수 | 근거·등록 |
| --- | --- | --- | ---: | --- |
| D | `_ready` | `scenes/JobHuntMiniGame.gd:249–256` | 8 | R5 |
| B? | `_process` | `scenes/JobHuntMiniGame.gd:258–285` | 28 | R5 |
| B? | `open` | `scenes/JobHuntMiniGame.gd:288–331` | 44 | R5 |
| B? | `_get_questions` | `scenes/JobHuntMiniGame.gd:333–334` | 2 | R5 |
| B? | `_build_choice_layouts` | `scenes/JobHuntMiniGame.gd:336–358` | 23 | R5 |
| B? | `_choices_for_question` | `scenes/JobHuntMiniGame.gd:360–365` | 6 | R5 |
| B? | `_clear_content` | `scenes/JobHuntMiniGame.gd:367–375` | 9 | R5 |
| D | `_build_base_ui` | `scenes/JobHuntMiniGame.gd:378–431` | 54 | R5 |
| B? | `_start_common` | `scenes/JobHuntMiniGame.gd:434–485` | 52 | R5 |
| B? | `_show_question` | `scenes/JobHuntMiniGame.gd:487–536` | 50 | R5 |
| B? | `_on_choose` | `scenes/JobHuntMiniGame.gd:538–595` | 58 | R5 |
| B? | `_on_timeout` | `scenes/JobHuntMiniGame.gd:597–608` | 12 | R5 |
| B? | `_show_result` | `scenes/JobHuntMiniGame.gd:611–746` | 136 | R5 |
| B? | `_on_finish` | `scenes/JobHuntMiniGame.gd:748–752` | 5 | R5 |
| B? | `_final_stress_delta` | `scenes/JobHuntMiniGame.gd:755–756` | 2 | R5 |
| B? | `_unhandled_input` | `scenes/JobHuntMiniGame.gd:758–770` | 13 | R5 |
| B? | `_configure_horizontal_focus` | `scenes/JobHuntMiniGame.gd:772–783` | 12 | R5 |
| B? | `_make_btn` | `scenes/JobHuntMiniGame.gd:785–814` | 30 | R5 |
| B? | `_add_room_surface` | `scenes/JobHuntMiniGame.gd:816–839` | 24 | R5 |
| B? | `_make_scene_strip` | `scenes/JobHuntMiniGame.gd:841–872` | 32 | R5 |
| B? | `_add_surface_rect` | `scenes/JobHuntMiniGame.gd:874–886` | 13 | R5 |
| B? | `_loc` | `scenes/JobHuntMiniGame.gd:888–892` | 5 | R5 |
| D | `preload/선언·주석/공백 등 위 함수 범위의 보집합` | `scenes/JobHuntMiniGame.gd` 위 범위 외 | 274 | R4/R5: 파일 의존성 |
| D | `스크립트 UID` | `scenes/JobHuntMiniGame.gd.uid:1` | 1 | R5: 의존 스크립트 동반 |

</details>

### scenes/CommunicationPhone.gd

<details>
<summary>57 항목</summary>

| 분류 | 함수·키 | 파일:줄 | 줄 수 | 근거·등록 |
| --- | --- | --- | ---: | --- |
| B? | `_ready` | `scenes/CommunicationPhone.gd:63–73` | 11 | R5 |
| B? | `open` | `scenes/CommunicationPhone.gd:76–89` | 14 | R5 |
| B? | `close` | `scenes/CommunicationPhone.gd:92–101` | 10 | R5 |
| B? | `is_open` | `scenes/CommunicationPhone.gd:104–105` | 2 | R5 |
| B? | `_build_ui` | `scenes/CommunicationPhone.gd:108–253` | 146 | R5 |
| B? | `_update_geometry` | `scenes/CommunicationPhone.gd:256–302` | 47 | R5 |
| B? | `_drawer_width_for` | `scenes/CommunicationPhone.gd:305–312` | 8 | R5 |
| B? | `_rebuild` | `scenes/CommunicationPhone.gd:315–335` | 21 | R5 |
| B? | `_update_tab_copy_and_style` | `scenes/CommunicationPhone.gd:338–351` | 14 | R5 |
| B? | `_build_conversation_list` | `scenes/CommunicationPhone.gd:354–371` | 18 | R5 |
| B? | `_received_contact_offer_ids` | `scenes/CommunicationPhone.gd:374–385` | 12 | R5 |
| B? | `_contact_surface_kind` | `scenes/CommunicationPhone.gd:388–390` | 3 | R5 |
| B? | `_conversation_row` | `scenes/CommunicationPhone.gd:393–449` | 57 | R5 |
| B? | `_open_thread` | `scenes/CommunicationPhone.gd:452–462` | 11 | R5 |
| B? | `_build_thread` | `scenes/CommunicationPhone.gd:465–517` | 53 | R5 |
| B? | `_build_contact_list` | `scenes/CommunicationPhone.gd:520–532` | 13 | R5 |
| B? | `_actual_contact_ids` | `scenes/CommunicationPhone.gd:535–540` | 6 | R5 |
| B? | `_contact_row` | `scenes/CommunicationPhone.gd:543–609` | 67 | R5 |
| B? | `_contact_method` | `scenes/CommunicationPhone.gd:612–632` | 21 | R5 |
| B? | `_contact_topic_bundle` | `scenes/CommunicationPhone.gd:635–650` | 16 | R5 |
| B? | `_contact_method_copy` | `scenes/CommunicationPhone.gd:653–661` | 9 | R5 |
| B? | `_contact_action_copy` | `scenes/CommunicationPhone.gd:664–667` | 4 | R5 |
| B? | `_request_offer` | `scenes/CommunicationPhone.gd:670–674` | 5 | R5 |
| B? | `_switch_tab` | `scenes/CommunicationPhone.gd:677–682` | 6 | R5 |
| B? | `_cycle_tab` | `scenes/CommunicationPhone.gd:685–686` | 2 | R5 |
| B? | `_go_back_one_level` | `scenes/CommunicationPhone.gd:689–696` | 8 | R5 |
| B? | `_clear_thread` | `scenes/CommunicationPhone.gd:699–705` | 7 | R5 |
| B? | `_focus_after_rebuild` | `scenes/CommunicationPhone.gd:708–719` | 12 | R5 |
| B? | `_restore_return_focus` | `scenes/CommunicationPhone.gd:722–730` | 9 | R5 |
| B? | `_refresh_focus_cycle` | `scenes/CommunicationPhone.gd:733–749` | 17 | R5 |
| B? | `_collect_focusable_controls` | `scenes/CommunicationPhone.gd:752–759` | 8 | R5 |
| B? | `_first_body_button` | `scenes/CommunicationPhone.gd:762–766` | 5 | R5 |
| B? | `_find_meta_control` | `scenes/CommunicationPhone.gd:769–776` | 8 | R5 |
| B? | `_unhandled_input` | `scenes/CommunicationPhone.gd:779–808` | 30 | R5 |
| B? | `_phone_shortcut_pressed` | `scenes/CommunicationPhone.gd:811–819` | 9 | R5 |
| B? | `_on_shade_gui_input` | `scenes/CommunicationPhone.gd:822–827` | 6 | R5 |
| B? | `_play_open_reveal` | `scenes/CommunicationPhone.gd:830–845` | 16 | R5 |
| B? | `_on_language_changed` | `scenes/CommunicationPhone.gd:848–851` | 4 | R5 |
| B? | `_optional_phone_copy` | `scenes/CommunicationPhone.gd:854–857` | 4 | R5 |
| B? | `_phone_message_sender` | `scenes/CommunicationPhone.gd:860–866` | 7 | R5 |
| B? | `_phone_message_body` | `scenes/CommunicationPhone.gd:869–878` | 10 | R5 |
| B? | `_localized` | `scenes/CommunicationPhone.gd:881–884` | 4 | R5 |
| B? | `_bundle_completed` | `scenes/CommunicationPhone.gd:887–890` | 4 | R5 |
| B? | `_has_relationship_memory` | `scenes/CommunicationPhone.gd:893–902` | 10 | R5 |
| B? | `_character_name` | `scenes/CommunicationPhone.gd:905–915` | 11 | R5 |
| B? | `_avatar_panel` | `scenes/CommunicationPhone.gd:918–934` | 17 | R5 |
| B? | `_avatar_color` | `scenes/CommunicationPhone.gd:937–942` | 6 | R5 |
| B? | `_section_title` | `scenes/CommunicationPhone.gd:945–949` | 5 | R5 |
| B? | `_empty_card` | `scenes/CommunicationPhone.gd:952–971` | 20 | R5 |
| B? | `_action_button` | `scenes/CommunicationPhone.gd:974–984` | 11 | R5 |
| B? | `_icon_button` | `scenes/CommunicationPhone.gd:987–997` | 11 | R5 |
| B? | `_apply_button_style` | `scenes/CommunicationPhone.gd:1000–1018` | 19 | R5 |
| B? | `_label` | `scenes/CommunicationPhone.gd:1021–1032` | 12 | R5 |
| B? | `_rounded_style` | `scenes/CommunicationPhone.gd:1035–1047` | 13 | R5 |
| B? | `_clear_children` | `scenes/CommunicationPhone.gd:1050–1053` | 4 | R5 |
| D | `preload/선언·주석/공백 등 위 함수 범위의 보집합` | `scenes/CommunicationPhone.gd` 위 범위 외 | 170 | R4/R5: 파일 의존성 |
| D | `스크립트 UID` | `scenes/CommunicationPhone.gd.uid:1` | 1 | R5: 의존 스크립트 동반 |

</details>

### scenes/CommitmentTask.gd

<details>
<summary>62 항목</summary>

| 분류 | 함수·키 | 파일:줄 | 줄 수 | 근거·등록 |
| --- | --- | --- | ---: | --- |
| B? | `_ready` | `scenes/CommitmentTask.gd:60–74` | 15 | R5 |
| B? | `open` | `scenes/CommitmentTask.gd:77–114` | 38 | R5 |
| B? | `close_committed` | `scenes/CommitmentTask.gd:117–137` | 21 | R5 |
| B? | `is_open` | `scenes/CommitmentTask.gd:140–141` | 2 | R5 |
| B? | `_exit_tree` | `scenes/CommitmentTask.gd:144–146` | 3 | R5 |
| B? | `_unhandled_input` | `scenes/CommitmentTask.gd:149–155` | 7 | R5 |
| B? | `_undo_last_selection` | `scenes/CommitmentTask.gd:158–176` | 19 | R5 |
| B? | `_build_ui` | `scenes/CommitmentTask.gd:179–286` | 108 | R5 |
| B? | `_rebuild_targets` | `scenes/CommitmentTask.gd:289–329` | 41 | R5 |
| B? | `_refresh_all` | `scenes/CommitmentTask.gd:332–347` | 16 | R5 |
| B? | `_refresh_progress` | `scenes/CommitmentTask.gd:350–366` | 17 | R5 |
| B? | `_refresh_targets` | `scenes/CommitmentTask.gd:369–392` | 24 | R5 |
| B? | `_refresh_feedback` | `scenes/CommitmentTask.gd:395–418` | 24 | R5 |
| B? | `_refresh_resolution` | `scenes/CommitmentTask.gd:421–456` | 36 | R5 |
| B? | `_refresh_hint` | `scenes/CommitmentTask.gd:459–469` | 11 | R5 |
| B? | `_on_requirement_pressed` | `scenes/CommitmentTask.gd:472–496` | 25 | R5 |
| B? | `_on_resolution_pressed` | `scenes/CommitmentTask.gd:499–528` | 30 | R5 |
| B? | `_release_resolution_guard` | `scenes/CommitmentTask.gd:531–543` | 13 | R5 |
| B? | `_on_target_mouse_entered` | `scenes/CommitmentTask.gd:546–548` | 3 | R5 |
| B? | `_on_target_focus_entered` | `scenes/CommitmentTask.gd:551–557` | 7 | R5 |
| B? | `_on_target_focus_exited` | `scenes/CommitmentTask.gd:560–563` | 4 | R5 |
| B? | `_on_language_changed` | `scenes/CommitmentTask.gd:566–569` | 4 | R5 |
| B? | `_on_input_mode_changed` | `scenes/CommitmentTask.gd:572–574` | 3 | R5 |
| B? | `_focus_initial` | `scenes/CommitmentTask.gd:577–594` | 18 | R5 |
| B? | `_ensure_valid_focus` | `scenes/CommitmentTask.gd:597–610` | 14 | R5 |
| B? | `_queue_geometry_refresh` | `scenes/CommitmentTask.gd:613–615` | 3 | R5 |
| B? | `_apply_geometry_for_generation` | `scenes/CommitmentTask.gd:618–620` | 3 | R5 |
| B? | `_connect_focus_neighbors` | `scenes/CommitmentTask.gd:623–651` | 29 | R5 |
| B? | `_apply_geometry` | `scenes/CommitmentTask.gd:654–769` | 116 | R5 |
| B? | `_apply_target_style` | `scenes/CommitmentTask.gd:772–781` | 10 | R5 |
| B? | `_target_style` | `scenes/CommitmentTask.gd:784–792` | 9 | R5 |
| B? | `_target_marker_rect` | `scenes/CommitmentTask.gd:795–813` | 19 | R5 |
| B? | `_draw_target_marker` | `scenes/CommitmentTask.gd:816–855` | 40 | R5 |
| B? | `_refresh_target_markers` | `scenes/CommitmentTask.gd:858–865` | 8 | R5 |
| B? | `_target_station_label` | `scenes/CommitmentTask.gd:868–877` | 10 | R5 |
| B? | `_target_short_label` | `scenes/CommitmentTask.gd:880–883` | 4 | R5 |
| B? | `_play_requirement_feedback` | `scenes/CommitmentTask.gd:886–940` | 55 | R5 |
| B? | `_stop_target_feedback_tweens` | `scenes/CommitmentTask.gd:943–948` | 6 | R5 |
| B? | `_physical_output_scale` | `scenes/CommitmentTask.gd:951–961` | 11 | R5 |
| B? | `_readable_font_size` | `scenes/CommitmentTask.gd:964–966` | 3 | R5 |
| B? | `_resolution_button` | `scenes/CommitmentTask.gd:969–994` | 26 | R5 |
| B? | `_label` | `scenes/CommitmentTask.gd:997–1004` | 8 | R5 |
| B? | `_panel_style` | `scenes/CommitmentTask.gd:1007–1017` | 11 | R5 |
| B? | `_new_flat_style` | `scenes/CommitmentTask.gd:1023–1024` | 2 | R5 |
| B? | `_selected_normal_outcome` | `scenes/CommitmentTask.gd:1027–1037` | 11 | R5 |
| B? | `_omitted_requirement_id` | `scenes/CommitmentTask.gd:1040–1045` | 6 | R5 |
| B? | `_button_for_slot` | `scenes/CommitmentTask.gd:1048–1054` | 7 | R5 |
| B? | `_localized` | `scenes/CommitmentTask.gd:1057–1060` | 4 | R5 |
| B? | `_task_title` | `scenes/CommitmentTask.gd:1063–1068` | 6 | R5 |
| B? | `_overreach_prompt` | `scenes/CommitmentTask.gd:1071–1076` | 6 | R5 |
| B? | `_effect_line` | `scenes/CommitmentTask.gd:1079–1087` | 9 | R5 |
| B? | `_format_money` | `scenes/CommitmentTask.gd:1090–1091` | 2 | R5 |
| B? | `_format_signed_number` | `scenes/CommitmentTask.gd:1094–1096` | 3 | R5 |
| B? | `_restored_selection` | `scenes/CommitmentTask.gd:1099–1109` | 11 | R5 |
| B? | `_valid_spec` | `scenes/CommitmentTask.gd:1112–1193` | 82 | R5 |
| B? | `_has_localized` | `scenes/CommitmentTask.gd:1196–1198` | 3 | R5 |
| B? | `_valid_effects` | `scenes/CommitmentTask.gd:1201–1211` | 11 | R5 |
| B? | `_same_id_set` | `scenes/CommitmentTask.gd:1214–1221` | 8 | R5 |
| B? | `_canonical_id_key` | `scenes/CommitmentTask.gd:1224–1229` | 6 | R5 |
| B? | `_release_activity_ambience` | `scenes/CommitmentTask.gd:1232–1237` | 6 | R5 |
| D | `preload/선언·주석/공백 등 위 함수 범위의 보집합` | `scenes/CommitmentTask.gd` 위 범위 외 | 180 | R4/R5: 파일 의존성 |
| D | `스크립트 UID` | `scenes/CommitmentTask.gd.uid:1` | 1 | R5: 의존 스크립트 동반 |

</details>

### systems/DemoCoreLoopV2.gd

<details>
<summary>477 항목</summary>

| 분류 | 함수·키 | 파일:줄 | 줄 수 | 근거·등록 |
| --- | --- | --- | ---: | --- |
| D | `contract` | `systems/DemoCoreLoopV2.gd:335–336` | 2 | R4/R11 |
| B? | `_hyunsu_exam_contract` | `systems/DemoCoreLoopV2.gd:338–396` | 59 | R4/R11 |
| B? | `_city_result_contract` | `systems/DemoCoreLoopV2.gd:398–430` | 33 | R4/R11 |
| D | `development_cap_week` | `systems/DemoCoreLoopV2.gd:432–442` | 11 | R4/R11 |
| D | `requested` | `systems/DemoCoreLoopV2.gd:444–453` | 10 | R4/R11 |
| D | `initialize_for_run` | `systems/DemoCoreLoopV2.gd:455–463` | 9 | R4/R11 |
| B? | `begin_fresh_w1_onboarding` | `systems/DemoCoreLoopV2.gd:468–497` | 30 | R4/R11 |
| D | `fresh_w1_onboarding_snapshot` | `systems/DemoCoreLoopV2.gd:499–501` | 3 | R4/R11 |
| D | `fresh_w1_onboarding_phase` | `systems/DemoCoreLoopV2.gd:503–504` | 2 | R4/R11 |
| B? | `fresh_w1_onboarding_pending` | `systems/DemoCoreLoopV2.gd:506–508` | 3 | R4/R11 |
| B? | `_fresh_w1_onboarding_allocation_gate` | `systems/DemoCoreLoopV2.gd:510–517` | 8 | R4/R11 |
| B? | `_apply_legacy_callback_retirements` | `systems/DemoCoreLoopV2.gd:523–552` | 30 | R4/R11 |
| B? | `disable_for_run` | `systems/DemoCoreLoopV2.gd:554–562` | 9 | R4/R11 |
| D | `is_active` | `systems/DemoCoreLoopV2.gd:564–567` | 4 | R4/R11 |
| D | `is_development_complete` | `systems/DemoCoreLoopV2.gd:569–574` | 6 | R4/R11 |
| D | `is_prototype_complete` | `systems/DemoCoreLoopV2.gd:576–577` | 2 | R4/R11 |
| B? | `mark_development_complete` | `systems/DemoCoreLoopV2.gd:579–611` | 33 | R4/R11 |
| B? | `mark_prototype_complete` | `systems/DemoCoreLoopV2.gd:613–614` | 2 | R4/R11 |
| B? | `completion_snapshot` | `systems/DemoCoreLoopV2.gd:616–964` | 349 | R4/R11 |
| B? | `_completion_snapshot_is_valid` | `systems/DemoCoreLoopV2.gd:966–1015` | 50 | R4/R11 |
| B? | `month_for_turn` | `systems/DemoCoreLoopV2.gd:1017–1018` | 2 | R4/R11 |
| B? | `cash_shortfall_for_money` | `systems/DemoCoreLoopV2.gd:1020–1021` | 2 | R4/R11 |
| B? | `month_spec` | `systems/DemoCoreLoopV2.gd:1023–1028` | 6 | R4/R11 |
| B? | `bundle` | `systems/DemoCoreLoopV2.gd:1030–1035` | 6 | R4/R11 |
| B? | `available_offer_ids` | `systems/DemoCoreLoopV2.gd:1037–1066` | 30 | R4/R11 |
| B? | `plan_for_month` | `systems/DemoCoreLoopV2.gd:1068–1074` | 7 | R4/R11 |
| B? | `episode_plan_spec` | `systems/DemoCoreLoopV2.gd:1080–1083` | 4 | R4/R11 |
| B? | `seoul_cycle_spec` | `systems/DemoCoreLoopV2.gd:1088–1091` | 4 | R4/R11 |
| B? | `_terminal_route_specs` | `systems/DemoCoreLoopV2.gd:1093–1097` | 5 | R4/R11 |
| B? | `_terminal_target_binding_matches_receipt` | `systems/DemoCoreLoopV2.gd:1099–1158` | 60 | R4/R11 |
| B? | `_terminal_target_binding_matches_authored` | `systems/DemoCoreLoopV2.gd:1160–1210` | 51 | R4/R11 |
| B? | `terminal_transition_receipt` | `systems/DemoCoreLoopV2.gd:1215–1226` | 12 | R4/R11 |
| B? | `terminal_transition_resolution` | `systems/DemoCoreLoopV2.gd:1228–1272` | 45 | R4/R11 |
| B? | `_terminal_live_resolution_matches_cycle` | `systems/DemoCoreLoopV2.gd:1274–1306` | 33 | R4/R11 |
| B? | `_terminal_transition_resolution_has_exact_shape` | `systems/DemoCoreLoopV2.gd:1308–1400` | 93 | R4/R11 |
| B? | `_terminal_binding_has_nonzero_effect` | `systems/DemoCoreLoopV2.gd:1402–1409` | 8 | R4/R11 |
| B? | `_terminal_allocation_resolution_drafts` | `systems/DemoCoreLoopV2.gd:1411–1476` | 66 | R4/R11 |
| B? | `_terminal_expiry_resolution_drafts` | `systems/DemoCoreLoopV2.gd:1478–1571` | 94 | R4/R11 |
| B? | `terminal_routes_for_target` | `systems/DemoCoreLoopV2.gd:1573–1595` | 23 | R4/R11 |
| B? | `_terminal_target_binding_from_receipt` | `systems/DemoCoreLoopV2.gd:1597–1624` | 28 | R4/R11 |
| B? | `_terminal_candidate_from_binding` | `systems/DemoCoreLoopV2.gd:1626–1648` | 23 | R4/R11 |
| B? | `_terminal_ordinary_candidate` | `systems/DemoCoreLoopV2.gd:1650–1666` | 17 | R4/R11 |
| B? | `_terminal_binding_candidate_records` | `systems/DemoCoreLoopV2.gd:1668–1690` | 23 | R4/R11 |
| B? | `terminal_target_candidates` | `systems/DemoCoreLoopV2.gd:1692–1703` | 12 | R4/R11 |
| B? | `_terminal_source_summary_witness_present` | `systems/DemoCoreLoopV2.gd:1705–1715` | 11 | R4/R11 |
| B? | `_terminal_source_proof_from_summary` | `systems/DemoCoreLoopV2.gd:1717–1767` | 51 | R4/R11 |
| B? | `_terminal_receipt_bindings_for_target` | `systems/DemoCoreLoopV2.gd:1773–1825` | 53 | R4/R11 |
| B? | `_terminal_receipt_bound_nodes_for_target` | `systems/DemoCoreLoopV2.gd:1827–1846` | 20 | R4/R11 |
| B? | `_terminal_valid_bindings_for_target` | `systems/DemoCoreLoopV2.gd:1848–1866` | 19 | R4/R11 |
| B? | `_terminal_union_ordinary_candidates` | `systems/DemoCoreLoopV2.gd:1868–1896` | 29 | R4/R11 |
| B? | `_terminal_ordinary_candidates_at_target_open` | `systems/DemoCoreLoopV2.gd:1902–1952` | 51 | R4/R11 |
| B? | `_terminal_historical_predicate_met` | `systems/DemoCoreLoopV2.gd:1954–1983` | 30 | R4/R11 |
| B? | `_terminal_historical_action_receipt_predicate_met` | `systems/DemoCoreLoopV2.gd:1989–2094` | 106 | R4/R11 |
| B? | `_terminal_historical_cycle_summary` | `systems/DemoCoreLoopV2.gd:2101–2161` | 61 | R4/R11 |
| B? | `_terminal_historical_cycle_summary_uncached` | `systems/DemoCoreLoopV2.gd:2163–2320` | 158 | R4/R11 |
| B? | `_terminal_historical_resolved_nodes` | `systems/DemoCoreLoopV2.gd:2326–2493` | 168 | R4/R11 |
| B? | `_terminal_historical_capacity_values` | `systems/DemoCoreLoopV2.gd:2495–2554` | 60 | R4/R11 |
| B? | `_terminal_seed_player_name` | `systems/DemoCoreLoopV2.gd:2561–2577` | 17 | R4/R11 |
| B? | `_terminal_historical_node_timelines_valid` | `systems/DemoCoreLoopV2.gd:2583–2789` | 207 | R4/R11 |
| B? | `_terminal_historical_bound_nodes` | `systems/DemoCoreLoopV2.gd:2791–2834` | 44 | R4/R11 |
| B? | `_terminal_historical_resolution_matches_cycle` | `systems/DemoCoreLoopV2.gd:2836–2913` | 78 | R4/R11 |
| B? | `_terminal_historical_resolutions_for_month` | `systems/DemoCoreLoopV2.gd:2915–3014` | 100 | R4/R11 |
| B? | `_terminal_historical_node_expiry_valid` | `systems/DemoCoreLoopV2.gd:3016–3043` | 28 | R4/R11 |
| B? | `_terminal_historical_trigger_expiry_valid` | `systems/DemoCoreLoopV2.gd:3045–3084` | 40 | R4/R11 |
| B? | `_terminal_historical_outer_weekly_valid` | `systems/DemoCoreLoopV2.gd:3086–3197` | 112 | R4/R11 |
| B? | `_terminal_historical_weekly_eviction_proven` | `systems/DemoCoreLoopV2.gd:3203–3220` | 18 | R4/R11 |
| B? | `_terminal_historical_allocation_valid` | `systems/DemoCoreLoopV2.gd:3222–3406` | 185 | R4/R11 |
| B? | `_terminal_historical_kept_matches_allocation` | `systems/DemoCoreLoopV2.gd:3408–3445` | 38 | R4/R11 |
| B? | `_terminal_historical_completed_bundle` | `systems/DemoCoreLoopV2.gd:3447–3544` | 98 | R4/R11 |
| B? | `_terminal_historical_routine_selected` | `systems/DemoCoreLoopV2.gd:3546–3569` | 24 | R4/R11 |
| B? | `_terminal_historical_relationship_predicate_met` | `systems/DemoCoreLoopV2.gd:3571–3653` | 83 | R4/R11 |
| B? | `_terminal_node_with_selected_candidate` | `systems/DemoCoreLoopV2.gd:3655–3709` | 55 | R4/R11 |
| B? | `_terminal_node_has_binding` | `systems/DemoCoreLoopV2.gd:3711–3724` | 14 | R4/R11 |
| B? | `_terminal_node_binding_fields_present` | `systems/DemoCoreLoopV2.gd:3727–3737` | 11 | R4/R11 |
| B? | `_terminal_selected_binding` | `systems/DemoCoreLoopV2.gd:3739–3749` | 11 | R4/R11 |
| B? | `_terminal_selected_identity` | `systems/DemoCoreLoopV2.gd:3751–3768` | 18 | R4/R11 |
| B? | `_terminal_selection_copy_matches_node` | `systems/DemoCoreLoopV2.gd:3770–3786` | 17 | R4/R11 |
| B? | `_terminal_historical_selection_identity_valid` | `systems/DemoCoreLoopV2.gd:3788–3843` | 56 | R4/R11 |
| B? | `_bind_terminal_routes_to_new_cycle` | `systems/DemoCoreLoopV2.gd:3845–3973` | 129 | R4/R11 |
| B? | `_terminal_transition_receipt_matches_spec` | `systems/DemoCoreLoopV2.gd:3975–4031` | 57 | R4/R11 |
| B? | `_terminal_source_proof_semantically_valid` | `systems/DemoCoreLoopV2.gd:4033–4072` | 40 | R4/R11 |
| B? | `_terminal_source_proof_matches_month_summary` | `systems/DemoCoreLoopV2.gd:4074–4240` | 167 | R4/R11 |
| B? | `_terminal_completed_turns_for_month` | `systems/DemoCoreLoopV2.gd:4245–4269` | 25 | R4/R11 |
| B? | `_terminal_source_witnesses_for_month` | `systems/DemoCoreLoopV2.gd:4271–4305` | 35 | R4/R11 |
| B? | `_terminal_node_summary_default` | `systems/DemoCoreLoopV2.gd:4307–4313` | 7 | R4/R11 |
| B? | `_terminal_node_runtime_projection` | `systems/DemoCoreLoopV2.gd:4315–4352` | 38 | R4/R11 |
| B? | `_terminal_node_projection_has_exact_shape` | `systems/DemoCoreLoopV2.gd:4354–4386` | 33 | R4/R11 |
| B? | `_terminal_expected_completion_bundle` | `systems/DemoCoreLoopV2.gd:4388–4398` | 11 | R4/R11 |
| B? | `_terminal_completed_bundle_state_valid` | `systems/DemoCoreLoopV2.gd:4400–4416` | 17 | R4/R11 |
| B? | `_terminal_w1_capacity_identity_valid` | `systems/DemoCoreLoopV2.gd:4418–4465` | 48 | R4/R11 |
| B? | `_terminal_w1_authority_allocations` | `systems/DemoCoreLoopV2.gd:4467–4499` | 33 | R4/R11 |
| B? | `_terminal_immutable_w1_typed_provenance_valid` | `systems/DemoCoreLoopV2.gd:4501–4542` | 42 | R4/R11 |
| B? | `_terminal_outer_weekly_identity_valid` | `systems/DemoCoreLoopV2.gd:4544–4607` | 64 | R4/R11 |
| B? | `_terminal_completion_semantics_valid` | `systems/DemoCoreLoopV2.gd:4609–4717` | 109 | R4/R11 |
| B? | `_terminal_effect_snapshot_valid` | `systems/DemoCoreLoopV2.gd:4719–4740` | 22 | R4/R11 |
| B? | `_terminal_expiry_outcomes_absent` | `systems/DemoCoreLoopV2.gd:4742–4867` | 126 | R4/R11 |
| B? | `_terminal_partial_allocation_valid` | `systems/DemoCoreLoopV2.gd:4869–4923` | 55 | R4/R11 |
| B? | `_terminal_expiry_semantics_valid` | `systems/DemoCoreLoopV2.gd:4925–5046` | 122 | R4/R11 |
| B? | `_terminal_typed_action_proof_matches_state` | `systems/DemoCoreLoopV2.gd:5048–5097` | 50 | R4/R11 |
| B? | `_terminal_action_receipt_proof_matches_state` | `systems/DemoCoreLoopV2.gd:5099–5142` | 44 | R4/R11 |
| B? | `_terminal_relationship_proof_matches_state` | `systems/DemoCoreLoopV2.gd:5144–5165` | 22 | R4/R11 |
| B? | `_terminal_selected_trigger_proof_matches_state` | `systems/DemoCoreLoopV2.gd:5167–5219` | 53 | R4/R11 |
| B? | `_terminal_relationship_bundle_absent_in_month` | `systems/DemoCoreLoopV2.gd:5221–5246` | 26 | R4/R11 |
| B? | `_terminal_dictionary_has_exact_keys` | `systems/DemoCoreLoopV2.gd:5248–5258` | 11 | R4/R11 |
| D | `_terminal_integral_number_matches` | `systems/DemoCoreLoopV2.gd:5263–5268` | 6 | R4/R11 |
| B? | `_terminal_integral_number_in_range` | `systems/DemoCoreLoopV2.gd:5270–5276` | 7 | R4/R11 |
| B? | `_terminal_variant_semantically_equal` | `systems/DemoCoreLoopV2.gd:5283–5333` | 51 | R4/R11 |
| B? | `_terminal_variant_numbers_are_integral` | `systems/DemoCoreLoopV2.gd:5339–5359` | 21 | R4/R11 |
| B? | `_terminal_effects_semantically_equal` | `systems/DemoCoreLoopV2.gd:5364–5392` | 29 | R4/R11 |
| B? | `_terminal_source_proof_has_exact_shape` | `systems/DemoCoreLoopV2.gd:5394–5470` | 77 | R4/R11 |
| B? | `seoul_cycle_month_spec` | `systems/DemoCoreLoopV2.gd:5476–5496` | 21 | R4/R11 |
| B? | `_seoul_cycle_month_start_turn` | `systems/DemoCoreLoopV2.gd:5498–5499` | 2 | R4/R11 |
| B? | `_seoul_cycle_month_end_turn` | `systems/DemoCoreLoopV2.gd:5501–5502` | 2 | R4/R11 |
| B? | `plan_uses_seoul_cycle` | `systems/DemoCoreLoopV2.gd:5504–5569` | 66 | R4/R11 |
| B? | `_fresh_seoul_cycle_gate` | `systems/DemoCoreLoopV2.gd:5571–5607` | 37 | R4/R11 |
| B? | `seoul_cycle_available` | `systems/DemoCoreLoopV2.gd:5609–5624` | 16 | R4/R11 |
| B? | `initialize_seoul_cycle` | `systems/DemoCoreLoopV2.gd:5626–5812` | 187 | R4/R11 |
| B? | `_new_seoul_cycle_state` | `systems/DemoCoreLoopV2.gd:5814–5883` | 70 | R4/R11 |
| B? | `_resolved_seoul_cycle_node` | `systems/DemoCoreLoopV2.gd:5885–5919` | 35 | R4/R11 |
| B? | `_seoul_cycle_node_with_resolved_trigger` | `systems/DemoCoreLoopV2.gd:5925–5974` | 50 | R4/R11 |
| B? | `_seoul_cycle_player_trigger_required` | `systems/DemoCoreLoopV2.gd:5976–5978` | 3 | R4/R11 |
| B? | `_eligible_seoul_cycle_player_trigger_ids` | `systems/DemoCoreLoopV2.gd:5980–5992` | 13 | R4/R11 |
| B? | `_seoul_cycle_player_trigger_candidate_records` | `systems/DemoCoreLoopV2.gd:5994–6020` | 27 | R4/R11 |
| B? | `_seoul_cycle_node_trigger_candidates` | `systems/DemoCoreLoopV2.gd:6022–6039` | 18 | R4/R11 |
| B? | `_generated_seoul_cycle_capacities` | `systems/DemoCoreLoopV2.gd:6041–6084` | 44 | R4/R11 |
| B? | `_seoul_cycle_seed_signature` | `systems/DemoCoreLoopV2.gd:6086–6092` | 7 | R4/R11 |
| B? | `_stable_seoul_cycle_seed` | `systems/DemoCoreLoopV2.gd:6094–6099` | 6 | R4/R11 |
| B? | `_seoul_cycle_condition_band` | `systems/DemoCoreLoopV2.gd:6101–6111` | 11 | R4/R11 |
| B? | `_seoul_cycle_capacity_quality` | `systems/DemoCoreLoopV2.gd:6113–6122` | 10 | R4/R11 |
| B? | `_seoul_cycle_progress_for_capacity` | `systems/DemoCoreLoopV2.gd:6124–6133` | 10 | R4/R11 |
| B? | `seoul_cycle_snapshot` | `systems/DemoCoreLoopV2.gd:6135–6170` | 36 | R4/R11 |
| B? | `preview_seoul_cycle_allocation` | `systems/DemoCoreLoopV2.gd:6172–6500` | 329 | R4/R11 |
| B? | `commit_seoul_cycle_allocation` | `systems/DemoCoreLoopV2.gd:6502–6751` | 250 | R4/R11 |
| B? | `_seoul_cycle_commitment_payload` | `systems/DemoCoreLoopV2.gd:6753–6843` | 91 | R4/R11 |
| B? | `_seoul_cycle_default_action_id` | `systems/DemoCoreLoopV2.gd:6845–6857` | 13 | R4/R11 |
| B? | `_merged_seoul_cycle_effects` | `systems/DemoCoreLoopV2.gd:6859–6873` | 15 | R4/R11 |
| B? | `_seoul_cycle_expected_allocation_effects` | `systems/DemoCoreLoopV2.gd:6875–6899` | 25 | R4/R11 |
| B? | `_apply_seoul_cycle_effects` | `systems/DemoCoreLoopV2.gd:6901–6908` | 8 | R4/R11 |
| B? | `_seoul_cycle_world_event_for_week` | `systems/DemoCoreLoopV2.gd:6910–6941` | 32 | R4/R11 |
| B? | `pending_seoul_cycle_trigger` | `systems/DemoCoreLoopV2.gd:6943–6945` | 3 | R4/R11 |
| B? | `pending_seoul_cycle_world` | `systems/DemoCoreLoopV2.gd:6947–6949` | 3 | R4/R11 |
| B? | `claim_seoul_cycle_trigger` | `systems/DemoCoreLoopV2.gd:6951–6952` | 2 | R4/R11 |
| B? | `claim_seoul_cycle_world` | `systems/DemoCoreLoopV2.gd:6954–6955` | 2 | R4/R11 |
| B? | `_claim_seoul_cycle_entry` | `systems/DemoCoreLoopV2.gd:6957–6986` | 30 | R4/R11 |
| B? | `begin_seoul_cycle_trigger` | `systems/DemoCoreLoopV2.gd:6988–6989` | 2 | R4/R11 |
| B? | `begin_seoul_cycle_world` | `systems/DemoCoreLoopV2.gd:6991–6992` | 2 | R4/R11 |
| B? | `_begin_seoul_cycle_entry` | `systems/DemoCoreLoopV2.gd:6994–7006` | 13 | R4/R11 |
| B? | `active_bundle_is_seoul_cycle_trigger` | `systems/DemoCoreLoopV2.gd:7008–7009` | 2 | R4/R11 |
| B? | `active_bundle_is_seoul_cycle_world` | `systems/DemoCoreLoopV2.gd:7011–7012` | 2 | R4/R11 |
| B? | `_active_bundle_matches_cycle_entry` | `systems/DemoCoreLoopV2.gd:7014–7026` | 13 | R4/R11 |
| B? | `resolve_seoul_cycle_trigger` | `systems/DemoCoreLoopV2.gd:7028–7030` | 3 | R4/R11 |
| B? | `resolve_seoul_cycle_world` | `systems/DemoCoreLoopV2.gd:7032–7034` | 3 | R4/R11 |
| B? | `_resolve_seoul_cycle_entry_public` | `systems/DemoCoreLoopV2.gd:7036–7059` | 24 | R4/R11 |
| B? | `_seoul_cycle_entry_receipt_id` | `systems/DemoCoreLoopV2.gd:7061–7079` | 19 | R4/R11 |
| B? | `_seoul_cycle_resolved_receipt_matches` | `systems/DemoCoreLoopV2.gd:7081–7098` | 18 | R4/R11 |
| B? | `_resolve_seoul_cycle_entry_in_state` | `systems/DemoCoreLoopV2.gd:7100–7164` | 65 | R4/R11 |
| B? | `_seoul_cycle_world_receipt_id` | `systems/DemoCoreLoopV2.gd:7166–7175` | 10 | R4/R11 |
| B? | `_terminal_effect_snapshot_after` | `systems/DemoCoreLoopV2.gd:7177–7192` | 16 | R4/R11 |
| B? | `complete_seoul_cycle_turn` | `systems/DemoCoreLoopV2.gd:7194–7378` | 185 | R4/R11 |
| B? | `_seoul_cycle_turn_ready` | `systems/DemoCoreLoopV2.gd:7380–7405` | 26 | R4/R11 |
| B? | `episode_selection_enabled` | `systems/DemoCoreLoopV2.gd:7407–7430` | 24 | R4/R11 |
| B? | `episode_offer_ids` | `systems/DemoCoreLoopV2.gd:7432–7444` | 13 | R4/R11 |
| B? | `plan_uses_episode_selection` | `systems/DemoCoreLoopV2.gd:7446–7475` | 30 | R4/R11 |
| B? | `episode_commitments_from_plan` | `systems/DemoCoreLoopV2.gd:7477–7483` | 7 | R4/R11 |
| B? | `_episode_schedule_for_selection` | `systems/DemoCoreLoopV2.gd:7485–7507` | 23 | R4/R11 |
| B? | `validate_episode_selection` | `systems/DemoCoreLoopV2.gd:7509–7546` | 38 | R4/R11 |
| B? | `commit_episode_selection` | `systems/DemoCoreLoopV2.gd:7548–7568` | 21 | R4/R11 |
| B? | `month_one_episode_echo` | `systems/DemoCoreLoopV2.gd:7570–7601` | 32 | R4/R11 |
| B? | `_seoul_cycle_month_one_echo` | `systems/DemoCoreLoopV2.gd:7603–7624` | 22 | R4/R11 |
| B? | `needs_plan` | `systems/DemoCoreLoopV2.gd:7626–7627` | 2 | R4/R11 |
| B? | `fresh_preplan_opening_roots` | `systems/DemoCoreLoopV2.gd:7632–7646` | 15 | R4/R11 |
| B? | `_legacy_preplan_opening_queue_matches` | `systems/DemoCoreLoopV2.gd:7648–7658` | 11 | R4/R11 |
| B? | `_legacy_preplan_opening_send_available` | `systems/DemoCoreLoopV2.gd:7660–7700` | 41 | R4/R11 |
| D | `opening_follow_up_event` | `systems/DemoCoreLoopV2.gd:7706–7733` | 28 | R4/R11 |
| B? | `needs_preplan_opening` | `systems/DemoCoreLoopV2.gd:7738–7753` | 16 | R4/R11 |
| B? | `claim_saved_preplan_opening` | `systems/DemoCoreLoopV2.gd:7755–7758` | 4 | R4/R11 |
| B? | `_preplan_opening_base_available` | `systems/DemoCoreLoopV2.gd:7760–7779` | 20 | R4/R11 |
| B? | `_preplan_opening_trigger` | `systems/DemoCoreLoopV2.gd:7781–7785` | 5 | R4/R11 |
| B? | `_preplan_opening_application_id` | `systems/DemoCoreLoopV2.gd:7787–7789` | 3 | R4/R11 |
| B? | `claim_preplan_opening_from_trigger` | `systems/DemoCoreLoopV2.gd:7791–7809` | 19 | R4/R11 |
| B? | `claim_legacy_preplan_opening_from_send` | `systems/DemoCoreLoopV2.gd:7816–7885` | 70 | R4/R11 |
| B? | `_claim_preplan_opening` | `systems/DemoCoreLoopV2.gd:7887–7937` | 51 | R4/R11 |
| B? | `pending_month_prelude` | `systems/DemoCoreLoopV2.gd:7942–7959` | 18 | R4/R11 |
| B? | `routine_options` | `systems/DemoCoreLoopV2.gd:7961–7967` | 7 | R4/R11 |
| B? | `default_routines` | `systems/DemoCoreLoopV2.gd:7969–7982` | 14 | R4/R11 |
| B? | `validate_routines` | `systems/DemoCoreLoopV2.gd:7984–8004` | 21 | R4/R11 |
| B? | `bundle_allowed_in_week` | `systems/DemoCoreLoopV2.gd:8006–8016` | 11 | R4/R11 |
| B? | `validate_plan` | `systems/DemoCoreLoopV2.gd:8018–8093` | 76 | R4/R11 |
| B? | `_validate_named_character_cap` | `systems/DemoCoreLoopV2.gd:8095–8137` | 43 | R4/R11 |
| B? | `commit_plan` | `systems/DemoCoreLoopV2.gd:8139–8223` | 85 | R4/R11 |
| B? | `routine_selection_for_month` | `systems/DemoCoreLoopV2.gd:8225–8235` | 11 | R4/R11 |
| B? | `apply_background_routines_for_turn` | `systems/DemoCoreLoopV2.gd:8237–8340` | 104 | R4/R11 |
| B? | `_routine_effects` | `systems/DemoCoreLoopV2.gd:8342–8357` | 16 | R4/R11 |
| B? | `decline_outcome` | `systems/DemoCoreLoopV2.gd:8359–8365` | 7 | R4/R11 |
| B? | `process_declines_before_bundle` | `systems/DemoCoreLoopV2.gd:8367–8390` | 24 | R4/R11 |
| B? | `process_due_decline_outcomes` | `systems/DemoCoreLoopV2.gd:8392–8428` | 37 | R4/R11 |
| B? | `_decline_matches_bundle` | `systems/DemoCoreLoopV2.gd:8430–8457` | 28 | R4/R11 |
| B? | `_consume_decline_record` | `systems/DemoCoreLoopV2.gd:8459–8501` | 43 | R4/R11 |
| B? | `decline_receipts_for_month` | `systems/DemoCoreLoopV2.gd:8503–8510` | 8 | R4/R11 |
| B? | `decline_receipts_from_month` | `systems/DemoCoreLoopV2.gd:8512–8519` | 8 | R4/R11 |
| B? | `_terminal_month_topology_complete` | `systems/DemoCoreLoopV2.gd:8521–8533` | 13 | R4/R11 |
| B? | `_terminal_completion_topology` | `systems/DemoCoreLoopV2.gd:8535–8596` | 62 | R4/R11 |
| B? | `_terminal_expiry_topology` | `systems/DemoCoreLoopV2.gd:8598–8649` | 52 | R4/R11 |
| B? | `_terminal_relationship_receipt` | `systems/DemoCoreLoopV2.gd:8651–8739` | 89 | R4/R11 |
| B? | `_terminal_story_choice_receipt` | `systems/DemoCoreLoopV2.gd:8741–8776` | 36 | R4/R11 |
| B? | `_terminal_story_receipts_for_identity` | `systems/DemoCoreLoopV2.gd:8778–8812` | 35 | R4/R11 |
| B? | `_terminal_selected_story_proof` | `systems/DemoCoreLoopV2.gd:8814–8875` | 62 | R4/R11 |
| B? | `_terminal_source_proof` | `systems/DemoCoreLoopV2.gd:8877–9048` | 172 | R4/R11 |
| B? | `_derive_terminal_transition_receipts_for_month` | `systems/DemoCoreLoopV2.gd:9050–9109` | 60 | R4/R11 |
| B? | `_terminal_month_requires_seoul_authority` | `systems/DemoCoreLoopV2.gd:9115–9170` | 56 | R4/R11 |
| B? | `can_record_month_summary` | `systems/DemoCoreLoopV2.gd:9172–9214` | 43 | R4/R11 |
| B? | `record_month_summary` | `systems/DemoCoreLoopV2.gd:9216–9319` | 104 | R4/R11 |
| B? | `_seoul_cycle_month_summary_payload` | `systems/DemoCoreLoopV2.gd:9321–9488` | 168 | R4/R11 |
| B? | `_seoul_cycle_historical_authority` | `systems/DemoCoreLoopV2.gd:9490–9513` | 24 | R4/R11 |
| B? | `_validated_month_summary` | `systems/DemoCoreLoopV2.gd:9515–9532` | 18 | R4/R11 |
| B? | `month_summary` | `systems/DemoCoreLoopV2.gd:9534–9537` | 4 | R4/R11 |
| B? | `month_opening_snapshot` | `systems/DemoCoreLoopV2.gd:9539–9544` | 6 | R4/R11 |
| B? | `pending_month_summary` | `systems/DemoCoreLoopV2.gd:9546–9561` | 16 | R4/R11 |
| B? | `acknowledge_month_summary` | `systems/DemoCoreLoopV2.gd:9563–9574` | 12 | R4/R11 |
| B? | `bundle_id_for_turn` | `systems/DemoCoreLoopV2.gd:9576–9582` | 7 | R4/R11 |
| B? | `begin_bundle` | `systems/DemoCoreLoopV2.gd:9584–9606` | 23 | R4/R11 |
| B? | `active_bundle_id` | `systems/DemoCoreLoopV2.gd:9608–9609` | 2 | R4/R11 |
| B? | `active_kind` | `systems/DemoCoreLoopV2.gd:9611–9612` | 2 | R4/R11 |
| B? | `action_result_ready` | `systems/DemoCoreLoopV2.gd:9614–9617` | 4 | R4/R11 |
| B? | `turn_completed` | `systems/DemoCoreLoopV2.gd:9619–9622` | 4 | R4/R11 |
| D | `has_completed_bundle` | `systems/DemoCoreLoopV2.gd:9624–9626` | 3 | R4: 일반 chapter1 close 중복 방지 MainGame :7909–7910 |
| B? | `action_receipt` | `systems/DemoCoreLoopV2.gd:9628–9632` | 5 | R4/R11 |
| B? | `activity_task_config` | `systems/DemoCoreLoopV2.gd:9638–9654` | 17 | R4/R11 |
| B? | `begin_or_resume_activity_task` | `systems/DemoCoreLoopV2.gd:9660–9713` | 54 | R4/R11 |
| B? | `activity_task_session` | `systems/DemoCoreLoopV2.gd:9715–9720` | 6 | R4/R11 |
| B? | `update_activity_task_requirements` | `systems/DemoCoreLoopV2.gd:9726–9755` | 30 | R4/R11 |
| B? | `select_activity_task_requirement` | `systems/DemoCoreLoopV2.gd:9757–9770` | 14 | R4/R11 |
| B? | `resolve_activity_task` | `systems/DemoCoreLoopV2.gd:9775–9811` | 37 | R4/R11 |
| B? | `clear_activity_task_session` | `systems/DemoCoreLoopV2.gd:9816–9823` | 8 | R4/R11 |
| B? | `activity_task_receipt` | `systems/DemoCoreLoopV2.gd:9827–9860` | 34 | R4/R11 |
| B? | `_legacy_instant_activity_task_receipt` | `systems/DemoCoreLoopV2.gd:9862–9926` | 65 | R4/R11 |
| B? | `activity_task_receipt_has_requirement` | `systems/DemoCoreLoopV2.gd:9928–9935` | 8 | R4/R11 |
| B? | `activity_task_receipt_outcome_id` | `systems/DemoCoreLoopV2.gd:9937–9938` | 2 | R4/R11 |
| B? | `_normalized_activity_task_config` | `systems/DemoCoreLoopV2.gd:9940–10057` | 118 | R4/R11 |
| B? | `_activity_task_requirement_ids` | `systems/DemoCoreLoopV2.gd:10059–10079` | 21 | R4/R11 |
| B? | `_activity_task_requirement_signature` | `systems/DemoCoreLoopV2.gd:10081–10087` | 7 | R4/R11 |
| B? | `_activity_task_resolution` | `systems/DemoCoreLoopV2.gd:10089–10139` | 51 | R4/R11 |
| B? | `_validated_activity_task_result` | `systems/DemoCoreLoopV2.gd:10141–10169` | 29 | R4/R11 |
| B? | `_normalized_activity_task_session` | `systems/DemoCoreLoopV2.gd:10171–10229` | 59 | R4/R11 |
| B? | `_clear_activity_task_session_for_owner` | `systems/DemoCoreLoopV2.gd:10231–10241` | 11 | R4/R11 |
| B? | `story_owns_action_result` | `systems/DemoCoreLoopV2.gd:10247–10258` | 12 | R4/R11 |
| B? | `action_story_stage` | `systems/DemoCoreLoopV2.gd:10264–10290` | 27 | R4/R11 |
| B? | `acknowledge_action_story_result` | `systems/DemoCoreLoopV2.gd:10295–10312` | 18 | R4/R11 |
| B? | `_action_record_for_bundle_from_weekly_commitment` | `systems/DemoCoreLoopV2.gd:10317–10361` | 45 | R4/R11 |
| B? | `recover_action_result` | `systems/DemoCoreLoopV2.gd:10363–10403` | 41 | R4/R11 |
| B? | `application_status` | `systems/DemoCoreLoopV2.gd:10405–10422` | 18 | R4/R11 |
| B? | `has_relationship_memory` | `systems/DemoCoreLoopV2.gd:10424–10438` | 15 | R4/R11 |
| B? | `obligation_receipt_matches` | `systems/DemoCoreLoopV2.gd:10442–10472` | 31 | R4/R11 |
| B? | `has_hyunsu_exam_memory` | `systems/DemoCoreLoopV2.gd:10474–10482` | 9 | R4/R11 |
| B? | `has_hyunsu_exam_outcome_receipt` | `systems/DemoCoreLoopV2.gd:10484–10490` | 7 | R4/R11 |
| B? | `future_story_source_matches` | `systems/DemoCoreLoopV2.gd:10492–10506` | 15 | R4/R11 |
| D | `post_demo_application_result_event_id` | `systems/DemoCoreLoopV2.gd:10508–10542` | 35 | R4/R11 |
| B? | `note_post_demo_application_result` | `systems/DemoCoreLoopV2.gd:10544–10608` | 65 | R4/R11 |
| B? | `hyunsu_exam_result_event_id` | `systems/DemoCoreLoopV2.gd:10610–10640` | 31 | R4/R11 |
| D | `legacy_callback_is_superseded` | `systems/DemoCoreLoopV2.gd:10642–10651` | 10 | R4/R11 |
| B? | `_current_application_action_record_valid` | `systems/DemoCoreLoopV2.gd:10658–10711` | 54 | R4/R11 |
| B? | `_current_job_hunt_application_recovery_valid` | `systems/DemoCoreLoopV2.gd:10717–10777` | 61 | R4/R11 |
| B? | `_clear_current_w1_application_recovery_authority` | `systems/DemoCoreLoopV2.gd:10779–10785` | 7 | R4/R11 |
| B? | `_action_receipt_from_record` | `systems/DemoCoreLoopV2.gd:10787–10916` | 130 | R4/R11 |
| B? | `_apply_action_application_receipt` | `systems/DemoCoreLoopV2.gd:10918–10961` | 44 | R4/R11 |
| B? | `note_action_commitment` | `systems/DemoCoreLoopV2.gd:10963–11019` | 57 | R4/R11 |
| B? | `_fresh_w1_application_postcondition` | `systems/DemoCoreLoopV2.gd:11021–11057` | 37 | R4/R11 |
| B? | `finalize_fresh_w1_application` | `systems/DemoCoreLoopV2.gd:11062–11142` | 81 | R4/R11 |
| B? | `stage_fresh_w1_application_draft` | `systems/DemoCoreLoopV2.gd:11144–11155` | 12 | R4/R11 |
| B? | `restart_fresh_w1_minigame` | `systems/DemoCoreLoopV2.gd:11157–11170` | 14 | R4/R11 |
| B? | `claim_fresh_w1_opening_interview` | `systems/DemoCoreLoopV2.gd:11172–11214` | 43 | R4/R11 |
| B? | `complete_fresh_w1_action_and_claim_interview` | `systems/DemoCoreLoopV2.gd:11219–11272` | 54 | R4/R11 |
| B? | `complete_active_bundle` | `systems/DemoCoreLoopV2.gd:11274–11446` | 173 | R4/R11 |
| B? | `_seoul_cycle_pending_key_for_active` | `systems/DemoCoreLoopV2.gd:11448–11467` | 20 | R4/R11 |
| B? | `_has_current_relationship_receipt` | `systems/DemoCoreLoopV2.gd:11469–11520` | 52 | R4/R11 |
| B? | `_is_action_story_bundle` | `systems/DemoCoreLoopV2.gd:11522–11525` | 4 | R4/R11 |
| B? | `_has_current_action_story_acknowledgement` | `systems/DemoCoreLoopV2.gd:11527–11547` | 21 | R4/R11 |
| B? | `_has_current_bundle_story_receipt` | `systems/DemoCoreLoopV2.gd:11549–11619` | 71 | R4/R11 |
| B? | `_bundle_story_event_ids` | `systems/DemoCoreLoopV2.gd:11621–11640` | 20 | R4/R11 |
| B? | `_current_story_choice_receipt_valid` | `systems/DemoCoreLoopV2.gd:11642–11693` | 52 | R4/R11 |
| B? | `_current_story_choice_receipt_census_valid` | `systems/DemoCoreLoopV2.gd:11695–11728` | 34 | R4/R11 |
| B? | `_live_story_owner_event_ids` | `systems/DemoCoreLoopV2.gd:11730–11741` | 12 | R4/R11 |
| B? | `_current_story_owner_receipts_valid` | `systems/DemoCoreLoopV2.gd:11743–11787` | 45 | R4/R11 |
| B? | `_current_story_owner_scope_present` | `systems/DemoCoreLoopV2.gd:11789–11815` | 27 | R4/R11 |
| B? | `_has_current_application_receipt` | `systems/DemoCoreLoopV2.gd:11817–11888` | 72 | R4/R11 |
| B? | `_story_choice_transport_owner_id` | `systems/DemoCoreLoopV2.gd:11890–11907` | 18 | R4/R11 |
| B? | `_current_outcome_receipt_ledger_census_valid` | `systems/DemoCoreLoopV2.gd:11909–11950` | 42 | R4/R11 |
| B? | `_current_outcome_receipt_allowed_sibling` | `systems/DemoCoreLoopV2.gd:11952–11992` | 41 | R4/R11 |
| B? | `_selected_choice_requires_outcome_receipt` | `systems/DemoCoreLoopV2.gd:11994–12030` | 37 | R4/R11 |
| B? | `_outcome_runtime_applicable` | `systems/DemoCoreLoopV2.gd:12032–12045` | 14 | R4/R11 |
| B? | `cancel_active_bundle` | `systems/DemoCoreLoopV2.gd:12047–12054` | 8 | R4/R11 |
| B? | `claim_scheduled_prelude` | `systems/DemoCoreLoopV2.gd:12059–12158` | 100 | R4/R11 |
| B? | `scheduled_prelude_receipt` | `systems/DemoCoreLoopV2.gd:12160–12168` | 9 | R4/R11 |
| B? | `_story_receipt_prefix_entries_valid` | `systems/DemoCoreLoopV2.gd:12170–12196` | 27 | R4/R11 |
| B? | `_story_receipt_owner_union_valid` | `systems/DemoCoreLoopV2.gd:12198–12245` | 48 | R4/R11 |
| B? | `_scheduled_prelude_story_receipts_complete` | `systems/DemoCoreLoopV2.gd:12251–12347` | 97 | R4/R11 |
| B? | `_canonical_w4_temptation_root` | `systems/DemoCoreLoopV2.gd:12349–12396` | 48 | R4/R11 |
| B? | `_sns_story_receipt_complete` | `systems/DemoCoreLoopV2.gd:12398–12455` | 58 | R4/R11 |
| B? | `_sns_story_choice_flags_valid` | `systems/DemoCoreLoopV2.gd:12457–12464` | 8 | R4/R11 |
| B? | `_sns_consequence_completion_valid` | `systems/DemoCoreLoopV2.gd:12466–12481` | 16 | R4/R11 |
| B? | `_legacy_sns_schedule_owner_valid` | `systems/DemoCoreLoopV2.gd:12483–12508` | 26 | R4/R11 |
| B? | `_legacy_month_schedule_has_exact_shape` | `systems/DemoCoreLoopV2.gd:12510–12544` | 35 | R4/R11 |
| B? | `_legacy_sns_consequence_completion_valid` | `systems/DemoCoreLoopV2.gd:12546–12566` | 21 | R4/R11 |
| B? | `_legacy_sns_current_story_authority_absent` | `systems/DemoCoreLoopV2.gd:12568–12588` | 21 | R4/R11 |
| B? | `_legacy_040746_sns_completed_origin_valid` | `systems/DemoCoreLoopV2.gd:12590–12612` | 23 | R4/R11 |
| B? | `pending_legacy_separate_consequence_id` | `systems/DemoCoreLoopV2.gd:12614–12630` | 17 | R4/R11 |
| B? | `_sns_temptation_claim_material_present` | `systems/DemoCoreLoopV2.gd:12632–12642` | 11 | R4/R11 |
| B? | `_scheduled_prelude_receipt_valid` | `systems/DemoCoreLoopV2.gd:12644–12699` | 56 | R4/R11 |
| B? | `consume_scheduled_prelude` | `systems/DemoCoreLoopV2.gd:12703–12756` | 54 | R4/R11 |
| B? | `_scheduled_prelude_receipt_from_state` | `systems/DemoCoreLoopV2.gd:12758–12795` | 38 | R4/R11 |
| B? | `_scheduled_prelude_entry_present` | `systems/DemoCoreLoopV2.gd:12797–12807` | 11 | R4/R11 |
| B? | `pending_consequence_id` | `systems/DemoCoreLoopV2.gd:12809–12846` | 38 | R4/R11 |
| B? | `_eligible_consequence_ids` | `systems/DemoCoreLoopV2.gd:12848–12861` | 14 | R4/R11 |
| B? | `received_phone_consequence_ids` | `systems/DemoCoreLoopV2.gd:12866–12903` | 38 | R4/R11 |
| B? | `received_phone_offer_ids` | `systems/DemoCoreLoopV2.gd:12910–12948` | 39 | R4/R11 |
| B? | `resolved_event_roots` | `systems/DemoCoreLoopV2.gd:12950–12965` | 16 | R4/R11 |
| D | `format_first_bill_story_text` | `systems/DemoCoreLoopV2.gd:12971–12991` | 21 | R4/R11 |
| D | `format_first_bill_story_tokens` | `systems/DemoCoreLoopV2.gd:12995–13093` | 99 | R4/R11 |
| D | `_first_bill_finale_contract` | `systems/DemoCoreLoopV2.gd:13095–13099` | 5 | R4/R11 |
| D | `build_first_bill_replay_snapshot` | `systems/DemoCoreLoopV2.gd:13101–13188` | 88 | R4/R11 |
| D | `validated_first_bill_replay_snapshot` | `systems/DemoCoreLoopV2.gd:13190–13329` | 140 | R4/R11 |
| D | `validated_complete_first_bill_replay_snapshot` | `systems/DemoCoreLoopV2.gd:13331–13340` | 10 | R4/R11 |
| D | `first_bill_replay_choice_available` | `systems/DemoCoreLoopV2.gd:13342–13349` | 8 | R4/R11 |
| D | `first_bill_replay_has_relationship_memory` | `systems/DemoCoreLoopV2.gd:13351–13361` | 11 | R4/R11 |
| D | `first_bill_replay_has_m3_ledger_memory` | `systems/DemoCoreLoopV2.gd:13363–13370` | 8 | R4/R11 |
| D | `first_bill_replay_snapshot_with_choice` | `systems/DemoCoreLoopV2.gd:13372–13397` | 26 | R4/R11 |
| D | `first_bill_replay_choice_is_fatal` | `systems/DemoCoreLoopV2.gd:13399–13418` | 20 | R4/R11 |
| D | `first_bill_replay_follow_up_roots` | `systems/DemoCoreLoopV2.gd:13420–13432` | 13 | R4/R11 |
| D | `_first_bill_replay_state` | `systems/DemoCoreLoopV2.gd:13434–13452` | 19 | R4/R11 |
| D | `_first_bill_father_memory_id` | `systems/DemoCoreLoopV2.gd:13454–13477` | 24 | R4/R11 |
| D | `_first_bill_cash_position_sentence` | `systems/DemoCoreLoopV2.gd:13479–13488` | 10 | R4/R11 |
| D | `first_bill_replay_player_name` | `systems/DemoCoreLoopV2.gd:13490–13494` | 5 | R4/R11 |
| D | `_first_bill_localized_player_name` | `systems/DemoCoreLoopV2.gd:13496–13498` | 3 | R4/R11 |
| D | `_validated_demo_collision_context` | `systems/DemoCoreLoopV2.gd:13500–13621` | 122 | R11: 실제 M06 포맷 :13030 |
| D | `_first_bill_candidate_ids` | `systems/DemoCoreLoopV2.gd:13623–13632` | 10 | R4/R11 |
| D | `_first_bill_candidate_ids_from_raw` | `systems/DemoCoreLoopV2.gd:13634–13665` | 32 | R4/R11 |
| D | `_first_bill_obligation_receipt` | `systems/DemoCoreLoopV2.gd:13667–13712` | 46 | R4/R11 |
| D | `_first_bill_candidate_copy_lines` | `systems/DemoCoreLoopV2.gd:13714–13727` | 14 | R4/R11 |
| D | `_first_bill_localized_copy` | `systems/DemoCoreLoopV2.gd:13729–13734` | 6 | R4/R11 |
| D | `_first_bill_body_copy` | `systems/DemoCoreLoopV2.gd:13736–13749` | 14 | R4/R11 |
| D | `_first_bill_after_bills_copy` | `systems/DemoCoreLoopV2.gd:13751–13773` | 23 | R4/R11 |
| D | `_first_bill_trace_copy` | `systems/DemoCoreLoopV2.gd:13775–13814` | 40 | R4/R11 |
| D | `_first_bill_hyunsu_memory_copy` | `systems/DemoCoreLoopV2.gd:13816–13834` | 19 | R4/R11 |
| B? | `prepare_demo_collision` | `systems/DemoCoreLoopV2.gd:13839–13949` | 111 | R4/R11 |
| D | `migrate_legacy_first_bill_state` | `systems/DemoCoreLoopV2.gd:13959–14034` | 76 | R4/R11 |
| D | `migrate_legacy_first_bill_resume_context` | `systems/DemoCoreLoopV2.gd:14039–14151` | 113 | R4/R11 |
| B | `_first_bill_legacy_rewind_to_opening` | `systems/DemoCoreLoopV2.gd:14153–14163` | 11 | R3: 구 W24 resume 게이트 :14039–14070 |
| B | `_first_bill_legacy_minimal_resume` | `systems/DemoCoreLoopV2.gd:14165–14178` | 14 | R3: 구 W24 resume 게이트 :14039–14070 |
| D | `_first_bill_game_state_is_fatal` | `systems/DemoCoreLoopV2.gd:14180–14185` | 6 | R4/R11 |
| B? | `story_choice_available` | `systems/DemoCoreLoopV2.gd:14187–14201` | 15 | R4/R11 |
| B? | `story_choice_transaction_required` | `systems/DemoCoreLoopV2.gd:14206–14229` | 24 | R4/R11 |
| B? | `story_choice_commit_available` | `systems/DemoCoreLoopV2.gd:14231–14242` | 12 | R4/R11 |
| B? | `_demo_collision_candidate_ids` | `systems/DemoCoreLoopV2.gd:14244–14277` | 34 | R4/R11 |
| B? | `has_hanbit_employment_provenance` | `systems/DemoCoreLoopV2.gd:14279–14343` | 65 | R4/R11 |
| B? | `completion_snapshot_has_hanbit_employment_provenance` | `systems/DemoCoreLoopV2.gd:14351–14489` | 139 | R4/R11 |
| B? | `_demo_person_obligation` | `systems/DemoCoreLoopV2.gd:14491–14514` | 24 | R4/R11 |
| B? | `_has_relationship_memory` | `systems/DemoCoreLoopV2.gd:14516–14525` | 10 | R4/R11 |
| B? | `_consequence_was_presented` | `systems/DemoCoreLoopV2.gd:14527–14582` | 56 | R4/R11 |
| B? | `consequence_receipt_has_root` | `systems/DemoCoreLoopV2.gd:14584–14601` | 18 | R4/R11 |
| B? | `prepare_story_bundle` | `systems/DemoCoreLoopV2.gd:14603–14619` | 17 | R4/R11 |
| B? | `story_follow_up_is_suppressed` | `systems/DemoCoreLoopV2.gd:14621–14627` | 7 | R4/R11 |
| B? | `restore_story_bundle_followups` | `systems/DemoCoreLoopV2.gd:14629–14632` | 4 | R4/R11 |
| B? | `forgone_for_month` | `systems/DemoCoreLoopV2.gd:14634–14640` | 7 | R4/R11 |
| B? | `relationship_stage` | `systems/DemoCoreLoopV2.gd:14642–14646` | 5 | R4/R11 |
| B? | `was_player_initiated` | `systems/DemoCoreLoopV2.gd:14648–14650` | 3 | R4/R11 |
| B? | `note_story_choice` | `systems/DemoCoreLoopV2.gd:14652–14736` | 85 | R4/R11 |
| B? | `_ensure_hyunsu_exam_outcome_receipt` | `systems/DemoCoreLoopV2.gd:14738–14788` | 51 | R4/R11 |
| B? | `_recover_missing_hyunsu_exam_outcome_receipt` | `systems/DemoCoreLoopV2.gd:14790–14834` | 45 | R4/R11 |
| B? | `_hyunsu_unanswered_recovery_is_proven` | `systems/DemoCoreLoopV2.gd:14836–14859` | 24 | R4/R11 |
| B? | `_forgone_bundle_recorded` | `systems/DemoCoreLoopV2.gd:14861–14870` | 10 | R4/R11 |
| B? | `_hyunsu_exam_outcome_receipt_valid` | `systems/DemoCoreLoopV2.gd:14872–14909` | 38 | R4/R11 |
| B? | `_ensure_city_result_receipt` | `systems/DemoCoreLoopV2.gd:14911–14951` | 41 | R4/R11 |
| B? | `_recover_missing_city_result_receipt` | `systems/DemoCoreLoopV2.gd:14953–14986` | 34 | R4/R11 |
| B? | `_exact_city_obligation_receipt_matches` | `systems/DemoCoreLoopV2.gd:14988–15020` | 33 | R4/R11 |
| B? | `_city_result_receipt_valid` | `systems/DemoCoreLoopV2.gd:15022–15050` | 29 | R4/R11 |
| B? | `_story_choice_declares_outcome` | `systems/DemoCoreLoopV2.gd:15052–15072` | 21 | R4/R11 |
| B? | `_story_choice_is_deferred_callback` | `systems/DemoCoreLoopV2.gd:15074–15081` | 8 | R4/R11 |
| B? | `_exact_deferred_story_choice_matches` | `systems/DemoCoreLoopV2.gd:15083–15125` | 43 | R4/R11 |
| B? | `_note_generic_story_choice` | `systems/DemoCoreLoopV2.gd:15127–15196` | 70 | R4/R11 |
| B? | `_current_story_event_scope_present` | `systems/DemoCoreLoopV2.gd:15198–15222` | 25 | R4/R11 |
| B? | `_note_deferred_callback_story_choice` | `systems/DemoCoreLoopV2.gd:15224–15267` | 44 | R4/R11 |
| B? | `_note_obligation_story_choice` | `systems/DemoCoreLoopV2.gd:15269–15335` | 67 | R4/R11 |
| B? | `_obligation_id_for_choice` | `systems/DemoCoreLoopV2.gd:15337–15363` | 27 | R4/R11 |
| B? | `_note_relationship_story_choice` | `systems/DemoCoreLoopV2.gd:15365–15489` | 125 | R4/R11 |
| B? | `_relationship_advanced_in_month` | `systems/DemoCoreLoopV2.gd:15491–15502` | 12 | R4/R11 |
| B? | `_current_relationship_receipt_valid` | `systems/DemoCoreLoopV2.gd:15504–15591` | 88 | R4/R11 |
| B? | `_note_application_story_choice` | `systems/DemoCoreLoopV2.gd:15593–15641` | 49 | R4/R11 |
| B? | `_story_outcome_owner_id` | `systems/DemoCoreLoopV2.gd:15643–15661` | 19 | R4/R11 |
| B? | `_bundle_declares_event_outcome` | `systems/DemoCoreLoopV2.gd:15663–15675` | 13 | R4/R11 |
| B? | `_outcome_choice_matches` | `systems/DemoCoreLoopV2.gd:15677–15687` | 11 | R4/R11 |
| B? | `_bundle_requirement_met` | `systems/DemoCoreLoopV2.gd:15689–15755` | 67 | R4/R11 |
| B? | `_predicate_met` | `systems/DemoCoreLoopV2.gd:15757–15878` | 122 | R4/R11 |
| B? | `_action_receipt_predicate_met` | `systems/DemoCoreLoopV2.gd:15880–15955` | 76 | R4/R11 |
| B? | `_exact_live_action_weekly_commitment` | `systems/DemoCoreLoopV2.gd:15957–15982` | 26 | R4/R11 |
| B? | `_seoul_cycle_receipts_include_track` | `systems/DemoCoreLoopV2.gd:15984–16006` | 23 | R4/R11 |
| B? | `_normalized_schedule` | `systems/DemoCoreLoopV2.gd:16008–16017` | 10 | R4/R11 |
| B? | `_normalized_player_trigger_ids` | `systems/DemoCoreLoopV2.gd:16019–16032` | 14 | R4/R11 |
| B? | `_seoul_cycle_raw_has_terminal_binding` | `systems/DemoCoreLoopV2.gd:16034–16045` | 12 | R4/R11 |
| B? | `_seoul_cycle_plan_has_terminal_binding` | `systems/DemoCoreLoopV2.gd:16047–16050` | 4 | R4/R11 |
| B? | `_terminal_target_binding_witness_key` | `systems/DemoCoreLoopV2.gd:16052–16054` | 3 | R4/R11 |
| B? | `_terminal_target_binding_witness_for_month_present` | `systems/DemoCoreLoopV2.gd:16056–16066` | 11 | R4/R11 |
| B? | `_terminal_transition_resolution_for_month_present` | `systems/DemoCoreLoopV2.gd:16068–16090` | 23 | R4/R11 |
| B? | `_terminal_target_binding_witnesses_globally_valid` | `systems/DemoCoreLoopV2.gd:16092–16248` | 157 | R4/R11 |
| B? | `_normalized_terminal_identity_ids` | `systems/DemoCoreLoopV2.gd:16250–16261` | 12 | R4/R11 |
| B? | `normalize_seoul_cycle_state` | `systems/DemoCoreLoopV2.gd:16265–17099` | 835 | R4/R11 |
| B? | `_seoul_cycle_receipt_dictionary` | `systems/DemoCoreLoopV2.gd:17101–17109` | 9 | R4/R11 |
| B? | `_terminal_active_allocation_envelope_valid` | `systems/DemoCoreLoopV2.gd:17111–17162` | 52 | R4/R11 |
| B? | `_normalize_seoul_cycle_terminal_identity` | `systems/DemoCoreLoopV2.gd:17164–17434` | 271 | R4/R11 |
| B? | `_terminal_active_node_expiry_valid` | `systems/DemoCoreLoopV2.gd:17436–17485` | 50 | R4/R11 |
| B? | `_terminal_live_resolutions_valid` | `systems/DemoCoreLoopV2.gd:17487–17598` | 112 | R4/R11 |
| B? | `_normalize_seoul_cycle_player_trigger_identity` | `systems/DemoCoreLoopV2.gd:17600–17717` | 118 | R4/R11 |
| B? | `_seoul_cycle_outer_weekly_identity_valid` | `systems/DemoCoreLoopV2.gd:17724–17866` | 143 | R4/R11 |
| B? | `_seoul_cycle_world_receipt_dictionary` | `systems/DemoCoreLoopV2.gd:17873–17917` | 45 | R4/R11 |
| B? | `_normalized_seoul_cycle_pending` | `systems/DemoCoreLoopV2.gd:17919–17947` | 29 | R4/R11 |
| B? | `_seoul_cycle_world_bundle_authored_for_week` | `systems/DemoCoreLoopV2.gd:17955–17982` | 28 | R4/R11 |
| B? | `_normalized_w1_onboarding` | `systems/DemoCoreLoopV2.gd:17984–18023` | 40 | R4/R11 |
| B? | `_validate_w1_onboarding_cycle_override` | `systems/DemoCoreLoopV2.gd:18025–18078` | 54 | R4/R11 |
| B? | `_legacy_040746_dictionary_has_allowed_keys` | `systems/DemoCoreLoopV2.gd:18080–18096` | 17 | R4/R11 |
| B? | `_legacy_040746_routine_selection_valid` | `systems/DemoCoreLoopV2.gd:18098–18109` | 12 | R4/R11 |
| B? | `_legacy_040746_plan_valid` | `systems/DemoCoreLoopV2.gd:18111–18199` | 89 | R4/R11 |
| B? | `_legacy_040746_completed_topology_valid` | `systems/DemoCoreLoopV2.gd:18201–18262` | 62 | R4/R11 |
| B? | `_legacy_040746_routine_effect_valid` | `systems/DemoCoreLoopV2.gd:18264–18282` | 19 | R4/R11 |
| B? | `_legacy_040746_routine_receipt_valid` | `systems/DemoCoreLoopV2.gd:18284–18340` | 57 | R4/R11 |
| B? | `_legacy_040746_routine_ledger_valid` | `systems/DemoCoreLoopV2.gd:18342–18385` | 44 | R4/R11 |
| B? | `_legacy_040746_month_summary_valid` | `systems/DemoCoreLoopV2.gd:18387–18485` | 99 | R4/R11 |
| B? | `_legacy_040746_summary_ledger_valid` | `systems/DemoCoreLoopV2.gd:18487–18522` | 36 | R4/R11 |
| B? | `_legacy_040746_decline_record` | `systems/DemoCoreLoopV2.gd:18524–18562` | 39 | R4/R11 |
| B? | `_legacy_040746_forgone_and_declines_valid` | `systems/DemoCoreLoopV2.gd:18564–18614` | 51 | R4/R11 |
| B? | `_legacy_040746_pending_commitment_valid` | `systems/DemoCoreLoopV2.gd:18616–18659` | 44 | R4/R11 |
| B? | `_legacy_040746_pending_baseline_matches_current` | `systems/DemoCoreLoopV2.gd:18661–18669` | 9 | R4/R11 |
| B? | `_legacy_040746_active_and_pending_valid` | `systems/DemoCoreLoopV2.gd:18671–18754` | 84 | R4/R11 |
| B? | `_legacy_040746_relationship_ledgers_valid` | `systems/DemoCoreLoopV2.gd:18756–18843` | 88 | R4/R11 |
| B? | `_terminal_array_has_integral_turn` | `systems/DemoCoreLoopV2.gd:18845–18850` | 6 | R4/R11 |
| B? | `_legacy_040746_shown_ledgers_valid` | `systems/DemoCoreLoopV2.gd:18852–18919` | 68 | R4/R11 |
| B? | `_legacy_040746_core_state_valid` | `systems/DemoCoreLoopV2.gd:18921–18958` | 38 | R4/R11 |
| B? | `_legacy_040746_numeric_outcome_value_valid` | `systems/DemoCoreLoopV2.gd:18960–18964` | 5 | R4/R11 |
| B? | `_legacy_040746_clamped_outcome_delta_valid` | `systems/DemoCoreLoopV2.gd:18966–18980` | 15 | R4/R11 |
| B? | `_legacy_040746_clamped_outcome_matches_any` | `systems/DemoCoreLoopV2.gd:18982–19000` | 19 | R4/R11 |
| B? | `_legacy_040746_action_weekly_record_valid` | `systems/DemoCoreLoopV2.gd:19002–19138` | 137 | R4/R11 |
| B? | `_legacy_040746_flag_matches` | `systems/DemoCoreLoopV2.gd:19140–19145` | 6 | R4/R11 |
| B? | `_legacy_040746_active_story_choice_from_flags` | `systems/DemoCoreLoopV2.gd:19147–19170` | 24 | R4/R11 |
| B? | `_legacy_040746_active_story_flags_valid` | `systems/DemoCoreLoopV2.gd:19172–19203` | 32 | R4/R11 |
| B? | `_legacy_040746_temptation_story_record_valid` | `systems/DemoCoreLoopV2.gd:19205–19236` | 32 | R4/R11 |
| B? | `_legacy_040746_convenience_tuple_valid` | `systems/DemoCoreLoopV2.gd:19238–19272` | 35 | R4/R11 |
| B? | `_legacy_040746_weekly_record_valid` | `systems/DemoCoreLoopV2.gd:19274–19365` | 92 | R4/R11 |
| B? | `_legacy_040746_weekly_witnesses_valid` | `systems/DemoCoreLoopV2.gd:19367–19422` | 56 | R4/R11 |
| B? | `_legacy_040746_delivery_tuple_valid` | `systems/DemoCoreLoopV2.gd:19427–19493` | 67 | R4/R11 |
| B? | `_legacy_040746_rain_weekly_witness` | `systems/DemoCoreLoopV2.gd:19495–19530` | 36 | R4/R11 |
| B? | `_legacy_040746_origin_witness_valid` | `systems/DemoCoreLoopV2.gd:19532–19562` | 31 | R4/R11 |
| B? | `_legacy_040746_origin_from_state` | `systems/DemoCoreLoopV2.gd:19564–19580` | 17 | R4/R11 |
| B? | `_legacy_040746_plan_origin_entry` | `systems/DemoCoreLoopV2.gd:19582–19604` | 23 | R4/R11 |
| B? | `_legacy_040746_plan_origin_entry_valid` | `systems/DemoCoreLoopV2.gd:19606–19662` | 57 | R4/R11 |
| B? | `_normalized_legacy_040746_plan_origins` | `systems/DemoCoreLoopV2.gd:19664–19721` | 58 | R4/R11 |
| B? | `_legacy_040746_plan_origin_from_state` | `systems/DemoCoreLoopV2.gd:19723–19739` | 17 | R4/R11 |
| B? | `legacy_plan_origin_receipt` | `systems/DemoCoreLoopV2.gd:19741–19743` | 3 | R4/R11 |
| B? | `_install_legacy_040746_plan_origin` | `systems/DemoCoreLoopV2.gd:19745–19767` | 23 | R4/R11 |
| B? | `_mint_legacy_040746_origin` | `systems/DemoCoreLoopV2.gd:19769–19793` | 25 | R4/R11 |
| B? | `_normalized_legacy_action_migration` | `systems/DemoCoreLoopV2.gd:19795–19875` | 81 | R4/R11 |
| B? | `_normalized_legacy_origin_migration` | `systems/DemoCoreLoopV2.gd:19877–19911` | 35 | R4/R11 |
| B? | `legacy_origin_receipt` | `systems/DemoCoreLoopV2.gd:19913–19915` | 3 | R4/R11 |
| B? | `_legacy_040746_active_source_owner` | `systems/DemoCoreLoopV2.gd:19917–19927` | 11 | R4/R11 |
| B? | `legacy_active_story_roots` | `systems/DemoCoreLoopV2.gd:19932–19941` | 10 | R4/R11 |
| B? | `legacy_active_story_completion_ready` | `systems/DemoCoreLoopV2.gd:19947–19973` | 27 | R4/R11 |
| B? | `_install_legacy_040746_active_story_authority` | `systems/DemoCoreLoopV2.gd:19975–20023` | 49 | R4/R11 |
| D | `_normalized_state` | `systems/DemoCoreLoopV2.gd:20025–20243` | 219 | R4/R11 |
| B? | `_normalized_authority_shape_poison` | `systems/DemoCoreLoopV2.gd:20245–20275` | 31 | R4/R11 |
| B? | `_authority_absence_shape_poisoned` | `systems/DemoCoreLoopV2.gd:20277–20280` | 4 | R4/R11 |
| B? | `_clear_terminal_authority_from_month_summaries` | `systems/DemoCoreLoopV2.gd:20282–20298` | 17 | R4/R11 |
| B? | `_quarantine_terminal_authority` | `systems/DemoCoreLoopV2.gd:20300–20305` | 6 | R4/R11 |
| B? | `_recover_finalized_action_state` | `systems/DemoCoreLoopV2.gd:20307–20423` | 117 | R4/R11 |
| B? | `_migrate_schema_two_relationship_state` | `systems/DemoCoreLoopV2.gd:20425–20529` | 105 | R4/R11 |
| B? | `_legacy_relationship_receipt_identity` | `systems/DemoCoreLoopV2.gd:20531–20545` | 15 | R4/R11 |
| B? | `opening_application_provenance_valid` | `systems/DemoCoreLoopV2.gd:20547–20549` | 3 | R4/R11 |
| B? | `_opening_application_provenance_valid` | `systems/DemoCoreLoopV2.gd:20551–20562` | 12 | R4/R11 |
| B? | `_relationship_outcome_for_choice` | `systems/DemoCoreLoopV2.gd:20564–20593` | 30 | R4/R11 |
| D | `preload/선언·주석/공백 등 위 함수 범위의 보집합` | `systems/DemoCoreLoopV2.gd` 위 범위 외 | 1033 | R4/R5: 파일 의존성 |
| D | `스크립트 UID` | `systems/DemoCoreLoopV2.gd.uid:1` | 1 | R5: 의존 스크립트 동반 |

</details>

### 계약·공유 파일과 복선

<details>
<summary>54 항목</summary>

| 분류 | 함수·키 | 파일:줄 | 줄 수 | 근거·등록 |
| --- | --- | --- | ---: | --- |
| D | `schema_version` | `content/meta/demo_core_loop_v2.json:2` | 1 | R3/R4 |
| B? | `status` | `content/meta/demo_core_loop_v2.json:3` | 1 | R3/R4 |
| D | `runtime_default` | `content/meta/demo_core_loop_v2.json:4` | 1 | R3/R4 |
| B? | `fallback` | `content/meta/demo_core_loop_v2.json:5` | 1 | R3/R4 |
| D | `scope` | `content/meta/demo_core_loop_v2.json:6–15` | 10 | R3/R4 |
| B? | `speech_contract` | `content/meta/demo_core_loop_v2.json:16–59` | 44 | R3/R4 |
| D | `legacy_callback_retirements` | `content/meta/demo_core_loop_v2.json:60–82` | 23 | R3/R4 |
| B? | `long_arc_contract` | `content/meta/demo_core_loop_v2.json:83–110` | 28 | R3/R4 |
| B? | `future_application_contracts` | `content/meta/demo_core_loop_v2.json:111–134` | 24 | R3/R4 |
| B? | `future_story_contracts` | `content/meta/demo_core_loop_v2.json:135–156` | 22 | R3/R4 |
| B? | `post_demo_application_contracts` | `content/meta/demo_core_loop_v2.json:157–171` | 15 | R3/R4 |
| B? | `deferred_callback_contracts` | `content/meta/demo_core_loop_v2.json:172–184` | 13 | R3/R4 |
| B? | `surface` | `content/meta/demo_core_loop_v2.json:185–197` | 13 | R3/R4 |
| B? | `episode_plan` | `content/meta/demo_core_loop_v2.json:198–238` | 41 | R3/R4 |
| B? | `seoul_cycle` | `content/meta/demo_core_loop_v2.json:239–1324` | 1086 | R3/R4 |
| B? | `phone` | `content/meta/demo_core_loop_v2.json:1325–1347` | 23 | R3/R4 |
| B? | `routine의 외곽/공통` | `content/meta/demo_core_loop_v2.json:1348–1357` | 10 | R3/R4 |
| D | `routine.options.livelihood` | `content/meta/demo_core_loop_v2.json:1358–1386` | 29 | R3/R4 |
| D | `routine.options.recovery 및 닫는 줄` | `content/meta/demo_core_loop_v2.json:1387–1399` | 13 | R3/R4 |
| B? | `relationship` | `content/meta/demo_core_loop_v2.json:1400–1419` | 20 | R3/R4 |
| B? | `exclusive_groups` | `content/meta/demo_core_loop_v2.json:1420–1442` | 23 | R3/R4 |
| B? | `decline_outcomes` | `content/meta/demo_core_loop_v2.json:1443–1830` | 388 | R3/R4 |
| B? | `scene_bundles` | `content/meta/demo_core_loop_v2.json:1831–4713` | 2883 | R3/R4 |
| B? | `months` | `content/meta/demo_core_loop_v2.json:4714–4853` | 140 | R3/R4 |
| D | `JSON 외곽` | `content/meta/demo_core_loop_v2.json:1`; `content/meta/demo_core_loop_v2.json:4854` | 2 | R4 |
| D | `choices[].foreshadow` | `content/events/arc_events.json:1881` | 1 | R6 |
| D | `choices[].foreshadow` | `content/events/arc_events.json:1898` | 1 | R6 |
| B | `choices[].foreshadow` | `content/events/ng_plus_events.json:38` | 1 | R6 |
| B | `choices[].foreshadow` | `content/events/ng_plus_events.json:168` | 1 | R6 |
| B | `choices[].foreshadow` | `content/events/arc_drama.json:347` | 1 | R6 |
| B | `choices[].foreshadow` | `content/events/arc_drama.json:747` | 1 | R6 |
| C | `파일 전체` | `content/meta/chapter1_core_loop_v2_causal_ledger.json:1–55806` | 55806 | R12 |
| D | `파일 전체` | `content/meta/demo_localization_scope.json:1–2697` | 2697 | R5/R8 |
| C | `파일 전체` | `content/meta/event_lifecycle.json:1–150` | 150 | R12 |
| C | `파일 전체` | `content/meta/release_content_inventory.json:1–855` | 855 | R12 |
| D | `파일 전체` | `playtests/order124/StoryChoiceM1M6Playtest.gd:1–3122` | 3122 | R9/R11 |
| D | `파일 전체` | `playtests/order124/StoryChoiceM1M6Playtest.gd.uid:1` | 1 | R9/R11 |
| D | `파일 전체` | `playtests/order124/StoryChoiceM1M6Playtest.tscn:1–12` | 12 | R9/R11 |
| D | `파일 전체` | `scenes/BigWheelGame.gd:1–1121` | 1121 | R5/R8 |
| D | `파일 전체` | `scenes/BigWheelGame.gd.uid:1` | 1 | R5/R8 |
| D | `파일 전체` | `scenes/HoldemClub.gd:1–1793` | 1793 | R5/R8 |
| D | `파일 전체` | `scenes/HoldemClub.gd.uid:1` | 1 | R5/R8 |
| D | `파일 전체` | `scenes/JeongseonCasino.gd:1–903` | 903 | R5/R8 |
| D | `파일 전체` | `scenes/JeongseonCasino.gd.uid:1` | 1 | R5/R8 |
| D | `파일 전체` | `scenes/RaceTrack.gd:1–1416` | 1416 | R5/R8 |
| D | `파일 전체` | `scenes/RaceTrack.gd.uid:1` | 1 | R5/R8 |
| D | `파일 전체` | `scenes/RouletteTable.gd:1–1560` | 1560 | R5/R8 |
| D | `파일 전체` | `scenes/RouletteTable.gd.uid:1` | 1 | R5/R8 |
| D | `파일 전체` | `scenes/ScalpingGame.gd:1–784` | 784 | R5/R8 |
| D | `파일 전체` | `scenes/ScalpingGame.gd.uid:1` | 1 | R5/R8 |
| D | `파일 전체` | `scenes/SlotMachineGame.gd:1–1502` | 1502 | R5/R8 |
| D | `파일 전체` | `scenes/SlotMachineGame.gd.uid:1` | 1 | R5/R8 |
| D | `파일 전체` | `scenes/TutorialOverlay.gd:1–922` | 922 | R5/R8 |
| D | `파일 전체` | `scenes/TutorialOverlay.gd.uid:1` | 1 | R5/R8 |

</details>

### author-only 및 V2 사건

111 author-only ID 및 V2 파일 38 ID(합집합 149)를 KO 및 현존 overlay 범위로 열거. R7 보류는 실저장 관측이 아니다.

<details>
<summary>149 항목</summary>

| 분류 | 함수·키 | 파일:줄 | 줄 수 | 근거·등록 |
| --- | --- | --- | ---: | --- |
| B? | `arc_final_countdown_career_executed` | `content/events/arc_pre_ending.json:1850–1868`; `content/events_en/arc_pre_ending.json:897–906` | 29 | R7 |
| B? | `arc_final_countdown_filed_not_executed` | `content/events/arc_pre_ending.json:1601–1619`; `content/events_en/arc_pre_ending.json:769–778` | 29 | R7 |
| B? | `arc_final_countdown_not_executed` | `content/events/arc_pre_ending.json:890–954`; `content/events_en/arc_pre_ending.json:412–430` | 84 | R7 |
| B? | `arc_final_countdown_other_filing_executed` | `content/events/arc_pre_ending.json:1419–1437`; `content/events_en/arc_pre_ending.json:673–682` | 29 | R7 |
| B? | `arc_final_countdown_startup_executed` | `content/events/arc_pre_ending.json:2027–2045`; `content/events_en/arc_pre_ending.json:984–993` | 29 | R7 |
| B? | `arc_y1_close_hyunsu_call` | `content/events/arc_year_close.json:407–432`; `content/events_en/arc_year_close.json:189–207` | 45 | R7 |
| B? | `arc_y1_current_route_open_door` | `content/events/arc_events.json:2170–2205`; `content/events_en/arc_events.json:680–698` | 55 | R7 |
| B? | `arc_y1_daeun_second_crossing` | `content/events/arc_daeun.json:68–101`; `content/events_en/arc_daeun.json:17–35` | 53 | R7 |
| B? | `arc_y1_hyunsu_relationship_reentry` | `content/events/arc_hyunsu.json:197–225`; `content/events_en/arc_hyunsu.json:83–101` | 48 | R7 |
| B? | `arc_y1_hyunsu_result_fail_after_move` | `content/events/arc_hyunsu.json:167–196`; `content/events_en/arc_hyunsu.json:63–82` | 50 | R7 |
| B? | `arc_y1_jaehyuk_open_door` | `content/events/arc_events.json:2098–2133`; `content/events_en/arc_events.json:642–660` | 55 | R7 |
| B? | `arc_y1_jiyeon_first_bill_date` | `content/events/arc_events.json:2026–2061`; `content/events_en/arc_events.json:604–622` | 55 | R7 |
| B? | `arc_y1_jiyeon_relationship_reentry` | `content/events/arc_events.json:2062–2097`; `content/events_en/arc_events.json:623–641` | 55 | R7 |
| B? | `arc_y1_jiyeon_second_crossing` | `content/events/arc_events.json:1990–2025`; `content/events_en/arc_events.json:585–603` | 55 | R7 |
| B? | `arc_y1_open_door_none` | `content/events/arc_events.json:2206–2240`; `content/events_en/arc_events.json:699–717` | 54 | R7 |
| B? | `arc_y1_relationship_reentry_none` | `content/events/arc_midgame.json:3694–3719`; `content/events_en/arc_midgame.json:1276–1294` | 45 | R7 |
| B? | `arc_y1_sangchul_open_door` | `content/events/arc_events.json:2134–2169`; `content/events_en/arc_events.json:661–679` | 55 | R7 |
| B? | `arc_y2_casino_chosen_door` | `content/events/arc_chapter_themes.json:681–717`; `content/events_en/arc_chapter_themes.json:267–285` | 56 | R7 |
| B? | `arc_y2_chosen_door_none` | `content/events/arc_chapter_themes.json:718–753`; `content/events_en/arc_chapter_themes.json:286–304` | 55 | R7 |
| B? | `arc_y2_daeun_relationship_fork` | `content/events/arc_daeun.json:416–451`; `content/events_en/arc_daeun.json:118–136` | 55 | R7 |
| B? | `arc_y2_hospital_door` | `content/events/arc_midgame.json:3807–3841`; `content/events_en/arc_midgame.json:1333–1351` | 54 | R7 |
| B? | `arc_y2_jiyeon_chosen_door` | `content/events/arc_chapter_themes.json:644–680`; `content/events_en/arc_chapter_themes.json:248–266` | 56 | R7 |
| B? | `arc_y2_jiyeon_relationship_fork` | `content/events/arc_events.json:774–809`; `content/events_en/arc_events.json:221–239` | 55 | R7 |
| B? | `arc_y2_money_structure` | `content/events/arc_chapter_themes.json:489–524`; `content/events_en/arc_chapter_themes.json:172–190` | 55 | R7 |
| B? | `arc_y2_open_door_cost` | `content/events/arc_chapter_themes.json:754–790`; `content/events_en/arc_chapter_themes.json:305–323` | 56 | R7 |
| B? | `arc_y2_open_door_cost_cancel_repeat` | `content/events/arc_chapter_themes.json:828–864`; `content/events_en/arc_chapter_themes.json:343–361` | 56 | R7 |
| B? | `arc_y2_open_door_cost_explanation` | `content/events/arc_chapter_themes.json:791–827`; `content/events_en/arc_chapter_themes.json:324–342` | 56 | R7 |
| B? | `arc_y2_sangchul_chosen_door` | `content/events/arc_chapter_themes.json:607–643`; `content/events_en/arc_chapter_themes.json:229–247` | 56 | R7 |
| B? | `arc_y2_sangchul_source_review` | `content/events/arc_chapter_themes.json:570–606`; `content/events_en/arc_chapter_themes.json:210–228` | 56 | R7 |
| B? | `arc_y2_year_boss_receipts` | `content/events/arc_year_close.json:149–188`; `content/events_en/arc_year_close.json:79–101` | 63 | R7 |
| B? | `arc_y3_birthday_father_call` | `content/events/arc_midgame.json:3000–3037`; `content/events_en/arc_midgame.json:1014–1032` | 57 | R7 |
| B? | `arc_y3_cost_after_buried` | `content/events/arc_year3_drama.json:1102–1130`; `content/events_en/arc_year3_drama.json:350–360` | 40 | R7 |
| B? | `arc_y3_cost_after_distanced` | `content/events/arc_year3_drama.json:1131–1159`; `content/events_en/arc_year3_drama.json:361–371` | 40 | R7 |
| B? | `arc_y3_cost_after_forgiven` | `content/events/arc_year3_drama.json:1015–1043`; `content/events_en/arc_year3_drama.json:317–327` | 40 | R7 |
| B? | `arc_y3_cost_after_leveraged` | `content/events/arc_year3_drama.json:1044–1072`; `content/events_en/arc_year3_drama.json:328–338` | 40 | R7 |
| B? | `arc_y3_cost_after_repaid` | `content/events/arc_year3_drama.json:1073–1101`; `content/events_en/arc_year3_drama.json:339–349` | 40 | R7 |
| B? | `arc_y3_cost_after_reported` | `content/events/arc_year3_drama.json:986–1014`; `content/events_en/arc_year3_drama.json:306–316` | 40 | R7 |
| B? | `arc_y3_daeun_hometown_departure` | `content/events/arc_daeun_extension.json:355–390`; `content/events_en/arc_daeun_extension.json:110–128` | 55 | R7 |
| B? | `arc_y3_father_after_visit_document` | `content/events/arc_events.json:1099–1134`; `content/events_en/arc_events.json:310–328` | 55 | R7 |
| B? | `arc_y3_jaehyuk_no_contact` | `content/events/arc_events.json:1183–1217`; `content/events_en/arc_events.json:348–366` | 54 | R7 |
| B? | `arc_y3_jaehyuk_pitch_questions` | `content/events/arc_events.json:1218–1253`; `content/events_en/arc_events.json:367–385` | 55 | R7 |
| B? | `arc_y3_jaehyuk_waiting_screen` | `content/events/arc_midgame.json:943–977`; `content/events_en/arc_midgame.json:307–325` | 54 | R7 |
| B? | `arc_y3_jiyeon_departure_platform` | `content/events/arc_year3_drama.json:911–947`; `content/events_en/arc_year3_drama.json:268–286` | 56 | R7 |
| B? | `arc_y3_relationship_departure_unattached` | `content/events/arc_year3_drama.json:948–985`; `content/events_en/arc_year3_drama.json:287–305` | 57 | R7 |
| B? | `arc_y3_truth_heard_by_father` | `content/events/arc_year3_drama.json:1160–1197`; `content/events_en/arc_year3_drama.json:372–390` | 57 | R7 |
| B? | `arc_y3_truth_heard_by_hyunsu` | `content/events/arc_year3_drama.json:1198–1234`; `content/events_en/arc_year3_drama.json:391–409` | 56 | R7 |
| B? | `arc_y3_truth_heard_by_none` | `content/events/arc_year3_drama.json:1235–1271`; `content/events_en/arc_year3_drama.json:410–428` | 56 | R7 |
| B? | `arc_y3_truth_unproven` | `content/events/arc_drama.json:1682–1718`; `content/events_en/arc_drama.json:654–672` | 56 | R7 |
| B? | `arc_y4_bill_night_jiyeon` | `content/events/arc_chapter_themes.json:1714–1777`; `content/events_en/arc_chapter_themes.json:699–724`; `content/events_ja/arc_chapter_themes.json:471–496`; `content/events_zh-CN/arc_chapter_themes.json:405–430`; `content/events_zh-TW/arc_chapter_themes.json:471–496` | 168 | R7 |
| B? | `arc_y4_body_witness_jiyeon` | `content/events/arc_chapter_themes.json:1106–1160`; `content/events_en/arc_chapter_themes.json:458–481`; `content/events_ja/arc_chapter_themes.json:230–253`; `content/events_zh-CN/arc_chapter_themes.json:230–253`; `content/events_zh-TW/arc_chapter_themes.json:230–253` | 151 | R7 |
| B? | `arc_y4_borrowed_name_jiyeon` | `content/events/arc_chapter_themes.json:1491–1543`; `content/events_en/arc_chapter_themes.json:607–628`; `content/events_ja/arc_chapter_themes.json:379–400`; `content/events_zh-CN/arc_chapter_themes.json:479–500`; `content/events_zh-TW/arc_chapter_themes.json:379–400` | 141 | R7 |
| B? | `arc_y4_family_partner_collision_jiyeon` | `content/events/arc_chapter_themes.json:1276–1329`; `content/events_en/arc_chapter_themes.json:528–546`; `content/events_ja/arc_chapter_themes.json:300–318`; `content/events_zh-CN/arc_chapter_themes.json:300–318`; `content/events_zh-TW/arc_chapter_themes.json:300–318` | 130 | R7 |
| B? | `arc_y4_three_promises_jiyeon_and_deal` | `content/events/arc_chapter_themes.json:927–988`; `content/events_en/arc_chapter_themes.json:386–409`; `content/events_ja/arc_chapter_themes.json:106–129`; `content/events_zh-CN/arc_chapter_themes.json:106–129`; `content/events_zh-TW/arc_chapter_themes.json:106–129` | 158 | R7 |
| B? | `arc_y4_year_close_jiyeon` | `content/events/arc_year_close.json:481–528`; `content/events_en/arc_year_close.json:232–255`; `content/events_ja/arc_year_close.json:130–153`; `content/events_zh-CN/arc_year_close.json:130–153`; `content/events_zh-TW/arc_year_close.json:130–153` | 144 | R7 |
| B? | `arc_y5_after_goal_hyunsu_career` | `content/events/arc_new_characters.json:404–440`; `content/events_en/arc_new_characters.json:177–195` | 56 | R7 |
| B? | `arc_y5_career_reviewer_receipt_minseo` | `content/events/arc_pre_ending.json:1703–1719`; `content/events_en/arc_pre_ending.json:822–829` | 25 | R7 |
| B? | `arc_y5_contract_cover_career` | `content/events/arc_midgame.json:4061–4096`; `content/events_en/arc_midgame.json:1474–1492` | 55 | R7 |
| B? | `arc_y5_contract_execution_career` | `content/events/arc_pre_ending.json:1814–1832`; `content/events_en/arc_pre_ending.json:879–888` | 29 | R7 |
| B? | `arc_y5_contract_execution_property` | `content/events/arc_pre_ending.json:1200–1235`; `content/events_en/arc_pre_ending.json:561–579` | 55 | R7 |
| B? | `arc_y5_contract_execution_property_jiyeon_filing` | `content/events/arc_pre_ending.json:1366–1384`; `content/events_en/arc_pre_ending.json:647–656` | 29 | R7 |
| B? | `arc_y5_contract_not_executed_notice` | `content/events/arc_pre_ending.json:1530–1546`; `content/events_en/arc_pre_ending.json:730–737` | 25 | R7 |
| B? | `arc_y5_contract_result_delivered_hyunsu_career` | `content/events/arc_pre_ending.json:1833–1849`; `content/events_en/arc_pre_ending.json:889–896` | 25 | R7 |
| B? | `arc_y5_contract_result_delivered_jiyeon` | `content/events/arc_pre_ending.json:1385–1401`; `content/events_en/arc_pre_ending.json:657–664` | 25 | R7 |
| B? | `arc_y5_contract_reviewer_delivery_minseo_career` | `content/events/arc_midgame.json:4097–4133`; `content/events_en/arc_midgame.json:1493–1511` | 56 | R7 |
| B? | `arc_y5_father_trace_alive_called` | `content/events/arc_year3_drama.json:1330–1367`; `content/events_en/arc_year3_drama.json:464–482` | 57 | R7 |
| B? | `arc_y5_father_trace_passed_called` | `content/events/arc_year3_drama.json:1272–1290`; `content/events_en/arc_year3_drama.json:429–438` | 29 | R7 |
| B? | `arc_y5_father_trace_passed_missed` | `content/events/arc_year3_drama.json:1553–1589`; `content/events_en/arc_year3_drama.json:603–621` | 56 | R7 |
| B? | `arc_y5_final_offer_career_boss` | `content/events/arc_pre_ending.json:1684–1702`; `content/events_en/arc_pre_ending.json:812–821` | 29 | R7 |
| B? | `arc_y5_final_offer_jiyeon_reference` | `content/events/arc_pre_ending.json:1236–1254`; `content/events_en/arc_pre_ending.json:580–589` | 29 | R7 |
| B? | `arc_y5_final_week_hyunsu_career_outbound` | `content/events/arc_drama.json:2236–2272`; `content/events_en/arc_drama.json:1008–1026` | 56 | R7 |
| B? | `arc_y5_final_week_hyunsu_outbound` | `content/events/arc_drama.json:2200–2235`; `content/events_en/arc_drama.json:989–1007` | 55 | R7 |
| B? | `arc_y5_final_week_jiyeon_outbound` | `content/events/arc_drama.json:2164–2199`; `content/events_en/arc_drama.json:970–988` | 55 | R7 |
| B? | `arc_y5_final_week_startup_after_acquisition` | `content/events/arc_drama.json:2273–2301`; `content/events_en/arc_drama.json:1027–1037` | 40 | R7 |
| B? | `arc_y5_key_and_remaining_person_jiyeon` | `content/events/arc_pre_ending.json:1402–1418`; `content/events_en/arc_pre_ending.json:665–672` | 25 | R7 |
| B? | `arc_y5_minseo_goal_cost_career` | `content/events/arc_new_characters.json:367–403`; `content/events_en/arc_new_characters.json:158–176` | 56 | R7 |
| B? | `arc_y5_name_copy_delivered_hyunsu_career` | `content/events/arc_pre_ending.json:1778–1794`; `content/events_en/arc_pre_ending.json:861–868` | 25 | R7 |
| B? | `arc_y5_name_copy_delivered_jiyeon` | `content/events/arc_pre_ending.json:1330–1346`; `content/events_en/arc_pre_ending.json:629–636` | 25 | R7 |
| B? | `arc_y5_name_copy_not_delivered_self` | `content/events/arc_pre_ending.json:1513–1529`; `content/events_en/arc_pre_ending.json:722–729` | 25 | R7 |
| B? | `arc_y5_name_on_line` | `content/events/arc_pre_ending.json:340–379`; `content/events_en/arc_pre_ending.json:170–192` | 63 | R7 |
| B? | `arc_y5_name_on_line_career_self` | `content/events/arc_pre_ending.json:1758–1777`; `content/events_en/arc_pre_ending.json:850–860` | 31 | R7 |
| B? | `arc_y5_name_on_line_jiyeon` | `content/events/arc_pre_ending.json:1310–1329`; `content/events_en/arc_pre_ending.json:618–628` | 31 | R7 |
| B? | `arc_y5_name_on_line_self` | `content/events/arc_pre_ending.json:1493–1512`; `content/events_en/arc_pre_ending.json:711–721` | 31 | R7 |
| B? | `arc_y5_people_verdict` | `content/events/arc_pre_ending.json:380–415`; `content/events_en/arc_pre_ending.json:193–211` | 55 | R7 |
| B? | `arc_y5_people_verdict_career_hyunsu` | `content/events/arc_pre_ending.json:1795–1813`; `content/events_en/arc_pre_ending.json:869–878` | 29 | R7 |
| B? | `arc_y5_people_verdict_daeun_routed` | `content/events/arc_pre_ending.json:1107–1142`; `content/events_en/arc_pre_ending.json:509–527` | 55 | R7 |
| B? | `arc_y5_people_verdict_jiyeon_routed` | `content/events/arc_pre_ending.json:1347–1365`; `content/events_en/arc_pre_ending.json:637–646` | 29 | R7 |
| B? | `arc_y5_protection_boundary_hyunsu_career` | `content/events/arc_midgame.json:4134–4171`; `content/events_en/arc_midgame.json:1512–1530` | 57 | R7 |
| B? | `arc_y5_protection_context_jiyeon_reference` | `content/events/arc_midgame.json:4024–4060`; `content/events_en/arc_midgame.json:1455–1473` | 56 | R7 |
| B? | `arc_y5_returned_documents_hyunsu` | `content/events/arc_pre_ending.json:1584–1600`; `content/events_en/arc_pre_ending.json:761–768` | 25 | R7 |
| B? | `arc_y5_room_consent_receipt_blocked_review` | `content/events/arc_pre_ending.json:1476–1492`; `content/events_en/arc_pre_ending.json:703–710` | 25 | R7 |
| B? | `arc_y5_room_consent_receipt_jiyeon` | `content/events/arc_pre_ending.json:1293–1309`; `content/events_en/arc_pre_ending.json:610–617` | 25 | R7 |
| B? | `arc_y5_startup_after_goal_cofounder` | `content/events/arc_new_characters.json:470–506`; `content/events_en/arc_new_characters.json:207–225` | 56 | R7 |
| B? | `arc_y5_startup_boundary_cofounder` | `content/events/arc_midgame.json:4230–4266`; `content/events_en/arc_midgame.json:1553–1571` | 56 | R7 |
| B? | `arc_y5_startup_c0_reviewer_delivery_minseo` | `content/events/arc_midgame.json:4201–4229`; `content/events_en/arc_midgame.json:1542–1552` | 40 | R7 |
| B? | `arc_y5_startup_c2_copy_delivered_cofounder` | `content/events/arc_pre_ending.json:1958–1974`; `content/events_en/arc_pre_ending.json:951–958` | 25 | R7 |
| B? | `arc_y5_startup_c2_sign_self` | `content/events/arc_pre_ending.json:1941–1957`; `content/events_en/arc_pre_ending.json:943–950` | 25 | R7 |
| B? | `arc_y5_startup_c3_copy_delivered_cofounder` | `content/events/arc_pre_ending.json:2010–2026`; `content/events_en/arc_pre_ending.json:976–983` | 25 | R7 |
| B? | `arc_y5_startup_contract_execution_c3` | `content/events/arc_pre_ending.json:1992–2009`; `content/events_en/arc_pre_ending.json:967–975` | 27 | R7 |
| B? | `arc_y5_startup_final_offer_acquirer` | `content/events/arc_pre_ending.json:1869–1887`; `content/events_en/arc_pre_ending.json:907–916` | 29 | R7 |
| B? | `arc_y5_startup_minseo_goal_cost` | `content/events/arc_new_characters.json:441–469`; `content/events_en/arc_new_characters.json:196–206` | 40 | R7 |
| B? | `arc_y5_startup_offer_c0` | `content/events/arc_midgame.json:4172–4200`; `content/events_en/arc_midgame.json:1531–1541` | 40 | R7 |
| B? | `arc_y5_startup_people_verdict_cofounder` | `content/events/arc_pre_ending.json:1975–1991`; `content/events_en/arc_pre_ending.json:959–966` | 25 | R7 |
| B? | `arc_y5_startup_reviewer_receipt_minseo` | `content/events/arc_pre_ending.json:1888–1904`; `content/events_en/arc_pre_ending.json:917–924` | 25 | R7 |
| B? | `arc_y5_startup_three_in_room` | `content/events/arc_pre_ending.json:1905–1921`; `content/events_en/arc_pre_ending.json:925–932` | 25 | R7 |
| B? | `arc_y5_startup_three_in_room_decision` | `content/events/arc_pre_ending.json:1922–1940`; `content/events_en/arc_pre_ending.json:933–942` | 29 | R7 |
| B? | `arc_y5_three_in_room_blocked_review` | `content/events/arc_pre_ending.json:1438–1456`; `content/events_en/arc_pre_ending.json:683–692` | 29 | R7 |
| B? | `arc_y5_three_in_room_career` | `content/events/arc_pre_ending.json:1720–1738`; `content/events_en/arc_pre_ending.json:830–839` | 29 | R7 |
| B? | `arc_y5_three_in_room_decision_blocked_review` | `content/events/arc_pre_ending.json:1457–1475`; `content/events_en/arc_pre_ending.json:693–702` | 29 | R7 |
| B? | `arc_y5_three_in_room_decision_career` | `content/events/arc_pre_ending.json:1739–1757`; `content/events_en/arc_pre_ending.json:840–849` | 29 | R7 |
| B? | `arc_y5_three_in_room_decision_other_actor` | `content/events/arc_pre_ending.json:1274–1292`; `content/events_en/arc_pre_ending.json:600–609` | 29 | R7 |
| B? | `arc_y5_three_in_room_other_actor` | `content/events/arc_pre_ending.json:1255–1273`; `content/events_en/arc_pre_ending.json:590–599` | 29 | R7 |
| B? | `v2_city_service_result_message` | `content/events/core_loop_v2_events.json:848–880`; `content/events_en/core_loop_v2_events.json:314–324`; `content/events_ja/core_loop_v2_events.json:314–324`; `content/events_zh-CN/core_loop_v2_events.json:314–324`; `content/events_zh-TW/core_loop_v2_events.json:314–324` | 77 | R3/R5 |
| B? | `v2_city_service_work_sample_message` | `content/events/core_loop_v2_events.json:817–847`; `content/events_en/core_loop_v2_events.json:303–313`; `content/events_ja/core_loop_v2_events.json:303–313`; `content/events_zh-CN/core_loop_v2_events.json:303–313`; `content/events_zh-TW/core_loop_v2_events.json:303–313` | 75 | R3/R5 |
| B? | `v2_convenience_trial_shift` | `content/events/core_loop_v2_events.json:1116–1145`; `content/events_en/core_loop_v2_events.json:415–425`; `content/events_ja/core_loop_v2_events.json:385–395`; `content/events_zh-CN/core_loop_v2_events.json:385–395`; `content/events_zh-TW/core_loop_v2_events.json:385–395` | 74 | R3/R5 |
| B? | `v2_daeun_return_after_distance` | `content/events/core_loop_v2_events.json:333–371`; `content/events_en/core_loop_v2_events.json:129–143`; `content/events_ja/core_loop_v2_events.json:129–143`; `content/events_zh-CN/core_loop_v2_events.json:129–143`; `content/events_zh-TW/core_loop_v2_events.json:129–143` | 99 | R3/R5 |
| B? | `v2_daeun_return_named` | `content/events/core_loop_v2_events.json:295–332`; `content/events_en/core_loop_v2_events.json:114–128`; `content/events_ja/core_loop_v2_events.json:114–128`; `content/events_zh-CN/core_loop_v2_events.json:114–128`; `content/events_zh-TW/core_loop_v2_events.json:114–128` | 98 | R3/R5 |
| B? | `v2_daeun_small_commitment` | `content/events/core_loop_v2_events.json:491–529`; `content/events_en/core_loop_v2_events.json:189–203`; `content/events_ja/core_loop_v2_events.json:189–203`; `content/events_zh-CN/core_loop_v2_events.json:189–203`; `content/events_zh-TW/core_loop_v2_events.json:189–203` | 99 | R3/R5 |
| B? | `v2_daeun_third_greeting` | `content/events/core_loop_v2_events.json:530–568`; `content/events_en/core_loop_v2_events.json:204–218`; `content/events_ja/core_loop_v2_events.json:204–218`; `content/events_zh-CN/core_loop_v2_events.json:204–218`; `content/events_zh-TW/core_loop_v2_events.json:204–218` | 99 | R3/R5 |
| B? | `v2_daeun_tuesday_followthrough` | `content/events/core_loop_v2_events.json:881–920`; `content/events_en/core_loop_v2_events.json:325–339`; `content/events_ja/core_loop_v2_events.json:325–339`; `content/events_zh-CN/core_loop_v2_events.json:325–339`; `content/events_zh-TW/core_loop_v2_events.json:325–339` | 100 | R3/R5 |
| D | `v2_demo_first_bill` | `content/events/core_loop_v2_events.json:1328–1447`; `content/events_en/core_loop_v2_events.json:508–546` | 159 | R11 |
| D | `v2_demo_first_bill_ledger` | `content/events/core_loop_v2_events.json:1448–1482`; `content/events_en/core_loop_v2_events.json:547–561` | 50 | R11 |
| D | `v2_demo_first_bill_opening` | `content/events/core_loop_v2_events.json:1280–1327`; `content/events_en/core_loop_v2_events.json:484–507`; `content/events_ja/core_loop_v2_events.json:454–477`; `content/events_zh-CN/core_loop_v2_events.json:454–477`; `content/events_zh-TW/core_loop_v2_events.json:454–477` | 144 | R11 |
| D | `v2_dirty_recruiter_week24` | `content/events/core_loop_v2_events.json:1032–1070`; `content/events_en/core_loop_v2_events.json:381–395` | 54 | R9/R11: 공개 M06 :28–29,901,2765 |
| D | `v2_dirty_trace_initial_call` | `content/events/core_loop_v2_events.json:992–1031`; `content/events_en/core_loop_v2_events.json:366–380` | 55 | R9/R11: 공개 M06 :28–29,892,2762 |
| B? | `v2_dodam_result_message` | `content/events/core_loop_v2_events.json:786–816`; `content/events_en/core_loop_v2_events.json:292–302`; `content/events_ja/core_loop_v2_events.json:292–302`; `content/events_zh-CN/core_loop_v2_events.json:292–302`; `content/events_zh-TW/core_loop_v2_events.json:292–302` | 75 | R3/R5 |
| B? | `v2_empty_sunday` | `content/events/core_loop_v2_events.json:1250–1279`; `content/events_en/core_loop_v2_events.json:473–483`; `content/events_ja/core_loop_v2_events.json:443–453`; `content/events_zh-CN/core_loop_v2_events.json:443–453`; `content/events_zh-TW/core_loop_v2_events.json:443–453` | 74 | R3/R5 |
| B? | `v2_father_health_signal` | `content/events/core_loop_v2_events.json:723–785`; `content/events_en/core_loop_v2_events.json:268–291`; `content/events_ja/core_loop_v2_events.json:268–291`; `content/events_zh-CN/core_loop_v2_events.json:268–291`; `content/events_zh-TW/core_loop_v2_events.json:268–291` | 159 | R3/R5 |
| B? | `v2_gangnam_receipt_walk` | `content/events/core_loop_v2_events.json:1071–1115`; `content/events_en/core_loop_v2_events.json:396–414`; `content/events_ja/core_loop_v2_events.json:366–384`; `content/events_zh-CN/core_loop_v2_events.json:366–384`; `content/events_zh-TW/core_loop_v2_events.json:366–384` | 121 | R3/R5 |
| B? | `v2_hanbit_interview` | `content/events/core_loop_v2_events.json:255–294`; `content/events_en/core_loop_v2_events.json:99–113`; `content/events_ja/core_loop_v2_events.json:99–113`; `content/events_zh-CN/core_loop_v2_events.json:99–113`; `content/events_zh-TW/core_loop_v2_events.json:99–113` | 100 | R3/R5 |
| B? | `v2_hanbit_offer_message` | `content/events/core_loop_v2_events.json:445–490`; `content/events_en/core_loop_v2_events.json:174–188`; `content/events_ja/core_loop_v2_events.json:174–188`; `content/events_zh-CN/core_loop_v2_events.json:174–188`; `content/events_zh-TW/core_loop_v2_events.json:174–188` | 106 | R3/R5 |
| B? | `v2_hyunsu_exam_eve` | `content/events/core_loop_v2_events.json:921–959`; `content/events_en/core_loop_v2_events.json:340–354`; `content/events_ja/core_loop_v2_events.json:340–354`; `content/events_zh-CN/core_loop_v2_events.json:340–354`; `content/events_zh-TW/core_loop_v2_events.json:340–354` | 99 | R3/R5 |
| B? | `v2_hyunsu_exam_morning_echo` | `content/events/core_loop_v2_events.json:960–991`; `content/events_en/core_loop_v2_events.json:355–365`; `content/events_ja/core_loop_v2_events.json:355–365`; `content/events_zh-CN/core_loop_v2_events.json:355–365`; `content/events_zh-TW/core_loop_v2_events.json:355–365` | 76 | R3/R5 |
| B? | `v2_hyunsu_first_study` | `content/events/core_loop_v2_events.json:167–208`; `content/events_en/core_loop_v2_events.json:65–79`; `content/events_ja/core_loop_v2_events.json:65–79`; `content/events_zh-CN/core_loop_v2_events.json:65–79`; `content/events_zh-TW/core_loop_v2_events.json:65–79` | 102 | R3/R5 |
| B? | `v2_hyunsu_player_reachout` | `content/events/core_loop_v2_events.json:135–166`; `content/events_en/core_loop_v2_events.json:50–64`; `content/events_ja/core_loop_v2_events.json:50–64`; `content/events_zh-CN/core_loop_v2_events.json:50–64`; `content/events_zh-TW/core_loop_v2_events.json:50–64` | 92 | R3/R5 |
| B? | `v2_hyunsu_study_followup` | `content/events/core_loop_v2_events.json:209–254`; `content/events_en/core_loop_v2_events.json:80–98`; `content/events_ja/core_loop_v2_events.json:80–98`; `content/events_zh-CN/core_loop_v2_events.json:80–98`; `content/events_zh-TW/core_loop_v2_events.json:80–98` | 122 | R3/R5 |
| B? | `v2_inventory_count_nights` | `content/events/core_loop_v2_events.json:1146–1182`; `content/events_en/core_loop_v2_events.json:426–443`; `content/events_ja/core_loop_v2_events.json:396–413`; `content/events_zh-CN/core_loop_v2_events.json:396–413`; `content/events_zh-TW/core_loop_v2_events.json:396–413` | 109 | R3/R5 |
| B? | `v2_jaehyuk_message` | `content/events/core_loop_v2_events.json:406–444`; `content/events_en/core_loop_v2_events.json:159–173`; `content/events_ja/core_loop_v2_events.json:159–173`; `content/events_zh-CN/core_loop_v2_events.json:159–173`; `content/events_zh-TW/core_loop_v2_events.json:159–173` | 99 | R3/R5 |
| B? | `v2_jaehyuk_plain_reunion_echo` | `content/events/core_loop_v2_events.json:657–722`; `content/events_en/core_loop_v2_events.json:253–267`; `content/events_ja/core_loop_v2_events.json:253–267`; `content/events_zh-CN/core_loop_v2_events.json:253–267`; `content/events_zh-TW/core_loop_v2_events.json:253–267` | 126 | R3/R5 |
| B? | `v2_jiyeon_second_crossing` | `content/events/core_loop_v2_events.json:569–617`; `content/events_en/core_loop_v2_events.json:219–237`; `content/events_ja/core_loop_v2_events.json:219–237`; `content/events_zh-CN/core_loop_v2_events.json:219–237`; `content/events_zh-TW/core_loop_v2_events.json:219–237` | 125 | R3/R5 |
| B? | `v2_logistics_class_session` | `content/events/core_loop_v2_events.json:1183–1219`; `content/events_en/core_loop_v2_events.json:444–461`; `content/events_ja/core_loop_v2_events.json:414–431`; `content/events_zh-CN/core_loop_v2_events.json:414–431`; `content/events_zh-TW/core_loop_v2_events.json:414–431` | 109 | R3/R5 |
| B? | `v2_m3_room_ledger_anchor` | `content/events/core_loop_v2_events.json:1483–1523`; `content/events_en/core_loop_v2_events.json:562–576`; `content/events_ja/core_loop_v2_events.json:478–492`; `content/events_zh-CN/core_loop_v2_events.json:478–492`; `content/events_zh-TW/core_loop_v2_events.json:478–492` | 101 | R3/R5 |
| B? | `v2_m4_housing_consultation_anchor` | `content/events/core_loop_v2_events.json:1524–1573`; `content/events_en/core_loop_v2_events.json:577–595`; `content/events_ja/core_loop_v2_events.json:493–511`; `content/events_zh-CN/core_loop_v2_events.json:493–511`; `content/events_zh-TW/core_loop_v2_events.json:493–511` | 126 | R3/R5 |
| B? | `v2_mirae_result_message` | `content/events/core_loop_v2_events.json:75–104`; `content/events_en/core_loop_v2_events.json:28–38`; `content/events_ja/core_loop_v2_events.json:28–38`; `content/events_zh-CN/core_loop_v2_events.json:28–38`; `content/events_zh-TW/core_loop_v2_events.json:28–38` | 74 | R3/R5 |
| B? | `v2_moving_crew_days` | `content/events/core_loop_v2_events.json:1220–1249`; `content/events_en/core_loop_v2_events.json:462–472`; `content/events_ja/core_loop_v2_events.json:432–442`; `content/events_zh-CN/core_loop_v2_events.json:432–442`; `content/events_zh-TW/core_loop_v2_events.json:432–442` | 74 | R3/R5 |
| B? | `v2_opening_application_send` | `content/events/core_loop_v2_events.json:2–34`; `content/events_en/core_loop_v2_events.json:2–12`; `content/events_ja/core_loop_v2_events.json:2–12`; `content/events_zh-CN/core_loop_v2_events.json:2–12`; `content/events_zh-TW/core_loop_v2_events.json:2–12` | 77 | R3/R5 |
| B? | `v2_opening_return_math` | `content/events/core_loop_v2_events.json:35–74`; `content/events_en/core_loop_v2_events.json:13–27`; `content/events_ja/core_loop_v2_events.json:13–27`; `content/events_zh-CN/core_loop_v2_events.json:13–27`; `content/events_zh-TW/core_loop_v2_events.json:13–27` | 100 | R3/R5 |
| B? | `v2_sangchul_demo_echo` | `content/events/core_loop_v2_events.json:618–656`; `content/events_en/core_loop_v2_events.json:238–252`; `content/events_ja/core_loop_v2_events.json:238–252`; `content/events_zh-CN/core_loop_v2_events.json:238–252`; `content/events_zh-TW/core_loop_v2_events.json:238–252` | 99 | R3/R5 |
| B? | `v2_sangchul_housing_lead` | `content/events/core_loop_v2_events.json:372–405`; `content/events_en/core_loop_v2_events.json:144–158`; `content/events_ja/core_loop_v2_events.json:144–158`; `content/events_zh-CN/core_loop_v2_events.json:144–158`; `content/events_zh-TW/core_loop_v2_events.json:144–158` | 94 | R3/R5 |
| B? | `v2_seorin_result_message` | `content/events/core_loop_v2_events.json:105–134`; `content/events_en/core_loop_v2_events.json:39–49`; `content/events_ja/core_loop_v2_events.json:39–49`; `content/events_zh-CN/core_loop_v2_events.json:39–49`; `content/events_zh-TW/core_loop_v2_events.json:39–49` | 74 | R3/R5 |

</details>

### ui_demo_dynamic

EN은 inline pair이므로 별도 ui_en.json이 없다. JA/간체/번체 legacy 표에서 미존재는 0줄. R8의 exact key 및 수집 출처는 삭제 근거가 아니다.

<details>
<summary>692 항목</summary>

| 분류 | 함수·키 | 파일:줄 | 줄 수 | 근거·등록 |
| --- | --- | --- | ---: | --- |
| B? | `"\"계산 전에 말씀해 주셔야 해요\""` | `locale/ui_zh-CN.json:1184`; `locale/ui_zh-TW.json:1184` | 2 | R8; `scenes/ArubaGame.gd::CUSTOMER_TYPES[44].text` |
| B? | `"\"많이 기다리셨죠. 바로 계산해 드릴게요\""` | `locale/ui_zh-CN.json:1185`; `locale/ui_zh-TW.json:1185` | 2 | R8; `scenes/ArubaGame.gd::CUSTOMER_TYPES[10].text` |
| B? | `"\"많이 드신 것 같은데, 물도 같이 찾으세요?\""` | `locale/ui_zh-CN.json:1186`; `locale/ui_zh-TW.json:1186` | 2 | R8; `scenes/ArubaGame.gd::CUSTOMER_TYPES[24].text` |
| B? | `"\"성실함\" — 맡은 일은 반드시 끝내는 사람입니다."` | `locale/ui_zh-CN.json:1089`; `locale/ui_zh-TW.json:1089` | 2 | R8; `scenes/JobHuntMiniGame.gd::INTERVIEW_QUESTION_POOL[13].text` |
| B? | `"\"잠깐만요\" 다른 손님 먼저"` | `locale/ui_zh-CN.json:1187`; `locale/ui_zh-TW.json:1187` | 2 | R8; `scenes/ArubaGame.gd::CUSTOMER_TYPES[4].text` |
| B? | `"\"죄송합니다\" 차분히 대응"` | `locale/ui_zh-CN.json:1188`; `locale/ui_zh-TW.json:1188` | 2 | R8; `scenes/ArubaGame.gd::CUSTOMER_TYPES[8].text` |
| B? | `"(당황) \"...글쎄요... 잘 모르겠습니다.\""` | `locale/ui_zh-CN.json:1091`; `locale/ui_zh-TW.json:1091` | 2 | R8; `scenes/JobHuntMiniGame.gd::INTERVIEW_QUESTION_POOL[15].text` |
| B? | `"(당황하며) 음... 이 펜은 잘 써지고 가격도 합리적입니다."` | `locale/ui_zh-CN.json:1092`; `locale/ui_zh-TW.json:1092` | 2 | R8; `scenes/JobHuntMiniGame.gd::INTERVIEW_QUESTION_POOL[26].text` |
| B? | `"(아무 말도 못 하고 인사만)"` | `locale/ui_zh-CN.json:1093`; `locale/ui_zh-TW.json:1093` | 2 | R8; `scenes/JobHuntMiniGame.gd::INTERVIEW_QUESTION_POOL[18].text` |
| B? | `"(웃으며 넘김) 저는 영업직 지원자가 아닌데요."` | `locale/ui_zh-CN.json:1094`; `locale/ui_zh-TW.json:1094` | 2 | R8; `scenes/JobHuntMiniGame.gd::INTERVIEW_QUESTION_POOL[27].text` |
| B? | `"(잠시 침묵) \"...열정적인 사람입니다.\""` | `locale/ui_zh-CN.json:1095`; `locale/ui_zh-TW.json:1095` | 2 | R8; `scenes/JobHuntMiniGame.gd::INTERVIEW_QUESTION_POOL[14].text` |
| B? | `"(침착하게) 이 펜은 오늘 하루를 기록하는 도구입니다. 오늘 내린 결정들을 잊고 싶지 않으시죠?"` | `locale/ui_zh-CN.json:1096`; `locale/ui_zh-TW.json:1096` | 2 | R8; `scenes/JobHuntMiniGame.gd::INTERVIEW_QUESTION_POOL[25].text` |
| B? | `"10년 만에 온 재혁의 카카오톡"` | — | 0 | R8; `$.scene_bundles.jaehyuk_world_meet.offer` |
| B? | `"10년 만에 온 재혁의 카카오톡에 이번 달에는 답하지 않았다."` | — | 0 | R8; `$.decline_outcomes.jaehyuk_stops_waiting_for_an_immediate_reply.message` |
| B? | `"11주차 폐점 전"` | — | 0 | R8; `$.scene_bundles.m3_inventory_shift.deadline` |
| B? | `"11주차가 끝나기 전"` | — | 0 | R8; `$.scene_bundles.m3_empty_saturday.deadline` |
| B? | `"12주차 새벽 전"` | — | 0 | R8; `$.scene_bundles.daeun_world_meet.deadline` |
| B? | `"12주차 해 질 녘 전"` | — | 0 | R8; `$.scene_bundles.jiyeon_world_meet.deadline` |
| B? | `"12주차가 끝나기 전"` | — | 0 | R8; `$.scene_bundles.hyunsu_study_followup.deadline` |
| B? | `"13주차 오전 접수에 맞춰 상담 운영직 지원서와 이력서를 보낸다."` | — | 0 | R8; `$.scene_bundles.m4_dodam_application.detail` |
| B? | `"13주차 화요일 정오"` | — | 0 | R8; `$.scene_bundles.m4_dodam_application.deadline` |
| B? | `"14주차 면접 시간에 참석하지 않아 한빛유통 이번 전형이 끝났다."` | — | 0 | R8; `$.decline_outcomes.hanbit_interview_not_attended.message` |
| B? | `"14주차 목요일 오후 2시"` | — | 0 | R8; `$.scene_bundles.m4_hanbit_interview.deadline` |
| B? | `"14주차 부동산 영업 종료 전"` | — | 0 | R8; `$.scene_bundles.sangchul_world_meet.deadline` |
| B? | `"15주차 마지막 수업 전"` | — | 0 | R8; `$.scene_bundles.m4_certificate_session.deadline` |
| B? | `"15주차 야간조 배정 전"` | — | 0 | R8; `$.scene_bundles.m4_logistics_shift.deadline` |
| B? | `"17주차 금요일 오후 6시"` | — | 0 | R8; `$.scene_bundles.m5_city_service_application.deadline` |
| B? | `"17주차 금요일 접수가 끝나면 이번 채용에는 지원할 수 없다."` | — | 0 | R8; `$.scene_bundles.m5_city_service_application.decline` |
| B? | `"1년 안에 업무를 익히고, 3년 뒤에는 혼자 프로젝트를 맡겠습니다. 5년 뒤에는 새로 온 동료가 업무를 익도록 도울 수 있는 사람이 되겠습니다."` | `locale/ui_zh-CN.json:1097`; `locale/ui_zh-TW.json:1097` | 2 | R8; `scenes/JobHuntMiniGame.gd::RESUME_QUESTION_POOL[17].text` |
| B? | `"1층 · 14분"` | `locale/ui_ja.json:3031`; `locale/ui_zh-CN.json:1192`; `locale/ui_zh-TW.json:1192` | 3 | R8; `scenes/ArubaGame.gd::DEL_ORDERS_DATA[9].info` |
| B? | `"1층 · 18분"` | `locale/ui_ja.json:3032`; `locale/ui_zh-CN.json:1193`; `locale/ui_zh-TW.json:1193` | 3 | R8; `scenes/ArubaGame.gd::DEL_ORDERS_DATA[1].info` |
| B? | `"1층 · 8분"` | `locale/ui_ja.json:3033`; `locale/ui_zh-CN.json:1194`; `locale/ui_zh-TW.json:1194` | 3 | R8; `scenes/ArubaGame.gd::DEL_ORDERS_DATA[11].info` |
| D | `"2026년, 서울."` | `locale/ui_ja.json:3088`; `locale/ui_zh-CN.json:2383`; `locale/ui_zh-TW.json:2383` | 3 | R8/R11; `scenes/OpeningCinematic.gd::BEATS[0].title` |
| B? | `"20주차 금요일 저녁까지"` | — | 0 | R8; `$.scene_bundles.jiyeon_second_crossing.deadline` |
| B? | `"20주차 마지막 나흘 근무조 배정 전"` | — | 0 | R8; `$.scene_bundles.m5_weekend_move_shift.deadline` |
| B? | `"20주차 마지막 집중반 시작 전"` | — | 0 | R8; `$.scene_bundles.m5_evening_spreadsheet_class.deadline` |
| B? | `"20주차 부동산 영업 종료 전"` | — | 0 | R8; `$.scene_bundles.sangchul_second_coffee.deadline` |
| B? | `"20주차 상담 접수 종료 전"` | — | 0 | R8; `$.scene_bundles.m5_employment_contract_clinic.deadline` |
| B? | `"20주차 야간 근무가 끝나기 전"` | — | 0 | R8; `$.scene_bundles.daeun_third_greeting.deadline` |
| B? | `"20주차 토요일 저녁"` | — | 0 | R8; `$.scene_bundles.jaehyuk_plain_reunion_echo.deadline` |
| B? | `"20주차 화요일 새벽"` | — | 0 | R8; `$.scene_bundles.daeun_shared_dream.deadline` |
| B? | `"21주차 화요일 새벽"` | — | 0 | R8; `$.scene_bundles.m6_daeun_tuesday_followthrough.deadline` |
| B? | `"22층 · 45분"` | `locale/ui_ja.json:3034`; `locale/ui_zh-CN.json:1195`; `locale/ui_zh-TW.json:1195` | 3 | R8; `scenes/ArubaGame.gd::DEL_ORDERS_DATA[5].info` |
| B? | `"23주차 도서관 마감 전"` | — | 0 | R8; `$.scene_bundles.m6_last_study_group.deadline` |
| B? | `"23주차 마지막 실전 대비반 전"` | — | 0 | R8; `$.scene_bundles.m6_public_recruitment.deadline` |
| B? | `"23주차 마지막 심야조 배정 전"` | — | 0 | R8; `$.scene_bundles.m6_holiday_night_shift.deadline` |
| B? | `"23주차 마지막 저녁"` | — | 0 | R8; `$.scene_bundles.m6_gangnam_receipt_walk.deadline` |
| B? | `"23주차 일요일 밤"` | — | 0 | R8; `$.scene_bundles.hyunsu_exam_eve.deadline` |
| B? | `"23주차가 끝나기 전"` | — | 0 | R8; `$.scene_bundles.m6_no_plans_day.deadline` |
| B? | `"3월에 보낸 지원서가 서류를 통과했다. 구로 물류센터 회의실에서 운영지원 면접을 본다."` | — | 0 | R8; `$.scene_bundles.m4_hanbit_interview.detail` |
| B? | `"3층 · 30분"` | `locale/ui_ja.json:3035`; `locale/ui_zh-CN.json:1196`; `locale/ui_zh-TW.json:1196` | 3 | R8; `scenes/ArubaGame.gd::DEL_ORDERS_DATA[3].info` |
| B? | `"4주차 고정"` | — | 0 | R8; `$.scene_bundles.first_temptation_boss.deadline` |
| B? | `"4층 · 25분"` | `locale/ui_ja.json:3036`; `locale/ui_zh-CN.json:1197`; `locale/ui_zh-TW.json:1197` | 3 | R8; `scenes/ArubaGame.gd::DEL_ORDERS_DATA[7].info` |
| B? | `"5년 후 본인의 모습은 어떨 것 같나요?"` | `locale/ui_zh-CN.json:1098`; `locale/ui_zh-TW.json:1098` | 2 | R8; `scenes/JobHuntMiniGame.gd::INTERVIEW_QUESTION_POOL[8].q` |
| B? | `"8주가 끝난 뒤에도 수면 부족으로 몸이 무거웠다."` | — | 0 | R8; `$.decline_outcomes.sleep_debt_rolls_forward.message` |
| B? | `"9주차 월요일 오전"` | — | 0 | R8; `$.scene_bundles.m3_hanbit_application.deadline` |
| B? | `"NCS 실전 문제 시간 안에 풀기"` | — | 0 | R8; `$.seoul_cycle.months.6.nodes.m6_advancement.label` |
| B? | `"NCS 실전 문제를 시간 안에 풀었다"` | — | 0 | R8; `$.scene_bundles.m6_public_recruitment.action_config.result_title` |
| B? | `"NCS 실전 연습"` | — | 0 | R8; `$.seoul_cycle.months.6.nodes.m6_advancement.board_label` |
| B? | `"V2에서는 실제 저축 행동 없이 성향을 선언하지 않는다."` | — | 0 | R8; `$.legacy_callback_retirements.callback_mindset_saver_echo.reason` |
| B? | `"V2에서는 실제 창업 행동 없이 성향을 선언하지 않는다."` | — | 0 | R8; `$.legacy_callback_retirements.callback_mindset_founder_echo.reason` |
| B? | `"V2에서는 실제 투자 거래 없이 성향을 선언하지 않는다."` | — | 0 | R8; `$.legacy_callback_retirements.callback_mindset_investor_echo.reason` |
| B? | `"{name}, 나 재혁이야. 군대 동기 최재혁. 기억나지? 오랜만이다. 잘 지냈어?"` | — | 0 | R8; `$.scene_bundles.jaehyuk_world_meet.message_body` |
| B? | `"간신히 진정됐다."` | `locale/ui_zh-CN.json:1200`; `locale/ui_zh-TW.json:1200` | 2 | R8; `scenes/ArubaGame.gd::CUSTOMER_TYPES[9].tip` |
| B? | `"갈등 해결 능력과 협업 역량을 보여주는 문항."` | `locale/ui_zh-CN.json:1099`; `locale/ui_zh-TW.json:1099` | 2 | R8; `scenes/JobHuntMiniGame.gd::RESUME_QUESTION_POOL[21].hint` |
| B? | `"갈등을 피하고 조용히 넘어가려 합니다."` | `locale/ui_zh-CN.json:1100`; `locale/ui_zh-TW.json:1100` | 2 | R8; `scenes/JobHuntMiniGame.gd::RESUME_QUESTION_POOL[24].text` |
| D | `"강남. 부와 지위가 주소가 되는 곳.\n아파트 한 채, 30억원."` | `locale/ui_ja.json:3089`; `locale/ui_zh-CN.json:2384`; `locale/ui_zh-TW.json:2384` | 3 | R8/R11; `scenes/OpeningCinematic.gd::BEATS[0].body` |
| B? | `"강남역 카페 앞에서 9,000원을 쓸지, 그냥 지나칠지, 이번 달 말 고정비부터 확인할지 정한다."` | — | 0 | R8; `$.scene_bundles.m6_gangnam_receipt_walk.detail` |
| B? | `"강남역에서 오늘 쓸 돈 정하기"` | — | 0 | R8; `$.scene_bundles.m6_gangnam_receipt_walk.offer` |
| B? | `"강현수"` | — | 0 | R8; `$.scene_bundles.hyunsu_exam_eve.message_sender` |
| B? | `"같은 도시의 사람"` | — | 0 | R8; `$.months[1].title` |
| B? | `"같은 한 주를 두 곳에 쓸 수 없다"` | — | 0 | R8; `scenes/TutorialOverlay.gd::core_loop_v2[1].title` |
| B? | `"개인적인 사정이 있었습니다. 이제는 집중할 수 있습니다."` | `locale/ui_zh-CN.json:1101`; `locale/ui_zh-TW.json:1101` | 2 | R8; `scenes/JobHuntMiniGame.gd::INTERVIEW_QUESTION_POOL[2].text` |
| B? | `"거친 문장을 다시 고치느라 시간이 들었지만 지원서는 보냈다. 마음 -1"` | — | 0 | R8; `$.seoul_cycle.terminal_routes.m1_resume_completed_q1_to_m2_advancement_revised.result` |
| B? | `"검진 뒤 반나절을 쉬었다"` | — | 0 | R8; `$.scene_bundles.m4_health_check_day.action_config.result_title` |
| B? | `"검진 예약을 다음 접수 때까지 미룬다."` | — | 0 | R8; `$.scene_bundles.m4_health_check_day.decline` |
| B? | `"경력 공백을 숨기지 않고 계약직 지원서를 보냈다. 접수 확인 메일은 왔지만 결과는 아직 모른다."` | — | 0 | R8; `$.scene_bundles.m2_seorin_application.action_config.result_body` |
| B? | `"경력 공백을 숨기지 않고 지원서를 보낸다."` | — | 0 | R8; `$.scene_bundles.m2_seorin_application.detail` |
| B? | `"계산 손님"` | `locale/ui_zh-CN.json:1203`; `locale/ui_zh-TW.json:1203` | 2 | R8; `scenes/ArubaGame.gd::CUSTOMER_TYPES[0].name` |
| B? | `"계산대의 직원은 이름 없는 익숙한 얼굴로 남는다."` | — | 0 | R8; `$.scene_bundles.daeun_return_after_distance.decline` |
| B? | `"고르지 않고 넘길 수 없다. 4주차에 문자를 확인하고 받거나 거절해야 한다."` | — | 0 | R8; `$.scene_bundles.first_temptation_boss.decline` |
| B? | `"고맙다며 갔다."` | `locale/ui_zh-CN.json:1205`; `locale/ui_zh-TW.json:1205` | 2 | R8; `scenes/ArubaGame.gd::CUSTOMER_TYPES[23].tip` |
| B? | `"고시원 방 · 노트북"` | — | 0 | R8; `$.seoul_cycle.months.3.nodes.m3_advancement.place; $.seoul_cycle.months.5.nodes.m5_advancement.place` |
| B? | `"고시원 방"` | — | 0 | R8; `$.seoul_cycle.months.1.nodes.recovery.place; $.seoul_cycle.months.2.nodes.m2_self.place; $.seoul_cycle.months.3.nodes.m3_self.place; $.seoul_cycle.months.5.nodes.m5_self.place; $.seoul_cycle.months.6.nodes.m6_self.place; $.seoul_cycle.nodes.recovery.place` |
| B? | `"고시원 복도"` | — | 0 | R8; `$.seoul_cycle.months.1.nodes.father.place; $.seoul_cycle.nodes.father.place` |
| B? | `"고시원을 벗어날 방 시세 알아보기"` | — | 0 | R8; `$.scene_bundles.sangchul_world_meet.offer` |
| B? | `"고쳐 둔 자기소개서 네 문항이 노트북 화면에 열려 있었다. 지원할 곳은 다시 찾을 수 있었지만, 월세 이체일은 먼저 다가왔다."` | — | 0 | R8; `$.episode_plan.primary_echo.m1_youth_center_resume_clinic.copy` |
| B? | `"고쳐 쓴 자기소개서 네 문항을 첨부해 지원했다. 화면에 ‘접수 완료 · 오전 9:14’가 떴다."` | — | 0 | R8; `$.scene_bundles.m1_youth_center_resume_clinic.action_config.result_body` |
| B? | `"고쳐 쓴 자기소개서가 노트북에 남아 있었다. 아직 보내지 못한 문장들 위로 모르는 번호의 알림이 떴다."` | — | 0 | R8; `$.seoul_cycle.months.1.nodes.resume.echo; $.seoul_cycle.nodes.resume.echo` |
| B? | `"공고의 핵심 업무를 단기 현장에서 실제로 해 본 일과 하나씩 연결해 적었습니다."` | `locale/ui_zh-CN.json:1102`; `locale/ui_zh-TW.json:1102` | 2 | R8; `scenes/JobHuntMiniGame.gd::RESUME_QUESTION_POOL[37].text` |
| B? | `"공공기관 계약직 NCS 실전 대비"` | — | 0 | R8; `$.scene_bundles.m6_public_recruitment.offer` |
| B? | `"공공기관 계약직 NCS 실전 대비반이 끝났다. 이번 달에는 시간 안에 문제를 풀어 보는 연습을 하지 못했다."` | — | 0 | R8; `$.decline_outcomes.first_half_recruitment_closes.message` |
| B? | `"공공기관 계약직 실전 대비반에서 자료해석 문제를 제한 시간 안에 풀고, 틀린 문항의 계산 순서를 다시 적었다. 새 지원서를 보낸 것은 아니다."` | — | 0 | R8; `$.scene_bundles.m6_public_recruitment.action_config.result_body` |
| B? | `"공공취업반 · 구립도서관"` | — | 0 | R8; `$.seoul_cycle.months.6.nodes.m6_advancement.place` |
| B? | `"공덕역 카페"` | `locale/ui_ja.json:3037`; `locale/ui_zh-CN.json:1206`; `locale/ui_zh-TW.json:1206` | 3 | R8; `scenes/ArubaGame.gd::DEL_ORDERS_DATA[8].name` |
| B? | `"공식적인 리더 경험이 없다면, 협업할 때 무엇을 맡았나요?"` | `locale/ui_zh-CN.json:1103`; `locale/ui_zh-TW.json:1103` | 2 | R8; `scenes/JobHuntMiniGame.gd::INTERVIEW_QUESTION_POOL[36].q` |
| B? | `"공용 주방에서 만난 현수에게 먼저 연락해 처음으로 같이 공부할 날을 잡는다."` | — | 0 | R8; `$.scene_bundles.hyunsu_player_reachout.detail` |
| B? | `"공용 주방의 낯선 이웃"` | — | 0 | R8; `$.scene_bundles.hyunsu_first_meet.offer` |
| B? | `"관련 업무에 관심이 많고 열심히 할 자신이 있습니다."` | `locale/ui_zh-CN.json:1104`; `locale/ui_zh-TW.json:1104` | 2 | R8; `scenes/JobHuntMiniGame.gd::RESUME_QUESTION_POOL[38].text` |
| B? | `"괜찮다고 답했던 첫 통화 뒤, 이번에는 내가 먼저 전화해 그 말 뒤의 침묵을 듣는다."` | — | 0 | R8; `$.seoul_cycle.terminal_routes.m1_father_completed_future_reassured_to_m3_quiet_call.detail` |
| B? | `"괜찮다고 한 뒤 아버지에게 다시 전화하기"` | — | 0 | R8; `$.seoul_cycle.terminal_routes.m1_father_completed_future_reassured_to_m3_quiet_call.label` |
| B? | `"괜찮다는 말 뒤에 남은 이야기를 다음 통화까지 가져갔다."` | — | 0 | R8; `$.seoul_cycle.terminal_routes.m1_father_completed_future_reassured_to_m3_quiet_call.result` |
| B? | `"교대 전에는 두 가지까지 처리할 수 있다. 고른 순서대로 끝낸 뒤, 그대로 나갈지 남은 하나까지 붙들지 정한다."` | — | 0 | R8; `$.scene_bundles.m3_inventory_shift.action_config.instruction` |
| B? | `"교대자가 오자 카운터를 넘겼다. 이번 주 통장에 찍힐 하루가 하나 늘었다."` | — | 0 | R8; `scenes/MainGame.gd::SIDE_JOB_VIGNETTES_CONVENIENCE[2].t` |
| B? | `"교대할 사람이 바로 일할 수 있도록 남은 업무와 정산 내용을 기록해 전달했습니다."` | `locale/ui_zh-CN.json:1105`; `locale/ui_zh-TW.json:1105` | 2 | R8; `scenes/JobHuntMiniGame.gd::INTERVIEW_QUESTION_POOL[37].text` |
| B? | `"교통비를 아끼려고 중고 자전거로 비 오는 신촌 골목을 지나다 검은 세단에 부딪히고, 운전석의 낯선 여성과 처음 마주한다."` | — | 0 | R8; `$.scene_bundles.jiyeon_world_meet.detail` |
| B? | `"교환 손님"` | `locale/ui_zh-CN.json:1207`; `locale/ui_zh-TW.json:1207` | 2 | R8; `scenes/ArubaGame.gd::CUSTOMER_TYPES[28].name` |
| B? | `"구립도서관 게시판에서 채용 공고와 필요한 기술을 수첩에 적는다."` | — | 0 | R8; `$.scene_bundles.m3_library_job_board.detail` |
| B? | `"구립도서관 채용 공고 살펴보기"` | — | 0 | R8; `$.scene_bundles.m3_library_job_board.offer` |
| B? | `"구립도서관 취업 게시판이 새 종이로 바뀌었다. 지난달의 작은 공고들은 내려갔다."` | — | 0 | R8; `$.decline_outcomes.the_library_board_changes.message` |
| B? | `"구청 전산실의 저녁 전산 실무 집중반이 끝났다. 이번 기수에는 참석하지 않았다."` | — | 0 | R8; `$.decline_outcomes.spreadsheet_class_closes.message` |
| B? | `"구체적인 시간표와 목표가 신뢰감을 준다."` | `locale/ui_zh-CN.json:1107`; `locale/ui_zh-TW.json:1107` | 2 | R8; `scenes/JobHuntMiniGame.gd::RESUME_QUESTION_POOL[16].hint` |
| B? | `"군대 동기 최재혁이 10년 만에 보낸 카카오톡을 읽고 이번 달 안에 답한다."` | — | 0 | R8; `$.scene_bundles.jaehyuk_world_meet.detail` |
| B? | `"귀사의 성장세와 사업 방향이 제 커리어 목표와 맞닿아 있어 지원했습니다."` | `locale/ui_zh-CN.json:1108`; `locale/ui_zh-TW.json:1108` | 2 | R8; `scenes/JobHuntMiniGame.gd::INTERVIEW_QUESTION_POOL[5].text` |
| B? | `"그 새벽에는 24시간 편의점에 가지 않아, 계산대 직원과 만나지 않았다."` | — | 0 | R8; `$.decline_outcomes.the_clerk_remains_a_familiar_stranger.message` |
| B? | `"그 새벽에는 편의점에 가지 않아, 계산대 직원과 만나지 않는다."` | — | 0 | R8; `$.scene_bundles.daeun_world_meet.decline` |
| B? | `"그 시간을 알고도 이번 달에는 편의점에 다시 가지 않는다."` | — | 0 | R8; `$.scene_bundles.daeun_shared_dream.decline` |
| B? | `"그 큰길로 다시 돌아가기"` | — | 0 | R8; `$.scene_bundles.jiyeon_second_crossing.offer` |
| B? | `"그것은 동료의 책임이므로 제 업무에 집중하겠습니다."` | `locale/ui_zh-CN.json:1109`; `locale/ui_zh-TW.json:1109` | 2 | R8; `scenes/JobHuntMiniGame.gd::INTERVIEW_QUESTION_POOL[23].text` |
| B? | `"그날 받을 수 있었던 돈은 벌지 못한다."` | — | 0 | R8; `$.scene_bundles.m1_convenience_trial_shift.decline` |
| B? | `"그날 신촌 이면도로를 지나지 않아, 검은 세단의 운전자와 만나지 않는다."` | — | 0 | R8; `$.scene_bundles.jiyeon_world_meet.decline` |
| B? | `"그날 카페에 가지 않아 정장 남자의 통화와 서류를 보지 못한다."` | — | 0 | R8; `$.scene_bundles.cafe_world_glimpse.decline` |
| B? | `"그날 카페에 가지 않아, 정장 남자의 통화도 테이블 위 서류도 보지 못했다."` | — | 0 | R8; `$.decline_outcomes.the_overheard_property_lead_disappears.message` |
| B? | `"그날 큰길에 검은 세단은 다시 서지 않았다. 지연과 커피를 마실 기회도 지나갔다."` | — | 0 | R8; `$.decline_outcomes.jiyeon_sedan_does_not_stop_again.message` |
| B? | `"그날 큰길을 지나지 않아 지연과 다시 만나지 않는다."` | — | 0 | R8; `$.scene_bundles.jiyeon_second_crossing.decline` |
| B? | `"그날은 신촌 이면도로를 지나지 않아, 검은 세단의 운전자와 마주치지 않았다."` | — | 0 | R8; `$.decline_outcomes.the_accident_ends_without_a_reason_to_reconnect.message` |
| B? | `"그는 한동안 이름 없는 이웃으로 남는다."` | — | 0 | R8; `$.scene_bundles.hyunsu_first_meet.decline` |
| B? | `"그때 답장 고마웠다. 이번 주 토요일 저녁, 신촌 포장마차에서 얼굴 볼래?"` | — | 0 | R8; `$.scene_bundles.jaehyuk_plain_reunion_echo.message_body` |
| B? | `"근로계약서에서 확인할 항목을 배웠다"` | — | 0 | R8; `$.scene_bundles.m5_employment_contract_clinic.action_config.result_title` |
| B? | `"기다리게 둔 사람에게 연락하기"` | — | 0 | R8; `$.seoul_cycle.months.5.nodes.m5_people.label` |
| B? | `"기다리는 쪽"` | — | 0 | R8; `$.months[4].title` |
| B? | `"기록 대조"` | — | 0 | R8; `$.scene_bundles.m3_inventory_shift.action_config.requirements[1].short` |
| B? | `"기록 작업대"` | — | 0 | R8; `$.scene_bundles.m3_inventory_shift.action_config.requirements[1].station` |
| B? | `"긴급도와 중요도를 나눠 정리한 뒤, 팀장과 처리 순서를 확인하겠습니다."` | `locale/ui_zh-CN.json:1110`; `locale/ui_zh-TW.json:1110` | 2 | R8; `scenes/JobHuntMiniGame.gd::INTERVIEW_QUESTION_POOL[29].text` |
| D | `"김민준, 서른셋."` | `locale/ui_ja.json:3090`; `locale/ui_zh-CN.json:2385`; `locale/ui_zh-TW.json:2385` | 3 | R8/R11; `scenes/OpeningCinematic.gd::BEATS[1].title` |
| D | `"끝낸 일 — 다은의 야간 근무 시간에 찾아가 먼저 저녁을 물었고, 짧게 안부를 나눴다."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.candidate_copy.done.daeun_checkin` |
| D | `"끝낸 일 — 도시시설운영단 작업표를 18:00 전에 보내 접수 완료 회신을 받았다."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.candidate_copy.done.city_work_sample` |
| D | `"끝낸 일 — 심야 하역의 마지막 상자까지 내리고 일당 28만원을 바로 받았다."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.candidate_copy.done.urgent_paid_shift` |
| D | `"끝낸 일 — 아버지에게 다시 전화해 목소리를 들었고, 다음에 연락할 시간을 적었다."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.candidate_copy.done.father_call` |
| D | `"끝낸 일 — 알람 하나를 맞추고 물을 마신 뒤, 더 버티지 않고 침대에 누웠다."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.candidate_copy.done.body_rest` |
| D | `"끝낸 일 — 월세·식비·교통비·휴대폰 결제를 적어 이번 달 지출 장부 첫 장을 맞췄다."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.candidate_copy.done.sangchul_ledger` |
| D | `"끝낸 일 — 재혁에게 먼저 이번 주 안부를 보냈고, 끊겼다 이어지는 답장을 주고받았다."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.candidate_copy.done.jaehyuk_reply` |
| D | `"끝낸 일 — 한빛유통 월말 오류표를 확인해 17:59에 내부 메일로 보냈다."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.candidate_copy.done.hanbit_month_close` |
| B? | `"나흘 야간 재고조사"` | — | 0 | R8; `$.scene_bundles.m3_inventory_shift.offer` |
| B? | `"나흘 이삿짐 보조조 들어가기"` | — | 0 | R8; `$.seoul_cycle.months.5.nodes.m5_livelihood.label` |
| B? | `"나흘의 재고조사를 마쳤다"` | — | 0 | R8; `$.scene_bundles.m3_inventory_shift.action_config.result_title` |
| B? | `"나흘짜리 보조 자리는 다른 사람으로 채워진다."` | — | 0 | R8; `$.scene_bundles.m5_weekend_move_shift.decline` |
| B? | `"나흘짜리 이삿짐 보조 자리는 다른 사람으로 채워졌다."` | — | 0 | R8; `$.decline_outcomes.moving_shift_is_filled.message` |
| B? | `"나흘짜리 자리는 다른 사람으로 채워진다."` | — | 0 | R8; `$.scene_bundles.m3_inventory_shift.decline` |
| B? | `"남들과 비교하는 생각 때문에 밤마다 다시 휴대폰을 켰다."` | — | 0 | R8; `$.decline_outcomes.the_comparison_pressure_goes_unexamined.message` |
| B? | `"남은 돈"` | — | 0 | R8; `$.months[0].title` |
| B? | `"남은 한 가지까지 마저 처리한다"` | — | 0 | R8; `$.scene_bundles.m3_inventory_shift.action_config.overreach.prompt` |
| B? | `"낯선 평가자 앞에서 경력 공백 질문에 직접 답해 본다."` | — | 0 | R8; `$.scene_bundles.m2_youth_center_mock_interview.detail` |
| B? | `"내가 먼저 잡은 첫 약속이 현수의 다음 제안으로 돌아왔다."` | — | 0 | R8; `$.seoul_cycle.terminal_routes.m2_people_completed_hyunsu_to_m3_followup.result` |
| B? | `"네 번째 달 마지막 검진일"` | — | 0 | R8; `$.scene_bundles.m4_health_check_day.deadline` |
| B? | `"네 번째 달 마지막 야간 근무 전"` | — | 0 | R8; `$.scene_bundles.daeun_player_return.deadline; $.scene_bundles.daeun_return_after_distance.deadline` |
| B? | `"네 번째 달 비가 그친 밤"` | — | 0 | R8; `$.scene_bundles.jiyeon_bus_stop_reunion.deadline` |
| B? | `"네 번째 달 상담 접수가 끝나기 전"` | — | 0 | R8; `$.scene_bundles.m4_housing_welfare_consultation.deadline` |
| B? | `"네 번째 달이 끝나기 전"` | — | 0 | R8; `$.scene_bundles.jaehyuk_world_meet.deadline` |
| B? | `"노동복지센터에서 계약 기간과 임금, 연장근로 항목을 실제 계약서 견본으로 확인한다."` | — | 0 | R8; `$.scene_bundles.m5_employment_contract_clinic.detail` |
| B? | `"놓친 지원을 없던 일로 만들지 않고 다음 공고에 다시 지원했다."` | — | 0 | R8; `$.seoul_cycle.terminal_routes.m2_advancement_expired_to_m3_advancement_retry.result` |
| B? | `"누구를 만났다고 만들지 않고, 연락할 시간을 실제로 썼다."` | — | 0 | R8; `$.seoul_cycle.terminal_routes.m1_father_expired_to_m2_people_open.result` |
| B? | `"다듬어 둔 문장을 공고에 맞춰 고쳐 지원서를 보냈다."` | — | 0 | R8; `$.seoul_cycle.terminal_routes.m1_resume_completed_q2_to_m2_advancement_polished.result` |
| B? | `"다듬은 자기소개서로 서린물산 지원하기"` | — | 0 | R8; `$.seoul_cycle.terminal_routes.m1_resume_completed_q2_to_m2_advancement_polished.label` |
| B? | `"다른 곳에서도 비슷한 일을 해봤습니다."` | `locale/ui_zh-CN.json:1111`; `locale/ui_zh-TW.json:1111` | 2 | R8; `scenes/JobHuntMiniGame.gd::RESUME_QUESTION_POOL[39].text` |
| B? | `"다른 팀이 재고표를 제출했다. 36만원을 받을 야간 재고조사는 끝났다."` | — | 0 | R8; `$.decline_outcomes.inventory_shift_is_filled.message` |
| B? | `"다섯 번째 달에는 하루도 완전히 쉬지 못했다. 피로가 다음 달 첫 일정까지 남았다."` | — | 0 | R8; `$.decline_outcomes.the_month_closes_without_recovery.message` |
| B? | `"다섯 번째 달의 마지막 일요일"` | — | 0 | R8; `$.scene_bundles.m5_last_empty_sunday.deadline` |
| B? | `"다시 만날 사람에게 연락하기"` | — | 0 | R8; `$.seoul_cycle.months.3.nodes.m3_people.label` |
| B? | `"다시 만날 약속 잡기"` | — | 0 | R8; `$.seoul_cycle.months.4.nodes.m4_people.board_label` |
| B? | `"다시 볼 이유"` | — | 0 | R8; `$.months[2].title` |
| B? | `"다시 연락하기"` | — | 0 | R8; `$.seoul_cycle.months.3.nodes.m3_people.board_label` |
| B? | `"다시 찾아갈 사람과 시간 맞추기"` | — | 0 | R8; `$.seoul_cycle.months.4.nodes.m4_people.label` |
| D | `"다은 — 늦은 식사를 챙겼는지 다시 묻기로 남긴 약속과, 전에 알게 된 야간 근무 시간."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.candidate_copy.evidence.daeun_checkin` |
| B? | `"다은과 약속한 화요일이 지났다. 그날 편의점에는 가지 않았다."` | — | 0 | R8; `$.decline_outcomes.daeun_tuesday_promise_missed.message` |
| B? | `"다은과 이름을 나눈 뒤에도 이번 달에는 다시 말을 걸러 가지 않았다."` | — | 0 | R8; `$.decline_outcomes.the_third_greeting_never_starts.message` |
| B? | `"다은에게 세 번째 인사 건네기"` | — | 0 | R8; `$.scene_bundles.daeun_third_greeting.offer` |
| B? | `"다은이 야간 근무하는 시간을 기억해 두었다가 편의점에 다시 들러 서로의 한 주를 묻는다."` | — | 0 | R8; `$.scene_bundles.daeun_shared_dream.detail` |
| B? | `"다은이 일하는 편의점에 다시 가기"` | — | 0 | R8; `$.scene_bundles.daeun_player_return.offer` |
| B? | `"다은이 일하는 화요일 새벽을 알고도 이번 달에는 편의점에 가지 않았다."` | — | 0 | R8; `$.decline_outcomes.the_small_tuesday_promise_passes.message` |
| B? | `"다은이 일하는 화요일에 다시 가기"` | — | 0 | R8; `$.scene_bundles.daeun_shared_dream.offer` |
| B? | `"다음 달 첫 일정을 시작할 때도 잠이 부족하다."` | — | 0 | R8; `$.scene_bundles.m2_sleep_debt_sunday.decline` |
| B? | `"다음 사람을 만날 때까지 피로가 남는다."` | — | 0 | R8; `$.scene_bundles.m3_empty_saturday.decline` |
| B? | `"다음 실제 면접 전에는 다시 연습할 자리가 없다."` | — | 0 | R8; `$.scene_bundles.m2_youth_center_mock_interview.decline` |
| B? | `"다음 일정을 시작할 때도 피곤하다."` | — | 0 | R8; `$.scene_bundles.m1_phone_off_sunday.decline` |
| B? | `"다음 지원서 제출 전"` | — | 0 | R8; `$.scene_bundles.m1_youth_center_resume_clinic.deadline` |
| B? | `"다음에 지원할 때까지 자기소개서 문장은 고쳐지지 않는다."` | — | 0 | R8; `$.scene_bundles.m1_youth_center_resume_clinic.decline` |
| B? | `"다음에 지원할 때까지 자기소개서 문장은 고쳐지지 않았다."` | — | 0 | R8; `$.decline_outcomes.preparation_window_moves_on.message` |
| B? | `"단골 할머니"` | `locale/ui_zh-CN.json:1215`; `locale/ui_zh-TW.json:1215` | 2 | R8; `scenes/ArubaGame.gd::CUSTOMER_TYPES[14].name` |
| B? | `"단기 일을 이어가며 익힌 현장 대응력을 한 직장에서 오래 쌓아 가고 싶어 지원했습니다."` | `locale/ui_zh-CN.json:1112`; `locale/ui_zh-TW.json:1112` | 2 | R8; `scenes/JobHuntMiniGame.gd::RESUME_QUESTION_POOL[2].text` |
| B? | `"단점과 그 극복 과정을 서술하시오."` | `locale/ui_zh-CN.json:1113`; `locale/ui_zh-TW.json:1113` | 2 | R8; `scenes/JobHuntMiniGame.gd::RESUME_QUESTION_POOL[10].q` |
| B? | `"단점은 딱히 없는 것 같습니다."` | `locale/ui_zh-CN.json:1114`; `locale/ui_zh-TW.json:1114` | 2 | R8; `scenes/JobHuntMiniGame.gd::RESUME_QUESTION_POOL[14].text` |
| B? | `"단점을 인정하면서 극복 과정까지 보여주는 것이 핵심."` | `locale/ui_zh-CN.json:1115`; `locale/ui_zh-TW.json:1115` | 2 | R8; `scenes/JobHuntMiniGame.gd::RESUME_QUESTION_POOL[11].hint` |
| D | `"당일 대타 — 18:30 집결, 자정 너머까지 이어지는 심야 하역, 바로 받는 28만원."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.candidate_copy.evidence.urgent_paid_shift` |
| B? | `"당장 갚아야 할 돈부터 처리하느라 장기 계획을 자주 미뤘습니다. 지금은 지원 마감과 지출을 주 단위로 기록하고 있습니다."` | `locale/ui_zh-CN.json:1116`; `locale/ui_zh-TW.json:1116` | 2 | R8; `scenes/JobHuntMiniGame.gd::RESUME_QUESTION_POOL[12].text` |
| B? | `"더 좋은 포지션으로 성장해 있을 것 같습니다."` | `locale/ui_zh-CN.json:1117`; `locale/ui_zh-TW.json:1117` | 2 | R8; `scenes/JobHuntMiniGame.gd::INTERVIEW_QUESTION_POOL[10].text` |
| B? | `"도담고객센터 상담 운영 지원"` | — | 0 | R8; `$.scene_bundles.m4_dodam_application.offer` |
| B? | `"도담고객센터 상담 운영직 접수가 끝났다. 지원서를 보내지 않았다."` | — | 0 | R8; `$.decline_outcomes.dodam_posting_expires.message` |
| B? | `"도담고객센터 지원서를 보냈다"` | — | 0 | R8; `$.scene_bundles.m4_dodam_application.action_config.result_title` |
| B? | `"도담고객센터 채용팀"` | — | 0 | R8; `$.scene_bundles.m6_dodam_response.message_sender` |
| B? | `"도서관 마감 전까지 각자 푼 문제를 바꿔 채점하고, 틀린 문항 두 개의 풀이를 소리 내 설명했다. 합격을 약속한 사람은 없었다."` | — | 0 | R8; `$.scene_bundles.m6_last_study_group.action_config.result_body` |
| B? | `"도서관 채용 공고를 수첩에 옮겼다. 당장 면접이 생긴 것은 아니지만, 어떤 기술을 더 준비해야 할지는 알게 됐다."` | — | 0 | R8; `$.scene_bundles.m3_library_job_board.action_config.result_body` |
| B? | `"도서관 채용 공고를 수첩에 옮겼다"` | — | 0 | R8; `$.scene_bundles.m3_library_job_board.action_config.result_title` |
| D | `"도시시설운영단 — 6월 26일 금요일 18:00까지 보내 달라는 작업표와 아직 오지 않은 면접 통보."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.candidate_copy.evidence.city_work_sample` |
| B? | `"도시시설운영단 계약직 접수가 끝났다. 이번 채용에는 지원서를 보내지 않았다."` | — | 0 | R8; `$.decline_outcomes.city_service_posting_expires.message` |
| B? | `"도시시설운영단 계약직 지원"` | — | 0 | R8; `$.scene_bundles.m5_city_service_application.offer` |
| B? | `"도시시설운영단 지원"` | — | 0 | R8; `$.seoul_cycle.months.5.nodes.m5_advancement.board_label` |
| B? | `"도시시설운영단 지원서 보내기"` | — | 0 | R8; `$.seoul_cycle.months.5.nodes.m5_advancement.label` |
| B? | `"도시시설운영단 지원서를 보냈다"` | — | 0 | R8; `$.scene_bundles.m5_city_service_application.action_config.result_title` |
| B? | `"도시시설운영단 채용팀"` | — | 0 | R8; `$.scene_bundles.m6_city_service_response.message_sender` |
| B? | `"돌발: 지금 바로 저를 설득해서 제품을 하나 파세요."` | `locale/ui_zh-CN.json:1118`; `locale/ui_zh-TW.json:1118` | 2 | R8; `scenes/JobHuntMiniGame.gd::INTERVIEW_QUESTION_POOL[24].q` |
| B? | `"돌발: 지금 이 자리에서 스스로를 한 단어로 표현한다면?"` | `locale/ui_zh-CN.json:1119`; `locale/ui_zh-TW.json:1119` | 2 | R8; `scenes/JobHuntMiniGame.gd::INTERVIEW_QUESTION_POOL[12].q` |
| B? | `"동료가 실수를 했는데 마감이 얼마 안 남았습니다. 어떻게 하겠습니까?"` | `locale/ui_zh-CN.json:1120`; `locale/ui_zh-TW.json:1120` | 2 | R8; `scenes/JobHuntMiniGame.gd::INTERVIEW_QUESTION_POOL[20].q` |
| B? | `"둘 사이에는 사고와 모르는 이름만 남는다."` | — | 0 | R8; `$.scene_bundles.jiyeon_bus_stop_reunion.decline` |
| B? | `"뒤에 있을 거라고 알아서 찾으라 한다"` | `locale/ui_zh-CN.json:1217`; `locale/ui_zh-TW.json:1217` | 2 | R8; `scenes/ArubaGame.gd::CUSTOMER_TYPES[38].text` |
| B? | `"등록번호 확인 후 찾아준다"` | `locale/ui_zh-CN.json:1218`; `locale/ui_zh-TW.json:1218` | 2 | R8; `scenes/ArubaGame.gd::CUSTOMER_TYPES[36].text` |
| B? | `"딱히 기억나는 실패가 없습니다."` | `locale/ui_zh-CN.json:1121`; `locale/ui_zh-TW.json:1121` | 2 | R8; `scenes/JobHuntMiniGame.gd::RESUME_QUESTION_POOL[29].text` |
| D | `"마감을 놓친 일 — 18:30 집결의 당일 하역 대타는 다른 사람에게 넘어갔다. 오늘의 28만원은 나중으로 미룰 수 없다."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.candidate_copy.deadline_missed.urgent_paid_shift` |
| D | `"마감을 놓친 일 — 도시시설운영단 작업표는 금요일 18:00까지 보내지 못했다. 이 지원에서는 같은 작업표를 나중에 제출할 수 없다."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.candidate_copy.deadline_missed.city_work_sample` |
| B? | `"마지막 모의면접 자리는 다른 사람이 예약했다. 이번 달에는 더 신청할 수 없다."` | — | 0 | R8; `$.decline_outcomes.mock_interview_window_closes.message` |
| B? | `"마지막으로 하고 싶은 말씀 있으신가요?"` | `locale/ui_zh-CN.json:1122`; `locale/ui_zh-TW.json:1122` | 2 | R8; `scenes/JobHuntMiniGame.gd::INTERVIEW_QUESTION_POOL[16].q` |
| B? | `"마침 공고가 떠서 넣어봤습니다."` | `locale/ui_zh-CN.json:1123`; `locale/ui_zh-TW.json:1123` | 2 | R8; `scenes/JobHuntMiniGame.gd::INTERVIEW_QUESTION_POOL[7].text` |
| B? | `"마포 공사장 도시락"` | `locale/ui_ja.json:3038`; `locale/ui_zh-CN.json:1220`; `locale/ui_zh-TW.json:1220` | 3 | R8; `scenes/ArubaGame.gd::DEL_ORDERS_DATA[10].name` |
| B? | `"만남을 지어내지 않고, 다음에 연락할 수 있도록 기록만 정리했다."` | — | 0 | R8; `$.seoul_cycle.terminal_routes.m2_people_expired_to_m3_contact_fail_forward.result` |
| B? | `"맡은 시간과 정산을 끝까지 확인하는 습관입니다. 여러 단기 일을 오갈 때도 근무 기록을 빠뜨리지 않았습니다."` | `locale/ui_zh-CN.json:1124`; `locale/ui_zh-TW.json:1124` | 2 | R8; `scenes/JobHuntMiniGame.gd::RESUME_QUESTION_POOL[7].text` |
| B? | `"매주 공부 시간을 지켜 다음 지원서와 면접에 필요한 실력을 쌓는다."` | — | 0 | R8; `$.routine.options.growth.description` |
| B? | `"매주 잠과 식사를 먼저 챙겨 건강과 정신력을 회복한다."` | — | 0 | R8; `$.routine.options.recovery.description` |
| B? | `"먼저 들어온 일을 먼저 처리합니다."` | `locale/ui_zh-CN.json:1125`; `locale/ui_zh-TW.json:1125` | 2 | R8; `scenes/JobHuntMiniGame.gd::INTERVIEW_QUESTION_POOL[30].text` |
| B? | `"먼저 문제의 범위를 파악하고, 팀과 협력해 최단 시간 내 해결책을 찾겠습니다."` | `locale/ui_zh-CN.json:1126`; `locale/ui_zh-TW.json:1126` | 2 | R8; `scenes/JobHuntMiniGame.gd::INTERVIEW_QUESTION_POOL[21].text` |
| B? | `"먼저 상대방의 입장을 충분히 듣고, 공통된 목표를 기준으로 합의점을 찾습니다."` | `locale/ui_zh-CN.json:1127`; `locale/ui_zh-TW.json:1127` | 2 | R8; `scenes/JobHuntMiniGame.gd::RESUME_QUESTION_POOL[22].text` |
| B? | `"먼저 연락하지 않는 동안 현수는 혼자 공부했다. 함께 공부하자는 말은 나오지 않았다."` | — | 0 | R8; `$.decline_outcomes.hyunsu_studies_alone_and_the_opening_cools.message` |
| B? | `"먼저 할 일"` | — | 0 | R8; `$.months[5].title` |
| B? | `"먼저 함께 공부하자고 연락한 뒤, 이번에는 현수가 같은 시간에 다시 공부하자고 한다."` | — | 0 | R8; `$.seoul_cycle.terminal_routes.m2_people_completed_hyunsu_to_m3_followup.detail` |
| B? | `"먼저 함께 공부하자고 한 뒤 얼마 지나지 않아, 이번에는 현수가 같은 시간에 다시 한 시간 공부하자고 한다."` | — | 0 | R8; `$.scene_bundles.hyunsu_study_followup.detail` |
| B? | `"메시지를 읽고도 이번 달에는 답하지 않는다."` | — | 0 | R8; `$.scene_bundles.jaehyuk_world_meet.decline` |
| B? | `"면접관이 가장 먼저 읽는 문항. 진정성이 핵심."` | `locale/ui_zh-CN.json:1130`; `locale/ui_zh-TW.json:1130` | 2 | R8; `scenes/JobHuntMiniGame.gd::RESUME_QUESTION_POOL[1].hint` |
| B? | `"면접실 · 청년센터"` | — | 0 | R8; `$.seoul_cycle.months.4.nodes.m4_advancement.place` |
| B? | `"명함은 이번 달에도 지갑 안에만 남는다."` | — | 0 | R8; `$.scene_bundles.sangchul_second_coffee.decline` |
| B? | `"모든 일을 동시에 처리하려 노력합니다."` | `locale/ui_zh-CN.json:1132`; `locale/ui_zh-TW.json:1132` | 2 | R8; `scenes/JobHuntMiniGame.gd::INTERVIEW_QUESTION_POOL[31].text` |
| B? | `"모르는 번호"` | — | 0 | R8; `$.scene_bundles.first_temptation_boss.offer` |
| B? | `"모르는 번호의 제안은 그날 밤 받거나 거절했다."` | — | 0 | R8; `$.decline_outcomes.the_offer_is_answered_or_refused_in_scene.message` |
| B? | `"목·금·토 사흘 심야 상하차"` | — | 0 | R8; `$.scene_bundles.m6_holiday_night_shift.offer` |
| B? | `"목요일 대타는 다른 사람이 맡았다. 그날 받을 수 있었던 돈은 벌지 못했다."` | — | 0 | R8; `$.decline_outcomes.cash_buffer_does_not_grow.message` |
| B? | `"목요일 밤 대타"` | — | 0 | R8; `$.scene_bundles.m1_convenience_trial_shift.offer` |
| B? | `"목요일 밤 대타를 마치고 받은 돈은 통장에 남아 있었다. 손바닥에는 비닐장갑 안에서 불은 자국이 아직 옅게 보였다."` | — | 0 | R8; `$.episode_plan.primary_echo.m1_convenience_trial_shift.copy` |
| B? | `"목요일 야간 대타를 맡는다"` | — | 0 | R8; `$.scene_bundles.m1_convenience_trial_shift.decision` |
| B? | `"목요일부터 토요일까지 이어지는 사흘 심야 상하차 자리는 다른 사람으로 채워졌다. 받을 수 있었던 48만원은 벌지 못했다."` | — | 0 | R8; `$.decline_outcomes.holiday_shift_is_filled.message` |
| B? | `"목요일부터 토요일까지 이어지는 사흘 심야조는 다른 사람으로 채워진다."` | — | 0 | R8; `$.scene_bundles.m6_holiday_night_shift.decline` |
| D | `"목표 30억원. 남은 시간은 5년."` | `locale/ui_ja.json:3091`; `locale/ui_zh-CN.json:2386`; `locale/ui_zh-TW.json:2386` | 3 | R8/R11; `scenes/OpeningCinematic.gd::BEATS[2].title` |
| D | `"몸 — 오늘 밤 일을 더 할지, 알람 하나만 맞추고 누워 쉴지 정해야 했다."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.candidate_copy.evidence.body_rest` |
| B? | `"몸과 방값 점검"` | — | 0 | R8; `$.seoul_cycle.months.4.nodes.m4_self.board_label` |
| B? | `"몸과 방값 함께 점검하기"` | — | 0 | R8; `$.seoul_cycle.months.4.nodes.m4_self.label` |
| B? | `"못 본 척한다"` | `locale/ui_zh-CN.json:1221`; `locale/ui_zh-TW.json:1221` | 2 | R8; `scenes/ArubaGame.gd::CUSTOMER_TYPES[26].text` |
| B? | `"무료 근로계약 상담 접수가 끝났다. 다음 계약서도 혼자 읽어야 한다."` | — | 0 | R8; `$.decline_outcomes.contract_clinic_intake_closes.message` |
| B? | `"무료 근로계약 상담"` | — | 0 | R8; `$.scene_bundles.m5_employment_contract_clinic.offer` |
| B? | `"무료 상담에서 계약 기간, 임금 지급일, 연장근로 항목에 표시를 했다. 당장 일자리가 생긴 것은 아니지만 다음 계약서에서 무엇을 확인할지는 알게 됐다."` | — | 0 | R8; `$.scene_bundles.m5_employment_contract_clinic.action_config.result_body` |
| B? | `"무시하고 다른 손님 먼저"` | `locale/ui_zh-CN.json:1222`; `locale/ui_zh-TW.json:1222` | 2 | R8; `scenes/ArubaGame.gd::CUSTOMER_TYPES[12].text` |
| B? | `"무직이면 매주 단기 일을 잡고, 취업 뒤에는 맡은 일을 버틴다."` | — | 0 | R8; `$.routine.options.livelihood.description` |
| B? | `"문장 구조를 다시 잡는 시간을 아껴 마지막 확인까지 마쳤다. 마음 +1"` | — | 0 | R8; `$.seoul_cycle.terminal_routes.m1_resume_completed_q3_to_m2_advancement_ready.result` |
| B? | `"문장을 거의 새로 썼다. 늦지 않게 보냈지만 기운이 더 들었다. 마음 -2"` | — | 0 | R8; `$.seoul_cycle.terminal_routes.m1_resume_completed_q0_to_m2_advancement_rewritten.result` |
| B? | `"문장을 다시 고쳐 서린물산 지원하기"` | — | 0 | R8; `$.seoul_cycle.terminal_routes.m1_resume_completed_q1_to_m2_advancement_revised.label` |
| B? | `"물류 인력사무소 · 분류 창고"` | — | 0 | R8; `$.seoul_cycle.months.4.nodes.m4_livelihood.place` |
| B? | `"물류관리 기초 수업을 들었다"` | — | 0 | R8; `$.scene_bundles.m4_certificate_session.action_config.result_title` |
| B? | `"물류센터에서 엿새 밤 택배 상자를 구역별로 나눈다."` | — | 0 | R8; `$.scene_bundles.m4_logistics_shift.detail` |
| B? | `"미래산업기술 지원 마감일이 지났다. 이번 달에는 같은 자리에 지원할 수 없다."` | — | 0 | R8; `$.decline_outcomes.this_posting_expires.message` |
| B? | `"미래산업기술 지원서를 보냈다"` | — | 0 | R8; `$.scene_bundles.m1_youth_center_resume_clinic.action_config.result_title` |
| B? | `"미래산업기술 채용 공고"` | — | 0 | R8; `$.scene_bundles.m1_mirae_application.offer` |
| D | `"미룬 일 — 다은의 야간 근무 시간에 찾아가 먼저 안부를 묻지 못했다."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.candidate_copy.not_done.daeun_checkin` |
| D | `"미룬 일 — 아버지가 다니는 병원과 창원에 내려갈 날짜는 정하지 못했다."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.candidate_copy.not_done.father_call` |
| D | `"미룬 일 — 알람을 맞추고 누워 쉬지 못했다."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.candidate_copy.not_done.body_rest` |
| D | `"미룬 일 — 이번 달 지출 영수증을 날짜순으로 적어 합계를 맞추지 못했다."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.candidate_copy.not_done.sangchul_ledger` |
| D | `"미룬 일 — 재혁에게 이번 주 안부를 먼저 보내지 못했다."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.candidate_copy.not_done.jaehyuk_reply` |
| D | `"미룬 일 — 한빛유통 월말 오류표는 오늘 내부 메일로 보내지 못했다."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.candidate_copy.not_done.hanbit_month_close` |
| B? | `"미룬 통화 뒤 연락할 시간을 다시 잡기"` | — | 0 | R8; `$.seoul_cycle.terminal_routes.m1_father_expired_to_m2_people_open.label` |
| B? | `"민준아, 네 아버지가 요 며칠 약국 봉투를 들고 들어오더라. 네가 한번 연락해 봐라."` | — | 0 | R8; `$.scene_bundles.father_health_signal.message_body` |
| B? | `"민준에게는 이번 달을 버틸 [b]주간 여력 네 개[/b]가 있습니다.\n숫자가 높을수록 한 주에 더 많은 일을 밀어붙일 수 있습니다.\n\n좋은 여력을 지금 써도 되고, 더 급한 주를 위해 남겨도 됩니다.\n한 번 쓴 여력은 다시 굴리거나 되돌릴 수 없습니다."` | — | 0 | R8; `scenes/TutorialOverlay.gd::core_loop_v2[0].body` |
| B? | `"밀린 잠 갚기"` | — | 0 | R8; `$.seoul_cycle.months.2.nodes.m2_self.label` |
| B? | `"밀린 잠 보충"` | — | 0 | R8; `$.seoul_cycle.months.2.nodes.m2_self.board_label` |
| B? | `"밀린 잠을 자는 일요일"` | — | 0 | R8; `$.scene_bundles.m2_sleep_debt_sunday.offer` |
| B? | `"바쁜 척 빠르게 처리한다"` | `locale/ui_zh-CN.json:1225`; `locale/ui_zh-TW.json:1225` | 2 | R8; `scenes/ArubaGame.gd::CUSTOMER_TYPES[18].text` |
| B? | `"반갑게 인사하며 응대한다"` | `locale/ui_zh-CN.json:1226`; `locale/ui_zh-TW.json:1226` | 2 | R8; `scenes/ArubaGame.gd::CUSTOMER_TYPES[16].text` |
| B? | `"방 안에 밀린 영수증과 빨래부터 처리한다."` | — | 0 | R8; `$.scene_bundles.m3_room_ledger.detail` |
| B? | `"방 안의 밀린 것들을 정리했다"` | — | 0 | R8; `$.scene_bundles.m3_room_ledger.action_config.result_title` |
| B? | `"방향만 손으로 가리킨다"` | `locale/ui_zh-CN.json:1227`; `locale/ui_zh-TW.json:1227` | 2 | R8; `scenes/ArubaGame.gd::CUSTOMER_TYPES[50].text` |
| B? | `"배달 콜과 비 오는 금요일"` | — | 0 | R8; `$.seoul_cycle.months.2.nodes.m2_livelihood.label` |
| B? | `"버스정류장에서 지연을 다시 본 뒤, 만나게 될지는 모른 채 19주차나 20주차 저녁에 같은 동네 큰길로 돌아간다."` | — | 0 | R8; `$.scene_bundles.jiyeon_second_crossing.detail` |
| B? | `"변화 대응력과 학습 의지를 어필하는 문항."` | `locale/ui_zh-CN.json:1135`; `locale/ui_zh-TW.json:1135` | 2 | R8; `scenes/JobHuntMiniGame.gd::RESUME_QUESTION_POOL[31].hint` |
| B? | `"변화가 안정되기를 기다렸다가 움직입니다."` | `locale/ui_zh-CN.json:1136`; `locale/ui_zh-TW.json:1136` | 2 | R8; `scenes/JobHuntMiniGame.gd::RESUME_QUESTION_POOL[34].text` |
| B? | `"변화의 핵심을 빠르게 파악하고, 관련 자료와 교육을 스스로 찾아 학습합니다."` | `locale/ui_zh-CN.json:1137`; `locale/ui_zh-TW.json:1137` | 2 | R8; `scenes/JobHuntMiniGame.gd::RESUME_QUESTION_POOL[32].text` |
| B? | `"보건소 검진 뒤 반나절 쉬기"` | — | 0 | R8; `$.scene_bundles.m4_health_check_day.offer` |
| B? | `"보건소 검진 예약을 잡지 못했다. 다음 접수일을 다시 확인해야 한다."` | — | 0 | R8; `$.decline_outcomes.health_check_is_postponed.message` |
| B? | `"보건소에서 기본 검사를 받고 그날 오후에는 일을 잡지 않는다."` | — | 0 | R8; `$.scene_bundles.m4_health_check_day.detail` |
| B? | `"보내지 못한 연락을 정리하기"` | — | 0 | R8; `$.seoul_cycle.terminal_routes.m2_people_expired_to_m3_contact_fail_forward.label` |
| D | `"보낸 파일을 닫은 뒤 {name}은 지원 번호가 적힌 페이지에서 결정 페이지로 돌아갔다."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.candidate_copy.return.city_work_sample` |
| B? | `"본인의 강점을 구체적인 경험과 함께 서술하시오."` | `locale/ui_zh-CN.json:1138`; `locale/ui_zh-TW.json:1138` | 2 | R8; `scenes/JobHuntMiniGame.gd::RESUME_QUESTION_POOL[5].q` |
| B? | `"본인의 실패 경험과 그로부터 배운 점을 서술하시오."` | `locale/ui_zh-CN.json:1139`; `locale/ui_zh-TW.json:1139` | 2 | R8; `scenes/JobHuntMiniGame.gd::RESUME_QUESTION_POOL[25].q` |
| B? | `"본인이 이 직무에 적합한 이유를 서술하시오."` | `locale/ui_zh-CN.json:1140`; `locale/ui_zh-TW.json:1140` | 2 | R8; `scenes/JobHuntMiniGame.gd::RESUME_QUESTION_POOL[35].q` |
| B? | `"불을 끄고 본 SNS 피드"` | — | 0 | R8; `$.scene_bundles.sns_pressure_night.offer` |
| B? | `"불을 끄고 잔 밤의 흔적처럼 이불 한쪽이 깊게 눌려 있었다. 몸은 조금 나아졌지만 모르는 번호는 그대로 빛났다."` | — | 0 | R8; `$.seoul_cycle.months.1.nodes.recovery.echo; $.seoul_cycle.nodes.recovery.echo` |
| D | `"불을 끄기 전 {name}은 침대 옆 수첩의 결정 페이지를 한 번만 다시 펼쳤다."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.candidate_copy.return.body_rest` |
| B? | `"비 오는 날 배달"` | — | 0 | R8; `$.seoul_cycle.months.2.nodes.m2_livelihood.board_label` |
| B? | `"비 할증이 붙는 저녁 배달 한 번으로 생활비를 보탠다."` | — | 0 | R8; `$.scene_bundles.m2_rain_delivery_shift.detail` |
| B? | `"비가 갠 날, 신촌역에서 버스로 돌아가기"` | — | 0 | R8; `$.scene_bundles.jiyeon_bus_stop_reunion.offer` |
| B? | `"비가 그쳤고 할증 배달도 끝났다. 그날 받을 수 있었던 수입은 벌지 못했다."` | — | 0 | R8; `$.decline_outcomes.rain_shift_passes.message` |
| B? | `"비가 예보된 금요일 배달"` | — | 0 | R8; `$.scene_bundles.m2_rain_delivery_shift.offer` |
| B? | `"비가 예보된 이번 달 금요일"` | — | 0 | R8; `$.scene_bundles.m2_rain_delivery_shift.deadline` |
| B? | `"빈 문서부터 다시 만들었지만 지원을 포기하지는 않았다. 마음 -3"` | — | 0 | R8; `$.seoul_cycle.terminal_routes.m1_resume_expired_to_m2_advancement_rebuilt.result` |
| B? | `"빈 문서부터 서린물산 지원서 다시 만들기"` | — | 0 | R8; `$.seoul_cycle.terminal_routes.m1_resume_expired_to_m2_advancement_rebuilt.label` |
| B? | `"빚을 갚는 데만 매달려 정규직 준비를 오래 미뤘습니다. 이제는 생계와 지원 일정을 함께 관리하고 있습니다."` | `locale/ui_zh-CN.json:1141`; `locale/ui_zh-TW.json:1141` | 2 | R8; `scenes/JobHuntMiniGame.gd::RESUME_QUESTION_POOL[27].text` |
| B? | `"빠르게 변화하는 업무 환경에 어떻게 적응하나요?"` | `locale/ui_zh-CN.json:1142`; `locale/ui_zh-TW.json:1142` | 2 | R8; `scenes/JobHuntMiniGame.gd::RESUME_QUESTION_POOL[30].q` |
| B? | `"빠르게 스캔한다"` | `locale/ui_zh-CN.json:1232`; `locale/ui_zh-TW.json:1232` | 2 | R8; `scenes/ArubaGame.gd::CUSTOMER_TYPES[2].text` |
| B? | `"사흘 심야 상하차조 잡기"` | — | 0 | R8; `$.seoul_cycle.months.6.nodes.m6_livelihood.label` |
| B? | `"사흘 연속 심야 상하차를 마쳤다"` | — | 0 | R8; `$.scene_bundles.m6_holiday_night_shift.action_config.result_title` |
| B? | `"상급자에게 중재를 요청합니다."` | `locale/ui_zh-CN.json:1143`; `locale/ui_zh-TW.json:1143` | 2 | R8; `scenes/JobHuntMiniGame.gd::RESUME_QUESTION_POOL[23].text` |
| B? | `"상담 운영 공고에 이력서를 첨부했다. 접수 확인 메일은 왔지만 면접 일정은 아직 정해지지 않았다."` | — | 0 | R8; `$.scene_bundles.m4_dodam_application.action_config.result_body` |
| B? | `"상사나 동료에게 방향을 물어보고 따릅니다."` | `locale/ui_zh-CN.json:1144`; `locale/ui_zh-TW.json:1144` | 2 | R8; `scenes/JobHuntMiniGame.gd::RESUME_QUESTION_POOL[33].text` |
| D | `"상철 — 직접 쓰는 돈부터 적어 보라는 빈 메모지와 서랍에 넣어 둔 명함."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.candidate_copy.evidence.sangchul_ledger` |
| B? | `"상철의 명함으로 먼저 전화하기"` | — | 0 | R8; `$.scene_bundles.sangchul_second_coffee.offer` |
| B? | `"상철의 명함은 지갑에 남았다. 이번 달에는 적힌 번호로 전화하지 않았다."` | — | 0 | R8; `$.decline_outcomes.sangchul_card_stays_unused.message` |
| B? | `"상품 위치를 묻는 손님"` | `locale/ui_zh-CN.json:1233`; `locale/ui_zh-TW.json:1233` | 2 | R8; `scenes/ArubaGame.gd::CUSTOMER_TYPES[46].name` |
| B? | `"상황을 상사에게 즉시 보고하겠습니다."` | `locale/ui_zh-CN.json:1145`; `locale/ui_zh-TW.json:1145` | 2 | R8; `scenes/JobHuntMiniGame.gd::INTERVIEW_QUESTION_POOL[22].text` |
| B? | `"새 지원서를 보내는 대신, 선택한 주에 공공기관 계약직 필기 문제를 실제 제한 시간에 맞춰 푼다."` | — | 0 | R8; `$.scene_bundles.m6_public_recruitment.detail` |
| B? | `"새벽 라면 물이 끓는 동안 옆방의 낯선 이웃과 처음 몇 마디를 나눈다."` | — | 0 | R8; `$.scene_bundles.hyunsu_first_meet.detail` |
| B? | `"새벽 물류 상자를 한 번 더 날랐다. 손목이 먼저 오늘을 기억했다."` | — | 0 | R8; `scenes/MainGame.gd::SIDE_JOB_VIGNETTES_CONVENIENCE[1].t` |
| B? | `"새벽 주방의 남자는 이름 없는 이웃으로 남았다."` | — | 0 | R8; `$.decline_outcomes.the_neighbor_remains_only_a_face.message` |
| B? | `"새벽 편의점의 계산대"` | — | 0 | R8; `$.scene_bundles.daeun_world_meet.offer` |
| B? | `"생활비를 벌려고 단기 일을 이어가던 달, 잠이 오지 않은 새벽에 24시간 편의점에 들어가 계산대 직원과 처음 말을 섞는다."` | — | 0 | R8; `$.scene_bundles.daeun_world_meet.detail` |
| B? | `"서린물산 계약직 공고"` | — | 0 | R8; `$.scene_bundles.m2_seorin_application.offer` |
| B? | `"서린물산 마감 뒤 한빛유통에 다시 지원하기"` | — | 0 | R8; `$.seoul_cycle.terminal_routes.m2_advancement_expired_to_m3_advancement_retry.label` |
| B? | `"서린물산 지원 마감은 놓쳤지만 빈 지원 기록을 덮어 두지 않고 한빛유통 운영지원 공고에 다시 지원한다."` | — | 0 | R8; `$.seoul_cycle.terminal_routes.m2_advancement_expired_to_m3_advancement_retry.detail` |
| B? | `"서린물산 지원 마감일이 지났다. 지원서를 보내지 않았다."` | — | 0 | R8; `$.decline_outcomes.seorin_posting_expires.message` |
| B? | `"서린물산 지원"` | — | 0 | R8; `$.seoul_cycle.months.2.nodes.m2_advancement.board_label` |
| B? | `"서린물산 지원서 완성하기"` | — | 0 | R8; `$.seoul_cycle.months.2.nodes.m2_advancement.label` |
| B? | `"서린물산 지원서를 보냈다"` | — | 0 | R8; `$.scene_bundles.m2_seorin_application.action_config.result_title` |
| B? | `"서린물산의 이번 채용은 끝난다."` | — | 0 | R8; `$.scene_bundles.m2_seorin_application.decline` |
| B? | `"서울 배달 동선"` | — | 0 | R8; `$.seoul_cycle.months.2.nodes.m2_livelihood.place` |
| B? | `"서울 사이클에서는 생계·앞날·사람·회복 변화가 실제로 여력을 배치한 노드에서만 발생한다."` | — | 0 | R8; `$.seoul_cycle.background_routines.reason` |
| B? | `"선반·스캐너"` | — | 0 | R8; `$.scene_bundles.m3_inventory_shift.action_config.requirements[0].station` |
| B? | `"선반은 다시 세어도 열한 개였다. 전날 반품 보관함으로 옮긴 한 개가 전산에 남은 기록도 찾았다. 인계표에는 차이와 확인 시각, 원인을 모두 적었다. 세 가지를 마쳤을 때는 교대 시각을 훌쩍 넘긴 뒤였다."` | — | 0 | R8; `$.scene_bundles.m3_inventory_shift.action_config.overreach.finish` |
| B? | `"선반은 두 번 세어도 열한 개였다. 인계표에는 전산 12개와 선반 11개, 확인 시각을 적었다. 어느 입고·반품 기록에서 어긋났는지는 찾지 못했다."` | — | 0 | R8; `$.scene_bundles.m3_inventory_shift.action_config.outcomes.inventory_untraced_handoff.finish` |
| B? | `"선반은 두 번 세어도 열한 개였다. 전날 한 개를 반품 보관함으로 옮겼지만 전산에는 아직 남아 있다는 기록도 찾았다. 인계표에는 아무것도 적지 못했다."` | — | 0 | R8; `$.scene_bundles.m3_inventory_shift.action_config.outcomes.inventory_trace_before_handoff.finish` |
| B? | `"선반은 두 번 세어도 열한 개였다. 차이 표시 옆에는 확인 시각과 선반 번호를 적었다."` | — | 0 | R8; `$.scene_bundles.m3_inventory_shift.action_config.legacy_instant_effect.finish` |
| B? | `"선반을 다시 세고 원인을 찾음 · 인계표는 남기지 못함"` | — | 0 | R8; `$.scene_bundles.m3_inventory_shift.action_config.outcomes.inventory_trace_before_handoff.recap` |
| B? | `"선반을 다시 세고 차이를 기록함 · 원인은 찾지 못함"` | — | 0 | R8; `$.scene_bundles.m3_inventory_shift.action_config.outcomes.inventory_untraced_handoff.recap` |
| B? | `"선반을 다시 세고 차이에 시각·선반 번호를 표시함"` | — | 0 | R8; `$.scene_bundles.m3_inventory_shift.action_config.legacy_instant_effect.recap` |
| B? | `"선반을 처음부터 다시 센다"` | — | 0 | R8; `$.scene_bundles.m3_inventory_shift.action_config.requirements[0].label` |
| B? | `"선반의 열한 개를 처음부터 다시 세어 실제 수량을 확인한다."` | — | 0 | R8; `$.scene_bundles.m3_inventory_shift.action_config.requirements[0].detail` |
| B? | `"선택한 주 도서관에서 각자 푼 문제를 바꿔 채점하고 오답 풀이를 설명한다."` | — | 0 | R8; `$.scene_bundles.m6_last_study_group.detail` |
| B? | `"선택한 주 목요일부터 토요일까지 택배 상자를 내리고 구역별로 쌓는다."` | — | 0 | R8; `$.scene_bundles.m6_holiday_night_shift.detail` |
| B? | `"선택한 주 목요일부터 토요일까지 택배 상자를 내리고 구역별로 쌓아 48만원을 받았다. 어깨와 손목에는 사흘 밤의 무게가 남았다."` | — | 0 | R8; `$.scene_bundles.m6_holiday_night_shift.action_config.result_body` |
| B? | `"선택한 주 월요일부터 목요일까지 구청 전산실에서 재고표 정렬과 기초 수식을 배운다."` | — | 0 | R8; `$.scene_bundles.m5_evening_spreadsheet_class.detail` |
| B? | `"선택한 주 월요일부터 목요일까지 재고표를 정렬하고 오류가 난 수식을 찾아 고쳤다. 수료증과 직접 만든 표 한 장을 다음 지원서에 첨부할 수 있게 됐다."` | — | 0 | R8; `$.scene_bundles.m5_evening_spreadsheet_class.action_config.result_body` |
| B? | `"선택한 주 하루는 일도 약속도 잡지 않고 잠과 식사를 먼저 챙긴다."` | — | 0 | R8; `$.scene_bundles.m6_no_plans_day.detail` |
| B? | `"선택한 주에 나흘 연속 이삿짐 차량을 따라다니며 상자와 가구를 나른다."` | — | 0 | R8; `$.scene_bundles.m5_weekend_move_shift.detail` |
| B? | `"섭섭해하셨다."` | `locale/ui_zh-CN.json:1235`; `locale/ui_zh-TW.json:1235` | 2 | R8; `scenes/ArubaGame.gd::CUSTOMER_TYPES[19].tip` |
| B? | `"성실하고 책임감이 강합니다. 맡은 일은 끝까지 완수합니다."` | `locale/ui_zh-CN.json:1146`; `locale/ui_zh-TW.json:1146` | 2 | R8; `scenes/JobHuntMiniGame.gd::RESUME_QUESTION_POOL[8].text` |
| B? | `"성장 가능성이 있다고 판단해 지원하게 됐습니다."` | `locale/ui_zh-CN.json:1147`; `locale/ui_zh-TW.json:1147` | 2 | R8; `scenes/JobHuntMiniGame.gd::RESUME_QUESTION_POOL[3].text` |
| B? | `"세 번째 달 게시판이 바뀌기 전"` | — | 0 | R8; `$.scene_bundles.m3_library_job_board.deadline` |
| B? | `"세 번째 달이 끝나기 전"` | — | 0 | R8; `$.scene_bundles.m3_room_ledger.deadline` |
| B? | `"세뱃돈 같은 거라며 주셨다."` | `locale/ui_zh-CN.json:1236`; `locale/ui_zh-TW.json:1236` | 2 | R8; `scenes/ArubaGame.gd::CUSTOMER_TYPES[17].tip` |
| D | `"손가락은 움직였지만 어깨가 무거웠다. 한 가지는 끝낼 수 있어도 두 가지를 붙잡을 몸은 아니었다."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.body_check[2].copy` |
| D | `"손가락을 펴는 데 한 박자가 더 걸렸다. 허리를 세우자 숨이 얕아졌다. 지금 한 번 더 무리하면 몸이 먼저 멈출 상태였다."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.body_check[0].copy` |
| D | `"손과 허리에 뚜렷한 통증은 없었다. 그래도 남은 시간은 한 가지를 제대로 끝내기에 충분할 뿐이었다."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.body_check[3].copy` |
| B? | `"손님은 고맙다며 2천 원을 계산대에 두고 갔다."` | `locale/ui_zh-CN.json:1238`; `locale/ui_zh-TW.json:1238` | 2 | R8; `scenes/ArubaGame.gd::CUSTOMER_TYPES[25].tip` |
| B? | `"손님은 고맙다며 팁 천 원을 두고 갔다."` | `locale/ui_zh-CN.json:1239`; `locale/ui_zh-TW.json:1239` | 2 | R8; `scenes/ArubaGame.gd::CUSTOMER_TYPES[37].tip; scenes/ArubaGame.gd::CUSTOMER_TYPES[49].tip` |
| B? | `"손님은 기다려야 한다며 불만을 보였다."` | `locale/ui_zh-CN.json:1240`; `locale/ui_zh-TW.json:1240` | 2 | R8; `scenes/ArubaGame.gd::CUSTOMER_TYPES[33].tip` |
| B? | `"손님은 다시 오지 않겠다며 나갔다."` | `locale/ui_zh-CN.json:1241`; `locale/ui_zh-TW.json:1241` | 2 | R8; `scenes/ArubaGame.gd::CUSTOMER_TYPES[45].tip` |
| B? | `"손님은 미안했다며 팁 천 원을 계산대에 두고 갔다."` | `locale/ui_zh-CN.json:1242`; `locale/ui_zh-TW.json:1242` | 2 | R8; `scenes/ArubaGame.gd::CUSTOMER_TYPES[11].tip` |
| B? | `"손님은 불만스러운 표정으로 택배를 찾았다."` | `locale/ui_zh-CN.json:1243`; `locale/ui_zh-TW.json:1243` | 2 | R8; `scenes/ArubaGame.gd::CUSTOMER_TYPES[39].tip` |
| B? | `"손님은 점장에게 항의하겠다고 했다."` | `locale/ui_zh-CN.json:1244`; `locale/ui_zh-TW.json:1244` | 2 | R8; `scenes/ArubaGame.gd::CUSTOMER_TYPES[13].tip` |
| B? | `"손님은 한숨을 쉬며 기다렸다."` | `locale/ui_zh-CN.json:1245`; `locale/ui_zh-TW.json:1245` | 2 | R8; `scenes/ArubaGame.gd::CUSTOMER_TYPES[5].tip` |
| B? | `"손님은 혼자 한참 매장을 헤맸다."` | `locale/ui_zh-CN.json:1246`; `locale/ui_zh-TW.json:1246` | 2 | R8; `scenes/ArubaGame.gd::CUSTOMER_TYPES[27].tip` |
| D | `"손바닥과 허리에 이번 달의 피로가 남아 있었다. 움직일 수는 있었지만 밤을 더 쓰면 회복할 자리가 거의 없었다."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.body_check[1].copy` |
| B? | `"솔직히 잘 모르겠습니다."` | `locale/ui_zh-CN.json:1148`; `locale/ui_zh-TW.json:1148` | 2 | R8; `scenes/JobHuntMiniGame.gd::INTERVIEW_QUESTION_POOL[11].text` |
| D | `"수요일에 받은 경찰의 초기 확인 전화도 수첩 한쪽에 남아 있었다. 아직 결론은 없었다."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.trace_copy.v2_dirty_trace_initial_call.claimed` |
| D | `"수요일에 새 번호로 온 모집책의 문자도 화면에 남아 있었다. 이전에 넘긴 세 세트까지 사라진 것은 아니었다."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.trace_copy.v2_dirty_recruiter_week24.claimed` |
| D | `"수요일에 새 번호를 차단했지만, 이전에 넘긴 통장과 체크카드 세 세트는 그대로 과거에 남아 있었다."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.trace_copy.v2_dirty_recruiter_week24.choices.0` |
| D | `"수요일에 온 모집책 문자와 발신 시각을 캡처해 보관했다. 원본 문자도 지우지 않았다."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.trace_copy.v2_dirty_recruiter_week24.choices.1` |
| D | `"수요일의 경찰 전화 옆에는 계좌를 넘긴 날부터 150만원 반환에 동의한 날까지 말한 순서가 적혀 있었다. 출석 날짜와 처분은 아직 정해지지 않았다."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.trace_copy.v2_dirty_trace_initial_call.choices.0` |
| D | `"수요일의 경찰 전화 옆에는 받아 적은 담당 부서와 사건번호가 남아 있었다. 요청 자료와 출석 날짜, 처분은 아직 정해지지 않았다."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.trace_copy.v2_dirty_trace_initial_call.choices.1` |
| B? | `"쉰 기록이 다음 달의 회복 방식까지 이어졌다."` | — | 0 | R8; `$.seoul_cycle.terminal_routes.m2_self_completed_to_m3_self_recovered.result` |
| B? | `"스캐너를 처음 칸으로 돌렸다. 두 번째로 세어도 선반에는 열한 개가 있었다."` | — | 0 | R8; `$.scene_bundles.m3_inventory_shift.action_config.requirements[0].feedback` |
| B? | `"시설 운영 기록을 정리하는 여섯 달 계약직 공고에 이력서를 보냈다. 접수번호는 왔지만 결과는 다음 달에 확인해야 한다."` | — | 0 | R8; `$.scene_bundles.m5_city_service_application.action_config.result_body` |
| B? | `"시설 점검표와 민원 기록을 정리하는 여섯 달 계약직에 이력서를 보낸다."` | — | 0 | R8; `$.scene_bundles.m5_city_service_application.detail` |
| B? | `"시험 전 마지막 문제에 답하기"` | — | 0 | R8; `$.scene_bundles.hyunsu_exam_eve.offer` |
| B? | `"시험 전 마지막 일요일 밤, 현수가 카카오톡으로 보낸 행정법 한 문제를 함께 보거나 지금은 덮고 자라고 답한다."` | — | 0 | R8; `$.scene_bundles.hyunsu_exam_eve.detail` |
| B? | `"시험 전 마지막 주에 현수의 카카오톡을 읽었지만, 한 문제도 함께 보지 않았고 쉬라는 답장도 보내지 못했다."` | — | 0 | R8; `$.decline_outcomes.hyunsu_takes_the_exam_without_another_shared_hour.message` |
| B? | `"시험 전 마지막 주의 메시지를 읽고도 답하지 못한다."` | — | 0 | R8; `$.scene_bundles.hyunsu_exam_eve.decline` |
| B? | `"신촌 골목의 검은 세단"` | — | 0 | R8; `$.scene_bundles.jiyeon_world_meet.offer` |
| B? | `"신촌 골목의 부동산에서 보증금과 월세를 직접 물어본다."` | — | 0 | R8; `$.scene_bundles.sangchul_world_meet.detail` |
| B? | `"신촌 피자"` | `locale/ui_ja.json:3039`; `locale/ui_zh-CN.json:1247`; `locale/ui_zh-TW.json:1247` | 3 | R8; `scenes/ArubaGame.gd::DEL_ORDERS_DATA[2].name` |
| B? | `"실물 재확인"` | — | 0 | R8; `$.scene_bundles.m3_inventory_shift.action_config.requirements[0].short` |
| B? | `"실패를 인정하는 용기와 성장 의지를 보여준다."` | `locale/ui_zh-CN.json:1150`; `locale/ui_zh-TW.json:1150` | 2 | R8; `scenes/JobHuntMiniGame.gd::RESUME_QUESTION_POOL[26].hint` |
| B? | `"심야 물류조"` | — | 0 | R8; `$.seoul_cycle.months.4.nodes.m4_livelihood.board_label` |
| B? | `"심야 상하차조"` | — | 0 | R8; `$.seoul_cycle.months.6.nodes.m6_livelihood.board_label` |
| D | `"심야 하역을 잡으면 28만원이 바로 들어온다. 그 대가로 자정 너머까지 상자를 나르고 오늘의 모든 마감과 연락을 놓친다."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.candidate_copy.tradeoff.urgent_paid_shift` |
| B? | `"쌓인 영수증과 빨래가 다음 달로 넘어간다."` | — | 0 | R8; `$.scene_bundles.m3_room_ledger.decline` |
| B? | `"아래에서 여력 하나를 고른 뒤, 서울 보드의 [b]사람·직업·생계·회복[/b] 중\n한 곳에 놓습니다. 확정하기 전에는 늘어날 진전과 대가를 정확히 볼 수 있습니다.\n\n다른 곳에 시간을 쓰는 동안에도 마감과 세계의 시간은 흐릅니다.\n낮은 숫자도 실패로 되감기지 않고, 한 주의 흔적으로 남습니다."` | — | 0 | R8; `scenes/TutorialOverlay.gd::core_loop_v2[1].body` |
| B? | `"아무 약속 없는 일요일"` | — | 0 | R8; `$.seoul_cycle.months.5.nodes.m5_self.label` |
| B? | `"아무 약속도 없는 토요일"` | — | 0 | R8; `$.scene_bundles.m3_empty_saturday.offer` |
| B? | `"아무 약속도 잡지 않는 일요일"` | — | 0 | R8; `$.scene_bundles.m5_last_empty_sunday.offer` |
| B? | `"아무에게도 주지 않는 하루"` | — | 0 | R8; `$.scene_bundles.m6_no_plans_day.offer` |
| D | `"아버지 — 약국 봉투를 봤다는 이웃의 연락, 받지 않은 전화, 그리고 신경 쓰지 말라는 짧은 문자."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.candidate_copy.evidence.father_call` |
| B? | `"아버지 통화는 놓쳤지만 이번 달 연락할 시간을 비워 둔다. 누구의 관계도 대신 진전시키지 않는다."` | — | 0 | R8; `$.seoul_cycle.terminal_routes.m1_father_expired_to_m2_people_open.detail` |
| B? | `"아버지께 할 말 정리"` | — | 0 | R8; `$.seoul_cycle.months.1.nodes.father.board_label; $.seoul_cycle.nodes.father.board_label` |
| B? | `"아버지는 다시 묻지 않았다. 통화목록의 이름만 아래로 밀렸다."` | — | 0 | R8; `$.decline_outcomes.father_stops_asking_for_that_month.message` |
| B? | `"아버지는 이번 달에는 다시 묻지 않는다."` | — | 0 | R8; `$.scene_bundles.father_first_call.decline` |
| B? | `"아버지에게 다시 전화하지 않은 채 일요일이 하나 더 지났다. 통화목록의 아버지 이름은 아래로 밀렸다."` | — | 0 | R8; `$.decline_outcomes.another_sunday_passes_without_the_real_question.message` |
| B? | `"아버지에게 다시 전화한다"` | — | 0 | R8; `$.scene_bundles.father_first_call.decision` |
| D | `"아버지에게 전화하면 목소리는 들을 수 있다. 대신 병명도 방문 날짜도 오늘 확정되지 않은 채 18:00이 지난다."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.candidate_copy.tradeoff.father_call` |
| B? | `"아버지에게 할 말 적기"` | — | 0 | R8; `$.seoul_cycle.months.1.nodes.father.label; $.seoul_cycle.nodes.father.label` |
| B? | `"아버지와 짧은 안부를 나누고, 그 뒤에 남은 침묵까지 듣는다."` | — | 0 | R8; `$.scene_bundles.father_first_call.detail` |
| B? | `"아버지와 통화를 마친 뒤에도 마지막 침묵이 방에 남아 있었다. 통화 기록 아래에는 다음 월세 이체일이 떠 있었다."` | — | 0 | R8; `$.episode_plan.primary_echo.father_first_call.copy` |
| B? | `"아버지와 통화하기"` | — | 0 | R8; `$.scene_bundles.father_first_call.offer` |
| B? | `"아버지와 통화한 기록이 아직 화면 위쪽에 있었다. 그 아래에 저장하지 않은 번호가 새로 찍혔다."` | — | 0 | R8; `$.seoul_cycle.months.1.nodes.father.echo; $.seoul_cycle.nodes.father.echo` |
| B? | `"아버지의 보증으로 생긴 가족 빚을 갚느라 일을 이어 갔습니다. 지금은 정리돼 다시 취업을 준비하고 있습니다."` | `locale/ui_zh-CN.json:1151`; `locale/ui_zh-TW.json:1151` | 2 | R8; `scenes/JobHuntMiniGame.gd::INTERVIEW_QUESTION_POOL[1].text` |
| B? | `"아버지의 안부를 다시 묻는 일요일"` | — | 0 | R8; `$.seoul_cycle.terminal_routes.m1_father_completed_wellbeing_to_m3_quiet_call.label` |
| B? | `"알람을 끄고 늦게 일어나 씻은 뒤 밥을 챙겨 먹었다. 은행 앱과 일정표는 저녁까지 열지 않았다. 낮에는 부족했던 잠을 더 잤고, 오늘 잡힌 일은 없었다."` | — | 0 | R8; `$.scene_bundles.m6_no_plans_day.action_config.result_body` |
| B? | `"알람을 끄고 아무 약속 없이 씻고 밥을 먹은 뒤 오래 잤다. 저녁에는 몸이 조금 가벼워졌다."` | — | 0 | R8; `$.scene_bundles.m3_empty_saturday.action_config.result_body` |
| B? | `"알람을 끄고 하루 푹 쉬어 지친 몸을 추스른다."` | — | 0 | R8; `$.scene_bundles.m2_sleep_debt_sunday.detail` |
| B? | `"야! 왜 이렇게 느려!"` | `locale/ui_zh-CN.json:1250`; `locale/ui_zh-TW.json:1250` | 2 | R8; `scenes/ArubaGame.gd::CUSTOMER_TYPES[7].text` |
| B? | `"야... 소주 어디 있어요?"` | `locale/ui_zh-CN.json:1251`; `locale/ui_zh-TW.json:1251` | 2 | R8; `scenes/ArubaGame.gd::CUSTOMER_TYPES[21].text` |
| B? | `"야간 재고조사 조에 들어가기"` | — | 0 | R8; `$.seoul_cycle.months.3.nodes.m3_livelihood.label` |
| B? | `"야간 재고조사"` | — | 0 | R8; `$.seoul_cycle.months.3.nodes.m3_livelihood.board_label` |
| B? | `"약속 없는 일요일"` | — | 0 | R8; `$.seoul_cycle.months.5.nodes.m5_self.board_label` |
| B? | `"약속한 화요일에 다은을 찾아가기"` | — | 0 | R8; `$.scene_bundles.m6_daeun_tuesday_followthrough.offer` |
| B? | `"약속한 화요일에 편의점에 가지 않는다."` | — | 0 | R8; `$.scene_bundles.m6_daeun_tuesday_followthrough.decline` |
| D | `"어젯밤 마지막 대화에는 새 문제를 더 보지 말고 알람을 맞춘 뒤 자라는 답이 남아 있었다."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.hyunsu_memory_copy.hyunsu_exam_eve_rest_protected` |
| D | `"어젯밤 마지막 대화에는 함께 확인한 행정법 한 문제와 “여기까지만 보자”는 답이 남아 있었다."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.hyunsu_memory_copy.hyunsu_exam_eve_one_problem` |
| D | `"어젯밤 현수가 보낸 마지막 문제 아래에는 {name}의 답이 없었다. 답하지 못한 채 시험 시간이 먼저 왔다."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.hyunsu_memory_copy.hyunsu_exam_eve_unanswered` |
| B? | `"업무 중 우선순위가 충돌할 때 어떻게 결정하나요?"` | `locale/ui_zh-CN.json:1153`; `locale/ui_zh-TW.json:1153` | 2 | R8; `scenes/JobHuntMiniGame.gd::INTERVIEW_QUESTION_POOL[28].q` |
| B? | `"여러 단기 현장에서 손님 응대와 정산을 맡았습니다. 업무가 달라도 인수인계와 마감 확인은 빠뜨리지 않았습니다."` | `locale/ui_zh-CN.json:1154`; `locale/ui_zh-TW.json:1154` | 2 | R8; `scenes/JobHuntMiniGame.gd::INTERVIEW_QUESTION_POOL[33].text` |
| D | `"여섯 번째 달에도 하루를 온전히 비우지는 못했다."` | — | 0 | R8/R11; `$.decline_outcomes.the_first_bill_arrives_on_an_exhausted_body.message` |
| B? | `"여섯 번째 달에도 하루를 온전히 쉬지 못한다."` | — | 0 | R8; `$.scene_bundles.m6_no_plans_day.decline` |
| B? | `"여의도 사무실 야식"` | `locale/ui_ja.json:3040`; `locale/ui_zh-CN.json:1252`; `locale/ui_zh-TW.json:1252` | 3 | R8; `scenes/ArubaGame.gd::DEL_ORDERS_DATA[4].name` |
| B? | `"연락 미루지 않기"` | — | 0 | R8; `$.seoul_cycle.months.5.nodes.m5_people.board_label` |
| B? | `"연락처는 없지만 약속한 시간이 있다. 21주차 화요일 새벽, 다은이 근무하는 편의점에 직접 간다."` | — | 0 | R8; `$.scene_bundles.m6_daeun_tuesday_followthrough.detail` |
| B? | `"연락처는 없지만 이름을 알게 된 편의점으로 다시 가, 이번에는 내가 먼저 대화를 이어 간다."` | — | 0 | R8; `$.scene_bundles.daeun_third_greeting.detail` |
| B? | `"연락하고 만날 시간 맞추기"` | — | 0 | R8; `$.seoul_cycle.months.2.nodes.m2_people.label` |
| B? | `"연락해 약속 잡기"` | — | 0 | R8; `$.seoul_cycle.months.2.nodes.m2_people.board_label` |
| B? | `"연봉 조건이 괜찮고 집에서 가까워서 지원했습니다."` | `locale/ui_zh-CN.json:1155`; `locale/ui_zh-TW.json:1155` | 2 | R8; `scenes/JobHuntMiniGame.gd::RESUME_QUESTION_POOL[4].text` |
| B? | `"연봉 협상은 어떻게 되나요?"` | `locale/ui_zh-CN.json:1156`; `locale/ui_zh-TW.json:1156` | 2 | R8; `scenes/JobHuntMiniGame.gd::INTERVIEW_QUESTION_POOL[19].text` |
| B? | `"열심히 배우며 회사에 기여하겠습니다."` | `locale/ui_zh-CN.json:1157`; `locale/ui_zh-TW.json:1157` | 2 | R8; `scenes/JobHuntMiniGame.gd::RESUME_QUESTION_POOL[18].text` |
| B? | `"엿새 동안 택배 상자를 구역별로 나누고 52만원을 받았다. 손가락 마디와 허리에는 야간 작업의 피로가 남았다."` | — | 0 | R8; `$.scene_bundles.m4_logistics_shift.action_config.result_body` |
| B? | `"엿새 심야 물류 분류"` | — | 0 | R8; `$.scene_bundles.m4_logistics_shift.offer` |
| B? | `"엿새 심야 물류조 들어가기"` | — | 0 | R8; `$.seoul_cycle.months.4.nodes.m4_livelihood.label` |
| B? | `"엿새 심야 분류 일을 마쳤다"` | — | 0 | R8; `$.scene_bundles.m4_logistics_shift.action_config.result_title` |
| B? | `"엿새짜리 심야 물류 분류조는 다른 사람으로 채워졌다."` | — | 0 | R8; `$.decline_outcomes.logistics_shift_is_filled.message` |
| B? | `"엿새짜리 야간조는 다른 사람으로 채워진다."` | — | 0 | R8; `$.scene_bundles.m4_logistics_shift.decline` |
| B? | `"영수증 보고 재적립 처리"` | `locale/ui_zh-CN.json:1253`; `locale/ui_zh-TW.json:1253` | 2 | R8; `scenes/ArubaGame.gd::CUSTOMER_TYPES[42].text` |
| B? | `"영수증 확인 후 즉시 교환"` | `locale/ui_zh-CN.json:1254`; `locale/ui_zh-TW.json:1254` | 2 | R8; `scenes/ArubaGame.gd::CUSTOMER_TYPES[30].text` |
| B? | `"영수증·빨래 정리"` | — | 0 | R8; `$.seoul_cycle.months.3.nodes.m3_self.board_label` |
| B? | `"영수증과 빨래 정리하기"` | — | 0 | R8; `$.seoul_cycle.months.3.nodes.m3_self.label` |
| B? | `"영수증과 빨래는 그대로 쌓였다. 정리하지 않은 지출도 그대로 남았다."` | — | 0 | R8; `$.decline_outcomes.the_room_ledger_waits.message` |
| B? | `"영수증과 빨래를 정리하는 밤"` | — | 0 | R8; `$.scene_bundles.m3_room_ledger.offer` |
| B? | `"영수증을 날짜순으로 정리하고 빨래를 돌렸다. 큰 문제는 풀리지 않았지만, 무엇부터 처리해야 할지는 분명해졌다."` | — | 0 | R8; `$.scene_bundles.m3_room_ledger.action_config.result_body` |
| D | `"영수증을 한쪽으로 모은 뒤 {name}은 수첩을 앞쪽의 결정 페이지로 넘겼다."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.candidate_copy.return.sangchul_ledger` |
| B? | `"옆자리의 통화가 상철에게 먼저 찾아갈 이유가 되었다."` | — | 0 | R8; `$.seoul_cycle.terminal_routes.m2_people_completed_cafe_to_m4_sangchul.result` |
| B? | `"오늘 저녁 · 통화"` | — | 0 | R8; `$.scene_bundles.father_first_call.message_body` |
| B? | `"오늘 좋은 기회를 주셔서 감사합니다. 합류하게 된다면 최선을 다하겠습니다."` | `locale/ui_zh-CN.json:1158`; `locale/ui_zh-TW.json:1158` | 2 | R8; `scenes/JobHuntMiniGame.gd::INTERVIEW_QUESTION_POOL[17].text` |
| D | `"오류표를 끝내면 입사 뒤 처음 맡은 월말 마감을 지킨다. 확인하지 못한 숫자를 어떻게 남길지까지 책임지는 동안 다른 줄은 내려놓아야 한다."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.candidate_copy.tradeoff.hanbit_month_close` |
| B? | `"오전 접수가 끝나면 더 지원할 수 없다."` | — | 0 | R8; `$.scene_bundles.m3_hanbit_application.decline` |
| D | `"오후 7시 회신 창과 오류표를 닫은 뒤 {name}은 수첩을 앞으로 당겨 결정 페이지를 펼쳤다."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.candidate_copy.return.hanbit_month_close` |
| B? | `"완벽주의 성향으로 업무 처리가 느릴 때가 있습니다."` | `locale/ui_zh-CN.json:1159`; `locale/ui_zh-TW.json:1159` | 2 | R8; `scenes/JobHuntMiniGame.gd::RESUME_QUESTION_POOL[13].text` |
| B? | `"운영지원 1차 면접을 14주차 목요일 오후 2시에 진행합니다."` | — | 0 | R8; `$.scene_bundles.m4_hanbit_interview.message_body` |
| B? | `"운영지원 계약직 채용 결과입니다. 월요일 출근 가능 여부를 오늘 오후 6시까지 회신해 주세요."` | — | 0 | R8; `$.scene_bundles.m5_hanbit_offer_message.message_body` |
| B? | `"운영지원 공고에 이력서를 첨부했다. 접수번호는 받았지만 연락이 온다는 보장은 없다."` | — | 0 | R8; `$.scene_bundles.m3_hanbit_application.action_config.result_body` |
| B? | `"원인을 찾아 인계표에 남김 · 선반은 다시 세지 못함"` | — | 0 | R8; `$.scene_bundles.m3_inventory_shift.action_config.outcomes.inventory_unconfirmed_handoff.recap` |
| B? | `"월세 낼 날이 다가오던 밤, 모르는 번호로 너무 쉬운 돈을 제안하는 문자가 온다."` | — | 0 | R8; `$.scene_bundles.first_temptation_boss.detail` |
| B? | `"이 분야의 전문가로서 팀을 이끄는 역할을 하고 싶습니다."` | `locale/ui_zh-CN.json:1160`; `locale/ui_zh-TW.json:1160` | 2 | R8; `scenes/JobHuntMiniGame.gd::INTERVIEW_QUESTION_POOL[9].text` |
| B? | `"이거 어제 샀는데 불량이에요."` | `locale/ui_zh-CN.json:1256`; `locale/ui_zh-TW.json:1256` | 2 | R8; `scenes/ArubaGame.gd::CUSTOMER_TYPES[29].text` |
| B? | `"이것저것 해 봤습니다. 들어가면 금방 배울 수 있습니다."` | `locale/ui_zh-CN.json:1161`; `locale/ui_zh-TW.json:1161` | 2 | R8; `scenes/JobHuntMiniGame.gd::INTERVIEW_QUESTION_POOL[34].text` |
| B? | `"이대 야식"` | `locale/ui_ja.json:3041`; `locale/ui_zh-CN.json:1257`; `locale/ui_zh-TW.json:1257` | 3 | R8; `scenes/ArubaGame.gd::DEL_ORDERS_DATA[6].name` |
| B? | `"이대로 끝내면 인계표는 비어 있다."` | — | 0 | R8; `$.scene_bundles.m3_inventory_shift.action_config.outcomes.inventory_trace_before_handoff.preview` |
| B? | `"이대로 넘기면 선반의 열한 개는 다시 확인하지 못한다."` | — | 0 | R8; `$.scene_bundles.m3_inventory_shift.action_config.outcomes.inventory_unconfirmed_handoff.preview` |
| B? | `"이대로 넘기면 숫자가 어긋난 지점은 찾지 못한다."` | — | 0 | R8; `$.scene_bundles.m3_inventory_shift.action_config.outcomes.inventory_untraced_handoff.preview` |
| B? | `"이력서에 6년 공백이 있네요. 설명해 주시겠어요?"` | `locale/ui_zh-CN.json:1162`; `locale/ui_zh-TW.json:1162` | 2 | R8; `scenes/JobHuntMiniGame.gd::INTERVIEW_QUESTION_POOL[0].q` |
| B? | `"이름을 나눈 뒤에도 이번 달에는 다시 말을 걸러 가지 않는다."` | — | 0 | R8; `$.scene_bundles.daeun_third_greeting.decline` |
| B? | `"이름을 묻지 못한 편의점에 다시 가기"` | — | 0 | R8; `$.scene_bundles.daeun_return_after_distance.offer` |
| B? | `"이름을 알고도 이번 달에는 그 편의점에 다시 가지 않았다."` | — | 0 | R8; `$.decline_outcomes.daeun_named_return_passes.message` |
| B? | `"이번 기수 수업은 다음 달 전에 끝난다."` | — | 0 | R8; `$.scene_bundles.m5_evening_spreadsheet_class.decline` |
| B? | `"이번 달 기초반은 마감되고 다음 접수까지 기다려야 한다."` | — | 0 | R8; `$.scene_bundles.m4_certificate_session.decline` |
| B? | `"이번 달 네 번의 일요일 중 한 번"` | — | 0 | R8; `$.scene_bundles.father_quiet_call.deadline` |
| B? | `"이번 달 늦은 밤"` | — | 0 | R8; `$.scene_bundles.hyunsu_first_meet.deadline` |
| B? | `"이번 달 마지막 모의면접 자리"` | — | 0 | R8; `$.scene_bundles.m2_youth_center_mock_interview.deadline` |
| B? | `"이번 달 마지막 모임은 민준 없이 끝난다."` | — | 0 | R8; `$.scene_bundles.m6_last_study_group.decline` |
| B? | `"이번 달 마지막 실전 문제풀이 모임"` | — | 0 | R8; `$.scene_bundles.m6_last_study_group.offer` |
| B? | `"이번 달 마지막 실전 문제풀이 모임은 민준 없이 끝났다. 틀린 문제의 풀이를 서로 비교할 기회도 지나갔다."` | — | 0 | R8; `$.decline_outcomes.study_group_takes_the_exam_without_minjun.message` |
| B? | `"이번 달 마지막 실전 문제풀이 모임을 마쳤다"` | — | 0 | R8; `$.scene_bundles.m6_last_study_group.action_config.result_title` |
| B? | `"이번 달 면접·지원·수업"` | — | 0 | R8; `$.seoul_cycle.months.4.nodes.m4_advancement.label` |
| B? | `"이번 달 목요일 밤 한 번"` | — | 0 | R8; `$.scene_bundles.m1_convenience_trial_shift.deadline` |
| B? | `"이번 달 무료 상담 접수가 끝난다."` | — | 0 | R8; `$.scene_bundles.m5_employment_contract_clinic.decline` |
| B? | `"이번 달 비 오는 저녁"` | — | 0 | R8; `$.scene_bundles.cafe_world_glimpse.deadline` |
| B? | `"이번 달 상담 시간이 끝나면 다음 접수 때까지 기다려야 한다."` | — | 0 | R8; `$.scene_bundles.m4_housing_welfare_consultation.decline` |
| B? | `"이번 달 안에 쉴 수 있는 일요일"` | — | 0 | R8; `$.scene_bundles.m1_phone_off_sunday.deadline; $.scene_bundles.m2_sleep_debt_sunday.deadline` |
| B? | `"이번 달 약속 지키기"` | — | 0 | R8; `$.seoul_cycle.months.6.nodes.m6_people.board_label` |
| B? | `"이번 달 여력"` | — | 0 | R8; `$.seoul_cycle.capacity.label` |
| B? | `"이번 달 잠들지 못한 밤"` | — | 0 | R8; `$.scene_bundles.sns_pressure_night.deadline` |
| B? | `"이번 달 저녁 한 번"` | — | 0 | R8; `$.scene_bundles.father_first_call.deadline` |
| B? | `"이번 달 지원 기간이 끝난다."` | — | 0 | R8; `$.scene_bundles.m1_mirae_application.decline` |
| B? | `"이번 달 지원 마감 전"` | — | 0 | R8; `$.scene_bundles.m2_seorin_application.deadline` |
| B? | `"이번 달 지켜야 할 약속에 연락하기"` | — | 0 | R8; `$.seoul_cycle.months.6.nodes.m6_people.label` |
| B? | `"이번 달 진로 준비"` | — | 0 | R8; `$.seoul_cycle.months.4.nodes.m4_advancement.board_label` |
| B? | `"이번 달 채용 공고는 게시판에서 내려간다."` | — | 0 | R8; `$.scene_bundles.m3_library_job_board.decline` |
| B? | `"이번 달 첫 금요일"` | — | 0 | R8; `$.scene_bundles.m1_mirae_application.deadline` |
| B? | `"이번 달 토요일 하나를 비워 씻고 먹고 오래 잔다."` | — | 0 | R8; `$.scene_bundles.m3_empty_saturday.detail` |
| B? | `"이번 달에는 강남역 거리를 직접 걷지 않는다."` | — | 0 | R8; `$.scene_bundles.m6_gangnam_receipt_walk.decline` |
| B? | `"이번 달에는 강남역 카페 앞에서 쓸 돈을 직접 정해 보지 않았다."` | — | 0 | R8; `$.decline_outcomes.gangnam_receipt_walk_passes.message` |
| B? | `"이번 달에는 고시원 밖 방값을 알아보러 부동산에 들어가지 않았다."` | — | 0 | R8; `$.decline_outcomes.the_warm_coffee_and_card_are_left_behind.message` |
| B? | `"이번 달에는 고시원 밖 방값을 직접 알아보지 않는다."` | — | 0 | R8; `$.scene_bundles.sangchul_world_meet.decline` |
| B? | `"이번 달에는 비가 갠 밤 신촌역 버스정류장에 가지 않았다."` | — | 0 | R8; `$.decline_outcomes.jiyeon_bus_route_passes.message` |
| B? | `"이번 달에는 아버지에게 다시 전화하지 않는다."` | — | 0 | R8; `$.scene_bundles.father_quiet_call.decline` |
| B? | `"이번 달에는 이름을 알고도 다시 인사하러 가지 않는다."` | — | 0 | R8; `$.scene_bundles.daeun_player_return.decline` |
| B? | `"이번 달에는 제한 시간을 두고 필기 문제를 풀어 보지 못한다."` | — | 0 | R8; `$.scene_bundles.m6_public_recruitment.decline` |
| B? | `"이번 달에도 편의점 야간 직원의 이름을 묻지 못했다."` | — | 0 | R8; `$.decline_outcomes.daeun_unnamed_return_passes.message` |
| B? | `"이번 달은 하루도 완전히 쉬지 못한 채 끝난다."` | — | 0 | R8; `$.scene_bundles.m5_last_empty_sunday.decline` |
| B? | `"이번 주 편의점 시프트"` | — | 0 | R8; `$.seoul_cycle.months.1.nodes.convenience.label; $.seoul_cycle.nodes.convenience.label` |
| B? | `"이번 주 하루 비우기"` | — | 0 | R8; `$.seoul_cycle.months.1.nodes.recovery.label; $.seoul_cycle.nodes.recovery.label` |
| B? | `"이번 채용 접수가 끝나면 같은 공고에는 지원할 수 없다."` | — | 0 | R8; `$.scene_bundles.m4_dodam_application.decline` |
| B? | `"이삿짐 보조 나흘"` | — | 0 | R8; `$.scene_bundles.m5_weekend_move_shift.offer` |
| B? | `"이삿짐 보조 나흘을 마쳤다"` | — | 0 | R8; `$.scene_bundles.m5_weekend_move_shift.action_config.result_title` |
| B? | `"이삿짐 보조 수당 56만원을 받았다."` | — | 0 | R8; `$.scene_bundles.m5_weekend_move_shift.action_config.result_body` |
| B? | `"이삿짐 보조"` | — | 0 | R8; `$.seoul_cycle.months.5.nodes.m5_livelihood.board_label` |
| B? | `"이삿짐 집결지"` | — | 0 | R8; `$.seoul_cycle.months.5.nodes.m5_livelihood.place` |
| B? | `"인계표 작성"` | — | 0 | R8; `$.scene_bundles.m3_inventory_shift.action_config.requirements[2].short` |
| B? | `"인계표"` | — | 0 | R8; `$.scene_bundles.m3_inventory_shift.action_config.requirements[2].station` |
| B? | `"인계표에 전산 12개, 선반 11개, 확인 시각과 지금까지 찾은 내용을 남겼다."` | — | 0 | R8; `$.scene_bundles.m3_inventory_shift.action_config.requirements[2].feedback` |
| B? | `"인계표에 차이를 적는다"` | — | 0 | R8; `$.scene_bundles.m3_inventory_shift.action_config.requirements[2].label` |
| B? | `"인력사무소 · 재고 창고"` | — | 0 | R8; `$.seoul_cycle.months.3.nodes.m3_livelihood.place` |
| B? | `"일단 들어가 봐야 알겠습니다."` | `locale/ui_zh-CN.json:1163`; `locale/ui_zh-TW.json:1163` | 2 | R8; `scenes/JobHuntMiniGame.gd::RESUME_QUESTION_POOL[19].text` |
| B? | `"일요일에 아버지에게 다시 전화하기"` | — | 0 | R8; `$.scene_bundles.father_quiet_call.offer` |
| B? | `"일요일에는 휴대폰을 끈다"` | — | 0 | R8; `$.scene_bundles.m1_phone_off_sunday.decision` |
| B? | `"일요일에도 쉬지 못해, 두 번째 달 첫 일정을 시작할 때 몸이 무거웠다."` | — | 0 | R8; `$.decline_outcomes.strain_carries_into_next_commitment.message` |
| B? | `"일자리와 다음 만남"` | — | 0 | R8; `$.months[3].title` |
| B? | `"입고·반품 기록을 대조한다"` | — | 0 | R8; `$.scene_bundles.m3_inventory_shift.action_config.requirements[1].label` |
| B? | `"입고·반품 기록을 대조해 한 개가 어긋난 지점을 찾는다."` | — | 0 | R8; `$.scene_bundles.m3_inventory_shift.action_config.requirements[1].detail` |
| B? | `"입고표와 반품 기록의 시각을 맞춰 보니, 전날 반품 보관함으로 옮긴 한 개가 전산표에는 아직 남아 있었다."` | — | 0 | R8; `$.scene_bundles.m3_inventory_shift.action_config.requirements[1].feedback` |
| B? | `"입사 후 3년, 5년 포부를 서술하시오."` | `locale/ui_zh-CN.json:1164`; `locale/ui_zh-TW.json:1164` | 2 | R8; `scenes/JobHuntMiniGame.gd::RESUME_QUESTION_POOL[15].q` |
| B? | `"자기소개서 고쳐 쓰기"` | — | 0 | R8; `$.seoul_cycle.months.1.nodes.resume.label; $.seoul_cycle.nodes.resume.label` |
| B? | `"자기소개서 고치기"` | — | 0 | R8; `$.seoul_cycle.months.1.nodes.resume.board_label; $.seoul_cycle.nodes.resume.board_label` |
| B? | `"자기소개서 네 문항 고쳐 쓰기"` | — | 0 | R8; `$.scene_bundles.m1_youth_center_resume_clinic.offer` |
| B? | `"자기소개서 네 문항을 고친다"` | — | 0 | R8; `$.scene_bundles.m1_youth_center_resume_clinic.decision` |
| B? | `"자기소개서를 다시 써 서린물산 지원하기"` | — | 0 | R8; `$.seoul_cycle.terminal_routes.m1_resume_completed_q0_to_m2_advancement_rewritten.label` |
| D | `"자정을 넘겨 방에 돌아온 {name}은 28만원 입금 내역을 확인하고 무거운 손으로 수첩의 결정 페이지를 펼쳤다."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.candidate_copy.return.urgent_paid_shift` |
| D | `"작업표를 보내면 지원 절차를 계속 밟을 수 있다. 제출은 면접이나 채용을 보장하지 않고 다른 일에 쓸 시간을 가져간다."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.candidate_copy.tradeoff.city_work_sample` |
| B? | `"잠들기 전, 잘된 사람들의 사진을 끝까지 들여다본다."` | — | 0 | R8; `$.scene_bundles.sns_pressure_night.detail` |
| B? | `"장소와 시간을 확인하고도 이번 달에는 만나지 않는다."` | — | 0 | R8; `$.scene_bundles.jaehyuk_plain_reunion_echo.decline` |
| B? | `"재고 회전율과 입출고표를 다루는 두 시간짜리 기초 수업을 듣는다."` | — | 0 | R8; `$.scene_bundles.m4_certificate_session.detail` |
| B? | `"재고조사 나흘째, 폐점 뒤. 마지막 선반은 전산에 12개, 눈앞에는 11개다. 교대까지 남은 시간에는 세 가지를 전부 끝내기 어렵다."` | — | 0 | R8; `$.scene_bundles.m3_inventory_shift.action_config.intro` |
| B? | `"재고조사 수당 36만원을 받았다."` | — | 0 | R8; `$.scene_bundles.m3_inventory_shift.action_config.result_body` |
| D | `"재혁 — 십 년 만에 다시 이어진 카카오톡과 포장마차에서 다시 나눈 대화."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.candidate_copy.evidence.jaehyuk_reply` |
| B? | `"재혁과 10년 만에 마주 앉기"` | — | 0 | R8; `$.scene_bundles.jaehyuk_plain_reunion_echo.offer` |
| D | `"재혁에게 먼저 쓰면 다시 만난 뒤의 첫 한 주를 서로 이야기하게 된다. 답장을 기다리고 말을 고르는 동안 서류와 장부에는 손대지 못한다."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.candidate_copy.tradeoff.jaehyuk_reply` |
| D | `"재혁의 답장이 잠시 멈춘 사이 {name}은 휴대폰을 수첩 옆에 놓고 결정 페이지를 펼쳤다. 대화는 아직 끝나지 않았다."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.candidate_copy.return.jaehyuk_reply` |
| B? | `"재혁이 보낸 포장마차 약속에 답하지 않았다. 이번 달에는 두 사람이 만나지 않았다."` | — | 0 | R8; `$.decline_outcomes.jaehyuk_reunion_date_passes.message` |
| B? | `"재확인·원인 추적·인계 기록을 모두 마침 · 교대 시각을 넘김"` | — | 0 | R8; `$.scene_bundles.m3_inventory_shift.action_config.overreach.recap` |
| B? | `"저기, 삼각김밥 어디 있어요?"` | `locale/ui_zh-CN.json:1258`; `locale/ui_zh-TW.json:1258` | 2 | R8; `scenes/ArubaGame.gd::CUSTOMER_TYPES[47].text` |
| B? | `"저기요, 계산이요."` | `locale/ui_zh-CN.json:1259`; `locale/ui_zh-TW.json:1259` | 2 | R8; `scenes/ArubaGame.gd::CUSTOMER_TYPES[1].text` |
| B? | `"저녁 전산 실무 집중반"` | — | 0 | R8; `$.scene_bundles.m5_evening_spreadsheet_class.offer` |
| B? | `"저녁 전산 실무 집중반을 마쳤다"` | — | 0 | R8; `$.scene_bundles.m5_evening_spreadsheet_class.action_config.result_title` |
| B? | `"저장해 둔 자기소개서를 열어 지원동기와 강점 등 네 문항의 답을 다시 쓴다."` | — | 0 | R8; `$.scene_bundles.m1_youth_center_resume_clinic.detail` |
| B? | `"저희 회사 지원동기가 무엇인가요?"` | `locale/ui_zh-CN.json:1166`; `locale/ui_zh-TW.json:1166` | 2 | R8; `scenes/JobHuntMiniGame.gd::INTERVIEW_QUESTION_POOL[4].q` |
| B? | `"전날 한 개를 반품 보관함으로 옮겼다는 기록을 찾았다. 인계표에는 그 기록과 전산 12개, 선반 11개의 차이를 적었다. 선반을 처음부터 다시 세지는 못했다."` | — | 0 | R8; `$.scene_bundles.m3_inventory_shift.action_config.outcomes.inventory_unconfirmed_handoff.finish` |
| B? | `"전산 12개, 선반 11개"` | — | 0 | R8; `$.scene_bundles.m3_inventory_shift.action_config.task_title` |
| B? | `"전산 12개와 선반 11개, 확인 시각을 적고 찾아낸 근거가 있으면 함께 남긴다."` | — | 0 | R8; `$.scene_bundles.m3_inventory_shift.action_config.requirements[2].detail` |
| B? | `"점장에게 물어봐야 한다고 설명"` | `locale/ui_zh-CN.json:1260`; `locale/ui_zh-TW.json:1260` | 2 | R8; `scenes/ArubaGame.gd::CUSTOMER_TYPES[32].text` |
| B? | `"점장이 교환 기록을 확인하고 성과수당 2천 원을 붙였다."` | `locale/ui_zh-CN.json:1261`; `locale/ui_zh-TW.json:1261` | 2 | R8; `scenes/ArubaGame.gd::CUSTOMER_TYPES[31].tip` |
| B? | `"점장이 빠른 응대 기록을 보고 성과수당 2천 원을 붙였다."` | `locale/ui_zh-CN.json:1262`; `locale/ui_zh-TW.json:1262` | 2 | R8; `scenes/ArubaGame.gd::CUSTOMER_TYPES[3].tip` |
| B? | `"점장이 사후 적립 기록을 보고 성과수당 천 원을 붙였다."` | `locale/ui_zh-CN.json:1263`; `locale/ui_zh-TW.json:1263` | 2 | R8; `scenes/ArubaGame.gd::CUSTOMER_TYPES[43].tip` |
| B? | `"정규직이 아니어서 도움이 될 만한 경험은 없습니다."` | `locale/ui_zh-CN.json:1167`; `locale/ui_zh-TW.json:1167` | 2 | R8; `scenes/JobHuntMiniGame.gd::INTERVIEW_QUESTION_POOL[35].text` |
| B? | `"정해진 면접에 참석하지 않으면 이번 한빛유통 전형은 끝난다."` | — | 0 | R8; `$.scene_bundles.m4_hanbit_interview.decline` |
| B? | `"제 몫을 먼저 끝낸 뒤 바쁜 사람을 도왔습니다."` | `locale/ui_zh-CN.json:1168`; `locale/ui_zh-TW.json:1168` | 2 | R8; `scenes/JobHuntMiniGame.gd::INTERVIEW_QUESTION_POOL[38].text` |
| B? | `"제 일만 하면 된다고 생각했습니다."` | `locale/ui_zh-CN.json:1169`; `locale/ui_zh-TW.json:1169` | 2 | R8; `scenes/JobHuntMiniGame.gd::INTERVIEW_QUESTION_POOL[39].text` |
| B? | `"주거 상담에서 숫자를 다시 적었다"` | — | 0 | R8; `$.scene_bundles.m4_housing_welfare_consultation.action_config.result_title` |
| B? | `"주거복지 상담사"` | — | 0 | R8; `autoloads/ImageRegistry.gd::PERSON_INFO.housing_counselor` |
| B? | `"주민센터 주거복지 상담 창구에서 보증금, 월세, 관리비, 중개비, 이사비를 차례로 적었다. 방을 보기 전에 무엇을 먼저 지킬지 정해야 한다는 사실이 분명해졌다."` | — | 0 | R8; `$.scene_bundles.m4_housing_welfare_consultation.action_config.result_body` |
| B? | `"주민센터 주거복지 상담 창구에서 보증금·월세·관리비·이사비를 함께 계산한다."` | — | 0 | R8; `$.scene_bundles.m4_housing_welfare_consultation.detail` |
| B? | `"주민센터 주거복지 창구"` | — | 0 | R8; `$.seoul_cycle.months.4.nodes.m4_self.place` |
| B? | `"주민센터에서 이사 비용 상담받기"` | — | 0 | R8; `$.scene_bundles.m4_housing_welfare_consultation.offer` |
| B? | `"주민센터의 이번 달 주거복지 상담 시간이 끝났다. 보증금과 월세 계산은 다음 접수 때 다시 물어봐야 한다."` | — | 0 | R8; `$.decline_outcomes.housing_consultation_window_closes.message` |
| B? | `"준비해 둔 문장으로 서린물산 지원하기"` | — | 0 | R8; `$.seoul_cycle.terminal_routes.m1_resume_completed_q3_to_m2_advancement_ready.label` |
| B? | `"준비해 둔 이력서를 첨부해 물류 운영지원 자리에 지원한다."` | — | 0 | R8; `$.scene_bundles.m3_hanbit_application.detail` |
| B? | `"준비해 둔 이력서를 첨부해 이번 주 금요일 마감 전에 지원한다."` | — | 0 | R8; `$.scene_bundles.m1_mirae_application.detail` |
| B? | `"지갑에 넣어 둔 명함의 번호로 먼저 전화해, 같은 부동산에서 믹스커피 한 잔을 더 마신다."` | — | 0 | R8; `$.scene_bundles.sangchul_second_coffee.detail` |
| D | `"지금 누우면 씻고 물을 마신 뒤 쉴 수 있다. 돈도 서류도 사람에게 보낼 답도 오늘은 끝내지 못한다."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.candidate_copy.tradeoff.body_rest` |
| D | `"지금 쓸 수 있는 잔액은 0원이었고, 밀린 비용 {arrears}에 이번 달 고정비 {fixed_expense}이 더 기다리고 있었다."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.after_bills_copy.arrears` |
| B? | `"지난달 실제로 하루를 쉬어 둔 덕분에 영수증과 빨래를 밤새 붙들지 않고 차례대로 정리한다."` | — | 0 | R8; `$.seoul_cycle.terminal_routes.m2_self_completed_to_m3_self_recovered.detail` |
| B? | `"지난달 약속을 잡지 못한 채 남은 연락처와 보낼 말을 정리한다. 만났다고 기록하지 않는다."` | — | 0 | R8; `$.seoul_cycle.terminal_routes.m2_people_expired_to_m3_contact_fail_forward.detail` |
| B? | `"지난번 이름을 나눈 야간 직원에게, 이번에는 내가 먼저 인사하러 간다."` | — | 0 | R8; `$.scene_bundles.daeun_player_return.detail` |
| B? | `"지난번에는 고맙다는 인사만 하고 나왔다. 같은 편의점에 다시 가 이번에는 내 이름을 말한다."` | — | 0 | R8; `$.scene_bundles.daeun_return_after_distance.detail` |
| B? | `"지원 알림과 돈 계산을 멈추고 하루 동안 푹 잔다."` | — | 0 | R8; `$.scene_bundles.m1_phone_off_sunday.detail` |
| B? | `"지원동기를 서술하시오."` | `locale/ui_zh-CN.json:1170`; `locale/ui_zh-TW.json:1170` | 2 | R8; `scenes/JobHuntMiniGame.gd::RESUME_QUESTION_POOL[0].q` |
| B? | `"지원서 검토를 위해 6월 26일 금요일 오후 6시까지 시설 점검 작업표 견본을 제출해 주세요."` | — | 0 | R8; `$.scene_bundles.m6_city_service_response.message_body` |
| B? | `"지원해 주셔서 감사합니다. 검토 결과 이번 상담 운영직 전형에는 함께하기 어렵게 되었습니다."` | — | 0 | R8; `$.scene_bundles.m6_dodam_response.message_body` |
| D | `"지출 장부를 맞추면 자기 돈이 어디로 갔는지 확인한다. 상철에게 기대지 않는 대신 사람들에게 연락하거나 지원 서류를 보내는 일은 오늘 미룬다."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.candidate_copy.tradeoff.sangchul_ledger` |
| B? | `"직무 요건과 나의 경험을 연결하는 것이 핵심."` | `locale/ui_zh-CN.json:1172`; `locale/ui_zh-TW.json:1172` | 2 | R8; `scenes/JobHuntMiniGame.gd::RESUME_QUESTION_POOL[36].hint` |
| B? | `"진열대까지 함께 가서 안내한다"` | `locale/ui_zh-CN.json:1264`; `locale/ui_zh-TW.json:1264` | 2 | R8; `scenes/ArubaGame.gd::CUSTOMER_TYPES[48].text` |
| B? | `"집 근처 편의점"` | — | 0 | R8; `$.seoul_cycle.months.1.nodes.convenience.place; $.seoul_cycle.nodes.convenience.place` |
| B? | `"집 근처 편의점의 하루짜리 심야 대타를 맡는다."` | — | 0 | R8; `$.scene_bundles.m1_convenience_trial_shift.detail` |
| B? | `"짧게 끊었던 첫 통화를 기억하고, 이번 일요일에는 먼저 전화해 조금 더 오래 듣는다."` | — | 0 | R8; `$.seoul_cycle.terminal_routes.m1_father_completed_call_ended_quickly_to_m3_quiet_call.detail` |
| B? | `"짧게 끊은 통화를 다시 잇는 일요일"` | — | 0 | R8; `$.seoul_cycle.terminal_routes.m1_father_completed_call_ended_quickly_to_m3_quiet_call.label` |
| B? | `"짧게 끝낸 첫 통화가 그대로 마지막 통화가 되지는 않았다."` | — | 0 | R8; `$.seoul_cycle.terminal_routes.m1_father_completed_call_ended_quickly_to_m3_quiet_call.result` |
| B? | `"찾아갔다."` | `locale/ui_zh-CN.json:1266`; `locale/ui_zh-TW.json:1266` | 2 | R8; `scenes/ArubaGame.gd::CUSTOMER_TYPES[51].tip` |
| B? | `"찾아보다가 관심이 생겼습니다. 좋은 회사라고 생각합니다."` | `locale/ui_zh-CN.json:1173`; `locale/ui_zh-TW.json:1173` | 2 | R8; `scenes/JobHuntMiniGame.gd::INTERVIEW_QUESTION_POOL[6].text` |
| D | `"첫 주가 시작된다."` | `locale/ui_ja.json:3092`; `locale/ui_zh-CN.json:2387`; `locale/ui_zh-TW.json:2387` | 3 | R8/R11; `scenes/OpeningCinematic.gd::BEATS[2].body` |
| B? | `"첫 지원 때 정리한 문장을 다시 풀어 쓰지 않고 서린물산 계약직 지원서에 맞춘다."` | — | 0 | R8; `$.seoul_cycle.terminal_routes.m1_resume_completed_q3_to_m2_advancement_ready.detail` |
| B? | `"첫 지원서에 남은 거친 문장을 고친 뒤 서린물산 계약직 지원서에 옮긴다."` | — | 0 | R8; `$.seoul_cycle.terminal_routes.m1_resume_completed_q1_to_m2_advancement_revised.detail` |
| B? | `"첫 지원서의 문장을 거의 처음부터 다시 써 서린물산 계약직 공고에 맞춘다."` | — | 0 | R8; `$.seoul_cycle.terminal_routes.m1_resume_completed_q0_to_m2_advancement_rewritten.detail` |
| B? | `"첫 통화 뒤 몇 주가 지난 일요일, 이번에는 내가 먼저 전화해 밥과 날씨, 공장 일 이야기를 듣는다."` | — | 0 | R8; `$.scene_bundles.father_quiet_call.detail` |
| B? | `"첫 통화에서 되물었던 안부를 기억하고 이번에는 내가 먼저 다시 전화한다."` | — | 0 | R8; `$.seoul_cycle.terminal_routes.m1_father_completed_wellbeing_to_m3_quiet_call.detail` |
| B? | `"첫 통화의 질문을 잊지 않고 다음 통화로 이어 갔다."` | — | 0 | R8; `$.seoul_cycle.terminal_routes.m1_father_completed_wellbeing_to_m3_quiet_call.result` |
| B? | `"청년센터 · 노트북"` | — | 0 | R8; `$.seoul_cycle.months.2.nodes.m2_advancement.place` |
| B? | `"청년센터 모의면접"` | — | 0 | R8; `$.scene_bundles.m2_youth_center_mock_interview.offer` |
| B? | `"청년센터 물류관리 기초 수업"` | — | 0 | R8; `$.scene_bundles.m4_certificate_session.offer` |
| B? | `"청년센터 물류관리 기초반이 끝났다. 이번 달에는 수업을 듣지 않았다."` | — | 0 | R8; `$.decline_outcomes.certificate_window_moves_on.message` |
| B? | `"청년센터 수정 기한을 넘긴 뒤 빈 문서에서 다시 시작해 서린물산 계약직 공고에 지원한다."` | — | 0 | R8; `$.seoul_cycle.terminal_routes.m1_resume_expired_to_m2_advancement_rebuilt.detail` |
| B? | `"청년센터"` | — | 0 | R8; `$.seoul_cycle.months.1.nodes.resume.place; $.seoul_cycle.nodes.resume.place` |
| B? | `"청년센터에서 다듬은 문장을 서린물산 계약직 공고에 맞춰 다시 확인한다."` | — | 0 | R8; `$.seoul_cycle.terminal_routes.m1_resume_completed_q2_to_m2_advancement_polished.detail` |
| B? | `"청년센터의 두 시간짜리 물류관리 기초 수업을 마쳤다. 자격증을 딴 것은 아니다."` | — | 0 | R8; `$.scene_bundles.m4_certificate_session.action_config.result_body` |
| B? | `"총각, 오늘 대타예요? 나는 매일 이 시간에 오는데."` | `locale/ui_zh-CN.json:1268`; `locale/ui_zh-TW.json:1268` | 2 | R8; `scenes/ArubaGame.gd::CUSTOMER_TYPES[15].text` |
| B? | `"최근 해 온 일 가운데 이 직무에 도움이 되는 경험이 있나요?"` | `locale/ui_zh-CN.json:1175`; `locale/ui_zh-TW.json:1175` | 2 | R8; `scenes/JobHuntMiniGame.gd::INTERVIEW_QUESTION_POOL[32].q` |
| B? | `"최씨 아저씨"` | — | 0 | R8; `$.scene_bundles.father_health_signal.message_sender` |
| B? | `"추가 야간 시프트. 새벽 3시, 손님이 없었다. 그 시간이 가장 길었다."` | — | 0 | R8; `scenes/MainGame.gd::SIDE_JOB_VIGNETTES_CONVENIENCE[0].t` |
| B? | `"추상적인 단어보다 구체적인 사례가 설득력 있다."` | `locale/ui_zh-CN.json:1176`; `locale/ui_zh-TW.json:1176` | 2 | R8; `scenes/JobHuntMiniGame.gd::RESUME_QUESTION_POOL[6].hint` |
| B? | `"취한 손님"` | `locale/ui_zh-CN.json:1270`; `locale/ui_zh-TW.json:1270` | 2 | R8; `scenes/ArubaGame.gd::CUSTOMER_TYPES[20].name` |
| B? | `"친절하게 안내한다"` | `locale/ui_zh-CN.json:1271`; `locale/ui_zh-TW.json:1271` | 2 | R8; `scenes/ArubaGame.gd::CUSTOMER_TYPES[22].text` |
| B? | `"카카오톡 답장 뒤 재혁이 보낸 장소와 시간을 확인하고 신촌 포장마차에서 실제로 만난다."` | — | 0 | R8; `$.scene_bundles.jaehyuk_plain_reunion_echo.detail` |
| B? | `"카페 옆자리 남자의 통화"` | — | 0 | R8; `$.scene_bundles.cafe_world_glimpse.offer` |
| B? | `"카페 옆자리에서 들은 재개발 이야기를 따라 신촌 부동산에서 보증금과 월세를 묻는다."` | — | 0 | R8; `$.seoul_cycle.terminal_routes.m2_people_completed_cafe_to_m4_sangchul.detail` |
| B? | `"카페에서 들은 방값을 직접 물어보기"` | — | 0 | R8; `$.seoul_cycle.terminal_routes.m2_people_completed_cafe_to_m4_sangchul.label` |
| D | `"카페의 남자"` | `locale/ui_ja.json:3094`; `locale/ui_zh-CN.json:2389`; `locale/ui_zh-TW.json:2389` | 3 | R8/R11; `autoloads/ImageRegistry.gd::PERSON_INFO.cafe_investor` |
| B? | `"커피 한 잔을 시키고, 옆자리 정장 남자가 재개발 입주권을 말하는 통화를 듣는다."` | — | 0 | R8; `$.scene_bundles.cafe_world_glimpse.detail` |
| B? | `"큰 실패는 없었지만 작은 실수에서 배웠습니다."` | `locale/ui_zh-CN.json:1178`; `locale/ui_zh-TW.json:1178` | 2 | R8; `scenes/JobHuntMiniGame.gd::RESUME_QUESTION_POOL[28].text` |
| B? | `"클록이 차면 장면이 열린다"` | — | 0 | R8; `scenes/TutorialOverlay.gd::core_loop_v2[2].title` |
| B? | `"택배 손님"` | `locale/ui_zh-CN.json:1272`; `locale/ui_zh-TW.json:1272` | 2 | R8; `scenes/ArubaGame.gd::CUSTOMER_TYPES[34].name` |
| B? | `"택배 여기 맡겼는데요."` | `locale/ui_zh-CN.json:1273`; `locale/ui_zh-TW.json:1273` | 2 | R8; `scenes/ArubaGame.gd::CUSTOMER_TYPES[35].text` |
| B? | `"택배 터미널"` | — | 0 | R8; `$.seoul_cycle.months.6.nodes.m6_livelihood.place` |
| B? | `"토요일에도 쉬지 못해, 다음 사람을 만날 때까지 피로가 남았다."` | — | 0 | R8; `$.decline_outcomes.strain_carries_into_romance_entry.message` |
| B? | `"토요일을 비워 두었다"` | — | 0 | R8; `$.scene_bundles.m3_empty_saturday.action_config.result_title` |
| D | `"통장 50만원. 월세 65만원짜리 고시원."` | `locale/ui_ja.json:3093`; `locale/ui_zh-CN.json:2388`; `locale/ui_zh-TW.json:2388` | 3 | R8/R11; `scenes/OpeningCinematic.gd::BEATS[1].body` |
| D | `"통화를 끊은 뒤 {name}은 월요일 저녁을 적은 페이지를 한 번 확인하고, 수첩의 결정 페이지로 돌아갔다."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.candidate_copy.return.father_call` |
| B? | `"특별한 강점은 없지만 열심히 하겠습니다."` | `locale/ui_zh-CN.json:1179`; `locale/ui_zh-TW.json:1179` | 2 | R8; `scenes/JobHuntMiniGame.gd::RESUME_QUESTION_POOL[9].text` |
| B? | `"특별한 이유는 없고 그냥 쉬었습니다."` | `locale/ui_zh-CN.json:1180`; `locale/ui_zh-TW.json:1180` | 2 | R8; `scenes/JobHuntMiniGame.gd::INTERVIEW_QUESTION_POOL[3].text` |
| B? | `"팀 내 갈등 상황에서 어떻게 대처하나요?"` | `locale/ui_zh-CN.json:1181`; `locale/ui_zh-TW.json:1181` | 2 | R8; `scenes/JobHuntMiniGame.gd::RESUME_QUESTION_POOL[20].q` |
| B? | `"편의점 근무"` | — | 0 | R8; `$.seoul_cycle.months.1.nodes.convenience.board_label; $.seoul_cycle.nodes.convenience.board_label` |
| B? | `"편의점 영수증이 책상 위에 놓여 있었다. 이번 주도 번 돈을 세고 모르는 번호의 문자를 열었다."` | — | 0 | R8; `$.seoul_cycle.months.1.nodes.convenience.echo; $.seoul_cycle.nodes.convenience.echo` |
| D | `"편의점에 가면 이번에는 {name}이 먼저 다은의 안부를 묻는다. 방을 나서는 순간 서류 마감과 다른 연락은 놓친다."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.candidate_copy.tradeoff.daeun_checkin` |
| D | `"편의점에서 돌아온 {name}은 가방을 내려놓고 수첩의 결정 페이지를 펼쳤다. 다은에게 먼저 물었던 한 문장을 그 아래에 적었다."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.candidate_copy.return.daeun_checkin` |
| B? | `"폐점 뒤 나흘 연속으로 창고와 매대의 수량을 다시 센다."` | — | 0 | R8; `$.scene_bundles.m3_inventory_shift.detail` |
| B? | `"포인트 손님"` | `locale/ui_zh-CN.json:1278`; `locale/ui_zh-TW.json:1278` | 2 | R8; `scenes/ArubaGame.gd::CUSTOMER_TYPES[40].name` |
| B? | `"포인트 카드요! 이거 적립됐어요?"` | `locale/ui_zh-CN.json:1279`; `locale/ui_zh-TW.json:1279` | 2 | R8; `scenes/ArubaGame.gd::CUSTOMER_TYPES[41].text` |
| B? | `"하루 동안 다른 일정을 잡지 않았다."` | — | 0 | R8; `$.scene_bundles.m5_last_empty_sunday.action_config.result_body` |
| B? | `"하루 쉬기"` | — | 0 | R8; `$.seoul_cycle.months.1.nodes.recovery.board_label; $.seoul_cycle.nodes.recovery.board_label` |
| B? | `"하루 온전히 비우기"` | — | 0 | R8; `$.seoul_cycle.months.6.nodes.m6_self.board_label` |
| B? | `"하루를 비워 두었다"` | — | 0 | R8; `$.scene_bundles.m5_last_empty_sunday.action_config.result_title` |
| B? | `"하루를 아무에게도 주지 않기"` | — | 0 | R8; `$.seoul_cycle.months.6.nodes.m6_self.label` |
| B? | `"하루를 아무에게도 주지 않았다"` | — | 0 | R8; `$.scene_bundles.m6_no_plans_day.action_config.result_title` |
| B? | `"한 달에 네 번 쓸 수 있는 여력"` | — | 0 | R8; `scenes/TutorialOverlay.gd::core_loop_v2[0].title` |
| B? | `"한 번 푹 쉰 뒤 방의 밀린 일을 정리하기"` | — | 0 | R8; `$.seoul_cycle.terminal_routes.m2_self_completed_to_m3_self_recovered.label` |
| B? | `"한 일의 진행이 끝까지 차면 편의점 근무, 문서 작성, 통화 같은\n[b]실제 수행 장면[/b]이 열립니다. 대화의 성공을 숫자로 판정하지는 않습니다.\n\n방향키로 이동하고, 확인 버튼으로 고르며, 확정 전에는 취소 버튼으로 돌아갑니다.\n민준이 모르는 만남과 위기는 그 주가 왔을 때 따로 찾아옵니다."` | — | 0 | R8; `scenes/TutorialOverlay.gd::core_loop_v2[2].body` |
| D | `"한빛유통 — 물류센터 운영지원 계약직으로 입사한 뒤 처음 맡은 월말 마감과 아직 비어 있는 오류표."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.candidate_copy.evidence.hanbit_month_close` |
| B? | `"한빛유통 물류센터 운영지원 계약직"` | — | 0 | R8; `event::v2_hanbit_offer_message.choices[0].grant_job_display` |
| B? | `"한빛유통 운영지원 1차 면접"` | — | 0 | R8; `$.scene_bundles.m4_hanbit_interview.offer` |
| B? | `"한빛유통 운영지원 공고"` | — | 0 | R8; `$.scene_bundles.m3_hanbit_application.offer` |
| B? | `"한빛유통 운영지원 지원 마감일이 지났다. 지원서를 보내지 않았다."` | — | 0 | R8; `$.decline_outcomes.hanbit_posting_expires.message` |
| B? | `"한빛유통 지원"` | — | 0 | R8; `$.seoul_cycle.months.3.nodes.m3_advancement.board_label` |
| B? | `"한빛유통 지원서 보내기"` | — | 0 | R8; `$.seoul_cycle.months.3.nodes.m3_advancement.label` |
| B? | `"한빛유통 지원서를 보냈다"` | — | 0 | R8; `$.scene_bundles.m3_hanbit_application.action_config.result_title` |
| B? | `"한빛유통 채용팀"` | — | 0 | R8; `$.scene_bundles.m4_hanbit_interview.message_sender; $.scene_bundles.m5_hanbit_offer_message.message_sender` |
| B? | `"할증이 붙은 배달 기회는 지나간다."` | — | 0 | R8; `$.scene_bundles.m2_rain_delivery_shift.decline` |
| B? | `"현수가 먼저 제안한 공부 약속"` | — | 0 | R8; `$.scene_bundles.hyunsu_study_followup.offer` |
| B? | `"현수가 먼저 제안한 다음 공부 시간"` | — | 0 | R8; `$.seoul_cycle.terminal_routes.m2_people_completed_hyunsu_to_m3_followup.label` |
| B? | `"현수가 이번 달 공부 일정을 정하기 전"` | — | 0 | R8; `$.scene_bundles.hyunsu_player_reachout.deadline` |
| B? | `"현수는 혼자 공부한다. 함께 공부하자는 말은 나오지 않는다."` | — | 0 | R8; `$.scene_bundles.hyunsu_player_reachout.decline` |
| B? | `"현수에게 먼저 보내는 메시지"` | — | 0 | R8; `$.scene_bundles.hyunsu_player_reachout.offer` |
| B? | `"현수의 제안을 받지 않아 둘은 다시 각자 공부한다."` | — | 0 | R8; `$.scene_bundles.hyunsu_study_followup.decline` |
| B? | `"현수의 제안을 받지 않았다. 공용 주방의 빈 탁자는 다시 혼자 쓰는 자리가 됐다."` | — | 0 | R8; `$.decline_outcomes.hyunsu_does_not_confirm_the_next_study_hour.message` |
| D | `"현재 잔액 {cash}에서 이번 달 고정비 {fixed_expense}을 빼면 {after_bills}이 남았다. 들어올 예정인 급여는 아직 더하지 않았다."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.after_bills_copy.covered` |
| D | `"현재 잔액 {cash}으로는 이번 달 고정비 {fixed_expense}에 {after_bills}이 모자랐다. 들어올 예정인 급여는 아직 잔액이 아니었다."` | — | 0 | R8/R11; `$.scene_bundles.demo_collision.first_bill_finale.after_bills_copy.short` |
| B? | `"혈압과 혈액 검사를 받고 결과표를 수첩에 끼웠다. 검진이 몸을 낫게 하지는 않았지만, 오후 일을 잡지 않고 쉬었다."` | — | 0 | R8; `$.scene_bundles.m4_health_check_day.action_config.result_body` |
| B? | `"형, 다음 주 토요일 시험인데 아직 헷갈리는 문제가 하나 있어요. 지금 잠깐 괜찮아요?"` | — | 0 | R8; `$.scene_bundles.hyunsu_exam_eve.message_body` |
| B? | `"홍대 치킨"` | `locale/ui_ja.json:3042`; `locale/ui_zh-CN.json:1281`; `locale/ui_zh-TW.json:1281` | 3 | R8; `scenes/ArubaGame.gd::DEL_ORDERS_DATA[0].name` |
| B? | `"화를 내는 손님"` | `locale/ui_zh-CN.json:1282`; `locale/ui_zh-TW.json:1282` | 2 | R8; `scenes/ArubaGame.gd::CUSTOMER_TYPES[6].name` |
| B? | `"화면을 끈 뒤에도 남들과 비교하는 생각은 계속된다."` | — | 0 | R8; `$.scene_bundles.sns_pressure_night.decline` |
| B? | `"휘어진 자전거 대신 버스를 타고 돌아갈 시간을 비워 둔다."` | — | 0 | R8; `$.scene_bundles.jiyeon_bus_stop_reunion.detail` |
| B? | `"휴대폰 · 다시 만날 장소"` | — | 0 | R8; `$.seoul_cycle.months.5.nodes.m5_people.place` |
| B? | `"휴대폰 · 서울 카페"` | — | 0 | R8; `$.seoul_cycle.months.2.nodes.m2_people.place` |
| B? | `"휴대폰 · 서울의 약속 장소"` | — | 0 | R8; `$.seoul_cycle.months.3.nodes.m3_people.place; $.seoul_cycle.months.4.nodes.m4_people.place` |
| B? | `"휴대폰 · 약속 장소"` | — | 0 | R8; `$.seoul_cycle.months.6.nodes.m6_people.place` |
| B? | `"휴대폰 알람을 끄고 구직 공고도 보지 않은 채, 밀린 잠과 식사를 챙기도록 하루를 비워 둔다."` | — | 0 | R8; `$.scene_bundles.m5_last_empty_sunday.detail` |
| B? | `"휴대폰을 꺼 둔 일요일에는 한 번 푹 잤다. 다시 화면을 켜도 월세 이체일까지 남은 날은 늘어나지 않았다."` | — | 0 | R8; `$.episode_plan.primary_echo.m1_phone_off_sunday.copy` |
| B? | `"휴대폰을 끄는 일요일"` | — | 0 | R8; `$.scene_bundles.m1_phone_off_sunday.offer` |

</details>

### QA 및 CI

<details>
<summary>99 항목</summary>

| 분류 | 함수·키 | 파일:줄 | 줄 수 | 근거·등록 |
| --- | --- | --- | ---: | --- |
| C | `ci.yml` | `.github/workflows/ci.yml:1–100` | 100 | R12: CI 유지; `직접 등록 미관측` |
| C | `CommunicationPhoneCheck.gd` | `tools/CommunicationPhoneCheck.gd:1–567` | 567 | R12: CI 유지; `audit.sh:771` |
| C | `CommunicationPhoneCheck.gd.uid` | `tools/CommunicationPhoneCheck.gd.uid:1` | 1 | R12: CI 유지; `audit.sh:771` |
| C | `CommunicationPhoneCheck.tscn` | `tools/CommunicationPhoneCheck.tscn:1–6` | 6 | R12: CI 유지; `audit.sh:771` |
| C | `CoreLoopV2BCheck.gd` | `tools/CoreLoopV2BCheck.gd:1–3055` | 3055 | R12: CI 유지; `audit.sh:579` |
| C | `CoreLoopV2BCheck.gd.uid` | `tools/CoreLoopV2BCheck.gd.uid:1` | 1 | R12: CI 유지; `audit.sh:579` |
| C | `CoreLoopV2BCheck.tscn` | `tools/CoreLoopV2BCheck.tscn:1–6` | 6 | R12: CI 유지; `audit.sh:579` |
| C | `CoreLoopV2CCheck.gd` | `tools/CoreLoopV2CCheck.gd:1–1715` | 1715 | R12: CI 유지; `audit.sh:598` |
| C | `CoreLoopV2CCheck.gd.uid` | `tools/CoreLoopV2CCheck.gd.uid:1` | 1 | R12: CI 유지; `audit.sh:598` |
| C | `CoreLoopV2CCheck.tscn` | `tools/CoreLoopV2CCheck.tscn:1–6` | 6 | R12: CI 유지; `audit.sh:598` |
| C | `CoreLoopV2Check.gd` | `tools/CoreLoopV2Check.gd:1–2702` | 2702 | R12: CI 유지; `audit.sh:560` |
| C | `CoreLoopV2Check.gd.uid` | `tools/CoreLoopV2Check.gd.uid:1` | 1 | R12: CI 유지; `audit.sh:560` |
| C | `CoreLoopV2Check.tscn` | `tools/CoreLoopV2Check.tscn:1–6` | 6 | R12: CI 유지; `audit.sh:560` |
| C | `CoreLoopV2CycleBalanceCheck.gd` | `tools/CoreLoopV2CycleBalanceCheck.gd:1–1715` | 1715 | R12: CI 유지; `audit.sh:673` |
| C | `CoreLoopV2CycleBalanceCheck.gd.uid` | `tools/CoreLoopV2CycleBalanceCheck.gd.uid:1` | 1 | R12: CI 유지; `audit.sh:673` |
| C | `CoreLoopV2CycleBalanceCheck.tscn` | `tools/CoreLoopV2CycleBalanceCheck.tscn:1–6` | 6 | R12: CI 유지; `audit.sh:673` |
| C | `CoreLoopV2CycleCheck.gd` | `tools/CoreLoopV2CycleCheck.gd:1–15470` | 15470 | R12: CI 유지; `audit.sh:654` |
| C | `CoreLoopV2CycleCheck.gd.uid` | `tools/CoreLoopV2CycleCheck.gd.uid:1` | 1 | R12: CI 유지; `audit.sh:654` |
| C | `CoreLoopV2CycleCheck.tscn` | `tools/CoreLoopV2CycleCheck.tscn:1–6` | 6 | R12: CI 유지; `audit.sh:654` |
| C | `CoreLoopV2DCheck.gd` | `tools/CoreLoopV2DCheck.gd:1–1856` | 1856 | R12: CI 유지; `audit.sh:617` |
| C | `CoreLoopV2DCheck.gd.uid` | `tools/CoreLoopV2DCheck.gd.uid:1` | 1 | R12: CI 유지; `audit.sh:617` |
| C | `CoreLoopV2DCheck.tscn` | `tools/CoreLoopV2DCheck.tscn:1–6` | 6 | R12: CI 유지; `audit.sh:617` |
| C | `CoreLoopV2ECheck.gd` | `tools/CoreLoopV2ECheck.gd:1–4552` | 4552 | R12: CI 유지; `audit.sh:636` |
| C | `CoreLoopV2ECheck.gd.uid` | `tools/CoreLoopV2ECheck.gd.uid:1` | 1 | R12: CI 유지; `audit.sh:636` |
| C | `CoreLoopV2ECheck.tscn` | `tools/CoreLoopV2ECheck.tscn:1–6` | 6 | R12: CI 유지; `audit.sh:636` |
| C | `CoreLoopV2FirstEntryCheck.gd` | `tools/CoreLoopV2FirstEntryCheck.gd:1–2428` | 2428 | R12: CI 유지; `audit.sh:693` |
| C | `CoreLoopV2FirstEntryCheck.gd.uid` | `tools/CoreLoopV2FirstEntryCheck.gd.uid:1` | 1 | R12: CI 유지; `audit.sh:693` |
| C | `CoreLoopV2FirstEntryCheck.tscn` | `tools/CoreLoopV2FirstEntryCheck.tscn:1–6` | 6 | R12: CI 유지; `audit.sh:693` |
| C | `CoreLoopV2HandoffCheck.gd` | `tools/CoreLoopV2HandoffCheck.gd:1–2140` | 2140 | R12: CI 유지; `audit.sh:713` |
| C | `CoreLoopV2HandoffCheck.gd.uid` | `tools/CoreLoopV2HandoffCheck.gd.uid:1` | 1 | R12: CI 유지; `audit.sh:713` |
| C | `CoreLoopV2HandoffCheck.tscn` | `tools/CoreLoopV2HandoffCheck.tscn:1–6` | 6 | R12: CI 유지; `audit.sh:713` |
| C | `DemoBuildCheck.gd` | `tools/DemoBuildCheck.gd:1–756` | 756 | R12: CI 유지; `audit.sh:1444` |
| C | `DemoBuildCheck.gd.uid` | `tools/DemoBuildCheck.gd.uid:1` | 1 | R12: CI 유지; `audit.sh:1444` |
| C | `DemoBuildCheck.tscn` | `tools/DemoBuildCheck.tscn:1–6` | 6 | R12: CI 유지; `audit.sh:1444` |
| C | `GalleryReplaySnapshotCheck.gd` | `tools/GalleryReplaySnapshotCheck.gd:1–718` | 718 | R12: CI 유지; `audit.sh:1077` |
| C | `GalleryReplaySnapshotCheck.gd.uid` | `tools/GalleryReplaySnapshotCheck.gd.uid:1` | 1 | R12: CI 유지; `audit.sh:1077` |
| C | `GalleryReplaySnapshotCheck.tscn` | `tools/GalleryReplaySnapshotCheck.tscn:1–6` | 6 | R12: CI 유지; `audit.sh:1077` |
| C | `InvestmentAPCopyCheck.gd` | `tools/InvestmentAPCopyCheck.gd:1–372` | 372 | R12: CI 유지; `직접 등록 미관측` |
| C | `InvestmentAPCopyCheck.gd.uid` | `tools/InvestmentAPCopyCheck.gd.uid:1` | 1 | R12: CI 유지; `직접 등록 미관측` |
| C | `InvestmentAPCopyCheck.tscn` | `tools/InvestmentAPCopyCheck.tscn:1–6` | 6 | R12: CI 유지; `직접 등록 미관측` |
| C | `ManualSaveCheck.gd` | `tools/ManualSaveCheck.gd:1–8329` | 8329 | R12: CI 유지; `audit.sh:1146` |
| C | `ManualSaveCheck.gd.uid` | `tools/ManualSaveCheck.gd.uid:1` | 1 | R12: CI 유지; `audit.sh:1146` |
| C | `ManualSaveCheck.tscn` | `tools/ManualSaveCheck.tscn:1–6` | 6 | R12: CI 유지; `audit.sh:1146` |
| C | `NightRoutineTimeCheck.gd` | `tools/NightRoutineTimeCheck.gd:1–251` | 251 | R12: CI 유지; `직접 등록 미관측` |
| C | `NightRoutineTimeCheck.gd.uid` | `tools/NightRoutineTimeCheck.gd.uid:1` | 1 | R12: CI 유지; `직접 등록 미관측` |
| C | `NightRoutineTimeCheck.tscn` | `tools/NightRoutineTimeCheck.tscn:1–6` | 6 | R12: CI 유지; `직접 등록 미관측` |
| C | `PhoneSystemCheck.gd` | `tools/PhoneSystemCheck.gd:1–269` | 269 | R12: CI 유지; `audit.sh:733` |
| C | `PhoneSystemCheck.gd.uid` | `tools/PhoneSystemCheck.gd.uid:1` | 1 | R12: CI 유지; `audit.sh:733` |
| C | `PhoneSystemCheck.tscn` | `tools/PhoneSystemCheck.tscn:1–6` | 6 | R12: CI 유지; `audit.sh:733` |
| C | `PlaytestFlavorCheck.gd` | `tools/PlaytestFlavorCheck.gd:1–473` | 473 | R12: CI 유지; `audit.sh:1463` |
| C | `PlaytestFlavorCheck.gd.uid` | `tools/PlaytestFlavorCheck.gd.uid:1` | 1 | R12: CI 유지; `audit.sh:1463` |
| C | `PlaytestFlavorCheck.tscn` | `tools/PlaytestFlavorCheck.tscn:1–6` | 6 | R12: CI 유지; `audit.sh:1463` |
| C | `ProseRecallCheck.gd` | `tools/ProseRecallCheck.gd:1–706` | 706 | R12: CI 유지; `직접 등록 미관측` |
| C | `ProseRecallCheck.gd.uid` | `tools/ProseRecallCheck.gd.uid:1` | 1 | R12: CI 유지; `직접 등록 미관측` |
| C | `ProseRecallCheck.tscn` | `tools/ProseRecallCheck.tscn:1–6` | 6 | R12: CI 유지; `직접 등록 미관측` |
| C | `SceneDirectionCheck.gd` | `tools/SceneDirectionCheck.gd:1–509` | 509 | R12: CI 유지; `audit.sh:1262` |
| C | `SceneDirectionCheck.gd.uid` | `tools/SceneDirectionCheck.gd.uid:1` | 1 | R12: CI 유지; `audit.sh:1262` |
| C | `SceneDirectionCheck.tscn` | `tools/SceneDirectionCheck.tscn:1–6` | 6 | R12: CI 유지; `audit.sh:1262` |
| C | `ScreenshotQA.gd` | `tools/ScreenshotQA.gd:1–25993` | 25993 | R12: 공용; ci.yml:74,81 → 입력 래퍼 :161 → tscn의 ext_resource |
| C | `ScreenshotQA.gd.uid` | `tools/ScreenshotQA.gd.uid:1` | 1 | R12: 공용; 위 tscn의 스크립트 UID |
| C | `ScreenshotQA.tscn` | `tools/ScreenshotQA.tscn:1–6` | 6 | R12: 공용; ci.yml:74,81 → 입력 래퍼 :161 → scene |
| C | `SeoulTraceCheck.gd` | `tools/SeoulTraceCheck.gd:1–48` | 48 | R12: CI 유지; `직접 등록 미관측` |
| C | `SeoulTraceCheck.gd.uid` | `tools/SeoulTraceCheck.gd.uid:1` | 1 | R12: CI 유지; `직접 등록 미관측` |
| C | `SeoulTraceCheck.tscn` | `tools/SeoulTraceCheck.tscn:1–6` | 6 | R12: CI 유지; `직접 등록 미관측` |
| C | `StoryDemoFourLanguageCheck.gd` | `tools/StoryDemoFourLanguageCheck.gd:1–1180` | 1180 | R9/R12: 공개·공용 보존; `audit.sh:304` |
| C | `StoryDemoFourLanguageCheck.gd.uid` | `tools/StoryDemoFourLanguageCheck.gd.uid:1` | 1 | R9/R12: 공개·공용 보존; `audit.sh:304` |
| C | `StoryDemoFourLanguageCheck.tscn` | `tools/StoryDemoFourLanguageCheck.tscn:1–6` | 6 | R9/R12: 공개·공용 보존; `audit.sh:304` |
| C | `StoryMapM1M6Check.gd` | `tools/StoryMapM1M6Check.gd:1–999` | 999 | R12: CI 유지; `직접 등록 미관측` |
| C | `StoryMapM1M6Check.gd.uid` | `tools/StoryMapM1M6Check.gd.uid:1` | 1 | R12: CI 유지; `직접 등록 미관측` |
| C | `StoryMapM1M6Check.tscn` | `tools/StoryMapM1M6Check.tscn:1–6` | 6 | R12: CI 유지; `직접 등록 미관측` |
| C | `StoryMapM1M6Playtest.gd` | `tools/StoryMapM1M6Playtest.gd:1–2543` | 2543 | R12: CI 유지; `직접 등록 미관측` |
| C | `StoryMapM1M6Playtest.gd.uid` | `tools/StoryMapM1M6Playtest.gd.uid:1` | 1 | R12: CI 유지; `직접 등록 미관측` |
| C | `StoryMapM1M6Playtest.tscn` | `tools/StoryMapM1M6Playtest.tscn:1–12` | 12 | R12: CI 유지; `직접 등록 미관측` |
| C | `StoryPlaybackCheck.gd` | `tools/StoryPlaybackCheck.gd:1–1578` | 1578 | R12: CI 유지; `audit.sh:1096` |
| C | `StoryPlaybackCheck.gd.uid` | `tools/StoryPlaybackCheck.gd.uid:1` | 1 | R12: CI 유지; `audit.sh:1096` |
| C | `StoryPlaybackCheck.tscn` | `tools/StoryPlaybackCheck.tscn:1–6` | 6 | R12: CI 유지; `audit.sh:1096` |
| C | `StoryTutorialPlacementCheck.gd` | `tools/StoryTutorialPlacementCheck.gd:1–316` | 316 | R12: CI 유지; `audit.sh:1058` |
| C | `StoryTutorialPlacementCheck.gd.uid` | `tools/StoryTutorialPlacementCheck.gd.uid:1` | 1 | R12: CI 유지; `audit.sh:1058` |
| C | `StoryTutorialPlacementCheck.tscn` | `tools/StoryTutorialPlacementCheck.tscn:1–6` | 6 | R12: CI 유지; `audit.sh:1058` |
| C | `audit.sh` | `tools/audit.sh:1–1640` | 1640 | R12: CI 유지; `audit.sh:3` |
| C | `build_story_demo_desktop.sh` | `tools/build_story_demo_desktop.sh:1–294` | 294 | R9/R12: 공개·공용 보존; `직접 등록 미관측` |
| C | `build_story_demo_macos.sh` | `tools/build_story_demo_macos.sh:1–2372` | 2372 | R9/R12: 공개·공용 보존; `직접 등록 미관측` |
| C | `build_story_demo_successor_macos.py` | `tools/build_story_demo_successor_macos.py:1–552` | 552 | R9/R12: 공개·공용 보존; `직접 등록 미관측` |
| C | `chapter1_core_loop_v2_causal_debt_baseline.json` | `tools/chapter1_core_loop_v2_causal_debt_baseline.json:1–65` | 65 | R12: CI 유지; `직접 등록 미관측` |
| C | `chapter1_core_loop_v2_causal_ledger_check.py` | `tools/chapter1_core_loop_v2_causal_ledger_check.py:1–23535` | 23535 | R12: CI 유지; `audit.sh:549,551` |
| C | `core_loop_v2_balance_sim.py` | `tools/core_loop_v2_balance_sim.py:1–4481` | 4481 | R12: CI 유지; `audit.sh:553` |
| C | `demo_core_loop_v2_audit.py` | `tools/demo_core_loop_v2_audit.py:1–13166` | 13166 | R12: CI 유지; `audit.sh:547` |
| C | `demo_experience_audit.py` | `tools/demo_experience_audit.py:1–653` | 653 | R12: CI 유지; `audit.sh:265` |
| C | `demo_localization_scope.py` | `tools/demo_localization_scope.py:1–1561` | 1561 | R12: CI 유지; `audit.sh:471,473` |
| C | `demo_prose_style_audit.py` | `tools/demo_prose_style_audit.py:1–637` | 637 | R12: CI 유지; `audit.sh:475` |
| C | `event_lifecycle.py` | `tools/event_lifecycle.py:1–941` | 941 | R12: CI 유지; `audit.sh:140,142` |
| C | `first_session_pacing_audit.py` | `tools/first_session_pacing_audit.py:1–417` | 417 | R12: CI 유지; `audit.sh:260` |
| C | `story_demo_density_contract.json` | `tools/fixtures/story_demo_density_contract.json:1–1073` | 1073 | R9/R12: 공개·공용 보존; `직접 등록 미관측` |
| C | `release_content_inventory.py` | `tools/release_content_inventory.py:1–3598` | 3598 | R12: CI 유지; `audit.sh:123,125` |
| C | `run_core_loop_v2_input_qa.sh` | `tools/run_core_loop_v2_input_qa.sh:1–187` | 187 | R12: CI 유지; `ci.yml:74,81` |
| C | `story_demo_density_audit.py` | `tools/story_demo_density_audit.py:1–3199` | 3199 | R9/R12: 공개·공용 보존; `audit.sh:270,272` |
| C | `story_demo_localization_audit.py` | `tools/story_demo_localization_audit.py:1–709` | 709 | R9/R12: 공개·공용 보존; `audit.sh:277,279` |
| C | `story_demo_package_audit.py` | `tools/story_demo_package_audit.py:1–2632` | 2632 | R9/R12: 공개·공용 보존; `직접 등록 미관측` |
| C | `story_demo_successor_package_audit.py` | `tools/story_demo_successor_package_audit.py:1–789` | 789 | R9/R12: 공개·공용 보존; `직접 등록 미관측` |

</details>
