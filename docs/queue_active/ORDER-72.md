# Active Queue Spec: ORDER-72

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-72 [P0·출시 범위] 심의·스토어 설문에 답할 실제 콘텐츠를 센다

**착수 파일:** `content/meta/release_content_inventory.json`,
`tools/release_content_inventory.py`, `tools/audit.sh`, `tools/audit_scope.json`,
`docs/CONTENT_RATING_INVENTORY.md`, `docs/STEAM_PAGE.md`,
`docs/MASTER_RELEASE_AUDIT.md`, `docs/QA_CHECKLIST.md`, `docs/PROPOSALS.md`,
`docs/CONTEXT_INDEX.md`, `docs/context_manifest.json`과 큐/완료 증거 문서
(`CLAUDE.md`, `docs/CODEX_QUEUE.md`, `docs/WORK_LOG.md`, `docs/HANDOFF.md`,
`docs/STATUS.md`, 이 사양).

**착수 설계 판정:** 현재 10개 export preset은 모두 `all_resources`이고
`tools/*, docs/*, build/*`만 제외한다. 따라서 V2 데모에서 도달하지 못하는
5년 사건·카지노/경마/홀덤 런타임도 업로드 패키지에는 들어간다. 한 원장을
`24주 V2 도달 / 240주 본편 도달 / 패키지 포함·현재 비도달`로 나누고,
도박·선정성·폭력성·공포·언어·범죄·음주/흡연/약물의 내용 축과 생성형 AI·
온라인 기능을 각각 소유 파일, 진입점, 표현 강도에 연결한다. 감사 도구는 preset,
한영 사건·엔딩, 민감 후보 ID/파일 fingerprint, 런타임 네트워크 API 0,
AI 제작 증거와 공시 문구를 함께 검증한다. 실제 export-pack ZIP은 full/V2에서
대표 증거 경로가 모두 든 것을 별도 스모크하며 산출물 해시는 일회성으로 남긴다.

**착수 경계:** Steam 공개 문서의 세 설문 구획과 “접근 불가 빌드 콘텐츠도
공개” 원칙, 현행 한국 등급 규정의 내용 축까지만 사실로 인용한다. 파트너 전용
설문 문항을 추정해 발명하거나 법률 자문·최종 연령 등급·콘텐츠 삭제를 하지
않는다. 현 빌드의 사실과 사업 선택을 분리해 사용자 결정은 제안 한 건으로만
올린다.

## 깊이 3문

1. 지우면 `all_resources` export에 들어가는 도박·성인 주제를 네 미니게임만으로
   오판하고, 구 RC와 다른 빌드에 같은 설문 답을 재사용한다.
2. 게임 상태는 바꾸지 않지만 어떤 콘텐츠를 포함/제외할지의 사용자 결정이 달라진다.
3. KO/EN 데모 출고 범위, 전체 5년판, 접근 불가하지만 패키지에 든 리소스가 경쟁한다.

## 배치 A — 재현 가능한 인벤토리

- 런타임 진입점과 export 필터를 함께 따라 도박, 범죄, 폭력, 음주/흡연, 성적
  내용, 생성형 AI 사용, 온라인 기능을 사실 기준으로 목록화한다.
- Steam 설문 초안과 GRAC/지역 등급 질문을 코드·자산 증거에 연결한다.

## 배치 B — 사용자 결정 경계

- 등급을 임의로 확정하거나 콘텐츠를 삭제하지 않는다. 사업·법무 선택만
  `PROPOSALS.md`에 30초 결정 형식으로 올리고 나머지 출고 작업은 계속한다.

## 완료 증거

- export 포함 콘텐츠의 소유 파일/진입 가능성/표현 강도 누락: `0`
- 기존 AI disclosure와 실제 제작 방식 모순: `0`
- 최종 등급·삭제 자동 결정: `0`
