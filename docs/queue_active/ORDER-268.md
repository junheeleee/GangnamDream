# 시작·진행·엔딩 회고의 중국어 UI 공백

#### [~] ORDER-268 중국어 UI 20기능·110키

[~] 착수 — 2026-09-20 Codex. clean main `e5ab39a69c46b01f2c148f4f69690240120395e2`.
공식39292/b112/meta9·기존54판정. 최신 번역 초안 우선 지시를 수행한다.

## 한 배치·깊이3문

플레이어가 시작·진행·회고할 때 기존 UI가 중국어 대신 영어를 읽는 공백을 채운다.
지우면 그 공백이 남는다. 상태·24주 뒤 결과는 바뀌지 않는 번역 단위다.
영어 폴백·휴면 참고 원고 저작과 경쟁하되 실제 기존 소비자의 누락을 우선한다.
20개의 독립 기능묶음에 110키를 나눈다. 짧은 라벨 하나를 오더 하나로 만들지 않는다.
단위 크기의 첫 실행 추정은 기능별 문맥으로 적용하며 새 영구규칙을 만들지 않는다.

## 고정 모집단

`.git/full-game-localization/post267-ui-throughput-batch-plan.json`
SHA `eff2f3a3742fdc6a06c8b487682123cf782d3daac9ec0c4a025db5de6720bdd0`의
selected_rows110과 units20만 소유한다. 실제 collector export로 ID·source hash·보호 여부를
재확인한다. 구성은 시작9/HUD6/정보15/현재35엔딩 요약38/인물 후일담41/마지막 상태1이다.
기능묶음은 시작 표지, 계속/새 이야기, 목표 수첩, 자산 상세, 남은 시간, 지연 단계,
다른 진행, 시작/숙련, 성과 결말, 상실 결말, 관계 결말, 일상 결말, 아버지, 어머니,
지연, 다은, 상철, 재혁, 현수, 마지막 상태다. 각 행의 정확한 분기와 조건을 보존한다.
현재 CN/TW 각각110키 부재이며 220신규 초안이다. JA110은 기존값 유지·이번 검수/수용0.
110은 전체 UI 분모가 아니며 모든 분기의 실제 플레이를 확인한 수치도 아니다.

## 파일 소유권

- ROOT 제품: `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json`의 선택110 추가만;
  `content/meta/full_game_localization.json`의 실제 신규 수용만.
- ROOT 운영: `CLAUDE.md`, `docs/CODEX_QUEUE.md`, `docs/CODEX_QUEUE_L3_PENDING.md`,
  본 사양, `docs/queue_archive/ORDER-268.md`, `docs/WORK_LOG.md`, `docs/STATUS.md`,
  `docs/queue_backlog/FULL_GAME_LOCALIZATION.md`, `docs/agent_review_decisions.json`,
  `docs/agent_reviews/ORDER-268.json`.
- Plato는 한국어→간체110, Rawls는 한국어→번체110을 각 별도 private 초안에 저작한다.
  다른 언어 초안을 중역/문자 변환하지 않는다. Poincare는 비저자 독립220 전수검수.
  ROOT만 실행·사전 설치·수용·Git을 수행한다. 세 작성/검수 파일을 분리한다.

## 보존선

KO/EN·JA·게임 코드·조건·라우팅·수치·저장·원본 슬롯·사람 원장·공개 M01~M06은 비소유다.
공개 보호 키·ui_unverified·미등록 ending·기본 fallback·구 AP/phone/debug는 제외한다.
기존 shared 시작/스캘핑/통장50만원 키는 모든 현재 의미에 맞는 하나의 값만 추가한다.
생존/별세, 미방문, 원격/실제 동석, 연애, 불확실한 진심과 소식의 사실 강도를 바꾸지 않는다.
원문 조건의 잠재 부채는 번역으로 수리하지 않는다. 응답·동의·소유를 덧붙이지 않는다.
영어 직행 consumer 수리·새 fixture·검사/역사 pin·audit_scope 변경0이다.

## 유한 검증과 수용

1. clean 선언 source에서 기존 full_game_localization export, 정확110 leaf IDs·limit110,
   CN/TW 각1회. 사전 편집 전 원문을 보존한다. 무보호·지원 consumer만 허용한다.
2. KO 직접 병렬 초안220→독립 전수220→기존 check의 선택 L1. 첫 실패는 보존한다.
   진짜 번역 결함은 고친다. 검사 오탐/미지원이면 원문·자연스러운 표현을 왜곡하지 않고
   해당 기능묶음을 HOLD로 분리한다. 다른 독립 묶음 저작은 계속한다. 새 도구 확대0.
3. 승인된 값만 기존 import --accept로 반영하고 receipt를 portable에 결속한다.
   기존39292 수용·비소유 UI·JA 전량·source raw의 역복원과 신규 current hash를 대조한다.
   실제 승인 수를 기록하며 미완료를220 완료로 세지 않는다. 전체 old L1·engine 반복0.
4. 기존 news-panel-locale-only의 명명 검사 목록12를 재사용하되 이 오더 소유13파일과
   실제 committed diff를 별도로 결속한다. 과거259 owned_paths를 이번 권한으로 쓰지 않는다.
   공개/공유 영향과 실제 신규 선택만 검증하며 full audit·240주·새 역사 스위트0이다.
5. 비저자 clean exact 단위 판정 후 보고/원장1행·큐 보관·STATUS·metadata를 마감한다.
   새 코드 수리가 필요하면 이 번역 배치에 붙이지 않고 별도 범위로 선언한다.

일회성 작업 지시다. 용어·언어 경계는 기존 I18N 정본, 권한은 WORK_UNIT이 소유한다.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.
공개GO1·인간OPEN45·본편HOLD 유지. 원어민/실제화면/인간플레이/물리패드 관측으로
바꾸지 않으며 외부 출시·스토어·지출·법률 인증0이다.
