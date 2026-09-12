# 중국어 VIP 단수 수량 검사 — 결과

[x] ORDER-241 — 2026-09-12 완료. 독립 Rawls의 work_unit GO 한정이다.
실제 source `ad7ff36b2118928ed9bfe007363475d6fcb51e04`, tree
`0f54fa5da0cf18fcd86ab39b3f39bb0f55238c5b`; 검토 HEAD `7b4bcce09b880883ebd392a2d4d22091abd467c0`.
공개GO1·인간OPEN45·본편HOLD. 자동 검사는 재미·깊이·문체·인간 판정이 아니다.

## 수리와 회귀

- 실제 KO의 한 사람이 떠나면서 다음 만남을 물었다는 CN/TW2는 단수를 보존한다.
  `有个人/有個人`은 一 생략이며 원문 번역 오류가 아니다. 번역문은 바꾸지 않았다.
- 제품2만 변경했다: ZH exact 전체KO+canonical UI key+CN/TW helper와
  validate_text numeric 분기의3줄 hook; fullself에 고정 회귀1 추가.
  출발·한 질문자·다음 만남 문의 역할 안에서만 numeric target에 一를 복원한다.
  전체 target의 나머지 수량과 원 target의 script/token/용어/통화/LF/영어 검사는 유지한다.
  일반 entity parser나 전역 一 생략 면제는 아니다. 유한 문법이며 일반 의미 증명이 아니다.
- Poincare 독립 저작 전30 봉인: 실제2+다른정상8, 정상base가 통과하는 변조14,
  exact key/source/locale OFF6. 옛 코드 실제2/OFF6을 먼저 한 번 캡처했다.
  첫 post30은 정상10/valid mutant14거부/OFF6 원래오류 exact,14입력 불변/0.145751208초다.
  고정30 전체 payload와6 baseline 출력을 새 self1에 그대로 등록했다.
- ZH 기존213함수는 validate_text hook 외 raw 불변, helper/hook 제거로 전체 raw exact.
  fullself 기존258 tests/279 methods raw 불변, 새1 제거로 전체 raw/AST exact; 현재259다.
  ROOT의 같은240 L1은90의 source/target/필드 변경 없이2오탐→0이다.
- 240과 공유한 전체수용38,587/errors0/1,185입력 exact 및 명시9 PASS/1,195입력
  exact는 [240 결과](ORDER-240.md)에 있다. 동일 검사를 두 번 실행하지 않았다.
  수용90·runtime80·old65 자체는240 소유이며241 독자 번역/플레이 실적이 아니다.
- 사전 fixture JSON 준비 SyntaxError1은 apply 이전에 멈춘 준비 실패이며 원형 기록했다.
  저자의 정적 마감 중 ROOT portable 수용과 전후 pin이 교차한 assert도 원형 보존했다.
  이는 코드 회귀 실패가 아니며 코드/UI 불변과 이전 post14를 구분해 재결속했다.

```text
도달 경로      : same frozen30 PASS; same target90 L1 errors2→0; shared9 PASS
생산자 ↔ 독자   : MainGame._ap_vip_network exact KO ↔ zh_translation_audit.validate_text numeric hook
바꾸는 상태     : 수량 오탐2→0; 실제 산문·게임·저장 변경0
포기 시 잃는 것 : 없음 — 번역을 왜곡하지 않고 검사 오탐을 닫는다
서사 위치       : 기존 VIP 빈 관계 로그1; 새 사건0
장면 계층       : 해당 없음 — 검증 도구
닫는 것         : exact 수량 오탐·고정 회귀; 인간/원어민/렌더/전체판 닫기0
```

WORK 완료231/230 원문2080B만 기존 현지화 이력 앞으로 이동했다. 나머지 WORK
raw/EOF2 및 기존 history는 역복원 exact다. 기존 인간 원장·공개 demo·project는 불변이다.
판정은 [독립 보고](../agent_reviews/ORDER-241.json)가 소유한다.
아래는 `.git/full-game-localization/` 증거 SHA다.
- `order241-controls.json`: `70d64e34df7ea50771b8040c311edbc9de845caf3579e3af278e2410691561e1`.
- `order241-pre-code-baseline.json`: `602b8add56f6d20bbde835b1af6b7c886454caa010cf32f88a4d3e7bd572f976`.
- `order241-post-code-result.json`: `b7955bf2ec6b61c22ad82b7beca4b0e353080f1fd56785a9571e60a75d8217bd`.
- `order241-author-freeze.json`: `729664799b3695d1a7726573d63d5a7bff1ab044482d53746116f260550d9f2b`.
- `order241-code-review.json`: `5f87d66ce724cff5103a1551ba6a129399bf8f90a798a70be492265cd0c15c31`.
- `order241-history-move.json`: `19cf9160b9e8ecfe916491880ecf4ea1339b32762d56c9bf740112534499e8df`.
- `order240-repaired-l1.json`: `350bba3e27d5bc3365fd49e913e70d9929ee369c8ce1ca81ac9625c5b56a3e0b`.
- `order240-all-accepted-l1.json`: `e97238243218685534afb27e2dc18c68c4f1944f53333855c76a2d2a5fb9d71a`.
- `order240-241-named-first.json`: `cba47a654858b6567e4539c19377abafa587478fceac1e680d19237bfb58a132`.

## 선언·진행 원문 보존

# Active Queue Spec: ORDER-241

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-241 [P0·검사] VIP 인사 로그의 중국어 단수 생략 오탐을 수리한다

**[~] 2026-09-12 Codex 착수 — 아래 파일만 소유한다.** 로컬 기준 HEAD
`56348b9df108836a689133b14e4f303f42d1d922`, tree
`88d516dbeb1910092104bf47459fe643b41faef6`. 진행 중240의 테스트2 신규 파일은
Rawls 소유이며 그대로 보존한다. 완료·검증 뒤 main/mirror를 동기화한다.

## 깊이 3문·하나의 판정 단위

1. 그대로 두면: 승인한 중국어 `有个人/有個人`의 생략된 一를 인식하지 못해
   실제 한 사람이 다음 만남을 물었다는 두 번역을 잘못 차단한다.
2. 장기 영향: 검사 전용 수량 정규화이며 실제 산문·상태·약속 성사·저장 변화0이다.
3. 대안: 자연스러운 번역을 검사기에 맞춰 고치거나 전역 수량 검사를 약화하지 않는다.
   정확한 UI 원문·키·중국어 locale에만 좁힌 회귀 수리 하나로 판정한다.

## 소유권과 보존선

- Plato 제품2: `tools/zh_translation_audit.py`,
  `tools/full_game_localization_self_test.py`. 실제 첫 L1의 두 오탐만 대상으로
  원문·정확 UI key·CN/TW에 결속한 helper와 고정 회귀를 추가한다.
- ROOT 운영: `tools/audit_scope.json`, `CLAUDE.md`, `docs/CODEX_QUEUE.md`,
  `docs/CODEX_QUEUE_L3_PENDING.md`, 이 사양·`docs/queue_archive/ORDER-241.md`,
  `docs/WORK_LOG.md`, `docs/history/WORK_LOG_2026-09-07_localization.md`,
  `docs/STATUS.md`, `docs/queue_backlog/FULL_GAME_LOCALIZATION.md`,
  `docs/agent_review_decisions.json`, `docs/agent_reviews/ORDER-241.json`.
- WORK의 완료231/230 두 절만 기존 현지화 이력 앞으로 원문 이동한다. 진행 중
  작업은 이동하지 않으며 나머지 bytes와 EOF를 보존한다.
- 240 source2/UI3/portable/test2는 해당 오더 소유다. 이벤트·게임플레이·돈·관계
  효과·기존 검사 기대·일반 숫자 parser·플레이어 저장·project·인간 원장은 수정0이다.
- `.git/full-game-localization/order241-*`는 독립 사전 controls·저작·회귀 사적 증거다.

## 수리·검증 계약

- 첫240 L1의90개 중2실패 원형과 승인 번역표를 유지한다. 출발할 때 한 사람이
  다음 만남을 물은 정확한 문장 역할 안에서만 `有个人/有個人`을 numeric-only
  `有一个人/有一個人`으로 해석한다. 실제 target은 바꾸지 않는다.
- 기존 script/token/용어/통화/줄바꿈/영어 검사는 원 target을 계속 읽는다.
  모든 entity 수량에 一 생략을 허용하거나 실패를 통째로 면제하지 않는다.
- Poincare가 저작 전 고정 controls를 봉인한다. 실제2와 정상 단수 표기,
  오수량·누락·잘못된 역할·중복·복수·key/source/locale OFF를 포함하며
  기대값은 제품 출력으로 만들지 않는다. Plato는 같은 controls를 회귀에 넣는다.
- 같은90 L1을 수리 뒤 재실행한다. 240과 공유하는 전체수용 L1 및 명시 정적
  검사는 최종 입력에서 한 번 실행하고 양쪽 근거로 연결한다. 신규 고정회귀 외
  기존 검사 원형을 보존한다. 전체감사·240주·실제 플레이 판정으로 확대하지 않는다.
- 비저자가 최종 exact source와 수리·실패 증거를 직접 검토한다. 내부 단위 GO만
  해당하며 공개GO1/인간OPEN45/본편HOLD와 native/render 미관찰은 보존한다.

규범 승격 없음: 기존 I18N·WORK_UNIT 적용. 정확 원문·소유·검수는 일회성이다.

## 2026-09-12 중간 결과 — 최종 판정 전

- 독립 고정30은 정상10·유효 정상에 연결된 변조14·OFF6이다. 같은 원형코드에서
  실제2/OFF6을 먼저 기록하고 helper+hook·새 self1만 구현했다.
- 첫 post30 PASS/14입력 전후exact. 기존 일반 parser·258 self·원 target 검사는 보존했다.
  ROOT 같은240 L1의90개는 산문 수정 없이2오탐→0이다.
- 로컬 코드 checkpoint `0bbf6a1`; git-private `order241-controls.json`,
  `order241-pre-code-baseline.json`, `order241-post-code-result.json`에 원형을 보존했다.
  완료231/230 원문2080B만 이력 앞에 이동했고 다른 WORK bytes/EOF2는 역복원 exact다.
- 240과 명시9/전체수용 L1을 공유하며 비저자 exact-source 최종 검수는 별도다.
  공개GO1·인간OPEN45·본편HOLD. 검사 통과는 재미·깊이·문체·인간 판정이 아니다.
