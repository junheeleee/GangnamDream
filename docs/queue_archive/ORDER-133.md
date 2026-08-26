# Archived Queue Spec: ORDER-133

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [x] ORDER-133 [P0·5장 인과] M49~M55의 계약·보호·보증·공동 결정을 실제 플레이로 잇는다

**[x] 완료 — 만진 파일:** `autoloads/GameState.gd`, `scenes/MainGame.gd`,
`scenes/StoryMode.gd`, `systems/Chapter5CausalRoute.gd`,
`content/meta/chapter5_causal_ledger.json`, KO/EN 사건·제품 라우팅·장면 계약,
M55 전용 CG·연출·오디오 매니페스트, 전용/공용 감사, 아래 정본·마감 문서.

**완료 판정 (2026-08-26):** 구현 `34e5a89`·보호 `8b7bc98`에서
19 roots·47 choices를 제품 경로로 동결했고, 후속 결말 구현 뒤 exact clean
`a5439549991109f6bdb8d1e86e4053d2f5dad1f2` / tree
`31c8749e1393b8f27c53c31d1f13d99856f7181f`에서 Chapter 1 478 변이와
전체 감사 `✅ 감사 통과`로 재검증했다. 장면 수·비트 수는 할당량이 아니며
각 원문·전달·검사·비교·결정·증거의 인과 기능으로만 유지한다. L2 화면
90장 묶음에 포함된 M49~M55 KO/EN 30장은 검은막·겹침·포커스 실패 0이다.
정상 속도 재미 판정 L3는 OPEN이며 플레이 준비 완료를 뜻하지 않는다.

**사용자 위임·착수 근거 (2026-08-26):** 사용자는 게임을 최종까지
완성하고 플레이할 때가 되면 알려 달라고 했다. 특히 초반부터
엔딩으로 갈수록 스토리와 게임성이 빽빽하고 격동적인지, 2년차
이후 선택지 구멍이 없는지 직접 판단해 진행하라고 위임했다.
ORDER-132 전수 감사에서 다음 제품 P0는 원고 분량이 아니라 M49~M55의
19개 장면이 `author_only`로 격리된 채 다음 장면이 이전 선택을 읽지
못하는 것으로 확정됐다. 정확히 19개인 이유는 숫자를 채우기 위해서가
아니라 기준 경로의 원문→전달→경계→검증→결정→증거 함수가 서로
다르기 때문이다. 각 장면의 패널·비트 수는 필요한 인과와 감정으로만
결정하며 10에 맞추지 않는다.

**착수 기준선:** `b0d659ec9fa74b8e78134851edf5664d71d249ff` / tree
`a103d53f3c3e32e68eee01503b4d36d1a8f2de65`의 exact clean 전체 감사
`CHAPTER1_CAUSAL_LEDGER_SELF_TEST_OK cases=476`과 `✅ 감사 통과`.

## 깊이 3문

1. **이 19단위를 열지 않으면 무엇이 깨지는가?** 오년차 산문은 있어도
   계약 원문, 다은 이름, 재혁 보증, 상철 검토, 네 사람의 동의가 제품
   경로에서 사라져 M56 이후의 서명이 저자가 만든 결론이 된다.
2. **본 플레이어와 보지 않은 플레이어의 상태가 24주 뒤에 다른가?** 각
   선택은 정확한 index·인물·문서·순서 receipt로 한 번만 남아 후속 장면의
   대사·가능성·비용이 달라진다. 부족하면 추론하지 않고 기존 안전
   fallback으로 닫힌다.
3. **같은 자리에서 무엇과 경쟁하는가?** 월간 행동판·참조용 career/startup
   경로·가중치 추첨과 경쟁한다. M49~M55에서는 story map의 정확한 주차와
   실제 선택 receipt만이 이기고, 하지 않은 행동을 플래그로 발명하지
   않는다.

## 배치 A — M49~M55 기준 경로 19단위·47선택

| # | 월/주 | 루트 | 선택 | 닫는 인과 |
|---:|---|---|---:|---|
| 1 | M49/W195 | `arc_y5_contract_cover_investment` | 3 | R3 원문·금액·다은 이름 |
| 2 | M49/W196 | `arc_y5_contract_reviewer_delivery_sangchul` | 3 | 상철에게 잘라 내지 않은 동일 원문 전달 |
| 3 | M50/W197 | `arc_y5_final_push_deadline_investment` | 3 | 마감 답변과 즉시 포기 비용 |
| 4 | M50/W200 | `arc_y5_protection_boundary_daeun` | 3 | 다은 이름 삭제·조달 상한 변화 |
| 5 | M51/W201 | `arc_y5_burnout_check_reference` | 3 | 진단 전 실제 검사 자료 |
| 6 | M51/W203 | `arc_y5_minseo_goal_cost_reference` | 3 | 돈·몸·사람 중 이미 낸 가격 |
| 7 | M51/W204 | `arc_y5_after_goal_daeun` | 3 | 목표 뒤에 먼저 비워 둘 시간 |
| 8 | M52/W207 | `arc_y5_final_offer` | 3 | 일곱 장 제안의 첫 행동 |
| 9 | M52/W208 | `arc_y5_final_offer_reference_delivery` | 1 | 상철·다은이 받은 같은 일곱 장 |
| 10 | M53/W209 | `arc_y5_jaehyuk_guarantee_request_reference` | 1 | 재혁 요청 원문·PDF·도착 시각 |
| 11 | M53/W210 | `arc_y5_jaehyuk_return_call_reference` | 3 | 재혁이 돌아온 이유의 한 질문 |
| 12 | M53/W210 | `arc_y5_jaehyuk_father_document_reference` | 1 | 통화 후 아버지 문서 비교본 |
| 13 | M53/W211 | `arc_y5_guarantee_protected_show_daeun` | 3 | 서명 전 다은에게 보여 준 순서 |
| 14 | M53/W212 | `arc_y5_jaehyuk_guarantee_decision_reference` | 3 | 거절·실제 서명·차단 중 한 결정 |
| 15 | M54/W215 | `arc_sangchul_final_door` | 3 | 제안자와 검토자가 같은 사람인 한계 |
| 16 | M54/W216 | `arc_y5_sangchul_review_receipt` | 1 | 15번 choice 0의 빨간 원·촬영 시각 |
| 17 | M55/W217 | `arc_y5_three_in_room` | 3 | 상철·재혁·다은·민준의 서로 다른 원문 |
| 18 | M55/W219 | `arc_y5_three_in_room_decision` | 3 | 이름 삭제·자필 동의·원 조건 재개 |
| 19 | M55/W220 | `arc_y5_room_consent_receipt` | 1 | 18번 choice 1의 자필 범위 원본 |

M51은 병원 검사표를 민서가 읽으므로 5→6 순서를 바꾸지 않는다.
M53은 통화 후에만 아버지 문서를 꺼내고, 다은에게 보여 준 후에만
보증을 결정한다. 16번은 15번 choice 0, 19번은 18번 choice 1에서만
열린다. 다른 선택에 없던 빨간 원이나 자필 동의를 생성하지 않는다.
이 세로줄은 투자형 정체성과 `route_invest`, 20억원 이상 자산 구간,
실제로 이어진 상철·다은·민서·재혁 관계가 모두 있는 런만 W195에서 연다.
W209~W212의 확장 보증 장면은 기존 `arc_jaehyuk_mirror`의 두 번째 부탁이
아니라 같은 한 번의 결정을 옮겨 깊게 만든 것이다. 세 결과는 기존
완료·거절/서명/차단 플래그와 정신·Moral Tint 비용까지 그대로 쓴다.

## 구현 계약

- 로케일 중립 `Chapter5CausalRoute` schema 1은 W195에서
  `investment_property` 경제 경로, 20억원 이상 진입 밴드, 실제 배우 역할을
  먼저 exact entry로 고정한 뒤 선택 index, 문서·비교·전달·검토·동의 receipt,
  순서를 저장한다. 번역문·AP·
  행동 카드·스탯·엔딩 결과는 저장하지 않는다.
- 진입 전에는 투자형 정체성·20억원·상철/다은/민서/재혁의 실제 선행 관계를
  모두 검사한다. entry가 한 번 저장된 뒤에는 가격이나 관계 플래그가 변해도
  이미 시작한 원문을 중간에 바꾸거나 다른 경제 경로로 갈아끼우지 않는다.
- R3의 7천만원은 HUD의 실시간 현금 잔액을 단정하는 수치가 아니라, 기존
  의무에 묶인 자금을 제외한 원문 조달표의 추가 확보 전제다. KO/EN 원고는
  둘을 명시적으로 구분하며 현재 잔액을 발명하지 않는다.
- 주차 ingress는 기준 경로의 정확한 선행 receipt에서만 열리고, 중복·
  역순·범위 밖 index·잘못된 인물/문서·손상 저장은 상태를 더 쓰지
  않고 기존 안전 fallback으로 닫힌다. 첫 성공 쓰기는 write-once·idempotent다.
- 각 장면은 story map 주차의 직접 전경을 소유한다. 이벤트 디렉터 메아리가
  같은 주차를 먼저 차지하지 않으며, 장면이 열린 주에 일반 AP 3택을 다시
  묻지 않는다.
- 19루트는 `author_only` 태그·lifecycle에서 빼되 무작위 사건으로 노출하지
  않기 위해 `weight=0`, `hidden=true`, `min_turn=9999`는 유지한다.
- 19단위는 장면 기능상 T2로 이관하고, 체인 중간 링크는 별도 tier를
  중복 선언하지 않는다. M55 네 사람 회의는 인물·문서·자리를 한눈에
  읽히는 전용 CG와 폴리·연출 계약을 갖추되, 숫자를 불리기 위한
  추가 링크는 만들지 않는다.
- 열린 career/startup Year 5 32루트·86선택은 `reference_only`, 제품
  consumer 0, kernel byte-exact를 유지한다. 공유 파일의 source hash만 승인된
  새 바이트로 재결합하고 참조 경로의 의미 digest는 바꾸지 않는다.
- M49~M55는 거래·이체·엔딩을 적용하지 않는다. 33세·1장 현재
  자산 30억의 `instant_legend`는 비밀 이스터에그로 byte·라우팅 불변이다.
  M56~M60의 추적·접수·증언·거래·마지막 서명은 다음 자식 오더다.

## 정확한 파일 소유권

**런타임·새 원장:** `autoloads/GameState.gd`, `scenes/MainGame.gd`,
`scenes/StoryMode.gd`, 신규 `systems/Chapter5CausalRoute.gd` 및 `.gd.uid`,
신규 `content/meta/chapter5_causal_ledger.json`.

**사건 KO/EN:** `content/events/arc_midgame.json`,
`content/events_en/arc_midgame.json`, `content/events/arc_new_characters.json`,
`content/events_en/arc_new_characters.json`, `content/events/arc_drama.json`,
`content/events_en/arc_drama.json`, `content/events/arc_pre_ending.json`,
`content/events_en/arc_pre_ending.json`.

**제품 라우팅·장면 계약:** `content/meta/event_lifecycle.json`,
`content/meta/event_director.json`, `content/meta/story_map.json`,
`content/meta/story_rules.json`, `content/meta/narrative_spine.json`,
`content/meta/release_content_inventory.json`, `assets/event_visual_contracts.json`,
`assets/scene_direction_manifest.json`, `assets/scene_audio_manifest.json`,
`autoloads/ImageRegistry.gd`, `assets/cg_acting_manifest.json`,
신규 `assets/CHAPTER5_MEETING_VISUAL_BIBLE.md`,
신규 `assets/cg/y5_three_in_room_v1.png` 및 `.import`,
`assets/ASSET_INDEX.md`, `docs/ART_AI_AUDIT.md`.

**정본·보호 계약:** `docs/STORY_BIBLE.md`,
`docs/CHOICE_CONSEQUENCE_SYSTEM.md`, `docs/SCENE_TIER.md`,
`docs/CONTENT_RATING_INVENTORY.md`, `docs/QA_CHECKLIST.md`,
`content/meta/year5_reference_routes.json`, `tools/year5_reference_route_audit.py`.
`systems/Year5ReferenceRouteKernel.gd`, `GameState.check_game_over()`의
`instant_legend` 분기, `project.godot`, 엔딩 JSON·라우팅은 byte 불변이다.

**검사:** 신규 `tools/chapter5_causal_route_audit.py`,
신규 `tools/Chapter5CausalRouteCheck.gd`, `.gd.uid`, `.tscn`,
`tools/arc_flow_sim.py`, `tools/event_director_audit.py`, `tools/event_lifecycle.py`,
`tools/story_map_audit.py`, `tools/narrative_spine_audit.py`,
`tools/full_run_pacing_audit.py`, `tools/ManualSaveCheck.gd`,
`tools/CoreChoiceSliceCheck.gd`, `tools/ScreenshotQA.gd`,
`tools/art_resolution_baseline.json`(신규 활성 CG 1개의 해상도 부채 재봉인),
`tools/chapter1_core_loop_v2_causal_ledger_check.py`, `tools/audit_scope.json`,
`tools/audit.sh`, `tools/narrative_continuity_audit.py`(투자 대표 경로가
실제 `route_invest` 정체성을 가지며 기존 W10 차트 장면을 카운트하게 된
감사 정확도 교정 1건), `tools/full_run_pacing_audit.py`(같은 정체성 교정으로
기존 W10 장면이 실측되면서 드러난 2시간 추정 오차 W94~95와 제품/비제품
런의 서로 다른 무작위 주차 계약을 분리).

**선언·마감:** `docs/CODEX_QUEUE.md`, 이 사양과 완료 시
`docs/queue_archive/ORDER-133.md`, `docs/queue_archive/CODEX_QUEUE_2026-08.md`,
`CLAUDE.md`, `docs/WORK_LOG.md`, 생성본 `docs/STATUS.md`.

위에 적지 않은 밸런스·세이브 schema·로케일·엔딩·`project.godot`은 수정하지
않는다. 검사가 추가 파생 파일의 재봉인을 요구하면 제품 계약을 느슨하게
하지 않고 이 사양에 정확한 이유를 추가한 뒤 같은 오더에서 갱신한다.

## 완료 증거

- **L1 기계:** exact 19루트·47선택·KO/EN 구조 패리티, 주차·순서·
  인물·문서 계약, write-once/idempotent, save/load 왕복, 손상·legacy
  fail-closed, 조건부 영수증 2개, 직접 주차 소유, `author_only -19`를
  전용 Python·Godot 검사로 입증한다.
- **L1 보호:** career/startup `32 roots / 86 choices / consumer 0 / reference_only`,
  `Year5ReferenceRouteKernel.gd` byte-exact, `EndingRouteIdentityCheck.gd`, Chapter 1
  476 self-test, 컨텍스트·큐·strict JSON·KO/EN·서사·말투·아트·CG acting·
  표적 감사와 `git diff --check`를 통과한다. 공용 스케줄러·GameState·StoryMode·
  연출/오디오/자산 레지스트리를 바꾸므로 구현 freeze 후 exact clean 전체 감사를
  한 번 실행한다.
- **L2 자가:** 19행 전수표에 도달 주차, 생산자↔독자, before→after,
  포기 시 잃는 후속, tier·장면 기능·파일:행을 남긴다. 실제 Godot KO/EN
  M49~M55 장면과 M55 전용 CG를 캡처해 검은막·HUD·자막·인물·문서·
  포커스를 눈으로 확인한다.
- **L3 사람:** 기계 GREEN은 재미 GO가 아니다. M49~M55를 정상 속도로
  플레이해 계약 문서가 인물 사이의 압박으로 읽히는지, M53·M55의 결정이
  실제 포기로 느껴지는지, 장면이 숫자 와다리로 느껴지지 않는지를 사용자가
  판정한다. 이 단계 전에는 플레이 준비 완료를 선언하지 않는다.

## L2 전수 증거

재미 판정이 아닌 실물 대조다. `#`은 배치 A root다. 근거 별칭은
`L=content/meta/chapter5_causal_ledger.json`, `M=content/events/arc_midgame.json`,
`N=content/events/arc_new_characters.json`, `P=content/events/arc_pre_ending.json`,
`D=content/events/arc_drama.json`, `G=autoloads/GameState.gd`,
`S=scenes/StoryMode.gd`, `R=systems/Chapter5CausalRoute.gd`의 `파일:행`이다.
entry/commit/choice-index 독자는 `G:266/303`, `S:3657`; L3는 별도다.

|#|W|producer→reader|before→after|포기·비용|물성|근거|
|---:|---:|---|---|---|---|---|
|1|195|entry→#1|∅→R3 초점 0/1/2|다른 초점 2|금액·예외·빈 이름|L:27 M:3810 G:266|
|2|196|#1→#2|미전달→전체본+첫줄|다른 첫줄 2|R3 전달본|L:45 M:3863 S:3657|
|3|197|#2→#3|무응답→연장/자정/거절|시간·조건·수수료|R3 답변|L:63 M:3912 S:3657|
|4|200|#3→#4|경계 없음→상한/시각/밤|다른 설명 2|R3/R4 이름·시간|L:81 M:3961 S:3657|
|5|201|#4→#5|증거 없음→수면/떨림/노동|다른 자료 2|진료 사본|L:99 N:282 S:3657|
|6|203|#5→#6|비용 무명→몸/사람/돈|다른 비용 2|진료·R4·R3|L:117 N:233 S:3657|
|7|204|#6→#7|빈 시간 없음→저녁/일요일/정지|다른 보호 2|비용 냅킨|L:135 N:331 S:3657|
|8|207|#7→#8|무대응→검토/재가격/선열람|다른 첫 행동 2|7장+조건부 아버지 스캔|L:153 P:142 S:3657|
|9|208|#8→#9|동일본 없음→두 사람 전달|판본 비대칭 포기|같은 7장 두 벌|L:171 P:577 S:3657|
|10|209|#9→#10|구두 부탁→PDF+도착시각|비공식성|재혁 PDF|L:187 D:1817 S:3657|
|11|210|#10→#11|답 초점 없음→관계/범위/이유|다른 질문 2|PDF 이름·총액·책임|L:203 D:1844 S:3657|
|12|210|#11→#12|두 보증 혼합→분리 비교|한 이야기로 축약 불가|아버지 스캔+재혁 PDF|L:221 D:1873 R:260|
|13|211|#12→#13|다은 미열람→돈/이름/시각 선공개|다른 선행권 2|두 보증의 칸·시각|L:237 D:1902 S:3657|
|14|212|#13→#14|미결정→거절/서명/차단|돈·통로·관계|PDF 서명/입력창|L:255 D:1931 R:310|
|15|215|#14→#15|한계 미기록→원/충돌/시간|다른 대면 2|제안+PDF 표시|L:273 P:191 S:3657|
|16|216|#15.c0→#16|∅→빨간 원+촬영시각|c1/2는 사본 포기|원 사진|L:291/296 P:600|
|17|217|#14+#15+(#16?)→#17|분산 문서→개방/상철/다은 선행|다른 선행권 2|7장·PDF·조건부 원·CG|L:307 P:242 S:3657|
|18|219|#17→#18|회의→삭제/자필/원조건|다른 결론 2|7장·PDF·조건부 자필|L:325 P:305 R:310|
|19|220|#18.c1→#19|∅→자필 원본 custody|c0/2는 M56 증거 포기|자필 원본·클립|L:343/348 P:627 G:409|

## 정본 승격 완료

- 계속 유효한 규칙은 `docs/CHOICE_CONSEQUENCE_SYSTEM.md`의 5장 exact receipt 절,
  `docs/STORY_BIBLE.md`의 5장 기준 배우/문서 경로, `docs/SCENE_TIER.md`의 승인된
  M49~M55 T2 장면 레지스트리, `docs/QA_CHECKLIST.md`의 장 전수 회귀 행으로만
  승격한다.
- exact 파일 범위, 19단위 배치, 검사 실행 순서, 착수 commit/tree는
  이 오더에서만 유효한 일회성 지시다.

## 다음 경계

M56~M60의 아버지 흔적→자기 이름 접수→사람들의 판결→실제 거래→마지막
서명과 `arc_final_week` exact actor binding을 별도 자식 오더로 연다. 33세·1장
30억 `instant_legend`는 비밀 이스터에그로 계속 보존한다.

**소유권 이관 (2026-08-26):** 구현 커밋 `34e5a89`과 보호 커밋
`8b7bc98`에서 M49~M55 구현을 freeze했다. 이 사양이 선언했던
`GameState.gd`, `MainGame.gd`, `StoryMode.gd`, 공유 사건·메타·검사 파일의
후속 소유권은 선언 커밋 이후 ORDER-134에 있다. ORDER-133 전용
19/47 원장·M55 CG·Year5 reference 보호 기준은 불변 회귀로 남는다.
