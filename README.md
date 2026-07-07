# Gangnam Dream (강남드림)

**Interactive drama / life simulator — Godot 4.6 (GDScript)**

You are Kim Min-jun, 33, unemployed, with 500,000 won in your account.
Goal: reach 3 billion won and enter Gangnam — Seoul's status district — in five years.
The real question underneath: *can you climb that ladder without becoming someone else?*

---

## What kind of game is this?

A Korean social-realism drama you play one week at a time (240 weeks, age 33→38).
Every week you spend limited time on money or on people — and the game quietly
remembers which. Choices stack into identity, identity stacks into one of **34 endings**.

It plays like a visual novel with a life-sim dashboard — and the screen itself
is a character: as your choices darken, the world literally drains of color
(the hidden **moral tint** system — never shown as a number, only felt).

## Core systems

| System | Description |
|---|---|
| **Weekly loop + montage** | 1 turn = 1 week. Uneventful weeks can be folded into a montage ("let the weeks pass") that stops the moment something — or someone — needs you |
| **Money vs people axis** | Every action spends time on one side; grind a whole month without people and it quietly wears you down |
| **Moral tint** | Hidden −100..+100 axis painted through shaders: color drains as you cross lines. Some scars never fully heal |
| **Discovery layer** | Once you learn a truth, the same scenes re-read differently (`description_if_known`) |
| **Story arcs** | Sangchul (the man who ruined your father), Daeun & Jiyeon (two loves, inverted mirrors), Jaehyuk, Hyunsu, Father — branching, loss-capable |
| **Romance & marriage** | Marriage can be *lost*: betray Daeun and she divorces you; live small and Jiyeon walks away |
| **Investment market** | 18 fictionalized assets, market cycles, fear/greed, leverage, crashes |
| **Casino suite** | Baccarat, blackjack, slots, roulette, sic bo, big wheel, hold'em, racetrack — with a full addiction/recovery narrative |
| **Endings** | 34, spouse-aware routing, NG+ knowledge variations, ending gallery |

## Content

~1,200 events (KR source + full EN overlay) · 34 endings · 15 jobs ·
18 assets · 28 items · 5 major character arcs · Steam demo scope (first 6 months).

## How to run

1. Install Godot 4.6+.
2. Open `project.godot`, press **F5**.

Build: `./tools/build.sh linux` / `./tools/build.sh windows`
Static audit (run before committing): `./tools/audit.sh`

## Documentation

| File | Contents |
|---|---|
| `CLAUDE.md` | Session protocol, current status, canon rules |
| `docs/STORY_BIBLE.md` | Design & narrative bible |
| `docs/ROADMAP.md` | Development phases |
| `docs/DECISIONS.md` | Design decision rationale |
| `docs/ROMANCE_SYSTEM.md` | Two-heroine canon |
| `docs/MORAL_TINT.md` / `docs/AP_REDESIGN.md` | Core system specs |
| `docs/CODEX_QUEUE.md` | Art/UI/audio work queue |
| `README_KR.md` | Korean version of this file |
