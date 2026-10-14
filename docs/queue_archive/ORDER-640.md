# ORDER-640 — 청구서의 실제 결제와 가용 현금 수리

#### [x] ORDER-640 [버그] M46 487300원 송금을 실제 현금과 결속 — 2026-10-15

실제M18/612하나HOLD·새월0·접근복구시동일M18 수정앱우선.
5언어유지·원고/JAzh다듬기/원장수용0. 선택본문은5언어모두불변.

## 근거·깊이 3문

MainGame W181 father alive+unseen/관계만읽으며잔고조건이없다.
bill_night/base·unattached와author_only jiyeon choice0는487300원 송금과원무과영수증을
확정하지만effects0다. GameState.apply_choice는effects.money만현금에반영하며
apply_monthly_pressure는수입/주거/이자만정산하고그청구나paymentflag를읽지않는다.
10만원·무직정상상태에서도결제성공을발명하고충분한잔고도출금하지않는실제결함이다.
CHOICE_CONSEQUENCE_SYSTEM §2 물질상태와월흐름1~4/행동의즉시돈비용을근거로
기존산문의정확한487300원 결제를완성한다. 새가격/융자/자동현금지원/예약시스템0.
지우면payment receipt→W185 father_crisis_contact의3결제회상독자를끊는다.
24주뒤원payment/care flags가남고실제487300원만줄어든다.
결제/자기진료/아버지병동조정이시간경쟁하며후자두선택의효과는불변이다.

## 정확한 소유·구현

root content/events/arc_chapter_themes.json: bill_night, _jiyeon, _unattached
choice0에 effects.money=-487300만추가. 기존텍스트/조건/flags/다른선택/비소유byte불변.
root autoloads/GameState.gd: live2event의원choice0에만한정한pure결제guard를
choice_available에연결. 기존effects정확액/원choice membership·가용whole-won현금/
기존common seen/3outcome flags를검사하여부족잔고/잘못된효과/중복·교차결제를
노출과직접commit양쪽에서거부. 원choice0 identity필수·fractional/NaN/Inf현금거부.
다른event의음수현금/부채/기회/선택계약은변경0·새generic field/API/schema0.
기존apply_effects/add_money로출금1회·paidflag/receipt원경로만사용·신규저장필드0.
이미결제한구저장에는역추징/환불/보정0. frozen replay/저장결과는기존receipt를읽고재결제0.
root tools/StoryChoiceFactCheck.gd: 기존5locale fixture에부족/경계/충분잔고·
원indices/livegallery/직접거부무변경·정확출금/중복거부·구receipt/frozen replay 검사추가.
root tools/chapter4_causal_route_audit.py: 기존m46검증에3원고결제effect exact만추가.
새checker/비용계측/도구최적화/전체audit/240주0. 새시스템이아닌확인된기존송금버그수리.
보호: 모든번역/원장·demo·원save/settings/project/preset/BuildInfo/자산/음악/Human.
큐2/이사양/archive/CLAUDE현재행/WORK_LOG/.git/order640-20261015/ root소유.
독립a1_qa_release_audit private review.md/json만·제품/Git/engine/UI/추가agent쓰기0.
612월별metadata는선언/제품/마감제외·실제월한commit보존.

## 검증·경계

audit_select --list; 기존chapter4/audit/consistency/ENcoverage/영어한글/spine/release/
story_choice_fact_audit + pre-autoload 격리StoryChoiceFactCheck·CompileCheck·
ManualSaveCheck full-story-production-only/ModLayerAudit 표적(지원범위실제확인).
새HOME/3XDG/UUID namespace·실제marker/exit/stdout+Godotlog오류0·사용자파일보존필수.
JSON3effects외역변환·원indices/flags/본문/원monthly불변·월정산에청구재출금0 직접대조.
runtime 준비증거≠실제M46UI/native/자연240/인간/원어민/5언어전체/출시GO.
context/queue/diff통과뒤commit·STATUS전용commit0·일회성/승격0.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.

초기검증수리: author_only 지연ID를제품코드guard에등록하면실제비도달이어도
lifecycle이제품참조로검출하므로그등록을제거했다. 지연은원고effects정합만검사하며
runtime/live2를3으로세지않는다. 숫자는Godot JSON float와정수리터럴의Dictionary
등가차이를피해단일money키/수치type/정확액을직접검증한다. 원실패영수증은보존한다.
독립검수추가: untyped money의문자/불린/배열/객체/null은float변환전에거부한다.
비정상현금반례는정상snapshot→주입→거부/원값관측→현금만복원뒤나머지상태비교를
사용한다. serialize는NaN/Inf를의도적으로거부하므로그함수에비정상값을보내지않는다.

## 마감 — 2026-10-15

제품7080b368363a63cea3869ed2a20dff77c6e3270c/treea138a30d77ecc6af2fc08db2fe89568ace3252ba.
독립GO_PAYMENT_CONTRACT_ONLY·범위내차단0·root전문/5blob/영수증핀확인.
review.md6429B/e4af07e493821b3274e275ef3b959f4ee3c1057eaf13625670d4d137fc5725bd,
review.json7470B/4d575167961901aa2f5bb76954c2c3e832985d421e125a2c3258cde3f6850d02.
도달 경로: MainGame W181→live2; choice_available→StoryMode visible/livegallery/apply_choice 재검사.
생산자 ↔ 독자: 원487300원effects+paidflag ↔ M47 father_crisis_contact 3memory/기존resultreceipt.
바꾸는 상태: 선택0 cash -487300 1회·원flags/choiceindex0; 거부시serialize/cooldown/log/meta 불변.
포기 시 잃는 것: 자기진료/병동조정의원마감·의료2of3는불변.
서사 위치: chapter4 consequence·기존계층/승격0; 닫는것: 무상송금/부족잔고/중복·교차결제.
정적10각0·4fresh격리facts합계8751/Compile69/ManualSaveproduction/ModLayer actual0·양로그오류0·보존true.
source본문/번역/원장/schema불변·author_only지연runtime활성화0·원paid구save역보정0.
초기fail/중간REWORK/짧은wrappermarker실패보존·최종후보전부재검증0·QA완화0.
추가legacybalance명령은범위밖3000×240모델을확인후ownPID14786만중단/exit143·PASS주장/재실행0.
전체balance/모델·자연240/wholechain/native/월/5언어원어민/출시HOLD.
612실제월metadata제외·사용자보호대상불변·일회성/승격0.
