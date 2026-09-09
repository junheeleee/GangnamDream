# ORDER-215 — 자각 모달 입력 수리

> [x] 완료 — 작성자와 다른 최종 검수에 따른 작업 단위 GO. 본편 전체 HOLD.

기준 eb8f7aaa825491905294822c468b1f0820b9f345, 선언
6c8cc6cee0679095c8631cfa4e4418dcb493c4cf. 원격 CI34316116861의 W18 빈
modal_kind 실패는 실제 제목 로그가 없어 소스상 원인 후보로 남긴다. 이번 재현은
그 CI의 전체 입력열 재생이 아니라 career8을 준비한 controlled W17 fixture다.

## 구현과 독립 확인

MainGame은 기존 자각 창과 Continue에 종류·소유 metadata만 추가했다.
점수·산문·효과·주차·라우팅은 바꾸지 않았다. QA는 아래 결과/보드보다 현재 모달을
먼저 판별하고 그 창의 유일한 확인 버튼에 raw South/Enter를 보낸다. 모르는 창,
종류 누락, 잘못된 소유자, 확인 버튼 누락·중복을 통과시키지 않는다.

Rawls 구현·자체 검사 뒤 ROOT가 제품 3파일 diff와 실제 호출부를 읽고 동일한
최종 파일로 KO gamepad 및 EN keyboard component를 각각 실행했다.
Godot4.6.2.stable.official.71f334935, Apple M1 Max/OpenGL 환경이다.
8→12에서 자각 확인 동안 상태 불변, 이후 결과 한 번·신청 영수증 한 개·W17→18,
4→8에서는 모달 없음, malformed6 반례를 두 장치에서 확인했다.
stdout와 각 격리 Godot log 모두 아래 성공 marker 및 오류0이다.

`CORE_LOOP_V2_MODAL_PRIORITY_OK ... fixture=controlled-w17`

| 입력 | 로그 bytes | stdout/Godot log SHA256 |
|---|---:|---|
| KO gamepad | 5565 | a3f6703630096cc978749a9660c5a267b00dea3c1caede9c9473b6a5415874a0 |
| EN keyboard | 5567 | d1b1700112c993d6053ccca5a4ba77bb2296a2115876f3763e55578084a4f107 |

ROOT 로그는 원본 저장소 `.git/full-game-localization/order215-root-{ko,en}.log`다.
구현 동결은 `.git/worktrees/checkout2/full-game-localization/`의
order215-implementation-final.json 12389B /
b8490b92147e41f3d3b9651d7af904658e95acc1159f402be9877cbca6252136이다.

검토한 제품 SHA256:

- MainGame.gd: 77c690b8f4f41d9559b6aac25eb78d5de31d42be423dddbd3e889cf3287c67dd
- ScreenshotQA.gd: 155870fb95722cbd1ca8ac01c5a4df414567a5190f48395f7dbe078c5e9b4b19
- wrapper: ede5607f0413a32d1983e5a54f2731e7e73e6a5c58999136b75fbed4fd0a56bc

## 명시 차선 마감

제품 ed8067c에서 core-loop-v2-modal-priority를 --list로 확인한 뒤6개 전부 통과했다.
두 raw 입력 component, queue25/fence4, scope140, context 및 queue 계약을 포함한다.
`.git/full-game-localization/order215-final-named-lane.json`에 실제 출력과 범위를 보존했다.
이후215 제품3파일을 바꾸지 않았다. 다른 오더의 검사를 여기 합산하지 않는다.

## 경계

초기 자체 fixture의 잘못된 tendency_score 속성과 JSON 주차 비교 실패는
수리 전 실패로 보존했다. 성공 marker만으로 앞선 실패를 지우지 않았다.
shell syntax·context·queue·diff 통과. 병렬 변경을 좁은 차선의 소유 범위로 확장하지 않았다.
fresh24주/240주·원격 CI 전체·인간 독해·물리 패드 조작감·재미 GO는 미판정이다.
공개 M01~M06 GO는 보존, 본편 HOLD. 이 오더의 절차·범위는 일회성이고
지속 입력 규칙은 기존 INPUT_UX의 의미 입력 소유를 따른다.

## 작업 단위 최종 판정

판정 source: 3ab1391ff476bbb8a857e12dc0a6267de0ac1123,
tree23c66e2e4fea39bf81dc7573a8aeabb9ad3ba760.
최종 차선 실행96c0db4417ad188478632af6dbb93a093675fe67에서 이 source까지
차이는 CLAUDE 현재 상태 한 줄뿐이다. 제품·검사·번역·portable·인간 원장은 불변이다.
CLAUDE 표적 검사7개도 통과했다(서로 다른 품질 표본으로 합산하지 않는다).

입력 실행 자체는 위 ed8067c에서 수행했다. ed8067c→판정 source의 전체
변경 목록에서215 제품3파일 차이가0이고 위 SHA도 같음을 확인했다.
C3에서 실행한 것으로 다시 쓰지 않는다.
판정: **ORDER-215의 controlled W17 자각 모달 입력 수리 범위 GO**.
작성자 Rawls와 다른 ROOT의 소스 검토 및 실제 엔진 표적 관찰이 근거다.
필수 잔여0이며 원격 실패의 원래 전체 입력열은 재현 완료로 올리지 않는다.
인간 원어민/플레이/물리 조작감 및 전체 품질은 이 판정으로 발급하지 않는다.

## 선언 사양 원문 — 아래 상태는 착수 시점의 역사

활성 사양은 원형 그대로 보존했다. 위 완료 판정이 현재 작업 상태다.
아래 파일 소유·수량·순서는 이 작업의 일회성 지시이며 새 작업의 권한이 아니다.

```markdown
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
```
