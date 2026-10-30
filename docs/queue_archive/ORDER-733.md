# ORDER-733 — 상점 원본 촬영의 안전한 실행 입구

#### [x] ORDER-733 — 2026-10-30 안전 입구 source 검수 완료

사용자 `그럼해`의 잠금 중 잔여 완성 지시.
기여: C5. 실제 촬영·화면 판정·업로드가 아니라 그 전에 빠진 실행 안전장치.

## 깊이 3문

1. 없으면 무엇이 깨지는가: 기존 store 촬영은 사용자 저장 분리·새 원본과
   오프라인 exporter receipt의 연결을 한 실행 계약으로 보장하지 못한다.
2. 플레이 상태: 제품 상태를 바꾸지 않는다. 새 QA namespace만 허용하며
   월별 실제 경로의 29.1/53a3 저장·원18.1·공개 데모는 비소유다.
3. 경쟁: 실제 대표 경로가 잠금으로 불가한 동안의 C5 준비만 수행한다.
   KO/EN 뒤 CJK 정합·Steam 계정·사람 확인을 대신하지 않는다.

## exact 파일 소유

- `tools/store_shot_capture.py`, `tools/store_shot_capture_self_test.py` 신설.
- `tools/audit_scope.json` 새 source-only 검사/차선 등록.
- `docs/STORE_SHOTLIST.md`, `docs/QA_CHECKLIST.md` 새 안전 실행법 연결.
- 이 사양/마감 archive, 큐 한 행, CLAUDE 현재 준비상태 한 행,
  WORK_LOG 신규 항목. 기존 월별 미커밋 증거는 보존·스테이징 제외.

## 구현·검증 계약

- 기존 pre-autoload bootstrap과 process-tree 회수 재사용. HOME/XDG 수정0,
  사용자 저장 복사0, 기존 캡처/자산 삭제·교체0, private 새 출력만.
- 실제 Git source commit/tree/build와 source 파일 SHA 전후 결속. 깨끗한
  전용 checkout만 실제 촬영에 허용하며 임의 후보값 입력으로 대체하지 않는다.
- 영어 1280x800 원본 exact8, decode/중복/이름/치수/hash, stdout/stderr/Godot
  원로그·exit·timeout·표식 순서·오류 확인. 성공 시 기존 offline exporter가
  읽는 receipt 발급. 실패 원로그·부분 출력·QA namespace 보존.
- 모의 프로세스/합성 PNG 반례와 exporter 연동으로 검사. 현재 Mac 잠금 중
  실제 Godot 부팅·촬영0. 원본의 실제 내용·시각/사람/C5 전체 GO0.
- 저자 root, 독립 검수 locked_media_audit. 실제 코드·산출물 전수 읽기.
- audit_select --list 먼저, source-only 표적 검사, manifest/queue/diff 확인.

## 마감

도달 경로: STORE_SHOT_CAPTURE_SELF_TEST_OK tests=27 synthetic_only=1 engine_runs=0.
생산자↔독자: store_shot_capture.capture → receipt.json → store_shot_export.export.
바꾸는 상태: 안전 runner 없음→source/실패 검사 수용; 제품 상태 변경0.
포기 시 잃는 것: 새 촬영의 source/원로그/격리/원본8 결속.
서사 위치·계층: C5 도구, 비해당. 닫는 것: source 준비만.

독립 /root/locked_media_audit GO_SOURCE_RUNNER_PREPARATION_ONLY.
전수 코드/문서와 최종27모의검사 3.699s exit0. root 발견 숨은 Git 편집 허점은
HEAD blob 전수 대조와 assume-unchanged/skip-worktree 반례로 수리·재검수했다.
보고 `.git/order733-store-capture-20261030/independent-review.json` 5999B
SHA0521275dd0486e37eee7ca834345e73eec35fcc955ce7f29c0963ecad02b77a5,
MD3704B SHA3b855c116efb968d0854632630cd524cc4af998a2894a8b591d28c34db2ec58b.
대상 runner13253B SHA967d2fc8(전체SHA는보고), tests23672B
SHA0af7edb04ebf14eb64d2fe84387869f00f5d714ca1b30580c982f1a6ff65b813.
audit 등록182/context/queue/diff 통과. 일반 영향목록의 엔진 검사 실행0.
기존 월별 dirty 파일을 차선에 추가하지 않고 선택된 source-only 검사를 직접 실행했다.

미관찰: 실제 엔진/격리/화면/패키지/사람/원어민/패드/출시0. 원본/공개 자산 교체0.
현행 Steam은 최소1920x1080을 요구하므로 기존1280 pipeline은 제출 준비완료가
아니다. 해상도는 다음 작은 범위로 별도 수리한다. 기존27시험은 합성이다.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.

반복 사용 규칙은 STORE_SHOTLIST/QA_CHECKLIST에 승격한다. 나머지 범위와
모의 검증 지시는 일회성이다. 실제 촬영은 잠금 해제 후 대표 경로 우선순위를
유지하는 별도 작업이며 이 도구 통과만으로 새 화면을 승인하지 않는다.
