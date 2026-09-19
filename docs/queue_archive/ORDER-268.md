# ORDER-268 — 중국어 시작·진행·회고 UI 번역

[x] 2026-09-20 실행 배치 마감. 독립 Poincare work_unit GO는 **158 반영과 62 HOLD 분리**의 한정 판정이다. 원220 전체 기계PASS가 아니다.

- 제품 `290f64300ab63f08a881d4913b745cdf6629c242`, tree `b3c9fee907d47d79657be63588456bd226e201d7`.
- clean 검토 `bb138b020610413250c15faed966a7093be399e8`; 이후 차이는 STATUS 문서뿐이다.
- 원20기능110키×2의220초안은 KO 직접 병렬 저작·독립 전수 언어GO/필수0다.
- 첫 기존 check는 두 언어 각각 첫 오류에서 중단했다. 이후 원110 전수 진단에서 CN7행/TW4행을 확인했다.
- 아래 사전 WORK/사양의 '첫 check CN7/TW4'는 이 전수 진단과 혼동한 당시 문구다. 원문은 보존하고 여기서 정정한다.
- title-lock 뜻풀이와 구독자/관용 수량의 인식 경계를 분리 보존했다.
- 4기능31키×2=62는 HOLD. ending_arrival11·ending_relationships7·epilogue_father8·epilogue_jiyeon5.
- 나머지16기능79키×2=158만 기존 도구로 수용했다. 원220 초안에서 번역 수정0·새 검사/코드/fixture0이다.
- 공식39450/b113/meta9. JA13096·CN/TW각13177. 기존39292의 현재source/target과 portable·UI raw 역복원 exact다.
- 사전 합집합3015 중 CN/TW 각각648존재/2367부재. 전체 UI 분모나 full completion 비율이 아니다.
- KO/EN·JA·runtime·공개데모·인간 원장 보존. named12는 계약 회귀이지 실제 화면/원어민/인간 플레이가 아니다.
- 원어민·렌더·물리패드 OPEN, 공개GO1·인간OPEN45·본편HOLD. 외부 출시·스토어·지출·새 원격CI 판정0.
- 보류62 원고는 아래 독립 보고의 held_drafts에 보존하며 현재 제품/공식수용에 포함하지 않는다.

자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.

[독립 보고](../agent_reviews/ORDER-268.json) · SHA 06841e26205bc955962de8ee54507fc63f80ddb4ab027023ac0d75b441600fdf

## 실행 원문

사적 원문 `.git/full-game-localization/order268-<이름>.json`은 실제 child stdout/stderr/exit와 입력 보존 핀을 유지한다.
diagnostics exit0는 진단 수집 성공이며220 통과가 아니다. 원실패와 보류 모집단을 지우지 않았다.

| 이름 | 바이트 | SHA256 | 결과 |
|---|---:|---|---|
| export-zh-cn-first | 377565 | b7a70b28ef36f71408c057f522d7f70bedbe10aea6c2d72ee51059d000f9bc8a | PASS |
| export-zh-tw-first | 377565 | 77cc79789b6f03460fec130d169ebee900447cdf6cc591d67e12179a33a7ac19 | PASS |
| preflight-check-cn-first | 377653 | ad37018d6c831f9a7d45d58e68e98db6906f0dcd7273772d9f1fcf5ae2c3d430 | FAIL preserved |
| preflight-check-tw-first | 377970 | 728acb79070130b6b84f347cc8ee65d46a9fa416a3a789f54945324b0e4091e7 | FAIL preserved |
| all-selected-diagnostics-first | 387423 | 0a0b5657414cfb7c2ff5481b29dc5b4f37b386bbe63920da26ecc13949cbfdb1 | diagnostics only; CN7/TW4 failures |
| source-bound-diagnostics-first | 385096 | 52811be052e4173fc8d7ac031775c71576013371b654cf217133820c785c34a7 | diagnostics only; CN7/TW4 failures |
| admissible-export-cn-first | 377620 | e45c45c86a2b8d517afe38b960a54d317e5acdca8bd3c8dfddca6e70deb32c8e | PASS |
| admissible-export-tw-first | 377620 | c7cc0ac56aab7c277420492b9de3b4c6f277f22301de05440c85c209c72c7548 | PASS |
| admissible-check-cn-first | 377511 | 80835d2ca8aaa36b8d41dcb54ed5ab640be7745bfa1c60bf9b1607fd63e8e740 | PASS |
| admissible-check-tw-first | 377510 | 67a7cfb75a5cff189bc42d467e89bf34d6b45ed14de5c44ef24b6cbb9a6c3be3 | PASS |
| formal-export-cn-first | 377600 | ebdd4c98760f4cb7c8e56abb94b80fb5bbd132cb635e3e613e5cb6bf71e7389d | PASS |
| formal-export-tw-first | 377607 | 8b690f8094858e0e5e3e44c1b19bd4ab6d155c6fb1cb3b6a03fa07dad7235d9a | PASS |
| formal-import-cn-first | 377510 | 63e56054da0b72384896917117cdcc09a02be7236c6a00a92c7cf912b2dbeb50 | PASS |
| formal-import-tw-first | 377511 | 3e43a389e764539206a60db648f4204075c6e63a8fadfd59e67233eceed1910d | PASS |
| preservation-first | 377992 | d87b3cafa413d78e719e1ddd05ae016fd6ab73b71d8e3ff5a2d3cf3ea9087e93 | PASS |
| named-first | 1688004 | e49b8813228f93429241bfe18bf91dce22575b0a48c4d277609cbf055658d959 | PASS |
| named-outer-first | 379612 | 31a7541282f49b185fc2f52a10902cb398ee4671b91bbfa4d190b601b9bf7ef4 | PASS |

## 독립 사전 보고

- `order268-language-review-first.json`: 5754B / 273a9f4874c3f8e4a12c64e3e5fa45d00abc8d7e9ae1cb0f1d012ab6c3880ff1
- `order268-machine-boundary-review.json`: 7819B / e1d3a6cb24a5d785aaef8c9ff56849daa183e07bbfaf7221209a5ed9dcc52582

## WORK 마감 전 원문

# Gangnam Dream Work Log

> 이전 WORK·이번 선언과 검수 원문은 [267 보존본](queue_archive/ORDER-267.md)에 있다.
> 기존 보존본 링크와 첫 검수의 지적은 원형 그대로 이어진다.

## 2026-09-20 (Codex — 중국어 UI 220문구 착수)

- 실행:220초안 독립 언어GO/필수0. 원기계검사 CN7/TW4 실패는 보존하고 해당4기능62를 HOLD 분리했다.
- 나머지16기능158 신규 수용 후보, 코드·검사틀 확대0. 실제 검사·보존·최종 판정 뒤 마감한다.

- [268](queue_active/ORDER-268.md): 시작·진행·회고20기능의 기존110키를 CN/TW 각각 직접 번역한다.
- Plato 간체·Rawls 번체·Poincare 비저자 전수검수·ROOT 실행/수용. JA·코드·기존수용은 보존한다.
- 새로운 검사/fixture 없이 기존 도구로 초안과 신규 선택만 검증한다. 예상220은 완료 수가 아니다.

## 2026-09-20 (Codex — 새 게임 기록 다국어 전달 마감)

- [267](queue_archive/ORDER-267.md): 제품3ece4b3·clean검토4bfa395, Poincare 단위GO/필수0.
- JA·간체·번체 새게임 출발/소식 기록 생성자와 번역을 연결했다. 독립33, 신규27·기존6재사용.
- 공식39292/b112/meta9. 기존39265 현재해시·원장/UI 원문 보존, 전체L1 반복0.
- 첫18은15통과/3실패를 보존하고 원인2개를 수리했다. 원36+보충12+위임4 포함 영향8검사가 통과했다.
- 격리component104는현재34입력바이트동일로재사용했다. 기존 기록·게임 상태·KO/EN 유지 범위이며 화면/인간 관찰은 아니다.
- 공개GO1·인간OPEN45·본편HOLD와 출시 권한0 유지.

## 다음 안전한 범위

- 2026-09-20 번역 지연 지적을 우선한다. 비보호 shipping 사건의 미수용은0이다.
  앞서 잔여로 센843은 비활성 참고741·보호 데모102이며 자동 저작 대상이 아니다.
  실제 중국어 UI 누락 초안을 먼저 채운다. 초안9월23일은 연속 작업 전제의 추정이며
  최종 검수·출시 완료 약속이 아니다.
- 커피제목3 후속은 `post267-coffee-event-title-scope.json`(821fdbe4)에 준비했지만 보류한다.
  weight0와 별개로 scripted StoryMode 유입 코드가 있어 비도달로 단정하지 않는다.
- Story 카드18/54는[265](queue_archive/ORDER-265.md)에서 수용했다. 공유 `대기`는 여전히 제외한다.
- 생성 시점의 기록만 이번에 고쳤다. 기존 기록의 소급 언어 변환·휴면route4 메뉴 복원은 범위 밖이다.
- 격리 실행에서 기존 KO `직장와` 조사 오류를 실제로 읽었다. KO 원형을 바꾸지 않는 이번
  범위 밖이며 별도 조사 연결 수리 후보다. 원문은 repaired runtime의 ko/default_new_run이다.

## 이어보기

- [265](queue_archive/ORDER-265.md) 이야기 카드·습관·생각 라벨, [266](queue_archive/ORDER-266.md) 관계 괄호 검사.
- [264](queue_archive/ORDER-264.md) 커피 차수 검사, [262](queue_archive/ORDER-262.md) 선물 메뉴 안내,
  [261](queue_archive/ORDER-261.md) 저장 물건명 갱신, [243](queue_archive/ORDER-243.md) 역사 CI 수리.

## 활성 사양 원문

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

## 실제 실행 경계

- 원110키×2의220초안과 독립 전수 언어GO/필수0를 보존한다. JA검수/수용0이다.
- 기존 첫 check는 CN7행/TW4행에서 title-lock·구독자수를 원화로 오인·둘 다/매월/한 번도
  수량 인식 경계로 실패했다. 첫 출력과 모든220행의 기존 validator 진단을 보존한다.
- 사전 허용한 분리 규칙대로 ending_arrival11·ending_relationships7·epilogue_father8·
  epilogue_jiyeon5의31키×2=62는 HOLD다. 후보를 줄여 원220의 기계 통과로 부르지 않는다.
- 나머지 독립16기능79키×2=158만 승인값 그대로 반영한다. 별도79 export/check를 실행하고
  apply_patch 설치 뒤 clean 제품에서 재export·기존 import --accept로 실제 receipt를 받는다.
  이 import는 동일값이므로 제품 변경0이며 원39292에158만 더해39450/b113이다.
- 원220의 재저작·새 검사 확대·원문 왜곡0. 보류62의 후속은 backlog에 남기고 다음 초안을 우선한다.

자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.
공개GO1·인간OPEN45·본편HOLD 유지. 원어민/실제화면/인간플레이/물리패드 관측으로
바꾸지 않으며 외부 출시·스토어·지출·법률 인증0이다.
