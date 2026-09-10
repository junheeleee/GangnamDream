# 관계 이름·새 로그 표시 현지화 — 결과

[x] ORDER-239 — 2026-09-10 완료. 역할14와 이를 받는 기존 로그6의 JA·CN·TW 60값을 수용했다.
저장 원문·기존 로그·관계 단계·효과는 그대로다. 이 보고는 작업 단위 증거이며
본편 GO나 실제 화면·원어민·인간 플레이 판정이 아니다. 최종 source 판정은 아래 마감 절에 별도로 결속한다.

## 제품과 수용

- 기준 `3f13efd60f485d9e6bb267ecaabdca3c35797333`, 선언 `30b4447941d6f2c246d085b834dc26cb4a56df7d`.
  runtime/collector checkpoint `978a9ed670105b023059a38e4377d1e1c73ba208`,
  UI·최종 격리 검사 checkpoint `b5e2e22baf757c94a6942505aff4bbc6880a3aa3`.
- exact KO14만 표시명으로 투영한다. ID·부모 생사로 이름을 추론하지 않으며
  custom/기번역/빈값/공백/부분일치는 원문 그대로다. 변경된 물리 이름 읽기4,
  논리 표시·로그 소비자7. getter와 wrapper4를 역제거하면 runtime2는 기준 raw와 같다.
- JA 기존7은 불변·신규13, CN/TW 신규각20: 새 값53·새 수용60이다.
  UI3의 추가행과 마지막 쉼표를 역제거하면 기존 raw와 같다. event overlay 변경0.
- 공식 initial20×3은 clean978a9ed에서 UI 저작 전에 export했다. final20×3은
  cleanb5e2e22에서 export/check/import했다. import 각20/changed_files0,
  INCOMPLETE·human OPEN이다. 이전 target hash 외 초기·최종 원문 필드는 같다.
- portable 신규60/b1 외 역복원 exact. 기존38,437/b96/metadata9와 역사 top-level
  source_revision/source_counts/coverage_boundary는 불변이다. 현재 수용38,497/b97/meta9:
  JA12,831·CN/TW각12,833. 언어별 events11,578(1,694roots), endings234, catalog834,
  UI185/187/187. 비보호 shipping event 미수용0은 전체 UI·렌더·원어민 완료가 아니다.

## 번역·코드 독립 검토

Poincare가 KO 실제 생산자와 20×3·EN14를 전량 읽었다. 초기 CN/TW 카페 친구는
상대가 단골손님이라는 오해를 만들 수 있어 직원인 원문의 관계로 수리했다.
선택 정밀화는 EN 전 연인의 romantic 명시와 JA 소개된 상대의 단계 중립화다.
JA의 최초 번역이 과거 만남을 발명했다는 ROOT의 중간 의심은 철회했다:
선택 결과가 실제 카페 입장·대면을 명시한다. 필수 수리는 CN/TW2이며 JA는 선택 수리다.
최종 target60 중 초기와 변경3·불변57, EN14 중 변경1·불변13. 잔여 필수0.

collector는 기존 unsupported helper를 보존하고 exact14 getter와 caller4·parent4가
연결된 이름21위치만 별도 resolved evidence/UI leaf ID로 분리한다. 새 event leaf는0이다.
알 수 없는 이름·누락키·알려진 연결 단절은 unresolved로 남는다. 현재 JA 실제 inventory는
calls3356/legacy3322/KO2848/static+context2877, context34calls/29IDs다.
역사 manifest와 기존 choice-preview19 기대값은 그대로이며 현재 수집 결과를 필터하지 않는다.
기존 full self256·277methods raw 보존, 새 테스트2로258이다.

이 recognizer는 현재 소스의 유한 토큰 계약이지 임의 GDScript 도달성·미래 alias의
일반 증명이 아니다. 현재 실제 경로를 직접 읽고 격리 실행으로 별도 확인했다.
기존 romantic 유형의 `연인/Partner`는 소개팅·썸·전 연인에도 붙는 별도 결함이다.
유형·호감/신뢰·효과 hint·빈 VIP 등은 이번 이름/로그 범위 밖이며 전체 패널 GO로 세지 않는다.

## 실행·회귀와 실패 원형

- 첫 선택 L1 60/errors0. author targeted는 JA 신규10+기존19 및 full self 신규2 PASS.
  입력15 전후exact. 명시 `relationship-display-localization` 첫 실행8 PASS:
  full self258, EN leak0, JA self98/UI2848/context34/34, registry142,
  queue fixtures25/fence4, agent222, context/queue.
  `order239-named-first.json`은 실행 뒤 기록한 결과 요약이며 full stdout이나 전후 manifest가 아니다.
- 실제 Godot4.6.2 격리:13가족×KO/EN/JA/CN/TW=65 고정 경우.
  실제 Label·VIP·종료·passive4, exact/custom/shared-ID/생사/최초 저장명·언어전환·
  메모리 serialize/JSON.parse/load를 검사했다. 승인20×5를 fixture에 내장했으며
  private 기대표에 대한 runtime 의존은 없다. 기존 AP/VIP를 제품에서 다시 열지 않았다.
- invocation1은 예약어 namespace parse, invocation2는 Variant→bool 추론으로 각0경우 실패.
  식별자/명시형만 고쳤다. 첫 완주 invocation3은 표시65 일치·상태60/65 PASS였고,
  저장 roundtrip5가 JSON 정수→실수 타입 비교 때문에 실패했다. ROOT는35경로의 값·문자열·
  keyset·순서 불변을 독립 확인했다. 최초 결과에서 플레이어 이름을 별도 관측했다고 쓰지 않는다.
- parsed payload의 관계/로그를 load 전에 deep-copy해 기대 상태를 고정한 뒤 동일65를 재검했다.
  최종 invocation4는65/65, state_ok65, 기대문자열65 및 기존 실제 표시65 모두 일치.
  플레이어 이름5도 직접 `QA Custom Player`로 관측했다. 입력13 전후exact,
  memory restore1, engine exit0, stderr/fatal0, process/storage 오류0.
  exact marker: `RELATIONSHIP_DISPLAY_CHECK_OK cases=65 locales=5 names=14 parents=6 isolation=preautoload rendered=0`.
- 기존 pre-autoload bootstrap·fresh namespace·process group helper를 재사용했다.
  project와 기존 저장 영역은 수정하지 않았다. 임시 evidence·격리 storage·실패 원형은 보존한다.
  이는 실제 렌더·전체 패널·기존 플레이어 disk save 왕복·정상 속도 플레이 검사가 아니다.
- 최종 전체수용 hash/L1 38,497/errors0, 입력1,183 전후exact,70.085471625초/1회.
  input manifest `f1273c725a5fd1ab8df70e5e82d8e5aac6cb16b6f0fe1c5073220cf9606bb129`,
  현재 source manifest `d6395149ccb1babcfa4402d9cc5c7709656fa1f755915f49a4df7fee556cd416`.
  전체 감사·240주·공개 패키지 재빌드·실제 화면 판정은 실행0이다.

## 증거 핀

아래 파일은 `.git/full-game-localization/`의 보존 증거다.

| 파일 | SHA-256 |
|---|---|
| order239-translation-final.json | `72565027bfb179977687662a908a4923da8310cb2ebbd3670c267e909fb00089` |
| order239-language-review.json | `5ac24043d497133f01068b0bfffba506c86a789b1871b5d559611e88c9be5918` |
| order239-code-static-review.json | `5bc51e9a5f20c8a0fa921d4bb8ad7e0b33af00647b95e32b3d5787bf7e718309` |
| order239-author-first-targeted.json | `22d60e9e547c74c0263114137f3dd36e2fbd9a548a8f1409dc924d5530307781` |
| order239-root-json-roundtrip-adjudication.json | `7977dba91fd21dc463340a0c4b07dd3587fc14332c80494f9e9596e66179e09f` |
| order239-relationship-display-final.json | `c16ab1859f1a3e68e5deb9776a1638a4a283794325303d297dd5ab8edbf6b119` |

공식 receipt SHA: JA `0140365459c9d9046ad6e4f6a2d9fdfc17504cda7eb77f22e6cb3391bd4aae94`,
CN `fb78b7b40ad73645b747041b4a880cdc6ed088bdd97cb454b3dc13b6267e3e39`,
TW `3537d1838d665fc7a64ae8beac50520111c1fc07e25646ae7b7f3b5e3a621c50`.
portable SHA `44fd6ae8229c322c61a136c64c85255015e6bf7db05208f867065a39d94a8e71`.
실제 최종 runner는 `gangnam-relationship-display-rfikth4_` 디렉터리의119173B,
SHA `ab6924db5d88a1513c592238a4864960e3e59cb4cf3a803c753deaabffeb2b65`이며
전체 절대 경로·stdout/log·격리 storage·실패 시도는 위 final JSON에 있다.

## 작업 단위 증거·보존선

```text
도달 경로      : RELATIONSHIP_DISPLAY_CHECK_OK cases=65 locales=5 names=14 parents=6 isolation=preautoload rendered=0
생산자 ↔ 독자   : KO 역할21위치/14키 ↔ systems/RelationshipSystem.gd:7 ↔ scenes/MainGame.gd:9859,18305 / systems/RelationshipSystem.gd:49,69
바꾸는 상태     : UI 미번역53 → 번역53; 수용38437 → 38497; 저장명/ID/이전 로그/효과 변경0
포기 시 잃는 것 : sidebar/VIP/종료/passive4 (해당 기존 소비자 호출 시); KO 원문 표시21위치
서사 위치       : M01~M60 기존 관계 공용 표시; story/event 변경0
장면 계층       : 신규 T1/T2/T3 장면0 (공용 표시 소비자 수리)
닫는 것         : exact 역할14·새 부모 로그6의 세 언어 표시; 전체 패널/본편 GO0
```

완료229/228 원문2,037B를 WORK→history로 raw 이동·역복원했다. 새 완료 절만 WORK에 추가한다.
큐 기존75행·agent 기존25판정은 원형 보존하고 이번 단위만 닫는다.
인간103390B SHA `6ab5c927c9f327aa2892c231d49fe144c1c154cb6069fc539f4f3f8e9c30c9f6`,
project4699B SHA `78e98d7bdc1349570df6f2cc7ca6cbb11d4fc5451f5bbfdd338561653c7380c5` 불변.
역사 demo manifest75684B SHA `9d50b64e6bc09d8e3e8e670fc48163ed5a0a419263cd0ffc601aac45c7abc7b6` 불변.
GameState/LocaleManager/DataRegistry/SaveManager·KO3·event overlay12·폰트·공개 언어 변경0.
공개 M01~M06 GO1·인간 OPEN45·본편 HOLD를 유지하며 옛 패키지 실물 재검증은 주장하지 않는다.

규범 승격 없음: 기존 I18N/WORK_UNIT을 적용했고 이번 범위·배치·증거·마감은 일회성이다.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.

## 정확 source·독립 최종 마감

제품 source `ea47abc4584a1f84bb7433d3ea06a58ce784e0e6`, tree
`eeb78a3b6f323d803ef6ae69b34af5e7ce351495`. Poincare가 독립 최종 검수한 이번
work_unit239만 GO/필수0이다. [최종 직접 검수](../agent_reviews/ORDER-239.json),
SHA `e764fd7ce6c6924459a29e2b252af24dc7b57583c7dcad76a454110aae5d9512`. 기존 언어/코드 검토와 최종 실제65·공식수용·전량L1의
입력 지문을 현재 source에 결속했다. Rawls 공식60·원장 역복원/보호7 RO 대조도 필수0이다.
source commit 이후에는 허용된 metadata wrapper만 마감하며 본편 HOLD는 그대로다.

## 선언 원형 — 착수 사양 보관

# Active Queue Spec: ORDER-239

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-239 [P0·현지화] 관계 이름과 새 관계 로그의 언어를 연결한다

**[~] 2026-09-10 Codex 착수 — 아래 파일만 소유한다.** 기준 clean
`3f13efd60f485d9e6bb267ecaabdca3c35797333`, tree
`6180f255e17752201ad19f332fe3ac43f24aca65`. 기존 관계 표시명21위치/14종의
저장 원문은 유지하고 표시 소비자만 연결한다. 준비 증거는 git-private
`order238-next-relationship-display-preflight.json` 및 `order238-relationship-collector-impact.json`.

## 깊이 3문과 판정 단위

1. 제거 시 결손: 번역된 사건을 골라도 관계 Label·새 로그에는 KO 역할이 그대로 남는다.
2. 24주/5년 상태 차이: 표시 언어만 바뀌며 ID·저장명·호감/신뢰·확률·돈·부모 생사 변화0.
3. 경쟁 대안: gameplay overlay나 저장명 이주 대신 exact 원문→표시 투영을 선택한다.

하나의 소비자 수리다. [첫 실행 재조정] 파일1~3 가정은 runtime+collector 배치와
UI3 배치로 분리한다. 표적은 역할14 + 이 이름을 받는 기존 로그6 =20 원문이다.
JA 기존7 보존·13신규, CN/TW 각각20 KO 직접 신규: 신규값53, 신규수용60 예상이다.
성공 전 이 수를 실적이라고 기록하지 않는다. 검수는 표본 대신20×3 전량이다.

## 정확한 소유권

- Plato: `systems/RelationshipSystem.gd`, `scenes/MainGame.gd`의 표시 함수와
  sidebar/VIP/종료/passive 이름 인수만; `tools/ja_translation_pipeline.py`의 exact14
  현재 inventory 추가(고유키13)와 자기회귀. 역사 manifest/107키/34 migration은 불변.
  `tools/full_game_localization.py`의 exact resolver/caller가 연결된 관계 진단 분리만,
  `tools/full_game_localization_self_test.py`의 새 표적 회귀. 원래 unsupported helper와
  기존 fixture/기대값을 지우지 않는다. 신규·누락·미확인 경로는 계속 unresolved다.
- ROOT: `locale/ui_ja.json`, `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json`의 선택20만.
  `content/meta/full_game_localization.json` 신규60/b1만. 역사 top-level 분모·기존38437·
  b96·metadata9는 보존하고 현재 resolved 관측은 결과에 별도로 둔다.
- Rawls: `tools/RelationshipDisplayLocaleCheck.tscn`(embedded GDScript),
  `tools/run_relationship_display_locale_qa.sh`. 기존 StoryNameplateBootstrap와 격리
  storage/process helper는 읽기 재사용하며 원본 수정0. Godot 전 pre-autoload namespace,
  실제 post namespace, 시간제한·프로세스 종료·오류 양쪽 로그·exact marker를 검증한다.
- ROOT 운영: `tools/audit_scope.json`, `CLAUDE.md`, `docs/CODEX_QUEUE.md`,
  `docs/CODEX_QUEUE_L3_PENDING.md`, 이 사양과 `docs/queue_archive/ORDER-239.md`,
  `docs/WORK_LOG.md`, `docs/history/WORK_LOG_2026-09-07_localization.md`,
  `docs/STATUS.md`, `docs/queue_backlog/FULL_GAME_LOCALIZATION.md`,
  `docs/agent_review_decisions.json`, `docs/agent_reviews/ORDER-239.json`.
- 사적 준비·검사·검수: `.git/full-game-localization/order239-*` 및 공식 도구가 정한
  이번 source/target batch receipt만. Poincare는 비저자 전량 의미·최종 품질 검수.

## 원문과 안전선

가족, 강남 인맥, 부모님, 사업 파트너, 새벽 통화 친구, 소개팅 상대, 썸 상대,
업계 지인, 옆방 이웃, 인생 멘토, 전 연인, 직장 선배, 친한 친구, 카페 단골 친구.
같은 parents_family라도 부모님/형/사별 뒤 어머니가 다르다. ID/생사 flag로 이름을
재추론하지 않는다. exact14 외 custom·기번역·빈값·부분일치·공백은 그대로다.
카페 친구는 실제 직원이며 새 단골손님/점주·동거·상사·확정연애/재결합을 만들지 않는다.

기존 로그6은 관계 종료1·passive4·VIP 유인1이다. CN/TW 부모 템플릿도 번역해
영어 문장+번역 이름을 완성이라고 세지 않는다. affinity5·누락명 fallback2·빈 VIP
등 나머지 표면은 이번 번역 분모 밖이다. 기존 로그를 소급 재번역하지 않는다.
legacy VIP/AP는 격리 함수 호출 회귀이며 플레이 노출/반복 행동판 부활이 아니다.

KO3파일·12 event overlay·GameState/LocaleManager/DataRegistry/SaveManager·폰트·
project/SHIPPING_LANGUAGES·플레이어 저장·공개 M01~M06·인간 원장은 비소유다.
공개 GO1/인간 OPEN45/본편 HOLD, native/render/play/physical 관찰은 별도로 유지한다.

## 실행·증거 순서

1. 선언 commit/push 뒤 Rawls는 별도 승인 기대표와 기존 효과를 코드 전 고정한다.
   runtime/collector를 먼저 checkpoint하고 아직 UI를 건드리지 않은 상태에서
   공식 initial20×3 export한다. 신규13키가 없던 이전 원문 batch를 만들지 않는다.
2. ROOT가 KO 직접53값을 저작, Poincare가 기존7 포함60을 소비자와 전량 대조한다.
   첫 L1 진단과 실패를 보존한다. 새로운 validator 오탐 수리는 별도 선언 전 변경0.
3. actual Label/VIP/종료/passive5·5언어, exact/custom/shared-ID·생사·최초이름·
   언어전환·메모리 save roundtrip을 격리 검사한다. 표시 함수는 상태 불변,
   실제 효과 함수는 기존 수치/확률 흐름 보존을 따로 비교한다. 렌더 품질 GO가 아니다.
4. 동일 최종본문/소스로 final export/check/import 및 portable 신규수용을 결속한다.
   기존38437 hash+원형과 선택 밖 UI raw를 보존한다. 관련 collector 자기회귀와
   한정 차선1회, 전체수용 hash/L1 1회. 전체감사·240주·패키지 재빌드·공개출시0.
5. 결과 포함 exact source에서 비저자 최종 판정 후 metadata wrapper만 마감한다.
   완료228/229 원문은 history로 raw 이동해 WORK40000B 한도를 확보하고 역복원한다.

규범 승격 없음: 기존 I18N/WORK_UNIT 적용, 이번 파일·표본·절차는 일회성이다.
