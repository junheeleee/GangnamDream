# Gangnam Dream Master Release Audit

Updated: 2026-07-10

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
| KO events | 1,477 | Consistent prose, reachability, pacing, or relevance |
| EN event overlays | 1,477 | Native English voice or cultural clarity |
| Choices per language | 3,316 | Meaningful tradeoffs or delayed consequence |
| Endings | 35 | Distinct emotional payoff or bespoke presentation |
| Explicit event CG links | 11 | Enough climax imagery for a commercial VN |
| Background assets | 55 | Canon continuity, physical logic, or correct event mapping |
| Character portrait assets | 37 | Flagship identity, expression coverage, or outfit continuity |
| CG files | 15 | Launch key moments and ending coverage |
| BGM / ambience / SFX | 7 / 25 / 30 | Loop fatigue, mix quality, ownership, or license proof |
| Achievements / easter eggs | 13 / 8 | Discovery quality or community conversation |
| Screenshot QA scopes | 22 | Full-playthrough correctness or subjective fun |

The first parity audit found eight EN-only overlay rows. DataRegistry silently ignored them because no KO base event existed, so translated scenes appeared to ship while no player could reach them. They are now promoted to complete bilingual events with conditions and consequences, and EN-only dead overlays fail CI.

## Current Product Diagnosis

These are confidence bands, not review scores. Every band must be replaced by play evidence.

| Dimension | Current band | Evidence / primary risk |
|---|---|---|
| Premise and social theme | Strong | 500K to 3B in five years, father debt, class pressure, moral erosion are immediately legible and culturally specific |
| First impression / IP | Developing | StartMenu now sells Minjun/Daeun/Jiyeon through a single-axis poster layout; final owned key art and custom wordmark are still missing |
| Flagship character appeal | Weak to developing | Portraits are readable, but props, silhouette grammar, leitmotifs, and promotional scene ownership were not locked |
| Core weekly loop | Weak to developing | The AP surface now leads with a 2x2 decision board, visible outcome/risk/echo cues, and a compact weekly stake; tactile execution and first-30-minute comprehension still need black-box proof |
| Story architecture | Unverified | Large authored spine exists, but a full black-box 240-week dramatic trace has not been critic-read end to end |
| Chapter pacing | Unverified | Content counts cannot prove that each act has escalation, reversal, climax, and breathing room |
| Choice consequence | Developing | Callback architecture is a real strength; immediate cost and player comprehension vary by event |
| Strategy /攻略 readability | Weak | The player cannot yet explain a viable 3B plan, risk bands, or why one run failed without external knowledge |
| Balance | Technically stable | Fixed policy simulations pass current bands; human fun, exploitability, and difficulty perception remain unverified |
| Writing quality | Uneven | Several flagship scenes are strong; ambient pool and EN overlays contain visible style variance |
| EN localization | Critical to developing | Zero-Hangul is clean, but native voice, pronouns, cultural context, and dead overlay parity require a full prose pass |
| UI/UX | Developing | Title and AP surfaces now have clear command hierarchies; several dense submodals and the top HUD still carry older dashboard grammar |
| Controller / Steam Deck | Developing | Brand-aware glyphs and several focus models exist; dense modals and large betting boards still require task-level tests |
| Image quality / continuity | Developing | Background/portrait separation and romance manifest exist; style generation eras and key-scene coverage remain visible |
| Audio identity | Developing | Context routing exists; only seven BGM tracks and no asset-license ledger create repetition and release risk |
| Motion / game feel | Weak to developing | AP commitment has a clearer board and feedback vocabulary, but input feel, audio tactility, and several navigation transitions still need measured play tests |
| Moral Tint impact | Promising, unproven | The thesis is distinctive; a complete neutral-to-White/Black run has not yet proven the player notices it without explanation |
| Endings | Developing | 35 outcomes and recap logic are substantial; bespoke visual/audio aftermath and critic-level final images are incomplete |
| Stability / save integrity | Good static baseline | Audit, compile, language, balance, and asset checks pass; full branch/save migration and long-session soak remain |
| Commercial package | Critical | Capsule and title screen are mood-led rather than character-led; no external conversion evidence yet |

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
- At least one AP action contains anticipation, performance, and payoff rather than a single menu click.
- A relationship hook, financial hook, and moral discomfort are all active.
- No required text is below the Steam Deck readability floor.
- The player voluntarily reads at least one result instead of skipping every card.

### Gate C: Demo End

- Six months ends on a dramatic question or irreversible consequence, not a calendar stop.
- The player understands what another run could change.
- EN and KO players receive the same events, choices, effects, CG timing, and ending teaser.
- Demo completion, replay intent, and wishlist intent are measured with external testers.

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
- Key art, title screen, story mode, AP, minigames, and endings look like one authored product.
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
