# Queue Result: ORDER-672

> 상태·우선순위 정본: [CODEX_QUEUE](../CODEX_QUEUE.md).

#### [x] ORDER-672 [문서·출시5조건] PR #34 승인 결정에 실행 큐를 맞춘다

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

## 2026-10-15 결과 — 문서 정렬만 완료

- PR #34 DECISIONS 22줄/문서1건을 main 7c08e0b1a6427d348e6e8b82e862f1fa1885ef08에
  병합·push하고 GitHub merged를 확인했다. 선언은 4643bccdf732a42d7f5a0fbbfe86a2090d2f2bc4.
- 기존78개를 612유지1/157조건부축소1/출시후보류76으로 전수 매핑했다.
  core23/현지화55를 나눠 조사했고, 보류는 core22+현지화54다.
  사양·기존상태·역사OPEN/REJECT/원gate·공개GO 보존. 제품/검사/원장 변경0.
- 큐의 보류gate는 실행제외다. parser가 새 의미를 강제한다고 주장하지 않으며,
  [~]와 기존 경로를 이력으로 유지했다. 672마감행만 제거/순번당김, 612workingoverlay는 보존.
- C3 CI진행중≠green, C4 사람/양쪽고지 및 C5 retail5언어/Steam준비물은 미충족 gap이다.
  5조건 밖 전수원어민·물리패드·보조경로·문체개선은 출시 차단을 중단한다.
  612는동일M18만/M19이후월별선언, 157제품실행은정확자식선언 뒤만.
- CLAUDE/MASTER의 낡은 추가 출시 차단을 DECISIONS로 라우팅했다.
  부팅예산 FAIL 13477→13222B 및 이동링크 FAIL을 원문이동/상대링크 정정으로 해결했다.
  예산증가/의미삭제/검사완화0. 612 untracked 링크는 backlog에서 평문으로 바꿔 clean CI를 보호했다.
- 후보 표적6(context/queue/queue-self/dashboard-advisory/human/agent-self) 최종 actual0,
  diff0. queue-self25/하위4, agent-self290. dashboard STALE은참고경고/exit0이고
  현황판전용commit0. human검사 open45/done1 보존; 초기실패도 private receipt에 남겼다.
  엔진/앱/OS/새월/전체audit/외부실행0.
- 정책/보존 비저자GO를 아래 보고와 결속했다. backlog 한행 수정은 최종정책부록GO,
  나머지10정책입력핀 exact. 원 보고를 덮지 않았다.
- 612사양11314B SHA a2ae0db65ce3aaaad80bc3370d90dfda109e2ee5c82b4e8afce5791daf766cb5와
  WORK_LOG미커밋suffix3555B SHA a9da54e58a91283d1732eae4d0581400cf8dc499274eb1b8aa2ec95c3a7c693b를
  보존·stage제외한다. project/human/agent원장 보호3도 before.json과 exact.
  검사 도구/게임원문/번역/저장/설정/공개제품 diff0.

### 독립 증거 핀

git-private `.git/release-priority-20261015/` 아래 원 보고를 보존했다.
root는 보고MD 전문과 JSON 파싱/원바이트 SHA를 대조했다. 이들은 문서 분류·보존 GO이지
현재main CI 녹색/대표완주/사람2~3시간/고지구현/Steam/출시 GO가 아니다.

| 보고 | SHA-256 |
|---|---|
| core-classification.md | 2d6be6f211138261c2811bdf5d3387b317cec6ef11addc03c3d90062c4310693 |
| core-classification.json | 8b7977c2209c4b82c43f74e23f8f1473adf3d6022b2ecd609dcb90bef39ad3d2 |
| localization-classification.md | 3d75f4adf06170c424ccf8deaf3c4558358a2a32436f507aa4a5cd831b3386c8 |
| localization-classification.json | 644cf09f149f10f128685bd2b77e5189d8f53b41b459582393c20dbbd9a4e7ed |
| policy-review.md | 495868e6e24afe14c6210c3d6ec181f002054d043a3217a948aebd786b47661f |
| policy-review.json | 1e14a1bb86580f3547a2f40c14ddf0cc95019121c7a5029e854c42c1b2a60d2c |
| policy-final-addendum.md | 63651694a4bed2e4610d6654e3f3870bbd135804b5bd0f8be5609d8f3e61cdec |
| policy-final-addendum.json | f442798b36728f0f2b57b2dcde9de718ad4532342543a8619955d593562e2899 |
| preservation-review.md | 49259d4e9bb0a0b395e76ad79939593a3ea1e0005af0c26f685cbdb6cdedcbef |
| preservation-review.json | 172c31a4c19e1d21ab2ade0f8bf4186f405ba54d5d9245372c0a93844417ef8f |

### 규범 판정

승격: CODEX_QUEUE의 출시 기준 실행 필터/보류 실행제외 및 157 최신잔여범위.
출시5조건·12월중순목표·사용자최종판정은 기존 DECISIONS 승인문을 복제/수정하지 않고
소유자로 참조했다. 그 밖의 분류78/이동/파일소유/검증/증거핀은 일회성이다.
