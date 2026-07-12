# Gangnam Dream P0 Ending Visual Bible

This document owns the eight bespoke P0 ending CGs listed in `docs/ENDING_ART.md`. Ending art depicts the final life, not an earlier proposal, wedding, hospital visit, or generic Gangnam reward.

## House Style

- Cinematic 2D Korean manhwa / Japanese visual-novel staging with believable Korean adult anatomy and age.
- Controlled linework, painterly cel shading, matte paper grain, restrained contrast, and practical Korean architecture.
- Palette starts from charcoal, concrete gray, muted navy, winter daylight, and limited warm household light. Runtime Moral Tint owns final Black/Gray/White treatment; never bake sepia, brown morality, saintly glow, or crushed-black unreadability into the source.
- Preserve the exact recurring identities in `assets/CHARACTER_VISUAL_BIBLE.md`. Scene emotion overrides the defeated default expression.
- No readable documents, phone UI, hospital names, apartment brands, car marks, logos, watermarks, or invented named people.

## Runtime Crop Contract

- Source: 1280x800 PNG.
- MainGame also displays the same file inside an approximately 950x430 `STRETCH_KEEP_ASPECT_COVERED` preview. This crops the source's upper and lower edges.
- Every face, gaze target, meaningful hand, phone, deed, curtain edge, bag, cup, or pen must remain inside the central vertical 72% (roughly y=112..688).
- The center horizontal 80% must tell the ending without relying on background text. Peripheral skyline and room detail may crop.
- Named actors look at each other, their reflection, or the scene object. Lens gaze is prohibited unless the prose explicitly establishes Minjun POV.

## 1. `cg_ending_full_circle`

- File: `assets/cg/ending_full_circle_v1.png`.
- Ending: `full_circle`, "In His Father's Name."
- Moment: the day Minjun enters Gangnam, immediately after telling Father by phone that Sangchul's debt has been repaid.
- Camera: medium-wide three-quarter profile inside a newly occupied Gangnam high-rise. Minjun stands at the window with one plain phone at his ear; one unopened moving box and one blank debt envelope/receipt sit behind him.
- Acting: Minjun's eyes are wet but controlled, shoulders finally lowered, gaze moving from the phone toward the ordinary sky. Father is not physically in the room and is not shown as a split-screen inset.
- Avoid: reusing the existing father-in-room `gangnam_dream` CG, visible luxury celebration, villain trophy, readable debt amount, or dead Father imagery.

## 2. `cg_ending_gangnam_dream_white`

- File: `assets/cg/ending_gangnam_dream_white_v1.png`.
- Ending: `gangnam_dream_white`, "Human Until Gangnam."
- Moment: clear early morning at the new apartment window, deed in hand, after reaching three billion won without crossing the line.
- Camera: wide side/back three-quarter. Minjun is alone but not lonely; the open room and Gangnam boulevard remain legible.
- Acting: upright but quiet, one hand holding a blank cream deed folder against his side, the other relaxed. His expression is relief and self-recognition, not conquest.
- Source color: clean cool daylight, natural skin, restrained green/blue city accents. White means recovered color and air, never a white veil.

## 3. `cg_ending_with_daeun`

- File: `assets/cg/ending_with_daeun_v1.png`.
- Ending: `with_daeun`, including married and callback prose variants.
- Moment: weekend evening in a small rented outer-Seoul villa kitchen/dining room. Two bowls of ramyeon cool between Daeun and Minjun.
- Camera: intimate two-shot across/along the small table. The modest home, low ceiling, ordinary kettle, and narrow window establish a life outside Gangnam without making it look like failure.
- Acting: Daeun in a practical soft cardigan lifts chopsticks and looks at Minjun with a small honest smile. Minjun in the black crewneck looks back, one hand close to hers. Rings may be hidden by angle so the image remains valid for both married and unmarried variants.
- Avoid: convenience-store uniform, luxury apartment, visible wedding photo, Father/guest cameo, exaggerated romance pose, or either actor looking at the lens.

## 4. `cg_ending_second_love`

- File: `assets/cg/ending_second_love_v1.png`.
- Ending: `second_love`, "To Gangnam, Together."
- Moment: Daeun stands at a Gangnam apartment balcony/window while Minjun makes a second cup of coffee behind her.
- Camera: room-wide composition with Daeun and the high night view on one visual axis and Minjun at a compact coffee counter on the other. They remain close enough to share the frame, not split into separate panels.
- Acting: Daeun turns partly toward him after asking "And now?" Minjun answers by preparing the second mug, glancing toward her rather than the camera. The silence is the payoff.
- Avoid: copying `with_daeun`'s ramyeon table, wedding staging, status-showcase poses, or making Daeun look like Jiyeon.

## 5. `cg_ending_jiyeon_man`

- File: `assets/cg/ending_jiyeon_man_v2.png`.
- Ending: `jiyeon_man`, across hollow, promise-completed, truth-shared, recovery, and father-reconciled prose variants.
- Moment: a Gangnam high-rise bathroom/foyer mirror after Jiyeon opens the door and stands beside Minjun.
- Camera: reflection-only observer shot from outside the mirror axis. Exactly two people appear in the entire frame, each exactly once and only inside the mirror: Minjun screen-left and Jiyeon screen-right. The illuminated frame, off-axis reflected room depth, and vanity edge establish the mirror while the camera and real-world bodies remain outside the image.
- Mirror pose lock: never generate a second foreground copy of either actor. Removing the duplicate body/reflection pair is the physical guarantee: there is only one head, shoulder line, torso, sleeve fall, and waist per person to stage. Both actors stay upright with level shoulders and square torsos; the vanity crop hides every hand. A visible back, duplicate face, extra limb, camera reflection, or third/fourth person is a failure.
- Acting: Minjun wears a rumpled white shirt with no tie, holding a restrained smile whose eyes remain ambiguous rather than villainous. Jiyeon wears an ivory silk blouse and black trousers, long waves and geometric earrings; she watches his reflection with composed intimacy and danger.
- This ambiguity is intentional: runtime Moral Tint and prose determine whether the same pair inside the mirror reads as chosen togetherness or self-erasure.
- Avoid: bridal gown, mentor-middle-age face, explicit misery, happy-idol pose, duplicate bodies/reflections, lens gaze, impossible mirror geometry, or luxury brand props.

## 6. `cg_ending_guardian`

- File: `assets/cg/ending_guardian_v1.png`.
- Ending: `guardian`, "The Things He Kept."
- Moment: Father is discharged at a modest Changwon hospital covered drop-off/parking edge in clear daylight.
- Camera: medium-wide two-shot. Minjun carries Father's small duffel and folded outer jacket; Father walks beside him in ordinary clothes and looks toward his son.
- Acting: Minjun's body turns toward Father while continuing forward. Father is tired but alive, with no melodramatic collapse. Their mutual gaze carries the saved second life.
- Avoid: reusing the hospital-bed visit CG, wheelchair unless medically required by prose, deathbed light, Seoul skyline, readable hospital branding, or a generic old man.

## 7. `cg_ending_jaehyuk_way`

- File: `assets/cg/ending_jaehyuk_way_v1.png`.
- Ending: `jaehyuk_way`, across Sangchul/Jaehyuk callback variants.
- Moment: Minjun stands alone before a Gangnam apartment window after Father's visit, one hand resting on a heavy curtain edge.
- Camera: wide rear three-quarter. The curtain is half drawn and the city remains partly visible, preserving both the base "closed it" ending and the `sangchul_leverage_stopped` variant that leaves it open.
- Acting: expensive room, ordinary isolated body. Minjun's face is a narrow profile with a stopped expression, not a villain grin. One open moving box may echo arrival; no literal ghosts or trampled faces.
- Source remains readable neutral-dark. Runtime Black drains color and damages surface while money/status details retain their restrained metallic focus.

## 8. `cg_ending_sangchul_reckoning`

- File: `assets/cg/ending_sangchul_reckoning_v1.png`.
- Ending: `sangchul_reckoning`, including police-statement and direct-debt-settlement variants.
- Moment: after the call to Father, in Minjun's modest room by an open window. The phone has just lowered; one plain pen and a small stack of blank papers/envelopes remain on the desk.
- Camera: medium-wide side three-quarter. The open window frames distant Gangnam sky as ordinary sky, not a prize.
- Acting: Minjun's writing hand has stopped trembling and now rests beside the pen; shoulders release for the first time. His eyes remain on the open air, not the lens.
- Avoid: a readable police form, guaranteed police station, cash pile, Sangchul in the room, Father physically present, or Gangnam apartment ownership.

## Acceptance Gate

- Every CG must have a `cg_acting_manifest.json` entry with camera, story action, gaze, and body support for every visible named actor.
- Every target ending owns an explicit `cg` key in the Korean base data; English remains a text-only overlay.
- `ScreenshotQA --qa=ending-p0 --lang=ko/en` must capture the first viewport at 1280x800, assert the exact texture path, and prove that the key action survives the 950x430 preview crop.
- The same scope must render `gangnam_dream_white` at White, `jaehyuk_way` at Deep Black, and the remaining endings at their narratively valid bands without exposing a morality label.
- No process/wedding CG may substitute for a final-life CG.
