# ORDER-459 — 코인 통화 수리의 정확한 번역 원장 전이 연결

#### [x] ORDER-459 [P1·수리 의존] 원문2파일·기존9receipt·3교정batch

**[~] 착수 — 2026-10-05.** 458 기본 full-body 검사가
`ORDER-365: whole current proof rejected: UI append: KO/runtime source changed outside reviewed boundary`
로 실패했다(28.980초). 원문·화면 수리는 통과했지만 현재 전체원장 승인은 아니다.
새로운 원문 변경을 과거 UI receipt에 무조건 허용하지 않는 정상적인 차단이다.

## 범위·소유

- claude_handoff_review: `tools/coin_call_receipt_history.py`만 작성한다.
  실제 f9b4337→632f88b 원문/phone 전이와632f88b→49124fd 기존9번역 교정을
  immutable commit/tree/blob/전체raw·정확한15leaf/비소유 역상으로 검증한다.
- root: `tools/ui_translation_append.py`의 정확한 단일 전이 dispatch와
  source-manifest/current-proof 연결, `tools/audit_scope.json`의 좁은 검사 등록,
  CLAUDE·큐/L3·이 사양/보관·458/457 상태·WORK_LOG·생성STATUS·판정원장.
- receipt_tests392: `tools/coin_call_receipt_history_self_test.py`만 작성한다.
  원문/receipt/locale/선택자/비소유 bytes/rollback·위조manifest의 최소 변이를 검증한다.
  과거 대형 suite나 변경하지 않은 변이 전량을 반복하지 않는다.
- independent392: 저작물과 실제 증거를 읽고 마지막
  `docs/agent_reviews/ORDER-459.json`, 의존 해소 후 `ORDER-458.json`만 작성한다.
- root만 프로젝트 import·검사·엔진을 실행한다. 제품 원고/번역/원장·자산·런타임
  및 기존 source proof/365/collector 자체의 변경은0이다.

## 불변 경계

새 허용범위는 위 두 실제 전이뿐이다. source census의 KO사건파일과story_rules를
정확한 이전바이트로 투영하여 기존 UI header를 비교하되 실제 현재source·HEAD·disk
결속을 유지한다. 다른 원문이나 미래 변경을 허용하는 wildcard/manifest 예외는 없다.
JA/CN/TW 기존3leaf씩의 source와target receipt전체를 검증하며, ledger 비교용
역상은 exact9entry·3batch·accepted checksum만 복원한다. 실제 파일을 되돌리지 않는다.
UI3사전·기존228batch·수용41755·비소유 원문/receipt를 그대로 지킨다. coverage증량0이다.
현재 raw와 원본 header를 새 과거값으로 덮거나 일반 UI append 규칙을 완화하지 않는다.
새 공통 캐시·새 검수 프레임워크·기존 검사 재설계는 하지 않는다.

## 표적 검증·완료

1. 새 focused 검사: 실제 고정 전이를 한 번 읽고 순수 변이를 검증한다. 실패/성공
   결과를 캐시해 현재 Git/파일 결속을 건너뛰지 않는다. 구문·등록·context·queue·diff.
2. 실제 기본 `full_body_translation_scope.py`1회로 현재 전체원장 경로를 재검증한다.
   같은 책임의 standalone365와 기존11행 변이차선을 중복 실행하지 않는다.
3. 458의15leaf/9공식교정·정합/visual/EN·24페이지/16PNG는 실제 source49124fd에
   결속한 선행 증거다. 이 단위에서 제품bytes불변을 다시 대조하고 후속 후보로 연결한다.
   제품이 바뀌지 않으면 화면/공식import를 재실행하지 않는다.
4. 비저자 한정판정 뒤459와458을 각각 마감한다. 457실제 메뉴 진행은 Mac잠금으로
   미실행이므로 열어 둔다. 인간/공개 이력·원본seed2/player34/W195·본편/새package HOLD 유지.

원장 진입 없이 원문만 고치면 이후 UI번역 수용이 매번 거부된다. 선택·경제·정본은
추가하지 않는다. 이 source/receipt전이와 파일 소유·검증은 **일회성**이며 자동PASS는
재미·깊이·문체·원어민·인간 플레이·물리패드 또는 출시GO가 아니다.

## 완료 — 2026-10-05

- exact source `be89b7f86cc40d07145610353fab5d427c920821`, tree
  `ccf14176b3cc7015bfd0d8f8cd33cc462a75010f`에서 공동 focused151 PASS,
  기본 full-body1회 exit0/빈 stderr/688.315초 PASS다. 현재50경로를 거친
  SOURCE_INVENTORY_ONLY이며 shipping1708/11681leaf·runtime/native claim0이다.
- `.git/chapter5-replay/order459-current-first/result.json` SHA
  `a7f694c3aa94f6b0d93de41b1284fe1d329968ee3869076d253d6896692592ec`:
  입력16·player34·seed2+W195·HEAD/tree/status 전후 동일. 제품9파일은
  렌더 source49124fd 그대로이며 화면/공식수용을 다시 실행하지 않았다.
- [독립 보고](../agent_reviews/ORDER-459.json) SHA
  `25c8b11e0ede9e4ce0cb7efafb22369d3d0e95b5a75ca985ee35235cdef780ea`, 한정GO.
  최초136FAIL과 저자/초기 독립읽기의 경로 누락, 중단된 대형차선은 보존한다.
  460 연결은 별도판정이며 자연457/본편/새package/출시HOLD 유지다.
- 규범 판정: 위 전이·소유·검증 지시는 일회성. 기존 WORK_UNIT/I18N 적용, 새 정본 승격0.
