# ORDER-636 — 가족 약속의 미성립 고객·체불·입금 사실 수리

#### [~] ORDER-636 [정합] M42 현장 제안과 실제 기록 구분 — 2026-10-15

실제M18/612 하나HOLD·새월0·화면접근복구시같은M18 수정앱 우선.
5언어유지·KOEN실제확정전JAzh다듬기중단/누락만·이번추가누락0.

## 근거·깊이 3문

MainGame7484..7495 W167는아버지생존/body_witness_seen/관계만읽고 직업·고객·체불금을읽지않는다.
family_partner_collision/commitment_none는 live, _jiyeon은author_only reference다.
3원고 모두기존고객과밀린보수를발명하고 선택결과는입금을단정한다.
GameState1954..2110 apply_choice와EventManager458 register_directed_event 및
제품3사건 choices의effects/opportunity/investment/grant_job 부재를직접대조했다.
현장제안은현재새사건으로존재할수있지만 과거고용·체불·확정입금은지원되지않는다.
그제안을지우거나새금액을더하지않고 현재일회성유급모집/선택한출입과보수확인요청만쓴다.
다은경로의결근처리/혼자경로의다른사람보수지급도 근거없는추가사실이라같이수리한다.
지우면공통family_table_seen→W169정산이끊긴다. 24주뒤기존family outcome flags는유지한다.
가족동석/혼자/불참과같은시각의수입기회가경쟁한다. 그러나수치보상은구현되어있지않으므로
이수리는허위확정문만닫고 돈선택의기능완성/전체갈등GO를주장하지않는다.
원기능의확정수입보상부재는미완채무로남기며 임의금액/경제effect/새시스템추가0.
family_table_missed는유급현장에가지않아도family_missed를생산한다.
W169의그flag로보수수령을역추정하지않는다. 현재three_half의보호deal회상에남은
'돈의시각/숫자빨라짐'은M39계약검토만으로지원되지않는별도후행수리다.

## 정확한 소유

root content/events/arc_chapter_themes.json 및 content/events_en/arc_chapter_themes.json만.
각언어9잎: family_partner_collision description/choices0.result_text/choices2.result_text;
_jiyeon description/choices2.result_text;
family_commitment_none description/choices0.result_text/choices1.result_text/choices2.result_text.
KOEN18잎은같은미성립고용/지급전제의coupled1단위다.
현재유급현장제안/5~10시/식탁시간·관계/선택text·동석·부재·취소결과/문단/name/숫자/
조건·일정/모든effects·flags·게임키/이웃바이트를유지한다. reference활성화0.
확정입금/미입금/체불악역/지급실패원인·새직업/새업무시스템/임의금액은발명하지않는다.
family_table_missed·three_half·후행scene·코드/경제/저장/JAzh/번역원장/자산/음악/
project/preset/BuildInfo/사용자설정/공개demo/Human불변.
내용지문실제stale이면 release_content_inventory.json 해당hash와
docs/CONTENT_RATING_INVENTORY.md 실제생성동일행만최소정렬한다.
큐2/이사양/archive/CLAUDE현재행/WORK_LOG/.git/order636-20261015/ root소유.
독립a1_qa_release_audit는private review.md/json만·제품/Git/engine/UI/추가agent쓰기0.
612월별metadata는선언/제품/마감에서제외·월별실제한commit계약보존.

## 검증·경계

audit_select --list 뒤기존chapter4/audit/consistency/ENcoverage/영어한글/spine/release만.
18잎한영전수·2파일byte역변환·문단/name/숫자/선택효과불변·임금효과없음원근거보존.
공식JA/CN/TW inventory각1회최종KO관측·수용0·기존CJK원고동결채무.
독립전수 sourceGO만·금전보상기능/wholechain/월/native/자연240/인간/원어민/패드/청취/출시GO아님.
engine/전체audit/새checker0·마감context/queue/diff·STATUS전용commit0.
일회성/정본승격0. 자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.
