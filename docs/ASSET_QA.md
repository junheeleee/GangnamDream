# Gangnam Dream Asset QA

Updated: 2026-09-05

Production gate: new and regenerated visual assets must also satisfy `docs/PRODUCTION_ASSET_PIPELINE.md` before they are treated as Steam-demo-ready assets. This QA file records current asset status; the production pipeline defines the acceptance process.

## Scope

- Visual pass over current generated PNG assets.
- Code/content usage pass against `ImageRegistry.gd`, direct `res://assets/...png` references in GDScript, and JSON `portrait` / `background` / `cg` IDs.
- Story-continuity pass against `docs/CANON_MAP.md`, `assets/CHARACTER_VISUAL_BIBLE.md`, and `docs/ASSET_CONTINUITY_CHECKLIST.md`.
- Audio pass is tracked separately in `docs/AUDIO_QA.md`.
- Contact sheets generated for local review:
  - `/tmp/gangnamdream_asset_qa_characters.png`
  - `/tmp/gangnamdream_asset_qa_backgrounds.png`
  - `/tmp/gangnamdream_asset_qa_cg_key_ui.png`
  - `/tmp/gangnamdream_p1_visual_upgrade_qa.png`
  - `/tmp/gangnamdream_backgrounds_production_after_remap.png`
  - `/tmp/gangnamdream_background_regen_complete.png`
  - `/tmp/gangnamdream_backgrounds_production_final.png`
  - `/tmp/gangnamdream_crop_qa/visual_crop_qa_sheet.png`
  - `/tmp/gangnamdream_p2_review_backgrounds_after.png`
  - `/tmp/gangnamdream_p2_keyart_after.png`

## Summary

Current core image set is usable only as a temporary visual placeholder set. The production direction has changed to a layered VN pipeline: recurring character portraits must be transparent-background assets, and backgrounds must be reusable location assets. Private/canon-sensitive backgrounds should be person-free; public venues may include small anonymous ambient silhouettes when an empty room would feel unnatural. The biggest risk is not missing files; it is visual continuity drift across repeated characters and places.

P1 missing-image pass added 10 PNGs: 7 NPC expression variants and 3 backgrounds. The new backgrounds can remain in production QA; most recurring-character variants are provisional until replaced by transparent portraits. `ImageRegistry` currently has no missing files.

Kim Minjun's core portrait set has been regenerated as transparent PNGs: `main_character_neutral_goshiwon`, `main_character_tired`, `main_character_determined`, `main_character_happy`, and `main_character_shocked`. The filename `neutral_goshiwon` is legacy; the current image no longer contains a goshiwon background.

Kim Minjun's career outfit variants have been added as transparent PNGs: `main_character_unemployed`, `main_character_part_time`, `main_character_office`, and `main_character_corporate`. `ImageRegistry` now chooses outfit portraits from current job category/tier for `player_normal`, `player_determined`, and `player_suit`, while emotional crisis states still use tired/happy/shocked portraits.

Han Jiyeon's portrait set has been regenerated as transparent PNGs: `npc_mentor.png`, `npc_jiyeon_warm.png`, and `npc_jiyeon_cold.png` now share the same 31-year-old wealthy/dangerous heroine design.

Han Jiyeon event scan confirms the active main arc is aligned with the 31-year-old heroine canon. The old 40s mentor / Park Jiyeon version remains deprecated only and must not be restored.

Core supporting cast portraits have been regenerated as transparent PNGs: Daeun, Sangchul, Jaehyuk, Father, Mother, and Hyunsu. A cast readability check was added after Hyunsu initially read too close to Minjun. Hyunsu was then revised again because the first high-readability version looked too middle-aged and low-appeal for a visual novel cast; the current version is a likable chubby 26-27-year-old exam-prep junior with round glasses, olive hoodie, and burgundy striped shirt.

Recurring minor NPC portraits have been regenerated as transparent PNGs: `npc_goshiwon_owner`, `npc_team_lead`, `npc_seongjun`, and `npc_tip_seller`. Earlier versions were 512×768 RGBA files but had fully opaque baked location backgrounds. The new pass has transparent corners and role-readable silhouettes. QA sheet: `/tmp/gangnamdream_minor_npc_transparent_pass.png`. `npc_seongjun` was then revised again because he read too close to `npc_team_lead`; the new readability sheet is `/tmp/gangnamdream_teamlead_seongjun_readability.png`.

Every accepted image must now pass the continuity checklist. The main failure mode is not visual polish; it is an image implying the wrong family history, wealth tier, room layout, age, vehicle, or relationship state.

Background continuity audit is recorded in `docs/BACKGROUND_CONTINUITY_AUDIT.md`. After the P2 public venue pass, the current status is 36 pass, 0 review, 0 fix, and 0 quarantined files. Runtime/direct background count is 36.

The Chapter 5 authored-location pass adds six exact 1280x800 runtime backgrounds: a Friday-morning family-medicine clinic, station stairs/gates, station lost-property office, Saturday-noon Hanjeongsik restaurant, generic night concert hall, and early-morning old-villa renovation interior. Direct original-resolution review confirms their location, time, functional circulation, UI-safe framing, and absence of readable brands/text or named-character proxies. `VisualCropQA` now includes all six at both 1280x800 and 960x600; the 39-shot sheet is `/tmp/gangnamdream_crop_qa/visual_crop_qa_sheet.png` (SHA-256 `a940f667ba79e9521c8442c74fb646f9e101de53bbc6020264269e41e86ec65f`). They are B+/`PASS-B` runtime candidates only: their ImageGen sources are below the P1 2560x1600 intermediate-master contract and are not A-grade release masters.

In-game crop QA was added as `tools/VisualCropQA.gd` / `tools/VisualCropQA.tscn`. Because Godot headless uses a dummy renderer and does not return usable SubViewport screenshots, the tool performs deterministic CPU compositing using the same crop math as the current MainGame/StoryMode layouts. Latest output: `/tmp/gangnamdream_crop_qa/visual_crop_qa_sheet.png`.

CG runtime display QA was added as `tools/CGRuntimeCheck.gd` / `tools/CGRuntimeCheck.tscn`. It verifies that StoryMode event `cg` keys resolve to the full-screen CG texture and suppress the separate portrait frame, and that MainGame ending `cg` keys resolve to the ending CG preview path.

The cast now has an explicit time axis separate from relationship state. `content/meta/cast_visual_years.json` maps chapters 1-2 to `y1`, chapters 3-4 to `y3`, and chapter 5 to `y5`; 32 transparent y3/y5 portraits cover Minjun, Daeun, Jiyeon, Hyunsu, Jaehyuk, Sangchul, and Father. Hospital, wedding, seasonal, romance-climax, and 2020 `father_past` portraits remain scene-owned and cannot be replaced by the time resolver.

`Stable Success` no longer falls back to an abstract geometric ending symbol. It owns `ending_stable_success_v1.png`, a 1280x800 CG of 38-year-old Minjun finding quiet relief in a modest Seoul studio, with no luxury/Gangnam victory language.

P2 key art/store material pass is complete. `gangnam_dream_keyart_rooftop.png` is now a textless 1920x1080 rooftop-to-Gangnam master key art, and Steam capsule/header assets are derived from it with deterministic local-font title overlays instead of generated text.

P3 audio pass is complete and recorded in `docs/AUDIO_QA.md`: 7 BGM tracks and 17 SFX files resolve through runtime audio managers, including the newly mapped `buy`, `sell`, and `tab_open` SFX keys.

Live-screen semantic routing QA found and fixed a separate class of issue: valid background files can still appear wrong if runtime inference chooses the wrong category fallback. `집들이` / room wording now routes to the current housing background instead of cafe/social fallback, and gym/exercise wording no longer falls through to hospital/health fallback. MainGame routine vignettes also choose their own backgrounds instead of inheriting the previous event background.

2026-06-15 second routing pass: runtime inference now looks for concrete place wording for cafe/coffee, convenience store, office/interview, subway, real estate, study/library, holdem, racetrack, and lottery before generic investment/gambling fallbacks. The semantic audit report now tracks the remaining manual-review set in `docs/BACKGROUND_SEMANTIC_AUDIT.md` (103 REVIEW candidates after this pass). Do not auto-fix the remainder from text keywords alone; several are legitimate scenes where the dialogue topic and physical location differ.

## Pass

- Kim Minjun core 5-expression transparent portrait set is usable for first in-game QA.
- Kim Minjun 4-outfit transparent portrait set is usable for first in-game QA. Contact sheet: `/tmp/gangnamdream_minjun_outfit_variants.png`.
- Core supporting cast transparent portraits are usable for first in-game QA: Daeun, Jiyeon, Jaehyuk, Sangchul, Father, Mother, Hyunsu.
- Recurring minor NPC transparent portraits are usable for first in-game QA: goshiwon owner, office team lead, Park Seongjun, racetrack tip seller.
- Team Lead / Park Seongjun readability check passes first visual QA: team lead keeps glasses, white shirt, tie, and crossed-arm pressure; Seongjun now has no glasses, softer face, muted cardigan, and ID lanyard.
- Han Jiyeon transparent portrait set is usable for first in-game QA: `npc_mentor`, `npc_jiyeon_warm`, `npc_jiyeon_cold`.
- Readability check sheets generated: `/tmp/gangnamdream_cast_readability_check.png`, `/tmp/gangnamdream_minjun_hyunsu_readability.png`.
- Core registered backgrounds are broadly consistent enough for a first in-game QA pass.
- The six Chapter 5 authored-location backgrounds pass B+ runtime review: `hospital_clinic_day`, `subway_station_stairs`, `subway_station_lost_found`, `hanjeongsik_restaurant_day`, `concert_hall_night`, and `villa_renovation_day`. The clinic, station pair, restaurant, and renovation site are fully person-free; the concert hall uses only distant non-identifiable C-tier audience/performer texture.
- P1 added backgrounds are usable for first in-game QA: `restaurant_korean`, `library`, `street_seoul_day`.
- `goshiwon_room.png` and `start.png` now share the canonical goshiwon layout: tiny high frosted ventilation window, bed, low desk at bed foot / screen-bottom foreground, no large scenic window.
- `family_living_room.png` has been regenerated as Minjun's father's modest Changwon working-class home and reconnected for family events.
- `late_night` / inferred night-room scenes now map to the regenerated `late_night_room.png`, which preserves the exact `goshiwon_room.png` structure as a colder 4am variant.
- `convenience_store_night_v2.png` is the canonical person-free store background. Its entrance, customer lane, counter/POS, staff pocket, storage wall, and far-left refrigerators follow `assets/CONVENIENCE_STORE_VISUAL_BIBLE.md`; the old filename is legacy-only.
- Gangnam day/night/station backgrounds have been regenerated without foreground protagonist-like figures.
- `penthouse_view.png` has been regenerated as an empty luxury ending background with no lone male silhouette.
- `late_night_room.png` has been recreated from `goshiwon_room.png` as a colder 4am variant, preserving exact room structure, and runtime maps back to it.
- P2 public venue backgrounds have been regenerated or replaced with safe ambient silhouettes:
  - `library`, `restaurant_korean`, `pc_bang_interior`, `racetrack_betting_hall`, and `holdem_club_interior` use small/dark faceless background figures only.
  - `seoul_rainy_street` and `hometown_train_station` no longer contain a clear central pedestrian/traveler.
  - QA sheet: `/tmp/gangnamdream_p2_review_backgrounds_after.png`.
- Runtime background semantic routing first pass is usable for QA: `friend_housewarming` / `housewarming_alone` route to current housing, hospital routing requires medical semantics, and MainGame/StoryMode share `ImageRegistry.infer_background_id()`.
- Story CGs now exist for all currently referenced CG IDs:
  - `cg_ending_father`
  - `cg_jiyeon_crash`
  - `cg_jaehyuk_reveal`
- Runtime CG display is connected:
  - StoryMode uses event `cg` as the first-priority full-screen image and hides the separate portrait frame for CG scenes.
  - MainGame ending screen uses ending `cg` as the background image and adds a wide CG preview inside the ending modal.
  - `tools/CGRuntimeCheck.tscn` passes.
- Cast time progression passes its first production QA:
  - `CastVisualTimeCheck.tscn` validates all three windows, seven core identities, relationship-stage independence, fixed-context protection, missing-file fallback, and four Minjun job variants.
  - 1280x800 Korean and 960x600 English `year-identity` renders keep all 21 neutral anchors inside the portrait safe area.
  - Local review sheets: `/tmp/cast_visual_years_neutral.jpg`, `/tmp/cast_visual_years_expression.jpg`, and `/tmp/cast_time_runtime_1280_contact.jpg`.
- `Stable Success` exact-CG ownership passes `CGRuntimeCheck`, ending distinctness audit, and the real Korean 1280x800 modal capture at `/tmp/gangnamdream_stable_success_20260724_2/ending_ko_15d_ending_stable_success.png`.
- P1 in-game crop QA passes first review for 15 MainGame/StoryMode/CG compositions:
  - StoryMode: goshiwon + Minjun, late-night goshiwon + tired Minjun, convenience + Daeun, Gangnam station + Jiyeon, family home + father, office + team lead, library + Hyunsu.
  - MainGame dashboard: goshiwon + unemployed Minjun, Gangnam day + corporate Minjun, Gangnam night + Jiyeon, late-night goshiwon + tired Minjun.
  - CG fullscreen: start goshiwon, Jiyeon crash, Jaehyuk reveal, ending father.
- The publisher splash and StartMenu now share the same identity-locked cast master and architectural wordmark. The obsolete rooftop concept is no longer a runtime brand surface.
- P0 Steam/store key art passes the first identity and crop review:
  - `gangnam_dream_keyart_cast_v1.png` — 1920x1080 textless cast master
  - `steam_capsule_main.png` — 616x353, three faces and reflection motif survive
  - `steam_header.png` — 460x215, Minjun remains primary
  - `steam_capsule_small.png` — 231x87, compact title and three distinct silhouettes remain readable
  - Deterministic exporter: `tools/KeyArtExport.tscn`
  - Runtime QA: `ScreenshotQA --qa=start-en` plus Korean default surface capture.

## Fix Or Review Before Final

- Chapter 5 authored-location runtime backgrounds
  - The six 1280x800 files are accepted as B+/`PASS-B` runtime candidates, not A-grade production masters.
  - Before an A-grade release promotion, regenerate or repaint from a true 2560x1600-or-larger source and repeat full-frame, 100% crop, UI-safe, text/logo, and perspective review without changing the approved place/time contracts.

- All recurring character portraits
  - Replace with transparent-background portraits.
  - Core cast pass is complete.
  - Current recurring minor NPC pass is complete for goshiwon owner, team lead, Seongjun, and tip seller.
  - Remaining later pass: any newly introduced recurring DLC characters.
  - Do not generate real room/street/office backgrounds inside these portraits.

- General investment/event backgrounds
  - General investment scenes should use `investment_phone.png`.
  - Multi-monitor rooms are reserved for `scalping_room` / pro-trading contexts, not early goshiwon investing.

- `gym_interior` dedicated background
  - Still needed before final visual lock.
  - Current `gym` / `exercise` runtime IDs intentionally use an exercise-safe fallback so 헬스장/운동 지문 no longer displays hospital imagery.
  - Replace the alias with a real reusable gym interior once the asset is generated.

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

## Wired (2026-06-10)

- `assets/ui/card_back.png` (256x358, RGBA, rounded transparent corners)
  - Wired into `HoldemClub._card_back()` as a `TextureRect` (KEEP_ASPECT_CENTERED). Procedural panel kept as fallback if texture is null.

- `assets/ui/poker_chip_icon.png` (128x128, RGBA, transparent bg) — REVERTED, needs regen
  - Was briefly wired into the HoldemClub header, but the source art is defective: the center club (♣) emblem is off-center (shifted down-left) relative to the chip rings. Can't be fixed by cropping. Removed from the UI until a chip with a centered emblem is regenerated.
  - 2026-06-21: removed from active runtime surfaces again. Jeongseon Casino hub now draws game-specific mini art procedurally, and MainGame/TutorialOverlay/Holdem pot icon use the centered denomination chip SVG set instead.

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
- `assets/ui/card_back.png`
- `assets/ui/horse_silhouette.png`
- `assets/ui/poker_chip_icon.png` — legacy/deprecated. Active runtime code should use `assets/ui/chips/chip_*.svg` or code-drawn casino art instead.

Steam key art is store material and is intentionally not referenced by game code. The other unused old backgrounds should either be deleted, archived, or deliberately wired into `ImageRegistry` after style/regeneration review.

## Next QA Steps

1. Verify MainGame portrait state switching in live play: early run should not show `main_character_30s` before a real upward mobility milestone.
2. Verify audio loudness and loop feel in live play, especially BGM transitions and minigame SFX.
3. Decide whether Holdem/RaceTrack should stay code-drawn or move to image-backed cards/chips/horses.
4. Regenerate only specific failed assets after live UI QA.
