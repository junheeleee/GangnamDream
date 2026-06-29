# Gangnam Dream QA Checklist

Use this checklist before major commits, playable builds, and release candidates.

## Targeted Screenshot QA
- Run screenshot QA for the surface you changed, not the entire visual suite by default.
- Use full `surface-en` or casino QA only before release candidates, before/after broad UI refactors, or when casino/minigame code changed.
- Keep the user-facing proof focused: inspect the PNGs for the modified surface, then run static audits.

| Change area | Fast QA command |
|---|---|
| Splash, opening, start menu, content notice | `--qa=start-en` |
| StoryMode/VN intro events, choices, chapter card | `--qa=story-en` |
| Main AP screen, action modals, info panel, people modal | `--qa=ap-en` |
| Demo month summary and demo ending CTA | `--qa=demo-end-en` |
| Ending modals and ending CG/card surface | `--qa=endings-en` |
| Title collection and meta-title reward surface | `--qa=title-en` |
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
