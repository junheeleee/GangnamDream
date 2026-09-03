# Active Queue Spec: ORDER-152

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-152 [P0·화자 표시] M51 혼합 대화의 초상 이름표를 실제 발화와 혼동하지 않게 한다

**[~] 2026-09-03 Codex 착수 — 아래 파일만 소유한다.** 사용자의 다음 수리 순서
승인에 따른 작은 결함 배치다. 기준은 review `042f5ea2bac73d27479922bc5f5051c2ad637355`,
제품 `2f91f4265613e57c8e3aaf34ab4f7f0971699f92`다. 기존 detached replay는 수정하지 않는다.

## 근거와 깊이 3문

1. **무엇이 틀렸는가?** `arc_y5_after_goal_daeun`의 민준 직접 질문에 다은 이름이
   표시됐다. 이름표는 초상 인물에서 추정되지만 두 사람이 말하는 산문이다. 기존
   `nameplate_role=hidden` 계약을 이 장면에 명시해 초상과 화자를 혼동하지 않게 한다.
2. **진료실도 같은 원인인가?** 아직 아니다. `arc_y5_burnout_check_reference`는 이미
   hidden 계약인데 의사의 도입 발화에 민준 이름이 관찰됐다. 실제 저장 이력의 root,
   loaded 계약, 실제 StoryMode의 문단·언어 전환·선택 전후를 먼저 재현한다.
   실패 증거 없는 공통 런타임 변경은 하지 않는다. 미재현이면 미해결로 남긴다.
3. **선택의 대가가 바뀌는가?** 아니다. 원고·선택 index·효과·영수증·주차·관계는
   바이트 보존한다. 이야기 밀도나 정점을 수정하는 배치가 아니며 이름표 문제를
   덮기 위해 초상·대사·선택을 삭제하지 않는다.

## 소유권

- `content/meta/story_rules.json`: 위 두 exact root의 presentation만. 진료실은
  재현 결과가 뒷받침하는 경우에만 수정하며 기존 hidden 의미를 약화하지 않는다.
- `scenes/StoryMode.gd`: 이름표 visibility·언어 갱신·선택 dock 복원 경로만,
  새 표적 검사로 기존 코드의 실패와 수정 후 통과가 입증될 때만 수정한다.
- `tools/StoryNameplateCheck.gd`, `.tscn`, `.gd.uid`: 격리 저장 공간의 실제
  StoryMode 표적 검사. KO/EN, 도입의 각 문단, 선택·결과, 언어 갱신,
  이전 장면의 이름표 잔류와 숨김/일반/원격 대조군을 확인한다.
- `tools/StoryNameplateBootstrap.gd`, `.gd.uid`,
  `tools/run_story_nameplate_check.py`: autoload 전에 새 QA 저장 경로를 고르는
  SceneTree bootstrap과 전용 실행기. 엔진 종료·성공 표식·오류를 함께 검사하고
  stdout 및 엔진 로그를 보존한다. 기존 선택기 변경 없이 이 실행기를 등록한다.
- `tools/audit_scope.json`, `tools/audit.sh`: 새 표적 검사 등록과 실행 한 건만.
  선택기 코드·기존 검사 범위·실패 기준은 바꾸지 않는다.
- 파생 원장의 현재 source hash가 실제로 영향을 받으면
  `tools/year5_reference_route_audit.py`의 현행 참조 영수증과
  `content/meta/{chapter5_causal_ledger,release_content_inventory}.json`의 해당
  source observation만. 역사 상수·기준선·게임플레이 원장은 수정하지 않는다.
- 실제 영향 검사에서 검출된 현행 snapshot 세 곳만 추가 소유한다:
  `tools/full_game_runtime_trace_audit.py`의 `AUDIT_RUNNER_SHA256`,
  `tools/full_game_volume_baseline.json`의 `story_rules.json` source hash,
  `tools/chapter1_core_loop_v2_causal_ledger_check.py`의 같은 파일에 대한
  새 exact 후속 관측(기존 ORDER-151 전후 tuple은 보존).
  보호 코드의 실제 diff를 검토한 뒤 현재 관측값만 갱신하며, 역사 영수증·
  볼륨 debt 30건·밀도 수량·인과 원장 행·검사 기준은 바꾸지 않는다.
- 기록: 이 사양, `docs/{CODEX_QUEUE,WORK_LOG,DEMO_FIXLOG,STATUS}.md`, `CLAUDE.md`.
  `docs/human_gates.json`은 상태를 바꿀 필요가 있을 때 후보의 재수리 상태만 갱신하며
  사람 gate OPEN·full/main/product HOLD와 기존 독립 사람 증거를 그대로 보존한다.

## 비소유와 남은 작업

공개 M01~M06 `story_demo_rc` BUILD `2026.08.31.1`의 산출물·GO, 사용자 main과
`project.godot`, 원본/재플레이 저장, 이벤트 원고·경제·엔딩·M55 복장·W240 발신은
비소유다. 오전 진료실/점심 식당/역/오픈하우스 및 생활 vignette의 배경 결함은
별도 후속 배치로 분리한다. 입력 잠금 문제를 근거 없이 게임 코드 결함으로 고치지 않는다.

## 검증·완료 경계

- 기존 코드의 실제 실패 출력을 보존한 뒤 수정하고 같은 표적 검사를 다시 실행한다.
- context manifest, story consistency, 영향 선택 검사, KO/EN 표적 렌더,
  `git diff --check`, 원고·효과 불변을 확인한다. 원본 저장을 쓰지 않는다.
- 진료실 원인 미확정, 배경 후속, Property M52~M60 미관찰을 각각 명시한다.
- 이 배치의 L1/L2는 정상 속도 인간 플레이나 재미 판정을 대신하지 않는다.
  새 전체 재검토 후보는 남은 차단 수리와 통합 검증 뒤 별도로 봉인한다.

**규범 소유권:** 인물·채널·표시 사실은 기존 `STORY_CONSISTENCY_SYSTEM.md` 및
`story_rules.json` 계약을 적용한다. 이 배치의 파일 소유권·표적 검증·신원은 일회성이다.
