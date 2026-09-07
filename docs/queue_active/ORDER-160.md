# Active Queue Spec: ORDER-160

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-160 [P0·전체 현지화] 남은 결말18종의 기본·조건별 산문129개를 세 언어로 옮긴다

**[~] 2026-09-07 Codex 착수 선언.** 사용자 전체판 일본어·중국어 번역 지시를
`fc749d1`에서 잇는다. KO 제품 원문 `53493fe`와 기존597 번역·역사 메타9는
그대로 둔다. JA·zh-CN·zh-TW는 각각 한국어에서 직접 작성한다.

## 깊이 3문

1. **왜 남은 결말을 먼저 잇는가?** 현재17종만 번역돼 있으므로 성공·상실·직장·
   관계·극단 경로의 끝이 언어마다 영어로 돌아간다. 짧은 제목만 채우지 않고
   긴 기억 변형까지 전체 root를 옮긴다.
2. **숨은 조건까지 설명할 것인가?** 아니다. 표시되지 않는 condition34는 이미
   분리했다. 현재 표시 산문234 중 남은129개만 번역하며, 내부 경로 점수를 새
   설명·힌트로 노출하지 않는다. 서사에 명시된 생사·관계·상환만 보존한다.
3. **끝 문구만 번역하면 전체판이 되는가?** 아니다. 사건·catalog·UI·표시 소비자
   결손이 남아 있다. 엔딩 텍스트 L1/L2와 원어민·실제 화면·본편 GO를 구분한다.

## 두 배치 — 25단위씩

긴 root의 기본/기억 변형을 모두 읽고 원문 순서 300~800자 검토 조각으로
분할한다. 짧은 두 극단 성공 결말은 합계540자라 한 비교 검토 단위로 둔다.

- A1~8 `gangnam_dream`; A9~10 `empty_house`; A11~14 `jiyeon_man`;
  A15~17 `jaehyuk_way`; A18~19 `lonely_rich`; A20~21 `gangnam_dream_white`;
  A22~23 `sangchul_reckoning`; A24~25 `crypto_ghost`.
  8 root /59 leaf /16,493 KO characters.
- B1~3 `startup_exit`; B4 `political_fix`+`creator_success`; B5~7 `investment_master`;
  B8~9 `reputation_legend`; B10~12 `orthodox_pinnacle`; B13 `orthodox_hollow`;
  B14~15 `unorthodox_legend`; B16 `early_retirement`; B17~25 `career_climber`.
  10 root /70 leaf /16,259 KO characters.

각 언어에서 같은50단위를 독립 작성한다. 금액·나이·기간·말투·미성사와 성사·
아버지 생사·관계 단계·소유·부채 귀속을 원문과 대조한다. 원문 자체 결함이
발견되면 본문을 번역하면서 몰래 수리하지 말고 별도 사실 문제로 기록한다.

## 정확한 파일 소유권

- `content/endings_{ja,zh-CN,zh-TW}.json`의 위18 root 텍스트만.
  새 condition·gameplay 키0. 기존17종/105번역과 역사 메타3/locale 불변.
- `content/meta/full_game_localization.json`의 실제 수용129 leaf/locale와
  배치/진행 기록; git-private 원본 export·응답·검사 receipt.
- 필요 시 `tools/zh_translation_audit.py`, `tools/full_game_localization.py`,
  `tools/full_game_localization_self_test.py`의 이번129 원문으로 재현한 오탐만.
  같은 문맥의 정상·수 변경·다른 단위/문맥 음성을 쌍으로 추가한다. 새로운
  consumer·조건 분모·역사 기준선·공개 데모·숫자 blanket 완화는 비소유다.
- 이 사양·CODEX_QUEUE·WORK_LOG·STATUS·CLAUDE·전체 현지화 backlog,
  `tools/audit_scope.json`의 이 문서 등록과 필요한 오탐 검사 등록만.

KO/EN·runtime·원문·엔딩 라우팅·저장·폰트·공개 언어·human_gates는 비소유다.
세 locale 파일은 각각 한 에이전트가 독점하고, 독립 KO 교차 대조는 읽기 전용이다.
본편 소비자 수리는 이 텍스트 배치 뒤 별도 exact 사양으로 진행한다.

**증거:** A59/B70 source/target 해시·독립 원문 전수 대조·지역문자/금액/토큰·
모든 변형·기존597/메타9 보존·표적 회귀. 원어민·사용자 표본·실제 화면 OPEN.
**규범 판정:** 지속 규칙은 I18N_INFRASTRUCTURE와 세 용어집이 소유한다.
위 root·50단위·소유 파일·분할은 일회성이다. L3 없는 전체 완료/출시 GO 금지.
