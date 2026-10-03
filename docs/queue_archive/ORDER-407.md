# ORDER-407 — 직장·승진·사업 안내 중국어 소비자 마감

#### [x] ORDER-407 [P1·현지화] 직장·승진·사업 안내 중국어 소비자 마감

## 완료 — 2026-10-04

- source `9e3705a8d1b631adcd9f5aff861b6883e2696867`, tree `913e1964a21d41e0ae9015949be77a93a4c3b81c`.
- 기존KO15키·CN/TW30값·공식2batch; accepted41152/b178·UI1482씩·JA3044불변.
- 실제6PNG·30lookup·52binding기록/56노드등장·86text·4cards 직접 검수.
  최초 runtime FAIL6은 JSON float/실제int 비교 결함으로 보존; 새r1에서 expected
  정수5필드만 lossless 정규화하고 typed전량검사 유지,13.265초PASS.
- normal11+조회1 PASS776.969초(Chapter1 776.493초); source2975/helper33불변.
  runtime은 helper35/player34·typed복원6·warmupdelta0·실제입력/행동0.
- [독립 전수 검수](../agent_reviews/ORDER-407.json) GO. 공개GO1·인간OPEN45·
  본편/새packageHOLD와 원어민/인간/물리 미관측 유지. EN2결함은 별도수리.
- 일회성 사양, 상시규범 추가0. 자동PASS는 도달성/계약 증거이지 재미·깊이·문체·출시GO가 아니다.

아래 착수 원문은 보존한다.

**[~] 착수 — 2026-10-04.** 사용자 계속 개발·검수·main 커밋/푸시 위임.
406 실제 화면에서 직장 메뉴의 CN/TW 영어 폴백을 확인했다.
한국어 15키를 각 지역에 직접 번역하여 기존 표시 소비자를 채운다.
새 직업·승진 규칙·기능 또는 월간 행동판을 추가하지 않는다.

## 판정 단위·깊이3문

- 생략하면 직장·승진 상태와 사업/콘텐츠 카드의 해당 15키가 CN/TW에서 영어로 남는다.
- 24주 뒤 상태 차이·경쟁은 N/A: 기존 표시값만 번역하고 조건/수치/행동은 불변이다.
- 한국어 키 15개를 15단위, CN/TW 각각15값으로 한 배치 판정한다.
  각 언어 공식1교환, 합계30값/2batch. 첫 배치 규칙으로 독립 원문 대조 전수30.

## 정확한 모집단

1. `%s — 월급 %s`
2. `── 승진 현황 ──`
3. `최고 직급 달성 — 더 높은 직종으로 이직을 고려하세요.`
4. `근속`
5. `%d / %d개월`
6. `승진 준비됨`
7. `기준 미달`
8. `업무 성과  %d / 100  [%s]  (기준: 60+)`
9. `근속 기간 충족. 업무 성과를 60 이상으로 올리세요.`
10. `%d개월 후 승진 판정 — 그때까지 성과를 쌓아라.`
11. `다음 직급 예시  ` (끝 공백2)
12. `남는 행동력은 투자·자기계발·관계에 쓰자.`
13. `창업 업무  —  내 사업을 키운다`
14. `콘텐츠 제작  —  채널을 키운다`
15. `이후  경력과 월수입`

자리표시자 종류/순서, 100·60+, 개월·월급·다음 직급 예시라는 의미를 보존한다.
성과 기준 충족을 승진 확정으로 바꾸지 않는다. 창업/콘텐츠 카드의 실제 job fallback
preview를 번역하며 별도 효과나 수치를 발명하지 않는다. 두 지역을 문자변환하지 않는다.
406 새 자격 문구·기존JA15값·기존dictionary/receipt/header는 바이트 보존한다.

## 파일 소유

- Root: locale/ui_zh-CN.json 새15값, content/meta/full_game_localization.json
  공식30receipt/2batch만, private order407-exchange*·order407-static*·CN draft·원본 교환.
- /root/receipt_bridge392: private order407-zh-TW-draft.json만 한국어 직접 저작.
  사전·수용 원장은 root만 쓰며 tools/ 수정0.
- /root/receipt_tests392: 새 private order407-run.py·order407-check.gd·
  order407-check.tscn과 해당 실행 산출물만. 기존 helper/증거 불변.
- /root/independent392: 비저자 전수30값·공식수용·실제화면·원본 검수,
  private order407-independent-review.json만.
- Root 기록: 이 사양·CODEX_QUEUE·CLAUDE·WORK_LOG·STATUS,
  docs/agent_reviews/ORDER-407.json·docs/agent_review_decisions.json·완료archive.
- MainGame/JobSystem/FontKit·게임 조건/확률/저장/스케줄/엔딩·KO/EN/JA·
  project.godot·공개demo·인간원장·소스inventory·이전 도구 변경0.

## 표적 검수

- 공식 export/check/import locale당1batch; 현재 source/selection/leaf/target hash와
  private receipt/header 연결, append inverse로 이전 raw 전량 복구를 증명한다.
- CN/TW 실제 MainGame 일 메뉴 1280×800: 준비된 승진자격/성과미달/
  근속부족/최고직급 상태와 창업·콘텐츠 카드 소비자를 관측한다.
  각 언어 A 최고직급+startup/creator 두카드, B 근속충족/perf59,
  C threshold-1/perf60의3상태, 총6PNG로 신규15키 union을 전부 덮는다.
  406에서 완료한 자격충족 화면은 반복하지 않는다. 실제 job_03 복사본을 쓰며,
  B/C의 사업/콘텐츠 flags=false, A는 각각 launched/started=true·exit/viral=false.
  scroll=0·스크롤바 비노출·모든 대상/카드의 scroll/modal/viewport 포함을 실제 측정한다.
  직업/threshold/max_promo/base_salary/promotion_bonus는 실제 DataRegistry에서 가져온다.
  A current_job복사본의 promotion_count=max, effective_salary와 monthly_income은
  base+max*bonus(현재3,110,000원), B/C는 count0·base(현재2,240,000원)로 준비한다.
  registry 원본은 불변이며 준비 복사본의 선언된 추가 필드를 분리해 대조한다.
  실제 label/template·분리 title/subtitle·중첩 gate·공유preview를 매핑하며
  두 언어15키 전부 적어도 한 번 lookup/실제노드 binding을 남긴다.
- 새 pre-autoload 격리, typed 전체 복원, 실제 사용자파일·source/helper hash 보존.
  dictionary/font/theme/cache 주입0. 실제 primary regional glyph/font size와
  줄바꿈/노드폭/모달bounds를 측정하고 모든 대상 PNG를 직접 열람한다.
  실제 action/confirm/promotion/trade/finalizer0; 자연진입/Back/물리관측0.
- 영향 선택에 맞는 기존 normal receipt/collector·ZH/EN·context/queue/diff와
  source영향 소비자만 최종후보에서1회, audit_select 목록조회1.
  새 source/도구변경이 없으므로406 focused·JA전용·완료화면·전체감사·240주 재실행0.
  최대3병렬, Chapter1이 선택되면1200초(406 초회720초 시간초과 실측 반영). 실패 원본 보존 후 해당 영향만 재검증.

## 경계와 다음 결함

상시규범 추가0/일회성. 자동PASS는 도달성/계약 증거이지 재미·깊이·문체·출시GO가 아니다.
406에서 확인한 EN Tenure 36px 잘림과 EN above60/실제>=60 오차는
별도 source 수리 범위로 남기며 이번 번역에 몰래 섞지 않는다.
대상키 밖 영어 폴백·다른 공유소비자·다른 해상도·자연진입은 미관측이다.
공개GO1·인간OPEN45·본편/새packageHOLD 유지.
native_reader/human_playtest/physical_controller_feel 미관측.
외부출시·스토어·지출·법률0.
