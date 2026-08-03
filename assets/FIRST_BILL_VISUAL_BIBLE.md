# 24-Week First Bill Visual Bible

Updated: 2026-08-04

## Canon Owners

- Scene background: `assets/backgrounds/v2_first_bill_desk_closeup.png`
- Acting portrait: `assets/characters/main_character_first_bill_decision.png`
- Event chain: `v2_demo_first_bill_opening` → `v2_demo_first_bill` →
  `v2_demo_first_bill_ledger`
- Room parent: `assets/backgrounds/goshiwon_room.png`
- Visual routing: `assets/event_visual_contracts.json`
- Audio routing: `assets/scene_audio_manifest.json`

This is the 24-week demo's first reckoning, not the Chapter 1 ending. The image
must make twenty-four weeks feel physically accumulated on one small desk while
leaving the 48-week boss and the five-year ending visually larger.

## Continuous-Scene Lock

- All three links are one Friday-evening scene at 17:52 on 2026-06-26.
- They keep the same title, background, portrait, room tone, and uninterrupted
  `reckoning` playback. A link is an authored paragraph boundary, not a new
  entrance or camera reset.
- The only permitted location departures are decision choice `3`, whose
  revealed result moves to `convenience_night`, and choice `6`, whose overnight
  unloading result moves to `warehouse_inventory_night`. Returning prose
  resumes the same ledger logic; it does not invent a second desk or notebook.
- The opening expression choices change only Minjun's immediate attention. They
  do not change pose, wardrobe, room geometry, money, stats, or long-term flags.
- The ledger closes by writing Monday, 2026-06-29. The date is prose/UI text only and is
  not baked legibly into the generated notebook.

## Desk Close-Up Geometry

The close-up is a camera move within the canonical goshiwon, never a new room.

- Camera is slightly above eye level, looking almost straight toward the low
  desk at the foot of the left-wall bed.
- A strip of the narrow bed and worn wall remains visible so the room is
  recognizable without returning to the establishing shot.
- The canonical black task lamp and right-wall switch remain on the same side.
  Bed, wall, desk edge, and walking aisle must agree with
  `GOSHIWON_VISUAL_BIBLE.md`.
- The desk owns exactly one unbranded phone with an extremely dim generic
  banking-app screen, one open blank lined notebook, one pen, a small receipt
  stack, one water glass, and the existing task lamp. Props may not duplicate
  between linked events.
- No amount, bank name, app interface, date, receipt text, logo, or handwriting
  is readable in the raster. State-specific values belong to localized prose.
- The lower 30% remains dialogue-safe. Notebook, pen, receipt silhouette, and
  phone stay readable above the panel rather than being hidden by it.

## Minjun Acting Lock

- `player_first_bill_decision` is canonical year-one Minjun, age 33, in the
  worn black crewneck. It is fixed in `cast_visual_years.json` and may not be
  replaced by current job clothing or later-year anchors.
- Preserve the same lean face, short messy black hair, worn eyes, nose, mouth,
  and body proportions as `player_normal` / `player_determined`.
- His gaze falls toward the notebook, jaw quietly set, mouth closed, shoulders
  readable. The expression is deliberate concentration: neither heroic resolve,
  anger, villainous hardness, nor collapsed despair.
- The portrait is transparent and prop-free. The separate background owns the
  notebook, phone, pen, receipts, water, and room.

## Dramatic Layering

1. Opening: the close-up reveals the accumulated evidence. `paper_handle`
   lands once when Minjun opens the app and notebook; `reckoning` enters only
   after the first physical paragraph.
2. Decision: the camera and actor hold still while eight mutually exclusive
   obligations compete. Stillness concentrates attention on the writing rather
   than manufacturing eight shallow visual cuts.
3. Ledger: completed, deferred, and expired work share one page. `pen_write`
   lands exactly once on choice `0`, result paragraph `0`, when Minjun writes
   the next Monday date. Closing the notebook receives no extra reward sting.

The narrow frame, repeated pose, and dry foley make the choice feel costly. The
scene must not become a finance-app showcase, a motivational montage, or a
premature victory image.

## Reject When

- The room gains a large window, skyline, second door, second bed, full office
  desk, luxury furniture, or multi-monitor trading setup.
- Any phone screen, notebook, receipt, or banking amount contains readable or
  invented text; any core prop is duplicated or malformed.
- Minjun changes face, age, outfit, posture, or eye line between the three links,
  looks at the lens, holds a prop, or appears baked into the background.
- The decision or ledger restarts `reckoning`, replays `paper_handle`, writes
  before the result paragraph, adds a success cue, or loses the housing room
  tone.
- The image becomes glossy mobile-game art, photoreal DSLR, cyberpunk finance
  imagery, warm aspirational advertising, or exaggerated misery.
