# Active Queue Spec: ORDER-277

#### [~] ORDER-277 정보구매 비용의 원화 검사 오탐과 보류 번역 복구

2026-09-20 착수. 부모 ORDER-157, 기준 main `990c95d94c03537e6a1e8d2cc8bf561483614290`.
기존 정보상 기능의 5키×CN/TW 10값만 복구한다. 새 저작·경마 기능 변경은 없다.

## 깊이 3문과 모집단

1. 없으면: 실제 3,000원 비용을 원화로 명확하게 번역한 정상 문장을 검사기가 거부하여 정보상 기능이 영어 폴백으로 남는다.
2. 상태: 비용·신뢰도·확률·돈 부족 조건은 불변이다. 번역 수용 여부만 달라진다.
3. 경쟁: 기존 정보상 문구의 폴백을 대체한다. 새 선택이나 AP 진입을 만들지 않는다.

RO 메모 `post276-held-repair-plan.json` SHA `5cb919180158055b7f1e345ed238bb21f5762560791e1d05266de56b8f546909`의
`held_rows_exact_from_public269` 5행을 전량 사용한다. 최초 언어 GO 원고10과 machine FAIL2/기능 보류10을 보존한다.
핵심은 `정보상에게 듣기   -3,000   (오늘의 한 마리...)` exact KO/ID 하나다.
`RaceTrack._build_dealer_row → _consult_dealer`의 실제 `add_money(-3000)`가 비용 의미를 소유한다.
착순8값·나머지 보류80·새 원고·JA는 비범위다.

## 구현 경계와 파일 소유

- Plato: `tools/zh_translation_audit.py`만. locale/exact ID/whole KO와 독립 비용 슬롯을 확인한 numeric/money source-view 수리 및 같은 파일의 작은 self-test 블록. target 삭제·정규화·통과문장 whitelist·전역 숫자 예외·기존 기대값 완화 금지.
- ROOT: `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json` 원고5행씩 raw append, `content/meta/full_game_localization.json` 실제 통과10값·1배치만.
- 운영 ROOT: `CLAUDE.md`, `docs/CODEX_QUEUE.md`, `docs/CODEX_QUEUE_L3_PENDING.md`, 이 active와 `docs/queue_archive/ORDER-277.md`, `docs/WORK_LOG.md`, 생성 `docs/STATUS.md`, `docs/agent_reviews/ORDER-277.json`, `docs/agent_review_decisions.json`.
- git-private `order277-*`: Rawls 고정 positive/mutant/OFF 사례와 직접/full 회귀 드라이버, ROOT 교환·입력핀·원형 캡처, Poincare 독립 계획/언어/최종 보고.
- 기존 collector/full 도구·runtime·KO/EN·project·공개판·human·기존63 agent판정은 원형 보존한다.

## 검증과 판정

변경 전 고정 정상10·변이12·OFF/무표기·독립 토큰/태그 사례를 봉인하고 최초 direct/full 결과를 보존한다.
정상 핵심2의 수리 후 PASS가 선행해야 변이 거부를 유효 회귀로 센다. 원화 없는 target은 기존 경로 그대로다.
실제 baseline/post 직접/full 검사, 공식 export/check → UI 적용 → 새 exact export/import --accept → portable 및 기존39911 전수 hash/raw inverse를 확인한다.
최종 clean exact에서 기존 `news-panel-locale-only` 고유12를 한 번 실행한다. 이번 전체 변경13경로를 별도 대조하며 새 작은 블록도 기존 ZH self-test에서 실행한다.
runtime/collector 비변경이므로 엔진·전체 감사·240주·화면 검사는 하지 않는다. 최종 metadata만 바꾸면 해당6 검사를 한 번 한다.
Poincare는 저자와 다른 검수자로 실제 원고10·코드 delta·실행 증거를 전량 읽고 exact source/tree·검토 HEAD에 한정 GO/HOLD/REWORK를 결속한다.
과거 FAIL·보류를 지우지 않으며 실제 수용 전 보류90 그대로다. 공개GO1·인간OPEN45·본편HOLD, 원어민·화면·인간·물리패드 미관찰을 보존한다.
위 선정·배치·소유·검증은 일회성, 기존 WORK_UNIT/I18N 규범 재사용이다.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.
