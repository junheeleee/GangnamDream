# ORDER-264 — 커피 회차 검사 오탐 수리 결과

[x] 2026-09-19. Poincare LOCAL work_unit GO / required0.

- source/review `3bcc93f1feff99c0c9c69b4e3bcdb651e3d086b5`, tree `2b4f2a57818500cedc0d78c11b3fccdcf937b0cf`, clean.
- exact UI+source+CN/TW 숫자 비교만 회차2로 해석한다. 실제 컵/사건제목/다른 key는 기존 경로다.
- 최초 표적1(24유형60행/46유효음성), fullself263, ZH12446 및 보존 모두 PASS.
- 원래263의58PASS/2FAIL은67b40fb3로 보존한다. 이번 신규번역수용0·공식39151/b109 유지.
- 제품2만 변경, 나머지 제품·UI3·원장39151·old49판정·human·project 보존.
- 실제 화면·원어민·인간플레이·전체L1 미실행. 공개GO1·인간OPEN45·본편HOLD.
- 규범 분류: 기존 계약의 일회성 적용, 새 영구 규칙0.

[독립 최종 보고](../agent_reviews/ORDER-264.json) · SHA 188d2b03ef0ff97f4fb55013b15fa4d534d98aac408c917d7e58d877ad5fda93

## 후속

263은 새 clean 기준선으로 재개한다. 사건 제목3의 잔 수 표현은 별도 부채이며
post264-coffee-event-title-followup.json a922201e에 보존했다.

## WORK 착수 원문

## 2026-09-19 (Codex — 커피 차수 검사 수리 착수)

- [264](queue_active/ORDER-264.md):263의 실제58PASS/2FAIL을 수리한다.
- 커피를 잔 수로 단정하는 검사 오탐이며 번역·원장 적용0, 공식39151 유지.


## 선언 원문

# 커피 진행표의 중국어 차수 검사 오탐

#### [~] ORDER-264 커피 차수 계약

[~] 착수 — 2026-09-19, Codex. 기준 `9b091a2ab87505f95a22546d55b72bf44d89434d`.
263 첫 L1 `67b40fb3`은58통과/2실패이며 제품 번역은 아직 적용0이다.
기존 계약의 일회성 표적 수리, 새 영구 규칙0이다.

## 단위·깊이3문

`두 번째 커피` 진행표는 두 번째 대화 맥락인데 generic ordinal noun 분류가
커피를 컵으로 단정하여 정상 CN `第二次咖啡闲谈`/TW `第二次喝咖啡`를 거부한다.
원문·소비자를 고정한 숫자 비교 어댑터 하나만 맡는다. 제거하면 실제 정상 번역이
잘못된 잔 수 표현을 요구받는다. 선택·24주·1년/5년 상태 변화0이며 같은 자리의
번역 왜곡이나 전역 cup 완화 대신 확인된 UI 의미만 수리한다.

## 계약과 소유권

- 제품2: `tools/zh_translation_audit.py`의 exact UI key/source/Chinese locale
  숫자쌍 어댑터 및 연결, `tools/full_game_localization_self_test.py`의 독립 유한 회귀.
- ROOT 첫 파일 구현·Git·검사; Rawls 두 번째 파일의 새 test method만 저작.
  Plato RO 대조, Poincare 비저자 코드·최초 증거·최종 단위검수.
- 운영10: 본 사양, `docs/queue_archive/ORDER-264.md`, `docs/queue_active/ORDER-263.md`,
  `docs/CODEX_QUEUE.md`, `docs/CODEX_QUEUE_L3_PENDING.md`, `docs/WORK_LOG.md`,
  `docs/STATUS.md`, `docs/agent_review_decisions.json`, `docs/agent_reviews/ORDER-264.json`,
  `CLAUDE.md`의 현황만.

어댑터는 source=`두 번째 커피`, key=`ui:두 번째 커피:/두 번째 커피`, CN/TW에서만
차수2/커피 대화 회차를 검사한다. 원문을 고치지 않고 숫자 비교만 해당 회차 의미로
정규화한다. 실제 컵·믹스커피·방문·다른 key/source/JA 경로는 기존 그대로다.
반환 오류 필터·정상 target 전문 whitelist·전역 cup→次 허용·기대 삭제는 금지한다.
문자·토큰·금액·단락·용어는 원래 source/target으로 계속 검사한다.
263 번역값·원장39151·공개데모·human·프로젝트·게임코드·저장·등록표 변경0이다.

## 검증과 완료

실패 원형을 보존하고 직접 함수/공식 translation_errors 두 진입을 검사한다.
두 실제 정상부터 확인한 뒤 잘못된1/3·차수 누락·杯 치환·커피 누락·추가수량·
숫자/단위 위장 및 비소유 source/key/locale OFF, 실제cup·믹스커피·방문 정상/음성,
원래 money/token/script 진단을 유한 표본으로 잠근다. 새 case는 15~25개의
독립 의미변이로 구성하며 두 locale 반복은 별도로 센다. 기존 사례 기대 불변이다.
선택 method 최초 실행, 기존 전체 full localization self와 ZH self는 최종소스에서
각1회 실행한다. 소유12 diff·코드 외 제품 raw·기존39151 수용값을 보존한다.
전체L1·엔진·원어민·사람플레이 재실행0. 기존 차선을 확대하거나 새 레지스트리를
만들지 않고 이번 두 코드 소비자의 표적 검사를 직접 실행·원형 보존한다.
최종 독립 GO 뒤 기록/보관/metadata만 마감하고263은 새 clean 기준선에서 재개한다.

기계 계약 GO≠번역60 수용/렌더/인간GO다. 공개GO1·인간OPEN45·본편HOLD 유지.
