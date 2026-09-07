# Active Queue Spec: ORDER-177

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-177 [P0·전체 현지화] 고시원·출퇴근·건강의 일상을 옮긴다

**[~] 2026-09-08 Codex 착수 — 아래25 ID의 세 언어 text-only overlay,
원문 결속 검사·수용 기록·증거 문서만 소유한다.**
사용자의 전체판 번역 지시를 이어간다. 기존12,171번역·메타9·batch28과 공개 working baseline·배경 제품53493fe를
보존한다. 제품의 출시·주거·생사·도달성 수리는 하지 않는다.

## 깊이 3문

1. 좁은 집·끼니·통근·몸의 피로가 폴백이면 생활 경험의 언어가 끊긴다.
2. 선택·돈·생사·관계·주거·이동·도달성 조건은 변경0이다.
3. 다른 생활 사건·UI·소비자와 경쟁하므로25단위 한 배치에 한정한다.

## 배치 A — 생활·주거·건강25 roots /176 leaf /5,806 KO자

`content/events/life_events.json`:24 roots/168 leaf/5,403 KO자.

- `gosiwon_neighbor_first_meet`
- `gosiwon_thin_walls`
- `gosiwon_bathroom_rush`
- `gosiwon_window_light`
- `gosiwon_upgrade_dream`
- `convenience_store_meal`
- `convenience_extra_kimbap`
- `season_rainy_commute`
- `subway_hell_9`
- `survival_convenience_meal`
- `delivery_app_temptation`
- `health_cold`
- `health_sleep_debt`
- `health_insomnia`
- `health_meal_skip`
- `health_back_pain`
- `health_eye_strain`
- `health_tension_headache`
- `health_crying_alone`
- `health_diet_choice`
- `health_exercise_choice`
- `health_checkup_reminder`
- `health_burnout_signal`
- `health_mental_burnout_signal`

`content/events/life_events2.json`:rainy_day_umbrella1 root/8 leaf/403 KO자.

source aggregate
`92331e8a8f84e1b81b2b96e37519f16bb3a1072806a63243f9c640134f228484`.
제목25+본문25+63선택/결과126=176. known/memory/reader/foreshadow0.
전부 shipping·protected=false·builtin_overlay_static_only이며 대상 세 언어
target/accepted0을 착수 때 재확인한다. 직전176의185문구와 교집합0이다.

25건의 명시 foreground/bridge/fallback allowlist·즉시followup 입출력0,
관련 literal direct call을 찾지 못했다. 전체 비도달이나 실플레이 판정은 아니다.
director는 delivery_app_temptation에 has_job, commute tag에 직업,
health_back_pain에 housing_in gosiwon을 요구한다. 도시락·배달앱·불면증의
기존 반복 제한도 번역에서 변경하지 않는다.

## 파일 소유권

각 `content/events_<ja|zh-CN|zh-TW>/life_events.json`에 위24행만 추가,
`life_events2.json`에 rainy_day_umbrella1행만 추가한다. 기존 행·값·순서·
source/target hash를 유지하고 게임플레이 키는 복사하지 않는다.
언어별 독립 작성자1명, KO 직접 저작 후 다른 작성자/ROOT 전수 L2.
영어 중역·간번 자동변환0, 문단·토큰·숫자·인물/사실 경계 보존.

ROOT는 full_game_localization.py·full_game_localization_self_test.py·
zh_translation_audit.py·audit_scope.json, content/meta/full_game_localization.json,
이 사양·CODEX_QUEUE·CODEX_QUEUE_L3_PENDING·CLAUDE·WORK_LOG·생성STATUS·
전체 현지화 backlog를 소유한다. 필요하면 완료174 WORK_LOG절만 기존9/7 현지화 history 앞으로
원문 이동한다. 기존 history와 끝 개행까지 보존한다. 수용 뒤 현재 행은 동일 이어보기로 옮기되 [~]·L3 OPEN 유지.
실제 번역에서 재현한 검사 오탐만 source 문맥·정상/변조 fixture로 수리한다.
KO/EN·runtime·save·routing·human_gates·catalog/endings·공개·폰트·배포 비소유.

## 원문 사실·노출 부채

- 이웃 첫 만남의 relationship_effects[0].name='옆방 이웃'1곳은 본문176 분모 밖
  기존 resolver 채무다. source gameplay key를 대상 overlay로 옮기지 않는다.
- '서울에서 처음 아는 사람', 화장실 사건의 면접8→9시와 고시원만의 조건,
  찜질방12,000원/원룸 이사 저축3만원 산문 대비 효과 부재를 임의 수리하지 않는다.
  실제3만원 입금을 계획으로 약화하거나 실제 이사·계약으로 키우지 않는다.
- 허리의33살은 연차 제한이 없지만 주거 제한은 있다. 생존 삼각김밥 결과의
  고시원 귀환도 원문/상태 확인점이며 실제 화면 회귀 결함으로 판정하지 않는다.
- 정형외과 검색→진료/엑스레이, 검진 예약→검사/정상 판정은 원문 압축이다.
  벽 너머 답장·감사 메모와 울음 뒤10분 통화도 명시된 사실을 그대로 옮긴다.
  반대로 원문에 없는 회신·화자 이름·약속 성사는 추가하지 않는다.
- 우산 선택3개의 기능 괄호는 기존 source 표면 노출 부채다. 임의 삭제/새 설교0.
- '24시 치킨'은 점포 영업 맥락인데 현재 수량 collector가 clock_hour24로 읽는다.
  초안에서 실제 오탐이 발생할 때만 정확 문맥 수리한다. 한 달1~2회, 세 번 이상,
  70%·절반 미만·7시간48분·1분30초·새벽2시·두 블록·30분·9호선·200미터를
  자동 통과와 별개로 전수 의미 대조한다.

## 검증

원문 manifest
`edf845a7164b8fedc9ec027be7a7edc381a3dcdf67ff58c2858d44a3237b64b8`.
최초source3 보존, 최종source/response/receipt3쌍과528문구 독립 KO 대조.
이전 수용·메타9·batch·기존행·제품 보존, named full-game-localization-overlays
차선을 --list로 확인하고 실행하며 EN·diff·portable 전량 source/hash를 검사한다.
원어민·실제 화면·L3 OPEN, 전체 INCOMPLETE·full/main/product HOLD,
출시 M01~M06 BUILD2026.08.31.1 사용자 GO 유지.

이 범위·배치·증거 절차는 일회성이다. 지속 규칙은 I18N_INFRASTRUCTURE와
언어별 용어집이 소유하며 새 서사·게임·출시 규칙을 만들지 않는다.

## 번역 결과 — L1/L2 수용·L3 OPEN

- 선언 `c760fb85fd625ff62da6de05a1e9887fe8052ebd` 뒤25 roots/176 leaf씩을
  KO에서 독립 저작하고 다른 작성자 또는 ROOT가 세 언어528개를 전수 대조했다.
  일본어 야간 직원의 ‘버티고 있었다’ 조사/동사 결합1곳과 번체의 화자·수식 범위를
  정밀화했다. 필수 L2 잔여0이며 원어민·실제 화면 판정은 아니다.
- 최초177행 source3개는 저작 전 target=null과 같은 원문176을 보존한다.
  최종 source/response check·import --accept3개 PASS·changed_files0.
  이미 작성한 target만 수용했고 기존 private 증거는 덮지 않았다.
- 최종176-record aggregate JA
  `09a34372837d397fd425fe9b63f20c9bf3a7351fb848e42c40af1353d6dd723b`,
  CN `35320d99a2dcd40fe539cc00c521c8c27b9dba999c0c94ea7e279577f7bacbcc`,
  TW `ef718d70cc91184e977561b921966fd204a6485094ab4ab97e016d46b7603b55`.
  신규528·누적12,699(언어별4,233), 사건403종3,165/locale다.
  이전12,171/meta9·batch28·두 파일의 기존185문구/25행 값과 상대순서를 보존했다.
  JA는 기존 prefix 뒤 추가, CN/TW는 기존행을 바꾸지 않은 삽입이며 새행의 KO
  상대순서를 각각 확인했다. 전체 배열의 강제 재정렬은 하지 않았다.
- JA 금액 묶음·원화 오천과 실제 네 가지 native 시간 표현만 source 문맥에
  결속했다. 부호는 합성 금액 전체에 적용하고 금액/시간 순서도 남긴다.
  독립 검토에서 괄호 엔화 별칭 누출을 고쳐 정상12/변조30을 확인했다.
  ZH는 복합1분30초·7시간48분,24시간 치킨점 영업,월1~2회와五千 원화,
  배달앱/App·엑스레이/X光 문맥의 실제 오탐을 수리했다. 뒤 정상 월빈도를
  앞의 잘못된 기간/횟수가 빌리는 반례, 단위/명사 꼬리와 정확 시간의 상하한을
  보완하고 독립 재검증26건을 확인했다.
  일반 수사·모든 Unicode·문장 의미의 완전 자동 판정은 아니다.
- 번체 峰은 대만 교육부의 정자 A01119 및 尖峰 항목을 직접 확인해 공유 정자로
  분류했다. 기존 OpenCC 데이터/hash는 불변이고 간번 자동변환은 하지 않았다.
  근거: [교육부 정자](https://dict.variants.moe.edu.tw/dictView.jsp?ID=12299&la=1),
  [교육부 尖峰](https://dict.concised.moe.edu.tw/dictView.jsp?ID=22746&la=0&powerMode=0).
- 완료174절1,115bytes만 기존 history22,947bytes 앞으로 원문 이동했다.
  새24,062bytes SHA `616dcf4d418187a5cff54d170515309a86d4b4a854f8b24a1f25059a01d4c8b4`,
  기존 내용·끝 LF2를 유지한다. 현재 검수행은 같은 활성 이어보기로만 이동한다.
- 옆방 표시명1곳, 주거/나이/면접·금액효과·압축 진료·우산 괄호3의 source
  부채는 별도로 남긴다. 실제3만원 입금·옆방 답장·10분 통화·정상 검진은 원문대로다.
  KO/EN·runtime·공개·폰트·save·human_gates 변경0, 원본 checkout 쓰기0.
  full/main/product HOLD·전체 INCOMPLETE·L3/원어민/화면 OPEN·출시 데모 GO 유지.

- portable checksum `ced5a540b5e1a2f3c5e67ba72c62726bd94d225368fc4946ee3c007731461faa`.
- 최종 표적12개·별도 EN·diff PASS, portable12,699 source/hash/L1 오류0.
  self167·ZH3014를 포함한 실제 차선 stdout은 git-private order177-final-checks.log,
  4,225bytes SHA `ec7fe51429a597e4ad9f653ff46d5be5407a1fdba8db98037105f5e015e031e7`다.
