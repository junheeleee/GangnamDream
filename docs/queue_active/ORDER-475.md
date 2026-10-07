# ORDER-475 — 심야 루틴의 상대적 취침 순서

#### [~] ORDER-475 [위임 수리] 새벽1시 이후 결과·생활 다리10잎 — 2026-10-07

착수 — 선언 커밋·push 뒤 아래 정확 소유만 구현한다. 474와 별도 오더다.
FULL_GAME_LOCALIZATION.md:156–159에 기록된 실제1시→12시→자정 전 모순이며
이미 닫은474 비용·거처, 다른 원문의 연차·투자손실 가드는 이번 범위가 아니다.

## 한 판정 단위와 깊이3문

- 지우면: 본문 새벽1시 뒤 결과가12시 취침, 자동 생활 다리가 자정 전 소등으로
  되돌아간다. 직접 결과와 EventManager→Main summary 두 독자 모두 모순이다.
- 24주 뒤: 기존 slept_early·arc_night_routine_seen, mental+6·현수 affinity+1은
  불변이다. W40+ callback_slept_early_echo는 무리하지 않고 일찍 쉰 기억을 읽는다.
  다른 선택처럼 더 공부하지 않고 곧 취침했다는 상대적 조기 취침은 보존한다.
- 경쟁: 새벽2시까지 공부/intelligence+2·investment_skill+1·health−2,
  맥주/mental+8·health−1과 기존 경쟁한다. 이번 수리는 선택·비용·회수를 늘리지 않는다.

한 사실/두 소비 잎×5언어=10잎이다. 첫 실행 추정15~25를 채우려 다른 사실을 넣지 않는다.

## 정확 변경·보존

arc_night_routine/choices[1]의 result_text와 bridge_summary만 바꾼다.
새벽1시 본문·새벽2시 선택0·다른 문장·호칭·문장 순서·토큰·LF/문단은 보존한다.
취침의 절대시각만 없애고 더 공부하지 않고 바로 쉼/상대적으로 공부를 일찍 마침으로
정렬한다. 새 시각·수면시간·다음날 효과·캐릭터 사실을 발명하지 않는다.
Main W12–22/고시원/현수 만남/미독해 dispatch·기존 자동 선택 우선순위,
GameState.apply_choice·EventManager 영수증/summary 및 콜백 조건은 변경0.

STORY_BIBLE.md:263과 narrative_spine.demo.bridge_roots가 생활 다리를 소유한다.
공개 M01~M06 14root/100잎 및 legacy72/467의 소유root에는 없다.
공유파일의 legacy 소유 arc_father_quiet_call raw·공개PCK·고정 pin·분모는 불변이다.
이 작은 사실 수리는 새 장면/계층 승격이 아니며 기존 미선언 T3 채무를 보존한다.

## 정확 파일 소유

- root KO/EN: content/events/arc_midgame.json, content/events_en/arc_midgame.json의
  위2잎씩만. root 표적검사: 새 tools/night_routine_time_audit.py(--self-test),
  tools/NightRoutineTimeCheck.gd, tools/NightRoutineTimeCheck.tscn,
  tools/audit_scope.json의 등록/전용 fast lane.
  기존 tools/first_win_fact_audit.py는 공유파일의 정확475 전이만 역사 비교로
  역투영하는 adapter를 root가 소유한다. 실제 현재raw/typed proof를 먼저 검증하며
  474 비용·거처 검사와 제품payload를 완화/롤백하지 않는다.
- 직접KO 목표어 저자 order469_review: content/events_ja/arc_midgame.json,
  content/events_zh-CN/arc_midgame.json, content/events_zh-TW/arc_midgame.json의
  위2잎씩만. 영어 중역·간체→번체 자동변환0.
- root 공식수용: content/meta/full_game_localization.json의 정확2×3 기존 교정,
  export/check/import --replace-existing/최초0/기존267배치 raw prefix·41848키 불변.
- root inventory: content/meta/release_content_inventory.json,
  docs/CONTENT_RATING_INVENTORY.md는 실제 변한 현재 지문만 owner 생성과 함께.
  먼저 실측하며 변하지 않으면 변경0; 공개 분모·분류·계약은 수정0.
- order469_history: tools/order470_source_compat.py,
  tools/order470_source_compat_self_test.py, tools/pr31_intake_history.py,
  tools/pr31_intake_history_self_test.py의 source5/receipt1/필요할 때만 metadata2
  정확 후속 전이와 표적 반례. 옛470–474 끝점·영수증을 바꾸지 않으며
  현재 runtime payload에 옛 산문을 돌려주지 않는다. root만 프로젝트 QA/엔진/커밋.
- 비저자 order469_main: docs/agent_reviews/ORDER-475.json만 작성한다.
  원문/목표어10잎·실제 로그·전이·L2 전수검수 후 독립 GO/HOLD/REWORK.
- root 운영: CLAUDE.md 현재, docs/CODEX_QUEUE.md,
  docs/CODEX_QUEUE_L3_PENDING.md 순번만, 이 사양/queue_archive/ORDER-475.md,
  docs/WORK_LOG.md, 생성 docs/STATUS.md, docs/agent_review_decisions.json.

arc_events/endings5·project.godot·Main/StoryMode/GameState/EventManager/EndingSystem·
callback 원문·narrative_spine·사용자 저장/seed·과거 human/agent 보고/판정·public manifest 변경0.

## 증거·마감

1. 두잎밖 raw/구조/gameplay·토큰·문단 불변과5언어 직접 대조.
2. 원본 공식6교정/최초0, 실제 export 후보/census/영수증과267 prefix·키를 결속한다.
3. proven fresh UUID pre-autoload 준비 상태에서 DataRegistry 두잎 로딩,
   실제 자동 선택 우선순위·직접 선택1·EventManager.resolve_narrative_bridge/
   consume→Main._narrative_bridge_summary를 관측한다. mental/현수/seen/slept_early·
   choice 영수증·summary와 W40 콜백 조건을 확인한다. 정확 모집단/고유ID,
   singleton 복원·전체source/보호/runner/로그/외부Godot SHA 전후·exit·marker·
   stdout/Godot오류를 기록한다. 실제 렌더·자연 플레이 관찰로 바꾸지 않는다.
4. 소유 잎·소비자·공식수용·전이 반례/en_coverage·english_hangul·continuity·
   scene_audio_contract·speech_register·release_inventory·demo 계약만 표적검사한다.
   UI대형/240주/전체감사/옛 화면 반복0. 검증 입력 재사용은 실제 동일성 경계를 남긴다.
5. 신규 미해결 실패0·L2 전칸·비저자 한정 판정 전에 완료하지 않는다.
   인간/원어민/물리패드/실제 화면·본편 출시 HOLD를 준비/자동 PASS로 대체하지 않는다.

규범 승격: 새 규범0. 기존 WORK_UNIT/I18N/SCENE_TIER를 적용하며 exact잎·
후속전이·표적 모집단 결속은 일회성이다.
