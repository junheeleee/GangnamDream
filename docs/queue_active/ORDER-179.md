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
