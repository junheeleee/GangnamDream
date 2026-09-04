# Archived Queue Spec: ORDER-152

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [x] ORDER-152 [P0·화자 표시] M51 혼합 대화의 초상 이름표를 실제 발화와 혼동하지 않게 한다

**[x] 2026-09-04 Codex 완료 — 아래 파일만 소유했다.** 사용자의 다음 수리 순서
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
- 진료실 원인 미확정과 배경 후속을 명시한다. Property M52~M60은 착수 당시
  미관찰이었으며, 아래 후속 Codex 화면 관찰이 6/6까지 도달한 범위만 갱신한다.
- 이 배치의 L1/L2는 정상 속도 인간 플레이나 재미 판정을 대신하지 않는다.
  새 전체 재검토 후보는 남은 차단 수리와 통합 검증 뒤 별도로 봉인한다.

**규범 소유권:** 인물·채널·표시 사실은 기존 `STORY_CONSISTENCY_SYSTEM.md` 및
`story_rules.json` 계약을 적용한다. 이 배치의 파일 소유권·표적 검증·신원은 일회성이다.

## 부분 수리·검증 영수증 (2026-09-03)

- 선언 `902722f`와 실행기·관측 파일 소유권 보충 커밋 뒤 별도
  `codex/order152-story-nameplates`에서 작업했다. 사용자 dirty main과 exact
  `042f5ea2bac73d27479922bc5f5051c2ad637355` detached replay는 수정하지 않았다.
- 제품 변경은 `arc_y5_after_goal_daeun.presentation` 한 건이다. 민준 질문에
  다은 이름표가 붙는 문제를 기존 hidden 계약으로 고쳤으며 초상은 유지했다.
  전체 KO/EN 이벤트·산문·선택·효과·scenes/autoloads/systems/assets와
  `project.godot`, 사람 게이트는 기준 후보 대비 바이트 불변을 확인했다.
- 수정 전 실제 StoryMode 검사에서 after_goal 156개 실패, burnout 0개였다.
  기준 로그는 `/private/tmp/gangnamdream-order152-nameplate-baseline.ysRMiW/`
  `attempt3-verbose-{stdout,godot}.log`에 있다. 진료실의 화면 관찰 원인은 여전히
  미확정이며 공통 StoryMode에 추측성 수정을 넣지 않았다.
- 최종 표적 L2: KO/EN×두 root×세 선택 12경우, 92문단, 화자 갱신 62회,
  언어 왕복 24회, 일반/원격 대조 20건, 표적 인용문 12페이지, 설정/화자 helper
  없는 경로 4건이 PASS다. 초상 실제 텍스처도 검사한다. 새 실행기는 autoload
  전에 독립 QA 경로를 만들며 종료코드·오류·누수·성공 표식·저장 경로를 함께
  검사한다. 최종 로그는
  `/var/folders/yr/mf2mg8vn7yld9rk4rf3qh2y80000gn/T/gangnam-story-nameplate-_uwdaswu/`의
  `stdout.log`, `godot.log`이며 둘 다 SHA256
  `318cdc0cdaed5032b9162d2bf4194daa9c84f325106b895599fa4e1f9ccc17fb`다.
  전환 중 한 프레임 노출이나 정상 속도 독립 인간 플레이를 검증한 것은 아니다.
- 별도 격리 bootstrap으로 영향 Godot 검사 7개가 기존 판정 기준에서 통과했다.
  StoryPlayback의 기존 156경우·1,044문단, Chapter5HumanReject, 원격 표시,
  업적, 모드, M1M6 및 68-script compile이다. 기존 StoryPresence 종료 누수
  경고는 관찰돼 전부 오류 0이라고 부르지 않는다. 새 이름표 검사는 오류·누수 0이다.
- 현재 원고 해시가 바뀌어 드러난 역사 투영·볼륨/인과 source 관측과 새 검사 등록
  해시는 이 배치의 실제 diff에만 맞춘다. 기존 역사 상수·볼륨 debt·검사 기준을
  느슨하게 바꾸지 않는다. 최초 선택 검사에서 큐 순서 0도 검출돼 1부터 연속으로
  교정했다. 공개 M6 산출물과 GO를 다시 발급하거나 확장하지 않았다.
- 현행 source 관측 정합 수리 뒤 year5 자체시험 233건, 인과 원장 488건,
  runtime-trace 187건, 볼륨 14건이 통과했다. year5의 기존 역사 상수 191개와
  인과 원장의 이전 source map/ORDER-151 tuple은 불변이며 정확한 후속 한 건만
  추가했다. 감사 실행기의 새 이름표 블록과 종료 flag를 역투영하면 종전 바이트와
  같다. 상세 로그는 `/private/tmp/gangnamdream-order152-receipts.Thy6j4/`와
  `/private/tmp/gangnamdream-order152-receipts.ywVdqd/`에 보존했다.
- 최종 `audit_select.py`는 변경 19파일에 대한 43개 표적 검사를 종료 0으로
  통과했다. Godot은 외부 실행기가 같은 pre-autoload 격리 bootstrap을 넣었으며
  테스트별 기존 오류 판정 기준을 변경하지 않았다. 전체 감사/전체 플레이가 아니다.
  로그: `/private/tmp/gangnamdream-order152-impact.Tbg35v/final-impact.log`.
  SHA256: `c779b4a2628a2158be48e2b6dbd94ded03b9c32a0f94051ca116dc2f60986b49`.
- 검사 후 2026-09-03 23:08:24 KST 읽기 전용 확인에서 원본 gameplay 28파일과
  원본/격리 manual slot 1·2가 모두 최초와 같았다(추가·삭제·변경 0).
  원본 manifest SHA256는
  `f8fb9df6f4f75389a73e56c9de1a082eab5c27ba0e28d43f687a1a7c453c1ede`다.
  logs/shader_cache/.DS_Store는 제외한다. Property 프로세스는 아직 열려 있으므로
  이 결과를 종료 후 postflight나 플레이 완료 증거로 부르지 않는다.

### 2026-09-04 후속 완료 영수증

- 기존 exact 후보의 **Codex 화면 관찰**은 두 경로 모두 M49→M60→후일담·6/6에
  도달했다. Property M55 복장/무초상, M58 민서 입장, 무이체와 W240 무응답은
  보존됐으나 W237 익명 보증이 M53 재혁 보증 뒤 중복 진입해 REJECT/HOLD다.
  결혼 체인·비교본 이름표와 생활 배경도 새 범위로 남았다. 상세·한계는
  `/private/tmp/gangnamdream-042f5ea-observation.ZZoJm1/STATUS.md`에 보존했다.
- 최종 `d934741` 실제 화면 표본은 보존 turn-204 저장을 새 사용자 폴더로 복사해
  정상 진입했다. `남는 하루 말고`의 도입, 민준 직접 질문, 다은 발화, 세 선택,
  선택 2의 두 결과와 월말 복귀까지 다은 초상은 유지되고 이름표는 계속 숨었다.
  화면 검사는 별도 격리 bootstrap만 썼고 원본 저장·후보를 수정하지 않았다.
  사후 기록은 `/private/tmp/gangnamdream-order152-screen.Z0Ajrl/SCREEN_OBSERVATION.md`
  (SHA-256 `5f7a9a13d0451375be9761d7e25985bd7915578d394a5d579ccb019308e862f1`)에
  페이지별 관찰·autosave·bootstrap 해시와 독립 인증이 아니라는 경계를 보존했다.
- 독립 리뷰의 의존성·정리 안전 결함도 닫았다. 선택 감사는 실제 StoryMode 장면·
  autoload·두 Chapter 5 route·연도별 초상 원장·두 현수 대조 원고·StoryMode의
  direct preload/style/direction manifest와 `project.godot`을 직접 의존성으로 읽는다.
  전용 실행기는 예측 불가능한 exact namespace를 먼저 골라 bootstrap에 전달하고,
  bootstrap/test 표식이 각각 정확히 한 번 같은 절대 경로와 플랫폼별 userdata
  직계 부모를 가리키는지 확인한다. 별도 process group을 제한 시간 안에 끝낸 뒤
  plain directory를 같은 부모의 격리 이름으로 원자 이동하고 inode/device를 다시
  대조한 경우에만 삭제한다. timeout·실패·unsafe platform에는 삭제하지 않는다.
  KO/EN 12경우·92문단 재통과와 정리 표식은
  `/var/folders/yr/mf2mg8vn7yld9rk4rf3qh2y80000gn/T/gangnam-story-nameplate-nok6hkge/stdout.log`
  (SHA-256 `df2f22cc7f55f6f83afb30056ced5bad9ab4839de9ba558b52a992fe9b078451`,
  `CHECK_OK` 20행·`QA_CLEANED` 21행)에 함께 남는다. 누적 테스트 폴더 25개와
  정리 검증 중 보존된 테스트 폴더 1개도 같은 exact 경계 확인 뒤 제거했다.
  별도 `runner_result.json`은 engine exit `0`, status `passed`, cleanup
  `removed_after_atomic_quarantine`를 기록하며 SHA-256은
  `0fe22fbaf79878697d973babe3c1d843c2cf1be5a102ca517d157515423f510a`다.
  SIGTERM 모의 실행도 wrapper exit `143`, child exit `-9`, 남은 자식 0,
  status `signal_interrupted`로 닫혔고 결과 JSON SHA-256은
  `834e337f06c37b5dd61d36616bf83e5f9fe46139ebfe1c0c441e1aaa02e513a8`다.
- 폐쇄 직전 현재 diff 10경로를 다시 영향 선택한 최종 회귀는 23개 검사를 모두
  종료 0으로 통과했다. 68개 스크립트 컴파일, 이름표 12경우·92문단,
  M01~M06 3경로·28 selector, Chapter 1 인과 self-test 488건,
  Chapter 5 property/general 종막, 공개 데모 패키지 self-test 264건과
  정본·큐·사람 게이트 검사를 포함한다. 로그는
  `/private/tmp/gangnamdream-order152-final-impact.log`, SHA-256은
  `7bfdb3408a0a568f7aea1ef42c5d224310e7e6e24eddd4e1df62726699f7e6bf`다.
  이는 회귀 증거이며 정상 속도 독립 인간 플레이 판정을 대신하지 않는다.
- 배경, W237 보증 충돌, 결혼/비교본 이름표는 각각 새 오더다. 이 커밋은 새 전체
  검토 후보나 사람 GO가 아니다. 두 사람 gate OPEN, full/main/product HOLD를
  유지하며 최종 새 exact에서 두 경로 전체 사람 재검토가 필요하다.
- 규범 판정: 기존 `STORY_CONSISTENCY_SYSTEM.md`의 표시 사실과
  `story_rules.json` hidden 계약을 적용했으며 새 정본 규칙은 없다. 파일 소유권·
  실행 순서·이번 exact 증거는 일회성이다.

## L2 완료 증거 양식

```text
도달 경로      : /var/folders/yr/mf2mg8vn7yld9rk4rf3qh2y80000gn/T/gangnam-story-nameplate-nok6hkge/stdout.log:20 = STORY_NAMEPLATE_CHECK_OK cases=12 pages=92 refreshes=62 locale_roundtrips=24 controls=20 quote_pages=12
생산자 ↔ 독자   : content/meta/story_rules.json:1112 ↔ autoloads/DataRegistry.gd:505 ↔ scenes/StoryMode.gd:5298
바꾸는 상태     : story_rules SHA256 42c966bb45f4339504652b62d78142950c543def289f802355795f293d8689a1 → 35e64bd87c7b88f6c77b1827228bfb594804140d79773b12298e706faf144d69; nameplate_role absent → hidden
포기 시 잃는 것 : arc_y5_after_goal_daeun@W204 + /private/tmp/gangnamdream-order152-nameplate-baseline.ysRMiW/attempt3-verbose-godot.log:412 failures=156
서사 위치       : chapter5.M51.W204
장면 계층       : T2 = content/meta/chapter5_causal_ledger.json:138
닫는 것         : arc_y5_after_goal_daeun false Daeun nameplate failures 156 → 0
```
