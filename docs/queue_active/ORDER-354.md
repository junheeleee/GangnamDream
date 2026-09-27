# Active Queue Spec: ORDER-354

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-354 [표시] 다이사이·카지노 허브의 안전 여백을 확보한다

**[~] 2026-09-27 Codex 착수 — 만지는 파일: 아래 두 표시 파일·신규 private 검수와 마감 문서만.**
303의 실제 CN/TW 14화면에서 발견한 결함의 별도 수리다. 303 최종 독립 기록을
먼저 보존하고 구현한다. 선언 당시 제품 baseline은 `2dc1e9f`이며 착수 commit 뒤
clean source를 다시 관측한다. 최초 실패·성공 증거와 기존303 판정을 바꾸지 않는다.

## 깊이 3문

1. 제거 손실: 화면 가장자리에서 현금·규칙·나가기 또는 허브 안내가 잘릴 위험이 남는다.
2. 장기 상태: 표시 여백만 바꾸므로 금전·저장·로그·선택·무작위 수열의 차이는0이어야 한다.
3. 경쟁: 상단 여백을 늘려 하단 베팅/복귀 행동을 밀어내지 않는다. 테이블의 빈 여백을 조절한다.

## 한 배치

- `scenes/DaiSaiTable.gd`, `scenes/JeongseonCasino.gd`의 표시 배치만 수리한다.
  실제 논리 canvas의 2.5% 안전 사각형 안에 노출된 제목/현금/규칙/나가기와
  모든 실제 행동 버튼·안내를 둔다. 배경은 cover/full bleed를 유지한다.
- DaiSai 초기/굴림/승리/다음선택/패배의 서로 다른 높이를 고려한다.
  top inset 때문에 하단이 잘리지 않도록 빈 padding/separation을 조정한다.
  글꼴·버튼 크기·문장·번역·베팅/입력/수치 계약을 축소하거나 바꾸어 통과시키지 않는다.
- 새 메커니즘이나 다른 게임 화면을 확장하지 않는다. 이미 중앙에 있는 문자열의
  넓은 control rect와 실제 glyph 노출을 구분하며 장식 테두리도 화면에서 잘리지 않게 한다.
- 303의 전후 typed 상태·11키/22값·15소비자·7화면/지역·24raw 계약을 그대로 다시
  검증한다. 최종 CN/TW 14 원본 PNG를 root와 비저자가 전수 확인하고 안전영역
  사각형을 독립 계산한다. 예전 helper는 동결하고 새354 helper로 차이만 이관한다.
  목표 해상도1280×800, 기본 글자; 한영/다른 해상도/물리 조작감은 새 관측으로 세지 않는다.
- 모든 비표시 함수와 제품 locale/저장/확률/정산 변경0을 source diff로 확인한다.
  새 UUID pre-autoload 격리·root 단독 순차 실행·실제 사용자 두 루트 전후 census와
  exact marker/exit0/3로그 오류0·실패 보존은 기존 절차를 따른다.

## 파일 소유권

- `/root/header_layout`: 위 두 runtime 표시 파일만. 관련 UI 프로필을 다시 확인한다.
- `/root/screen_path_probe`: `.git/full-game-localization/order354-status-observer.gd/.tscn`,
  `order354-oracle.json`, `order354-validate.py`, `order354-oracle-*` 신규 helper/증거만.
- `/root/screen_independent_review`: `order354-*review*.json` 독립 사전/최종 보고만.
  제품/검사 저자가 아니며 새source를 직접 관측한다.
- root: 큐/이 사양→완료 archive/WORK_LOG/STATUS/CLAUDE 현재 한 행,
  agent ledger의 새354와303후속 행·독립 보고 정확복사,
  새 private `order354-render.py`, `order354-render-*`, `order354-check*`, `order354-root-*`.
- `project.godot`, 인간 원장, 기존 보고·helper, 공개 패키지, 이야기·locale·금전 계약은 비소유.

## 마감·한계

표시 diff가 요구하는 audit_select 표적 검사와 위 원래14화면/24raw를 실행한다.
안전 여백 필수 결함0·독립 작업한정 GO 뒤354를 닫고303 원래 범위의 후속 판정을
별도 추가한다. 옛303 REWORK를 고치지 않는다. 현금 표시 검사는 재미/출시 승인이 아니다.
302 successor package·본편 HOLD, 공개GO1·인간OPEN45·공식40299/b136/meta9·보류72 유지.
정상 title ingress·자연 완료 굴림·MainGame/logviewer 실제화면·원어민·인간·물리패드·
오디오·다른해상도·패키지는 미관측이다. 규범은 일회성/기존 INPUT_MATRIX·WORK_UNIT 적용.
