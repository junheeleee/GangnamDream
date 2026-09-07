# Active Queue Spec: ORDER-175

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-175 [현지화 운영 수리] 활성 검수 대기 행을 손실 없이 이어보기로 옮긴다

**[~] 2026-09-07 Codex 착수 — 아래 큐 저장·읽기 경로만 소유한다.**
전체판 번역을 진행하며 큐가12,979/13,000bytes에 닿았다. L1/L2가 끝나도
L3 OPEN인 기존 오더를 완료로 바꾸거나 문장을 깎을 수 없다. 새로운 승인·우선순위
체계를 만들지 않고 단일 큐를 명시적 위치에서 이어 읽도록 저장만 나눈다.

## 깊이 3문

1. 다음 번역 배치마다 크기 제한 때문에 기존 검수 의무를 압축하는 비용을 없앤다.
2. 기존 행의 이름·상태·게이트·상대순서와 사람 판정은 모두 보존한다.
3. 일회성 저장 수리 한 단위다. 새 게임 시스템·일반 문서 프레임워크로 키우지 않는다.

## 소유권

- `docs/CODEX_QUEUE.md`: 운영 본문은 유지하고 ORDER174~159의 기존16행을
  `docs/CODEX_QUEUE_L3_PENDING.md`로 정확 이동한다. 이 페이지는 archive가 아닌
  동일 활성 인덱스의 연속부다. 단일 명시적 include 위치에서 펼쳐 원래 순서로 읽는다.
- `tools/queue_index.py`와 `tools/queue_index_self_test.py`: 최소 공용 reader와
  한정 fixture. 기존 primary-only 입력도 지원한다. 행 정렬·자동 승인·자동 상태 변경0.
- `tools/queue_consistency_check.py`·`tools/project_dashboard.py`: 같은 reader로
  두 파일의 모든 행을 읽어 누락·중복·순서·사양 상태 불일치를 검출한다.
- `docs/context_manifest.json`·`tools/context_manifest_check.py`: 이어보기 분류·
  링크·별도16,000bytes 한도만 등록한다. 부팅13,000/활성사양16,000 한도 불변.
- `tools/audit_scope.json`: 새 경로의 표적 차선과 회귀 등록. 전체 감사/Godot0.
- 이 사양(완료 시 `docs/queue_archive/ORDER-175.md`)·CLAUDE 현재 상태·WORK_LOG·
  생성STATUS. 선언 공간을 위해 큐의 작성자/날짜 머리말과 과거 함정 포인터 절은
  기존 `docs/queue_archive/CODEX_QUEUE_2026-09.md`에 원문 보존하고 현재 링크 유지.

선언 당시의 행을 그대로 이동한다. 이 오더의 추가·완료 제거에 필요한 순번 이동
외에 상대순서 변경0. 기존 ORDER174~159 사양은 수정하지 않는다.
KO/EN/JA/ZH·모든 제품·원장·런타임·공개·fonts/save·human_gates는 비소유다.

## 검증

- 선언 전38행, 선언 후39행; 완료 후 이 오더만 보관하고 기존38행을 복원한다.
  16행의 이동 전후 바이트, 이름·상태·게이트·링크, dashboard 행순서/개수 일치.
- 한정 fixture: legacy, 정상이동, 누락·중복 include, 잘못된/경로탈출/심볼릭 링크,
  행 누락·중복·순서 역전·사양 상태 불일치, 이어보기의 허위 완료·L3 GO,
  dashboard 누락 방지, 별도 예산. 열린 L3 행은 완료/GO로 해석하지 않는다.
- queue reader self-test·queue consistency·context·dashboard freshness·human gates·
  audit_select --verify·diff. 제품 변경이 없어 전체 감사·240주·Godot은 실행하지 않는다.
- 번역11,616/meta9·원문 manifest·기존 human_gates 바이트 보존.
  전체 INCOMPLETE·full/main/product HOLD, 원어민/화면 OPEN·출시 데모 사용자 GO.

지속되는 파일 읽기 형식은 CODEX_QUEUE의 인덱스 절이 소유한다. 위 이동과 선언·
검증 범위는 일회성이며 새로운 사람 승인 규칙은 없다.
