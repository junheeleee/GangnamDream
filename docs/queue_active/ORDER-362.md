# Active Queue Spec: ORDER-362

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-362 [P1·검증] 4장 수리 뒤 콘텐츠 검토 지문 두 축을 다시 결속한다

2026-09-28 Codex 발행. 351의 실제 release inventory 실패를 분리한 후속이다.
361 검증 연결 구현 뒤·352 새 집필 전에 수행한다. 2026-09-28 착수 선언이며 구현·지문 갱신은 아직0이다.
361에서 발견한 기존360 기록의 Chapter1 연결 누락은 별도363이 이 작업 뒤에
수리한다. 이 기록을 곧 다시 바꿀 예정이므로360만 먼저 연결해 같은 검사를
반복하지 않는다. 361 GO를 이 작업의 선행으로 요구하는 순환 대기는 두지 않는다.

## 깊이 3문

1. 왜 지금인가: 현재 본문과 검토 기록을 일치시켜 변경 사실을 숨기지 않는다.
2. 무엇을 보존하는가: 후보 ID/count, 기존 사실·강도, 나머지5축과 동결 공개
   패키지·인간 판정. 최종 등급·법률 인증·외부 제출은 하지 않는다.
3. 무엇과 경쟁하는가: 새 집필 전에 확인된 검토 기록 불일치를 닫는다.
   351 문구나361 코드 변경을 여기에 덧붙이지 않는다.

## 실제 실패

- `order351-static-first-10-stdout.log`, exit1: `crime`,
  `alcohol_tobacco_drugs`의 `candidate_scan.expected_content_sha256` 두 필드와
  `docs/CONTENT_RATING_INVENTORY.md` stale, 합3오류다.
- 새 제품 `3f0aa92dc9c3bdefd6a333fa84481a318baad907`의 부모는
  `6297e8cbcd4e77278055b5e332f545ea32de90f9`다. 351의 KO/EN39문구가
  두 축 후보 사건의 전체 JSON 지문에 어떤 영향을 주는지 실제로 분해한다.
  실패만으로 수위·후보·등급이 달라졌다고 단정하지 않는다.

## 착수 후 소유할 파일 — 2파일, 1배치

- `content/meta/release_content_inventory.json`: 위 두 content SHA만.
  마지막 검토 기준에서 현재까지 실제 변경된 후보 사건/문구를 전량 읽고
  사실·강도·후보 동일성을 판단한 후 갱신한다. 확인 없는 재해시 금지.
- `docs/CONTENT_RATING_INVENTORY.md`: 기존 생성기로 재생성, 수동 편집 금지.
- 마감: 이 사양·351 후속 검토·큐·WORK_LOG·생성 STATUS·CLAUDE 현재행,
  새 독립 보고/판정 append. 실제 착수 시 심의 콘텐츠 프로필 정본과
  최신 위임 범위를 읽고 저자/검수자 소유를 나눠 선언 커밋을 먼저 만든다.
- 제품·도구·후보 ID/count·언어축·기존 사실/강도·공개 pin·인간 원장·
  export 필터·스토어는 비소유다. 사실 변화가 있으면 별도 범위를 선언한다.

## 완료 조건

### 2026-09-28 착수 소유·검증 선언 (일회성)

- 시작점 main `42fe58882e3e32b9eeeb86614c1b2fe88f88819e`, clean.
  저자 `/root`만 위 제품 2파일을 수정한다. 비저자 `/root/r3_route_probe`는
  실제 candidate event 전체와 원문 변경을 독립 검토하고 clean source 최종
  보고를 `.git/full-game-localization/order362-independent-final-review.json`에 쓴다.
  root가 검증 후 `docs/agent_reviews/ORDER-362.json`으로 보존하고
  `docs/agent_decisions.json`에 새 work_unit 판단만 append한다.
- CLAUDE·큐·WORK_UNIT와 QA/build/release 프로필 5정본을 확인했다.
  기준 `c94cd3ae19f22a015b3bd6b6e25afb17a8561242`의 두 축을 재계산하고
  현재까지 후보 집합·전체 KO/EN 사건 차이를 분해한다. 서사·등급 판단은
  기존 사실/강도와의 일치 검토로 한정한다.
- `audit_select.py --base 42fe58882e3e32b9eeeb86614c1b2fe88f88819e`로 영향도를
  확인한다. 실제 실행은 inventory normal(생성문서 신선도 포함)/self-test,
  context_manifest/queue_consistency, append 뒤 agent 결정 원장 검사다.
  기존 생성기의 `--write-report`는 생성 작업이며 추가 테스트로 세지 않는다.
  체크 전후 exact text source census와 원래351 실패 증거를 보존한다.
- 원문/runtime/도구 변경0이므로 Godot·화면·240주·전체 감사·351/361의 통과
  차선을 반복하지 않는다. 알려진 Chapter1 두 실패는363까지 보존하며
  이를 이 오더의 PASS나 본편 GO로 바꾸지 않는다. 도구 소유 확장0.
- 마감 소유는 위 명시 문서 외 완료 큐 이동용
  `docs/CODEX_QUEUE_L3_PENDING.md` 순번, `docs/queue_archive/CODEX_QUEUE_2026-09.md`
  완료 행/사양 이동이다. 기존 행·판정·원문은 보존한다.

- 실제 원문 차이와 두 축 판단을 비저자가 전수 확인한다. normal/self-test,
  생성문서 신선도와 해당 표적 검증을 실행하고 원래3오류를 보존한다.
- 새 clean source에 독립 작업 판정을 결속한다. 이어363에서360·362 기록의
  Chapter1 역사 비교를 연결하고, 실제 실패가 닫힌 뒤351·361을 별도 후속 검수한다.
- 일회성 지시, 상시 규범은 기존 WORK_UNIT·콘텐츠 인벤토리 정본이다.
  원어민/인간/물리 및 본편/새 package HOLD, 외부 출시·법률 인증0 유지.
