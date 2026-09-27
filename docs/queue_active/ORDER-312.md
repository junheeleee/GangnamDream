# Active Queue Spec: ORDER-312

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-312 [QA] 승인된 월세 검사 후계를 역사 핀과 분리한다

2026-09-27 선언. 310/311 표적 검사의 chapter5 normal FAIL1에서 발견했다.
현재 parser는 승인308의 정확 후계인데 chapter5 공개 보존 루프가 구버전 SHA만
요구한다. 실패 원본 `order310-check-chapter5-first.json`을 보존한다.

- 깊이: 맞는 번역을 검사하는 승인 코드를 구버전 오인으로 거부한다. 검사를 끄면
  실제 변조를 놓친다. exact 전후 Git 원본 증명만 추가한다. 게임/선택/경제/장기
  상태 차이0이며 새 원고·시스템·인간 판정을 만들지 않는다.
- 저자 `/root/blackjack_accounting_tests`: `tools/chapter5_human_reject_audit.py`
  한 파일. parser 경로 하나에 전후 commit/SHA와 현재 raw successor를 확인한 뒤
  검증된 predecessor bytes를 역사 비교용으로만 반환한다.
  기존 PUBLIC_DEMO_FROZEN_FILES·CN 전이·127 self·305/310 helper·실제 parser는 무수정.
  rollback/변조/타경로/잘못된 pin/누락 Git 증거를 거부하는 별도 self만 추가한다.
- root: 큐2파일·이 사양·CLAUDE 현재행·WORK_LOG·생성STATUS·새 작업판정 원장.
- `/root/release_status_crosscheck`: 새 private `order312-evidence-bridge.py`만.
  731c60a의18 static capture(17PASS/1FAIL)와 runtime의 실제 pins/raw를 대조하고,
  최종 delta가 이 checker와 선언 metadata뿐임을 증명한다. 기존 증거/helper 덮기0.
- 비저자 `/root/blackjack_accounting_review`: 새 private `order312-review*.json`과
  `docs/agent_reviews/ORDER-312.json`만. 310/311 보고 소유는 기존 선언을 유지한다.
- 검증: chapter5 normal/self·기존127 보존·새 음성 경계, exact evidence bridge.
  앞720 year5 회귀·5언어 엔진·다른 검사 성공은 입력 무변경 증명으로 재사용하며
  이 한 checker 때문에 게임/장기 검사를 반복하지 않는다.
- 전후 parser: `636a457fe44db3470cc37443c060230d4fbe2fbe` → 승인
  `59d4f790ecfd84f023c5796039264e4bfe72cdcf`. 공개 source/package GO 상속0.
  인간OPEN45·공개옛GO1·본편HOLD·40299/b136/meta9·보류72 보존.
- 규범: 일회성 exact 후계 수리, 기존 WORK_UNIT 적용. 자동 통과는 도달성·계약
  증거이며 재미·깊이·원어민/인간/물리패드·전체제품/출시 GO가 아니다.
