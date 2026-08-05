# Gangnam Dream Master Release Audit

Updated: 2026-08-03

## Mission

This is the final cross-discipline quality gate for Gangnam Dream. It covers the work as a game, a story, a bilingual release, a controller product, a visual IP, and a commercial Steam package.

Adjacent and top-selling execution references are assigned by surface in `docs/STEAM_QUALITY_BENCHMARKS.md`.

`Metacritic 90` and `one million copies` are ambitions, not promises. They are useful only when translated into observable gates:

- No review-killing weakness may remain in first impression, core loop, writing, controls, localization, stability, or asset legitimacy.
- The game needs at least three review-leading strengths that critics mention without prompting.
- The demo must create desire for another week, another relationship scene, and another run before asking for a wishlist.
- Market appeal is tested with strangers and store data, not inferred from content volume.

## Current 24-Week Demo RC Boundary

The current V2 line is an automated release candidate, not a human release
approval. Weeks 1–24 use the monthly four-promise loop on a full-width planning
board; a separate portrait contact phone contains only real messages, call
history, and reachable contacts. Week 24 ends at the midpoint of the 48-week
first chapter. Durable receipts continue to
Hyunsu's Week-27 result, the City Facilities Week-28 result, the exact
Week-48/96/144/192 closes and the Week-197 reckoning without replacing the
240-week ending.

Automated gates cover exact economy ledgers, choice/state round trips, one
fresh-boundary autosave, completed-save resume without another write, Korean
and English 720p surfaces, controller navigation contracts, all five chapter
handoffs and zero representative-path scheduler jams. Device tiers, purchases,
favorites, and phone-hosted finance or leisure are retired; valid legacy
refurbished-phone receipts receive one idempotent KRW 180,000 migration refund.
`runtime_default=false` stays locked until one unchanged RC
passes a normal-speed 75–95-minute play, physical Steam Deck/DualSense input,
continuous headphone/laptop/TV A/V review, external comprehension and a human
desire-to-continue verdict.

## Artifact Identity, Save, and Third-Party Notice Gate

Every full, demo, and V2 artifact must carry the same four canonical fields in
its StartMenu identity metadata, new save root, and build manifest:
`game_version`, `build_id`, `build_flavor`, and `save_namespace`; the visible
label renders version, build ID, and channel. Full is `full/legacy`, demo is
`demo/legacy`, and V2 is
`core_loop_v2_playtest/core_loop_v2_playtest_v1`; all three read version and
build ID from `BuildInfo`. Manifests also bind the save schema, features, full
Git revision/tree and artifact hashes. `build_identity_audit.py --self-test`
gates field drift and mutated profile fixtures.

Build ID and game-version differences are warnings, not compatibility keys.
Future save schemas and incompatible flavor/namespaces fail before player
state changes. Demo saves may enter the full build; full saves may not enter a
demo; both demo flavors reject saves beyond Week 24, and V2 stays isolated in
both directions. An incompatible slot remains
visible with its source and reason instead of becoming a silent load failure.

Settings reads third-party notices from the generated source-ledger view, not
hand-copied UI facts. The current surface contains one Godot Engine 4.6.2 entry,
three font families covering six files, and 21 audio sources covering 139
shipping files. Export filters include the Godot MIT text, all three OFL 1.1
copies, the exact Godot 4.6.2 bundled-component COPYRIGHT text, the generated
audio notice, and notice metadata. One audio source requires attribution;
the shipped horse file is credited from its D4XX/CC0 per-file record rather
than the mixed-license pack summary. Fresh Full and V2 export-pack ZIPs must
contain all ten notice/ledger files byte-for-byte, verified by
`third_party_notice_audit.py --pack-zip` alongside the release-content pack
inventory. KO/EN ScreenshotQA at
960x600 and 1280x800 must keep all three tabs, full license text, scrolling,
safe-area bounds, an inset between legal copy and the focus frame, and focus
restoration usable. The global V2 badge stays clear of StoryMode's dialogue-log
and settings commands; narrow Story HUD text is clipped/ellipsized inside its
reserved slot. Notice and monthly-planner surfaces hide the redundant floating
badge while the title/notice identity remains available, so it cannot cover a
header command. Automated hashes and renders
prove ledger/package/surface alignment; they do not replace human readability
or legal review.

## Release Content Inventory Gate

The machine-readable owner is `content/meta/release_content_inventory.json`;
the generated reviewer view is `docs/CONTENT_RATING_INVENTORY.md`. Every release
candidate must keep three scopes separate: content reachable in the 24-week V2
demo, content reachable in the 240-week full game, and content included in the
uploaded package but not currently reachable in that build. The current ten
export presets all use `all_resources`, so an inaccessible scene or minigame is
not absent from a V2 package merely because the demo route cannot enter it.

The ledger covers gambling, sexuality, violence, fear, language, crime,
alcohol/tobacco/drugs, generative AI, and online features. Every material fact
must name an owner, evidence, reachability, package inclusion, and expression
intensity. A full and V2 export-pack ZIP smoke must prove the complete packaged
event, ending, ledger, and 284-raster import inventories independently of
source-tree scans. The current technology baseline is
offline single-player: no runtime networking, multiplayer, chat, remote UGC,
telemetry, real-money payment, or live AI; one `OS.shell_open` leaves the game
for a Steam wishlist/store URL, and data-only mods read local `user://mods/`
files.

Official public references, checked 2026-08-03:

- [Steamworks Content Survey](https://partner.steamgames.com/doc/gettingstarted/contentsurvey?l=english)
- [Game Rating and Administration Committee rating rules](https://www.law.go.kr/LSW/schlPubRulInfoP.do?chrClsCd=&schlPubRulSeq=2200000127949)
- [Game Content Rating Board guide](https://www.gcrb.or.kr/Images/usingGuide/using_guide_01.html)
- [Game Industry Promotion Act](https://www.law.go.kr/LSW/lsInfoP.do?lsId=010196)

Steam's public guide divides the survey into General Content, Mature Content,
and Generative AI, and says uploaded adult content must be disclosed even when
it is inaccessible or unpresented. The Korean public rules and guide require a
separate evidence pass across sexuality, violence, fear, language, drugs
(including alcohol and tobacco), crime, and gambling. A Steam answer does not
automatically satisfy Korean classification.

Public pages do not expose every partner-only prompt and do not determine this
game's final age rating. Before submission, the owner must capture the live
partner/rating form, record its version and exact candidate build, and reconcile
it with the ledger. Final rating, deletion, and export-filter decisions remain
`user_required`; this audit is factual evidence, not legal advice. Required
survey disclosure also does not authorize store-page spoilers: the discovery-
hidden marketing rules in `docs/STEAM_PAGE.md` remain intact.

## Baseline Inventory

| Surface | Current baseline | What the number does not prove |
|---|---:|---|
| KO events | 1,597 | Consistent prose, reachability, pacing, or relevance |
| EN event overlays | 1,597 | Native English voice or cultural clarity |
| Choices per language | 3,506 | Meaningful tradeoffs or delayed consequence |
| Endings | 35 | Distinct emotional payoff or bespoke presentation |
| Event/result CG link instances | 40 | Enough climax imagery for a commercial VN; 38 owner events and 33 unique CG IDs |
| Active background PNG assets | 82 | Canon continuity, physical logic, or correct event mapping |
| Active character portrait PNG assets | 90 | Flagship identity, expression coverage, or outfit continuity |
| Active CG PNG assets | 74 | Launch key moments and ending coverage |
| Active raster resolution inventory | 246 | Native 4K quality, face/hand correctness, or TV viewing quality |
| BGM / ambience / SFX | 20 / 49 / 70 | Loop fatigue, mix quality, dramatic taste, or human listening approval |
| Achievements / easter eggs | 15 / 8 | Discovery quality or community conversation |
| Screenshot QA scopes | 78 | Full-playthrough correctness or subjective fun |

The first parity audit found eight EN-only overlay rows. DataRegistry silently ignored them because no KO base event existed, so translated scenes appeared to ship while no player could reach them. They are now promoted to complete bilingual events with conditions and consequences, and EN-only dead overlays fail CI.

## Current Product Diagnosis

These are confidence bands, not review scores. Every band must be replaced by play evidence.

| Dimension | Current band | Evidence / primary risk |
|---|---|---|
| Premise and social theme | Strong | 500K to 3B in five years, father debt, class pressure, moral erosion are immediately legible and culturally specific |
| First impression / IP | Developing to strong | One identity-locked Minjun/Daeun/Jiyeon key art now owns splash, StartMenu, and Steam capsules; external character recall and conversion remain unverified |
| Flagship character appeal | Developing | Portrait/CG outfit pairs, gaze contracts, scene-specific Minjun expressions, first-snow winter pairs, season-gated dates, and heroine-specific first-morning scenes now protect key heroine moments; general-cast seasonal coverage, leitmotifs, merchandise recall, and remaining T1/T2 work are incomplete |
| Core weekly loop | Scene-first weekly commitment passes, fun unproven | The base calendar exposes 52 scheduled Decision/Boss weeks distributed 13/9/10/10/10, 21 Echoes, 20 blocking summaries, and a final week-240 ledger absorbed into the ending. AP remains an internal economy budget, but a direct week now hides the AP chip, portrait rail, calculation board, Seoul Trace, and separate Next Week command. The random director permits only reviewed foreground scenes and state-causal single-choice bridges. Korean PlayStation and English Xbox runs reach the same `with_daeun` ending after 240 weeks and 218 events, recover one actual causal bridge, and use zero keyboard/mouse input. This is reachability and consequence-legibility evidence rather than a fun pass |
| Story architecture | Structural recomposition passed, Round 2 fun unproven | Seven demo sequences and a five-chapter causal spine now replace the original event-card schedule. Chapter 2 binds four causal sequences from the year ledger to the hospital door; Chapter 3 binds Jiyeon's distance, Jaehyuk's offer and consequence, Father's buried debt, and Minjun's changing definition of Gangnam across multiple weeks; Chapters 4-5 bind the guarantee bill, Hyunsu, Father visit/defer/KTX/passing/legacy, romance verdicts, and last signature. All 32 Tier-1 chains pass. Only a fresh human playthrough can overturn the user's narrative NO-GO |
| Chapter pacing | Causal distribution implemented, late path still lean | Representative roots now distribute `30/25/25/18/13` and `33/26/31/26/16`. Each route has one isolated Chapter-3 micro-scene; the curated random foreground appears 28/24 times with at least one window in every chapter. Chapter 1 holds eight chains, Chapter 2 four, Chapter 3 four temporal spines, and the late chapters preserve week-spanning body, family, relationship, and money consequences. Path A and Chapter 5 remain numerically lean; add no filler until recall and emotional carry are tested |
| Choice consequence | Bounded path debt automated, human regret unproven | Generic forgone applications, relationships, rest, study, shifts, savings, and market windows now persist by action/person and disclose a bounded delayed cost before the path is reopened. Costs are consumed only after successful completion; cancellation is free, investment uses actual price movement, missed income is never deducted twice, and declining gambling is unpunished. Authored event consequence quality still varies, and only human replay can prove regret rather than bookkeeping |
| Strategy /攻略 readability | Weak | The player cannot yet explain a viable 3B plan, risk bands, or why one run failed without external knowledge |
| Balance | Technically stable | Fixed policy simulations pass current bands; human fun, exploitability, and difficulty perception remain unverified |
| Writing quality | Uneven | Several flagship scenes are strong; ambient pool and EN overlays contain visible style variance |
| EN localization | Developing | First-run language selection, zero-Hangul, catalog parity, and localized canonical names are gated; native voice, pronouns, cultural context, and a full prose pass remain |
| UI/UX | Developing, direct weekly surface improved | StoryMode and direct weeks now share a restrained scene-first hierarchy: body copy is shadow-free, semantic text has 1px ink contact, and three choice surfaces use a 1px rest/2px focus/1px press contract across 720p, Deck, and 1080p. Direct weeks no longer return to a web-like AP dashboard, while the ending report remains a six-stage fullscreen controller sequence. MainGame still exposes 22 `_open_*` surfaces plus seven page renderers; People, gambling, routine, and Info Deck remain broader web/list debt |
| Controller / Steam Deck | Developing, two full automated routes proven | Brand-aware physical-position glyphs, shared keyboard/gamepad verbs, 18 direct casino/race routes, nine keyboard core minigame tasks, keyboard-only/mouse-only demo completion, and KO PlayStation/EN Xbox title-to-ending 240-week routes are gated. The full pad routes use zero keyboard/mouse input, perform the real first-week Job Hunt, consume all granted AP, enter all five chapters, and end as `with_daeun`. Physical Steam Deck/DualSense/Switch Pro hand feel, reconnect, suspend/resume, and overlay tests remain |
| Display / console readiness | Developing, automated layout matrix passed | Korean PlayStation and English Xbox runs now cover 960x600, 720p, 1280x800, 1600x900, 1080p, QHD, 4K, and 3440x1440. Sixteen real renders preserve exact output dimensions, TV-safe settings/AP/story controls, active focus, and distortion-free cover framing; 1080p adds all three glyph families. Physical handheld/TV checks, sofa-distance readability, suspend/resume, and certification remain. Sampled AP/world/romance art is still sourced at 1280x800, so 4K layout readiness is not native-raster readiness |
| Image quality / continuity | Developing, first P0 4K master passed | Background/portrait separation, romance outfit pairs, spatial bibles, 74 active CGs and 315 locked event visual contracts gate high-risk scenes. The 246-raster ledger blocks path and dimension regressions; 91 meet native 1080, 33 are native 4K, and 155 remain in the heavy/severe 4K enlargement band. `goshiwon_hallway` retains its official-tool/model/input/output hashes, full-frame inference, three 100% A/B crops, KO/EN 1080p and EN 4K runtime proof. Dimensions and one clean environment do not certify faces, hands, continuity, or physical TV viewing quality; those remain production and human gates |
| Audio identity | Developing, full catalog automated | All 139 files are recording/sample-backed and source-audited. Every one of 1,603 KO/EN events has one explicit audio intent, all 94 registered backgrounds have reviewed ambience profiles, and two deterministic KO/EN 240-week route traces cover five chapters, seven activities, and two ending families. Runtime prose inference and the universal room fallback are removed. Long-session taste, fatigue, mix balance, memorable identity, chapter-boss arrangements, and headphones/laptop/TV listening proof remain human gates |
| Motion / game feel | Developing, full direction catalog automated; human feel unproven | One generated ledger now classifies 1,603 events, 177 authored edges, 94 backgrounds, seven activities, and 35 endings. StoryMode, MainGame, LivingSceneLayer, and the audio catalog consume explicit location/time/channel contracts instead of localized-prose or hash inference. Automated KO/EN title-to-ending routes exercise the runtime direction owners and Reduce Motion removes camera travel. Input feel, repetition, transition timing, physical Deck hitching, and emotional tension still require normal-reading human replay |
| Moral Tint impact | Promising, partially embodied | Five KO/EN anchor scenes carry one hidden attention grammar from Daeun's cafe through Sangchul, Gangnam, Father, and the final countdown. Band crossings return to one canonical goshiwon/black-crewneck memory frame, identical result cards change attention order, and Gray now stays legibly distinct from both Black collapse and White recovery on naturally dark locations. Portrait distance, surface, lived ambience, and two non-jingle attention cues support the shift; a complete neutral-to-White/Black blind run still has not proven players notice it without explanation |
| Endings | Presentation gate passed, human impact unproven | Thirty-five save-compatible outcomes and eighteen explicit final-CG routes now end in six opaque controller-native stages: scene beats first, then credits, cast aftermath, Time Ledger, run record, and unlocks. Grade, assets, and turn count are absent from the first scene; the Jiyeon drawer cut follows credits. KO/EN title-to-ending pad routes traverse every stage, but external players must still prove recall, satisfaction, and shareability across multiple ending families |
| Stability / save integrity | Good automated baseline | Audit, compile, language, balance, asset, tutorial input-leak, and two title-to-ending 240-week controller routes pass. The full runs repaired the week-240 termination gap and same-week authored-root drain; full branch/save migration and long-session soak remain |
| Commercial package | Developing | Owned character key art, three Steam capsule sizes, and a localized first-run path exist; no external capsule conversion or wishlist evidence yet |

## 2026-07-17 Whole-Game Structure Baseline

The reproducible source is `python3 tools/game_structure_audit.py`; the design response is `docs/GAME_RECOMPOSITION_PLAN.md`.

This dated table is a frozen historical baseline. The current inventory is the table above; do not copy these 2026-07-17 counts into a release submission.

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

The accepted target keeps 240 internal weeks and default AP 2 but requires only 40-60 direct decision weeks. The six-month demo is the mandatory vertical slice: 8-10 decisions, two pressure peaks, three to five echoes, no unknown content loss, Korean/English parity, and controller-only completion. The user subsequently authorized whole-game recomposition while retaining the demo NO-GO, so full-run cadence may advance only as infrastructure for the same causal-novel edit, never as evidence that the slice is fun.

The cadence now passes its Round 3 structural contract. KO PlayStation and EN Xbox reach the CTA from the title with zero keyboard/mouse events, a real Job Hunt, and exactly one commitment in each of nine direct weeks. The same 24-week calendar contains seven Decisions, two Bosses, four no-input Echoes, eleven Quiet weeks, three blocking summaries, and six intact monthly economy passes. Current runs use 666/670 confirms across the same 47 events and preserve exact gameplay-state parity. Each commitment stores the chosen path, two forgone paths, and later echo through save/load; opening or canceling a submenu is mutation-free. This is a structural pass, not a player fun pass. A fresh user normal-reading replay remains mandatory.

Round 4 closes the completion boundary that remained inside that contract. Opening a job, study, relationship, investment, or side-shift surface only arms a pending commitment; AP and the durable ledger change after the actual application, assessment, target choice, transaction, or minigame settlement succeeds. A pre-action public snapshot yields concrete cash, portfolio, income, body, mind, visible skill, reputation, performance, affinity, and readiness deltas for the result card and one later Echo without exposing Moral, route, or hidden odds. Hovering a live AP card now transfers real GUI focus, so keyboard and controller navigation continue from the card under the pointer. The latest EN Xbox routes complete the demo in 670 confirms/47 events and the full 240 weeks in 3,183 confirms/221 events with 52 commitments, 20 Echoes, zero keyboard/mouse events, and `with_daeun`. The full audit passes 2,248 Japanese UI keys and all 55 scripts; human fun remains unproven.

The concrete market-settlement pass closes the remaining abstraction inside that boundary. Investment results now retain asset ID, side, fill price, quantity, fee, committed cash, proceeds, realized P/L, and leveraged exposure. Unlocked gambling can occupy the risky market choice, but entering a venue or reading rules spends nothing; only a completed race, hand, scalping run, or casino round records venue, count, trades, and session net before closing the week. Korean/English result scenes and saved Echoes name those facts, while Japanese UI parity reaches 2,284 keys. The full audit passes all nine direct minigame routes, three input modes, eight resolutions, existing economy bands, and 55-script compilation. This proves an honest settlement boundary, not player temptation or regret.

Round 5 removes the AP dashboard from the player's direct-week experience without deleting the economy beneath it. Decision/Boss weeks now expose only the current pressure and three world-backed choices; the AP HUD chip, portrait rail, weekly calculation board, Seoul Trace, and separate Next Week command stay hidden. Mouse hover and controller focus own the same card and crossfade the full background to that choice's location. A completed action leaves one compact `Actual Result / Closed Paths / Remaining Echo` scene ledger, whose confirmation advances immediately. Quiet/Echo beats use the previous commitment or routine location and matching ambience, while remote contact remains in the current home rather than pretending to be a cafe meeting. KO PlayStation and EN Xbox complete the 24-week slice in 658/662 confirms with nine direct commitments and four Echoes; EN Xbox completes 240 weeks in 3,132 confirms, 221 events, 52 commitments, and 20 Echoes. A freed-card lifetime defect found at week 37 was repaired and the full route then reached `with_daeun`. Human hesitation and enjoyment remain open gates.

The ORDER-28 content-diet pass removes random volume from the foreground without deleting data. After the ORDER-54 seed/harvest repair and ORDER-57 rent reminder, 64 of 1,032 runtime candidates may own a standalone StoryMode scene and 19 may resolve as one-choice causal bridges from seven material producer roots: six implicit bridge-only roots plus one hybrid root that also schedules its own delayed harvest. Multi-choice auto-commit is zero, demo random bridges are zero, and an eligible full-game bridge resolves once without reapplying the generic hidden-event chance. Representative A/B paths show 28/25 curated random windows, no isolated micro-scene in any chapter, and estimated structural runtimes of 221.0/244.6 minutes. Fresh Korean PlayStation and English Xbox runs finish the same 240 weeks, 226 events, two bridges, and `with_daeun` ending in 3,120/3,148 inputs. This closes a curation and causality gate only; the user's Demo Round 2 NO-GO remains authoritative.

User Demo Round 2 returned NO-GO. The problem is now measured as continuity rather than volume: 1,390 catalog events are standalone, 844 are short standalone cards, and the representative first chapter changes its inferred person/theme thread 42-43 times across 46 authored stops. The new vertical slice must present 7-9 causal novel sequences, demote unrelated micro-events into non-blocking bridges, and prove that choices are remembered by later scenes before any full-run rollout.

The 2026-07-18 full-run cadence prerequisite is now executable. Direct weeks total 52 with chapter counts `12/10/10/10/10`; five full-run bosses join the two demo bosses, Echoes total 20, and twenty blocking summaries precede a final week-240 ledger inside the ending. After the first causal pass across all five chapters, two representative paths retain 27-29 post-demo random-event windows with at least one in every chapter. A fixed structural reading model places the estimated two-hour line at weeks 107-110 and total runtime at 210.5-235.6 minutes. Legacy rhythm saves preserve authored/economy state while dropping only stale current-week locks, and current demo saves carry into the full build. These figures are regression evidence, not player telemetry or a refund-line claim.

Two actual-input full runs now sit behind that model. KO PlayStation completed in 3,242 confirms across 218 seen events, and EN Xbox completed in 3,299 confirms across 219 events; both started unemployed, took the visible Job Hunt into `job_01`, spent every granted AP, used zero keyboard/mouse input, and reached `with_daeun`. English StoryMode showed zero Hangul. The runs exposed and repaired a real week-240 termination gap and a StoryMode return loop that had stacked thirteen unrelated authored roots into week 194. Post-demo authored roots are now limited to one per week while immediate multi-part follow-ups remain intact; peak weekly input fell from 188 to 171/173. This is a reachability and pacing-bound pass only.

The ending surface has since passed its P0 interaction contract. The AP shell and tall report are replaced by six opaque, no-scroll stages; the full ending prose is retained as two-to-four scene beats, while grade, final assets, and turn count wait until the post-credits run record. The Jiyeon drawer truth cut now fires immediately after credits rather than behind a New Run or Main Menu command. A fresh EN Xbox run completed 240 weeks, 221 events, and 3,323 confirms; a fresh KO PlayStation run completed 240 weeks, 222 events, and 3,287 confirms. Both traversed all six pages with zero keyboard/mouse input. P0/P1 ending renders, Japanese UI-key parity, zero-Hangul English, all 55 scripts, and the full audit pass. Human emotional impact and ending-family recall remain unproven.

The full-run AP surface now also passes its contextual-pressure contract. The old neutral `turn % 3` cycle has been removed; live job and promotion timing, housing and rent cover, nearest person and recent money/human weeks, portfolio access, health/mental state, and weeks remaining select seven semantic families without mutating state. EN Xbox completed 240 weeks/219 events/3,257 confirms with 55 sampled pressure frames, seven families, at least three families in every chapter, and a maximum same-family streak of four. KO PlayStation completed 240 weeks/222 events/3,310 confirms with 59 frames, at least four families per chapter, and a maximum streak of three. Both used exactly three distinct bound actions per frame, zero fallback catalog visits, zero keyboard/mouse events, and kept the week 1/61/114/161/217 pressure panels inside the 1280x800 TV-safe rectangle. This closes the generic-menu regression, not the human meaningful-choice gate.

The 2026-07-19 input-profile convergence closes two schedule aliases without adding content. The unrelated Hyunsu exam/result root no longer collides with the Gangnam/six-month finale: Gangnam remains in week 22, the exam opens in week 23, and the formal result waits until week 25. Week-22 confirms fall from 70 to 34, while held South advances only the current event's prose and hard-stops before choices, chapter cards, results, and the next event. Capital pressure now opens on the third week of quarter-ending months rather than every month, preserving demo months 3/6 while freeing contextual families later. A fresh EN Xbox run completes the demo in 698 confirms/47 events and the full game in 3,316 confirms/222 events, with 58 pressure frames, seven families, at least four per chapter, a maximum streak of three, zero keyboard/mouse input, and the `with_daeun` ending. This remains automation evidence; Demo Round 2 is still NO-GO.

The first-session interaction grammar now distinguishes authored actions from decisions. Across all 108 prologue identities, seven one-choice, non-timed events expose their localized action on the final paragraph and commit it with one fresh input; they never open a one-item choice rail or trigger the choice portrait shift. AUTO and held prose input stop before the action, while true multi-choice scenes retain the full rail. Four canonical `same_location` edges continue without replaying the scene ink wipe or text-panel fade. The twelve-event prose and all effects remain intact, while the measured fast-input ceiling falls from 170 to 163. This is a trust and pacing gate, not evidence that the prose itself is emotionally sufficient.

The first-24-week scene-flow profile now gates spatial and dramatic continuity across the complete demo rather than only the opening. The original EN Xbox route exposed three same-location follow-up recuts, six follow-up moves without transition grammar, and five same-week unrelated conflict switches. First work, Hyunsu study, first investment loss, and first savings now occupy weeks 3, 11, 15, and 18; the week-20 job/investment scene owns Hyunsu's night mirror as a direct follow-up. Korean and English Xbox routes both complete the same 47 events with 24 roots, 23 follow-ups, ten continuous boundaries, and all three defect counters at zero. Their week-by-week cash, event order, pressure sequence, action choices, and final state are identical; only prose-length input counts differ at 689 versus 693. This is deterministic continuity evidence, not a reversal of the user's Demo Round 2 NO-GO.

The normal-reading experience profile now measures what those 47 events actually expose instead of treating confirm counts as playtime. Korean PlayStation estimates 67.3 minutes and English Xbox 58.9 minutes, with 36 meaningful choices, the first at 3.9/3.5 minutes, and a maximum later gap of 3.3/2.7 minutes. Both routes expose 15 backgrounds, 11 portraits, four CGs, ten place ambiences, four human-presence layers, five score keys, and 19/19 committed AP. Eight authored emotional transitions now use existing score motifs after place ambience establishes; ordinary scenes remain unscored. Rendered background IDs, not localized prose keywords, own ambience selection, eliminating three measured KO/EN location mismatches. These are duration, diversity, and parity gates only; the user's narrative NO-GO remains authoritative.

The second causal convergence pass removes isolated micro-scenes from all five chapters on both representative paths. Authored roots are now `26/25/26/16/13` and `28/24/32/23/15`; late milestones preserve week distance, current housing, and the required 2-billion-before-2.5-billion order. The dedicated Korean and English late-chapter suite renders 28 surfaces per locale and locks subway, Hangang, remote-call, live-home, ambience, and authored-silence ownership. This clears the structural and presentation regression gate only. Demo Round 2 remains NO-GO until a human player reports emotional continuity and meaningful choice.

Chapter 2 now demonstrates the full-run novel grammar outside the demo. Both representative paths stop 24 times, enter four causal chains and two Tier-1 peaks, and leave only two isolated micro-scenes. Korean and English 1280x800 evidence covers 18 surfaces each, including Jiyeon's street/cafe result, the parents' restaurant/current-home result, and the entered/deferred hospital door.

Chapter 3 now carries four explicit temporal spines through the weekly hub instead of pretending every causal link is an immediate scene cut. Representative paths stop 26/31 times, enter 15/20 temporal edges, reach 2/4 Tier-1 peaks, and leave zero isolated scenes. The deferred queue retains two events due in the same week and presents them one at a time; duplicate targets keep the earliest due week. Korean and English 1280x800 evidence covers 22 surfaces each, including live-housing messages, Father's remote call, Jaehyuk's two mirrors, the true 120-week midpoint, and year-three closure. The Chapter 1 pass below closes the next debt identified at that stage.

Chapter 1 foreground compression is now executable. Representative paths contain 26/28 roots, enter eight immediate chains, carry four/three temporal links, and leave zero isolated micro-scenes. First-paycheck, office-routine, and night-routine beats retain their effects as non-blocking bridges; survival jobs cannot show an office shift. Hyunsu's failure follows study, the week-20 job/investment mirror, exam, formal result, four-week aftermath, five-week drift, and six-week new path without the legacy pivot duplicating the outcome. Every goshiwon farewell reaches the first night in the live home. Korean and English 1280x800 evidence covers eight surfaces each, while the demo runtime gate locks scheduling, housing, job filtering, and the 3,800-won beer cost. This closes the first structural pass across all five chapters, not the user's emotional NO-GO.

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
- Every scheduled Echo names at least one exact committed action from the recent-action ledger; two different actions from the same money/human axis must not collapse into the same visible echo.
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
- Korean and English controller-input runs complete all 24 weeks, commit once in all nine direct weeks, exercise both money and human time through direct and automatic weeks, and stop on the week-25 CTA with no stale commitment overlay.
- PlayStation-position Korean and Xbox-position English routes start at the title, cross the splash/opening, use no keyboard or mouse, perform the real first-week Job Hunt, expose no fallback action catalog, and close each direct week only after one real commitment.
- Automated routing alone is not a pacing pass: the shipping slice must reduce 24 direct decision weeks to 8-10 decisions, two pressure peaks, and three to five short echoes without losing monthly economy, guaranteed arcs, or callbacks.

### Gate D: Full Run

- Every act has setup, escalation, reversal, climax, and aftermath.
- No flagship character disappears for a year without intentional narrative meaning.
- Every ending resolves money, Minjun's humanity, the father spine, and the player's strongest relationship.
- White, Gray, and Black routes have distinct visual, audio, prose, and interaction aftermath.
- A losing run is interpretable; a winning run is not reducible to one forced exploit.
- A random event that claims to follow from the player's recent behavior cites an exact compatible action when one exists, survives save/load, and falls back safely for legacy saves without exposing hidden Moral or route values.

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

### Data-Only Mod Safety (P3, Non-Blocking)

- Community events enter only the random pool. Built-in story rewrites require explicit `override=true` while preserving conditions, timing, follow-ups, and choice count.
- New mod-owned state uses the `mod_` namespace. Invalid flags, blank display copy, unsafe IDs, and cross-pack follow-ups fail closed.
- Balance presets merge only existing job, asset, item, and news IDs and cannot change field types or nested catalog schemas. Declared load order is deterministic and later values win.
- Moral themes retain the hidden `black/gray/white` structure and may alter fixed color values only. Default, color-vision, and high-contrast presets remain selectable without exposing a morality score.
- The in-game list controls enable state and order for data layers, while saves record active mod IDs for reproducible bug reports. Script and native-code loading remain unsupported.
- This is a community and DLC authoring surface, not a release-quality substitute. It cannot waive any story, balance, save, accessibility, or black-box gate above.

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
