# ORDER-548 — 정상 NG+ 새게임의 full owner 발급 수리

#### [x] ORDER-548 [P0·확인 입구 수리] 정상 반복런 표식과 fresh full 계약 정렬

**착수 — 2026-10-11.** 547에서 발견한 기존 NG+ 초기화 결함을 별도 단위로 수리한다.
root가 547의 실제 앱 종료·독립 final·메타데이터 기록을 마친 뒤 이 선언을 커밋·push해야
제품 저작을 시작한다. 기존 실패·보고를 덮지 않으며 이 사양을 547 구현 범위에 붙이지 않는다.

## 깊이 3문

1. 그대로 두면 첫 엔딩 이후 정상 New Story가 full owner를 받지 못한다. GameState가
   정상 NG+ 표식을 생산했는데 pristine 검사가 오염으로 거절하여 첫 회와 다음 회의
   제품 입구가 달라지고 whole 회귀의 terminal→date 연결도 실패한다.
2. 새 선택·보상·수치 차이를 만드는 일이 아니다. 반복런도 기존 full 달력·읽음 영수증
   소유 규칙을 따르게 하고 이미 존재하는 NG+ 표식·칭호 시작 보너스는 보존한다.
   24주 뒤의 새 경로·장면·능력치·스케줄을 발명하지 않는다.
3. fresh full 발급과 무표식 legacy 흐름의 경계다. 정상 새게임만 기존 owner를 받으며
   loaded legacy/손상 owner 자동 승격0·AP fallback 재해석0이다. 새 코어/프로필/cap0.

## 확인 근거

- 547 source a0bc2886의 기존 whole Manual은 actual exit1/204.866474s,
  ManualSaveCheck:1900의 date fresh initializer assertion 한 건으로 실패했다.
  `.git/order547-qa-20261011/regression-manual-01.json`과 세 원로그는 보존한다.
- ManualSaveCheck:119–120의 production→date 앞에서 실제 terminal이
  GameState.finish_run→MetaProgression.record_run으로 total_runs를 증가시킨다.
  production:2217–2223은 메타를 복구하지 않고 GameState만 새로 시작한다.
- GameState:1165–1169의 int(total_runs)>=1은 is_repeat_run=true, >=4는
  is_veteran_run=true도 만든다. StartMenu:2105–2119는 이 생산자 뒤 full을 발급하려
  하나 FullStoryFlow:503–514의 flags.is_empty가 정상 표식을 거부한다.
- Manual/FullStoryFlow/StartMenu는 4fe119a..a0bc2886 diff0이었다. 543/545의 기존
  PASS는 date/purchase 단독 차선이며 whole 선행 PASS가 아니다. 원 로그에 직접 flags
  dump는 없으므로 이를 런타임 직접 관측했다고 쓰지 않는다.

## 정확한 범위·소유

제품 변경은 아래 두 파일뿐이다.

| 소유자 | 파일 | 허용 변경 |
|---|---|---|
| root | systems/FullStoryFlow.gd | full fresh flags 검증만 정상 NG+ 생산자 조합으로 정렬. 나머지 pristine·저장·owner/schema·cap·scheduler 불변 |
| phone_cn_author | tools/ManualSaveCheck.gd | 기존 실제 StartMenu/slot/v4/backup/finish를 재사용한 표적 회귀와 whole 연결. 기존 assertion·marker·fixture는 삭제/완화0 |

cjk_wrap_diagnosis는 이 선언의 docs/queue_active/ORDER-548.md,
docs/CODEX_QUEUE.md, docs/CODEX_QUEUE_L3_PENDING.md만 소유한다.
root가 선언을 검토·적용·커밋하며 제품 파일을 author와 동시에 편집하지 않는다.
phone_independent_review는 비저자로 실제 diff/raw·보호 증거를 읽고 신규 독립 보고만 쓴다.

추가 기록 범위:

- root: CLAUDE.md 현재행, docs/WORK_LOG.md, docs/history/WORK_LOG_2026-10-11_pre_order548.md.
  현재 WORK_LOG가 40000B 한계에 가까우므로 복사 직전의 원문 전량을 위 정확한 history
  경로에 byteexact 보관하고, 현재 파일에는 archive 링크와 짧은 최신 기록만 둔다.
  원문을 압축/재집필/유실하지 않으며 원문 SHA/바이트 결속을 기록한다.
- root: docs/agent_review_decisions.json의 이번 source work_unit 판정 append,
  이 사양 마감/queue_archive/ORDER-548.md와 두 큐 상태, 신규 private QA 원자료/일회성
  격리 기록만. 기존 판정·raw·보고를 덮지 않는다. commit/push는 root만 한다.
- 비저자: docs/agent_reviews/ORDER-548.json 및 필요 시
  docs/agent_reviews/ORDER-548-manifest.json의 이번 실제 evidence 결속만.
- 큐 예산 이동은 기존 실행 순서·81행의 제목/상태/링크/gate를 보존하고 순번+1 및
  새548행만 허용한다. primary의 완료 검토 안내 한 문장만 원문그대로 L3 인덱스 앞
  안내영역으로 옮긴다. 158행은 원위치이며 기계 parser·등록·예산값·gate 변경0이다.

StartMenu/GameState/MetaProgression/SaveManager는 읽기 근거일 뿐 수정0이다.
게임 원문·EN/JA/zh·자산·project.godot/presets·공개 데모/pin·사용자 저장/설정·
과거 Human 판정/보고/raw는 불변이다. 엔딩 선택/finish_run 라우팅·경제 밴드도 불변이다.

## 최소 구현 계약

- full initializer에서만 정상 NG+ flags를 허용한다. preview8/12의 기존 empty-flags
  pristine는 유지한다. 공용 _pristine_start의 무조건적인 완화는 금지한다.
- 기존 생산자와 같은 int(MetaProgression.data.get("total_runs",0)) 해석으로 예상 키를
  정한다: <1은 {}, 1–3은 {is_repeat_run:true}, >=4는
  {is_repeat_run:true,is_veteran_run:true}. 새 메타 숫자 정규화 규칙0.
- raw bool true만 허용한다. false/숫자/문자열/null/컨테이너의 truthy 변환0.
  예상 키 누락·추가 키·횟수와 다른 조합은 거절하며 flags를 실제 삭제/재작성하지 않는다.
- 성공은 기존 owner 키 추가뿐이다. 날짜/나이/turn·game_over·events_seen/event_log·
  직업/월수입·pending story/commitment·weekly commitment/action 기록·returning 등
  나머지 기존 pristine 조건은 그대로다. 칭호 보너스 돈/능력치·시작 action_log도 보존한다.
- owns_session 선행 처리·손상 owner fail-closed·정상 중복의 무변경을 유지한다.
  total_runs 대조는 fresh 발급에만 두며 valid_session/v4 load에 추가하지 않는다.
  다른 런으로 메타가 늘어도 이미 저장된 full 슬롯은 자기 영수증대로 재개한다.
- 표식의 기존 easter_eggs 조건 독자와 v4 flags 저장을 보존한다. 표식 삭제/false
  정규화·검사에서 terminal 메타 지우기·marker 제거로 실패를 숨기지 않는다.

## 기존 도구의 표적 검증

모든 실행은 root/비저자 입구 보호 뒤 proven pre-autoload bootstrap·fresh HOME/XDG·
고유 namespace를 재사용한다. late override/실사용 user:// 실행0이다.
synthetic 메타/상태와 실제 제품 메서드 호출이며 native 입력·인간 플레이·자연 240주·
새 OS 프로세스 cold 증거가 아니다.

1. total_runs 0/1/3/4를 명시 준비하고 기존 _production_fresh_start의 실제 StartMenu
   _initialize_new_run_state(false)를 호출한다. 정확 NG+ 표식+PROFILE_FULL+valid_session+
   W1 미완을 확인한다. 4회 표본에는 기존 실제 칭호 보너스·action_log도 보존 확인한다.
   RNG 무변경은 owner 발급/중복/거절에만 요구하며 시장 초기화가 있는 새게임 전체에
   요구하지 않는다. 성공 owner 발급 전후 다른 생산자 상태는 불변이다.
2. repeat/veteran 각각 false·int/float1·"true"·null·배열/사전, veteran 단독,
   횟수와 다른 true 조합, 필요한 키 누락, unknown flag true/false를 전수 거절한다.
   정상 NG+에 기존 pristine 오염을 한 요소씩 더해도 false+전체 상태/RNG 불변이다.
   손상 owner는 그대로 보존하며 재발급하지 않는다.
3. 실제 StartMenu가 생산한 repeat/veteran owner를 기존 slot에 save_game→load_game하고
   새 Main에서 profile/영수증/표식/다른 상태를 확인한다. 메타 횟수를 더 높인 뒤 같은
   슬롯을 로드/중복 초기화해도 유효하고 무변경이어야 한다. JSON 숫자는 기존 exact
   저장표현 helper만 쓰며 flag bool·본문·영수증은 exact로 둔다.
4. owner 없는 repeat legacy 저장의 로드+새 Main 자동 등록0. 기존 유효 preview8/12
   저장의 cap/비승격은 그대로다. 새 preview의 NG+ flags 허용 확대0. demo/V2 별도
   격리 프로세스에서 full 발급0·state 불변을 확인한다.
5. Manual의 기존 backup 다음에 작은 --full-story-ngplus-only 분기·표적 함수·기존
   _finish를 재사용할 수 있다. whole에서는 기존 production→date→purchase 뒤 새 함수를
   호출하여 원 terminal carryover를 그대로 검증한다. 표적 함수는 로컬 GameState/
   EventManager/loaded-context/locale/MetaProgression.data/_new_this_run를 정확 복원한다.
   중간에 전역 _restore_meta_progression으로 최종 backup을 소진하거나 terminal carryover를
   숨기지 않는다. 기존 최종 _finish/_exit_tree 보호·복구는 그대로다.
6. 수리 뒤 기존 whole Manual을 한 번 실행하여 terminal→date→purchase와 나머지 기존
   assertion을 그대로 확인한다. 새 영구 runner/profile/검사등록/최적화0.
   exact 새 marker/명령은 저작 뒤 root/비저자가 소스에서 확정한다.

컴파일·선택된 영향 정적 검사·보호/diff 확인만 더한다. 전체 audit·자연 240주 반복0.
547의 의도된 fault injection/음성 ERROR와 유일 최종 FAIL 원자료를 보존하며,
새 실행도 정확 callsite/개수로 예상 거절과 예기치 않은 parse/script/engine 오류를 구분한다.

## 완료·판정 경계

- exact marker+actual exit+stdout/stderr/Godot 로그·독립 전수 source/raw 검수에서 새
  실패0을 확인하기 전 [x]로 닫지 않는다. 실패/미관측은 HOLD/REWORK 그대로 남긴다.
- 정상 NG+ fresh 입구·거절·v4/legacy/preview/demo/V2 보존에만 source commit/tree와
  이번 work_unit 판정을 결속한다. 다른 작품·품질·package 판정을 대신하지 않는다.
- 547/546/544 과거 보고·판정을 소급 바꾸지 않는다. 현 본편/출시 HOLD,
  인간/원어민/물리패드 미관측 유지. 자동 계약은 재미·깊이·문체의 증거가 아니다.
- 외부 출시/스토어/지출/법률 인증0. 새 정본 규범0이며 이 실행 지시는 일회성이다.

## 완료 결과 — 2026-10-11

- [독립 최종 보고](../agent_reviews/ORDER-548.json): 이번 source work_unit만 GO,
  본편/출시 HOLD. 최종 판정 source는 a2d4788b694b32b74fddc064305b7f606a21f41c/
  tree afbe37336dfc9e157ad4b7518fc0110ffd2fe4f8이다. 실제 최종 실행 source는
  2d7591528098732131cc530b551b43bcb2ff496a/tree
  356a6e02f8114eeb321d1bd3bf38057aa6fbc76e이며, 뒤 source 결속은 CLAUDE/WORK_LOG
  결과 기록만 추가한 것으로 제품/fixture/raw 불변이다.
- full fresh에서만 기존 total_runs의 <1/1–3/>=4 조합과 raw bool true를 수용한다.
  정상 StartMenu의 -1/0/1/3/4회·칭호 보상, owner만 추가/중복 무변경,
  57거절, repeat/veteran v4→새 Main·저장 뒤 메타 증가, legacy 미승격을 확인했다.
  fresh 전체 flags strict와 loaded 두 NG 표식의 presence/raw bool/value를 구분하며,
  다른 loaded flags/경제/이력은 기존 전체 cold state exact가 보호한다.
  기대 owner 한 곳만 기존 JSON 저장표현 helper를 거치고 실제 postload 직접 비교는 유지한다.
- 최종7차선/21stream: compile69 actual0/4.536s, NG+ full 표적
  actual0/6.623546s, demo/V2/preview8/preview12 제외 각각 actual0이다.
  이 여섯 차선은 정확 marker1/stderr0/strict wrapper PASS다.
  whole은 actual0/215.92721s/최종 exact marker1/assertion 실패0이며
  production/date/purchase/NG+ marker도 각각1이다.
- whole strict wrapper는 ValueError(error in manual-whole-04 stderr)/exit1/FAIL 그대로다.
  의도 ERROR10(손상 activity4+손상 empty owner2+잘못된 terminal ID4)과 WARNING25는
  이전547의 실제 호출 경로·개수와 동일하다. stderr/Godot 거울을 중복 합산하지 않는다.
  원547의 date fresh initializer FAIL은 사라졌으나 strict whole PASS·전체 CI 녹색이나
  zero-error/zero-warning 판정으로 바꾸지 않는다.
- 초기 표적3회 actual1/marker0(각 assertion3/3/2), 잘못된 self-test 호출 exit2,
  이전547 whole actual1 및 옛547 HOLD를 원형 보존한다. 영향 정적6차선은 ccd3 후보의
  결과이며 후속 fixture 수정에 소급하지 않는다. 최종 compile/표적/whole이 수정분을 검증했다.
  원자료는 `.git/order548-qa-20261011/`와 기존547 디렉터리에 그대로 둔다.
- 비저자 최종 보호99그룹/1795파일·기존290판정/Human·공개/player/seed/547 원자료
  보존을 결속했다. native 입력·변경 화면·자연 반복240주·새 OS cold·인간/원어민/
  물리패드 관측은0이며 자동 계약은 재미·깊이·문체의 증거가 아니다.
- 마감은548만 [x]로 보관한다. 다른81큐행은 순번−1 외 제목/상태/링크/gate 불변이며
  특히547의 `화면 GO · NG+ 회귀 HOLD`를 소급 변경하지 않는다.
  정본 승격: 새 규범 없음. 이 단위의 구현·검수·격리·마감 지시는 일회성이다.
