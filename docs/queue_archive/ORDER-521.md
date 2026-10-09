# ORDER-521 — cold result 재개 이름표 복원

#### [x] ORDER-521 [P1·표시 수리] 저장 결과의 이름표를 원래 표시 상태로 복원

**완료 — 2026-10-10 / source 한정 GO.** 비저자 `phone_independent_review`가
clean `98bb99ed8e0b08d260ea0cc944cf727863bc3621`/tree
`ca59bbcd5e83e033c0b9bd1547488451fb053976`의 원코드·반례·수정후 로그·fresh 보존을
직접 대조했다. 원520 앱의 표시 결함은 보존하며 새 앱 실제 검수는 후속이다.

## 구현·표적 증거

- 생산자 `StoryMode.gd:2583` 현재 렌더된 이름표 visible → 기존 dock cache →
  `_set_choice_dock_active(false)` 소비자다. 앞선 선택 dock이 없는 cold loader의
  초기 false를 덮는 cache1줄+주석만 추가했다. 원문/선택/효과/저장 schema diff0이다.
- 기존 `StoryNameplateCheck.gd`에 +59/-1로 KO/EN named/hidden cold4를 더했다.
  정상 진행에서 만든 result context를 fresh StoryMode에 로드하여 root/choice0/
  문단/body/name/visible/전체 GameState가 같음을 확인한다. hidden은 계속 숨긴다.
- private `.git/order521-nameplate-20261010/`: clean fixture80f5e7b에서 수정전
  exit1/62.702042초·named KO/EN2건만 FAIL이다. 기존24/hidden2는 유지했다.
  준비 symlink 거부1건은 엔진 시작 전이며 canonical 동일 증거 경로로 재준비했다.
  반례/준비 실패/실패 QA namespace는 삭제·덮기 없이 보존했다.
- 수정후 runner exit0/62.757176초. 실제 stdout16741B/SHA048fb527…·
  Godot16606B/SHA58c699a4…·stderr/오류/경고/누수0이다. 정확 cold4 marker1과
  기존24/pages262/refresh118/locale24/controls32/quote12 marker1을 직접 읽었다.
  compile68 exit0/4.361424초·stdout=Godot313B·stderr/오류0이다.
  EN coverage/Hangul/demo 현지화/표면언어/context/queue 기존6검사 exit0이다.
- root와 비저자 fresh before=after672869B/SHA
  `09284f86e9d559a1b4b325906ca1fb05b56dbcdc5f515317ad7542de4d60defa`:
  tracked3258/helper5/seed2/W238/player33·보호33곳 exact다. 보호31곳에 수정전
  external 원로그·실패 QA2곳을 더했다. own engine20069 종료/editor61385 생존이다.
  독립 최종대조 후 동결을 해제했다. 새 checker/runner/보고/전체audit/240주/export0이다.

선택기66등록 전부를 반복하지 않았다. 표시 cache1줄에 직접 닿는 fresh loader,
일반/hidden/CG/언어/입력 기존표본·compile·EN/한글/demo/표면 검사로 한정했다.
변하지 않은 폰트·원장·서사·장기 경로 검사의 재실행을 완료 조건으로 만들지 않는다.

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
   Godot 오류를 읽고 보호33곳·전체source/helper/seed/player 전후를 직접 대조한다.
   새 export·전체audit·240주·검수 성능작업0이다.
3. clean source endpoint에 독립 판정을 결속한다. 성공은 source만 GO이며 원520 앱
   화면을 소급 통과시키지 않는다. 새 package와 실제 화면 검수는 별도 후속이다.

제품 표시 연결 복구·일회성, 새 정본 승격0. 인간/원어민/물리패드/연속청취·전체품질/
출시 GO가 아니며 실제 새앱/나머지 runtime은 HOLD다.
