# Gangnam Dream Asset Continuity Checklist

Updated: 2026-07-11

Use this before generating, accepting, wiring, or replacing any image asset. A visually strong image still fails if it says the wrong thing about the story.

## Source Order

1. `CLAUDE.md` current-state block and project rules
2. Runtime code and shipped JSON
3. `docs/CANON_MAP.md`
4. `docs/STORY_BIBLE.md`
5. Asset-specific canon files such as `assets/CHARACTER_VISUAL_BIBLE.md`
6. Older briefs and logs, only as historical context

## Required Pass Before Production

- Canon owner: identify the character, location, route, or one-off scenario the image belongs to.
- Asset type: choose background, transparent portrait, CG, UI icon, or key art before prompting.
- Economic tier: confirm what the image implies about money, housing, job status, and class.
- Family signal: inspect photos, furniture, living arrangement, and visible household size.
- Time and place: confirm city, district, season, day/night, weather, and vehicle side.
- Functional layout sanity: confirm the object/space could physically work in real life before judging mood. Roads need readable lanes/curbs/crosswalks; bus stops need coherent road-facing direction, bench orientation, shelter glass placement, and boarding side; cars need correct driver/passenger side; tables/game boards need centered play areas and aligned chips/cards/numbers.
- Reuse risk: ask whether this image will appear repeatedly; if yes, avoid baked-in scene details.
- Text/brands: remove or neutralize accidental words, logos, vehicle names, and impossible signage.
- Crop check: verify important story details survive the actual in-game crop.
- Quarantine rule: if an asset contradicts canon, remove it from runtime mapping before regenerating.

## Asset-Type Rules

### Recurring Character Portraits

- Transparent background only.
- No room, street, office, car, skyline, or event-specific props in the portrait.
- Lock age, hair, outfit class signal, expression range, and silhouette in `assets/CHARACTER_VISUAL_BIBLE.md`.
- Reuse the same character design across expressions; do not let the model age or recast the person.
- A CG outfit and its event portrait must use the same clothing unless the text explicitly shows a wardrobe change between paragraphs.
- Lock Minjun's clothing too. A heroine match does not excuse a protagonist who changes from sweatshirt to suit between portrait and CG.
- Audit posture as identity, not generic mood. The cast must not share one
  hunched frontal bust pose merely because the story is difficult.
- Tired acting keeps the eyes legible and the spine readable. Use gaze, eyelid
  tension, jaw, breathing, and shoulder relaxation before bending the whole
  torso. Half-shut red eyes or a collapsed chest fail unless an explicit
  illness/injury scene owns them.
- Compare recurring portraits as a silhouette sheet before approval: Minjun's
  guarded lean, Daeun's careful upright stance, Jiyeon's controlled posture,
  Hyunsu's rounded ease, Jaehyuk's polish, Sangchul's grounded lean, and
  Father's mild age-specific stoop must differ at a one-second glance.

### Backgrounds

- Backgrounds are places, not full scenes.
- The place must be structurally readable. A pretty background fails if the player cannot tell where the road, sidewalk, entrance, table center, counter, bed, window, or door actually is.
- No recurring main character inside a reusable background.
- Avoid visible family photos, awards, luxury objects, or extra people unless the location canon explicitly allows them.
- Private/canon-sensitive locations should be person-free unless the image is a one-off CG.
- Public venues may include ambient anonymous people when the location would feel unnatural empty: small dark silhouettes, distant back views, seated figures hidden by furniture/monitors, or crowd texture only.

### Presence and communication

- A standing portrait means the character is physically present in the scene location.
- Phone, video-call, message, and memory scenes must be registered in `content/meta/story_rules.json`; prose alone is not enough to distinguish them.
- A remote speaker uses the compact communication inset. A local reaction portrait may remain full size, but the media badge must stay visible.
- `scene_location` and `remote_location` must describe different physical spaces for remote media. Example: Minjun's goshiwon / Father's Changwon home.
- A split-screen call CG is allowed and remains authoritative, but its event still needs a channel contract for fallback portraits and accessibility context.
- If a person has a clear face, foreground pose, readable outfit identity, detailed hands, or protagonist-like framing, treat the asset as a special CG candidate, not a generic background.

### CGs

- CGs may combine people and place, but must match the exact event text.
- Check positions and objects: driver/passenger side, phone direction, bicycle wheels, hands, steering wheel, door, weather, and lighting.
- Name every character's gaze target: partner, player POV, or a scene object. Unexplained lens gaze is a rejection.
- CGs are allowed to be dramatic; they are not allowed to rewrite character age, wealth, relationship state, or location layout.

#### Gaze And Acting Hard Gate

- Every CG job must declare `camera_role`, `gaze_source`, and `gaze_target` before generation.
- A character looks into the lens only when the event explicitly makes the camera the player POV. Even then, the pupils target the player's implied eye position, not the image center by default.
- In a two-person frame, head angle, pupil direction, shoulder turn, and hand gesture must all point to the same partner or object. Correct pupils on a catalog pose still fail.
- Natural expression is asymmetric: brows, lids, mouth corners, cheek tension, and head tilt do not mirror perfectly. A stock smile pasted onto a face is a rejection.
- The expression must answer the current verb in the prose: offering, checking, withholding, turning back, flinching, listening, or deciding. Generic `smiling at viewer` is not an acting direction.
- UI portraits may address the player as interface figures. Narrative CGs must belong to the scene and its relationships.
- During crop QA, cover the dialogue area and confirm that the remaining eyes still explain who is looking at whom.

### Key Art / Store Capsules

- Keep master key art textless whenever possible.
- Do not rely on image generation for readable game-title text; compose title/logo text locally with real fonts after the image is generated.
- Capsule crops must keep both the emotional subject and the title readable at their final pixel size.
- Store art may be more symbolic than runtime backgrounds, but it must not imply the wrong protagonist wealth tier, age, or genre.

## Locked Location Notes

### Minjun's Goshiwon

- Full layout owner: `assets/GOSHIWON_VISUAL_BIBLE.md`.
- Tiny Sinchon goshiwon room.
- Small high frosted ventilation window only.
- Narrow bed and low desk at bed foot / screen-bottom foreground.
- No skyline window, luxury furniture, separate workroom, or large monitor trading setup.
- One left-wall bed running front-to-back, one right-front low desk, one small high frosted window, and one right-side door. Duplicate doors/switches and transverse beds are rejection errors.

### Minjun's Family Home

- Modest older working-class Changwon home.
- Father and mother are separated after the fraud; Minjun lives alone in Seoul.
- At most one small faded old photo of father/mother/Minjun or father alone.
- No large framed extended-family portrait, no warm intact big-family image, no wealthy Seoul apartment.
- `assets/cg/seollal_sebae_family_v1.png` is the approved one-off Seollal action reference: Father plus two paternal relatives, no mother, exactly four people including bowing Minjun, and the same sofa/table/TV/entry class signal as `family_living_room.png`.

### Investment Scenes

- Early/default investment uses phone or one small laptop in a cramped room.
- Multi-monitor rooms are reserved for scalping, quant/pro trading, or late-game professional contexts.
- A poor goshiwon resident should not appear to own an expensive trading command center.

### Han Jiyeon First Accident

- Han Jiyeon is 31, beautiful, dangerous, and wealthy.
- Vehicle is a black Mercedes-Benz S-Class-level sedan.
- Korean road context: left-hand driver seat.
- She exits from the driver side in the canonical first accident.

### Han Jiyeon's Recurring Sedan

- Treat the sedan as a recurring character prop, not a generic luxury-car placeholder.
- Exterior reference is `assets/cg/jiyeon_crash_day_v3.png`; interior reference is `assets/cg/romance/first_kiss_jiyeon.png`.
- Follow `assets/VEHICLE_VISUAL_BIBLE.md` for body class, wheel/trim language, black leather cabin, and left-hand-drive seating.
- The first-snow, sun-visor photo-strip, drive-home, and future DLC scenes all use the same car unless the story explicitly records a replacement.

### Seoul Street / Bus Stop / Road Backgrounds

- For generic street backgrounds, keep the road, sidewalk, curb, and lane direction immediately readable.
- Do not include a bus stop unless the event needs it. If a bus stop appears, the road-facing/boarding side, bench direction, shelter glass, and pedestrian approach must be spatially coherent.
- Avoid ambiguous glass shelters in non-bus-stop backgrounds; they create the same continuity risk as misplaced car doors or missing bicycle wheels.
- `assets/backgrounds/seoul_bus_stop_wallet.png` is the approved wallet-event reference: road-facing bench, front glass windbreak, open boarding doorway, tactile paving, curb, and bus lane in one readable axis. The wallet is event-specific and must remain above the dialogue crop.

### Daeun's Convenience Store

- The canonical floor plan and camera lanes live in `assets/CONVENIENCE_STORE_VISUAL_BIBLE.md`.
- Checkout sits beside the glass entrance so the clerk can see arrivals and departures.
- The clerk stands between the counter and a solid tobacco/storage wall. Refrigerators never occupy the wall directly behind the clerk.
- The POS screen faces the clerk. Customers see the back or side of the monitor.
- Refrigerators run along the opposite or perpendicular perimeter wall, separated from the staff pocket.
- Minjun stands on the public store side near the entrance; Daeun remains inside the staff pocket. The counter must visibly separate them.

### Minjun's First Interview

- The canonical layout and two-person staging live in `assets/OFFICE_INTERVIEW_VISUAL_BIBLE.md`.
- Daytime Mapo small-company office, not a night office or Gangnam executive room.
- Interviewer sits on the window/staff side; Minjun sits on the door/candidate side in the inexpensive navy interview suit.
- The resume and their mutual eye line carry the six-year-gap question. Neither actor looks at the lens.
- Reusable interview backgrounds remain person-free. The unnamed interviewer appears only in the one-off CG.

### Namsan Date Route

- Full layout and paired-route owner: `assets/NAMSAN_VISUAL_BIBLE.md`.
- The first paragraph uses the enclosed aerial cable-car cabin; it must not read as a bus, subway, or observation deck.
- The second paragraph uses the wang-donkatsu restaurant with oversized pork-cutlet plates and no tabletop barbecue grill.
- Observation-deck preludes use the person-free indoor glass-wall background; do not show an exterior mountain path or cafe.
- Love-lock follow-ups use heroine-specific CGs on the outdoor summit terrace.
- The tower complex is immediately beside the terrace. A full tower across another hill is a structural rejection error.
- Do not show a newly personalized couple lock before the player chooses to hang one.

### Amusement Park Date Routes

- Full location, floor-plan, outfit, and acting owner: `assets/AMUSEMENT_PARK_VISUAL_BIBLE.md`.
- Fixed outerwear is valid only in March-May or September-November; the milestone waits outside those months.
- Daeun's first paragraph uses the person-free parade promenade and her slate-blue portrait. The helping CG begins only after she has met the lost child.
- In Daeun's CG, each adult holds exactly one separate child hand. Minjun must look reassuringly present rather than inheriting his unemployed defeat expression.
- If the player returns to rides, the result must restore the roller-coaster background and Daeun portrait instead of leaving the helping CG under contradictory prose.
- Jiyeon's first paragraph uses the front-row lift-hill background, and the second uses the physically correct two-person booth.
- Booth bench and camera/monitor sit on opposite walls and face each other. A camera behind the bench or a one-person passport stool is a structural rejection.
- Jiyeon's four-cut CG appears only after the photo choice. All four face beats stay above the dialogue-safe lower region; the skipped-photo result returns to the roller coaster.

### Daeun Hometown Route

- Full calendar, location, wardrobe, and result-timing owner: `assets/HOMETOWN_VISUAL_BIBLE.md`.
- Episode 1 starts only in June-August and defers to a later summer; episode 2 completes an already-started trip.
- The train scene must use an interior window-seat background, not the provincial station platform.
- Daeun's mother's dining room is separate from Minjun's father's Changwon home and has exactly three place settings.
- Daeun keeps the same pale-sage summer outfit in both portraits and the return-bus CG.
- The dinner stays visible through result paragraph 0. The night-bus CG appears only at result paragraph 1.

### First Night And Morning Routes

- Full home, wardrobe, gaze, and result-timing owner: `assets/FIRST_MORNING_VISUAL_BIBLE.md`.
- Daeun and Jiyeon never share the generic apartment background. Daeun owns a modest small one-bedroom rental; Jiyeon owns a spacious high-rise home.
- The first-night portrait and morning CG preserve the same indoor outfit. Indoor scene contracts are valid across seasons and must not be mistaken for missing outdoor winter coverage.
- Night result paragraph 0 retains the home background and portrait. The morning CG appears only at result paragraph 1.
- Daeun's two hands must remain attached to one cooking action: ring hand on the pan, other hand on the spatula, rolled omelet in the pan.
- Jiyeon's direct gaze is legal only as Minjun's explicit POV; exactly one hand pulls the duvet to her nose and the other remains hidden.

### First-Snow Romance Routes

- Full calendar, location, wardrobe, prop, vehicle, and gaze owner: `assets/FIRST_SNOW_VISUAL_BIBLE.md`.
- Both routes fire only in December. Paragraph 0 retains a person-free location background and the dedicated winter portrait; paragraph 1 reveals the full CG and hides portrait/HUD.
- Daeun waits outside the canonical convenience store in a cranberry quilted coat and oatmeal scarf. Exactly two small canned coffees exist: one offered, one retained.
- Jiyeon remains in the screen-left driver seat of her recurring left-hand-drive black sedan; Minjun remains in the screen-right passenger seat. Both belts stay fastened and the stopped wipers rest at the windshield base.
- Mutual gaze is legal only after the prose establishes Daeun's offered coffee or Jiyeon's request to stay. Neither scene uses accidental lens contact.

### Explicit Climate Portraits

- `kx_monsoon`, `kx_heatwave`, and `kx_cold_snap` use dedicated Minjun portraits rather than the generic long-sleeve tired portrait.
- Rain shell, short sleeves/cooling towel, and padded parka/scarf must be readable before expression detail.
- Climate portraits remain transparent 512x768 assets and never bake in their street backgrounds.
- Cold-snap streets must show frozen road/curb logic without ambiguous bus shelters or unrelated foreground people.

## Production Status Tags

- `approved`: canon-safe and wired.
- `placeholder`: acceptable temporarily, but not final.
- `quarantined`: must not be used in runtime default mapping.
- `deprecated`: legacy reference only; replace or delete later.

## Resolved Quarantine

- Previous `assets/backgrounds/family_living_room.png`: contained a large unrelated extended-family portrait and read as a stable large household.
- Current `assets/backgrounds/family_living_room.png`: regenerated on 2026-06-12 as Minjun's father's modest Changwon working-class home and may be used for family-home scenes after visual QA.
