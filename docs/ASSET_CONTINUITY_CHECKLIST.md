# Gangnam Dream Asset Continuity Checklist

Updated: 2026-07-01

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

### Backgrounds

- Backgrounds are places, not full scenes.
- The place must be structurally readable. A pretty background fails if the player cannot tell where the road, sidewalk, entrance, table center, counter, bed, window, or door actually is.
- No recurring main character inside a reusable background.
- Avoid visible family photos, awards, luxury objects, or extra people unless the location canon explicitly allows them.
- Private/canon-sensitive locations should be person-free unless the image is a one-off CG.
- Public venues may include ambient anonymous people when the location would feel unnatural empty: small dark silhouettes, distant back views, seated figures hidden by furniture/monitors, or crowd texture only.
- If a person has a clear face, foreground pose, readable outfit identity, detailed hands, or protagonist-like framing, treat the asset as a special CG candidate, not a generic background.

### CGs

- CGs may combine people and place, but must match the exact event text.
- Check positions and objects: driver/passenger side, phone direction, bicycle wheels, hands, steering wheel, door, weather, and lighting.
- CGs are allowed to be dramatic; they are not allowed to rewrite character age, wealth, relationship state, or location layout.

### Key Art / Store Capsules

- Keep master key art textless whenever possible.
- Do not rely on image generation for readable game-title text; compose title/logo text locally with real fonts after the image is generated.
- Capsule crops must keep both the emotional subject and the title readable at their final pixel size.
- Store art may be more symbolic than runtime backgrounds, but it must not imply the wrong protagonist wealth tier, age, or genre.

## Locked Location Notes

### Minjun's Goshiwon

- Tiny Sinchon goshiwon room.
- Small high frosted ventilation window only.
- Narrow bed and low desk at bed foot / screen-bottom foreground.
- No skyline window, luxury furniture, separate workroom, or large monitor trading setup.

### Minjun's Family Home

- Modest older working-class Changwon home.
- Father and mother are separated after the fraud; Minjun lives alone in Seoul.
- At most one small faded old photo of father/mother/Minjun or father alone.
- No large framed extended-family portrait, no warm intact big-family image, no wealthy Seoul apartment.

### Investment Scenes

- Early/default investment uses phone or one small laptop in a cramped room.
- Multi-monitor rooms are reserved for scalping, quant/pro trading, or late-game professional contexts.
- A poor goshiwon resident should not appear to own an expensive trading command center.

### Han Jiyeon First Accident

- Han Jiyeon is 31, beautiful, dangerous, and wealthy.
- Vehicle is a black Mercedes-Benz S-Class-level sedan.
- Korean road context: left-hand driver seat.
- She exits from the driver side in the canonical first accident.

### Seoul Street / Bus Stop / Road Backgrounds

- For generic street backgrounds, keep the road, sidewalk, curb, and lane direction immediately readable.
- Do not include a bus stop unless the event needs it. If a bus stop appears, the road-facing/boarding side, bench direction, shelter glass, and pedestrian approach must be spatially coherent.
- Avoid ambiguous glass shelters in non-bus-stop backgrounds; they create the same continuity risk as misplaced car doors or missing bicycle wheels.

## Production Status Tags

- `approved`: canon-safe and wired.
- `placeholder`: acceptable temporarily, but not final.
- `quarantined`: must not be used in runtime default mapping.
- `deprecated`: legacy reference only; replace or delete later.

## Resolved Quarantine

- Previous `assets/backgrounds/family_living_room.png`: contained a large unrelated extended-family portrait and read as a stable large household.
- Current `assets/backgrounds/family_living_room.png`: regenerated on 2026-06-12 as Minjun's father's modest Changwon working-class home and may be used for family-home scenes after visual QA.
