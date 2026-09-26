# Active Queue Spec: ORDER-289

#### [~] ORDER-289 [P0·정산] 바카라 수수료 한 번·타이 원금 반환

[~] 착수 — 2026-09-26. 기준 `88a8a44`. 사용자 개발·최종 내부 검수 위임으로
확인된 금전 정산 결함을 수리한다. 번역·공개 데모·사람 판정은 건드리지 않는다.

## 문제와 고정할 계약

Table은 뱅커 수익을 이미0.95배로 지급하고도 미납5%를 종료 때 다시 차감한다.
타이8:1 당첨에는 원금 반환이 없고, 종료 후 미납액이 남아 다시 출금될 수 있다.
기존 TutorialOverlay·Baccarat 모델·카지노 용어집의 수익0.95/8/11배 및
Table의 나갈 때 수수료 정산 안내를 유지한다. 새 배율·카드 규칙이 아니다.

- 뱅커 승리: 원금 포함2배 현금 회수,5% 미납 적립, 당회 순손익에는5% 반영.
- 타이: T 원금 포함9배와 P/B 원금 반환. 페어는 독립 원금 포함12배 유지.
- `_net`은 수수료 반영 순손익이며 summary는 이를 그대로 쓴다.
- 미납은 종료 시 한 번 출금하고 소진한다. 재호출·새 세션에서 중복 출금0.
- 정산 완료 라운드만 대상으로 종료 전 `cash-start-미납 == net`, 종료 후
  `cash-start == net == summary.net`. 딜 도중 이탈·강제 open은 비대상이다.

깊이3문: 고치지 않으면 실제 현금과 안내한 이익이 다르다. 정산 오류가 다음
베팅 여력·카지노 세션 결과에 남는다. 같은 현금의 다른 베팅과 경쟁한다.

## 정확한 소유권

- ROOT: `scenes/BaccaratTable.gd`의 `_finish_result`, `_on_exit`,
  `get_session_summary`와 관련 상태 주석만; 새
  `tools/run_baccarat_accounting_check.py`, `tools/audit_scope.json` 해당 등록.
- 테스트 저자: 새 `tools/BaccaratAccountingCheck.gd`, `.gd.uid`, `.tscn`만.
- 비저자 검수: `docs/agent_reviews/ORDER-289.json`만.
- ROOT 기록: CLAUDE 상태 한 줄, CODEX_QUEUE와 L3 이어보기의 순번만,
  WORK_LOG, 생성 STATUS, active/archive289, agent 원장 새 한 건.
- git-private `.git/full-game-localization/order289*`: 원형 증거·실행 보조.

project.godot·원본 사용자 저장·보호 데모·기존 번역·인간 원장·카드 모델·
카지노 허브·공용 현금 API는 비소유다. 미납액을 베팅 가능 현금에서 예약할지,
카드 소비 순서와 주석 불일치, 실제 입력·전체 UI·EV·다른 게임은 별도 범위다.

## 검증과 판정

선언 commit/push 뒤 실제 Table의 bet→deal→process reveal→result→exit를
고정 카드로 호출한다. 고정 독립 기대값으로 P/B/T 승패·P/B 타이 반환·페어
독립·혼합 음수 손익·누적 수수료·종료 반복·다시 열기와 KO/EN을 확인한다.
현금 신호·당회 로그·HUD/summary 순손익과 표시 소비자를 함께 본다.
범위와 사례 ID를 실행 전에 봉인하고, 수정 전 실패와 같은 모집단 후속 검증을
보존한다. 새 pre-autoload 저장 공간·사용자 파일 해시·입력 해시·raw log·exit·
정확 marker·사례 검증은 기존288 패턴을 사용하되288 자체는 수정하지 않는다.

실행 전 봉인 모집단: 18사례×KO/EN=36. `player_win`, `player_loss`,
`banker_win`, `banker_loss`, `tie_win`, `tie_loss`, `player_tie_refund`,
`banker_tie_refund`, `mixed_tie_refunds`, `player_pair_win`, `player_pair_loss`,
`banker_pair_win`, `banker_pair_loss`, `both_pairs_win`, `banker_pair_mixed`,
`player_banker_negative`, `multi_round_commission`, `reopen_empty`.
기본칩10만원·시작현금1천만원. 반복 종료는 각 사례 안에서 확인하며 금전·
수수료 로그의 중복 방지만 판정한다. 닫기 신호·메타 플레이 횟수의 완전 멱등은
이번 수리 주장이 아니다. `banker_pair_mixed`는 P12회/B1회/PP1회 베팅으로
페어 당첨이 있어도 fee 반영 net−5천원인 경계를 확인한다.

정적 영향 검사: core·EN 표면/coverage·오디오 입력 계약·표면 언어/coherence·
JA UI/ZH·등록·queue/context. net의 부호에 연결된 기존 피드백은 한정 확인한다.
전체240주·다른 게임 반복 실행은 없다.288에서 확인한 `.git` private gd33개
오탐 feature-liveness를 같은 이유로 반복하거나 baseline을 넓히지 않는다.
최종 비저자가 소스·독립 기대값·전후 증거를 직접 읽고 이 단위만 판정한다.

규범 승격 없음, 실행·파일 소유·검수 지시는 일회성이다. 자동 검사는 계약
증거이며 재미·원어민·인간 플레이·물리 패드 관찰이 아니다. 본편HOLD 유지.
