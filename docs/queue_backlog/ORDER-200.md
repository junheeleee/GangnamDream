# Active Queue Spec: ORDER-200

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-200 [P0·전체 현지화] 친구·직장·살림 선택의 후속을 옮긴다

**[~] 2026-09-08 Codex 착수 — callback32~35의 미수용17종92leaf 한 배치, 세 언어 text-only.**
선언 직전 ORDER199 수용24,534(각8,178)·meta9·batch56를 재확인한다.
공개 working baseline·별도 배경 제품53493fe를 변경하지 않는다.

## 깊이 3문

1. 친구와 다시 만남/아직 못 만남, 용서/화해, 대응/손실을 KO에서 직접 읽는다.
2. 원문에 있는 실제 답장·만남·매매는 살리고, 제안·다짐을 완료로 앞당기지 않는다.
3. 32의4종·33 forgiven1종·34의7종·35의5종만 옮긴다.
   33의 기존 leveraged6leaf와 36 이후 사건은 비소유다.

## 범위 — A17/92, 총5,348 KO자

- `callback_reached_out_echo`
- `callback_friends_world_echo`
- `callback_startup_friend_update`
- `callback_drift_accepted_now`
- `callback_sangchul_forgiven_echo`
- `callback_jeonse_protected_safe`
- `callback_jeonse_scam_narrow`
- `callback_hoesik_payoff`
- `callback_kkondae_respect`
- `callback_overtime_burnout`
- `callback_tax_windfall`
- `callback_recycling_neighbor`
- `callback_truth_echo`
- `callback_lie_echo`
- `callback_mindset_saver_echo`
- `callback_mindset_investor_echo`
- `callback_envy_fuel_echo`

합29선택·LF193·{name}12. source aggregate
`5ec0afdaedf6b222f7151c6c021db201a95c13d16adc7ad0ef9573800f9c42c5`.
known/reader/memory-field/foreshadow/밖표시명 신규0.
전부 shipping·event_standard·protected=false·builtin_overlay_static_only.
jeonse safe/narrow·kkondae·tax·recycling 다섯 bridge는 각각1선택, 나머지12종은2선택이다.
public·정적 M07~M60 closure 교집합0이며 실플레이 도달 증거가 아니다.

callback_events_32.json: 4종/24leaf·1508KO자·LF58·name1,
6130B SHA `8c0e7a61ac3448676c0a05495c707c64770b4ce5dbfa2081d29953cf0d66e815`.
callback_events_33.json: 1종/6leaf·518KO자·LF22·name0,
4770B SHA `0bda82c90e603fe32ade2447de4c5e690c88e0e66ba6ec087726e5ed034950e2`.
callback_events_34.json: 7종/32leaf·1354KO자·LF46·name0,
7850B SHA `e41a694747e0b4fcb1ad8292c6ed1f5b9566a9c132d144f0fdca71210e016099`.
callback_events_35.json: 5종/30leaf·1968KO자·LF67·name11,
9497B SHA `51614fe7e20a9edcac30554dc488582a0e172ed7c82801d437d0d1ef5145f6ef`.

32/34/35의9개 locale파일은 신규다. 33은 기존 leveraged1행6leaf 뒤에 forgiven만 append한다.
KO의 forgiven→leveraged 순서를 따라 기존 overlay까지 재정렬하지 않는다.
기존33 행의 raw prefix·6leaf·portable 수용기록을 보존한다.
기존33 지문:
ja 1678B SHA `92d50ac63b1d55c5f1c0e6e8e85c19fae7533b8cf8effb8ed0faefc72523508f`.
zh-CN 1230B SHA `b1171ea20862abc8238fc5d973b1a0c99637b2ec9d9c5bf1a66a307ce1f191f3`.
zh-TW 1338B SHA `5f5cf94549b653592c74805ec98a92e40ee37ca905bef421c2f1e589758fe506`.
선언 직전 신규92 미수용·target 부재와 기존33 지문을 재확인한다.

## 도달·조건·독자

- DataRegistry94~97 등록. source 즉시/지연 ID edges0.
- director foreground2(truth_echo·mindset_investor_echo), bridge5(위1선택 사건).
  fallback/context 명시ID0. bridge 편성과 실제 도달은 별개다.
- runtime 정확ID1은 ImageRegistry639 hoesik_payoff→office 이미지 선택이다.
  직접 사건 호출로 세지 않는다.
- 출력flag17위치16unique. 내부 seen no_flag는 forgiven1곳이다.
  외부 event조건독자1: callback54 overtime_boundary_echo.
  overtime_boundary_set은 부모 kx_yageun c1도 쓰는 공유flag다.
- 외부 known독자6문구/2root: arc_almost_there의 saver_patient/
  saver_pivots_to_invest/investor_disciplined/investor_reset,
  arc_year_three_crossroads의 envy_released/envy_still_burning.
  새flag runtime literal0. 외부 reader문구는 비소유다.
- 32 min_turn32/40/48/52,33 min76+seen제외,
  34 min30/30/24/20/28/8/12,35 min16/16/16/16/20.
  max_turn 없음. 34 kkondae만 has_job이며 다른 데 없는 직업/주거조건은 추가하지 않는다.
  조건 최소값을 산문의 '수개월/반년/6개월'과 정확히 일치하는 시간표로 주장하지 않는다.

## 파일 소유권

각 locale callback_events_32.json~35.json 열두 파일만 저작한다.
KO 직접 독립 저작, EN 중역·간번 자동변환0, 전수 교차 L2.
ROOT는 tools/full_game_localization.py·full_game_localization_self_test.py·
zh_translation_audit.py·audit_scope.json, portable 수용원장, 이 사양,
CODEX_QUEUE·L3_PENDING·CLAUDE·WORK_LOG·생성STATUS·전체 현지화 backlog를 소유한다.
오탐은 실물 정상/변조 짝과 원문 경계로만 수리한다.
필요하면 완료197 WORK_LOG절만 기존9/7 history 앞으로 원문 이동한다.
활성 문서 예산을 넘으면 완료 증거만 queue_archive로 원문 이동하고 링크한다.
기존 history bytes/끝 개행을 보존한다.
KO/EN·runtime·save·fonts·routing·공개·human_gates·다른 사건·catalog/endings 비소유.
완료는 같은 큐 이어보기 [~]·L3 OPEN, 전체 번역이나 제품 GO가 아니다.

## 친구·용서의 사실 경계와 부모 부채

- reached_out의 부모 friend_group_chat_silent는 실제 답장,2주 조율 뒤 비어색한 만남이다.
  echo는 어색한 첫연락/의무적 한 번 만남 가능성을 다시 평가한다.
  두 원고 차이를 가상의 새약속이나 또다른 이전연락으로 메우지 않는다.
  c0 더자주봄·단톡재개, 상대도기다렸던것같다는추측을 보존한다.
  c1 한 번만남 뒤 '다음'미도래를 새일정확정으로 만들지 않는다.
- friends_world는 친구결혼식 뒤 실제연락이다. c0 실제대면/서로대화,
  c1 답장만함·아직못만남·날짜미정의 차이를 유지한다.
  {name}이친구세계일부가된감정을 다른관계/결혼확정으로 바꾸지 않는다.
- startup은 대학동기 회사의 Series A50억원→c0 Series B120억원 뉴스다.
  개인입금·주인공수익·친구의현금보유로 만들지 않는다.
  c1 자금소진우려뉴스 뒤 실제선발신과 잠깐뒤 실제답장이 있다.
  원문의 '형' 호칭을 새혈연/학년확정으로 해석하지 않는다.
  답장이 원문에 있는 이 장면을 일반경로 무응답장면과 혼동해 삭제하지 않는다.
- drift는 예전 반년만의만남 뒤 오늘 다시실제만남이다.
  오늘은약속금방잡힘/앉자마자말이됨을 그대로 옮긴다.
  c0 차이를나눔/c1 말적어도불편하지않음이지 관계단절이 아니다.
- forgiven의 부모 arc_sangchul_reckoning c1은 사과수용과무게내려놓음이다.
  '아버지가 돌아오는 건 아니었다'와 echo '아버지를 망하게 한 사람'은 각각그대로둔다.
  생사조건·추가과거를 만들어 맞추지 않는다.
  c0 실제나감/상철과시장·날씨대화, c1 메시지를읽고답하지않음이다.
  용서와화해를 구분하고 무답선택에 커피·동석·답장·화해완료를 추가하지 않는다.
  민준·임상철 표기는 locale 정본에 맞추며 새한국식 한자명을 발명하지 않는다.

## 주거·직장·행정의 사실 경계와 부모 부채

- jeonse protected는 집주인파산신청 연락, 확정일자·전세권서류로대응,
  법원경매 선순위채권자 인정과 보증금전액회수까지 원문에 있다.
  이 사건의 압축결과를 일반적인 법률보장·무조건보상으로 확장하지 않는다.
  '고시원 방 옆 전세 계약'의 어색한주거구문을 이사완료·현재전세입주로 임의교정하지 않는다.
- jeonse narrow는 집주인파산문자/확정일자미취득 후
  법률구조공단 실제방문·후순위·일부회수·500만원손실이다.
  부모 kx_real_estate_jeonse 미보호선택은 '다행히 늦지 않았다'인데 echo미취득인 부채다.
  늦은신청완료·보상보험·손실회복을 만들어잇지 않는다.
  전세는 JAチョンセ, CN/TW全租이며 월세/매매로 바꾸지 않는다.
  법률구조공단·홈택스·주민센터와 제도는 한국 배경으로 유지한다.
- hoesik는 다음분기 신규프로젝트 PL 제안이다. 회식덕/실력덕은 아직모른다.
  c0실제수락/c1더준비된뒤맡고싶다고정중거절이며 승진·시작·완료확정이 아니다.
  고개끄덕임은 다음기회 보장이 아니다.
- kkondae는 예전반박을상사가옳다고인정한말을듣는다.
  처벌·징계·정식사과·승진을 덧붙이지 않는다.
- overtime c0 선택은 '선을그었다'지만 결과는 마음속다짐뿐이다.
  실제상사통보/퇴근완료/승낙으로 바꾸지 않는다.
  c1 버팀뒤몸의항의·소화/수면문제를 새의학진단으로 만들지 않는다.
  공유flag 후속callback54가 실제정시퇴근처럼회고하는차이는 원문부채로남긴다.
- tax는 환급예정액확정알림→c0실제15만원입금이다.
  부모 kx_tax_refund는 산문예정인데 이미 money+15만원,
  echo도실제입금과+15만원효과다. 두금액을합산해30만원이라고쓰거나
  추가/두번째환급을발명하지 않는다. 게임효과는 비소유다.
- recycling은 옆방아주머니가먼저말검, 실제서로이름알게됨/이후복도인사다.
  새이름·친밀관계·이사확정은 추가하지 않는다.

## 면접·투자·동기의 사실 경계

- truth는 새서류전형통과/면접, 가족빚공백질문재등장이다.
  c0솔직한설명뒤감사말/신뢰감, c1다르게포장뒤고개끄덕임이다.
  어느쪽도 합격·채용·새월급확정은 아니다.
- lie는 예전사업준비주장을팀장이호기심으로되묻는다. 방어적추궁이아니다.
  '6개월 전'을 조건min16에맞춰바꾸지 않는다.
  c0가족빚으로정정/상사반응, c1새거짓말/납득의차이를 유지한다.
  솔직함을 채용취소면제·징계없음보장으로 부풀리지 않는다.
- saver는절약저축실제잔액·타인주식수익전언이다.
  c0계속모음/아직때아님, c1실제HTS켜고계좌열기다.
  계좌개설을첫주식매수·수익발생으로앞당기지 않는다.
  효과20만원을산문새금액으로 넣지 않는다.
- investor는수개월공부뒤실제소액투자와며칠의등락이다.
  카페글은 온라인커뮤니티글이며 실제카페방문이아니다.
  c0원칙유지·손절/추가매수·소액수익, c1전량매도·손실확정의실제행동을 보존한다.
  새원금·수익률·효과10만원손실을 산문에더하지 않는다.
- envy는분노동기로수개월버틴피로다. c0자기이유를다시씀,
  c1계속감/몸부담이며 번아웃진단·치료·새성공으로 확정하지 않는다.

## 검증

source manifest `edf845a7164b8fedc9ec027be7a7edc381a3dcdf67ff58c2858d44a3237b64b8`.
저작전 initial3 A93행, 신규92previousnull×3.
최종source/response/receipt3쌍·276문구 대조, 기존24,534/meta9/b56 보존.
check/import는 source JSONL을 --batch, 언어를 --locale로 명시한다(--source 없음).
named full-game-localization-overlays --list 뒤 선택12·EN·diff·전량수용 hash/L1.
실행 stdout만 증거화, 전체audit/Godot/240주0.
전체 INCOMPLETE·full/main/product HOLD·L3/원어민/화면 OPEN.
출시 M01~M06 BUILD2026.08.31.1 사용자 GO 유지.
이 문서는 일회성 범위이며 지속 규칙의 소유자는 I18N_INFRASTRUCTURE/용어집이다.

## 수용 결과 — 276번역·L1/L2, L3 OPEN

- 선언 `ad16fb00aa87149fc6b332cae7f24f682330231a` push 뒤 initial3
  A93행·신규92 previous null×3를 저작 전에 봉인했다.
  KO 직접 독립 저작 후 다른 작성자/ROOT가276문구 전부를 대조했다.
- callback32~35 신규17종92leaf씩, 열두 text-only 파일에 반영했다.
  신규9파일과 기존33 세 파일의 forgiven append뿐이며 leveraged6leaf씩과
  각 기존 object raw prefix·행/키순서·portable 기록을 보존했다.
  누적24,810(각8,270)·b57, 언어별 events1,033종7,202·endings234·catalog834다.
- 독립 L2 필수0, 정밀3: CN 용서뒤 심리적释怀 상태의 추가단정1,
  TW 대학동기의기수1·남들때문/남들을위해의 동기구별1을 반영했다.
  지정3 최종실물 교차검토와 전체12파일/records 역치환으로
  JA92/CN91/TW90 나머지 불변을 확인했다.
- ZH 실물6원문의 오탐을 source 결속으로 수리했다.
  식사제안/그한번/의무적만남·두원인·용서와화해·서류한장의 역할을 구분하고,
  '보증금 일부만'의 '보증금 일'을 1만원으로 잘못읽지 않게 했다.
  홈택스는 해당환급알림의 bounded Hometax만 지원한다.
  도구+208/-0·591,901B SHA
  `6a6b67e26d3fec9422ce8db97e1a478af95537f0b2c8d9a9432839b8d41390fa`.
- ZH 자체6772(기존6548+신규224)와 독립고정84는 각각 PASS다.
  독립84는 실제정상12·target변조거부60·source경계12로,
  마지막12는 typed라이선스해제10과 Hometax영어거부2다.
  source변형중3은 예전generic numeric도통과하던 한계이며,
  84를 모든source변조 E2E거부나 무수량의미·원어민·화면인증으로 과장하지 않는다.
  독립 입력 SHA `48c42884c69d21d3264392bc762a0fcf72012404e497275e9160d94cdf2053f5`.
- 최종 source/response/receipt3쌍·실물276 L1 오류0,
  check/import --accept3 changed_files0. 최종92 records:
  JA `e00008d3055e8c78effda22de551b3c34606a9771906856ac82e8776356fa768`,
  CN `12e286ce7bd817d951a8c819deb8ba906dffee047605ffd3d0302e4abfb10c64`,
  TW `75dd21102f21a9fad6efcd0a214ecb21ddc891500a348b4ea8ca72985323577b`.
  수용24,810 전량 source/target hash·L1, 기존24,534/meta9/b56 보존 PASS다.
- 완료197 WORK_LOG절1,099B만 history 앞으로 원문 이동했다.
  50,432→51,531B SHA
  `dd562e359163754a8fdfade8cad56394c0f2185f4bc0c75c9d1a58d9b828307c`.
  기존 bytes·끝 LF2 유지, 같은 활성 이어보기 [~]·L3 OPEN이다.
- 실제답장/만남·미정일정·용서≠화해·마음속다짐·계좌개설≠매수를 보존했다.
  부모의전세취득/환급효과·야근공유flag 등 원문부채는 번역으로 잇지 않았다.
  KO/EN·runtime·공개·fonts·save·human_gates 변경0, 원본 checkout 쓰기0.
  전체 INCOMPLETE·full/main/product HOLD·원어민/화면 OPEN·출시 데모 GO 유지.
- portable checksum `ab13f4abd1072d92ac7d91f8dddd5b9cc20b94e0396f7e2408996948c5c927e0`.

### 최종 회귀·보존 증거

- named full-game-localization-overlays --list 뒤 선택12 전부 PASS:
  source inventory52·full self204·JA69·ZH6772,
  정적 ERROR0/WARNING0·EN1813/1813+35/35·공개5언어 패리티.
  JA/CN/TW skeleton1047에는 보호된14종도 포함되므로 수용1033종과 분모가 다르다.
- context303·queue63(in_progress61)·diff check PASS.
  실행 stdout은 private `order200-final-checks.log` 4295B,
  SHA `d0516b40fe635e856c833589ee748f078eab0baafa122f340ec9ddeddaa096db`에 보존했다.
  JP-first 글꼴 blocked 경고는 숨기지 않으며 L3를 기계통과로 대체하지 않는다.
- 별도 읽기전용 수용검토30입력은 전후 동일,
  snapshot `1bc85dae79b4b54c0569e90f6d85700ad8995961821602ef97bd9c7969423a02`.
  초기3 source 봉인·최종3쌍·이전원장/메타/기존33/KO/human 보존을 재대조했다.
- full audit.sh·Godot·240주 자동/사람 플레이0. 이 기록은 번역 수용 증거이며 제품 후보 발급이 아니다.
