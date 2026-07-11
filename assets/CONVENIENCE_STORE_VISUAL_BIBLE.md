# Daeun Convenience Store Visual Bible

Updated: 2026-07-11

This location is Daeun's recurring stage and must remain one recognizable
store across backgrounds, portraits, CGs, chapter cards, and future DLC.
Atmosphere never overrides a working retail floor plan.

## Canonical Floor Plan

```text
STREET / RAIN
┌──────────────────────────────────────────────────────────────┐
│ glass frontage                         glass entrance door   │
│                                               ┌──────┐       │
│                                               │ door │       │
│                                               └──┬───┘       │
│ public store side                                │ Minjun     │
│                                                 ▼            │
│  refrigerator wall        low aisle      ┌──────────────┐   │
│  drinks / food             shelves        │ customer side│   │
│                                            ├──────────────┤   │
│                                            │ POS → Daeun  │   │
│                                            │ staff pocket │   │
│                                            └──────────────┘   │
│                                          tobacco/storage wall│
└──────────────────────────────────────────────────────────────┘
```

## Non-Negotiable Geometry

- The checkout counter is adjacent to the entrance, not floating in the aisle.
- Daeun stands in the narrow staff pocket with her back toward a solid
  tobacco/storage wall. That wall may include closed cabinets, cigarette
  rows without readable brands, receipt rolls, and one CCTV monitor.
- The POS monitor sits on the counter with its screen facing Daeun. From the
  customer side, the player sees the monitor back or side housing.
- Minjun stands on the public side of the counter near the glass door. He
  never appears behind the register unless the story explicitly makes him an
  employee.
- Refrigerated cases occupy the opposite or perpendicular perimeter wall.
  They do not sit directly behind Daeun.
- The counter has a readable top slab, customer-facing cabinet panels, bag or
  supply recess, horizontal trim, and kickplate. No featureless black wall.

## Reusable Background Camera

- Camera is in the first aisle, looking diagonally toward the checkout and
  entrance.
- Empty background contains no Daeun or Minjun.
- The frame shows all four anchors at once: entrance, public customer lane,
  counter/staff pocket, and distant refrigerator wall.
- Bottom dialogue-safe area may contain floor and low counter panels, but not
  an abstract blank slab.

## Exterior And First-Snow Camera

- The exterior is the same store seen through the glass, never a second branch.
- From screen-left to screen-right, the readable order remains refrigerator
  bank, low center aisle, counter/POS and staff pocket, then the glass entrance.
- The counter stays immediately left of the entrance from the street view.
  Moving it to the rear wall or placing refrigerators behind the clerk changes
  the building and is a rejection error.
- `convenience_store_exterior_first_snow.png` is the canonical exterior shell.
  `first_snow_daeun_v1.png` must preserve that same facade, door, counter,
  refrigerator bank, wet pavement, and blank unbranded fascia.
- Snow, daylight, signage treatment, and camera distance may vary in future
  scenes. The floor plan, glass-bay order, and entrance/counter relationship may not.

## First Kindness CG

- Camera: side three-quarter view from the public aisle, not a dead-center
  customer POV.
- Daeun: behind the counter, body turned toward the POS and Minjun; beige
  cardigan over navy work polo; short layered bob and left-temple hair clip.
- Minjun: public side near the entrance, worn black crewneck, holding the first
  triangle rice package. Only a three-quarter profile is needed.
- Action: Daeun slides the second package across the counter.
- Gaze: `Daeun -> Minjun's eyes`; `Minjun -> Daeun, then the offered item`.
  Neither person looks into the camera.
- POS: screen faces Daeun; the camera sees its back/side.
- Exactly two focal triangle packages. No readable promotion text, logo, or
  price label.

## Rejection Conditions

- Refrigerators behind Daeun.
- POS screen facing the customer/camera.
- Ambiguous clerk/customer sides.
- Daeun front-facing the lens with a stock smile.
- Minjun placed outside the store or behind the register.
- Counter reads as a wall, bar, supermarket belt, or display case.
- Entrance absent from a first-meeting CG.
- Exterior door, counter, aisle, or refrigerator order contradicts the canonical interior.
