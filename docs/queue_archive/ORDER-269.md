# ORDER-269 — 날짜·목표·경마 중국어 UI

[x] 2026-09-20. 독립 Poincare work_unit GO는 **164 반영과38 HOLD 분리**에 한정한다.

- 제품 `b48cbc7099c1eb5b487a264fe04a230e00ff00ea`, tree `4783c9c646cb75e83baf57e17ee5a8650adf6c30`.
- clean 검토 `e4b63b6bba1048d23017dbcd8e1661ff29513f22`; 제품 이후 STATUS 문서만 다르다.
- 20기능101키씩202초안 KO 직접 병렬 저작·비저자 전수 검수. 정보상42행 각1건 수리: REWORK2→r1 언어GO/필수0.
- 첫 기존check는 각 첫 착순 오류에서 중단. 별도101×2 전수 진단은 CN6/TW6이며 수집 exit0가202통과는 아니다.
- 착순·미터·비용 표기 기계경계4기능19키씩38을 HOLD. 나머지16기능82키씩164만 실제수용.
- 공식39614/b114/meta9, JA13096·CN/TW각13259. 기존39450 현재source/target·UI와portable raw역복원 exact.
- UI 사전합집합3015 중 CN/TW각730존재/2285부재. 전체 실제 UI 분모/완료율이 아니다.
- 보류38 r1원고는 독립 보고 held_drafts에 보존. 이전268보류62·한국어/영어·JA·runtime·공개데모·인간 원장 보존.
- fixed named12 통과는 회귀 증거뿐이며 원어민·실제화면·인간플레이·물리패드 관측이 아니다.
- 공개GO1·인간OPEN45·본편HOLD. 외부출시·스토어·지출·새 원격CI 판정0.
- 일회성: 이 배치 선택·번역·검증·수용 지시. 영속 언어/권한 규칙은 기존 I18N 정본과 WORK_UNIT 유지, 신규 규범 승격0.

자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.

[독립 보고](../agent_reviews/ORDER-269.json) · SHA 8c5a13d53aa29d6fb45adf1d2c563f908a7e58860536ebf8ae128b35b04b77aa

## 실제 실행 원문

`.git/full-game-localization/order269-<이름>.json`에 child stdout/stderr/exit·입력 핀을 보존한다.
최초 실패와 후속 진단·수용은 별개이며 원202 전체기계PASS가 아니다.

| 이름 | 바이트 | SHA256 | 결과 |
|---|---:|---|---|
| export-cn-first | 377562 | 32cceaef1aafc88054a526de4c04ab474651b13c5a55c5fc5dee533c65e59e51 | PASS |
| export-tw-first | 377569 | d9a6387ea242951ce812b5af1e1bef25fd1e6f0bdd4f9dfb5cc5523889f07502 | PASS |
| preflight-check-cn-first | 377668 | 7842fde4dc2bef54e0dd062ec233985b77a9d0d65f53e994434c076d47c23c36 | FAIL preserved |
| preflight-check-tw-first | 377668 | 64e2e150ba190c50677182c8614b9f9b751d52d079a6b4b049e7882810ceae4b | FAIL preserved |
| source-bound-diagnostics-first | 384071 | 0d4305da88bfc7b5dd139f901cf7edd52a66b7fc16cf6f6f015aa66e9350809e | diagnostic collection only; CN6/TW6 rejected |
| admissible-export-cn-first | 377620 | 231a39bc45bbb4667608a2565821cae4575c93f42de4c909ebfe1b23f21fa8a4 | PASS |
| admissible-export-tw-first | 377620 | 91c3a355acf4bd6e6ae616b12e5bbbcf575e42b064a174bac1435f977ba2d37e | PASS |
| admissible-check-cn-first | 377511 | d326ed1760af1abe17811ea8f955be6530a004977ac2fa38add78f817c5192f3 | PASS |
| admissible-check-tw-first | 377500 | da2c293c1461c7d8c989f0d32b4b34b41438697ac5423aea07cafedadcb77b85 | PASS |
| formal-export-cn-first | 377607 | 1d0e5182398486a001a43cf99b6d25f04cc871a9050b80ce914a81ca7fbfa304 | PASS |
| formal-export-tw-first | 377600 | 73690ea739e78fde071bad372739a87138f6ca1b138f5e84ca1401060d59dce9 | PASS |
| formal-import-cn-first | 377511 | c23b2df60dedcaf06cc475f34d95730ecf90d5862ba5d0e9ccfed4d7302e52f6 | PASS |
| formal-import-tw-first | 377518 | 688004b21e4ff4bb1fb395d11071ed530bff731b92163e6b782363739c673333 | PASS |
| preservation-first | 377828 | 5500c8c1c2d78136df040cef7bb3d7b966dd19f0f098079a082189db0af1f8c3 | PASS |
| named-first | 1688778 | 0dd78a73a1a5bd6084f53a00110c474206bf994cb3e87027b9a6d4d52dc4911d | PASS |
| named-outer-first | 379612 | 52c9b283a59d8af411bf441fd369968d62dcd9b8b620dd681e31ee67b0b12e5e | PASS |

## 독립 사전 검토

- `order269-language-review-first.json`: 6611B / 33aee4c0a320e23887ba39ecad383abe2162e74535d883036cc6e23f553e5e87
- `order269-language-review-revision1.json`: 4011B / ce10139320bae4d95b08dc2c9d6789f2d8e3295a5b74a08c1d35375603ddd32f
- `order269-machine-boundary-review.json`: 8750B / 5b041be160e06e4c9ff70a05897b1904f14ac8a60e4abfd096fa3f887dd2eb2b

## WORK 마감 전 원문

# Gangnam Dream Work Log

> 이전 WORK·이번 선언·첫 실패 원문은 [268 보존본](queue_archive/ORDER-268.md)에 있다.

## 2026-09-20 (Codex — 날짜·목표·경마 중국어202 착수)

- [269](queue_active/ORDER-269.md): 20기능101키씩 KO 직접 병렬저작·독립전수. 기존39450·268보류62 보존.
- 202초안 전수 검수 중 정보상42행의 사실보장 확장2건 수정. 원REWORK와r1언어GO를 별도 보존.
- 첫check 각첫1중단·후속전수 CN6/TW6. 착순/미터/비용 기계경계4기능38은 HOLD,
  나머지16기능164만 실제수용. 공식39614/b114/meta9, 기존39450·게임·JA·검사틀 보존.
- 실제수용과 UI/portable 역복원 증거를 마감한 뒤 고정 명명12와 독립 exact 검토를 받는다.

## 2026-09-20 (Codex — 중국어 UI158 반영·62 보류)

- [268](queue_archive/ORDER-268.md): 제품290f643·검토bb138b0, 독립 Poincare 한정GO/필수0.
- 시작·진행·엔딩 회고20기능220초안 전수 언어검수. 16기능158만 실제수용, 4기능62는 기계경계HOLD.
- 공식39450/b113/meta9. 기존39292와 KO/EN/JA·runtime·공개판·인간 원형 보존.
- 첫 check 두 언어 FAIL·이후 전수 진단 CN7/TW4와 보류62 원고 보존. 승인문 왜곡·검사 확대·새 runtime실행0. 명명12 통과.
- UI 사전합집합3015 중 CN/TW 각2367키가 남는다. 실제 전체 UI분모·원어민/화면 완료는 아니다.
- 공개GO1·인간OPEN45·본편HOLD, 외부 출시 권한0 유지.

## 다음 안전한 범위

- 남은 실제 중국어 UI 초안 우선. 보류4기능62는 backlog와268 보고에 그대로 있으며 다시 저작하지 않는다.
- 비보호 shipping 사건11578의 세 언어 수용 완료.843은 비활성참고741·보호102로 새 사건 공백이 아니다.
- JA 기존 후일담의 의미 확인·커피 제목3·KO 조사·Holdem 영어직행은 별도 수리 후보로 남긴다.
- [267](queue_archive/ORDER-267.md) 새게임 기록, [265](queue_archive/ORDER-265.md) Story 카드·습관,
  [266](queue_archive/ORDER-266.md) 관계 검사와 [264](queue_archive/ORDER-264.md) 커피 검사 이력 보존.

## 활성 사양 원문

# 날짜·목표와 경마의 중국어 UI 누락

#### [~] ORDER-269 중국어 UI 20기능·101키

[~] 착수 — 2026-09-20 Codex. clean main `a09fb3c2eb7c3edda7b899dd12159a81595b0787`.
공식39450/b113/meta9·기존55판정. 최신 번역 초안 우선 지시를 수행한다.

## 한 배치·깊이3문

이 번역을 빼면 실제 날짜·목표·상태·경마 표면이 중국어 대신 영어로 남는다.
24주 뒤 상태나 효과를 바꾸지 않는 번역 단위며 영어 폴백·휴면 원고 저작과 경쟁한다.
짧은 라벨마다 새 오더를 만들지 않고 독립20기능으로101키를 관리한다.

## 고정 범위

`.git/full-game-localization/post268-ui-next-plan.json`
SHA `169c9c3b7a7d553c204d6933aed9ea93d1a4577a6c831091519f10330f0515d1`의
selected_rows101과 units20만 소유한다. 실제 기존 collector export에서 원문/ID·보호·지원성을 확인한다.
경마/말81·규칙닫기1·현재목표12·상태칭호3·날짜1·숙련3이다. CN/TW각101부재,
JA101은 기존값 보존·이번 검수/수용0이다. 원202는 완료 수가 아니다.
경마는 멘토→첫방문 선택→story followup의 기존 연결만 근거로 삼고 실제 전경로 도달은 미관측이다.

## 파일 소유권

- ROOT 제품: `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json` 선택101 추가와
  `content/meta/full_game_localization.json` 실제 신규수용만.
- ROOT 운영: `CLAUDE.md`, `docs/CODEX_QUEUE.md`, `docs/CODEX_QUEUE_L3_PENDING.md`,
  본 사양, `docs/queue_archive/ORDER-269.md`, `docs/WORK_LOG.md`, `docs/STATUS.md`,
  `docs/queue_backlog/FULL_GAME_LOCALIZATION.md`, `docs/agent_review_decisions.json`,
  `docs/agent_reviews/ORDER-269.json`.
- Plato는 간체, Rawls는 번체를 각각 KO 직접 저작해 별도 private 초안만 쓴다.
  Poincare는 비저자202 전수검수와 실제 후보 한정 판정을 맡고 ROOT만 실행·수용·Git을 한다.

## 보존과 유한 검증

KO/EN·JA·게임/표시 코드·배당·수량·말ID·저장·공개데모·인간 원장·기존39450·268보류62는 비소유다.
말 종류/착순/배당과 순익·정보상 주장과 실제 결과를 구별하고 원화·기호·토큰·개행을 보존한다.
공유키 나가기/날짜/신마/숙련/규칙닫기는 기존 의미 전체와 맞추되 새 진입이나 소급 저장 변환을 만들지 않는다.
구AP/phone/debug/비노출/fallback·영어직행 수리·새검사/fixture/역사 pin/audit_scope 확장0이다.

1. clean 선언에서 각101 export → 병렬 KO직접 초안 → 비저자202 전수 언어검수 → 기존 선택 check.
2. 첫 실패는 보존한다. 언어 결함이면 원고를 고친다. 검사 인식/미지원이면 해당 기능묶음을 HOLD로 분리하고
   자연스러운 원문 뜻을 왜곡하거나 새 검사 수리로 확대하지 않는다. 원202 전체PASS로 부르지 않는다.
3. 승인값만 apply_patch 설치하고 clean 후보 재export 뒤 기존 import --accept로 실제 receipt를 받는다.
   동일값 import는 제품변경0이다. 신규만 portable에 더하고 기존39450/current hash·UI/portable 역복원·JA를 대조한다.
4. 기존 news-panel-locale-only 명명12를 재사용하되 이번 소유13파일과 실제 전체diff를 별도 결속한다.
   전체old L1·engine·full audit·240주·새도구0. 독립 clean exact 한정 판정 후 보고/원장/큐/STATUS를 마감한다.
5. 보류가 생기면 원고를 독립 보고 안에 보존하여 이후 중복 저작을 막는다. 다음 실제 UI 초안을 우선한다.

일회성 작업 지시이며 언어 계약·권한은 기존 I18N 정본과 WORK_UNIT을 따른다.

## 실제 실행 — 최종 검토 전

원202 전수 검수 REWORK2(정보상42행 각1)는 r1에서 해결, 언어GO/필수0다.
첫 기존check는 양언어 각각 첫 착순 오류에서 중단했다. 후속101×2 전수 진단은 CN6/TW6이며
착순 수량·원형 %dm·비용 원화 명시의 인식 경계다. 원문 뜻·검사 코드를 바꾸지 않았다.
bet_type_explanations4·horse_form_rows8·race_header_cash2·tipster_and_cash_checks5의
19키씩38 전체기능을 HOLD로 분리했다. 나머지16기능82키씩164만 기존check/import 통과.
공식39614/b114/meta9·JA13096/CN·TW각13259. 기존39450 및 UI/portable 역복원 증거를 유지한다.
사전합집합3015 중 CN/TW 각2285부재는 전체 UI분모가 아니다. 원202 전체기계PASS로 부르지 않는다.
보류38은 최종 독립 보고에 실제 r1원고로 보존하고268보류62와 중복저작하지 않는다.

자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.
공개GO1·인간OPEN45·본편HOLD 유지. 원어민·실제화면·인간플레이·물리패드 관측과 외부출시 권한0이다.
