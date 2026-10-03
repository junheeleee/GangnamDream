# ORDER-406 — 승진 안내의 숨은 확률 비노출 수리

#### [~] ORDER-406 [P1·UI 정합] 승진 안내의 숨은 확률 비노출 수리

**[~] 착수 — 2026-10-04.** 사용자 계속 개발·검수·main 커밋/푸시 위임.
404/405 실제 소비자 조사에서 MainGame::_open_cat_work의 조건 충족 문구가
숨은 정확 확률을 노출함을 확인했다. CLAUDE 불변 규칙의 비노출 수리이며,
승진 확률·조건·판정·수치·밸런스 변경이 아니다.

## 판정 단위·깊이3문

- 지우지 않으면 조건 충족 화면이 KO/EN/JA에서 숨은35%를 계속 공개한다.
- 24주 뒤 상태 차이·경쟁 선택은 N/A: 기존 안내 한 줄만 수리하며 계산은 불변이다.
- 대상 한 source pair와 JA/CN/TW 새3값, 그 source 전이의 공식 수용 연결을 한 단위로 본다.
  다른 승진/구직 문구·일 메뉴 전체 번역·스토리/기능 확장은 하지 않는다.

## 정확한 수정

scenes/MainGame.gd::_open_cat_work 조건문 안 _tr 한 줄:
- KO: `이번 달 승진 판정 대상!  (35% 확률)` → `이번 달 승진 판정 대상!`
- EN: `Up for promotion this month!  (35% chance)` →
  `Eligible for a promotion review this month!`
- 조건 `tenure >= threshold and perf >= 60`, promo_count/max_promo와 실제 판정 계산 불변.
- 새KO에서 JA/CN/TW 직접 번역3값을 공식 export/check/import 언어당1batch로 수용한다.
  승진 확정으로 바꾸지 않는다. old JA키는 immutable 값 그대로 비도달 역사행으로 보존하며
  old key 실제소비0/accepted receipt0, 새 key actual1을 증명한다. 옛receipt/header 재작성0.
- MainGame-only 한 줄 commit을 먼저 만들어 실제 Git parent/tree/blob를 고정하고,
  후속6도구와 번역을 최종 source candidate로 동결한다. 중간 checkpoint를 GO로 주장하지 않는다.

## 파일 소유

- Root: scenes/MainGame.gd 한 줄; locale/ui_ja.json·ui_zh-CN.json·ui_zh-TW.json 새1값씩;
  content/meta/full_game_localization.json 새3receipt/3batch 공식수용만.
  private order406-exchange*·order406-static*·draft/original proof.
- /root/receipt_bridge392: tools/main_game_locale_history.py,
  tools/ja_translation_pipeline.py, tools/ja_translation_audit.py,
  tools/ui_translation_append.py, tools/ui_translation_append_self_test.py,
  tools/audit_scope.json만. 새 finite successor·collector/retainedJA·focused 연결.
- /root/receipt_tests392: private order406-run*·order406-check*·oracle/로그/PNG만.
- /root/independent392: 비저자3값·source/bridge/실제 화면·원본증거 검수,
  private order406-independent-review.json만.
- Root 기록: 이 사양·CODEX_QUEUE·CLAUDE·WORK_LOG·STATUS,
  docs/agent_reviews/ORDER-406.json·docs/agent_review_decisions.json·완료archive.
- source inventory 원장·기존pins/함수본문·기존 helper/증거·공개demo·인간원장·
  project.godot·저장·거래·스케줄·엔딩·다른게임코드 변경0.

## 유한 source 연결과 검수

- MainGame은 한 줄 inverse로 이전 raw와 byte-exact. 403까지8stage 불변,
  actual406의9번째 Git parent/tree/blob/head·path집합·역방향증명.
  캐시 성공 재사용0; missing/wrong Git proof와 PASS→proof loss를 fresh 재검증.
- collector는390 tutorial+406 승진 exact2pair만 이전 view와 의미가 다르다.
  현재 leaf/source/좌표는 actual406 실물을 읽고 다른 source/ID/포맷/조건/호출수 불변.
  pipeline 새 appendix self-seal과 제거 후 이전 전체 byte-exact.
- JA audit은 old승진1키 exact immutable target·current call0·accepted receipt0만
  보존행 허용. 기존390 보존행 검사 불변. 누락/변형/추가/재호출/가짜receipt 거부.
- 공식 manifest는 actual406+pre406+기존6 main raw의 currentAruba8조합과
  pre381/preAruba1조합만 총9개. 실패402 중간raw·교차조합 허용0.
- 새 focused 한 차선: exact pair/부분수정/중복/이동/인접문구/조건변조,
  Git증명결손·HEAD 불일치·proof loss, collector key/좌표/전량맵,
  JA retained 오염,9manifest집합 및 fresh3receipt를 표적 검증한다.
  이전 focused/historical 전체를 다시 돌리지 않는다.
- 실제 MainGame 조건 충족 메뉴 KO/EN/JA/CN/TW 1280×800 각1PNG:
  DataRegistry 실제직업 복사, tenure=실제threshold·performance60·승진수<max의
  준비상태(월급은실제job.base_salary, startup/creator=false),
  정확한 새문구 한 노드/old35%문구0, 노드폭/font/모달bounds 측정.
  전체 일메뉴 번역/품질 GO가 아니라 대상 한줄 소비 관측이다.
- fresh pre-autoload StoryNameplateBootstrap·typed 깊은복원·사용자34파일/
  source/helper hash보존, 입력·승진계산실행·confirm/pressed/거래/finalizer0.
  dictionary/font/theme/cache injection0; 자연취업/시간진행/Back/물리관측0.
- runtime 통과 후 새focused 및 current normal receipt/collector·JA UI·ZH/EN·
  Chapter1 등 source영향 소비자·context/queue/diff, audit_select 목록조회1.
  최대3병렬/Chapter1 720초. 전체감사·240주·완료단위화면 반복0.
  실패 원본 보존 후 해당 영향만 재검증한다.

## 판정 경계

상시규범 추가0/일회성. 기존 숨은확률 비노출·I18N·WORK_UNIT 규칙 적용.
공개GO1·인간OPEN45·본편/새packageHOLD 유지. source work_unit 독립판정만 하며,
자동PASS는 재미/문체/출시GO가 아니다. native_reader/human_playtest/
physical_controller_feel 및 자연진입/다른승진상태/다른해상도 미관측.
외부출시·스토어·지출·법률0.
