# Active Queue Spec: ORDER-362

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [x] ORDER-362 [P1·검증] 4장 수리 뒤 콘텐츠 검토 지문 두 축을 다시 결속한다

2026-09-28 Codex 발행. 351의 실제 release inventory 실패를 분리한 후속이다.
361 검증 연결 구현 뒤·352 새 집필 전에 수행한다. 2026-09-28 착수 선언이며 구현·지문 갱신은 아직0이다.
361에서 발견한 기존360 기록의 Chapter1 연결 누락은 별도363이 이 작업 뒤에
수리한다. 이 기록을 곧 다시 바꿀 예정이므로360만 먼저 연결해 같은 검사를
반복하지 않는다. 361 GO를 이 작업의 선행으로 요구하는 순환 대기는 두지 않는다.

## 독립 마감 (2026-09-28)

- 비저자 `/root/r3_route_probe`의 한정 work_unit GO, clean source `c7db93f7fc915a4d16fa5e8f63fa8b72343a6491`,
  tree `96b70c27fd4a833c6b1150742b19da38415f59f0`. [보고](../agent_reviews/ORDER-362.json) SHA
  `80ce364d6c6a1a06098cb681ecc29d28f1b029e7f3a6e892fcfea7acdb62e9ca`, private 최종 원본과 byte-identical이다.
- 기존121판정/99보고를 그대로 두고 각1개만 추가한다. 인간 원장·원351 실패·
  361의두 실패·공개 데모 불변. 351/361 통합 및 본편/새package HOLD다.
- 완료 사양만 archive로 이동한다. aggregate archive 변경0, 활성 큐 나머지
  순번 -1 및351/361/WORK_LOG의362 상대 링크 이동만 반영한다.
- 마감 metadata 검사: context PASS(boot30398), queue PASS(active80/in_progress76),
  agent 원장 self222 PASS(product HOLD/human unchanged). 기존 판정121개 raw prefix,
  보고99개·인간 원장·보고 증거8개 SHA·새 보고 원본 동일성을 별도로 확인했다.

| 항목 | 관측 |
|---|---|
| 도달 경로 | RELEASE_CONTENT_INVENTORY_OK; RELEASE_CONTENT_INVENTORY_SELF_TEST_OK cases=45; context/queue PASS |
| 생산자 ↔ 독자 | content/meta/release_content_inventory.json:689,747 ↔ tools/release_content_inventory.py:437,2041,2999 |
| 바꾸는 상태 | stale body SHA 2 + 생성표 stale → exact2 SHA 치환/최신 표 |
| 포기 시 잃는 것 | order351-static-first-10-stdout.log: ERROR 3; 내용 검토 이력 불일치 |
| 서사 위치 | Ch4 arc_y4_family_partner_collision_jiyeon/three_promises/deal_only/jiyeon_and_deal; KOEN 8description |
| 장면 계층 | N/A: 산문/화면 저작0, 기존 후보4사건 전문 검토 |
| 닫는 것 | 두 검토 지문·생성표 불일치만; Chapter1 2FAIL →363, 351/361 HOLD |

## 2026-09-28 구현 직후 기록 — 이후 최종 판정은 위 마감 절

- 선언 `be6bd91` 및 원장 경로 정정 `6df5de6` 뒤 제품 2파일만 변경했다.
  기준360 `c94cd3ae19f22a015b3bd6b6e25afb17a8561242`부터 시작점까지
  KO/EN 변경은351의39문구, 이 중 후보 사건의 description 8개(4사건×2언어)다.
  나머지31문구는 7축 후보 밖이며 전량 읽었다. 새 구조·조건·효과·선택 변경0.
- `arc_y4_family_partner_collision_jiyeon`: 퇴원 후 첫 서울 방문 명시.
  crime 검색은 기존 결과의 `표를 사기 전에` 오탐으로 이미 등록되어 있다.
  범죄 행위·강도 변화가 아니다. `arc_y4_three_promises`와 `_deal_only`,
  `_jiyeon_and_deal`은 재입원 명시이며 기존 약표 대조/복용 확인의 건강 서사다.
  네 사건 KO/EN 전문·조건문·선택·결과 및 전후 본문을 저자와 비저자가
  각각 읽어 기존 facts/intensity 유지가 타당함을 확인했다.
- crime 후보73/40파일·ID SHA `4e0463a4d699a58c1c3fc7fa856c80b4218417badce2d62ec0403d389294c0dd`,
  alcohol 후보82/39파일·ID SHA `32942c5a49b64e9027b5a0071e1c95d6d205478ef05ea6ad25c5ad3c5d90433f`
  불변. 다른5축 content SHA와 7축 후보 집합도 동일하다.
- content SHA만 crime `3909aa7574de228b135c25936226f3c5bf1018bfc16b1585b212cf71be4cf933`
  → `f4fd635402ca61ce5632576a11b5d461a7e3cd32ed85f7a5eea80ba4e1e834dd`,
  alcohol `3ab95d312b2b2d36bdd76293987362ac765786937153245652442fbb1c8c418d`
  → `421a29f3f803fa35668b14a1b64a8ffd101616dfc7d9b6d5b863ab42cc924ef4`.
  기존 생성기로 표를 재생성했고 같은 두 셀 외 raw 변경0이다.
- inventory raw SHA `2ff675845e1017764eb67c1c9c330ecd3b3507fa0b40535757b00bba073a88b0`
  → `f46041343731f5cd64b680f778cff9ee77ea0c67fe114536f27a557fe5c1ead0`.
  생성표 SHA `c306b061c4b89aef40eb10c1833e0b06e0eff919d7941eb30986625c79f9d9d0`.
- 표적4검사: inventory normal(6.420초), self45(9.176초), context(0.280초),
  queue(0.262초) 모두 exit0·정확 marker·stderr0·timeout0. 각 전후1838개
  tracked/untracked text source census 동일. 영향선택20개는 실행20개가 아니다.
  실행은 `6df5de6` 위 dirty 제품 바이트에서 했으며 clean commit 재실행은 아니다.
  이후 마감 문서 변경과 검사한 제품의 동일성을 최종 검수에서 대조한다.
- 후보 packet `.git/full-game-localization/order362-candidate-packet.json` SHA
  `8de9115ab734b6941a0446782c8c0b8f0ffd8a02f26a3d10f0bed1e29faadae8`,
  결과 summary `order362-first-summary.json` SHA
  `0efc347597e19382af1efbbdbb376e08c048b372bce6cab3fef61ca2ec3dd49f`.
  원351 실패 stdout SHA `62ecd8616a661e9b35d8f4384206b07e1312f02b1d09ff661530b764eacdaff9`
  및 exit1·3오류를 보존했다. 선언 이전 증거/인간 판정을 고쳐 PASS로 만들지 않았다.
- 독립 원문 검수 `/root/r3_route_probe`는 두 SHA를 Git에서 별도 재계산했고
  기존 facts/intensity 변경 필요0을 보고했다. 최종 clean-source 판정은 별도다.
  등급·법률 인증·원어민/인간/물리·새 엔진/화면/자연 입력·전체240주 관찰0.
  351/361 통합과 본편/새package HOLD 유지. 다음363만 역사 비교를 수리한다.
- 규범 판정: 이 오더의 실행·검증·소유 지시는 일회성이다. 기존 WORK_UNIT과
  콘텐츠 인벤토리 정본 적용이며 상시 규범 신규 승격0. 스킬은 선행 선언,
  파일 소유 분리, 실제 원문 검토, 표적 검증과 독립 판정을 적용하는 데 사용했다.

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
  `docs/agent_review_decisions.json`에 새 work_unit 판단만 append한다.
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
