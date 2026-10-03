# ORDER-404 — 무직 취업 메뉴 중국어 안내 9종

#### [~] ORDER-404 [P1·현지화] 무직 취업 메뉴 중국어 안내 9종

**[~] 착수 — 2026-10-04.** 부모157. 사용자 계속 개발·검수·main 동기화 위임.
403 실제 CN/TW work 화면에서 남은 영어를 한국어 원문에서 직접 옮긴다.
9키×2언어=18값, 각 언어 공식1교환 batch. 코드·원문·기존 번역 변경0.

## 판정 단위·깊이3문

- 제거하면 무직 플레이어의 일 메뉴 제목·설명·구직/지원서/면접 준비가 영어로 남는다.
- 번역만 바꾸며 선택·돈/AP/시간·능력치·취업 조건은 그대로다.
  24주 상태 차이·경쟁 선택 추가는 해당 없음. 기존 수치/조건의 재설계가 아니다.
- 실제 한 메뉴의 무직2분기를 하나로 묶는다. 추정15~25개를 맞추려고 취업 후
  승진/창업/크리에이터 원고를 추가하지 않는다. 공용 미리보기의 실제 관측 범위를 구분한다.

## 정확한 모집단과 소비자

MainGame::_open_cat_work → _cat_modal_button → _make_essential_action_card;
_ap_action_preview의 기존3문구. 현재 JA9키 존재/CN·TW9키 부재.

1. 일 · 커리어
2. 아직 직업이 없다. 수입이 0원이다. 무엇이든 시작해야 한다.
3. 구직활동  —  일자리를 찾아 지원한다
4. 지원 계속  —  마포 면접 이후 다음 지원처를 고른다
5. 자소서 작성  —  지원서를 다듬는다
6. 모의 면접  —  말하는 연습을 한다
7. 중간 위험 · AP 1 · 조건 충족 시 취업 · 1~3주: 첫 월급
8. 낮은 위험 · AP 1 · 지력 0~2 · 이력서 완성 · 1~3주: 지원 보너스
9. 낮은 위험 · AP 1 · 사회성 0~2 · 운 0~1 · 1~3주: 면접 보너스

수치/range/조건·AP/기간, 자소서와 이력서의 원문 차이, 마포 지명 보존.
입력 glyph·돈배지·AP상태의 기존 번역은 변경하지 않는다.
취업 후 화면·창업·크리에이터·행동 결과 산문·다른 공용 소비자는 비포함.

## 파일 소유

- Root: locale/ui_zh-CN.json·locale/ui_zh-TW.json 새9키씩,
  content/meta/full_game_localization.json 새18receipt/2batch 공식수용만.
  private order404-zh-CN-draft.json·order404-exchange*·order404-static-*,
  원본교환/receipt/append 검증자료.
- /root/receipt_bridge392: private order404-zh-TW-draft.json만 한국어 직접저작.
  CN초안 변환/중역0, tracked·검사기 수정0.
- /root/receipt_tests392: private order404-check.gd·.tscn·order404-run.py,
  새 oracle·원본로그·PNG·order404-screen-*만. 이전 helper/증거불변.
- /root/independent392: 비저자18값 전수 의미·지역문자·숫자·실제소비/화면검수,
  private order404-independent-review.json만.
- Root 기록: 본 사양·큐2·CLAUDE·WORK_LOG·STATUS,
  docs/agent_reviews/ORDER-404.json·docs/agent_review_decisions.json·완료archive.
- MainGame/FontKit/게임/검사기/project.godot/공개demo/인간원장 변경0.
  새 결함은 별도선언하며403 GO를404 판정으로 승계하지 않는다.

## 표적 검증

- 공식 export/check/import 원본·source/target freshness·18값 비저자 전수,
  기존 UI/receipt raw 역삭제·append-only. 과거수용 재발급/헤더/메타변경0.
- 실제MainGame1280×800 CN/TW 각2장, 총4PNG:
  - initial: current_job={}·arc_intro_meal_seen=false·social_skill0 → 구직/자소서2카드.
  - after-mapo: current_job={}·arc_intro_meal_seen=true·social_skill20 → 지원계속/자소서/모의면접3카드.
  - startup_launched/creator_started=false. 두fixture 합집합9키/locale를 실제
    제목·설명·split title/subtitle·preview 노드와 lookup/수신함수 identity로 결속한다.
- 403 원본 CN/TW work는 초기6키 영어폴백·기하 비교에만 재사용한다.
  후속3키의 before 관측으로 부르지 않는다. 새 문자열의 실제SC/TC font·글자폭·
  card82/모달bounds·이웃 nonoverlap을 새로 확인한다. 403의 영어ellipsis 면제를
  새중문에 자동승계하거나 전체text-fit GO로 부르지 않는다.
- fresh pre-autoload StoryNameplateBootstrap·새namespace, typed 준비/표시/복원;
  current_job 깊은 복사·전체flags/social/AP/money/turn/cast/inventory/선택상태 보존.
  정상AP getter warmup의 두memoization flag만 기록. 실제사용자34파일과
  제품/helper hash 불변. font/theme/사전/cache주입0, 입력/pressed/행동/거래/finalizer0.
  준비한 마포후기/social20을 자연플레이 도달로 주장하지 않는다.
- 현재 UI receipt+normal 소비자5·ZH/EN·context/queue/diff, 변경파일 audit_select
  조회만. Chapter1 720초·최대3병렬. 제품code/JA/검사기 불변이므로403focused/
  역사self/이전화면전체/전체감사/240주 반복0. 실패원본 보존 후 해당영향만 재검증.
- 공개GO1·인간OPEN45·본편/새packageHOLD 보존. 자동PASS는 재미/깊이/문체·출시GO가 아니다.
  원어민/인간/물리패드·자연진입/Back/행동 결과·다른해상도 미관측, 외부출시/스토어/지출/법률0.
- 상시규범0/일회성. 기존 I18N·WORK_UNIT·gangnamdream-dev 적용.
