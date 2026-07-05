# Gangnam Dream QA Checklist

Use this checklist before major commits, playable builds, and release candidates.

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
| StoryMode/VN intro events, choices, chapter card | `--qa=story-en` |
| Main AP screen, warning state, action modals, info panel, people modal pages | `--qa=ap-en` |
| AP Act 1~5 action rail evolution, no-scroll 4-slot regression | `--qa=ap-act-en` |
| Investment modal Trade/Holdings/Market/Bank pages | `--qa=invest-en` |
| Demo month summary and demo ending CTA | `--qa=demo-end-en` |
| Ending modals and ending CG/card surface | `--qa=endings-en` |
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
- Rare and hidden events respect unlock rules.
- Repeated events are prevented or reduced.
- Chained events can follow previous choices.
- Invalid event data fails safely.

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
