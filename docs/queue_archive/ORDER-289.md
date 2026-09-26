# Archived Queue Spec: ORDER-289

#### [x] ORDER-289 [P0·정산] 바카라 수수료 한 번·타이 원금 반환

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


## 완료 — 2026-09-26

- 최종 source `2050eff82fb1ec3c3f29a14ecbf191f04baac03f`,
  tree `d0e67c86630f211130acec3081d43bd41e19bffb`.
  [독립 검수](../agent_reviews/ORDER-289.json)의 이 작업 한정 판정을 따른다.
- 뱅커 수수료는 당회 순손익에 반영하되 현금에서는 기존 안내대로 종료할 때
  한 번 차감한다. 미납을 먼저 소진해 동기 현금 신호와 재종료에서도 중복 출금을
  막는다. summary는 이미 수수료를 반영한 net을 그대로 반환한다.
- 타이 당첨에는 T 원금도 돌려준다. P/B 타이 반환·Pair 12배·기존 수익 배율과
  카드 규칙·원본 저장 형식·공개 고정 데모는 바꾸지 않았다.
- 실제 Table bet→deal→각 카드 process 공개→result→exit×2를 호출했다.
  18사례×KO/EN=36, 실제 정산은 19라운드×2=38이다. 임의 결과를 주입하거나
  정산 함수만 직접 호출하지 않는다. 새 세션·두 승리 뒤 패배·재종료까지 포함한다.
- 10만원 뱅커 승리의 현금 회수20만원·미납5천원·순손익9만5천원,
  타이 회수90만원·순손익80만원을 확인했다. P+B 및 P12/B1/PP1 혼합은
  현금 회수와 총베팅이 같아도 수수료 뒤 net−5천원이며 패배 분기를 유지한다.
- KO/EN 금융 패리티, 현금 신호의 금액과 당시 미납, HUD·당회 로그·결과 배너·
  미납 안내의 텍스트 값, 숨은 성향 변화, counters·road·summary를 확인했다.
  기존 KO format_money는 만원 단위 반올림으로 9만5천원을10만원으로 표시한다.
  따라서 이는 올바른 net의 기존 표시 소비자 연결 증거이며 원 단위 정확 표시나
  실제 픽셀·스크린샷·청취 검증이 아니다. 공용 formatter는 비소유로 보존했다.

### 실제 실행·원형 증거

아래는 모두 `.git/full-game-localization/` 아래 `result.json`이다.
각 결과가 clean source, 입력14개, 실제 사용자 파일43개 전후와 raw log SHA를 묶는다.

| 실행 | 실제 결과 | result SHA-256 |
|---|---|---|
| `order289-before-fix` | f799817, exit1·36실행·22PASS/14FAIL·144assert 실패, engine 오류0 | `174ad43d1b76b34fa2bf2a6b71a2574026a6f39095f6027d82f539f07cadff59` |
| `order289-after-fix` | 2050eff, exit0·36PASS·assert/engine 오류0·정확 marker | `7c44725f694d16a1cc629ade42b56a882ab8886b421e3786108bcd9149e2f886` |
| `order289-targeted-first` | 표적 정적11/11 PASS | `7527a6fd74afedfda9b7d25580b2c83e1d16599db584345c0e88fa871fedaf12` |

수정 전후 기대값36행은 동일하고 입력14개 중 Table만 달라졌다.
전14FAIL은 3개 정산 결함과 다음 단계/재개까지 이어지는 오차를 포함하며
14개 독립 제품 결함이 아니다. 후속 실행3.494초, stdout/Godot log 동일,
stderr 비어 있음·정확 marker1회·저장/프로세스 종료 오류0.
실제 사용자 파일43개는 두 실행 전체에서 동일했다. 새 pre-autoload 저장
공간은 각각 따로 사용·보존했으며 사용자 저장이나 실패 증거를 삭제하지 않았다.
runner validator 자체10사례 PASS와 개별 ASSERT_FAIL의 직접 오류 검출도 추가했다.

표적11은 core static, EN 표면/coverage, 오디오·입력 정적 계약, 플레이어
표면 언어/coherence, JA UI, ZH, context, queue, 감사 등록155다.
전체 감사나 기존 feature-liveness의 .git 과거 gd33개 오탐을 다시 실행하지 않았다.
과거 CI 잔여3건·번역 수용/보류 원장·사람 판정의 의미는 바꾸지 않았다.
종료 metadata 검증은 `order289-closure-first/result.json`에 별도 기록하며
문서 마감 때문에 같은36사례를 반복하지 않는다.

### L2 결속·미관찰 경계

```text
도달 경로      : BACCARAT_ACCOUNTING_CHECK_OK cases=36 locales=2
생산자 ↔ 독자   : scenes/BaccaratTable.gd:391 ↔ scenes/BaccaratTable.gd:129,494
바꾸는 상태     : 뱅커 현금195000→200000·미납5천원1회, 타이800000→900000 회수
포기 시 잃는 것 : P/B/T 패배 대조 및 베팅하지 않은 독립 Pair 회수0
서사 위치       : 해당 없음 — 카지노 Table의 정산 완료 라운드
장면 계층       : 해당 없음 — 새 서사 장면 저작0
닫는 것         : 수수료 중복·타이 원금 누락·재종료 출금, 전체 바카라/출시 닫음 아님
```

규범 승격 없음. 기존 안내와 배율에 정산을 맞춘 버그 수리이며 실행·소유·판정
지시는 **일회성**이다. 정산 완료 라운드의 현금 계약만 판정한다.
딜 도중 이탈·강제 open·재귀 종료의 실제 호출·미납액을 베팅 여력에서 예약할지·
잔액 부족/음수 정책·카드 순서 주석·다른 베팅액/해상도/플랫폼·실제 카지노 진입·
패키지·EV·전체 번역·원어민·인간·물리 패드·청취는 미검증/별도 범위다.
반복 종료는 금전·수수료 로그 한정이며 closed 신호2회·메타 기록의 반복은 그대로다.
자동 검사는 계약 증거이지 재미·인간 관찰·외부 출시 승인이 아니다.
본편HOLD·공개GO1·인간OPEN45·공식40129/b130/meta9·보류72를 보존한다.
