# Gangnam Dream Asset Continuity Checklist

Updated: 2026-06-12

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
- No recurring main character inside a reusable background.
- Avoid visible family photos, awards, luxury objects, or extra people unless the location canon explicitly allows them.
- If a background contains a person, treat it as a special CG candidate, not a generic background.

### CGs

- CGs may combine people and place, but must match the exact event text.
- Check positions and objects: driver/passenger side, phone direction, bicycle wheels, hands, steering wheel, door, weather, and lighting.
- CGs are allowed to be dramatic; they are not allowed to rewrite character age, wealth, relationship state, or location layout.

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

## Production Status Tags

- `approved`: canon-safe and wired.
- `placeholder`: acceptable temporarily, but not final.
- `quarantined`: must not be used in runtime default mapping.
- `deprecated`: legacy reference only; replace or delete later.

## Resolved Quarantine

- Previous `assets/backgrounds/family_living_room.png`: contained a large unrelated extended-family portrait and read as a stable large household.
- Current `assets/backgrounds/family_living_room.png`: regenerated on 2026-06-12 as Minjun's father's modest Changwon working-class home and may be used for family-home scenes after visual QA.
