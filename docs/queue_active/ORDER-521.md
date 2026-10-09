# ORDER-521 — cold result 재개 이름표 복원

#### [~] ORDER-521 [P1·표시 수리] 저장 결과의 이름표를 원래 표시 상태로 복원

**착수 — 2026-10-10.** [516](../queue_archive/ORDER-516.md)의 실제 resume-fix
이어하기는 같은 result0/정신64를 복원하지만 김민준 이름표가 빠진다.
원앱/저장/실패 증거는 보존하고 source 연결부만 수리한다.

## 한 단위·깊이 3문

1. 없으면 같은 결과를 읽어도 재시작 뒤 누가 말하는지 표시가 달라진다.
2. 선택·24주 상태·저장 형식을 바꾸지 않고 기존 이름표 표시만 복원한다.
3. 강제 이름표 표시와 경쟁한다. cold result에는 앞선 선택 dock이 없으므로
   현재 렌더링한 표시 상태를 캐시해 복원하고 hidden/black_future는 그대로 숨긴다.

## 파일·소유

- root: `scenes/StoryMode.gd`의 `_restore_story_result()`에서 dock 해제 전
  현재 이름표 visible을 기존 cache에 연결하는 1줄과 주석만.
- root: 기존 `tools/StoryNameplateCheck.gd`에 KO/EN named/hidden cold result
  표본4개를 더한다. 실제 일반 선택/숨김/CG/언어 전환 기존24표본은 유지한다.
- root 운영: 이 사양·CODEX_QUEUE·302 잔여·CLAUDE 현재행·WORK_LOG·생성 STATUS·
  위임 원장. private `.git/order521-*` 원로그/보존만 추가한다.
- 비저자 `phone_independent_review`: 소스/반례/수리 결과/전체 보존/clean endpoint 읽기만.
- 원문/번역·flags/효과/라우팅·project·저장/공개본·모든 옛 앱/ZIP/manifest/raw·
  helper/seed/checkpoint/사용자 저장·과거 인간 판정은 불변. 새 검사/runner/보고0이다.

## 검증과 마감

1. 기존 pre-autoload 격리 이름표 runner로 수정 전 반례→같은 표본 수정 후 통과를
   보존한다. fresh StoryMode의 정상 결과와 cold 복원된 결과를 비교하며 named는
   원이름/표시, hidden은 계속숨김, 문단/선택/경제 snapshot은 동일해야 한다.
2. 기존 이름표24/compile 및 영향 검사만 실행한다. 정확 marker와 stdout/stderr/
   Godot 오류를 읽고 보호30곳·전체source/helper/seed/player 전후를 직접 대조한다.
   새 export·전체audit·240주·검수 성능작업0이다.
3. clean source endpoint에 독립 판정을 결속한다. 성공은 source만 GO이며 원520 앱
   화면을 소급 통과시키지 않는다. 새 package와 실제 화면 검수는 별도 후속이다.

제품 표시 연결 복구·일회성, 새 정본 승격0. 인간/원어민/물리패드/연속청취·전체품질/
출시 GO가 아니며 실제 새앱/나머지 runtime은 HOLD다.
