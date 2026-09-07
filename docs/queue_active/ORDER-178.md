# Active Queue Spec: ORDER-178

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-178 [P0·전체 현지화] 직장·구직·자기계발의 선택을 옮긴다

**[~] 2026-09-08 Codex 착수 — 아래25 ID의 세 언어 text-only overlay,
원문 결속 검사·수용 기록·증거 문서만 소유한다.**
사용자의 전체 게임 번역 지시를 이어간다. 직전12,699번역(언어별4,233)·
메타9·batch29와 공개 working baseline·별도 배경 제품53493fe를 보존한다.

## 깊이 3문

1. 야근·거절·자격증·월급의 일상 선택이 폴백이면 인물의 생활선이 끊긴다.
2. 직업·승진·지원·연락·이체·생사·관계·도달성 조건은 변경0이다.
3. 남은 사건·UI·소비자와 경쟁하므로25단위 한 배치에 한정한다.

## 배치 A — 직장·구직·자기계발25 roots /194 leaf /7,759 KO자

전부 `content/events/life_events.json`의 다음25개다.

- `jobs_003`
- `jobs_014`
- `jobs_025`
- `jobs_036`
- `job_promotion_chance`
- `job_colleague_conflict`
- `job_interview_eve`
- `job_first_hoesik`
- `selfdev_certification`
- `selfdev_book`
- `first_job_rejection`
- `work_overtime_bomb`
- `salary_gap_shock`
- `work_chat_typo`
- `pay_day_ritual`
- `orthodox_promotion_mirror`
- `orthodox_overtime_fomo`
- `orthodox_award_ceremony`
- `orthodox_senior_farewell`
- `salary_not_enough`
- `survival_job_portal_night`
- `selfdev_english_class`
- `selfdev_coding_course`
- `selfdev_invest_seminar`
- `selfdev_language_app`

source aggregate
`a4d7d62c2177c885abf41b652c4845bc33ba66a1af43ca1a07d4d6495e564da1`.
제목25+본문25+72선택/결과144=194. known/memory/reader/foreshadow/분모 밖 name0.
전부 shipping·protected=false·builtin_overlay_static_only다. 대상3언어
target/accepted0·이전176/177과 교집합0을 선언 직전 확인한다.

명시 foreground/bridge/fallback allowlist0·직접followup 유입/유출0이며
runtime literal ID 참조를 찾지 못했다. 패키지 원문 보충이지 실제 노출 증가나
전체 비도달·플레이 GO 판정이 아니다. 기존 고용·tier·route·turn 조건은
EventManager가 읽으며 사무직 종류나 면접 예약을 보증하지 않는다.
범위 밖 flag callback13은 직접후속으로 합산하지 않는다. resume_polished는
JobSystem/MainGame도 소비하므로 게임플레이 키·수치·플래그를 변경하지 않는다.

## 파일 소유권

각 `content/events_<ja|zh-CN|zh-TW>/life_events.json`에 위25행만 추가한다.
직전177까지의29행과 life_events2 전체는 보존한다. 기존 값·행 상대순서·
source/target hash를 유지하며 새25행 내부의 KO 상대순서를 따른다.
기존 배열 전체 재정렬은 하지 않는다.
언어별 독립 작성자1명·KO 직접 저작과 다른 작성자/ROOT의 전수 L2.
영어 중역·간번 자동변환0, 문단·토큰·수량·인물과 사실 경계 보존.

ROOT는 full_game_localization.py·full_game_localization_self_test.py·
zh_translation_audit.py·audit_scope.json, content/meta/full_game_localization.json,
이 사양·CODEX_QUEUE·CODEX_QUEUE_L3_PENDING·CLAUDE·WORK_LOG·생성STATUS·
전체 현지화 backlog를 소유한다. 필요하면 완료175 WORK_LOG절만 기존9/7
현지화 history 앞으로 원문 이동하고 기존 기록·끝 개행을 보존한다.
실제 번역에서 재현한 수량/문맥 검사 오탐만 좁은 정상/변조 짝으로 수리한다.
KO/EN·runtime·save·routing·human_gates·life_events2·catalog/endings·공개·
폰트·배포 비소유다. 수용 뒤 같은 활성 이어보기로 옮기되 [~]·L3 OPEN 유지.

## 원문 사실·부채 경계

- jobs_003의22만원 준비비 지출 산문↔money +220000 효과를 임의 통일하지 않는다.
- jobs_014의 '네, 알겠습니다'를 세 글자→두 글자로 부르는 원문 불일치를
  번역자가 새 대사/글자수로 수리하지 않는다. 실제 답변2초와 기회3초를 보존한다.
- jobs_036 도입의 약속 유무 양립과 지하철에서 '막 나왔다'를 거짓말로 부르는
  원문을 재연출하지 않는다. 각 선택의 발신/미회신·약속 취소·읽음은 source대로다.
- 사직서는 저장하지 않은 초안이다. 지원서를 실제 제출한 다른 사건과 구분한다.
  실제 자격증 합격·승진·연봉 인상·30일 완주는 원문대로이며 새 성사를 만들지 않는다.
- 코딩 수업은 결제 뒤3강 또는5강까지만 들었다. 완강 목표를 완강으로 키우지 않는다.
  정보처리기사 자격을 일본/중국의 다른 시험으로 치환하지 않는다.
- 영어 학원의 직장 선배 언급은 min_turn만, salary_not_enough의 고시원비는
  주거 조건이 없다. 정적 source 확인점이지 실제 화면 결함 확정은 아니다.
- 재테크 강의는 토요일 오후 두 시간이지 오후2시가 아니다. 강의70%/30%·
  1,900/49,900원·연봉20%·코인+38%·200명/120개초과·48시간미만·
  자격증D-14/2주·3시간/20문항·30일연속을 전수 의미 대조한다.

## 검증

원문 manifest
`edf845a7164b8fedc9ec027be7a7edc381a3dcdf67ff58c2858d44a3237b64b8`.
최초source3 보존, 최종source/response/receipt3쌍과582문구 독립 KO 대조.
named full-game-localization-overlays를 --list로 확인한 뒤 실행하고
EN·diff·portable 전량 source/hash를 확인한다. 숫자나 감사는 실제 화면·
원어민·재미 GO 대체0이다. 전체 INCOMPLETE·full/main/product HOLD,
L3/원어민/화면 OPEN·출시 M01~M06 BUILD2026.08.31.1 사용자 GO 유지.

이 범위·배치·증거 절차는 일회성이다. 지속 규칙은 I18N_INFRASTRUCTURE와
언어별 용어집이 소유하며 새 서사·제품·출시 규칙을 만들지 않는다.

## 번역 결과 — L1/L2 수용·L3 OPEN

- 선언 `5928130c567ff5e584e9f0f9ecc8da3ca4e7f771` 뒤25 roots/194 leaf씩을
  KO에서 독립 저작하고 다른 작성자 또는 ROOT가 세 언어582개를 전수 대조했다.
  CN 주체 자기지시2곳, TW 반복 술자리/월급의 모호함2곳, JA 응답 기회3초1곳을
  정밀화하고 변경 leaf를 다시 대조했다. 나머지 문구·문단·토큰은 보존했다.
- 최초195행 source3개는 저작 전 target=null과 같은 원문194를 보존한다.
  최종 source/response check·import --accept3개 PASS·changed_files0.
  기존 private 증거를 덮지 않고 이미 작성한 target을 수용했다.
- 최종194-record aggregate JA
  `c3994f0c92d5f1ca9237e0f06c7ec330b4e0b6a716c3e4a8dd5390271f380973`,
  CN `57bfc8aad4aedf766efd8d3128a7c34d2748366f0c396113af085bc6ffe623dc`,
  TW `313b62f1d5d717250e4d682231300f43007794e1f2e375dcb2d3f8f23fdcf42b`.
  신규582·누적13,281(언어별4,427), 사건428종3,359/locale다.
  이전12,699/meta9·batch29·기존29행209문구의 값·raw row·상대순서를 보존했다.
  새25행은 KO 상대순서이며 life_events2 전체는 변경0이다.
- JA는 원문 전체가 '자격증 시험 D-14'인 경우만 시험까지14일로 결속했다.
  독립 정상3/변조24와 신설 메서드16사례 PASS. 기존 금액/시간 수리는 불변이다.
  ZH는 하루/매월·한두 잔·동료/구독·미완주·구직 회사/공고·읽음 초과 수와
  D-14 및 실제 서비스/언어 이름의 오탐만 원문 문맥에 결속했다.
  자체3203(이전3014+신규189)와 실제388문구 오류0을 확인했다.
  독립 검토가 발견한 한두 잔의 추가 상한과 학습/수강료의 잘못된 시·분·초
  주기가 뒤 정상 주기를 빌리는 세 유형을 수리했다. 정상/변조24사례 재확인
  PASS·제보 차단 잔여0이며 신설 문맥 밖으로 검사를 확장하지 않았다.
  전역 숫자·영어 허용이나 문장 의미의 완전 자동 판정은 아니다.
- 한국 자격 명칭은 [IPA의 한국 시험 명칭](https://www.ipa.go.jp/shiken/asia/mutual-recognition/korea.html)을
  확인해 情報処理技師를 유지했다. 일본 시험으로 바꾸지 않았다.
  [Incruit](https://www.incruit.com/), [JobKorea](https://www.jobkorea.co.kr/),
  [Saramin](https://oapi.saramin.co.kr/), [Python](https://www.python.org/?locale=en)은
  원문에 해당 이름이 있는 문구에서만 공식 철자를 허용한다.
- 완료175절954bytes만 기존 history24,062bytes 앞으로 원문 이동했다.
  새25,016bytes SHA `d05a48b99a960b17e2132e3ff7a18ce39ee54133b85126095f64dbbe93f4d206`,
  기존 내용·끝 LF2를 유지한다. 검수행은 같은 활성 이어보기로만 이동한다.
- 22만원 지출/효과, 글자수, 약속 유무/지하철, 고용·주거 조건의 원문 부채는
  따로 남겼다. 지원·승진·합격·답장·30일 완주는 실제 사실대로이며 미저장 초안과
  코딩3/5강을 완성으로 키우지 않는다. KO/EN·runtime·공개·fonts·save·
  human_gates 변경0, 원본 checkout 쓰기0.
  full/main/product HOLD·전체 INCOMPLETE·L3/원어민/화면 OPEN·출시 데모 GO 유지.

- portable checksum `4316d1a657e4e46418aaf0b44c3044379c9f16e40eec282299c62ad3fb673e04`.

## 최종 표적 검증

- named `full-game-localization-overlays`를 먼저 --list로 확인하고 실제12개
  차선을 실행했다. self168/ZH3203·audit ERROR0/WARNING0·공개100/121 패리티
  PASS다. 전체13,281수용의 source/target hash와 L1 오류0, EN·한글 누출0·diff PASS.
- 실제 stdout4,225bytes는 git-private `order178-final-checks.log`로 보존했다.
  SHA `c833285d1177a6dddee2c9c7e82e3aadeb575601b2c46b257cfbf66c1de3f14b`.
  중국어 full JP-first font route의 blocked는 기존 미완료 상태 그대로다.
  skeleton PASS는 전체판 글꼴·화면·원어민·출시 GO가 아니다.
