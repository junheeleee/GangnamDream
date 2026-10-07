# ORDER-476 — 실제 보유 평가손실에만 첫 손실 장면을 연다

#### [x] ORDER-476 [위임 수리] 첫 투자 손실의 현재 보유 전제 — 2026-10-07

착수 — 선언 커밋·push 이후 아래 소유만 구현한다. 확인된 부채는
FULL_GAME_LOCALIZATION.md의 first-loss 보유자산 가드 부재다.
화면 잠금과 별개인 소스 수리이며 이미 완료한474/475를 반복하지 않는다.

## 한 판정 단위 / 깊이3문

- 지우면: 안내·숙련5만 있으면 미매수·전량매도·이익 저장에도 보유주식 손실과
  손절·추가매수를 단정한다. 현재 보유와 실제 가격을 확인해야 한다.
- 뒤의 독자: 기존 cut_loss_first/held_through_loss/averaged_down의 W36+ 회수가 실제
  손실 장면 선택 뒤에만 생긴다. 새 거래·회수·플래그는 만들지 않는다.
- 경쟁: 첫 월급 다리의 기존 우선순위는 유지한다. W15~18에 손실이 없으면
  다음 기존 후보로 진행하고 seen·선택·현금·보유를 소비하지 않는다.

등록 자산의 Dictionary 보유 중 quantity/avg_price/명시 market_prices가
int 또는 float이며 유한·양수이고 현재 가격 < 평균 원가인 항목 하나 이상이면
true다. 다른 종목 이익과 상계하지 않는다. bool/문자열/없는 가격/미등록 종목/
0·음수·NaN·Inf는 false다. 투자 경험 플래그·숙련·순자산·초기 가격 폴백은
손실 증거가 아니다. W15~18·안내·숙련5·미독해는 보존하고 실제 진입 때 다시 읽는다.
InvestmentSystem.buy_asset가 quantity/avg_price를 생산하고 Main 보유 표가 같은
현재가격/원가를 읽는다. helper는 초기화·매매·월갱신·RNG·저장을 호출하지 않는다.

기존 선택의 cash 효과는 실제 종목 거래가 아니며 선택1의3일 회복 단정도 남은
원문 부채다. 이 오더가 반쪽 매매를 완성하거나 전체 투자 장면을 GO하지 않는다.

## 정확 파일 소유

- root 제품: scenes/MainGame.gd 숙련 조건 동일 한 줄의 helper 호출 + UI없는
  EOF pure helper만. 기존 UI-call line·payload·그밖 raw 불변.
- root 준비 회귀: tools/arc_flow_sim.py의 portfolio/market_prices/predicate 연결,
  A/B W15 등록 보유 손실 준비. 기존240주 기대·경쟁·예외 처리를 완화하지 않는다.
  tools/ScreenshotQA.gd의 옛 무조건 W15 기대만 조건부 W15~18 노출로 정렬한다.
  실제입력 경로에 가짜 보유를 주입하거나 prepared 증거로 재분류하지 않는다.
- root 새 런타임: tools/InvestmentLossGateCheck.gd/.tscn,
  tools/audit_scope.json 등록/전용 차선.
  tools/investment_ap_copy_self_test.py는 새 JA appendix 역상 한 단계만 연결한다.
- order469_history: tools/order469_source_compat.py/_self_test.py,
  tools/pr31_intake_history.py/_self_test.py. 실제 Main-only direct-parent 전이와
  현재 Git/disk를 먼저 증명하고 역사 비교만 exact 역투영한다. 옛469~475
  raw·끝점·영수증·470 helper 불변. actual payload를 old raw로 반환하지 않는다.
- order469_review: tools/ja_translation_pipeline.py 새 sealed476 appendix만.
  옛469/470 seal·핀 불변; pre476에서 기존 total-line -8을 검사하고 실제 현재
  전체 UI-call tuple/좌표 불변을 별도 증명한다. 새
  tools/investment_loss_gate_audit.py/_self_test.py를 소유한다.
- 비저자 order469_main: docs/agent_reviews/ORDER-476.json만 최종 후보·실제 증거
  전수검수 뒤 작성한다. 저작·프로젝트QA·엔진·커밋은 하지 않는다.
- root 운영: CLAUDE.md 현재, docs/CODEX_QUEUE.md, docs/CODEX_QUEUE_L3_PENDING.md
  순번만, 이 사양/queue_archive/ORDER-476.md, docs/WORK_LOG.md,
  생성 docs/STATUS.md, docs/agent_review_decisions.json.

콘텐츠5언어/번역원장/등급 inventory·story map/spine/rules·GameState·
InvestmentSystem·project.godot·사용자 저장/seed·공개manifest·과거human/agent판정 변경0.
텍스트 변경0이므로 새 번역 영수증0. source-only 역사 census 비교만 변경한다.

## 검증 / 마감

1. exact Main 전이·현재 전체census/Git/disk·UI call/좌표·비소유 raw 불변.
   Main locale14/13와 JA 정확 -8줄 역사 경계를 재분류하지 않는다.
2. fresh UUID pre-autoload namespace에서 실제 Main helper/_next_arc_id를 호출한다.
   빈·sold·0·손익0·이익·잘못된 보유/가격·소수손실·혼합보유와 W14/15/18/19·
   안내/숙련/seen·월급 경쟁·가격 재평가·preview 불변·후속 callback 조건을 전수한다.
   singleton 복원·보호source/사용자저장·engine SHA·로그/exit/marker를 남긴다.
   준비 상태 연결이지 화면·자연플레이·매매 조작 증거가 아니다.
3. 원본 arc_flow_sim.py를 trigger 변경 때문에 한 번 실행한다. 기대 삭제·
   항상true proxy0. 동일 검사를 이유없이 반복하지 않는다.
4. predicate/전이 반례, 원본 en_coverage·english_hangul·JA_UI·JA_DEMO_PIPELINE·
   ZH_DEMO_*·DEMO_I18N·narrative_continuity·scene_audio_contract·speech_register,
   release_inventory·context_manifest·queue_consistency·audit_select 표적 차선을 실행한다.
   입력 재사용은 실제 SHA/모집단 경계를 남기며 새 미해결 실패0이어야 한다.
5. L2 경로/생산자↔독자/상태/포기비용/위치/계층/닫힘 전 칸과 비저자 한정 판정
   뒤 main 마감. 실제 화면/자연플레이/원어민/물리패드·본편 출시 HOLD를 보존한다.

규범 승격: 새 규범0. 현재 사실을 발명하지 않는 기존 정본을 적용한다.
exact 전이·검수 모집단·지원 adapter는 이 오더 일회성이다.


## 2026-10-07 마감 — 현재 보유 평가손실 진입 한정 GO

마감 문서 이동 뒤 private metadata1은 미stage 삭제경로를 snapshot하려다 준비
실패했다(원본 CLI 실행0). 정확 소유 문서만 stage하여 이동을 실제 index에 맞춘
뒤 fresh metadata2로 검사한다. 제품/원본 검사 기대를 완화하거나 이전 실패를
PASS로 재분류하지 않는다. 다음 별도477은 선언만이며 이 GO의 제품 범위가 아니다.

- source-only `54bda08d1c0ec1472b3cf1805703f84e1f533428` / direct parent
  `53b885d66af93532b5c5a3117795be16cbe7e288`: Main의 숙련 조건 한 줄에
  현재 보유 손실 검사와 UI없는 EOF helper만 추가했다. final source candidate
  `312433f8f9caf9b05fe71f9e71bc957800c64b18` / tree `aceebcfc6724800ac26d5186bcd8db5ae66df389`.
  비저자 [ORDER-476 보고](../agent_reviews/ORDER-476.json) SHA `f763d7aeb4d0535250addb0a96ebe751875f41bf335376f6273daf864645faec`.
  이 ingress 수리만 GO이며 전체 투자 장면·실제 입력·렌더·자연 플레이·출시 GO가 아니다.
- 등록된 종목의 실제 양수·유한 수량/원가/명시 현재가격을 읽어 종목별 평가손실을
  확인한다. 미매수·전량매도·손익0·이익·없는 가격·잘못된 숫자는 진입하지 않는다.
  mixed 보유는 타종목 이익과 상계하지 않으며 가격·보유를 매번 다시 읽는다.
  경험 flag/숙련·초기가격·순자산은 손실 증거로 쓰지 않는다. helper의 거래·RNG·
  월갱신·저장·상태 변경0, 기존 W15~18·안내·숙련5·seen·우선순위는 보존한다.
- Main actual SHA `c04f986d7fca16fa1e1023dc90801af373398ce4e94b3baca35ee19e2350bff1`;
  전체 실제 UI-call tuple/line은 기존과 동일하다. JA의 역사 total-line -8은
  pre476에서 그대로 검사하고 현재 EOF 추가는 새 sealed appendix로 분리했다.
  새 실제census `defc3ee5e602220868859f88820fc023a24fc4750f54694d5333f0fef1dc0996`의 typed Git/disk를
  먼저 검증한 뒤 역사 비교만 pre476 census
  `90d88b6fe55939264625f49a36bfdc8ff7d10f93c7cd53b85a394f20f911cc05`로 역투영한다.
  기존469~475 seal·raw·끝점·14/13 반환·영수증은 불변이고 actual payload는 현재다.
  제품5언어/번역 ledger/등급 inventory·공개 pin 변경0/새 번역 영수증0이다.

### L2 — 한 진입 전제, 전 칸

| 단위 | 도달 경로 | 생산자 ↔ 독자 | 바꾸는 상태 | 포기 시 잃는 것 | 서사 위치 | 장면 계층 | 닫는 것 |
|---|---|---|---|---|---|---|---|
| arc_invest_first_loss ingress | W15~18·안내·숙련5·미독해+현재 보유 평가손실; prepared route90/competition30/live15/producer20 | InvestmentSystem.buy_asset의 quantity/avg_price + 실제 market_prices ↔ Main._has_current_investment_loss/_next_arc_id; callback_events_45의 cut_loss_first/held_through_loss/averaged_down 독자 | guard 자체0; false면 seen/cash/portfolio/quote/기억을 소비하지 않는다. 기존 선택0 cash−100000/mental+3/skill+2; 선택1 cash0/mental−3/skill+3; 선택2 cash−200000/mental−2/skill+1·세 기억flag/seen 보존 | 기존 세 선택의 서로 다른 기억; 실제 apply_choice 생산 뒤 W35/36 조건 읽기60(적격15·거절45, 자연 발화 아님) | 1장 Main 직접 아크; W15~18/M04~05; story_map/spine 명시항목 없음 | T3(미선언 기본); 기존 상태변경/매매서사 부채 유지·승격0 | 허위 손실 진입만 차단; 기존 seen 재진입차단·새 선택/플래그0 |

### 실제 검증

- runtime1 result SHA `389bd1ea2d3af341be0ad81b7b7d071c743d3e2d149e6253af39d4e6053c42ea`; actual engine/wrapper0,
  5.315015초. fresh UUID pre-autoload namespace `GangnamDream_StoryNameplateQA_fdf8a6e489a8483e970ce3e41056eadd`에서
  실제 Main helper/selector·InvestmentSystem buy/부분sell/전량sell·GameState.apply_choice와
  callback 조건 reader를 실행했다. loaded5/helper210/route90/competition30/live15/
  producer20/callback60=430 고유 ID 전수 PASS, locale별86·복원true이다.
  stdout=Godot SHA `98d5a523eeaaebbddc7feed42b4aa7a32b254519d08ae65585426edb914e1a34` / 83256bytes;
  stderr0/engine 오류0, 외부Godot SHA `e6b5cfdc226ffb7ec4f4950b0b12ddba4f040624724cff1acce9ae1241cf0034` 전후동일.
  전체3216 tracked·보호11그룹·source/runner/로그 전후불변이다.
  producer는 실제 API를 준비 상태에서 호출했고 callback은 W15 선택 생산 뒤 W35/36
  조건 읽기다. UI 키보드/버튼·자연240주·콜백 자연 발화·실제렌더 증거가 아니다.
- checks1 result SHA `1e5ae0eee9e4ebd0151e97e219144e558b67d73a3bc296f27e8e2ef059d68f1f`; 3723.935388초.
  한 실제 전체collect 17505잎 뒤 fresh4 proof context의
  원본 API로 새 소스56/PR31 31 반례를 검증했다. 기존 전체 selftest 재실행이나
  collector/판정 함수 대체0. 같은 frozen source에 원본18 CLI+차선 목록1 실제exit0/
  stderr0이며 fresh context 정상 종료 후 전체source/runner/log 보존을 확인했다.
  실제 arc_flow_sim240주 원본은 trigger 영향 때문에 한 번 실행했고 기대값 삭제나
  always-true proxy0이다. 차선 목록은 실행된 검사로 재분류하지 않는다.
  신규 미해결 실패0. 화면 반복/옛 전체사례 반복/전체감사 재실행0.
  원본 검사별 실제 소요는 JA_UI 663.896초·ZH_DEMO 787.332초·AP 소비자
  774.855초였다. 후속 결과문5잎 수리는 Main/UI/guard를 바꾸지 않으므로 이
  큰 UI/guard 검사를 관성적으로 반복하지 않고 실제 변경 입력의 표적 검수를 고른다.
  두 실제 실행은 clean a03f0bc/tree b81742c에서 이루어졌고 최종후보에서는
  CLAUDE의 최근완료/갱신 두 현재상태 행만 달라졌다. input-reuse1.json SHA
  `38ab5289f739eb4d71507c44d1a1d41c9a98a19df5ca8a8f8b22c33c206808fb`로 나머지3215 tracked·제품/소비자/fixture/
  검증코드/정본·외부engine·원로그 동일성을 재결속했다. 과거 실제 실행을
  최종후보의 새 실행으로 재분류하지 않는다.

| 원본 CLI/차선 목록 | 실제 exit | stdout SHA256 | stderr SHA256 |
|---|---:|---|---|
| held_loss_audit | 0 | `e17e425a90b12ed131572a232f4d65604b6ef2e16eab35581df9f798bd27209d` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| held_loss_negatives | 0 | `5992b670d7564c5a0bca84c9fc7c7d506439bfd07a8479cb1ae5bb68927f78b3` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| arc_flow | 0 | `9ca2c90cb8afdb56b12a4574c16ba6591d54d817d86f01d04b614a6214b61f7a` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| ja_ui | 0 | `334472e339e88c0dc5dac2aa0be9b1af2dad0ba891a4d87407f17d1ccbd1c5b5` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| ja_demo_pipeline | 0 | `f34a0e8c3d1974e855c65b7465c28de7d6c039f15a915621a01f0dabd0bd72df` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| ja_demo | 0 | `6ed04c74866309324c16c5af50b5382800bf0e9d92bf60f41c6801c6d9c45e1b` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| zh_demo | 0 | `36b55e5f467f1ab01ed5b5e03af8027f8a72727e0bd2b11bdc6c531f863b33c0` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| ap_copy_consumer | 0 | `99b78fadade898358e074ecbf06ffa934bf3891d17fbe83e94104faca09b5bda` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| en_coverage | 0 | `3c8fb0fe51e73967455b28149d28977ee7a44a9ff3891baae9a938f89d81451b` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| english_hangul | 0 | `15ad7fcf86b374cacd08c98110654b04febf4b65210231e6a7b7fb237abe6c44` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| narrative_continuity | 0 | `50fb37b91b7b1ad1fb7d25f2c7d2fffe1921a944de98518c20333b01d3949f26` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| scene_audio_contract | 0 | `b629eaab373ccfbd504686997f7cb04b8ebdc484fe4328ec4a6e67432d6b9132` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| speech_register | 0 | `43952f3918dd5c4d1a8b1002dcec7dad706502315a57d115d67195724324dc11` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| release_inventory | 0 | `9bca145d3db7bb10745ec0c7deaa709ced89d47c09dbb8de9021c097de5ac516` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| demo_i18n | 0 | `a99e3d2981750a415a713bf9292c56abe2c65a0eab43dbe25b03c119c0c0dce8` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| context_manifest | 0 | `566d7b4d3ae529bb4dc10d1c31b0106e6fe8bdd82cca57dbdaa05fd84ae6b422` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| queue_consistency | 0 | `591b8736de73337ab8bda79d4bb66a995e451ffc6b5eaf1382e5a91625bb9d23` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| audit_scope_verify | 0 | `1442a1ca89fa4dde39e6d3b1147deeb786c87fa37c15a4043da722427c9f5810` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| declared_lane_plan | 0 | `0624d2ad78da0bee6e0747c662ec291ee811205cc9bf41b2a0bd740171fa885a` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |

### 보존·남은 위험

- legacy ScreenshotQA 입력은 _ap_invest를 제외하여 손실 보유를 생산하지 않는다.
  옛 무조건 W15 손실 기대만 optional15~18로 정렬했으며 가짜 보유 주입0.
  hyunsu_study_together W18 기대는 그대로이고 전체 legacy 실제입력 경로는 이번에
  실행하지 않았다. prepared430/시뮬레이터 결과로 그 기대를 새 PASS라 하지 않는다.
- 기존 첫손실 선택의 현금 -100000/-200000은 실제 종목 매매가 아니다. 선택1의
  3일 뒤 회복 단정도 원문 부채로 남는다. 이 전제 수리가 반쪽 거래를 완성·제거하거나
  전체 장면 계층·재미·깊이를 승인하지 않는다.
- human_gates SHA `6ab5c927c9f327aa2892c231d49fe144c1c154cb6069fc539f4f3f8e9c30c9f6`,
  공개GO1·인간OPEN45·과거 HOLD/REJECT·149 captureFAIL·473~475 한정GO를 보존한다.
  project.godot·사용자 저장/seed·공개manifest·과거 판정 변경0이다.
- gangnamdream-dev의 정확 소유·전이 분리·pre-autoload 격리·전수 독립검수·표적
  검증을 적용했다. 새규범0/기존 정본 적용이며 exact helper/adapter/검수 결속은
  일회성이다. 자동 게이트는 계약 증거이지 재미·깊이·문체의 증거가 아니다.
  실제 화면149/457/302·원어민·사람·물리패드·본편 출시 HOLD는 그대로다.
