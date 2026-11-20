# Active Queue Spec: ORDER-161

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-161 [P0·전체 현지화] catalog 7섹션의 설명·이름·뉴스를 세 언어로 옮긴다

**[~] 2026-09-07 Codex 착수 선언.** 사용자 전체판 번역 지시를 `74be170`에서
잇는다. KO 제품 `53493fe`와 앞선984 수용 번역·역사 메타9·공개 데모를 보존한다.
JA·zh-CN·zh-TW를 한국어에서 각각 직접 작성하며 간번 변환·영어 중역은 없다.

## 깊이 3문

1. **없으면 무엇이 깨지는가?** 직업·선물·기억·자산·뉴스가 영어로 돌아가므로
   이야기 언어와 반복 표시 언어가 갈라진다. 제목뿐 아니라 본문·태그·주제를 채운다.
2. **선택을 바꾸는가?** 번역은 선택·조건·수치·회수 시점을 바꾸지 않는다.
   원문에 있는 금액·기간·이미 발생한 행동만 옮기고 새 사실이나 힌트를 만들지 않는다.
3. **무엇과 경쟁하는가?** 전체 사건·UI와 같은 현지화 예산을 쓴다. 834 leaf의
   짧은 반복 표면을 먼저 닫되 이것을 전체판 번역·런타임·원어민 GO로 세지 않는다.

## 두 배치 — 독립 표시 묶음

- A 15단위: assets 원문 순서6행씩3단위; jobs5행씩3단위;
  items5/5/4행3단위; achievements5행씩3단위; clues 앞2행/마지막1행2단위;
  thoughts1단위. 66행·202 leaf·3,706 KO자다.
- B 20단위: news_001~news_076을4행씩19단위, news_077~news_079를 마지막
  1단위로 읽는다. 79행·632 leaf·6,242 KO자다. 모든 headline과 topics를
  조합해 읽고 `{topic}`·수치·고유명·배열 순서/개수를 보존한다.

짧은 catalog는 한 행보다 같은 표면의 독립 묶음이 판정 단위다. 이는 이 작업의
측정 기반 분할이며 이야기 장면 수·선택 수를 늘리는 단위가 아니다.
공개 `jobs.job_01.name`은 변경0이다. 기존 JA 직업명15개도 먼저 보존·대조하며
기작성 존재만으로 새 번역이라 세지 않는다. A202/B632는 원문/검토 분모다.

**독립 원문 대조 뒤 보존선 정밀화 선언:** 기존 JA `jobs.job_13.name`의
`動画クリエイター`에는 KO의 YouTube가 빠져 있다. 이 같은 catalog text 범위
안의 1leaf를 `YouTubeクリエイター`로 수리한다. 나머지 기존14명·공개 job_01은
불변이다. 신규 시스템/원문/범위를 더하는 것이 아니라 대조에서 확인한 누락
수리이며, 선언을 먼저 커밋한 뒤 반영하고 독립 재대조한다.

## 정확한 파일 소유권

- `locale/catalog_ja.json`, `locale/catalog_zh-CN.json`, `locale/catalog_zh-TW.json`:
  assets/jobs/items/achievements/clues/thoughts/news의 기존 text-only 계약 전부.
  언어별 파일은 각각 한 작성자가 소유하며 교차 검토자는 읽기 전용이다.
- `content/meta/full_game_localization.json`: 실제 원문 대조·기계 검증한 leaf의
  해시와 배치 기록만. 초기 git-private source export는 덮지 않는다.
- 필요 시 `tools/zh_translation_audit.py`, `tools/full_game_localization.py`,
  `tools/full_game_localization_self_test.py`, `tools/ja_translation_pipeline.py`:
  이 catalog 원문에서 관찰한 숫자/토큰/지역문자 오탐만 source-bound 수리하고
  정상·값/단위/다른 문맥 변조를 쌍으로 검사한다. 금액 blanket 완화는 금지다.
- 이 사양·CODEX_QUEUE·CLAUDE·WORK_LOG·생성 STATUS·전체 현지화 backlog와
  `tools/audit_scope.json`의 해당 catalog/문서/검사 등록. 예산 초과 시 기존
  WORK_LOG 원문을 `docs/history/WORK_LOG_2026-09-07_localization.md`로 이동해
  링크하며 내용을 압축하거나 삭제하지 않는다.

KO/EN·runtime·gameplay·저장·엔딩 라우팅·폰트·공개 언어·human_gates 비소유.
원문 자체의 나이/글자수/뉴스 사실 문제는 번역에서 몰래 고치지 않고 별도 기록한다.

## 증거와 판정

L1: 834 leaf/locale 범위·숫자/원화/토큰·배열·gameplay 키0·기존 leaf 보존·
source/target receipt·등록 `full-game-localization-overlays` 차선·EN·diff check.
L2: 다른 작성자가 KO에서 전수 교차 대조, headline7주제 조합과 선물/단서의
인물·시간·수량·표시 소비자 확인. L3: 원어민·사용자 표본·실제 화면 OPEN.

DataRegistry의 catalog overlay와 MainGame의 tags/news 표시를 읽기 전용으로
확인한다. 자동 게이트는 계약 증거이지 재미·깊이·문체의 증거가 아니다.
지속 규범은 I18N_INFRASTRUCTURE·세 용어집이 소유하며 위 분할/파일은 일회성이다.

## 실행 증거 — 2026-09-07

- 선언 `f3070ea`, 기존 JA 누락 수리 선언 `27aa518` 뒤 구현했다. A202/B632를
  세 언어 각각 직접 작성·교차 검토했다. 신규2,485(819/833/833), 기존 JA
  `job_13` 수리1, 기존 유지16을 합친2,502문구다. 기존 다른14직업명과 공개
  job_01은 그대로이며 기존984 수용 기록·비표시 메타9도 불변이다.
- 초기 git-private source export는 보존했다. 원문 대조 수리 후 같은 KO
  manifest에서 `order161-final-A/B`를 재export하고 여섯 check/import를 통과했다.
  portable 원장은 총3,486=언어별(234엔딩+94사건+834catalog)이다. 기계 수용이
  원어민·실플레이 승인이 아니라는 경계를 유지한다.
- 최종 catalog SHA-256: JA `a3da3deb0f4b050f84c9bc47639930a87cb181cc5959ae25ece555b45be0cb8c`,
  CN `8e0b4c94b0fe79baf6999cc0e8f9bdb7847f59394f15add49cf23051ff2cb7cb`,
  TW `f69f67198903e190ae6ccabae181484b47c8a5e757fd7d9107370b88742b1709`.
- 다른 작성자가 KO에서 전체2,502 leaf와 언어별553 headline-topic 조합을
  대조했다. 불명확한 이익/수익성, 정규장 외/장후, 한국 법인/자회사, 두 번째
  창업/창업가, 보조금/대출 범위를 수리하고 다시 대조했다. L2 blocker0이며
  인간 언어·플레이 gate를 닫은 것은 아니다.
- 실제 새 숫자 문맥만 source-bound 수리: 억대/수백억/수조원, 첫1억, 나이대,
  구독자·인원·횟수, `2030` 연령층, 한자 수사와 brand 전체 경계. ZH935,
  full-game self-test77 통과. 독립106(정상21허용+변조85거부)도 통과했고
  실제 catalog2,502오류0이다. 양 지역 OpenCC 분류 데이터는 변경0이다.
- DataRegistry411/432~473/1197~1224와 scenes/MainGame.gd19639/23393/9701의
  표시 소비자를 읽었다. overlay7섹션·자산 tags·news 조합은 정적 계약이며,
  폰트·잘림·정상 속도·native 증거가 아니다. KO 원문 결함5건은 backlog로 분리했다.
- L3·전체판 INCOMPLETE/HOLD는 그대로다. 다음 배치는 누락 사건과 UI/소비자다.
  이 사양의 분할·해시·receipt 절차는 일회성이고 지속 규범은 기존 현지화 정본이다.
- 최종 `full-game-localization-overlays`12검사·EN·diff check 통과. 전체 source
  inventory에서 세 언어 catalog834/834 present/machine_valid/receipted가 일치했다.
  기존 공개/legacy 본문·UI의 넓은 숫자 감사 잔여는 이번 catalog 결과에 합산하지
  않는다. 실제 CLI stdout은 worktree git-private
  `full-game-localization/order161-final-checks.log`에 보존했다.
