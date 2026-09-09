# ORDER-211 — 카페·만남·SNS 번역 L1/L2

이 문서는 원문·번역 데이터와 표적 검사 기록이다. 인간 플레이·원어민·화면 판정이 아니다.
L3 OPEN, 전체 INCOMPLETE/HOLD, 공개 M01~M06 BUILD2026.08.31.1 사용자 GO를 유지한다.

## 신원과 수용 범위

기준 제품/main은 fb02197bd380516a9439c825f08a0ebfa7d08e31,
선언은 62154b2fef7d8dc5901f1a66687c5de4f5ae27e7이다.
기준 source manifest edf845a7164b8fedc9ec027be7a7edc381a3dcdf67ff58c2858d44a3237b64b8.
portable의 별도 source_revision 53493fe7abbbbb82f0e56352da22acb2fe63b034는 변경하지 않았다.
새 제품 커밋은 이 기록을 포함하는 Git 커밋으로 식별하며, 개발 main 통합을 출시 승격으로 부르지 않는다.

A 카페18종106문구, B 만남·SNS19종114문구를 언어별 직접 저작했다.
합37종220문구×3=660. 언어별73선택·LF508·이름 자리표시자107을 보존했다.
수용은31,392→32,052(각10,464→10,684), b75→b77.
언어별 엔딩35종234문구·사건1,420종9,616문구·catalog834문구다.
기존31392의 값·순서와 나머지 메타9를 유지한다.
비보호 미작성 사건274종1,962문구/locale 및 공개 보호2문구·UI·표시 소비자는 아직 별도다.

## 저작·전수 대조

한국어 직접 저작이며 영어 중역·간번 기계전환0. 작성자와 다른 담당이 세 언어660문구를 전부 대조했다.
ROOT는 JA pair 출력의 잘린 부분135:172를 다시 읽은 뒤에만220문구 전량 판정을 기록했다.
필수 재작성0, 선택 정밀화5(JA2/CN2/TW1)를 반영했다.

- JA: 보증 발언을 개인적 이행 약속으로 강화하지 않도록 조정; 빗길 표현 자연화.
- CN: 예상 밖 표정의 관찰 방향, 배달 사고의 미발생 가정 명료화.
- TW: 소개자를 통화 상대로 지정하지 않도록 원문의 미지정 소개 경위 회수.

나머지655문구와 12파일의 형식·순서를 역치환으로 author raw와 대조했다.
검사에 맞추기 위한 본문 변경0. 원문 연결·효과의 부채는
[활성 사양](../queue_active/ORDER-211.md)에 남기고 번역에서 몰래 수리하지 않았다.
지갑 당일 접수증≠연락처/약속, 투자 제안≠거래, 조건부 채용≠합격,
인물의 수익 보장 발언≠확정 수익을 보존했다.

## 숫자 검사 수리의 경계

동결 저자 L1: JA209/220 clean(11leaf14진단), CN202/220(18leaf23진단),
TW200/220(20leaf26진단). 금액·카운터·순위·허용된 전화/브랜드 표기 오탐을
수정 전에 정상·변조 입력으로 봉인하고 완전한 KO 원문에 결속한 검사만 추가했다.
기존 일반 검사나 전체 원문을 면제하지 않았다.

JA 자체70: 정상22, 변조33, source변형15를 고정했다.
31개 숫자·단위 변조는 거부하며 비수치 영어2는 기존 허용 한계로 별도 기록한다.
source15에서 새 helper OFF와 기존 끝단 거부는 서로 다른 증거다.
ZH 자체161: 실제 오탐38·반대 언어 기존정상8·자연변형23·변조69·source-OFF23.
OFF는 HEAD의 결과가 유지된다는 뜻이지 잘못된 원문을 의미적으로 검증했다는 뜻이 아니다.

ROOT 별도12쌍은 저작·가드 수정 전에 동결했다. 초기 정상3/12·변조11/12였으므로
오탐이 있는 상태의 변조 거부를 정상/오류 분리 성공으로 세지 않는다.
JA 첫 독립4쌍은 정상2/4·변조3/4로 불합격: 30→40분 미탐과 두 한자 금액 오탐.
실패를 보존하고 같은 입력을 공개한 뒤 지정 원문3곳만 보강했다.
중국어 첫 독립8쌍도 정상2/8·변조8/8로 불합격이었다. 한자 원화 금액과 번체 등수 표현을
지정 원문3곳에서 보강한 뒤 같은 공개8쌍의 정상8/8·변조8/8을 확인했다.
최종 고정12의 정상12/12·변조12/12는 수리 후 회귀 증거이며 독립 블라인드 재승인이나 인간 GO가 아니다.
새 고정 사례는 repository 자체 검사에도 등록해 private 기록만으로 끝내지 않는다.

## 교환·수용 증거

initial6은 대상 번역12파일을 쓰기 전에 export했고 previous660은 digest(null)이었다.
final6은 L2 뒤 본문 hash로 export했으며 response6과 같은 헤더/현재 target을 사용했다.
각 import의 changed_files=0: 본문을 다시 쓰지 않고 정확한 승인 영수증을 남겼다.
source ID·조건·효과·KO/EN·runtime·save·fonts·human_gates·공개판 변경0.
WORK_LOG는 새 절만 추가하고 기존 history 원문과 끝 LF2를 그대로 보존했다.

| locale-batch | leaves | batch ID | receipt file SHA256 |
|---|---:|---|---|
| ja-A | 106 | 0e5eb257e8184e34db2c74f5fbeb5a2319364856ebfba919e49b06191c3e23ce | fc926bd7c56c15c30bcdcf1e5578c1540d999efc64c888900d9cf4d2a505ba71 |
| ja-B | 114 | 286010cf277b40d5677d090c1e14575d4dba4ec9c48723d689b020a4fdc69e6d | 2875fd1670672a231b4f978082a91473b7ecfdf34e1c16775a82894faaa2ce98 |
| zh-CN-A | 106 | 95d960ba29b48ce178e753a2c63d1ecac6453c89526aa4bbca8c5dbed8e27ffd | 1a15f71cba896dad4f4b90ef6ea7604cbe1fe5f0a79dd0fe5ec36039a8df6d7e |
| zh-CN-B | 114 | 6b985ff4118e7426b24a62682bc9bd5e96496f01a9a6df9fd2b3977596c3751a | b8a48feaf8d4cfb07262d8c5d10727c46a04b63d140927981b70786ac735631d |
| zh-TW-A | 106 | 1a0254e5ef7b65561c77b72dc64260761e9f5449b098b96ba102f25bb451e160 | 189b04171f571b0146c321d0c2041a93a7f6dba5c48ae49a9e9a58d64c77e0da |
| zh-TW-B | 114 | fab84aa04fa7c9fffd7bbd0942896c46831fce07a76a68b095e1b22a66bcfade | a8cbe4621936bd1d88b5e0d570c15fdd8ca2614f3c549fc5de702a78dd447817 |

수용 SHA256: a208ed70a2907d947abdd370936af1bd843b727efa354ae63929eefc73605a79.
portable file SHA256: fa363fb6f92f14767ae8178a05e71255093cceb8d43639aece5920e2a796fb0f.
L2 target freeze SHA256: d58db7ccbafa4247998cf881c0107fb0e04a02964264520169436661f18782f8.

## 독립·ROOT 봉인 파일

경로는 작업 private 증거 디렉터리다. 아래 지문으로 동일 입력을 구분한다.

- order211-initial-seal.json: 18477 B / e3f30774ffb31de621bd6eb8663c943bf63ab40cf6ab863734e7cc4df62ad543
- order211-independent-preflight.json: 216071 B / e446be6d8932373ed50c542dcb3c68ed77391ec123792434513f4db3ada8d5cc
- order211-ja-author-freeze.json: 290733 B / 0161d1e5e64fcbddbf7549741726607ae1ec3c54fc796e4598eeb66fb5ff24a8
- order211-cn-author-freeze.json: 227402 B / 0cd2b75155e9fbdaef368fb57040d93d4a03fb62416df66bb988519f899ed356
- order211-tw-author-freeze.json: 209015 B / c11c2acd6b72ed9cca3278b12866207d9ca352b76cce2b5ab48a77a9036c9beb
- order211-ja-independent-l2.json: 18160 B / dd8f574e5b42df4b94618b882a274730f403a27c3cc84bb96ff637e1a180df2e
- order211-cn-independent-l2.json: 27302 B / 54895a6660d4cd83b8d2f21807b9a105cd8458bc3513e13d169db49a853f9c04
- order211-tw-independent-l2.json: 22830 B / 8cc0f7e5848026e94922b596e01e8aa446fc96ea806398d085e87bebf1a982a7
- order211-root-l2-decisions.json: 8839 B / d1d728a834de01a6d4b9c86458151f369be03b6c50127c8edac5b41e660fb08c
- order211-independent-preaccept.json: 35746 B / 7fc33386c80688733e7e024bd8567a3884fa32f7f92a4518a10992484fc68ffe
- order211-root-independent-numeral-fixtures.json: 12929 B / 350b499d953369eceabaf02e5f8f440fe6a3bc371cef18f6bdc4b24757ea0444
- order211-root-independent-fixtures-baseline.json: 7016 B / 9f25a836c013f95b162887324ac908113e1c894ce1e91e4825086fd1a43eb533
- order211-root-ja-b1.json: 1373 B / fd40947f7fc541b487e5a67d3d8a8e359c41c1d6009146c00e8776aca17c825a
- order211-ja-guard-final.json: 9928 B / eae2c28eeb2b8cead8378ef3924cd6c09cac879036037e2554a1a5dad8a28967
- order211-zh-guard-b1.json: 75565 B / ac5c1d20b12f062150955f9a42330a66623d5abc214a7ed5f42c244aef964bf0
- order211-root-combined-b1.json: 9577 B / c2d5f458c98f06962314c968deb63ee41e1b2ee13c70d9847080d00ad4238b4c
- order211-root-final-32052-proof.json: 7856 B / ed7fdeb9b6bbb25e5e3b691f52abf9806b2549f599ea2ead1164c14f2d22942d
- order211-root-exchange-final.json: 9423 B / a740219741c5ca8bcca1532b2618c52bd5ea0eb4bc293e3ae80adec445ee1942

## 검증과 남은 판정

수용32,052 전량 source/target hash·L1과 신규660 current target, 고정12 회귀를 확인했다.
명시 차선·문서·보호 범위 검사의 실제 실행 결과는 아래 완료 시점 기록에 있다.
전체 audit/Godot/240주를 이 번역 배치에서 새로 실행하지 않았다.
원어민·실제 화면·Chapter5 인간 실플레이는 대체하지 않는다.
선언·수용 숫자·파일 소유권·이번 검사 지시는 일회성이다.
지속 현지화 규칙은 기존 I18N_INFRASTRUCTURE.md가 소유하며 새 규범 승격은 없다.

## 완료 시점의 표적 검사

명시 차선 full-game-localization-overlays를 --list로 확인한 뒤 12개를 실행해 전부 통과했다.
full_game_localization_self_test 228 tests/OK, ZH self11,271, JA self69,
full-body scope52, 공개 demo 변조4 및5언어14사건/100문구/121UI,
정적 audit ERROR0/WARNING0, i18n coverage clean, scope139, context325/links127,
queue active74/in_progress72를 확인했다. queue index25/fence4와 EN coverage도 통과했다.
ZH self 출력의 shared_han_jp_first=1/status=blocked는 보존된 차단 fixture이며
이번 번역으로 실화면 글꼴 승인을 얻었다고 해석하지 않는다.
준비 CLI에서 --lane/--base 혼용과 존재하지 않는 queue_index_check 이름은 실행 전 종료했다.
올바른 --lane 단독과 queue_index_self_test를 실행한 결과만 위에 적었다.
원래 실패 호출을 통과 기록으로 바꾸지 않았다.

고정 source/target32,052 전량 검증과 별도로, diff25경로·기존 queue73행의
내용/순서·메타9·이전31,392·WORK 새 절 외 불변·기존 history 불변을 확인했다.
독립 최종 영수증·문서 검토의 봉인은 다음과 같다.

- order211-root-combined-b2.json: 7852 B / 4e6e5bacd32abd90f50d0b46a99dc009139ef589fdeaed01337484355f106fd0
- order211-zh-guard-final.json: 68819 B / 71ef785bbb1ccf4ee5704d944241a8900a466a404f5a20b115a7c2eb1e4f9ebe
- order211-final-lane-output.txt: 4232 B / e5e33c8540eb1825ab29acf674ec93a320e6370ce99fea4807baf86cc66ad5b0
- order211-final-checks.json: 7820 B / 614ffa9347367ba0fb682b6dd0f35bcc063ef61c0611ac802bc727ee20f8cd92
- order211-independent-final-receipts.json: 40683 B / 2a18057fb34cce7c8a3c11259dbfb6367cc388b8fcef526f188bd30a768f4270
- order211-independent-scope-docs.json: 19655 B / 52ac39d74fe3bb4c182c59193f446c5e2a97a3cbd1cf11140690921010bc449a

독립 영수증 검토는47입력을 전후 봉인했고 신규660/배치2 제거 시 이전 portable
8,149,267B/ad267de784e0d6baf0ce98ce597bb159d80a1670e17c1dafb1e455be94fe2bbd를
byte-exact로 복원했다. 독립 문서 검토의 필수 수정0이며 이 최종 참조절·STATUS
재생성은 ROOT의 후속 확인 범위다. WORK에는718B 새 절만 추가했고 history는 이동하지 않았다.
