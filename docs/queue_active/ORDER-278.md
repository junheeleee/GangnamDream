# Active Queue Spec: ORDER-278

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-278 [P0·전체 현지화] 경마 착순의 중국어 수량 오탐 수리와 보류 설명 8값 복구

**[~] 2026-09-20 Codex 착수 — 아래 파일만 소유한다.** 부모157의 후속이며
기준은 `1447e4eb0fbbd630126108559914981a9e4446a7`이다. 269 원형 보고의
`bet_type_explanations` 4키×CN/TW8값 전량이 모집단이다. 새 번역을 만들거나
보류 모집단을 줄이지 않는다. 지난277의 정보상 비용 수리는 그대로 보존한다.

## 깊이 3문

1. 지우면 무엇이 깨지는가: 정확한 착순 `第1·2名` 등을 인원 수로 오독하여
   올바른 경마 설명6값이 거부되고 같은 단위의 단승2값도 수용되지 못한다.
2. 24주 뒤 무엇이 다른가: 상태·경제·도박 규칙은 불변이며 해당 중국어 UI는
   영어 폴백에서 KO 직접 번역으로 바뀐다. 새 선택이나 재미의 증거가 아니다.
3. 무엇과 경쟁하는가: 전역 `名` 예외나 검사 맞춤 원고 개작 대신, 정확한
   KO/ID·지역의 실제 착순 span만 구분하고 잘못된 순위·수량 검사는 유지한다.

## 하나의 판정 단위

- `scenes/RaceTrack.gd::_bet_desc`의 연승·단승·복승·삼쌍승4키와
  `systems/HorseRace.gd` 지급 규칙을 원형8값과 전수 대조한다.
- 선언 뒤, 구현 전 정상8·착순 누락/추가/교체/재배열·말 수 변경·분류사
  교체·여분 수량·KO/ID/locale 경계 OFF의 유한 사례와 드라이버를 봉인한다.
  현 checker의 실제 direct/full API 오류 배열을 보존한다. 정상 통과 전 음성
  거부를 수리 성공으로 세지 않는다. OFF는 각 API의 baseline 배열과 같아야 한다.
- checker만 exact source-bound span 구분을 더하며 토큰·줄바꿈·문자·통화·
  용어 검사와 이전 self 기대값을 바꾸지 않는다. 전역 ordinal/名 면제 금지.
- 기존8값을 원문 직접 독립 검수하고 source-bound export/check 뒤 append한다.
  새 target hash export/import receipt로만 공식 원장을 갱신한다.
- 기존39921 수용 hash·UI 및 원장 역복원·JA·원문 manifest·공개판·인간 판정을
  보존한다. 정상 수용 시39929/b123/meta9, 기존보류80→72이며 검수 GO 전 수량은
  목표이지 완료가 아니다.

## 정확한 파일 소유권

- `tools/zh_translation_audit.py`: 위 착순 오탐의 helper·hook·표적 self-test만.
- `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json`: 원형4키×2 append만.
- `content/meta/full_game_localization.json`: 실제 신규8 receipt 및 한 배치만.
- `CLAUDE.md`, `docs/CODEX_QUEUE.md`, `docs/CODEX_QUEUE_L3_PENDING.md`,
  `docs/WORK_LOG.md`, 생성 `docs/STATUS.md`, 이 사양과 `docs/queue_archive/ORDER-278.md`,
  `docs/agent_reviews/ORDER-278.json`, `docs/agent_review_decisions.json`.

원문·런타임·collector·full_game_localization.py·JA·게임 효과·확률·저장·
project.godot·공개 데모·인간 원장·다른 보류72값은 비소유다. 사설 증거는
`.git/full-game-localization/order278-*`에 최초 출력과 실제 실패를 보존한다.

## 검증·판정

고정 direct/full 사례→지역별 실제4값 check/import→39921 보존을 수행한다.
clean 제품과 STATUS-only 검토 HEAD를 결속하고 기존 `news-panel-locale-only`
명명12 검사 목록을 재사용한다. 목록은 검사 선택용일 뿐 과거 오더 소유권을
상속하지 않으며 기준부터 전체 diff가 위13경로 안인지 별도 확인한다.
독립 비저자가 실제8값·checker diff·정상/변이/OFF·수용·보존·명명12를 전수
검토한 뒤 `work_unit` 한정 GO/HOLD를 기록한다. 폐쇄 문서 뒤 metadata6만 확인한다.
전체 감사·240주·엔진·화면/입력 검사는 실행하지 않는다. 이8값의 렌더·원어민·
인간 플레이·물리패드는 미관찰이며 본편HOLD·공개GO1·인간OPEN45를 유지한다.
자동 게이트는 도달 가능성과 계약 증거이지 재미·깊이·문체의 증거가 아니다.
새 규범은 없고 원문 직접 번역·증거/권한 분리는 기존 정본을 적용한다. 일회성.
