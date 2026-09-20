# ORDER-281 — 빅휠 중국어28·일본어 커서 수리

[x] 2026-09-20. 비저자 Poincare work_unit 한정GO, 필수 결함0.

- 제품 `ddb7481a41748e0dc7917d5c5ffb6a985648f34e`, tree `ee7a5175768951736ed6eb5d72b1fab03bb159a3`; clean 검토 `c68dd423b66244d423decb3c54d0f1c27121e1c2`, STATUS-only wrapper.
- KO14키에서 CN14/TW14를 직접 작성하고, JA 커서1의 大 오역을 바로잡았다. 원문14·대상29 전수 독립 대조, 추가공유7호출(커서4·현금3)도 같은 의미다.
- 순배당과 총회수·누적손익·0원 count-up시작·실제 입력9인자/HUD6·원화·토큰·LF·BBCode 보존. source/runtime/checker/collector/확률/수치/효과는 불변.
- 실제 check/export/import14/14/1, 공식40009/b126/meta9. old39980 source/target hash·UI/portable raw 역복원·다른JA행 유지. 기존보류72는 변경0.
- 명명12 PASS. 실제 UI와 조건부 legacy/AP의 staticconsumer는 fresh-story/화면 관찰이 아니다. 당첨 부모의 JOKER배 원문1·직행영문 기계/심볼·그림/물리입력은 비포함.
- [독립 보고](../agent_reviews/ORDER-281.json) SHA `be2c85b084f94ae8f9adbddf17bf0225b9193cde7692a6d307dd3d3a074ae5ef`. 화면·원어민·인간·물리패드 미관찰, 공개GO1·인간OPEN45·본편HOLD 유지. 전체패널/번역/게임 GO가 아니다.
- 선정·소유·배치·검사는 일회성. 기존 WORK_UNIT/I18N 재사용, 신규 규범 승격0.

자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.

## 최초 실제 캡처

git-private에 stdout/stderr bytes·SHA·exit·입력핀을 원형 보존한다.

| 파일 | 바이트 | SHA256 | exit | 결과 |
|---|---:|---|---:|---|
| order281-accept-cn-first.json | 377824 | 7bf23d914943cf7aa9230233a120336d1cc3a7691c88a9dcb552d75a3c791566 | 0 | PASS |
| order281-accept-ja-first.json | 377833 | c44a0bc16bd03e22b9125d000039fa7ef52cb02a3d52de4b62dee508e47b8f94 | 0 | PASS |
| order281-accept-tw-first.json | 377824 | a94aff0344137054b85fd4fb561f600ef167c02684aadbf3146c6dd084fe319c | 0 | PASS |
| order281-applied-export-cn-first.json | 377889 | 7baeb05b5e3a56dd31bf83a49f6dcafe71fca06cec0a7d327d2d047eb7e23a69 | 0 | PASS |
| order281-applied-export-ja-first.json | 377867 | 939b659e2debeb90197f9b65ea39f2b74240ef9804cd30916570303b9d1bd3c0 | 0 | PASS |
| order281-applied-export-tw-first.json | 377889 | 4d428d241cf721c02b54ce91aa259aee59c80beac6f085366212494e18620591 | 0 | PASS |
| order281-export-cn-first.json | 377885 | 555d6a65780c3bc26af8a63bcd716a7c65a440625584ae107100602af5461262 | 0 | PASS |
| order281-export-ja-first.json | 377867 | 0fb7f6ec0ce94bf84474ef54fc25d5bd8c94e97cabb84f437d64783b04e2aef7 | 0 | PASS |
| order281-export-tw-first.json | 377885 | a9600c22aa1f4c138e2b2a98742954e8229daee8cadcdd717f07f8c3c305e484 | 0 | PASS |
| order281-named-envelope-first.json | 379947 | 06ef9cf73185b687c5f659ade3f2e1cb788ddd5975d56704845c077afb1b7762 | 0 | PASS |
| order281-named-first.json | 1698633 | cac4a11b0ac3f7a6a61f22154ca4cda5a28c94ea41fbd3f487e287478ca3e8f4 | 0 | PASS |
| order281-preflight-cn-first.json | 377813 | 30e8a06cac8b2cf8fba42c3988d4767d01349e726d20c6ed57dd6cb46b2ab966 | 0 | PASS |
| order281-preflight-ja-first.json | 377818 | cc2e798f5b72b9661134c6ed44a136de3aad0068fe5303b124cf2fed718b02f7 | 0 | PASS |
| order281-preflight-tw-first.json | 377813 | a0167e72f8fa9b5a178bffd2234b4a20a9ed7c4f24a0d2cd2e24de1fa147c75a | 0 | PASS |
| order281-preservation-first.json | 378153 | 4dd18afd35aac1ce71768bf481208d74abc486a9442a0622a1138a18e193878e | 0 | PASS |

## WORK 마감 전 원문

# Gangnam Dream Work Log

> 이전 WORK·선언·검증 원문은 [280 보존본](queue_archive/ORDER-280.md)에 있다.

## 2026-09-20 (Codex — 슬롯 당첨 결과 중국어8값)

- [280](queue_archive/ORDER-280.md): 제품3eb1474·검토e72574a, 독립 Poincare 한정GO/필수0.
- 슬롯777·체리3/2/1 결과명이 중국어에서도 새 결과·기록·로그에 들어가도록8값을 채웠다. 실제777선두 분기와 Tutorial 공유의 정확 수량을 보존했다.
- 공식39980/b125/meta9. 기존39972 source/target hash·UI/portable 원형·JA·원문 manifest 보존. 최초 실패와 의미 적합한 TW v2 재검수를 남겼고 명명12 PASS.
- 실제화면·원어민·인간·물리패드 미관찰. 공개GO1·인간OPEN45·본편HOLD 및 보류72 불변.

## 다음 안전한 범위

- 마감 보정: 최초 staged whitespace 검사가 보존본 EOF 빈줄을 지적했으나 실행기가 commit을 중단하지 않았다. 원사양 바이트를 지우지 않고 끝 주석을 덧붙여 수리하고 새 diff가 선택한 표적5검사로 재검증했다. 다음 마감은 staged 검사 exit0를 확인한 뒤에만 commit한다.

- 재개 팁: full_game_localization의 check/import에도 batch와 같은 --locale를 명시한다. 기본JA를 자동 추론으로 오인하지 않는다.
- 다음 BigWheel RO 메모 post280-next-bigwheel-scope.json(15810B/SHA dbdb5219294a50762b16edae80d99fa89b9c69ca13614845523904882ba12f3d)을 ROOT 전량 읽고12핀 확인했다. 중국어14키28값과 JA 커서→大 오역1을 별도 선언할 수 있다. 당첨 부모의 Joker배 원문 결함1은 제외·별도 수리 대상이며 공유7호출·직행영문·조건부 legacy/AP 한계를 보존한다. 새 제품 구현은 아직 없다.
- 슬롯 직접영문 기계/심볼 라벨과 튜토리얼 원문 채무는 별도다. 새 UI 배치는 producer/consumer·공유키를 먼저 확인하고 별도 선언한다. legacy/AP 조건부 진입은 fresh-story/화면 증거가 아니다.
- UI사전3016 중 CN/TW각2104키 부재는 전체 live UI 분모가 아니다. 본문·UI·동적인자·직행EN·실제화면은 별도로 검수한다.
- 보류72는268의62·270의10. 자산 안내5키×2 중 KO 3분의1 오탐2는 별도 범위이며 checker를 이번에 넓히지 않았다.
- 월말 net==0·첫월급 투자접근·시장 동적인자/AP효과·자산10억 절반·저자산 초기판정·잠/식사 고지는 별도 원문 정합 대상이다.
- 비보호 shipping 사건11578 세 언어 수용, 잔여843은 참고741·보호102. 공개판·역사 인간 판정은 유지한다.

## 활성 사양 원문

# Active Queue Spec: ORDER-281

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-281 [P0·전체 현지화] 빅휠 중국어28값과 일본어 커서 오역을 고친다

**[~] 2026-09-20 Codex 착수 — 아래 13경로만 소유.** 부모 ORDER-157.
기준 `e2ead9848898e1f1437811df5ac5af727070fa42`. 실제 UI14키×CN/TW28값 및 JA 커서1의 작은
독립 배치다. 다음 RO 메모의 전체 원문14·12핀과 shared7을 ROOT가 확인했다:
post280-next-bigwheel-scope.json 15810B,
SHAdbdb5219294a50762b16edae80d99fa89b9c69ca13614845523904882ba12f3d.

## 깊이 3문

1. 지우면: 베팅 구역·잔액·손익·입력 안내의 영어 폴백, 일본어 커서의 大 오독이 남는다.
2. 24주 상태: 새 선택이 아니라 동일 조건/결과 표시다. 돈·확률·진행·AP 변화0.
3. 같은 자리 경쟁: 기존 source lookup만 번역하며 새 창·행동·언어 노출0.

## 정확한 대상

- `"커서: %s"` — scenes/BigWheelGame.gd::_pad_move_segment:245
- `"베팅 구역을 비웠습니다."` — scenes/BigWheelGame.gd::_pad_cancel:299
- `"세그먼트를 먼저 선택해 주세요"` — scenes/BigWheelGame.gd::_do_spin:345
- `"현금이 부족합니다"` — scenes/BigWheelGame.gd::_do_spin:347
- `"0원"` — scenes/BigWheelGame.gd::_finish_spin:425
- `"꽝   결과: %s"` — scenes/BigWheelGame.gd::_finish_spin:429
- `"베팅 구역 선택"` — scenes/BigWheelGame.gd::_build_ui:620
- `"JOKER\n(%.0f:1)\n%d칸"` — scenes/BigWheelGame.gd::_build_ui:636
- `"%s배당\n(%.0f:1)\n%d칸"` — scenes/BigWheelGame.gd::_build_ui:638
- `"%.0f:1  /  %d칸"` — scenes/BigWheelGame.gd::_draw_result_plate:845
- `"   [color=#f0b429]스핀 중...[/color]"` — scenes/BigWheelGame.gd::_refresh_hud:869
- `"[b]빅휠[/b]   |   현금 [b]%s[/b]   |   %d라운드   W[color=#3de87a]%d[/color] L[color=#e85d5d]%d[/color]   손익 [b]%s[/b]%s"` — scenes/BigWheelGame.gd::_refresh_hud:871
- `"[b]%s[/b]  [%s/%s] 구역  [%s] 선택/스핀  [%s/%s] 금액 −/+  [%s] 금액 +  [%s] 규칙  [%s] 취소"` — scenes/BigWheelGame.gd::_refresh_pad_hint:978
- `"잔액: %s   |   베팅: %s"` — scenes/BigWheelGame.gd::_refresh_balance:1020

JA는 `커서: %s` 한 값을 `大: %s`에서 실제 커서 의미로 수정한다. BigWheel1,
Baccarat2·DaiSai1·Roulette1의5호출이 모두 커서다. CN/TW 현금 부족 공유3도 포함.
원어마다 한국어 직접 저작하며 중역·간번 자동변환0. 그 외 JA 변경0.

## 파일 소유권

- locale/ui_zh-CN.json, locale/ui_zh-TW.json: 위14키 append만.
- locale/ui_ja.json: 커서 한 값만.
- content/meta/full_game_localization.json: exact29 수용과1배치 append.
- CLAUDE.md, docs/CODEX_QUEUE.md, docs/CODEX_QUEUE_L3_PENDING.md.
- docs/queue_active/ORDER-281.md, docs/queue_archive/ORDER-281.md.
- docs/WORK_LOG.md, docs/STATUS.md.
- docs/agent_review_decisions.json, docs/agent_reviews/ORDER-281.json.

원형39980/b125/meta9와 held72를 보존한다. 이전67판정·human/public·KO/EN·
나머지JA·runtime·checker·collector·project.godot·manifest는 비소유다.
당첨 부모 `당첨!  %s배   +%s`의 첫인자가 JOKER 라벨인 원문 결함1은 제외한다.
그 부모 수리와 직접 영어 기계/심볼 라벨·실제 화면은 별도 범위다.

## 검증과 판정

원문14에 대해 비저자가29값 전수 대조한다. 금액은 원화, ratio는 순배당이며
확률이나 총회수로 바꾸지 않는다. 0원은 count-up의 시작값이지 최종 보상이 아니다.
LF·%.0f:%d 및 HUD6인자·패드9인자·BBCode·입력 순서·부호를 보존한다.

같은 locale로 source-bound export/check, 수동 설치 뒤 fresh export/import --accept,
JA 교체는 --replace-existing 명시. 원형 failure를 지우지 않는다. old39980의
source/target·UI/portable raw 역복원을 확인하고 clean exact 제품에서 기존
news-panel-locale-only 고유12를 한 번 실행한다. 종료 metadata6 외 전체감사·
240주·engine·신규QA/숫자예외 확장은 없다. 실패면 원인 분류 후 같은 모집단 재검수.

Main→Casino→BigWheel은 conditional legacy/AP 소비자다. guarded handler가
존재하는 것과 fresh-story/실제 표시 관찰은 다르다. 화면·원어민·인간·물리패드
미관찰, 공개GO1·인간OPEN45·본편HOLD 유지. 패널/게임 전체 번역완료가 아니다.
선정/소유/배치/검사는 일회성. 기존 WORK_UNIT·I18N 사용, 신규 규범 승격0.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.

<!-- End of byte-preserved ORDER-281 specification. -->
