# ORDER-478 — 시장 국면을 코드명이 아닌 표시 이름으로 기록한다

#### [~] ORDER-478 [위임 수리] 시장 국면 로그5언어와 공유 일본어1잎 — 2026-10-07

477 source 한정 GO 마감 뒤 착수한다. 이 선언 커밋·push 뒤 정확 소유만 구현한다.
선언 시점 구현/QA/수용0이며 실제 화면·자연 진행·원어민·패드·출시 GO가 아니다.
실물 근거는 InvestmentSystem._roll_cycle의 raw enum 인수와 Main 시장 로그 소비자,
FULL_GAME_LOCALIZATION.md의 남은 neutral/bear/bull 인수 항목이다.

## 한 판정 단위 / 깊이3문

- 지우면: 부모 로그만 번역되어 플레이어가 실제 읽는 인수에 neutral/bear/bull이 남는다.
- 뒤의 독자: MainGame._run_week_start_economy → InvestmentSystem.process_month/
  _roll_cycle → GameState.add_log/action_log → MainGame._render_log가 읽는다.
  상태·24주 경제 차이는 만들지 않는 기존 표면 결함 수리이며 새로운 선택이 아니다.
- 경쟁: 기존 시장판의 상승장/Bull Market·하락장/Bear Market·횡보장/Sideways 쌍을
  재사용한다. 로그만 현지화하고 enum·확률·가격·매매·기간을 바꾸지 않는다.

한 단위는 실제 시장 국면 로그다. 함께 쓰이는 JA 횡보장 1값은 横歩場→横ばい相場로
교정한다. 같은 사전의 横ばい 표기와 [다이와 금융 용례](https://www.daiwa.jp/glossary/YST1807.html)에
맞춘 에이전트 의미 판단이지 원어민 관찰이 아니다. 인접 횡보=横歩 값/분석모달은 비소유다.

## 정확 소유 / 분리 전이

- root 제품: systems/InvestmentSystem.gd의 _roll_cycle 로그 인수와 순수 표시 이름
  helper만. known3은 위 기존 LocaleManager.ui 쌍, unknown은 원문 enum 그대로다.
  새 시장 사실·횡보로의 fallback 정규화0. 기존 난수2호출/순서·timer·fear_greed·
  crash_risk·market_context·가격·매매·과거 저장 로그·인접 함수는 불변이다.
- order469_review 제품: locale/ui_ja.json의 top-level 횡보장 값 정확1잎.
  CN/TW/나머지JA 값/키/순서/raw는 불변이며 중역/자동변환0이다.
- source2만 별도 커밋한다. root 공식 수용: content/meta/full_game_localization.json
  JA ui:횡보장:/횡보장만 fresh export/check/import --accept --replace-existing.
  기존 문구1교정이되 accepted 행이 없으므로 최초수용1/기존accepted교정0/배치1,
  신규UI키0이다. 이전273 raw배치/41848키 보존→274/41849가 기대되며 실제 실행으로
  확정한다. private source/response/receipt/portable header를 결속하고 ledger1은
  별도 커밋한다. CN/TW 기존465 국면3·272 부모 수용/JA 나머지 retained는 보존한다.
- order469_history 지원: tools/market_cycle_label_history.py/_self_test.py(새2),
  tools/order469_source_compat.py/_self_test.py, tools/pr31_intake_history.py/
  _self_test.py, tools/order470_source_compat.py/_self_test.py.
  source2/공식ledger1을 actual Git direct-parent·global diff·literal inverse·현재
  raw/함수 identity로 먼저 증명한다. 별도 현재 단계에서만 접속하고469~477 핀과
  477 source5/receipt1/metadata2를 덮지 않는다. source census에서는 Investment만
  역상하고, JA1잎/ledger는 별도 exact4raw 비교 역상으로 복원한다. census는
  Investment→477 KO→476 Main 순서다. source census와 targets/수용 단계를
  분리하며 PR31 기존 custom inverse seam을 쓴다. 실제 runtime/collector에는 옛
  값/과거 원문을 반환하지 않는다. ui_translation_append/365/Main history 변경0.
- order469_review 지원: tools/ja_translation_pipeline.py의 정확 sealed appendix,
  tools/investment_loss_gate_audit.py, tools/investment_loss_gate_self_test.py 및
  tools/investment_ap_copy_self_test.py.
  old collector 호출/핀/반례는 보존하며 actual 새3호출·unique0 예상은 구현 뒤 실측으로
  확정한다. 현 source/JA target/ledger 증명 뒤 역사 비교만 내리고 현재 호출은 다시
  조립한다. 손실 게이트 PROTECTED14의 Investment1 비교만 연결하며 실제 입력은 현재다.
- root QA: tools/MarketCycleLogCheck.gd/.tscn, tools/market_cycle_log_audit.py,
  tools/audit_scope.json 전용 차선. 기존 pre-autoload 격리 bootstrap/ProseRecallCheck
  재사용, predicate/RNG stub0·실제 사용자 저장/seed0.
- 비저자 order469_main: docs/agent_reviews/ORDER-478.json만 실제 최종후보·source2/
  receipt1·로그 소비와 원문·모집단·실제 증거 전수검수 뒤 작성한다. 제품 저작/
  프로젝트QA/engine/import/커밋0.
- root 운영: CLAUDE.md 현재, docs/CODEX_QUEUE.md, docs/CODEX_QUEUE_L3_PENDING.md
  순번, 이 사양/queue_archive/ORDER-478.md, docs/WORK_LOG.md, 생성 docs/STATUS.md,
  docs/agent_review_decisions.json.

project.godot·공개 manifest/PCK·사용자 저장·seed·human/과거agent 판정·이벤트/효과/
전체판 분모·release_content_inventory·arc_flow/ScreenshotQA/이전 fixture 변경0.
새 필요 파일/범위는 구현 전에 별도 선언한다.

## 표적 검증 / 마감

1. 제품2 raw hunk·정확 잎/함수·주변·게임플레이 전수보존과 typed 실제 Git 전이,
   현재 source census/JA target/원장 prefix·첫수용1·새배치1 및 인접 변조 반례.
2. [첫 실행 재조정] fresh UUID에서5언어×known3 실제 _roll_cycle/log15,
   unknown helper5, 복원5의 작은 모집단25를 계획한다. 고정 seed의 기존 randi_range+
   randf와 비교하여 cycle/timer/crash_risk 및 다음 난수 소비가 같음을 확인한다.
   실제 add_log 메시지·kind·append/시간·가격/현금/보유 불변과 singleton/locale 복원을
   확인한다. process-local global RNG 전부 복원/자연 월초/렌더/입력 관찰 주장은 하지 않는다.
3. 원본 collector 한 actual collect와 frozen source/census/함수 identity 재사용,
   공식 JA1 export/check/import, 새 시장 source/history·손실 비교·AP 직접 역상,
   JA UI·ZH normal·demo_localization_scope --lang all·English Hangul·release inventory
   원본 진입·등록/큐/정본을 실제 실행한다. 중복 JA demo/pipeline demo 진입은
   동일 public source 계약을 읽는 세 원본 경계로 대조한다. 코드명 helper3call/
   unique0은 실측이며 기존 수용·native/실제 화면/출시 상태는 승격하지 않는다.
   full-body는 원본 order365_ui_receipt_compat.current_source_errors를 fresh에서
   실제1회, 원본 full_body_translation_scope._accepted_event_additions를3언어에
   실제 적용한다. 새 ledger 전체 schema/native/checksum/receipt shape·events binding과
   신규UI1 외 기존41848 accepted 불변을 증명한다. 나머지 event/body/closure는
   477 실제 결과·코드/원문/target/story_map/lifecycle/역사끝점 불변으로만 재사용한다.
   narrative/scene_audio/speech/EN coverage는 각각 실제 읽는 전체 입력 집합을 대조해
   같을 때만 477 계약 결과를 재사용하며 새 출력·원검사 재실행으로 세지 않는다.
   인간/에이전트 상태는 현재 원장/resolver가 별도 소유한다. Investment를 읽는
   release owner는 재사용하지 않는다. 영향 없는430/40·독립240주·대형UI/옛전체
   selftest 반복0, validator 약화0. 영향 실패는 실제 원인을 수리하며 새 미해결 실패0.
4. L2전칸·독립 최종 판단 뒤 main 마감. 로그와 공유 JA1만 GO하며 인접 JA횡보,
   실제 화면/입력·자연 진행·5장·원어민/사람/물리패드·본편 출시 HOLD를 보존한다.

규범 승격: 새규범0. 기존 현지화·공식교정·실제 사실·증거분리 정본 적용이며,
이번 exact source2/ledger1·역상/검수·입력 재사용 결속은 일회성이다.
자동 통과는 재미·깊이·문체의 증거가 아니다.
