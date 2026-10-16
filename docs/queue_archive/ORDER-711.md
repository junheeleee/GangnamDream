# ORDER-711 — 선택 회수 문단의 일반 표식

#### [x] ORDER-711 완료 — 2026-10-16 · C2/C4 선택 회수 표식 한정

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

## 완료 근거 · 한정 수용

`StoryMode._resolved_story_description`의 기존 memory append 한 곳만 바꿨다.
실제 조건/빈값/중복 배제를 통과한 블록 앞에 승인된 회색 기울임 한 줄을 붙이며,
표식 뒤 단일 줄바꿈으로 기존 원문 문단 index를 보존했다. 전체 교체 변형만으로는
표식이 없고, 갤러리는 기존 저장 selector만 읽는다. 본문·조건·id·효과·순서 변경0.
초기 저작의 들여쓰기 오류는 동결 전에 원래 깊이로 고쳤고 실패를 검수 보고에 남겼다.

- 기존 UI pair120개 전부 원형+새1개. controller38 불변·StoryMode82→83·target121→122.
  CJK 사전은 새 키 하나씩만, 기존 셀/순서와 전체 raw 역산3/3 exact.
  manifest·본문 번역/원장 재결속0. 비소유819파일/34,137,686B 직접 지문 drift0.
- 신규 5언어×10조건=50사례/실제 decoded20페이지. 불일치·빈값·중복·교체-only·
  교체+memory·저장 갤러리/현재 live 반대·selected/deferred 순서를 검증했다.
  old renderer+new checker는 KO/matching에서 exit1; intentional ERROR와 ObjectDB
  WARNING를 원raw로 보존했다. 수정 full headless11.993795초 exit0/stderr0,
  이전710 8사례 및 기존156case/1044page marker도 유지했다.
- 별도 opt-in GUI9.726649초 exit0/stderr0. 기존 캡처 경로의 1280×800 PNG5장을
  root/비저자가 직접 모두 봤다. 표식→회상 순서·정확 문구/스타일·잘림/겹침/BBCode
  노출0. 실제 엔진의 자동 fixture 렌더이지 native 입력·사람·원어민 관찰이 아니다.
  HUD 초기 값은 fixture 상태이며 대표 경로의 돈/시간 증거로 세지 않는다.
- demo UI122/122·self55·JA UI2954/2954·EN 한글0·Chinese UI contract0·context/
  실제 queue checker/diff 통과. 첫 root의 없는 codex_queue.py 호출실패는 보존하고
  올바른 queue_consistency_check로만 정정했다. 검사/예외/래칫 완화0.
- 기존 checker28→29함수 중 `_ready` 두 삽입과 새 함수만 추가했다. 역산 전체 raw
  exact·기존27함수 불변. narrow opt-in은 기존 full 실행/710 회귀를 대체하지 않는다.

엔딩 읽기 확인: MainGame:21531의 후일담은 EndingSystem:153/:180의 실제 consumed
종막 선택 영수증 coda를 이미 표시한다. MainGame:21562/:22151/:22284의 시간 원장은
저장된 연말 선택 제목과 CHOICE PATTERN을 표시한다(GameState:947). 결정적 선택 회수/
연말 요약은 있으나 모든 선택의 연대기 목록은 아니다. 새 엔딩 UI/실제 엔딩 관측0.

독립 `/root/m32_isolation_review`는 diff6·보호819·stage6핀·원raw32(29전독/3진단scan)·
PNG5/5·증거26핀을 직접 검수해 `GO_DECLARED_A5_SOURCE_RENDER_DELTA_ONLY_PENDING_INTEGRATION`.
private `independent-final.md` 5292B/SHA256
`1933476eed20b9729b09142f208c49e0edc1d373446c77fd00782e55f24a887c`,
JSON14137B/SHA256 `5eb65eb9224f9914f0ac96545b5ae995d7e2d745f9364ab31a51ce3f308cca89`.
원before·source/checker 역산·표적/engine raw·5PNG·통합 영수증은 위 private 경로에 보존한다.

개발 스킬의 격리·표적·exact marker/오류 scan·독립 증거 분리를 적용했다.
승격0: 표식 규범은 최신 DECISIONS가 이미 소유하고, 실행/검증 지시는 일회성이다.
711 사용자 앱/저장/설정 직접 접근0·project/preset/공개/과거 판정/H3·W145 불변.
710의 원설정 mtime 사고를 소급해서 보존 성공으로 바꾸지 않는다.
709 CI38904281491은 전체 success지만 710/711 수정 CI는 별도이고 진행≠녹색이다.
새 export/실제 월/사람2~3시간/CJK 원어민/패드/청취/전체C2/M60/출시 GO0.
다음은 결정2 별도 exact 선언과 새 main 전체CI success 뒤 W145/M37 재개다.
