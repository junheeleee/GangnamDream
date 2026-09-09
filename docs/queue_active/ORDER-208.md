# Active Queue Spec: ORDER-208

> 착수 — 만지는 파일: locale 9파일·portable 원장·이 사양·queue/L3·CLAUDE/WORK/STATUS/backlog 및 아래 소유 도구. 선언 commit/push·초기 source 봉인 뒤 저작한다.

#### [~] ORDER-208 [P0·전체 현지화] 투자 연쇄와 한국 생활의 원장면

공개 M01~M06 BUILD2026.08.31.1 사용자 GO·전체 INCOMPLETE/HOLD 유지.
실제 기준29,124(각9,708)/b69/meta9. 완료207 `9b46bb35ffd059183a8db618bf8f5cac31df8ff8`가 현재 main/origin main과 번역 브랜치의 공통 출발점이다. 개발 소스 통합이지 인간 게이트 GO가 아니다.

## 깊이 3문

1. 정보·투자·결과 확인·권리 매각의 시점을 합치지 않는다.
2. 수익률·노출액·실현손익·잔여권리 순현금은 서로 다른 숫자다.
3. 한국 제도와 생활 압박은 원문 인물의 경험/주장으로 옮기고 새 승인을 만들지 않는다.

## 범위

### A: 19종 / 154leaf

- `disasters_001`
- `gambling_002`
- `politics_003`
- `politics_004`
- `disasters_005`
- `disasters_006`
- `gambling_007`
- `finance_paycheck_card`
- `finance_012`
- `disasters_014`
- `politics_016`
- `gambling_020`
- `finance_022`
- `politics_025`
- `real_estate_regulation_news`
- `fear_greed_index`
- `market_crash_panic`
- `dividend_income`
- `real_estate_news`

6,276 KO자·58선택·LF165·name16.
source aggregate `502879cfa13ca13467498e133fd0c017da7ce9715c834b18e9ad198ae4d53367`.

### B: 19종 / 122leaf

- `orthodox_integrity_reward`
- `orthodox_institutional_access`
- `unorthodox_gray_zone_tip`
- `unorthodox_underground_network`
- `inv_ipo_hot_tip`
- `inv_redev_zone_tip`
- `inv_redev_completion_sale`
- `sangchul_tip_redev`
- `sangchul_tip_warning`
- `kx_hospital_visit`
- `kx_tax_refund`
- `kx_health_insurance`
- `kx_real_estate_jeonse`
- `kx_convenience_store_job`
- `kx_hoesik`
- `kx_yageun`
- `kx_kkondae`
- `kx_office_politics`
- `kx_salary_negotiation`

6,694 KO자·42선택·LF205·name7.
source aggregate `e6b2f9ef14bacdf1fcf562431584dbad23a8f3914077ab0f27f37845bec8972a`.

전체38종276leaf·100선택·12,970 KO자·LF370·name23.
전부 shipping/event_standard/protected=false. known/reader/memory/foreshadow0.
전체 source aggregate `1b40d8d4431f93c46d2f1cd19a0941a9d0285cb3f56023e2f8c62871a92ff6be`.

- investment_events.json: 남은28종216leaf만 추가. KO90,059B
  `8807bb5b1e6ac6b06885065d6473083eaf60079bccd060dcbc09535680ac8e8f`.
- korea_admin.json: 신규5종30leaf. KO7,471B
  `e7316783940bdaeee4ef81a757b572690840d726259c72641c0fa6b197150118`.
- korea_workplace.json: 신규5종30leaf. KO6,692B
  `f996fdc3ddddb8de37df4d886dde37632c3be823f0915813f96ea51b8712aa55`.

JA/CN/TW 기존investment23종158leaf씩474 accepted/source/target 및 raw23객체 prefix를 보존한다.
나머지28은 A/B 순서가 아니라 KO source의 상대순서로 기존23 뒤에 추가한다.
admin/workplace 각2개 신규파일×3=6new, investment3append. 전체9파일만 소유.
선언 전 기존207 수용원장·세 investment 파일 및 신규6부재를 재검증했다.
원장7,584,807B SHA `86f18e31520e80207e756b3c9f7485aa652f20ef58f352bdf83ec9d94ee99150`;
accepted SHA `30bf7432031c5810692bdd5d6eebf87bdb720630b3ec6ea1c316b3c6589eaf99`.
기존investment 지문(전체B/SHA; 끝 `]\n` 앞 raw prefix B/SHA):
- ja: 24602/`f30d521a9b9531ecd598c32127cdae55a25fdd625f5558bee4f9b364c6d2a7f5`; 24600/`896fa2a4c443a4b4ed908cbf3c359db7e716706f26e674928017b61035468b3f`.
- zh-CN: 20372/`e57efdd210cabacc7a66c5028b0e52b9f9380174f9fe94c94da47943e6081c23`; 20370/`c36d27cf26ca3d2313e3194a8324c76d2898168af91661eca8b2b02292e7e5af`.
- zh-TW: 20507/`ce804f11b82a08cbe1de15a156e4cde2986a55dbbf43914b327436b23d62b94b`; 20505/`082f102bf29113fa8bfd66e62f2161e722bb7fe4032915e0e14649eed58a3c85`.
private `order208-preflight-prefixes.json`에 raw/accepted158 해시를 별도 봉인했다.
원래 마지막 객체 뒤 LF도 유지하며 그 다음 쉼표로 이어 붙인다.
초기 A155행/B123행·154/122 previous-null×3 봉인 후에만 저작한다.

## 조건·도달·연결

대부분 투자 사건의 has_portfolio는 직장/배우자/집을 보장하지 않는다.
finance012 max_money50만원, paycheck/finance022 max_mental65,
real_estate_news max_money5천만원도 실제보유나 급여 상태가 아니다.
정도3/6·사도3/6 조건과 반대축상한4를 원문대로 보존한다.
admin/workplace has_job6/no_job2, 병원min4·전세min20/최소돈5천만원을 보존한다.
고정 1월·새벽시각·고시원·집·동료·신입의 조건 간극은 번역수리 대상이 아니다.

_property_ladder_event_id의 투자 정체성 확인과 앞선 장면/예약 우선순위를 읽는다.
IPO W49~72/1천만원/portfolio/미열람, 상철 W73~96/IPOclosed/1천만원/관계단계,
일반 상철기회 W82~111/5천만원/아직 진실·신고·단절 없음,
재개발 W112~143/arc_opp_result_seen/8천만원을 구분한다.
재개발 매각은 min160/redev_management_seen/미처리 두 종료flag가 별도 조건이다.
정적 M07~M60 교집합0. 전역 root3(IPO/상철팁/재개발팁), 명시closure4(매각 포함),
selected callback/chain 분류·그 delayed 집합0. 실제38종 플레이/도달 주장0.

직접 in/out0, 지연 output14물리슬롯/7root쌍.
내부 재개발팁→매각2슬롯/1쌍, 외부 incoming0.
IPO결과 +1, 상철팁 +8, 재개발판정 +24와매각 +48을 현재결과로 당기지 않는다.
_resolve_opportunity는 선택시 손익을 실제 정산하나 산문은 결과를 기다리는 구조다.
UI 숫자·순현금 지급과 원고 시점의 간극을 새승리/실패 산문으로 봉합하지 않는다.

output40물리슬롯/28고유flag(투자30/18+생활10/10).
투자12 외부조건독자/16슬롯:
arc_opp_sangchul_realty, callback_redev_bet_taken_result, callback_redev_bet_failed_result,
callback_heeded_sangchul_warning_result, callback_underground_network_member_consequence,
callback_took_gray_tip_echo, callback_sangchul_tip_win_payoff, callback_sangchul_tip_lose_awkward,
callback_inv_ipo_hot_tip_win_listing, callback_inv_ipo_hot_tip_lose_listing,
callback_pb_access_reality, callback_took_gray_tip_consequence.
arc_opp_sangchul_win/lose와 ending unorthodox_legend 전체/known도 읽는다.
closed는 거절 또는 승/패 결과회수 모두에서 나온다. closed≠win, result_seen≠win.
관리판정의 두선택 모두 management_seen을 주지만 하나만 조합총회에 참석한다.

생활9 외부조건독자:
callback_tax_windfall, callback_jeonse_protected_safe, callback_jeonse_scam_narrow,
callback_hoesik_payoff, callback_hoesik_left_early_office, callback_overtime_burnout,
callback_overtime_boundary_echo, callback_kkondae_yielded_echo, callback_kkondae_respect.
ordinary_life의 worked_convenience known1과 amb_hoesik_00 전체도 읽는다.
선택output의 외부producer6종/10슬롯: 상철/IPO 승패callback4×2,
amb_hoesik_00의 early_leave1, callback_overtime_burnout의 boundary_set1.
그 회수 사실을 원장면에 미리 넣지 않는다.
엔딩 known2(unorthodox_legend/ordinary_life)는 첫매칭·다른조건/우선순위가 있어 확정출력0.

meta selected키4/값0: exposed state_sensitive의 IPO employment, 매각location,
재개발팁/상철팁 relationship. story_rules 신규설정0.
ImageRegistry의 convenience/insurance 두ID 배경추론은 ingress가 아니다.
KO/runtime·효과·라우팅·메타는 전부 읽기전용이다.

## 사실 안전선 — 투자/생활비 A

- 월세5만원 인상=연60만원/5년300만원, 협상3만원 절감=연36만원.
  구독2개의 합계48,000원과 5만원 gap, 이사35만원/7개월 손익분기는 원문대로다.
  실제 이사 결과를 새매입·소유로 바꾸지 않는다.
- coin 새벽1시·1시간200%는 광고주장.10배/증거금10만원/노출100만원을 수익으로 바꾸지 않는다.
  설치안함·새벽2시유혹, 설치화면을 남겨둠, 실제전액베팅/결과미상은 각선택별이다.
- 정책10:03의세 발표, 창유지와2시간뒤재열기 원문을 보존한다.
  당일+3.2%/다음날-1.8% 뒤에도 수익이라는 결과를 손실로 바꾸지 않는다.
  해고소문은 공식발표가 아니고 주가는 -8%를 향해 간다. -8% 도달·주인공 해고 확정0.
- 휴대폰 공식수리30만원/중고액정18만원, 실제수리는 새폰구입이 아니다.
- 스포츠 링크100%주장/11명/3초. 등록화면에서 뒤로 나온 선택은 가입완료가 아니다.
  1만원 베팅패배는 원문 실제결과다.
- 급여는 도입에서 이미 카드값 출금인데 결과에서 다시 갚는 원문 간극을 보존한다.
  최소결제액 실제이체/남은돈 투자, 외면은 서로 다른 행동이다.
- 마이너스34,200원·한도잔여4,967,800원에서 임의총한도500만원 추가0.
  08:41 알림과 저녁 지인차입금 입금·마이너스 해소를 구분한다. 지인빚 상환은 추가하지 않는다.
  매도 뒤 계좌0과 한도전액 인출·투자계좌 이동은 별도 선택이다.
- 사기피해300명·낙폭-3.2/-4.1/-2.8%를 보존한다. c1은 1/3매수 뒤
  다음날2% 추가하락·추가1/3매수다. c2의 -6.3% 손절은 별도 선택이며 익절이 아니다.
- 지원금 발표조건·신청제출과 지급은 구분한다. c2의 이미수령 결과는 원문압축이다.
  새 승인화면·행정절차·추가입금 창작0.
- 동료의 작년1억원수익은 주장. 도입이미집/결과모임떠남 간극을 새재회로 봉합0.
- ETF20년600%는 접한주장. has_portfolio와 '아무것도보유하지않음' 간극을 수리0.
- 부동산소문10만뷰/다음달미정과 별도정책발표는 같은확정기사로 합치지 않는다.
- 공포탐욕 title100/description98 두값을맞추지 않는다.
  빨강손실·파랑수익 원문색은 중국시장 관습으로 뒤집지 않는다.
- 코스피-8% 충격. c0 분할매수 뒤 2개월후 시장50%반등과 포지션두배는 다른 기준이다.
  c1 매도손실확정과 c2의 버팀을 분리하며, c0 반등결과를 c2로 옮기지 않는다.
- 배당234,000원 세언급은 같은실제입금이지 세번지급이 아니다.
  '처음' 도입과 cooldown8/seen조건없음은 원문부채다.
- 아파트평균25억원 두언급=25억 원의 뉴스주장(2.5b KRW), 주인공집/현재가격 보장0.

## 사실 안전선 — 기회 연쇄 B

- integrity 익명연락을 상철초상만으로 상철발신이라고 실명화0.
  합법·안전·수익설명은 원문주장이지 법적보증/최신제도설명 추가0.
- PB 공개리서치를 하루먼저받음은 내부자비밀정보가 아니다.
  실제거절/상대이해와 미래초대는 정식계약·확정수익/고정승진이 아니다.
- gray낯선사람/합법성 '아마도'·매수포지션 대기/며칠후 결과를 유지한다.
  정보를샀다는 원문에없는 결제·즉시수익을 추가0.
- underground 도입방입장/선택클릭의 간극을 새초대·신원으로 수리0.
  원문의 수익/양심결과를 각선택대로 구분한다.
- IPO 2~3상한가는 타인주장, 현재청약은 결과확정이 아니다.
  거절closed와 +1주 승/패결과closed를 구분한다.
- 재개발 평당시세의30%는30%할인이 아니다. 전재산 표현/65%stake 간극을 보존한다.
  실제계약·열쇠/인감과 인허가대기, 부분투자 현금잔여는 각선택대로다.
- 매각26억원은 잔여권리에서 새로받는 순현금(2.6b KRW)이다.
  이미반영한손익·세금·분담금·장부금액을 중복입금하지 않는다.
  팔면 실제서명/입금, 보유하면 입금없음. 완공·입주·새집확정 추가0.
- 상철30년/도입의 과열분위기3번·c1의 폭락3번은 그의 회고다.
  위험점검 선택은 즉시매도·영구손실방지가 아니다.
  후속의 손실회피/수익강화를 원장면으로 당기지 않는다.

## 사실 안전선 — 한국 생활 B

- 약값4,800/진료비4,500/비타민8,000=17,300원과 effect18,000원차이는수리0.
  대기10분/진료3분, 실제진료와건강감각을 원문대로. 의료보장창작0.
- 연말정산1월/min5 고정시점, 환급15만원예정/효과와 후속실제입금을 구분한다.
  신고작성·신청을 새접수/입금완료로 높이지 않는다.
- 보험고지89,000원과'9만원'근사는그대로. 3회분납 가능/신청은 승인보증이 아니다.
- 전세시세60~80%는한국제도설명으로원문을옮긴다. 확정일자/전세권설정은 c0실제행동이다.
  c1서명/아직안늦음은확정일자취득이 아니다.
  min_money5천만원은보증금액이 아니며 effect5천원은이사비가 아니다.
- 편의점시급10,320원은원문금액, 06~11시 실제채용/근무산문과 grant_job없음/80만원effect의
  간극을다듬지 않는다. 현재법정최저임금으로설명하거나다른시급으로갱신0.
- 회식1차후퇴장과 amb3차/부장공유flag는같은장면이 아니다.
  끝까지남은결과의 귀가/팀장어깨토닥임압축을 새주거동석으로봉합0.
- 야근19시인데정시퇴근choice,22시퇴근/자정고시원은그대로.
  공유burnout부모의내적경계와후속실제퇴근공부를한번의행동으로합치지 않는다.
- 꼰대겉동의/내심과 소신발언은구분. 후속의인정은현재승인으로당기지 않는다.
- 사내정치 선택은사람/정보/관계의주장대로,새승진/공로확정추가0.
- 연봉15%요구뒤 실제7%합의 또는회사3%안을구분한다.
  effect20만원을추가월급/연간총액의새수치로붙이지 않는다.

## 원문 부채·소유권·검증

위 금액/시각/입장순서/조건/회수강도·즉시PnL대지연산문·제도주장의 간극은 KO/runtime후속으로 남긴다.
원문부채를 번역·초상·효과수정으로 봉합하지 않는다. 새읽음·답장·입장·승인·계약·소유추가0.
소유는 locale9파일 신규38종 및 ROOT portable/이사양/queue/L3/CLAUDE/WORK/STATUS/backlog,
full_game_localization.py/self_test/zh_translation_audit.py/audit_scope.json이다.
KO직접저작/EN중역·간번자동변환0. 독립L2신규828 전량, 기존474prefix·값·hash보존.
가드는 정상실물/변조짝 사전봉인 뒤만수리, 자체/독립·sourceOFF/E2E분리.
완료205 WORK_LOG절만9/7history 앞으로 exact이동 가능, 기존byte/EOF LF2보존.
위 source/oldledger/oldinvestment 실제 지문을 기준으로 기존 수용본을 보존한다.
source manifest `edf845a7164b8fedc9ec027be7a7edc381a3dcdf67ff58c2858d44a3237b64b8`.
초기6/최종source-response-receipt6쌍 결속 뒤 계획29,952(각9,984)/b71.
named lane --list 후 표적검사·EN·전량hash/L1·diff. 전체audit/Godot/240주0.
활성사양16,000B 초과시완료결과만archive·정확경로등록. 전체INCOMPLETE/HOLD·L3/원어민/화면OPEN.


## 수용·검수 기록

신규828과 기존29,124를 대조·수용한 결과·지문·검사 경계는
[ORDER-208 L1/L2 기록](../queue_archive/ORDER-208_L1_L2_RESULTS.md)에 보존한다.
전체 INCOMPLETE/HOLD와 L3·원어민·화면 OPEN은 유지한다.
