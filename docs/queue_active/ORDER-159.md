# Active Queue Spec: ORDER-159

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-159 [P0·전체 현지화] 일상·안정·회복 결말 14종의 모든 조건별 후일담을 옮긴다

**[~] 2026-09-07 Codex 착수 선언.** 사용자 전체판 일본어·중국어 번역 지시의
다음 실제 미번역 범위다. 제품 한국어 `53493fe`를 그대로 두고 `6e088e5`에서
이어간다. JA·zh-CN·zh-TW를 한국어에서 각각 작성한다. 기존 357문구는 보존한다.

## 깊이 3문

1. **짧은 결말만 채우는가?** 아니다. 기본 설명뿐 아니라 사람·기억·부채 상태가
   바꾸는 모든 조건별 변형을 root 전체로 읽고 번역한다.
2. **언어별로 삶의 결과를 바꿀 수 있는가?** 없다. 안정·회복을 강남 소유나 관계
   성사로 과장하지 않고, 원문의 기간·금액·질병·도박·가족 사실을 보존한다.
3. **무엇이 아직 완료가 아닌가?** 번역 L1/L2 수용만 기록한다. 실제 도달·원어민
   문체·화면·사람 표본·전체판 GO는 OPEN이며 기존 공개 데모도 덮지 않는다.

## 두 배치 — 18단위 + 15단위

같은 root의 조건별 원고를 함께 읽되 긴 변형은 원문 순서의 300~800자 검토
단위로 나눈다. 같은 33단위를 세 locale에서 독립 수행한다.

- A1~9 `ordinary_life`; A10~11 `stable_success`; A12~13 `balanced_life`;
  A14~15 `healthy_retirement`; A16~17 `career_burnout`; A18 `writer`.
  6 root /56 leaf.
- B1 `burnout`; B2~3 `mental_break`; B4~5 `bankruptcy`; B6~7 `debt_spiral`;
  B8~12 `gambling_recovery`; B13 `full_circle`; B14 `guardian`; B15 `second_love`.
  8 root /40 leaf.

도박 회복을 의지만으로 완치로 만들거나 채무 약속을 상환 완료로 바꾸지 않는다.
이 원칙은 새 서사를 쓰라는 지시가 아니라 원문에 있는 사실 그대로의 번역이다.

## 정확한 파일 소유권

- `content/endings_{ja,zh-CN,zh-TW}.json`의 위 14 root 텍스트만.
- git-private source/response/receipt; `content/meta/full_game_localization.json`의
  위 96 leaf/locale 수용 해시·배치 기록. 실제 원문 대조 뒤에만 수용한다.
- `docs/queue_active/ORDER-159.md`, CODEX_QUEUE, WORK_LOG, STATUS, CLAUDE,
  `docs/queue_backlog/FULL_GAME_LOCALIZATION.md`의 실측 진행 상태.
- `tools/audit_scope.json`의 위 문서 경로 등록만. 번역 검사 오탐이 새로 생기면
  별도 exact 선언 뒤 수리하며 수량·문자 기준을 통과용으로 넓히지 않는다.
- 부팅 예산 도달의 기계적 보존 이동만: 큐의 기존 공통 함정 절을
  `docs/queue_archive/CODEX_QUEUE_2026-09.md`에 원문 그대로 보관하고 링크한다.
  WORK_LOG의 2026-08-29 마지막 기록도 필요 시
  `docs/history/WORK_LOG_2026-08-29.md`에 원문 그대로 옮긴다. 이력 삭제 0.

KO/EN·gameplay·선택·엔딩 라우팅·runtime·폰트·저장·공개 언어·기존 공개 데모·
human_gates는 비소유. 보호 leaf 변경은 자동 거부한다. 세 locale 파일을 에이전트
각각 독점 소유하고, 독립 교차 원문 대조는 읽기 전용으로 수행한다.

**증거:** 배치별 source/target 수·해시·독립 원문 대조·지역 문자/숫자/토큰·조건
완전성·기존357/공개 데모 불변·표적 회귀. 사용자 표본·원어민·실제 화면 OPEN.
**규범 판정:** 지속 규칙은 `I18N_INFRASTRUCTURE.md`와 기존 언어 용어집 소유다.
이 root 목록·단위·파일 범위와 보존 이동은 일회성이다.

## 실물 분모 정정 선언 — 2026-09-07

`content/endings.json:condition` 34개는 내부 작성 메모다. 코드식과 한국어 요약이
섞여 있고 `DataRegistry.gd:1137`의 fallback 처리 외에는 Godot 코드 소비자가
없다. 실제 끝맺음은 `MainGame.gd:_resolved_ending_description`의 본문/변형,
제목·후일담을 표시하며 조건식이나 route 점수를 보여 주지 않는다.

- 최초 엔딩 포착 268 leaf 중34를 비표시 메타데이터로 분리한다. 번역 분모234;
  이번 A51/B32=83 leaf/locale. 18+15 서사 단위는 그대로다.
- `tools/full_game_localization.py`, 전용 self-test,
  `tools/i18n_coverage_check.py`의 비표시 condition 강제 번역만 수리한다.
  신규 오버레이에 condition이 없어도 정상이며 제목/본문/변형 필수는 유지한다.
- 기존 3개 엔딩의 condition 번역 바이트는 보존하되 그9건의 수용 해시를
  `content/meta/full_game_localization.json`에서 역사 비표시 기록으로 분리한다.
  기존357은 348 번역 +9 비표시 메타였다. 검사나 번역 성공으로 부풀리지 않는다.
- `docs/I18N_INFRASTRUCTURE.md`에 이 지속 경계를 적고 전체 backlog 분모도
  실제 수집 결과와 정렬한다. KO/EN·runtime·화면·routing 변경0이다.
- 최초96 export는 버리지 않는다. 원문 본문이 아니라 수집 계약이 바뀌었으므로
  최종83 응답은 새로운 exact export로 검사·수용한다. 비표시 키의 추가/변조는
  번역 수용으로 통과하지 못하며 기존 비표시 기록도 source/target 해시를 보존한다.

같은 두 배치의 실물 검사 수리 2단위를 A19~20으로 기록한다. 계속 유효한
비표시 메타 분리는 현지화 정본 소유이며 root 목록과 증거 이동은 일회성이다.

### 같은 본문에서 확인한 중국어 검사 오탐

`tools/zh_translation_audit.py`와 내부 self-test만 추가 소유한다. 실제 관측된
`한 달에 한 번→每月一次`, `석 달→三個月/三个月`, `두 번째 전화→第二通電話/电话`,
`1금융/2금융→第一/第二金融圈`, `임씨→Im`, `초판 5만 부→5萬本/5万册`를
각각 정확한 원문·단위 문맥으로 판정한다. 책 부수를 5만원으로 세지 않는다.
숫자·빈도·순서·부수·원화 단위 변경과 원문 없는 Im의 음성 회귀를 추가한다.
오탐이 아닌 구체 사실 추가·오역은 번역에서 고치며 광역 검사 완화는 금지한다.
