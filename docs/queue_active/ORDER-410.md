# ORDER-410 — 자기계발 선택·누적 기록 중국어 소비자 마감

#### [~] ORDER-410 [P1·현지화] 자기계발 선택·누적 기록 중국어 소비자 마감

**[~] 착수 — 2026-10-04.** 사용자 계속 개발·검수·main 커밋/푸시 위임.
기존 _open_cat_dev → _ap_study의 선택 설명·누적 기록·AP 소진 안내를
한국어에서 중국어 간체·번체로 각각 직접 번역한다. 기존 행동판을 새로 활성화하지 않는다.

## 판정 단위·깊이3문

- 생략하면 자기계발 선택과 누적 기록의 아래15키가 CN/TW에서 영어로 남는다.
- 24주 뒤 상태·경쟁은 N/A: 표시 번역만 추가하며 공부/보상/AP/시간/선택은 불변이다.
- 기존KO15키를15단위, CN/TW 각15값으로 한 배치 판정한다.
  공식 locale당1교환·30값/2batch이며 비저자 원문 대조 전수30을 한다.

## 정확한 모집단

1. `행동력이 없습니다`
2. `자기계발`
3. `이번 주, 무엇을 갈고닦을까.`
4. `독서`
5. `책 한 권만큼 넓어진다`
6. `운동`
7. `몸을 만든다 — 사람 쪽 시간`
8. `명상`
9. `숨을 고르고 머리를 비운다`
10. `투자공부`
11. `돈이 되기 전의 눈을 만든다`
12. `독서 — {n}권째`
13. `운동 — {n}주차`
14. `명상 — {n}회째`
15. `투자공부 — {n}회째`

{n}·책/주/횟수·원문 의미를 보존하며 수치·효과·성공 보장을 발명하지 않는다.
두 지역을 문자변환하지 않는다. JA15기존값·기존사전/receipt/header는 원문 보존한다.
공유키가 행동판·루틴·결과·회고·직업/투자 AP 오류에도 쓰이나 이들 전체 화면
번역 완료를 주장하지 않는다. 새 기능/휴식 비네트/임계 보상은 범위 밖이다.

## 파일 소유

- Root: locale/ui_zh-CN.json·locale/ui_zh-TW.json 신규값 merge만,
  content/meta/full_game_localization.json 공식30receipt/2batch,
  private order410-exchange*·order410-static*·CN draft·공식 교환 원본.
- /root/receipt_bridge392: private order410-zh-TW-draft.json만 한국어 직접 저작.
- /root/receipt_tests392: 새 private order410-run.py·order410-check.gd·
  order410-check.tscn만. 기존 격리/서체/typed복원 helper를 재사용하고 수정하지 않는다.
  엔진 실행은 root의 사전검토 뒤1회; 실제 산출물은 root가 생성한다.
- /root/independent392: 비저자 전수30값·공식수용·실제4화면·원본 검수,
  private order410-independent-review.json만.
- Root 기록: 이 사양·CODEX_QUEUE·CLAUDE·WORK_LOG·STATUS·완료archive,
  docs/agent_reviews/ORDER-410.json·docs/agent_review_decisions.json.
- MainGame/JobSystem/FontKit/NotificationToast·게임 조건/확률/저장/스케줄/엔딩·
  KO/EN/JA·project.godot·공개demo·인간원장·소스inventory·tools/ 변경0.

## 표적 검수

- 공식 export/check/import locale당1batch, current source/selection/leaf/target hash와
  receipt/header 연결, append inverse로 이전 raw 전량 복구 증명.
- CN/TW 실제 MainGame 1280×800 각2상태 총4PNG:
  A: action_points=1, study_count_read/exercise/meditate/invest 각12.
     실제 _open_cat_dev → _ap_study의 제목·소개·4카드·결합누적14키/10Labels.
  B: action_points=0에서 같은 진입. 실제 NotificationToast의 AP 오류1키,
     모달 생성·AP 소비·공부 실행0. 실제 toast 표시 후 사라짐도 관측한다.
  누적0은 새고유키가 없어 별도 캡처하지 않는다.
- 카드 선택은 번역문 아닌 기존 ap_study_type=0..3 메타로 식별한다.
  실제 subtitle14px의 설명+누적 전체 fit,4카드72px·Atlas128×64·상하margin8의
  combined minimum/포함/겹침을 측정한다. 실제overflow는 면제하지 않고 별도수리로 남긴다.
  toast의 실제 font/viewport/수명도 확인한다.
- pre-autoload격리·typed전량복원·원본registry/실제player/source/helper hash불변.
  dictionary/font/theme/cache주입0. 실제지역 primary glyph/fontsize/노드폭을 대조하고
  4PNG 모두 직접열람/독립검수. lookup30·신규15키 union실제소비를 결속한다.
- 실제 action/confirm/study commit/trade/finalizer0; 자연진입/Back/물리관측0.
- 기존normal receipt·fullbody·storygraph·Chapter5·Year5·Chapter1·ZH·EN·
  context/queue/diff와 audit_select 목록조회만 최종후보1회, 최대3병렬.
  source/도구변경0이므로409focused·JA전용·완료화면·역사suite·전체감사·240주 재실행0.
  Chapter1 timeout1200초. 실패원본 보존 뒤 해당영향만 새시도로 검수.

## 경계

일회성 사양·상시규범추가0. 자동PASS는 도달성/계약 증거이지 재미·깊이·문체·출시GO가 아니다.
공개GO1·인간OPEN45·본편/새packageHOLD·원어민/인간/물리미관측 보존.
Claude B3/B4와 다른UI영어폴백·전체번역은 별도후속. 외부출시·스토어·지출·법률0.
