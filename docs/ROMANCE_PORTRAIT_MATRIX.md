# Romance Portrait And CG Continuity Matrix

Updated: 2026-07-11

## Rule

Romance clothing is locked per scene, not per season label. Every event owns a CG, a heroine portrait wearing the same outfit, Minjun's scene outfit, and an explicit gaze target. A new expression may change the face, but it may not silently change the clothes.

The machine-readable source is `assets/romance_visual_manifest.json`. `CGRuntimeCheck` fails when an event's `cg` or `portrait` drifts from this file, when a referenced portrait is missing, or when a special portrait is not exactly 512x768.

## T0 Contract

| Event | Heroine portrait | Heroine outfit | Minjun | Gaze logic |
|---|---|---|---|---|
| Daeun / East Sea | `daeun_sea` | coral-rose wrap swim dress + pale sky-blue cover-up | POV; black casual if shown | Daeun looks just off-axis toward Minjun at camera-left |
| Jiyeon / Haeundae | `jiyeon_sea` | deep emerald asymmetric swim dress + smoke-gray cover-up | cropped left, black casual | Jiyeon looks down-left at Minjun; he looks up-right at her |
| Daeun / fireworks | `daeun_fireworks` | muted blue-gray wrap dress | cropped left, black casual | Daeun watches the sky; Minjun watches her |
| Jiyeon / fireworks | `jiyeon_fireworks` | charcoal hooded windbreaker | cropped left, black casual | Jiyeon turns back toward Minjun |
| Daeun / cherry | `daeun_cherry` | pale-blue belted shirt dress + beige cardigan | POV; black casual if shown | Daeun looks up at the canopy |
| Jiyeon / cherry | `jiyeon_cherry` | cream spring jacket + black knit | cropped left, black casual | Jiyeon looks back at Minjun |
| Daeun / first kiss | `daeun_smile` | navy work polo + beige cardigan | visible left, black casual | mutual eye contact |
| Jiyeon / first kiss | `jiyeon_warm` | cream jacket + black inner | visible right, black casual | mutual eye contact |

`arc_season_sea_daeun` is intentionally staged. The upper-body portrait reveals the coral wrap neckline beneath the same pale-blue travel layer during the train and shop paragraphs. The complete swim-dress silhouette appears only when the beach CG reveals at paragraph 2.

## Minjun Outfit Lock

- Personal dates, hospital visits, the bicycle accident, and intimate family scenes use `player_romance_casual`: the same worn black crewneck as `main_character_unemployed.png`.
- A job does not force Minjun to wear his office uniform on a weekend date. Corporate or office clothing is required only when the text says he came directly from work, is at work, or is performing public success.
- T1 and ending jobs must name Minjun's outfit in the CG prompt and point to an existing portrait reference. If no portrait matches, the CG and new portrait are produced as one pair.

## T1 Contract

| Event | Prelude portrait | Climax portrait | Heroine outfit | Minjun | Gaze logic |
|---|---|---|---|---|---|
| Daeun / Namsan | `daeun_namsan` | `daeun_namsan` | moss-green short duffle coat + ivory knit + dark jeans | visible left, worn black crewneck/jacket | mutual eye contact; Daeun's hand rests naturally on the rail above the locks |
| Jiyeon / Namsan | `jiyeon_namsan` | `jiyeon_namsan` | sapphire tailored belted coat + charcoal-black mock-neck | visible right, worn black crewneck/jacket | Jiyeon studies a lock; Minjun watches Jiyeon |
| Daeun / Amusement Park | `daeun_amusement` | `daeun_amusement` | slate-blue chore jacket + ivory knit + dark jeans | visible right, worn black crewneck/jacket | both adults look to the lost child; child looks to Daeun; exactly two adult-child hand contacts |
| Jiyeon / Amusement Park | `jiyeon_amusement` | `jiyeon_amusement` | wine-red tailored suede jacket + charcoal-black mock-neck | visible right in all four frames, worn black crewneck/jacket | lens pose → mutual gaze → shared laugh → cheek-kiss surprise |
| Daeun / Hometown | `daeun_hometown_worried` | `daeun_hometown_warm` | pale sage summer overshirt + ivory T-shirt + navy trousers | visible right on bus, worn black crewneck/jacket | Daeun sleeps against the window; Minjun watches her and the rural-to-Seoul reflection |
| Jiyeon / Narrow Room | `jiyeon_narrow_door` | `jiyeon_narrow_room` | charcoal travel coat over oxblood top, then coat removed with charcoal trousers | visible right, worn black crewneck | mutual eye contact across the floor aisle; observer camera |

The Narrow Room is also a location-continuity contract. `assets/GOSHIWON_VISUAL_BIBLE.md` fixes the left-wall bed, right-front desk, high frosted window, single door, two cup ramyeon bowls, and the dialogue-safe prop band.

Namsan is a four-location continuity contract. `assets/NAMSAN_VISUAL_BIBLE.md` locks the cable-car ascent, wang-donkatsu restaurant, person-free indoor observation deck, and outdoor same-summit love-lock CG, where only an immediate partial tower structure may appear.

The amusement park is a choice-timed and season-timed contract. `assets/AMUSEMENT_PARK_VISUAL_BIBLE.md` locks mild-weather months, the park/roller-coaster/booth progression, opposing booth camera and bench, and result-only four-cut CG. `main_character_unemployed.png` supplies Minjun's identity but never forces its defeated expression onto the date.

The hometown trip is a calendar, location, and delayed-result contract. `assets/HOMETOWN_VISUAL_BIBLE.md` locks June-August entry, the interior train and separate maternal home, one continuous summer outfit, and the night-bus CG at result paragraph 1 rather than at choice commit.

## Gaze Gate

Each named character must have one readable target:

- `player_pov`: direct camera gaze is allowed only when the camera is Minjun's eyes and no second Minjun is visible.
- `mutual`: both pupils converge on the other character's eye line.
- `scene_target`: the heroine looks at fireworks, blossoms, a road, or another explicit story object while Minjun may watch her.
- `over_shoulder`: the heroine looks toward the visible foreground Minjun, not toward an unrelated lens position.
- `right_portrait`: the reusable portrait is anchored screen-right, so its pupils and slight head turn face screen-left into the dialogue/player space. A straight lens stare is not the neutral default.

An attractive face looking vaguely toward the viewer is not enough. Pupils, head angle, chin, shoulders, torso, and any active hand must tell the same action. If the gaze target cannot be explained in one sentence, or if any of those vectors contradict it, the CG is rejected.

## T1 Production Order

T1 scenes are produced as paired jobs: first lock the CG composition and outfits, then derive the transparent portrait from that accepted CG. This applies to Namsan, both amusement-park scenes, Jiyeon's narrow room, Daeun's night bus, both first-morning scenes, proposals, and weddings.
