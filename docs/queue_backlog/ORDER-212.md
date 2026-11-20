# Active Queue Spec: ORDER-212

> [~] 착수 — 만지는 파일: 아래 소유 범위의 번역6·portable·큐·결과 문서와 표적 검사. 선언 전 기준 제품·원문·대상 부재를 다시 확인했다.

#### [~] ORDER-212 [P0·전체 현지화] 선택의 나비효과·친절의 연쇄

기준 제품: e87f6782acdafa3bcb06c0639099d1914ab4ca6f. 계획 기준은 수용32,052(각10,684)/b77/meta9.
공개 M01~M06 BUILD2026.08.31.1 사용자 GO와 전체 INCOMPLETE/HOLD,
L3·원어민·화면 OPEN을 유지한다. 이 사양의 수량은 출시 완료 판정이 아니다.

## 깊이 3문

1. 먼저 보낸 연락, 실제 응답, 상호 수락, 만남과 거래의 성립을 원문 단계만큼 옮긴다.
2. 큰 결과로 이어지는 작은 선택의 감각과 수치·시간·상대의 역할을 구분한다.
3. 후속 회상과 앞 장면이 다르면 번역에서 새 관계·새 직장·연락처를 만들어 연결하지 않는다.

## 배치 A — 24종144문구

butterfly_events.json의 11종:

- butterfly_mystery_info_offer
- butterfly_mystery_info_details
- butterfly_mystery_info_result_win
- butterfly_mystery_info_result_scam
- butterfly_drunk_investor
- butterfly_drunk_investor_callback
- butterfly_resume_lie
- butterfly_resume_lie_caught
- butterfly_usb_found
- butterfly_usb_dilemma
- butterfly_old_contact

chain_events.json의 13종:

- chain_banchan_reunion
- chain_banchan_reunion_declined
- chain_banchan_son
- chain_exec_meal
- chain_exec_meal_arrival
- chain_exec_interview
- chain_envelope_owner_return
- chain_interior_offer
- chain_envelope_guilt
- chain_neighbor_moving
- chain_neighbor_civil_servant
- chain_celeb_return
- chain_scammer_again

24종144leaf·48선택·LF439/name33. 세 언어432문구를 직접 저작한다.
KO 상대순서·선택·구조를 보존하는 text-only overlay6만 신규 작성한다.
계획 완료 수용32,484(각10,828)/b78, 사건1,444종9,760문구/locale.
비보호 미작성은250종1,818문구/locale로 줄어들 계획이며 UI·표시 소비자는 별도다.

| KO 원문 | bytes | SHA256 |
|---|---:|---|
| content/events/butterfly_events.json | 18039 | 155fa963fc64c1a582c445a1fb91920dc991c39829ad5d2b54e6332158f9efdb |
| content/events/chain_events.json | 26254 | c6cfd30506bab0ac544b0d4c1291e9d812be03c53765d3e978d42c26523088bc |

aggregate a8066ecadcae839f749260a46be5a9f0b5c7582d4b774acbeae10de347ddbe47
는 선언 직전 수집기로 다시 확인한다. 원문 파일·집계의 정본은 수집 결과다.

## 연결과 사실 경계

ROOT는 KO2 전량, 독립 담당은 KO24와 외부35종·엔딩2종을 읽었다.
내부 edge8(직접2·deferred6), 출력43slot/39flag.
외부 ingress8slot/부모5/대상7은 8주 뒤 연결이다.
조건 독자29/23flag, final_last_winter known11, ending known2,
외부 공유생산자 envelope_returned_late 1을 확인했다.
정적 min_turn은 앞 사건 이후 경과 시간으로 해석하지 않는다.

1. mystery: 익명 남자의 사업 인가 예고와 50만원 정보 구매를 구분한다.
   듣기만 하는 선택에서 구매를 만들지 않는다. 성공 가지의 800만원/원금16배는
   실제 투자 진입 설명이 없는 원문 부채다. 정보가 맞지만 투자하지 않은 가지는 수익0이다.
   사기 가지의 경찰서 진술·추적 어려움·낮은 환급 가능성은 실제 검거나 환급이 아니다.
2. drunk: 50대 익명 사업가는 portrait 키만으로 상철이라 부르지 않는다.
   명함 수령과 두 잔 추가를 보존한다. 콜백 도입은 문자 발신→30분 뒤 수신이고,
   연락하지 않겠다는 선택이 뒤에 있는 역전은 원문 그대로 둔다.
3. resume: 적은 TOEIC900과 실제745를 바꾸지 않는다. 정정 제출은 면접 결과 미정,
   허위 제출은 서류 통과·면접 예정이다. 자백 뒤 권고사직 산문과 job 제거 효과 부재를
   재고용 설명으로 메우지 않는다. 위조 제출 통과는 원문이 성립시킨 범위다.
4. USB: 실제 열람과 총무팀 반환 가지를 구분한다. 경쟁사가 원하는 자료와
   경쟁사30% 낮은 단가의 귀속을 임의로 합치지 않는다. 법무팀에 전달한 결과는
   공개되지 않았으며 외부 직원 징계를 현재 장면에 앞당기지 않는다.
5. old_contact: 답장 뒤 한 달1~2회 연락은 실제이나 만나고 싶다는 생각은 대면이 아니다.
   무응답 가지의 SNS 관찰·좋아요 없이 닫기를 보존한다.
6. banchan: 반찬 구매/무료 수령·반값·매주 방문과 단골 관계만 성립한다.
   아들이 준 명함→실제 이력서 발송→면접 연락과 일시 수령까지이며 취업 확정은 없다.
   명함만 받는 선택은 번호를 저장하지 않는다.
7. wallet: 반환8주 뒤 식사 초대는 처음에는 날짜·장소 미정이다.
   토요일 낮 선제 답장→상대12:30 제안→민준의 재확인과 동의→달력 순서를 보존한다.
   거절은 후속 만남이 없다. 도착은 수락 flag 경로만이며 사진으로 어머니 생사를 추측하지 않는다.
8. executive: 계열사 자리 제안은 본인의 검증이 필요하다. 면접의 정직 답변 뒤에만
   3일 뒤 합격·월455만원·첫 출근이 있다. 불합격 가지는 전무의 실제 수신 문자와
   작성했다 삭제한 미발신 답장을 구분한다.
9. envelope/interior: 방문 손님의 음료 한 박스·주말 일손 제안과 실제 토요일 근무를 구분한다.
   일당13만원 뒤 다음 주 문의는 추가 수락이 아니다. 후속 정식 수락은 인수50만원과
   다음 달 월224만원/직장 교체까지 원문에 있다. 거절의 언제든 자리는 상대의 말이다.
10. guilt: 현재 장면의50만원 반환·사례 거절과 남자의 실제 방문을 보존한다.
    돈을 계속 가진 가지는 쓰지 않은 현금과 젖은 공고만 남으며 자동 반환하지 않는다.
11. neighbor: 이사 도움은 용달3회·캔커피2개·실제 번호 교환이다.
    인사만 한 가지는 이름을 끝까지 묻지 않는다. 주거 신청은 실제 선정·6개월120만원,
    감사 발신 뒤 엄지 이모티콘 회신이 있다. 마감 후 작성한 답장은 미발신이다.
12. celeb: 02:30 편의점의 삼각김밥2개·음료1개를 유지한다.
    모른 척과 이전 사인 요청이 같은 flag를 만드는 부채를 고치지 않는다.
    사진1장에 대한 수락과 비공개 조건은 셀카 동석을 뜻하지 않는다.
13. scammer: 경고 뒤 대학생은 지갑을 넣고 사라지며 연락처를 교환하지 않는다.
    무시하는 가지는 지갑을 꺼내는 목격까지다. 피해나 금전 전달 성사를 추가하지 않는다.

## 외부 회수의 기존 원문 부채

현재 경찰서 신고와 후속 금감원, 그룹 전무/계열사와 후속 체인점 운영자,
반찬 구매 단골/아들 명함과 후속 반찬가게 알바/아주머니 연락처를 각각 보존한다.
현재 선정6개월120만원을 후속 심사12개월240만원 또는 탈락에 맞춰 바꾸지 않는다.
TOEIC·권고사직을 후속 경험·발표·대학 성적표·계속 재직에 맞춰 창작하지 않는다.
편의점과 후속 카페, USB 법무 전달과 후속 내부 비리 징계를 섞지 않는다.
50만원 반환과 외부30만원 반환의 공용 flag, 경고 뒤 연락처 부재,
3개월 서사와 다른2개월 회고, 이미 발신한 뒤 연락 안 함 선택을 유지한다.
독립 근거 order212-independent-preflight.json:
73630B / 46b83bd78f67658e69bfdf1e08b3bcc0a96237ae48ef7067d3df8df64922ffc0.
ROOT는 지정11그룹을 원문에서 직접 재독했다. 이는 인간 플레이 판정이 아니다.

## 소유와 검증

언어 담당은 content/events_{ja,zh-CN,zh-TW}/ 아래 butterfly_events.json,
chain_events.json의 자기 언어2파일만 쓴다. KO/EN/gameplay/runtime/save/font/human/public 불변.
ROOT는 portable·queue/L3·이 사양·CLAUDE/WORK/STATUS/backlog를 소유한다.
필요시 ORDER-212_L1_L2_RESULTS.md 및 full_game_localization.py,
full_game_localization_self_test.py, zh_translation_audit.py, audit_scope.json만 표적 수리한다.

선언 직전 대상6 부재·144 미수용·KO2 지문을 확인하고 선언 커밋/요청된 동기화 뒤
initial3(헤더 포함145행씩)/previous432 null을 봉인한 다음 저작한다.
신규432 전량 독립 L2, LF·토큰·순서·source hash와 기존32,052/meta9/b77을 보존한다.
숫자 오탐은 수정 전 정상/변조 입력을 고정하고 source-exact guard와 같은 회귀만 보강한다.
최종source/response/receipt3쌍·현재raw6·수용전량hash/L1·named lane --list→실행·EN·diff를 확인한다.
전체 audit/Godot/240주를 실행하지 않는다. 원어민·화면·L3·전체판을 GO로 올리지 않는다.
WORK_LOG가 예산을 넘으면 완료208의 ‘투자 연쇄·한국 생활 번역’ 절만
docs/history/WORK_LOG_2026-09-07_localization.md 앞에 raw exact 이동한다.
해당 절1365B/SHA5d9ec488391863c5fe173fa37b19a6990a67a7d01e5588986b022573fcc8731d,
기존 history63581B/SHA4e266ae74fe6f2dbbfe0e099de7aeff7e49683159afe093635369b0ebf480bbd와
끝 LF2를 선언 직전에 다시 봉인한다. 기존 내용 요약·삭제와 다른 절 이동은 허용하지 않는다.
선언·소유·수량·배치 지시는 일회성이다. 지속 규칙은 기존 I18N_INFRASTRUCTURE.md가 소유한다.


## 수용·검수 기록

신규432와 기존32,052를 대조·수용한 결과·지문·검사 경계는
[ORDER-212 L1/L2 기록](../queue_archive/ORDER-212_L1_L2_RESULTS.md)에 보존한다.
전체 INCOMPLETE/HOLD와 L3·원어민·화면 OPEN은 유지한다.
보관본을 apply_patch로 이동할 때는 내용뿐 아니라 기존 끝 LF2도 다시 대조한다.
