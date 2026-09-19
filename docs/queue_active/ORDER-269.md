# 날짜·목표와 경마의 중국어 UI 누락

#### [~] ORDER-269 중국어 UI 20기능·101키

[~] 착수 — 2026-09-20 Codex. clean main `a09fb3c2eb7c3edda7b899dd12159a81595b0787`.
공식39450/b113/meta9·기존55판정. 최신 번역 초안 우선 지시를 수행한다.

## 한 배치·깊이3문

이 번역을 빼면 실제 날짜·목표·상태·경마 표면이 중국어 대신 영어로 남는다.
24주 뒤 상태나 효과를 바꾸지 않는 번역 단위며 영어 폴백·휴면 원고 저작과 경쟁한다.
짧은 라벨마다 새 오더를 만들지 않고 독립20기능으로101키를 관리한다.

## 고정 범위

`.git/full-game-localization/post268-ui-next-plan.json`
SHA `169c9c3b7a7d553c204d6933aed9ea93d1a4577a6c831091519f10330f0515d1`의
selected_rows101과 units20만 소유한다. 실제 기존 collector export에서 원문/ID·보호·지원성을 확인한다.
경마/말81·규칙닫기1·현재목표12·상태칭호3·날짜1·숙련3이다. CN/TW각101부재,
JA101은 기존값 보존·이번 검수/수용0이다. 원202는 완료 수가 아니다.
경마는 멘토→첫방문 선택→story followup의 기존 연결만 근거로 삼고 실제 전경로 도달은 미관측이다.

## 파일 소유권

- ROOT 제품: `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json` 선택101 추가와
  `content/meta/full_game_localization.json` 실제 신규수용만.
- ROOT 운영: `CLAUDE.md`, `docs/CODEX_QUEUE.md`, `docs/CODEX_QUEUE_L3_PENDING.md`,
  본 사양, `docs/queue_archive/ORDER-269.md`, `docs/WORK_LOG.md`, `docs/STATUS.md`,
  `docs/queue_backlog/FULL_GAME_LOCALIZATION.md`, `docs/agent_review_decisions.json`,
  `docs/agent_reviews/ORDER-269.json`.
- Plato는 간체, Rawls는 번체를 각각 KO 직접 저작해 별도 private 초안만 쓴다.
  Poincare는 비저자202 전수검수와 실제 후보 한정 판정을 맡고 ROOT만 실행·수용·Git을 한다.

## 보존과 유한 검증

KO/EN·JA·게임/표시 코드·배당·수량·말ID·저장·공개데모·인간 원장·기존39450·268보류62는 비소유다.
말 종류/착순/배당과 순익·정보상 주장과 실제 결과를 구별하고 원화·기호·토큰·개행을 보존한다.
공유키 나가기/날짜/신마/숙련/규칙닫기는 기존 의미 전체와 맞추되 새 진입이나 소급 저장 변환을 만들지 않는다.
구AP/phone/debug/비노출/fallback·영어직행 수리·새검사/fixture/역사 pin/audit_scope 확장0이다.

1. clean 선언에서 각101 export → 병렬 KO직접 초안 → 비저자202 전수 언어검수 → 기존 선택 check.
2. 첫 실패는 보존한다. 언어 결함이면 원고를 고친다. 검사 인식/미지원이면 해당 기능묶음을 HOLD로 분리하고
   자연스러운 원문 뜻을 왜곡하거나 새 검사 수리로 확대하지 않는다. 원202 전체PASS로 부르지 않는다.
3. 승인값만 apply_patch 설치하고 clean 후보 재export 뒤 기존 import --accept로 실제 receipt를 받는다.
   동일값 import는 제품변경0이다. 신규만 portable에 더하고 기존39450/current hash·UI/portable 역복원·JA를 대조한다.
4. 기존 news-panel-locale-only 명명12를 재사용하되 이번 소유13파일과 실제 전체diff를 별도 결속한다.
   전체old L1·engine·full audit·240주·새도구0. 독립 clean exact 한정 판정 후 보고/원장/큐/STATUS를 마감한다.
5. 보류가 생기면 원고를 독립 보고 안에 보존하여 이후 중복 저작을 막는다. 다음 실제 UI 초안을 우선한다.

일회성 작업 지시이며 언어 계약·권한은 기존 I18N 정본과 WORK_UNIT을 따른다.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.
공개GO1·인간OPEN45·본편HOLD 유지. 원어민·실제화면·인간플레이·물리패드 관측과 외부출시 권한0이다.
