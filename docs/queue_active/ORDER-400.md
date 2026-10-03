# ORDER-400 — 인물 메뉴 중국어 연락·관계 안내 32키

#### [~] ORDER-400 [P0·현지화] 인물 메뉴 중국어 연락·관계 안내 32키

**[~] 착수 — 2026-10-03.** 부모157, 사용자 계속 개발·검수 위임.
Claude 원격394~399 계획의 번호·범위를 덮지 않는 별도 UI 배치다.
393 지역font 실측/수리와 독립 화면 검수를 재사용하며 새 source code 변경0.

## 판정 단위·깊이3문

- 인물 모달의 연락·선물·휴식·관계 상태32키를 CN/TW 각각 한국어에서 직접
  번역한다(64값). 2묶음×16키이며 지역별 공식4교환 batch로 기록한다.
- 제거하면 이미 관측한 영어fallback이 남는다. 장기 선택/경쟁 선택은 번역에
  해당하지 않으며 사람 사실·선택지·돈/AP/선물/저장 상태를 바꾸지 않는다.
- 현재 JA32키·기존CN/TW 값 보존. UI 루트뿐 아니라 실제 소비자의 조건분기와
  placeholder/BBCode/표시폭을 검수한다. 전체 인물 UI 완역으로 부르지 않는다.

## 파일 소유

- Root: locale/ui_zh-CN.json·locale/ui_zh-TW.json 신규32키씩,
  content/meta/full_game_localization.json 신규64receipt/4batch만 공식수용.
  private order400-zh-CN-draft.json·order400-exchange*·order400-static-* 및
  교환 source/response/receipt/append 보존자료. 기존 byte prefix 유지.
- /root/receipt_bridge392: private order400-zh-TW-draft.json만 한국어 직접저작.
  간체 초안의 변환/중역0. tracked 사전/원장 쓰기0.
- /root/receipt_tests392: private order400-check.gd·.tscn·order400-run.py,
  관측 oracle·로그·PNG 및 order400-screen-*만. 393 원본불변.
- /root/independent392: 비저자64값 전수 의미/토큰/지역문자 검수,
  private order400-independent-review.json만; 저작수정은 저자에게 반환한다.
- Root 기록: 이 사양·큐2개·CLAUDE·WORK_LOG·STATUS,
  필요시 docs/history/WORK_LOG_2026-09-07_localization.md 손실없는이동,
  docs/agent_reviews/ORDER-400.json·docs/agent_review_decisions.json,
  완료 시 docs/queue_archive/ORDER-400.md.
- MainGame/FontKit/게임로직/project.godot/검사기/공개demo/인간원장 변경0.
  다른결함은 별도선언한다. 본 오더만으로393 또는391판정을 승계하지 않는다.

## 정확한 모집단 (위에서16키씩 두 묶음)

1. `사람 · 관계`
2. `인맥·휴식`
3. `전화드리기`
4. `전화하기`
5. `전화 걸어보기`
6. `한 잔 하기`
7. `만나기`
8. `안부 묻기`
9. `닿지 않음`
10. `선물로 마음을 전한다`
11. `%d주 뒤에 다시 선물할 수 있다`
12. `선물하기`
13. `인맥 넓히기`
14. `모르는 사람들 사이로 섞인다`
15. `VIP 인맥`
16. `더 높은 곳의 사람들을 만난다`
17. `자유시간`
18. `한강을 걷거나 그냥 쉰다`
19. `만난 사람`
20. `행동력`
21. `곁에 있는 사람을 챙긴다`
22. `새 인맥과 회복 행동`
23. `아직 연락할 사람이 없습니다.`
24. `행동 없음`
25. `[b]패드[/b]  LB/RB 페이지 · ↑↓ 행동 · %s 선택 · %s 뒤로  —  %s`
26. `%s와의 대화가 더 미뤄지고 있다.`
27. `혼자 강남에 가는 사람은 없다.`
28. `끊어지기 직전`
29. `멀어지는 중`
30. `알아가는 중`
31. `서먹한 편`
32. `아직 낯선`

소비자: MainGame::_open_cat_people/_people_pages/_contact_channel_verb/
_people_actions_for_page/_build_people_status_strip/_render_people_page/
_refresh_people_pad_hint/_people_status_line/_relationship_warmth_label.
주간 _people_pressure_state8키·_run_people_action 관계행동1키·접촉 서사/결과/
로그·공유AP배지·동적이름·다른HUD는 비포함이다.

## 표적검증과 효율

- source/target freshness를 잠근 공식 export/check/import, 64값 비저자 전수,
  기존 UI/receipt raw 역삭제·append-only 판정. 재수용·기존값교정0.
- CN/TW 각 초기cast/빈cast/network50/act4 mixed 긴상태4준비화면, 총8PNG.
  실제 MainGame1280×800, Label/RichText 소비·SC/TC font/glyph/경계·BBCode.
  나머지 연락6·warmth 경계·status·선물 ready/cooldown·network49/50 getter를
  전량 대조하여32키별 actual 소비표를 만든다. natural reachability 주장은0.
- fresh pre-autoload StoryNameplateBootstrap 격리, tracked/helper hash,
  실사용자파일 불변과 준비상태 typed복원. 사전/cache/font/theme 주입0.
  raw입력/거래/선물행동/콜백0; prepared 관측을 실입력/물리패드로 부르지 않는다.
- 현재 UI receipt+normal 소비자5, ZH/ENcoverage, context/queue/diff와
  변경파일 기반 audit_select 조회만. Chapter1 720초·최대3병렬.
  제품code/JA/검사기 불변이므로 기존393 focused·JA화면/역사self·전체감사·240주
  반복0. 실패 시 영향 검사만 재실행하며 원본 실패/저자·독립 관찰을 분리한다.
- 기존11px/focus테두리·공유badge/주간표면·동적이름과 B3/B4 원고는 별도잔여.
  기존사전·수용원장·판정·보고·사람원장·공개GO1/인간OPEN45 보존.
  본편/새package HOLD, 원어민/인간/물리 미관측. 외부출시·스토어·지출·법률0.
- 규범: 기존 I18N/WORK_UNIT·gangnamdream-dev 재사용. 상시규범0,
  위 모집단·파일분담·검사계획은 일회성. 자동PASS는 전체품질/출시GO가 아니다.
