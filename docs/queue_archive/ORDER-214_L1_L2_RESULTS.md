# ORDER-214 — 생활 선택·부채·직장 번역 검토

> [x] 완료 — 작성자와 다른 최종 검수에 따른 작업 단위 GO. 본편 전체 HOLD.

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

## 정확 교환과 수용

final source 제품 ed8067c421d646abb015a6ef8521a4eaaf9eb290,
tree6060537bcf84424e615058a0611c7ec0eac2e0d6에서 각169문구를 export했다.
finalsource/response의 헤더·source·previous/current target과 receipt가 일치한다.
세 check/import --accept 모두169, changed_files=0이다. 교환12개를 보존했다.

| locale | batch ID | receipt 파일 SHA256 |
|---|---|---|
| ja | 6276a08c8efbb5579a8e8458be30cae58560c2baed61e9a2b2ad0aa335c42371 | 7e679f3fe535c3070ad7fc769dc2c0c14a8a8d649f10a173bfe6153909723cfa |
| zh-CN | e5468784eae8575b117632829533e99d99c5d7718d5191dc89743ddd9109b8db | d172205312c26e41e9bdf6581d4b20ea931542e510541236894ee522e6bfd21f |
| zh-TW | fca9e946c29906e860ec86f7fc37a684f6f41afec6b4bc954d346ba8c83c9cec | 4c29b397edd3a386a304a81a150131e74668412fc36cd0f98532f36f55490649 |

수용 전 기존32,484와 신규507의 source/target hash·L1을 전량 실행해 오류0이다.
입력30경로 전후 불변이며, 수용은 신규507만 append했다. 각10,997·총32,991/b79,
메타9·옛32,484의 값과 순서·b78·나머지 top-level 원형을 보존했다.
신규507/b79를 역제거한 raw가 옛8,425,796B/
b73d519bdf516eacb2a2db2a7b72242fe5ff0397b85a5aa8ae5dc4217076a3f5와 정확히 같다.
새 accepted SHA cef066d7685c1f2dbfe0bd57d236436c4379fb8de01a683ab3d6e54c5840e5cf,
portable8552044B/32283da99eaa76b409da6dba65fc158eeea4bcafdd4f6cc3c229512163c9aaa5.
사건1,468종9,929문구/locale, 남은 shipping 비보호226종1,649문구다.
author_only105종741·공개 보호2·UI·표시 소비자는 이 잔여와 별개다.
명시 차선과 독립 최종 후보 판정은 아래 최종 절에 기록한다.

이 오더의 수량·소유·검증 지시는 일회성이다. 지속 번역 규칙은 기존
I18N_INFRASTRUCTURE, 위임된 최종 판단은 WORK_UNIT이 소유한다.

## 최종 통합 검사와 독립 판정

판정 source: 3ab1391ff476bbb8a857e12dc0a6267de0ac1123,
tree23c66e2e4fea39bf81dc7573a8aeabb9ad3ba760.
최종 차선 실행96c0db4417ad188478632af6dbb93a093675fe67에서 이 source까지
차이는 CLAUDE 현재 상태 한 줄뿐이다. 제품·검사·번역·portable·인간 원장은 불변이다.
CLAUDE 표적 검사7개도 통과했다(서로 다른 품질 표본으로 합산하지 않는다).

full-game-localization-overlays --list 후12개 실행 PASS. 목록의 audit.py는
기존 등록상 두 번이며 고유 명령11개다. 서로 다른 검증으로 두 번 세지 않는다.
full body52, 번역 self231, JA69, ZH11,589, 데모 변이4와5언어 공개 패리티,
정적 ERROR0/WARNING0, EN 노출0, context·queue·scope 검사를 확인했다.
실제 출력은 private/order214-final-named-lane.json에 보존했다.

Rawls는 작성 번역의 별도 영수증 검수자로 교환12·신규507·현재 KO/target18·
세 receipt selfhash를 재계산했다. 옛32,484/78배치/meta9의 raw·순서를 보존하고,
역제거한 portable가 실제 Git baseline과 byte-exact임을 독립 확인했다.
JA4/CN3/TW3 역치환18개와48입력 전후 불변도 통과했다. 전체 L1은 반복하지 않고
ROOT가 실제 실행한 증거30입력을 현재29+portable Git 원형에 결속했다.
최종 독립 보고 order214-independent-final-receipts.json 41462B /
5ca16476ae65c9318fa0be2fa18788402f1a9c6fe789b97ba314f397c726d917.

판정: **ORDER-214의 번역 저작·텍스트 수용 범위 GO**, 필수 잔여0.
JA는 Plato, CN/TW는 ROOT의 작성자와 다른 전수 대조와 위 실제 수리를 근거로 한다.
전량 번역 가드의 자동 PASS만으로 문체 GO를 발급하지 않았다.
원어민 독해·실제 렌더·인간 플레이·물리 입력·전체 게임 품질은 미관찰/미판정이다.
사람 원장을 닫거나 본편 HOLD/INCOMPLETE를 바꾸지 않는다.

## 선언 사양 원문 — 아래 상태는 착수 시점의 역사

활성 사양은 원형 그대로 보존했다. 위 완료 판정이 현재 작업 상태다.
아래 파일 소유·수량·순서는 이 작업의 일회성 지시이며 새 작업의 권한이 아니다.

```markdown
# Active Queue Spec: ORDER-214

> [~] 착수 — 만지는 파일: 아래 정확 소유 범위만.

#### [~] ORDER-214 [P0] 생활 선택과 부채·직장 연쇄

기준 main eb8f7aaa825491905294822c468b1f0820b9f345. 사용자 최신 전체판 번역·최종 검수 위임을 근거로 아래 사전 권고를 공식 실행 사양으로 채택한다. 사전 권고의 미선언 문구보다 이 선언이 우선한다.

## 깊이 3문

1. 원문 사실과 실제 검수 근거를 지켜 후속의 신뢰를 만든다.
2. 선택의 대가와 이전 판단의 한계를 시간이 흐른 뒤에도 보존한다.
3. 작업량이나 자동 통과를 작품 품질·관찰하지 않은 증거로 바꾸지 않는다.

## 정확 24 ID

- amb_jeonse_00
- amb_jeonse_check
- amb_jeonse_confront
- amb_hoesik_00
- amb_hoesik_drink
- amb_hoesik_dodge
- amb_coin_00
- amb_coin_warn
- amb_holiday_00
- amb_holiday_home
- amb_mlm_00
- amb_mlm_meet
- amb_health_00
- amb_mlm_aftermath
- amb_mlm_aftermath_father_passed
- amb_wallet_00
- amb_wallet_return
- amb_jobswitch_00
- amb_jobswitch_in
- amb_wallet_payoff
- amb_parent_hospital
- amb_guarantee_00
- amb_credit_steal_00
- amb_credit_confront

## 권고 판정

필수 범위 결함 0. 24종169문구를 **A 한 배치**로 선언한다.
원문6파일과24객체의 전체 지문 및169 source hash는 기존 preflight와 정확히 같다.
기존 preflight는212 수용 전 관측이므로 원장/기준제품만 현 main으로 갱신한다.
이전45입력 중 변경은 portable 한 파일뿐이며, 원문·연결/메타/런타임 입력은 그대로다.

- 일반 본문166 + `amb_guarantee_00.description_memory_if_known` 3 =169.
- 선택59, LF226, `{name}`81, 원문11,137자. 세 언어507문구.
- source aggregate: `ef6ef26d66b9173feeaf87ba9c813522ab71e3407403cbbab51324c3aaeb1e40`.
- current portable:32,484(각10,828)/b78/meta9.
  accepted SHA `d05b3933a7d9190ba9e37c2d00d74a3b0d031ef29a641b78bbef678814e35c1e`.
- 계획 완료:32,991(각10,997)/b79/meta9. 실행 전 수용으로 세지 않는다.
- 대상18파일 부재, 다른 동명/별도 locale 파일에서 선택ID 충돌0, selected accepted0.

## 정확한 저작 소유

각 언어 작성자는 `content/events_<자기 locale>/` 아래 다음6개 신규 파일만 소유한다.
locale은 `ja`, `zh-CN`, `zh-TW`이며 간체/번체 자동변환·EN 중역·타언어 복사0.

| basename | roots | leaves | choices |
|---|---:|---:|---:|
| amb_scenarios.json | 6 | 40 | 14 |
| amb_scenarios2.json | 4 | 28 | 10 |
| amb_scenarios3.json | 5 | 34 | 12 |
| amb_scenarios4.json | 4 | 28 | 10 |
| amb_scenarios5.json | 2 | 14 | 5 |
| amb_scenarios6.json | 3 | 25 | 8 |

행은 각 KO 파일 상대순서, 선택 배열은 KO 인덱스 그대로 쓴다.
허용 필드는 `id/title/description/choices[text,result_text]`와 원문에 존재하는
`description_memory_if_known` 세 키뿐이다. 기억 키/순서도 그대로 둔다:
`last_payment_endured`, `last_payment_spoke`, `last_payment_smiled`.
조건·효과·flag·태그·portrait·배경·opportunity·후속 연결은 복제하거나 수정하지 않는다.
기억 필드는 기존 collector/내장 overlay/StoryMode/검증 계약이 지원함을 소스에서 확인했다.

사별 MLM 대체는 hidden/weight0이지만 shipping 대상이다. 생존판과 합치거나
author_only로 제외하지 않는다. 내부 직접 연결10과 외부 deferred2는 번역 범위 판단 근거이며
그 자체로 새 플레이·M07~M60 도달 증거가 아니다. 외부 콜백/ending은 읽기만 한다.

## ROOT 통합 소유 권고

- portable: `content/meta/full_game_localization.json`.
- 운영: `CLAUDE.md`, `docs/WORK_LOG.md`, generated `docs/STATUS.md`,
  `docs/CODEX_QUEUE.md`, `docs/CODEX_QUEUE_L3_PENDING.md`,
  `docs/queue_active/ORDER-214.md`,
  `docs/queue_archive/ORDER-214_L1_L2_RESULTS.md`,
  `docs/queue_backlog/FULL_GAME_LOCALIZATION.md`.
- 실제 오탐이 있을 때만 `tools/full_game_localization.py`,
  `tools/full_game_localization_self_test.py`, `tools/zh_translation_audit.py`를
  별도 담당에게 source-exact 표적 소유권으로 넘긴다. 필요할 때만
  `tools/audit_scope.json`의 정확한 표적 등록을 변경한다.
- KO/EN/기존 locale/공개 데모/엔딩/catalog/runtime/save/font/human/manifest는 비소유.
  213 strict historical transition 감사2도 이 번역 배치에서는 비소유다.

WORK_LOG 현재39,731B, 잔여269B다. 충분한 기록을 위해 이동이 필요하면 **선언에 먼저**
기존 완료209절 `계절·동네·취미의 한국 생활 번역` 1,300B
(SHA `832828a41c13d785a994fb6abc1f56b927c7859a34c21f93e2d6c5d5ff5cd018`)만
`docs/history/WORK_LOG_2026-09-07_localization.md` 앞에 raw exact 이동하도록 한정할 수 있다.
현 history64,946B/SHA `9a0dc936650799944ef3d9bc13f8cf4e29f9fdb6971d55b7d0d541ac28c76db6`와 끝 LF를
이동 직전에 재봉인한다. 이 선언으로 ROOT에 해당 raw 이동 소유권을 부여한다.

## 사실·후속 부채 보존선

ROOT가 직접 읽은14그룹과 기존 preflight를 공식 사양에 연결한다.
번역으로 기존 부채를 봉합하지 않는다.

- 전세: 일반 주거승급 flag를 전세계약 성립으로 확대하지 않는다.80%·보험마지노선은
  가상 원문의 주장이고 실제 현행 법률 승인서가 아니다. 이사 물색을 이사완료로 올리지 않는다.
- 코인: 대사 태호와 Hyunsu 관련 조건/효과의 차이, 전화와 표정 서술의 기존 차이를 보존.
  영상통화·현재 동석·친구에게 송금·확정수익을 발명하지 않는다.
- 회식: 현재3차, 화장실10분, 다음날 반차와 자리복귀를 구분.
  후속의 조기퇴장/회식불참으로 현재 선택을 바꾸지 않는다.
- 명절/부모: 생존 조건과 사별 대체를 나눠, 실제 수신·송금·발화·방문이 있는 곳은 유지한다.
  명절의 둘/한 그릇 원문 압축을 자의로 두 그릇으로 수정하지 않는다.
- 다단계: 월천/원문 글자수,300만원 카드빚/150만원 효과, 부모 비상금/6년 회고를 구분.
  어머니판에 현재 아버지 송금·통화를 만들지 않는다.
- 건강:119를 부르려는 단계와 실제 수액 치료를 구분. 외부 재검예약 flag 공유를 현재에 합치지 않는다.
- 지갑:30만원 주운 지갑과 별도 전무 지갑 연쇄를 섞지 않는다. 현재 명함/사례금/식사와
  후속 주말 가게일만 보존하고 회사입사·새 면접·일당60만원을 추가하지 않는다.
- 이직: 제안 연봉1.5배/조건부 옵션과 실제 사직·새 사무실을 구분.
  소스에 없는 job/salary 효과나 확정 현금화·후속 A라운드 보완을 만들지 않는다.
- 병원:부친 수술500만원은 후속의 부모빚 상환과 다르다. 거절 뒤 결과는 미정이며
  본문에서 실제 대출로 수술을 돕는 가지를 효과0이라는 이유로 지우지 않는다.
- 보증:20년 익명 고교친구, 보증 거절/실제 도장/도움 제안을 나눈다.
  c2 효과-30만원만으로 송금·합의를 추가하지 않고 기억3은 과거 창구의 회상으로 둔다.
- 직장 공로: 금융 신용으로 번역하지 않는다. 임원에게 원본 실제 송부·인지,
  부장의 동시이름 약속과 실제 향후 등재를 구분한다.
- 대부분 callback `min_turn`은 절대 하한이다. 이번 명시 deferred12주/8주 외 값을
  앞 사건 이후 지연기간으로 발명하지 않는다. 원문·후속 소비자는 전부 비수정.

## 검증 순서

1. 정확한 공식 선언 HEAD/clean과 KO6 지문, root24/leaf169, 미수용169·target18부재를 다시 봉인.
2. **원본 main의** `git --absolute-git-dir`는
   `/Users/junheelee/Documents/GitHub/GangnamDream/.git`다.
   initial은 `f.private_dir`가 가리키는 `.git/full-game-localization/<locale>/full-ko-direct-2026-09-07.1`
   에서 해석한다. 기존 WT의 `.git/worktrees/checkout2` 경로를 자동 복사하지 않는다.
3. export `--group events --ids <정확24ID 쉼표목록> --limit 169` 한 배치/locale,
   헤더 포함170행×3. previous는 JSON null이 아니라 `digest(None)` 문자열이다.
   507 null/source169/locale/manifest/batch·selection hash와 선언 HEAD를 저작 전에 검증.
   export rows의 leaf-ID 정렬과 locale파일의 KO행순서는 서로 다른 계약이다.
4. 세 작성자가 KO에서 독립 직접 저작. 전량 자체 의미대조·shape/LF/token/source/current L1,
   3파일이 아니라 자기 언어6파일 raw와169 ID-keyed records 지문을 동결.
5. 작성자가 아닌 담당의 전량169 L2. 제안된 정밀화만 ROOT 적용하고
   exact inverse raw18/나머지불변/기억3 보존 확인.
6. 자연문 오탐은 원문+타깃+typed error로 보존. 수정 전에 normal/자연변형/mutant/source-OFF 봉인.
   본문을 검출기에 맞춰 왜곡하거나 숫자값을 상수로 덮어쓰지 않는다.
7. current target hash 기준 final export3→response3→check/import --accept3.
   initial3+finalsource3+response3+receipt3=12교환파일의 결속·selfhash·target exact 확인.
   신규507만 append하고 old32,484/순서/b78/meta9/나머지 top-level 원형을 보존한다.
8. 수용전량 source/target hash·L1, named overlay lane `--list` 후 한 번,
   EN/context/queue/index/diff 및 생성 STATUS를 확인. 전체 audit/Godot/240주를 합산하지 않는다.
   자가·독립L2·자동검사·노출후회귀·사람 판정은 각자 분리한다.

원문/지침/기존 proof21 입력 전후 SHA:
`f0229395c7866021265c65ab535907cb2f60350aceb18fd62a04e776caab09be` 동일.
현재 범위는 번역 저작·텍스트 수용의 한 배치일 뿐이다. 전체 INCOMPLETE/HOLD,
원어민·화면·L3 OPEN을 자동 결과로 닫지 않으며 최신 사용자 위임의 정확한 판정 범위는
ROOT가 별도 근거로 기록한다. 이 시안의 작업 지시는 일회성이다.
```
