# ORDER-584 — 구저장 월 상황판의 시간·거처·계절 중국어

#### [x] ORDER-584 [현지화] CN/TW42 source/receipt 수용 — 2026-10-13

기준 clean main51f7ab19e20081ec79570bcc3029fb7a654b0e6c/tree
079fbd1dd46dcb6291dcb8a63a4e4b6669c8a231. 현재157 위임의 supported UI 누락을 잇는다.
비저자 탐색으로 MainGame._month_narration:11826–11879의 경과개월5·거처4·
계절12 exact21을 확인했다. 모두 ui_static_context/supported/unprotected·JA존재·
CN/TW부재다. 581 주간 소리/시각과 겹치지 않는다. 실측 한 묶음만 처리한다.

## 깊이·범위·소유

1. 누락을 두면 구저장 AP 월상황판이 영어 fallback으로 남는다.
2. _render_ap_actions:10577 → _week_opening_line:11689 → _month_narration:11757
   → _tr:476/LocaleManager.ui:212 → lines:10615/_type_text:10646이다.
   FullStoryFlow:10578·scene_first:10601 조기반환 및 선행 위기/관계/자산 반환을
   보존하며 정상 본편 노출이나 실제21조건 도달을 주장하지 않는다.
3. 선택·24주 상태·계산·조건 불변이다. KO의 경과/잔여 시간·1.5평·추정/확정·
   관찰의 강도와 %s/문단을 지역별 직접 번역한다. 새 인과/사실은 만들지 않는다.

- root: locale/ui_zh-CN.json·locale/ui_zh-TW.json 해당 새21키씩만;
  content/meta/full_game_localization.json accepted42/checksum/새 UI batch1만.
- root: 큐2·이 사양/마감 archive·WORK_LOG·CLAUDE 현재2행·새 private 실행자료.
- mod_layer_ci: 새 .git/order584-20261013/tw.response.jsonl만 KO 직접 저작.
- manual_save_ci: 같은 새 private의 비저자42 전수 source/receipt 보고만.
- rework_batch_plan: 같은 새 private before/final/보존 보고만.

KO/EN/runtime/JA·조건/게임플레이·project.godot·저장·공개 M01~M06·옛 raw/앱/
seed/인간 판정·retail언어는 비소유다. 새 Blackjack provider/번역은 이번 범위0이다.

## 순서·검증·한계

선언commit/push → immutable before → 공식 exact21 fresh export×2 → KO 직접
CN/TW 분리 저작 → 비저자42 전수 대조 → 공식 check/import --accept×2 →
원official header/digest를 보존한 portable 원장 append → 표적/독립 보존 →
context/queue/diff·마감commit/push → 현재 Git append proof/새CI 한 번 확인이다.
공식 source manifest98664e3985186e7173cfa8cde576aec6136f41f756cf185699d5020cd81177cb는
불변이어야 하며 기존325batch/모든accepted·사전 old members/order/bytes exact다.

기존 selector --list 조회만; ZH all·JA UI·i18n coverage·demo scope all·story demo·
CN/TW official inventory와 기존 ui_translation_append 현 후보 proof를 쓴다.
EN 검사2는 선언 clean 상태 actual0 뒤 KO/EN/runtime exact로 귀속하고 변경 없는
반복0이다. 새 실패0·독립 GO 전 완료0. 새 helper/checker/selftest/등록·엔진/
전체 audit/240주/479·481 후속0이다. 가져오기 정규화는 exact inverse로 복원한다.

gangnamdream-dev/I18N의 KO 직접 저작·소유 보존·source/실관찰 분리를 적용한다.
일회성/승격0·Maclockedtrue·M17/562 HOLD 하나·새월/해제 재요청0이다.
기준51f7 CI38331629727은 정적job success/엔진 audit in_progress, transport500은
원자료 보존 후 한 번 재시도했으며 취소/재실행0이다. 렌더/원어민/인간/물리패드
OPEN·전체 INCOMPLETE·출시 HOLD·종료resource/Presence 잔여를 유지한다.

## 마감 — 구저장 AP 월 상황판 source/receipt42 한정

| 완료 증거 | 측정값 또는 file:line |
|---|---|
| 도달 경로 | MainGame:10577→11689→11757→10615/10646; FullStoryFlow:10578·scene_first:10601 조기반환·실제21조건 관찰0 |
| 생산자 ↔ 독자 | MainGame:11826–11879 KO21 ↔ _tr:476/LocaleManager.ui:212/lookup:475 ↔ locale/ui_zh-CN.json·ui_zh-TW.json |
| 바꾸는 상태 | locale별 static2045→2066/2980·missing935→914·receipted1965→1986; accepted14788→14809·JA13173 불변 |
| 포기 시 잃는 것 | 경과개월5·거처4·계절12의 조건부 월상황판 영어 fallback21/locale |
| 서사 위치 | 기존 legacy/AP 월 상황판; 정상 FullStoryFlow/새 주차/인물/선택·경제 변화0 |
| 장면 계층 | 기존 UI 관찰문 번역; 신규 T1/T2/T3 장면·산문 저작0 |
| 닫는 것 | 공식 check2/import2·표적7·선언시 EN2 actual0·독립 의미/receipt42 GO·제품/비소유 보존 GO; 렌더/native/출시 GO0 |

선언34c2eddb30ccf3e61674193886412420f46b1553/tree
71eb0f9aae8e43e0bc9b4e07f6f6a60838e074b5를 먼저 commit/push했다.
before11/11을 봉인한 뒤 exact21 fresh export×2에서 KO 직접 CN/TW를 분리 저작했다.
CN 첫 초안의 가을 회상1이 과거 발화 장소를 확실한 미래 장소로 바꾸어 배치
REWORK/HOLD였다. cn.initial.response.jsonl에 원21 전체를 보존하고 해당1을
과거 발화/당시 기대로 수리한 뒤 CN21·TW21 전체를 비저자가 다시 대조해 GO42다.
원 REWORK/HOLD와 preimport6693B prefix를 지우거나 과거 GO로 대체하지 않았다.
EN 인접 노출은 공개했으며 중역·간번 변환0이다. 1평반·1/2년·6개월·반년·%s·
잔액의 달라짐/커 보임·익숙해지는 중·felt/hope/might를 보존했다.

공식 check2/import2가 각각 actual0이며 원receipt의 header와 semantic digest를
그대로 batch326에 결속했다. old325batch/모든 oldaccepted·사전 old members/order/
bytes·JA는 불변이다. accepted42·batch1을 추가하고 기존 checksum만
c51b51d3eaba81ff2529377a54544b833fc16d11d74bdd441ad6df2551984f0e로 갱신했다.
root21·JA0/CN21/TW21이며 source34c2·manifest98664는 위 선언과 같다.
receipt semantic digest CN7da13f19e45a8cdf33e3f62e9abe3a371fa0bdb814f0be3645e93f479e85bc1d /
TW66fa9e9aed952117f131d3ebfbdb4698d0e49263f19337b71c5aa49aae89aa46는
raw SHA CNf49d9afcc7f98c5842be0c18c1ce843d8dc4e921b173212e4edc08f19e13afea /
TWd2d5f993ceb83f014a5ea2a780bc9cfd556849204f9326e64c7259d24df3fe0a와 구분한다.

표적7은 ZH all·JA UI·i18n·demo scope all·story demo·CN/TW official after inventory다.
before inventory2/export2도 actual0다. EN2는 선언 clean 시 actual0 뒤 KO/EN/runtime
exact로 귀속하고 재실행0이다. selector33은 --list 조회만이며 selftest/engine/240주0다.
locale별 inventory는 static21 delta 외 전체 JSON exact·invalid[]·source manifest98664
불변이다. unsupported466·source17504·전역 INCOMPLETE/human·native OPEN을 유지한다.
ZH static2066/2980은 전체 중국어 출시 완료가 아니며 bypass11/shipping0도 그대로다.

독립 보존은 제품4 raw inverse·공식receipt42·기존 validate_append·old325/accepted·
보호62그룹1209항목·비소유3367 mode/blob/SHA·old583raw13 exact를 확인했다.
원캡처25/26의 false1은 dirty3만이라는 보조 기대와 실제 dirty6의 불일치다.
제품3 외 변경은 이미 소유한 CLAUDE/큐2뿐이며 같은 캡처에서 분리 정정했다.
원 false는 보존하고 재snapshot0·제품 결함0이며 큐2는 기준51f7 bytes로 복원했다.
마감 metadata·최종 commit의 clean 신원/현재 Git append proof와 새 CI는 별도다.

새 .git/order584-20261013/에만 원자료를 보존했다. before.json은38835B/
SHA1b375aefff2237fb7ad9f6c21f2590aceecfc907ecac122270fdb0a5b2cf1e07,
independent-review.md는10638B/SHAa66ed32d6bfee63996392e582c5acbd9c7662d2ed2a8cc0eda73dfab14cae5f6다.
final.json은26967B/SHA215c394857a41565b7875dfda15c09395707419030cc73cfea616f1413a8ed13,
preservation-review.md는5111B/SHA0a16fe59cd606f3d1ba05d7d8cc30f59ff33d2caa5bbd73cb19b0836ab3ad66c다.
frozen CN은201018B/SHA8fed42aa201f7f2e7b8c80c6f0bd5c3c12056a63d5792b564f58f155086f9b19,
TW201684B/SHA03f9d0aa6c929d2102d5b5633d57c352255c36a595dae7b9bdca462055f71f49,
원장11788337B/SHA9383acd3b35ef5044ae365d91b98a639b6b642c377e4065f79c1b5c93b6bd292다.
preflight/exchange/targeted.actual.json과 inventory-readback에 실제 출력/exit를 결속했다.
transport500/undefined 저장·없는 source context 투영·UTF8 stdin 구성 실패·출력 잘림/
없는 Bank 경로·source hash 보조 투영 오류·metadata 보조 false와 정정 근거는
execution-notes와 독립 보고에 남겼다. 원실패나 원초안을 덮어쓰지 않았다.
보존 JSON의 첫 메모리 조립 structuredClone ReferenceError도 파일쓰기 전0으로
남기고 메모리 복제만 정정했다. 원25/26과 별도metadata 정정 true는 구분한다.

gangnamdream-dev/I18N의 직접 저작·파일 소유 보존·source/실관찰 분리를 적용했다.
일회성/승격0·새helper/checker/등록/selftest/엔진/월0, KO/EN/runtime/JA·조건·저장/
project.godot·공개데모·인간 이력 불변이다. 실제 21조건·렌더/원어민/인간/패드
OPEN·전체 INCOMPLETE·출시 HOLD·M17/562 OS잠금 HOLD 하나·해제 재요청0이다.
기준51f7 CI38331629727은 정적job success/engine audit in_progress였으며
새push CI는 한 번 확인·취소/재실행0·현황판 단독후속0이다.
