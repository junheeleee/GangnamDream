# ORDER-487 — 감사 실패·삭제 후보표 (삭제 전)

2026-10-09. DECISIONS 2026-10-08과 사용자의 PR #32 후속 지시를 실행한다.
이 표를 먼저 commit/push하고, 삭제는 그 이후 별도 커밋에서 한다.
현재 삭제0, KNOWN_FAILURES 적용0, 제품 원문·번역·저장 변경0이다.

## 증거와 관측 한계

- 기준 main: `894a6c09e710f6817fb7c8c1b106a11e4cf8e326`.
  현재 audit.sh 종료 집계는 중복 없는 **163개 flag**다. 결정문의 106은 과거 수량이다.
- A: 마지막 끝까지 실행된 실패 CI
  [37547183644 / job 112553876826](https://github.com/junheeleee/GangnamDream/actions/runs/37547183644),
  source `0356d316ffa7307724fad15e805b0ffdeb6d270f`, 2026-10-07 종료.
  원 종료 요약의 실패31개를 빠짐없이 아래에 옮겼다. A만 있는 행은 현재 재실행 FAIL을 뜻하지 않는다.
- B: 484의 실제 종료 응답5개(exit1). 원 응답 보존본은
  `.git/order484-20261008.QsF61I/targeted-checks1.json`, SHA256
  `5e237ba1687e4b95653d441a22138923ea41f3db0b70439678b46a67eda23e81`.
  원 로그 파일인 것처럼 표기하지 않는다. source/UI는 현재 main과 같다.
- C: 위 기준 main에서 기존 명령만 실행했다. peak, exposed-state, audio catalog,
  direction catalog, full-run direction, feature liveness, runtime trace, release inventory와
  dashboard freshness다. 앞7개와 dashboard는 exit1, release inventory는 exit0다.
  이는 누락 원인 확인을 위한 표적 실행이며 새 계측기·새 검사 도구가 아니다.
- D: 후속 [37794089692](https://github.com/junheeleee/GangnamDream/actions/runs/37794089692)는
  `d231078d`에서 audit.py ERROR0 뒤 다음 ORDER365 명령의 출력 없이 약6시간 후 취소됐다.
  취소를 전 검사 FAIL/PASS로 바꾸지 않는다. 현재
  [37845053788](https://github.com/junheeleee/GangnamDream/actions/runs/37845053788)의 정적 감사·밸런스
  job은 성공했지만 전체 감사 job은 진행 중이다. 따라서 **현재 전체 CI 녹색 아님**이다.

실패 이름의 합집합은36개다(A31 + B5). 현재 직접 확인한 FAIL은13개(B5 + C8),
이전 FAIL 중 현재 PASS로 확인한 것은 release inventory1개다. 나머지22개는 A의 실패·현재 코드
의존 조사까지다. 나머지127개 flag는 이 표가 PASS를 발급하지 않는다. 최신 전체 감사가 아직
완주하지 못한 관측 공백을 숨기지 않고, 삭제 후 실제 main CI에서 목록 밖 실패를 모두 잡는다.

## 실패 전수표

처리의 **삭제**는 닫힌 오더의 역사 전용 명령/분기만 뜻한다. **고침**은 기존 제품 소유자의
역사 의존을 끊는 것이다. **KNOWN_FAILURES**는 검사 자체를 유지하며 이유·소유자·30일 이내
만료를 별도로 등록할 후보일 뿐, 이 표만으로 CI 예외가 생기지 않는다.

| 검사명 (audit.sh flag) | 지키는 제품 동작 | 실패 원인 / 관측 | 처리 |
| --- | --- | --- | --- |
| ORDER365_UI_RECEIPT_CURRENT_EXIT | 없음: 완료365의22키·옛3파일 Git 전이 봉인 | A: PR31의 고정 HEAD/product 불일치. D는 이 명령에서 출력 없이 취소 | 삭제. generic append/공식 영수증 검사는 보존 |
| ORDER365_UI_RECEIPT_SELF_TEST_EXIT | 없음: 위 전이의 역사 self-test | A: 같은 whole-current 고정 거부 | 삭제 |
| ORDER351_SOURCE_CURRENT_EXIT | 없음: 완료351의 옛 source/receipt admission | A: 309/313/350/351 whole-file successor 핀 불일치 | 삭제 |
| ORDER351_SOURCE_COMPAT_EXIT | 없음: 위 고정 transition self-test | A: 같은 핀 불일치 | 삭제 |
| ORDER351_SOURCE_HISTORY_EXIT | 없음: 옛 Git endpoint 재현 | A: 같은 핀 불일치 | 삭제 |
| ORDER350_SOURCE_CURRENT_EXIT | 없음: 완료350 source admission | A: 이후 정상 원고 변경을 고정 핀이 거부 | 삭제 |
| ORDER350_SOURCE_COMPAT_EXIT | 없음: 위 전이 self-test | A: 같은 핀 불일치 | 삭제 |
| ORDER350_SOURCE_HISTORY_EXIT | 없음: 옛 endpoint 재현 | A: 같은 핀 불일치 | 삭제 |
| ORDER309_SOURCE_COMPAT_EXIT | 없음: 완료309 source 전이 self-test | A: 이후 정상 source를 옛 successor와 비교 | 삭제 |
| ORDER309_SOURCE_HISTORY_EXIT | 없음: 옛 endpoint 재현 | A: 같은 핀 불일치 | 삭제 |
| ORDER313_SOURCE_COMPAT_EXIT | 없음: 완료313 source 전이 self-test | A: 이후 정상 arc_events를 옛 endpoint와 비교 | 삭제 |
| ORDER313_SOURCE_HISTORY_EXIT | 없음: 옛 endpoint 재현 | A: 같은 핀 불일치 | 삭제 |
| META_TITLE_HISTORY_RECONCILIATION_EXIT | 역사 reconciliation 자체는 없음. 현재 타이틀 번역 제품 조건은 별도 소유 | A: FIRST_START_NOTICE_HISTORY_FAIL kind=meta | 역사 전용 suite 삭제; 현재 호출·타이틀/템플릿 검사는 유지 |
| CI_LOCALIZATION_RECONCILIATION_EXIT | 역사 reconciliation 자체는 없음 | A: FIRST_START_NOTICE_HISTORY_FAIL kind=ci | 역사 전용 suite 삭제; 실제 JA/ZH/데모 검사 유지 |
| RELEASE_CONTENT_EXIT | 실제 shipping/author_only·심의 사실 원장의 현재 내용 일치 | A: ending_content_sha256 낡음. C: 현재 PASS(events1813, demo1806) | 유지. 이미 풀린 실패를 예외에 넣지 않음 |
| STORY_GRAPH_CONTRACT_SELF_TEST_EXIT | 현재 월 경계 소유권·typed graph 변조 거절 | A: 실제 graph 전 검사에서365/PR31 whole-current proof 거부 | 고침: 역사 gate만 제거, 현재 graph/변조 검사 유지 |
| STORY_GRAPH_CONTRACT_EXIT | 현재 사건의 월 경계 소유·전달 조건 | A: 같은 선행 history 거부 | 고침 |
| FULL_GAME_RUNTIME_TRACE_SELF_TEST_EXIT | 전 구간 추적 runner·occurrence 기록 계약 | A: runner의 옛 exact-source SHA 불일치 | 고정 byte seal만 분리. 실제 계약은 유지; 잔여 실패는 KNOWN_FAILURES 후보 |
| FULL_GAME_RUNTIME_TRACE_CONTRACT_EXIT | 추적기의 주차·상태·occurrence 소비 계약 | A/C: expected c906ff8b…, current30b17b2a… | 위와 같음. 원 runner/게임 변경0 |
| YEAR5_REFERENCE_ROUTE_EXIT | 마지막 해 reference-only 경로가 live 해금/중복 경로를 만들지 않음 | A: 실제 검사 전365/PR31 immutable proof 거부 | 고침: 역사 projection만 제거, 현재 route 조건 유지 |
| CHAPTER5_HUMAN_REJECT_EXIT | 5장 사실 안전선·인간 REJECT 재발·공개 데모 보존 | A:365 whole-current proof 거부(self-test146은 당시 PASS) | 고침. 인간 판정/현재 내용/데모 계약 불변 |
| PEAK_CHAIN_EXIT | 정점 장면의 선택·대화 왕복·회수 밀도 | A/C: arc_sangchul_deduction만 EXPAND, gold-standard 불일치(30/31) | 유지·KNOWN_FAILURES 후보. 산문 수리는 이 오더 밖 |
| EXPOSED_STATE_EXIT | 인물이 알 수 있는 직업·관계·장소 사실만 서술함 | A/C: undeclared employment3·relationship1, Hyunsu room KO/EN2 | 유지·KNOWN_FAILURES 후보. 사실/원고 원장 수정은 이 오더 밖 |
| CHAPTER1_INVENTORY_HISTORY_EXIT | 없음: 완료363→PR31의 옛 inventory 전이 | A: PR31 whole-current admission 실패 | 역사 CLI/전용 self-test 삭제. 현재 release inventory 유지 |
| CHAPTER1_CAUSAL_LEDGER_SELF_TEST_EXIT | 현재 인과·state receipt·저장 왕복·오입력 거절 | A: 오래된 파일 snapshot·proof binding 때문에 fixture 거부 | 고침: 역사 admission/옛 snapshot 비교 분리; typed 상태·저장 변조 검사 유지 |
| CHAPTER1_CAUSAL_LEDGER_EXIT | 1장 선택 생산자↔독자의 실제 인과와 typed receipt | A:365/PR31 history 실패와 옛 파일/registry binding 비교 | 고침. 현재 semantic causality/runtime proof를 삭제하지 않음 |
| SCENE_AUDIO_CATALOG_EXIT | shipping 사건별 음악·환경음 intent | A/C: author_only로 내린 지연6개가 manifest에 남음 | 유지·KNOWN_FAILURES 후보. 장면 음악 검사 삭제 금지 |
| SCENE_DIRECTION_CATALOG_EXIT | shipping 사건의 배경·시점·연출 intent 누락 방지 | A/C: manifest와 shipping event set 불일치 | 유지·KNOWN_FAILURES 후보. manifest 저작은 이번 범위 밖 |
| FULL_RUN_DIRECTION_EXIT | 전 구간 연출 분류의 실제 shipping 집합 일치 | A/C: author_only 지연5개가 extra 분류로 남음 | 유지·KNOWN_FAILURES 후보 |
| FEATURE_LIVENESS_EXIT | 게임 진입점 없이 추가된 runtime 코드 검출 | A/C: 독립 QA scene tools/story_header_safe_area_check.gd를 새 dead script로 잡음 | 검사 유지. 기존 독립 scene 근거로 오탐 고침(먼저 파일 소유 선언) |
| STATUS_DOC_EXIT | 현재 저장소 사실을 보여 주는 생성 현황의 신선도 | A/C: DASHBOARD_STALE. 현재 후보/판정 결속 변화 원인 추가 확인 필요 | 유지·생성/비교 원인 고침. 낡은 문서를 PASS로 바꾸지 않음 |
| JA_UI_EXIT | 현재 JA 정적 UI·placeholder/숫자/호칭 검사 | B: source-history 거부 inventory.stats={} 뒤 migrated_context_ids KeyError | 고침: 역사 의존 제거 + 오류 inventory의 정상 FAIL 보고 |
| JA_DEMO_INVENTORY_EXIT | 현재 데모 source/leaf·정적/동적 UI 수집 | B(보고명 JA_DEMO_PIPELINE):482 whole CN/TW UI/원장 핀이 새32 append 거부 | 고침. 실제 collector·데모 leaf/topology 보호 유지 |
| JA_DEMO_AUDIT_EXIT | 데모 JA target/누락/형식 검사 | B: 실제72/467 수집 후 위 gate가 옛40767 source 기대값을 반환 | 고침. 현재 target/보호 leaf/coverage 검사는 유지 |
| ZH_DEMO_AUDIT_EXIT | 간체/번체 구분·숫자/통화·placeholder·coverage | B: 같은 history gate + 빈 stats KeyError | 고침. 제품 언어·format/숫자 검사는 유지 |
| DEMO_I18N_SCOPE_EXIT | 현재 데모 범위·fingerprint·prepared/shipping 분리 | B:482 gate 거부 후40767 != 현재40769, old SHA 비교 | 역사 전체 UI/ledger pin 분리. 공개 M01~M06 byte/leaf 보호는 유지 |

## 삭제할 역사 전용 파일: 정확 후보

아래는 runtime 디렉터리에서 참조하지 않는 audit 어댑터다. 완료 오더의 fixed commit/blob·
whole-file bytes를 요구하거나 과거 predecessor로 역투영한다. **일반 parser/현재 receipt 검증을
기존 제품 소유자에 먼저 남긴 뒤** 삭제한다. 과거 증거는 Git으로 복구 가능하다.

| 정확 파일 | 제품 동작이 아닌 이유 / 보존할 독자 |
| --- | --- |
| tools/order305_demo_source_compat.py | 완료305의 source endpoint. 현재 demo scope/공개 보호 leaf는 demo_localization_scope에 유지 |
| tools/order309_source_compat.py | 완료309 before/after source 역투영. 현재 마지막 해 조건은 year5 checker에 유지 |
| tools/order310_demo_source_compat.py | 완료310의 demo source 전이. 공개 데모 내용 계약 자체는 유지 |
| tools/order313_source_compat.py | 완료313 source endpoint. _loads의 duplicate/비정상 숫자 거절은 ui_translation_append로 보존 |
| tools/order316_header_source_compat.py | 완료316의 header source admission. 현재 UI context 수집은 pipeline에 유지 |
| tools/order350_source_compat.py | 완료350 전이. _Document 문자좌표 span·_ordered는 기존 append 제품 소유자에 보존 |
| tools/order351_source_compat.py | 완료351 전이 합성. generic parser를 남긴 뒤 의존 제거 |
| tools/order365_ui_receipt_compat.py | 55행 fixed commit/tree와22키 old receipt. generic validate_append/공식 receipt는 유지 |
| tools/order469_source_compat.py | 완료469 author_only 전이의 고정 before/after. 실제 lifecycle·shipping 분리 검사는 유지 |
| tools/order470_source_compat.py | 완료470 원고 전이. generic span은 기존 owner로 보존; 현재 사실 검사는 유지 |
| tools/main_game_locale_history.py | 과거240→239→220 bytes 관측 어댑터. 현재 MainGame UI 호출/format 수집은 유지 |
| tools/meta_title_locale_history.py | 완료242 insertion 역투영. 현재 semantic UI collector와 타이틀 표면은 유지 |
| tools/opening_rhythm_history.py | docstring은149 수리지만 실제 소유는 완료463의 단일 commit·11개 타이밍 역상(84~134행). 활성149 화면/리듬/skip 검사 자체는 유지 |
| tools/holdem_money_history.py | fixed Git whole-file SHA·완료 수리 stage chain. 현재 숫자/통화/I18nInfrastructure 소비자는 유지 |
| tools/coffee_encounter_receipt_history.py | 완료448 receipt/source endpoint. 현재 커피 장면 사실/문자 조건 검사는 유지 |
| tools/coin_call_receipt_history.py | 완료458 receipt/source endpoint. 현재 수신·비용·번역 조건은 유지 |
| tools/pr31_intake_history.py | 완료468 intake·direct-parent·whole-current admission. 제품 사실 검사의 generic _Document는 보존 |
| tools/market_cycle_label_history.py | 완료478의 고정 source/receipt pin. 현재 market formatter·번역 형식은 유지 |
| tools/wealth_milestone_log_history.py | 완료480의 fixed log/UI/receipt endpoint. 실제 재산 기준·flag·표시 검사는 유지 |
| tools/asset_one_billion_log_history.py | 486행 이후 완료482 fixed source4·receipt3 endpoint. 새32 UI append의 비제품 거부 원인 |

전용 self-test/역사 suite 후보도 함께 삭제한다:

- tools/meta_title_locale_history_self_test.py
- tools/opening_rhythm_history_self_test.py (완료463의 Git/source 역상만; 활성149의 화면 검수와 분리)
- tools/meta_title_locale_successor_self_test.py (칭호 완료오더의 fixed raw·history suite;
  현재 타이틀/형식 조건은 제품 collector/validator에 보존)
- tools/ci_localization_reconciliation_self_test.py (main history rollback/stage endpoint suite)
- tools/order469_source_compat_self_test.py
- tools/order470_source_compat_self_test.py
- tools/coin_call_receipt_history_self_test.py
- tools/pr31_intake_history_self_test.py
- tools/market_cycle_label_history_self_test.py
- tools/wealth_milestone_log_history_self_test.py
- tools/history_semantic_scope_self_test.py (완료486 순수 계산 재사용 계측)

기존 compat 파일 안의 self_test/historical_self_test도 같이 사라진다. 추가 cost-only suite
`pr31_main_proof_scope_check.py`, `holdem_manifest_proof_scope_self_test.py`,
`chapter5_proof_scope_self_test.py`, `ui_comparison_memo_self_test.py`는 실제 게임 실행이 아니라
옛 proof 호출 수/이전 구현 동등성·context 재사용을 검사한다. 정확 파일 소유 선언 후 삭제 후보다.
generic malformed 입력을 함께 가진 ui_fixed_ledger_projection_check/ui_append_value_parse_check는
**전부 삭제하지 않고**, fixed REF_COMMIT/SHA·옛 구현 비교만 분리한다.

Holdem 전용 receipt suite의 삭제 후보는 다음13개다. 실제 플레이/그림 관찰이 아니라 이전 stage
raw pin·inverse·trace·수량을 고정한다. 안의 유용한 formatter/현재 collector 조건은 기존 제품
검사로 보존한 후 제거한다. audit.sh 호출은0, audit_scope 등록을 정리한다.

`holdem_money_receipt_check.py`, `holdem_banner_receipt_check.py`,
`holdem_banner_locale_receipt_check.py`, `holdem_betting_receipt_check.py`,
`holdem_table_labels_receipt_check.py`, `holdem_seat_height_receipt_check.py`,
`holdem_card_color_receipt_check.py`, `holdem_message_pulse_receipt_check.py`,
`holdem_rank_ja_receipt_check.py`, `holdem_async_receipt_check.py`,
`holdem_hand_net_receipt_check.py`, `holdem_victory_particle_receipt_check.py`,
`holdem_canvas_width_check.py` (모두 tools/).

audit_scope의 history-semantic-scope, ledger-whitespace-470, ledger-whitespace,
holdem-manifest-proof-scope, ui-comparison-memo, chapter5-proof-scope는 역사/비용 차선이라 폐지 후보다.
카지노 현재 숫자/숫자 소유 validator 차선은 유지한다. 삭제 전에 실제 등록 ID와 파일을 대조한다.

## 지우지 않는 것과 의존 분리 조건

- opening_rhythm_history의 docstring만 보고 활성149 검사로 분류하지 않는다.
  완료463 사양이 정확한 소유자이며 삭제 대상은 source 역상뿐이다. **활성149/L3 OPEN**의
  실제 프롤로그 시간·화면·skip 검수는 지우지 않고, 완료로 바꾸지도 않는다.
- ui_translation_append_self_test와 full_game_localization_self_test는 generic receipt·숫자의
  소유/위치/부호·원시 보존을 지킨다. 오더 번호가 있다는 이유로 통째 삭제하지 않는다.
- `_loads`는 duplicate, NaN/Infinity와 `1e999` overflow도 거부해야 한다.
  `_Document` span은 UTF-8 byte index가 아니라 문자 좌표다. `_ordered`·raw_inverse도 유지한다.
- JA pipeline의 원 현재 호출 수집·context/API/format·동적 housing 공급자와 full_game의
  원 collect→targets→check_batch→merge_selected, 보호 leaf/previous target/공식 receipt는 유지한다.
- Chapter1 checker는 inventory 역사 CLI와 old source snapshot admission만 분리한다.
  현재 typed state, 실제 runtime 소비자, invalid receipt/저장 roundtrip 검사는 보존한다.
- Chapter5/year5/story graph/fact audits는 old whole-file gate를 걷어내되 현재 사실·효과·배제 조건을
  유지한다. scene/audio·compile·manual save·demo runtime·English Hangul은 삭제 목록에 없다.

## 완료 전 남은 일

표의 선커밋 → 별도 삭제/기존 owner 수리 커밋 → 잔여 정확 실패의 이유·소유자·만료 등록 →
실제 main CI 녹색 순서다. UNKNOWN·취소·누락 flag는 알려진 실패로 자동 수용하지 않는다.
목록 밖/만료 실패는 빨강이며 전역 skip은 없다. 현재 전체 CI·원어민·실제 화면·본편 출시 HOLD는
불변이다. 이 표와 후속 정리는 게임 완성/출시 GO가 아니다.
