# Gangnam Dream QA Checklist

Use this checklist before major commits, playable builds, and release candidates.

Cross-discipline release gates and current product risks live in `docs/MASTER_RELEASE_AUDIT.md`.

## Chapter 1 48-Week Causal Ledger Gate

This gate has two deliberately different modes. A truthful snapshot of an
incomplete Chapter 1 may pass the first mode; only a complete 12-month causal
ledger may pass the second. Neither mode is a normal-speed human GO.

### Current snapshot and coverage-gap gate

- Run `python3 tools/chapter1_core_loop_v2_causal_ledger_check.py --self-test`,
  then run `python3 tools/chapter1_core_loop_v2_causal_ledger_check.py` against
  the checked-in ledger and debt baseline. The current declaration snapshot
  must report target rows `48`, authoritative implemented rows `24`, missing
  slots `24`, exact current↔baseline debt equality, and the literal diagnostic
  `COVERAGE_GAP weeks=25..48 missing_slots=24 authoritative=24/48`.
- Exit zero in this mode means only that the W1–24 prefix and the W25–48 gap
  were described without missing, extra, duplicate, stale, or fabricated
  evidence. `coverage_gaps` entries do not count as gameplay rows. A gap record
  may name its range, missing slot IDs, status, runtime proof, and later owner;
  it must not invent a producer, terminal, next verb, reader, or save proof for
  unimplemented play.
- The checker must lock the ledger's canonical semantic JSON digest and every
  proof's exact ID, kind, pointer, assertion, and pointed-source digest. It must
  also lock the causal runtime/data/normative owners and the MainGame/StoryMode
  scene bindings, while checking the five exact project autoload bindings rather
  than freezing unrelated project settings. A coordinated ledger relabel, a
  valid-but-unrelated function pointer, or a changed transitive causal owner is
  a failure even when the JSON schema still passes.
- Every weekly branch owns only its board-route completion. Job-hunt quality,
  Aruba results, inventory outcomes, recovery diminution, and Story choices are
  exact nested output groups. The checker must enumerate realized branch×group
  outputs, reject a group from another row or unreachable bundle, and reject a
  Story output used to inflate weekly-route divergence or clear an orphan fact.
  The 23 trigger-bearing rows plus the one allocation-only row must form an
  exact execution-family census with zero unclassified rows and no invented
  conditional group on a fixed result.
- Milestone invocations must declare both facts read and facts produced. A
  producer→reader handoff must preserve first-run versus reentry ownership,
  exact choice identity, mutually exclusive activation, and any context-root or
  deferred-receipt gate. A displayed log is classified separately and cannot
  satisfy a causal reader, route-divergence, or orphan-fact requirement.
- A multi-stage milestone must declare source-derived applicability,
  predecessors, invocation membership, and runtime proof for every execution
  stage. JSON array order is non-semantic: the checker must validate the DAG,
  reject cycles and later→earlier handoffs, and allow a shared order index only
  for source-proven mutually exclusive paths. Fatal/surviving, fresh/reentry,
  dirty/clean, and optional-follow-up paths may not be unioned into one
  impossible co-present execution.
- First-entry, prepared MainGame reentry, and cold StoryMode resume must keep
  separate handoff versus durable material/history roles. A reader may be reused
  across mutually exclusive call sites only when no source scenario co-presents
  the duplicates. Every First Bill formatter call containing a special token
  must bind its eager full read set; a token-free call must not gain a fake
  causal reader.
- Each row's save proof is the exact eight-step chain from `SaveManager.save_game`
  through payload byte write/read verification, `SaveManager.load_game`,
  `GameState` serialize/load, and both V2 normalization layers. A raw dictionary
  round trip or a pointer to only one normalization function is insufficient.
- A report, dashboard, audit summary, or handoff that turns this expected
  `COVERAGE_GAP`, a blocked full-scope evaluation, or normal snapshot exit zero
  into Chapter 1 `OK`, complete, green, or release-ready evidence fails this
  gate. Removing the blocked evaluation, reporting zero findings for an
  unevaluated W25–48 scope, or weakening the target from 48 rows also fails.
- Existing 24-week title-to-CTA input, surface, survivability, localization,
  save, and First Bill rows remain authoritative prefix regression evidence.
  The existing Week-24→48 component carryover row remains historical/legacy
  compatibility evidence, including its expected zero new V2 receipts after
  Week 24. Those checks may catch a regression, but none can satisfy the
  complete-Chapter-One mode or prove playable W25 input.

### Completion-only machine gate and W48 order

- Run
  `python3 tools/chapter1_core_loop_v2_causal_ledger_check.py --require-complete-chapter-one`
  only for a final Chapter 1 candidate. It must fail while any coverage gap,
  blocked evaluation, current debt, or baseline debt remains. It may exit zero
  only with exactly 48 unique month×family rows, all 12 months containing one
  `advancement`, `livelihood`, `people`, and `self` row, gap count `0`, blocked full-scope
  evaluations `0`, and both current debt and baseline equal to `{}`. Every row
  must have real runtime evidence for availability, completion/expiry producer,
  terminal, next verb, near/month/W48 reader, and save round trip.
- The completion gate must also prove this exact living W48 order:

```text
last W48 capacity/node action
→ its threshold/task and W48 world event
→ M12 completed/expired/forgone outcomes
→ December income, fixed cost, arrears, decline, and failure check
├─ fatal result → terminal failure only
└─ survived → chapter1_end_snapshot from the post-settlement state
              → arc_year1_close
              → eligible actual-seen-scene curation
              → chapter1_complete save
              → Chapter 1 completion surface
              → user chooses Chapter 2
              → W49 and chapter_card_34
```

- Routing `arc_year1_close` at W48 week start, before the final action or
  December settlement, is a failure even if the event is reachable. A fatal
  December result opens no Year-One boss, scene curation, completion save, or
  completion surface. The frozen snapshot must contain the actual final action
  and post-settlement material state and must not read W49 or Chapter 2 facts.

### L2 48-slot review and demo boundary

- L2 is one exhaustive 48-row review table, not a count summary. It contains
  exactly one row for each `M01..M12 × advancement|livelihood|people|self` slot
  and records slot ID, month/week window, family, `implemented|missing`, runtime
  pointer or current gap proof, completion/expiry producer and terminal, next
  verb, near/month/W48 reader, save proof, current debt code, and later debt
  owner. Duplicate or absent slots fail. In the declaration snapshot, M1–M6 are
  the 24 implemented rows and M7–M12 are the 24 explicit missing rows; a missing
  row may not be reviewed as if planned prose were runtime evidence.
- Checker self-tests, the normal snapshot, the completion-only flag, and the L2
  table are full Chapter One L1/L2 evidence only. A future
  `--require-complete-chapter-one` pass proves the W1–48 runtime construction
  contract; it is not a demo RC, release, or human-verdict condition. Demo human
  and platform approval instead uses one unchanged clean W1–24 `demo_rc` through
  its W24 CTA. That GO approves only the demo and does not claim W25–48 or full
  Chapter One completion.

## Chapter 5 M49~M55 Causal Ingress Gate

- `python3 tools/chapter5_causal_route_audit.py`와
  `Chapter5CausalRouteCheck.tscn`은 정확히 19루트·47선택, 0-based index,
  주차 `195,196,197,200,201,203,204,207,208,209,210×2,211,212,215,216,217,219,220`,
  M51 검사→민서→다은, M53 요청→통화→아버지 문서→다은 공개→결정 순서를
  함께 잠근다. 빠진·추가된·중복된 루트나 선택, locale prose가 들어간 영수증,
  잘못된 배우·문서·주차는 실패다.
- 19개 KO 루트는 `author_only` 태그와 lifecycle에서 빠지되 `weight=0`,
  `hidden=true`, `conditions.min_turn=9999`를 유지한다. EN은 같은 ID·선택 수의
  text-only overlay이며 gameplay 키를 새로 소유하지 않는다. M56~M60 결말까지
  등록한 현재 코퍼스는 packaged 1,796, shipping 1,686, author-only 110이어야 한다.
- W207은 일반 Echo보다 `arc_y5_final_offer`가 먼저이며 W219도 회의 결정을
  직접 소유한다. 열린 18개 고유 주차에서는 일반 AP 3택을 다시 묻지 않는다.
  W210은 return call 뒤 father document 하나만 같은 주 queue로 잇고, unrelated
  due root를 함께 비우지 않는다.
- W216 `arc_y5_sangchul_review_receipt`는 `arc_sangchul_final_door` choice 0,
  W220 `arc_y5_room_consent_receipt`는 `arc_y5_three_in_room_decision` choice 1에서만
  열린다. 다른 선택·손상 저장·legacy 추론이 빨간 원이나 자필 원본을 만들면
  실패다.
- 영수증 쓰기는 write-once·idempotent이고 중복·역순·범위 밖 index·tamper에
  fail-closed여야 한다. 수동 저장과 자동 저장의 serialize/load 왕복 뒤 exact
  actor/document/order가 같아야 하며 재진입이 효과나 장면을 반복해서는 안 된다.
- **인과 완성 게이트:** 47개 선택 각각에 choice-index를 읽는 실제 downstream
  dialogue/availability/cost/absence reader가 하나 이상 있어야 한다. 다음 루트가
  단지 선행 receipt의 존재를 확인하거나 로그에 표시하는 것은 reader가 아니다.
  1~17번 루트의 43선택은 후속 16루트의 `chapter5_causal_reads`가 실제
  관찰 행동을 본문 앞 대사로 읽는다. KO는 exact
  `source_event_ids/optional_source_event_ids/texts/mode` 구조, EN은 text-only
  `texts` overlay, source 행·choice 열 패리티를 지켜야 한다. 18번의 3선택은
  W221·W227 문장을 바꾸고 19번의 1선택은 M56 진입 잠금이 소비하므로 현재
  `47/47 connected, 0 pending`이다.
- 기존 career/startup Year 5는 `32 roots / 86 choices / consumer 0 /
  reference_only`, `Year5ReferenceRouteKernel.gd` byte-exact를 유지한다.
  M49~M55는 거래·이체·엔딩을 적용하지 않으며 `instant_legend` 라우팅과 엔딩
  JSON은 불변이다.
- 기계 통과 뒤 KO/EN 실제 장면과 M55 전용 CG를 960×600, 1280×800,
  1920×1080에서 캡처해 검은막, CG crop, 상철 초상, player-determined 전달,
  문서·자필·빨간 원의 시선, HUD/자막 겹침을 눈으로 본다. 정상 속도 L3에서
  문서가 인물 압박으로 읽히고 M53·M55의 포기가 실제로 느껴져야만 사람이 GO한다.

## Chapter 5 M56~M60 Safe Finale Gate

- `python3 tools/chapter5_finale_route_audit.py`와
  `Chapter5FinaleRouteCheck.tscn`은 생존·별세 변형을 포함한 정확한 11루트·30선택,
  한 플레이의 9루트·24선택, 주차 `221,224,227,230,235,238,239,240×2`와
  `father_trace→custody→filing→verdict→nontransaction→guarantee_return→
  father_answer→signature→outbound` 순서를 잠근다.
- 진입은 `investment_safe_no_execution` 하나만 허용한다. M49~M55의 terminal
  선택과 exact entry가 있어야 하고, M55 choice 1은 W220 자필 원본 receipt까지
  요구한다. 진입 뒤 father life/contact, source choices, actor bindings를 다시
  현재 상태에서 추론하면 실패다. career/startup·일반 런을 이 프로필에 묶어서는
  안 된다.
- M57은 `withdrawn|limited_filed|verification_hold|self_filed`의 네 물성을
  choice 0~3과 정확히 대응시킨다. 붉은 철회 표지, 다은 제한 접수본, 현재 동의
  확인 보류·임시번호, 자기 명의 227번을 서로 바꾸거나 접수 완료·거래·소유권으로
  확대하면 실패다.
- M59 receipt는 `kind:none`, `reason:no_executable_contract`, 현금·자산·부채
  변화가 각각 0이어야 한다. 산문·effect·저장 어느 곳도 지급하지 않은 계약금·
  잔금·수수료 금액, 취소·양도·등기·열쇠를 만들면 실패다. 닫힌 창구, 쓴 시간,
  보류와 미전달은 상태별로 남아야 한다.
- receipt는 root·turn·order·actor·document·economic outcome을 write-once·
  idempotent로 저장한다. 수동/자동 저장 왕복, same-turn resume, legacy missing,
  tamper/corrupt, 중복·역순·범위 밖 선택을 검사하고, StoryMode commit 실패는
  선택 효과를 포함한 전체 상태를 byte-identical하게 되돌려야 한다.
- W240은 `arc_final_countdown_property_not_executed` 완료 뒤
  `arc_y5_final_week_daeun_outbound` 하나만 같은 주 queue로 잇는다. 마지막 선택이
  `pending→ready`, MainGame 복귀가 먼저 `ready→consumed`를 한 번만 쓴 뒤 기존
  `check_game_over()`를 정확히 한 번 호출해야 한다. W240 재진입·중복 엔딩 기록·
  다음 달 지연은 실패다. 두 W240 선택의 능력치·Moral Tint·경제 effect는 모두
  비어 있어야 하며, exact signature/outbound receipt와 후일담만 달라져야 한다.
- 번아웃·정신 붕괴·채무·파산·중독의 즉시 실패 5개는 finale hold보다 먼저 이긴다.
  30억원 미달 37세 런도 W240 outbound 직후 기존 38세 결말 순서로 닫히며,
  33세 첫 장 30억원은 즉시 `instant_legend`로 끝나야 한다. 이 비밀 엔딩의
  조건·순서·결과가 바뀌면 실패다.
- KO/EN W221·W227·W230·W235·W240을 960×600, 1280×800, 1920×1080에서
  캡처한다. 검은 전환막이 멈춰 보이지 않는지, 배경·초상·문서·자막·HUD·포커스가
  겹치지 않는지, W240 두 장면이 같은 밤의 다른 기능으로 읽히는지 본다. 기계
  GREEN은 재미 GO가 아니며 정상 속도 사람이 무이체를 빈 결말이 아니라 닫힌 문·
  쓴 시간·먼저 보낸 말로 느껴야 플레이 준비 완료를 선언한다.

## Release Content Survey / Rating Intake Gate

- `content/meta/release_content_inventory.json` is the machine ledger and
  `docs/CONTENT_RATING_INVENTORY.md` is its generated reviewer view. Run
  `python3 tools/release_content_inventory.py`; report freshness, bilingual
  event/ending evidence, export presets, content fingerprints, runtime online
  APIs, and the Steam AI draft must agree. Run `--self-test` to prove the
  mutation gates before closing inventory changes.
- Every row must identify owner/evidence, expression intensity, and all three
  scopes: `24-week V2 reachable`, `240-week full reachable`, and `included in
  package but currently unreachable`. Missing ownership, reachability, package
  state, or intensity is a release failure.
- All current export presets use `all_resources`. Source reachability does not
  prove package absence. Inspect real full and V2 pack ZIPs with:

```bash
python3 tools/release_content_inventory.py \
  --pack-zip retail_full=build/qa/release_content_inventory/full.zip \
  --pack-zip v2_playtest=build/qa/release_content_inventory/v2.zip
```

- Review gambling, sexuality, violence, fear, language, crime,
  alcohol/tobacco/drugs, generative AI, and online features. The AI disclosure
  must include actual pre-generated assistance in some 2D art, narrative,
  English localization, programming/code, and audio source selection, editing,
  arrangement, and mixing. Audio source waveforms remain recordings or recorded
  real-instrument samples, not text-to-audio or code synthesis. Do not turn that
  source fact into a false denial of AI-assisted audio production. Final human
  review and no runtime generation/external AI service stay exact.
- The current runtime is offline single-player. Network APIs, multiplayer,
  chat, remote UGC, telemetry, real-money payment, and live AI remain zero. One
  `OS.shell_open` may leave the game for the Steam wishlist/store page; local
  data-only mods under `user://mods/` are not an online feature.
- Official public references were checked 2026-08-03: [Steamworks Content
  Survey](https://partner.steamgames.com/doc/gettingstarted/contentsurvey?l=english),
  [게임물관리위원회 등급분류규정](https://www.law.go.kr/LSW/schlPubRulInfoP.do?chrClsCd=&schlPubRulSeq=2200000127949),
  [게임콘텐츠등급분류위원회 이용안내](https://www.gcrb.or.kr/Images/usingGuide/using_guide_01.html),
  and the [게임산업진흥에 관한 법률](https://www.law.go.kr/LSW/lsInfoP.do?lsId=010196).
  Steam requires uploaded mature content to be disclosed even when inaccessible;
  its survey does not replace the Korean evidence pass.
- Public pages are not a verbatim copy of every partner-only form. Before each
  submission, capture the live form, record its version and candidate build,
  and reconcile every answer with the inventory. Automation must never choose
  a final age rating, delete content, or change export filtering; those remain
  `user_required`. This checklist is not legal advice.
- Rating/submission disclosure is not store marketing. Do not expose Moral Tint,
  hidden endings, betrayal outcomes, or other discovery-hidden material beyond
  what the platform or rating submission actually requires.

## Controller / Steam Deck Release Gate
- Controller support is a release gate, not a polish extra. See `docs/CONTROLLER_UX_STRATEGY.md`.
- Focus traversal is the last resort, not the default controller model. Gameplay uses direct contextual actions or a semantic mode/cursor; focus is reserved for settings and short conventional lists.
- A first-time player must complete the first 15 minutes with controller only: no mouse, no keyboard, no hidden shortcuts.
- Every major screen must present a default active selection or contextual action within 0.5 seconds. Only a conventional menu needs an actual GUI focus owner.
- No short menu should force the player through more than 12 focusable targets in one rail; gameplay must not become a focus rail at all.
- Casino minigames must pass controller-only flow: change stake, place bet, read bet, start round, read result, repeat/exit.
- Dense casino layouts such as Dai Sai and Roulette must use mode/cursor models, not flat focus traversal over every visible bet button.
- `A/South` confirms the highlighted item, `B/East` backs out or clears pending action,
  `X/West` performs the named contextual secondary action, `Y/North` opens
  rules/details, `LB/RB` changes sibling group/tab/mode, and `L2/R2` changes the
  previous/next page or decreases/increases a reversible coarse value.
- A screen without pages or a coarse value leaves `L2/R2` inert. Triggers never
  confirm, save, load, purchase, commit a schedule, advance time, or exit.
- A held/noisy analog trigger changes exactly one page/value before release;
  thresholds, reconnect, modal capture, and background input cannot duplicate it.
- When the right-side Info Deck is open, `B/East` must close it instead of opening the system menu.
- Basic actions must not require hidden multi-button chords.

## Display / Console Readiness Gate
- Windowed mode remains freely resizable down to the explicit 960x600 minimum; resizing never loses focus, hides a primary command, or requires restarting the scene.
- Validate 960x600, 1280x720, 1280x800, 1600x900, 1920x1080, 2560x1440, 3840x2160, and 3440x1440. This is one responsive layout system, not eight manually positioned variants.
- Story text, AP decisions, casino controls, result actions, and subtitles stay inside a central safe area suitable for TV overscan and handheld edges.
- Backgrounds and CGs use aspect-cover cropping without geometric stretching. Faces, gaze targets, decisive hands, cards, chips, and result states survive every supported aspect ratio.
- QHD/4K text and vector surfaces remain native-sharp. Raster masters must not reveal obvious 1280px upscale softness at normal viewing distance.
- A platform glyph changes presentation only. Xbox/Steam Deck, DualSense, and Nintendo controllers preserve the same semantic South/East/West/North actions.
- Controller-only suspend/resume restores the last safe focus and never advances prose, confirms a bet, or consumes AP on wake.
- Gamepad vibration is optional and intensity-controlled. Focus, hover, UI
  click/open/close, tab/page navigation, prose advance, failed input, and reversible
  value preview never vibrate. Named semantic pulses are reserved for successful
  choice/action/wager commits, tactile table actions, race impacts, real danger,
  and major result beats; raw per-scene motor numbers are rejected.
- Vibration Off and 0% both stop active output immediately and remain silent after
  settings reload. Visual/audio feedback must preserve all information without it.

## Targeted Screenshot QA
- Run screenshot QA for the surface you changed, not the entire visual suite by default.
- Use full `surface-en` or casino QA only before release candidates, before/after broad UI refactors, or when casino/minigame code changed.
- Keep the user-facing proof focused: inspect the PNGs for the modified surface, then run static audits.

| Change area | Fast QA command |
|---|---|
| First-five-minute reading contract: fresh StoryMode AUTO OFF, same-session user opt-in persistence, one physical Enter/South/click per tutorial page, planner focus restoration, the three-page promise/world/scene ownership tutorial, and the 2020 Knee flashback using only the age-57 `father_past` portrait in KO/EN safe crops | `StoryPlaybackCheck.tscn`, `TutorialInputCheck.tscn`, `StoryTutorialPlacementCheck.tscn`, then `--qa=story-presence --lang=ko/en` at 1280×800 |
| StoryMode reading settings: three text sizes, Slow/Normal/Fast typewriter speed, immediate persistence, authored slow-pacing ratio, AUTO total-time compensation, text-size→speed→language→audio→vibration→motion controller focus, vibration off/0% immediate stop and disabled-strength focus skip, and 960×600 no-scroll fit | `StoryAudioSettingsCheck.tscn`, `InputMatrixCheck.tscn`, `ControllerSemanticCheck.tscn` at `--resolution 960x600`, then `--qa=story-audio --lang=ko/en` plus Japanese UI audit |
| StoryMode Dialogue History: only fully seen prose, the confirmed player choice, and seen result text; literal bracket notices retained while real BBCode is stripped; partial current text without future leakage; no unchosen/locked option or hidden score; same-session follow-up continuity; fresh-session reset; actual top-button/West open, East close, visible scroll focus and bottom-to-Close navigation; paused typing/AUTO/direction/timed choice; exact choice-focus and timer restoration; source-progress resume across text-size pagination; cross-locale source-shape mismatch rewinding the current phase to source zero without future leakage; nested resume schema and explicit pre-feature v4 notice; standard/large text choice/result captures; KO/EN 1280×720 plus KO 960×600 fit | `StoryDialogueHistoryCheck.tscn`, `ManualSaveCheck.tscn`, then `--qa=story-dialogue-history --lang=ko/en` at 1280×720 and `--lang=ko/en` at 960×600 |
| Quiet-week compression and readable consequence contract: no-information Quiet weeks render no card or fixed delay while preserving economy/axes/calendar; meaningful Echo/bridge/result cards remain for explicit confirmation; month summaries clear stale weekly layers; the family notebook motive is literal and matched in KO/EN/JA; `WAVE` and `ECHO` remain distinct; fast-forward QA inputs are measured separately from required player inputs | `MotivationImprintCheck.tscn`, `ImmersionLoopCheck.tscn`, `--qa=motivation-imprint --lang=ko/en/ja`, `--qa=immersion-loop --lang=ko/en/ja`, then `--qa=demo-gamepad --lang=ko --pad=playstation --demo-build` and `--qa=full-gamepad --lang=en --pad=xbox` |
| Ten-slot manual saves: autosave/v3 compatibility, StoryMode prose/choice/result/timer resume, effect-once restoration, two five-row 960×600 pages, and local chapter-start fixtures at weeks 1/49/97/145/193 | `ManualSaveCheck.tscn`, then `--qa=full-gamepad --lang=ko --pad=playstation --write-chapter-saves` when regenerating slots 6–10 |
| Six-month audio dramaturgy: Knee family-home identity, uninterrupted family motif, paragraph foley, audible default room/human mix, exact goshiwon/convenience/office/hospital source identity, ten demo music keys, maximum one unscored root, KO/EN parity | `audio_source_audit.py`, `scene_audio_catalog.py`, `AudioAssetCheck.tscn`, `BGMContinuityCheck.tscn`, `GameAudioContractCheck.tscn`, then `--qa=demo-experience --lang=ko/en --demo-build` and `python3 tools/demo_experience_audit.py <ko.json> <en.json>` |
| Full-run audio ownership: all 1,603 events have one explicit intent, all 94 registered backgrounds have a reviewed profile, no localized prose inference or room fallback, two KO/EN representative 240-week traces cover five chapters, seven activities, and two endings | `python3 tools/scene_audio_catalog.py`, `python3 tools/full_run_audio_audit.py --output-dir build/qa/full_run_audio`, `BGMContinuityCheck.tscn`, then chapter-by-chapter human listening on headphones, laptop speakers, and living-room TV |
| Last-payment public office: `public_office` room tone, recorded queue ding-dong only after choice 0 result paragraph 0 begins, no waiting-description/locale-switch/result-rerender replay, provenance and stream present | `python3 tools/audio_source_audit.py`, `python3 tools/scene_audio_contract_check.py`, then `BGMContinuityCheck.tscn` |
| Opening job causality: cash-first and preparation-first submit no application and receive no week-two interview; job-first records exactly one application, never interviews in the same week, unlocks the Mapo interview only later while unemployed, and preserves post-interview `Keep Applying` | `CoreChoiceSliceCheck.tscn` plus `DemoBuildCheck.tscn -- --demo-build` |
| V2 release playtest flavor: three presets carry exactly `gangnam_demo,core_loop_v2_playtest`; retail/legacy Demo presets carry no playtest feature; release playtest exposes one dedicated 24-week entry while retail release exposes zero; window/title/global marker never lose flavor; settings, display, meta, autosave, and ten slots have a 14-path retail/playtest intersection of zero; no cross-flavor migration or fallback; `runtime_default=false` remains retail-owned | `PlaytestFlavorCheck.tscn -- --demo-build --core-loop-v2-playtest-build`, then `build.sh playtest`, native no-argument artifact boot, and KO/EN marker/entry inspection |
| Release identity, save compatibility, and third-party notices: full/demo/V2 share four canonical fields across StartMenu identity metadata, save metadata, and manifests while the visible label renders version/build/channel; incompatible saves remain visible but cannot load; Settings renders the generated engine 1 / font family 3 (6 files) / audio source 21 (139 files, attribution-required 1) ledger with Godot MIT, exact 4.6.2 bundled-component COPYRIGHT, three OFL texts, and D4XX/CC0 horse-file provenance reachable without a network link; focus returns to Settings after closing; fresh Full/V2 packs contain the exact ten notice/ledger files | `python3 tools/build_identity_audit.py --self-test`, `python3 tools/third_party_notice_audit.py --self-test`, then the same tool with both `--pack-zip` paths, `ManualSaveCheck.tscn`, `First30SecondsCheck.tscn`, and `--qa=third-party-notices --lang=ko/en` at 960×600 and 1280×800 |
| Save durability and the sealed V2 boundary: every slot write uses same-folder temporary bytes, exact readback and payload/slot/build-identity validation, then prepares a byte-identical verified backup of the prior valid primary before replacement. A temporary, backup, replacement, or final-verification failure preserves the prior primary and last verified backup and emits one failure; a retry emits one success and keeps the prior primary as the new backup. A missing or parse-corrupt primary may load only a compatible verified backup and restores the canonical primary bytes. Demo/V2 states above Week 24 and arbitrary turn-25 states are rejected before `GameState` mutation; the only V2 exception has source and target both `core_loop_v2_playtest/core_loop_v2_playtest_v1`, exact integer `turn=25`, exact completed Weeks `1..24` with no gap/duplicate, and strict typed completion receipts. It reopens the sealed Week-24 recap/CTA and never enables Week-25 input | `ManualSaveCheck.tscn`; `tools/audit.sh` must require exit 0, exact `MANUAL_SAVE_CHECK_OK`, and zero engine/script/parse errors in strict mode |
| ORDER-94 fresh Seoul Cycle Month One: only a newly generated V2 playtest run carrying durable `seoul_cycle_eligible_v1` provenance may enroll; a provenance-less old unplanned save, `month_one_episode_v1`, and legacy monthly plans stay on their original rules. The player receives four deterministic capacity pieces and allocates one each week among exactly four visible nodes—career, livelihood, people, recovery—while hidden world/fixed events stay outside the player node list. Preview/cancel is zero-delta; commit owns one weekly ledger; threshold follow-ups append without a second AP or duplicate effect; completed, expired, locked, featured-missed, and repeat-fallback states remain distinct through save/load. The three tutorial pages explain capacity → node → clock/scene without exposing future event identities. Keyboard, mouse, raw gamepad, KO/EN, Reduce Motion, 1280×800, and 960×600 agree | `python3 tools/demo_core_loop_v2_audit.py`, `CoreLoopV2CycleCheck.tscn`, `CoreLoopV2FirstEntryCheck.tscn`, `TutorialInputCheck.tscn`, `tools/run_core_loop_v2_input_qa.sh month-one-matrix`, and `tools/run_core_loop_v2_input_qa.sh surface-matrix`; automation proves ownership, routing, state, input, and fit only—the comprehension/fun verdict remains open until user play |
| Core Loop V2 Weeks 1–8 foundation: an enrolled run uses the same four-capacity/four-node grammar in both months, with month-specific labels, places, thresholds, deadlines, trigger windows, locked people branches, and world clock events. Each of eight allocations produces exactly one weekly commitment; hidden background routines are suppressed with zero gameplay effect; special work/action surfaces own their own result once; featured opportunities can expire exactly once while an explicitly authored generic fallback remains available; all decline producers have a later consumer; monthly summaries preserve actual allocations, node outcomes, missed opportunities, cash/body/mind, and next-month eligibility; no Week-9 legacy-planner fallthrough | `python3 tools/demo_core_loop_v2_audit.py`, `CoreLoopV2CycleCheck.tscn`, `CoreLoopV2FirstEntryCheck.tscn`, `tools/run_core_loop_v2_input_qa.sh full-matrix`, and `tools/run_core_loop_v2_input_qa.sh surface-matrix`; normal-speed memory/fun and physical-pad feel remain human gates |
| Week-4 temptation localization: KO/EN choice 0 names only the same observable actions (block the number, put the phone face down), never a moral self-declaration or judgment of choice 1; choice order, gameplay effects, flags, routes, and the `lent_account`-owned Week-8 clean/fallout split stay unchanged; localized overlays remain text-only | `python3 tools/demo_core_loop_v2_audit.py`, `python3 tools/i18n_coverage_check.py`, and `python3 tools/english_hangul_audit.py` |
| Legacy monthly-planner neutral activity types `[compatibility only]`: the authored internal `temptation` kind, event, effects, flags, Moral values, and follow-ups stay unchanged for already committed episode/legacy saves. That old surface keeps the ordinary `회복 / RECOVERY` label, rest icon, and colour and never reveals the internal temptation kind. Fresh Seoul Cycle runs do not use this planner in Months One through Six and are tested by the ORDER-94 rows instead | `python3 tools/demo_core_loop_v2_audit.py`, `CoreLoopV2Check.tscn`, and the dedicated old-save fixture in `CoreLoopV2FirstEntryCheck.tscn`; this row cannot establish fresh-path completion |
| Core Loop V2 Weeks 9–12 gate: Month Three presents exactly four Seoul Cycle nodes with unique work, place, deadline, and threshold semantics; the inventory-crew milestone opens the real inventory task, not a generic confirmation. The people node is locked with zero causally eligible threads, requires an explicit South choice for one ordinary candidate, preserves the existing `terminal_auto` only when one source-bound terminal candidate remains, and preserves every eligible thread in canonical order up to the current authored maximum of four; five candidates, non-record entries, and missing KO/EN label/detail fail closed. A terminal candidate ID, its authored target bundle, route, and variant remain separate identities through preview, explicit multi-candidate South selection, receipt, save/load, and the next scene. At 960×600 only the candidate list scrolls within a two-row viewport while the focused item, full detail/progress/deadline, and Commit remain visible; East before commit is state-free. The room-ledger/self node owns recovery and story exactly once; world events remain separate from player allocation. Weekly owner, action result, node progress, application/relationship receipt, featured miss, month summary, and save/load remain atomic; the 80,000-won repair, 2,000,000/1,500,000/3,000,000 cash facts, 310,000-won arrears, and 50,000-won inventory ledger stay exact | `python3 tools/demo_core_loop_v2_audit.py --self-test`, `CoreLoopV2CycleCheck.tscn`, the 0..4/malformed people-board fixtures and Month-Three segments of `tools/run_core_loop_v2_input_qa.sh full-matrix` plus `surface-matrix` in KO/EN at 960×600 and 1280×800; the first-meeting→player-pursuit feel remains a human gate |
| Core Loop V2 Weeks 13–16 gate: Month Four uses four nodes—interview/application/class, logistics livelihood, one causally eligible person, and health/housing self-care. Conditional career/people triggers resolve once with their exact week window, threshold, localized label/place, named owner, and contact axis and remain identical after normalize and save/load; unmet people paths lock instead of inventing a contact or recording a forgone choice. Existing Hanbit, Daeun, Jiyeon, Sangchul, and Jaehyuk prerequisites and exclusive groups remain authoritative; the logistics and housing actions own their effects once; Week 16 summary reaches Month Five without legacy-planner fallthrough | `python3 tools/demo_core_loop_v2_audit.py`, `CoreLoopV2CycleCheck.tscn`, `tools/run_core_loop_v2_input_qa.sh full-matrix`, and `surface-matrix`; normal-speed pursuit memory/fun remains a human gate |
| Core Loop V2 Weeks 17–20 gate: Month Five uses four nodes—next application/work preparation, moving livelihood, one waiting person, and an empty Sunday. The selected person branch preserves its prior contact and exact allowed week or locks; `daeun_shared_dream` can still feed Week 21 only from its legal Week-20 path. Hanbit hired/declined status, job_03, received-message receipt, 1,680,000-won first pay and 2,240,000-won later pay, Friday 18:00 City deadline, moving/spreadsheet action ownership, Month-Six response deferral, decline consumers, and Month-Five summary all remain exact and atomic | `python3 tools/demo_core_loop_v2_audit.py`, `CoreLoopV2CycleCheck.tscn`, `tools/run_core_loop_v2_input_qa.sh full-matrix`, and KO/EN surfaces; normal-speed conflict memory/fun remains a human gate |
| Core Loop V2 Weeks 21–24 audited-prefix gate: Month Six has four nodes—NCS/final practice, loading livelihood, an actually owed promise, and rest/walk—with conditional people paths locked when their prerequisites are absent. Week-21 Father signal and Week-22/23 application responses stay world-owned; Week-24 preserves dirty-account callback → First Bill opening/decision/ledger → eligible Hyunsu exam echo ordering without inventing an absent branch. Every allocation, follow-up, world receipt, selected/deferred/expired obligation, final pay, and successful completion autosave occurs exactly once; the 24-allocation recap separates spent time, partial progress, missed featured opportunities, and locked paths. A successful diagnostic CTA never calls `finish_run` or writes again; a failed-autosave South input remains on the same recap and owns only the explicit retry | `python3 tools/demo_core_loop_v2_audit.py`, `CoreLoopV2CycleCheck.tscn`, `CoreLoopV2FirstEntryCheck.tscn`, `tools/run_core_loop_v2_input_qa.sh full-matrix`, `surface-matrix`, and `CoreLoopV2CycleBalanceCheck.tscn`; normal-speed 75–95-minute memory/fun, physical pad, and continuous A/V remain W1–24 diagnostic gates |
| Father-memory closure and Week-24 receipt ownership: the three mutually exclusive Month-Three quiet-call memories each add one visible KO/EN paragraph to the guaranteed Week-21 Father health signal; the three mutually exclusive Week-21 responses each add one paragraph to the guaranteed First Bill opening. Gallery replay freezes that one Week-21 memory and never substitutes a later run's relationship state; an old schema-1 replay without the field uses base prose. Missing, wrong-character, legacy-flag-only, V1, and unreconstructable completed-save paths likewise infer no contact. The four police/recruiter choices preflight the collision-owned claimed receipt before any effect or result UI, keep their exact effects once, resolve only that exact source key, create zero new generic story-choice receipts, preserve injected old or same-root foreign receipts unchanged, and fail closed when their exact deferred owner is absent | `python3 tools/demo_core_loop_v2_audit.py`, `CoreLoopV2BCheck.tscn`, `CoreLoopV2ECheck.tscn`, `CoreLoopV2HandoffCheck.tscn`, `ManualSaveCheck.tscn`, and KO/EN `tools/run_core_loop_v2_input_qa.sh surface-matrix`; automation must report relationship `readerless=0`, Week-24 generic `write_only=0`, exact deferred owners/readers `2`, local effects `4`, and new events `0`. Whether the variations feel like a remembered relationship rather than a hidden score remains the ORDER-88 human gate |
| Twenty-Four Weeks in Seoul completion: the fresh boundary freezes Week-24 money, fixed expense, body, mind, housing/background, financial rung, temptation receipts, all 24 allocations, six month summaries, obligations, and unresolved threads before later live state can change. The first summary has no vertical scroll; North opens six month pages plus one unresolved page, LB/RB wraps pages, D-pad selects exact receipt rows, East returns, and South exits only after autosave succeeds. Each month keeps four global-week allocation rows, up to four outcomes, up to eight deterministically ordered scene receipts, and a missed record. Failed autosave retries on the same component instance and cannot escape; success unlocks the terminal CTA. A supported pre-snapshot completed save shows only reconstructable facts and marks every missing amount, state, week, relationship, callback, obligation, or event as `기록 없음 / NOT RECORDED`; it never reads the current HUD, fabricates a receipt, or falls back to the obsolete modal. KO/EN 960×600 and 1280×800 keep the summary, details, focus, and CTA inside the viewport | `tools/run_core_loop_v2_input_qa.sh surface-matrix` must end with exact `CORE_LOOP_V2_SURFACE_MATRIX_OK languages=ko+en resolutions=1280x800+960x600 cases=4` and covers snapshot immutability, retry, seven-page navigation, and legacy unknown/fallback fixtures; `full-matrix` covers keyboard/gamepad completion and one non-writing title CTA |
| Core Loop V2 title-to-24-week product route: preconfigured KO/EN title → opening/prologue → Chapter 1 → three-page Seoul Cycle tutorial → six monthly boards → 24 raw-input capacity/node allocations → every eligible threshold action and world event → five intermediate month summaries → First Bill opening/decision/ledger and only the causally eligible exam echo → exactly one successful turn-25 completion autosave → frozen summary → six month pages plus unresolved page → non-writing CTA → title and V2-entry rediscovery. KO/EN×keyboard/gamepad must each report six cycle plans, 24 allocations, suppressed routines 24, expected world/trigger receipts, `first_bill=1/1/1`, `autosave=1`, `title_return=1`, `mixed=0`, `semantic_events=0`, and `unknown_events=0`; settings/display/meta/autosave/slot paths remain inside each run's isolated absolute root | `tools/run_core_loop_v2_input_qa.sh full-matrix` must end with exact `CORE_LOOP_V2_FULL_MATRIX_OK languages=ko+en devices=keyboard+gamepad weeks=24 cases=4`; selectors may locate and focus controls by stable metadata, but activation uses raw `InputEventKey` or `InputEventJoypadButton` press/release. Direct schedule/choice/GameState assembly, `pressed.emit()`, semantic action injection, mixed-device rescue, and legacy `demo-experience` do not satisfy this gate. Packaged boot and physical Deck/pad feel remain separate gates |
| Core Loop V2 speaker knowledge and register: all 38 V2 speech-bearing surfaces partition into 29 speech/message contracts and nine reasoned solo-action exemptions; every base or choice-result speaker owns non-empty register basis and fact sources; no shared references, missing producer, future-only source, legacy forced backfill, Hyunsu/City calendar drift, numeric game-week labels in story prose, Week-13/14 Sangchul April drift, English `-ssi`, or false Tuesday follow-through on the late-meal-only path | `python3 tools/story_consistency_audit.py`, `python3 tools/demo_core_loop_v2_audit.py`, `python3 tools/speech_register_audit.py`, `python3 tools/i18n_coverage_check.py`, `python3 tools/english_hangul_audit.py`, then `--qa=core-loop-v2 --lang=ko/en` at 1280×800 and 960×600; the scope must include the pre-plan Send/interview/calculation plus Jiyeon, Father, City, Hyunsu, and first-bill story frames, not only the planner shell |
| Exact 24-week English voice pass: the dated ORDER-86 22-unit speaker→listener ledger recorded 72 events / 447 event leaves, 543 dynamic occurrences / 536 unique keys, and 147 activity lines. ORDER-88 later recorded an intermediate 73 / 471 / 686 / 657 localization snapshot, while the active `demo_rc` collector reports 72 / 467 / 730 / 701. Completion therefore requires an exact set/hash delta from ORDER-86 through the intermediate snapshot to the active population and a second read of every added or changed event, dynamic surface, and activity line; neither historical count can be relabeled as current evidence. The reconciled pass includes the pre-plan application, interview, calculation, mandatory three-slide first-planner tutorial, four Month-One primary traces, inventory task, convenience customers, resumes, mock interviews, messages, Father-memory returns, First Bill inline copy, and all unchosen result paths; Korean meaning, paragraph/token/choice shape, dates, times, amounts, effects, flags, and reachability stay unchanged; names hidden, the principal relationships remain distinguishable through sentence shape, directness, hesitation, contractions, and selective address; demo `oppa/-ssi` remain zero and `hyung` is contextual rather than counted | `python3 tools/demo_localization_scope.py --self-test --lang all`, `python3 tools/i18n_coverage_check.py`, `python3 tools/english_hangul_audit.py`, `python3 tools/speech_register_audit.py`, `python3 tools/story_consistency_audit.py`, `python3 tools/demo_core_loop_v2_audit.py`, `CoreLoopV2ECheck.tscn`, `StoryDialogueHistoryCheck.tscn`, then English `--qa=core-loop-v2` at 1280×800 and 960×600 plus `--qa=story-en` 1280×800 and `--qa=story-presence` 960×600; native or near-native random-three judgment remains `demo_en_voice_random_three` only after the reconciled 22-unit ledger is recorded |
| Core Loop V2 24-week survivability: the fresh Seoul Cycle balance owner must execute four named strategies—livelihood, advancement, people, recovery—and one deliberate high-cost fatal route through all real allocations, trigger/world effects, decline receipts, and six month settlements. It records exact monthly cash/health/mental/employment plus observed floors, never seeds later-week receipts or normalizes stats, and evaluates game over after due decline but before summary/CTA. The old 18 branch-only kernels and 48 routine units remain legacy/fallback regression only and cannot satisfy this row | `python3 tools/demo_core_loop_v2_audit.py`, `CoreLoopV2CycleBalanceCheck.tscn`, and `CoreLoopV2CycleCheck.tscn`; `tools/audit.sh` must require exit 0, exact `CORE_LOOP_V2_CYCLE_BALANCE_OK`, and zero engine/script/parse errors in strict mode. Exact trajectories and named baselines are owned by `docs/BALANCE.md` |
| Whole-won cash and funded opportunities: nearest won with signed `.5` away from zero, one settlement per transaction, integer serialization after retired-phone migration and repeated load, conserved loan/investment receipts, exact 19 choices / 15 events / 7 files, funded choice parity across MainGame/StoryMode/EventManager, zero-stake no RNG/state/cooldown/follow-up, two state-free KO/EN fallback exits, item-gated sibling handling, and safe new/override mod topology | `python3 tools/opportunity_money_audit.py`, `python3 tools/mod_pack_validator.py --self-test`, `MoneyIntegrityCheck.tscn`, `CoreLoopV2HandoffCheck.tscn`, `SimRun.tscn`, then `python3 tools/convergence_sim.py --runs 3000 --write docs/CONVERGENCE_REPORT.md`; exact W24/W48/W240 and policy bands are owned by `docs/BALANCE.md`.<br>`SimRun.tscn` records real metaprogression, so local runs must use a disposable `HOME` with `GANGNAM_SIMRUN_ISOLATED=1`; ordinary player HOME execution is rejected and CI gives the step its own HOME. |
| Core Loop V2 Year-One component carryover `[component-runtime PASS]`: all four unmodified turn-25 snapshots continuing through production GameState weekly actions and month processing plus the actual Week-27/31/36/42/48 Hyunsu/Year-One scheduler outcomes and the selected clean path's Week-28 City result; no date teleport during the carryover drive, no V2 routine effect or receipt after Week 24, no stat normalization, positive health/mental at every month close, exact Week-48 `arc_year1_close`; non-positive-cash cafe paths use the same production availability contract and state-free authored exit as the player surface | `CoreLoopV2HandoffCheck.tscn`; exact Week-24→48 cash/health/mental, observed floors, recovery weeks and monthly ledgers for all four paths are owned by `docs/BALANCE.md`; this is component-runtime evidence, not UI end-to-end evidence |
| Demo-save → full-build MainGame Week-25 continuation `[OPEN full-release/continuation blocker]`: after the W1–24 demo is promoted out of its isolated playtest namespace, its exact W24 CTA save loaded by the full build must preserve all 24 action receipts plus actual prologue/run-seen history, leave the CTA only in full flavor, restore the normal economy and controls, and enter Week 25 exactly once. Reloading the sealed playtest turn-25 diagnostic receipt or driving a legacy component snapshot to W48 is not handoff evidence | A real demo-flavor save created from the MainGame prologue through the W24 action, sixth settlement, First Bill and CTA must be loaded in a separate full-build process and driven through Weeks 25–28, preserving the eligible W25 result and W27/W28 receipts. The current isolated W1–24 playtest save cannot close this gate. This gate controls advertised continuation/full release support, not the W1–24 demo length or its human verdict |
| Seoul Cycle, legacy planner, and portrait contact phone: fresh enrolled Months One through Six use one full-screen four-capacity/four-node board. It shows exact progress, effects, deadline, world-clock position, locked/expired/featured-missed/repeat state; preview and East cancellation are zero-delta; South commits one legal pair; unavailable nodes leave the focus path; root East cannot bypass an unfinished week; saved unfinished boards reopen editable; finished history reopens read-only; the floating playtest badge is hidden while open and synchronously restored on close. The old three-step `Weeks → Routines → Final Review` planner remains only for already committed episode/legacy saves and preserves its old placement, routine, refund, and read-only contracts. The separate right-side portrait phone remains Messages/Contacts only; only `inbound_message|call_log` is conversation and only `phone|kakao|business_card` is reachable contact; device/store/finance/investment/leisure/game entry points remain zero | `PhoneSystemCheck.tscn`, `CommunicationPhoneCheck.tscn`, `CoreLoopV2Check.tscn`, `CoreLoopV2CycleCheck.tscn`, `CoreLoopV2FirstEntryCheck.tscn`, `TutorialInputCheck.tscn`, `tools/run_core_loop_v2_input_qa.sh full-matrix`, and `surface-matrix` |
| First-run language gate, KO default names, localized portrait name tags | `--qa=locale-gate` |
| Prologue motivation imprint: Knee, Last Payment, notebook choices, persistent goal sentence, notebook modal, montage, and month-end ritual | `--qa=motivation-imprint --lang=ko/en` |
| Legacy Tier-1 32-root regression (not current quality PASS): prior links, decision points, panels, quoted dialogue, KO/EN parity | `python3 tools/peak_scene_chain_audit.py --strict` |
| Chapter 1 temporal spine: exact Hyunsu exam→formal result→4/5/6-week aftermath/drift/new-path order, no legacy pivot duplication, hallway-local Minjun before remote Hyunsu messages/call, all goshiwon-goodbye choices entering the live-housing first night, survival-job office exclusion, exact 3,800-won beer effect, ambience-only music suppression, and KO/EN fit (8 shots per language) | `--qa=chapter1-spine --lang=ko/en` plus `DemoBuildCheck.tscn -- --demo-build` |
| Chapter 2 causal peaks: four three-link sequences, current-housing parents scene, message/phone presence, Jiyeon street/cafe and parents restaurant/home result backgrounds, matching result ambience, hospital enter/defer CG ownership, exact route flags, and KO/EN fit (18 shots per language) | `--qa=chapter2-peaks --lang=ko/en` |
| Chapter 3 temporal spine: four week-spanning narratives, earliest-target deduplication, two same-week deferred events presented one at a time, later-event preservation, live-housing messages/calls, remote/local presence badges, paragraph-owned score, Jiyeon departure, Jaehyuk mirrors, Father's debt truth, exact 120-week midpoint, year-three closure, and KO/EN fit (22 shots per language) | `--qa=chapter3-spine --lang=ko/en` |
| Late-chapter temporal spines: year 1.5→2, 1B→isolation, subway body signal→six-week review→eight-week doubt, year-four close→five-week reckoning→final year, 2B→2.5B order, current-housing private scenes, Hangang riverside, remote Father call, ambience/music ownership, and KO/EN fit (28 shots per language) | `--qa=late-chapter-spines --lang=ko/en` |
| Father peaks and wardrobe: Changwon hospital geography, corridor-local Minjun before Father's physical reveal, four visit/defer choices, ward CG only after an entered result, deferred route remaining in the corridor, patient gown in ward scenes, old home clothes in Changwon-home calls, current-housing last call, winter Seoul KTX platform, empty Changwon ward, canonical terminal effects, and KO/EN fit (24 shots per language) | `--qa=father-peaks --lang=ko/en` |
| Father 23-second KTX chain: Seoul-bound geography after Changwon Jungang, optional artifact-memory link, remote home-clothes memory inset, final call/no-call fit, unchanged terminal effects/flags, and KO/EN fit (8 shots per language) | `--qa=father-ktx --lang=ko/en` |
| First-kiss chains: Daeun's dawn convenience-store alley, Jiyeon's empty left-hand-drive sedan prelude, Jiyeon in the left driver seat and Minjun in the right passenger seat, no effects before the final choice, exact kiss/defer terminal effects, result pagination, and KO/EN fit (14 shots per language) | `--qa=first-kiss --lang=ko/en` |
| Jaehyuk peaks: hotel-pitch CG ownership, current-housing ghost/mirror continuity, two ghost buildup routes, two guarantee buildup routes, artifact-hidden 2/visible 3 choices, ten-second mirror decision, exact betrayal/guarantee terminal state, crossed-line scar clamp, and KO/EN fit (17 shots per language) | `--qa=jaehyuk-peaks --lang=ko/en` |
| Home peaks: continuous summer travel outfit and rural table, two stat-free Mother's Table buildup routes, paragraph-delayed night-bus CG, continuous Narrow Room CG/outfit/geometry, two stat-free room buildup routes, father-death/records-known text variants, four exact terminal states, and KO/EN fit (21 shots per language) | `--qa=home-peaks --lang=ko/en` |
| Prepared Japanese/Chinese arbitrary-character wrapping and 1280x800 safe area | `--qa=i18n-layout --lang=ja/zh-CN/zh-TW` |
| Splash, opening, StartMenu press-any-key, start menu, content notice | `--qa=start-en` |
| Archive CG silhouettes/fullscreen preview, hidden-name secrecy, and exact gallery replay integrity: 20 roots, 51 authored events (ordinary 48 + First Bill 3), conditional runtime maximum 52, first valid seen+snapshot atomic/write-once pairs, locale-neutral name/turn/moral/housing/selectors/choice indices, frozen 1·3·5-year portraits and seasonal audio, HUD/result-card zero, GameState/meta mutation zero, and seen-only/orphan/corrupt/direct-request fail-closed. First Bill additionally freezes both Month-Three ledger memories plus empty, normalizes an old missing field to empty, and rejects wrong type/value or mutually contradictory live flags | `GalleryReplaySnapshotCheck.tscn`, `CoreLoopV2ECheck.tscn`, `ManualSaveCheck.tscn`, `StoryPlaybackCheck.tscn`, then real-render `--qa=gallery --lang=ko/en`; the dedicated marker must report `roots=20 authored_closure=51 runtime_max=52 ... frozen=7 hud=0 mutation=0 m3=3+legacy` |
| Five year identities, year-scene curation, Y1 timed choice, Y5 week countdown, and ending five-scene recap | `--qa=year-identity --lang=ko/en` |
| Cast 1/3/5-year visual axis: turn windows 1-96/97-192/193-240, seven core identities, four Minjun job variants, relationship-stage independence, fixed hospital/wedding/season/romance/2020 portraits, missing-file fallback, and 21 face-safe anchors at 960x600 English and 1280x800 Korean | `CastVisualTimeCheck.tscn`, then `--qa=year-identity --lang=ko/en` |
| Steam store sequence: cold-open, money-mule timer, montage, time ledger, identical bright/dark scene pair, seasonal date CG, and five-scene ending recap | `--qa=store --lang=en` then `StoreScreenshotExport.tscn` |
| Active raster inventory and completed human verdict ledger for every CG, portrait, and background | `python3 tools/art_ai_audit.py` |
| Active raster dimensions, 1080p/4K cover enlargement bands, exact path baseline, and low-resolution regression ratchet | `python3 tools/art_resolution_audit.py` |
| Promoted high-resolution master provenance, official tool/model hashes, full-frame tile policy, three-or-more 100% crop verdicts, and exact runtime hash | `python3 tools/art_master_audit.py` |
| A/B/C narrative detail hierarchy: authored actors remain readable, anonymous extras alone become low-detail silhouettes, and wedding focus stays Minjun/Daeun/conditional Hyunsu | `python3 tools/cast_detail_contract_check.py` |
| Store trailer sources: 22 actual Godot surfaces covering goal, timer, tint, romance, rupture, time records, investment, and minigames | `--qa=trailer --lang=ko/en` at 1920x1080 |
| StoryMode/VN flashforward Black→arrival Gray reset, intro events, 1~4-choice lower dock, readable backgrounds, chapter card, scene direction framing | `--qa=story-en` |
| Story handoffs: outgoing background/portrait snapshot, memory dissolve, six-year matte time cut, explicit-move crossfade, no effect for same-location edges, prose/AUTO input lock, and opacity-only Reduce Motion fallback | `StoryPlaybackCheck.tscn`, then inspect the opening chain at 1280x800 in KO/EN |
| Restrained body/title/choice/state material at 720p, Steam Deck, and 4K | `TextMaterialCheck.tscn`, then `--qa=text-material --lang=en` |
| StoryMode non-CG Black/Gray/White luminance, forced-Black framing, same-scene perception prose, moral choice wording, portrait distance, result-attention order/counterweight preservation, and KO/EN crop | `--qa=story-moral --lang=ko/en` |
| Authored Moral Perception anchors: Daeun cafe, Sangchul mirror, guarantee bill, father's last call, and last signature across Black/Gray/White prose and choices (30 shots per language) | `--qa=moral-anchors --lang=ko/en` |
| Romance CG Gray/Black/White color hierarchy and no-HUD climax framing | `--qa=romance-cg` |
| Romance portrait outfit/scale against exact paired CG contract | `--qa=romance-portraits` |
| Namsan route cable car→restaurant→observation-deck paragraph backgrounds, paired portraits, lock CG intro/choices | `--qa=namsan --lang=ko/en` |
| Amusement routes: parade→helping CG/result fork, coaster→correct booth→choice-only four-cut CG, KO/EN crop and expression continuity | `--qa=amusement --lang=ko/en` |
| Daeun hometown route: interior train→separate maternal dining room→delayed night-bus result CG, summer outfit and KO/EN crop continuity | `--qa=hometown --lang=ko/en` |
| First nights: 3-link/2-decision heroine-specific buildup→four terminal state paths→tasteful fade→paragraph-delayed morning CG, same home/outfit, late-game month HUD, KO/EN 16 shots each | `--qa=wedding-morning --lang=ko/en` |
| Seasonal romance peaks: four 3-link/2-decision routes, KTX→East Sea/Haeundae and pre-launch Hangang→first explosion transitions, state-free buildup, final-only CG/effect/audio, ten exact terminal states, and KO/EN fit (30 shots per language) | `--qa=season-peaks --lang=ko/en` |
| Daeun's first night: 3-link/2-decision buildup, live goshiwon/oneroom housing continuity, one convenience-store outfit and identity with expression-only acting, no indoor rain particles, continuous `rain_room`/`intimate` playback, unchanged two terminal states, and KO/EN fit (9 shots per language) | `--qa=daeun-first-night --lang=ko/en` |
| Sangchul first meeting: early-spring real-estate office, 3-link/2-decision measure/coffee buildup, no state before the final three answers, unchanged terminal stats/cast/Changwon seed, exactly one real business-card grant per answer, continuous office ambience with no villain score, physical-pad `ui_accept` routing, and KO/EN fit (12 shots per language) | `--qa=sangchul-first-meet --lang=ko/en` |
| Sangchul deduction: live goshiwon/oneroom/apartment housing, same-night tired/casual portrait continuity across both evidence routes, certificate/archived-business cross-checks, state-free buildup, 15-second final decision, exact confirm/defer state and clue flags, dynamic housing ambience, final-only `reckoning`/reveal, two controller-only completions, and KO/EN fit (12 shots per language) | `--qa=sangchul-deduction --lang=ko/en` |
| Sangchul casino invitation: live goshiwon/oneroom/apartment housing, remote message→local internal thought→reply grammar, people/cost routes, state-free buildup, exact accept/decline states, accepted-only ticket and explicit bus arrival, exterior in-person reset, continuous housing ambience with no villain score, two controller-only completions, and KO/EN fit (14 shots per language) | `--qa=sangchul-casino --lang=ko/en` |
| Hyunsu reunion: live goshiwon/oneroom housing messages, remote accounting portrait, photo/memory routes, knocked-versus-waited conditional callback, state-free buildup, explicit `gukbap_restaurant_night` arrival with no barbecue grill/food/brand/named proxy, full in-person reset, exact two terminal outcomes, one physical business card only after meeting, continuous home silence then cafe/intimate audio, two controller-only completions, and KO/EN fit (12 shots per language) | `--qa=hyunsu-reunion --lang=ko/en` |
| Commitment scenes: Daeun's three-link last-cup→next-year→proposal buildup; four-link mother reaction→groom-side state→groom-enters-first/bride-enters-later couple wide→couple close wedding; mother honju hanbok, Father honju suit, living/passed Father × Hyunsu-alone variants, truly empty reserved chair and no invented spouse/child; only Minjun/Daeun identifiable in couple frames; no premature marriage flags; final accepted delayed CG/no-CG defer branch; exclusive small/full wedding choice persistence; legacy small fallback; and Jiyeon's three-link pre-decision class-gap chain with final-only cost/flag effects (38 shots per language) | `--qa=commitment --lang=ko/en` |
| Romance ruptures: two state-free buildup paths per heroine, canonical married homes, Daeun offscreen in the kitchen, artifact-locked 2/3-choice finals, six exact terminal states and endings, non-separating branches with no leaked CG, and paragraph-delayed seal/departure CGs (28 shots per language) | `--qa=breakup --lang=ko/en` |
| First snow: December-only store/car prelude→paragraph-1 CG, winter outfits, exactly two cans, left-driver/right-passenger seating, resting wipers, gaze and KO/EN crop | `--qa=first-snow --lang=ko/en` |
| Climate portraits: monsoon rain shell, heatwave short sleeves/cooling towel, cold-snap parka/scarf and dedicated frozen street | `--qa=climate --lang=ko/en` |
| Event visual contracts: seasonal Minjun clothing, rainy room/street split, road-facing wallet bus-stop bench, visible bungeoppang cart, full-scene Seollal bow CG, year-close wardrobe, father phone location, split cafe identities/name tags/paragraph reveal, choice-result location/ambience, and flag-dependent character stages | `--qa=event-visuals --lang=ko/en` |
| Story presence contracts: the 2020 Knee flashback uses the age-57 `father_past`; remote present-day Father/contacts use a compact call or memory inset instead of standing in the current room; local message reactions keep Minjun full-size; in-person scenes reset to the normal portrait; English channel/name labels contain no Hangul | `StoryPresenceCheck.tscn`, `StoryTutorialPlacementCheck.tscn`, plus `--qa=story-presence --lang=ko/en` |
| Weekly immersion loop: season/housing opening line, one-to-three-week authored-arc omen, reachable bills/reserve/wealth rung, uncovered-bills crisis, action-causal StoryMode frame, and preserved notebook motive | `--qa=immersion-loop --lang=ko/en` plus `--qa=motivation-imprint --lang=ko/en` |
| Curated random foreground and causal bridges: exact foreground 64 / one-choice bridge 19 / causal producer root 7 sets, with the roots split into six implicit bridge-only roots and one hybrid delayed-harvest root; includes the fallback-only goshiwon rent reminder that never crowds an eligible causal callback, demo bridge count 0, no multi-choice auto-commit, one deterministic post-demo state callback, no duplicate history/effects, and KO/EN full-route bridge parity | `python3 tools/event_director_audit.py`, `EventDirectorCheck.tscn`, `ImmersionLoopCheck.tscn`, then `--qa=full-gamepad --lang=ko/en` |
| Main AP full-height in-world stills, Seoul Trace visited/locked nodes, warning state, people pressure grind hints, routine/date, Work/Money/Self-Dev/People/Life modals, four-scene gambling selector, market/info/keepsake surfaces | `--qa=ap-en --lang=ko/en` |
| Scene-first Act 1~5 commitment stage, actual KRW 500K first-month horizon, post-first-interview `Keep Applying`, NOW/COST/LATER, three scene-backed choices, cancel-safe submodals, result persistence until confirm, focused-card background preview, contextual home/transit/work/outdoor contact scenes, and direct advance without an AP board or Next Week button | `--qa=ap-act-en --lang=ko/en` |
| One-time investment terminology/risk guide, controller default focus, then Trade/Holdings/Market movers/Bank pages in Korean and English | `--qa=invest-en --lang=ko/en` |
| Demo boot surfaces, t=1~8 story chain, AP loop, month summary, demo ending CTA | `--qa=demo-blackbox --lang=ko/en --demo-build` |
| Full demo input route: real confirm inputs through StoryMode, choices, AP, results, month summaries, and the week-24 CTA | `--qa=demo-input --lang=ko/en --demo-build` |
| Full 240-week controller black box: title, opening, five chapters, all scheduled week kinds, monthly summaries, authored roots, one pad-selected causal producer and its exact later bridge, AP, and the actual ending with zero keyboard/mouse input | `--qa=full-gamepad --lang=ko --pad=playstation`, then `--qa=full-gamepad --lang=en --pad=xbox` |
| Chapter 5 M49~M55 product route: exact 19 roots/47 choices, direct-week ownership, W210 same-week order, W216/W220 conditional receipts, save/load and tamper fail-closed, KO/EN parity, M55 meeting CG crop and no black/HUD layer; automation is not the causal-reader or fun verdict | `python3 tools/chapter5_causal_route_audit.py`, `Chapter5CausalRouteCheck.tscn`, `ManualSaveCheck.tscn`, then targeted `--qa=full-gamepad --lang=ko/en` chapter-5 fixtures at 960×600, 1280×800, and 1920×1080 |
| Chapter 5 M56~M60 safe finale: 11 authored roots/30 choices and one-run 9/24, exact father-life variants, four M57 filing materials, M59 economic zero, W240 signature→Daeun same-turn outbound, atomic save/tamper closure, immediate failures first, under-goal W240 close, and unchanged 33-year `instant_legend`; automation is not the density/fun verdict | `python3 tools/chapter5_finale_route_audit.py`, `Chapter5FinaleRouteCheck.tscn`, `ManualSaveCheck.tscn`, `EndingRouteIdentityCheck.tscn`, then targeted `--qa=full-gamepad --lang=ko/en` W221/W227/W230/W235/W240 fixtures at 960×600, 1280×800, and 1920×1080 |
| Demo month summary, demo ending CTA, 6-month Time Ledger card | `--qa=demo-end-en` |
| P0 final-life endings: eight exact CG owners, 950x430 crop, Jiyeon reflection-only mirror with exactly two non-duplicated actors and coherent gaze, 1B Second Love across-river home, Jiyeon-mediated Gangnam framing, White/Deep Black readability, and KO/EN first viewport | `--qa=ending-p0 --lang=ko/en` |
| P1 final-life endings: exact CG owner/crop, Late Call memory, Rich and Alone base/divorce/no-leak, One More Circle base/Father-memory calendar action, distinct Bankruptcy/Debt Spiral calculation states, Startup Exit base/first-user memory, 33-year-old first-year Myth arrival, Orthodox Pinnacle base/salary-memory company-dinner pause, Burnout first-person emergency-bed hand/IV/phone composition, Stable Success's modest Seoul-room relief CG, and Mental Collapse no-leak | `--qa=ending-p1 --lang=ko/en` |
| Train semantics: summer/date and Father-call scenes remain inside the train, while the holiday decision remains on the provincial platform | `--qa=transport --lang=ko/en` |
| Representative ending modals, graded CG/card surface, exact Burnout/Stable Success CGs, dedicated symbols for Ordinary Life/Mental Collapse, fallback mood cards, and final Time Ledger card | `--qa=endings-en --lang=ko/en` |
| Title collection and meta-title reward surface | `--qa=title-en` |
| Tutorial overlay surface and onboarding copy | `--qa=tutorial-en` |
| Job hunt/career modal: four resume questions with best answers distributed across left/center/right, top-only route below Grade A, three equal-width left-to-right 14px cards, hover/focus sync, keyboard/pad movement and confirm, post-result AP focus restore, dedicated uncropped 1881×210 resume/interview strips, KO/EN 960×600 fit | `InputMatrixCheck.tscn`, then `--qa=job-en --lang=ko/en` at 960×600 |
| Part-time shifts: cards, convenience customer→response→next-customer controller focus loop, no focus theft on another-customer timeout, delivery route, mode-specific background/ambience, KO/EN crop | `--qa=aruba-en --lang=ko/en` |
| Event-scene text size + language + Music/Ambience + SFX + Reduce Motion, dedicated Menu input, timed-choice pause/focus restore, result no-replay, and no stream restart | `StoryAudioSettingsCheck.tscn` plus `--qa=story-audio --lang=ko/en` at 1280x720 and 1280x800 |
| Casino/minigame UI, direct controller cursors, physical stages, activity ambience, and phase-locked Jeongseon floor/table motif | `game_audio_contract_check.py`, `GameAudioContractCheck.tscn`, `BGMContinuityCheck.tscn`, then `--qa=casino-en` |
| Keyboard casino labels and longest English stake text | `InputMatrixCheck.tscn`, then inspect `10b_blackjack_keyboard_hint` from `--qa=casino-en` at 1920x1080 |
| Moral ambience: inert room tone persists, human presence recedes at Black and returns at White without music or UI disclosure | `MoralAmbienceCheck.tscn` |
| Racetrack bet→gate→gallop→crowd rise→finish and controller-only round trip | `SmokeRace.tscn` then `--qa=racetrack-en --lang=ko/en` |
| Moral tint/filter, choice echo, and same-room five-stage Minjun threshold acting | `--qa=moral --lang=ko/en` |
| Scene transition only | `--qa=transition` |
| Broad Steam Deck English regression | `--qa=surface-en` |

Command template:

```bash
/Users/junheelee/Downloads/Godot.app/Contents/MacOS/Godot \
  --rendering-driver opengl3 \
  --resolution 1280x800 \
  res://tools/ScreenshotQA.tscn -- --qa=start-en
```

Automated onboarding gates:

- `LocaleSurfaceCheck.tscn` must render the bilingual first-run language gate, enter the selected locale, localize canonical KO/EN save names, and return Jiyeon/Daeun portrait names in the active language.
- `I18nInfrastructureCheck.tscn` must keep `ja`, `zh-CN`, and `zh-TW` hidden from shipping selection while proving alias normalization, KO/EN byte-preserving `ui_context`, the exact community-context → community-legacy → built-in-context → built-in-legacy → English lookup, `context:<id>` miss dedupe/reset, complete English event/ending/catalog fallback, non-Korean date/housing/money surfaces, and actual bundled-font glyph coverage reporting. `ModLayerCheck.tscn` must additionally prove old Korean-key packs keep priority, new explicit context rows win, refresh reloads both provenance caches, and localized default player names still round-trip. Both Chinese routes must report blocked while their dedicated paths are empty; shared Han displayed by the JP-first fallback is not SC/TC readiness.
- `FontRoutingCheck.tscn` must keep KO/EN on Pretendard primary and `ja` on Noto Sans JP primary, with exact regular/semibold/bold weights `400/600/700` and bundled emoji last. It must shape representative hiragana, katakana, kanji, and Japanese punctuation through one Noto RID, reject the variable font's Thin `wght=100` default as a UI role, prove a live locale switch mutates the same shared role resources, and reject direct product font loads outside `FontKit`. A glyph-presence pass alone is insufficient because it cannot detect mixed-font kana/kanji.
- `i18n_coverage_check.py` keeps English strict and prepared locales in empty-skeleton mode. Its current prepared-language `--strict` scans all 1,758 packaged events (1,603 shipping + 155 author-only) and 35 endings, so a pass contains but is not identical to the 1,603-event shipping release claim. It is not evidence for the 24-week demo and must pass before that code is added to `SHIPPING_LANGUAGES`.
- `multilingual_surface_audit.py` rejects malformed locale/catalog files and Korean text leaked into target values. Korean source strings are allowed only as keys in `ui_<code>.json`.
- Preserve the ORDER-96 context-migration baseline as historical evidence: 3,254 static UI calls, 2,730 legacy Korean keys, the disjoint `34 formatting + 45 shared + 28 split = 107` partition, and exactly `legacy 3,217 + context 37` with 30 IDs across 37 owner call sites. The current manifest must separately lock the reached `29 formatting + 44 shared + 27 split = 100` partition and 29 context IDs across 34 calls; later inventory changes may not rewrite the historical baseline.
- The current active-candidate UI inventory is exactly `3,320 calls = legacy 3,286 + context 34`, 2,821 unique legacy Korean keys, and 29 reached context IDs. Japanese must be `legacy 2,821/2,821 + context 29/29 = 2,850/2,850`; both Chinese skeletons must be `legacy 0/2,821 + context 0/29`. Raw locale JSON keys must be unique before effective dictionary counting. Japanese prose scopes remain held until the approved 24-week source text is declared final.
- The parameterized registry must remain `56 raw = migrate 48 / 42 templates + dynamic pair reader 4 + branch-selected literal 2 + locale money formatter 2`. It must reject missing, extra, duplicate, stale, or selector-partial path/function/KO/EN/signature/count rows. The Aruba status parent and GameState year-choice quote are two supplemental existing lookup-before-format provenance rows outside raw 56, so runtime must contain exactly 50 `ui_format` calls, not 48, 49, or 51; the separate raw-migration argument-provenance registry must contain exactly 15 rows.
- `ui_format` must prove independent KO-template/KO-args and EN-template/EN-args validation, KO and EN authored-byte preservation, target/community hit with target args, miss with explicit English args, stable-template miss dedupe/refresh, and fail-closed invalid percent, argument kind/count/order, localized conversion-order, semantic-modifier, and newline cases. A target template matches the Korean conversion kinds/order, explicit positive-sign/precision semantics, and newline count; source KO and EN arity need not match, while width and zero-padding such as `%d` versus `%02d` may differ. Nested money or copy producers must not reuse an active-locale result as an English fallback argument.
- Exact whole-won ownership is limited to `CommitmentTask::_format_money` and `SeoulCycleBoard::_format_money`, both delegated to the one locale formatter. Target checks must keep the exact integer, sign, and commas; CommitmentTask preserves its signed English `KRW` prefix policy, SeoulCycleBoard its `won` suffix, and JA/zh-CN/zh-TW use `ウォン/韩元/韓元`. These two owners are not new template keys.
- `demo_localization_scope.py` must derive the actual 24-week union from runtime sources and lock exactly 72 visible events, 467 event text leaves, zero endings, 730 dynamic KO/EN pair occurrences with 701 unique Korean lookup keys, and four visible market asset names. The 467 event leaves, 701 unique dynamic keys, and four catalog names form exactly 1,172 unique demo translation sources. The dynamic union must include the pre-plan application and 125-year scene, all six title/body pairs in the mandatory three-slide first-planner tutorial, all four Month-One decision verbs and all four primary traces, the inventory task's 32 contract pairs, and all occurrences reachable through the specialized convenience and rain-delivery shifts, resume writing, mock interview, and the convenience close vignette, while excluding Aruba's unreachable legacy card pools. It must include the prologue closure and Chapter 1 card, count `callback_escaped_dirty_trace` only as an internal receipt/source, reject direct English bypasses for prepared locales, and keep `ja`, `zh-CN`, and `zh-TW` out of shipping. Skeleton mode reports missing work without failing KO/EN CI. Japanese `--strict` must pass before a Japanese demo claim.
- Exact-minute clock text is permitted only when `demo_localization_scope.json` declares the reachable source path, localized literal, canonical time, exact occurrence count, and reason. `demo_prose_style_audit.py` must reject a missing, stale, duplicate, or count-drifted permission and must not treat a written-out Korean clock phrase as an undeclared escape hatch.
- The English voice contract lives only in `docs/I18N_GLOSSARY.md` under `영어 인물 목소리 — 화자→청자`. Its 22-unit application ledger must include unchanged lines as PASS as well as edited lines with before→after evidence; no sentence-length, contraction, politeness, or address ratio can substitute for the second read. Dynamic message duplicates must agree with their event overlays, and one failure in the native or near-native random-three sample reopens the full 22-unit review.
- `zh_translation_audit.py --strict --lang zh-CN/zh-TW` is a separate claim gate for each region. It must require all 2,821 legacy static UI keys and all 29 context IDs in addition to the exact 72 events / 467 event leaves / 701 dynamic keys / four catalog names, totaling 1,172 unique demo translation sources; an otherwise complete body with English-fallback UI must fail. The workflow requires direct Korean-source translation and forbids OpenCC cross-region generation. A pinned OpenCC 1.3.1 character dataset is used only as an offline classifier, never to produce or rewrite target text: it rejects all 4,093 context-unambiguous Traditional-only candidates in `zh-CN` and all 3,804 context-unambiguous Simplified-only candidates in `zh-TW`, while identity/overlap forms remain for phrase rules and mandatory native context review. Both regions also reject noncanonical CJK compatibility ideographs and Han variation-selector sequences without rewriting them. The audit rejects detectable Hangul, kana, untranslated English prose, invented Han-character names or adjacent aliases, placeholder/paragraph drift, yen/yuan conversion of Korean won, and meaning changes in signed values, dates, times, durations, calendar versus duration months, counts, ordinal units, ticket identifiers, Korean native-number expressions, actual demo classifiers, and colloquial ten-thousand-won amounts. Current `legacy 0/2,821 + context 0/29 · 0/72 · 0/467 · 0/701 · 0/4` coverage, 13 broad production-runtime English branches, the missing Chinese AUTO character-rate route, and both missing regional fonts are expected strict failures, not evidence to relax the gate. The manifest lookup audit's narrower `direct_english_bypass=0` does not override the broad runtime count, and an automated strict pass does not replace native review of context-dependent shared characters.
- `ja_translation_pipeline.py --scope demo --inventory` must report `467/701/4/0` event text, dynamic keys, catalog names, and endings, representing 1,172 unique demo translation sources. Declaring the approved 24-week source text final may unlock only this non-destructive merge; full generation collects all 1,758 packaged events (1,603 shipping + 155 author-only), 35 endings, and the complete catalog and requires a separate full-game approval. After context and template migration, `ja_translation_audit.py --scope ui` must accept the 2,821 legacy static keys, the exact 29 reached context IDs, and only the 701 manifest-locked dynamic keys beyond them; `--scope demo` must reject empty or source-invented target fields even in skeleton mode. A one- or two-character Korean source such as `돈` must not pass with an English-only target unless an explicit canonical exact mapping authorizes it.
- ORDER-97 L3 remains OPEN with no completion evidence on active `demo_rc` BUILD `2026.08.22.1`. On that exact candidate, the user chooses three distinct actual surfaces from Batch A's 23 calls and three from Batch B's 24 calls. One wrong fallback, value language, placeholder result, byte-preservation result, or context meaning rejects that whole batch rather than only the sampled row. Automated inventory, self-tests, screenshots, or key parity cannot mark either gate done, and neither OPEN gate is a final surface/full-audit/CI claim.
- `ScreenshotQA --qa=i18n-layout --lang=ja/zh-CN/zh-TW` must wrap the QA-only CJK paragraph without clipping or covering the footer at 1280x800. The JA capture must use the same `FontKit.ui_regular()` role as the product and visually retain one Noto Sans JP weight across kana and kanji. This proves only the synthetic paragraph, not the real planner, phone, dialogue history, First Bill, or CTA. An OS-provided glyph fallback is not sufficient for release; the font must be bundled through `FontKit` and the real translated surfaces must be captured separately. A Japanese font displaying shared Han is likewise not Chinese release evidence: the active SC/TC chain must win before JP and pass Windows, macOS, and Linux/Steam Deck glyph checks.
- Japanese remains a hidden beta even after the UI/font checks pass. After the prose hold is explicitly lifted, all 72 demo events and legal choices, planner/phone/opening/name surfaces, four market asset names, and layout captures require strict coverage. A Japanese native reviewer must compare the Korean source directly against the same `demo_rc` at normal speed and through replay; key parity cannot approve voice, relationship distance, subtext, KRW weight, causal meaning, or translationese. This demo claim remains separate from full-game Japanese release coverage, but it blocks the combined four-language public demo until approved.
- Simplified and Traditional Chinese remain two hidden preparation targets. A Mainland Chinese native reviewer may approve `claim:zh-CN-demo`, and a Taiwan native reviewer may approve `claim:zh-TW-demo`, only after that region's full strict audit passes. Each reviewer must compare Korean against the same `demo_rc` at normal speed and replay all 72 legal events and every choice/result, judging character voice, relationship distance, implication, aftertaste, Korean-culture explanation, KRW weight, regional glyph forms, and actual line breaks. Each regional gate also blocks the combined four-language public demo; Korean/English development candidates may still be tested while translation is incomplete. Neither demo GO authorizes full-game Chinese coverage or premature shipping-language exposure.
- `TutorialInputCheck.tscn` must reject the held Enter/South that opened the overlay, key echo, and a second held press; after release it advances exactly one slide per fresh accept, never activates an underlying action, dismisses cleanly, and restores the previous focus. The three pages explain only `이번 달 여력 확인 → 한 노드에 배치 → 도시 시계가 장면과 기한을 움직임`; they do not expose later-week identities, imply that capacity values are random rerolls, or describe the legacy three-step planner as the fresh rule. `CoreLoopV2FirstEntryCheck.tscn` also proves Q/E and both shoulder buttons cannot change the board behind the overlay. Core Loop V2 records `tutorial_shown` only after the last slide completes, so cancel or parent teardown can show it again. Both run inside `tools/audit.sh`.
- `StoryTutorialPlacementCheck.tscn` must drive the real `story_knee_witness` forced choice through its result and authored follow-up without any StoryMode tutorial modal, while proving that the first AP dashboard still explains assets, health, and mental strength. It runs inside `tools/audit.sh`.
- `StoryPlaybackCheck.tscn` must start normal StoryMode in AUTO and read-only replay in manual mode without letting replay overwrite the session preference. AUTO may carry prose, results, and one-choice authored actions, but it must remain parked at every real choice, timer, and chapter handoff; keyboard `A` and gamepad North are toggles, never surrogate choice inputs. When another authored arc is already due, the StoryMode return must remain fully covered and enter that arc without flashing the MainGame/AP shell. It must execute the authored `memory_cut`, `time_cut`, and `explicit_move` follow-ups with a preserved outgoing frame, hold prose and AUTO until the handoff ends, keep all `same_location` edges effect-free, and reduce the handoff to a 0.24-second opacity fade when Reduce Motion is enabled.
- `first_session_pacing_audit.py` locks the fresh V2 opening to one exact fifteen-event sequence across all 432 identity paths: the legacy app-open follow-up is replaced by the actual Send scene, then the reserved interview, 125-year return, and Chapter 1 card run before planning. It caps the route at 110 text-panel paragraphs and 220 fast-path inputs; the current observed maxima are 102 and 212. Cinematic playback leaves exactly eight manual Story stops and auto-carries seven direct actions. It also checks KO/EN choice parity and rejects placeholder-only choices or oversized paragraphs.
- A fresh Core Loop V2 entry must keep one continuous queue in this order:
  `story_flashforward` and its prologue chain → the V2-only
  `v2_opening_application_send` scene (replacing, not following, the legacy
  app-open card) → `arc_intro_01_meal` → `v2_opening_return_math` →
  `chapter_card_33` → the Month-One planner and its three tutorial pages.
  `CoreLoopV2FirstEntryCheck.tscn` must prove that the interview owner does not
  exist before Send, becomes one `presented` consequence receipt after Send,
  turns `consumed` once after both roots, survives a mid-queue save, and never
  replays on MainGame re-entry.
- The opening comparison is exactly `30억원 ÷ 세전 월 200만원 = 1,500개월 =
  125년` in Korean and the same quantities in English. It may not claim a net
  salary, living-cost forecast, investment return, or guaranteed route. Its two
  choices are expression-only: choosing either must leave the serialized public
  state, tendency, `mindset_*`, route, and every non-presentation receipt
  unchanged.
- Fresh Month One must show exactly four player nodes—`m1_resume`,
  `m1_convenience`, `m1_father`, and `m1_recovery`—after the pre-plan application
  reaches `submitted/interviewed`. Their labels describe this week's concrete preparation,
  work, contact, or rest rather than pretending a multi-week progress clock is one meal.
  `m1_mirae_application` stays hidden because it already happened, while
  `hyunsu_first_meet` and `first_temptation_boss` remain world/fixed owners outside the
  four player nodes. A schema-3 save with an already committed old Month-One Mirae
  action must retain that card, spend its original week once, and attach the
  interview+calculation as its Week-Two scheduled prelude rather than the
  producer week. V1 and 25–240-week legacy scheduling remain available.
- V2 initialization must write exactly three durable `superseded` receipts for
  `callback_mindset_saver_echo`, `callback_mindset_investor_echo`, and
  `callback_mindset_founder_echo`. Hybrid saves preserve their original flags,
  tendency dictionary, and realized tendency byte-for-byte through save/load,
  while EventManager keeps all three callbacks ineligible at Weeks 24, 48, and
  240. V1 retains all three legacy flag-driven callback behaviors unchanged.
- `MotivationImprintCheck.tscn` must prove the exact nine-link Knee→Last Payment→Father→Notebook chain, all nine identity choices and serialized flags, nine KO/EN memory readers, three persistent notebook motives, and Father contacts at weeks 11, 15, and 21.
- `tools/audit.sh` must print `MOTIVATION_IMPRINT_OK chain=9 identity=9 readers=9 motives=3 father_contacts=3`.
- `ScreenshotQA --qa=motivation-imprint --lang=ko/en` must render the three identity-choice surfaces, the full persistent notebook sentence on the AP goal bar, the no-scroll notebook and montage modals, and the visible month-end ritual at 1280x800.
- `peak_scene_chain_audit.py --strict` preserves the old 32-root expansion baseline through
  actual `follow_up_event` paths. It must not regress, but its old 2~4-link/quoted-dialogue
  rule is not the current T1 quality gate. Functional dramatic-beat profiles are migrated
  separately under `SCENE_TIER.md`.
- Demo ending ScreenshotQA fails when the record requires vertical scrolling; the wishlist, restart, and main-menu actions must remain in the first 1280×800 viewport in both languages.
- `DemoBuildCheck.tscn -- --demo-build` must keep full and demo export presets separate, execute the canonical t=1~8 arc chain with real choice effects/follow-ups, permit week 24, and stop before week 25. It must also lock Hyunsu's data gates at exam week 24 and formal result week 25. `tools/audit.sh` must print `DEMO_BUILD_CHECK_OK feature=gangnam_demo cutoff=24 chain=7 presets=6`.
- `ScreenshotQA --qa=demo-blackbox --lang=ko/en --demo-build` is the visual companion gate. `--demo-build` is mandatory because Godot custom export features are unavailable while running from the editor.
- The demo black-box gate must keep every AP card inside the 1280x800 viewport with normal and bonus AP, and the final record must say week 24 while rejecting any visible week-25 copy.
- `ScreenshotQA --qa=demo-input --lang=ko/en --demo-build` must complete all 24 playable weeks using actual `ui_accept` input, preserve the authored opening chain, forbid the retired generic first-workday and premature career-specialization scenes, and end at the wishlist CTA without a transient AP overlay or toast.
- The same route must use the visible three-card demo pressure stage rather than repeatedly opening the fallback catalog, record both money and human weeks, and ignore embedded minigame cards whose own real-input suites are responsible for their internals.
- `ScreenshotQA --qa=demo-gamepad --lang=ko --pad=playstation --demo-build` and `--lang=en --pad=xbox` must boot from the language-aware title, cross the JUNPAC splash and opening, finish all 24 weeks, and stop at the week-25 CTA with zero keyboard/mouse events.
- The gamepad routes must begin unemployed, execute the visible primary `Job Hunt`, finish employed, use zero `See Other Actions` fallbacks, and consume every AP actually granted. Monthly crisis penalties or bonuses may change the budget, so the assertion is `used == available`, not a hard-coded 48.
- They must sample exactly 24 scheduled week kinds, expose 8-10 direct Decision/Boss weeks, exactly two Bosses, 3-5 Echoes, and a rendered no-input beat for every observed Quiet/Echo week. AP input on an auto week fails. The route must show exactly three full month summaries while reaching month 7, proving all six monthly economies ran.
- The base slice schedules nine direct weeks (seven Decision plus two Boss), four Echoes, eleven Quiet weeks, and three summaries. Authored StoryMode choices own weeks `4/10/13/16/20/23/24`, so the base contract remains two generic AP commitments plus seven authored commitments, never a second AP choice after those scenes. A live health, mental, or cash crisis may promote one otherwise automatic week and must be reported rather than normalized away; the current causal first-job route therefore records three generic plus seven authored commitments across ten direct weeks. Week 4 is delayed; immediate authored results must not claim that nothing has arrived. The week kind is locked in serialized run state before any StoryMode round trip or automatic routine can change crisis inputs. Latest reachability references are KO PlayStation 630 and EN Xbox 634 fast confirms across the same 46 events, with ten total commitments, four exact Echoes, and zero keyboard/mouse events. Default cinematic playback reserves only 36 Story stops: 35 meaningful choices plus one chapter handoff. Both numbers are regression evidence, not a fun verdict; a fresh normal-reading replay remains mandatory before release approval.
- A direct-week card may only arm a pending commitment. Canceling a job, study, relationship, investment, side-shift, or gambling surface must spend no AP and create no completed record. Entering a gambling venue, reading rules, and leaving without a completed race/hand/run/round must also preserve AP, public state, first-visit state, and the serialized commitment ledger. The completed record must be written once after the real subchoice, trade, application, assessment, or minigame settlement and must preserve the pre-action public snapshot through save/load.
- A save-compatibility repair must never edit or exercise the player's only copy in place. Record the primary and backup hashes, copy both into an isolated playtest user root, load through the production `SaveManager` compatibility path, traverse the real owner UI through the repaired boundary, save and reload the resulting state, and then recheck the original hashes. A raw dictionary migration fixture is necessary but cannot replace this slot→UI→durable-slot proof. Numeric-key repair may promote only an exact, fully validated legacy alias; conflicting or partially valid keys fail closed.
- The commitment result and later Echo must name the actual public deltas, not repeat the preview. Supported evidence includes cash, portfolio, monthly income, body, mind, visible skills, reputation, performance, affinity, job ID, resume readiness, and interview readiness; hidden Moral/route values and exact internal odds fail the gate.
- Hovering the second live AP card must make it `gui_get_focus_owner()`. A subsequent keyboard/controller direction must depart from that card, and hover must never focus disabled, hidden, or `FOCUS_NONE` controls.
- The first-24-week scene-flow profiler must report `events=46 roots=25 followups=21 continuous=9 followup_recuts=0 uncontracted_moves=0 same_week_conflict_switches=0`. It must keep the first shift, Hyunsu study, first investment loss, job/investment mirror, and Hyunsu night scene at weeks `3/18/15/20/20`; the first savings milestone may not interrupt week 17 and must retain its pending latch through later spending.
- With the same route seed and selected actions, KO and EN must produce the same week-by-week cash, event order, pressure sequence, action profile, and final gameplay state. Localized prose may change only the input count. Presentation motion and audio pitch must never consume the global gameplay random stream.
- The demo route must observe `arc_gangnam_visit_alone` and `arc_four_months_in` in week 22, `story_first_savings_milestone` in week 23, `hyunsu_exam_day` as the final story event in week 24, and no formal Hyunsu result before the cutoff. The representative route must hold at least KRW 3,000,000 when the savings prose is shown; the current KO/EN route holds KRW 7,010,192. A full route must observe exactly one pass/fail result in week 25. Week 22 above 55 confirms fails the spacing gate.
- The paragraph above and the existing `demo-experience` title-to-CTA routes are legacy-fallback evidence, not proof of the V2 Seoul Cycle. The dedicated V2 product-route row is the instrumented source-runtime owner: stable selectors establish target reachability, synthesized raw event press/release establishes activation, and the isolated sealed turn-25 receipt proves that Weeks 1–24 completed. It never proves playable W25–48, Chapter-One completion, or the real demo-flavor W24→full-build W25 handoff. Directional focus links and packaged first-run entry need separate automation; physical device feel and a normal-speed verdict remain W1–24 demo human gates.
- The First Bill must expose one gallery/year-scene root. It starts at the desk at 17:52, moves through the selected action's actual place and elapsed time, then returns to the same notebook ledger. Title, dialogue history, and score must not restart as separate cards; route backgrounds and ambience must follow the authored movement. Only currently valid 2–4 candidates may appear. Three expression choices must produce distinct local prose with zero serialized-state, promise, receipt, relationship, or Moral change; the selected one of the existing eight decisions must preserve its exact effect and receipts. The ledger must distinguish selected, deferred, and expired obligations, skip after a fatal health result, and leave Monday 29 June without erasing the finished action.
- A completed First Bill replay must use its bounded JSON-safe snapshot rather than live-run HUD/state, expose no internal fragments as separate gallery entries, and allow alternate decision/fatal/ledger viewing without mutating the current run. Its Month-Three ledger memory is exactly reasons-named, totals-only, or empty; a missing old schema-1 field normalizes to empty without live inference, while invalid type/value and both-live-flags corruption fail closed. Legacy Week-24 in-progress saves must migrate atomically to the opening→decision→ledger sequence; malformed or contradictory receipt/queue/pending-index payloads must roll back byte-identically. A legacy completed save without reconstructable pre-close facts must not receive a synthetic replay snapshot.
- The current generated direction/audio inventory is 1,603 localized event pairs, 177 authored event edges, and 94 registered backgrounds. `python3 tools/scene_direction_catalog.py`, `scene_audio_contract_check.py`, the release-content inventory freshness check, and their self-tests must agree on those generated sources after any opening or First Bill edit; older 1,565/166/91 values in historical release notes are not the current baseline.
- The old 24-week survivability kernel—three routine pairs × three temptation branches × cautious/hard mandatory choices, 48 routine units, and six settlements—is a legacy/fallback arithmetic regression only. Its 18 trajectories must remain stable for old saves, but a PASS cannot be reported as fresh Seoul Cycle balance evidence.
- The fresh Seoul Cycle balance check starts from a new eligible run and executes four named allocation strategies plus one deliberate high-cost failure from Week 1. It may not seed Weeks 1–20 receipts, skip threshold surfaces, fabricate relationship eligibility, or reset health/mental. Each route must match its exact monthly cash/health/mental/employment checkpoints and observed floor in `docs/BALANCE.md`; a fatal fixture is valid only when the same live board exposes a survivable recovery sibling and the logged final effect crosses zero. A visible pre-choice warning remains a separate UI/human gate.
- Both cap-week and ordinary month-end paths must call game-over evaluation after due decline effects and before summary/recap/CTA. A fixture where mental 1 receives a decline of -2 must end as `mental_break`, never open the demo recap.
- `CoreLoopV2HandoffCheck` must consume all four unmodified turn-25 full-route snapshots, including the dirty-deeper health-low edge, and advance the calendar rather than setting target dates. Under one deterministic recovery policy it executes production GameState weekly actions, job/relationship/inventory month processing and pressure, claims actual authored scheduler events through Weeks 27/28/31/36/42/48, and reaches the Week-48 Year-One close with positive health and mental. It must prove zero new V2 routine effects/receipts after Week 24 and zero health/mental normalization, plus exact legacy-identity retirement and value-preserving save/load at Weeks 24, 48, and 240. This component-runtime gate does not prove that the completed demo save can leave its CTA in full-build MainGame.
- The current story-first schedule exposes exactly 77 direct Decision/Boss weeks with chapter counts `13/9/10/15/30`, bosses at weeks `4/24/45/92/140/192/237/240`, and 19 scheduled Echoes. These counts describe the exact authored schedule; they are not a permanent content quota. Week 235 is one fixed follow-through that records the no-transfer notice rather than inventing a second branch. A real health, mental, or cash crisis may promote a scheduled Quiet/Echo into an additional Decision only while that crisis is live; every promotion must be reported explicitly.
- The calendar schedules 21 full-summary checkpoints, but only 20 blocking summary modals may appear. Week 240 performs its final monthly calculation and resolves directly into an ending; week 241 must never expose an interactive AP screen.
- After the demo cutoff, at most one distinct authored root may begin in a week. Its immediate multi-part `follow_up_event` chain may finish in the same week, but StoryMode return cannot drain unrelated due roots into one uninterrupted stack.
- The pre-story-first reference full real-input route completes as `with_daeun` with `job_01`: EN Xbox uses 3,064 confirms across 218 seen events, records 45 generic plus seven authored commitments across its historical 52 direct weeks and 20 exact Echoes, and exposes zero Hangul. It remains legacy input/parity evidence, not the current 77-week pacing contract. AP-card activations are tracked separately from finalized commitments because cancelable job and sub-action modals may be inspected without spending the week. It uses zero keyboard/mouse events, enters all five chapters, renders every auto week, and reaches the ending directly after week 240. A fresh KO full rerun is required only if the localized gameplay contract changes.
- Every direct-week pressure frame must expose a non-empty semantic family and exactly three distinct bound AP actions. Across a full route, at least six families must appear globally, at least three in every chapter, no family may repeat more than five direct frames in a row, and no family may own more than 65% of sampled frames. The latest EN route exposes 58 frames, seven families, at least four per chapter, and a maximum streak of three; the KO reference also exposes seven families with a maximum streak of three.
- Pressure selection is a read-only preview: fixture snapshots before and after `_demo_week_pressure()` must match. English IDs/actions must be locale-independent, visible English may contain no Hangul or hidden Moral/route vocabulary, and a long Act 5 question may not expand its frame beyond the 2.5% TV-safe rectangle.
- These full-run numbers prove reachability, pacing bounds, input purity, and localization only. They do not overturn the user's Demo Round 2 NO-GO or substitute for a normal-reading emotional playtest.
- `ScreenshotQA --qa=demo-experience --demo-build` must emit a machine-readable event profile for KO PlayStation and EN Xbox. `python3 tools/demo_experience_audit.py <ko.json> <en.json>` must keep the two routes at 25 roots, 40-60 events, at least 24 meaningful choices, 40-90 estimated minutes, first meaningful choice within seven minutes, maximum later choice gap within 7.5 minutes, final story event `hyunsu_exam_day`, and exact structural/visual/ambience/authored-score parity. The accepted prose baseline is 46 events, 35 meaningful choices, 36 manual Story stops under cinematic playback, KO 62.6 minutes, EN 54.3 minutes, 15 backgrounds, 11 portraits, four CGs, eleven place ambiences, five human-presence layers, ten music keys, and 41 authored-music events. The base contract is two generic AP commitments plus seven authored StoryMode commitments with at least four money-axis and two human-axis records. The current causal job route reports one additional live cash-crisis promotion, hence three generic plus seven authored commitments and 630/634 fast-path confirms. Older 19/19 AP, 689/693, 666/670, 642/646, 628/632, and 47-event values are historical.
- When a rendered background ID exists, `BGMContinuityCheck` must prove localized title, prose, category, or tags cannot override its place ambience. Runtime prose inference and the universal goshiwon-room fallback are forbidden even when a legacy event omits a background; that event must inherit a reviewed rendered surface or declare intentional silence. The seven demo score anchors must retain place ambience and enter after paragraph one or later; `tools/demo_experience_audit.py --self-test`, `scene_audio_contract_check.py`, and `scene_audio_catalog.py` gate this contract.
- `python3 tools/narrative_continuity_audit.py` may classify a scene as an isolated micro-scene only when it has one link, at most six panels, at most one dialogue line, and every authored branch is at most 420 source characters. The branch range must count description, choice text, result text, and recursively linked child prose: 420 characters remains micro, while 421 does not. The audit must report branch minimum/maximum characters and retain its chapter ratchets without an event-ID allowlist.
- `python3 tools/full_run_pacing_audit.py` must keep both representative paths at 24-36 post-demo random-event opportunities with at least one in every chapter, estimate 180-300 minutes total, and report the week, source component, and root that first cross the fixed-model two-hour checkpoint. The default window remains weeks 97-144; the only earlier exception is exactly week 96 when the `arc_year2_close` scene component itself crosses the checkpoint. A later cadence or summary component may not borrow that exception. Week 95, any other week-96 root, and week 145 fail. This is a structural comparison model and may not be reported as human playtime or fun evidence.
- `EventDirectorCheck.tscn` must migrate a legacy rhythm save by removing only stale current-week locks, preserve money and authored flags, and accept a current-version week-25 demo state unchanged in the full build. `DemoBuildCheck.tscn -- --demo-build` must retain the week-24 cutoff while proving the contextual decision surface exists during the full run and disappears after week 240.
- `ScreenshotQA --qa=ap-act-en --lang=en` must render direct weeks `1/61/114/161/217`, keep all five canonical chapter names, and reject any fixture that lands on Quiet/Echo. Direct weeks must hide the AP HUD chip, portrait rail, weekly calculation board, Seoul Trace, and separate Next Week command. Inspect 1280x720, 1280x800, and 1920x1080 captures for title clipping, card overflow, focused-card background continuity, and crisis tint legibility.
- `ImmersionLoopCheck` must keep every pressure at exactly three live actions, mutation-free previews, no visible Moral/route vocabulary, zero Korean leakage in English, at least six contextual families globally, and at least three families in each chapter's deterministic fixture set. Capital pressure appears only in months 3, 6, 9, and 12 at week three; the six-month fixture must therefore expose exactly two capital windows.
- `StoryPlaybackCheck.tscn` must prove one held `ui_accept` can traverse multiple prose paragraphs but stops on the current event's final paragraph. It must not expose or commit a choice or cross events. A fresh accept opens a real multi-choice rail; default AUTO instead carries each of the seven first-session one-choice actions after its localized reading delay, applies it exactly once without a rail or portrait-choice shift, and stops before every real choice. Authored cinematic holds must return direct actions to AUTO rather than strand them. Korean/English hints must fit with Xbox `A`, PlayStation `✕`, and Nintendo `B`, and all four demo `same_location` edges must skip the full scene ink/text fade while preserving the follow-up.
- `ScreenshotQA --qa=ap-act-en --lang=en` must keep the three primary cards in one horizontal row, preserve their scene art and preview copy, transfer mouse hover to real GUI focus, crossfade the full background to the focused card's scene, and leave the result confirmation unobstructed by the commit toast. Result confirmation must advance directly instead of rebuilding a closed AP surface.

Automated data-only mod gates:

- `python3 tools/mod_pack_validator.py --self-test` must validate the three bundled Moral palettes plus a valid random-event pack and balance preset without launching Godot.
- `python3 tools/mod_layer_audit.py` must print `MOD_LAYER_AUDIT_OK repository scripts=0 text_only=1 exact_paths=1 random_events=1 schedule_locked=1 mod_flags=1 presets=1 schema_guard=1 themes=3`.
- `ModLayerCheck.tscn` must discover translation, asset, event, preset, and theme layers; preserve built-in IDs unless `override=true`; reject blank event copy and non-`mod_` flags; preserve schedule keys and choice counts; reject catalog type/schema changes; reverse the winning preset when load order is reversed; and fall back when every layer is disabled.
- The settings surface must expose the three official Moral palettes at 1280x720 and 1280x800 inside the 2.5% TV-safe rectangle with a keyboard/controller focus owner. The mod manager is a conventional short list: enable toggles plus earlier/later ordering, with changes applied on the next launch.
- External themes may change only fixed color values under `main/story` and `black/gray/white`. They cannot add a Moral band, rename a surface, or expose the hidden Moral score.
- Script, scene, package, and native-library files under the mod root are unsupported and must never be loaded.

Automated artifact and hidden-feature gates:

- `AchievementPathCheck.tscn` must keep the achievement catalog, English dictionary, ending unlock labels, and all fifteen executable unlock paths identical while restoring the player's exact pre-check meta file.
- `HiddenFeatureCheck.tscn` must expose exactly two base choices without each route artifact and the original third choice with it in Korean and English. It must execute Jaehyuk's photo follow-up, Jiyeon's `jiyeon_man` DIK route, Daeun's non-divorce post-it route, four dawn lines plus the fifth deepest line, the post-credits drawer cut and achievement, and all six localized keepsake names in the ending ledger.
- `tools/audit.sh` must print `HIDDEN_FEATURE_CHECK_OK artifact_choices=3 follow_up=1 jiyeon_dik=1 daeun_route=1 dawn=5 drawer=1 keepsakes=6`. A catalog-only or JSON-only check is not sufficient.
- `HousingKeepsakeCheck.tscn` must select the oldest owned artifact before a housing upgrade, render the current pre-move housing rather than a fixed room, preserve the artifact on `keep`, remove only that artifact on `leave`, apply the localized result in Korean and English, survive serialization, and hide the artifact-gated route choice afterward without changing ending routing.
- `tools/audit.sh` must print `HOUSING_KEEPSAKE_CHECK_OK oldest=1 keep=1 leave=1 localized=2 silence=1 route_delta=0` and clean only its exact `gangnam-housing-keepsake.*` isolated-home directory.

Automated year-identity gates:

- `YearIdentityCheck.tscn` must verify all five localized chapter identities; actual-current-run-only year-scene candidates; four distinct dynamic choices; five serialized selections; localized ending recap titles; the three authored Y1 timeout defaults; all three Y2 investment windows; the Y4 three-week montage cap; and the Y5 48-week HUD plus monthly narration.
- `tools/audit.sh` must print `YEAR_IDENTITY_CHECK_OK chapters=5 curated=5 choices=4 localized=2 timed=3 y2=3 y4_cap=3 y5_weeks=48 serialized=1`.
- `ScreenshotQA --qa=year-identity --lang=ko/en` must render five chapter cards, the four-choice year-end curation, a visible countdown bar, the Y4 three-week montage result, the Y5 week HUD, and the no-overflow `5년, 다섯 장면 / FIVE YEARS, FIVE SCENES` ending ledger at 1280x800.

Automated store-asset gate:

- `ScreenshotQA --qa=store --lang=en` must generate exactly eight named source frames from actual game state, including the same Daeun cafe event at Moral Tint +80 and -80.
- `StoreScreenshotExport.tscn` must crop those sources to the canonical 1280x720 filenames in `/tmp/gangnamdream_store_screenshots`.
- `python3 tools/store_shot_check.py` must print `STORE_SHOT_CHECK_OK count=8 size=1280x720 unique=8`; missing, stale, duplicate, undersized, or wrongly sized PNGs fail the gate.

Automated art-quality gate:

- `tools/art_ai_audit.py` derives the active CG, portrait, and background paths from `ImageRegistry`; no hand-maintained inventory may silently omit a runtime asset.
- `tools/art_resolution_audit.py` measures those same active paths against 1080p and 4K cover targets and compares them with `tools/art_resolution_baseline.json`. A new/stale path, changed target contract, changed kind, or lower width/height fails `tools/audit.sh`; a larger replacement is allowed.
- The current baseline is 246 active rasters: 74 CGs, 90 portraits, and 82 backgrounds. Ninety-one meet the authored native-1080 target, 33 are native 4K, and 155 remain in the heavy/severe 4K enlargement band. This is a dimension contract, not a final face/hand/continuity or living-room verdict.
- `docs/ART_RESOLUTION_READINESS.md` prioritizes 52 P0 assets from the real KO/EN 24-week demo profile, the executable Steam store capture contract, and A-or-higher endings. This priority report guides production; it does not turn dimensions into a human quality verdict.
- `tools/art_master_audit.py` gates only promoted masters listed in `tools/art_master_manifest.json`. The current pilot is `goshiwon_hallway`: full-frame Real-ESRGAN, three approved 100% crops, and exact source/output/tool/model hashes. It does not approve blind upscaling for actors, hands, lettering, mirrors, or recurring props.
- Every active path must have exactly one row and its reviewed file hash in `docs/ART_AI_AUDIT.md`; duplicate rows, changed hashes, and `FAIL` or `PENDING` verdicts fail `tools/audit.sh`.
- Active portraits require alpha. Missing files, stale ledger rows, or unreviewed new registry paths fail immediately.
- `cast_detail_contract_check.py` requires every CG gaze/action actor to be A/B-tier, keeps relationship cast tiered, and forbids atmospheric C-tier extras from becoming acting focus. Reusable backgrounds may embed only C-tier extras.
- Contact sheets accelerate review but do not replace original-resolution checks for hands, gaze, reflections, readable text, architecture, recurring identity, and the ten store-facing key visuals.
- After changing a CG, run only its owning ScreenshotQA scope first. The current Crypto Ghost repair is covered by `--qa=endings-en --lang=en`; broad casino/AP QA is unrelated.

Automated ending-fact gate:

- `ending_distinctness_audit.py` must keep all 35 KO/EN endings aligned while rejecting self-funded 3B language in `jiyeon_man`, a Gangnam apartment in the 1B `second_love`, age-55/current-retirement claims, the stale 200M orthodox amount, or a missing `startup_exit` reread in `gangnam_dream`.
- The same gate requires three byte-distinct fallback symbols wired to `ordinary_life`, `burnout`, and `mental_break`, an exact dedicated `cg_ending_stable_success` owner/path, and the documented nine-ID generic mood-card backlog.
- `ScreenshotQA --qa=ending-p0 --lang=ko/en`, `--qa=ending-p1 --lang=ko/en`, and `--qa=endings-en --lang=ko/en` are the visual companions; they must use factual seed money/housing and exact symbol/CG resource paths.

Automated store-trailer gate:

- `ScreenshotQA --qa=trailer --lang=ko/en` must render all 22 named in-game sources at 1920x1080. The actual timed-choice surface must remain readable at 12/7/3 seconds and turn urgent at three seconds.
- `python3 tools/trailer/trailer_check.py` must keep the exact 30/60-second cut totals, Korean/English caption pairs, canonical key art/music, project-owned cues, and complete source contract valid. It runs inside `tools/audit.sh` without requiring generated footage.
- `./tools/trailer/render_all.sh` must produce four H.264/AAC 1080p60 MP4s, SRT files, checksum manifests, and five QA frames per edit under ignored `build/trailer/`.
- Reviewers must confirm the same-scene Moral Tint progression, title-safe captions, 22-26s/44-50s catastrophe silence, and no unsupported marketing claim. See `docs/TRAILER_PRODUCTION.md`.

Automated audio gates:

- `audio_source_audit.py` must assign every shippable WAV/OGG to licensed recording/sample provenance; no missing, stale, duplicate, undocumented, or synthesized audio may ship.
- `build_sample_audio_assets.py --validate-only` must resolve every external source and hash without generating a waveform. The retired `generate_*audio*.py --check` commands are read-only compatibility gates and may not write release files.
- `scene_audio_contract_check.py` must give every active CG an ambience and every event on all Tier-1 peak paths an authored scene-audio contract. `scene_audio_catalog.py` must additionally classify every shipping KO/EN event and every registered rendered background, rejecting missing/stale IDs and locale-dependent background or CG changes. Diegetic spoken language remains Korean under every text locale.
- `full_run_audio_audit.py` must trace two representative 240-week paths in KO/EN with identical week/event/ambience/music ownership, an authored scene, profiled connective scene, and explicit score entrance in every chapter, all seven activity owners, and two ending families. Its output is deterministic coverage evidence, not human listening or fun evidence.
- `game_audio_contract_check.py` must preserve 17 physical SFX keys, 19 stage call sites, seven activity ambience owners, nine direct-controller minigames, and ten separate human-presence layers. It rejects a regression from semantic controls to `grab_focus()` traversal.
- `audio_source_audit.py` must reject public-transit/crowd recordings in goshiwon thin-wall or generic public-interior beds, food-court substitutes in convenience-store/casino beds, and unrelated object recordings substituted for scanners, buses, wedding applause, slot reels, roulette wheels, or race gates.
- `GameAudioContractCheck.tscn` must load every physical stream, prove bounded playback variation, keep same-activity ambience continuous, reject stale-owner clearing, and restore housing ambience on exit. Jeongseon floor/table masters must have the same substantial loop length; same-layer calls cannot rewind, and both floor→table and table→floor crossfades must inherit playback phase before the score closes on exit.
- `MoralAmbienceCheck.tscn` must prove that Light/Deep Black progressively remove and low-pass only the human layer, that inert machinery remains legible, that White restores people, and that the transition starts no explanatory music.
- `StoryAudioSettingsCheck.tscn` must open from `gd_menu`; expose three text sizes, Slow/Normal/Fast text speeds, the selectable languages, Music/Ambience, SFX, and Reduce Motion without scrolling; persist speed into a new StoryMode; preserve the authored slow-pacing ratio; keep AUTO's total target reading time stable after typing-time compensation; pause prose/AUTO/direction timing/timed choices; restore one countdown row and the exact focused choice; rebind current prose/choices/results across KO/EN without replaying effects or follow-ups; close from Menu/Cancel; and never restart either stream. Run once at physical 960x600, while `ScreenshotQA --qa=story-audio --lang=ko/en` continues to cover 1280x720 and 1280x800 with Large text, zero English Hangul, and no panel/body clipping.
- `StoryDialogueHistoryCheck.tscn` must open from the visible top button and semantic West input while prose or choices are active. It records screen-complete authored blocks, the exact pre-effect wording of the chosen option, and completed result blocks once each; a partly typed current block may appear only as a transient visible prefix. The history must never contain an unchosen or locked option, a future sentence, exact relationship/moral values, or a reconstructed old event-log guess. Opening the modal freezes prose, AUTO, authored holds, and timed choices; closing it resumes one timer row from the saved remainder and restores the same choice node. Immediate follow-ups in the same StoryMode queue keep the history, a fresh StoryMode visit starts empty, and `ManualSaveCheck.tscn` must round-trip the nested schema through real slot IO without applying the selected effect again.
- A StoryMode resume must store the source paragraph count and locale with its source-relative progress. If KO and EN source shapes differ, loading in the other language rewinds only the current phase to source zero; it must never infer a later paragraph or expose text beyond the saved phase.
- `BGMContinuityCheck.tscn` must keep the weekly hub, ordinary random events, and unscored arcs on place/season ambience without starting generic lo-fi; preserve same-context playback and Moral Tint texture changes; and permit story music only through an explicit paragraph score contract. `menu/early/hustle/late_tense` remain lobby-only.
- `ImmersionLoopCheck.tscn` must prove two-week action memory and serialization, precise no-leak event families, ×2.6/×1.88 echo strength, ×0.42 filler attenuation, deterministic quiet-week bands, localized causal frames, season/housing vignettes, non-mutating arc omens, actual-bills deadlines, four reachable financial rungs, one/three-month cash-reserve pressure, and SFX mix trims.
- Financial progress must be derived from one runtime contract: starting cash below current housing+loan interest shows this month's bills; employment with less than three months of actual cash still shows the reserve; only a funded reserve advances to the next wealth rung. The ultimate 3-billion-won goal and the selected notebook motive remain visible without replacing each other.
- KO/EN 1280x800 screenshots must fit the longest top-left rung (`One-room move range`) and compact remaining amount without clipping, keep uncovered bills visually urgent, and keep covered reserve/wealth states out of emergency red. Japanese UI keys must remain complete even though Japanese content is not a launch language.

Automated random-event director gates:

- `event_director_audit.py` must distinguish 1,176 catalog candidates from the 1,003 events that can actually enter the runtime director after authored story, scheduled roots, direct-only V2 beats, and follow-up targets are removed. It requires five contiguous chapter windows, five contiguous asset bands, 1,000 once-per-run events, and exactly three approved repeatable everyday events.
- The content-diet contract must derive exactly 64 foreground events, 19 one-choice stateful bridges, and seven material producer roots from the Korean source. Six producer roots have no authored follow-up of their own; `butterfly_mystery_info_result_scam` is the seventh hybrid root because it also schedules `chain_scammer_again`. The nineteenth bridge is the housing-gated goshiwon rent reminder and does not add a producer root. Comedy, `korea_` explainers, and consequence-free callback recaps cannot own foreground; multi-choice automatic resolution remains zero.
- `EventDirectorCheck.tscn` must reject commute and after-work scenes while unemployed, goshiwon scenes after moving out, a six-month partner scene before romance, and named-cast callbacks before meeting. It must preserve Sangchul's introduction, authored arc/follow-up routing, and the data-owned ×2.6/×1.88 recent-action echo. Demo builds must expose zero random bridges even after week 24; full builds may resolve an eligible curated bridge once without the generic hidden-event chance.
- Selecting an actual random event, not merely drawing it, records its run count and last turn. Both dictionaries must survive save/load. The three repeatable events may return only after 24-32 weeks, at 0.35 weight, and never exceed two appearances.
- Guaranteed arcs, authored follow-up events, deferred queues, event prose, effects, and Moral Tint remain outside this director. A causal bridge must reuse the original choice application and write its event history exactly once.

Automated Living Scene gates:

- `LivingSceneCheck.tscn` must route rain, first snow, memory, fireworks, city light, and neutral scenes from stable IDs/backgrounds/tags/channels only; description text cannot create weather.
- Rain and snow shader motion must move toward increasing canvas Y. `LivingSceneCheck.tscn` locks the source direction and `ScreenshotQA --qa=living-scene` must identify a positive downward displacement in real rendered frames.
- Authored `direction.camera` always wins. Reduce Motion stops camera and portrait breathing and reduces particle motion; remote/memory/CG portraits never breathe like a local body.
- Moral Black must reduce atmospheric life and motion while increasing only a bounded afterimage; White may restore air but cannot exceed the 2px background blur cap.
- `ScreenshotQA --qa=living-scene --lang=ko/en` runs at 1920x1080, captures five profiles, checks layer order below portraits/text, and compares two independent rain frames. At least eight of 960 upper-scene samples must change; neutral scenes remain particle-free.

Automated text-material gates:

- `TextMaterialCheck.tscn` must print `TEXT_MATERIAL_CHECK_OK text_depth=1 surface_depth=2 body_shadow=0 press_travel=1 motion_ms=55`.
- Story prose and AP explanations must have no visible text shadow or outline. Scene/name/choice/key-money/state roles use one crisp pixel only; Deep Black money may change color but may not grow beyond a 1px metallic edge.
- Story and AP choice surfaces rest at 1px, hover/focus at no more than 2px, and remove the floating shadow while pressing content exactly 1px. Reapplying Moral Tint may not accumulate that travel.
- AP card hover and focus are one state: `mouse_entered` on an enabled visible card must call `grab_focus()`, update the same-week restore index, and leave directional navigation deterministic. Hover-only highlighting with a different keyboard/controller focus owner is a failure.
- Run `--qa=text-material --lang=en` and `--qa=display-matrix --lang=en` at 1280x720, 1280x800, and 3840x2160 after changing these tokens, then inspect the AP decision and Story choice PNGs for doubled glyphs, blur, clipping, and TV-safe intrusion. `--qa=story-en --lang=en` at 1280x800 is the body/result companion.

Automated input and display gates:

- `InputMatrixCheck.tscn` must print `INPUT_MATRIX_CHECK_OK modes=3 resolutions=8 brands=3 direct_scenes=9 direct_routes=18 major_routes=8 modal_routes=8 boundary_routes=16 invalid_routes=8 keyboard_tasks=10 action_sets=4`; the same run also proves StartMenu Down/Up focus movement before opening Settings, skips disabled vibration strength, and keeps all eight direct-game tutorials from leaking L2/R2 into the hidden stake or buy-in.
- `ControllerSemanticCheck.tscn` must print `CONTROLLER_SEMANTIC_CHECK_OK surfaces=4 major_actions=2 raw_routes=8 trigger_gate=1 reconnect_gate=2 modal_leaks=0 vibration=1`. It sends raw trigger/key press and release through title load/archive, Story save/settings, the 24-week completion ledger, and MainGame save/ending pages; held trigger jitter, held reconnect duplication, neutral reconnect first-press loss, hidden modal input, prose/finish fallthrough, and destructive trigger actions are failures.
- `GameAudioContractCheck.tscn` must print `GAME_AUDIO_RUNTIME_OK physical=32 ambience_roundtrip=3 varied_playback=1 casino_music=1 haptics=12 unused_profiles=0 direct_scene_raw=0 vibration_roundtrip=1 boundary_clamp=8 same_stack=3`. Ordinary UI wrappers and raw scene motor values are forbidden; every named profile must own a real callsite, all eight reversible value routes must stop at their endpoints, and reel/card/result beats must not overwrite one another in the same call stack.
- Its keyboard tasks must place/start one real round in Blackjack, Baccarat, Slots, Roulette, Big Wheel, Dai Sai, Holdem, and RaceTrack, then launch the selected table from the casino hub. A stake-only toggle is insufficient.
- Keyboard-only title-to-demo QA must reach the week-25 CTA with `mouse_events=0`; mouse-only QA must reach the same boundary with `key_events=0`. Both routes must begin unemployed and exercise money and human axes.
- The month summary and demo-ending CTA must fit at 1280x800 without vertical scrolling or an off-screen progression button.
- `ScreenshotQA --qa=display-matrix --lang=ko/en` must pass independently at 960x600, 1280x720, 1280x800, 1600x900, 1920x1080, 2560x1440, 3440x1440, and 3840x2160. Every run captures title settings, the demo AP decision, and a Living Scene choice; 1080p additionally captures Xbox, PlayStation, and Nintendo glyph surfaces.
- Settings, AP pressure, and Story choice controls must stay inside the 2.5% TV-safe rectangle and own valid keyboard/controller focus. Story backgrounds must use covered aspect preservation rather than stretching. Captured PNG dimensions must equal the requested output dimensions.
- A passing QHD/4K layout does not certify native art sharpness. Record the source dimensions of each sampled background, portrait, and CG; a 1280x800 source shown at 3840x2160 remains raster-master debt even when the frame is geometrically correct.
- Xbox/Steam Deck, PlayStation, and Nintendo labels must come from `ControllerHints` physical positions. Game scenes may not hardcode one brand's face-button letters.
- Reduce Motion and vibration on/off/strength must be reachable from title,
  MainGame, and Story scene settings without restarting current audio or changing
  game state. Disabling vibration also removes the strength slider from focus and
  stops an already-running cue.
- The Steam Full Controller Support claim remains blocked until physical Steam Deck, DualSense, and Switch Pro blind passes cover reconnect, suspend/resume, overlay, and accidental input.

## Launch
- Project opens in Godot 4.6.
- Start screen loads.
- New game starts without script errors.
- Main UI appears correctly.
- Buttons are clickable.
- Text wraps horizontally and does not appear vertical.

## Core Loop
- `m3_inventory_shift` 수행 화면에는 선반 재확인·입고/반품 기록 대조·인계표 작성의
  세 작업 대상과 보통 처리 기회 두 번이 정확히 보인다. 세 조합과 전부 처리 결과,
  남긴 일, 최종 돈·건강·정신력 효과가 서로 모순되지 않는다.
- 선택 도중에는 AP·돈·건강·정신력·주 완료가 바뀌지 않는다. 중복·잘못된 요구,
  보통 0/1/3개 확정은 거부되고, 저장 후 같은 선택 순서와 남은 횟수로 돌아온다.
  마지막 확인만 기존 원자 거래를 한 번 실행하며 재시도·로드가 효과를 반복하지 않는다.
- 재고조사 결과 장면과 다음 달 물류 수업은 실제 결과 영수증만 읽는다. 하지 않은
  재확인·추적·기록을 했다고 쓰지 않고, 결과 카드·로그·효과를 중복 재생하지 않는다.
  수행층 도입 전 저장은 기존 장면이 증명한 재확인·확인 시각·선반 번호만 읽으며
  새 조합이나 인계표 작성을 발명하지 않는다.
- 수행 화면은 960×600과 1280×800 KO/EN에서 핵심 스크롤 없이 맞고, 키보드·패드
  방향 이동/South 확인/East 마지막 선택 취소가 같은 의미를 가진다. 물리 패드와
  실제 행동감은 `demo_inventory_task_hand_feel` 사람 게이트가 판정한다.
- Turn advances correctly.
- Date, age, and turn update correctly.
- Monthly expenses apply correctly.
- Events appear from valid data.
- Choices apply stat, money, relationship, investment, flag, and item effects.
- Game over triggers correctly.
- Endings trigger correctly.

## Event System
- Event conditions work.
- Every `content/events/*.json` file is registered in `DataRegistry.EVENT_PATHS`.
- Rare and hidden events respect unlock rules.
- Repeated events are prevented or reduced.
- Chained events can follow previous choices.
- Invalid event data fails safely.
- `SceneDirectionCheck.tscn` passes hold, camera, beat, sting, ambience restore, and BGM continuity.
- `FlashforwardVisualCheck.tscn` passes scene-local Black override, persistent tint safety, semantic background, HUD/portrait treatment, and Gray follow-up restore.

## Launch / First 30 Seconds
- The launch flow contains exactly one mandatory input gate: the title prompt. Publisher pre-roll and the three-beat New Story opening are fully automatic and skippable.
- The JUNPAC mark uses the user-approved transparent `junpac_games_logo_v2.png` on a dedicated pure-white publisher backdrop. The logo and white backdrop fade out together before the dark Gangnam Dream title film appears. Runtime cropping may remove empty alpha padding, but must not redraw, stretch, recolor, or regenerate the wordmark. Runtime launch trees must not load the old black-box `junpac_games_logo.jpg` or retired `JunpacMark.gd`.
- `publisher_sting` plays once per cold boot. It does not loop, stack on skip, or restart at the title/opening handoff.
- New Story routes through `OpeningCinematic.tscn`; Continue and Load route directly to the saved game. The opening contains at most three full-bleed illustrated beats and no black presentation cards or final confirmation gate.
- Keyboard shows `PRESS ANY KEY`; active Xbox/Steam Deck, DualSense, and Switch layouts show their physical South button. Dismissing the gate restores focus to a visible title command.
- Reduce Motion removes opening camera scaling and inferred Living Scene camera travel while preserving the same image, copy, timing budget, and skip target.
- `First30SecondsCheck.tscn` must print `FIRST_30_SECONDS_CHECK_OK gates=1 beats=3 budget=17.1s logo=image audio=1 reduced_motion=1 pad=1 notices=ledger`.
- Run `ScreenshotQA --qa=first-30` for KO/EN at 1280x720, Steam Deck 1280x800, and 3840x2160. Include at least one `--pad=playstation --reduce-motion` run and one 4K pad run; inspect logo edges, title-safe copy, full-bleed crops, English zero-Hangul, and duplicated transitions.

## Ending Art
- `CGRuntimeCheck.tscn` passes all ending CG paths, minimum 1280×720 dimensions, unique ownership, Gangnam Ink preview grading, and the ending-CG shadow-legibility grade.
- `CGRuntimeCheck.tscn` also passes all story CG paths, exact 1280×800 romance dimensions, paragraph reveal timing, paragraph-specific background order, hidden portraits, and hidden HUD. Story CGs keep unique ownership except the explicit same-ballroom continuity allowlist for Jiyeon's three-link wedding-gap chain.
- First-snow runtime checks also prove December-only routing and correct person-free prelude background/portrait before each delayed CG.
- An ending without a dedicated CG uses its moral mood card; it never borrows another ending's image.
- The ending owns an opaque fullscreen surface and never reveals the AP shell or a scroll container behind it.
- Page order is fixed to final scene beats, credits, cast aftermath, Time Ledger, run record, and unlocks/next run. South advances every page; Back is offered only after emotional closure.
- The first scene contains no grade, final-assets total, turn count, or unlock report. Full authored ending prose is split into readable beats rather than deleted or collapsed into one summary.
- The Jiyeon drawer truth cut fires once immediately after credits when its hidden conditions are met, then resumes the aftermath page without replaying.
- Run `ScreenshotQA --qa=ending-p0 --lang=ko/en` and `--qa=ending-p1 --lang=en`; representative six-page captures must fit at 1280×800 without wheel input, clipped labels, or Korean leakage in English.
- A title-to-ending Xbox-position EN run and PlayStation-position KO run must traverse all six pages with zero keyboard/mouse input.

## News And Market
- Monthly news generates.
- News affects relevant markets.
- Market bubbles and crashes occur within intended ranges.
- Misleading news does not feel unfair without counterplay.

## Save/Load
- Autosave works.
- Manual save slots work.
- Loading restores player state, portfolio, relationships, flags, inventory, and logs.
- Every new save stores `game_version`, `build_id`, `build_flavor`, and `save_namespace`; the start-menu slot row shows its source and compatibility before loading.
- A `game_version` or `build_id` mismatch is diagnostic-only and loads with a warning. A future save schema, invalid identity field, mismatched namespace/flavor, full save opened in a demo, or a general post-Week-24 save opened in the demo/V2 playtest is rejected before mutating `GameState`. The sole V2 exception is the exact same-playtest-identity, strict-typed `turn=25` completion receipt with completed Weeks `1..24`; it reopens the Week-24 recap/CTA and does not expose Week-25 play. Any arbitrary turn 25 or turn 26+ remains rejected.
- The compatibility direction allows a demo-flavor save in a full loader, but a full save may not load in the demo and the current V2 playtest namespace is isolated in both directions. The public continuation/full-release blocker is an actual W1–24 demo-flavor save → W24 CTA → full MainGame Week 25 exactly once; loader acceptance alone does not close it. This separate OPEN bridge does not change the W24 demo cutoff or gate the demo's own human verdict. Identity-less legacy saves remain eligible within the active flavor and cutoff, with an explicit warning.
- A save write must verify temporary bytes and payload identity before replacement, preserve a byte-identical verified backup of the prior primary, and leave the prior primary/backup untouched on any failed stage. Retry must produce one success without stale temporary files. If the primary is missing or parse-corrupt, load may use only a compatible verified backup and must restore the canonical primary bytes before applying state.
- Archive `seen_scenes` and `unlocked_cgs` survive restarts through MetaProgression; old meta saves receive empty defaults without migration failure.
- Archive replay never mutates the active run, achievements, scene history, or CG unlock history.
- Save data remains compatible after content additions where possible.

## UI/UX
- Stat panels remain readable.
- Investment panel remains readable.
- Relationship panel remains readable.
- Event choices fit on screen.
- Opening choices folds the dialogue panel away; dialogue and choice surfaces never cover the scene in two stacked layers.
- Gray and Black StoryMode backgrounds retain readable architecture, eye-lines, and hand actions at 1280×800.
- Living Scene particles and haze never cover the lower dialogue dock or the normal portrait face zone.
- Notifications do not block important buttons.

## AP Consequence Echoes
- `ImmersionLoopCheck.tscn` must preserve distinct `apply`, `rest`, `contact`, and `save` action records through weekly finalization and save/load, keep previews read-only, and produce different KO/EN Echo and event-cause lines without hidden Moral/route terms.
- Forgone generic paths must persist by action/person/first and latest turn/count through save/load. Reopening the card must disclose the delayed cost before confirmation; opening or canceling must not consume it; successful completion must apply it exactly once and repeat completion must not apply it again. Contact cooling, accumulated fatigue, delayed-job starting performance, restart friction, and actual market movement require separate runtime assertions. Missed shifts/savings must never deduct fabricated cash, and declining gambling must never create a debt.
- `ScreenshotQA --qa=immersion-loop --lang=ko/en` must render the two-line delayed-cost card without clipping at 1280x800. `ja_translation_audit.py --scope ui` must preserve placeholders and zero missing keys. The KO PlayStation/EN Xbox `demo-experience` reports must retain exact 46-event, 25-root, 35-choice, nine-commitment structural parity; these automatic checks never constitute a human fun GO.
- A direct Decision/Boss week must expose exactly three commitments with visible NOW/COST/LATER and no fallback catalog. Opening and canceling a study, relationship, or investment submenu must leave AP and commitment history unchanged. A successful subchoice/trade must finalize exactly one commitment, set remaining AP to zero, retain exactly two forgone paths, reject a second same-week commitment, and survive serialization.
- Investment settlement evidence must include asset ID, side, fill, quantity, fee, and the applicable committed cash/proceeds/realized P/L/exposure. Gambling settlement evidence must include the actual venue, at least one completed round or hand, optional trade count, and session net. KO/EN result and saved Echo surfaces must name these concrete facts without leaking Hangul to English or exposing Moral/route/internal odds.
- Before commitment, no Next Week command may be visible on a direct Decision/Boss surface. After a generic commitment, the scene ledger must show the actual result, both paths not chosen that week, and an unknown later echo without pretending those paths are permanently closed; confirming that ledger must advance directly to the next week or month boundary. An authored StoryMode boss may own the weekly commitment instead of rebuilding this generic ledger.
- `CoreChoiceSliceCheck.tscn` must prove one serialized first-week chapter intent; no application or interview for cash/preparation routes; one application, no same-week interview, and a later unemployed-only interview for the work route; `arc_temptation_01` as the week-4 authored boss; zero generic AP duplicate in that week; branch-specific week-8 delayed results; one atomic story-boss record; and save/load round-trip parity. `tools/audit.sh` must print `CORE_CHOICE_SLICE_CHECK_OK intent=1 interview=causal authored=7 generic=2 ap_duplicate=0 delayed=t8 branches=2 axes=money/human save=roundtrip`.
- Contact previews must not collapse into the goshiwon or cafe. Deterministic fixtures must resolve distinct home, subway, live workplace, and outdoor scenes; the chosen concrete background ID must survive pending state, completion, serialization, a later job/home change, and the matching Echo.
- `ScreenshotQA --qa=immersion-loop --lang=ko/en` must capture application and rest Echoes plus a matched event causal frame at 1280x800; exact action copy, dialogue dock, and controls remain inside the TV-safe area.
- `ScreenshotQA --qa=demo-gamepad --lang=en --pad=xbox` must observe one and only one commitment in every scheduled or live-crisis-promoted direct week and an exact recent commitment in all four scheduled Echo weeks. The base slice has nine direct weeks; the current causal first-job route has ten after one reported cash-crisis promotion. `--qa=full-gamepad` remains legacy evidence for its historical 52-direct/20-Echo route. The current story-first 77-direct/19-Echo schedule is instead gated by the exact chapter route, pacing, targeted input, and finale screenshot checks until a same-route full-input harness replaces that legacy evidence; neither route may use fallback catalog, keyboard, or mouse rescue.
- Legacy saves without action records keep the generic money/human causal frame and must not fail deserialization.

## Scene Direction / Full-Run Motion

- `scene_direction_catalog.py` reports 1,603 events, 177 authored edges,
  94 backgrounds, eight manifest activities, and 35 endings with zero missing
  contracts. The runtime direction checker separately exercises seven activity
  owners.
- `SceneDirectionCheck.tscn` derives its runtime population from the 1,603 unique,
  loaded shipping event IDs declared in the direction manifest's `event_intents`
  and checks only edges whose source belongs to that population. Unknown IDs and
  unclassified shipping edges fail closed; being packaged does not move an
  author-only root into that declared shipping population.
- `full_run_direction_audit.py` traces orthodox/people and Black-risk routes in
  KO/EN for 960 scheduled weeks without language-dependent direction drift.
- `SceneDirectionCheck.tscn` and `LivingSceneCheck.tscn` reject same-location
  rewipes, unclassified movement, indoor weather, upward rain, portrait
  occlusion, and Reduce Motion camera travel.
- Real title-to-ending KO PlayStation and EN Xbox 240-week runs must print both
  `FULL_DIRECTION_RUNTIME_OK` and `FULL_INPUT_RUN_OK`, with zero keyboard/mouse
  rescue and zero unclassified runtime intent.
- The display matrix includes 960x600, 720p, 1280x800, 1600x900, 1080p, QHD,
  logical 4K, and 3440x1440. A passing logical 4K layout does not certify
  native-raster sharpness or a physical TV.
- Human gates remain mandatory for normal-speed repetition, motion sickness,
  transition taste, physical Steam Deck shader hitching, and chapter-by-chapter
  A/V listening.
