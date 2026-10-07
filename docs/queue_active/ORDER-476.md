# ORDER-476 — 실제 보유 평가손실에만 첫 손실 장면을 연다

#### [~] ORDER-476 [위임 수리] 첫 투자 손실의 현재 보유 전제 — 2026-10-07

착수 — 선언 커밋·push 이후 아래 소유만 구현한다. 확인된 부채는
FULL_GAME_LOCALIZATION.md의 first-loss 보유자산 가드 부재다.
화면 잠금과 별개인 소스 수리이며 이미 완료한474/475를 반복하지 않는다.

## 한 판정 단위 / 깊이3문

- 지우면: 안내·숙련5만 있으면 미매수·전량매도·이익 저장에도 보유주식 손실과
  손절·추가매수를 단정한다. 현재 보유와 실제 가격을 확인해야 한다.
- 뒤의 독자: 기존 loss_cut/loss_hold/loss_doubled_down의 W36+ 회수가 실제
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
