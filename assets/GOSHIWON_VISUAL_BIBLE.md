# Minjun Goshiwon Visual Bible

Updated: 2026-07-17

## Canon Owner

- Reusable background: `assets/backgrounds/goshiwon_room.png`
- Shared-kitchen background: `assets/backgrounds/goshiwon_shared_kitchen.png`
- Hallway background: `assets/backgrounds/goshiwon_hallway.png`
- T1 Jiyeon CG: `assets/cg/romance/narrow_room_jiyeon_v1.png`
- Related events: `arc_jiyeon_narrow_room_1`, `arc_jiyeon_narrow_room_2`

This room is Minjun's economic starting point and a recurring story object. Its structure may not change to improve a single composition.

## Locked Geometry

Camera stands just inside the single door on the right and looks toward the back wall.

```text
BACK WALL
┌──────── shelf/mini-fridge ───── small high frosted window ── hooks ┐
│                                                                   │
│  narrow bed, head at back                                         │
│  running front-to-back       narrow floor aisle                   │
│  along LEFT wall                                                  │
│                               low desk at bed foot / RIGHT front   │
└──────────────────────────────────────────── single door / camera ─┘
FRONT / CAMERA
```

- One narrow single bed only. It runs front-to-back along the left wall.
- Bed head and pillow sit toward the back wall; bed foot points toward the camera.
- One low desk sits at the bed foot in the right foreground.
- Shelf and mini-fridge remain on the far-left perimeter.
- One small high frosted ventilation window sits on the back wall. It never becomes a skyline window.
- Coat hooks and one wall switch sit on the right wall beside one single door.
- Desk owns the black task lamp, notebook, phone, and small power strip.

## Reusable Background Rule

- `goshiwon_room.png` stays person-free.
- Early investing uses a phone or one modest laptop only. No multi-monitor trading station.
- Bedding, lamp, window, desk, shelf, fridge, and door placement remain stable across all angles.

## Shared Kitchen Lock

- `goshiwon_shared_kitchen.png` is a separate communal room reached from the
  canonical hallway. It never contains Minjun's bed, desk, lamp, notebook, or
  other private-room props.
- The kitchen is roughly two meters wide with one continuous stainless counter,
  one sink, one drying rack, one or two inexpensive induction burners, one
  modest hood, shallow communal shelves, one old shared refrigerator, and one
  narrow clear aisle. Appliance doors and the walking path must remain usable.
- Peeling gray-beige walls, exposed utilities, worn dark tile, cheap fixtures,
  and the 2 AM fluorescent/corridor-light mix identify it as the same building
  as `goshiwon_hallway.png`.
- Reusable scenery stays person-free and contains no readable labels. A neutral
  pot and sparse communal cookware are allowed; personal study books, phones,
  food brands, and event-specific possessions are not baked into the room.
- The left and center retain the sink, burner, refrigerator, shelves, and aisle
  above the dialogue-safe lower third. The right edge remains quiet enough for
  Hyunsu's transparent portrait without hiding the location.
- Any event whose active physical scene is inside `고시원 공용 주방`,
  `고시원 공용 부엌`, or the `goshiwon shared kitchen` uses
  `goshiwon_shared_kitchen`, not the private `goshiwon_room`. A hallway outside
  the kitchen and a later verbal memory keep their actual present location.

## Jiyeon Narrow Room Lock

- Jiyeon sits on the floor aisle beside the left bed, knees drawn up, not posed romantically on the bed.
- Her charcoal long coat is off and draped across the bed. She wears the oxblood fine-knit top and charcoal trousers from `npc_jiyeon_narrow_room.png`.
- Minjun sits low opposite near the desk in his worn black crewneck.
- Exactly two unbranded cup ramyeon bowls sit on the desk's back edge, above the dialogue-safe zone.
- Jiyeon and Minjun look at each other. The camera is an observer, never either character's lens POV.
- Steam and the small frosted window may carry the intimacy; no large window, city lights, or luxury prop is allowed.

## Narrow Room Chain Contract

- Episode 2 is one continuous scene across `arc_jiyeon_narrow_room_2`, `arc_jiyeon_narrow_room_silence` or `arc_jiyeon_narrow_room_truth`, and `arc_jiyeon_narrow_room_decision`.
- Every link retains `goshiwon_room`, `jiyeon_narrow_inside`, and `cg_romance_narrow_room_jiyeon`; Jiyeon cannot return to the doorway travel coat after sitting down.
- The first two choices are dialogue and observation only. They may not set flags, affinity, Moral Tint, mental, or money before the final decision.
- The two bowls, mutual eye line, task lamp, bed, desk, and high frosted window remain in the same positions through the final result.

## Reject When

- Bed rotates across the back wall, moves to the right, changes bedding, or becomes a double bed.
- Desk moves beside the pillow, disappears, or becomes a full workstation.
- A second door, second switch, second bed, large window, skyline, or private bathroom appears.
- A shared-kitchen scene shows a bed, private desk, apartment island, dining
  room, restaurant equipment, blocked refrigerator, duplicated sink, or luxury
  cabinetry.
- Jiyeon wears her cream blazer, beach outfit, or full makeup inside the room.
- Either actor looks at the lens or the cup ramyeon disappears under the dialogue panel.
