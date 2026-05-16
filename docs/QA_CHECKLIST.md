# Gangnam Dream QA Checklist

Use this checklist before major commits, playable builds, and release candidates.

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

