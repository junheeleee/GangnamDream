# Active Queue Spec: ORDER-184

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-184 [P0·전체 현지화] 후반 생활 이정표와 돈·직장 갈림길을 옮긴다

**[~] 2026-09-08 Codex 착수 — 아래25 ID의 세 언어 text-only overlay,
원문 결속 검사·수용 기록·증거 문서만 소유한다.**
직전15,957번역(언어별5,319)·메타9·batch35를 선언 직전 재확인해 보존한다.
공개 working baseline·별도 배경 제품53493fe는 변경하지 않는다.

## 깊이 3문

1. 남은 기간을 세는 생활 이정표와 큰돈의 기회·손실에서 선택의 무게를 그대로 읽는다.
2. 입금·계약·실제 만남과 권유/검토/미확정 주문, 시대·나이·직급은 변경0이다.
3. 다른 본편 사건/UI와 경쟁하므로25단위 한 배치다. 이25개가 하나의 연속 서사라는 뜻은 아니다.

## 배치 A — 25 roots /189 leaf /10,482 KO자

`content/events/story_events.json` 후반6종47 leaf/5,278자와
`content/events/drama_events.json` 앞19종142 leaf/5,204자다.
각 파일의 KO 상대순서를 유지한다.

- `story_one_half_year`
- `story_two_year`
- `story_three_year`
- `story_four_year`
- `age_35_checkpoint`
- `age_39_final`
- `drama_crypto_allin`
- `drama_crypto_result_big`
- `drama_crypto_result_small`
- `drama_startup_offer`
- `drama_chaebol_encounter`
- `drama_scam_attempt`
- `drama_inheritance_news`
- `drama_housing_lottery`
- `drama_office_politics`
- `drama_friend_investment`
- `drama_mentor_encounter`
- `drama_media_appearance`
- `drama_burnout_warning`
- `drama_rooftop_oneroom`
- `drama_viral_moment`
- `drama_eviction_notice`
- `drama_job_offer_dilemma`
- `drama_investment_big_win`
- `drama_friend_betrayal`

제목25+본문25+67선택/결과134+known5=189.
known5는 age_39_final.description_if_known이고 reader/memory payload/foreshadow0이다.
관계 표시 이름 강남 인맥·친한 친구·인생 멘토는 5회/3종의 밖 표면으로
이189문구 분모나 새 수용에 넣지 않는다. 전부 shipping·protected=false·
builtin_overlay_static_only이고 M07~M60 정적 closure·공개 교집합0이다.
선언 직전 세 언어 target/수용0과 source aggregate
`2261f5828a915a0680d45dd28d17bc56ced4f7d8affd6e3111f1f245d5a6b1ec`를 재확인한다.

## 도달과 장기 독자

- 직접 후속은 crypto_allin→result_big/result_small2개이며 모두 이번 배치 내부다.
  비어 있는 follow_up6회는 후속 사건으로 세지 않는다. 외부 직접 유입/유출0이다.
- flag write23회/13종의 밖 조건 독자는 callback_creator_started_echo,
  callback_chaebol_connection_echo, callback_bought_apartment_echo,
  callback_leverage_addict_margin_call, drama_startup_acquisition,
  startup_first_user_traction, creator_algorithm_penalty, creator_first_income8종이다.
  이들은 새 번역·수리 대상이 아니다.
- director foreground 등록은 crypto_allin1개, bridge/fallback0이다.
  MainGame의 me=(age-33)*12+month는 시작1~종료60이고 이정표18/24/30/36/48/54를
  각각 큐에 넣는다. JobSystem 승진 시 office_politics를60%로 추가할 수 있다.
  V2·Chapter5·인물 아크의 우선순위 때문에 선언 ID가 반드시 실플레이에 뜬다는 뜻은 아니다.
- age39 known5를 켜는 회수 flags의 생산자는
  arc_late_game_push·arc_37_reckoning이다. 이 밖 생산자와 runtime은 그대로 둔다.
  min_turn9999나 weight0만으로 비도달/저작전용이라고 단정하지 않는다.

## 파일 소유권

각 `content/events_<ja|zh-CN|zh-TW>/story_events.json`의 위6행과
`content/events_<ja|zh-CN|zh-TW>/drama_events.json`의 위19행만 소유한다.
기존 story25행158문구씩의 raw/value/order와 원래 JA goal 선두 순서는 보존하고,
새6행만 KO 상대순서로 덧붙인다. 기존 배열 전체 재정렬0.
drama3파일은 선언 직전 부재를 확인한 뒤 없을 때만 새19행으로 만든다.
기존 story 지문은 선언 직전 최종183 커밋의 실물로 재확인해 증거를 남긴다.

KO 직접 독립 저작·다른 작성자/ROOT 전수 L2를 한다.
EN 중역·간번 자동변환·gameplay key 복사0. 문단·토큰·수량·인물/사실 경계를 보존한다.
ROOT는 tools/full_game_localization.py·full_game_localization_self_test.py·
zh_translation_audit.py·audit_scope.json, content/meta/full_game_localization.json,
이 사양·CODEX_QUEUE·CODEX_QUEUE_L3_PENDING·CLAUDE·WORK_LOG·생성STATUS·
전체 현지화 backlog를 소유한다. 실제 오탐만 문맥과 정상/변조 짝으로 수리한다.
필요하면 완료181 WORK_LOG절만 기존9/7 현지화 history 앞으로 원문 이동하고
해당 절·기존 history 내용·끝 개행을 byte-exact 보존한다.
KO/EN·runtime·save·routing·human_gates·밖name·다른 사건·catalog/endings·공개·
폰트·배포는 비소유다. 수용 후 같은 활성 이어보기로 옮겨도 [~]·L3 OPEN 유지.

## 원문 사실·부채 경계

- 18개월의 출퇴근/현직 산문은 별도 직업 조건이 없고, 24개월의 옛친구 만남은 실제다.
  점심8분을 유지하며 인물이나 직업을 번역으로 추가하지 않는다.
  3년 산문36세/4년 산문37세와 me36/48의 달력 나이 계산은 별도 확인점이다.
  age39 ID의 본문은 38세 생일 전이며 남은7개월(현재달 포함)이다.
  ID를 근거로39세 생일로 바꾸지 않는다. known5의 회수도 그대로 옮긴다.
- 3년의 남은2년·한달→한주→오늘밤 계획과 업무/운동/1시간 공부 실제완료는 구분한다.
  4년의2년전 대비자산 증가에는 별도 자산 검증이 없고, 실제 선발신과 자동이체 내역 검토를
  새 송금으로 바꾸지 않는다. age39는 투자 한도를 쓰고 주문창을 열지 않는다.
  계산3번/화면3개를 보존한다.
- crypto 새벽2시·오픈채팅의3배 소문은 수익 보증이 아니다. 최대500만원 투자 확인은
  산문상 실제지만 최초 지출 payload가 없고 큰 결과의 새벽5시/-38%/강제청산과
  400만·550만원 고정손실은 최소조건50만원과 다른 원문 부채다.
  작은 결과의1주뒤 반토막25만원 회수/25만원 손실·50만원 추가·하루10회 들여다볼 미래와
  직접 즉시후속의 시간 압축도 그대로 둔다. 번역에서 손실을 재계산하지 않는다.
- startup은 설립6개월째이며 현재 월급 없이 스톡옵션만 준다. 6개월 무급 계약으로 바꾸지 않는다.
  억대 전망은 확정 성공이 아니다.
  사직은 산문상 실제지만 직업변경 payload 부재를 숨기지 않는다. 주말 참여 합의도 원문대로다.
  재벌2세는2살이 아니고 이름 없는 상대를 상철로 바꾸지 않는다.
  연락처 교환·일주일 뒤 초대는 실제지만 수락/참석까지 만들지 않는다.
- 사기 계정의30%/100만원→130만원·팔로워3만은 주장이다.
  실제 입금/입금확인 발신과3일뒤 계정소멸은 있으나 새 답장은 없다.
  경고 글에 실제 감사 댓글이 생기는 원문은 유지한다.
- 유산의 사망자는 먼 친척이지 아버지가 아니다. OO법무법인 표기를 실존업체로 바꾸지 않는다.
  500만원 실제입금과 전액기부를 유지한다. 주택청약 당첨은 원문 절차명이지 무조건 추첨으로
  바꾸지 않는다. 실제 계약금/날인과2년뒤 입주 예정, 새 집이 생겼다는 감각을 구분하고 즉시
  이사로 만들지 않는다. 비용800만원/최소조건1000만원과 '간신히'의 차이도 새로 보정하지 않는다.
- 사내정치의 김 대리는 부장/상철/다른 정본 인물로 합치지 않는다. 팀장/부장 등 직급 보존.
  이직 탐색은 실제 채용이 아니며 팀장/급여30만원 상승 산문과 job payload 부재는 별도다.
  친구 투자500만원 요구/최소조건300만원·1년2배 약속, 부분100만원 상대 수락과
  산문/효과의 지급 범위는 각각 보존한다.
- 멘토는 이름 없는 중년이며20세 서울진입/20년전·수십억 주장과
  실제 매주 만남 시작 또는 명함만 받기를 구분한다. 상철로 지정하지 않는다.
  media의2030 두 회는20대·30대 세대이지2030년이 아니다.
  기사 실제공개·SNS 응원댓글과 효과20만원을 새 취재료 문장으로 합치지 않는다.
- 번아웃은 진단을 추가하지 않고 의사의 휴식 권고를 옮긴다. 실제2일 휴식,
  버티기 분기의 월말실적/직업조건 부재도 원문 확인점이다.
  옥탑 보증금500은500만원·월세45만원이며 지역통화로 환산하지 않는다.
  여름/겨울의 온도 비유·실제 열쇠/짐풀기와 하우스메이트2명,
  housing payload 부재는 새 수리 대상이 아니다.
- 바이럴3일전 영상/10만조회·수백댓글에는 creator 조건이 없으며,
  3개월 업로드/구독1만/수입과 홍보비 효과50만원을 산문 밖 확정 지급액으로 만들지 않는다.
  퇴거2개월 통보/소유주 변경·개보수 주장과 실제2개월내 이사/협상보상50만원,
  권리 분기 효과100만원·housing payload 부재를 보존한다. 게임 속 법적 서술을 새 법률 안내로 확대0.
- 두 직장 제안은 대기업 계열사/스타트업이며 채용 수락 산문과 job payload는 별개다.
  연봉 협상 문맥의50만원 인상은 유지하고 월급50만원이나 효과20만원으로 고쳐 쓰지 않는다.
  ETF6개월38%에는 실제 보유 자산 검증이 없으며 실제 매도/보유뒤+10%→-15%/
  수익의 절반 현금화·절반 보유를 구분하며 보유 원금 절반으로 바꾸지 않는다. 새 수익을 보장하지 않는다.
  친구 배신에서 실제 사업자등록·사과는 보존하고 특허/법률 검색을 소송 제기로 키우지 않는다.

## 검증

원문 manifest
`edf845a7164b8fedc9ec027be7a7edc381a3dcdf67ff58c2858d44a3237b64b8`.
KO story_events70,759bytes SHA
`25675b3ec0b92aad87f501cedfb84ee57eba380fc5e021e41ef1c5cc858b5f68`,
drama_events64,438bytes SHA
`05050759599c85b29c5649d0460f600b3cf8d3241ef3df29ed5f24a16727caa3`.
저작 전에 initial source3(190행/189leaf, previous=null)를 봉인한다.
최종source/response/receipt3쌍·567문구를 독립 KO 대조하고 기존15,957/meta9를 보존한다.
named full-game-localization-overlays --list 뒤 선택12검사·EN·diff·전량수용 hash/L1을 실행한다.
실제 stdout은 실행 뒤 증거화하며 전체감사/Godot/240주를 실행하지 않는다.
전체 INCOMPLETE·full/main/product HOLD·L3/원어민/화면 OPEN,
출시 M01~M06 BUILD2026.08.31.1 사용자 GO 유지.

이 범위·배치·증거 절차는 일회성이다. 지속 규칙은 I18N_INFRASTRUCTURE와
언어별 용어집이 소유하며 새 서사·제품·출시 규칙을 만들지 않는다.
