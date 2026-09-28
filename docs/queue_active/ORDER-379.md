# Active Queue Spec: ORDER-379

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-379 [P0·현지화] 배달 목적지 일본어와 직업 선택창 중국어를 채운다

**[~] 2026-09-28 Codex 착수 — 아래 파일만 소유한다.** 부모 ORDER-157.
사용자의 브리핑 뒤 즉시 진행·검수 효율화 위임. 기준
`82a9c23b640cea54342bc3b4cd51b977b0d949f4`.

## 깊이 3문·배치 경계
1. 지우면: 일본어 배달 후보와 중국어 직업 지원 조건·준비 안내가 영어로 남는다.
2. 24주 차이: 선택·경제·진행은 바꾸지 않는다. 같은 판단 정보의 언어 접근성을 고친다.
3. 경쟁: 새 시스템 대신 이미 도달하는 두 소비자의 확인된 사전 누락을 닫는다.
독립된 소비자 2묶음, JA 12값과 CN/TW 각40값, 총92값이다. 원장도 두 batch로
분리한다. 임의로 단위 수를 늘리지 않는다. context ID는 기존 official/append
경로의 키 정체성을 그대로 사용하며 verifier·collector 변경은 본 범위 밖이다.

## 정확한 소유권
- root: `locale/ui_ja.json`에 ArubaGame `DEL_ORDERS_DATA` 239–244행의
  목적지 name 6개와 info 6개만 추가. 기존 CN/TW 해당 값은 비소유.
- compat357: MainGame `_open_jobs`부터 `_handle_job_modal_input` 직전의
  한국어 직접 CN/TW 초안만 git-private `order379-zh-drafts.json`에 저작.
  현재 누락 legacy39와 `ui.job.entry_tier`1만. root가 공식 검증·수용 후
  `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json` 각각40행을 추가한다.
- root 단독: `content/meta/full_game_localization.json` 공식 receipt·batch2 추가,
  export/response/import/검증용 git-private order379 파일, 이 사양/완료 archive,
  CODEX_QUEUE 두 인덱스, CLAUDE 현재행, WORK_LOG, 생성 STATUS,
  agent_review_decisions 및 agent_reviews/ORDER-379.json.
- screen_path_probe: git-private order379 화면 helper·runner만. root만 엔진 실행.
- r3_route_probe: 독립 한국어 대조92값·증거·PNG 검수와 git-private 보고만.
공유 파일 동시 저작 금지. 기존 값/순서/원형바이트·KO/EN·런타임·catalog·
JobSystem 잠금 사유·공개 demo·실사용자 저장·인간 원장·출시 언어는 비소유.

## 구현·표적 검증
- 한국어에서 JA/SC/TC 직접 작성, 독립 전수 의미 검수. 공식 export/check/import,
  source/target/receipt identity 및 exact raw append 검증. UI3+원장은 같은 commit.
- 기존 current receipt guard, 언어별 UI 감사, 필요한 현행 consumer 정상 경로만
  최대3개 병렬 실행. 변경 없는 self/역사 corpus/전체 감사/240주를 반복하지 않는다.
  영향 선택·context/queue/등록/diff 검사를 포함하되 조회를 검사 수로 부풀리지 않는다.
- 실제 MainGame의 배달 JA clear/rain 2화면과 직업 CN/TW 준비/미준비·현재직업·
  조건부족·4티어를 최소 준비상태로 묶어 관측한다. 최종 사전 hit·실제 표시·
  지역 글꼴/글리프·1280×800 경계와 PNG를 확인한다. 표적 외 누출은 잔여로 기록.
- 검증은 proven pre-autoload 격리 bootstrap, clean source/helper/실사용자 파일
  전후불변을 요구한다. 준비상태를 자연 AP 도달·채용·정산·새입력·전체플레이·
  원어민·물리패드 관찰로 바꾸지 않는다. 문제 발견 시 증거를 보존한다.
- final source 결속 독립 work_unit GO 뒤 main에 정리한다. 본편/새 package HOLD,
  공개 GO1·인간 OPEN45와 과거 판정을 보존한다.

## 규범 판정
이 모집단·파일·표적실행 계획은 일회성이다. 기존 I18N append/언어/관측 규칙을
재사용하며 새 정본 규칙은 만들지 않는다.
