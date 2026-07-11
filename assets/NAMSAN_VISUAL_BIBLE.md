# Namsan Visual Bible

Updated: 2026-07-11

This file owns the physical layout, staging, outfits, and gaze logic for the paired Namsan romance events. The indoor observation-deck beat and the outdoor love-lock beat are two adjacent places, not one interchangeable background.

## Location Split

### Cable Car Ascent

- Runtime background: `assets/backgrounds/namsan_cable_car_night.png`.
- Person-free enclosed cabin with broad slanted windows, coherent cable lines, compact benches, a dark rubber floor, and Seoul/Han River visibly dropping away below.
- It must read as an aerial cable car, never a bus, subway, train aisle, cafe, or exterior aerial shot.

### Tonkatsu Restaurant

- Runtime background: `assets/backgrounds/namsan_tonkatsu_restaurant_night.png`.
- Modest old-fashioned hillside restaurant with two oversized Korean wang-donkatsu plates on a two-person table, ordinary vinyl chairs, and a practical service counter.
- It is a pork-cutlet restaurant, not Korean barbecue: no tabletop grills, exhaust hoods, luxury service, or readable menu text.
- Small distant back-view staff silhouettes are allowed; no clear secondary face or named-character proxy.

### Indoor Observation Deck

- Runtime background: `assets/backgrounds/namsan_observation_deck_night.png`.
- A person-free, reusable interior with floor-to-ceiling glass, dark structural mullions, restrained ceiling reflections, the Han River, bridges, and Seoul/Gangnam lights below.
- The camera stands inside the summit observatory. The city is below the eye line; this is not a cafe, rooftop, hotel suite, or exterior mountain path.
- No named character, readable signage, logos, love locks, dining tables, or decorative crowd is baked into this background.

### Outdoor Love-Lock Terrace

- One-off CG owners: `namsan_lock_daeun_v1.png` and `namsan_lock_jiyeon_v1.png`.
- The iron-mesh safety railing is densely covered with varied existing padlocks. Locks may imply old names and dates through wear, but no generated text is readable.
- The terrace is part of the summit tower complex. A partial cylindrical tower/base structure may rise immediately at frame-right; a complete tower on a distant hill is physically wrong.
- Seoul and the river sit below the terrace. The lower 31 percent stays dark and low-detail enough for the VN dialogue box.

## Character And Outfit Locks

### Kim Minjun

- Worn black crewneck, washed charcoal-black casual jacket, and dark trousers.
- No suit, luxury watch, business bag, or late-game success styling.

### Kim Daeun

- `daeun_namsan`: muted moss-green short duffle coat over an ivory ribbed knit and dark straight jeans.
- Same short layered dark-brown jaw/nape hair, wispy bangs, and small clip over the left temple as her identity reference.
- CG action: she rests one hand naturally on the rail above the existing locks while asking Minjun the question; she and Minjun hold mutual eye contact.

### Han Jiyeon

- `jiyeon_namsan`: deep sapphire-blue tailored belted wool coat over a charcoal-black silk mock-neck and slim black trousers, with restrained geometric gold earrings.
- Same long black waves, sharp early-30s face, and old-money restraint as her identity reference.
- CG action: she says the ritual is childish but remains planted, arms crossed, studying an existing lock. Minjun watches her contradiction; neither looks at the lens.

## Composition Contract

- Daeun CG: Minjun screen-left, Daeun screen-right, mutual eye line.
- Jiyeon CG: Jiyeon screen-left, Minjun screen-right, Jiyeon's gaze on a lock and Minjun's gaze on Jiyeon.
- Keep both faces above `y=330` in the 1280x800 master so a normal dialogue panel cannot erase the acting.
- Hands must be anatomically plausible and secondary to the eye line. Do not add a newly personalized lock before the player chooses whether to hang one.

## Prohibited

- Full Namsan tower across another hill, aerial resort view, generic rooftop, cafe interior, hotel lounge, or street-level tower view.
- Heroine looking into the camera, both actors staring in unrelated directions, or a hand gesturing at an object the eyes ignore.
- Daeun with long hair, teenage styling, luxury coat, or influencer makeup.
- Jiyeon with a bob, middle-aged face, generic office suit, or Daeun-like modest palette.
- Readable AI text, heart-shaped branded props, logos, crowds with clear faces, or a pre-written couple lock before the choice.
