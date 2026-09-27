# Archived Queue Spec: ORDER-312

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [x] ORDER-312 [QA] 승인된 월세 검사 후계를 역사 핀과 분리한다

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

## 2026-09-27 완료 증거

- source `a0d4446f1290c22d6ef53b23e94e340439a5bf52`, tree `a4be8663f369da0048bc3031cab8070bcfdb1c86`; [독립 보고](../agent_reviews/ORDER-312.json) 작업 한정 판정.
- 생산자↔독자: `chapter5_human_reject_audit.py:248` exact승인308parser ↔ 기존 public frozen hash checker. 전후 Git 원본 SHA/경로/옛핀/current raw 모두 확인한 경우만 역사 바이트를 반환한다.
- 도달 경로: `CHAPTER5_HUMAN_REJECT_AUDIT_OK`, `CHAPTER5_HUMAN_REJECT_SELF_TEST_OK cases=146`. 기존127 원문보존+양성4/음성15=새19. 두 최종 캡처1220핀/exit0/stderr0/전후clean·동일.
- 최초 FAIL1 `order310-check-chapter5-first.json` 및 옛self127은 원형 보존. wrong path·rollback·변조·옛핀변경·누락/변조 Git proof는 거절하며 기존 CN전이·공개핀·실제 parser 변경0.
- bridge375행 SHA `2f3d4355775898d39dc7b63b95a7f64a25a417eb36543636248568c68a11443b`; 최종 capture `addc10ddd1ee6894be520c3f54f6e775a127627e58223a862e121092ee23562f` PASS/2.324초.18고정캡처·runtime3로그·1219Git source·9path 최종차이 대조. 재사용16정적+엔진1, 새엔진0.
- 원격108c41b의 R2 문서계획은 충돌 번호310만313으로 변경해 보존했다. 수리7/판단5 본문·309정정 보존, 제품/검사 원격 변경0. 원장93·privateaccepted153·40299/b136/meta9 및 과거 공개/인간 기록 불변.
- 바꾸는 상태: 검사 오탐1만 해소. 경제/선택/원고/저장0. 포기비용·서사 위치·장면 계층 해당 없음. 닫는 것: exact 검사 후계 연결만, 전체 제품/화면/출시 GO0.
- 규범 승격: 없음(일회성 exact 전이). 자동 통과는 도달성·계약 증거이지 재미·깊이·문체의 증거가 아니다.
