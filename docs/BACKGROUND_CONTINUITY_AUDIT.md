# Gangnam Dream Background Continuity Audit

Updated: 2026-06-12

## Scope

This audit covers every background image currently reachable from runtime code after the failed-background regeneration pass:

- `ImageRegistry.BACKGROUNDS`
- `MainGame.gd` direct background constants
- minigame scene direct backgrounds
- `StartMenu.gd` start/menu background

Contact sheets:

- `/tmp/gangnamdream_backgrounds_registered_sheet.png` — before `late_night` remap
- `/tmp/gangnamdream_backgrounds_production_after_remap.png` — after initial `late_night` quarantine/remap
- `/tmp/gangnamdream_background_regen_complete.png` — regenerated failure set
- `/tmp/gangnamdream_backgrounds_production_final.png` — current production/direct set
- `/tmp/gangnamdream_crop_qa/visual_crop_qa_sheet.png` — MainGame/StoryMode/CG crop QA composite sheet

Current production/direct background count: 36.

Quarantined background file: none.

## Standards

- Reusable VN backgrounds should read as places, not specific event scenes.
- Main or recurring characters must not be baked into reusable backgrounds.
- Public venue crowds are acceptable only when they function as ambient venue context and do not create a clear protagonist-like foreground figure.
- Minjun's goshiwon must keep the locked structure: tiny high frosted ventilation window, bed, low desk at bed foot / foreground, no large scenic window.
- Family-home backgrounds must match the Changwon working-class father-home canon: modest, separated-family history, no big-family wealth signal.
- Default investment scenes must remain phone/laptop scale. Multi-monitor rooms are reserved for pro trading, scalping, or late-game specialist scenes.

## Summary

| Status | Count | Meaning |
|---|---:|---|
| PASS | 30 | Safe for first in-game QA |
| REVIEW | 6 | Usable temporarily, but re-check crop/context before final |
| FIX | 0 | Regenerate or convert to one-off CG before final |
| QUARANTINED | 0 | Removed from production mapping until regenerated |

P1 crop QA result: passed first deterministic in-game composition review. `tools/VisualCropQA` generated 15 MainGame/StoryMode/CG composites using the current 1280x800 layout and the actual asset files. No regenerated P0/P1 background produced a new crop failure. Public venue backgrounds with ambient people remain REVIEW until their final story/minigame placements are locked.

## Resolved High-Priority Fixes

| Priority | Asset | Issue | Required action |
|---|---|---|---|
| P0 | `convenience_store_night.png` | Clear cashier silhouette was baked into a high-use Daeun/alba background. | Regenerated as person-free convenience store interior at night. |
| P0 | `late_night_room.png` | Large window and different room layout contradicted canonical goshiwon structure. | Recreated as a 4am color-grade of `goshiwon_room.png`, preserving exact room structure, and remapped back into runtime. |
| P1 | `gangnam_day.png` | Foreground backpack man read like a protagonist baked into a reusable Gangnam background. | Regenerated with architecture/traffic ambience and no clear foreground figure. |
| P1 | `gangnam_night_street.png` | Foreground backpack man repeated the same protagonist-like silhouette. | Regenerated with rainy Gangnam night street and no foreground protagonist figure. |
| P1 | `gangnam_station_exit.png` | Foreground back-view figure made it scene-specific rather than neutral station background. | Regenerated as neutral Gangnam Station exit background. |
| P1 | `penthouse_view.png` | Lone male silhouette was baked into an ending background. | Regenerated as empty luxury penthouse view. |

## Asset Audit Table

| Asset | Status | Notes |
|---|---|---|
| `goshiwon_room.png` | PASS | Canonical goshiwon structure: tiny high frosted window, bed, desk at foot/foreground, no large scenic window. |
| `goshiwon_hallway.png` | PASS | Person-free cramped hallway, good early housing ambience. |
| `convenience_store_night.png` | PASS | Regenerated as a person-free 2am Korean convenience store interior with empty checkout counter. |
| `cafe_seoul.png` | PASS | Foreground cafe table is empty; pedestrians are outside/window ambience only. |
| `seoul_subway.png` | PASS | Empty subway interior, reusable and clean. |
| `seoul_rainy_street.png` | REVIEW | Distant lone pedestrian is small enough for temporary use, but avoid turning it into a clear protagonist silhouette in final crop. |
| `pojangmacha.png` | PASS | Empty tables and food setup, strong reusable social background. |
| `rooftop_night.png` | PASS | Person-free rooftop night, appropriate for reflective scenes. |
| `office_desk.png` | PASS | Empty office desk/space, strong workplace background. |
| `realestate_office.png` | PASS | Empty real-estate office; documents/maps imply business without people. |
| `investment_meeting.png` | PASS | Empty conference room; charts are generic enough. |
| `gangnam_day.png` | PASS | Regenerated as a neutral daytime Gangnam commercial district background with no clear foreground figure. |
| `gangnam_night_street.png` | PASS | Regenerated as rainy Gangnam night street with neon reflections and no foreground protagonist figure. |
| `gangnam_apartment.png` | PASS | Empty luxury apartment interior, no baked character. |
| `hospital_corridor.png` | PASS | Empty corridor, wheelchair is acceptable context. |
| `hospital_clinic.png` | PASS | Empty clinic room, safe for health events. |
| `family_living_room.png` | PASS | Modest Changwon working-class home; no large extended-family portrait or wealthy Seoul signal. |
| `hometown_train_station.png` | REVIEW | Public station silhouettes are acceptable temporarily; re-check if used with close portraits. |
| `burnout_hospital_room.png` | PASS | Empty hospital room, good burnout/failure background. |
| `penthouse_view.png` | PASS | Regenerated as empty luxury penthouse skyline view with no person or silhouette. |
| `investment_phone.png` | PASS | Correct default investment scale: phone on cramped desk, no multi-monitor room. |
| `trading_screen_night.png` | PASS | Multi-monitor setup is valid only for `trading_room` / pro-trading contexts, not default investing. |
| `pc_bang_interior.png` | REVIEW | Ambient gamers make sense for PC-bang venue, but do not use as generic portrait background without crop QA. |
| `library.png` | REVIEW | Public study room includes seated people; acceptable for study ambience, but final may need person-free variant if portraits overlay heavily. |
| `restaurant_korean.png` | REVIEW | Mostly safe, but faint kitchen staff silhouette is present. Low priority. |
| `street_seoul_day.png` | PASS | Empty residential/day street, no strong people. |
| `oneroom_apartment.png` | PASS | Empty improved housing background, distinct from goshiwon. |
| `racetrack_betting_hall.png` | REVIEW | Venue crowd is expected for racetrack minigame; avoid use as generic VN portrait background. |
| `racetrack_track_view.png` | PASS | Track view with spectators as distant venue context; safe for racetrack minigame. |
| `holdem_club_interior.png` | REVIEW | Players are baked into a specific poker table scene; acceptable as minigame venue background, not a neutral VN background. |
| `scalping_trading_room.png` | PASS | Empty pro trading setup, reserved for scalping/pro contexts. |
| `aruba_delivery_street.png` | PASS | Delivery street scene reads as place/situation without clear character. |
| `gangnam_station_exit.png` | PASS | Regenerated as neutral daytime station-exit background with no dominant foreground person. |
| `rooftop_daytime.png` | PASS | Empty older-building rooftop, safe for reflection/ending contexts. |
| `military_training_ground.png` | PASS | Empty training ground, safe for military-memory events. |
| `late_night_room.png` | PASS | Recreated from `goshiwon_room.png` as a colder 4am variant, preserving exact canonical goshiwon layout. |

## Runtime Change Made

- `ImageRegistry.BACKGROUNDS["late_night"]` now points to `res://assets/backgrounds/late_night_room.png`.
- `MainGame.BG_NIGHT_ROOM` now points to `res://assets/backgrounds/late_night_room.png`.
- The file itself is now generated from `goshiwon_room.png`, so late-night/mental/goshiwon events keep the same room structure.

## Runtime Crop QA

- Added `tools/VisualCropQA.gd` / `tools/VisualCropQA.tscn`.
- Output directory: `/tmp/gangnamdream_crop_qa`.
- Contact sheet: `/tmp/gangnamdream_crop_qa/visual_crop_qa_sheet.png`.
- Covered backgrounds: `goshiwon_room`, `late_night_room`, `convenience_store_night`, `gangnam_station_exit`, `family_living_room`, `office_desk`, `library`, `gangnam_day`, `gangnam_night_street`.
- Covered CGs: `start`, `jiyeon_crash`, `jaehyuk_reveal`, `ending_father`.

## Next Step

Verify/implement the runtime full-screen CG display path for event and ending `cg` keys. The CG images themselves pass crop QA, but scene-code scan still needs a live connection check.
