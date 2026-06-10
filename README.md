# Gangnam Dream (강남드림)

**Interactive drama / life simulator — Godot 4.6 (GDScript)**

You are Kim Min-jun, 33, unemployed, with ₩500,000 in your account.  
Goal: accumulate ₩3 billion and enter Gangnam — in 5 years (60 turns).

---

## What kind of game is this?

A Korean social-realism story where every monthly choice matters.  
Each turn you pick from one of a handful of events: career, investment, relationships, side-hustle, or risk.  
The choices stack into your character's identity — and eventually into one of 25 endings.

It plays like a visual novel with a dashboard strategy layer.

---

## Core Systems

| System | Description |
|---|---|
| **Monthly event loop** | One event per turn, drawn from a weighted pool of 395 events |
| **Tendency system** | Career / Invest / Found — behavior accumulates into identity, no preset traits |
| **Route system** | Orthodox vs unorthodox choices gate different late-game events and endings |
| **Investment market** | 18 assets with volatility, fear/greed index, bubbles, crashes, leverage |
| **Arc system** | 5 story arcs (Sangchul, Jiyeon, Jaehyuk, Daeun, Father) with branching outcomes |
| **Story mode** | Key moments render as visual-novel scenes with portraits and backgrounds |
| **Housing progression** | Goshiwon → One-room → Villa lease → Apartment lease (cost + passives) |
| **Run themes** | Each run gets a random category boost, or choose a preset theme |
| **Meta progression** | 39 collectable titles, run history, per-run stats |
| **Save system** | Autosave + 3 manual slots |

---

## Content

| Category | Count |
|---|---|
| Total events | 395 |
| — Life events | 142 |
| — Investment events | 41 |
| — Story / arc events | 157 |
| — Relationship events | 35 |
| — Hidden / rare events | 20 |
| Endings | 25 |
| Jobs | 15 |
| Investment assets | 18 |
| Items | 28 |
| News templates | 79 |

---

## How to Run

1. Install Godot 4.6 or later.
2. Open `project.godot`.
3. Press **F5**.

Build scripts: `./tools/build.sh linux` / `./tools/build.sh windows`

---

## Documentation

| File | Contents |
|---|---|
| `CLAUDE.md` | Session protocol, current status, core rules |
| `docs/GAME_DESIGN.md` | Full game design document |
| `docs/ROADMAP.md` | Development phases and checkboxes |
| `docs/BALANCE.md` | Economy tuning log |
| `docs/DECISIONS.md` | Design decision rationale |
| `docs/STORY_BIBLE.md` | Character and narrative reference |
| `README_KR.md` | Korean version of this file |
