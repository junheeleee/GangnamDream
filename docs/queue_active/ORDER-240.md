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
