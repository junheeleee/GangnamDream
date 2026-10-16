# ORDER-711 — 선택 회수 문단의 일반 표식

#### [~] ORDER-711 착수 — 2026-10-16 · C2/C4 읽기·선택 인과 가시화

PR39는9f0d077로main병합됐고선행넘김수리710은49bee97로마감했다.
정본은DECISIONS 2026-10-16 A5이며순서1→5→2→3→4를유지한다.

## 깊이3문·수용

이미선택한일의결과가돌아온문단임을작은일반표식으로구분한다. 원고나조건을
새로쓰지않아허위선택·직업·관계·날짜를만들지않으며, 기존의실제memory조건과
문단순서를그대로소비한다. 새선택계층·보상·미래결과예고0이다.

`description_memory_if_known`가실제로추가한블록바로앞에만기존causal_frame의
`[color=#9aa4b2][i]…[/i][/color]` 한줄을붙인다. KO `지난 선택`, EN `An earlier choice`,
JA `以前の選択`, CN `之前的选择`, TW `之前的選擇` exact이다.
조건불일치/빈memory/중복으로생략된블록에는표식0·`description_if_known` 전체
교체만으로는표식0이다. 갤러리도기존보존선택조건만사용하며원live선택을발명0.
선택전description/choice에미래회수를알리는문구0·본문/id/flags/조건/effects/순서0.

## exact 소유·분리

- `/root/m32_path_review`: `scenes/StoryMode.gd`의기존memory append구간만·
  `locale/ui_ja.json`, `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json` 각각새UI키1개.
  KO/EN2문구는기존 `_tr`/LocaleManager.ui를쓴다. 타이핑/hold/선택/저장/엔딩불변.
- `/root/av_audio_status`: 기존 `tools/StoryPlaybackCheck.gd`에이표식의관련회귀만.
  5언어·실제memory조건유무·빈값·중복배제·전체교체변형·본문순서/표식스타일·
  선택무확정을검사한다. 기존함수/710 8회귀보존·실행/최종판정0.
- root: `tools/story_demo_localization_audit.py`의UI실수집개수83/122 정합만
  (기존controller38/기존키집합+새키1을증명). 필요가실제확인될때만
  `content/meta/demo_localization_scope.json`의현재UI source 개수/hash 셀을정합한다.
  기존검사·예외·threshold완화/본문번역원장재결속0·별도새검사도구0.
- root: 이사양/archive·CODEX_QUEUE/L3·CLAUDE현재행·WORK_LOG, private
  `.git/order711-choice-recall-marker-20261016/` before/원raw/캡처/보고/수용영수증.
  root만Git/QA/엔진/UI·독립 `/root/m32_isolation_review`는정확diff/기존키보존/
  표적원raw/실렌더표본검수와private보고만. 저자는자가최종판정0.
- 엔딩화면의결정적선택요약기존소비자는**읽기확인만**한다. 없으면보고하고
  새엔딩UI/요약/분기/기록/저장스키마는만들지않는다.

## 검증·보존·C1

선행710의별도source archive·검증공식engine와pre-autoload fresh namespace
방식만쓴다. rootproject/preset·HOME/XDG·OS권한·사용자앱/저장/설정 접근/변경0.
새키의5언어lookup과실제StoryMode파싱/페이지표시가성립하는표적만실행한다.
정적 UI 개수 기대값은실제추가키1과동일하며, 새UI가원수집기에서보이지않으면
검사우회가아니라원인을먼저고친다. CJK본문다듬기/원장재결속/과거판정변경0.

실제수정후source회귀/관련UI source게이트·문서기본게이트·독립검수만마감한다.
자동실렌더와native/human/원어민/물리패드증거를구분한다. 전체로컬audit/새240주/
완료월재개0·CI진행≠녹색·새main전체success뒤보존W145/M37대표경로재개한다.
실제월최대2/월별관측·마감한commit·H3위험/옛복원HOLD/공개demo/사용자판정보존.
이오더는사용자승인A5의작은UI수리·일회성이고새규범은기존DECISIONS가소유한다.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.
