# Completed Queue Spec: ORDER-354

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [x] ORDER-354 [표시] 다이사이·카지노 허브의 안전 여백을 확보한다

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

## 2026-09-27 완료 — 표시 수리의 작업한정 GO

- 두 `_build_ui`의 foreground를 2.5% inset으로 배치하고 다이사이의 세로 빈
  padding/separation만 줄였다. 나머지52/40 함수·서체·버튼·문장·입력·금전·저장·RNG는
  그대로다. 1280×800 안전영역 `[32,20,1216,760]`, 다음선택 패널 bottom804→774.
- 실제 실행 `85c5295a5ecc0d66caa357996c3141f3379270fd` / tree
  `d413dd760926048583a971973f73a3663619c13a`: CN/TW 각7원본PNG·12합성 키보드 edge,
  두 실행 모두 exit0·정확 marker·3로그 오류0·격리 namespace와 사용자43파일 불변.
  원본14장은 root와 비저자가 전수 읽었다. 각 지역250개 노출 행동 사각형을 대조했다.
  `order354-check-accepted-bindings.json` SHA
  `592b7c0967dbc4e58acddc004b69539dcbd9814544f4eb448152ddaa03f3ee28`, 음성72개 거부.
- 최종 검수 source `2d3fb7a8360c5f9308748c02928f33a61186fdb3` / tree
  `c6f9dc54cb0efe42c04a4325b3b4590d3b31c0b1`. 실행 뒤 CLAUDE 현재 행만 바뀐
  차이를1244/1245핀으로 결속했다. 이 최종source에서 엔진/이미지를 재실행한 것은 아니다.
  [독립 보고](../agent_reviews/ORDER-354.json) SHA
  `8ddcdb7cdb8d4cd27f8939d56b1a7c8a15de2b60f6844e5c331ba06b9188b71b`:
  SAFE-01/FIT-02 해소, 필수 범위 결함0, 작업한정 GO. 기존303 REWORK는 원형 보존한다.
- 표적22검사는 **15 PASS / 7 FAIL**이다. 요약 `order354-check-selected-summary.json`
  SHA `9f713543e9690ce4811f6933a17f3588c2a6535b0a34368a4ff9d0f4ace6f84a`.
  최초4개 static은 `5ca8741`의 두 표시 파일 dirty 상태(최종 제품 바이트와 동일), 나머지는
  clean `85c5295`다. 전체를 최종 clean source에서 통과했다고 쓰지 않는다.
- 미해결 의무: 등급 inventory 기존3내용핀, JA/ZH 비교기의 기존 KO 원문 계약 불일치
  (ZH self-test12530 자체는 PASS), liveness의 `.git` 사설42파일 오탐, InputMatrix의
  종료 ObjectDB/3resource 경고, ControllerSemantic의 원인 미확정 ObjectDB 경고.
  InputMatrix의 같은 수량 역사 기록은 있으나 exact 자원 신원은 미확인이고,
  ControllerSemantic은 기존 결함이라는 인과 증거도 없다. 7 FAIL을 면제하지 않는다.
  각각 원문 호환 비교·inventory 사실 동기화·스캐너 경계·격리 수명 조사로 별도 선언해야 하며
  이 표시 수리에 끼워 넣거나 역사305/310/316·공개 핀을 갱신하지 않았다.
- 개발 스킬의 선언·소유 분리·격리·표적 검증·비저자 검수를 적용했다. 규범은
  일회성/기존 INPUT_MATRIX·WORK_UNIT 적용, 새 승격0. 자동 게이트는 계약 증거이지
  재미·문체·깊이의 판정이 아니다. 앞 절 미관측·공개GO1·인간OPEN45·본편/새package HOLD 유지.
