# ORDER-480 — 20억 첫 돌파 기록의 고정 잔여금 안내

#### [~] ORDER-480 [위임 사실 수리] 실제 순자산과 다른 고정10억 잔여 안내를 없앤다 — 2026-10-07

479 한정 GO와 main push `c1e6177` 뒤 착수한다. 선언 commit/push 전 구현·
collector·공식수용·제품QA·엔진 실행0이다. source와 영수증을 분리하고, 실제 수리·
표적 검증·독립 최종 판정 전 완료 또는 본편 GO를 선언하지 않는다.

## 한 판정 단위 / 깊이3문

- 지우면: GameState.check_game_over:4332는 처음 확인한 순자산이25억·30억 이상이어도
  고정 `남은 건 10억 / KRW 1B left`를 기록한다. CN/TW는 이 키가 없어 영어로
  떨어지고 JA는 같은 고정 금액이다. 실제 total_now와 플레이어 로그의 사실이 어긋난다.
- 뒤의 독자: MainGame.apply_monthly_pressure:8667 → GameState.check_game_over →
  GameState.add_log/action_log → MainGame._render_log. 새 선택·24주 상태 차이는0이고
  동일한 최초 돌파 로그의 금액 사실만 고친다. 과거 저장 로그는 재작성하지 않는다.
- 경쟁: 매번 잔여액을 계산하는 새 동적 formatter 대신 기존 문장의 고정 잔여 주장만
  삭제한다. 임계20억·목표30억·최초 flag·로그 횟수·경제·엔딩 라우팅은 그대로다.

근거: CLAUDE의 숫자·현지화 규칙, WORK_UNIT의 위임 판정, 실제 GameState:4310–4362,
FULL_GAME_LOCALIZATION backlog의 이정표 보류10 보존선. 10억의 `3분의 1` 검사 결함과
다른 이정표4는 비소유이며 이번3수용으로 그 보류10 전체를 닫지 않는다.

## 정확 소유 / 분리 전이

- root 제품: `autoloads/GameState.gd` 해당 LocaleManager.ui의 KO/EN literal2뿐.
  KO `🔥 자산 20억 돌파 — 강남이 손에 잡힐 듯하다.` / EN
  `🔥 Assets passed KRW 2B — Gangnam feels close.`. 조건/flag/로그kind·인접 호출/
  총자산 산식·peak_asset·M60 종결·다은 pending·게임플레이는 raw 불변이다.
- order469_review 제품: `locale/ui_ja.json`, `locale/ui_zh-CN.json`,
  `locale/ui_zh-TW.json`에 새 KO 키1씩/직접 KO 번역1씩만 추가. JA
  `🔥 資産が20億ウォンを突破 — カンナムに手が届きそうだ。`, CN
  `🔥 资产突破20亿韩元——江南仿佛触手可及。`, TW
  `🔥 資產突破20億韓元——江南彷彿近在眼前。`를 초안으로 검수한다.
  중역/자동변환0·옛JA 키/값 및 나머지사전 raw·순서 보존. 원어민 관찰 아님.
- source4만 별도 actual Git 커밋한다. root 공식: `content/meta/full_game_localization.json`
  fresh full_game_localization export/check/import로 새 ui 키1×JA/CN/TW 최초수용3.
  현재274배치/41849 및 ja13153/CN·TW14348 원문·accepted-prefix·native/render OPEN
  보존. 기존 accepted 교정0, locale별배치3이면277/41852 예상이며 actual로 확정한다.
  source response receipt 원문과 portable header/현재source revision을 결속하고 ledger1
  별도 커밋. source-call 수/고유키 분모 변경0 예상과 leafID/digest/hash 변화는 구분한다.
- order469_history 지원: `tools/wealth_milestone_log_history.py`/`_self_test.py` 새2,
  `tools/market_cycle_label_history.py`/`_self_test.py`,
  `tools/order470_source_compat.py`/`_self_test.py`,
  `tools/order469_source_compat.py`/`_self_test.py`,
  `tools/pr31_intake_history.py`/`_self_test.py`. exact source4/ledger1의 actual typed
  Git 직접부모·전역 경로·literal inverse·현재raw/disk/config/function·정상/예외 종료를
  먼저 검증하고 역사 비교만479 이전 source/receipt로 투영한다. 기존 핀/원검사/반례는
  덮지 않는다. 실제 collector/runtime는 현재 문자열을 읽는다. census213은 GameState
  정확2문구만 역상한 뒤 기존 Investment 등 전이를 읽으며 old source hash 승격0이다.
- order469_review 지원: `tools/investment_loss_gate_audit.py` 및
  `tools/investment_loss_gate_self_test.py`의 보호14
  중 GameState 정확 문구 비교만 연결한다. `tools/ja_translation_pipeline.py`는 현재
  GameState call 전체 복원 접속으로 변경0을 우선한다. 실제로 필요한 sealed appendix
  연결만 허용하고 다른 소비자·옛 모집단·분모·핀 변경0이다.
  `tools/ja_translation_audit.py`는 보존한 옛JA20억 키 정확1개의 retained 접속만
  소유한다. 새 helper의 typed old/current source·현재 call의 옛키0/새키1·원래JA값/
  accepted 부재를 증명한 때만 허용하며 임의 extra 면제0. 원 전체 UI검사 반복 대신
  `wealth_milestone_log_history_self_test.py`의 exact current/retained/변조 반례를
  order469_history가 함께 소유한다. source4 편집 전 포착한 필수 소비자 연결이며
  새 분모·기존 unknown-extra 규칙·옛 retired 모집단을 바꾸지 않는다.
- root QA: `tools/WealthMilestoneLogCheck.gd`/`.tscn`,
  `tools/wealth_milestone_log_audit.py`, `tools/audit_scope.json` 전용 차선과 private
  `.git/` 원본 runner/로그/실패/입력 지문. 기존 pre-autoload 격리 bootstrap 사용,
  predicate/RNG/경제/종결 stub0·실제 사용자 저장/seed0·물리Mac잠금 요청/폴링0.
- 비저자 order469_main: `docs/agent_reviews/ORDER-480.json`만 소유. 최종 source
  commit/tree·제품4/수용3/원장1/입력 보존과 실제 원로그 전수 검수. 제품 저작/
  프로젝트QA/import/엔진/commit0. 저자自가 GO로 완료하지 않는다.
- root 운영: CLAUDE 현재 상태, CODEX_QUEUE/L3 순번, 이 사양/완료 archive,
  WORK_LOG/생성 STATUS/agent_review_decisions. 새 필요 범위는 편집 전 별도 선언한다.

project.godot·공개 manifest/PCK·사용자 저장·seed·human/과거agent 판정·이벤트/효과/
release_content_inventory·전체판 분모·Demo/ArcFlow/ScreenshotQA/옛 fixture 변경0.

## 표적 검증 / 비용 경계

1. source4 hunk 전수·비소유 raw/조건/flag·콜수·ledger raw prefix·실제 typed stage를
   검증한다. 정상 current와 인접 문구·조건·다른키·직접부모·추가경로·재해시 원장/
   census 변조·warm Git/disk/HEAD/function/config·정상/예외 종료를 구분해 증명한다.
2. [첫 실행 재조정] 5언어×순자산20억 미달/정확/초과25억/목표30억×최초/기록완료40,
   현금21억−대출2억=순자산19억5, locale/ singleton 복원5의 준비50을 계획한다.
   실제 GameState.check_game_over/add_log를 읽고20억 로그0/1·flag·kind·타로그와
   건강/정신/중독/peak/현금/보유/대출/종결 상태를 대조한다. 준비값·실제결과·복원을
   별도 기록하며 자연 월말·렌더·입력 관찰로 승격하지 않는다. 기존 seed/user 파일 불변.
3. 실제 collector1회만 수행한다. 바뀐 leaf3의 원래 export/check/import 각3실행을
   source별 입력 지문과 같은 invocation의 원본 fresh 가드로 결속한다. owner 함수
   후킹/입장·종료 생략/가짜공식영수증0. 새FAIL은 수리 뒤 같은조건으로 검증한다.
4. en_coverage/english_hangul 및 actual 소유 소비자·source/receipt/census seam만
   영향 검증한다. 옛 UI365·전체JA/UI·240주·전체pipeline·화면 검사를 이유없이
   반복하지 않는다. old 성공은 정확 입력동일일 때만 제한 재사용하며 신규실행으로
   부르지 않는다. main push는 검증 완료분과 선언만, 실패/미관찰은 보존한다.
5. L2 전칸·독립 최종 판정 뒤 metadata owner 검수와 main 마감. 본편HOLD·공개GO1·
   인간OPEN45를 유지한다. 자동검사는 계약 증거이지 재미·깊이·문체의 증거가 아니다.

규범 승격: 새규범0. 기존 사실·현지화·변경 입력 중심 검수/위임 규칙 적용이며 이
exact raw 전이·준비모집단·실행 계획은 이번 단위의 일회성이다.
