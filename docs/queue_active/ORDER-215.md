# Active Queue Spec: ORDER-215

> [~] 착수 — 만지는 파일: MainGame.gd의 자각 모달 metadata, ScreenshotQA.gd, V2 입력 wrapper와 아래 ROOT 운영 파일만.

#### [~] ORDER-215 [P0·CI] 자각 알림의 입력 소유권

기준 제품 eb8f7aaa825491905294822c468b1f0820b9f345, 선언 부모 23724b75b531363aa0b6b3b5b7ee3908a0e13ae4.
실패 CI34316116861/job102352572928는 전체 감사 통과 뒤 KO gamepad W18에서
빈 `_modal_kind`로 실패했다. 실제 제목 로그가 없어 아래 원인은 소스상 후보다.
진단 private/order215-w18-modal-diagnosis.json 18057B /
b100ddb5af1f2b553a87be7a7041ced5fd96c007f379d9fcc33d738bd482bcb8.

## 깊이 3문

1. 모달을 건너뛰면 사용자가 확인하지 않은 자각을 QA가 진행시킨다.
2. 확인 전후의 주차·영수증·효과가 같아야 중복 입력을 숨기지 않는다.
3. 가장 위의 알림과 아래 결과·서울보드 중 현재 입력 소유자는 하나다.

## 범위 — 한 입력 소유권 결함

W1/W5/W17 직접 지원이 career4+4+4를 쌓으면 기존 자각 모달이 열린다.
QA는 현재 모달 검사 전에 아래 result/board를 강제 포커스해 진행할 수 있다.
빈 kind 전부 허용, 모달 제목 문자열 허용목록, 임의 sleep·timeout 증량은 금지한다.

Rawls 제품 소유:

- tools/ScreenshotQA.gd: 모달 우선 판별·모달 소유 Continue에 raw South/Enter,
  알 수 없는 모달 실패와 kind/title/focus/receipt 진단, 작은 component scope.
- scenes/MainGame.gd: 기존 자각 모달의 `tendency_realization` kind와
  tendency_kind/확인 버튼 metadata만. 점수·문구·효과·신호·주차·라우팅 변경 0.
- tools/run_core_loop_v2_input_qa.sh: modal-priority-ko-gamepad 및
  modal-priority-en-keyboard 범위와 별도 성공 marker만 추가.

ROOT 운영 소유: tools/audit_scope.json, CLAUDE.md, docs/CODEX_QUEUE.md,
docs/CODEX_QUEUE_L3_PENDING.md, docs/WORK_LOG.md, docs/STATUS.md,
docs/queue_active/ORDER-215.md, docs/queue_archive/ORDER-215.md.
KO/EN/locale 원고·portable·save·project.godot·workflow·공개 후보는 비소유다.
214/216 병렬 변경은 각 별도 소유·검증이며 이 결과에 합산하지 않는다.

## 표적 검증

실제 W17 신청 확정 경로를 사용하되 시험 초기 상태 career8을 명시하는 component
fixture다. 8→12 자각 모달이 아래 result/board보다 먼저 처리되고, 확인하는 동안
주차·돈·영수증·신청 횟수 불변, 이후 정당한 결과가 한 번만 이어짐을 검사한다.
threshold 미달은 모달 없음, unknown/malformed/소유 버튼 누락·중복은 진단 실패.
KO gamepad와 EN keyboard 둘 다 raw 입력·격리 QA 상태로 실행한다.
GUI unavailable이면 계약/컴파일까지만 기록하고 런타임 PASS를 만들지 않는다.
실행 가능 엔진은 기존 설치 위치를 먼저 찾고, 표적 범위 로그와 성공 marker 및
stdout/Godot log 오류를 함께 검사한다. 주입한 component fixture를 fresh24주,
독립 인간·물리 패드·재미 GO로 보고하지 않는다.

등록 표적 차선 --list 후 실행·diff·shell syntax·context/queue 검사.
새 전체 감사·24주/240주·CI 수동 dispatch는 반복하지 않는다. 제품 로직 변경이
필요한 새 실측은 별도 범위를 먼저 선언한다. 공개 M01~M06 GO는 원형 보존,
현재 본편 HOLD다. 이 오더 지시/파일 소유는 일회성이다.
