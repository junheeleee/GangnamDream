# 인물 카드 관계 설명의 한자 별칭 오탐 수리

#### [~] ORDER-266 관계 괄호 검사 계약

[~] 착수 — 2026-09-19, Codex. clean 기준
`a2417fe04be76351e81f417ef56b8dc1d97ebcd0`.265 첫L1은50PASS/4FAIL,
원형1c6b2079를 보존하며 승인54/제품적용0/수용39211을 유지한다.

## 단위·깊이3문

UI `강현수 (친구)`와 `최재혁 (군대 동기)`의 두 CN/TW 관계표시가 별칭으로
오인된다. 관계를 없애거나 번역을 검사에 맞춰 비틀지 않고 이름 오독 검사만
원문·정확UI키·언어에 묶어 수리한다. 없으면 정본 인명과 관계가 공존하지 못한다.
선택/24주·1년·5년 상태 변화0이며 blanket alias허용과 경쟁하되 이번 두 key만 맡는다.

## 소유와 경계

- ROOT 제품: `tools/zh_translation_audit.py` exact source/key/Chinese locale
  관계명 괄호를 alias 검사 probe에서만 구별하는 helper와 기존호출 결속.
- Rawls 제품: `tools/full_game_localization_self_test.py` 독립 유한 새test method만.
  기존263tests raw역복원 exact, ROOT만 실행·Git. Poincare 비저자 최종검수.
- ROOT 운영10: 본 사양, `docs/queue_archive/ORDER-266.md`, `docs/queue_active/ORDER-265.md`,
  `docs/CODEX_QUEUE.md`, `docs/CODEX_QUEUE_L3_PENDING.md`, `docs/WORK_LOG.md`,
  `docs/STATUS.md`, `docs/agent_review_decisions.json`, `docs/agent_reviews/ORDER-266.json`,
  `CLAUDE.md`의 현재상태만.
- UI3·번역값·portable39211/b110·게임/원문·공개데모·human·project·audit_scope는 비소유.

의미가 명시된 friend/army-cohort 역할 어휘의 유한 괄호 문법만 인식한다.
정본 로마자 이름은 그대로 검사하고 괄호 역할만 alias probe에서 마스킹한다.
실제 한자이름/새별칭/성누락/다른인물/다른source/key/locale는 기존경로이며
원래 target 전체가 문자·토큰·수·용어 검사를 계속 받는다. 오류 삭제필터·전체
정상target whitelist·전역 한자별칭 완화0. 기존 code 경로의 OFF 진단도 보존한다.

## 유한 검증·완료

독립 fixture에서 actual4를 먼저 고정하고 문법변형, 인명·한자별칭·관계·scope·
문자·숫자·토큰 음성 및 OFF 전후 동일진단을 direct/full consumer에서 검증한다.
새test1→fullself→ZH self/skeleton와 raw보존 각 최초1회.263기존test는 역복원 exact.
기존39211 current source/target 해시와 portable/UI 전체raw·비소유를 보존한다.
실패 원문은 남기고 기대를 내려 통과시키지 않는다. 엔진/전체감사/전체oldL1 재실행0.
독립 clean exact 단위GO 뒤 원문보관·판정1행·metadata4만 마감한다.
265는 새 clean기준선 선언 후 같은승인54로 재개한다. 원래50/4는 합산하지 않는다.

규범 분류: 기존 현지화 계약의 일회성 수리, 새 영구규칙0.
자동 계약증거는 재미·문체·원어민·렌더·인간플레이·물리패드 증거가 아니다.
공개GO1·인간OPEN45·본편HOLD를 유지하며 외부출시 판단0이다.
