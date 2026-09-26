# Active Queue Spec: ORDER-303

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [ ] ORDER-303 [표시·입력] 다이사이 중국어 현금·결과·복귀의 실제 소비자를 검수한다

**[ ] 2026-09-27 Codex 준비 — 사용자 승인 P0 ORDER-302 뒤에 착수한다.** 부모 ORDER-157.
ORDER-301 source `9911c36f973149036f1b909e75ac8686f04a9543`의 11키/22값을
clean main `4da937b7edb09018cb27b5d36a7e7248968b5feb`의 동일 제품에서 검수한다.
설계 입력은 private `order301-root-next-scope.json`
SHA `37246060b7e6dad488827481ce8310e9a3d6481974a512332d7ccafe7eccea08`다.
기존 선택19키/금융 다른 게임 검사는 반복하지 않는다.

## 깊이 3문

1. 제거 손실: 현금·승패·순손익 번역의 전체 인수와 복귀 경로를 실제로 읽은 증거가 없다.
2. 장기 상태: 표시 검사는 원본 저장을 바꾸지 않는다. 실제 굴림/결과 콜백의 판돈·로그·숨은 수치·meta 변화는 격리 상태에 정확히 남겨야 한다.
3. 경쟁: 결과·현금·전적·주사위·재선택 행동과 허브 용어집이 같은 첫 화면 안에서 함께 읽혀야 한다.

## 한 배치와 관측 계약

- 11 KO 키 각각의 CN/TW 소비자, source의 15 literal callsite 전수 대조.
  실제1280×800 각7PNG: DaiSai 초기/굴림/준비승리/다음선택/준비패배,
  연결된 카지노 허브 DaiSai 선택/용어집. 총14PNG를 root와 비저자가 전수 읽는다.
- locale당6 raw keyboard press/release쌍(12행): 초기 기본베팅의 Esc로 zero-round
  table→실제 연결 hub callback; 준비 hub index3에서 Right→DaiSai; X 용어집;
  Esc 닫기; 별도 초기 table Enter→실제 `_do_roll`; 승리 RESULT Enter→다음 선택.
  직접 handler/pressed emit은 입력 증거가 아니다. 준비 진입은 정상 title ingress가 아니다.
- 준비 단계에만 money10000000/stake50000, typed table/RNG 상태를 명시한다.
  실제 굴림은 선차감50000과 pending dice/RNG 소비를 별도 검증한다. 애니메이션을
  검사 전용 일시정지/processing 동결로 잡으면 before/after와 이유를 별도 기록하고
  정상 속도 굴림/자연 결과 전환을 주장하지 않는다. 동결로 결과나 RNG를 덮지 않는다.
- 승리와 패배는 별도 수명·이미 지불한 stake fixture: money9950000/dice[1,2,3].
  single1 승리 `_finish_roll`은 gross100000/net+50000/money10050000,
  BIG 패배는 net-50000/money9950000. 실제 콜백당 round1/history1/log1/meta1,
  hidden gambling+1 또는 addiction+2, 패배 shake RNG 소비를 정확히 대조한다.
  승리 pulse0.28초/패배 shake0.225초 뒤, RESULT 자동종료2.2초 전에 결과를 캡처한다.
  RESULT Enter는 재베팅 없이 IDLE/다음 베팅 안내만 바꾼다.
- 새로운 원문 title/hub readers는 실제 control로 확인한다. 실제 결과 money log와
  history 저장값은 비시각 증거로 분리한다. MainGame
  `_weekly_commitment_settlement_label`의 `details.game_id=daisai`와
  `game_id=casino, games=[daisai]`, 각각 rounds>0인 완전 반환2개/지역은
  비시각 호출만 검사한다. 실제 MainGame/logviewer 화면을 보았다고 쓰지 않는다.
- 전체 부모문장·HUD7인수·signed log·순이익과 총반환을 독립 고정 oracle로 대조한다.
  기존 영어 부모/직접 영어 chrome은 번역 완료가 아니다. 신규 UI/번역 수리는 별도 오더다.
- 전체 visible control census·TextLine/TextParagraph·실효 style/icon·서체/글리프·
  wrap·ancestor clip·canvas를 기록한다. 구조와 PNG를 모두 확인하며 잘림을 숨기지 않는다.
- 매 raw/capture/callback/disposal/최종 shutdown에서 전체 typed GameState/Meta/settings/
  namespace files/table/RNG와 경계 연결을 검사한다. 허용된 효과·일시정지·준비만
  명시하고 release no-op을 검증한다. baseline 뒤 상태 복원으로 변화를 감추지 않는다.
- 새 UUID pre-autoload 격리, 두 user-dir marker, exact 성공 marker, exit0,
  stdout/stderr/engine log 오류0, 새 실제 사용자 두 루트 전후 전수 hash census 필수.
  root만 엔진을 순차 실행하고 매 시도의 exclusive 경로/실패 원본을 보존한다.

## 파일 소유권

- root: 이 사양→`docs/queue_archive/ORDER-303.md`, `docs/CODEX_QUEUE.md`,
  `docs/CODEX_QUEUE_L3_PENDING.md` 순번, `docs/WORK_LOG.md`, `docs/STATUS.md`,
  `CLAUDE.md` 현재 상태 한 행, `docs/agent_review_decisions.json` 새303행,
  독립보고 정확복사 `docs/agent_reviews/ORDER-303.json`.
- root: 새 private `.git/full-game-localization/order303-render.py`,
  `order303-render-*` 실제 산출물/`order303-root-*`·`order303-check*` 기록.
- observer 저자 `/root/blackjack_accounting_tests`: 새 private
  `order303-status-observer.gd/.tscn`만.
- 기대값/validator 저자 `/root/release_status_crosscheck`: 새 private
  `order303-oracle.json`, `order303-validate.py`, `order303-oracle-*` 기록만.
- 비저자 `/root/blackjack_accounting_review`: 새 private `order303-*review*.json`만.
  observer/oracle/runner 비저자로 사전 및 최종 source-bound 품질 판정.
- 제품 code/locale/receipt/assets/project/human/공개/서사/금전 계약 변경은 비소유.

## 검증·완료·한계

helper 사전 독립 검수 후 위14PNG/24raw 및 비시각 결과를 실행한다. strict validator와
메모리 변조 음성검사를 별도로 하고 원본 이미지와 전체 문장을 전수 판정한다.
후속 CLAUDE 한 행으로 source가 달라지면 runtime pins 불변으로 명시 결속하며
그 최종source에서 재실행했다고 쓰지 않는다. context/queue/ledger/dashboard/diff만 마감.
이전300/295/297/301 named12와 전체감사는 새 변경 이유 없이는 재실행하지 않는다.

정상 진입·자연 무작위 결과·MainGame/logviewer 실제화면·마우스/gamepad·다른해상도·
오디오/패키지·원어민/인간/물리패드는 미관측. 공식40299/b136/meta9·보류72·
공개GO1·인간OPEN45·본편HOLD 유지. 자동 PASS는 재미/인간/출시 판정이 아니다.

**규범 판정:** 이번11키·경로·증거구성은 일회성. 기존 UI/I18N/WORK_UNIT 적용, 새 승격 없음.

## 동시 발행 조정

미구현 선언 `538b97f`가 원격 사용자 승인302와 번호가 겹쳐303으로 보존했다.
helper 작성·엔진 실행0. 최초 선언은 `codex/daisai-status-declaration-538b97f`에 남는다.
이 대기 항목을 실제 착수할 때 clean source를 갱신하고 소유권을 다시 선언한다.

