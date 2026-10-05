# WORK_LOG.md — 강남드림 작업 기록

이전 원문 전체는 [시장 UI 번역 전 기록](history/WORK_LOG_2026-10-05_pre_order465.md)에 바이트 그대로 보존했다. Claude PR #31 기록은 [별도 보관본](history/WORK_LOG_2026-10-05_claude_pr31.md)에 있다.

## 2026-10-05 — 사용자 우선 PR31 문장 수리 들이기 선언 (468)

- 실제 통합4b26792(부모8a2c9a9/b9284e3), Main6 e88742c, 공식24영수증 db4de2f. 기존 main66신규 UI잎/6배치 보존, accepted41830/b240. arc_events5·project·과거 인간/공개/사용자 저장 불변.
- 기본 EN/EN한글18, JA_UI/JA pipeline, ZH기본/자체12623, inventory history82, 새source역상167 통과. 현재 PR변경 accepted687 전수 기계오류0. 초과월수/연수 오탐2종은 원문 분류만 좁혀 수리하고 비저자가 찾은 `不是` 누락을 포함한68사례 PASS. ZH전체 자체검사는 연수추가 전 증거이며 이후 변경은 새표적검사로 구분한다.
- `.git/pr31-intake-20261005.Kz8A4y/runtime2/result.json`: prepared 엔딩235/5언어·투자AP30/주복원5 PASS, 보호57/11그룹·제품697 전후동일. runtime1의10실패는 fixture가 생존+사망flag를 동시에 만든 기대값 오류였고 보존한다. 실제렌더/자연입력/원어민/인간 관찰이 아니다.
- 공식 CN/TW 검사에서 확인한2오탐의 실패출력은 보존했다. 원래 번역을 고치지 않고 공식check/import 각8 changed_files0. 서로 다른 consumer가 전체 현재 이력을 중복 읽지 않도록 한 호출 내 fresh proof를 공유해 최종검사한다. 별도시작한 content1 중 inventory82 PASS만 채택, graph/ch5 실행은 중단·미판정으로 기록한다.
- 최신 지시에 따라 B3/B4와 후처리3종을 먼저 진행한다. PR runbook은 로컬 미존재로 원격 브랜치에서 직접 읽었고, 최신 b9284e3의 추가분은 심의목록2지문 보정뿐이다.
- 진행 중467의 Main3쌍/도구4파일/새fixture2파일을 보존한다. 467 검수 미완료를 완료로 올리지 않으며 Main6줄의 새 역사 전이에 연결한다.
- 선언 후 EN_HANGUL 오탐부터 수리한다. arc_events.json·project.godot·공개/사용자 저장과 인간 판정은 불변, 7k/수첩·5년은 별도다.

## 2026-10-05 — 거래 결과 번역 검증 완료·AP 안내 후속 선언 (466 완료/467 착수)

- 실제 clean ae28a8b/tree3679f0의 tracked3146·보호57 전후동일. normal1 result `1f50a10cefca0a7eb187dc7799988a419bd7e1cbf6442553ac7f443f844a93d9`, delta `84d54fbaf7dd486174ed61c233206907123b0f18613660b8db3e1561aa39d167`; delta17.943166459초/ZH34.348521초/exit0/stderr0. 후속7b3bee3은CLAUDE3행만이며 두커밋 main push 완료.
- 실제464/465의 원문결과·로그·Git 객체와 전체계보를 결속했다. 두 제품commit의 실제parent→commit4raw를 각각32/16값·2/2batch로 검증했고 source213hash·두export census·기존226판정/보고·player/public/seed가 불변이다. 전체history/current365를 다시 실행한 것은 아니다.
- 비저자16값 전수 및 공식수용 한정GO([보고](agent_reviews/ORDER-466.json)). 실제toast·log잘림·렌더/원어민/물리입력·본편/출시HOLD. 기존 규범 적용, 새규범승격0·이번 proof는 일회성이다.
- 다음467은 확인된 AP부족 오안내3쌍을 기존 짧은 한영/다국어 문구로 통일한다. 게임규칙·사전·원장은 불변이다. 원문 변경에 필요한 exact collector/역사증명 지원과 별도 표적 회귀를 선언했으며 선언push 전 구현하지 않는다.

## 2026-10-05 — 투자 매수·매도 결과 중국어16값 수용 (466)

- 052d29d main 선언·push 뒤 한국어8키를 간체/번체 저자가 각각 직접 작성하고 비저자가16값 전수·실제 소비자를 읽었다. 기본실패/매수·매도 기록/행동완료/성공toast의 자산명→투입금 순서와 %s·✓·→를 보존했다. InvestmentSystem의 같은 기본실패·매도완료 키도 공유 소비자다.
- 공식check1 CN11.562068초/TW11.581151초·각8/exit0/stderr0, import 각8·기존4raw 역상 PASS. CN/TW1801→1809, 전체accepted41805→41821/b235→237. JA·한영원문·AP·거래규칙·저장·공개·기존원장 바이트는 불변이다.
- 실제464 전체이력 PASS와465 새추가분 증거를 재사용한다. 현재 clean후보의 두제품전이32/16값을 각각 검증하고 새ZH 기본1회로 결속하는 단계는 아직 미실행이다. current365/전체history·엔진·화면/원어민/물리입력은 NOT_RUN이다.
- 별도 발견: 비pending 일반매수/매도/레버리지의 AP0 안내가 '이번 달 거래 불가'로 과장된다. 실제 spend_ap는 현재AP만 검사하고 주가 바뀌면 같은 달에도 복원될 수 있다. 기존 다국어 '행동력이 없습니다' 재사용 수리를 다음 독립 범위로 준비하며 이번 수용에는 섞지 않는다.

## 2026-10-05 — 시장 번역의 기존 기준선과 새32값 검증 (465 완료)

- clean c3de816/tree3bd9c338의 tracked3144·보호57파일/HEAD/status 전후동일, result `de1fccb26eb47da078362f930a227dcaccd529a08f0855fb2dfab9b4936bdf04`. actual delta14.5050395초·ZH34.513431초/exit0·stderr0. 이후56bfed7은CLAUDE3행만변경했다.
- 실제464 PASS의 결과·로그SHA/3141경로·Git객체와 현재전체경로를 결속하고, 원문·검사코드·기존41773값/233batch·225판정을보존했다. 1개제품commit의전후4raw·32신규영수증·공식header/selection/nullprior·actualexportGit source census와freshcollect동일을증명했다. current365/전체history는NOT_RUN이며464실행을현재재실행으로세지않는다.
- 초기check1 FAIL·원초안을남기고각지역수량사한글자수정후32전량의미재검수/공식check2/import PASS. 제품16키×2지역만GO, 렌더/원어민/물리입력·범위 밖 남은 중국어·본편/출시HOLD. 근거[독립보고](agent_reviews/ORDER-465.json); 새규범승격0·이번증명은일회성배치조건이다.
- 다음466은일반투자결과8키×2지역만선언한다. 주변보유/은행/거래카드안내는기수용이며표본수를채우려고다른주제를묶지않는다. '이번 달 거래 불가'는시간축위험으로남기고이번번역에서제외한다.

## 2026-10-05 — 투자 시장 탭 중국어16키 착수 (465)

- 1a8ab27 main 선언·push 뒤 간체/번체 한국어 직접저작을 분리했다. 상태·경보·계좌·현재평가액·수익률·절대등락률 상위4·기록·보유평가액의32값만 추가한다. JA16사전존재·원문/게임규칙/저장/공개는 불변이다. JA공식accepted 여부와사전존재를구분한다.
- 공식 source/check2/import 각16·신규32수용/2batch·4raw역상 PASS로 수용41805/b235가 됐다. 최초check1은CN의 자연스러운 분류사 项를 숫자검사가 인식못해 실패했고TW는NOT_RUN이다. 원초안/response/실패로그를보존하고 저자·비저자가32전량을다시읽어 같은 뜻의 个/個만수정했다. 원문·검사코드변경0.
- 실제464 clean dd1c391의365 PASS를 재사용하되 이번 current365/전체history는 NOT_RUN으로 분리한다. 기존3141 경로집합/원문·도구·영수증과 새추가분 raw역상·actual Git source census를 결속하고 ZH 기본1회를 실행한다. 이 clean후보 검증은 다음 단계이며 아직 PASS로 세지 않는다.
- WORK_LOG 39,915byte 전체를 이동 보존해 이후 기록의 예산을 확보했다. 규칙완화/검사코드변경0, Mac잠금 중 화면·공포/탐욕 draw_string 글리프·입력·원어민은 미관찰이다.
