# First Night And Morning Visual Bible

Updated: 2026-07-17

This file owns the spatial, wardrobe, reveal-timing, and acting continuity for `arc_daeun_wedding_night` and `arc_jiyeon_wedding_night`.

## Shared Contract

- The wedding night is a private indoor scene and is valid in every season. Do not add a calendar gate merely to justify clothing.
- Each heroine owns a separate home. The generic `apartment` background is prohibited for these events.
- The event portrait and following-morning CG use the same indoor outfit. No unexplained wardrobe change occurs during the fade.
- Each route is a three-link chain with two decisions. The root and both dialogue branches remain in the same home, portrait, outfit, ambience, and score; no transition may imply a second location or a wardrobe change.
- Daeun branches through tea or mutual honesty before `arc_daeun_wedding_night_choice`. Jiyeon branches through the shared window or the untouched wineglass before `arc_jiyeon_wedding_night_choice`.
- The root and branch links apply no effects, cast effects, flags, or CG. Only the final choice owns the canonical relationship result.
- The night result remains on the home background with the portrait through result paragraph 0.
- The morning CG appears only on each `*_wedding_night_choice` event at `result_cg_reveal_paragraph: 1`, when the prose explicitly says the next morning.
- Minjun is the player POV in both morning CGs. Do not draw a duplicate Minjun body into the frame.
- The lower dialogue region must not cover the heroine's face, gaze target, hands, wedding ring, omelet, or duvet action.

## Daeun Home And Outfit

- Background owner: `assets/backgrounds/daeun_newlywed_home_night.png`.
- A modest small Seoul one-bedroom rental: compact kitchen on screen-left, bedroom doorway near center, entrance on screen-right, and half-unpacked moving boxes.
- Two pairs of shoes and ordinary furniture establish a shared first home without implying Gangnam wealth.
- Portrait owner: `assets/characters/npc_daeun_wedding_night.png`.
- Outfit lock: muted dusty-mauve soft-knit wrap cardigan, cream square-neck cotton top, and charcoal lounge trousers.
- Identity lock: age 33, short layered dark hair, left-temple clip, warm brown eyes, and a small closed-mouth shy smile.

### Daeun Morning CG

- CG owner: `assets/cg/romance/wedding_morning_daeun_v1.png`.
- Daeun stands in the same kitchen in the same outfit, shown from a back three-quarter angle.
- Her gaze stays on the rolled omelet. Her left hand grips the pan handle and shows the wedding ring; her right hand holds the wooden spatula.
- Exactly two hands are visible and both perform one physically coherent cooking action.
- The emotional verb is `making a first shared home through an ordinary breakfast`, not posing for Minjun or the camera.

## Jiyeon Home And Outfit

- Background owner: `assets/backgrounds/jiyeon_newlywed_home_night.png`.
- A spacious high-end Seoul high-rise: charcoal stone and fabric, broad city window on screen-right, restrained wine service, and only a few moving boxes.
- Expense is communicated through proportion and material, not visible brands or excessive gold decoration.
- Portrait owner: `assets/characters/npc_jiyeon_wedding_night.png`.
- Outfit lock: deep midnight-blue matte-silk wrap lounge blouse with muted burgundy piping and black tailored lounge trousers.
- Identity lock: age 31, long black hair, sharp adult eyes, elegant posture, and composure visibly beginning to crack.

### Jiyeon Morning CG

- CG owner: `assets/cg/romance/wedding_morning_jiyeon_v1.png`.
- Jiyeon is bare-faced in the same blouse, with naturally disordered long hair and cool dawn light through the same high-rise window language.
- The camera is Minjun's eye position. Direct gaze is allowed only because the prose explicitly says she notices him looking.
- Exactly one hand is visible pulling the duvet to her nose; the other remains hidden.
- No lingerie, nudity, glamour pose, or generic `smiling at viewer` direction. The emotional verb is `being seen without armor and trying to recover`.

## Runtime Owners

- Portrait IDs: `daeun_wedding_night`, `jiyeon_wedding_night`.
- Background IDs: `daeun_newlywed_home`, `jiyeon_newlywed_home`.
- CG IDs: `cg_romance_wedding_morning_daeun`, `cg_romance_wedding_morning_jiyeon`.
- Regression owners: `tools/CGRuntimeCheck.gd`, `tools/peak_scene_chain_audit.py`, `assets/romance_visual_manifest.json`, `assets/cg_acting_manifest.json`, and `--qa=wedding-morning --lang=ko/en`.
