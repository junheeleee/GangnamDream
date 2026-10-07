# ORDER-482 — 10억 첫 기록의 근거 없는 가속 보장

#### [~] ORDER-482 [위임 사실 수리] 10억 돌파의 가속 보장절만 제거한다 — 2026-10-08

481 한정 GO/main 5aaebe8 뒤 선언한다. 선언 전 구현·새QA·collector·수용·엔진0.
본편HOLD·공개GO1·인간OPEN45는 보존한다. 게임 출시/원어민/실제화면 판정이 아니다.

## 한 판정 단위 / 깊이3문

- 지우면: GameState:4327–4329는 asset_1b_reached 최초 flag와 로그만 쓰며 가속
  효과를 실행하지 않는다. 현재 KO/EN/JA의 가속 보장은 실제 소비자와 다르다.
- 뒤의 독자: GameState.check_game_over → add_log/action_log → MainGame._render_log.
  선택/24주 상태 차이0. 순자산 기준·1회 flag·기존 저장 로그는 그대로다.
- 경쟁: 새 가속 시스템/동적 계산을 만들지 않고 보장절만 삭제한다. 10억 돌파와
  30억의 3분의1 사실은 유지하며 다음 기록도 다른 이정표도 고치지 않는다.

## 정확 소유 / 전이

- root 제품 `autoloads/GameState.gd` KO/EN literal2: `💰 자산 10억 돌파 — 30억의 3분의 1.` /
  `💰 Assets passed KRW 1B — one third of the goal.`. 임계/flag/경제/엔딩/인접 raw 불변.
- order469_main 제품 `locale/ui_ja.json`, `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json`
  새키1씩 직접 KO번역: JA `💰 資産が10億ウォンを突破 — 30億ウォンの3分の1。`,
  CN `💰 资产突破10亿韩元 — 30亿韩元的三分之一。`,
  TW `💰 資產突破10億韓元 — 30億韓元的三分之一。`. 옛JA키/값·순서 보존.
- source4만 actual Git 직접부모·전역경로로 별도 commit. root 공식
  `content/meta/full_game_localization.json`: 원 export/check/import 각3·collect9로
  새키 최초3만 수용한다. 기존277 raw배치/41852 accepted 보존→280/41855 예상,
  실제 결과로 확정. 교정0·oldJA accepted0·native/render OPEN. ledger1 별도 commit.
- order469_history 지원 `tools/asset_one_billion_log_history.py` 새 leaf helper,
  `tools/wealth_milestone_log_history.py`, `tools/wealth_milestone_log_history_self_test.py`,
  `tools/market_cycle_label_history.py`, `tools/order470_source_compat.py`,
  `tools/pr31_intake_history.py`, `tools/investment_loss_gate_audit.py`.
  actual typed source4/receipt1·literal/raw inverse·current Git/disk/HEAD/config/function·
  fresh 입장/정상·예외 종료를 검증한 후만 480 current로 역사 투영한다.
  옛480·481 핀/반례/모집단/함수 경계는 덮지 않는다. 성공cache/임의raw면제0.
- order469_main 지원 `tools/ja_translation_pipeline.py`, `tools/ja_translation_audit.py`,
  `tools/zh_translation_audit.py`. JA actual call 새10억→옛10억의 sealed appendix만
  합성하고 oldJA retained 정확1/receipt0을 증명한다. CN/TW fraction은 정확 KO전체·
  UI ID·통화역할/분모3분자1에 한정해 fraction span만 numeric 비교에서 제외한다.
  원문 전체의 script/token/LF/term/money 검사는 유지한다. 잘못된 분수·금액·부가수량·
  sign/%/시간·누락/중복·source/key 변조는 거절한다. 일반3분 파서/교육비 규칙 불변.
- root QA `tools/AssetOneBillionLogCheck.gd`/`.tscn` 새2,
  `tools/asset_one_billion_log_audit.py` 새1, `tools/wealth_milestone_log_audit.py`,
  `tools/audit_scope.json`와 private .git runner/입력지문/로그. 옛20억 fixture 불변.
- 비저자 order469_review `docs/agent_reviews/ORDER-482.json`만 작성한다. 실제 source,
  제품4/수용3/지원·표적검증 원로그 전수 판정. 저작/QA/engine/import/commit0.
- root 운영 CLAUDE현재상태·CODEX_QUEUE/L3순번·이 사양/archive·WORK_LOG·STATUS·
  agent_review_decisions만. 추가 범위는 편집 전 선언한다.

## 표적 검증 / 비용 경계

1. source4 전수 raw inverse·typed 실제이력·현재보존 및 새fraction/retained/call 반례.
   old77/96/181/365·전체pipeline/대형UI/240주를 이유없이 반복하지 않는다.
2. [첫 실행 재조정] 5언어×순자산10억 미달/정확/초과15억/목표30억×최초/기록완료40,
   현금11억−대출2억=9억5, singleton/locale 복원5의 준비50. 실제 check_game_over/
   add_log·전체serialize·signal·기존sentinel·중복방지/ending을 대조한다.
   pre-autoload UUID 격리·stdout/Godot오류검사·사용자save/seed불변. 자연진행/렌더/입력 아님.
3. 원main export3/check3/import3의 actual collect9를 같은 호출의 selective return
   관찰로만 결속한다. 함수교체/collector후킹/입출구생략/가짜공식영수증0.
   바뀐잎3/현재source·target·receipt지문·옛prefix 보존. 실패/중단은 따로 남긴다.
4. en_coverage/english_hangul·새source/fraction/역사 소비자만 영향검수, 등록/목록/
   context/queue/diff. 같은 입력의 과거결과 제한재사용과 새실행을 구분한다.
5. 독립 최종판정·L2전칸 뒤만 완료하며 확인된 결과만 main push한다.

project.godot·공개manifest/PCK·사용자save/seed·인간원장·과거agent판정·사건/효과/
분모·release_content_inventory·Demo/ArcFlow/ScreenshotQA 변경0. 새규범0;
exact 전이/모집단/실행계획은 일회성이다. 자동검사는 계약 증거이지 재미·문체 증거가 아니다.
