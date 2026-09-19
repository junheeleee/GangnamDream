# Active Queue Spec: ORDER-275

#### [~] ORDER-275 중국어 직업·공동 주거·기록 표시 5키

2026-09-20 착수. 부모 ORDER-157, 기준 main `211997655dfbe9a5aaecfce926a1f0796c1b67b4`.
사용자 전체 현지화·내부 검수 위임 안의 text-only 배치다.

## 깊이 3문과 원문 모집단

1. 없으면: 아래 실제 consumer의 CN/TW 문구가 영어 fallback으로 남는다.
2. 상태: 번역값만 달라지며 주거 소유·결혼·투자·기록 수와 게임 상태는 그대로다.
3. 경쟁: 같은 자리의 fallback을 대체한다. 새 화면·선택·AP 행동은 만들지 않는다.

| 정확한 KO 키 | 실제 소비자와 경계 |
|---|---|
| 무직 | GameState.get_job_display_name 빈 직업 → MainGame HUD |
| 다은과 사는 작은 서울 신혼집 | GameState.get_presentation_home_name → 종료 결과 복사 본문 |
| 다은과 사는 신혼집 | GameState.get_presentation_home_display_name → 주거 표시 |
| 💥 마진콜! %s 강제청산 — 손실 %s | InvestmentSystem._check_margin_calls → 새 거래 로그; 기존 레버리지 보유 조건 |
| 외 %d개 기록 | MainGame._month_summary_action_card, 최초3개 외 추가 기록 수 |

집 두 이름은 결혼 완료·이혼 아님에서만 쓰는 표현이며 소유/매입을 뜻하지 않는다.
마진콜 두 인자는 자산명→손실금액이다. 새 투자/AP 진입·과거 로그 재번역은 비범위다.
첫 월급 로그·토스트2는 투자 접근 가능성의 원문 사실 확인이 남아 이번 모집단에서 제외한다.
기존 JA5는 바이트 보존만 하며 새 언어 판정/수용으로 세지 않는다.
RO 메모 `post273-next-ui-scope.json` SHA c74a6ce408ec3eefc809d38f81100bf7f48852076edc31d4f7f22ae8d78f19f3 중 위5키만 선정.

## 정확한 파일 소유

- ROOT: `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json`에 위5키씩 raw append;
  `content/meta/full_game_localization.json`의 공식 신규10값/1배치만.
- ROOT 운영: `CLAUDE.md`, `docs/CODEX_QUEUE.md`, `docs/CODEX_QUEUE_L3_PENDING.md`,
  이 active·`docs/queue_archive/ORDER-275.md`, `docs/WORK_LOG.md`, 생성 `docs/STATUS.md`,
  `docs/agent_reviews/ORDER-275.json`, `docs/agent_review_decisions.json`.
- ROOT 간체5, Rawls 번체5를 각각 KO에서 직접 저작. Poincare는 비저자 전량 검수.
- `.git/full-game-localization/order275-*`: 원문 export·초안·독립 리뷰·기존 helper의
  bounded 재사용·첫 실행 raw 증거만. 제품 밖 준비 기록은 기존 원문을 덮지 않는다.

## 검증과 완료 경계

원문5·현재 consumer/조건·token순서·공개121 비접촉을 먼저 대조한다. source-bound
export→check→raw 설치→새 exact export/import→portable 수용으로 공식 증거를 남긴다.
기존39895 hash·KO/EN/JA·source manifest·runtime·project·인간원장·공개판을 보존한다.
기존 `news-panel-locale-only`의 고유12 검사만 clean exact 후보에서 한 번 실행한다.
이전 오더의 소유권을 가져오는 것이 아니라 본 사양 소유12경로와 전체 변경을 별도로
대조한 뒤 기존 check-list만 재사용한다. 실패는 원형 보존 후 같은 모집단을 수리한다.
checker/collector 변경·전체 감사·엔진·240주·새 화면관찰은 비범위다. 부당한 검사
거부가 나오면 번역을 왜곡하지 않고 그 값은 보류, 수리는 별도 범위로 선언한다.
비저자가 원문/값10/실제 검증을 읽고 source commit/tree와 clean 검토 HEAD에 한정 GO를
결속한다. 마감 metadata만 바꾸면 metadata 표적 검사를 따로 한 번 실행한다.

공개GO1·인간OPEN45·기존61 agent 판정·기존보류90·본편HOLD 보존.
원어민·실제 화면·인간 플레이·물리패드 완료를 주장하지 않는다.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.
선정·소유·배치·검증은 일회성, 기존 WORK_UNIT/I18N 정본 재사용·새 규범0.
