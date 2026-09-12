# CI 감사 실행 스크립트 지문 정합

#### [~] ORDER-247 감사 실행 지문 수리

[~] 착수 — 2026-09-12, Codex. 기준 clean HEAD
`a687a3645a5de8d81bbe54565ecc193d54ba70e6`. 기존243/244의 원인에 합치지 않는
일회성1원인·고정25대조·1배치다. 제품 런타임·번역문은 바꾸지 않는다.

## 관측과 깊이3문

exact41 원격 main34691376114·mirror34691376116은 둘 다 failure다.
실패 flag는 `FULL_GAME_RUNTIME_TRACE_SELF_TEST_EXIT`와
`FULL_GAME_RUNTIME_TRACE_CONTRACT_EXIT`이며, 두 원인은 모두 전체 `tools/audit.sh`의
expected af026c51/got784d936d 지문 불일치다. compile68 각PASS와 skipped 후속 입력,
업로드 파일0을 원형대로 보존한다. 기존243/244의 로컬 통과는 원격 전체 통과가 아니다.

현재 audit raw79946B/c906ff8b은 옛 sealed79593B/af026c51에 검사 등록과 실패 전파만
더한 것이다. 당시41의79864B/784d936d에서245의 주석·successor 명령82B가 더해졌다.
정책·teardown4블록과 runtime5파일은 원형이며, 검증 뒤 단일 현행 지문만 갱신한다.
옛 후보 허용목록·역사 어댑터·실패 필터·항상 성공하는 우회는 만들지 않는다.

없으면 정당한 검사 등록이 원격 전체 CI를 계속 막는다. 선택·24주 상태·1년/5년
게임플레이는 변경0이다. 남은 칭호 번역과 경쟁하지만 현재 검증 기반 결함부터 닫는다.

## 소유 파일

- ROOT: `tools/full_game_runtime_trace_audit.py`의 `AUDIT_RUNNER_SHA256` 단일 상수와
  근거 주석만. 기존 guard6976B/97d8060e·self50689B/a4048afd 원형 보존.
- ROOT: `tools/audit_scope.json`에 두 trace 검사 의존 `tools/audit.sh` 등록과
  명시 전용 `audit-runner-seal` 차선. 기존 자동 차선·실행 코드·기대값은 변경0.
- ROOT 운영: `CLAUDE.md`, `docs/CODEX_QUEUE.md`, `docs/CODEX_QUEUE_L3_PENDING.md`,
  본 사양·`docs/queue_archive/ORDER-247.md`, `docs/WORK_LOG.md`, `docs/STATUS.md`,
  `docs/queue_backlog/FULL_GAME_LOCALIZATION.md`, `docs/agent_review_decisions.json`,
  `docs/agent_reviews/ORDER-247.json`. 245/246 완료 상태만 현재 문서에 반영한다.
- Rawls의 private 고정25는 선언 전 준비한 입력 그대로 사용한다. Poincare는
  저작 없이 코드·원형·실행 결과를 전량 읽고 별도 최종 단위를 판정한다.

`tools/audit.sh` 자체·추적 runtime/profile·게임플레이·KO/EN·UI3·수용38698/b100/meta9·
인간 원장·`project.godot`·손상 로컬 mirror는 변경0이다. 새 실패는 별도 범위다.

## 구현 전 고정과 검증

private `order244-runtime-trace-seal-controls.json` 32042B,
SHA `ab3e1a82d8e370915eff2105105aad26849351f86cff72e1602b5c51493eeb14`와
driver12546B/`51bb111851ee0518ff5013cccd19a576c60977b19f96e04b86b738367ab088a1`를
그대로 쓴다. 파일명의244는 준비 시점일 뿐 이 수리를 기존244 범위에 넣지 않는다.
현재 정상1·기존 변조20·옛 raw/실패41 raw/exit 초기화/집계 제거4의25다.
선언 commit 뒤 baseline25를 먼저 관측하고 stdout·stderr·exit·입력 전후 지문을
전량 저장한다. 정상 실패 상태에서 변조 거부를 유효 PASS로 세지 않는다.
상수 수리 뒤 같은 입력25를 실제 guard로 검사한다. 대부분 whole hash에서 거부되므로
이를 깊은 의미 guard25개를 독립 실행한 것처럼 표현하지 않는다.

최종 영향 검사는 명시 차선 self·normal·등록과 상시 context·queue의 고유5개다.
기존 runtime/locale 입력은 raw로 비교하며 old245 언어 전량·Godot·로컬 full audit는
재실행하지 않는다. 독립 검수와 새 clean source/review 신원을 발급한 뒤 사용자 요청
동기화 범위 main/원격 mirror를 FF해 새 exact CI를 각1회 요청한다. 원격이 아직
미완료이거나 실패면 이를 성공으로 닫지 않고 상태와 다음 실제 범위를 남긴다.

자동 PASS는 계약·회귀 증거이며 재미·문체·화면·원어민·인간 실플레이·본편 GO가 아니다.
공개 GO1·인간 OPEN45·본편 HOLD를 유지한다. 작업 제한은 일회성이며 새 규범은 없다.

## 구현·최초 대조

선언 `52b3af4b445233831cb3a39e6a46ddb03ee0fa43` 뒤 baseline25를 실행했다.
정상 current는 REJECT·옛 sealed raw는 PASS였고 유효 negative는0이다. 첫 원형
`order247-baseline-first.json` 47751B/80d57c938c95795d1b48ba0349d4cf2966d51f56b8365f8a8d435261697ad562,
exit1/0.745초/실제25call·입력4 전후exact를 보존한다.

검사기는 단일 지문+출처 주석만4추가/3삭제다. 현171119B/b49b282d를 되돌리면
기존171037B/f74c8265이며 guard/self·실행 AST 나머지는 원형이다. scope26추가줄은
명시 차선24와 source의존2뿐이다. audit raw c906과 제품·번역은 변경0이다.
같은25 첫 post는 정상1PASS/변조24REJECT·입력4 exact, exit0/0.773초다.
`order247-post-first.json` 47853B/e6f72b36c869513524a7a8543d6c9713d090c93a707c5f5e8a2f4102e23a0afe.
고유 입력은25이며 baseline+post를 새50개 검사로 세지 않는다. 최종 명시5·독립
단위판정·새 exact 원격 CI는 아직 남는다.

## 표적 검사 후보

제품 `a486c2473ed8bce8e5e43ba847b599fffd4c4297`/tree488018a551b24e26fac45333a8bd322b9134d721,
검토 `543940993a8e15b7734861b1537d0741bbad9f23`/tree5ab265f3172bfe68643bf1a8b3dda67a978ec644.
Poincare의 code/post 전량 검토는 필수0이며 private `order247-code-review.json`
9737B/5d3bee7762a53027d22a3751d701f7c662cd711b41da899af29d7cf081019d72다.

첫 명시 capture는 기존 context 중복 등록을 누락으로 오인해 child0에서 준비 실패했다.
원형 `order247-named-first.json` 59421B/ee6ca9206053990595a464932e9c85eec1144f5201f16961960ca62b4ce74964를
보존했다. 입력 before 미획득에 따른 changed 목록은 실제 파일 변경 증거가 아니다.
별도 수리 driver는 표준 selector의 first등록 선택과 고유5 가드를 그대로 썼다.
같은 clean 검토 후보의 최초 실제5는 전부 exit0,1.887초/입력246 전후exact다.
`order247-named-after-selection-fix.json` 95548B/1cdd40d02e9d97c3ab45ab8a98b9337bc082c515e44d3d12fa936f28a112755c.
trace self187·일반profiles3(PENDING)·등록145/guard6/EXTRA17·context363·active78이다.
선언52 대비 소유 밖2667개 Git blob은 exact다. 로컬 전체 감사·Godot·번역전량 재실행0.
원격 CI와 최종 단위판정은 여전히 별도이며 기존41 failure를 GREEN으로 바꾸지 않는다.

원격 후보 `07ef0f750abe97d6c671d27a6f638938b15658a7`/tree8cdc0a90948195ab0cc76a80a86e7c87f6f9b315는
Poincare local pre-CI 검토 필수0(`order247-local-pre-ci-review.json` 12296B/7cc3d620)을
받았고 sourcea486에 결속됐다. main/원격 mirror를41→07ef로 atomic FF했다.
새 run은 main34696178566·mirror34696178468, 시작13:20:53Z이며 첫 관측 둘 다
in_progress다. `order247-ci-first.json` 26918B/6d159998 원형을 보존했다.
실제 원격 완료·최종 단위GO는 아직 아니다. 다음248은 private 준비만 병렬 진행한다.
