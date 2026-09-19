# ORDER-273 — 경마 거리 단위 검사·기존 중국어 복구

[x] 2026-09-20. 독립 Poincare work_unit GO는 이번 20수용·0보류 처리에만 적용한다.

- 제품 `6b000a133908ffd1d5b7a8279a0cc2074668ad73`, tree `168b173d2b6740e09d984334e18dbd73367a201a`. clean 검토 `a7da931bc7ee23be394b53dfc18155db38257872`. source 이후 STATUS만 변경.
- 수리 전 정상4거부·단위누락1허용을 실제관찰했다. 수리 뒤 정상4/변이14/OFF2와 원고20 전수 확인, 명명12 PASS.
- 최초 preflight check2는 ROOT의 --locale 누락으로 실패했다. 원형 보존 후 정확 locale를 명시한 같은 batch retry각10PASS, formal import각10PASS다. 번역문은 바꾸지 않았다.
- 기존 두 기능10키×2=20원고를 재저작 없이 복구했다. 전체경마화면·공개/인간/본편 GO가 아니다.
- 실제 수용 39892/b118/meta9. 기존39872 보존; UI/portable 역복원과 JA/원문/runtime 보존.
- 원어민·렌더·인간플레이·물리패드 OPEN. 공개GO1·인간OPEN45·본편HOLD 유지. 이전보류110중20복구·90미수용이며 원형보류증거는 유지.
- 원형 QA·실패·수리·남은 위험은 [독립 보고](../agent_reviews/ORDER-273.json), SHA 4bfcf981f3945b52f72daaab07df612444f95dce346df2d8d7d93a0fd0363290.
- 일회성: 본 배치 번역·선정·검증·수용·파일소유 지시. 영속 권한/언어규칙은 기존 WORK_UNIT/I18N 소유, 신규 규범 승격0.

자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.

## 실제 캡처

원문은 git-private에 stdout/stderr/exit·입력핀과 보존한다. 진단 수집 exit0와 전체 통과는 다르다.

| 파일 | 바이트 | SHA256 | exit | 결과 |
|---|---:|---|---:|---|
| order273-cases-baseline-first.json | 404513 | 0b85ce2d5f82a9268c534e0a991f8b6fdbafcae610d0cd929cf9d6cb8d237224 | 0 | diagnostic collection only, not population PASS |
| order273-cases-post-first.json | 402643 | 22e449cbb8f271480fb206360526b5c32b20f9520905eb8f9e2f18942f240719 | 0 | PASS |
| order273-export-cn-first.json | 377541 | 85ae21da7be72cd2a6108a86b324f6aec253bb5403dbe2740b02d4a7e18f22eb | 0 | PASS |
| order273-export-tw-first.json | 377535 | 391573e596ab005b5cbdb6d3d58c128ec0e273fbd8a7a303a0b995270eca3d65 | 0 | PASS |
| order273-formal-export-cn-first.json | 377564 | 28fbde55fe4f119c6a124f27dca931631eb2cd871606743c53dea648190aa08e | 0 | PASS |
| order273-formal-export-tw-first.json | 377564 | 6ed7488e3b2a3f2c5ffabb2e40cba289983066ad0a72ee670b5d614a2b489808 | 0 | PASS |
| order273-formal-import-cn-first.json | 377511 | 702e1c65eb151f4948f6fa5c40e81474e5de6515da3b6e7564703e8a9af1dd86 | 0 | PASS |
| order273-formal-import-tw-first.json | 377511 | 7cffdeec9893f16b5d3ca6a86b767307328f114f4acaad7ea13cc2e7d4292bce | 0 | PASS |
| order273-named-first.json | 1691959 | f0d611124a1769bf8960069de5f85efab5a9a3b66955027a15498ce5a74bdfd6 | 0 | PASS |
| order273-named-outer-first.json | 379618 | 800cc178cd2597d1f4423fb81d2c78fab4d931b7cf13999e5849231bf4734603 | 0 | PASS |
| order273-preflight-check-cn-first.json | 377302 | 72b0e6ce6838a1c330f71b181c3484cf056c1d806895f7e1ce0dd804157d80c8 | 1 | FAIL preserved |
| order273-preflight-check-cn-retry-first.json | 377497 | 89c1ca73c1df944eb0843aa4c76e78a80794a7af626d6df8ce1d55cdf42576d3 | 0 | PASS |
| order273-preflight-check-tw-first.json | 377302 | fa89955376dd0d2e2612e222f514c18602d9029a576015989597f4c35aadf09a | 1 | FAIL preserved |
| order273-preflight-check-tw-retry-first.json | 377503 | 25085ddcd9fec69396ab51fe0effe047beb240a96076440f759cd390652ac5ae | 0 | PASS |
| order273-preservation-first.json | 377737 | bd94601ce364be185384ce0f22edf0e29472b32d190f89542d75bb7e8fb3ae27 | 0 | PASS |

## WORK 마감 전 원문

# Gangnam Dream Work Log

> 이전 WORK·현재 선언·실패 원문은 [272 보존본](queue_archive/ORDER-272.md)에 있다.

## 2026-09-20 (Codex — 경마 거리 단위 오탐·기존20값 복구 착수)

- [273](queue_active/ORDER-273.md): 두 완성 KO템플릿만 수리한다. 정상4/변이14/OFF2와 원고20값의 모집단을 분리한다.
- ROOT가 원메모23815B/SHA67bb7c8a5688e11dab6ab6f255e9a3b8a18edd7d3d94247a45984809723dafa9를 전량 읽었다. 실제복구0, 기존39872·보류110 보존.
- 파일소유: Plato checker1, ROOT locale2/portable/운영문서, Poincare 비저자 검수. 기존원고 재저작0.
- 수리 전 정상4가 m오탐으로 direct/full 거부됐고 단위누락변이는 통과했다. dirty선언HEAD8e7908에서 checker2a4242 고정 후 같은20 입력을 실행: 정상4·유효음성14·OFF2원형 확인. 그 뒤 수리를 clean18c8로 commit했다.
- 기존20원고 전수 언어GO/필수0. 최초check2는 ROOT의 CLI --locale 누락으로 실패했고 원형을 보존했다. 정확 locale를 명시한 같은batch retry각10PASS, 설치후 cleaned83dd5 formal import각10PASS/changed_files0. check/import에도 --locale를 항상 명시한다.
- 실제39892/b118/meta9, 기존39872·JA·원형보류증거 보존. 이전110중20복구·나머지90미수용. 명명12·보존·cleanexact 최종검토는 다음 별도 증거다.

## 2026-09-20 (Codex — 월초 돌발상황·시장 안내 중국어 30 반영)

- [272](queue_archive/ORDER-272.md): 제품b61eeb5·검토49428e8, 독립 Poincare 한정GO/필수0.
- 원30초안 전수 언어검토 뒤 실제30수용·0보류. 상세 실패·의미·원고는 독립보고에 보존.
- 공식39872/b117/meta9. 기존39842·KO/EN/JA·runtime·공개판·인간원장/과거58판정 보존.
- 최초 명명11PASS/queue1FAIL 뒤 문서 머리말을 수리하고 queue만 재실행PASS. 원형 증거는 보존하며 원어민·화면 완료가 아니다. 공개GO1·인간OPEN45·본편HOLD.

## 다음 안전한 범위

- 첫고지본문1의 JA/CN/TW누락과 수집 미노출은 별도 수리 대상이다.
  `.git/full-game-localization/post270-first-warning-repair-scope.json` 7257B/SHA66a21413b144447af3b99671907bb058b5892aca1962df3a07bc29fef438c6ba.
  ROOT가 RO메모 전량을 읽었다. 기존KO/EN7literal씩을 같은완성값의 단일literal로 펴는 방향이며, 새1key의 현재/역사 collector경계와 JA누락을 별도선언으로 검증한다. 새collector대형화0.
- 이전268보류62+269보류38+270보류10=110 원고는 각 독립보고에 보존했다. 재저작 없이 실제 기계경계 수리와 회복수용 대상이다.
- 시장 부모1은 수용했지만 neutral/bear/bull 동적인자와 AP효과 원문 정합은 별도다.
- 보류110 복구 RO메모 `.git/full-game-localization/post271-held-recovery-scope.json` 14937B/SHA16336cd78cd93041d2c061a3abdccb2ffbdb2a80c3e1b638777e79d2892bf546를 ROOT 전량읽음. 가장작은 후속은 기존 %dm 거리단위 오탐의 좁은검사 수리이며 최대20값 회복후보, 실제회복0이다.
- 현재 원문 `자산10억! 절반`, 저자산만 본 `아직 초반`, 투자확인 없는등급, 경고의잠/식사묘사는 별도정합 수리후보다.
- 비보호 shipping 사건11578 세 언어 수용 완료.843은 참고741·보호102이며 신규 활성 사건 공백이 아니다. 실제화면·동적표시명·직행EN·원어민 검수는 별도다.

## 활성 사양 원문

# Active Queue Spec: ORDER-273

#### [~] ORDER-273 — 경마 거리 단위 오탐 수리와 기존 중국어 20값 복구

2026-09-20 착수. 부모 [157](ORDER-157.md), 현재 위임 [WORK_UNIT](../WORK_UNIT.md).
기준 main `f61c7f4e6066900fd12e461754f9966a409007ac`, 공식39872/b117/meta9, 기존보류110.

## 깊이 3문과 한정 범위

1. 무엇이 깨졌는가: 경마 거리 `%dm`에서 placeholder를 제거한 target의 `m`을 source의 `dm`과 대조하여 정상 원고4값을 영어잔재로 거부한다. 같은 기능의16값도 함께 보류됐다.
2. 게임 상태가 달라지는가: 아니다. 24주/5년 효과·선택·저장·확률은 그대로이며 중국어 경마 정보표의 영어 폴백만 줄인다.
3. 무엇과 경쟁하는가: 새 UI 저작보다 기존 검수 원고20값을 재저작 없이 복구한다. 다른90보류·첫고지·동적 표시명·직행EN은 새 범위다.

기존 두 기능 `race_header_cash`/`horse_form_rows`의10키×2지역20값만 수용후보다.
두 기능은 같은 오탐 원인을 공유하므로 15~25독립기능에 억지로 맞추지 않는다.
회귀입력20개(정상4/변이14/OFF2)는 번역20값과 별도 모집단이며 합산하지 않는다.
원형은 `.git/full-game-localization/post272-metre-repair-cases.json` 23815B,
SHA256 `67bb7c8a5688e11dab6ab6f255e9a3b8a18edd7d3d94247a45984809723dafa9`.
공개269 `held_drafts` 원문과 SHA를 대조한다. 기존 언어 GO를 기계 수용으로 부르지 않는다.

## 파일 소유권

- 구현자 Plato: `tools/zh_translation_audit.py`의 두 완성 KO원문에 한정된 거리 slot/unit 검사와 기존 self-test의 소형 회귀 사례. 전역 m/dm 허용·기존 기준선 완화·새 프레임워크 금지.
- ROOT: `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json`의 위10키씩만; `content/meta/full_game_localization.json`의 실제 영수증20값과1배치만.
- 운영 ROOT: `CLAUDE.md`, `docs/CODEX_QUEUE.md`, `docs/CODEX_QUEUE_L3_PENDING.md`, 이 active와 `docs/queue_archive/ORDER-273.md`, `docs/WORK_LOG.md`, `docs/STATUS.md`, `docs/queue_backlog/FULL_GAME_LOCALIZATION.md`, `docs/agent_review_decisions.json`, `docs/agent_reviews/ORDER-273.json`.
- 비저자 Poincare: 읽기 검토와 git-private 봉인 보고. Git/QA/공식 수용은 ROOT만 수행한다.
- git-private 기존 exchange/capture helper를 재사용한다. 원형 first결과를 덮지 않는다.

## 구현·검증

- 선언 commit 뒤 수리 전 direct validate_text/full translation_errors의20회귀입력과20원고를 실제 관찰한다. 기대값은 관찰과 분리하며 진단 완료exit0를 번역PASS로 세지 않는다.
- source의 distance 인자 slot(header1/horse2, 0부터)와 미터 suffix를 묶고 종류·순서·부호·BBCode·줄바꿈·돈·문자·다른 영어 검사는 보존한다. 숫자 뒤 일반 공백은 오류라고 새로 규정하지 않는다.
- 수리 뒤 같은20입력을 실행한다. 정상4 모두 PASS 전에는 음성14의 성공을 주장하지 않는다. OFF2는 원형 진단과 동일해야 한다. 원고20 전수 언어·소비자 재대조 뒤 기존 check/import로 실제 수용한다.
- 새 exact clean 후보에서 기존 `news-panel-locale-only` 명명12를 한 번 실행한다. 이 차선의 ZH self-test가 변경 checker를 직접 검사하고, fullself가 실제 adapter를 회귀 검사한다. 실패는 원형 보존 후 해당 검사만 수리·재실행한다. 전체감사·엔진·240주·새 native claim0.
- 기존39872 source/target 해시, UI/portable raw inverse, KO/EN/JA/runtime/project/public/human 원형 보존을 확인한다. 선언소유14경로 밖 수정0.
- 비저자가 실제 변경과 증거를 읽고 clean source commit/tree 및 STATUS-only 또는 명시 운영metadata wrapper를 결속해 한정 work_unit 판정한다. closure metadata만 바뀌면 그 표적 검사를 별도 실행한다.

## 닫는 것과 남는 것

닫는 것: 실제 통과한 거리 검사 수리·최대20값 수용. 원고 의미·거리 단위·숫자 소유를 왜곡하지 않는다.
보존: 기존 인간 판정·공개GO1·인간OPEN45·본편HOLD. 원어민·실제 화면·물리패드 OPEN.
이 배치의 선정·파일소유·증거 계획은 일회성이다. 언어·위임 규범은 기존 정본을 유지한다.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.
