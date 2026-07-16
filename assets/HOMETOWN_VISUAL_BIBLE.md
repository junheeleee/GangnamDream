# Daeun Hometown Visual Bible

Updated: 2026-07-17

This file owns the location, calendar, wardrobe, and acting continuity for `arc_daeun_hometown_1` and `arc_daeun_hometown_2`.

## Calendar Contract

- The trip begins only in June, July, or August after turn 100.
- If its story prerequisites are met outside summer, it waits for the next summer instead of disappearing.
- Once episode 1 has begun, episode 2 completes the same two-day trip even if the calendar crosses a month boundary.
- Daeun wears one continuous travel outfit in the train, her mother's home, and the return bus.

## Character And Wardrobe Lock

- Daeun is 33 with short layered dark-brown hair, wispy bangs, and the same left-temple clip as her core portrait.
- Outfit: pale sage lightweight cotton overshirt with sleeves rolled below the elbows, ivory T-shirt, dark navy trousers, and charcoal shoulder strap.
- `daeun_hometown_worried` owns the train expression. Her gaze stays lowered toward Minjun or their joined space, never vaguely at the lens.
- `daeun_hometown_warm` owns the dinner expression. It is a small, embarrassed, closed-mouth smile, not a cheerful clerk performance.
- Minjun keeps his off-duty worn black crewneck/jacket and dark trousers. His bus expression is quiet relief, not the defeated default portrait.

## Location Lock

### Regional Train

- Camera is inside a modest Korean intercity train, beside a two-seat window pair.
- Summer rice paddies and low rural hills move outside. An outdoor platform cannot substitute for the written window scene.
- No named or clearly readable foreground passenger is baked into the reusable background.

### Daeun's Mother's Home

- This is not Minjun's father's Changwon home and never uses `dad_house`.
- Modest rural Korean dining room at summer dusk: kitchen, standing fan, medicine and reading glasses, fields outside.
- The table has exactly three diners' place settings and one thick rolled omelet at the center.
- No large family portrait, male factory jacket, wealthy apartment signal, or fourth invisible diner.

### Return Bus

- Daeun sits in the window seat and sleeps with her head against the glass, not on Minjun's shoulder.
- Minjun sits on the aisle/right and looks toward Daeun and the shared reflection with a restrained peaceful smile.
- Sparse rural lights recede while denser Seoul lights approach in the same pane.
- No physical contact, lens gaze, giant ghost reflection, or unexplained wardrobe change.

## Runtime Timing

- Episode 2 is one continuous scene across `arc_daeun_hometown_2`, `arc_daeun_hometown_table_hands` or `arc_daeun_hometown_table_daughter`, and `arc_daeun_hometown_table_decision`. All links retain `daeun_mother_home_dining` and `daeun_hometown_warm`.
- The first two choices are dialogue and observation only. They may not set flags, affinity, Moral Tint, mental, or money before the final decision.
- The dinner background and `daeun_hometown_warm` portrait remain during result paragraph 0.
- `cg_romance_hometown_night_bus_daeun` appears at result paragraph 1, exactly when the prose reaches the night bus.
- The shared event-level result CG applies to both choices; duplicating it on each choice is prohibited.

## Runtime IDs

- Backgrounds: `regional_train_window`, `daeun_mother_home_dining`
- Portraits: `daeun_hometown_worried`, `daeun_hometown_warm`
- CG: `cg_romance_hometown_night_bus_daeun`
