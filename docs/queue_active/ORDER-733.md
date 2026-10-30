# ORDER-733 — 상점 원본 촬영의 안전한 실행 입구

상태: [~] 2026-10-30 착수. 사용자 `그럼해`의 잠금 중 잔여 완성 지시.
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

반복 사용 규칙은 STORE_SHOTLIST/QA_CHECKLIST에 승격한다. 나머지 범위와
모의 검증 지시는 일회성이다. 실제 촬영은 잠금 해제 후 대표 경로 우선순위를
유지하는 별도 작업이며 이 도구 통과만으로 새 화면을 승인하지 않는다.
