# Active Queue Spec: ORDER-390

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-390 [P1·전체 현지화] 시작 안내 파산 설명 정합·일중 UI23값

**[~] 2026-09-29 Codex 착수 — 아래 파일만 소유한다.** ORDER-157의 번역
위임과 현재 개발·검수 위임을 따른다. BALANCE 2026-06-11과 DECISIONS
동일 날짜의 순자산 파산 기준은 GameState와 일치한다. 시작 안내만 잘못된
빚 설명을 갖고 있으므로 규칙이 아니라 표시를 수리한다.

## 깊이 3문

1. 없애면 무엇이 깨지는가: 파산 대상과 비교 방향을 잘못 설명하고 중국어
   시작 안내가 영어로 남는다. 올바른 위험 이해와 첫 행동 안내를 복구한다.
2. 24주 뒤 상태 차이: 새 선택이 아닌 표시 정합 수리다. 순자산·파산선·
   건강/정신력·AP·효과·일정·저장·finish_run 변경0.
3. 경쟁: 남은 UI와 검수 시간이 경쟁한다. 한 tutorial의11키를 묶고 이미
   검증한 격리 화면 준비를 재사용한다. 새 검증 범위는 실제 source변경에 한정한다.

## 정확한 파일 소유권

- Root 제품: `scenes/MainGame.gd`의 `_show_tutorial` KO/EN1쌍만:
  `건강/정신력이 0이 되거나 빚이 -1억을 넘으면 끝납니다.` →
  `건강/정신력이 0이 되거나 순자산이 -1억 원 미만이면 끝납니다.`;
  EN `debt exceeds -KRW 100M` → `Net Worth falls below -KRW 100M`.
- Root 번역: `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json` 각각 tutorial
  `_tr`11키(제목·소개·목표2·행동2·방향2·수정위험본문·첫주팁·시작버튼),
  `locale/ui_ja.json` 수정된 한국어 새키1. 각 지역 한국어 직접 저작이며
  간번 변환/영어 중역0. JA 구 오류키는 역사 바이트로 보존하며 현재 호출0을
  증명한다. 기존 `ui.tutorial.danger`는 변경0.
- Root 공식 수용: `content/meta/full_game_localization.json`23 receipt/3배치
  append만. MainGame exact copy commit을 공식 export의 source로 관측한다.
  중간 source commit은 번역·검수 완료 후보가 아니며 최종 후보에서3언어를 함께 결속한다.
- `/root/compat357`: `tools/main_game_locale_history.py`,
  `tools/ja_translation_pipeline.py`, `tools/ja_translation_audit.py`,
  `tools/ui_translation_append.py`, `tools/ui_translation_append_self_test.py`,
  `tools/audit_scope.json`. 실제1쌍 copy successor·원형 Git/raw inverse·
  current collector 새키와 역사 view 구키의 exact 연결·보존 JA구키1만 검증한다.
  원형핀/원형함수/반례 보존, 범용 예외/허위 current snapshot/기존 checker완화0.
- `/root/screen_path_probe`: private `order390-check.gd`, `order390-check.tscn`,
  `order390-run.py`와 격리 화면 결과. 기존389 helper 재사용, 새 제품 수정0.
- `/root/r3_route_probe`: 비저자 23값/KOEN1쌍/변경 도구와 실제PNG 독립 검수,
  private `order390-independent-review.json` 작성. Root와 다른 판정자다.
- 기록: 이 사양·큐2개·CLAUDE·WORK_LOG·STATUS·필요시 기존
  `docs/history/WORK_LOG_2026-09-07_localization.md` 손실 없는 이동,
  `docs/agent_reviews/ORDER-390.json`, `docs/agent_review_decisions.json`,
  `docs/queue_archive/ORDER-390.md`; private `order390-*` 교환·검증·보존증거.

## 표적 검증·경계

- 공식 export/check/import3배치, 23값 한국어 의미·숫자·토큰·지역문자 전수,
  기존 UI/receipt raw 역삭제. MainGame 전후는 정확1쌍 외 byte동일.
- 새 source/collector/JA구키 exact focused 반례·실제 collector·current UI append·
  영향 consumer5·JA UI/ZH/ENcoverage·context/queue/diff를 표적 실행한다.
  파일 선택이 제시한106검사는 영향 검토 자료이며 전체감사/240주 재실행0.
  변경 없는 역사 self는 반복하지 않되 새 bridge가 읽는 경계의 반례는 생략하지 않는다.
- 실제 MainGame tutorial CN/TW 상단/하단과 KO/EN/JA 수정 경고를 1280×800에서
  관측한다. draft preview와 수용사전 cache주입0 실행 구분. 문구·전용 font·glyph·
  줄바꿈·clip·아래팁/시작버튼 노출, preautoload 격리·실사용자 저장 불변·typed복원.
- 준비 스크롤은 입력 증거가 아니다. 자연진입/복귀·거래·새 입력·물리 패드·
  기존 선택테두리 약3px 잘림과 동적 대출상품명/패드 부모문구는 제외.
- GameState/경제/저장/project.godot/공개데모/사람원장/출시언어 불변.
  기존153판정/131보고·실패/GO/HOLD/OPEN 보존. 공개GO1·인간OPEN45·본편/새
  package HOLD, 원어민/인간/물리 미관측. 외부출시/스토어/지출/법률행위0.
- 규범: 기존 I18N/WORK_UNIT 재사용·새 상시규범0. 모집단·분담·검증은 일회성.
  자동PASS는 계약증거이며 재미·깊이·문체·원어민/인간/출시GO가 아니다.
