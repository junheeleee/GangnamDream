# ORDER-221 — CI 설치 단계의 checkout 격리

> [x] 완료 — 정확 소스의 CI 격리 수리만 위임된 내부 작업 GO다.
> 로컬 mock·표적 검사 통과를 새 원격 CI 전체 PASS나 본편 GO로 합산하지 않는다.

## 정확 소스와 변경 범위

선언7b04b9d676a611bc3d634da3da84f293298bfd47 뒤 제품을
2c972f6de7d58f83a9fc0a616ca4b08b72b482ff,
tree b7f9cc74a700e8bd2537bba2156f3c5d50adcbc4로 동결했다.
검사 HEAD14c15ad0e9035b086f29b217c3d095f813c4ec45는 generated STATUS만의
문서 wrapper다. ROOT가 구현하고 Rawls가 독립 고정8개를 검증했다.

실제 제품 diff는 .github/workflows/ci.yml의 Godot 설치 step에
working-directory: runner.temp 한 줄46B, audit_scope의 명시 차선1개,
CLAUDE의 현재 CI 사실행1개다. 설치 run body와 뒤7개 run step은 그대로이며
checkout 기본 cwd를 유지한다. 뒤7개 실행을 했다는 주장은 아니다.
workflow 전4531B/283f2df07e4d13e382852f3e085e5369c7b1330df1880b530fe8b13e953252ec,
후4577B/10b1c91fbf63a98b015ebb4a976299d7bf4557aa2d8218769d0b37915b42d786.
한 줄 역제거로 원형 raw가 일치한다.

## 원래 실패를 보존한다

[기존 원격 run34336769751](https://github.com/junheeleee/GangnamDream/actions/runs/34336769751)은
c0dac746의 결과다. 정적 job102417888660은 success, Godot job102417889033은
STATUS_DOC_EXIT 때문에 failure다. COMPILE_CHECK_OK total=68은 관찰했지만
뒤 V2 KO/EN·SimRun·SmokeRace는 skipped였다.
원격 로그는 새 수리의 통과 증거가 아니다.

checkout에 남는 untracked godot.zip은 정확 소스 resolver를 None으로 만들어
저장된 clean STATUS와 다르게 만드는 충분조건이다. 원격 전체 git status가 없으므로
유일한 오염 경로였다고 단정하지 않는다. Rawls의 구현 전 원인 재현4와 고정8 사양은
private ci-status-34336769751-independent-diagnosis.json10513B/
c556bf7070c477a28b941f10f0b6be43bd0684fba1f957d34ad724aca5d7367a에 남긴다.
그때 재현4와 이번 고정8을 독립 표본12로 더하지 않는다.

## 실제 검증과 한계

Rawls는 현재 YAML run block 그대로를 /bin/bash -e와 격리 mock4개로 실행했다.
고정8 모두 기대 충족, 예상 밖 실행 실패0, 필수 결함0이다.

- 옛 checkout cwd: 설치 명령은0이어도 ZIP이 남아 subject None. 원래 실패 보존.
- runner.temp·공백 포함 temp·추가 README archive: checkout 상태와 source 유지.
- tracked 제품 변경·다른 untracked 파일: 여전히 subject None.
- STATUS-only 변경: 원래 제한 예외 유지.
- curl 의도 실패42: unzip/sudo/godot 미도달. 별도 unzip 실패를 추가 검사한 것은 아니다.

private order221-independent-ci-isolation.json28559B/
fd3fc790381c4729180f201f6ae0d90c51df453d9069d260e05f87788a9fe84d가
기대값·각 git 전후·명령 trace·실패 stderr와 한계를 소유한다.
실제 다운로드·archive 추출·sudo·엔진·대시보드·Ubuntu 원격 전체 실행은 하지 않았다.

ROOT는 실제 YAML·셸 구문과 단일 step diff를 읽고, 직전 전량 L1의587개 입력이
불변임을 재해시했다. 번역33,711개·기존 UI 제품을 다시 수정하거나 긴 검사를 반복하지
않았다. private order221-root-diff-review.json1853B/
5f46369f3a6665df905c45ac0a1b04e487b4ea95d6d29cd5b2a853c7531ae634.

동결 wrapper에서 명시 ci-checkout-isolation 차선5개를 한 번 실행해 exit0이었다.
scope141·queue index25/fence4·agent self222·context336·queue76/진행74가 통과했다.
**착수 사양의 agent self38은 예상수 오기다. 실제 로그는222이며 기존 파일을
변경하거나 검사를 추가하지 않았다.** 원형 사양을 덮지 않고 여기서 정정한다.
private order221-final-targeted-lane.log1602B/
89fc093113cf88b86539586ec3a705af5af4f3544eb9b5640ec7bef258fcbec4.
장기 causal/year5/L1/Godot을 재실행하지 않았다.

## 판정과 보존

위 독립 재현과 실제 소스 검수로 이 한 수리만 내부 작업 GO다.
source resolver·dashboard·audit.sh·.gitignore를 완화하지 않았고,
전체 human 원장103390B/6ab5c927c9f327aa2892c231d49fe144c1c154cb6069fc539f4f3f8e9c30c9f6,
project.godot4699B/78e98d7bdc1349570df6f2cc7ca6cbb11d4fc5451f5bbfdd338561653c7380c5,
이전7개 agent 기록·공개 M01~M06 GO·사용자 저장·원문/번역/수용은 보존한다.
기존219/220 내부 GO는 소스09bfcde에 그대로 두며 새 소스로 재발급하지 않는다.

마감은 새221만 archive/agent record로 옮기고 이전75개 큐를 raw로 복원한다.
전체 본편 HOLD·인간/원어민/물리/실제 렌더 미관찰은 유지한다.
main·기존 번역 브랜치는 이후 ff 동기화한다. **이 기록 시점 새 원격 결과는 미관찰**이며,
push 뒤 정확 HEAD/run/job를 별도로 확인한다. 미완료·실패를 통과로 추정하지 않는다.

승격: 기존 BUILD_PIPELINE의 clean source·증거 분리와 WORK_UNIT의 위임 판정 규칙이
이미 지속 규칙을 소유한다. 이번 한 줄 수리·파일 소유·고정8·실행 순서는 일회성이다.
새 규범이나 공용 예외를 추가하지 않았다.

## 착수 사양 원형 보존

3916B/e65b70ea1bdce4e8dec94b5bb0f027f3cf8bfda8f58c7aff3eea790bfbe712b6.
아래 진행 상태·검사 예상수는 착수 당시 원형이며 현재 판정은 위 절이 소유한다.

````markdown
# Active Queue Spec: ORDER-221

> [~] 착수 — CI 엔진 설치 임시 파일의 checkout 오염만 수리한다.

#### [~] ORDER-221 [P0] CI 설치 파일과 정확 소스 판정 격리

기준 main59a84b7. 직전 번역219/선택 표시220은 소스09bfcde의 내부 작업 GO로
닫았다. 그 원문·번역·수용·제품을 이 새 작업에서 변경하지 않는다.

## 깊이와 원인

1. 이전 동기화 c0dac746의 원격 run34336769751/job102417889033은 전체 감사 중
   STATUS_DOC_EXIT 하나로 실패했고 V2·SimRun·SmokeRace는 미실행이다.
2. CI가 checkout에 godot.zip을 내려받고 실행파일만 이동한다. 남은 untracked ZIP은
   현행 정확 소스 판정을 None으로 만들어 저장된 clean 현황 문서와 불일치한다.
   Rawls의 격리 Git 재현4가 이를 충분조건으로 확인했다. CI 전체 git status는
   기록되지 않아 유일한 오염 파일이었다고 단정하지 않는다.
3. 설치 단계의 cwd만 runner.temp로 옮겨 download/unzip을 checkout 밖에 둔다.
   소스 신뢰·dirty 거부·공개판 신원은 유지하고 뒤의 게임 검사를 다시 실행할 수 있게 한다.

## 소유와 한계

- ROOT: .github/workflows/ci.yml의 Godot 설치 단계에 working-directory 한 줄,
  tools/audit_scope.json의 명시 ci-checkout-isolation 차선만, CLAUDE.md의 현재 CI 사실,
  docs/CODEX_QUEUE.md·docs/CODEX_QUEUE_L3_PENDING.md의 새221행/순번,
  이 active spec·docs/queue_archive/ORDER-221.md·docs/WORK_LOG.md·generated docs/STATUS.md,
  docs/agent_review_decisions.json의 별도221 내부 작업 기록.
- Rawls: 코드 전 봉인한8개 fixture의 독립 검증과 private 증거만. 제품 쓰기 없음.
- 비소유: human_gates.py·project_dashboard.py·audit.sh·.gitignore·기존69/38 self·
  전체 인간 원장·공개 manifest·모든 원문/번역/수용·게임 소스·project.godot·사용자 저장.
  dirty 허용, ZIP ignore, CI에서 현황 덮어쓰기, broad git clean은 금지한다.
- 선행 읽기: QA·빌드 프로필 필수5문서를 ROOT가 전량 읽었다. 이 작업은 출시·
  패키지·원어민·물리·정상 독해 판정이 아니며 자동 검사 범위를 확대하지 않는다.

## 코드 전 유한 검증

private ci-status-34336769751-independent-diagnosis.json10513B/
c556bf7070c477a28b941f10f0b6be43bd0684fba1f957d34ad724aca5d7367a가 원인과
기대8개를 구현 전에 봉인한다: 옛 checkout cwd 실패, runner.temp 정상, 공백 경로,
추가 archive member, tracked 제품 변경 거부, 다른 untracked 거부, STATUS-only 기존
예외 유지, 설치 명령 실패 전파. mock 설치와 Git resolver만 검사하며 실제 엔진 설치나
GitHub 전체 실행 결과로 부르지 않는다. ROOT는 실제 YAML의 한 단계만 바뀌었는지,
다음 import/audit/입력/Sim cwd가 checkout인지와 587개 번역 검증 입력 보존을 확인한다.

자가 diff·YAML/셸 구문 검사 뒤 Rawls 독립8개, 기존 agent self38과 scope/index/context/
queue의 명시 차선을 한 번 실행한다. 긴 year5·causal·L1·Godot은 반복하지 않는다.
최종 clean 소스의 현황 문서 freshness도 확인한다. 그 뒤 main과 기존 번역 브랜치를
ff 동기화하고 새 원격 CI를 관찰한다. 원격 미완료/실패는 그대로 남긴다.

## 완료 판정

정확 한 줄의 설치 격리와 독립 유한 재현이 통과하면 이 수리만 내부 작업 GO다.
로컬 mock PASS를 원격 CI 전체 PASS로 기록하지 않는다. 원격 결과는 exact HEAD/run/job로
따로 남기며, 새 결함은 다시 별도 소유로 분리한다. 전체 본편 HOLD와 인간 원형은 유지한다.
계속 유효한 clean 소스·증거 분리 규칙은 기존 BUILD_PIPELINE·WORK_UNIT이 이미 소유한다.
이번 파일 소유·고정8입력·정확 cwd 수리·재검 순서는 일회성이다.
````
