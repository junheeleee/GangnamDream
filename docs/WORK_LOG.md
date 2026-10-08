# WORK_LOG.md — 강남드림 작업 기록

이전 원문 전체는 [검수 재사용 선언 전 보존본](history/WORK_LOG_2026-10-08_pre_order486.md)에 바이트 그대로 이동했다. 보존본의 상대 링크는 이동 전 경로 기준이다.

## 2026-10-09 — 이력 검사54개 제거·제품 계약 복구 (487, CI 대기)

- 사용자 지시·DECISIONS 2026-10-08대로 PR32/484 마감 뒤 이 정리만 진행했다. 실패 전수표는 cad6d39에서 먼저 main commit·push했고, 추가 의존 표는214e9d6/f7cdf69/954c04e에서 삭제 전에 확정했다. 관측163flag/실패 합집합36을 유지하며 과거22·현재13·release 회복1·미관측127을 혼동하지 않는다.
- 아래54파일을 삭제했다. 모두 닫힌 오더의 특정 Git 부모/전체 source bytes·옛 census·역투영 endpoint 또는 그 계측/호출 수 전용 suite다. **이 검사가 지키던 현재 제품 동작이 없었다.** 실제 UI·숫자/통화·장소·시간·배제·receipt·저장·컴파일·데모 동작은 현재 collector/validator와 generic 부정 테스트에 남겼다. 정확 파일별 근거는 선커밋 [전수표](queue_backlog/AUDIT_FAILURE_TRIAGE_2026-10-09.md)에 있다. 삭제 원본은 Git f7cdf69 이전 이력에서 복구할 수 있다.
- 삭제: tools/order305_demo_source_compat.py
- 삭제: tools/order309_source_compat.py
- 삭제: tools/order310_demo_source_compat.py
- 삭제: tools/order313_source_compat.py
- 삭제: tools/order316_header_source_compat.py
- 삭제: tools/order350_source_compat.py
- 삭제: tools/order351_source_compat.py
- 삭제: tools/order365_ui_receipt_compat.py
- 삭제: tools/order469_source_compat.py
- 삭제: tools/order470_source_compat.py
- 삭제: tools/main_game_locale_history.py
- 삭제: tools/meta_title_locale_history.py
- 삭제: tools/opening_rhythm_history.py
- 삭제: tools/holdem_money_history.py
- 삭제: tools/coffee_encounter_receipt_history.py
- 삭제: tools/coin_call_receipt_history.py
- 삭제: tools/pr31_intake_history.py
- 삭제: tools/market_cycle_label_history.py
- 삭제: tools/wealth_milestone_log_history.py
- 삭제: tools/asset_one_billion_log_history.py
- 삭제: tools/meta_title_locale_history_self_test.py
- 삭제: tools/opening_rhythm_history_self_test.py
- 삭제: tools/meta_title_locale_successor_self_test.py
- 삭제: tools/ci_localization_reconciliation_self_test.py
- 삭제: tools/order469_source_compat_self_test.py
- 삭제: tools/order470_source_compat_self_test.py
- 삭제: tools/coin_call_receipt_history_self_test.py
- 삭제: tools/pr31_intake_history_self_test.py
- 삭제: tools/market_cycle_label_history_self_test.py
- 삭제: tools/wealth_milestone_log_history_self_test.py
- 삭제: tools/history_semantic_scope_self_test.py
- 삭제: tools/pr31_main_proof_scope_check.py
- 삭제: tools/holdem_manifest_proof_scope_self_test.py
- 삭제: tools/chapter5_proof_scope_self_test.py
- 삭제: tools/ui_comparison_memo_self_test.py
- 삭제: tools/chapter1_ui_proof_reuse_check.py
- 삭제: tools/holdem_money_receipt_check.py
- 삭제: tools/holdem_banner_receipt_check.py
- 삭제: tools/holdem_banner_locale_receipt_check.py
- 삭제: tools/holdem_betting_receipt_check.py
- 삭제: tools/holdem_table_labels_receipt_check.py
- 삭제: tools/holdem_seat_height_receipt_check.py
- 삭제: tools/holdem_card_color_receipt_check.py
- 삭제: tools/holdem_message_pulse_receipt_check.py
- 삭제: tools/holdem_rank_ja_receipt_check.py
- 삭제: tools/holdem_async_receipt_check.py
- 삭제: tools/holdem_hand_net_receipt_check.py
- 삭제: tools/holdem_victory_particle_receipt_check.py
- 삭제: tools/holdem_canvas_width_check.py
- 삭제: tools/meta_title_locale_successor.py
- 삭제: tools/holdem_residual_locale_check.py
- 삭제: tools/ui_receipt_cost_profile.py
- 삭제: tools/ui_receipt_cost_profile_check.py
- 삭제: tools/scalping_phase_focus_receipt_check.py
- audit.sh의 이력 전용15flag/명령만 제거하여 집계163→148이다. audit_scope의 폐지 tool·old CLI/paths/비용 차선을 정리했으며 등록182/현재 target 누락0/삭제 helper 소비자0이다. 비용 계측·재사용 후속 작업0·다른 새 오더0·새 tool/report/history helper0.
- strict duplicate/NaN/Infinity/1e999 거절·UTF-8 문자 좌표 span·raw exact inverse·공식 source/target/header/batch binding은 기존 ui_translation_append owner로 보존했다. demo manifest 원 SHA·72 사건/467잎·40769 현재 text와 사건 전체 효과/조건 순서 semantic seal을 유지하며 out-of-demo 원문 공백만 비고정이다. 불변 공개14/100잎·reuse8/3지역 source/target seal도 유지한다. old public target값 재현과 공식 receipt가 원래 없는 보호 baseline을 새 원장 수용으로 둔갑시키지 않았다.
- 현재 표적 PASS: UI append109·strict span/parser168·generic projection88, trace187+현재 계약, demo16+62, full-game localization265, JA collector76/UI2952+context29/demo72·467, ZH12623, full-body54, graph64/Year5 22/Chapter5 76, Chapter1현재24/48 및12부정(48주 완성 아님), facts first-win19/ending10/night13/loss gate50+numeric52/hold24/wealth15/recall27/coffee88, gate companion50, gift18/new-run47/notice17/header23, width27/reaction23/log23/AP42. feature liveness는 실제 생성 QA scene 경로를 발견하여 known orphan2를 보존했다. EN coverage/한글누출(형식52·오류0)/narrative continuity/context/queue/diff PASS다.
- 통합 중 실제 실패도 남긴다: trace의 ObjectDB negative를 false branch로 감싼 변조가 accepted되어 current top-level3 probe 의미 guard로 수리했다(전체 audit.sh SHA 재도입0). 새 English registry가 삭제되면서 format2 호출을 놓친 FAIL은 현행2 system-log 소비자 registry를 복원해 오류0으로 닫았다. localization265의 fake UI fixture errors/entries 누락과 coffee 옛 title fixture 충돌은 현재 interface/비소유 synthetic case로 고쳤고 최종265 PASS다. 게임 원문/번역/원장으로 실패를 덮지 않았다.
- docs/KNOWN_FAILURES.md에는 현재 실제 제품 FAIL5만 이유·Codex 소유·2026-10-16 만료로 남긴다. 검사 자체는 실행/FAIL 로그 보존하며 CI opt-in에서만 정확 exit1을 비차단 처리한다. 미설정/exit2+/미등록/중복/빈 사유·소유자/만료/30일초과는 빨강이다. inline gate 부정14 PASS·shell binding/syntax PASS다. 컴파일/EN/원장/서사/음악/데모/저장 검사 삭제0.
- 비저자 causality_audits_author가 root의 gate/CI/demo/strict append를 직접 읽어 blocking0, 저자들도 분리 소유 파일의 현재 부정 테스트를 확인했다. 새 비용 보고/오더별 봉인 보고 대신 이 기록에 근거를 남긴다. 게임·locale·ledger·autoload/scenes/systems·project.godot·human_gates diff0; 로컬 engine/사용자 저장 접근0·원어민/화면/물리 패드 관찰0.
- **정리는 아직 진행 중이다.** 이 source를 main에 올린 뒤 실제 전체 main CI 녹색(정확 KNOWN_FAILURES 제외)을 확인해야 닫는다. 로컬 표적 PASS를 CI/출시 GO로 바꾸지 않는다. 공개 GO와 인간 이력·본편 HOLD를 보존한다. 다음 문장 묶음의 기본 arc_36_unexpected_hand 선택지 수리는 정리 완료 뒤에만 진행한다.
- 마지막 등록 읽기 검수 localization_collector_author가 현재223개 고유 명령의 옵션/수동 argv를 확인했다. 폐지 inventory-history 옵션2곳과 closed408 재사용 suite를 추가 제거한 뒤 유효 등록181/빠진 경로0이다. strict JSON과 실제 대화 이력은 삭제 대상이 아니다. 최종 source commit 뒤 실제 CI를 확인한다.

## 2026-10-09 — 카지노 용어집 중국어 실제 반영·검수 정리 착수 (484 마감, 487 선언)

- 카지노 용어16개를 한국어에서 각 지역으로 옮긴 CN/TW32값과 원공식 receipt2를 main faa71588579d52e5f145b68b313f86d4e4523ec6/tree246f8162830e4290637b017d449081358fcbbe26에 commit·push했다. UI1811→1827씩/원장41855→41887/b280→282다. 기존 pure validate_append가 UI/receipt 대응·원 header/receipt checksum·이전 members/order/raw 역상·JA0을 통과했고 원 source213 SHA는 불변이다. 원값 수동 교체·원공식 collector 대체·새 history helper0이다.
- 도달 경로: actual CASINO_GLOSSARY_CHECK_OK locales=2 translation=32 overlay_reentry=2 singleton_restore=2 prepared_component_only=true. 생산자↔독자: JeongseonCasino.gd:831/63↔LocaleManager.gd:150↔locale/ui_zh-CN.json:1814·ui_zh-TW.json:1814. 바꾸는 상태: 선택16키×2의 영어 fallback→지역 lookup/actual node32 일치·miss0. 포기 시 잃는 것: 선택16 용어·원화·배당/손실 설명의 지역어 표면(주차/게임 상태 변화0). 서사 위치: 선택적 카지노 UI·월 beat 없음. 장면 계층: 보조 UI, 신규 T1/T2/T3 원고0. 닫는 것: source/UI32·준비 컴포넌트36; natural KO/JA2·JA 신규수용0·화면/입력/자연플레이/원어민 OPEN.
- 실제 engine은 기존 prepared fixture와 fresh pre-autoload namespace만 사용했다. exit0·정확 marker·stdout/Godot log fatal0, translation32/reentry2/locale6+game/meta restore2 PASS다. private consumer1 stdout/Godot log SHA b79721b9ba9115634155d0b1638227937587f42964094c2c8ae82f474819ddb8/stderr0. 실제 UI32의 private 원 receipt 파일 SHA CN6acfbec32962632e44ba18c6562d5cd72bcfd475fb5e02f17f12a13266a9ef41/TWd69c38fc6d82f7e271a1948ccc58d36e74c622cfe8881cbcaaeb49c89fd8cd5f를 worktree 제거 전에 main private에 보존했다.
- 비저자 /root/glossary_preexport_review가 실제 main3파일·원 receipt32/b2·새 로그36을 직접 읽어 source/UI 한정 마감 결함0으로 판단했다. /root/translation_status_readonly는 고정482 admission→옛40767 demo 기대값 fallback과 빈 UI stats→KeyError의 인과를 코드로 확인했다. 새 per-order 보고/자가 인간 판정0이며 WORK_LOG에 현재 범위와 한계를 남긴다.
- EN/한글누출·context·diff는 PASS다. JA_UI·JA_DEMO_PIPELINE·JA_DEMO_AUDIT·ZH_DEMO_AUDIT·DEMO_I18N_SCOPE는 실제 exit1/FAIL5다. 종료 tool 응답의 보존본(원 로그 자체 아님)은 private targeted-checks1.json SHA5e237ba1687e4b95653d441a22138923ea41f3db0b70439678b46a67eda23e81이다. 신규 source/UI가 게임을 깨뜨린 증거가 아니라 닫힌 source/UI 전체 핀이 새 append를 거부한 실패이며, FAIL을 PASS로 바꾸지 않는다. 전체CI NOT_GREEN/HOLD와 제품 검사 보존·복구를 바로 다음 [487](queue_active/ORDER-487.md)에 이관한다.
- 최신 승인대로 [484 완료 사양](queue_archive/ORDER-484.md)을 보존하고 단일 검수 정리를 선언한다. 상시 실패 전수표를 먼저 커밋하고 다음 커밋에서 이력 전용 검사를 삭제한다. 지금 삭제0/새 비용 도구0/다른 새 오더0이다. 모든 실행 지시 일회성·새 규범0. 자동 게이트는 도달 가능성과 계약 증거이지 재미·깊이·문체·인간 GO가 아니다. 공개 GO1/과거 인간/원어민/물리·본편출시 HOLD는 불변이다.

## 2026-10-09 — PR #32 적용·카지노 번역 마감 경로 정리 (484, 진행)

- 사용자 승인 문서만의 PR #32를 main b81d2b0에 합쳤다(DECISIONS 추가19줄/다른 파일0). 원484 live guard가 끝난 뒤 로컬도 fast-forward했다. 원문 export6는 실제 CN/TW exit0·원main/collect2·지역별16잎·UI3478/errors0·동일17505잎 지문·passed/preserved/observer복원true다. 원결과/옛 실패는 `.git/order484-20261008.QsF61I/preexport6/`에 보존한다. 아직 check/import·32값 수용·실제 화면 완료가 아니다.
- 새 결정대로 미구현 history helper5 연결·새 전용 self CLI·오더별 검수 보고 계획을 중단했다. 기존 helper의 current 핀은 CN 한 지역만 import해도 다음 TW 원collector를 거부하므로, 같은 제품 후보의 독립 지역 checkout에서 기존 원공식 check/import를 수행한 뒤 UI2·실제 영수증2만 함께 반영한다. 원collector·target hash·제품 검증은 바꾸지 않으며 새 비용 도구를 만들지 않는다. 강남드림 개발 스킬의 소유 선언·표적 검증 원칙에 최신 사용자 결정을 우선 적용했다.
- 484 뒤에는 상시 실패 표를 먼저 커밋하는 검수 정리 오더 하나만 연다. 479·481 및 계측/재사용/시간단축 후속은 중단하고 정리 완료까지 다른 새 오더0이다. 기본 arc_36_unexpected_hand 선택지의 "지난 주말 가지 못한 곳"은 이후 문장 묶음에 포함한다. 원어민·인간·물리 패드·본편/출시 판정은 갱신하지 않았다.

## 2026-10-08 — 번역 검수의 순수 계산 재사용 (486, 완료)

- 수리 B/F와 새 검사/차선만 구현했다. 준비1/2 각각295·원body/pin 보존·실제2의44 PASS다. 실제2는 B/F 원 _read_proof를 각arm2번씩 직접 호출해 전 proof 동일, Git/typed/제품disk 횟수 동일을 확인했다. 선택묶음180.111422→117.587582초, B receipt26→1·F product18→9/receipt2→1이며 추가 module-binding read B52→107/F4→193은 숨기지 않는다. 전체 pipeline 단축률/공식 수용/게임 관찰은0이다.
- 원 actual1은 측정wrapper를 arm별로 새 정의한 정적 결함을 발견해 own child53173 SIGINT로204.155784초 뒤 종료했다. 실제6등가check는 모두true·fatalKeyboardInterrupt·measurementsnull/exit1/preservedtrue다. 예상 F binding 불일치를 실제FAIL로 관측했다고 쓰지 않는다. 측정기는 동일wrapper1회 설치/계수dict만 교체로 수리해 full proof equality를 유지했고 다음actual2가384.389250초/exit0/preservedtrue로 끝났다. 중단원본/실패를 덮어쓰지 않았다.
- private `.git/order486-20261008.YiW24K/`: roster SHA162fe9d03aae4e3eaf5c035b9a9cfaf2de64b782aa6309795b9b0f16e88ef415; prepared2 SHAbe1cbed0fd8afa3adbd58087d02ea8071ed4738fd34a3437d98374dc3a9faa5d; static1 SHA30ae16a6f6f7e3fd507d966acbf40f033c2adf28e15c3eef84ad05d01e1944ca; actual1 SHAbe07f22b81b2b6478a29653b820cd96e980b58c76740e56480c2861c0e172217; actual2 SHAce70a8a89eabbe94ae809bdea1663aa976b28b72d803e73605efe0c98663cceb. 전 실행 HEAD ac0ddc22+소유dirty/3256파일·status·HEAD/tree·명부/runner 전후 동일이며 외부player/seed 전량 실측이 아니다. engine 접근/실행0. 등록219/명시4목록/context/queue PASS, 이 구현시점에는 clean source 후보와 독립 최종 판정이 대기였고 다음 기록에서 마감했다.
- source940ad0bf3250bfae64f3d9ec00ff319da0343e35/tree6e15bc346459c7d4503d00d76fbfebf3bee42b83를 main commit·push했다. 구현4의 QA snapshot/disk/commit SHA 동일을 비저자가 직접 확인했고 clean 후보 재실행0이다. [독립 보고](agent_reviews/ORDER-486.json) SHA64b6b993566c6f759a231b0e30dc5780b92a37210ec225a4db9e20c93c91d43b의 blocking0/work_unit 한정GO를 별도 agent 원장에 결속하고 [완료 사양](queue_archive/ORDER-486.md)을 보존한다. 모든 실행지시 일회성/새규범0, 게임·원어민·공식수용·출시GO 아님. source commit 후 STATUS stale는 후보신원 변화로 보존·재생성한다.
- 원484 preexport5는 own PID18332 SIGINT 뒤 wrapper1/3950.184972초·원main/collect/UI진입1씩·유효collect/export/수용0·보존/observer복원true로 종료했다. 원결과SHA51851de6e81b756f430e269da90244d724d038c08e6b9524883edb4c099e6223과 옛1~4는 그대로다. None 반환1을 성공 수집으로 세지 않는다. 새private pre_export6는 원 main 작업별 cold B/F owner만 감싸 원export2를 재개한다. 원operation/observer·입출구/protected 보존과 종료clear/token복원을 요구하며 연결 실제관찰은486한정GO에 포함하지 않는다.
- 한 시간의 대기와 반복 역사 계산을 실제로 부딪혔으므로 B/F의 성공한 순수 계산만 동기 작업1회 안에서 재사용한다. 원 Git/disk/HEAD/config 입출구·실제 main/collect 횟수·오류/예외 거절을 보존한다. 비저자 설계 조사에서 부분 호출 배수만 확인했으며 전체 병목/시간 기여율·속도 향상은 미측정이다. 강남드림 개발 스킬의 선언·표적·독립/인간 분리를 적용한다. 제품/번역/수용0·새규범0/일회성.
