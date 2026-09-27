# Active Queue Spec: ORDER-360

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-360 [P1·검증] 대본 수리 뒤 현재 콘텐츠 검토 지문을 다시 결속한다

2026-09-27 Codex 발행. Claude의 P-20 승인 반영 커밋 `78d6fea`가 남긴
검사 실패를 실제 현재 소스 `636ed302`에서 읽기 전용으로 확인한 후속이다.
359 제품 수리나358 역사 비교에 범위를 붙이지 않는다. 358 뒤·351 전에 실행한다.

## 깊이 3문

1. 왜 필요한가: 현재 본문과 내용 검토 기록이 다르면 출시 준비 검사가
   실제 변경과 단순 원문 갱신을 구별하지 못한다.
2. 무엇을 보존하는가: 기존 사실·강도·후보 ID와 동결 공개 패키지·인간 증거를
   유지하며, 검토한 현재 KO/EN 사건에 대한 지문만 다시 결속한다.
3. 무엇과 경쟁하는가: 다음4장 집필 전에 기존 대본 수리의 검토 누락을 닫는다.
   최종 등급·법률 인증·외부 제출·스토어·내용 삭제는 이 작업이 아니다.

## 확인된 실패 (구현 아님)

- `python3 -B tools/release_content_inventory.py` normal1회, exit1·6.26초·stderr0.
- `gambling`, `sexuality`, `violence`, `fear`, `crime`,
  `alcohol_tobacco_drugs`의 `candidate_scan.expected_content_sha256`6개와
  생성 보고 stale1개만 실패한다. 후보 사건/파일 수·ID SHA와 language 축은 일치한다.
- 지문은 KO/EN 후보 사건의 전체 JSON을 읽는다. 관련 없는 문장 수리도 같은 사건의
  지문을 바꿀 수 있으므로 실패만으로 표현 강화·후보 증가·등급 변경을 단정하지 않는다.
  309/313/350별 원인은 아직 분해하지 않았으며 관측에는359도 포함된다.
- private `order359-claude-inventory-result.json` SHA
  `82b1e38b3d3038962e748857409c7450844d787375efcab1736867d29a442c34`,
  stdout SHA `e257a8f270879d603699e394a7eacd6477f3839bb2d3f1aad16f8760dd9ee92e`.
  전후18파일 SHA 불변. 이1회는359의 정적7명령에 합산하지 않는다.

## 착수·소유 경계

- 착수 전 최신 CLAUDE·WORK_UNIT·심의 콘텐츠 프로필 정본을 읽고 기준 commit을
  고정한다. 아래 두 파일의 소유를 선언·커밋한 뒤 작업한다.
- `content/meta/release_content_inventory.json`: 위6축의 본문 지문만.
  각 축 지문이 마지막으로 검토된 원문과 현재 원문의 실제 변경 사건·문구를
  Git에서 추적하고 전량 직접 읽는다. 확인 없이 현재 해시로 덮어쓰지 않는다.
- `docs/CONTENT_RATING_INVENTORY.md`: 기존 생성기로 재생성한다. 수동 편집 금지.
- 마감: 이 사양·큐·WORK_LOG·생성STATUS·CLAUDE 현재행과 별도 독립 판정 보고.
- 제품 원고/번역·도구·후보 ID/count·언어축·기존 사실/강도·공개 source/tree/PCK/ZIP
  핀·인간 원장·export 필터·스토어는 비소유다. 사실 내용이 실제로 달라졌으면
  별도 범위를 선언하고 검토하며, 지문 갱신으로 그 차이를 숨기지 않는다.

## 완료 조건

- 6축별 실제 변경 원문과 지문 변화의 근거를 비저자가 전수 확인한다.
- `release_content_inventory.py` normal과 관련 self-test, 생성 보고 최신성,
  영향선택에 따른 표적 검증을 실행하고 원래7실패를 보존한다. 전체 엔진/플레이를
  이유 없이 반복하지 않는다. 변경 허용6필드/생성 보고 외 불변을 증명한다.
- 새 clean source·검토 근거를 별도 독립 작업 판정에 결속한다. 인간·원어민·물리
  관찰·최종 등급·법률 인증·새 패키지 GO로 바꾸지 않는다.
- 일회성 지시, 상시 규칙은 기존 WORK_UNIT·콘텐츠 인벤토리 정본을 따른다.

## 착수 선언 (2026-09-28)

- 기준 clean main: `199da42747d1559f3ac15f2159a116ed177e7cbb`.
- root 소유: 위 inventory의 `content_axes` 중 명시6축
  `candidate_scan.expected_content_sha256`만, 기존 생성기의 Markdown 결과만.
  마감 소유는 이 사양(archive 이동 포함)·CODEX_QUEUE·WORK_LOG·생성STATUS·
  CLAUDE 현재행·`docs/agent_reviews/ORDER-360.json`와
  `docs/agent_review_decisions.json`의 새 작업판정1개 append다.
  archive 이동 뒤 연속 순번을 유지하는 `docs/CODEX_QUEUE_L3_PENDING.md`의
  순서 숫자만 함께 소유한다. 기존 행 순서·문구·상태·링크는 불변이다.
- `/root/compat357`: Git 기준/변경 leaf 추출 증거만
  `.git/full-game-localization/order360-*`에 작성한다. 추적 파일 비소유.
- `/root/r3_route_probe`: 원문·수정 차이·검증 증거의 독립 판정과 private 보고만.
  inventory/도구/원고 저작에 참여하지 않는다.
- 기존118판정/96보고·인간/공개핀·원문/번역/자산/도구/게임플레이 불변을 확인한다.
  기존 실패1회를 다시 기준 실행으로 반복하지 않고 보존한다. 선언 이후 수정본에
  normal/self-test·생성 최신성·영향선택의 관련 표적 검사만 실행한다.
- 규범: 일회성 작업 지시이며 상시 규칙 승격0. 원어민/인간/물리 관측·출시 승인 아님.

### 표적 검사 선택 근거

- 두 제품 경로로 `audit_select --list`가 고른20개는 실행 결과가 아니다.
  실제 수정은6개 본문 지문과 그 생성표이며 후보/검색규칙/사실/원문/게임플레이는
  불변이다. 직접 소비자 normal·관련 self-test45와 context/queue를 실행하고,
  생성 최신성은 normal 및 마감 STATUS check로 확인한다.
- event lifecycle·본문/graph/역사 guard·번역·엔진2종 등 비변경 소비자를
  이 지문 수리 때문에 재실행하지 않는다. 원고 수리의 기존358 표적19종 증거는
  보존하며360의 새 실행/전체 감사 PASS로 세지 않는다.

## 구현·검증 증거 (2026-09-28)

| 항목 | 관측 |
|---|---|
| 도달 경로 | 기존 generator1 exit0; normal/self45/context/queue4 PASS |
| 생산자 ↔ 독자 | content_axes 6개 expected_content_sha256 ↔ release_content_inventory.py candidate_fingerprint/validate_source/render_report |
| 바꾸는 상태 | 6 stale body SHA + 생성표 stale → exact6 raw SHA 치환/최신 표 |
| 포기 시 잃는 것 | 기존359 normal7오류 계속; 원문 검토 이력 단절 |
| 서사 위치 | 현재 KO/EN 후보11사건/8파일, 시간·화자·회상/서류 전제 수리의 검토 기록 |
| 장면 계층 | N/A: 산문/화면 저작0·기존 산문 검토만 |
| 닫는 것 | 현재 지문/생성표 불일치만; 본편/새package HOLD 유지 |

- 기준별7축 재산출 exact, 후보 집합/파일/ID SHA·검색규칙·facts 동일.
  gambling/sexuality `2f91f426`, fear/crime/alcohol `f4c7fd90`,
  violence `bf5dd604`, language `556e929a`에서 추적했다.
- root와 비저자가47 netleaf(KO13/EN34, 수정45/새ghost2) 전량을 읽고 기존20사실/
  강도 변경 필요0을 판단했다. first-parent49편집/17사건버전/6commit을 결속하며
  전체 분기 이력으로 확대하지 않는다. 359는 이 후보 지문 변화에 기여0이다.
- private `order360-candidate-packet.json` SHA
  `09e19c5d8de9d2eadd14ce1d596890383cb9de28945cb3255b938dadfc0b9680`;
  `order360-final1-summary.json` SHA
  `9c8517e1b51a67a8ab48dd529ae6ab876a5dbcff4cd63022b54c387340337896`.
  전후1375경로 불변·timeout0. 생성1회와 표적4명령, 영향선택20개를 구분한다.
- private `order360-preservation-final1.json` SHA
  `14081284034c71bcff337847efdba73d150980e495c2a9fcf80bb120bda1157a`:
  exact6치환 외 불변·118기존판정/96보고·인간/공개핀 보존.
- 규범은 일회성, 기존 WORK_UNIT·콘텐츠 원장 정본 적용/새승격0.
  새 엔진/화면/입력/원어민/인간/물리/package 관측0·외부 제출0.

현재 상태: 구현·표적 검증 완료, clean source 별도 독립 최종 판정 대기.
