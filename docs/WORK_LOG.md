# WORK_LOG.md — 강남드림 작업 기록

이전 원문 전체는 [검수 재사용 선언 전 보존본](history/WORK_LOG_2026-10-08_pre_order486.md)에 바이트 그대로 이동했다. 보존본의 상대 링크는 이동 전 경로 기준이다.

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

## 2026-10-09 — 지금 하지 않는 직장 일을 단정하지 않도록, 현수 방문 장소도 분명하게 (490)

- 아버지 전화 결과의 현재 동료 상철→이미 경험한 사무소 커피 제안, 느린 축적 장면의 급여/퇴근/3년 동일 급여→현재 자동이체·가계부, 현수 전화의 근무→오늘 별일 없음, 합격 방문→현수가 사는 고시원으로 고쳤다. 선언5c48461 → KO/EN9d09b1a → 최종 be3f616b6df1c3a275155e80f7c0db369569e4bb를 main에 올렸다. 5잎×5언어25값/20파일 외 raw 변화0, 선택·효과·조건·라우팅·runtime·저장·공개 데모·project·과거 판정 불변이다.
- 현재 직업을 발명한 원문을 먼저 고쳐 employment3을 억지 등록하지 않았다. person_deal의 기존 관계 변형에 relationship1만 등록했다. 기존 EXPOSED를 실제 재실행해 실패6→0(roots380/exposed531/sensitive523/neutral8)으로 복귀, KNOWN 정확1행만 닫았다. PEAK_CHAIN_EXIT/Codex/만료2026-10-16이 유일한 현재 CI 예외이며 밀도 결함은 남아 있다. 검사 삭제·예외 확대0이다.
- 확정 KO를 각 지역에서 독립 저작해 JA/CN/TW 공식 export/check/import 각5잎·4파일을 수용했다. current source/target/official receipt15 일치·translation_errors0, accepted41887 불변/15교정·batch285→286·native/rendered OPEN·새 coverage0이다. 옛 receipts/전역 metadata를 보존했고 전체 번역은 여전히 INCOMPLETE다. release inventory에서 실제 바뀐 gambling/sexuality/fear 지문3만 갱신하고 기존 보고 생성기로 맞췄다.
- EN coverage/한글 누출·서사 연속성·말투·story consistency·장면 음악·prose recall·번역 overlay·release inventory·보호 데모 검사가 PASS했다. 표적 Python trace는 실제 플레이가 아니다. 독립 manifest_alignment_review가 ingress·KO/번역15·공식수용3·25값 raw 역상·도메인1·지문3을 직접 검수하고 EXPOSED 재실행/known1 삭제까지 최종 GO·blocking0을 확인했다. 새 formal보고·에이전트 판정 원장·전체 감사·엔진240주·도구/계측0이다.
- [490 완료 사양](queue_archive/ORDER-490.md)에 기존 producer/consumer·정확한 범위와 한계를 기록하고 큐는 선언 전 바이트로 복귀한다. 개발 스킬의 선선언·작은 diff·공식 수용·기존 표적 검증을 적용했다. 새 규범0/일회성 절차다. Mac 실제 잠금으로 화면149/457/302 재개 미실행, 원어민/인간/물리패드 미관찰·본편출시 HOLD다. 정리487의 실제 녹색 CI는 보존하되 새 main CI 통과로 확대하지 않는다.

## 2026-10-09 — 살아 있는 장면의 음악·연출 등록을 정상화 (489)

- 이미 제품 진입에서 제외한4장 지연 연인 원고6개가 shipping 음악·연출 intent에 남아 기존 검사3개를 실패시켰다. 선언6cc09a9 뒤 source d0515605c023b8d7cce68a6a07c01373fc2055a5에서 audio rendered_profile와 direction explicit_move에서 같은6개씩만 제외했다. 실제 음악/이미지·원고/5locale·저장·runtime·공개데모·project·판정 이력은 바꾸거나 지우지 않았다.
- 전체 JSON 역상으로 exact6 외 값 변화0. 살아 있는1702사건·전환192·배경101·활동8·엔딩35 계약과 기존 오디오4개 분류는 동일하다. 오디오 전체 생성기는 범위 밖4개도 재분류하므로 쓰지 않았다. author_only6의 package 원고와 weight0/hidden/조건을 유지해 새 서사·선택·연애 진전을 만들지 않는다.
- 오디오 카탈로그·연출 카탈로그·전 구간 연출의 실제 FAIL→PASS를 확인해 KNOWN_FAILURES의 정확3행만 제거했다. 남은 PEAK_CHAIN_EXIT/EXPOSED_STATE_EXIT2와 Codex소유·만료10-16, 제품 검사 자체·CI 목록 밖 빨강은 보존한다. scene_audio_contract·lifecycle declared111/exempt111/product_ingress0·4장 causal promoted19/direct15·현재 release inventory도 PASS. 지문 변화0으로 심의 파일 갱신0.
- 기존 방향·오디오 Python trace 각 routes2/localesko-en/weeks960 PASS는 실기기240주 플레이/청취가 아니다. 전체 감사·엔진·새 검사/계측/재사용 도구0. 독립 manifest_alignment_review가 실제3파일 diff/전체 JSON/현재원고6과 조건을 직접 읽고 제품 검사3개를 재실행해 등록 정합 범위만 GO·blocking0. 새 오더별 formal 보고/판정 원장0.
- context/queue/fixtures25·human open45/done1·diff PASS. [489 완료 사양](queue_archive/ORDER-489.md)에 좁은 수치·consumer와 일회성 절차를 기록했다. 개발 스킬의 선선언·최소 변경·표적 검증·보존 절차를 적용했고 새 규범은 없다. 화면은 실제 Mac잠금으로 재개하지 못했다. 원어민/인간플레이/연속청취/물리패드 미관찰·본편출시 HOLD, 새 main CI 대기다. 남은 사실·정점 원고 결함과 화면 회귀를 완료로 세지 않는다.

## 2026-10-09 — 4장 놓친 일정 선택지를 5개 언어에서 분명하게 (488)

- 플레이어가 ‘지난 주말 가지 못한 곳에 시각을 보낸다’ 대신 ‘그날 놓친 일정의 이번 주 재방문 시각을 잡는다’를 고른다. 다은 약속/무연애 야간진료에 공통인 행동이며 예약 승인·치료·관계 회복을 만들지 않는다. 선언9b4cb67 → KO/EN f13fcd1 → 최종5언어 source1442deb1cb93913031ed5fb5ae6b157ae77fdec3. 선택지 한 잎×5값만 바뀌었고 본문·결과·플래그·조건·효과·순서·라우팅·비소유 raw 변화0이다.
- 기존 공식 export/check/import --accept --replace-existing에서 JA/CN/TW 각1잎·1파일 PASS. 초기 extra-field 응답은 strict FAIL로 거절하고 private에 보존했다. 원 sourcef13fcd1/header/3accepted receipt를 그대로 원장에 결속했다. accepted41887 불변·기존3교정·batch282→285·새 coverage0; 다른41884/옛batch/metadata raw 불변. 기존 collector/overlay/committed receipts가 current source/target3·translation_errors0을 확인했다. 세 지역을 KO에서 직접 검토했고 자동 한자 변환/영어 pivot0이다.
- EN coverage·EN 한글(format52/issues0)·서사 연속성·장면 음악·말투·4장 인과(promoted19/direct15)·prose recall·현재 release inventory·데모 scope·JA demo errors0/ZH skeleton·context/queue/diff PASS. inventory의 INCOMPLETE와 기존 보수적 invalid/unsupported는 유지한다. release inventory 지문 변화0이므로 심의 파일을 갱신하지 않았다. 스케줄러/엔딩/저장 변경0에 맞게 기존 영향 검사만 실행했고 전체 감사/엔진/24주·240주 반복/새 검사·비용 도구0이다.
- 비저자 choice_copy_review가 최종1442deb/기준9b4cb67의5값 전수, 두 경로 소비자, 전체 diff와 원 exchange/accepted receipts3를 직접 읽어 한 잎 품질 GO·blocking0을 확인했다. 새 오더별 formal 보고/판정 원장은 만들지 않는다. [488 완료 사양](queue_archive/ORDER-488.md)에 receipt와 좁은 증거/범위를 남기고 큐/이어보기는 순번만 정렬했다. 개발 스킬이 선선언·파일 소유·공식 번역 수용·표적 검증을 이끌었으며 계속 유효한 규칙은 기존 I18N/WORK_UNIT/DECISIONS 소유, 이번 실행은 일회성이다.
- 자동 게이트는 도달·계약 증거이지 재미·깊이·문체·인간 GO가 아니다. native_reader/human_playtest/physical_controller_feel/실제 화면은 미관찰이다. 기본 본문/결과의 연락창·지난 주말 부채, 공개 데모 GO1, 인간 이력, 본편 출시 HOLD, KNOWN_FAILURES5/만료10-16을 보존한다. 게임 저장·project.godot·arc_events·자산·과거 판정 변화0이다. 앞서 472에서 닫힌 2장 수첩·5장 기간 교정은 반복하지 않았다. 정리487의 실제 green main CI37858051278은 이 새 원문 후보의 CI/출시 GO가 아니다.

## 2026-10-09 — 실제 main CI 녹색·검수 정리 마감 (487)

- 실제 main00eec859470bf69c86cf989b7bbe587f07e2072c/source0af4ca6987aaec94c34d14cd738c2d443f524342의 [CI37858051278](https://github.com/junheeleee/GangnamDream/actions/runs/37858051278)가 2026-10-09T00:38:35Z completed/success다. 정적·밸런스113586904516, Godot·입력·경제113586904198 모두 success·skipped 제품 단계0. 현황 오탐 UID14 수리도 DASHBOARD_FRESH로 실제 확인됐다.
- COMPILE_CHECK_OK total=68; 감사 통과 known_failures=5 allowed_in_ci=True; 목록 밖 실패0. KNOWN_FAILURES의 실제 제품5건은 검사 실행/FAIL 로그·Codex 소유·만료2026-10-16을 보존한다. 이력 전용56삭제·표 선커밋·비제품 근거는 아래 기록과 [전수표](queue_backlog/AUDIT_FAILURE_TRIAGE_2026-10-09.md)에 있으며 Git에서 복구 가능하다. EN 한글·번역 원장·서사·장면 음악·데모·컴파일·저장 검사는 삭제하지 않았다.
- CORE_LOOP_V2_INPUT_OK KOgamepad24주/1640입력·ENkeyboard24주/1646입력, 둘 다 semantic/unknown0·autosave1·title_return1·first_bill1/1/1. SIMRUN_CASH_INTEGRITY_OK24/48/240·SMOKE_ALL_OK. CI의 입력 로그·화면 artifact11587947306(4,712,075byte; digest b5869e6b9b70e2574f7bff41fb9d60a9f000480dd1317d3a25933c3cd58bc665)도 보존됐다. 자동 PASS는 계약 증거이며 재미·깊이·문체나 인간·원어민·물리 패드 관찰을 증명하지 않는다.
- [487 완료 사양](queue_archive/ORDER-487.md)을 아카이브하고 큐 본문/이어보기의 순번만 정렬한다. 기존 L3 상태·문구·판정은 불변. 계속 유효한 규범은 DECISIONS 2026-10-08이 이미 소유하며 이번 파일 소유·표/삭제/마감 절차는 일회성이다. 신규 도구·비용 계측·재사용 후속0; 게임 원문·번역·원장·저장·project.godot·인간 이력 수정0. 개발 스킬의 선선언/제품 보존/표적 검증을 적용했다.
- 다음은 사용자가 지정한 기본 arc_36_unexpected_hand의 모호한 선택지 수리를 별도 선언한다. 준비된 2장 수첩·5장 기간 초안은 완료472를 먼저 대조해 중복 적용하지 않는다. 공개 데모 GO·본편 출시 HOLD·known 제품 결함5건을 유지한다.
- 비저자 cleanup_closure_review가 최종 main/CI 양 job의 실제 로그·56개 삭제/선커밋 표·금지 경로 diff를 직접 대조해 정리 완료의 blocker0을 확인했다. 검수 모집단은894a6c09..00eec859이며 게임/locale/원장/runtime/project/인간·에이전트 판정 이력 diff0이다. 별도 오더별 보고/원장/새 도구는 만들지 않았고 검수 절차 정리의 완료만 판정했다.

## 2026-10-09 — main CI 현황 오탐의 실제 원인 수리 (487, 재검증 대기)

- 실제 [main CI37851130776](https://github.com/junheeleee/GangnamDream/actions/runs/37851130776), source0fb0807/job113564010620이 종료됐다. 정적/밸런스 성공·전체 컴파일68 PASS, audit.sh 집계의 정확 KNOWN_FAILURES5 외 실패는 STATUS_DOC_EXIT 한 건이다. 뒤의 실제입력/240주 시뮬은 이 실패로 skipped이며 완료로 세지 않는다.
- clean detached clone0fb0807에서 기존 Godot4.6.2 첫 import를 실행했다. tracked diff0이지만 기존 QA .gd의 누락 UID14가 untracked로 생겼고 현황의 후보 reason이 바뀌어 DASHBOARD_FRESH→STALE를 재현했다.6305215에서14경로를 먼저 선언한 뒤 실제 엔진 생성 sidecar14만 추가했다. 검사/게임 .gd 수정0·새 tool0·전역 ignore/skip0·현재 후보 resolver와 STATUS 변경 감지 보존이다.
- 같은 UID14를 가진 격리 source31a89cb에서 별도 fresh clone→첫 import exit0/fatal0→tracked0/untracked0→DASHBOARD_FRESH를 확인했다. 기존 UID150+14 중복0·생성 원본과 추가14 바이트 모두 일치. fresh import 로그 SHA c40177b43a39a6fa5efde3564d10c83ed33c765c7d6eb0cfd566d6baa74a7f54, 재import 로그67cd67d9ae319284b7f1f64d0c47172778ec20e95e1f11c68f48cf0aa7189284를 격리 /tmp/gangnam-order487-ci-import.ARKSLI에 보존했다. 실제 게임/사용자 저장/화면·원어민·물리 패드 관찰0이다.
- 비저자 ci_dashboard_review가 dirty 후보 인과와 successor의 tracked baseline/생성 extras 분리를 직접 읽어 이 수리의 blocking0을 확인했다. 새 UID는 새 source 후보이며 과거 GO를 승계하지 않는다. 공개 데모의 exact commit/manifest와 이전 successor는 불변이고 GENERATED_UIDS 계약 변경0이다. 개발 스킬의 선선언·실물 재현·표적 검증을 적용했다.
- context/queue/등록179·diff PASS다. 부팅 예산18000초과2byte를 관측하고 현 상태 문구만 줄여 PASS로 수리했다. 게임 원문·번역·원장·저장·project.godot·인간 이력 변경0, known5의 소유자/만료10-16·제품 검사148flag는 유지한다. 새 source와 생성 STATUS를 main에 올린 뒤 실제 CI 녹색을 확인해야487을 닫는다. 다른 새 오더0·출시 HOLD·일회성이다.

## 2026-10-09 — 이력 검사56개 제거·제품 계약 복구 (487, CI 대기)

- 사용자 지시·DECISIONS 2026-10-08대로 PR32/484 마감 뒤 이 정리만 진행했다. 실패 전수표는 cad6d39에서 먼저 main commit·push했고, 추가 의존 표는214e9d6/f7cdf69/954c04e/476aa68에서 삭제 전에 확정했다. 관측163flag/실패 합집합36을 유지하며 과거22·현재13·release 회복1·미관측127을 혼동하지 않는다.
- 아래56파일을 삭제했다. 모두 닫힌 오더의 특정 Git 부모/전체 source bytes·옛 census·역투영 endpoint 또는 그 계측/호출 수 전용 suite다. **이 검사가 지키던 현재 제품 동작이 없었다.** 실제 UI·숫자/통화·장소·시간·배제·receipt·저장·컴파일·데모 동작은 현재 collector/validator와 generic 부정 테스트에 남겼다. 정확 파일별 근거는 선커밋 [전수표](queue_backlog/AUDIT_FAILURE_TRIAGE_2026-10-09.md)에 있다. 삭제 원본은 Git f7cdf69 이전 이력에서 복구할 수 있다.
- 삭제: tools/order305_demo_source_compat.py
- 삭제: tools/order309_source_compat.py
- 삭제: tools/order310_demo_source_compat.py
- 삭제: tools/order313_source_compat.py
- 삭제: tools/order316_header_source_compat.py
- 삭제: tools/order350_source_compat.py
- 삭제: tools/order351_source_compat.py
- 삭제: tools/order365_ui_receipt_compat.py
- 삭제: tools/order469_source_compat.py
- 삭제: tools/order470_source_compat.py
- 삭제: tools/main_game_locale_history.py
- 삭제: tools/meta_title_locale_history.py
- 삭제: tools/opening_rhythm_history.py
- 삭제: tools/holdem_money_history.py
- 삭제: tools/coffee_encounter_receipt_history.py
- 삭제: tools/coin_call_receipt_history.py
- 삭제: tools/pr31_intake_history.py
- 삭제: tools/market_cycle_label_history.py
- 삭제: tools/wealth_milestone_log_history.py
- 삭제: tools/asset_one_billion_log_history.py
- 삭제: tools/meta_title_locale_history_self_test.py
- 삭제: tools/opening_rhythm_history_self_test.py
- 삭제: tools/meta_title_locale_successor_self_test.py
- 삭제: tools/ci_localization_reconciliation_self_test.py
- 삭제: tools/order469_source_compat_self_test.py
- 삭제: tools/order470_source_compat_self_test.py
- 삭제: tools/coin_call_receipt_history_self_test.py
- 삭제: tools/pr31_intake_history_self_test.py
- 삭제: tools/market_cycle_label_history_self_test.py
- 삭제: tools/wealth_milestone_log_history_self_test.py
- 삭제: tools/history_semantic_scope_self_test.py
- 삭제: tools/pr31_main_proof_scope_check.py
- 삭제: tools/holdem_manifest_proof_scope_self_test.py
- 삭제: tools/chapter5_proof_scope_self_test.py
- 삭제: tools/ui_comparison_memo_self_test.py
- 삭제: tools/chapter1_ui_proof_reuse_check.py
- 삭제: tools/market_cycle_log_audit.py
- 삭제: tools/asset_one_billion_log_audit.py
- 삭제: tools/holdem_money_receipt_check.py
- 삭제: tools/holdem_banner_receipt_check.py
- 삭제: tools/holdem_banner_locale_receipt_check.py
- 삭제: tools/holdem_betting_receipt_check.py
- 삭제: tools/holdem_table_labels_receipt_check.py
- 삭제: tools/holdem_seat_height_receipt_check.py
- 삭제: tools/holdem_card_color_receipt_check.py
- 삭제: tools/holdem_message_pulse_receipt_check.py
- 삭제: tools/holdem_rank_ja_receipt_check.py
- 삭제: tools/holdem_async_receipt_check.py
- 삭제: tools/holdem_hand_net_receipt_check.py
- 삭제: tools/holdem_victory_particle_receipt_check.py
- 삭제: tools/holdem_canvas_width_check.py
- 삭제: tools/meta_title_locale_successor.py
- 삭제: tools/holdem_residual_locale_check.py
- 삭제: tools/ui_receipt_cost_profile.py
- 삭제: tools/ui_receipt_cost_profile_check.py
- 삭제: tools/scalping_phase_focus_receipt_check.py
- audit.sh의 이력 전용15flag/명령만 제거하여 집계163→148이다. audit_scope의 폐지 tool·old CLI/paths/비용 차선을 정리했으며 등록182/현재 target 누락0/삭제 helper 소비자0이다. 비용 계측·재사용 후속 작업0·다른 새 오더0·새 tool/report/history helper0.
- strict duplicate/NaN/Infinity/1e999 거절·UTF-8 문자 좌표 span·raw exact inverse·공식 source/target/header/batch binding은 기존 ui_translation_append owner로 보존했다. demo manifest 원 SHA·72 사건/467잎·40769 현재 text와 사건 전체 효과/조건 순서 semantic seal을 유지하며 out-of-demo 원문 공백만 비고정이다. 불변 공개14/100잎·reuse8/3지역 source/target seal도 유지한다. old public target값 재현과 공식 receipt가 원래 없는 보호 baseline을 새 원장 수용으로 둔갑시키지 않았다.
- 현재 표적 PASS: UI append109·strict span/parser168·generic projection88, trace187+현재 계약, demo16+62, full-game localization265, JA collector76/UI2952+context29/demo72·467, ZH12623, full-body54, graph64/Year5 22/Chapter5 76, Chapter1현재24/48 및12부정(48주 완성 아님), facts first-win19/ending10/night13/loss gate50+numeric52/hold24/wealth15/recall27/coffee88, gate companion50, gift18/new-run47/notice17/header23, width27/reaction23/log23/AP42. feature liveness는 실제 생성 QA scene 경로를 발견하여 known orphan2를 보존했다. EN coverage/한글누출(형식52·오류0)/narrative continuity/context/queue/diff PASS다.
- 통합 중 실제 실패도 남긴다: trace의 ObjectDB negative를 false branch로 감싼 변조가 accepted되어 current top-level3 probe 의미 guard로 수리했다(전체 audit.sh SHA 재도입0). 새 English registry가 삭제되면서 format2 호출을 놓친 FAIL은 현행2 system-log 소비자 registry를 복원해 오류0으로 닫았다. localization265의 fake UI fixture errors/entries 누락과 coffee 옛 title fixture 충돌은 현재 interface/비소유 synthetic case로 고쳤고 최종265 PASS다. 게임 원문/번역/원장으로 실패를 덮지 않았다.
- docs/KNOWN_FAILURES.md에는 현재 실제 제품 FAIL5만 이유·Codex 소유·2026-10-16 만료로 남긴다. 검사 자체는 실행/FAIL 로그 보존하며 CI opt-in에서만 정확 exit1을 비차단 처리한다. 미설정/exit2+/미등록/중복/빈 사유·소유자/만료/30일초과는 빨강이다. inline gate 부정14 PASS·shell binding/syntax PASS다. 컴파일/EN/원장/서사/음악/데모/저장 검사 삭제0.
- 비저자 causality_audits_author가 root의 gate/CI/demo/strict append를 직접 읽어 blocking0, 저자들도 분리 소유 파일의 현재 부정 테스트를 확인했다. 새 비용 보고/오더별 봉인 보고 대신 이 기록에 근거를 남긴다. 게임·locale·ledger·autoload/scenes/systems·project.godot·human_gates diff0; 로컬 engine/사용자 저장 접근0·원어민/화면/물리 패드 관찰0.
- **정리는 아직 진행 중이다.** 이 source를 main에 올린 뒤 실제 전체 main CI 녹색(정확 KNOWN_FAILURES 제외)을 확인해야 닫는다. 로컬 표적 PASS를 CI/출시 GO로 바꾸지 않는다. 공개 GO와 인간 이력·본편 HOLD를 보존한다. 다음 문장 묶음의 기본 arc_36_unexpected_hand 선택지 수리는 정리 완료 뒤에만 진행한다.
- 마지막 등록 읽기 검수 localization_collector_author가 실사 당시223개 고유 명령의 옵션/수동 argv를 확인했다. 폐지 inventory-history 옵션2곳과 closed408 재사용 suite를 추가 제거했다. strict JSON과 실제 대화 이력은 삭제 대상이 아니다.
- 일반 이름까지 등록 Python120개를 전수 실사해 closed478 market/482 1B의 fixed parent/raw/current==committed suite2를 추가 제거했다. 두 실제 엔진 fixture와 현재 경제/언어/순자산/원장 검사는 보존한다. 혼합 Holdem tutorial은 과거 선언 raw pin만 제거하고 실제4잎 파서·도달·lookup·숫자/BBCode/카드분류187 PASS/원문 및 원장 무변경을 확인했다. 최종 유효 등록179/삭제 경로 참조0이다. source7ec060a와 wrapper145c131의 CI 정적/밸런스는 실제 성공, 전체 감사/입력/240주/컴파일은 아직 실행 중이며 최종 source 뒤 실제 CI를 확인한다.

## 2026-10-09 — 카지노 용어집 중국어 실제 반영·검수 정리 착수 (484 마감, 487 선언)

- 카지노 용어16개를 한국어에서 각 지역으로 옮긴 CN/TW32값과 원공식 receipt2를 main faa71588579d52e5f145b68b313f86d4e4523ec6/tree246f8162830e4290637b017d449081358fcbbe26에 commit·push했다. UI1811→1827씩/원장41855→41887/b280→282다. 기존 pure validate_append가 UI/receipt 대응·원 header/receipt checksum·이전 members/order/raw 역상·JA0을 통과했고 원 source213 SHA는 불변이다. 원값 수동 교체·원공식 collector 대체·새 history helper0이다.
- 도달 경로: actual CASINO_GLOSSARY_CHECK_OK locales=2 translation=32 overlay_reentry=2 singleton_restore=2 prepared_component_only=true. 생산자↔독자: JeongseonCasino.gd:831/63↔LocaleManager.gd:150↔locale/ui_zh-CN.json:1814·ui_zh-TW.json:1814. 바꾸는 상태: 선택16키×2의 영어 fallback→지역 lookup/actual node32 일치·miss0. 포기 시 잃는 것: 선택16 용어·원화·배당/손실 설명의 지역어 표면(주차/게임 상태 변화0). 서사 위치: 선택적 카지노 UI·월 beat 없음. 장면 계층: 보조 UI, 신규 T1/T2/T3 원고0. 닫는 것: source/UI32·준비 컴포넌트36; natural KO/JA2·JA 신규수용0·화면/입력/자연플레이/원어민 OPEN.
- 실제 engine은 기존 prepared fixture와 fresh pre-autoload namespace만 사용했다. exit0·정확 marker·stdout/Godot log fatal0, translation32/reentry2/locale6+game/meta restore2 PASS다. private consumer1 stdout/Godot log SHA b79721b9ba9115634155d0b1638227937587f42964094c2c8ae82f474819ddb8/stderr0. 실제 UI32의 private 원 receipt 파일 SHA CN6acfbec32962632e44ba18c6562d5cd72bcfd475fb5e02f17f12a13266a9ef41/TWd69c38fc6d82f7e271a1948ccc58d36e74c622cfe8881cbcaaeb49c89fd8cd5f를 worktree 제거 전에 main private에 보존했다.
- 비저자 /root/glossary_preexport_review가 실제 main3파일·원 receipt32/b2·새 로그36을 직접 읽어 source/UI 한정 마감 결함0으로 판단했다. /root/translation_status_readonly는 고정482 admission→옛40767 demo 기대값 fallback과 빈 UI stats→KeyError의 인과를 코드로 확인했다. 새 per-order 보고/자가 인간 판정0이며 WORK_LOG에 현재 범위와 한계를 남긴다.
- EN/한글누출·context·diff는 PASS다. JA_UI·JA_DEMO_PIPELINE·JA_DEMO_AUDIT·ZH_DEMO_AUDIT·DEMO_I18N_SCOPE는 실제 exit1/FAIL5다. 종료 tool 응답의 보존본(원 로그 자체 아님)은 private targeted-checks1.json SHA5e237ba1687e4b95653d441a22138923ea41f3db0b70439678b46a67eda23e81이다. 신규 source/UI가 게임을 깨뜨린 증거가 아니라 닫힌 source/UI 전체 핀이 새 append를 거부한 실패이며, FAIL을 PASS로 바꾸지 않는다. 전체CI NOT_GREEN/HOLD와 제품 검사 보존·복구를 바로 다음 [487](queue_active/ORDER-487.md)에 이관한다.
- 최신 승인대로 [484 완료 사양](queue_archive/ORDER-484.md)을 보존하고 단일 검수 정리를 선언한다. 상시 실패 전수표를 먼저 커밋하고 다음 커밋에서 이력 전용 검사를 삭제한다. 지금 삭제0/새 비용 도구0/다른 새 오더0이다. 모든 실행 지시 일회성·새 규범0. 자동 게이트는 도달 가능성과 계약 증거이지 재미·깊이·문체·인간 GO가 아니다. 공개 GO1/과거 인간/원어민/물리·본편출시 HOLD는 불변이다.

## 2026-10-09 — PR #32 적용·카지노 번역 마감 경로 정리 (484, 진행)

- 사용자 승인 문서만의 PR #32를 main b81d2b0에 합쳤다(DECISIONS 추가19줄/다른 파일0). 원484 live guard가 끝난 뒤 로컬도 fast-forward했다. 원문 export6는 실제 CN/TW exit0·원main/collect2·지역별16잎·UI3478/errors0·동일17505잎 지문·passed/preserved/observer복원true다. 원결과/옛 실패는 `.git/order484-20261008.QsF61I/preexport6/`에 보존한다. 아직 check/import·32값 수용·실제 화면 완료가 아니다.
- 새 결정대로 미구현 history helper5 연결·새 전용 self CLI·오더별 검수 보고 계획을 중단했다. 기존 helper의 current 핀은 CN 한 지역만 import해도 다음 TW 원collector를 거부하므로, 같은 제품 후보의 독립 지역 checkout에서 기존 원공식 check/import를 수행한 뒤 UI2·실제 영수증2만 함께 반영한다. 원collector·target hash·제품 검증은 바꾸지 않으며 새 비용 도구를 만들지 않는다. 강남드림 개발 스킬의 소유 선언·표적 검증 원칙에 최신 사용자 결정을 우선 적용했다.
- 484 뒤에는 상시 실패 표를 먼저 커밋하는 검수 정리 오더 하나만 연다. 479·481 및 계측/재사용/시간단축 후속은 중단하고 정리 완료까지 다른 새 오더0이다. 기본 arc_36_unexpected_hand 선택지의 "지난 주말 가지 못한 곳"은 이후 문장 묶음에 포함한다. 원어민·인간·물리 패드·본편/출시 판정은 갱신하지 않았다.

## 2026-10-08 — 번역 검수의 순수 계산 재사용 (486, 완료)

- 수리 B/F와 새 검사/차선만 구현했다. 준비1/2 각각295·원body/pin 보존·실제2의44 PASS다. 실제2는 B/F 원 _read_proof를 각arm2번씩 직접 호출해 전 proof 동일, Git/typed/제품disk 횟수 동일을 확인했다. 선택묶음180.111422→117.587582초, B receipt26→1·F product18→9/receipt2→1이며 추가 module-binding read B52→107/F4→193은 숨기지 않는다. 전체 pipeline 단축률/공식 수용/게임 관찰은0이다.
- 원 actual1은 측정wrapper를 arm별로 새 정의한 정적 결함을 발견해 own child53173 SIGINT로204.155784초 뒤 종료했다. 실제6등가check는 모두true·fatalKeyboardInterrupt·measurementsnull/exit1/preservedtrue다. 예상 F binding 불일치를 실제FAIL로 관측했다고 쓰지 않는다. 측정기는 동일wrapper1회 설치/계수dict만 교체로 수리해 full proof equality를 유지했고 다음actual2가384.389250초/exit0/preservedtrue로 끝났다. 중단원본/실패를 덮어쓰지 않았다.
- private `.git/order486-20261008.YiW24K/`: roster SHA162fe9d03aae4e3eaf5c035b9a9cfaf2de64b782aa6309795b9b0f16e88ef415; prepared2 SHAbe1cbed0fd8afa3adbd58087d02ea8071ed4738fd34a3437d98374dc3a9faa5d; static1 SHA30ae16a6f6f7e3fd507d966acbf40f033c2adf28e15c3eef84ad05d01e1944ca; actual1 SHAbe07f22b81b2b6478a29653b820cd96e980b58c76740e56480c2861c0e172217; actual2 SHAce70a8a89eabbe94ae809bdea1663aa976b28b72d803e73605efe0c98663cceb. 전 실행 HEAD ac0ddc22+소유dirty/3256파일·status·HEAD/tree·명부/runner 전후 동일이며 외부player/seed 전량 실측이 아니다. engine 접근/실행0. 등록219/명시4목록/context/queue PASS, 이 구현시점에는 clean source 후보와 독립 최종 판정이 대기였고 다음 기록에서 마감했다.
- source940ad0bf3250bfae64f3d9ec00ff319da0343e35/tree6e15bc346459c7d4503d00d76fbfebf3bee42b83를 main commit·push했다. 구현4의 QA snapshot/disk/commit SHA 동일을 비저자가 직접 확인했고 clean 후보 재실행0이다. [독립 보고](agent_reviews/ORDER-486.json) SHA64b6b993566c6f759a231b0e30dc5780b92a37210ec225a4db9e20c93c91d43b의 blocking0/work_unit 한정GO를 별도 agent 원장에 결속하고 [완료 사양](queue_archive/ORDER-486.md)을 보존한다. 모든 실행지시 일회성/새규범0, 게임·원어민·공식수용·출시GO 아님. source commit 후 STATUS stale는 후보신원 변화로 보존·재생성한다.
- 원484 preexport5는 own PID18332 SIGINT 뒤 wrapper1/3950.184972초·원main/collect/UI진입1씩·유효collect/export/수용0·보존/observer복원true로 종료했다. 원결과SHA51851de6e81b756f430e269da90244d724d038c08e6b9524883edb4c099e6223과 옛1~4는 그대로다. None 반환1을 성공 수집으로 세지 않는다. 새private pre_export6는 원 main 작업별 cold B/F owner만 감싸 원export2를 재개한다. 원operation/observer·입출구/protected 보존과 종료clear/token복원을 요구하며 연결 실제관찰은486한정GO에 포함하지 않는다.
- 한 시간의 대기와 반복 역사 계산을 실제로 부딪혔으므로 B/F의 성공한 순수 계산만 동기 작업1회 안에서 재사용한다. 원 Git/disk/HEAD/config 입출구·실제 main/collect 횟수·오류/예외 거절을 보존한다. 비저자 설계 조사에서 부분 호출 배수만 확인했으며 전체 병목/시간 기여율·속도 향상은 미측정이다. 강남드림 개발 스킬의 선언·표적·독립/인간 분리를 적용한다. 제품/번역/수용0·새규범0/일회성.
