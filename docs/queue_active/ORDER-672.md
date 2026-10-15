# Active Queue Spec: ORDER-672

> 상태·우선순위 정본: [CODEX_QUEUE](../CODEX_QUEUE.md).

#### [~] ORDER-672 [문서·출시5조건] PR #34 승인 결정에 실행 큐를 맞춘다

## 위임·판정 단위

2026-10-15 사용자 직접 지시: PR #34를 main에 합치고 큐를 승인된 다섯 출시 조건에
맞춘다. PR은 문서 한 건으로 main 7c08e0b1a6427d348e6e8b82e862f1fa1885ef08에 병합·push,
GitHub merged 확인. 판정 단위는 기존 열린 78오더의 잔여 범위 분류와 실행 우선순위다.
제품 구현·추가 실제 월 플레이·외부 출시는 이 문서 오더가 아니다.

## 깊이 3문

1. 오래된 OPEN을 완료로 바꿔야 하는가? 아니다. 역사 인간·원어민·물리 패드 판정과
   사양 경로·상태는 보존하고, 새 조건 밖 잔여 의무의 실행 gate만 출시 후 보류로 내린다.
2. 번역 원장의 missing 전체가 치명 결함인가? 아니다. 실제 빈 표면·EN 한글과
   고지·5언어 출고에 필요한 범위만 조건부 유지한다. KO/EN 확정 전 CJK 다듬기는 중단한다.
3. 목표일이 출시 승인인가? 아니다. 12월 중순은 목표이며 다섯 조건 미충족은 명시한다.
   최종 출시 판정과 범위 축소는 사용자, 외부 업로드·스토어 변경·설문 실행은 별도 권한이다.

## 배치 1 — 분류·정렬

- 기존 인덱스 78개를 중복·누락 없이 잔여 기준으로 C1~C5 또는 출시 후 보류에 대응시킨다.
- 실행 순서는 CI 실패/만료 예외 우선, 동일 M18 재검수와 대표 완주,
  확정 치명 결함만 수리, 고지/출고 gap 준비로 좁힌다.
- 기존 사양/이력의 [~]는 완료되지 않았다는 뜻이지 자동 실행 허가가 아니다.
  gate의 보류 항목은 건너뛰며 조건 밖 새 오더는 사용자 승인 없이 열지 않는다.
- 과거 L3 이어보기의 OPEN·수용 증거와 공개 데모 GO는 변경하지 않는다.

## 배치 2 — 라우팅·독립 검토·마감

- 부팅/품질 참조의 낡은 추가 출시 차단 조건을 최신 DECISIONS로 라우팅한다.
- 기존 78개 분류와 C4/C5 실제 gap을 비저자가 검토한다.
- 문서 정합/큐 파서/선택 목록/diff만 표적 확인하고 월별 진행 dirty를 제외해 커밋한다.

## 정확한 소유권

- docs/CODEX_QUEUE.md, docs/CODEX_QUEUE_L3_PENDING.md: 순서·gate·출시 실행 제외.
- docs/queue_active/ORDER-157.md: 최신 결정의 잔여 범위와 부모/자식 권한 경계만 추가.
- docs/queue_backlog/RELEASE_PRIORITY_2026-10-15.md: 78개 분류 근거·5조건 gap.
- CLAUDE.md 현재 상태, docs/MASTER_RELEASE_AUDIT.md 출시 정책 라우팅/현재 실행 절.
- 이 사양(마감 시 docs/queue_archive/ORDER-672.md), docs/WORK_LOG.md 새 앞부분만.
- .git/release-priority-20261015/*: 분류·독립 검토·보존 증거(비제품).

## 비소유·검증

게임 원문/번역/코드/자산/검사 도구/KNOWN_FAILURES·인간 원장·공개 데모·저장·설정·
project.godot은 비소유. 진행 중 ORDER-612 사양 및 WORK_LOG 3555B 미커밋 suffix를
byte-exact 보존하며 612 큐 overlay도 같은 월의 한 커밋까지 stage하지 않는다.
제품 동작 검사 삭제·완화 0, engine/native/화면·설정 변경 0.
검증: context_manifest_check, queue_consistency_check, queue_index_self_test,
audit_select --list(실행 아님), git diff --check, 비소유 diff와 보호 hash 대조.
이 문서 오더는 출시 GO·CI 녹색·사람 2~3시간 확인·Steam 업로드를 발급하지 않는다.

## 규범 소유권

승인된 출시 조건/목표일은 DECISIONS 2026-10-15가 유일 정본이다.
실행 제외·조건 매핑은 CODEX_QUEUE, 품질 목표는 MASTER_RELEASE_AUDIT가 참조한다.
78개 분류·이 사양의 파일 소유·검증은 일회성이다.
