# Active Queue Spec: ORDER-125

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-125 [P0·패키징] 사람 최종 판정을 묶을 clean 240주 full_rc를 발급한다

**착수 선언 (2026-08-24):** 기준은 ORDER-98 active 후보 재결합 closure
`9bd6643222740432641d4ff09972bffa27235ccc`, tree
`8bf86193a316b71c3f268b88e14bd0d45d57c637`다. `full_rc`는 현재
`waiting_rebuild`라 새 사람 최종 판정을 exact 후보에 묶을 수 없다. 사용자 요청
“그냥 완성시켜 어떻게든”에 따라 게임 규칙을 바꾸지 않고 실제 240주 정식판
후보의 provenance·자동 회귀·세 native 플랫폼 패키지만 먼저 발급한다.

## 깊이 3문

1. 왜 기존 BUILD `2026.08.22.1`을 그대로 쓰지 않는가? 현재 HEAD는 그 빌드 뒤의
   승인된 원고·표면·검사 수리를 포함하고, 첫 부모와 같은 BUILD_ID를 재사용하면
   화면·저장 메타와 실제 소스가 갈라진다.
2. 왜 macOS ZIP 하나만 만들지 않는가? `full_rc`가 플랫폼 공통 사람 판정 원장에
   쓰이므로 Windows·macOS·Linux 세 산출물과 하나의 clean manifest가 같은
   commit/tree를 가리켜야 한다. native 실행 주장은 실제 macOS smoke 범위만 한다.
3. 왜 이 발급이 R1b나 최종 GO가 아닌가? 사람 게이트는 active exact 후보가 있어야
   시작할 수 있지만 후보 존재는 원고 승인·재미·A/V·실기기 판정을 대신하지 않는다.
   마지막 해 R1b는 invalidated/reference-only 상태로 패키지 안에서 비도달이어야 한다.

## 배치 A — provenance와 aggregate 발급 계약 8단위

1. `BuildInfo.BUILD_ID`만 다음 미사용 전역 ID `2026.08.24.4`로 바꾼다.
2. `GAME_VERSION`, `SAVE_VERSION`, flavor, feature, 저장 namespace는 보존한다.
3. `tools/build.sh full-rc`는 시작·fresh import 뒤·export 뒤 clean source를 검사한다.
4. BUILD_ID 날짜가 HEAD 날짜와 같고 첫 부모의 BUILD_ID와 다름을 검사한다.
5. 기존 retail Windows·macOS·Linux export를 같은 clean source에서 직렬 실행한다.
6. `build/full_rc/MANIFEST.sha256` 하나에 profile `full`, exact commit/tree,
   `source_status=clean`, Godot 버전, UTC와 세 artifact SHA-256을 기록한다.
7. identity audit는 aggregate manifest의 세 경로가 정확히 한 번씩 있고 실제 파일
   해시가 맞는지 검사하며, 기존 단일 플랫폼 full manifest 호환은 보존한다.
8. self-test는 clean/date/import/3-platform/aggregate audit 호출 하나라도 빠지거나
   artifact가 누락·중복·교체되면 실패한다.

## 배치 B — exact 후보 회귀·패키지·등록 10단위

1. 구현 commit의 별도 clean worktree에서 fresh import와 전체 `tools/audit.sh`를
   실행하고 Godot skip·marker 누락·금지 오류를 허용하지 않는다.
2. KO PlayStation 의미 입력으로 240주를 완주해 `FULL_INPUT_RUN_OK`와
   `FULL_DIRECTION_RUNTIME_OK`를 확인한다.
3. 별도 격리 HOME의 EN Xbox 의미 입력으로 같은 240주 두 marker를 확인한다.
4. 두 런의 keyboard/mouse 입력은 0이고 저장·chapter 경계·엔딩 도달을 확인한다.
5. full export-pack을 별도로 만들고 release content inventory와 제3자 고지를
   검사한다.
6. `full-rc`로 Windows·macOS·Linux를 export하고 aggregate manifest 자체와
   artifact 세 개를 독립 재해시한다.
7. macOS ZIP을 풀어 ad-hoc 서명·bundle·실행 파일을 확인하고 격리 HOME에서
   무인자 부팅한다. 실제 플레이어 저장은 읽거나 쓰지 않는다.
8. `human_gates.json`의 `full_rc`만 active exact commit/tree/manifest로 등록한다.
   기존 full gate 12개는 모두 `open`, evidence 없음으로 둔다.
9. R1b reference route audit direct/self-test/runtime으로 `historical_invalidated`,
   `r1b_allowed=false`, `dispatch=0`, product consumer 0을 재확인한다.
10. 문서·queue·dashboard를 같은 증거로 갱신하고 ORDER-125만 archive한다.

## 정확한 파일 소유권

**제품 provenance 한 줄:** `systems/BuildInfo.gd`.

**발급 도구:** `tools/build.sh`, `tools/build_identity_audit.py`.

**파생 전체감사 수리:** `tools/feature_liveness_audit.py`,
`tools/CompileCheck.gd`, `tools/audit.sh`. ORDER-103의 격리
staging `project.godot`가 `AudioManagerStub.gd`를 실제 autoload로 참조하지만 감사가
루트 `project.godot`만 읽어 고아로 오판하는 기존 false red를, 모든 `*.godot`
프로젝트 설정을 검색하게 고친다. baseline에 죽은 파일로 추가하거나 staging
디렉터리를 통째로 면제하지 않는다. CompileCheck는 전수 `load()` 뒤 기존
`COMPILE_SCAN`과 함께 `COMPILE_CHECK_OK`를 출력해 selector의 exit 0+marker+오류 0
계약을 만족시킨다. 전체 감사도 exact marker를 직접 요구해 무출력 exit 0을
성공으로 오판하지 않는다. 오류를 자체적으로 숨기거나 허용하지 않는다.

**선언·마감:** `docs/CODEX_QUEUE.md`, 이 사양,
`docs/queue_archive/CODEX_QUEUE_2026-08.md`, `CLAUDE.md`, `docs/HANDOFF.md`,
`docs/BUILD_PIPELINE.md`, `docs/human_gates.json`, `docs/WORK_LOG.md`, 생성본
`docs/STATUS.md`.

위에 적지 않은 `project.godot`, `export_presets.cfg`, 사건·스토리·엔딩·게임플레이·
저장·밸런스·번역·자산 파일은 수정하지 않는다. build 산출물과 격리 QA 로그는
`build/` 아래 일회성 증거이며 Git에 넣지 않는다.

## R1b·제품 불변 경계

- `content/meta/year5_reference_routes.json`의 기존 `protected_file_hashes` 전체를
  새 allowlist를 만들지 않고 그대로 검사한다.
- event lifecycle의 author-only, weight 0, hidden, min_turn 9999와 ingress 0,
  reference route의 invalidated/replacement null/reference-only/dispatch false,
  product consumer 0을 유지한다.
- `all_resources` export가 dormant 원고를 포함하는 것은 활성화 증거가 아니다.
  실제 240주 제품 경로에서 도달 0이어야 한다.
- 이 오더는 ORDER-124 story-first 제품 이관이나 AP 엔진 삭제를 하지 않는다.

## 완료 증거

- 구현 commit은 clean이고 `BUILD_ID=2026.08.24.4`, 날짜/첫 부모 재사용 guard PASS.
- build identity self-test, 전체 감사, KO/EN 240주 두 경로, R1b 세 검사,
  full-pack inventory/notices가 모두 PASS.
- feature liveness는 nested staging project의 실제 autoload 참조를 인식하고 새
  orphan 0으로 PASS하며 기존 orphan baseline은 바꾸지 않는다.
- CompileCheck는 전수 scan과 exact success marker를 모두 남기고, selector가 marker
  누락·비정상 종료·스크립트/파싱/컴파일 오류를 계속 거부한다.
- Windows EXE·macOS ZIP·Linux 실행 파일과 aggregate manifest가 exact 같은
  commit/tree를 가리키며 해시 재검산 PASS.
- macOS 무인자 격리 smoke가 StartMenu까지 도달하고 retail 사용자 데이터 전후
  해시가 같다.
- `full_rc`는 active가 되지만 사람 gate 12개, 원고 사용자 최종 서명, A/V·패드·
  원어민·재미 판정은 OPEN이다.
- 변경 파일 밖 drift 0, dashboard/context/queue/human/audit selection/diff PASS.

## 사람 판정과 종료 경계

이 오더는 사람에게 판정할 동일 후보를 만드는 자동 L1/L2다. 발급 뒤에만 exact
후보에서 ORDER-107·109·112·118 원고 사용자 최종 서명과 full A/V·240주 사람
판정을 요청할 수 있다. 자동 완주나 패키지 성공을 사용자 GO로 기록하지 않는다.
ORDER-124 BUILD `2026.08.24.3`의 story-first 구조 판정은 별도 후보에서 병행하며,
그 결과로 full_rc identity를 조용히 바꾸지 않는다.

## 규범 판정

clean source·고유 BUILD_ID·aggregate manifest·exact 후보에 사람 evidence를 묶는
규칙은 기존 `BUILD_PIPELINE.md`와 `human_gates.json` 계약의 적용이다. BUILD 번호,
기준 commit, artifact 경로·해시, 격리 로그는 이 오더에서만 유효한 일회성 증거다.
