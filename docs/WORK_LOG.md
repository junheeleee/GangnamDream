# WORK_LOG.md — 강남드림 작업 기록

이전 원문 전체는 [2026-09-28 이전 기록](history/WORK_LOG_2026-09-28_pre_order351.md)에 바이트 그대로 보존했다. 2026-09-28 Codex 후반 항목은 [별도 보관본](history/WORK_LOG_2026-09-28_codex_late.md)에 있다.

## 2026-10-03 (Claude — 2장 수첩·5장 "5년" 적용 대기 초안)

- Codex가 PR #31 들이기를 하는 동안 충돌을 피하려고 콘텐츠·원장을 건드리지 않고 문서 초안만 썼다: [PROSE_DRAFT_CH2_CH5_2026-10-03.md](queue_backlog/PROSE_DRAFT_CH2_CH5_2026-10-03.md).
- `arc_year_one_mark`는 공책 두 칸 대신 거래내역 출력지 입금 줄 옆에 이름을 적는 일로, `arc_year2_close`는 배경(눈 내린 주택가 골목)과 어긋난 "책상 위 수첩 세 칸"을 가로등 아래 은행 명세표 뒷면으로 바꿨다. CH2 지시서 51·104행의 끝 논설 삭제도 같은 초안에 넣었다.
- 5장 "5년"은 숫자 대신 고시원·편의점 카운터를 가리키게 했다. 추가로 `hyunsu_year5_call` 첫 줄 "막판이었다. 강남까지 정말 얼마 안 남았다."가 자산 조건 없이 뜨는 사실 결함을 찾아 초안에 넣었다.
- 적용(KO/EN·JA/zh 공식 경로·원장·등급 지문·검사)은 Codex가 들이기 뒤 한 배치로 한다. 검사는 문서 검사만 돌렸다.

## 2026-10-01 (Claude — Codex 부재 중 직접 수리 3배치)

- 사용자 지시("너 스스로 판단하고 개선해야해")로 지시서 항목을 직접 고쳤다. 배치마다 KO/EN → JA·zh 공식 export/check/import → 영수증 → 심의 지문·보고서 → 검사.
- **엔딩 사실(`3643da2b`):** `empty_house`는 살아 있지만 화해하지 않은 아버지 런에서도 열린다. 그래서 기본 본문을 생존 기준으로 바꾸고 사망 문장은 `father_passed` 변형으로 옮겼다. 아버지가 살아 있으면 사망 전제 변형을 건너뛴다(MainGame 6줄). 그 밖에 E3~E11·E13(고시원 고정, 액수, 편의점, 6년, 미뤘던 전화, 부부 존대, 하드코딩)을 고쳤다.
- **4·5장 표기(`65be1dee`):** 청혼 체인의 고정 시점 "5년" 표현, 예식 전 "아내/처가", 연인 확정 뒤 지연의 존대, 연애·공시 기간을 고쳤다. 5장 F1은 판독 오류로 정정했다. 등급 축 sexuality·fear 지문은 연도·호칭만 바뀌어 강도 변화 없이 갱신했다.
- **엔딩 교훈 삭제(이번):** 10엔딩 52문단의 주제문·교훈 줄을 지웠다("더럽게", "충분한 밤", "30억으로도 못 사는" 등). 번역도 같은 줄만 지웠고 언어별 삭제 줄 수가 일치한다.
- **검사:** ending_distinctness·en/i18n·english_hangul·speech_register·multilingual·peak·audit·chapter4/5 경로·release_content_inventory·diff-check PASS. 이 환경에 Godot가 없어 컴파일은 CI가 본다. `zh_translation_audit` KeyError·수용원장 `ui:%d년 차`·`story_graph_contract_audit`의 MainGame 원문 승인(ORDER-390)은 수리 전 브랜치에서도, `ci_localization_reconciliation_self_test`·`chapter5_human_reject_audit`는 main에서도 실패한다. Codex가 들일 때 ORDER-390 승인 이력을 이번 MainGame 6줄과 함께 갱신해야 한다.
- **5장 정점·4장 내부어:** `arc_pre_ending_father_call`의 해설 꼬리 두 곳을 지웠다(대사는 보존). `arc_pre_ending_winter`는 현재형을 과거형으로 바꾸고 교훈 세 줄과 "갚아낸 빚"을 지웠다. `arc_year_three_half`의 계약어와 손상 폴백의 "배타 영수증"은 젖어 번진 메모라는 장면으로 바꿨다. 등급 fear 축 지문을 갱신했다.
- **5장 판정·예고(배치5):** `arc_daeun_final_choice`의 서술자 판정과 현재형, `arc_late_game_push`·`arc_37_ending_peace`의 선택지 예고와 생사 추상어, `arc_minseo_03_arrival`의 계약어("자기 쪽 기록으로만", "반응을 빌리지 않고"), `arc_minseo_03b_not_arrived`의 교훈 두 줄과 "민준" 하드코딩(F10)을 고쳤다. 원격 민서의 무읽음·무답장 사실은 보존했다.
- **4장 계약어(배치6):** `arc_y4_borrowed_name` 3변형의 선택 예고·결산문, `arc_y4_bill_night`·`_unattached`의 다은 대사와 계약어, `arc_y4_year_close_daeun`·`_unattached`의 결산문을 19잎×5언어로 고쳤다. 줄어든 `_document_gap`·`bill_night_unattached`가 `narrative_continuity`의 고립 소장면(420자 이하)에 걸려, 해설을 되살리지 않고 손가락·물컵 같은 감각 묘사로 보강해 통과시켰다. 지연 변형 6개는 F12 판정 대기로 건드리지 않았다.
- **데모 계약 회귀 복구:** 배치1에서 고친 `arc_hyunsu_lifeline_call`("공시 4년 만에")은 `min_turn 9999`라 제품에서 나오지 않는데, 출시 데모가 원문 바이트를 고정한 `arc_events.json` 안에 있어 CI의 데모 현지화 검사 4개(JA_DEMO_INVENTORY·JA_DEMO_AUDIT·DEMO_I18N_SCOPE·_SELF_TEST)를 깼다. 5언어 파일과 영수증 18건을 기준 커밋 `89cb4450`으로 되돌렸다. 앞으로 `arc_events.json`은 건드리지 않는다.
- **4장 계약어·5장 도덕 판정(배치7):** `arc_y4_three_promises`·`_deal_only`, `arc_36_unexpected_hand` 3변형, `arc_y4_body_witness`·`_hyunsu`, `arc_y4_family_*` 비지연 3장면, `arc_year4_close`의 설계 규칙 문장("없는 연인이나 친구의 이름으로", "누구의 반응도 발명되지 않았다", "이 경로에는 파트너를")과 선택 예고를 32잎×5언어로 걷었다. `arc_daeun_the_test`는 "임상철이 됐다"·"발걸음은 가벼웠다"를 지우고, 다은이 첫 장에서 손을 멈췄다가 "괜찮다고 했잖아요"라며 읽지 않기로 하는 장면과 지하철 유리창에 비친 익숙한 웃음으로 바꿨다(4장 F6). 420자 아래로 준 세 장면은 감각 묘사로 보강했다. 등급 축 alcohol("복용표" 토큰) 지문만 갱신했다.
- **얇은 엔딩 재작성(배치8):** `full_circle`·`guardian`·`second_love`·`crypto_ghost`·`writer`의 기본 본문을 지시서 권고대로 다시 썼다(변형은 같은 꼬리 문단을 유지, 11잎×5언어). full_circle은 꺼지는 텔레비전과 공장 기름 밴 손, guardian은 지난 삶에서 들지 못한 짐 가방, second_love는 교훈 줄 대신 설탕 뺀 머그잔과 김 서린 유리, crypto_ghost는 새로고침하는 엄지와 식은 국, writer는 경로 고정 사건 목록과 판매 기록 대신 새벽 3시의 첫 문장으로 바꿨다. 작은따옴표 대사는 큰따옴표로 바꿨다. 라우팅·조건·DIK 키는 그대로이고 엔딩 corpus 지문만 갱신했다.
- **장면 음악 회귀 복구:** 배치7이 `arc_year4_close`의 `arc_y4_midpoint_receipt_seen` 변형을 두 문단으로 줄여, 셋째 문단에 걸린 음악 신호가 사라졌다(CI `SCENE_AUDIO`). 해설을 되살리지 않고 뭉개진 볼펜 자국을 짚는 문단을 넣어 세 문단으로 복구했다(5언어). 앞으로 문단을 지울 때 `scene_audio_contract_check`를 함께 돌린다.
- **4·5장 사실 결함(배치9):** 4장 F9(결혼 견적 결과문 "3천만원이 넘는 돈", 차감 수치 불변)·F10(`arc_y4_father_crisis_stabilized` "민준"→`{name}`)·F11("새벽 12시"→"자정"), 5장 F3(`arc_father_legacy` 선택1 "소리 내어 말했다")·F4("했어요"→"보세요")·F7(`arc_jiyeon_year5_return` 선택 문구를 결과와 일치, "부산 2년")을 5언어에 반영했다(10잎). 5장 F9(`arc_daeun_later_echo`)는 데모 고정 파일 `arc_events.json` 안이라 건너뛰었다. `arc_father_legacy` 본문·회상 3잎은 이번 변경 전부터 수용원장 source 지문이 어긋나 있어(보류 커밋 계열로 추정) 손대지 않았다. CI 실패 목록은 기존과 같다.
- **2·3장 사실 결함(배치10):** 3장 F1(재혁 "군대 선임"→"동기")·F2(현수 공시 "4년"→"여섯 해가 넘는 시험", 제목 포함)·F3(다은 연애 기간 "2년이 넘었다"→"몇 계절", 동거 서술은 ROMANCE 대조 필요로 남김)·F4(지연 첫 만남 "상철의 소개"→"빗길의 사고")·F5(상철을 만나는 곳 "같은 카페"→"같은 사무실, 같은 책상"), 2장 F2("편의점 밖에서 보는 다은"→"약속을 잡고 만나는")·F3("남은 4년"→"남은 시간", 밤의 장소를 편의점 휴게 의자로)를 12잎×5언어에 반영했다. 2장 F1(P0, `arc_jaehyuk_aftermath` 선택지의 `[crossed_line 경로]` 같은 경로명 노출)과 F4(`arc_jiyeon_03_offer`)는 데모 고정 파일 `arc_events.json` 안이라 손대지 못했다. 엄격해진 검증기에 맞춰 zh의 "两个不同的世界"(원문에 없는 수량), JA "三年目"(원문 3년째)도 고쳤다. 등급 sexuality·fear·alcohol 축 지문만 갱신했다(강도 불변).
- **1장(배치11):** F6(`arc_goshiwon_goodbye` 변형의 "30개월"→"고시원의 요령")만 5언어에 반영했다. F1·F3·F4·F7은 데모 고정 파일 `arc_events.json` 안이다. F2(KTX 회상이 `told_dad_okay` 경로의 실제 대사와 다름)는 회상 변형 추가가 노출 상태 계약(`exposed_event_state_contracts`)과 번역 장부 배치 구조를 함께 건드려 Codex 몫으로 남겼다. F5(도달 불가 변형)는 삭제 판정이 필요하다. 등급 sexuality 축 지문만 갱신했다.
- **사용자 판정 3건("권고 3건 진행해"):** DECISIONS 2026-10-01에 기록했다. `instant_legend`의 개발자 목소리 문장은 5언어에서 지웠다(엔딩 corpus 지문 갱신). 지연 변형 author_only 전환과 `later_echo` 선택 조건은 각각 검사 도구 승격 목록·lifecycle 원장·코드 분기와 데모 고정 파일 계약을 함께 바꿔야 해 Codex 복귀 계획 7k로 넘겼다.
- **3장 도덕 해설(사용자 "응"):** `arc_y3_cost_of_knowing`의 선택지 나열·"출처가 깨끗해지는 것은 아니었다", `arc_y3_sangchul_deeper_room`의 자기 승인 문장을 지우고, `arc_35_orthodox_weight`·`_unorthodox_weight`를 분류어("정석의 무게")와 격언 없이 적금 자동이체 알림·새벽 3시 7분의 매도 버튼으로 다시 썼다. 하드코딩 "민준/Minjun" 2곳도 `{name}`으로 바꿨다. 9잎×5언어. 비정석 장면에서 "불안"이 빠져 등급 fear·violence 후보에서 빠졌으므로(사실 항목 참조 없음, violence는 원래 검색 잡음) 두 축의 수·목록 지문과 gambling·sexuality 지문을 갱신했다. `arc_jaehyuk_04b_counter`는 데모 고정 파일이라 7k에 넣었다. CI 대조 실패 집합은 기존 29개 그대로다.
- **남김:** 4장 `_person_deal`은 2026-10-03 사용자 위임으로 판정했다(DECISIONS 2026-10-03: 합치지 않고 다은 경로 DIK·야간 진료 기본 본문·중립 선택문). 구현은 지연 변형·`later_echo`와 함께 Codex 7k다.

## 2026-10-04 (Codex — 인물 Atlas 카드 이미지 돌출 수리)

- [402](queue_archive/ORDER-402.md): 그림크기를 유지한 채 카드만 실제내용 최소높이를
  따르도록 국소8줄 수리. 최초60/내용72/간격−5 → 첫수리64/72/−1 FAIL →
  ready+최소높이신호의 최종72/72/+7 PASS. 초상카드60·그림128×64 유지.
- source1bda1fc2/tree99007ae7,5언어10PNG 전량독립검수·20semantic 이동,
  typed복원5·사용자34파일·2964tracked불변.15.040초, geometry0.
  OS raw/물리/자연Back/confirm/끝경계wrap은 관측하지 않았다.
- focused81/historical0 PASS30.518초; normal13+영향조회1 PASS595.434초.
  영향목록97개 자체를 실행한 것은 아니다. Chapter1 debt8/blocked3/gap24,
  year5 reference_only/invalidated 유지. 전체감사/240주/역사self 반복0.
- before aggregateFAIL·첫제품64px FAIL·자기marker검사FAIL·normal중단143·
  dirty clean-guard 차단을 모두 보존, 실패후소스를 새로 묶어 재관측했다.
- [비저자 보고](agent_reviews/ORDER-402.json)의 exact work_unit만 내부GO.
  EN 배지폭잔여4건은 all_text_fits=false로 남기며 다음403에서 따로 수리한다.
  수용raw41,069/b169·기존159판정/137보고·인간원장·공개GO1/인간OPEN45 보존.
  본편/새packageHOLD, 원어민/인간/물리·B3/B4 미관측/별도잔여. 자동PASS≠출시GO.
- gangnamdream-dev의 격리실행·실패보존·저작/검수분리 적용. 상시규범0/일회성.
  다음403 선언: 축배지 실제글자폭 수용·공유메뉴 회귀, 검증허용집합을 유지한
  새 manifest wrapper의 호출내 중복증명 축소. 외부출시/스토어/지출/법률0.

## 2026-10-03 (Codex — 인물 모달 중국어 배지·연락 불가16값)

- [401](queue_archive/ORDER-401.md): CN/TW8키씩16값을 공식2교환으로 수용.
  각사전1,433→1,441, 원장41,053/b167→41,069/b169, 기존raw 역삭제일치.
  공용 사람축을 좁히던 CN 人物→人을 수용 전에 고치고16값 전수 재검수했다.
- source d3b1079b/tree6f2cb008, 실제1280×800 CN/TW4PNG에8키/locale.
  40bindings·16lookups·8AP술어·8typed복원, 사용자34파일·tracked2962불변.
  22모달노드+별도smallSET2의24font역할/별도glyph111 PASS. smallSET은 실제12px,
  68×22panel/56×18label/글자36×18이며 자연HUD screenshot으로 합치지 않았다.
- 첫런11.297초PASS, 정적11검사+차선조회1 PASS575.374초. 이전400/393 런 반복0,
  역사self/전체감사/240주0. Chapter1 debt8/blocked3/gap24·year5 reference_only 유지.
- [비저자 보고](agent_reviews/ORDER-401.json)의 exact work_unit만 내부GO.
  source/사전 주입·입력·연락/선물/거래/finalizer0. 기존158판정/136보고·인간원장
  불변, 공개GO1·인간OPEN45·본편/새packageHOLD. 자연진입/공유타화면/원어민/인간/
  물리패드·11px/포커스·그림돌출·B3/B4 미관측/별도잔여. 자동PASS는 출시GO가 아니다.
- gangnamdream-dev의 독립검수·표적실행·과거증거보존 적용. 상시규범0/일회성.
  다음402는 실제보인 Atlas카드 돌출만 먼저계측후수리한다. 외부출시/스토어/지출/법률0.

## 2026-10-03 (Codex — 인물 메뉴 중국어 연락·선물·관계 안내64값)

- [400](queue_archive/ORDER-400.md): 한국어 직접 CN/TW32키씩64값을 공식4교환으로
  수용했다. 사전 각1,401→1,433, 원장40,989/b163→41,053/b167. 원본 importer를
  호출하고 byte-preserving apply_patch로 수용했으며 기존값/receipt raw 역삭제일치.
- 고정 f149e67c/tree27196a1c에서 실제MainGame1280×800의 CN/TW4상태씩8PNG.
  locale별25키 화면·7키 실제getter,182bindings·64lookups·24warmth경계와
  typed복원18건·사용자34파일불변. 대상88text노드/96font역할·별도glyph966PASS.
  독립검수자와root가8PNG전량 직접읽음. 전체64값 screenshot주장은 아니다.
- 첫 mixed2화면은 실제 AP주차memoization 때문에 준비불변검사가 실패했다.
  실패8PNG/로그를 보존하고 실제APgetter warmup의 두flag만 허용·기록하도록
  helper만 보강했다. 재관측14.499초, 제품/400고정후tracked·과거393증거 변경0.
- 현행정적11검사+변경차선조회1 PASS(520.257초), source전후2,960파일불변.
  Chapter1 debt8/blocked3/gap24·year5 reference_only/invalidated 잔여보존.
  역사self/전체감사/240주/기존JA화면 재실행0. 자동PASS는 본편GO가 아니다.
- [독립보고](agent_reviews/ORDER-400.json)의 이 work_unit만 내부GO.
  기존157판정/135보고/인간원장·공개GO1/인간OPEN45 보존, 본편/새packageHOLD.
  11px/포커스·network썸네일돌출·영문배지/연락불가사유/동적이름·자연진입/입력·
  원어민/인간/물리·B3/B4 원고는 별도잔여다. raw입력/선물/거래/콜백0.
- gangnamdream-dev의 선행선언·저작/검수분리·표적검수 적용. 상시규범0/일회성.
  다음401은 같은모달에 실제남은8키16값을 선언한다. 외부출시/스토어/지출/법률0.

## 2026-10-03 (Codex — 투자·인물 안내 지역 글꼴과 투자 중국어 검수 마감)

- 393: 실제 Open Sans/외부fallback을 측정한 뒤 normal_font4줄만 연결했다.
  제품d0a7c9c는 Claude ab6f52fe MainGame과 동일. current source dd3f5794,
  tree6c904aeb. 사전/원장/게임/FontKit/공개데모 변경0.
- before4PNG→after16PNG·52font역할·별도glyph1530행·같은label언어전환10,
  typed복원18·실사용자34파일불변. TextServer 별도probe를 내부RichText RID
  관측으로 부르지 않는다. raw입력/거래/콜백0. 독립검수자20PNG전량 직접확인.
- exact Git/raw4줄역삭제 bridge·focused54 PASS 원본로그, current정적13검사+
  조회1 PASS(462.402초/2957tracked불변). Chapter1 debt8/blocked3/gap24와
  year5 reference_only/invalidated 유지. 역사self/전체감사/240주 반복0.
- helper 예약어 parse실패와 JSON float/int 비교실패는 원본보존 후 해당화면만
  재실행했다. 실제 font수치가 맞던 후자는 제품결함이 아니다.
- 391은8값 KO의미/지역문자/인수·원본receipt·CN/TW4상태와KO/EN/JA 투자회귀를
  따로 검수해GO. 392의18dd header를 보존한 current successor결속이며,
  새export/import 재실행0·역사rendered/native OPEN 유지·공식40,989/b163.
- [393](agent_reviews/ORDER-393.json)와 [391](agent_reviews/ORDER-391.json) 각각
  내부work_unit판정만 추가. 기존155판정/133보고/인간원장·공개GO1/인간OPEN45
  보존, 본편/새packageHOLD. 기존11px/focus3px·동적이름·자연입력·원어민/인간/물리
  미관측. 작은 글씨를 가독성승인으로 과장하지 않는다.
- gangnamdream-dev의 선행선언·소유분리·독립검수·표적실행 적용. 상시규범0/일회성.
  과거 로그 두 항목은 바이트 그대로 기존현지화보존본에 이동. 다음400은
  모달32키/CN-TW64값을 선언했고 저작·화면 검수를 분리해 이어간다. 외부권한행사0.

## 2026-10-03 (Codex — Claude 인계 원장·검증 연결 복구)

- [392](queue_archive/ORDER-392.md): 이미 반영된 CN/TW 패드8값을 보존하고
  공식8receipt/2batch만 복구했다.40,981/b161→40,989/b163, 원장 byte는
  Claude `9db4a6e5`와 동일. 기존receipt/JA/원문/게임/공개데모 변경0.
- PR31 최신 return-plan/runbook을 읽고 B3 미수용 시 허용된392-first 경로를
  택했다. 검수 안 된 원고/폰트를 함께 합치지 않았다. 실제 Git18dd 원문 census,
  보존 source rows/공식 header, 현8값/hash/digest/역삭제를 재검증했다.
  이는 새 역사 재검증이지 당시 원본 import 실행/화면 증거의 재발급이 아니다.
- exact PR30 두 부모·실제 main 유입e89·원격원장·복구f5c966a만 고정하고
  일반 append 판정은 유지했다. 미회복/고아/중복/중간 drift를 거절한다.
  focused 작성자 전사86+보강13+최종영향2 PASS; 최신97 전량실행 주장은 없다.
  private `order392-development-evidence.json`에 helper2오류·lane인자거절·
  큐순번FAIL도 구분 보존했다. 순번 수리와 과거 WORK_LOG 손실 없는 이동 완료.
- clean source `f043387a`/tree`909fd3f8` 표적10명령 모두exit0/stderr0,
  452.627초·tracked2,955개 전후불변. 독립검수는8값/전이/반례 전수 및 보호
  2,041경로 불변을 확인해 이 work_unit만GO. 기존154판정/132보고와 인간
  원장은 보존하고 판정1건만 추가했다. 기계PASS는 게임 전체 품질GO가 아니다.
- Chapter1 debt8/blocked3/gap24, year5 reference_only/invalidated, 원형350의
  5언어arc_drama+원장 및351원장 pin 실패는 이전부터의 별도잔여다. 원형검사
  수정/역사self반복/전체감사/240주/엔진0. 공개GO1·인간OPEN45·본편/새packageHOLD.
- 다음 읽기전용 분석: 투자·인물 pad label은 normal_font가 빠졌고 FontKit은
  안정적인 JP/SC/TC 역할객체를 이미 제공한다. 전역theme 선행 없이 로컬 수리
  가능하나 실제font/화면은391 OPEN이다. 투자2줄은391 조건범위, 인물까지4줄은
  별도393 선언이 필요하다. MainGame/source successor와 실제5언어 화면을 묶고,
  인물 CN/TW 미번역·전역font·11px/포커스잘림을 완료로 과장하지 않는다.
- gangnamdream-dev로 선행선언·파일소유분리·독립검수·표적검증. 새 상시규범0,
  계획은일회성. B3/B4 원고와 누적원장은 이후별도검수. 외부출시/스토어/지출/법률0.

## 2026-09-30 (Codex — Claude 원격 인계 보존·미완료 범위 정합)

- 통합 `e89f3ed` 표적 receipt 검사1회 FAIL: `UI/receipt/source/target additions differ: zh-CN`.
  원본 private `order391-upstream-receipt-check.json` 보존. 새 검사 완화/원장위조0.
- 동기화가 거부되어 원격을 읽었고 `0f5852d`/`bdbd10f`의 Claude 인계를 확인했다.
  CN/TW 각4값과 아래 작성자 기록을 그대로 보존한다. 직전 Codex 항목의
  제품 미반영/검사PASS는 원격 수신 전 로컬 후보의 기록이지 현 사전의 증거가 아니다.
- 현 사전8값의 수용원장 추가0, 원본 export/import receipt·8PNG는 이 로컬에
  없다. 인계의 Open Sans primary/한자 fallback 보고만으로 프로젝트 소유
  SC/TC 우선경로를 승인하지 않는다. 현재 값·원문·지역font·receipt 연결은 미완료.
  비저자 검수 사용한도 HOLD, 원문 코드 변경0·새GO0·기존 인간/공개판정 보존.

## 2026-09-30 (Codex — 투자 패드 안내 초안8값·검수 미완료)

- ORDER-391 선언 `18dd16d` main/origin 반영. 한국어 직접 CN/TW4키씩8값 초안,
  source `18dd16d6020b2dcae8484f4b70af3261a6ccd91e` 공식 export/check 각2배치
  PASS. 각 `FULL_LOCALIZATION_BATCH_VALID leaves=4`, 병렬 check7.914초,
  source/response 전후 동일. private `order391-*` 교환·결과 보존.
- 화면 저자/비저자 검수자가 사용한도로 실패했고 9/30 재확인 시 일반 사용 불가.
  반복 위임·리셋/지출0. `gangnamdream-dev`/WORK_UNIT의 독립 검수 조건을
  통과하지 못했으므로 import/accept·코드수리·완료판정0. 실제font/PNG 미관측.
  제품/사전/수용원장/공개데모/사람원장/154판정/132보고 불변, 공식40,981/b161.
- 재개는 원문8값 독립검수와 격리된 실제font 확인부터. 조건부 source수리 시
  별도 sourcecommit·exact proof·새 export 결속 후 수용한다. 이전 실패/초안을
  덮지 않는다. 기존 검사·전체감사·240주 반복0, 공개GO1·인간OPEN45·본편HOLD.
  자동PASS는 계약증거이며 재미·깊이·문체·원어민/인간/물리/출시GO가 아니다.

## 2026-09-29 (Claude — Codex 인계: 투자 패드 안내 중국어 8값)

- Codex 주간 한도 소진으로 사용자 지시에 따라 [391](queue_archive/ORDER-391.md)을 이어받았다. CN/TW 패드 안내 4키×2 = 8값을 공식 export/check/import로 반영했다(`BATCH_VALID leaves=4` ×2). 기존 값 변경0.
- 이 환경에 Godot 4.6.2 공식판을 받아 xvfb로 실제 MainGame 투자 화면 CN/TW 4상태 8PNG를 관측했다. 번역·placeholder 정상, 한자는 fallback으로 두부0이라 사양 조건상 font 코드 수리0.
- `full_game_runtime_trace_audit` 실패는 수정 전 main에서도 재현(무관). 비저자 독립 검수는 없어 GO를 기록하지 않고 큐에 OPEN으로 남겼다. CN/TW 자산명·상단·우측 패널 영어 누출은 기존 미번역 범위로 관측만 했다.

## 2026-09-29 (Codex — 시작 안내 파산 설명·일중 번역)

- 시작 안내 파산 조건 KO/EN1쌍을 빚이 아니라 순자산<-1억원으로 바로잡았다. CN/TW tutorial11키씩22값과 JA 새키1을 한국어 직접 번역했다. 공식40,981/b161·CN/TW UI각1,397. JA구키와 기존UI/receipt raw를 보존했고 GameState·경제·저장·공개데모 변경0.
- 공식 export/check/import 각3배치·23값 독립 원문검수·append 역삭제 PASS. 정적14검사+차선조회1 PASS(839.300초). 실제 tutorial CN/TW 상하단과 KO/EN/JA 수정위험본문7PNG(16.778초)를 관측했고, 초안cache 폭 예비검사와 수용사전cache주입0을 구분했다. exact source successor·current collector·JA구키 보존 반례를 검사했고 변경 없는 역사self·전체감사·240주 반복0. 독립 검수에서 발견한 branch2 ID 재발급을 수리하고 비소유2,950 Entry/blueprint 전량을 보존했다. 개발 중 봉인 실패도 보존했다. 초기CN首周는 숫자검사가 ordinal_week1로 인식하지 못해 원본실패를 보존하고 第1周로 명시, 원배치11값 재검수 및23값 표적재검사PASS; checker완화0. 새 source 경계 focused57반례 PASS. 인과원장 첫 실행420초 timeout을 실패로 보존하고, 동일 clean source에서 해당1명령만720초 상한으로 재실행했다. 위 시간은 첫 묶음과 재실행 합계이며 통과한13검사+조회1은 반복하지 않았다.
- 각 실행 전후 tracked/helper census·실사용자 저장 불변, 준비상태 typed복원·지역 font/glyph/경계 PASS. 거래·새 입력0. 기존153판정 raw prefix/131보고·사람원장·과거실패/GO/HOLD/OPEN을 보존하고 새 work_unit GO1개만 append했다.
- 검사 source `c2e05ead21e56489062fe3a76358e4af5778b2ee`에서 전후 census 동일. 최종 source `c9e88a962fe5ceb103089459420705d3ddf3ab80` tree `960b5d6ee0008dab8fcf86cbbce66372588cac3b`는 CLAUDE 상태 요약만 추가했고 별도 제품 재실행으로 세지 않는다. [독립 검수](agent_reviews/ORDER-390.json) work_unit GO.
- 동적 대출상품명·패드 부모문구·남은 일중 UI와 기존 선택테두리 약3px 잘림은 남았다. 준비 스크롤은 입력 증거가 아니며 후속 언어는 재사용 패널의 커진 높이에서 관측했다. 자연진입 레이아웃/복귀·실제 거래·원어민·인간·물리 미관측. 공개GO1·인간OPEN45·본편/새package HOLD 유지, 전체 번역/출시GO가 아니다.
- gangnamdream-dev의 선행선언·파일 소유분리·비저자 검수·격리/표적검증을 적용했다. 기존 I18N/WORK_UNIT 정본 재사용·상시규범 승격0·이번 모집단/검사계획은 일회성. 외부출시/스토어/지출/법률행위0. 자동PASS는 계약증거이며 재미·깊이·문체·사람GO의 증거가 아니다. 효율 조사에서 Chapter1 정상 경로의 current admission 최소3회 반복(snapshot 및 JobHunt/Aruba 관측)을 읽기 전용으로 확인했다. 시간 비중은 미계측이며 공유 검증 최적화는 이번 범위에 구현하지 않았다.
- 다음은 확인된 패드 부모4키 CN/TW8값과 실제 폰트 경로를 별도 선언한다. normal_font 직접 연결 누락은 코드에서만 확인했으며 실제 표시 결함은 아직 미관측이다. 폰트 수리는 실측 후 판단한다. 동적 대출상품명은 provider가 아직 검증되지 않아 수용을 우회하지 않는다. 완료한 은행등급/시작안내 표본을 반복하지 않고 남은 consumer로 이동한다.

## 2026-09-29 (Codex — 중국어 신용등급·튜토리얼 위험 안내)

- 신용등급4단계와 튜토리얼 위험 제목5키를 CN/TW에서 한국어 직접 번역했다. 새10값, 공식40,958/b158·CN/TW UI각1,386. 신용위험과 종료위험 context를 분리하고 기존 plain보통·투자주의 배지를 보존했다. KO/EN/JA·기존 UI/receipt raw·경제·저장·런타임 변경0.
- 공식 export/check/import 각2배치·10값 전수 독립 의미검수·append 역삭제 PASS. 정적10검사+차선조회1 PASS(372.094초), 변경 없는 self·전체감사·240주 재실행0. 실제 은행4등급·튜토리얼의 지역별5화면, 총10PNG/10목표Label과 별도1~10등급 getter20회(22.763초)를 관측했다. 초안cache 예비폭과 수용사전cache주입0을 구분한다. 최장 검사 선배정 실행시간은 직전411.112초와 별도 기록하며 동일환경 성능보장으로 해석하지 않는다. 최초 static 호출의 잘못된 full SHA 인수는 clean-head guard가 제품검사 시작 전에 거부했다. 원본 order389-static-invocation-failure.json 보존 후 관측 SHA로 정정했으며 제품/검사기 수정과 중복 제품검사0.
- 각 실행 전후 tracked/helper census·실사용자 저장 불변, 준비상태 typed 복원·SC/TC font/glyph/경계 PASS. 거래·새 입력0. 기존152판정 raw prefix/130보고·사람원장·원385 HOLD 및386 timeout/retry와388 closure기대식 실패 원본 보존, 새 work_unit GO1개만 append.
- 검사 source `e7a172df5a358eb4dadc9dc14ecebba28aa9a5b4`에서 전후 census 동일. 최종 source `ecf8ffd708fc6a68762ad0ff2f307f24a1872fc0` tree `00578bd77a4b43e89a503329126393cfce364e4e`는 CLAUDE 상태 요약만 추가했고 별도 제품 재실행으로 세지 않는다. [독립 검수](agent_reviews/ORDER-389.json) work_unit GO.
- 동적 대출상품명·패드 부모문구·레거시 은행/튜토리얼 전체와 기존 선택테두리 약3px 잘림은 미완료다. 준비 스크롤은 입력 증거가 아니며 자연진입/복귀·실제 거래·원어민·인간·물리 미관측. 공개GO1·인간OPEN45·본편/새package HOLD 유지, 전체은행/튜토리얼 완역이나 출시GO가 아니다.
- gangnamdream-dev의 선행선언·파일 소유분리·비저자 검수·격리/표적검증을 적용했다. 기존 I18N/WORK_UNIT 정본 재사용·상시규범 승격0·이번 모집단/검사계획은 일회성. 외부출시/스토어/지출/법률행위0. 자동PASS는 계약증거이며 재미·깊이·문체·사람GO의 증거가 아니다.
- 다음 읽기전용 후보는 MainGame::_show_tutorial의 미수용 CN/TW11키22값이다(389위험제목 제외). 다만 MainGame.gd:6059의 기존 KO/EN/JA 빚 -1억 설명은 GameState.gd:4293~4297의 실제 순자산<-1억 조건과 달라 별도 선언 후 원문/JA 정합 수리를 먼저 해야 한다. 패드4키8값은 RichText 일반폰트 연결 확인을 별도 선언한다. collector는 모두 정적 지원이지만 동적 대출상품명은 여전히 provider 연결이 필요하다. 다음은 이 준비화면을 재사용하여 검수 저작비를 줄인다. 이번 새범위 저작/수리0.

## 2026-09-29 (Codex — 중국어 은행 잔액·월 이율·상환 안내)

- 마감검증 첫 실행은 이력 이동 구분 개행을 두 번 계산해 FAIL했다. 최초 helper/trace를 private `order388-closure-check-first*`로 보존했다. 원문 suffix3,231B가 이미 개행을 포함해 기존 이력102,453B+원문=105,684B와 정확히 같음을 별도 에이전트도 대조했다. 제품/이력 변경 없이 검사기 기대식만 바로잡아 마감검증 재시도 PASS.
- 은행·대출의 월 이율·부채잔액/총한도·신용·AP 무소비·500만원/전액 상환·레버리지 잠금 안내10키를 CN/TW에서 각각 한국어 직접 번역했다. 새20값, 공식40,948/b156·CN/TW UI각1,381. KO/EN/JA·기존 UI/receipt raw·경제·저장·런타임 변경0.
- 공식 export/check/import 각2배치·20값 전수 독립 의미검수·append 역삭제 PASS. 정적10검사+차선조회1 PASS(411.112초), 변경없는 self·전체감사·240주 재실행0. 실제 은행 소비자에서 2지역×잠김/열림4준비상태로10키 union·20lookup·48노드/4PNG를 관측했다(12.890초). 예비cache폭검사와 수용사전cache주입0 실행을 구분했다. 첫장 영향검사가310.887초로 최장이라 다음 배치는 이 항목부터 병렬 배정할 수 있다(검사 생략/성능개선 실측 주장은 아님).
- 각 실행 전후 tracked/helper census·실사용자 저장 불변, 준비상태 전체 typed 복원·SC/TC font/glyph/경계 PASS. 대출/상환/매매·새 입력0. 기존151판정 raw prefix/129보고·사람원장·원385 HOLD 및386 timeout/retry 원본 보존, 새 work_unit GO1개만 append.
- 검사 source `b6945e0e253f73779afde9a9a2df4d93f11dd13d`에서 전후 census 동일. 최종 source `fe3fac7b17057c52974cb6bbc0c1a8beaef4ffee` tree `c62f1151a2f3129ec70be993617933f845d5315e`는 CLAUDE 상태 요약만 추가했고 별도 제품 재실행으로 세지 않는다. [독립 검수](agent_reviews/ORDER-388.json) work_unit GO.
- 동적 대출상품명·신용 형용사·패드 부모문구·레거시 은행 전체와 기존 선택테두리 약3px 잘림은 미완료다. 자연진입/복귀·실제 거래·원어민·인간·물리 미관측. 공개GO1·인간OPEN45·본편/새package HOLD 유지, 전체은행 완역이나 출시GO가 아니다.
- gangnamdream-dev의 선행선언·파일 소유분리·비저자 검수·격리/표적검증을 적용했다. 기존 I18N/WORK_UNIT 정본 재사용·상시규범 승격0·이번 모집단/검사계획은 일회성. 외부출시/스토어/지출/법률행위0. 자동PASS는 계약증거이며 재미·깊이·문체·사람GO의 증거가 아니다.
- 다음 읽기전용 후보는 신용4등급과 튜토리얼 위험 context의 CN/TW10값이다. 보통은 context로 분리하고 위험의 튜토리얼 fallback 영향을 함께 소유해야 한다. 대출상품명2는 동적 get_loan_name의 unverified 소비자라 정확 provider 별도 선언 전 단순 UI append 불가. JA상품명2/CN·TW각6의 명시 사전부재를 완역/모두영어로 세지 않는다(보통은 기존 plain fallback). 새 저작0, 기존 선택테두리 잘림도 별도 국소 수리로 남긴다.

## 2026-09-29 (Codex — 같은 검수의 중복 증명 비용 축소)

- 실제 정상 CLI 1회 76.769초, 이전 보존 baseline 292.847초 대비 73.8% 단축. command/exit/stdout/stderr byte-exact 동일. 단일 관측 비교이며 통제된 반복 benchmark나 실호출 횟수 계측은 아니다.
- 새 focused 25개와 registry/context/queue/diff PASS. 최초 7명령 중 목록조회만 잘못 결합한 옵션으로 exit2/집계false; 원본을 보존하고 조회만 올바른 전용 차선으로 재실행 PASS. 총 8명령=6검사+조회실패1+조회재시도1, 과거 정상 baseline·역사 self/corpus·전체감사·엔진 반복0. 같은 호출의 증명 4→1은 구조와 명시 대역시험 근거이고 실측 호출 횟수로 부르지 않는다.
- 검사 source `ddd544952b717673281cf8067d5dfb215897b0ae` 전후 census 동일. 최종 source `88cad8363125db6c6836dcc5072c95d8d75e0649`는 CLAUDE 상태만 추가했고 재실행으로 세지 않는다. [독립 검수](agent_reviews/ORDER-387.json) work_unit GO.
- 정상 CLI helper만 추가. 원형 validate_model/핀/역사 self 본문 불변, 개별 raw 대조와 호출 간 fresh/중첩·예외 해제 유지. 진입6예외만 fail-closed 대표오류로 반환하고 본문·종료 예외를 감추지 않는다.
- 게임/번역/저장/공개후보 변경0, 수용40,928/b154·CN/TW UI각1,371 유지. 공개GO1·인간OPEN45·본편/새package HOLD. 원어민·인간·물리·새화면/입력 미관측. 남은 일중 UI와 기존 안내 선택테두리 약3px 잘림은 별도 작업으로 남는다.
- 기존150판정 raw prefix/128보고·인간원장·원385 HOLD·386 timeout/retry를 보존하고 새GO1개만 append. 개발스킬의 선행선언·파일분리·독립검수·표적검증 적용, 정본승격0·외부권한행사0. 자동PASS는 계약증거이며 재미·깊이·문체의 증거가 아니다.
- 다음은 읽기전용으로 선별된 CN/TW 은행·대출 UI10키/20값의 별도 선언이다. 신규 번역/실제 화면 관측은 이번 작업에 포함되지 않는다.

## 2026-09-29 (Codex — 거래 안내 잘림 수리와 다섯 언어 자산 이동)

- 선언ebe72d2→제품6dacf74→도구06e95b4. 선택한 상세카드1개와46px 마우스 ↑/↓로 세로공간을 확보했다. 전체자산ID/순환·매매callback·경제는 그대로이며 중복 클릭음만 억제했다. caption의FOCUS_NONE·modal/page/queued삭제가드는 기존 확인키 의미와 오래된 버튼 재진입을 보존한다. 동시2카드비교→한카드상세는 하단안내/매매가시성을 위한 내부판단이다.
- 현재 Git386→382→381의18객체·3전이·정확역상으로 source호환을 결속했다. 원형 함수/핀/self본문은 보존하고 현행focused45를 선택했다. 실제호출좌표/전체KOEN문구/consumer와pre386공식manifest를 구별하며 수용40928/b154·JA/CN/TW사전·원장변경0이다.
- 실제검사source06e95b4:1280×800 22PNG/248node·binding/42lookup/17fixture/5언어 PASS,67.968초. CN/TW원12상태와5언어모든5자산보유+저컨디션첫/끝10화면을 봤다. footer y744..766→627..649/clip740; 새버튼과caption폭·글리프·비중첩도PASS. 비저자22장전수직접검수, root는EN첫/TW거래/JA끝3장을직접대조했다.
- 실제경로에합성주입140건=키20edges+마우스버튼60edges+motion60,pressed30·매매0. 모든자산접근·첫끝순환·중간선택·release추가효과0·돈/AP/보유/이력/registry불변,17fixture전체typed복원과실사용자34파일·sourcecensus불변. 물리패드/원어민/인간·자연진입/복귀·실제정산·pad표시전체는미관측이다.
- 정적최초12명령 중11exit0·ch5하나300초timeout,aggregatefalse를원형보존했다. 이전같은검사가294.917초였으며 제품결함출력은없었다. 다른11/엔진반복없이ch5만420초상한으로단독재실행해292.847초PASS·stderr빈값. 총13명령실행,현재11종검사+조회1·반복1; 과거self·전체감사·240주·새export/import는0. 1장debt8/blocked3/gap24와human pending등기존한계유지.
- 최종상태source는CLAUDE현재행만추가한후독립보고386GO/385-runtime-recheckGO에결속했다. 기존148판정/126보고·원385HOLD/실패·인간원장SHA·공개GO1/인간OPEN45는보존하고현재한정판정2개만append한다. 본편/새packageHOLD와기존guide CTA focus약3px잘림은닫지않는다.
- 다음안전후보는남은은행중국어UI와정상검사중복비용이다. 읽기전용추적상Chapter5가current_source_errors1회+demo JA/CN/TW source_errors3회로큰현재proof를4회열고있다(2082/2201행). 다음별도범위에서호출내fresh_validation_proof공유4→1을검토하며전역cache/검사생략은하지않는다. 성능개선구현·시간측정은아직0이다.
- 개발스킬의선행선언·파일소유분리·비저자검수·격리/표적검증을따랐다. 이번시간제한학습은원래294.917초인검사에300초를둔경계였고실패1개만단독확인했다. 상시규범승격0·범위/모집단일회성,외부출시/스토어/지출/법률행위0. 자동PASS는계약증거이지재미·문체·사람GO가아니다.
