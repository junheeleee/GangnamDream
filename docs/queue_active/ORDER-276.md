# Active Queue Spec: ORDER-276

#### [~] ORDER-276 중국어 취소 힌트·자산 증가·불러오기 오류 3키

2026-09-20 착수. 부모 ORDER-157, 기준 main `e99a3ed337ced9c30267aae3cc40b22631e71ffa`.
사용자 전체 현지화·내부 검수 위임의 text-only 배치다.

## 깊이 3문과 정확한 모집단

1. 없으면: 실제 메뉴·월말·설정 오류 표면의 간체/번체가 영어로 남는다.
2. 상태: 번역만 바뀌며 취소 허용·패드 입력·월말 수치·라이선스 파일은 그대로다.
3. 경쟁: 기존 세 표면의 fallback을 대체하며 새 기능/선택/AP 진입은 없다.

| 정확한 KO | 실제 소비자와 경계 |
|---|---|
| [%s] 뒤로 | MainGame._open_modal; 취소 가능 && 패드 활성일 때 %s=East 글리프 |
| 자산이 %s 늘었습니다. 이 흐름을 유지하세요. | MainGame._calc_month_grade → 실제 grade.msg; %s=기존 원화 자산 증가 formatter |
| 라이선스 전문을 불러오지 못했습니다. | StartMenu._third_party_license_text → 설정 고지; 지정 파일 부재일 때만 |

RO메모 `post275-next-ui-scope.json` 15217B/SHA4302fe97369150e23958592995557f9f217898535d1fbfc50b04d21fe68e7085 중 위3키만 선정한다.
`흑자에 자산 성장까지. 좋은 한 달이었습니다.`는 net>=0의 0경계 원문 결함 때문에
저작 전에 제외한다. 첫 월급2·기존보류90도 비범위다. 파일 오류는 실제 배포파일
결손 관측이 아니고 라이선스 본문/법률 인증을 번역하거나 바꾸는 작업이 아니다.
기존 JA3는 원형 보존만 하며 새 언어 GO/수용으로 세지 않는다.

## 파일 소유

- ROOT: `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json` 위3키씩 raw append,
  `content/meta/full_game_localization.json` 신규6값·1배치만.
- 운영 ROOT: `CLAUDE.md`, `docs/CODEX_QUEUE.md`, `docs/CODEX_QUEUE_L3_PENDING.md`,
  이 active·`docs/queue_archive/ORDER-276.md`, `docs/WORK_LOG.md`, 생성 `docs/STATUS.md`,
  `docs/agent_reviews/ORDER-276.json`, `docs/agent_review_decisions.json`.
- ROOT 간체3·Rawls 번체3는 각각 KO 직접 저작, Poincare 비저자 전량 검수.
- `.git/full-game-localization/order276-*`: source-bound 교환·초안·리뷰·기존 bounded
  helper 재사용·원형 QA. 다음 보류 수리의 RO메모는 진단 제안뿐이며 제품 변경0.

## 검증과 종료

원문3/consumer·placeholder·공개121 비접촉을 전수 확인하고 export/check/raw 설치/
새 exact export/import/portable 수용한다. 기존39905 hash·KO/EN/JA·원문 manifest·
runtime·project·인간원장·공개판을 보존한다. clean exact 후보에서 기존 명명
`news-panel-locale-only` 고유12를 한 번 실행하되 본 사양12경로의 전체 변경을
별도 대조한다. 실패 원형을 보존하며 검사 오탐을 번역 왜곡으로 회피하지 않는다.
checker/collector/runtime·전체 감사·엔진/실제화면·240주는 비범위다.
독립 비저자가 실제6값과 증거를 읽고 source commit/tree·clean 검토 HEAD에
한정 work_unit 판정을 결속한다. 마감 metadata만 바꾸면 해당6 검사를 한 번 한다.
공개GO1·인간OPEN45·기존62 agent판정·보류90·본편HOLD 유지. 원어민·화면·인간·
물리패드 미관찰을 유지한다. 이전274의 화면 증거도 승계하지 않는다.
선정·소유·배치·검증은 일회성, 기존 WORK_UNIT/I18N 재사용·새 규범 승격0.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.
