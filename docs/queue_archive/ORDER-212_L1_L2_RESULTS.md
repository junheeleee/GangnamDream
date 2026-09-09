# ORDER-212 — 나비효과·친절의 연쇄 번역 L1/L2

원문·번역 데이터와 표적 검사 기록이다. 인간 플레이·원어민·화면 판정이 아니다.
L3 OPEN·전체 INCOMPLETE/HOLD·공개 M01~M06 BUILD2026.08.31.1 사용자 GO를 유지한다.

## 신원과 수용 범위

기준 제품/main e87f6782acdafa3bcb06c0639099d1914ab4ca6f,
선언 a658d00f81cdbb5993bde30f0371e376f55170d5.
source manifest edf845a7164b8fedc9ec027be7a7edc381a3dcdf67ff58c2858d44a3237b64b8,
portable source_revision53493fe7abbbbb82f0e56352da22acb2fe63b034는 그대로다.
새 제품은 이 기록을 포함하는 Git 커밋으로 구분하며 main 정리는 출시 승격이 아니다.

butterfly11종66문구+chain13종78문구, 24종144문구씩 세 언어432를 수용했다.
언어별48선택·LF439·name33을 보존했다. 수용32,052→32,484(각10,684→10,828),
b77→b78. 엔딩35종234문구·사건1,444종9,760문구·catalog834문구/locale다.
shipping 비보호 미작성250종1,818문구/locale와 author_only105종741문구,
공개 보호2문구·UI·표시 소비자를 분리한다. 숫자로 전체판 완료를 주장하지 않는다.

## 저작·전수 대조

한국어 직접 저작이며 영어 중역·간번 기계전환0. 다른 담당이 세 언어432문구를
전량 대조했다. ROOT는 JA 출력에서 잘린 envelope 원문을 전량 재독했다.
필수 재작성0, 선택 정밀화7(JA1/CN2/TW4)을 반영하고 나머지425를 보존했다.
JA 사진 부탁의 촬영 주체 미지정, CN 늦은 오후/저녁, TW 못 들은 척하는 사람과
사례 거절의 주체·메시지 발신 문법·불필요한 손잡이 당기기 표현을 정밀화했다.
TW 두 주체는 갑자기 서술자 我를 넣지 않는 ROOT 대안을 독립 검토자가 재확인했다.
역치환6 raw가 저자 원형과 정확히 일치한다. 검사에 맞춘 본문 변경0.

식사 초대→가능 시간 발신→상대 시간 제안→날짜/주소 재확인→달력→도착을 보존했다.
거절 후 만남을 만들지 않았고, 실제 합격·엄지 회신과 미발신 답장을 구분했다.
후속의 직업·관계·신고 기관·기간·지원액·금전 효과 차이는
[활성 사양](../queue_active/ORDER-212.md)의 원문 부채이며 번역에서 몰래 수리하지 않았다.

## 숫자·문자 검사 수리

저자 동결 L1은 JA144/144, CN131/144(13leaf14진단), TW133/144(11leaf15진단).
ZH는 실제 수량14leaf19진단·영문 literal9·이름표기1을 구분했다.
JA 기존228 self AST를 유지하고 두 완전한 KO 원문의 기간·합계·월급·회수만 보강했다.
공개4쌍과 자체20입력, 총28을 수정 전에 고정했다. 초기 정상은 공개2/4·자체2/4로
실패했고, 최종은 공개정상4/변조4·자체정상4/변조12·source-OFF4 모두 기대 결과다.
변조 거부에 정상 오탐이 섞인 초기 결과를 분리 성공으로 세지 않는다.

ZH 자체192는 실제정상24·자연변형24·변조120·source-OFF24다.
초기 정상0/24·자연9/24·변조116/120이었다. 최종 정상24/24·자연24/24·
변조120/120·source-OFF24의 기존 진단 보존을 확인했다. 전체 의미 판정이 아니라
고정된 수량·단위·역할·표기의 회귀다. 원문 밖 예외나 임의 숫자 면제는 추가하지 않았다.
두 기존 정상 주거지원 한자 합계 오탐은 별도 공개 입력 뒤 실제 값을 Decimal로 읽도록
보강했다. 기대120만원으로 덮어쓰지 않고 기존 원화 비교에 넘긴다.
중간 자체검사11,479 통과 뒤 현재 TW의 정상 ‘兩個三角飯捲’를 새로 오탐 처리한1건을
발견해 정상/2→3 변조2를 추가했다. 최종 ZH self11,481 통과, 현재288 L1오류0이다.
기존 self11,271·상수와 정의는 보존하고 지정 hook/새 회귀만 추가했다.

ROOT의 저작 전 고정12쌍은 v1의 주거용어2오류를 가드 작성 전 v2로 정정했고 v1도 보존했다.
v2 초기 정상8/12·변조12/12였다. JA4를 공개해 수리하고, ZH own192 봉인 뒤
중국어8(초기정상6/8)을 공개했다. 최종12정상/12변조는 같은 입력의 공개 회귀이며
새 블라인드 승인·원어민·인간 플레이 판정이 아니다. 고정 사례는 repo self에도 등록했다.

## 교환·기존 수용 보존

initial3은 저작 전에 export했으며 각145행/144문구, previous432는 digest(null)이다.
L2 후 final3·response3·receipt3의 헤더/선택/source/current target이 일치한다.
check/import는 각 언어144, changed_files=0이며 본문 재쓰기 없이 영수증을 남겼다.
기존32,052 전량 hash/L1 및 신규432를 수용 전에 실행해 오류0을 확인했다.
수용 후에는32,484 전체 hash·신규432 L1·고정12를 재검사하고, 코드3/원문2/번역6/
사람gates/project 지문이 수용 전후 동일함을 확인해 이전 L1과 연결했다.
이 후검사의 기존 L1 실행 개수는0이며 같은32,052를 재실행했다고 쓰지 않는다.
기존 accepted값/순서·meta9·b77과 제품 원문·KO/EN/runtime/save/font/공개판을 보존했다.
WORK_LOG는 새 절과 허용된 완료208절 raw exact 이동만 수행한다.

| locale | leaves | batch ID | receipt SHA256 |
|---|---:|---|---|
| ja-A | 144 | 679c38a2659052e58f65cfa76aa21229ba342c6251a9c5e5d8289f1e2d9e559b | 25b09d3ecdadc1b26a8b22e827f52179a5522d640f0350a12ddfe3f8cf2d47d0 |
| zh-CN-A | 144 | 4978a6f98a337418849c302ec8bfb8e38210a170f2772c6eec0f1b63a1200088 | e693f01590eca93314ce7f161bca9addfba687762c4311d472d2ce84152c62d2 |
| zh-TW-A | 144 | 72e0925fc1309bd8e598379e5265cb779e1112b2db889a17128be25ca2591828 | bb13fc809863b5e9a0b7c8b735e75f4e6e9addde4d58dcbb5a831c86adf8a53f |

수용 SHA256: d05b3933a7d9190ba9e37c2d00d74a3b0d031ef29a641b78bbef678814e35c1e.
portable SHA256: b73d519bdf516eacb2a2db2a7b72242fe5ff0397b85a5aa8ae5dc4217076a3f5.
L2 raw6 freeze: ded75337fe7fe00b2f1cb5655a042ed79e0614bd942813cdce2a60dd4faf044d.

## 증거 파일

- order212-initial-seal.json: 12363 B / f661fc330d8462975f7e92b224f25d8ffaa40f4e8700d61412153c25aa6c5b54
- order212-independent-preflight.json: 73630 B / 46b83bd78f67658e69bfdf1e08b3bcc0a96237ae48ef7067d3df8df64922ffc0
- order212-ja-author-freeze.json: 158217 B / 73c124ca864644fbbb35ae420658c8320ea4c1798dc72eeb3fe9d99ec1013335
- order212-cn-author-freeze.json: 155917 B / ecd4b23ff7db6897d6fa08ccf28272432498e65067caea4e9fde333b727e9f08
- order212-tw-author-freeze.json: 171547 B / 35597c8238df8a444c39d97f2ecb737c5be134a84cbebf068b311e2c0ba14eba
- order212-ja-independent-l2.json: 48193 B / 3fa599904dd5305d325e981f89625b462e18919691e94d57e028aba56c268ee8
- order212-cn-independent-l2.json: 22496 B / 757c666b7b252413b1cdb85cecebd39fe8a6f9eca561899d2db6e06448034c99
- order212-tw-independent-l2.json: 20530 B / 0cc18e93627cfedf26adb7e310331ca0f922bb4d2b543a23001c7139ccd07956
- order212-root-l2-decisions.json: 10617 B / b6d09177b0968fd1563a77e78dcb14c9547ae1635d82961289591aff815d317f
- order212-independent-post-l2.json: 21866 B / fe509faf7e9ddd08ecd69c2e974363fa6e8716f0d58a28c15c77560528be9ef8
- order212-ja-guard-final.json: 20897 B / b1ff24c33e191fadf983298061937b25a97e289611e115e55468b8242f81d142
- order212-zh-guard-final.json: 13875 B / f9de79f452335d26d7501b3959ed1955180d986ee5bc4959232892eaa7afd50e
- order212-root-independent-numeral-fixtures-v2.json: 14564 B / 47096d978a061389d9fb01a803fc5455958e9b1e0aef5e49a549cd6c8bf226f0
- order212-root-preaccept-32052-proof.json: 6702 B / c9d983f4396597f85caf8d26977495b06752fefeb37878a850e6e9df12f81d1c
- order212-root-final-32484-proof.json: 6698 B / 73e4990ec135890892f7f0e3a724c19f34770bbd045efebe6787c5bb149bf895
- order212-root-exchange-final.json: 4830 B / 1d8d466c6d4f3d2b84d08751634d02d6aa9edd0d348b13eb9910d19d92a1ff53

## CI와 사람 판정 경계

기존 fb02197 CI34306171104는 year5 ending3·public CN1의 옛 지문 충돌로 실패했다.
e87 메인 CI34310713725도 완료 job102336634285의 로그에서 같은 두 실패를 확인했다.
정적 job102336634442는 성공했으며, 상위 실행 목록의 지연된 in_progress와 구분했다.
현재 e87/a658 소스에서 두 감사의4진단을 재현했고 승인된 번역 계보를 별도 수리로 넘겼다.
이 번역 차선 통과를 원격 CI 전체 GO라고 부르지 않는다. Chapter5 두 실제 재플레이와
원어민·화면·L3 OPEN은 그대로이며 전체 audit/Godot/240주를 이 배치에서 실행하지 않았다.
준비 중 존재하지 않는 audit_scope_check 이름은 실행에 실패했다. 올바른 명령은
python3 tools/audit_select.py --verify이며 그 결과만 등록 검사 증거로 센다.
선언·파일 소유·수량·회귀 지시는 일회성이다. 지속 규칙은 기존 I18N_INFRASTRUCTURE.md가
소유하고 새로운 정본 규칙 승격은 없다.

## 완료 차선 검사

명시 차선 full-game-localization-overlays를 --list로 확인한 뒤12개 모두 통과했다.
full_game_localization self229/OK, ZH self11,481, JA self69, full-body scope52,
공개 demo 변조4 및5언어14사건/100문구/121UI, 정적 audit ERROR0/WARNING0,
i18n coverage clean, scope139, context327/links130, queue75/in_progress73이다.
추가 EN coverage와 queue index25/fence4도 통과했다. ZH self의
shared_han_jp_first=1/status=blocked 출력은 보존된 차단 fixture이며 실제 폰트 승인이 아니다.

ROOT 범위 첫 검사는 history 이동 뒤 끝 LF가2→1로 바뀐 것을 검출해 실패했다.
끝 LF2만 복원한 뒤 scope20·기존32,052·meta9·queue74·허용208절 이동이 통과했다.
해당 history64,946B의 SHA는9a0dc936650799944ef3d9bc13f8cf4e29f9fdb6971d55b7d0d541ac28c76db6다.
WORK 새 절1,104B/최종39,265B 외 나머지는 원형이고, diffcheck 오류0이다.
이 실패 호출은 통과 기록으로 덮지 않았다. 전체 audit·Godot·240주 실행0,
원격 CI 전체 완료·인간/원어민/화면 판정은 이 표적 결과에 합산하지 않는다.

## 독립 최종 검토

영수증 검토는 입력32를 전후 봉인했다. 신규432와 새 배치1만 역제거한 portable가
기존8,314,974B/fa363fb6f92f14767ae8178a05e71255093cceb8d43639aece5920e2a796fb0f로
byte-exact 복원됐다. 기존32,052 L1과 후검사 연결에도 중복 합산이 없다.
문서·범위 독립 검토 필수수정0. 준비 도우미의 meta9를 최상위 필드 수로 잘못 센
첫 호출은 실패로 보존하고 실제3×3 메타 기록을 읽어 도우미만 정정했다.
이 최종 참조절과 STATUS 재생성은 ROOT 후속 확인 범위다.

- order212-independent-final-receipts.json: 30,900B / 6705f6f4033b798dfcd90f1c1dee5a7c70d98b76331d02692e7705033aee7b54
- order212-independent-scope-docs.json: 16,912B / 9ab87f45aa1f77909b65f9fad339a9797a2d8ef7fca3cc9a4a85ec5bbac303c2
- order212-final-lane-output.json: 4,549B / fcd3073a3c835c7fd03af0f03efdbab54759bb00ec45d961dbd305d3c94a4356
- order212-root-scope-final.json: 1,861B / 05d0ae750ee3f105a9725c8241368a23dbffee57f181554af60a216087327a33
