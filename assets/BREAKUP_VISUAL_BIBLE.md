# Gangnam Dream Breakup Visual Bible

This document owns the two T2 romance rupture CGs. They are choice-result images, never event preludes and never ending substitutes.

## Shared Contract

- Source and runtime: 1280x800 PNG, restrained-color Gangnam Ink VN climax layer.
- A breakup CG appears only after the player commits to the separating choice and only when the result prose reaches the depicted action.
- The lower 30% is UI-safe. A face, gaze, decisive hand, threshold, or document may not depend on that area.
- No morality label, visible legal text, brand, wedding spectacle, lens gaze, or invented witness.
- These scenes are quiet consequences. Avoid revenge glamour, screaming, collapsed sobbing, saint/villain framing, and generic breakup stock poses.

## Daeun: `cg_romance_breakup_daeun`

- File: `assets/cg/romance/breakup_daeun_v1.png`.
- Owner: `arc_daeun_final_choice_decision`, betrayal choice 1, result paragraph 3. The prelude chain is `arc_daeun_final_choice` → kitchen/name branch → decision.
- Prelude location: the canonical modest `daeun_newlywed_home`, not a Gangnam street.
- Prelude portrait: hidden. The prose places Daeun offscreen in the kitchen; showing a floating convenience-store-uniform portrait would contradict the blocking.
- Moment: after learning the truth, Daeun presses one red seal onto one blank separation paper at the dining table.
- Wardrobe: same dusty-mauve wrap cardigan, cream home top, charcoal trousers, short hair, and left-temple clip as the married-home continuity set. Never the convenience-store uniform.
- Acting: no tears or lens gaze. Daeun looks just past Minjun, right hand on the seal, left hand flat on the paper. Minjun is a rear three-quarter white-shirt foreground with lowered shoulders and withdrawn hands.
- Prop lock: exactly one blank paper, one red seal, and one black pen. The paper carries no readable language or fabricated legal details.

## Jiyeon: `cg_romance_breakup_jiyeon`

- File: `assets/cg/romance/breakup_jiyeon_v1.png`.
- Owner: `arc_jiyeon_verdict_decision`, release choice 1, result paragraph 2. The prelude chain is `arc_jiyeon_verdict` → voice/fear branch → decision.
- Prelude location: the canonical `jiyeon_newlywed_home`, not a generic Gangnam street.
- Moment: Jiyeon crosses the apartment threshold toward a physically coherent corridor/elevator lobby while Minjun stays behind.
- Wardrobe: canonical ivory blazer, black blouse and trousers, geometric earrings, waist-length black waves, and one small structured black handbag. No wedding dress or suitcase.
- Acting: Jiyeon remains upright and does not turn back for reassurance. Her gaze follows the corridor. Minjun remains seated near the room/window, smaller in frame, watching her and not reaching.
- Architecture lock: the front door opens to an indoor apartment corridor, never directly onto a street. The warm room and cool corridor may contrast without fantasy lighting.

## Acceptance Gate

- `ImageRegistry`, Korean base events, `romance_visual_manifest.json`, `event_visual_contracts.json`, and `cg_acting_manifest.json` agree on both owners and paths.
- Korean and English overlays produce identical CG timing because English remains text-only.
- `ScreenshotQA --qa=breakup --lang=ko/en` proves the pre-choice location, Daeun portrait absence, Jiyeon portrait identity, non-separating branches with no leaked CG, and exact paragraph-delayed reveals.
- Both CGs remain readable at 1280x800 under their seeded Moral bands and hide the ordinary result ledger while active.
