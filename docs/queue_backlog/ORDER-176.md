# Active Queue Spec: ORDER-176

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-176 [P0·전체 현지화] 월세·첫 월급·가족 기억을 옮긴다

**[~] 2026-09-07 Codex 착수 — 아래25 ID의 세 언어 text-only overlay,
원문 결속 검사·수용 기록·증거 문서만 소유한다.**
사용자의 전체 게임 번역 지시를 이어간다. 기존11,616/meta9·공개 working
baseline·배경 제품53493fe는 보존한다. 출시·도달성·게임 사실 수리는 하지 않는다.

## 깊이 3문

1. 월세와 첫 월급, 가족 기억이 영어 폴백이면 본편의 일상 경험이 끊긴다.
2. 선택·돈·생사·동의·장소·시간·관계 단계·게임 조건은 바꾸지 않는다.
3. 다른 생활 사건·UI·소비자와 경쟁하므로25단위 한 배치에 한정한다.

## 배치 A — 생활25 roots /185 leaf /10,023 KO자

`content/events/life_events.json`의5 roots/41 leaf/2,536 KO자:

- `final_last_winter`
- `class_reunion`
- `class_reunion_lie_exposed`
- `parents_bankbook`
- `survival_rent_due`

`content/events/life_events2.json`의20 roots/144 leaf/7,487 KO자:

- `sns_compare_00`
- `empty_fridge_00`
- `reunion_rsvp_00`
- `landlord_rent_up`
- `apartment_view_00`
- `health_checkup_00`
- `first_paycheck_00`
- `colleague_resign_00`
- `overtime_delivery_00`
- `random_kindness_00`
- `library_study_00`
- `book_discovery_00`
- `street_busker_00`
- `sunday_night_00`
- `friend_baby_news`
- `small_goal_00`
- `neighborhood_regen`
- `late_taxi_driver_00`
- `letter_to_self_00`
- `first_paycheck_00_father_passed`

source aggregate
`024de1b9c11cd9ca865052a027749219d4a3d91b734b5150f382e776cfcf3a92`.
표준185에는 final_last_winter의 description_memory_if_known11개가 포함된다.
reader/foreshadow/분모 밖 name0. 전부 shipping·protected=false·정적 내장 overlay
지원이며 세 locale target/accepted0을 저작 전에 확인한다. 전체 원문 분모는
17,374/사건12,421/파일213으로 유지한다. rainy_day_umbrella8문구는 후속으로 남긴다.

foreground는 class_reunion/final_last_winter/parents_bankbook3개, bridge·fallback는
survival_rent_due1개다. class_reunion.choice1의 직접 후속 lie_exposed도 포함한다.
나머지의 실제 비도달을 이 정적 분류만으로 주장하지 않는다.
첫 월급 alive→passed는 EventManager의 생사·passing_seen·passed stage에 따른
삽입/꺼냄/직접트리거 치환이며 별세 사본은 독립 무작위 사건이 아니다.
parents_bankbook의 requires_living_father도 같은 생사 계약을 읽는다.
간접 flag reader callback2개는 이번 직접 후속 범위 밖이다.

## 파일 소유권

각 `content/events_<ja|zh-CN|zh-TW>/life_events.json` 신규5행과
`life_events2.json` 신규20행, 총6파일만 저작한다.
언어별 독립 작성자1명, 한국어 직접 저작과 다른 작성자/ROOT의 전수 L2 대조다.
영어 중역·간번 자동변환0. 선택 배열·문단·토큰·숫자·사실 보존.

ROOT는 tools/full_game_localization.py·full_game_localization_self_test.py·
zh_translation_audit.py·audit_scope.json, content/meta/full_game_localization.json,
이 사양·CODEX_QUEUE·CODEX_QUEUE_L3_PENDING·CLAUDE·WORK_LOG·생성STATUS·
전체 현지화 backlog, I18N_INFRASTRUCTURE의 검사 실행 안내를 소유한다.
최근 기록 한도를 위해 완료172·173 WORK_LOG절을 기존9/7 현지화 history 앞으로
원문 이동할 수 있다. 기존 기록·활성 판정은 보존한다.
직접 부딪힌 원문 문맥 오탐만 정상/변조 짝과 독립 리뷰로 수리한다.
L1/L2 수용 뒤 이 오더의 행은 동일 큐 이어보기로 옮기되 [~]·L3 OPEN을 유지한다.

KO/EN·runtime·save·routing·human_gates·catalog/endings·공개·폰트·배포 비소유.
기존 target·11,616/meta9·oldbatch27을 보존한다.

## 원문 사실·부채 경계

- 월세 인상 원문15만원→협상10/5만원→최종7만원의 불일치, 매달 인상 산문과
  일회성 effects의 차이는 원문 부채다. 번역자가 금액이나 게임 결과를 통일하지 않는다.
- 집 보기 결과의 계약·서명·입주는 원문에 실제로 있다. 주거 상태 효과 부재와
  분리해 그대로 옮기며, 매수·소유로 키우거나 반대로 실제 계약을 지우지 않는다.
- 월세65만원은 월말 한 번의 차감 예약 확인이며 현재 잔액은 불변이다.
  지원서는 작성이지 제출/채용이 아니고, 재개발 정보 수집은 매수가 아니다.
- 동창회는 다음 달 셋째 주 토요일 초대에서 참석까지 원문이 압축한다.
  친구 출산의 하트 회신·한 달 뒤 만남/선물도 명시 원문이므로 임의 삭제하지 않는다.
- 첫 월급 alive는 부모와 셋, passed는 어머니와 둘·아버지는 기억만이다.
  '첫'의 조건 제한, 일부 고시원 고정 배경은 원문/상태 확인점이지 실제 화면 결함 판정이 아니다.
- 62선택 중 life_events2의52개는 도덕·관계·보상 괄호(정신력- 포함)를 원문이
  노출한다. 이를 임의 삭제하거나 새 설명을 덧붙이지 않고 source 노출 부채로 분리한다.
- 택시의 '오래만' 오타와 컵라면 결과의 배달 거리 구절은 원문 확인점이다.
  원문에 없는 이동·배달 완료·화자를 만들지 않는다.

## 검증과 증거

- source manifest `edf845a7164b8fedc9ec027be7a7edc381a3dcdf67ff58c2858d44a3237b64b8`.
- 최초 source3개를 저작 전에 보존하고 최종 source/response/receipt3쌍을 발급한다.
- 555문구 KO 직접 독립 전수 L2, 기존11,616/meta9·oldbatch27·공개·source 보존.
- full-game-localization-overlays 표적 차선·EN·diff와 portable 전량 source/hash 검사.
  자동·정적 증거는 L3/원어민/화면을 대신하지 않는다. 전체 INCOMPLETE·
  full/main/product HOLD·출시 M01~M06 BUILD2026.08.31.1 사용자 GO 유지.

이 배치·소유권·증거 절차는 일회성이다. 지속 규칙은 I18N_INFRASTRUCTURE와
언어별 용어집이 소유하며 새 서사·상품·출시 규칙을 만들지 않는다.

### 선언 준비 중 검사 선택 정정

일반 파일 선택기가19검사로 확장돼 무관한 legacy 인과 원장 self-test 실행을
시작했다. 해당 parent/child를 중단(exit143)했고 이 실행의 PASS 주장은0이다.
GODOT 환경값·PATH 발견은 모두 없음, 원본/제품 쓰기0이었다.
이후 검사는 먼저 --list로 확인하고 명시 full-game-localization-overlays 차선을 쓴다.
지속 실행 안내는 I18N_INFRASTRUCTURE의 기존 source-bound 도구 안내에 승격했다.

## 번역 결과 — L1/L2 수용·L3 OPEN

- 선언 `6ee6f19361eb799a62c72362cff8884ab72e243d` 뒤25 roots/185 leaf씩을
  KO에서 독립 저작했다. JA/TW/CN을 다른 작성자 또는 ROOT가 각각185개 전수 대조했다.
  JA 중개사의 되물음 화자1곳을 고치고, 떠나는 진행상과 TW 과제의 범위·
  아버지 기대의 지속 표현을 정밀화했다. 필수 L2 잔여0이며 원어민 판정은 아니다.
- 최초186행 source3개는 저작 전 target=null과 같은 원문185를 보존한다.
  최종 source/response check·import --accept3개 PASS·changed_files0이다.
  이미 작성한 같은 target을 수용했으며 기존 private 증거를 덮지 않았다.
- 최종185-record aggregate JA
  `fdfcbd1408acc7261224fe3e0571b9f7fde0dab0354291a9ba8a54b81175312e`,
  CN `3edb320820179e15bdf1c9702bf717e6bbe8612a7343a515ac9a25edcd52a7ac`,
  TW `f25cc402db23622a4caf9518b6cdb3c03afee1878f3b1c98463a7ad46132d394`.
  portable 신규555·누적12,171(언어별4,057), 사건378종2,989/locale다.
  기존11,616/meta9·oldbatch27은 같은 값으로 유지하고 batch1만 추가했다.
- JA4천 원의 통화/값/소유자 순서, 다음 달 셋째 주 토요일과1인 요금의
  결속을 추가했다. 독립 검토의 다다음 달(再来月) substring 누출을 고쳐 정상4/변조22를
  확인했다. ZH 생활 수량10유형·원화一千·브랜드 조사 문맥을 수리했다.
  신규 수용의 명사·단위 경계 및 한정 기간을 독립 반례로 검증했다.
  검사상 허용을 위해 번역을 바꾸지 않았으며 모든 Unicode·분수·수사나
  문장 의미를 자동 판정한다는 주장은 하지 않는다. 해당 의미 대조는 L2에 남는다.
- 완료172·173절3,010bytes를 기존 history19,937bytes 앞으로 원문 이동했다.
  새22,947bytes SHA `75618386ce5fc0929b3e5f108e74dceca1b526e17bb60b94543de167ae515ea1`,
  기존 내용과 끝 LF2를 보존했다. 현재 행은 같은 활성 이어보기로만 이동한다.
- 월세 금액 원문 불일치·결과/효과 차이·실제 계약·압축된 만남·괄호52를
  원문 부채와 구분했다. KO/EN·runtime·공개·폰트·저장·human_gates 변경0,
  source manifest 불변·원본 checkout 쓰기0다. full/main/product HOLD·
  전체 INCOMPLETE·L3/원어민/화면 OPEN·출시 데모 GO를 유지한다.

- portable checksum `4db90842be4d44e69bfa049018cf0cd4f02254be33869de35367983128a949be`.
- 최종 표적12개 차선·EN·diff PASS, portable12,171 source/hash/L1 오류0.
  self165·ZH2315를 포함한 실제 차선 stdout은 git-private order176-final-checks.log,
  4,225bytes SHA `92eb5e46444b6b9e2eca2fdb80a4a1df67e8100436d63831fc0fc54905a61830`다.
