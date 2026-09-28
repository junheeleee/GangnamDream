# Active Queue Spec: ORDER-382

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-382 [P0·UI 수리] 영어 경력란의 긴 직업명·승진 정보를 모두 읽게 한다

부모381/157. 2026-09-28 착수 — 아래 파일 소유를 확정하고 선언 뒤 구현한다.
제품 기준 `b9b5c3d1cb3c6fd177cd8e03aed7fac2086b9032`, 관측 clean `a332f746636e677a4b77d9d97d08353bcf0addc1`.

## 깊이 3문·한 배치
1. 지우면 영어 취업창의 현재 경력에서 승진 정보가 잘린 채 남는다.
2. 24주 차이는 없다. 직업·승진·급여 수치는 보존하고 현재 정보를 온전히 보여 준다.
3. 직업명을 줄이거나 글자를 작게 하지 않고 기존 label의 줄바꿈 기능만 사용한다.
381 실제 `en-jobs-t3`의 `Public Agency Contract Worker · Tier 3 · Promotions 1/3`은
372px/288px, KO207/JA261/CN244/TW259px는 같은288px 안에 들어왔다.
원본 `.git/full-game-localization/order381-screen-first`는 전체FAIL 그대로 보존한다.

## 확정한 정확한 파일 소유
- 제품: `scenes/MainGame.gd`의 `_build_job_status_strip()` 재직 branch 한 곳,
  `status_box.add_child(_label(` → `_wrap_label(` 한 토큰만. 같은 기존 helper의
  WORD_SMART/clip=false/EXPAND_FILL 사용. 원문·번역·15px·레이아웃 열 폭·경제·입력 불변.
- 호환: `tools/main_game_locale_history.py`에 실제 새 product commit/parent/tree/blob/
  whole raw와 한 토큰 exact inverse 증명. 기존381 함수·핀·원형 본문 보존.
  381의 HEAD blob 증명을 과거 raw에 단순 호출하거나 새 핀으로 덮지 않는다.
- 검사: `tools/ui_translation_append_self_test.py`에 해당 successor의 표적 반례만,
  `tools/audit_scope.json` 등록. 호출 위치/의미가 같아 pipeline·append 수정은 기본 비소유.
  추가 경로가 실제로 필요하면 먼저 새 범위를 선언한다. 모듈 연쇄를 추가하지 않는다.
- root: 사양/완료 archive·큐2·CLAUDE 현재행·WORK_LOG/허용 history·생성 STATUS·
  새 agent 보고/원장·private382 증거. 독립 비저자 검수, root 단독 격리 엔진 실행.
착수 선언 commit 뒤 구현하며381 frozen helper/report와 인간 원장은 바꾸지 않는다.
실행 역할: root는 제품1곳과 문서·판정 정리, compat357은 위 도구3파일,
screen_path_probe는 private382 관찰기/실행기만, r3_route_probe는 독립 비저자 검수.
root만 격리 엔진과 수용 명령을 실행한다. WORK_LOG의 오래된 완결 항목은 필요 시
`docs/history/WORK_LOG_2026-09-07_localization.md`로 바이트 보존 이동한다.

## 검증·한계
- 실제 EN T3의 전체문구·행수·높이·후속 카드/하단 영역을1280x800에서 확인한다.
  기존5언어 T3를같은준비로관찰하고 inputrouting불변을 실제변경영향으로결속한다.
  두 줄 적합성은 아직 미측정이며 추정으로 PASS하지 않는다.
- 새 focused/currentguard·영향 consumer normal·registry/context/queue/diff만 우선.
  변경 없는 역사 self/전체감사/240주 반복0. 첫 실행 원문·실패·시간·source/player 불변을 남긴다.
- 전역모달·자연게임플레이·인간/원어민/물리패드·새package 완료를 주장하지 않는다.
  공개GO1·인간OPEN45·본편/새package HOLD. 외부출시·스토어·지출·법률 권한 없음.
이 exact범위·검사계획은 일회성이며 새 상시규범은 아니다.
