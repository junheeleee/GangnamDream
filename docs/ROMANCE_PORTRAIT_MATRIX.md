# Romance Portrait And CG Continuity Matrix

Updated: 2026-07-10

## Rule

Romance clothing is locked per scene, not per season label. Every event owns a CG, a heroine portrait wearing the same outfit, Minjun's scene outfit, and an explicit gaze target. A new expression may change the face, but it may not silently change the clothes.

The machine-readable source is `assets/romance_visual_manifest.json`. `CGRuntimeCheck` fails when an event's `cg` or `portrait` drifts from this file, when a referenced portrait is missing, or when a special portrait is not exactly 512x768.

## T0 Contract

| Event | Heroine portrait | Heroine outfit | Minjun | Gaze logic |
|---|---|---|---|---|
| Daeun / East Sea | `daeun_sea` | navy swim dress + off-white cover-up | POV; black casual if shown | Daeun looks into Minjun's viewpoint |
| Jiyeon / Haeundae | `jiyeon_sea` | black high-neck swim dress + cream overshirt | cropped left, black casual | Jiyeon looks down-left at Minjun |
| Daeun / fireworks | `daeun_fireworks` | muted blue-gray wrap dress | cropped left, black casual | Daeun watches the sky; Minjun watches her |
| Jiyeon / fireworks | `jiyeon_fireworks` | charcoal hooded windbreaker | cropped left, black casual | Jiyeon turns back toward Minjun |
| Daeun / cherry | `daeun_cherry` | pale-blue belted shirt dress + beige cardigan | POV; black casual if shown | Daeun looks up at the canopy |
| Jiyeon / cherry | `jiyeon_cherry` | cream spring jacket + black knit | cropped left, black casual | Jiyeon looks back at Minjun |
| Daeun / first kiss | `daeun_smile` | navy work polo + beige cardigan | visible left, black casual | mutual eye contact |
| Jiyeon / first kiss | `jiyeon_warm` | cream jacket + black inner | visible right, black casual | mutual eye contact |

`arc_season_sea_daeun` is intentionally staged. The upper-body portrait reads as an ordinary navy travel layer under the same off-white shirt during the train and shop paragraphs. The complete swim-dress silhouette appears only when the beach CG reveals at paragraph 2.

## Minjun Outfit Lock

- Personal dates, hospital visits, the bicycle accident, and intimate family scenes use `player_romance_casual`: the same worn black crewneck as `main_character_unemployed.png`.
- A job does not force Minjun to wear his office uniform on a weekend date. Corporate or office clothing is required only when the text says he came directly from work, is at work, or is performing public success.
- T1 and ending jobs must name Minjun's outfit in the CG prompt and point to an existing portrait reference. If no portrait matches, the CG and new portrait are produced as one pair.

## Gaze Gate

Each named character must have one readable target:

- `player_pov`: direct camera gaze is allowed only when the camera is Minjun's eyes and no second Minjun is visible.
- `mutual`: both pupils converge on the other character's eye line.
- `scene_target`: the heroine looks at fireworks, blossoms, a road, or another explicit story object while Minjun may watch her.
- `over_shoulder`: the heroine looks toward the visible foreground Minjun, not toward an unrelated lens position.

An attractive face looking vaguely toward the viewer is not enough. If the gaze target cannot be explained in one sentence, the CG is rejected.

## T1 Production Order

T1 scenes are produced as paired jobs: first lock the CG composition and outfits, then derive the transparent portrait from that accepted CG. This applies to Namsan, both amusement-park scenes, Jiyeon's narrow room, Daeun's night bus, both first-morning scenes, proposals, and weddings.
