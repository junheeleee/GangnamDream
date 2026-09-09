# ORDER-214 — 생활 선택·부채·직장 번역 검토

24종169문구/언어, 일본어·간체·번체507문구의 한국어 직접 번역이다.
영어 중역·간번 자동 변환0. 인간·원어민·화면 판정과 본편 전체 GO는 아니다.

## 원문과 독립 대조

선언23724b75b531363aa0b6b3b5b7ee3908a0e13ae4에서 최초 교환3을 내보냈다.
각170행/169문구, target 부재507과 previous=digest(null)을 저작 전에 확인했다.
원문은 amb_scenarios1~6의24종, 일반166+기억3, 선택59/LF226/name81이다.
source aggregate ef6ef26d66b9173feeaf87ba9c813522ab71e3407403cbbab51324c3aaeb1e40.

JA는 ROOT 저작→Plato169 전수, CN은 Plato 저작→ROOT169 전수,
TW는 Poincare 저작→ROOT169 전수로 대조했다. 각각 한국어와 결과물을 직접 읽었다.
JA 필수3(보증인 주체1·연체 후 대출/전세 차단 의미2)와 선택 정밀화1(매주말 제안),
CN 선택 정밀화3(전화 중 물리적 붙잡음 제거·경찰 접수증·네 글자 인용),
TW 선택 정밀화3(매주말 제안·통장·월세 명시)를 적용했다.
각6파일의 역치환이 저자 raw와 정확히 일치하며 나머지497문구는 동결 후 그대로다.
최초 검수 결함을 지우지 않았고 숫자 검사에 맞춘 산문 왜곡0이다.

미성립 이사·통화·동석·송금·직업·계약을 추가하지 않았다. 보험 경계/과거 부친
상환 주체/전화와 얼굴 묘사/산문과 money effect 차이 등 원문 부채는 번역으로
몰래 고치지 않았다. 제안과 실제 수락·식사·일한 결과가 있는 가지는 구별했다.

## 최초 오류와 수리 방식

자가 동결 L1: JA146/169(23진단), CN161/169(8문구11진단),
TW163/169(6문구6진단). CN의 앞선 glossary1은 저자 동결 전에 고쳤고,
TW의 통장·월세2는 위 독립 대조에서 정밀화했다. 최초 결과는 별도 보존한다.
나머지 자연문 수량 오탐은 완전한 KO source에 묶인 실제 값·단위·역할로 처리한다.
기대 숫자로 타깃을 덮거나 leaf 전체를 면제하지 않는다.

JA 자체182의 실제/자연46·타깃변조108·source-OFF23·원문숫자변조5를
코드 전에 봉인했다. ROOT 독립4쌍의 첫 실행은 정상3/4였고, 생략형
「残業は倍」가 오탐이었다. 이를 노출한 뒤 별도18입력을 먼저 봉인해 수리했다.
이후4쌍은 노출 후 회귀이며 새 블라인드 승인으로 세지 않는다.
기존229 self는 보존하고 새2를 등록했다. ZH의 CN72와 TW36도 각각
수정 전 정상/자연/변조/source-OFF로 봉인했다. 통합 최종 결과는 아래에 기록한다.

## 증거 위치

기본 경로는 원본 저장소 `.git/full-game-localization/`다.

- order214-ja-author-freeze.json: 일본어 자가 동결·최초23진단
- order214-cn-author-freeze.json: 169223B / da9bca781c991ecdd5e92284780836fcabcd425dfbc49bc7ad4e496caeff417e
- order214-ja-independent-l2.json: 23391B / 77136f41b2f7eccc2de5602f938b21aa2c45ba67851b3bd0d2b64324d0101d35
- order214-root-ja-cn-l2-integration.json: JA4/CN3 적용·각 raw6 역치환
- order214-tw-independent-l2.json: TW169 전수·정밀화3·raw6 역치환
- order214-root-private-guard-B1-result.json: 최초 독립3/4, 실패 보존
- order214-ja-guard-B2.json: 67652B / d31fab183f1f05563f9e2cce65f2fc459c159c857d950cea4936e688c96789c0

TW 저자 동결만 `.git/worktrees/checkout2/full-game-localization/`의
order214-tw-author-freeze.json 207550B /
310217c77e08774b6f035d336065284fe7a87974cf2d6e648e45c21c16b46434에 있다.
공식 initial/final 교환은 이 WT 경로가 아니라 원본 main의 private_dir를 쓴다.

## 병렬 변경의 신원 경계

214 원문6은 그대로지만 별도215의 MainGame metadata 변경이 전체 source manifest를
edf845a7164b8fedc9ec027be7a7edc381a3dcdf67ff58c2858d44a3237b64b8에서
8cf471d2c6b3b900371e47f9c0bc5f1dcaf8a116f7bcfe740ff7e682c3243a91로 바꾼다.
현재 source hash map의 MainGame 한 항목만 선언 blob으로 역치환하면 옛 manifest가
정확히 복원된다. final 교환은 이 수리를 포함한 실제 제품 커밋 이후 발급한다.
기존 portable의 source_revision/manifest는 역사 snapshot으로 보존하며 새 교환
헤더와 혼동하지 않는다. 입력·운영 검사를 번역 품질이나 실플레이로 합산하지 않는다.

수용/명시 차선/정확 후보의 최종 마감은 이어서 기록한다.
이 오더의 수량·소유·검증 지시는 일회성이다. 지속 번역 규칙은 기존
I18N_INFRASTRUCTURE, 위임된 최종 판단은 WORK_UNIT이 소유한다.
