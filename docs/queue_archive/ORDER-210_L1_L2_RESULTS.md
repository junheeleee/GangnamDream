# ORDER-210 — 도시 휴식·도박·우정 번역 L1/L2

개발 텍스트 수용 기록이다. 전체 INCOMPLETE/HOLD, 원어민·화면·L3 OPEN을 유지한다.
공개 M01~M06 BUILD2026.08.31.1의 사용자 GO와 기존 제품은 그대로다.
이 기록은 자동 검사나 Codex 독립 검토를 인간 실플레이에 합산하지 않는다.

## 기준·수용

- 완료209 기준: `259636fa9ed8b6172652a396ba686c104d96af80`.
- 선언·교환 검토 HEAD: `9d98c2c8741d0da5a7703a64cfe4ccc190a8902d`.
- A16종98 / B23종140, 총39종238문구×3=714를 한국어에서 직접 저작했다.
  영어 중역·간번 자동 변환0. KO6는 읽기전용, 신규 locale18파일만 저작했다.
- 언어별80선택/LF528/name37, known/foreshadow0, KO 상대 순서와 text-only 구조를 보존했다.
- 원장: 기존30,678(각10,226)/b73 → 31,392(각10,464)/b75. meta9는 별도 보존이다.
- 현재 언어별 사건1,383종9,396문구 + 엔딩35종234문구 + catalog834문구.
  공개 보호14종의 기존100문구는 이 수용에 중복 추가하지 않았다.
- 원장8,149,267B SHA `ad267de784e0d6baf0ce98ce597bb159d80a1670e17c1dafb1e455be94fe2bbd`.
  accepted SHA `c51703ec323331adea7fde20bb0f955e7a44dab9fba2d52c1ea4f3b3e9feacc7`.
- source manifest `edf845a7164b8fedc9ec027be7a7edc381a3dcdf67ff58c2858d44a3237b64b8`, portable source_revision
  `53493fe7abbbbb82f0e56352da22acb2fe63b034`는 변경하지 않았다.

## 원문·연결 범위

원문6/39, 외부 콜백32, 조건 flag 직접 부모6을 읽고 번역의 사실 경계를 선언했다.
출력40slot/35flag·내부direct4·deferred0을 정적 대조했다.
M07~M60 exact ID 교집합0은 일반 사건의 비도달이나 플레이 완료 증거가 아니다.
카지노 문의/발신/미회신, 경마 관전/조사/실제 베팅/반사실 환급,
친구와의 실제 통화/미래 제안·회사 투자금의 소유를 구분했다.
조건·효과 금액·시점·승식·콜백 회고의 원문 부채는
[활성 사양](../queue_active/ORDER-210.md)의 원문별 경계를 유지한다.
KO/EN·gameplay·runtime·save·font·public·human_gates 변경0.

## 독립 L2와 최종 본문

언어 작성자와 다른 검토자가 각238문구를 한국어 원문과 전량 대조했다.
JA 필수2/선택2, CN 선택4, TW 선택1을 ROOT가 원문과 다시 확인해 모두 반영했다.
9곳은 행동 이력·첫 대면 존대·관찰/허용·인물 관계·문장 호응 정밀화이며,
숫자 검사에 맞추기 위한 본문 변경은0이다.

- `events:race_mentor_truth:/choices/1/result_text` (events_ja): KO는 오늘 실제로 마권을 샀다는 1회 사건이며 ‘오늘도’라고 하지 않는다. 今日も는 원문에 없는 이전 구매를 단정한다. 조건 racetrack_guide_met도 이전 마권 구매를 보장하지 않는다. 현재 실제 구매는 보존하고 반복 의미만 제거한다.
- `events:racetrack_mentor_meet:/description` (events_ja): 첫 대면의 KO 질문 ‘젊어 보이는데 경마 알아요?’는 친근하지만 -요 존대다. 현 知ってる？는 처음 만난 청자에게 반말로 시작해 관계 거리를 낮춘다. 후속 과시 대사의 반말은 그대로 두고 질문 말미만 자연스러운 구어 존대로 복원한다. JA 정본의 화자→청자 경어 차이 보존 원칙에 따른 제안이다.
- `events:friend_success_gap:/choices/0/result_text` (events_ja): KO는 복잡한 감정과 진심이 동시에 있을 수 있다는 관찰이다. あってもいい는 있어도 괜찮다는 허용·자기승인으로 기울 수 있다. ありえる로 가능성/공존 관찰을 직접 보존한다. 새 답장·통화·감정 사건은 추가하지 않는다.
- `events:friend_wedding_stranger:/description` (events_ja): KO ‘이상하게 반가우면서 낯설었다’는 낯선 친구의 세계를 보는 자기 감각이다. よそよそしい는 타인의 서먹하거나 냉담한 태도로도 읽힐 수 있어, なじみのない感じ로 낯섦의 감각을 더 분명하게 한다. 실제 낯선 참석자·처가 친척의 원문 특이점은 보존한다.
- `events:holdem_read_people:/choices/1/result_text` (events_zh-CN): 원문은 이번 폴드 경험을 이미 치른 비유적 수업료로 회고한다. 현행 总得는 일반적인 필요·당위로 바뀌어 구체적 과거 회고가 약해진다. 실제 추가 지출을 발명하지 않고 그 경험의 지시 대상을 복원한다.
- `events:holdem_big_pot:/choices/0/result_text` (events_zh-CN): 원문은 상대가 자리에서 일어났다는 데까지 확정한다. 离开는 그 자리를 떠난 행동을 더 명시하므로, 원문의 기립 단계만 남기는 좁은 정밀화다. 승패·패 공개·주인공 동작은 그대로다.
- `events:friend_drunk_midnight_call:/description` (events_zh-CN): 원문의 우리에는 과거 술집의 정확한 인원이 없다. 咱俩는 둘로 좁히므로 咱们으로 당시 일행의 범위를 열어 둔다. 현재 통화 상대 한 명과 통화 시각은 바뀌지 않는다.
- `events:friend_success_gap:/description` (events_zh-CN): 대학 동기라는 원문의 같은 학번/동기 관계를 大学同学가 일반 대학 지인으로 넓힌 부분만 同届로 정밀화한다. 투자금은 회사 A라운드 자금이고, 회상 속 공동 창업 제안 및 실제 친구 개인의 성공 여부를 새로 확정하지 않는다.
- `events:race_last_bettor:/choices/1/result_text` (events_zh-TW): KO의 '만회하려다 두 배로 잃은 하루였다'는 하루가 아니라 손실이 두 배가 됐다는 문장이다. 현재 의미는 문맥으로 이해되지만 '想翻本，反而輸了兩倍的一天'의 명사절 호응이 거칠다. 하루를 주제로 먼저 두고 손실의 두 배를 분명히 연결하는 자연도 정밀화만 제안한다. 수량·손실·행동 단계·LF는 불변이며 L1 회피 목적이 아니다.

최종 동결 `order210-l2-target-freeze-v1.json`:
330,786B SHA `0d91d41b2a908c6f8b637a2a99e67808770d4e037eea3aebdd329e2bb30a1382`.
각 수정 역치환18파일은 author raw와 byte-exact이고 나머지705문구는 불변이다.

| locale | 최종238 records SHA |
|---|---|
| ja | `fb8580ad48cec13e153dc5dd820f3b8213077442881541d56c2f44e75d3be9e7` |
| zh-CN | `c2c95bbede9e973f7c661a41acf8317de5d71bd4803f372ce3da36e34134187c` |
| zh-TW | `273ffa70850b71060356c33f638e08dd660fc3702f761fbccce4238bc915dd6a` |

## 초기 교환과 최종 영수증

초기 source6은 대상 파일 부재 때 생성했다. A99행/B141행이며 각238개의
previous_target은 null digest였다. 이후 초기 파일을 재생성하거나 덮지 않았다.
L2 본문 확정 뒤 final-v1 source6을 새로 내보내고 현재 target에서 response6을 만들었다.
check6/import6 모두 PASS, changed_files=0이다. import는 검토 본문을 재작성하지 않았다.
최종 source/response/header·selection/batch ID·receipt internal SHA·본문18·원장714를 대조했다.

| locale/batch | 초기 source SHA | final source SHA | response SHA | receipt raw SHA |
|---|---|---|---|---|
| ja-A | `223cf2d47f7c3c485e24d94aec32cfa0583b54cae53798809300a0b53fd18799` | `df3511a1b1330e752e7041476b13065894d4e0a4b302773c5e2a7e76ef43545d` | `d4675725364270cc4c8fb25c5916b98246448848296c1d06a6481a47aee40b07` | `697864cfee265493cdd691e5503d941ae171f7bab3c01de2833c861bcd8fb1de` |
| ja-B | `6489760f307970349708382db362a1142250778df806c7d9c2ae9d48d1e1d977` | `bd43659e3f9fd9cfa82260a4e9d44dac3095ddaf125b00bbe6b4a06dc1bb00d0` | `ba6732dc46f8eebe5d51694c6d82cc16f5c88b92da459f57c51772882cc56c0b` | `47a972cf27da30228cef48dee678a9db531d801392a9f4db544d4d2796781519` |
| zh-CN-A | `fbc106b202d4c85222844dcee222731a04203c21ac8fc3421dfac6256ead64c2` | `65e7d7bb2a9ea55b3cd98068c643efbe8748f2a023f91edc4f52ab14009dba64` | `67a88a69fa130e55122b5359c1ce36f1ee103d30570a4a39ac0a57c008ea637d` | `1dfa1572e698f00cc7bada86853db0717118dd520aa3671ac2463769d913bf2b` |
| zh-CN-B | `000e3b93232ded0b39e951c7f95b6cceb40f799ea986e0e97f53eca71df0d945` | `669ca3c3485c907a64e7db974e4816835c5805485534c0ee06a4c6e0c29f36e8` | `4a536c252c7c61a900e44f134cfc68a615fc0befafe5cb9ae383bb2ddeda1015` | `4607625b935d0a110b1c0cf64a479d7137c6877af30ea100bd79b043761b464d` |
| zh-TW-A | `11c9e308738bee5b0c8d54b463e4af6f87be3fcbf2cfb497f21c0ca40a922053` | `8eea7d3f6f2b3c36618559d98915d0b6e0be0a16abe629fa808f298d947978cc` | `8768ea34c28713d57565a71b6a0e6876040f8c00aad8d478a1ab7661d0b46566` | `30edad7b2fe0a4a9cb557358d37f20a1fe4e380d8c6ba8afcbeca05117ddf94f` |
| zh-TW-B | `dac1e61d3532675a9248e9b3ac4cdc957d5c655cc4cf828dd07956f8f4e21168` | `5837f3403e2a66ca9c1725dccb9bb62fac3896e602eea517f5f76bd358fcbcbe` | `c8ccf6f3b7b18e168ce9d91af9a6e4f1e1f07e23040b82a1aa34447f7407889e` | `9ad8cd9d3da00dca46ab270e212af8628d56d53f8507594d13680443fd9c5b61` |

`order210-exchange-final-proof.json` 9,300B SHA
`69bd2b5ad2d3c1ef02501390f3513265cb4a65c7500cb49bc99664c933d6d4be`.
교환은 worktree-private 증거이고 source/target 수용 지문은 저장소 원장에 보존한다.

## 숫자 검사 — 실패와 수리의 분리

저작 직후 JA12leaf/12진단, CN55leaf/106진단, TW40leaf/71진단을 기록했다.
이들은 통화·한자 수량·말 번호/순위·나이·시간·할인의 표기/역할 해석과
원문에 있는 Pump/Ddareungi/A를 다루는 표적 오탐이었다.
원문이 정확히 일치하는 범위에서만 새 슬롯을 적용하고 공통 반환형과 기존 경로를 보존했다.
이 검사는 모든 자연어의 의미나 새 원문까지 자동 승인하는 장치가 아니다.

- JA 자체 입력144는 코드 수정 전에 봉인: 실물12/자연24/target84/source24.
  정상36 통과·target84는 새 helper 직접 거부. source24는 새 licence OFF이며
  기존 E2E는22거부/2허용이다. 기존 정상6의 회귀0을 따로 확인했다.
  fixture122,885B SHA `dea98af36ce86c8a2ddfd1f0dbc8ab4a5716bd01bdfd9c519e79d1e0c7633bed`.
- ZH 자체 입력497도 먼저 봉인: 실물114/자연10/target259/source-OFF114.
  정상124 통과·숫자 변조259 거부, source-OFF114는 새 helper 비적용이다.
  OFF의 기존 E2E19허용/95거부는 변조 전량 거부와 구분한다.
  fixture558,572B SHA `08ae8ce2d9f1617ff3a82f99faa4498d3360284c7bbe0ba350f742fd80789483`.
- ROOT는 별도12쌍을 guard 수정 전에 봉인했다.
  13,814B SHA `0741886ca07a0f31ae0335df0d0502455151b85be78715337e9dfb6fef1b727c`.
  최초 baseline 정상8/12, 변조11/12 거부였다. 정상 오탐은 정상/변조 분리 성공이 아니다.
- B1에서는 실제 새714 L1이0오류였지만 독립12쌍은 정상11/12·변조10/12였다.
  JA 블러핑2→3회와 CN 만화20→10권을 놓쳤고, TW 자연스러운 경마 표현도 막았다.
  B1 원본 결과8,942B SHA `d917a6caf7db3d7669b0f311ec0fb36b210a4f326822d1f08148d67eb8b8bae4`를 보존한다.
- B2는 같은 source와 같은12쌍 바이트에서 위 세 축만 보강했다.
  JA의 블러핑2회/큰 팟1회, CN 권수20, TW 경주수·賽事 동의형·말 순위·18배를 구분했다.
  정상12/12 통과·변조12/12 거부. 본문18/714 변경0.
  B2 결과8,905B SHA `6aecbfd6167702d5baa1515f4a5418022ba3d07f6bcfd9488a92c05ddc132f52`.
- JA B2 추가 최소8은 정상3/수량변조3/source-OFF2이며,
  source-OFF2의 기존 E2E 허용은 잔여 한계로 명시한다. 기존144 결과 배열은 B1과 동일했다.
  기존222 테스트 AST와 다른 기존 함수들을 보존했다.

전량 L1 증명 시점의 도구 지문(아래 CLI 형식 수리 이전):

| 파일 | bytes | SHA |
|---|---:|---|
| `tools/full_game_localization.py` | 159570 | `bcd8bf172e5ec60c4523aa936ec39e2803d0173758b6c9b42d004b54747c7a9f` |
| `tools/full_game_localization_self_test.py` | 419344 | `b41eb36b03a0b5137ae0e7a58a8be5a95191466d6c61a30449036a8ce2bd483e` |
| `tools/zh_translation_audit.py` | 1029710 | `6e6b15460e04aeb5957a388ca93b9e0b706fc15b06995044c14a737c7260ad17` |

## 전량 확인과 남은 범위

`order210-root-final-31392-proof.json` 8,909B SHA
`197c02441f4635fbe71892422f34d52caf347335349c044a3d936531d7ffa0a3`:
31,392개 전량 source/target hash·L1 오류0, 새714 오류0, 독립12쌍 정상/변조 분리,
검증 입력30개의 전후 불변을 확인했다. 기존30,678은 그대로 유지했다.

최종 선택 차선·독립 영수증·문서/범위 결과는 아래 실행 기록에 분리했다.
전체 audit.sh/Godot/240주·화면/원어민/인간 실플레이는 실행하지 않았다.
자동 수용을 full/product/main GO로 기록하지 않는다.

실제 비보호 미작성은311종2,182문구/locale다. 수용 원장 밖 shipping325종2,284문구에는
공개 보호14종102문구가 섞여 있으므로 전부 미작성으로 세지 않는다.
그 보호 범위 중 기존 overlay100문구 외의 `arc_temptation_01` foreshadow2는
본편의 별도 잔여로 추적한다. 공개 snapshot PASS를 이2문구의 번역 증거로 쓰지 않는다.
UI·표시 소비자·원어민·화면 검토도 남아 있다.

사양의 선언·수용 수치·도구 수정 범위는 이 묶음의 일회성 지시다.
지속 규칙은 기존 `I18N_INFRASTRUCTURE.md` Status의 직접 저작·원문 결속·
공개 보호·초기/최종 교환·named lane·사람 판정 분리 규칙을 그대로 적용했다.
새 서사·밸런스·런타임 규칙 승격0.

## 최종 표적 검사와 독립 보존 확인

named lane의 12개 목록을 먼저 확인하고 1회 실행했다. 최초 결과는 **11 PASS / 1 실행 실패**다.
`full_game_localization_self_test.py`는 실제 Xcode Python3.9.6 CLI에서 긴 UTF-8
물리행3621을 해석하지 못해 테스트 진입 전 실패했다. 이 실패 원문은
`order210-final-lane-output.txt`에 보존하며 최초 lane 자체를 PASS로 바꾸지 않는다.

다른11개는 source52(shipping1708/11680·closure192/1751), audit ERROR0/WARNING0,
I18N coverage(각1397=수용1383+공개14·endings35), JA self69, ZH self11094,
공개 demo self4/fixtures4와 5언어14/100/UI121, scope139, context323/links124/
invariants15/open proposals0, queue73/in_progress71/max_batches2를 통과했다.
lane에 audit.py가 두 번 포함된 것은 서로 다른 증거로 더하지 않는다.
별도 `en_coverage_check.py`는 `EN coverage: clean (no Korean leaking to EN players)`였다.

실패 파일은 strict UTF-8 decode·메모리 compile이 원래부터 정상이었다.
신규 fixture12의 긴 리터럴만 인접 리터럴로 나누고 실제 CLI 검사 교훈 주석1줄을 더했다.
전체 AST SHA `bc074b0f0d4ee918ec1553c851c4cb293abc31be3f75129424bcbbe172f6704c`와
fixture12 값은 전후 exact, 최대 물리행은3200→952B다. 검사 의미·번역·production guard 변경0.
최종 self 파일은431288B SHA `a32b7a40ccaf16affe8b13cc1cf9df480c85bd23cf93fe7f89e3709579d5b272`다.
위 전량 증명 시점의419344B 지문을 이 최종 파일 지문으로 소급 교체하지 않는다.

해당 실패 검사만 실제 CLI로 1회 다시 실행해 exit0·226 tests·
`FULL_GAME_LOCALIZATION_SELF_TEST_OK cases=226`를 확인했다. 최종 관련 검사12개는
이 표적 재실행까지 합쳐 해소됐으며 전체 lane을 다시 실행했다고 하지 않는다.
stdout372B SHA `e86c8616cef36bb77bf87ff1e8d6642423ed1ce287386ca39bf7e3c92fe8c12a`,
`order210-self-cli-format-proof.json` SHA `7b939b834286322f3e378564268aa6cc3e3feb1c11277cc28bb70405bae07079`.
ZH의 기존 `shared_han_jp_first=1 status=blocked`는 그대로이며 원어민·렌더 PASS가 아니다.

독립 최종 영수증 `order210-independent-final-receipts.json` 90306B SHA
`8c72bc1f305131d67884913c9f0cba39898dbf7929ae57792cd85710f885218b`:
initial previous=null·final source/response/receipt6·raw18·새714·기존30678 값/순서/
raw prefix와 기존b73/meta9를 대조했다. 새714/배치2를 역적용하면 기존 원장 바이트가
exact 복원된다. 검증 입력58개의 전후 seal은
`45a736c9f427987437a21170634152ac41f3818e76928565dc6e4dc22e0a5f8c`로 동일하다.

독립 scope/docs 사전 검토는 정확한 소유32경로와 기존 큐72행·상태·상대순서를 확인했다.
WORK_LOG의207절1280B만 history 앞에 exact 이동했고 기존 history62301B를 보존했다.
최종 history63581B SHA `4e266ae74fe6f2dbbfe0e099de7aeff7e49683159afe093635369b0ebf480bbd`,
EOF LF2다. 이 검사와 자동 수용은 인간 L3·native·render·full GO를 대신하지 않는다.
