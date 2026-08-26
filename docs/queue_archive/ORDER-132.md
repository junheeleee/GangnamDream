# Archived Queue Spec: ORDER-132

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [x] ORDER-132 [P1·갤러리 회상 무결성] 20개 명장면을 최초 관람 상태로 고정하고 현재 런 누출을 차단한다

**사용자 위임·착수 근거 (2026-08-26):** 사용자는 게임을 최종까지
완성하고, 플레이할 때가 되면 알려 달라고 했다. ORDER-131 종료 전수
감사에서 다음 제품 P1이 갤러리 20루트의 현재 런 상태 누출로 확정됐다.
과거의 이름·연도·인물상·도덕 인지·주거·기억·선택·계절 음향이 나중
런에 따라 바뀌지 않게 하되, 현재 번역 원고는 계속 반영한다.

**착수 기준선:** `024e41861f5dcb095bbb4798ab6376ec6f13b772` / tree
`9ca464232f90f405bedf2ab47e5d385339ec7c4c`의 exact clean 전체 감사
`CHAPTER1_CAUSAL_LEDGER_SELF_TEST_OK cases=476`과 `✅ 감사 통과`.

**정확한 파일 범위:** `autoloads/MetaProgression.gd`,
`scenes/StartMenu.gd`, `scenes/StoryMode.gd`, `systems/DemoCoreLoopV2.gd`,
`autoloads/BGMPlayer.gd`, 신규 `tools/GalleryReplaySnapshotCheck.gd`,
`tools/GalleryReplaySnapshotCheck.gd.uid`, `tools/GalleryReplaySnapshotCheck.tscn`,
`tools/CoreLoopV2ECheck.gd`, `tools/ManualSaveCheck.gd`,
`tools/StoryPlaybackCheck.gd`, `tools/StoryDialogueHistoryCheck.gd`,
`tools/MoneyIntegrityCheck.gd`, `tools/PlaytestFlavorCheck.gd`,
`tools/ScreenshotQA.gd`, `tools/audit.sh`, `tools/audit_scope.json`,
`tools/demo_core_loop_v2_audit.py`, `tools/core_loop_v2_balance_sim.py`,
`tools/chapter1_core_loop_v2_causal_ledger_check.py`,
`content/meta/chapter1_core_loop_v2_causal_ledger.json`,
`tools/year5_reference_route_audit.py`,
`content/meta/year5_reference_routes.json`,
`docs/ROMANCE_SYSTEM.md`, `docs/CORE_LOOP_V2.md`,
`docs/QA_CHECKLIST.md`, `docs/CODEX_QUEUE.md`, 이 사양과 완료 시
`docs/queue_archive/ORDER-132.md`,
`docs/queue_archive/CODEX_QUEUE_2026-08.md`, `CLAUDE.md`,
`docs/WORK_LOG.md`, 생성본 `docs/STATUS.md`. `autoloads/GameState.gd`,
`autoloads/SaveManager.gd`, `content/meta/default_meta.json`, 사건·번역 JSON,
로케일 파일, `project.godot`은 byte 불변 범위다.

**전체 감사 통합 수리 (2026-08-26):** 구현 freeze 뒤 첫 exact clean 전체
감사가 과거의 비갤러리 가짜 replay fixture, 단일 스냅숏 writer 이름,
`_choice_visible` 구 시그니처, StoryMode 메모리 reader 구 본문 위치,
Year 5 보호 해시를 계속 요구해 7개 차선을 반려했다. 제품 계약이나 Chapter 1
48행·debt·proof ID를 느슨하게 하지 않고, 위 검사 fixture·포인터·source/proof
digest만 새 원자 pair 구조에 맞춰 같은 오더에서 재봉인한다.

## 판정 단위·배치

**배치 A — 갤러리 20루트, 독립 단위 20개:**

`arc_date_namsan_daeun`, `arc_date_namsan_jiyeon`,
`arc_date_park_daeun`, `arc_date_park_jiyeon`,
`arc_daeun_hometown_1`, `arc_jiyeon_narrow_room_1`,
`arc_season_cherry_daeun`, `arc_season_cherry_jiyeon`,
`arc_season_sea_daeun`, `arc_season_sea_jiyeon`,
`arc_season_fireworks_daeun`, `arc_season_fireworks_jiyeon`,
`arc_season_snow_daeun`, `arc_season_snow_jiyeon`,
`arc_daeun_first_kiss`, `arc_jiyeon_first_kiss`,
`arc_daeun_first_night`, `arc_daeun_wedding_night`,
`arc_jiyeon_wedding_night`, `v2_demo_first_bill_opening`.

작성 폐쇄는 exact 51편(일반 48 + 첫 청구서 3)이다. 첫 청구서에서
실행 중 조건부로 붙는 `v2_hyunsu_exam_morning_echo`까지 포함한 최대 재생
집합은 52편이다. 루트 하나가 반려되어도 다른 루트의 스냅숏 계약은
독립적으로 판정할 수 있게 검사한다.

## 착수 전 깊이 3문

1. **이 루트의 스냅숏을 지우면 무엇이 깨지는가?** 과거 관람 장면의
   이름·연차 인물상·도덕 팔레트·주거·기억 문장·계절 음향이 현재
   런으로 바뀌어, 회상이 기록이 아니라 새로 지어낸 장면이 된다.
2. **본 플레이어와 보지 않은 플레이어의 상태가 24주 뒤에 다른가?** 최초
   실재 조우에서만 `seen + valid snapshot` 쌍이 원자적으로 생기며, 보지 않은
   루트는 잠긴다. 이 차이는 후속 런이 바뀌어도 덮어쓰지 않는다.
3. **같은 자리에서 무엇과 경쟁하는가?** 재생 시점의 live `GameState`와 최초 관람
   스냅숏이 경쟁한다. 갤러리에서는 스냅숏만 이기고, 필요한 값이 없거나
   손상되면 live 추론 없이 잠긴다.

## 구현 계약

- 로케일 중립 schema 1은 root ID, raw player name, turn, moral tint,
  housing ID, 사건별 일치한 선택자 key, 사건별 보였던 원래 choice
  index만 저장한다. 번역된 본문·선택·결과 문장은 저장하지 않는다.
- 일반 19루트는 최초 live 진입의 첫 렌더·선택 효과 전에 폐쇄 전체를 캡처한다.
  첫 청구서는 결정 직전 frame을 잡고 exact 결정 receipt가 생긴 뒤 결과 산문 전에
  유효 pair를 저장한다. `seen_scenes`와 스냅숏은 detached 후보 메타의 한 논리적
  pair로 한 번 저장하며 뒤의 런이 덮어쓰지 않는다. 파일시스템 crash transaction을
  새로 보장한다는 뜻은 아니다.
- 기존 seen-only, 고아 스냅숏, 잘못된 root/schema/type/깊이/크기는 카드·
  진행률·재생을 fail-closed로 잠근다. 기존 `seen_scenes`를 지우거나
  현재 런으로 과거를 합성하지 않고, 다음 실제 live 조우에서만 쌍을 복구한다.
- 갤러리 StoryMode는 이름·시각 연차·도덕 인지·배경/주거·조건 선택자·
  보이는 선택·계절 BGM/앨비언스를 스냅숏에서만 읽고 live fallback을
  두지 않는다. 모든 갤러리 재생에서 live HUD를 숨긴다.
- 첫 청구서 schema 1에
  `m3_ledger_memory = "" | "m3_ledger_reasons_named" | "m3_ledger_totals_only"`를
  추가한다. 구 스냅숏의 누락은 `""`로 정규화하고 live 추론을 하지
  않으며, 타입·허용값·상호모순은 거부한다.
- 재생은 현재 런, 업적, scene history, CG unlock, 메타 스냅숏을 수정하지
  않는다. 손상 재생 요청은 스토리 큐를 비우고 메뉴로 복귀한다.
- 메타 버전·세이브 슬롯 schema를 올리지 않고, AP·사건 원고·로케일·
  `project.godot`을 바꾸지 않는다. 갤러리가 아닌 일반 StoryMode 선택
  inventory/opportunity/follow-up 스냅숏은 별도 오더의 경계다.

## 완료 증거

- L1: 전용 검사가 `roots=20 authored_closure=51 runtime_max=52`, 최초 쌍
  write-once·원자 저장, 7개 동결 표면, HUD 0, live mutation 0, 손상/legacy
  fail-closed, First Bill M3 3종+구 누락을 입증한다.
- L1: `CoreLoopV2ECheck`, `ManualSaveCheck`, `StoryPlaybackCheck`, KO/EN
  `ScreenshotQA --qa=gallery`, `audit_select`, 컨텍스트 메니페스트,
  `git diff --check`를 통과한다. 공용 메타·StoryMode·BGM 스키마를
  바꾸므로 완료 후 exact clean 전체 감사를 한 번 실행한다.
- L2: 20루트 전수표에 도달 경로, 생산자↔독자, before→after, 포기 시
  잃는 재생 표면, 서사 위치, T1/T2/T3, 닫는 것을 측정값 또는 `file:line`으로
  남긴다.
- L3: 이 오더는 과거 상태 무결성 수리이며 신규 원고·연출 판정을 만들지
  않는다. 기존 `human_gates.json`의 데모 정상 속도 재생·언어·실물 입력
  OPEN은 별도로 유지하며 자동 GREEN으로 재미 GO를 선언하지 않는다.

## 정본 승격 판정

- 승격 완료: `docs/ROMANCE_SYSTEM.md` §7-I가 최초 유효 쌍·로케일 중립·
  fail-closed·read-only 규칙을, `docs/CORE_LOOP_V2.md`의 첫 청구서 절이 M3
  장부 기억 동결을, `docs/QA_CHECKLIST.md`의 갤러리 행이 20루트 검증 계약을
  각각 소유한다. 같은 규칙을 새 정본에 중복하지 않았다.
- 일회성: exact 수정 파일 범위, 20단위 배치, 검사 실행 순서,
  착수 기준 commit/tree.

## L2 전수 증거

생산자는 `scenes/StoryMode.gd:3502`·`:3803`의 일반 19루트 첫 문단 전 live 캡처와
`:3602`·`:5953`의 첫 청구서 결정 전 frame/결정 후 pair 캡처다.
`autoloads/MetaProgression.gd:14`
카탈로그와 `:316` 폐쇄 계산 뒤 `:346` 스냅숏 작성, `:373` 원자 pair 저장,
`:398` 유효 pair 판정을 거친다. 독자는 `scenes/StartMenu.gd:1285` 카드와
`:1431` 동결 썸네일, `scenes/StoryMode.gd:277`의 경계 검사 및 `:329` 폐쇄,
`:438` 연차·`:447` 도덕 인지·`:3835` 초상·`:3907` selector·선택 독자,
`autoloads/BGMPlayer.gd:361`의 동결 계절/주거 문맥이다.

일반 19행의 before→after는 미관람·seen-only·고아·손상·직접 요청 잠김 → 다음
실제 live 첫 조우에서만 pair 기록 → 이후 덮어쓰기 불가다. 첫 청구서는 W24
결정 receipt까지 있어야 열리고, 복구 가능한 legacy 진행 중 저장만 이어받으며
복구 불가능한 완료 저장은 잠긴다. 포기하면 표의 동결 표면이 현재 런으로 바뀐다.
번역문은 저장하지 않아 현재 KO/EN을 읽는다. 일반 루트는 당시 보였던 선택 index만
고정하고 실제 고른 선택을 자동 재선택하지 않지만, 첫 청구서는 exact 결정
`choice_index/selected_obligation_id`를 저장한다. 대체 선택은 회상 안에서만 바뀐다.

| # | 루트 | 서사 위치·도달 | 기능 tier | 작성 폐쇄/보이는 선택 | 이 행이 닫는 동결 표면·경계 |
|---:|---|---|---|---:|---|
| 1 | `arc_date_namsan_daeun` | 다은 데이트 3회 뒤 남산 | T1 | 2/6 | 이름·연차·도덕·자물쇠 선택 |
| 2 | `arc_date_namsan_jiyeon` | 지연 데이트 3회 뒤 남산 | T1 | 2/6 | 이름·연차·도덕·자물쇠 선택 |
| 3 | `arc_date_park_daeun` | 남산 뒤 데이트 6회 | 미선언(T3 기본)·기능상 T2 부채 | 1/2 | 당시 선택·관계 플래그; T3 무상태 계약과 불일치 |
| 4 | `arc_date_park_jiyeon` | 남산 뒤 데이트 6회 | 미선언(T3 기본)·기능상 T2 부채 | 1/2 | 당시 선택·관계 플래그; T3 무상태 계약과 불일치 |
| 5 | `arc_daeun_hometown_1` | W100+ 여름, 다은 연애 | 미선언(T3 기본)·T2 전주 부채 | 1/2 | 고향 방문 선택; 실제 T1 `hometown_2`는 폐쇄 밖 |
| 6 | `arc_jiyeon_narrow_room_1` | W150+ 서늘한 달, 지연·기록선 | 미선언(T3 기본)·T2 전주 부채 | 1/2 | 기록 selector·방 방문 선택; T1 `narrow_room_2`는 폐쇄 밖 |
| 7 | `arc_season_cherry_daeun` | 매년 4월, 다은 | 미선언(T3 기본)·기능상 T2 부채 | 1/3 | `cherry_grey_view` selector·선택 |
| 8 | `arc_season_cherry_jiyeon` | 매년 4월, 지연 | 미선언(T3 기본)·기능상 T2 부채 | 1/3 | `cherry_grey_view` selector·선택 |
| 9 | `arc_season_sea_daeun` | 매년 7~8월, 다은 | T1 | 4/6 | 두 중간 분기·결정·계절 음향 |
| 10 | `arc_season_sea_jiyeon` | 매년 7~8월, 장거리 허용 | T1 | 4/6 | 두 중간 분기·결정·계절 음향 |
| 11 | `arc_season_fireworks_daeun` | 매년 9~10월, 다은 | T1 | 4/7 | 복장/강변 분기·결정·계절 음향 |
| 12 | `arc_season_fireworks_jiyeon` | 매년 9~10월, 지연 | T1 | 4/7 | 일정/보폭 분기·결정·계절 음향 |
| 13 | `arc_season_snow_daeun` | 매년 12월, 다은 | 미선언(T3 기본)·기능상 T2 부채 | 1/2 | `daeun_sea_5years` selector·선택 |
| 14 | `arc_season_snow_jiyeon` | 매년 12월, 지연 | 미선언(T3 기본)·기능상 T2 부채 | 1/2 | `jiyeon_cant_swim` selector·선택 |
| 15 | `arc_daeun_first_kiss` | 연애·데이트 2회 뒤 첫 입맞춤 | T1 | 4/6 | 4개 연차 초상 surface·최종 결정 |
| 16 | `arc_jiyeon_first_kiss` | 연애·데이트 2회 뒤 첫 입맞춤 | T1 | 4/6 | 4개 연차 초상 surface·최종 결정 |
| 17 | `arc_daeun_first_night` | W116+, 호감 45+ | T1 | 4/6 | 4개 연차 초상·4주거 배경/앰비언스·결정 |
| 18 | `arc_daeun_wedding_night` | 결혼식 관람 뒤 | T1 | 4/6 | 고향 방문 selector·결혼 첫밤 결정 |
| 19 | `arc_jiyeon_wedding_night` | 결혼 공백 장면 뒤 | T1 | 4/6 | 결혼 첫밤 결정·연차/도덕 표면 |
| 20 | `v2_demo_first_bill_opening` | W24 `demo_collision`·복구 가능한 legacy 진행 중 | T1 | 3/12 | exact 결정 receipt·이름·턴·주거·돈/몸/마음·후보·의무·아버지·M3·dirty/현수; 조건부 echo만 runtime +1 |

합계는 루트 20, 작성 폐쇄 `2+2+1+1+1+1+1+1+4+4+4+4+1+1+4+4+4+4+4+3=51`,
일반 48편의 authored choice slot 86, `{name}` 포함 사건 44, turn-dependent 초상
사건 12, `current_housing` 사건 4, selector-bearing 사건 6이다. 86은 모든 선택을
동결했다는 뜻이 아니다. 명시 T1은 12루트다. 나머지 8루트는 데이터상 미선언이라
`docs/SCENE_TIER.md:53`에 따라 기본 T3지만 선택·플래그를 바꾸므로 기능상 T2와
formal tier 이관 부채를 함께 기록한다.

`arc_daeun_hometown_1`과 `arc_jiyeon_narrow_room_1`은 각각 한 사건짜리 전주다.
실제 정점 `arc_daeun_hometown_2`(어머니의 밥상)와
`arc_jiyeon_narrow_room_2`(좁은 방)는 다음 주의 별도 루트라 이 20개 폐쇄에
들어오지 않는다. 따라서 이 완료는 정확한 카탈로그의 무결성이지 “모든 정점이
회상 가능하다”는 주장이나 재미 판정이 아니다.

## 완료 기록 (2026-08-26)

- 제품 구현 `2e2e5fea8548bfc1dd574aa9d5230192a64ecc7f`, 감사 계약 정렬
  `7112744`, 고립 플레이테스트 홈 정리 `efd647d`로 마감했다.
- 전용 표지는
  `GALLERY_REPLAY_SNAPSHOT_CHECK_OK roots=20 authored_closure=51 runtime_max=52 name=44 portraits=12 moral=48 housing=4 selectors=6 choices=86 write_once=20 fail_closed=seen_only+orphan+corrupt+direct frozen=7 hud=0 mutation=0 m3=3+legacy`다.
- exact 전체 감사는 두 번 통과했다. 첫 실행에서 새 flavor 임시 홈 정리 경고를
  발견해 allowlist를 고쳤고, 최종 `efd647d`에서 경고 없이 `✅ 감사 통과`했다.
  Chapter 1 인과 self-test 476건도 두 번 통과했다. 독립 검토의 남은 P1/P2는 0이다.
- 실물 OpenGL KO/EN 갤러리 각 5장(CG 목록·미리보기·회상·히든 기록·읽기 전용
  결과)을 확인해 잘림·검정막·HUD/결과 카드 누출 0을 확인했다.
- 사람의 정상 속도 재미·언어·실물 입력 GO는 계속 OPEN이다. 두 후속 정점의
  카탈로그 편입과 8루트 formal tier 이관도 다음 콘텐츠 범위다.
- 33세·1장 30억 `instant_legend`는 이 작업 밖의 비밀 이스터에그로 byte 불변이다.

## 다음 경계

ORDER-132 밖에서 Chapter 5 M49~M59의 실제 인물·계약·대화 영수증과
M60·`arc_final_week` actor binding을 별도 자식 오더로 연다. 33세·1장
30억 `instant_legend`는 비밀 이스터에그로 계속 보존한다.
