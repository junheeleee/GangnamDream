# Active Queue Spec: ORDER-364

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-364 [P1·검증] 기존 두 반례가 손상시키는 증명의 원래 소유자를 복원한다

2026-09-28 Codex 발행·착수. 363의 실제 full self 실패에서 분리한 1단위/1배치.

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
