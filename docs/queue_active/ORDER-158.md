# Active Queue Spec: ORDER-158

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-158 [P0·전체 현지화] 초반 이후 사람·주거·연말 회수 8개 root를 세 언어로 옮긴다

**[~] 2026-09-07 Codex 착수 선언.** 사용자의 전체판 번역 지시를 잇는다.
한국어 제품 원문 `53493fe7abbbbb82f0e56352da22acb2fe63b034`의 텍스트만
JA/zh-CN/zh-TW에서 독립 번역한다. 본편 전체 번역 완료나 출시 GO가 아니다.

## 깊이 3문

1. **왜 이 장면들인가?** 출시 데모를 덮지 않고 이후 현수·다은·주거 변화·연말
   선택 회수와 2년차 진입을 잇는다. 문맥 없는 짧은 UI부터 수만 채우지 않는다.
2. **긴 연말 변형을 어떻게 쪼개는가?** 검토 단위는 300~800자씩 나누되 같은
   root의 전체 도입·선택·변형을 함께 읽는다. 조각을 요약하거나 다른 선택 결과와
   합치지 않고, 완전한 root를 대상으로 구조 검사·증분 병합한다.
3. **자동 통과와 언어 완성을 구분하는가?** source/target 해시·전체 leaf·수치·
   토큰·행동 사실의 L1/L2 증거를 남긴다. 원어민과 실제 화면 L3는 OPEN이다.

## 한 배치 — 20개 표적 단위

- 1: `hyunsu_result_fail` 전체.
- 2~4: `arc_goshiwon_goodbye` 도입·선택·결과.
- 5~6: `arc_daeun_02_regular` 도입·선택/결과.
- 7: `arc_y1_new_room_first_month` 전체.
- 8~13: `arc_year1_close` 도입·각 선택·조건별 결과를 원문 순서로 분할.
- 14~16: `arc_year_one_mark` 도입·선택·변형.
- 17~18: `arc_y2_bank_limit_review` 도입·선택/결과.
- 19~20: `arc_sangchul_03_network` 도입·선택/결과.

세 locale는 위 같은 20단위를 각각 한국어에서 작성한다. 금액은 원화,
호칭·인명은 해당 지역 용어집, 사람의 행동/응답/소유/생사는 원문 그대로다.
고시원·월세·전세·한국 직급을 일본/중국 제도로 바꾸지 않는다.

## 정확한 파일 소유권

- `content/events_{ja,zh-CN,zh-TW}/` 아래 `arc_hyunsu.json`,
  `arc_midgame.json`, `arc_daeun.json`, `arc_year_close.json`,
  `arc_chapter_themes.json`, `arc_events.json`의 위 8개 root 텍스트만.
- source-bound 배치/응답/receipt는 worktree git-private 경로에 보관한다.
  새 증분 도구로 source/target 일치·누락/추가/중복·gameplay 불변을 검사한다.
- `content/meta/full_game_localization.json`의 실제 수용 leaf와 미완료 장부,
  이 사양·CODEX_QUEUE·WORK_LOG·STATUS·CLAUDE·현지화 backlog 기록만.

### 같은 8개 root의 검사 오탐 수리 선언 — 2026-09-07

초안 CN 16/TW 18 leaf가 기존 중국어 검사에 걸렸다. 실제 오자는 번역에서
고쳤고, 아래 실물 오탐만 `tools/zh_translation_audit.py`와 그 내부 self-test로
추가 소유한다. 새 원고·경제·관계 범위는 열지 않는다.

- 상자 수의 `只/箱`, 글자/제목 수의 `個字/個標題`, 눈길 `一眼`, 전화 수신의
  `兩聲`, 공간을 차지하는 `一處/一塊地方`, 첫 행 `首行`을 정확한 문맥으로 읽는다.
- `첫 주는`의 ‘주’가 사람 존칭 `주`/명 등의 탐지와 겹치는지 재현하고,
  정상 `第一週`를 소비 순서 때문에 놓친다면 종류·span을 보존해 고친다.
- 원문에 `한PD건설`이 있는 경우만 `HanPD`를 허용한다. 무관한 영어는 계속 거부.
- `群`의 대만 표준자 여부를 공식 사전으로 확인하고, 공유자라면 그 한 글자만
  출처와 함께 정정한다. OpenCC 자료·해시·다른 혼용 문자는 바꾸지 않는다.
- 단순히 두 사람이 등장한다는 이유로 source에 없는 `兩人`을 수량 검사에서
  광역 허용하지 않는다. 원문에 없는 강조는 자연스러운 상호 표현으로 정리한다.

모든 허용 형태에 수 변경·수 누락·다른 단위/문맥·상호 없는 영어의 음성 사례를
동반한다. 기존 금액·포맷 원화·문자 혼용·공개 데모 검사는 전부 유지한다.

`arc_jaehyuk_01_reunion`을 포함한 기존 공개 데모 텍스트, KO/EN 원고,
효과·선택 수/순서·플래그·일정·런타임·저장·폰트·제품 언어 공개 설정은 비소유다.
검사 오탐이나 새 runtime 누락은 별도로 선언하며 통과를 위해 광역 완화하지 않는다.

**증거:** locale별 원문/번역 leaf 수와 해시, 원문 의미 대조, 선택 merge 검사,
보호 데모 불변, 대상 구조 감사·공통 회귀. 원어민/화면 게이트는 OPEN.
**규범 판정:** 번역 지속 규칙은 `I18N_INFRASTRUCTURE.md`와 세 용어집이 이미
소유한다. 위 8개 root·20단위·파일 범위는 이 배치에만 쓰는 일회성이다.
