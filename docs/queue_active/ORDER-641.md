# ORDER-641 — 안정 경과의 허위 취소수입과 현금 차감 수리

#### [~] ORDER-641 [정합] M47 현재 시간 행동과 실제 비용 정렬 — 2026-10-15

실제M18/612 하나HOLD·새월0·맥접근복구시동일M18 수정앱우선.
5출시언어유지·KOEN실제확정전JAzh다듬기중단/누락만·이번누락추가0.

## 근거와 판단

MainGame7413 _chapter_four_father_outcome_id/W188는의료2of3와생사/seen만읽는다.
직업/소득/취소가능한확정유급일감 producer/돈영수증0인데 stabilized choice1은
확정수입하나/상대방/일취소를발명하고effects.money=-300000을항상현금에서뺀다.
ORDER131 §배치B22·story_map M47 medical_outcome consequence·story_rules stabilized는
입원안정경과만보장한다. CHOICE_CONSEQUENCE §2/월흐름의실제행동비용을근거로
없는유급일감의실제차감을제거한다. 이를병원수가/송금/예약금/새취소수수료로바꾸지않는다.
직업guard도현재고용만으로특정일감/30만원을증명하지못해선택을부당하게닫으므로0.
독립a1_qa_release_audit의읽기전용설계대조도같은최소수리를권고했다.
사용자위임내기존consequence 고아effect수리이며새시스템/반쪽시스템삭제/새의료거래0.

## 깊이 3문

삭제하면입원안정경과에서전화받을현재시간을선택하는자리를잃으므로장면/선택은유지한다.
24주뒤choice0의지력+1/mental-6/affinity+3과choice1의mental-4/affinity+2 차이는남는다.
두선택별새이름있는장기독자는없어wholechainGO로세지않는다.
현재처방을되읽고연락창구를맡기와,검사시각을달력에비워병동번호무음예외설정이경쟁한다.
생존은기존의료2of3가소유하며이선택/돈을사망·완치의원인으로쓰지않는다.

## 정확한 소유

root content/events/arc_drama.json: arc_y4_father_crisis_stabilized choices1
text/result_text 2잎과effects.money=-300000 키만제거; effects.mental=-4 그대로.
root content/events_en/arc_drama.json: 같은선택text/result_text2잎.
새앞선약속/고용/일상대/확정수입을발명하지않고현재달력·무음예외·검사시각만남긴다.
본문/choice0/다른사건/flags/cast/주차/분기/원문key순서·paragraph/name 불변.
root docs/BALANCE.md: 이선택한정cash -300000→0·다른수치/밴드불변 이유만기록.
root tools/StoryChoiceFactCheck.gd: 기존fixture에5locale×무직/소득0/음수·0·양수cash,
money불변/mental-4/affinity2/입원stage·두flags/choice-index1/직업소득불변,
정상serialize왕복·구receipt/result/동결gallery 무재적용 검증추가.
M46 live2 결제487300원/guard/author_only/parity와기존facts회귀를그대로유지한다.
코드/저장schema/구save환불·역추징/엔딩/직업급여·월고정비/JAzh원고·원장/자산/음악/
project/preset/BuildInfo/공개demo/Human 불변.
release실제stale시해당contenthash+생성동일행만정렬.
큐2/이사양/archive/CLAUDE현재행/WORK_LOG/.git/order641-20261015/ root소유.
독립a1_qa_release_audit는private review.md/json만·제품/Git/engine/UI/추가agent쓰기0.
612월별dirty4는선언/제품/마감제외·월별실제한commit보존.

## 검증과 한계

audit_select --list만·chapter4/audit/consistency/ENcoverage/영어한글/spine/release 표적.
KOEN4잎+KO1효과 외byte역변환·문단/name·다른선택/flags/금액변경단1키대조.
공식3locale inventory 각1회 최종source관측·QA완화/번역수용0.
기존StoryChoiceFactCheck만freshHOME/3XDG/UUID pre-autoload bootstrap로실행.
정확marker/actualexit/stdout+Godotlog오류0·보호파일/전체trackedbyte불변필수.
전체audit/전체balance_check/240주/새checker/최적화0. 과도한검증을다시열지않는다.
독립GO는이source/effect수리한정·전체경제/장기reader/실제M47/구save전체/native/5언어/출시HOLD.
context/queue/diff 통과뒤마감·STATUS전용commit0·일회성/승격0.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.
