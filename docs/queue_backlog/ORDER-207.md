# Active Queue Spec: ORDER-207

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-207 [P0·전체 현지화] 투자·직장·가족 불안과 자기 기준의 원장면

착수 기준28,302(각9,434)·meta9·b67를 직전 수용 `0ad9202694a016a7bbeedd35fc14f85fa6426674`에서 확인한다.
선언 전 실제 원장·source manifest·미수용40/274·신규12파일 부재를 재검증한다.
공개 M01~M06 BUILD2026.08.31.1 사용자 GO와 전체 INCOMPLETE·full/main/product HOLD 유지.

## 깊이 3문

1. 수익률·원금·현금화·추가매수 의도는 서로 다른 사실이다.
2. 협상·청취·질문을 채용·인상·약속·병원 동행 완료로 바꾸지 않는다.
3. 미래목표와 현재행동을 분리하고 인물의 판단/불안을 옮긴다.

## 범위

### A: 23종 / 158leaf

- `inv_rebalancing_dilemma`
- `inv_hot_tip_kakao`
- `inv_market_crash_alert`
- `inv_dividend_received`
- `inv_loss_cut_decision`
- `inv_stock_ipo_lottery`
- `inv_etf_study`
- `inv_real_estate_bubble_fear`
- `inv_recession_news`
- `inv_investment_book`
- `inv_insider_tip`
- `inv_tax_worry`
- `inv_dca_commitment`
- `inv_crypto_mania`
- `inv_overseas_stock`
- `inv_portfolio_review`
- `etf_drip_discovery`
- `dividend_payday`
- `portfolio_rebalancing`
- `invest_first_win`
- `invest_first_loss`
- `leverage_temptation`
- `goshiwon_invest_night`

56선택·7,392 KO자·LF68·{name}23.
source aggregate `e17bae62736bc9becf99676e4a7a2171ed92f3695d985e86ee2f7378a22c421f`.

### B: 17종 / 116leaf

- `work_credit_stolen`
- `work_burnout_monday`
- `work_headhunter_call`
- `work_peer_salary_slip`
- `work_lunch_alone`
- `work_year_review`
- `anxiety_friend_baby`
- `anxiety_marriage_pressure`
- `anxiety_child_cost_calc`
- `anxiety_pension_crisis`
- `anxiety_parents_aging`
- `anxiety_early_retirement_witness`
- `identity_midnight_question`
- `identity_old_notebook`
- `identity_gangnam_why`
- `identity_10year_vision`
- `identity_define_success`

41선택·6,341 KO자·LF155·{name}0.
source aggregate `587bb09d0fea0a88c43faf7c43166b194170f2b57bb0afc175635e80dad0a217`.

전체40종274leaf·97선택·13,733 KO자·LF223·{name}23.
전부 shipping/event_standard/protected=false/builtin_overlay_static_only.
known/reader/memory/foreshadow0. source aggregate
`fe5cd2ad8b8bbc2efad458deadc3bf98aeda80819fab6e5c086686a0bd19094e`.

`investment_events.json`: 신규23종, KO 90059B `8807bb5b1e6ac6b06885065d6473083eaf60079bccd060dcbc09535680ac8e8f`.
`work_events.json`: 신규6종, KO 9742B `f61b3d54cfa86546065d29d2a3ab8cc0e0fe57d801007bdf126b9df441f96975`.
`anxiety_events.json`: 신규6종, KO 10564B `d7e0763064758b9c54f0f16e6be92519631d2bec0d3b03f850c80e4e4b6906d3`.
`identity_events.json`: 신규5종, KO 6401B `b5adc84b14759a4706d9d134ac5d096ebfcf82d3ef34605f5637f2c312d0e925`.

locale JA/CN/TW마다 investment_events의 선택23종만, work6·anxiety6·identity5를 신규 저작한다.
investment KO 전체51종 중 비선택28종은 이번 locale 파일에 넣지 않는다.
신규12파일만 수정. 저작 전 initial A159/B117행의158/116 previous-null 봉인.

## 조건·독자·도달

A has_portfolio22/has_job2/goshiwon1, ETF발견 min3. B work6/조기퇴직목격1 has_job.
나머지 불안·자기질문은 직장을 보장하지 않는다.
기간 조건은 원문별로 유지한다: 첫수익 W2~15, 첫손실 W3~20, 버블/코인 W49~96,
연간검토 min48, 연금불안 W8~192. 나머지 min 조건과 cooldown은 저작하지 않는다.
anxiety_parents_aging은 conditions에 father 부정조건이 아니라 tags의 requires_living_father로
EventManager._event_passes_hard_state_contracts/monotonic 생사판정을 받는다.
부모의 현재 방문·아버지 무릎은 살아 있는 원문이며 passed 대체장면을 여기서 만들지 않는다.

선택28슬롯이 기존26플래그를 기록한다(A6슬롯/4개, B22슬롯/22개).
추가 runtime 플래그를 만드는 작업이 아니다. 다른 producer는 callback_credit_theft_again c1의
job_change_trigger 한 슬롯이며 work_year_review만의 고유 경험으로 합치지 않는다.
외부 source-event 독자는27종/27 조건 슬롯이다:

- `callback_asked_growth_path_echo`
- `callback_asserted_timeline_echo`
- `callback_child_cost_grind`
- `callback_childfree_leaning_echo`
- `callback_comparison_anxiety_echo`
- `callback_confronted_manager_echo`
- `callback_considered_job_change_echo`
- `callback_corporate_escape_echo`
- `callback_credit_theft_again`
- `callback_etf_study_mode_echo`
- `callback_etf_study_payoff`
- `callback_first_invest_loss_echo`
- `callback_first_invest_win_echo`
- `callback_gangnam_standard_held`
- `callback_job_change_outcome`
- `callback_market_value_checked_echo`
- `callback_midnight_echo`
- `callback_own_path_confirmed`
- `callback_parent_first_money`
- `callback_past_self_accepted_echo`
- `callback_pension_self_fund`
- `callback_proactive_parent_care_echo`
- `callback_proactive_parent_care_echo_father_passed`
- `callback_salary_negotiation_result`
- `callback_started_etf_echo`
- `callback_success_undefined_echo`
- `callback_vision_midcheck`

독자는 전부 읽기전용, 이들의 원문과 기존 번역을 재저작하지 않는다.
endings.json에서26플래그의 exact known 독자0과 runtime 소비0은 다르다.
GameState.gd의 career_burnout 판정 한 문장은 burnout_acknowledged/job_change_trigger 두 플래그를 읽는다.
직장·앞선 엔딩 우선순위가 있어 선택만으로 엔딩확정0. career_burnout 전체 표준/known 읽기.
직접/지연 연결 incoming/outgoing0.

M07~M60 정적 closure 교집합0이다. 전역 foreground/explicit 분류는
anxiety_child_cost_calc·anxiety_pension_crisis 두 종이며, callback 분류/지연도달 교집합0.
등록·분류·static_possible은40종 실제표시/플레이 증거가 아니다.

metadata exact 키5/값6:
- event_director foreground 두 ID.
- story_rules 두 ID: internal/current_housing/participants[player]/portrait local,
  expected player_normal/current_housing 배경·음향. 가족/공무원/투자상담사를 화면에 동석시키지 않는다.
- exposed state_sensitive 두 ID는 housing/location. required_layer_contracts pension1은 같은 주거 배경·음향.
- release inventory4값: parents_aging/insider registered_not_foreground, portfolio_review 검색잡음,
  insider의 범죄 축 여러 사건 묶음. 그룹 static_possible≠insider 도달.
selected root/출력의 V2 직접참조0. 위 GameState 두 플래그 외 runtime exact literal0.

## 사실 안전선

### 투자 A

- rebalancing_dilemma의 한 종목은 60% 초과, portfolio_rebalancing은 정확히60%다.
  파란 수익·빨간 손실은 한국 원문대로다. 중국 시장의 색 관습으로 반전0.
  일부매도·다른자산 매수와 유지 후 추가상승을 각 선택대로 구분한다.
- hot_tip은 다온 단톡방의 오후2시 소문, 100명 초과/절반의 매수 의사다.
  형의 과거 한 번 적중을 신뢰 보증으로 바꾸지 않는다. c0 실제10만원 매수 뒤 하락,
  c2 공시에서 근거를 찾지 못함. '살게요'를 체결완료로 승격0.
- crash는 새벽3:17·미국 -4.8%·9시 국내장·5시간45분이라는 원문 그대로다.
  c0 손실 확정, c1 일주일 뒤 절반쯤 회복, c2 분할매수 주문과 미래 가능성을 구분한다.
  '전설이 될 수도'를 성공 보장으로 바꾸지 않는다.
- dividend_received 47,200원 실제입금, 재투자/외식을 선택한다. dividend_payday 43,200원
  두 언급은 같은 입금이다. 재투자 결과를 새 배당 한 번으로 증폭0.
- loss_cut의 -25%와 2주, 실제매도/물타기/그냥 닫기를 보존한다.
  앱 삭제 욕구는 삭제완료가 아니다.
- IPO 청약 증거금50만원, 도입 경쟁률820:1 초과/결과820:1, 3주(기간) 뒤2주(주식수)를 구분한다.
  SNS의 '따상 확실'은 타인의 과장 주장이지 객관적 보장이나 단순 두 배 실현이 아니다.
  실제 결과는 소폭수익뿐이다.
- etf_study는 이미 영상3편을 보고, 선택 후 일주일 공부 또는 익숙한 방식 유지.
  etf_drip_discovery의 장기수익 설명은 영상에서 접한 주장으로 두고 새무위험 보장 추가0.
  c0 자동이체 설정, c1 공부, c2 개별종목 선택을 서로 합치지 않는다.
- bubble은 경제학자3명의 경고·댓글 반반·기존 리츠다. 붕괴 예언을 발생사실로 만들지 않는다.
  recession의 전망2.1→0.9%, 코스피2% 가까이, 환율1,400원 향함을 확정수치로 평탄화0.
  해당 뉴스는 게임 원고이지 현재 시황이 아니다.
- investment_book은 실제구입/주말독서, 알림절반쯤 끄기·보고서 읽기와 현실차이 결론을 구분한다.
- insider의 공급계약·다음 달 실적은 선배의 주장이다. c0 다음달 주가20% 상승/돈을 번 사실과 불안,
  c1 조용한 거절·선배의 웃음, c2 공개자료로 판단함을 구분한다. 법적 면책·무위험 보장 추가0.
- tax_worry의 2,000만원 초과는 친구의 설명, 주인공은 경계선 근처다.
  20만원 상담은 실제지출, c1 신고서 작성은 제출완료가 아니다.
  overseas의250만원 기준도 원문 인식으로 옮기며 현재법령 설명이나 새제도 수정0.
- DCA 도입의 자동이체 설정과 월30만원, c0 6개월 뒤 잔고, c1 타이밍 기다린3개월을 유지한다.
  c1을 맞추려고 취소·미이체 사건을 창작0.
- crypto의 동창3천만원 수익 주장은 상태메시지다. c0 50만원→두배→반토막→조금올라 -30%,
  매도하지 못함을 손실확정 매도로 바꾸지 않는다. c1 두달 뒤42% 하락 뒤 침묵,
  c2 백서/원칙을 실제 신뢰수익 보장으로 바꾸지 않는다.
- overseas는 오르카 첫구매·달러결제와 복잡함, 100달러 경험이 미래1000달러를 지켜준다는 비유다.
  c0 한달 공부, c2 국내에 집중한다는 판단. 원/달러 환산이나 기존 매도완료 추가0.
- annual review 1월1일·1년·+7.3% 대 +11.2%, 시장미달≠원금손실.
  c2 기초부터 다시는 전량매도/저장삭제가 아니다.
- first_win은 ETF3.2%/48,000원, c0 추가매수 의도·확신이지 새매수 완료가 아니다.
  c1 48,000원 실현 뒤 같은날 오후2% 추가상승. 모든선택을 매도실현 하나로 합치지 않는다.
- first_loss의 손실7.4% 두 언급(첫 표기만 -)은 같은 오늘손실, c0 다음달6% 회복은 손실완전회복이 아니다.
  c1 매도 후3주 뒤 원점회복은 원문의 시간이다.
- leverage 3배·1년280%는 영상제목, c0 전체30%의3배=90% 노출 비유이며 수익90%가 아니다.
  c1 손실자 비율이 영상에 없었다는 뜻이지 손실자0이 아니다.
- goshiwon은 실제2평/새벽2시·노트북. c0 닫음, c1 실제매수→4시취침→다음날 -3%.
  브랜드는 용어집을 따르고 ID kakao로 다온을 바꾸지 않는다.

### 직장·불안·기준 B

- credit_stolen 실제가로채기, c0 앞으로 흔적 남길 결심/c1 실제 따로 대화, 공로복구/승진 합의0.
  burnout은 자기질문≠의료진단.
  30분산책은 실제, 이번 분기까지 버티자는 말의 '세 번째 분기'는 회고 압축이다.
- headhunter15%는 제안이지 수락된 계약이 아니다. c0 커피·조건 청취,
  c2 묻는 것까지만이며 답변·새직장 확정0. peer_salary12% 차이 뒤 HR 면담을 잡고
  성과 자료를 모은 것까지다. 임금인상은 별도 callback 선택에서만 발생한다.
- lunch는30분 혼자 먹기/뉴스, c1 '내일 같이 갈래요라고 물어보자'는 계획이지 오늘 초대 발신이 아니다.
- year_review는 실제B+다. S는 목표, c0 방향을 얻었다는 비유가 B+를 지우지 않는다.
  c2 이력서 열기/수정 필요가 이직 완료가 아니다.
- friend_baby는 친구의 임신 소식이다. 돌잔치 농담을 출산완료로 바꾸지 않는다.
  c0 전화끊음이라는 결과와 도입 메시지의 매체 간극은 아래 부채로 남긴다.
- marriage_pressure는 친척 압박과 자기 시간표이며 새청혼·혼인약속이 아니다.
  child_cost는 평균3억2천만원 보도/계산, 본인의 실제지출·임신·배우자 합의가 아니다.
- pension은2055년 고갈 전망 기사·위험, 30년 뒤의 불안이지 이미 없어진 연금이나 현재정책 확정이 아니다.
- parents_aging은 살아 있는 아버지 현재무릎·부모의 노화 목격.
  c0 병원예약, c2 요양 월200만원 비용조사는 완료 동행·치료·실제지출이 아니다.
- retirement는53세 선배의 실제퇴사/명예퇴직 권고. HR의 '자발적' 표현과 목격된 현실을 구분한다.
  c0 20년 근속 회고·포트폴리오 열기, c1 실제발신과 나중의 '고마워. 잘 지내' 답장은 지우지 않는다.
  답장으로 새취업·약속 성사를 만들지 않는다.
- midnight3시의 이력서/주식/알바는 선택지적 시나리오이지 모두 완료한 하루가 아니다.
- old_notebook은 대학1학년 시절 적은10년회사/30세목표. 과거목표를 성취사실로 바꾸지 않는다.
  노트 보관과 상자에 다시 넣기를 폐기/과거무효화로 바꾸지 않는다.
- gangnam_why 질문자는 미상, 인물지정0. 어디서나 가능한 수준은 능력목표다.
- 10year_vision의38세·5년·30억은 미래다. c0 적은 몇줄이 실제행동이며 목표달성/새이사0.
- define_success 실제친구 임원승진/주인공 축하발신, 30억은 목표≠현재재산·상대읽음/회신.

## 원문 부채 — 번역 수리0

1. crash 계산5시간43분/원문5시간45분, 새벽2시 미국개장/3시 마감.
2. crypto 단계 기준, dividend 47,200/효과50,000원, 해외100달러/효과200,000원. 환산·효과맞춤0.
3. DCA 설정/대기, 첫수익 매수의도/후속 무리한투자, 부모예약/후속동행의 압축 차이.
4. friend_baby 메시지/전화끊음은 미연출 채널전환. 새연결·수락 무대화0.
5. 고정1월1일/시각·REIT/후배/소파/고시원/기혼 조건누락, vision min32의5년/38세는 KO/runtime 부채.
6. 세금·연금·시황·수익주장의 제도/사실갱신0. 원문의 인물/보도/영상 주장이며 투자조언 추가0.
7. callback의 실제협상·이직·송금·돌잔치·첫투자를 원장면으로 당겨 넣지 않는다.
   공유 job_change_trigger의 다른부모 보존. 전량독서≠루트플레이.

## 소유권·검증

JA/CN/TW 각4파일·40종 KO직접저작, EN중역/간번자동변환0.
저자동결 후 독립 L2 전량822문구, 수정은 교차검토와 역치환 보존.
ROOT owns portable원장·이사양/queue/L3/CLAUDE/WORK_LOG/STATUS/backlog,
full_game_localization.py·self_test·zh_translation_audit.py·audit_scope.json.
가드는 원문결속 정상실물/변조짝으로만 수리, 검사맞춤 번역0. 자체/독립 분모·source OFF/E2E 원인 분리.
완료204 WORK_LOG절만 9/7 history 앞으로 원문이동 가능, 기존byte/EOF LF2 보존.
활성사양16,000B를 넘기면 완료결과만 정확경로등록 archive로 보관한다.
KO/EN·runtime·save·fonts·routing·공개·human·다른event/catalog/endings 수정0.

source manifest `edf845a7164b8fedc9ec027be7a7edc381a3dcdf67ff58c2858d44a3237b64b8`.
초기6·최종 source/response/receipt6쌍, A158/B116·최종274/locale exact 결속.
기존28,302/meta9/b67→계획29,124(각9,708)/b69, 실제수용값이 아니다.
named full-game-localization-overlays --list 후 선택검사·EN·diff·전량수용hash/L1.
전체audit/Godot/240주 실행0. 전체 INCOMPLETE·full/main/product HOLD·L3/원어민/화면 OPEN.
출시후보 발급·인간게이트 통과가 아니다.

수용·검증 기록: [L1/L2 결과](../queue_archive/ORDER-207_L1_L2_RESULTS.md).
