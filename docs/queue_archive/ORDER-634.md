# ORDER-634 — 몸 신호의 직업·생활·운동 이력 사실 수리

#### [x] ORDER-634 [정합] M41 현재 몸과 실제 루틴 선택 분리 — 2026-10-15

실제M18/612 하나HOLD·새월0·화면접근복구시같은M18 우선.
5언어 유지·KOEN 실제확정전 JAzh다듬기중단/누락만·이번추가누락0.
현재Macreadonly CGSSessionlockedtrue·native재시도/OS설정변경0.

## 근거·깊이 3문

MainGame7480의정확 W161 및8450부근 W163..172 fallback은 직업·식사/수면/운동
이력·증상의최초발생·과거병원기록을읽지않는다. habit producer는 W151..164로
루틴재작성/다음날한시간비움/현재3km달리기 선택이지 '작년' 또는 예방효과가아니다.
KO퇴근길/KOEN전에는없던증상/2시식사/2년운동공백/3년생활과
DIK작년·운동이없었으면더심했음, 결과의첫진료기록/늘지나친식당/하루커피와물/
3년식생활/추가커피를 해당flag가보장하지않는다.
현재몸관찰과 실제선택한기록만 남기며 현재결과의의료/식사/무시행동은유지한다.
삭제하면공통 arc_36_body_signal_seen → W164 body_witness 진입을끊는다.
세outcome의직접독자는 improved_diet → burn_or_light DIK(W204..214),
went_to_hospital/ignored_body → callback_went_hospital_echo/ignored_body_echo(min186)다.
24주뒤 원래flags/건강·정신·현금효과는유지한다. 병원·식사·무시가경쟁한다.

## 정확한 소유

root content/events/arc_midgame.json 및 content/events_en/arc_midgame.json:
arc_36_body_signal description2 + description_if_known3×2 + result_text3×2 =14잎.
base6문단/name배열·DIK각5문단/name0·세result각4문단/name배열을보존한다.
KO만퇴근길을제거해무직/자영업에도같은지하철현재장면을쓸수있게한다.
DIK는 changed=다음날한시간비움/maintained=내일일정재작성/restarted=실제3km선택
회고만; 고정'작년'/연속유지/건강예방인과는추정하지않는다.
현재묘사/실제진료와그결과/식사/결정의불편함은지우지않는다.
제목/choice text/효과/flags/DIK키순서/조건/일정/인물/배경/다른사건/코드/수치/
저장/자산/음악/JAzh/번역원장/project/preset/BuildInfo/공개demo/human불변.
내용지문 실제stale이면 release_content_inventory.json 해당hash와
docs/CONTENT_RATING_INVENTORY.md 실제생성 동일행만 최소정렬한다.
실측 보완: 원 EN의 coffee/water를 'had drunk'라 한 구절이 alcohol의 drunk 검색에
걸려 body_signal을 noise로 세었다. 미보장 하루식사를 제거하자 이오탐이 사라졌다.
현재축만 expected_event_count82→81·observedIDs/contentSHA·noise ID목록1→0 및
같은생성보고의row/noise절을정렬한다. 실제음주/약물fact·다른축·공개demo snapshot 불변.
큐2/이사양/archive/CLAUDE현재행/WORK_LOG/.git/order634-20261015/는root소유.
독립 a1_qa_release_audit는 private review.md/review.json만·추가agent/engine/UI/Git쓰기0.
612월별metadata는이번선언/제품/마감제외·월별한commit계약/모든구raw보존.

## 검증·경계

audit_select --list 후 기존 관련source검사만·전체audit/engine/자연240/새월/새검사0.
14잎 KOEN전수/producer↔reader·전체파일 byte역변환·문단/name·선택효과보존.
KO최종후 officialJA/CN/TW inventory각1회 관측·수용/원고쓰기0.
독립14잎 전수품질/사실판정·sourceGO≠전체장면/chain/월/구저장산문/
native/원어민/인간/물리패드/청취/5언어/출시GO.
기존CJK오래된본문은동결채무로기록하고 검사/기준선을바꿔숨기지않는다.
독자정정: W164를세outcome의직접독자로쓴최초사양은오기로보존하며 위공통seen과구분한다.
후행독자의준비식지속/떨림감소/건강예방단정은별도chain채무다.
W204의'작년'은calendar2029→2030이면성립하므로 M41의동년루틴회상오류로단정하지않는다.
마감context/queue/diff·현황판전용commit0·일회성/새정본승격0.
같은 파일의 여러 JSON leaf patch는 실제 원문 행 순서대로 정렬해 뒤쪽 DIK 뒤에 앞쪽 결과 hunk를 놓지 않는다.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.

## 마감 — 2026-10-15

제품09ab1b0d5591a527e1b1c6a7978888a8738e8e67/treec72383e2adf53de391cac98a75bf404bfd9254f7.
독립14잎전수 GO_SOURCE_ONLY·본문2파일전체역변환/문단/name/DIK순서/효과flags불변.
review.md6340B/c115c481570be94d1ffc79e090424534d1b4437df725dad5e3147e520fba8d28,
review.json6175B/aa15880dd46836266bc7f7302d023c1da1ab9a363c815a01c87dc34bbba9d424 root전문/핀확인.
audit/consistency/spine/i18n각0·EN/한글marker는개별exit미수집·release최초1→오탐정렬뒤0.
원had drunk는coffee/water오탐이므로 alcohol현재축82→81/39·IDs/hash/noise만정렬했다.
다른축/실제음주facts/공개snapshot 불변·검사삭제/기준선약화0.
source/leaf/실패/공식3inventory raw는 .git/order634-20261015/ 보존.
manifest14d0d6ddf6ed2474e9131b28cb84f96a3a9787f2751fd33dd287288148f6c8fc;
current11290/stale108·126·126/전체invalid108·34·34/INCOMPLETE/nativeOPEN·JAzh/원장쓰기0.
도달 경로: 정확W161/구경로163..172·engine/native실행0.
생산자 ↔ 독자: habit151..164의실제3선택 ↔ body_signal DIK3; 공통seen ↔ W164witness.
바꾸는 상태: 산문14잎/선택효과flags/schema before=after.
포기 시 잃는 것: 병원/식사/무시의기존outcome별독자burn/callback·효과는유지.
서사 위치: chapter4.setup; 장면 계층: 기존유지/승격0; 닫는 것: 미보장과거사실14잎한정.
reader원사양오기는별도정정·후행지속식사/증상완화/예방확신은chainHOLD다.
612월별metadatacommit제외·실제M18 하나HOLD/새월0·현재후보CI미확정.
일회성/승격0·다음같은M41 고객전제수리·화면접근복구시동일M18 우선.
