# Gangnam Dream QA Checklist

Use this checklist before major commits, playable builds, and release candidates.

Cross-discipline release gates and current product risks live in `docs/MASTER_RELEASE_AUDIT.md`.

## Controller / Steam Deck Release Gate
- Controller support is a release gate, not a polish extra. See `docs/CONTROLLER_UX_STRATEGY.md`.
- Do not treat "all buttons are focusable" as success. Dense screens need a semantic controller model.
- A first-time player must complete the first 15 minutes with controller only: no mouse, no keyboard, no hidden shortcuts.
- Every major screen must present a default focus within 0.5 seconds.
- No ordinary screen should force the player through more than 12 focusable targets in one rail.
- Casino minigames must pass controller-only flow: change stake, place bet, read bet, start round, read result, repeat/exit.
- Dense casino layouts such as Dai Sai and Roulette must use mode/cursor models, not flat focus traversal over every visible bet button.
- `A/South` confirms the highlighted item, `B/East` backs out or clears pending action, `Y/North` opens rules/details, `LB/RB` changes group/tab/mode.
- When the right-side Info Deck is open, `B/East` must close it instead of opening the system menu.
- Basic actions must not require hidden multi-button chords.

## Targeted Screenshot QA
- Run screenshot QA for the surface you changed, not the entire visual suite by default.
- Use full `surface-en` or casino QA only before release candidates, before/after broad UI refactors, or when casino/minigame code changed.
- Keep the user-facing proof focused: inspect the PNGs for the modified surface, then run static audits.

| Change area | Fast QA command |
|---|---|
| First-run language gate, KO default names, localized portrait name tags | `--qa=locale-gate` |
| Splash, opening, StartMenu press-any-key, start menu, content notice | `--qa=start-en` |
| StoryMode/VN flashforward Black→arrival Gray reset, intro events, 1~4-choice lower dock, readable backgrounds, chapter card, scene direction framing | `--qa=story-en` |
| StoryMode non-CG Black/Gray/White luminance, forced-Black framing, same-scene perception prose, moral choice wording, portrait distance, and KO/EN crop | `--qa=story-moral --lang=ko/en` |
| Authored Moral Perception anchors: Daeun cafe, Sangchul mirror, why Gangnam, father's last call, and final countdown across Black/Gray/White prose and choices | `--qa=moral-anchors --lang=ko/en` |
| Romance CG Gray/Black/White color hierarchy and no-HUD climax framing | `--qa=romance-cg` |
| Romance portrait outfit/scale against exact paired CG contract | `--qa=romance-portraits` |
| Namsan route cable car→restaurant→observation-deck paragraph backgrounds, paired portraits, lock CG intro/choices | `--qa=namsan --lang=ko/en` |
| Amusement routes: parade→helping CG/result fork, coaster→correct booth→choice-only four-cut CG, KO/EN crop and expression continuity | `--qa=amusement --lang=ko/en` |
| Daeun hometown route: interior train→separate maternal dining room→delayed night-bus result CG, summer outfit and KO/EN crop continuity | `--qa=hometown --lang=ko/en` |
| First nights: heroine-specific home/portrait→night result→paragraph-delayed morning CG, same outfit, late-game month HUD, KO/EN crop | `--qa=wedding-morning --lang=ko/en` |
| First snow: December-only store/car prelude→paragraph-1 CG, winter outfits, exactly two cans, left-driver/right-passenger seating, resting wipers, gaze and KO/EN crop | `--qa=first-snow --lang=ko/en` |
| Climate portraits: monsoon rain shell, heatwave short sleeves/cooling towel, cold-snap parka/scarf and dedicated frozen street | `--qa=climate --lang=ko/en` |
| Main AP screen, Seoul Trace visited/locked nodes, warning state, people pressure grind hints, routine modal/time record, market ticker/info panel, keepsake thumbnails, action modals, people modal pages | `--qa=ap-en` |
| AP Act 1~5 2x2 decision board, actual KRW 500K first-month horizon, post-first-interview `Keep Applying`, action-commit overlay, Seoul Trace restoration, no-scroll special-action row, ACT4 relationship pressure modal | `--qa=ap-act-en` |
| Investment modal Trade/Holdings/Market movers/Bank pages | `--qa=invest-en` |
| Demo month summary, demo ending CTA, 6-month Time Ledger card | `--qa=demo-end-en` |
| Ending modals, graded ending CG/card surface, White no-CG fallback, final Time Ledger card | `--qa=endings-en` |
| Title collection and meta-title reward surface | `--qa=title-en` |
| Tutorial overlay surface and onboarding copy | `--qa=tutorial-en` |
| Job hunt/career modal tier pages and resume/interview minigame surface | `--qa=job-en` |
| Casino/minigame UI only | `--qa=casino-en` |
| Moral tint/filter only | `--qa=moral` |
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
- `TutorialInputCheck.tscn` must advance exactly one tutorial slide per accept input, never activate an underlying AP action, dismiss cleanly, and restore the previous focus. It runs inside `tools/audit.sh`.
- `StoryPlaybackCheck.tscn` must let AUTO advance prose while remaining parked at every choice; keyboard `A` and gamepad North are toggles, never surrogate choice inputs. When another authored arc is already due, the StoryMode return must remain fully covered and enter that arc without flashing the MainGame/AP shell.
- `first_session_pacing_audit.py` caps the authored prologue at eight chained scenes/eight AUTO confirmations, requires a meaningful choice by scene three, checks KO/EN choice parity, and rejects placeholder-only choices or oversized text-panel paragraphs.
- Demo ending ScreenshotQA fails when the record requires vertical scrolling; the wishlist, restart, and main-menu actions must remain in the first 1280×800 viewport in both languages.

Automated audio gates:

- `audio_source_audit.py` must assign every shippable WAV/OGG to exactly one reproducible source script; no missing, stale, duplicate, or undocumented audio may ship.
- `generate_gangnam_ui_sfx.py --check` must reproduce the four tactile UI WAV files byte-for-byte without external samples.
- `BGMContinuityCheck.tscn` must preserve playback position across same-context scene re-entry and Moral Tint texture changes; semantic ambience routing must remain stable.

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

## Ending Art
- `CGRuntimeCheck.tscn` passes all ending CG paths, minimum 1280×720 dimensions, unique ownership, and Gangnam Ink preview grading.
- `CGRuntimeCheck.tscn` also passes all story CG paths, unique event ownership, exact 1280×800 romance dimensions, paragraph reveal timing, paragraph-specific background order, hidden portraits, and hidden HUD.
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
- Save data remains compatible after content additions where possible.

## UI/UX
- Stat panels remain readable.
- Investment panel remains readable.
- Relationship panel remains readable.
- Event choices fit on screen.
- Opening choices folds the dialogue panel away; dialogue and choice surfaces never cover the scene in two stacked layers.
- Gray and Black StoryMode backgrounds retain readable architecture, eye-lines, and hand actions at 1280×800.
- Notifications do not block important buttons.
