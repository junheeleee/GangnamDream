# WORK_LOG.md — 강남드림 작업 기록

이전 기록은 [검수 재사용 선언 전 보존본](history/WORK_LOG_2026-10-08_pre_order486.md)과 [484~490 보존본](history/WORK_LOG_2026-10-09_pre_order491.md)에 남겼다. 보존본의 상대 링크는 이동 전 경로 기준이며 원문 바이트를 보존했다.

## 2026-10-09 — 중국어 대출·상환 안내32값 수용 (495)

- KO16키·실제 은행/공유 투자17호출의 CN/TW32값을 병렬 저작·비저자 전수 대조해 반영했다. 대출잔액/현금·신용등급 방향·남은 차입 한도·변동금리·원화 음수 위험·금리 precision을 보존했다. 기존 금액 검사 오탐은 별도496에서 먼저 수리하고 정상 문안을 우회하지 않았다. 선언0cda0e4 → 제품6939838e8e9508bfabc559e7f2b9434c3bf6e558 main commit/push 완료다.
- 공식 check/import16씩·원header/SHA2·현재 source/target/committed receipt32·4파일 raw 역상 PASS. accepted42021→42053/batch290→291/UI1894→1910씩·JA불변, legacy1685/2952/context29/29/dynamic150/701로 전체 미완료를 구분했다. 비저자 actual Git current_proof(base6c1d96e→제품6939838)는 transition1/32receipt/배치1·선언Git/current source manifest 일치·blocking0이다.
- EN/Hangul·JA UI·ZH·i18n·multilingual·공개/legacy 데모 영향검사 PASS. [495 완료 사양](queue_archive/ORDER-495.md)에 상세 수용 증거를 남겼다. 개발 스킬의 선선언·독립 저작/검수·기존 원장·영향 검증 적용, 새 도구/형식 보고/판정원장0·새규범0/일회성이다. 원문/runtime/경제/저장/project·공개M01~M06·shipping language·역사 인간판정은 불변이다.
- 직전492 ef97d8c의 실제 CI37889060971 녹색이며 최신 후보는 진행/대기다. Mac잠금으로 실제폭/입력149·457·302 미관찰·원어민/물리패드 OPEN·본편 출시 HOLD다. 이번 수용은 기존 은행 UI 번역이며 신규 StoryMode 기능이나 출시 GO가 아니다.

## 2026-10-09 — 금리 안내를 2만원으로 읽던 금액 검사 경계 수리 (496)

- 495 중국어 은행 문안을 공식 검사하던 중 월 이자를 월 이=2만원으로 읽는 오탐을 발견했다. 가짜 금액을 번역에 넣거나 검사를 끄지 않고, 선행496을 별도 선언735752a 후 제품69c75c4d450efb4f34ae771d082078ffe48d1e4d로 main commit/push했다. 기존 zh_translation_audit.py의 수사/숫자 끝 경계와 embedded self-test1파일만 수정했다.
- 현재 소스 raw매치5잎/실제 금액 변화4잎을 전후 대조했다. 은행 금리2잎의 가짜20,000원 제거, 상철 주거2본문의 쉼표 앞 천/칠십을 보증금1,000만원·월세70만원으로 정확히 검출한다. 일부 callback의 500만원은 그대로다. 해당 사건3잎×CN/TW 기존 번역 errors0, source manifest b7d4a4a0418151a18274c73e702d1e149a91c7a11611bece742b3e143acbd2ea 불변이다. 게임 문구/번역/원장/경제/저장 변경0이다.
- ZH self-test12659·current audit·full localization265·body scope54·등록179·i18n·공개demo·context/queue/diff PASS. 원화 단위·금액 추가/변조·음수 부호 거부를 유지했고 495 공식 check16×2도 정상 문안 그대로 통과했다. 비저자가 별도 구코드와 현재 source, 정상/음수/추가·변조 반례와 실제 최종 Git의 tool-only31+/1-/금지 제품경로diff0을 확인해 한정 GO·blocking0이다.
- [496 완료 사양](queue_archive/ORDER-496.md)에 범위/증거를 남겼다. 개발 스킬의 선선언·실제 실패 재현·영향 검사로 수리했다. 새 검사/이력/계측/재사용 도구·형식 보고/판정원장·예외0·새규범0/일회성이다. 직전492 ef97d8c의 실제 CI37889060971 녹색이며 현재 후속 후보 CI/실제화면·원어민·물리패드·본편 출시 HOLD는 별개다. 495 은행 번역 수용을 재개한다.

## 2026-10-09 — 중국어 V2 결산·옛 저장의 미복원 기록50값 수용 (494)

- 기존 V2 결산25키/31소비자를 CN/TW로 각각 KO 직접 저작·독립 전수 검수했다. 끝낸 일·선택의 대가로 남긴 일·기한이 지난 일을 구분하고, 옛 저장에서 누락된 마지막 선택/연락/종결 현금을 추정하거나 0으로 만들지 않았다. 선언3b47355 → 제품446b9ca3d558f79e17ccc06bd8b29081c1bef48c를 main commit/push했다. UI/원장3파일·신규50값 외 제품 변화0, 신규 StoryMode 기능이나 M60엔딩이 아니다.
- 공식 export/check/import25씩 PASS·현재 source/target/committed receipt50일치/errors0, accepted41971→42021·batch289→290·UI1869→1894씩/JA3055 불변이다. ZH legacy1644→1669/2952·context29/29·dynamic150/701, 전체 INCOMPLETE/원어민 OPEN을 보존했다. 이번 실행의493+494 합계84값이며 기존 번역과 원장 메타/289배치 raw는 불변이다.
- 비저자 phone_independent_review가 KO25/소비자31/번역50·원공식header/SHA2·전후4파일 raw 역상·actual Git current_proof(base2e2f266→제품446b9ca transition1/50receipt/배치1)를 직접 확인해 scope GO·blocking0이다. 선언Git/현재 source manifest b7d4a4a0418151a18274c73e702d1e149a91c7a11611bece742b3e143acbd2ea가 일치한다. 별도 formal 보고/판정원장/새 검사·계측 도구0이다.
- EN/Hangul0·JA UI·ZH skeleton·i18n·multilingual·공개storydemo·legacy demo 영향검사 PASS. 493 이후 바뀐50값만의 영향 검증이며 전체 local audit/엔진240주를 반복하지 않았다. 직전491 마감7df56fd의 실제 CI run37884109402 녹색을 확인했고, 최신492~494는 진행/대기 중이라 현재 main 녹색·출시완료라고 하지 않는다.
- [494 완료 사양](queue_archive/ORDER-494.md)에 수용과 한계를 남겼다. 개발 스킬의 현지화 프로필·선선언·지역 독립 저작·기존 원장·표적 검사 적용, 새규범0/절차 일회성이다. 원문·게임동작·저장·project·공개 M01~M06·shipping language·인간판정은 보존했다. Mac잠금으로 실제 폭/입력149·457·302 미관찰, 원어민/물리패드 OPEN·본편 출시 HOLD다.

## 2026-10-09 — 중국어 문맥 UI17키씩·현재29/29 문맥 분리 수용 (493)

- planner·Holdem·MainGame21소비자의 남은 문맥키17개를 간체/번체 각각 KO 직접 저작·독립 전수 검수했다. 지력은 intelligence, 설정은 홀덤 준비단계, 대기는 자금부족, 인연은 상대 이름 대체값, 기억은 비상호작용 그림 자리표시로 구분했다. 선언eb0e57c → 제품1d90f58cc832e9fcce55ac3093fbf262e4d81ab0를 main commit/push했다. 제품3파일·신규34값 외 원문/런타임/저장/기존 번역0변경이다.
- 공식 export/check/import17씩 PASS·현재 source/target/committed receipt34일치/errors0, accepted41937→41971·batch288→289·UI1852→1869씩/JA3055 불변이다. CN/TW context12→29/29가 닫혔지만 legacy1644/2952·동적150/701·전체 INCOMPLETE는 그대로다. 기존 넓은 source metadata·288배치·일본어와 보호 데모는 보존했다.
- 비저자 phone_independent_review는 KO17/소비자21/번역34, 원공식header2·receipt SHA2와 전후4파일 raw 역상, 실제 Git current_proof(baseef97d8c→제품1d90f58 transition1/34receipt/batch1)를 직접 확인해 scope GO·blocking0을 기록했다. source 선언Git/현재 manifest b7d4a4a0418151a18274c73e702d1e149a91c7a11611bece742b3e143acbd2ea 일치다. 새 formal 보고·판정원장0이다.
- EN/Hangul0·JA UI·ZH skeleton·i18n·multilingual·공개storydemo14/100/121·legacy demo72/467/701 영향검사 PASS. 실제 GitHub CI의 직전491 마감7df56fd는 run37884109402 녹색을 확인했다. 최신492/493 CI는 진행 중이며 이를 녹색으로 선점하지 않는다. 등록 예외0·제품 검사 유지, 전체 local audit/엔진240주/새 검사·계측 도구0이다.
- [493 완료 사양](queue_archive/ORDER-493.md)에 범위/증거/한계를 남겼다. 개발 스킬의 현지화 프로필·선선언·지역 독립 저작·기존 원장·표적 검증을 적용했고 새규범0/절차 일회성이다. Mac 잠금으로 실제 폭/입력149·457·302는 미관찰/OPEN, 원어민·물리패드·본편 출시 HOLD다. 게임원문·shipping language·project.godot·사용자 저장·공개 M01~M06·역사 인간판정은 불변이다.

## 2026-10-09 — 연락 휴대전화의 중국어 안내50값 수용 (492)

- 실제 CommunicationPhone 소비자의 미번역25키를 CN/TW에서 각각 한국어 직접 작성했다. 연락/통화·문자·연락처·지난 대화 기록과 일정 가능 여부를 자기 언어로 읽도록 했다. 기존 V2 전화의 번역이지 StoryMode에 새 휴대전화를 만든 것이 아니다. 선언79f69c0 → 제품061d7b7f6a5b8d334779fb70976982391a7f9174를 main commit/push했다. 제품 파일3개·신규50값, 원문/런타임/기존 번역0변경.
- 병렬 저자와 비저자 전수 문맥 대조에서 TW의 SMS 한정3표현을 찾아 KakaoTalk도 포함하는 訊息으로 수리한 뒤 수용했다. 원 공식 export/check/import 각25 PASS, source/target/receipt50일치·translation_errors0, accepted41887→41937·batch287→288다. UI 사전1827→1852씩/JA3055 불변이며 실제 ZH 정적 coverage는 legacy1644/2952·context12/29다. 전체 번역 INCOMPLETE/원어민 OPEN을 유지했다.
- 기존 ui_translation_append의 명시적 전후4파일 raw 역상·원영수증header/SHA2, 비저자의 실제 Git current_proof(base7df56fd→제품061d7b7 transition1/50추가) PASS. 선언Git와 현재 source manifest b7d4a4a0418151a18274c73e702d1e149a91c7a11611bece742b3e143acbd2ea가 일치하며 옛 UI·원장 metadata/287배치 바이트를 보존했다. source/수용 scope GO·신규 blocker0, 새 formal 보고/판정원장0이다.
- EN/Hangul·JA UI·ZH·i18n·multilingual·공개storydemo·legacy demo 범위 영향검사 PASS. 게임 원문·음악·선택·저장·shipping language·공개 M01~M06·과거 인간 판정·project는 그대로다. 전체 local audit/엔진240주/새 계측·이력 도구0. Mac 잠금으로 화면149/457/302·이번 전화 실제 폭 검수는 미관찰이다. 최신 전체 CI는 아직 확인 중이며 등록 검사 예외0을 녹색/출시 GO로 바꾸지 않는다.
- [492 완료 사양](queue_archive/ORDER-492.md)에 정확한 소비자·수용·한계를 기록했다. 개발 스킬의 현지화 프로필·먼저 선언·지역 독립 저작·기존 원장·표적 검증을 적용했고 새규범0/절차 일회성이다. ORDER-157 전체·실제화면/원어민·물리패드·본편 출시 HOLD는 계속 남는다.

## 2026-10-09 — 상철 추론의 잘못된 직장 기억 수리·등록 검사 예외0 (491)

- 취업 여부와 무관하게 차트를 가르친 현재 동료로 나오던 상철을 실제 첫날 사무소의 커피 제안 기억으로 고쳤다. 선언0df3dfd → KO/EN95d8dd5 → 최종417526178ff0e1c031bf3414f0ecc0463576d8e3을 main commit/push했다. 본문·선택0 결과2잎×5언어10값/5파일 외 raw 변화0. 처음부터 아들임을 안 사실·문서 대조·아버지의 무지·추론 무게와 선택/효과/타이머/플래그/라우팅을 보존했다.
- JA/CN/TW를 KO에서 독립 저작해 공식 export/check/import 각2잎을 수용했다. CN의 커피 반복은 수용 전 수리했다. 현재 원문/번역/official6receipt 일치·translation_errors0, accepted41887 유지/6교정·batch286→287·옛 원장 raw 불변·새 coverage0이다. 전체 INCOMPLETE/원어민·화면 OPEN을 유지했다. release 실제 지문 변화0/기존 원장검사 PASS라 심의 파일은 바꾸지 않았다.
- 혼자 증거를 대조하는 장면에 대사 최소2를 요구하던 기존 검사를 현재 SCENE_TIER에 맞췄다. deduction만 measure 안에서 기존 두 증거 경로·합류·15초 확정/유보·최종 상태·빈 본문/결과 금지를 검사하고 dialogue1/evidence_convergence를 명시한다. 전역 기준·필수PASS·baseline0·다른30개 metric/verdict는 그대로다. strict31/31 PASS, 저자 부정표본34/34·비저자 root14/14 거절(중복 포함/합산 아님). 허구 대사·클릭·새 도구0이다.
- 실제 strict PASS 뒤 KNOWN의 마지막 PEAK1행만 제거해 등록 예외0으로 복귀했다. 기존 CI gate의 빈 표 수용·목록 밖 EN_HANGUL 실패 차단도 확인했다. 제품 검사를 지우거나 정책을 완화하지 않았다. EN/Hangul·서사 연속성·말투·story·음악·EXPOSED·prose recall·overlay/i18n·보호 데모·release 영향 검사 PASS. 전체 audit/엔진240주·새 계측/이력/재사용 도구0, 최신 main 전체 CI는 별도 확인한다.
- 비저자 deduction_contract_author가 실제10값·5파일 raw 역상·한국어와 번역6·공식수용3/현재receipt6·옛원장·known1행 삭제를 직접 검수해 사실/현지화 정합 GO·blocking0. 도구는 비저자 root가 검수했다. 새 formal 보고/판정원장0이다. [491 완료 사양](queue_archive/ORDER-491.md)에 기능·실제 소비자·한계를 기록했다. 개발·장면 스킬의 선선언·진입/지식 확인·최소 수리·표적 검증을 적용했고 새 규범0/절차 일회성이다. Mac 잠금으로 화면149/457/302 재개 미실행, 인간·원어민·물리패드·청취 미관찰·본편 출시 HOLD를 유지한다. 과거 판정·공개 데모·사용자 저장·project는 불변이다.
