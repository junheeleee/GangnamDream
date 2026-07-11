# First-Snow Visual Bible

Updated: 2026-07-11

## Shared Contract

- Both events fire only in December through `MainGame._season_date_id()`.
- Paragraph 0 establishes the location with a transparent winter portrait over a person-free background.
- Paragraph 1 reveals the full 1280x800 CG; the portrait and StoryMode HUD must disappear.
- Minjun wears the same worn black quilted winter jacket over a charcoal crewneck in both routes.
- Snow, practical light, and wet or icy ground stay subdued. The scene is intimate adult drama, not a holiday postcard.

## Daeun Route

- Event: `arc_season_snow_daeun`
- Background: `convenience_store_exterior_first_snow.png`
- Portrait: `npc_daeun_first_snow.png`
- CG: `first_snow_daeun_v1.png`
- Location is outside the same neighborhood convenience store where Daeun and Minjun first met.
- The blank fascia, glass entrance, counter near the entrance, and refrigerator bank deeper inside establish a plausible Korean store floor plan.
- Daeun wears a muted cranberry quilted coat, oatmeal scarf, charcoal layers, and dark trousers.
- Exactly two small plain canned coffees exist: she offers one with her right hand and retains one with her left.
- Daeun and Minjun look at each other. Neither looks into the lens.

## Jiyeon Route

- Event: `arc_season_snow_jiyeon`
- Background: `jiyeon_sedan_first_snow_interior.png`
- Portrait: `npc_jiyeon_first_snow.png`
- CG: `first_snow_jiyeon_v1.png`
- The vehicle is Jiyeon's unbranded black premium sedan with Korean left-hand drive.
- Jiyeon occupies the screen-left driver seat; Minjun occupies the screen-right front passenger seat.
- Both seat belts remain fastened. The car is stopped and the windshield wipers rest at the bottom edge.
- Jiyeon wears a deep charcoal tailored coat over a dark garnet turtleneck with restrained geometric earrings.
- After she says, "Let's stay like this," both turn toward each other. The gaze is mutual and story-motivated, never accidental lens contact.

## Regression Gate

- `assets/romance_visual_manifest.json` owns outfit, December, visibility, and eye-line contracts.
- `assets/cg_acting_manifest.json` owns camera, action, gaze, seating, and prop contracts.
- `tools/CGRuntimeCheck.gd` proves prelude background/portrait, delayed CG reveal, and December-only routing.
- `tools/ScreenshotQA.gd --qa=first-snow --lang=ko|en` captures both preludes, reveals, choices, and results.
