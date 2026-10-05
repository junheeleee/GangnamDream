# ORDER-464 — 정선 카지노 허브의 중국어 안내·조작 문구

#### [x] ORDER-464 [P1·현지화] 기존 허브9키를 간체·번체로 읽는다

## 완료 (2026-10-05)

- source/공식수용 한정. [독립 전수 보고](../agent_reviews/ORDER-464.json).
  제품`dd1c3915f7cb6c9e9c609ee35dc071269893ad99`는 사전2개/원장만 변경했다.
  사전각1776→1785·accepted41755→41773·batch231→233·JA3053 불변이다.
- 공식 export/check/import 각지역9값,4raw역상·3141중비소유3138바이트 동일이다.
  실제12호출의 의미를 전수읽었고 source_revision/selection/원header/receipt SHA를
  결속했다. 기존 규칙·정산·저장·공개·사람·224판정/202보고는 불변이다.
- clean제품에서 `.git/full-game-localization/order464-normal1/result.json`
  SHA `32cac4131de86ecb8b5b3b1cc0f83fb3b98c457a98ced7ee4fa773ab56aa446b`,
  current365470.767761초·ZH skeleton34.427529초 모두exit0/정확marker/stderr0.
  tracked3141/HEAD/tree/status·보호11그룹57파일은 전후동일이다.
- 후속`ef16809f6af4a3606c8012498b293304d1fdb156`는 CLAUDE 상태3행뿐이다.
  그후보에서 위명령을 다시돌렸다는 뜻이 아니다. 실제렌더/입력/원어민·본편/출시는
  미관찰/HOLD, 전체중국어완료0이다. 자동통과는 계약 증거이고 새정본 승격0이다.

**[~] 착수 — 2026-10-05.** 부모157. 149/463 source 수용 뒤 Mac잠금과 무관한
기존 UI 누락을 수리한다. 정선 카지노의 아래9한국어키는 JA에 있고 CN/TW에는
없다. 각 지역 한국어 직접저작9값씩, 총18값만 추가한다. 새게임/문안/규칙0이다.

## 정확한 배치

| KO key | 실제 reader (`scenes/`) |
|---|---|
| `처음 왔군요.\n화려한 조명과 기계음이 섞인 공간 — 이곳이 정선 카지노입니다.` | JeongseonCasino:85 |
| `±0원` | JeongseonCasino:197 |
| `[%s] 입장  [D-pad/%s/%s] 게임 선택  [%s] 규칙  [%s] 용어집  [%s] 나가기` | JeongseonCasino:211 |
| `선택: %s` | JeongseonCasino:224 |
| `정선 카지노` | JeongseonCasino:281 / MainGame:11734,11753,15776 |
| `원하는 게임을 선택하세요` | JeongseonCasino:307 |
| `도박은 중독성이 있습니다. 적정 한도 내에서 즐기세요.` | JeongseonCasino:373 |
| `용어 설명` | JeongseonCasino:381 |
| `입장` | JeongseonCasino:491 |

입장경로 MainGame:15776→17713→JeongseonCasino.open. 기존 첫방문/회복잠금/
세션조건을 바꾸지 않는다. 패드6인수는 south/L/R/north/west/east이며 순서·공백·
기호·개행을 보존한다. 첫방문안내는 KO를 원문으로 하며 EN의 felt tables를 넣지
않는다. 지명은 기존旌善/카지노 용어와 일치시킨다. ±0은 손익0원이지 잔액이 아니다.

깊이3문: 없으면 허브의 안내·게임선택·중독주의가 영어로 남는다. 선택/24주후 상태는
불변이며 언어만 바뀐다. 짧은 조작 안내와 정확한 행동/통화 의미가 같은 폭에서 경쟁한다.
기존286/290/294/301 버튼·HUD·정산/하위게임·용어집 본문·블랙잭 의심 규칙은 비소유다.

## 파일 소유

- root 제품: `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json`의 정확9키씩,
  `content/meta/full_game_localization.json` accepted18·공식receipt2batch append만.
- claude_handoff_review: `.git/full-game-localization/order464-cn-draft.json`만.
- receipt_tests392: `.git/full-game-localization/order464-tw-draft.json`만.
- independent392: 비저자18값/공유reader/실제수용증거 전수검수 및
  `docs/agent_reviews/ORDER-464.json`만. 원어민 증거를 발급하지 않는다.
- root 기록: 이 사양→archive, 큐/L3순번, CLAUDE현재행·WORK_LOG최상단·생성STATUS·
  agent_review_decisions 신규464행. private `order464-*` 목록/교환/helper/로그만.
- 원문/KO·EN·JA/런타임/collector/history/pin/공개manifest/사람원장/실제저장/
  프로젝트 설정은 바꾸지 않는다. 사전각1776→1785/accepted41755→41773/b231→233 예상.

## 표적 검증

선언커밋 이후 공식 export→지역별 저작→check→한국어 대조→공식 import의 출력을
apply_patch로 적용한다. 공식 atomic writer만 patch출력으로 연결하고 검증은 바꾸지
않는다. 실제receipt의 source/target·header·canonical digest를 원장에 복사한다.
기존 `ui_translation_append.validate_append`로 raw역상/신규18핀/2batch를 증명한다.
새 검증 도구·source adapter·차선 신설0; 기존442의 제한된 교환 helper를 재사용한다.

새 clean후보에서 `order365_ui_receipt_compat.py` 기본1회와
`zh_translation_audit.py --lang all` 기본1회, 영향목록 조회·context/queue·diff 및
마감 metadata검사만 수행한다. full-body는365를 포함하므로 중복 실행하지 않는다.
기존 self-test 전량/JA·EN·서사4종/엔진/240주/패키지 재실행0, 신규관측으로 쓰지 않는다.
실제허브3상태×CN/TW 화면·물리입력·원어민·정상플레이는 NOT_RUN, rendered/native OPEN.
실제화면이 필요하면 잠금해제 후 별도 선언하며 과거 카지노 화면 증거를 상속하지 않는다.

완료범위는18값의 의미/구조/공식수용뿐이다. 149/457/302runtime·본편/출시는 HOLD.
자동통과는 계약 증거이지 재미·문체·사람/출시GO가 아니다. 규범은 기존I18N/WORK_UNIT
적용이며 위9키/파일소유/단계는 일회성; 새정본 승격0이다.
