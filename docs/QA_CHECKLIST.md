# Gangnam Dream QA Checklist

Use this checklist before major commits, playable builds, and release candidates.

Cross-discipline release gates and current product risks live in `docs/MASTER_RELEASE_AUDIT.md`.

## Controller / Steam Deck Release Gate
- Controller support is a release gate, not a polish extra. See `docs/CONTROLLER_UX_STRATEGY.md`.
- Focus traversal is the last resort, not the default controller model. Gameplay uses direct contextual actions or a semantic mode/cursor; focus is reserved for settings and short conventional lists.
- A first-time player must complete the first 15 minutes with controller only: no mouse, no keyboard, no hidden shortcuts.
- Every major screen must present a default active selection or contextual action within 0.5 seconds. Only a conventional menu needs an actual GUI focus owner.
- No short menu should force the player through more than 12 focusable targets in one rail; gameplay must not become a focus rail at all.
- Casino minigames must pass controller-only flow: change stake, place bet, read bet, start round, read result, repeat/exit.
- Dense casino layouts such as Dai Sai and Roulette must use mode/cursor models, not flat focus traversal over every visible bet button.
- `A/South` confirms the highlighted item, `B/East` backs out or clears pending action, `Y/North` opens rules/details, `LB/RB` changes group/tab/mode.
- When the right-side Info Deck is open, `B/East` must close it instead of opening the system menu.
- Basic actions must not require hidden multi-button chords.

## Display / Console Readiness Gate
- Windowed mode remains freely resizable down to the explicit 960x600 minimum; resizing never loses focus, hides a primary command, or requires restarting the scene.
- Validate 960x600, 1280x720, 1280x800, 1920x1080, 2560x1440, 3840x2160, and one 21:9 viewport. This is one responsive layout system, not seven manually positioned variants.
- Story text, AP decisions, casino controls, result actions, and subtitles stay inside a central safe area suitable for TV overscan and handheld edges.
- Backgrounds and CGs use aspect-cover cropping without geometric stretching. Faces, gaze targets, decisive hands, cards, chips, and result states survive every supported aspect ratio.
- QHD/4K text and vector surfaces remain native-sharp. Raster masters must not reveal obvious 1280px upscale softness at normal viewing distance.
- A platform glyph changes presentation only. Xbox/Steam Deck, DualSense, and Nintendo controllers preserve the same semantic South/East/West/North actions.
- Controller-only suspend/resume restores the last safe focus and never advances prose, confirms a bet, or consumes AP on wake.
- Gamepad vibration is optional and intensity-controlled. Repeated prose/menu confirms do not buzz continuously; semantic pulses are reserved for tactile table actions, race impacts, real danger, and major result beats.

## Targeted Screenshot QA
- Run screenshot QA for the surface you changed, not the entire visual suite by default.
- Use full `surface-en` or casino QA only before release candidates, before/after broad UI refactors, or when casino/minigame code changed.
- Keep the user-facing proof focused: inspect the PNGs for the modified surface, then run static audits.

| Change area | Fast QA command |
|---|---|
| First-run language gate, KO default names, localized portrait name tags | `--qa=locale-gate` |
| Prologue motivation imprint: Knee, Last Payment, notebook choices, persistent goal sentence, notebook modal, montage, and month-end ritual | `--qa=motivation-imprint --lang=ko/en` |
| Tier-1 peak scene chain count, meaningful decision points, StoryMode panels, dialogue exchange, and KO/EN choice parity | `python3 tools/peak_scene_chain_audit.py --strict` |
| Father peaks and wardrobe: Changwon hospital geography, local Minjun before Father's physical reveal, patient gown in ward scenes, old home clothes in Changwon-home meetings/calls, corrected opaque skin/clothing color, actual current-housing last call, winter Seoul KTX platform, Seoul deal room, empty Changwon ward, next-morning remote call, canonical terminal effects, and KO/EN fit (20 shots per language) | `--qa=father-peaks --lang=ko/en` |
| Father 23-second KTX chain: Seoul-bound geography after Changwon Jungang, optional artifact-memory link, remote home-clothes memory inset, final call/no-call fit, unchanged terminal effects/flags, and KO/EN fit (8 shots per language) | `--qa=father-ktx --lang=ko/en` |
| First-kiss chains: Daeun's dawn convenience-store alley, Jiyeon's empty left-hand-drive sedan prelude, Jiyeon in the left driver seat and Minjun in the right passenger seat, no effects before the final choice, exact kiss/defer terminal effects, result pagination, and KO/EN fit (14 shots per language) | `--qa=first-kiss --lang=ko/en` |
| Jaehyuk peaks: hotel-pitch CG ownership, current-housing ghost/mirror continuity, two ghost buildup routes, two guarantee buildup routes, artifact-hidden 2/visible 3 choices, ten-second mirror decision, exact betrayal/guarantee terminal state, crossed-line scar clamp, and KO/EN fit (17 shots per language) | `--qa=jaehyuk-peaks --lang=ko/en` |
| Home peaks: continuous summer travel outfit and rural table, two stat-free Mother's Table buildup routes, paragraph-delayed night-bus CG, continuous Narrow Room CG/outfit/geometry, two stat-free room buildup routes, father-death/records-known text variants, four exact terminal states, and KO/EN fit (21 shots per language) | `--qa=home-peaks --lang=ko/en` |
| Prepared Japanese/Chinese arbitrary-character wrapping and 1280x800 safe area | `--qa=i18n-layout --lang=ja/zh-CN/zh-TW` |
| Splash, opening, StartMenu press-any-key, start menu, content notice | `--qa=start-en` |
| Archive CG silhouettes/fullscreen preview, scene replay paging, hidden-name secrecy, and read-only GameState/MetaProgression invariants | `--qa=gallery --lang=ko/en` |
| Five year identities, year-scene curation, Y1 timed choice, Y5 week countdown, and ending five-scene recap | `--qa=year-identity --lang=ko/en` |
| Steam store sequence: cold-open, money-mule timer, montage, time ledger, identical bright/dark scene pair, seasonal date CG, and five-scene ending recap | `--qa=store --lang=en` then `StoreScreenshotExport.tscn` |
| Active raster inventory and completed human verdict ledger for every CG, portrait, and background | `python3 tools/art_ai_audit.py` |
| A/B/C narrative detail hierarchy: authored actors remain readable, anonymous extras alone become low-detail silhouettes, and wedding focus stays Minjun/Daeun/conditional Hyunsu | `python3 tools/cast_detail_contract_check.py` |
| Store trailer sources: 22 actual Godot surfaces covering goal, timer, tint, romance, rupture, time records, investment, and minigames | `--qa=trailer --lang=ko/en` at 1920x1080 |
| StoryMode/VN flashforward Black→arrival Gray reset, intro events, 1~4-choice lower dock, readable backgrounds, chapter card, scene direction framing | `--qa=story-en` |
| Restrained body/title/choice/state material at 720p, Steam Deck, and 4K | `TextMaterialCheck.tscn`, then `--qa=text-material --lang=en` |
| StoryMode non-CG Black/Gray/White luminance, forced-Black framing, same-scene perception prose, moral choice wording, portrait distance, result-attention order/counterweight preservation, and KO/EN crop | `--qa=story-moral --lang=ko/en` |
| Authored Moral Perception anchors: Daeun cafe, Sangchul mirror, why Gangnam, father's last call, and final countdown across Black/Gray/White prose and choices | `--qa=moral-anchors --lang=ko/en` |
| Romance CG Gray/Black/White color hierarchy and no-HUD climax framing | `--qa=romance-cg` |
| Romance portrait outfit/scale against exact paired CG contract | `--qa=romance-portraits` |
| Namsan route cable car→restaurant→observation-deck paragraph backgrounds, paired portraits, lock CG intro/choices | `--qa=namsan --lang=ko/en` |
| Amusement routes: parade→helping CG/result fork, coaster→correct booth→choice-only four-cut CG, KO/EN crop and expression continuity | `--qa=amusement --lang=ko/en` |
| Daeun hometown route: interior train→separate maternal dining room→delayed night-bus result CG, summer outfit and KO/EN crop continuity | `--qa=hometown --lang=ko/en` |
| First nights: 3-link/2-decision heroine-specific buildup→four terminal state paths→tasteful fade→paragraph-delayed morning CG, same home/outfit, late-game month HUD, KO/EN 16 shots each | `--qa=wedding-morning --lang=ko/en` |
| Seasonal romance peaks: four 3-link/2-decision routes, KTX→East Sea/Haeundae and pre-launch Hangang→first explosion transitions, state-free buildup, final-only CG/effect/audio, ten exact terminal states, and KO/EN fit (30 shots per language) | `--qa=season-peaks --lang=ko/en` |
| Commitment scenes: Daeun's three-link last-cup→next-year→proposal buildup; four-link mother reaction→groom-side state→groom-enters-first/bride-enters-later couple wide→couple close wedding; mother honju hanbok, Father honju suit, living/passed Father × Hyunsu-alone variants, truly empty reserved chair and no invented spouse/child; only Minjun/Daeun identifiable in couple frames; no premature marriage flags; final accepted delayed CG/no-CG defer branch; exclusive small/full wedding choice persistence; legacy small fallback; and Jiyeon's three-link pre-decision class-gap chain with final-only cost/flag effects (38 shots per language) | `--qa=commitment --lang=ko/en` |
| Romance ruptures: two state-free buildup paths per heroine, canonical married homes, Daeun offscreen in the kitchen, artifact-locked 2/3-choice finals, six exact terminal states and endings, non-separating branches with no leaked CG, and paragraph-delayed seal/departure CGs (28 shots per language) | `--qa=breakup --lang=ko/en` |
| First snow: December-only store/car prelude→paragraph-1 CG, winter outfits, exactly two cans, left-driver/right-passenger seating, resting wipers, gaze and KO/EN crop | `--qa=first-snow --lang=ko/en` |
| Climate portraits: monsoon rain shell, heatwave short sleeves/cooling towel, cold-snap parka/scarf and dedicated frozen street | `--qa=climate --lang=ko/en` |
| Event visual contracts: seasonal Minjun clothing, rainy room/street split, road-facing wallet bus-stop bench, visible bungeoppang cart, full-scene Seollal bow CG, year-close wardrobe, father phone location, split cafe identities/name tags/paragraph reveal, choice-result location/ambience, and flag-dependent character stages | `--qa=event-visuals --lang=ko/en` |
| Story presence contracts: remote Father/contacts use a compact call or memory inset instead of standing in the current room, local message reactions keep Minjun full-size, in-person scenes reset to the normal portrait, and English channel/name labels contain no Hangul | `StoryPresenceCheck.tscn` plus `--qa=story-presence --lang=ko/en` |
| Weekly immersion loop: season/housing opening line, one-to-three-week authored-arc omen, rent countdown/due state, and action-causal StoryMode frame | `--qa=immersion-loop --lang=ko/en` |
| Main AP full-height in-world stills, Seoul Trace visited/locked nodes, warning state, people pressure grind hints, routine/date, Work/Money/Self-Dev/People/Life modals, four-scene gambling selector, market/info/keepsake surfaces | `--qa=ap-en --lang=ko/en` |
| AP Act 1~5 2x2 decision board, actual KRW 500K first-month horizon, post-first-interview `Keep Applying`, action-commit overlay, Seoul Trace restoration, no-scroll special-action row, ACT4 relationship pressure modal, AP result persistence until confirm, and focus return to the selected parent card | `--qa=ap-act-en --lang=ko/en` |
| One-time investment terminology/risk guide, controller default focus, then Trade/Holdings/Market movers/Bank pages in Korean and English | `--qa=invest-en --lang=ko/en` |
| Demo boot surfaces, t=1~8 story chain, AP loop, month summary, demo ending CTA | `--qa=demo-blackbox --lang=ko/en --demo-build` |
| Full demo input route: real confirm inputs through StoryMode, choices, AP, results, month summaries, and the week-24 CTA | `--qa=demo-input --lang=ko/en --demo-build` |
| Demo month summary, demo ending CTA, 6-month Time Ledger card | `--qa=demo-end-en` |
| P0 final-life endings: eight exact CG owners, 950x430 crop, Jiyeon reflection-only mirror with exactly two non-duplicated actors and coherent gaze, 1B Second Love across-river home, Jiyeon-mediated Gangnam framing, White/Deep Black readability, and KO/EN first viewport | `--qa=ending-p0 --lang=ko/en` |
| P1 final-life endings: exact CG owner/crop, Late Call memory, Rich and Alone base/divorce/no-leak, One More Circle base/Father-memory calendar action, distinct Bankruptcy/Debt Spiral calculation states, Startup Exit base/first-user memory, and 33-year-old first-year Myth arrival | `--qa=ending-p1 --lang=ko/en` |
| Train semantics: summer/date and Father-call scenes remain inside the train, while the holiday decision remains on the provincial platform | `--qa=transport --lang=ko/en` |
| Representative ending modals, graded CG/card surface, exact dedicated symbols for Ordinary Life/Burnout/Mental Collapse/Stable Success, fallback mood cards, and final Time Ledger card | `--qa=endings-en --lang=ko/en` |
| Title collection and meta-title reward surface | `--qa=title-en` |
| Tutorial overlay surface and onboarding copy | `--qa=tutorial-en` |
| Job hunt/career modal tier pages and resume/interview minigame surface | `--qa=job-en` |
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
- `I18nInfrastructureCheck.tscn` must keep `ja`, `zh-CN`, and `zh-TW` hidden from shipping selection while proving alias normalization, unique UI-miss logging, complete English event/ending/catalog fallback, non-Korean date/housing/money surfaces, and actual bundled-font glyph coverage reporting.
- `i18n_coverage_check.py` keeps English strict and prepared locales in empty-skeleton mode. After a language translation wave, `--lang <code> --strict` must pass before that code is added to `SHIPPING_LANGUAGES`.
- `multilingual_surface_audit.py` rejects malformed locale/catalog files and Korean text leaked into target values. Korean source strings are allowed only as keys in `ui_<code>.json`.
- `ja_translation_audit.py --scope ui` must cover all 2,091 extracted `_tr`/`LocaleManager.ui` keys with exact placeholders and line breaks, zero Hangul/yen leakage, canonical names, valid casino terminology, and correct lock/unlock polarity. Japanese prose scopes remain held until explicit demo GO.
- `ScreenshotQA --qa=i18n-layout --lang=ja/zh-CN/zh-TW` must wrap the QA-only CJK paragraph without clipping or covering the footer at 1280x800. An OS-provided glyph fallback is not sufficient for release; the font must be bundled through `FontKit`.
- Japanese remains a hidden beta even after the UI/font checks pass. The 15-scene Japanese story capture set, strict event/ending parity, and native-speaker spot check are required after the prose hold is lifted and before `ja` can enter `SHIPPING_LANGUAGES`.
- `TutorialInputCheck.tscn` must advance exactly one tutorial slide per accept input, never activate an underlying AP action, dismiss cleanly, and restore the previous focus. It runs inside `tools/audit.sh`.
- `StoryTutorialPlacementCheck.tscn` must drive the real `story_knee_witness` forced choice through its result and authored follow-up without any StoryMode tutorial modal, while proving that the first AP dashboard still explains assets, health, and mental strength. It runs inside `tools/audit.sh`.
- `StoryPlaybackCheck.tscn` must let AUTO advance prose while remaining parked at every choice; keyboard `A` and gamepad North are toggles, never surrogate choice inputs. When another authored arc is already due, the StoryMode return must remain fully covered and enter that arc without flashing the MainGame/AP shell.
- `first_session_pacing_audit.py` locks the authored prologue to the canonical twelve-scene sequence across all 108 identity paths, allows at most 84 text-panel paragraphs, 12 AUTO confirmations, and 180 fast inputs, and requires the first meaningful choice by scene five. It also checks KO/EN choice parity and rejects placeholder-only choices or oversized paragraphs.
- `MotivationImprintCheck.tscn` must prove the exact nine-link Knee→Last Payment→Father→Notebook chain, all nine identity choices and serialized flags, nine KO/EN memory readers, three persistent notebook motives, and Father contacts at weeks 11, 15, and 21.
- `tools/audit.sh` must print `MOTIVATION_IMPRINT_OK chain=9 identity=9 readers=9 motives=3 father_contacts=3`.
- `ScreenshotQA --qa=motivation-imprint --lang=ko/en` must render the three identity-choice surfaces, the full persistent notebook sentence on the AP goal bar, the no-scroll notebook and montage modals, and the visible month-end ritual at 1280x800.
- `peak_scene_chain_audit.py --strict` measures the 28 canonical Tier-1 roots through their actual `follow_up_event` paths. It must preserve both Namsan gold-standard chains, Daeun's proposal, Daeun's wedding, and Jiyeon's wedding-gap chain, and may never raise the recorded expansion debt above 23; each accepted expansion ratchets that ceiling down.
- Demo ending ScreenshotQA fails when the record requires vertical scrolling; the wishlist, restart, and main-menu actions must remain in the first 1280×800 viewport in both languages.
- `DemoBuildCheck.tscn -- --demo-build` must keep full and demo export presets separate, execute the canonical t=1~8 arc chain with real choice effects/follow-ups, permit week 24, and stop before week 25. `tools/audit.sh` must print `DEMO_BUILD_CHECK_OK feature=gangnam_demo cutoff=24 chain=8 presets=6`.
- `ScreenshotQA --qa=demo-blackbox --lang=ko/en --demo-build` is the visual companion gate. `--demo-build` is mandatory because Godot custom export features are unavailable while running from the editor.
- The demo black-box gate must keep every AP card inside the 1280x800 viewport with normal and bonus AP, and the final record must say week 24 while rejecting any visible week-25 copy.
- `ScreenshotQA --qa=demo-input --lang=ko/en --demo-build` must complete all 24 playable weeks using actual `ui_accept` input, preserve the authored opening chain, forbid the retired generic first-workday and premature career-specialization scenes, and end at the wishlist CTA without a transient AP overlay or toast.
- The same route must use the visible three-card demo pressure stage rather than repeatedly opening the fallback catalog, record both money and human weeks, and ignore embedded minigame cards whose own real-input suites are responsible for their internals.
- `ImmersionLoopCheck` must keep every demo pressure at exactly three live actions, mutation-free previews, no visible Moral/route vocabulary, and zero Korean leakage in English.
- `ScreenshotQA --qa=ap-act-en --lang=en` must keep the three primary cards in one horizontal row at 1280x800, preserve their scene art and preview copy, and leave the result confirmation unobstructed by the commit toast.

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
- Every active path must have exactly one row and its reviewed file hash in `docs/ART_AI_AUDIT.md`; duplicate rows, changed hashes, and `FAIL` or `PENDING` verdicts fail `tools/audit.sh`.
- Active portraits require alpha. Missing files, stale ledger rows, or unreviewed new registry paths fail immediately.
- `cast_detail_contract_check.py` requires every CG gaze/action actor to be A/B-tier, keeps relationship cast tiered, and forbids atmospheric C-tier extras from becoming acting focus. Reusable backgrounds may embed only C-tier extras.
- Contact sheets accelerate review but do not replace original-resolution checks for hands, gaze, reflections, readable text, architecture, recurring identity, and the ten store-facing key visuals.
- After changing a CG, run only its owning ScreenshotQA scope first. The current Crypto Ghost repair is covered by `--qa=endings-en --lang=en`; broad casino/AP QA is unrelated.

Automated ending-fact gate:

- `ending_distinctness_audit.py` must keep all 35 KO/EN endings aligned while rejecting self-funded 3B language in `jiyeon_man`, a Gangnam apartment in the 1B `second_love`, age-55/current-retirement claims, the stale 200M orthodox amount, or a missing `startup_exit` reread in `gangnam_dream`.
- The same gate requires four byte-distinct dedicated symbols wired to `ordinary_life`, `burnout`, `mental_break`, and `stable_success`, and locks the remaining generic mood-card backlog to the documented nine IDs.
- `ScreenshotQA --qa=ending-p0 --lang=ko/en` and `--qa=endings-en --lang=ko/en` are the visual companions; they must use factual seed money/housing and exact symbol resource paths.

Automated store-trailer gate:

- `ScreenshotQA --qa=trailer --lang=ko/en` must render all 22 named in-game sources at 1920x1080. The actual timed-choice surface must remain readable at 12/7/3 seconds and turn urgent at three seconds.
- `python3 tools/trailer/trailer_check.py` must keep the exact 30/60-second cut totals, Korean/English caption pairs, canonical key art/music, project-owned cues, and complete source contract valid. It runs inside `tools/audit.sh` without requiring generated footage.
- `./tools/trailer/render_all.sh` must produce four H.264/AAC 1080p60 MP4s, SRT files, checksum manifests, and five QA frames per edit under ignored `build/trailer/`.
- Reviewers must confirm the same-scene Moral Tint progression, title-safe captions, 22-26s/44-50s catastrophe silence, and no unsupported marketing claim. See `docs/TRAILER_PRODUCTION.md`.

Automated audio gates:

- `audio_source_audit.py` must assign every shippable WAV/OGG to exactly one reproducible source script; no missing, stale, duplicate, or undocumented audio may ship.
- `generate_gangnam_ui_sfx.py --check` must reproduce the six tactile UI WAV files byte-for-byte without external samples.
- `scene_audio_contract_check.py` must give every active CG an ambience and every event on all 28 Tier-1 peak paths an authored scene-audio contract. Diegetic spoken language remains Korean under every text locale.
- `game_audio_contract_check.py` must preserve 17 physical SFX keys, 19 stage call sites, seven activity ambience owners, nine direct-controller minigames, and nine separate human-presence layers. It rejects a regression from semantic controls to `grab_focus()` traversal.
- `GameAudioContractCheck.tscn` must load every physical stream, prove bounded playback variation, keep same-activity ambience continuous, reject stale-owner clearing, and restore housing ambience on exit. Jeongseon floor/table masters must have the same substantial loop length; same-layer calls cannot rewind, and both floor→table and table→floor crossfades must inherit playback phase before the score closes on exit.
- `MoralAmbienceCheck.tscn` must prove that Light/Deep Black progressively remove and low-pass only the human layer, that inert machinery remains legible, that White restores people, and that the transition starts no explanatory music.
- `StoryAudioSettingsCheck.tscn` must open from `gd_menu`; expose three text sizes, the selectable languages, Music/Ambience, SFX, and Reduce Motion without scrolling; pause prose/AUTO/direction timing/timed choices; restore one countdown row and the exact focused choice; rebind current prose/choices/results across KO/EN without replaying effects or follow-ups; close from Menu/Cancel; and never restart either stream. `ScreenshotQA --qa=story-audio --lang=ko/en` must pass at 1280x720 and 1280x800 with Large text, zero English Hangul, and no panel/body clipping.
- `BGMContinuityCheck.tscn` must keep the weekly hub, ordinary random events, and unscored arcs on place/season ambience without starting generic lo-fi; preserve same-context playback and Moral Tint texture changes; and permit story music only through an explicit paragraph score contract. `menu/early/hustle/late_tense` remain lobby-only.
- `ImmersionLoopCheck.tscn` must prove two-week action memory and serialization, precise no-leak event families, ×2.6/×1.88 echo strength, ×0.42 filler attenuation, deterministic quiet-week bands, localized causal frames, season/housing vignettes, non-mutating arc omens, rent deadlines, and SFX mix trims.

Automated random-event director gates:

- `event_director_audit.py` must distinguish 1,177 structural candidates, 1,045 legacy candidates after story/weight exclusions, and the 1,032 events that can actually enter the director after nine scheduled arcs and four direct chain targets are removed. It requires five contiguous chapter windows, five contiguous asset bands, 1,029 once-per-run events, and exactly three approved repeatable everyday events.
- `EventDirectorCheck.tscn` must reject commute and after-work scenes while unemployed, goshiwon scenes after moving out, a six-month partner scene before romance, and named-cast callbacks before meeting. It must preserve Sangchul's introduction, authored arc/follow-up routing, and the data-owned ×2.6/×1.88 recent-action echo.
- Selecting an actual random event, not merely drawing it, records its run count and last turn. Both dictionaries must survive save/load. The three repeatable events may return only after 24-32 weeks, at 0.35 weight, and never exceed two appearances.
- Guaranteed arcs, follow-up events, deferred queues, event prose, effects, and Moral Tint remain outside this director.

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
- Run `--qa=text-material --lang=en` and `--qa=display-matrix --lang=en` at 1280x720, 1280x800, and 3840x2160 after changing these tokens, then inspect the AP decision and Story choice PNGs for doubled glyphs, blur, clipping, and TV-safe intrusion. `--qa=story-en --lang=en` at 1280x800 is the body/result companion.

Automated input and display gates:

- `InputMatrixCheck.tscn` must print `INPUT_MATRIX_CHECK_OK modes=3 resolutions=6 brands=3 direct_scenes=9 direct_routes=18 keyboard_tasks=9 action_sets=4`.
- Its keyboard tasks must place/start one real round in Blackjack, Baccarat, Slots, Roulette, Big Wheel, Dai Sai, Holdem, and RaceTrack, then launch the selected table from the casino hub. A stake-only toggle is insufficient.
- Keyboard-only title-to-demo QA must reach the week-25 CTA with `mouse_events=0`; mouse-only QA must reach the same boundary with `key_events=0`. Both routes must begin unemployed and exercise money and human axes.
- The month summary and demo-ending CTA must fit at 1280x800 without vertical scrolling or an off-screen progression button.
- `ScreenshotQA --qa=display-matrix --lang=en` must pass independently at 1280x720, 1280x800, 1920x1080, 2560x1440, 3840x2160, and 3440x1440. Every run captures title settings, the demo AP decision, and a Living Scene choice; 1080p additionally captures Xbox, PlayStation, and Nintendo glyph surfaces.
- Settings and AP decision controls must stay inside the 2.5% TV-safe rectangle. Captured PNG dimensions must equal the requested output dimensions.
- Xbox/Steam Deck, PlayStation, and Nintendo labels must come from `ControllerHints` physical positions. Game scenes may not hardcode one brand's face-button letters.
- Reduce Motion and vibration on/off/strength must be reachable from both title and in-run settings without restarting current audio or changing game state.
- The Steam Full Controller Support claim remains blocked until physical Steam Deck, DualSense, and Switch Pro blind passes cover reconnect, suspend/resume, overlay, and accidental input.

## Launch
- Project opens in Godot 4.6.
- Start screen loads.
- New game starts without script errors.
- Main UI appears correctly.
- Buttons are clickable.
- Text wraps horizontally and does not appear vertical.

## Core Loop
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
- The JUNPAC mark is a transparent code-native tapered crescent plus red square. Runtime launch trees must not load the old black-box `junpac_games_logo.jpg`.
- `publisher_sting` plays once per cold boot. It does not loop, stack on skip, or restart at the title/opening handoff.
- New Story routes through `OpeningCinematic.tscn`; Continue and Load route directly to the saved game. The opening contains at most three full-bleed illustrated beats and no black presentation cards or final confirmation gate.
- Keyboard shows `PRESS ANY KEY`; active Xbox/Steam Deck, DualSense, and Switch layouts show their physical South button. Dismissing the gate restores focus to a visible title command.
- Reduce Motion removes opening camera scaling and inferred Living Scene camera travel while preserving the same image, copy, timing budget, and skip target.
- `First30SecondsCheck.tscn` must print `FIRST_30_SECONDS_CHECK_OK gates=1 beats=3 budget=17.1s logo=vector audio=1 reduced_motion=1 pad=1`.
- Run `ScreenshotQA --qa=first-30` for KO/EN at 1280x720, Steam Deck 1280x800, and 3840x2160. Include at least one `--pad=playstation --reduce-motion` run and one 4K pad run; inspect logo edges, title-safe copy, full-bleed crops, English zero-Hangul, and duplicated transitions.

## Ending Art
- `CGRuntimeCheck.tscn` passes all ending CG paths, minimum 1280×720 dimensions, unique ownership, Gangnam Ink preview grading, and the ending-CG shadow-legibility grade.
- `CGRuntimeCheck.tscn` also passes all story CG paths, exact 1280×800 romance dimensions, paragraph reveal timing, paragraph-specific background order, hidden portraits, and hidden HUD. Story CGs keep unique ownership except the explicit same-ballroom continuity allowlist for Jiyeon's three-link wedding-gap chain.
- First-snow runtime checks also prove December-only routing and correct person-free prelude background/portrait before each delayed CG.
- An ending without a dedicated CG uses its moral mood card; it never borrows another ending's image.

## News And Market
- Monthly news generates.
- News affects relevant markets.
- Market bubbles and crashes occur within intended ranges.
- Misleading news does not feel unfair without counterplay.

## Save/Load
- Autosave works.
- Manual save slots work.
- Loading restores player state, portfolio, relationships, flags, inventory, and logs.
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
