# Active Queue Spec: ORDER-364

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [x] ORDER-364 [P1·검증] 기존 두 반례가 손상시키는 증명의 원래 소유자를 복원한다

2026-09-28 Codex 발행·착수. 363의 실제 full self 실패에서 분리한 1단위/1배치.

## 2026-09-28 독립 최종 마감

- 비저자 `/root/r3_route_probe`의 ORDER-364 한정 work_unit GO.
  clean source `ebd408f330c6d71f736b9f274f85389fe79d9c5d`, tree `5d6b9ce690df6e378696201ae5063cd308134d7e`.
  [최종 보고](../agent_reviews/ORDER-364.json) SHA `9ff285f31aedc94bf8add9a00305d198654914bbd3d4c4456670afb3bec778d2`.
  private 원본과 byte-identical이며,363 판정과 별도 unit_id로 append했다.
- 원형 증명 소유자 한 줄 복원·입력/assert/반복수 보존·표적18/full689 원문을
  독립 확인했다. 첫 full실패 및 인간·공개·기존122판정/100보고를 유지한다.
  351/361 통합·본편/새package HOLD다. source 또는 공개 출시 전체 GO가 아니다.

## 2026-09-28 수리·실제 결과 — 독립 최종 대기

- 선언 `989a92db8829154e116296e5c807a3877f0b73b0` 뒤 mock owner 한 줄만 복원.
  원형358 `0bfc2805fd1ebb21363174a5a779511a3208e03a`의 current_source는350였다.
  입력·assert·반복수·production·원형모듈 변경0. 역치환하면363 첫코드 SHA
  `16e815a6fc7249b1ca20d6155057039edd392cbf2b17919fc2fd3898e4c2e079`와 전체 raw 동일.
  최종 SHA `49a408e6955f7c5263d4c9e37f8fb65a53d44141eb94b9eec09625c6af2b6f74`.
- 기존18 표적검사 exit0/9.908초, record SHA
  `f013b9727cd1745acfd67f2b93324c2180f04363e7f6b1a53568cff9e5b1fd57`.
  marker `ORDER364_ORIGINAL_PROOF_BOUNDARY_OK cases=18`.
- full689 재검 exit0/1025.104초, record SHA `6980b31e18c9f822bb81f5a1ea6635e35c8009c546c41777442bc1243d62178e`.
  marker `CHAPTER1_CAUSAL_LEDGER_SELF_TEST_OK cases=689`. 두 실행의 text1840 전후
  동일·stderr/timeout0. 363 첫 full실패는1033.169초 exit1로 따로 보존한다.
- 최초363의6PASS는 이번 바뀐 self 함수에 도달하지 않는다. 제품 코드·등록·소비자
  바이트 동일 및 차이 비영향으로 재사용하며 같은 검사를 이유 없이 반복하지 않는다.
  context/queue는 각 당시 문서의 PASS이며 최종 문서는 별도 마감 검사로 결속한다.
  전체689 안에 표적18/focused63 포함. 기존622/신규4/신규63을 삭제·면제하지 않았다.
- clean source-bound 독립 최종 판정은 대기다. 게임 원문/번역/공개/인간 기록 불변,
  351/361 통합·본편·새package HOLD. 자동계약은 재미·원어민/인간/물리 관측이 아니다.

| L2 항목 | 측정값 / 위치 |
|---|---|
| 도달 경로 | ORDER364_ORIGINAL_PROOF_BOUNDARY_OK cases=18; full689 exit0 |
| 생산자 ↔ 독자 | tools/order350_source_compat.py:530 ↔ tools/chapter1_core_loop_v2_causal_ledger_check.py:4967 |
| 바꾸는 상태 | 잘못된351 mock 소유자 → 원형350 owner; 같은 assertion2 FAIL→PASS |
| 포기 시 잃는 것 | missing immutable proof / altered immutable proof, 원형350 반례2 |
| 서사 위치 | N/A: 기존 KO midgame 검증 fixture; 제품0변경 |
| 장면 계층 | N/A: 장면 저작0 |
| 닫는 것 | 반례 소유자 오류1; 출시/본편 품질 판정0 |

## 착수 전 깊이 3문

1. 왜 지금인가: 이전 inventory 실패가 가렸던 기존 반례2개가 실제 full 실행에서
   실패했다. 원형358은 order350를 current_source로 읽었지만361부터 별칭은351이다.
2. 무엇을 보존하는가: 같은 두 반례의 입력/claim/assert/반복수·실제 관측 로직·
   원형모듈·pin·기존622+361추가4+363추가63, 실패 원문·현재 게임/번역/공개/인간 증거.
3. 무엇과 경쟁하는가: 모의 대상의 실제 원래 소유자350 복원 한 줄로 해결한다.
   새 production guard·공용모듈·범위 확대 및 통과시키기 위한 assertion 완화는 하지 않는다.

## 일회성 선언·파일 소유

- 선행 CLAUDE/큐/WORK_UNIT/개발 스킬·동일 QA 프로필을 적용한다. 363 도구3의
  미커밋 바이트는 그대로 유지하고 선언만 별도 커밋한다. 363의 코드 SHA
  `16e815a6fc7249b1ca20d6155057039edd392cbf2b17919fc2fd3898e4c2e079`.
- `/root/compat357`: `tools/chapter1_core_loop_v2_causal_ledger_check.py`의
  `order350_source_boundary_self_test` 안 `mock.patch.object` 대상 한 줄만
  `current_source`→이미 import된 `chapter3_source`로 고정한다. 다른 tracked 수정0.
- root: 이 사양·363/351/361 후속·큐2·WORK_LOG·CLAUDE 현재행·생성 STATUS,
  private 표적 증거, 새 보고/판정 append와 완료 사양 이동/상대링크를 소유한다.
  비저자 `/root/r3_route_probe`는 원형 import·의미상 owner·원문 증거를 전수 검토한다.
- 원형358 commit `0bfc2805`의 전체 OID는 Git에서 확인해 마감에 기록한다.
  미확인 후보 신원을 발명하지 않는다. 독립 재현은
  `.git/full-game-localization/order363-proof-owner-repro.json`에 별도 보존했다.

## 검증 및 마감

- 두 원형 proof 반례를 포함한 `order350_source_boundary_self_test` 18사례를
  private 표적 호출하고 실제 marker/실패/전후 census를 보존한다. 그 뒤 full
  Chapter1 self를 실제 재실행해 합계689를 확인한다. 변경된 함수에 도달하지 않는
  기존363의6PASS는 원문과 차이 비영향을 결속하며 이유 없는 재실행0이다.
- full 실패를 덮어쓰거나 당시3514/36363이 실행됐다고 쓰지 않는다. 363 수리
  코드·현재 게임/번역/inventory·인간 원장·기존122판정/100보고는 불변이다.
- 실제 입력/코드 변경0인 한 full shell·엔진·화면·240주·역사1955 반복0.
  마감 문서/큐/판정 구조 검사는 변경 뒤만 실행한다. 새 체크 등록/공용도구0.
- clean source에 각각 별도 ORDER-363/364 보고·판정을 결속한다. 둘이 끝나도
  351/361 통합 보고는 별도이며 본편/새package HOLD·원어민/인간/물리 미관측이다.
  외부출시/스토어/지출/법률 인증0, 일회성 수리이며 상시 규범 승격0이다.
