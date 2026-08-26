# Archived Queue Spec: ORDER-134

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [x] ORDER-134 [P0·5장 결말] M56~M60의 실제 문서·사람·마지막 서명을 엔딩에 잇는다

**[x] 완료 — 만진 파일:** `autoloads/GameState.gd`, `scenes/MainGame.gd`,
`scenes/StoryMode.gd`, `systems/Chapter5FinaleRoute.gd`,
`content/meta/chapter5_finale_ledger.json`, KO/EN 결말 사건·엔딩 연결·장면 계약,
전용/공용 감사, 아래 정본·마감 문서.

**완료 판정 (2026-08-26):** 구현
`974534f2ffdab012d6765d04ca2063792681656d`에서 작성 11 roots·30 choices,
한 런 9 roots·24 choices의 안전한 미실행 결말을 완성했다. 감사 정합
`a5439549991109f6bdb8d1e86e4053d2f5dad1f2` / tree
`31c8749e1393b8f27c53c31d1f13d99856f7181f`의 exact clean 전체 감사가
`✅ 감사 통과`했고 30억 `instant_legend`·즉시 실패 우선순위를 보존했다.
KO/EN×3해상도 종막 60장과 선행 30장 총 90장의 검은막 실패는 0이다.
중요 장면은 10비트에 맞추지 않고 trace→custody→filing→verdict→
nontransaction→return→answer→signature→outbound의 서로 다른 인과·감정
기능 때문에 9단계다. 정상 속도 재미 판정 L3는 OPEN이며 새 후보 빌드 전에는
플레이 준비 완료를 선언하지 않는다.

**사용자 위임·착수 근거 (2026-08-26):** 사용자는 게임을 끝까지
완성하고 직접 플레이할 때가 되면 알려 달라고 했다. 특히
엔딩으로 갈수록 서사와 게임성이 더 치밀하고 격동적이어야 하며,
중요 장면의 비트는 1~2개로 압축하지 말되 10이라는 숫자에 맞추지
말라고 했다. ORDER-133이 만든 M49~M55 투자·부동산 세로줄은
실제 접수·거래·엔딩으로 아직 연결되지 않았고, 기존 M59 원고는
지급하지 않은 계약금·잔금·양도 결과를 산문으로 발명한다. 이
자식은 실제 금액·조건이 없는 거래를 하지 않고, 무이체·미실행이
정확한 물질 결과가 되는 최종 경로를 먼저 완성한다.

**착수 기준선:** `8b7bc98fc612cfef02d6f7a7596941f6b70ecdab`. ORDER-133
구현 커밋 `34e5a89d67b49ade65aa046ad69e9b02ae165338`의 19 roots·47 choices,
경로 보호 커밋 `8b7bc98`의 career/startup 32 roots·86 choices 기준선을
동시에 지킨다. ORDER-133의 공유 런타임·사건 파일 소유권은 이
선언 커밋 이후 ORDER-134로 이관한다.

## 깊이 3문

1. **이 세로줄을 열지 않으면 무엇이 깨지는가?** M55의 네 사람 결정은
   실제 접수·무이체·마지막 서명에서 읽히지 않고, 성공 엔딩은
   `arc_final_week_seen`이 우연히 쓰인 다음 월에 닫히거나 목표 미달 런은
   38세가 되는 다음 턴까지 엔딩이 늦어진다.
2. **본 플레이어와 보지 않은 플레이어의 상태가 24주 뒤에 다른가?**
   M55 이름 결정, 아버지 생사·최종 연락, M57 접수 상태, M58 대답,
   M59 `no_executable_contract`를 exact receipt로 남긴다. 이 기록은 M60의
   문서·대사·가능한 행동과 최종 엔딩 해제 시점을 바꾸며, 없는
   동의·접수·이체·답장은 추론하지 않는다.
3. **같은 자리에서 무엇과 경쟁하는가?** 늦게 남은 아버지·다은·상철
   반복 아크, 일반 AP 행동판, generic `arc_final_countdown/final_week`,
   실물 없는 M59 거래 산문과 경쟁한다. W221~W240에서는 원장의
   다음 exact root만이 이기고, 선택한 장면이 그 주의 행동이 된다.

## 배치 A — 한 플레이의 9 roots·24 choices

| # | 월/주 | 기능 | 제품 root | 선택 | exact 독자 |
|---:|---|---|---|---:|---|
| 1 | M56/W221 | 아버지 흔적으로 M55 심판 | `arc_y5_father_trace_alive_exact` 또는 `arc_y5_father_trace_passed_exact` | 3 | M55 choice, father life/contact |
| 2 | M56/W224 | 비교 문서를 다은에게 공유/자기 보관 | `arc_y5_father_trace_custody` | 2 | W221 choice |
| 3 | M57/W227 | 철회·제한 접수·확인 보류·자기 명의 접수 | `arc_y5_name_on_line_daeun_routed` | 4 | M55, custody |
| 4 | M58/W230 | 다은·민서의 서로 다른 판정 | `arc_y5_people_verdict_daeun_exact` | 3 | filing state, custody |
| 5 | M59/W235 | 접수 상태별 무이체·미실행 통지 | `arc_y5_property_not_executed_notice` | 1 | filing/verdict, economic zero |
| 6 | M60/W238 | 재혁에게 보증 이후 결과 전달/미전달 | `arc_y5_remaining_jaehyuk_or_self` | 2 | W212, W235 |
| 7 | M60/W239 | 생존 아버지에게 보내거나 별세 기억 앞에 남김 | `arc_y5_final_father_answer_alive` 또는 `arc_y5_final_father_answer_passed` | 3 | W221, W235, father life/contact |
| 8 | M60/W240 | 접수 문서와 무이체 결과 앞의 마지막 서명 | `arc_final_countdown_property_not_executed` | 3 | filing, verdict, noexecution |
| 9 | M60/W240 | 다은에게 먼저 보내는 구체 행동 | `arc_y5_final_week_daeun_outbound` | 3 | signature, prior Daeun facts |

한 런의 9 roots·24 choices는 숫자 목표가 아니다. 각 root가 trace,
custody, filing, verdict, nontransaction, guarantee return, father answer,
signature, outbound action이라는 서로 다른 인과·감정 기능을 닫기 때문이다.
중요 장면은 그 기능에 필요한 비트를 모두 쓰되 10에 맞추지 않는다.

## 배치 B — typed finale reducer·저장·엔딩 해제 18단위

1. 로케일 중립 `Chapter5FinaleRoute` schema 1과 exact JSON ledger.
2. `entry={route_id,turn,profile_id,source_route_id,source_choices,father,actor_bindings}`.
3. M55 conditional W220까지 소진한 `Chapter5CausalRoute.route_complete()`.
4. W221 entry lock과 이후 생사·관계 변화에도 배우·출처 재결속 금지.
5. exact state/entry/receipt/ending key set 검증.
6. 선언된 정수만 JSON 디스크 경계에서 int 정규화.
7. legacy missing/tamper/corrupt state fail-closed, W221 전 구저장은 진입 가능.
8. root/turn/index/order/actor/document/economic receipt write-once·idempotent.
9. M57 choice 0~3을 `withdrawn|limited_filed|verification_hold|self_filed`로 구분.
10. M59 `economic_outcome={kind:none,reason:no_executable_contract,cash_delta_krw:0,asset_delta_krw:0,debt_delta_krw:0}`.
11. 선택별 exact 문서 문장을 KO/EN 원고에 prepend하는 typed causal reads.
12. StoryMode preflight→full snapshot→`apply_choice`→receipt commit 원자성.
13. 실패 시 GameState full snapshot 즉시 롤백.
14. W221~W240 direct foreground ingress·same-turn W240 chain·AP 재질문 0.
15. finale entry 후 비치명 ending hold, 기존 5개 즉시 실패 엔딩 우선 보존.
16. final-week receipt에서 `pending→ready`, MainGame 복귀에서 `ready→consumed`를 먼저 쓰고 canonical `check_game_over()` 1회.
17. 37세 W240 미달 런도 consumed finale에서 기존 38세 분기 순서로 즉시 결산.
18. 33세·1장 현재 30억 `instant_legend`은 바이트·순서·결과 불변.

## 구현 계약

- 실행 profile은 `investment_safe_no_execution` 하나다. career/startup·일반 런을
  사실인 것처럼 바인딩하지 않고, 그 경로는 후속 자식이 같은 reducer에
  profile을 추가한다.
- 진입은 ORDER-133 경로의 exact entry와 terminal 선택이 있고, c1이면 W220
  자필 동의 receipt까지 있을 때만 성공한다. 19 receipts를 무조건
  요구하지 않는다.
- 아버지 생사는 단조 증거로 고정하고, `present|called|missed|records_only`는
  실제 Y4 final-contact flags로만 저장한다. 연락 증거가 없거나 충돌하면
  `records_only`로 닫고 통화·방문을 발명하지 않는다.
- 배우는 ORDER-133이 실제 만난 `player/father/sangchul/daeun/minseo/jaehyuk`만
  고정한다. 현수·지연·연인·배우자를 새로 만들지 않는다.
- M57의 네 결과는 서로 다른 물성을 유지한다: 빨간 철회 도장, 다은
  제한을 가진 접수본, 현재 동의 확인 보류·임시번호, 자기 명의 227번.
  M58~M60은 해당 receipt를 exact 문장으로 읽는다.
- 거래를 실행하지 않는 것은 깨끗한 정답이 아니다. 수수료·닫힌 시간,
  다른 사람의 쓴 시간, 보류·미전달을 상태별로 남긴다. 다만 금액·등기·
  소유·부채는 변화 0이다.
- W240의 두 선택은 같은 밤의 독립 기능이다. 첫 서명은 다섯 해를
  자기 문장으로 해석하고, 둘째 선택은 다은에게 밥·사과·거리와 다음
  연락 시각 중 하나를 실제로 먼저 보낸다. 두 선택 모두 숨은 능력치·
  Moral Tint·경제 effect 없이 receipt와 후일담만 바꾸며, 답장·용서·
  재회는 확정하지 않는다.

## 정확한 파일 소유권

**런타임·저장:** `autoloads/GameState.gd`, `autoloads/SaveManager.gd`,
`scenes/MainGame.gd`, `scenes/StoryMode.gd`, `systems/Chapter5CausalRoute.gd`,
`systems/EndingSystem.gd`, 신규 `systems/Chapter5FinaleRoute.gd` 및 `.gd.uid`, 신규
`content/meta/chapter5_finale_ledger.json`.

**사건 KO/EN:** `content/events/arc_year3_drama.json`,
`content/events_en/arc_year3_drama.json`, `content/events/arc_pre_ending.json`,
`content/events_en/arc_pre_ending.json`, `content/events/arc_drama.json`,
`content/events_en/arc_drama.json`.

**제품·서사 계약:** `content/meta/event_lifecycle.json`,
`content/meta/event_director.json`, `content/meta/story_map.json`,
`content/meta/story_rules.json`, `content/meta/narrative_spine.json`,
`content/meta/release_content_inventory.json`, `docs/STORY_BIBLE.md`,
`docs/CHOICE_CONSEQUENCE_SYSTEM.md`, `docs/SCENE_TIER.md`,
`docs/CONTENT_RATING_INVENTORY.md`, `docs/ENDING_CONTRACT.md`,
`docs/QA_CHECKLIST.md`.

**검사:** 신규 `tools/chapter5_finale_route_audit.py`, 신규
`tools/Chapter5FinaleRouteCheck.gd`, `.gd.uid`, `.tscn`,
`tools/arc_flow_sim.py`, `tools/event_lifecycle.py`,
`tools/event_director_audit.py`, `tools/story_map_audit.py`,
`tools/narrative_spine_audit.py`, `tools/narrative_continuity_audit.py`,
`tools/full_run_pacing_audit.py`, `tools/EndingRouteIdentityCheck.gd`,
`tools/ManualSaveCheck.gd`, `tools/CoreChoiceSliceCheck.gd`,
`tools/chapter1_core_loop_v2_causal_ledger_check.py`,
`tools/chapter4_causal_route_audit.py`, `tools/story_consistency_audit.py`,
`tools/i18n_coverage_check.py`, `tools/audit.py`,
`tools/audit_scope.json`, `tools/audit.sh`.

**선언·마감:** `docs/CODEX_QUEUE.md`, 이 사양과 완료 시
`docs/queue_archive/ORDER-134.md`, `docs/queue_archive/CODEX_QUEUE_2026-08.md`,
`docs/queue_archive/ORDER-133.md`, `CLAUDE.md`, `docs/WORK_LOG.md`,
생성본 `docs/STATUS.md`.

`project.godot`, 기존 ending JSON/산문, career/startup reference roots·86 choices,
`systems/Year5ReferenceRouteKernel.gd`, 밸런스 수치는 수정하지 않는다.
`check_game_over()`는 비치명 ending hold, W240 consumed 시간 게이트만 추가하며
기존 즉시 실패 5개, NG+·startup·성공 분기 순서, `instant_legend`
블록은 byte-exact로 지킨다.

## 완료 증거

- **L1 기계:** 한 런 9 roots·24 choices, 변형 roots까지 exact KO/EN parity,
  주차·순서·배우·문서·economic-zero, write-once/idempotent, save/load,
  tamper/legacy fail-closed, same-turn W240, ending ready/consume exactly once를 Python·Godot
  검사로 입증한다.
- **L1 엔딩:** age 33 현재 30억은 즉시 `instant_legend`, age 34+
  30억은 W239까지 hold, W240에 단 한 번 해제, 30억 미달도 W240에
  기존 시간제 분기로 결산한다. 번아웃·정신·채무·파산·중독 즉시
  실패가 항상 먼저 이긴다.
- **L1 보호:** ORDER-133 19 roots·47 choices, career/startup 32 roots·86 choices/
  consumer 0/kernel byte-exact, Chapter 1 476 self-test, strict JSON·KO/EN·서사·말투·
  lifecycle/director/map/spine/pacing, `git diff --check` 통과. 공용 runtime·ending
  gate를 바꾸므로 구현 freeze 후 exact clean 전체 감사를 한 번 실행한다.
- **L2 자가:** 9행 전수표에 도달 주차, producer↔reader, before→after,
  포기 비용, 문서 물성, 파일:행을 남긴다. KO/EN W221·W227·W230·W235·
  W240을 실제 Godot에서 캡처해 검은막·HUD·자막·배경·포커스를 본다.
- **L3 사람:** 기계 GREEN은 재미 GO가 아니다. 사용자가 M56~M60을
  정상 속도로 플레이해 거래 0이 빈 결말이 아니라 닫힌 문·쓴 시간·
  먼저 보낸 말로 느껴지는지, M57·M60 선택이 실제 포기로 남는지
  판정한다. 이 단계 전에는 플레이 준비 완료를 선언하지 않는다.

## L2 전수 증거

생사 변형은 같은 기능 행에 병기한다. 근거 별칭은
`F=content/meta/chapter5_finale_ledger.json`, `Y=content/events/arc_year3_drama.json`,
`P=content/events/arc_pre_ending.json`, `D=content/events/arc_drama.json`,
`G=autoloads/GameState.gd`, `S=scenes/StoryMode.gd`,
`R=systems/Chapter5FinaleRoute.gd`, `E=systems/EndingSystem.gd`,
`M=scenes/MainGame.gd`의 실제 `파일:행`이다. 공통 entry/commit/read/prepend는
`G:409/445/520`, `S:3735`; ready/consume는 `R:324/509/519`, `M:541`이다.

|#|W|producer→reader|before→after|포기·비용|물성|근거|
|---:|---:|---|---|---|---|---|
|1|221|M55+father entry→trace alive/passed|∅→사실/연락/records 1|답장·방문·부활 없음|생존 연락+회의록 / 별세 봉투+회의록|F:51/75 Y:1162/1249|
|2|224|#1→custody|∅→다은 공유/자기 보관|통제/공유 중 1|비교본 Daeun/Self|F:99 Y:1297 G:520|
|3|227|M55+#2→filing|∅→철회/제한/보류/자기명의|기회/상한/즉시성/타인 이름|빨간 표지·제한본·임시번호·227번|F:121 P:674 R:324|
|4|230|#2+#3→verdict|한 결론→다은/민서/분리|다른 말 순서|사람 시간/절차 메모|F:146 P:770 G:520|
|5|235|#3+#4→nontransaction|미확정→no contract, 0/0/0|소유·등기·열쇠 없음; 시간 남음|미실행 통지|F:170 P:1164 R:154|
|6|238|W212+#5→guarantee return|∅→실제 채널 상태 보존/자기보관|채널에 남길 문장/자기 원장 중 1|채널 상태본/Self copy|F:203 D:1963 G:520|
|7|239|#1+#5→answer alive/passed|∅→문자/음성/시각 또는 봉투/빈자리/날짜|답장·화해·전달 없음|생존/별세 답 기록|F:226/250 Y:1334/1379|
|8|240|#3+#4+#5+#7→signature|미서명→내 이름/사람/비용 1; pending|다른 해석 2; 거래 없음|무이체 마지막 서명|F:274 P:1237 R:324|
|9|240|#2+#8→outbound→coda|무발신·pending→밥/사과/거리 1·ready→consumed|다른 발신 2; 답장·숨은 효과 없음|구체 발신 시각|F:300 D:2004 E:122 M:541|

최종 `final_revision5`에서 KO/EN×3해상도 finale 60장과 ORDER-133 causal
30장, 총 90장을 새로 렌더했다. 사전/사후 fingerprint
`1566ed39cb1964b302d38579dc783fc76070717b852c8ae089d789e38df22f8a`가
같고, 고유 PNG `90/90`, 실제 해상도 일치, `BLACK_FAIL 0/90`, 검은막·겹침·
포커스·same-turn·ending receipt 육안 검수가 모두 통과했다. 이는 레이아웃
L2이며 정상 속도 재미 GO가 아니다.

## 정본 승격 완료

- 계속 유효한 규칙은 `docs/CHOICE_CONSEQUENCE_SYSTEM.md`의 M56~M60 exact
  filing/nontransaction/finale receipt 절, `docs/STORY_BIBLE.md`의 인물·문서 결말,
  `docs/SCENE_TIER.md`의 승인 장면, `docs/QA_CHECKLIST.md`의 엔딩 회귀로만
  승격한다.
- exact 파일 범위, 배치 단위, 검사 실행 순서, 착수 commit/tree는
  이 오더에서만 유효한 일회성 지시다.

## 다음 경계

이 오더는 ORDER-133 투자·부동산 세로줄의 사실인 미실행 결말만
완성한다. 그 다음은 같은 finale reducer에 일반 안전 런, career, startup
profile을 각각 작은 자식으로 추가한다. 가격·수수료·금융 조건 없이
부동산 소유·취소·양도 거래를 발명하지 않으며, 33세·1장 30억
`instant_legend`는 비밀 이스터에그로 계속 보존한다.
