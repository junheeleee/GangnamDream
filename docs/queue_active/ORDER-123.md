# Active Queue Spec: ORDER-123

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-123 [P0·CI/입력] W9 다중 약속 선택판의 3~4개 후보를 보존해 24주 입력 정지를 복구한다

**착수 선언 (2026-08-22):** 구현 기준은 ORDER-122 closure
`680e5f6bdcc9223b45143ca6224f7eb112809c6e`다. 원격 run
[`32514117956`](https://github.com/junheeleee/GangnamDream/actions/runs/32514117956)의
정적 감사와 전체 `audit.sh`는 통과했지만, KO PlayStation 24주 실제입력이 W9에서
`trigger_candidates supports at most 2 entries`로 중단됐다. 정확한 후보는 ordinary
`daeun_world_meet`와 source-bound terminal
`terminal:m1_father_completed_wellbeing_to_m3_quiet_call`,
`terminal:m2_people_completed_hyunsu_to_m3_followup` 세 개다.

Board의 두 후보 상한은 `d86a5f1e507dcc6e71f911424e7c4f206e0b26aa`, ordinary와
terminal receipt를 합친 상태 원장은 `9e6d155724d9`에서 들어왔다. 그 3개 union을
실행 가능한 `trigger_candidates`로 처음 노출한 표면 생산자는 자식
`780c10a1229465bc55ad6715a50d165b6bb396df`이며, 이때부터 Board와 실제 입력의
producer/consumer 계약이 어긋났다.
ORDER-119 기준과 ORDER-122 후보의 producer·Board·MainGame·ScreenshotQA·데이터는
byte-exact이며, 선행 audit red가 사라져 처음 실제입력 단계까지 도달하면서 드러난
기존 ORDER-101 통합 부채다. 후보를 둘로 자르거나 콘텐츠를 바꾸지 않는다.

**감사 파생 잠금 보강 (2026-08-22):** 구현 freeze
`4177cd281d7be2c4084a294fd1aa3cbb89b15709`의 첫 전체 감사에서 제품·
컴파일·밸런스·런타임은 통과했고, 새 `MainGame.gd` 바이트를 아직 가리키지
않는 Year5 보호 해시 1건과 Board의 새 fail-closed 안내 `_tr` 1회가
지역화 source occurrence 원장에 반영되지 않은 파생 실패 4건만 남았다.
제품 문구·번역 키·JA 번역·route/R1b 의미는 바꾸지 않고 이 exact 잠금만
소유 범위에 추가한다.

## 깊이 3문

1. 왜 상한을 3으로만 올리지 않는가? M3 people은 Jiyeon·Daeun ordinary 둘과
   Father·Hyunsu terminal 둘을 함께 합법적으로 만들 수 있어 현재 reachable max는 4다.
2. 왜 ID를 하나로 합치지 않는가? terminal의 선택 ID, 실행 bundle ID, route ID는
   서로 다른 계보다. candidate를 bundle로 덮으면 잘못된 버튼·영수증·다음 장면을 고른다.
3. 왜 작은 화면까지 함께 고치는가? 960×600의 기존 세로 목록은 세 번째 후보부터
   설명·진전·Commit과 겹친다. 실제 입력이 가능해도 읽거나 확정할 수 없으면 복구가 아니다.

## 구현 계약

- `SeoulCycleBoard`는 이름 있는 최대치 4를 허용하고 5 이상, 중복/빈 ID,
  localized label/detail 결손을 계속 fail-closed한다.
- terminal preview의 canonical 선택 identity는 non-empty
  `selected_trigger_candidate_id`, ordinary preview는
  `selected_trigger_bundle_id`다. bundle·route·variant 필드는 원래 의미를 보존한다.
- `MainGame`은 위 identity로 후보별 side-effect-free preview를 붙이며, 후보 map의
  키와 preview identity가 정확히 같을 때만 Board에 건넨다.
- compact 화면은 후보 목록만 최대 두 행 높이의 세로 scroll 영역으로 만들고,
  포커스 후보를 자동으로 보이게 한다. 설명·진전·deadline·Commit은 고정해 숨기지 않는다.
- 0개는 노드를 잠근다. ordinary 후보 1개도 South로 명시 선택하고, source-bound terminal
  후보가 단독으로 남은 경우에만 기존 `terminal_auto`를 보존한다. 2~4개는 canonical lexical
  order로 전부 남긴다. East는 commit 전 선택만 되돌리며 상태를 쓰지 않는다.
- ScreenshotQA 실제입력은 desired bundle이 terminal binding으로 치환됐으면 candidate
  record의 `bundle_id`로 찾아 record `id`를 누른다. receipt에서 candidate/bundle/route를
  각각 대조하고 하나로 간주하지 않는다.
- `DemoCoreLoopV2`·KO/EN 사건·`demo_core_loop_v2.json`·효과·밸런스·저장 schema·
  후보 생산/정렬·terminal receipt는 byte-exact다.
- Year5 보호 기준은 구현 freeze `4177cd281d7be2c4084a294fd1aa3cbb89b15709`와
  그 commit의 `MainGame.gd` SHA-256만 가리키며 route·object digest·R1b
  activation은 바꾸지 않는다.
- 지역화 원장은 동일한 KO/EN 안내 lookup의 occurrence `+1`만 기록한다.
  unique source key/hash, 번역 문자열, JA/ZH coverage와 shipping 상태는 바꾸지 않는다.

## L1 기계 증거

- Board fixture를 KO/EN × keyboard/gamepad × 960×600/1280×800에서 0·1·2·3·4개로
  실행한다. 3개는 실패한 W9 exact IDs, 4개는 reachable M3 union을 쓴다.
- 3개에서는 Hyunsu terminal을, 4개에서는 마지막 후보를 raw 방향키/패드로 찾아
  candidate/bundle/route tuple, 선택 preview, Commit, emit, state-byte neutrality를 확인한다.
- 5개, raw record type·KO/EN label/detail 결손, missing/wrong
  `selected_trigger_candidate_id`, sibling substitution, candidate/bundle/route cross-wire는
  open 또는 Commit을 fail-closed하고 emit/state 변화 0이다.
- compact에서 후보 scroll viewport·focused button·trailing rows·Commit rect가 모두
  Board 안에 있고 `seoul_cycle_preview_layout_clearance >= 0`; label ellipsis와 잘림이 없다.
- `CoreLoopV2CycleCheck`는 current W9 exact 3개와 reachable legal max 4를 producer에서
  고정하고 재구성할 수 없는 fifth state·terminal identity 변이를 거부한다. Board의 실제
  5-record 상한은 ScreenshotQA와 static demo audit가 따로 증명한다.
- `demo_core_loop_v2_audit.py`는 Board declared max와 현재 data/terminal-union 최대치를
  대조해 max2 회귀와 unbounded 완화를 거부한다. `audit_scope`는 Board 변경이 이 검사의
  direct+self-test를 반드시 선택하도록 한다.
- Compile, Chapter causal direct+self-test, CoreLoop cycle, KO gamepad 24주,
  EN keyboard 24주, surface matrix, `audit_select`, context/queue/dashboard/diff를 통과한다.
- Year5 direct+self-test/R1 Godot, JA UI/pipeline self-test, ZH direct+self-test,
  demo localization direct+self-test가 파생 잠금 갱신 뒤 통과한다.
- 최종 closure까지 포함한 같은 바이트에서 `./tools/audit.sh`와 원격 CI가 green이어야 한다.

## L2 재독

- 실패 run의 W9 세 후보와 선택 후 실제 `v2_hyunsu_study_followup` 도달을 로그로 대조한다.
- 960×600 KO/EN 캡처에서 세 번째·네 번째 항목, 설명, 진전, Commit을 직접 본다.
- ordinary/terminal 선택 각각에서 candidate ID, authored bundle, terminal route, variant,
  영수증과 다음 장면이 서로 바뀌지 않았는지 전수 재독한다.
- 기준 대비 사건·실행 meta·DemoCoreLoop·효과·저장·밸런스 byte 불변과 변경 파일 밖
  drift 0을 확인한다. 예외는 아래에 선언한 Year5/localization 파생 잠금 필드뿐이다.

## 배치 — 정확히 20단위

1. 선언·큐·부팅 상태를 기준 commit과 실패 run에 고정한다.
2. W9 세 후보의 producer·Board·MainGame·입력 계보를 exact fixture로 고정한다.
3. reachable M3 네 후보와 다섯 후보 불법 경계를 정적 계산한다.
4. Board에 이름 있는 최대치 4와 5개 fail-closed를 구현한다.
5. MainGame의 terminal-aware candidate preview identity를 구현한다.
6. Board의 terminal-aware selected preview identity를 구현한다.
7. compact 후보 영역을 두 행 높이 scroll로 만들고 trailing surface를 보존한다.
8. 후보 포커스 자동 스크롤과 1~4개 방향 이동을 연결한다.
9. ScreenshotQA 0/1/2 fixture를 3/4까지 확장한다.
10. terminal candidate/bundle/route cross-wire 음성 fixture를 추가한다.
11. ScreenshotQA 실제입력의 desired bundle→candidate ID 해석을 고친다.
12. 실제입력 receipt와 다음 장면의 candidate/bundle/route를 각각 검증한다.
13. CoreLoop producer의 W9 exact 3·reachable max4·max5 음성을 고정한다.
14. static demo audit와 audit selection의 Board 상한 계약을 고정한다.
15. KO/EN × 입력 × 해상도 matrix를 실행하고 compact 이미지를 재독한다.
16. KO gamepad·EN keyboard 24주와 첫 full audit를 같은 freeze에서 실행한다.
17. 구현 commit과 MainGame 해시를 Year5 보호 기준·감사 상수에 재잠근다.
18. Board 안내 lookup `+1`의 source occurrence만 localization manifest·JA self-test에 재잠근다.
19. Chapter source/proof hash와 WORK_LOG 최종 hash만 새 바이트에 재잠근다.
20. 지속 규칙 승격·archive·STATUS·최종 full audit·원격 CI green 뒤 더 쓰지 않는다.

## 파일 소유권 — 정확히 19개

1. `scenes/MainGame.gd`
2. `scenes/SeoulCycleBoard.gd`
3. `tools/ScreenshotQA.gd`
4. `tools/CoreLoopV2CycleCheck.gd`
5. `tools/demo_core_loop_v2_audit.py`
6. `tools/audit_scope.json`
7. `tools/chapter1_core_loop_v2_causal_ledger_check.py`
8. `docs/QA_CHECKLIST.md`
9. `content/meta/year5_reference_routes.json`
10. `tools/year5_reference_route_audit.py`
11. `content/meta/demo_localization_scope.json`
12. `tools/ja_translation_pipeline.py`
13. `CLAUDE.md`
14. `docs/CODEX_QUEUE.md`
15. `docs/queue_active/ORDER-123.md`
16. `docs/queue_archive/ORDER-123.md`
17. `docs/queue_archive/CODEX_QUEUE_2026-08.md`
18. `docs/WORK_LOG.md`
19. `docs/STATUS.md`

`content/meta/chapter1_core_loop_v2_causal_ledger.json`은 direct 검사로 byte-exact를
증명한다. 실제 semantic digest가 바뀌는 예외가 확인될 때만 먼저 scope를 확장한다.
`project.godot`, 사건 JSON, `systems/DemoCoreLoopV2.gd`, 다른 meta manifest, 저장·밸런스,
release 원장과 asset manifest는 수정·스테이징하지 않는다. 위 Year5/localization
원장은 지목한 baseline/hash/count 필드만 바꾸고 나머지는 byte-exact로 보존한다.

## 증거 양식

- 기준/구현/closure commit과 tree, exact changed paths와 outside `0`.
- 실패 run·step·W9 3 IDs, KO/EN 24주 종료 marker와 선택 tuple/다음 bundle.
- 0..4 matrix·5/malformed 음성 수, 960/1280 KO/EN 캡처 경로와 L2 판정.
- Compile/Cycle/Chapter/demo audit/audit-select/full audit/원격 CI 결과.
- byte-exact 불변 목록, 승격/일회성 판정, ORDER-119 사용자 GO OPEN.
