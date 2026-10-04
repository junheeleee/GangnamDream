# ORDER-452 — 홀덤 한 판의 실제 순손익을 표시한다

#### [~] ORDER-452 [P1·UI 금액] 팟 총액을 내 순손익으로 오인하지 않는다

**[~] 착수 — 2026-10-05.** 현재 SHOWDOWN은 승리 때 전체팟을 더한 값,
패배 때 전체팟을 뺀 값을 내 손익으로 표시한다. 시작100k/내출자10k/팟30k에서
실제 잔액 변화는 승+20k/패−10k인데 표시는+30k/−30k다. 기존439는 두 값을
구별해 기록했으며 정산 정확성 완료를 주장하지 않았다. 별도 표시 수리1배치다.

## 범위·소유

- root: `scenes/HoldemClub.gd` 정확5줄, private452 정상검사, CLAUDE·큐/L3·
  이 사양/보관·WORK_LOG·생성STATUS·새 독립보고/판정.
- claude_handoff_review: `tools/holdem_money_history.py`·`tools/ui_translation_append.py`
  EOF의 정확 source 전이 연결과 새 `tools/holdem_hand_net_receipt_check.py`.
- receipt_tests392: private452 GD/scene/oracle/run 및 `tools/audit_scope.json`.
- independent392: 실제5줄·후속손 경계·원본3PNG/실제효과·정상증거 독립 검수.
  root만 collector·검사·엔진을 실행한다. 소유를 겹치지 않는다.

## 제품 계약

- 실제 선언 `1a31721cb583586c8a4649a4c4950e82ab02fbe1`·tree
  `9c356359cc6a50f40bd6e98994908313f47d0ec9`, 제품
  `ffc99a1f7ee19f6f8de36eed4729395a83dbdf65`·tree
  `23214ad2801ac7af00644fc8e341803b989beecd`를 main에 커밋·푸시했다.
  제품 변경은49/355/1207/1210/1218 다섯 줄이며 새 검수는 아직 미실행이다.

- 기존 빈줄49에 `_hand_start_stack: int = 0`을 선언하고, 첫손 buy-in 초기화와
  잔액 부족 종료 검사 뒤/블라인드 차감 전의 빈줄355에서 현재 stack을 캡처한다.
- 승/패 branch의 hand_net을 각각 지급 후 `_player_stack - _hand_start_stack`으로
  계산한다. 승리 메시지의 `_fmt(_pot)`만 `_fmt(hand_net)`으로 바꾼다.
  summary/history.net은 이 값을 받는다. 두 번의 동일 수식은 고유 주변 문맥으로
  검증하며 기존 whole raw 역상·행수·71 UiCall/좌표/Entry ID를 보존한다.
- 실제 팟 지급·승자/AI/카드/입력/애니메이션/숨은효과·RESULT의 sessionnet/cash·
  GameState/Meta/Main/사전/번역원장/collector를 바꾸지 않는다. 명시 POT 상세는
  gross30k를 유지한다. `_player_bet`는 street별 값이므로 손 시작 기준으로 쓰지 않는다.
- `_net_session`의 기존 잘못된 휴면 쓰기는 실제 reader0이며 이번 수리에서 정리하지
  않는다. side-pot·승자 동률·추가 게임 규칙·KO 조사 수리도 추가하지 않는다.
- 실제 선언/제품 commit/tree/blob/raw를 관측한 뒤12번째 정확 전이와 현재 실제
  manifest tuple만 연결한다. 기존 proof prefix·451 canonical 두 단계 원장 증명과
  accepted41755/b228·사전3053/1776/1776은 byte-exact, 새 번역·교환0이다.

## 표적 검수

- KO 격리1세션에서 실제 `_start_hand`/블라인드2회, 합법52장 분할의 준비 RIVER2개,
  실제 dispatcher→SHOWDOWN 승1/패1을 관측한다. 자연 딜/베팅 입력으로 부르지 않는다.
  손1 시작100k→RIVER90k/팟30k→승120k/순익+20k; 손2 시작120k→RIVER110k/팟30k→
  패110k/순익−10k. 준비 RIVER의 street bet5k가 실제 phase 전환에서0이 되어도 손
  시작값100k/120k를 유지해야 한다. 각손 POT 상세30k와 승리 메시지를 대조한다.
- 실제 RESULT1회는 sessionnet+10k/cash5,010,000·기존 hidden/log/Meta 효과를 독립
  계산해 비교한다. 안정된 RESULT 중복 호출1회는 typed 상태·신호·Meta bytes 변화0이다.
  Close·Main AP 소비·실제 패드·자연 ingress는 실행하지 않는다.
- 승/패/RESULT 원본3PNG에서 signed 금액·POT 상세·승리 메시지의 actual font/glyph/
  fullfit/부모 포함·겹침을 읽는다. 기존 `_fmt`/다국어 사전과 소비자 소스 불변을
  검사하며 과거 다국어/19키/베팅 전체 suite를 다시 실행하지 않는다.
- 새 int도 typed snapshot/직접 restore에 추가한다. busyfalse·timer 소진 후 전체
  typed/RNG/Meta bytes·존재/semantic focus를 복원하며 실제player34를 보존한다.
- 새 focused·receipt normal·EN·context·queue·diff·등록7검증+차선조회1을 같은 clean
  후보에서 실행한다. current collector1회·새 pure/captured 반례만 focused에 둔다.
  JA/ZH 전체·fullbody·과거 suite·whole audit·240주·성능 A/B·새package는 NOT_RUN이다.

## 깊이·완료 경계

- 이 표시를 지우면 선택 결과의 금액 해석이 틀린다. 기존 선택과24주 상태·경쟁을
  바꾸는 새 기능이 아니라 이미 발생한 내 잔액 차이를 정확히 읽는 수리다.
- 이전212판정190보고·원449 REWORK·인간OPEN45/DONE1·공개GO1·본편/새package HOLD를
  보존한다. 저자/비저자가 실제3PNG와 증거를 읽은 한정GO만 완료 근거다.
  자동 PASS는 계약 증거이지 재미·깊이·문체·원어민·인간·물리패드·전체 출시 GO가 아니다.
  지시는 일회성, 새 정본 규칙0이다. 검수 성능 최적화는 별도 범위로 남긴다.
