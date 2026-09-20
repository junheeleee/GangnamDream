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
