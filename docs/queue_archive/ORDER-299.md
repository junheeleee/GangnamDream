# ORDER-299 — 다이사이 선택·안내 중국어

[x] 2026-09-27. 한국어19키·CN/TW38값 전수 독립 작업 한정 GO, 필수 결함0.

- source `96125930d9097a967c6c6bf3fa83d1f6c192b51a`, tree `309dadbcad69204e949b68bbd4d3fca1d099f84a`. [독립 보고](../agent_reviews/ORDER-299.json) SHA `cbd45cbea05ff7542c43a989edc0029baa47128d124b9137acf73c5b2ea29005`.
- 두 지역에서 한국어를 직접 번역했다. 숫자/페어·합계·간편 모드, 싱글/페어/합계 버튼, 베팅 단위·기본 복귀, 선택 후 다시 눌러 굴리기, 정보·주사위 합계·패드 안내19키다. 특정 눈은单点/單點, 합계는总点数/總點數로 구별하며 placeholder순서·개행·BBCode·순배당1~3:1/8:1을 유지했다.
- 정적19 literal reader(Table16/Model3)·추가 공유0. 모델값은 feedback/cursor/info/canvas/log에 이어진다. history의 label 저장은 실제 표시로 세지 않는다. BIG/SMALL 등 영어 인자·직접영어·다른 부모문장은 이 수용 밖이다.
- 공식 사전 export/check·적용후 target-hash export/check/import 각19 PASS, fixed named12 전부PASS. 공식40277/b135/meta9(신규38), 각1054키. 기존40239핀/134batch·사전1035값/지역·JA·원문·runtime·project·공개·인간은 원형 보존했다. 역치환 바이트·전체 기존 수용 SHA 검증을 포함한다.
- 도달: FULL_LOCALIZATION_BATCH_VALID locale=zh-CN/zh-TW leaves=19. 생산자↔독자: locale/ui_zh-*.json ↔ DaiSaiTable16/DaiSai3. 상태:19키씩 부재→수용. 제거손실: 선택·안내 영어 폴백. 서사/계층: 기존 카지노 UI, 장면·게임규칙 추가0. 닫음: 정확38값의 사전/소스/영수증 범위만.
- 다음은 새 문구의 실제 화면·표적 입력 검수이며 별도 선언한다. 기존297/298 화면과 금융26화면·188raw·전체감사를 반복하지 않았다. 새 엔진실행·화면·입력0이며 이전화면으로 새 번역을 인증하지 않는다.
- UI3028 reference 대비각1974부재는 전체 live UI 분모가 아니다. 보류72·공개GO1·인간OPEN45·본편HOLD 유지. 원어민·인간·물리패드·정상진입·무작위play·정산·오디오·다른해상도·패키지 미관측이다.
- 규범 승격 없음: I18N/WORK_UNIT 기존 정본을 적용하며19키·파일·배치·검증은 일회성이다. 자동 PASS는 계약 증거이지 재미·깊이·문체·인간 판단이 아니다.

## 최초 선언 원문

# Active Queue Spec: ORDER-299

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-299 [P0·현지화] 다이사이 선택·안내 19키를 간체·번체로 직접 번역한다

**[~] 2026-09-27 Codex 착수 — 아래 파일만 소유한다.** 부모 ORDER-157,
시작 clean `93ae96865c38229735604e8c8181236dcde9c13f`. 사용자 계속 지시와
앞선297/298 완료 뒤 남은 영어 선택·안내를 줄인다. 실제 화면/입력은 후속 범위다.

## 깊이 3문

1. 제거 손실: 이미 지역화된 선택 이름 주위의 영어 안내·싱글/페어/합계 버튼이 남는다.
2. 장기 상태: 번역 사전과 수용 원장만 바뀐다. 금전·AP·확률·배당·저장·입력은 불변이다.
3. 경쟁 대상: 숫자/페어·합계·간편 모드, 선택과 다시 눌러 굴리기, 기본 베팅 복귀를 구별한다.

## 한 배치 19단위 — 정확한 한국어 키

각 행은 원문→CN/TW 두 값의 독립 직접 저작·검수 단위다. `\n`은 실제 줄바꿈이다.

| 단위 | 한국어 원문 | 현재 literal reader |
|---:|---|---|
| 1 | `%s 베팅 모드` | scenes/DaiSaiTable.gd:214 |
| 2 | `%s 선택. %s를 한 번 더 누르면 굴립니다.` | scenes/DaiSaiTable.gd:260 |
| 3 | `기본 베팅으로 되돌렸습니다.` | scenes/DaiSaiTable.gd:277 |
| 4 | `숫자/페어` | scenes/DaiSaiTable.gd:329 |
| 5 | `합계` | scenes/DaiSaiTable.gd:331 |
| 6 | `간편` | scenes/DaiSaiTable.gd:332 |
| 7 | `홀수\n1:1` | scenes/DaiSaiTable.gd:627 |
| 8 | `짝수\n1:1` | scenes/DaiSaiTable.gd:628 |
| 9 | `%d 싱글\n1~3:1` | scenes/DaiSaiTable.gd:636 |
| 10 | `%d%d 페어\n8:1` | scenes/DaiSaiTable.gd:643 |
| 11 | `합계 %d\n%d:1` | scenes/DaiSaiTable.gd:660 |
| 12 | `베팅 단위` | scenes/DaiSaiTable.gd:668 |
| 13 | `기본 베팅` | scenes/DaiSaiTable.gd:692 |
| 14 | `선택: %s   \|   베팅액: %s   \|   결과: %s` | scenes/DaiSaiTable.gd:794 |
| 15 | `[b]%s[/b] · %s  [%s/%s] 모드  [%s] 선택/굴림  [%s/%s] 칩 −/+  [%s] 칩 +  [%s] 규칙  [%s] 뒤로` | scenes/DaiSaiTable.gd:906 |
| 16 | `%d-%d-%d / 합계 %d` | scenes/DaiSaiTable.gd:1052 |
| 17 | `%d 싱글` | systems/DaiSai.gd:98 |
| 18 | `%d 페어` | systems/DaiSai.gd:100 |
| 19 | `합계 %d` | systems/DaiSai.gd:106 |

전체 runtime collector와 repository literal 검색에서19키/19호출(Table16/Model3),
추가 공유 reader0을 확인했다. 모델값은 선택 feedback·cursor·info·canvas·로그에
이어지지만 history 데이터의 label 보관을 실제 화면 노출로 세지 않는다.
원문·숫자/배당·placeholder 종류/순서·BBCode·줄바꿈을 유지하고 영어 중역·간번 변환은 금지한다.

## 파일 소유권·분업

- root 제품: `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json`의 위19키씩만 추가,
  `content/meta/full_game_localization.json` accepted38값·batch1행 append-only.
- CN 저자: 새 git-private `order299-zh-CN-draft.json`만. 한국어→간체 직접 작성.
- TW 저자: 새 git-private `order299-zh-TW-draft.json`만. 한국어→번체 직접 작성.
- 독립 검수자: 저작 비참여, 새 git-private `order299-*review*.json`만.
- root 기록: 이 사양→`docs/queue_archive/ORDER-299.md`, `docs/CODEX_QUEUE.md`,
  `docs/CODEX_QUEUE_L3_PENDING.md` 순번만, `docs/WORK_LOG.md`, 생성 `docs/STATUS.md`,
  `CLAUDE.md` 현재 상태 한 행, `docs/agent_review_decisions.json` 새 work_unit1행,
  `docs/agent_reviews/ORDER-299.json` 독립보고 정확 복사.
- root 보조: 새 git-private `order299-*` source/export/response/receipt/check/closure.
  실패 출력·초안·기존 보고를 덮지 않는다. 기존 도구는 읽고 재사용하며 tracked 도구 변경0.

## 검증·수용

기존 full_game_localization의 정확19 leaf export→check→원문 대조→수용을 쓴다.
기존공식40239/b134/meta9·보류72, CN/TW각1035키 기준. 기대 수용40277/b135,
CN/TW각1054키·JA3028 대비각1974부재(전체 live UI 분모 아님).
기존사전/40239수용행/134batch의 역치환 바이트 보존, 수용 전체 source/target SHA와
raw JSON중복·누락·placeholder·지역문자·숫자·토큰·줄바꿈을 확인한다.
독립 검수자는38값과19 literal 문맥 전수, 실제 생성된 hint/info/feedback의
부모·인자 의미를 읽으며 좁은 사전/문맥 GO만 낸다. 실제 렌더 GO로 확대하지 않는다.
`audit_select --lane news-panel-locale-only --list`의 기존 고정12 Python검사 목록을
재사용하되 이 오더의 정확파일범위를 별도 검사한다. 명칭은 이전 UI 차선일 뿐
그 오더의 파일 소유/판정을 상속하지 않는다. context·queue·원장·dashboard·diff 마감.

## 비소유·남은 위험

KO/EN/JA·게임코드·project.godot·공개 M01~M06·인간 원장·기존 판정은 보존한다.
직접 영어 BIG/SMALL/ANY TRIPLE/ROLL/SELECTED BET/PAYS/SHAKER와 다른 부모문장,
카지노 허브 공유키, 실제 화면/입력·정상진입·정산·오디오·다른 해상도는 별도다.
원어민·인간 플레이·물리패드 미관측, 공개GO1·인간OPEN45·전체판HOLD 유지.
자동 PASS는 계약 증거이지 재미·깊이·문체·인간 판단을 대신하지 않는다.

**규범 판정:**19키·배치·파일·검증은 일회성. 계속 유효한 I18N/WORK_UNIT 규칙은 기존 정본 적용.
