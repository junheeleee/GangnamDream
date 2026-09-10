# ORDER-228 — 중반 생활20종 번역 검토

> [x] 완료 — 507문구 수용·정확 C2 work_unit228 내부 GO. 본편 HOLD·실제 관찰 OPEN.

원문20종169문구/언어, 현재 기준 ab55c9a. 초기 수용36,076/b87에서 시작한다.
소유권·사실 안전선·검증은 아래에 원형 보존한 선언 사양을 따른다.

선언 검증 첫 실행은 신규 행0의 연속 순번 위반, 다음 실행은 사양 상태 머리말 누락을
발견했다. 기존75행을 유지한 순번 이동과 명시 상태 머리말로 수리했다. 구현 전 결함이다.

clean 선언 wrapper a491f66를 push했다. 첫 export는 기본limit80으로169선택을 거부했다.
파일·원문을 바꾸지 않고 명시limit169로 재시도한다. ROOT는 KO20 전체 객체를 직접 재독해했다.
초기 사양의 시간 역전 주체를 arc_night_routine으로 명확히 했고, 50만원×100=5천만원은
정상 산술이므로 원문 채무로 분류하지 않는다. 변경은 설명 정정이며 KO 수정0이다.

## 저작·독립 의미 검토

JA/CN/TW 각각20종169문구를 KO에서 직접 작성했다. 각 저자 최초 L1은
JA4leaf/6진단, CN15/18, TW18/23이며 원형을 git-private author/first-L1에 보존했다.
구조·LF252·{name}47/{assets}2/{job}1/{money}1과 기존31객체310문구는 보존했다.
Rawls→JA, Poincare→CN, Plato→TW 전량507 대조: 필수0, 선택 정밀화7 채택.
JA 시각을 청각으로 바꾼 웃음 표현·회고 시점2, CN 결합 자연성·추가 비판어조2,
TW 비교구문·친구 가치평가 어조3을 수리했다. 최종 2/2/3만 재독하고
나머지167/167/166와 원문169·raw prefix를 동일 묶음으로 다시 결속했다.
초기 CN patch2회는 전체 줄/순차 hunk 조건 불일치로 쓰기 없이 거부됐고,
실제 원문 줄 순서로 재생성한 patch만 적용됐다. 저자 원형은 덮지 않았다.

## 실제 검사 오탐과 수리

중국어16개 정확 KO source 지문 안에서만 수량·통화·고유명을 해석한다.
하루 빈도, 한 번의 비유·부정 경험, 한두 말/두 화면, 방/빈자리, 20·25·35억의
공유 원화 단위, 五千萬, KakaoBank/Mingi, Hyunsu의 실제 인용 발화가 대상이다.
특히 '비워 둘'의 둘은 숫자2가 아닌 두다의 활용이다. '둘 다'→兩者/兩個와
구별했다. 일반 이름 허용 목록·오류 필터를 완화하지 않았다.
JA는 같은 첫 수익 source2의 원화3개·화면8자리·완료100배를 먼저 확인하고
기존 숫자 비교에 정상화한다. 새로운 gameplay·답장·주거·생존 사실은 만들지 않는다.

코드 전 ROOT ZH113·JA17, Rawls 독립24와 JA 검사저자40을 봉인했다.
ZH ROOT 첫113은 정상8을 잘못 막았다. 두다/두 대상의 실제 위치와 중첩 패턴을
수리한 다음 같은113을 통과했다. Rawls24 첫 실행은 자연형2를 막아 유효
변조대조8/10만 성립했다. Plato의 정적 지적5·고정18을 더해 자연형 회귀,
미승인 Mingi 한자 별칭, 실제 TW 두 대상, 공유 표기를 수리했다.
최종 ZH155=ROOT113+Rawls24+Plato18, JA57=검사저자40+ROOT17 기대를 충족했다.
source-OFF는 새 국소 처리 OFF만 강제하고 기존 E2E 결과는 관찰값으로 분리한다.
기존243 self-test를 보존하고 고정212의 재구성·해시를 검증하는 메서드2를 추가했다.
추가 메서드2 최초 실행 PASS. 이 단계에는 전체 회귀/수용 검증 전이었으며,
아래 최종 결과에서 별도 실행과 지문을 결속했다.
ZH155의 첫 통합 실행은 fixture 전후만 봉인했다. 코드 SHA는 사후 측정이며
전후 봉인으로 과장하지 않는다. 후속 공식 QA에서 실행 코드 전후를 별도 결속한다.

본문 최종 raw: JA162728B/1ed79923365d2e3491204cab1fd351dca4ca27b32271d4b3e1a3d66274c805a9,
CN126292B/c72daf101cc9225f01c8fd9d4e169b8f9619809529abdd709958206be548e582,
TW127281B/c6b0d4b74aad637f895fca97974dc3e5ab8282ed54b6d318d0a5c27f7304f2cc.
본편 HOLD·native/render/human OPEN은 그대로다.

## 최종 교환·수용·회귀 결과

C1 `3017cff08fbfb5b8fe3037c7fc7aaf0cafd088df`의 clean 상태에서 최종 공식169
export/check/import를 각 언어에 수행했다. source169는 초기와 같고 이전 target
hash는 최종 본문과 같다. check/import 모두 leaves169·changed_files0이다.
제품 C2 `c6434252acc8a0ee697f40a5d9aa04d6f3e8ce05`, tree
`d923a903d973d5a2a7e8359e3a8109126067e29c`. C1→C2는 수용 원장·CLAUDE·backlog
3개 파일뿐이며 실제 번역·코드 지문은 검사 대상과 같다.

수용36,583(JA12,193/CN12,195/TW12,195), b88/meta9. 원장 raw
SHA8911d0f5da2c02b0db305e0718ea31e6d10c43e25111d891020be2f2d0615b4b,
accepted SHA ea7802b92180a24ae94a916bfb58d60dfd7f34ff0a425f9939f3d26fa35e25b0.
신규507 제거·batch1 제거·accepted hash 원복으로 이전36,076/b87/meta9 raw가 exact다.
첫 원장 patch 준비는 기존 key순서를 정렬해 역복원 assertion에서 쓰기 전에
막혔다. 기존 순서를 유지한 append만 적용했다.

전체 수용36,583 source/target hash 및 L1: ERROR0, 605입력 전후 exact,65.418초.
명시 overlay12: 모두 PASS,610입력(코드 포함) 전후 exact,61.08초.
full-body self52, full-localization self245(새2/고정212 포함), JA88,
ZH12407, 공개 self4·5locale14사건100leaf/UI121, audit ERROR0/WARNING0,
scope141/context/queue76를 확인했다. ZH font의 blocked는 self-test 진입 전
실제 설정의 정적 readiness 진단이다. skeleton 차선 PASS가 이 표시를 닫지는 않는다.
중국어 폰트/표시 소비자 후속 확인점으로 남기며 실제 화면 고장을 관찰한 것은 아니다.
Godot·전체 감사·240주·실제 디스플레이·원어민·사람 플레이는 실행하지 않았다.

고정212는 정상72/변조94/source-OFF46이다. ROOT ZH155 실행 당시 코드 전후
pin 부재는 사후 측정으로 분리했고, 후속 named lane이 같은 고정155를 포함한
self245와 실제 코드 전후 지문을 결속했다. 과거 실패 원형은 덮지 않았다.

### 핵심 private 증거

아래 경로는 `.git/full-game-localization/` 기준이며, 자동 검사와 사람 판정은 별도다.

| 파일 | bytes | SHA256 |
|---|---:|---|
| order228-ja-independent-final-l2.json | 6425 | 49b787776e9dc2eacc08eaab5c3940939a055c6ec0afe5e5d70f5aa858b9c37d |
| order228-cn-independent-l2-final.json | 13918 | f020659aed2cdd4feb87dd848c668fa93a03a18e21c2533c0000ea4aa8fd5de6 |
| order228-tw-independent-final-l2.json | 11215 | 64b674629f8e55d4a8f090bd82453fa08796b8a8164aece5c757d9b64b934e16 |
| order228-plato-zh-final-static-review.json | 14536 | b4d908d832b6a294e00850c6df61b5d7ccce6a576e07a3ef8f7583f469726122 |
| order228-self-registration-independent-static.json | 6371 | 891efbba82b15348c13f4e91cb249d3f1e7fcb3b3c2ac9f95016fd089ed52047 |
| order228-portable-acceptance-proof.json | 785 | c46734d2df8f60b6990831e5ad62d30c070fa4c31666eb10fd884872da78d1d6 |
| order228-all-accepted-l1-final.json | 73752 | a90bdfde73ecb65f4871857b8d250adf01c02b90468207c40c4f97d9a557200b |
| order228-named-qa-final.json | 139617 | e9ce61e0a2d3962b3de58356c04c85f560a0b5bd2ddca6e7c021a72f83664d20 |

이전 인간 원장103390B/SHA6ab5c927c9f327aa2892c231d49fe144c1c154cb6069fc539f4f3f8e9c30c9f6,
공개 M01–M06 BUILD2026.08.31.1 사용자 GO와 KO/EN·gameplay·project.godot은 보존했다.
이전 agent14 기록도 보존하며 신규 work_unit228만 별도 판정한다.
본편 HOLD, native_reader/human_playtest/physical_controller_feel 및 렌더 OPEN.
자동 게이트는 계약·회귀 증거이지 재미·깊이·문체나 인간 관찰의 증거가 아니다.

WORK 이관 실제값은39609→37824B다. ORDER138 본문1784B는 기존 history에 exact
append했고, 앞 구분 LF1B는 역복원에 별도 포함한다. 초기 계획37825B를 실제
계측으로 정정하며 원문 손실은 없다(order228-worklog-move-actual.json).

비보호 사건 잔여64종453문구/언어, UI·표시 소비자는 미완료다. 다음22종197문구는
ROOT·Rawls의 KO 원문/국소 소비자 사전조사만 완료했으며 번역 실적으로 세지 않는다.
과거 CI ab55c9a의 두 run을 한 번 읽었을 때 둘 다 in_progress였고, 이를 현재
후보 CI 성공으로 쓰지 않았다. 현재 후보의 원격 full CI 완료는 미관찰이다.

## 최종 내부 판정

Plato의 정확 C2 독립 검토: ORDER-228 한정 GO, 제품 필수0.
JA의 의미 판정은 저자 Plato가 아닌 Rawls의 전량169/최종2 결속에 의존한다.
CN은 Poincare, TW는 Plato의 비저자 전량/최종 결속이다.
최종 private 보고 order228-plato-c2-final.json24043B, SHA
edd7b565cc3b33bba20f44e7656ca1d5d8b7224806f3c415140fd99498610b3b.
640입력 전후 exact·보호1902 Git blob set 보존을 확인했다.
큐의 기존75행을 되돌리고 활성 사양은 아래에 손실 없이 보관한다.
후속 metadata wrapper는 제품·인간·정본을 바꾸지 않으며 STATUS는 clean 상태에서 생성한다.

## 선언 사양 원형

# Active Queue Spec: ORDER-228

#### [~] ORDER-228 [전체 현지화] 중반 생활20종 직접 번역

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

arc_night_routine의 새벽1시→자정→자정 전 역전, first-win의
아이스크림5천원/효과1만5천원, four-months ID/반년 제목, 연차와 dispatch 주차 차이는
번역에서 몰래 정정하지 않는다. 사별 first-win은 실제 발신·없는 번호 안내·발신 시각이며,
first-win의 50만원×100=5천만원은 정상 산술이므로 그대로 유지한다.
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
