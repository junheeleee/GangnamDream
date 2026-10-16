# Active Queue Spec: ORDER-699

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

## [~] 2026-10-16 착수 — 승인된 텍스트 검토 R1 적용

사용자 직접 지시: PR #35의 [R1 문안](../queue_backlog/TEXT_REVIEW_R1_2026-10-16.md)을
main에 병합하고 다섯 장면의 KO/EN에 적용한다. PR head
`cca02ca90665310e503ba84f008482d5d933dcb3`는 문서 한 파일만 추가하며,
로컬 merge `98fde7f`를 main에 push했다. 연결 API의 권한403은 보존하며 Git 병합으로 완료했다.
새 월 플레이가 아닌 화면 없는 사용자 승인 작업이다. C2의 수첩 제목 연속성과
잘못된 사실을 고치고, 사용자가 지정한 정점 산문을 적용한다. R2나 전수 문체 개선은 열지 않는다.

### 깊이 3문

1. 지우면 무엇이 깨지는가: 세 수첩 변형에서 본문에 없던 제목을 결과가 읽으며,
   병원 마감은 게임 선택 제한을 세계의 절차로 잘못 설명한다.
2. 24주 뒤 상태가 바뀌는가: 아니다. 이번 작업은 이미 승인된 행동·사실의 전달을
   고친다. flags/effects/conditions/id, 선택 순서와 후속·엔딩을 바꾸지 않는다.
3. 무엇과 경쟁하는가: 기존 선택의 밥/사과/거리, 서명 세 뜻, 방문/통화/미룸,
   납부/자기 진료/병동 조정, 장부/전화/잠의 비용을 보존한다. 새 선택은 만들지 않는다.

### 다섯 단위와 범위

- `arc_final_week`: base·서명3변형, 선택0/2와 결과3개. 나머지 `final_*` 등 R2 문안은 불변.
- `arc_final_countdown`: base·moral2변형과 결과3개. 변형별 세 뜻·추가 문장은 유지.
- `arc_y4_father_crisis_contact`: 본문·결과3개·기억11키. 실제 생산 선택과 맞지 않는
  직업/기간/화면 내 로그 위치 등은 같은 행동·숫자·시각을 지키는 최소 문안으로 조정한다.
- `arc_y4_bill_night`와 `_unattached`: 본문·결과3개·기억5키씩. `_jiyeon`은 비소유.
- `arc_year1_close`와 `_father_passed`: R1의 base·지정6변형 중5개·선택0·결과0,
  별세 결과1. 나머지 기억·선택/결과는 불변. 기존 계층·자산·연출·오디오는 유지한다.

### 정확한 파일 소유권

- root: `content/events/arc_drama.json`, `content/events/arc_pre_ending.json`,
  `content/events/arc_chapter_themes.json`, `content/events/arc_year_close.json`의 위7개 사건 텍스트만.
- 영어 저자: 대응 `content/events_en/arc_drama.json`, `content/events_en/arc_pre_ending.json`,
  `content/events_en/arc_chapter_themes.json`, `content/events_en/arc_year_close.json`의 대응 텍스트만.
- root: `docs/SCENE_TIER.md` 공통 산문 계약에 R1 §0 규칙 한 줄.
- root: `content/meta/full_game_localization.json`의 바뀐 KO leaf 수용 영수증만 철회하고
  기존 `full_game_localization.digest`로 `accepted_sha256` 정합. CJK 번역/기존 수용 확대0.
- 필요한 경우 root: `content/meta/release_content_inventory.json`의 이번 변경에 영향받는
  현재 본편 source 지문, `docs/CONTENT_RATING_INVENTORY.md`의 대응 생성 셀만. 등급 사실·강도·
  후보 집합·frozen demo·검사 기준은 불변이며 원문 변경을 감추는 예외를 추가하지 않는다.
- root: 이 사양·`docs/CODEX_QUEUE.md`·순번만 `docs/CODEX_QUEUE_L3_PENDING.md`·
  `CLAUDE.md`·`docs/WORK_LOG.md`. 검수 원문/보고는 `.git/order699-text-r1-20261016/`.

### 검증·판정

기존 검사 영향 목록을 먼저 확인한다. KO/EN 변경 leaf 전수 대조, gameplay/비소유 사건
parsed·원문 역산 불변, 토큰/금액/시각·moral 문장·별세 경계·CJK 바이트 보존을 확인한다.
기존 EN coverage/Hangul·정합·영향 감사와 문서 검사만 실행한다. 새 checker·전체audit·
240주·엔진·실제 앱 실행0. R1 패턴은 수동 관찰이지 정규식0 달성용 문장 삭제가 아니다.
독립 검수자는 저자와 분리해 7개 사건의 변경 leaf 전수와 실제 조건/생산 선택을 읽고
KO/EN 정합·보존 범위만 판정한다. root가 원 보고와 실제 산출물을 직접 읽는다.

사용자 테스트16.2/개발 검수16.3 앱·저장·설정·프로세스·`project.godot`·공개 데모·
과거 인간 원장·제품 검사는 비소유다. 화면·저장 왕복·사람/원어민·출시 GO를 발급하지 않는다.
제품 원문이 달라졌으므로 이후 새 검수 패키지는 새 후보를 결속해야 한다. 기존 앱을 몰래 바꾸지 않는다.
승격 예정: `SCENE_TIER.md` 공통 산문 계약 §0 작성 규칙 한 줄. 나머지는 일회성이다.
