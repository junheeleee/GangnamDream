# Active Queue Spec: ORDER-363

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-363 [P1·검증] 콘텐츠 검토 기록의 정확한 후속값을 1장 역사 비교에 연결한다

2026-09-28 Codex 발행. 361의 실제 Chapter1 normal/self 실패를 분리한 후속이다.
362의 본문 재검토와 지문 갱신 뒤 착수한다. 아래 선언 후 구현·표적 실행을 마쳤으며 원형pin 변경0이다.

## 2026-09-28 실제 구현·실행 결과 — 최종 독립 판정 대기

- 정확3도구만 수정했다. 현재 raw와 관측 SHA 및 선행 admission을 먼저 확인한
  뒤 새로 읽은 immutable Git 8객체의 신원·내용을 검증한다. 360의6필드와362의
  2필드만 raw literal로 역변환하여 원래156 SHA에 연결한다. 캐시·새 공용 모듈0.
- 기존101/151~156 상수·pin·원형 모듈·`_file_digest` 불변. 363의 기존 함수 변경은
  snapshot gate/self_test/main 3개이며364는 기존반례 mock owner 한 줄이다. 양성 fixture4곳의 함수명만 원복하면
  기존 self_test 전체 AST와 동일하다. 새63사례는 현재원문/claim 결속, rollback,
  공백·인접필드·사실·공개pin·다른경로·Git 위조/누락/timeout·성공 뒤 실패를 검사한다.
- 최초 표적6종 PASS 후 full1FAIL을 보존하고,364의 원형 mock owner 한 줄 복원 뒤
  표적18 및 full689 실제 PASS. 수용선은8종9실행(8PASS/1FAIL), 최종8종 PASS다.
  실제 **689=기존622+361추가4+새63**이며 focused63·표적18은689에 포함되어 별도 합산하지 않는다.
  normal은 `debt_codes=8 blocked=3` 및 기존 W25~48 24슬롯 gap을 그대로 보고한다.
  이는 ledger snapshot 검증이지 인과 부채 해소나 완성된1장·본편 GO가 아니다.
- 기존316→Chapter1 StoryMode 경계7사례 PASS. 보조 파일 SHA `8cb37847748846002a65afcd8bcc33c48bc4e104c2339922649c9e5da9a3cade`를
  실행 entry와 사후 현재바이트에서 재대조했다. 전체316 corpus 재실행0.
- 최초6종 및 첫full은 tracked+untracked text1839,364 표적18/재full은1840경로다.
  각각 HEAD/tree/status·실행기 SHA·원361 실패2개/로그와 전후 census가 동일하다.
  PASS 실행의 stderr/timeout0이며 실패1건은그대로다. 실행은 각 선언HEAD
  dirty3도구 기준이며 clean마감커밋에서 재실행했다고 주장하지 않는다.
- audit의 기존 lane/check 등록은 전량 동일하며 새 explicit-only lane1/check1과
  shell 표적호출/exit flag만 추가했다. 선택목록6은 별도 수용 실행6이 아니다.
  shell 전체·역사1955·엔진·화면·240주·다른361 통과검사 재실행0.
- 최초361의 normal/self exit1 및 이번363의1033.169초 full실패를 보존한다. 원361 self는 당시 준비단계
  실패였고, 이번689 완료를 과거626 완료로 소급하지 않는다. 게임 원문·번역·
  inventory·생성 콘텐츠표·공개 데모·기존122판정/100보고·인간 원장 변경0.
- 비저자 정적 검토와 원형358 대조에서364의 exact owner 복원을 확인했다. clean source와 원문 실행증거를 결속한 최종
  판정은 별도 대기다. 351/361 통합 후속도 별도 검수/보고까지 HOLD다.

| 검사 | 실제 결과 | record SHA256 |
|---|---|---|
| focused | exit0 / 0.832초 | `e36949ad0fa805f06640166eb9237c5b7f18e0778c99c819d03c1de48874e927` |
| normal | exit0 / 35.748초 | `0bbe5eddca67d04cc817392449a6ad23fe6118623ab71087f4bf6d0431ffa5d9` |
| consumer | exit0 / 8.189초 | `1c01987e3b5a64699e87c7c6e9bcda0364cdf9353e7d174181501f05a4aa1bdb` |
| registration | exit0 / 0.226초 | `f0558de9bbd59aeced6df737ef67120ab28d53fbfb33e6ab4b9a2bafdaa4d56a` |
| context | exit0 / 0.273초 | `4c547e208d87c0f207014cbeac8cc388b5ba85e2586ec9e083fbb0994cf3f993` |
| queue | exit0 / 0.276초 | `99981b5d7edc9f41baa8142c197f059addf7b1b9387ac6ae010ed0dc1c83e0ee` |
| self | exit0 / 1025.104초 | `6980b31e18c9f822bb81f5a1ea6635e35c8009c546c41777442bc1243d62178e` |

| L2 항목 | 측정값 / 위치 |
|---|---|
| 도달 경로 | CHAPTER1_INVENTORY_HISTORY_SELF_TEST_OK cases=63; CHAPTER1_CAUSAL_LEDGER_SELF_TEST_OK cases=689 |
| 생산자 ↔ 독자 | tools/chapter1_core_loop_v2_causal_ledger_check.py:4459 → :4578 → :5124; 양성 fixture :4601 |
| 바꾸는 상태 | inventory snapshot mismatch exit1 ×2 → normal exit0 / self689 exit0 |
| 포기 시 잃는 것 | order361-first-11/12: inventory snapshot mismatch; 역사 fixture 준비 중단 |
| 서사 위치 | N/A: 검증 연결; Ch4 원문351·inventory360/362는 그대로 |
| 장면 계층 | N/A: 게임/장면/화면 저작0 |
| 닫는 것 | 역사 비교 연결 결함1과 별도364 반례의 owner복원; 351/361 통합·본편·새package HOLD 유지 |

자동 계약은 재미·깊이·문체 또는 원어민/인간/물리 감각 관측이 아니다.
개발 스킬의 선행 선언·파일 소유 분리·표적 검증·독립 검수를 적용했다.
일회성 수리이며 상시 규범 승격·외부 출시/스토어/지출/법률 인증0이다.

## 2026-09-28 실제 첫 실행 — 기존 반례의 증명 소유자 오류로 HOLD

- 선언 뒤3도구 구현. focused63·normal·기존316 StoryMode 소비자7·등록·context·
  queue, 6종 PASS. summary SHA `5d5dfcd947101e792aa8424b728a020fdba0bba17560e89b931a4fbfc05c52d2`.
- full self는1033.169초 exit1, timeout0, 전후1839 text 동일. record
  `.git/full-game-localization/order363-long-self.json` SHA
  `91514fe267e97df46a17c77c11e8c264b251190e12739c5908b2f64abb2bbc82`.
  stdout `CHAPTER1_CAUSAL_LEDGER_SELF_TEST_CENSUS full=2 skip=21 fallback=1`;
  stderr는 ORDER-350 `missing immutable proof`/`altered immutable proof` 두 반례다.
  이 실행은 뒤351의4·363의63사례에 도달하지 않았고689완료 주장은0이다.
- 비저자가 원형358의 import와 실제2×2 재현을 대조했다. 361의 alias350→351
  변경으로 기존 두 반례의 mock이 실제 proof 소유자350 대신351을 겨냥했다.
  새363 관측 호출은 재현4경우 모두0. 원형350을 손상시키면 같은 raw/claim/assert가
  그대로 거절한다. 새 제품 경계 강화나 반례 완화 대신 원래 mock 소유자만 복원한다.
- 이 수리는 inventory 관측 밖이므로 별도 [364](ORDER-364.md)에 선언한다.
  이전361 두 실패 및 이번 full 실패를 보존하고 실제 full 재완료·독립 후속 판정까지
  363·351·361 HOLD다. 새 원고/번역/엔진/화면/인간 관찰0이다.

## 2026-09-28 착수 선언 — 1배치, 구현 전

- clean main `543199909e0d56196d3f106dd490d45a486f4246`에서 시작한다.
  CLAUDE·큐·선택 사양·WORK_UNIT·개발 스킬을 재확인했고 QA/build/release
  5정본은 전회 전량 읽은 뒤 현재까지 변경0임을 Git으로 확인했다.
- `/root/compat357`만 `tools/chapter1_core_loop_v2_causal_ledger_check.py`를
  저작한다. inventory exact 관측 helper, immutable 전이 검증, 원래 양성 fixture
  4곳 연결, 새 반례 및 `--inventory-history-self-test` 표적 CLI만 소유한다.
  101/151~156 pin·기존622+361의4사례·본편 원장/부채·원형 모듈은 보존한다.
- root는 `tools/audit_scope.json`, `tools/audit.sh`의 새 표적 CLI 등록만 소유한다.
  기존 등록·호출은 지우거나 완화하지 않는다. private 실행 recorder와 metadata
  (이 사양·351/361 후속·큐2·WORK_LOG·CLAUDE 현재행·생성 STATUS·새 보고/판정
  append·완료 사양 이동/상대링크)도 root가 소유한다. 기존 보고/판정 변경0.
- `/root/r3_route_probe`는 제품 저작 없이 모든 전이·차이·반례·실행 증거와
  clean source를 독립 검수한다. private 최종 보고를 root가 exact 보존한다.
- 실제362 제품 `c7db93f7fc915a4d16fa5e8f63fa8b72343a6491`, 직접 부모
  `6df5de6ac3a5db5b53391e55416bd423e38a1f0c`, tree
  `96b70c27fd4a833c6b1150742b19da38415f59f0`. inventory raw
  `2ff675845e1017764eb67c1c9c330ecd3b3507fa0b40535757b00bba073a88b0`
  → `f46041343731f5cd64b680f778cff9ee77ea0c67fe114536f27a557fe5c1ead0`.
  360 직접 부모 `f41efdb2ea1b5a646bff10604d89fdd00ac9c620`도 Git에서 확인한다.
  360 후/362 전 동일 blob `f7ca93d46b4349086d397647a7d1b9670e9306b4`.
- 영향 목록을 읽되 실행 수로 세지 않는다. 최초 실행은 새 focused CLI,
  Chapter1 normal/self, 기존316의 Chapter1 StoryMode 한 경로 소비자 표본,
  audit 선택/등록 정합·context/queue로 한정한다. normal/self가 현재 실패한
  게이트이므로 실제 재실행한다. 전체1955 history·엔진·240주·전체 shell과
  무관한361 통과 검사는 반복하지 않는다.
- 매 검사 전후 tracked/untracked text census·원 실패2개·stdout/stderr·marker와
  사례 수를 보존한다. 변경 후의 PASS와 이전 FAIL을 따로 기록한다. 실패가
  생기면 원인을 고치되 새 범위는 별도 선언한다. 새 gameplay/번역/화면/등급0.
- 이 선언은 일회성이다. 363 내부 판정 뒤에도351/361 통합 후속 판정은 별도
  증거·보고이며 본편/새package HOLD·인간/원어민/물리 미관측·옛공개GO를 유지한다.

## 깊이 3문

1. 왜 지금인가: 검토된 현재 콘텐츠 기록 때문에 보존된 1장 인과 검사가 중단된다.
2. 무엇을 보존하는가: 원형101/151~156 pin·622사례·361 추가4반례·원장/부채,
   현재 inventory·공개 package·인간 판정. 역사 비교만 정확한 후속값에 연결한다.
3. 무엇과 경쟁하는가: 360만 잇고362에서 다시 깨뜨리는 반복을 피한다.
   새 원고·번역·게임 로직·등급 판단은 범위 밖이다.

## 실제 실패와 증거

- `.git/full-game-localization/order361-first-11.json` SHA
  `c715bcc36ef7cd6619e14945bd4d555085650e02cff95a9dc3023d96fe632a34`:
  normal exit1,37.689초. `order361-first-12.json` SHA
  `6a7f02a8a0c60bec5ae8e61ce74b308ff69b37d1b5458dc42180c116faec428c`:
  self exit1,37.028초. 둘 다 stderr에 inventory snapshot mismatch를 기록하며
  self는 fixture 준비에서 중단, 기존622+추가4사례 완료 주장은0이다.
- Chapter1 기대 체인은156의 inventory raw SHA
  `eaa588e0401af69a9079aa2d11f105e4e57c6780e5030c517320a34a5f251764`에서 끝난다.
  360 제품 `c94cd3ae19f22a015b3bd6b6e25afb17a8561242`는 정확6축의
  `candidate_scan.expected_content_sha256`만 바꿔 현재 raw SHA
  `2ff675845e1017764eb67c1c9c330ecd3b3507fa0b40535757b00bba073a88b0`가 됐다.
  351 제품과361은 이 파일을 바꾸지 않았다. 350/351의 LIVE·KOEN history 밖이다.
- 362의 실제 제품·직접 부모·정확 raw 전이는 완료 후 관측해 봉인한다.
  아직 없는 commit/hash를 발명하거나 미리 승인하지 않는다.

## 착수 후 소유할 파일 — 3도구, 1배치

- `tools/chapter1_core_loop_v2_causal_ledger_check.py`: inventory 한 경로만의
  exact observation bridge와 표적 반례. immutable360·362 부모/제품/Git blob을
  확인하고 검토된 지문 필드만 역변환했을 때 전체 이전 raw와 같아야 한다.
  현재 raw/관측 hash를 먼저 결속하고 역사 비교에만 사용한다. 새 공용 모듈은 만들지 않는다.
- `tools/audit_scope.json`, `tools/audit.sh`: 필요하면 해당 명시 차선만 추가.
  기존 검사·원형 모듈·pin·corpus의 삭제/면제/완화0.
- 마감: 이 사양·351/361 후속 상태·큐2·WORK_LOG·CLAUDE 현재행·생성 STATUS,
  비저자 보고와 판정 append. 착수 때 최신 WORK_UNIT/프로필과 파일 소유자를
  확인하고 `[~]` 선언 커밋을 구현 전에 분리한다.
- 제품·번역·현재 inventory·생성 콘텐츠 표·인간 원장·공개 pin은 비소유다.

## 완료 조건

- rollback/neighbor·공백/사실·공개pin/다른 경로/관측hash 불결속/누락·위조Git을
  거부하고 기존 pin·원장·부채·622사례와361 추가4사례를 보존한다.
- Chapter1 normal/self와 정확 소비자 표적 검사를 실제 실행한다. 최초 두 실패,
  새 실행의 전후 source census·marker/오류로그·사례 수를 각각 보존한다.
  361의 다른 통과 검사는 바뀐 호출 경계가 요구할 때만 재실행한다.
- 비저자가 정확 clean source와 전수 전이·반례·실행 증거를 읽고 판정한다.
  그 뒤351/361 후속 판정은 별도 보고/원장 append로 결속한다.
- 일회성 작업 지시이며 기존 WORK_UNIT·I18N·큐 규범을 적용한다.
  자동 계약은 재미·문체·원어민/인간/물리 관측이 아니다. 본편/새package HOLD,
  기존 공개GO·인간OPEN·외부 출시/스토어/지출/법률 인증 권한 경계를 유지한다.
