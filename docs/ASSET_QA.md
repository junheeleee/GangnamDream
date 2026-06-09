# Gangnam Dream Asset QA

Updated: 2026-06-09

## Scope

- Visual pass over current generated PNG assets.
- Code/content usage pass against `ImageRegistry.gd`, direct `res://assets/...png` references in GDScript, and JSON `portrait` / `background` / `cg` IDs.
- Contact sheets generated for local review:
  - `/tmp/gangnamdream_asset_qa_characters.png`
  - `/tmp/gangnamdream_asset_qa_backgrounds.png`
  - `/tmp/gangnamdream_asset_qa_cg_key_ui.png`

## Summary

Current core image set is usable for an anime / Korean manhwa VN build, but it should now move from bulk generation to selective QA fixes. The biggest risk is not missing files; it is small visual logic errors such as character age, Korean car handedness, props, or unused draft UI assets looking production-ready.

`ImageRegistry` currently has no missing files.

## Pass

- Main protagonist core set: `neutral`, `tired`, `determined`, `happy`, `shocked`, `30s` are usable after the latest `happy` correction.
- Core NPC portraits are usable: `father`, `mother`, `jaehyuk`, `team_lead`, `goshiwon_owner`, `seongjun`, `daeun`, `sangchul`, `hyunsu`, `jiyeon`.
- Core registered backgrounds are broadly consistent enough for a first in-game QA pass.
- Story CGs now exist for all currently referenced CG IDs:
  - `cg_ending_father`
  - `cg_jiyeon_crash`
  - `cg_jaehyuk_reveal`
- In-game splash key art has been replaced with the anime rooftop-to-Gangnam composition.

## Fix Or Review Before Final

- `assets/characters/main_character_50s.png`
  - Looks closer to late 30s / 40s than 50s.
  - Low priority because the current core loop is 33 -> 38, but regenerate if old/epilogue content remains.

- `assets/characters/npc_coworker.png`
  - Unused after `boss` was remapped to `npc_team_lead`.
  - Style is flatter and more generic than the current portrait set.
  - Either remove from production index or regenerate only if a distinct coworker role is restored.

- `assets/cg/jiyeon_crash.png`
  - Latest version fixes the major issues: two bicycle wheels, wealthy imported car, front driver-side exit, visible steering wheel.
  - Keep this one unless an in-game crop makes the driver-side detail ambiguous.

## Wired (2026-06-10)

- `assets/ui/card_back.png` (256x358, RGBA, rounded transparent corners)
  - Wired into `HoldemClub._card_back()` as a `TextureRect` (KEEP_ASPECT_CENTERED). Procedural panel kept as fallback if texture is null.

- `assets/ui/poker_chip_icon.png` (128x128, RGBA, transparent bg)
  - Wired into HoldemClub header via BBCode `[img=16]` next to the pot amount.

- `assets/ui/horse_silhouette.png` (1024x128, RGBA, 8 transparent black gallop frames)
  - Wired into `RaceTrack._draw_track()` via `draw_texture_rect_region`. Per-lane frame offset animates the gallop; a lane-colored saddle dot preserves horse identity (silhouettes are pure black, so `modulate` tint is impossible). Procedural color circle kept as fallback.
  - NOTE: frames are a run-cycle of one horse, not 8 distinct breeds. Fine for animation; regen if distinct-breed silhouettes are wanted.

## Unused PNG Candidates

These are not referenced by `ImageRegistry` or direct GDScript image paths at the time of this audit:

- `assets/audio/또롱 슝 얼굴 패밀리 비교.png`
- `assets/backgrounds/cafe_afternoon.png`
- `assets/backgrounds/cafe_meetup.png`
- `assets/backgrounds/gangnam_street_night.png`
- `assets/backgrounds/hospital_waiting_room.png`
- `assets/backgrounds/investment_monitor.png`
- `assets/backgrounds/rooftop_dawn.png`
- `assets/backgrounds/subway_platform_rush.png`
- `assets/characters/npc_coworker.png`
- `assets/keyart/steam_capsule_main.png`
- `assets/keyart/steam_capsule_small.png`
- `assets/keyart/steam_header.png`
- `assets/ui/card_back.png`
- `assets/ui/horse_silhouette.png`
- `assets/ui/poker_chip_icon.png`

Steam key art is expected to be unused in game code; keep it for store material. The other unused old backgrounds should either be deleted, archived, or deliberately wired into `ImageRegistry` after style/regeneration review.

## Next QA Steps

1. Run the game and verify image crop/composition inside actual UI.
2. Trigger StoryMode CG display for `jiyeon_crash`, `jaehyuk_reveal`, and `ending_father`.
3. Verify MainGame portrait state switching: early run should not show `main_character_30s` before a real upward mobility milestone.
4. Decide whether Holdem/RaceTrack should stay code-drawn or move to image-backed cards/chips/horses.
5. Regenerate only specific failed assets after in-game crop QA.
