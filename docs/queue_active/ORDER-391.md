# ORDER-391 — 투자 패드 안내 중국어8값·실제 글꼴 연결

#### [~] ORDER-391 [P0·현지화] 투자 패드 안내 중국어8값·실제 글꼴 연결

**[~] 착수 — 2026-09-29.** 부모 ORDER-157, 사용자 개발·검수 위임.

## 2026-10-03 재개

- PR31 `9db4a6e5` 공식8receipt/2batch와 exact Git 이력 복구를
  [ORDER-392](../queue_archive/ORDER-392.md)에서 완료했다. 공식40,989/b163,
  현재 표적10검사·독립 work_unit GO. 기존8값은 보존하며 화면/font GO는 아니다.
- 독립 검수 실행 가능. 과거 사용한도 HOLD는 당시 기록으로 남기며 현재의
  재개 차단으로 쓰지 않는다. 실제 지역 primary font/화면 검수는 아직 OPEN이다.

## 2026-09-30 원격 인계 반영 후 재개 지점 — 미완료

- 통합 source `e89f3ed`에서 `order365_ui_receipt_compat.py` normal1회 실패:
  `UI/receipt/source/target additions differ: zh-CN`. 공식40,981/b161·historical_cases0.
  원본 `.git/full-game-localization/order391-upstream-receipt-check.json` 보존;
  과거391 초안PASS로 덮지 않고 현 사전/수용원장 불일치 수리를 남긴다.
- 원격 `0f5852d`가 통합한 `bdbd10f`의 CN/TW8값을 보존한다. 아래 Codex 기록은
  원격 수신 전 로컬 후보 `18dd16d`의 검사다. Claude 값은 일부 다르므로 이를
  현재 사전 PASS로 바꿔 쓰지 않는다. 수용원장40,981/b161은 아직 그대로다.
- Claude 작성자 보고8PNG·공식 import의 원본 파일은 이 로컬에 없다. 원본 회수
  또는 새 격리관측·현재 사전 공식 교환/원장 연결을 마쳐야 한다. 기존8값을
  로컬 초안으로 덮지 않는다. 현 주인의 값·raw 보존과 source/target freshness를
  함께 확인하며 기존 receipt가 있었다고 재구성하지 않는다.
- Open Sans primary와 한자 fallback은 인계 보고이며 직접 관측이 아니다.
  두부 없음만으로 I18N_INFRASTRUCTURE의 SC/TC primary 경로를 증명하지 못한다.
  실제 지역font 확인 후 조건부2줄 수리 여부를 판단한다. 독립 검수 사용한도
  HOLD, 새GO0. 원래 source/도구 수리 범위를 확대하지 않는다.

## 원격 수신 전 로컬 진행 기록 (2026-09-30)

- 선언 `18dd16d6020b2dcae8484f4b70af3261a6ccd91e` main/origin 동기화.
  한국어 직접 CN/TW4값씩 초안, 같은 source의 공식 export/check2배치 PASS.
  각 `FULL_LOCALIZATION_BATCH_VALID ... leaves=4`, 병렬 check7.914초,
  source/response 전후 hash 동일. import/accept0, 공식40,981/b161 그대로.
- private `.git/full-game-localization/order391-{zh-CN,zh-TW}-draft.json`,
  `-source.jsonl`, `-response.jsonl`, `order391-export-result.json`,
  `order391-response-check-result.json` 및 `order391-resume.md` 보존.
- 화면 저자와 독립 검수자가 사용한도로 실패했다. 2026-09-30 확인 시 일반
  사용 불가이며 자동 재시도·크레딧 리셋/지출0. helper3개·실제font/PNG·독립
  의미판정·최종GO는 아직 없다. 코드 부재만으로 폰트 결함을 확정하지 않는다.
- 제품/공식사전/수용원장/검사도구 변경0. 재개 시 남은 독립 의미검수와 격리
  font 실측부터 진행한다. source 변경 시 기존 export를 덮지 말고 새 후보로
  export/check를 다시 결속한다. 변경 없는 기존 검사·확인된 실패를 반복하지 않는다.

**2026-09-29 Claude 인계 결과 (Codex 주간 한도 소진으로 사용자 지시에 따라 이어받음).**
- 8값: 공식 `full_game_localization.py` export→check→import `--accept` CN/TW 각1배치
  `FULL_LOCALIZATION_BATCH_VALID leaves=4`. 용어는 기존 사전 다수형을 따랐다(CN `手柄`·
  `翻页`·`返回`, TW `手把`·`換頁`·`返回`; `←→ 행동`은 거래 동작 선택이라 `操作`).
  `locale/ui_zh-CN.json`·`locale/ui_zh-TW.json` 각 +4행 append, 기존 값 변경0.
- 화면: Godot `4.6.2.stable.official.71f334935`(Linux, xvfb opengl3, 1280×800), 실제
  MainGame `_open_investments` + `ControllerHints.force_brand_for_qa(XBOX)`로 CN/TW ×
  비자산페이지/자산없음/거래불가/거래가능 8PNG 관측. 네 key 모두 번역문·placeholder
  순서(`B 返回`, `A 买入 10万韩元`/`A 无法交易`, 페이지·자산명) 정상.
- font: `normal_font` 실효값은 `Open Sans SemiBold`(라틴 primary)이고 한자는 primary에
  없지만 fallback으로 8PNG 모두 두부 없이 렌더링됐다. 사양의 조건(실제 결함 관측)이
  성립하지 않아 **`MainGame.gd` 수리0**, `/root/compat357` 도구 변경0.
- 검사: `audit_select` 대상 중 `full_game_runtime_trace_audit`(self/normal)은 **수정 전
  `origin/main`에서도 같은 seal drift로 실패**(이 작업 무관), STATUS는 커밋 전 stale만 실패.
- **열린 것:** 비저자 독립 검수 0(작성자 Claude 자체 확인만) → work_unit GO를 기록하지
  않는다. 원장 receipt append·private `order391-*` 증거는 이 환경에 없다. 자산명
  `Hanseong Electronics`가 CN/TW에서 영어로 남고, 상단 `Next Week ›`·인물 카드·우측
  패널 영어 누출은 기존 CN/TW 미번역(ORDER-157) 범위로 관측만 했다.

## 문제·판정 단위

투자 화면의 패드 전용 안내4키가 CN/TW에서 영어로 남는다. 각 지역 한국어 직접
번역4값, 총8값을 한 화면의 네 상태로 검수한다. normal_font 명시 연결은 없으나
실제 결함은 아직 미관측이다. 실제 유효 font를 먼저 확인하고 잘못된 경로일 때만
기존 FontKit regular 연결2줄을 수리한다. 입력·거래 규칙 변경0.

깊이3문: 제거하면 페이지/자산/행동/뒤로 안내가 영어로 남는다. 장기 상태와
경쟁 선택은 번역 작업에 해당하지 않으며 돈/AP/저장/서사 변화0을 보존한다.
8값은 같은 소비자의 조건 분기이고 작은 모집단이므로 독립 검수 전량 대상이다.

## 파일 소유·착수 범위

- Root: `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json`,
  `content/meta/full_game_localization.json` 신규8값/2배치 append.
  `scenes/MainGame.gd`는 `_open_investments`의 실제 유효 font 결함이 확인될 때만
  `_invest_pad_hint_label` normal_font 기존 `_font_regular` 연결2줄. KO/EN/JA
  문구·입력·폰트 크기·게임 상태는 불변. 조건 미충족 시 제품코드 변경0.
- `/root/compat357`: 조건부 font 수리가 생길 때만
  `tools/main_game_locale_history.py`, `tools/ui_translation_append.py`,
  `tools/ui_translation_append_self_test.py`, `tools/audit_scope.json`의 exact
  Git/raw 역삭제 successor와 해당 focused 반례/차선. 기존핀·원형함수·실패 보존.
  JA pipeline/audit 변경0, 범용 예외·source 허위 대체·checker 완화0.
- `/root/screen_path_probe`: private `order391-check.gd`, `order391-check.tscn`,
  `order391-run.py` 및 격리 화면 증거만. 준비상태·font 관측 저자, 제품 변경0.
- `/root/r3_route_probe`: 비저자 번역8값·조건부 코드/도구·helper·실제PNG 및
  최종 source 독립 검수, private `order391-independent-review.json`.
- 기록: 이 사양·큐2개·CLAUDE·WORK_LOG·STATUS·필요시 기존
  `docs/history/WORK_LOG_2026-09-07_localization.md` 손실 없는 이동,
  `docs/agent_reviews/ORDER-391.json`, `docs/agent_review_decisions.json`,
  `docs/queue_archive/ORDER-391.md`; private `order391-*` 교환·검증·보존증거.

## 정확한 번역 키

1. `[b]패드[/b]  LB/RB 페이지 · %s 뒤로  —  %s`
2. `[b]패드[/b]  LB/RB 페이지 · 거래 가능한 자산 없음`
3. `거래 불가`
4. `[b]패드[/b]  LB/RB 페이지 · ↑↓ 자산 · ←→ 행동 · %s %s · %s 뒤로  —  %s`

각 key 소비자는 `_refresh_invest_pad_hint`, placeholder2/0/0/4·BBCode·버튼
브랜드/페이지/행동/자산 인수 순서를 보존한다. 기존 JA4값·receipt0은 변경0.

## 검증·비포함

- 공식 export/check/import2배치, 한국어 의미·숫자·토큰·지역문자 전량검수,
  기존 dictionary/receipt raw 역삭제. 새 source가 생기면 실제 Git 변경을 먼저
  분리 commit하고 exact bridge와 focused 반례를 검수한다.
- CN/TW × 비자산페이지/자산없음/거래불가/거래가능 4상태를 실제 MainGame
  1280×800에서 관측. draft preview와 공식 dictionary cache주입0을 구분한다.
  normal/bold 실효 font·glyph·BBCode·인수·경계/잘림·preautoload 격리·실사용자
  저장 불변·typed복원을 확인한다. font수리 시 KO/EN/JA 최소 회귀 추가.
- 영향 normal consumer5·JA UI/ZH/ENcoverage·context/queue/diff 및 차선조회만.
  source검증 변경 때만 새 focused 반례. Chapter1 인과검사는 관측된 소요에 맞춰
  처음부터720초 상한, 다른 표적 검사 병렬화. 변경 없는 역사 self·전체감사·240주0.
- 준비된 pad상태는 자연진입/복귀·실입력·물리패드 증거가 아니다. 거래/콜백0.
  기존11px크기·선택테두리 약3px잘림·동적상품/자산명 전수는 별도 후속.
- GameState/경제/저장/project.godot/공개데모/사람원장/출시언어 불변.
  기존154판정/132보고·역사 실패/GO/HOLD/OPEN 보존. 공개GO1·인간OPEN45·
  본편/새package HOLD, 원어민/인간/물리 미관측. 외부출시/스토어/지출/법률0.
- 규범: 기존 I18N/WORK_UNIT 재사용·새 상시규범0. 위 모집단·분담·검증은 일회성.
  자동PASS는 계약증거이며 재미·깊이·문체·원어민/인간/출시GO가 아니다.
