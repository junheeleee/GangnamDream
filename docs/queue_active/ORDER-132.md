# Active Queue Spec: ORDER-132

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-132 [P1·갤러리 회상 무결성] 20개 명장면을 최초 관람 상태로 고정하고 현재 런 누출을 차단한다

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
`tools/StoryPlaybackCheck.gd`, `tools/ScreenshotQA.gd`, `tools/audit.sh`,
`tools/audit_scope.json`, `docs/ROMANCE_SYSTEM.md`, `docs/CORE_LOOP_V2.md`,
`docs/QA_CHECKLIST.md`, `docs/CODEX_QUEUE.md`, 이 사양과 완료 시
`docs/queue_archive/ORDER-132.md`,
`docs/queue_archive/CODEX_QUEUE_2026-08.md`, `CLAUDE.md`,
`docs/WORK_LOG.md`, 생성본 `docs/STATUS.md`. `autoloads/GameState.gd`,
`autoloads/SaveManager.gd`, `content/meta/default_meta.json`, 사건·번역 JSON,
로케일 파일, `project.godot`은 byte 불변 범위다.

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
- 최초 live 진입의 첫 렌더·선택 효과 전에 폐쇄 전체를 캡처한다.
  `seen_scenes`와 유효한 스냅숏은 하나의 후보 메타를 한 번만 저장하고,
  뒤의 런이 최초 쌍을 덮어쓰지 않는다.
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

- 승격 후보: `docs/ROMANCE_SYSTEM.md` 회상 갤러리에 최초 유효 쌍·로케일
  중립·fail-closed·read-only 규칙, `docs/CORE_LOOP_V2.md`에 First Bill M3
  기억 동결 규칙, `docs/QA_CHECKLIST.md`에 20루트 검증 계약.
- 일회성: exact 수정 파일 범위, 20단위 배치, 검사 실행 순서,
  착수 기준 commit/tree.

## 다음 경계

ORDER-132 밖에서 Chapter 5 M49~M59의 실제 인물·계약·대화 영수증과
M60·`arc_final_week` actor binding을 별도 자식 오더로 연다. 33세·1장
30억 `instant_legend`는 비밀 이스터에그로 계속 보존한다.
