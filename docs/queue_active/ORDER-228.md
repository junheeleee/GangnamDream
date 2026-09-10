# Active Queue Spec: ORDER-228

> [~] 2026-09-10 착수 — 중반 생활20종의 JA·zh-CN·zh-TW 직접 번역.
> 실행 순서는 CODEX_QUEUE.md, 최종 내부 권한과 실제 관찰 경계는 WORK_UNIT.md가 소유한다.

## 입력·깊이 3문

기준 clean main ab55c9a683e131769a5729e5a964a5770793c94b. 이전227의 내부 GO를
이번 작업이나 본편 GO로 가져오지 않는다. 현재 수용36,076(JA12,024/CN·TW12,026),
batch87/meta9, 비보호 shipping 잔여84종622문구/언어다.

1. 없으면 무엇이 깨지는가: 아래20종169문구/언어가 영어 폴백에 남는다.
2. 24주 뒤 무엇이 다른가: 원본 선택·급여·투자·부모 분기 효과는 유지하고 같은 결과를
   대상 언어로 읽는다. 번역은 새 상태나 성공 보장을 만들지 않는다.
3. 무엇과 경쟁하는가: 원문에서 직장 시간·투자 위험·사람에게 연락·혼자 버티기가
   경쟁한다. 비용·포기·응답 여부를 친절한 정답으로 바꾸지 않는다.

원본 content/events/arc_midgame.json 298279B,
SHA c95b30b2172ebc64f3812527a8656b6055fa2068e2b728c0838bcad965eafffd.
source manifest db7c9549e2692e657859d8d7329fbf9439894bcdf4c8bd379f85ba4a5d762d99.
정렬169 source record SHA 3f6b386603e4aee56160ce3893f8802b2f72fb94a2e173aa8ebbfac1a3938069.
60선택·LF252·{name}47/{assets}2/{job}1/{money}1, protected0·author_only0.

## 정확한20종 — KO 상대순서

arc_hyunsu_night_talk, arc_job_vs_invest, arc_social_comparison,
arc_first_real_win, arc_gangnam_visit_alone, arc_money_loneliness,
arc_quit_job, arc_first_job_week, arc_first_job_week_convenience,
arc_first_job_week_delivery, arc_night_routine, arc_gangnam_real_estate,
arc_four_months_in, arc_paycheck_reality, arc_office_routine,
arc_invest_first_loss, arc_year_two_pressure, arc_first_real_win_father_passed,
arc_money_loneliness_father_passed, arc_gangnam_real_estate_father_passed.

## 소유권·진행

- content/events_{ja,zh-CN,zh-TW}/arc_midgame.json: 위20종 text-only append.
  기존31객체/언어의 raw prefix·값·상대순서 보존. 공식 초기 export를 먼저 한다.
- content/meta/full_game_localization.json: 검수된 신규507만 append 수용.
  이전36,076 accepted와 batch87/meta9는 raw 역보존. 초안을 수용으로 세지 않는다.
- 조건부 tools/ja_translation_pipeline.py, tools/zh_translation_audit.py,
  tools/full_game_localization.py, tools/full_game_localization_self_test.py:
  이번 실제169 최초 검사에서 재현된 국소 오탐만. 원문 지문·역할/수량 대조와
  비저자 고정 정상/변조/sourceOFF를 먼저 봉인한다. 필요 없으면 수정0.
- tools/audit_scope.json의 이 사양·결과 보고 두 경로 등록.
- CLAUDE.md, docs/CODEX_QUEUE.md, docs/CODEX_QUEUE_L3_PENDING.md(기존75행 보존),
  docs/WORK_LOG.md, docs/STATUS.md, docs/queue_backlog/FULL_GAME_LOCALIZATION.md,
  이 사양·docs/queue_archive/ORDER-228_L1_L2_RESULTS.md,
  docs/agent_review_decisions.json 및 해당 docs/agent_reviews/ 단일 보고.
- WORK_LOG 예산391B 잔여: 완료 기록 공간만 확보하도록 맨 아래 완료138절을
  기존 docs/history/WORK_LOG_2026-09-07_localization.md에 raw 손실 없이 이동한다.
- git-private order228-* 초안·교환·실패·검수 근거. 기존 증거를 덮지 않는다.

Plato JA169, Rawls CN169, Poincare TW169를 KO에서 각각 직접 저작한다.
비저자 전량 대조는 Rawls→JA, Poincare→CN, Plato→TW. ROOT는 원문/소비자·검사·통합,
마지막 exact 후보는 비저자가 다른 언어의 독립 판정을 포함해 결속한다.
EN 중역·간번변환0. KO/EN·게임플레이·스케줄러·원본 저장·project.godot·공개 M01–M06·
human_gates.json·출시 언어·스토어는 비소유다.

## 원문 채무와 사실 안전선

현수 새벽1시→자정→자정 전 역전, first-win 5천만원/50만원×100 및
아이스크림5천원/효과1만5천원, four-months ID/반년 제목, 연차와 dispatch 주차 차이는
번역에서 몰래 정정하지 않는다. 사별 first-win은 실제 발신·없는 번호 안내·발신 시각이며,
money-loneliness 사별은 연락처·기록·기억이지 새 통화/녹음이 아니다.
first-win 사별의 고시원 계단/current_housing 및 first-loss의 보유자산 가드 부재는
소비자 국소 사전 조사 채무이지 Ch5 결혼 뒤 실제 재진입을 입증한 결함이 아니다.
퇴사 상태 해제와 인수인계 산문, 투자 실제 매도·사흘 뒤 손실 절반·추가20만원을 구별한다.
집 즐겨찾기는 소유가 아니며 실제 답장·실제 도착만 원문 범위에서 유지한다.

## 검증·종료

초기 공식169 export×3 → 직접 저작/최초169 L1 원형 → 비저자507 전량 의미 대조 →
필요 수리/같은 전량 재결속 → 현재 target hash의 최종 export/check/import --accept.
기존값·KO·보호물·원장 역보존, 전체 수용 hash/L1 1회(기존227 UI4 비대칭 포함),
명시 full-game-localization-overlays 12검사 1회, scope/context/queue/diff 및
clean 메타데이터에서 STATUS 생성→검사→wrapper commit→동일 검사.
실패가 없으면 같은 검사를 반복하지 않는다. 전체 감사·240주·Year5·Godot·227의
완료된 UI fixture는 이 번역 배치에서 재실행하지 않는다.

수용 뒤 예상36,583(JA12,193/CN·TW12,195)/b88·잔여64종453문구/언어는 아직 실적이 아니다.
정확 제품 commit/tree와 비저자 근거가 결속된 work_unit228만 내부 GO로 닫는다.
본편 HOLD, native_reader/human_playtest/physical_controller_feel 및 렌더 OPEN.
자동 게이트는 계약·회귀 증거이지 재미·깊이·문체나 인간 관찰의 증거가 아니다.
새 규범은 모두 이 배치 일회성이다. 언어·수용·판정 영구 규칙은 기존 정본을 따른다.
