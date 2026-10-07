# ORDER-474 — 첫5천만원 축하의 지출·거처 사실

#### [~] ORDER-474 [위임 수리] 실제1만5천원 선택과 현재 거처 — 2026-10-07

착수 — 선언 커밋·push 뒤 아래 정확 소유만 구현한다. 기존157 잔여 기록
FULL_GAME_LOCALIZATION.md:156–159와 현재 원문/소비자의 확인 결함이다.
473의 완료 범위를 늘리거나 화면 대기149/457/302·157의 원래 소유에 넣지 않는다.

## 실측 두 독립 단위와 깊이3문

- 지우면: 실제 money−15000 선택을5천원 지출이라고 설명하고, 비고시원 거주자도
  사별판 결과에서 고시원 계단에 앉는다. 결과문과 실제 choice/current_housing이 충돌한다.
- 24주 뒤: mental+12·money−15000·arc_first_real_win_seen 및 선택/후속/소비자는
  그대로다. 새 상태·회수·금액·승리 조건을 만들지 않고 이미 낸 비용의 설명만 맞춘다.
- 경쟁: 혼자 축하/아버지에게 전화(사별판은 연결되지 않는 번호)/다음 목표의
  기존 선택·대가·아버지 생사를 보존한다. 수리를 위해 선택이나 음식을 늘리지 않는다.

모집단은 두 root의 choices[0].result_text만×5언어=10잎이다. 확인된 작은 사실
수리를15개로 부풀리지 않는다(WORK_UNIT의 배치 크기는 첫 실행 추정).

## 정확 변경

1. arc_first_real_win/choices[0].result_text의 기존 아이스크림5천원을 실제
   선택 효과1만5천원에 맞춘다. 다른 문장·효과·금액은 보존한다.
2. arc_first_real_win_father_passed의 같은 금액과 `고시원 계단`을 수리한다.
   이미 생존판이 쓰는 `집으로 돌아와`와 양립하는 결과로만 정렬한다.

토큰·문단·문장 순서·KO/EN 시제·다른 결과/본문/배경·일반/사별 라우팅은 불변이다.
MainGame.gd:7688–7693의 t≥15/순자산≥5천만/미독해·생사 분기는 수정하지 않는다.
공개 M01~M06 14root/100잎에 두 root가 없다(story_demo_localization_audit.py:33–48).
legacy V2의 arc_midgame 소유는 arc_father_quiet_call이며 그 raw도 보존한다.
기존 frozen 공개 PCK·인간 GO 및 M01~M06 원문을 새로 만들거나 갱신하지 않는다.

## 파일 소유

- root KO/EN: content/events/arc_midgame.json,
  content/events_en/arc_midgame.json의 위2잎씩만.
- 직접KO 목표어 저자 order469_review: content/events_ja/arc_midgame.json,
  content/events_zh-CN/arc_midgame.json, content/events_zh-TW/arc_midgame.json의
  위2잎씩만. 영어 중역·간체→번체 자동변환 금지.
- root 공식수용: content/meta/full_game_localization.json. exact2×3의
  export/check/import --replace-existing, 최초수용0/기존 원장 prefix·키 보존.
- root inventory: content/meta/release_content_inventory.json,
  docs/CONTENT_RATING_INVENTORY.md의 실제 변한 현재 지문만 owner 생성과 함께.
  먼저 실측하며 변하지 않은 지문·공개 계약·분모·분류는 변경0.
- order469_history: tools/order470_source_compat.py,
  tools/order470_source_compat_self_test.py, tools/pr31_intake_history.py,
  tools/pr31_intake_history_self_test.py의 실제 source5/receipt1/
  필요할 때만 metadata2를 정확 successor로 추가한다. 옛470–473 끝점은 불변이고
  과거 산문을 실제 runtime payload로 반환하지 않는다. root만 QA/엔진/커밋한다.
- root 표적검사: 새 tools/first_win_fact_audit.py(--self-test),
  tools/FirstWinFactCheck.gd, tools/FirstWinFactCheck.tscn,
  tools/audit_scope.json의 등록·전용 fast lane.
- 비저자 order469_main: docs/agent_reviews/ORDER-474.json만 작성한다.
  원문/목표어10잎·실제로그·전이·L2 전수검수, 독립 GO/HOLD/REWORK.
- root 운영: CLAUDE.md 현재, docs/CODEX_QUEUE.md,
  docs/CODEX_QUEUE_L3_PENDING.md 순번만, 이 사양/queue_archive/ORDER-474.md,
  docs/WORK_LOG.md, 생성 docs/STATUS.md, docs/agent_review_decisions.json.

arc_events5·endings5·project.godot·GameState/Main/EndingSystem·사용자 저장·seed·
과거 human/agent 보고·판정·public manifest는 만지지 않는다.

## 최소 증거와 마감

1. exact10 밖 raw/JSON 구조·효과·플래그·토큰·LF/문단 불변,5언어 전수 의미 대조.
2. 공식6교정/최초0과 실제 source census·이전 원장 prefix·typed Git 전이를 결속한다.
3. 새 fixture는 proven fresh UUID pre-autoload에서 실제 GameState.apply_choice/
   MainGame._next_arc_id를 읽는다. 생사×고시원/비고시원, t/금액 경계, 실제
   money−15000/mental+12/seen 영수증과 재호출 차단을 준비 상태로 확인한다.
   source/runtime/사용자 보호와 외부 Godot 실행파일 SHA 전후·exit·정확marker·
   stdout/Godot오류를 모두 기록한다.
4. 변경된 잎·생산자/독자·공식 수용·이력 반례 및 en_coverage·english_hangul·
   narrative_continuity·scene_audio_contract·speech_register·release_inventory·
   demo 계약에 필요한 표적 검사만 선택한다. JA/zh는 실제 공식 leaf 검증을 한다.
   변경 없는 UI 대형 검사/240주/전체 감사/옛 화면을 이유 없이 반복하지 않는다.
   이전 검사 재사용은 그 검사의 실제 입력 동일성/비적용 경계를 따로 남긴다.
5. 새 실패0·L2 각 칸·비저자 한정 판정 전에 완료하지 않는다. 실제 창·자연 플레이·
   인간·원어민·물리패드·본편 출시 HOLD는 준비/자동 검증으로 대신하지 않는다.

규범 승격: 새 규범0. 기존 WORK_UNIT/I18N/SCENE_TIER 정본을 적용하며 이번
exact두 결과·분리 전이·최소 검사 순서는 일회성이다.
