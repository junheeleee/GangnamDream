# ORDER-478 — 시장 국면을 코드명이 아닌 표시 이름으로 기록한다

#### [x] ORDER-478 [위임 수리] 시장 국면 로그5언어와 공유 일본어1잎 — 2026-10-07

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


## 2026-10-07 마감 — 새 시장 로그5언어·공유 JA1 한정 GO

- source candidate `38efd9b2e13f2f50d682897075ffcc7a9e8ad8ae` / tree `4600717702c5271138450e6705790a4a776afb19`.
  비저자 [전수보고](../agent_reviews/ORDER-478.json) SHA `02d4e432fc0dc409f712348f038358076b7f72bd20e51f83e641a7f588bab985`.
  새 로그의 known3을 각 언어 표시 이름으로 기록하며 JA 횡보장1을 横ばい相場로 고쳤다.
  내부 enum·난수2호출/순서·기간·확률·가격·매매·과거 저장 로그와 비소유 raw는 불변이다.
- source2 `20443aa07a5f260ec4b581aaec97c89388004705` / parent
  `dfc23a93d8f3c028528dae2405bd63b11e6fac4d`, support16
  `d68bc66b228b0a908defef747d206e05ac66a0fc`, ledger1 `ae01837dc6cfc0a272534ed38e654513d21cc6e5`를 분리했다.
  ledger directparent는 actual export source d68bc66이다. native/render OPEN과 기존273 raw배치/
  41848 accepted 값·순서·옛 history 핀을 보존→274/41849, 최초수용1/기존accepted교정0/새UI키0.
  actual runtime/collector에는 현재 코드와 텍스트만 읽히며 옛값은 정확 역사 비교에서만 역상한다.

### L2 — 표시 보정 한 단위, 전 칸

| 단위 | 도달 경로 | 생산자 ↔ 독자 | 바꾸는 상태 | 포기 시 잃는 것 | 서사 위치 | 장면 계층 | 닫는 것 |
|---|---|---|---|---|---|---|---|
| 시장 국면 로그·공유JA1 | MARKET_CYCLE_LOG_CHECK_OK locales=5 cases=25 roll_log=15 unknown=5 restore=5 prepared_component_only=true; runtime1/result.json; 자연월초/화면/입력0 | InvestmentSystem.gd:138,293 → GameState.gd:4025,4032,4035 ↔ MainGame.gd:10197,10201,10203; MainGame.gd:6241,6260 → InvestmentSystem.gd:15,18(코드독해) | 소유 log 인수 raw enum3→localized labels3×5; JA 횡보장 横歩場→横ばい相場1; enum/확률/기간/가격/매매 원문변경0; seed3/1/2→timer10/11/7 및 다음RNG3518853771/2033395789/3570245418(구식=현재) | InvestmentSystem.gd:138·GameState.gd:4032→MainGame.gd:10197; 표시 교정 없으면 enum neutral/bear/bull 기록; 새 선택/기억/발화 주차0 | MainGame.gd:6241–6260·InvestmentSystem.gd:15–18 월초 경제→MainGame.gd:10185 기존 로그; 새 chapter/beat/route0 | MainGame.gd:10185 기존 보조 로그; 신규 T1/T2/T3 장면0·기존 T3 표면 보정; 전경 장면/정점 승격0 | known3×5 새 시장 로그 raw enum 노출0; JA 공유 횡보장 오역1→0; 인접 횡보 横歩 변경0·과거 저장 로그수정0·실제화면/자연월초/본편 출시GO0 |

### 실제 검증과 제한 재사용

- prepared25: engine0·3.134221초, fresh UUID pre-autoload.
  known3×5 actual _roll_cycle→GameState.add_log15, unknown5, 복원5 전수.
  고정seed3/1/2의 기존 두 난수 호출 oracle와 timer10/11/7·다음 RNG가 같다.
  localized message/날짜/turn17/type=market·signal1·append, 가격/보유/현금/달력 불변.
  stdout=Godot·stderr/엔진오류0·engine/runner/전체tracked3228/보호11/로그 보존.
  정확25 ID SHA `ec7335cf7cd2e1227a8f836e50491658424c742b72c1f6be87df75a7e1097bc3`. prior log는 준비 sentinel 보존이며
  실제 옛 사용자 저장을 복원해 관찰했다는 뜻이 아니다. global RNG 전체 복원/자연월초/렌더/입력 주장은 없다.
- official: 원본 current collector 실제1 반환까지 700.135664초(fresh 입장 검사 포함),
  actual JA1 export/check/import3 각각0·stderr0/changed_files0·native OPEN.
  공식 단계 886.890371초. 전체 실제 source census/immutable inventory/
  원본 함수 identity와 tracked/HEAD를 guarded reuse 전후에 확인했다. ledger/pin만 허용한
  명시 handoff 뒤 집중4 `[('market_cycle_label_history_self_test', 77), ('order469_source_compat_self_test', 15), ('order470_source_compat_self_test', 10), ('pr31_intake_history_self_test', 28)]`·original365 함수1·원본 CLI9,
  original _accepted_event_additions(locale3)는 실제 통과했다. 그 뒤 원 context 검사는
  CLAUDE.md 18041B>18000B로 exit1, 원 pipeline FAIL과 fresh 예외 탈출을 그대로 보존한다.
  직접 자식 `38efd9b2e13f2f50d682897075ffcc7a9e8ad8ae`는 CLAUDE 최근상태1행만 17948B로 줄였다.
  나머지3227 tracked·213 census·원로그36·제품/함수/config 불변을 대조해 성공한 원검사만 재사용했다.
  context 재검사+미실행 queue/등록검사/목록4는 별도 12.012242초·실제0이며
  새 original fresh5 입출구·213 census·lazy Main 슬롯은 별도 773.359551초에
  정상 종료했다. 합계 원본 CLI 검증12+목록1/365원본함수1은 완료이며 새 미해결 실패0.
  원 pipeline을 PASS로 소급하거나 성공한 제품 게이트를 새후보 실행으로 세지 않는다.
  guarded calls6/boundary37,
  원 실패 pipeline 8324.186217초(명시 handoff 대기 포함). 하위 명령의 모든 수집까지
  전역1회라고 주장하지 않는다. 목록1은 검증 실행이 아니다.
- EN coverage257/speech257/scene audio133/narrative machinecore140의 전체 읽기 입력과
  KO/EN glob각127·기존 원로그8을 직접 대조해 477 실제 계약 결과만 재사용했다.
  narrative의 인간/agent print_pending 출력은 현재 상태로 재사용하지 않는다.
  fullbody 원본 코드·event KO127/목표어각128·meta6·기존역사코드의529 core입력과 옛
  event 투영/핀을 보존한다. Investment를 읽는 lifecycle 입장은 옛값 재사용이 아니라
  이번 actual collector의 audit_author_only 성공에 귀속한다. ledger-dependent365/본문수용3은 새로 실행했다.
  옛 fullbody 분모/selftests·새 fullbody 실행·자연 도달성 PASS로 확대하지 않는다.
- prepared25 actualsubject는 d68bc66에 남는다. 최종후보까지 변경3은
  `['CLAUDE.md', 'content/meta/full_game_localization.json', 'tools/market_cycle_label_history.py']`, 나머지3225 tracked·실제 소비자/
  Godot/fixture/bootstrap 입력은 동일하다. 새5 receipt RHS만의 handoff와 current original gates는
  별도로 검증했다. 옛430/40·독립240주·옛 대형UI/전체 selftest 반복0;
  이번 JA UI 원본1은 실제 1494.906396초 실행했다.
- private final_reuse의 첫 실행은 실제 입력 목록의 모듈명 오타로 KeyError exit1이었다.
  원실패/tool chunk/실행시간/runnerSHA를 보존하고 실제 owner가 읽는
  order316_header_source_compat.py를 목록에 바로잡아529 입력을 빠짐없이 재대조했다.
  이 실패는 제품/원본 게이트 실패가 아니며 PASS로 소급하지 않는다.
  그 실패기록에 원runnerSHA1필드를 추가한87B가 먼저 완료된 final-reuse1의 기록 지문과
  달랐다. 원 결과를 덮지 않고 exact byte inverse·의미동일·현재3228 raw/기존증거를
  final-reuse2 successor에 결속했다. 검사/제품 재실행이나 실패 기록 소급0이다.

| 실제 증거(.git/order478-20261007.SC3sdU/) | SHA256 |
|---|---|
| runtime1/result.json | `f2ee175344bf1305836329e6f6b3766ca125bd5f2f060c92e7bb203747ef25b7` |
| pipeline1/official-result.json | `d859b73ce5a021f62c59ab7a90f99e9fe971b304ac09e2ad7615ddf616d584bc` |
| pipeline1/result.json | `d1b8671a5cef9a795213a7a04002e7a5b12bd5d029f1258854c6a86e4a356dfd` |
| continuation1/result.json | `6fa9d5e0cbd6840ac572778cc5dbefc31e3f766bd0ecf078de0344ed933d3b62` |
| proof-close1/result.json | `0f0a85763d86dd1e98966f0ce09ffe7bda57bc1abc93fc8fcc0d0db0922b6f09` |
| contract-reuse1.json | `62b4e72d9465bb26b983ddff89f0de931953956cde4d42cb2a55bb0018f66476` |
| final-reuse1.json | `0359854ebe8ff774a3df2e5d940769699f3b2a01508558f0ec2b568f677d51e1` |
| final-reuse2.json | `e38920a0ffe5f09f98efdd602b9b927870b33a7781283da1bada53a375bc4396` |
| final-reuse-failed1.json | `d2cf37481922a5bbeba12a36f1daf2dda9263b7eb8f319a04373f8182371e9ca` |

JA 인접 횡보=横歩·분석모달, 화면/입력·자연월초·5장·원어민·사람·물리패드·본편 출시 HOLD.
project.godot/공개manifest/PCK/player/seed/human·옛agent 판정·공개GO1·인간OPEN45·149captureFAIL 보존.
gangnamdream-dev의 정확 소유·source/receipt 분리·pre-autoload 격리·영향 표적검수·입력동일성 재사용을 적용했다.
승격: 새규범0. 기존 정본 적용이며 이번 exact2/ledger1·역상/증거결속은 일회성이다.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.
