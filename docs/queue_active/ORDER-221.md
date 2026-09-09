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
