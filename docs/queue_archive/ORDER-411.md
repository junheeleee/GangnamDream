# ORDER-411 — 생활 주거 상태·다음 주거 중국어 소비자 마감

#### [x] ORDER-411 [P1·현지화] 생활 주거 상태·다음 주거 중국어 소비자 마감

## 완료 — 2026-10-04

- source `5f40003af611af74e2a03e60ffa38b0376050f38`, tree `2aeb3e9d04080a1572af6c7182de596dd8b0ea59`.
- KO직접 CN/TW19값씩·38값 비저자 전수수용. accepted41220/b182, JA3044불변.
- 실제5상태×2언어10PNG·88대상·38lookup·84binding PASS17.285초.
  20주거카드82px·부제최대361/410px, typed복원10/source2984/helper44/player34 보존.
- normal11+조회1 PASS635.627초·Chapter1 325.394초.
  source2984/helper54/입력10/이전증거4 불변. [독립 원문·화면 검수](../agent_reviews/ORDER-411.json) GO.
- 일회성/상시규범추가0. 자동PASS는 계약증거이지 재미·문체·출시GO가 아니다.
  공개GO1·인간OPEN45·본편/새packageHOLD·자연진입/Back/원어민/인간/물리미관측 유지.
  선물영역의 가격 앞자리잘림은 별도412로 수리하며 선물번역/스크롤전체는 미승인이다.

아래 착수 원문은 보존한다.

**[~] 착수 — 2026-10-04.** 사용자 계속 개발·검수·main 커밋/푸시 위임.
기존 생활 모달의 현재 주거·월 부담·이사/계약 갱신·부족액을
KO에서 CN/TW로 각각 직접 번역한다. 이사·구매나 새 행동판을 활성화하지 않는다.

## 판정 단위·깊이3문

- 생략하면 현재 주거와 다음 주거의 비용/부족액 안내19 source가 영어로 남는다.
- 24주 뒤 상태·경쟁은 N/A: 표시만 번역하며 주거조건·비용·돈·시간은 불변.
- 기존19 source를19단위, CN/TW 각19값으로 한 배치 판정한다.
  locale당1공식교환·38값/2batch, 비저자38값 원문대조 전수.

## 정확한 모집단

MainGame::_open_cat_life의 legacy14:
1. `생활`
2. `주거는 삶의 질이다. 더 나은 곳으로 갈수록 정신력에 여유가 생긴다.`
3. `지금 사는 신혼집과 내 이름으로 남겨 두는 주거 계약은 따로 표시된다.`
4. `현재 생활  —  %s`
5. `현재 주거  —  %s`
6. `내 주거 계약의 월 부담 %s · 현금 %s`
7. `월 고정비 %s · 현금 %s`
8. `다음 주거 없음`
9. `이제 목표는 강남 입성 자산을 만드는 것이다.`
10. `내 주거 계약 갱신  —  %s  (월 %s / 보증금 %s)`
11. `이사  —  %s  (월 %s / 보증금 %s)`
12. `다음 주거 계약  —  %s`
13. `다음 이사  —  %s`
14. `필요 현금 %s · 부족액 %s`

기존 context1:
15. `ui.housing.now_status` — KO `현재`, EN `Now`.
    일반KO키가 아니라 context ID의 사전/receipt로 추가한다.

GameState 실제 삽입값4:
16. `고시원`
17. `원룸`
18. `빌라 전세`
19. `아파트 전세`

9포맷키·%s16개의 순서, 월 비용/보증금/필요액 구분과 원화 의미를 보존한다.
주거명 두 reader는 KO당1leaf이며 새provider가 필요 없다. 전세를 소유권/매매로 바꾸지 않는다.
JA19기존값·기존사전/receipt/header 보존. 두 지역 간 문자변환0.
기존 완료/신혼집명/일반preview·선물진열대2설명은 별도 범위다.
공유주거명 소비자가 다른 화면에도 적용돼도 그 화면 fit을 승인하지 않는다.

## 파일 소유

- Root: CNdraft·locale/ui_zh-CN.json 및 locale/ui_zh-TW.json 신규값 merge,
  content/meta/full_game_localization.json 공식38receipt/2batch,
  private order411-exchange*·order411-static*·공식교환원본.
- /root/receipt_bridge392: private order411-zh-TW-draft.json KO직접 저작만.
- /root/receipt_tests392: 새 private order411-run.py·check.gd·check.tscn만,
  기존격리/서체/typed복원helper 불변재사용. 엔진 실행은 root 사전검토 후.
- /root/independent392: 비저자38값·공식수용·10화면·검수원본,
  private order411-independent-review.json만.
- Root 기록: 이사양·CODEX_QUEUE·CLAUDE·WORK_LOG·STATUS·완료archive,
  docs/agent_reviews/ORDER-411.json·docs/agent_review_decisions.json.
- MainGame/GameState/FontKit·조건/비용/확률/저장/스케줄/엔딩·KO/EN/JA·
  project.godot·공개demo·인간원장·sourceinventory·tools 변경0.

## 표적 검수

- 공식export/check/import locale당1batch; source/selection/leaf/target hash와
  receipt/header 연결, append inverse로 이전raw 전량보존.
- 실제 MainGame::_open_cat_life 1280×800, CN/TW 각5상태 총10PNG:
  A gosiwon/500000·일반: 현재·다음이사·부족액.
  B oneroom/40000000·일반: 이사버튼·빌라전세.
  C villa/40000000·공유: 현재생활·다음계약·부족액.
  D villa/130000000·공유: 계약갱신·아파트전세.
  E apartment/150000000·일반: 최종주거·목표.
  공유는 실제 arc_daeun_wedding_day_seen=true와 daeun_divorced=false로 준비한다.
  get_housing_info/can_upgrade_housing 및 실제 지역통화/주거명 getter를 대조한다.
- 신규19키 union실제소비·38lookup, context/legacy 삽입값의 실노드 연결.
  긴 주거/월비용/보증금 버튼과14px 상태부제 전체fit, badge·포함·겹침을 확인한다.
  문장줄바꿈은 실제Label line/visible count와높이로 판정하며 ellipse/잘림을 면제하지 않는다.
  target주거영역만 판정하고 선물진열대 전체번역·전체모달스크롤 완료로 확대하지 않는다.
- pre-autoload격리·typed전체복원·registry/player/source/helper hash불변,
  dictionary/font/theme/cache주입0. 모든10PNG 직접·독립열람.
  이사/구매/confirm/시간진행0, 준비fixture이지 자연진입/Back/물리관측이 아니다.
- normal receipt/fullbody/storygraph/Chapter5/Year5/Chapter1/ZH/EN/context/queue/diff,
  audit_select 목록조회만 최종후보1회 최대3병렬; Chapter1 timeout1200.
  source/tools변경0이므로 이전focused/JA전용/완료화면/역사suite/전체감사/240주 재실행0.
  실패원본보존 후 해당영향만 새시도. 실제layout결함은 새수리범위 선언 전 수정0.

## 경계

일회성 사양·상시규범추가0. 자동PASS는 계약증거이지 재미·깊이·문체·출시GO가 아니다.
공개GO1·인간OPEN45·본편/새packageHOLD·원어민/인간/물리미관측 보존.
Claude B3/B4·선물/그밖UI영어폴백·전체번역은 별도후속.
외부출시·스토어·지출·법률0.
