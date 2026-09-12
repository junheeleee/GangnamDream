# 관계 패널 표시·세 언어 번역 — 결과

[x] ORDER-240 — 2026-09-12 완료. 독립 Poincare의 work_unit GO 한정이다.
실제 source `ad7ff36b2118928ed9bfe007363475d6fcb51e04`, tree
`0f54fa5da0cf18fcd86ab39b3f39bb0f55238c5b`; 정확 검토 HEAD `7b4bcce09b880883ebd392a2d4d22091abd467c0`.
공개 GO1·인간 OPEN45·본편 HOLD를 유지한다. 자동 검사는 재미·깊이·문체 판정이 아니다.

## 변경·수용

- 소개팅·썸·전 연인의 표시 category만 연애 관련/Romance로 중립화했다.
  empty는 현재 없는 범용 행동판 대신 실제 이야기 진행으로 안내한다.
  MainGame KO/EN pair2 역치환으로 전체 원형 exact. 나머지 연인/partner fallback,
  저장 ID/type/name·관계 단계·힌트13 경계·돈·확률·AP/VIP 효과는 변경0이다.
- UI30×3=90: JA 기존28 직접 검수 중6정밀화/22보존, 신규2; CN/TW각30 신규.
  실제 신규 dictionary 값62, 변경 기존값6이며 이전 연인/empty key는 삭제0이다.
  독립 번역 전량90의 필수0, 권고3을 채택해 초기87값 유지/3정밀화했다.
- clean `cdc3ae1`에서 UI 저작 전 initial30×3을 export했다. clean
  `0bbf6a1344ab0166b7feb11302843d8fbb526487`에서 final/export/check/import 모두
  각30·changed_files0·INCOMPLETE/human OPEN이다. initial/final 원문은 이전
  target hash 필드 외 exact이며 공식 response는 승인 번역표와 같다.
- portable 제품 `d7733c4ad46bd02c003a3838b922a3af195ce0a9`, 신규90/b1 외
  기존38,497/b97/meta9·역사 top-level raw 역복원 exact. 현재38,587/b98:
  JA12,861, CN/TW각12,863. 언어별 사건11,578·엔딩234·catalog834,
  UI215/217/217이다. 보호/author-only·나머지 UI·원어민·렌더는 별도다.
- collector 실제 calls3356/legacy3322/KO2849/static+context2878,
  context34calls/29IDs. 현재 collision100/format28과 역사101/29를 구분한다.
  source2 역투영은 역사 대조에만 쓰며 실제 collector·기존29(내부19 포함) 원형을
  보존한다. 고정24는3정상/21변조다. 전체 포착17388, 지원17059/미확정329;
  UI 합집합3570·미확정 포함3899는 최종 실플레이 UI 분모가 아니다.

## 검증과 첫 실패

- 첫90 L1은 CN/TW VIP 단수2를 잘못 차단했다. 독립 언어 검수는 `有个人/有個人`의
  생략된 一를 인정했다. 별도241 exact-source 수량 수리 뒤 같은90 오류0,
  source/target/hash/ID/순서와 나머지 필드는 모두 exact다. 번역을 검사에 맞춰 바꾸지 않았다.
- 새 actual-node/함수 검사는16가족×5언어=80, 힌트 입력43·metric 경계12다.
  첫 실행은 표시80 exact/상태70 PASS였고 passive_missing_name·VIPempty10이 실패했다.
  원래 before는 MainGame 초기화 이전 상태를 복원한 값이며 stats_changed refresh는
  director 주차 flags를 초기화할 수 있었다. 각 입력 준비의 마지막 실제 `_refresh_all`
  뒤 before를 잡는 harness 수리만 했다. 수치 기대/80 ID·순서·표/43 입력 변경0이다.
- 같은80 재검 모두 PASS, 최종 효과10의 전체 before/expected/after·delta{}를 확인했다.
  최초에는 전체state hash만 있어 원래의 정확 delta를 소급 관측했다고 쓰지 않는다.
  최종15입력 전후/current exact, engine exit0·stderr0·양쪽log fatal0·restore1,
  process/storage 오류0이다. 원형 실패 로그와 임시 격리 storage는 보존했다.
- 기존239의65는 원형으로1회 PASS, 상태65·표시65 exact/13입력 불변.
  그 검사의 VIPempty 기대는 기존 lookup을 읽으므로 새 번역 정답 증거로 세지 않는다.
  새80은 승인된 VIP 번역을 독립 literal 기대값으로 비교했다.
- 최종 전체수용 hash/L1 38,587/errors0, 1,185입력 전후exact,70.778601667초/1회.
  240/241 공유 명시 차선 `relationship-panel-vip-quantity` 첫9 PASS,
  1,195입력 exact/87.844097208초. fullself259, JA122, ZH12446,
  EN leak0, registry143, queue25/fence4, agent222, context/queue PASS.
  ZH skeleton marker를 전체 번역/실플레이 완료로 쓰지 않는다. 전체감사·240주·
  공개 패키지 재빌드·원어민·실제 화면 판정은 실행0이다.

## 범위와 근거

```text
도달 경로      : RELATIONSHIP_PANEL_CHECK_OK cases=80 locales=5 source_keys=30 hint_rows=43 isolation=preautoload rendered=0
생산자 ↔ 독자   : MainGame._relationship_type_label/_rel_effect_hint ↔ _render_sidebars Label; VIPempty ↔ GameState.add_log
바꾸는 상태     : 번역 수용38497→38587; source copy2; 저장/게임플레이 변경0
포기 시 잃는 것 : 없음 — 선택/효과 신규 저작이 아닌 표시 수리
서사 위치       : 전체판 공유 관계 패널·기존 로그; 새 사건0
장면 계층       : 해당 없음 — UI 현지화
닫는 것         : 이30키·source2 내부 단위; 공개/인간/전체판 게이트 닫기0
```

실제 렌더·가독성·원어민·정상 속도 전체 플레이·물리 패드 감각은 미관찰이다.
save-language는 parsed 관계/로그/플레이어명 왕복이며 전체 legacy migration이나
기존 플레이어 disk save 검사가 아니다. 로그 날짜 metadata는 기존 logger 소유다.
인접 VIP 완료/toast2·GameState 새 인연1, 다른 UI 및 칭호의 EN 직행은 별도 미완료다.
판정은 [독립 보고](../agent_reviews/ORDER-240.json)가 소유한다.

아래 SHA는 `.git/full-game-localization/`의 원형 증거이며 다음 세션이 필요할 때만 읽는다.
- `order240-translation-final.json`: `e15b3ac750de17740d616033ce89ece5c32c57b4062fb778cb86b1954aea1c01`.
- `order240-language-review.json`: `7f458b74c3690965065eabb29c183c25eb5ad03a55dc72650379058dc2106386`.
- `order240-source-static-review.json`: `9999ca64150962c49f501a5b870e34791dc0b3408c44057018690e704c65fc92`.
- `order240-relationship-panel-final.json`: `6bef3fe03d5feed9c494272efb7b6cf825bb6432ab88ccf60308ac0e1f8ec2cd`.
- `order240-runtime-review.json`: `4b270fb35b120e2e09de000192b61c808aa71c810041f75860db41a27a5d1f7c`.
- `order240-prior65-replay.json`: `99b496509a37670e9ed8141383a2bda26b9b462f7d8134892bf8fa4ba9886b92`.
- `order240-repaired-l1.json`: `350bba3e27d5bc3365fd49e913e70d9929ee369c8ce1ca81ac9625c5b56a3e0b`.
- `order240-official-final.json`: `99a4cb1e17f335c218b534fac2df28d00ec536bc484f93bfc0a0e368e637ddb4`.
- `order240-official-check.json`: `801065234b5530d84c157439f11d33ce0b365d8c568c5dac1c097ff66025cf58`.
- `order240-official-import.json`: `24b8fdc5cfeed6bea461e0887a019a256e29f877a3eca865e007bbc2517d9c3c`.
- `order240-portable-proof.json`: `e3d50972711877737068d5f1e317a58ec44dc9c91320867f4638a705e28a1fb7`.
- `order240-all-accepted-l1.json`: `e97238243218685534afb27e2dc18c68c4f1944f53333855c76a2d2a5fb9d71a`.
- `order240-241-named-first.json`: `cba47a654858b6567e4539c19377abafa587478fceac1e680d19237bfb58a132`.

## 선언·진행 원문 보존

# Active Queue Spec: ORDER-240

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-240 [P0·현지화] 관계 패널의 단계 과장·옛 안내를 고치고 나머지 문구를 번역한다

**[~] 2026-09-10 Codex 착수 — 아래 파일만 소유한다.** clean 기준
`af9874d1acb768433087827c84b7b9f43bf03a5e`, tree
`ec9a00329dc9398ad22bec33457a2e28451c828f`. 선행239는 내부 단위 GO이며 본편 HOLD다.
읽기 준비는 git-private `order239-next-relationship-panel-preflight.json`과 Plato의
현재 MainGame 조기 반환 경로 대조다. 준비 측정은 제품 수리·번역 수용 실적이 아니다.

## 깊이 3문과 판정 단위

1. 제거하면: 소개팅·썸·전 연인에도 type romantic만으로 연인/Partner가 붙고,
   빈 카드가 현재 없는 범용 관계 행동판을 안내한다. CN/TW 나머지30키는 EN으로 폴백한다.
2. 장기 상태: 표시 category/copy만 바꾼다. 관계ID/type/이름/호감·신뢰/돈/확률/진행 변화0.
3. 대안: ID별 연애 단계를 발명하거나 AP 메뉴를 되살리는 대신 중립 category와
   실제 이야기 진행 안내를 사용한다. 저장 이주·신규 시스템·새 장면은 없다.

하나의 관계 패널 현지화 단위이며 [첫 실행 재조정] 키30을 기능군별15+15 두 묶음으로
검수한다. 기존 core31 중 가족1은239 수용분으로 보존하고 나머지30×3=90을 표적으로 한다.
JA 새2(유형/empty)·기존28 직접 검수, CN/TW 각30 신규 예상이다. 실적은 공식 수용 뒤 기록한다.
JA 용어집의 관계→人間関係와 현재 関係 불일치도 선택키 안에서 정밀화한다.

## 정확한 소유권

- Plato: `scenes/MainGame.gd`의 `_relationship_type_label` romantic1과 `_render_sidebars`
  empty1의 KO/EN pair만. `tools/ja_translation_pipeline.py`의 exact 두 치환 현재-view
  adapter와 추가 회귀만. 기존 collector 실제 관측·역사 manifest/partition/fixture 기대값은 보존.
- Rawls: `tools/RelationshipPanelLocaleCheck.tscn`(embedded GDScript),
  `tools/run_relationship_panel_locale_qa.sh`. 기존239 실행기·bootstrap/storage/process helper는
  읽기 재사용한다. 239 테스트와 production helper는 수정하지 않는다.
- ROOT: `locale/ui_ja.json`, `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json`의 선택30만.
  이전 연인·이전 empty key는 다른/역사 소비자를 위해 삭제0. `content/meta/full_game_localization.json`
  신규90/b1만, 기존38,497/b97/meta9·역사 top-level 원형 유지.
- ROOT 운영: `tools/audit_scope.json`, `CLAUDE.md`, `docs/CODEX_QUEUE.md`,
  `docs/CODEX_QUEUE_L3_PENDING.md`, 이 사양·`docs/queue_archive/ORDER-240.md`,
  `docs/WORK_LOG.md`, `docs/STATUS.md`, `docs/queue_backlog/FULL_GAME_LOCALIZATION.md`,
  `docs/agent_review_decisions.json`, `docs/agent_reviews/ORDER-240.json`.
- `.git/full-game-localization/order240-*`와 공식 source/response/receipt는 사적 증거.
  Poincare는 비저자 전량90·KO/EN source2·최종 exact-source 검수다.

## 고정 source·번역 경계

- romantic 표시만 `연애 관련` / `Romance`. 실제 partner fallback의 기존 연인/partner는 유지한다.
- empty는 `아직 기록된 인연이 없습니다. 이야기를 진행하며 맺은 인연이 여기에 표시됩니다.` /
  `No connections recorded yet. Connections formed through the story appear here.`
- 나머지는 준비 core의 탭/제목/호감·신뢰, 유형5/인연 fallback, hint13, affinity5,
  누군가 fallback와 empty VIP log다. `인연` 중복2는 한 키로 세고 가족은 기수용이다.
  인접 VIP 완료로그·toast2와 GameState 새 인연1은 별도 미선택이다.
- hint의 기존 호출·동거·지원을 번역이 추가로 확정하거나 배우자·생존 부모·재결합을 만들지 않는다.
  story/관계 정본·KO 사건·EN 사건·12 overlay·RelationshipSystem·GameState·LocaleManager·
  DataRegistry·SaveManager·project·SHIPPING_LANGUAGES·폰트·플레이어 저장은 비소유다.
- 계산상 calls3356/legacy3322/context34/IDs29 불변, KO2848→2849,
  static+context2877→2878, collision101→100(형식29→28). 실제 관측으로 확인하며
  실패하면 수리한다. 역사107-key 계획·원본 manifest·이전239 회귀는 덮어쓰지 않는다.

## 실행·검증

1. 선언 commit/push 뒤 source2/collector 수리. Rawls는 저작 전 기존 helper의
   입력·효과·13hint 경계/5affinity 경계·empty/unknown 기대와 격리 요구를 고정한다.
2. clean source checkpoint 뒤 UI 변경 전 initial30×3 공식 export.
   KO에서 각 지역 직접 저작, 기존JA28 포함90 전량 대조. source2가 먼저 정확해야 한다.
3. actual card Label의 type/empty/metrics·affinity5·hint13와 missing fallback·VIPempty를
   KO/EN/JA/CN/TW로 고정 대조한다. negative threshold·unknown·name14/custom·저장 상태
   보존도 확인하며 기대값은 product 출력으로 만들지 않는다. 개수는 사전 roster가 정한다.
   headless actual node/함수는 render/native/human GO가 아니다. 이전65 회귀도 동일 입력으로1회.
4. 첫 선택L1을 보존, 동일 최종본문 clean checkpoint에서 final export/check/import,
   신규90 portable 결속·이전 수용 raw 역복원. 전량수용 hash/L1 1회·표적 정적 차선1회.
   validator 오탐·추가 source 변경이 필요하면 그 파일 범위는 별도 선언하고 진행한다.
5. 결과 포함 exact source를 비저자가 판정한 뒤 허용 metadata만 마감·main/mirror 동기화한다.
   공개 GO1·인간 OPEN45·본편 HOLD 유지. 전체감사/240주/패키지·공개 출시0.

규범 승격 없음: 기존 I18N·ROMANCE·WORK_UNIT 적용. 이번 두 source·30키·소유·검수는 일회성이다.

## 2026-09-12 중간 결과 — 최종 판정 전

- source2·collector 현재-view 구현, JA/CN/TW90 전량 대조 뒤 공식 수용했다.
  final export/check/import clean `0bbf6a1344ab0166b7feb11302843d8fbb526487`,
  portable `d7733c4`에서38,587/b98. 기존38,497/b97/meta9 역복원 exact.
- 첫 L1은90 중 Chinese2 수량 오탐. 별도241 수리 뒤 같은90 오류0이며 원문·target·
  나머지 필드 exact다. 실제 단수 번역과 첫 실패 원형을 유지했다.
- actual-node80 첫 실행70/80(표시80일치·상태10실패)을 보존했다. 초기화 후의
  상태를 before로 잡는 harness 수리만으로 같은80 PASS, 수치 기대·43hint 그대로다.
  첫 hash만으로 원래 상태 delta를 관측했다고 쓰지 않는다. 기존65는 원형으로1회 PASS.
- 원형·최종 증거는 git-private `order240-relationship-panel-final.json`,
  `order240-prior65-replay.json`, `order240-repaired-l1.json`, `order240-official-*.json`.
  실제 렌더·원어민·인간 플레이·기존 플레이어 disk save 왕복은 미관찰이다.
- 241과 합친 `relationship-panel-vip-quantity` 차선은 기존8과 ZH self1의9개다.
  두 오더의 공유 검사를 최종 입력에서 한 번 실행한다. 전량 수용 L1과
  비저자 exact-source 최종 판정 뒤에만 닫는다. 현재 공개·인간 원형/본편 HOLD다.
