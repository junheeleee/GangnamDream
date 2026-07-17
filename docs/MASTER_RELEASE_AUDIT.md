# Gangnam Dream Master Release Audit

Updated: 2026-07-17

## Mission

This is the final cross-discipline quality gate for Gangnam Dream. It covers the work as a game, a story, a bilingual release, a controller product, a visual IP, and a commercial Steam package.

Adjacent and top-selling execution references are assigned by surface in `docs/STEAM_QUALITY_BENCHMARKS.md`.

`Metacritic 90` and `one million copies` are ambitions, not promises. They are useful only when translated into observable gates:

- No review-killing weakness may remain in first impression, core loop, writing, controls, localization, stability, or asset legitimacy.
- The game needs at least three review-leading strengths that critics mention without prompting.
- The demo must create desire for another week, another relationship scene, and another run before asking for a wishlist.
- Market appeal is tested with strangers and store data, not inferred from content volume.

## Baseline Inventory

| Surface | Current baseline | What the number does not prove |
|---|---:|---|
| KO events | 1,555 | Consistent prose, reachability, pacing, or relevance |
| EN event overlays | 1,555 | Native English voice or cultural clarity |
| Choices per language | 3,433 | Meaningful tradeoffs or delayed consequence |
| Endings | 35 | Distinct emotional payoff or bespoke presentation |
| Explicit event/result CG links | 32 | Enough climax imagery for a commercial VN |
| Background PNG assets | 79 | Canon continuity, physical logic, or correct event mapping |
| Character portrait PNG assets | 62 | Flagship identity, expression coverage, or outfit continuity |
| CG PNG files | 60 | Launch key moments and ending coverage |
| BGM / ambience / SFX | 14 / 46 / 53 | Loop fatigue, mix quality, ownership, or license proof |
| Achievements / easter eggs | 15 / 8 | Discovery quality or community conversation |
| Screenshot QA scopes | 62 | Full-playthrough correctness or subjective fun |

The first parity audit found eight EN-only overlay rows. DataRegistry silently ignored them because no KO base event existed, so translated scenes appeared to ship while no player could reach them. They are now promoted to complete bilingual events with conditions and consequences, and EN-only dead overlays fail CI.

## Current Product Diagnosis

These are confidence bands, not review scores. Every band must be replaced by play evidence.

| Dimension | Current band | Evidence / primary risk |
|---|---|---|
| Premise and social theme | Strong | 500K to 3B in five years, father debt, class pressure, moral erosion are immediately legible and culturally specific |
| First impression / IP | Developing to strong | One identity-locked Minjun/Daeun/Jiyeon key art now owns splash, StartMenu, and Steam capsules; external character recall and conversion remain unverified |
| Flagship character appeal | Developing | Portrait/CG outfit pairs, gaze contracts, scene-specific Minjun expressions, first-snow winter pairs, season-gated dates, and heroine-specific first-morning scenes now protect key heroine moments; general-cast seasonal coverage, leitmotifs, merchandise recall, and remaining T1/T2 work are incomplete |
| Core weekly loop | Structurally weak, redesign specified | The calendar currently asks for up to 480 AP commits; even montage leaves an estimated 141-142 stopping weeks. Manual quiet weeks draw random content while montage silently skips it. The 240-week calendar can stay, but pacing must move to 40-60 authored decision weeks under one invisible director |
| Story architecture | Unverified | Large authored spine exists, but a full black-box 240-week dramatic trace has not been critic-read end to end |
| Chapter pacing | Front-loaded | Representative authored paths distribute 46/29/14/16/12 and 46/27/16/19/12 beats across Years 1-5. Each chapter now needs a setup, escalation, reversal, pressure boss, and aftermath rather than more undirected events |
| Choice consequence | Developing | Callback architecture is a real strength; immediate cost and player comprehension vary by event |
| Strategy /攻略 readability | Weak | The player cannot yet explain a viable 3B plan, risk bands, or why one run failed without external knowledge |
| Balance | Technically stable | Fixed policy simulations pass current bands; human fun, exploitability, and difficulty perception remain unverified |
| Writing quality | Uneven | Several flagship scenes are strong; ambient pool and EN overlays contain visible style variance |
| EN localization | Developing | First-run language selection, zero-Hangul, catalog parity, and localized canonical names are gated; native voice, pronouns, cultural context, and a full prose pass remain |
| UI/UX | Developing, over-surfaced | StoryMode and demo AP now share a restrained text/material hierarchy: body copy is shadow-free, semantic text has 1px ink contact, and choice surfaces use a 1px rest/2px focus/1px press contract across 720p, Deck, and 4K. MainGame still exposes 22 `_open_*` surfaces plus seven page renderers; People, gambling, routine, Info Deck, and ending report remain broader web/list debt |
| Controller / Steam Deck | Developing, automated routes proven | Brand-aware physical-position glyphs, shared keyboard/gamepad verbs, 18 direct casino/race routes, nine keyboard core minigame tasks, keyboard-only/mouse-only completion, and title-to-CTA KO PlayStation/EN Xbox 24-week demo routes are gated. The pad routes use no keyboard or mouse, perform the real first-week Job Hunt, consume all available primary AP, and never escape through the fallback catalog. Physical Steam Deck/DualSense/Switch Pro hand feel, reconnect, suspend/resume, and overlay tests remain |
| Display / console readiness | Developing | 720p, 1280x800, 1080p, QHD, 4K, and 3440x1440 real renders preserve TV-safe settings/AP/story surfaces and 21:9 expands the scene without moving decisions offstage. Physical handheld/TV checks, sofa-distance readability, suspend/resume, raster-master review, and platform certification remain |
| Image quality / continuity | Developing | Background/portrait separation, romance outfit pairs, spatial bibles, 57 active CG and 172 locked event visual contracts now gate high-risk scenes. Four summer/fireworks peaks lock staged transport/location and final-only effects; Daeun's first-night chain locks actual current housing and indoor rain, while Hyunsu's reunion separates remote home messages from a dedicated old-alley gukbap restaurant with an empty two-person table. Explicit winter/night/private-room/transit/cast/cultural art debts remain, so recurring-cast seasons and climax coverage are still incomplete |
| Audio identity | Developing | All 113 files are project-owned, reproducible, and source-audited; 14 scores, 46 ambience beds, and 53 effects have scene contracts. `rain_room` separates indoor rain-on-glass from outdoor particles and stays continuous through Daeun's first-night chain. Long-session musical grammar, one memorable four-note identity, chapter-boss arrangements, and human listening proof remain |
| Motion / game feel | Weak to developing | AP commitment has a clearer board and feedback vocabulary, and chained story scenes no longer flash the AP shell between them; input feel and several navigation transitions still need measured play tests |
| Moral Tint impact | Promising, partially embodied | Five KO/EN anchor scenes carry one hidden attention grammar from Daeun's cafe through Sangchul, Gangnam, Father, and the final countdown. Band crossings return to one canonical goshiwon/black-crewneck memory frame, identical result cards change attention order, and Gray now stays legibly distinct from both Black collapse and White recovery on naturally dark locations. Portrait distance, surface, lived ambience, and two non-jingle attention cues support the shift; a complete neutral-to-White/Black blind run still has not proven players notice it without explanation |
| Endings | Developing, wrong reveal order | Thirty-five save-compatible outcomes and eighteen explicit final-CG routes are substantial, but the current Grade/stat report arrives before emotional closure. Final scene, silence, title, and credits must precede records and statistics; the IDs should read as 8-10 finale families with state variants |
| Stability / save integrity | Good static baseline | Audit, compile, language, balance, asset, and tutorial input-leak checks pass; full branch/save migration and long-session soak remain |
| Commercial package | Developing | Owned character key art, three Steam capsule sizes, and a localized first-run path exist; no external capsule conversion or wishlist evidence yet |

## 2026-07-17 Whole-Game Structure Baseline

The reproducible source is `python3 tools/game_structure_audit.py`; the design response is `docs/GAME_RECOMPOSITION_PLAN.md`.

| Measured surface | Baseline | Release implication |
|---|---:|---|
| Events / authored / random pool | 1,565 / 388 / 1,177 | Stop adding volume; curate priority and causality |
| Representative authored path | 117-120 beats | Enough material for one run; pacing and selection are the work |
| Manual AP ceiling | 480 commits | Cannot ship as the default dramatic rhythm |
| Estimated montage stopping weeks | 141-142 | Current compression is insufficient |
| Longest authored gap | 11 weeks | Quiet time is valid only when deliberate and legible |
| Monthly summaries | 60 | Compress to quarterly/exceptional presentation while preserving monthly economy |
| AP functions / routine kinds | 42 / 4 | Do not add actions; contextualize existing ones and expand routine representation |
| Independent minigame/hub surfaces | 13 | Keep as optional fantasy, but return consequences to the main narrative |
| Endings / explicit final CG | 35 / 18 | Preserve IDs, group emotional finales, and put scenes before reports |

The accepted target keeps 240 internal weeks and default AP 2 but requires only 40-60 direct decision weeks. The six-month demo is the mandatory vertical slice: 8-10 decisions, two pressure peaks, three to five echoes, no unknown content loss, Korean/English parity, and controller-only completion. Full-game migration is forbidden until that slice is materially better in black-box play.

The 2026-07-17 pad black box proves routing but fails pacing. KO PlayStation and EN Xbox reach the CTA from the title with zero keyboard/mouse events, a real Job Hunt, zero fallback actions, and every AP actually granted consumed through a primary card; observed budgets vary from 47 to 49 because authored month-start crises and bonuses can change weekly AP. Repeated employment/capital frames were repaired and capital appears at most once per month. Representative runs still require about 1,008/1,012 confirms, 24 direct decision weeks, 171/173 inputs in week one, and 91/90 in week 23. This is a regression baseline, not a fun pass; Quiet/Echo/Decision scheduling remains the P0 blocker.

### Strategy convergence baseline

The deterministic 3,000-run comparison now gates five 240-week policies. Safe career, aggressive investing, people-first, pure gambling, and founder play have five distinct dominant terminal identities. Mean pairwise ending JSD is 0.989, median human-axis use spans 220 weeks, and Moral Tint spans 52 points. No hidden asset catch-up or leader suppression exists in live source.

The labeling and dramatic-ownership blocker is repaired without inflating returns. Salary-only play reaches 3B in 0% of modeled runs by design. The aggressive investor now resolves to `investment_master` in 93.4% of runs, and the rare founder acquisition resolves to `startup_exit` instead of generic Gangnam. A nine-case live `check_game_over()` gate locks startup, generic Gangnam, investment, orthodox, unorthodox, balanced, and career priority. The source and limits are recorded in `docs/CONVERGENCE_REPORT.md`.

## Three Potential Review-Leading Strengths

These are the features that can plausibly lead a positive review. Everything else supports them.

1. **Moral consequence without a morality meter:** Minjun and the world visibly clear or decay while the game refuses to label the player good or evil.
2. **Korean class reality as playable pressure:** rent, family debt, comparison, jobs, speculation, and Gangnam are systems and relationships rather than exotic set dressing.
3. **Choices that return months or years later:** the callback structure makes small behavior become memory, reputation, relationship, and ending language.

If a feature does not strengthen one of these, improve usability or create delight, it is a candidate for compression.

## Quality Gates

### Gate A: First 10 Minutes

- A stranger can name Minjun, the 500K/3B/five-year premise, and one person they want to meet again.
- Title screen reads as a character drama at capsule distance and as a game under controller focus.
- Opening interview and AP job search feel like one career pipeline.
- No tutorial paragraph explains Moral Tint.
- The first meaningful choice has an immediate visible cost and a later promised echo.

### Gate B: First 30 Minutes

- The player can state a short-term plan for the next three weeks.
- Each playable demo week presents one legible pressure and exactly three contextual responses before exposing the full action catalog.
- Every primary response shows expectation, cost, a qualitative risk band, and a one-to-three-week echo before commitment without exposing Moral Tint or route scores.
- At least one AP action contains anticipation, performance, and payoff rather than a single menu click.
- A relationship hook, financial hook, and moral discomfort are all active.
- No required text is below the Steam Deck readability floor.
- The player voluntarily reads at least one result instead of skipping every card.
- Authored rain, snow, memory, city-light, and fireworks scenes have perceptible depth or air while ordinary interiors do not receive decorative particles.

### Gate C: Demo End

- Six months ends on a dramatic question or irreversible consequence, not a calendar stop.
- The player understands what another run could change.
- EN and KO players receive the same events, choices, effects, CG timing, and ending teaser.
- Demo completion, replay intent, and wishlist intent are measured with external testers.
- Korean and English controller-input runs complete all 24 weeks, exercise both money and human time, and stop on the week-25 CTA with no stale AP overlay.
- PlayStation-position Korean and Xbox-position English routes start at the title, cross the splash/opening, use no keyboard or mouse, perform the real first-week Job Hunt, never open the fallback action catalog, and consume every AP actually granted.
- Automated routing alone is not a pacing pass: the shipping slice must reduce 24 direct decision weeks to 8-10 decisions, two pressure peaks, and three to five short echoes without losing monthly economy, guaranteed arcs, or callbacks.

### Gate D: Full Run

- Every act has setup, escalation, reversal, climax, and aftermath.
- No flagship character disappears for a year without intentional narrative meaning.
- Every ending resolves money, Minjun's humanity, the father spine, and the player's strongest relationship.
- White, Gray, and Black routes have distinct visual, audio, prose, and interaction aftermath.
- A losing run is interpretable; a winning run is not reducible to one forced exploit.

### Gate E: Metacritic 90 Candidate

- Zero P0 and P1 defects in two independent full playthrough passes.
- External critics identify the same three intended strengths without being briefed.
- Native Korean and native English editors approve flagship prose; machine-like lines are absent from sampled ambient pools.
- Controller-only completion is possible without mouse rescue or focus hunting.
- 720p, Steam Deck, 1080p, QHD, 4K, and 21:9 preserve the same command hierarchy without stretched art, clipped text, or unsafe-edge controls.
- Key art, title screen, story mode, AP, minigames, and endings look like one authored product.
- Story motion remains readable and nonblank at 1080p/4K, preserves faces and text, honors Reduce Motion, and never replaces branch logic with an unskippable video.
- Asset source, license, and modification records are complete.

### Gate F: Million-Copy Commercial Candidate

- Capsule, trailer opening, and demo all sell the same character conflict.
- Unprompted testers remember a character, quote, object, or visual transformation after 48 hours.
- Store-page and trailer variants are tested rather than chosen by taste alone.
- Wishlist growth, demo completion, replay intent, refund reasons, creator coverage, and regional response justify scaling spend.
- Korean specificity remains legible abroad without flattening the work into a generic office-life simulator.

## Audit Tracks

| Track | Black-box evidence | Source/data evidence | Output |
|---|---|---|---|
| Story / chapters / endings | Full run video, emotion map, skip points | Trigger graph, dead branches, act density, callback payoff | Act-by-act rewrite/fix queue |
| Game loop / balance / strategy | Decision diary, failure comprehension, exploit hunt | SimRun policies, economy model, AP value distribution | Strategy surface and balance changes |
| Characters / IP | Recall test, preference reasons, scene ownership | Portrait/CG manifest, appearance cadence, relationship states | Flagship identity sheets and key scenes |
| UI/UX / Deck | Controller-only task timings, misfocus log | focus graph, text size scan, scroll inventory | No-mouse interaction pass |
| KO/EN writing | Native read-aloud and context test | ID/choice/effect parity, Hangul leak, terminology audit | Paired prose fixes and glossary |
| Art / motion / moral surface | Screenshot filmstrip by route | asset mapping, outfit/gaze/layout manifests, shader state | Visual replacement and staging queue |
| Audio | Long-session loop fatigue, mix notes | route map, loudness, source/license ledger | Theme/stem/SFX replacement queue |
| Stability | Full runs, suspend/resume, save migration | compile, audit, soak, branch coverage | Release blocker list |
| Commercial | Blind capsule/trailer/demo tests | funnel metrics and regional feedback | Go/no-go evidence |

## Severity

- **P0:** Prevents launch, breaks save/progression, exposes wrong language, creates legal risk, or destroys first-session trust.
- **P1:** Likely review complaint, refund trigger, controller blocker, major continuity break, or weakens a flagship scene.
- **P2:** Polish, coverage, secondary clarity, optional route improvement.
- **P3:** Delight, deep-cut easter egg, collector surface, post-launch candidate.

## Current Execution Order

1. IP identity and title-screen rebuild.
2. Six-month demo black-box pass and AP loop redesign.
3. Bilingual prose and chapter/ending dramatic trace.
4. Controller/Deck task audit across every dense surface.
5. Image, audio, motion, and Moral Tint climax pass.
6. Full-run stability and commercial package gate.

This order can move only when a newly discovered P0 blocks it.
