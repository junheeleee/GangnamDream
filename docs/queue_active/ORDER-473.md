# ORDER-473 — 엔딩 순자산·현금 사실 정렬

#### [~] ORDER-473 [위임 수리] 세 엔딩의 금액 주체·잔여액 — 2026-10-07

착수 — 만지는 파일은 아래 정확 목록이다. 선언 커밋·push 뒤 구현한다.
ORDER-468 독립 보고의 기존 금액 결함 두 종류와 현재 직접 확인한 같은 사실의
stable_success/cut_sangchul_network 한 잎만 수리한다. 화면 잠금과 무관하게
원문·번역·준비 소비자는 진행하며 149/457/302 실제 관찰 대기는 보존한다.

## 한 배치 21단위와 깊이 3문

- 지우면: 현금+투자자산−대출로 고른 엔딩이 통장 잔액으로 거짓 설명된다.
  안정 엔딩의 10억 초과 후보도 목표까지 남은 돈을 고정20억으로 읽는다.
- 24주 뒤: 선택·효과·플래그·우선순위·금액 경계는 바꾸지 않는다. 이미 축적된
  투자와 빚을 포함한 실제 결과의 설명만 정렬한다. 새 선택이나 상태는 없다.
- 경쟁: 기존 안정/정석/비정석·고른 이력과 포기한 결과를 그대로 둔다.
  문구 수리가 엔딩 자격이나 아파트·관계·성공 보장을 새로 만들지 않는다.

## 정확 모집단 — 21잎×KO/EN/JA/CN/TW = 105

- stable_success: description, description_if_known/cut_sangchul_network — 2.
- orthodox_pinnacle: description 및 DIK11(salary_raised, salary_denied,
  credit_asserted, credit_recognized, jobswitch_reconnected, declined_golf,
  extreme_frugal, frugal_quiet, skipped_staycation, ignored_mystery_info,
  orthodox_wavered) — 12.
- unorthodox_legend: description 및 DIK6(cafe_double_jackpot, coin_second_win,
  holdem_high_stakes_win, own_path_solidified, investigating_gray_contact,
  gray_tip_debt_paid) — 7.

같은 잎 안의 금액 주체를 순자산으로 맞추고 stable 기본의 고정20억 잔여액을
숫자 없는 목표까지 남은 금액으로 바꾼다. 금액10억/5억의 이상 의미, 문단·토큰,
나머지 서사와 모든 비소유 raw를 보존한다. 다른 통장 비유·문체 부채는 범위 밖이다.
순자산 정의와 기존 선택 조건은 GameState.gd:4119,4479,4482,4498에서 관측한다.
미노출 author condition 노트는 변경·번역·플레이어 힌트로 승격하지 않는다.

## 파일 소유

- root KO/EN: content/endings.json, content/endings_en.json.
- 지역별 직접 번역 저자 order469_review: content/endings_ja.json,
  content/endings_zh-CN.json, content/endings_zh-TW.json만. KO에서 각각 작성하며
  영어 중역·CN/TW 문자 변환 금지. 공식 수용은 root가 한다.
- root 공식 수용·생성: content/meta/full_game_localization.json,
  content/meta/release_content_inventory.json, docs/CONTENT_RATING_INVENTORY.md.
  source5커밋 → 같은 소유 EN12 연결 수리1커밋 → 공식63교정 원장1커밋 →
  실제 변한 inventory2커밋으로 분리한다. 최초 source5의 새 영어 predicate 결함을
  독립 검수가 찾아 같은 범위에서 수리했고 두 실제 끝점을 보존한다.
  각21잎 exact export/check/import --replace-existing; 신규 커버리지로 세지 않는다.
- order469_history: tools/order470_source_compat.py 및
  tools/order470_source_compat_self_test.py, tools/pr31_intake_history.py 및
  tools/pr31_intake_history_self_test.py만. 옛 핀·불변 Git끝점은 보존하고
  source5/ENrepair1/receipt1/metadata2의 실제 전이·원장 prefix·21/63·비소유 bytes를
  닫힌 successor로 추가한다. 역사 역상은 비교용이며 runtime에 옛 산문 반환 금지.
- root 검사: tools/PR31EndingDescriptionCheck.gd,
  새 tools/ending_money_fact_audit.py(--self-test), tools/audit_scope.json.
  root만 프로젝트 검사와 엔진을 실행한다. 다른 에이전트는 코드·원문 읽기만 한다.
- root 운영: CLAUDE.md 현재, docs/CODEX_QUEUE.md,
  docs/CODEX_QUEUE_L3_PENDING.md 순번만, 이 사양/queue_archive/ORDER-473.md,
  docs/WORK_LOG.md, 생성 docs/STATUS.md, docs/agent_review_decisions.json.
- 비저자 order469_main: docs/agent_reviews/ORDER-473.json만 작성한다.
  105문장과 실제 로그·Git 경계·영수증을 직접 읽고 GO/HOLD/REWORK를 판정한다.
  작성자는 표본을 고르지 않는다. 이 작은 사실 수리는 전수검수한다.

project.godot, GameState/Main/EndingSystem, arc_events5, 공개 데모14/100/PCK,
사용자 저장·seed·과거 인간 판정·기존 보고/원장 행은 불변이다.

## 표적 검증과 증거

1. exact21 밖 bytes·gameplay·토큰·문단과 금액 의미를 검사한다.
2. 공식63 교정 수용; 이전 배치·영수증은 지우거나 다시 발급하지 않는다.
3. 같은 순자산/다른 현금, 평가 투자자산·대출 차감, stable10억 초과를
   실제 기존 selector/resolver의 준비 상태에서 검증한다. 기존60 경계/100잎도
   동일 fixture 계약으로 보존한다. 실제 창·자연 플레이·인간 관찰은 아니다.
4. en_coverage, english_hangul, narrative_continuity, scene_audio_contract,
   speech_register, ending_distinctness, release_inventory, source/receipt/history
   음성 검사와 영향 받은 JA/ZH·demo 계약만 실행한다. 새 실패0 전 완료 금지.
   변경 없는240주·전체 감사·옛 준비 화면 검사를 반복하지 않는다.
5. 모든 Godot은 fresh UUID의 proven pre-autoload 격리. 실제 exit·성공 marker와
   stdout/Godot오류·사용자/제품 입력 전후 보존을 남긴다. 과거 실패도 보존한다.
6. L2 각 칸과 현재 candidate commit/tree·독립 보고 SHA를 결속한다.
   scoped source/준비 GO와 실제 화면·원어민 OPEN·본편 출시 HOLD는 분리한다.

규범 승격: 기존 I18N/WORK_UNIT 정본을 적용한다. exact모집단·전이·검사 순서는
일회성이다. 자동 검사는 계약 증거이지 재미·문체·출시 승인이나 인간 증거가 아니다.
