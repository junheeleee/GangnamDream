# Completed Queue Spec: ORDER-303

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [x] ORDER-303 [표시·입력] 다이사이 중국어 현금·결과·복귀의 실제 소비자를 검수한다

**[~] 2026-09-27 Codex 착수 — 만지는 파일: 아래 파일 소유권의 private helper·신규 증거와 마감 문서만.** 부모 ORDER-157.
ORDER-302 수리7항목 source GO가 선행을 충족했다. clean main
`ca1de8e1add53e09f6e3c5687a5958c75603af67`에서 착수하며 source 후보는
`ca2670ded596bf111f668c59535c3d3603bddda5` / tree
`12403c916dca2284c138610727be2f4b42702220`다. ORDER-301 대상11키/22값과
runtime6파일은 동일하되 CN/TW 전체 파일은 데모 수리 후 지문으로 새로 결속한다.
CLAUDE 현재 행을 포함한 착수 commit 뒤 source를 다시 관측하며 옛 후보를 상속하지 않는다.
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
- observer 저자 `/root/header_layout`: 새 private
  `order303-status-observer.gd/.tscn`만.
- 기대값/validator 저자 `/root/screen_path_probe`: 새 private
  `order303-oracle.json`, `order303-validate.py`, `order303-oracle-*` 기록만.
- 비저자 `/root/screen_independent_review`: 새 private `order303-*review*.json`만.
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

## 2026-09-27 관측 완료·화면 수리 잔여

- 실행 source `2dc1e9f7941d5c19bf0a1c1f7055e6c02ec5ffdb` / tree
  `2547f53ed6d1445cde7e264037b5a23f0d2d3cfe`. `cn-second`·`tw-first` 각7PNG/12raw,
  exit0·정확 marker·3로그 오류0·전체 상태/정산/복귀/namespace·실제 사용자43파일 동일.
- root·비저자는 최종14 원본을 전수 읽었다. 11키/22값·15소비자·비시각4반환,
  메모리 변조60개 거부. `order303-check-accepted-bindings.json`
  SHA `171ca6b224af52d2095a87fff6bd0aad6ee3312b96fb71c8cbdc447ffb2e1a11`.
- 최초 `cn-first`는 입력 전달 시점의 검사 도구 가정 오류로 FAIL이며 원본 보존.
  입력 버퍼를 실제 전달한 같은 프레임의 전후 상태를 기록하도록 검사 도구를 수리했다.
  이번 도구의 재실행에서는 `parse_input_event` 직후 상태를 소비자 결과로 가정하지 않는다.
- 대상 문장·금액은 읽히지만 다이사이 상단과 허브 제목/나가기/주의/용어집이
  2.5% 안전 여백 밖이다. 다음 선택의 테이블 아래 장식 테두리도 화면 끝에 닿는다.
  자동 관측 통과를 화면 품질 GO로 올리지 않는다. 별도354 수리와 원래 배치 후속
  독립 판정 전에는 [~]를 유지한다. 비저자 최종 `7a69b426`/tree `45be31b1`
  작업한정 REWORK: [보고](../agent_reviews/ORDER-303.json) SHA
  `f8be3f61db78601ebd68d8c34617270bd1e488a58cd9d1b8f56a7dc4f657a87d`.
  SAFE-01·FIT-02 필수 수리2건. 최종 source는 문서6개만 달라 실제 실행 source와
  무변경 제품 바이트로 결속했으며 재실행을 주장하지 않는다.

## 2026-09-27 후속 완료 — 원래 모집단 작업한정 GO

- 위 REWORK와 최초 실패·21원본PNG·기존 판정은 그대로 보존했다. [354](ORDER-354.md)의
  별도 표시 수리 뒤, 원래11키/22값·15소비자·CN/TW 14원본PNG·24합성 키보드 edge·
  정산/복귀/비시각4반환 모집단 전체를 새로 확인했다. root와 비저자 전수 판독,
  각 지역7화면·12edge·exit0·정확 marker·3로그 오류0, 실제 사용자43파일 불변이다.
- 실제 실행 `85c5295a5ecc0d66caa357996c3141f3379270fd` / tree
  `d413dd760926048583a971973f73a3663619c13a`. 최종 독립 검수는
  `2d3fb7a8360c5f9308748c02928f33a61186fdb3` / tree
  `c6f9dc54cb0efe42c04a4325b3b4590d3b31c0b1`이며 CLAUDE 현재 행만 달라졌다.
  제품 불변 핀으로 연결했으며 최종source에서 새 엔진 실행은0이다.
- [별도303 후속 보고](../agent_reviews/ORDER-303-followup.json) SHA
  `ffb1ae91dee7fb071ddd46239c4dfaa043087d777f913984beeeacf53c9b89a2`:
  SAFE-01/FIT-02 해소·필수 범위 결함0·작업한정 GO. 354 GO를 대신 가져온 판정이 아니다.
  새 validator 음성72개 거부와 typed 상태 결속은 별도 기계 증거다.
- 새 판정2개만 추가해 이전103개와 원문 prefix를 보존했다. 더 넓은 표적 검사는
  15 PASS/7 FAIL이며 상세 잔여는354 완료 절에 있다. 이 GO는 전체 검사 통과나 전체 중국어
  UI 완료가 아니다. 정상 진입·자연 완료 굴림·실제 MainGame 로그 화면·다른 해상도·
  원어민·인간·물리패드·오디오·패키지는 미관측. 기존 영문 chrome/용어집 설명은 이11키 밖이다.
- 규범은 일회성/기존 UI·I18N·WORK_UNIT 적용, 새 승격0. 자동 게이트는 계약 증거이지
  재미·깊이·문체 판정이 아니다. 본편·302 successor package HOLD와 인간OPEN45·공개GO1 유지.
  다음 안전 작업은 큐의309이며, 이 마감에서 후반 대본을 새로 쓰거나 수리하지 않았다.
