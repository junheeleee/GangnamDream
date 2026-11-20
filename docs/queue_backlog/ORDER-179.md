# Active Queue Spec: ORDER-179

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-179 [P0·전체 현지화] 생활비·소비·주거 불안을 옮긴다

**[~] 2026-09-08 Codex 착수 — 아래25 ID의 세 언어 text-only overlay,
원문 결속 검사·수용 기록·증거 문서만 소유한다.**
직전13,281번역(언어별4,427)·메타9·batch30과 공개 working baseline·
별도 배경 제품53493fe를 착수 직전 재확인해 보존한다. 사용자의 전체 게임 번역 지시를 이어간다.

## 깊이 3문

1. 월세·소비·주거 불안이 폴백이면 돈과 사람의 일상 선택이 다른 언어에서 끊긴다.
2. 돈·당첨·주거·계약·답장·동석·도달성 조건은 변경0이다.
3. 남은 사건·UI·소비자와 경쟁하므로25단위 한 배치에 한정한다.

## 배치 A — 생활비·소비25 roots /186 leaf /7,110 KO자

전부 `content/events/life_events.json`의 다음25개다.

- `neighborhood_cafe_regular`
- `first_month_rent_pressure`
- `social_life_004`
- `disasters_009`
- `finance_011`
- `disasters_020`
- `comedy_032`
- `finance_033`
- `social_life_037`
- `hangang_chicken`
- `selfdev_gym_register`
- `social_comparison_peer`
- `social_alone_lunch`
- `finance_negative_balance`
- `small_unexpected_win`
- `jeonse_scam_warning`
- `floor_noise_war`
- `frugal_month_challenge`
- `lottery_last_change`
- `lottery_result`
- `comedy_convenience_1plus1`
- `comedy_subway_seat`
- `comedy_cafe_seat_war`
- `friend_housewarming`
- `algorithm_knows_me`

source aggregate
`1960c802928cd612a4ff4d2f6b588386e6ede9043250e5d2513447c05250d9b0`.
제목25+본문25+68선택/결과136=186. known/memory/reader/foreshadow0.
전부 shipping·protected=false·builtin_overlay_static_only다. 각 언어
대상 target/accepted0과 직전17825종 교집합0을 선언 직전 확인한다.
분모 밖 표시명1은 neighborhood_cafe_regular의 '카페 단골 친구'다.

명시 foreground/bridge/fallback0, 대상 literal 직접 호출은 발견하지 못했다.
직접후속1 lottery_last_change.choice0→lottery_result는 같은 배치다.
lottery_result는 hidden/weight0이나 shipping 직접후속이며 author_only가 아니다.
밖 flag 독자 checked_registry→callback_checked_registry_vindicated,
lotto_5th_prize→callback_lotto_5th_prize_echo는 이번 번역에 추가하지 않는다.
friend_housewarming은 source/gosiwon tag로 주거가 제한된다. 비교 사건의
job tag는 commute의 직업 강제와 다르다. ImageRegistry의 housewarming ID는
배경 선택이지 사건 호출이 아니다. 정적 확인은 전체 비도달·플레이 GO가 아니다.

## 파일 소유권

각 `content/events_<ja|zh-CN|zh-TW>/life_events.json`에 위25행만 추가한다.
기존 값·행 상대순서·source/target hash를 유지하고 새행 내부의 KO
상대순서를 따른다. 기존 배열 전체 재정렬0, gameplay key 복사0.
KO 직접 저작과 다른 작성자/ROOT의 전수 L2. 영어 중역·간번 자동변환0.
문단·토큰·수량·인물/사실 경계를 보존한다.

ROOT는 full_game_localization.py·full_game_localization_self_test.py·
zh_translation_audit.py·audit_scope.json, content/meta/full_game_localization.json,
이 사양·CODEX_QUEUE·CODEX_QUEUE_L3_PENDING·CLAUDE·WORK_LOG·생성STATUS·
전체 현지화 backlog를 소유한다. 필요하면 완료176 WORK_LOG절만 기존9/7
현지화 history 앞으로 원문 이동하고 기존 내용·끝 개행도 보존한다.
실제 번역에서 재현한 검사 오탐만 좁은 문맥과 정상/변조 짝으로 수리한다.
KO/EN·runtime·save·routing·human_gates·life_events2·catalog/endings·공개·
폰트·배포 비소유다. 수용 후 같은 활성 이어보기로 옮기되 [~]·L3 OPEN 유지.

## 원문 사실·부채 경계

- finance_011의45만원 지출↔money +450000, finance_033의비교표 저장·공부↔
  money +370000 효과는 번역에서 임의 정정하지 않는다.
- 전세 두 사건은 계약/보증금을 전제하나 현재 jeonse 주거 guard가 없다.
  고정 -38,000원 잔고도 max_money100만원 조건과 다르다. 월5만원은 자동이체
  설정이지 현재 이체가 아니다. 전화 신호·부재중·무답장은 source대로다.
- 주운5만원을 지금 주머니에 넣는 행동과 '6개월 뒤 주인이 없으면 내 것'이라는
  선택 문구를 구분한다. 실제 소유권 확정·법적 인증으로 키우지 않는다.
- 복권 구매 -1000 뒤 결과 +4000과 산문 순이익4000은 불일치다.
  즉시 후속 enqueue와 토요일21시 대기는 별도 시간축 source 확인점이다.
  정확 확률1/8,145,060·3개일치·5등·5천원·5배·400%를 바꾸지 않는다.
- 검색→투자, 단톡방→웃고 헤어짐, 맥주 구매→함께 마심, 보험 조건 검색→
  보험료의 압축은 source대로다. 새 수락·동석·이동·구매 단계를 만들지 않는다.
- finance_033의 '앱을 열었다가 닫았다/아니면 아직 계좌가 없었다'는 조건 없는
  원문 대안이다. 집들이의 고시원 창문과 앞 no-window 산문도 별도 확인점이다.
- 공식 수리18만원/이틀과 당일25만원/그날 저녁, 세입자127명/28억원,
  중고3/5/2만원·60%, 2024/+31%/147좋아요, 월급비교/정확45만원받음,
  3개월개근/한달반,1+1/5개/3,500→11,000원,0.5초·15/12테이블,
  새벽1시47분·두시간뒤·10년전과30대/3억원을 전수 의미 대조한다.

## 검증

원문 manifest
`edf845a7164b8fedc9ec027be7a7edc381a3dcdf67ff58c2858d44a3237b64b8`.
초기source3 보존, 최종source/response/receipt3쌍과558문구 독립 KO 대조.
named full-game-localization-overlays를 --list로 확인 후 실행, EN·diff와
portable 전량 source/hash를 검사한다. 전체 INCOMPLETE·full/main/product HOLD,
L3/원어민/화면 OPEN·출시 M01~M06 BUILD2026.08.31.1 사용자 GO 유지.

이 범위·배치·증거 절차는 일회성이다. 지속 규칙은 I18N_INFRASTRUCTURE와
언어별 용어집이 소유하며 새 서사·제품·출시 규칙을 만들지 않는다.

## 번역 결과 — L1/L2 수용·L3 OPEN

- 선언 `c5bf1b5e823ae42e93005078b1345108c758483b` 뒤25 roots/186 leaf씩을
  KO에서 직접 저작하고 세 언어558문구를 다른 작성자 또는 ROOT가 전수 대조했다.
  CN의 위로/허세/알고리즘 주체3곳, TW 알고리즘 주체1곳을 명료화하고
  변경 leaf를 재대조했다. JA 필수 수정0. 나머지 값·문단·토큰은 보존했다.
- 초기187행 source3개는 저작 전 target=null과 같은 원문186을 보존한다.
  최종 source/response check·import --accept3개 PASS·changed_files0.
  기존 private 증거를 덮지 않고 작성된 target을 수용했다.
- 최종186-record aggregate JA
  `c0aef13002216736864aaef37adb4fdd53bb6faf87dcb135e403de9674f52d6c`,
  CN `46d6b882a13b780da23686abaf125025f001f3f8e5eb3f46a4a09d4d0aaf4545`,
  TW `5e21b9ab703a27d04bf20b0d36bfcde0ee6d44f7f0d7de923b2be74a1c2e2613`.
  신규558·누적13,839(언어별4,613), 사건453종3,545/locale다.
  이전13,281/meta9·batch30·기존54행403문구의 값·raw row·상대순서를 보존했다.
  새25행 내부는 KO 상대순서이며 life_events2 전체는 변경0이다.
- JA의 원화1,000원 묶음/지출 부호, 1+1의 설명과 로또 한 구좌·생략점 뒤
  일치 개수의 실제 오탐만 비교 스트림에서 정밀화했다. 독립 반례의 괄호
  人民元·프로모션 접두부호·음수 당첨 개수를 닫아 정상6/변조4 PASS다.
  원문·실제 번역에 숫자를 더하거나 표현을 검사기에 맞춰 억지 수정하지 않았다.
- ZH는30대·매월1회·맥주2캔·3개일치/5등·3개월권/약1.5개월·첫 행운·
  두 가격 차이를 실제 문맥에 결속했다. '이 원하는'을2원으로 읽은 오탐과
  구매 선택의 U+2212 부호만 수리했고 café/이분은 추가 수리0이다.
  신설 수량의 앞 잘못된 구절을 버리고 뒤 수량을 차용하는 대표5유형을
  닫았다. 多年/不會/箱/次/半天의 잘못된 단위·부정 구절5개 거부와
  정상5개를 독립 확인했고 원화 대표10개도 PASS다. 최종 자체3319는
  기존3203+신규116이며 실제 CN/TW372문구 오류0이다.
  관측 범위의 종결이지 임의 추가 수량·동사 부정 전체의 의미 인증은 아니다.
- 원문 중고거래의 이름은 [공식 Daangn](https://github.com/daangn/websites)과
  [공식 Karrot 사용 안내](https://www.daangn.com/wv/faqs/28)에 근거했다.
  당근을 뜻하는 모든 문장이나 임의 영어가 아니라 해당 판매 문맥만 허용한다.
  S&P500은 원문에 있는 지수명 자체를 유지하며 값이나 통화를 바꾸지 않는다.
  source underscore 식별자 차용은 닫았다. é/결합문자 source가 기존 generic
  token fallback에서 허용되는 한계는 선언 baseline에도 같아 별도 부채로 남긴다.
  새 composite licence는 그 둘을 허용하지 않는지 직접 검사한다.
- 완료176절1,533bytes만 기존 history25,016bytes 앞으로 원문 이동했다.
  새26,549bytes SHA `e357e17975555af41ac8d7405b695fdaf2d08d8757ee767c2f90150406c9e14d`,
  기존 내용·끝 LF2를 유지한다. 검수행은 같은 활성 이어보기로만 이동한다.
- 자동이체 설정/조건부 소유/미응답은 실제 완료로 키우지 않고 원문 확률·
  당첨금·기다림·실제 수령/투자는 그대로다. 선언의 효과·주거·시간축 부채와
  분모 밖 표시명은 별도 남겼다. KO/EN·runtime·공개·fonts·save·
  human_gates 변경0, 원본 checkout 쓰기0.
  full/main/product HOLD·전체 INCOMPLETE·L3/원어민/화면 OPEN·출시 데모 GO 유지.

- portable checksum `db36af5246d3e2637d7d6225772108ff4a5f8a5a6ea735781861c579289abb1c`.

### 최종 표적 검사

- 명시 차선 full-game-localization-overlays의 --list12개 확인 뒤 실제12개 PASS.
  full-game self172·ZH self3319·audit ERROR0/WARNING0, 공개100 leaf/121 UI
  패리티와 EN coverage/English Hangul0을 확인했다. 글꼴 JP-first blocked는
  자동 텍스트 통과에 합산하지 않고 원어민·화면·전체 HOLD로 남긴다.
- 누적13,839의 원문/대상 hash·L1 오류0이며 과거13,281와 메타9는 보존했다.
  최종 ZH 검사기316,848bytes SHA
  `8410854e7281b78df4bb9a24c863ef579c27ac65398eb882a9631c3df7c27812`.
- 실제 차선 stdout은 git-private `full-game-localization/order179-final-checks.log`에
  그대로 보존했다. 4,225bytes SHA
  `e7e89d132be0a6d03a03410a01f5f89c86973b606e292a6ba179b7d5c0e2e680`.
  이 로그는 회귀 증거이며 인간 실플레이나 출시 GO가 아니다.
