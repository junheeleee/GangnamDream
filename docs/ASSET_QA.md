# Gangnam Dream Asset QA

Updated: 2026-06-12

## Scope

- Visual pass over current generated PNG assets.
- Code/content usage pass against `ImageRegistry.gd`, direct `res://assets/...png` references in GDScript, and JSON `portrait` / `background` / `cg` IDs.
- Story-continuity pass against `docs/CANON_MAP.md`, `assets/CHARACTER_VISUAL_BIBLE.md`, and `docs/ASSET_CONTINUITY_CHECKLIST.md`.
- Contact sheets generated for local review:
  - `/tmp/gangnamdream_asset_qa_characters.png`
  - `/tmp/gangnamdream_asset_qa_backgrounds.png`
  - `/tmp/gangnamdream_asset_qa_cg_key_ui.png`
  - `/tmp/gangnamdream_p1_visual_upgrade_qa.png`
  - `/tmp/gangnamdream_backgrounds_production_after_remap.png`
  - `/tmp/gangnamdream_background_regen_complete.png`
  - `/tmp/gangnamdream_backgrounds_production_final.png`
  - `/tmp/gangnamdream_crop_qa/visual_crop_qa_sheet.png`

## Summary

Current core image set is usable only as a temporary visual placeholder set. The production direction has changed to a layered VN pipeline: recurring character portraits must be transparent-background assets, and backgrounds must be person-free location assets. The biggest risk is not missing files; it is visual continuity drift across repeated characters and places.

P1 missing-image pass added 10 PNGs: 7 NPC expression variants and 3 backgrounds. The new backgrounds can remain in production QA; most recurring-character variants are provisional until replaced by transparent portraits. `ImageRegistry` currently has no missing files.

Kim Minjun's core portrait set has been regenerated as transparent PNGs: `main_character_neutral_goshiwon`, `main_character_tired`, `main_character_determined`, `main_character_happy`, and `main_character_shocked`. The filename `neutral_goshiwon` is legacy; the current image no longer contains a goshiwon background.

Kim Minjun's career outfit variants have been added as transparent PNGs: `main_character_unemployed`, `main_character_part_time`, `main_character_office`, and `main_character_corporate`. `ImageRegistry` now chooses outfit portraits from current job category/tier for `player_normal`, `player_determined`, and `player_suit`, while emotional crisis states still use tired/happy/shocked portraits.

Han Jiyeon's portrait set has been regenerated as transparent PNGs: `npc_mentor.png`, `npc_jiyeon_warm.png`, and `npc_jiyeon_cold.png` now share the same 31-year-old wealthy/dangerous heroine design.

Han Jiyeon event scan confirms the active main arc is aligned with the 31-year-old heroine canon. The old 40s mentor / Park Jiyeon version remains deprecated only and must not be restored.

Core supporting cast portraits have been regenerated as transparent PNGs: Daeun, Sangchul, Jaehyuk, Father, Mother, and Hyunsu. A cast readability check was added after Hyunsu initially read too close to Minjun. Hyunsu was then revised again because the first high-readability version looked too middle-aged and low-appeal for a visual novel cast; the current version is a likable chubby 26-27-year-old exam-prep junior with round glasses, olive hoodie, and burgundy striped shirt.

Recurring minor NPC portraits have been regenerated as transparent PNGs: `npc_goshiwon_owner`, `npc_team_lead`, `npc_seongjun`, and `npc_tip_seller`. Earlier versions were 512×768 RGBA files but had fully opaque baked location backgrounds. The new pass has transparent corners and role-readable silhouettes. QA sheet: `/tmp/gangnamdream_minor_npc_transparent_pass.png`. `npc_seongjun` was then revised again because he read too close to `npc_team_lead`; the new readability sheet is `/tmp/gangnamdream_teamlead_seongjun_readability.png`.

Every accepted image must now pass the continuity checklist. The main failure mode is not visual polish; it is an image implying the wrong family history, wealth tier, room layout, age, vehicle, or relationship state.

Background continuity audit is recorded in `docs/BACKGROUND_CONTINUITY_AUDIT.md`. After regenerating the failed background set, the current status is 30 pass, 6 review, 0 fix, and 0 quarantined files. Runtime/direct background count is back to 36.

In-game crop QA was added as `tools/VisualCropQA.gd` / `tools/VisualCropQA.tscn`. Because Godot headless uses a dummy renderer and does not return usable SubViewport screenshots, the tool performs deterministic CPU compositing using the same crop math as the current MainGame/StoryMode layouts. Latest output: `/tmp/gangnamdream_crop_qa/visual_crop_qa_sheet.png`.

## Pass

- Kim Minjun core 5-expression transparent portrait set is usable for first in-game QA.
- Kim Minjun 4-outfit transparent portrait set is usable for first in-game QA. Contact sheet: `/tmp/gangnamdream_minjun_outfit_variants.png`.
- Core supporting cast transparent portraits are usable for first in-game QA: Daeun, Jiyeon, Jaehyuk, Sangchul, Father, Mother, Hyunsu.
- Recurring minor NPC transparent portraits are usable for first in-game QA: goshiwon owner, office team lead, Park Seongjun, racetrack tip seller.
- Team Lead / Park Seongjun readability check passes first visual QA: team lead keeps glasses, white shirt, tie, and crossed-arm pressure; Seongjun now has no glasses, softer face, muted cardigan, and ID lanyard.
- Han Jiyeon transparent portrait set is usable for first in-game QA: `npc_mentor`, `npc_jiyeon_warm`, `npc_jiyeon_cold`.
- Readability check sheets generated: `/tmp/gangnamdream_cast_readability_check.png`, `/tmp/gangnamdream_minjun_hyunsu_readability.png`.
- Core registered backgrounds are broadly consistent enough for a first in-game QA pass.
- P1 added backgrounds are usable for first in-game QA: `restaurant_korean`, `library`, `street_seoul_day`.
- `goshiwon_room.png` and `start.png` now share the canonical goshiwon layout: tiny high frosted ventilation window, bed, low desk at bed foot / screen-bottom foreground, no large scenic window.
- `family_living_room.png` has been regenerated as Minjun's father's modest Changwon working-class home and reconnected for family events.
- `late_night` / inferred night-room scenes now map to the regenerated `late_night_room.png`, which preserves the exact `goshiwon_room.png` structure as a colder 4am variant.
- `convenience_store_night.png` has been regenerated as a person-free reusable store background with an empty checkout counter.
- Gangnam day/night/station backgrounds have been regenerated without foreground protagonist-like figures.
- `penthouse_view.png` has been regenerated as an empty luxury ending background with no lone male silhouette.
- `late_night_room.png` has been recreated from `goshiwon_room.png` as a colder 4am variant, preserving exact room structure, and runtime maps back to it.
- Story CGs now exist for all currently referenced CG IDs:
  - `cg_ending_father`
  - `cg_jiyeon_crash`
  - `cg_jaehyuk_reveal`
- P1 in-game crop QA passes first review for 15 MainGame/StoryMode/CG compositions:
  - StoryMode: goshiwon + Minjun, late-night goshiwon + tired Minjun, convenience + Daeun, Gangnam station + Jiyeon, family home + father, office + team lead, library + Hyunsu.
  - MainGame dashboard: goshiwon + unemployed Minjun, Gangnam day + corporate Minjun, Gangnam night + Jiyeon, late-night goshiwon + tired Minjun.
  - CG fullscreen: start goshiwon, Jiyeon crash, Jaehyuk reveal, ending father.
- In-game splash key art has been replaced with the anime rooftop-to-Gangnam composition.

## Fix Or Review Before Final

- All recurring character portraits
  - Replace with transparent-background portraits.
  - Core cast pass is complete.
  - Current recurring minor NPC pass is complete for goshiwon owner, team lead, Seongjun, and tip seller.
  - Remaining later pass: any newly introduced recurring DLC characters.
  - Do not generate real room/street/office backgrounds inside these portraits.

- General investment/event backgrounds
  - General investment scenes should use `investment_phone.png`.
  - Multi-monitor rooms are reserved for `scalping_room` / pro-trading contexts, not early goshiwon investing.

- Runtime CG display connection still required before final
  - Current CG files pass fullscreen crop QA, but the scene-code scan only confirms `ImageRegistry.get_cg()`, not that StoryMode/Ending currently renders event `cg` keys as full-screen images.
  - Verify and implement the `cg` display path before final story polish.

- Public venue background review remains
  - Review public venue backgrounds with ambient people in final context: `library`, `pc_bang_interior`, `racetrack_betting_hall`, `holdem_club_interior`, `hometown_train_station`, `restaurant_korean`.

- `assets/characters/main_character_50s.png`
  - Looks closer to late 30s / 40s than 50s.
  - Low priority because the current core loop is 33 -> 38, but regenerate if old/epilogue content remains.

- `assets/characters/main_character_30s.png`
  - Contains a baked room background and should not be used for recurring runtime compositing.
  - Current runtime status switching now uses transparent outfit portraits instead.

- `assets/characters/npc_coworker.png`
  - Unused after `boss` was remapped to `npc_team_lead`.
  - Style is flatter and more generic than the current portrait set.
  - Either remove from production index or regenerate only if a distinct coworker role is restored.

- `assets/cg/jiyeon_crash.png`
  - Latest version fixes the major issues: two bicycle wheels, wealthy imported car, front driver-side exit, visible steering wheel.
  - Updated again after identity QA so Han Jiyeon's face/hair/outfit match the transparent portrait set (`npc_mentor`, `npc_jiyeon_warm`, `npc_jiyeon_cold`).
  - Identity QA sheet: `/tmp/gangnamdream_jiyeon_crash_identity_qa.png`.
  - Keep this one unless an in-game crop makes the driver-side detail ambiguous.

- `assets/cg/start.png`
  - Replaced with a corrected cramped-goshiwon opening CG.
  - Preserves the start-CG spatial memory: low desk at the bed foot / screen-bottom foreground, cramped room, no large view window.
  - Gangnam is implied by the phone/goal object, not shown as a direct skyline outside the goshiwon window.

- `assets/cg/ending_father.png`
  - Replaced with the brief-correct emotional hospital scene: son holding weakened father's hand.
  - Hands are acceptable for first in-game QA; re-check after StoryMode crop.

## Wired (2026-06-10)

- `assets/ui/card_back.png` (256x358, RGBA, rounded transparent corners)
  - Wired into `HoldemClub._card_back()` as a `TextureRect` (KEEP_ASPECT_CENTERED). Procedural panel kept as fallback if texture is null.

- `assets/ui/poker_chip_icon.png` (128x128, RGBA, transparent bg) — REVERTED, needs regen
  - Was briefly wired into the HoldemClub header, but the source art is defective: the center club (♣) emblem is off-center (shifted down-left) relative to the chip rings. Can't be fixed by cropping. Removed from the UI until a chip with a centered emblem is regenerated.

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
- `assets/backgrounds/investment_monitor.png` — legacy/deprecated for default investment; use `investment_phone.png` unless the scene is explicitly pro-trading.
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

1. Verify/implement StoryMode and Ending full-screen CG display for `jiyeon_crash`, `jaehyuk_reveal`, and `ending_father`.
2. Verify MainGame portrait state switching in live play: early run should not show `main_character_30s` before a real upward mobility milestone.
3. Review public venue backgrounds with ambient people after actual story placement.
4. Decide whether Holdem/RaceTrack should stay code-drawn or move to image-backed cards/chips/horses.
5. Regenerate only specific failed assets after live UI QA.
