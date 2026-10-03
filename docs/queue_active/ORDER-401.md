# ORDER-401 — 인물 모달 중국어 잔여 배지·연락 불가 안내

#### [~] ORDER-401 [P0·현지화] 인물 모달 중국어 잔여 배지·연락 불가 안내

**[~] 착수 — 2026-10-03.** 부모157. 사용자 계속 개발·검수 위임.
400 실제 화면에 남은 영어 배지·연락 불가 사유를 한국어에서 CN/TW로 직접 옮긴다.
8키×2언어=16값, 각 언어 공식1교환 batch. 코드·원문·기존 번역 변경0.

## 판정 단위·깊이3문

- 제거하면400 화면의 MONEY/PEOPLE/Free/1 CHOICE와 연락 불가 영어 사유가 남는다.
- 선택/상태/돈/AP/관계/사망·이혼·이별 조건은 그대로이며 미래 선택을 추가하지 않는다.
  경쟁/24주 상태 차이는 번역에는 해당하지 않는다.
- 한 화면에 실제 남은8키를 묶는다. 추정15~25단위를 맞추려고 미호출 주간pressure나
  다른 메뉴 원고를 추가하지 않는 일회성8단위 배치다.
- 현재 JA8키·CN/TW 기존값·공식 과거receipt/raw 보존. 공용 키가 전파되는 사실과
  실제 화면 검수 범위를 분리하며, 인물 메뉴 전체완역·다른 화면 검수완료로 부르지 않는다.

## 정확한 모집단과 소비자

1. 돈 — MainGame::_axis_label(money)
2. 사람 — MainGame::_axis_label(human)
3. 무료 — MainGame::_make_essential_action_card 비용 배지
4. 이제 닿지 않는 번호다. — _person_reachable(father), 기존 terminal 조건
5. 더는 걸 수 없는 번호가 됐다. — _person_reachable(daeun), daeun_divorced
6. 그녀는 자기 세계로 돌아갔다. — _person_reachable(jiyeon), jiyeon_left
7. 확정 — _ap_status_text, 현재 일반 weekly commitment
8. 1회 선택 — _ap_status_text, 미확정 decision/boss

공유영향: 돈 FIN/MONEY/Money·사람 People/PEOPLE 메뉴 및 CoreLoopPlanner::_rebuild,
무료 다른 비용카드, AP 상태 상단HUD/투자/레버리지, 확정 _add_week_commitment_slot.
대소문자 다른 영어에도 같은 뜻을 유지한다. AP1·숫자format·동적이름·배경HUD·메뉴
설명·pressure8·관계행동·연락/선물 결과 산문·카드 그림 돌출/11px/포커스는 비포함.

## 파일 소유

- Root: locale/ui_zh-CN.json·locale/ui_zh-TW.json 새8키씩,
  content/meta/full_game_localization.json 새16receipt/2batch만 공식수용.
  private order401-zh-CN-draft.json·order401-exchange*·order401-static-*,
  교환 원본/receipt/append 검증자료.
- /root/receipt_bridge392: private order401-zh-TW-draft.json만 한국어 직접저작.
  간체초안 변환/중역0, tracked 쓰기0.
- /root/receipt_tests392: private order401-check.gd·.tscn·order401-run.py,
  관측 oracle·로그·PNG·order401-screen-*만. 400·393 원본불변.
- /root/independent392: 비저자16값 전수 의미·지역문자·실제소비/화면검수,
  private order401-independent-review.json만.
- Root 기록: 본 사양·큐2·CLAUDE·WORK_LOG·STATUS,
  docs/agent_reviews/ORDER-401.json·docs/agent_review_decisions.json,
  완료 시 docs/queue_archive/ORDER-401.md.
- MainGame/FontKit/게임/검사기/project.godot/공개demo/인간원장 변경0.
  새 발견은 별도선언. 400 GO를401 판정으로 승계하지 않는다.

## 표적 검증

- 공식 export/check/import 원본·source/target freshness·16값 비저자 전수,
  기존 UI/receipt raw 역삭제·append-only. 기존수용 재발급/과거메타변경0.
- 실제 MainGame1280×800 CN/TW 각2장, 총4PNG:
  - cast-unreachable: 준비한 기존 부친 terminal·다은 divorced·지연 left 조건의
    비활성3카드 사유/무료와 현재 commitment없는 AP1회 선택.
  - network-set: social50 네트워크/휴식 돈·사람 배지, 현재 턴의 일반 commitment 확정.
- SET 양성은 has_weekly=true/has_story=false/requires_input=true를 모두 확인한다.
  story commitment→AP숫자, 다른 턴 일반 commitment→1회 선택은 getter 반례로 둔다.
  기존 _add_week_commitment_slot의 작은 확정표시도 실제 생성노드·font/폭을 확인한다.
- fresh pre-autoload StoryNameplateBootstrap 격리, 제품/helper hash·사용자34파일
  불변·typed 준비/복원. 실제AP getter warmup으로 정상memoization 두flag만 기록;
  직접cache/font/theme/사전 주입0. producer/finalize/행동콜백/입력/선물/거래0.
  준비한 죽음·이혼·이별·commitment를 자연플레이 도달로 주장하지 않는다.
- 현재 UI receipt+normal 소비자5·ZH/EN·context/queue/diff, 변경파일 audit_select
  조회만. Chapter1 720초·최대3병렬. 새제품code/JA/검사기변경이 없으므로
  역사self/400화면전체/전체감사/240주 재실행0. 실패는 해당영향만 다시 확인한다.
- 상시규범0. 기존I18N·WORK_UNIT·gangnamdream-dev 적용, 위 모집단/준비관측은 일회성.
  자동PASS는 출시/본편GO가 아니다. 공개GO1·인간OPEN45·본편/새packageHOLD 보존.
  원어민/인간/물리패드 미관측, 외부출시/스토어/지출/법률0.
