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
| Splash, opening, StartMenu press-any-key, start menu, content notice | `--qa=start-en` |
| StoryMode/VN flashforward Black→arrival Gray reset, intro events, choices, chapter card, scene direction framing | `--qa=story-en` |
| Romance CG Gray/Black/White color hierarchy and no-HUD climax framing | `--qa=romance-cg` |
| Romance portrait outfit/scale against exact paired CG contract | `--qa=romance-portraits` |
| Main AP screen, Seoul Trace visited/locked nodes, warning state, people pressure grind hints, routine modal/time record, market ticker/info panel, keepsake thumbnails, action modals, people modal pages | `--qa=ap-en` |
| AP Act 1~5 2x2 decision board, post-first-interview `Keep Applying`, no-scroll special-action row, ACT4 relationship pressure modal | `--qa=ap-act-en` |
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

- `TutorialInputCheck.tscn` must advance exactly one tutorial slide per accept input, never activate an underlying AP action, dismiss cleanly, and restore the previous focus. It runs inside `tools/audit.sh`.
- Demo ending ScreenshotQA fails when the record requires vertical scrolling; the wishlist, restart, and main-menu actions must remain in the first 1280×800 viewport in both languages.

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
- `CGRuntimeCheck.tscn` also passes all story CG paths, unique event ownership, exact 1280×800 romance dimensions, paragraph reveal timing, hidden portraits, and hidden HUD.
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
- Notifications do not block important buttons.
