# ORDER-661 — 빈집 엔딩이 하지 않은 다음달 방문 약속을 회상하는 KOEN2잎 수리

#### [x] ORDER-661 [정합] 아버지의 부재는 회수하되 없는 약속·미이행은 만들지 않는다 — 2026-10-15

660 마감 뒤 empty_house/description_if_known/father_passed KOEN2잎만 고친다.
Mac CG세션잠금true·같은M18/612 수정앱실제재검수HOLD·새월0.
5언어유지·KOEN실제확정전 JAzh다듬기중단/누락만·나중일괄정합.

## 근거·깊이 3문

arc_father_04_visit choice3는 father_visit_deferred만 만들고 화해/약속/고백은 만들지않는다.
MainGame:7413 medical공통receipts정상·care_left_open·의료증거<=1이면 W188사망이선택된다.
W185접촉방식은 그 생사계산에포함되지않는다. contact choice1→called choice1은
오늘창원도착못함/다음약속으로덮지않음을 실제로말한다. choice2→missed는
방문·통화불가를답하며 내일반드시하겠다는약속도붙이지않는다.
W188 terminal father_passed·finalweek/peak목표→empty_house·앞DK3false라 사망변주가읽힌다.
next-month promise를생산하지않은위정상경로에도 같은미이행약속회상을보는것이결함이다.
leaf를통째지우면 사망뒤도착한집의 건조한두번째머그/아버지부재 회수를잃는다.
그약속1문장만 지금창밖을아버지와함께볼수없다는공통사실로좁힌다.
방문/연락/기간/약속/미이행/새금액·의료인과를발명하지않는다.
고르지않은접촉·화해·고백/재확약은합류이후도그대로구분되고 DK순서도변하지않는다.

## 소유·검증

root content/endings.json 및 content/endings_en.json:
empty_house/description_if_known/father_passed 각1/총2잎.
원문집/등기/작년겨울/병원사망/머그/부자감정/30억·names·문단newline는보존.
다른leaf/조건/DK순서/endingID/grade/CG/배경/flags/효과/receipt/코드/schema/저장/
JAzh/번역원장/사용자save설정/project.godot/demo/역사human 불변.
실제영향시 release current endingSHA/동일생성보고1셀만정렬·수량ID타축public불변.
큐2/active/archive/CLAUDE현재행/WORK_LOG/.git/order661-20261015/ root소유.
a1_qa_release_audit는 private review.md/json만·제품/Git/engineUI/새agent쓰기0.
612dirty4/WORK_LOGsuffix3555B 모든commit제외·바이트보존.
2잎 fullinverse/parsed/문단newline/name/digits·비소유exact·producer/실제입구/
medicalresult→firsttrue사망변주 정상source반례대조·source조합을actualruntime으로세지않음.
audit_select --list만·audit/consistency/ENcoverage/영어한글/spine/continuity/
ending_money_fact/ending_distinctness/release 표적9·공식JA/CN/TW inventory각1.
동결번역delta는실제raw로읽고불변가정0·다듬기/수용0.
context/queue/diff0·고정제품commit/tree/pins·독립2잎전수 source사실한정.
engine/전체audit/자연240/새checker/비용작업0.
실제M18/엔딩/native/전체부자·의료·경제/카탈로그/5언어/352선행/출시HOLD.
일회성수리/새정본승격0.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.

## 마감 — source 사실 수리 한정

## 2026-10-15 — 빈집 엔딩의 하지 않은 방문 약속 회상 수리

- [661](queue_archive/ORDER-661.md): W185에서 다음 방문 약속을 하지 않은 경로에도 붙던 “다음 달에 꼭 내려가겠다”/미이행 회상을 KO/EN 각 한 문장씩 고쳤다. 지금 아버지와 이 집의 창밖을 함께 볼 수 없다는 사실만 남기고, 집·등기·작년 겨울·병원·머그·금액 및 분기·저장을 보존했다.
- 제품 후보 7dbf21ade6e27171d01a1bddea4a6006c907a549/tree 6498927ebf40150c7760c3e3136329ab22abff2e. 원고2 inverse/parsed/문단·newline·name·digits와 비소유 바이트 exact. 의료증거1→W188 사망/앞 DK3 false 반례4는 source 합성이지 실제 플레이가 아니다. 표적9/공식 inventory3 actual0, selection33은 목록만. release ending SHA와 같은 생성보고1셀만 정렬/수량·ID·타축·public 불변. engine/전체audit/자연240/새checker0.
- manifest 5f9cae7b56cc3efad5ba66a5f527037967b03bb10abf325e5ff70e0225978883. 동결3언어 ending230/235 current·stale4·invalid1, 전체invalid119/48/46·INCOMPLETE/nativeOPEN. 전체 raw 대조는 manifest와 ending current−1/stale+1만/invalid 집합 동일. 다듬기·수용0.
- 독립 GO_SOURCE_FACT_ONLY/2잎 전수. root 전문/spec1/제품4/증거4/raw3/보고2핀 확인: .git/order661-20261015/review.md6719B/b6b8eeac00faf8f09b51d99d848516e72dd56a7fd82dbd6172f7b0249d8a317d; JSON9657B/7d3b442834281010d4e18d936fdd81fdc814d79009169be9a89c847314bd3706.
- 실제M18/엔딩/native/전체부자·의료·경제/카탈로그/5언어/352선행/출시 HOLD. 세션잠금true/실제재시도0·새월0·612dirty4/WORK_LOGsuffix3555B 제외·보존. 비저자 다음24잎 source 사전조사에서 다은 엔딩의 첫 라면·미실행 투자실패·작은예식 회상 후보를 확인 중이며 아직 수리·최종GO가 아니다. 스킬의 표적·독립·보존 절차 적용; 일회성/새정본승격0.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.
